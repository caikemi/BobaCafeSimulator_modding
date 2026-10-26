"""在本工程/官方 Mod SDK 内创建两个容器示例子蓝图。

需要已有游戏父蓝图及对应 C++ 插件，不能在空白 UE 工程中直接运行。
只保存两个新建的示例资产；同名资产已存在时只验证父类并保留原内容。
不会保存地图、原始父蓝图或整个 Content 目录。

UE 命令行示例：
UnrealEditor-Cmd.exe BobaCafeSimulator.uproject -run=pythonscript
  -script=Tools/CreateModContainerBlueprints.py
  -EnablePlugins=PythonScriptPlugin,EditorScriptingUtilities -unattended -NullRHI
"""

import hashlib
import json
import re
from pathlib import Path

import unreal


DEFINITIONS = (
    {
        "asset_path": "/Game/Mods/MyWaterBucket/BP_MyWaterBucket",
        "parent_asset_path": "/Game/2Game/Blueprint/BP_1022水桶",
        "item_id": "Mod_NewWaterBucket_20000",
    },
    {
        "asset_path": "/Game/Mods/MyLiquidContainer/BP_MyLiquidContainer",
        "parent_asset_path": "/Game/2Game/Blueprint/BP_液体容器",
        "item_id": "Mod_NewLiquidContainer_20000",
    },
)


def generated_class_path(asset_path):
    """将包路径转换成蓝图生成类的完整对象路径。"""
    return asset_path + "." + asset_path.rsplit("/", 1)[1] + "_C"


def source_file(project_root, asset_path):
    """取得当前工程 /Game 源资产的磁盘路径，用于验证原文件未变。"""
    return project_root / "Content" / (asset_path.removeprefix("/Game/") + ".uasset")


def fingerprint(path):
    """记录源文件哈希；不写入或修改源资产。"""
    if not path.is_file():
        return None
    return hashlib.sha256(path.read_bytes()).hexdigest()


def direct_parent_path(blueprint, report_directory):
    """读取实际直接父类；必要时只读导出文本，不保存蓝图包。"""
    asset_data = unreal.EditorAssetLibrary.find_asset_data(blueprint.get_path_name())
    value = asset_data.get_tag_value("ParentClass")
    if isinstance(value, tuple):
        value = next((item for item in reversed(value) if isinstance(item, str)), "")
    if value:
        match = re.search(r"'([^']+)'", str(value))
        return match.group(1) if match else str(value)

    text_path = report_directory / (blueprint.get_name() + "_verification.copy")
    task = unreal.AssetExportTask()
    task.object = blueprint
    task.filename = str(text_path)
    task.exporter = unreal.ObjectExporterT3D()
    task.automated = True
    task.prompt = False
    task.replace_identical = True
    if not unreal.Exporter.run_asset_export_task(task):
        raise RuntimeError("Cannot read the direct parent of " + blueprint.get_path_name())
    raw = text_path.read_bytes()
    text = raw.decode("utf-16" if raw.startswith(b"\xff\xfe") else "utf-8-sig")
    match = re.search(r"^   ParentClass=.*?'([^']+)'", text, re.MULTILINE)
    if not match:
        raise RuntimeError("The Blueprint export did not contain a direct parent class.")
    return match.group(1)


def main():
    """预检全部父类后创建缺失资产，并写出可核对的 CDO 与哈希证据。"""
    project_root = Path(unreal.Paths.convert_relative_path_to_full(unreal.Paths.project_dir()))
    report_directory = project_root / "tmp"
    report_directory.mkdir(parents=True, exist_ok=True)
    report_path = report_directory / "created_mod_container_blueprints.json"
    report = {"project": str(project_root), "assets": [], "success": False}
    prepared = []

    def write_report():
        """即使失败也保留实际已完成步骤，避免把部分成功误报为全部成功。"""
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    try:
        # 先完成两项预检，避免同名资产父类不符时仍创建另一个资产。
        for definition in DEFINITIONS:
            expected_parent = generated_class_path(definition["parent_asset_path"])
            parent_class = unreal.load_class(None, expected_parent)
            if parent_class is None:
                raise RuntimeError(
                    "Missing game parent Blueprint: " + expected_parent
                    + ". Run this tool inside the official SDK/current game project."
                )
            entry = dict(definition)
            entry["expected_parent_class"] = expected_parent
            entry["parent_source_sha256_before"] = fingerprint(
                source_file(project_root, definition["parent_asset_path"])
            )
            existing = None
            if unreal.EditorAssetLibrary.does_asset_exist(definition["asset_path"]):
                existing = unreal.load_asset(definition["asset_path"])
                if not isinstance(existing, unreal.Blueprint):
                    raise RuntimeError("The existing target is not a Blueprint: " + definition["asset_path"])
                actual_parent = direct_parent_path(existing, report_directory)
                if actual_parent != expected_parent:
                    raise RuntimeError(
                        "Existing Blueprint has a different direct parent: "
                        + definition["asset_path"] + " -> " + actual_parent
                    )
                entry["existing_source_sha256_before"] = fingerprint(
                    source_file(project_root, definition["asset_path"])
                )
            report["assets"].append(entry)
            prepared.append((definition, parent_class, existing, entry))
        write_report()

        asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
        for definition, parent_class, existing, entry in prepared:
            blueprint = existing
            if blueprint is None:
                package_path, asset_name = definition["asset_path"].rsplit("/", 1)
                factory = unreal.BlueprintFactory()
                factory.set_editor_property("parent_class", parent_class)
                blueprint = asset_tools.create_asset(asset_name, package_path, unreal.Blueprint, factory)
                if blueprint is None:
                    raise RuntimeError("Failed to create " + definition["asset_path"])
                unreal.BlueprintEditorLibrary.compile_blueprint(blueprint)
                cdo = unreal.get_default_object(blueprint.generated_class())
                cdo.set_editor_property("ItemID", unreal.Name(definition["item_id"]))
                if not unreal.EditorAssetLibrary.save_loaded_asset(blueprint, False):
                    raise RuntimeError("Failed to save the new asset " + definition["asset_path"])
                entry["status"] = "created_and_saved"
            else:
                entry["status"] = "existing_verified_unchanged"

            actual_parent = direct_parent_path(blueprint, report_directory)
            if actual_parent != entry["expected_parent_class"]:
                raise RuntimeError("Direct parent verification failed for " + definition["asset_path"])
            generated_class = blueprint.generated_class()
            if not unreal.MathLibrary.class_is_child_of(generated_class, parent_class):
                raise RuntimeError("Generated class inheritance verification failed.")
            cdo = unreal.get_default_object(generated_class)
            entry["object_path"] = blueprint.get_path_name()
            entry["generated_class"] = generated_class.get_path_name()
            entry["actual_parent_class"] = actual_parent
            entry["actual_default_item_id"] = str(cdo.get_editor_property("ItemID"))
            entry["default_item_id_matches_example"] = entry["actual_default_item_id"] == definition["item_id"]
            entry["default_max_capacity"] = cdo.get_editor_property("最大容量")
            entry["default_current_capacity"] = cdo.get_editor_property("容量")
            entry["source_file"] = str(source_file(project_root, definition["asset_path"]))
            entry["parent_source_sha256_after"] = fingerprint(
                source_file(project_root, definition["parent_asset_path"])
            )
            entry["parent_source_unchanged"] = (
                entry["parent_source_sha256_before"] == entry["parent_source_sha256_after"]
            )
            if not entry["parent_source_unchanged"]:
                raise RuntimeError("A parent source file changed during asset creation.")
            if existing is not None:
                entry["existing_source_unchanged"] = (
                    entry["existing_source_sha256_before"]
                    == fingerprint(source_file(project_root, definition["asset_path"]))
                )
                if not entry["existing_source_unchanged"]:
                    raise RuntimeError("An existing target asset changed unexpectedly.")
            write_report()
            unreal.log("MOD_CONTAINER_BLUEPRINT " + entry["status"] + " " + entry["object_path"])

        report["success"] = True
        write_report()
        unreal.log("MOD_CONTAINER_BLUEPRINTS_VERIFIED " + str(report_path))
    except Exception as error:
        report["error"] = str(error)
        write_report()
        raise


if __name__ == "__main__":
    main()

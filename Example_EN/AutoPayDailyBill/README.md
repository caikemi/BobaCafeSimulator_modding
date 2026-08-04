# AutoPayDailyBill (API v3)

[Back to examples](../README.md) | [中文](../../Example_ZH/AutoPayDailyBill/)

On `game.morning_started`, the server reads an economy snapshot and pays affordable Water, Utility, Rent, and Payroll bills in that order. It stores the processed event sequence in private mod storage.

The current entry is `mod.json → v3.lua`. The same folder's `main.lua` is retained only for legacy API v1 game builds; it is not the current example.

Permissions:

- `economy.read`
- `economy.pay-bills`
- `storage.write`

Prerequisite: the host Blueprint emits `game.morning_started` after daily bills finish initialization. Payment is server-authoritative. Tax is currently readable but cannot be paid through the public service.

This is an authoring example. A release mod should document payment order, balance policy, and multiplayer installation requirements.

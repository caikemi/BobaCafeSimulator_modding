# Drink, liquid, ingredient, and icon ID reference

[Back to the English home page](../../README_EN.md) | [中文](../zh/11-id-reference.md)

> This is a snapshot of current game data, not a global mod-ID allocation table. Built-in data may change with game updates; verify against the current build before release. Examples use 5200–5999 for new drinks, but authors must still coordinate collisions.


Each record occupies one line and can be searched by `ID`, `FName`, name, `Color1`, or `Color2`. Log entries with `ID:0` are preserved as recorded.

### Current liquid/drink IDs, names, and colors

Base-liquid `FName` values can be used directly in a recipe's liquid-type fields. A finished drink without a predefined `FName` is shown as `—`.

> `Drink.Honey` is also a valid ingredient-liquid FName for recipes. The current color list does not contain a separate Honey record.

| ID | FName | Name | Color1 | Color2 |
|---:|---|---|---|---|
| 0 | `Drink.Syrup` | Syrup | `R=1 G=0.857 B=0.078 A=1` | `R=1 G=0.907 B=0.143 A=1` |
| 0 | `Drink.PumpkinJuice` | Pumpkin Juice | `R=0.644 G=0.28 B=0 A=1` | `R=0.585 G=0.275 B=0 A=1` |
| 0 | `Drink.HotMilk` | Baked Milk | `R=0.637 G=0.861 B=0.765 A=1` | `R=0.852 G=0.798 B=0.616 A=1` |
| 0 | `Drink.PineappleJuice` | Pineapple Juice | `R=1 G=0.678 B=0 A=1` | `R=1 G=0.887 B=0 A=1` |
| 0 | `Drink.JackfruitJuice` | Jackfruit Juice | `R=1 G=0.816 B=0.233 A=1` | `R=1 G=0.902 B=0.291 A=1` |
| 0 | `Drink.AppleJuice` | Apple Juice | `R=0.9 G=0.599 B=0.245 A=1` | `R=0.8 G=0.506 B=0.194 A=1` |
| 0 | `Drink.PeachJuice` | Peach Juice | `R=1 G=0.321 B=0.465 A=1` | `R=1 G=0.431 B=0.58 A=1` |
| 0 | `Drink.MangoJuice` | Mango Juice | `R=1 G=0.643 B=0 A=1` | `R=1 G=0.539 B=0 A=1` |
| 0 | `Drink.BananaJuice` | Banana Juice | `R=1 G=0.871 B=0 A=1` | `R=1 G=0.792 B=0 A=1` |
| 0 | `Drink.StrawberryJuice` | Strawberry Juice | `R=1 G=0.168 B=0.258 A=1` | `R=1 G=0.161 B=0.193 A=1` |
| 0 | `Drink.PomegranateJuice` | Pomegranate Juice | `R=0.8 G=0.074 B=0.092 A=1` | `R=0.599 G=0.066 B=0.066 A=1` |
| 0 | `Drink.CoconutMilk` | Coconut Milk | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 0 | `Drink.FruitJelly` | Fruit Jelly Juice | `R=0.021 G=0.9 B=0.032 A=1` | `R=0.198 G=1 B=0.061 A=1` |
| 0 | `Drink.MagmaJelly` | Magma Jelly Juice | `R=1 G=0.11 B=0.453 A=1` | `R=1 G=0.102 B=0.202 A=1` |
| 0 | `Drink.GhostWater` | Ghost Water | `R=0.8 G=0.9 B=1 A=0.5` | `R=0.7 G=0.95 B=1 A=1` |
| 0 | `Drink.RustyIronWater` | Rusty Iron Water | `R=0.5 G=0.205 B=0.153 A=0.7` | `R=0.432 G=0.275 B=0.17 A=1` |
| 0 | `Drink.HotWater` | Hot Water | `R=0.382 G=0.965 B=1 A=1` | `R=0.622 G=0.866 B=0.96 A=1` |
| 0 | `Drink.PureWater` | Purified Water | `R=0.311 G=0.848 B=1 A=1` | `R=0.624 G=0.863 B=0.956 A=1` |
| 0 | `Drink.SashimiGreenTea` | Sashimi Green Tea | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 0 | `Drink.Yogurt` | Yogurt | `R=0.95 G=0.95 B=0.716 A=1` | `R=1 G=1 B=0.859 A=1` |
| 5001 | — | Lemon Water | `R=1 G=0.604 B=0.049 A=1` | `R=1 G=0.604 B=0.049 A=1` |
| 5002 | `Drink.WatermelonJuice` | Watermelon Juice | `R=0.672 G=0.08 B=0.071 A=1` | `R=0.672 G=0.064 B=0.055 A=1` |
| 5003 | — | Smashed Fresh Orange | `R=0.991 G=0.391 B=0.047 A=1` | `R=0.964 G=0.391 B=0.094 A=1` |
| 5006 | `Drink.SqueezeOrangeJuice` | Fresh-Squeezed Orange Juice | `R=1 G=0.261 B=0 A=1` | `R=1 G=0.226 B=0 A=1` |
| 5005 | `Drink.Milk` | Milk | `R=1 G=0.967 B=0.905 A=1` | `R=1 G=0.972 B=0.918 A=1` |
| 5007 | `Drink.GreenTea` | Green Tea | `R=0.223 G=0.297 B=0.086 A=1` | `R=0.234 G=0.31 B=0.095 A=1` |
| 5014 | `Drink.Coffee` | Hot Coffee | `R=0.05 G=0.014 B=0.004 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5032 | `Drink.MilkTea` | Milk Tea | `R=0.356 G=0.212 B=0.09 A=1` | `R=0.373 G=0.191 B=0.037 A=1` |
| 5008 | — | Lemon Green Tea | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 5009 | — | Watermelon Iced Tea | `R=0.701 G=0.286 B=0.196 A=1` | `R=0.701 G=0.296 B=0.216 A=1` |
| 5011 | — | Watermelon Fruit Milk | `R=1 G=0.422 B=0.246 A=1` | `R=1 G=0.455 B=0.27 A=1` |
| 5013 | — | Orange Lemon | `R=1 G=0.836 B=0.155 A=1` | `R=1 G=0.63 B=0.097 A=1` |
| 5015 | — | Pumpkin Tea | `R=0.401 G=0.21 B=0.059 A=1` | `R=0.46 G=0.242 B=0.015 A=1` |
| 5016 | — | Pumpkin Milk | `R=0.661 G=0.504 B=0.24 A=1` | `R=0.627 G=0.395 B=0.179 A=1` |
| 5019 | — | Taro Ball Milk Tea | `R=0.453 G=0.265 B=0.321 A=1` | `R=0.353 G=0.266 B=0.411 A=1` |
| 5020 | — | Jasmine Milk Green Tea | `R=0.695 G=0.7 B=0.303 A=1` | `R=0.779 G=0.95 B=0.437 A=1` |
| 5021 | — | Taro Paste Milk Tea | `R=0.516 G=0.397 B=0.595 A=1` | `R=0.76 G=0.574 B=0.365 A=1` |
| 5022 | — | Taro Paste Boba | `R=0.576 G=0.454 B=0.658 A=1` | `R=0.658 G=0.378 B=0.44 A=1` |
| 5023 | — | Pudding Milk Tea | `R=0.668 G=0.475 B=0.256 A=1` | `R=0.714 G=0.615 B=0.172 A=1` |
| 5024 | — | Ao-Ao Milk Tea | `R=0.484 G=0.34 B=0.177 A=1` | `R=0.391 G=0.318 B=0.276 A=1` |
| 5025 | — | Red Bean Milk Tea | `R=0.717 G=0.411 B=0.214 A=1` | `R=0.568 G=0.338 B=0.338 A=1` |
| 5026 | — | Red Bean Milk Pudding | `R=0.716 G=0.381 B=0.16 A=1` | `R=0.565 G=0.337 B=0.337 A=1` |
| 5027 | — | Double-Topping Milk Tea | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.371 G=0.191 B=0.037 A=1` |
| 5028 | — | Coconut Jelly Milk Tea | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.9 G=0.9 B=0.95 A=1` |
| 5029 | — | Supreme Triple-Topping Milk Tea | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.1 G=0.1 B=0.1 A=1` |
| 5030 | — | Cheese-Foam Milk Tea | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.98 B=0.9 A=1` |
| 5031 | — | Ao-Ao Cheese Milk Tea | `R=0.761 G=0.597 B=0.418 A=1` | `R=0.543 G=0.405 B=0.358 A=1` |
| 5033 | — | Red Date and Longan Warm Milk Tea | `R=0.6 G=0.239 B=0.149 A=1` | `R=0.741 G=0.567 B=0.218 A=1` |
| 5034 | — | Brown Sugar Boba Milk Tea | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.523 G=0.327 B=0.21 A=1` |
| 5035 | — | Baked-Milk Tea | `R=1 G=0.965 B=0.905 A=1` | `R=0.685 G=0.95 B=0.662 A=1` |
| 5036 | — | Watermelon Boba | `R=1 G=0.3 B=0.35 A=1` | `R=1 G=0.9 B=0.9 A=1` |
| 5037 | — | Taro Ball Grape | `R=0.45 G=0.25 B=0.55 A=1` | `R=0.65 G=0.5 B=0.75 A=1` |
| 5038 | — | Full-Cup Passion Fruit | `R=0.9 G=0.8 B=0.2 A=1` | `R=0.429 G=0.502 B=0.283 A=1` |
| 5039 | — | Pineapple Jackfruit | `R=0.95 G=0.9 B=0.1 A=1` | `R=1 G=0.8 B=0.2 A=1` |
| 5040 | — | Apple Peach | `R=1 G=0.7 B=0.75 A=1` | `R=0.9 G=0.8 B=0.4 A=1` |
| 5041 | — | Peach Mango | `R=0.97 G=0.726 B=0.767 A=1` | `R=1 G=0.82 B=0.387 A=1` |
| 5042 | — | Blueberry Fruit Tea | `R=0.259 G=0.233 B=0.5 A=1` | `R=0.285 G=0.215 B=0.4 A=1` |
| 5043 | — | Peach Nectar | `R=1 G=0.623 B=0.686 A=1` | `R=0.981 G=1 B=0.634 A=1` |
| 5044 | — | Peach Green Tea | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.7 B=0.75 A=1` |
| 5045 | — | Passion Fruit Pineapple | `R=1 G=0.768 B=0.21 A=1` | `R=0.794 G=0.964 B=0.775 A=1` |
| 5046 | — | Jasmine Green Grape | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5047 | — | Mint Green Tea | `R=0.2 G=0.8 B=0.5 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5048 | — | Pomegranate Juice | `R=0.8 G=0.1 B=0.15 A=1` | `R=0.9 G=0.2 B=0.25 A=1` |
| 5049 | — | Grape Jelly | `R=0.45 G=0.25 B=0.55 A=1` | `R=1 G=0.7 B=0.98 A=0.5` |
| 5050 | — | Fresh Mango Passion Fruit | `R=1 G=0.783 B=0.262 A=1` | `R=0.915 G=0.965 B=0.571 A=1` |
| 5051 | — | Green Plum Iced Tea | `R=0.5 G=0.6 B=0.2 A=1` | `R=0.8 G=0.7 B=0.4 A=1` |
| 5052 | — | Sunshine Green Grape | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.9 G=0.95 B=0.8 A=1` |
| 5053 | — | Super Fruit Tea | `R=0.9 G=0.5 B=0.2 A=1` | `R=0.8 G=0.9 B=0.2 A=1` |
| 5054 | — | Honey Pomelo Tea | `R=0.95 G=0.7 B=0.1 A=1` | `R=1 G=0.882 B=0.29 A=1` |
| 5055 | — | Latte | `R=0.35 G=0.2 B=0.1 A=1` | `R=0.398 G=0.272 B=0.187 A=1` |
| 5056 | — | Coconut Latte | `R=0.429 G=0.264 B=0.153 A=1` | `R=0.397 G=0.286 B=0.213 A=1` |
| 5057 | — | Grape Americano | `R=0.061 G=0.013 B=0.025 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5058 | — | Jasmine Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.499 G=0.582 B=0.332 A=1` |
| 5059 | — | Apple Latte | `R=0.397 G=0.285 B=0.211 A=1` | `R=0.967 G=0.588 B=0.505 A=1` |
| 5060 | — | Orange Americano | `R=0.151 G=0.073 B=0.037 A=1` | `R=0.148 G=0.084 B=0.021 A=1` |
| 5061 | — | Butter Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.509 G=0.446 B=0.227 A=1` |
| 5062 | — | Peach Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.564 G=0.395 B=0.423 A=1` |
| 5063 | — | Mango Milk | `R=1 G=0.767 B=0.207 A=1` | `R=0.832 G=0.832 B=0.576 A=1` |
| 5064 | — | Coconut Mango Pomelo Sago | `R=1 G=0.735 B=0.099 A=1` | `R=0.95 G=0.95 B=0.602 A=1` |
| 5065 | — | Mango Pomelo Sago | `R=1 G=0.738 B=0.1 A=1` | `R=0.947 G=0.947 B=0.386 A=1` |
| 5066 | — | Peach Gum Milk | `R=0.95 G=0.95 B=0.572 A=1` | `R=0.88 G=0.668 B=0.243 A=1` |
| 5067 | — | Watermelon Coconut | `R=1 G=0.3 B=0.35 A=1` | `R=0.95 G=0.95 B=0.744 A=1` |
| 5068 | — | Coconut Lemon Milk | `R=0.95 G=0.95 B=0.562 A=1` | `R=0.95 G=0.898 B=0.173 A=1` |
| 5069 | — | Taro Ball Coconut | `R=0.95 G=0.95 B=0.92 A=1` | `R=0.658 G=0.52 B=0.75 A=1` |
| 5070 | — | Mango Sago | `R=1 G=0.75 B=0.15 A=1` | `R=1 G=0.845 B=0.509 A=1` |
| 5071 | — | Avocado Sago | `R=0.56 G=0.75 B=0.306 A=1` | `R=0.985 G=1 B=0.634 A=1` |
| 5072 | — | Brown Sugar Boba Milk Tea | `R=0.762 G=0.428 B=0.263 A=1` | `R=0.55 G=0.304 B=0.181 A=1` |
| 5073 | — | Glowing Lemon Water | `R=0.867 G=1 B=0.172 A=1` | `R=0.675 G=1 B=0.178 A=1` |
| 5074 | — | Mandrake Green Tea | `R=0.066 G=0.65 B=0.155 A=1` | `R=0.245 G=0.6 B=0.191 A=1` |
| 5075 | — | Magma Watermelon Tentacles | `R=0.95 G=0 B=0.012 A=1` | `R=1 G=0.278 B=0.12 A=1` |
| 5076 | — | Glowing Mandrake Lemon | `R=0.153 G=1 B=0.118 A=1` | `R=0.472 G=0.8 B=0.038 A=1` |
| 5077 | — | Ghost Baked Milk | `R=0.8 G=0.723 B=0.517 A=1` | `R=0.439 G=0.907 B=1 A=1` |
| 5078 | — | Rust Green Tea | `R=0.14 G=0.5 B=0.151 A=1` | `R=0.439 G=0.22 B=0.073 A=1` |
| 5079 | — | Ghost Mandrake | `R=0.582 G=1 B=0.835 A=1` | `R=0.109 G=0.5 B=0.123 A=1` |
| 5080 | — | Rusty Peach | `R=0.832 G=0.443 B=0.443 A=1` | `R=0.432 G=0.21 B=0.062 A=1` |
| 5081 | — | Ghost Mango | `R=1 G=0.633 B=0.119 A=1` | `R=0.345 G=0.891 B=1 A=1` |
| 5082 | — | Dried-Bat Americano | `R=0.273 G=0.151 B=0.076 A=1` | `R=0.047 G=0.047 B=0.047 A=1` |
| 5083 | — | Abyss Green Tea | `R=0.408 G=0.65 B=0.166 A=1` | `R=0.7 G=0.442 B=0.425 A=1` |
| 5084 | — | Will-o'-the-Wisp Baked Milk | `R=1 G=0.892 B=0.664 A=1` | `R=1 G=0.068 B=0.064 A=1` |
| 5085 | — | Spider Cave Ghost Water | `R=0.394 G=0.85 B=0.787 A=1` | `R=0.154 G=1 B=0.323 A=1` |
| 5086 | — | Cthulhu Tentacle Cup | `R=0.1 G=0.3 B=0.25 A=1` | `R=0.6 G=0 B=0.8 A=1` |
| 5087 | — | Spider Cave Grape Tea | `R=0.343 G=0.074 B=0.45 A=1` | `R=0.418 G=0.9 B=0.489 A=1` |
| 5088 | — | Bat Coconut | `R=0.61 G=1 B=0.911 A=1` | `R=0.095 G=0.06 B=0.025 A=1` |
| 5089 | — | Ghost Milk with Taro Balls | `R=0.622 G=0.471 B=0.85 A=1` | `R=0.366 G=0.951 B=1 A=1` |
| 5090 | — | Ice and Fire Duet | `R=0 G=0.543 B=1 A=1` | `R=1 G=0.005 B=0 A=1` |
| 5091 | — | Mandrake Mutant Watermelon Juice | `R=0.8 G=0.2 B=0.4 A=1` | `R=0.48 G=1 B=0.415 A=1` |
| 5092 | — | Dirty Mushroom Tea | `R=0.227 G=0.096 B=0.04 A=1` | `R=0.5 G=0.316 B=0.171 A=1` |
| 5093 | — | Jelly Slime Baked Milk | `R=0 G=1 B=0.031 A=1` | `R=0.219 G=0.9 B=0.347 A=1` |
| 5094 | — | Toxic Swamp Lemon Water | `R=0.863 G=1 B=0.108 A=1` | `R=0.887 G=0.402 B=1 A=1` |
| 5095 | — | Gaze of the Abyss | `R=0.5 G=0 B=1 A=1` | `R=0.98 G=0.127 B=1 A=1` |
| 5096 | — | Magma Lava Drink | `R=1 G=0.003 B=0 A=1` | `R=0.1 G=0.021 B=0 A=1` |
| 5097 | — | Bat Latte | `R=0.373 G=0.267 B=0.183 A=1` | `R=0.18 G=0.1 B=0.05 A=1` |
| 5098 | — | Dark Spore Latte | `R=0.175 G=0.112 B=0.081 A=1` | `R=0.447 G=0.162 B=0.7 A=1` |
| 5099 | — | Bat Wasteland Milk Tea | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5100 | — | Swamp Jelly | `R=0.2 G=0.3 B=0.2 A=1` | `R=0.2 G=1 B=0.1 A=1` |
| 5101 | — | Infernal Bitter Water | `R=0 G=0 B=0 A=1` | `R=1 G=0.3 B=0 A=1` |
| 5102 | — | Hallucinogenic Mushroom Milk | `R=0.8 G=0.4 B=0.8 A=1` | `R=0 G=0.5 B=1 A=1` |
| 5103 | — | Abyssal Trap Honey Brew | `R=0.079 G=0 B=0.1 A=1` | `R=0.926 G=1 B=0 A=1` |
| 5104 | — | Void Black Hole | `R=0 G=0.017 B=1 A=1` | `R=0.007 G=0 B=0.5 A=1` |
| 5105 | — | Galactic Stardust Dew | `R=0 G=0.471 B=1 A=1` | `R=0.309 G=0 B=1 A=1` |
| 5106 | — | Philosopher's Stone Special | `R=0.7 G=0.138 B=0.001 A=1` | `R=0.546 G=1 B=0 A=1` |
| 5108 | `Drink.CherryJuice` | Premium Cherry Juice | `R=0.7 G=0.1 B=0.15 A=1` | `R=0.7 G=0.1 B=0.15 A=1` |
| 5107 | — | Ruby Orange Juice | `R=0.95 G=0.35 B=0.1 A=1` | `R=1 G=0.6 B=0.05 A=1` |
| 5109 | — | Lucky Red Milk | `R=0.92 G=0.75 B=0.8 A=1` | `R=0.96 G=0.96 B=0.92 A=1` |
| 5110 | — | Candied Hawthorn Americano | `R=0.18 G=0.1 B=0.05 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5111 | — | Firecracker Milk Tea | `R=0.65 G=0.75 B=0.55 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5112 | — | Explosive Red Cherry | `R=0.7 G=0.05 B=0.15 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5113 | — | Explosive Candied Hawthorn | `R=0.7 G=0.05 B=0.15 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5114 | — | Banana Milk | `R=0.982 G=0.807 B=0.371 A=1` | `R=0.982 G=0.807 B=0.371 A=1` |
| 5115 | — | Strawberry Milk | `R=0.991 G=0.479 B=0.474 A=1` | `R=0.991 G=0.815 B=0.753 A=1` |
| 5116 | — | Mint Chocolate Latte | `R=0.558 G=0.397 B=0.216 A=1` | `R=0.716 G=0.839 B=0.658 A=1` |
| 5117 | — | Apple Jasmine | `R=0.839 G=0.839 B=0.515 A=1` | `R=0.839 G=0.831 B=0.509 A=1` |
| 5118 | — | Banana Latte | `R=0.88 G=0.571 B=0.216 A=1` | `R=0.982 G=0.839 B=0.558 A=1` |
| 5119 | — | Banana Green Tea | `R=0.597 G=0.624 B=0.153 A=1` | `R=0.839 G=0.839 B=0.434 A=1` |
| 5120 | — | Super Yogurt Bowl | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5121 | — | Strawberry Yogurt | `R=0.982 G=0.672 B=0.651 A=1` | `R=0.973 G=0.905 B=0.847 A=1` |
| 5122 | — | Banana Yogurt | `R=0.991 G=0.913 B=0.651 A=1` | `R=0.991 G=0.913 B=0.651 A=1` |
| 5123 | — | Mint Milk Green Tea | `R=0.223 G=0.497 B=0.086 A=1` | `R=0.552 G=0.694 B=0.301 A=1` |
| 5124 | — | Jasmine Green Tea | `R=0.73 G=0.768 B=0.258 A=1` | `R=0.738 G=0.784 B=0.275 A=1` |
| 5125 | — | Red Apple Milk Green Tea | `R=0.665 G=0.745 B=0.279 A=1` | `R=0.88 G=0.896 B=0.701 A=1` |
| 5126 | — | Apple Milk | `R=0.991 G=0.871 B=0.565 A=1` | `R=0.991 G=0.905 B=0.658 A=1` |

### Current topping IDs

```text
1102 Lemon Slice
1103 Orange Slice
1105 Purified Water Tool
1106 Juicer Tool
1107 Boba
1108 Receipt
7001 Taro Ball
7002 Jasmine Jam
7003 Taro Paste
7004 Popping Boba
7005 Pudding
7006 Ao-Ao
7007 Peach Gum
7008 Purple Rice
7009 Diced Mango
7010 Diced Avocado
7011 Diced Peach
7012 Diced Pineapple
7013 Blueberry
7014 Butter
7015 Red Bean
7016 Brown Sugar
7017 Jelly
7018 Pomelo Pulp
7019 Green Plum
7020 Honey
7021 Passion Fruit
7022 Cheese Foam
7023 Dried Red Date
7024 Dried Longan
7025 Coconut Jelly
7026 Peeled Green Grape
7027 Peeled Grape
7028 Mint
7029 Sago
7030 Glowing Lemon Slice
7031 Graveyard Mushroom
7032 Dried Bat
7033 Mandrake Slice
7034 Spider Silk
7035 Eye of the Abyss
7036 Magma Tentacle Slice
7037 Philosopher's Stone
7038 Will-o'-the-Wisp
7039 Star Prism
7040 Jelly Slime
7041 Magma Jelly Slime
7042 Ghost Water
7043 Rusty Iron Water
7044 Firecracker
7045 Candied Hawthorn
7046 Cupid Syrup
7047 Taste-Amnesia Powder
7048 Perfect-Filter Flavoring
7049 Sashimi
7050 Skeleton Fishbone Powder
```

### Tutorial icon IDs

Use these values with `drink.TutorialItemIds:Add(ID)`.

```text
1004 Watermelon
1005 Orange
1007 Milk
1008 Green Tea
1010 Cooking Pot
1012 Juicer
1028 Grinder
1029 Coffee Beans
1030 Coffee Brewer
1033 Pumpkin
1036 Apple
1040 Peach
1045 Strawberry
1047 Pineapple
1054 Banana
1092 Jackfruit
1093 Mango
1094 Pomegranate
1105 Purified Water Tool
1106 Juicer Tool
1116 Coconut Milk
1142 Centrifuge
1143 Premium 8J Cherry
1175 Yogurt Maker
3033 Infusion Device
```

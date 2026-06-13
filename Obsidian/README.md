# Galax Obsidian Library Assets

This folder is the source layout for assets and themes that can be published to the `WhyMayko/Matcha-Scripts` GitHub repository and loaded remotely by the Matcha Drawing UI.

## Folders

- `themes/default`: official built-in themes, stored as JSON files.
- `themes/user`: user-created or published custom themes, stored as JSON files.
- `assets/icons`: real PNG icons copied from Obsidian when available.
- `assets/textures`: small reusable textures, such as `TransparencyTexture.png` and `SaturationMap.png`.
- `assets/logos`: configurable logo images, such as `mspaint.png`.
- `data`: lightweight JSON datasets that should stay outside the runtime library, such as `keybinds.json`.

## Theme JSON

Expected format:

```json
{
  "Background": "0D0D0D",
  "Main": "191919",
  "Accent": "7D55FF",
  "Outline": "282828",
  "Text": "FFFFFF",
  "FontFace": "Monospace"
}
```

`FontFace` must use a Matcha-supported Drawing font:

```text
UI
System
SystemBold
Minecraft
Monospace
Pixel
Fortnite
```

## Raw URLs

Use this GitHub raw URL format:

```text
https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Library/Obsidian/assets/textures/TransparencyTexture.png
https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Library/Obsidian/themes/default/Default.json
https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Library/Obsidian/assets/icons/check.png
https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Library/Obsidian/data/keybinds.json
```

# Galax Obsidian Library Assets

Estrutura para subir no seu GitHub e usar como fonte remota da UI.

## Pastas

- `themes/default`: temas oficiais/default da lib, todos em JSON.
- `themes/user`: temas customizados que voce quiser publicar, todos em JSON.
- `assets/icons`: icones PNG reais copiados da Obsidian quando existirem.
- `assets/textures`: texturas pequenas como `TransparencyTexture.png` e `SaturationMap.png`.
- `assets/logos`: logos configuraveis, como `mspaint.png`.

## Tema JSON

Formato esperado:

```json
{
  "Background": "0D0D0D",
  "Main": "191919",
  "Accent": "7D55FF",
  "Outline": "282828",
  "Text": "FFFFFF",
  "FontFace": "Code"
}
```

## URLs

Quando subir no GitHub, use URLs raw nesse formato:

```text
https://raw.githubusercontent.com/USUARIO/REPO/refs/heads/main/Library/Obsidian/assets/textures/TransparencyTexture.png
https://raw.githubusercontent.com/USUARIO/REPO/refs/heads/main/Projects/Galax%20-%20Obsidian/Library/Obsidian/themes/default/Default.json
```

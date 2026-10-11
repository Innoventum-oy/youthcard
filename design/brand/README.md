# Youth Card fresh brand

The SVG files here are the editable source artwork supplied in the Nuorisokortti `fresh-concept` folder. The app uses matching PNG files in `images/brand/`.

| Role | Color |
| --- | --- |
| Mint | `#5DE2C1` |
| Navy | `#17313D` |
| Teal | `#087F77` |
| Coral | `#FF705E` |

`app-icon-opaque.png` is the same icon with its unused alpha channel removed for the iOS App Store icon. Regenerate platform assets after changing the brand artwork:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The Figma file contains matching light and dark screens and theme variables: https://www.figma.com/design/Qc215zClE0kqncDGYxF84I

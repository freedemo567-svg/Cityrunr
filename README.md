<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:2c5caf5c9f4ea1d15fd4fab494a4855082083770ba96ab28cb08928676c2b6a3 -->

# City Run 3D

The current game is in [city3d/](city3d/README.md). Open that folder in Godot 4.3 Standard or VS Code. It contains the latest vehicle rendering, building facades, character selection, on-foot exploration and Kerala geographic drive.

## Project files

- [Game source and asset credits](city3d/README.md)
- [Malayalam setup and Android build guide](city3d/BUILD_GUIDE_ML.md)
- [Godot project](city3d/project.godot)
- [Run, test and build commands](city3d/tools/project.mjs)

Kerala map data is included under `city3d/assets/kerala/tiles/`; no separate data ZIP is required for this checkout. Keep the complete `city3d` folder, including assets, licence files, tools and tests.

## Run

Set `GODOT_BIN` to a Godot 4.3 Standard executable. From the repository root:

```sh
"$GODOT_BIN" --headless --path city3d --editor --import
node city3d/tools/project.mjs run
```

For Android export, follow the Malayalam guide. The current export uses Godot's Android preset and produces `city3d/build/city-run-3d.apk`.

The game remains a prototype with flat geographic terrain and illustrative scenery. Phone performance, touch and audible audio need device verification.

<!-- /coderabbit-ai-generated:v1 -->
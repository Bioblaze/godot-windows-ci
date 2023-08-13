# godot-windows-ci

`godot-windows-ci` is a Dockerized Continuous Integration environment for Godot game development on Windows. This repository is managed by the user `bioblaze` and is automatically pushed to the Docker registry upon every push to the main branch.

## Features

- **Godot Client:** Accessible via `%GODOT_HOME%/godot.exe`.
- **RC Edit Tool:** Accessible via `%RCEDIT_HOME%/rcedit.exe`.
- **SignTool:** Accessible via `%SIGNTOOL_HOME%/signtool.exe`.
- **Butler for itch.io:** Accessible via `%BUTLER_HOME%/butler.exe`.
- **Image Conversion Script (`create_ico.ps1`):** A PowerShell script to convert PNG images to ICO. Located in `%GODOT_TOOLS%`.

## Usage

### Running Godot

To run the Godot client, execute:

```shell
%GODOT_HOME%/godot.exe
```

### Running RC Edit

To run the RC Edit tool, execute:

```shell
%RCEDIT_HOME%/rcedit.exe
```

### Running SignTool

To run SignTool, execute:

```shell
%SIGNTOOL_HOME%/signtool.exe
```

### Running Butler

To run Butler for itch.io, execute:

```shell
%BUTLER_HOME%/butler.exe
```

### Converting PNG to ICO with `create_ico.ps1`

To convert a PNG file to ICO using the included script, execute:

```powershell
%GODOT_TOOLS%/create_ico.ps1 -Path path/to/your_image.png
```

## Contributing

If you have any questions or need support, feel free to open an issue or contact `bioblaze`. Contributions and feedback are welcome!

## License

Please see the [LICENSE](LICENSE) file for details on licensing.
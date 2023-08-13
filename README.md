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

### Additional Tools

## create_ico.ps1

`create_ico.ps1` is a PowerShell script that converts a given PNG image into an ICO file with multiple sizes. It's useful for generating icons for your Windows applications.

### Requirements

- **ImageMagick**: This script requires ImageMagick to be installed on your system.

### Usage

You can run `create_ico.ps1` by providing the path to the PNG file and the export folder as follows:

```powershell
create_ico.ps1 -icon_png path/to/your_image.png -export_folder path/to/export/folder
```

### Parameters

- **icon_png** (Mandatory): Path to the PNG file you want to convert to an ICO file.
- **export_folder** (Mandatory): Path to the folder where you want to save the exported ICO file.

### Example

```powershell
create_ico.ps1 -icon_png C:/images/my_icon.png -export_folder C:/exports
```

This command will convert `my_icon.png` into an ICO file and save it in the `C:/exports` folder with various sizes (256, 128, 64, 48, 32, 16).

### Troubleshooting

- If you encounter an error message stating that ImageMagick is not found, please make sure ImageMagick is properly installed.
- If the specified PNG file or export folder doesn't exist, you'll receive a warning message.

### Output

Upon successful execution, the script will inform you that the icon has been successfully created and provide the path to the new ICO file.

---

## Contributing

If you have any questions or need support, feel free to open an issue or contact `bioblaze`. Contributions and feedback are welcome!

## License

Please see the [LICENSE](LICENSE) file for details on licensing.

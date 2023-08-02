# Save as create_ico.ps1

param(
    [Parameter(Mandatory=$true)] [string]$icon_png,
    [Parameter(Mandatory=$true)] [string]$export_folder
)

# Check if ImageMagick is installed
if (-not (Get-Command 'magick' -ErrorAction SilentlyContinue)) {
    Write-Host "ImageMagick is not found. Please install ImageMagick first."
    exit
}

# Check if the provided png file exists
if (-not (Test-Path -Path $icon_png)) {
    Write-Host "The file $icon_png does not exist."
    exit
}

# Check if the provided export folder exists
if (-not (Test-Path -Path $export_folder)) {
    Write-Host "The folder $export_folder does not exist."
    exit
}

# Define the output ico file path
$output_ico = Join-Path $export_folder "icon.ico"

# Use ImageMagick to convert the png to ico with multiple sizes
magick convert $icon_png -define icon:auto-resize=256,128,64,48,32,16 $output_ico

Write-Host "Icon has been successfully created at $output_ico"

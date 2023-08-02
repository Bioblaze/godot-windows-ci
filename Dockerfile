# Use Microsoft's Windows Server Core image as the base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variable for Godot
ENV GODOT_VERSION="4.1.1"
ENV RELEASE_NAME="stable"
ENV SUBDIR=""
ENV GODOT_TEST_ARGS=""
ENV GODOT_PLATFORM="win64"
ENV GODOT_HOME="C:/godot"
ENV GODOT_TOOLS="C:/godot_tools"
ENV RCEDIT_HOME="C:/rcedit"
ENV SIGNTOOL_HOME="C:/signtool"
ENV BUTLER_HOME="C:/butler"

# Print environment variables
RUN echo GODOT_HOME="%GODOT_HOME%" GODOT_TOOLS="%GODOT_TOOLS%" RCEDIT_HOME="%RCEDIT_HOME%" SIGNTOOL_HOME="%SIGNTOOL_HOME%" BUTLER_HOME="%BUTLER_HOME%"


# Create required directories if they were not created
RUN powershell New-Item -Path %GODOT_HOME% -ItemType Directory -Force
RUN powershell New-Item -Path %GODOT_TOOLS% -ItemType Directory -Force
RUN powershell New-Item -Path %RCEDIT_HOME% -ItemType Directory -Force
RUN powershell New-Item -Path %SIGNTOOL_HOME% -ItemType Directory -Force
RUN powershell New-Item -Path %BUTLER_HOME% -ItemType Directory -Force

# Print URL for Godot
RUN echo https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%%SUBDIR%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.zip

# Download Godot Engine
RUN powershell Invoke-WebRequest -Uri "https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%%SUBDIR%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.zip" -OutFile godot.zip
RUN powershell Expand-Archive -Path .\godot.zip -DestinationPath %GODOT_HOME% \
    && powershell Rename-Item -Path "%GODOT_HOME%\Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.exe" -NewName "%GODOT_HOME%\godot.exe" \
    && powershell New-Item -Path %GODOT_HOME% -Name ._sc_ -ItemType "file" -Force

# Run Godot engine with arguments
RUN %GODOT_HOME%\godot.exe -v -e --quit --headless

# Create required directories if they were not created NOTE: If they weren't something is wrong....
RUN powershell New-Item -Path "%GODOT_HOME%/editor_data" -ItemType Directory -Force
RUN powershell New-Item -Path "%GODOT_HOME%/editor_data/export_templates" -ItemType Directory -Force

# Download and install export templates
RUN powershell Invoke-WebRequest -Uri "https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_export_templates.tpz" -OutFile export-templates.tpz
RUN powershell Expand-Archive -Path .\export-templates.tpz -DestinationPath "%GODOT_HOME%\editor_data\export_templates\%GODOT_VERSION%.stable"

# Install ImageMagick via Chocolatey
RUN choco install -y imagemagick

# Copy 'tools' directory to the image
COPY tools/ %GODOT_TOOLS%/

# Set 'tools' directory in the PATH
RUN setx /M PATH "%PATH%;%GODOT_TOOLS%"

# Download and install rcedit
RUN powershell Invoke-WebRequest -Uri "https://github.com/electron/rcedit/releases/download/v1.1.1/rcedit-x64.exe" -OutFile %RCEDIT_HOME%/rcedit.exe

# Set rcedit to path
RUN setx /M PATH "%PATH%;%RCEDIT_HOME%"

# Copy signtool from Windows Kits to signtool directory
RUN powershell Copy-Item "C:/Program Files (x86)/Windows Kits/10/bin/10.0.22621.0/x64/signtool.exe" -Destination %SIGNTOOL_HOME%

# Set signtool to path
RUN setx /M PATH "%PATH%;%SIGNTOOL_HOME%"

# Download and install butler
RUN powershell Invoke-WebRequest -Uri "https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default" -OutFile %BUTLER_HOME%/butler.zip
RUN powershell Expand-Archive -Path %BUTLER_HOME%/butler.zip -DestinationPath %BUTLER_HOME%

# Set butler to path
RUN setx /M PATH "%PATH%;%BUTLER_HOME%"

# Verify butler and rcedit installation
RUN powershell -Command "& {%BUTLER_HOME%/butler.exe -V; %RCEDIT_HOME%/rcedit.exe -h;}"

# Set butler to path
RUN setx /M PATH "%PATH%;%ANDROID_HOME%/cmdline-tools/cmdline-tools/bin"

# Create an Android debug keystore
RUN "%ANDROID_HOME%/cmdline-tools/cmdline-tools/bin/keytool.exe" -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999

# Move debug.keystore to GODOT_HOME
RUN powershell Move-Item -Path .\debug.keystore -Destination "%GODOT_HOME%\debug.keystore"

# Append editor settings
RUN echo 'export/windows/rcedit = "%RCEDIT_HOME%"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/windows/signtool = "%SIGNTOOL_HOME%"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/android/android_sdk_path = "${ANDROID_SDK_ROOT}"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/android/shutdown_adb_on_exit = true' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/android/timestamping_authority_url = ""' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'xport/android/debug_keystore = "%GODOT_HOME%\debug.keystore"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres

# Remove downloaded files
RUN powershell Remove-Item -Path %BUTLER_HOME%/butler.zip
RUN powershell Remove-Item -Path .\godot.zip
RUN powershell Remove-Item -Path .\export-templates.tpz

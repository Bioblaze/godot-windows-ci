# Use Microsoft's Windows Server Core image as the base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Define arguments
ARG GODOT_VERSION="4.1.1"
ARG RELEASE_NAME="stable"
ARG GODOT_PLATFORM="win64"

# Set environment variable for Godot
ENV GODOT_VERSION=${GODOT_VERSION}
ENV RELEASE_NAME=${RELEASE_NAME}
ENV GODOT_PLATFORM=${GODOT_PLATFORM}
ENV GODOT_TEST_ARGS=""
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
RUN echo https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.exe.zip

# Download Godot Engine
RUN powershell Invoke-WebRequest -Uri "https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.exe.zip" -OutFile godot.zip
RUN powershell Expand-Archive -Path .\godot.zip -DestinationPath %GODOT_HOME% \
    && powershell Rename-Item -Path "%GODOT_HOME%\Godot_v%GODOT_VERSION%-%RELEASE_NAME%_%GODOT_PLATFORM%.exe" -NewName "%GODOT_HOME%\godot.exe" \
    && powershell New-Item -Path %GODOT_HOME% -Name ._sc_ -ItemType "file" -Force

# Run Godot engine with arguments
RUN powershell %GODOT_HOME%\godot.exe -v -e --quit --headless

# Create required directories if they were not created NOTE: If they weren't something is wrong....
RUN powershell New-Item -Path "%GODOT_HOME%/editor_data" -ItemType Directory -Force
RUN powershell New-Item -Path "%GODOT_HOME%/editor_data/export_templates" -ItemType Directory -Force

# Download and install export templates
RUN powershell Invoke-WebRequest -Uri "https://downloads.tuxfamily.org/godotengine/%GODOT_VERSION%/Godot_v%GODOT_VERSION%-%RELEASE_NAME%_export_templates.tpz" -OutFile export-templates.tpz

# Install Chocolatey and packages
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" \
    && choco install -y 7zip

# Extract export templates with 7-Zip
RUN powershell -command "& {&'%ProgramFiles%\7-Zip\7z.exe' e .\export-templates.tpz -o%GODOT_HOME%\editor_data\export_templates\%GODOT_VERSION%.%RELEASE_NAME%}"

# Copy 'tools' directory to the image
COPY tools/ %GODOT_TOOLS%/

# Set 'tools' directory in the PATH
RUN setx /M PATH "%PATH%;%GODOT_TOOLS%"

# Download and install rcedit
RUN powershell Invoke-WebRequest -Uri "https://github.com/electron/rcedit/releases/download/v1.1.1/rcedit-x64.exe" -OutFile %RCEDIT_HOME%/rcedit.exe

# Set rcedit to path
RUN setx /M PATH "%PATH%;%RCEDIT_HOME%"

# Download Windows SDK
RUN powershell Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/p/?linkid=2083338"&"clcid=0x409' -OutFile C:/WindowsSDKSetup.exe

# Install Windows SDK
RUN powershell Start-Process -FilePath C:/WindowsSDKSetup.exe -ArgumentList "/q", "/norestart", "/features", "+" -Wait

# Remove the setup file
RUN powershell Remove-Item -Path C:/WindowsSDKSetup.exe

# Verify the installation
RUN powershell if (!(Test-Path 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64')) {throw "Installation of Windows SDK failed"}


# Copy signtool.exe from the InstallLocation in the registry
RUN powershell -command "& {&'Copy-Item' '%PROGRAMFILES(X86)%\Windows Kits\10\bin\x64\signtool.exe' -Destination %SIGNTOOL_HOME%}"

# Set signtool to path
RUN setx /M PATH "%PATH%;%SIGNTOOL_HOME%"

# Download and install butler
RUN powershell Invoke-WebRequest -Uri "https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default" -OutFile %BUTLER_HOME%/butler.zip
RUN powershell Expand-Archive -Path %BUTLER_HOME%/butler.zip -DestinationPath %BUTLER_HOME%

# Set butler to path
RUN setx /M PATH "%PATH%;%BUTLER_HOME%"

# Verify butler and rcedit installation
RUN powershell -Command "& {%BUTLER_HOME%/butler.exe -V; %RCEDIT_HOME%/rcedit.exe -h;}"

# Set Android to path
# RUN setx /M PATH "%PATH%;%ANDROID_HOME%/cmdline-tools/cmdline-tools/bin"

# Create an Android debug keystore
# RUN powershell "%ANDROID_HOME%/cmdline-tools/cmdline-tools/bin/keytool.exe" -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999

# Move debug.keystore to GODOT_HOME
# RUN powershell Move-Item -Path .\debug.keystore -Destination "%GODOT_HOME%\debug.keystore"

# Append editor settings
RUN echo 'export/windows/rcedit = "%RCEDIT_HOME%"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
RUN echo 'export/windows/signtool = "%SIGNTOOL_HOME%"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/android_sdk_path = "${ANDROID_SDK_ROOT}"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/shutdown_adb_on_exit = true' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/timestamping_authority_url = ""' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/debug_keystore_pass = "android"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres
# RUN echo 'export/android/debug_keystore = "%GODOT_HOME%\debug.keystore"' >> %GODOT_HOME%/editor_data/editor_settings-4.tres

# Remove downloaded files
RUN powershell Remove-Item -Path %BUTLER_HOME%/butler.zip
RUN powershell Remove-Item -Path .\godot.zip
RUN powershell Remove-Item -Path .\export-templates.tpz

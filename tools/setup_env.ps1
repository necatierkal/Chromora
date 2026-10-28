$ErrorActionPreference = "Stop"
$base = "c:\Users\PC\Desktop\Önemli Projelerim\Chromora"

Write-Host "=== Setting up Chromora Directories ==="
$dirs = @(
    "tools\godot",
    "android",
    "src\core",
    "src\entities",
    "src\ui",
    "src\ui\components",
    "src\ui\modals",
    "data\levels",
    "data\mechanics",
    "assets\audio",
    "assets\fonts",
    "assets\icons",
    "tests",
    "docs"
)

foreach ($d in $dirs) {
    $full = Join-Path $base $d
    if (-not (Test-Path $full)) {
        New-Item -ItemType Directory -Path $full -Force | Out-Null
    }
}
Write-Host "Project directories created."

# Check Godot
$godotExe = Join-Path $base "tools\godot\godot.exe"
if (-not (Test-Path $godotExe)) {
    Write-Host "Downloading Godot 4.3 Stable..."
    $godotZip = Join-Path $base "tools\godot\godot.zip"
    $url = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    curl.exe -L -o $godotZip $url
    Write-Host "Extracting Godot 4.3..."
    Expand-Archive -Path $godotZip -DestinationPath (Join-Path $base "tools\godot") -Force
    Remove-Item $godotZip -Force
    $extracted = Get-ChildItem -Path (Join-Path $base "tools\godot") -Filter "*win64*.exe" | Select-Object -First 1
    if ($extracted) {
        Rename-Item -Path $extracted.FullName -NewName "godot.exe" -Force
    }
    Write-Host "Godot 4.3 ready at: $godotExe"
} else {
    Write-Host "Godot 4.3 already present."
}

# Check Android Export Templates
$templatesDir = Join-Path $env:APPDATA "Godot\export_templates\4.3.stable"
if (-not (Test-Path (Join-Path $templatesDir "android_debug.apk"))) {
    Write-Host "Downloading Godot 4.3 Export Templates..."
    if (-not (Test-Path $templatesDir)) {
        New-Item -ItemType Directory -Path $templatesDir -Force | Out-Null
    }
    $tpzPath = Join-Path $base "tools\godot\templates.tpz"
    $tpzUrl = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz"
    curl.exe -L -o $tpzPath $tpzUrl
    Write-Host "Extracting Export Templates..."
    $tempExtract = Join-Path $base "tools\godot\temp_templates"
    Expand-Archive -Path $tpzPath -DestinationPath $tempExtract -Force
    # Inside tpz, files are inside 'templates/' folder
    $innerTemplates = Join-Path $tempExtract "templates"
    if (Test-Path $innerTemplates) {
        Copy-Item -Path "$innerTemplates\*" -Destination $templatesDir -Recurse -Force
    } else {
        Copy-Item -Path "$tempExtract\*" -Destination $templatesDir -Recurse -Force
    }
    Remove-Item -Path $tpzPath -Force
    Remove-Item -Path $tempExtract -Recurse -Force
    Write-Host "Export templates installed to: $templatesDir"
} else {
    Write-Host "Export templates already installed at: $templatesDir"
}

# Generate debug keystore
$keystorePath = Join-Path $base "android\debug.keystore"
if (-not (Test-Path $keystorePath)) {
    Write-Host "Generating debug.keystore..."
    $keytool = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\keytool.exe"
    & $keytool -genkey -v -keystore $keystorePath -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    Write-Host "debug.keystore generated."
} else {
    Write-Host "debug.keystore already exists."
}

Write-Host "=== Setup Environment Completed Successfully ==="

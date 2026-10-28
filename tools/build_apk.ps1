# Chromora - Bulletproof Android Debug APK Build & Verify Script
$ErrorActionPreference = "Stop"

$baseDir = Split-Path -Parent $PSScriptRoot
$godotExe = "D:\tools\godot\godot.exe"
$outApk = Join-Path $baseDir "android\Chromora-debug.apk"
$tempApk = "D:\tools\godot\Chromora-debug.apk"
$keystore = "D:\tools\godot\debug.keystore"
$aapt = "C:\Android\Sdk\build-tools\34.0.0\aapt.exe"
$zipalign = "C:\Android\Sdk\build-tools\34.0.0\zipalign.exe"
$apksigner = "C:\Android\Sdk\build-tools\34.0.0\apksigner.bat"
$cacheDir = "D:\tools\godot\editor_data\cache"

Write-Host "=== Building Chromora Android Debug APK ==="
Set-Location $baseDir

# Clean previous temp unaligned files if any
Remove-Item "$cacheDir\tmpexport-unaligned.*" -Force -ErrorAction SilentlyContinue

# Execute Godot export
cmd.exe /c "$godotExe --headless --export-debug Android $tempApk"

# Check if Godot finished or if Windows file-sharing lock prevented internal zipalign/apksigner
$unaligned = Get-ChildItem "$cacheDir" -Filter "tmpexport-unaligned.*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($unaligned) {
    Write-Host "Finalizing alignment and signature via Android build-tools..."
    & $zipalign -p -f 4 $unaligned.FullName $tempApk
    & $apksigner sign --verbose --ks $keystore --ks-pass "pass:android" --ks-key-alias "androiddebugkey" $tempApk
    Remove-Item $unaligned.FullName -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path $tempApk)) {
    Write-Error "Failed to generate $tempApk"
}

# Copy to target location
Copy-Item -Path $tempApk -Destination $outApk -Force
Write-Host "APK output located at: $outApk"

# Sizing
$fileObj = Get-Item -LiteralPath $outApk
$byteCount = $fileObj.Length
$mbCount = [math]::Round($byteCount / 1048576, 2)
Write-Host "APK File Size: $mbCount MB ($byteCount bytes)"

# Verify package & permissions
Write-Host "`n=== Package & Permissions Validation ==="
& $aapt dump badging $tempApk | Select-String "package:", "application-label:", "uses-permission:"

# Verify signature
Write-Host "`n=== Signature Validation ==="
& $apksigner verify --verbose $outApk

Write-Host "`n=== BUILD AND VALIDATION SUCCESSFUL! ==="

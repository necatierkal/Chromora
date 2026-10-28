# Chromora - Production Android Release APK Build & Verify Script
$ErrorActionPreference = "Stop"

$baseDir = Split-Path -Parent $PSScriptRoot
$godotExe = "D:\tools\godot\godot.exe"
$outApk = Join-Path $baseDir "android\Chromora-release.apk"
$tempApk = "D:\tools\godot\Chromora-release.apk"
$keystore = "D:\tools\godot\chromora-release.keystore"
$aapt = "C:\Android\Sdk\build-tools\34.0.0\aapt.exe"
$zipalign = "C:\Android\Sdk\build-tools\34.0.0\zipalign.exe"
$apksigner = "C:\Android\Sdk\build-tools\34.0.0\apksigner.bat"
$cacheDir = "D:\tools\godot\editor_data\cache"

Write-Host "=== Building Chromora Android Release APK ==="
Set-Location $baseDir

# Clean previous temp files
Remove-Item "$cacheDir\tmpexport-unaligned.*" -Force -ErrorAction SilentlyContinue
Remove-Item $tempApk -Force -ErrorAction SilentlyContinue

# Execute Godot release export
cmd.exe /c "$godotExe --headless --export-release Android $tempApk"

# Finalize alignment and release signature if temp unaligned was generated
$unaligned = Get-ChildItem "$cacheDir" -Filter "tmpexport-unaligned.*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($unaligned) {
    Write-Host "Finalizing alignment and release signature via Android build-tools..."
    & $zipalign -p -f 4 $unaligned.FullName $tempApk
    & $apksigner sign --verbose --ks $keystore --ks-pass "pass:chromora2026release" --ks-key-alias "chromora_release_key" $tempApk
    Remove-Item $unaligned.FullName -Force -ErrorAction SilentlyContinue
} else {
    # If Godot exported without external signing, verify or sign explicitly with release keystore
    Write-Host "Ensuring release keystore signature via apksigner..."
    & $apksigner sign --verbose --ks $keystore --ks-pass "pass:chromora2026release" --ks-key-alias "chromora_release_key" $tempApk
}

if (-not (Test-Path $tempApk)) {
    Write-Error "Failed to generate $tempApk"
}

# Copy to target destination
Copy-Item -Path $tempApk -Destination $outApk -Force
Write-Host "Release APK output located at: $outApk"

# File size
$fileObj = Get-Item -LiteralPath $outApk
$byteCount = $fileObj.Length
$mbCount = [math]::Round($byteCount / 1048576, 2)
Write-Host "APK File Size: $mbCount MB ($byteCount bytes)"

# Verify package & permissions
Write-Host "`n=== Package & Permissions Validation ==="
& $aapt dump badging $tempApk | Select-String "package:", "application-label:", "uses-permission:"

# Verify signature
Write-Host "`n=== Release Signature Validation ==="
& $apksigner verify --verbose $outApk

Write-Host "`n=== RELEASE BUILD AND VALIDATION SUCCESSFUL! ==="

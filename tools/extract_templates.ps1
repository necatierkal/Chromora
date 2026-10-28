Add-Type -AssemblyName System.IO.Compression.FileSystem
$dest = "D:\tools\godot\editor_data\export_templates\4.3.stable"
if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}
$zip = [System.IO.Compression.ZipFile]::OpenRead("D:\tools\godot\templates.tpz")
Write-Host "Total entries:" $zip.Entries.Count

foreach ($entry in $zip.Entries) {
    if ($entry.FullName.StartsWith("templates/")) {
        $relName = $entry.FullName.Substring("templates/".Length)
        if ($relName.Length -gt 0 -and -not $relName.EndsWith("/")) {
            $target = Join-Path $dest $relName
            $parent = Split-Path $target -Parent
            if (-not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
        }
    }
}
$zip.Dispose()
Remove-Item "D:\tools\godot\templates.tpz" -Force
Write-Host "Export templates extracted successfully to: $dest"
Get-ChildItem $dest | Select-Object Name, Length

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $UpstreamDir,
    [Parameter(Mandatory)] [string] $GameRefDir,
    [Parameter(Mandatory)] [string] $OutputDir
)
$ErrorActionPreference = 'Stop'
$upstreamRoot = (Resolve-Path -LiteralPath $UpstreamDir).Path
$referencesRoot = (Resolve-Path -LiteralPath $GameRefDir).Path
$destinationRoot = [IO.Path]::GetFullPath($OutputDir)
if (Test-Path -LiteralPath $destinationRoot) { throw 'OutputDir must not already exist.' }
$upstreamManifest = Join-Path $upstreamRoot 'checksums.manifest'
foreach ($entry in (Get-Content -LiteralPath $upstreamManifest -Raw | ConvertFrom-Json)) {
    $assetPath = [IO.Path]::GetFullPath((Join-Path $upstreamRoot $entry.path))
    if (!$assetPath.StartsWith($upstreamRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Invalid upstream path: $($entry.path)"
    }
    if ((Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash -ne $entry.sha256) {
        throw "Upstream hash mismatch: $($entry.path)"
    }
}
$outputDll = Join-Path $destinationRoot 'ShieldOnly.dll'
dotnet run --project (Join-Path $PSScriptRoot 'ShieldOnlyPort.csproj') -c Release -- (Join-Path $upstreamRoot 'ShieldOnly.dll') $referencesRoot $outputDll
if ($LASTEXITCODE -ne 0) { throw 'Assembly audit/port failed.' }
foreach ($folder in @('spine', 'blood', 'offering')) {
    Copy-Item -LiteralPath (Join-Path $upstreamRoot $folder) -Destination (Join-Path $destinationRoot $folder) -Recurse
}
$repositoryRoot = Split-Path -Parent $PSScriptRoot
foreach ($name in @('ShieldOnly.json', 'README.md', '验证报告.md')) {
    Copy-Item -LiteralPath (Join-Path $repositoryRoot $name) -Destination (Join-Path $destinationRoot $name)
}
$records = @(Get-ChildItem -LiteralPath $destinationRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
    [ordered]@{
        path = [IO.Path]::GetRelativePath($destinationRoot, $_.FullName).Replace('\', '/')
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
})
$records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $destinationRoot 'checksums.manifest') -Encoding utf8
Write-Output "Built: $destinationRoot"

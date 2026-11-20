param(
    [string]$NodeVersion = '24.13.0'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$rawArch = $env:PROCESSOR_ARCHITEW6432
if ([string]::IsNullOrWhiteSpace($rawArch)) {
    $rawArch = $env:PROCESSOR_ARCHITECTURE
}

$arch = switch ($rawArch.ToUpperInvariant()) {
    'ARM64' { 'arm64' }
    'AMD64' { 'x64' }
    default { throw "Unsupported Windows architecture for Node.js bootstrap: $rawArch" }
}

$cacheRoot = Join-Path $PSScriptRoot '.cache'
$folderName = "node-v$NodeVersion-win-$arch"
$targetDir = Join-Path $cacheRoot $folderName
$nodeExe = Join-Path $targetDir 'node.exe'

if (-not (Test-Path -LiteralPath $nodeExe)) {
    New-Item -ItemType Directory -Path $cacheRoot -Force | Out-Null
    $tmpDir = Join-Path $cacheRoot ('.tmp-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    try {
        $baseUrl = "https://nodejs.org/dist/v$NodeVersion"
        $zipName = "$folderName.zip"
        $zipUrl = "$baseUrl/$zipName"
        $shaUrl = "$baseUrl/SHASUMS256.txt"
        $zipPath = Join-Path $tmpDir $zipName
        $shaPath = Join-Path $tmpDir 'SHASUMS256.txt'
        $extractDir = Join-Path $tmpDir 'extract'

        [Console]::Error.WriteLine("Node.js was not found on PATH (or is older than v20). Downloading portable Node.js v$NodeVersion ($arch)...")
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Invoke-WebRequest -Uri $shaUrl -OutFile $shaPath -UseBasicParsing

        $pattern = "^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($zipName))$"
        $expectedLine = Get-Content -LiteralPath $shaPath | Where-Object { $_ -match $pattern } | Select-Object -First 1
        if (-not $expectedLine) {
            throw "Could not find SHA-256 checksum for $zipName in $shaUrl"
        }
        $expectedHash = $Matches[1].ToLowerInvariant()
        $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash) {
            throw "SHA-256 checksum mismatch for ${zipName}: expected $expectedHash, got $actualHash"
        }

        [Console]::Error.WriteLine("Extracting Node.js v$NodeVersion to $targetDir...")
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

        $stagedDir = Join-Path $extractDir $folderName
        $stagedNode = Join-Path $stagedDir 'node.exe'
        if (-not (Test-Path -LiteralPath $stagedNode)) {
            throw "Extracted archive did not contain $stagedNode"
        }

        $null = & $stagedNode -v
        if ($LASTEXITCODE -ne 0) {
            throw "Bootstrapped Node.js binary failed self-check (exit code $LASTEXITCODE)"
        }

        if (-not (Test-Path -LiteralPath $nodeExe)) {
            if (Test-Path -LiteralPath $targetDir) {
                Remove-Item -LiteralPath $targetDir -Recurse -Force
            }
            Move-Item -LiteralPath $stagedDir -Destination $targetDir
        }
    } finally {
        Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

[Console]::Out.WriteLine($nodeExe)

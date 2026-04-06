param(
    [string]$Version = "latest",
    [string]$Repo = "med-000/tduex",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\tduex\bin",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-AssetArch {
    switch ($env:PROCESSOR_ARCHITECTURE.ToLowerInvariant()) {
        "arm64" { return "arm64" }
        default { return "x86_64" }
    }
}

function Get-ReleaseUrl {
    param(
        [string]$RepoName,
        [string]$ReleaseVersion,
        [string]$AssetName
    )

    if ($ReleaseVersion -eq "latest") {
        return "https://github.com/$RepoName/releases/latest/download/$AssetName"
    }

    return "https://github.com/$RepoName/releases/download/$ReleaseVersion/$AssetName"
}

function Add-UserPath {
    param([string]$PathToAdd)

    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    $entries = @()
    if ($current) {
        $entries = $current.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
    }

    if ($entries -contains $PathToAdd) {
        return $false
    }

    $updated = if ($current) { "$current;$PathToAdd" } else { $PathToAdd }
    [Environment]::SetEnvironmentVariable("Path", $updated, "User")
    return $true
}

$arch = Get-AssetArch
$assetName = "tduex_Windows_$arch.zip"
$downloadUrl = Get-ReleaseUrl -RepoName $Repo -ReleaseVersion $Version -AssetName $assetName

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("tduex-install-" + [System.Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot $assetName
$extractDir = Join-Path $tempRoot "extract"
$exeName = "tduex.exe"
$downloaded = $false

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    Write-Host "Downloading $downloadUrl"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
    $downloaded = $true

    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    $exePath = Get-ChildItem -Path $extractDir -Filter $exeName -Recurse | Select-Object -First 1 -ExpandProperty FullName
    if (-not $exePath) {
        throw "tduex.exe was not found in $assetName."
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    $destination = Join-Path $InstallDir $exeName
    Copy-Item -Path $exePath -Destination $destination -Force:$Force.IsPresent

    $pathUpdated = Add-UserPath -PathToAdd $InstallDir

    Write-Host "Installed: $destination"
    if ($pathUpdated) {
        Write-Host "Added to user PATH: $InstallDir"
        Write-Host "Open a new PowerShell window to use 'tduex'."
    } else {
        Write-Host "You can now run 'tduex' from a new PowerShell window."
    }
}
catch {
    if (-not $downloaded) {
        Write-Error "Failed to download release asset '$assetName'. Create a GitHub release asset with that name or specify -Version."
    }

    throw
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
    }
}

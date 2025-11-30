#Requires -Version 7.4

[CmdletBinding()]
param ()

begin {
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version 3.0

    $SourceDir = $PSScriptRoot
    $TargetDir = $PWD
    $GitDir    = Join-Path $SourceDir .git
}

process {
    & git --git-dir=$GitDir ls-files | ForEach-Object {
        $SourcePath = Join-Path $SourceDir $_
        $TargetPath = Join-Path $TargetDir $_

        # Skip unchanged files
        $SourceHash = Get-FileHash -Path $SourcePath -Algorithm SHA256
        $TargetHash = Get-FileHash -Path $TargetPath -Algorithm SHA256 -ErrorAction Ignore
        if ($SourceHash.Hash -eq ($TargetHash)?.Hash) {
          Write-Host "Skipping: $TargetPath (unchanged)" -ForegroundColor DarkGray
          return
        }

        Write-Host "Ensuring: $TargetPath"

        # Ensure target directory exists
        $d = Split-Path $TargetPath -Parent
        if (-not (Test-Path $d)) {
            New-Item -ItemType Directory -Path $d -Force > $null
        }

        # Copy the file from source to target
        Copy-Item $SourcePath $TargetPath -Force
    }
}

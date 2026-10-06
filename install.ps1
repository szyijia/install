#Requires -Version 5.1
$ErrorActionPreference = "Stop"

if ($env:OS -ne 'Windows_NT' -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
    throw 'This installer requires Windows x64. Other hosts are not yet accepted.'
}

$installDirectory = [IO.Path]::Combine($home, ".patchwing")

function Test-GitInstalled {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Debug "Git is installed."
    }
    else {
        Write-Output "No git installation detected. Git is required to use patchwing."
        exit 1
    }
}

function Compare-GitVersions {
    param (
        [string]$version1,
        [string]$version2
    )

    $version1Components = $version1 -split '\.'
    $version2Components = $version2 -split '\.'

    for ($i = 0; $i -lt 3; $i++) {
        $version1Number = [int]$version1Components[$i]
        $version2Number = [int]$version2Components[$i]

        if ($version1Number -lt $version2Number) {
            return -1
        }
        elseif ($version1Number -gt $version2Number) {
            return 1
        }
    }

    return 0
}

function Test-GitVersion {
    $minGitVersion = "2.25.1"
    $gitVersionText = & git --version
    if ($LASTEXITCODE -ne 0 -or $gitVersionText -notmatch 'git version (\d+\.\d+\.\d+)') {
        throw 'Unable to determine Git version.'
    }
    $gitVersion = $Matches[1]
    $comparisonResult = Compare-GitVersions -version1 $gitVersion -version2 $minGitVersion
    if ($comparisonResult -eq -1) {
        Write-Output "Installed git version $gitVersion is older than required git version $minGitVersion."
        exit 1
    }
}

function Update-Path {
    $path = [Environment]::GetEnvironmentVariable("PATH", "User")
    $binPath = [IO.Path]::Combine($installDirectory, "bin")
    $entries = @($path -split [IO.Path]::PathSeparator | Where-Object { $_ })
    if ($entries | Where-Object { $_.TrimEnd('\') -ieq $binPath.TrimEnd('\') }) {
        return $false
    }
    [Environment]::SetEnvironmentVariable(
        "Path", (($entries + $binPath) -join [IO.Path]::PathSeparator), "User"
    )

    return $true
}

Test-GitInstalled
Test-GitVersion

if (Test-Path $installDirectory) {
    throw "Existing directory detected: $installDirectory. It has been preserved; use a fresh Windows user for first-install acceptance."
}

Write-Output "Installing Patchwing to $installDirectory..."

& git clone https://github.com/szyijia/patchwing.git -b patchwing/main $installDirectory
if ($LASTEXITCODE -ne 0) {
    throw "Git clone failed with exit $LASTEXITCODE. Partial files have been preserved."
}

Push-Location $installDirectory\bin
try {
    & .\pw.bat --version
    if ($LASTEXITCODE -ne 0) {
        throw "Patchwing bootstrap failed with exit $LASTEXITCODE. PATH has not been changed."
    }
}
finally {
    Pop-Location
}

$wasPathUpdated = Update-Path
Write-Output @"

Patchwing has been installed!

"@

if ($wasPathUpdated) {
    Write-Output @"
Please restart your terminal to start using Patchwing.
"@
}

Write-Output @"
To create an account, visit: https://console.patchwing.net/register
Then login using:

  pw login

For more information, visit:
https://docs.patchwing.net
"@

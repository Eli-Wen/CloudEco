param(
    [Parameter(Mandatory = $true)]
    [string]$HostUrl,

    [Parameter(Mandatory = $true)]
    [int]$Users,

    [Parameter(Mandatory = $true)]
    [int]$SpawnRate,

    [Parameter(Mandatory = $true)]
    [string]$RunTime,

    [Parameter(Mandatory = $true)]
    [string]$OutputPrefix
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$locustFile = Join-Path $repoRoot "load_tests\locustfile.py"
$resultsDir = Join-Path $repoRoot "load_tests\results"
$csvPrefixPath = Join-Path $resultsDir $OutputPrefix

if (-not (Test-Path $locustFile)) {
    throw "Locust file not found: $locustFile"
}

if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

Write-Host "Running single Locust test..."
Write-Host "Host: $HostUrl | Users: $Users | SpawnRate: $SpawnRate | RunTime: $RunTime"
Write-Host "CSV prefix: $csvPrefixPath"

locust `
    -f $locustFile `
    --headless `
    -u $Users `
    -r $SpawnRate `
    -t $RunTime `
    --host $HostUrl `
    --csv "$csvPrefixPath"

Write-Host "Locust run finished. CSV outputs saved under load_tests/results/."

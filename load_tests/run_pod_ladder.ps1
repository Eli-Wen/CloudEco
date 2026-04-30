param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(1, 2, 4, 8)]
    [int]$PodCount,

    [Parameter(Mandatory = $true)]
    [string]$HostUrl,

    [string]$Users = "1,2,4,8,12,16,24,32",

    [int]$SpawnRate = 1,

    [string]$RunTime = "2m",

    [switch]$ScaleFirst
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$singleRunScript = Join-Path $repoRoot "load_tests\run_single_locust_test.ps1"
$scaleScript = Join-Path $repoRoot "load_tests\scale_k8s_deployment.ps1"
$resultsDir = Join-Path $repoRoot "load_tests\results"

if (-not (Test-Path $singleRunScript)) {
    throw "Single-run script not found: $singleRunScript"
}

if ($ScaleFirst) {
    if (-not (Test-Path $scaleScript)) {
        throw "Scale script not found: $scaleScript"
    }
    Write-Host "Scaling deployment to $PodCount replicas before ladder run..."
    & $scaleScript -Replicas $PodCount
}

$userLevels = $Users.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
if ($userLevels.Count -eq 0) {
    throw "No valid user levels provided. Example: -Users `"1,2,4,8`""
}

if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

for ($i = 0; $i -lt $userLevels.Count; $i++) {
    $userLevelRaw = $userLevels[$i]
    if (-not [int]::TryParse($userLevelRaw, [ref]$null)) {
        throw "Invalid user level: $userLevelRaw"
    }
    $userLevel = [int]$userLevelRaw
    if ($userLevel -le 0) {
        throw "User level must be > 0. Invalid value: $userLevel"
    }

    $outputPrefix = "pod${PodCount}_users${userLevel}"

    Write-Host ""
    Write-Host "========================================"
    Write-Host "Running $outputPrefix"
    Write-Host "Host=$HostUrl Users=$userLevel SpawnRate=$SpawnRate RunTime=$RunTime"
    Write-Host "========================================"

    & $singleRunScript `
        -HostUrl $HostUrl `
        -Users $userLevel `
        -SpawnRate $SpawnRate `
        -RunTime $RunTime `
        -OutputPrefix $outputPrefix

    Write-Host ""
    Write-Host "Expected raw CSV outputs under: $resultsDir"
    Write-Host "Prefix: $outputPrefix"
    Write-Host "Inspect failure rate and latency before continuing."

    if ($i -lt $userLevels.Count - 1) {
        Read-Host "Press Enter to continue to next user level, or Ctrl+C to stop at breaking point"
    }
}

Write-Host ""
Write-Host "Pod ladder run completed."

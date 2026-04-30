param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(1, 2, 4, 8)]
    [int]$Replicas
)

$ErrorActionPreference = "Stop"

# This helper changes only Kubernetes deployment replica count.
# It does not create/update/destroy Azure infrastructure resources.
$repoRoot = Split-Path -Parent $PSScriptRoot
$sshKeyPath = Join-Path $repoRoot "infra\keys\cloudeco_a1_key"
$masterHost = "azureuser@48.193.42.240"

if (-not (Test-Path $sshKeyPath)) {
    throw "SSH key not found: $sshKeyPath"
}

$remoteCommand = @"
kubectl scale deployment cloudeco-api -n cloudeco --replicas=$Replicas
kubectl rollout status deployment/cloudeco-api -n cloudeco --timeout=300s
kubectl get pods -n cloudeco -o wide
"@

Write-Host "Scaling cloudeco-api to $Replicas replicas..."
ssh -o StrictHostKeyChecking=no -i $sshKeyPath $masterHost $remoteCommand
Write-Host "Scaling command finished."

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Workspace,
    [Parameter(Mandatory = $true)]
    [string]$RuntimeNodeModules,
    [string]$CompatibilityRoot
)

$ErrorActionPreference = 'Stop'
$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
$runtimeModulesPath = (Resolve-Path -LiteralPath $RuntimeNodeModules).Path
$compatibilityRootPath = if ($CompatibilityRoot) {
    (Resolve-Path -LiteralPath $CompatibilityRoot).Path
} else {
    $workspacePath
}
$packageJson = Join-Path $runtimeModulesPath '@oai\artifact-tool\package.json'
if (-not (Test-Path -LiteralPath $packageJson -PathType Leaf)) {
    throw "Runtime node_modules does not contain @oai/artifact-tool/package.json: $runtimeModulesPath"
}

$compatModules = Join-Path $compatibilityRootPath '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules'
if (Test-Path -LiteralPath $compatModules) {
    $resolvedCompat = (Resolve-Path -LiteralPath $compatModules).Path
    $compatPackage = Join-Path $resolvedCompat '@oai\artifact-tool\package.json'
    if (-not (Test-Path -LiteralPath $compatPackage -PathType Leaf)) {
        throw "Existing workspace runtime path is incompatible and will not be overwritten: $compatModules"
    }
    Write-Output "Existing compatible runtime path: $compatModules"
    exit 0
}

$compatParent = Split-Path -Parent $compatModules
New-Item -ItemType Directory -Force -Path $compatParent | Out-Null
New-Item -ItemType Junction -Path $compatModules -Target $runtimeModulesPath | Out-Null
Write-Output "Created artifact-tool compatibility junction: $compatModules -> $runtimeModulesPath"

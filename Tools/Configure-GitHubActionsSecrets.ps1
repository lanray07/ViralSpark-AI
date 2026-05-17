param(
    [Parameter(Mandatory = $true)]
    [string] $PrivateKeyPath,

    [string] $KeyId = "YGUJ392L3K",
    [string] $IssuerId = "69a6de76-14b3-47e3-e053-5b8c7c11a4d1"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is required to set repository secrets from this script."
}

if (-not (Test-Path -LiteralPath $PrivateKeyPath)) {
    throw "Private key file not found: $PrivateKeyPath"
}

$privateKeyBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $PrivateKeyPath)))

$KeyId | gh secret set ASC_KEY_ID
$IssuerId | gh secret set ASC_ISSUER_ID
$privateKeyBase64 | gh secret set ASC_PRIVATE_KEY_BASE64

Write-Host "GitHub Actions secrets configured for App Store Connect upload."

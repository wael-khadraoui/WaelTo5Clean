# Run full stack from repo root (double-click may require: Right-click -> Run with PowerShell)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
$compose = Join-Path $PSScriptRoot 'docker-compose.yml'
$envFile = Join-Path $PSScriptRoot '.env'
$envExample = Join-Path $PSScriptRoot '.env.example'

if (-not (Test-Path $envFile)) {
  Write-Host 'Creating docker/.env from .env.example...'
  Copy-Item $envExample $envFile -Force
  Write-Host 'Edit docker/.env if needed.' -ForegroundColor Yellow
}

Write-Host 'Starting Docker stack...'
docker compose -f $compose --env-file $envFile up --build -d
Write-Host 'App: http://localhost:8080  |  Adminer: http://localhost:5050' -ForegroundColor Green

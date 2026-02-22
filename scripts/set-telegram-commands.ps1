param(
  [Parameter(Mandatory=$true)] [string] $BotToken,
  [string] $LanguageCode = "en"
)

$ErrorActionPreference = 'Stop'

$base = "https://api.telegram.org/bot$BotToken/setMyCommands"
$commandsPath = Join-Path $PSScriptRoot "..\telegram-commands.json"

if (-not (Test-Path $commandsPath)) {
  Write-Error "commands file not found: $commandsPath"
  exit 1
}

$commandsObj = Get-Content $commandsPath -Raw | ConvertFrom-Json
$payload = @{ 
  commands = @($commandsObj.commands) 
  language_code = $LanguageCode
} | ConvertTo-Json -Depth 10

try {
  $res = Invoke-RestMethod -Uri $base -Method Post -Body $payload -ContentType "application/json"
  if ($res.ok) {
    Write-Output "✅ Telegram slash commands updated."
  } else {
    Write-Output "❌ Telegram API returned error."
    $res | ConvertTo-Json -Depth 6
    exit 1
  }
} catch {
  Write-Error "Failed to update commands: $($_.Exception.Message)"
  exit 1
}

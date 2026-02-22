param(
  [Parameter(Mandatory=$true)] [string] $BotToken,
  [string] $LanguageCode = "en"
)

$ErrorActionPreference = 'Stop'

$myCmdUrl = "https://api.telegram.org/bot$BotToken/getMyCommands"
$body = @{ language_code = $LanguageCode } | ConvertTo-Json
$desiredPath = Join-Path $PSScriptRoot "..\telegram-commands.json"
$desired = (Get-Content $desiredPath -Raw | ConvertFrom-Json).commands.command

try {
  $res = Invoke-RestMethod -Uri $myCmdUrl -Method Post -Body $body -ContentType "application/json"
} catch {
  Write-Error "Failed to fetch current commands: $($_.Exception.Message)"
  exit 1
}

if (-not $res.ok) { Write-Error "Telegram API error: $($res.description)"; exit 1 }
$current = @($res.result.command)

$collision = $desired | Where-Object { $_ -in $current }

if ($collision.Count -gt 0) {
  Write-Output "⚠️  Conflict candidates with existing bot commands:"
  $collision | ForEach-Object { "- /$_" }
} else {
  Write-Output "✅ No collision with current bot commands."
}

Write-Output "Desired commands to register:"
$desired | ForEach-Object { "- /$_" }

if ($current.Count -gt 0) {
  Write-Output "\nCurrent bot commands for check:"
  $current | ForEach-Object { "- /$_" }
}

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$Patterns = @(
    'TELEGRAM_BOT_TOKEN\s*[:=]',
    '\b[0-9]{8,10}:[A-Za-z0-9_-]{30,}\b',
    'OPENAI_API_KEY\s*[:=]',
    'ANTHROPIC_API_KEY\s*[:=]',
    'api[_-]?key\s*[:=]\s*\S+',
    'BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY',
    'password\s*[:=]\s*\S+',
    'oauth[_-]?token\s*[:=]',
    'bearer\s+[A-Za-z0-9._-]+'
)

$Regex = [regex]::new(($Patterns -join "|"), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$Files = Get-ChildItem -Recurse -File -Force |
    Where-Object {
        $_.FullName -notmatch '\\.git\\' -and
        $_.FullName -notmatch '\\snapshots\\hermes\\(logs|sessions|cache)\\' -and
        $_.Name -notin @('verify-no-secrets.ps1', 'verify-no-secrets.sh')
    }

$Found = $false
foreach ($File in $Files) {
    $Rel = Resolve-Path -Relative $File.FullName
    if ($File.Name -in @('.env', 'auth.json', 'id_rsa', 'id_ed25519') -or
        $File.Name -like '.env.*' -or
        $File.Name -like '*.pem' -or
        $File.Name -like '*.key') {
        Write-Host "Forbidden secret-like file tracked or present: $Rel"
        $Found = $true
        continue
    }
    try {
        $Matches = Select-String -Path $File.FullName -Pattern $Regex -AllMatches -ErrorAction Stop
    } catch {
        continue
    }
    foreach ($Match in $Matches) {
        if ($Match.Line -match '(?i)\b(api[_-]?key|token|secret|password|oauth[_-]?token)\s*[:=]\s*REDACTED\b') {
            continue
        }
        Write-Host "Potential secret in ${Rel}:$($Match.LineNumber): $($Match.Line.Trim())"
        $Found = $true
    }
}

if ($Found) {
    Write-Error "Secret verification failed."
    exit 1
}

Write-Host "No obvious secrets found."

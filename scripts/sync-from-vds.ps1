$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$HostName = $env:HERMES_VDS_HOST
if (-not $HostName) { $HostName = "178.104.60.170" }
$User = $env:HERMES_VDS_USER
if (-not $User) { $User = "root" }
$Port = $env:HERMES_VDS_PORT
if (-not $Port) { $Port = "22" }
$Key = $env:HERMES_VDS_KEY
if (-not $Key) { $Key = Join-Path $HOME ".ssh\hermes-vds\hermes_vds_ed25519" }
$KnownHosts = Join-Path $env:TEMP "hermes_vds_known_hosts_tmp"

$WorkspaceSnapshot = Join-Path $Root "snapshots\workspace"
$HermesSnapshot = Join-Path $Root "snapshots\hermes"
$MemSnapshot = Join-Path $HermesSnapshot "memories"
$SystemdSnapshot = Join-Path $Root "snapshots\systemd"
New-Item -ItemType Directory -Force -Path $WorkspaceSnapshot, $HermesSnapshot, $MemSnapshot, $SystemdSnapshot | Out-Null

function Invoke-HermesSsh {
    param([string]$Command)
    & ssh -i $Key -p $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$User@$HostName" $Command
}

function Copy-HermesFile {
    param([string]$Remote, [string]$Local)
    & scp -i $Key -P $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$User@$HostName`:$Remote" $Local 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Skipped missing or inaccessible $Remote" }
}

$RemoteTar = "/tmp/hermes_workspace_snapshot.tar.gz"
$TarPath = Join-Path $env:TEMP "hermes_workspace_snapshot.tar.gz"
Invoke-HermesSsh "cd /srv/hermes/workspace && tar --exclude='.env' --exclude='auth.json' --exclude='*.lock' --exclude='*.pid' --exclude='state.db*' --exclude='kanban.db' --exclude='sessions' --exclude='logs' --exclude='cache' --exclude='audio_cache' --exclude='image_cache' --exclude='.cache' --exclude='*.pem' --exclude='*.key' --exclude='id_rsa' --exclude='id_ed25519' -czf $RemoteTar ."
& scp -i $Key -P $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$User@$HostName`:$RemoteTar" $TarPath
Invoke-HermesSsh "rm -f $RemoteTar"
tar -xzf $TarPath -C $WorkspaceSnapshot

Copy-HermesFile "/home/hermes/.hermes/SOUL.md" (Join-Path $HermesSnapshot "SOUL.md")
Copy-HermesFile "/home/hermes/.hermes/memories/MEMORY.md" (Join-Path $MemSnapshot "MEMORY.md")
Copy-HermesFile "/home/hermes/.hermes/memories/USER.md" (Join-Path $MemSnapshot "USER.md")

$Config = Invoke-HermesSsh "python3 - <<'PY'
from pathlib import Path
import re
p = Path('/home/hermes/.hermes/config.yaml')
if p.exists():
    text = p.read_text(errors='replace')
    text = re.sub(r'(?i)(token|secret|password|api[_-]?key|oauth|bearer)(\s*[:=]\s*).+', r'\1\2REDACTED', text)
    text = re.sub(r'\b\d{8,10}:[A-Za-z0-9_-]{30,}\b', 'REDACTED_TELEGRAM_TOKEN', text)
    print(text)
PY"
$Config | Set-Content -Encoding UTF8 (Join-Path $HermesSnapshot "config.sanitized.yaml")

Invoke-HermesSsh "systemctl cat hermes-gateway.service 2>/dev/null || true" | Set-Content -Encoding UTF8 (Join-Path $SystemdSnapshot "hermes-gateway.service")
Invoke-HermesSsh "find /home/hermes/.hermes/skills -maxdepth 2 -type f 2>/dev/null | sort || true" | Set-Content -Encoding UTF8 (Join-Path $HermesSnapshot "skills.txt")
& (Join-Path $PSScriptRoot "healthcheck.ps1") | Set-Content -Encoding UTF8 (Join-Path $HermesSnapshot "healthcheck.txt")

Write-Host "Sync complete. Run scripts\verify-no-secrets.ps1 before commit."

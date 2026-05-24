$ErrorActionPreference = "Stop"

$HostName = $env:HERMES_VDS_HOST
if (-not $HostName) { $HostName = "178.104.60.170" }
$User = $env:HERMES_VDS_USER
if (-not $User) { $User = "root" }
$Port = $env:HERMES_VDS_PORT
if (-not $Port) { $Port = "22" }
$Key = $env:HERMES_VDS_KEY
if (-not $Key) { $Key = Join-Path $HOME ".ssh\hermes-vds\hermes_vds_ed25519" }
$Service = "hermes-gateway.service"
$Workspace = "/srv/hermes/workspace"
$HermesHome = "/home/hermes/.hermes"
$KnownHosts = Join-Path $env:TEMP "hermes_vds_known_hosts_tmp"

function Invoke-HermesSsh {
    param([string]$Command)
    & ssh -i $Key -p $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$User@$HostName" $Command
}

Write-Output "Hermes healthcheck for $User@$HostName"
Write-Output ("service.active=" + (Invoke-HermesSsh "systemctl is-active $Service 2>/dev/null || true"))
Write-Output ("service.enabled=" + (Invoke-HermesSsh "systemctl is-enabled $Service 2>/dev/null || true"))
Write-Output ("workspace.exists=" + (Invoke-HermesSsh "test -d '$Workspace' && echo yes || echo no"))
Write-Output ("hermes.home.exists=" + (Invoke-HermesSsh "test -d '$HermesHome' && echo yes || echo no"))
Write-Output ("config.exists=" + (Invoke-HermesSsh "test -f '$HermesHome/config.yaml' && echo yes || echo no"))
Write-Output ("env.present=" + (Invoke-HermesSsh "test -f '$HermesHome/.env' && echo present || echo absent"))
Write-Output ("auth_json.present=" + (Invoke-HermesSsh "test -f '$HermesHome/auth.json' && echo present || echo absent"))
Write-Output ("hermes.version_hint=" + (Invoke-HermesSsh "command -v hermes >/dev/null 2>&1 && hermes --version 2>/dev/null || python3 -m hermes --version 2>/dev/null || echo unknown"))

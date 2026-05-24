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

$SkillLocal = Join-Path $Root "deploy\hermes\skills\copywriter-agent\SKILL.md"
$ContextLocal = Join-Path $Root "deploy\hermes\workspace\docs\copywriting"

function Invoke-HermesSsh {
    param([string]$Command)
    & ssh -i $Key -p $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$User@$HostName" $Command
    if ($LASTEXITCODE -ne 0) {
        throw "ssh command failed with exit code $LASTEXITCODE"
    }
}

function Invoke-CheckedNative {
    param([scriptblock]$Command, [string]$Description)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE"
    }
}

Write-Host "Deploying copywriter agent to $User@$HostName"

Invoke-HermesSsh "install -d -o hermes -g hermes /home/hermes/.hermes/skills/copywriter-agent /srv/hermes/workspace/docs/copywriting"
Invoke-CheckedNative { & scp -i $Key -P $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts $SkillLocal "$User@$HostName`:/home/hermes/.hermes/skills/copywriter-agent/SKILL.md" } "copy skill"
Invoke-CheckedNative { & scp -i $Key -P $Port -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=$KnownHosts "$ContextLocal\*" "$User@$HostName`:/srv/hermes/workspace/docs/copywriting/" } "copy context"
Invoke-HermesSsh "chown -R hermes:hermes /home/hermes/.hermes/skills/copywriter-agent /srv/hermes/workspace/docs/copywriting && systemctl restart hermes-gateway.service && systemctl is-active hermes-gateway.service"

Write-Host "Copywriter agent deployed."

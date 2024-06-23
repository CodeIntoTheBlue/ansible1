# setup_windows_client.ps1

# Install OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Install OpenSSHUtils for key-based authentication
Install-Module -Force OpenSSHUtils -Scope AllUsers

# Start and configure SSH service
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Configure firewall
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Configure WinRM for Ansible
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file

# Enable SSH agent
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

Write-Host "Windows client has been set up for Ansible management."
Write-Host "Remember to copy the SSH public key from the master server."
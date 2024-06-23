
## Ubuntu richten...
```bash
# user sudo Rechte geben
su root 
nano /etc/sudoers

# snap aktualisieren
sudo snap refresh

snap-store --quit && sudo snap refresh snap-store

```

# 1. Open SSH

standardmäßig ist es mit passwort aber besser wäre mit SSH-keys
OpenSSH muss auf allen Clients und Servern installiert sein

# Linux


sudo apt install openssh-server




# Windows
- Ein Gerät, auf dem mindestens Windows Server 2019 oder Windows 10 (Build 1809) ausgeführt wird.

Installieren Sie dann die Server- oder Clientkomponente nach 

```powershell
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# intending to use key based
Install-Module -Force OpenSSHUtils -Scope AllUsers
```


Um den OpenSSH-Server für die erste Verwendung zu starten und zu konfigurieren, öffnen Sie eine PowerShell-Eingabeaufforderung mit erhöhten Rechten (mit der rechten Maustaste klicken, als Administrator ausführen), und führen Sie dann die folgenden Befehle aus, um den `sshd service` zu starten:


```powershell
# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
```




   ```powershell
   Restart-Service sshd
   ```
   
   **Automatischen Start einrichten**:
   - Stellen Sie sicher, dass der Dienst beim Systemstart automatisch startet:

   ```powershell
   Set-Service -Name sshd -StartupType 'Automatic'
   ```

### Konfiguration der Firewall

**Erstellen Sie eine Firewall-Regel für SSH**:
   - Verwenden Sie diesen Befehl, um eine eingehende Regel für den SSH-Port (22) zu erstellen:

   ```powershell
   New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
   ```


#ssh-agent on windows
OpenSSH AuthenticationAgent


# By default the ssh-agent service is disabled. Configure it to start automatically. 
# Make sure you're running as an Administrator. 

Get-Service ssh-agent | Set-Service -StartupType Automatic

# Start the service 

Start-Service ssh-agent 

# This should return a status of Running 

Get-Service ssh-agent 

# Now load your key files into ssh-agent 

ssh-add $env:USERPROFILE\.ssh\id_ed25519







## Linux Master

sudo apt install openssh-server


connect to each server from the workstation or laptop, answer yes to initial prompt


ssh 172.16.250.133




--> connect to server with the IP-Adress from Workstation (laptop)



## Create key on workstation


ls -la .ssh


ssh-keygen -t ed25519 -C "Strong Default"

#Passphrase ist immer besser (hugoboss)


### Adding ssh-key to a LINUX server

ssh-copy-id -i ~/.ssh/id_ed25519.pub 192.168.49.130


________________

## Windows-Client  Generieren eines SSH-Schlüssels auf dem (wenn nicht bereits vorhanden)

ssh-keygen -t ed25519 -C "your_email@example.com"


#### SSH-Schlüssel auf den Windows-Server kopieren


mkdir $env:USERPROFILE\.ssh


scp $env:USERPROFILE\.ssh\id_ed25519.pub user@192.168.49.130:C:\Users\user\.ssh\authorized_keys


icacls $env:USERPROFILE\.ssh\authorized_keys /inheritance:r
icacls $env:USERPROFILE\.ssh\authorized_keys /grant "$($env:USERNAME):(R)"
icacls $env:USERPROFILE\.ssh\authorized_keys /remove:g "Users"



Master Server python3-pip
pywinrm (python package)



Powershell version überprüfen
```powershell
$psversiontable
```

Browse: "Setting up windows Host ansible"
docs.ansible.com/ansible
WinRM Setup
ConfigureRemotingForAnsible.ps1
copy entire code into powershell





### SSH-Agent auf Windows


# By default the ssh-agent service is disabled. Configure it to start automatically.
# Make sure you're running as an Administrator.
Get-Service ssh-agent | Set-Service -StartupType Automatic

# Start the service
Start-Service ssh-agent

# This should return a status of Running
Get-Service ssh-agent

# Now load your key files into ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519





### Kopieren des öffentlichen Schlüssels von LinuxMaster zum Windows-Client

scp ~/.ssh/id_ed25519.pub username@windows_client_ip:C:/Users/username/.ssh/authorized_keys









### To use Ansible to ping Windows clients from a Linux control machine, you need to ensure that WinRM 


(Windows Remote Management) is properly configured on the Windows clients and that Ansible is set up correctly on the Linux control machine. Here are the general steps to achieve this:

#### 1. Set Up WinRM on Windows Clients

winrm quickconfig


Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -Enabled True



Set-Item WSMan:\localhost\Service\AllowRemoteAccess -Value $true

#on  linux master
sudo apt install python3-pip
     


ansible all --key-file ~/.ssh/ansible -i inventory -m win_ping




ansible all --key-file ~/.ssh/ansible -i inventory -m win_ping -vvv





## 2. Ansible Key generieren


ssh-keygen -t ed25519 -C "ansible"
```

anderen Pfad eingeben

 /home/janina/.ssh/ansible

--> keine Passphrase angeben



#Den key wieder rüberkopieren zu linux
ssh-copy-id -i ~/.ssh/ansible.pub 192.168.178.68


# zu windows hosts
scp ~/.ssh/ansible.pub win10admin1@192.168.178.68:C:/Users/win10admin1/.ssh/authorized_keys



##  SSH-AGENT auf linux master


eval $(ssh-agent)

# = Agent pid 2362

ps aux | grep 2362

#der ssh-agent is running in the background

ssh-add

#Enter passphrase for /home....
#--> Identity was added

#only for one terminal ein prozess endet dann beim schließen


---------------------------------

#oder beides zusammenfassen in ein alias on workstation
alias ssha='eval $(ssh-agent) && ssh-add'

#dann
ssha

#und fertig hinzugefügt die ssh
#bis terminal closed

nano .bashrc

# irgendwo in der datei einfach eintragen

#ssh-agent
alias ssha='eval $(ssh-agent) && ssh-add'

#und fertig gespeichert
# für immer


# Git on linux master workstation

nur on workstation required



which git


sudo apt update



sudo apt install git



# Ansible start


#auf dem linuxmaster aka workstation
sudo apt update

sudo apt install ansible

nano inventory

#Dann alle IP adressen eintragen die man managen will




ansible all --key-file ~/.ssh/ansible -i inventory -m ping


ansible servers --key-file ~/.ssh/ansible -i inventory -m ping

ansible windows --key-file ~/.ssh/ansible -i inventory -m win_ping

### create an ansible config file



nano ansible.cfg

[defaults]
inventory = inventory
private_key_file = ~/.ssh/ansible

ansible all -m ping




#### Create user add ssh-key and give sudo rights

#user_management.yml

---
- hosts: all
  become: true
  tasks:

    - name: create simone user
      tags: always
      user:
        name: simone
        groups: root

    - name: add ssh-key for simone
      tags: always
      authorized_key:
         user: simone
         key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3inf5BR5TmRphZZMvwuT8J4VpRYSQZUExa0grred51 ansible"

    - name: add sudoers file for simone
      tags: always
      copy:
        src: sudoer_simone
        dest: /etc/sudoers.d/simone
        owner: root
        group: root
        mode: 0440




# create
nano sudoer_simone
#sudoer_simone
simone ALL=(ALL) NOPASSWD: ALL

# dann mit sudo rechten direkt einloggen auf dem Server ohne passwort

ssh -i ~/.ssh/ansible simone@192.168.178.71
```



### ansible.cfg improven ohne become passwort playbook starten


[defaults]
inventory = inventory
private_key_file = ~/.ssh/ansible
remote_user = simone




### Creating initial configuration for a fresh server

#bootstrap.yml


---
- hosts: all
  become: true
  pre_tasks:
    - name: install updates (CentOS)
      tags: always
      dnf:
        update_cache: yes
      changed_when: false  
      when: ansible_distribution == "CentOS"

    - name: install updates (Ubuntu)
      tags: always
      apt:
        update_cache: yes
      changed_when: false    
      when: ansible_distribution == "Ubuntu"


# das als placeholder behalten in site.yml
# falls man neuen key hinzufügt oder ändert
# als state: absent, falls er mal kompromittiert wird oder so


- hosts: all
  become: true
  tasks:

    - name: create simone user
      tags: always
      user:
        name: simone
        groups: root

    - name: add ssh-key for simone
      tags: always
      authorized_key:
         user: simone
         key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3inf5BR5TmRphZZMvwuT8J4VpRYSQZUExa0grred51 ansible"






# SemaphoreUI



# create a system user for semaphore
sudo adduser --system --group --home /home/semaphore semaphore


create a database
semaphore needs a database server

sudo apt update
sudo apt upgrade

# maruadb installieren
sudo apt install mariadb-server

# testen ob die db läuft
systemctl status mariadb

#get on the mariadb shell
sudo mariadb


# more secure yes, but not secure
sudo mysql_secure_installation

#no password given for now
# no to unix_socket

#new root password for the db (passwortdb)
# remove anonymous user, enter to yes
# login remotely enter for YES
# remove test database and acces to it, enter for yes
# remove privileg enter for yes



#### MariaDB Starten und Datenbank erstellen



sudo mariadb


# in mariadb
CREATE DATABASE semaphore_db;

SHOW DATABASES;


GRANT ALL PRIVILEGES ON semaphore_db.* TO semaphore_user@localhost IDENTIFIED BY 'passwortuser';

FLUSH PRIVILEGES;


### Install Semaphore

# https://github.com/semaphoreui/semaphore/releases
#get the latest with link
#copy latest linkadress from github

#for Ubuntu 24.04 LTS 
#https://git.hub.com/semaphoreui/semaphore/releases/download/v2.10.7/semaphore_2.10.7_linux_amd64.deb


# Debian und Ubuntu 22.02 LTS
wget https://github.com/semaphoreui/semaphore/releases/download/v2.10.7/semaphore_2.10.7_linux_386.deb

# Ubuntu 24.04 LTS
wget https://github.com/semaphoreui/semaphore/releases/download/v2.10.7/semaphore_2.10.7_linux_amd64.deb


ls -l

sudo apt install ./semaphore_2.10.7_linux_386.deb




sudo semaphore setup

# 1 for mysql

# hostname default

# User = semaphore_user

# password = passwortuser

# db Name = semaphore_db

# default path

# no url

# no email alerts no own mail server
# no no no

#username janina
#email janina@ansible.com



nano config.json

# all db configuration

# remove the downloaded file
rm semaphore_2.9..... file


# user:group
sudo chown semaphore:semaphore config.json


# directory erstellen
sudo mkdir /etc/semaphore

# change ownership
sudo chown semaphore:semaphore /etc/semaphore

# config.json verschieben
sudo mv config.json /etc/semaphore/

# nachgucken im directory
ls -l /etc/semaphore



sudo apt install ansible


#### Run Semaphore


# als test starten mit der config datei
semaphore server --config /etc/semaphore/config.json



## Creating a Systemd service


#https://docs.ansible-semaphore.com/

#Creating a [Systemd](https://www.learnlinux.tv/systemd-deep-dive-a-complete-easy-to-understand-guide-for-everyone/) service will faciliate setting up Semaphore to run each time the server itself restarts. To create a Systemd service file for Semaphore, we will run the following command:


sudo nano /etc/systemd/system/semaphore.service


#Inside that file, we’ll add the following:
#instructions for semaphore server

[Unit]
Description=Ansible Semaphore
Documentation=https://docs.ansible-semaphore.com/
Wants=network-online.target
After=network-online.target
ConditionPathExists=/usr/bin/semaphore
ConditionPathExists=/etc/semaphore/config.json

[Service]
ExecStart=/usr/bin/semaphore server --config /etc/semaphore/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10s
User=semaphore
Group=semaphore

[Install]
WantedBy=multi-user.target

#refresh systemd with the new service file


sudo systemctl daemon-reload

# status nachgucken
systemctl status semaphore.service

# it tells its disabled and not running

#And then we’ll enable Semaphore:

sudo systemctl enable semaphore.service

# status nochmal nachgucken
systemctl status semaphore.service

# jetzt ist es enabled, aber läuft noch nicht
#And to start Semaphore, we’ll run the following command:

sudo systemctl start semaphore.service

# status nochmal nachgucken
systemctl status semaphore.service

# dann läuft es


### create SuperUser rights on Hosts




# on hosts
sudo su

cd /etc/sudoers.d
l

# create a new user
nano janina
# in der datei den user anlegen den man mit semaphore dann nutzen will
janina ALL=(ALL) NOPASSWD: ALL

# save ctrl+o  ctrl+x

# permisson angucken
ls -l

# change permission on that file
chmod 440 janina


# copy the key to the server

ssh-copy-id -i ~/.ssh/id_rsa.pub janina@192.168.178.71
```


### setting up proxy etc

sudo apt install nginx


# status nginx
systemctl status nginx

# nginx stoppen für die konfiguration
sudo systemctl stop nginx

# in das directory gehen
cd /etc/nginx

# files dort angucken
ls

# default nginx config file
cd sites-available/
ls
cat default

# ein backup von dem file erstellen
sudo mv default default.bak

# go to
cd /etc/nginx/sites-enabled
ls -l
# default file is rot weil anderes file weg

# file löschen in sites-enabled
sudo rm default
ls
# go back to sites-available
cd /etc/nginx/sites-available

# create a configfile for semphore in sites-availbale
sudo nano semaphore.conf

server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name semaphore.ansible.de;
    location / {
        proxy_cache_bypass $http_upgrade;
        proxy_http_version 1.1;
        proxy_pass http://localhost:3000;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
   }
}



# nginx wieder starten
sudo systemctl restart nginx

# status checken
sudo systemctl status nginx
# its active and running








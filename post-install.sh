#!/bin/bash

LOG="$HOME/post_install.log"
echo "Starting post-install at $(date)" | tee -a "$LOG"

# APT system update and upgrade – Ausgabe ins Terminal, nur Fehler ins Log
echo "[APT] Updating and upgrading system"
sudo apt update -y 2>>"$LOG"
sudo apt upgrade -y 2>>"$LOG"

# Snap packages (standard confinement)
snaps=(
  spotify
  telegram-desktop
  signal-desktop
  thunderbird
  obs-studio
  vlc
  steam
  zerotier
  joplin
  zotero-snap
  zoom-client
  brave
)

# Snap packages requiring --classic
classic_snaps=(
  obsidian
  code
  android-studio
)

# Install regular snaps
for app in "${snaps[@]}"; do
  if snap list | grep -q "^$app\\s"; then
    echo "[SNAP] $app already installed" | tee -a "$LOG"
  else
    echo "[SNAP] Installing $app" | tee -a "$LOG"
    sudo snap install "$app" 1>/dev/null 2>>"$LOG"
  fi
done

# Install classic snaps
for app in "${classic_snaps[@]}"; do
  if snap list | grep -q "^$app\\s"; then
    echo "[SNAP] $app already installed" | tee -a "$LOG"
  else
    echo "[SNAP] Installing $app (classic)" | tee -a "$LOG"
    sudo snap install "$app" --classic 1>/dev/null 2>>"$LOG"
  fi
done

# APT packages
apt_pkgs=(
  curl
  vim
  git
  htop
  python3-pip
  usb-creator-gtk
)

for pkg in "${apt_pkgs[@]}"; do
  if dpkg -l | grep -q "^ii\\s*$pkg\\s"; then
    echo "[APT] $pkg already installed" | tee -a "$LOG"
  else
    echo "[APT] Installing $pkg" | tee -a "$LOG"
    sudo apt install -y "$pkg" 1>/dev/null 2>>"$LOG"
  fi
done

# Add qBittorrent PPA and install
echo "[REPO] Adding qBittorrent PPA" | tee -a "$LOG"
sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y 1>/dev/null 2>>"$LOG"
sudo apt update -y 1>/dev/null 2>>"$LOG"
sudo apt install -y qbittorrent 1>/dev/null 2>>"$LOG"

# Unity repo
echo "[REPO] Adding Unity" | tee -a "$LOG"
wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/unity.gpg > /dev/null 2>>"$LOG"
echo "deb [signed-by=/usr/share/keyrings/unity.gpg] https://hub.unity3d.com/linux/repos/deb stable main" | sudo tee /etc/apt/sources.list.d/unityhub.list > /dev/null 2>>"$LOG"

# Docker repo
echo "[REPO] Adding Docker" | tee -a "$LOG"
sudo install -m 0755 -d /etc/apt/keyrings 1>/dev/null 2>>"$LOG"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null 2>>"$LOG"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>>"$LOG"

# Anydesk repo
echo "[REPO] Adding Anydesk" | tee -a "$LOG"
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/anydesk.gpg > /dev/null 2>>"$LOG"
echo "deb [signed-by=/usr/share/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list > /dev/null 2>>"$LOG"

# Final update and installs
echo "[APT] Installing docker-ce, unityhub, anydesk" | tee -a "$LOG"
sudo apt update -y 1>/dev/null 2>>"$LOG"
sudo apt install -y docker-ce docker-ce-cli unityhub anydesk 1>/dev/null 2>>"$LOG"

# Miniconda install
echo "[INSTALL] Installing Miniconda" | tee -a "$LOG"
wget -qO ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>>"$LOG"
bash ~/miniconda.sh -b 1>/dev/null 2>>"$LOG"
~/miniconda3/bin/conda init --all 1>/dev/null 2>>"$LOG"
rm ~/miniconda.sh

# Cleanup
echo "[CLEANUP] Removing APT cache and unnecessary packages" | tee -a "$LOG"
sudo apt autoremove -y 1>/dev/null 2>>"$LOG"
sudo apt clean 1>/dev/null 2>>"$LOG"
rm -f ~/miniconda.sh >>"$LOG" 2>&1 || true

echo "Post-install complete at $(date)" | tee -a "$LOG"

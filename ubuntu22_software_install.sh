#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Brave Browser
sudo apt install apt-transport-https curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y

# Install Wine
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
sudo apt update
sudo apt install --install-recommends winehq-stable -y

# Install Git
sudo apt install git -y

# Install Docker
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Install Neofetch
sudo apt install neofetch -y

# Install Visual Studio Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y

# Install OBS Studio
sudo apt install ffmpeg -y
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update
sudo apt install obs-studio -y

# Install Adobe Reader
sudo apt install gdebi-core wget -y
wget ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb
sudo gdebi AdbeRdr9.5.5-1_i386linux_enu.deb

# Install QGroundControl
sudo apt remove modemmanager -y
sudo add-apt-repository universe
sudo apt update
wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage
chmod +x QGroundControl.AppImage
sudo mv QGroundControl.AppImage /usr/local/bin/qgroundcontrol

# Install Steam
sudo apt install steam -y

# Install Kdenlive
sudo add-apt-repository ppa:kdenlive/kdenlive-stable -y
sudo apt update
sudo apt install kdenlive -y

# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update
sudo apt install spotify-client -y

# Install Zoom
wget -O zoom.deb https://zoom.us/client/latest/zoom_amd64.deb
sudo apt install ./zoom.deb -y
rm zoom.deb

# Install xclip
sudo apt install xclip

echo "Installation of all software completed successfully!"


#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Brave Browser
sudo apt install apt-transport-https curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y

# Need to install google chrome manually

sudo apt install -y \
  build-essential \
  cmake \
  git \
  htop \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest \
  python3-setuptools \
  python3-vcstool \
  wget \
  libbullet-dev \
  python3-rosdep \
  python3-argcomplete \
  python3-empy \
  python3-netifaces \
  python3-yaml \
  python-is-python3 \
  libqt5webkit5

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

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

# Install QGroundControl
sudo usermod -aG dialout "$(id -un)"
sudo apt remove modemmanager -y
sudo apt remove --purge modemmanager
sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y
sudo apt install libfuse2 -y
sudo apt install libxcb-xinerama0 libxkbcommon-x11-0 libxcb-cursor-dev -y
sudo apt update
wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage
chmod +x QGroundControl-x86_64.AppImage
sudo mv QGroundControl-x86_64.AppImage QGroundControl.AppImage

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

# Install nordvpn
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui
sudo groupadd nordvpn
sudo usermod -aG nordvpn $USER

# Install foxglove
wget https://get.foxglove.dev/desktop/latest/foxglove-studio-latest-linux-amd64.deb
sudo apt install ./foxglove-studio-*.deb
sudo apt update && sudo apt install foxglove-studio

# Install global protect VPN
wget https://terpware.umd.edu/Deliverables/401/Download
sudo dpkg -i GlobalProtect*.deb

# Install xclip
sudo apt install xclip -y

### Install ROS 2 Humble desktop full
# Setup locale
sudo apt install locales -y
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Setup sources
sudo apt install software-properties-common -y
sudo add-apt-repository universe
sudo apt update


# Add the ROS 2 GPG key
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Add the ROS 2 repository
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list'

# Install development tools and ROS tools
sudo apt update

# Install ROS 2 Humble desktop
sudo apt update
sudo apt install ros-humble-desktop -y

# Source the setup script
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Install and initialize rosdep
sudo apt install python3-rosdep -y
sudo rosdep init
rosdep update

echo "ROS 2 Humble Desktop Full installation completed successfully!"

# Install MAVROS and dependencies
sudo apt update
sudo apt install ros-humble-visualization-msgs ros-humble-vision-msgs -y
wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
sudo ./install_geographiclib_datasets.sh
rm install_geographiclib_datasets.sh

sudo apt-get install ros-humble-mavros ros-humble-mavros-extras ros-humble-mavros-msgs -y

# Cleanup and sourcing
sudo apt update
sudo apt autoremove
source ~/.bashrc

git config --global user.email "muditsingal@gmail.com"
git config --global user.name "Mudit Singal"

echo "Installation of all software completed successfully!"

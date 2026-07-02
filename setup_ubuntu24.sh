#!/usr/bin/env bash
# setup_ubuntu24.sh
#
# Rebuilds the software environment from the old Ubuntu 22.04 (Jammy) /
# ROS2 Humble machine onto a fresh Ubuntu 24.04 (Noble) install / ROS2 Jazzy.
#
# PRECONDITION: NVIDIA driver already installed manually (ubuntu-drivers
# autoinstall or equivalent), system rebooted, `nvidia-smi` confirmed working.
# This script does NOT touch the NVIDIA driver.
#
# Run as your normal user (not root) — it calls sudo where needed.
# Each phase is a function; comment out a call at the bottom to skip it.

set -euo pipefail

log() { echo -e "\n==> $*\n"; }

# =============================================================================
# Phase 0 — Base system prep
# =============================================================================
phase0_base() {
  log "Phase 0: base system update + prerequisites"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y curl wget gpg ca-certificates software-properties-common \
    apt-transport-https gnupg2

  sudo apt install -y locales
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
  sudo add-apt-repository universe -y
}

# =============================================================================
# Phase 1 — Third-party repos & keys (fetched fresh — see prior conversation
# on why we don't copy raw keyrings from the old machine)
# =============================================================================
phase1_repos() {
  log "Phase 1: adding third-party repositories"

  log "  -> Brave browser"
  curl -fsS https://dl.brave.com/install.sh | sh

  log "  -> Google Chrome (self-registers its own apt repo on install)"
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    -o /tmp/google-chrome-stable.deb
  sudo apt install -y /tmp/google-chrome-stable.deb

  log "  -> Docker CE"
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  log "  -> NVIDIA Container Toolkit (driver itself already installed)"
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

  log "  -> Foxglove Studio"
  # NOTE: verify this is still the current release URL at https://foxglove.dev/download
  # before running — Foxglove ships as a .deb that self-registers its own repo on install.
  FOXGLOVE_DEB_URL="https://get.foxglove.dev/desktop/latest/foxglove-studio-latest-linux-amd64.deb"
  curl -fsSL "$FOXGLOVE_DEB_URL" -o /tmp/foxglove-studio.deb
  sudo apt install -y /tmp/foxglove-studio.deb

  log "  -> Tailscale (not on the old machine — added fresh per your request)"
  curl -fsSL https://tailscale.com/install.sh | sh

  log "  -> sqlitebrowser PPA (codename auto-detected — was pinned to jammy before)"
  sudo add-apt-repository -y ppa:linuxgndu/sqlitebrowser

  log "  -> ROS2 Jazzy apt source (official ros2-apt-source method)"
  ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
    | grep -F "tag_name" | awk -F'"' '{print $4}')
  curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
  sudo dpkg -i /tmp/ros2-apt-source.deb

  sudo apt update
}

# =============================================================================
# Phase 2 — Bulk apt install (filtered from apt-manual.txt)
# =============================================================================
phase2_packages() {
  log "Phase 2: installing packages"
  sudo dpkg --configure -a
  sudo apt update

  log "  -> General tools, media, fonts, GStreamer"
  sudo apt install -y \
    bash-completion chrony git htop iftop kdenlive meson net-tools neofetch \
    picocom sqlitebrowser tree ufw v4l-utils vainfo vlc xclip \
    fonts-indic hyphen-en-us mythes-en-us i965-va-driver intel-media-va-driver \
    ubuntu-restricted-addons \
    gir1.2-gst-rtsp-server-1.0 libgstrtspserver-1.0-0 \
    gstreamer1.0-alsa gstreamer1.0-libav gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools gstreamer1.0-vaapi \
    libzmq3-dev libflashrom1 libftdi1-2 libfuse2 \
    python3-gi python3-pip python3-tk python3-venv python-is-python3 \
    globalprotect

  # NOTE: on the old (Humble/Fortress) machine these were libgz-transport11-*
  # dev headers, used for building against Gazebo Transport directly. Jazzy
  # pairs with Gazebo Harmonic, which ros-jazzy-ros-gz vendors internally —
  # you likely don't need standalone gz-transport dev headers at all anymore.
  # If you do (e.g. a custom gz-transport plugin), confirm the correct
  # version for Harmonic (likely libgz-transport13-*) and add it here:
  # sudo apt install -y libgz-transport13-core-dev libgz-transport13-dev \
  #   libgz-transport13-log-dev libgz-transport13-parameters-dev

  log "  -> Docker"
  sudo apt install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    docker-ce-rootless-extras docker-compose-plugin docker-model-plugin
  sudo usermod -aG docker "$USER"

  log "  -> NVIDIA Container Toolkit"
  sudo apt install -y nvidia-container-toolkit nvidia-container-toolkit-base \
    libnvidia-container1 libnvidia-container-tools
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker

  log "  -> ROS2 Jazzy"
  sudo apt install -y ros-dev-tools
  sudo apt install -y \
    ros-jazzy-desktop \
    ros-jazzy-camera-calibration \
    ros-jazzy-foxglove-bridge \
    ros-jazzy-mavros \
    ros-jazzy-mavros-extras \
    ros-jazzy-mavros-msgs \
    ros-jazzy-rosbag2-storage-mcap \
    ros-jazzy-rosbridge-server \
    ros-jazzy-ros-gz \
    ros-jazzy-usb-cam \
    ros-jazzy-vision-msgs \
    ros-jazzy-visualization-msgs \
    python3-colcon-common-extensions

  if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
  fi

  log "  -> MAVROS GeographicLib datasets (mavros_node won't start without these)"
  curl -fsSL -o /tmp/install_geographiclib_datasets.sh \
    https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
  sudo bash /tmp/install_geographiclib_datasets.sh
}

# =============================================================================
# Phase 3 — Manual / non-apt installs
# =============================================================================
phase3_manual() {
  log "Phase 3: mavlink-router (built from source — not an apt package)"
  sudo apt install -y git meson ninja-build pkg-config gcc g++ systemd systemd-dev

  MAVLINK_ROUTER_DIR="$HOME/src/mavlink-router"
  mkdir -p "$(dirname "$MAVLINK_ROUTER_DIR")"
  if [ ! -d "$MAVLINK_ROUTER_DIR" ]; then
    git clone https://github.com/mavlink-router/mavlink-router.git "$MAVLINK_ROUTER_DIR"
  fi
  cd "$MAVLINK_ROUTER_DIR"
  git submodule update --init --recursive
  meson setup build .
  ninja -C build
  sudo ninja -C build install
  sudo systemctl daemon-reload
  sudo systemctl enable mavlink-router
  cd - > /dev/null

  echo "NOTE: mavlink-router needs /etc/mavlink-router/main.conf — this was"
  echo "custom on your old machine and wasn't in the backup. Recreate it"
  echo "before starting the service: sudo systemctl start mavlink-router"
}

# =============================================================================
# Phase 4 — Python environment (pyenv + venv, not system Python this time)
# =============================================================================
phase4_python() {
  log "Phase 4: Python environment"

  sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

  if [ ! -d "$HOME/.pyenv" ]; then
    curl -fsSL https://pyenv.run | bash
  fi
  {
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init -)"'
  } >> ~/.bashrc

  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  PYENV_PY_VERSION="3.12.8"
  pyenv install -s "$PYENV_PY_VERSION"

  VENV_DIR="$HOME/venvs/ml"
  mkdir -p "$HOME/venvs"
  "$PYENV_ROOT/versions/$PYENV_PY_VERSION/bin/python" -m venv "$VENV_DIR"
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"

  log "  -> Installing the real pip extras (ROS-provided packages excluded —"
  log "     ros-jazzy-desktop already brings rclpy, ament-*, colcon-*, etc.)"
  pip install --upgrade pip
  pip install \
    torch torchvision \
    ultralytics ultralytics-thop \
    opencv-python \
    onnx onnxruntime-gpu onnxslim \
    tensorrt-cu12 tensorrt-cu12-bindings tensorrt-cu12-libs \
    cuda-bindings cuda-pathfinder \
    sahi \
    symforce symforce-sym \
    pymap3d pybboxes pycocotools \
    plotly polars contourpy ml_dtypes \
    matplotlib scipy pandas numpy \
    ruff staticmap

  deactivate

  echo "NOTE: activate this venv with: source ~/venvs/ml/bin/activate"
}

# =============================================================================
# Phase 5 — Snap apps (curated — base/runtime snaps are pulled in automatically)
# =============================================================================
phase5_snaps() {
  log "Phase 5: snap apps"
  sudo snap install spotify
  sudo snap install acrordrdc

  log "  -> VS Code (via official apt repo instead of snap)"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  rm -f /tmp/packages.microsoft.gpg
  sudo apt update
  sudo apt install -y code
}

# =============================================================================
# Phase 6 — VS Code extensions
# =============================================================================
phase6_vscode_extensions() {
  log "Phase 6: VS Code extensions"
  local extensions=(
    anthropic.claude-code
    eamodio.gitlens
    formulahendry.code-runner
    ms-azuretools.vscode-containers
    ms-azuretools.vscode-docker
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    ms-python.vscode-python-envs
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-toolsai.vscode-jupyter-cell-tags
    ms-toolsai.vscode-jupyter-slideshow
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode.cmake-tools
    ms-vscode.cpp-devtools
    ms-vscode.cpptools
    ms-vscode.cpptools-extension-pack
    ms-vscode.cpptools-themes
    ms-vscode.remote-explorer
  )
  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" || echo "  ! failed: $ext (continuing)"
  done
}

# =============================================================================
# Phase 7 — Sanity checks
# =============================================================================
phase7_checks() {
  log "Phase 7: sanity checks"
  echo "--- nvidia-smi ---"
  nvidia-smi || echo "  ! nvidia-smi failed — check driver install"

  echo "--- docker GPU passthrough ---"
  docker run --rm --gpus all nvidia/cuda:13.3-base-ubuntu24.04 nvidia-smi \
    || echo "  ! docker GPU passthrough failed"

  echo "--- ROS2 Jazzy ---"
  bash -lc "source /opt/ros/jazzy/setup.bash && ros2 pkg list | grep jazzy | head -5" \
    || echo "  ! ros2 pkg list check failed"

  echo "--- services ---"
  systemctl status docker chrony tailscaled ufw globalprotect --no-pager \
    || true
}

# =============================================================================
# Run all phases
# =============================================================================
phase0_base
phase1_repos
phase2_packages
phase3_manual
phase4_python
phase5_snaps
phase6_vscode_extensions
phase7_checks

log "Setup complete. Log out/in (or reboot) to pick up the docker group and .bashrc changes."

#!/usr/bin/env bash
# extract_packages.sh
# Run this on the CURRENT machine you want to back up.
# It gathers everything needed to rebuild the system on a fresh Ubuntu 24.04 install.

set -uo pipefail

OUTDIR="$HOME/system-backup-$(date +%Y%m%d)"
mkdir -p "$OUTDIR"

echo "==> Writing backup data to $OUTDIR"

# 1. Manually installed apt packages (excludes auto-pulled dependencies —
#    this is the list you actually want to reinstall, not the full dpkg dump)
apt-mark showmanual | sort > "$OUTDIR/apt-manual.txt"

# 2. Full installed package list with exact versions (reference only, useful
#    if you ever need to pin a specific version, e.g. a CUDA/driver combo)
dpkg-query -W -f='${Package}\t${Version}\n' | sort > "$OUTDIR/dpkg-all-versions.txt"

# 3. APT sources: PPAs and third-party repo URLs (ROS2, NVIDIA CUDA, Tailscale, etc.
#    almost certainly live here since they're not in the default Ubuntu archive).
#    This only copies the .list files (plain-text repo URLs), not key material —
#    the corresponding key-add commands get regenerated from each vendor's
#    official docs when building the install script, not copied from here.
mkdir -p "$OUTDIR/apt-sources"
cp /etc/apt/sources.list "$OUTDIR/apt-sources/" 2>/dev/null
cp -r /etc/apt/sources.list.d "$OUTDIR/apt-sources/" 2>/dev/null

# 4. Snap packages
if command -v snap &>/dev/null; then
    snap list > "$OUTDIR/snap-list.txt" 2>/dev/null
fi

# 5. Flatpak apps (if you use any)
if command -v flatpak &>/dev/null; then
    flatpak list --app --columns=application > "$OUTDIR/flatpak-list.txt" 2>/dev/null
fi

# 6. pyenv versions + global pip packages
if command -v pyenv &>/dev/null; then
    pyenv versions > "$OUTDIR/pyenv-versions.txt" 2>/dev/null
fi
if command -v pip3 &>/dev/null; then
    pip3 list --format=freeze > "$OUTDIR/pip-system.txt" 2>/dev/null
fi
# If you keep requirements.txt files per-venv/project, those travel with the
# project dirs themselves — this script only captures the system/pyenv level.

# 7. npm global packages
if command -v npm &>/dev/null; then
    npm list -g --depth=0 --json > "$OUTDIR/npm-global.json" 2>/dev/null
fi

# 8. Rust/cargo global installs
if command -v cargo &>/dev/null; then
    ls "$HOME/.cargo/bin" > "$OUTDIR/cargo-bin.txt" 2>/dev/null
fi

# 9. VS Code extensions
if command -v code &>/dev/null; then
    code --list-extensions > "$OUTDIR/vscode-extensions.txt" 2>/dev/null
fi

# 10. Enabled systemd services (helps flag anything custom you set up,
#     e.g. chrony/PTP config, Tailscale, custom udev/daemon units)
systemctl list-unit-files --state=enabled --no-pager > "$OUTDIR/systemd-enabled.txt" 2>/dev/null

# 11. Tailscale version (config/auth itself doesn't transfer, just a marker)
if command -v tailscale &>/dev/null; then
    tailscale version > "$OUTDIR/tailscale-version.txt" 2>/dev/null
fi

# 12. CUDA / NVIDIA driver version, since this matters a lot for Jetson/GPU work
if command -v nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=driver_version,name --format=csv > "$OUTDIR/nvidia-driver.txt" 2>/dev/null
fi
if [ -f /usr/local/cuda/version.json ]; then
    cp /usr/local/cuda/version.json "$OUTDIR/cuda-version.json" 2>/dev/null
fi

tar -czf "$OUTDIR.tar.gz" -C "$(dirname "$OUTDIR")" "$(basename "$OUTDIR")"

echo "==> Done."
echo "==> Review: $OUTDIR"
echo "==> Archive for easy transfer: $OUTDIR.tar.gz"
echo ""
echo "Next: share apt-manual.txt (and any of the others that are relevant to you)"
echo "back with me, and I'll turn it into an install script for Ubuntu 24.04."


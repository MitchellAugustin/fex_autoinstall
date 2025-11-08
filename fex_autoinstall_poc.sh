#!/bin/bash

# Usage: wget https://raw.githubusercontent.com/esullivan-nvidia/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh

# Exit immediately if a command exits with a non-zero status.
set -e

ORIG_DIR=$(pwd)

TEMP_DIR=$(mktemp -d)

cleanup() {
  cd "$ORIG_DIR"
  rm -rf "$TEMP_DIR"
  echo "Cleaned up temporary directory: $TEMP_DIR"
}

trap cleanup EXIT

cd "$TEMP_DIR"
echo "Working in temporary directory: $TEMP_DIR"

echo "Adding FEX-Emu PPA..."
sudo add-apt-repository -y ppa:fex-emu/fex
sudo apt update

echo "Installing FEX-Emu and Vulkan packages..."
sudo apt install -y fex-emu-armv8.4 fex-emu-wine patchelf mesa-vulkan-drivers

echo "Downloading required files..."
wget https://repo.steampowered.com/steam/archive/stable/steam-launcher_latest_all.deb
wget https://raw.githubusercontent.com/esullivan-nvidia/fex_autoinstall/refs/heads/main/patch_steam_for_arm64.patch
wget https://raw.githubusercontent.com/esullivan-nvidia/fex_autoinstall/refs/heads/main/fex_config_with_thunking_enabled.json

echo "Installing Steam from .deb..."
sudo apt install -y ./steam-launcher_latest_all.deb

echo "Fetching FEX RootFS..."
FEXRootFSFetcher -y -x

echo "Applying FEX config..."
mkdir -p ~/.fex-emu
mv fex_config_with_thunking_enabled.json ~/.fex-emu/Config.json
sed -i 's/Ubuntu_24_04.sqsh/Ubuntu_24_04/g' ~/.fex-emu/Config.json

echo "Configuring AppArmor..."
echo "abi <abi/4.0>,
include <tunables/global>
 
profile FEXBash /usr/bin/FEXBash flags=(unconfined) {
  userns,
 
  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/FEXBash>
}
" > FEXBash_apparmor.txt

echo "abi <abi/4.0>,
include <tunables/global>
 
profile steam /usr/bin/steam flags=(unconfined) {
  userns,
 
  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/steam>
}
" > steam_apparmor.txt


sudo mv steam_apparmor.txt /etc/apparmor.d/steam
sudo mv FEXBash_apparmor.txt /etc/apparmor.d/FEXBash

set +e
sudo apparmor_parser -Tr /etc/apparmor.d/steam
sudo apparmor_parser -Tr /etc/apparmor.d/FEXBash
set -e

echo "Installing NVIDIA NGX libs..."
nvidia_driver_version=$(cat /sys/module/nvidia/version)
wget https://download.nvidia.com/XFree86/Linux-x86_64/$nvidia_driver_version/NVIDIA-Linux-x86_64-$nvidia_driver_version.run

ubuntu=$(jq -r '.Config.RootFS' $HOME/.fex-emu/Config.json)
rootfs="$HOME/.fex-emu/RootFS/$ubuntu"
 
runfile=$(realpath ./NVIDIA-Linux-x86_64-$nvidia_driver_version.run)
runfilename=$(basename $runfile)
 
sh $runfile -x # || return -1
 
cd ${runfilename%.run}
 
# Copy NGX .dlls for DLSS support in Proton
mkdir -p $rootfs/usr/lib/x86_64-linux-gnu/nvidia/wine
cp *.dll $rootfs/usr/lib/x86_64-linux-gnu/nvidia/wine/

# The Proton script uses the location of the libGLX_nvidia.so.0 DSO to locate
# the NGX dlls. It does this by calling dlopen on the library and then obtains
# its location in the filesystem using dlinfo. Once it has the location of the
# DSO the relative offset of the NGX dlls is always the same. If libGLX_nvidia.so
# can't be successfully dlopen'd the NGX dlls will not be installed into the
# application Wine prefix.
#
# Because the proton script is using dlopen it is necessary to also have all
# of the dependencies of libGLX_nvidia.so installed as well. The safest way
# to do this is to just copy all of the library files.
#
# See find_nvidia_wine_dll_dir in https://github.com/ValveSoftware/Proton/blob/proton_10.0/proton
# for all of the details. 

# Copy 64 bit libraries
for dso in *.so.$nvidia_driver_version; do
cp -vf ./$dso $rootfs/lib/x86_64-linux-gnu/$dso
pushd $rootfs/lib/x86_64-linux-gnu >/dev/null
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
popd >/dev/null
done
 
# Copy 32 bit libraries
cd 32
for dso in *.so.$nvidia_driver_version; do
cp -vf ./$dso $rootfs/lib/i386-linux-gnu/$dso
pushd $rootfs/lib/i386-linux-gnu >/dev/null
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).0
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).1
ln -sf $dso $(echo $dso | cut -d'.' -f1-2).2
popd >/dev/null
done

echo "Patching Steam launcher to automatically invoke with FEXBash on arm64..."
sudo patch -p1 /usr/lib/steam/bin_steam.sh < patch_steam_for_arm64.patch

echo "---"
echo "Installation complete!"
echo "We recommend running sudo apt update && sudo apt upgrade to ensure everything on your host is up-to-date"
echo "---"

# wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh
SWD=$(pwd)
sudo add-apt-repository -y ppa:fex-emu/fex
sudo apt update
sudo apt install -y fex-emu-armv8.4 fex-emu-wine patchelf
wget https://repo.steampowered.com/steam/archive/stable/steam-launcher_latest_all.deb
wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/patch_steam_for_arm64.patch
sudo apt install ./steam-launcher_latest_all.deb
FEXRootFSFetcher -y -a

echo "{"Config":{"Disassemble":"0","PassManagerDumpIR":"0","HostFeatures":"0","ProfileStats":"0","TelemetryDirectory":"","OutputLog":"server","SilentLog":"1","DisableTelemetry":"0","ForceSVEWidth":"0","InjectLibSegFault":"0","GDBSymbols":"0","BlockJITNaming":"0","LibraryJITNaming":"0","GlobalJITNaming":"0","O0":"0","RootFS":"Ubuntu_24_04.sqsh","SMCChecks":"1","X87ReducedPrecision":"0","ThunkConfig":"","X87StrictReducedPrecision":"0","ABILocalFlags":"0","StallProcess":"0","SingleStep":"0","HideHypervisorBit":"0","GdbServer":"0","StartupSleep":"0","DumpIR":"no","StartupSleepProcName":"","MonoHacks":"1","DumpGPRs":"0","ServerSocketPath":"","NeedsSeccomp":"0","ExtendedVolatileMetadata":"","ParanoidTSO":"0","DISABLE_VIXL_INDIRECT_RUNTIME_CALLS":"1","VolatileMetadata":"1","ThunkGuestLibs":"\/usr\/share\/fex-emu\/GuestThunks","StrictInProcessSplitLocks":"0","ThunkHostLibs":"\/usr\/lib\/aarch64-linux-gnu\/fex-emu\/HostThunks","HalfBarrierTSOEnabled":"1","MemcpySetTSOEnabled":"0","SmallTSCScale":"1","VectorTSOEnabled":"0","MaxInst":"5000","TSOEnabled":"1","Multiblock":"1"},"ThunksDB":{"fex_thunk_test":0,"asound":0,"drm":0,"Vulkan":1,"WaylandClient":0,"GL":1}}" > ~/.fex-emu/Config.json

echo "abi <abi/4.0>,
include <tunables/global>
 
profile FEXBash /usr/bin/FEXBash flags=(unconfined) {
  userns,
 
  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/FEXBash>
}
" > FEXBash_apparmor.txt
sudo mv FEXBash_apparmor.txt /etc/apparmor.d/FEXBash
sudo apparmor_parser -Tr /etc/apparmor.d/steam
sudo apparmor_parser -Tr /etc/apparmor.d/FEXBash
cd $SWD
sudo patch -p1 /usr/lib/steam/bin_steam.sh < patch_steam_for_arm64.patch
echo "We recommend running sudo apt update && sudo apt upgrade to ensure everything on your host is up-to-date"

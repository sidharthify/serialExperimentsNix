# nixos/hardware/amd.nix

{ config, pkgs, lib, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.overdrive.enable = true;

  # amdgpu.ppfeaturemask — the bits that matter (drivers/gpu/drm/amd/amdgpu/amdgpu.h):
  #   PP_PCIE_DPM_MASK  = 0x4     (bit  2)
  #   PP_OVERDRIVE_MASK = 0x4000  (bit 14)   <- power limit + clock/voltage control
  #   PP_GFXOFF_MASK    = 0x8000  (bit 15)   <- gfx power-gating, causes clock bounce
  #   PP_STUTTER_MODE   = 0x20000 (bit 17)
  #   PP_GFX_DCS_MASK   = 0x80000 (bit 19)   <- gfx deep-clock-sleep
  #
  # The previous value here was 0xfff7bfff, documented as "disables PCIe DPM
  # (bit 14) and stutter mode (bit 19)". Both labels were wrong: bit 14 is
  # OVERDRIVE and bit 19 is GFX_DCS, so that mask silently DISABLED overdrive.
  # Effect: pp_od_clk_voltage never appeared, power1_cap was stuck at 170 W
  # (writes to it failed), and LACT's power_cap: 200 was never applied.
  #
  # 0xfff57fff = all features on, minus GFXOFF (15), STUTTER_MODE (17) and
  # GFX_DCS (19). That keeps overdrive available and still pins the clocks,
  # which was the original intent. Costs some idle power in exchange for
  # steadier boost behaviour.
  #
  # NOTE: this is a kernel parameter — it only takes effect after a reboot.
  boot.kernelParams = lib.mkAfter [
    "amdgpu.ppfeaturemask=0xfff57fff"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu ppfeaturemask=0xfff57fff
  '';

  # keep lact for fan control only, but disable its performance level management
  services.lact.enable = true;
}

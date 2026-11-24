# nixos/services/pipewire.nix

{ config, pkgs, ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;

    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate"        = 48000;
        "default.clock.quantum"     = 256;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 1024;
      };
    };

    extraConfig.pipewire."93-clean-mic" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Clean Mic (DeepFilterNet)";
            "media.name"       = "Clean Mic (DeepFilterNet)";
            "filter.graph" = {
              nodes = [
                {
                  type    = "ladspa";
                  name    = "df";
                  plugin  = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                  label   = "deep_filter_mono";
                  control = { "Attenuation Limit (dB)" = 100; };
                }
              ];
            };
            "audio.rate"     = 48000;
            "audio.position" = [ "MONO" ];
            "capture.props" = {
              "node.name"     = "capture.clean_mic";
              "node.passive"  = true;
              "target.object" = "alsa_input.usb-Generalplus_Usb_Audio_Device-00.mono-fallback";
            };
            "playback.props" = {
              "node.name"   = "clean_mic";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}

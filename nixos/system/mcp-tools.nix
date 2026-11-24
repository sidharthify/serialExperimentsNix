{ pkgs, ... }:

let
  ghidra = pkgs.ghidra-bin.overrideAttrs (_: {
    version = "12.1.4";
    versiondate = "20260921";
    dontAutoPatchelf = true;
    src = pkgs.fetchzip {
      url = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip";
      hash = "sha256-ZD4Vs1i7BMvrneAbAiOc7F9iBj64Rbom+PaVO//TzK8=";
    };
  });
in
{
  environment.etc = {
    "rea/ghidra".source = "${ghidra}/lib/ghidra";
    "rea/jdk25".source = pkgs.jdk25.home;
    "rea/node".source = pkgs.nodejs_26;
  };

  environment.systemPackages = with pkgs; [
    uv
    radare2
    clang-tools
    mcp-language-server
    github-mcp-server
    chromium
  ];
}

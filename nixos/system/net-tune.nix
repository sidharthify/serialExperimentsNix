# nixos/system/net-tune.nix

{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_base_mss" = 1024;

    # ---- ingress burst handling ----
    "net.core.netdev_max_backlog" = 16384;
    "net.core.netdev_budget" = 600;

    # ---- socket buffers sized for the real BDP ----
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 262144;
    "net.core.wmem_default" = 262144;
    "net.ipv4.tcp_rmem" = "4096 131072 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.udp_rmem_min" = 16384;
    "net.ipv4.udp_wmem_min" = 16384;

    # ---- local queueing latency ----
    "net.ipv4.tcp_notsent_lowat" = 131072;
    "net.ipv4.tcp_autocorking" = 0;

    # ---- connection setup speed ----
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_syn_retries" = 4;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.core.somaxconn" = 8192;
    "net.ipv4.ip_local_port_range" = "10240 65535";
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.ipv4.tcp_keepalive_time" = 120;
    "net.ipv4.tcp_keepalive_intvl" = 20;
    "net.ipv4.tcp_keepalive_probes" = 5;
  };

  systemd.services.nic-tune = {
    description = "Latency tuning for enp7s0 (disable pause frames + EEE)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.ethtool ];
    script = ''
      IF=enp7s0
      ethtool -A "$IF" rx off tx off || true
      ethtool --set-eee "$IF" eee off || true
      ethtool -C "$IF" rx-usecs 0 rx-frames 1 || true
    '';
  };

  environment.systemPackages = [ pkgs.ethtool ];
}

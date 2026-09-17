# nixos/system/net-tune.nix
# Ethernet/latency tuning for the Airtel fibre + OpenWrt (192.168.2.1) setup.
# Measured 2026-09-18: ~180 Mbit/s down, ~160 up, 12 ms idle RTT, ~0 bufferbloat.
# Path MTU to the internet is 1480 (PPPoE), NOT 1500 - hence tcp_mtu_probing.

{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl = {
    # ---- path MTU ----
    # PPPoE gives a 1480-byte path MTU while the NIC is 1500. If an ICMP
    # "frag needed" is ever filtered, connections would black-hole; probing
    # lets TCP discover the real MTU itself instead of stalling.
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_base_mss" = 1024;

    # ---- ingress burst handling ----
    # Realtek r8169 is single-queue with a 256-slot ring (hardware max), so the
    # softirq backlog is the only place bursts can absorb.
    "net.core.netdev_max_backlog" = 16384;
    "net.core.netdev_budget" = 600;

    # ---- socket buffers sized for the real BDP ----
    # 200 Mbit x 15 ms ~= 375 KB; 16 MB ceiling leaves room for long-RTT
    # transfers (game CDNs, overseas mirrors) without over-buffering locally.
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 262144;
    "net.core.wmem_default" = 262144;
    "net.ipv4.tcp_rmem" = "4096 131072 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    # UDP floor - helps QUIC (most of the web now) and game traffic
    "net.ipv4.udp_rmem_min" = 16384;
    "net.ipv4.udp_wmem_min" = 16384;

    # ---- local queueing latency ----
    # Cap unsent data in the socket to ~128 KB so a bulk upload can't park
    # hundreds of ms of its own data ahead of an interactive packet.
    "net.ipv4.tcp_notsent_lowat" = 131072;
    # Don't hold small writes back waiting to coalesce - costs latency.
    "net.ipv4.tcp_autocorking" = 0;

    # ---- connection setup speed ----
    "net.ipv4.tcp_fastopen" = 3;            # client + server TFO
    "net.ipv4.tcp_syn_retries" = 4;         # fail over faster than the 6 default
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.core.somaxconn" = 8192;
    "net.ipv4.ip_local_port_range" = "10240 65535";
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 15;

    # Don't carry a bad cwnd/ssthresh estimate from one congested moment
    # into every later connection to the same host.
    "net.ipv4.tcp_no_metrics_save" = 1;

    # Detect dead peers sooner without being chatty.
    "net.ipv4.tcp_keepalive_time" = 120;
    "net.ipv4.tcp_keepalive_intvl" = 20;
    "net.ipv4.tcp_keepalive_probes" = 5;
  };

  # Realtek NIC link-layer tuning.
  #   flow control (802.3x pause frames): when a buffer fills, pause frames
  #     stall EVERY flow on the link instead of dropping from the one that
  #     caused it - head-of-line blocking, felt directly as ping spikes.
  #   EEE: puts the PHY into low-power idle between packets and costs a
  #     wake-up (Tx LPI 12 us here) on the next one. Unwanted on a desktop.
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
      # tolerate a NIC that hasn't appeared yet or a firmware that refuses
      ethtool -A "$IF" rx off tx off || true
      ethtool --set-eee "$IF" eee off || true
      # keep interrupt coalescing at zero: an interrupt per packet is the
      # lowest-latency setting and this link never exceeds ~20k pps.
      ethtool -C "$IF" rx-usecs 0 rx-frames 1 || true
    '';
  };

  environment.systemPackages = [ pkgs.ethtool ];
}

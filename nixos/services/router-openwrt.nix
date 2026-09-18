# nixos/services/router-openwrt.nix
#
# Declarative-ish config for the OpenWrt router at 192.168.2.1.
#
# ---------------------------------------------------------------------------
# READ THIS FIRST: what "declarative" does and does not mean here
# ---------------------------------------------------------------------------
# The router is a separate machine running OpenWrt, not NixOS. `nixos-rebuild`
# builds a closure for THIS host and cannot converge a foreign device. So this
# module does the honest half of the job:
#
#   * the router's desired state lives here, in the flake, under version control
#   * one command - `router-sync` - pushes it, idempotently
#
# What you do NOT get is automatic convergence. Change something by hand in
# LuCI and nothing here notices or reverts it. Treat `router-sync` the way you
# treat `nixos-rebuild switch`: the config is truth, but only once you run it.
#
# ---------------------------------------------------------------------------
# Scope: this module is ADDITIVE and deliberately narrow
# ---------------------------------------------------------------------------
# It only ever writes the UCI sections named in `firewallRules` below. It never
# enumerates, rewrites, or deletes anything else. That restraint is the whole
# safety story: the router also carries a WireGuard zone (`firewall.vpnzone`),
# an `Allow-WireGuard` rule, and an `Allow-Satisfactory-v6` rule that this
# module knows nothing about, and a careless "sync = make reality match the
# file" implementation would happily delete all three. If you want those
# managed here too, add them below - don't make the script smarter.
#
# ---------------------------------------------------------------------------
# Why named UCI sections
# ---------------------------------------------------------------------------
# `uci add firewall rule` creates an ANONYMOUS section (`@rule[11]`, stored as
# `cfg1292bd`). Anonymous sections have no stable identity, so re-running a
# script that adds one gives you the rule twice, then three times. Named
# sections (`firewall.mc_ipv6`) are addressable by key, so writing one is
# naturally idempotent - `uci set` on an existing key is an update, not an
# insert. The pre-existing `allow_wg` rule already uses this pattern.
#
# The Minecraft rule was originally created anonymously (2026-09-18), so the
# sync script also clears out any ANONYMOUS rule whose `name` matches one we
# declare. Without that you'd get a duplicate the first time you run it.
#
# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------
# Key-based, using a dedicated key (~/.ssh/id_openwrt) rather than the login
# password or your personal id_rsa - a sync that needs a typed password isn't a
# sync, and a key scoped to one job is easy to revoke. The public half lives in
# /etc/dropbear/authorized_keys on the router. To rotate: ssh-keygen a new pair,
# append the new pubkey, drop the old line.
#
# There is deliberately no password anywhere in this file. Everything in the Nix
# store is world-readable.

{ config, pkgs, lib, ... }:

let
  routerHost = "192.168.2.1";
  routerUser = "root";
  sshKey     = "/home/sidharthify/.ssh/id_openwrt";

  # -------------------------------------------------------------------------
  # Desired firewall rules, keyed by UCI named-section id.
  #
  # About `dest_ip = "::529/-64"`: that NEGATIVE prefix length is a real fw4
  # feature, not a typo. It compiles to
  #     ip6 daddr & ::ffff:ffff:ffff:ffff == ::529
  # i.e. "match on the interface identifier, ignore the /64". Airtel hands out
  # the LAN prefix by DHCPv6-PD with a ~15h lifetime and it changes whenever
  # PPPoE reconnects, so a rule pinned to a full literal address would silently
  # stop matching. Matching the suffix alone means this rule never needs
  # touching. ::529 is the desktop's stable DHCPv6 suffix.
  # -------------------------------------------------------------------------
  firewallRules = {
    mc_ipv6 = {
      name      = "Allow-Minecraft-IPv6";
      src       = "wan";
      dest      = "lan";
      proto     = "tcp";
      dest_port = "25565";
      dest_ip   = "::529/-64";
      family    = "ipv6";
      target    = "ACCEPT";
    };
  };

  # Render one rule into the uci commands that create it.
  renderRule = key: opts: lib.concatStringsSep "\n" (
    [ "uci -q delete firewall.${key}" "uci set firewall.${key}=rule" ]
    ++ lib.mapAttrsToList (k: v: "uci set firewall.${key}.${k}='${v}'") opts
  );

  uciScript = lib.concatStringsSep "\n\n"
    (lib.mapAttrsToList renderRule firewallRules);

  # Names we own, used to clear anonymous leftovers of the same rule.
  ownedNames = lib.mapAttrsToList (_: r: r.name) firewallRules;

  routerSync = pkgs.writeShellScriptBin "router-sync" ''
    set -eu
    SSH="${pkgs.openssh}/bin/ssh -i ${sshKey} -o BatchMode=yes \
         -o StrictHostKeyChecking=accept-new -o ConnectTimeout=8 \
         ${routerUser}@${routerHost}"

    DRY=0
    case "''${1-}" in
      --dry-run|-n) DRY=1 ;;
      --show|-s)
        exec $SSH "uci show firewall | grep -E '\.name=' || true"
        ;;
      --help|-h)
        echo "router-sync            apply the declared router config"
        echo "router-sync --dry-run  print what would be applied, change nothing"
        echo "router-sync --show     list the firewall rules currently on the router"
        exit 0 ;;
      "") : ;;
      *) echo "unknown argument: $1 (try --help)" >&2; exit 1 ;;
    esac

    # Anonymous sections carrying a name we manage are leftovers from before
    # this module existed. Remove them so the named section is the only copy.
    CLEANUP=""
    for n in ${lib.concatStringsSep " " (map (n: "'${n}'") ownedNames)}; do
      CLEANUP="$CLEANUP
      for sec in \$(uci show firewall | grep \"\.name='$n'\" | cut -d. -f2); do
        case \"\$sec\" in
          ${lib.concatStringsSep "|" (lib.attrNames firewallRules)}) ;;
          *) echo \"  removing anonymous duplicate: firewall.\$sec ($n)\"
             uci -q delete \"firewall.\$sec\" ;;
        esac
      done"
    done

    SCRIPT="set -e
    $CLEANUP

    ${uciScript}

    uci commit firewall
    /etc/init.d/firewall reload >/dev/null 2>&1
    echo '  firewall reloaded'"

    if [ "$DRY" = 1 ]; then
      echo "--- would run on ${routerHost} ---"
      echo "$SCRIPT"
      exit 0
    fi

    echo "syncing router config to ${routerHost}..."
    echo "$SCRIPT" | $SSH sh
    echo "done. verify with: router-sync --show"
  '';
in
{
  environment.systemPackages = [ routerSync ];
}

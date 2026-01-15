{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # Sonarr
      sonarr = {
        image = "linuxserver/sonarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [
          "/mnt/sdb/sonarr/config:/config"
          "/mnt/sdb/media:/media"
          "/mnt/sdb/data/torrents:/downloads"
        ];
        extraOptions = [ "--network=host" ];
      };

      # Radarr
      radarr = {
        image = "linuxserver/radarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [
          "/mnt/sdb/radarr/config:/config"
          "/mnt/sdb/media:/media"
          "/mnt/sdb/data/torrents:/downloads"
        ];
        extraOptions = [ "--network=host" ];
      };

      # Prowlarr
      prowlarr = {
        image = "linuxserver/prowlarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [
          "/mnt/sdb/prowlarr/config:/config"
        ];
        extraOptions = [ "--network=host" ];
      };

      # Jellyfin
      jellyfin = {
        image = "linuxserver/jellyfin:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [
          "/mnt/sdb/jellyfin/config:/config"
          "/mnt/sdb/media:/media"
        ];
        extraOptions = [ "--network=host" ];
      };

      # qBittorrent (Docker)
      qbittorrent-docker = {
        image = "ghcr.io/hotio/qbittorrent:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          UMASK = "002";
          TZ = "Asia/Kolkata";
          WEBUI_PORTS = "8080/tcp,8080/udp";
        };
        volumes = [
          "/mnt/sdb/qbittorrent/config:/config"
          "/mnt/sdb/data/torrents:/downloads"
        ];
        ports = [
          "8080:8080"
          "6881:6881"
          "6881:6881/udp"
        ];
      };
    };
  };
}

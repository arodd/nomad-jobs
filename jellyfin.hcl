job "jellyfin" {
  datacenters = ["dc1"]
  type        = "service"

  group "jellyfin" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    constraint {
      attribute = "${meta.gpu_type}"
      operator  = "="
      value     = "intel"
    }
    service {
      name = "jellyfin"
      provider = "nomad"
      port = "http"
      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.jellyfin.rule=Host(`jf.domain.com`)",
        "traefik.http.routers.jellyfin.entrypoints=websecure",
        "traefik.http.routers.jellyfin.tls=true",
        "traefik.http.routers.jellyfin.tls.certresolver=domain",
        "traefik.http.routers.jellyfin.middlewares=jellyfin-mw",
        "traefik.http.middlewares.jellyfin-mw.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex",
        "traefik.http.middlewares.jellyfin-mw.headers.STSSeconds=315360000",
        "traefik.http.middlewares.jellyfin-mw.headers.STSIncludeSubdomains=true",
        "traefik.http.middlewares.jellyfin-mw.headers.STSPreload=true",
        "traefik.http.middlewares.jellyfin-mw.headers.forceSTSHeader=true",
        "traefik.http.middlewares.jellyfin-mw.headers.frameDeny=true",
        "traefik.http.middlewares.jellyfin-mw.headers.contentTypeNosniff=true",
        "traefik.http.middlewares.jellyfin-mw.headers.customresponseheaders.X-XSS-PROTECTION=1",
        "traefik.http.middlewares.jellyfin-mw.headers.customFrameOptionsValue='allow-from https://jf.domain.com'"
      ]

    }
    
    network {
      mode = "bridge"
      port "http" { to = 8096 }
    }

    task "jellyfin" {
      driver = "docker"
      #user = "jellyfin"
      #env = {
      #  "TZ" = "America/Chicago"
      #}

      config {
        image = "jellyfin/jellyfin:latest"
        #network_mode = "host"
        #runtime = "runsc"
        mounts = [
          {
            type = "bind"
            target = "/config"
            source = "/Datastore/nomad-vols/jellyfin-cfg"
            readonly = false
            bind_options = {
              propagation = "rprivate"
            }
          },
          {
            type = "bind"
            target = "/cache"
            source = "/Datastore/nomad-vols/jellyfin-cache"
            readonly = false
            bind_options = {
              propagation = "rprivate"
            }
          },
          {
            type = "bind"
            target = "/media"
            source = "/Datastore/Torrents"
            readonly = false
            bind_options = {
              propagation = "rprivate"
            }
          }
        ]
        devices = [
          {
            host_path = "/dev/dri"
            container_path = "/dev/dri"
          }
        ]
        ports = ["http"]
      }
      
      resources {
        cpu = 200
        memory = 3072
      }
    }
  }
}


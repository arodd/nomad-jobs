job "channels" {
  datacenters = ["dc1"]
  type        = "service"

  group "channels" {
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
    network {
      mode = "cni/macvlan-net"
      port "http" {
        static = "8089"
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:a0"
        }
      }
    }
    service {
      name = "channels"
      provider = "nomad"
      port = "http"
      address_mode = "alloc"
      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.channels.rule=Host(`channels.domain.com`)",
        "traefik.http.routers.channels.entrypoints=websecure",
        "traefik.http.routers.channels.tls=true",
        "traefik.http.routers.channels.tls.certresolver=domain",
        "traefik.http.routers.channels.middlewares=channels-mw",
        "traefik.http.middlewares.channels-mw.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex",
        "traefik.http.middlewares.channels-mw.headers.STSSeconds=315360000",
        "traefik.http.middlewares.channels-mw.headers.STSIncludeSubdomains=true",
        "traefik.http.middlewares.channels-mw.headers.STSPreload=true",
        "traefik.http.middlewares.channels-mw.headers.forceSTSHeader=true",
        "traefik.http.middlewares.channels-mw.headers.frameDeny=true",
        "traefik.http.middlewares.channels-mw.headers.contentTypeNosniff=true",
        "traefik.http.middlewares.channels-mw.headers.customresponseheaders.X-XSS-PROTECTION=1",
        "traefik.http.middlewares.channels-mw.headers.customFrameOptionsValue='allow-from https://channels.domain.com'"
      ]

    }

    task "channels" {
      driver = "podman"
      #user = "channels-dvr"
      #env = {
      #  "TZ" = "America/Chicago"
      #}

      config {
        image = "fancybits/channels-dvr:latest"
        #runtime = "runsc"
        volumes = [
          "/Datastore/nomad-vols/channels:/channels-dvr:rw,rprivate",
          "/Datastore/Torrents/DVR:/Datastore/Torrents/DVR:rw,rprivate"
        ]
        devices = [
          "/dev/dri:/dev/dri:rw"
        ]    
      }
      resources {
        cpu = 150
        memory = 3072
      }
    }
  }
}


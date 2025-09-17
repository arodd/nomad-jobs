job "hassio" {
  datacenters = ["dc1"]
  type        = "service"

  group "hassio" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    network {
      mode = "host" 
      port "hassio" { static = 8123 }
      #cni {
      #  args = {
      #    "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
      #    "MAC": "7e:d7:94:cc:be:ef"
      #  }
      #}
    }
    service {
      name = "hassio"
      provider = "nomad"
      port = "hassio"
      #address_mode = "alloc"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hassio.rule=Host(`hassio.domain.com`)",
        "traefik.http.routers.hassio.entrypoints=websecure",
        "traefik.http.routers.hassio.tls=true",
        "traefik.http.routers.hassio.tls.certresolver=domain",
        "traefik.http.routers.hassio.middlewares=hassio-mw",
        "traefik.http.middlewares.hassio-mw.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex",
        "traefik.http.middlewares.hassio-mw.headers.STSSeconds=315360000",
        "traefik.http.middlewares.hassio-mw.headers.STSIncludeSubdomains=true",
        "traefik.http.middlewares.hassio-mw.headers.STSPreload=true",
        "traefik.http.middlewares.hassio-mw.headers.forceSTSHeader=true",
        "traefik.http.middlewares.hassio-mw.headers.frameDeny=true",
        "traefik.http.middlewares.hassio-mw.headers.contentTypeNosniff=true",
        "traefik.http.middlewares.hassio-mw.headers.customresponseheaders.X-XSS-PROTECTION=1",
        "traefik.http.middlewares.hassio-mw.headers.customFrameOptionsValue='allow-from https://hassio.domain.com'"
      ]

    } 
    task "hassio" {
      driver = "podman"
      env = {
        "TZ" = "America/Chicago"
      }
      config {
        image = "ghcr.io/home-assistant/home-assistant:stable"
        network_mode = "host"
        security_opt = [
          "apparmor=unconfined"
        ]
        volumes = [
          "/Datastore/nomad-vols/hassio/data:/hassio-data:rw,rshared",
          "/Datastore/nomad-vols/hassio/config:/config:rw,rshared",
          "/Datastore/nomad-vols/hassio/media:/media:rw,rshared",
          "/run/dbus:/run/dbus:ro"
        ]
      }
      resources {
        cpu = 500
        memory = 4096
      }
    }
  }
}


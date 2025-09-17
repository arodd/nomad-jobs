job "grafana" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "default"

  group "grafana" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    
    network {
      mode = "bridge"
      port "http" { static = 3000 }
    }
    
    service {
      name = "grafana"
      provider = "nomad"
      port = "http"
      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.grafana.rule=Host(`grafana.internal.domain.com`)",
        "traefik.http.routers.grafana.entrypoints=internal",
        "traefik.http.routers.grafana.tls=true",
        "traefik.http.routers.grafana.tls.certresolver=domain"
      ]

    }

    task "grafana" {
      driver = "docker"
      #user = "unifi"
      env = {
        "TZ" = "America/Chicago"
      }

      config {
        image = "grafana/grafana:latest"
        ports = ["http"]
        mounts = [
          {
            type = "bind"
            target = "/var/lib/grafana"
            source = "/Datastore/nomad-vols/grafana-data"
            readonly = false
            bind_options = {
              propagation = "rprivate"
            }
          }
        ]      
      }
    resources {
      cpu = 100
      memory = 3072
    }
    }

  }
}

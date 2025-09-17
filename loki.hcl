job "loki" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "all"

  group "loki" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    
    network {
      mode = "cni/macvlan-net"
      port "http" { static = 3100 }
      port "grpc" { static = 9096 }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}"
        }
      }
    }
    
    service {
      name = "loki-http"
      provider = "nomad"
      port = "http"
      address_mode = "alloc"
      tags = ["http"]
    }
    service {
      name = "loki-grpc"
      provider = "nomad"
      port = "grpc"
      address_mode = "alloc"
      tags = ["grpc"]
    }

    task "loki" {
      driver = "podman"
      user = "nobody"
      env = {
        "TZ" = "America/Chicago"
      }

      config {
        image = "grafana/loki:3.3.2"
        args = ["-config.file=/mnt/config/loki-config.yaml"]
        volumes = [
          "/Datastore/nomad-vols/loki-cfg:/mnt/config:rw,rprivate",
          "/Datastore/nomad-vols/loki-data:/loki-data:rw,rprivate"
        ]
      }
    resources {
      cpu = 1500
      memory = 2048
    }
    }

  }
}

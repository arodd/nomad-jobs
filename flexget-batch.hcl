job "flexget-batch" {
  datacenters = ["dc1"]
  type        = "batch"
  node_pool = "arm64"
  periodic {
    cron             = "*/15 * * * * *"
    prohibit_overlap = true
  }

  group "flexget" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    
    network {
      mode = "cni/macvlan-net"
    }

    task "flexget" {
      driver = "podman"
      user = "nobody"
      env = {
        "TZ" = "America/Chicago"
      }

      config {
        image = "ghcr.io/flexget/flexget:latest"
        args = ["--logfile","/config/logs/${NOMAD_ALLOC_ID}.log","execute"]
        volumes = [
          "/Datastore/nomad-vols/flexget:/config:rw",
          "/Datastore/Torrents:/Datastore/Torrents:rw"
        ]  
      }
      resources {
        cpu = 1500
        memory = 3072
      }
    }
  }
}

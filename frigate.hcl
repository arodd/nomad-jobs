job "frigate" {
  datacenters = ["dc1"]
  type        = "service"

  group "frigate" {
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
      name = "frigate"
      provider = "nomad"
      port = "http"
      tags = [

      ]

    }
    
    network {
      mode = "cni/macvlan-net"
      port "http" { static = 8971 }
      port "rtsp" { static = 8554 }
      port "webrtc" { static = 8555 }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:01"
        }
      }
    }

    task "frigate" {
      driver = "podman"

      config {
        image = "ghcr.io/blakeblackshear/frigate:stable"
        shm_size = "512m"
        volumes = [
          "/Datastore/nomad-vols/frigate/config:/config:rw:rprivate",
          "/Datastore/nomad-vols/frigate/media:/media/frigate:rprivate",
          "/etc/localtime:/etc/localtime:ro"
        ]
        tmpfs = [
          "/tmp/cache"
        ]
        devices = [
          "/dev/dri:/dev/dri:rw"
          
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


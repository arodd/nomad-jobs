job "esphome" {
  datacenters = ["dc1"]
  node_pool = "default"
  group "esphome" {
    network {
      mode = "cni/macvlan-net"
      port "esphome" { static = 6052 }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "7e:d7:94:cc:be:ea"
        }
      }
    }
    service {
      name     = "esphome"
      port     = "esphome"
      provider = "nomad"
      address_mode = "alloc"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.esphome.rule=Host(`esphome.internal.domain.com`)",
        "traefik.http.routers.esphome.entrypoints=internal",
        "traefik.http.routers.esphome.tls=true",
        "traefik.http.routers.esphome.tls.certresolver=domain"
      ]
    } 

    task "esphome" {
      driver = "podman"

      config {
        image   = "ghcr.io/esphome/esphome"
        ports   = ["esphome"]
        cap_add = ["net_raw"]
        volumes = [
          "/Datastore/nomad-vols/esphome/config:/config:rw,rshared" 
        ]
        devices = [
          #"/dev/ttyACM0:/dev/ttyACM0:rw"
        ]
      }
      resources {
        cpu    = 100
        memory = 512
      }
    }
  }
}


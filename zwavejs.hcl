job "zwavejs" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

  group "zwavejs" {
    count = 1
    network {
      mode = "cni/macvlan-net"
      port "web" {
        static = 8091
      }
      port "websocket" {
        static = 3000
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "7e:d7:94:cc:be:aa"
        }
      }      
    }
    service {
      name = "zwave"
      provider = "nomad"
      address_mode = "alloc"
      port = "web"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.zwave.rule=Host(`zwave.internal.domain.com`)",
        "traefik.http.routers.zwave.entrypoints=internal",
        "traefik.http.routers.zwave.tls=true",
        "traefik.http.routers.zwave.tls.certresolver=domain"
      ]

    }
    task "zwavejs" {
      driver = "podman"

      config {
        image = "zwavejs/zwave-js-ui:11.3.0"
        ports = ["web", "websocket"]
        volumes = [
          "/Datastore/nomad-vols/zwavejs/data:/usr/src/app/store:rw:rprivate"
        ]
        devices = [
          "/dev/serial/by-id/usb-Nabu_Casa_ZWA-2_80B54EE5D988-if00:/dev/zwave:rw"
        ]  
      }

      resources {
        cpu    = 500
        memory = 4096
      }

      env = {
      }

    }
  }
}

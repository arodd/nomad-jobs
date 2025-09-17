job "registry" {
  datacenters = ["dc1"]
  node_pool = "arm64"
  group "registry" {
    network {
      mode = "bridge"
      port "registry" { 
        static = 5000
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}"
        }
      }
    }
    service {
      name     = "registry"
      port     = "registry"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.registry.rule=Host(`registry.internal.domain.com`)",
        "traefik.http.routers.registry.entrypoints=internal",
        "traefik.http.routers.registry.tls=true",
        "traefik.http.routers.registry.tls.certresolver=domain"      
      ]
    }
    task "registry" {
      driver = "podman"

      config {
        image = "registry:3"
        ports = ["registry"]
        volumes = [
          "/Datastore/nomad-vols/registry:/var/lib/registry:rw,rprivate"
        ]
      }
      resources {
        cpu    = 200
        memory = 2048
      }
    }
  }
}

job "minecraft-java" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "all"
  group "minecraft" {
    count = 1
    network {
      mode = "cni/macvlan-net"
      port "mc" {
        static = 25565
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}"
        }
      }
    }
    service {
      name = "minecraft-java"
      provider = "nomad"
      address_mode = "alloc"
      port = "mc"
      tags = [
        
      ]

    }
    task "mcjava" {
      driver = "podman"

      config {
        image = "itzg/minecraft-server"

        ports = ["mc"]
        volumes = [
          "/Datastore/nomad-vols/minecraft_java:/data:rw,rprivate" 
        ]
        devices = [
        ]  
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      env = {
          EULA = "TRUE"
      }

    }
  }
}

job "minecraft" {
  datacenters = ["*"]
  group "servers" {
    count = 1
    network {
      mode = "cni/macvlan-net"
      port "mcserver" {
        static = 19132
      }
      port "mcserver-v6" {
        static = 19133
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:a1"
        }
      }
    }
    service {
      name = "minecraft"
      provider = "nomad"
      port = "mcserver"
      address_mode = "alloc"
      tags = [
        "minecraft",
        "traefik.enable=true",
        "traefik.tcp.routers.minecraft.entrypoints=minecraft",
        "traefik.tcp.routers.minecraft.rule=HostSNI(`*`)",
        "traefik.tcp.routers.minecraft.service=minecraft",
        "traefik.tcp.services.minecraft.loadbalancer.server.port=19132",
        "traefik.udp.routers.minecraft.entryPoints=udp-entrypoint",
        "traefik.udp.routers.minecraft.service=minecraft",
        "traefik.udp.services.minecraft.loadbalancer.server.port=19132"
      ]

    }
    volume "minecraft-app" {
      type      = "host"
      read_only = false
      source    = "minecraft-app"
    }
    task "server" {
      kill_timeout = "300s"
      #kill_signal = "SIGTERM"
      driver = "exec"
        config {
          args = ["--", "/bin/sh", "-c", "cd /app/data && exec /app/latest/bedrock_server"]
          command = "/usr/bin/dumb-init"
       }
       env {
         LD_LIBRARY_PATH = "/app/data"
       }
       resources {
         cpu = 200
         memory = 4096
       }
       artifact {
        source      = "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.21.100.7.zip"
        destination = "/app/latest"
        headers {
          User-Agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
        }
        # options {
        #   checksum = "sha256:abd123445ds4555555555"
        # }
      }
      volume_mount {
        volume      = "minecraft-app"
        destination = "/app/data"
        read_only   = false
      }
    }
  }
}

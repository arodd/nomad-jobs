job "minecraft" {
  datacenters = ["dc1"]

  meta {
  }

  group "servers" {
    count = 1

    network {
      port "mcserver" {
        static = 19132
      }
    }

    volume "minecraft-app" {
      type      = "host"
      read_only = false
      source    = "minecraft-app"
    }

    task "vm" {
      driver = "exec"
        config {
          args = ["-c", "cd /app/data && exec /app/latest/bedrock_server"]
          command = "/bin/sh"
       }
       env {
         LD_LIBRARY_PATH = "/app/data"
       }
       resources {
         cpu = 8000
         memory = 6000
       }
       artifact {
        source      = "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.21.51.02.zip"
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

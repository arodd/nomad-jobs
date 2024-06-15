job "minecraft" {
  # Specifies the datacenter where this job should be run
  # This can be omitted and it will default to ["*"]
  datacenters = ["*"]

  meta {
    # User-defined key/value pairs that can be used in your jobs.
    # You can also use this meta block within Group and Task levels.
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "servers" {

    # Specifies the number of instances of this group that should be running.
    # Use this to scale or parallelize your job.
    # This can be omitted and it will default to 1.
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

    # Tasks are individual units of work that are run by Nomad.
    task "vm" {
      # This particular task starts a simple web server within a Docker container
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
        source      = "https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.0.03.zip"
        destination = "/app/latest"
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


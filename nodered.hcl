job "nodered" {
  datacenters = ["dc1"]
  type        = "service"

  group "nodered" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    network {
      mode = "bridge" 
      port "nodered" { static = 1880 }
    }
    service {
      name = "nodered"
      provider = "nomad"
      port = "nodered"
      tags = [

      ]

    } 
    task "nodered" {
      driver = "docker"
      env = {
        "TZ" = "America/Chicago"
      }
      config {
        image = "nodered/node-red:latest"
        mounts = [
          {
            type = "bind"
            target = "/data"
            source = "/Datastore/nomad-vols/nodered/data"
            readonly = false
            bind_options = {
              propagation = "rshared"
            }
          }
        ]  
      }
      template {
       data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
NODE_RED_CREDENTIAL_SECRET="{{ with nomadVar "nomad/jobs/nodered" }}{{ .password }}{{ end }}"
EOH
        
        destination = "secrets/file.env"
        env         = true
      }
      resources {
        cpu = 500
        memory = 2048
      }
    }
  }
}


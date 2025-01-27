job "unifi" {
  datacenters = ["dc1"]
  type        = "service"

  group "unifi" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    
    network {
      mode = "host" 
    }

    task "unifi" {
      driver = "docker"
      user = "unifi"
      env = {
        "TZ" = "America/Chicago"
      }

      config {
        image = "jacobalberty/unifi:latest"
        network_mode = "host"
        mounts = [
          {
            type = "bind"
            target = "/var/lib/unifi"
            source = "/Datastore/nomad-vols/unifi"
            readonly = false
            bind_options = {
              propagation = "rshared"
            }
          },
          {
            type = "bind"
            target = "/etc/mongodb.conf"
            source = "/Datastore/nomad-vols/unifi-cfg/mongodb.conf"
            readonly = false
            bind_options = {
              propagation = "rshared"
            }
          }
        ]      
      }
      resources {
        cpu = 1500
        memory = 1500
      }
    }
  }
}

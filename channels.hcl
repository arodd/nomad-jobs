job "channels" {
  datacenters = ["dc1"]
  type        = "service"

  group "channels" {
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

    task "channels" {
      driver = "docker"
      #user = "channels-dvr"
      #env = {
      #  "TZ" = "America/Chicago"
      #}

      config {
        image = "fancybits/channels-dvr:latest"
        network_mode = "host"
        mounts = [
          {
            type = "bind"
            target = "/channels-dvr"
            source = "/Datastore/nomad-vols/channels"
            readonly = false
            bind_options = {
              propagation = "rshared"
            }
          },
          {
            type = "bind"
            target = "/shares/DVR"
            source = "/Datastore/Torrents/DVR"
            readonly = false
            bind_options = {
              propagation = "rshared"
            }
          }
        ]
        devices = [
          {
            host_path = "/dev/dri"
            container_path = "/dev/dri"
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

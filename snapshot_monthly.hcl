job "snapshot_monthly" {
  datacenters = ["dc1"]
  type        = "batch"
  periodic {
    crons = [
      "0 0 1 * * *"
    ]
    time_zone = "America/Chicago"
    prohibit_overlap = true
  }
  group "snapshot" {
    count = 1
    volume "datastore" {
      type      = "host"
      read_only = false
      source    = "datastore"
    }
    volume "datastore-bin" {
      type      = "host"
      read_only = true
      source    = "datastore-bin"
    }
    task "snapshot" {
      driver = "exec"
  
      config {
        command = "/Datastore/bin/snapshot"
        args = ["-path=/Datastore/nomad-vols", "-monthly=12"]
    
      }
      volume_mount {
        volume      = "datastore"
        destination = "/Datastore/nomad-vols"
        read_only   = false
      }
      volume_mount {
        volume      = "datastore-bin"
        destination = "/Datastore/bin"
        read_only   = true
      }
    }
  }
}


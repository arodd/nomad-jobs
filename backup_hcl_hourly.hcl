job "backup_hcl_hourly" {
  datacenters = ["dc1"]
  type        = "batch"
  periodic {
    crons = [
      "58 * * * * *"
    ]
    time_zone = "America/Chicago"
    prohibit_overlap = true
  }
  group "nomad-backup" {
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
        command = "/Datastore/bin/backup_hcl.sh"
        work_dir = "/Datastore/nomad-vols/nomad-jobs-backup"
    
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


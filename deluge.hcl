job "deluge" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

  group "deluge" {
    count = 1
    network {
      mode = "cni/macvlan-net"
      port "web" {
        static = 8112
      }
      port "torrents" {
        static = 32750
      }
      port "client" {
        static = 58846
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:a3"
        }
      }
    }
    service {
      name = "deluge"
      provider = "nomad"
      port = "client"
      address_mode = "alloc"
      tags = [
      ]

    }
    service {
      name = "deluge-v6"
      provider = "nomad"
      port = "client"
      address_mode = "alloc_ipv6"
      tags = [
      ]

    }
    task "deluge" {
      driver = "podman"

      config {
        image = "linuxserver/deluge:latest"
        #runtime = "runsc"
        ulimit {
          nofile = "131072"
          nproc = "8192"
        }
        volumes = [
          "/Datastore/nomad-vols/deluge/config:/config:rw,rprivate",
          "/Datastore/Torrents:/Datastore/Torrents:rw,rprivate"
        ]
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      env = {    
        PUID = "1000",
        PGUID = "1000",
        UMASK = "022",
        DELUGE_LOGLEVEL = "error",
        TZ = "America/Chicago"
        
      }
    }
  }
}

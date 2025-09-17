job "matter" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

  group "matter" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    service {
      name = "matter"
      provider = "nomad"
      port = "matter"
      address_mode = "alloc"
      tags = [
      ]

    } 
    service {
      name = "thread"
      provider = "nomad"
      port = "thread"
      address_mode = "alloc"
      tags = [
      ]

    }
    network {
      mode = "cni/macvlan-router"
      port "matter" { static = 5580 }
      port "thread" { static = 8081 }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:fb"
        }
      }
    }
    task "matter" {
      driver = "podman"
      env = {
        "TZ" = "America/Chicago"
      }
      config {
        image = "ghcr.io/home-assistant-libs/python-matter-server:stable"
        security_opt = [
          "apparmor=unconfined"
        ]
        args = ["--storage-path", "/data", "--paa-root-cert-dir", "/data/credentials", "--bluetooth-adapter", "0"]
        volumes = [
          "/Datastore/nomad-vols/hassio/matter:/data:rw,rshared",
          "/run/dbus:/run/dbus:ro"
        ]
      }
      resources {
        cpu = 3000
        memory = 2048
      }
    }
    task "otbr" {
      driver = "podman"

      config {
        image = "openthread/border-router"
        volumes = [
          "/Datastore/nomad-vols/hassio/thread:/data:rw,rprivate" 
        ]
        cap_add = ["net_admin","net_raw"]
        devices = [
          "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_28d4f927a3b3ed11b3b843aca7669f5d-if00-port0:/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_28d4f927a3b3ed11b3b843aca7669f5d-if00-port0:rw",
          "/dev/net/tun:/dev/net/tun:rw"
        ]  
      }

      resources {
        cpu    = 3000
        memory = 2048
      }

      env = {
        OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_28d4f927a3b3ed11b3b843aca7669f5d-if00-port0?uart-baudrate=460800&uart-flow-control"
        OT_INFRA_IF = "eth0"
        OT_THREAD_IF = "wpan0"
        OT_LOG_LEVEL = "7"
        OT_REST_LISTEN_ADDR = "0.0.0.0"
      }

    }
  }
}


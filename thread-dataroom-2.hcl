job "thread-dataroom-2" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "default"

  group "router" {
    count = 1
    network {
      mode = "cni/macvlan-router"
      port "thread" {
        static = 8081
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "00:01:02:03:04:fa"
        }
      }
    }
    service {
      name = "thread-dataroom"
      provider = "nomad"
      port = "thread"
      address_mode = "alloc"
      tags = [
      ]

    }
    task "otbr" {
      driver = "podman"

      config {
        image = "openthread/border-router"
        volumes = [
          "/Datastore/nomad-vols/thread-dataroom/data:/data:rw,rprivate"
        ]
        cap_add = ["net_admin","net_raw"]
        devices = [
          "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_eefba3ba80c2ef119619c7138148b910-if00-port0:/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_eefba3ba80c2ef119619c7138148b910-if00-port0:rw",
          "/dev/net/tun:/dev/net/tun:rw"
        ]
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      env = {
        OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_eefba3ba80c2ef119619c7138148b910-if00-port0?uart-baudrate=460800"
        OT_INFRA_IF = "eth0"
        OT_THREAD_IF = "wpan0"
        OT_LOG_LEVEL = "7"
        OT_REST_LISTEN_ADDR = "0.0.0.0"
      }

    }
  }
}

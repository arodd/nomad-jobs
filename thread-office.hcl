job "thread-office" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

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
          "MAC": "00:01:02:03:04:fd"
        }
      }
    }
    service {
      name = "thread-office"
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
        network_mode = "host"
        volumes = [
          "/Datastore/nomad-vols/thread-office/data:/data:rw,rprivate"
        ]
        cap_add = ["net_admin","net_raw"]
        devices = [
          "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_4083c2ffa7c2ef11b71fbe138148b910-if00-port0:/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_4083c2ffa7c2ef11b71fbe138148b910-if00-port0:rw",
          "/dev/net/tun:/dev/net/tun:rw"
        ]  
      }

      resources {
        cpu    = 3000
        memory = 4096
      }

      env = {
        OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_4083c2ffa7c2ef11b71fbe138148b910-if00-port0?uart-baudrate=460800"
        OT_INFRA_IF = "eth0"
        OT_THREAD_IF = "wpan0"
        OT_LOG_LEVEL = "7"
        OT_REST_LISTEN_ADDR = "0.0.0.0"
      }

    }
  }
}

job "thread-mbr" {
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
          "MAC": "00:01:02:03:04:fc"
        }
      }
    }
    service {
      name = "thread-mbr"
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
          "/Datastore/nomad-vols/thread-mbr/data:/data:rw,rprivate"
        ]
        cap_add = ["net_admin","net_raw"]
        devices = [
          "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_e00483ef3b53ef11bc042ae0174bec31-if00-port0:/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_e00483ef3b53ef11bc042ae0174bec31-if00-port0:rw",
          "/dev/net/tun:/dev/net/tun:rw"
        ]  
      }

      resources {
        cpu    = 3000
        memory = 4096
      }

      env = {
        OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_e00483ef3b53ef11bc042ae0174bec31-if00-port0?uart-baudrate=460800"
        OT_INFRA_IF = "eth0"
        OT_THREAD_IF = "wpan0"
        OT_LOG_LEVEL = "7"
        OT_REST_LISTEN_ADDR = "0.0.0.0"
      }

    }
  }
}

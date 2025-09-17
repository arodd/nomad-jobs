job "mqtt-broker" {
  datacenters = ["dc1"]
  node_pool = "arm64"

  group "mosquitto" {
    network {
      mode = "cni/macvlan-net"
      port "mqtt" { static = 1883 }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "7e:d7:94:cc:be:ed"
        }
      }
    }

    service {
      name     = "mqtt"
      port     = "mqtt"
      provider = "nomad"
      address_mode = "alloc"
    }

    task "init-passwd" {
      driver = "podman"
      lifecycle { hook = "prestart" }
      user = "0"
      config {
        image   = "eclipse-mosquitto:2"
        command = "/bin/sh"
        args    = ["/local/init-passwd.sh"]
        volumes = [
          "/Datastore/nomad-vols/mosquitto:/mosquitto:rw,rprivate" 
        ]
      }
      template {
        destination = "local/mosquitto.conf"
        change_mode = "restart"
        data = <<-EOF
persistence true
persistence_location /mosquitto/data
log_dest file /mosquitto/log/mosquitto.log
log_timestamp true

listener 1883 0.0.0.0
allow_anonymous false
password_file /mosquitto/config/passwd
EOF
      }
      template {
        destination = "local/init-passwd.sh"
        perms       = "0755"
        data = <<EOF
#!/bin/sh
set -eu
mkdir -p /mosquitto/config
if [ -f /mosquitto/config/passwd ]; then
  mosquitto_passwd -b /mosquitto/config/passwd "$MQTT_USERNAME" "$MQTT_PASSWORD"
else
  mosquitto_passwd -b -c /mosquitto/config/passwd "$MQTT_USERNAME" "$MQTT_PASSWORD"
fi
cp /local/mosquitto.conf /mosquitto/config/mosquitto.conf
chown 1883:1883 /mosquitto/config/passwd
chmod 0700 /mosquitto/config/passwd
EOF
     }
     template {
        destination = "secrets/env"
        env         = true
        data = <<-EOT
MQTT_USERNAME={{ with nomadVar "nomad/jobs/mqtt-broker" }}{{ .mqtt_username | toJSON }}{{ end }}
MQTT_PASSWORD={{ with nomadVar "nomad/jobs/mqtt-broker" }}{{ .mqtt_password | toJSON }}{{ end }}
EOT
     }      
     resources {
       cpu    = 50
       memory = 64
     }
    }


    task "mosquitto" {
      driver = "podman"

      config {
        image   = "eclipse-mosquitto:2"
        ports   = ["mqtt"]
        command = "sh"
        args    = ["-lc", "mosquitto -c /mosquitto/config/mosquitto.conf"]
        volumes = [
          "/Datastore/nomad-vols/mosquitto:/mosquitto:rw,rprivate" 
        ]
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}


job "vector" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"
  reschedule {
    unlimited = true
    delay = "1m"
  }

  group "vector" {
    count = 1
    network {
      mode = "bridge"
      port "syslog" { static = 5140 }
    }

    service {
      name = "vector"
      port = "syslog"
      provider = "nomad"
    }

    task "vector" {
      driver = "docker"
      user = "nobody"
      config {
        image        = "timberio/vector:0.44.0-debian"
        args = ["--config", "/local/vector.toml"]
        ports = ["syslog"]
        runtime = "runsc"
      }

      template {
        data = <<EOF
[sources.source_syslog]
type = "syslog"
address = "0.0.0.0:5140"
max_length = 102_400
mode = "udp"
path = "/tmp/syslog_udp"

[sinks.sink_loki]
type = "loki"
inputs = [ "source_syslog" ]
endpoint = "http://loki-http.default.service.nomad:3100"
labels.datasource = "source_syslog"
out_of_order_action = "rewrite_timestamp"
encoding.codec = "json"

EOF

        destination = "local/vector.toml"
      }
      resources {
        cpu    = 2000
        memory = 1024
      }
    }
  }
}

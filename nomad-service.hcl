job "nomad-service" {

  datacenters = ["*"]
  type        = "system"

  group "main-group" {
    count = 1
    constraint {
      attribute = "${meta.role}"
      operator  = "="
      value     = "server"
    }  
    service {
      name = "nomad"
      provider = "nomad"
      address = "${attr.unique.network.ip-address}"
      port = 4646
      tags = [
        "http"
      ]
    }

    restart {
      attempts         = 5
      interval         = "36h"
      delay            = "5s"
      mode             = "delay"
      render_templates = false
    }

    update {
      max_parallel = 0
    }

    task "main-task" {
      driver = "exec"

      config {
        command = "/bin/bash"
        args    = ["-c", "trap 'exit 0' SIGINT; while true; do sleep 1; done"]
      }
    }
  }
}

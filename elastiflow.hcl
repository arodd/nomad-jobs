job "elastiflow" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

  group "elastiflow" {
    count = 1
    network {
      port "flows" {
        static = 9995
      }
      port "es_transport" {}
      port "es_http" {}
      port "kibana" {}
    }
    service {
      name = "elastiflow"
      provider = "nomad"
      port = "kibana"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.elastiflow.rule=Host(`elastiflow.internal.domain.com`)",
        "traefik.http.routers.elastiflow.entrypoints=internal",
        "traefik.http.routers.elastiflow.tls=true",
        "traefik.http.routers.elastiflow.tls.certresolver=domain"
      ]

    }


    task "elasticsearch" {
      driver = "docker"

      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch:9.1.2"
        ports = ["es_transport", "es_http"]
        ulimit {
          memlock = "-1"
          nofile = "131072"
          nproc = "8192"
        }
        mount {
          type = "bind"
          target = "/usr/share/elasticsearch/data"
          source = "/Datastore/nomad-vols/elasticsearch/data"
          readonly = false
          bind_options = {
            propagation = "rprivate"
          }
        }

      }

      resources {
        cpu    = 500
        memory = 4096
      }

      env = {
        "cluster.initial_master_nodes" = "es_master1"
        "indices.query.bool.max_clause_count" = "8192"
        "xpack.security.enabled" = "false"
        "node.name" = "es_master1"
        "search.max_buckets" = "250000"
        "network.bind_host" = "0.0.0.0"
        "action.destructive_requires_name" = "true"
        "ES_JAVA_OPTS" = "-Xms2g -Xmx2g"
        "cluster.name" = "elastiflow"
        "bootstrap.memory_lock" = "true"
        "http.publish_port" = "${NOMAD_PORT_es_http}"
        "transport.port" = "${NOMAD_PORT_es_transport}"
        "transport.publish_port" = "${NOMAD_PORT_es_transport}"
        "http.port" = "${NOMAD_PORT_es_http}"
      }

      # Volumes detected: /var/lib/elasticsearch:/usr/share/elasticsearch/data

    }
    task "kibana" {
      driver = "docker"

      config {
        image = "docker.elastic.co/kibana/kibana:9.1.2"
        ports = ["kibana"]
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      env {
        SERVER_HOST = "0.0.0.0"
        SERVER_PORT = "${NOMAD_PORT_kibana}"
        SERVER_MAXPAYLOADBYTES = "8388608"
        KIBANA_AUTOCOMPLETETIMEOUT = "3000"
        TELEMETRY_OPTIN = "false"
        TELEMETRY_ENABLED = "false"
        KIBANA_AUTOCOMPLETETERMINATEAFTER = "2500000"
        ELASTICSEARCH_SSL_VERIFICATIONMODE = "none"
        SERVER_NAME = "${NOMAD_GROUP_NAME}-${NOMAD_ALLOC_INDEX}"
        ELASTICSEARCH_REQUESTTIMEOUT = "132000"
        ELASTICSEARCH_SHARDTIMEOUT = "120000"
        ELASTICSEARCH_HOSTS = "http://${NOMAD_ADDR_es_http}"
        VIS_TYPE_VEGA_ENABLEEXTERNALURLS = "true"
        XPACK_MAPS_SHOWMAPVISUALIZATIONTYPES = "true"
        XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY = "ElastiFlow_0123456789_0123456789_0123456789"
      }

    }
    task "elastiflow" {
      driver = "docker"

      config {
        image = "elastiflow/flow-collector:6.4.2"
        ports = ["flows"]
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      env {
        EF_OUTPUT_ELASTICSEARCH_TIMESTAMP_SOURCE = "start"
        EF_OUTPUT_ELASTICSEARCH_INDEX_PERIOD = "rollover"
        EF_LICENSE_ACCEPTED = "true"
        EF_FLOW_SERVER_UDP_IP = "0.0.0.0"
        EF_FLOW_SERVER_UDP_PORT = "9995"
        EF_OUTPUT_ELASTICSEARCH_ENABLE = "true"
        EF_OUTPUT_ELASTICSEARCH_ECS_ENABLE = "true"
        EF_OUTPUT_ELASTICSEARCH_ADDRESSES = "${NOMAD_ADDR_es_http}"
        EF_PROCESSOR_ENRICH_IPADDR_DNS_ENABLE = "true"
        EF_PROCESSOR_ENRICH_IPADDR_DNS_NAMESERVER_IP = "10.13.0.1"
        EF_PROCESSOR_ENRICH_IPADDR_DNS_NAMESERVER_TIMEOUT = "3000"
      }

      # Volumes detected: /etc/elastiflow:/etc/elastiflow

    }
  }
}

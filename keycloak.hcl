job "keycloak" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"

  group "keycloak-group" {
    count = 1

    network {
      # Expose ports for HTTP and HTTPS.
      port "http" {
        to = 8080
      }
    }

    task "keycloak" {
      driver = "docker"

      config {
        # Use the official Keycloak Docker image.
        image = "quay.io/keycloak/keycloak:26.1.1"
        args = ["start-dev", "--hostname", "https://keycloak.domain.com"]
        ports = ["http"]
        mount {
          type = "bind"
          target = "/opt/keycloak/data/h2"
          source = "/Datastore/nomad-vols/keycloak/data"
          readonly = false
          bind_options = {
            propagation = "rshared"
          }
        }
      }


      template {
        data = <<EOH
KC_BOOTSTRAP_ADMIN_USERNAME=admin
KC_BOOTSTRAP_ADMIN_PASSWORD=admin
TEST={{ with nomadVar "nomad/jobs/keycloak" }}{{ .admin_password }}{{ end }}
PROXY_ADDRESS_FORWARDING=true
KC_PROXY_HEADERS=xforwarded
EOH
        destination = "secrets/env"
        env         = true
      }
      resources {
        cpu    = 100   # 500 MHz
        memory = 2048  # 1GB of memory
      }

      service {
        name = "keycloak"
        provider = "nomad"
        port = "http"
        tags = [
          "http",
          "traefik.enable=true",
          "traefik.http.routers.keycloak.rule=Host(`keycloak.domain.com`)",
          "traefik.http.routers.keycloak.entrypoints=websecure",
          "traefik.http.routers.keycloak.tls=true",
          "traefik.http.routers.keycloak.tls.certresolver=domain",
          "traefik.http.routers.keycloak.middlewares=keycloak-mw",
          "traefik.http.middlewares.keycloak-mw.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex",
          "traefik.http.middlewares.keycloak-mw.headers.STSSeconds=315360000",
          "traefik.http.middlewares.keycloak-mw.headers.STSIncludeSubdomains=true",
          "traefik.http.middlewares.keycloak-mw.headers.STSPreload=true",
          "traefik.http.middlewares.keycloak-mw.headers.forceSTSHeader=true",
          "traefik.http.middlewares.keycloak-mw.headers.frameDeny=true",
          "traefik.http.middlewares.keycloak-mw.headers.contentTypeNosniff=true",
          "traefik.http.middlewares.keycloak-mw.headers.customresponseheaders.X-XSS-PROTECTION=1",
          "traefik.http.middlewares.keycloak-mw.headers.customFrameOptionsValue='allow-from https://keycloak.domain.com'"
        ]
      }
    }
  }
}

job "traefik2" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"
  node_pool = "arm64"
  reschedule {
    unlimited = true
    delay = "35s"
  }

  group "traefik" {
    count = 1
    network {
      mode = "cni/macvlan-net"
      port "https" {
        static = 7443
      }
      port "internal" {
        static = 8443
      }

      port "api" {
        static = 8081
      }
      port "minecraft" {
        static = 19132
      }
      cni {
        args = {
          "NOMAD_JOB_NAME" : "${NOMAD_JOB_NAME}",
          "MAC": "7e:d7:94:cc:f6:cb"
        }
      }
    }
    service {
      name = "traefik2"
      provider = "nomad"
      address_mode = "alloc"
      port = "https"
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        port     = "api"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "podman"
      user = "nobody"
      config {
        image        = "traefik:latest"
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/Datastore/nomad-vols/traefik2:/traefik:rw"
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.websecure]
    address = ":7443"
    [entryPoints.websecure.http.tls]
      certResolver = "domain"
      [[entryPoints.websecure.http.tls.domains]]
        main = "domain.com"
    [entryPoints.minecraft]
    address = ":19132"        
    [entryPoints.internal]
    address = ":8443"
    [entryPoints.internal.http.tls]
      certResolver = "domain"
      [[entryPoints.websecure.http.tls.domains]]
        main = "internal.domain.com"
    [entryPoints.traefik]
    address = ":8081"

[api]
    dashboard = true
    insecure  = true

[log]
  filePath = "/traefik/log"
  level = "DEBUG"
# Enable Nomad provider
[providers.nomad]
    watch = true
    exposedByDefault = false
  [providers.nomad.endpoint]
    address = "unix:///secrets/api.sock"
    token = "{{ with nomadVar "nomad/jobs/traefik2" }}{{ .nomad_token }}{{ end }}"
  [providers.nomad.endpoint.tls]
    insecureSkipVerify = true
[providers.file]
  directory = "/traefik/config"
  watch = true

[tls.stores]
  [tls.stores.default.defaultGeneratedCert]
    resolver = "domain"
    [tls.stores.default.defaultGeneratedCert.domain]
      main = "domain.com"
[tls.options]
  [tls.options.default]
    sniStrict = true
    minVersion = "VersionTLS12"
    curvePreferences = [
      "secp521r1",
      "secp384r1"
    ]
    cipherSuites = [
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
      "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
    ]
    [tls.options.mintls13]
      minVersion = "VersionTLS13"
        
[certificatesResolvers.domain.acme]
  email = "austin@domain.com"
  storage = "/traefik/acme.json"
  [certificatesResolvers.domain.acme.dnsChallenge]
    provider = "cloudflare"

[experimental.plugins.google-oidc-auth-middleware]
  moduleName = "github.com/andrewkroh/google-oidc-auth-middleware"
  version = "v0.1.0"
EOF

        destination = "local/traefik.toml"
      }
      template {
  data = <<EOH
# Lines starting with a # are ignored

# Empty lines are also ignored
CF_DNS_API_TOKEN="{{ with nomadVar "nomad/jobs/traefik2" }}{{ .cloudflare_api_token }}{{ end }}"
EOH

  destination = "secrets/file.env"
  env         = true
}
      resources {
        cpu    = 2000
        memory = 1025
      }
    }
  }
}

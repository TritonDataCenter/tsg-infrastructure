job "tsg-v1" {

  type = "service"

  datacenters = ["us-east-1a"]

  group "deployment" {

    constraint {
      distinct_hosts = true
    }

    constraint {
      operator = "="
      attribute = "${meta.role}"
      value = "api-server"
    }

    update {
      health_check = "task_states"
      max_parallel = 1
      stagger      = "10s"
    }

    count = 3

    task "api" {
      driver = "exec"

      artifact {
        source = "https://github.com/joyent/triton-service-groups/releases/download/v0.2.6/triton-service-groups_0.2.6_linux_amd64.tar.gz"
      }

      env {
         "TSG_HTTP_BIND" = "${NOMAD_IP_http}"
         "TSG_TRITON_DC" = "us-east-1a"
         "TSG_TRITON_URL" = "https://us-east-1a.api.samsungcloud.io"
         "TSG_TRITON_AUTH_URL" = "https://us-east-1a.api.samsungcloud.io"
         "TSG_TRITON_WHITELIST" = "true"
         "TSG_CRDB_USER" = "root"
         "TSG_CRDB_DATABASE" = "triton"
         "TSG_CRDB_HOST" = "cockroach.svc.svctsgstg.us-east-1a.cns.scloud.host"
         "TSG_NOMAD_URL" = "nomad-server.svc.svctsgstg.us-east-1a.cns.scloud.host"
         "TSG_NOMAD_PORT" = "4646"
      }

      config {
        command = "triton-sg"
        args = [
          "agent",
          "--log-level", "DEBUG"
        ]
      }

      service {
        tags = [
          "urlprefix-/v1/tsg",
          "urlprefix-/v1/tsg/*",
          "urlprefix-/v1/tsg/*/*",
          "urlprefix-/v1/tsg/*/*/*"
        ]

        port = "http"

        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        network {
          port "http" {
             static = "3000"
          }
        }
      }
    }
  }
}

job "[[.job_name]]" {
  type = "service"
  datacenters = ["[[.dc]]"]
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
        source = "https://github.com/joyent/triton-service-groups/releases/download/v[[.api_release_version]]/triton-service-groups_[[.api_release_version]]_linux_amd64.tar.gz"
      }

      env {
        "TSG_HTTP_BIND" = "${NOMAD_IP_http}"
        "TSG_TRITON_DC" = "[[.dc]]"
        "TSG_TRITON_URL" = "[[.triton_url]]"
        "TSG_TRITON_AUTH_URL" = "[[.triton_auth_url]]"
        "TSG_TRITON_WHITELIST" = "[[.auth_whitelist]]"
        "TSG_CRDB_USER" = "[[.crdb_user]]"
        "TSG_CRDB_DATABASE" = "[[.crdb_database]]"
        "TSG_CRDB_HOST" = "[[.crdb_cns]]"
        "TSG_NOMAD_URL" = "[[.nomad_cns]]"
        "TSG_NOMAD_PORT" = "[[.nomad_port]]"
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
          "urlprefix-/[[.api_version]]/tsg",
          "urlprefix-/[[.api_version]]/tsg/*",
          "urlprefix-/[[.api_version]]/tsg/*/*",
          "urlprefix-/[[.api_version]]/tsg/*/*/*"
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

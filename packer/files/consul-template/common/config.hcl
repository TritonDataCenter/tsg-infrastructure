log_level = "info"

reload_signal = "SIGHUP"
kill_signal   = "SIGINT"

max_stale = "30s"

wait {
  min = "5s"
  max = "30s"
}

consul {
  address = "127.0.0.1:8500"

  retry {
    enabled     = true
    attempts    = 5
    backoff     = "500ms"
    max_backoff = "1m"
  }
}

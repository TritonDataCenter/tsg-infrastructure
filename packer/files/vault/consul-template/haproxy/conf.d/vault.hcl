vault {
  address     = "http://127.0.0.1:8200"
  renew_token = false

  retry {
    enabled     = true
    attempts    = 5
    backoff     = "250ms"
    max_backoff = "1m"
  }
}

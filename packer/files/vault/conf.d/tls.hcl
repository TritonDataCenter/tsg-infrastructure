listener "tcp" {
  tls_cert_file = "/mnt/vault/.tls/cert.pem"
  tls_key_file  = "/mnt/vault/.tls/key.pem"

  tls_min_version   = "tls12"
  tls_cipher_suites = "0xc02f,0xc030,0xcca8,0xc02b,0xc02c,0xcca9"

  tls_prefer_server_cipher_suites = true
}

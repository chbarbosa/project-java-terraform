output "infra_status" {
  value = {
    ambiente = upper(terraform.workspace)
    servicos = {
      for name, config in local.microservicos : 
      upper(name) => "http://localhost:${config.port}"
    }
    banco_dados = "localhost:${docker_container.db.ports[0].external}"
    s3_bucket   = aws_s3_bucket.uploads.bucket
    sqs_queue   = aws_sqs_queue.q_orders.url
  }
}
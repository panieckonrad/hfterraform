resource "aws_msk_cluster" "hf-msk" {
  cluster_name           = "hf-msk"
  kafka_version          = "2.6.2"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    ebs_volume_size = 2
    client_subnets  = [
      aws_subnet.hf-msk-subnet1-public.id,
      aws_subnet.hf-msk-subnet2-public.id
    ]
    security_groups = [aws_security_group.sg.id]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }


  tags = {
    Name    = "hf-msk",
    Pricing = "hf"
  }
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.hf-msk.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.hf-msk.bootstrap_brokers_tls
}

output "bootstrap_brokers" {
  description = "plaintext connection host:port pairs"
  value       = aws_msk_cluster.hf-msk.bootstrap_brokers
}
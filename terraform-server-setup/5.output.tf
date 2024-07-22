output "bastion_public_ip" {
  description = "The Bastion Instance Public IP"
  value       = aws_instance.bastion.public_ip
}


output "master_public_ip" {
  description = "The Master Instance Public IP"
  value       = aws_instance.master-server.public_ip
}

output "loadbalancer_public_ip" {
  description = "The Load Balancer Instance Public IP"
  value       = aws_instance.load-balancer-server.public_ip
}

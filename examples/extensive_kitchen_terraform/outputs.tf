output "reachable_other_host_ip_address" {
  description = "The IP address of the reachable_other_host instance"
  value       = aws_instance.reachable_other_host.public_ip
}

output "remote_group_public_dns" {
  description = "The list of public DNS names of the remote_group instances"
  value       = [aws_instance.remote_group.*.public_dns]
}

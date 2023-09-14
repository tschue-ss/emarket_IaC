
## EIP1,2
output "public_ip" {
  description = "Contains the public IP address"
  value       = [aws_eip.eip1.id, aws_eip.eip2.id]
}

## VPC_ID
output "vpc_id" {
  value = aws_vpc.terra.id
}

## Private_subnet_id
output "private_subnet_id" {
  value = [aws_subnet.private.*.id[0], aws_subnet.private.*.id[1]]
}


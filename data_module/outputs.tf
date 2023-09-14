#
# Outputs
#

## RDS(Mariadb)
output "mariadb_endpoint" {
  description = "The connection endpoint"
  value       = element(split(":", aws_db_instance.terra.endpoint),0)
}

output "mariadb_user_name" {
  description = "The master username for the database"
  value       = aws_db_instance.terra.username
}

output "mariadb_user_password" {
  description = "The master password for the database"
  value       = random_string.password.result
}


## Elasticache(Redis)
output "redis_cluster_endpoint" {
  description = "The elasticache_cluster connection endpoint url"
  value       = lookup(aws_elasticache_cluster.terra.cache_nodes[0],"address")
}

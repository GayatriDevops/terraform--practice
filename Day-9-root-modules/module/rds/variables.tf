variable "identifier" {}
variable "db_name" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "username" {}
variable "password" {
  sensitive = true
}
variable "subnet_ids" {
  type = list(string)
}
variable "parameter_group_name" {}
variable "backup_retention_period" {
  type = number
}
variable "backup_window" {}
variable "maintenance_window" {}
variable "deletion_protection" {
  type = bool
}
variable "final_snapshot_identifier" {}
variable "skip_final_snapshot" {
  type = bool
}
variable "monitoring_interval" {
  type = number
}
variable "monitoring_role_name" {}
variable "create_monitoring_role" {
  type    = bool
  default = false
}
variable "publicly_accessible" {
  type = bool
}
variable "tags" {
  type    = map(string)
  default = {}
}




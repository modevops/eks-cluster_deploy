variable "environment_name"  {
  description = "Environment in which application is being deployed"
  type = string
  default = "sandbox"
}


variable "project_name"  {
  description = "Environment in which application is being deployed"
  type = string
  default = "test"
}

variable "cluster_conf" {
  default = {
    disk_size = 200
    count = {
      desired = 3
      min = 1
      max = 3
    }
  }
}

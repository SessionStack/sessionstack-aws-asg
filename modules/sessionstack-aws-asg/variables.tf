variable "instance_type" {
  description = "Instance type used to create the SessionStack services server"
  type        = string
}

variable "instance_tags" {
  description = "Instance tags used to attach to the MongoDB server"
  type        = map(any)
  default     = {}
}

variable "associate_public_ip_address" {
  description = "Flag indicating whether the MongoDB server has a public ip address"
  type        = bool
  default     = false
}

variable "autoscalling_group_name" {
  description = "Autoscalling group name"
  type        = string
}

variable "ami" {
  description = "AMI ID used as a base to create new sessionstack instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where we want to host the instance"
  type        = string
}

variable "key_name" {
  description = "Name of keypair that will be used for logging into instance"
  type        = string
}

variable "volume_id" {
  description = "The volume used to persist the static files"
  type        = string
}

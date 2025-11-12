variable "project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for zonal cluster"
  type        = string
  default     = "us-central1-a"
}

variable "node_count" {
  description = "Number of nodes in node pool"
  type        = number
  default     = 2
}
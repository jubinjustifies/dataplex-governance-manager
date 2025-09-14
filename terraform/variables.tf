variable "project_id" {
  description = "The ID of the project where the Dataplex DataScan will be created."
  type        = string
}

variable "region" {
  description = "Region for the Dataplex DataScan."
  type        = string
}

variable "bq_table" {
  description = "BQ table on which Dataplex datascan needs to be enabled."
  type        = string
  default     = null
}

variable "dq_rules_yaml_loc" {
  description = "Quality Scan rules YAML file location."
  type        = string
  default     = null
}

variable "enable_alerting" {
  description = "Enable alerting for Dataplex scan failures."
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address or DL to receive alerts for Dataplex scan failures."
  type        = string
  default     = null
}

variable "alert_topic" {
  description = "PubSub Topic to receive alerts for Dataplex scan failures."
  type        = string
  default     = null
}

variable "alert_sub" {
  description = "PubSub Subscription to receive alerts from Topic for Dataplex scan failures."
  type        = string
  default     = null
}
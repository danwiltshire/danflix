variable "application_name" {
  description = "The application name"
  type        = string

  validation {
    condition     = length(var.application_name) > 1
    error_message = "The value must be greater than 1 characters long."
  }
}

variable "environment" {
  description = "The environment e.g. prod"
  type        = string

  validation {
    condition     = length(var.environment) > 1
    error_message = "The value must be greater than 1 characters long."
  }
}

variable "resource_prefix" {
  description = "The prefix will lead resource names"
  type        = string

  validation {
    condition     = length(var.resource_prefix) > 1
    error_message = "The value must be greater than 1 characters long."
  }
}

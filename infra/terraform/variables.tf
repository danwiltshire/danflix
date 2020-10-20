variable "application_name" {
  description = "The application name"
  type        = string

  validation {
    condition     = length(var.application_name) > 1
    error_message = "The value must be greater than 1 characters long."
  }
}

variable "aws_provider_configuration" {
  type = map(object({
    region     = string
  }))
}

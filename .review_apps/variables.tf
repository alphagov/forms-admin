variable "pull_request_number" {
  type        = number
  description = "The id of the GitHub pull request on which the review app is based"
}


variable "forms_admin_container_image" {
  type        = string
  description = "The forms-admin container image which should be deployed"
}

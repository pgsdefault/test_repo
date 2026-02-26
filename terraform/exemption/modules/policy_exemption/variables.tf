variable "scope" { type = string }
variable "policy_assignment_id" { type = string }
variable "policy_definition_reference_ids" {
  type    = list(string)
  default = []
}
variable "exemption_category" { type = string }
variable "name" { type = string }
variable "display_name" { type = string }
variable "description" {
  type    = string
  default = null
}
variable "expires_on" {
  type    = string
  default = null
}
variable "metadata" {
  type    = map(string)
  default = null
}

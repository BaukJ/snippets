variable "aws_profile_main" {
    type = string
    default = "default"
    description = "The AWS CLI profile to use for the main account"
}
variable "aws_profile_other" {
    type = string
    description = "The AWS CLI profile to use for the other account"
}

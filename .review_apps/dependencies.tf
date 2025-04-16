##
# Terraform remote state data resources are
# used to read the content of a Terraform state
# file.
#
# This is common pattern in the `forms-deploy`
# codebase, and is used to share information
# between different Terraform roots without
# having to do any external wiring of outputs
# to inputs.
#
# In this instance, we will be sharing things
# like the subnet and security groups ids that
# are necessary for deploying to AWS ECS. 
##
data "terraform_remote_state" "review" {
  backend = "s3"

  config = {
    key    = "review.tfstate"
    bucket = "gds-forms-integration-tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

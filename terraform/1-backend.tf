terraform {
  backend "s3" {
    bucket       = "codercooks-project-bucket"
    key          = "url-shortener-app/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

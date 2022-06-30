locals {

  tags = {
    created_by = "terraform"
  }

  module_path        = abspath(path.module)
  
  server_path        = abspath("${path.module}/../mvp/")
  
  deploy_path        = abspath("${path.module}/../deploy.zip")
}

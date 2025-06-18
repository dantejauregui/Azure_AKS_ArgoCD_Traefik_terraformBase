terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfdevbackend2024pidant"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
# This will create to the Blob storage created with the bash script "dev" in order to store the terraform remote backend
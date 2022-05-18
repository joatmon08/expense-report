terraform {
  backend "remote" {
    organization = "${TFC_ORGANIZATION}"

    workspaces {
      name = "${TFC_WORKSPACE}"
    }
  }
}
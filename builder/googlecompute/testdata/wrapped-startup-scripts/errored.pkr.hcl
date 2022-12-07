
variable "project" {
  type    = string
  default = "${env("GOOGLE_PROJECT_ID")}"
}

variable "service_account_file" {
  type    = string
  default = "${env("GOOGLE_APPLICATION_CREDENTIALS")}"
}

variable "ssh_private_key" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "googlecompute" "autogenerated_1" {
  account_file        = var.service_account_file
  image_name          = "packer-tester-${local.timestamp}"
  project_id          = "${var.project}"
  source_image_family = "centos-7"
  ssh_username        = "${var.ssh_username}"
  start_script_file   = "./errored.sh"
  skip_create_image   = true
  zone                = "${var.zone}"
}

build {
  sources = ["source.googlecompute.autogenerated_1"]

  provisioner "shell" {
    execute_command = "sudo -E -S sh '{{ .Path }}'"
    inline          = ["ls /var/log"]
  }

  provisioner "shell" {
    inline          = ["echo hello from the other side"]
  }
}

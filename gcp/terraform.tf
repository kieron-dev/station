variable "username" {
  type = string
}

provider "google-beta" {
  project = "cff-eirini-peace-pods"
  region = "europe-west2"
  zone = "europe-west2-a"
}

resource "google_compute_instance" "station" {
  provider = google-beta
  name = "${var.username}-eirini-station"
  machine_type = "n1-standard-8"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
      size = 100
      type = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = ""
    }
  }

  connection {
    type = "ssh"
    user = var.username
    host = self.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source = "provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "file" {
    source = "provision-user.sh"
    destination = "/tmp/provision-user.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "sudo /tmp/provision.sh",
      "chmod +x /tmp/provision-user.sh",
      "/tmp/provision-user.sh",
    ]
  }
}


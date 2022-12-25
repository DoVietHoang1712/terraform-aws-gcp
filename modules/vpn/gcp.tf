resource "google_compute_address" "static" {
  region = var.region
  name   = "external-ip-aws-customer-gateway"
}

resource "google_compute_network" "default" {
  name = var.gcp_network
}

resource "google_compute_subnetwork" "default" {
  name          = var.gcp_subnet
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.default.id
}

resource "google_compute_vpn_gateway" "vpnGw" {
  name    = var.vpn_name
  network = google_compute_network.default.id
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                    = var.tunnel_name
  peer_ip                 = aws_vpn_connection.stsvpn.tunnel1_address
  shared_secret           = aws_vpn_connection.stsvpn.tunnel1_preshared_key
  target_vpn_gateway      = google_compute_vpn_gateway.vpnGw.id
  ike_version             = 1
  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
    google_compute_vpn_gateway.vpnGw,
  ]
}

resource "google_compute_forwarding_rule" "esp" {
  name        = "${var.name}-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.static.address
  target      = google_compute_vpn_gateway.vpnGw.id
}

resource "google_compute_forwarding_rule" "udp500" {
  name        = "${var.name}-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.static.address
  target      = google_compute_vpn_gateway.vpnGw.id
}

resource "google_compute_forwarding_rule" "udp4500" {
  name        = "${var.name}-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.static.address
  target      = google_compute_vpn_gateway.vpnGw.id
}

resource "google_compute_route" "this" {
  name       = "${var.name}-route"
  network    = google_compute_network.default.name
  dest_range = var.aws_cidr_block
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}

resource "google_compute_firewall" "firewall" {
  name    = var.name
  network = google_compute_network.default.name

  allow {
    protocol = "all"
  }

  priority      = 1000
  source_ranges = [var.aws_cidr_block, "0.0.0.0/0", "192.168.3.0/24", "192.168.4.0/24"]
}

# data "google_service_account" "hoangdv" {
#   account_id = var.account_id
# }

resource "google_service_account" "hoangdv" {
  account_id   = var.account_id
  display_name = "hoangdv"
}

resource "google_project_iam_binding" "hoangdv" {
  project = var.project_id
  role    = "roles/editor"
  members = ["serviceAccount:${google_service_account.hoangdv.email}"]
}

resource "google_compute_instance" "gcp-aws" {
  name         = "gcp-aws"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20221018"
    }
  }

  # scratch_disk {
  #   interface = "SCSI"
  # }

  network_interface {
    network    = google_compute_network.default.name
    subnetwork = google_compute_subnetwork.default.name
  }

  service_account {
    email  = google_service_account.hoangdv.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_project_iam_binding.hoangdv
  ]
}

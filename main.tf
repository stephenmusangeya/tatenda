provider "google" {
  credentials = file("key.json")
  project     = "tatenda-magaisa"
  region      = "us-central1"
}

data "local_file" "app_files" {
  filename = "${path.module}/app/${each.value}"
  for_each = fileset("${path.module}/app", "**/*")
}

resource "google_storage_bucket" "bucket" {
  name     = "tatenda-magaisa" # replace with your domain
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html" # optional, replace with your custom 404 page
  }
}

resource "google_storage_bucket_object" "object" {
  for_each   = data.local_file.app_files
  name       = replace(each.value.filename, "${path.module}/app/", "")
  bucket     = google_storage_bucket.bucket.name
  source     = each.value.filename
  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    jpg  = "image/jpeg"
    png  = "image/png"
    js   = "application/javascript"
  }, lower(element(split(".", basename(each.value.filename)), length(split(".", basename(each.value.filename))) - 1)), "text/plain")
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

# Create a Global Static IP
resource "google_compute_global_address" "static_ip" {
  name = "static-ip-address"
}

# Create a backend bucket
resource "google_compute_backend_bucket" "bucket" {
  name        = "backend-bucket"
  bucket_name = google_storage_bucket.bucket.name
}

# Create a URL map to route incoming requests to the backend bucket
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_bucket.bucket.self_link
}

# Create a target HTTP proxy to route requests to the URL map
resource "google_compute_target_http_proxy" "http_proxy" {
  name   = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

# Create a global forwarding rule to handle and route incoming requests
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.static_ip.address
}

provider "google" {
  credentials = file("key.json")
  project     = "mhl-crypto"
  region      = "us-central1"
}

data "local_file" "app_files" {
  filename = "${path.module}/app/${each.value}"
  for_each = fileset("${path.module}/app", "**/*")
}

resource "google_storage_bucket" "bucket" {
  name     = "tatenda-site"
  location = "US"
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
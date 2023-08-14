# プロバイダーの選択
provider "google" {
  project   = local.project
  region    = local.region
}

# ローカル変数
locals {
  project     = "" # プロジェクト名
  region      = "asia-northeast1" # リージョン
  user_name   = "" # ここに名前でも入れて個別に識別できるようにする
}

# サービスアカウント作成
resource "google_service_account" "cloud_functions_test" {
  account_id   = "cloud-functions-test-${local.user_name}"
  description  = "cloud functions用のテストアカウント"
  display_name = "cloud-functions-test"
  project      = local.project
}

# 権限付与
resource "google_project_iam_member" "cloud_functions_test" {
  project = local.project
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_service_account.cloud_functions_test.email}"
}

# cloud storageのbucketを作成
resource "google_storage_bucket" "bucket" {
  name     = "test-${local.project}-${local.user_name}-gcf-storage" # Every bucket name must be globally unique
  location = local.region
  uniform_bucket_level_access = true
}

# cloud storageにzipを格納
resource "google_storage_bucket_object" "sample_code" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./sample_code.zip"  # Add path to the zipped function source code
}

# cloud functionsの構築
resource "google_cloudfunctions2_function" "sample" {
  name = "sample-function-${local.user_name}"
  location = local.region
  description = "test function"

  build_config {
    runtime = "python310"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.sample_code.name
      }
    }
  }

  service_config {
    max_instance_count  = 10
    min_instance_count = 1
    available_memory    = "128Mi"
    timeout_seconds     = 3600
    available_cpu = "83m"
    all_traffic_on_latest_revision = true
    service_account_email = google_service_account.cloud_functions_test.email
  }
}

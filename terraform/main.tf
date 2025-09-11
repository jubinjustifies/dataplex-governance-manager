
resource "google_logging_metric" "dataplex_scan_failures" {
  count       = 1
  name        = "dataplex_scan_failures"
  description = "Count of failed Dataplex scans"
  filter      = <<EOT
jsonPayload.@type="type.googleapis.com/google.cloud.dataplex.v1.DataScanEvent"
jsonPayload.dataQuality.score<100
  EOT
  project     = "burner-jubsharm"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

module "data_quality_scan" {
  source     = "./modules/dataplex-datascan"
  name       = "raw-customer-onboarding-quality-scan"
  prefix     = ""
  project_id = "burner-jubsharm"
  region     = "us-central1"
  labels = {
    billing_id = "a"
  }
  data = {
    resource = "//bigquery.googleapis.com/projects/burner-jubsharm/datasets/raw_dataset/tables/raw_customer_onboarding"
  }
  iam = {
    "roles/dataplex.dataScanAdmin" = [
      "serviceAccount:dataplex-admin@burner-jubsharm.iam.gserviceaccount.com"
    ],
    "roles/dataplex.dataScanEditor" = [
      "user:jubsharm@gmail.net"
    ]
  }
//  iam_by_principals = {
//    "group:user-group@example.com" = [
//      "roles/dataplex.dataScanViewer"
//    ]
//  }
//  iam_bindings_additive = {
//    am1-viewer = {
//      member = "user:am1@example.com"
//      role   = "roles/dataplex.dataScanViewer"
//    }
//  }
  factories_config = {
    data_quality_spec = "configs/quality_scan.yaml"
  }
//  execution_schedule = "0 2 * * *" # Daily at 2:00 AM
  enable_alerting    = true
  alert_email        = "jubin.sharma@gmail.com"

}



module "data_profile_scan" {
  source     = "./modules/dataplex-datascan"
  name       = "raw-customer-onboarding-profile-scan"
  prefix     = ""
  project_id = "burner-jubsharm"
  region     = "us-central1"
  labels = {
    billing_id = "a"
  }
  data = {
    resource = "//bigquery.googleapis.com/projects/burner-jubsharm/datasets/raw_dataset/tables/raw_customer_onboarding"
  }
  iam = {
    "roles/dataplex.dataScanEditor" = [
      "user:jubsharm@gmail.net"
    ],
    "roles/bigquery.dataEditor" = [
      "user:jubsharm@gmail.net"
    ]
  }
  data_profile_spec = {
    sampling_percent = 100
    post_scan_actions  = {
      bigquery_export = {
        results_table = "projects/burner-jubsharm/datasets/raw_dataset/tables/raw_customer_onboarding_profile_scan"
      }
    }
  }
//  execution_schedule = "0 2 * * *" # Daily at 2:00 AM
  enable_alerting    = true
  alert_email        = "jubin.sharma@gmail.com"
}
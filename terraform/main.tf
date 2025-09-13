resource "google_pubsub_topic" "scan_alerts_topic" {
  name    = "dataplex-scan-alerts"
  project = "burner-jubsharm"
}

resource "google_pubsub_subscription" "scan_alerts_subscription" {
  name  = "dataplex-scan-alerts-sub"
  topic = google_pubsub_topic.scan_alerts_topic.id
  project = "burner-jubsharm"

  ack_deadline_seconds = 20
}


resource "google_pubsub_topic_iam_member" "monitoring_publisher" {
  topic  = google_pubsub_topic.scan_alerts_topic.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-646776580204@gcp-sa-monitoring-notification.iam.gserviceaccount.com"
}


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
  alert_topic        = "dataplex-scan-alerts"
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
  alert_topic        = "dataplex-scan-alerts"
}
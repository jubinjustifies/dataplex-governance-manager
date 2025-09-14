resource "google_pubsub_topic" "scan_alerts_topic" {
  name    = var.alert_topic
  project = var.project_id
}

resource "google_pubsub_subscription" "scan_alerts_subscription" {
  name  = var.alert_sub
  topic = google_pubsub_topic.scan_alerts_topic.id
  project = var.project_id

  ack_deadline_seconds = 20
}


resource "google_pubsub_topic_iam_member" "monitoring_publisher" {
  topic  = google_pubsub_topic.scan_alerts_topic.name
  role   = "roles/pubsub.publisher"
  project = var.project_id
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
  project     = var.project_id
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
  project_id = var.project_id
  region     = var.region
  labels = {
    billing_id = "a"
  }
  data = {
    resource = "//bigquery.googleapis.com/${var.bq_table}"
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
    data_quality_spec = var.dq_rules_yaml_loc
  }
//  execution_schedule = "0 2 * * *" # Daily at 2:00 AM
  enable_alerting    = var.enable_alerting
  alert_email        = var.alert_email
  alert_topic        = var.alert_topic
}



module "data_profile_scan" {
  source     = "./modules/dataplex-datascan"
  name       = "raw-customer-onboarding-profile-scan"
  prefix     = ""
  project_id = var.project_id
  region     = var.region
  labels = {
    billing_id = "a"
  }
  data = {
    resource = "//bigquery.googleapis.com/${var.bq_table}"
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
        results_table = "${var.bq_table}_profile_scan"
      }
    }
  }
//  execution_schedule = "0 2 * * *" # Daily at 2:00 AM
  enable_alerting    = var.enable_alerting
  alert_email        = var.alert_email
  alert_topic        = var.alert_topic
}
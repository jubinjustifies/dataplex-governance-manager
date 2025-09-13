
//resource "google_logging_metric" "dataplex_scan_failures" {
//  count       = var.enable_alerting ? 1 : 0
//  name        = "dataplex_scan_failures"
//  description = "Count of failed Dataplex scans"
//  filter      = "resource.type=\"dataplex_datascan\" AND jsonPayload.scanResult.result=\"FAILED\""
//  project     = var.project_id
//  metric_descriptor {
//    metric_kind = "DELTA"
//    value_type  = "INT64"
//    unit        = "1"
//  }
//}

resource "google_monitoring_notification_channel" "email_alert" {
  count        = var.enable_alerting && var.alert_email != null ? 1 : 0
  display_name = "Data Quality DL"
  type         = "email"
  project      = var.project_id
  labels = {
    email_address = var.alert_email
  }
}


resource "google_pubsub_topic" "scan_alerts_topic" {
  name    = "dataplex-scan-alerts"
  project = var.project_id
}


resource "google_monitoring_notification_channel" "pubsub_alert" {
  count        = var.enable_alerting ? 1 : 0
  display_name = "Dataplex Scan PubSub Channel"
  type         = "pubsub"
  project      = var.project_id

  labels = {
    topic = google_pubsub_topic.scan_alerts_topic.id
  }
}


resource "google_pubsub_subscription" "scan_alerts_subscription" {
  name  = "dataplex-scan-alerts-sub"
  topic = google_pubsub_topic.scan_alerts_topic.name
  project = var.project_id

  ack_deadline_seconds = 20
}


resource "google_monitoring_alert_policy" "scan_failure_alert" {
  count        = var.enable_alerting ? 1 : 0
  display_name = "Dataplex Scan Failure Alert"
  combiner     = "OR"
  project      = var.project_id
//  depends_on = [google_logging_metric.dataplex_scan_failures]

  conditions {
    display_name = "Scan Failure Condition"
    condition_threshold {
//      filter          = "resource.type=\"global\" AND metric.type=\"logging.googleapis.com/user/dataplex_scan_failures\""
      filter          = "metric.type=\"logging.googleapis.com/user/dataplex_scan_failures\" AND resource.type=\"dataplex.googleapis.com/DataScan\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_COUNT"
      }
    }
  }

  notification_channels = var.enable_alerting && var.alert_email != null ? [google_monitoring_notification_channel.email_alert[0].id] : []
//  notification_channels = var.enable_alerting ? [google_monitoring_notification_channel.pubsub_alert[0].id] : []

}

//gcloud pubsub subscriptions pull dataplex-scan-alerts-sub --limit=10 --auto-ack



resource "google_monitoring_notification_channel" "email_alert" {
  count        = var.enable_alerting && var.alert_email != null ? 1 : 0
  display_name = "Data Quality DL"
  type         = "email"
  project      = var.project_id
  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_notification_channel" "pubsub_alert" {
  count        = var.enable_alerting ? 1 : 0
  display_name = "Dataplex Scan PubSub Channel"
  type         = "pubsub"
  project      = var.project_id

  labels = {
    topic = "projects/${var.project_id}/topics/${var.alert_topic}"
  }
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

  notification_channels = var.enable_alerting && var.alert_email != null ? [google_monitoring_notification_channel.email_alert[0].id, google_monitoring_notification_channel.pubsub_alert[0].id] : []

}

//gcloud pubsub subscriptions pull dataplex-scan-alerts-sub --limit=10 --auto-ack


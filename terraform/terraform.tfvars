project_id        = "burner-jubsharm"
region            = "us-central1"
bq_table          = "projects/burner-jubsharm/datasets/raw_dataset/tables/raw_customer_onboarding"
dq_rules_yaml_loc = "configs/quality_scan.yaml"
enable_alerting   = true
alert_email       = "jubin.sharma@gmail.com"
alert_topic       = "dataplex-scan-alerts"
alert_sub         = "dataplex-scan-alerts-sub"

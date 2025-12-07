let
    Source = complaints_enriched,

    #"Selected Columns" = Table.SelectColumns(
        Source,
        {
            "CASE_ID",
            "CLIENT_ID",
            "LOGGED_ON",
            "CLOSED_ON",
            "AGE_DAYS",
            "OPEN_DAYS",
            "YEAR","MONTH","QUARTER","WEEK",
            "CASE_STATUS",
            "PRODUCT_LINE",
            "INTAKE_SOURCE",
            "CHANNEL",
            "RISK_FLAG",
            "REG_TYPE",
            "DECISION_STATUS",
            "OVERALL_OUTCOME",
            "REOPEN_COUNT",
            "ACK_SLA_MET",
            "REVIEW_SLA_MET",
            "FINAL_SLA_MET",
            "VULNERABLE_FLAG",
            "FIRST_CONTACT_RESOLVED",
            "BOUNCE_FLAG",
            "GOODWILL_AMOUNT",
            "COMP_AMOUNT",
            "ADJUSTMENT_AMOUNT",
            "TOTAL_AMOUNT",
            "EXTERNAL_TOTAL_COST",
            "OWNER_ID",
            "LOGGED_BY_ID",
            "CLOSED_BY_ID"
        }
    )
in
    #"Selected Columns"
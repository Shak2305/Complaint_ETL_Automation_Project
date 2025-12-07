let
    // Parameter path
    ParamTable = Excel.CurrentWorkbook(){[Name="PARAM_PATH"]}[Content],
    FolderPath = ParamTable{0}[Column1],

    // File path
    FullPath = FolderPath & "complaints_dataset.xlsx",

    // Source load
    Source = Excel.Workbook(File.Contents(FullPath), null, true),

    // Sheet selection
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],

    // Promote headers
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),

    // Schema enforcement
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",
        {
            {"CASE_ID", type text}, {"CLIENT_ID", type text},
            {"INTAKE_SOURCE", type text}, {"PRODUCT_LINE", type text},
            {"FORM_TYPE", type text}, {"CASE_STATUS", type text},
            {"LOGGED_ON", type date}, {"RECEIVED_ON", type date},
            {"RECEIVED_ESTIMATED", type date}, {"RECEIVED_ADJUSTED", type date},
            {"CLOSED_ON", type date}, {"MERGED_FLAG", type text},
            {"REMOVED_FLAG", type text}, {"OPEN_DAYS", Int64.Type},
            {"LOGGED_BY", type text}, {"LOGGED_BY_ID", type text},
            {"OWNER_NAME", type text}, {"OWNER_ID", type text},
            {"CLOSED_BY_NAME", type text}, {"CLOSED_BY_ID", type text},
            {"REOPEN_COUNT", Int64.Type}, {"LAST_REOPEN_ON", type date},
            {"COMPLETED_ON", type date}, {"FIRST_COMPLETION_DATE", type date},
            {"ACK_DUE", type date}, {"ACK_COMPLETED", type date},
            {"ACK_OVERDUE_FLAG", type text}, {"REVIEW_DUE", type date},
            {"REVIEW_COMPLETED", type date}, {"FINAL_DUE", type date},
            {"FINAL_COMPLETED", type date}, {"FINAL_OVERDUE_FLAG", type text},
            {"RISK_FLAG", type text}, {"REG_TYPE", type text},
            {"DECISION_STATUS", type text}, {"VULNERABLE_FLAG", type text},
            {"THIRD_PARTY_FLAG", type text}, {"GOODWILL_AMOUNT", Int64.Type},
            {"COMP_AMOUNT", Int64.Type}, {"ADJUSTMENT_AMOUNT", Int64.Type},
            {"TOTAL_AMOUNT", Int64.Type}, {"INITIAL_ISSUE", type text},
            {"CATEGORY_A", type text}, {"ROOT_CAUSE_A", type text},
            {"OUTCOME_A", type text}, {"CATEGORY_B", type text},
            {"ROOT_CAUSE_B", type text}, {"OUTCOME_B", type text},
            {"CATEGORY_C", type text}, {"ROOT_CAUSE_C", type text},
            {"OUTCOME_C", type text}, {"OVERALL_OUTCOME", type text},
            {"FIRST_CONTACT_RESOLVED", type text}, {"BOUNCE_FLAG", type text},
            {"CHANNEL", type text}, {"TRANSFER_DATE", type date},
            {"TRANSFERRED_ACCOUNT_FLAG", type text}, {"EXTERNAL_REF", type text},
            {"ORIGINAL_RECORD_ID", type text}, {"COMPLAINT_ORIGIN", type text},
            {"EXTERNAL_CATEGORY", type text}, {"EXTERNAL_STATUS", type text},
            {"EXTERNAL_FILE_REQUESTED", type date}, {"EXTERNAL_FILE_DUE", type date},
            {"EXTERNAL_FILE_SUBMITTED", type date}, {"REVIEW_OUTCOME", type text},
            {"FINAL_OUTCOME_AUTHORITY", type text}, {"FINAL_DECISION_DATE", type date},
            {"REASON_FOR_CHANGE", type text}, {"EXTERNAL_CASE_OUTCOME", type text},
            {"EXTERNAL_CASE_END", type date}, {"FEE_CHARGED", Int64.Type},
            {"REFUND_AMOUNT", Int64.Type}, {"EXTERNAL_TOTAL_COST", Int64.Type},
            {"BILLING_DATE", type date}, {"BILLING_REF", type text},
            {"BILLING_AMOUNT", Int64.Type}
        }
    )
in
    #"Changed Type"

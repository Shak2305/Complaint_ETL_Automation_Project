let
    // Parameter path
    ParamTable = Excel.CurrentWorkbook(){[Name="PARAM_PATH"]}[Content],
    FolderPath = ParamTable{0}[Column1],

    // File path
    FullPath = FolderPath & "jira_dataset.xlsx",

    // Source load
    Source = Excel.Workbook(File.Contents(FullPath), null, true),

    // Sheet selection
    Sheet1_Sheet = Source{[Item="Sheet1", Kind="Sheet"]}[Data],

    // Promote headers
    #"Promoted Headers" =
        Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars = true]),

    // Schema enforcement
    #"Changed Type" =
        Table.TransformColumnTypes(#"Promoted Headers",
        {
            {"RECORD_ID", Int64.Type}, {"OWNER", type text},
            {"CURRENT_STAGE", type text}, {"CREATED_ON", type date},
            {"LAST_MODIFIED_ON", type date}, {"USER_ID", type text},
            {"DAY_OF_WEEK", type text}, {"EVENT_TIMESTAMP", type datetime},
            {"WEEK_START", type date}, {"ELAPSED_DAYS", Int64.Type},
            {"PRIORITY_GROUP", type text}, {"TIME_BUCKET", type text},
            {"DIVISION", type text}, {"TARGET_METRIC", type text},
            {"TARGET_START", type date}, {"TARGET_END", type date},
            {"BREACH_INDICATOR", type text}, {"RULE_APPLIED", type text}
        }
    ),

    // Date intelligence
    Add_Year    = Table.AddColumn(#"Changed Type", "YEAR", each Date.Year([CREATED_ON])),
    Add_Month   = Table.AddColumn(Add_Year, "MONTH", each Date.Month([CREATED_ON])),
    Add_Quarter = Table.AddColumn(Add_Month, "QUARTER", each Date.QuarterOfYear([CREATED_ON])),
    Add_Week    = Table.AddColumn(Add_Quarter, "WEEK", each Date.WeekOfYear([CREATED_ON])),

    // SLA logic
    SLA_Status =
        Table.AddColumn(Add_Week, "SLA_MET", each 
            if [PRIORITY_GROUP] = "HIGH"   and [ELAPSED_DAYS] <= 3 then "YES" else
            if [PRIORITY_GROUP] = "MEDIUM" and [ELAPSED_DAYS] <= 5 then "YES" else
            if [PRIORITY_GROUP] = "LOW"    and [ELAPSED_DAYS] <= 7 then "YES" else "NO"
        ),

    // YES/NO converter
    fYesNo = (Y as text) as logical =>
        let
            output = if Text.Upper(Y) = "YES" then true else false
        in
            output,

    // Flag conversion
    #"Converted Flags" =
        Table.TransformColumns(
            SLA_Status,
            {{"BREACH_INDICATOR", each fYesNo(_), type logical}}
        ),

    // Column ordering
    #"Reordered Columns" =
        Table.ReorderColumns(#"Converted Flags",
        {
            "RECORD_ID", "OWNER", "CURRENT_STAGE", "CREATED_ON",
            "YEAR", "MONTH", "QUARTER", "WEEK", "LAST_MODIFIED_ON",
            "USER_ID", "DAY_OF_WEEK", "EVENT_TIMESTAMP", "WEEK_START",
            "ELAPSED_DAYS", "PRIORITY_GROUP", "SLA_MET", "BREACH_INDICATOR",
            "TIME_BUCKET", "DIVISION", "TARGET_METRIC", "TARGET_START",
            "TARGET_END", "RULE_APPLIED"
        }
    ),

    // Safe date field
    TryConvert =
        Table.AddColumn(#"Reordered Columns", "SAFE_DATE",
            each try Date.From([CREATED_ON]) otherwise null
        )
in
    TryConvert

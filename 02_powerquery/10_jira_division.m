let
    ParamTable = Excel.CurrentWorkbook(){[Name="PARAM_PATH"]}[Content],
    FolderPath = ParamTable{0}[Column1],

    FullPath = FolderPath & "jira_dataset.xlsx",

    Source = Excel.Workbook(File.Contents(FullPath), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",
    {
        {"RECORD_ID", Int64.Type}, {"OWNER", type text}, {"CURRENT_STAGE", type text},
        {"CREATED_ON", type date}, {"LAST_MODIFIED_ON", type date}, {"USER_ID", type text},
        {"DAY_OF_WEEK", type text}, {"EVENT_TIMESTAMP", type datetime}, {"WEEK_START", type date},
        {"ELAPSED_DAYS", Int64.Type}, {"PRIORITY_GROUP", type text}, {"TIME_BUCKET", type text},
        {"DIVISION", type text}, {"TARGET_METRIC", type text}, {"TARGET_START", type date},
        {"TARGET_END", type date}, {"BREACH_INDICATOR", type text}, {"RULE_APPLIED", type text}
    }),

    Add_Year = Table.AddColumn(#"Changed Type", "YEAR", each Date.Year([CREATED_ON])),
    Add_Month = Table.AddColumn(Add_Year, "MONTH", each Date.Month([CREATED_ON])),
    Add_Quarter = Table.AddColumn(Add_Month, "QUARTER", each Date.QuarterOfYear([CREATED_ON])),
    Add_Week = Table.AddColumn(Add_Quarter, "WEEK", each Date.WeekOfYear([CREATED_ON])),

    SLA_Status = Table.AddColumn(Add_Week, "SLA_MET", each 
        if [PRIORITY_GROUP] = "HIGH" and [ELAPSED_DAYS] <= 3 then "YES" else
        if [PRIORITY_GROUP] = "MEDIUM" and [ELAPSED_DAYS] <= 5 then "YES" else
        if [PRIORITY_GROUP] = "LOW" and [ELAPSED_DAYS] <= 7 then "YES" else "NO"
    ),

    fYesNo = (Y as text) as logical =>
        let
            output = if Text.Upper(Y) = "YES" then true else false
        in
            output,

    #"Converted Flags" = Table.TransformColumns(
        SLA_Status,
        {{"BREACH_INDICATOR", each fYesNo(_), type logical}}
    ),

    #"Reordered Columns" = Table.ReorderColumns(#"Converted Flags",
    {"RECORD_ID", "OWNER", "CURRENT_STAGE", "CREATED_ON", "YEAR", "MONTH", "QUARTER",
     "WEEK", "LAST_MODIFIED_ON", "USER_ID", "DAY_OF_WEEK", "EVENT_TIMESTAMP",
     "WEEK_START", "ELAPSED_DAYS", "PRIORITY_GROUP", "SLA_MET", "BREACH_INDICATOR",
     "TIME_BUCKET", "DIVISION", "TARGET_METRIC", "TARGET_START", "TARGET_END",
     "RULE_APPLIED"}),
     TryConvert = Table.AddColumn(#"Reordered Columns", "SAFE_DATE", each try Date.From([CREATED_ON]) otherwise null),


    // Group By Division
     Grouped = Table.Group(#"Reordered Columns", {"DIVISION"},
        {
            {"Total", each Table.RowCount(_), Int64.Type},
            {"AvgElapsed", each List.Average([ELAPSED_DAYS]), type number},
            {"Breaches", each List.Count(List.Select([BREACH_INDICATOR], (x)=> x="YES")), Int64.Type}
        })

in
    Grouped
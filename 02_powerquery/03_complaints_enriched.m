let
    // Source
    Source = complaints_clean,

    // Date intelligence
    Add_Year   = Table.AddColumn(Source, "YEAR", each Date.Year([LOGGED_ON]), Int64.Type),
    Add_Month  = Table.AddColumn(Add_Year, "MONTH", each Date.Month([LOGGED_ON]), Int64.Type),
    Add_Qtr    = Table.AddColumn(Add_Month, "QUARTER", each Date.QuarterOfYear([LOGGED_ON]), Int64.Type),
    Add_Week   = Table.AddColumn(Add_Qtr, "WEEK", each Date.WeekOfYear([LOGGED_ON]), Int64.Type),

    // Ageing logic
    Today = Date.From(DateTime.LocalNow()),
    Add_ActualAge = Table.AddColumn(Add_Week, "AGE_DAYS", each
        if [CLOSED_ON] <> null
        then Duration.Days([CLOSED_ON] - [LOGGED_ON])
        else Duration.Days(Today - [LOGGED_ON]),
        Int64.Type
    ),

    // SLA checks
    Add_ACK_SLA = Table.AddColumn(Add_ActualAge, "ACK_SLA_MET", each
        if [ACK_DUE] = null or [ACK_COMPLETED] = null then null
        else if [ACK_COMPLETED] <= [ACK_DUE] then "YES" else "NO",
        type text
    ),
    Add_REVIEW_SLA = Table.AddColumn(Add_ACK_SLA, "REVIEW_SLA_MET", each
        if [REVIEW_DUE] = null or [REVIEW_COMPLETED] = null then null
        else if [REVIEW_COMPLETED] <= [REVIEW_DUE] then "YES" else "NO",
        type text
    ),
    Add_FINAL_SLA = Table.AddColumn(Add_REVIEW_SLA, "FINAL_SLA_MET", each
        if [FINAL_DUE] = null or [FINAL_COMPLETED] = null then null
        else if [FINAL_COMPLETED] <= [FINAL_DUE] then "YES" else "NO",
        type text
    ),

    // YES/NO to boolean
    fYesNo = (Y as nullable text) as nullable logical =>
        let
            t = if Y = null then null else Text.Upper(Y),
            result =
                if t = "YES" then true
                else if t = "NO" then false
                else null
        in
            result,

    // Flag conversion
    #"Converted Flags" = Table.TransformColumns(
        Add_FINAL_SLA,
        {
            {"MERGED_FLAG", each fYesNo(_), type logical},
            {"REMOVED_FLAG", each fYesNo(_), type logical},
            {"VULNERABLE_FLAG", each fYesNo(_), type logical},
            {"THIRD_PARTY_FLAG", each fYesNo(_), type logical},
            {"ACK_OVERDUE_FLAG", each fYesNo(_), type logical},
            {"FINAL_OVERDUE_FLAG", each fYesNo(_), type logical},
            {"FIRST_CONTACT_RESOLVED", each fYesNo(_), type logical},
            {"BOUNCE_FLAG", each fYesNo(_), type logical},
            {"TRANSFERRED_ACCOUNT_FLAG", each fYesNo(_), type logical},
            {"ACK_SLA_MET", each fYesNo(_), type logical},
            {"REVIEW_SLA_MET", each fYesNo(_), type logical},
            {"FINAL_SLA_MET", each fYesNo(_), type logical}
        }
    )
in
    #"Converted Flags"

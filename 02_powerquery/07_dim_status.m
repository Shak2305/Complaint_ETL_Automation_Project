let
    // Source
    Source = complaints_enriched,

    // Unique statuses
    #"Distinct Status" =
        Table.Distinct(
            Table.SelectColumns(Source, {"CASE_STATUS"})
        ),

    // Status grouping
    #"Add Status Group" =
        Table.AddColumn(#"Distinct Status", "STATUS_GROUP", each
            if Text.Upper([CASE_STATUS]) = "OPEN"
                or Text.Upper([CASE_STATUS]) = "IN_REVIEW"
                or Text.Upper([CASE_STATUS]) = "PENDING_INFO"
            then "OPEN"
            else "CLOSED",
            type text
        ),

    // Surrogate key
    #"Added Index" =
        Table.AddIndexColumn(#"Add Status Group", "STATUS_KEY", 1, 1, Int64.Type),

    // Order columns
    #"Reordered Columns" =
        Table.ReorderColumns(#"Added Index", {"STATUS_KEY", "CASE_STATUS", "STATUS_GROUP"})
in
    #"Reordered Columns"

let
    // Source
    Source = complaints_enriched,

    // Logged-by fields
    Logged = Table.SelectColumns(Source, {"LOGGED_BY_ID", "LOGGED_BY"}),
    #"Renamed Logged" = Table.RenameColumns(Logged,
        {{"LOGGED_BY_ID", "PERSON_ID"}, {"LOGGED_BY", "PERSON_NAME"}}
    ),

    // Owner fields
    Owner = Table.SelectColumns(Source, {"OWNER_ID", "OWNER_NAME"}),
    #"Renamed Owner" = Table.RenameColumns(Owner,
        {{"OWNER_ID", "PERSON_ID"}, {"OWNER_NAME", "PERSON_NAME"}}
    ),

    // Closed-by fields
    Closed = Table.SelectColumns(Source, {"CLOSED_BY_ID", "CLOSED_BY_NAME"}),
    #"Renamed Closed" = Table.RenameColumns(Closed,
        {{"CLOSED_BY_ID", "PERSON_ID"}, {"CLOSED_BY_NAME", "PERSON_NAME"}}
    ),

    // Combine all person roles
    Combined = Table.Combine({#"Renamed Logged", #"Renamed Owner", #"Renamed Closed"}),

    // Remove duplicates
    #"Distinct Persons" = Table.Distinct(Combined),

    // Surrogate key
    #"Added Index" = Table.AddIndexColumn(#"Distinct Persons", "PERSON_KEY", 1, 1, Int64.Type),

    // Order columns
    #"Reordered Columns" = Table.ReorderColumns(#"Added Index",
        {"PERSON_KEY", "PERSON_ID", "PERSON_NAME"}
    )
in
    #"Reordered Columns"

let
    Source = complaints_enriched,

    #"Selected Columns" = Table.SelectColumns(
        Source,
        {
            "CASE_ID","CLIENT_ID","LOGGED_ON","CLOSED_ON",
            "CATEGORY_A","CATEGORY_B","CATEGORY_C",
            "INITIAL_ISSUE","OVERALL_OUTCOME"
        }
    ),

    #"Unpivoted Categories" = Table.Unpivot(
        #"Selected Columns",
        {"CATEGORY_A","CATEGORY_B","CATEGORY_C"},
        "CATEGORY_SLOT",
        "CATEGORY"
    ),

    #"Filtered Rows" = Table.SelectRows(#"Unpivoted Categories",
        each [CATEGORY] <> null and [CATEGORY] <> ""
    )
in
    #"Filtered Rows"
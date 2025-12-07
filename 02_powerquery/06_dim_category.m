let
    // Source
    Source = complaints_categories_long,

    // Unique categories
    #"Distinct Categories" =
        Table.Distinct(
            Table.SelectColumns(Source, {"CATEGORY"})
        ),

    // Surrogate key
    #"Added Index" =
        Table.AddIndexColumn(#"Distinct Categories", "CATEGORY_KEY", 1, 1, Int64.Type),

    // Order columns
    #"Reordered Columns" =
        Table.ReorderColumns(#"Added Index", {"CATEGORY_KEY", "CATEGORY"})
in
    #"Reordered Columns"

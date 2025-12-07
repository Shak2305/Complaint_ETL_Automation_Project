let
    // Source
    Source = complaints_raw,

    // Trim key text columns
    #"Trimmed Text" = Table.TransformColumns(Source,
        {
            {"CASE_STATUS", Text.Trim, type text},
            {"PRODUCT_LINE", Text.Trim, type text},
            {"INITIAL_ISSUE", Text.Trim, type text},
            {"CATEGORY_A", Text.Trim, type text},
            {"CATEGORY_B", Text.Trim, type text},
            {"CATEGORY_C", Text.Trim, type text},
            {"OVERALL_OUTCOME", Text.Trim, type text}
        }
    ),

    // Normalize flags to uppercase
    #"Uppercased Flags" = Table.TransformColumns(#"Trimmed Text",
        {
            {"MERGED_FLAG", Text.Upper, type text},
            {"REMOVED_FLAG", Text.Upper, type text},
            {"VULNERABLE_FLAG", Text.Upper, type text},
            {"THIRD_PARTY_FLAG", Text.Upper, type text},
            {"ACK_OVERDUE_FLAG", Text.Upper, type text},
            {"FINAL_OVERDUE_FLAG", Text.Upper, type text},
            {"FIRST_CONTACT_RESOLVED", Text.Upper, type text},
            {"BOUNCE_FLAG", Text.Upper, type text},
            {"TRANSFERRED_ACCOUNT_FLAG", Text.Upper, type text}
        }
    ),

    // Convert empty strings to null
    #"Blanks to Null" = Table.ReplaceValue(
        #"Uppercased Flags",
        "",
        null,
        Replacer.ReplaceValue,
        Table.ColumnNames(#"Uppercased Flags")
    )
in
    #"Blanks to Null"

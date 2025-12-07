Option Explicit

Sub ExportFactSheetToCSV()

    Dim ws As Worksheet, newWB As Workbook
    Dim folderPath As String, fileName As String, fullPath As String
    Dim dt As String, usr As String
    Dim r As Long, lastRow As Long
    Dim rawVal As String, numVal As Double

    ' --- Username for dynamic path ---
    usr = Environ("USERNAME")

    ' --- File name with date ---
    dt = Format(Date, "yyyymmdd")
    fileName = "fact_complaints_" & dt & ".csv"

    ' --- Export folder ---
    folderPath = "C:\Users\" & usr & "\OneDrive\Work\FreelancePortfolio\TransformedFiles\"
    If Dir(folderPath, vbDirectory) = "" Then MkDir folderPath
    fullPath = folderPath & fileName

    ' --- Source sheet ---
    Set ws = ThisWorkbook.Sheets("fact_complaints")

    ' --- Copy sheet ---
    ws.UsedRange.Copy
    Set newWB = Workbooks.Add(xlWBATWorksheet)
    newWB.Sheets(1).Range("A1").PasteSpecial xlPasteValues

    With newWB.Sheets(1)

        lastRow = .Cells(.Rows.Count, 1).End(xlUp).Row

        ' --- COLUMN C = LOGGED_ON ---
        For r = 2 To lastRow

            rawVal = Trim(CStr(.Cells(r, 3).Value)) ' column C
            rawVal = Replace(rawVal, Chr(160), "")
            rawVal = Replace(rawVal, vbCr, "")
            rawVal = Replace(rawVal, vbLf, "")
            rawVal = Replace(rawVal, vbTab, "")

            If IsNumeric(rawVal) Then
                numVal = CDbl(rawVal)
                .Cells(r, 3).NumberFormat = "@"
                .Cells(r, 3).Value = Format(DateSerial(1899, 12, 30) + numVal, "yyyy-mm-dd")
            End If

        Next r

        ' --- COLUMN D = CLOSED_ON ---
        For r = 2 To lastRow

            rawVal = Trim(CStr(.Cells(r, 4).Value)) ' column D
            rawVal = Replace(rawVal, Chr(160), "")
            rawVal = Replace(rawVal, vbCr, "")
            rawVal = Replace(rawVal, vbLf, "")
            rawVal = Replace(rawVal, vbTab, "")

            If IsNumeric(rawVal) Then
                numVal = CDbl(rawVal)
                .Cells(r, 4).NumberFormat = "@"
                .Cells(r, 4).Value = Format(DateSerial(1899, 12, 30) + numVal, "yyyy-mm-dd")
            End If

        Next r

    End With

    ' --- Save CSV ---
    Application.DisplayAlerts = False
    newWB.SaveAs fileName:=fullPath, FileFormat:=xlCSV
    Application.DisplayAlerts = True

    newWB.Close False

    MsgBox "CSV exported successfully:" & vbCrLf & fullPath, vbInformation

End Sub


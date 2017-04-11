Attribute VB_Name = "Module7"
Sub test()
'
'prepareYamatoSQL
'
Cells(1, 1).Select

Dim datfile1 As String, datfile2 As String
datfile1 = ActiveWorkbook.Path & "\YamatoUpdQualifier.txt"
datfile2 = ActiveWorkbook.Path & "\YamatoDelQualifier.txt"

Open datfile1 For Output As #1
Close #1
Open datfile2 For Output As #2
Close #2

'Get the sizes (height, width) of the table
Dim H As Long, W As Long
H = Cells(Rows.Count, 1).End(xlUp).Row
W = Cells(1, Columns.Count).End(xlToLeft).Column
MsgBox "Height(rows)" & H & ", Width(columns)" & W

'Get column of Acc
i = 1
Dim AccRow As Long
Do While i <= W
  If UCase(Cells(1, i).Value) = UCase(">entry") Then
     AccRow = i
  End If
  i = i + 1
Loop
'Get column of Feature
i = 1
Dim FetRow As Long
Do While i <= W
  If UCase(Cells(1, i).Value) = UCase("feature") Then
     FetRow = i
  End If
  i = i + 1
Loop
'Get column of Location
i = 1
Dim LocRow As Long
Do While i <= W
  If UCase(Cells(1, i).Value) = UCase("location") Then
     LocRow = i
  End If
  i = i + 1
Loop
MsgBox "Acc " & AccRow & "-Feature " & FetRow & "-Location" & LocRow

'Find blank cells at row 1
Rows("1:1").Select
On Error GoTo LABEL1
Selection.SpecialCells(xlCellTypeBlanks).Select

'ichi = Selection.Address 'to get address of the cell

'Store the location of the blank cells at row 1
Dim KuranCount As Integer
Dim ii As Integer
'Dim KuranRow() As Long
Dim KuranCol() As Long
KuranCount = Selection.Areas.Count
'ReDim KuranRow(KuranCount)
ReDim KuranCol(KuranCount)
     For ii = 1 To KuranCount
       'KuranRow(ii) = Selection.Areas(ii).Row
       KuranCol(ii) = Selection.Areas(ii).Column
       MsgBox "No." & ii & " cell address: " & Cells(1, KuranCol(ii)).Address
       MsgBox "Qualifier of selected cell is," & Cells(1, KuranCol(ii) - 1)
     Next
    
MsgBox "Finished, saved to YamatoUpd(Del)Qualifier.txt"

Open datfile1 For Output As #1
Dim S As String
Dim V As Variant

For ii = 1 To KuranCount
i = 2

If Left(Cells(1, KuranCol(ii) - 1).Value, 1) = "/" Then
   S = Cells(1, KuranCol(ii) - 1).Value
Else
   S = "/" & Cells(1, KuranCol(ii) - 1).Value
End If

Do While i <= H
 If Cells(i, KuranCol(ii)).Value <> "" Then
    If Left(Cells(i, KuranCol(ii)).Value, 1) = "/" Then
       V = Split(Cells(i, KuranCol(ii)).Value, " ", 2)
       If UBound(V) = 1 Then
            GoSub HYOJI2
       End If
       If UBound(V) = 0 Then
            GoSub HYOJI3
       End If
     Else
       GoSub HYOJI1
    End If
  End If
  i = i + 1
Loop

Next
Close #1

Exit Sub

HYOJI1:
     Print #1, "#" & i & vbTab & Cells(i, AccRow).Value&; vbTab & _
     Cells(i, FetRow).Value&; vbTab & Cells(i, LocRow).Value&; vbTab & _
     S & vbTab & Cells(i, KuranCol(ii) - 1).Value&; _
     vbTab & S & vbTab & Cells(i, KuranCol(ii)).Value & vbLf;
Return

HYOJI2:
     Print #1, "#" & i & vbTab & Cells(i, AccRow).Value&; vbTab & _
     Cells(i, FetRow).Value&; vbTab & Cells(i, LocRow).Value&; vbTab & _
     S & vbTab & Cells(i, KuranCol(ii) - 1).Value&; _
     vbTab & V(0) & vbTab & V(1) & vbLf;
Return

HYOJI3:
     Print #1, "#" & i & vbTab & Cells(i, AccRow).Value&; vbTab & _
     Cells(i, FetRow).Value&; vbTab & Cells(i, LocRow).Value&; vbTab & _
     S & vbTab & Cells(i, KuranCol(ii) - 1).Value&; _
     vbTab & V(0) & vbTab & Cells(i, KuranCol(ii) - 1).Value & vbLf;
Return

LABEL1:
MsgBox "No values to correct the annotation"
End Sub


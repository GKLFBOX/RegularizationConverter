Attribute VB_Name = "CommonFunction"
Option Explicit

'------------------------------------------------------------------------------
' ## �����u�b�N�̋N���L���m�F
'------------------------------------------------------------------------------
Public Function IsDuplicateBook _
    (ByVal confirmation_filename As String) As Boolean
    
    IsDuplicateBook = False
    
    Dim openingFile As Workbook
    For Each openingFile In Workbooks
        If openingFile.Name = confirmation_filename Then
            IsDuplicateBook = True
            Exit Function
        End If
    Next openingFile
    
End Function

'------------------------------------------------------------------------------
' ## �z���IsEmpty
'------------------------------------------------------------------------------
Public Function IsEmptyArray(ByRef confirmation_array As Variant) As Boolean
    
    On Error GoTo Error_Handler
    
    ' �G���[�܂��͍ő�v�f����0�����̏ꍇ�͋�
    IsEmptyArray = IIf(UBound(confirmation_array) < 0, True, False)
    
    Exit Function
    
Error_Handler:
    IsEmptyArray = True
    
End Function

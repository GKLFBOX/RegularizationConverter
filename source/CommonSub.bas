Attribute VB_Name = "CommonSub"
Option Explicit

'------------------------------------------------------------------------------
' ## ������Excel�t�@�C����ǂݎ���p�ŊJ��
'------------------------------------------------------------------------------
Public Sub OpenBookReadOnly(ByVal open_filepath As String, _
                            ByRef open_file As Workbook)
    
    Dim openFileName As String
    openFileName = Dir(open_filepath)
    
    If Not openFileName Like "*.xls?" Then
        MsgBox "Excel�t�@�C�����w�肵�ĉ������B", vbCritical
        Exit Sub
    End If
    
    ' �����u�b�N�̋N���L���m�F
    If CommonFunction.IsDuplicateBook(openFileName) Then
        MsgBox "�����u�b�N���J����Ă��邽�ߏ����𒆒f���܂����B", vbCritical
        Exit Sub
    End If
    
    Workbooks.Open Filename:=open_filepath, ReadOnly:=True
    Set open_file = Workbooks(openFileName)
    
End Sub

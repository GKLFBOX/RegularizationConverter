Attribute VB_Name = "ConvertReverse"
Option Explicit

'------------------------------------------------------------------------------
' ## �w�b�_�s��
'------------------------------------------------------------------------------
Private Const HEADER_LINENO As Long = 1

'------------------------------------------------------------------------------
' ## �f�[�^�x�[�X�`�����猳�t�@�C���ւ̋t�ϊ��v���O����
'
' ConverDatabase�ɂč쐬�����f�[�^�����t�@�C���֕Ԃ�
'------------------------------------------------------------------------------
Public Sub ConvertReverse(ByVal source_filepath As String)
    
    ' �t�ϊ��ɂ��Ă̊m�F
    Dim confirmationMessage As VbMsgBoxResult
    confirmationMessage = _
        MsgBox("���t�@�C���ւ̋t�ϊ����s���܂��B��肠��܂��񂩁H", _
            vbYesNo + vbQuestion)
    If confirmationMessage = vbNo Then Exit Sub
    
    ' ���t�@�C������f�[�^�x�[�X�`���t�@�C���̃p�X����
    Dim extensionPoint As Long
    Dim dataFilePath As String
    extensionPoint = InStrRev(source_filepath, ".")
    dataFilePath = Left(source_filepath, extensionPoint - 1) & "_�ҏW�p.xlsx"
    
    If Dir(dataFilePath) = "" Then
        MsgBox "�ҏW�p�t�@�C�������݂��܂���B", vbCritical
        Exit Sub
    End If
    
    ' �f�[�^�x�[�X�`���t�@�C�����J��
    Dim dataFile As Workbook
    Call CommonSub.OpenBookReadOnly(dataFilePath, dataFile)
    If dataFile Is Nothing Then Exit Sub
    
    ' ���t�@�C�����J��
    Dim sourceFile As Workbook
    Call openSourceFile(source_filepath, sourceFile)
    If sourceFile Is Nothing Then
        dataFile.Close SaveChanges:=False
        Exit Sub
    End If
    
    CommonProperty.AccelerationMode = True
    
    ' �f�[�^�x�[�X�`���̃f�[�^��z��Ɋi�[
    Dim dataArray As Variant
    dataArray = dataFile.Sheets(1).UsedRange
    dataFile.Close SaveChanges:=False
    
    ' ���t�@�C���փf�[�^��߂�
    Call returnData(dataArray, sourceFile)
    
    CommonProperty.AccelerationMode = False
    
    ' �㏑���ۑ��̊m�F
    Dim saveMessage As VbMsgBoxResult
    saveMessage = _
        MsgBox("���t�@�C���ւ̋t�ϊ����������܂����B�ۑ����܂����H", _
            vbYesNo + vbInformation)
    If saveMessage = vbYes Then sourceFile.Save
    
End Sub

'------------------------------------------------------------------------------
' ## ���t�@�C�����J��
'------------------------------------------------------------------------------
Private Sub openSourceFile(ByVal source_filepath As String, _
                           ByRef source_file As Workbook)
    
    Dim sourceFileName As String
    sourceFileName = Dir(source_filepath)
    
    ' �����u�b�N�̋N���L���m�F
    If CommonFunction.IsDuplicateBook(sourceFileName) Then
        MsgBox "�����u�b�N���J����Ă��邽�ߏ����𒆒f���܂����B", vbCritical
        Exit Sub
    End If
    
    Workbooks.Open Filename:=source_filepath
    Set source_file = Workbooks(sourceFileName)
    
End Sub

'------------------------------------------------------------------------------
' ## ���t�@�C���փf�[�^��߂�
'------------------------------------------------------------------------------
Private Sub returnData(ByRef data_array As Variant, _
                       ByRef source_file As Workbook)
    
    Dim data_row As Long, data_col As Long
    Dim sheet_row As Long, sheet_col As Long
    Dim sheetName As String
    Dim currentSheet As Worksheet
    
    For data_row = 1 + HEADER_LINENO To UBound(data_array, 1)
        
        sheetName = data_array(data_row, 1)
        sheet_row = data_array(data_row, 2)
        
        ' �V�[�g���܂��͍s�ԍ����󔒂̏ꍇ�̓X�L�b�v
        If sheetName <> "" Or sheet_row < 1 Then GoTo Continue_data_row
        
        ' �s�f�[�^�����t�@�C���֖߂�
        Set currentSheet = source_file.Worksheets(sheetName)
        For data_col = 1 + ADDITION_COLUMN To UBound(data_array, 2)
            sheet_col = data_col - ADDITION_COLUMN
            currentSheet.Cells(sheet_row, sheet_col).Value = _
                data_array(data_row, data_col)
        Next data_col
        
Continue_data_row:
        
    Next data_row
    
    Set currentSheet = Nothing
    
End Sub

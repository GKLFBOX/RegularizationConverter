Attribute VB_Name = "ConvertDatabase"
Option Explicit

'------------------------------------------------------------------------------
' ## ��v�f�̕t����(�ϊ�/�t�ϊ�����)
'------------------------------------------------------------------------------
Public Const ADDITION_COLUMN As Long = 2

'------------------------------------------------------------------------------
' ## �V�[�g���Ƃɏ����ꂽ���[�̃f�[�^�x�[�X�`���ւ̕ϊ��v���O����
'
' �C�ӂ̌`���ŏ����ꂽExcel�t�@�C�����V�[�g���ƍs�ԍ���ێ�����
' ���ׂẴV�[�g���}�[�W���f�[�^�x�[�X�`���̕\�֕ϊ�����
'------------------------------------------------------------------------------
Public Sub ConvertDatabase(ByVal source_filepath As String, _
                           ByRef exclusionary_sheet() As String, _
                           ByRef exclusionary_row() As String)
    
    Dim sourceFile As Workbook
    Dim dataFile As Workbook
    
    ' ���t�@�C�����J��
    Call CommonSub.OpenBookReadOnly(source_filepath, sourceFile)
    If sourceFile Is Nothing Then Exit Sub
    
    ' �o�̓t�@�C�����쐬
    Call createNewFile(sourceFile, dataFile)
    If dataFile Is Nothing Then
        sourceFile.Close SaveChanges:=False
        Exit Sub
    End If
    
    CommonProperty.AccelerationMode = True
    
    Dim rowSize As Long: rowSize = 0
    Dim columnSize As Long: columnSize = 0
    Dim columnName() As String
    Dim dataArray() As Variant
    
    ' ���s������эő��L��
    Call fetchMatrixSize(sourceFile, rowSize, columnSize, _
        exclusionary_sheet, exclusionary_row)
    
    ' �V�[�g������эs�ԍ��̗v�f���m��
    columnSize = columnSize + ADDITION_COLUMN
    
    ' �w�b�_�̐���
    ReDim columnName(1 To 1, 1 To columnSize)
    columnName(1, 1) = "�V�[�g��"
    columnName(1, 2) = "�s�ԍ�"
    Call createHeader(columnName)
    
    ' �V�[�g��/�s�ԍ��̕t������єz��ւ̊i�[
    ReDim dataArray(1 To rowSize, 1 To columnSize)
    Call storeToArray(sourceFile, dataArray, _
        exclusionary_sheet, exclusionary_row)
    sourceFile.Close SaveChanges:=False
    
    ' �t�@�C���֏o��
    Call outputData(dataFile, rowSize, columnSize, columnName, dataArray)
    
    CommonProperty.AccelerationMode = False
    dataFile.Save
    
    MsgBox "�f�[�^�x�[�X�`���ւ̕ϊ����������܂����B", vbInformation
    
End Sub

'------------------------------------------------------------------------------
' ## "���t�@�C����_�ҏW�p.xlsx"�̏o�̓t�@�C���𓯊K�w�ɍ쐬
'------------------------------------------------------------------------------
Private Sub createNewFile(ByRef source_file As Workbook, _
                          ByRef new_file As Workbook)
    
    ' �t�@�C��������
    Dim extensionPoint As Long
    Dim newFileName As String
    extensionPoint = InStrRev(source_file.Name, ".")
    newFileName = Left(source_file.Name, extensionPoint - 1) & "_�ҏW�p.xlsx"
    
    ' �t�@�C���p�X����(���t�@�C���Ɠ��K�w)
    Dim newFilePath As String
    newFilePath = source_file.Path & "\" & newFileName
    
    ' �����u�b�N�̋N���L���m�F����ъ����t�@�C���̑��݊m�F
    If CommonFunction.IsDuplicateBook(newFileName) Then
        MsgBox "�����u�b�N���J����Ă��邽�ߏ����𒆒f���܂����B", vbCritical
        Exit Sub
    ElseIf Not Dir(newFilePath) = "" Then
        MsgBox "�����t�@�C�������݂��邽�ߏ����𒆒f���܂����B", vbCritical
        Exit Sub
    End If
    
    Set new_file = Workbooks.Add
    new_file.SaveAs Filename:=newFilePath
    
End Sub

'------------------------------------------------------------------------------
' ## ���s������эő��L��
'------------------------------------------------------------------------------
Private Sub fetchMatrixSize(ByRef source_file As Workbook, _
                            ByRef row_size As Long, _
                            ByRef column_size As Long, _
                            ByRef exclusionary_sheet() As String, _
                            ByRef exclusionary_row() As String)
    
    Dim currentSheet As Worksheet
    Dim currentData As Variant
    Dim skipSheet As Long, skipRowSize As Long
    Dim bufferSize As Long
    
    For Each currentSheet In source_file.Worksheets
        
        ' ���O�V�[�g�����ƍ�
        skipSheet = _
            matchExclusionaryValue(exclusionary_sheet, currentSheet.Name)
        If skipSheet = 0 Then GoTo Continue_currentSheet
        
        ' UsedRange�ōő�񂨂�эő�s�̎擾�Z�k��
        currentData = currentSheet.UsedRange
        If IsEmpty(currentData) Then GoTo Continue_currentSheet
        
        ' ���O�s���猸�Z�s���̎Z�o
        skipRowSize = substractRowSize _
            (exclusionary_row, UBound(currentData, 1))
        ' ���s���̍X�V
        row_size = row_size + UBound(currentData, 1) - skipRowSize
        ' �ő��̊m�F/�X�V
        bufferSize = UBound(currentData, 2)
        If bufferSize > column_size Then column_size = bufferSize
        
        Erase currentData
        
Continue_currentSheet:
        
    Next currentSheet
    
End Sub

'------------------------------------------------------------------------------
' ## ���O�ݒ�l�Ƃ̏ƍ�(��v = 0)
'------------------------------------------------------------------------------
Private Function matchExclusionaryValue(ByRef exclusionary_value() As String, _
                                        ByVal current_value As String) As Long
    
    matchExclusionaryValue = 1
    
    ' ���O�ݒ�l����̏ꍇ�̓X�L�b�v
    If CommonFunction.IsEmptyArray(exclusionary_value) Then Exit Function
    
    ' ��v����ݒ�l������ꍇ��0�ɂȂ�
    Dim i As Long
    For i = 0 To UBound(exclusionary_value)
        matchExclusionaryValue = matchExclusionaryValue * StrComp _
            (exclusionary_value(i), current_value)
        If matchExclusionaryValue = 0 Then Exit For
    Next i
    
End Function

'------------------------------------------------------------------------------
' ## ���O�s���猸�Z�s���̎Z�o
'------------------------------------------------------------------------------
Private Function substractRowSize(ByRef exclusionary_row() As String, _
                                  ByVal current_rowsize As Long) As Long
    
    substractRowSize = 0
    
    ' ���O�ݒ�l����̏ꍇ�̓X�L�b�v
    If CommonFunction.IsEmptyArray(exclusionary_row) Then Exit Function
    
    ' ���O�s�����݂̍ő�s�ȉ��̏ꍇ���J�E���g
    Dim i As Long
    For i = 0 To UBound(exclusionary_row)
        If exclusionary_row(i) <= current_rowsize Then
            substractRowSize = substractRowSize + 1
        End If
    Next i
    
End Function

'------------------------------------------------------------------------------
' ## �V�[�g��/�s�ԍ��̕t������єz��ւ̊i�[
'------------------------------------------------------------------------------
Private Sub storeToArray(ByRef source_file As Workbook, _
                         ByRef data_array() As Variant, _
                         ByRef exclusionary_sheet() As String, _
                         ByRef exclusionary_row() As String)
    
    Dim currentSheet As Worksheet
    Dim currentData As Variant
    Dim skipSheet As Long, skipRow As Long
    Dim current_row As Long, current_col As Long
    Dim data_row As Long, data_col As Long
    
    data_row = 0
    For Each currentSheet In source_file.Worksheets
        
        ' ���O�V�[�g�����ƍ�
        skipSheet = _
            matchExclusionaryValue(exclusionary_sheet, currentSheet.Name)
        If skipSheet = 0 Then GoTo Continue_currentSheet
        
        ' UsedRange�Ŕz�񉻒Z�k��
        currentData = currentSheet.UsedRange
        If IsEmpty(currentData) Then GoTo Continue_currentSheet
        
        For current_row = 1 To UBound(currentData, 1)
            ' ���O�s�ԍ����ƍ�
            skipRow = _
                matchExclusionaryValue(exclusionary_row, current_row)
            If skipRow <> 0 Then
                data_row = data_row + 1
                ' �V�[�g��/�s�ԍ��̕t��
                data_array(data_row, 1) = currentSheet.Name
                data_array(data_row, 2) = current_row
                ' ��v�f�̕t�������l�����Ĕz��֊i�[
                For current_col = 1 To UBound(currentData, 2)
                    data_col = ADDITION_COLUMN + current_col
                    data_array(data_row, data_col) = _
                        currentData(current_row, current_col)
                Next current_col
            End If
        Next current_row
        
        Erase currentData
        
Continue_currentSheet:
        
    Next currentSheet
    
End Sub

'------------------------------------------------------------------------------
' ## �w�b�_�̐���
'------------------------------------------------------------------------------
Private Sub createHeader(ByRef column_name() As String)
    
    Dim i As Long
    Dim columnNumberName As Long
    
    For i = 1 + ADDITION_COLUMN To UBound(column_name, 2)
        columnNumberName = i - ADDITION_COLUMN
        ' �b��I��"��**"�Ƃ��Ă���
        column_name(1, i) = "��" & columnNumberName
    Next
    
End Sub

'------------------------------------------------------------------------------
' ## �o�̓t�@�C���ւ̏�������
'------------------------------------------------------------------------------
Private Sub outputData(ByRef data_file As Workbook, _
                       ByVal row_size As Long, _
                       ByVal column_size As Long, _
                       ByRef column_name() As String, _
                       ByRef data_array() As Variant)
    
    With data_file.Sheets(1)
        ' ���t���ɕϊ�����Ȃ��悤�ɂ��ׂĕ�����Ƃ��ďo��
        .Cells(1, 1).Resize(1, column_size).NumberFormatLocal = "@"
        .Cells(1, 1).Resize(1, column_size) = column_name
        .Cells(2, 1).Resize(row_size, column_size).NumberFormatLocal = "@"
        .Cells(2, 1).Resize(row_size, column_size) = data_array
    End With
    
End Sub

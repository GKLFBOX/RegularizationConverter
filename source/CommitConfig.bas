Attribute VB_Name = "CommitConfig"
Option Explicit

'------------------------------------------------------------------------------
' ## �ݒ�t�H���_�̃t�H���_��
'------------------------------------------------------------------------------
Private Const CONFIG_FOLDER As String = "\config"

'------------------------------------------------------------------------------
' ## �ݒ�t�@�C���̓ǂݍ���
'------------------------------------------------------------------------------
Public Function LoadConfig(ByVal config_filename As String) As String
    
    LoadConfig = ""
    
    Dim configFilePath As String
    configFilePath = ThisWorkbook.Path & CONFIG_FOLDER & config_filename
    
    If Dir(configFilePath) = "" Then Exit Function
    
    Dim bufferData As String
    Open configFilePath For Input As #1
        Do Until EOF(1)
            Line Input #1, bufferData
            LoadConfig = LoadConfig & bufferData & vbCrLf
        Loop
        LoadConfig = Left(LoadConfig, Len(LoadConfig) - Len(vbCrLf))
    Close #1
    
End Function

'------------------------------------------------------------------------------
' ## ���O����V�[�g���̓ǂݍ���
'------------------------------------------------------------------------------
Public Sub LoadExclusionarySheet(ByVal config_sheetname As String, _
                                 ByRef exclusionary_sheet() As String)
    
    Dim bufferSheetName() As String
    bufferSheetName = Split(config_sheetname, vbCrLf)
    
    ' ���p/�S�p�X�y�[�X�݂̂������ď��O�V�[�g�����L��
    Dim i As Long
    Dim blankChecker As String
    Dim n_sheet As Long: n_sheet = 0
    For i = 0 To UBound(bufferSheetName)
        blankChecker = Replace(Replace(bufferSheetName(i), " ", ""), "�@", "")
        If blankChecker <> "" Then
            ReDim Preserve exclusionary_sheet(0 To n_sheet)
            exclusionary_sheet(n_sheet) = bufferSheetName(i)
            n_sheet = n_sheet + 1
        End If
    Next i
    
End Sub

'------------------------------------------------------------------------------
' ## ���O����s�ԍ��̓ǂݍ���
'------------------------------------------------------------------------------
Public Sub LoadExclusionaryRow(ByVal config_rownumber As String, _
                               ByRef exclusionary_row() As String)
    
    If config_rownumber = "" Then Exit Sub
    
    ' �ݒ�l������,�n�C�t��,�J���}�݂̂��m�F
    If Not validateSingleCharacter(config_rownumber) Then Exit Sub
    
    Dim bufferRow() As String
    bufferRow = Split(config_rownumber, ",")
    
    ' �J���}��؂�̗v�f���Ƃ̊m�F
    Dim i As Long
    Dim hyphenPosition As Long
    Dim fullRowNumber As String: fullRowNumber = ""
    For i = 0 To UBound(bufferRow)
        If bufferRow(i) = "" Then
            MsgBox "�J���}��؂�̎w�肪�s���ł��B", vbCritical
            Exit Sub
        End If
        ' �͈͓��͂̊m�F
        hyphenPosition = InStr(bufferRow(i), "-")
        If hyphenPosition > 0 Then
            ' �͈͓���(�n�C�t���L��)�̏ꍇ�͍s�ԍ��֕ϊ�
            Call convertRowNumber(hyphenPosition, bufferRow(i))
            ' �ϊ��o���Ă��Ȃ��ꍇ�͏I��
            If InStr(bufferRow(i), "-") > 0 Then Exit Sub
        End If
        ' �J���}��؂�̍s�ԍ��Ƃ��ċL��
        fullRowNumber = fullRowNumber & bufferRow(i)
        If i <> UBound(bufferRow) Then fullRowNumber = fullRowNumber & ","
    Next i
    
    exclusionary_row = Split(fullRowNumber, ",")
    
End Sub

'------------------------------------------------------------------------------
' ## ���O����s�ԍ��̓��͂�����,�n�C�t��,�J���}�݂̂��m�F
'------------------------------------------------------------------------------
Private Function validateSingleCharacter _
    (ByVal config_rownumber As String) As Boolean
    
    validateSingleCharacter = True
    
    Dim i As Long
    Dim singleCharacter As String
    
    For i = 1 To Len(config_rownumber)
        singleCharacter = Mid(config_rownumber, i, 1)
        If Not IsNumeric(singleCharacter) _
        And singleCharacter <> "-" _
        And singleCharacter <> "," Then
            validateSingleCharacter = False
            MsgBox "�ݒ�l�ɐ���,�n�C�t��,�J���}�ȊO���܂܂�Ă��܂��B", _
                vbCritical
            Exit Function
        End If
    Next i
    
End Function

'------------------------------------------------------------------------------
' ## �͈͓��͂��e�s�ԍ��֕ϊ�
'------------------------------------------------------------------------------
Private Sub convertRowNumber(ByVal hyphen_position As Long, _
                             ByRef row_range As String)
    
    Dim smallNumber As String
    Dim largeNumber As String
    
    smallNumber = Left(row_range, hyphen_position - 1)
    largeNumber = Mid(row_range, hyphen_position + 1)
    
    ' �͈͓��͂Ƃ��Ė�肪�������m�F
    If Not IsNumeric(smallNumber) Or Not IsNumeric(largeNumber) Then
        MsgBox "�s�ԍ��͈͓̔��͂̐��l���s���ł��B", vbCritical
        Exit Sub
    ElseIf CLng(smallNumber) >= CLng(largeNumber) Then
        MsgBox "�s�ԍ��͈͓̔��͂̑召���s���ł��B", vbCritical
        Exit Sub
    End If
    
    row_range = ""
    
    ' �J���}��؂�̍s�ԍ��֕ϊ�
    Dim i As Long
    For i = CLng(smallNumber) To CLng(largeNumber)
        row_range = row_range & i
        If i <> CLng(largeNumber) Then row_range = row_range & ","
    Next i
    
End Sub

'------------------------------------------------------------------------------
' ## �ݒ�t�H���_�̑��݊m�F����э쐬
'------------------------------------------------------------------------------
Public Sub PrepareConfigFolder()
    
    Dim configFolderPath As String
    configFolderPath = ThisWorkbook.Path & CONFIG_FOLDER
    
    If Dir(configFolderPath, vbDirectory) = "" Then
        MkDir configFolderPath
    End If
    
End Sub

'------------------------------------------------------------------------------
' ## �ݒ�t�@�C���ւ̏����o��
'------------------------------------------------------------------------------
Public Sub SaveConfig(ByVal config_filename As String, _
                      ByVal config_data As String)
    
    Dim configFilePath As String
    configFilePath = ThisWorkbook.Path & CONFIG_FOLDER & config_filename
    
    Open configFilePath For Output As #1
        Print #1, config_data
    Close #1
    
End Sub

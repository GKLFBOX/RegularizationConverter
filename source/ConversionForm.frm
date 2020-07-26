VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} ConversionForm 
   Caption         =   "�K�����ϊ��v���O����"
   ClientHeight    =   3720
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   6660
   OleObjectBlob   =   "ConversionForm.frx":0000
   StartUpPosition =   1  '�I�[�i�[ �t�H�[���̒���
End
Attribute VB_Name = "ConversionForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'------------------------------------------------------------------------------
' ## �ݒ�t�@�C���̃t�@�C����
'------------------------------------------------------------------------------
Private Const SHEET_CONFIG As String = "\ExclusionarySheet.config"
Private Const ROW_CONFIG As String = "\ExclusionaryRow.config"

'------------------------------------------------------------------------------
' ## �t�H�[��������
'
' �����Ŏw�肵�Ă���v���p�e�B�͈ȉ��̒ʂ�
' *�T�C�Y�֌W�����������K�{�̂���
' *�R�[�h�ł����w��ł��Ȃ�����
'------------------------------------------------------------------------------
Private Sub UserForm_Initialize()
    
    With FileDorpView
        .OLEDropMode = ccOLEDropManual  ' D&D�̗L����
        .View = lvwReport               ' �\���`��
        .LabelEdit = lvwManual          ' ���e�̕ҏW
        .AllowColumnReorder = True      ' �񕝂̕ύX
        .FullRowSelect = True           ' �s�S�̂̑I��
        .Gridlines = True               ' �O���b�h���\��
        
        .ColumnHeaders.Add Text:="�t�@�C����", Width:=100
        .ColumnHeaders.Add Text:="�t�@�C���p�X", Width:=400
    End With
    
    With ExclusionarySheetBox
        .MultiLine = True                   ' ���s�̗L����
        .ScrollBars = fmScrollBarsVertical  ' �X�N���[���o�[
    End With
    
    ' �ݒ�t�@�C���̓ǂݍ���
    ExclusionarySheetBox.Value = CommitConfig.LoadConfig(SHEET_CONFIG)
    ExclusionaryRowBox.Value = CommitConfig.LoadConfig(ROW_CONFIG)
    
End Sub

'------------------------------------------------------------------------------
' ## �t�@�C���h���b�v���̓���(�v�Q�Ɛݒ�)
'------------------------------------------------------------------------------
Private Sub FileDorpView_OLEDragDrop _
    (Data As MSComctlLib.DataObject, Effect As Long, Button As Integer, _
     Shift As Integer, x As Single, y As Single)
    
    If Not Data.Files.Count = 1 Then
        MsgBox "�ϊ�����t�@�C����1�ɂ��ĉ������B", vbExclamation
        Exit Sub
    End If
    
    ' �㏑���̂��߈�xClear
    FileDorpView.ListItems.Clear
    
    With FileDorpView.ListItems.Add
        .Text = Dir(Data.Files(1))
        .SubItems(1) = Data.Files(1)
    End With
    
End Sub

'------------------------------------------------------------------------------
' ## �ϊ��{�^��
'------------------------------------------------------------------------------
Private Sub ConversionButton_Click()
    
    With ConversionForm.FileDorpView.ListItems
        If .Count = 1 Then
            Dim sourceFilePath As String
            Dim exclusionarySheet() As String
            Dim exclusionaryRow() As String
            
            sourceFilePath = .Item(1).SubItems(1)
            
            ' �ݒ�l�ǂݍ���
            Call CommitConfig.LoadExclusionarySheet _
                (ExclusionarySheetBox.Value, exclusionarySheet)
            Call CommitConfig.LoadExclusionaryRow _
                (ExclusionaryRowBox.Value, exclusionaryRow)
            
            ' �ϊ����s
            Call ConvertDatabase.ConvertDatabase _
                (sourceFilePath, exclusionarySheet, exclusionaryRow)
            
            ' �ݒ�t�H���_�̏���
            Call CommitConfig.PrepareConfigFolder
            
            ' �ݒ�l�ۑ�
            Call CommitConfig.SaveConfig _
                (SHEET_CONFIG, ExclusionarySheetBox.Value)
            Call CommitConfig.SaveConfig _
                (ROW_CONFIG, ExclusionaryRowBox.Value)
        Else
            MsgBox "�t�@�C�����w�肳��Ă��܂���B", vbExclamation
        End If
    End With
    
End Sub

'------------------------------------------------------------------------------
' ## �t�ϊ��{�^��
'------------------------------------------------------------------------------
Private Sub ReversionButton_Click()
    
    With ConversionForm.FileDorpView.ListItems
        If .Count = 1 Then
            Dim sourceFilePath As String
            sourceFilePath = .Item(1).SubItems(1)
            
            ' �ϊ����s
            Call ConvertReverse.ConvertReverse(sourceFilePath)
        Else
            MsgBox "�t�@�C�����w�肳��Ă��܂���B", vbExclamation
        End If
    End With
    
End Sub

'------------------------------------------------------------------------------
' ## �t�H�[���Ɠ����Ƀu�b�N�����
'------------------------------------------------------------------------------
Private Sub UserForm_Terminate()
    
    ' �ҏW���̓R�����g�A�E�g
    'ThisWorkbook.Close
    
End Sub

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'------------------------------------------------------------------------------
'
' [�K�����ϊ��v���O����] v1.0   2020/07/16 G.O.
'
' �V�[�g���Ƃɏ����ꂽ���[��s�v�V�[�g����ѕs�v�s�����O��
' �l�݂̂̃f�[�^�x�[�X�`���֕ϊ�/�t�ϊ����s���v���O����
'
'
' ##�R�[�f�B���O�K�C�h���C��
'
' [You.Activate|VBA�R�[�f�B���O�K�C�h���C��]�ɏ�������
' (http://www.thom.jp/vbainfo/codingguideline.html)
'
'------------------------------------------------------------------------------
Option Explicit

'------------------------------------------------------------------------------
' ## �A�h�C���N����
'------------------------------------------------------------------------------
Private Sub Workbook_Open()
    Load ConversionForm
    ConversionForm.Show vbModeless
End Sub

'------------------------------------------------------------------------------
' ## �A�h�C���I����
'------------------------------------------------------------------------------
Private Sub Workbook_BeforeClose(Cancel As Boolean)
    ' �u�b�N����ɕ��Ă��܂����ꍇ�G���[�ɂȂ邽��
    ' �u�b�N�����O�ɕK��Unload��UserForm_Terminate���o�R������
    Unload ConversionForm
End Sub
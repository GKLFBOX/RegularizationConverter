Attribute VB_Name = "CommonProperty"
Option Explicit

'------------------------------------------------------------------------------
' ## ��ʍX�V/�C�x���g���m/�����v�Z�̐���
'------------------------------------------------------------------------------
Public Property Let AccelerationMode(ByVal flg As Boolean)
    
    ' �u�b�N������J���Ă��Ȃ���Calculation�̓G���[�ɂȂ邽�ߒ���
    With Application
        .ScreenUpdating = Not flg
        .EnableEvents = Not flg
        .Calculation = IIf(flg, xlCalculationManual, xlCalculationAutomatic)
    End With
    
End Property

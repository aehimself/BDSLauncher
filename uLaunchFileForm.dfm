object LaunchFileForm: TLaunchFileForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'LaunchFileForm'
  ClientHeight = 163
  ClientWidth = 313
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  DesignSize = (
    313
    163)
  TextHeight = 15
  object DelphiVersionLabel: TLabel
    Left = 16
    Top = 8
    Width = 217
    Height = 15
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select Delphi version to open the file with:'
  end
  object DelphiInstanceLabel: TLabel
    Left = 16
    Top = 67
    Width = 206
    Height = 15
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select the instance to open the file with:'
  end
  object DelphiVersionComboBox: TComboBox
    Left = 16
    Top = 29
    Width = 281
    Height = 23
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = DelphiVersionComboBoxChange
  end
  object DelphiInstanceComboBox: TComboBox
    Left = 16
    Top = 88
    Width = 281
    Height = 23
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = DelphiInstanceComboBoxChange
  end
  object OpenButton: TButton
    Left = 16
    Top = 128
    Width = 281
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Open'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end

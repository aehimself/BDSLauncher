object LaunchFileForm: TLaunchFileForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'LaunchFileForm'
  ClientHeight = 161
  ClientWidth = 314
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    314
    161)
  TextHeight = 15
  object DelphiVersionLabel: TLabel
    Left = 8
    Top = 8
    Width = 217
    Height = 15
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select Delphi version to open the file with:'
  end
  object DelphiInstanceLabel: TLabel
    Left = 8
    Top = 66
    Width = 206
    Height = 15
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select the instance to open the file with:'
  end
  object DelphiVersionComboBox: TComboBox
    Left = 8
    Top = 29
    Width = 298
    Height = 23
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = DelphiVersionComboBoxChange
  end
  object DelphiInstanceComboBox: TComboBox
    Left = 8
    Top = 88
    Width = 298
    Height = 23
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object OpenButton: TButton
    Left = 8
    Top = 128
    Width = 298
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Open'
    Default = True
    TabOrder = 2
    OnClick = OpenButtonClick
  end
end

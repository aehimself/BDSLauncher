object LaunchFileForm: TLaunchFileForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'LaunchFileForm'
  ClientHeight = 192
  ClientWidth = 483
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  TextHeight = 15
  object OpenButton: TButton
    Left = 0
    Top = 167
    Width = 483
    Height = 25
    Align = alBottom
    Caption = 'Open'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object InstancesTreeView: TTreeView
    Left = 0
    Top = 0
    Width = 483
    Height = 167
    Align = alClient
    BorderStyle = bsNone
    HideSelection = False
    Indent = 19
    ReadOnly = True
    RowSelect = True
    ShowLines = False
    ShowRoot = False
    TabOrder = 0
    OnChange = InstancesTreeViewChange
    OnCollapsing = InstancesTreeViewCollapsing
    OnCustomDrawItem = InstancesTreeViewCustomDrawItem
    OnDblClick = InstancesTreeViewDblClick
  end
  object Timer1: TTimer
    Interval = 10000
    OnTimer = RefreshDisplay
    Left = 8
    Top = 16
  end
end

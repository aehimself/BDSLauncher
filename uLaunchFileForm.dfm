object LaunchFileForm: TLaunchFileForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'LaunchFileForm'
  ClientHeight = 191
  ClientWidth = 479
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
  OnResize = FormResize
  TextHeight = 15
  object InstancesTreeView: TTreeView
    Left = 0
    Top = 0
    Width = 479
    Height = 154
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
    OnChanging = InstancesTreeViewChanging
    OnCollapsing = InstancesTreeViewCollapsing
    OnCustomDrawItem = InstancesTreeViewCustomDrawItem
    OnDblClick = InstancesTreeViewDblClick
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 154
    Width = 479
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      479
      37)
    object OpenButton: TButton
      Left = 384
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Open'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object CancelButton: TButton
      Left = 296
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object RefreshInstancesTimer: TTimer
    Interval = 10000
    OnTimer = RefreshDisplay
    Left = 64
    Top = 16
  end
end

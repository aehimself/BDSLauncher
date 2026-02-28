object BDSLauncherMainForm: TBDSLauncherMainForm
  Left = 0
  Top = 0
  Caption = 'AE BDSLauncher'
  ClientHeight = 386
  ClientWidth = 601
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  TextHeight = 15
  object Splitter: TSplitter
    Left = 250
    Top = 0
    Width = 5
    Height = 386
    OnMoved = SplitterMoved
  end
  object RulesTreeView: TTreeView
    Left = 0
    Top = 0
    Width = 250
    Height = 386
    Align = alLeft
    BorderStyle = bsNone
    DragMode = dmAutomatic
    HideSelection = False
    Indent = 19
    ReadOnly = True
    RowSelect = True
    ShowLines = False
    ShowRoot = False
    TabOrder = 0
    OnAdvancedCustomDrawItem = RulesTreeViewAdvancedCustomDrawItem
    OnChange = RulesTreeViewChange
    OnChanging = RulesTreeViewChanging
    OnCollapsing = RulesTreeViewCollapsing
    OnDragDrop = RulesTreeViewDragDrop
    OnDragOver = RulesTreeViewDragOver
  end
  object ScrollBox: TScrollBox
    Left = 255
    Top = 0
    Width = 346
    Height = 386
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    ParentColor = False
    TabOrder = 1
    DesignSize = (
      346
      386)
    object FileMaskLabel: TLabel
      Left = 8
      Top = 16
      Width = 57
      Height = 15
      Caption = 'File masks:'
    end
    object DelphiVersionLabel: TLabel
      Left = 8
      Top = 160
      Width = 78
      Height = 15
      Caption = 'Delphi version:'
    end
    object CaptionContainsLabel: TLabel
      Left = 28
      Top = 278
      Width = 172
      Height = 15
      Caption = 'Instance caption should contain:'
    end
    object InstanceParamsLabel: TLabel
      Left = 8
      Top = 342
      Width = 136
      Height = 15
      Caption = 'New instance parameters:'
    end
    object FileMasksMemo: TMemo
      Left = 8
      Top = 37
      Width = 332
      Height = 100
      Anchors = [akLeft, akTop, akRight]
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      OnChange = FileMasksMemoChange
    end
    object DelphiVersionComboBox: TComboBox
      Left = 8
      Top = 181
      Width = 332
      Height = 22
      Style = csOwnerDrawFixed
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnChange = DelphiVersionComboBoxChange
    end
    object AlwaysNewInstanceRadioButton: TRadioButton
      Left = 8
      Top = 232
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Always start in a new instance'
      TabOrder = 2
      OnClick = InstanceRadioClick
    end
    object SelectedInstanceRadioButton: TRadioButton
      Left = 8
      Top = 255
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Use an existing instance'
      Checked = True
      TabOrder = 3
      TabStop = True
      OnClick = InstanceRadioClick
    end
    object InstanceContainsEdit: TEdit
      Left = 28
      Top = 299
      Width = 312
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      OnChange = InstanceContainsEditChange
    end
    object InstanceParamsEdit: TEdit
      Left = 8
      Top = 363
      Width = 332
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      OnChange = InstanceParamsEditChange
    end
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Left = 48
    Top = 8
    object File1: TMenuItem
      Caption = '&File'
      object Enablelogging1: TMenuItem
        Caption = '&Enable logging'
        OnClick = Enablelogging1Click
      end
      object Savesettings1: TMenuItem
        Caption = '&Save settings'
        ShortCut = 16467
        OnClick = Savesettings1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object OpenDelphisourcefile1: TMenuItem
        Caption = 'Open Delphi source file...'
        ShortCut = 16463
        OnClick = OpenDelphisourcefile1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32883
        OnClick = Exit1Click
      end
    end
    object Rules1: TMenuItem
      Caption = '&Rules'
      object Newrule1: TMenuItem
        Caption = '&New rule...'
        ShortCut = 16462
        OnClick = Newrule1Click
      end
      object Deleterule1: TMenuItem
        Caption = '&Delete rule...'
        ShortCut = 16452
        OnClick = Deleterule1Click
      end
      object Renamerule1: TMenuItem
        Caption = 'Rename rule...'
        ShortCut = 16466
        OnClick = Renamerule1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Moveup1: TMenuItem
        Caption = 'Move &up'
        ShortCut = 16469
        OnClick = MoveRuleClick
      end
      object Movedown1: TMenuItem
        Caption = 'Move do&wn'
        ShortCut = 16471
        OnClick = MoveRuleClick
      end
    end
    object Fileassociations1: TMenuItem
      Caption = 'File &associations'
      object akeover1: TMenuItem
        Caption = '&Take over'
        OnClick = akeover1Click
      end
      object Giveback1: TMenuItem
        Caption = '&Give back...'
        OnClick = Giveback1Click
      end
    end
  end
end

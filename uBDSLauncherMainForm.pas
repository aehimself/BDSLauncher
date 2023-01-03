{
  AE BDS Launcher © 2023 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uBDSLauncherMainForm;

Interface

Uses System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, uSettings;

Type
  TBDSLauncherMainForm = Class(TForm)
    RulesTreeView: TTreeView;
    PopupMenu: TPopupMenu;
    Newrule1: TMenuItem;
    Deleterule1: TMenuItem;
    Splitter: TSplitter;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Rules1: TMenuItem;
    Savesettings1: TMenuItem;
    N1: TMenuItem;
    Newrule2: TMenuItem;
    Deleterule2: TMenuItem;
    Fileassociations1: TMenuItem;
    akeover1: TMenuItem;
    Giveback1: TMenuItem;
    N2: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    Enablelogging1: TMenuItem;
    ScrollBox1: TScrollBox;
    FileMaskLabel: TLabel;
    FileMasksMemo: TMemo;
    DelphiVersionLabel: TLabel;
    DelphiVersionComboBox: TComboBox;
    AlwaysNewInstanceRadioButton: TRadioButton;
    SelectedInstanceRadioButton: TRadioButton;
    CaptionContainsLabel: TLabel;
    InstanceContainsEdit: TEdit;
    InstanceParamsLabel: TLabel;
    InstanceParamsEdit: TEdit;
    Procedure FormCreate(Sender: TObject);
    Procedure Deleterule1Click(Sender: TObject);
    Procedure Newrule1Click(Sender: TObject);
    Procedure RulesTreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure RulesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
    Procedure RulesTreeViewChange(Sender: TObject; Node: TTreeNode);
    Procedure InstanceContainsEditChange(Sender: TObject);
    Procedure InstanceParamsEditChange(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure PopupMenuPopup(Sender: TObject);
    Procedure DelphiVersionComboBoxChange(Sender: TObject);
    Procedure FileMasksMemoChange(Sender: TObject);
    Procedure InstanceRadioClick(Sender: TObject);
    Procedure Exit1Click(Sender: TObject);
    Procedure Savesettings1Click(Sender: TObject);
    Procedure akeover1Click(Sender: TObject);
    Procedure Giveback1Click(Sender: TObject);
    Procedure MoveRuleClick(Sender: TObject);
    Procedure Enablelogging1Click(Sender: TObject);
    Procedure FormResize(Sender: TObject);
    Procedure SplitterMoved(Sender: TObject);
  strict private
    _dontsave: Boolean;
    _loading: Boolean;
    Procedure OpenFile(Const inFileName: String);
    Procedure RefreshRules;
    Procedure UpdateSelectedTreeNode;
    Function SelectedRule: TRule;
  End;

Var
  BDSLauncherMainForm: TBDSLauncherMainForm;

Implementation

Uses WinApi.Windows, WinApi.Messages, System.SysUtils, uLaunchFileForm, Vcl.Dialogs, AE.IDE.Versions, System.UITypes, uFileAssociations,
     uDetectDelphiVersionOfProject, uBDSLogger;

{$R *.dfm}

//
// TBDSLauncherMainForm
//

Procedure TBDSLauncherMainForm.DelphiVersionComboBoxChange(Sender: TObject);
Var
  rule: TRule;
  ver: TAEIDEVersion;
Begin
  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  ver := DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion;

  If Assigned(ver) Then
    rule.DelphiVersion := ver.Name
  Else
    rule.DelphiVersion := '';

  UpdateSelectedTreeNode;
End;

Procedure TBDSLauncherMainForm.Enablelogging1Click(Sender: TObject);
Begin
  Enablelogging1.Checked := Not Enablelogging1.Checked;

  Settings.EnableLogging := Enablelogging1.Checked;
End;

Procedure TBDSLauncherMainForm.Exit1Click(Sender: TObject);
Begin
  Self.Close;
End;

Procedure TBDSLauncherMainForm.FileMasksMemoChange(Sender: TObject);
Var
  rule: TRule;
Begin
  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.FileMasks := FileMasksMemo.Text;

  UpdateSelectedTreeNode;
End;

Procedure TBDSLauncherMainForm.FormCreate(Sender: TObject);
Var
  ver: TAEIDEVersion;
  fname: String;
  a: Integer;
Begin
  Settings.Load;

  _loading := True;
  Try
    Self.Height := Settings.MainWindowHeight;
    Self.Width := Settings.MainWindowWidth;
    RulesTreeView.Width := Settings.RuleListWidth;
  Finally
    _loading := False;
  End;

  BDSLogger.Log('BDS launcher is starting up');

  _dontsave := False;

  If Not ParamStr(1).IsEmpty Then
  Begin
    _dontsave := True;

    Self.WindowState := wsMinimized;
    Self.Visible := False;

    fname := ParamStr(1);

    If fname.StartsWith('"') And fname.EndsWith('"') Then
      fname := fname.Substring(1, fname.Length - 2)
    Else
    Begin
      For a := 2 To ParamCount Do
        fname := fname + ' ' + ParamStr(a);
    End;

    Self.OpenFile(fname);

    PostMessage(Self.Handle, WM_QUIT, 0, 0);

    Exit;
  End;

  BDSLogger.Log('No file name was provided, showing rule editor form...');

  DelphiVersionComboBox.Items.BeginUpdate;
  Try
    DelphiVersionComboBox.Items.Add('Auto detect or use latest');

    For ver In RuleEngine.DelphiVersions.InstalledVersions Do
      DelphiVersionComboBox.Items.AddObject(ver.Name, ver);
  Finally
    DelphiVersionComboBox.Items.EndUpdate;
  End;

  Enablelogging1.Checked := Settings.EnableLogging;
  Self.RefreshRules;
End;

Procedure TBDSLauncherMainForm.FormDestroy(Sender: TObject);
Begin
  If Not _dontsave And Settings.IsLoaded Then
    Settings.Save;
End;

Procedure TBDSLauncherMainForm.FormResize(Sender: TObject);
Begin
  If _loading Then
    Exit;

  Settings.MainWindowHeight := Self.Height;
  Settings.MainWindowWidth := Self.Width;
End;

Procedure TBDSLauncherMainForm.Giveback1Click(Sender: TObject);
Begin
  GiveBackFileAssociations;
End;

Procedure TBDSLauncherMainForm.InstanceContainsEditChange(Sender: TObject);
Var
  rule: TRule;
Begin
  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.InstanceCaptionContains := InstanceContainsEdit.Text;

  UpdateSelectedTreeNode;
End;

Procedure TBDSLauncherMainForm.InstanceParamsEditChange(Sender: TObject);
Var
  rule: TRule;
Begin
  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.NewInstanceParams := InstanceParamsEdit.Text;

  UpdateSelectedTreeNode;
End;

Procedure TBDSLauncherMainForm.InstanceRadioClick(Sender: TObject);
Var
  rule: TRule;
Begin
  rule := SelectedRule;

  InstanceContainsEdit.Enabled := SelectedInstanceRadioButton.Checked And Assigned(rule);

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.AlwaysNewInstance := AlwaysNewInstanceRadioButton.Checked;

  UpdateSelectedTreeNode;
End;

Procedure TBDSLauncherMainForm.MoveRuleClick(Sender: TObject);
Var
  thisnode, targetnode: TTreeNode;
Begin
  thisnode := RulesTreeView.Selected;

  If Sender = Moveup1 Then
  Begin
    targetnode := thisnode.GetPrev;
    While Assigned(targetnode) And Assigned(targetnode.Parent) Do
      targetnode := targetnode.Parent;
  End
  Else
  Begin
    targetnode := thisnode.GetNext;
    While Assigned(targetnode) And Assigned(targetnode.Parent) Do
      targetnode := targetnode.GetNext;
  End;

  If Not Assigned(targetnode) Then
    Exit;

  RulesTreeView.Items.BeginUpdate;
  Try
    If Sender = Moveup1 Then
    Begin
      thisnode.MoveTo(targetnode, naInsert);
      thisnode.Expand(False);
    End
    Else
    Begin
      targetnode.MoveTo(thisnode, naInsert);
      targetnode.Expand(False);
    End;

    TRule(thisnode.Data).Order := thisnode.Index;
    TRule(targetnode.Data).Order := targetnode.Index;
  Finally
    RulesTreeView.Items.EndUpdate;
  End;
End;

Procedure TBDSLauncherMainForm.Newrule1Click(Sender: TObject);
Var
  rulename: String;
  a: Integer;
Begin
  rulename := '';

  If Not InputQuery('Add new rule', 'Rule name:', rulename) Or rulename.IsEmpty Then
    Exit;

  RuleEngine.Rule[rulename] := TRule.Create;

  RefreshRules;

  For a := 0 To RulesTreeView.Items.Count - 1 Do
    If (RulesTreeView.Items[a].Parent = nil) And (RulesTreeView.Items[a].Text = rulename) Then
    Begin
      RulesTreeView.Selected := RulesTreeView.Items[a];
      Break;
    End;
End;

Procedure TBDSLauncherMainForm.akeover1Click(Sender: TObject);
Begin
  TakeOverFileAssociations;
End;

Procedure TBDSLauncherMainForm.Deleterule1Click(Sender: TObject);
Var
  tn: TTreeNode;
Begin
  tn := RulesTreeView.Selected;

  If Not Assigned(tn) Or (MessageDlg('Are you sure you want to delete this rule?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) Then
    Exit;

  RuleEngine.Rule[tn.Text] := nil;
  tn.Delete;

  RulesTreeViewChange(RulesTreeView, RulesTreeView.Selected);
End;

Procedure TBDSLauncherMainForm.OpenFile(Const inFileName: String);
Var
  lff: TLaunchFileForm;
  determinedversion: String;
  ver: TAEIDEVersion;
  inst: TAEIDEInstance;
Begin
  BDSLogger.Log('Attempting to open file ' + inFileName);

  If Not FileExists(inFileName) Then
    Raise EArgumentException.Create(inFileName + ' does not exist!');

  BDSLogger.Log('Running Delphi instances:');
  For ver In RuleEngine.DelphiVersions.InstalledVersions Do
    For inst In ver.Instances Do
      BDSLogger.Log(ver.Name + ', ' + inst.IDECaption);

  // Attempt to detect the Delphi version used to create the file. This information is used by rules and the selector window as well.
  determinedversion := DetectDelphiVersion(inFileName);

  BDSLogger.Log('Determined Delphi version: ' + determinedversion);

  // If any rules matches the file and launching is successful, no form is going to be needed either
  If RuleEngine.LaunchByRules(inFileName, determinedversion) Then
    Exit;

  // If there is only one installed version and it has no running instances, don't run any rules or ask how to open it,
  // just start a new instance
  If ((Length(RuleEngine.DelphiVersions.InstalledVersions) = 1) And (Length(RuleEngine.DelphiVersions.InstalledVersions[0].Instances) = 0)) Then
  Begin
    BDSLogger.Log('No rule applied to the input file, but there''s only one installation and no instances. Starting one...');

    RuleEngine.DelphiVersions.InstalledVersions[0].NewInstanceParams := inFileName;
    RuleEngine.DelphiVersions.InstalledVersions[0].NewIDEInstance;

    Exit;
  End;

  BDSLogger.Log('Showing version selector window...');

  // If we resize the selector form, it's width must be saved. As rules won't change here, we can assume it's safe to do so
  _dontsave := False;

  // We ran out of options for the time being. Show the form and ask where to open the file
  lff := TLaunchFileForm.Create(nil);
  Try
    lff.Caption := inFileName;

    // If Delphi version detection was successful, change the default item in the combobox.
    If Not determinedversion.IsEmpty Then
      lff.DelphiVersionDetected(determinedversion);

    If lff.ShowModal <> mrOk Then
      Exit;

    If Assigned(lff.SelectedInstance) Then
    Begin
      BDSLogger.Log(lff.SelectedVersion.Name + ', ' + lff.SelectedInstance.IDECaption + ' was selected to start the file in.');

      lff.SelectedInstance.OpenFile(inFileName)
    End
    Else If Assigned(lff.SelectedVersion) Then
    Begin
      BDSLogger.Log('A new instance of ' + lff.SelectedVersion.Name + ' was selected to start the file in.');

      lff.SelectedVersion.NewInstanceParams := inFileName;
      lff.SelectedVersion.NewIDEInstance;
    End;
  Finally
    lff.Free;
  End;
End;

Procedure TBDSLauncherMainForm.PopupMenuPopup(Sender: TObject);
Begin
  Deleterule1.Enabled := Assigned(RulesTreeView.Selected);
  Moveup1.Enabled := Assigned(RulesTreeView.Selected);
  Movedown1.Enabled := Assigned(RulesTreeView.Selected);
End;

Procedure TBDSLauncherMainForm.RefreshRules;
Var
  rulename, s: String;
  tn: TTreeNode;
Begin
  _loading := True;
  Try
    RulesTreeView.Items.BeginUpdate;
    Try
      RulesTreeView.Items.Clear;

      For rulename In RuleEngine.Rules Do
      Begin
        tn := RulesTreeView.Items.AddChild(nil, rulename);
        tn.Data := RuleEngine.Rule[rulename];

        For s In RuleEngine.Rule[rulename].DisplayName.Split([sLineBreak]) Do
          RulesTreeView.Items.AddChild(tn, s);

        tn.Expand(False);

        // Automatically reset order in case it got messed up
        RuleEngine.Rule[rulename].Order := tn.Index;
      End;

      If RulesTreeView.Items.Count = 0 Then
        RUlesTreeViewChange(nil, nil);
    Finally
      RulesTreeView.Items.EndUpdate;
    End;
  Finally
    _loading := False;
  End;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewChange(Sender: TObject; Node: TTreeNode);
Var
  rule: TRule;
  rnode: TTreeNode;
Begin
  rnode := RulesTreeView.Selected;

  While Assigned(rnode) And Assigned(rnode.Parent) Do
    rnode := rnode.Parent;

  If rnode <> Node Then
  Begin
    RulesTreeView.Selected := rnode;
    Exit;
  End;

  rule := SelectedRule;

  _loading := True;
  Try
    FileMasksMemo.Enabled := Assigned(rule);
    If Assigned(rule) Then
      FileMasksMemo.Text := rule.FileMasks
    Else
      FileMasksMemo.Text := '';

    DelphiVersionComboBox.Enabled := Assigned(rule);
    If Assigned(rule) Then
      If Not rule.DelphiVersion.IsEmpty Then
        DelphiVersionComboBox.ItemIndex := DelphiVersionComboBox.Items.IndexOf(rule.DelphiVersion)
      Else
        DelphiVersionComboBox.ItemIndex := 0
    Else
      DelphiVersionComboBox.ItemIndex := -1;

    InstanceContainsEdit.Enabled := Assigned(rule);
    If Assigned(rule) Then
      InstanceContainsEdit.Text := rule.InstanceCaptionContains
    Else
      InstanceContainsEdit.Text := '';

    If Assigned(rule) And rule.AlwaysNewInstance Then
      AlwaysNewInstanceRadioButton.Checked := True
    Else
      SelectedInstanceRadioButton.Checked := True;
    InstanceRadioClick(nil);
    AlwaysNewInstanceRadioButton.Enabled := Assigned(rule);
    SelectedInstanceRadioButton.Enabled := Assigned(rule);

    InstanceParamsEdit.Enabled := Assigned(rule);
    If Assigned(rule) Then
      InstanceParamsEdit.Text := rule.NewInstanceParams
    Else
      instanceParamsEdit.Text := '';
  Finally
    _loading := False;
  End;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
Begin
  AllowCollapse := False;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  tp: TPoint;
Begin
  If Button <> mbRight Then
    Exit;

  RulesTreeView.Selected := RulesTreeView.GetNodeAt(X, Y);

  tp.X := X;
  tp.Y := Y;

  tp := Self.ClientToScreen(tp);
  PopUpMenu.Popup(tp.X, tp.Y);
End;

Procedure TBDSLauncherMainForm.Savesettings1Click(Sender: TObject);
Begin
  If Settings.IsLoaded Then
    Settings.Save;
End;

Function TBDSLauncherMainForm.SelectedRule: TRule;
Var
  tn: TTreeNode;
Begin
  tn := RulesTreeView.Selected;

  If Assigned(tn) And Assigned(tn.Data) Then
    Result := tn.Data
  Else
    Result := nil;
End;

Procedure TBDSLauncherMainForm.SplitterMoved(Sender: TObject);
Begin
  If _loading Then
    Exit;

  Settings.RuleListWidth := RulesTreeView.Width;
End;

Procedure TBDSLauncherMainForm.UpdateSelectedTreeNode;
Var
  tn: TTreeNode;
  s: String;
Begin
  tn := RulesTreeView.Selected;

  If Not Assigned(tn) Then
    Exit;

  RulesTreeView.Items.BeginUpdate;
  Try
    tn.DeleteChildren;

    For s In TRule(tn.Data).DisplayName.Split([sLineBreak]) Do
      RulesTreeView.Items.AddChild(tn, s);

    tn.Expand(False);
  Finally
    RulesTreeView.Items.EndUpdate;
  End;
End;

End.

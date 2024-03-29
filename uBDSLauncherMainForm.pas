﻿{
  AE BDS Launcher © 2023 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uBDSLauncherMainForm;

Interface

Uses System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, uSettings, WinApi.Windows,
     AE.IDE.Versions;

Type
  TBDSLauncherMainForm = Class(TForm)
    RulesTreeView: TTreeView;
    Splitter: TSplitter;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Rules1: TMenuItem;
    Savesettings1: TMenuItem;
    N1: TMenuItem;
    Newrule1: TMenuItem;
    Deleterule1: TMenuItem;
    Fileassociations1: TMenuItem;
    akeover1: TMenuItem;
    Giveback1: TMenuItem;
    Enablelogging1: TMenuItem;
    ScrollBox: TScrollBox;
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
    N2: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    Renamerule1: TMenuItem;
    OpenDelphisourcefile1: TMenuItem;
    N3: TMenuItem;
    Procedure FormCreate(Sender: TObject);
    Procedure Deleterule1Click(Sender: TObject);
    Procedure Newrule1Click(Sender: TObject);
    Procedure RulesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
    Procedure RulesTreeViewChange(Sender: TObject; Node: TTreeNode);
    Procedure InstanceContainsEditChange(Sender: TObject);
    Procedure InstanceParamsEditChange(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
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
    Procedure RulesTreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; Var Accept: Boolean);
    Procedure RulesTreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    Procedure RulesTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; Var PaintImages, DefaultDraw: Boolean);
    Procedure Renamerule1Click(Sender: TObject);
    Procedure RulesTreeViewChanging(Sender: TObject; Node: TTreeNode; Var AllowChange: Boolean);
    Procedure OpenDelphisourcefile1Click(Sender: TObject);
  strict private
    _dontsave: Boolean;
    _loading: Boolean;
    Procedure OpenInInstance(Const inFileName: String; Const inInstance: TAEIDEInstance);
    Procedure OpenFile(Const inFileName: String);
    Procedure OpenInNewInstance(Const inFileName: String; Const inIDEVersion: TAEIDEVersion; Const inParams: String = '');
    Procedure RefreshRules;
    Procedure MoveNode(inSourceNode, inDestinationNode: TTreeNode);
    Procedure UpdateSelectedTreeNode;
    Function OpenWithRules(Const inFileName, inDetectedVersion: String): Boolean;
    Function SelectedRule: TRule;
  End;

Var
  BDSLauncherMainForm: TBDSLauncherMainForm;

Implementation

Uses WinApi.Messages, System.SysUtils, uLaunchFileForm, Vcl.Dialogs, System.UITypes, uFileAssociations,
     uDetectDelphiVersionOfProject, uBDSLogger, System.Masks;

Resourcestring
  VERSION_AUTODETECT = 'Auto detect or use latest';
  ADDRULE_CAPTION = 'Add new rule';
  ADDRULE_RULENAME = 'Rule name:';
  ERROR_RULEEXISTS = 'A rule named %s already exists!';
  DELETERULE_CONFIRM = 'Are you sure you want to delete this rule?';
  OPENFILE_DELPHISOURCEFILE = 'Delphi source files';
  ERROR_FILEDOESNTEXIST = '%s does not exist!';
  RENAMERULE_CAPTION = 'Rename rule';
  RENAMERULE_NEWRULENAME = 'New rule name:';
  SETTINGSSAVED = 'Settings saved successfully.';

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
    If Settings.WindowSize[Self.ClassName].Height <> 0 Then
      Self.Height := Settings.WindowSize[Self.ClassName].Height;
    If Settings.WindowSize[Self.ClassName].Width <> 0 Then
      Self.Width := Settings.WindowSize[Self.ClassName].Width;
    If Settings.RuleListWidth <> 0 Then
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

    Halt(0);
  End;

  BDSLogger.Log('No file name was provided, showing rule editor form...');

  If Assigned(Screen.MessageFont) Then
    Self.Font.Assign(Screen.MessageFont);

  DelphiVersionComboBox.Items.BeginUpdate;
  Try
    DelphiVersionComboBox.Items.Add(VERSION_AUTODETECT);

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

  If Self.Height <> 448 Then
    Settings.WindowSize[Self.ClassName].Height := Self.Height
  Else
    Settings.WindowSize[Self.ClassName].Height := 0;

  If Self.Width <> 629 Then
    Settings.WindowSize[Self.ClassName].Width := Self.Width
  Else
    Settings.WindowSize[Self.ClassName].Width := 0;
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

Procedure TBDSLauncherMainForm.MoveNode(inSourceNode, inDestinationNode: TTreeNode);
Var
  tmp: TTreeNode;
Begin
  While Assigned(inSourcenode) And Assigned(inSourceNode.Parent) Do
    inSourceNode := inSourceNode.Parent;

  While Assigned(inDestinationNode) And Assigned(inDestinationNode.Parent) Do
    inDestinationNode := inDestinationNode.Parent;

  If Not Assigned(inSourceNode) Or Not Assigned(inDestinationNode) Then
    Exit;

  If inDestinationNode.Index > inSourceNode.Index Then
  Begin
    tmp := inDestinationNode;
    inDestinationNode := inSourceNode;
    inSourceNode := tmp;
  End;

  // Phisically move the node and force-expand it
  RulesTreeView.Items.BeginUpdate;
  Try
    inSourceNode.MoveTo(inDestinationNode, naInsert);
    inSourceNode.Expand(False);
  Finally
    RulesTreeView.Items.EndUpdate;
  End;

  // Set the order of each rule between the two nodes to represent their new order
  tmp := inSourceNode;
  Repeat
    TRule(tmp.Data).Order := tmp.Index;

    If tmp = inDestinationNode Then
      Break;

    Repeat
      tmp := tmp.GetNext;
    Until Not Assigned(tmp.Parent);
  Until False;
End;

Procedure TBDSLauncherMainForm.MoveRuleClick(Sender: TObject);
Var
  targetnode: TTreeNode;
Begin
  If Sender = Moveup1 Then
    targetnode := RulesTreeView.Selected.GetPrev
  Else
  Begin
    targetnode := RulesTreeView.Selected.GetNext;
    While Assigned(targetnode) And Assigned(targetnode.Parent) Do
      targetnode := targetnode.GetNext;
  End;

  MoveNode(RulesTreeView.Selected, targetnode);
End;

Procedure TBDSLauncherMainForm.Newrule1Click(Sender: TObject);
Var
  rulename: String;
  a: Integer;
Begin
  rulename := '';

  If Not InputQuery(ADDRULE_CAPTION, ADDRULE_RULENAME, rulename) Or rulename.IsEmpty Then
    Exit;

  If RuleEngine.ContainsRule(rulename) Then
  Begin
    MessageDlg(Format(ERROR_RULEEXISTS, [rulename]), mtError, [mbOK], 0);
    Exit;
  End;

  RuleEngine.Rule[rulename].Order := Length(RuleEngine.Rules);

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

  If Not Assigned(tn) Or (MessageDlg(DELETERULE_CONFIRM, mtConfirmation, [mbYes, mbNo], 0) <> mrYes) Then
    Exit;

  Repeat
    tn := tn.GetNext;

    If Assigned(tn) And Not Assigned(tn.Parent) Then
      Dec(TRule(tn.Data).Order);
  Until Not Assigned(tn);

  tn := RulesTreeView.Selected;

  RuleEngine.Rule[tn.Text] := nil;
  tn.Delete;

  RulesTreeViewChange(RulesTreeView, RulesTreeView.Selected);
End;

Procedure TBDSLauncherMainForm.OpenDelphisourcefile1Click(Sender: TObject);
Var
  fname, filter: String;
  a: Integer;
Begin
  filter := '';

  For a := Low(KNOWNEXTENSIONS) To High(KNOWNEXTENSIONS) Do
    filter := filter + '*' + KNOWNEXTENSIONS[a] + ',';

  filter := filter.Substring(0, filter.Length - 1);

  filter := Format('%s (%s)|%s', [OPENFILE_DELPHISOURCEFILE, filter, filter.Replace(',', ';')]);

  If PromptForFileName(fname, filter) Then
  Begin
    RuleEngine.DelphiVersions.RefreshInstalledVersions;

    Self.OpenFile(fname);
  End;
End;

Procedure TBDSLauncherMainForm.OpenFile(Const inFileName: String);
Var
  lff: TLaunchFileForm;
  determinedversion: String;
  ver: TAEIDEVersion;
  inst: TAEIDEInstance;
  instancebanner: Boolean;
Begin
  BDSLogger.Log('Attempting to open file ' + inFileName);

  If Not FileExists(inFileName) Then
    Raise EArgumentException.Create(Format(ERROR_FILEDOESNTEXIST, [inFileName]));

  If Length(RuleEngine.DelphiVersions.InstalledVersions) > 0 Then
  Begin
    instancebanner := False;

    For ver In RuleEngine.DelphiVersions.InstalledVersions Do
      For inst In ver.Instances Do
      Begin
        If Not instancebanner Then
        Begin
          BDSLogger.Log('Running Delphi instances:');

          instancebanner := True;
        End;

        BDSLogger.Log(inst.Name);
      End;
  End;

  // Attempt to detect the Delphi version used to create the file. This information is used by rules and the selector window as well.
  determinedversion := DetectDelphiVersion(inFileName);

  If Not determinedversion.IsEmpty Then
    BDSLogger.Log('Determined Delphi version: ' + determinedversion);

  If GetKeyState(VK_SHIFT) >= 0 Then
  Begin
    // If any rules matches the file and launching is successful, no form is going to be needed either
    If Self.OpenWithRules(inFileName, determinedversion) Then
      Exit;
  End
  Else
    BDSLogger.Log('Shift was down when starting the file, rule execution was skipped.');

  // If there is only one installed version and it has no running instances, don't run any rules or ask how to open it,
  // just start a new instance
  If ((Length(RuleEngine.DelphiVersions.InstalledVersions) = 1) And (Length(RuleEngine.DelphiVersions.InstalledVersions[0].Instances) = 0)) Then
  Begin
    BDSLogger.Log('Only one installed version and no instances were found.');

    Self.OpenInNewInstance(inFileName, RuleEngine.DelphiVersions.InstalledVersions[0]);

    Exit;
  End;

  BDSLogger.Log('Showing version selector window...');

  // If we resize the selector form, it's width must be saved. As rules won't change here, we can assume it's safe to do so
  _dontsave := False;

  // We ran out of options for the time being. Show the form and ask where to open the file
  lff := TLaunchFileForm.Create(nil);
  Try
    lff.Initialize(inFileName);

    // If Delphi version detection was successful, change the default item in the combobox.
    If Not determinedversion.IsEmpty Then
      lff.DelphiVersionDetected(determinedversion);

    If lff.ShowModal <> mrOk Then
      Exit;

    If lff.SelectedObject <> nil Then
      If lff.SelectedObject is TAEIDEInstance Then
      Begin
        BDSLogger.Log((lff.SelectedObject As TAEIDEInstance).Name + ' was selected.');

        Self.OpenInInstance(inFileName, lff.SelectedObject As TAEIDEInstance);
      End
      Else If lff.SelectedObject Is TAEIDEVersion Then
      Begin
        BDSLogger.Log('A new instance of ' + (lff.SelectedObject As TAEIDEVersion).Name + ' was selected.');

        Self.OpenInNewInstance(inFilename, lff.SelectedObject As TAEIDEVersion);
      End;
  Finally
    lff.Free;
  End;
End;

Procedure TBDSLauncherMainForm.OpenInInstance(Const inFileName: String; Const inInstance: TAEIDEInstance);
Begin
  inInstance.OpenFile(inFileName);
  SetForegroundWindow(inInstance.IDEHWND);

  BDSLogger.Log(ExtractFileName(inFileName) + ' was started in an existing ' + inInstance.Name + ' instance.');
End;

Procedure TBDSLauncherMainForm.OpenInNewInstance(Const inFileName: String; Const inIDEVersion: TAEIDEVersion; Const inParams: String = '');
Var
  inst: TAEIDEInstance;
Begin
  If inParams.IsEmpty Then
    inst := inIDEVersion.NewIDEInstance('"' + inFileName + '"')
  Else
  Begin
    inst := inIDEVersion.NewIDEInstance(inParams);
    SetForegroundWindow(inst.IDEHWND);
    inst.OpenFile(inFileName);
  End;

  BDSLogger.Log(ExtractFileName(inFileName) + ' was started in a new ' + inst.Name + ' instance.');
End;

Function TBDSLauncherMainForm.OpenWithRules(Const inFileName, inDetectedVersion: String): Boolean;
Var
  rulename, mask: String;
  rule: TRule;
  ver: TAEIDEVersion;
  inst: TAEIDEInstance;
  anymatch: Boolean;
Begin
  Result := False;

  For rulename In RuleEngine.Rules Do
  Begin
    rule := RuleEngine.Rule[rulename];

    BDSLogger.Log('Checking with rule #' + rule.Order.ToString + ': ' + rulename);

    // Rule was not set up for this file pattern
    anymatch := False;
    For mask In rule.FileMasks.Split([sLineBreak]) Do
      anymatch := anymatch Or MatchesMask(inFileName, mask);

    If Not anymatch Then
    Begin
      BDSLogger.Log('None of the file masks in the rule matched the input file!');

      Continue;
    End;

    If Not rule.DelphiVersion.IsEmpty Then
      ver := RuleEngine.DelphiVersions.VersionByName(rule.DelphiVersion) // Rule explicitly specified a Delphi version
    Else If Not inDetectedVersion.IsEmpty Then
      ver := RuleEngine.DelphiVersions.VersionByName(inDetectedVersion) // Auto detection was enabled, version could be detected
    Else
      ver := RuleEngine.DelphiVersions.LatestVersion; // Auto detection was specified by the rule, but version was not detected. In this case, use the latest

    // Delphi version requested by this rule is not installed (?)
    If Not Assigned(ver) Then
    Begin
      BDSLogger.Log('No suitable Delphi versions requested by the rule were found!');

      Continue;
    End;

    If rule.AlwaysNewInstance Then
    Begin
      BDSLogger.Log('Rule specifies a new instance every time.');

      Self.OpenInNewInstance(inFileName, ver, rule.NewInstanceParams);

      Result := True;
      Exit;
    End
    Else If Not rule.InstanceCaptionContains.IsEmpty Then
    Begin
      BDSLogger.Log('Searching for an instance of ' + ver.Name + ' which has ' + rule.InstanceCaptionContains + ' in it''s caption...');

      For inst In ver.Instances Do
        If inst.IDECaption.ToLower.Contains(rule.InstanceCaptionContains.ToLower) Then
        Begin
          Self.OpenInInstance(inFileName, inst);

          Result := True;
          Exit;
        End;
    End
    Else If Length(ver.Instances) > 0 Then
    Begin
      BDSLogger.Log('Rule specifies file can be launched in any instance');

      Self.OpenInInstance(inFileName, ver.Instances[0]);

      Result := True;
      Exit;
    End;

    BDSLogger.Log('Rule matched, but no suitable instances were found.');
    Self.OpenInNewInstance(inFilename, ver, rule.NewInstanceParams);

    Result := true;
    Exit;
  End;
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

Procedure TBDSLauncherMainForm.Renamerule1Click(Sender: TObject);
Var
  rulename: String;
Begin
  If Not Assigned(RulesTreeView.Selected) Then
    Exit;

  rulename := RulesTreeView.Selected.Text;

  If Not InputQuery(RENAMERULE_CAPTION, RENAMERULE_NEWRULENAME, rulename) Or rulename.IsEmpty Then
    Exit;

  If RuleEngine.ContainsRule(rulename) Then
  Begin
    MessageDlg(Format(ERROR_RULEEXISTS, [rulename]), mtError, [mbOK], 0);
    Exit;
  End;

  RuleEngine.RenameRule(RulesTreeView.Selected.Text, rulename);
  RulesTreeView.Selected.Text := rulename;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; Var PaintImages, DefaultDraw: Boolean);
Begin
  If Assigned(Node.Data) Then
    Sender.Canvas.Font.Style := [fsBold]
  Else
    Sender.Canvas.Font.Style := [fsItalic];
End;

Procedure TBDSLauncherMainForm.RulesTreeViewChange(Sender: TObject; Node: TTreeNode);
Var
  rule: TRule;
Begin
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

Procedure TBDSLauncherMainForm.RulesTreeViewChanging(Sender: TObject; Node: TTreeNode; Var AllowChange: Boolean);
Begin
  AllowChange := Not Assigned(Node.Parent);

  If AllowChange Then
    Exit;

  While Assigned(Node.Parent) Do
    Node := Node.Parent;

  RulesTreeView.Selected := Node;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
Begin
  AllowCollapse := False;
End;

Procedure TBDSLauncherMainForm.RulesTreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
Begin
  MoveNode(RulesTreeView.Selected, RulesTreeView.GetNodeAt(X, Y));
End;

Procedure TBDSLauncherMainForm.RulesTreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; Var Accept: Boolean);
Var
  destnode: TTreeNode;
begin
  destnode := RulesTreeView.GetNodeAt(X, Y);

  While Assigned(destnode) And Assigned(destnode.Parent) Do
   destnode := destnode.Parent;

  Accept := Assigned(destnode) And (RulesTreeView.Selected <> destnode);
End;

Procedure TBDSLauncherMainForm.Savesettings1Click(Sender: TObject);
Begin
  If Settings.IsLoaded Then
  Begin
    Settings.Save;

    MessageDlg(SETTINGSSAVED, mtInformation, [mbOK], 0);
  End;
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

  If RulesTreeView.Width <> 250 Then
    Settings.RuleListWidth := RulesTreeView.Width
  Else
    Settings.RuleListWidth := 0;
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

﻿{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uBDSLauncherMainForm;

Interface

Uses System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, uRuleEngine;

Type
  TBDSLauncherMainForm = Class(TForm)
    RulesTreeView: TTreeView;
    RuleEditorPanel: TPanel;
    PopupMenu: TPopupMenu;
    Newrule1: TMenuItem;
    Deleterule1: TMenuItem;
    FileMaskLabel: TLabel;
    DelphiVersionLabel: TLabel;
    CaptionContainsLabel: TLabel;
    InstanceContainsEdit: TEdit;
    InstanceParamsLabel: TLabel;
    InstanceParamsEdit: TEdit;
    DelphiVersionComboBox: TComboBox;
    FileMasksMemo: TMemo;
    AlwaysNewInstanceRadioButton: TRadioButton;
    SelectedInstanceRadioButton: TRadioButton;
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

Uses WinApi.Windows, WinApi.Messages, System.SysUtils, uLaunchFileForm, Vcl.Dialogs, AE.IDE.Versions, System.UITypes, uFileAssociations;

{$R *.dfm}

//
// TBDSLauncherMainForm
//

Procedure TBDSLauncherMainForm.DelphiVersionComboBoxChange(Sender: TObject);
Var
  rule: TRule;
Begin
  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.DelphiVersion := DelphiVersionComboBox.Text;

  UpdateSelectedTreeNode;
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
Begin
  For ver In RuleEngine.DelphiVersions.InstalledVersions Do
    DelphiVersionComboBox.Items.Add(ver.Name);

  RuleEngine.Load;
  _dontsave := False;

  If Not ParamStr(1).IsEmpty Then
  Begin
    _dontsave := True;

    Self.WindowState := wsMinimized;
    Self.Visible := False;

    Self.OpenFile(ParamStr(1));

    PostMessage(Self.Handle, WM_QUIT, 0, 0);
  End
  Else
    Self.RefreshRules;
End;

Procedure TBDSLauncherMainForm.FormDestroy(Sender: TObject);
Begin
  If Not _dontsave And RuleEngine.IsLoaded Then
    RuleEngine.Save;
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
  InstanceContainsEdit.Enabled := SelectedInstanceRadioButton.Checked;

  rule := SelectedRule;

  If _loading Or Not Assigned(rule) Then
    Exit;

  rule.AlwaysNewInstance := AlwaysNewInstanceRadioButton.Checked;

  UpdateSelectedTreeNode;
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
Begin
  If Not FileExists(inFileName) Then
    Raise EArgumentException.Create(inFileName + ' does not exist!');

  // If there is only one installed version and it has no running instances, don't run any rules or ask how to open it,
  // just start a new instance
  If ((Length(RuleEngine.DelphiVersions.InstalledVersions) = 1) And (Length(RuleEngine.DelphiVersions.InstalledVersions[0].Instances) = 0)) Then
  Begin
    RuleEngine.DelphiVersions.InstalledVersions[0].NewInstanceParams := inFileName;
    RuleEngine.DelphiVersions.InstalledVersions[0].NewIDEInstance;

    Exit;
  End;

  // If any rules matches the file and launching is successful, no form is going to be needed either
  If RuleEngine.LaunchByRules(inFileName) Then
    Exit;

  // We ran out of options for the time being. Show the form and ask where to open the file
  lff := TLaunchFileForm.Create(nil);
  Try
    lff.Caption := inFileName;

    lff.ShowModal;
  Finally
    lff.Free;
  End;
End;

Procedure TBDSLauncherMainForm.PopupMenuPopup(Sender: TObject);
Begin
  Deleterule1.Enabled := Assigned(RulesTreeView.Selected);
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
      End;
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
      DelphiVersionComboBox.ItemIndex := DelphiVersionComboBox.Items.IndexOf(rule.DelphiVersion)
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
  If _dontsave And RuleEngine.IsLoaded Then
    RuleEngine.Save;
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

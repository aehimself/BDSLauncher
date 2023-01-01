{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uLaunchFileForm;

Interface

Uses System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, AE.IDE.Versions;

Type
  TLaunchFileForm = Class(TForm)
    DelphiVersionComboBox: TComboBox;
    DelphiVersionLabel: TLabel;
    DelphiInstanceLabel: TLabel;
    DelphiInstanceComboBox: TComboBox;
    OpenButton: TButton;
    Procedure DelphiVersionComboBoxChange(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure DelphiInstanceComboBoxChange(Sender: TObject);
  strict private
    _selectedinstance: TAEIDEInstance;
    _selectedversion: TAEIDEVersion;
    Procedure RefreshInstances;
    Procedure RefreshVersions;
    Function InstanceCaption(Const inIDEInstance: TAEIDEInstance): String;
  public
    Procedure DelphiVersionDetected(Const inDelphiVersion: String);
    Property SelectedInstance: TAEIDEInstance Read _selectedinstance;
    Property SelectedVersion: TAEIDEVersion Read _selectedversion;
  End;

Implementation

Uses System.SysUtils, uRuleEngine, Vcl.Dialogs, System.UITypes;

{$R *.dfm}

Procedure TLaunchFileForm.DelphiInstanceComboBoxChange(Sender: TObject);
Begin
  If DelphiInstanceComboBox.ItemIndex > -1 Then
    _selectedinstance := DelphiInstanceComboBox.Items.Objects[DelphiInstanceComboBox.ItemIndex] As TAEIDEInstance
  Else
    _selectedinstance := nil;
End;

Procedure TLaunchFileForm.DelphiVersionComboBoxChange(Sender: TObject);
Begin
  If DelphiVersionComboBox.ItemIndex > -1 Then
    _selectedversion := DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion
  Else
    _selectedversion := nil;

  RefreshInstances;
End;

Procedure TLaunchFileForm.DelphiVersionDetected(Const inDelphiVersion: String);
Begin
  If DelphiVersionComboBox.Items.IndexOf(inDelphiVersion) <> -1 Then
    DelphiVersionComboBox.ItemIndex := DelphiVersionComboBox.Items.IndexOf(inDelphiVersion)
  Else
    MessageDlg('Selected project was created with ' + inDelphiVersion + ', which is not installed on this PC.', mtWarning, [mbOK], 0);
End;

Procedure TLaunchFileForm.FormCreate(Sender: TObject);
Begin
  Self.RefreshVersions;
End;

Function TLaunchFileForm.InstanceCaption(Const inIDEInstance: TAEIDEInstance): String;
Begin
  Result := inIDEInstance.IDECaption + ' (PID: ' + inIDEInstance.PID.ToString + ')';
End;

Procedure TLaunchFileForm.RefreshInstances;
Var
  inst: TAEIDEInstance;
  selpid: Cardinal;
  npos: Integer;
Begin
  _selectedinstance := nil;

  DelphiInstanceComboBox.Items.BeginUpdate;
  Try
    If DelphiInstanceComboBox.ItemIndex = -1 Then
      selpid := 0
    Else
      selpid := (DelphiInstanceComboBox.Items.Objects[DelphiInstanceComboBox.ItemIndex] As TAEIDEInstance).PID;

    DelphiInstanceComboBox.Items.Clear;

    If DelphiVersionComboBox.ItemIndex = -1 Then
    Begin
      DelphiInstanceComboBox.Enabled := False;
      OpenButton.Enabled := False;

      Exit;
    End;

    DelphiInstanceComboBox.Enabled := True;
    OpenButton.Enabled := True;

    DelphiInstanceComboBox.Items.Add('New instance...');

    For inst In (DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion).Instances Do
    Begin
      npos := DelphiInstanceComboBox.Items.AddObject(InstanceCaption(inst), inst);

      If inst.PID = selpid Then
        DelphiInstanceComboBox.ItemIndex := npos;
    End;

    If DelphiInstanceComboBox.ItemIndex = -1 Then
      DelphiInstanceComboBox.ItemIndex := 0;

    DelphiInstanceComboBoxChange(nil);
  Finally
    DelphiInstanceComboBox.Items.EndUpdate;
  End;
End;

Procedure TLaunchFileForm.RefreshVersions;
Var
  dver: TAEIDEVersion;
  sel, npos: Integer;
Begin
  _selectedversion := nil;
  _selectedinstance := nil;

  DelphiVersionComboBox.Items.BeginUpdate;
  Try
    If DelphiVersionComboBox.ItemIndex = -1 Then
      sel := -1
    Else
      sel := (DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion).VersionNumber;

    DelphiVersionComboBox.Items.Clear;

    For dver In RuleEngine.DelphiVersions.InstalledVersions Do
    Begin
      npos := DelphiVersionComboBox.Items.AddObject(dver.Name, dver);

      If dver.VersionNumber = sel Then
        DelphiVersionCombobox.ItemIndex := npos
    End;

    If DelphiVersionComboBox.Items.Count = 0 Then
    Begin
      DelphiVersionComboBox.Enabled := False;
      Exit;
    End;

    DelphiVersionComboBox.Enabled := True;

    If DelphiVersionComboBox.ItemIndex = -1 Then
      DelphiVersionComboBox.ItemIndex := DelphiVersionComboBox.Items.Count - 1;

    DelphiVersionComboBoxChange(nil);
  Finally
    DelphiVersionComboBox.Items.EndUpdate;
  End;
End;

End.

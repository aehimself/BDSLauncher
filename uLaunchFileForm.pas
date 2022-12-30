{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uLaunchFileForm;

Interface

Uses System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, AE.IDE.DelphiVersions, AE.IDE.Versions;

Type
  TLaunchFileForm = Class(TForm)
    DelphiVersionComboBox: TComboBox;
    DelphiVersionLabel: TLabel;
    DelphiInstanceLabel: TLabel;
    DelphiInstanceComboBox: TComboBox;
    OpenButton: TButton;
    procedure DelphiVersionComboBoxChange(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  strict private
    _selectedinstance: TAEIDEInstance;
    Procedure RefreshInstances;
    Procedure RefreshVersions;
    Function InstanceCaption(Const inIDEInstance: TAEIDEInstance): String;
  public
    Property SelectedInstance: TAEIDEInstance Read _selectedinstance;
  End;

Implementation

Uses System.SysUtils, uRuleEngine;

{$R *.dfm}

Procedure TLaunchFileForm.DelphiVersionComboBoxChange(Sender: TObject);
Begin
  RefreshInstances;
End;

Procedure TLaunchFileForm.FormCreate(Sender: TObject);
Begin
  Self.RefreshVersions;
End;

Function TLaunchFileForm.InstanceCaption(Const inIDEInstance: TAEIDEInstance): String;
Begin
  Result := inIDEInstance.IDECaption + ' (PID: ' + inIDEInstance.PID.ToString + ')';
End;

Procedure TLaunchFileForm.OpenButtonClick(Sender: TObject);
Begin
  _selectedinstance := DelphiInstanceComboBox.Items.Objects[DelphiInstanceComboBox.ItemIndex] As TAEIDEInstance;

  If Not Assigned(_selectedinstance) Then
  Begin
    (DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion).NewInstanceParams := Self.Caption;
    (DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion).NewIDEInstance;
  End
  Else
    _selectedinstance.OpenFile(Self.Caption);

  Self.ModalResult := mrOk;
End;

Procedure TLaunchFileForm.RefreshInstances;
Var
  inst: TAEIDEInstance;
  selpid: Cardinal;
  npos: Integer;
Begin
  DelphiInstanceComboBox.Items.BeginUpdate;
  Try
    If DelphiInstanceComboBox.ItemIndex = -1 Then
      selpid := 0
    Else
      selpid := (DelphiInstanceComboBox.Items.Objects[DelphiInstanceComboBox.ItemIndex] As TAEIDEInstance).PID;

    DelphiInstanceComboBox.Items.Clear;

    If DelphiVersionComboBox.ItemIndex = -1 Then
      Exit;

    DelphiInstanceComboBox.Items.Add('New instance...');

    For inst In (DelphiVersionComboBox.Items.Objects[DelphiVersionComboBox.ItemIndex] As TAEIDEVersion).Instances Do
    Begin
      npos := DelphiInstanceComboBox.Items.AddObject(InstanceCaption(inst), inst);

      If inst.PID = selpid Then
        DelphiInstanceComboBox.ItemIndex := npos;
    End;

    If DelphiInstanceComboBox.ItemIndex = -1 Then
      DelphiInstanceComboBox.ItemIndex := 0;
  Finally
    DelphiInstanceComboBox.Items.EndUpdate;

    OpenButton.Enabled := DelphiInstanceComboBox.Items.Count > 0;
  End;
End;

Procedure TLaunchFileForm.RefreshVersions;
Var
  dver: TAEIDEVersion;
  sel, npos: Integer;
Begin
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
      Exit;

    If DelphiVersionComboBox.ItemIndex = -1 Then
      DelphiVersionComboBox.ItemIndex := DelphiVersionComboBox.Items.Count - 1;
  Finally
    DelphiVersionComboBox.Items.EndUpdate;
  End;

  DelphiInstanceComboBox.Enabled := DelphiVersionComboBox.Items.Count > 0;

  RefreshInstances;
End;

End.

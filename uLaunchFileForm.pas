{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uLaunchFileForm;

Interface

Uses System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

Type
  TLaunchFileForm = Class(TForm)
    InstancesTreeView: TTreeView;
    Timer1: TTimer;
    ButtonsPanel: TPanel;
    OpenButton: TButton;
    CancelButton: TButton;
    Procedure FormCreate(Sender: TObject);
    Procedure FormResize(Sender: TObject);
    Procedure InstancesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
    Procedure InstancesTreeViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Var DefaultDraw: Boolean);
    Procedure InstancesTreeViewChange(Sender: TObject; Node: TTreeNode);
    Procedure InstancesTreeViewDblClick(Sender: TObject);
    Procedure RefreshDisplay(Sender: TObject);
  strict private
    _loading: Boolean;
    _selectinstance: Boolean;
    _selectedobject: TObject;
  public
    Procedure DelphiVersionDetected(Const inDelphiVersion: String);
    Procedure Initialize(Const inFileName: String);
    Property SelectedObject: TObject Read _selectedobject;
  End;

Implementation

Uses System.SysUtils, uSettings, Vcl.Dialogs, System.UITypes, WinApi.Windows, Vcl.Graphics, AE.IDE.Versions;

{$R *.dfm}

Procedure TLaunchFileForm.DelphiVersionDetected(Const inDelphiVersion: String);
Var
  a: Integer;
  found: Boolean;
Begin
  found := false;

  For a := 0 To InstancesTreeView.Items.Count - 1 Do
    If InstancesTreeView.Items[a].Text = inDelphiversion Then
    Begin
      InstancesTreeView.Selected := InstancesTreeView.Items[a];
      found := True;

      Break;
    End;

  If Not found Then
    MessageDlg('Selected project was created with ' + inDelphiVersion + ', which is not installed on this PC.', mtWarning, [mbOK], 0);
End;

Procedure TLaunchFileForm.FormCreate(Sender: TObject);
Begin
  _selectinstance := False;
  _selectedobject := nil;

  If Assigned(Screen.MessageFont) Then
    Self.Font.Assign(Screen.MessageFont);

  _loading := True;
  Try
    If Settings.WindowSize[Self.ClassName].Height <> 0 Then
      Self.Height := Settings.WindowSize[Self.ClassName].Height;
    If Settings.WindowSize[Self.ClassName].Width <> 0 Then
      Self.Width := Settings.WindowSize[Self.ClassName].Width;
  Finally
    _loading := False;
  End;
End;

Procedure TLaunchFileForm.FormResize(Sender: TObject);
Begin
  If _loading Then
    Exit;

  If Self.Height <> 230 Then
    Settings.WindowSize[Self.ClassName].Height := Self.Height
  Else
    Settings.WindowSize[Self.ClassName].Height := 0;

  If Self.Width <> 495 Then
    Settings.WindowSize[Self.ClassName].Width := Self.Width
  Else
    Settings.WindowSize[Self.ClassName].Width := 0;
End;

Procedure TLaunchFileForm.Initialize(Const inFileName: String);
Begin
  Self.Caption := inFileName;

  _selectinstance := inFileName.ToLower.EndsWith('.pas') Or inFileName.ToLower.EndsWith('.dfm');

  Self.RefreshDisplay(nil);
End;

Procedure TLaunchFileForm.InstancesTreeViewChange(Sender: TObject; Node: TTreeNode);
Begin
  If Assigned(Node) Then
    _selectedobject := Node.Data
  Else
    _selectedobject := nil;

  OpenButton.Enabled := Assigned(_selectedobject);
End;

Procedure TLaunchFileForm.InstancesTreeViewCollapsing(Sender: TObject; Node: TTreeNode; Var AllowCollapse: Boolean);
Begin
  AllowCollapse := False;
End;

Procedure TLaunchFileForm.InstancesTreeViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Var DefaultDraw: Boolean);
Begin
  If TObject(Node.Data) Is TAEIDEVersion Then
    Sender.Canvas.Font.Style := [fsBold];
End;

Procedure TLaunchFileForm.InstancesTreeViewDblClick(Sender: TObject);
Begin
  If Assigned(_selectedobject) Then
    Self.ModalResult := mrOk;
End;

Procedure TLaunchFileForm.RefreshDisplay(Sender: TObject);
Var
  ver: TAEIDEVersion;
  inst: TAEIDEInstance;
  vertn, insttn, lastver: TTreeNode;
  sel: String;
Begin
  If Assigned(Sender) Then
    RuleEngine.DelphiVersions.RefreshInstalledVersions;

  lastver := nil;

  If Assigned(InstancesTreeView.Selected) Then
    sel := InstancesTreeView.Selected.Text
  Else
    sel := '';

  InstancesTreeView.Items.BeginUpdate;
  Try
    InstancesTreeView.Items.Clear;

    For ver in RuleEngine.DelphiVersions.InstalledVersions Do
    Begin
      vertn := InstancesTreeView.Items.AddChildFirst(nil, ver.Name);
      vertn.Data := ver;

      If ver.Name = sel Then
        InstancesTreeView.Selected := vertn;

      lastver := vertn;

      For inst In ver.Instances Do
      Begin
        insttn := InstancesTreeView.Items.AddChild(vertn, inst.Name);
        insttn.Data := inst;

        If inst.Name = sel Then
          InstancesTreeView.Selected := insttn;
      End;

      vertn.Expand(False);
    End;

    If sel.IsEmpty Then
      If Not _selectinstance Or Not Assigned(lastver) Or (lastver.Count = 0) Then
        InstancesTreeView.Selected := lastver
      Else
        InstancesTreeView.Selected := lastver.Item[0];
  Finally
    InstancesTreeView.Items.EndUpdate;
  End;
End;

End.

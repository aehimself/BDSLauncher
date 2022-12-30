{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uFileAssociations;

Interface

Procedure GiveBackFileAssociations;
Procedure TakeOverFileAssociations;

Implementation

Uses Win.Registry, WinApi.Windows, WinApi.ShlObj, System.SysUtils;

Const
  CLASSESROOT = '\SOFTWARE\Classes\';
  AEBDSLAUNCHERROOT = CLASSESROOT + 'AEBDSLauncher';
  BDSLAUNCHERBACKUP = 'AEBDSLauncherBackup';
  CHANGEEXTENSIONS : Array[0..4] Of String = ('.pas', '.dpr', '.dproj', '.dfm', '.groupproj');

Procedure NotifyAssociationsChange;
Begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
End;

Procedure ResetFileAssociation(Const inRegistry: TRegistry; Const inPath: String);
Var
  delkey: Boolean;
Begin
  delkey := False;

  If inRegistry.OpenKey(CLASSESROOT + inPath, False) Then
  Try
    If inRegistry.ValueExists(BDSLAUNCHERBACKUP) Then
    Begin
      inRegistry.WriteString('', inRegistry.ReadString(BDSLAUNCHERBACKUP));

      inRegistry.DeleteValue(BDSLAUNCHERBACKUP);
    End
    Else
      delkey := True;
  Finally
    inRegistry.CloseKey;
  End;

  If delkey Then
    inRegistry.DeleteKey(CLASSESROOT + inPath);
End;

Procedure GiveBackFileAssociations;
Var
  reg: TRegistry;
  extension: String;
Begin
  reg := TRegistry.Create;
  Try
    reg.RootKey := HKEY_CURRENT_USER;

    // If AEBDSLauncher does not exist, we did not take file associations over yet. In this case, do nothing!
    If Not reg.KeyExists(AEBDSLAUNCHERROOT) Then
      Exit;

    If Not reg.DeleteKey(AEBDSLAUNCHERROOT) Then
    Begin
      Exit;
    End;

    For extension In CHANGEEXTENSIONS Do
      ResetFileAssociation(reg, extension);

    NotifyAssociationsChange;
  Finally
    FreeAndNil(reg);
  End;
End;

Procedure ChangeFileAssociation(Const inRegistry: TRegistry; Const inPath: String);
Begin
  If inRegistry.OpenKey(CLASSESROOT + inPath, True) Then
  Try
    If inRegistry.ValueExists('') Then
      inRegistry.WriteString(BDSLAUNCHERBACKUP, inRegistry.ReadString(''));
    inRegistry.WriteString('', 'AEBDSLauncher');
  Finally
    inRegistry.CloseKey;
  End;
End;

Procedure TakeOverFileAssociations;
Var
  reg: TRegistry;
  extension: String;
Begin
  reg := TRegistry.Create;
  Try
    reg.RootKey := HKEY_CURRENT_USER;

    If reg.OpenKey(AEBDSLAUNCHERROOT, True) Then
    Try
      reg.WriteString('', 'AE BDSLauncher file');
    Finally
      reg.CloseKey;
    End;

    If reg.OpenKey(AEBDSLAUNCHERROOT + '\DefaultIcon', True) Then
    Try
      reg.WriteString('', ParamStr(0));
    Finally
      reg.CloseKey;
    End;

    If reg.OpenKey(AEBDSLAUNCHERROOT + '\shell\open\command', True) Then
    Try
      reg.WriteString('', ParamStr(0) + ' "%1"');
    Finally
      reg.CloseKey;
    End;

    For extension In CHANGEEXTENSIONS Do
      ChangeFileAssociation(reg, extension);

    NotifyAssociationsChange;
  Finally
    FreeAndNil(reg);
  End;
End;

End.

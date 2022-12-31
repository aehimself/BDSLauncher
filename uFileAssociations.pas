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
  CHANGEEXTENSIONS : Array[0..5] Of String = ('.pas', '.dpr', '.dproj', '.dfm', '.groupproj', '.dpk');

Procedure NotifyAssociationsChange;
Begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
End;

//
// Giving back file associations
//

Procedure InternalGiveBackFileAssociations(Const inRegistry: TRegistry; Const inPath: String);
Var
  rootkeyfound, delkey: Boolean;
Begin
  // Revert taken over associations back to their previous ones (if there were any). If there was no association before taking over
  // we have to delete the keys, but reverting twice in a row should not do anything!

  delkey := False;
  rootkeyfound := inRegistry.KeyExists(AEBDSLAUNCHERROOT + inPath);

  // If our key exists, delete it
  If rootkeyfound Then
    inRegistry.DeleteKey(AEBDSLAUNCHERROOT + inPath);

  If inRegistry.OpenKey(CLASSESROOT + inPath, False) Then
  Try
    If inRegistry.ValueExists(BDSLAUNCHERBACKUP) Then
    Begin
      inRegistry.WriteString('', inRegistry.ReadString(BDSLAUNCHERBACKUP));

      inRegistry.DeleteValue(BDSLAUNCHERBACKUP);

      // If backup value exists there was an association for sure, therefore the association must not be deleted, no matter what
      delkey := False;
    End
    Else
      // No backup key was found. This can mean there was no previous association OR we are reverting from a non-taken-over
      // state. Therefore, association only has to be deleted if our key was found!
      delkey := rootkeyfound;
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

    For extension In CHANGEEXTENSIONS Do
      InternalGiveBackFileAssociations(reg, extension);

    NotifyAssociationsChange;
  Finally
    FreeAndNil(reg);
  End;
End;

//
// Taking over file associations
//

Procedure InternalTakeOverFileAssociations(Const inRegistry: TRegistry; Const inPath: String);
Var
  oldtarget, description, friendlytname, icon: String;
Begin
  // There are only two things we should consider here: taking over the second time should have zero effect whatsoever
  // and maybe there are no associations for this file type yet.

  // Open the current file extension assignment, back up the old association and change it to the new one
  If inRegistry.OpenKey(CLASSESROOT + inPath, True) Then
  Try
    oldtarget := '';

    If Not inRegistry.ValueExists(BDSLAUNCHERBACKUP) Then
    Begin
      If inRegistry.ValueExists('') Then
      Begin
        oldtarget := inRegistry.ReadString('');
        inRegistry.WriteString(BDSLAUNCHERBACKUP, oldtarget);
      End;

      inRegistry.WriteString('', 'AEBDSLauncher' + inPath);
    End;
  Finally
    inRegistry.CloseKey;
  End;

  If inRegistry.KeyExists(AEBDSLAUNCHERROOT + inPath) Then
    Exit;

  // Look for the old association and extract description, friendly type name and icon to use
  description := '';
  friendlytname := '';
  If inRegistry.OpenKey(CLASSESROOT + oldtarget, False) Then
  Try
    If inRegistry.ValueExists('') Then
      description := inRegistry.ReadString('');

    If inRegistry.ValueExists('FriendlyTypeName') Then
      friendlytname := inRegistry.ReadString('FriendlyTypeName');
  Finally
    inRegistry.CloseKey;
  End;

  icon := '';
  If inRegistry.OpenKey(CLASSESROOT + oldtarget + '\DefaultIcon', False) Then
  Try
    If inRegistry.ValueExists('') Then
      icon := inRegistry.ReadString('');
  Finally
    inRegistry.CloseKey;
  End;

  // Now, create our own association with the previously collected information
  If description.IsEmpty Then
    description := 'AE BDSLauncher file';
  If inRegistry.OpenKey(AEBDSLAUNCHERROOT + inPath, True) Then
  Try
    inRegistry.WriteString('', description);

    If Not friendlytname.IsEmpty Then
      inRegistry.WriteString('FriendlyTypeName', friendlytname);
  Finally
    inRegistry.CloseKey;
  End;

  If inRegistry.OpenKey(AEBDSLAUNCHERROOT + inPath + '\Shell\Open\Command', True) Then
  Try
    inRegistry.WriteString('', ParamStr(0) + ' "%1"');
  Finally
    inRegistry.CloseKey;
  End;

  If icon.IsEmpty Then
    icon := ParamStr(0);
  If inRegistry.OpenKey(AEBDSLAUNCHERROOT + inPath+ '\DefaultIcon', True) Then
  Try
    inRegistry.WriteString('', icon);
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

    For extension In CHANGEEXTENSIONS Do
      InternalTakeOverFileAssociations(reg, extension);

    NotifyAssociationsChange;
  Finally
    FreeAndNil(reg);
  End;
End;

End.

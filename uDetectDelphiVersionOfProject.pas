{
  AE BDS Launcher © 2023 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uDetectDelphiVersionOfProject;

Interface

Function DetectDelphiVersion(Const inFileName: String): String;

Implementation

Uses AE.IDE.Versions.Consts, System.SysUtils, System.IniFiles, System.IOUtils;

// https://delphi.fandom.com/wiki/How_to_find_out_which_Delphi_version_was_used_to_create_a_project%3F

Procedure GetVersionAndExcludedSuffix(Const inFileText: String; Var outVersionNumber, outExcludedSuffix: Integer);
Const
  VERSTART = '<ProjectVersion>';
  VEREND = '</ProjectVersion>';
  EXCLSTART = '<Excluded_Packages Name="';
  EXCLEND = '">';
Var
 startindex, endindex, cpos: Integer;
 s: String;
Begin
  outVersionNumber := 0;
  outExcludedSuffix := 0;

  startindex := inFileText.IndexOf(VERSTART);
  If startindex > -1 Then
  Begin
    Inc(startindex, VERSTART.Length);
    endindex := inFileText.IndexOf(VEREND, startindex);
    s := inFileText.Substring(startindex, endindex - startindex).Replace('.', '').Replace(',', '');
    outVersionNumber := Integer.Parse(s);
  End;

  startindex := inFiletext.IndexOf(EXCLSTART);
  If startindex > -1 Then
  Begin
    Inc(startindex, EXCLSTART.Length);
    endindex := inFileText.IndexOf(EXCLEND, startindex);
    s := inFileText.Substring(startindex, endindex - startindex);

    cpos := 0;
    Repeat
      cpos := s.IndexOf('.bpl', cpos);
      If cpos > -1 Then
      Begin
        Integer.TryParse(s.Substring(cpos - 3, 3), outExcludedSuffix);
        Inc(cpos, 4);
      End;
    Until (cpos = -1) Or (outExcludedSuffix > 0);
  End;
End;


Function CheckFromDProj(Const inDPROJFileName: String): String;
Var
  ver, suffix: Integer;
Begin
  Result := '';

  If Not FileExists(inDPROJFileName) Then
    Exit;

  GetVersionAndExcludedSuffix(TFile.ReadAllText(inDPROJFileName), ver, suffix);

  {$REGION 'Attempt to identify exact version based on version number'}
  Case ver Of
    122, 123:
      Result := IDEVER_DELPHIXE;
    134:
        Result := IDEVER_DELPHIXE2;
    143:
      Result := IDEVER_DELPHIXE3;
    146:
      Result := IDEVER_DELPHIXE4;
    151, 153:
      Result := IDEVER_DELPHIXE5;
    154:
      Result := IDEVER_DELPHIXE6;
    160, 161:
      Result := IDEVER_DELPHIXE7;
    171, 172:
      Result := IDEVER_DELPHIXE8;
    180:
      Result := IDEVER_DELPHI10;
    183, 184:
      Result := IDEVER_DELPHI102;
    185, 186, 187, 188:
      Result := IDEVER_DELPHI103;
    190, 191, 192:
      Result := IDEVER_DELPHI104;
    193, 194, 195:
      Result := IDEVER_DELPHI11;
    201, 202:
      Result := IDEVER_DELPHI12;
  End;
  {$ENDREGION}

  {$REGION 'If that fails, attempt to determine version from excluded package suffix - if there''s any'}
  If Result.IsEmpty And (suffix <> 0) Then
    Case suffix Of
      110:
        Result := IDEVER_DELPHI2007;
      120:
        Result := IDEVER_DELPHI2009;
      140:
        Result := IDEVER_DELPHI2010;
      150:
        Result := IDEVER_DELPHIXE;
      160:
        Result := IDEVER_DELPHIXE2;
      170:
        Result := IDEVER_DELPHIXE3;
      180:
        Result := IDEVER_DELPHIXE4;
      190:
        Result := IDEVER_DELPHIXE5;
      200:
        Result := IDEVER_DELPHIXE6;
      210:
        Result := IDEVER_DELPHIXE7;
      220:
        Result := IDEVER_DELPHIXE8;
      230:
        Result := IDEVER_DELPHI10;
      240:
        Result := IDEVER_DELPHI101;
      250:
        Result := IDEVER_DELPHI102;
      260:
        Result := IDEVER_DELPHI103;
      270:
        Result := IDEVER_DELPHI104;
      280:
        Result := IDEVER_DELPHI11;
      290:
        Result := IDEVER_DELPHI12;
    End;
  {$ENDREGION}
End;

Function CheckFromBDSProj(Const inBDSProjFileName: String): String;
Var
  ver, suffix: Integer;
Begin
  Result := '';

  If Not FileExists(inBDSProjFileName) Then
    Exit;

  GetVersionAndExcludedSuffix(TFile.ReadAllText(inBDSProjFileName), ver, suffix);

  Case suffix Of
    90:
      Result := IDEVER_DELPHI2005;
    100:
      Result := IDEVER_DELPHI2006;
  End;
End;

Function CheckFromDof(Const inDOFFileName: String): String;
Var
  dof: TINIFile;
Begin
  Result := '';

  If Not FileExists(inDOFFileName) Then
    Exit;

  dof := TINIFile.Create(inDOFFileName);
  Try
    Result := dof.ReadString('FileVersion', 'Version', '');

    If Result = '6.0' Then
      Result := IDEVER_DELPHI6
    Else If Result = '7.0' Then
      Result := IDEVER_DELPHI7
    Else If Not Result.IsEmpty Then
      Result := '';
  Finally
    FreeAndNil(dof);
  End;
End;

Function DetectDelphiVersion(Const inFileName: String): String;
Begin
  Result := '';

  // Delphi version detection is only possible if the file to be opened is .dpr, .dproj or .bdsproj.
  If Not inFileName.ToLower.EndsWith('.dpr') And Not inFileName.ToLower.EndsWith('.dproj') And Not inFileName.ToLower.EndsWith('.bdsproj') Then
    Exit;

  Result := CheckFromDProj(ChangeFileExt(inFileName, '.dproj'));
  If Not Result.IsEmpty Then
    Exit;

  Result := CheckFromBDSProj(ChangeFileExt(inFileName, '.bdsproj'));
  If Not Result.IsEmpty Then
    Exit;

  Result := CheckFromDOF(ChangeFileExt(inFileName, '.dof'));
End;

End.

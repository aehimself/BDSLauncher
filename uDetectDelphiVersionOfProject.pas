Unit uDetectDelphiVersionOfProject;

Interface

Function DetectDelphiVersion(Const inFileName: String): String;

Implementation

Uses AE.IDE.Versions.Consts, System.SysUtils;

Function DetectDelphiVersion(Const inFileName: String): String;
Begin
  Result := '';

  // Delphi version detection is only possible if the file to be opened is .dpr or .dproj.
  If Not inFileName.ToLower.EndsWith('.dpr') Or Not inFileName.ToLower.EndsWith('.dproj') Then
    Exit;


End;

End.

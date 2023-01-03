{
  AE BDS Launcher © 2023 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uBDSLogger;

Interface

Type
  TBDSLogger = Class
  strict private
    _fname: String;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure Log(inLineToLog: String);
  End;

Function BDSLogger: TBDSLogger;

Implementation

Uses uSettings, System.SysUtils, System.IOUtils;

Var
  _logger: TBDSLogger;

Function BDSLogger: TBDSLogger;
Begin
  If Not Assigned(_logger) Then
    _logger := TBDSLogger.Create;

  Result := _logger;
End;

Constructor TBDSLogger.Create;
Begin
  _fname := ChangeFileExt(Settings.SettingsFileName, '.log');
End;

Destructor TBDSLogger.Destroy;
Begin
  If Settings.EnableLogging Then
    TFile.AppendAllText(_fname, sLineBreak);

  inherited;
End;

Procedure TBDSLogger.Log(inLineToLog: String);
Begin
  If Not Settings.EnableLogging Then
    Exit;

  inLineToLog := Format('[%s]  %s', [DateTimeToStr(Now), inLineToLog]);

  If Not TFile.Exists(_fname) Then
    TFile.WriteAllBytes(_fname, TEncoding.UTF8.GetPreamble)
  Else
    inLineToLog := sLineBreak + inLineToLog;

  TFile.AppendAllText(_fname, inLineToLog, TEncoding.UTF8);
End;

Initialization
  _logger := nil;

Finalization
  FreeAndNil(_logger);

End.

program BDSLauncher;

uses
  Vcl.Forms,
  uBDSLogger in 'uBDSLogger.pas',
  uSettings in 'uSettings.pas',
  uBDSLauncherMainForm in 'uBDSLauncherMainForm.pas' {BDSLauncherMainForm},
  uLaunchFileForm in 'uLaunchFileForm.pas' {LaunchFileForm},
  uFileAssociations in 'uFileAssociations.pas',
  uDetectDelphiVersionOfProject in 'uDetectDelphiVersionOfProject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'AE BDS Launcher';
  Application.CreateForm(TBDSLauncherMainForm, BDSLauncherMainForm);
  Application.Run;
end.

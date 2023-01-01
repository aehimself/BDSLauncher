program BDSLauncher;



uses
  Vcl.Forms,
  uBDSLauncherMainForm in 'uBDSLauncherMainForm.pas' {BDSLauncherMainForm},
  uLaunchFileForm in 'uLaunchFileForm.pas' {LaunchFileForm},
  uRuleEngine in 'uRuleEngine.pas',
  uFileAssociations in 'uFileAssociations.pas',
  uDetectDelphiVersionOfProject in 'uDetectDelphiVersionOfProject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TBDSLauncherMainForm, BDSLauncherMainForm);
  Application.Run;
end.

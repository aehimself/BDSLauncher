{
  AE BDS Launcher © 2023 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uSettings;

Interface

Uses AE.Application.Setting, AE.Application.Settings, System.Generics.Collections, AE.IDE.DelphiVersions, AE.IDE.Versions, System.JSON;

Type
  TRule = Class(TAEApplicationSetting)
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    AlwaysNewInstance: Boolean;
    FileMasks: String;
    DelphiVersion: String;
    InstanceCaptionContains: String;
    NewInstanceParams: String;
    Order: Word;
    Function DisplayName: String;
  End;

  TRuleEngine = Class(TAEApplicationSetting)
  strict private
    _dvers: TAEDelphiVersions;
    _rules: TObjectDictionary<String, TRule>;
    Procedure SetRule(Const inRuleName: String; Const inRule: TRule);
    Function Compare(Const inItem1, inItem2: String): Integer;
    Function GetRule(Const inRuleName: String): TRule;
    Function GetRules: TArray<String>;
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Constructor Create; Override;
    Destructor Destroy; Override;
    Procedure RenameRule(Const inRuleName, inNewName: String);
    Function ContainsRule(Const inRuleName: String): Boolean;
    Function LaunchByRules(Const inFileName, inAutoDetectedVersion: String): Boolean;
    Property DelphiVersions: TAEDelphiVersions Read _dvers;
    Property Rule[Const inRuleName: String]: TRule Read GetRule Write SetRule;
    Property Rules: TArray<String> Read GetRules;
  End;

  TSettings = Class(TAEApplicationSettings)
  strict private
    _ruleengine: TRuleEngine;
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    EnableLogging: Boolean;
    MainWindowHeight: Integer;
    MainWindowWidth: Integer;
    RuleListWidth: Integer;
    SelectorWidth: Integer;
    Constructor Create(Const inSettingsFileName: String); Override;
    Destructor Destroy; Override;
    Property RuleEngine: TRuleEngine Read _ruleengine;
  End;

Function RuleEngine: TRuleEngine;
Function Settings: TSettings;

Implementation

Uses System.SysUtils, System.Masks, System.Generics.Defaults, uBDSLogger;

Const
  TXT_ALWAYSNEWINSTANCE = 'alwaysnewinstance';
  TXT_FILEMASKS = 'filemasks';
  TXT_DELPHIVERSION = 'delphiversion';
  TXT_INSTANCECAPTIONCONTAINS = 'instancecaptioncontains';
  TXT_NEWINSTANCEPARAMS = 'newinstanceparams';
  TXT_ORDER = 'order';
  TXT_RULES = 'rules';
  TXT_ENABLELOGGING = 'enablelogging';
  TXT_SELECTORWIDTH = 'selectorwidth';
  TXT_MAINWINDOWWIDTH = 'mainwindowwidth';
  TXT_MAINWINDOWHEIGHT = 'mainwindowheight';
  TXT_RULELISTWIDTH = 'rulelistwidth';

Var
  _settings: TSettings;

Function RuleEngine: TRuleEngine;
Begin
  Result := Settings.RuleEngine;
End;

Function Settings: TSettings;
Begin
  If Not Assigned(_settings) Then
    _settings := TSettings.New(slAppData) As TSettings;

  Result := _settings;
End;

//
// TRule
//

Function TRule.DisplayName: String;
Begin
  If Self.DelphiVersion.IsEmpty Then
    Result := 'Auto-detect Delphi version, or use latest' + sLineBreak
  Else
    Result := 'Explicitly use ' + Self.DelphiVersion + sLineBreak;

  If Self.AlwaysNewInstance Then Result := Result + 'Always in new instance'
    Else
  If Not Self.InstanceCaptionContains.IsEmpty Then
    Result := Result + 'Find instance with "' + Self.InstanceCaptionContains + '" in caption'
  Else
    Result := Result + 'Any opened instance';
End;

Function TRule.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Self.AlwaysNewInstance Then
    Result.AddPair(TXT_ALWAYSNEWINSTANCE, TJSONBool.Create(Self.AlwaysNewInstance));

  If Not Self.DelphiVersion.IsEmpty Then
    Result.AddPair(TXT_DELPHIVERSION, Self.DelphiVersion);

  If Not Self.FileMasks.IsEmpty Then
    Result.AddPair(TXT_FILEMASKS, Self.FileMasks);

  If Not Self.InstanceCaptionContains.IsEmpty Then
    Result.AddPair(TXT_INSTANCECAPTIONCONTAINS, Self.InstanceCaptionContains);

  If Not Self.NewInstanceParams.IsEmpty Then
    Result.AddPair(TXT_NEWINSTANCEPARAMS, Self.NewInstanceParams);

  If Self.Order <> 0 Then
    Result.AddPair(TXT_ORDER, TJSONNumber.Create(Self.Order));
End;

Procedure TRule.InternalClear;
Begin
  inherited;

  Self.AlwaysNewInstance := False;
  Self.DelphiVersion := '';
  Self.FileMasks := '';
  Self.InstanceCaptionContains := '';
  Self.NewInstanceParams := '';
  Self.Order := 0;
End;

Procedure TRule.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  inJSON.TryGetValue<Boolean>(TXT_ALWAYSNEWINSTANCE, Self.AlwaysNewInstance);
  inJSON.TryGetValue<String>(TXT_DELPHIVERSION, Self.DelphiVersion);
  inJSON.TryGetValue<String>(TXT_FILEMASKS, Self.FileMasks);
  inJSON.TryGetValue<String>(TXT_INSTANCECAPTIONCONTAINS, Self.InstanceCaptionContains);
  inJSON.TryGetValue<String>(TXT_NEWINSTANCEPARAMS, Self.NewInstanceParams);
  inJSON.TryGetValue<Word>(TXT_ORDER, Self.Order);
End;

//
// TRuleEngine
//

Function TRuleEngine.Compare(Const inItem1, inItem2: String): Integer;
Begin
  // From help:
  // Result is less than zero     ->  inItem1 is less than inItem2 (BEFORE in list)
  // Result is equal to zero      ->  inItem1 is equal to inItem2
  // Result is greater than zero  ->  inItem1 is greater than inItem2 (AFTER in list)

  Result := _rules[inItem1].Order - _rules[inItem2].Order;
End;

Function TRuleEngine.ContainsRule(Const inRuleName: String): Boolean;
Begin
  Result := _rules.ContainsKey(inRuleName);
End;

Constructor TRuleEngine.Create;
Begin
  inherited;

  _dvers := TAEDelphiVersions.Create(nil);
  _rules := TObjectDictionary<String, TRule>.Create([doOwnsValues]);
End;

Destructor TRuleEngine.Destroy;
Begin
  FreeAndNil(_dvers);
  FreeAndNil(_rules);

  inherited;
End;

Function TRuleEngine.LaunchByRules(Const inFileName, inAutoDetectedVersion: String): Boolean;
Var
  rulename, mask: String;
  rule: TRule;
  ver, lastmatchedversion: TAEIDEVersion;
  inst: TAEIDEInstance;
  anymatch: Boolean;
Begin
  Result := False;

  _dvers.RefreshInstalledVersions;

  lastmatchedversion := nil;

  For rulename In Self.Rules Do
  Begin
    rule := Self.Rule[rulename];

    BDSLogger.Log('Checking with rule #' + rule.Order.ToString + ': ' + rulename);

    // Rule was not set up for this file pattern
    anymatch := False;
    For mask In rule.FileMasks.Split([sLineBreak]) Do
      anymatch := anymatch Or MatchesMask(inFileName, mask);

    If Not anymatch Then
    Begin
      BDSLogger.Log('None of the file masks in the rule matched the input file!');

      Continue;
    End;

    If Not rule.DelphiVersion.IsEmpty Then
      ver := _dvers.VersionByName(rule.DelphiVersion) // Rule explicitly specified a Delphi version
    Else If Not inAutoDetectedVersion.IsEmpty Then
      ver := _dvers.VersionByName(inAutoDetectedVersion) // Auto detection was enabled, version could be detected
    Else
      ver := _dvers.LatestVersion; // Auto detection was specified by the rule, but version was not detected. In this case, use the latest

    // Delphi version requested by this rule is not installed (?)
    If Not Assigned(ver) Then
    Begin
      BDSLogger.Log('No suitable Delphi versions requested by the rule were found!');

      Continue;
    End;

    If rule.AlwaysNewInstance Then
    Begin
      BDSLogger.Log('Starting a new instance of ' + ver.Name + ' as defined in the rule...');

      ver.NewInstanceParams := rule.NewInstanceParams;
      ver.NewIDEInstance.OpenFile(inFileName);

      Result := True;
      Exit;
    End
    Else If Not rule.InstanceCaptionContains.IsEmpty Then
    Begin
      BDSLogger.Log('Searching for an instance of ' + ver.Name + ' which has ' + rule.InstanceCaptionContains + ' in it''s caption...');

      For inst In ver.Instances Do
        If inst.IDECaption.ToLower.Contains(rule.InstanceCaptionContains.ToLower) Then
        Begin
          BDSLogger.Log(ver.Name + ' - ' + inst.IDECaption + ' (PID: ' + inst.PID.ToString + ') selected.');

          inst.OpenFile(inFileName);

          Result := True;
          Exit;
        End;
    End
    Else If Length(ver.Instances) > 0 Then
    Begin
      inst := ver.Instances[0];

      BDSLogger.Log(ver.Name + ' - ' + inst.IDECaption + ' (PID: ' + inst.PID.ToString + ') selected.');

      inst.OpenFile(inFileName);

      Result := True;
      Exit;
    End;

    BDSLogger.Log('No suitable ' + ver.Name + ' instances found for this rule. If no other rule launches this file, a new instance of it will be launched.');

    lastmatchedversion := ver;
    lastmatchedversion.NewInstanceParams := rule.NewInstanceParams;
  End;

  If Assigned(lastmatchedversion) Then
  Begin
    BDSLogger.Log('No rules found a suitable intance to start this file. Launching a new instance of ' + lastmatchedversion.name + '...');

    lastmatchedversion.NewIDEInstance.OpenFile(inFileName);
    Result := True;
  End;
End;

Procedure TRuleEngine.RenameRule(Const inRuleName, inNewName: String);
Begin
  _rules.Add(inNewName, _rules.ExtractPair(inRuleName).Value);
End;

Function TRuleEngine.GetAsJSON: TJSONObject;
Var
  rulename: String;
Begin
  Result := inherited;

  For rulename In Self.Rules Do
    Result.AddPair(rulename, _rules[rulename].AsJSON);
End;

Function TRuleEngine.GetRule(Const inRuleName: String): TRule;
Begin
  If Not _rules.ContainsKey(inRuleName) Then
    _rules.Add(inRuleName, TRule.Create);

  Result := _rules[inRuleName];
End;

Function TRuleEngine.GetRules: TArray<String>;
Begin
  Result := _rules.Keys.ToArray;

  TArray.Sort<String>(Result, TComparer<String>.Construct(Compare));
End;

Procedure TRuleEngine.InternalClear;
Begin
  inherited;

  _rules.Clear;
End;

Procedure TRuleEngine.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
Begin
  inherited;

  For jp In inJSON Do
    _rules.Add(jp.JsonString.Value, TRule.NewFromJSON(jp.JsonValue) As TRule);
End;

Procedure TRuleEngine.SetRule(Const inRuleName: String; Const inRule: TRule);
Begin
  If Assigned(inRule) Then
    _rules.AddOrSetValue(inRuleName, inRule)
  Else
    _rules.Remove(inRuleName);
End;

//
// TSettings
//

Constructor TSettings.Create(Const inSettingsFileName: String);
Begin
  inherited;

  _ruleengine := TRuleEngine.Create;
End;

Destructor TSettings.Destroy;
Begin
  FreeAndNil(_ruleengine);

  inherited;
End;

Function TSettings.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Self.EnableLogging Then
    Result.AddPair(TXT_ENABLELOGGING, TJSONBool.Create(Self.EnableLogging));
  If Length(_ruleengine.Rules) > 0 Then
    Result.AddPair(TXT_RULES, _ruleengine.AsJSON);
  If Self.MainWindowHeight <> 450 Then
    Result.AddPair(TXT_MAINWINDOWHEIGHT, TJSONNumber.Create(Self.MainWindowHeight));
  If Self.MainWindowWidth <> 637 Then
    Result.AddPair(TXT_MAINWINDOWWIDTH, TJSONNumber.Create(Self.MainWindowWidth));
  If Self.RuleListWidth <> 392 Then
    Result.AddPair(TXT_RULELISTWIDTH, TJSONNumber.Create(Self.RuleListWidth));
  If Self.SelectorWidth <> 322 Then
    Result.AddPair(TXT_SELECTORWIDTH, TJSONNumber.Create(Self.SelectorWidth));
End;

Procedure TSettings.InternalClear;
Begin
  inherited;

  _ruleengine.Clear;
  Self.EnableLogging := False;
  Self.MainWindowHeight := 450;
  Self.MainWindowWidth := 637;
  Self.RuleListWidth := 392;
  Self.SelectorWidth := 322;
End;

Procedure TSettings.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  inJSON.TryGetValue<Boolean>(TXT_ENABLELOGGING, Self.EnableLogging);
  If inJSON.GetValue(TXT_RULES) <> nil Then
    _ruleengine.AsJSON := inJSON.GetValue<TJSONObject>(TXT_RULES);
  inJSON.TryGetValue<Integer>(TXT_MAINWINDOWHEIGHT, Self.MainWindowHeight);
  inJSON.TryGetValue<Integer>(TXT_MAINWINDOWWIDTH, Self.MainWindowWidth);
  inJSON.TryGetValue<Integer>(TXT_RULELISTWIDTH, Self.RuleListWidth);
  inJSON.TryGetValue<integer>(TXT_SELECTORWIDTH, Self.SelectorWidth);
End;

Initialization
  _settings := nil;

Finalization
  FreeAndNil(_settings);

End.

{
  AE BDS Launcher © 2022 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit uRuleEngine;

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

  TRuleEngine = Class(TAEApplicationSettings)
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
    Constructor Create(Const inSettingsFileName: String); Override;
    Destructor Destroy; Override;
    Function LaunchByRules(Const inFileName, inAutoDetectedVersion: String): Boolean;
    Property DelphiVersions: TAEDelphiVersions Read _dvers;
    Property Rule[Const inRuleName: String]: TRule Read GetRule Write SetRule;
    Property Rules: TArray<String> Read GetRules;
  End;

Var
  RuleEngine: TRuleEngine;

Implementation

Uses System.SysUtils, System.Masks, System.Generics.Defaults;

Const
  TXT_ALWAYSNEWINSTANCE = 'alwaysnewinstance';
  TXT_FILEMASKS = 'filemasks';
  TXT_DELPHIVERSION = 'delphiversion';
  TXT_INSTANCECAPTIONCONTAINS = 'instancecaptioncontains';
  TXT_NEWINSTANCEPARAMS = 'newinstanceparams';
  TXT_ORDER = 'order';

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

Constructor TRuleEngine.Create(Const inSettingsFileName: String);
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

    // Rule was not set up for this file pattern
    anymatch := False;
    For mask In rule.FileMasks.Split([sLineBreak]) Do
      anymatch := anymatch Or MatchesMask(inFileName, mask);
    If Not anymatch Then Continue;

    If Not rule.DelphiVersion.IsEmpty Then
      ver := _dvers.VersionByName(rule.DelphiVersion) // Rule explicitly specified a Delphi version
    Else If Not inAutoDetectedVersion.IsEmpty Then
      ver := _dvers.VersionByName(inAutoDetectedVersion) // Auto detection was enabled, version could be detected
    Else
      ver := _dvers.LatestVersion; // Auto detection was specified by the rule, but version was not detected. In this case, use the latest

    // Delphi version requested by this rule is not installed (?)
    If Not Assigned(ver) Then
      Continue;

    If rule.AlwaysNewInstance Then
    Begin
      ver.NewInstanceParams := rule.NewInstanceParams;
      ver.NewIDEInstance.OpenFile(inFileName);

      Result := True;
      Exit;
    End
    Else
      For inst In ver.Instances Do
        If inst.IDECaption.ToLower.Contains(rule.InstanceCaptionContains.ToLower) Then
        Begin
          inst.OpenFile(inFileName);

          Result := True;
          Exit;
        End;

    lastmatchedversion := ver;
    lastmatchedversion.NewInstanceParams := rule.NewInstanceParams;
  End;

  If Assigned(lastmatchedversion) Then
  Begin
    lastmatchedversion.NewIDEInstance.OpenFile(inFileName);
    Result := True;
  End;
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

Initialization
  RuleEngine := TRuleEngine.New(slAppData) As TRuleEngine;

Finalization
  FreeAndNil(RuleEngine);

End.

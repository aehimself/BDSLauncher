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
    Property DelphiVersions: TAEDelphiVersions Read _dvers;
    Property Rule[Const inRuleName: String]: TRule Read GetRule Write SetRule;
    Property Rules: TArray<String> Read GetRules;
  End;

  TWindowSize = Class(TAEApplicationSetting)
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Height: Integer;
    Width: Integer;
  End;

  TSettings = Class(TAEApplicationSettings)
  strict private
    _ruleengine: TRuleEngine;
    _windows: TObjectDictionary<String, TWindowSize>;
    Procedure SetWindowSize(Const inWindowClass: String; Const inWindowSize: TWindowSize);
    Function GetWindowSize(Const inWindowClass: String): TWindowSize;
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    EnableLogging: Boolean;
    RuleListWidth: Integer;
    Constructor Create(Const inSettingsFileName: String); Override;
    Destructor Destroy; Override;
    Property RuleEngine: TRuleEngine Read _ruleengine;
    Property WindowSize[Const inWindowClass: String]: TWindowSize Read GetWindowSize Write SetWindowSize;
  End;

Function RuleEngine: TRuleEngine;
Function Settings: TSettings;

Implementation

Uses System.SysUtils, System.Generics.Defaults;

Resourcestring
  RULE_VERSION_AUTODETECT = 'Auto detect or use latest';
  RULE_VERSION_EXPLICIT = 'Explicitly use %s';
  RULE_INSTANCE_ALWAYSNEW = 'Always in new instance';
  RULE_INSTANCE_CAPTIONFILTER = 'Find instance with "%s" in caption';
  RULE_INSTANCE_ANY = 'Any instance';

Const
  TXT_ALWAYSNEWINSTANCE = 'alwaysnewinstance';
  TXT_FILEMASKS = 'filemasks';
  TXT_DELPHIVERSION = 'delphiversion';
  TXT_INSTANCECAPTIONCONTAINS = 'instancecaptioncontains';
  TXT_NEWINSTANCEPARAMS = 'newinstanceparams';
  TXT_ORDER = 'order';
  TXT_RULES = 'rules';
  TXT_ENABLELOGGING = 'enablelogging';
  TXT_RULELISTWIDTH = 'rulelistwidth';
  TXT_HEIGHT = 'height';
  TXT_WIDTH = 'width';
  TXT_WINDOWS = 'windows';

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
    Result := RULE_VERSION_AUTODETECT + sLineBreak
  Else
    Result := Format(RULE_VERSION_EXPLICIT, [Self.DelphiVersion]) + sLineBreak;

  If Self.AlwaysNewInstance Then Result := Result + RULE_INSTANCE_ALWAYSNEW
    Else
  If Not Self.InstanceCaptionContains.IsEmpty Then
    Result := Result + Format(RULE_INSTANCE_CAPTIONFILTER, [Self.InstanceCaptionContains])
  Else
    Result := Result + RULE_INSTANCE_ANY;
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
// TWindowSize
//

Function TWindowSize.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Self.Height <> 0 Then
    Result.AddPair(TXT_HEIGHT, TJSONNumber.Create(Self.Height));

  if Self.Width <> 0 Then
    Result.AddPair(TXT_WIDTH, TJSONNumber.Create(Self.Width))
End;

Procedure TWindowSize.InternalClear;
Begin
  inherited;

  Self.Height := 0;
  Self.Width := 0;
End;

Procedure TWindowSize.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  inJSON.TryGetValue<Integer>(TXT_HEIGHT, Self.Height);
  inJSON.TryGetValue<Integer>(TXT_WIDTH, Self.Width);
End;

//
// TSettings
//

Constructor TSettings.Create(Const inSettingsFileName: String);
Begin
  inherited;

  _ruleengine := TRuleEngine.Create;
  _windows := TObjectDictionary<String, TWindowSize>.Create([doOwnsValues]);
End;

Destructor TSettings.Destroy;
Begin
  FreeAndNil(_ruleengine);
  FreeAndNil(_windows);

  inherited;
End;

Function TSettings.GetAsJSON: TJSONObject;
Var
  winclass: String;
  winjson, json: TJSONObject;
Begin
  Result := inherited;

  If Self.EnableLogging Then
    Result.AddPair(TXT_ENABLELOGGING, TJSONBool.Create(Self.EnableLogging));
  If Length(_ruleengine.Rules) > 0 Then
    Result.AddPair(TXT_RULES, _ruleengine.AsJSON);

  If Self.RuleListWidth <> 0 Then
    Result.AddPair(TXT_RULELISTWIDTH, TJSONNumber.Create(Self.RuleListWidth));

  If _windows.Count > 0 Then
  Begin
    winjson := TJSONObject.Create;
    Try
      For winclass In _windows.Keys Do
      Begin
        json := _windows[winclass].AsJSON;

        If json.Count = 0 Then
          FreeAndNil(json)
        Else
          winjson.AddPair(winclass, json);
      End;
    Finally
      If winjson.Count = 0 Then
        FreeAndNil(winjson)
      Else
        Result.AddPair(TXT_WINDOWS, winjson);
    End;
  End;
End;

Function TSettings.GetWindowSize(Const inWindowClass: String): TWindowSize;
Begin
  If Not _windows.ContainsKey(inWindowClass) Then
    _windows.Add(inWindowClass, TWindowSize.Create);

  Result := _windows[inWindowClass];
End;

Procedure TSettings.InternalClear;
Begin
  inherited;

  _ruleengine.Clear;
  Self.EnableLogging := False;
  Self.RuleListWidth := 0;
  _windows.Clear;
End;

Procedure TSettings.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
Begin
  inherited;

  inJSON.TryGetValue<Boolean>(TXT_ENABLELOGGING, Self.EnableLogging);
  If inJSON.GetValue(TXT_RULES) <> nil Then
    _ruleengine.AsJSON := inJSON.GetValue<TJSONObject>(TXT_RULES);
  inJSON.TryGetValue<Integer>(TXT_RULELISTWIDTH, Self.RuleListWidth);

  If inJSON.GetValue(TXT_WINDOWS) <> nil Then
    For jp In inJSON.GetValue<TJSONObject>(TXT_WINDOWS) Do
      _windows.Add(jp.JsonString.Value, TWindowSize.NewFromJSON(jp.JsonValue) As TWindowSize);
End;

Procedure TSettings.SetWindowSize(Const inWindowClass: String; Const inWindowSize: TWindowSize);
Begin
  If Assigned(inWindowSize) Then
    _windows.AddOrSetValue(inWindowClass, inWindowSize)
  Else
    _windows.Remove(inWindowClass);
End;

Initialization
  _settings := nil;

Finalization
  FreeAndNil(_settings);

End.

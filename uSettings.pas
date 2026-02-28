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
    _alwaysnewinstance: Boolean;
    _filemasks: String;
    _delphiversion: String;
    _instancecaptioncontains: String;
    _newinstanceparams: String;
    _order: Word;
    Procedure InternalClear; Override;
    Procedure SetAlwaysNewInstance(Const inAlwaysNewInstance: Boolean);
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Procedure SetFileMasks(Const inFileMasks: String);
    Procedure SetDelphiVersion(Const inDelphiVersion: String);
    Procedure SetInstanceCaptionContains(Const inInstanceCaptionContains: String);
    Procedure SetNewInstanceParams(Const inNewInstanceParams: String);
    Procedure SetOrder(Const inOrder: Word);
    Function GetAsJSON: TJSONObject; Override;
  public
    Function DisplayName: String;
    Property AlwaysNewInstance: Boolean Read _alwaysnewinstance Write SetAlwaysNewInstance;
    Property FileMasks: String Read _filemasks Write SetFileMasks;
    Property DelphiVersion: String Read _delphiversion Write SetDelphiVersion;
    Property InstanceCaptionContains: String Read _instancecaptioncontains Write SetInstanceCaptionContains;
    Property NewInstanceParams: String Read _newinstanceparams Write SetNewInstanceParams;
    Property Order: Word Read _order Write SetOrder;
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
    _height: Integer;
    _width: Integer;
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Procedure SetHeight(Const inHeight: Integer);
    Procedure SetWidth(Const inWidth: Integer);
    Function GetAsJSON: TJSONObject; Override;
  public
    Property Height: Integer Read _height Write SetHeight;
    Property Width: Integer Read _width Write SetWidth;
  End;

  TSettings = Class(TAEApplicationSettings)
  strict private
    _enablelogging: Boolean;
    _ruleengine: TRuleEngine;
    _rulelistwidth: Integer;
    _windows: TObjectDictionary<String, TWindowSize>;
    Procedure SetEnableLogging(Const inEnableLogging: Boolean);
    Procedure SetRuleListWidth(Const inRuleListWidth: Integer);
    Procedure SetWindowSize(Const inWindowClass: String; Const inWindowSize: TWindowSize);
    Function GetWindowSize(Const inWindowClass: String): TWindowSize;
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Constructor Create(Const inSettingsFileName: String); Override;
    Destructor Destroy; Override;
    Property EnableLogging: Boolean Read _enablelogging Write SetEnableLogging;
    Property RuleEngine: TRuleEngine Read _ruleengine;
    Property RuleListWidth: Integer Read _rulelistwidth Write SetRuleListWidth;
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
  If Self._delphiversion.IsEmpty Then
    Result := RULE_VERSION_AUTODETECT + sLineBreak
  Else
    Result := Format(RULE_VERSION_EXPLICIT, [Self._delphiversion]) + sLineBreak;

  If Self._alwaysnewinstance Then Result := Result + RULE_INSTANCE_ALWAYSNEW
    Else
  If Not Self._instancecaptioncontains.IsEmpty Then
    Result := Result + Format(RULE_INSTANCE_CAPTIONFILTER, [Self._instancecaptioncontains])
  Else
    Result := Result + RULE_INSTANCE_ANY;
End;

Function TRule.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Self._alwaysnewinstance Then
    Result.AddPair(TXT_ALWAYSNEWINSTANCE, TJSONBool.Create(Self._alwaysnewinstance));

  If Not Self._delphiversion.IsEmpty Then
    Result.AddPair(TXT_DELPHIVERSION, Self._delphiversion);

  If Not Self._filemasks.IsEmpty Then
    Result.AddPair(TXT_FILEMASKS, Self._filemasks);

  If Not Self._instancecaptioncontains.IsEmpty Then
    Result.AddPair(TXT_INSTANCECAPTIONCONTAINS, Self._instancecaptioncontains);

  If Not Self._newinstanceparams.IsEmpty Then
    Result.AddPair(TXT_NEWINSTANCEPARAMS, Self._newinstanceparams);

  If Self._order <> 0 Then
    Result.AddPair(TXT_ORDER, TJSONNumber.Create(Self._order));
End;

Procedure TRule.InternalClear;
Begin
  inherited;

  Self._alwaysnewinstance := False;
  Self._delphiversion := '';
  Self._filemasks := '';
  Self._instancecaptioncontains := '';
  Self._newinstanceparams := '';
  Self._order := 0;
End;

Procedure TRule.SetAlwaysNewInstance(Const inAlwaysNewInstance: Boolean);
Begin
  If _alwaysnewinstance = inAlwaysNewInstance Then
    Exit;

  _alwaysnewinstance := inAlwaysNewInstance;

  Self.SetChanged;
End;

Procedure TRule.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  inJSON.TryGetValue<Boolean>(TXT_ALWAYSNEWINSTANCE, Self._alwaysnewinstance);
  inJSON.TryGetValue<String>(TXT_DELPHIVERSION, Self._delphiversion);
  inJSON.TryGetValue<String>(TXT_FILEMASKS, Self._filemasks);
  inJSON.TryGetValue<String>(TXT_INSTANCECAPTIONCONTAINS, Self._instancecaptioncontains);
  inJSON.TryGetValue<String>(TXT_NEWINSTANCEPARAMS, Self._newinstanceparams);
  inJSON.TryGetValue<Word>(TXT_ORDER, Self._order);
End;

procedure TRule.SetDelphiVersion(const inDelphiVersion: String);
begin

end;

Procedure TRule.SetFileMasks(Const inFileMasks: String);
Begin
  If _filemasks = inFileMasks Then
    Exit;

  _filemasks := inFileMasks;

  Self.SetChanged;
End;

Procedure TRule.SetInstanceCaptionContains(Const inInstanceCaptionContains: String);
Begin
  If _instancecaptioncontains = inInstanceCaptionContains Then
    Exit;

  _instancecaptioncontains := inInstanceCaptionContains;

  Self.SetChanged;
End;

Procedure TRule.SetNewInstanceParams(Const inNewInstanceParams: String);
Begin
  If _newinstanceparams = inNewInstanceParams Then
    Exit;

  _newinstanceparams := inNewInstanceParams;

  Self.SetChanged;
End;

Procedure TRule.SetOrder(Const inOrder: Word);
Begin
  If _order = inOrder Then
    Exit;

  _order := inOrder;

  Self.SetChanged;
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
  _dvers.DDEDiscoveryTimeout := 2;
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
  If inRuleName = inNewName Then
    Exit;

  _rules.Add(inNewName, _rules.ExtractPair(inRuleName).Value);

  Self.SetChanged;
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
  Begin
    _rules.AddOrSetValue(inRuleName, inRule);

    Self.SetChanged;
  End
  Else If _rules.ContainsKey(inRuleName) Then
  Begin
    _rules.Remove(inRuleName);

    Self.SetChanged;
  End;
End;

//
// TWindowSize
//

Function TWindowSize.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Self._height <> 0 Then
    Result.AddPair(TXT_HEIGHT, TJSONNumber.Create(Self._height));

  if Self._width <> 0 Then
    Result.AddPair(TXT_WIDTH, TJSONNumber.Create(Self._width))
End;

Procedure TWindowSize.InternalClear;
Begin
  inherited;

  Self._height := 0;
  Self._width := 0;
End;

Procedure TWindowSize.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  inJSON.TryGetValue<Integer>(TXT_HEIGHT, Self._height);
  inJSON.TryGetValue<Integer>(TXT_WIDTH, Self._width);
End;

Procedure TWindowSize.SetHeight(Const inHeight: Integer);
Begin
  If _height = inHeight Then
    Exit;

  _height := inHeight;

  Self.SetChanged;
End;

Procedure TWindowSize.SetWidth(Const inWidth: Integer);
Begin
  If _width = inWidth Then
    Exit;

  _width := inWidth;

  Self.SetChanged;
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

  If Self._enablelogging Then
    Result.AddPair(TXT_ENABLELOGGING, TJSONBool.Create(Self._enablelogging));
  If Length(_ruleengine.Rules) > 0 Then
    Result.AddPair(TXT_RULES, _ruleengine.AsJSON);

  If Self._rulelistwidth <> 0 Then
    Result.AddPair(TXT_RULELISTWIDTH, TJSONNumber.Create(Self._rulelistwidth));

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
  Self._enablelogging := False;
  Self._rulelistwidth := 0;
  _windows.Clear;
End;

Procedure TSettings.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
Begin
  inherited;

  inJSON.TryGetValue<Boolean>(TXT_ENABLELOGGING, Self._enablelogging);
  If inJSON.GetValue(TXT_RULES) <> nil Then
    _ruleengine.AsJSON := inJSON.GetValue<TJSONObject>(TXT_RULES);
  inJSON.TryGetValue<Integer>(TXT_RULELISTWIDTH, Self._rulelistwidth);

  If inJSON.GetValue(TXT_WINDOWS) <> nil Then
    For jp In inJSON.GetValue<TJSONObject>(TXT_WINDOWS) Do
      _windows.Add(jp.JsonString.Value, TWindowSize.NewFromJSON(jp.JsonValue) As TWindowSize);
End;

Procedure TSettings.SetEnableLogging(Const inEnableLogging: Boolean);
Begin
  If _enablelogging = inEnableLogging Then
    Exit;

  _enablelogging := inEnableLogging;

  Self.SetChanged;
End;

Procedure TSettings.SetRuleListWidth(Const inRuleListWidth: Integer);
Begin
  If _rulelistwidth = inRuleListWidth Then
    Exit;

  _rulelistwidth := inRuleListWidth;

  Self.SetChanged;
End;

Procedure TSettings.SetWindowSize(Const inWindowClass: String; Const inWindowSize: TWindowSize);
Begin
  If Assigned(inWindowSize) Then
  Begin
    _windows.AddOrSetValue(inWindowClass, inWindowSize);

    Self.SetChanged;
  End
  Else If _windows.ContainsKey(inWindowClass) Then
  Begin
    _windows.Remove(inWindowClass);

    Self.SetChanged;
  End;
End;

Initialization
  _settings := nil;

Finalization
  FreeAndNil(_settings);

End.

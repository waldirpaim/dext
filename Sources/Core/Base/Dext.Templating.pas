// ***************************************************************************
//
//           Dext Framework
//
//           Copyright (C) 2025 Cesar Romero & Dext Contributors
//
//           Licensed under the Apache License, Version 2.0 (the "License");
//           you may not use this file except in compliance with the License.
//           You may obtain a copy of the License at
//
//               http://www.apache.org/licenses/LICENSE-2.0
//
//           Unless required by applicable law or agreed to in writing,
//           software distributed under the License is distributed on an
//           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//           either express or implied. See the License for the specific
//           language governing permissions and limitations under the
//           License.
//
// ***************************************************************************
//
//  Author:  Cesar Romero
//  Created: 2026-04-10
//
//  Dext.Templating - Generic Template Engine Contracts & Implementation
//
// ***************************************************************************

unit Dext.Templating;

interface

uses
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  Dext.Collections,
  Dext.Collections.Dict,
  Dext.Text.Escaping;

type
  ITemplateContext = interface
    ['{1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D}']
    procedure SetValue(const AKey: string; const AValue: string);
    function GetValue(const AKey: string): string;
    function TryGetValue(const AKey: string; out AValue: string): Boolean;
    function HasValue(const AKey: string): Boolean;

    procedure SetObject(const AKey: string; AObject: TObject);
    function GetObject(const AKey: string): TObject;

    procedure SetList(const AKey: string; const AItems: TArray<TObject>);
    function GetList(const AKey: string): TArray<TObject>;

    function CreateChildScope: ITemplateContext;
  end;

  ITemplateEngine = interface
    ['{2B3C4D5E-6F7A-8B9C-0D1E-2F3A4B5C6D7E}']
    function Render(const ATemplate: string; const AContext: ITemplateContext): string;
  end;

  ITemplateLoader = interface
    ['{5C6D7E8F-9A0B-1C2D-3E4F-5A6B7C8D9E0F}']
    function Load(const ATemplateName: string): string;
  end;

  ITemplateFilterRegistry = interface
    ['{6D7E8F9A-0B1C-2D3E-4F5A-6B7C8D9E0F1A}']
    procedure RegisterFilter(const AName: string; const AFilter: System.SysUtils.TFunc<string, string>);
    function ApplyFilter(const AName: string; const AValue: string): string;
  end;

  TTemplateContext = class(TInterfacedObject, ITemplateContext)
  private
    FValues: IDictionary<string, string>;
    FObjects: IDictionary<string, TObject>;
    FLists: IDictionary<string, TArray<TObject>>;
    FParent: ITemplateContext;
  public
    constructor Create; overload;
    constructor Create(const AParent: ITemplateContext); overload;
    destructor Destroy; override;

    procedure SetValue(const AKey: string; const AValue: string);
    function GetValue(const AKey: string): string;
    function TryGetValue(const AKey: string; out AValue: string): Boolean;
    function HasValue(const AKey: string): Boolean;

    procedure SetObject(const AKey: string; AObject: TObject);
    function GetObject(const AKey: string): TObject;

    procedure SetList(const AKey: string; const AItems: TArray<TObject>);
    function GetList(const AKey: string): TArray<TObject>;

    function CreateChildScope: ITemplateContext;
  end;

  TDextTemplateEngine = class(TInterfacedObject, ITemplateEngine, ITemplateFilterRegistry)
  private
    FFilters: IDictionary<string, System.SysUtils.TFunc<string, string>>;
    FRttiCtx: TRttiContext;

    function ResolveExpression(const AExpr: string; const AContext: ITemplateContext): string;
    function ResolveObjectProperty(AObj: TObject; const APropPath: string): string;
    function ProcessBlock(const ATemplate: string; const AContext: ITemplateContext;
      var APos: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;

    function Render(const ATemplate: string; const AContext: ITemplateContext): string;

    procedure RegisterFilter(const AName: string; const AFilter: System.SysUtils.TFunc<string, string>);
    function ApplyFilter(const AName: string; const AValue: string): string;
  end;

  TTemplating = record
  public
    class function CreateContext: ITemplateContext; static;
    class function CreateEngine: ITemplateEngine; static;
  end;

implementation

uses
  Dext.Collections.Comparers;

{ TTemplateContext }

constructor TTemplateContext.Create;
begin
  inherited Create;
  FValues := TCollections.CreateDictionaryIgnoreCase<string, string>;
  FObjects := TCollections.CreateDictionaryIgnoreCase<string, TObject>;
  FLists := TCollections.CreateDictionaryIgnoreCase<string, TArray<TObject>>;
end;

constructor TTemplateContext.Create(const AParent: ITemplateContext);
begin
  Create;
  FParent := AParent;
end;

destructor TTemplateContext.Destroy;
begin
  FValues := nil;
  FObjects := nil;
  FLists := nil;
  inherited;
end;

function TTemplateContext.GetValue(const AKey: string): string;
begin
  if not TryGetValue(AKey, Result) then
    Result := '';
end;

function TTemplateContext.HasValue(const AKey: string): Boolean;
var
  Dummy: string;
begin
  Result := TryGetValue(AKey, Dummy);
end;

procedure TTemplateContext.SetValue(const AKey: string; const AValue: string);
begin
  FValues.AddOrSetValue(AKey, AValue);
end;

function TTemplateContext.TryGetValue(const AKey: string; out AValue: string): Boolean;
begin
  Result := FValues.TryGetValue(AKey, AValue);
  if not Result and Assigned(FParent) then
    Result := FParent.TryGetValue(AKey, AValue);
end;

function TTemplateContext.GetObject(const AKey: string): TObject;
begin
  if not FObjects.TryGetValue(AKey, Result) and Assigned(FParent) then
    Result := FParent.GetObject(AKey);
end;

procedure TTemplateContext.SetObject(const AKey: string; AObject: TObject);
begin
  FObjects.AddOrSetValue(AKey, AObject);
end;

function TTemplateContext.GetList(const AKey: string): TArray<TObject>;
begin
  if not FLists.TryGetValue(AKey, Result) and Assigned(FParent) then
    Result := FParent.GetList(AKey);
end;

procedure TTemplateContext.SetList(const AKey: string; const AItems: TArray<TObject>);
begin
  FLists.AddOrSetValue(AKey, AItems);
end;

function TTemplateContext.CreateChildScope: ITemplateContext;
begin
  Result := TTemplateContext.Create(Self);
end;

{ TDextTemplateEngine }

constructor TDextTemplateEngine.Create;
begin
  inherited Create;
  FFilters := TCollections.CreateDictionaryIgnoreCase<string, System.SysUtils.TFunc<string, string>>;
  FRttiCtx := TRttiContext.Create;
end;

destructor TDextTemplateEngine.Destroy;
begin
  FFilters := nil;
  FRttiCtx.Free;
  inherited;
end;

procedure TDextTemplateEngine.RegisterFilter(const AName: string;
  const AFilter: System.SysUtils.TFunc<string, string>);
begin
  FFilters.AddOrSetValue(AName, AFilter);
end;

function TDextTemplateEngine.ApplyFilter(const AName: string;
  const AValue: string): string;
var
  Filter: System.SysUtils.TFunc<string, string>;
begin
  if FFilters.TryGetValue(System.SysUtils.Trim(AName), Filter) and Assigned(Filter) then
    Result := Filter(AValue)
  else
    Result := AValue;
end;

function TDextTemplateEngine.ResolveObjectProperty(AObj: TObject;
  const APropPath: string): string;
var
  LType: TRttiType;
  LProp: TRttiProperty;
  LParts: TArray<string>;
  LCurrent: TObject;
  LVal: TValue;
  I: Integer;
begin
  Result := '';
  if not Assigned(AObj) then
    Exit;

  LParts := System.StrUtils.SplitString(APropPath, '.');
  LCurrent := AObj;

  for I := 0 to High(LParts) do
  begin
    LType := FRttiCtx.GetType(LCurrent.ClassInfo);
    if not Assigned(LType) then
      Exit;

    LProp := LType.GetProperty(System.SysUtils.Trim(LParts[I]));
    if not Assigned(LProp) then
      Exit;

    LVal := LProp.GetValue(LCurrent);

    if I = High(LParts) then
    begin
      if LVal.Kind = tkClass then
        Result := LVal.AsObject.ToString
      else
        Result := LVal.ToString;
      Exit;
    end;

    if LVal.Kind <> tkClass then
      Exit;

    LCurrent := LVal.AsObject;
    if not Assigned(LCurrent) then
      Exit;
  end;
end;

function TDextTemplateEngine.ResolveExpression(const AExpr: string;
  const AContext: ITemplateContext): string;
var
  Expr, FilterName: string;
  PipePos, DotPos: Integer;
  Obj: TObject;
  ObjKey, PropPath: string;
begin
  Expr := System.SysUtils.Trim(AExpr);

  PipePos := System.Pos('|', Expr);
  if PipePos > 0 then
  begin
    FilterName := System.SysUtils.Trim(System.Copy(Expr, PipePos + 1, MaxInt));
    Expr := System.SysUtils.Trim(System.Copy(Expr, 1, PipePos - 1));
    Result := ApplyFilter(FilterName, ResolveExpression(Expr, AContext));
    Exit;
  end;

  DotPos := System.Pos('.', Expr);
  if DotPos > 0 then
  begin
    ObjKey := System.Copy(Expr, 1, DotPos - 1);
    PropPath := System.Copy(Expr, DotPos + 1, MaxInt);
    Obj := AContext.GetObject(ObjKey);
    if Assigned(Obj) then
      Result := ResolveObjectProperty(Obj, PropPath)
    else
      Result := '';
    Exit;
  end;

  Result := AContext.GetValue(Expr);
end;

function TDextTemplateEngine.ProcessBlock(const ATemplate: string;
  const AContext: ITemplateContext; var APos: Integer): string;
var
  SB: TStringBuilder;
  InnerPos, EndPos: Integer;
  TagContent, BlockType, BlockKey, BlockContent, MatchTag: string;
  Items: TArray<TObject>;
  Item: TObject;
  ChildScope: ITemplateContext;
  Condition: Boolean;
  IsRaw: Boolean;
  I: Integer;
begin
  SB := TStringBuilder.Create;
  try
    while APos <= Length(ATemplate) do
    begin
      InnerPos := System.Pos('{{', ATemplate, APos);
      if InnerPos < 1 then
      begin
        SB.Append(System.Copy(ATemplate, APos, MaxInt));
        APos := Length(ATemplate) + 1;
        Break;
      end;

      SB.Append(System.Copy(ATemplate, APos, InnerPos - APos));
      APos := InnerPos + 2;

      IsRaw := False;
      if (APos <= Length(ATemplate)) and (ATemplate[APos] = '{') then
      begin
        IsRaw := True;
        Inc(APos);
      end;

      if IsRaw then MatchTag := '}}}' else MatchTag := '}}';
      EndPos := System.Pos(MatchTag, ATemplate, APos);
      if EndPos < 1 then
      begin
        if IsRaw then SB.Append('{{{') else SB.Append('{{');
        Continue;
      end;

      TagContent := System.SysUtils.Trim(System.Copy(ATemplate, APos, EndPos - APos));
      APos := EndPos + Length(MatchTag);

      if (Length(TagContent) > 0) and (TagContent[1] = '#') then
      begin
        BlockType := System.SysUtils.LowerCase(System.StrUtils.SplitString(System.Copy(TagContent, 2, MaxInt), ' ')[0]);
        BlockKey := System.SysUtils.Trim(System.Copy(TagContent, BlockType.Length + 2, MaxInt));

        InnerPos := APos;
        BlockContent := '';
        I := 1;
        while APos <= Length(ATemplate) do
        begin
          EndPos := System.Pos('{{', ATemplate, APos);
          if EndPos < 1 then Break;

          APos := EndPos + 2;
          if System.StrUtils.StartsText('#' + BlockType, System.Copy(ATemplate, APos, MaxInt)) then
            Inc(I)
          else if System.StrUtils.StartsText('/' + BlockType, System.Copy(ATemplate, APos, MaxInt)) then
          begin
            Dec(I);
            if I = 0 then
            begin
              BlockContent := System.Copy(ATemplate, InnerPos, EndPos - InnerPos);
              EndPos := System.Pos('}}', ATemplate, APos);
              APos := EndPos + 2;
              Break;
            end;
          end;
        end;

        if BlockType = 'if' then
        begin
          Condition := (System.SysUtils.LowerCase(AContext.GetValue(BlockKey)) = 'true') or
                       (AContext.GetObject(BlockKey) <> nil);
          if Condition then
          begin
            I := 1;
            SB.Append(ProcessBlock(BlockContent, AContext, I));
          end;
        end
        else if BlockType = 'unless' then
        begin
          Condition := (System.SysUtils.LowerCase(AContext.GetValue(BlockKey)) = 'true') or
                       (AContext.GetObject(BlockKey) <> nil);
          if not Condition then
          begin
            I := 1;
            SB.Append(ProcessBlock(BlockContent, AContext, I));
          end;
        end
        else if BlockType = 'each' then
        begin
          Items := AContext.GetList(BlockKey);
          if Length(Items) > 0 then
          begin
            for I := 0 to High(Items) do
            begin
              Item := Items[I];
              ChildScope := AContext.CreateChildScope;
              ChildScope.SetObject('this', Item);
              ChildScope.SetValue('@index', System.SysUtils.IntToStr(I));
              ChildScope.SetValue('@first', System.StrUtils.IfThen(I = 0, 'true', 'false'));
              ChildScope.SetValue('@last', System.StrUtils.IfThen(I = High(Items), 'true', 'false'));
              
              InnerPos := 1;
              SB.Append(ProcessBlock(BlockContent, ChildScope, InnerPos));
            end;
          end;
        end;
      end
      else if (Length(TagContent) > 0) and (TagContent[1] = '/') then
      begin
      end
      else
      begin
        if IsRaw then
          SB.Append(ResolveExpression(TagContent, AContext))
        else
          SB.Append(TDextEscaping.Html(ResolveExpression(TagContent, AContext)));
      end;
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TDextTemplateEngine.Render(const ATemplate: string;
  const AContext: ITemplateContext): string;
var
  Pos: Integer;
begin
  Pos := 1;
  Result := ProcessBlock(ATemplate, AContext, Pos);
end;

class function TTemplating.CreateContext: ITemplateContext;
begin
  Result := TTemplateContext.Create;
end;

class function TTemplating.CreateEngine: ITemplateEngine;
begin
  Result := TDextTemplateEngine.Create;
end;

end.

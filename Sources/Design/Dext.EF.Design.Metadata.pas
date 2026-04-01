unit Dext.EF.Design.Metadata;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  SimpleParser.Lexer.Types,
  Dext.Entity.Core;

type
  TEntityMetadataParser = class
  private
    function GetNodeText(Node: TSyntaxNode): string;
    function HasAttribute(Node: TSyntaxNode; const AttrName: string): Boolean;
    function GetAttributeValue(Node: TSyntaxNode; const AttrName: string): string;
    procedure ExtractMembers(AMetadata: TEntityClassMetadata; AClassNode: TSyntaxNode);
  public
    function ParseUnit(const AFileName: string): IList<TEntityClassMetadata>;
  end;

implementation

uses
  System.IOUtils,
  System.Types;

{ TEntityMetadataParser }

function TEntityMetadataParser.GetNodeText(Node: TSyntaxNode): string;
begin
  Result := Node.GetAttribute(anName);
  if Result = '' then Result := Node.GetAttribute(anType);
  if Result = '' then
  begin
    if Node is TValuedSyntaxNode then
      Result := TValuedSyntaxNode(Node).Value;
  end;
  if Result.StartsWith('&') then
    Result := Result.Substring(1);
end;

function TEntityMetadataParser.HasAttribute(Node: TSyntaxNode; const AttrName: string): Boolean;
var
  Child, Attr: TSyntaxNode;
begin
  Result := False;
  for Child in Node.ChildNodes do
  begin
    if Child.Typ = ntAttributes then
    begin
      for Attr in Child.ChildNodes do
      begin
        if SameText(GetNodeText(Attr), AttrName) then
          Exit(True);
      end;
    end;
  end;
end;

function TEntityMetadataParser.GetAttributeValue(Node: TSyntaxNode; const AttrName: string): string;
var
  Child, Attr, Arg: TSyntaxNode;
begin
  Result := '';
  for Child in Node.ChildNodes do
  begin
    if Child.Typ = ntAttributes then
    begin
      for Attr in Child.ChildNodes do
      begin
        if SameText(GetNodeText(Attr), AttrName) then
        begin
          // Try to get first argument value
          for Arg in Attr.ChildNodes do
          begin
            if Arg.Typ = ntPositionalArgument then
              Exit(GetNodeText(Arg).DeQuotedString(''''));
          end;
          Exit('');
        end;
      end;
    end;
  end;
end;

procedure TEntityMetadataParser.ExtractMembers(AMetadata: TEntityClassMetadata; AClassNode: TSyntaxNode);
  procedure Scan(ContextNode: TSyntaxNode);
  var
    CChild, Sub: TSyntaxNode;
    MName, MType: string;
    Member: TEntityMemberMetadata;
  begin
    for CChild in ContextNode.ChildNodes do
    begin
      if CChild.Typ in [ntProperty, ntField] then
      begin
        MName := GetNodeText(CChild);
        if MName = '' then Continue;

        // In Dext, we mostly use properties for entities
        MType := CChild.GetAttribute(anType);
        if MType = '' then
        begin
             for Sub in CChild.ChildNodes do
               if Sub.Typ = ntType then MType := GetNodeText(Sub);
        end;

        Member := TEntityMemberMetadata.Create;
        Member.Name := MName;
        Member.MemberType := MType;
        Member.Visible := True;
        
        // Attributes
        Member.IsPrimaryKey := HasAttribute(CChild, 'PrimaryKey') or HasAttribute(CChild, 'PK');
        Member.IsRequired := HasAttribute(CChild, 'Required');
        Member.IsAutoInc := HasAttribute(CChild, 'AutoInc');
        Member.IsReadOnly := HasAttribute(CChild, 'NotMapped');
        
        Member.DisplayLabel := GetAttributeValue(CChild, 'Caption');
        if Member.DisplayLabel = '' then Member.DisplayLabel := GetAttributeValue(CChild, 'DisplayLabel');
        
        Member.DisplayFormat := GetAttributeValue(CChild, 'DisplayFormat');
        Member.EditMask := GetAttributeValue(CChild, 'EditMask');
        
        var VisAttr := GetAttributeValue(CChild, 'Visible');
        if VisAttr <> '' then
          Member.Visible := SameText(VisAttr, 'True')
        else
          Member.Visible := True;

        var LenAttr := GetAttributeValue(CChild, 'MaxLength');
        if LenAttr <> '' then Member.MaxLength := StrToIntDef(LenAttr, 0);

        var WidthAttr := GetAttributeValue(CChild, 'DisplayWidth');
        if WidthAttr <> '' then Member.DisplayWidth := StrToIntDef(WidthAttr, 0);

        var PrecisionAttr := GetAttributeValue(CChild, 'Precision');
        if PrecisionAttr <> '' then Member.Precision := StrToIntDef(PrecisionAttr, 0);

        var DefAttr := GetAttributeValue(CChild, 'DefaultValue');
        if DefAttr <> '' then Member.DefaultValue := DefAttr;

        // Alignment (Map Enum string to Delphi TAlignment)
        var AlignAttr := GetAttributeValue(CChild, 'Alignment');
        if AlignAttr <> '' then
        begin
          if SameText(AlignAttr, 'taLeftJustify') then Member.Alignment := taLeftJustify
          else if SameText(AlignAttr, 'taRightJustify') then Member.Alignment := taRightJustify
          else if SameText(AlignAttr, 'taCenter') then Member.Alignment := taCenter;
        end;

        AMetadata.Members.Add(Member);
      end
      else if CChild.Typ in [ntPublic, ntPublished, ntProtected] then
        Scan(CChild);
    end;
  end;

begin
  Scan(AClassNode);
end;

function TEntityMetadataParser.ParseUnit(const AFileName: string): IList<TEntityClassMetadata>;
var
  Builder: TPasSyntaxTreeBuilder;
  SyntaxTree, InterfaceNode, TypeSection, TypeNode, ClassNode, Candidate: TSyntaxNode;
  Content: string;
  Stream: TStringStream;
  Metadata: TEntityClassMetadata;
  ClassName, TableName: string;
begin
  Result := TCollections.CreateObjectList<TEntityClassMetadata>(True);
  if not FileExists(AFileName) then Exit;

  Builder := TPasSyntaxTreeBuilder.Create;
  try
    Builder.InitDefinesDefinedByCompiler;
    Builder.AddDefine('MSWINDOWS'); // Crucial for Dext
    Builder.UseDefines := True;

    Content := TFile.ReadAllText(AFileName);
    Stream := TStringStream.Create(Content, TEncoding.UTF8);
    try
      try
        SyntaxTree := Builder.Run(Stream);
        try
          InterfaceNode := SyntaxTree.FindNode(ntInterface);
          if InterfaceNode = nil then Exit;

          for TypeSection in InterfaceNode.ChildNodes do
          begin
            if TypeSection.Typ = ntTypeSection then
            begin
              for TypeNode in TypeSection.ChildNodes do
              begin
                if TypeNode.Typ = ntTypeDecl then
                begin
                  ClassName := GetNodeText(TypeNode);
                  ClassNode := nil;
                  
                  // Find the class/record/interface definition
                  for Candidate in TypeNode.ChildNodes do
                  begin
                    if SameText(Candidate.GetAttribute(anType), 'class') or 
                       SameText(Candidate.GetAttribute(anKind), 'class') then
                    begin
                      ClassNode := Candidate;
                      Break;
                    end;
                  end;

                  if ClassNode <> nil then
                  begin
                    // Check if it has [Table] or [Entity] attribute (Dext uses Table mostly)
                    if HasAttribute(TypeNode, 'Table') or HasAttribute(TypeNode, 'Entity') then
                    begin
                      TableName := GetAttributeValue(TypeNode, 'Table');
                      if TableName = '' then TableName := GetAttributeValue(TypeNode, 'Entity');
                      if TableName = '' then TableName := ClassName;

                      Metadata := TEntityClassMetadata.Create;
                      Metadata.ClassName := ClassName;
                      Metadata.TableName := TableName;
                      Metadata.UnitName := ChangeFileExt(ExtractFileName(AFileName), '');
                      ExtractMembers(Metadata, ClassNode);
                      Result.Add(Metadata);
                    end;
                  end;
                end;
              end;
            end;
          end;
        finally
          SyntaxTree.Free;
        end;
      except
        // Silent fail on parse error during design time to avoid IDE popups
      end;
    finally
      Stream.Free;
    end;
  finally
    Builder.Free;
  end;
end;

end.

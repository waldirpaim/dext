program CheckTypeName;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Rtti, System.TypInfo, Dext.Types.Lazy;

type
  TTest = class
    FCat: Lazy<TObject>;
    property Cat: Lazy<TObject> read FCat;
  end;

var
  Ctx: TRttiContext;
  Typ: TRttiType;
  Prop: TRttiProperty;
begin
  Typ := Ctx.GetType(TTest);
  Prop := Typ.GetProperty('Cat');
  Writeln('Type Name: ', Prop.PropertyType.Name);
  Writeln('TypeKind: ', GetEnumName(TypeInfo(TTypeKind), Ord(Prop.PropertyType.TypeKind)));
end.

unit Dext.EF.Design.Registration;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.EF.Design.Editors,
  Dext.EF.Design.Expert;

procedure Register;

implementation

procedure Register;
begin
  Dext.EF.Design.Editors.RegisterEditors;
  Dext.EF.Design.Expert.RegisterExpert;
end;

end.

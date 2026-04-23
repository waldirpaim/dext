unit Infra.Context;

interface

uses
  Dext.Entity,
  Dext.Entity.Core,
  Domain.Entities;

type
  /// <summary>
  ///   Database Context.
  ///   Registered as Scoped in DI (one per HTTP request).
  /// </summary>
  TAppDbContext = class(TDbContext)
  private
    function GetProducts: IDbSet<TProduct>;
  protected
    procedure OnModelCreating(Builder: TModelBuilder); override;
  public
    property Products: IDbSet<TProduct> read GetProducts;
  end;

implementation

{ TAppDbContext }

function TAppDbContext.GetProducts: IDbSet<TProduct>;
begin
  Result := Entities<TProduct>;
end;

procedure TAppDbContext.OnModelCreating(Builder: TModelBuilder);
begin
  inherited;
  Builder.Entity<TProduct>;
end;

end.

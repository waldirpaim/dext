unit Infra.Services;

interface

uses
  System.SysUtils,
  Dext.Entity,
  Dext.Entity.Core,
  Domain.Entities,
  Domain.Interfaces,
  Infra.Context;

type
  /// <summary>
  ///   Implementation of IProductService.
  ///   Demonstrates constructor injection (DbContext is injected)
  ///   and the use of Smart Properties (Prop<T>) generating the same AST
  ///   that DataApi uses under the hood.
  /// </summary>
  TProductService = class(TInterfacedObject, IProductService)
  private
    FDb: TAppDbContext;
  public
    // Constructor Injection
    constructor Create(const Db: TAppDbContext);
    
    function GetActiveProducts: TArray<TProduct>;
    function GetExpensiveProducts(MinPrice: Currency): TArray<TProduct>;
    function GetProductCount: Integer;
  end;

implementation

{ TProductService }

constructor TProductService.Create(const Db: TAppDbContext);
begin
  inherited Create;
  FDb := Db; // Automatically provided by Dext DI Container
end;

function TProductService.GetActiveProducts: TArray<TProduct>;
begin
  // Example of Smart Properties. 
  // P.IsActive == True generates an IExpression AST.
  Result := FDb.Products
    .Where(
      procedure(P: TProduct)
      begin
        P.IsActive := True;
      end)
    .ToArray;
end;

function TProductService.GetExpensiveProducts(MinPrice: Currency): TArray<TProduct>;
begin
  Result := FDb.Products
    .Where(
      procedure(P: TProduct)
      begin
        P.Price > MinPrice;
      end)
    .ToArray;
end;

function TProductService.GetProductCount: Integer;
begin
  Result := FDb.Products.Count;
end;

end.

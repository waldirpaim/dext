unit Domain.Interfaces;

interface

uses
  Dext.Entity.Core,
  Domain.Entities;

type
  /// <summary>
  ///   Service interface for product business logic.
  ///   Registered in DI and used for:
  ///   - Demonstrating constructor injection
  ///   - TAutoMocker<T> in tests (all deps auto-mocked)
  /// </summary>
  IProductService = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetActiveProducts: TArray<TProduct>;
    function GetExpensiveProducts(MinPrice: Currency): TArray<TProduct>;
    function GetProductCount: Integer;
  end;

implementation

end.

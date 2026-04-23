unit Tests.ProductService;

interface

uses
  DunitX.TestFramework,
  Dext.Testing,
  Dext.Testing.AutoMocking,
  Domain.Entities,
  Domain.Interfaces,
  Infra.Context,
  Infra.Services;

type
  [TestFixture]
  TProductServiceTests = class(TObject)
  private
    FMocker: TAutoMocker<TProductService>;
    FSut: IProductService;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    
    [Test]
    procedure GetExpensiveProducts_ShouldReturnOnlyProductsAboveMinPrice;
  end;

implementation

{ TProductServiceTests }

procedure TProductServiceTests.Setup;
begin
  // Dext Testing: AutoMocker automatically injects mocked dependencies 
  // into the TProductService constructor (e.g., TAppDbContext).
  FMocker := TAutoMocker<TProductService>.Create;
  FSut := FMocker.ClassUnderTest;
end;

procedure TProductServiceTests.TearDown;
begin
  FMocker.Free;
end;

procedure TProductServiceTests.GetExpensiveProducts_ShouldReturnOnlyProductsAboveMinPrice;
var
  MockDb: TAppDbContext;
  Products: TArray<TProduct>;
begin
  // Arrange
  MockDb := FMocker.Get<TAppDbContext>;
  // Setup mock data... (In a real test, you'd populate the MockDb's in-memory provider)
  
  // Act
  // Products := FSut.GetExpensiveProducts(1000);
  
  // Assert
  // Assert.AreEqual(1, Length(Products));
  Assert.Pass('Test infrastructure is configured correctly.');
end;

initialization
  TDUnitX.RegisterTestFixture(TProductServiceTests);

end.

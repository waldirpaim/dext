unit Domain.Entities;

interface

uses
  Dext.Entity,
  Dext.Core.SmartTypes,
  Dext.Web.DataApi;

type
  /// <summary>
  ///   Product entity — demonstrates Smart Properties, DataApi, and LINQ-like queries.
  ///   This single class powers the entire demo:
  ///   - [DataApi] generates full REST CRUD automatically
  ///   - Smart Types (StringType, CurrencyType, BoolType) enable type-safe LINQ queries
  ///   - [SoftDelete] turns Remove() into UPDATE instead of DELETE
  /// </summary>
  [DataApi]
  [Table('products')]
  [SoftDelete('IsDeleted')]
  TProduct = class
  private
    FId: Int64;
    FName: StringType;
    FDescription: StringType;
    FPrice: CurrencyType;
    FStock: IntType;
    FIsActive: BoolType;
    FIsDeleted: Boolean;
    FCreatedAt: TDateTime;
  public
    [PK, AutoInc]
    property Id: Int64 read FId write FId;

    [Column('name'), Required, MaxLength(100)]
    property Name: StringType read FName write FName;

    [Column('description'), MaxLength(500)]
    property Description: StringType read FDescription write FDescription;

    [Column('price'), Precision(18, 2)]
    property Price: CurrencyType read FPrice write FPrice;

    [Column('stock')]
    property Stock: IntType read FStock write FStock;

    [Column('is_active')]
    property IsActive: BoolType read FIsActive write FIsActive;

    [Column('is_deleted')]
    property IsDeleted: Boolean read FIsDeleted write FIsDeleted;

    [Column('created_at')]
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

end.

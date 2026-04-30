unit Generated.SQLServer;

interface

uses
  Dext.Entity,
  Dext.Entity.Mapping,
  Dext.Types.Nullable,
  Dext.Types.Lazy,
  Dext.Entity.TypeSystem,
  Dext.Specifications.Types,
  System.SysUtils,
  System.Classes;

type

  TAttachments = class;
  TAuditLogs = class;
  TCategories = class;
  TCountries = class;
  TCustomers = class;
  TOrderItems = class;
  TOrders = class;
  TProductMetadata = class;
  TProductTags = class;
  TProducts = class;
  TSystemConfig = class;
  TTags = class;

  [Table('dbo.ATTACHMENTS')]
  TAttachments = class
  private
    FId: string;
    FFileName: string;
    FContent: TBytes;
  public
    [PK, Column('ID')]
    property Id: string read FId write FId;
    [MaxLength(255), Column('FILE_NAME')]
    property FileName: string read FFileName write FFileName;
    [Column('CONTENT')]
    property Content: TBytes read FContent write FContent;
  end;

  [Table('dbo.AUDIT_LOGS')]
  TAuditLogs = class
  private
    FId: Nullable<Integer>;
    FLogDate: Nullable<TDateTime>;
    FOperation: string;
    FDetails: string;
    FUserId: Nullable<Integer>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [Column('LOG_DATE')]
    property LogDate: Nullable<TDateTime> read FLogDate write FLogDate;
    [MaxLength(50), Column('OPERATION')]
    property Operation: string read FOperation write FOperation;
    [MaxLength(255), Column('DETAILS')]
    property Details: string read FDetails write FDetails;
    [Column('USER_ID')]
    property UserId: Nullable<Integer> read FUserId write FUserId;
  end;

  [Table('dbo.CATEGORIES')]
  TCategories = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FParentId: Nullable<Integer>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(50), Column('NAME')]
    property Name: string read FName write FName;
    [Column('PARENT_ID')]
    property ParentId: Nullable<Integer> read FParentId write FParentId;
  end;

  [Table('dbo.COUNTRIES')]
  TCountries = class
  private
    FCode: string;
    FName: string;
  public
    [PK, MaxLength(2), Column('CODE')]
    property Code: string read FCode write FCode;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
  end;

  [Table('dbo.CUSTOMERS')]
  TCustomers = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FCountryCode: string;
    FExternalId: string;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
    [MaxLength(2), Column('COUNTRY_CODE')]
    property CountryCode: string read FCountryCode write FCountryCode;
    [Column('EXTERNAL_ID')]
    property ExternalId: string read FExternalId write FExternalId;
  end;

  [Table('dbo.ORDER_ITEMS')]
  TOrderItems = class
  private
    FOrderId: Nullable<Int64>;
    FSequence: Nullable<Integer>;
    FProductId: Nullable<Integer>;
    FQuantity: Nullable<Integer>;
    FDiscount: Nullable<Double>;
  public
    [PK, Column('ORDER_ID')]
    property OrderId: Nullable<Int64> read FOrderId write FOrderId;
    [PK, Column('SEQUENCE')]
    property Sequence: Nullable<Integer> read FSequence write FSequence;
    [Column('PRODUCT_ID')]
    property ProductId: Nullable<Integer> read FProductId write FProductId;
    [Column('QUANTITY')]
    property Quantity: Nullable<Integer> read FQuantity write FQuantity;
    [Column('DISCOUNT')]
    property Discount: Nullable<Double> read FDiscount write FDiscount;
  end;

  [Table('dbo.ORDERS')]
  TOrders = class
  private
    FId: Nullable<Int64>;
    FOrderDate: Nullable<TDateTime>;
    FCustomerId: Nullable<Integer>;
    FStatus: string;
  public
    [PK, Column('ID')]
    property Id: Nullable<Int64> read FId write FId;
    [Column('ORDER_DATE')]
    property OrderDate: Nullable<TDateTime> read FOrderDate write FOrderDate;
    [Column('CUSTOMER_ID')]
    property CustomerId: Nullable<Integer> read FCustomerId write FCustomerId;
    [MaxLength(20), Column('STATUS')]
    property Status: string read FStatus write FStatus;
  end;

  [Table('dbo.PRODUCT_METADATA')]
  TProductMetadata = class
  private
    FProductId: Nullable<Integer>;
    FDescription: string;
    FJsonSpecs: string;
  public
    [PK, Column('PRODUCT_ID')]
    property ProductId: Nullable<Integer> read FProductId write FProductId;
    [MaxLength(255), Column('DESCRIPTION')]
    property Description: string read FDescription write FDescription;
    [MaxLength(255), Column('JSON_SPECS')]
    property JsonSpecs: string read FJsonSpecs write FJsonSpecs;
  end;

  [Table('dbo.PRODUCT_TAGS')]
  TProductTags = class
  private
    FProductId: Nullable<Integer>;
    FTagId: Nullable<Integer>;
  public
    [PK, Column('PRODUCT_ID')]
    property ProductId: Nullable<Integer> read FProductId write FProductId;
    [PK, Column('TAG_ID')]
    property TagId: Nullable<Integer> read FTagId write FTagId;
  end;

  [Table('dbo.PRODUCTS')]
  TProducts = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FPrice: Nullable<Double>;
    FWeight: Nullable<Double>;
    FIsActive: Nullable<Boolean>;
    FReleaseDate: Nullable<TDateTime>;
    FCategoryId: Nullable<Integer>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
    [Column('PRICE')]
    property Price: Nullable<Double> read FPrice write FPrice;
    [Column('WEIGHT')]
    property Weight: Nullable<Double> read FWeight write FWeight;
    [Column('IS_ACTIVE')]
    property IsActive: Nullable<Boolean> read FIsActive write FIsActive;
    [Column('RELEASE_DATE')]
    property ReleaseDate: Nullable<TDateTime> read FReleaseDate write FReleaseDate;
    [Column('CATEGORY_ID')]
    property CategoryId: Nullable<Integer> read FCategoryId write FCategoryId;
  end;

  [Table('dbo.SYSTEM_CONFIG')]
  TSystemConfig = class
  private
    FConfigKey: string;
    FConfigValue: string;
    FLastModified: Nullable<TDateTime>;
    FIsInternal: Nullable<Boolean>;
    FConfigType: Nullable<Integer>;
  public
    [PK, MaxLength(50), Column('CONFIG_KEY')]
    property ConfigKey: string read FConfigKey write FConfigKey;
    [MaxLength(255), Column('CONFIG_VALUE')]
    property ConfigValue: string read FConfigValue write FConfigValue;
    [Column('LAST_MODIFIED')]
    property LastModified: Nullable<TDateTime> read FLastModified write FLastModified;
    [Column('IS_INTERNAL')]
    property IsInternal: Nullable<Boolean> read FIsInternal write FIsInternal;
    [Column('CONFIG_TYPE')]
    property ConfigType: Nullable<Integer> read FConfigType write FConfigType;
  end;

  [Table('dbo.TAGS')]
  TTags = class
  private
    FId: Nullable<Integer>;
    FName: string;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(30), Column('NAME')]
    property Name: string read FName write FName;
  end;

  AttachmentsEntity = class(TEntityType<TAttachments>)
  public
    class var Id: TPropExpression;
    class var FileName: TPropExpression;
    class var Content: TPropExpression;

    class constructor Create;
  end;

  AuditLogsEntity = class(TEntityType<TAuditLogs>)
  public
    class var Id: TPropExpression;
    class var LogDate: TPropExpression;
    class var Operation: TPropExpression;
    class var Details: TPropExpression;
    class var UserId: TPropExpression;

    class constructor Create;
  end;

  CategoriesEntity = class(TEntityType<TCategories>)
  public
    class var Id: TPropExpression;
    class var Name: TPropExpression;
    class var ParentId: TPropExpression;

    class constructor Create;
  end;

  CountriesEntity = class(TEntityType<TCountries>)
  public
    class var Code: TPropExpression;
    class var Name: TPropExpression;

    class constructor Create;
  end;

  CustomersEntity = class(TEntityType<TCustomers>)
  public
    class var Id: TPropExpression;
    class var Name: TPropExpression;
    class var CountryCode: TPropExpression;
    class var ExternalId: TPropExpression;

    class constructor Create;
  end;

  OrderItemsEntity = class(TEntityType<TOrderItems>)
  public
    class var OrderId: TPropExpression;
    class var Sequence: TPropExpression;
    class var ProductId: TPropExpression;
    class var Quantity: TPropExpression;
    class var Discount: TPropExpression;

    class constructor Create;
  end;

  OrdersEntity = class(TEntityType<TOrders>)
  public
    class var Id: TPropExpression;
    class var OrderDate: TPropExpression;
    class var CustomerId: TPropExpression;
    class var Status: TPropExpression;

    class constructor Create;
  end;

  ProductMetadataEntity = class(TEntityType<TProductMetadata>)
  public
    class var ProductId: TPropExpression;
    class var Description: TPropExpression;
    class var JsonSpecs: TPropExpression;

    class constructor Create;
  end;

  ProductTagsEntity = class(TEntityType<TProductTags>)
  public
    class var ProductId: TPropExpression;
    class var TagId: TPropExpression;

    class constructor Create;
  end;

  ProductsEntity = class(TEntityType<TProducts>)
  public
    class var Id: TPropExpression;
    class var Name: TPropExpression;
    class var Price: TPropExpression;
    class var Weight: TPropExpression;
    class var IsActive: TPropExpression;
    class var ReleaseDate: TPropExpression;
    class var CategoryId: TPropExpression;

    class constructor Create;
  end;

  SystemConfigEntity = class(TEntityType<TSystemConfig>)
  public
    class var ConfigKey: TPropExpression;
    class var ConfigValue: TPropExpression;
    class var LastModified: TPropExpression;
    class var IsInternal: TPropExpression;
    class var ConfigType: TPropExpression;

    class constructor Create;
  end;

  TagsEntity = class(TEntityType<TTags>)
  public
    class var Id: TPropExpression;
    class var Name: TPropExpression;

    class constructor Create;
  end;

implementation

class constructor AttachmentsEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  FileName := TPropExpression.Create('FileName');
  Content := TPropExpression.Create('Content');
end;

class constructor AuditLogsEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  LogDate := TPropExpression.Create('LogDate');
  Operation := TPropExpression.Create('Operation');
  Details := TPropExpression.Create('Details');
  UserId := TPropExpression.Create('UserId');
end;

class constructor CategoriesEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  Name := TPropExpression.Create('Name');
  ParentId := TPropExpression.Create('ParentId');
end;

class constructor CountriesEntity.Create;
begin
  Code := TPropExpression.Create('Code');
  Name := TPropExpression.Create('Name');
end;

class constructor CustomersEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  Name := TPropExpression.Create('Name');
  CountryCode := TPropExpression.Create('CountryCode');
  ExternalId := TPropExpression.Create('ExternalId');
end;

class constructor OrderItemsEntity.Create;
begin
  OrderId := TPropExpression.Create('OrderId');
  Sequence := TPropExpression.Create('Sequence');
  ProductId := TPropExpression.Create('ProductId');
  Quantity := TPropExpression.Create('Quantity');
  Discount := TPropExpression.Create('Discount');
end;

class constructor OrdersEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  OrderDate := TPropExpression.Create('OrderDate');
  CustomerId := TPropExpression.Create('CustomerId');
  Status := TPropExpression.Create('Status');
end;

class constructor ProductMetadataEntity.Create;
begin
  ProductId := TPropExpression.Create('ProductId');
  Description := TPropExpression.Create('Description');
  JsonSpecs := TPropExpression.Create('JsonSpecs');
end;

class constructor ProductTagsEntity.Create;
begin
  ProductId := TPropExpression.Create('ProductId');
  TagId := TPropExpression.Create('TagId');
end;

class constructor ProductsEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  Name := TPropExpression.Create('Name');
  Price := TPropExpression.Create('Price');
  Weight := TPropExpression.Create('Weight');
  IsActive := TPropExpression.Create('IsActive');
  ReleaseDate := TPropExpression.Create('ReleaseDate');
  CategoryId := TPropExpression.Create('CategoryId');
end;

class constructor SystemConfigEntity.Create;
begin
  ConfigKey := TPropExpression.Create('ConfigKey');
  ConfigValue := TPropExpression.Create('ConfigValue');
  LastModified := TPropExpression.Create('LastModified');
  IsInternal := TPropExpression.Create('IsInternal');
  ConfigType := TPropExpression.Create('ConfigType');
end;

class constructor TagsEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  Name := TPropExpression.Create('Name');
end;

end.

unit Generated.Firebird;

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
  TOrders = class;
  TProducts = class;
  TProductMetadata = class;
  TProductTags = class;
  TSystemConfig = class;
  TTags = class;

  [Table('ATTACHMENTS')]
  TAttachments = class
  private
    FId: string;
    FFileName: string;
    FContent: TBytes;
  public
    [PK, MaxLength(36), Column('ID')]
    property Id: string read FId write FId;
    [MaxLength(255), Column('FILE_NAME')]
    property FileName: string read FFileName write FFileName;
    [Column('CONTENT')]
    property Content: TBytes read FContent write FContent;
  end;

  [Table('AUDIT_LOGS')]
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

  [Table('CATEGORIES')]
  TCategories = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FParentId: Nullable<Integer>;
    FNavParent: Lazy<TCategories>;
    FNavParent2: Lazy<TCategories>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(50), Column('NAME')]
    property Name: string read FName write FName;
    [Column('PARENT_ID')]
    property ParentId: Nullable<Integer> read FParentId write FParentId;
    [ForeignKey('PARENT_ID')]
    property Parent: Lazy<TCategories> read FNavParent write FNavParent;
    [ForeignKey('PARENT_ID')]
    property Parent2: Lazy<TCategories> read FNavParent2 write FNavParent2;
  end;

  [Table('COUNTRIES')]
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

  [Table('CUSTOMERS')]
  TCustomers = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FCountryCode: string;
    FExternalId: string;
    FNavCountryCode2: Lazy<TCountries>;
    FNavCountryCode3: Lazy<TCountries>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
    [MaxLength(2), Column('COUNTRY_CODE')]
    property CountryCode: string read FCountryCode write FCountryCode;
    [MaxLength(36), Column('EXTERNAL_ID')]
    property ExternalId: string read FExternalId write FExternalId;
    [ForeignKey('COUNTRY_CODE')]
    property CountryCode2: Lazy<TCountries> read FNavCountryCode2 write FNavCountryCode2;
    [ForeignKey('COUNTRY_CODE')]
    property CountryCode3: Lazy<TCountries> read FNavCountryCode3 write FNavCountryCode3;
  end;

  [Table('ORDERS')]
  TOrders = class
  private
    FId: Nullable<Integer>;
    FOrderDate: Nullable<TDateTime>;
    FCustomerId: Nullable<Integer>;
    FStatus: string;
    FNavCustomer: Lazy<TCustomers>;
    FNavCustomer2: Lazy<TCustomers>;
  public
    [PK, Column('ID')]
    property Id: Nullable<Integer> read FId write FId;
    [Column('ORDER_DATE')]
    property OrderDate: Nullable<TDateTime> read FOrderDate write FOrderDate;
    [Column('CUSTOMER_ID')]
    property CustomerId: Nullable<Integer> read FCustomerId write FCustomerId;
    [MaxLength(20), Column('STATUS')]
    property Status: string read FStatus write FStatus;
    [ForeignKey('CUSTOMER_ID')]
    property Customer: Lazy<TCustomers> read FNavCustomer write FNavCustomer;
    [ForeignKey('CUSTOMER_ID')]
    property Customer2: Lazy<TCustomers> read FNavCustomer2 write FNavCustomer2;
  end;

  [Table('PRODUCTS')]
  TProducts = class
  private
    FId: Nullable<Integer>;
    FName: string;
    FPrice: Nullable<Double>;
    FWeight: Nullable<Double>;
    FIsActive: Nullable<Boolean>;
    FReleaseDate: Nullable<TDateTime>;
    FCategoryId: Nullable<Integer>;
    FNavCategory: Lazy<TCategories>;
    FNavCategory2: Lazy<TCategories>;
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
    [ForeignKey('CATEGORY_ID')]
    property Category: Lazy<TCategories> read FNavCategory write FNavCategory;
    [ForeignKey('CATEGORY_ID')]
    property Category2: Lazy<TCategories> read FNavCategory2 write FNavCategory2;
  end;

  [Table('PRODUCT_METADATA')]
  TProductMetadata = class
  private
    FProductId: Nullable<Integer>;
    FDescription: string;
    FJsonSpecs: string;
    FNavProduct: Lazy<TProducts>;
    FNavProduct2: Lazy<TProducts>;
  public
    [PK, Column('PRODUCT_ID')]
    property ProductId: Nullable<Integer> read FProductId write FProductId;
    [MaxLength(255), Column('DESCRIPTION')]
    property Description: string read FDescription write FDescription;
    [MaxLength(255), Column('JSON_SPECS')]
    property JsonSpecs: string read FJsonSpecs write FJsonSpecs;
    [ForeignKey('PRODUCT_ID')]
    property Product: Lazy<TProducts> read FNavProduct write FNavProduct;
    [ForeignKey('PRODUCT_ID')]
    property Product2: Lazy<TProducts> read FNavProduct2 write FNavProduct2;
  end;

  [Table('PRODUCT_TAGS')]
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

  [Table('SYSTEM_CONFIG')]
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

  [Table('TAGS')]
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
    class var Parent: TPropExpression;
    class var Parent2: TPropExpression;

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
    class var CountryCode2: TPropExpression;
    class var CountryCode3: TPropExpression;

    class constructor Create;
  end;

  OrdersEntity = class(TEntityType<TOrders>)
  public
    class var Id: TPropExpression;
    class var OrderDate: TPropExpression;
    class var CustomerId: TPropExpression;
    class var Status: TPropExpression;
    class var Customer: TPropExpression;
    class var Customer2: TPropExpression;

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
    class var Category: TPropExpression;
    class var Category2: TPropExpression;

    class constructor Create;
  end;

  ProductMetadataEntity = class(TEntityType<TProductMetadata>)
  public
    class var ProductId: TPropExpression;
    class var Description: TPropExpression;
    class var JsonSpecs: TPropExpression;
    class var Product: TPropExpression;
    class var Product2: TPropExpression;

    class constructor Create;
  end;

  ProductTagsEntity = class(TEntityType<TProductTags>)
  public
    class var ProductId: TPropExpression;
    class var TagId: TPropExpression;

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
  Parent := TPropExpression.Create('Parent');
  Parent2 := TPropExpression.Create('Parent2');
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
  CountryCode2 := TPropExpression.Create('CountryCode2');
  CountryCode3 := TPropExpression.Create('CountryCode3');
end;

class constructor OrdersEntity.Create;
begin
  Id := TPropExpression.Create('Id');
  OrderDate := TPropExpression.Create('OrderDate');
  CustomerId := TPropExpression.Create('CustomerId');
  Status := TPropExpression.Create('Status');
  Customer := TPropExpression.Create('Customer');
  Customer2 := TPropExpression.Create('Customer2');
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
  Category := TPropExpression.Create('Category');
  Category2 := TPropExpression.Create('Category2');
end;

class constructor ProductMetadataEntity.Create;
begin
  ProductId := TPropExpression.Create('ProductId');
  Description := TPropExpression.Create('Description');
  JsonSpecs := TPropExpression.Create('JsonSpecs');
  Product := TPropExpression.Create('Product');
  Product2 := TPropExpression.Create('Product2');
end;

class constructor ProductTagsEntity.Create;
begin
  ProductId := TPropExpression.Create('ProductId');
  TagId := TPropExpression.Create('TagId');
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

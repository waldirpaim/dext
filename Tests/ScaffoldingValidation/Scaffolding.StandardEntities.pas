unit Scaffolding.StandardEntities;

interface

uses
  Dext.Entity,
  Dext.Entity.Mapping,
  Dext.Types.Nullable,
  Dext.Types.Lazy,
  Dext.Types.UUID,
  System.SysUtils;

type
  [Table('COUNTRIES')]
  TCountry = class
  private
    FCode: string;
    FName: string;
  public
    [PK, MaxLength(2), Column('CODE')]
    property Code: string read FCode write FCode;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
  end;

  [Table('CATEGORIES')]
  TCategory = class
  private
    FId: Integer;
    FName: string;
    FParentId: Nullable<Integer>;
    FParent: Lazy<TCategory>;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Integer read FId write FId;
    [MaxLength(50), Column('NAME')]
    property Name: string read FName write FName;
    [Column('PARENT_ID')]
    property ParentId: Nullable<Integer> read FParentId write FParentId;
    
    [ForeignKey('PARENT_ID')]
    property Parent: Lazy<TCategory> read FParent write FParent;
  end;

  [Table('PRODUCTS')]
  TProduct = class
  private
    FId: Integer;
    FName: string;
    FPrice: Currency;
    FWeight: Double;
    FCategoryId: Integer;
    FCategory: Lazy<TCategory>;
    FIsActive: Boolean;
    FReleaseDate: Nullable<TDateTime>;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Integer read FId write FId;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
    [Column('PRICE')]
    property Price: Currency read FPrice write FPrice;
    [Column('WEIGHT')]
    property Weight: Double read FWeight write FWeight;
    [Column('IS_ACTIVE')]
    property IsActive: Boolean read FIsActive write FIsActive;
    [Column('RELEASE_DATE')]
    property ReleaseDate: Nullable<TDateTime> read FReleaseDate write FReleaseDate;
    [Column('CATEGORY_ID')]
    property CategoryId: Integer read FCategoryId write FCategoryId;
    
    [ForeignKey('CATEGORY_ID')]
    property Category: Lazy<TCategory> read FCategory write FCategory;
  end;

  [Table('PRODUCT_METADATA')]
  TProductMetadata = class
  private
    FProductId: Integer;
    FDescription: string;
    FProduct: Lazy<TProduct>;
    FJsonSpecs: string;
  public
    [PK, Column('PRODUCT_ID')]
    property ProductId: Integer read FProductId write FProductId;
    [Column('DESCRIPTION')]
    property Description: string read FDescription write FDescription;
    [Column('JSON_SPECS'), JsonColumn]
    property JsonSpecs: string read FJsonSpecs write FJsonSpecs;
    
    [ForeignKey('PRODUCT_ID')]
    property Product: Lazy<TProduct> read FProduct write FProduct;
  end;

  [Table('CUSTOMERS')]
  TCustomer = class
  private
    FId: Integer;
    FName: string;
    FCountryCode: string;
    FCountry: Lazy<TCountry>;
    FExternalId: TUUID;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Integer read FId write FId;
    [MaxLength(100), Column('NAME')]
    property Name: string read FName write FName;
    [MaxLength(2), Column('COUNTRY_CODE')]
    property CountryCode: string read FCountryCode write FCountryCode;
    [Column('EXTERNAL_ID')]
    property ExternalId: TUUID read FExternalId write FExternalId;
    
    [ForeignKey('COUNTRY_CODE')]
    property Country: Lazy<TCountry> read FCountry write FCountry;
  end;

  [Table('ORDERS')]
  TOrder = class
  private
    FId: Int64;
    FOrderDate: TDateTime;
    FCustomerId: Integer;
    FCustomer: Lazy<TCustomer>;
    FStatus: string;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Int64 read FId write FId;
    [Column('ORDER_DATE')]
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    [Column('CUSTOMER_ID')]
    property CustomerId: Integer read FCustomerId write FCustomerId;
    [MaxLength(20), Column('STATUS')]
    property Status: string read FStatus write FStatus;
    
    [ForeignKey('CUSTOMER_ID')]
    property Customer: Lazy<TCustomer> read FCustomer write FCustomer;
  end;

  [Table('ORDER_ITEMS')]
  TOrderItem = class
  private
    FOrderId: Int64;
    FSequence: Integer;
    FProductId: Integer;
    FQuantity: Integer;
    FOrder: Lazy<TOrder>;
    FProduct: Lazy<TProduct>;
    FDiscount: Nullable<Double>;
  public
    [PK, Column('ORDER_ID')]
    property OrderId: Int64 read FOrderId write FOrderId;
    [PK, Column('SEQUENCE')]
    property Sequence: Integer read FSequence write FSequence;
    [Column('PRODUCT_ID')]
    property ProductId: Integer read FProductId write FProductId;
    [Column('QUANTITY')]
    property Quantity: Integer read FQuantity write FQuantity;
    [Column('DISCOUNT')]
    property Discount: Nullable<Double> read FDiscount write FDiscount;
    
    [ForeignKey('ORDER_ID')]
    property Order: Lazy<TOrder> read FOrder write FOrder;
    [ForeignKey('PRODUCT_ID')]
    property Product: Lazy<TProduct> read FProduct write FProduct;
  end;

  [Table('TAGS')]
  TTag = class
  private
    FId: Integer;
    FName: string;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Integer read FId write FId;
    [MaxLength(30), Column('NAME')]
    property Name: string read FName write FName;
  end;

  [Table('PRODUCT_TAGS')]
  TProductTag = class
  private
    FProductId: Integer;
    FTagId: Integer;
  public
    [PK, Column('PRODUCT_ID')]
    property ProductId: Integer read FProductId write FProductId;
    [PK, Column('TAG_ID')]
    property TagId: Integer read FTagId write FTagId;
  end;

  [Table('AUDIT_LOGS')]
  TAuditLog = class
  private
    FId: Int64;
    FLogDate: TDateTime;
    FOperation: string;
    FDetails: string;
    FUserId: Nullable<Integer>;
  public
    [PK, AutoInc, Column('ID')]
    property Id: Int64 read FId write FId;
    [Column('LOG_DATE')]
    property LogDate: TDateTime read FLogDate write FLogDate;
    [MaxLength(50), Column('OPERATION')]
    property Operation: string read FOperation write FOperation;
    [Column('DETAILS')] // Large text
    property Details: string read FDetails write FDetails;
    [Column('USER_ID')]
    property UserId: Nullable<Integer> read FUserId write FUserId;
  end;

  [Table('ATTACHMENTS')]
  TAttachment = class
  private
    FId: TGuid;
    FFileName: string;
    FContent: TBytes;
  public
    [PK, Column('ID')]
    property Id: TGuid read FId write FId;
    [MaxLength(255), Column('FILE_NAME')]
    property FileName: string read FFileName write FFileName;
    [Column('CONTENT')]
    property Content: TBytes read FContent write FContent;
  end;

  [Table('SYSTEM_CONFIG')]
  TSystemConfig = class
  private
    FKey: string;
    FValue: string;
    FLastModified: TDateTime;
    FIsInternal: Boolean;
    FConfigType: Integer;
  public
    [PK, MaxLength(50), Column('CONFIG_KEY')]
    property &Key: string read FKey write FKey;
    [Column('CONFIG_VALUE')]
    property &Value: string read FValue write FValue;
    [Column('LAST_MODIFIED')]
    property LastModified: TDateTime read FLastModified write FLastModified;
    [Column('IS_INTERNAL')]
    property IsInternal: Boolean read FIsInternal write FIsInternal;
    [Column('CONFIG_TYPE')]
    property ConfigType: Integer read FConfigType write FConfigType;
  end;

implementation

end.

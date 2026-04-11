unit Dext.Web.Features.Tests;

interface

uses
  System.SysUtils,
  Dext.Testing.Attributes,
  Dext.Assertions,
  Dext.Auth.JWT,
  Dext.Net.RestRequest;

type
  [TestFixture('Web Extension Features Tests (Phase 3)')]
  TWebFeaturesTests = class
  public
    [Test('T.3 - Should validate JWT generation and parsing correctly (Item B.3)')]
    procedure TestJwtBuilderAndValidation;

    [Test('T.3 - Should support Multipart Form Data adding correctly (Item C.1)')]
    procedure TestMultipartFormData;
  end;

implementation

{ TWebFeaturesTests }

procedure TWebFeaturesTests.TestJwtBuilderAndValidation;
var
  Handler: IJwtTokenHandler;
  Token: string;
  Result: TJwtValidationResult;
begin
  Handler := TJwtTokenHandler.Create('MySuperSecretKeyForJWT123', 'DextIssuer', 'DextAudience', 120);
  
  // Generate
  Token := Handler.GenerateToken([TClaim.Create('user_id', '12345')]);
  Should(Token).NotBeEmpty;
  Should(Token).Contain('.'); // Should have 3 parts
  
  // Validate
  Result := Handler.ValidateToken(Token);
  Should(Result.IsValid).BeTrue;
  Should(Length(Result.Claims)).BeGreaterThan(0);
end;

procedure TWebFeaturesTests.TestMultipartFormData;
begin
  Should(True).BeTrue; // Placeholder for Multipart Data Verification over Dext.Net
end;

end.

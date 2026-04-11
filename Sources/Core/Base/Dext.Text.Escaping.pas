// ***************************************************************************
//
//           Dext Framework
//
//           Copyright (C) 2025 Cesar Romero & Dext Contributors
//
//           Licensed under the Apache License, Version 2.0 (the "License");
//           you may not use this file except in compliance with the License.
//           You may obtain a copy of the License at
//
//               http://www.apache.org/licenses/LICENSE-2.0
//
//           Unless required by applicable law or agreed to in writing,
//           software distributed under the License is distributed on an
//           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//           either express or implied. See the License for the specific
//           language governing permissions and limitations under the
//           License.
//
// ***************************************************************************
//
//  Author:  Cesar Romero
//  Created: 2026-04-10
//
//  Dext.Text.Escaping - Unified Text Escaping Utilities
//
//  Centralizes common escaping logic for XML, JSON, HTML, and URL used
//  across the framework (Reporters, Serializers, RestClient, etc.).
//
// ***************************************************************************

unit Dext.Text.Escaping;

interface

uses
  System.SysUtils,
  System.NetEncoding;

type
  /// <summary>
  ///   Unified utilities for text escaping and encoding.
  /// </summary>
  TDextEscaping = class
  public
    /// <summary>Encodes a string for safe HTML display.</summary>
    class function Html(const S: string): string; static; inline;
    /// <summary>Encodes a string for safe XML inclusion.</summary>
    class function Xml(const S: string): string; static; inline;
    /// <summary>Encodes a string for safe JSON inclusion.</summary>
    class function Json(const S: string): string; static; inline;
    /// <summary>Encodes a string for URL query parameters.</summary>
    class function Url(const S: string): string; static; inline;
  end;

implementation

{ TDextEscaping }

class function TDextEscaping.Html(const S: string): string;
begin
  Result := TNetEncoding.HTML.Encode(S);
end;

class function TDextEscaping.Json(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  if S = '' then
  begin
    Result := '';
    Exit;
  end;

  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    case C of
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
      '/': Result := Result + '\/';
      #8:  Result := Result + '\b';
      #9:  Result := Result + '\t';
      #10: Result := Result + '\n';
      #12: Result := Result + '\f';
      #13: Result := Result + '\r';
    else
      if (C < #32) or (C > #126) then
        Result := Result + '\u' + IntToHex(Ord(C), 4)
      else
        Result := Result + C;
    end;
  end;
end;

class function TDextEscaping.Url(const S: string): string;
begin
  Result := TNetEncoding.URL.Encode(S);
end;

class function TDextEscaping.Xml(const S: string): string;
begin
  Result := TNetEncoding.HTML.Encode(S); // XML uses similar escapes for basics
  // Custom XML specific escapes could be added here if needed
end;

end.

{******************************************************************************}
{                                                                              }
{ JmTypes.pas for Jedi Math Alpha 1.03a                                         }
{ Project JEDI Math  http://sourceforge.net/projects/jedimath/                 }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.1 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{ or see the file MPL-1.1.txt included in this package.                        }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  The Original Code is JmTypes.pas.                                           }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ This unit contains various type declarations for the most common types used  }
{ in the JEDI Math project. The types include:                                 }
{ Number types such as TJmFloat and TJmInteger,                                }
{ an exception class EJmMathError,                                             }
{ array and function types.                                                    }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ Unit owner:    Chris Eyre                                                    }
{ Last modified:                                                               }
{      20.02.2005 by Ralph K. Muench (ralphkmuench@users.sourceforge.net)      }
{      for the Jedi Math Alpha 1.03a release                                   }
{                                                                              }
{******************************************************************************}

unit JmTypes;
interface
{$I JediMath.inc}

uses
{$IFDEF WIN32}
  Windows,
{$ENDIF}
{$IFDEF DELPHI6_UP}
  Types,
{$ENDIF}
  Classes,
  SysUtils;


type
{$ifdef jmDoublePrecision}
  TJmFloat = double;
{$endif jmDoublePrecision}
{$ifdef jmSinglePrecision}
  TJmFloat = single;
{$endif jmSinglePrecision}
{$ifdef jmExtendedPrecision}
  TJmFloat = extended;
{$endif jmExtendedPrecision}

  TJmInteger = longint;

  PLargeInteger = ^TLargeInteger;
  TLargeInteger = record
    case Integer of
    0: (
      LowPart: LongWord;
      HighPart: Longint);
    1: (
      QuadPart: Int64);
  end;
      {
// The following declaration is identical to
// the above and will be romeved.
  PULargeInteger = ^TULargeInteger;
  TULargeInteger = record
    case Integer of
    0: (
      LowPart: LongWord;
      HighPart: LongWord);
    1: (
      QuadPart: Int64);
  end;
       }
type
  TDynByteArray     = array of Byte;
  TDynShortintArray = array of Shortint;
  TDynSmallintArray = array of Smallint;
  TDynWordArray     = array of Word;
  TDynIntegerArray  = array of Integer;
  TDynLongintArray  = array of Longint;
  TDynCardinalArray = array of Cardinal;
  TDynInt64Array    = array of Int64;
  TDynExtendedArray = array of Extended;
  TDynDoubleArray   = array of Double;
  TDynSingleArray   = array of Single;
  TDynFloatArray    = array of TJmFloat;
  TDynPointerArray  = array of Pointer;
  TDynStringArray   = array of string;

// TPrimalityTestMethod is no longer in use:
// Will not be available in future versisions if
// there is no demand for this type.
{
type
  TPrimalityTestMethod = (ptTrialDivision, ptRabinMiller);
}

type
  EJmMathError = class (Exception)
  public
    constructor CreateResRec(ResStringRec: PResStringRec);
    constructor CreateResRecFmt(ResStringRec: PResStringRec; const Args: array of const);
  end;

implementation

{ EJmMathError }

constructor EJmMathError.CreateResRec(ResStringRec: PResStringRec);
begin
  {$IFDEF FPC}
  inherited Create(ResStringRec^);
  {$ELSE FPC}
  inherited Create(LoadResString(ResStringRec));
  {$ENDIF FPC}
end;

constructor EJmMathError.CreateResRecFmt(ResStringRec: PResStringRec;
  const Args: array of const);
begin
  {$IFDEF FPC}
  inherited CreateFmt(ResStringRec^, Args);
  {$ELSE FPC}
  inherited CreateFmt(LoadResString(ResStringRec), Args);
  {$ENDIF FPC}
end;

end.









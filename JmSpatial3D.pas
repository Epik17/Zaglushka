{******************************************************************************}
{                                                                              }
{ JmSpatial3D.pas for Jedi Math Alpha 1.03a                                    }
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
{ This is the original code.                                                   }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ Unit owner:  Ralph K. Muench                                                 }
{ Last modified:                                                               }
{      20.02.2005 by Ralph K. Muench (ralphkmuench@users.sourceforge.net)      }
{      for the Jedi Math Alpha 1.03a release                                   }
{                                                                              }
{******************************************************************************}

unit JmSpatial3D;

interface

uses
{$IFDEF WIN32}
  Dialogs,
{$ENDIF}
{$IFDEF LINUX}
  QDialogs,
{$ENDIF}
 SysUtils, Classes, Math, JmTypes, JmBasics, JmGeometry;

const
 iVek : TVector3D = ( x : 1 );  // The vector ( 1, 0, 0 )
 jVek : TVector3D = ( y : 1 );  // The vector ( 0, 1, 0 )
 kVek : TVector3D = ( z : 1 );  // The vector ( 0, 0, 1 )
 NullVek : TVector3D = ( );     // The vector ( 0, 0, 0 )
 NullPoint : TPoint3D = ( );    // The point ( 0, 0, 0 )

type
 EJmSpatial3D = class(Exception);
 {An exception class specially for raising spatial exceptions}

 TJmPointArray = array of TPoint3D;    // Zero based
 TJmVectorArray = array of TVector3D;  // Zero based

type
   ICartesianCS = interface
   ['{D057457F-8341-4575-925C-10A27FA1C2BB}']
   {This is the GUID string for the
    ICartesianCS}

    procedure SetOrigin(P: TPoint3D);
    function GetOrigin: TPoint3D;
    property Origin: TPoint3D read GetOrigin write SetOrigin;

    procedure SetIDir(v: TVector3D);
    function GetIDir: TVector3D;
    property IDir: TVector3D read GetIDir write SetIDir;

    procedure SetJDir(v: TVector3D);
    function GetJDir: TVector3D;
    property JDir: TVector3D read GetJDir write SetJDir;

    procedure SetKDir(v: TVector3D);
    function GetKDir: TVector3D;
    property KDir: TVector3D read GetKDir write SetKDir;

    procedure SetAxes(i,j,k:TVector3D);

    Function SysToGlob( P : TPoint3D ) : TPoint3D;    Overload;
    Function SysToGlob( V : TVector3D ) : TVector3D;  Overload;
    Function GlobToSys( P : TPoint3D ) : TPoint3D;    Overload;
    Function GlobToSys( V : TVector3D ) : TVector3D;  Overload;
   end;

type
   ITransformationOfCCS = interface
   ['{BDF95D4F-6D4D-4ACB-92A1-9FB4F36A4CC8}']
   {This is the GUID string for the
    ITransformationCCS}
    procedure SetEuler(v: TPoint3D);
    function GetEuler: TPoint3D;
    property Euler: TPoint3D read GetEuler write SetEuler;

    procedure SetOffset(v: TPoint3D);
    function GetOffset: TPoint3D;
    property Offset: TPoint3D read GetOffset write SetOffset;

    Procedure Invert;
    Function Transform( P : TPoint3D ) : TPoint3D;    Overload;
    Function Transform( v : TVector3D ) : TVector3D;  Overload;
    Function CopyOf : ITransformationOfCCS;
   end;

type
   ISphericalCS = interface
   ['{CE721AD1-356E-4E28-8F00-801AE5B8BB37}']
   {This is the GUID string for the
    ISphericalCS}
    Function Get_AttachedCS : ICartesianCS;
    Function SpherToCar( P : TPoint3D ) : TPoint3D;        Overload;
    Function SpherToGlob( P : TPoint3D ) : TPoint3D;       Overload;
    Function CarToSpher( P : TPoint3D ) : TPoint3D;        Overload;
    Function GlobToSpher( P : TPoint3D ) : TPoint3D;       Overload;
    Function SpherToCar( PSpher : TPoint3D; v : TVector3D ) : TVector3D;  Overload;
    Function SpherToGlob( PSpher : TPoint3D; v : TVector3D ) : TVector3D; Overload;
    Function CarToSpher( PCar : TPoint3D; v : TVector3D ) : TVector3D;    Overload;
    Function GlobToSpher( PGlob : TPoint3D; v : TVector3D ) : TVector3D;  Overload;
   end;


// Point and vector functions
Function Sub(const P1,P2:TPoint3D):TVector3D;           Overload;
Function Sum(const P:TPoint3D;v:TVector3D):TPoint3D;           Overload;
Function Sum(const P1,P2:TPoint3D):TPoint3D;           Overload;
Function IsEqual(v1,v2:TVector3D):Boolean;                                       Overload;
Function Scale(Factor:TJmFloat; P:TPoint3D):TPoint3D;                             Overload;
Function Angle( v1, v2 : TVector3D ): TJmFloat;
Function RandomPoint3D(Min,Max:TJmFloat):TPoint3D;
Function RandomSphericalPoint3D(MinR,MaxR,MinTh,MaxTh,MinPh,MaxPh:TJmFloat):TPoint3D;
Function RandomVector3D(Min,Max:TJmFloat):TVector3D;
Function CrossProduct(V1,V2:TVector3D):TVector3D;
Function PointsEqual(const P1,P2:TPoint3D;Epsilon:TJmFloat): Boolean;
Function VectorsEqual(const v1,v2:TVector3D;Epsilon:TJmFloat): Boolean;
Function MinimumAngle(const P1,P2,P3:TPoint3D) : TJmFloat;
Function CarToSpher( P : TPoint3D ) : TPoint3D;
Function SpherToCar( P : TPoint3D ) : TPoint3D;
Function ThetaPhiToDir(const theta,phi:TJmFloat ) : TVector3D;
Procedure SphericalUnitVectorsFromCar( P : TPoint3D; var R, Theta, Phi : TVector3D );
Procedure SphericalUnitVectorsFromSpher( P : TPoint3D; var R, Theta, Phi : TVector3D );

// Helper functions
Function CartesianCS : ICartesianCS;
Function RandomCartesianCS(Min,Max:TJmFloat) : ICartesianCS;
Function CartesianCSFromThreePoints(const P1,P2,P3:TPoint3D) : ICartesianCS;

Function TransformationOfCCS(Sigma1,Sigma2:ICartesianCS) : ITransformationOfCCS;
Function TransformationOfCCSUnit : ITransformationOfCCS;

Function SphericalCS(Sigma:ICartesianCS) : ISphericalCS;

// Spatial angles
// See JmSpatialDoc_Ver 0_9.pdf Version 0.9 pages 14-16
Function FiniteSpaceAngleMagnitude( Const Theta, DeltaPhi, DeltaTheta : TJmFloat ) : TJmFloat;
Procedure FiniteSpaceAngle( NPhi, NTheta, iPHi, iTheta : Longint;
                            var v1, v2, v3, v4 : TVector3D;
                            var DeltaOmega : TJmFloat );

implementation

// See JmSpatialDoc_Ver 0_9.pdf Version 0.9 pages 14-16
Function FiniteSpaceAngleMagnitude( Const Theta, DeltaPhi, DeltaTheta : TJmFloat ) : TJmFloat;
begin
 Result := ( Cos( Theta ) - Cos( Theta + DeltaTheta ) ) * DeltaPhi;
end;

// See JmSpatialDoc_Ver 0_9.pdf Version 0.9 pages 14-16
Procedure FiniteSpaceAngle( NPhi, NTheta, iPHi, iTheta : Longint;
                            var v1, v2, v3, v4 : TVector3D;
                            var DeltaOmega : TJmFloat );
var DeltaPhi, DeltaTheta : TJmFloat;
    Phi, Theta : TJmFloat;
    P, T : TJmFloat;
begin
 DeltaPhi := 2 * Pi / NPhi;
 DeltaTheta := Pi / NPhi;
 Phi := iPhi * DeltaPhi;
 Theta := iTheta * DeltaTheta;

 P := Phi;
 T := Theta;
 v1.x := Cos( P ) * Sin( T );
 v1.y := Sin( P ) * Sin( T );
 v1.z := Cos( P ) * Sin( T );

 P := Phi;
 T := Theta + DeltaTheta;
 v2.x := Cos( P ) * Sin( T );
 v2.y := Sin( P ) * Sin( T );
 v2.z := Cos( P ) * Sin( T );

 P := Phi + DeltaPhi;
 T := Theta + DeltaTheta;
 v3.x := Cos( P ) * Sin( T );
 v3.y := Sin( P ) * Sin( T );
 v3.z := Cos( P ) * Sin( T );

 P := Phi + DeltaPhi;
 T := Theta;
 v4.x := Cos( P ) * Sin( T );
 v4.y := Sin( P ) * Sin( T );
 v4.z := Cos( P ) * Sin( T );

 DeltaOmega := FiniteSpaceAngleMagnitude( Theta, DeltaPhi, DeltaTheta );
end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
                       { Point and vector functions }
(************************************************************************)
(************************************************************************)
(************************************************************************)

Function Scale(Factor:TJmFloat; P:TPoint3D):TPoint3D;
begin
 Result.x := Factor * P.x;
 Result.y := Factor * P.y;
 Result.z := Factor * P.z;
end;

Function VectorsEqual(const v1,v2:TVector3D;Epsilon:TJmFloat): Boolean;
begin
 Result := FloatsEqual( v1.x, v2.x, Epsilon ) and
           FloatsEqual( v1.y, v2.y, Epsilon ) and
           FloatsEqual( v1.z, v2.z, Epsilon );
end;

Function PointsEqual(const P1,P2:TPoint3D;Epsilon:TJmFloat): Boolean;
begin
 Result := FloatsEqual( P1.x, P2.x, Epsilon ) and
           FloatsEqual( P1.y, P2.y, Epsilon ) and
           FloatsEqual( P1.z, P2.z, Epsilon );
end;

Function RandomPoint3D(Min,Max:TJmFloat):TPoint3D;
begin
 Result.x := Random * ( Max - Min ) + Min;
 Result.y := Random * ( Max - Min ) + Min;
 Result.z := Random * ( Max - Min ) + Min;
end;

Function RandomSphericalPoint3D(MinR,MaxR,MinTh,MaxTh,MinPh,MaxPh:TJmFloat):TPoint3D;
begin
 Result.x := Random * ( MaxR - MinR ) + MinR;
 Result.y := Random * ( MaxTh - MinTh ) + MinTh;
 Result.z := Random * ( MaxPh - MinPh ) + MinPh;
end;

Function RandomVector3D(Min,Max:TJmFloat):TVector3D;
begin
 Result.x := Random * ( Max - Min ) + Min;
 Result.y := Random * ( Max - Min ) + Min;
 Result.z := Random * ( Max - Min ) + Min;
end;

Function CrossProduct(V1,V2:TVector3D):TVector3D;
begin
 Result.x := V1.y * V2.z - V1.z * V2.y;
 Result.y := V1.z * V2.x - V1.x * V2.z;
 Result.z := V1.x * V2.y - V1.y * V2.x;
end;

Function Sub(const P1,P2:TPoint3D):TVector3D; overload;
begin
 Result.x := P1.x - P2.x;
 Result.y := P1.y - P2.y;
 Result.z := P1.z - P2.z;
end;

Function Sum(const P:TPoint3D;v:TVector3D):TPoint3D; overload;
begin
 Result.x := P.x + V.x;
 Result.y := P.y + V.y;
 Result.z := P.z + V.z;
end;

Function Sum(const P1,P2:TPoint3D):TPoint3D;
begin
 Result.x := P1.x + P2.x;
 Result.y := P1.y + P2.y;
 Result.z := P1.z + P2.z;
end;

Function Sum(V:TVector3D;P:TPoint3D):TPoint3D; overload;
begin
 Result.x := P.x + V.x;
 Result.y := P.y + V.y;
 Result.z := P.z + V.z;
end;

Function IsEqual(v1,v2:TVector3D):Boolean;                                       Overload;
Begin
 Result := (IsEqual(v1.x,v2.x) And IsEqual(v1.y,v2.y) And IsEqual(v1.z,v2.z));
End;


Function Angle( v1, v2 : TVector3D ): TJmFloat;
var ca : TJmFloat;
begin
 // use: v1*v2 = |v1|*|v2|*cos( alpha )
 Try
  ca := DotProduct( v1, v2 ) / ( Magnitude( v1 ) * Magnitude( v2 ) );
 Except
  Raise EJmSpatial3D.Create( 'Angle needs non zero vectors' );
 End;
 If ca > 1 then ca := 1;
 If ca < -1 then ca := -1;
 Result := ArcCos( ca );
end;

Function MinimumAngle(const P1,P2,P3:TPoint3D) : TJmFloat;
var Tmp : TJmFloat;
begin
 Result := Angle( Sub( P2, P1 ), Sub( P3, P1 ) );
 Tmp := Angle( Sub( P1, P2 ), Sub( P3, P2 ) );
 If Tmp < Result Then
  Result := Tmp;
 Tmp := Angle( Sub( P1, P3 ), Sub( P2, P3 ) );
 If Tmp < Result Then
  Result := Tmp;
end;

Function CarToSpher( P : TPoint3D ) : TPoint3D;
begin
 // The coordinates x, y and z of the result correspond
 // to the spherical coordinates r, theta and phi
 Result.x := Sqrt((P.x*P.x)+(P.y*P.y)+(P.z*P.z));
 Try
  Result.y := ArcCos( P.z / Result.x );
 Except
  If P.y < 0 then
   Result.y := Pi
  else
   Result.y := 0;
 End;
 Try
  Result.z := ArcTan2( P.y, P.x );
 Except
  Result.z := 0;
 End;
end;

Function SpherToCar( P : TPoint3D ) : TPoint3D;
begin
 // The coordinates x, y and z of P correspond
 // to the spherical coordinates r, theta and phi
 Result.x := P.x * Cos( P.z ) * Sin( P.y );
 Result.y := P.x * Sin( P.z ) * Sin( P.y );
 Result.z := P.x * Cos( P.y );
end;

Function ThetaPhiToDir(const theta,phi:TJmFloat ) : TVector3D;
var P : TPoint3D;
begin
 P.x := 1;
 P.y := theta;
 P.z := phi;
 P := SpherToCar( P );
 Result := Sub( P, NullPoint );
end;


Procedure SphericalUnitVectorsFromCar( P : TPoint3D; var R, Theta, Phi : TVector3D );
begin
 Try
  R := UnitVector( Sub( P, NullPoint ) );
 Except
  Raise EJmSpatial3D.Create( 'Spherical unit vectors not defined at zero' );
 End;
 // Now we transform P to get Theta and Phi
 P := CarToSpher( P );
 Phi.z := 0;
 Phi.x := - Sin( P.z ); //P.z is phi
 Phi.y := Cos( P.z );

 Theta.z := - Sin( P.y ); //P.y is theta
 Theta.x := Cos( P.z ) * Cos( P.y );
 Theta.y := Sin( P.z ) * Cos( P.y );
end;

Procedure SphericalUnitVectorsFromSpher( P : TPoint3D; var R, Theta, Phi : TVector3D );
begin
 P := SpherToCar( P );
 SphericalUnitVectorsFromCar( P, R, Theta, Phi );
end;


(************************************************************************)
(************************************************************************)
(************************************************************************)
                       { TCartesianCS Type }
(************************************************************************)
(************************************************************************)
(************************************************************************)

type
 TCartesianCS = class(TInterfacedObject, ICartesianCS)
   O : TPoint3D;
   iv, jv, kv : TVector3D;

   constructor Create; overload;
   destructor Destroy; override;

   procedure SetOrigin(P: TPoint3D);
   function GetOrigin: TPoint3D;
   property Origin: TPoint3D read GetOrigin write SetOrigin;

   procedure SetIDir(v: TVector3D);
   function GetIDir: TVector3D;
   property IDir: TVector3D read GetIDir write SetIDir;

   procedure SetJDir(v: TVector3D);
   function GetJDir: TVector3D;
   property JDir: TVector3D read GetJDir write SetJDir;

   procedure SetKDir(v: TVector3D);
   function GetKDir: TVector3D;
   property KDir: TVector3D read GetKDir write SetKDir;

   procedure SetAxes(i,j,k:TVector3D);

   Function SysToGlob( P : TPoint3D ) : TPoint3D;    Overload;
   Function SysToGlob( V : TVector3D ) : TVector3D;  Overload;
   Function GlobToSys( P : TPoint3D ) : TPoint3D;    Overload;
   Function GlobToSys( V : TVector3D ) : TVector3D;  Overload;
 end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
                       { TTransformationOfCCS Type }
(************************************************************************)
(************************************************************************)
(************************************************************************)

type
 TTransformationOfCCS = class(TInterfacedObject, ITransformationOfCCS)
   Tr : TVector3D;
   Diagonal, TopRight, BottLeft : TPoint3D;

   procedure SetEuler(v: TPoint3D);
   function GetEuler: TPoint3D;
   property Euler: TPoint3D read GetEuler write SetEuler;

   procedure SetOffset(v: TPoint3D);
   function GetOffset: TPoint3D;
   property Offset: TPoint3D read GetOffset write SetOffset;

   constructor Create( Sigma1, Sigma2 : ICartesianCS ); overload;
   destructor Destroy; override;
   Procedure Invert;
   Function Transform( P : TPoint3D ) : TPoint3D;    Overload;
   Function Transform( v : TVector3D ) : TVector3D;  Overload;

   Function CopyOf : ITransformationOfCCS;
 end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
                       { TSphericalCS Type }
(************************************************************************)
(************************************************************************)
(************************************************************************)

type
 TSphericalCS = class(TInterfacedObject, ISphericalCS)
   AttachedCS : ICartesianCS;
   constructor Create( Sigma : ICartesianCS ); overload;
   destructor Destroy; override;

   Function Get_AttachedCS : ICartesianCS;
   Function SpherToCar( P : TPoint3D ) : TPoint3D;    Overload;
   Function SpherToGlob( P : TPoint3D ) : TPoint3D;   Overload;
   Function CarToSpher( P : TPoint3D ) : TPoint3D;    Overload;
   Function GlobToSpher( P : TPoint3D ) : TPoint3D;   Overload;
   Function SpherToCar( PSpher : TPoint3D; v : TVector3D ) : TVector3D;  Overload;
   Function SpherToGlob( PSpher : TPoint3D; v : TVector3D ) : TVector3D; Overload;
   Function CarToSpher( PCar : TPoint3D; v : TVector3D ) : TVector3D;    Overload;
   Function GlobToSpher( PGlob : TPoint3D; v : TVector3D ) : TVector3D;  Overload;
 end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
                       { Helper functions }
(************************************************************************)
(************************************************************************)
(************************************************************************)

Function CartesianCS : ICartesianCS;
begin
 Result := TCartesianCS.Create;
end;

Function RandomCartesianCS(Min,Max:TJmFloat) : ICartesianCS;
begin
 Result := TCartesianCS.Create;
 Result.Origin := RandomPoint3D( Min, Max );
 Result.IDir := RandomVector3D( Min, Max );
 Result.JDir := RandomVector3D( Min, Max );
end;

Function CartesianCSFromThreePoints(const P1,P2,P3:TPoint3D) : ICartesianCS;
var i, j, k : TVector3D;
begin
 Result := TCartesianCS.Create;
 Result.Origin := P1;
 If MinimumAngle( P1, P2, P3 ) * 180 / Pi < 10 then
  Raise EJmSpatial3D.Create( 'Angles between points must be larger than 10°' );
 i := UnitVector( Sub( P2, P1 ) );
 k := UnitVector( CrossProduct( i, Sub( P3, P1 ) ) );
 j := CrossProduct( k, i );
 Result.SetAxes( i, j, k );
end;

Function TransformationOfCCS(Sigma1,Sigma2:ICartesianCS) : ITransformationOfCCS;
begin
 Result := TTransformationOfCCS.Create(Sigma1,Sigma2);
end;

Function TransformationOfCCSUnit : ITransformationOfCCS;
begin
 Result := TTransformationOfCCS.Create(CartesianCS,CartesianCS);
end;

Function SphericalCS(Sigma:ICartesianCS) : ISphericalCS;
begin
 Result := TSphericalCS.Create(Sigma);
end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
                  { Implementation of TCartesianCS }
(************************************************************************)
(************************************************************************)
(************************************************************************)

constructor TCartesianCS.Create;
begin
 inherited Create;
 O :=  NullPoint;
 iv := iVek;
 jv := jVek;
 kv := kVek;
end;

destructor TCartesianCS.Destroy;
begin
 inherited;
end;

procedure TCartesianCS.SetOrigin(P: TPoint3D);
begin
 O := P;
end;

function TCartesianCS.GetOrigin: TPoint3D;
begin
 Result := O;
end;

procedure TCartesianCS.SetIDir(v: TVector3D);
var Tmp : TVector3D;
begin
 Try
  Tmp := UnitVector( v );
 Except
  Raise EJmSpatial3D.Create( 'Direction must be a non zero vector' );
 End;
 iv := Tmp;
 If DotProduct( iv, jv ) < 0.707 then
  begin
   kv := UnitVector( CrossProduct( iv, jv ) );
   jv := CrossProduct( kv, iv );
  end
 else
  begin
   jv := UnitVector( CrossProduct( iv, kv ) );
   kv := UnitVector( CrossProduct( iv, jv ) );
  end;
end;

function TCartesianCS.GetIDir: TVector3D;
begin
 Result := iv;
end;

procedure TCartesianCS.SetJDir(v: TVector3D);
var Tmp : TVector3D;
begin
 Try
  Tmp := UnitVector( v );
 Except
  Raise EJmSpatial3D.Create( 'Direction must be a non zero vector' );
 End;
 jv := Tmp;
 If DotProduct( jv, kv ) < 0.707 then
  begin
   iv := UnitVector( CrossProduct( jv, kv ) );
   kv := CrossProduct( iv, jv );
  end
 else
  begin
   kv := UnitVector( CrossProduct( jv, iv ) );
   iv := UnitVector( CrossProduct( jv, kv ) );
  end;
end;

function TCartesianCS.GetJDir: TVector3D;
begin
 Result := jv;
end;

procedure TCartesianCS.SetKDir(v: TVector3D);
var Tmp : TVector3D;
begin
 Try
  Tmp := UnitVector( v );
 Except
  Raise EJmSpatial3D.Create( 'Direction must be a non zero vector' );
 End;
 kv := Tmp;
 If DotProduct( kv, iv ) < 0.707 then
  begin
   jv := UnitVector( CrossProduct( kv, iv ) );
   iv := CrossProduct( jv, kv );
  end
 else
  begin
   iv := UnitVector( CrossProduct( kv, jv ) );
   jv := UnitVector( CrossProduct( kv, iv ) );
  end;
end;

function TCartesianCS.GetKDir: TVector3D;
begin
 Result := kv;
end;

procedure TCartesianCS.SetAxes(i,j,k:TVector3D);
var Tmp : TVector3D;
begin
 // Check that vectors are unit vectors
 If Not( FloatsEqual( Magnitude( i ), 1, 10 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs unit vectors' );
 If Not( FloatsEqual( Magnitude( j ), 1, 10 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs unit vectors' );
 If Not( FloatsEqual( Magnitude( k ), 1, 10 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs unit vectors' );
 // Check for normality
 If Not( FloatsEqual( DotProduct( i, j ),
                      0, 100 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs 3 normal vectors' );
 If Not( FloatsEqual( DotProduct( i, k ),
                      0, 100 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs 3 normal vectors' );
 If Not( FloatsEqual( DotProduct( j, k ),
                      0, 100 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs 3 normal vectors' );
 // Check for right handidness
 Tmp := CrossProduct( i, j );
 If Not( FloatsEqual( DotProduct( Tmp, k ),
                      1, 100 * ThreeFloatEpsilon ) ) then
  Raise EJmSpatial3D.Create( 'Set axes needs right handed vectors' );
 iv := i;
 jv := j;
 kv := k;
end;

Function TCartesianCS.SysToGlob( P : TPoint3D ) : TPoint3D;
var v : TVector3D;
begin
 v := Scale( P.x, iv );
 Result := Sum( O, v );
 v := Scale( P.y, jv );
 Result := Sum( Result, v );
 v := Scale( P.z, kv );
 Result := Sum( Result, v );
end;

Function TCartesianCS.SysToGlob( v : TVector3D ) : TVector3D;
var Tmp : TVector3D;
begin
 Result := Scale( v.x, iv );
 Tmp := Scale( v.y, jv );
 Result := Add( Result, Tmp );
 Tmp := Scale( v.z, kv );
 Result := Add( Result, Tmp );
end;

Function TCartesianCS.GlobToSys( P : TPoint3D ) : TPoint3D;
var rP : TVector3D;
begin
 rP := Sub( P, O );
 Result.x := DotProduct( rp, iv );
 Result.y := DotProduct( rp, jv );
 Result.z := DotProduct( rp, kv );
end;

Function TCartesianCS.GlobToSys( v : TVector3D ) : TVector3D;
begin
 Result.x := DotProduct( v, iv );
 Result.y := DotProduct( v, jv );
 Result.z := DotProduct( v, kv );
end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
               { Implementation of TTransformationOfCCS }
(************************************************************************)
(************************************************************************)
(************************************************************************)

procedure TTransformationOfCCS.SetEuler(v: TPoint3D);
var Alpha, Beta, Gamma : Extended;
    sa, sb, sc, ca, cb, cc : Extended;
    Offset_ : TVector3D;
begin
 Alpha := v.x;
 Beta  := v.y;
 Gamma := v.z;
 Offset_ := Tr;
 sa := sin( Alpha );
 sb := sin( Beta );
 sc := sin( Gamma );
 ca := cos( Alpha );
 cb := cos( Beta );
 cc := cos( Gamma );
 TopRight := NullPoint;
 BottLeft := NullPoint;
 Diagonal.x := 1;
 Diagonal.y := 1;
 Diagonal.z := 1;
 Diagonal.x := ca * cc - sa * cb * sc;
 Diagonal.y := ca * cb * cc - sa * sc;
 Diagonal.z := cb;
 TopRight.x := - cb * sa * cc - ca * sc;
 TopRight.y := sa * sb;
 BottLeft.x := cb * ca * sc + sa * cc;
 TopRight.z := -ca * sb;
 BottLeft.y := sb * sc;
 BottLeft.z := sb * cc;
 InVert;
  {
 MInv.Set_Equal_To( M );
 MInv.Invert;
 MInv[ 0, 1 ] := Offset_.x;
 MInv[ 0, 2 ] := Offset_.y;
 MInv[ 0, 3 ] := Offset_.z;
 MInv[ 1, 0 ] := 0;
 MInv[ 2, 0 ] := 0;
 MInv[ 3, 0 ] := 0;
 M.Set_Equal_To( MInv );
 M.Invert;
 M[ 1, 0 ] := 0;
 M[ 2, 0 ] := 0;
 M[ 3, 0 ] := 0;
   }
end;

function TTransformationOfCCS.GetEuler: TPoint3D;
begin
end;

procedure TTransformationOfCCS.SetOffset(v: TPoint3D);
begin
end;

function TTransformationOfCCS.GetOffset: TPoint3D;
begin
end;

Function TTransformationOfCCS.CopyOf : ITransformationOfCCS;
var Zw : TTransformationOfCCS;
begin
 Zw := TTransformationOfCCS.Create(CartesianCS,CartesianCS);
 // Result := TransformationOfCCSUnit;
 // Exit;

 Zw.Diagonal := Self.Diagonal;
 Zw.TopRight := Self.TopRight;
 Zw.Bottleft := Self.Bottleft;
 Zw.Tr := Self.Tr;
 Result := ITransformationOfCCS( Zw );
end;

constructor TTransformationOfCCS.Create( Sigma1, Sigma2 : ICartesianCS );
begin
 inherited Create;
 Diagonal.x := DotProduct( Sigma1.IDir, Sigma2.IDir );
 BottLeft.x := DotProduct( Sigma1.IDir, Sigma2.JDir );
 BottLeft.y := DotProduct( Sigma1.IDir, Sigma2.KDir );

 TopRight.x := DotProduct( Sigma1.JDir, Sigma2.IDir );
 Diagonal.y := DotProduct( Sigma1.JDir, Sigma2.JDir );
 BottLeft.z := DotProduct( Sigma1.JDir, Sigma2.KDir );

 TopRight.y := DotProduct( Sigma1.KDir, Sigma2.IDir );
 TopRight.z := DotProduct( Sigma1.KDir, Sigma2.JDir );
 Diagonal.z := DotProduct( Sigma1.KDir, Sigma2.KDir );

 Tr := Sigma1.GlobToSys( Sub( Sigma1.Origin, Sigma2.Origin ) );
 Tr := Transform( Tr );
end;

destructor TTransformationOfCCS.Destroy;
begin
 inherited;
end;

Procedure TTransformationOfCCS.Invert;
var Zw : TPoint3D;
begin
 Zw := BottLeft;
 BottLeft := TopRight;
 TopRight := Zw;
 Tr := Transform( Tr );
 Tr.x := - Tr.x;
 Tr.y := - Tr.y;
 Tr.z := - Tr.z;
end;

Function TTransformationOfCCS.Transform( P : TPoint3D ) : TPoint3D;
begin
 Result.x := Diagonal.x * P.x + TopRight.x * P.y + TopRight.y * P.z;
 Result.y := BottLeft.x * P.x + Diagonal.y * P.y + TopRight.z * P.z;
 Result.z := BottLeft.y * P.x + BottLeft.z * P.y + Diagonal.z * P.z;
 Result := Sum( Result, Tr );
end;

Function TTransformationOfCCS.Transform( v : TVector3D ) : TVector3D;
begin
 Result.x := Diagonal.x * v.x + TopRight.x * v.y + TopRight.y * v.z;
 Result.y := BottLeft.x * v.x + Diagonal.y * v.y + TopRight.z * v.z;
 Result.z := BottLeft.y * v.x + BottLeft.z * v.y + Diagonal.z * v.z;
end;

(************************************************************************)
(************************************************************************)
(************************************************************************)
               { Implementation of TSphericalCS }
(************************************************************************)
(************************************************************************)
(************************************************************************)

Function TSphericalCS.Get_AttachedCS : ICartesianCS;
begin
 Result := AttachedCS;
end;

constructor TSphericalCS.Create( Sigma : ICartesianCS );
begin
 inherited Create;
 AttachedCS := Sigma;
end;

destructor TSphericalCS.Destroy;
begin
 inherited;
end;

Function TSphericalCS.SpherToCar( P : TPoint3D ) : TPoint3D;
begin
 Result := JmSpatial3D.SpherToCar( P );
end;

Function TSphericalCS.SpherToGlob( P : TPoint3D ) : TPoint3D;
begin
 Result := AttachedCS.SysToGlob( SpherToCar( P ) );
end;

Function TSphericalCS.CarToSpher( P : TPoint3D ) : TPoint3D;
begin
 Result := JmSpatial3D.CarToSpher( P );
end;

Function TSphericalCS.GlobToSpher( P : TPoint3D ) : TPoint3D;
begin
 Result := CarToSpher( AttachedCS.GlobToSys( P ) );
end;

Function TSphericalCS.SpherToCar( PSpher : TPoint3D; v : TVector3D ) : TVector3D;
var RDir, ThetaDir, PhiDir : TVector3d;
begin
 SphericalUnitVectorsFromSpher( PSpher, RDir, ThetaDir, PhiDir );
 Result := Scale( RDir, v.x );
 Result := Add( Result, Scale( ThetaDir, v.y ) );
 Result := Add( Result, Scale( PhiDir, v.z ) );
end;

Function TSphericalCS.SpherToGlob( PSpher : TPoint3D; v : TVector3D ) : TVector3D;
begin
 Result := AttachedCS.SysToGlob( SpherToCar( PSpher, v ) );
end;

Function TSphericalCS.CarToSpher( PCar : TPoint3D; v : TVector3D ) : TVector3D;
var RDir, ThetaDir, PhiDir : TVector3d;
    PSpher : TPoint3D;
begin
 PSpher := Self.CarToSpher( PCar );
 SphericalUnitVectorsFromSpher( PSpher, RDir, ThetaDir, PhiDir );
 Result.x := DotProduct( v, RDir );
 Result.y := DotProduct( v, ThetaDir );
 Result.z := DotProduct( v, PhiDir );
end;

Function TSphericalCS.GlobToSpher( PGlob : TPoint3D; v : TVector3D ) : TVector3D;
var PSys : TPoint3D;
    vSys : TVector3D;
begin
 PSys := AttachedCS.GlobToSys( PGlob );
 vSys := AttachedCS.GlobToSys( v );
 Result := Self.CarToSpher( PSys, vSys );
end;

end.







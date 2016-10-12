unit Matrix_preobraz;



interface



uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, Matrixes,MyTypes;


function IsometryMatrix(phi,theta : Real) : TMatrix;


implementation
               
function RotXMatrix(Angle: Extended) : TMatrix;
begin
  Result := TMatrix.CreateE(4);  //Роджерс и Адамс, с. 121

 Result[2,2] := Cos(Angle);
 Result[3,3] := Result[2,2];
 Result[2,3] := Sin(Angle);
 Result[3,2] := -Result[2,3];
end;

function RotYMatrix(Angle: Extended) : TMatrix;
begin
 Result := TMatrix.CreateE(4);//Роджерс и Адамс, с. 122

 Result[1,1] := Cos(Angle);
 Result[1,3] := -Sin(Angle);
 Result[3,3] := Result[1,1];
 Result[3,1] := -Result[1,3];
end;

function RotZMatrix(Angle: Extended) : TMatrix;
begin
 Result := TMatrix.CreateE(4); //Роджерс и Адамс, с. 122

 Result[1,1] := Cos(Angle);
 Result[1,2] := Sin(Angle);
 Result[2,1] := -Result[1,2];
 Result[2,2] := Result[1,1];
end;

function IsometryMatrix(phi,theta : Real) : TMatrix;
var
  phimatrix, thetamatrix : TMatrix;
begin
  phimatrix := RotYMatrix(phi);
  thetamatrix := RotXMatrix(theta);

  Result := phimatrix.Mult(thetamatrix);
end;


end.

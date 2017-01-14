unit DeveloperTools;

interface

uses FlightData, HelicoptersDatabase, Dialogs, SysUtils;


function MaxRelativeDifferencies(flightdata : TFlightData;helicopter : THelicopter) : TStateVector;overload;


implementation

function Difference(statevector1, statevector2 : TStateVector) : TStateVector;
begin
  with Result do
   begin
     x := Abs(statevector2.x - statevector1.x);
     y := Abs(statevector2.y - statevector1.y);
     z := Abs(statevector2.z - statevector1.z);
     theta := Abs(statevector2.theta - statevector1.theta);
     thetaVisual := Abs(statevector2.thetaVisual - statevector1.thetaVisual);
     gamma := Abs(statevector2.gamma - statevector1.gamma);
     psi := Abs(statevector2.psi - statevector1.psi);
     V := Abs(statevector2.V - statevector1.V);
     ny := Abs(statevector2.ny - statevector1.ny);
     t := Abs(statevector2.t - statevector1.t);
   end;
end;

function AbsoluteDifferencies (manevrdata : TManevrData) : TManevrData;
var
  len, i : Integer;

begin

  len := Length(manevrdata);

  SetLength(Result,len-1);

  for i := Low(Result) to High(Result) do
    Result[i] := Difference(manevrdata[i+1], manevrdata[i]);


end;

function AbsoluteDifferenciesAverageSum (differencies : TManevrData) : TStateVector;
var
  i, len : Integer;
begin
  with Result do
   begin
     x := 0;
     y := 0;
     z := 0;
     theta := 0;
     thetaVisual := 0;
     gamma := 0;
     psi := 0;
     V := 0;
     ny := 0;
     t := 0;
   end;

 for i := Low(differencies) to High(differencies) do
  begin
    Result.x := Result.x + differencies[i].x;
    Result.y := Result.y + differencies[i].y;
    Result.z := Result.z + differencies[i].z;
    Result.theta := Result.theta + differencies[i].theta;
    Result.thetaVisual := Result.thetaVisual + differencies[i].thetaVisual;
    Result.gamma := Result.gamma + differencies[i].gamma;
    Result.psi := Result.psi + differencies[i].psi;
    Result.V := Result.V + differencies[i].V;
    Result.ny := Result.ny + differencies[i].ny;
    Result.t := Result.t + differencies[i].t;
  end;

   len := Length(differencies);

   if len > 0 then
    with Result do
     begin
       x := x/len;
       y := y/len;
       z := z/len;
       theta := theta/len;
       thetaVisual := thetaVisual/len;
       gamma := gamma/len;
       psi := psi/len;
       V := V/len;
       ny := ny/len;
       t := t/len;
     end
   else
    ShowMessage('DeveloperTools`AbsoluteDifferenciesAverageSum: Devision by zero!');

end;

function Divide (arg1, arg2 : Real) : Real;overload;
begin
 if not (arg2 = 0) then
  Result := arg1/arg2
 else
  Result := 0;
end;

function Divide (statevector1, statevector2 : TStateVector) : TStateVector;overload;
begin
  with Result do
   begin
     x := Divide(statevector1.x,statevector2.x);
     y := Divide(statevector1.y,statevector2.y);
     z := Divide(statevector1.z,statevector2.z);
     theta := Divide(statevector1.theta,statevector2.theta);
     thetaVisual := Divide(statevector1.thetaVisual,statevector2.thetaVisual);
     gamma := Divide(statevector1.gamma,statevector2.gamma);
     psi := Divide(statevector1.psi,statevector2.psi);
     V := Divide(statevector1.V,statevector2.V);
     ny := Divide(statevector1.ny,statevector2.ny);
     t := Divide(statevector1.t,statevector2.t);
   end;
end;

function MaxRelativeDifferencies(theAbsoluteDifferencies : TManevrData; anAbsoluteDifferenciesSum : TStateVector) : TStateVector;overload;
const
  percent = 100;
  bignumber = -10050000.;
var
 i : Integer;

begin
  with Result do
   begin
     x := bignumber;
     y := bignumber;
     z := bignumber;
     theta := bignumber;
     thetaVisual := bignumber;
     gamma := bignumber;
     psi := bignumber;
     V := bignumber;
     ny := bignumber;
     t := bignumber;
   end;

   for i := Low(theAbsoluteDifferencies) to High(theAbsoluteDifferencies) do
    begin
      FindingMax(theAbsoluteDifferencies[i].x, Result.x);
      FindingMax(theAbsoluteDifferencies[i].y, Result.y);
      FindingMax(theAbsoluteDifferencies[i].z, Result.z);
      FindingMax(theAbsoluteDifferencies[i].theta, Result.theta);
      FindingMax(theAbsoluteDifferencies[i].thetaVisual, Result.thetaVisual);
      FindingMax(theAbsoluteDifferencies[i].gamma, Result.gamma);
      FindingMax(theAbsoluteDifferencies[i].psi, Result.psi);
      FindingMax(theAbsoluteDifferencies[i].V, Result.V);
      FindingMax(theAbsoluteDifferencies[i].ny, Result.ny);
      FindingMax(theAbsoluteDifferencies[i].t, Result.t);
    end;

    Result := Divide(Result, anAbsoluteDifferenciesSum)
end;

function MaxRelativeDifferencies(flightdata : TFlightData;helicopter : THelicopter) : TStateVector;overload;
var
 AbsDifferencies : TManevrData;
begin
 AbsDifferencies := AbsoluteDifferencies (FlightDataToManevrData(FlightData, helicopter));

 Result := MaxRelativeDifferencies(AbsDifferencies, AbsoluteDifferenciesAverageSum (AbsDifferencies))

 
end;

end.

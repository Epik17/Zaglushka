unit DeveloperTools;

interface

uses FlightData, HelicoptersDatabase, Dialogs, SysUtils;


function MaxRelativeDifferencies(flightdata : TFlightData;helicopter : THelicopter) : TStateVector;overload; //во сколько раз максимальное приращение величины больше среднего. Норма: 1-2 раза
function FormatDif(difs : TStateVector) : string;

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
  i: Integer;
  counters : TStateVector;
const
  smallnumber = 0.00001;
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

  with counters do
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
    if differencies[i].x > smallnumber then
     counters.x := counters.x + 1;

    Result.y := Result.y + differencies[i].y;
    if differencies[i].y > smallnumber then
     counters.y := counters.y + 1;

    Result.z := Result.z + differencies[i].z;
    if differencies[i].z > smallnumber then
     counters.z := counters.z + 1;

    Result.theta := Result.theta + differencies[i].theta;
    if differencies[i].theta > smallnumber then
     counters.theta := counters.theta + 1;

    Result.thetaVisual := Result.thetaVisual + differencies[i].thetaVisual;
    if differencies[i].thetaVisual > smallnumber then
     counters.thetaVisual := counters.thetaVisual + 1;

    Result.gamma := Result.gamma + differencies[i].gamma;
    if differencies[i].gamma > smallnumber then
     counters.gamma := counters.gamma + 1;

    Result.psi := Result.psi + differencies[i].psi;
    if differencies[i].psi > smallnumber then
     counters.psi := counters.psi + 1;

    Result.V := Result.V + differencies[i].V;
    if differencies[i].V > smallnumber then
     counters.V := counters.V + 1;

    Result.ny := Result.ny + differencies[i].ny;
    if differencies[i].ny > smallnumber then
     counters.ny := counters.ny + 1;

    Result.t := Result.t + differencies[i].t;
    if differencies[i].t > smallnumber then
     counters.t := counters.t + 1;
  end;

    with Result do
     begin
       if counters.x <> 0 then
        x := x/counters.x
       else
        x := 0;

       if counters.y <> 0 then
        y := y/counters.y
       else
        y := 0;

       if counters.z <> 0 then
        z := z/counters.z
       else
        z := 0;

       if counters.theta <> 0 then
        theta := theta/counters.theta
       else
        theta := 0;

       if counters.thetaVisual <> 0 then
        thetaVisual := thetaVisual/counters.thetaVisual
       else
        thetaVisual := 0;

       if counters.gamma <> 0 then
        gamma := gamma/counters.gamma
       else
        gamma := 0;


       if counters.psi <> 0 then
        psi := psi/counters.psi
       else
        psi := 0;

       if counters.V <> 0 then
        V := V/counters.V
       else
        V := 0;

       if counters.ny <> 0 then
        ny := ny/counters.ny
       else
        ny := 0;

       if counters.t <> 0 then
        t := t/counters.t
       else
        t := 0;
     end

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

function FormatDif(difs : TStateVector) : string;

function MyFloatToStrF(value:Real):string;
  begin  //auxiliary function
    Result := FloatToStrF(value,FfFixed,20,1)
  end;
begin

  Result:=
  'dx = ' + MyFloatToStrF(difs.x) +
  '; dy = ' +  MyFloatToStrF(difs.y) +
  '; dz = ' +   MyFloatToStrF(difs.z) +
  '; dtheta = ' +   MyFloatToStrF(difs.theta) +
  '; dthetaVisual = ' +   MyFloatToStrF(difs.thetaVisual) +
  '; dgamma = ' +   MyFloatToStrF(difs.gamma) +
  '; dpsi = ' +   MyFloatToStrF(difs.psi) +
  '; dV = ' +   MyFloatToStrF(difs.V) +
  '; dny = ' +   MyFloatToStrF(difs.ny) +
  '; dt = ' +   MyFloatToStrF(difs.t)

end;

end.

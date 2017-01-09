unit FlightData;

interface
uses SysUtils,MyTypes, Math, GlobalConstants, HelicoptersDatabase,Dialogs;

type TStateVector = record
x,y,z,{m}
theta,gamma,psi,{rad}
V{m/s},
ny,
t{s} : Real;
end;                     

type TManevrData = array of TStateVector;
type TFlightData = array of TManevrData;

type TManevrPropsPerebornye = record
Vmax, Vmin, S, xmin, xmax, ymin, ymax, zmin, zmax : Real
end;


function StateVectorString (state:TStateVector):string;
function ToXYZ1Array(FlightData : TManevrData) : TArrayOfArrayOfReal;overload;
procedure AppendManevrData(var GlobalFlightData: TFlightData; Manevr : TManevrData; helicopter : THelicopter);overload;
procedure AppendManevrData(var MainManevrData: TManevrData; Manevr : TManevrData; helicopter : THelicopter);overload;
function PrependManevrDataWithStateVector (ManevrData: TManevrData; statevector : TStateVector) : TManevrData;

function FlightDataToManevrData(FlightData : TFlightData; helicopter : THelicopter) : TManevrData;

function tVypoln(Manevr : TManevrData) : Extended;
function Vfinal(Manevr : TManevrData) : Extended;
function deltaX(Manevr : TManevrData) : Extended;
function deltaY(Manevr : TManevrData) : Extended;
function deltaZ(Manevr : TManevrData) : Extended;
function ManevrPropsPerebornye(Manevr : TManevrData) : TManevrPropsPerebornye;


implementation

function StateVectorString (state:TStateVector):string;
  function MyFloatToStrF(value:Real):string;
  begin  //auxiliary function
    Result := FloatToStrF(value,FfFixed,20,5)
  end;

begin 
  with state do
   Result :=
   MyFloatToStrF(x)+' '+
   MyFloatToStrF(y)+' '+
   MyFloatToStrF(z)+' '+
   MyFloatToStrF(RadToDeg(theta))+' '+
   MyFloatToStrF(-{for Blitz3D}RadToDeg(gamma))+' '+
   MyFloatToStrF(RadToDeg(psi))+' '+
   MyFloatToStrF(V*g_mps)+' '+
   MyFloatToStrF(ny)+' '+
   MyFloatToStrF(t)+' '
end;

function ToXYZ1Array(statevector : TStateVector) : TArrayOfReal; overload;

begin
  SetLength(Result,4);
  with statevector do
   begin
     Result[0] := x;
     Result[1] := y;
     Result[2] := z;
     Result[3] := 1;
   end;

end;

function ToXYZ1Array(FlightData : TManevrData) : TArrayOfArrayOfReal; overload;
var
  i,count : Integer;
begin
  count := Length(FlightData);

  SetLength(Result,count);

  for i:=0 to count -1 do
   Result[i]:= ToXYZ1Array(FlightData[i])
end;

function VmaxNotReached(helicopter : THelicopter;flightdata : TManevrData) : Boolean;
var
  i:Integer;
begin
 Result := False;

 for i :=0  to High(flightdata) do
  if flightdata[i].V*g_mps > 0.95*helicopter.Vmax then
  begin
   Result := True;
   Break;
  end;
end;

procedure AppendManevrData(var GlobalFlightData: TFlightData; Manevr : TManevrData; helicopter : THelicopter);overload;
var
  i, initialcount :Integer;
begin
 if not VmaxNotReached (helicopter,Manevr) then
  begin

    initialcount := Length(GlobalFlightData);
    SetLength(GlobalFlightData,initialcount+1);
    SetLength(GlobalFlightData[High(GlobalFlightData)],Length(Manevr));

    for i:=Low(Manevr) to High(Manevr) do
      GlobalFlightData[High(GlobalFlightData),i]:= Manevr[i];

  end
 else
  ShowMessage('Ошибка при подстыковке маневра. Превышение разрешенной максимальной скорости (' + FloatToStr(0.95*helicopter.Vmax)+ ') км/ч')
end;

procedure AppendManevrData(var MainManevrData: TManevrData; Manevr : TManevrData; helicopter : THelicopter);overload;
var
  i, initialcount :Integer;
begin
 if not VmaxNotReached (helicopter,Manevr) then
  begin

    initialcount := Length(MainManevrData);
    SetLength(MainManevrData,initialcount+Length(Manevr));

    for i:=Low(Manevr) to High(Manevr) do
      MainManevrData[initialcount+i]:= Manevr[i]

  end
 else
  ShowMessage('Превышение разрешенной максимальной скорости (' + FloatToStr(0.95*helicopter.Vmax)+ ') км/ч')
end;

function FlightDataToManevrData(FlightData : TFlightData; helicopter : THelicopter) : TManevrData;
var
  i : Integer;
begin
  SetLength(Result,0);

  for i := Low(FlightData) to High(FlightData) do
   AppendManevrData(Result,FlightData[i],helicopter)
end;

function PrependManevrDataWithStateVector (ManevrData: TManevrData; statevector : TStateVector) : TManevrData;
var
  i : Integer;
begin
 SetLength(Result, Length(ManevrData)+1);
 Result[0]:= statevector;
 for i := 0 to High(ManevrData) do
  Result[i+1]:= ManevrData[i]
end;



function tVypoln(Manevr : TManevrData) : Extended;
{var
 t0 : Real;  }
begin
 // t0 := Manevr[Low(Manevr)].t;

  Result := Manevr[High(Manevr)].t - Manevr[Low(Manevr)].t;

 { if t0 > dt/2 then
   Result := Result + dt;
     }
end;

function Vfinal(Manevr : TManevrData) : Extended;
begin
  Result := Manevr[High(Manevr)].V * g_mps
end;

function deltaX(Manevr : TManevrData) : Extended;
begin
  Result := Manevr[High(Manevr)].x - Manevr[Low(Manevr)].x
end;

function deltaY(Manevr : TManevrData) : Extended;
begin
  Result := Manevr[High(Manevr)].y - Manevr[Low(Manevr)].y
end;

function deltaZ(Manevr : TManevrData) : Extended;
begin
  Result := Manevr[High(Manevr)].z - Manevr[Low(Manevr)].z
end;

function ManevrPropsPerebornye(Manevr : TManevrData) : TManevrPropsPerebornye;
const
 bigNumber = 1005000;
var
  i : Integer;

procedure FindingMin (var tempvalue : Real; var min : Real);
 begin
  if tempvalue < min then
    min := tempvalue
 end;

procedure FindingMax (var tempvalue : Real; var max : Real);
 begin
  if tempvalue > max then
    max := tempvalue
 end;

begin
  Result.S := 0;

  Result.xmin := bigNumber;
  Result.ymin := bigNumber;
  Result.zmin := bigNumber;
  Result.Vmin := bigNumber;
  Result.xmax := -bigNumber;
  Result.ymax := -bigNumber;
  Result.zmax := -bigNumber;
  Result.Vmax := -bigNumber;

  for i := 0 to High(Manevr) do
   begin
    if i > 0 then
     Result.S := Result.S + Sqrt(Sqr(Manevr[i].x - Manevr[i-1].x) + Sqr(Manevr[i].y - Manevr[i-1].y) + Sqr(Manevr[i].z - Manevr[i-1].z));

     FindingMin(Manevr[i].x, Result.xmin);
     FindingMax(Manevr[i].x, Result.xmax);

     FindingMin(Manevr[i].y, Result.ymin);
     FindingMax(Manevr[i].y, Result.ymax);

     FindingMin(Manevr[i].z, Result.zmin);
     FindingMax(Manevr[i].z, Result.zmax);

     FindingMin(Manevr[i].V, Result.Vmin);
     FindingMax(Manevr[i].V, Result.Vmax);
   end;

  Result.Vmin := Result.Vmin * g_mps;
  Result.Vmax := Result.Vmax * g_mps;
end;

end.

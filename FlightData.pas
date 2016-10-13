unit FlightData;

interface
uses SysUtils,MyTypes, Math, GlobalConstants, HelicoptersDatabase,Dialogs;

type TStateVector = record
x,y,z,theta,gamma,psi,V,ny,t : Real;
end;                     

type TManevrData = array of TStateVector;
type TFlightData = array of TManevrData;

function StateVectorString (state:TStateVector):string;
function ToXYZ1Array(FlightData : TManevrData) : TArrayOfArrayOfReal;overload;
procedure AppendManevrData(var GlobalFlightData: TFlightData; Manevr : TManevrData; helicopter : THelicopter);overload;
procedure AppendManevrData(var MainManevrData: TManevrData; Manevr : TManevrData; helicopter : THelicopter);overload;



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
  ShowMessage('Превышение разрешенной максимальной скорости (' + FloatToStr(0.95*helicopter.Vmax)+ ') км/ч')
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




end.

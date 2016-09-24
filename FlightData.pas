unit FlightData;

interface
uses SysUtils,MyTypes, Math;

type TStateVector = record
x,y,z,theta,gamma,psi,V,ny,t : Real;
end;


type TFlightData = array of TStateVector;

function StateVectorString (state:TStateVector):string;
function ToXYZ1Array(statevector : TStateVector) : TArrayOfReal;  overload;
function ToXYZ1Array(FlightData : TFlightData) : TArrayOfArrayOfReal; overload;

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
   MyFloatToStrF(RadToDeg(gamma))+' '+
   MyFloatToStrF(RadToDeg(psi))+' '+
   MyFloatToStrF(V*3.6)+' '+
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

function ToXYZ1Array(FlightData : TFlightData) : TArrayOfArrayOfReal; overload;
var
  i,count : Integer;
begin
  count := Length(FlightData);

  SetLength(Result,count);

  for i:=0 to count -1 do
   Result[i]:= ToXYZ1Array(FlightData[i])
end;
end.

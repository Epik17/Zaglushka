unit World;

interface

function AirDensity(H : Real{height in meters}) : Real ;

implementation
function AirDensity(H : Real{height in meters}) : Real;
begin
  Result := 0.125*(20-H/1000)/(20+H/1000);
end;
end.
 
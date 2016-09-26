unit Manoeuvres;

interface

uses FlightData,Math,HelicoptersDatabase,Kernel,Dialogs, JmGeometry,SysUtils;

type TVector = record
x,y,z : Real;
end;


procedure AppendManevr(var GlobalFlightData: TFlightData; Manevr : TFlightData; helicopter : THelicopter);
function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TFlightData;
function iGorkaPikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real; Pikirovanie : Boolean) : TFlightData;
function Gorka (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TFlightData;
function Pikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TFlightData;
function iVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real; Left:Boolean) : TFlightData;
function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TFlightData;
function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TFlightData;
function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TFlightData;
function Vvector(Vmodule, psi, theta : Real) : TVector;
function Vvector3D(Vmodule, psi, theta : Real) : TVector3D;
procedure ExtendArray(var myarray: TFlightData);overload;
procedure ExtendArray(var myarray: TFlightData; count: Integer);overload;
procedure MyIntegrate(var tempstate : TStateVector; dt,a : Real;omega : TVector3D);
procedure g_Etape(var TempFlightData : TFlightData; var tempstate : TStateVector; helicopter : THelicopter; ny,a : Real; omega : TVector3D);
procedure VErrorMessage(temp,min,max: Real);
function GorkaPikirovanieInputheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax : Real; Pikirovanie : Boolean) : TFlightData;
function VmaxNotReached(helicopter : THelicopter;flightdata : TFlightData) : Boolean;

const
 dt = 0.1; //��� �� �������, �
 g = 9.81;
 mps = 3.6;

implementation

function VmaxNotReached(helicopter : THelicopter;flightdata : TFlightData) : Boolean;
var
  i:Integer;
begin
 Result := False;

 for i :=0  to High(flightdata) do
  if flightdata[i].V*mps > 0.95*helicopter.Vmax then
  begin
   Result := True;
   Break;
  end;
end;

procedure AppendManevr(var GlobalFlightData: TFlightData; Manevr : TFlightData; helicopter : THelicopter);
var
  i, initialcount :Integer;
begin
 if not VmaxNotReached (helicopter,Manevr) then
  begin
    initialcount := Length(GlobalFlightData);
    SetLength(GlobalFlightData,initialcount+Length(Manevr));

    for i:=Low(Manevr) to High(Manevr) do
      GlobalFlightData[initialcount+i]:= Manevr[i]
  end
 else
  ShowMessage('���������� ����������� ������������ �������� (' + FloatToStr(0.95*helicopter.Vmax)+ ') ��/�')
end;

function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TFlightData;
var
  distance, tempt,tempx,tempz,dx,dz : Real;
begin
  SetLength(Result,0);
  distance :=0;
  tempt := initialstate.t;
  tempx := initialstate.x;
  tempz := initialstate.z;

  while distance <= desiredDistance do
   begin
    ExtendArray(Result);

    with Result[High(Result)] do
     begin
      y := initialstate.y;
      V := initialstate.V;
      psi := initialstate.psi;
      theta := initialstate.theta;
      gamma := initialstate.gamma;
      ny := initialstate.ny;

        tempt := tempt + dt;
      t := tempt;
        dx:=V*dt*Cos(psi);
        tempx := tempx+dx;
      x := tempx;
        dz:=V*dt*Sin(psi);
        tempz := tempz+dz;
      z := tempz;
      distance := distance + Sqrt(Sqr(dx)+Sqr(dz))
     end;
     
   end;

end;

procedure g_Etape(var TempFlightData : TFlightData; var tempstate : TStateVector; helicopter : THelicopter; ny,a : Real; omega : TVector3D);
begin
  ExtendArray(TempFlightData);

  MyIntegrate(tempstate,dt,a,omega);

  TempFlightData[High(TempFlightData)] := tempstate;
end;

function iGorkaPikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real; Pikirovanie : Boolean) : TFlightData;
var
 vvod,nakl,vyvod : TFlightData;
 nyslope,tempa,dnxa : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny,nx,dnxa,nxOtXvr : Real);

begin
     omega.x:=0;
     omega.y:=0;
     if tempstate.V>=0 then
      omega.z := (ny-Cos(tempstate.theta))*g/tempstate.V   //rad
     else
      begin
        omega.z :=0;
        ShowMessage('procedure SetOmegaAndAcceleration: V <= 0!');
        Halt;
      end;

      a := g*(nx - dnxa - Sin(tempstate.theta) - nxOtXvr);
end;

procedure Etape(var TempFlightData : TFlightData; ny : Real);
   begin
    ExtendArray(TempFlightData);

    SetOmegaAndAcceleration(tempomega, tempa, tempstate,ny,nx(helicopter, ny, icG, icT,tempstate.y,mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,mps*tempstate.V)); //��������� �������� � ��/�

    MyIntegrate(tempstate,dt,tempa,tempomega);

    TempFlightData[High(TempFlightData)] := tempstate;
   end;

begin
   //��������������
   tempstate := initialstate;

   dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*mps);  //��������� �������� � ��/�

   failed := False;

 //����
   SetLength(vvod,0);

 if (tempstate.V > 0) and not failed then
  while not ((RadToDeg(tempstate.theta)>=thetaSlope) xor Pikirovanie) do
   begin
    SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyvvoda,nx(helicopter, nyvvoda, icG, icT,tempstate.y,mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,mps*tempstate.V)); //��������� �������� � ��/�
    g_Etape(vvod,tempstate, helicopter, nyvvoda,tempa, tempomega);
   end
 else
  failed := True;

  vvod[High(vvod)].theta := DegToRad(thetaSlope);

 //��������� �������
   SetLength(nakl,0);

   nyslope := Cos(tempstate.theta);

 if (tempstate.V > 0) and not failed then
  while not ((mps*tempstate.V <= Vvyvoda) xor Pikirovanie) do
    Etape(nakl,nyslope)
 else
  failed := True;

 //�����  
   SetLength(vyvod,0);

 if (tempstate.V > 0) and not failed then
  while not ((RadToDeg(tempstate.theta)<=0) xor Pikirovanie) do
    Etape(vyvod,nyvyvoda)
 else
  failed := True;

  vyvod[High(vyvod)].theta := 0.;

  if failed then ShowMessage('������� �������� �� ����!');

 //�������
  SetLength(Result,0);
  AppendManevr(Result,vvod,helicopter);
  AppendManevr(Result,nakl,helicopter);
  AppendManevr(Result,vyvod,helicopter);

 //������� 
  SetLength(vvod,0);
  SetLength(nakl,0);
  SetLength(vyvod,0);
end;

procedure VErrorMessage(temp,min,max: Real);
begin
  ShowMessage('�������� ����� ��������� ' + FloatToStr(Round(temp)) + ' ��/�. ��� �������� ������ ������ � ��������� �� '+FloatToStr(min) + ' �� '+FloatToStr(max) +' ��/�');
end;


function GorkaPikirovanieInputheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax : Real; Pikirovanie : Boolean) : TFlightData;
var
  Vtemp : Real;
begin
  Vtemp := initialstate.V*mps;

  if (Vtemp>=Vmin) and (Vtemp<=Vmax) then
   Result := iGorkaPikirovanie(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Pikirovanie)
  else
   begin
     SetLength(Result,0);
     VErrorMessage(Vtemp,Vmin,Vmax)
   end;
end;

function Gorka (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TFlightData;
const
  Vmin = 150;
var
  Vmax : Real;
begin
  Vmax := 0.9*helicopter.Vmax;

  Result := GorkaPikirovanieInputheck(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax,False)
end;


function Pikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TFlightData;
const
  Vmin = 50;
  Vmax = 150;
begin
  Result := GorkaPikirovanieInputheck(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax,True)
end;

function iVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real; Left: Boolean) : TFlightData;
var
  tempa, tempny, dpsiVvod, prevgamma: Real;
  vvod, constgammaUchastok,vyvod : TFlightData;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed:Boolean;
procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny : Real; Left: Boolean);

begin
     failed := False;

     omega.x:=DegToRad(10);  //�������� ����� � ���� (������ �� �����), �������� � �������
     if Left then omega.x := -omega.x;

     omega.z:=0;
     if tempstate.V>=0 then
      begin
       omega.y := Sqrt(Sqr(ny)-1)*g/tempstate.V;   //rad

       if not Left then omega.y := -omega.y;
      end

     else
      begin
        omega.y :=0;
        ShowMessage('procedure SetOmegaAndAcceleration: V <= 0!');
        Halt;
      end;
      a := 0;
end;

begin
   //��������������
 tempstate := initialstate;
 tempny :=1;

 //����
   SetLength(vvod,0);
  if (tempstate.V > 0) and not failed then
   while not (Abs(RadToDeg(tempstate.gamma)) >=Abs(kren)) do
     begin
      tempny := 1/Cos(tempstate.gamma);
      SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny, Left);
      g_Etape(vvod,tempstate, helicopter, tempny,tempa, tempomega);
     end
  else
   failed:= True;

 if (tempstate.V > 0) and not failed then
  if vvod[High(vvod)].gamma >= 0 then
   vvod[High(vvod)].gamma := DegToRad(kren)
  else
 if (tempstate.V > 0) and not failed then 
   vvod[High(vvod)].gamma := -DegToRad(kren);

 //������� c ���������� ������
   SetLength(constgammaUchastok,0);
   tempomega.x := 0;
   dpsiVvod := tempstate.psi-initialstate.psi;

  if (tempstate.V > 0) and not failed then
    while not (Abs(tempstate.psi-initialstate.psi) >= Abs((DegToRad(deltaPsi))-Abs(dpsiVvod))) do
      g_Etape(constgammaUchastok,tempstate, helicopter, tempny,tempa, tempomega)
  else
   failed:= True;

 //�����  
   SetLength(vyvod,0);
   prevgamma :=0;

 if (tempstate.V > 0) and not failed then
  while not (tempstate.gamma*prevgamma < 0) do
   begin
    tempny := 1/Cos(tempstate.gamma);
    SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny,Left);
    tempomega.x := -tempomega.x;
    prevgamma := tempstate.gamma;
    g_Etape(vyvod,tempstate, helicopter, tempny,tempa, tempomega); 
   end
  else
   failed:= True;

  if failed then ShowMessage('������� �������� �� ����!');

  SetLength(Result,0);
  AppendManevr(Result,vvod,helicopter);
  AppendManevr(Result,constgammaUchastok,helicopter);
  AppendManevr(Result,vyvod,helicopter);

  SetLength(vvod,0);
  SetLength(constgammaUchastok,0);
  SetLength(vyvod,0);
end;

function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TFlightData;
begin
  if deltaPsi < 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, False);
  if deltaPsi > 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, True);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TFlightData;
var
  localTime,tempny,a : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

 procedure SetAcceleration(var a : Real; tempstate: TStateVector; ny : Real);
  const
   timeBeforeFullNX = 10{������}; //�� ���������� ����������� ��������� nx ������ �����
begin
      a := g*nx(helicopter,tempny,icG, icT,tempstate.y,mps*tempstate.V);

      if localTime < timeBeforeFullNX then
       a:= (1/timeBeforeFullNX)*localTime*a;
end;

begin
    //��������������
 failed := False;

 tempstate := initialstate;
 tempny :=1;
 localTime :=0;
 tempomega.x:=0;
 tempomega.y:=0;
 tempomega.z:=0;
 SetLength(Result,0);

 if (tempstate.V > 0) and not failed then
   while not (mps*tempstate.V >=Vfinal) do
    begin
     begin
      SetAcceleration(a,tempstate, tempny);
      g_Etape(Result,tempstate, helicopter, tempny,a, tempomega);
      localTime := localTime + dt;
     end;
      tempstate.V := Vfinal/mps;
    end
 else
  failed := True;

  if failed then ShowMessage('������� �������� �� ����!');

  //ShowMessage(FloatToStr(localTime));
end;

function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TFlightData;
begin
  if initialstate.V*mps < 0.95*helicopter.Vmax then
   Result := HorizRazgon(helicopter, initialstate, icG, icT,Vfinal)
  else
   begin
     SetLength(Result,0);
     ShowMessage('��������� �������� ��� ������� ��������� ' + FloatToStr(Round(initialstate.V*mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
   end;

end;

function Vvector(Vmodule, psi, theta : Real) : TVector;
var
  absV : Real;
begin
  absV := Abs(Vmodule);

  with Result do
   begin
     x:= absV*Cos(theta)*Cos(psi);
     y:= absV*Sin(theta);
     z:= absV*Cos(theta)*Sin(psi)
   end;
end;

function Vvector3D(Vmodule, psi, theta : Real) : TVector3D;
var
  absV : Real;
begin
  absV := Abs(Vmodule);

  with Result do
   begin
     x:= absV*Cos(theta)*Cos(psi);
     y:= absV*Sin(theta);
     z:= absV*Cos(theta)*Sin(psi)
   end;
end;

procedure ExtendArray(var myarray: TFlightData);overload;
begin
 SetLength(myarray,Length(myarray)+1);
end;
procedure ExtendArray(var myarray: TFlightData; count: Integer);overload;
begin
 SetLength(myarray,Length(myarray)+count);
end;

procedure MyIntegrate(var tempstate : TStateVector; dt,a : Real;omega : TVector3D);
var
angles, dangles, intermediateangles,dr : TVector3D;
dV : Real;
begin
 angles.x := tempstate.gamma;
 angles.y := tempstate.psi;
 angles.z := tempstate.theta;

 dangles := Scale(omega,dt);
 intermediateangles := Add(angles,Scale(dangles,0.5));

 dV := a*dt;

 dr := Scale(Vvector3D((tempstate.V+dV/2),intermediateangles.y,intermediateangles.z),dt);

 angles := Add(angles,dangles);

 tempstate.gamma := angles.x;
 tempstate.psi := angles.y;
 tempstate.theta := angles.z;
 tempstate.V := tempstate.V + dV;
 tempstate.t := tempstate.t + dt;
 tempstate.x := tempstate.x + dr.x;
 tempstate.y := tempstate.y + dr.y;
 tempstate.z := tempstate.z + dr.z;
end;

end.

unit Manoeuvres;

interface

uses FlightData,Math,HelicoptersDatabase,Kernel,Dialogs, JmGeometry,SysUtils, GlobalConstants;

type TVector = record
x,y,z : Real
end;


procedure AppendManevr(var GlobalFlightData: TFlightData; Manevr : TManevrData; helicopter : THelicopter);
function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TManevrData;
function Gorka (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
function Pikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;

function tVypoln(Manevr : TManevrData) : Extended;
function Vfinal(Manevr : TManevrData) : Extended;
function deltaX(Manevr : TManevrData) : Extended;
function deltaY(Manevr : TManevrData) : Extended;
function deltaZ(Manevr : TManevrData) : Extended;

const
 dt = 0.1; //��� �� �������, �

implementation

procedure ExtendArray(var myarray: TManevrData);overload;
begin
 SetLength(myarray,Length(myarray)+1);
end;

procedure ExtendArray(var myarray: TManevrData; count: Integer);overload;
begin
 SetLength(myarray,Length(myarray)+count);
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

procedure AppendManevr(var GlobalFlightData: TFlightData; Manevr : TManevrData; helicopter : THelicopter);overload;
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
  ShowMessage('���������� ����������� ������������ �������� (' + FloatToStr(0.95*helicopter.Vmax)+ ') ��/�')
end;

procedure AppendManevr(var MainManevrData: TManevrData; Manevr : TManevrData; helicopter : THelicopter);overload;
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
  ShowMessage('���������� ����������� ������������ �������� (' + FloatToStr(0.95*helicopter.Vmax)+ ') ��/�')
end;

function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TManevrData;
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

procedure g_Etape(var TempFlightData : TManevrData; var tempstate : TStateVector; helicopter : THelicopter; ny,a : Real; omega : TVector3D);
begin
  ExtendArray(TempFlightData);

  MyIntegrate(tempstate,dt,a,omega);

  TempFlightData[High(TempFlightData)] := tempstate;
end;

function iGorkaPikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real; Pikirovanie : Boolean) : TManevrData;
var
 vvod,nakl,vyvod : TManevrData;
 nyslope,tempa,dnxa : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny,nx,dnxa,nxOtXvr : Real);

begin
     omega.x:=0;
     omega.y:=0;
     if tempstate.V>=0 then
      omega.z := (ny-Cos(tempstate.theta))*g_g/tempstate.V   //rad
     else
      begin
        omega.z :=0;
        ShowMessage('procedure SetOmegaAndAcceleration: V <= 0!');
        Halt;
      end;

      a := g_g*(nx - dnxa - Sin(tempstate.theta) - nxOtXvr);
end;

 procedure Etape(var TempFlightData : TManevrData; ny : Real);
   begin
    ExtendArray(TempFlightData);

    SetOmegaAndAcceleration(tempomega, tempa, tempstate,ny,nx(helicopter, ny, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�

    MyIntegrate(tempstate,dt,tempa,tempomega);

    TempFlightData[High(TempFlightData)] := tempstate;
   end;


begin
   //��������������
   tempstate := initialstate;

   dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //��������� �������� � ��/�

   failed := False;

 //����
   SetLength(vvod,0);

  while (not ((RadToDeg(tempstate.theta)>=thetaSlope) xor Pikirovanie)) and (not failed) do
    if (tempstate.V > 0) then
     begin
      SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyvvoda,nx(helicopter, nyvvoda, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�
      g_Etape(vvod,tempstate, helicopter, nyvvoda,tempa, tempomega);
     end
    else
    failed := True;

  vvod[High(vvod)].theta := DegToRad(thetaSlope);

 //��������� �������
   SetLength(nakl,0);

   nyslope := Cos(tempstate.theta);

  while (not ((g_mps*tempstate.V <= Vvyvoda) xor Pikirovanie)) and (not failed) do
   if (tempstate.V > 0) then
    Etape(nakl,nyslope)
   else
  failed := True;

 //�����  
   SetLength(vyvod,0);

 while (not ((RadToDeg(tempstate.theta)<=0) xor Pikirovanie)) and (not failed) do
  if (tempstate.V > 0) then
    Etape(vyvod,nyvyvoda)
  else
  failed := True;

  vyvod[High(vyvod)].theta := 0.;

  if failed then ShowMessage('��� ������ ���������������� �������� ������ ����������. ������� �������� �� ����!');

 //�������
  SetLength(Result,0);
  AppendManevr(Result,vvod,helicopter);
  AppendManevr(Result,nakl,helicopter);
  AppendManevr(Result,vyvod,helicopter);

 //������� 
  SetLength(vvod,0);
  SetLength(nakl,0);
  SetLength(vyvod,0);

  ShowMessage(FloatToStr(deltaY(Result)));
end;

procedure VErrorMessage(temp,min,max: Real; Pikirovanie : boolean);
var
  manevr : string;
begin
  if Pikirovanie then
   manevr := '�����������'
  else
   manevr := '�����';
  ShowMessage('�������� ����� � '+manevr +' ��������� ' + FloatToStr(Round(temp)) + ' ��/�. ��� �������� ������ ������ � ��������� �� '+FloatToStr(min) + ' �� '+FloatToStr(max) +' ��/�');
end;


function GorkaPikirovanieInputheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax : Real; Pikirovanie : Boolean) : TManevrData;
var
  Vtemp : Real;
begin
  Vtemp := initialstate.V*g_mps;

  if (Vtemp>=Vmin) and (Vtemp<=Vmax) then
   Result := iGorkaPikirovanie(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Pikirovanie)
  else
   begin
     SetLength(Result,0);
     VErrorMessage(Vtemp,Vmin,Vmax,Pikirovanie)
   end;
end;

function Gorka (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
const
  Vmin = 150;
var
  Vmax : Real;
begin
  Vmax := 0.9*helicopter.Vmax;

  Result := GorkaPikirovanieInputheck(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax,False)
end;


function Pikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
const
  Vmin = 50;
  Vmax = 150;
begin
  Result := GorkaPikirovanieInputheck(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax,True)
end;

function iVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real; Left: Boolean) : TManevrData;
var
  tempa, tempny, dpsiVvod, prevgamma: Real;
  vvod, constgammaUchastok,vyvod : TManevrData;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed:Boolean;
procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny : Real; Left: Boolean);

begin


     omega.x:=DegToRad(10);  //�������� ����� � ���� (������ �� �����), �������� � �������
     if Left then omega.x := -omega.x;

     omega.z:=0;
     if tempstate.V>=0 then
      begin
       omega.y := Sqrt(Sqr(ny)-1)*g_g/tempstate.V;   //rad

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
 failed := False;

   //��������������
 tempstate := initialstate;
 tempny :=1;

 //����
   SetLength(vvod,0);
 if not failed then
  if (tempstate.V > 0)  then
   while not (Abs(RadToDeg(tempstate.gamma)) >=Abs(kren)) do
     begin
      tempny := 1/Cos(tempstate.gamma);
      SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny, Left);
      g_Etape(vvod,tempstate, helicopter, tempny,tempa, tempomega);
     end
  else
   failed:= True;

if not failed then
 if (tempstate.V > 0) then
  if vvod[High(vvod)].gamma >= 0 then
   vvod[High(vvod)].gamma := DegToRad(kren)
  else
 if (tempstate.V > 0) and not failed then 
   vvod[High(vvod)].gamma := -DegToRad(kren);

 //������� c ���������� ������
   SetLength(constgammaUchastok,0);
   tempomega.x := 0;
   dpsiVvod := tempstate.psi-initialstate.psi;

 if not failed then
  if (tempstate.V > 0) then
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

function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, False);
  if deltaPsi > 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, True);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
var
  localTime,tempny,a : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

 procedure SetAcceleration(var a : Real; tempstate: TStateVector; ny : Real);
  const
   timeBeforeFullNX = 10{������}; //�� ���������� ����������� ��������� nx ������ �����
begin
      a := g_g*nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V);

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



    while (not (g_mps*tempstate.V >=Vfinal)) and (not failed) do
      if (tempstate.V > 0) then
        begin
         begin
          SetAcceleration(a,tempstate, tempny);
          g_Etape(Result,tempstate, helicopter, tempny,a, tempomega);
          localTime := localTime + dt;
         end;
        end
      else
        failed := True;

      tempstate.V := Vfinal/g_mps;

  if failed then ShowMessage('������� �������� �� ����!');

  //ShowMessage(FloatToStr(localTime));
end;

function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
begin
  if initialstate.V*g_mps < 0.95*helicopter.Vmax then
   Result := HorizRazgon(helicopter, initialstate, icG, icT,Vfinal)
  else
   begin
     SetLength(Result,0);
     ShowMessage('��������� �������� ��� ������� ��������� ' + FloatToStr(Round(initialstate.V*g_mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
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

function tVypoln(Manevr : TManevrData) : Extended;
begin
  Result := Manevr[High(Manevr)].t - Manevr[Low(Manevr)].t
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

end.




unit Manoeuvres;

interface

uses FlightData,Math,HelicoptersDatabase,Kernel,Dialogs, JmGeometry,SysUtils, GlobalConstants;

type TVector = record
x,y,z : Real
end;

type TManevrPropsPerebornye = record
Vmax, Vmin, S, xmin, xmax, ymin, ymax, zmin, zmax : Real
end;



function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TManevrData;
function Gorka (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
function Pikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real) : TManevrData;
function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
function Spiral(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}, Vy{m/s}: Real) : TManevrData;
function HorizRazgonTormozhenie(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
function RazgonSnaborom(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}, Vy{m/s}: Real) : TManevrData;
function VertVzlet(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltayInterface, Vdesired : Real) : TManevrData;
function VertPosadka(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltayInterface, Vdesired : Real) : TManevrData;
function Visenie(initialstate : TStateVector; duration : Real) : TManevrData;

function tVypoln(Manevr : TManevrData) : Extended;
function Vfinal(Manevr : TManevrData) : Extended;
function deltaX(Manevr : TManevrData) : Extended;
function deltaY(Manevr : TManevrData) : Extended;
function deltaZ(Manevr : TManevrData) : Extended;
function ManevrPropsPerebornye(Manevr : TManevrData) : TManevrPropsPerebornye;
function VertVzletPosadkaVmax (helicopter : THelicopter;icG, icT,icH0, deltay : Real) : Real;



const
 dt = 0.1; //��� �� �������, �
 deltatSlope = 1.; //����������������� ���������� ��������� ��� ������/�������

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





function HorizFlight (initialstate : TStateVector; desiredDistance : Real) : TManevrData;
var
  distance, tempt,tempx,tempz,dx,dz : Real;
begin
   SetLength(Result,0);

  if initialstate.V>0 then
    begin
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
    end
  else
   ShowMessage('function HorizFlight: V <= 0!');
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
  AppendManevrData(Result,vvod,helicopter);
  AppendManevrData(Result,nakl,helicopter);
  AppendManevrData(Result,vyvod,helicopter);

 //������� 
  SetLength(vvod,0);
  SetLength(nakl,0);
  SetLength(vyvod,0);

  //ShowMessage(FloatToStr(ManevrPropsPerebornye(Result).zmax));
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

function iVirageSpiral(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������},Vy {m/s}: Real; Left: Boolean) : TManevrData;
var
  tempa, tempny, dpsiVvod, prevgamma, Vytemp : Real;
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
 Vytemp := 0;

 //����
   SetLength(vvod,0);
 if not failed then
  if (tempstate.V > 0)  then
   while not (Abs(RadToDeg(tempstate.gamma)) >=Abs(kren)) do
     begin
      tempny := 1/Cos(tempstate.gamma);
      SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny, Left);
      g_Etape(vvod,tempstate, helicopter, tempny,tempa, tempomega);

       //for spiral
      Vytemp := Vy/Abs(kren)*Abs(RadToDeg(tempstate.gamma));
      vvod[High(vvod)].y := vvod[High(vvod)].y + Vytemp/2*dt;
      tempstate.y := vvod[High(vvod)].y;
     end
  else
   failed:= True;

 //  ShowMessage('iVirage: y = ' + FloatToStr(vvod[High(vvod)].y));

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
     begin
      g_Etape(constgammaUchastok,tempstate, helicopter, tempny,tempa, tempomega);

      constgammaUchastok[High(constgammaUchastok)].y := constgammaUchastok[High(constgammaUchastok)].y + Vytemp/2*dt;
      tempstate.y := constgammaUchastok[High(constgammaUchastok)].y;
     end
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

      //for spiral
      Vytemp := Vy/Abs(kren)*Abs(RadToDeg(tempstate.gamma));
      vyvod[High(vyvod)].y := vyvod[High(vyvod)].y + Vytemp/2*dt;
      tempstate.y := vyvod[High(vyvod)].y;
   end
 else
   failed:= True;

  //ShowMessage('iVirage: Vy = ' + FloatToStr(Vytemp));

  if failed then ShowMessage('������� �������� �� ����!');

  SetLength(Result,0);
  AppendManevrData(Result,vvod,helicopter);
  AppendManevrData(Result,constgammaUchastok,helicopter);
  AppendManevrData(Result,vyvod,helicopter);

  SetLength(vvod,0);
  SetLength(constgammaUchastok,0);
  SetLength(vyvod,0);
end;

function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, 0, False);
  if deltaPsi > 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, 0, True);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function Spiral(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}, Vy{m/s}: Real) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, Vy, False);
  if deltaPsi > 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, Vy, True);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function iRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{km/h}, VyDesired{m/s} : Real) : TManevrData;
var
  localTime,tempny,a, Vytemp, tempy : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

function Razgon() : Boolean;
begin
  Result := g_mps*initialstate.V < Vfinal;
end;

 procedure SetAccelerationTormozh(var a : Real; tempstate: TStateVector; ny, Vy, V : Real);
  const
 knx = 0.013;
 var
   linearnx, realnx, VfinalTrick : Real;

begin

      linearnx := -knx*localTime;

      if Vfinal <=2 then
       VfinalTrick := Vfinal
      else
       VfinalTrick := Vfinal-2;

      realnx := nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy)-nx(helicopter,tempny,icG, icT,tempstate.y, VfinalTrick(* ��������� �������� ��������� ��-�� ����� �� ������ ��������� � ����� ������� *), Vy);

      if linearnx < realnx then
       a := g_g*realnx
      else
       a := g_g*linearnx

end;

 procedure SetAccelerationRazgon(var a : Real; tempstate: TStateVector; ny, Vy : Real);
  const
 knx = 0.013;

 var
   linearnx, realnx : Real;

begin

      linearnx := knx*localTime;
      realnx := nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy);

      if linearnx > realnx then
       a := g_g*realnx
      else
       a := g_g*linearnx

end;

begin
    //��������������
 failed := False;

 if initialstate.V*g_mps <> Vfinal then
   begin
     tempstate := initialstate;
     tempny :=1;
     localTime :=0;
     tempomega.x:=0;
     tempomega.y:=0;
     tempomega.z:=0;
     SetLength(Result,0);
     tempy := initialstate.y;


    if initialstate.V*g_mps < 0.95*helicopter.Vmax then
     begin
      //while (not (g_mps*tempstate.V >=Vfinal)) and (not failed) do
      while ((Razgon and (g_mps*tempstate.V <=Vfinal)) or ((not Razgon) and (g_mps*tempstate.V >=Vfinal))) and (not failed) do
        if (tempstate.V >= 0) then
          begin
           begin
            if Length(Result) = 0 then
             Vytemp := VyRasp(helicopter, icG, icT, tempy, initialstate.V*g_mps)
            else
             Vytemp := VyRasp(helicopter, icG, icT, Result[High(Result)].y, Result[High(Result)].V*g_mps);

            if (Vytemp > VyDesired) or (Abs(VyDesired) < 0.001){in case of horizontal flight} then
              Vytemp := VyDesired;

            if Razgon then
             SetAccelerationRazgon(a,tempstate, tempny, Vytemp)
            else
             SetAccelerationTormozh(a,tempstate, tempny, Vytemp, initialstate.V);

            g_Etape(Result,tempstate, helicopter, tempny,a, tempomega);

                       //climb
            tempy := tempy +  + Vytemp*dt;
            Result[High(Result)].y := tempy;

            Result[High(Result)].theta := -ArcTan(a/g_g); //pitch according to nx_temp

            localTime := localTime + dt;
           end;
          end
        else
          failed := True;

       if not failed then
        Result[High(Result)].V := Vfinal/g_mps;

       if failed then ShowMessage('������� �������� �� ����!');
     end

    else
      ShowMessage('��������� �������� ��������� ' + FloatToStr(Round(initialstate.V*g_mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
   end
 else
  ShowMessage('�������� � ��������� �������� ��� ������� (����������) �� ����� ���� ����� ����� �����!')
end;

function HorizRazgonTormozhenie(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
begin
 Result:= iRazgon(helicopter, initialstate, icG, icT,Vfinal, 0);
end;

function RazgonSnaborom(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}, Vy{m/s}: Real) : TManevrData;
begin
 Result:= iRazgon(helicopter, initialstate, icG, icT,Vfinal, Vy);
end;

//function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
{begin
  if initialstate.V*g_mps < 0.95*helicopter.Vmax then
   Result := HorizRazgon(helicopter, initialstate, icG, icT,Vfinal)
  else
   begin
     SetLength(Result,0);
     ShowMessage('��������� �������� ��� ������� ��������� ' + FloatToStr(Round(initialstate.V*g_mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
   end; 
end;
 }
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
var
 t0 : Real;
begin
  t0 := Manevr[Low(Manevr)].t;

  Result := Manevr[High(Manevr)].t - Manevr[Low(Manevr)].t;

  if t0 > dt/2 then
   Result := Result + dt;

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

function VertVzletPosadkaVmax (helicopter : THelicopter;icG, icT,icH0, deltay : Real) : Real;
begin
  Result := Min((ny(helicopter, icG, icT, icH0, 0)-1)*g_g*deltatSlope, (ny(helicopter, icG, icT, icH0 + deltay, 0)-1)*g_g*deltatSlope)
end;

function VertVzletPosadkaDeltaT (deltay, Vmax : Real) : Real;
//constant speed duration
var
  relation : Real;
begin
 Result := 0;

 if deltay <> 0 then
   if Vmax > 0 then
    begin
      relation := Abs(deltay/Vmax);

       if relation > deltatSlope then
        Result := relation - deltatSlope
       else
        begin
          ShowMessage('�������� ������� ������ � �� ����� ���������� ����� ����� �����������!');
        end  
    end
   else
      ShowMessage('�������� ������ ���� ���������������!')
 else
   ShowMessage('����������� �� ������ ���� ����� ����!');

end;

function VertVzletPosadkaAcceleration(deltay, Vmax : Real) : Real;
begin
  Result := 0;

  if Vmax > 0 then
   begin
    Result := Vmax/deltatSlope;

    if deltay <0 then   //landing
     Result := -Result;
   end
  else
    ShowMessage('�������� ������ ���� ���������������!');
end;

function VertVzletPosadkaV (deltay, Vmax, t : Real) : Real;
var
  deltat, a : Real;
begin
  Result := 0;

  deltat := VertVzletPosadkaDeltaT(deltay, Vmax);

  if deltat > 0 then
   begin
      a := VertVzletPosadkaAcceleration(deltay, Vmax);

      if deltay < 0 then
       Vmax := -Vmax; //landing

      if t <= (2*deltatSlope + deltat) + dt then
       begin
        if t <= deltatSlope then //first slope
         Result := a*t
        else
         if (t>deltatSlope) and (t < deltatSlope+deltat) then //plato
          Result := Vmax
         else //second slope
          Result := -a*(t-deltatSlope-deltat)+Vmax;
       end
      else
       ShowMessage('�������� ����� ��������� ����� ���������� �������')
   end


end;

function VertVzletPosadkay (deltay, Vmax, t : Real) : Real;
var
  deltat, a : Real;
begin
  Result := 0;

  deltat := VertVzletPosadkaDeltaT(deltay, Vmax);

  if deltat > 0 then
   begin
    a := VertVzletPosadkaAcceleration(deltay, Vmax);

    if deltay < 0 then
       Vmax := -Vmax; //landing

    if t <= (2*deltatSlope + deltat) + dt then
     begin
      if t <= deltatSlope then //first parabola
       Result := (0.5*a)*Sqr(t)
      else
       if (t>deltatSlope) and (t < deltatSlope+deltat) then //slope
        Result := Vmax*(t - deltatSlope/2)
       else //second parabola
        Result := (0.5*a)*(Sqr(t)-Sqr(2*deltatSlope+deltat)) + (Vmax-a*(deltatSlope+deltat))*(t - 2*deltatSlope - deltat) + deltay;
     end
    else
     ShowMessage('�������� ����� ��������� ����� ���������� �������');
   end;
end;

function iVertVzletPosadka(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltay, Vdesired : Real) : TManevrData;
var
  deltat, localt : Real;

begin
 SetLength(Result,0);

 if Vdesired <= VertVzletPosadkaVmax (helicopter,icG, icT,initialstate.y,deltay) then
   if deltay <> 0 then
    if Abs(initialstate. V) < 0.001 then
      begin
        deltat := VertVzletPosadkaDeltaT(deltay, Vdesired);

        if deltat > 0 then
         begin
          localt := -dt;

          while localt < deltat + 2*deltatSlope do
           begin
            ExtendArray(Result);

            Result[High(Result)] := initialstate;

            localt := localt + dt;

            with Result[High(Result)] do
             begin
              y := initialstate.y + VertVzletPosadkay (deltay, Vdesired, localt);
              V := VertVzletPosadkaV (deltay, Vdesired, localt);
              t := localt
             end;

           end;

          Result[High(Result)].V := 0;
         end
        else
         ShowMessage('function iVertVzletPosadka: deltat error ')
      end
    else
     ShowMessage('��������� �������� ������� ������ ���� ����� ����!')
   else
    ShowMessage('����������� �� ������ ���� ����� ����!')
 else
  ShowMessage('�������� ������������ �������� �� ����� ���� ����������')
end;

function VertVzlet(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltayInterface, Vdesired : Real) : TManevrData;
begin
  Result := iVertVzletPosadka(helicopter, initialstate, icG, icT, deltayInterface, Vdesired);
end;

function VertPosadka(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltayInterface, Vdesired : Real) : TManevrData;
begin
  Result := iVertVzletPosadka(helicopter, initialstate, icG, icT, -deltayInterface, Vdesired);
end;

function MyOscillation (A, Omega, phi, duration, t : Real) : Real;
begin
  if t<=duration/2 then
    Result := (2/duration)* t * A * Cos(Omega * t + phi)
  else
    Result := ((-2/duration)* t + 2) * A * Cos(Omega * t + phi)
end;
       
function Visenie(initialstate : TStateVector; duration : Real) : TManevrData;
var
localtime : Real;
const
  ampli = 0.0349; // 2 degrees
  omega = 0.04;
begin
   SetLength(Result,0);
   localtime := 0;

  if duration>0 then
    begin
        while localtime < duration-dt/2 do
         begin
          ExtendArray(Result);

          with Result[High(Result)] do
           begin
            x := initialstate.x;
            y := initialstate.y;
            z := initialstate.z;
            V := 0;
            psi := initialstate.psi;
            ny := initialstate.ny;

            theta := initialstate.theta + MyOscillation (ampli, omega, Pi/2, duration, localtime);
            gamma := initialstate.gamma + MyOscillation (ampli, omega, 0, duration, localtime);
            t := initialstate.t + localtime + dt;

            localtime := localtime + dt;

           end;
         end;

          with Result[High(Result)] do
             begin
              theta := 0;
              gamma := 0;
             end;
    end
  else
   ShowMessage('����������������� ������� ������ ���� ������ ����!');
end;

end.




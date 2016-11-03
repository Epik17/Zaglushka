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
function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{градусы}: Real) : TManevrData;
function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}: Real) : TManevrData;
function RazgonSnaborom(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}, Vy{m/s}: Real) : TManevrData;
function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}: Real) : TManevrData;

function tVypoln(Manevr : TManevrData) : Extended;
function Vfinal(Manevr : TManevrData) : Extended;
function deltaX(Manevr : TManevrData) : Extended;
function deltaY(Manevr : TManevrData) : Extended;
function deltaZ(Manevr : TManevrData) : Extended;
function ManevrPropsPerebornye(Manevr : TManevrData) : TManevrPropsPerebornye;

const
 dt = 0.1; //шаг по времени, с

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

    SetOmegaAndAcceleration(tempomega, tempa, tempstate,ny,nx(helicopter, ny, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //переводим скорость в км/ч

    MyIntegrate(tempstate,dt,tempa,tempomega);

    TempFlightData[High(TempFlightData)] := tempstate;
   end;


begin
   //инициализируем
   tempstate := initialstate;

   dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //переводим скорость в км/ч

   failed := False;

 //ввод
   SetLength(vvod,0);

  while (not ((RadToDeg(tempstate.theta)>=thetaSlope) xor Pikirovanie)) and (not failed) do
    if (tempstate.V > 0) then
     begin
      SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyvvoda,nx(helicopter, nyvvoda, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //переводим скорость в км/ч
      g_Etape(vvod,tempstate, helicopter, nyvvoda,tempa, tempomega);
     end
    else
    failed := True;

  vvod[High(vvod)].theta := DegToRad(thetaSlope);

 //наклонный участок
   SetLength(nakl,0);

   nyslope := Cos(tempstate.theta);

  while (not ((g_mps*tempstate.V <= Vvyvoda) xor Pikirovanie)) and (not failed) do
   if (tempstate.V > 0) then
    Etape(nakl,nyslope)
   else
  failed := True;

 //вывод  
   SetLength(vyvod,0);

 while (not ((RadToDeg(tempstate.theta)<=0) xor Pikirovanie)) and (not failed) do
  if (tempstate.V > 0) then
    Etape(vyvod,nyvyvoda)
  else
  failed := True;

  vyvod[High(vyvod)].theta := 0.;

  if failed then ShowMessage('При данных эксплуатационных условиях разгон невозможен. Падение скорости до нуля!');

 //стыкуем
  SetLength(Result,0);
  AppendManevrData(Result,vvod,helicopter);
  AppendManevrData(Result,nakl,helicopter);
  AppendManevrData(Result,vyvod,helicopter);

 //очищаем 
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
   manevr := 'пикирование'
  else
   manevr := 'горку';
  ShowMessage('Скорость ввода в '+manevr +' составила ' + FloatToStr(Round(temp)) + ' км/ч. Эта скорость должна лежать в диапазоне от '+FloatToStr(min) + ' до '+FloatToStr(max) +' км/ч');
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

function iVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{градусы}: Real; Left: Boolean) : TManevrData;
var
  tempa, tempny, dpsiVvod, prevgamma: Real;
  vvod, constgammaUchastok,vyvod : TManevrData;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed:Boolean;
procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny : Real; Left: Boolean);

begin


     omega.x:=DegToRad(10);  //скорость ввода в крен (вывода из крена), градусов в секунду
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

   //инициализируем
 tempstate := initialstate;
 tempny :=1;

 //ввод
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

 //участок c постоянным креном
   SetLength(constgammaUchastok,0);
   tempomega.x := 0;
   dpsiVvod := tempstate.psi-initialstate.psi;

 if not failed then
  if (tempstate.V > 0) then
    while not (Abs(tempstate.psi-initialstate.psi) >= Abs((DegToRad(deltaPsi))-Abs(dpsiVvod))) do
      g_Etape(constgammaUchastok,tempstate, helicopter, tempny,tempa, tempomega)
  else
   failed:= True;

 //вывод  
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

  if failed then ShowMessage('Падение скорости до нуля!');

  SetLength(Result,0);
  AppendManevrData(Result,vvod,helicopter);
  AppendManevrData(Result,constgammaUchastok,helicopter);
  AppendManevrData(Result,vyvod,helicopter);

  SetLength(vvod,0);
  SetLength(constgammaUchastok,0);
  SetLength(vyvod,0);
end;

function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{градусы}: Real) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, False);
  if deltaPsi > 0 then
    Result:=iVirage(helicopter, initialstate, icG, icT,kren, deltaPsi, True);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function iRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{km/h}, VyDesired{m/s} : Real) : TManevrData;
var
  localTime,tempny,a, Vytemp, tempy : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

 procedure SetAcceleration(var a : Real; tempstate: TStateVector; ny, Vy : Real);
  const
   timeBeforeFullNX = 10{секунд}; //на достижение максимально возможной nx уходит время
begin
      a := g_g*nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy);

      if localTime < timeBeforeFullNX then
       a:= (1/timeBeforeFullNX)*localTime*a;
end;

begin
    //инициализируем
 failed := False;

 tempstate := initialstate;
 tempny :=1;
 localTime :=0;
 tempomega.x:=0;
 tempomega.y:=0;
 tempomega.z:=0;
 SetLength(Result,0);
 tempy := initialstate.y;



    while (not (g_mps*tempstate.V >=Vfinal)) and (not failed) do
      if (tempstate.V > 0) then
        begin
         begin
          if Length(Result) = 0 then
           Vytemp := VyRasp(helicopter, icG, icT, tempy, initialstate.V*g_mps)
          else
           Vytemp := VyRasp(helicopter, icG, icT, Result[High(Result)].y, Result[High(Result)].V*g_mps);

          if (Vytemp > VyDesired) or (Abs(VyDesired) < 0.001){in case of horizontal flight} then
            Vytemp := VyDesired;

          SetAcceleration(a,tempstate, tempny, Vytemp);
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

      Result[High(Result)].V := Vfinal/g_mps;

  if failed then ShowMessage('Падение скорости до нуля!');

end;

function HorizRazgon(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}: Real) : TManevrData;
begin
 Result:= iRazgon(helicopter, initialstate, icG, icT,Vfinal, 0);
end;

function RazgonSnaborom(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}, Vy{m/s}: Real) : TManevrData;
begin
 Result:= iRazgon(helicopter, initialstate, icG, icT,Vfinal, Vy);
end;

function HorizRazgonInputCheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{км/ч}: Real) : TManevrData;
begin
  if initialstate.V*g_mps < 0.95*helicopter.Vmax then
   Result := HorizRazgon(helicopter, initialstate, icG, icT,Vfinal)
  else
   begin
     SetLength(Result,0);
     ShowMessage('Начальная скорость при разгоне составила ' + FloatToStr(Round(initialstate.V*g_mps)) + ' км/ч. Эта скорость не может превышать  '+FloatToStr(0.95*helicopter.Vmax)+ ' км/ч');
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

end.




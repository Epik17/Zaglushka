unit Manoeuvres;

interface

uses FlightData,Math,HelicoptersDatabase,Kernel,Dialogs, JmGeometry,SysUtils, GlobalConstants;


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
function ForcedVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
function Naklon (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda : Real) : TManevrData;
function PetlyaNesterova (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nySredn: Real) : TManevrData;
function iBoevoiRazvorot(helicopter : THelicopter; initialstate : TStateVector; icG, icT, kren, tangage, dkurs, greaternyCoeff, smallernyCoeff : Real) : TManevrData;

function VertVzletPosadkaVmax (helicopter : THelicopter;icG, icT,icH0, deltay : Real) : Real;

implementation

type TVector = record
x,y,z : Real
end;  

const
 dt = 0.1; //��� �� �������, �
 deltatSlope = 1.; //����������������� ���������� ��������� ��� ������/�������
 defaultfailureMessage = '���������� ������';

var
 failureMessage : string=defaultfailureMessage;

procedure AppendFailureMessage(newmessage : string);
var
  separator : string;
begin
 separator := '; ';

 if failureMessage = defaultfailureMessage then
  separator := ': ';

  failureMessage := failureMessage + separator + newmessage
end;

procedure ClearFailureMessages;
begin
 failureMessage := defaultfailureMessage
end;

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
            thetaVisual := initialstate.thetaVisual;
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
   ShowMessage('�������� ��������������� ������ ������ ���� ������ ����');
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
 tempstate.thetaVisual := tempstate.theta + DegToRad(g_thetaVisualdefault);
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

procedure HmaxCheck (tempstate: TStateVector; var failed : Boolean);
begin
  if tempstate.y > 2000 then
  begin
    failed := True;
    AppendFailureMessage('��������� ������ 2000 �');
  end;
end;

procedure SetOmegaAndAccelerationVvodVGorku(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny,nx,dnxa,nxOtXvr : Real);

begin
     omega.x:=0;
     omega.y:=0;
     if tempstate.V>=0 then
      omega.z := (ny-Cos(tempstate.theta))*g_g/tempstate.V   //rad
     else
      begin
        omega.z :=0;
        ShowMessage('������� �������� �� ����!');
        Halt;
      end;

      a := g_g*(nx - dnxa - Sin(tempstate.theta) - nxOtXvr);
end;

function iGorkaPikirovanie (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda : Real; Pikirovanie : Boolean) : TManevrData;
var
 vvod,nakl,vyvod : TManevrData;
 nyslope,tempa,dnxa : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

 procedure Etape(var TempFlightData : TManevrData; ny : Real);
   begin
    ExtendArray(TempFlightData);

    SetOmegaAndAccelerationVvodVGorku(tempomega, tempa, tempstate,ny,nx(helicopter, ny, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�

    MyIntegrate(tempstate,dt,tempa,tempomega);

    TempFlightData[High(TempFlightData)] := tempstate;
   end;


begin
     //��������������

     SetLength(Result,0);

     failed := False;
     ClearFailureMessages;

// if not ((nyvvoda > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) or (nyvyvoda > ny(helicopter, icG, icT,initialstate.y-200,Vvyvoda))) then
if not (nyvvoda > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) then
 if not (nyvyvoda > ny(helicopter, icG, icT,initialstate.y-200,Vvyvoda)) then
  begin
     dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //��������� �������� � ��/�

     tempstate := initialstate;

   //����
     SetLength(vvod,0);

    while (not ((RadToDeg(tempstate.theta)>=thetaSlope) xor Pikirovanie)) and (not failed) do
      if (tempstate.V > 0) then
       begin
        SetOmegaAndAccelerationVvodVGorku(tempomega, tempa, tempstate,nyvvoda,nx(helicopter, nyvvoda, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�
        g_Etape(vvod,tempstate, helicopter, nyvvoda,tempa, tempomega);
        HmaxCheck(tempstate, failed);
       end
      else
      failed := True;

    vvod[High(vvod)].theta := DegToRad(thetaSlope);


   //��������� �������
     SetLength(nakl,0);

     nyslope := Cos(tempstate.theta);

    while (not ((g_mps*tempstate.V <= Vvyvoda) xor Pikirovanie)) and (not failed) do
     if (tempstate.V > 0) then
      begin
       Etape(nakl,nyslope);
       HmaxCheck(tempstate, failed);
      end
     else
    failed := True;

   //�����  
     SetLength(vyvod,0);

   while (not ((RadToDeg(tempstate.theta)<=0) xor Pikirovanie)) and (not failed) do
    if (tempstate.V > 0) then
     begin
      Etape(vyvod,nyvyvoda);
      HmaxCheck(tempstate, failed);
     end
    else
     failed := True;
  end
 else
  begin
   failed := True;
   AppendFailureMessage('��������� ���������� �� ������');
  end
 else
 begin
  failed := True;
  AppendFailureMessage('��������� ���������� �� �����');
 end;

 //�������
  if not failed then
    begin
     vyvod[High(vyvod)].theta := 0.;
     vyvod[High(vyvod)].thetaVisual :=DegToRad(g_thetaVisualdefault);

     AppendManevrData(Result,vvod,helicopter);
     AppendManevrData(Result,nakl,helicopter);
     AppendManevrData(Result,vyvod,helicopter);
    end
  else
   ShowMessage(failureMessage);


 //�������
  SetLength(vvod,0);
  SetLength(nakl,0);
  SetLength(vyvod,0);

end;

procedure VErrorMessage(temp,min,max: Real; manevr: string);
begin
  ShowMessage('�������� ����� � '+manevr +' ��������� ' + FloatToStr(Round(temp)) + ' ��/�. ��� �������� ������ ������ � ��������� �� '+FloatToStr(min) + ' �� '+FloatToStr(max) +' ��/�');
end;


function GorkaPikirovanieInputheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Vmin,Vmax : Real; Pikirovanie : Boolean) : TManevrData;
var
  Vtemp : Real;
  manevr : string;
begin
  Vtemp := initialstate.V*g_mps;

  if (Vtemp>=Vmin) and (Vtemp<=Vmax) then
   Result := iGorkaPikirovanie(helicopter, initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,Vvyvoda,Pikirovanie)
  else
   begin
     if Pikirovanie then
      manevr := '�����������'
     else
      manevr := '�����';

     SetLength(Result,0);
     VErrorMessage(Vtemp,Vmin,Vmax,manevr)
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


function ProportionalTo (orientirTemp, orientirStart, orientirFinal, parameterStart, parameterFinal : Real) : Real;
 //������ �������� ��������� ��������������� ��������� ���������
var
  k : Real;
begin
  k := (parameterFinal-parameterStart)/(orientirFinal-orientirStart);
  try
  Result := k * orientirTemp + parameterStart - orientirStart*k;
  except
   Result := 0;
   ShowMessage('������ ���������� ���������������� ��������');
  end;
end;


function iVirageSpiral(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������},Vy {m/s}: Real; Left, Forced: Boolean) : TManevrData;
var
  tempa, tempny, dpsiVvod, prevgamma, Vytemp, dnxa : Real;
  vvod, constgammaUchastok,vyvod : TManevrData;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed:Boolean;

const
  vvodVyvodPart = 0.1; // ���� �� ��������� �����, �����. ����� � ������

procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny, dnxa : Real; Left, Forced, constKren: Boolean);
begin

   if not constKren then
    begin
     omega.x:=DegToRad(10);  //�������� ����� � ���� (������ �� �����), �������� � �������
     if Left then omega.x := -omega.x
    end
   else
    omega.x:=0;

     omega.z:=0;
     if tempstate.V>=0 then
      begin
       omega.y := Sqrt(Sqr(ny)-1)*g_g/tempstate.V;   //rad

       if not Left then omega.y := -omega.y;
      end

     else
      begin
        omega.y :=0;
        ShowMessage('������� �������� �� ����!'+' ' + FloatToStr(tempstate.V));
        Halt;
      end;

    if not Forced then
       a := 0
    else
       a := g_g*(nx(helicopter, ny, icG, icT,tempstate.y,g_mps*tempstate.V) - dnxa - nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V));

end;

begin
 failed := False;
 ClearFailureMessages;

 if (1/Cos(DegToRad(kren)) <= ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) then
 if (Vy <= VyRasp(helicopter, icG, icT, initialstate.y, initialstate.V*g_mps)) then
      begin
          //��������������
       tempstate := initialstate;
       tempny :=1;
       Vytemp := 0;
       dnxa:= nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);

       //����
         SetLength(vvod,0);

       if not failed then
         while not (Abs(RadToDeg(tempstate.gamma)) >=Abs(kren)) do
          if (tempstate.V > 0)  then
             begin
              tempny := 1/Cos(tempstate.gamma);

              SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny, dnxa, Left, Forced, False);
              g_Etape(vvod,tempstate, helicopter, tempny,tempa, tempomega);

               //for spiral
              Vytemp := Vy/Abs(kren)*Abs(RadToDeg(tempstate.gamma));
              vvod[High(vvod)].y := vvod[High(vvod)].y + Vytemp/2*dt;
              tempstate.y := vvod[High(vvod)].y;

              HmaxCheck(tempstate,failed);
             end
          else
           begin
            failed:= True;
            Break;
           end;

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
         while not (Abs(tempstate.psi-initialstate.psi) >= Abs((DegToRad(deltaPsi))-Abs(dpsiVvod))) do
          if (tempstate.V > 0) then
             begin
              SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny, dnxa, Left,Forced,True);

              g_Etape(constgammaUchastok,tempstate, helicopter, tempny,tempa, tempomega);

              //��������� �������� �����
              {if Abs(tempstate.psi) > Abs(initialstate.psi + DegToRad(deltaPsi)) then
               constgammaUchastok[High(constgammaUchastok)].psi := initialstate.psi + DegToRad(deltaPsi);
               }

              constgammaUchastok[High(constgammaUchastok)].y := constgammaUchastok[High(constgammaUchastok)].y + Vytemp/2*dt;
              tempstate.y := constgammaUchastok[High(constgammaUchastok)].y;

               HmaxCheck(tempstate,failed);
             end
          else
           begin
            failed:= True;
            Break;
           end;

       //�����
         SetLength(vyvod,0);

       prevgamma := 0;

       if not failed then
       begin
        while not (tempstate.gamma*prevgamma < 0) do
         if (tempstate.V > 0) then
           begin
             tempny := 1/Cos(tempstate.gamma);

            SetOmegaAndAcceleration(tempomega,tempa,tempstate, tempny,dnxa,Left, Forced, False);
            tempomega.x := -tempomega.x;
            prevgamma := tempstate.gamma;
            g_Etape(vyvod,tempstate, helicopter, tempny,tempa, tempomega);

            //��������� �������� �����
           { if Abs(tempstate.psi) > Abs(initialstate.psi + DegToRad(deltaPsi)) then
               vyvod[High(vyvod)].psi := initialstate.psi + DegToRad(deltaPsi); }

              //for spiral
              Vytemp := Vy/Abs(kren)*Abs(RadToDeg(tempstate.gamma));
              vyvod[High(vyvod)].y := vyvod[High(vyvod)].y + Vytemp/2*dt;
              tempstate.y := vyvod[High(vyvod)].y;

              HmaxCheck(tempstate,failed);
           end
         else
          begin
           failed:= True;
           Break;
          end;

                //��������� �������� �����
            if (Abs(tempstate.gamma) > 0.001)  then
             if (tempstate.gamma*prevgamma < 0) then
              SetLength(vyvod,Length(vyvod)-1)
             else
               vyvod[High(vyvod)].gamma := 0;

       end;
      end
 else
  begin
   failed:= True;
   AppendFailureMessage('������������ �����������������');
  end
else
  begin
   failed:= True;
   AppendFailureMessage('�������� ���� ��������� ����������');
  end;


  //ShowMessage('iVirage: Vy = ' + FloatToStr(Vytemp));

  if not failed then
    begin
      SetLength(Result,0);
      AppendManevrData(Result,vvod,helicopter);
      AppendManevrData(Result,constgammaUchastok,helicopter);
      AppendManevrData(Result,vyvod,helicopter);

      SetLength(vvod,0);
      SetLength(constgammaUchastok,0);
      SetLength(vyvod,0);
    end
  else
   begin
    ShowMessage(failureMessage);
    SetLength(Result,0);
   end;
end;

function iiVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real; Forced : Boolean) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, 0, False, Forced);

  if deltaPsi > 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, 0, True, Forced);

  if deltaPsi = 0 then
   SetLength(Result,0)
end;                     

function Virage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
begin
  Result := iiVirage(helicopter, initialstate, icG, icT,kren, deltaPsi{�������}, False)
end;

function ForcedVirage(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}: Real) : TManevrData;
begin
   Result := iiVirage(helicopter, initialstate, icG, icT,kren, deltaPsi{�������}, True)
end;

function Spiral(helicopter : THelicopter; initialstate : TStateVector; icG, icT,kren, deltaPsi{�������}, Vy{m/s}: Real) : TManevrData;
begin
  if deltaPsi < 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, Vy, False, False);
  if deltaPsi > 0 then
    Result:=iVirageSpiral(helicopter, initialstate, icG, icT,kren, deltaPsi, Vy, True, False);
  if deltaPsi = 0 then
   SetLength(Result,0)
end;

function TakesLongTime (initialstate, tempstate : TStateVector) : Boolean;
begin
  Result := False;

  if tempstate.t - initialstate.t > 180 then
   Result := True;

end;

function iRazgonTormozhenie(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{km/h}, VyDesired{m/s} : Real) : TManevrData;
var
  localTime,tempny,a, Vytemp, tempy, VstartThetaCorr, ThetastartThetaCorr, VytempCorrected, VbeginCorr, VendCorr : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

const
   Vfactor = 0.2;

function Razgon() : Boolean;
begin
  Result := g_mps*initialstate.V < Vfinal;
end;

 procedure SetAccelerationTormozh(var a : Real; tempstate: TStateVector; ny, Vy, V : Real);
 { const
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

end;   }

 const
  knx = 0.005;
  VfinalReper = 2;
  thetaMax = 6;//degree


var
 linearnx, realnx,VfinalTrick : Real;

begin
   linearnx := -knx*localTime;

      if Vfinal <= VfinalReper then
       if Vfinal < 0.1
       then
         VfinalTrick := Vfinal+0.1
       else
         VfinalTrick := Vfinal
      else
       VfinalTrick := Vfinal - VfinalReper;

   realnx := nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy)-nx(helicopter,tempny,icG, icT,tempstate.y, VfinalTrick, Vy);
 //  ShowMessage('SetAccelerationTormozh '+  FloatToStr(nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy)));
 //  ShowMessage('SetAccelerationTormozh '+ FloatToStr(nx(helicopter,tempny,icG, icT,tempstate.y,VfinalTrick, Vy)));

   if g_mps*tempstate.V < 100 then
          if Abs(realnx) > Tan(DegToRad(thetaMax))
          then
            realnx := -Tan(DegToRad(thetaMax));


   if linearnx < realnx then
     a := g_g*realnx
   else
     a := g_g*linearnx
end;

function ManevrName(aRazgon : Boolean): string;
begin
  if aRazgon then
   Result := '������'
  else
   Result := '����������'
end;



 procedure SetAccelerationRazgon(var a : Real; tempstate: TStateVector; ny, Vy : Real);
  const
 knx = 0.005;

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
 VstartThetaCorr := 0;
 ThetastartThetaCorr := 0;
 VytempCorrected := 0;
 ClearFailureMessages;

 if Round(initialstate.V*g_mps) <> Vfinal then
    begin
         tempstate := initialstate;
         tempny :=1;
         localTime :=0.1;
         tempomega.x:=0;
         tempomega.y:=0;
         tempomega.z:=0;
         SetLength(Result,0);
         tempy := initialstate.y;


      if initialstate.V*g_mps < 0.95*helicopter.Vmax then
       begin
          //while (not (g_mps*tempstate.V >=Vfinal)) and (not failed) do
        while ((Razgon and (g_mps*tempstate.V <=Vfinal)) or ((not Razgon) and (g_mps*tempstate.V >=Vfinal))) and (not failed) do
         begin
           if TakesLongTime (initialstate, tempstate) then
            begin
             Break;
             ShowMessage('���������� ��������� ' + ManevrName(Razgon) + ' � ��������� �����������: �������������� �������� ������� ����� �������');
             SetLength(Result,0);
            end;

            if (tempstate.V >= 0) then
              begin
               begin


                    //calculating Vy
                if Length(Result) = 0 then
                 Vytemp := VyRasp(helicopter, icG, icT, tempy, initialstate.V*g_mps)
                else
                 Vytemp := VyRasp(helicopter, icG, icT, Result[High(Result)].y, Result[High(Result)].V*g_mps);

                if (Vytemp > VyDesired) or (Abs(VyDesired) < 0.001){in case of horizontal flight} then
                  Vytemp := VyDesired;


                  if Razgon then
                    begin
                     VbeginCorr := initialstate.V + Vfactor*Abs(Vfinal/g_mps - initialstate.V) ;  // m/s
                     VendCorr :=  Vfinal/g_mps - Vfactor*Abs(Vfinal/g_mps - initialstate.V)
                    end
                  else
                    begin
                     VbeginCorr := initialstate.V - Vfactor*Abs(Vfinal/g_mps - initialstate.V);
                     VendCorr :=  Vfinal/g_mps + Vfactor*Abs(Vfinal/g_mps - initialstate.V)
                    end;

                if  Abs(Abs(tempstate.V)-Abs(initialstate.V))*g_mps < Vfactor*Abs(Abs(Vfinal)-g_mps*Abs(initialstate.V)) then
                 //beginning
                   VytempCorrected := ProportionalTo(tempstate.V, initialstate.V, VbeginCorr, 0, Vytemp);

                if Abs(Abs(Vfinal)-Abs(tempstate.V)*g_mps) < Vfactor*Abs(Abs(Vfinal)-g_mps*Abs(initialstate.V)) then
                   //ending
                   VytempCorrected := ProportionalTo(tempstate.V, VendCorr, Vfinal/g_mps, Vytemp, 0);



                if Razgon then
                 SetAccelerationRazgon(a,tempstate, tempny, {Vytemp}VytempCorrected)
                else
                 SetAccelerationTormozh(a,tempstate, tempny, {Vytemp}VytempCorrected, initialstate.V);





                g_Etape(Result,tempstate, helicopter, tempny,a, tempomega);




                           //climb
                tempy := tempy + {Vytemp}VytempCorrected*dt;
                Result[High(Result)].y := tempy;




                 //thetaVisual correction
                Result[High(Result)].thetaVisual := DegToRad(g_thetaVisualdefault)-0.6*ArcTan(a/g_g); //pitch according to nx_temp

                if Abs(Abs(tempstate.V) - Abs(initialstate.V))*g_mps > 0.7*Abs(Abs(Vfinal) - Abs(initialstate.V)) then
                 begin
                  if VstartThetaCorr = 0 then
                    begin
                     VstartThetaCorr := tempstate.V*g_mps;
                     ThetastartThetaCorr := Result[High(Result)].thetaVisual;
                    end;

                  Result[High(Result)].thetaVisual := ProportionalTo(tempstate.V*g_mps, VstartThetaCorr, Vfinal, ThetastartThetaCorr, DegToRad(g_thetaVisualdefault))
                 end;




                localTime := localTime + dt;

                HmaxCheck(Result[High(Result)], failed);
               end;
              end
            else
             begin
              failed := True;
              AppendFailureMessage('������� �������� �� ������������� ��������');
             end;
         end;
           if not failed then
           begin
            Result[High(Result)].V := Vfinal/g_mps;
            Result[High(Result)].thetaVisual := DegToRad(g_thetaVisualdefault);
           end;

        if failed then
         begin
          ShowMessage(failureMessage);
          SetLength(Result,0);
         end;
       end

      else
          ShowMessage('��������� �������� ��������� ' + FloatToStr(Round(initialstate.V*g_mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
    end
 else
  ShowMessage('�������� � ��������� �������� ��� ������� (����������) �� ����� ���� ����� ����� �����!')
end;

function iTormozhNew(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{km/h}, VyDesired{m/s} : Real) : TManevrData;
var
  localTime,tempny,a, Vytemp, tempy : Real;
  tempstate : TStateVector;
  tempomega : TVector3D;
  failed : Boolean;

procedure SetAccelerationTormozh(var a : Real; tempstate: TStateVector; ny, Vy : Real);
 var
  realnx,VfinalTrick : Real;
 const
  VfinalReper = 2;
  thetaMax = 6;//degree
begin
      if Vfinal <= VfinalReper then
       if Vfinal < 0.1
       then
         VfinalTrick := Vfinal+0.1
       else
         VfinalTrick := Vfinal
      else
       VfinalTrick := Vfinal - VfinalReper;

  realnx := nx(helicopter,tempny,icG, icT,tempstate.y,g_mps*tempstate.V, Vy)-nx(helicopter,tempny,icG, icT,tempstate.y, VfinalTrick, Vy);

  if g_mps*tempstate.V < 100 then
    if Abs(realnx) > Tan(DegToRad(thetaMax))
    then
      realnx := -Tan(DegToRad(thetaMax));

  a := g_g*realnx
end;

begin
 failed := False;

 if Round(initialstate.V*g_mps) <> Vfinal then
   begin
      //��������������
     tempstate := initialstate;
     tempny :=1;
     localTime :=0;
     tempomega.x:=0;
     tempomega.y:=0;
     tempomega.z:=0;
     SetLength(Result,0);
     tempy := initialstate.y;
     a:=0;

    if initialstate.V*g_mps < 0.95*helicopter.Vmax then
     begin
       while (g_mps*tempstate.V >=Vfinal) and (not failed) do
       begin
         if TakesLongTime (initialstate, tempstate) then
            begin
             Break;
             ShowMessage('���������� ��������� ���������� � ��������� �����������');
             SetLength(Result,0);
            end;

        if (tempstate.V >= 0) then
          begin
           begin
            if Length(Result) = 0 then
             Vytemp := VyRasp(helicopter, icG, icT, tempy, initialstate.V*g_mps)
            else
             Vytemp := VyRasp(helicopter, icG, icT, Result[High(Result)].y, Result[High(Result)].V*g_mps);

            if (Vytemp > VyDesired) or (Abs(VyDesired) < 0.001){in case of horizontal flight} then
              Vytemp := VyDesired;

             SetAccelerationTormozh(a,tempstate, tempny, Vytemp);

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
       end;
       if not failed then
        Result[High(Result)].V := Vfinal/g_mps;

       if failed then
         begin
          ShowMessage('������� �������� �� ����!');
          SetLength(Result,0);
         end;
     end

    else
      ShowMessage('��������� �������� ��������� ' + FloatToStr(Round(initialstate.V*g_mps)) + ' ��/�. ��� �������� �� ����� ���������  '+FloatToStr(0.95*helicopter.Vmax)+ ' ��/�');
   end
 else
  ShowMessage('�������� � ��������� �������� ��� ������� (����������) �� ����� ���� ����� ����� �����!')
end;

function TormozhNew(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{km/h}, VyDesired{m/s} : Real; divisionsCount : Integer) : TManevrData;
var
  tempstate : TStateVector;
  etape : TManevrData;
  VfinalTemp, deltaVfinal : Real;
begin
 SetLength(Result,0);

 if divisionsCount > 0 then
  begin
   tempstate := initialstate;
   deltaVfinal := (initialstate.V*g_mps - Vfinal)/divisionsCount;
   VfinalTemp := initialstate.V*g_mps - deltaVfinal;

   while Round(tempstate.V*g_mps) > Vfinal do
    begin
      etape := iTormozhNew(helicopter, tempstate, icG, icT,VfinalTemp, VyDesired);

      tempstate := etape[High(etape)];

      AppendManevrData(Result,etape,helicopter);

      VfinalTemp := VfinalTemp - deltaVfinal;
    end;

  end
 else
  ShowMessage('TormozhNew: ���������� ��������� �� ����� ���� ������ ����')


end;

function HorizRazgonTormozhenie(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}: Real) : TManevrData;
begin
{ if initialstate.V*g_mps < Vfinal then
   Result:= TormozhNew(helicopter, initialstate, icG, icT,Vfinal, 0,5);  // � ���������� ����������
 else }
   Result:= iRazgonTormozhenie(helicopter, initialstate, icG, icT,Vfinal, 0);  // ��� ��������� ����������
end;


function RazgonSnaborom(helicopter : THelicopter; initialstate : TStateVector; icG, icT,Vfinal{��/�}, Vy{m/s}: Real) : TManevrData;
begin
 Result:= iRazgonTormozhenie(helicopter, initialstate, icG, icT,Vfinal, Vy);
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
        Result := (-0.5*a)*Sqr(t-deltatSlope-deltat)+Vmax*(t-deltatSlope-deltat)+Vmax*(0.5*deltatSlope+deltat)
     end
    else
     ShowMessage('�������� ����� ��������� ����� ���������� �������');
   end;
end;

function iVertVzletPosadka(helicopter : THelicopter; initialstate : TStateVector; icG, icT, deltay, Vdesired : Real) : TManevrData;
var
  deltat, localt : Real;
  failed : Boolean;

begin
 SetLength(Result,0);
 failed := False;
 ClearFailureMessages;

 if Vdesired <= VertVzletPosadkaVmax (helicopter,icG, icT,initialstate.y,deltay) then
   if deltay <> 0 then
    if Abs(initialstate. V) < 0.001 then
      begin
        deltat := VertVzletPosadkaDeltaT(deltay, Vdesired);

        if deltat > 0 then
         begin
          localt := -dt;

          while (localt < deltat + 2*deltatSlope) and (not failed) do
           begin


            localt := localt + dt;

            if localt > 0 then
              begin
                ExtendArray(Result);

                Result[High(Result)] := initialstate;

                with Result[High(Result)] do
                 begin
                  y := initialstate.y + VertVzletPosadkay (deltay, Vdesired, localt);
                  V := VertVzletPosadkaV (deltay, Vdesired, localt);
                  t := initialstate.t + localt
                 end; 

                 HmaxCheck(Result[High(Result)], failed);
              end;

           end;

           if not failed then
            begin
              Result[High(Result)].V := 0;
            end

           else
            begin
             SetLength(Result,0);
             ShowMessage(failureMessage);
            end;

         end
        else
         ShowMessage('function iVertVzletPosadka: deltat error ')
      end
    else
     ShowMessage('��������� �������� ������� ������ ���� ����� ����!')
   else
    ShowMessage('����������� �� ������ ���� ����� ����!')
 else
  ShowMessage('�������� ������������ �������� �� ����� ���� ����������');

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
  Result := 0;

  if duration > 0.001 then
   if t<=duration/2 then
    Result := (2/duration)* t * A * Cos(Omega * t + phi)
   else
    Result := ((-2/duration)* t + 2) * A * Cos(Omega * t + phi)
  else
   ShowMessage('����������������� ������� ������ ���� ������ ����');
end;

function Visenie(initialstate : TStateVector; duration : Real) : TManevrData;

var
localtime : Real;

const
  ampli = 0.0349; // 2 degrees
  omega = 0.04;

begin

 SetLength(Result,0);

 if initialstate.V = 0 then
   begin

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

              thetaVisual := initialstate.thetaVisual + MyOscillation (ampli, omega, Pi/2, duration, localtime);
              gamma := initialstate.gamma + MyOscillation (ampli, omega, 0, duration, localtime);
              t := initialstate.t + localtime + dt;

              localtime := localtime + dt;

             end;

           end;

            with Result[High(Result)] do
               begin
                thetaVisual := DegToRad(g_thetaVisualdefault);
                gamma := 0;
               end;
      end

    else

     ShowMessage('����������������� ������� ������ ���� ������ ����!');

   end

 else

  ShowMessage('��� ���������� ������� �������� ������ ���� ����� ����!');

end;





function iNaklon (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda : Real) : TManevrData;
var
 vvod,nakl,vyvod : TManevrData;
 nyslope,tempa : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

procedure SetOmegaAndAccelerationVvodVyvod(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny, nxOtXvr : Real);
var
  nx : Real;
begin
     a := 0;

     nx := (Sin(tempstate.theta)*(1+ny)+nxOtXvr)/Cos(tempstate.theta);

     omega.x:=0;
     omega.y:=0;
     if tempstate.V>=0 then
      omega.z := ((ny-1)*Cos(tempstate.theta)-nx*Sin(tempstate.theta))*g_g/tempstate.V   //rad
     else
      begin
        omega.z :=0;
        ShowMessage('������� �������� �� ����!');
        Halt;
      end;     
end;

procedure SetOmegaAndAccelerationNakl(var omega : TVector3D; var a : Real; tempstate: TStateVector);

begin
     a := 0;

     omega.x:=0;
     omega.y:=0;
     if tempstate.V>=0 then
      omega.z := 0 //rad
     else
      begin
        omega.z :=0;
        ShowMessage('������� �������� �� ����!');
        Halt;
      end;
end;

 procedure Etape(var TempFlightData : TManevrData; ny : Real);
   begin
    ExtendArray(TempFlightData);

    SetOmegaAndAccelerationNakl(tempomega, tempa, tempstate);

    MyIntegrate(tempstate,dt,tempa,tempomega);

    TempFlightData[High(TempFlightData)] := tempstate;
   end;


begin
     //��������������

     SetLength(Result,0);

     failed := False;
     ClearFailureMessages;

// if not ((nyvvoda > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) or (nyvyvoda > ny(helicopter, icG, icT,initialstate.y-200,Vvyvoda))) then
if not (nyvvoda > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) then

  begin
   //  dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //��������� �������� � ��/�

     tempstate := initialstate;

   //����
     SetLength(vvod,0);
    while (not ((RadToDeg(tempstate.theta)>=thetaSlope) xor (thetaSlope<0))) and (not failed) do
      if (tempstate.V > 0) then
       begin
        SetOmegaAndAccelerationVvodVyvod(tempomega, tempa, tempstate,nyvvoda,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�
        g_Etape(vvod,tempstate, helicopter, nyvvoda,tempa, tempomega);

        vvod[High(vvod)].thetaVisual := initialstate.thetaVisual;

        HmaxCheck(tempstate, failed);
       end
      else
      failed := True;

    vvod[High(vvod)].theta := DegToRad(thetaSlope);

   //��������� �������
     SetLength(nakl,0);

     nyslope := Cos(tempstate.theta);

    while (not (Abs(initialstate.y-tempstate.y)>=hvyvoda)) and (not failed) do
     if (tempstate.V > 0) then
      begin
       Etape(nakl,nyslope);
       nakl[High(nakl)].thetaVisual := initialstate.thetaVisual;
       HmaxCheck(tempstate, failed);
      end
     else
    failed := True;

   //�����  
     SetLength(vyvod,0);
   if not (nyvyvoda > ny(helicopter, icG, icT,initialstate.y-200,g_mps*tempstate.V)) then

   while (not ((RadToDeg(tempstate.theta)<=0) xor (thetaSlope<0))) and (not failed) do
    if (tempstate.V > 0) then
     begin
        SetOmegaAndAccelerationVvodVyvod(tempomega, tempa, tempstate,nyvyvoda,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�
        g_Etape(vyvod,tempstate, helicopter, nyvyvoda,tempa, tempomega);

        vyvod[High(vyvod)].thetaVisual := initialstate.thetaVisual;

        HmaxCheck(tempstate, failed);
     end
    else
     failed := True

    else
   begin
   failed := True;
   AppendFailureMessage('��������� ���������� �� ������');
   end
  end

 else
 begin
  failed := True;
  AppendFailureMessage('��������� ���������� �� �����');
 end;

 //�������
  if not failed then
    begin
     vyvod[High(vyvod)].theta := 0.;
     vyvod[High(vyvod)].thetaVisual :=DegToRad(g_thetaVisualdefault);

     AppendManevrData(Result,vvod,helicopter);
     AppendManevrData(Result,nakl,helicopter);
     AppendManevrData(Result,vyvod,helicopter);
    end
  else
   ShowMessage(failureMessage);


 //�������
  SetLength(vvod,0);
  SetLength(nakl,0);
  SetLength(vyvod,0);
  
end;

function NaklonInputheck(helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda,Vmin,Vmax : Real) : TManevrData;
var
  Vtemp : Real;
  manevr : string;
begin
  Vtemp := initialstate.V*g_mps;

  if (Vtemp>=Vmin) and (Vtemp<=Vmax) then
   Result := iNaklon (helicopter,initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda)
  else
   begin
     if thetaSlope < 0 then
      manevr := '�������� �� ���������'
     else
      manevr := '����� ������ �� ���������';

     SetLength(Result,0);
     VErrorMessage(Vtemp,Vmin,Vmax,manevr)
   end;
end;

function Naklon (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda : Real) : TManevrData;
const
Vmin = 50;

var
  Vmax : Real;

begin
   Vmax := 0.9*helicopter.Vmax;
   Result := NaklonInputheck(helicopter,initialstate, icG, icT,nyvvoda,nyvyvoda,thetaSlope,hvyvoda,Vmin,Vmax);

end;

function iPetlyaNesterova (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nySredn, nyAmplitude: Real) : TManevrData;
var
 tempa,dnxa,nytemp : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

begin
     //��������������

     SetLength(Result,0);

     failed := False;
     ClearFailureMessages;

//if not (nySredn > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) then
 begin
     dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //��������� �������� � ��/�

     tempstate := initialstate;

    while (not (RadToDeg(tempstate.theta)>=360) and (not failed)) do
      if (tempstate.V > 0) then
       begin
        nytemp := nySredn + nyAmplitude * Cos(tempstate.theta);
        SetOmegaAndAccelerationVvodVGorku(tempomega, tempa, tempstate,nytemp,nx(helicopter, nytemp, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V)); //��������� �������� � ��/�
        g_Etape(Result,tempstate, helicopter, nytemp,tempa, tempomega);
        HmaxCheck(tempstate, failed);
       end
      else
      
       begin
        failed := True;
        AppendFailureMessage('��� ���������� ����� ��������� ��������� ������� �������� �� ����');
       end;

      if Length(Result) > 0 then
         Result[High(Result)].theta := 0;
 end;
{ else
  begin
   failed := True;
   AppendFailureMessage('��������� ���������� �� �����');
  end;  }

  if failed then
   ShowMessage(failureMessage);

end;

function PetlyaNesterova (helicopter : THelicopter; initialstate : TStateVector; icG, icT,nySredn: Real) : TManevrData;
const
  amplitudeCoeff = 0.3;
begin
 Result := iPetlyaNesterova (helicopter , initialstate, icG, icT,nySredn,amplitudeCoeff*nySredn)
end;


function iBoevoiRazvorot(helicopter : THelicopter; initialstate : TStateVector; icG, icT, kren, tangage, dkurs, greaternyCoeff, smallernyCoeff : Real) : TManevrData;
var
vvod, stable, vyvod: TManevrData;
 nyTemp, tempa,dnxa, localTime : Real;
 tempstate : TStateVector;
 tempomega : TVector3D;
 failed : Boolean;

const
// greater = 1.2;
// smaller = 0.8;
 kursCoeff = 0.97;
 gammaDot = 0.087; //5 degrees per second

 function Nishod : Boolean;
 begin
   Result := tangage < 0
 end;

 function nyVvodCoeff (Nishod: Boolean) : Real;
 begin
   if Nishod

   then
     Result := smallernyCoeff
   else
     Result := greaternyCoeff

 end;

  function nyVyvodCoeff (Nishod: Boolean) : Real;
 begin
   if Nishod
   then
     Result := greaternyCoeff
   else
     Result := smallernyCoeff

 end;

procedure SetOmegaAndAcceleration(var omega : TVector3D; var a : Real; tempstate: TStateVector; ny,nx,dnxa,nxOtXvr, initialkren, finalkren, localTime : Real);

begin

     if tempstate.V >= 0

     then

      begin
        if (RadToDeg(tempstate.gamma) <> finalkren)
        then
         if (RadToDeg(tempstate.gamma) < finalkren)
         then
          omega.x := gammaDot
         else
          omega.x := -gammaDot
        else
         omega.x:=0;

        omega.y:= - ny * Sin(tempstate.gamma) * g_g / (tempstate.V * Cos(tempstate.theta));      //rad
        omega.z := (ny * Cos(tempstate.gamma) -Cos(tempstate.theta)) * g_g / tempstate.V    //rad
      end
     else
      begin
        omega.x:=0;
        omega.y :=0;
        omega.z :=0;
        ShowMessage('������� �������� �� ����!');
        Halt;
      end;

      a := g_g*(nx - dnxa - Sin(tempstate.theta) - nxOtXvr);
end;


begin

     //��������������

     SetLength(Result,0);
     localTime := 0;

     failed := False;
     ClearFailureMessages;



//    if not (nyvvoda > ny(helicopter, icG, icT,initialstate.y,initialstate.V*g_mps)) then
  //   if not (nyvyvoda > ny(helicopter, icG, icT,initialstate.y-200,Vvyvoda)) then
    begin
         dnxa := nx(helicopter, {ny}1, icG, icT,initialstate.y,initialstate.V*g_mps);  //��������� �������� � ��/�

         tempstate := initialstate;

       //����
         SetLength(vvod,0);

        while (not (Abs(RadToDeg(tempstate.theta))>=Abs(tangage)) and (not failed)) do
          if (tempstate.V > 0) then
           begin
            localTime := tempstate.t - initialstate.t;
            nyTemp := nyVvodCoeff(Nishod) * Cos(tempstate.theta) / Cos(tempstate.gamma);
            SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyTemp,nx(helicopter, nyTemp, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V),RadToDeg(initialstate.gamma),kren, localTime); //��������� �������� � ��/�
            g_Etape(vvod,tempstate, helicopter, nyTemp,tempa, tempomega);
            HmaxCheck(tempstate, failed);
           end
          else
          failed := True;

        vvod[High(vvod)].theta := DegToRad(tangage);
        tempstate.theta := DegToRad(tangage);

       //��������� �������
         SetLength(stable,0);



        while (not ((Abs(RadToDeg(tempstate.psi - initialstate.psi)) >= Abs(kursCoeff * dkurs)))) and (not failed) do
         if (tempstate.V > 0) then
          begin
           nyTemp := Cos(tempstate.theta) / Cos(tempstate.gamma);
           SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyTemp,nx(helicopter, nyTemp, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V),kren,kren, localTime); //��������� �������� � ��/�
           g_Etape(stable,tempstate, helicopter, nyTemp,tempa, tempomega);
           
            if Abs(stable[High(stable)].gamma) <> Abs(DegToRad(kren))
            then
            stable[High(stable)].gamma := DegToRad(kren);

           HmaxCheck(tempstate, failed);
          end
         else
        failed := True;

        if Length(stable)>0 then
        stable[High(stable)].theta := DegToRad(tangage);

        
       //�����  
         SetLength(vyvod,0);
         tempomega.z := 0;
         tempomega.x := 0;

      //   ShowMessage(FloatToStr(tempstate.theta * Round(tempomega.z)));

   //    while  (tempstate.theta * tempomega.z <= 0) and (tempstate.gamma * tempomega.x <= 0) and (not failed) do
       repeat
        if (tempstate.V > 0) then
         begin
          nyTemp := nyVyvodCoeff(Nishod) * Cos(tempstate.theta) / Cos(tempstate.gamma);
          SetOmegaAndAcceleration(tempomega, tempa, tempstate,nyTemp,nx(helicopter, nyTemp, icG, icT,tempstate.y,g_mps*tempstate.V),dnxa,nxOtXvr(helicopter,tempstate.y,icG,g_mps*tempstate.V),RadToDeg(stable[High(stable)].gamma),0, localTime); //��������� �������� � ��/�
          g_Etape(vyvod,tempstate, helicopter, nyTemp,tempa, tempomega);

          if Abs(vyvod[High(vyvod)].gamma) < gammaDot * dt
          then
           vyvod[High(vyvod)].gamma := 0;

          HmaxCheck(tempstate, failed);
         end
        else
         failed := True;

       until (((tempstate.theta * tempomega.z > 0) and (tempstate.gamma * tempomega.x > 0)) and (not failed));

    end;
 {    else
      begin
       failed := True;
       AppendFailureMessage('��������� ���������� �� ������');
      end
     else
     begin
      failed := True;
      AppendFailureMessage('��������� ���������� �� �����');
     end;

            }


      //�������
  if not failed then
    begin
      if Length(vyvod) > 0 then
      begin
       vyvod[High(vyvod)].theta := 0.;
       vyvod[High(vyvod)].thetaVisual :=DegToRad(g_thetaVisualdefault);
      end;
     AppendManevrData(Result,vvod,helicopter);
     AppendManevrData(Result,stable,helicopter);
     AppendManevrData(Result,vyvod,helicopter);
    end
  else
   ShowMessage(failureMessage);


 //�������
  SetLength(vvod,0);
  SetLength(stable,0);
  SetLength(vyvod,0);

end;

end.




unit Kernel;

interface

uses HelicoptersDatabase, Dialogs,Sysutils,World, GlobalConstants, Math;


type TDiapason = array [0..g_Vmax] of Real;

function HotV(helicopter : THelicopter; icG, icT,V: Real) : Real; overload; //характеризует диапазон высот и скоростей с учетом полетного веса и температуры

function Diapason(helicopter : THelicopter; icG, icT : Real) : TDiapason;overload; //просто сетка дл€ визуализации скорректированного диапазона

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;overload; //с учетом полетного веса и температуры
function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;
function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent, V, Vy, Hrasch : Real) : Real; overload;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;  overload;
function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V, Cx : Real) : Real;  overload;

function ny(helicopter : THelicopter;icG, icT,icH0,V : Real):Real; overload;
function ny(helicopter : THelicopter;icG, icT,icH0,V, Hrasch : Real): Real; overload;

function nyMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;
function gammaMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//на высоте h c точностью до 1 км/ч
function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;

function RealHst(helicopter : THelicopter; icG, icT : Real): Real;

function VyRasp(helicopter : THelicopter; icG, icT, h0, Vnach, Vkon{km/h} : Real) : Real;overload; //m/s
function VyRasp(helicopter : THelicopter; icG, icT, h0, V{km/h}  : Real) : Real;overload;


function Trasp(helicopter : THelicopter; icT, H : Real) : Real;
function HotTyagi(helicopter : THelicopter; icT, Tyaga : Real) : Real;


const
  g_Hrasch = 1500;  //used in nx and ny plots !


implementation

const
 normT = 15;
 Neuzemli15 = 2000;
 termCoeffHotT = 50;

function HotV(helicopter : THelicopter; V: Real) : Real; overload;
//характеризует диапазон высот и скоростей дл€ нормальных условий
begin
 Result := helicopter.Hdyn - Sqr(V-helicopter.ParabolaCoeff*helicopter.Vmax)*(helicopter.Hdyn-helicopter.Hst)/Sqr(helicopter.ParabolaCoeff*helicopter.Vmax)
end;

function Diapason (helicopter : THelicopter) : TDiapason; overload;  //просто сетка дл€ визуализации диапазона дл€ нормальных условий
var
  i : Integer;
begin
 for i:=0 to g_Vmax do
     Result[i] :=  HotV(helicopter, i)
end;

function iUZemli(uzemli{при 15 градусах}, tempcoeff, icT : Real) : Real;
begin
  Result := uzemli;

  if icT > normT then
    Result := Result - tempcoeff*(icT-normT)
end;


function fOtH(uzemli15{при 15 градусах}, tempcoeff, icT, H, ctg : Real) : Real; overload;
begin
  Result := iUZemli(uzemli15, tempcoeff, icT) - H * ctg
end;

function fOtH(uzemli15, tempcoeff, icT, H, ctg, Hrasch : Real) : Real; overload;
begin
  if
   H <= Hrasch

  then //constant value
   Result := fOtH(uzemli15, tempcoeff, icT, Hrasch, ctg)

  else //linear dependence
   Result := fOtH(uzemli15, tempcoeff, icT, H, ctg)
end;

function Trasp(helicopter : THelicopter; icT, H : Real) : Real;overload;
begin
  Result := fOtH(helicopter.TraspUZemli{при 15 градусах}, helicopter.TemperCoeff, icT, H, helicopter.ctgTotH)
end;

function Trasp(helicopter : THelicopter; icT, H, Hrasch : Real) : Real;overload;
begin
  Result := fOtH(helicopter.TraspUZemli{при 15 градусах}, helicopter.TemperCoeff, icT, H, helicopter.ctgTotH, Hrasch)
end;

//функци€, обратна€ Trasp
function HotTyagi(helicopter : THelicopter; icT, Tyaga : Real) : Real;
begin
  Result := (iUZemli(helicopter.TraspUZemli, helicopter.TemperCoeff, icT) - Tyaga) / helicopter.ctgTotH
end;

   {
function HotV(helicopter : THelicopter;icG, icT, V: Real) : Real; overload;
var
   groundT, T,dH, H1 : Real;

begin
 H1 := HotV(helicopter,0);
 groundT := helicopter.TraspUZemli;
 T := (groundT - H1*helicopter.ctgTotH)*(icG/helicopter.Gnorm);

 if icT > normT then groundT := groundT-helicopter.TemperCoeff*(icT-normT);

 dH := (groundT-T)/helicopter.ctgTotH - H1;

  Result := HotV(helicopter,V) + dH;
end;

  }
function HotV(helicopter : THelicopter;icG, icT, V: Real) : Real; overload;
var
  H1 : Real;
begin
  H1 := HotV(helicopter,0);

  Result := HotV(helicopter,V) + HotTyagi(helicopter, icT, Trasp(helicopter,normT, H1)*(icG/helicopter.Gnorm)) - H1
end;

function Ne(helicopter : THelicopter; icT, H : Real) : Real; overload;
begin
  Result := fOtH(Neuzemli15, termCoeffHotT * helicopter.ctgNotH, icT, H, helicopter.ctgNotH)
end;

function Ne(helicopter : THelicopter; icT, H, Hrasch : Real) : Real; overload;
begin
  Result := fOtH(Neuzemli15, termCoeffHotT * helicopter.ctgNotH, icT, H, helicopter.ctgNotH, Hrasch)
end;


function iinx (helicopter : THelicopter; ny, icG, icT, V, hManevraCurrent, Vy, Nerasp : Real) : Real;

const
  smallnumber = 0.001;

var
  tempV, H1 : Real;
begin
   Result :=0;

 if (Abs(V) <= smallnumber) and (V >= 0) then
  tempV := smallnumber
 else
  tempV := V;

 if tempV>0 then
  begin
   H1 := HotV(helicopter,ny*icG, icT, tempV);

   Result :=  g_mps*(75 * (2 * (Nerasp - Ne(helicopter, icT, H1){потребна€} - Vy * icG * g_g / 736)))/(tempV * helicopter.Gnorm)
  end
 else
  ShowMessage('ѕри вычислении тангенциальной перегрузки обнаружено некорректное значение скорости ' + FloatToStr(V));

end;

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real; overload;
begin
  Result := iinx (helicopter, ny, icG, icT, V, hManevraCurrent, 0, Ne(helicopter, icT, hManevraCurrent))
end;

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent, V, Vy : Real) : Real; overload;
begin
  Result := iinx (helicopter, ny, icG, icT, V, hManevraCurrent, Vy, Ne(helicopter, icT, hManevraCurrent))
end;

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent, V, Vy, Hrasch : Real) : Real; overload;
begin
  Result := iinx (helicopter, ny, icG, icT, V, hManevraCurrent, Vy, Ne(helicopter, icT, hManevraCurrent,Hrasch))
end;


   {

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;

const
  smallnumber = 0.001;

var
  tempV, H1 : Real;
begin
   Result :=0;

 if (Abs(V) <= smallnumber) and (V >= 0) then
  tempV := smallnumber
 else
  tempV := V;

 if tempV>0 then
  begin
   H1 := HotV(helicopter,ny*icG, icT, tempV);

   Result :=  g_mps*(75 * (2 * (
   Ne(helicopter, icT, hManevraCurrent)//располагаема€
   - Ne(helicopter, icT, H1)//потребна€
   )))/(tempV*helicopter.Gnorm)
  end
 else
  ShowMessage('ѕри вычислении тангенциальной перегрузки обнаружено некорректное значение скорости '+FloatToStr(V));

end;

      }


function Diapason (helicopter : THelicopter; icG, icT : Real) : TDiapason;overload;
var
 i : Integer;
begin
  for i:=0 to g_Vmax do
   Result[i] := HotV(helicopter,icG, icT,i)
end;

//function inx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real): Real;
 {
var
 tempV : Real;
const
  smallnumber = 0.001;

begin
 Result :=0;

 if (Abs(V) <= smallnumber) and (V >= 0) then
  tempV := smallnumber
 else
  tempV := V;

 if tempV>0 then
  with helicopter do
   Result := (540/Gnorm)*((TraspUZemli*(1-ny)/ctgTotH+HotV(helicopter,icG, icT,tempV)*ny-hManevraCurrent)*ctgNotH -0.0066*icG*Vy/2)/tempV
 else
  ShowMessage('ѕри вычислении тангенциальной перегрузки обнаружено некорректное значение скорости '+FloatToStr(V));
end; }


//function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real; overload;
////с учетом полетного веса и температуры
// begin
//   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, 0);
// end;


//function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;
//с учетом полетного веса, температуры и скороподъемности
// begin
//   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, Vy);
// end;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real; overload;
const
  Cx = 0.0115;
begin
  Result := Cx*helicopter.Fomet*AirDensity(hManevraCurrent)*Sqr(V/g_mps/2)/icG
end;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V, Cx : Real) : Real;  overload;
begin
  Result := Cx*helicopter.Fomet*AirDensity(hManevraCurrent)*Sqr(V/g_mps/2)/icG
end;
  {
function ny(helicopter : THelicopter;icG, icT,icH0,V : Real): Real;
var
  denominator : Real;
begin
  Result :=1;
  with helicopter do
   denominator := (TraspUZemli/ctgTotH-HotV(helicopter,icG, icT,V));

  if Abs(denominator) > 0.00001 then
   with helicopter do
    Result:= (TraspUZemli/ctgTotH-icH0)/(TraspUZemli/ctgTotH-HotV(helicopter,icG, icT,V))
  else
    ShowMessage('ѕри заданных услови€х невозможно определить нормальную перегрузку');

end;
    }
function ny(helicopter : THelicopter;icG, icT,icH0,V : Real): Real; overload;
begin
 Result := {располагаема€} Trasp(helicopter, icT, icH0) / {потребна€} Trasp(helicopter, icT, HotV(helicopter, icG, icT, V))
end;

function ny(helicopter : THelicopter;icG, icT,icH0,V, Hrasch : Real): Real; overload;
begin
 Result := {располагаема€} Trasp(helicopter, icT, icH0, Hrasch) / {потребна€} Trasp(helicopter, icT, HotV(helicopter, icG, icT, V))
end;


function nyMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;
var
  i : Integer;
  TempResult : Real;
begin
  Result := -100500;

  for i:=0 to g_Vmax do
    begin
     with helicopter do
      TempResult := ny(helicopter,icG, icT,icH0,i);

     if TempResult > Result then
      Result := TempResult
    end;

end;

function gammaMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;
begin
  try
   Result := RadToDeg(ArcCos(1/nyMax(helicopter, icG, icT, icH0)))
  except                                                          // run executable to see effect of try-except!
   Result := 0;
   //ShowMessage('ѕри заданных услови€х невозможно вычислить допустимый угол крена');
  end;
end;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//c точностью до 1 км/ч
var
  i : Integer;
  diap : TDiapason;
begin
  diap := Diapason(helicopter, icG, icT);

  Result := 0;

  for i:=0 to g_Vmax do
   if diap[i] > h then
    Result := i;
end;


function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//c точностью до 1 км/ч
var
  i : Integer;
  diap : TDiapason;
begin
  diap := Diapason(helicopter, icG, icT);

  Result := 0;

  for i:=0 to g_Vmax do
   if diap[i] > h then
    begin
     Result := i-1;
     Break;
    end;
end;

function RealHst(helicopter : THelicopter; icG, icT : Real): Real;
var
  i : Integer;
  diap : TDiapason;
begin
  diap := Diapason(helicopter, icG, icT);

  Result := -100500;

  for i:=0 to g_Vmax do
   if diap[i] > Result then
    Result := diap[i];
end;

function VyRasp(helicopter : THelicopter; icG, icT, h0, V : Real) : Real;overload;
const
  smallnumber = 0.001;
var
 tempV : Real;
begin
 if Abs(V) <= smallnumber then
  tempV := smallnumber
 else
  tempV := V;

 Result := nx(helicopter, 1, icG, icT,h0,tempV)*tempV/g_mps;
end;

function VyRasp(helicopter : THelicopter; icG, icT, h0, Vnach, Vkon : Real) : Real;overload; //m/s
begin
  Result := Max(VyRasp(helicopter, icG, icT,h0,Vnach),VyRasp(helicopter, icG, icT,h0,Vkon));
end;

end.


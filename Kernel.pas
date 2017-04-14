unit Kernel;

interface

uses HelicoptersDatabase, Dialogs,Sysutils,World, GlobalConstants, Math;


type TDiapason = array [0..g_Vmax] of Real;

function HotV(helicopter : THelicopter; icG, icT,V: Real) : Real; overload; //характеризует диапазон высот и скоростей с учетом полетного веса и температуры

function Diapason(helicopter : THelicopter; icG, icT : Real) : TDiapason;overload; //просто сетка дл€ визуализации скорректированного диапазона

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;overload; //с учетом полетного веса и температуры
function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;  overload;
function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V, Cx : Real) : Real;  overload;

function ny(helicopter : THelicopter;icG, icT,icH0,V : Real):Real;
function nyMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;
function gammaMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//на высоте h c точностью до 1 км/ч
function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;

function RealHst(helicopter : THelicopter; icG, icT : Real): Real;

function VyRasp(helicopter : THelicopter; icG, icT, h0, Vnach, Vkon{km/h} : Real) : Real;overload; //m/s
function VyRasp(helicopter : THelicopter; icG, icT, h0, V{km/h}  : Real) : Real;overload;

implementation

function HotV(helicopter : THelicopter; V: Real) : Real;overload;
//характеризует диапазон высот и скоростей дл€ нормальных условий
begin
 Result := helicopter.Hdyn - Sqr(V-helicopter.ParabolaCoeff*helicopter.Vmax)*(helicopter.Hdyn-helicopter.Hst)/Sqr(helicopter.ParabolaCoeff*helicopter.Vmax)
end;

function Diapason (helicopter : THelicopter) : TDiapason;overload;  //просто сетка дл€ визуализации диапазона дл€ нормальных условий
var
  i : Integer;
begin
 for i:=0 to g_Vmax do
     Result[i] :=  HotV(helicopter, i)
end;

function HotV(helicopter : THelicopter;icG, icT, V: Real) : Real; overload;
var
   groundT, T,dH, H1 : Real;
const
 normT = 15;
begin
 H1 := HotV(helicopter,0);
 groundT := helicopter.TraspUZemli;
 T := (groundT - H1*helicopter.ctgTotH)*(icG/helicopter.Gnorm);

 if icT > normT then groundT := groundT-helicopter.TemperCoeff*(icT-normT);

 dH := (groundT-T)/helicopter.ctgTotH - H1;

  Result := HotV(helicopter,V) + dH;
end;

function Diapason (helicopter : THelicopter; icG, icT : Real) : TDiapason;overload;
var
 i : Integer;
begin
  for i:=0 to g_Vmax do
   Result[i] := HotV(helicopter,icG, icT,i)
end;

function inx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real): Real;

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
end;

function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real; overload;
//с учетом полетного веса и температуры
 begin
   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, 0);
 end;


function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;
//с учетом полетного веса, температуры и скороподъемности
 begin
   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, Vy);
 end;

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

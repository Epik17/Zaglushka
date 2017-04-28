unit Kernel;

interface

uses HelicoptersDatabase, Dialogs,Sysutils,World, GlobalConstants, Math;


type TDiapason = array [0..g_Vmax] of Real;

function HotV(helicopter : THelicopter; icG, icT,V: Real) : Real; overload; //������������� �������� ����� � ��������� � ������ ��������� ���� � �����������

function Diapason(helicopter : THelicopter; icG, icT : Real) : TDiapason;overload; //������ ����� ��� ������������ ������������������ ���������

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;overload; //� ������ ��������� ���� � �����������
function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;  overload;
function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V, Cx : Real) : Real;  overload;

function ny(helicopter : THelicopter;icG, icT,icH0,V : Real):Real;
function nyMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;
function gammaMax(helicopter : THelicopter;icG, icT,icH0 : Real): Real;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//�� ������ h c ��������� �� 1 ��/�
function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;

function RealHst(helicopter : THelicopter; icG, icT : Real): Real;

function VyRasp(helicopter : THelicopter; icG, icT, h0, Vnach, Vkon{km/h} : Real) : Real;overload; //m/s
function VyRasp(helicopter : THelicopter; icG, icT, h0, V{km/h}  : Real) : Real;overload;


function Trasp(helicopter : THelicopter; icT, icH0 : Real) : Real;
function HotTyagi(helicopter : THelicopter; icT, Tyaga : Real) : Real;

implementation

const
 normT = 15;

function HotV(helicopter : THelicopter; V: Real) : Real;overload;
//������������� �������� ����� � ��������� ��� ���������� �������
begin
 Result := helicopter.Hdyn - Sqr(V-helicopter.ParabolaCoeff*helicopter.Vmax)*(helicopter.Hdyn-helicopter.Hst)/Sqr(helicopter.ParabolaCoeff*helicopter.Vmax)
end;

function Diapason (helicopter : THelicopter) : TDiapason;overload;  //������ ����� ��� ������������ ��������� ��� ���������� �������
var
  i : Integer;
begin
 for i:=0 to g_Vmax do
     Result[i] :=  HotV(helicopter, i)
end;

function iUZemli(uzemli{��� 15 ��������}, tempcoeff, icT : Real) : Real;
begin
  Result := uzemli;

  if icT > normT then
    Result := Result - tempcoeff*(icT-normT)
end;

{
function TraspUZemli(helicopter : THelicopter; icT : Real) : Real;
begin
  Result := iUZemli(helicopter.TraspUZemli, helicopter.TemperCoeff, icT)
end;
 }

function fOtH(uzemli{��� 15 ��������}, tempcoeff, icT, icH0, ctg : Real) : Real;
begin
  Result := iUZemli(uzemli{��� 15 ��������}, tempcoeff, icT) - icH0 * ctg
end;

function Trasp(helicopter : THelicopter; icT, icH0 : Real) : Real;
begin
  //Result := TraspUZemli(helicopter, icT) - icH0 * helicopter.ctgTotH
  Result := fOtH(helicopter.TraspUZemli{��� 15 ��������}, helicopter.TemperCoeff, icT, icH0, helicopter.ctgTotH)
end;



//�������, �������� Trasp
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

function Ne(helicopter : THelicopter; icT, icH0 : Real) : Real;
const
  Neuzemli = 2000;
  termCoeffHotT = 50;
begin
  //Result := TraspUZemli(helicopter, icT) - icH0 * helicopter.ctgTotH
  Result := fOtH(Neuzemli{��� 15 ��������}, termCoeffHotT * helicopter.ctgNotH, icT, icH0, helicopter.ctgNotH)
end;

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

   Result :=  g_mps*(75 * (2 * (Ne(helicopter, icT, H1) - Ne(helicopter, icT, hManevraCurrent))))/(tempV*helicopter.Gnorm)
  end
 else
  ShowMessage('��� ���������� �������������� ���������� ���������� ������������ �������� �������� '+FloatToStr(V));

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
  ShowMessage('��� ���������� �������������� ���������� ���������� ������������ �������� �������� '+FloatToStr(V));
end;

//function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real; overload;
////� ������ ��������� ���� � �����������
// begin
//   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, 0);
// end;


function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;
//� ������ ��������� ����, ����������� � ����������������
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
    ShowMessage('��� �������� �������� ���������� ���������� ���������� ����������');

end;
    }
function ny(helicopter : THelicopter;icG, icT,icH0,V : Real): Real;

begin
 Result := {�������������} Trasp(helicopter, icT, icH0) / {���������} Trasp(helicopter, icT, HotV(helicopter, icG, icT, V))
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
   //ShowMessage('��� �������� �������� ���������� ��������� ���������� ���� �����');
  end;
end;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//c ��������� �� 1 ��/�
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


function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//c ��������� �� 1 ��/�
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


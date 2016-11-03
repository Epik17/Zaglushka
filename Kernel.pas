unit Kernel;

interface

uses HelicoptersDatabase, Dialogs,Sysutils,World, GlobalConstants, Math;


type TDiapason = array [0..g_Vmax] of Real;

function HotV(helicopter : THelicopter; V: Real) : Real; overload; //������������� �������� ����� � ��������� ��� ���������� �������
function HotV(helicopter : THelicopter; icG, icT,V: Real) : Real; overload; //������������� �������� ����� � ��������� � ������ ��������� ���� � �����������

function Diapason(helicopter : THelicopter; icG, icT : Real) : TDiapason;overload; //������ ����� ��� ������������ ������������������ ���������

function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;overload; //� ������ ��������� ���� � �����������
function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;

function ny(helicopter : THelicopter;icG, icT,icH0,V : Real):Real;

function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//�� ������ h c ��������� �� 1 ��/�
function VminOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;

function RealHst(helicopter : THelicopter; icG, icT : Real): Real;

function VyRasp(helicopter : THelicopter; icG, icT, h0, Vnach, Vkon{km/h} : Real) : Real;overload; //m/s
function VyRasp(helicopter : THelicopter; icG, icT, h0, V{km/h}  : Real) : Real;overload;

implementation


function HotV(helicopter : THelicopter; V: Real) : Real;
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
  ShowMessage('function nx: ������������ �������� �������� '+FloatToStr(V));
end;

function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;
//� ������ ��������� ���� � �����������
 begin
   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, 0);
 end;


function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V{km/h}, Vy{m/s} : Real) : Real;overload;
//� ������ ��������� ����, ����������� � ����������������
 begin
   Result := inx (helicopter, ny, icG, icT,hManevraCurrent,V{km/h}, Vy);
 end;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;
const
  Cx = 0.0115;
begin
  Result := Cx*helicopter.Fomet*AirDensity(hManevraCurrent)*Sqr(V/g_mps/2)/icG
end;

function ny(helicopter : THelicopter;icG, icT,icH0,V : Real): Real;
begin
  with helicopter do
   Result:= (TraspUZemli/ctgTotH-icH0)/(TraspUZemli-HotV(helicopter,icG, icT,V)*ctgTotH)
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

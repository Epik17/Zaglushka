unit Kernel;

interface

uses HelicoptersDatabase, Dialogs,Sysutils,World;

const
  maxV=360;

type TDiapason = array [0..maxV] of Real;

function HotV(helicopter : THelicopter; V: Real) : Real; overload; //������������� �������� ����� � ��������� ��� ���������� �������
function HotV(helicopter : THelicopter; icG, icT,V: Real) : Real; overload; //������������� �������� ����� � ��������� � ������ ��������� ���� � �����������
function Diapason(helicopter : THelicopter) : TDiapason;overload; //������ ����� ��� ������������ ��������� ��� ���������� �������
function Diapason(helicopter : THelicopter; icG, icT : Real) : TDiapason;overload; //������ ����� ��� ������������ ������������������ ���������
function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;overload; //� ������ ��������� ���� � �����������
function nx(helicopter : THelicopter; ny, icG, icT,hManevraCurrent,hManevraInitial,V : Real) : Real;overload; //� ������ ��������� ����, ����������� � ���� �������� �����
         //������ ������� nx �� ������������� � �������������; ����� ��������� �������� ���� ��� � ����� �������� ��
function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;
function ny(helicopter : THelicopter;icG, icT,icH0,V : Real):Real;
function VmaxOnAGivenHeight(helicopter : THelicopter; icG, icT, h : Real) : Integer;//�� ������ h c ��������� �� 1 ��/�

implementation

function HotV(helicopter : THelicopter; V: Real) : Real;
begin
 Result := helicopter.Hdyn - Sqr(V-helicopter.ParabolaCoeff*helicopter.Vmax)*(helicopter.Hdyn-helicopter.Hst)/Sqr(helicopter.ParabolaCoeff*helicopter.Vmax)
end;

function Diapason (helicopter : THelicopter) : TDiapason;
var
  i : Integer;
begin
 for i:=0 to maxV do
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
  for i:=0 to maxV do
   Result[i] := HotV(helicopter,icG, icT,i)
end;

function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,V : Real) : Real;
//� ������ ��������� ���� � �����������
begin
 Result :=0;

 if v>0 then
  with helicopter do
   Result := (540/Gnorm)*((TraspUZemli*(1-ny)/ctgTotH+HotV(helicopter,icG, icT,V)*ny-hManevraCurrent)*ctgNotH+0.0066*icG)/V
 else
  ShowMessage('function nx: ������������ �������� �������� '+FloatToStr(V));
end;

function nx (helicopter : THelicopter; ny, icG, icT,hManevraCurrent,hManevraInitial,V : Real) : Real;overload;
//� ������ ��������� ����, ����������� � ���� �������� �����; �� ������������� ���������: ����� ��������� ������
begin
  Result := nx(helicopter, ny, icG, icT,hManevraCurrent,V) - nx(helicopter, ny, icG, icT,hManevraInitial,V)
end;

function nxOtXvr(helicopter : THelicopter;hManevraCurrent,icG,V : Real) : Real;
const
  Cx = 0.0115;
begin
  Result := Cx*helicopter.Fomet*AirDensity(hManevraCurrent)*Sqr(V/3.6/2)/icG
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

  for i:=0 to maxV do
   if diap[i] > h then
    Result := i;

 { if Result = 0 then
   ShowMessage('����� �� ������� ��������� ����� � ���������'); }
end;

end.

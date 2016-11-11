unit InterfaceClasses;

interface

uses Contnrs,  // ����� ������� TObjectList
     Classes,
     Dialogs,
     SysUtils;

const

g_ParametersCount = 10;
//1: ���������, �
//2: ���������� �� �����
//3: ���������� �� ������
//4: ���� ������� ����������, ��������
//5: �������� ������, ��/�
//6: ���� ��� ������, ��������
//7: ��������� ����� ��� ������, ��������
//8: �������� �������� ��� �������, ��/�
//9: ������������ �������� ��� �������/������/�������, �/�
//10: ������������ �������� ��� ������/�������, �

g_HelicoptersCount = 6;
g_ManevrTypesCount = 9;
g_ManevrNames :array[1..g_ManevrTypesCount] of string = ('�������������� �����','�����','�����������','����� �����', '������ �����', '������ � ���������','������ � ������� ������','������������ �����','������������ �������');
g_HelicopterTypes : array [1..g_HelicoptersCount] of string = ('�����-�','��-26','��-226','��-28�','��-8���-5','��-8����');


type TManevrTypes = (mtUndefined, mtHorizFlight, mtGorka, mtPikirovanie,mtLeftVirage,mtRightVirage,
mtHorizRazgon,mtRazgonSnaborom, mtLiftOff, mtLanding);
type TParametersArray = array [1..g_ParametersCount] of Real;
type TArrayOfString = array of string;



type TManevr = class(TObject)
private
 fType : TManevrTypes;
    function GetType: TManevrTypes;
public
  fParameters : TParametersArray;

  constructor Create(aType : TManevrTypes);overload;
  constructor Create(aType : TManevrTypes; parameters:TParametersArray); overload;

  property pType : TManevrTypes read GetType;
  function ParametersString : string;

end;

type TManevrList = class(TObjectList)
  private
    function GetItems(i: Integer): TManevr;
    procedure SetItems(i: Integer; const Value: TManevr);
public
constructor Create(fileContent: TArrayOfString);overload;
property Items[i: Integer]: TManevr read GetItems write SetItems; default;


end;

function ConvertManevrType (aType : string) : TManevrTypes; overload;
function ConvertManevrType (aType : TManevrTypes) : string; overload;



implementation

{ TManevr }

constructor TManevr.Create(aType: TManevrTypes);
var
  i : Integer;
begin
 fType := aType;

 for i:=1 to Length(fParameters) do
  fParameters[i]:=i;
end;

constructor TManevr.Create(aType: TManevrTypes;
  parameters: TParametersArray);
  var
  i : Integer;
begin
   fType := aType;

 for i:=1 to Length(fParameters) do
  fParameters[i]:=parameters[i];
end;

function TManevr.GetType: TManevrTypes;
begin
 Result := fType;
end;


function ConvertManevrType (aType : string) : TManevrTypes; overload;
begin
    Result := mtUndefined;
    if aType = '�������������� �����' then Result := mtHorizFlight;
    if aType = '�����' then Result := mtGorka;
    if aType = '�����������' then Result := mtPikirovanie;
    if aType = '����� �����' then Result := mtLeftVirage;
    if aType = '������ �����' then Result := mtRightVirage;
    if aType = '������ � ���������' then Result := mtHorizRazgon;
    if aType = '������ � ������� ������' then Result := mtRazgonSnaborom;
    if aType = '������������ �����' then Result := mtLiftOff;
    if aType = '������������ �������' then Result := mtLanding;
end;

function ConvertManevrType (aType : TManevrTypes) : string; overload;
begin
   Result := '�� �����';

  case aType of
    mtHorizFlight : Result := '�������������� �����';
    mtGorka : Result := '�����';
    mtPikirovanie : Result := '�����������';
    mtLeftVirage : Result := '����� �����';
    mtRightVirage :  Result := '������ �����';
    mtHorizRazgon :  Result := '������ � ���������';
    mtRazgonSnaborom :  Result := '������������ �����';
    mtLiftOff :  Result := '������ � ������� ������';
    mtLanding :  Result := '������������ �������';
  end;
end;


{ TManevrList }

constructor TManevrList.Create(fileContent: TArrayOfString);
   var
  ManevrCount, i,j,k : Byte;
  ManevrType : TManevrTypes;
  Manevr : TManevr;
  Parameters : TParametersArray;
begin
  ManevrCount := StrToInt(fileContent[0]);

  for i:=0 to ManevrCount-1 do
    begin
     ManevrType := ConvertManevrType(fileContent[(g_ParametersCount+1)*i+1]);

     k:=1;

     for j := 2+i*(g_ParametersCount+1) to 2+(g_ParametersCount+1)*i+(g_ParametersCount-1) do
       begin
        Parameters[k]:= StrToFloat(StringReplace(fileContent[j],'.',',',[rfReplaceAll]));

        Inc(k);
       end;


     Manevr := TManevr.Create(ManevrType,Parameters);

     Self.Add(Manevr)
    end;

end;


function TManevrList.GetItems(i: Integer): TManevr;
begin
  Result := TManevr(inherited GetItem(i));
end;

function TManevr.ParametersString: string;
var i:Byte;
begin
 Result :='';

 for i:=1 to g_ParametersCount do
  Result := Result + ' ' + FloatToStr(fParameters[i]);
end;

procedure TManevrList.SetItems(i: Integer; const Value: TManevr);
begin
  inherited SetItem(i, Value);
end;

end.

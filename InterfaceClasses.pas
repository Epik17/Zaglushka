unit InterfaceClasses;

interface

uses Contnrs,  // чтобы работал TObjectList
     Classes,
     Dialogs,
     SysUtils;

const

g_ParametersCount = 12;
//1: Дальность, м
//2: Перегрузка на вводе
//3: Перегрузка на выводе
//4: Угол наклона траектории, градусов
//5: Скорость вывода, км/ч
//6: Крен при вираже, градусов
//7: Изменение курса при вираже, градусов
//8: Конечная скорость при разгоне/торможении, км/ч
//9: Вертикальная скорость при разгоне/взлете/посадке/спирали, м/с
//10: Вертикальное смещение при взлете/посадке/накл.наборе/накл.снижении, м
//11: Продолжительность висения, с
//12: Темп ввода в крен, град/с

g_ManevrTypesCount = 19;
g_ManevrNames :array[1..g_ManevrTypesCount] of string = (
{1}'Горизонтальный полет',
{2}'Горка',
{3}'Пикирование',
{4}'Левый вираж',
{5}'Правый вираж',
{6}'Разгон/торможение в горизонте',
{7}'Разгон/торможение с изм. высоты',
{8}'Вертикальный взлет',
{9}'Вертикальная посадка',
{10}'Висение',
{11}'Левая спираль',
{12}'Правая спираль',
{13}'Левый форсированный вираж',
{14}'Правый форсированный вираж',
{15}'Набор высоты по наклонной',
{16}'Снижение по наклонной',
{17}'Петля Нестерова',
{18}'Левый разворот на горке',
{19}'Правый разворот на горке');

type TManevrTypes = (mtUndefined, mtHorizFlight, mtGorka, mtPikirovanie,mtLeftVirage,mtRightVirage,
mtHorizRazgonTormozh,mtRazgonSnaborom, mtLiftOff, mtLanding, mtHovering,mtLeftSpiral,mtRightSpiral,
mtLeftForcedVirage,mtRightForcedVirage,mtNaklNabor, mtNaklSnizhenie, mtNesterov, mtLeftRazvNaGorke, mtRightRazvNaGorke);
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
    if aType = 'Горизонтальный полет' then Result := mtHorizFlight;
    if aType = 'Горка' then Result := mtGorka;
    if aType = 'Пикирование' then Result := mtPikirovanie;
    if aType = 'Левый вираж' then Result := mtLeftVirage;
    if aType = 'Правый вираж' then Result := mtRightVirage;
    if aType = 'Разгон/торможение в горизонте' then Result := mtHorizRazgonTormozh;
    if aType = 'Разгон/торможение с изм. высоты' then Result := mtRazgonSnaborom;
    if aType = 'Вертикальный взлет' then Result := mtLiftOff;
    if aType = 'Вертикальная посадка' then Result := mtLanding;
    if aType = 'Висение' then Result := mtHovering;
    if aType = 'Левая спираль' then Result := mtLeftSpiral;
    if aType = 'Правая спираль' then Result := mtRightSpiral;
    if aType = 'Левый форсированный вираж' then Result := mtLeftForcedVirage;
    if aType = 'Правый форсированный вираж' then Result := mtRightForcedVirage;
    if aType = 'Набор высоты по наклонной' then Result := mtNaklNabor;
    if aType = 'Снижение по наклонной' then Result := mtNaklSnizhenie;
    if aType = 'Петля Нестерова' then Result := mtNesterov;
    if aType = 'Левый разворот на горке' then Result := mtLeftRazvNaGorke;
    if aType = 'Правый разворот на горке' then Result := mtRightRazvNaGorke;
end;

function ConvertManevrType (aType : TManevrTypes) : string; overload;
begin
   Result := 'Не задан';

  case aType of
    mtHorizFlight : Result := 'Горизонтальный полет';
    mtGorka : Result := 'Горка';
    mtPikirovanie : Result := 'Пикирование';
    mtLeftVirage : Result := 'Левый вираж';
    mtRightVirage :  Result := 'Правый вираж';
    mtHorizRazgonTormozh :  Result := 'Разгон/торможение в горизонте';
    mtRazgonSnaborom :  Result := 'Разгон/торможение с изм. высоты';
    mtLiftOff :  Result := 'Вертикальный взлет';
    mtLanding :  Result := 'Вертикальная посадка';
    mtHovering :  Result := 'Висение';
    mtLeftSpiral :  Result :=  'Левая спираль';
    mtRightSpiral :  Result := 'Правая спираль';
    mtLeftForcedVirage : Result := 'Левый форсированный вираж';
    mtRightForcedVirage :  Result := 'Правый форсированный вираж';
    mtNaklNabor : Result := 'Набор высоты по наклонной';
    mtNaklSnizhenie : Result := 'Снижение по наклонной';
    mtNesterov : Result := 'Петля Нестерова';
    mtLeftRazvNaGorke : Result := 'Левый разворот на горке';
    mtRightRazvNaGorke : Result := 'Правый разворот на горке';
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

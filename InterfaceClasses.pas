unit InterfaceClasses;

interface

uses Contnrs,  // чтобы работал TObjectList
     Classes,
     Dialogs,
     SysUtils;

const

g_ParametersCount = 10;
//1: Дальность, м
//2: Перегрузка на вводе
//3: Перегрузка на выводе
//4: Угол наклона траектории, градусов
//5: Скорость вывода, км/ч
//6: Крен при вираже, градусов
//7: Изменение курса при вираже, градусов
//8: Конечная скорость при разгоне, км/ч
//9: Вертикальная скорость при разгоне/взлете/посадке, м/с
//10: Вертикальное смещение при взлете/посадке, м

g_HelicoptersCount = 6;
g_ManevrTypesCount = 9;
g_ManevrNames :array[1..g_ManevrTypesCount] of string = ('Горизонтальный полет','Горка','Пикирование','Левый вираж', 'Правый вираж', 'Разгон в горизонте','Разгон с набором высоты','Вертикальный взлет','Вертикальная посадка');
g_HelicopterTypes : array [1..g_HelicoptersCount] of string = ('Ансат-У','Ми-26','Ка-226','Ми-28Н','Ми-8МТВ-5','Ми-8АМТШ');


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
    if aType = 'Горизонтальный полет' then Result := mtHorizFlight;
    if aType = 'Горка' then Result := mtGorka;
    if aType = 'Пикирование' then Result := mtPikirovanie;
    if aType = 'Левый вираж' then Result := mtLeftVirage;
    if aType = 'Правый вираж' then Result := mtRightVirage;
    if aType = 'Разгон в горизонте' then Result := mtHorizRazgon;
    if aType = 'Разгон с набором высоты' then Result := mtRazgonSnaborom;
    if aType = 'Вертикальный взлет' then Result := mtLiftOff;
    if aType = 'Вертикальная посадка' then Result := mtLanding;
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
    mtHorizRazgon :  Result := 'Разгон в горизонте';
    mtRazgonSnaborom :  Result := 'Вертикальный взлет';
    mtLiftOff :  Result := 'Разгон с набором высоты';
    mtLanding :  Result := 'Вертикальная посадка';
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

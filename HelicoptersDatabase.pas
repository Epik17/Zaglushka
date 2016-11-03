unit HelicoptersDatabase;

interface

type THelicopter = record
Fomet, //ометаема€ площадь, м2
Gnorm, //нормальный полетный вес, кг
TraspUZemli, //располагаема€ т€га у земли, кг
nyMin, //минимальна€ нормальна€ скоростна€ перегрузка
nyMax, //максимальна€ нормальна€ скоростна€ перегрузка
ctgTotH,  //котангенс угла наклона графика т€ги Ќ¬ как функции высоты
ctgNotH,  //котангенс угла наклона графика мощности силовой установки как функции высоты
Hst,  //статический потолок, м
Hdyn,  //динамический потолок, м
Vmax, //максимальна€ скорость, км/ч
TemperCoeff, //температурный коэффициент
ParabolaCoeff, //коэффициент параболы, которой моделируетс€ диапазон высот и скоростей
Gmin, //минимальный полетный вес
Gmax : Real; //максимальный полетный вес
end;

type THelicoptersDatabase = array [1..2] of THelicopter;
type THelicopterParameters = array [1..14] of Real;
function CreateHelicopter (params: THelicopterParameters) : THelicopter;

const
mi8 : THelicopterParameters = (356,12000,10800,0.5,1.5,1.036,0.15,-100,4500,250,60,0.5,11000,12500);
mi81 : THelicopterParameters = (356,12500,11800,0.5,1.5,1.036,0.15,1000,4000,250,60,0.5,11000,12800);

implementation
function CreateHelicopter (params: THelicopterParameters) : THelicopter;
begin
 with Result do
 begin
    Fomet := params[1];
    Gnorm := params[2];
    TraspUZemli := params[3];
    nyMin := params[4];
    nyMax := params[5];
    ctgTotH := params[6];
    ctgNotH := params[7];
    Hst := params[8];
    Hdyn := params[9];
    Vmax := params[10];
    TemperCoeff := params[11];
    ParabolaCoeff := params[12];
    Gmin := params[13];
    Gmax := params[14];
 end;
end;

end.
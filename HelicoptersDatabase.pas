unit HelicoptersDatabase;

interface

type THelicopter = record
Name: string;
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

type THelicoptersDatabase = array [1..8] of THelicopter;
type THelicopterParameters = array [1..14] of Real;
function CreateHelicopter (aname: string;params: THelicopterParameters) : THelicopter;

const
//mi8 : THelicopterParameters = (356,12000,10800,0.5,1.5,1.036,0.15,-100,4500,250,60,0.5,11000,12500);
ansatU : THelicopterParameters = (103.8,3000,4080,0.5,2.7,0.29,0.1,3200,5200,275,30,0.382,2800,3600);
mi26 : THelicopterParameters = (800,49600,52000,0.5,1.5,4.4,1.81,1420,4600,295,496,0.424,48000,50000);
mi8mtv : THelicopterParameters = (356,12000,13420,0.5,1.5,1.0,0.24,3980,6000,250,120,0.37,11000,12500);
mi8mtv5tv3117vm : THelicopterParameters = (356,13000,13700,0.5,1.5,1.0,0.234,3980,6000,250,130,0.3672,12000,13500);
mi8mtv5vk2500 : THelicopterParameters = (356,13000,15200,0.5,1.5,0.77143,0.08,4300,6000,250,130,0.3474,12000,15500);
mi28 : THelicopterParameters = (232,11000,13852,0.5,2.8,0.922,0.28,2950,5250,305,110,0.4,10800,11500);
ka226 : THelicopterParameters = (132,3100,3920,0.5,1.5,0.315,0.1077,2600,6500,210,31,0.444,3000,3500);


implementation
function CreateHelicopter (aname: string; params: THelicopterParameters) : THelicopter;
begin
 with Result do
 begin
    Name := aname;
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
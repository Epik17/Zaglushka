unit frmPlot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,FlightData, TeEngine, Series, ExtCtrls, TeeProcs, Chart, GlobalConstants, Math,
  StdCtrls;

type
  Tfrm_Plot = class(TForm)
    cht_plot: TChart;
    Series1: TLineSeries;
    cbb_parameter: TComboBox;
    procedure cbb_parameterSelect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Plot: Tfrm_Plot;


procedure plotParameterVsTime (manevrdata : TManevrData; parameter : TParametersNames);
function cbbParameterItemIndexToParameter (index : Integer) : TParametersNames;

implementation

uses frmInterface;

function cbbParameterItemIndexToParameter (index : Integer) : TParametersNames;
begin

  Result := x;

   if index = 0 then
    Result := x
   else
    if index = 1 then
     Result := y
    else
     if index = 2 then
        Result := z
      else
       if index = 3 then
        Result := theta
       else
         if index = 4 then
           Result := gamma
         else
          if index = 5 then
            Result := psi
          else
            if index = 6 then
              Result := V
            else
             if index = 7 then
               Result := ny;
end;

procedure plotParameterVsTime (manevrdata : TManevrData; parameter : TParametersNames);
var i : Integer;
    parametervalue : Real;

  begin
    parametervalue := 0;
    frm_Plot.cht_plot.Series[0].Clear;

    for i := 0 to High(manevrdata) do
     begin
      case parameter of    //(x, y, z, theta, gamma, psi, V, ny, nx
       x: parametervalue := manevrdata[i].x;
       y: parametervalue := manevrdata[i].y;
       z: parametervalue := manevrdata[i].z;
       theta: parametervalue := RadToDeg(manevrdata[i].theta);
       gamma: parametervalue := RadToDeg(manevrdata[i].gamma);
       psi: parametervalue := RadToDeg(manevrdata[i].psi);
       V: parametervalue := manevrdata[i].V * g_mps;
       ny: parametervalue := manevrdata[i].ny;
      end;

      frm_Plot.cht_plot.Series[0].AddXY(manevrdata[i].t,{manevrdata[i].psi}parametervalue)
     end;


  end;

{$R *.dfm}

procedure Tfrm_Plot.cbb_parameterSelect(Sender: TObject);
begin
 frm_Interface.btn_CalcutateClick(Self)
end;

end.

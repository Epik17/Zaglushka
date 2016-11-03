unit frmInterface;
          //TODO
{
 -----foolproof:--------------
 ny(V) dependencies:
  - gamma(V) in Virage
  - ny in Gorka, Pikirovanie
 -----------------------------

- add Desceleration

- add theta = arctan(nx) in GorkaPikirovanie and Razgon/Desceleration

- reliable isometric projection (equal axis scales, min/max X and Z, range, etc. !! )

- first V<0 message must stop all posterior calculations and appending of manoeuvres! We apparently need g_failed in appending

- add TSaveDialog

- fix incorrect psi in Virage (360 and self-crossing of trajectory) 
}


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,InterfaceClasses, HelicoptersDatabase,FlightData,Manoeuvres,Menus, Grids, ComCtrls,
  ExtCtrls,Kernel, TeeProcs, TeEngine, Chart, Series,Matrix_preobraz,Matrixes,MyTypes,Math,shellapi, GlobalConstants;


type TButtonMode = (bmAdd,bmUpdate);

type
  Tfrm_Interface = class(TForm)
    lst_Manevry: TListBox;
    cbb_Manevry: TComboBox;
    btn_AddManevr: TButton;
    pm_Manevry: TPopupMenu;
    DeleteManevr: TMenuItem;
    cbb_HelicopterType: TComboBox;
    btn_ExportFlightTask: TButton;
    btn_ImportFlightTask: TButton;
    dlgOpenFile: TOpenDialog;
    Memo1: TMemo;
    trckbr_H0: TTrackBar;
    lbl_H0name: TLabel;
    lbl_H0value: TLabel;
    trckbr_G: TTrackBar;
    lbl_Gname: TLabel;
    lbl_Gvalue: TLabel;
    trckbr_T: TTrackBar;
    lbl_Tname: TLabel;
    lbl_Tvalue: TLabel;
    btn_Calcutate: TButton;
    cht_DiapNXNY: TChart;
    Series1: TLineSeries;
    cht_traj: TChart;
    Series2: TPointSeries;
    rg_view: TRadioGroup;
    rg_xarak: TRadioGroup;
    btn_ExportCalculatedTask: TButton;
    lblV0: TLabel;
    lblV0value: TLabel;
    trckbrV0: TTrackBar;
    lbl_RecalcNeeded: TLabel;
    strngrd_ManevrInfo: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure cbb_ManevryChange(Sender: TObject);
    procedure btn_AddManevrClick(Sender: TObject);
    procedure DeleteManevrClick(Sender: TObject);
    procedure btn_ExportFlightTaskClick(Sender: TObject);
    procedure btn_ImportFlightTaskClick(Sender: TObject);
    procedure lst_ManevryMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbb_HelicopterTypeSelect(Sender: TObject);
    procedure SetInitialConditionsTrackbars;
    procedure SetICTrackbar (var trackbar : TTrackBar; amin,amax,aposition : Real);
    procedure DrawDiapason(var cht: TChart;
  helicopter: THelicopter; icG, icT: Real);
  procedure DrawNY(var cht: TChart;
  helicopter: THelicopter; icG, icT, icH0: Real);
  procedure DrawNX(var cht: TChart;
  helicopter: THelicopter; icG, icT, icH0: Real);
  procedure DrawCharacs(var cht: TChart;
  helicopter: THelicopter; icG, icT, icH0: Real);

    procedure rg_viewClick(Sender: TObject);
    procedure rg_xarakClick(Sender: TObject);
    procedure btn_ExportCalculatedTaskClick(Sender: TObject);
    procedure btn_CalcutateClick(Sender: TObject);



  private
    { Private declarations }
  public
    { Public declarations }
  procedure DrawTrajectory(var cht: TChart;
  FlightData : TFlightData); 
    procedure CreateLabeledScrollbars(names:TArrayOfString; multipliers:TArrayOfReal; mins : TArrayOfInteger; maxes : TArrayOfInteger); overload;
    procedure CreateLabeledScrollbars(ManevrType : TManevrTypes);overload;
    procedure DynamicallyUpdateLabelValues (Sender: TObject);
    procedure ResetElementsArrays;
    procedure UpdateValuesFromTManevr;
    procedure DynamicallyUpdateICLabelValuesAndPlots(Sender: TObject);
    procedure ExportFlightTask(manevrlist : TManevrList);
    procedure ExportCalculatedFlightTask (FlightData : TFlightData);
    function g_H0 () : Real;
    function g_V0 () : Real;
    function g_T () : Real;
    function g_G () : Real;
    procedure AppendTempManevr (tempManevr : TManevr);
    procedure RecalculateRedrawFromManevrList;
    procedure FlightDataInitialization;
    procedure DynamicFoolProtection;
    procedure FullRecalculate(Sender: TObject);
    procedure DisableCalculateButton;
    procedure EnableCalculateButton;
    procedure CollectTrackBarsData(var ParamArray : TParametersArray);
    procedure UpdateManevrList(var manevrlist: TManevrList);
    procedure DynamicallyChangeV0max;
    procedure AddModeOn;
    procedure UpdateModeOn;
    procedure CreateManevrInfoGrid;
    procedure ShowManevrInfo(manevr : TManevrData; colNo : Byte);overload;
    procedure ShowManevrInfo;overload;
  end;

var
 frm_Interface: Tfrm_Interface;
 g_ManevrList : TManevrList;
 g_TrackBars: array of TTrackBar;
 g_NameLabels : array of TLabel;
 g_ValueLabels : array of TLabel;
 g_Multipliers : TArrayOfReal;
 g_ButtonMode : TButtonMode;
 g_HelicopterDatabase : THelicoptersDatabase;
 g_Helicopter : THelicopter;
 g_FlightData : TFlightData;
 g_nxVisited : Boolean = False;

const
Tmin = -40; //minimal outboard temperature
Tmax = 40;  //maximal outboard temperature
Tdefault = 15; //default outboard temperature
deltaH0 = 25; //H0 increment



function ManevrTypeToNumber (aType : string) : Integer;
function HelicopterTypeToNumber (aType : string) : Integer;
procedure HelicoptersInitialization;





implementation


{$R *.dfm}

procedure Tfrm_Interface.FlightDataInitialization;
begin
   SetLength(g_FlightData,1);
   SetLength(g_FlightData[0],1);

    with g_FlightData[0,0] do
     begin
      x :=0;
      y := g_H0;
      z :=0;
      theta :=0;
      gamma := 0;
      psi :=DegToRad(45);
      V := g_V0/g_mps;
      ny :=1;
      t :=0;
     end

end;

procedure Tfrm_Interface.FormCreate(Sender: TObject);
var
  i : Byte;

begin

 for i:=1 to Length(g_ManevrNames) do
   cbb_Manevry.Items.Add(g_ManevrNames[i]);

 g_ManevrList := TManevrList.Create;

 for i:=1 to Length(g_HelicopterTypes) do
   cbb_HelicopterType.Items.Add(g_HelicopterTypes[i]);

   ResetElementsArrays;

   AddModeOn;

   HelicoptersInitialization;

   cbb_HelicopterType.ItemIndex :=5; // choosing Mi-81
   cbb_HelicopterTypeSelect(Self);



   FlightDataInitialization;

   DisableCalculateButton;

   CreateManevrInfoGrid;

end;

procedure Tfrm_Interface.cbb_ManevryChange(Sender: TObject);
begin
 if cbb_Manevry.ItemIndex = -1
 then
  btn_AddManevr.Enabled := False
 else
  begin
   btn_AddManevr.Enabled := True;

   CreateLabeledScrollbars(ConvertManevrType(cbb_Manevry.Items[cbb_Manevry.ItemIndex]));

   AddModeOn;
  end
end;

 procedure Tfrm_Interface.AppendTempManevr (tempManevr : TManevr);
 var
   TempManevrData : TManevrData;
   laststate : TStateVector;
 begin
   laststate := g_FlightData[High(g_FlightData)][High(g_FlightData[High(g_FlightData)])];

   case tempManevr.pType of

        mtHorizFlight :
         TempManevrData:=HorizFlight(laststate,tempManevr.fParameters[1]);

        mtGorka :
         TempManevrData:=Gorka(g_Helicopter, laststate,g_G,g_T,tempManevr.fParameters[2],tempManevr.fParameters[3],tempManevr.fParameters[4],tempManevr.fParameters[5]);

        mtPikirovanie :
         TempManevrData:=Pikirovanie(g_Helicopter, laststate,g_G,g_T,tempManevr.fParameters[2],tempManevr.fParameters[3],-tempManevr.fParameters[4],tempManevr.fParameters[5]);

        mtLeftVirage :
         TempManevrData:=Virage(g_Helicopter,laststate, g_G, g_T,tempManevr.fParameters[6], tempManevr.fParameters[7]);

        mtRightVirage :
         TempManevrData:=Virage(g_Helicopter,laststate, g_G, g_T,tempManevr.fParameters[6], -tempManevr.fParameters[7]);

        mtHorizRazgon :
         TempManevrData:=HorizRazgon(g_Helicopter,laststate,g_G, g_T,tempManevr.fParameters[8]);

        mtRazgonSnaborom :
         TempManevrData:=RazgonSnaborom(g_Helicopter,laststate,g_G, g_T,tempManevr.fParameters[8],tempManevr.fParameters[9]);
    end;

   if Length(TempManevrData) > 0 then
    //if there were no errors during the calculation of TempManevrData
     AppendManevrData(g_FlightData,TempManevrData,g_Helicopter);


 end;

procedure Tfrm_Interface.btn_AddManevrClick(Sender: TObject);
var
  tempManevr : TManevr;
  ParamArray : TParametersArray;
  temp_g_FlightDataLength : Integer;

begin

//adding
 if g_ButtonMode = bmAdd then
   begin
     CollectTrackBarsData(ParamArray);

     tempManevr := TManevr.Create(ConvertManevrType(cbb_Manevry.Items[cbb_Manevry.ItemIndex]),ParamArray);

    //calculating task and appending it
      if g_ManevrList.Count =0 then
        SetLength(g_FlightData,1);

     temp_g_FlightDataLength := Length(g_FlightData);

     AppendTempManevr(tempManevr);

    if Length(g_FlightData) = temp_g_FlightDataLength then
     ShowMessage('Уточните исходные данные либо удалите маневр из списка');


      g_ManevrList.Add(tempManevr);

      lst_Manevry.Items.Add(ConvertManevrType(tempManevr.pType));

      lst_Manevry.ItemIndex := lst_Manevry.Count-1;

   end

 else

 //updating
 if lst_Manevry.Count > 0 then
  if (g_ButtonMode = bmUpdate) and (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = lst_Manevry.Items[lst_Manevry.ItemIndex]) then
    begin
      // updating parameters of SELECTED manoeuvre
      UpdateManevrList(g_ManevrList);

      // since one manoeuvre is updated we need to recalculate all manoeuvres in the flight task
      RecalculateRedrawFromManevrList;
    end;


 pm_Manevry.AutoPopup := True;

 UpdateModeOn;

 DrawTrajectory(cht_traj,g_FlightData);

 if Length(g_FlightData)-1 = lst_Manevry.Count then
  ShowManevrInfo;

end;

procedure Tfrm_Interface.DeleteManevrClick(Sender: TObject);
var
  tempindex,i : Integer;
begin

 if lst_Manevry.ItemIndex <> -1 then
 begin
   //ShowMessage('Маневр '+ConvertManevrType((g_ManevrList[lst_Manevry.ItemIndex] as TManevr).pType)+' будет удален!');
   tempindex := lst_Manevry.ItemIndex;
   g_ManevrList.Delete(lst_Manevry.ItemIndex);

   lst_Manevry.DeleteSelected;

  if (tempindex = 0) and (lst_Manevry.Count > 0) then
    begin
     lst_Manevry.ItemIndex := tempindex; //selecting the next manoeuvre and its parameters
     UpdateValuesFromTManevr
    end
  else
   if (tempindex = 0) and (lst_Manevry.Count = 0) then  //if only one is left
    begin
      cbb_Manevry.ItemIndex :=-1;
      btn_AddManevr.Enabled := False;

      
      for i:=0 to High(g_TrackBars) do //deleting parameters
      begin
       g_TrackBars[i].Visible :=False;
       g_NameLabels[i].Visible :=False;
       g_ValueLabels[i].Visible :=False;

       pm_Manevry.AutoPopup := False;
      end;
    end
   else
   lst_Manevry.ItemIndex := tempindex-1; //selecting the next manoeuvre and its parameters

   UpdateValuesFromTManevr;

   RecalculateRedrawFromManevrList;

   if Length(g_FlightData)-1 = lst_Manevry.Count then
    ShowManevrInfo;
 end;

end;



procedure Tfrm_Interface.btn_ExportFlightTaskClick(Sender: TObject);
begin
if g_ManevrList.Count > 0 then
 ExportFlightTask(g_ManevrList)
end;

procedure Tfrm_Interface.btn_ImportFlightTaskClick(Sender: TObject);
var
  i:Integer;
  ManevrsLines : TArrayOfString;
const
  manevrInfoStartLineIndex = 5;
begin
if dlgOpenFile.Execute then
    begin
      Memo1.Lines.LoadFromFile(dlgOpenFile.FileName);
      try  // run the executable to see effect!
         begin
          //reading initial conditions
          cbb_HelicopterType.ItemIndex := HelicopterTypeToNumber(Memo1.Lines[0]);
          trckbr_G.Position := StrToInt(Memo1.Lines[1]);
          trckbr_H0.Position := Round(StrToFloat(Memo1.Lines[2])/deltaH0);
          trckbr_T.Position := StrToInt(Memo1.Lines[3]);
          trckbrV0.Position := StrToInt(Memo1.Lines[4]);

          //reading manoeuvres info
          g_ManevrList.Clear;
          g_ManevrList.Free;

          lst_Manevry.Clear;

          SetLength(ManevrsLines,Memo1.Lines.Count-manevrInfoStartLineIndex);

          for i:=manevrInfoStartLineIndex to Memo1.Lines.Count-1 do
            ManevrsLines[i-manevrInfoStartLineIndex] :=Memo1.Lines[i];



          g_ManevrList := TManevrList.Create(ManevrsLines);

          for i:=0 to g_ManevrList.Count-1 do
           lst_Manevry.Items.Add(ConvertManevrType(g_ManevrList[i].pType));


          lst_Manevry.ItemIndex := 0;
          pm_Manevry.AutoPopup := True;

          UpdateValuesFromTManevr;

          RecalculateRedrawFromManevrList;

          if Length(g_FlightData)-1 = lst_Manevry.Count then
           ShowManevrInfo;

         end;
      except
        ShowMessage('Некорректная структура файла');
      end

    end;

end;

procedure Tfrm_Interface.CreateLabeledScrollbars(names:TArrayOfString; multipliers:TArrayOfReal; mins : TArrayOfInteger; maxes : TArrayOfInteger);
var
  i,L : Byte;
const
  startleft = 415;
  starttop = 40;
begin
   //очищаем массивы
  if Length(g_TrackBars) > 0 then
   begin
     L := Length(g_TrackBars);
     for i:=0 to L-1 do
      begin
        g_TrackBars[i].Free;
        g_NameLabels[i].Free;
        g_ValueLabels[i].Free;
      end;

     ResetElementsArrays;

   end;


  if (Length(names)=Length(multipliers)) and (Length(multipliers)=Length(mins)) and (Length(mins)=Length(maxes)) then
   begin
     L := Length(names);
   SetLength(g_TrackBars,L);
   SetLength(g_NameLabels,L);
   SetLength(g_ValueLabels,L);
   SetLength(g_Multipliers,L);

   for i:=0 to L-1 do
      begin
        g_NameLabels[i]:=TLabel.Create(self);
        with g_NameLabels[i] do
         begin
           Parent:=Self;
           Top:=starttop+i*30;
           Left:=startleft;
           Height :=17;
           Width:=25;
           Caption := names[i];
           Visible :=True;
         end;

         g_TrackBars[i]:=TTrackBar.Create(self);
         with g_TrackBars[i] do
            begin
               Parent:=Self;
               Top:=starttop+i*30;
               Left:=startleft+100;
               Max:=maxes[i];
               Position:=mins[i];
               TickStyle:=tsNone;
               ThumbLength:=10;
               Height :=17;
               Width:=90;
               OnChange:= DynamicallyUpdateLabelValues;
               Visible :=True;
               Min:=mins[i]; 
            end;

        g_ValueLabels[i]:=TLabel.Create(self);
        with g_ValueLabels[i] do
         begin
           Parent:=Self;
           Top:=starttop+i*30;
           Left:=startleft+200;
           Height :=17;
           Width:=25;
           Visible :=True;

           g_Multipliers[i]:= multipliers[i];
           Caption := FloatToStr(g_Multipliers[i]*g_TrackBars[i].Position);
         end;
      end;
   end
  else
   ShowMessage('procedure Tfrm_Interface.CreateLabeledScrollbars: Неравные длины массивов скроллбаров и меток!');
end;

procedure Tfrm_Interface.CreateLabeledScrollbars(ManevrType: TManevrTypes);
var
 count:Byte;
 names: TArrayOfString;
 multipliers : TArrayOfReal;
 mins, maxes : TArrayOfInteger;

  procedure MySetLength(count: Byte);
  begin
   SetLength(multipliers,count);
   SetLength(names,count);
   SetLength(mins,count);
   SetLength(maxes,count);
  end;

begin
 if ManevrType = mtHorizFlight then
 begin
  count :=1;
  MySetLength(count);

  multipliers[0]:=100;
  mins[0]:=1;
  names[0]:='Дальность, м';
  maxes[0]:=20;
 end;

  if (ManevrType = mtGorka) or (ManevrType = mtPikirovanie) then
     begin
      count :=4;
      MySetLength(count);

      names[0]:='ny ввода';
      names[1]:='ny вывода';
      names[2]:='Накл. тракт., град.';
      names[3]:='Скор. вывода, км/ч';

      multipliers[0]:=0.01;
      multipliers[1]:=0.01;
      multipliers[2]:=1;
      multipliers[3]:=1;


      mins[2]:=20;

      maxes[2]:=30;
     end;

     if (ManevrType = mtGorka) then
      begin
       mins[0]:=110;
       mins[1]:=50;
       mins[3]:=110;

       maxes[0]:=170;
       maxes[1]:=90;
       maxes[3]:=130;
      end;

      if (ManevrType = mtPikirovanie) then
      begin
       mins[0]:=50;
       mins[1]:=110;
       mins[3]:=200;

       maxes[0]:=90;
       maxes[1]:=170;
       maxes[3]:=Round(0.95*g_Helicopter.Vmax)-1;
      end;


  if (ManevrType = mtLeftVirage) or (ManevrType = mtRightVirage)then
 begin
  count :=2;
  MySetLength(count);

  multipliers[1]:=1;
  mins[1]:=1;
  names[1]:='Изм-е курса, град';
  maxes[1]:=720;

  multipliers[0]:=1;
  mins[0]:=10;
  names[0]:='Крен';
  maxes[0]:=45;
 end;

  if ManevrType = mtHorizRazgon then
 begin
  count :=1;
  MySetLength(count);

  multipliers[0]:=1;
  mins[0]:=Round(1.05*g_FlightData[0][0].V*g_mps);
  names[0]:='Макс. скор., км/ч';
  maxes[0]:=Round(0.95*g_Helicopter.Vmax)-1;
 end;

 if ManevrType = mtRazgonSnaborom then
   begin
    count :=2;
    MySetLength(count);

    multipliers[0]:=1;
    mins[0]:=Round(1.05*g_FlightData[0][0].V*g_mps);
    names[0]:='Макс. скор., км/ч';
    maxes[0]:=Round(0.95*g_Helicopter.Vmax)-1;

    multipliers[1]:=0.5;
    mins[1]:=2;
    names[1]:='Верт. скор., м/с';
    maxes[1]:=10;
   end;

  CreateLabeledScrollbars(names, multipliers, mins, maxes);
end;

procedure Tfrm_Interface.ResetElementsArrays;
begin
   SetLength(g_TrackBars,0);
   SetLength(g_NameLabels,0);
   SetLength(g_ValueLabels,0);
   SetLength(g_Multipliers,0);
end;

procedure Tfrm_Interface.UpdateValuesFromTManevr;
 var
  SelectedManevr : TManevr;
  SelectedIndex, i : Integer; //number of the selected manoeuvre in the cbb and in a TManevrList object
begin
if lst_Manevry.ItemIndex <>-1 then
 begin
   SelectedIndex := lst_Manevry.ItemIndex;

   cbb_Manevry.ItemIndex := ManevrTypeToNumber(lst_Manevry.Items[SelectedIndex]); //selecting the corresponding manoeuvre in the cbb

   CreateLabeledScrollbars(ConvertManevrType(lst_Manevry.Items[SelectedIndex]));  // making the corresponding trackbars visible

       SelectedManevr := g_ManevrList[SelectedIndex];

       if (SelectedManevr.pType = mtHorizFlight) then
          g_TrackBars[0].Position := Round(SelectedManevr.fParameters[1]/g_Multipliers[0]);

       if (SelectedManevr.pType = mtGorka) or (SelectedManevr.pType = mtPikirovanie) then
         for i:=0 to Length(g_TrackBars)-1 do
           g_TrackBars[i].Position := Round(SelectedManevr.fParameters[i+2]/g_Multipliers[i]);

       if (SelectedManevr.pType = mtLeftVirage) or (SelectedManevr.pType = mtRightVirage) then
         for i:=0 to Length(g_TrackBars)-1 do
           g_TrackBars[i].Position := Round(SelectedManevr.fParameters[i+6]/g_Multipliers[i]);

      if (SelectedManevr.pType = mtHorizRazgon) then
        g_TrackBars[0].Position := Round(SelectedManevr.fParameters[8]/g_Multipliers[0]);

      if (SelectedManevr.pType = mtRazgonSnaborom) then
         for i:=0 to Length(g_TrackBars)-1 do
           g_TrackBars[i].Position := Round(SelectedManevr.fParameters[i+8]/g_Multipliers[i]);
 end;
end;

procedure Tfrm_Interface.lst_ManevryMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  UpdateValuesFromTManevr;
  DrawTrajectory(cht_traj,g_FlightData);

 if Length(g_FlightData)-1 = lst_Manevry.Count then
  ShowManevrInfo(g_FlightData[lst_Manevry.ItemIndex+1],1);
end;

function ManevrTypeToNumber (aType : string) : Integer;
begin

  if aType = 'Горизонтальный полет' then
   Result := 0
  else
    if aType = 'Горка' then
     Result := 1
    else
     if aType = 'Пикирование' then
      Result := 2
     else
      if aType = 'Левый вираж' then
       Result := 3
      else
       if aType = 'Правый вираж' then
        Result := 4
       else
        if aType = 'Разгон в горизонте' then
         Result := 5
        else
         if aType = 'Разгон с набором высоты' then
          Result := 6
         else
          begin
           Result := -1;
           ShowMessage('function ManevrTypeToNumber: некорректное название маневра');
          end;

end;

function HelicopterTypeToNumber (aType : string) : Integer;
begin

  if aType = 'Ансат-У' then
   Result := 0
  else
    if aType = 'Ми-26' then
     Result := 1
    else
     if aType = 'Ка-226' then
      Result := 2
     else
      if aType = 'Ми-28Н' then
       Result := 3
      else
       if aType = 'Ми-8МТВ-5' then
        Result := 4
       else
        if aType = 'Ми-8АМТШ' then
         Result := 5
        else
          begin
           Result := -1;
           ShowMessage('function HelicopterTypeToNumber: некорректное название вертолета');
          end;
end;


procedure Tfrm_Interface.DynamicallyUpdateLabelValues(Sender: TObject);  //обновление параметров на основе положения ползунков
 var
  i : Integer; //number of the selected manoeuvre in the form list
begin

  DynamicFoolProtection;

 //refreshing labels' values
  for i:=0 to High(g_TrackBars) do
   g_ValueLabels[i].Caption := FloatToStr(g_Multipliers[i]*g_TrackBars[i].Position);

end;

procedure HelicoptersInitialization;
begin
 g_HelicopterDatabase[1] := CreateHelicopter(mi8);
 g_HelicopterDatabase[2] := CreateHelicopter(mi81);
end;


procedure Tfrm_Interface.cbb_HelicopterTypeSelect(Sender: TObject);
begin
  if cbb_HelicopterType.ItemIndex = 4 then g_Helicopter := g_HelicopterDatabase[1];  //Mi-8
  if cbb_HelicopterType.ItemIndex = 5 then g_Helicopter := g_HelicopterDatabase[2];  //Mi-8 clone

  SetInitialConditionsTrackbars;
  DynamicallyUpdateICLabelValuesAndPlots(Self);

 if g_ManevrList.Count > 0 then
  EnableCalculateButton;

end;

procedure Tfrm_Interface.SetICTrackbar (var trackbar : TTrackBar; amin,amax,aposition : Real);
begin
   with trackbar do
  begin
   Max := Round(amax);
   Position := Round(aposition);
   OnChange := DynamicallyUpdateICLabelValuesAndPlots;
   Min := Round(amin); //this has to be at the end, otherwise it doesn't work for trckbr_G (delphi's bug?)
  end;
end;

procedure Tfrm_Interface.SetInitialConditionsTrackbars;

begin
 SetICTrackbar(trckbr_H0,50{meters}/deltaH0,0.9*g_Helicopter.Hdyn/deltaH0,400/deltaH0);
 SetICTrackbar(trckbrV0,0,0.95*g_Helicopter.Vmax-1,100);
 SetICTrackbar(trckbr_G,g_Helicopter.Gmin,g_Helicopter.Gmax,g_Helicopter.Gmax);
 SetICTrackbar(trckbr_T,Tmin,Tmax,Tdefault);
end;

procedure Tfrm_Interface.DynamicallyUpdateICLabelValuesAndPlots(Sender: TObject);
begin
 DynamicallyChangeV0max;

 lbl_H0value.Caption := FloatToStr(g_H0);
 lbl_Gvalue.Caption := FloatToStr(g_G);
 lbl_Tvalue.Caption := FloatToStr(g_T);
 lblV0value.Caption := FloatToStr(g_V0);

 DrawCharacs(cht_DiapNXNY,g_Helicopter,g_G,g_T,g_H0);

 FlightDataInitialization;

 if g_ManevrList.Count > 0 then
  EnableCalculateButton;

 DynamicallyUpdateLabelValues(Self);
end;

procedure Tfrm_Interface.ExportFlightTask(manevrlist : TManevrList);
var
f: textfile;
i,j : Byte;
currentdir : string;
begin
 currentdir := GetCurrentDir;
 try
   AssignFile(f, currentdir+'\FlightTask.txt');
   Rewrite(f);

   Writeln(f,cbb_HelicopterType.Items[cbb_Helicoptertype.ItemIndex]);
   Writeln(f,FloatToStr(g_G));
   Writeln(f,FloatToStr(g_H0));
   Writeln(f,FloatToStr(g_T));
   Writeln(f,FloatToStr(g_V0));

   Writeln(f, manevrlist.Count);

   for i:=0 to manevrlist.Count -1 do
   begin
    Writeln(f, ConvertManevrType(manevrlist[i].pType));

    for j:=1 to Length(manevrlist[i].fParameters) do
     Writeln(f, manevrlist[i].fParameters[j]:7:6);
   end;
   CloseFile(f);
   ShowMessage('Полетное задание успешно сохранено в файл '+currentdir+'\FlightTask.txt');
 except
   ShowMessage('Ошибка при сохранении полетного задания');
 end; 

end;

function Tfrm_Interface.g_H0 () : Real;
begin
  Result :=deltaH0*trckbr_H0.Position;
end;

function Tfrm_Interface.g_V0 () : Real;
begin
  Result :=trckbrV0.Position;
end;


function Tfrm_Interface.g_T () : Real;
begin
  Result :=trckbr_T.Position;
end;

function Tfrm_Interface.g_G () : Real;
begin
  Result :=trckbr_G.Position;
end;

procedure Tfrm_Interface.DrawDiapason(var cht: TChart;
  helicopter: THelicopter; icG, icT: Real);
  var
    diap : TDiapason;
    i : Integer;
begin
  with cht.LeftAxis do
   begin
     Title.Caption:='H, км';
     Minimum := 0;
     Maximum := 6;
   end;

 cht.BottomAxis.Minimum := 0;

 for i := 0 to cht.SeriesCount - 1 do
  cht.Series[i].Clear;

 (cht.Series[0] as TLineSeries).LinePen.Color := clRed;
 (cht.Series[0] as TLineSeries).LinePen.Width := 2;

 diap := Diapason(helicopter, icG, icT);

 for i := Low(diap) to High(diap) do
  if diap[i] > 0 then
   cht.Series[0].AddXY(i,diap[i]/1000);

end;

procedure Tfrm_Interface.DrawTrajectory(var cht: TChart;
  FlightData: TFlightData);
var

 NewSeries : TPointSeries;
 i,j, m  : Integer;
 xyz1 : TArrayOfArrayOfReal;
 xyz1s : TMatrixData;
 chopped,
 rotated : TMatrix;


const
   pointersize = 2;
begin
   for i := 0 to cht.SeriesCount - 1 do
      cht.Series[i].Clear;

    while cht.SeriesCount > 0 do
      cht.Series[0].Free;

  if Length(FlightData) > 1 then
   begin 
    for m := 0 to High(FlightData) do
      begin
        NewSeries := TPointSeries.Create(self);

        with NewSeries.Pointer do
         begin
          Style := psCircle;
          Pen.Visible := False; //removes the border

          HorizSize := pointersize;
          VertSize := pointersize;

          if (m = lst_Manevry.ItemIndex+1)  then
           begin
            HorizSize := HorizSize + 2;
            VertSize := VertSize + 2;
           end;
           
         end;

       if Length(FlightData[m]) > 1 then
        begin
             xyz1 := ToXYZ1Array(FlightData[m]);

          SetLength(xyz1s,Length(xyz1));

          for i :=0 to Length (xyz1) - 1 do
            begin
              SetLength(xyz1s[i],Length(xyz1[i]));

              for j:=0 to Length(xyz1[i]) - 1 do
               xyz1s[i,j]:= xyz1[i,j]
            end;

          chopped := TMatrix.Create(xyz1s);

          if rg_view.ItemIndex = 2 then //isometric
             begin
               cht.LeftAxis.Visible := False;
               cht.BottomAxis.Visible := False;
               rotated := chopped.Mult(IsometryMatrix(-DegToRad(29.52),-DegToRad(26.23)))
             end
          else
            begin
             rotated := chopped;  //not rotated
             cht.LeftAxis.Visible := True;
             cht.BottomAxis.Visible := True;
            end;

         if (rg_view.ItemIndex = 1) then
          with cht.LeftAxis do
           begin
            Automatic := False;
            Minimum := 0;
            Maximum := Round(1.4*g_H0);
           end
         else
          cht.LeftAxis.Automatic := True;

          for i :=0 to rotated.RowCount - 1 do
           if (rg_view.ItemIndex = 1) or (rg_view.ItemIndex = 2) then
             NewSeries.AddXY(rotated[i+1,1],rotated[i+1,2])
           else
             NewSeries.AddXY(rotated[i+1,1]{x},rotated[i+1,3]{z});

          cht.AddSeries(NewSeries);
        end;


      end;
   end;


end;

procedure Tfrm_Interface.rg_viewClick(Sender: TObject);
begin
  DrawTrajectory(cht_traj,g_FlightData);
end;

procedure Tfrm_Interface.DrawNY(var cht: TChart; helicopter: THelicopter;
  icG, icT, icH0: Real);
const
  dny=0.1;
var
 V,i : Integer;
 tempny : Real;

begin
  with cht.LeftAxis do
   begin
     Title.Caption:='ny max';
     Minimum := 0;
     Maximum := 2;
   end;

 cht.BottomAxis.Minimum := 0;

 for i := 0 to cht.SeriesCount - 1 do
  cht.Series[i].Clear;

 (cht.Series[0] as TLineSeries).LinePen.Color := clRed;
 (cht.Series[0] as TLineSeries).LinePen.Width := 2;

 for V := 0 to g_Vmax do
  begin
    tempny := ny(helicopter,g_G, g_T,g_H0,V);

   if tempny > 0 then
    cht.Series[0].AddXY(V,tempny)
  end;
end;

procedure Tfrm_Interface.DrawCharacs(var cht: TChart;
  helicopter: THelicopter; icG, icT, icH0: Real);
begin
 case rg_xarak.ItemIndex of
  0: DrawDiapason(cht, helicopter, icG, icT);
  1: DrawNY(cht, helicopter,icG, icT, icH0);
  2: DrawNX(cht,helicopter,icG, icT, icH0);
 end;
end;

procedure Tfrm_Interface.rg_xarakClick(Sender: TObject);
begin
 DrawCharacs(cht_DiapNXNY,g_Helicopter,g_G,g_T,g_H0);
end;

procedure Tfrm_Interface.DrawNX(var cht: TChart; helicopter: THelicopter;
  icG, icT, icH0: Real);
  const
    dny = 0.1;
  var
  tempny : Real;
  V,i : Integer;
  NewSeries : TLineSeries;
begin
   for i := 0 to cht.SeriesCount - 1 do
  cht.Series[i].Clear;

  While cht.SeriesCount > 0 do
        cht.Series[0].Free;

  cht.BottomAxis.Minimum := 50;

  with cht.LeftAxis do
   begin
     Title.Caption:='nx max';
     Minimum := -0.5;
     Maximum := 1;
   end;

  tempny := helicopter.nyMin;
  
  while  tempny <=  helicopter.nyMax do
   begin
   // ShowMessage(FloatToStr(cht.SeriesCount));

    NewSeries:=TLineSeries.Create(self);

    if (tempny > 0.95) and (tempny < 1.05) then
     NewSeries.LinePen.Width := 3
    else

     NewSeries.LinePen.Width := 1;

    for V :=50 to g_Vmax do
      begin
       cht.AddSeries(NewSeries);
       cht.Series[cht.SeriesCount-1].AddXY(V,nx(helicopter,tempny, icG, icT,icH0,V));
      end;

    tempny := tempny + dny;
   end;

   g_nxVisited := True;
end;

procedure Tfrm_Interface.ExportCalculatedFlightTask(
  FlightData: TFlightData);
var
f: textfile;
i,j : Integer;
currentdir : string;
begin
 currentdir := GetCurrentDir;
 try
   begin
     AssignFile(f, currentdir+'\blitz\lib\massivw.txt');
     Rewrite(f);

     Writeln(f,cbb_HelicopterType.Items[cbb_Helicoptertype.ItemIndex]+' G = '+FloatToStr(g_G)+' H0 = ' + FloatToStr(g_H0) +' T = '+FloatToStr(g_T) );

     for i:=0 to Length(g_FlightData) -1 do
      for j := 0 to Length(g_FlightData[i]) -1 do
        Writeln(f, StateVectorString(FlightData[i][j]));

     CloseFile(f);
     ShowMessage('Массив положений вертолета успешно сохранен в файл '+currentdir+'\blitz\lib\massivw.txt');
   end;
 except
   ShowMessage('Ошибка при сохранении массива положений вертолета');
 end;

end;

procedure Tfrm_Interface.btn_ExportCalculatedTaskClick(Sender: TObject);
begin
 if Length(g_FlightData) > 1 then
  ExportCalculatedFlightTask(g_FlightData);
end;

procedure Tfrm_Interface.RecalculateRedrawFromManevrList;
var
  i:Integer;
begin
 SetLength(g_FlightData,1);

  for i:=0 to lst_Manevry.Count - 1 do
     begin
       lst_Manevry.ItemIndex := i;
       UpdateValuesFromTManevr;   //setting ALL trackbars to the right positions according to g_ManevrList
       UpdateManevrList(g_ManevrList);  //little update g_ManevrList of from MODIFIED trackbars
     end;

 for i:=0 to g_ManevrList.Count - 1 do
  AppendTempManevr(g_ManevrList[i]);


 pm_Manevry.AutoPopup := True;

 UpdateModeOn;

 DrawTrajectory(cht_traj,g_FlightData);

 if g_ManevrList.Count > 0 then
  btn_AddManevr.Enabled := True;

 DisableCalculateButton; 
end;

procedure Tfrm_Interface.FullRecalculate;
begin
 if g_ManevrList.Count > 0 then
   begin
    FlightDataInitialization;

    RecalculateRedrawFromManevrList;

    if Length(g_FlightData)-1 = lst_Manevry.Count then
     ShowManevrInfo

   end;
end;

procedure Tfrm_Interface.DisableCalculateButton;
begin
  btn_Calcutate.Visible := False;
  lbl_RecalcNeeded.Visible := False;
end;

procedure Tfrm_Interface.EnableCalculateButton;
begin
  btn_Calcutate.Visible := True;
  lbl_RecalcNeeded.Visible := True;
end;

procedure Tfrm_Interface.btn_CalcutateClick(Sender: TObject);
begin
 FullRecalculate(Self);

 DisableCalculateButton;
end;

procedure Tfrm_Interface.DynamicFoolProtection;
var
  cosTheta  : Real;
  cosThetaRounded, trckbarNo,Vmax : Integer;
const
  cosCorrection = 0.02;

begin
 {
      names[0]:='ny ввода';
      names[1]:='ny вывода';
      names[2]:='Накл. тракт., град.';
      names[3]:='Скор. вывода, км/ч';

      multipliers[0]:=0.01;
      multipliers[1]:=0.01;
      multipliers[2]:=1;
      multipliers[3]:=10;
 }

  if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Горка') or (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Пикирование') then
    begin
       if cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Горка' then
        trckbarNo := 1
       else
        trckbarNo := 0;

        cosTheta := RoundTo(Cos(DegToRad(g_TrackBars[2].Position)),-2);

        cosThetaRounded := Round(100*(cosTheta-cosCorrection));
        //cosCorrection allows avoiding accidental exceeding of the overload caused by inexact values of the slope angle

        if g_TrackBars[trckbarNo].Position > cosThetaRounded then
         g_TrackBars[trckbarNo].Position := cosThetaRounded;

        g_TrackBars[trckbarNo].Max := cosThetaRounded;
    end;

  if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Разгон в горизонте') then
   begin
     Vmax := VmaxOnAGivenHeight(g_Helicopter,g_G,g_T,g_H0)-1;
     if g_TrackBars[0].Position > Vmax then
      g_TrackBars[0].Position := Vmax;
     g_TrackBars[0].Max := Vmax;
   end;


end;



procedure Tfrm_Interface.CollectTrackBarsData(var ParamArray : TParametersArray);
begin
 if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Горизонтальный полет')  then
   begin
     ParamArray[1] := g_Multipliers[0]*g_TrackBars[0].Position;
     ParamArray[2] :=0;
     ParamArray[3] :=0;
     ParamArray[4] :=0;
     ParamArray[5] :=0;
     ParamArray[6] :=0;
     ParamArray[7] :=0;
     ParamArray[8] :=0;
     ParamArray[9] :=0;
   end;
  if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Горка') or (cbb_Manevry.Items[cbb_Manevry.ItemIndex] ='Пикирование') then
   begin
     ParamArray[1] := 0;
     ParamArray[2] :=g_Multipliers[0]*g_TrackBars[0].Position;
     ParamArray[3] :=g_Multipliers[1]*g_TrackBars[1].Position;
     ParamArray[4] :=g_Multipliers[2]*g_TrackBars[2].Position;
     ParamArray[5] :=g_Multipliers[3]*g_TrackBars[3].Position;
     ParamArray[6] :=0;
     ParamArray[7] :=0;
     ParamArray[8] :=0;
     ParamArray[9] :=0;
   end;
  if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Левый вираж') or (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Правый вираж') then
     begin
     ParamArray[1] :=0;
     ParamArray[2] :=0;
     ParamArray[3] :=0;
     ParamArray[4] :=0;
     ParamArray[5] :=0;
     ParamArray[6] :=g_Multipliers[0]*g_TrackBars[0].Position;
     ParamArray[7] :=g_Multipliers[1]*g_TrackBars[1].Position;
     ParamArray[8] :=0;
     ParamArray[9] :=0;
   end;

    if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Разгон в горизонте')  then
   begin
     ParamArray[1] :=0;
     ParamArray[2] :=0;
     ParamArray[3] :=0;
     ParamArray[4] :=0;
     ParamArray[5] :=0;
     ParamArray[6] :=0;
     ParamArray[7] :=0;
     ParamArray[8] :=g_Multipliers[0]*g_TrackBars[0].Position;
     ParamArray[9] :=0;
   end;

     if (cbb_Manevry.Items[cbb_Manevry.ItemIndex] = 'Разгон с набором высоты')  then
   begin
     ParamArray[1] :=0;
     ParamArray[2] :=0;
     ParamArray[3] :=0;
     ParamArray[4] :=0;
     ParamArray[5] :=0;
     ParamArray[6] :=0;
     ParamArray[7] :=0;
     ParamArray[8] :=g_Multipliers[0]*g_TrackBars[0].Position;
     ParamArray[9] :=g_Multipliers[1]*g_TrackBars[1].Position;
   end;
end;

procedure Tfrm_Interface.UpdateManevrList(var manevrlist: TManevrList);
var
SelectedIndex, i : Integer;
begin
        SelectedIndex := lst_Manevry.ItemIndex;

     if SelectedIndex <>-1 then
       begin
         if (manevrlist[SelectedIndex].pType = mtHorizFlight) then
            manevrlist[SelectedIndex].fParameters[1] := g_Multipliers[0]*g_TrackBars[0].Position;

         if (manevrlist[SelectedIndex].pType = mtGorka) or (manevrlist[SelectedIndex].pType = mtPikirovanie) then
          for i:=0 to Length(g_TrackBars)-1 do
           manevrlist[SelectedIndex].fParameters[i+2] := g_Multipliers[i]*g_TrackBars[i].Position;

         if (manevrlist[SelectedIndex].pType = mtLeftVirage) or (manevrlist[SelectedIndex].pType = mtRightVirage) then
          for i:=0 to Length(g_TrackBars)-1 do
           manevrlist[SelectedIndex].fParameters[i+6] := g_Multipliers[i]*g_TrackBars[i].Position;

         if  (manevrlist[SelectedIndex].pType = mtHorizRazgon) then
            manevrlist[SelectedIndex].fParameters[8] := g_Multipliers[0]*g_TrackBars[0].Position;

         if (manevrlist[SelectedIndex].pType = mtRazgonSnaborom) then
          for i:=0 to Length(g_TrackBars)-1 do
           manevrlist[SelectedIndex].fParameters[i+8] := g_Multipliers[i]*g_TrackBars[i].Position;
       end;
end;

procedure Tfrm_Interface.DynamicallyChangeV0max;
var
  maxV0, minV0, realHstat  : Integer;

const
 defaultVMin = 0;
begin
 // updating Hst
  realHstat := Round(RealHst(g_Helicopter,g_G,g_T));

  if realHstat < deltaH0*trckbr_H0.Position then
   trckbr_H0.Position := Round(0.9*realHstat/deltaH0);

  trckbr_H0.Max := Round(0.9*realHstat/deltaH0);


 // updating maxV0
  maxV0 := VmaxOnAGivenHeight(g_Helicopter,g_G,g_T,g_H0);

  if maxV0 > 0.85*g_Helicopter.Vmax then
   maxV0 := Round(0.85*g_Helicopter.Vmax);

  if trckbrV0.Position > maxV0 then
    trckbrV0.Position := maxV0;

  trckbrV0.Max := maxV0;


 // updating minV0
  minV0 := VminOnAGivenHeight(g_Helicopter,g_G,g_T,g_H0);

 if minV0 < defaultVMin then
  trckbrV0.Min := defaultVMin
 else
  trckbrV0.Min := minV0;

  if trckbrV0.Position < defaultVMin then
    trckbrV0.Position := defaultVMin;
end;



procedure Tfrm_Interface.AddModeOn;
begin
 btn_AddManevr.Caption := 'Добавить маневр';
 g_ButtonMode := bmAdd;
end;

procedure Tfrm_Interface.UpdateModeOn;
begin
 btn_AddManevr.Caption := 'Обновить маневр';
 g_ButtonMode := bmUpdate;
end;



procedure Tfrm_Interface.CreateManevrInfoGrid;
begin
 with strngrd_ManevrInfo do
   begin

     ColWidths[0]:=160;
     ColWidths[1]:=115;
     ColWidths[2]:=115;

     Width := 396;

     Cells[0,1] := 'Время выполнения, с';
     Cells[0,2] := 'Максимальная высота, м';
     Cells[0,3] := 'Минимальная высота, м';
     Cells[0,4] := 'Изменение высоты, м';
     Cells[0,5] := 'Горизонтальное смещение, м';
     Cells[0,6] := 'Пройденный путь, м';
     Cells[0,7] := 'Максимальная скорость, км/ч';
     Cells[0,8] := 'Минимальная скорость, км/ч';
     Cells[0,9] := 'Конечная скорость, км/ч';

     Cells[1,0] :='Выделенный маневр';
     Cells[2,0] :='Полетное задание';

   end;


end;

procedure Tfrm_Interface.ShowManevrInfo(manevr : TManevrData; colNo : Byte);
var
 props : TManevrPropsPerebornye;

 function Format(value: Real):string;
 begin
   Result := FloatToStr(RoundTo(value,-1))
 end;

begin
 props := ManevrPropsPerebornye(manevr);

 with strngrd_ManevrInfo do
  begin
    Cells[colNo,1] := Format(tVypoln(manevr));
    Cells[colNo,2] := Format(props.ymax);
    Cells[colNo,3] := Format(props.ymin);
    Cells[colNo,4] := Format(deltaY(manevr));
    Cells[colNo,5] := Format(Sqrt(Sqr(deltaX(manevr))+Sqr(deltaZ(manevr))));
    Cells[colNo,6] := Format(props.S);
    Cells[colNo,7] := Format(props.Vmax);
    Cells[colNo,8] := Format(props.Vmin);
    Cells[colNo,9] := Format(manevr[High(manevr)].V*g_mps);
  end;

end;

procedure Tfrm_Interface.ShowManevrInfo;
begin

   begin
    if not (lst_Manevry.Count = 0) then
     begin
      strngrd_ManevrInfo.Visible := True;
      ShowManevrInfo(g_FlightData[lst_Manevry.Count],1);
      ShowManevrInfo(FlightDataToManevrData(g_FlightData,g_Helicopter),2);
     end
    else
     strngrd_ManevrInfo.Visible := False;
   end;
end;

end.


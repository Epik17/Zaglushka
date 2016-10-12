program Manevr;

uses
  Forms,
  frmInterface in 'frmInterface.pas' {frm_Interface},
  InterfaceClasses in 'InterfaceClasses.pas',
  HelicoptersDatabase in 'HelicoptersDatabase.pas',
  FlightData in 'FlightData.pas',
  Manoeuvres in 'Manoeuvres.pas',
  World in 'World.pas',
  Kernel in 'Kernel.pas',
  Matrixes in 'Matrixes.pas',
  Matrix_preobraz in 'Matrix_preobraz.pas',
  MyTypes in 'MyTypes.pas',
  JmTypes in 'JmTypes.pas',
  JmGeometry in 'JmGeometry.pas',
  GlobalConstants in 'GlobalConstants.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_Interface, frm_Interface);
  Application.Run;
end.

unit HelicoptersDatabase;

interface

type THelicopter = record
Fomet, //��������� �������, �2
Gnorm, //���������� �������� ���, ��
TraspUZemli, //������������� ���� � �����, ��
nyMin, //����������� ���������� ���������� ����������
nyMax, //������������ ���������� ���������� ����������
ctgTotH,  //��������� ���� ������� ������� ���� �� ��� ������� ������
ctgNotH,  //��������� ���� ������� ������� �������� ������� ��������� ��� ������� ������
Hst,  //����������� �������, �
Hdyn,  //������������ �������, �
Vmax, //������������ ��������, ��/�
TemperCoeff, //������������� �����������
ParabolaCoeff, //����������� ��������, ������� ������������ �������� ����� � ���������
Gmin, //����������� �������� ���
Gmax : Real; //������������ �������� ���
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
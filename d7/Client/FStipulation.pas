unit FStipulation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, A2Form,Atzcls, ExtCtrls, deftype, uCryptStringList;

type
  TFrmStipulation = class(TForm)
    A2Form: TA2Form;
    A2ListBox1: TA2ListBox;
    A2ButtonAgree: TA2Button;
    A2ButtonNotAgree: TA2Button;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure A2ButtonAgreeClick(Sender: TObject);
    procedure A2ButtonNotAgreeClick(Sender: TObject);
  private
  public

  end;

var
   FrmStipulation: TFrmStipulation;

implementation

uses
   FMain, FNewUser, FLogOn;
{$R *.DFM}

procedure TFrmStipulation.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 0;
   Left := 0;

   A2ListBox1.SetScrollTopImage (EtcAtzClass.GetEtcAtz (126),EtcAtzClass.GetEtcAtz (125));
   A2ListBox1.SetScrollTrackImage (EtcAtzClass.GetEtcAtz (130),EtcAtzClass.GetEtcAtz (129));
   A2ListBox1.SetScrollBottomImage (EtcAtzClass.GetEtcAtz (128),EtcAtzClass.GetEtcAtz (127));

   A2ButtonAgree.SetUpA2Image (EtcAtzClass.GetEtcAtz (131));
   A2ButtonAgree.SetDownA2Image (EtcAtzClass.GetEtcAtz (132));
   A2ButtonNotAgree.SetUpA2Image (EtcAtzClass.GetEtcAtz (133));
   A2ButtonNotAgree.SetDownA2Image (EtcAtzClass.GetEtcAtz (134));
end;

procedure TFrmStipulation.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmStipulation.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
end;

procedure TFrmStipulation.FormShow(Sender: TObject);
var
   i : integer;
   StringList : TStringList;
   CryptStringList : TCryptStringList;
begin
   if A2ListBox1.Count > 0 then exit;
   CryptStringList := TCryptStringList.Create;
   StringList := TStringList.Create;
   CryptStringList.LoadFromCryptFile ('ect\stip.Cpt');
   CryptStringList.GetDeStringList (StringList);
   A2ListBox1.Clear;
   for i := 0 to StringList.Count -1 do begin
      A2ListBox1.AddItem (StringList[i]);
   end;
   StringList.Free;
   CryptStringList.Free;
end;

procedure TFrmStipulation.A2ButtonAgreeClick(Sender: TObject);
{ //@@ 테스트용
var
   i : integer;
   StringList : TStringList;
begin
   StringList := TStringList.Create;
   StringList.LoadFromFile ('ect\stip.txt');
   A2ListBox1.Clear;
   for i := 0 to StringList.Count -1 do begin
      A2ListBox1.AddItem (StringList[i]);
   end;
   StringList.Free;
}
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   Visible := FALSE;
   FrmNewUser.Visible := TRUE;
end;

procedure TFrmStipulation.A2ButtonNotAgreeClick(Sender: TObject);
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   Visible := FALSE;
   FrmLogon.Visible := TRUE;
{
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   FrmLogOn.SocketAddOneData (CM_CLOSE);
   bodirectclose := TRUE;
}
end;

end.

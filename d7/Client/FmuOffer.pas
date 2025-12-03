unit FmuOffer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, A2Form, StdCtrls, Deftype;

type
  TFrmMuOffer = class(TForm)
    A2Form: TA2Form;
    A2Label2: TA2Label;
    A2Edit2: TA2Edit;
    A2Label3: TA2Label;
    A2Label4: TA2Label;
    A2Label5: TA2Label;
    A2Label6: TA2Label;
    A2Label7: TA2Label;
    A2Label8: TA2Label;
    A2Label9: TA2Label;
    A2Label10: TA2Label;
    A2Label11: TA2Label;
    A2Label12: TA2Label;
    A2Edit3: TA2Edit;
    A2Edit4: TA2Edit;
    A2Edit5: TA2Edit;
    A2Edit6: TA2Edit;
    A2Label15: TA2Label;
    A2Label16: TA2Label;
    A2Label17: TA2Label;
    A2Label18: TA2Label;
    A2Label19: TA2Label;
    A2Label20: TA2Label;
    A2Label21: TA2Label;
    A2Edit7: TA2Edit;
    A2Edit8: TA2Edit;
    A2Edit9: TA2Edit;
    A2Edit10: TA2Edit;
    A2Edit11: TA2Edit;
    A2Edit12: TA2Edit;
    A2Edit13: TA2Edit;
    A2Label23: TA2Label;
    A2Label24: TA2Label;
    A2Label25: TA2Label;
    A2Label26: TA2Label;
    A2Edit14: TA2Edit;
    A2Edit15: TA2Edit;
    A2Edit16: TA2Edit;
    A2Edit17: TA2Edit;
    A2Button1: TA2Button;
    A2Label13: TA2Label;
    A2Label14: TA2Label;
    A2Button2: TA2Button;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
     procedure MessageProcess (var code: TWordComData);
     procedure SetPostion;
  end;

var
  FrmMuOffer: TFrmMuOffer;

implementation

uses
   FMain, FAttrib, FBottom, FLogOn;

{$R *.DFM}

procedure TFrmMuOffer.MessageProcess (var code: TWordComData);
begin

end;

procedure TFrmMuOffer.SetPostion;
begin
   if FrmAttrib.Visible then begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := ((640 - FrmAttrib.Width) div 2) - (Width div 2);
   end else begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := (640 div 2) - (Width div 2);
   end;
end;

procedure TFrmMuOffer.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 0;
   Left := 0;
end;

procedure TFrmMuOffer.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmMuOffer.FormShow(Sender: TObject);
begin
   SetPostion;
end;

end.

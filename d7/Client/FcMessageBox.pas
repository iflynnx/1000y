unit FcMessageBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  A2Form, StdCtrls, Deftype, ExtCtrls, AUtil32, A2Img, AtzCls;

const
   MessageMaxCount = 3;

type
  TFrmcMessageBox = class(TForm)
    A2Form: TA2Form;
    A2LabelCaption: TA2Label;
    A2ButtonOK: TA2Button;
    A2ButtonCanCel: TA2Button;
    A2LabelText0: TA2Label;
    A2LabelText1: TA2Label;
    A2LabelText2: TA2Label;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure A2ButtonOKClick(Sender: TObject);
    procedure A2ButtonCanCelClick(Sender: TObject);
  private
     MessageArr : array [0..MessageMaxCount-1] of TA2Label;
  public
     procedure AddMessageText (aText: string);
     procedure MessageProcess (var code: TWordComData);
     procedure SetPostion;
     procedure SetImage;

     procedure SetMessage (astr : string);
  end;

var
   FrmcMessageBox: TFrmcMessageBox;

implementation

uses
   FMain, FAttrib, FBottom, FLogOn;

{$R *.DFM}

procedure TFrmcMessageBox.FormCreate(Sender: TObject);
var
   i : integer;
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 10;
   Left := 10;
   for i := 0 to MessageMaxCount -1 do begin
      MessageArr[i] := TA2Label(FindComponent('A2LabelText'+IntToStr(i)));
   end;
   SetImage;
end;

procedure TFrmcMessageBox.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmcMessageBox.AddMessageText (aText: string);
var
   str, rdstr : String;
   int : integer;
begin
   str := aText;
   int := 0;
   while TRUE do begin
      str := GetValidStr3 (str,rdstr, #13);
      MessageArr[int].Caption := rdstr;
      inc(int);
      if str = '' then Break;
      if int > MessageMaxCount-1 then break;
   end;
end;

{
   TSShowSpecialWindow = record
      rMsg : Byte;
      rWindow : Byte;
      rCaption : TNameString;
      rWordString: TWordString;
   end;
   PTSShowSpecialWindow = ^TSShowSpecialWindow;

}

procedure TFrmcMessageBox.SetMessage (astr : string);
begin
   A2LabelText0.Caption := CutLengthString (astr, A2LabelText0.Width);
   A2LabelText1.Caption := CutLengthString (astr, A2LabelText1.Width);
   A2LabelText2.Caption := CutLengthString (astr, A2LabelText2.Width);
end;

procedure TFrmcMessageBox.MessageProcess (var code: TWordComData);
var
   pckey : PTCKey;
   PSSShowSpecialWindow : PTSShowSpecialWindow;
begin
   pckey := @code.Data;
   case pckey^.rmsg of
      SM_SHOWSPECIALWINDOW :
         begin
            PSSShowSpecialWindow := @Code.data;
            case PSSShowSpecialWindow^.rWindow of
               WINDOW_AGREE :
                  begin
                     PSSShowSpecialWindow := @Code.Data;
                     A2LabelCaption.Caption := StrPas (@PSSShowSpecialWindow^.rCaption);
                     SetMessage (GetWordString(PSSShowSpecialWindow^.rWordString));
                     FrmcMessageBox.Visible := TRUE;
                  end;
            end;
         end;
   end;
end;

procedure TFrmcMessageBox.FormShow(Sender: TObject);
begin
   SetPostion;
end;

procedure TFrmcMessageBox.SetPostion;
begin
   if FrmAttrib.Visible then begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := ((640 - FrmAttrib.Width) div 2) - (Width div 2);
   end else begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := (640 div 2) - (Width div 2);
   end;
   A2LabelCaption.Left := (Width div 2) - (A2LabelCaption.Width div 2);
end;

procedure TFrmcMessageBox.A2ButtonOKClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
   CCWindowConfirm.rWindow := WINDOW_AGREE;
   cCWindowConfirm.rboCheck := TRUE;
   cCWindowConfirm.rButton := 0; // 버튼이 여려개 있을경우만 사용 일반은 0이 초기값
   FrmLogon.SocketAddData (sizeof(cCWindowConfirm), @cCWindowConfirm);
   FrmcMessageBox.Visible := FALSE;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmcMessageBox.A2ButtonCanCelClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
   CCWindowConfirm.rWindow := WINDOW_AGREE;
   cCWindowConfirm.rboCheck := FALSE;
   cCWindowConfirm.rButton := 0; // 버튼이 여려개 있을경우만 사용 일반은 0이 초기값
   FrmLogon.SocketAddData (sizeof(cCWindowConfirm), @cCWindowConfirm);
   FrmcMessageBox.Visible := FALSE;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmcMessageBox.SetImage;
begin
   A2ButtonOK.SetUpA2Image (EtcAtzClass.GetEtcAtz (47));
   A2ButtonOk.SetDownA2Image (EtcAtzClass.GetEtcAtz (48));
   A2ButtonCanCel.SetUpA2Image (EtcAtzClass.GetEtcAtz (49));
   A2ButtonCanCel.SetDownA2Image (EtcAtzClass.GetEtcAtz (50));
end;

end.

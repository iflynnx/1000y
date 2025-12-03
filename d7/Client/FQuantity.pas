unit FQuantity;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, A2Form, ExtCtrls, deftype, adeftype, AUtil32;

type
  TQitemData = record
     itemName : string[16];
     Count : integer;
  end;

  TShowType = (SH_Server, SH_Depository, SH_FAttrib);
  TFrmQuantity = class(TForm)
    Image1: TImage;
    BtnOK: TA2Button;
    BtnCancel: TA2Button;
    LbCountName: TLabel;
    EdCount: TA2Edit;
    procedure BtnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure Clear;
    procedure FormShow(Sender: TObject);
    procedure EdCountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SetFormText;
  private
    { Private declarations }
  public
    msg : byte;
    Countid  : LongInt;
    sourkey : word;
    destkey : word;
    CountCur : LongInt;
    CountMax : LongInt;
    CountName: string;

    ShowType : TShowType; // TRUE ServerType
    procedure MYVisible (aVisible : Boolean; aType : TShowType; aItemName, aCount:string);
    procedure MessageProcess (var code: TWordComData);
  end;

var
  FrmQuantity: TFrmQuantity;

implementation

uses FMain, FExchange, FLogOn, FBottom, FDepository, FAttrib;

{$R *.DFM}

procedure TFrmQuantity.FormCreate(Sender: TObject);
begin
   Parent := FrmM;
   Left := FrmExchange.Left + 10;
   Top := FrmExchange.Top + FrmExchange.Height - 100;

   // FrmQuantity Set Font
   EdCount.Font.Name := mainFont;
   LbCountName.Font.Name := mainFont;
   ShowType := SH_Server;
end;

procedure TFrmQuantity.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmQuantity.Clear;
begin
   msg      := 0;
   Countid  := 0;
   sourkey  := 0;
   destkey  := 0;
   CountCur := 0;
   CountMax := 0;
   CountName:= '';
   LbCountName.Caption := '';
   EdCount.Text := '';
end;

procedure TFrmQuantity.MessageProcess (var code: TWordComData);
var
   pckey : PTCKey;
   psCount : PTSCount;
begin
   pckey := @Code.data;
   case pckey^.rmsg of
      SM_SHOWCOUNT :
         begin
            psCount := @Code.data;
            FrmQuantity.msg := psCount^.rmsg;
            FrmQuantity.Countid := psCount^.rCountid;
            FrmQuantity.CountCur := psCount^.rCountCur;
            FrmQuantity.CountMax := psCount^.rCountMax;
            FrmQuantity.sourkey := psCount^.rsourkey;
            FrmQuantity.destkey := psCount^.rdestkey;
            FrmQuantity.CountName := GetWordString (psCount^.rCountName);
            MyVisible (TRUE, SH_Server,FrmQuantity.CountName,IntToStr(0));
         end;
   end;
end;
procedure TFrmQuantity.BtnOKClick(Sender: TObject);
var
   i : longint;
   CSelectCount : TCSelectCount;
begin
   case ShowType of
      SH_Server :
         begin
            i := _StrToInt (EdCount.Text);
            if (i > 0) and (i <= CountMax) then begin
               CSelectCount.rmsg := CM_SELECTCOUNT;
               CSelectCount.rboOk := TRUE;
               CSelectCount.rsourkey := sourkey;
               CSelectCount.rdestkey := destkey;
               CSelectCount.rCountid := Countid;
               CSelectCount.rCount := _StrToInt (EdCount.Text);
               FrmLogOn.SocketAddData (sizeof(CSelectCount), @CSelectCount);
               FrmExchange.ExchangeLock := FALSE;
               FrmBottom.EdChat.SetFocus;
               Visible := FALSE;
            end else begin
               // error
               CSelectCount.rmsg := CM_SELECTCOUNT;
               CSelectCount.rboOk := FALSE;
               CSelectCount.rsourkey := sourkey;
               CSelectCount.rdestkey := destkey;
               CSelectCount.rCountid := Countid;
               CSelectCount.rCount := 0;
               FrmLogOn.SocketAddData (sizeof(CSelectCount), @CSelectCount);
               FrmExchange.ExchangeLock := FALSE;
               Visible := FALSE;
               FrmBottom.AddChat (Conv('数量已满或没有'), 9, 29);
               FrmBottom.EdChat.SetFocus;
            end;
         end;
      SH_Depository :
         begin
         end;
      SH_FAttrib :
         begin
         end;
   end;
   FrmBottom.EdChat.SetFocus;
end;

procedure TFrmQuantity.BtnCancelClick(Sender: TObject);
var  CSelectCount : TCSelectCount;
begin
   case ShowType of
      SH_Server :
         begin
            CSelectCount.rmsg := CM_SELECTCOUNT;
            CSelectCount.rboOk := FALSE;
            CSelectCount.rsourkey := sourkey;
            CSelectCount.rdestkey := destkey;
            CSelectCount.rCountid := Countid;
            CSelectCount.rCount := 0;

            FrmLogOn.SocketAddData (sizeof(CSelectCount), @CSelectCount);

            FrmExchange.ExchangeLock := FALSE;
            Visible := FALSE;
            Clear;
         end;
      SH_Depository :
         begin
         end;
      SH_FAttrib :
         begin
         end;
   end;
   FrmBottom.EdChat.SetFocus;
end;

procedure TFrmQuantity.FormShow(Sender: TObject);
begin
   case ShowType of
      SH_Server :
         begin
            FrmExchange.ExchangeLock := TRUE;
            LbCountName.Caption := CountName;
            EdCount.Text := IntToStr(CountCur);
         end;
      SH_Depository :
         begin
         end;
      SH_FAttrib :
         begin
         end;
   end;
   Top := 480 - (117 + Height+10) ;
   {
   if FrmAttrib.Visible then Left := (640 - 180 - Width ) div 2
   else Left := (640 - Width) div 2;
   }
   Left := 20;
   if FrmQuantity.Visible then begin
      if FrmBottom.Visible then FrmQuantity.FocusControl(EdCount);
      EdCount.SelectAll;
   end;
end;

procedure TFrmQuantity.EdCountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = 13 then BtnOKClick(Self);
   if key = VK_ESCAPE then BtnCancelClick(Self);
end;

procedure TFrmQuantity.SetFormText;
begin
   FrmQuantity.Font.Name := mainFont;

   LbCountName.Font.Name := mainFont;
   EdCount.Font.Name := mainFont;
end;

procedure TFrmQuantity.MYVisible(aVisible: Boolean; aType: TShowType; aItemName, aCount:string);
begin
   Visible := aVisible;
   ShowType := aType;
   LbCountName.Caption := aItemName;
   EdCount.Text := aCount;
end;

end.

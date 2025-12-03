unit FExchange;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, A2Form, ExtCtrls, deftype, cltype, AUtil32, adeftype, Charcls, AtzCls;

type
  TFrmExchange = class(TForm)
    Image1: TImage;
    BtnOk: TA2Button;
    BtnCancel: TA2Button;
    A2ILabel1: TA2ILabel;
    A2ILabel2: TA2ILabel;
    A2ILabel3: TA2ILabel;
    A2ILabel4: TA2ILabel;
    A2ILabel5: TA2ILabel;
    A2ILabel6: TA2ILabel;
    A2ILabel7: TA2ILabel;
    A2ILabel8: TA2ILabel;
    LbSourceId: TLabel;
    LbDestId: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Clear;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure SourceItemStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure SourceItemDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SourceItemDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure A2ILabel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure SetFormText;

  private
    procedure SetItemLabel (Lb: TA2ILabel; aname: string; acolor: byte; shape: word);
  public
    LabelArr : array [0..8-1] of TA2ILabel;
    ExchangeLock : Boolean;
    procedure MessageProcess (var code: TWordComData);
  end;

var
   FrmExchange: TFrmExchange;

implementation

uses
   FMain, FAttrib, FQuantity, FLogOn, FBottom;

{$R *.DFM}

procedure TFrmExChange.SetItemLabel (Lb: TA2ILabel; aname: string; acolor: byte; shape: word);
var
   gc, ga: integer;
begin
   Lb.Hint := aname;
   GetGreenColorAndAdd (acolor, gc, ga);

   Lb.GreenCol := gc;
   Lb.GreenAdd := ga;

   if shape = 0 then begin
      Lb.A2Image := nil;
      Lb.BColor := 0;
      exit;
   end else
      Lb.A2Image := AtzClass.GetItemImage (shape);
end;

procedure TFrmExChange.MessageProcess (var code: TWordComData);
var
   i: integer;
   str, rdstr : string;
   pckey : PTCKey;
   psExChange : PTSExChange;
begin
   pckey := @Code.data;
   case pckey^.rmsg of
      SM_SHOWEXCHANGE:
         begin
            psExChange := @Code.data;
            str := GetwordString (psExChange^.rWordString);
            str := GetValidstr3 (str, rdstr, ',');
            LbSourceID.Caption := rdstr;           // SourceID
            if psExChange^.rCheckLeft then LbSourceId.Font.Color := clGray
            else LbSourceId.Font.Color := clWhite;

            str := GetValidstr3 (str, rdstr, ',');
            LbDestID.Caption := rdstr;             // DestID
            if psExChange^.rCheckRight then LbDestId.Font.Color := clGray
            else LbDestId.Font.Color := clWhite;

            for i := 0 to 8-1 do begin
               str := GetValidstr3 (str, rdstr, ',');
               SetItemLabel (LabelArr[i], rdstr, psExChange^.rColors[i], psExChange^.rIcons[i]);
            end;
            FrmExchange.Visible := TRUE;
         end;
   end;
end;

procedure TFrmExchange.Clear;
begin
    A2ILabel1.A2Image := nil;
    A2ILabel2.A2Image := nil;
    A2ILabel3.A2Image := nil;
    A2ILabel4.A2Image := nil;
    A2ILabel5.A2Image := nil;
    A2ILabel6.A2Image := nil;
    A2ILabel7.A2Image := nil;
    A2ILabel8.A2Image := nil;
end;

procedure  TFrmExchange.FormCreate(Sender: TObject);
begin
   Parent := FrmM;
   Color := clBlack;
   Left := 10; Top := 10;

   LabelArr[0] := A2ILabel1;
   LabelArr[1] := A2ILabel2;
   LabelArr[2] := A2ILabel3;
   LabelArr[3] := A2ILabel4;
   LabelArr[4] := A2ILabel5;
   LabelArr[5] := A2ILabel6;
   LabelArr[6] := A2ILabel7;
   LabelArr[7] := A2ILabel8;
end;

procedure  TFrmExchange.FormDestroy(Sender: TObject);
begin
//
end;

procedure  TFrmExchange.BtnCancelClick(Sender: TObject);
var ckey : TCKey;
begin
   if ExchangeLock then exit;
   ckey.rmsg := CM_CANCELEXCHANGE;
   FrmLogon.SocketAddData (sizeof(ckey), @ckey);
end;

procedure  TFrmExchange.BtnOkClick(Sender: TObject);
var cClick : TCClick;
begin
   if ExchangeLock then exit;
   cClick.rmsg := CM_CLICK;
   cClick.rwindow := WINDOW_EXCHANGE;
   cClick.rclickedId := 0;
   cClick.rShift := KeyShift;
   cClick.rkey := 0;
   FrmLogon.SocketAddData (sizeof(cClick), @cClick);
end;

procedure  TFrmExchange.SourceItemStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
//
end;

procedure  TFrmExchange.SourceItemDragDrop(Sender, Source: TObject; X, Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;

   with Source as TDragItem do begin
      if SourceID <> WINDOW_ITEMS then exit;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := DragedId;
      cDragDrop.rdestId := 0;
      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_EXCHANGE;
      cDragDrop.rsourkey := Selected;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop);
   end;
end;

procedure  TFrmExchange.SourceItemDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_ITEMS then begin
            Accept := TRUE;
         end;
      end;
   end;
end;

procedure TFrmExchange.A2ILabel1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   MouseInfoStr := TA2ILabel (Sender).Hint;
end;

procedure TFrmExchange.FormShow(Sender: TObject);
begin
   FrmBottom.EdChat.SetFocus;
end;

procedure TFrmExchange.SetFormText;
begin
   FrmExchange.Font.Name := mainFont;

   LbSourceId.Font.Name := mainFont;
   LbDestId.Font.Name := mainFont;
end;

end.

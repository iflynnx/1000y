unit FSearch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, A2Form, StdCtrls, FMain, Deftype, AUtil32;

type
  TFrmSearch = class(TForm)
    A2ComboBox1: TA2ComboBox;
    A2Edit1: TA2Edit;
    Lbshow: TA2Label;
    BtnOk: TA2Button;
    BtnCancel: TA2Button;
    A2Form: TA2Form;
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SearchItem; // 탐색창
    procedure A2Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
  public
    QuantityId : Longint;
    QuantityData : String;
  end;

var
   FrmSearch: TFrmSearch;


implementation

uses FLogOn, FExchange, FBottom;

{$R *.DFM}
procedure TFrmSearch.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self,A2Form);
   Left := 100;
   Top := 200;

   QuantityId := 0;
   QuantityData := '';
   // FrmSearch Set Font
   A2ComboBox1.Font.Name := mainFont;
   A2Edit1.Font.Name := mainFont;
   Lbshow.Font.Name := mainFont;
end;

procedure TFrmSearch.BtnOkClick(Sender: TObject);
var
   cInputString: TCInputString;
   n : integer;
begin
   cInputString.rmsg := CM_INPUTSTRING;
   cInputString.rInputStringId := QuantityId;
   StrPcopy (@cInputString.rSelectedList,''); // 아직 몬스터와 지명추가안됨
   SetWordString (cInputString.rInputString, A2Edit1.Text);

   n := Sizeof(cInputString) - sizeof(TWordString) + sizeofwordstring (cInputString.rinputstring);

   FrmLogon.SocketAddData (n, @cInputString);
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
   Visible := FALSE;
end;

procedure TFrmSearch.BtnCancelClick(Sender: TObject);
begin
   Visible := FALSE;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmSearch.SearchItem;  // 탐색창
var
   str, rdstr : string;
begin
   A2Edit1.Text := '';
   str := QuantityData;
   str := GetValidstr3 (str, rdstr, ',');
   LbShow.Caption := rdstr;
   A2ComboBox1.Items.Clear;
   while TRUE do begin
      str := GetValidstr3 (str, rdstr, ',');
      A2ComboBox1.Items.Add (rdstr);
      if str = '' then Break;
   end;

   if A2ComboBox1.Items.Count > 0 then A2ComboBox1.Text := A2ComboBox1.Items[0]
   else A2ComboBox1.Text := '';
end;

procedure TFrmSearch.FormShow(Sender: TObject);
var
   str, rdstr : string;
begin
   A2Edit1.Text := '';
   str := QuantityData;
   str := GetValidstr3 (str, rdstr, ',');
   LbShow.Caption := rdstr;
   A2ComboBox1.Items.Clear;
   while TRUE do begin
      str := GetValidstr3 (str, rdstr, ',');
      A2ComboBox1.Items.Add (rdstr);
      if str = '' then Break;
   end;

   if A2ComboBox1.Items.Count > 0 then A2ComboBox1.Text := A2ComboBox1.Items[0]
   else A2ComboBox1.Text := '';
   A2Edit1.SetFocus;
end;

procedure TFrmSearch.A2Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if key = 13 then BtnOkClick(Self);
   if key = VK_ESCAPE then BtnCancelClick(Self);
end;

end.


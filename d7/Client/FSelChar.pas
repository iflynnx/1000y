unit FSelChar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, log,autil32, deftype, A2Form, A2Img;

type
  TFrmSelChar = class(TForm)
    A2Form: TA2Form;
    EditChar: TA2Edit;
    EditPassWord: TA2Edit;
    EditConfirm: TA2Edit;
    Pninfo: TA2Label;
    BtnChangePass: TA2Button;
    BtnSelect: TA2Button;
    BtnDelete: TA2Button;
    BtnCreateChar: TA2Button;
    LbSex: TA2Label;
    BtnWaMan: TA2Button;
    BtnMan: TA2Button;
    CBVillage: TA2ComboBox;
    ListBox1: TA2ListBox;
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure BtnChangePassClick(Sender: TObject);
    procedure BtnSelectClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnCreateCharClick(Sender: TObject);
    procedure EditPassWordKeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnRealClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnWaManClick(Sender: TObject);
    procedure BtnManClick(Sender: TObject);
  private
    { Private declarations }
  public
    boCommandHide : Boolean;
    procedure MyHide;
    procedure MyShow;
    { Public declarations }
    procedure SetFormText;
  end;

var
  FrmSelChar: TFrmSelChar;

implementation

uses FLogOn, FMain, FUpDateID;

{$R *.DFM}

procedure TFrmSelChar.SetFormText;
begin
   Caption := Conv('千年[选择角色]');
   Pninfo.Caption := Conv('若无连线角色,请按[制造角色]建立.');
end;

procedure TFrmSelChar.EditKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = char (VK_ESCAPE)) or (key = char(VK_RETURN)) then key := char(0);
end;

procedure TFrmSelChar.BtnChangePassClick(Sender: TObject);
var ccp : TCChangePassWord;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   if Length (EditPassWord.Text) < 4 then begin Pninfo.Caption := Conv('密码必须4个字以上.'); EditPassWord.SetFocus; exit; end;
   if not isEngNumeric (EditPassWord.Text) then begin Pninfo.Caption := Conv('只能使用英文字母与阿拉伯数字.'); EditPassWord.SetFocus; exit; end;
   if EditPassWord.Text <> EditConfirm.Text then begin Pninfo.Caption := Conv('密码与确认密码必须一致.'); EditConfirm.SetFocus; exit; end;

   ccp.rmsg := CM_CHANGEPASSWORD;
   StrPCopy (@ccp.rNewPass, EditPassWord.Text);

   FrmLogOn.SocketAddData (sizeof(ccp), @ccp);
end;

procedure TFrmSelChar.BtnDeleteClick(Sender: TObject);
var
   ret : integer;
   buffer : array [0..64] of byte;
   cdc : TCDeleteChar;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   if listbox1.Items[Listbox1.Itemindex] = '' then begin exit; end;

   _StrPCopy (@Buffer,Listbox1.Items[ListBox1.ItemIndex] + ' ' + Conv('确定要删除该角色.'));
   ret := Application.MessageBox(@Buffer, Pchar(Conv('删除角色')), 1);
   if ret <> 1 then exit;

   cdc.rmsg := CM_DELETECHAR;
   StrPCopy (@cdc.rchar, listbox1.Items[Listbox1.Itemindex]);
   FrmLogOn.SocketAddData (sizeof(cdc), @cdc);
end;

procedure TFrmSelChar.BtnCreateCharClick(Sender: TObject);
var ccc : TCCreateChar;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   if Length (EditChar.Text) < 2 then begin Pninfo.Caption := Conv('角色名称 输入2个字以上.'); EditChar.SetFocus; exit; end;
   if Pos (',', EditChar.Text) > 0 then begin Pninfo.Caption := Conv('不可使用特殊符号.'); EditChar.SetFocus; exit; end;
   if Pos (',', CBVillage.text) > 0 then begin Pninfo.Caption := Conv('不可使用特殊符号.'); CBVillage.SetFocus; exit; end;

   ccc.rmsg := CM_CREATECHAR;
   StrPCopy (@ccc.rchar, EditChar.Text);

   if LbSex.Caption = Conv('男') then ccc.rsex := 0
   else ccc.rsex := 1;

   StrPCopy (@ccc.rVillage, CBVillage.Text);
   StrPCopy (@ccc.rServer, '');

   FrmLogOn.SocketAddData (sizeof(ccc), @ccc);
end;

procedure TFrmSelChar.BtnSelectClick(Sender: TObject);
var csc : TCSelectChar;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   csc.rmsg := CM_SELECTCHAR;
   StrPCopy (@csc.rchar, listbox1.Items[Listbox1.Itemindex]);
   FrmLogOn.SocketAddData (sizeof(csc), @csc);
end;

procedure TFrmSelChar.EditPassWordKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = char (VK_ESCAPE)) or (key = char(VK_RETURN)) then key := char(0);
end;

procedure TFrmSelChar.ListBox1DblClick(Sender: TObject);
begin
   BtnSelectClick(Sender);
end;

procedure TFrmSelChar.ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if key = VK_RETURN then BtnSelectClick(Sender);
end;

procedure TFrmSelChar.FormHide(Sender: TObject);
begin
   if boCommandHide = FALSE then FrmM.Close;
end;

procedure TFrmSelChar.MyHide;
begin
   boCommandHide := TRUE;
   Visible := FALSE;
   boCommandHide := FALSE;
end;

procedure TFrmSelChar.MyShow;
var csc : TCSelectChar;
begin
   boCommandHide := FALSE;
   Visible := TRUE;
   if ReConnectChar <> '' then begin
      csc.rmsg := CM_SELECTCHAR;
      StrPCopy (@csc.rchar, ReConnectChar);
      FrmLogOn.SocketAddData (sizeof(csc), @csc);
      ReConnectChar := '';
   end;
   ListBox1.SetFocus;
end;

procedure TFrmSelChar.FormShow(Sender: TObject);
begin
   if FileExists ('ect\Village.txt') then begin
      CBVillage.Items.LoadFromFile ('ect\village.txt');
      if CBVillage.Items.Count >= 1 then CBVillage.Text := CBVillage.Items[0];
   end;
end;

procedure TFrmSelChar.BtnRealClick(Sender: TObject);
begin
   FrmUpDateId.ShowModal;
end;

procedure TFrmSelChar.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self, A2form);
   Left := 0; Top := 0;
   SetFormText;
   LbSex.Font.Name := mainFont;
   CBVillage.Font.Name := mainFont;
   EditPassWord.Font.Name := mainFont;
   EditConfirm.Font.Name := mainFont;
   Pninfo.Font.Name := mainFont;
end;


procedure TFrmSelChar.BtnWaManClick(Sender: TObject);
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   LbSex.Caption := Conv('女');
end;

procedure TFrmSelChar.BtnManClick(Sender: TObject);
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   LbSex.Caption := Conv('男');
end;

end.

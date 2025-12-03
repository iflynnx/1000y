unit FNewUser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, autil32, deftype, ExtCtrls, A2Form, Atzcls,
  uResidentRegistrationNumber, A2Img;

type
  TFrmNewUser = class(TForm)
    A2Form: TA2Form;
    BtnOk: TA2Button;
    BtnCancel: TA2Button;
    BtnReal: TA2Button;
    Label6: TA2Label;
    Label8: TA2Label;
    EditID: TA2Edit;
    EditPassWord: TA2Edit;
    EditMasterKey: TA2Edit;
    EditConfirm: TA2Edit;
    EditName: TA2Edit;
    EditBirth: TA2Edit;
    EditKoreaId: TA2Edit;
    A2EditTel: TA2Edit;
    A2EditEMail: TA2Edit;
    Pninfo: TA2Label;
    A2ILabel14down: TA2ILabel;
    A2ILabel14up: TA2ILabel;
    A2ILabel_Opinion: TA2ILabel;
    A2Edit_parentName: TA2Edit;
    A2Edit_parentKoreaID: TA2Edit;
    A2Edit_parentBirth: TA2Edit;
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure EditPassWordEnter(Sender: TObject);
    procedure EditConfirmEnter(Sender: TObject);
    procedure EditMasterKeyEnter(Sender: TObject);
    procedure EditNameEnter(Sender: TObject);
    procedure EditKoreaIdEnter(Sender: TObject);
    procedure EditBirthEnter(Sender: TObject);
    procedure BtnRealClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure A2ILabel14upClick(Sender: TObject);
    procedure A2ILabel14downClick(Sender: TObject);
    procedure A2EditTelEnter(Sender: TObject);
    procedure A2EditEMailEnter(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure A2Edit_parentNameEnter(Sender: TObject);
    procedure A2Edit_parentBirthEnter(Sender: TObject);
    procedure A2Edit_parentKoreaIDEnter(Sender: TObject);
  private
    OpinionImage : TA2Image;
    parentAccept : Boolean;
  public
    procedure SetFormText;
    procedure Set14Down(value: Boolean);
    procedure SetImage;
  end;

var
   FrmNewUser: TFrmNewUser;

implementation

uses FLogOn, FMain;

{$R *.DFM}

procedure TFrmNewUser.SetFormText;
begin
   Caption := Conv('千年[建立新名称]');
   Label6.Caption := Conv('连线名称只能使用英文字母,此名称即是登入ID.');
   Label8.Caption := Conv('请务必输入本人名称及出生年月日.');
   Pninfo.Caption := Conv('建立新名称.');
end;

procedure TFrmNewUser.FormCreate(Sender: TObject);
begin
   OpinionImage := nil;
   parentAccept := FALSE;
   Left := 0; Top := 0;
   FrmM.AddA2Form (Self, A2form);
   SetFormText;
   SetImage;
end;

procedure TFrmNewUser.FormDestroy(Sender: TObject);
begin
   if OpinionImage <> nil then OpinionImage.Free;
   OpinionImage := nil;
end;

procedure TFrmNewUser.FormHide(Sender: TObject);
begin
//   ModalResult := 0;
   FrmLogon.Visible := TRUE;
end;

procedure TFrmNewUser.FormShow(Sender: TObject);
begin
   Set14Down (FALSE);
   BtnOk.Enabled := TRUE;
   EditName.Enabled := FALSE;
   EditBirth.Enabled := FALSE;
   EditKoreaId.Enabled := FALSE;
   EditName.Text := '';
   EditBirth.Text := '';
   EditKoreaId.Text := '';

   EditName.Color := clBtnFace;
   EditBirth.Color := clBtnFace;
   EditKoreaId.Color := clBtnFace;
   SetImage;
   A2Edit_parentName.Text := '';
   A2Edit_parentBirth.Text := '';
   A2Edit_parentKoreaID.Text := '';
   SetFormText;
end;

procedure TFrmNewUser.BtnCancelClick(Sender: TObject);
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   Visible := FALSE;
   FrmLogon.Visible := TRUE;
//   ModalResult := -1;

end;

procedure TFrmNewUser.EditKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = char (VK_ESCAPE)) or (key = char(VK_RETURN)) then key := char(0);
end;

procedure TFrmNewUser.BtnOkClick(Sender: TObject);
var
   cCCreateIdPass3 : TCCreateIdPass3;
begin
   if (A2ILabel14up.A2Image = nil) and (A2ILabel14down.A2Image = nil) then begin
      pninfo.Caption := '未满14周岁,需家长陪同.';
      Set14Down (FALSE);
      exit;
   end;
   if not A2ILabel14down.Enabled then begin
      if Pos (',', A2Edit_parentName.Text) > 0  then begin Pninfo.Caption := Conv('本人名称输入错误.'); A2Edit_parentName.SetFocus; exit; end;
      if A2Edit_parentName.Text = '' then begin Pninfo.Caption := Conv('本人名称输入错误.'); A2Edit_parentName.SetFocus; exit; end;
      if Pos (',', A2Edit_parentBirth.Text) > 0  then begin Pninfo.Caption := Conv('身份证号码输入错误.'); A2Edit_parentBirth.SetFocus; exit; end;
      if not IsNumeric (A2Edit_parentBirth.Text) then begin Pninfo.Caption := Conv('只能输入阿拉伯数字.'); A2Edit_parentBirth.SetFocus; exit; end;
      if Length (A2Edit_parentBirth.Text) <> 6 then begin Pninfo.Caption := Conv('请输入6位阿拉伯数字'); A2Edit_parentBirth.SetFocus; exit; end;

      if Pos (',', A2Edit_parentKoreaID.Text) > 0  then begin Pninfo.Caption := Conv('身份证号码输入错误.'); A2Edit_parentKoreaID.SetFocus; exit; end;
      if not IsNumeric (A2Edit_parentKoreaID.Text) then begin Pninfo.Caption := Conv('只能输入阿拉伯数字.'); A2Edit_parentKoreaID.SetFocus; exit; end;
      if Length (A2Edit_parentKoreaID.Text) <> 7 then begin Pninfo.Caption := Conv('请输入7位阿拉伯数字'); A2Edit_parentKoreaID.SetFocus; exit; end;
      if not checkResidentRegistrationNumber (A2Edit_parentBirth.Text+A2Edit_parentKoreaID.Text) then begin Pninfo.Caption := Conv('无效的身份证号码.'); A2Edit_parentBirth.SetFocus; exit; end;

      parentAccept := TRUE;
      pninfo.Caption := '';
      Set14Down (FALSE);
      exit;
   end;

   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   if Length (EditId.Text) < 4 then begin Pninfo.Caption := Conv('连线名称必须4个字以上.'); EditId.SetFocus; exit; end;
   if not isEngNumeric (EditId.Text) then begin Pninfo.Caption := Conv('英文字母与阿拉伯数字组合使用.'); EditId.SetFocus; exit; end;

   if Length (EditPassWord.Text) < 4 then begin Pninfo.Caption := Conv('密码必须4个字以上.'); EditPassWord.SetFocus; exit; end;
   if not isEngNumeric (EditPassWord.Text) then begin Pninfo.Caption := Conv('英文字母与阿拉伯数字组合使用.'); EditPassWord.SetFocus; exit; end;
   if EditPassWord.Text <> EditConfirm.Text then begin Pninfo.Caption := Conv('密码确认输入错误.'); EditConfirm.SetFocus; exit; end;

   if Pos (',', EditMasterKey.Text) > 0  then begin Pninfo.Caption := Conv('钥匙单字输入错误.'); EditMasterKey.SetFocus; exit; end;
   if EditMasterKey.Text = '' then begin Pninfo.Caption := Conv('钥匙单字输入错误.'); EditMasterKey.SetFocus; exit; end;

   if EditName.Enabled = FALSE then begin
      Pninfo.Caption := Conv('请按[实名确认]键.');
      exit;
   end;

   if Pos (',', EditName.Text) > 0  then begin Pninfo.Caption := Conv('本人名称输入错误.'); EditName.SetFocus; exit; end;
   if EditName.Text = '' then begin Pninfo.Caption := Conv('本人名称输入错误.'); EditName.SetFocus; exit; end;
   if Pos (',', EditBirth.Text) > 0  then begin Pninfo.Caption := Conv('身份证号码输入错误.'); EditBirth.SetFocus; exit; end;
   if not IsNumeric (EditBirth.Text) then begin Pninfo.Caption := Conv('只能输入阿拉伯数字.'); EditBirth.SetFocus; exit; end;
   if Length (EditBirth.Text) <> 6 then begin Pninfo.Caption := Conv('请输入6位阿拉伯数字'); EditBirth.SetFocus; exit; end;

   if Pos (',', EditKoreaId.Text) > 0  then begin Pninfo.Caption := Conv('身份证号码输入错误.'); EditKoreaId.SetFocus; exit; end;
   if not IsNumeric (EditKoreaId.Text) then begin Pninfo.Caption := Conv('只能输入阿拉伯数字.'); EditKoreaId.SetFocus; exit; end;
   if Length (EditKoreaId.Text) <> 7 then begin Pninfo.Caption := Conv('请输入7位阿拉伯数字'); EditKoreaId.SetFocus; exit; end;
   if not checkResidentRegistrationNumber (EditBirth.Text+EditKoreaId.Text) then begin Pninfo.Caption := Conv('无效的身份证号码.'); EditBirth.SetFocus; exit; end;

   fillchar (cCCreateIdPass3, sizeof(cCCreateIdPass3), 0);
   with cCCreateIdPass3 do begin
      rMsg := CM_CREATEIDPASS3;
      rID := EditId.Text;
      rPass := EditPassWord.Text;
      rName := EditName.Text;
      rNativeNumber := EditBirth.Text + '-' + EditKoreaId.Text;
      rMasterKey := EditMasterKey.Text;
      rEmail := A2EditEMail.Text;
      rPhone := A2EditTel.Text;
      rParentName := A2Edit_parentName.Text;
      rParentNativeNumber := A2Edit_parentBirth.Text + '-' + A2Edit_parentKoreaID.Text;
   end;
   FrmLogOn.SocketAddData (sizeof(cCCreateIdPass3), @cCCreateIdPass3);
end;

procedure TFrmNewUser.EditIDEnter(Sender: TObject);
begin
   Label6.Caption := Conv('连线名称只能使用英文字母,此名称即是登入ID.');
   Label8.Caption := Conv('连线名称只能最多建立5个连线角色.');
end;

procedure TFrmNewUser.EditPassWordEnter(Sender: TObject);
begin
   Label6.Caption := Conv('密码必须为4-12位.');
   Label8.Caption := Conv('请输入密码.');
end;

procedure TFrmNewUser.EditConfirmEnter(Sender: TObject);
begin
   Label6.Caption := Conv('密码必须为4-12位.');
   Label8.Caption := Conv('请确认密码.');
end;

procedure TFrmNewUser.EditMasterKeyEnter(Sender: TObject);
begin
   Label6.Caption := Conv('变更密码时所需要的单字.');
   Label8.Caption := Conv('请输入别人无法知晓的单字.');
end;

procedure TFrmNewUser.EditNameEnter(Sender: TObject);
begin
   Label6.Caption := Conv('连线名称拥有者的名称.');
   Label8.Caption := Conv('输入本人名称(实名).');
end;

procedure TFrmNewUser.EditKoreaIdEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入本人的身份证号码.');
   Label8.Caption := Conv('确认连线名称拥有者时,输入本人名称及身份证号码.');
end;

procedure TFrmNewUser.EditBirthEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入本人的身份证号码.');
   Label8.Caption := Conv('确认连线名称拥有者时,输入本人名称及身份证号码.');
end;

procedure TFrmNewUser.BtnRealClick(Sender: TObject);
var
   n : integer;
   tempstr : string;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   tempstr :=
   Conv('实名确认.') + #13 +
   Conv('请正确输入本人名称与身份证号码.') + #13 +
   Conv('您同意以实名登入吗?');

   n := Application.MessageBox( PChar(tempstr), Pchar(Conv('千年')), 1);
   if n <> 1 then begin
      PnInfo.Caption := Conv('请按[实名确认]键.');
      BtnOk.Enabled := TRUE;

      EditName.Enabled := FALSE;
      EditBirth.Enabled := FALSE;
      EditKoreaId.Enabled := FALSE;

      EditName.Color := clBtnFace;
      EditBirth.Color := clBtnFace;
      EditKoreaId.Color := clBtnFace;
      exit;
   end;

   PnInfo.Caption := Conv('已同意实名确认.');

   EditName.Enabled := TRUE;
   EditBirth.Enabled := TRUE;
   EditKoreaId.Enabled := TRUE;

   EditName.Color := clWhite;
   EditBirth.Color := clWhite;
   EditKoreaId.Color := clWhite;

   EditName.SetFocus;
end;

procedure TFrmNewUser.SetImage;
begin
   // FrmNewUser Set Font
   FrmNewUser.Font.Name := mainFont;
   EditID.Font.Name := mainFont;
   EditPassWord.Font.Name := mainFont;
   EditMasterKey.Font.Name := mainFont;
   EditConfirm.Font.Name := mainFont;
   EditName.Font.Name := mainFont;
   EditBirth.Font.Name := mainFont;
   EditKoreaId.Font.Name := mainFont;
   Label6.Font.Name := mainFont;
   Label8.Font.Name := mainFont;
   Pninfo.Font.Name := mainFont;
   A2EditEMail.Font.Name := mainFont;
   A2EditTel.Font.Name := mainFont;

   BtnReal.SetUpA2Image (EtcAtzClass.GetEtcAtz (113));
   BtnReal.SetDownA2Image (EtcAtzClass.GetEtcAtz (114));
   BtnOk.SetUpA2Image (EtcAtzClass.GetEtcAtz (115));
   BtnOk.SetDownA2Image (EtcAtzClass.GetEtcAtz (116));
   BtnCancel.SetUpA2Image (EtcAtzClass.GetEtcAtz (117));
   BtnCancel.SetDownA2Image (EtcAtzClass.GetEtcAtz (118));
   A2ILabel14up.A2Image := nil;
   A2ILabel14down.A2Image := nil;
end;

procedure TFrmNewUser.A2ILabel14upClick(Sender: TObject);
begin
   A2ILabel14down.A2Image := nil;
   A2ILabel14up.A2Image := (EtcAtzClass.GetEtcAtz (112));
   pninfo.Caption := '';
end;

procedure TFrmNewUser.A2ILabel14downClick(Sender: TObject);
begin
   A2ILabel14up.A2Image := nil;
   A2ILabel14down.A2Image := (EtcAtzClass.GetEtcAtz (112));
   if parentAccept then exit;
   if OpinionImage = nil then begin
      OpinionImage := TA2Image.Create (A2ILabel_Opinion.Width, A2ILabel_Opinion.Height, 0, 0);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (119), 0, 0, FALSE);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (120), 136, 0, FALSE);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (121), 272, 0, FALSE);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (122), 0, 136, FALSE);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (123), 136, 136, FALSE);
      OpinionImage.DrawImage (EtcAtzClass.GetEtcAtz (124), 272, 136, FALSE);
      A2ILabel_Opinion.A2Image := OpinionImage;
   end;
   parentAccept := FALSE;
   pninfo.Caption := '';
   Set14Down (TRUE);
end;

procedure TFrmNewUser.A2EditTelEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入您的电话号码.');
   Label8.Caption := Conv('请输入能与您通讯的有效方式.');
end;

procedure TFrmNewUser.A2EditEMailEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入您的E-Mail地址.');
   Label8.Caption := Conv('请输入能与您通讯的有效方式.');
end;

procedure TFrmNewUser.Set14Down (value: Boolean);
begin
   EditID.Enabled := not value;
   EditID.Visible := not value;
   EditPassWord.Enabled := not value;
   EditPassWord.Visible := not value;
   EditMasterKey.Enabled := not value;
   EditMasterKey.Visible := not value;
   EditConfirm.Enabled := not value;
   EditConfirm.Visible := not value;
   A2ILabel14up.Enabled := not value;
   A2ILabel14up.Visible := not value;
   A2ILabel14down.Enabled := not value;
   A2ILabel14down.Visible := not value;
   EditName.Enabled := not value;
   EditName.Visible := not value;
   EditBirth.Enabled := not value;
   EditBirth.Visible := not value;
   EditKoreaId.Enabled := not value;
   EditKoreaId.Visible := not value;
   BtnReal.Enabled := not value;
   BtnReal.Visible:= not value;
   A2EditTel.Enabled := not value;
   A2EditTel.Visible := not value;
   A2EditEMail.Enabled := not value;
   A2EditEMail.Visible := not value;

   A2ILabel_Opinion.Visible := value;
   A2Edit_parentName.Enabled := value;
   A2Edit_parentName.Visible := value;
   A2Edit_parentBirth.Enabled := value;
   A2Edit_parentBirth.Visible := value;
   A2Edit_parentKoreaID.Enabled := value;
   A2Edit_parentKoreaID.Visible := value;
end;


procedure TFrmNewUser.A2Edit_parentNameEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入您父母的名称.');
   Label8.Caption := Conv('');
   Pninfo.Caption := Conv('');
end;

procedure TFrmNewUser.A2Edit_parentBirthEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入您父母的身份证号码.');
   Label8.Caption := Conv('');
   Pninfo.Caption := Conv('');
end;

procedure TFrmNewUser.A2Edit_parentKoreaIDEnter(Sender: TObject);
begin
   Label6.Caption := Conv('请输入您父母的身份证号码.');
   Label8.Caption := Conv('');
   Pninfo.Caption := Conv('');
end;

end.

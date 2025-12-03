unit FMuMagicOffer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, A2Form, ExtCtrls, Deftype, AtzCls, jpeg, AUtil32;

type
  TFrmMuMagicOffer = class(TForm)
    A2ILabel0: TA2ILabel;
    A2ILabel1: TA2ILabel;
    A2ILabel2: TA2ILabel;
    A2ILabel3: TA2ILabel;
    A2ILabel4: TA2ILabel;
    A2ILabel5: TA2ILabel;
    A2ILabel6: TA2ILabel;
    A2ILabel7: TA2ILabel;
    A2ILabel11: TA2ILabel;
    A2ILabel15: TA2ILabel;
    A2ILabel18: TA2ILabel;
    A2ILabel8: TA2ILabel;
    A2ILabel12: TA2ILabel;
    A2ILabel16: TA2ILabel;
    A2ILabel19: TA2ILabel;
    A2ILabel9: TA2ILabel;
    A2ILabel13: TA2ILabel;
    A2ILabel17: TA2ILabel;
    A2ILabel20: TA2ILabel;
    A2ILabel10: TA2ILabel;
    A2ILabel14: TA2ILabel;
    A2ILabel21: TA2ILabel;
    A2Edit2: TA2Edit;
    A2EditSpeed: TA2Edit;
    A2EditDamageHead: TA2Edit;
    A2EditArmorHead: TA2Edit;
    A2EditOutPower: TA2Edit;
    A2EditInPower: TA2Edit;
    A2EditArmorArm: TA2Edit;
    A2EditDamageArm: TA2Edit;
    A2EditDamegeBody: TA2Edit;
    A2EditMagicPower: TA2Edit;
    A2EditArmorLeg: TA2Edit;
    A2EditDamageLeg: TA2Edit;
    A2EditRecovery: TA2Edit;
    A2EditLife: TA2Edit;
    A2EditArmorBody: TA2Edit;
    A2EditAvoid: TA2Edit;
    A2ButtonOk: TA2Button;
    A2ButtonCancel: TA2Button;
    A2LabelMsg1: TA2Label;
    A2LabelMsg2: TA2Label;
    A2Form: TA2Form;
    A2ILabelCaption: TA2ILabel;
    A2ILabelMagic: TA2ILabel;
    procedure A2ButtonOkClick(Sender: TObject);
    procedure A2ButtonCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure A2ILabel2Click(Sender: TObject);
    procedure A2ILabel3Click(Sender: TObject);
    procedure A2ILabel4Click(Sender: TObject);
    procedure A2ILabel5Click(Sender: TObject);
    procedure A2ILabel6Click(Sender: TObject);
    procedure A2Edit2KeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditSpeedKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditDamegeBodyKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditRecoveryKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditAvoidKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditDamageHeadKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditDamageArmKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditDamageLegKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditArmorBodyKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditArmorHeadKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditArmorArmKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditArmorLegKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditOutPowerKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditInPowerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditMagicPowerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure A2EditLifeKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure A2EditSpeedMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure A2EditRecoveryMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure A2EditDamageHeadMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure A2EditOutPowerMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure A2Edit2MouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
  private
     MMagicOfferType : Byte;
  public
     procedure MessageProcess (var code: TWordComData);
     procedure SetPostion;
     procedure SetImage;
  end;

var
  FrmMuMagicOffer: TFrmMuMagicOffer;

implementation

uses
   FMain, FAttrib, FBottom, FLogOn;

{$R *.DFM}

procedure TFrmMuMagicOffer.MessageProcess (var code: TWordComData);
var
   PTSSShowGuildMagicWindow : PTSShowGuildMagicWindow;
begin
   PTSSShowGuildMagicWindow := @Code.Data;
   case PTSSShowGuildMagicWindow^.rWindow of
      WINDOW_GUILDMAGIC :
         begin
            with PTSSShowGuildMagicWindow^ do begin
            {
               A2EditSpeed.Text := IntToStr(rSpeed);
               A2EditDamegeBody.Text := IntToStr(rDamageBody);

               A2EditRecovery.Text := IntToStr(rRecovery);
               A2EditAvoid.Text := IntToStr(rAvoid);

               A2EditDamageHead.Text := IntToStr(rDamageHead);
               A2EditDamageArm.Text := IntToStr(rDamageArm);
               A2EditDamageLeg.Text := IntToStr(rDamageLeg);
               A2EditArmorBody.Text := IntToStr(rArmorBody);
               A2EditArmorHead.Text := IntToStr(rArmorHead);
               A2EditArmorArm.Text := IntToStr(rArmorArm);
               A2EditArmorLeg.Text := IntToStr(rArmorLeg);

               A2EditOutPower.Text := IntToStr(rOutPower);
               A2EditInPower.Text := IntToStr(rInPower);
               A2EditMagicPower.Text := IntToStr(rMagicPower);
               A2EditLife.Text := IntToStr(rLife);
               }
               FrmMuMagicOffer.Visible := TRUE;
            end;
         end;

   end;
end;

procedure TFrmMuMagicOffer.SetPostion;
begin
   if FrmAttrib.Visible then begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := ((640 - FrmAttrib.Width) div 2) - (Width div 2);
   end else begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := (640 div 2) - (Width div 2);
   end;
end;

procedure TFrmMuMagicOffer.SetImage;
var
   i : integer;
begin
   for i := 0 to 21 do begin
      TA2ILabel (FindComponent('A2ILabel'+IntToStr(i) )).A2Image := EtcAtzClass.GetEtcAtz (75+i);
   end;
   A2ButtonOk.SetUpA2Image(EtcAtzClass.GetEtcAtz (97));
   A2ButtonOk.SetDownA2Image(EtcAtzClass.GetEtcAtz (98));
   A2ButtonCanCel.SetUpA2Image(EtcAtzClass.GetEtcAtz (41));
   A2ButtonCanCel.SetDownA2Image(EtcAtzClass.GetEtcAtz (42));
   A2ILabelCaption.A2Image := EtcAtzClass.GetEtcAtz (74);
   A2ILabelMagic.A2Image := EtcAtzClass.GetEtcAtz (99);
end;

procedure TFrmMuMagicOffer.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 0;
   Left := 0;
   SetImage;
end;

procedure TFrmMuMagicOffer.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmMuMagicOffer.FormShow(Sender: TObject);
begin
   SetPostion;
   A2Edit2.SetFocus;
   A2LabelMsg1.Caption := Conv('请输入门派武功名称');
   A2LabelMsg2.Caption := '';
//   MMagicOfferType := MAGICTYPE_WRESTLING;
end;

procedure TFrmMuMagicOffer.A2ButtonOkClick(Sender: TObject);
var
   CGuildMagicData : TCGuildMagicData;
begin
   with CGuildMagicData do begin
      rMsg := CM_MAKEGUILDMAGIC;
      rWindow := WINDOW_GUILDMAGIC;

      rSpeed := _StrToInt(A2EditSpeed.Text);
      rDamageBody := _StrToInt(A2EditDamegeBody.Text);

      rMagicName := A2Edit2.Text;
      rMagicType := MMagicOfferType;
      rRecovery := _StrToInt(A2EditRecovery.Text);
      rAvoid := _StrToInt(A2EditAvoid.Text);

      rDamageHead := _StrToInt(A2EditDamageHead.Text);
      rDamageArm := _StrToInt(A2EditDamageArm.Text);
      rDamageLeg := _StrToInt(A2EditDamageLeg.Text);
      rArmorBody := _StrToInt(A2EditArmorBody.Text);
      rArmorHead := _StrToInt(A2EditArmorHead.Text);
      rArmorArm := _StrToInt(A2EditArmorArm.Text);
      rArmorLeg := _StrToInt(A2EditArmorLeg.Text);

      rOutPower := _StrToInt(A2EditOutPower.Text);
      rInPower := _StrToInt(A2EditInPower.Text);
      rMagicPower := _StrToInt(A2EditMagicPower.Text);
      rLife := _StrToInt(A2EditLife.Text);
      FrmLogon.SocketAddData (sizeof(CGuildMagicData), @CGuildMagicData);
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
   FrmMuMagicOffer.Visible := FALSE;
end;

procedure TFrmMuMagicOffer.A2ButtonCancelClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
   CCWindowConfirm.rWindow := WINDOW_GUILDMAGIC;
   cCWindowConfirm.rboCheck := FALSE;
   cCWindowConfirm.rButton := 0; // 滚瓢捞 咯妨俺 乐阑版快父 荤侩 老馆篮 0捞 檬扁蔼
   FrmLogon.SocketAddData (sizeof(cCWindowConfirm), @cCWindowConfirm);
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
   FrmMuMagicOffer.Visible := FALSE;
end;

procedure TFrmMuMagicOffer.A2ILabel2Click(Sender: TObject);
begin // 拳法
   MMagicOfferType := MAGICTYPE_WRESTLING;
   if not A2ILabelMagic.Visible then A2ILabelMagic.Visible := TRUE;
   A2ILabelMagic.Left := 47;
end;

procedure TFrmMuMagicOffer.A2ILabel3Click(Sender: TObject);
begin // 剑法
   MMagicOfferType := MAGICTYPE_FENCING;
   if not A2ILabelMagic.Visible then A2ILabelMagic.Visible := TRUE;
   A2ILabelMagic.Left := 107;
end;

procedure TFrmMuMagicOffer.A2ILabel4Click(Sender: TObject);
begin // 刀法
   MMagicOfferType := MAGICTYPE_SWORDSHIP;
   if not A2ILabelMagic.Visible then A2ILabelMagic.Visible := TRUE;
   A2ILabelMagic.Left := 168;
end;

procedure TFrmMuMagicOffer.A2ILabel5Click(Sender: TObject);
begin // 槌法
   MMagicOfferType := MAGICTYPE_HAMMERING;
   if not A2ILabelMagic.Visible then A2ILabelMagic.Visible := TRUE;
   A2ILabelMagic.Left := 231;
end;

procedure TFrmMuMagicOffer.A2ILabel6Click(Sender: TObject);
begin // 枪术
   MMagicOfferType := MAGICTYPE_SPEARING;
   if not A2ILabelMagic.Visible then A2ILabelMagic.Visible := TRUE;
   A2ILabelMagic.Left := 291;
end;

procedure TFrmMuMagicOffer.A2Edit2KeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditSpeed.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditSpeedKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditDamegeBody.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditDamegeBodyKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditRecovery.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditRecoveryKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditAvoid.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditAvoidKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditDamageHead.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditDamageHeadKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditArmorArm.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditDamageArmKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditDamageLeg.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditDamageLegKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditArmorBody.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditArmorBodyKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditArmorHead.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditArmorHeadKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditArmorArm.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditArmorArmKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditArmorLeg.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditArmorLegKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditOutPower.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditOutPowerKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditInPower.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditInPowerKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditMagicPower.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditMagicPowerKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if key = 13 then A2EditLife.SetFocus;
end;

procedure TFrmMuMagicOffer.A2EditLifeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if key = 13 then begin
      if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
   end;
end;

procedure TFrmMuMagicOffer.A2EditSpeedMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin // 傍拜加档
   A2LabelMsg1.Caption := Conv('攻击速度 + 身体攻击 总合为 100 值')+ '(' + IntToStr(_StrToInt(A2EditSpeed.text) + _StrToInt(A2EditDamegeBody.Text))+')';
   A2LabelMsg2.Caption :='';
end;

procedure TFrmMuMagicOffer.A2EditRecoveryMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin //磊技焊沥
   A2LabelMsg1.Caption := Conv('恢复 + 躲闪 总合为 100 值')+'('+IntToStr(_StrToInt(A2EditRecovery.text)+_StrToInt(A2EditAvoid.Text))+')';
   A2LabelMsg2.Caption :='';
end;

procedure TFrmMuMagicOffer.A2EditDamageHeadMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   A2LabelMsg1.Caption := Conv('头部攻击 + 臂部攻击 + 腿部攻击 + 身体攻击 + 头部防御');
   A2LabelMsg2.Caption := Conv('+ 臂部防御 + 腿部防御 总和为 228 值')+'('+
                          IntToStr(_StrToInt(A2EditDamageHead.text)+_StrToInt(A2EditDamageArm.Text)+
                          _StrToInt(A2EditDamageLeg.text)+_StrToInt(A2EditArmorBody.Text)+
                          _StrToInt(A2EditArmorHead.text)+_StrToInt(A2EditArmorArm.Text)+
                          _StrToInt(A2EditArmorLeg.text))+')';
end;

procedure TFrmMuMagicOffer.A2EditOutPowerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   A2LabelMsg1.Caption := Conv('外功消耗 + 内功消耗 + 武功消耗 +');
   A2LabelMsg2.Caption := Conv('活力消耗 总合为 80 值')+'('+
                          IntToStr(_StrToInt(A2EditInPower.text)+_StrToInt(A2EditOutPower.Text)+
                          _StrToInt(A2EditMagicPower.text)+_StrToInt(A2EditLife.Text))+')';
end;

procedure TFrmMuMagicOffer.A2Edit2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   A2LabelMsg1.Caption := Conv('请输入门派武功名称');
   A2LabelMsg2.Caption := '';
end;

end.

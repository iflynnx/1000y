program Client;

uses
  Windows,
  Forms,
  FLogOn in 'FLogOn.pas' {FrmLogOn},
  FNewUser in 'FNewUser.pas' {FrmNewUser},
  FSelChar in 'FSelChar.pas' {FrmSelChar},
  CLMap in 'CLMap.pas',
  CTable in 'CTable.pas',
  dll_Sock in 'dll_Sock.pas',
  USound in 'Usound.pas',
  deftype in '..\1000ydef\deftype.pas',
  TileCls in 'TileCls.pas',
  ObjCls in 'objcls.pas',
  FMain in 'FMain.pas' {FrmM},
  FBottom in 'FBottom.pas' {FrmBottom},
  FAttrib in 'FAttrib.pas' {FrmAttrib},
  SubUtil in '..\1000ydef\SubUtil.pas',
  FExchange in 'FExchange.pas' {FrmExchange},
  FSearch in 'FSearch.pas' {FrmSearch},
  FQuantity in 'FQuantity.pas' {FrmQuantity},
  FSound in 'FSound.pas' {FrmSound},
  Log in '..\1000ydef\Log.pas',
  FDepository in 'FDepository.pas' {FrmDepository},
  FSearchUser in 'FSearchUser.pas' {FrmSearchUser},
  FcMessageBox in 'FcMessageBox.pas' {FrmcMessageBox},
  uPersonBat in 'uPersonBat.pas',
  FbatList in 'FbatList.pas' {FrmbatList},
  FMuMagicOffer in 'FMuMagicOffer.pas' {FrmMuMagicOffer},
  uBuffer in '..\common\uBuffer.pas',
  uCrypt in '..\common\uCrypt.pas',
  uPackets in '..\common\uPackets.pas',
  FStipulation in 'FStipulation.pas' {FrmStipulation},
  BSCommon in '..\common\BSCommon.pas';

{$R *.RES}

//var
//   buffer : array [0..128] of byte;
//   SelfHandle : integer;

begin
  Application.Initialize;
{
  SelfHandle := FindWindow ('TApplication', 'Client');
  StrPCopy (@Buffer, '¾ÆÇ×');
  SetWindowText (SelfHandle, @buffer);
}
  Application.CreateForm(TFrmM, FrmM);
  Application.CreateForm(TFrmLogOn, FrmLogOn);
  Application.CreateForm(TFrmNewUser, FrmNewUser);
  Application.CreateForm(TFrmSelChar, FrmSelChar);
  Application.CreateForm(TFrmBottom, FrmBottom);
  Application.CreateForm(TFrmAttrib, FrmAttrib);
  Application.CreateForm(TFrmExchange, FrmExchange);
  Application.CreateForm(TFrmSearch, FrmSearch);
  Application.CreateForm(TFrmQuantity, FrmQuantity);
  Application.CreateForm(TFrmSound, FrmSound);
  Application.CreateForm(TFrmDepository, FrmDepository);
  Application.CreateForm(TFrmSearchUser, FrmSearchUser);
  Application.CreateForm(TFrmcMessageBox, FrmcMessageBox);
  Application.CreateForm(TFrmbatList, FrmbatList);
  Application.CreateForm(TFrmMuMagicOffer, FrmMuMagicOffer);
  Application.CreateForm(TFrmStipulation, FrmStipulation);
  Application.Run;
end.

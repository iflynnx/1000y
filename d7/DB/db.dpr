program db;

uses
  Forms,
  FMain in 'FMain.pas' {frmMain},
  uConnector in 'uConnector.pas',
  uBuffer in '..\common\uBuffer.pas',
  uDBProvider in '..\common\uDBProvider.pas',
  uUtil in '..\common\uUtil.pas',
  uRemoteConnector in 'uRemoteConnector.pas',
  uPackets in '..\common\uPackets.pas',
  uCrypt in '..\common\uCrypt.pas',
  uEasyList in '..\common\uEasyList.pas',
  uKeyClass in '..\common\uKeyClass.pas',
  uRecordDef in 'uRecordDef.pas',
  deftype in '..\1000ydef\deftype.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

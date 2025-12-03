program gate;

uses
  Forms,
  FMain in 'FMain.pas' {frmMain},
  uConnector in 'uConnector.pas',
  uBuffer in '..\common\uBuffer.pas',
  uUtil in '..\common\uUtil.pas',
  uLGRecordDef in '..\common\uLGRecordDef.pas',
  uDBRecordDef in '..\common\uDBRecordDef.pas',
  uPackets in '..\common\uPackets.pas',
  uEasyList in '..\common\uEasyList.pas',
  uCrypt in '..\common\uCrypt.pas',
  uKeyClass in '..\common\uKeyClass.pas',
  uGramerId in '..\1000ydef\uGramerId.pas',
  deftype in '..\1000ydef\deftype.pas',
  Common in '..\common\Common.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

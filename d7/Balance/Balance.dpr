program Balance;

uses
  Forms,
  FMain in 'FMain.pas' {frmMain},
  uUtil in '..\common\uUtil.pas',
  uBuffer in '..\common\uBuffer.pas',
  uCrypt in '..\common\uCrypt.pas',
  uPackets in '..\common\uPackets.pas',
  deftype in '..\1000ydef\deftype.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

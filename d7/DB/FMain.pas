unit FMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, StdCtrls, ComCtrls, iniFiles, mmSystem, uRecordDef, ExtCtrls,
  uKeyClass;

type
  TfrmMain = class(TForm)
    sckRemoteAccept: TServerSocket;
    cmdClose: TButton;
    PageControl1: TPageControl;
    tsEvent: TTabSheet;
    tsMonitor: TTabSheet;
    lstEvent: TListBox;
    txtLog: TMemo;
    sckAccept: TServerSocket;
    cmdAddRecord: TButton;
    tsStatus: TTabSheet;
    StaticText1: TStaticText;
    lblTotalRecordCount: TStaticText;
    StaticText3: TStaticText;
    lblUsedRecordCount: TStaticText;
    StaticText5: TStaticText;
    lblUnusedRecordCount: TStaticText;
    timerDisplay: TTimer;
    timerProcess: TTimer;
    StaticText7: TStaticText;
    lblGateConnectCount: TStaticText;
    StaticText9: TStaticText;
    lblRemoteConnectCount: TStaticText;
    StaticText11: TStaticText;
    lblElaspedTime: TStaticText;
    cmdSaveUserData: TButton;
    cmdBackup: TButton;
    StaticText2: TStaticText;
    lblLockedCount: TStaticText;
    sckItemRemote: TServerSocket;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
    procedure sckRemoteAcceptAccept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckRemoteAcceptClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckRemoteAcceptClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckRemoteAcceptClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckRemoteAcceptClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckRemoteAcceptClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckAcceptClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckAcceptClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure cmdAddRecordClick(Sender: TObject);
    procedure timerDisplayTimer(Sender: TObject);
    procedure timerProcessTimer(Sender: TObject);
    procedure cmdSaveUserDataClick(Sender: TObject);
    procedure cmdBackupClick(Sender: TObject);
    procedure sckItemRemoteAccept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckItemRemoteClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckItemRemoteClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckItemRemoteClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckItemRemoteClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
    BackupStream : TFileStream;
    boBackup : Boolean;
    BackupPos : Integer;
  public
    { Public declarations }
    procedure AddEvent (aStr : String);
    procedure AddLog (aStr : String);

    function GetUserDataFields : String;
    function GetItemDataFields : String;

    procedure AddTodayData (KeyValue, aStr : String);
    procedure SaveTodayData (aFileName : String);

    function BackupFDB : Boolean;
  end;

var
  frmMain: TfrmMain;

  ElaspedSec, StartTick : Integer;

  FDBFileName : String;
  BufferSizeS2S : Integer;
  GateAcceptPort, RemoteAcceptPort, ItemRemoteAcceptPort : Integer;

  TodayDate : TDateTime;
  TodayCharList : TStringList;

  CurrentCharList : TStringKeyClass;

implementation

uses
   uConnector, uRemoteConnector, uDBProvider, uUtil;

{$R *.DFM}

procedure TfrmMain.AddEvent (aStr : String);
begin
   if lstEvent.Items.Count > 100 then begin
      lstEvent.Items.Delete (0);
   end;
   lstEvent.Items.Add (aStr);
   lstEvent.ItemIndex := lstEvent.Items.Count - 1;
end;

procedure TfrmMain.AddLog (aStr : String);
begin
   if txtLog.Lines.Count > 1000 then begin
      txtLog.Lines.Delete (0);
   end;
   txtLog.Lines.Add (aStr);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   boFlag : Boolean;
   iniFile : TIniFile;
begin
   AddLog (format ('DB Server Started %s %s', [DateToStr (Date), TimeToStr (Time)]));

   ElaspedSec := 0;
   StartTick := timeGetTime;

   TodayDate := Date;

   BackupStream := nil;
   boBackup := false;
   BackupPos := 0;

   if not FileExists ('.\DB.INI') then begin
      iniFile := TIniFile.Create ('.\DB.INI');
      iniFile.WriteString ('DB_SERVER', 'FileName', 'TESTDB.FDB');
      iniFile.WriteInteger ('DB_SERVER', 'BufferSizeS2S', 1024 * 1024);
      iniFile.WriteInteger ('DB_SERVER', 'GateAcceptPort', 3051);
      iniFile.WriteInteger ('DB_SERVER', 'RemoteAcceptPort', 1024);
      iniFile.WriteInteger ('DB_SERVER', 'ItemRemoteAcceptPort', 1020);
      iniFile.Free;
   end;

   iniFile := TIniFile.Create ('.\DB.INI');
   FDBFileName := iniFile.ReadString ('DB_SERVER', 'FileName', 'TESTDB.FDB');
   BufferSizeS2S := iniFile.ReadInteger ('DB_SERVER', 'BufferSizeS2S', 1024 * 1024);
   GateAcceptPort := iniFile.ReadInteger ('DB_SERVER', 'GateAcceptPort', 3051);
   RemoteAcceptPort := iniFile.ReadInteger ('DB_SERVER', 'RemoteAcceptPort', 1024);
   ItemRemoteAcceptPort := iniFile.ReadInteger ('DB_SERVER', 'ItemRemoteAcceptPort', 1020);
   iniFile.Free;

   DBProvider := TDBProvider.Create (FDBFileName);
   DBProvider.SetPrintControl (txtLog);
   boFlag := DBProvider.OpenDB;
   if boFlag = false then begin
      DBProvider.CreateDB;
      DBProvider.OpenDB;
      DBProvider.AddBlankRecord (10000);
      DBProvider.CloseDB;

      DBProvider.OpenDB;
   end;

   TodayCharList := TStringList.Create;

   if FileExists ('.\UserData\Today.SDB') then begin
      TodayCharList.LoadFromFile ('.\UserData\Today.SDB');
      if TodayCharList.Count > 0 then begin
         TodayCharList.Delete (0);
      end;
   end;

   CurrentCharList := TStringKeyClass.Create;

   ConnectorList := TConnectorList.Create;
   RemoteConnectorList := TRemoteConnectorList.Create;

   sckRemoteAccept.Port := RemoteAcceptPort;
   sckRemoteAccept.Active := true;

   sckItemRemote.Port := ItemRemoteAcceptPort;
   sckItemRemote.Active := true;

   sckAccept.Port := GateAcceptPort;
   sckAccept.Active := true;

   timerDisplay.Interval := 1000;
   timerDisplay.Enabled := true;

   timerProcess.Interval := 10;
   timerProcess.Enabled := true;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   if sckRemoteAccept.Active = true then begin
      sckRemoteAccept.Socket.Close;
   end;
   if sckAccept.Active = true then begin
      sckAccept.Socket.Close;
   end;
   if sckItemRemote.Active = true then begin
      sckItemRemote.Socket.Close;
   end;

   timerDisplay.Enabled := false;
   timerProcess.Enabled := false;

   CurrentCharList.Free;

   RemoteConnectorList.Free;
   ConnectorList.Free;

   SaveTodayData ('');
   
   TodayCharList.Clear;
   TodayCharList.Free;

   DBProvider.CloseDB;
   DBProvider.Free;
end;

procedure TfrmMain.cmdCloseClick(Sender: TObject);
begin
   if boBackup = true then exit;
   if Application.MessageBox ('Do you want to exit program?', 'DB SERVER', MB_OKCANCEL) <> ID_OK then exit;
   Close;
end;

procedure TfrmMain.sckRemoteAcceptAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.CreateConnect (Socket, rt_userdata);
   AddEvent ('Remote Accepted ' + Socket.RemoteAddress);
end;

procedure TfrmMain.sckRemoteAcceptClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   //
end;

procedure TfrmMain.sckRemoteAcceptClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.DeleteConnect (Socket);
   AddEvent ('Remote DisConnected ' + Socket.RemoteAddress);
end;

procedure TfrmMain.sckRemoteAcceptClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   AddEvent ('Remote Socket Error ' + Socket.RemoteAddress);
   ErrorCode := 0;
end;

procedure TfrmMain.sckRemoteAcceptClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   cmdStr : String;
begin
   if Socket.ReceiveLength > 0 then begin
      cmdStr := Socket.ReceiveText;
      RemoteConnectorList.AddReceiveData (Socket, cmdStr);
   end;
end;

procedure TfrmMain.sckRemoteAcceptClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.SetWriteAllow (Socket);
end;

procedure TfrmMain.sckAcceptAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.CreateConnect (Socket);
   AddLog (format ('Gate Server Accepted %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckAcceptClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   //
end;

procedure TfrmMain.sckAcceptClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.DeleteConnect (Socket);
   AddLog (format ('Gate Server Disconnected %s', [Socket.RemoteAddress]));
end;

procedure TfrmMain.sckAcceptClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   AddLog (format ('Gate Server Accept Socket Error (%d, %s)', [ErrorCode, Socket.RemoteAddress]));
   ErrorCode := 0;
end;

procedure TfrmMain.sckAcceptClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   nRead : Integer;
   buffer : array[0..4096] of byte;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      ConnectorList.AddReceiveData (Socket, @buffer, nRead);
      exit;
   end;
end;

procedure TfrmMain.sckAcceptClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.SetWriteAllow (Socket);
end;

procedure TfrmMain.cmdAddRecordClick(Sender: TObject);
var
   mStr : String;
   nCount : Integer;
begin
   mStr := InputBox ('数据库扩展', '数据库扩展大小(记录数)', '0');
   nCount := _StrToInt (mStr);
   if nCount <= 0 then exit;

   DBProvider.AddBlankRecord (nCount);
end;

procedure TfrmMain.timerDisplayTimer(Sender: TObject);
var
   CurTick : Integer;
   FileName : String;
   nYear, nMonth, nDay : Word;
   mYear, mMonth, mDay : Word;
begin
   CurTick := timeGetTime;

   if CurTick >= StartTick + 1000 then begin
      ElaspedSec := ElaspedSec + 1;
      StartTick := CurTick;
   end;

   lblElaspedTime.Caption := IntToStr (ElaspedSec);
   lblTotalRecordCount.Caption := IntToStr (DBProvider.TotalRecordCount);
   lblUsedRecordCount.Caption := IntToStr (DBProvider.UsedRecordCount);
   lblUnusedRecordCount.Caption := IntToStr (DBProvider.UnusedRecordCount);
   lblGateConnectCount.Caption := IntToStr (ConnectorList.Count);
   lblRemoteConnectCount.Caption := IntToStr (RemoteConnectorList.Count);
   lblLockedCount.Caption := IntToStr (CurrentCharList.Count);

   if TodayDate <> Date then begin
      DecodeDate (TodayDate, nYear, nMonth, nDay);
      DecodeDate (Date, mYear, mMonth, mDay);

      FileName := '.\UserData\UserData';
      FileName := FileName + IntToStr (nYear) + '-';
      if nMonth < 10 then FileName := FileName + '0' + IntToStr (nMonth) + '-'
      else FileName := FileName + IntToStr (nMonth) + '-';
      if nDay < 10 then FileName := FileName + '0' + IntToStr (nDay) + '.SDB'
      else FileName := FileName + IntToStr (nDay) + '.SDB';

      SaveTodayData (FileName);
      TodayCharList.Clear;
      TodayDate := Date;
      if nMonth <> mMonth then BackupFDB;
   end;
end;

procedure TfrmMain.timerProcessTimer(Sender: TObject);
var
   CurTick : Integer;
begin
   CurTick := timeGetTime;
   ConnectorList.Update (CurTick);
   RemoteConnectorList.Update (CurTick);

   if boBackup = true then begin
      if DBProvider.BackupRecord (BackupStream, BackupPos) = false then begin
         BackupStream.Free;
         BackupStream := nil;
         BackupPos := 0;
         boBackup := false;

         cmdBackup.Enabled := true;
         cmdClose.Enabled := true;
         Caption := 'DB Server';
         exit;
      end;
      BackupPos := BackupPos + 1;
      Caption := 'Backup : ' + IntToStr (BackupPos);
   end;
end;

function TfrmMain.GetUserDataFields : String;
var
   i : Integer;
   RetStr : String;
begin
   RetStr := 'PrimaryKey,MasterName,Guild,LastDate,CreateDate,Sex,ServerId,X,Y';
   RetStr := RetStr + ',Light,Dark,Energy,InPower,OutPower,Magic,Life,Talent,GoodChar';
   RetStr := RetStr + ',BadChar,Adaptive,Revival,Immunity,Virtue,CurEnergy,CurInPower';
   RetStr := RetStr + ',CurOutPower,CurMagic,CurLife,CurHealth,CurSatiety,CurPoisoning';
   RetStr := RetStr + ',CurHeadSeak,CurArmSeak,CurLegSeak';
   for i := 0 to 10 - 1 do begin
      RetStr := RetStr + format (',BasicMagic%d', [i]);
   end;
   for i := 0 to 8 - 1 do begin
      RetStr := RetStr + format (',WearItem%d', [i]);
   end;
   for i := 0 to 30 - 1 do begin
      RetStr := RetStr + format (',HaveItem%d', [i]);
   end;
   for i := 0 to 30 - 1 do begin
      RetStr := RetStr + format (',HaveMagic%d', [i]);
   end;

   Result := RetStr;
end;

function TfrmMain.GetItemDataFields : String;
var
   i : Integer;
   RetStr : String;
begin
   RetStr := 'Name,No,Password';
   for i := 0 to 10 - 1 do begin
      RetStr := RetStr + format (',Item%d', [i]);
   end;
   Result := RetStr;
end;


procedure TfrmMain.AddTodayData (KeyValue, aStr : String);
var
   i : Integer;
   str, rdstr : String;
begin
   for i := 0 to TodayCharList.Count - 1 do begin
      str := TodayCharList.Strings [i];
      str := GetTokenStr (str, rdstr, ',');
      if rdstr = KeyValue then begin
         TodayCharList.Strings [i] := aStr;
         exit;
      end;
   end;
   TodayCharList.Add (aStr);
end;

procedure TfrmMain.SaveTodayData (aFileName : String);
var
   FileName : String;
   mStr : String;
   boClear : Boolean;
begin
   if TodayCharList.Count = 0 then exit;

   if aFileName = '' then begin
      FileName := '.\UserData\Today.SDB';
      boClear := false;
   end else begin
      FileName := afileName;
      boClear := true;
   end;
   if FileExists (FileName) then begin
      DeleteFile (FileName);
   end;

   mStr := GetUserDataFields;
   TodayCharList.Insert (0, mStr);
   TodayCharList.SaveToFile (FileName);
   TodayCharList.Delete (0);

   if boClear = true then begin
      TodayCharList.Clear;
   end;
end;

procedure TfrmMain.cmdSaveUserDataClick(Sender: TObject);
begin
   SaveTodayData ('');
end;

procedure TfrmMain.cmdBackupClick(Sender: TObject);
begin
   if Application.MessageBox ('Do you want to backup fdb file?', 'DB SERVER', MB_OKCANCEL) <> ID_OK then exit;

   BackupFDB;
end;

function TfrmMain.BackupFDB;
var
   FileName : String;
   mYear, mMonth, mDay : Word;
begin
   DecodeDate (Date, mYear, mMonth, mDay);
   if BackupStream <> nil then BackupStream.Free;
   FileName := format ('.\UserData\Backup%d-%d-%d.FDB', [mYear, mMonth, mDay]);
   if FileExists (FileName) then DeleteFile (FileName);
   BackupStream := TFileStream.Create (FileName, fmCreate);
   DBProvider.BackupHeader (BackupStream);

   boBackup := true;
   BackupPos := 0;

   cmdBackup.Enabled := false;
   cmdClose.Enabled := false;
end;

procedure TfrmMain.sckItemRemoteAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.CreateConnect (Socket, rt_itemdata);
   AddEvent ('ItemRemote Accepted ' + Socket.RemoteAddress);
end;

procedure TfrmMain.sckItemRemoteClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.DeleteConnect (Socket);
   AddEvent ('ItemRemote DisConnected ' + Socket.RemoteAddress);
end;

procedure TfrmMain.sckItemRemoteClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
end;

procedure TfrmMain.sckItemRemoteClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   cmdStr : String;
begin
   if Socket.ReceiveLength > 0 then begin
      cmdStr := Socket.ReceiveText;
      RemoteConnectorList.AddReceiveData (Socket, cmdStr);
   end;
end;

procedure TfrmMain.sckItemRemoteClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.SetWriteAllow (Socket);
end;

end.

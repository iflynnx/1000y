unit FMain;

interface

uses
  Windows, Messages, mmSystem, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ScktComp, ExtCtrls, uProcess, db, dbTables, uPackets, IniFiles;

type
  TfrmMain = class(TForm)
    tsEvent: TPageControl;
    cmdClose: TButton;
    tsStatus: TTabSheet;
    lstStatus: TListBox;
    timerDisplay: TTimer;
    sckAccept: TServerSocket;
    StaticText1: TStaticText;
    lblConnectCount: TStaticText;
    StaticText3: TStaticText;
    lblElaspedTime: TStaticText;
    StaticText5: TStaticText;
    lblExceptCount: TStaticText;
    TabSheet1: TTabSheet;
    lstEvent: TListBox;
    tsLog: TTabSheet;
    txtLog: TMemo;
    timerProcess: TTimer;
    tsSQL: TTabSheet;
    txtSQL: TMemo;
    sckRemoteAccept: TServerSocket;
    procedure cmdCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sckAcceptAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckAcceptClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure sckAcceptClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sckAcceptClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure timerDisplayTimer(Sender: TObject);
    procedure timerProcessTimer(Sender: TObject);
    procedure sckRemoteAcceptAccept(Sender: TObject;
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
  private
    { Private declarations }

  public
    { Public declarations }

    procedure AddStatus (aStr : String);
    procedure AddEvent (aStr : String);
    procedure AddLog (aStr : String);
    procedure AddSQL (aStr : String);

    function GetUserDataFields : String;
  end;

var
   frmMain: TfrmMain;

   ElaspedSec , StartTick, LastQueryTick : Integer;
   DataBase : TDatabase;

   DBDSN, DBUserName, DBPassword : String;
   ClientAcceptPort : Integer;
   RemoteAcceptPort : Integer;
   TodayDate : TDateTime;

implementation

uses
   uConnector, uDBAdapter, uRemoteConnector;

{$R *.DFM}

procedure TfrmMain.AddStatus (aStr : String);
begin
   if lstStatus.Items.Count > 100 then begin
      lstStatus.Items.Delete (0);
   end;
   lstStatus.Items.Add (aStr);
   lstStatus.ItemIndex := lstStatus.Items.Count - 1;
end;

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

procedure TfrmMain.AddSQL (aStr : String);
begin
   if txtSQL.Lines.Count > 1000 then begin
      txtSQL.Lines.Delete (0);
   end;
   txtSQL.Lines.Add (aStr);
end;

procedure TfrmMain.cmdCloseClick(Sender: TObject);
begin
   if Application.MessageBox ('Do you want to exit program?', 'LOGIN SERVER', MB_OKCANCEL) <> ID_OK then exit;
   Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   iniFile : TIniFile;
begin
   ElaspedSec := 0;
   StartTick := timeGetTime;
//   LastQueryTick := timeGetTime;

   if not FileExists ('./login.ini') then begin
      iniFile := TIniFile.Create ('./login.ini');
      iniFile.WriteString ('ODBC', 'DSN', 'account1000y');
      iniFile.WriteString ('ODBC', 'UserName', 'sa');
      iniFile.WriteString ('ODBC', 'Password', 'cj741852');
      iniFile.WriteInteger ('SERVER', 'CLIENTACCEPTPORT', 3050);
      iniFile.WriteInteger ('SERVER', 'REMOTEACCEPTPORT', 1021);
      iniFile.Free;
   end;
   iniFile := TIniFile.Create ('./login.ini');
   DBDSN := iniFile.ReadString ('ODBC', 'DSN', 'account1000y');
   DBUserName := iniFile.ReadString ('ODBC', 'UserName', 'sa');
   DBPassword := iniFile.ReadString ('ODBC', 'Password', 'cj741852');
   ClientAcceptPort := iniFile.ReadInteger ('SERVER', 'CLIENTACCEPTPORT', 3050);
   RemoteAcceptPort := iniFile.ReadInteger ('SERVER', 'REMOTEACCEPTPORT', 1021);
   iniFile.Free;

   TodayDate := Date;
   
{
   DataBase := TDatabase.Create (nil);

   Database.DataBaseName := DBDSN;
   Database.AliasName := DBDSN;
   Database.Params.Add ('USER NAME=' + DBUserName);
   Database.Params.Add ('PASSWORD=' + DBPassword);
   Database.KeepConnection := true;
   Database.LoginPrompt := false;
   DataBase.Connected := TRUE;
}
   DBAdapter := TSDBAdapter.Create (DBDSN, DBDSN);

   ConnectorList := TConnectorList.Create;
   RemoteConnectorList := TRemoteConnectorList.Create;

   sckRemoteAccept.Port := RemoteAcceptPort;
   sckRemoteAccept.Active := true;

   sckAccept.Port := ClientAcceptPort;
   sckAccept.Active := true;

   sckRemoteAccept.Port := RemoteAcceptPort;
   sckRemoteAccept.Active := true;

   timerDisplay.Interval := 1000;
   timerDisplay.Enabled := true;

   timerProcess.Interval := 10;
   timerProcess.Enabled := true;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   sckAccept.Active := false;
   sckRemoteAccept.Active := false;

   timerDisplay.Enabled := false;
   timerProcess.Enabled := false;

   ConnectorList.Free;

   DBAdapter.Free;
   DataBase.Free;
end;

procedure TfrmMain.sckAcceptAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.CreateConnect (Socket);
   AddStatus (format ('Client Accepted %s', [Socket.LocalAddress]));
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
   AddStatus (format ('Client Disconnected %s', [Socket.LocalAddress]));
end;


procedure TfrmMain.sckAcceptClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   AddStatus (format ('Client Socket Error %s [ErrorCode=%d]', [Socket.LocalAddress, ErrorCode]));
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
   AddEvent ('0 byte Received (' + Socket.LocalAddress);
end;

procedure TfrmMain.sckAcceptClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ConnectorList.SetWriteAllow (Socket);
end;

procedure TfrmMain.timerDisplayTimer(Sender: TObject);
var
   CurTick : Integer;
//   Query : TQuery;
//   mStr : String;
   FileName : String;
   nYear, nMonth, nDay : Word;
   mYear, mMonth, mDay : Word;
begin
   CurTick := timeGetTime;
   
   if CurTick >= StartTick + 1000 then begin
      ElaspedSec := ElaspedSec + 1;
      StartTick := CurTick;
   end;

   if TodayDate <> Date then begin
      DecodeDate (TodayDate, nYear, nMonth, nDay);
      DecodeDate (Date, mYear, mMonth, mDay);

      FileName := '.\Backup\Login';
      FileName := FileName + ' ' + IntToStr (nYear) + '-';
      if nMonth < 10 then FileName := FileName + '0' + IntToStr (nMonth) + '-'
      else FileName := FileName + IntToStr (nMonth) + '-';
      if nDay < 10 then FileName := FileName + '0' + IntToStr (nDay) + '.SDB'
      else FileName := FileName + IntToStr (nDay) + '.SDB';

      DBAdapter.SaveToSDBFile (FileName);
      TodayDate := Date;
   end;
   
{
   if CurTick >= LastQueryTick + 1000 * 60 then begin
      Query := TQuery.Create (nil);
      Query.DatabaseName := 'account1000y';

      Query.SQL.Clear;
      mStr := 'SELECT GetDate() ';
      Query.SQL.Clear;
      Query.SQL.Add (mStr);
      Query.Open;
      Query.Close;

      Query.Free;

      LastQueryTick := CurTick;
   end;
}
   lblConnectCount.Caption := IntToStr (ConnectorList.Count);
   lblElaspedTime.Caption := IntToStr (ElaspedSec);
end;

procedure TfrmMain.timerProcessTimer(Sender: TObject);
var
   CurTick : Integer;
begin
   CurTick := timeGetTime;

   ConnectorList.Update (CurTick);
   RemoteConnectorList.Update (CurTick);
end;

function TfrmMain.GetUserDataFields : String;
var
   i : Integer;
   RetStr : String;
begin
   RetStr := 'PrimaryKey,Password,';
   for i := 0 to 5 - 1 do begin
      RetStr := RetStr + format ('CharInfo%d', [i]) + ',';
   end;
   RetStr := RetStr + 'IpAddr,UserName,Birth,Telephone,MakeDate,LastDate,Address,Email,NativeNumber,MasterKey';

   Result := RetStr;
end;

procedure TfrmMain.sckRemoteAcceptAccept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.CreateConnect (Socket);
end;

procedure TfrmMain.sckRemoteAcceptClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RemoteConnectorList.DeleteConnect (Socket);
end;

procedure TfrmMain.sckRemoteAcceptClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
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

end.

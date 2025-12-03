unit SVMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, inifiles, ExtCtrls,
  uAnsTick, uUser, uconnect, mapunit, fieldmsg, ulevelexp, deftype,
  svClass, basicobj, uMonster, uNpc, aUtil32, Spin, uGuild, Menus, ComCtrls,
  uLetter, uManager, AnsStringCls, uDoorGen;

type

  TFrmMain = class(TForm)
    ListBoxEvent: TListBox;
    TimerProcess: TTimer;
    LbConnection: TLabel;
    LbUser: TLabel;
    TimerDisplay: TTimer;
    LbItem: TLabel;
    LbMonster: TLabel;
    LbNpc: TLabel;
    TimerSave: TTimer;
    TimerClose: TTimer;
    SEProcessListCount: TSpinEdit;
    LbProcess: TLabel;
    MainMenu1: TMainMenu;
    Files1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    Env1: TMenuItem;
    LoadBadIpAndNotice1: TMenuItem;
    LbRemote: TLabel;
    StatusBar1: TStatusBar;
    LbLeaveCount: TLabel;
    TimerRain: TTimer;
    MRain: TMenuItem;
    TimerRainning: TTimer;
    SESelServer: TSpinEdit;
    MConnection: TMenuItem;
    MDrop100: TMenuItem;
    MView: TMenuItem;
    MGate: TMenuItem;
    chkSaveUserData: TCheckBox;
    chkWeather: TCheckBox;
    MDelGuild: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerProcessTimer(Sender: TObject);
    procedure TimerDisplayTimer(Sender: TObject);
    procedure TimerSaveTimer(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure LoadBadIpAndNotice1Click(Sender: TObject);
    procedure SEProcessListCountChange(Sender: TObject);
    procedure TimerRainTimer(Sender: TObject);
    procedure MRainClick(Sender: TObject);
    procedure TimerRainningTimer(Sender: TObject);
    procedure MDrop100Click(Sender: TObject);
    procedure MGateClick(Sender: TObject);
    procedure MDelGuildClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    BadIpStringList: TStringList;
    NoticeStringList: TStringList;
    CurNoticePosition: integer;

    Rain : TSRainning;
  public
    ServerIni : TIniFile;
    boConnectRemote : Boolean;

    boCloseFlag : Boolean;
    ProcessCount : integer;

    IniDate : string;
    IniHour : integer;
    EventStringList : TStringList;

    procedure AddEvent(aevent: string);

    procedure WriteLogInfo (aStr : String);
    procedure WriteDumpInfo (aData : PChar; aSize : Integer);
  end;

var
  FrmMain: TFrmMain;

  BufferSizeS2S : Integer = 1048576;
  BufferSizeS2C : Integer = 8192;

  CurrentDate : TDateTime;

implementation

uses
   FSockets, FGate, uGConnect, uItemLog;

{$R *.DFM}

procedure TFrmMain.WriteLogInfo (aStr : String);
var
   Stream : TFileStream;
   tmpFileName : String;
   szBuf : array[0..1024] of Byte;
begin
   try
      StrPCopy(@szBuf, '[' + DateToStr(Date) + ' ' + TimeToStr(Time) + '] ' + aStr + #13#10);
      tmpFileName := 'TGS1000.LOG';
      if FileExists (tmpFileName) then
         Stream := TFileStream.Create (tmpFileName, fmOpenReadWrite)
      else
         Stream := TFileStream.Create (tmpFileName, fmCreate);

      Stream.Seek(0, soFromEnd);
      Stream.WriteBuffer (szBuf, StrLen(@szBuf));
      Stream.Destroy;
   except
   end;
end;

procedure TFrmMain.WriteDumpInfo (aData : PChar; aSize : Integer);
var
   Stream : TFileStream;
   tmpFileName : String;
   iCount : Integer;
begin
   try
      iCount := 0;
      while true do begin
         tmpFileName := 'DUMP' + IntToStr (iCount) + '.BIN';
         if not FileExists (tmpFileName) then break;
         iCount := iCount + 1;
      end;
      
      Stream := TFileStream.Create (tmpFileName, fmCreate);
      Stream.Seek(0, soFromEnd);
      Stream.WriteBuffer (aData^, aSize);
      Stream.Destroy;
   except
   end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
   cnt : integer;
   Manager : TManager;
begin
   WriteLogInfo ('GameServer Started');

   CurrentDate := Date;

   SEProcessListCount.Value := ProcessListCount;
   EventStringList := TStringList.Create;

   boConnectRemote := FALSE;
   boCloseFlag := FALSE;
   
   Randomize;

   BadIpStringList := TStringList.Create;
   NoticeStringList := TStringList.Create;

   ServerINI := TIniFile.Create ('.\sv1000.Ini');

   GameStartDateStr := DateToStr (EncodeDate (GameStartYear, GameStartMonth, GameStartDay));

   GameStartDateStr := ServerIni.ReadString ('SERVER', 'GAMESTARTDATE', GameStartDateStr);
   GameCurrentDate := Round ( Date - StrToDate (GameStartDateStr));
   BufferSizeS2S := ServerINI.ReadInteger ('SERVER', 'BUFFERSIZES2S', 1048576);
   BufferSizeS2C := ServerINI.ReadInteger ('SERVER', 'BUFFERSIZES2C', 8192);

   cnt := ServerINI.ReadInteger ('DATABASE','COUNT', 0);
   Inc (cnt);
   ServerINI.WriteInteger ('DATABASE', 'COUNT', cnt);

   IniDate := ServerINI.ReadString ('DATABASE', 'DATE', '');
   IniHour := ServerINI.ReadInteger ('DATABASE','HOUR', 0);

   Udp_Item_IpAddress := ServerIni.ReadString ('UDP_ITEM', 'IPADDRESS', '127.0.0.1');
   Udp_Item_Port := ServerIni.ReadInteger ('UDP_ITEM', 'PORT', 6001);

   Udp_MouseEvent_IpAddress := ServerIni.ReadString ('UDP_MOUSEEVENT', 'IPADDRESS', '127.0.0.1');
   Udp_MouseEvent_Port := ServerIni.ReadInteger ('UDP_MOUSEEVENT', 'PORT', 6001);

   Udp_Moniter_IpAddress := ServerIni.ReadString ('UDP_MONITER', 'IPADDRESS', '127.0.0.1');
   Udp_Moniter_Port := ServerIni.ReadInteger ('UDP_MONITER', 'PORT', 6000);

   Udp_Connect_IpAddress := ServerIni.ReadString ('UDP_CONNECT', 'IPADDRESS', '127.0.0.1');
   Udp_Connect_Port := ServerIni.ReadInteger ('UDP_CONNECT', 'PORT', 6022);

   DBServerIPAddress := ServerIni.ReadString ('DB_SERVER', 'IPADDRESS', '127.0.0.1');
   DBServerPort := ServerIni.ReadInteger ('DB_SERVER', 'PORT', 3051);
   BattleServerIPAddress := ServerIni.ReadString ('BATTLE_SERVER', 'IPADDRESS', '127.0.0.1');
   BattleServerPort := ServerIni.ReadInteger ('BATTLE_SERVER', 'PORT', 3040);

   NoticeServerIpAddress := ServerIni.ReadString ('NOTICE_SERVER', 'IPADDRESS', '127.0.0.1');
   NoticeServerPort := ServerIni.ReadInteger ('NOTICE_SERVER', 'PORT', 3020);

   ManagerList := TManagerList.Create;

   SESelServer.MaxValue := ManagerList.Count - 1;

   GateConnectorList := TGateConnectorList.Create;

   ConnectorList := TConnectorList.Create;
   UserList := TUserList.Create (100);
   
   GuildList := TGuildList.Create;
   GateList := TGateList.Create;
   MirrorList := TMirrorList.Create;

   SoundObjList := TSoundObjList.Create;

   Manager := ManagerList.GetManagerByTitle ('ºüÀê¶´');

   ItemGen := TItemGen.Create;
   ItemGen.SetManagerClass (Manager);
   ItemGen.Initial ('ItemGen', 100, 84);
   ItemGen.StartProcess;

   Manager := ManagerList.GetManagerByTitle ('ÐÞÁ¶¶´');

   ObjectChecker := TObjectChecker.Create;
   ObjectChecker.SetManagerClass (Manager);
   ObjectChecker.Initial ('ObjectChecker', 26, 28);
   ObjectChecker.StartProcess;

   LetterManager := TLetterManager.Create (7, 1000, 'UserLetter.TXT');

   TimerProcess.Interval := 10;
   TimerProcess.Enabled := TRUE;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   TimerProcess.Enabled := false;
   TimerSave.Enabled := false;
   TimerDisplay.Enabled := false;

   SoundObjList.Free;

   ObjectChecker.EndProcess;
   ObjectChecker.Free;
   
   ItemGen.EndProcess;
   ItemGen.Free;

   LetterManager.Free;

   MirrorList.Free;
   GateList.Free;
   GuildList.Free;

   UserList.free;
   ConnectorList.free;
   GateConnectorList.Free;
   ManagerList.Free;

   ServerINI.Free;
   NoticeStringList.Free;
   BadIpStringList.Free;
   EventStringList.Free;

   WriteLogInfo ('GameServer Exit');
end;

procedure TFrmMain.AddEvent(aevent: string);
begin
   EventStringList.Add (aevent);
end;

procedure TFrmMain.TimerSaveTimer(Sender: TObject);
const
   OldDate : string = '';
var
   i, n: integer;
   Str: string;
   usd : TStringData;
   Manager : TManager;
   nYear, nMonth, nDay : Word;
begin
   if TimerClose.Enabled = true then exit;

   str := TimeToStr (Time);
   if OldDate <> DateToStr (Date) then begin
      OldDate := DateToStr (Date);
      GameCurrentDate := Round ( Date - StrToDate (GameStartDateStr));
      NameStringListForDeleteMagic.Clear;
   end;

   if Date <> CurrentDate then begin
      DecodeDate (CurrentDate, nYear, nMonth, nDay);
      Str := '.\ItemLog\Backup\ItemLog';
      Str := Str + IntToStr (nYear) + '-';
      if nMonth < 10 then Str := Str + '0';
      Str := Str + IntToStr (nMonth) + '-';
      if nDay < 10 then Str := Str + '0';
      Str := Str + IntToStr (nDay) + '.SDB';
      ItemLog.SaveToSDB (Str);

      CurrentDate := Date;
   end;

   if Pos ('AM', str) > 0 then GrobalLightDark := gld_dark
   else GrobalLightDark := gld_light;

   if NoticeStringList.Count > 0 then begin
      if CurNoticePosition >= NoticeStringList.Count then CurNoticePosition := 0;
      // UserList.SendNoticeMessage ( NoticeStringList[CurNoticePosition], SAY_COLOR_NOTICE);
      inc (CurNoticePosition);
   end;

   n := GetCPUStartHour;
   if n <> IniHour then begin
      IniHour := n;
      ServerIni.WriteInteger ('DATABASE', 'HOUR', n);
      // GuildList.CompactGuild;
      GuildList.SaveToFile ('.\Guild\CreateGuild.SDB');
   end;

   usd.rmsg := 1;
   SetWordString (usd.rWordString, IntToStr (UserList.Count));
   n := sizeof(TStringData) - sizeof(TWordString) + sizeofwordstring (usd.rwordstring);
   FrmSockets.UdpMoniterAddData (n, @usd);
end;

procedure TFrmMain.TimerCloseTimer(Sender: TObject);
begin
   if (UserList.Count = 0) and (ConnectorList.Count = 0) and (ConnectorList.GetSaveListCount = 0) then begin
      if TimerClose.Interval = 1000 then begin
         TimerClose.Interval := 5000;
         exit;
      end;
      Close;
   end else begin
      ConnectorList.CloseAllConnect;
   end;
end;

procedure TFrmMain.Exit1Click(Sender: TObject);
begin
   boCloseFlag := true;

   TimerClose.Interval := 1000;
   TimerClose.Enabled := TRUE;
end;

procedure TFrmMain.LoadBadIpAndNotice1Click(Sender: TObject);
begin
   if FileExists ('BadIpAddr.txt') then BadIpStringList.LoadFromFile ('BadIpAddr.txt');
   if FileExists ('Notice.txt') then NoticeStringList.LoadFromFile ('Notice.txt');

   Udp_Item_IpAddress := ServerIni.ReadString ('UDP_ITEM', 'IPADDRESS', '127.0.0.1');
   Udp_Item_Port := ServerIni.ReadInteger ('UDP_ITEM', 'PORT', 6001);

   Udp_MouseEvent_IpAddress := ServerIni.ReadString ('UDP_MOUSEEVENT', 'IPADDRESS', '127.0.0.1');
   Udp_MouseEvent_Port := ServerIni.ReadInteger ('UDP_MOUSEEVENT', 'PORT', 6001);

   Udp_Moniter_IpAddress := ServerIni.ReadString ('UDP_MONITER', 'IPADDRESS', '127.0.0.1');
   Udp_Moniter_Port := ServerIni.ReadInteger ('UDP_MONITER', 'PORT', 6000);

   Udp_Connect_IpAddress := ServerIni.ReadString ('UDP_CONNECT', 'IPADDRESS', '127.0.0.1');
   Udp_Connect_Port := ServerIni.ReadInteger ('UDP_CONNECT', 'PORT', 6022);

   NoticeServerIpAddress := ServerIni.ReadString ('NOTICE_SERVER', 'IPADDRESS', '127.0.0.1');
   NoticeServerPort := ServerIni.ReadInteger ('NOTICE_SERVER', 'PORT', 3020);

   frmSockets.ReConnectNoticeServer (NoticeServerIPAddress, NoticeServerPort);

   CurNoticePosition := 0;

   LoadGameIni ('.\game.ini');
end;

procedure TFrmMain.SEProcessListCountChange(Sender: TObject);
begin
   ProcessListCount := SEProcessListCount.Value;
end;

procedure TFrmMain.TimerDisplayTimer(Sender: TObject);
var
   str : string;
   Manager : TManager;
begin
   while TRUE do begin
      if EventStringList.Count = 0 then break;
      str := EventStringList[0];
      EventStringList.Delete (0);
      if ListBoxEvent.Items.Count > 5 then ListboxEvent.Items.Delete(0);
      ListBoxEvent.Items.add (str);
   end;

   LbProcess.Caption := 'P:' + IntToStr (processcount);
   ProcessCount := 0;

   if ConnectorList <> nil then
      LbConnection.Caption := 'C:' + IntToStr(ConnectorList.Count);
   if UserList <> nil then
      LbUser.Caption := 'U:' + IntToStr (UserList.Count);

   if ManagerList <> nil then begin
      Manager := ManagerList.GetManagerByIndex (SeSelServer.Value);
      if Manager <> nil then begin
         LbItem.Caption := 'I:' + IntToStr(TItemList (Manager.ItemList).Count);
         LbMonster.Caption := 'M:' + IntToStr(TMonsterList (Manager.MonsterList).Count);
         LbNpc.Caption := 'N:' + IntToStr(TNpcList (Manager.NpcList).Count);
      end;
   end;
end;

procedure TFrmMain.TimerProcessTimer(Sender: TObject);
var
   CurTick : integer;
begin
   CurTick := mmAnsTick;

   GateConnectorList.Update (CurTick);

   PrisonClass.Update (CurTick);

   ConnectorList.Update (CurTick);
   UserList.Update (CurTick);

   if boCloseFlag = false then begin
      ManagerList.Update (CurTick);
   end;

   GuildList.Update (CurTick);
   GateList.Update (CurTick);
   MirrorList.Update (CurTick);

   ItemGen.Update (CurTick);
   ObjectChecker.Update (CurTick);

   SoundObjList.Update (CurTick);

   inc (ProcessCount);
end;

procedure TFrmMain.TimerRainTimer(Sender: TObject);
var
   nYear, nMonth, nDay : Word;
   nHour, nMin, nSec, nMSec : Word;
   boSnow : boolean;
begin
   if chkWeather.Checked = false then exit;
   
   try
      DecodeDate (Date, nYear, nMonth, nDay);
      DecodeTime (Time, nHour, nMin, nSec, nMSec);
   except
      exit;
   end;

   boSnow := true;
   if (nMonth > 3) and (nMonth < 11) then begin
      boSnow := false;
   end else if (nMonth = 3) or (nMonth = 11) then begin
      if Random (10) > 2 then begin
         boSnow := false;
      end;
   end;

   if boSnow = false then begin
      Rain.rmsg := SM_RAINNING;
      Rain.rspeed := 10;
      Rain.rCount := 200;
      Rain.rOverray := 50;
      Rain.rTick := 600;
      Rain.rRainType := RAINTYPE_RAIN;
   end else begin
      Rain.rmsg := SM_RAINNING;
      Rain.rspeed := 1;
      Rain.rCount := 200;
      Rain.rOverray := 20;
      Rain.rTick := 600;
      Rain.rRainType := RAINTYPE_SNOW;
   end;

   TimerRainning.Enabled := TRUE;
end;

procedure TFrmMain.MRainClick(Sender: TObject);
begin
   TimerRainTimer (Self);
end;

procedure TFrmMain.TimerRainningTimer(Sender: TObject);
const
   RainTick : integer = 0;
var
   SendCount : Integer;
begin
   if chkWeather.Checked = false then exit;
   
   // Speed, Count, Overray, Tick
   UserList.SendRaining (Rain);

   SendCount := 20;
   if Rain.rRainType = RAINTYPE_SNOW then SendCount := 60;
   RainTick := RainTick + 1;
   if RainTick > SendCount then begin
      RainTick := 0;
      TimerRainning.Enabled := FALSE;
   end;
end;

procedure TFrmMain.MDrop100Click(Sender: TObject);
begin
   //
end;

procedure TFrmMain.MGateClick(Sender: TObject);
begin
   frmGate.Show;
end;

procedure TFrmMain.MDelGuildClick(Sender: TObject);
begin
   //
   GuildList.CompactGuild;
end;

procedure TFrmMain.FormActivate (Sender: TObject);
begin
   LoadBadIpAndNotice1Click (Self);
end;

end.

unit FLogOn;

interface

uses
  Windows, SysUtils, Classes, ExtCtrls, Controls, Graphics, Forms,
  Buttons, StdCtrls, adeftype, deftype, uBuffer,
  uAnsTick, aUtil32, Dll_Sock, inifiles, ScktComp, WinSock,
  Dialogs, Cltype, A2Form, Log, mmSystem, uPackets, Messages, ansunit;

const
   MAXSOCKETDATASIZE = 10000;
   MAXSOCKETSENDDATASIZE = 4096;

   PROCESSDATASIZE = 4096;

   PacketBufferSize = 8192;
   SocketBufferSize = 64192;

type
  TConnectState = ( cs_none, cs_balance, cs_gate, cs_gameserver );
  
  THostAddressClass = class
   private
     IpList: TStringList;
     PortList: TStringList;
     NameList: TStringList;
     function GetCount: integer;
   public
     constructor Create (aFileName: string);
     destructor Destroy; override;
     function FindIndexByName (aname: string): integer;
     function GetIps(aidx: integer; adefault: string) : string;
     function GetPorts(aidx: integer; adefault: string) : string;
     function GetNames(aidx: integer; adefault: string) : string;
     property Count: integer read GetCount;
  end;

  TFrmLogOn = class(TForm)

    TimerReConnect: TTimer;
    TimerNixConnectConfirmed: TTimer;
    A2Form: TA2Form;
    BtnLogin: TA2Button;
    BtnNewUser: TA2Button;
    BtnExit: TA2Button;
    EdID: TA2Edit;
    EdPass: TA2Edit;
    PnInfo: TA2Label;
    ComboBox: TA2ComboBox;
    TimerSpeedCheck: TTimer;
    sckConnect: TClientSocket;
    timerProcess: TTimer;
    TimerSendTime: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EdIdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnExitClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure BtnLogInClick(Sender: TObject);
    procedure BtnNewUserClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure TimerReConnectTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure TimerNixConnectConfirmedTimer(Sender: TObject);
    procedure TimerSpeedCheckTimer(Sender: TObject);
    procedure sckConnectConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckConnectDisconnect(Sender: TObject;Socket: TCustomWinSocket);
    procedure sckConnectError(Sender: TObject; Socket: TCustomWinSocket;ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure sckConnectRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckConnectWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure timerProcessTimer(Sender: TObject);
  private
    { Private declarations }

    PacketSender : TPacketSender;
    PacketReceiver : TPacketReceiver;

   {
   SendBuffer : TBuffer;
   MainBuffer : TBuffer;
   boWriteAllow : Boolean;
   }

    HostAddressClass : THostAddressClass;

    FStartTime : TDateTime;
    FCurTick, FOldTick : integer;

    procedure InitMainSocketAndBuffer;
  public
   function MessageProcess (var Code : TWordComData) : Boolean;
   procedure ClearEdit (abo:Boolean);
   function  SocketAddData(cnt: integer; pb: pbyte) :Boolean;
   function  SocketAddOneData(adata:byte) :Boolean;

   function  SocketDisConnect(ErrText, ErrCaption : string; aActive : Boolean): Boolean;
   procedure SetFormText;
  end;

function Conv (astr : string): string;

var
   FrmLogOn: TFrmLogOn;

   mainFont : string = 'Arial';
   CurServerName : string = '';
   MessageDelayTime : array [0..255] of integer;

   CaptionServerName : string = '';

   ReConnectId : string = '';
   ReConnectPass : string = '';
   ReConnectChar : string = '';
   ReConnectIpAddr : string = '';
   ReConnectPort : integer = 0;

   boTimePaid : Boolean = TRUE; // 牢器讥眉农侩
   ReConnetFlag : Boolean = TRUE;
   indexTick : integer;

   ConnectState : TConnectState;
   boDirectClose : Boolean = FALSE;

implementation

uses
   FNewUser, FSelChar, FMain, FBottom, FAttrib, FStipulation;

{$R *.DFM}

constructor THostAddressClass.Create (aFileName: string);
var
   i: integer;
   str, rdstr: string;
   StringList: TStringList;
begin
   IpList := TStringList.Create;
   PortList := TStringList.Create;
   NameList := TStringList.Create;

   StringList := TStringList.Create;

   if FileExists (aFileName) then begin
      StringList.LoadFromFile (afilename);
      for i := StringList.Count-1 downto 0 do begin
         str := stringlist[i];
         str := GetValidStr3 (str, rdstr, ',');
         if rdstr = '' then begin StringList.delete (i); continue; end;
         str := GetValidStr3 (str, rdstr, ',');
         if rdstr = '' then begin StringList.delete (i); continue; end;
         str := GetValidStr3 (str, rdstr, ',');
         if rdstr = '' then begin StringList.delete (i); continue; end;
      end;

      for i := 0 to StringList.Count-1 do begin
         str := stringlist[i];
         str := GetValidStr3 (str, rdstr, ',');
         IpList.Add(rdstr);
         str := GetValidStr3 (str, rdstr, ',');
         PortList.Add(rdstr);
         str := GetValidStr3 (str, rdstr, ',');
         NameList.Add(rdstr);
      end;
   end;
end;

destructor THostAddressClass.Destroy;
begin
   IpList.free;
   PortList.free;
   NameList.free;
   inherited destroy;
end;

function THostAddressClass.GetIps(aidx:integer; adefault: string) : string;
begin
   result := adefault;
   if (aidx < 0) or (aidx >= IpList.Count) then exit;
   Result := IpList[aidx];
end;

function THostAddressClass.GetPorts(aidx:integer; adefault: string) : string;
begin
   result := adefault;
   if (aidx < 0) or (aidx >= PortList.Count) then exit;
   Result := PortList[aidx];
end;

function THostAddressClass.GetNames(aidx: integer; adefault: string) : string;
begin
   result := adefault;
   if (aidx < 0) or (aidx >= NameList.Count) then exit;
   Result := NameList[aidx];
end;

function THostAddressClass.GetCount: integer;
begin
   Result := NameList.Count;
end;

function THostAddressClass.FindIndexByName (aname: string): integer;
var
   i : integer;
begin
   Result := -1;
   for i := 0 to NameList.Count -1 do begin
      if NameList[i] = aname then begin
         Result := i;
         exit;
      end;
   end;
end;

///////////////////////////////
//         FrmLogin
///////////////////////////////
procedure TFrmLogOn.FormCreate(Sender: TObject);
var
   i, n : integer;
   cserver: string;
   str : string;
   TimepayType : TTimepayType;
begin
   ConnectState := cs_none;

   FStartTime := Time;
   FOldTick := mmAnsTick;
   indexTick := 0;

   FrmM.AddA2Form (Self, A2form);
   Left := 0; Top := 0;

   PacketSender := nil;
   PacketReceiver := nil;

   InitMainSocketAndBuffer;
   
   timerProcess.Interval := 10;
   timerProcess.Enabled := true;

   SetFormText;

   cserver := ClientIni.ReadString ('CLIENT','NAMEOFLEND',Conv('创造'));
   HostAddressClass := THostAddressClass.Create ('addr.txt');

   for i := 0 to HostAddressClass.Count -1 do ComboBox.Items.add (HostAddressClass.GetNames(i, Conv('创造')));
   if ComboBox.Items.Count = 0 then ComboBox.Items.add (Conv('创造'));

   n := HostAddressClass.FindIndexByName (cserver);
   if n <> -1 then begin
      ComboBox.Text := ComboBox.Items[n];
   end else begin
      if ComboBox.Items.Count > 0 then ComboBox.Text := ComboBox.Items[0];
   end;

   FillChar (MessageDelayTime, sizeof(MessageDelayTime), 0);

   str := '';
   for i := 1 to ParamCount +2 do begin
      str := str + ParamStr(i) + ' ';
   end;

   if NATION_VERSION <> NATION_KOREA then exit;
   if Loadtimepay then begin
      TimepayType := CheckTimePayed(str);
      case TimepayType of
         Tpt_actoz :;
         Tpt_timepay :
            begin
               TimerNixConnectConfirmed.Enabled := TRUE; // 牢器讥 眉农鸥烙赣 累悼 DLL俊辑 家南楷搬捞 谗辨矫 眉农窃
               boTimePaid := FALSE; // FALSE老版快 牢器讥烙
            end;
         Tpt_Close :
            begin
               SocketDisConnect(Conv('与服务器连接中断.'),Conv('用户身份认证'),TRUE);
            end;
      end;
   end;
end;

procedure TFrmLogOn.FormDestroy(Sender: TObject);
begin
   if PacketSender <> nil then begin
      PacketSender.Free;
      PacketSender := nil;
   end;
   if PacketReceiver <> nil then begin
      PacketReceiver.Free;
      PacketReceiver := nil;
   end;
end;
{
procedure TFrmLogOn.MyEventFunction (aeventstr: shortstring);
var
//   ckey : TCKey;
   cVer : TCVer;
   cIdPass : TCIdPass;
begin
   if not ReConnetFlag then exit;
   if aeventstr = 'ONCONNECT' then begin
      InitMainSocketAndBuffer;

      EdId.Enabled := TRUE;
      EdPass.Enabled := TRUE;
      BtnLogin.Enabled := TRUE;
      BtnNewUser.Enabled := TRUE;
      EdId.Color := clBlack;
      EdPass.Color := clBlack;
      if Visible then EdId.SetFocus;

      cVer.rmsg := CM_VERSION;
      cVer.rVer := PROGRAM_VERSION;
      cVer.rNation := NATION_KOREA; // 惫啊备喊 : 茄惫
      SocketAddData (sizeof(cVer), @cVer);

      Pninfo.Caption := Conv('捞抚捞 绝绰盒篮 货捞抚阑 穿福技夸[楷搬凳]');

      if ReConnectId <> '' then begin
         cIdPass.rmsg := CM_IDPASS;
         StrPCopy ( @cIdPass.rId, ReConnectId);
         StrPCopy ( @cIdPass.rPass, ReConnectPass);
         SocketAddData (sizeof(cIdPass), @cIdPass);
         ClearEdit(FALSE);
         PnInfo.Caption := Conv('泪矫 扁促府技夸 ...');

         ReConnectId := '';
         ReConnectPass := '';
         ReConnectIpAddr := '';
         ReConnectPort := 0;
      end;
   end;

   if aeventstr = 'ONERROR' then begin
      PnInfo.Caption := Conv('楷搬角菩!!!');
   end;

   if aeventstr = 'ONDISCONNECT' then begin
      if FrmBottom.Visible then begin

         if ReConnectId = '' then begin
            ReConnetFlag := FALSE;
//            LogObj.WriteLog (5, 'Close becuase Socket Disconnect');
            SocketDisConnect(Conv('辑滚客狼 楷搬捞 谗绢脸嚼聪促.'),Conv('玫斥'), TRUE);
            FrmM.Close;
         end;
      end;
   end;
end;
}
procedure TFrmLogOn.BtnLogInClick(Sender: TObject);
var
   cIdPass : TCIdPass;
   cIdPassAzaCom : TCIdPassAzaCom;
   str : string;
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   if boTimePaid then begin // boTimePaid FALSE : 牢器讥
      cIdPass.rmsg := CM_IDPASS;
      StrPCopy ( @cIdPass.rId, EdId.Text);
      StrPCopy ( @cIdPass.rPass, EdPass.Text);
      SocketAddData (sizeof(cIdPass), @cIdPass);
   end else begin
      showMessage (Conv('连接为收费账号.'));
      cIdPassAzaCom.rmsg := CM_IDPASSAZACOM;
      StrPCopy ( @cIdPassAzaCom.rId, EdId.Text);
      StrPCopy ( @cIdPassAzaCom.rPass, EdPass.Text);
//      StrPCopy ( @cIdPassAzaCom.rAzaComId, ParamString[4]);
      str := Copy (ParamStr(1), 0, 8);
      StrPCopy ( @cIdPassAzaCom.rAzaComId, str);
      SocketAddData (sizeof(cIdPassAzaCom), @cIdPassAzaCom);
   end;

   ClearEdit(FALSE);
   PnInfo.Caption := Conv('请稍等片刻...');
end;

procedure TFrmLogOn.BtnNewUserClick(Sender: TObject);
begin
{
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   Visible := FALSE;
   FrmNewUser.Visible := TRUE;
}
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   Visible := FALSE;
   FrmStipulation.Visible := TRUE;
end;

procedure TFrmLogOn.BtnExitClick(Sender: TObject);
begin
   FrmM.SoundManager.NewPlayEffect ('click.wav',0,0);
   SocketAddOneData (CM_CLOSE);
   bodirectclose := TRUE;
end;

procedure TFrmLogOn.InitMainSocketAndBuffer;
begin
   if PacketSender <> nil then begin
      PacketSender.Clear;
   end;
   if PacketReceiver <> nil then begin
      PacketReceiver.Clear;
   end;
end;

procedure TFrmLogOn.ClearEdit (abo:Boolean);
begin
   if abo then begin
      EdId.Enabled := abo;
      EdPass.Enabled := abo;
      if Visible then EdId.SetFocus;
      EdId.Text := '';
      EdPass.Text := '';
   end else begin
      EdId.Enabled := abo;
      EdPass.Enabled := abo;
   end;
end;

procedure TFrmLogOn.EditKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = char (VK_ESCAPE)) or (key = char(VK_RETURN)) then key := char(0);
end;

procedure TFrmLogOn.EdIdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case key of
      VK_RETURN : EdPass.SetFocus;
      VK_ESCAPE : ClearEdit(TRUE);
   end;
end;

procedure TFrmLogOn.EdPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if key = VK_ESCAPE then ClearEdit(TRUE);
   if key <> VK_RETURN then exit;

   if Length (Edid.Text) < 2 then begin Edid.SetFocus; exit; end;
   if Length (EdPass.Text) < 4 then begin EdPass.SetFocus; exit; end;

   if Pos (',', EdID.Text) > 0 then begin Edid.SetFocus; exit; end;
   if Pos (',', EdPass.Text) > 0 then begin EdPass.SetFocus; exit; end;

   BtnLogInClick (Self);
end;

function TFrmLogOn.MessageProcess (var Code : TWordComData) : Boolean;
var
   i : integer;
   str, rdstr : string;
   pckey : PTCKey;
   psWs : PTWordInfoString;
   psMessage : PTSMessage;
   psWindow : PTSWindow;

   psReConnect: PTSReConnect;
   psSConnectThru : PTSConnectThru;
begin
   Result := true;

   pckey := @Code.data;
   case pckey^.rmsg of
      SM_CONNECTTHRU :
         begin
            TimerReConnect.Enabled := FALSE;
            psSConnectThru := @Code.Data;
            ReConnectIpAddr := StrPas(@psSConnectThru.rIpAddr);
            ReConnectPort := psSConnectThru.rPort;
            sckConnect.Active := false;

            TimerReConnect.Enabled := TRUE;

            Result := false;
         end;
      SM_RECONNECT:
         begin
            psReConnect := @Code.Data;
            ReConnectId := StrPas (@psReConnect^.rid);
            ReConnectPass := StrPas (@psReConnect^.rPass);
            ReConnectIpAddr := StrPas (@psReConnect^.ripAddr);
            ReConnectChar := StrPas (@psReConnect^.rCharName);
            ReConnectPort := psReConnect^.rPort;
            sckConnect.Active := false;

            TimerReConnect.Enabled := TRUE;
         end;
      SM_CLOSE :
         begin
            if pckey^.rkey = 1 then begin
//               LogObj.WriteLog (5, 'Close becuase version');
               SocketDisConnect(Conv('官方网站: http://www.1000y.com'), Conv('下载最新版本.'), TRUE);
               sleep (100);
               FrmM.close;
            end;
         end;
      SM_MESSAGE :
         begin
            psMessage := @Code.Data;
            case psMessage^.rkey of
               MESSAGE_LOGIN        :
                  begin
//                     LogObj.WriteLog(4, format('SM_MESSAGE MESSAGE_LOGIN %s', [GetWordString(psMessage^.rWordString)]));
                     PnInfo.Caption := GetWordString (psMessage^.rWordString);
                  end;
               MESSAGE_CREATELOGIN  :
                  begin
//                     LogObj.WriteLog(4, format('SM_MESSAGE MESSAGE_CREATELOGIN %s', [GetWordString(psMessage^.rWordString)]));
                     FrmNewUser.Pninfo.Caption := GetWordString (psMessage^.rWordString);
                  end;
               MESSAGE_SELCHAR      :
                  begin
//                     LogObj.WriteLog(4, format('SM_MESSAGE MESSAGE_SELCHAR %s',[GetWordString(psMessage^.rWordString)]));
                     FrmSelChar.Pninfo.Caption := GetWordString (psMessage^.rWordString);
                  end;
               MESSAGE_GAMEING      :
                  begin
//                     LogObj.WriteLog(4, 'SM_MESSAGE MESSAGE_GAMEING');
                     ;//FrmMain.LbMouseInfo.Caption := GetWordString (psMessage^.rWordString);
                  end;
            end;
            if psMessage^.rkey = MESSAGE_LOGIN then ClearEdit (TRUE);
         end;
      SM_WINDOW :
         begin
            psWindow := @code.data;
            {
            if pswindow^.rboShow then
//               LogObj.WriteLog(4, format('SM_WINDOW %d = TRUE', [pswindow^.rwindow]))
            else
//               LogObj.WriteLog(4, format('SM_WINDOW %d = FALSE', [pswindow^.rwindow]));
            }
            case pswindow^.rwindow of
               1 :
                  begin
                     Visible := pswindow^.rboShow;
{
                     if pswindow^.rboShow then begin
                        Visible := TRUE;
                     end
                     else begin
                        Visible := FALSE;
                     end;
}
                  end;
               2 :
                  begin
                     FrmNewUser.Visible := pswindow^.rboShow;
{
                     if pswindow^.rboShow then begin
                        FrmNewUser.Visible := TRUE;
                     end
                     else begin
                        FrmNewUser.Visible := FALSE;
                     end;
}
                  end;
               3 :
                  begin
                     if pswindow^.rboShow then begin
                        FrmSelChar.MyShow;
                     end
                     else begin
                        FrmSelChar.MyHide;
                     end;
                  end;
               4 :
                  begin
//                     FrmMain.Visible := pswindow^.rboShow;
//                     if pswindow^.rboShow then begin FrmMain.Show; FrmBottom.Visible := TRUE; end
//                     else begin FrmMain.Hide; FrmBottom.Visible := FALSE; end;
                  end;
            end;
         end;
      SM_CHARINFO :
         begin
            FrmSelChar.ListBox1.Clear;
            psws := @Code.Data;
            str := GetWordString (psws^.rWordString);
            while TRUE do begin
               str := GetValidStr3 (str, rdstr, ',');
               if rdstr <> '' then FrmSelChar.ListBox1.AddItem (rdstr);
               if (str = '') or (FrmSelChar.ListBox1.Count > 5) then break;
            end;
            {
            str := GetValidStr3 (str, rdstr, ',');
//            LogObj.WriteLog(4, 'SM_CHARINFO ' + rdstr);
//            FrmSelChar.ListBox1.Items.Add (rdstr);
            FrmSelChar.ListBox1.AddItem (rdstr);
            str := GetValidStr3 (str, rdstr, ',');
//            LogObj.WriteLog(4, 'SM_CHARINFO ' + rdstr);
//            FrmSelChar.ListBox1.Items.Add (rdstr);
            FrmSelChar.ListBox1.AddItem (rdstr);
            str := GetValidStr3 (str, rdstr, ',');
//            LogObj.WriteLog(4, 'SM_CHARINFO ' + rdstr);
//            FrmSelChar.ListBox1.Items.Add (rdstr);
            FrmSelChar.ListBox1.AddItem (rdstr);
            str := GetValidStr3 (str, rdstr, ',');
//            LogObj.WriteLog(4, 'SM_CHARINFO ' + rdstr);
//            FrmSelChar.ListBox1.Items.Add (rdstr);
            FrmSelChar.ListBox1.AddItem (rdstr);
            str := GetValidStr3 (str, rdstr, ',');
//            LogObj.WriteLog(4, 'SM_CHARINFO ' + rdstr);
//            FrmSelChar.ListBox1.Items.Add (rdstr);
            FrmSelChar.ListBox1.AddItem (rdstr);
            }
            FrmSelChar.ListBox1.ItemIndex := 0;
            for i := 0 to FrmSelChar.ListBox1.Count -1 do begin
               str := FrmSelChar.ListBox1.Items[i];
               str := GetValidStr3 (str, rdstr, ':');
               if Pos (FrmLogon.ComboBox.Text,Str) > 0 then begin
                  FrmSelChar.ListBox1.ItemIndex := i;
                  break;
               end;
            end;
         end;
      else begin
         FrmM.MessageProcess (code);
         FrmBottom.MessageProcess (code);
         FrmAttrib.MessageProcess (code);
      end;
   end;
end;

function TFrmLogOn.SocketAddData(cnt:integer; pb:pbyte): Boolean;
var
   n : integer;
   sd : TWordComData;
begin
   Result := TRUE;

   n := pb^;
   if (n >= 0) and (n <= 255) then begin
      if MessageDelayTime[n] + 25 > mmAnsTick then exit;
      MessageDelayTime[n] := mmAnsTick;
   end;
   sd.Size := cnt;
//   sd.cnt := cnt;
   Move (pb^, sd.data, cnt);

   {
   Reverse4Bit (sd);

   SendBuffer.Put (@sd, cnt + sizeof (word));
   }
   if PacketSender <> nil then
      PacketSender.PutPacket (0, 0, 0, @sd, cnt + SizeOf (Word));
end;

function  TFrmLogOn.SocketAddOneData(adata:byte) :Boolean;
var sd : TComdata;
begin
   fillchar (sd, sizeof(sd), 0);
   sd.Size := 3;
//   sd.cnt := 3;
   sd.data[0] := adata;

   Result := SocketAddData (3, @sd.data);
end;

function  TFrmLogOn.SocketDisConnect(ErrText, ErrCaption : string; aActive : Boolean): Boolean;
begin
   Result := true;
   try
      if aActive = TRUE then begin
         if sckConnect.Active then sckConnect.Active := FALSE;
      end;
   except
      Result := FALSE;
   end;
   if (ErrText <> '') or (ErrCaption <> '') then Application.MessageBox(Pchar(ErrText), Pchar(ErrCaption), 0);
end;

{
procedure TFrmLogOn.TimerSendTimer(Sender: TObject);
var
   sd: TWordComdata;
   buffer : array [0..MAXSOCKETDATASIZE-1] of byte;
   cnt : Integer;
begin
   if GetAnsSocketAllowSend (AnsSocketHandle) = FALSE then exit;

   cnt := 0;
   while MainPacketBuffer.Count > 0 do begin
      if MainPacketBuffer.Get (@sd) = false then break;
      if cnt + sd.cnt + sizeof (word) > MAXSOCKETSENDDATASIZE then break;

      Reverse4Bit (sd);
      Move (sd, buffer[cnt], sd.cnt + sizeof (word));

      cnt := cnt + sd.cnt + sizeof (word);
   end;
   if cnt > 0 then AnsSocketSend (AnsSocketHandle, @Buffer, cnt);
end;
}

{
procedure TFrmLogOn.TimerRBufferPTimer(Sender: TObject);
var
	i, len : integer;
   wcnt : word;
   sd: TWordComData;
   gSocketBuffer : array [0..MAXSOCKETDATASIZE-1] of byte;
begin
   AnsSocketUpDate (AnsSocketHandle);

   len := AnsSocketRead (AnsSocketHandle, @gSocketBuffer, PROCESSDATASIZE);
   if len > 0 then begin
      if MainBuffer.Put (@gSocketBuffer, len) = false then begin
         ShowMessage ('MainBuffer.Put () failed');
      end;
   end;

   for i := 0 to 50 - 1 do begin
      if MainBuffer.View (@wcnt, sizeof (word)) = false then break;
      if MainBuffer.Count < wcnt + sizeof (word) then break;
      if MainBuffer.Get (@sd, wcnt + sizeof (word)) = false then break;
      Reverse4Bit (sd);
      MessageProcess (sd);
   end;
end;
}


procedure TFrmLogOn.FormActivate(Sender: TObject);
const
   bofirst: boolean = TRUE;
var
   n : integer;
   sip, sport, sname : string;
begin
   if not bofirst then exit;
   bofirst := FALSE;

   n := HostAddressClass.FindIndexByname (ComBoBox.text);
   sip := HostAddressClass.GetIps (n , '210.113.15.129');
   sport := HostAddressClass.GetPorts (n , '3051');
   sname := HostAddressClass.GetNames (n , Conv('创造'));

   sckConnect.Address := sip;
   sckConnect.Port := _StrToInt (sport);

   Caption := Conv('千年')+' [' + sname +']';

   CaptionServerName := sname;

   {
   if not boTimePaid then begin
      if comparisonParam then begin
         sckConnect.Active := TRUE;
      end;
   end else begin
      sckConnect.Active := TRUE;
   end;
   }
   try
      sckConnect.Active := TRUE;
   except
      Pninfo.Caption := Conv('连接失败!!!');
   end;
   CurServerName := Combobox.text;
end;

procedure TFrmLogOn.ComboBoxChange(Sender: TObject);
var
   n : integer;
   sip, sport, sname: string;
begin
   n := HostAddressClass.FindIndexByName (ComboBox.Text);
   ComboBox.Text := HostAddressClass.GetNames (n, Conv('创造'));
   if CurServerName = ComboBox.Text then exit;
   CurServerName := ComboBox.Text;

   ClientIni.WriteString ('CLIENT','NAMEOFLEND',ComboBox.Text);

   ConnectState := cs_none;
   sckConnect.Active := false;

   n := HostAddressClass.FindIndexByname (ComBoBox.text);
   sip := HostAddressClass.GetIps (n , '210.113.15.129');
   sport := HostAddressClass.GetPorts (n , '3051');
   sname := HostAddressClass.GetNames (n , Conv('创造'));

   try
      if not sckConnect.Active then begin
         sckConnect.Address := sip;
         sckConnect.Port := _StrToInt (sport);
      end else sckConnect.Active := FALSE;
   except
      Pninfo.Caption := Conv('连接失败!!!');
      exit;
   end;

   Pninfo.Caption := Conv('正在连接...');

   EdId.Enabled := FALSE;
   EdPass.Enabled := FALSE;
   BtnLogin.Enabled := FALSE;
   BtnNewUser.Enabled := FALSE;
   EdId.Color := clBtnFace;
   EdPass.Color := clBtnFace;

   try
      sckConnect.Active := TRUE;
   except
      Pninfo.Caption := Conv('连接失败!!!');
   end;
   CurServerName := Combobox.text;

{
   if not boTimePaid then begin
      if comparisonParam then begin
         sckConnect.Active := true;
      end;
   end else sckConnect.Active := true;
}
//   ReConnetFlag := TRUE;
end;

procedure TFrmLogOn.TimerReConnectTimer(Sender: TObject);
begin
   try
      sckConnect.Address := ReConnectIpAddr;
      sckConnect.Port := ReConnectPort;
      sckConnect.Active := true;
      TimerReConnect.Enabled := FALSE;
   except
      exit;
   end;
end;


procedure TFrmLogOn.SetFormText;
begin
   // FrmLogOn font set
   FrmLogOn.Font.Name :=mainFont;

   PnInfo.Font.Name := mainFont;
   ComboBox.Font.Name := mainFont;
   EdID.Font.Name := mainFont;
   EdPass.Font.Name := mainFont;

   Caption := Conv('千年');
   Pninfo.Caption := Conv('正在连接...若无连线名称,请按[新名称]建立.');
end;


procedure TFrmLogOn.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   FrmM.SetA2Form (Self, A2form);
end;

procedure TFrmLogOn.TimerNixConnectConfirmedTimer(Sender: TObject);
var
   str : string;
begin
   if not boTimePaid then begin
      if not CheckConnect then begin
         TimerNixConnectConfirmed.Enabled := FALSE;
         str := ErrorMessage;
         if str = '' then str := Conv('发生未知错误.');
         SocketDisConnect(str,Conv('用户身份认证'),TRUE);
         sleep (100);
         FrmM.Close;
      end;
   end;
end;
procedure TFrmLogOn.TimerSpeedCheckTimer(Sender: TObject);
var
   Tick : integer;
   nHour, nMin, nSec, nMSec : word;
   ElaspedTime : TDateTime;
   aTime : integer;
//   h : pchar;
begin
///// 皋农肺
{
   h := pchar(FindWindow(nil, 'SpeedHack'));
   if h <> nil then PostMessage(THandle(h), WM_QUIT, 0, 0);

   h := pchar(FindWindow(nil, 'GearNT'));
   if h <> nil then PostMessage(THandle(h), WM_QUIT, 0, 0);

   h := pchar(FindWindow(nil, '1000y - XZ'));
   if h <> nil then PostMessage(THandle(h), WM_QUIT, 0, 0);

   h := pchar(FindWindow(nil, 'Brothers Speeder'));
   if h <> nil then PostMessage(THandle(h), WM_QUIT, 0, 0);
}
/////

   FCurTick := mmAnsTick;
   Tick := (FCurTick - FOldTick) div 100;
   ElaspedTime := Time - FStartTime;
   DecodeTime (ElaspedTime, nHour, nMin, nSec, nMSec);
   aTime := nHour * 3600 + nMin * 60 + nSec + 15;
   inc(indexTick);
   if indexTick > 10000 then begin
      FOldTick := mmAnsTick;
      FStartTime := Time;
      indexTick := 0;
   end;
   if Tick > aTime then begin
      TimerSpeedCheck.Enabled := FALSE;
      SocketDisConnect(Conv('请勿使用外挂程序.'), Conv('千年'), TRUE);
      sleep (100);
      FrmM.Close;
   end;
   {
   FrmM.ListBox1.Items.Add(format ('%d : %d = %d',[Tick,aTime,aTime-Tick]));
   FrmM.ListBox1.ItemIndex := FrmM.ListBox1.Items.Count-1;
   if FrmM.ListBox1.Items.Count > 30000 then FrmM.ListBox1.Items.Delete(0);
   }
end;

procedure TFrmLogOn.sckConnectConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
   cVer : TCVer;
//   cIdPass : TCIdPass;
begin
   if PacketSender <> nil then begin
      PacketSender.Free;
   end;
   if PacketReceiver <> nil then begin
      PacketReceiver.Free;
   end;

   PacketSender := TPacketSender.Create ('Sender', 65535, Socket);
   PacketReceiver := TPacketReceiver.Create ('Receiver', 65535);

   if ConnectState = cs_none then begin
      Pninfo.Caption := Conv('连接成功...若无连线名称,请按[新名称]建立.');

      EdId.Enabled := TRUE;
      EdPass.Enabled := TRUE;
      BtnLogin.Enabled := TRUE;
      BtnNewUser.Enabled := TRUE;
      EdId.Color := clBlack;
      EdPass.Color := clBlack;
      if Visible then EdId.SetFocus;

      ConnectState := cs_balance;
   end else if ConnectState = cs_balance then begin
      cVer.rmsg := CM_VERSION;
      cVer.rVer := PROGRAM_VERSION;
      cVer.rNation := NATION_VERSION;
      SocketAddData (sizeof(cVer), @cVer);

      ConnectState := cs_gate;
   end;
   {
      ckey.rmsg := CM_VERSION;
      ckey.rkey := PROGRAM_VERSION;
      SocketAddData (sizeof(ckey), @ckey);
   }
   {
      cVer.rmsg := CM_VERSION;
      cVer.rVer := PROGRAM_VERSION;
      cVer.rNation := NATION_KOREA; // 惫啊备喊 : 茄惫
      SocketAddData (sizeof(cVer), @cVer);
   }

   //      FrmMain.ProgramInit;

   {
      if ReConnectID = '' then begin
         Pninfo.Caption := Conv('捞抚捞 绝绰盒篮 货捞抚阑 穿福技夸[楷搬凳]');
      end else begin
         cIdPass.rmsg := CM_IDPASS;
         StrPCopy ( @cIdPass.rId, ReConnectId);
         StrPCopy ( @cIdPass.rPass, ReConnectPass);
         SocketAddData (sizeof(cIdPass), @cIdPass);
         ClearEdit(FALSE);
         PnInfo.Caption := Conv('泪矫 扁促府技夸');

         ReConnectId := '';
         ReConnectPass := '';
         ReConnectIpAddr := '';
         ReConnectPort := 0;
      end;
   }
end;

procedure TFrmLogOn.sckConnectDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if PacketSender <> nil then begin
      PacketSender.Free;
      PacketSender := nil;
   end;
   if PacketReceiver <> nil then begin
      PacketReceiver.Free;
      PacketReceiver := nil;
   end;
   if not ReConnetFlag then exit;
   if FrmBottom.Visible then begin
      if ReConnectId = '' then begin
         ReConnetFlag := FALSE;
         TimerNixConnectConfirmed.Enabled := FALSE;
         FrmM.DXTimer1.Enabled := FALSE;
         if boTimePaid then
            if not CloseFlag then SocketDisConnect (Conv('与服务器连接中断.'),Conv('千年'),FALSE);
         FrmM.Close;
      end;
   end;
end;

procedure TFrmLogOn.sckConnectError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   PnInfo.Caption := Conv('连接失败!!!')
end;

procedure TFrmLogOn.sckConnectRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   buffer : array [0..4096 - 1] of char;
   nRead : Integer;
begin
   nRead := Socket.ReceiveBuf (buffer, 4096);
   if nRead > 0 then begin
      if PacketReceiver <> nil then begin
         if PacketReceiver.PutData (@buffer, nRead) = false then begin
//            ShowMessage (Conv('款康磊俊霸 楷遏窍矫扁 官而聪促. [PPD]'));
         end;
      end;
   end;
end;

procedure TFrmLogOn.sckConnectWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if PacketSender <> nil then begin
      PacketSender.WriteAllow := true;
   end;
end;

procedure TFrmLogOn.timerProcessTimer(Sender: TObject);
var
   nSize, i : Integer;
   PacketData : TPacketData;
   ComData : TWordComData;
begin
   if PacketSender <> nil then PacketSender.Update;
   if PacketReceiver <> nil then begin
      PacketReceiver.Update;
      if PacketReceiver.Count > 0 then begin
         for i := 0 to 50 -1 do begin
            if PacketReceiver.Count = 0 then exit;
            if PacketReceiver.GetPacket (@PacketData) = false then break;

            nSize := PacketData.PacketSize - SizeOf (Word) - SizeOf (Integer) - SizeOf (Byte) - SizeOf (Byte);

            if nSize < 4096 then begin
               Move (PacketData.Data, ComData, nSize);
               if MessageProcess (ComData) = false then break;
            end;
         end;
      end;
      { // 呈公腹篮 风橇
      while PacketReceiver.Count > 0 do begin
         if PacketReceiver.GetPacket (@PacketData) = false then break;

         nSize := PacketData.PacketSize - SizeOf (Word) - SizeOf (Integer) - SizeOf (Byte) - SizeOf (Byte);

         if nSize < 4096 then begin
            Move (PacketData.Data, ComData, nSize);
            if MessageProcess (ComData) = false then break;
         end;
      end;
      }
   end;
end;


var
   ansStringClass : TansStringClass;

function Conv (astr : string): string;
begin
   Result := ansStringClass.GetString(astr);
end;

Initialization
begin
   ansStringClass := TansStringClass.Create;
   if NATION_VERSION = NATION_KOREA then exit;
   ansStringClass.LoadFromFile ('ncl1000.acs');
end;

Finalization
begin
   ansStringClass.Free;
end;


end.


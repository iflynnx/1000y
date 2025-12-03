unit UUser;

interface

uses
  Windows, SysUtils, Classes, ScktComp, WinSock, aDefType, svclass, deftype,
  aUtil32, basicobj, fieldmsg, AnsImg2, mapunit, subutil, uanstick, uSendcls,
  uUserSub, aiunit, uLetter, uManager, AnsStringCls, uConnect, uBuffer,
  uItemLog, uKeyClass, uGramerID, mmSystem, uLevelExp;

const
   InputStringState_None          = 0;
   InputStringState_AddExchange   = 1;
   InputStringState_Search        = 2;

   RefusedMailLimit               = 5; // 芭何等 率瘤狼 弥措荐 (率瘤扁瓷阑 荤侩且 荐 绝霸凳)
   MailSenderLimit                = 5; // 焊辰 荤恩阑 扁撅窍绰 弥措摹

type
   TMouseEventData = record
     rtick : Integer;
     revent: array [0..10-1] of integer;
   end;
   PTMouseEventData = ^TMouseEventData;

   // 概农肺 眉农甫 淬淬窍绰 努贰胶
   TMacroChecker = class
   private
      nSaveCount : Integer; // 付快胶捞亥飘 单捞鸥 焊包 肮荐
      DataList : TList;

      nReceivedCount : Integer; // 眠啊等 付快胶 捞亥飘 单捞鸥狼 墨款飘

      function CheckNone : Boolean; // 沥富肺 酒公老档 窍瘤 臼绰 荤恩
      function CheckCase1 : Boolean; // MouseMove父 0 < x < 20 牢 荤恩
      function CheckCase2 : Boolean; // 30盒悼救 荐摹啊 +-10%捞郴牢 荤恩
      function CheckCase3 : Boolean; // 呈公 磊林 焊郴绰 荤恩

   public
      constructor Create(anSaveCount : Integer);
      destructor Destroy; override;

      procedure Clear;

      procedure SaveMacroCase(aName : String; nCase : Integer);
      procedure AddMouseEvent(pMouseEvent : PTCMouseEvent; anTick : Integer);
      function Check(aName : String) : Boolean;
   end;

   TUserObject = class (TBasicObject)
   private
     Connector : TConnector;

     boFalseVersion : Boolean;
     boShiftAttack : Boolean;
     TargetId : integer;
     PrevTargetID : Integer;
     LifeObjectState : TLifeObjectState;

     RopeTarget : integer;
     RopeTick : integer;
     RopeOldX, RopeOldy : word;

     ShootBowCount : integer;

     FreezeTick : integer;
     DiedTick : integer;
     HitedTick : integer;
     // StructedTick : Integer;
     LifeData : TLifeData;

     function   AllowCommand (CurTick: integer): Boolean;
   protected
     LastGainExp : integer;

     DisplayValue : Word;
     DisplayTick : Integer;

     AttribClass : TAttribClass;
     WearItemClass : TWearItemClass;
     HaveItemClass : THaveItemClass;
     HaveMagicClass : THaveMagicClass;

     function  FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
     procedure Initial (aName: string);
     procedure StartProcess; override;
     procedure EndProcess; override;
   public
     Name, IP : String;
     GuildServerID : Integer;
     GuildName : string;
     GuildGrade : string;
     SendClass : TSendClass;
     SayTick : integer;
     SearchTick : integer;

     constructor Create;
     destructor Destroy; override;
     procedure SetTargetId (aid: integer);
     procedure CommandChangeCharState (aFeatureState: TFeatureState; boSend: Boolean);
     procedure ShowEffect (aEffectNumber : Word; aEffectKind : TLightEffectKind);
     function  CommandHited (aattacker: integer; aHitData: THitData; apercent: integer): integer;
     function  CommandHit (CurTick: integer; boSend: Boolean): Boolean;
     procedure CommandBowing (CurTick: integer; atid: integer; atx, aty: word; boSend: Boolean);
     procedure CommandTurn (adir: word; boSend: Boolean);
     procedure Update (CurTick: integer); override;

     function GetLifeObjectState : TLifeObjectState;
     function AddMagic  (aMagicData: PTMagicData): Boolean;
     function FindHaveMagicByName (aMagicName : String) : Integer;
     function DeleteItem (aItemData: PTItemData): Boolean;
     function FindItem (aItemData : PTItemData): Boolean;

     procedure SetLifeData;
   public
     function GetAge : Integer;
   end;


   TUser = class (TUserObject)
   private
     boNewServer : Boolean;

     boTv : Boolean;
     boException : Boolean;

     boCanSay, boCanMove, boCanAttack : Boolean;

     InputStringState : integer;
     CountWindowState : integer;

     CM_MessageTick : array [0..255] of integer;
     PrisonTick : Integer;
     SaveTick : integer;
     FalseTick : integer;
     PosMoveX, PosMoveY: integer;
     SysopScope : integer;

     MailBox : TList;
     MailTick : Integer;
     RefuseReceiver : TStringList;
     MailSender : TStringList;
     boLetterCheck : Boolean;

     UseSkillKind : Integer;
     SkillUsedTick : Integer;
     SkillUsedMaxTick  : Integer;

     SpecialWindow : Byte;
     ItemLogData : array [0..4 - 1] of TItemLogRecord;

     CopyHaveItem : THaveItemClass;

     MacroChecker : TMacroChecker;

     NetStateID : Integer;
     NetStateTick : Integer;
     SaveNetState : TCNetState;

     // procedure SendData (cnt:integer; pb:pbyte);

     procedure LoadUserData (aName: string);
     procedure SaveUserData (aName: string);
     procedure MessageProcess (var code: TWordComData);
     function  FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
     procedure UserSay (astr: string);
     procedure DragProcess (var code: TWordComData);
     procedure InputStringProcess (var code: TWordComData);
     procedure SelectCount (var Code : TWordComData);
     procedure ClickExChange (awin:byte; aclickedid:longInt; akey:word);
     function  AddableExChangeData (pex : PTExChangedata): Boolean;
     procedure AddExChangeData (var aSenderInfo : TBasicData; pex : PTExChangedata; aSenderIP : String);
     procedure DelExChangeData (pex : PTExChangedata);

   public
     SysopObj, UserObj : TBasicObject;
      
     ExChangeData : TExChangeData;
     procedure ExChangeStart (aId : Integer);
     function isCheckExChangeData: Boolean;

     constructor Create;
     destructor Destroy; override;
     function  InitialLayer (aCharName: String) : Boolean;
     procedure FinalLayer;

     procedure Initial (aName: string);
     procedure StartProcess; override;
     procedure EndProcess; override;
     procedure Update (CurTick: integer); override;

     function  FieldProc2 (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;

     procedure AddRefusedUser (aName : String);
     procedure DelRefusedUser (aName : String);
     procedure AddMailSender (aName : String);
     function CheckSenderList (aName : String) : Boolean;

     procedure SetPosition (x, y : Integer);
     procedure SetPositionBS (ex, ey : Integer);

     function ShowItemLogWindow : String;
     function MovingStatus : Boolean;
     procedure UdpSendMouseEvent (aInfoStr: String);

     property LetterCheck : Boolean read boLetterCheck;
     property Exception : Boolean read boException write boException;
   end;

   TUserList = class
   private
     ExceptCount : integer;
     CurProcessPos : integer;
     UserProcessCount : Integer;
     
     // AnsList : TAnsList;
     NameKey : TStringKeyClass;
     DataList : TList;

     // TvList : TList;

     function  GetCount: integer;
   public
     constructor Create (cnt: integer);
     destructor  Destroy; override;
     function    InitialLayer (aCharName: string; aConnector : TConnector) : Boolean;
     procedure   FinalLayer (aConnector : TConnector);
     procedure   StartChar (aCharname: string);

     function    GetUserPointer (aCharName: string): TUser;
     function    GetUserPointerById (aId: LongInt): TUser;

     procedure   GuildSay (aGuildName, astr: string);
     function    GetGuildUserInfo (aGuildName: string): string;

     procedure   SayByServerID (aServerID : Integer; aStr: String);
     procedure   MoveByServerID (aServerID : Integer; aTargetID, aTargetX, aTargetY : Integer);

     procedure   SendNoticeMessage (aStr: String; aColor : Integer);
     // procedure   SendGradeShoutMessage (astr: string; aColor: integer);
     function    GetUserList: string;
     procedure   SendRaining (aRain : TSRainning);

     // function    FieldProc2 (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;

     procedure   Update (CurTick: integer);
     property    Count : integer read GetCount;

     procedure   SaveUserInfo (aFileName : String);
     procedure   SendSoundEffect (aManager : TManager; aSoundEffect : String);
   end;

var
  UserList : TUserList;
  boCheckSpeed : Boolean = false;

implementation

uses
   uNpc, uMonster, uGuild, SvMain, FSockets, FGate, uGConnect, uDoorGen;

////////////////////////////////////////////////////
//
//             ===  TMacroChecker  ===
//
////////////////////////////////////////////////////

constructor TMacroChecker.Create(anSaveCount : Integer);
var
   i : Integer;
   pMouseEvent : PTMouseEventData;
begin
   nSaveCount := anSaveCount;
   DataList := TList.Create;

   for i := 0 to nSaveCount - 1 do begin
      New(pMouseEvent);
      if pMouseEvent <> nil then begin
         FillChar(pMouseEvent^, sizeof(TMouseEventData), 0);
         DataList.Add(pMouseEvent);
      end;
   end;

   nReceivedCount := 0;
end;

destructor TMacroChecker.Destroy;
var
   i : Integer;
   pMouseEvent : PTMouseEventData;
begin
   for i := 0 to DataList.Count - 1 do begin
      pMouseEvent := DataList.Items[i];
      if pMouseEvent <> nil then Dispose(pMouseEvent);
   end;
   DataList.Clear;
   DataList.Free;
end;

procedure TMacroChecker.Clear;
begin
   nReceivedCount := 0;   
end;

function TMacroChecker.CheckNone : Boolean; // 沥富肺 酒公 老档 救窍绰 荤恩
var
   i, j : integer;
   pMouseEventData : PTMouseEventData;
begin
   Result := false;

   if nReceivedCount = nSaveCount then begin
      for i := 0 to nReceivedCount - 1 do begin
         pMouseEventData := DataList.Items[i];
         if pMouseEventData = nil then break;
         for j := 0 to 10 - 1 do begin
            if pMouseEventData^.revent[j] <> 0 then exit;
         end;
      end;
   end;

   Result := true;
end;

function TMacroChecker.CheckCase1: Boolean; // MouseMove父 0 < x < 20 牢 荤恩
var
   i, j : integer;
   pMouseEventData : PTMouseEventData;
begin
   Result := false;

   for i := 0 to nReceivedCount - 1 do begin
      pMouseEventData := DataList.Items[i];
      if pMouseEventData = nil then exit;
      for j := 1 to 10 - 1 do begin
         if pMouseEventData^.revent[j] <> 0 then exit;
      end;
      if (pMouseEventData^.revent[0] <= 0) or (pMouseEventData^.revent[0] >= 20) then exit;
   end;

   Result := true;
end;

function TMacroChecker.CheckCase2: Boolean; // 30盒悼救 荐摹啊 +-10%捞郴牢 荤恩
var
   i, j : integer;
   pMouseEventData : PTMouseEventData;
   AverageData, LimitData : TMouseEventData;
begin
   Result := false;

   FillChar(AverageData, sizeof(TMouseEventData), 0);
   for i := 0 to nReceivedCount - 1 do begin
      pMouseEventData := DataList.Items[i];
      if pMouseEventData = nil then exit;
      for j := 0 to 10 - 1 do begin
         AverageData.revent[j] := AverageData.revent[j] + pMouseEventData^.revent[j];
      end;
   end;
   for i := 0 to 10 - 1 do begin
      AverageData.revent[i] := Integer(AverageData.revent[i] div nReceivedCount);
      LimitData.revent[i] := Integer(AverageData.revent[i] div 10);
   end;

   for i := 0 to nReceivedCount - 1 do begin
      pMouseEventData := DataList.Items[i];
      if pMouseEventData = nil then exit;
      for j := 0 to 10 - 1 do begin
         if pMouseEventData^.revent[j] > AverageData.revent[j] + LimitData.revent[i] then exit;
         if pMouseEventData^.revent[j] < AverageData.revent[j] - LimitData.revent[i] then exit;
      end;
   end;

   Result := true;
end;

function TMacroChecker.CheckCase3: Boolean; // 呈公 磊林 焊郴绰 荤恩
var
   i : integer;
   nTick, nSumTick : Integer;
   pD1, pD2 : PTMouseEventData;
begin
   Result := false;

   nSumTick := 0;
   for i := 0 to nReceivedCount - 2 do begin
      pD1 := DataList.Items[i];
      pD2 := DataList.Items[i + 1];
      if (pD1 = nil) or (pD2 = nil) then exit;
      nTick := pD1^.rTick - pD2^.rTick;
      nSumTick := nSumTick + nTick;
   end;

   nTick := Integer(nSumTick div (nReceivedCount - 1));
   if nTick >= 6000 then exit; // 1盒

   Result := true;
end;

procedure TMacroChecker.SaveMacroCase(aName : String; nCase : Integer);
   function GetCurDate : String;
   var
      nYear, nMonth, nDay : Word;
      sDate : String;
   begin
      Result := '';
      try
         DecodeDate (Date, nYear, nMonth, nDay);
         sDate := IntToStr(nYear);
         if nMonth < 10 then sDate := sDate + '0';
         sDate := sDate + IntToStr(nMonth);
         if nDay < 10 then sDate := sDate + '0';
         sDate := sDate + IntToStr(nDay);
      except
      end;
      Result := sDate;
   end;
var
   Stream : TFileStream;
   szBuffer : array[0..128] of byte;
   tmpStr, CaseStr, FileName : String;
begin
   Case nCase of
      1 : CaseStr := '只有MouseMove的数值是0 < x < 20的人';
      2 : CaseStr := '30分钟内平均数值在误差10%范围以内的人';
      3 : CaseStr := '5分间格更快时间传输的人';
      4 : CaseStr := 'SpeedHack使用者';
   end;
   try
      FileName := '.\MacroData\MC' + GetCurDate + '.SDB';
      if FileExists(FileName) then begin
         Stream := TFileStream.Create(FileName, fmOpenReadWrite);
         Stream.Seek(0, soFromEnd);
      end else begin
         Stream := TFileStream.Create(FileName, fmCreate);
         tmpStr := 'DateTime, Name, Case' + #13#10;
         StrPCopy(@szBuffer, tmpStr);
         Stream.WriteBuffer (szBuffer, StrLen(@szBuffer));
      end;

      tmpStr := DateToStr(Date) + ' ' + TimeToStr(Time) + ',' + aName + ',' + CaseStr + ',' + #13#10;
      StrPCopy(@szBuffer, tmpStr);
      Stream.WriteBuffer(szBuffer, StrLen(@szBuffer));
      Stream.Destroy;
   except
   end;
end;

procedure TMacroChecker.AddMouseEvent(pMouseEvent : PTCMouseEvent; anTick : Integer);
var
   pMouseEventData : PTMouseEventData;
begin
   if nSaveCount < DataList.Count then Exit;
   pMouseEventData := DataList.Items[nSaveCount - 1];
   if pMouseEventData = nil then Exit;

   pMouseEventData^.rTick := anTick;
   Move(pMouseEvent^.revent, pMouseEventData^.revent, sizeof(Integer) * 10);
   DataList.Delete (nSaveCount - 1);
   DataList.Insert (0, pMouseEventData);

   if nReceivedCount < nSaveCount then begin
      nReceivedCount := nReceivedCount + 1;
   end;
end;

function TMacroChecker.Check(aName : String) : Boolean;
var
   bFlag : Boolean;
begin
   Result := true;

   bFlag := CheckNone;
   if bFlag = true then begin
      Result := false;
      exit;
   end;

   bFlag := CheckCase1;
   if bFlag = true then begin
      SaveMacroCase(aName, 1);
      exit;
   end;
   bFlag := CheckCase2;
   if bFlag = true then begin
      SaveMacroCase(aName, 2);
      exit;
   end;
   bFlag := CheckCase3;
   if bFlag = true then begin
      SaveMacroCase(aName, 3);
      exit;
   end;

   Result := false;
end;


constructor TUserObject.Create;
begin
   inherited Create;
   
   SendClass := TSendClass.Create;
   AttribClass := TAttribClass.Create (Self, SendClass);

   HaveMagicClass := THaveMagicClass.Create (Self, SendClass, AttribClass);
   WearItemClass := TWearItemClass.Create (Self, SendClass, AttribClass);
   HaveItemClass := THaveItemClass.Create (SendClass, AttribClass);

   LifeObjectState := los_init;
end;

destructor TUserObject.Destroy;
begin
   HaveItemClass.Free;
   WearItemClass.Free;
   HaveMagicClass.Free;

   AttribClass.Free;
   SendClass.Free;
   inherited destroy;
end;

function TUserObject.GetAge : Integer;
begin
   Result := AttribClass.GetAge;
end;

function TUserObject.GetLifeObjectState : TLifeObjectState;
begin
   Result := LifeObjectState;
end;

procedure TUserObject.SetLifeData;
begin
   FillChar (LifeData, SizeOf (TLifeData), 0);

   GatherLifeData (LifeData, AttribClass.AttribLifeData);
   GatherLifeData (LifeData, WearItemClass.WearItemLifeData);
   GatherLifeData (LifeData, HaveMagicClass.HaveMagicLifeData);
   
   CheckLifeData (LifeData);
end;


procedure TUserObject.SetTargetId (aid: integer);
var
   bo : TBasicObject;
begin
   if (TargetId <> 0) and (aid = 0) then begin
      PrevTargetId := TargetId;
   end;
   if aid = BasicData.id then exit;
   TargetId := aid;
   if TargetId = 0 then exit;

   bo := TBasicObject (GetViewObjectById (TargetId));
   if bo = nil then exit;
   if bo.State = wfs_die then exit;
   if TUser (Self).UseSkillKind <> ITEM_KIND_SHOWSKILL then begin
      if bo.BasicData.Feature.rHideState = hs_0 then exit;
   end;

   if Basicdata.Feature.rfeaturestate <> wfs_care then CommandChangeCharState (wfs_care, FALSE);

   LifeObjectState := los_attack;
end;

procedure TUserObject.StartProcess;
var
   ItemData: TItemData;
   str : String;
begin
   Inherited StartProcess;

   RopeTarget := 0;
   RopeTick := 0;
   RopeOldX := 0;
   RopeOldy := 0;

   boShiftAttack := TRUE;
   SearchTick := 0;
   SayTick := 0;
   FreezeTick := 0;
   DiedTick := 0;
   HitedTick := 0;
   // StructedTick := 0;
   TargetId := 0;
   PrevTargetId := 0;
   LifeObjectState := los_none;

   Basicdata.id := GetNewUserId;
   BasicData.Feature := WearItemClass.GetFeature;
   WearItemClass.ViewItem (ARR_WEAPON, @ItemData);
   HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
   HaveMagicClass.SelectBasicMagic (ItemData.rHitType, 100, str);

   BasicData.nx := BasicData.x;
   BasicData.ny := BasicData.y;

   SendClass.SendMap (BasicData, Manager.MapName, Manager.ObjName, Manager.RofName, Manager.TilName, Manager.SoundBase);
end;

procedure TUserObject.EndProcess;
begin
   WearItemClass.SaveToSdb (@Connector.CharData);
   HaveItemClass.SaveToSdb (@Connector.CharData);
   AttribClass.SaveToSdb (@Connector.CharData);
   HaveMagicClass.SaveToSdb (@Connector.CharData);

   FreezeTick := 0;
   DiedTick := 0;
   HitedTick := 0;
   // StructedTick := 0;
   TargetId := 0;
   LifeObjectState := los_init;
   Name := '';
   IP := '';
   
   Inherited EndProcess;
end;

function  TUserObject.AllowCommand (CurTick: integer): Boolean;
begin
   Result := TRUE;
   if FreezeTick > CurTick then Result := FALSE;
   if BasicData.Feature.rFeatureState = wfs_die then Result := FALSE;
end;

procedure TUserObject.ShowEffect (aEffectNumber : Word; aEffectKind : TLightEffectKind);
var
   SubData : TSubData;
begin
   BasicData.Feature.rEffectNumber := aEffectNumber;
   BasicData.Feature.rEffectKind := aEffectKind;

   SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

   BasicData.Feature.rEffectNumber := 0;
   BasicData.Feature.rEffectKind := lek_none;
end;

function   TUserObject.CommandHited (aattacker: integer; aHitData: THitData; apercent: integer): integer;
var
   // CurTick : Integer;
   snd, n, decbody, dechead, decArm, decLeg, exp : integer;
   SubData : TSubData;
begin
   Result := 0;

   // 嘎狙绰啊 乔沁绰啊
   n := LifeData.avoid + aHitData.ToHit;
   n := Random (n);
   if n < LifeData.avoid then exit; // 乔沁澜.

   {
   CurTick := mmAnsTick;
   if CurTick <= StructedTick + LifeData.recovery then exit;
   StructedTick := CurTick;
   }

   // 贸澜 乔秦 眉仿
   if apercent = 100 then begin
      decHead := aHitData.damagehead - LifeData.armorHead;
      decArm := aHitData.damageArm - LifeData.armorArm;
      decLeg := aHitData.damageLeg - LifeData.armorLeg;
      decbody := aHitData.damageBody - LifeData.armorBody;
   end else begin
      decHead := (aHitData.damagehead * apercent div 100) * aHitData.HitFunctionSkill div 10000 - LifeData.armorHead;
      decArm :=  (aHitData.damageArm * apercent div 100) * aHitData.HitFunctionSkill div 10000 - LifeData.armorArm;
      decLeg :=  (aHitData.damageLeg * apercent div 100) * aHitData.HitFunctionSkill div 10000 - LifeData.armorLeg;
      decbody := (aHitData.damageBody * apercent div 100) * aHitData.HitFunctionSkill div 10000 - LifeData.armorBody;
   end;

   if decHead <= 0 then decHead := 1;
   if decArm <= 0 then decArm := 1;
   if decLeg <= 0 then decLeg := 1;
   if decbody <= 0 then decbody := 1;

   // 郴己俊 狼茄 乔秦 皑家 (个烹俊父 利侩凳)
   n := AttribClass.MaxLife div decBody;
   if n <= 4 then begin
      decBody := decBody - decBody * AttribClass.AttribData.cAdaptive div 20000; // 利览仿篮 50%
   end;
   if decBody <= 0 then decBody := 1;

   // 眉仿家葛
   AttribClass.CurHeadLife := AttribClass.CurHeadLife - decHead;
   AttribClass.CurArmLife  := AttribClass.CurArmLife - decArm;
   AttribClass.CurLegLife  := AttribClass.CurLegLife - decLeg;
   AttribClass.CurLife     := AttribClass.CurLife - decBody;

   //  磊技焊沥...
{
   Case aHitData.HitLevel of
      0..4999 :
         FreezeTick := mmAnsTick;
      5000..5999 :
         FreezeTick := mmAnsTick + (TempData.recovery div 10);
      6000..6999 :
         FreezeTick := mmAnsTick + (TempData.recovery div 8);
      7000..7999 :
         FreezeTick := mmAnsTick + (TempData.recovery div 6);
      8000..8999 :
         FreezeTick := mmAnsTick + (TempData.recovery div 4);
      9000..9499 :
         FreezeTick := mmAnsTick + (TempData.recovery div 2);  50
      9500..9999 :
         FreezeTick := mmAnsTick + TempData.recovery;
   end;
}  {
   Case aHitData.HitLevel of
      9500..9999 : sdec := 40;
      9000..9499 : sdec := 35;
      8000..8999 : sdec := 30;
      7000..7999 : sdec := 20;
      6000..6999 : sdec := 10;
      5000..5999 : sdec := 5;
      0..4999 :    sdec := 0;
   end;
   m := AttribClass.MaxLife div decbody;
   case m of
      0..15  : ddec := 10;
      16..20 : ddec := 5;
      else     ddec := 0;
   end;
   m := sdec + ddec + 50;

   FreezeTick := mmAnsTick + TempData.recovery * m div 100;
   }

   FreezeTick := mmAnsTick + LifeData.recovery;

   if AttribClass.MaxLife <= 0 then BasicData.LifePercent := 0
   else BasicData.LifePercent := AttribClass.CurLife * 100 div AttribClass.MaxLife;
   
   SubData.percent := BasicData.LifePercent;
   SubData.attacker := aattacker;
   SubData.HitData.HitType := aHitData.HitType;
   
   SendLocalMessage (NOTARGETPHONE, FM_STRUCTED, BasicData, SubData);
   Result := n;

   // 磷阑订 酒公 版摹档 绝澜
   if AttribClass.CurLife = 0 then exit;

   // 利览仿 歹窍扁 郴己 +
   n := AttribClass.MaxLife div decBody;
   if n <= 4 then AttribClass.AddAdaptive (DEFAULTEXP);

   // 版摹 歹窍扁
   n := AttribClass.MaxLife div decbody;
   if n > 15 then exp := DEFAULTEXP               // 15 措捞惑 嘎阑父 窍促搁 1000
   else exp := DEFAULTEXP * n * n div (15 * 15);   // 15措 嘎栏搁 磷备档 巢栏搁 10 => 500   n 15 => 750   5=>250

   SubData.ExpData.Exp := exp;
   SubData.ExpData.ExpType := 0;
   if apercent = 100 then begin
      // if not isUserID (aAttacker) then begin // 内膏飘啊 酒聪搁 个户 倾侩
         SendLocalMessage (aattacker, FM_ADDATTACKEXP, BasicData, SubData);
      // end;
   end;

   // 碍脚 歹窍扁
   // if not isUserID (aAttacker) then begin // 内膏飘啊 酒聪搁 个户 倾侩
      SubData.ExpData.Exp := DEFAULTEXP - SubData.ExpData.Exp;
      SendLocalMessage (BasicData.Id, FM_ADDPROTECTEXP, BasicData, SubData);
   // end;

   snd := Random (100);
   if snd < 40 then begin
      case AttribClass.AttribData.cAge of
         0..5999 :      snd := 2002;
         6000..11900 :  snd := 2004;
         else           snd := 2000;
      end;
      if not BasicData.Feature.rboman then snd := snd + 200;
      SetWordString (SubData.SayString, IntToStr (snd) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;

   BoSysopMessage (IntToStr(decBody) + ' : ' + IntToStr(exp), 10);

   Result := n;
end;

procedure TUserObject.CommandBowing (CurTick: integer; atid: integer; atx, aty: word; boSend: Boolean);
var
   snd, pos : integer;
   boHitAllow: Boolean;
   SubData : TSubData;
   tmpItemData : TItemData;
begin
   if not AllowCommand (CurTick) then exit;

   if HitedTick + LifeData.AttackSpeed > CurTick then exit;

   if HaveMagicClass.pCurAttackMagic = nil then exit;
   
   if ShootBowCount > (HaveMagicClass.pCurAttackMagic^.rcSkillLevel div 2000) + 1 then begin
      SetTargetId (0);
      ShootBowCount := 0;
      exit;
   end;
   inc (ShootBowCount);

   boHitAllow := FALSE;
   case HaveMagicClass.pCurAttackMagic^.rMagicType of
      5 : // 泵贱
         begin
            pos := HaveItemClass.FindKindItem (7);
            if pos <> -1 then begin
               HaveItemClass.ViewItem (pos, @tmpItemData);
               tmpItemData.rOwnerName[0] := 0;
               if HaveItemClass.DeleteKeyItem (pos, 1, @tmpItemData) then boHitAllow := TRUE;
            end;
         end;
      6 : // 捧过
         begin
            pos := HaveItemClass.FindKindItem (8);
            if pos <> -1 then begin
               HaveItemClass.ViewItem (pos, @tmpItemData);
               tmpItemData.rOwnerName[0] := 0;
               if HaveItemClass.DeleteKeyItem (pos, 1, @tmpItemData) then boHitAllow := TRUE;
            end;
         end;
      else
         boHitAllow := TRUE;
   end;

   if boHitAllow = FALSE then exit;

   HitedTick := CurTick;

   if HaveMagicClass.DecEventMagic (HaveMagicClass.pCurAttackMagic) = FALSE then begin
      SendClass.SendChatMessage ('没能攻击.', SAY_COLOR_SYSTEM);
      exit;
   end;

   if GetViewDirection (BasicData.x, BasicData.y, atx, aty) <> basicData.dir then
      CommandTurn ( GetViewDirection (BasicData.x, BasicData.y, atx, aty), TRUE);
      
   SubData.motion := BasicData.Feature.rhitmotion;
   SendLocalMessage ( NOTARGETPHONE, FM_MOTION, BasicData, SubData);

   SubData.HitData.damageBody := LifeData.damageBody;
   SubData.HitData.damageHead := LifeData.damageHead;
   SubData.HitData.damageArm := LifeData.damageArm;
   SubData.HitData.damageLeg := LifeData.damageLeg;
   // SubData.HitData.ToHit := 100 - LifeData.avoid;
   SubData.HitData.ToHit := 75;
   SubData.HitData.HitType := 1;
   SubData.HitData.HitLevel := 0;
   
   if HaveMagicClass.pCurAttackMagic <> nil then
      SubData.HitData.HitLevel := HaveMagicClass.pCurAttackMagic^.rcSkillLevel;

   AttribClass.CurLife := AttribClass.CurLife - HaveMagicClass.pCurattackmagic^.rEventDecLife;

   SubData.TargetId := atid;
   SubData.tx := atx;
   SubData.ty := aty;
   // SubData.BowImage := HaveMagicClass.pCurAttackMagic^.rBowImage;
   SubData.BowImage := tmpItemData.rActionImage;
   SubData.BowSpeed := HaveMagicClass.pCurAttackMagic^.rBowSpeed;
   SubData.BowType := HaveMagicClass.pCurAttackMagic^.rBowType;
   SendLocalMessage (NOTARGETPHONE, FM_BOW, BasicData, SubData);

   snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber;
   if snd <> 0 then begin
      case HaveMagicClass.pCurAttackMagic^.rcSkillLevel of
         0..4999: snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber;
         5000..8999: snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber+1;
         else snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber+2;
      end;

      SetWordString (SubData.SayString, InttoStr(snd) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;

   if boSend then SendClass.SendMotion (BasicData.id, SubData.motion);
end;

function  TUserObject.CommandHit (CurTick: integer; boSend: Boolean): Boolean;
var
   snd, allowAttackTick : integer;
   per, nskill :integer;
   SubData : TSubData;
begin
   Result := FALSE;

   if not AllowCommand (CurTick) then exit;
   if HaveMagicClass.pCurAttackMagic = nil then exit;

   per := (AttribClass.CurLegLife * 100 div AttribClass.MaxLife);

   if per > 50 then AllowAttackTick := LifeData.AttackSpeed
   else AllowAttackTick := LifeData.AttackSpeed + LifeData.AttackSpeed * (50 - per) div 50;    // 100% 沥档 词霸 锭妨柳促.

   if HitedTick + AllowAttackTick > CurTick then exit;
   HitedTick := CurTick;

   if HaveMagicClass.DecEventMagic (HaveMagicClass.pCurAttackMagic) = FALSE then begin
      SendClass.SendChatMessage ('没能攻击.', SAY_COLOR_SYSTEM);
      exit;
   end;

   per := (AttribClass.CurArmLife * 100 div AttribClass.MaxLife);

   if per > 50 then begin
      SubData.HitData.damageBody := LifeData.damageBody;
      SubData.HitData.damageHead := LifeData.damageHead;
      SubData.HitData.damageArm := LifeData.damageArm;
      SubData.HitData.damageLeg := LifeData.damageLeg;
   end else begin
      SubData.HitData.damageBody := LifeData.damageBody - LifeData.damageBody * (50 - per) div 50;
      SubData.HitData.damageHead := LifeData.damageHead - LifeData.damageHead * (50 - per) div 50;
      SubData.HitData.damageArm := LifeData.damageArm - LifeData.damageArm * (50 - per) div 50;
      SubData.HitData.damageLeg := LifeData.damageLeg - LifeData.damageLeg * (50 - per) div 50;
   end;

   // SubData.HitData.ToHit := 100 - tempData.avoid;
   SubData.HitData.ToHit := 75;
   SubData.HitData.HitType := 0;
   SubData.HitData.HitLevel := 0;
   SubData.HitData.boHited := FALSE;
   SubData.HitData.HitFunction := 0;
   SubData.HitData.HitFunctionSkill := 0;
   SubData.HitData.HitedCount := 0;

   if HaveMagicClass.pCurAttackMagic <> nil then SubData.HitData.HitLevel := HaveMagicClass.pCurAttackMagic^.rcSkillLevel;
   if HaveMagicClass.pCurEctMagic <> nil then begin
      case HaveMagicClass.pCurEctMagic^.rFunction of
         MAGICFUNC_5HIT, MAGICFUNC_8HIT :
            begin
               SubData.HitData.HitFunction := HaveMagicClass.pCurEctMagic^.rFunction;
               SubData.HitData.HitFunctionSkill := HaveMagicClass.pCurEctMagic^.rcSkillLevel;
            end;
      end;
   end;

   LastGainExp := 0;
   SendLocalMessage (NOTARGETPHONE, FM_HIT, BasicData, SubData);

   if (HaveMagicClass.pCurEctMagic <> nil) and (SubData.HitData.HitedCount > 1) then begin
      HaveMagicClass.AddEctExp (10, LastGainExp);
   end;

   if SubData.HitData.boHited then begin
      snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber;
      if snd <> 0 then begin
         case HaveMagicClass.pCurAttackMagic^.rcSkillLevel of
            0..4999: snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber;
            5000..8999: snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber+2;
            else snd := HaveMagicClass.pCurAttackMagic^.rSoundStrike.rWavNumber+4;
         end;

         SetWordString (SubData.SayString, InttoStr(snd) + '.wav');
         SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      end;
   end else begin
      snd := HaveMagicClass.pCurAttackMagic^.rSoundSwing.rWavNumber;
      if snd <> 0 then begin
         case HaveMagicClass.pCurAttackMagic^.rcSkillLevel of
            0..4999: snd := HaveMagicClass.pCurAttackMagic^.rSoundSwing.rWavNumber;
            5000..8999: snd := HaveMagicClass.pCurAttackMagic^.rSoundSwing.rWavNumber+2;
            else snd := HaveMagicClass.pCurAttackMagic^.rSoundSwing.rWavNumber+4;
         end;

         SetWordString (SubData.SayString, InttoStr(snd) + '.wav');
         SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      end;
   end;


   // 鼻过阑 荤侩窍绰 荤恩篮 荐访摹啊 臭酒瘤搁(50) 30锅捞唱 31锅 葛拣栏肺 傍拜茄促.
   SubData.motion := BasicData.Feature.rhitmotion;

   // 父距 荤侩磊啊 荤侩窍绰 公傍捞 八过捞唱 档过老版快俊绰
   // 荐访摹啊 50.00焊促 臭酒瘤搁 subdata.motion 篮 32锅捞芭唱 37锅栏肺 焊咯霖促.
   case HaveMagicClass.pCurAttackMagic.rMagicType of
      MAGICTYPE_WRESTLING :
         begin
            if (HaveMagicClass.pCurAttackMagic^.rcSkillLevel > 5000) then
               SubData.motion := 30+Random (2);
         end;
      MAGICTYPE_FENCING :
         begin
            nskill := HaveMagicClass.pCurAttackMagic^.rcSkillLevel;
            if (nskill > 5000) then begin
               if Random (2) = 1 then SubData.motion := 38;
            end
         end;
      MAGICTYPE_SWORDSHIP :
         begin
            nskill := HaveMagicClass.pCurAttackMagic^.rcSkillLevel;
            if (nskill > 5000) then begin
               if Random (2) = 1 then SubData.motion := 37;
            end
         end;
   end;

   SendLocalMessage ( NOTARGETPHONE, FM_MOTION, BasicData, SubData);

   if boSend then SendClass.SendMotion (BasicData.id, SubData.motion);
   Result := TRUE;
end;


procedure TUserObject.CommandTurn (adir: word; boSend: Boolean);
var SubData : TSubData;
begin
   if not AllowCommand (mmAnsTick) then exit;

   if BasicData.Feature.rFeatureState = wfs_die then exit;
   BasicData.dir := adir;
   SendLocalMessage (NOTARGETPHONE, FM_TURN, BasicData, SubData);
   if boSend then SendClass.SendTurn (BasicData);
end;

procedure TUserObject.CommandChangeCharState (aFeatureState: TFeatureState; boSend: Boolean);
var
   snd : integer;
   SubData : TSubData;
begin
   Case aFeatureState of
      wfs_die : LifeObjectState := los_die;
      Else LifeObjectState := los_none;
   end;
   if aFeatureState = wfs_die then begin
      if Manager.boPosDie = false then begin
         Maper.MapProc (BasicData.Id, MM_HIDE, BasicData.x, BasicData.y, BasicData.x, BasicData.y, BasicData);
      end;
      
      SetTargetId (0);
      DiedTick := mmAnsTick;

      case AttribClass.AttribData.cAge of
         0..5999 :      snd := 2003;
         6000..11900 :  snd := 2005;
         else           snd := 2001;
      end;
      if not BasicData.Feature.rboman then snd := snd + 200;

      SetWordString (SubData.SayString, IntToStr (snd) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;

   if aFeatureState = wfs_running then begin
      if HaveMagicClass.pCurRunningMagic <> nil then begin
         if HaveMagicClass.pCurRunningMagic^.rcSkillLevel > 8500 then aFeatureState := wfs_running2;
      end;
   end;

   WearItemClass.SetFeatureState (aFeatureState);
   BasicData.Feature := WearItemClass.GetFeature;

   BasicData.Feature.rTeamColor := 0;
   case aFeatureState of
      wfs_running,
      wfs_running2:
         begin
            if HaveMagicClass.pCurRunningMagic <> nil then begin
               if HaveMagicClass.pCurRunningMagic^.rcSkillLevel > 5000 then
                  BasicData.Feature.rTeamColor := 4;
            end;
         end;
      wfs_sitdown:
         begin
            if HaveMagicClass.pCurBreathngMagic <> nil then
               BasicData.Feature.rTeamColor := HaveMagicClass.pCurBreathngMagic^.rcSkillLevel div 1000;   //aaa
         end;
   end;
   
   SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
   AttribClass.FeatureState := BasicData.Feature.rfeaturestate;
end;

function   TUserObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   str : string;
   ret, percent : integer;
//   xx, yy: word;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   case Msg of
      FM_CLICK :
         begin
            if hfu = BasicData.id then begin
               str := '';
               str := str + '名称: ' + Name + #13;
               if GuildName <> '' then str := str + '门派名称: ' + GuildName + '  ' + '门派职位: ' + GuildGrade + #13;
               str := str + '使用武功: ' + HaveMagicClass.GetUsedMagicList;
               SetWordString (aSubData.SayString, str);
            end;
         end;
      FM_DEADHIT :
         begin
            if SenderInfo.id = BasicData.id then exit;
            if BasicData.Feature.rfeaturestate = wfs_die then begin Result := PROC_TRUE; exit; end;
            if aSubData.TargetId <> 0 then begin Result := PROC_TRUE; exit; end;
            AttribClass.CurLife := 0;
            CommandChangeCharState (wfs_die, FALSE);
         end;
      FM_HIT :
         begin
            if BasicData.Feature.rfeaturestate = wfs_die then begin Result := PROC_TRUE; exit; end;

            if isHitedArea (SenderInfo.dir, SenderInfo.x, SenderInfo.y, aSubData.HitData.HitFunction, percent) then begin
               if (TUser (Self).SysopScope = 101) or (BasicData.Feature.rHideState = hs_0) then begin
               end else begin
                  ret := CommandHited (SenderInfo.id, aSubData.HitData, percent);
                  if (ret <> 0) and (AttribClass.CurLife = 0) then CommandChangeCharState (wfs_die, FALSE);
                  if ret <> 0 then begin
                     aSubData.HitData.boHited := TRUE;
                     aSubData.HitData.HitedCount := aSubData.HitData.HitedCount +1;
                  end;
               end;
            end;
{
            xx := SenderInfo.x; yy := SenderInfo.y;
            GetNextPosition (SenderInfo.dir, xx, yy);
            if (BasicData.x = xx) and (BasicData.y = yy) then begin
               ret := CommandHited (SenderInfo.id, aSubData.HitData);
               if (ret <> 0) and (AttribClass.CurLife = 0) then CommandChangeCharState (wfs_die, FALSE);
               if ret <> 0 then aSubData.HitData.boHited := TRUE;
            end;
}
         end;
      FM_BOW :
         begin
            if BasicData.Feature.rfeaturestate = wfs_die then begin Result := PROC_TRUE; exit; end;
            if aSubData.TargetId = Basicdata.id then begin
               if (TUser (Self).SysopScope = 101) or (BasicData.Feature.rHideState = hs_0) then begin
               end else begin
                  ret := CommandHited (SenderInfo.id, aSubData.HitData, 100);
                  if (ret <> 0) and (AttribClass.CurLife = 0) then CommandChangeCharState (wfs_die, FALSE);
               end;
            end;
         end;
      FM_CHANGEFEATURE :
         begin
            if SenderInfo.id = BasicData.id then begin
               if State <> wfs_care then SetTargetId (0);
               if State <> wfs_sitdown then HaveMagicClass.SetBreathngMagic (nil);
               if (State <> wfs_running) and (state <> wfs_running2) then HaveMagicClass.SetRunningMagic (nil);
            end;
            if Senderinfo.Feature.rfeaturestate = wfs_die then begin
               if Senderinfo.id = TargetId then SetTargetId (0);
            end;
         end;
   end;
end;

procedure TUserObject.Update (CurTick: integer);
var
   ret : integer;
   key : word;
   Bo : TBasicObject;
   GotoXyRData : TGotoXyRData; // ract, rdir, rlen : word;

   x1, y1, x2, y2: word;
   nX, nY : Integer;
   SubData : TSubData;
begin
   inherited UpDate (CurTick);

   AttribClass.Update (Curtick);

   ret := HaveMagicClass.Update (CurTick);
   case ret of
      RET_CLOSE_NONE:;
      RET_CLOSE_RUNNING:
         begin
            CommandChangeCharState (wfs_normal, FALSE);
            HaveMagicClass.SetRunningMagic(nil);
         end;
      RET_CLOSE_BREATHNG:
         begin
            CommandChangeCharState (wfs_normal, FALSE);
            HaveMagicClass.SetBreathngMagic(nil);
         end;
      RET_CLOSE_ATTACK :
         begin
         end;
      RET_CLOSE_PROTECTING :
         begin
            HaveMagicClass.SetProtectingMagic(nil);
         end;
   end;

   HaveItemClass.Update (CurTick);
   WearItemClass.Update (CurTick);

   if (BasicData.Feature.rFeatureState = wfs_die) and (CurTick > DiedTick + 3000) then begin
      if Manager.boPosDie = true then begin
         CommandChangeCharState (wfs_normal, FALSE);
         
         TUser(Self).boNewServer := true;
         x1 := BasicData.x;
         y1 := BasicData.y;
         PosByDieClass.GetPosByDieData (Manager.ServerID, ServerID, x1, y1);
         TUser(Self).SetPosition (x1, y1);
         exit;
      end;
      nX := BasicData.x;
      nY := BasicData.y;

      if Maper.isMoveable (nX, nY) = false then begin
         if Maper.GetNearXy (nX, nY) = false then begin
            frmMain.WriteLogInfo (format ('TUserObject.Update() GetMoveableXY Error (%s, %d, %d, %d)', [Name, ServerID, nX, nY]));
            exit;
         end;
         CommandChangeCharState (wfs_normal, FALSE);
         TUser(Self).SetPosition (nX, nY);
      end else begin
         BasicData.X := nX;
         BasicData.Y := nY;
         CommandChangeCharState (wfs_normal, FALSE);
         Maper.MapProc (BasicData.Id, MM_SHOW, BasicData.x, BasicData.y, BasicData.x, BasicData.y, BasicData);
      end;
      exit;
      {
      if Maper.isMoveable (nX, nY) then begin
         Maper.MapProc (BasicData.Id, MM_SHOW, BasicData.x, BasicData.y, BasicData.x, BasicData.y);
         CommandChangeCharState (wfs_normal, FALSE);
      end else begin
         if Maper.GetNearXy (nX, nY) then begin
            CommandChangeCharState (wfs_normal, FALSE);
            Phone.SendMessage (NOTARGETPHONE, FM_DESTROY, BasicData, SubData);
            Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);
            BasicData.x := nX; BasicData.y := nY;
            SendClass.SendMap (BasicData, Manager.MapName, Manager.ObjName, Manager.RofName, Manager.TilName, Manager.SoundBase);
            Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
            Phone.SendMessage (NOTARGETPHONE, FM_CREATE, BasicData, SubData);
         end;
      end;
      }
   end;
   if (BasicData.Feature.rFeatureState = wfs_die) and (CurTick < DiedTick + 3000) then begin
      if (RopeTarget <> 0) and (RopeTick + 500 > CurTick) then begin
         bo := TBasicObject (GetViewObjectById (RopeTarget));
         if bo = nil then exit;
         x1 := BasicData.x;
         y1 := BasicData.y;
         x2 := bo.Posx;
         y2 := bo.Posy;

         if AI0GotoXy (GotoXyRData, BasicData.dir, x1, y1, x2, y2, RopeOldX, RopeOldY, Maper.isMoveable) then begin

            case GotoXyRData.ract of
               AI_CLEAROLDPOS : begin RopeOldX := 0; RopeOldY := 0; end;
               AI_TURN        :
                  begin
                     BasicData.dir := GotoXyRData.rdir;
                     SendLocalMessage (NOTARGETPHONE, FM_TURN, BasicData, SubData);
                     SendClass.SendTurn (BasicData);
                  end;
               AI_MOVE        :
                  begin
                     x1 := BasicData.x; y1 := BasicData.y;
                     GetNextPosition (GotoXyRData.rdir, x1, y1);
                     if Maper.isMoveable ( x1, y1) then begin
                        RopeOldX := BasicData.x;
                        RopeOldy := BasicData.y;
                        BasicData.dir := GotoXyRData.rdir;
                        BasicData.nx := x1;
                        BasicData.ny := y1;
                        Phone.SendMessage ( NOTARGETPHONE, FM_MOVE, BasicData, SubData);

                        SendClass.SendMove (BasicData); // 郴啊 杭荐 乐澜.

                        Maper.MapProc (BasicData.Id, MM_MOVE, BasicData.x, BasicData.y, x1, y1, BasicData);
                        BasicData.x := x1; BasicData.y := y1;
                     end;
                  end;
            end;
         end;
      end;
   end;

   Case LifeObjectState of
      los_none:
         begin
            if boShiftAttack = FALSE then begin boShiftAttack := TRUE; SendClass.SendShiftAttack (boShiftAttack); end;
         end;
      los_die :
         begin
            if boShiftAttack = FALSE then begin boShiftAttack := TRUE; SendClass.SendShiftAttack (boShiftAttack); end;
         end;
      los_attack:
         begin
            bo := TBasicObject (GetViewObjectById (TargetId));
            if bo = nil then LifeObjectState := los_none
            else begin
               if HaveMagicClass.pCurAttackMagic = nil then exit;
               case HaveMagicClass.pCurAttackMagic^.rMagicType of
                  MAGICTYPE_BOWING, MAGICTYPE_THROWING :
                     begin
                        if boShiftAttack = FALSE then begin boShiftAttack := TRUE; SendClass.SendShiftAttack (boShiftAttack); end;
                       CommandBowing (CurTick, TargetId, bo.Posx, bo.Posy, TRUE);
                     end;
                  else begin
                     if GetLargeLength (BasicData.X, BasicData.Y, bo.PosX, bo.PosY) = 1 then begin
                        key := GetNextDirection (BasicData.X, BasicData.Y, bo.PosX, bo.PosY);
                        if key = DR_DONTMOVE then exit;   // 困率捞 0 老锭狼 版快牢单 困率捞 1烙..
                        if key <> BasicData.dir then CommandTurn (key, TRUE);
                        if CommandHit (CurTick, TRUE) then begin
                           if boShiftAttack = TRUE then begin boShiftAttack := FALSE; SendClass.SendShiftAttack (boShiftAttack); end;
                        end;
                     end else begin
                        if boShiftAttack = FALSE then begin boShiftAttack := TRUE; SendClass.SendShiftAttack (boShiftAttack); end;
                     end;
                  end;
               end;
            end;
         end;
   end;

   if AttribClass.ReQuestPlaySoundNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (AttribClass.RequestPlaySoundNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      AttribClass.ReQuestPlaySoundNumber := 0;
   end;
   if HaveMagicClass.ReQuestPlaySoundNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (HaveMagicClass.RequestPlaySoundNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      HaveMagicClass.ReQuestPlaySoundNumber := 0;
   end;
   if HaveItemClass.ReQuestPlaySoundNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (HaveItemClass.RequestPlaySoundNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      HaveItemClass.ReQuestPlaySoundNumber := 0;
   end;
   if WearItemClass.ReQuestPlaySoundNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (WearItemClass.RequestPlaySoundNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      WearItemClass.ReQuestPlaySoundNumber := 0;
   end;
end;

procedure TUserObject.Initial (aName: String);
begin
   inherited Initial (aName, aName);

   Name := aName;
   IP := Connector.IpAddr;

   SendClass.SetName (Name);
   SendClass.SetConnector (Connector);

   AttribClass.LoadFromSdb (@Connector.CharData);
   HaveMagicClass.LoadFromSdb (@Connector.CharData);
   HaveItemClass.LoadFromSdb (@Connector.CharData);
   WearItemClass.LoadFromSdb (@Connector.CharData);
end;

function TUserObject.FindHaveMagicByName (aMagicName : String) : Integer;
begin
   Result := HaveMagicClass.FindHaveMagicByName (aMagicName);
end;

function TUserObject.DeleteItem (aItemData: PTItemData): Boolean;
begin
   Result := HaveItemClass.DeleteItem (aItemData);
end;

function TUserObject.FindItem (aItemData : PTItemData): Boolean;
begin
   Result := HaveItemClass.FindItem (aItemData);
end;

function TUserObject.AddMagic  (aMagicData: PTMagicData): Boolean;
begin
   Result := HaveMagicClass.AddMagic (aMagicData);
end;

////////////////////////////////////////////////////
//
//             ===  User  ===
//
////////////////////////////////////////////////////

constructor TUser.Create;
begin
   inherited Create;

   MailBox := TList.Create;
   RefuseReceiver := TStringList.Create;
   MailSender := TStringList.Create;

   MacroChecker := TMacroChecker.Create (6);
   
   boException := false;

   SysopObj := nil;
   UserObj := nil;

   boCanSay := true;
   boCanMove := true;
   boCanAttack := true;
end;

destructor TUser.Destroy;
var
   i : Integer;
   pd : PTLetterData;   
begin
   for i := 0 to MailBox.Count - 1 do begin
      pd := MailBox.Items[i];
      if pd <> nil then Dispose (pd);
   end;
   MailBox.Free;
   RefuseReceiver.Free;
   MailSender.Free;

   MacroChecker.Free;
   
   inherited destroy;
end;

procedure TUser.LoadUserData (aName: string);
var
   flag : Boolean;
   i, xx, yy: integer;
begin
   StrPCopy (@Basicdata.Name, aName);

   ServerID := Connector.CharData.ServerId;
   xx := Connector.CharData.X;
   yy := Connector.CharData.Y;

   Maper.GetMoveableXy (xx, yy, 10);
   if Maper.IsMoveable (xx, yy) = false then begin
      xx := Maper.Width div 2;
      yy := Maper.Height div 2;
      Maper.GetMoveableXy (xx, yy, 10);
   end;

   BasicData.x := xx;
   BasicData.y := yy;
   BasicData.dir := DR_4;
   GuildName := StrPas (@Connector.CharData.Guild);
   GuildGrade := '';

   StrPCopy (@Connector.CharData.LastDate, DateToStr (Date));
   boNewServer := FALSE;
end;

procedure TUser.SaveUserData (aName: string);
begin
   Connector.CharData.ServerID := ServerID;
   StrPCopy (@Connector.CharData.Guild, GuildName);
   if (not boNewServer) and (Connector.BattleState = bcs_none) then begin
      Connector.CharData.X := BasicData.x;
      Connector.CharData.Y := BasicData.Y;
   end else begin
      Connector.CharData.X := PosMoveX;
      Connector.CharData.Y := PosMoveY;
   end;
end;

function  TUser.InitialLayer (aCharName: string): Boolean;
begin
   Result := false;

   PrisonTick := mmAnsTick;
   SaveTick := mmAnsTick;
   FalseTick := 0;
   MailTick := mmAnsTick - 10 * 100;
   Name := aCharName;

   Result := true;
end;

procedure TUser.Initial (aName: string);
begin
   inherited Initial (aName);

   FillChar (ExchangeData, SizeOf (TExchangeData), 0);

   InputStringState := InputStringState_None;
   
   boTV := false;
   boException := false;
   boLetterCheck := true;

   boCanSay := true;
   boCanMove := true;
   boCanAttack := true;

   UseSkillKind := -1;
   SkillUsedTick := 0;
   SkillUsedMaxTick := 0;

   LoadUserData (aName);
   FillChar (CM_MessageTick, sizeof(CM_MessageTick), 0);

   SysopScope := Sysopclass.GetSysopScope (aName);

   if SysopScope >= 100 then SysopScope := 101;

   SpecialWindow := 0;
   CopyHaveItem := nil;

   NetStateID := 0;
   NetStateTick := 0;
   FillChar (SaveNetState, SizeOf (TCNetState), 0);

   FillChar (ItemLogData, SizeOf (TItemLogRecord) * 4, 0);
end;

procedure TUser.StartProcess;
var
   SubData : TSubData;
   boAlertFlag : Boolean;
   tmpGuildName : String;
   tmpManager : TManager;
   rStr : String;
   // timestr, msgstr : String;
begin
   PosMoveX := -1;
   PosMoveY := -1;
   
   inherited StartProcess;
   boTv := FALSE;

   boAlertFlag := FALSE;
   if GuildName <> '' then begin
      if GuildList.CheckGuildUser (GuildName, Name) = true then begin
         GuildServerID := GuildList.GetGuildServerID (GuildName);
         StrPCopy (@BasicData.Guild, GuildName);
         GuildGrade := GuildList.GetUserGrade (GuildName, Name);
         UserList.GuildSay (GuildName, format ('%s(%s)连线了.', [Name, GuildGrade]) );
      end else begin
         tmpGuildName := GuildName;
         GuildName := '';
         GuildGrade := '';
         StrPCopy(@BasicData.Guild, '');
         boAlertFlag := TRUE;
      end;
   end;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (NOTARGETPHONE, FM_CREATE, BasicData, SubData);

   if boAlertFlag = TRUE then begin
      SendClass.SendChatMessage (tmpGuildName + '你已经脱离门派了.', SAY_COLOR_NORMAL);
   end;

   if Manager.boPrison = true then begin
      rStr := PrisonClass.GetUserStatus (Name);
      if rStr <> '' then begin
         SendClass.SendChatMessage ('被囚禁于流配地.', SAY_COLOR_NORMAL);
         SendClass.SendChatMessage ('请输入 [@囚禁情报] 来查询囚禁时间.', SAY_COLOR_NORMAL);
         SendClass.SendChatMessage (rStr, SAY_COLOR_NORMAL);
      end;
   end;

   LetterManager.CheckLetter (StrPas(@BasicData.Name), MailBox);
   RefuseReceiver.Clear;
   MailSender.Clear;

//   rStr := '救崇窍技夸. 玫斥涝聪促.' + #13;
//   rStr := rStr + '捞锅 滚傈狼 函版荤亲俊 包茄 傍瘤涝聪促' + #13;
//   rStr := rStr + '' + #13;
//   rStr := rStr + ' 1. 努腐,歹喉努腐栏肺 酒捞袍 裙垫捞 啊瓷钦聪促' + #13;
//   rStr := rStr + ' 2. 公傍函版矫 秦寸公扁啊 磊悼栏肺 馒侩邓聪促' + #13;
//   rStr := rStr + '' + #13;
//   rStr := rStr + '歹 磊技茄 郴侩篮 权其捞瘤甫 曼绊窍技夸' + #13;
//   rStr := rStr + '坷疵 窍风档 榴玫窍技夸' + #13;

//   SendClass.SendShowSpecialWindow (WINDOW_ALERT, '玫斥 傍瘤荤亲', rStr);
end;

procedure TUser.EndProcess;
var
   i : Integer;
   BasicObject : TBasicObject;
   SubData : TSubData;
begin
   if FboRegisted = FALSE then exit;

   if boTV = true then begin
      MirrorList.DelViewer (Self);
      boTV := false;
   end;

   if GuildName <> '' then begin
      UserList.GuildSay (GuildName, format ('%s(%s)离线了.', [Name, GuildGrade]));
   end;

   Phone.SendMessage (NOTARGETPHONE, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   SaveUserData (Name);
   inherited EndProcess;
end;

procedure TUser.FinalLayer;
begin
   if UserObj <> nil then begin
      TUser(UserObj).SysopObj := nil;
      UserObj := nil;
   end;
   if SysopObj <> nil then begin
      TUser(SysopObj).SendClass.SendChatMessage ('解除连线.', SAY_COLOR_SYSTEM);
      TUser(SysopObj).UserObj := nil;
      SysopObj := nil;
   end;

   if CopyHaveItem <> nil then begin
      CopyHaveItem.Free;
      CopyHaveItem := nil;
   end;
end;

function TUserList.GetGuildUserInfo (aGuildName: string): string;
var
   i, n : integer;
   str : string;
   TempUser: TUser;
begin
   str := ''; n := 0;
   for i := 0 to DataList.Count -1 do begin
      TempUser := DataList.Items [i];
      if TempUser.GuildName <> aGuildName then continue;
      str := str + TempUser.Name + '  ';
      if (n <> 0) and (n mod 8 = 0) then str := str + #13;
      n := n + 1;
   end;
   Result := '现在使用者 : ' + IntToStr(n) + #13 + str;
end;

procedure TUser.UserSay (astr: string);
var
   i, j, k, xx, yy, ret, n, scolor: integer;
   nByte : Byte;
   TempUser : TUser;
   Bo : TBasicObject;
   tempdir : word;
   templength : integer;
   ItemData : TItemData;
   RetStr, Str, searchstr, msgstr, timestr : string;
   strs : array [0..15] of string;
   tmpBasicData : TBasicData;
   SubData : TSubData;
   tmpManager : TManager;
   GuildMagicWindow : TSShowGuildMagicWindow;
   GuildObject : TGuildObject;
   LimitStr : String;
begin
   if astr = '' then exit;

   LimitStr := Copy (aStr, 1, 88);
   aStr := LimitStr;

   str := astr;
   for i := 0 to 15 do begin
      str := GetValidStr3 (str, strs[i], ' ');
      if str = '' then break;
   end;

   case astr[1] of
      '/' :
         begin
            if Strs[0] = INI_WHO then begin
               SetWordString (SubData.SayString, aStr);
               Phone.SendMessage (MANAGERPHONE, FM_CURRENTUSER, BasicData, SubData);
               SendClass.SendChatMessage (GetWordString(SubData.SayString), SAY_COLOR_SYSTEM);
               if GuildName <> '' then begin
                  GuildList.GetGuildInfo (GuildName, Self);
                  str := UserList.GetGuildUserInfo (GuildName);
                  SendClass.SendChatMessage (str, SAY_COLOR_NORMAL);
               end;
            end else if (UpperCase(strs[0]) = '/WHERE') or (UpperCase(strs[0]) = '/哪里') then begin
               nByte := Maper.GetAreaIndex (BasicData.X, BasicData.Y);
               if nByte > 0 then begin
                  searchstr := AreaClass.GetAreaName (nByte);
                  if searchstr = '' then searchstr := Manager.Title;
               end else begin
                  searchstr := Manager.Title;
               end;
               str := '这里是' + searchstr + '.';
               SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
            end;
         end;
      '#' :
         begin
            if Strs[0] = '#' then begin
               if (SysopScope > 50) and (Length(astr) > 4) then begin
                  UserList.SendNoticeMessage ('<SYSTEM>: '+Copy (astr, 2, Length(astr)), SAY_COLOR_NOTICE);
                  exit;
               end;
            end;
         end;
      '@' :
         begin
            if SysopScope > 99 then begin
               if Strs [0] = '@速度确认' then begin
                  if boCheckSpeed = false then begin
                     Str := '开始检查速度';
                     boCheckSpeed := true;
                  end else begin
                     Str := '结束检查速度';
                     boCheckSpeed := false;
                  end;
                  SendClass.SendChatMessage (Str, SAY_COLOR_SYSTEM);
                  exit;
               end;
               if Strs [0] = '@角色信息' then begin
                  if Strs [1] <> '' then begin
                     Str := GuildList.GetCharInformation (Strs [1]);
                     if Str <> '' then begin
                        SendClass.SendChatMessage (Str, SAY_COLOR_SYSTEM);
                     end;
                  end;
                  exit;
               end;
               if Strs [0] = '@门派信息' then begin
                  if Strs [1] <> '' then begin
                     Str := GuildList.GetInformation (Strs [1]);
                     if Str <> '' then begin
                        SendClass.SendChatMessage (Str, SAY_COLOR_SYSTEM);
                     end;
                  end;
                  exit;
               end;

               // 措访辑滚侩 抛胶飘 疙飞绢
               if Strs [0] = '@参加对战' then begin
                  SetPositionBS (BasicData.X, BasicData.Y);
                  exit;
               end;
               if UpperCase (Strs [0]) = '@荐访悼沥焊' then begin
                  SendClass.SendChatMessage (ObjectChecker.GetCurInfo, SAY_COLOR_SYSTEM);
                  exit;
               end;
               if UpperCase (Strs [0]) = '@REGENMAP' then begin
                  n := Manager.RegenInterval;
                  Manager.RegenInterval := 1;
                  Manager.Update (mmAnsTick);
                  Manager.RegenInterval := n;
                  exit;
               end;
               if UpperCase (Strs [0]) = '@召唤怪兽' then begin
                  if Strs [1] <> '' then begin
                     TMonsterList (Manager.MonsterList).ComeOn (Strs [i], BasicData.X, BasicData.Y);
                  end;
                  exit;
               end;
               if UpperCase (Strs [0]) = '@整理物品' then begin
                  HaveItemClass.DeleteAllItem;
                  exit;
               end;
               if UpperCase (strs[0]) = '@使用者情报' then begin
                  if Strs[1] = '' then begin
                     UserList.SaveUserInfo ('.\LOG\USERINFO.SDB');
                     SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                     TempUser := UserList.GetUserPointer (Strs[1]);
                     if TempUser <> nil then begin
                        RetStr := TempUser.Name + ': IP(' + TempUser.Connector.IpAddr + ') Ver(' + IntToStr (TempUser.Connector.VerNo) + ')'; 
                        SendClass.SendChatMessage (RetStr, SAY_COLOR_SYSTEM);
                     end else begin
                        SendClass.SendChatMessage (format ('%s目前不在线上.', [Strs[1]]), SAY_COLOR_SYSTEM);
                     end;
                  end;
                  exit;
               end;
               if UpperCase (strs[0]) = '@SHOWME' then begin
                  for i := 0 to ViewObjectList.Count - 1 do begin
                     Bo := ViewObjectList.Items [i];
                     SendClass.SendChatMessage (StrPas (@Bo.BasicData.Name) + '(' + IntToStr (Bo.BasicData.X) + ',' + IntToStr (Bo.BasicData.Y) + ')', SAY_COLOR_SYSTEM);
                  end;
                  SendClass.SendChatMessage (format ('开启了%d个.', [ViewObjectList.Count]), SAY_COLOR_SYSTEM);
                  exit;
               end;
               if UpperCase (strs[0]) = '@储存保管窗' then begin
                  ItemLog.SaveToSDB ('.\ITEMLOG\ITEMLOG.SDB');
                  SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if UpperCase (strs[0]) = '@开关保管窗' then begin
                  if ItemLog.Enabled = true then begin
                     ItemLog.Enabled := false;
                     SendClass.SendChatMessage ('保管窗被停止使用.', SAY_COLOR_SYSTEM);
                  end else begin
                     ItemLog.Enabled := true;
                     SendClass.SendChatMessage ('保管窗被开启使用.', SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase(strs[0]) = '@DAMAGE' then begin
                  boShowHitedValue := not boShowHitedValue;
                  exit;
               end;
               if UpperCase(strs[0]) = '@GUILDDAMAGE' then begin
                  boShowGuildDuraValue := not boShowGuildDuraValue;
                  exit;
               end;
               if UpperCase (strs[0]) = '@NOHIT' then begin
                  SysopScope := 101;
                  exit;
               end;
               if UpperCase (strs[0]) = '@HIT' then begin
                  SysopScope := 100;
                  exit;
               end;

               if UpperCase(strs[0]) = '@CALLGUILD' then begin
                  if GuildList.MoveStone (Strs[1], Manager.ServerID, BasicData.x, BasicData.y) = true then begin
                     SendClass.SendChatMessage ('已移动门派石.', SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase(strs[0]) = '@CREATEGUILD' then begin
                  if GuildList.CreateStone (Strs[1], '', Manager.ServerID, BasicData.x, BasicData.y) = true then begin
                     SendClass.SendChatMessage ('已创建门派石.', SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;

               {
               if UpperCase(strs[0]) = '@READ' then begin
                  SysopClass.ReLoadFromFile;
                  ItemClass.ReLoadFromFile;
                  MonsterClass.ReLoadFromFile;
                  NpcClass.ReLoadFromFile;
                  ManagerList.ReLoadFromFile;
                  exit;
               end;
               }

               // 泅犁 付阑狼 漂沥 谅钎肺 捞悼茄促
               if UpperCase(strs[0]) = '@MOVE' then begin
                  xx := _StrToInt (Strs[1]);
                  yy := _StrToInt (Strs[2]);
                  if Maper.isMoveable (xx, yy) then begin
                     PosMoveX := xx;
                     PosMoveY := yy;
                  end;
                  exit;
               end;

               // 货肺款 付阑狼 漂沥 谅钎肺 捞悼茄促
               if UpperCase(strs[0]) = '@MOVEEX' then begin
                  xx := _StrToInt (Strs[2]);
                  yy := _StrToInt (Strs[3]);

                  tmpManager := ManagerList.GetManagerByTitle (Strs[1]);
                  if tmpManager <> nil then begin
                     if tmpManager.ServerID <> ServerID then begin
                        boNewServer := TRUE;
                        ServerID := tmpManager.ServerID;
                     end;
                     PosMoveX := xx;
                     PosMoveY := yy;
                  end;
                  exit;
               end;

               // 林函 葛电 阁胶磐客 NPC 甫 力芭窃
               if UpperCase(Strs[0]) = '@KILLALL' then begin
                  SubData.TargetId := 0;
                  if UpperCase(Strs[1]) = 'MOP' then begin
                     SubData.TargetId := 1;
                  end; 
                  ShowEffect (4, lek_none);
                  SendLocalMessage (NOTARGETPHONE, FM_DEADHIT, BasicData, SubData);
                  exit;
               end;

               // NPC 家券
               if UpperCase(Strs[0]) = '@CALLNPC' then begin
                  Bo := TNpcList(Manager.NpcList).GetNpcByName (Strs[1]);
                  if Bo <> nil then begin
                     for k := 0 to 10 - 1 do begin
                        xx := BasicData.X - 2 + Random(4);
                        yy := BasicData.Y - 2 + Random(4);
                        if Maper.isMoveable (xx, yy) then begin
                           TNpc(Bo).CallMe (xx, yy);
                           break;
                        end;
                     end;
                  end;
                  exit;
               end;
               // 阁胶磐 家券
               if UpperCase(Strs[0]) = '@CALLMOP' then begin
                  Bo := TBasicObject(TMonsterList(Manager.MonsterList).GetMonsterByName (Strs[1]));
                  if Bo <> nil then begin
                     for k := 0 to 10 - 1 do begin
                        xx := BasicData.X - 2 + Random(4);
                        yy := BasicData.Y - 2 + Random(4);
                        if Maper.isMoveable (xx, yy) then begin
                           TMonster(Bo).CallMe (xx, yy);
                           break;
                        end;
                     end;
                  end;
                  exit;
               end;
               // NPC 免滴
               if UpperCase(Strs[0]) = '@APPEARNPC' then begin
                  Bo := TNpcList(Manager.NpcList).GetNpcByName (Strs[1]);
                  if Bo <> nil then begin
                     PosMoveX := BO.BasicData.x;
                     PosMoveY := BO.BasicData.y;
                  end;
                  exit;
               end;
               // 阁胶磐 免滴
               if UpperCase(Strs[0]) = '@APPEARMOP' then begin
                  Bo := TBasicObject(TMonsterList(Manager.MonsterList).GetMonsterByName (Strs[1]));
                  if Bo <> nil then begin
                     PosMoveX := BO.BasicData.x;
                     PosMoveY := BO.BasicData.y;
                  end;
                  exit;
               end;

               if UpperCase(Strs[0]) = '@SHOW' then begin
                  if Strs[1] = '' then exit;
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser <> nil then begin
                     if TempUser.SysopObj = nil then begin
                        if UserObj <> nil then begin
                           TUser(UserObj).SysopObj := nil;
                        end;
                        UserObj := TempUser;
                        TempUser.SysopObj := Self;
                        if not boTv then begin
                           boTv := TRUE;
                        end;
                        SendClass.SendMap (TempUser.BasicData, TempUser.Manager.MapName, TempUser.Manager.ObjName, TempUser.Manager.RofName, TempUser.Manager.TilName, Manager.SoundBase);
                        for i := 0 to TempUser.ViewObjectList.Count -1 do
                           SendClass.SendShow (TBasicObject (TempUser.ViewObjectList[i]).BasicData);
                     end;
                  end;
                  exit;
               end;

               // 荤侩磊狼 立加阑 秦力 矫挪促
               if (UpperCase(Strs[0]) = '@BAN') or (UpperCase(Strs[0]) = '@BANEX') then begin
                  if Strs[1] <> '' then begin
                     msgstr := Copy(astr, Pos(Strs[1], astr) + Length(Strs[1]), Length(astr));
                     TempUser := UserList.GetUserPointer (Strs[1]);
                     if TempUser = nil then begin
                        SendClass.SendChatMessage (format ('%s目前不在线上.',[Strs[1]]), SAY_COLOR_SYSTEM);
                     end else begin
                        if UpperCase(Strs[0]) = '@BAN' then
                           TempUser.SendClass.SendChatMessage('角色已被管理员强制断线.', SAY_COLOR_SYSTEM);
                        if msgstr <> '' then begin
                           msgstr := '千年:' + msgstr;
                           TempUser.SendClass.SendChatMessage(msgstr, SAY_COLOR_NORMAL);
                        end;
                        ConnectorList.CloseConnectByCharName(StrPas(@TempUser.BasicData.Name));

                        SendClass.SendChatMessage (format ('%s将在10秒后断线.',[Strs[1]]), SAY_COLOR_SYSTEM);
                     end;
                  end;
               end;
               if UpperCase (strs[0]) = '@删除门派' then begin
                  GuildList.DeleteStone (Strs [i]);
                  exit;
               end;

               if UpperCase(strs[0]) = '@禁言' then begin
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser = nil then begin
                     SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     TempUser.boCanSay := not TempUser.boCanSay;
                  end;
               end;
               if UpperCase(strs[0]) = '@禁移' then begin
                  tempUser := UserList.GetUserPointer (Strs[1]);
                  if tempUser <> nil then begin
                     Case tempUser.WearItemClass.GetActionState of
                        as_free :
                           begin
                              tempUser.WearItemClass.SetActionState (as_ice);
                           end;
                        as_ice :
                           begin
                              tempUser.WearItemClass.SetActionState (as_free);
                           end;
                     end;
                     SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, tempUser.BasicData, SubData);
                  end else begin
                     SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end;
               end;
               if UpperCase(strs[0]) = '@剧' then begin
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser = nil then begin
                     SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     TempUser.boCanAttack := not TempUser.boCanAttack;
                  end;
               end;

               if UpperCase(strs[0]) = '@CALL' then begin
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser = nil then begin
                     SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     if TempUser.ServerID <> ServerID then begin
                        Tempuser.boNewServer := TRUE;
                        TempUser.ServerID := ServerID;
                     end;
                     TempUser.PosMoveX := BasicData.x;
                     TempUser.PosMoveY := BasicData.y;
                  end;
               end;
               if (UpperCase(Strs[0]) = '@APPEAR') or (UpperCase(Strs[0]) = '@APPEAREX') then begin
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser = nil then begin
                     SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     if TempUser.ServerID <> ServerID then begin
                        boNewServer := TRUE;
                        ServerID := TempUser.ServerID;
                     end;

                     PosMoveX := TempUser.BasicData.x;
                     PosMoveY := TempUser.BasicData.y;

                     if UpperCase(Strs[0]) = '@APPEAREX' then begin
                        PosMoveX := PosMoveX + 10;
                        PosMoveY := PosMoveY + 10;
                     end;
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@HIDEON' then begin
                  WearItemClass.SetHiddenState (hs_0);
                  SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                  exit;
               end;
               if UpperCase (Strs[0]) = '@HIDEOFF' then begin
                  WearItemClass.SetHiddenState (hs_100);
                  SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                  exit;
               end;
               if UpperCase (Strs[0]) = '@囚禁' then begin
                  msgstr := PrisonClass.AddUser (Strs[1], Strs[2], Strs[3]);
                  if msgstr = '' then begin
                     SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                     SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@释放' then begin
                  msgstr := PrisonClass.DelUser (Strs[1]);
                  if msgstr = '' then begin
                      SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                      SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@修改囚禁时间' then begin
                  msgstr := Prisonclass.UpdateUser (Strs[1], Strs[2], Strs[3]);
                  if msgstr = '' then begin
                      SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                      SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@追加囚禁时间' then begin
                  msgstr := PrisonClass.PlusUser (Strs[1], Strs[2], Strs[3]);
                  if msgstr = '' then begin
                      SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                      SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@设定囚禁时间' then begin
                  msgstr := PrisonClass.EditUser (Strs[1], Strs[2], Strs[3]);
                  if msgstr = '' then begin
                      SendClass.SendChatMessage ('处理完毕.', SAY_COLOR_SYSTEM);
                  end else begin
                      SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;
               if UpperCase (Strs[0]) = '@囚禁情报' then begin
                  if Strs[1] <> '' then begin
                     msgstr := PrisonClass.GetUserStatus (Strs[1]);
                     if msgstr <> '' then begin
                         SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
                     end;
                  end;
                  exit;
               end;
            end;
            if UpperCase (Strs[0]) = '@囚禁情报' then begin
               msgstr := Prisonclass.GetUserStatus (Name);
               if msgstr <> '' then begin
                   SendClass.SendChatMessage (msgstr, SAY_COLOR_SYSTEM);
               end;
               exit;
            end;
            if UpperCase (Strs [0]) = '@探查' then begin
            end;

            if strs[0] = INI_SERCHSKILL then begin
               if (SysopScope > 99) and (Strs[1] <> '') then begin
                  TempUser := UserList.GetUserPointer (strs[1]);
                  if TempUser = nil then begin SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM); exit; end;
                  str := format('%s在 %s的 %d,%d地方.',[Strs[1], TempUser.Manager.Title, TempUser.BasicData.X, TempUser.BasicData.Y]);
                  SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
                  exit;
               end;
               if SearchTick + 1000 > mmAnsTick then begin
                  SendClass.SendChatMessage ('请稍后再进行.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if Strs[1] = '' then begin
                  InputStringState := InputStringState_Search;
                  SendClass.SendShowInputString (InputStringState, '请输入探查对象', '角色');
                  exit;
               end;

               SearchTick := mmAnsTick;
               TempUser := UserList.GetUserPointer (strs[1]);
               if TempUser = nil then begin
                  SendClass.SendChatMessage (format ('%s不在.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  exit;
               end;
               if TempUser.SysopScope >= 100 then begin
                  SendClass.SendChatMessage ('此人是游戏管理员.无法探查.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if TempUser.ServerID <> ServerID then begin
                  SendClass.SendChatMessage (format ('%s在%s.',[Strs[1], TempUser.Manager.Title]), SAY_COLOR_SYSTEM);
                  exit;
               end;
               searchstr := '';
               TempLength := GetLargeLength (BasicData.x, BasicData.y, TempUser.PosX, TempUser.Posy);
               tempdir := GetViewDirection (BasicData.x, BasicData.y, TempUser.PosX, TempUser.Posy);
               case tempdir of
                  0 : searchstr := INI_NORTH;
                  1 : searchstr := INI_NORTHEAST;
                  2 : searchstr := INI_EAST;
                  3 : searchstr := INI_EASTSOUTH;
                  4 : searchstr := INI_SOUTH;
                  5 : searchstr := INI_SOUTHWEST;
                  6 : searchstr := INI_WEST;
                  7 : searchstr := INI_WESTNORTH;
               end;

               if TempLength < 30 then searchstr := format ('在%s里.',[searchstr])
               else searchstr := format ('%s在远处.',[searchstr]);
               SendClass.SendChatMessage (searchstr, SAY_COLOR_SYSTEM);
            end;

            if strs[0] = '@武功删除' then begin
               if Strs [1] <> '' then begin
                  for i := 0 to NameStringListForDeleteMagic.Count -1 do begin
                     if Name = NameStringListForDeleteMagic[i] then begin
                        SendClass.SendChatMessage ('今天已删除过武功.', SAY_COLOR_SYSTEM);
                        SendClass.SendChatMessage ('每天只可删除一次.', SAY_COLOR_SYSTEM);
                        exit;
                     end;
                  end;
                  ret := HaveMagicClass.GetMagicIndex(Strs[1]);
                  if ret <> -1 then begin
                     if HaveMagicClass.DeleteMagic (ret) then begin
                        SendClass.SendChatMessage (Strs[1] + ' 武功已被删除.', SAY_COLOR_SYSTEM);
                        NameStringListForDeleteMagic.Add (Name);
                     end else SendClass.SendChatMessage ('失败了.', SAY_COLOR_SYSTEM);
                  end;
               end;
               exit;
            end;
            if strs[0] = '@观战' then begin
               if boTV = true then begin
                  MirrorList.DelViewer (Self);
                  boTV := false;
               end;
               if MirrorList.AddViewer (Strs [1], Self) = true then begin
                  boTv := true;
               end;
               exit;
            end;
            if strs[0] = '@结束观战' then begin
               if boTV = true then begin
                  MirrorList.DelViewer (Self);
                  boTV := false;
               end;
               exit;
            end;
            if Strs[0] = '@物品' then begin
               ItemClass.GetItemData (strs[1], ItemData);
               if ItemData.rName[0] = 0 then begin
                  SendClass.SendChatMessage (format ('%s 物品没有.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  exit;
               end;

               if (ItemData.rPrice = 0) or (SysopScope > 99) then begin
                  if (SysopScope > 99) and (Strs[2] <> '') then begin
                     ItemData.rCount := _StrToInt(Strs[2]);
                  end;
                  tmpBasicData.Feature.rRace := RACE_NPC;
                  StrPCopy (@tmpBasicData.Name, '物品');
                  tmpBasicData.x := BasicData.x;
                  tmpBasicData.y := BasicData.y;
                  SignToItem (ItemData, ServerID, tmpBasicData, '');
                  HaveItemClass.AddItem (@ItemData);
                  SendClass.SendChatMessage (format ('制造 %s 成功.',[Strs[1]]), SAY_COLOR_SYSTEM);
               end else begin
                  SendClass.SendChatMessage ('无法制造.', SAY_COLOR_SYSTEM);
               end;
            end;

            // 荤侩磊埃狼 率瘤 傈价 扁瓷
            if Strs[0] = '@纸条' then begin
               if Strs[1] = '' then exit;
               if Strs[1] = StrPas(@BasicData.Name) then exit;
               if Manager.boPrison = true then begin
                  SendClass.SendChatMessage ('在流配地里无法传递纸条.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if GetAge < 2000 then begin
                  SendClass.SendChatMessage ('20岁以上才可以传递纸条.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if RefuseReceiver.Count >= 5 then begin
                  SendClass.SendChatMessage (IntToStr(RefusedMailLimit) + '人以上拒绝你的纸条,所以无法再传递纸条.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               for i := 0 to RefuseReceiver.Count - 1 do begin
                  if RefuseReceiver.Strings[i] = Strs[1] then begin
                     SendClass.SendChatMessage (format('%s拒绝你的纸条.',[Strs[1]]), SAY_COLOR_SYSTEM);
                     exit;
                  end;
               end;
               TempUser := UserList.GetUserPointer (Strs[1]);
               timestr := '[' + DateToStr(Date) + ' ' + TimeToStr(Time) + ']';
               msgstr := Copy(astr, Pos(Strs[1], astr) + Length(Strs[1]), Length(astr));
               if TempUser = nil then begin
                  {
                  if LetterManager.AddLetter (StrPas(@BasicData.Name), Strs[1], msgstr) then
                     SendClass.SendChatMessage (format ('%s目前不在线上,此纸条将稍后传达.',[Strs[1]]), SAY_COLOR_SYSTEM)
                  else
                     SendClass.SendChatMessage (format ('未传达的纸条太多,所以无法处理.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  }
                  SendClass.SendChatMessage (format ('%s目前不在线上.',[Strs[1]]), SAY_COLOR_SYSTEM)
               end else begin
                  if TempUser.LetterCheck = true then begin
                     TempUser.AddMailSender (StrPas(@BasicData.Name));
                     TempUser.SendClass.SendChatMessage (format ('%s传了一个纸条给你.',[Name]), SAY_COLOR_SYSTEM);
                     TempUser.SendClass.SendChatMessage (timestr, SAY_COLOR_NORMAL);
                     TempUser.SendClass.SendChatMessage (msgstr, SAY_COLOR_NORMAL);

                     SendClass.SendChatMessage (format ('你给%s传了一个纸条.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     SendClass.SendChatMessage (format ('%s目前为拒绝纸条状态.',[Strs[1]]), SAY_COLOR_SYSTEM);
                  end;
               end;
               exit;
            end;
            if Strs[0] = '@接收纸条' then begin
               if Strs[1] = '' then begin
                  boLetterCheck := true;
                  SendClass.SendChatMessage ('设定接收纸条.', SAY_COLOR_NORMAL);
               end else begin
                  if Strs[1] = StrPas(@BasicData.Name) then exit;
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser <> nil then begin
                     TempUser.DelRefusedUser (StrPas(@BasicData.Name));
                     SendClass.SendChatMessage (format('你已设定接收%s传来的纸条.', [Strs[1]]), SAY_COLOR_SYSTEM);
                  end else begin
                     SendClass.SendChatMessage ('对方不在线上.', SAY_COLOR_SYSTEM);
                  end;
               end;
               exit;
            end;
            if Strs[0] = '@拒绝纸条' then begin
               if Strs[1] = '' then begin
                  boLetterCheck := false;
                  SendClass.SendChatMessage ('设定拒绝纸条.', SAY_COLOR_NORMAL);
               end else begin
                  if Strs[1] = StrPas(@BasicData.Name) then exit;
                  TempUser := UserList.GetUserPointer (Strs[1]);
                  if TempUser <> nil then begin
                     if CheckSenderList (Strs[1]) then begin
                        TempUser.AddRefusedUser (StrPas(@BasicData.Name));
                        SendClass.SendChatMessage (format('你已设定拒绝%s传来的纸条.', [Strs[1]]), SAY_COLOR_SYSTEM);
                     end;
                  end else begin
                     SendClass.SendChatMessage ('对方不在线上.', SAY_COLOR_SYSTEM);
                  end;
               end;
               exit;
            end;
            if UpperCase(Strs[0]) = '@CREATEGUILD' then begin
               if GuildList.CreateStone (Strs[1], StrPas (@BasicData.Name), Manager.ServerID, BasicData.x, BasicData.y) = true then begin
                  SendClass.SendChatMessage ('已移动门派石.', SAY_COLOR_SYSTEM);
               end;
               exit;
            end;

            {
            if Strs[0] = '@确认纸条' then begin
               if MailBox.Count > 0 then begin
                  pd := MailBox.Items[0];
                  if pd <> nil then begin
                     timestr := '[' + DateToStr(pd^.rDate) + ' ' + TimeToStr(pd^.rTime) + ']';
                     msgstr := StrPas(@pd^.rSayString);
                     SendClass.SendChatMessage (format ('%s传了一个纸条给你.',[StrPas(@pd^.rSender)]), SAY_COLOR_SYSTEM);
                     SendClass.SendChatMessage (timestr, SAY_COLOR_NORMAL);
                     SendClass.SendChatMessage (msgstr, SAY_COLOR_NORMAL);
                     Dispose (pd);
                  end;
                  MailBox.Delete (0);
               end;
               exit;
            end;
            if Strs[0] = '@删除纸条' then begin
               if MailBox.Count > 0 then begin
                  pd := MailBox.Items[0];
                  MailBox.Delete (0);
                  SendClass.SendChatMessage ('纸条已删除.', SAY_COLOR_SYSTEM);
               end;
               exit;
            end;
            }
            if Strs[0] = '@设定福袋密码' then begin
               RetStr := ItemLog.SetPassword (Name, Strs[1]);
               SendClass.SendChatMessage (RetStr, SAY_COLOR_SYSTEM);
               exit;
            end;
            if Strs[0] = '@解除福袋密码' then begin
               RetStr := ItemLog.FreePassword (Name, Strs[1]);
               SendClass.SendChatMessage (RetStr, SAY_COLOR_SYSTEM);
               exit;
            end;

            // 巩颇公傍 积己
            if Strs [0] = '@申请门派武功' then begin
               if GuildName = '' then begin
                  SendClass.SendChatMessage ('门主才拥有申请门派武功权力.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               if SpecialWindow <> WINDOW_NONE then begin
                  SendClass.SendChatMessage ('请关闭开启的窗口.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               GuildObject := GuildList.GetGuildObject (GuildName);
               if GuildObject <> nil then begin
                  if GuildObject.IsGuildSysop (Name) = false then exit;
                  if GuildObject.GetGuildMagicString <> '' then exit;

                  ItemClass.GetItemData ('金币', ItemData);
                  if ItemData.rName [0] = 0 then exit;
                  ItemData.rCount := 40;
                  if FindItem (@ItemData) = false then begin
                     SendClass.SendChatMessage ('申请门派武功需要40个金币.', SAY_COLOR_SYSTEM);
                     exit;
                  end;

                  FillChar (GuildMagicWindow, SizeOf (TSShowGuildMagicWindow), 0);
                  GuildMagicWindow.rMsg := SM_SHOWSPECIALWINDOW;
                  GuildMagicWindow.rWindow := WINDOW_GUILDMAGIC;
                  GuildMagicWindow.rSpeed := 50;
                  GuildMagicWindow.rDamageBody := 50;
                  GuildMagicWindow.rRecovery := 50;
                  GuildMagicWindow.rAvoid := 50;
                  GuildMagicWindow.rDamageHead := 20;
                  GuildMagicWindow.rDamageArm := 20;
                  GuildMagicWindow.rDamageLeg := 20;
                  GuildMagicWindow.rArmorBody := 48;
                  GuildMagicWindow.rArmorHead := 40;
                  GuildMagicWindow.rArmorArm := 40;
                  GuildMagicWindow.rArmorLeg := 40;
                  GuildMagicWindow.rOutPower := 20;
                  GuildMagicWindow.rInPower := 20;
                  GuildMagicWindow.rMagicPower := 20;
                  GuildMagicWindow.rLife := 20;

                  SpecialWindow := WINDOW_GUILDMAGIC;
                  SendClass.SendShowGuildMagicWindow (@GuildMagicWindow);
               end;
               exit;
            end;
            if Strs [0] = '@确认属性值' then begin
               with AttribClass.AttribData do begin
                  n := cEnergy + cMagic + cInPower + cOutPower + cLife;
                  Str := format ('基本值(%s),内功(%s),外功(%s),武功(%s),活力(%s) [%s]',
                     [Get10000To100(cEnergy), Get10000To100(cInPower), Get10000To100(cOutPower), Get10000To100(cMagic), Get10000To100(cLife), Get10000To100(n)]);
                  SendClass.SendChatMessage (Str, SAY_COLOR_SYSTEM);
               end;
               exit;
            end;
            if Strs [0] = '@战争通知' then begin
               if GuildName = '' then exit;
               msgstr := Copy(astr, Pos(Strs[0], astr) + Length(Strs[0]), Length(astr));
               GuildObject := GuildList.GetGuildObject (GuildName);
               GuildObject.SetWarAlarm (Name, msgstr);
               exit;
            end;
         end;
      '!' :
         begin
            if mmanstick < SayTick + 300 then exit;
            SayTick := mmAnsTick;
            if Length (aStr) <= 2 then exit;

            if SysopScope < 100 then begin
               if Manager.boBigSay = false then begin
                  if aStr[2] <> '!' then begin
                     SendClass.SendChatMessage ('禁止大喊的地区.', SAY_COLOR_SYSTEM);
                  end else begin
                     if Length (aStr) <= 3 then exit;
                     UserList.SayByServerID (ServerID, '{' + Name + '} : ' + Copy (astr, 3, Length(aStr) - 2));
                  end;
                  exit;
               end;
            end else begin
               if Manager.boBigSay = false then begin
                  if aStr[2] = '!' then begin
                     if Length (aStr) <= 3 then exit;
                     UserList.SayByServerID (ServerID, '{' + Name + '} : ' + Copy (astr, 3, Length(aStr) - 2));
                     exit;
                  end;
               end;
            end;

            if (astr[2] = '!') and (GuildName <> '')then begin
               if Length (astr) <= 3 then exit;
               UserList.GuildSay (GuildName, '<'+Name + '> : ' + Copy (astr,3, Length(astr)-2));
               exit;
            end;

            if Length(astr) - 1 <= 0 then exit;

            if (AttribClass.CurLife <= 5000) and (SysopScope < 100) then begin
               SendClass.SendChatMessage ('活力需要在50以上.', SAY_COLOR_SYSTEM);
               exit;
            end;

            if SysopScope < 100 then
               AttribClass.CurLife := AttribClass.CurLife - 2000;

            sColor := SAY_COLOR_GRADE0;
            with AttribClass.AttribData do n := cEnergy + cMagic + cInPower + cOutPower + cLife;
            n := (n - 5000) div 4000;
            if n < 0 then n := 0;
            if n > 11 then n := 11;
            case n of
               0..6 : sColor := SAY_COLOR_GRADE0;
               7  :   sColor := SAY_COLOR_GRADE1;
               8  : sColor := SAY_COLOR_GRADE2;
               9  : sColor := SAY_COLOR_GRADE3;
               10 : sColor := SAY_COLOR_GRADE4;
               11 : sColor := SAY_COLOR_GRADE5;
            end;

            if SysopScope >= 100 then sColor := SAY_COLOR_GRADE5;

            UserList.SendNoticeMessage ('['+Name+'] : '+Copy (astr,2, Length(astr)-1), sColor);
         end;
      else begin
         SetWordString (SubData.SayString, Name + ': ' + astr);
         SendLocalMessage (NOTARGETPHONE, FM_SAY, BasicData, SubData);
      end;
   end;
end;

procedure TUser.ExChangeStart (aId : Integer);
var
   ExChangeUser : TUser;
   BObject : TBasicObject;
   TempBasicData : TBasicData;
   SubData : TSubData;
begin
   if ExChangeData.rExChangeId <> 0 then begin
      SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
      SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, BasicData, SubData);
   end;

   BObject := TBasicObject (SendLocalMessage ( aid, FM_GIVEMEADDR, BasicData, SubData));
   if (Integer (BObject) = 0) or (integer(BObject) = -1) then exit;

   ExChangeUser := TUser (BObject);
   if ExChangeUser.ExChangeData.rExChangeId <> 0 then begin
      SendClass.SendChatMessage (StrPas (@ExChangeUser.BasicData.Name) + '对方正与其他玩家进行交易.', SAY_COLOR_SYSTEM);
      exit;
   end;

   FillChar (ExChangeData, sizeof(ExChangeData), 0);
   FillChar (ExChangeUser.ExChangeData, sizeof(ExChangeData), 0);

   ExChangeData.rExChangeId := aid;
   ExChangeData.rExChangeName := StrPas (@ExchangeUser.BasicData.Name);

   ExChangeUser.ExChangeData.rExChangeId := BasicData.id;
   ExChangeUser.ExChangeData.rExChangeName := StrPas (@BasicData.Name);

   SendLocalMessage ( ExChangeData.rExChangeId, FM_SHOWEXCHANGE, BasicData, SubData);
   TempBasicData.id := ExChangeData.rExChangeId;                                           // 巩力乐澜.
   SendLocalMessage ( BasicData.Id, FM_SHOWEXCHANGE, TempBasicData, SubData);
end;

procedure TUser.InputStringProcess (var code: TWordComData);
var
   sname, searchstr : string;
   pCInputString : PTCInputString;
   TempUser : TUser;
   tempdir, TempLength : integer;
begin
   pCInputString := @Code.Data;

   case InputStringState of
      InputStringState_None         :;
      InputStringState_AddExchange  :;
      InputStringState_Search       :  // if rSelectedList then ;;
         begin
            InputStringState := InputStringState_None;
            sname := GetWordString (pCInputString^.rInputString);

            if sname = '' then begin
               SendClass.SendChatMessage ('探查内容不存在.', SAY_COLOR_SYSTEM);
               exit;
            end;
            if SearchTick + 1000 > mmAnsTick then begin
              SendClass.SendChatMessage ('请稍后再进行.', SAY_COLOR_SYSTEM);
              exit;
            end;
            SearchTick := mmAnsTick;

            TempUser := UserList.GetUserPointer (sname);

            if TempUser = nil then begin
               SendClass.SendChatMessage (format ('%s不在.',[sname]), SAY_COLOR_SYSTEM);
               exit;
            end;
            if TempUser.SysopScope >= 100 then begin
               SendClass.SendChatMessage ('此人是游戏管理员.无法探查.', SAY_COLOR_SYSTEM);
               exit;
            end;
            if TempUser.ServerID <> ServerID then begin
               SendClass.SendChatMessage (format ('%s在%s.',[sname, TempUser.Manager.Title]), SAY_COLOR_SYSTEM);
               exit;
            end;
            searchstr := '';
            TempLength := GetLargeLength (BasicData.x, BasicData.y, TempUser.PosX, TempUser.Posy);
            tempdir := GetViewDirection (BasicData.x, BasicData.y, TempUser.PosX, TempUser.Posy);
            case tempdir of
               0 : searchstr := INI_NORTH;
               1 : searchstr := INI_NORTHEAST;
               2 : searchstr := INI_EAST;
               3 : searchstr := INI_EASTSOUTH;
               4 : searchstr := INI_SOUTH;
               5 : searchstr := INI_SOUTHWEST;
               6 : searchstr := INI_WEST;
               7 : searchstr := INI_WESTNORTH;
            end;

            if TempLength < 30 then searchstr := format ('在%s里.',[searchstr])
            else searchstr := format ('%s在远处.',[searchstr]);
            SendClass.SendChatMessage (searchstr, SAY_COLOR_SYSTEM);
         end;
   end;
end;

function TUser.isCheckExChangeData: Boolean;
var
   i, j : integer;
   bo : Boolean;
begin
   Result := TRUE;

   for j := 0 to 4-1 do begin
      bo := FALSE;
      for i := 0 to HAVEITEMSIZE-1 do begin
         if StrPas (@HaveItemClass.HaveItemArr[i].rName) = ExChangeData.rItems[j].rItemName then begin
            if HaveItemClass.HaveItemArr[i].rColor = ExChangeData.rItems[j].rColor then begin
               if HaveItemClass.HaveItemArr[i].rCount >= ExChangeData.rItems[j].rItemCount then begin
                  ExChangeData.rItems[j].rkey := i;
                  bo := TRUE;
                  break;
               end;
            end;
         end;
      end;
      if bo = FALSE then Result := FALSE;
   end;
end;

procedure TUser.SelectCount (var Code : TWordComData);
var
   i, ret : integer;
   ItemData : TItemData;
   pccount : PTCSelectCount;
   tempUser : TUser;
   TempBasicData : TBasicData;
   SubData : TSubData;
   boFlag : boolean;
begin
   pccount := @Code.data;

   if pccount^.rCount <= 0 then exit;

   if pccount^.rboOk = FALSE then begin
      CountWindowState := DRAGACTION_NONE;
      exit;
   end;

   // case CountWindowState of
   case pcCount^.rCountid of
      DRAGACTION_DROPITEM :
         begin
            if not HaveItemClass.ViewItem (pccount^.rsourkey, @ItemData) then exit;
            if pccount^.rCount <= 0 then exit;
            if Itemdata.rCount >= pccount^.rCount then begin
               SignToItem (ItemData, ServerID, BasicData, IP);
               ItemData.rCount := pccount^.rCount;
               SubData.ItemData := ItemData;
               SubData.ServerId := ServerID;
               ret := Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
               if ret = PROC_TRUE then begin
                  TempBasicData.Feature.rrace := RACE_NPC;
                  StrPCopy(@TempBasicData.Name, '地面');
                  TempBasicData.x := BasicData.x;
                  TempBasicData.y := BasicData.y;
                  SignToItem (ItemData, ServerID, TempBasicData, '');
                  HaveItemClass.DeleteKeyItem (pccount^.rsourkey, ItemData.rCount, @ItemData);
               end else begin
                  SendClass.SendChatMessage ('无法放在这个地方.', SAY_COLOR_SYSTEM);
               end;
            end;
         end;
      DRAGACTION_ADDEXCHANGEITEM :
         begin
            if not HaveItemClass.ViewItem (pccount^.rsourkey, @ItemData) then exit;

            for i := 0 to 4-1 do begin
               if StrPas (@ItemData.rName) = ExChangeData.rItems[i].rItemName then begin
                  if ItemData.rColor = ExChangeData.rItems[i].rColor then begin
                     SendClass.SendChatMessage ('已经有同样名称的物品.', 3);
                     exit;
                  end;
               end;
            end;
            ItemData.rcount := pccount^.rCount;

            TempUser := TUser (SendLocalMessage (ExChangeData.rExChangeId, FM_GIVEMEADDR, BasicData, SubData));
            if (Integer (TempUser) = 0) or (integer(TempUser) = -1) then begin
               SendClass.SendChatMessage ('交换对象不存在.', 3);
               exit;
            end;
{
            for i := 0 to HAVEITEMSIZE-1 do begin
               if StrPas (@TempUser.ItemDataArr[i].rName) = StrPas (@ItemData.rName) then begin
                  SendSystemMessage ('惑措啊 鞍篮 捞抚狼 酒捞袍捞 乐嚼聪促.', 3);
                  exit;
               end;
            end;
}

            boFlag := false;
            for i := 0 to 4-1 do begin
               if ExChangeData.rItems[i].rItemCount = 0 then begin
                  ExChangeData.rItems[i].rIcon := ItemData.rShape;
                  ExChangeData.rItems[i].rItemName := StrPas (@ItemData.rName);
                  ExChangeData.rItems[i].rItemViewName := StrPas (@ItemData.rViewName);
                  ExChangeData.rItems[i].rItemcount := pccount^.rcount;
                  ExChangeData.rItems[i].rColor := ItemData.rcolor;
                  boFlag := true;
                  break;
               end;
            end;

            if boFlag = false then begin
               SendClass.SendChatMessage ('无法再增加.', 3);
               exit;
            end;

            if isCheckExChangeData then begin
               SendLocalMessage ( ExChangeData.rExChangeId, FM_SHOWEXCHANGE, BasicData, SubData);
               TempBasicData.id := ExChangeData.rExChangeId;
               SendLocalMessage ( BasicData.Id, FM_SHOWEXCHANGE, TempBasicData, SubData);
            end else begin
               SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
               TempBasicData.id := ExChangeData.rExChangeId;
               SendLocalMessage ( BasicData.Id, FM_CANCELEXCHANGE, TempBasicData, SubData);
            end;
         end;
      DRAGACTION_FROMITEMTOLOG :
         begin
            if CopyHaveItem = nil then exit;
            if not CopyHaveItem.ViewItem (pcCount^.rsourkey, @ItemData) then exit;
            if ItemData.rCount < pcCount^.rCount then exit;

            if pcCount^.rdestkey < 10 then ret := 0
            else if pcCount^.rdestkey < 20 then ret := 1
            else if pcCount^.rdestkey < 30 then ret := 2
            else ret := 3;
            if ItemLogData[ret].Header.boUsed = false then exit;
            if ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Name[0] <> 0 then begin
               if ItemData.rboDouble = false then exit;
               if StrPas (@ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Name) <> StrPas (@ItemData.rName) then exit;
               if ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Color <> ItemData.rColor then exit;
            end;

            if CopyHaveItem.DeleteKeyItem (pcCount^.rSourKey, pcCount^.rCount, @ItemData) = false then exit;

            StrCopy (@ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Name, @ItemData.rName);
            ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Color := ItemData.rColor;
            ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Count := ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Count + pcCount^.rCount;

            ItemClass.GetItemData (StrPas (@ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Name), ItemData);
            ItemData.rColor := ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Color;
            ItemData.rCount := ItemLogData[ret].ItemData[pcCount^.rdestkey mod 10].Count;
            SendClass.SendLogItem (pcCount^.rdestkey, ItemData);
         end;
      DRAGACTION_FROMLOGTOITEM :
         begin
            if CopyHaveItem = nil then exit;

            if pcCount^.rsourkey < 10 then ret := 0
            else if pcCount^.rsourkey < 20 then ret := 1
            else if pcCount^.rsourkey < 30 then ret := 2
            else ret := 3;
            if ItemLogData[ret].Header.boUsed = false then exit;
            if ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Name[0] = 0 then exit;
            if ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Count < pcCount^.rCount then exit;

            CopyHaveItem.ViewItem (pcCount^.rdestkey, @ItemData);
            if ItemData.rName [0] <> 0 then begin
               if ItemData.rboDouble = false then exit;
               if StrPas (@ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Name) <> StrPas (@ItemData.rName) then exit;
               if ItemData.rColor <> ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Color then exit;
            end;

            ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Count := ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Count - pcCount^.rCount;

            ItemClass.GetItemData (StrPas (@ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Name), ItemData);
            ItemData.rColor := ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Color;
            ItemData.rCount := pcCount^.rCount;
            if CopyHaveItem.AddKeyItem (pcCount^.rdestkey, pcCount^.rCount, ItemData) = false then exit;

            if ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Count <= 0 then begin
               FillChar (ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10], SizeOf (TItemLogData), 0);
            end;
            ItemClass.GetItemData (StrPas (@ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Name), ItemData);
            ItemData.rColor := ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Color;
            ItemData.rCount := ItemLogData[ret].ItemData[pcCount^.rsourkey mod 10].Count;
            SendClass.SendLogItem (pcCount^.rsourkey, ItemData);
         end;
   end;
end;

procedure TUser.DragProcess (var code: TWordComData);
var
   i, ret : integer;
   pcDragDrop : PTCDragDrop;
   BObject : TBasicObject;
   tmpBasicData : TBasicData;
   ItemData, tmpItemData : TItemdata;
   SubData : TSubData;
   boFlag : boolean;
   oldHitType : Byte;
   str : String;
   ComData : TWordComData;
   pcSelectCount : PTCSelectCount;
begin
   pcDragDrop := @Code.Data;
   with pcdragdrop^ do begin
      if (rsourwindow = WINDOW_ITEMS) and (rdestwindow = WINDOW_ITEMS) then begin
         if ExchangeData.rExChangeId <> 0 then begin
            SendClass.SendChatMessage('正在交易,操作失败.', SAY_COLOR_SYSTEM);
            exit;
         end;
         HaveItemClass.ChangeItem (rsourkey, rdestkey);
      end;
      if (rsourwindow = WINDOW_MAGICS) and (rdestwindow = WINDOW_MAGICS) then begin
         HaveMagicClass.ChangeMagic (rsourkey, rdestkey);
      end;
      {
      if (rsourwindow = WINDOW_BASICFIGHT) and (rdestwindow = WINDOW_BASICFIGHT) then begin
         HaveMagicClass.ChangeBasicMagic (rsourkey, rdestkey);
      end;
      }
      if (rsourwindow = WINDOW_ITEMS) and (rdestwindow = WINDOW_WEARS) then begin
         if ExchangeData.rExChangeId <> 0 then begin
            SendClass.SendChatMessage('正在交易,操作失败.', SAY_COLOR_SYSTEM);
            exit;
         end;
         WearItemClass.ViewItem (ARR_WEAPON, @ItemData);

         oldHitType := ItemData.rHitType;

         if HaveItemClass.ViewItem (rsourkey, @ItemData) = FALSE then exit;
         if WearItemClass.AddItem (@ItemData) = FALSE then exit;
         tmpItemData.rOwnerName[0] := 0;
         HaveItemClass.DeleteKeyItem (rsourkey, 1, @tmpItemData);

         WearItemClass.ViewItem (ARR_WEAPON, @ItemData);
         if oldHitType <> ItemData.rHitType then begin
            HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
            HaveMagicClass.SelectBasicMagic (ItemData.rHitType, 100, str);
            HaveMagicClass.SetEctMagic(nil);
         end;
         BasicData.Feature := WearItemClass.GetFeature;
         SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
      end;

      if (rsourwindow = WINDOW_WEARS) and (rdestwindow = WINDOW_ITEMS) then begin
         if ExchangeData.rExChangeId <> 0 then begin
            SendClass.SendChatMessage('正在交易,操作失败.', SAY_COLOR_SYSTEM);
            exit;
         end;
      
         WearItemClass.ViewItem (ARR_WEAPON, @ItemData);

         oldHitType := ItemData.rHitType;

         if rsourkey = 5 then rsourkey := 1;
         if WearItemClass.ViewItem (rsourkey, @ItemData) = FALSE then exit;
         ItemData.rOwnerName[0] := 0;
         if HaveItemClass.AddItem (@ItemData) = FALSE then exit;
         WearItemClass.DeleteKeyItem (rsourkey);

         WearItemClass.ViewItem (ARR_WEAPON, @ItemData);
         if oldHitType <> ItemData.rHitType then begin
            HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
            HaveMagicClass.SelectBasicMagic (ItemData.rHitType, 100, str);
            HaveMagicClass.SetEctMagic (nil);
         end;
         BasicData.Feature := WearItemClass.GetFeature;
         SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
      end;

      if (rsourwindow = WINDOW_ITEMS) and (rdestwindow = WINDOW_SCREEN) then begin // 滚府扁
         if HaveItemClass.ViewItem (rsourkey, @ItemData) = FALSE then exit;
         if ItemData.rKind = ITEM_KIND_CANTMOVE then begin
            SendClass.SendChatMessage ('无法交换的物品.', SAY_COLOR_SYSTEM);
            exit;
         end;
         if GetCellLength (BasicData.x, BasicData.y, rdx, rdy) > 3 then begin
            SendClass.SendChatMessage ('距离太远.', SAY_COLOR_SYSTEM);
            exit;
         end;
         BasicData.nx := rdx;
         BasicData.ny := rdy;
         SubData.ServerId := ServerID;
         if rdestid <> 0 then begin


// 背券芒 规过 Start
            if rdestid <> BasicData.id then begin
               if SpecialWindow <> WINDOW_NONE then exit;
               if ExchangeData.rExChangeId <> 0 then exit;
               Bobject := GetViewObjectById ( rDestid);
               if (Integer (BObject) = -1) or (Integer(BObject) = 0) then exit;
               if (BObject.BasicData.Feature.rrace = RACE_HUMAN) then begin
                  if (BObject.BasicData.Feature.rfeaturestate = wfs_die) and (StrPas (@ItemData.rName) = INI_ROPE) then begin
                     SignToItem (ItemData, ServerID, BasicData, IP);
                     SubData.ItemData := ItemData;
                     SubData.ItemData.rCount := 1;
                     BasicData.nx := rdx;
                     BasicData.ny := rdy;
                     ret := Phone.SendMessage (rdestid, FM_ADDITEM, BasicData, SubData);     //  鸥牢俊霸 林扁...
                     if ret = PROC_TRUE then begin
                        tmpItemData.rOwnerName[0] := 0;
                        HaveItemClass.DeleteKeyItem (rsourkey, 1, @tmpItemData);
                     end;
                     exit;
                  end;
                  if TUser(BObject).SpecialWindow <> WINDOW_NONE then begin
                     SendClass.SendChatMessage(TUser(BObject).Name + '此人在无法进行交换物品的状态下.', SAY_COLOR_SYSTEM);
                     exit;
                  end;
                  if TUser(BObject).ExchangeData.rExchangeId <> 0 then begin
                     SendClass.SendChatMessage('对方与其他人交易中.', SAY_COLOR_SYSTEM);
                     exit;
                  end;

                  ExChangeStart (rDestid);
                  rdestwindow := WINDOW_EXCHANGE;
                  // exit;
               end else begin
                  ItemData.rCount := 1;
                  SignToItem (ItemData, ServerID, BasicData, IP);
                  SubData.ItemData := ItemData;
                  BasicData.nx := rdx;
                  BasicData.ny := rdy;
                  ret := Phone.SendMessage (rdestid, FM_ADDITEM, BasicData, SubData);     //  鸥牢俊霸 林扁...
                  if ret = PROC_TRUE then begin
                     tmpBasicData.Feature.rRace := RACE_NPC;
                     StrPCopy (@tmpBasicData.Name, '染色物品');
                     tmpBasicData.x := BasicData.x;
                     tmpBasicData.y := BasicData.y;
                     SignToItem (ItemData, ServerID, tmpBasicData, '');
                     HaveItemClass.DeleteKeyItem (rsourkey, 1, @ItemData);
                  end;
                  exit;
               end;
            end;
// 背券芒 规过 end

{
// 背券芒 荤侩捞傈 start
            SubData.ItemData := ItemData;
            SubData.ItemData.rCount := 1;
            BasicData.nx := rdx;
            BasicData.ny := rdy;
            ret := Phone.SendMessage (rdestid, FM_ADDITEM, BasicData, SubData);     //  鸥牢俊霸 林扁...
            if ret = PROC_TRUE then HaveItemClass.DeleteKeyItem (rsourkey, 1);
// 背券芒 荤侩捞傈 end
}
         end else begin
            if ExchangeData.rExChangeId <> 0 then begin
               SendClass.SendChatMessage('正在交易,操作失败.', SAY_COLOR_SYSTEM);
               exit;
            end;

            {
            if (ItemData.rCount = 1) or (ItemData.rboDouble = false) then begin
               ItemData.rCount := 1;
               SignToItem (ItemData, ServerID, BasicData);
               SubData.ItemData := ItemData;
               BasicData.nx := rdx;
               BasicData.ny := rdy;
               ret := Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
               if ret = PROC_TRUE then begin
                  tmpBasicData.Feature.rRace := RACE_NPC;
                  StrPCopy (@tmpBasicData.Name, '地面');
                  tmpBasicData.x := BasicData.x;
                  tmpBasicData.y := BasicData.y;
                  SignToItem (ItemData, ServerID, tmpBasicData);
                  HaveItemClass.DeleteKeyItem (rsourkey, 1, ItemData);
               end else begin
                  SendClass.SendChatMessage ('无法放在这个地方.', SAY_COLOR_SYSTEM);
               end;
            end else begin
            }
               CountWindowState := DRAGACTION_DROPITEM;
               SendClass.SendShowCount (DRAGACTION_DROPITEM, rsourkey, rdestkey, ItemData.rCount, StrPas (@ItemData.rViewName));
               SendClass.SendChatMessage ('请选择数量.', SAY_COLOR_SYSTEM);
            {
            end;
            }
            exit;
         end;
      end;

      if (rsourwindow = WINDOW_SCREEN) and (rdestwindow = WINDOW_ITEMS) then begin // 凛扁
         if rsourid <> 0 then begin
            Bobject := GetViewObjectById (rsourid);
            if (Integer (BObject) = -1) or (Integer(BObject) = 0) then exit;
            if GetCellLength (BasicData.x, BasicData.y, BObject.Posx, BObject.Posy) > 3 then begin
               SendClass.SendChatMessage ('距离太远.', SAY_COLOR_SYSTEM);
               exit;
            end;
            Phone.SendMessage (rsourid, FM_PICKUP, BasicData, SubData);
         end;
      end;
      if (rsourwindow = WINDOW_SCREEN) and (rdestwindow = WINDOW_SCREEN) then begin // 凛扁
         if BasicData.id = rdestid then begin
            if rsourid <> 0 then begin
               Bobject := GetViewObjectById ( rsourid);
               if (Integer (BObject) = -1) or (Integer(BObject) = 0) then exit;
               if GetCellLength (BasicData.x, BasicData.y, BObject.Posx, BObject.Posy) > 3 then begin
                  SendClass.SendChatMessage ('距离太远.', SAY_COLOR_SYSTEM);
                  exit;
               end;
               Phone.SendMessage (rsourid, FM_PICKUP, BasicData, SubData);
            end;
         end;
      end;

      if (rsourwindow = WINDOW_ITEMS) and (rdestwindow = WINDOW_EXCHANGE) then begin // 背券芒俊 棵府扁
         // 肮荐甫 拱绢焊扁 傈俊 固府 八荤茄促 start
         if not HaveItemClass.ViewItem (rsourkey, @ItemData) then exit;
         if ItemData.rKind = ITEM_KIND_CANTMOVE then begin
            SendClass.SendChatMessage ('无法交换的物品.', SAY_COLOR_SYSTEM);
            exit;
         end;

         for i := 0 to 4-1 do begin
            if StrPas (@ItemData.rName) = ExChangeData.rItems[i].rItemName then begin
               if ItemData.rColor = ExChangeData.rItems[i].rColor then begin
                  SendClass.SendChatMessage ('已经有同样名称的物品.', 3);
                  exit;
               end;
            end;
         end;

         boFlag := false;
         for i := 0 to 4-1 do begin
            if ExChangeData.rItems[i].rItemCount = 0 then begin
               boFlag := true;
               break;
            end;
         end;

         if boFlag = false then begin
            SendClass.SendChatMessage ('无法继续添加.', 3);
            exit;
         end;

         // 肮荐甫 拱绢焊扁 傈俊 固府 八荤茄促 start
         // if HaveItemClass.ViewItem (rsourkey, ItemData) = FALSE then exit;

         CountWindowState := DRAGACTION_ADDEXCHANGEITEM;

         SendClass.SendShowCount (DRAGACTION_ADDEXCHANGEITEM, rsourkey, rdestkey, ItemData.rCount, StrPas (@ItemData.rViewName));
         SendClass.SendChatMessage ('请选择数量.', SAY_COLOR_SYSTEM);
{
         sCount.rmsg := SM_SHOWCOUNT;
         sCount.rCountid := DRAGACTION_ADDEXCHANGEITEM;
         sCount.rkey := pcdragdrop^.rsourkey;
         sCount.rCountCur := 0;
         sCount.rCountMax := ItemDataArr[pcdragdrop^.rsourkey].rcount;
         SetWordString ( sCount.rCountName, StrPas (@ItemDataarr[pcdragdrop^.rsourkey].rViewName));
         SendDataFunction ( sizeof(sCount)-sizeof(TWordString)+sizeofWordstring(sCount.rCountName), @scount);
         SendSystemMessage ('请选择数量.',1);
}
      end;

      if (rsourwindow = WINDOW_ITEMS) and (rdestwindow = WINDOW_ITEMLOG) then begin
         if CopyHaveItem = nil then begin
            frmMain.WriteLogInfo ('CopyHaveItem = nil');
            exit;
         end;
         if not CopyHaveItem.ViewItem (rsourkey, @ItemData) then exit;
         
         if rdestkey < 10 then ret := 0
         else if rdestkey < 20 then ret := 1
         else if rdestkey < 30 then ret := 2
         else ret := 3;
         if ItemLogData[ret].Header.boUsed = false then exit;
         if ItemLogData[ret].ItemData[rdestkey mod 10].Name[0] <> 0 then begin
            if ItemData.rboDouble = false then exit;
            if StrPas (@ItemLogData[ret].ItemData[rdestkey mod 10].Name) <> StrPas (@ItemData.rName) then exit;
            if ItemLogData[ret].ItemData[rdestkey mod 10].Color <> ItemData.rColor then exit;
         end;

         if ItemData.rCount > 1 then begin
            SendClass.SendShowCount (DRAGACTION_FROMITEMTOLOG, rSourKey, rDestKey, ItemData.rCount, StrPas (@ItemData.rViewName));
         end else begin
            FillChar (ComData, SizeOf (TComData), 0);
            pcSelectCount := @ComData.Data;
            pcSelectCount^.rboOk := true;
            pcSelectCount^.rsourkey := rsourkey;
            pcSelectCount^.rdestkey := rdestkey;
            pcSelectCount^.rCount := 1;
            pcSelectCount^.rCountid := DRAGACTION_FROMITEMTOLOG;
            SelectCount (ComData);
         end;
      end;
      if (rsourwindow = WINDOW_ITEMLOG) and (rdestwindow = WINDOW_ITEMS) then begin
         if CopyHaveItem = nil then begin
            frmMain.WriteLogInfo ('CopyHaveItem = nil');
            exit;
         end;
         
         if rsourkey < 10 then ret := 0
         else if rsourkey < 20 then ret := 1
         else if rsourkey < 30 then ret := 2
         else ret := 3;
         if ItemLogData[ret].Header.boUsed = false then exit;
         if ItemLogData[ret].ItemData[rsourkey mod 10].Name[0] = 0 then exit;

         FillChar (ItemData, SizeOf (TItemData), 0);
         CopyHaveItem.ViewItem (rdestkey, @ItemData);
         if ItemData.rName[0] <> 0 then begin
            if ItemData.rboDouble = false then exit;
            if StrPas (@ItemLogData[ret].ItemData[rsourkey mod 10].Name) <> StrPas (@ItemData.rName) then exit;
            if ItemLogData[ret].ItemData[rsourkey mod 10].Color <> ItemData.rColor then exit;
         end;

         if ItemLogData[ret].ItemData[rsourkey mod 10].Count > 1 then begin
            ItemClass.GetItemData (StrPas (@ItemLogData[ret].ItemData[rsourkey mod 10].Name), ItemData);
            SendClass.SendShowCount (DRAGACTION_FROMLOGTOITEM, rSourKey, rDestKey, ItemLogData[ret].ItemData[rsourkey mod 10].Count, StrPas (@ItemData.rViewName));
         end else begin
            FillChar (ComData, SizeOf (TComData), 0);
            pcSelectCount := @ComData.Data;
            pcSelectCount^.rboOk := true;
            pcSelectCount^.rsourkey := rsourkey;
            pcSelectCount^.rdestkey := rdestkey;
            pcSelectCount^.rCount := 1;
            pcSelectCount^.rCountid := DRAGACTION_FROMLOGTOITEM;
            SelectCount (ComData);
         end;
      end;
   end;
end;

function TUser.AddableExChangeData (pex : PTExChangedata): Boolean;
var i, cnt, excnt : integer;
begin
   Result := TRUE;

   cnt := 0;
   for i := 0 to HAVEITEMSIZE -1 do if HaveItemClass.HaveItemArr[i].rName[0] = 0 then cnt := cnt + 1;

   excnt := 0;
   for i := 0 to 4-1 do if pex^.ritems[i].ritemcount <> 0 then excnt := excnt + 1;

   if cnt < excnt then Result := FALSE;
end;

procedure TUser.AddExChangeData (var aSenderInfo : TBasicData; pex : PTExChangedata; aSenderIP : String);
var
   i : integer;
   ItemData : TItemData;
begin
   for i := 0 to 4 - 1 do begin
      if pEx^.rItems[i].rItemName <> '' then begin
         ItemClass.GetItemdata (pex^.rItems[i].rItemName, ItemData);
         ItemData.rCount := pex^.rItems[i].rItemCount;
         ItemData.rColor := pex^.rItems[i].rColor;
         SignToItem (ItemData, ServerID, aSenderInfo, aSenderIP);
         HaveItemClass.AddItem (@ItemData);
      end;
   end;
end;

procedure TUser.DelExChangeData (pex : PTExChangedata);
var
   key, j : integer;
   ItemData : TItemData;
begin
   for j := 0 to 4-1 do begin
      if pEx^.rItems[j].rItemName <> '' then begin
         key := pEx^.rItems[j].rKey;
         if StrPas (@HaveItemClass.HaveItemArr[key].rName) = pex^.rItems[j].rItemName then begin
            if HaveItemClass.HaveItemArr[key].rColor = pex^.rItems[j].rColor then begin
               if HaveItemClass.HaveItemArr[key].rCount >= pEx^.rItems[j].rItemCount then begin
                  ItemData.rOwnerName[0] := 0;
                  HaveItemClass.DeleteKeyItem (key, pEx^.rItems[j].rItemCount, @ItemData);
               end;
            end;
         end;
      end;
   end;
end;

procedure TUser.ClickExChange (awin:byte; aclickedid:longInt; akey:word);
var
   boExChange : Boolean;
   BObject : TBasicObject;
   ExUser : TUser;
   TempBasicData : TBasicData;
   SubData : TSubData;
begin
   boExChange := TRUE;

   ExChangeData.rboCheck := not ExChangeData.rboCheck;

   if ExChangeData.rboCheck then begin
      BObject := TBasicObject (SendLocalMessage ( ExChangeData.rExChangeId, FM_GIVEMEADDR, BasicData, SubData));
      if (Integer (BObject) = 0) or (integer(BObject) = -1) then begin
         boExChange := FALSE;
      end else begin
         if not (BObject is TUser) then boExChange := FALSE;
      end;

      if boExChange = FALSE then begin
         SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
         TempBasicData.id := ExChangeData.rExChangeId;
         SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, TempBasicData, SubData);
         exit;
      end;

      ExUser := TUser (BObject);

      if ExUser.ExChangeData.rboCheck then begin

         if isCheckExChangeData = FALSE then boExChange := FALSE;
         if ExUser.isCheckExChangeData = FALSE then boExChange := FALSE;
         if boExChange = FALSE then begin
            SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
            TempBasicData.id := ExChangeData.rExChangeId;
            SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, TempBasicData, SubData);
            exit;
         end;

         if AddableExChangeData(@ExUser.ExChangedata) = FALSE then boExChange := FALSE;
         if ExUser.AddableExChangeData(@ExChangeData) = FALSE then boExChange := FALSE;
         if boExChange = FALSE then begin
            SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
            TempBasicData.id := ExChangeData.rExChangeId;
            SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, TempBasicData, SubData);
            exit;
         end;

         AddExChangeData(ExUser.BasicData, @ExUser.ExChangedata, ExUser.IP);
         ExUser.AddExChangeData(BasicData, @ExChangeData, IP);

         DelExChangeData(@ExChangedata);
         ExUser.DelExChangeData(@ExUser.ExChangeData);

         SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
         TempBasicData.id := ExChangeData.rExChangeId;
         SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, TempBasicData, SubData);
         exit;
      end;
   end;

   SendLocalMessage ( ExChangeData.rExChangeId, FM_SHOWEXCHANGE, BasicData, SubData);
   TempBasicData.id := ExChangeData.rExChangeId;
   SendLocalMessage ( BasicData.Id, FM_SHOWEXCHANGE, TempBasicData, SubData);
end;

procedure TUser.MessageProcess (var code: TWordComData);
var
   CurTick, CurNetTick, NetTick : integer;
   i, ret, n : integer;
   boFlag : Boolean;
   MagicData : TMagicData;
   ItemData, tmpItemData : TItemData;
   xx, yy: word;
   str, iname : string;
   SubData : TSubData;
   pckey : PTCkey;
   pcHit : PTCHit;
   pcsay : PTCSay;
   pcMove : PTCMove;
   pcClick : PTCClick;
   pcWindowConfirm : PTCWindowConfirm;
   pcGuildMagicData : PTCGuildMagicData;
   pcDragDrop : PTCDragDrop;
   pcMouseEvent : PTCMouseEvent;
   pcNetState : PTCNetState;

   tmpBasicData : TBasicData;
   BObject : TBasicObject;
   ExUser : TUser;
   GuildObject : TGuildObject;
   pGuildSelfData : PTCreateGuildData;

   oldHitType : Byte;
   ComData : TWordComData;
begin
   pckey := @Code.Data;

   if (BasicData.Feature.rfeaturestate = wfs_die) and (pckey^.rmsg <> CM_SAY) then exit;

   CurTick := mmAnsTick;

   try
   case pckey^.rmsg of
      CM_NETSTATE :
         begin
            pCNetState := @Code.Data;

            if CurTick >= pCNetState^.rMadeTick + 100 then begin
               FillChar (SaveNetState, SizeOf (TCNetState), 0);
               exit;
            end;
            if (SaveNetState.rID = 0) or (pCNetState^.rID - SaveNetState.rID > 1) then begin
               Move (pCNetState^, SaveNetState, SizeOf (TCNetState));
               exit;
            end;
            if pCNetState^.rCurTick - SaveNetState.rCurTick >= 900 then begin
               if boCheckSpeed = true then begin
                  MacroChecker.SaveMacroCase (Name, 4);
                  ConnectorList.CloseConnectByCharName (Name);
               end;
            end;
            Move (pCNetState^, SaveNetState, SizeOf (TCNetState));
            exit;
         end;
      CM_MOUSEEVENT : // 付快胶 捞亥飘 贸府... 皋农肺...
         begin
            pcMouseEvent := @Code.data;
            str := Name + ',';
            for i := 0 to 10 - 1 do begin
               str := str + IntToStr(pcMouseEvent^.rEvent[i]) + ',';
            end;
            UdpSendMouseEvent (Str);

            // 概农肺牢啊甫 眉农窍咯 蜡历狼 立加阑 辆丰矫挪促
            MacroChecker.AddMouseEvent (pcMouseEvent, CurTick);
            if MacroChecker.Check (Name) then begin
               ConnectorList.CloseConnectByCharName (Name);   
            end;
         end;
      CM_SELECTCOUNT :
         begin
            if CM_MessageTick[CM_SELECTCOUNT] + 50 > CurTick then exit;
            CM_MessageTick[CM_SELECTCOUNT] := CurTick;
            SelectCount (code);
         end;
      CM_CANCELEXCHANGE  :
         begin
            if CM_MessageTick[CM_CANCELEXCHANGE] + 50 > CurTick then exit;
            CM_MessageTick[CM_CANCELEXCHANGE] := CurTick;
            if ExChangeData.rExChangeId <> 0 then begin
               SendClass.SendChatMessage('取消交易', SAY_COLOR_SYSTEM);
               // BObject := TBasicObject (SendLocalMessage ( ExChangeData.rExChangeId, FM_GIVEMEADDR, BasicData, SubData));
               // if (Integer (BObject) = 0) or (Integer(BObject) = -1) then exit
               // else if not (BObject is TUser) then exit;
               BObject := TBasicObject (UserList.GetUserPointerById (ExChangeData.rExchangeId));
               if BObject <> nil then begin
                  ExUser := TUser(BObject);
                  ExUser.SendClass.SendChatMessage('交易被取消', SAY_COLOR_SYSTEM);
                  ExUser.FieldProc (ExChangeData.rExchangeId, FM_CANCELEXCHANGE, BasicData, SubData);
               end;

               // SendLocalMessage ( ExChangeData.rExChangeId, FM_CANCELEXCHANGE, BasicData, SubData);
               tmpBasicData.id := ExChangeData.rExChangeId;
               SendLocalMessage ( BasicData.id, FM_CANCELEXCHANGE, tmpBasicData, SubData);

               FillChar (ExChangeData, SizeOf (TExchangeData), 0);
            end;
         end;
      CM_INPUTSTRING :
         begin
            if CM_MessageTick[CM_INPUTSTRING] + 50 > CurTick then exit;
            CM_MessageTick[CM_INPUTSTRING] := CurTick;
            InputStringProcess (Code);
         end;
      CM_DRAGDROP :
         begin
            if CM_MessageTick[CM_DRAGDROP] + 50 > CurTick then exit;
            CM_MessageTick[CM_DRAGDROP] := CurTick;
            DragProcess (Code);
         end;
      CM_DBLCLICK :
         begin
            if CM_MessageTick[CM_DBLCLICK] + 30 > CurTick then exit;
            CM_MessageTick[CM_DBLCLICK] := CurTick;

            pcClick := @Code.Data;
            case pcclick^.rwindow of
               WINDOW_SCREEN :
                  begin
                     if SpecialWindow <> WINDOW_NONE then exit;
                     
                     if (pcclick^.rclickedId <> 0) then begin
                        if IsObjectItemID (pcclick^.rclickedid) then begin
                           FillChar (ComData, SizeOf (TCDragDrop) + SizeOf (Word), 0);
                           ComData.Size := SizeOf (TCDragDrop);
                           pcDragDrop := @ComData.Data;
                           pcDragDrop^.rmsg := CM_DRAGDROP;
                           pcDragDrop^.rsourwindow := WINDOW_SCREEN;
                           pcDragDrop^.rdestwindow := WINDOW_ITEMS;
                           pcDragDrop^.rsourId := pcclick^.rclickedid;
                           DragProcess (ComData);
                           exit;
                        end;

                        SendLocalMessage (pcclick^.rclickedid, FM_DBLCLICK, BasicData, SubData);
                        if HaveMagicClass.pCurEctMagic <> nil then begin
                           if HaveMagicClass.pCurEctMagic^.rFunction = MAGICFUNC_REFILL then begin
                              SendLocalMessage (pcclick^.rclickedid, FM_REFILL, BasicData, SubData);
                              exit;
                           end;
                        end;
                     end;

                     if (BasicData.Feature.rFeatureState = wfs_care) and (pcclick^.rclickedId <> 0) then begin
                        if pcclick^.rclickedid = TargetID then exit;
                        if PrevTargetId <> 0 then begin
                           if isMonsterID (pcclick^.rclickedID) = true then begin
                              if isMonsterId (PrevTargetID) = true then begin
                                 if boCanAttack = true then SetTargetId (pcclick^.rclickedid);
                                 exit;
                              end;
                           end;
                           if isUserID (pcclick^.rclickedID) = true then begin
                              if isUserId (PrevTargetID) = true then begin
                                 if (Manager.boHit = true) and (boCanAttack = true) then
                                    SetTargetId (pcclick^.rclickedid);
                                 exit;
                              end;
                           end;
                        end;
                        if TargetId <> 0 then begin
                           if isMonsterId (pcclick^.rclickedId) = true then begin
                              if isMonsterId (TargetID) = true then begin
                                 if boCanAttack = true then SetTargetId (pcclick^.rclickedid);
                                 exit;
                              end;
                           end;
                           if isUserId (pcclick^.rclickedId) = true then begin
                              if isUserId (TargetID) = true then begin
                                 if (Manager.boHit = true) and (boCanAttack = true) then
                                    SetTargetId (pcclick^.rclickedid);
                                 exit;
                              end;
                           end;
                        end;
                     end;

                     if (ssShift in pcclick^.rShift) and (pcclick^.rclickedId <> 0) then begin
                        if isMonsterId (pcclick^.rclickedId) = true then begin
                           if boCanAttack = true then SetTargetId (pcclick^.rclickedid);
                        end;
                        exit;
                     end;
                     if (ssCtrl in pcclick^.rShift) and (pcclick^.rclickedId <> 0) then begin
                        if isUserId (pcclick^.rclickedId) = true then begin
                           if (Manager.boHit = true) and (boCanAttack = true) then
                              SetTargetId (pcclick^.rclickedid);
                        end;
                        exit;
                     end;
                  end;
               WINDOW_ITEMS :
                  begin
                     if SpecialWindow <> WINDOW_NONE then exit;
                     
                     if HaveItemClass.ViewItem (pcclick^.rkey, @ItemData) = FALSE then exit;
                     case ItemData.rKind of
                        ITEM_KIND_ITEMLOG :
                           begin
                              if SpecialWindow <> 0 then exit;
                              n := ItemLog.GetRoomCount (Name);
                              if n >= 4 then begin
                                 SendClass.SendChatMessage (format ('%s的福袋数量已满.', [Name]), SAY_COLOR_SYSTEM);
                                 exit;
                              end;

                              if ItemLog.CreateRoom (Name) = true then begin
                                 tmpItemData.rOwnerName[0] := 0;
                                 HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @tmpItemData);
                                 SendClass.SendChatMessage ('物品已使用.',SAY_COLOR_SYSTEM);
                                 SendClass.SendChatMessage (format ('%s的福袋一共有%d个.', [Name, n + 1]), SAY_COLOR_SYSTEM);
                              end else begin
                                 SendClass.SendChatMessage ('为了系统的稳定,所以无法再增加福袋.', SAY_COLOR_SYSTEM);
                              end;
                           end;
                        ITEM_KIND_WEARITEM2,
                        ITEM_KIND_WEARITEM :
                           begin
                              if ExchangeData.rExChangeId <> 0 then begin
                                 SendClass.SendChatMessage('正在交易,操作失败.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;

                              WearItemClass.ViewItem (ARR_WEAPON, @tmpItemData);
                              oldHitType := tmpItemData.rHitType;

                              ItemData.rCount := 1;

                              if WearItemClass.ChangeItem (ItemData, tmpItemDAta) = true then begin
                                 ItemData.rOwnerName[0] := 0;
                                 HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @ItemData);
                                 if tmpItemData.rName[0] <> 0 then begin
                                    HaveItemClass.AddKeyItem (pcclick^.rkey, 1, tmpItemData);
                                 end;

                                 WearItemClass.ViewItem (ARR_WEAPON, @ItemData);
                                 if oldHitType <> ItemData.rHitType then begin
                                    HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
                                    HaveMagicClass.SelectBasicMagic (ItemData.rHitType, 100, str);
                                    HaveMagicClass.SetEctMagic(nil);
                                 end;
                                 BasicData.Feature := WearItemClass.GetFeature;
                                 SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                              end;
                           end;
                        ITEM_KIND_HIDESKILL :
                           begin
                              if UseSkillKind <> -1 then begin
                                 SendClass.SendChatMessage ('现在无法使用.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;
                              if UseSkillKind = ItemData.rKind then begin
                                 SendClass.SendChatMessage ('无法重复使用.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;
                              UseSkillKind := ItemData.rKind;
                              SkillUsedTick := CurTick;
                              SkillUsedMaxTick := INI_HIDEPAPER_DELAY * 100;
                              WearItemClass.SetHiddenState (hs_0);
                              SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

                              tmpItemData.rOwnerName[0] := 0;
                              HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @tmpItemData);
                              SendClass.SendChatMessage ('物品已使用.',SAY_COLOR_SYSTEM);
                           end;
                        ITEM_KIND_SHOWSKILL :
                           begin
                              if UseSkillKind <> -1 then begin
                                 SendClass.SendChatMessage ('现在无法使用.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;
                              if UseSkillKind = ItemData.rKind then begin
                                 SendClass.SendChatMessage ('无法重复使用.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;

                              UseSkillKind := ItemData.rKind;
                              SkillUsedTick := CurTick;
                              SkillUsedMaxTick := INI_SHOWPAPER_DELAY * 100;

                              for i := 0 to ViewObjectList.Count - 1 do begin
                                 BObject := ViewObjectList.Items [i];
                                 if BObject.BasicData.Feature.rHideState = hs_0 then begin
                                    SendLocalMessage (BasicData.ID, FM_CHANGEFEATURE, BObject.BasicData, SubData);
                                 end;
                              end;

                              tmpItemData.rOwnerName[0] := 0;
                              HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @tmpItemData);
                              SendClass.SendChatMessage ('物品已使用.',SAY_COLOR_SYSTEM);
                           end;
                        ITEM_KIND_TICKET:
                           begin
                              if ItemData.rServerId <> ServerID then begin
                                 boNewServer := TRUE;
                                 ServerID := ItemData.rServerId;
{
                                 case ItemData.rServerId of
                                    0: SendClass.SendChatMessage ('急厚锰俊辑 荤侩且荐 乐嚼聪促.',SAY_COLOR_SYSTEM);
                                    1: SendClass.SendChatMessage ('蛆按锰俊辑 荤侩且荐 乐嚼聪促.',SAY_COLOR_SYSTEM);
                                 end;
                                 exit;
}
                              end;
                              PosMoveX := ItemData.rx; PosMoveY := ItemData.ry;
                              tmpItemData.rOwnerName[0] := 0;
                              HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @tmpItemData);
                              SendClass.SendChatMessage ('物品已使用.',SAY_COLOR_SYSTEM);
                           end;
                        ITEM_KIND_DRUG:
                           begin
                              if Manager.boUseDrug = false then begin
                                 SendClass.SendChatMessage ('无法服用药物的地区.', SAY_COLOR_SYSTEM);
                                 exit;
                              end;
                              iname := StrPas (@ItemData.rName);
                              if AttribClass.AddItemDrug (iname) then begin
                                 if HaveItemClass.ViewItem (pcclick^.rkey, @ItemData) then begin
                                    if ItemData.rSoundEvent.rWavNumber <> 0 then begin
                                       SetWordString (SubData.SayString, IntToStr (ItemData.rSoundEvent.rWavNumber) + '.wav');
                                       SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                                    end;
                                 end;
                                 tmpBasicData.Feature.rrace := RACE_NPC;
                                 StrPCopy(@tmpBasicData.Name, '使用');
                                 tmpBasicData.x := BasicData.x;
                                 tmpBasicData.y := BasicData.y;
                                 ItemData.rCount := 1;
                                 SignToItem(ItemData, ServerID, tmpBasicData, '');
                                 HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @ItemData);
                                 SendClass.SendChatMessage (format ('服用了%s.',[iname]),SAY_COLOR_SYSTEM);
                              end else begin
                                 SendClass.SendChatMessage ('无法再服用.', SAY_COLOR_SYSTEM);
                              end
                           end;
                        ITEM_KIND_COLORDRUG:
                           begin

                           end;
                        ITEM_KIND_BOOK:
                           begin
                              str := StrPas (@ItemData.rname);

                              with AttribClass.AttribData do n := cEnergy + cMagic + cInPower + cOutPower + cLife;
                              n := (n - 5000) div 4000;
                              if n < 0 then n := 0;
                              if n > 11 then n := 11;

                              {
                              if n < ItemData.rNeedGrade then begin
                                 SendClass.SendChatMessage (format ('泅犁殿鞭:%d 鞘夸殿鞭:%d',[n, ItemData.rNeedGrade]),SAY_COLOR_SYSTEM);
                                 SendClass.SendChatMessage ('修炼武功失败.',SAY_COLOR_SYSTEM);
                                 exit;
                              end;
                              }

                              if MagicClass.GetMagicData (str, MagicData, 0) then begin
                                 if HaveMagicClass.AddMagic (@MagicData) then begin
                                    tmpItemData.rOwnerName[0] := 0;
                                    HaveItemClass.DeleteKeyItem (pcclick^.rkey, 1, @tmpItemData);
                                 end else begin
                                    SendClass.SendChatMessage ('修炼武功失败.',SAY_COLOR_SYSTEM);
                                    exit;
                                 end;
                              end;
                           end;
                     end;
                  end;
               WINDOW_WEARS :
                  begin
                  end;
               WINDOW_MAGICS:
                  begin
                     if SpecialWindow <> WINDOW_NONE then exit;
                     
                     HaveMagicClass.ViewMagic (pcclick^.rkey, @MagicData);
                     if MagicData.rName[0] = 0 then exit;

                     n := (AttribClass.CurHeadLife * 100 div AttribClass.MaxLife);
                     if HaveMagicClass.PreSelectHaveMagic (pcclick^.rkey, n, str) = false then begin
                        if str <> '' then begin
                           SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
                        end;
                        exit;
                     end;

                     boFlag := true;
                     Case MagicData.rMagicType of
                        MAGICTYPE_WRESTLING, MAGICTYPE_FENCING, MAGICTYPE_SWORDSHIP, MAGICTYPE_HAMMERING,
                        MAGICTYPE_SPEARING, MAGICTYPE_BOWING, MAGICTYPE_THROWING : boFlag := false;
                     end;

                     if boFlag = false then begin
                        if WearItemClass.GetWeaponType <> MagicData.rMagicType then begin
                           n := HaveItemClass.FindItemByMagicKind (MagicData.rMagicType);
                           if n < 0 then exit;
                           HaveItemClass.ViewItem (n, @ItemData);
                           ItemData.rCount := 1;

                           if ItemData.rName[0] <> 0 then begin
                              WearItemClass.ChangeItem (ItemData, tmpItemData);
                           end else begin
                              WearItemClass.ViewItem (ARR_WEAPON, @tmpItemData);
                              WearItemClass.DeleteKeyItem (ARR_WEAPON);
                           end;

                           ItemData.rOwnerName[0] := 0;
                           HaveItemClass.DeleteKeyItem (n, 1, @ItemData);
                           if tmpItemData.rName[0] <> 0 then begin
                              HaveItemClass.AddKeyItem (n, 1, tmpItemData);
                           end;

                           HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
                           BasicData.Feature := WearItemClass.GetFeature;
                           SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                        end;
                     end;

                     n := (AttribClass.CurHeadLife * 100 div AttribClass.MaxLife);
                     ret := HaveMagicClass.SelectHaveMagic (pcclick^.rkey, n, str);
                     case ret of
                        SELECTMAGIC_RESULT_FALSE:
                           begin
                              if str <> '' then SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
                              exit;
                           end;
                        SELECTMAGIC_RESULT_NONE:;
                        SELECTMAGIC_RESULT_NORMAL:  CommandChangeCharState (wfs_normal, FALSE);
                        SELECTMAGIC_RESULT_SITDOWN: CommandChangeCharState (wfs_sitdown, FALSE);
                        SELECTMAGIC_RESULT_RUNNING: CommandChangeCharState (wfs_running, FALSE);
                     end;
                     HaveMagicClass.ViewMagic (pcclick^.rkey, @MagicData);
                     if MagicData.rName[0] <> 0 then begin
                        SetWordString (SubData.SayString, StrPas (@MagicData.rName));
                        SendLocalMessage (NOTARGETPHONE, FM_SAYUSEMAGIC, BasicData, SubData);
                     end;
                  end;
               WINDOW_BASICFIGHT:
                  begin
                     if SpecialWindow <> WINDOW_NONE then exit;
                     
                     HaveMagicClass.ViewBasicMagic (pcclick^.rkey, @MagicData);
                     if MagicData.rName[0] = 0 then exit;

                     n := (AttribClass.CurHeadLife * 100 div AttribClass.MaxLife);
                     if HaveMagicClass.PreSelectBasicMagic (pcclick^.rkey, n, str) = false then begin
                        if str <> '' then begin
                           SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
                        end;
                        exit;
                     end;

                     boFlag := true;
                     Case MagicData.rMagicType of
                        MAGICTYPE_WRESTLING, MAGICTYPE_FENCING, MAGICTYPE_SWORDSHIP, MAGICTYPE_HAMMERING,
                        MAGICTYPE_SPEARING, MAGICTYPE_BOWING, MAGICTYPE_THROWING : boFlag := false;
                     end;

                     if boFlag = false then begin
                        if WearItemClass.GetWeaponType <> MagicData.rMagicType then begin
                           n := HaveItemClass.FindItemByMagicKind (MagicData.rMagicType);
                           if n < 0 then exit;
                           HaveItemClass.ViewItem (n, @ItemData);
                           ItemData.rCount := 1;

                           if ItemData.rName[0] <> 0 then begin
                              WearItemClass.ChangeItem (ItemData, tmpItemData);
                           end else begin
                              WearItemClass.ViewItem (ARR_WEAPON, @tmpItemData);
                              WearItemClass.DeleteKeyItem (ARR_WEAPON);
                           end;

                           ItemData.rOwnerName[0] := 0;
                           HaveItemClass.DeleteKeyItem (n, 1, @ItemData);
                           if tmpItemData.rName[0] <> 0 then begin
                              HaveItemClass.AddKeyItem (n, 1, tmpItemData);
                           end;
                           HaveMagicClass.SetHaveItemMagicType (ItemData.rHitType);
                           BasicData.Feature := WearItemClass.GetFeature;
                           SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                        end;
                     end;

                     n := (AttribClass.CurHeadLife * 100 div AttribClass.MaxLife);
                     ret := HaveMagicClass.SelectBasicMagic (pcclick^.rkey, n, str);
                     case ret of
                        SELECTMAGIC_RESULT_FALSE:
                           begin
                              if str <> '' then SendClass.SendChatMessage (str, SAY_COLOR_SYSTEM);
                              exit;
                           end;
                        SELECTMAGIC_RESULT_NONE:;
                        SELECTMAGIC_RESULT_NORMAL:  CommandChangeCharState (wfs_normal, FALSE);
                        SELECTMAGIC_RESULT_SITDOWN: CommandChangeCharState (wfs_sitdown, FALSE);
                        SELECTMAGIC_RESULT_RUNNING: CommandChangeCharState (wfs_running, FALSE);
                     end;
                     MagicData := HaveMagicClass.DefaultMagic[pcclick^.rkey];
                     if MagicData.rName[0] <> 0 then begin
                        SetWordString (SubData.SayString, StrPas (@MagicData.rName));
                        SendLocalMessage (NOTARGETPHONE, FM_SAYUSEMAGIC, BasicData, SubData);
                     end;
                  end;
               else exit;
            end;
         end;
      CM_CLICK :
         begin
            if CM_MessageTick[CM_CLICK] + 30 > CurTick then exit;
            CM_MessageTick[CM_CLICK] := CurTick;

            pcClick := @Code.Data;
            case pcclick^.rwindow of
               WINDOW_EXCHANGE: ClickExChange (pcclick^.rwindow, pcclick^.rclickedId, pcclick^.rkey);
               WINDOW_BASICFIGHT:
                  begin
                     if not HaveMagicClass.ViewBasicMagic (pcclick^.rkey, @MagicData) then exit;
                     str := GetMagicDataInfo (MagicData);
                     SendClass.SendChatMessage (str, SAY_COLOR_NORMAL);
                  end;
               WINDOW_MAGICS:
                  begin
                     if not HaveMagicClass.ViewMagic (pcclick^.rkey, @MagicData) then exit;
                     str := GetMagicDataInfo (MagicData);
                     SendClass.SendChatMessage (str, SAY_COLOR_NORMAL);
                  end;
               WINDOW_ITEMS :
                  begin
                     if not HaveItemClass.ViewItem (pcclick^.rkey, @ItemData) then exit;
                     str := GetItemDataInfo (ItemData);
                     SendClass.SendChatMessage (str, SAY_COLOR_NORMAL);
                  end;
               WINDOW_SCREEN :
                  begin
                     if pcclick^.rclickedId <> 0 then begin
                        if IsObjectItemID (pcclick^.rclickedid) then begin
                           FillChar (ComData, SizeOf (TCDragDrop) + SizeOf (Word), 0);
                           ComData.Size := SizeOf (TCDragDrop);
                           pcDragDrop := @ComData.Data;
                           pcDragDrop^.rmsg := CM_DRAGDROP;
                           pcDragDrop^.rsourwindow := WINDOW_SCREEN;
                           pcDragDrop^.rdestwindow := WINDOW_ITEMS;
                           pcDragDrop^.rsourId := pcclick^.rclickedid;
                           DragProcess (ComData);
                        end else begin
                           SendLocalMessage (pcclick^.rclickedId, FM_CLICK, BasicData, SubData);
                           SendClass.SendChatMessage (GetWordString (SubData.SayString), SAY_COLOR_SYSTEM);
                        end;
                     end;
                  end;
               else exit;
            end;
         end;
      CM_HIT :
         begin
            if SpecialWindow <> WINDOW_NONE then exit;
            
            if CM_MessageTick[CM_HIT] + 50 > CurTick then exit;
            CM_MessageTick[CM_HIT] := CurTick;

            if boCanAttack = false then exit;
            if Manager.boHit = false then exit;
            
            pchit := @Code.Data;
            if pcHit^.rkey <> BasicData.dir then CommandTurn (pcHit^.rkey, FALSE);
            if HaveMagicClass.pCurAttackMagic = nil then exit;
            case HaveMagicClass.pCurAttackMagic^.rMagicType of
               MAGICTYPE_BOWING, MAGICTYPE_THROWING :
                  begin
                     CommandBowing (mmAnsTick, pcHit^.rtid, pcHit^.rtx, pcHit^.rty, FALSE);
                  end;
               else
                  begin
                     CommandHit (mmAnsTick, FALSE);
                  end;
            end;
         end;
{
      CM_CLICKPERCENT:
         begin
            if CM_MessageTick[CM_CLICKPERCENT] + 50 > CurTick then exit;
            CM_MessageTick[CM_CLICKPERCENT] := CurTick;

            pcClick := @Code.Data;
            case pcclick^.rwindow of
               WINDOW_BASICFIGHT:
                  begin
                     HaveMagicClass.SetDefaultMagicPercent (pcclick^.rkey, pcclick^.rclickedId);
                  end;
               WINDOW_MAGICS:
                  begin
                     HaveMagicClass.SetHaveMagicPercent (pcclick^.rkey, pcclick^.rclickedId);
                  end;
               WINDOW_SCREEN :;
               else exit;
            end;
         end;
}
      CM_KEYDOWN :
         begin
            if CM_MessageTick[CM_KEYDOWN] + 30 > CurTick then exit;
            CM_MessageTick[CM_KEYDOWN] := CurTick;

            pckey := @Code.Data;
            case pckey^.rkey of
               VK_F2 :
                  begin
                     if BasicData.Feature.rfeaturestate = wfs_normal then CommandChangeCharState (wfs_care, FALSE)
                     else CommandChangeCharState (wfs_normal, FALSE)
                  end;
               VK_F3 : CommandChangeCharState (wfs_sitdown, FALSE);
               VK_F4 :
                  begin
                     if BasicData.Feature.rFeatureState = wfs_normal then begin
                        SubData.motion := AM_HELLO;
                        SendLocalMessage ( NOTARGETPHONE, FM_MOTION, BasicData, SubData);
                     end;
                  end;
               VK_F5 :;
               VK_F6 :;
               VK_F7 :;
               VK_F8 :;
            end;
            if BasicData.Feature.rFeaturestate = wfs_normal then SetTargetId (0);
         end;
      CM_TURN :
         begin
            if SpecialWindow <> WINDOW_NONE then exit;

            pckey := @Code.Data;
            BasicData.dir := pckey^.rkey;
            SendLocalMessage ( NOTARGETPHONE, FM_TURN, BasicData, SubData);
         end;
      CM_MOVE :
         begin
            if SpecialWindow <> WINDOW_NONE then exit;

            // Lan Cable 阑 UnPlug 茄盲 捞悼窍绰 巴阑 阜扁 困茄 内靛
            // if CM_MessageTick[CM_MOVE] + 10 > CurTick then exit;
            CM_MessageTick[CM_MOVE] := CurTick;

            pcMove := @Code.data;
            if (boCanMove = false) or (pcMove^.rx <> BasicData.x) or (pcMove^.ry <> basicData.y) then begin SendClass.SendSetPosition (BasicData); exit; end;

            xx := BasicData.x; yy := BasicData.y;
            GetNextPosition ( pcMove^.rdir, xx, yy);
            if Maper.isMoveable (xx, yy) then begin
               {
               if BasicData.dir <> pcMove^.rdir then begin
                  BasicData.dir := pcMove^.rdir;
                  SendLocalMessage ( NOTARGETPHONE, FM_TURN, BasicData, SubData);
               end;
               }
               BasicData.nx := xx;
               BasicData.ny := yy;
               Phone.SendMessage ( NOTARGETPHONE, FM_MOVE, BasicData, SubData);
               Maper.MapProc (BasicData.id, MM_MOVE, BasicData.x, basicData.y, xx, yy, BasicData);
               BasicData.dir := pcMove^.rdir;
               BasicData.x := xx; BasicData.y := yy;
               HaveMagicClass.AddWalking;
            end else begin
               BasicData.dir := pcMove^.rdir;
               SendLocalMessage ( NOTARGETPHONE, FM_TURN, BasicData, SubData);
               SendClass.SendSetPosition(BasicData);
            end;
         end;
      CM_SAY :
         begin
            if CM_MessageTick[CM_SAY] + 50 > CurTick then exit;
            CM_MessageTick[CM_SAY] := CurTick;

            if boCanSay = false then exit;

            pcSay := @Code.Data;
            str := GetWordString (pcSay^.rWordString);
            UserSay (str);
         end;
      CM_WINDOWCONFIRM :
         begin
            pcWindowConfirm := @Code.Data;
            if pcWindowConfirm^.rWindow <> SpecialWindow then exit;

            Case SpecialWindow of
               WINDOW_ITEMLOG :
                  begin
                     if pcWindowConfirm^.rboCheck = true then begin
                        for i := 0 to 4 - 1 do begin
                           if ItemLogData[i].Header.boUsed = true then begin
                              ItemLog.SetLogRecord (Name, i, ItemLogData[i]);
                           end;
                           ItemLogData[i].Header.boUsed := false;
                        end;
                        if CopyHaveItem <> nil then begin
                           HaveItemClass.CopyFromHaveItemClass (CopyHaveItem);
                        end;
                     end else begin
                        for i := 0 to 4 - 1 do begin
                           ItemLogData[i].Header.boUsed := false;
                        end;
                     end;

                     HaveItemClass.Locked := false;
                     WearItemClass.Locked := false;

                     HaveItemClass.Refresh;

                     if CopyHaveItem <> nil then begin
                        CopyHaveItem.Free;
                        CopyHaveItem := nil;
                     end;
                  end;
               WINDOW_ALERT :
                  begin
                  end;
            end;
            SpecialWindow := WINDOW_NONE;
         end;
      CM_MAKEGUILDMAGIC :
         begin
            SpecialWindow := WINDOW_NONE;
            if GuildName = '' then exit;
            GuildObject := GuildList.GetGuildObject (GuildName);
            if GuildObject = nil then exit;
            if GuildObject.IsGuildSysop (Name) = false then begin
               SendClass.SendChatMessage ('门主才拥有申请门派武功权力.', SAY_COLOR_SYSTEM);
               exit;
            end;
            if GuildObject.GetGuildMagicString <> '' then begin
               SendClass.SendChatMessage ('已经申请过门派武功了.', SAY_COLOR_SYSTEM);
               exit;
            end;

            ItemClass.GetItemData ('金币', ItemData);
            if ItemData.rName [0] = 0 then exit;
            ItemData.rCount := 40;
            if FindItem (@ItemData) = false then begin
               SendClass.SendChatMessage ('申请门派武功需要40个金币.', SAY_COLOR_SYSTEM);
               exit;
            end;

            pcGuildMagicData := PTCGuildMagicData (@Code.Data);

            FillChar (MagicData, SizeOf (TMagicData), 0);
            StrPCopy (@MagicData.rName, pcGuildMagicData^.rMagicName);
            MagicData.rGuildMagicType := 1;
            MagicData.rMagicType := pcGuildMagicData^.rMagicType;
            MagicData.rShape := MagicData.rMagicType + 1;
            MagicData.rSkillExp := 100;
            MagicData.rLifeData.damageBody := pcGuildMagicData^.rDamageBody;
            MagicData.rLifeData.damageHead := pcGuildMagicData^.rDamageHead;
            MagicData.rLifeData.damageArm := pcGuildMagicData^.rDamageArm;
            MagicData.rLifeData.damageLeg := pcGuildMagicData^.rDamageLeg;
            MagicData.rLifeData.ArmorBody := pcGuildMagicData^.rArmorBody;
            MagicData.rLifeData.ArmorHead := pcGuildMagicData^.rArmorHead;
            MagicData.rLifeData.ArmorArm := pcGuildMagicData^.rArmorArm;
            MagicData.rLifeData.ArmorLeg := pcGuildMagicData^.rArmorLeg;
            MagicData.rLifeData.AttackSpeed := pcGuildMagicData^.rSpeed;
            MagicData.rLifeData.Recovery := pcGuildMagicData^.rRecovery;
            MagicData.rLifeData.Avoid := pcGuildMagicData^.rAvoid;
            MagicData.rEventDecInPower := pcGuildMagicData^.rInPower;
            MagicData.rEventDecOutPower := pcGuildMagicData^.rOutPower;
            MagicData.rEventDecMagic := pcGuildMagicData^.rMagicPower;
            MagicData.rEventDecLife := pcGuildMagicData^.rLife;

            if MagicClass.CheckMagicData (MagicData, Str) = false then begin
               SendClass.SendChatMessage (Str, SAY_COLOR_SYSTEM);
               exit;
            end;

            if MagicClass.AddGuildMagic (MagicData, GuildName) = false then begin
               SendClass.SendChatMessage ('无法添加门派武功.', SAY_COLOR_SYSTEM);
               exit;
            end;

            GuildObject := GuildList.GetGuildObject (GuildName);
            if GuildObject = nil then begin
               SendClass.SendChatMessage ('无法搜索到加入的门派.', SAY_COLOR_SYSTEM);
               exit;
            end;

            if DeleteItem (@ItemData) = false then exit;
            GuildObject.AddGuildMagic (pcGuildMagicData^.rMagicName);

            SendClass.SendChatMessage (format ('%s门派武功是%s.', [GuildName, pcGuildMagicData^.rMagicName]), SAY_COLOR_SYSTEM);
         end;
   end;
   except
      frmMain.WriteLogInfo (format ('TUser(%s).MessageProcess () failed', [Name]));
      frmMain.WriteDumpInfo (@Code, SizeOf (TWordComData));
      frmMain.WriteDumpInfo (@BasicData, SizeOf (TBasicData));
   end;
end;

function  TUser.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i, Key : Integer;
   str : string;
   per : integer;
   ItemData : TItemData;
   SubData : TSubData;
   ExChangeUser : TUser;
   SaveHideState : THiddenState;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   if SysopObj <> nil then begin
      TUser(SysopObj).FieldProc2 (hfu, Msg, SenderInfo, aSubData);
   end;

   if (botv = true) and (Msg <> FM_SAY) then exit;

   case Msg of
      FM_LIFEPERCENT :
         begin
            SendClass.SendStructed (SenderInfo, aSubData.percent);
         end;
      FM_KILL :
         begin
            if BasicData.Feature.rFeatureState <> wfs_die then exit;
            ShowEffect (8, lek_follow);

            BasicData.nX := BasicData.X;
            BasicData.nY := BasicData.Y;
            SubData.ServerId := Manager.ServerID;
            for i := 0 to 10 - 1 do begin
               Key := Random (HAVEITEMSIZE);
               HaveItemClass.ViewItem (Key, @SubData.ItemData);
               if SubData.ItemData.rName [0] <> 0 then begin
                  if Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData) = PROC_TRUE then begin
                     HaveItemClass.DeleteKeyItem (Key, SubData.ItemData.rCount, @SubData.ItemData);
                     exit;
                  end;
               end;
            end;
            for i := 0 to 30 - 1 do begin
               HaveItemClass.ViewItem (i, @SubData.ItemData);
               if SubData.ItemData.rName [0] <> 0 then begin
                  if Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData) = PROC_TRUE then begin
                     HaveItemClass.DeleteKeyItem (i, SubData.ItemData.rCount, @SubData.ItemData);
                     exit;
                  end;
               end;
            end;
         end;
      FM_REFILL :
         begin
            if hfu = BasicData.id then begin
               AttribClass.CurAttribData.CurEnergy := AttribClass.AttribData.cEnergy;
               AttribClass.CurAttribData.CurInPower := AttribClass.AttribData.cInPower;
               AttribClass.CurAttribData.CurOutPower := AttribClass.AttribData.cOutPower;
               AttribClass.CurAttribData.CurMagic := AttribClass.AttribData.cMagic;
               AttribClass.CurAttribData.CurLife := AttribClass.AttribData.cLife;
               AttribClass.CurAttribData.CurHeadSeak := AttribClass.AttribData.cHeadSeak;
               AttribClass.CurAttribData.CurArmSeak := AttribClass.AttribData.cArmSeak;
               AttribClass.CurAttribData.CurLegSeak := AttribClass.AttribData.cLegSeak;
               DiedTick := 0;
               SendClass.SendAttribBase (AttribClass.AttribData, AttribClass.CurAttribData);
               SendClass.SendAttribValues (AttribClass.AttribData, AttribClass.CurAttribData);
            end;
         end;
      FM_SHOWEXCHANGE :
         begin
            ExChangeUser := TUser (SendLocalMessage ( SenderInfo.id, FM_GIVEMEADDR, BasicData, SubData));
            if (Integer (ExChangeUser) = 0) or (integer(ExChangeUser) = -1) then exit;

            SendClass.SendShowExChange (@ExChangedata, @ExchangeUser.ExChangeData);
         end;
      FM_CANCELEXCHANGE :
         begin
            FillChar (ExChangeData, sizeof(ExChangeData), 0);
            SendClass.SendCancelExChange;
            Result := PROC_TRUE;
         end;

      FM_ENOUGHSPACE :
         begin
            if HaveItemClass.FreeSpace >= 1 then begin Result := PROC_TRUE; exit; end;
         end;
      FM_GATE :
         begin
            if hfu <> BasicData.id then exit;

            PosMoveX := SenderInfo.nx;
            PosMoveY := SenderInfo.ny;
            if ServerID <> aSubData.ServerId then begin
               ServerID := aSubData.ServerId;
               boNewServer := TRUE;
            end;
         end;
      FM_SOUND :
         begin
            SendClass.SendSoundEffect (GetWordString (aSubData.SayString), SenderInfo.x, SenderInfo.y);
         end;
      FM_SAYUSEMAGIC : SendClass.SendSayUseMagic (SenderInfo, GetWordString (aSubData.SayString) );
      FM_SAY   : SendClass.SendSay (SenderInfo, GetWordString (aSubData.SayString) );
      FM_SHOUT : SendClass.SendChatMessage (GetWordString(aSubData.SayString), SAY_COLOR_SHOUT);
      FM_SHOW  :
         begin
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SaveHideState := SenderInfo.Feature.rHideState;
               SenderInfo.Feature.rHideState := hs_100;
            end;
            SendClass.SendShow (SenderInfo);
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SenderInfo.Feature.rHideState := SaveHideState;
            end;
         end;
      FM_HIDE  :
         begin
            SendClass.SendHide (SenderInfo);
         end;
      FM_STRUCTED :
         begin
            if SenderInfo.Feature.rRace <> RACE_DYNAMICOBJECT then begin
               SendClass.SendMotion (SenderInfo.id, AM_STRUCTED);
            end;
            SendClass.SendStructed (SenderInfo, aSubData.percent);
         end;
      FM_CHANGEFEATURE :
         begin
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SaveHideState := SenderInfo.Feature.rHideState;
               SenderInfo.Feature.rHideState := hs_100;
            end;
            SendClass.SendChangeFeature (SenderInfo);
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SenderInfo.Feature.rHideState := SaveHideState;
            end;
         end;
      FM_CHANGEPROPERTY :
         begin
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SaveHideState := SenderInfo.Feature.rHideState;
               SenderInfo.Feature.rHideState := hs_100;
            end;
            SendClass.SendChangeProperty (SenderInfo);
            if UseSkillKind = ITEM_KIND_SHOWSKILL then begin
               SenderInfo.Feature.rHideState := SaveHideState;
            end;
         end;
      FM_ADDATTACKEXP  :
         begin
            per := AttribClass.CurArmLife * 100 div AttribClass.MaxLife;
            if per <= 50 then begin
               SendClass.SendChatMessage ('因为攻击力太弱而没能得到经验值.',SAY_COLOR_SYSTEM);
            end else begin
               LastGainExp := HaveMagicClass.AddAttackExp (aSubData.ExpData.ExpType, aSubData.ExpData.Exp);
            end;
         end;
      FM_ADDPROTECTEXP  : HaveMagicClass.AddProtectExp (aSubData.ExpData.ExpType, aSubData.ExpData.Exp);
      FM_MOTION : if SenderInfo.id <> BasicData.id then SendClass.SendMotion (SenderInfo.id, aSubData.motion);
      FM_TURN   : if SenderInfo.id <> BasicData.id then SendClass.SendTurn (SenderInfo);
      FM_MOVE   : if SenderInfo.id <> BasicData.id then SendClass.SendMove (SenderInfo);
      FM_SYSOPMESSAGE : if SysopScope > aSubData.SysopScope then SendClass.SendChatMessage (GetWordString (aSubData.SayString), SAY_COLOR_SYSTEM);
      FM_ADDITEM :
         begin
            str := StrPas (@aSubData.ItemData.rName);
            if str = INI_ROPE then begin
               if BasicData.Feature.rFeatureState = wfs_die then begin
                  RopeTarget := SenderInfo.id;
                  RopeTick := mmAnsTick;
                  Result := PROC_TRUE;
                  exit;
               end;
            end;
            if HaveItemClass.AddItem (@aSubData.ItemData) then Result := PROC_TRUE;
         end;
      FM_DELITEM : if HaveItemClass.DeleteItem (@aSubData.ItemData) then Result := PROC_TRUE;
      FM_DELKEYITEM :
         begin
            if HaveItemClass.DeleteKeyItem (aSubData.TargetId, aSubData.VassalCount, @aSubData.ItemData) then Result := PROC_TRUE;
         end;
      FM_BOW : SendClass.SendShootMagic (SenderInfo, aSubData.TargetId, aSubData.tx, aSubData.ty, aSubData.BowImage, aSubData.BowSpeed, aSubData.BowType);
   end;
end;

function  TUser.FieldProc2 (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
begin
   Result := PROC_FALSE;
   case Msg of
      FM_SOUND :
         begin
            SendClass.SendSoundEffect (GetWordString (aSubData.SayString), SenderInfo.x, SenderInfo.y );
         end;
      FM_SAYUSEMAGIC : SendClass.SendSayUseMagic (SenderInfo, GetWordString (aSubData.SayString) );
      FM_SAY   : SendClass.SendSay (SenderInfo, GetWordString (aSubData.SayString) );
      FM_SHOUT : SendClass.SendChatMessage (GetWordString(aSubData.SayString), SAY_COLOR_SHOUT);
      FM_SHOW  : SendClass.SendShow (SenderInfo);
      FM_HIDE  : SendClass.SendHide (SenderInfo);
      FM_STRUCTED      :
         begin
            if SenderInfo.Feature.rRace <> RACE_DYNAMICOBJECT then begin
               SendClass.SendMotion (SenderInfo.id, AM_STRUCTED);
            end;
            SendClass.SendStructed (SenderInfo, aSubData.percent);
         end;
      FM_CHANGEFEATURE : SendClass.SendChangeFeature (SenderInfo);
      FM_CHANGEPROPERTY : SendClass.SendChangeProperty (SenderInfo);
      FM_MOTION : SendClass.SendMotion (SenderInfo.id, aSubData.motion);
      FM_TURN   : SendClass.SendTurn (SenderInfo);
      FM_MOVE   : SendClass.SendMove (SenderInfo);
      FM_BOW : SendClass.SendShootMagic (SenderInfo, aSubData.TargetId, aSubData.tx, aSubData.ty, aSubData.BowImage, aSubData.BowSpeed, aSubData.BowType);
   end;
end;

procedure TUser.Update (CurTick: integer);
var
   i, cnt : integer;
   iCnt : Word;
   ComData : TWordComdata;
   GMD : TGMData;
   SubData : TSubData;
   BObject : TBasicObject;
   tmpManager : TManager;
begin
   if boException = true then exit;
   
   inherited UpDate (CurTick);

   if Connector.ReceiveBuffer.Count > 0 then begin
      while true do begin
         if Connector.ReceiveBuffer.Get (@ComData) = false then break;
         MessageProcess (ComData);
      end;
   end;

   // 胶乔靛 琴 规瘤甫 困秦辑 付访茄 菩哦
   if CurTick >= NetStateTick + 500 then begin
      SendClass.SendNetState (NetStateID, CurTick);
      Inc (NetStateID);
      NetStateTick := CurTick; 
   end;

   if boNewServer then begin
      boNewServer := FALSE;
      if (PosMoveX <> -1) and (PosMoveY <> -1) then begin
         Phone.SendMessage (NOTARGETPHONE, FM_DESTROY, BasicData, SubData);
         Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

         if ServerID <> Manager.ServerID then begin
            tmpManager := ManagerList.GetManagerByServerID (ServerId);
            if tmpManager <> nil then begin
               SetManagerClass (tmpManager);
               AttribClass.SetAddExpFlag := tmpManager.boGetExp;
               HaveMagicClass.SetAddExpFlag := tmpManager.boGetExp;
               if tmpManager.RegenInterval > 0 then begin
                  DisplayValue := 0;
                  DisplayTick := -1;
               end;
            end else begin
               frmMain.WriteLogInfo (format ('Manager = nil (%s, %d, %d, %d)', [Name, ServerID, PosMoveX, PosMoveY]));
            end;
         end;

         if Maper.GetMoveableXy (PosMoveX, PosMoveY, 10) = false then begin
            frmMain.WriteLogInfo (format ('FM_GATE NewServer Error (%s, %d, %d, %d)', [Name, ServerID, PosMoveX, PosMoveY]));
         end;

         BasicData.x := PosMoveX; BasicData.y := PosMoveY;
         PosMoveX := -1; PosMoveY := -1;

         SendClass.SendMap (BasicData, Manager.MapName, Manager.ObjName, Manager.RofName, Manager.TilName, Manager.SoundBase);
         Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
         Phone.SendMessage (NOTARGETPHONE, FM_CREATE, BasicData, SubData);

         if BasicData.Feature.rfeaturestate = wfs_die then begin
            Maper.MapProc (BasicData.Id, MM_HIDE, BasicData.x, BasicData.y, BasicData.x, BasicData.y, BasicData);
         end;
      end;
   end else begin
      if (Connector.BattleState <> bcs_gotobattle) and (PosMovex <> -1) and (PosMoveY <> -1) then begin
         Phone.SendMessage (NOTARGETPHONE, FM_DESTROY, BasicData, SubData);
         Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

         if Maper.GetMoveableXy (PosMoveX, PosMoveY, 10) = false then begin
            frmMain.WriteLogInfo (format ('FM_GATE GetMoveableXY Error (%s, %d, %d, %d)', [Name, ServerID, PosMoveX, PosMoveY]));
         end;
         
         BasicData.x := PosMoveX; BasicData.y := PosMoveY;
         PosMoveX := -1; PosMoveY := -1;
         
         SendClass.SendMap (BasicData, Manager.MapName, Manager.ObjName, Manager.RofName, Manager.TilName, Manager.SoundBase);
         Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
         Phone.SendMessage (NOTARGETPHONE, FM_CREATE, BasicData, SubData);
      end;
   end;

   if Manager.boPrison = true then begin
      if PrisonTick + 6000 <= CurTick then begin
         PrisonTick := CurTick;
         if PrisonClass.IncreaseElaspedTime (Name, 1) <= 0 then begin
            ServerID := Manager.TargetServerID;
            PosMoveX := Manager.TargetX;
            PosMoveY := Manager.TargetY;
            boNewServer := true;
            SendClass.SendChatMessage ('从流配地释放出来了.', SAY_COLOR_NORMAL);
            SendClass.SendChatMessage ('请遵守游戏法则,避免再次被囚禁.', SAY_COLOR_NORMAL);
            exit;
         end;
      end;
   end;

   if CurTick >= SaveTick + 10 * 60 * 100 then begin
      SaveTick := CurTick;
      SaveUserData (Name);
      WearItemClass.SaveToSdb (@Connector.CharData);
      HaveItemClass.SaveToSdb (@Connector.CharData);
      AttribClass.SaveToSdb (@Connector.CharData);
      HaveMagicClass.SaveToSdb (@Connector.CharData);
   end;

   {
   if MailBox.Count > 0 then begin
      if MailTick + 10 * 100 <= CurTick then begin
         pd := MailBox.Items[0];
         if pd <> nil then begin
            SendClass.SendChatMessage (format ('%s传了一个纸条给你.',[StrPas(@pd^.rSender)]), SAY_COLOR_SYSTEM);
            SendClass.SendChatMessage ('请输入 [@确认纸条] 来确认.', SAY_COLOR_NORMAL);
            SendClass.SendChatMessage ('请输入 [@删除纸条] 来删除.', SAY_COLOR_NORMAL);
         end else begin
            MailBox.Delete (0);
         end;
         MailTick := CurTick;
      end;
   end;
   }

   if Manager.RegenInterval > 0 then begin
      if LifeObjectState <> los_die then begin
         if (DisplayTick = -1) or (DisplayTick + 100 < CurTick) then begin
            if (Manager.RemainHour = 0) and (Manager.RemainMin = 0) then begin
               if Manager.RemainSec <> DisplayValue then begin
                  DisplayValue := Manager.RemainSec;
                  SendClass.SendChatMessage (format ('剩下 %d 秒.', [DisplayValue]), SAY_COLOR_SYSTEM);
                  {
                  if (DisplayValue = 0) and (SysopScope < 100) then begin
                     CommandChangeCharState (wfs_die, FALSE);
                  end;
                  }
               end;
            end else begin
               if Manager.RemainMin <> DisplayValue then begin
                  DisplayValue := Manager.RemainMin;
                  SendClass.SendChatMessage (format ('剩下 %d 分.', [DisplayValue]), SAY_COLOR_SYSTEM);
               end;
            end;
         end;
      end;
   end;

   if UseSkillKind <> -1 then begin
      if SkillUsedTick + SkillUsedMaxTick <= CurTick then begin
         cnt := UseSkillKind;
         UseSkillKind := -1;
         SkillUsedTick := 0;
         SkillUsedMaxTick := 0;
      
         Case cnt of
            ITEM_KIND_HIDESKILL :
               begin
                  WearItemClass.SetHiddenState (hs_100);
                  SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
               end;
            ITEM_KIND_SHOWSKILL :
               begin
                  SetTargetID (0);
                  for i := 0 to ViewObjectList.Count - 1 do begin
                     BObject := ViewObjectList.Items [i];
                     if BObject.BasicData.Feature.rHideState = hs_0 then begin
                        SendLocalMessage (BasicData.ID, FM_CHANGEFEATURE, BObject.BasicData, SubData);
                     end;
                  end;
               end;
         end;
      end;
   end;
end;

procedure TUser.AddRefusedUser (aName : String);
var
   i : Integer;
begin
   if RefuseReceiver.Count >= 5 then begin
      SendClass.SendChatMessage ('无法传递纸条.', SAY_COLOR_SYSTEM); 
      exit;
   end;

   for i := 0 to RefuseReceiver.Count - 1 do begin
      if RefuseReceiver.Strings[i] = aName then exit;
   end;

   RefuseReceiver.Add (aName);
end;

procedure TUser.DelRefusedUser (aName : String);
var
   i : Integer;
begin
   for i := 0 to RefuseReceiver.Count - 1 do begin
      if RefuseReceiver.Strings[i] = aName then begin
         RefuseReceiver.Delete (i);
         exit;
      end;
   end;
end;

procedure TUser.AddMailSender (aName : String);
begin
   if CheckSenderList (aName) = True then exit;
   if MailSender.Count >= MailSenderLimit then begin
      MailSender.Delete (MailSender.Count - 1);
      MailSender.Insert (0, aName);
   end else begin
      MailSender.Add (aName);
   end;
end;

function TUser.CheckSenderList (aName : String) : Boolean;
var
   i : Integer;
begin
   Result := False;
   for i := 0 to MailSender.Count - 1 do begin
      if MailSender.Strings[i] = aName then begin
         Result := True;
         Exit;
      end;
   end;
end;

procedure TUser.SetPosition (x, y : Integer);
begin
   PosMoveX := x;
   PosMoveY := y;
end;

procedure TUser.SetPositionBS (ex, ey : Integer);
begin
   PosMoveX := ex;
   PosMoveY := ey;
   Connector.BattleState := bcs_gotobattle;
end;

function TUser.MovingStatus : Boolean;
begin
   Result := false;
   if (PosMoveX <> -1) or (PosMoveY <> -1) then begin
      Result := true;
   end;
end;

function TUser.ShowItemLogWindow : String;
var
   i, j, n : Integer;
   ItemData : TItemData;
begin
   Result := '';

   if ItemLog.Enabled = false then begin
      Result := '无法使用储存物品的功能.';
      exit;
   end;
   if SpecialWindow <> 0 then begin
      Result := '请关闭开启的窗口.';
      exit;
   end;
   if ExChangeData.rExChangeId <> 0 then begin
      Result := '请关闭开启的窗口.';
      exit;
   end;

   n := ItemLog.GetRoomCount (Name);
   if n <= 0 then begin
      Result := format ('%s没有储存空间,请使用福袋增加储存空间.', [Name]);
      exit;
   end;
   if n > 4 then n := 4;

   if ItemLog.isLocked (Name) = true then begin
      Result := format ('%s的保管窗有密码设定.', [Name]);
      exit;
   end;

   for i := 0 to n - 1 do begin
      if ItemLog.GetLogRecord (Name, i, ItemLogData[i]) = false then begin
         Result := '发生未知错误,保管窗被取消.';
         exit;
      end;
   end;

   if CopyHaveItem <> nil then CopyHaveItem.Free;
   CopyHaveItem := THaveItemClass.Create (SendClass, nil);
   CopyHaveItem.CopyFromHaveItemClass (HaveItemClass);

   HaveItemClass.Locked := true;
   WearItemClass.Locked := true;

   SpecialWindow := WINDOW_ITEMLOG;
   SendClass.SendShowSpecialWindow (WINDOW_ITEMLOG, '物品保管窗', '将物品移动到DRAG&DROP后,请按[确认]键.');
   for i := 0 to n - 1 do begin
      for j := 0 to 10 - 1 do begin
         ItemClass.GetItemData (StrPas (@ItemLogData[i].ItemData[j].Name), ItemData);
         ItemData.rColor := ItemLogData[i].ItemData[j].Color;
         ItemData.rCount := ItemLogData[i].ItemData[j].Count;
         SendClass.SendLogItem (i * 10 + j, ItemData);
      end;
   end;
end;

procedure TUser.UdpSendMouseEvent (aInfoStr: String);
var
   cnt : integer;
   usd: TStringData;
begin
   usd.rmsg := 1;
   SetWordString (usd.rWordString, ainfostr);
   cnt := sizeof(usd) - sizeof(TWordString) + sizeofwordstring (usd.rwordstring);
   FrmSockets.UdpSendMouseInfo (cnt, @usd);
end;


////////////////////////////////////////////////////
//
//             ===  UserList  ===
//
////////////////////////////////////////////////////

constructor TUserList.Create (cnt: integer);
begin
   CurProcessPos := 0;
   UserProcessCount := 0;
   
   ExceptCount := 0;
   // TvList := TList.Create;
   // AnsList := TAnsList.Create (cnt, AllocFunction, FreeFunction);
   DataList := TList.Create;
   NameKey := TStringKeyClass.Create;
end;

destructor TUserList.Destroy;
var
   i : Integer;
   User : TUser;
begin
   // AnsList.Free;
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      User.Free;
   end;
   DataList.Clear;
   DataList.Free;
   
   NameKey.Free;
   // TvList.Free;
   inherited destroy;
end;

function TUserList.InitialLayer (aCharName: string; aConnector : TConnector) : Boolean;
var
   i : Integer;
   User : TUser;
   tmpManager : TManager;
   ServerID : Integer;
   xx, yy : Word;
   rStr : String;
begin
   Result := false;

   if NameKey.Select (aCharName) <> nil then exit;

   User := TUser.Create;

   User.Connector := aConnector;
   User.SysopScope := SysopClass.GetSysopScope (aCharName);

   tmpManager := nil;
   rStr := PrisonClass.GetUserStatus (aCharName);
   if rStr <> '' then begin
      User.ServerID := User.Connector.CharData.ServerID;
      for i := 0 to ManagerList.Count - 1 do begin
         tmpManager := ManagerList.GetManagerByIndex (i);
         if tmpManager.boPrison = true then begin
            if User.ServerID <> tmpManager.ServerID then begin
               ServerID := tmpManager.ServerID;
               User.ServerID := ServerID;
               User.Connector.CharData.ServerID := ServerID;
               User.Connector.CharData.X := 61;
               User.Connector.CharData.Y := 77;
            end;
            break;
         end;
         tmpManager := nil;
      end;
   end;

   if tmpManager = nil then begin
      ServerID := User.Connector.CharData.ServerID;
      tmpManager := ManagerList.GetManagerByServerID (ServerID);
      if tmpManager <> nil then begin
         if (tmpManager.RegenInterval > 0) and (User.SysopScope < 100) then begin
            ServerID := tmpManager.TargetServerID;
            User.Connector.CharData.ServerID := ServerID;
            User.Connector.CharData.X := tmpManager.TargetX;
            User.Connector.CharData.Y := tmpManager.TargetY;
            tmpManager := ManagerList.GetManagerByServerID (ServerID);
         end;
      end else begin
         ServerID := 1;
         tmpManager := ManagerList.GetManagerByServerID (ServerID);
      end;
   end;

   User.SetManagerClass (tmpManager);
   User.AttribClass.SetAddExpFlag := tmpManager.boGetExp;
   User.HaveMagicClass.SetAddExpFlag := tmpManager.boGetExp;

   Result := User.InitialLayer (aCharName);
   
   User.Initial (aCharName);
   
   NameKey.Insert (aCharName, User);
   DataList.Add (User);

   Result := true;
end;

procedure   TUserList.StartChar (aCharname: string);
var
   User : TUser;
begin
   User := NameKey.Select (aCharName);
   if User <> nil then begin
      User.StartProcess;
      exit;
   end;
   frmMain.WriteLogInfo ('TUserList.StartChar () failed');
end;

// procedure TUserList.FinalLayer (aCharName: string);
procedure TUserList.FinalLayer (aConnector : TConnector);
var
   i : integer;
   Name : String;
   User : TUser;
begin
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.Connector = aConnector then begin
         Name := User.Name;
         User.FinalLayer;
         User.EndProcess;
         User.Free;
         DataList.Delete (i);
         NameKey.Delete (Name);
         exit;
      end;
   end;
   frmMain.WriteLogInfo ('TUserList.FinalLayer () failed');
end;

procedure  TUserList.SayByServerID (aServerID : Integer; aStr: String);
var
   i : integer;
   User : TUser;
begin
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.ServerID = aServerID then begin
         User.SendClass.SendChatMessage (aStr, SAY_COLOR_NORMAL);
      end;
   end;
end;

procedure TUserList.MoveByServerID (aServerID : Integer; aTargetID, aTargetX, aTargetY : Integer);
var
   i : integer;
   User : TUser;
begin
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.ServerID = aServerID then begin
         User.boNewServer := true;
         User.ServerID := aTargetID;
         User.PosMoveX := aTargetX;
         User.PosMoveY := aTargetY;
      end;
   end;
end;

procedure  TUserList.GuildSay (aGuildName, aStr: string);
var
   i : integer;
   User : TUser;
begin
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.GuildName = aGuildName then begin
         User.SendClass.SendChatMessage (aStr, SAY_COLOR_NORMAL);
      end;
   end;
end;


procedure  TUserList.SendNoticeMessage (aStr: String; aColor : Integer);
var
   ComData : TWordComData;
   cnt : integer;
   psChatMessage : PTSChatMessage;
begin
   psChatMessage := @ComData.Data;
   with psChatMessage^ do begin
      rmsg := SM_CHATMESSAGE;
      case aColor of
         SAY_COLOR_NORMAL : begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,0); end;
         SAY_COLOR_SHOUT  : begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,24); end;
         SAY_COLOR_SYSTEM : begin rFColor := WinRGB (22,22, 0); rBColor := WinRGB (0, 0 ,0); end;
         SAY_COLOR_NOTICE : begin rFColor := WinRGB (255 div 8, 255 div 8, 255 div 8); rBColor := WinRGB (133 div 8, 133 div 8, 133 div 8); end;

         SAY_COLOR_GRADE0 : begin rFColor := WinRGB (18, 16, 14); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE1 : begin rFColor := WinRGB (26, 23, 21); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE2 : begin rFColor := WinRGB (31, 29, 27); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE3 : begin rFColor := WinRGB (22, 18,  8); rBColor := WinRGB (1,4,11); end;
         SAY_COLOR_GRADE4 : begin rFColor := WinRGB (23, 13,  4); rBColor := WinRGB (1,4,11); end;
         SAY_COLOR_GRADE5 : begin rFColor := WinRGB (31, 29, 21); rBColor := WinRGB (1,4,11); end;

         else begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,0); end;
      end;

      SetWordString (rWordstring, aStr);
      ComData.Size := Sizeof(TSChatMessage) - Sizeof(TWordString) + sizeofwordstring(rWordString);
   end;

   GateConnectorList.AddSendDataForAll (@ComData, ComData.Size + SizeOf (Word));
end;

function TUserList.GetCount: integer;
begin
   Result := DataList.Count;
end;

function TUserList.GetUserList: string;
begin
   Result := format ('<现在使用者> %d 名.',[ConnectorList.Count]) + #13;
end;

function TUserList.GetUserPointer (aCharName: string): TUser;
begin
   Result := NameKey.Select (aCharName);
end;

function TUserList.GetUserPointerById (aId: LongInt): TUser;
var
   i : integer;
   User : TUser;
begin
   Result := nil;
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.BasicData.Id = aId then begin
         Result := User;
         exit;
      end;
   end;
end;


procedure TUserList.SendRaining (aRain : TSRainning);
var
   i : integer;
   User : TUser;
begin
   for i := 0 to DataList.Count -1 do begin
      User := DataList.Items [i];
      if User.Manager.boWeather = true then begin
         User.SendClass.SendRainning (aRain);
      end;
   end;
end;

procedure TUserList.Update (CurTick: integer);
var
   cnt : integer;
   pld : PTLeaveData;

   i, m : integer;
   Name : String;
   User : TUser;
   StartPos : integer;
begin
   UserProcessCount := (DataList.Count * 4 div 100);
   if UserProcessCount = 0 then UserProcessCount := DataList.Count;

   UserProcessCount := ProcessListCount;

   if DataList.Count > 0 then begin
      StartPos := CurProcessPos;
      for i := 0 to UserProcessCount - 1 do begin
         if CurProcessPos >= DataList.Count then CurProcessPos := 0;
         User := DataList.Items [CurProcessPos];
         try
            User.Update (CurTick);
         except
            User.Exception := true;
            Name := User.Name;
            frmMain.WriteLogInfo (format ('TUser.Update (%s) exception', [Name]));
            ConnectorList.CloseConnectByCharName (Name);
            exit;
         end;
         
         Inc (CurProcessPos);
         if CurProcessPos = StartPos then break;
      end;
   end;
end;

{
function TUserList.FieldProc2 (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i: integer;
   User : TUser;
begin
   Result := PROC_FALSE;
   for i := 0 to TvList.Count - 1 do begin
      User := TvList.Items [i];
      User.FieldProc2 (hfu, msg, SenderInfo, aSubdata);
   end;
end;
}

procedure TUserList.SaveUserInfo (aFileName : String);
var
   i : Integer;
   Stream : TFileStream;
   User : TUser;
   Str : String;
   buffer : array [0..1024] of char;
begin
   if FileExists (aFileName) then DeleteFile (aFileName);
   try
      Stream := TFileStream.Create (aFileName, fmCreate);
   except
      exit;
   end;

   Str := 'Name,MasterName,Guild,Map,X,Y,IpAddr,Ver,Pay' + #13#10;
   StrPCopy (@buffer, Str);
   Stream.WriteBuffer (buffer, StrLen (buffer));
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      Str := User.Name + ',' + User.Connector.LoginID + ',' + User.GuildName + ',' + User.Manager.Title + ',' + IntToStr (User.BasicData.X) + ',' + IntToStr (User.BasicData.Y) + ',';
      Str := Str + User.Connector.IpAddr + ',' + IntToStr (User.Connector.VerNo) + ',' + IntToStr (Byte(User.Connector.PaidType)) + #13#10;
      StrPCopy (@buffer, Str);
      Stream.WriteBuffer (buffer, StrLen (buffer));
   end;
   
   Stream.Free;
end;

procedure TUserList.SendSoundEffect (aManager : TManager; aSoundEffect : String);
var
   i : Integer;
   Manager : TManager;
   User : TUser;
begin
   for i := 0 to DataList.Count - 1 do begin
      User := DataList.Items [i];
      if User.Manager = aManager then begin
         User.SendClass.SendSoundEffect (aSoundEffect + '.wav', User.BasicData.X, User.BasicData.Y);
      end;
   end;
end;

end.

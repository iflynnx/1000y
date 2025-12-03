unit uGuild;

interface

uses
  Windows, Classes, SysUtils, svClass, subutil, uAnsTick, AnsUnit,
  BasicObj, FieldMsg, MapUnit, DefType, Autil32, uMonster, uGramerid, UUser,
  IniFiles, uLevelexp, uGuildSub, uManager, AnsStringCls, UserSDB;

const
   // DEC_GUILD_DURA_TICK = 200;
   DEC_GUILD_DURA_TICK = 500;

   // 2000.09.16 巩颇檬籍狼 郴备己 刘啊摹 5000栏肺 荐沥 by Lee.S.G
   // ADD_GUILD_DURA_BY_SYSOP = 4000;
   ADD_GUILD_DURA_BY_SYSOP = 5000;
   ADD_GUILD_DURA_BY_SUBSYSOP = 1000;
   DEC_GUILD_DURA_BY_HIT = 20;

   MAX_GUILD_DURA = 1100000;

   GUILDSTONE_IMAGE_NUMBER = 67;
   
   MAX_SUBSYSOP_COUNT = 3;
   MAX_GUILDNPC_COUNT = 5;
   MAX_GUILDWEAR_COUNT = 2;

type
   TGuildObject = class (TBasicObject)
   private
      FGuildName : String;
      FWarAlarmStr : String;
      FWarAlarmStartTick : Integer;
      FWarAlarmTick : Integer;
      
      SelfData : TCreateGuildData;

      GuildNpcList : TList;
      DieGuildNpcList : TList;
      GuildUserList : TGuildUserList;
      DuraTick : integer;

      boAddGuildMagic : Boolean;

      function    AddGuildNpc (aName : String; aX, aY : Integer; aSex : Byte): Boolean;
   protected
      procedure   Initial;
      procedure   StartProcess; override;
      procedure   EndProcess; override;
      function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
      function    GetUserGrade (uname: string): string;
      function    GetGuildNpcbyName (aname: string): integer;

   public
      constructor Create;
      destructor  Destroy; override;

      procedure   Clear;
      procedure   LoadFromFile (aGuildName: String);
      procedure   SaveToFile;

      procedure   GetGuildInfo (aUser: TUser);
      function    MoveStone (aServerID, ax, ay: integer) : Boolean;
      function    CreateStone (aSysopName : String; aServerID, ax, ay: integer) : Boolean;

      procedure   Update (CurTick: integer); override;

      function    IsGuildSysop (aName : String) : Boolean;
      function    IsGuildSubSysop (aName : String) : Boolean;
      function    IsGuildUser (aName : String) : Boolean;
      function    IsGuildNpc (aName : String) : Boolean;

      function    GetSelfData : PTCreateGuildData;
      function    GetGuildMagicString : String;
      function    GetInformation : String;

      procedure   AddGuildMagic (aMagicName : String);
      procedure   ChangeGuildNpcName (aOldName, aNewName : String);

      procedure   SetWarAlarm (aName, aStr : String);

      property    GuildName : String read FGuildName;
   end;

   TGuildList = class
   private
      CurProcessPos : Integer;
      DataList : TList;

      function    GetCount: Integer;
   public
      constructor Create;
      destructor  Destroy; override;

      procedure   Clear;

      procedure   LoadFromFile (aFileName : String);
      procedure   SaveToFile (aFileName : String);

      procedure   CompactGuild;

      // function    isGuildSysop (aGuildName, aName : String) : Boolean;
      procedure   AllowGuildName (gid: integer; aboAllow: Boolean; aGuildName, aSysopName: string);
      function    AllowGuildCondition (gname, uname: string): Boolean;
      function    AddGuildObject (aGuildName, aOwnerName : String; aServerID, aX, aY: integer): TGuildObject;
      function    GetUserGrade (aGuildName, uname: string): string;
      function    GetGuildServerID (aGuildName : String): Integer;
      procedure   GetGuildInfo (aGuildName: string; aUser: TUser);
      function    CheckGuildUser(aGuildName, aName : String) : Boolean;
      function    MoveStone (aGuildName : string; aServerID, ax, ay: integer) : Boolean;
      function    CreateStone (aGuildName, aSysopName : string; aServerID, ax, ay: integer) : Boolean;
      procedure   DeleteStone (aGuildName : String);

      function    GetGuildObject (aGuildName : String) : TGuildObject;
      function    GetGuildObjectByMagicName (aMagicName : String) : TGuildObject;
      function    GetCharInformation (aName : String) : String;
      function    GetInformation (aName : String) : String;

      procedure   Update (CurTick: integer);
      property    Count : integer read GetCount;
   end;

var
   GuildList : TGuildList;

implementation

uses
   SVMain, FSockets;

////////////////////////////////////////////////////
//
//             ===  GuildObject  ===
//
////////////////////////////////////////////////////

constructor TGuildObject.Create;
begin
   inherited Create;

   FGuildName := '';

   FWarAlarmStr := '';
   FWarAlarmTick := 0;
   FWarAlarmStartTick := 0;

   FillChar (SelfData, SizeOf (TCreateGuildData), 0);
   
   GuildNpcList := TList.Create;
   DieGuildNpcList := TList.Create;
   GuildUserList := TGuildUserList.Create;
end;

destructor  TGuildObject.Destroy;
begin
   Clear;
   GuildUserList.Free;
   GuildNpcList.Free;
   DieGuildNpcList.Free;

   inherited Destroy;
end;

procedure TGuildObject.Clear;
var
   i : Integer;
   GuildNpc : TGuildNpc;
begin
   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      GuildNpc.Free;
   end;
   DieGuildNpcList.Clear;
   
   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      GuildNpc.EndProcess;
      GuildNpc.Free;
   end;
   GuildNpcList.Clear;
   GuildUserList.Clear;
end;

function TGuildObject.GetSelfData : PTCreateGuildData;
begin
   Result := @SelfData;
end;

function TGuildObject.GetInformation : String;
var
   i : Integer;
   Str : String;
begin
   Result := '';

   Str := format ('<%s 门派信息>', [GuildName]) + #13;
   Str := Str + format ('门主: %s', [SelfData.Sysop]) + #13;
   for i := 0 to 3 - 1 do begin
      Str := Str + format ('副门主%d: %s', [i + 1, SelfData.SubSysop[i]]) + #13;
   end;
   Str := Str + format ('位置: %d,%d', [BasicData.X, BasicData.Y]) + #13;
   Str := Str + format ('耐久性: %d', [SelfData.Durability]) + #13;
   Str := Str + format ('门派武功: %s 修炼值: %d', [SelfData.GuildMagic, SelfData.MagicExp]) + #13;
   for i := 0 to 5 - 1 do begin
      Str := Str + format ('%s : %d,%d', [SelfData.GuildNpc[i].rName, SelfData.GuildNpc [i].rX, SelfData.GuildNpc [i].rY]) + #13;
   end;

   Result := Str;
end;

function TGuildObject.GetGuildMagicString : String;
begin
   Result := SelfData.GuildMagic;
end;

procedure TGuildObject.AddGuildMagic (aMagicName : String);
var
   GuildNpc : TGuildNpc;
begin
   GuildNpc := nil;
   SelfData.GuildMagic := aMagicName;
   SelfData.MagicExp := 100;
   if GuildNpcList.Count > 0 then begin
      GuildNpc := GuildNpcList.Items [0];
   end else if DieGuildNpcList.Count > 0 then begin
      GuildNpc := DieGuildNpcList.Items [0];
   end;
   if GuildNpc <> nil then begin
      GuildNpc.boMagicNpc := true;
      StrPCopy (@GuildNpc.BasicData.Guild, SelfData.GuildMagic);
      MagicClass.GetMagicData (SelfData.GuildMagic, GuildNpc.GuildMagicData, SelfData.MagicExp);
      GuildNpc.BocChangeProperty;
   end;
end;

function TGuildObject.IsGuildUser (aName : String) : boolean;
begin
   Result := GuildUserList.IsGuildUser(aName);
end;

function TGuildObject.IsGuildSysop (aName : String) : Boolean;
begin
   Result := false;
   if SelfData.Sysop = aName then Result := true;
end;

function TGuildObject.IsGuildSubSysop (aName : String) : Boolean;
var
   i : Integer;
begin
   Result := false;
   for i := 0 to 3 - 1 do begin
      if SelfData.SubSysop [i] = aName then begin
         Result := true;
         exit;
      end;
   end;
end;

function TGuildObject.IsGuildNpc (aName : String) : Boolean;
var
   i : Integer;
   GuildNpc : TGuildNpc;
begin
   Result := false;

   if aName = '' then exit;

   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      if GuildNpc.GuildNpcName = aName then begin
         Result := true;
         exit;
      end;
   end;
   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      if GuildNpc.GuildNpcName = aName then begin
         Result := true;
         exit;
      end;
   end;
end;

procedure TGuildObject.SaveToFile;
var
   i, j, nIndex : Integer;
   GuildNpc : TGuildNpc;
begin
   if SelfData.Name = '' then exit;

   FillChar (SelfData.GuildNpc, SizeOf (SelfData.GuildNpc), 0);
   nIndex := 0;
   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      if GuildNpc.boMagicNpc = true then begin
         SelfData.MagicExp := GuildNpc.GuildMagicData.rSkillExp;
         SelfData.GuildNpc[nIndex].rName := GuildNpc.GuildNpcName;
         SelfData.GuildNpc[nIndex].rX := GuildNpc.StartX;
         SelfData.GuildNpc[nIndex].rY := GuildNpc.StartY;
         SelfData.GuildNpc[nIndex].rSex := GuildNpc.Sex;
         Inc (nIndex);
      end;
   end;
   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      if GuildNpc.boMagicNpc = true then begin
         SelfData.MagicExp := GuildNpc.GuildMagicData.rSkillExp;
         SelfData.GuildNpc[nIndex].rName := GuildNpc.GuildNpcName;
         SelfData.GuildNpc[nIndex].rX := GuildNpc.StartX;
         SelfData.GuildNpc[nIndex].rY := GuildNpc.StartY;
         SelfData.GuildNpc[nIndex].rSex := GuildNpc.Sex;
         Inc (nIndex);
      end;
   end;

   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      if GuildNpc.boMagicNpc = false then begin
         SelfData.GuildNpc[nIndex].rName := GuildNpc.GuildNpcName;
         SelfData.GuildNpc[nIndex].rX := GuildNpc.StartX;
         SelfData.GuildNpc[nIndex].rY := GuildNpc.StartY;
         SelfData.GuildNpc[nIndex].rSex := GuildNpc.Sex;
         Inc (nIndex);
      end;
   end;
   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      if GuildNpc.boMagicNpc = false then begin
         SelfData.MagicExp := GuildNpc.GuildMagicData.rSkillExp;
         SelfData.GuildNpc[nIndex].rName := GuildNpc.GuildNpcName;
         SelfData.GuildNpc[nIndex].rX := GuildNpc.StartX;
         SelfData.GuildNpc[nIndex].rY := GuildNpc.StartY;
         SelfData.GuildNpc[nIndex].rSex := GuildNpc.Sex;
         Inc (nIndex);
      end;
   end;

   GuildUserList.SaveToFile ('.\Guild\' + SelfData.Name + 'GUser.sdb');
end;

procedure TGuildObject.LoadFromFile;
begin
   if not FileExists ('.\Guild\' + SelfData.Name + 'GUser.SDB') then exit;

   GuildUserList.LoadFromFile ('.\Guild\' + SelfData.Name + 'GUser.sdb');
end;

function TGuildObject.GetUserGrade (uName: String) : String;
var
   i : Integer;
begin
   if SelfData.Durability < SelfData.MaxDurability + 100000 then begin
      if uName = SelfData.Sysop then
         Inc (SelfData.Durability, ADD_GUILD_DURA_BY_SYSOP);
      for i := 0 to MAX_SUBSYSOP_COUNT - 1 do begin
         if uName = SelfData.SubSysop[i] then
            Inc (SelfData.Durability, ADD_GUILD_DURA_BY_SUBSYSOP);
      end;
      SelfData.Durability := SelfData.MaxDurability;
   end;

   Result := GuildUserList.GetGradeName (uName);
end;

procedure TGuildObject.GetGuildInfo (aUser: TUser);
var
   i : Integer;
   tmpStr, Sep : String;
begin
   tmpStr := SelfData.Name + ' (' + IntToStr (BasicData.X) + ',' + IntToStr (BasicData.Y) + ')';
   aUser.SendClass.SendChatMessage ('门派名称: ' + tmpStr, SAY_COLOR_NORMAL);
   aUser.SendClass.SendChatMessage ('门主: ' + SelfData.Sysop, SAY_COLOR_NORMAL);

   tmpStr := '副门主: ';
   Sep := '';
   for i := 0 to MAX_SUBSYSOP_COUNT - 1 do begin
      if SelfData.SubSysop[i] <> '' then begin
         tmpStr := tmpStr + Sep + SelfData.SubSysop[i];
         Sep := ', ';
      end;
   end;
   aUser.SendClass.SendChatMessage (tmpStr, SAY_COLOR_NORMAL);
end;

function TGuildObject.AddGuildNpc (aName: string; ax, ay: integer; aSex : Byte): Boolean;
var
   i : integer;
   GuildNpc : TGuildNpc;
begin
   Result := FALSE;

   if GetGuildNpcByName (aName) <> -1 then exit;
   if aSex <> 2 then aSex := 1;

   for i := 0 to MAX_GUILDNPC_COUNT - 1 do begin
      if SelfData.GuildNpc[i].rName = '' then begin
         SelfData.GuildNpc[i].rName := aName;
         SelfData.GuildNpc[i].rX := aX;
         SelfData.GuildNpc[i].rY := aY;
         SelfData.GuildNpc[i].rSex := aSex;

         GuildNpc := TGuildNpc.Create;
         GuildNpc.SetManagerClass (Manager);

         GuildNpc.Initial (Self, aName, aX, aY, aSex);

         if (SelfData.GuildMagic <> '') and (boAddGuildMagic = false) then begin
            GuildNpc.boMagicNpc := true;
            StrPCopy (@GuildNpc.BasicData.Guild, SelfData.GuildMagic);
            MagicClass.GetMagicData (SelfData.GuildMagic, GuildNpc.GuildMagicData, SelfData.MagicExp);
            boAddGuildMagic := true;
         end;
         DieGuildNpcList.Add (GuildNpc);
         
         Result := TRUE;
         exit;
      end;
   end;
end;

function  TGuildObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i, n, percent : integer;
//   xx, yy: word;
   str1, str2, str3: string;
   str, gname : string;
   sayer, objectname, gradename: string;
   SubData: TSubData;
   BO: TBasicObject;
   GuildNpc : TGuildNpc;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   case Msg of
      FM_ADDITEM:
         begin
            if SelfData.Name = '' then Exit;
            
            if aSubData.ItemData.rKind = ITEM_KIND_DUMMY then begin
               if GuildNpcList.Count + DieGuildNpcList.Count >= MAX_GUILDNPC_COUNT then begin
                  BocSay ('无法再制造.');
                  exit;
               end;
               i := 0;
               while true do begin
                  if aSubData.ItemData.rSex = 2 then begin
                     gName := INI_GUILD_NPCWOMAN_NAME + IntToStr(i);
                     if GetGuildNpcByName (gName) = -1 then begin
                        AddGuildNpc (gName, BasicData.X, BasicData.Y, 2);
                        Result := PROC_TRUE;
                        break;
                     end;
                  end else begin
                     gName := INI_GUILD_NPCMAN_NAME + IntToStr(i);
                     if GetGuildNpcByName (gName) = -1 then begin
                        AddGuildNpc (gName, BasicData.X, BasicData.Y, 1);
                        Result := PROC_TRUE;
                        break;
                     end;
                  end;
                  Inc (i);
               end;
            end;
         end;
      FM_HIT :
         begin
            if SelfData.Name <> '' then begin
               if isHitedArea (SenderInfo.dir, SenderInfo.x, SenderInfo.y, aSubData.HitData.HitFunction, percent) then begin
                  UserList.GuildSay (SelfData.Name, SelfData.Name + ': ' + format ('%s被攻击.',[INI_GUILD_STONE]));
                  Dec (SelfData.Durability, DEC_GUILD_DURA_BY_HIT);
                  if SelfData.Durability <= 0 then begin
                     // FboAllowDelete := TRUE;
                  end;
                  n := SelfData.Durability;
                  if n > SelfData.MaxDurability then n := SelfData.MaxDurability;
                  BocSay (IntToStr (n));
                  SubData.TargetId := SenderInfo.id;
                  for i := 0 to GuildNpcList.Count - 1 do begin
                     GuildNpc := GuildNpcList.Items [i];
                     if GuildNpc.FieldProc (NOTARGETPHONE, FM_GUILDATTACK, BasicData, SubData) = PROC_TRUE then begin
                        break;
                     end;
                  end;
               end;
            end;
{
            xx := SenderInfo.x; yy := SenderInfo.y;
            GetNextPosition (SenderInfo.dir, xx, yy);
            if (BasicData.x = xx) and (BasicData.y = yy) then begin
               UserList.GuildSay (GuildName, GuildName+ ': '+format ('%s被攻击.',[INI_GUILD_STONE]));
               Dec (GuildDurability, DEC_GUILD_DURA_BY_HIT);
               BocSay (IntToStr (GuildDurability));
               SubData.TargetId := SenderInfo.id;
               for i := 0 to AnsList.Count -1 do
                  if TGuildNpc (AnsList[i]).FieldProc (NOTARGETPHONE, FM_GUILDATTACK, BasicData, SubData) = PROC_TRUE then break;
            end;
}
         end;
      FM_PICKUP :
         begin
            if FboAllowDelete then exit;
            if (SelfData.Name = '') and (SelfData.Sysop <> '') then begin
               if (StrPas (@SenderInfo.Name) = SelfData.Sysop) then begin
                  ItemClass.GetItemData (INI_Guild_STONE, SubData.ItemData);
                  SignToItem (SubData.ItemData, Manager.ServerID, SenderInfo, '');
                  SubData.ServerId := Manager.ServerId;
                  if TFieldPhone(Manager.Phone).SendMessage (SenderInfo.id, FM_ADDITEM, BasicData, SubData) = PROC_TRUE then begin
                     FboAllowDelete := TRUE;
                     exit;
                  end;
               end;
            end;
         end;
      FM_SAY :
         begin
            if FboAllowDelete then exit;
            if SenderInfo.id = BasicData.id then exit;

            if StrPas (@SenderInfo.Name) = SelfData.Sysop then begin
               str := GetWordString (aSubData.SayString);
               if ReverseFormat (str, '%s: %s门派创建', str1, str2, str3, 2) then begin
                  if (not isFullHangul (str2)) or (not isGrammarID(str2)) or (Length(str2) > 12) or (Length(str2) < 2) then begin
                     BocSay ('门派名称错误.');
                     exit;
                  end;
                  SubData.ServerId := Manager.ServerId;
                  StrPCopy (@SubData.SubName, Str1);
                  StrPCopy (@SubData.GuildName, Str2);
                  if TFieldPhone (Manager.Phone).SendMessage (MANAGERPHONE, FM_ALLOWGUILDNAME, BasicData, SubData) = PROC_FALSE then begin
                     BocSay ('已有门派名称,无法成立门派.');
                     BocSay ('门主或副门主,无法成立门派.');
                     BocSay ('已是门派成员,无法成立门派.');
                     exit;
                  end else begin
                     BocChangeProperty;
                  end;
                  exit;
               end;
            end;
            if SelfData.Name = '' then exit;

            str := GetwordString (aSubData.SayString);
            if Pos ('请将我逃脱',str) > 0 then begin
               str := GetValidStr3 (str, sayer, ':');
               // 2000.09.18 NPC狼 捞抚苞 User狼 捞抚捞 鞍阑锭 八祸坷幅滚弊 荐沥 by Lee.S.G
               // 呕硼绰 RACE_HUMAN俊辑父 蜡瓤窍促
               Bo := GetViewObjectByName (sayer, RACE_HUMAN);
               if Bo = nil then exit;
               if not (Bo is TUser) then exit;
               TUser(Bo).GuildName := '';
               TUser(Bo).GuildGrade := '';
               StrPCopy(@TUser(Bo).BasicData.Guild, '');
               TUser(Bo).BocChangeProperty;
               BocSay ('成功脱离了.');
               exit;
            end;

            str := GetWordString (aSubData.SayString);
            if Pos ('请将我的权力撤除', str) > 0 then begin
               str := GetValidStr3 (str, sayer, ':');
               Bo := GetViewObjectByName (sayer, RACE_HUMAN);
               if Bo = nil then exit;
               if not (Bo is TUser) then exit;
               if (sayer <> SelfData.SubSysop[0]) and (sayer <> SelfData.SubSysop[1]) and (sayer <> SelfData.SubSysop[2]) then begin
                  BocSay ('你不是副门主.');
                  exit;
               end;
               if sayer = SelfData.SubSysop[0] then SelfData.SubSysop[0] := ''
               else if sayer = SelfData.SubSysop[1] then SelfData.SubSysop[1] := ''
               else if sayer = SelfData.SubSysop[2] then SelfData.SubSysop[2] := '';
               BocSay ('已将副门主权力撤除.');
               exit;
            end;

            str := GetwordString (aSubData.SayString);
            if ReverseFormat (str, '%s: ', sayer, str2, str3, 1) then begin
               if (sayer <> SelfData.Sysop) and (sayer <> SelfData.SubSysop[0])
                  and (sayer <> SelfData.SubSysop[1]) and (sayer <> SelfData.SubSysop[2]) then exit;
            end;

            if ReverseFormat (str, '%s: 攻击%s', sayer, objectname, str3, 2) then begin
               Bo := GetViewObjectByName (objectname, RACE_HUMAN);
               if Bo = nil then begin BocSay (format ('%s不在.',[objectname])); exit; end;
               if not (Bo is TUser) then begin BocSay (format ('%s不是使用者.',[objectname])); exit; end;
               if BO.BasicData.Feature.rfeaturestate = wfs_die then exit;
               SubData.TargetId := BO.BasicData.id;
               for i := 0 to GuildNpcList.Count - 1 do begin
                  GuildNpc := GuildNpcList.Items [i];
                  Bo := GetViewObjectByID (GuildNpc.BasicData.ID);
                  if Bo <> nil then begin
                     GuildNpc.FieldProc (NOTARGETPHONE, FM_GUILDATTACK, BasicData, SubData);
                  end;
               end;
               exit;
            end;
            if ReverseFormat (str, '%s: 停止攻击', sayer, objectname, str3, 1) then begin
               SubData.TargetId := 0;
               for i := 0 to GuildNpcList.Count - 1 do begin
                  GuildNpc := GuildNpcList.Items [i];
                  GuildNpc.FieldProc (NOTARGETPHONE, FM_GUILDATTACK, BasicData, SubData);
               end;
               exit;
            end;
            if ReverseFormat (str, '%s: 将%s加入', sayer, objectname, str3, 2) then begin
               // 2000.09.18 NPC狼 捞抚苞 User狼 捞抚捞 鞍阑锭 八祸坷幅滚弊 荐沥 by Lee.S.G
               // 啊涝篮 RACE_HUMAN俊辑父 蜡瓤窍促
               Bo := GetViewObjectByName (objectname, RACE_HUMAN);
               if Bo = nil then begin BocSay (format ('%s不在.',[objectname])); exit; end;
               if not (Bo is TUser) then begin BocSay (format ('%s不是使用者.',[objectname])); exit; end;
               if TUser(Bo).GuildName = SelfData.Name then begin BocSay (format ('%s已被加入过.',[objectname])); exit; end;
               if TUser(Bo).GuildName <> '' then begin BocSay (format ('%s已拥有门派.',[objectname])); exit; end;
               TUser(Bo).GuildName := SelfData.Name;
               // 2000.09.16 巩林唱 何巩林狼 啊涝矫 巩颇檬籍狼 郴备己阑 刘啊矫虐扁 困秦
               // GetUserGrade() 甫 龋免茄促 by Lee.S.G
               TUser(Bo).GuildGrade := GetUserGrade (objectname);
               StrPCopy (@TUser(Bo).BasicData.Guild, SelfData.Name);
               GuildUserList.AddUser (objectname);
               TUser(Bo).BocChangeProperty;
               BocSay (format ('加入了%s.',[objectname]));
            end;
            if ReverseFormat (str, '%s: 将%s逐出', sayer, objectname, str3, 2) then begin
               if GuildUserList.DelUser (objectname) then begin
                  BocSay (format ('逐出了%s.',[objectname]));
                  SubData.ServerId := Manager.ServerId;
                  StrPCopy (@SubData.SubName, objectname);
                  StrPCopy (@SubData.GuildName, SelfData.Name);
                  TFieldPhone (Manager.Phone).SendMessage (MANAGERPHONE, FM_REMOVEGUILDMEMBER, BasicData, SubData);

                  // 2000.09.18 NPC狼 捞抚苞 User狼 捞抚捞 鞍阑锭 八祸坷幅滚弊 荐沥 by Lee.S.G
                  // 呕硼绰 RACE_HUMAN俊辑父 蜡瓤窍促
                  {
                  Bo := GetViewObjectByName (objectname, RACE_HUMAN);
                  if Bo = nil then exit;
                  if not (Bo is TUser) then exit;
                  TUser (Bo).GuildName := '';
                  // 2000.09.16 GuildGrade档 窃膊 檬扁拳 矫挪促 by Lee.S.G
                  TUser (Bo).GuildGrade := '';
                  StrPCopy (@TUser (Bo).BasicData.Guild, '');
                  TUser(Bo).BocChangeProperty;
                  }
               end else begin
                  BocSay (format ('%s未加入门派.',[objectname]));
               end;
            end;
            if ReverseFormat (str, '%s: %s的职称是%s', sayer, objectname, gradename, 3) then begin
               if (not isFullHangul (gradename)) or (not isGrammarID(gradename)) or (Length(gradename) > 12) or (Length(gradename) < 2) then begin
                  BocSay ('错误的职称.');
                  exit;
               end;

               if GuildUserList.IsGuildUser (objectname) then begin
                  BocSay (format ('获得的职称是%s.',[gradename]));
                  GuildUserList.SetGradeName (objectname, gradename);
               end else begin
                  BocSay (format ('%s未加入门派.',[objectname]));
               end;
            end;

            if ReverseFormat (str, '%s: 将%s任命为副门主', sayer, objectname, str3, 2) then begin
               if sayer <> SelfData.Sysop then exit;
               // 2000.09.18 NPC狼 捞抚苞 User狼 捞抚捞 鞍阑锭 八祸坷幅滚弊 荐沥 by Lee.S.G
               // 何巩林绰 RACE_HUMAN俊辑父 蜡瓤窍促
               Bo := GetViewObjectByName (objectname, RACE_HUMAN);
               if Bo = nil then begin BocSay (format ('%s不在.',[objectname])); exit; end;
               if not (Bo is TUser) then begin BocSay (format ('%s不是使用者.',[objectname])); exit; end;
               if TUser (Bo).GuildName <> SelfData.Name then begin BocSay (format ('%s不是门派成员.',[objectname])); exit; end;

               if (objectname = SelfData.SubSysop[0]) or (objectname = SelfData.SubSysop[1]) or (objectname = SelfData.SubSysop[2]) then begin
                  BocSay (format ('%s已经是副门主了.',[objectname]));
                  exit;
               end;

               if (SelfData.SubSysop[0] <> '') and (SelfData.SubSysop[1] <> '') and (SelfData.SubSysop[2] <> '') then begin
                  BocSay ('无法再任命了.');
                  BocSay ( format ('副门主 %s, %s, %s.', [SelfData.SubSysop[0],SelfData.SubSysop[1],SelfData.SubSysop[2]]));
                  exit;
               end;

               // 2000.09.20 促弗 巩颇狼 巩林唱 何巩林绰 何巩林肺 烙疙瞪荐 绝促 by Lee.S.G
               SubData.ServerId := Manager.ServerId;
               StrPCopy (@SubData.SubName, objectname);
               StrPCopy (@SubData.GuildName, '');
               if TFieldPhone(Manager.Phone).SendMessage (MANAGERPHONE, FM_ALLOWGUILDSYSOPNAME, BasicData, SubData) = PROC_FALSE then begin
                  BocSay ('已经是其他门派的门主或副门主.');
                  BocSay ('已经是.');
                  Exit;
               end;
               
               if SelfData.SubSysop[0] = '' then begin SelfData.SubSysop[0] := objectname; BocSay(format ('%s任命为副门主.',[objectname])); exit; end;
               if SelfData.SubSysop[1] = '' then begin SelfData.SubSysop[1] := objectname; BocSay(format ('%s任命为副门主.',[objectname])); exit; end;
               if SelfData.SubSysop[2] = '' then begin SelfData.SubSysop[2] := objectname; BocSay(format ('%s任命为副门主.',[objectname])); exit; end;
            end;
            if ReverseFormat (str, '%s: 将%s副门主撤除了', sayer, objectname, str3, 2) then begin
               if sayer <> SelfData.Sysop then exit;
               if SelfData.SubSysop[0] = objectname then begin SelfData.SubSysop[0] := ''; BocSay(format ('%s副门主被撤除.',[objectname])); exit; end;
               if SelfData.SubSysop[1] = objectname then begin SelfData.SubSysop[1] := ''; BocSay(format ('%s副门主被撤除.',[objectname])); exit; end;
               if SelfData.SubSysop[2] = objectname then begin SelfData.SubSysop[2] := ''; BocSay(format ('%s副门主被撤除.',[objectname])); exit; end;
               BocSay (format ('%s不是副门主.',[objectname]));
            end;

            if ReverseFormat (str, '%s: 门派情报', str1, str2, str3, 1) then begin
               BocSay ('门派卒兵情报');
               for i := 0 to GuildNpcList.Count -1 do begin
                  GuildNpc := GuildNpcList.Items [i];
                  str := StrPas(@GuildNpc.BasicData.Name);
                  str := str + '  x:' + IntToStr (GuildNpc.BasicData.X);
                  str := str + '  y:' + IntToStr (GuildNpc.BasicData.Y);
                  BocSay (str);
               end;
               n := SelfData.Durability;
               if n > SelfData.MaxDurability then n := SelfData.MaxDurability;
               BocSay (format ('门派石: %d/%d',[n, SelfData.MaxDurability]));
               exit;
            end;
         end;
   end;
end;

procedure TGuildObject.Initial;
var
   i : Integer;
   GuildNpc : TGuildNpc;
   MagicData : TMagicData;
begin
   inherited Initial (SelfData.Name, SelfData.Name);

   LoadFromFile (SelfData.Name);

   FGuildName := SelfData.Name;
   DuraTick := mmAnsTick;

   // if (SelfData.MaxDurability = 0) or (SelfData.MaxDurability = 110000) then begin
   // SelfData.MaxDurability := MAX_GUILD_DURA;
   // end;

   BasicData.id := GetNewStaticItemId;
   BasicData.x := SelfData.X;
   BasicData.y := SelfData.Y;
   BasicData.ClassKind := CLASS_GUILDSTONE;
   BasicData.Feature.rrace := RACE_STATICITEM;
   BasicData.Feature.rImageNumber := 67;
   BasicData.Feature.rImageColorIndex := 0;

   MagicClass.GetMagicData (SelfData.GuildMagic, MagicData, SelfData.MagicExp);
   if MagicData.rName [0] = 0 then begin
      SelfData.GuildMagic := '';
      SelfData.MagicExp := 0;
   end;

   boAddGuildMagic := false;

   DieGuildNpcList.Clear;
   for i := 0 to MAX_GUILDNPC_COUNT - 1 do begin
      if SelfData.GuildNpc[i].rName = '' then continue;

      GuildNpc := TGuildNpc.Create;
      if Manager <> nil then begin
         GuildNpc.SetManagerClass (Manager);
      end;
      GuildNpc.Initial (Self, SelfData.GuildNpc[i].rName, SelfData.GuildNpc[i].rX, SelfData.GuildNpc[i].rY, SelfData.GuildNpc[i].rSex);

      if (SelfData.GuildMagic <> '') and (boAddGuildMagic = false) then begin
         GuildNpc.boMagicNpc := true;
         StrPCopy (@GuildNpc.BasicData.Guild, SelfData.GuildMagic);
         MagicClass.GetMagicData (SelfData.GuildMagic, GuildNpc.GuildMagicData, SelfData.MagicExp);
         boAddGuildMagic := true;
      end;
      DieGuildNpcList.Add (GuildNpc);
   end;
end;

procedure TGuildObject.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   TFieldPhone(Manager.Phone).RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   TFieldPhone(Manager.Phone).SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TGuildObject.EndProcess;
var
   i : integer;
   SubData : TSubData;
   GuildNpc : TGuildNpc;
begin
   if FboRegisted = FALSE then exit;

   for i := DieGuildNpcList.Count - 1 downto 0 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      GuildNpc.Free;
      DieGuildNpcList.Delete (i);
   end;

   for i := GuildNpcList.Count - 1 downto 0 do begin
      GuildNpc := GuildNpcList.Items [i];
      GuildNpc.EndProcess;
      GuildNpc.Free;
      GuildNpcList.Delete (i);
   end;

   TFieldPhone(Manager.Phone).SendMessage (0, FM_DESTROY, BasicData, SubData);
   TFieldPhone(Manager.Phone).UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

function TGuildObject.MoveStone (aServerID, ax, ay: integer) : Boolean;
var
   i, nX, nY : integer;
   nIndex : Byte;
   SubData : TSubData;
   tmpManager : TManager;
   GuildNpc : TGuildNpc;
begin
   Result := false;

   if Manager = nil then exit;

   tmpManager := ManagerList.GetManagerByServerID (aServerID);
   if tmpManager = nil then exit;
   if tmpManager.boMakeGuild = false then exit;
   nIndex := TMaper (tmpManager.Maper).GetAreaIndex (aX, aY);
   if nIndex = 0 then exit;
   if AreaClass.CanMakeGuild (nIndex) = false then exit;

   nX := aX; nY := aY;
   // TMaper (tmpManager.Maper).GetMoveableXY (nX, nY, 10);
   // if not TMaper (tmpManager.Maper).isMoveable (nX, nY) then exit;

   TFieldPhone(Manager.Phone).SendMessage (NOTARGETPHONE, FM_DESTROY, BasicData, SubData);
   TFieldPhone(Manager.Phone).UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   SelfData.MapID := aServerID;
   SelfData.X := nX; SelfData.Y := nY;
   BasicData.x := nx; BasicData.y := ny;

   SetManagerClass (tmpManager);

   TFieldPhone(Manager.Phone).RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   TFieldPhone(Manager.Phone).SendMessage (NOTARGETPHONE, FM_CREATE, BasicData, SubData);

   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      GuildNpc.MoveGuildNpc (aServerID, nX, nY);
   end;

   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      GuildNpc.MoveDieGuildNpc (aServerID, nX, nY);
   end;

   Result := true;
end;

function TGuildObject.CreateStone (aSysopName : String; aServerID, ax, ay: integer) : Boolean;
var
   i, nX, nY : integer;
   nIndex : Byte;
   SubData : TSubData;
   tmpManager : TManager;
   GuildNpc : TGuildNpc;
begin
   Result := false;

   if (aSysopName <> '') and (SelfData.Sysop <> aSysopName) then exit; 

   tmpManager := ManagerList.GetManagerByServerID (aServerID);
   if tmpManager = nil then exit;
   if tmpManager.boMakeGuild = false then exit;
   nIndex := TMaper (tmpManager.Maper).GetAreaIndex (aX, aY);
   if nIndex = 0 then exit;
   if AreaClass.CanMakeGuild (nIndex) = false then exit;

   nX := aX; nY := aY;
   if TMaper (tmpManager.Maper).isGuildStoneArea (nX, nY) = true then exit;
   // TMaper (tmpManager.Maper).GetMoveableXY (nX, nY, 10);
   // if not TMaper (tmpManager.Maper).isMoveable (nX, nY) then exit;

   SelfData.MapID := aServerID;
   SelfData.X := nX; SelfData.Y := nY;
   BasicData.x := nx; BasicData.y := ny;

   SetManagerClass (tmpManager);

   Initial;
   StartProcess;

   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      GuildNpc.MoveGuildNpc (aServerID, nX, nY);
   end;

   for i := 0 to DieGuildNpcList.Count - 1 do begin
      GuildNpc := DieGuildNpcList.Items [i];
      GuildNpc.MoveDieGuildNpc (aServerID, nX, nY);
   end;

   Result := true;
end;

function TGuildObject.GetGuildNpcByName (aname: string): integer;
var
   i : integer;
   GuildNpc : TGuildNpc;
begin
   Result := -1;
   for i := 0 to GuildNpcList.Count -1 do begin
      GuildNpc := GuildNpcList.Items [i];
      if GuildNpc.GuildNpcName = aName then begin
         Result := i;
         exit;
      end;
   end;
end;

procedure TGuildObject.ChangeGuildNpcName (aOldName, aNewName : String);
var
   i : integer;
   GuildNpc : TGuildNpc;
begin
   for i := 0 to MAX_GUILDNPC_COUNT - 1 do begin
      if SelfData.GuildNpc [i].rName = aOldName then begin
         SelfData.GuildNpc [i].rName := aNewName;
         exit;
      end;
   end;
end;

procedure TGuildObject.SetWarAlarm (aName, aStr : String);
var
   i : Integer;
   boFlag : Boolean;
begin
   boFlag := false;

   if isGuildSysop (aName) then boFlag := true;
   if boFlag = false then begin
      if isGuildSubSysop (aName) then boFlag := true; 
   end;

   if boFlag = false then exit;
   
   FWarAlarmStr := aStr;
   FWarAlarmTick := mmAnsTick;
   FWarAlarmStartTick := mmAnsTick;
end;

procedure TGuildObject.Update (CurTick: integer);
var
   i, j, nX, nY : integer;
   nname: string;
   GuildNpc : TGuildNpc;
   bo : TBasicObject;
begin
   // 2000.09.18 巩颇器凉捞 昏力登绰 泅惑阑 阜扁困秦 刚历 昏力窍绊
   // 第捞绢 官肺 积己茄促 by Lee.S.G
   for i := GuildNpcList.Count - 1 downto 0 do begin
      GuildNpc := GuildNpcList.Items [i];
      if GuildNpc.boAllowDelete then begin
         GuildNpc.EndProcess;
         GuildNpcList.Delete (i);
         DieGuildNpcList.Add (GuildNpc);
      end;
   end;

   {
   for i := 0 to 5 - 1 do begin
      nName := GuildNpcDataClass.GuildNpcDataArr[i].rname;
      if nname = '' then continue;

      ret := GetGuildNpcByName (nname);
      if ret = -1 then begin
         xx := GuildNpcDataClass.GuildNpcDataArr[i].rx;
         yy := GuildNpcDataClass.GuildNpcDataArr[i].ry;

         tempx := 0; tempy := 0;
         if not TMaper(Manager.Maper).IsMoveable (xx, yy) then begin
            for j := 0 to 32 do begin
               GetNearPosition (tempx, tempy);
               if TMaper(Manager.Maper).isMoveable (xx + tempx, yy + tempy) then begin
                  break;
               end;
            end;
            if not TMaper(Manager.Maper).isMoveable (xx + tempx, yy + tempy) then begin
               tempx := 0; tempy := 0;
            end;
         end;

         GuildNpc := TGuildNpc.Create;
         GuildNpc.SetManagerClass (Manager);
         GuildNpc.StartX := xx;
         GuildNpc.StartY := yy;
         GuildNpc.Initial (TBasicObject(Self), nname, xx+tempx, yy+tempy);
         GuildNpc.GuildNpcDataClass := GuildNpcDataClass;

         if (GuildMagicName <> '') and (i = 0) then begin
            GuildNpc.boMagicNpc := TRUE;
            StrPcopy (@GuildNpc.BasicData.Guild, GuildMagicName);
            MagicClass.GetMagicData (GuildMagicName, GuildNpc.GuildMagicData, GuildMagicExp);
         end;

         GuildNpc.StartProcess;
         // 2000.09.16 巩颇器凉吝 巩颇公傍捞 瘤沥等 器凉狼 困摹啊 函窍绰巴阑
         // 阜扁 困秦 TAnsList俊 Insert Method甫 眠啊窍绊 巩颇器凉狼 积己矫
         // 霉锅掳 器凉篮 府胶飘狼 急滴俊 火涝茄促 by Lee.S.G
         // AnsList.Add (GuildNpc);
         if i = 0 then GuildNpcList.Insert (0, GuildNpc)
         else GuildNpcList.Add (GuildNpc);
      end;
   end;
   }

   if (Manager <> nil) and (DieGuildNpcList.Count > 0) then begin
      for i := DieGuildNpcList.Count - 1 downto 0 do begin
         GuildNpc := DieGuildNpcList.Items [i];
         nX := GuildNpc.StartX - 3 + Random (6);
         nY := GuildNpc.StartY - 3 + Random (6);
         TMaper (Manager.Maper).GetMoveableXY (nX, nY, 10);
         if TMaper (Manager.Maper).isMoveable (nX, nY) then begin
            GuildNpc.BasicData.X := nX;
            GuildNpc.BasicData.Y := nY;
            GuildNpc.StartProcess;
            GuildNpcList.Add (GuildNpc);
            DieGuildNpcList.Delete (i);
         end;
      end;
   end;

   for i := 0 to GuildNpcList.Count - 1 do begin
      GuildNpc := GuildNpcList.Items [i];
      GuildNpc.Update (CurTick);
   end;

   if CurTick > DuraTick + DEC_GUILD_DURA_TICK then begin
      DuraTick := CurTick;
      Dec (SelfData.Durability);
      if boShowGuildDuraValue then begin
         BocSay (IntToStr(SelfData.Durability) + '/' + IntToStr (SelfData.MaxDurability));
      end;
   end;

   if (FWarAlarmStr <> '') and (CurTick > FWarAlarmTick + 1000) then begin
      UserList.GuildSay (SelfData.Name, SelfData.Name + ': ' + format ('%s', [FWarAlarmStr]));
      FWarAlarmTick := CurTick;
      if CurTick > FWarAlarmStartTick + 18000 then begin
         FWarAlarmTick := 0;
         FWArAlarmSTartTick := 0;
         FWarAlarmStr := '';
      end;
   end;
end;

////////////////////////////////////////////////////
//
//             ===  GuildList  ===
//
////////////////////////////////////////////////////

constructor TGuildList.Create;
begin
   CurProcessPos := 0;
   
   DataList := TList.Create;

   LoadFromFile ('.\Guild\CreateGuild.SDB');
end;

destructor TGuildList.Destroy;
begin
   SaveToFile ('.\Guild\CreateGuild.SDB');
   Clear;
   DataList.Free;
   
   inherited Destroy;
end;

procedure TGuildList.Clear;
var
   i : Integer;
   GuildObject : TGuildObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      GuildObject.EndProcess;
      GuildObject.Free;
   end;
   DataList.Clear;
end;

function  TGuildList.GetCount: integer;
begin
   Result := DataList.Count;
end;

function TGuildList.GetUserGrade (aGuildName, uName: String): string;
var
   i : integer;
   GuildObject : TGuildObject;
begin
   Result := '';
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         Result := GuildObject.GetUserGrade (uname);
         exit;
      end;
   end;
end;

function TGuildList.GetGuildServerID (aGuildName : String): Integer;
var
   i : integer;
   GuildObject : TGuildObject;
begin
   Result := -1;
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         if GuildObject.boAllowDelete = false then begin
            Result := GuildObject.SelfData.MapID;
            exit;
         end;
      end;
   end;
end;

procedure TGuildList.GetGuildInfo (aGuildName: string; aUser: TUser);
var
   i : integer;
   GuildObject : TGuildObject;
begin
   for i := 0 to DataList.Count -1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         GuildObject.GetGuildInfo (aUser);
         exit;
      end;
   end;
end;

function TGuildList.CheckGuildUser (aGuildName, aName : String) : Boolean;
var
   i : integer;
   GuildObject : TGuildObject;
begin
   Result := FALSE;
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName <> aGuildName then continue;
      if GuildObject.IsGuildUser(aName) = true then begin
         Result := TRUE;
         exit;
      end;
   end;
end;

procedure   TGuildList.AllowGuildName (gid: integer; aboAllow: Boolean; aGuildName, aSysopName: string);
var
   i : integer;
   pd : PTCreateGuildData;
   GuildObject: TGuildObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.BasicData.id = gid then begin
         if aboAllow = true then begin
            pd := GuildObject.GetSelfData;
            
            GuildObject.BocSay (format ('门派名称是%s.',[aGuildName]));
            pd^.Sysop := aSysopName;
            StrPCopy (@GuildObject.BasicData.Name, aGuildName);
            StrPCopy (@GuildObject.BasicData.ViewName, aGuildName);
            pd^.Name := aGuildName;
            GuildObject.FGuildName := aGuildName;
            GuildObject.BocChangeFeature;
            pd^.MakeDate := DateToStr (Date);
         end else begin
            GuildObject.BocSay ('无法成立门派.');
         end;
         exit;
      end;
   end;
end;

function TGuildList.AllowGuildCondition (gname, uname: string): Boolean;
var
   i, j : integer;
   pd : PTCreateGuildData;
   GuildObject: TGuildObject;
begin
   Result := TRUE;
   for i := 0 to DataList.Count -1 do begin
      GuildObject := DataList.Items [i];
      pd := GuildObject.GetSelfData;
      if pd^.Name = '' then continue;
      if pd^.Name = gname then begin Result := FALSE; exit; end;
      if pd^.Sysop = uname then begin Result := FALSE; exit; end;
      for j := 0 to MAX_SUBSYSOP_COUNT - 1 do begin
         if pd^.SubSysop[j] = uname then begin
            Result := FALSE;
            exit;
         end;
      end;
   end;
end;

function  TGuildList.MoveStone (aGuildName : String; aServerID, ax, ay: integer) : Boolean;
var
   i : integer;
   GuildObject : TGuildObject;
begin
   Result := false;
   for i := 0 to DataList.Count -1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         Result := GuildObject.MoveStone (aServerID, ax, ay);
         exit;
      end;
   end;
end;

function TGuildList.CreateStone (aGuildName, aSysopName : String; aServerID, ax, ay: integer) : Boolean;
var
   i : integer;
   GuildObject : TGuildObject;
begin
   Result := false;
   for i := 0 to DataList.Count -1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.SelfData.Name = aGuildName then begin
         if GuildObject.boRegisted = false then begin
            Result := GuildObject.CreateStone (aSysopName, aServerID, ax, ay);
         end;
         exit;
      end;
   end;
end;

function TGuildList.AddGuildObject (aGuildName, aOwnerName : String; aServerID, aX, aY: integer): TGuildObject;
var
   Manager : TManager;
   GuildObject : TGuildObject;
   pd : PTCreateGuildData;
begin
   GuildObject := TGuildObject.Create;

   pd := GuildObject.GetSelfData;
   pd^.Name := aGuildName;
   pd^.MapID := aServerID;
   pd^.X := aX;
   pd^.Y := aY;
   pd^.Durability := MAX_GUILD_DURA + 100000;
   pd^.MaxDurability := MAX_GUILD_DURA;
   pd^.Sysop := aOwnerName;
   
   Manager := ManagerList.GetManagerByServerID (aServerID);
   GuildObject.SetManagerClass (Manager);
   GuildObject.Initial;
   GuildObject.StartProcess;
   DataList.Add (GuildObject);
   
   Result := GuildObject;
end;

procedure TGuildList.LoadFromFile (aFileName : String);
var
   i, j : Integer;
   str, rdstr : string;
   iName : string;
   pd, pdd : PTCreateGuildData;
   DB : TUserStringDb;
   Manager : TManager;
   GuildObject : TGuildObject;
begin
   if not FileExists (aFileName) then exit;

   DB := TUserStringDb.Create;
   DB.LoadFromFile (aFileName);

   for i := 0 to Db.Count - 1 do begin
      iName := Db.GetIndexName (i);
      if iName = '' then continue;

      GuildObject := TGuildObject.Create;
      pd := GuildObject.GetSelfData;

      FillChar (pd^, SizeOf(TCreateGuildData), 0);

      pd^.Name := iName;
      pd^.Title := Db.GetFieldValueString (iName, 'Title');
      pd^.MapID := Db.GetFieldValueInteger (iName, 'MapID');
      pd^.x := Db.GetFieldValueInteger (iname, 'X');
      pd^.y := Db.GetFieldValueInteger (iname, 'Y');
      pd^.Durability := Db.GetFieldValueInteger (iName, 'Durability');
      pd^.MaxDurability := Db.GetFieldValueInteger (iName, 'MaxDurability');
      pd^.GuildMagic := Db.GetFieldValueString (iName, 'GuildMagic');
      pd^.MagicExp := Db.GetFieldValueInteger (iName, 'MagicExp');
      pd^.MakeDate := Db.GetFieldValueString (iName, 'MakeDate');
      pd^.Sysop := Db.GetFieldValueString (iname, 'Sysop');
      for j := 0 to MAX_SUBSYSOP_COUNT - 1 do begin
         pd^.SubSysop[j] := Db.GetFieldValueString (iName, 'SubSysop' + IntToStr (j));
      end;
      for j := 0 to MAX_GUILDNPC_COUNT - 1 do begin
         str := Db.GetFieldValueString (iName, 'Npc' + IntToStr(j));
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildNpc[j].rName := rdstr;
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildNpc[j].rx := _StrToInt (rdstr);
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildNpc[j].ry := _StrToInt (rdstr);
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildNpc[j].rSex := _StrToInt (rdstr);
      end;
      for j := 0 to MAX_GUILDWEAR_COUNT - 1 do begin
         str := Db.GetFieldValueString (iName, 'Wear0');
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildWear[j].rItemName := rdstr;
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildWear[j].rColor := _StrToInt (rdstr);
         str := GetValidStr3 (str, rdstr, ':');
         pd^.GuildWear[j].rItemCount := _StrToInt (rdstr);
      end;

      pd^.BasicPoint := Db.GetFieldValueInteger (iName, 'BasicPoint');
      pd^.AwardPoint := Db.GetFieldValueInteger (iName, 'AwardPoint');
      pd^.BattleRejectCount := Db.GetFieldValueInteger (iName, 'BattleRejectCount');
      pd^.ChallengeGuild := Db.GetFieldValueString (iName, 'ChallengeGuild');
      pd^.ChallengeGuildUser := Db.GetFieldValueString (iName, 'ChallengeGuildUser');
      pd^.ChallengeDate := Db.GetFieldValueString (iName, 'ChallengeDate');

      Manager := ManagerList.GetManagerByServerID (pd^.MapID);
      if Manager <> nil then begin
         GuildObject.SetManagerClass (Manager);
         GuildObject.Initial;
         GuildObject.StartProcess;
      end else begin
         GuildObject.Initial;
      end;

      DataList.Add (GuildObject);
   end;

   DB.Free;
end;

procedure TGuildList.SaveToFile (aFileName : String);
var
   i, j : integer;
   str, rdstr : string;
   pd : PTCreateGuildData;
   GuildObject : TGuildObject;
   DB : TUserStringDb;
begin
   if not FileExists (aFileName) then exit;

   Db := TUserStringDb.Create;
   Db.LoadFromFile (aFileName);

   for i := 0 to Db.Count - 1 do begin
      Db.DeleteName (Db.GetIndexName (0));
   end;

   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      pd := GuildObject.GetSelfData;
      if pd^.Name = '' then continue;

      GuildObject.SaveToFile;

      Db.AddName (pd^.Name);
      Db.SetFieldValueString (pd^.Name, 'Title', pd^.Title);
      Db.SetFieldValueInteger (pd^.Name, 'MapID', pd^.MapID);
      Db.SetFieldValueInteger (pd^.Name, 'X', pd^.x);
      Db.SetFieldValueInteger (pd^.Name, 'Y', pd^.y);
      Db.SetFieldValueInteger (pd^.Name, 'Durability', pd^.Durability);
      Db.SetFieldValueInteger (pd^.Name, 'MaxDurability', pd^.MaxDurability);
      Db.SetFieldValueString (pd^.Name, 'GuildMagic', pd^.GuildMagic);
      Db.SetFieldValueInteger (pd^.Name, 'MagicExp', pd^.MagicExp);
      Db.SetFieldValueString (pd^.Name, 'MakeDate', pd^.MakeDate);
      Db.SetFieldValueString (pd^.Name, 'Sysop', pd^.Sysop);
      for j := 0 to MAX_SUBSYSOP_COUNT - 1 do begin
         Db.SetFieldValueString (pd^.Name, 'SubSysop' + IntToStr (j), pd^.SubSysop[j]);
      end;
      for j := 0 to MAX_GUILDNPC_COUNT - 1 do begin
         str := pd^.GuildNpc[j].rName + ':';
         str := str + IntToStr (pd^.GuildNpc[j].rx) + ':';
         str := str + IntToStr (pd^.GuildNpc[j].ry) + ':';
         str := str + IntToStr (pd^.GuildNpc[j].rSex) + ':';
         if pd^.GuildNpc[j].rName = '' then str := '';
         Db.SetFieldValueString (pd^.Name, 'Npc' + IntToStr(j), str);
      end;
      for j := 0 to MAX_GUILDWEAR_COUNT - 1 do begin
         str := '';
         if pd^.GuildWear[j].rItemName <> '' then begin
            str := pd^.GuildWear[j].rItemName + ':';
            str := str + IntToStr (pd^.GuildWear[j].rColor) + ':';
            str := str + IntToStr (pd^.GuildWear[j].rItemCount) + ':';
         end;
         Db.SetFieldValueString (pd^.Name, 'Wear' + IntToStr(j), str);
      end;
      Db.SetFieldValueInteger (pd^.Name, 'BasicPoint', pd^.BasicPoint);
      Db.SetFieldValueInteger (pd^.Name, 'AwardPoint', pd^.AwardPoint);
      Db.SetFieldValueInteger (pd^.Name, 'BattleRejectCount', pd^.BattleRejectCount);
      Db.SetFieldValueString (pd^.Name, 'ChallengeGuild', pd^.ChallengeGuild);
      Db.SetFieldValueString (pd^.Name, 'ChallengeGuildUser', pd^.ChallengeGuildUser);
      Db.SetFieldValueString (pd^.Name, 'ChallengeDate', pd^.ChallengeDate);
   end;

   Db.SaveToFile ('.\Guild\CreateGuild.SDB');
   Db.Free;
end;

procedure TGuildList.Update (CurTick: integer);
var
   i, j : Integer;
   DeleteGuildObject, GuildObject : TGuildObject;
   StartPos, GuildProcessCount : Integer;
begin
   GuildProcessCount := (DataList.Count * 4 div 100);
   if GuildProcessCount = 0 then GuildProcessCount := DataList.Count;

   GuildProcessCount := ProcessListCount;

   if DataList.Count > 0 then begin
      StartPos := CurProcessPos;
      for i := 0 to GuildProcessCount - 1 do begin
         if CurProcessPos >= DataList.Count then CurProcessPos := 0;
         GuildObject := DataList.Items [CurProcessPos];
         // if (GuildObject.SelfData.Durability <= 0) or (GuildObject.FboAllowDelete = true) then begin
         if GuildObject.FboAllowDelete = true then begin
            GuildObject.EndProcess;
            GuildObject.Free;
            DataList.Delete (CurProcessPos);
         end else begin
            try
               GuildObject.Update (CurTick);
            except
               frmMain.WriteLogInfo (format ('TGuild.Update (%s) exception', [GuildObject.GuildName]));
               exit;
            end;
         end;
         Inc (CurProcessPos);
         if CurProcessPos = StartPos then break;
      end;
   end;
end;

procedure TGuildList.CompactGuild;
var
   i : Integer;
   GuildObject : TGuildObject;
   Str, iName : String;
   buffer : array [0..4096 - 1] of char;
   DB : TUserStringDB;
   Stream : TFileStream;
begin
   if not FileExists ('.\Guild\DeletedGuild.SDB') then begin
      Str := 'Index,DeletedDate,Name,Durability,X,Y,Sysop,SubSysop0,SubSysop1,SubSysop2,GuildMagic,MakeDate,MagicExp' + #13#10;
      StrPCopy (@buffer, Str);
      Stream := TFileStream.Create ('.\Guild\DeletedGuild.SDB', fmCreate);
      Stream.WriteBuffer (buffer, StrLen (@buffer));
      Stream.Free;
   end;

   DB := TUserStringDB.Create;
   DB.LoadFromFile ('.\Guild\DeletedGuild.SDB');

   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = '' then continue;
      if GuildObject.SelfData.Durability <= 0 then begin
         iName := IntToStr (DB.Count);
         DB.AddName (iName);
         DB.SetFieldValueString (iName, 'DeletedDate', DateToStr (Date));
         DB.SetFieldValueString (iName, 'Name', GuildObject.GuildName);
         DB.SetFieldValueInteger (iName, 'Durability', GuildObject.SelfData.Durability);
         DB.SetFieldValueInteger (iName, 'X', GuildObject.SelfData.X);
         DB.SetFieldValueInteger (iName, 'Y', GuildObject.SelfData.Y);
         DB.SetFieldValueString (iName, 'Sysop', GuildObject.SelfData.Sysop);
         DB.SetFieldValueString (iName, 'SubSysop0', GuildObject.SelfData.SubSysop [0]);
         DB.SetFieldValueString (iName, 'SubSysop1', GuildObject.SelfData.SubSysop [1]);
         DB.SetFieldValueString (iName, 'SubSysop2', GuildObject.SelfData.SubSysop [2]);
         DB.SetFieldValueString (iName, 'GuildMagic', GuildObject.SelfData.GuildMagic);
         DB.SetFieldValueString (iName, 'MakeDate', GuildObject.SelfData.MakeDate);
         DB.SetFieldValueInteger (iName, 'MagicExp', GuildObject.SelfData.MagicExp);

         GuildObject.boAllowDelete := true;
         try DeleteFile ('.\Guild\' + GuildObject.GuildName + 'GUser.SDB'); except end;
      end;
   end;

   DB.SaveToFile ('.\Guild\DeletedGuild.SDB');
   DB.Free;

   MagicClass.CompactGuildMagic;
end;

procedure TGuildList.DeleteStone (aGuildName : String);
var
   i : Integer;
   GuildObject : TGuildObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         GuildObject.SelfData.Durability := 0;
         CompactGuild;
         exit;
      end;
   end;
end;

function TGuildList.GetGuildObject (aGuildName : String) : TGuildObject;
var
   i : Integer;
   GuildObject : TGuildObject;
begin
   Result := nil;
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = aGuildName then begin
         Result := GuildObject;
         exit;
      end;
   end;
end;

function TGuildList.GetGuildObjectByMagicName (aMagicName : String) : TGuildObject;
var
   i : Integer;
   GuildObject : TGuildObject;
begin
   Result := nil;
   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.SelfData.GuildMagic = aMagicName then begin
         Result := GuildObject;
         exit;
      end;
   end;
end;

function TGuildList.GetCharInformation (aName : String) : String;
var
   i, j : Integer;
   GuildObject : TGuildObject;
begin
   Result := '';

   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = '' then continue;
      if GuildObject.SelfData.Sysop = aName then begin
         Result := format ('%s门派的门主', [GuildObject.GuildName]);
         exit;
      end;
      for j := 0 to 3 - 1 do begin
         if GuildObject.SelfData.SubSysop[j] = aName then begin
            Result := format ('%s门派的副门主', [GuildObject.GuildName]);
            exit;
         end;
      end;
   end;
end;

function TGuildList.GetInformation (aName : String) : String;
var
   i : Integer;
   GuildObject : TGuildObject;
begin
   Result := '';

   for i := 0 to DataList.Count - 1 do begin
      GuildObject := DataList.Items [i];
      if GuildObject.GuildName = '' then continue;
      Result := GuildObject.GetInformation;
   end;
end;

end.

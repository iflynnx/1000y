unit uManager;

interface

uses
   SysUtils, Classes, DefType, AUtil32, uAnsTick, AnsStringCls;

type

   TManager = class
   private
      RegenedTick : Integer;
   public
      ServerID : integer;
      SmpName : String;
      MapName : String;
      ObjName : String;
      RofName : String;
      TilName : String;
      Title : String;
      SoundBase : String;
      SoundEffect : String;
      Phone : Pointer;
      Maper : Pointer;
      boUseDrug : Boolean;
      boGetExp : Boolean;
      boBigSay : Boolean;
      boMakeGuild : Boolean;
      boPosDie : Boolean;
      boHit : Boolean;
      boWeather : Boolean;
      boPrison : Boolean;

      EffectTick : Integer;
      EffectInterval : Integer;
      RegenInterval : Integer;

      TargetServerID : Integer;
      TargetX, TargetY : Word;

      TotalHour, TotalMin, TotalSec : Word;
      RemainHour, RemainMin, RemainSec : Word;

      MonsterList : Pointer;
      ItemList : Pointer;
      StaticItemList : Pointer;
      DynamicObjectList : Pointer;
      NpcList : Pointer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Update (CurTick : LongInt);

      procedure CalcTime (nTick : Integer; var nHour, nMin, nSec : Word);
   end;

   TManagerList = class
   private
      DataList : TList;

      function    GetCount : Integer;
   public
      constructor Create;
      destructor  Destroy; override;

      procedure   Clear;
      function    LoadFromFile (aFileName : String) : Boolean;
      procedure   ReLoadFromFile;

      procedure   Update (CurTick : LongInt);
      function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;

      function    GetManagerByIndex (aIndex : Integer) : TManager;
      function    GetManagerByServerID (aServerID : Integer) : TManager;
      function    GetManagerByTitle (aTitle : String) : TManager;
      // function    GetManagerByGuild (aGuild, aName : String) : TManager;      

      property    Count : Integer read GetCount;
   end;

var
   ManagerList : TManagerList;

implementation

uses
   svMain, svClass, UserSDB, MapUnit, FieldMsg, uMonster, uNpc, BasicObj,
   uGuild, uUser, uDoorGen;

constructor TManager.Create;
begin
   EffectTick := 0;
   EffectInterval := 0;
   RegenedTick := mmAnsTick;

   MonsterList := nil;
   ItemList := nil;
   StaticItemList := nil;
   DynamicObjectList := nil;
   NpcList := nil;

   Phone := nil;
   Maper := nil;
end;

destructor TManager.Destroy;
begin
   if MonsterList <> nil then TMonsterList (MonsterList).Free;
   if ItemList <> nil then TItemList (ItemList).Free;
   if StaticItemList <> nil then TStaticItemList (StaticItemList).Free;
   if DynamicObjectList <> nil then TDynamicObjectList (DynamicObjectList).Free;
   if NpcList <> nil then TNpcList (NpcList).Free;

   if Phone <> nil then TFieldPhone (Phone).Free;
   if Maper <> nil then TMaper (Maper).Free;

   inherited Destroy;
end;

procedure TManager.CalcTime (nTick : Integer; var nHour, nMin, nSec : Word);
var
   SecValue : Integer;
begin
   SecValue := nTick div 100;
   nHour := SecValue div 3600;
   SecValue := SecValue - nHour * 3600;
   nMin := SecValue div 60;
   SecValue := SecValue - nMin * 60;
   nSec := SecValue;
end;

procedure TManager.Update (CurTick : LongInt);
begin
   if (RegenInterval > 0) and (RegenedTick + 100 <= CurTick) then begin
      CalcTime (RegenedTick + RegenInterval - CurTick, RemainHour, RemainMin, RemainSec);
   end;
   if (RegenInterval > 0) and (RegenedTick + RegenInterval <= CurTick) then begin
      RegenedTick := CurTick;

      if (TargetX > 0) and (TargetY > 0) then begin
         UserList.MoveByServerID (ServerID, TargetServerID, TargetX, TargetY);
      end;
      
      TMonsterList (MonsterList).ReLoadFromFile;
      TNpcList (NpcList).ReLoadFromFile;
      TDynamicObjectList (DynamicObjectList).ReLoadFromFile;
      TItemList (ItemList).AllClear;

      if ObjectChecker.Manager = Self then begin
         ObjectChecker.RegenData;
      end;
   end else begin
      TMonsterList (MonsterList).Update (CurTick);
      TItemList (ItemList).Update (CurTick);
      TStaticItemList (StaticItemList).Update (CurTick);
      TDynamicObjectList (DynamicObjectList).Update (CurTick);
      TNpcList (NpcList).Update (CurTick);

      if SoundEffect <> '' then begin
         if CurTick >= EffectTick + EffectInterval then begin
            UserList.SendSoundEffect (Self, SoundEffect);
            EffectTick := CurTick;
         end;
      end;
   end;
end;

constructor TManagerList.Create;
begin
   DataList := TList.Create;
   LoadFromFile ('.\Init\MAP.SDB');
end;

destructor TManagerList.Destroy;
begin
   if DataList <> nil then begin
      Clear;
      DataList.Destroy;
   end;
end;

function TManagerList.GetCount : Integer;
begin
   Result := 0;
   if DataList <> nil then begin
      Result := DataList.Count;
   end;

   inherited Destroy;
end;

procedure TManagerList.Clear;
var
   i : Integer;
   Manager : TManager;
begin
   if DataList <> nil then begin
      for i := 0 to DataList.Count - 1 do begin
         Manager := DataList.Items[i];
         if Manager <> nil then Manager.Free;
      end;
   end;
end;

function TManagerList.LoadFromFile (aFileName : String) : Boolean;
var
   i : Integer;
   Manager : TManager;
   MapDB : TUserStringDB;
   iName : String;
begin
   Result := false;
   
   MapDB := TUserStringDB.Create;
   MapDB.LoadFromFile (aFileName);

   for i := 0 to MapDB.Count - 1 do begin
      iName := MapDB.GetIndexName (i);
      if iName <> '' then begin
         Manager := TManager.Create;
         
         Manager.ServerId := StrToInt (iName);
         Manager.SmpName := MapDB.GetFieldValueString (iName, 'SmpName');
         Manager.MapName := MapDB.GetFieldValueString (iName, 'MapName');
         Manager.ObjName := MapDB.GetFieldValueString (iName, 'ObjName');
         Manager.RofName := MapDB.GetFieldValueString (iName, 'RofName');
         Manager.TilName := MapDB.GetFieldValueString (iName, 'TilName');
         Manager.Title := MapDB.GetFieldValueString (iName, 'MapTitle');
         Manager.SoundBase := MapDB.GetFieldValueString (iName, 'SoundBase');
         Manager.SoundEffect := MapDB.GetFieldValueString (iName, 'SoundEffect');

         Manager.boUseDrug := MapDB.GetFieldValueBoolean (iName, 'boUseDrug');
         Manager.boGetExp := MapDB.GetFieldValueBoolean (iName, 'boGetExp');
         Manager.boBigSay := MapDB.GetFieldValueBoolean (iName, 'boBigSay');
         Manager.boMakeGuild := MapDB.GetFieldValueBoolean (iName, 'boMakeGuild');
         Manager.boPosDie := MapDB.GetFieldValueBoolean (iName, 'boPosDie');
         Manager.boHit := MapDB.GetFieldValueBoolean (iName, 'boHit');
         Manager.boWeather := MapDB.GetFieldValueBoolean (iName, 'boWeather');
         Manager.boPrison := MapDB.GetFieldValueBoolean (iName, 'boPrison');

         Manager.RegenInterval := MapDB.GetFieldValueInteger (iName, 'RegenInterval');
         Manager.EffectInterval := MapDB.GetFieldValueInteger (iName, 'EffectInterval');

         Manager.TargetServerID := MapDB.GetFieldValueInteger (iName, 'TargetServerID');
         Manager.TargetX := MapDB.GetFieldValueInteger (iName, 'TargetX');
         Manager.TargetY := MapDB.GetFieldValueInteger (iName, 'TargetY');

         Manager.CalcTime (Manager.RegenInterval, Manager.TotalHour, Manager.TotalMin, Manager.TotalSec);
         Manager.CalcTime (Manager.RegenInterval, Manager.RemainHour, Manager.RemainMin, Manager.RemainSec);

         Manager.Maper := TMaper.Create ('.\Smp\' + Manager.SmpName);
         Manager.Phone := TFieldPhone.Create (Manager);

         Manager.MonsterList := TMonsterList.Create (Manager);
         Manager.ItemList := TItemList.Create (10, Manager);
         Manager.StaticItemList := TStaticItemList.Create (10, Manager);
         Manager.DynamicObjectList := TDynamicObjectList.Create (10, Manager);
         Manager.NpcList := TNpcList.Create (Manager);

         DataList.Add (Manager);
      end;
   end;

   MapDB.Free;

   Result := true;
end;

procedure TManagerList.ReLoadFromFile;
var
   i : Integer;
   Manager : TManager;
begin
   for i := 0 to DataList.Count - 1 do begin
      Manager := DataList[i];
      if Manager <> nil then begin
         TMonsterList (Manager.MonsterList).Free;
         TNpcList (Manager.NpcList).Free;

         Manager.MonsterList := nil;
         Manager.NpcList := nil;

         Manager.MonsterList := TMonsterList.Create (Manager);
         Manager.NpcList := TNpcList.Create (Manager);
      end;
   end;
end;

function TManagerList.GetManagerByIndex (aIndex : Integer) : TManager;
begin
   Result := nil;

   if DataList = nil then exit;
   if (aIndex < 0) or (aIndex >= DataList.Count) then exit;

   Result := DataList.Items[aIndex];
end;

function TManagerList.GetManagerByServerID (aServerID : Integer) : TManager;
var
   i : Integer;
   Manager : TManager;
begin
   Result := nil;

   if DataList = nil then exit;

   for i := 0 to DataList.Count - 1 do begin
      Manager := DataList.Items [i];
      if Manager <> nil then begin
         if Manager.ServerID = aServerID then begin
            Result := Manager;
            exit;
         end;
      end;
   end;
end;

function TManagerList.GetManagerByTitle (aTitle : String) : TManager;
var
   i : Integer;
   Manager : TManager;
begin
   Result := nil;

   if DataList = nil then exit;

   for i := 0 to DataList.Count - 1 do begin
      Manager := DataList.Items [i];
      if Manager <> nil then begin
         if Manager.Title = aTitle then begin
            Result := Manager;
            exit;
         end;
      end;
   end;
end;

{
function TManagerList.GetManagerByGuild (aGuild, aName : String) : TManager;
var
   i : Integer;
   Manager : TManager;
begin
   Result := nil;

   if DataList = nil then exit;

   for i := 0 to DataList.Count - 1 do begin
      Manager := DataList.Items [i];
      if Manager <> nil then begin
         if TGuildList(Manager.GuildList).CheckGuildUser(aGuild, aName) = TRUE then begin
            Result := Manager;
            exit;
         end;
      end;
   end;
end;
}

procedure TManagerList.Update (CurTick : LongInt);
var
    i : Integer;
    Manager : TManager;
begin
   for i := 0 to DataList.Count - 1 do begin
      Manager := DataList.Items [i];
      if Manager <> nil then begin
         Manager.Update (CurTick);
      end;
   end;
end;

function  TManagerList.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i : integer;
   nByte : Byte;
   SenderName, GuildName: String;
   tmpUser : TUser;
   tmpManager : TManager;
begin
   Result := PROC_FALSE;

   case Msg of
      FM_CHECKGUILDUSER :
         begin
            SenderName := StrPas (@aSubData.SubName);
            GuildName := StrPas (@aSubData.GuildName);
            if GuildList.CheckGuildUser(GuildName, SenderName) = TRUE then begin
               Result := PROC_TRUE;
               exit;
            end;
            Result := PROC_FALSE;
         end;
      FM_REMOVEGUILDMEMBER :
         begin
            SenderName := StrPas (@aSubData.SubName);
            GuildName := StrPas (@aSubData.GuildName);
            tmpUser := UserList.GetUserPointer (SenderName);
            if tmpUser <> nil then begin
               if tmpUser.GuildName = GuildName then begin
                  tmpUser.GuildName := '';
                  tmpUser.GuildGrade := '';
                  StrPCopy(@tmpUser.BasicData.Guild, '');
                  tmpUser.BocChangeProperty;
                  tmpUser.SendClass.SendChatMessage(GuildName + '你已经脱离门派了.', SAY_COLOR_NORMAL);
                  Result := PROC_TRUE;
               end;
            end;
         end;
      FM_ALLOWGUILDSYSOPNAME :
         begin
            SenderName := StrPas (@aSubData.SubName);
            GuildName := StrPas (@aSubData.GuildName);
            if not GuildList.AllowGuildCondition (GuildName, SenderName) then begin
               Result := PROC_FALSE;
               exit;
            end;
            Result := PROC_TRUE;
         end;
      FM_ALLOWGUILDNAME :
         begin
            SenderName := StrPas (@aSubData.SubName);
            GuildName := StrPas (@aSubData.GuildName);
            if not GuildList.AllowGuildCondition (GuildName, SenderName) then begin
               Result := PROC_FALSE;
               exit;
            end;

            GuildList.AllowGuildName (SenderInfo.id, TRUE, GuildName, SenderName);
            Result := PROC_TRUE;
         end;
      FM_CURRENTUSER :
         begin
            SetWordString (aSubData.SayString, UserList.GetUserList);
         end;
      FM_ADDITEM :
         begin
            tmpManager := GetManagerByServerID (aSubData.ServerId);
            case aSubData.ItemData.rKind of
               ITEM_KIND_GUILDSTONE :
                  begin
                     if tmpManager.boMakeGuild = true then begin
                        nByte := TMaper (tmpManager.Maper).GetAreaIndex (SenderInfo.nX, SenderInfo.nY);
                        if AreaClass.CanMakeGuild (nByte) = true then begin
                           if TMaper (tmpManager.Maper).isGuildStoneArea (SenderInfo.nX, SenderInfo.nY) = false then begin
                              GuildList.AddGuildObject ('', StrPas (@SenderInfo.Name), tmpManager.ServerID, SenderInfo.nx, SenderInfo.ny);
                              Result := PROC_TRUE;
                           end;
                        end;
                     end;
                  end;
               ITEM_KIND_STATICITEM :
                  begin
                     Result := TStaticItemList(tmpManager.StaticItemList).AddStaticItemObject (aSubData.ItemData, SenderInfo.Id, SenderInfo.nx, SenderInfo.ny);
                  end;
               else
                  begin
                     TItemList(tmpManager.ItemList).AddItemObject (aSubData.ItemData, SenderInfo.Id, SenderInfo.nx, SenderInfo.ny);
                     Result := PROC_TRUE;
                  end;
            end;
         end;

   end;
end;

end.

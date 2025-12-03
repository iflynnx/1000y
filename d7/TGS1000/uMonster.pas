unit uMonster;

interface

uses
  Windows, Classes, SysUtils, svClass,subutil, uAnsTick, AnsUnit,
  BasicObj, FieldMsg, MapUnit, DefType, Autil32, aiunit, uUser,
  uAIPath, uManager, uSkills, uMopSub;

type

   TMonster = class (TLifeObject)
   private
      pSelfData : PTMonsterData;

      AttackSkill : TAttackSkill;

      HaveItemClass : TMopHaveItemClass;
      HaveMagicClass : TMopHaveMagicClass;

      procedure  SetAttackSkillData;
   protected
      procedure  SetMonsterData;
      function   FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;

      function   Regen : Boolean;
      function   Start : Boolean;
   public
      MonsterName : String;

      constructor Create;
      destructor  Destroy; override;

      procedure   InitialEx (aMonsterName: String);
      procedure   Initial (aMonsterName: string; ax, ay, aw: integer);
      procedure   StartProcess; override;
      procedure   EndProcess; override;

      procedure   Update (CurTick: integer); override;

      procedure   CallMe(x, y : Integer);

      function    GetAttackSkill : TAttackSkill;
      procedure   SetAttackSkill (aAttackSkill : TAttackSkill);
   end;

   TMonsterList = class
   private
      Manager : TManager;

      CurProcessPos : integer;
      DataList : TList;

      function  GetCount: integer;
      procedure Clear;
   public
      constructor Create (aManager : TManager);
      destructor  Destroy; override;

      procedure   AddMonster (aMonsterName: string; ax, ay, aw: integer; aMemberStr : String);
      function    CallMonster (aMonsterName: string; ax, ay, aw: integer; aName : String) : TMonster;
      function    CopyMonster (aBasicData : TBasicData; aAttackSkill : TAttackSkill) : TMonster;
      procedure   ComeOn (aName : String; X, Y : Word);

      function    FindMonster (aMonsterName : String) : Integer;
      function    DeleteMonster (aMonsterName : String) : Boolean;

      procedure   ReLoadFromFile;

      procedure   Update (CurTick: integer);

      function    GetMonsterByName(aName : String) : TMonster;

      property    Count : integer read GetCount;
   end;

implementation

uses
   SvMain;

/////////////////////////////////////
//       Monster
////////////////////////////////////
constructor TMonster.Create;
var
   i : Integer;
begin
   inherited Create;

   pSelfData := nil;
   AttackSkill := nil;

   HaveItemClass := TMopHaveItemClass.Create (Self);
   HaveMagicClass := TMopHaveMagicClass.Create (SElf);
end;

destructor TMonster.Destroy;
begin
   HaveMagicClass.Free;
   HaveItemClass.Free;
   
   pSelfData := nil;
   if (AttackSkill <> nil) and (FboCopy = false) then begin
      AttackSkill.Free;
   end;
   inherited Destroy;
end;

function TMonster.Regen : Boolean;
var
   i, xx, yy : word;
begin
   Result := true;

   for i := 0 to 10 - 1 do begin
      xx := CreatedX - ActionWidth + Random(ActionWidth * 2);
      yy := CreatedY - ActionWidth + Random(ActionWidth * 2);
      if Maper.isMoveable (xx, yy) then begin
         EndProcess;

         BasicData.x := xx;
         BasicData.y := yy;
         BasicData.nx := xx;
         BasicData.ny := yy;
         BasicData.Feature.rHitMotion := AM_HIT1;

         CurLife := MaxLife;

         StartProcess;
         exit;
      end;
   end;
   Result := false;
end;

function TMonster.Start : Boolean;
var
   i, xx, yy : word;
begin
   Result := true;

   xx := BasicData.X;
   yy := BasicData.Y;
   for i := 0 to 10 - 1 do begin
      if Maper.isMoveable (xx, yy) then begin
         BasicData.x := xx;
         BasicData.y := yy;
         BasicData.nx := xx;
         BasicData.ny := yy;
         BasicData.Feature.rHitMotion := AM_HIT1;

         CurLife := MaxLife;

         StartProcess;
         exit;
      end;
      xx := CreatedX - ActionWidth + Random(ActionWidth * 2);
      yy := CreatedY - ActionWidth + Random(ActionWidth * 2);
   end;
   Result := false;
end;

procedure TMonster.SetAttackSkillData;
begin
   if pSelfData = nil then exit;
   if AttackSkill = nil then exit;

   AttackSkill.boViewHuman := pSelfData^.rboViewHuman;
   AttackSkill.boAutoAttack := pSelfData^.rboAutoAttack;
   AttackSkill.boAttack := pSelfData^.rboAttack;
   AttackSkill.EscapeLife := pSelfData^.rEscapeLife;
   AttackSkill.ViewWidth := pSelfData^.rViewWidth;
   AttackSkill.boChangeTarget := pSelfData^.rboChangeTarget;
   AttackSkill.boBoss := pSelfData^.rboBoss;
   AttackSkill.boVassal := pSelfData^.rboVassal;
   AttackSkill.VassalCount := pSelfData^.rVassalCount;

   AttackSkill.SetAttackMagic (pSelfData^.rAttackMagic);
end;

procedure TMonster.SetMonsterData;
var
   i : Integer;
begin
   if pSelfData = nil then exit;

   LifeData.damageBody      := LifeData.damageBody      + pSelfData^.rDamage;
   LifeData.damageHead      := LifeData.damageHead      + 0;
   LifeData.damageArm       := LifeData.damageArm       + 0;
   LifeData.damageLeg       := LifeData.damageLeg       + 0;
   LifeData.AttackSpeed     := LifeData.AttackSpeed     + pSelfData^.rAttackSpeed;
   LifeData.avoid           := LifeData.avoid           + pSelfData^.ravoid;
   LifeData.recovery        := LifeData.recovery        + pSelfData^.rrecovery;
   LifeData.armorBody       := LifeData.armorBody       + pSelfData^.rarmor;
   LifeData.armorHead       := LifeData.armorHead       + pSelfData^.rarmor;
   LifeData.armorArm        := LifeData.armorArm        + pSelfData^.rarmor;
   LifeData.armorLeg        := LifeData.armorLeg        + pSelfData^.rarmor;
   LifeData.HitArmor        := pSelfData^.rHitArmor;

   BasicData.Feature.raninumber := pSelfData^.rAnimate;
   BasicData.Feature.rImageNumber := pSelfData^.rShape;

   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      HaveItemClass.AddDropItem (pSelfData^.rHaveItem[i].rName, pSelfData^.rHaveItem[i].rCount); 
   end;

   MaxLife := pSelfData^.rLife;
   CurLife := MaxLife;

   SetAttackSkillData;

   WalkSpeed := pSelfData^.rWalkSpeed;
   SoundNormal := pSelfData^.rSoundNormal;
   SoundAttack := pSelfData^.rSoundAttack;
   SoundDie := pSelfData^.rSoundDie;
   SoundStructed := pSelfData^.rSoundStructed;
end;

procedure  TMonster.Initial (aMonsterName: string; ax, ay, aw: Integer);
var
   i : Integer;
   MonsterData : TMonsterData;
begin
   MonsterClass.GetMonsterData (aMonsterName, pSelfData);

   inherited Initial (aMonsterName, StrPas (@pSelfData^.rViewName));

   if AttackSkill = nil then begin
      AttackSkill := TAttackSkill.Create (Self);
   end;

   HaveItemClass.Clear;
   
   SetMonsterData;

   MonsterName := aMonsterName;

   Basicdata.id := GetNewMonsterId;
   BasicData.X := ax;
   BasicData.Y := ay;
   BasicData.ClassKind := CLASS_MONSTER;
   BasicData.Feature.rrace := RACE_MONSTER;

   CreatedX := ax;
   CreatedY := ay;

   ActionWidth := aw;

   HaveMagicClass.Init (pSelfData^.rHaveMagic);
end;

procedure  TMonster.InitialEx (aMonsterName: String);
var
   i : Integer;
   MonsterData : TMonsterData;
begin
   MonsterClass.GetMonsterData (aMonsterName, pSelfData);

   StrPCopy (@BasicData.Name, StrPas (@pSelfData^.rName));
   StrPCopy (@BasicData.ViewName, StrPas (@pSelfData^.rViewName));

   inherited InitialEx;

   if AttackSkill = nil then begin
      AttackSkill := TAttackSkill.Create (Self);
   end;

   HaveItemClass.DropItemClear;
   
   SetMonsterData;

   MonsterName := aMonsterName;

   HaveMagicClass.Init (pSelfData^.rHaveMagic);
end;

procedure TMonster.StartProcess;
var
   SubData : TSubData;
   MonsterData : TMonsterData;
begin
   inherited StartProcess;

   if AttackSkill = nil then begin
      AttackSkill := TAttackSkill.Create (Self);

      AttackSkill.TargetX := CreateX - 3 + Random (6);
      AttackSkill.TargetY := CreateY - 3 + Random (6);

      SetAttackSkillData;
   end;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);

   if FboCopy = true then begin
      ShowEffect (1, lek_none);
   end;

   // 은신술
   if HaveMagicClass.isHaveHideMagic then begin
      if HaveMagicClass.RunHaveHideMagic (BasicData.LifePercent) then begin
         SetHideState (hs_0);
      end;
   end;
end;

procedure TMonster.EndProcess;
var
   SubData : TSubData;
begin
   if FboRegisted = FALSE then exit;
   
   SetAttackSkill (nil);
   FboCopy := false;

   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

procedure TMonster.CallMe(x, y : Integer);
begin
   EndProcess;
   BasicData.x := x;
   BasicData.y := y;
   StartProcess;
end;

function  TMonster.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i, j, lifepercent : Integer;
   tx, ty, len, len2, key: word;
   Str : String;
   bo : TBasicObject;
   SubData : TSubData;
   ItemData : TItemData;
   MagicData : TMagicData;
   Monster : TMonster;
label abcde;

begin
   Result := PROC_FALSE;

   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;
   if FboAllowDelete = true then exit;

   if LifeObjectState = los_die then exit;

   case Msg of
      FM_IAMHERE, FM_HIT, FM_STRUCTED, FM_CHANGEFEATURE, FM_MOVE, FM_SHOW:
         begin
            if SenderInfo.id = BasicData.id then goto abcde;
            if SenderInfo.Feature.rrace <> RACE_HUMAN then goto abcde;        // 주석이면 몬스터도 공격
            if SenderInfo.Feature.rHideState = hs_0 then goto abcde;

            if (SenderInfo.Feature.rFeatureState = wfs_die) then begin
               if SenderInfo.id = AttackSkill.CurNearViewHumanId then AttackSkill.CurNearViewHumanId := 0;
               if SenderInfo.id = AttackSkill.HateHumanId then AttackSkill.HateHumanId := 0;
               goto abcde;
            end;
            len := GetLargeLength (BasicData.x, BasicData.y, SenderInfo.x, SenderInfo.y);
            if AttackSkill.ViewWidth < len then exit;
            if AttackSkill.boViewHuman = FALSE then exit;
            bo := nil;
            if AttackSkill.CurNearViewHumanID <> 0 then
               bo := TBasicObject (GetViewObjectById (AttackSkill.CurNearViewHumanId));
            if bo <> nil then begin
               len2 := GetLargeLength (BasicData.x, BasicData.y, bo.Posx, bo.Posy);
               if len2 > len then AttackSkill.CurNearViewHumanId := SenderInfo.id;
            end else AttackSkill.CurNearViewHumanId := SenderInfo.id;
         end;
      FM_HIDE :
         begin
            if SenderInfo.id = BasicData.id then goto abcde;
            if SenderInfo.id = AttackSkill.CurNearViewHumanId then AttackSkill.CurNearViewHumanId := 0;
            if SenderInfo.id = AttackSkill.HateHumanId then AttackSkill.HateHumanId := 0;
         end;
   end;
abcde:

   case Msg of
      FM_IAMHERE :
         begin
            if SenderInfo.ID = BasicData.ID then exit;
            if SenderInfo.Feature.rRace = RACE_ITEM then begin
               if (LifeObjectState <> los_none) and (LifeObjectState <> los_attack) then exit;

               // 수집술
               if not HaveMagicClass.isHavePickMagic then exit;
               if not HaveMagicClass.RunHavePickMagic (BasicData.LifePercent, StrPas (@SenderInfo.Name)) then exit;
               if HaveItemClass.HaveItemFreeCount > 0 then begin
                  AttackSkill.SetSaveIDandPos (SenderInfo.ID, SenderInfo.X, SenderInfo.Y, los_eat);
                  LifeObjectState := los_movework;
                  exit;
               end;
            end;
         end;
      FM_SHOW :
         begin
         end;
      FM_ADDITEM :
         begin
            if LifeObjectState = los_die then exit;
            if SenderInfo.Feature.rrace = RACE_ITEM then begin
               Str := StrPas (@aSubData.ItemData.rName);
               if HaveItemClass.AddHaveItem (Str, aSubData.ItemData.rCount, aSubData.ItemData.rColor) = true then begin
                  SetWordString (SubData.SayString, IntToStr (aSubData.ItemData.rSoundDrop.rWavNumber));
                  SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                  Result := PROC_TRUE;
               end;
            end;
         end;
      FM_CHANGEFEATURE:
         begin
            if SenderInfo.ID = BasicData.ID then exit;

            // if LifeObjectState = los_attack then exit;
            if SenderInfo.Feature.rRace <> RACE_HUMAN then exit;
            if SenderInfo.Feature.rfeaturestate <> wfs_die then exit;
            if HaveMagicClass.isHaveKillMagic then begin
               AttackSkill.SetSaveIDandPos (SenderInfo.ID, SenderInfo.X, SenderInfo.Y, los_kill);
               LifeObjectState := los_movework;
               exit;
            end;
         end;
      FM_GATHERVASSAL :
         begin
            if SenderInfo.id = BasicData.id then exit;
            if AttackSkill.boVassal and (LifeObjectState = los_none) and (aSubData.VassalCount > 0) then begin
               aSubData.VassalCount := aSubData.VassalCount - 1;
               AttackSkill.SetTargetId (aSubData.TargetId, false);
            end;
         end;
      FM_HIT,
      FM_MOVE :
         begin
            if SenderInfo.ID = BasicData.ID then exit;
            
            // 재생술
            if HaveMagicClass.isHaveHealMagic then begin
               if HaveMagicClass.RunHaveHealMagic (StrPas (@SenderInfo.Name), SenderInfo.LifePercent, SubData) then begin
                  key := GetNextDirection (BasicData.X, BasicData.Y, SenderInfo.X, SenderInfo.Y);
                  if (key <> DR_DONTMOVE) and (key <> BasicData.dir) then begin
                     CommandTurn (key);
                  end;
                  SubData.Motion := BasicData.Feature.rHitMotion;
                  SendLocalMessage (NOTARGETPHONE, FM_MOTION, BasicData, SubData);
                  ShowEffect (6, lek_follow);
                  SendLocalMessage (SenderInfo.ID, FM_HEAL, BasicData, SubData);
               end;
            end;
         end;
      FM_HEAL :
         begin
            ShowEffect (6, lek_follow);
            CurLife := CurLife + aSubData.HitData.ToHit;
            if CurLife > MaxLife then CurLife := MaxLife;

            if MaxLife <= 0 then BasicData.LifePercent := 0
            else BasicData.LifePercent := CurLife * 100 div MaxLife;
            SubData.Percent := BasicData.LifePercent;
            SendLocalMessage (NOTARGETPHONE, FM_LIFEPERCENT, BasicData, SubData);
         end;
      FM_STRUCTED :
         begin
            if SenderInfo.id = BasicData.id then begin
               if CurLife <= 0 then CurLife := 0;
               // 은신술
               if HaveMagicClass.isHaveHideMagic then begin
                  if BasicData.Feature.rHideState = hs_100 then begin
                     if HaveMagicClass.RunHaveHideMagic (BasicData.LifePercent) then begin
                        SetHideState (hs_0);
                     end;
                  end;
               end;
               // 분신술
               if HaveMagicClass.isHaveSameMagic then begin
                  if (FboCopy = false) and (LifeObjectState = los_attack) then begin
                     if HaveMagicClass.RunHaveSameMagic (BasicData.LifePercent, SubData) = true then begin
                        if CopiedList = nil then begin
                           CopiedList := TList.Create;
                        end;
                        CopiedList.Clear;
                        if BasicData.Feature.rrace = RACE_MONSTER then begin
                           for j := 0 to SubData.HitData.ToHit - 1 do begin
                              Monster := TMonsterList (Manager.MonsterList).CopyMonster (BasicData, AttackSkill);
                              if Monster <> nil then begin
                                 Monster.CopyBoss := Self;
                                 Monster.LifeObjectState := LifeObjectState;
                                 CopiedList.Add (Monster);
                              end;
                           end;
                        end;
                     end;
                  end;
               end;

               // 시약술
               if HaveMagicClass.isHaveEatMagic then begin
                  if HaveMagicClass.RunHaveEatMagic (BasicData.LifePercent, HaveItemClass, SubData) then begin
                     CurLife := CurLife + SubData.HitData.ToHit;
                     if CurLife > MaxLife then CurLife := MaxLife;

                     if MaxLife <= 0 then BasicData.LifePercent := 0
                     else BasicData.LifePercent := CurLife * 100 div MaxLife;
                     SubData.Percent := BasicData.LifePercent;
                     SendLocalMessage (NOTARGETPHONE, FM_LIFEPERCENT, BasicData, SubData);
                  end;
               end;

               if CurLife <= 0 then begin
                  AttackSkill.SetTargetId (0, true);
                  if HaveMagicClass.isHaveSwapMagic = false then begin
                     HaveItemClass.DropItemGround;
                  end;
                  exit;
               end;
               if AttackSkill.boAttack = false then exit;

               if AttackSkill.boChangeTarget then begin
                  Bo := GetViewObjectByID (AttackSkill.GetTargetID);
                  if Bo <> nil then begin
                     len := GetLargeLength (BasicData.x, BasicData.y, Bo.Posx, Bo.Posy);
                     if len > 1 then begin
                        AttackSkill.SetTargetId (aSubData.attacker, true);
                     end;
                  end;
               end;
               if isUserId (aSubData.attacker) then AttackSkill.HateHumanId := aSubData.attacker;
            end;
         end;
      FM_DEADHIT :
         begin
            if SenderInfo.id = BasicData.id then exit;
            if BasicData.Feature.rfeaturestate = wfs_die then begin Result := PROC_TRUE; exit; end;

            CurLife := 0;
            BasicData.LifePercent := 0;
            
            AttackSkill.SetTargetId (0, true);
            if HaveMagicClass.isHaveSwapMagic = false then begin
               HaveItemClass.DropItemGround;
            end;

            CommandChangeCharState (wfs_die);
         end;
      FM_SAY :
         begin
         end;
   end;
end;

procedure TMonster.Update (CurTick: integer);
var
   i : Integer;
   key : Word;
   boFlag : Boolean;
   SubData : TSubData;
   BO : TLifeObject;
   BasicObject : TBasicObject;
begin
//   inherited UpDate (CurTick);
   if (BasicData.Feature.rfeaturestate = wfs_die) and (LifeObjectState <> los_die) then begin
      LifeObjectState := los_die;
   end;
   
   case LifeObjectState of
      los_init :
         begin
            Start;
            exit;
         end;
      los_die :
         begin
            // 변신술
            if CurTick > DiedTick + 200 then begin
               if HaveMagicClass.isHaveSwapMagic then begin
                  if HaveMagicClass.RunHaveSwapMagic (BasicData.LifePercent, SubData) = true then begin
                     InitialEx (StrPas (@SubData.SubName));
                     SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                  end;
                  exit;
               end;
            end;
            if CurTick > DiedTick + 1600 then begin
               if Manager.RegenInterval = 0 then begin
                  if AttackSkill <> nil then begin
                     if AttackSkill.GetObjectBoss <> nil then begin
                        FboAllowDelete := true;
                     end;
                  end;
                  if FboAllowDelete = false then begin
                     Regen;
                  end;
                  exit;
               end;
            end;
            if CurTick > DiedTick + 800 then begin
               if Manager.RegenInterval > 0 then begin
                  FboAllowDelete := true;
                  exit;
               end;
            end;
         end;
      los_none:
         begin
            if AttackSkill <> nil then AttackSkill.ProcessNone (CurTick);
         end;
      los_escape:
         begin
            if AttackSkill <> nil then AttackSkill.ProcessEscape (CurTick);
         end;
      los_attack:
         begin
            if AttackSkill <> nil then begin
               boFlag := AttackSkill.ProcessAttack (CurTick, Self);
               if (boFlag = false) and (FboCopy = false) then begin
                  if CopiedList <> nil then begin
                     for i := 0 to CopiedList.Count - 1 do begin
                        BO := TLifeObject (CopiedList[i]);
                        BO.boAllowDelete := true;
                     end;
                  end;
               end;
            end;
         end;
      los_moveattack :
         begin
            if AttackSkill <> nil then AttackSkill.ProcessMoveAttack (CurTick);
         end;
      los_deadattack :
         begin
            if AttackSkill <> nil then AttackSkill.ProcessDeadAttack (CurTick);
         end;
      los_movework :
         begin
            if AttackSkill <> nil then AttackSkill.ProcessMoveWork (CurTick);
         end;
      los_eat :
         begin
            if AttackSkill = nil then begin
               LifeObjectState := los_none;
               exit;
            end;
            if CurTick < AttackSkill.ArrivalTick + 100 then exit;

            BasicObject := TBasicObject (GetViewObjectByID (AttackSkill.GetSaveID));
            if BasicObject <> nil then begin
               if BasicObject.BasicData.Feature.rRace = RACE_ITEM then begin
                  Phone.SendMessage (BasicObject.BasicData.ID, FM_PICKUP, BasicData, SubData);
               end;
            end;
            LifeObjectState := los_none;
            if AttackSkill.GetTargetID <> 0 then LifeObjectState := los_attack;
         end;
      los_kill :
         begin
            if AttackSkill = nil then begin
               LifeObjectState := los_none;
               exit;
            end;
            if CurTick < AttackSkill.ArrivalTick + 100 then exit;

            BasicObject := TBasicObject (GetViewObjectByID (AttackSkill.GetSaveID));
            if BasicObject <> nil then begin
               if BasicObject.BasicData.Feature.rRace = RACE_HUMAN then begin
                  if BasicObject.BasicData.Feature.rFeatureState = wfs_die then begin
                     key := GetNextDirection (BasicData.X, BasicData.Y, AttackSkill.TargetX, AttackSkill.TargetY);
                     if (key <> DR_DONTMOVE) and (key <> BasicData.dir) then begin
                        CommandTurn (key);
                     end;
                     Phone.SendMessage (BasicObject.BasicData.ID, FM_KILL, BasicData, SubData);
                  end;
               end;
            end;
            LifeObjectState := los_none;
            if AttackSkill.GetTargetID <> 0 then LifeObjectState := los_attack;
         end;
      los_move :
         begin
            if AttackSkill <> nil then begin
               if AttackSkill.ProcessMove (CurTick) = false then exit;
            end;

            LifeObjectState := los_none;
         end;
   end;
end;

function TMonster.GetAttackSkill : TAttackSkill;
begin
   if AttackSkill = nil then
      AttackSkill := TAttackSkill.Create (Self);

   Result := AttackSkill;
end;

procedure TMonster.SetAttackSkill (aAttackSkill : TAttackSkill);
begin
   if AttackSkill <> nil then begin
      if FboCopy = false then begin
         AttackSkill.Free;
      end;
   end;

   AttackSkill := aAttackSkill;
end;

////////////////////////////////////////////////////
//
//             ===  MonsterList  ===
//
////////////////////////////////////////////////////

constructor TMonsterList.Create (aManager: TManager);
begin
   Manager := aManager;

   CurProcessPos := 0;
   // AnsList := TAnsList.Create (cnt, AllocFunction, FreeFunction);
   // AnsList.MaxUnUsedCount := 10000;
   DataList := TList.Create;

   ReLoadFromFile;
end;

destructor TMonsterList.Destroy;
begin
   Clear;
   DAtaList.Free;
   
   inherited destroy;
end;

procedure TMonsterList.Clear;
var
   i : Integer;
   Monster : TMonster;
begin
   for i := 0 to DataList.Count - 1 do begin
      Monster := DataList.Items [i];
      Monster.EndProcess;
      Monster.Free;
   end;
   DataList.Clear;
end;

procedure   TMonsterList.ReLoadFromFile;
var
   i, j : integer;
   pd : PTCreateMonsterData;
   FileName : String;
   CreateMonsterList : TList;
begin
   Clear;

   FileName := format ('.\Setting\CreateMonster%d.SDB', [Manager.ServerID]);
   if not FileExists (FileName) then exit;

   CreateMonsterList := TList.Create;
   LoadCreateMonster (FileName, CreateMonsterList);
   for i := 0 to CreateMonsterList.Count - 1 do begin
      pd := CreateMonsterList.Items [i];
      if pd <> nil then begin
         for j := 0 to pd^.Count - 1 do begin
            AddMonster (pd^.mName, pd^.x, pd^.y, pd^.Width, pd^.Member);
         end;
      end;
   end;
   for i := 0 to CreateMonsterList.Count - 1 do begin
      Dispose (CreateMonsterList[i]);
   end;
   CreateMonsterList.Clear;
   CreateMonsterList.Free;
end;

function  TMonsterList.GetCount: integer;
begin
   Result := DataList.Count;
end;

procedure TMonsterList.AddMonster (aMonsterName: string; ax, ay, aw: integer; aMemberStr : String);
var
   Monster, Member : TMonster;
   str, MemberName, MemberCount : String;
   i, Count : Integer;
   AttackSkill, tmpAttackSkill : TAttackSkill;
begin
   Monster := TMonster.Create;
   if Monster <> nil then begin
      Monster.SetManagerClass (Manager);
      Monster.Initial (aMonsterName, ax, ay, aw);
      DataList.Add (Monster);
      if aMemberStr <> '' then begin
         AttackSkill := Monster.GetAttackSkill;
         AttackSkill.SetGroupSkill;
         str := aMemberStr;
         while str <> '' do begin
            str := GetValidStr3 (str, MemberName, ':');
            if MemberName = '' then break;
            str := GetValidStr3 (str, MemberCount, ':');
            if MemberCount = '' then break;
            Count := _StrToInt (MemberCount);

            for i := 0 to Count - 1 do begin
               Member := TMonster.Create;
               if Member <> nil then begin
                  Member.SetManagerClass (Manager);
                  Member.Initial (MemberName, ax, ay, aw);
                  DataList.Add (Member);
                  AttackSkill.AddGroup (Member);
                  tmpAttackSkill := Member.GetAttackSkill;
                  if tmpAttackSkill <> nil then
                     tmpAttackSkill.SetBoss (Monster);
               end;
            end;
         end;
      end;
   end;
end;

function TMonsterList.CopyMonster (aBasicData : TBasicData; aAttackSkill : TAttackSkill) : TMonster;
var
   Monster : TMonster;
begin
   Result := nil;
   
   Monster := TMonster.Create;
   if Monster <> nil then begin
      Monster.SetManagerClass (Manager);
      Monster.SetAttackSkill (aAttackSkill);
      Monster.FboCopy := true;
      Monster.Initial (StrPas (@aBasicData.Name), aBasicData.x, aBasicData.y, 4);
      if Monster.Start = false then begin
         Monster.Free;
         exit;
      end;
      DataList.Add (Monster);

      Result := Monster;
   end;
end;

function TMonsterList.FindMonster (aMonsterName : String) : Integer;
var
   i, iCount : Integer;
   Monster : TMonster;
begin
   Result := 0;

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      Monster := DataList.Items [i];
      if Monster.MonsterName = aMonsterName then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMonsterList.DeleteMonster (aMonsterName : String) : Boolean;
var
   i, iCount : Integer;
   Monster : TMonster;
begin
   Result := false;

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      Monster := DataList.Items [i];
      if Monster.MonsterName = aMonsterName then begin
         Monster.FboAllowDelete := true;
         Inc (iCount);
      end;
   end;
   if iCount > 0 then Result := true;
end;

function TMonsterList.CallMonster (aMonsterName: string; ax, ay, aw: integer; aName : String) : TMonster;
var
   Monster : TMonster;
   AttackSkill : TAttackSkill;
begin
   Result := nil;
   
   Monster := TMonster.Create;
   if Monster <> nil then begin
      Monster.SetManagerClass (Manager);
      Monster.Initial (aMonsterName, ax, ay, aw);
      if Monster.Start = false then begin
         Monster.Free;
         exit;
      end;
      AttackSkill := Monster.GetAttackSkill;
      if AttackSkill <> nil then begin
         AttackSkill.SetDeadAttackName (aName);
      end;
      DataList.Add (Monster);

      Result := Monster;
   end;
end;


function TMonsterList.GetMonsterByName(aName : String) : TMonster;
var
   i : Integer;
   Monster : TMonster;
begin
   Result := nil;
   for i := 0 to DataList.Count - 1 do begin
      Monster := DataList.Items [i];
      if Monster.MonsterName = aName then begin
         if Monster.BasicData.Feature.rfeaturestate = wfs_normal then begin
            Result := Monster;
            exit;
         end;
      end;
   end;
end;

procedure TMonsterList.Update (CurTick: integer);
var
   i : integer;
   Monster : TMonster;
begin
   if CurProcessPos >= DataList.Count then CurProcessPos := 0;

   for i := 0 to ProcessListCount - 1 do begin
      if DataList.Count = 0 then break;
      if CurProcessPos >= DataList.Count then CurProcessPos := 0;
      Monster := DataList [CurProcessPos];
      if Monster.FboAllowDelete = true then begin
         Monster.EndProcess;
         Monster.Free;
         DataList.Delete (CurProcessPos);
      end else begin
         try
            Monster.Update (CurTick);
            Inc (CurProcessPos);
         except
            Monster.FBoAllowDelete := true;
            frmMain.WriteLogInfo (format ('TMonsterList.Update (%s) failed', [Monster.MonsterName]));
         end;
      end;
   end;
end;

procedure TMonsterList.ComeOn (aName : String; X, Y : Word);
var
   i : Integer;
   Monster : TMonster;
begin
   for i := 0 to DataList.Count - 1 do begin
      Monster := DataList.Items [i];
      if StrPas (@Monster.BasicData.Name) = aName then begin
         if Monster.FboAllowDelete = true then continue;
         if Monster.AttackSkill = nil then continue;
         Monster.AttackSkill.SetSaveIDandPos (0, X, Y, los_none);
         Monster.LifeObjectState := los_move;
      end;
   end;
end;

end.

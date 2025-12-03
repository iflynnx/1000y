unit uSkills;

interface

uses
   Windows, Classes, SysUtils, BasicObj, DefType, uAnsTick, AnsStringCls;

const
   DIVRESULT_NONE = 0;
   DIVRESULT_WHATSELL = 1;
   DIVRESULT_WHATBUY = 2;
   DIVRESULT_SELLITEM = 3;
   DIVRESULT_BUYITEM = 4;
   DIVRESULT_HOWMUCH = 5;

type
   TSpeechData = record
      rSayString : String;
      rSpeechTick : integer;
      rDelayTime : integer;
   end;
   PTSpeechData = ^TSpeechData;

   TDeallerData = record
      rHearString : String;
      rSayString : String;
      rNeedItem : array[0..5 - 1] of TCheckItem;
      rGiveItem : array[0..5 - 1] of TCheckItem;
   end;
   PTDeallerData = ^TDeallerData;

   TGroupSkill = class;

   TLifeObject = class (TBasicObject)             // 蜡历绰 力寇....
   private
      OldPos : TPoint;
   protected
      CreatedX, CreatedY, ActionWidth : word;
      
      DontAttacked : Boolean; // 厚公厘...
      SoundNormal : TEffectData;
      SoundAttack : TEffectData;
      SoundDie : TEffectData;
      SoundStructed : TEffectData;

      FreezeTick : integer;
      DiedTick : integer;
      HitedTick : integer;
      WalkTick : integer;

      WalkSpeed : integer;
      LifeData : TLifeData;
      LifeObjectState : TLifeObjectState;
      CurLife, MaxLife : integer;

      FBoCopy : Boolean;
      CopiedList : TList;
      CopyBoss : TLifeObject;

      procedure InitialEx;
      procedure Initial (aMonsterName, aViewName : String);
      procedure StartProcess; override;
      procedure EndProcess; override;
      function  AllowCommand (CurTick: integer): Boolean;
      function  CommandHited (aAttacker: integer; aHitData: THitData; apercent: integer): integer;
      procedure CommandChangeCharState (aFeatureState: TFeatureState);
      procedure CommandHit (CurTick: integer);
      procedure CommandTurn (adir: word);
      procedure CommandSay (astr: string);
      function  ShootMagic (var aMagic: TMagicData; Bo : TBasicObject) : Boolean;
      function  GotoXyStand (ax, ay: word): integer;
      function  GotoXyStandAI (ax, ay : word) : Integer;
      function  FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;

      procedure ShowEffect (aEffectNumber : Word; aEffectKind : TLightEffectKind);
   public
      constructor Create;
      destructor  Destroy; override;

      function GetLifeObjectState : TLifeObjectState;
      procedure CopyDie (aBasicObject : TBasicObject);
      procedure CopyBossDie;

      procedure SetHideState (aHideState : THiddenState);
   end;

   TBuySellSkill = class
   private
      BasicObject : TBasicObject;

      boLogItem : Boolean;

      BuyItemList : TList;
      SellItemList : TList;

      FileName : String;

      procedure Clear;

      function DivHearing (aHearStr: string; var Sayer, aItemName: string; var aItemCount: integer): integer;

   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      function LoadFromFile (aFileName : String) : Boolean;
      function ProcessMessage (aStr : String; SenderInfo : TBasicData) : Boolean;

      property CanLogItem : Boolean read boLogItem;
   end;

   TSpeechSkill = class
   private
      BasicObject : TBasicObject;

      SpeechList : TList;
      CurSpeechIndex : Integer;
      SpeechTick : Integer;

      procedure Clear;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      function LoadFromFile (aFileName : String) : Boolean;
      procedure ProcessMessage (CurTick : Integer);
   end;
   
   TDeallerSkill = class
   private
      BasicObject : TBasicObject;

      DataList : TList;

      procedure Clear;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      function LoadFromFile (aFileName : String) : Boolean;
      function ProcessMessage (aStr : String; SenderInfo : TBasicData) : Boolean;
   end;

   TAttackSkill = class
   private
      BasicObject : TBasicObject;
      Boss : TBasicObject;
      ObjectBoss : TDynamicObject;

      DeadAttackName : String;

      SaveID : Integer;
      TargetID : Integer;
      EscapeID : Integer;

      SaveNextState : TLifeObjectState;

      TargetPosTick : Integer;

      AttackMagic : TMagicData;

      boGroupSkill : Boolean;
      GroupSkill : TGroupSkill;

      BowCount : Integer;
      BowAvailTick : Integer;
      BowAvailInterval : Integer;
      boBowAvail : Boolean;

      TargetStartTick : Integer;
      TargetArrivalTick : Integer;
   public
      TargetX : Integer;
      TargetY : Integer;
   
      HateHumanID : Integer;
      CurNearViewHumanId : Integer;
      EscapeLife : Integer;

      ViewWidth : integer;

      boGroup : Boolean;
      boBoss : Boolean;
      boVassal: Boolean;
      boAutoAttack : Boolean;
      boAttack : Boolean;
      boChangeTarget : Boolean;
      boViewHuman : Boolean;
      
      VassalCount: integer;

      boSelfTarget : Boolean;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      procedure SetSelf (aSelf : TBasicObject);
      procedure SetBoss (aBoss : TBasicObject);

      procedure SetObjectBoss (aBoss : TDynamicObject);
      function  GetObjectBoss : TDynamicObject;
      
      procedure SetDeadAttackName (aName : String);
      procedure SetTargetID (aTargetID : Integer; boCaller : Boolean);
      procedure SetHelpTargetID (aTargetID : Integer);
      procedure SetHelpTargetIDandPos (aTargetID, aX, aY : Integer);
      
      procedure SetSaveIDandPos (aTargetID : Integer; aTargetX, aTargetY : Word; aNextState : TLifeObjectState);

      procedure SetEscapeID (aEscapeID : Integer);
      procedure SetAttackMagic (aAttackMagic : TMagicData);
      procedure SetSelfTarget (boFlag : Boolean);

      procedure SetGroupSkill;
      procedure AddGroup (aBasicObject : TBasicObject);

      procedure ProcessNone (CurTick : Integer);
      procedure ProcessEscape (CurTick : Integer);
      procedure ProcessFollow (CurTick : Integer);
      function  ProcessAttack (CurTick : Integer; aBasicObject : TBasicObject) : Boolean;
      procedure ProcessMoveAttack (CurTick : Integer);
      procedure ProcessDeadAttack (CurTick : Integer);
      procedure ProcessMoveWork (CurTick : Integer);
      function  ProcessMove (CurTick : Integer) : Boolean;

      procedure HelpMe (aMeID, aTargetID, aX, aY : Integer);
      procedure CancelHelp (aTargetID : Integer);

      procedure NoticeDie;
      procedure MemberDie (aBasicObject : TBasicObject);

      property GetTargetID : Integer read TargetID;
      property GetSaveID : Integer read SaveID;
      property GetNextState : TLifeObjectState read SaveNextState;
      property GetDeadAttackName : String read DeadAttackName;
      property ArrivalTick : Integer read TargetArrivalTick;
   end;

   TGroupSkill = class
   private
      BasicObject : TBasicObject;
      MemberList : TList;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      procedure AddMember (aBasicObject : TBasicObject);
      procedure DeleteMember (aBasicObject : TBasicObject);
      procedure BossDie;
      procedure ChangeBoss (aBasicObject : TBasicObject);

      procedure FollowMe;
      procedure FollowEachOther;
      procedure Attack (aTargetID : Integer);
      procedure MoveAttack (aTargetID, aX, aY : Integer);
      procedure CancelTarget (aTargetID : Integer);
   end;

implementation

uses
   svMain, SubUtil, aUtil32, svClass, uNpc, uMonster, uAIPath, FieldMsg,
   MapUnit, UserSDB, uUser, uItemLog;

///////////////////////////////////
//         LifeObject
///////////////////////////////////
constructor TLifeObject.Create;
begin
   inherited Create;
   FBoCopy := false;
   CopiedList := nil;
   CopyBoss := nil;
end;

destructor  TLifeObject.Destroy;
begin
   FBoCopy := false;
   CopiedList := nil;
   CopyBoss := nil;
   inherited destroy;
end;

function TLifeObject.GetLifeObjectState : TLifeObjectState;
begin
   Result := LifeObjectState;
end;

procedure TLifeObject.CopyDie (aBasicObject : TBasicObject);
var
   i : Integer;
begin
   if CopiedList = nil then exit;
   for i := 0 to CopiedList.Count - 1 do begin
      if aBasicObject = CopiedList[i] then begin
         CopiedList.Delete (i);
         exit;
      end;
   end;
end;

procedure TLifeObject.CopyBossDie;
begin
   CopyBoss := nil;
   FboAllowDelete := true;
end;

procedure TLifeObject.SetHideState (aHideState : THiddenState);
begin
   BasicData.Feature.rHideState := aHideState;
   BocChangeFeature;
end;

procedure TLifeObject.InitialEx;
begin
   LifeData.damageBody    := 55;
   LifeData.damageHead    := 0;
   LifeData.damageArm     := 0;
   LifeData.damageLeg     := 0;
   LifeData.armorBody     := 0;
   LifeData.armorHead     := 0;
   LifeData.armorArm      := 0;
   LifeData.armorLeg      := 0;
   LifeData.AttackSpeed   := 150;
   LifeData.avoid         := 25;
   LifeData.recovery      := 70;

   DontAttacked := FALSE;

   LifeObjectState := los_none;
   BasicData.Feature.rfeaturestate := wfs_normal;
end;

procedure  TLifeObject.Initial (aMonsterName, aViewName : String);
begin
   inherited Initial (aMonsterName, aViewName);

   LifeData.damageBody    := 55;
   LifeData.damageHead    := 0;
   LifeData.damageArm     := 0;
   LifeData.damageLeg     := 0;
   LifeData.armorBody     := 0;
   LifeData.armorHead     := 0;
   LifeData.armorArm      := 0;
   LifeData.armorLeg      := 0;
   LifeData.AttackSpeed   := 150;
   LifeData.avoid         := 25;
   LifeData.recovery      := 70;

   DontAttacked := FALSE;

   LifeObjectState := los_init;
end;

procedure   TLifeObject.StartProcess;
var
   CurTick : integer;
begin
   inherited StartProcess;
   
   CurTick := mmAnsTick;

   FreezeTick := CurTick;
   DiedTick := CurTick;
   HitedTick := CurTick;
   WalkTick := CurTick;

   LifeObjectState := los_none;
end;

procedure TLifeObject.EndProcess;
var
   i : Integer;
begin
   LifeObjectState := los_exit;

   if CopyBoss <> nil then begin
      CopyBoss.CopyDie (Self);
      CopyBoss := nil;
   end;
   if CopiedList <> nil then begin
      for i := 0 to CopiedList.Count - 1 do begin
         TLifeObject (CopiedList[i]).CopyBossDie;
      end;
      CopiedList.Free;
      CopiedList := nil;
   end;
   
   inherited EndProcess;
end;

function  TLifeObject.AllowCommand (CurTick: integer): Boolean;
begin
   Result := TRUE;
   if FreezeTick > CurTick then Result := FALSE;
   if BasicData.Feature.rFeatureState = wfs_die then Result := FALSE;
end;

function   TLifeObject.CommandHited (aattacker: integer; aHitData: THitData; apercent: integer): integer;
var
   i, n, lifepercent, declife, exp : integer;
   SubData : TSubData;
   BO : TBasicObject;
   Monster, FirstMonster : TMonster;
   tmpAttackSkill : TAttackSkill;
begin
   Result := 0;

   if DontAttacked then exit;

   n := LifeData.avoid + aHitData.ToHit;

   n := Random (n);

   if n < LifeData.avoid then exit;    // 乔沁澜.

   if apercent = 100 then begin
      declife := aHitData.damageBody - LifeData.armorBody;
   end else begin
      declife := (aHitData.damageBody * apercent div 100) * aHitData.HitFunctionSkill div 10000 -LifeData.armorBody;
   end;

   // Monster 唱 NPC 狼 磊眉 规绢仿俊 狼茄 厚啦利 眉仿皑家
   if LifeData.HitArmor > 0 then begin
      declife := declife - ((declife * LifeData.HitArmor) div 100); 
   end;

   if declife <= 0 then declife := 1;

   CurLife := CurLife - declife;
   if CurLife <= 0 then CurLife := 0;

   FreezeTick := mmAnsTick + LifeData.recovery;

   if MaxLife <= 0 then begin
      FboAllowDelete := true;
      exit;
   end;

   if MaxLife <= 0 then BasicData.LifePercent := 0
   else BasicData.LifePercent := CurLife * 100 div MaxLife;

   SubData.Percent := BasicData.LifePercent;
   SubData.attacker := aAttacker;
   SubData.HitData.HitType := aHitData.HitType;
   
   SendLocalMessage (NOTARGETPHONE, FM_STRUCTED, BasicData, SubData);

   //  版摹 歹窍扁  //
   n := MaxLife div declife;
   if n > 15 then exp := DEFAULTEXP         // 10措捞惑 嘎阑父 窍促搁 1000
   else  exp := DEFAULTEXP * n * n div (15*15);      // 20措 嘎栏搁 磷备档 巢栏搁 10 => 500   n 15 => 750   5=>250
//   else  exp := DEFAULTEXP * n div 15;      // 10措 嘎栏搁 磷备档 巢栏搁 10 => 500   n 15 => 750   5=>250

   SubData.ExpData.Exp := exp;
   SubData.ExpData.ExpType := 0;
   if apercent = 100 then
      SendLocalMessage (aAttacker, FM_ADDATTACKEXP, BasicData, SubData);

   //////////////////////
   BoSysopMessage (IntToStr(declife) + ' : ' + IntTostr(exp), 10);

   if SoundStructed.rWavNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (SoundStructed.rWavNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;

   Result := n;
end;

procedure TLifeObject.CommandHit (CurTick: integer);
var
   SubData : TSubData;
begin
   if not AllowCommand (mmAnsTick) then exit;

   if HitedTick + LifeData.AttackSpeed < CurTick then begin
      HitedTick := CurTick;
      SubData.HitData.damageBody := LifeData.damageBody;
      SubData.HitData.damageHead := LifeData.damageHead;
      SubData.HitData.damageArm := LifeData.damageArm;
      SubData.HitData.damageLeg := LifeData.damageLeg;

//      SubData.HitData.ToHit := 100 - LifeData.avoid;
      SubData.HitData.ToHit := 75;
      SubData.HitData.HitType := 0;
      SubData.HitData.HitLevel := 7500;

      SubData.HitData.boHited := FALSE;
      SubData.HitData.HitFunction := 0;

      SendLocalMessage (NOTARGETPHONE, FM_HIT, BasicData, SubData);

      if SoundAttack.rWavNumber <> 0 then begin
         SetWordString (SubData.SayString, IntToStr (SoundAttack.rWavNumber) + '.wav');
         SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      end;

      SubData.motion := BasicData.Feature.rhitmotion;
      SendLocalMessage ( NOTARGETPHONE, FM_MOTION, BasicData, SubData);
   end;
end;

procedure TLifeObject.CommandSay (astr: string);
var
   SubData : TSubData;
begin
   SetWordString (SubData.SayString, StrPas (@BasicData.Name) + ': '+ astr);
   SendLocalMessage (NOTARGETPHONE, FM_SAY, BasicData, SubData);
end;

procedure TLifeObject.CommandTurn (adir: word);
var
   SubData : TSubData;
begin
   if not AllowCommand (mmAnsTick) then exit;
   BasicData.dir := adir;
   SendLocalMessage (NOTARGETPHONE, FM_TURN, BasicData, SubData);
end;

procedure TLifeObject.CommandChangeCharState (aFeatureState: TFeatureState);
var
   i : Integer;
   SubData : TSubData;
   BO : TLifeObject;
begin
   if aFeatureState = wfs_die then begin
      LifeObjectState := los_die;
      
      if BasicData.Feature.rHideState <> hs_100 then begin
         BasicData.Feature.rHideState := hs_100;
         SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
      end;
      if FboCopy = true then begin
         ShowEffect (1, lek_none);
      end;
      if CopiedList <> nil then begin
         for i := 0 to CopiedList.Count - 1 do begin
            BO := CopiedList[i];
            if BO <> nil then begin
               BO.CommandChangeCharState (aFeatureState);
            end;
         end;
      end;
      DiedTick := mmAnsTick;
      if SoundDie.rWavNumber <> 0 then begin
         SetWordString (SubData.SayString, IntToStr (SoundDie.rWavNumber) + '.wav');
         SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      end;
   end;
   BasicData.Feature.rfeaturestate := aFeatureState;
   SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
end;

procedure TLifeObject.ShowEffect (aEffectNumber : Word; aEffectKind : TLightEffectKind);
var
   SubData : TSubData;
begin
   BasicData.Feature.rEffectNumber := aEffectNumber;
   BasicData.Feature.rEffectKind := aEffectKind;

   SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

   BasicData.Feature.rEffectNumber := 0;
   BasicData.Feature.rEffectKind := lek_none;
end;

function TLifeObject.ShootMagic (var aMagic: TMagicData; Bo : TBasicObject) : Boolean;
var
   SubData : TSubData;
   CurTick : Integer;
begin
   Result := false;
   
   CurTick := mmAnsTick;
   
   if not AllowCommand (CurTick) then exit;

   if HitedTick + LifeData.AttackSpeed >= CurTick then exit;

   HitedTick := mmAnsTick;
   
   if GetViewDirection (BasicData.x, BasicData.y, bo.PosX, bo.posy) <> basicData.dir then
      CommandTurn ( GetViewDirection (BasicData.x, BasicData.y, bo.posx, bo.posy));
      
   SubData.motion := BasicData.Feature.rhitmotion;
   SendLocalMessage ( NOTARGETPHONE, FM_MOTION, BasicData, SubData);

   SubData.HitData.damageBody := aMagic.rLifeData.damageBody;
   SubData.HitData.damageHead := aMagic.rLifeData.damageHead;
   SubData.HitData.damageArm := aMagic.rLifeData.damageArm;
   SubData.HitData.damageLeg := aMagic.rLifeData.damageLeg;

   SubData.HitData.ToHit := 75;
   SubData.HitData.HitType := 1;
   SubData.HitData.HitLevel := 0;
   SubData.HitData.HitLevel := aMagic.rcSkillLevel;

   SubData.TargetId := Bo.BasicData.id;
   SubData.tx := Bo.PosX;
   SubData.ty := Bo.PosY;
   SubData.BowImage := aMagic.rBowImage;
   SubData.BowSpeed := aMagic.rBowSpeed;
   SubData.BowType := aMagic.rBowType;
   SendLocalMessage (NOTARGETPHONE, FM_BOW, BasicData, SubData);

   if aMagic.rSoundStrike.rWavNumber <> 0 then begin
      SetWordString (SubData.SayString, IntTostr (aMagic.rSoundStrike.rWavNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;

   Result := true;
end;

function TLifeObject.GotoXyStandAI (ax, ay : word) : Integer;
var
   x, y : Integer;
   key : word;
   SubData : TSubData;
begin
   Result := 2;
   x := 0;
   y := 0;
   if (ax = BasicData.x) and (ay = BasicData.y) then begin
      Result := 0;
      exit;
   end;
   
   SearchPathClass.SetMaper (Maper);
   SearchPathClass.GotoPath (BasicData.x, BasicData.y, ax, ay, x, y);
   if (x <> 0) and (y <> 0) then begin
      key := GetNextDirection (BasicData.x, BasicData.y, x, y);
      if BasicData.dir <> key then begin
         CommandTurn(key);
         Result := 1;
         exit;
      end;
      if Maper.isMoveable (x, y) then begin
         BasicData.nx := x;
         BasicData.ny := y;
         Phone.SendMessage ( NOTARGETPHONE, FM_MOVE, BasicData, SubData);
         Maper.MapProc (BasicData.Id, MM_MOVE, BasicData.x, BasicData.y, x, y, BasicData);
         BasicData.x := x; BasicData.y := y;
      end;
   end;
end;

function TLifeObject.GotoXyStand (ax, ay: word): integer;
   function _Gap ( a1, a2: word): integer;
   begin
      if a1 > a2 then Result := a1-a2
      else Result := a2-a1;
   end;

var
   i : integer;
   SubData: TSubData;
   key, len : word;
   boarr : array [0..8-1] of Boolean;
   lenarr : array [0..8-1] of word;
   mx, my: word;
begin
   Result := 2;

   len := _Gap (BasicData.x,ax) + _Gap(BasicData.y,ay);
   if (len = 0) then begin Result := 0; exit; end;      //档馒

   key := GetNextDirection ( BasicData.x, BasicData.y, ax, ay);
   // 档馒
   mx := BasicData.x;
   my := BasicData.y;
   GetNextPosition (key, mx, my);
   if (mx = ax) and (my = ay) and  not Maper.IsMoveable (ax, ay) then begin
      if BasicData.dir <> key then CommandTurn (key);
      Result := 1;
      exit;
   end;

   for i := 0 to 8-1 do lenarr[i] := 65535;

   boarr[0]  := Maper.isMoveable (   BasicData.x, BasicData.y-1);
   if (OldPos.x = BasicData.x) and (OldPos.y = BasicData.y-1) then boarr[0] := FALSE;
   if boarr[0] then lenarr[0] := (BasicData.x-ax)*(BasicData.x-ax) + (BasicData.y-1-ay)*(BasicData.y-1-ay);

   boarr[1]  := Maper.isMoveable ( BasicData.x+1, BasicData.y-1);
   if (OldPos.x = BasicData.x+1) and (OldPos.y = BasicData.y-1) then boarr[1] := FALSE;
   if boarr[1] then lenarr[1] := (BasicData.x+1-ax)*(BasicData.x+1-ax) + (BasicData.y-1-ay)*(BasicData.y-1-ay);

   boarr[2]  := Maper.isMoveable ( BasicData.x+1, BasicData.y);
   if (OldPos.x = BasicData.x+1) and (OldPos.y = BasicData.y) then boarr[2] := FALSE;
   if boarr[2] then lenarr[2] := (BasicData.x+1-ax)*(BasicData.x+1-ax) + (BasicData.y-ay)*(BasicData.y-ay);

   boarr[3]  := Maper.isMoveable ( BasicData.x+1, BasicData.y+1);
   if (OldPos.x = BasicData.x+1) and (OldPos.y = BasicData.y+1) then boarr[3] := FALSE;
   if boarr[3] then lenarr[3] := (BasicData.x+1-ax)*(BasicData.x+1-ax) + (BasicData.y+1-ay)*(BasicData.y+1-ay);

   boarr[4]  := Maper.isMoveable (   BasicData.x, BasicData.y+1);
   if (OldPos.x = BasicData.x) and (OldPos.y = BasicData.y+1) then boarr[4] := FALSE;
   if boarr[4] then lenarr[4] := (BasicData.x-ax)*(BasicData.x-ax) + (BasicData.y+1-ay)*(BasicData.y+1-ay);

   boarr[5]  := Maper.isMoveable ( BasicData.x-1, BasicData.y+1);
   if (OldPos.x = BasicData.x-1) and (OldPos.y = BasicData.y+1) then boarr[5] := FALSE;
   if boarr[5] then lenarr[5] := (BasicData.x-1-ax)*(BasicData.x-1-ax) + (BasicData.y+1-ay)*(BasicData.y+1-ay);

   boarr[6]  := Maper.isMoveable ( BasicData.x-1, BasicData.y);
   if (OldPos.x = BasicData.x-1) and (OldPos.y = BasicData.y) then boarr[6] := FALSE;
   if boarr[6] then lenarr[6] := (BasicData.x-1-ax)*(BasicData.x-1-ax) + (BasicData.y-ay)*(BasicData.y-ay);

   boarr[7]  := Maper.isMoveable ( BasicData.x-1, BasicData.y-1);
   if (OldPos.x = BasicData.x-1) and (OldPos.y = BasicData.y-1) then boarr[7] := FALSE;
   if boarr[7] then lenarr[7] := (BasicData.x-1-ax)*(BasicData.x-1-ax) + (BasicData.y-1-ay)*(BasicData.y-1-ay);


   len := 65535;
   for i := 0 to 8-1 do begin
      if len > lenarr[i] then begin
         key := i;
         len := lenarr[i];
      end;
   end;

   mx := BasicData.x; my := BasicData.y;
   GetNextPosition (key, mx, my);
   if key <> BasicData.dir then CommandTurn (key)
   else begin
      if Maper.isMoveable ( mx, my) then begin
         OldPos.x := BasicData.x;
         Oldpos.y := BasicData.y;
         BasicData.dir := key;
         BasicData.nx := mx;
         BasicData.ny := my;
         Phone.SendMessage ( NOTARGETPHONE, FM_MOVE, BasicData, SubData);
         Maper.MapProc (BasicData.Id, MM_MOVE, BasicData.x, BasicData.y, mx, my, BasicData);
         BasicData.x := mx; BasicData.y := my;
      end else begin
         OldPos.x := 0; OldPos.y := 0;
      end;
   end;
end;

function  TLifeObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   n, percent: integer;
//   xx, yy: word;
begin
//   Result := PROC_FALSE;
//   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;
   case Msg of
      FM_BOW :
         begin
            if BasicData.Feature.rfeaturestate = wfs_die then exit;
            if aSubData.TargetId = Basicdata.id then begin
               n := CommandHited (SenderInfo.id, aSubData.HitData, 100);
               if CurLife <= 0 then CommandChangeCharState (wfs_die);
               if n <> 0 then aSubData.HitData.boHited := TRUE;
            end;
         end;
      FM_HIT :
         begin
            if BasicData.Feature.rfeaturestate = wfs_die then exit;
            if isHitedArea (SenderInfo.dir, SenderInfo.x, SenderInfo.y, aSubData.HitData.HitFunction, percent) then begin
               n := CommandHited (SenderInfo.id, aSubData.HitData, percent);
               if (CurLife <= 0) then CommandChangeCharState (wfs_die);
               if n <> 0 then begin
                  aSubData.HitData.boHited := TRUE;
                  aSubData.HitData.HitedCount := aSubData.HitData.HitedCount +1;
               end;
            end;
{
            xx := SenderInfo.x; yy := SenderInfo.y;
            GetNextPosition (SenderInfo.dir, xx, yy);
            if (BasicData.x = xx) and (BasicData.y = yy) then begin
               n := CommandHited (SenderInfo.id, aSubData.HitData);
               if (CurLife <= 0) then CommandChangeCharState (wfs_die);
               if n <> 0 then aSubData.HitData.boHited := TRUE;
            end;
}
         end;
   end;
end;
{
procedure   TLifeObject.Update (CurTick: integer);
begin
   inherited Update (CurTick);
end;
}
   
constructor TBuySellSkill.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;

   BuyItemList := TList.Create;
   SellItemList := TList.Create;

   boLogItem := false;

   LoadFromFile ('test.txt');
end;

destructor TBuySellSkill.Destroy;
begin
   Clear;
   if BuyItemList <> nil then BuyItemList.Free;
   if SellItemList <> nil then SellItemList.Free;
   
   inherited Destroy;
end;

procedure TBuySellSkill.Clear;
var
   i : Integer;
   pItemData : PTItemData;
begin
   if BuyItemList <> nil then begin
      for i := 0 to BuyItemList.Count - 1 do begin
         pItemData := BuyItemList.Items [i];
         if pItemData <> nil then Dispose (pItemData);
      end;
      BuyItemList.Clear;
   end;
   if SellItemList <> nil then begin
      for i := 0 to SellItemList.Count - 1 do begin
         pItemData := SellItemList.Items [i];
         if pItemData <> nil then Dispose (pItemData);
      end;
      SellItemList.Clear;
   end;
end;

function TBuySellSkill.LoadFromFile (aFileName : String) : Boolean;
var
   i : Integer;
   mStr, KindStr, ItemName : String;
   StringList : TStringList;
   ItemData : TItemData;
   pItemData : PTItemData;
begin
   Result := false;

   if FileExists (aFileName) then begin
      FileName := aFileName;
      Clear;

      StringList := TStringList.Create;
      StringList.LoadFromFile (aFileName);
      for i := 0 to StringList.Count - 1 do begin
         mStr := StringList.Strings[i];
         if mStr <> '' then begin
            mStr := GetValidStr3 (mStr, KindStr, ':');
            mStr := GetValidStr3 (mStr, ItemName, ':');

            if (KindStr <> '') and (ItemName <> '') then begin
               ItemClass.GetItemData (ItemName, ItemData);
               if ItemData.rName[0] <> 0 then begin
                  New (pItemData);
                  Move (ItemData, pItemData^, sizeof (TItemData));
                  if UpperCase (KindStr) = 'SELLITEM' then
                     SellItemList.Add (pItemData)
                  else if UpperCase (KindStr) = 'BUYITEM' then
                     BuyItemList.Add (pItemData);
               end;
            end else if UpperCase (KindStr) = 'LOGITEM' then begin
               boLogItem := true;
            end;
         end;
      end;
      StringList.Free;
      Result := true;
   end;
end;

function TBuySellSkill.DivHearing (aHearStr: string; var Sayer, aItemName: string; var aItemCount: integer): integer;
var
   str: string;
   str1, str2, str3: string;
begin
   Result := DIVRESULT_NONE;

   if not ReverseFormat (aHearStr, '%s: %s', str1, str2, str3, 2) then exit;
   sayer := str1;

   str := str2;
   
   if Pos ('卖什么', str) = 1 then Result := DIVRESULT_WHATSELL;
   if Pos ('买什么', str) = 1 then Result := DIVRESULT_WHATBUY;
   if Pos ('买入', str) = 1 then Result := DIVRESULT_WHATSELL;
   if Pos ('卖出', str) = 1 then Result := DIVRESULT_WHATBUY;
   if Result <> DIVRESULT_NONE then exit;

   if ReverseFormat (str, '%s 多少钱', str1, str2, str3, 1) then begin
      aItemName := str1;
      Result := DIVRESULT_HOWMUCH;
      exit;
   end;

   if ReverseFormat (str, '买入 %s %s个', str1, str2, str3, 2) then begin
      aItemName := str1;
      aItemCount := _StrToInt (str2);
      Result := DIVRESULT_BUYITEM;
      exit;
   end;
   if ReverseFormat (str, '买 %s %s个', str1, str2, str3, 2) then begin
      aItemName := str1;
      aItemCount := _StrToInt (str2);
      Result := DIVRESULT_BUYITEM;
      exit;
   end;


   if ReverseFormat (str, '卖出 %s %s个', str1, str2, str3, 2) then begin
      aItemName := str1;
      aItemCount := _StrToInt(str2);
      if aItemCount < 0 then aItemCount := 0;
      Result := DIVRESULT_SELLITEM;
      exit;
   end;
   if ReverseFormat (str, '卖 %s %s个', str1, str2, str3, 2) then begin
      aItemName := str1;
      aItemCount := _StrToInt(str2);
      if aItemCount < 0 then aItemCount := 0;
      Result := DIVRESULT_SELLITEM;
      exit;
   end;

   if ReverseFormat (str, '买入%s', str1, str2, str3, 1) then begin
      aItemName := str1;
      aItemCount := 1;
      Result := DIVRESULT_BUYITEM;
      exit;
   end;
   if ReverseFormat (str, '买入%s', str1, str2, str3, 1) then begin
      aItemName := str1;
      aItemCount := 1;
      Result := DIVRESULT_BUYITEM;
      exit;
   end;

   if ReverseFormat (str, '卖出%s', str1, str2, str3, 1) then begin
      aItemName := str1;
      aItemCount := 1;
      Result := DIVRESULT_SELLITEM;
      exit;
   end;
   if ReverseFormat (str, '卖出%s', str1, str2, str3, 1) then begin
      aItemName := str1;
      aItemCount := 1;
      Result := DIVRESULT_SELLITEM;
      exit;
   end;
end;

function TBuySellSkill.ProcessMessage (aStr : String; SenderInfo : TBasicData) : Boolean;
var
   i, icnt, ipos, ret : Integer;
   str, sayer, iname, RetStr : String;
   pItemData : PTItemData;
   ItemData, MoneyItemData : TItemData;
   SubData : TSubData;
   User : TUser; 
begin
   Result := true;

   ret := DivHearing (aStr, sayer, iname, icnt);
   case ret of
      {
      DIVRESULT_ITEMLOG :
         begin
            User := UserList.GetUserPointer (StrPas (@SenderInfo.Name));
            if User <> nil then begin
               RetStr := User.ShowItemLogWindow;
               if RetStr <> '' then begin
                  TLIfeObject (BasicObject).CommandSay (RetStr);
               end;
            end;
         end;
      }
      DIVRESULT_HOWMUCH:
         begin
            ipos := -1;
            for i := 0 to SellItemList.Count - 1 do begin
               pitemdata := SellItemList[i];
               if iname = Strpas (@pitemdata^.rname) then begin
                  ipos := i;
                  break;
               end;
            end;
            if ipos = -1 then begin
               TLifeObject (BasicObject).CommandSay (format ('没有%s.',[iname]));
            end else begin
               ItemClass.GetItemData (iname, ItemData);
               TLifeObject (BasicObject).CommandSay (format ('%s的价格是%d钱币.',[iname,ItemData.rPrice]));
            end;
         end;
      DIVRESULT_SELLITEM:
         begin
            if icnt <= 0 then exit;
            if icnt > 1000 then begin
               TLifeObject(BasicObject).CommandSay ('数量太多.');
               exit;
            end;

            ipos := -1;
            for i := 0 to BuyItemList.count-1 do begin
               pitemdata := Buyitemlist[i];
               if iname = Strpas (@pitemdata^.rname) then begin ipos := i; break; end;
            end;
            if ipos = -1 then begin
               TLIfeObject (BasicObject).CommandSay (format ('不买%s.',[iname]));
               exit;
            end;
            if TFieldPhone (BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ENOUGHSPACE, BasicObject.BasicData, SubData) = PROC_FALSE then begin
               TLIfeObject (BasicObject).CommandSay ('携带的物品太多了.');
               exit;
            end;

            ItemClass.GetItemData (INI_GOLD, MoneyItemData);
            ItemClass.GetItemData (iname, ItemData);

            SignToItem (ItemData, BasicObject.Manager.ServerID, BasicObject.BasicData, '');
            SubData.ItemData := ItemData;
            SubData.ItemData.rCount := icnt;
            if TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_DELITEM, BasicObject.BasicData, SubData) = PROC_FALSE then begin
               TLIfeObject (BasicObject).CommandSay (format ('没有携带%s.',[iname]));
               exit;
            end;
            MoneyItemData.rCount := ItemData.rprice * icnt;
            SignToItem (MoneyItemData, BasicObject.Manager.ServerID, BasicObject.BasicData, '');
            SubData.ItemData := MoneyItemData;
            SubData.ServerId := BasicObject.Manager.ServerId;
            TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ADDITEM, BasicObject.BasicData, SubData);
            TLIfeObject (BasicObject).CommandSay (format ('买入了%s.',[iname]));
         end;
      DIVRESULT_BUYITEM:
         begin
            if icnt <= 0 then exit;
            if icnt > 1000 then begin
               TLIfeObject (BasicObject).CommandSay ('数量太多.');
               exit;
            end;
            ipos := -1;
            for i := 0 to SellItemList.count-1 do begin
               pitemdata := sellitemlist[i];
               if iname = Strpas (@pitemdata^.rname) then begin ipos := i; break; end;
            end;
            if ipos = -1 then begin
               TLIfeObject (BasicObject).CommandSay (format ('没有%s.',[iname]));
               exit;
            end;

            ItemClass.GetItemData (INI_GOLD, MoneyItemData);
            ItemClass.GetItemData (iname, ItemData);

            if (ItemData.rboDouble = false) and (icnt > 1) then begin
               TLIfeObject (BasicObject).CommandSay (format ('%s只卖一个.', [StrPas(@ItemData.rName)]));
               exit;
            end;
            if TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ENOUGHSPACE, BasicObject.BasicData, SubData) = PROC_FALSE then begin
               TLIfeObject (BasicObject).CommandSay ('携带的物品太多了.');
               exit;
            end;

            SignToItem (MoneyItemData, BasicObject.Manager.ServerID, BasicObject.BasicData, '');
            MoneyItemData.rCount := ItemData.rPrice * icnt;
            SubData.ItemData := MoneyItemData;
            if TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_DELITEM, BasicObject.BasicData, SubData) = PROC_FALSE then begin
               TLIfeObject (BasicObject).CommandSay ('携带的钱币太少了.');
               exit;
            end;

            ItemData.rCount := icnt;
            SignToItem (ItemData, BasicObject.Manager.ServerID, BasicObject.BasicData, '');
            SubData.ItemData := ItemData;
            SubData.ServerId := BasicObject.Manager.ServerId;
            TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ADDITEM, BasicObject.BasicData, SubData);
            TLIfeObject (BasicObject).CommandSay (format ('卖掉了%s.',[iname]));
         end;
      DIVRESULT_WHATSELL:
         begin
            str := '';
            for i := 0 to SellItemList.count-1 do begin
               pitemdata := sellitemlist[i];
               if i < SellItemList.count-1 then str := str + Strpas (@pitemdata^.rname) + ','
               else                             str := str + Strpas (@pitemdata^.rname);
            end;
            if SellItemList.Count <> 0 then
               TLIfeObject (BasicObject).CommandSay (format ('卖出%s.',[str]))
            else
               TLIfeObject (BasicObject).CommandSay ('我不卖物品.');
         end;
      DIVRESULT_WHATBUY:
         begin
            str := '';
            for i := 0 to BuyItemList.count-1 do begin
               pitemdata := Buyitemlist[i];
               if i < BuyItemList.count-1 then str := str + Strpas (@pitemdata^.rname) + ','
               else                             str := str + Strpas (@pitemdata^.rname);
            end;
            if BuyItemList.Count <> 0 then
               TLIfeObject (BasicObject).CommandSay (format ('买入%s.',[str]))
            else
               TLIfeObject (BasicObject).CommandSay ('我不买物品.');
         end;
      else begin
         Result := false;
      end;
   end;
end;

// TSpeechSkill
constructor TSpeechSkill.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;

   SpeechList := TList.Create;
   CurSpeechIndex := 0;
   SpeechTick := 0;
end;

destructor TSpeechSkill.Destroy;
begin
   if SpeechList <> nil then begin
      Clear();
      SpeechList.Free;
   end;
end;

procedure TSpeechSkill.Clear;
var
   i : Integer;
begin
   for i := 0 to SpeechList.Count - 1 do dispose (SpeechList[i]);
   SpeechList.Clear;
   CurSpeechIndex := 0;
   SpeechTick := 0;
end;

function TSpeechSkill.LoadFromFile (aFileName : String) : Boolean;
var
   i : integer;
   SpeechDB : TUserStringDB;
   iname : String;
   pd : PTSpeechData;
begin
   Result := false;
   
   if aFileName = '' then exit;
   if FileExists(aFileName) = FALSE then exit;

   Clear;

   SpeechDB := TUserStringDb.Create;
   SpeechDB.LoadFromFile (aFileName);

   for i := 0 to SpeechDB.Count -1 do begin
      iname := SpeechDB.GetIndexName (i);
      if SpeechDB.GetFieldValueBoolean(iname, 'boSelfSay') = TRUE then begin
         New (pd);
         FillChar (pd^, sizeof(TSpeechData), 0);
         pd^.rSayString := SpeechDB.GetFieldValueString (iname, 'SayString');
         pd^.rDelayTime := SpeechDB.GetFieldValueInteger (iname, 'DelayTime');
         pd^.rSpeechTick := pd^.rDelayTime;
         SpeechList.Add(pd);
      end;
   end;
   SpeechDB.Free;
end;

procedure TSpeechSkill.ProcessMessage (CurTick : Integer);
var
   pd : PTSpeechData;
begin
   if SpeechList.Count > 0 then begin
      pd := SpeechList[CurSpeechIndex];
      if SpeechTick + pd^.rDelayTime < CurTick then begin
         TLIfeObject(BasicObject).CommandSay(pd^.rSayString);
         SpeechTick := CurTick;
         if CurSpeechIndex < SpeechList.Count - 1 then Inc(CurSpeechIndex)
         else CurSpeechIndex := 0;
      end;
   end;
end;

constructor TDeallerSkill.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;
   DataList := TList.Create;
end;

destructor TDeallerSkill.Destroy;
begin
   if DataList <> nil then begin
      Clear;
      DataList.Free;
   end;
   inherited Destroy;
end;

procedure TDeallerSkill.Clear;
var
   i : Integer;
begin
   for i := 0 to DataList.Count - 1 do dispose (DataList[i]);
   DataList.Clear;
end;

function TDeallerSkill.LoadFromFile (aFileName : String) : Boolean;
var
   i, j, iCount : integer;
   DeallerDB : TUserStringDB;
   iname : String;
   pd : PTDeallerData;
   str, mName, mCount : String;
begin
   Result := false;

   if aFileName = '' then exit;
   if FileExists(aFileName) = FALSE then exit;

   Clear;

   DeallerDB := TUserStringDb.Create;
   DeallerDB.LoadFromFile (aFileName);

   for i := 0 to DeallerDB.Count -1 do begin
      iname := DeallerDB.GetIndexName (i);
      if DeallerDB.GetFieldValueBoolean(iname, 'boSelfSay') <> TRUE then begin
         new (pd);
         FillChar (pd^, sizeof(TDeallerData), 0);
         pd^.rHearString := DeallerDB.GetFieldValueString (iname, 'HearString');
         pd^.rSayString := DeallerDB.GetFieldValueString (iname, 'SayString');
         str := DeallerDB.GetFieldValueString (iname, 'NeedItem');
         for j := 0 to 5 - 1 do begin
            if str = '' then break;
            str := GetValidStr3 (str, mName, ':');
            if mName = '' then break;
            str := GetValidStr3 (str, mCount, ':');
            if mCount = '' then break;
            iCount := _StrToInt (mCount);
            if iCount <= 0 then iCount := 1;
            pd^.rNeedItem[j].rName := mName;
            pd^.rNeedItem[j].rCount := iCount;
         end;
         str := DeallerDB.GetFieldValueString (iname, 'GiveItem');
         for j := 0 to 5 - 1 do begin
            if str = '' then break;
            str := GetValidStr3 (str, mName, ':');
            if mName = '' then break;
            str := GetValidStr3 (str, mCount, ':');
            if mCount = '' then break;
            iCount := _StrToInt (mCount);
            if iCount <= 0 then iCount := 1;
            pd^.rGiveItem[j].rName := mName;
            pd^.rGiveItem[j].rCount := iCount;
         end;
         DataList.Add(pd);
      end;
   end;
   DeallerDB.Free;
   Result := true;
end;

function TDeallerSkill.ProcessMessage (aStr : String; SenderInfo : TBasicData) : Boolean;
var
   i, j, k : Integer;
   sayer, dummy1, dummy2 : String;
   pd : PTDeallerData;
   BO : TBasicObject;
   SubData : TSubData;
   ItemData : TItemData;
begin
   Result := false;

   if DataList.Count <= 0 then exit;

   for i := 0 to DataList.Count - 1 do begin
      pd := DataList[i];
      if ReverseFormat (astr, '%s: ' + pd^.rHearString, sayer, dummy1, dummy2, 1) then begin
         BO := TLifeObject (BasicObject).GetViewObjectByID (SenderInfo.id);
         if BO = nil then exit;
         if SenderInfo.Feature.rRace <> RACE_HUMAN then exit;
         for j := 0 to 5 - 1 do begin
            if pd^.rNeedItem[j].rName = '' then break;
            ItemClass.GetItemData (pd^.rNeedItem[j].rName, ItemData);
            if ItemData.rName[0] <> 0 then begin
               ItemData.rCount := pd^.rNeedItem[j].rCount;
               if TUser (BO).FindItem (@ItemData) = false then begin
                  TUser (BO).SendClass.SendChatMessage (format ('%s 物品需要 %d个.', [StrPas (@ItemData.rName), ItemData.rCount]), SAY_COLOR_SYSTEM);
                  exit;
               end;
            end;
         end;

         BasicObject.BasicData.nx := SenderInfo.x;
         BasicObject.BasicData.ny := SenderInfo.y;
         for j := 0 to 5 - 1 do begin
            if pd^.rGiveItem[j].rName = '' then break;
            ItemClass.GetItemData (pd^.rGiveItem[j].rName, ItemData);
            ItemData.rCount := pd^.rGiveItem[j].rCount;
            ItemData.rOwnerName[0] := 0;

            SubData.ItemData := ItemData;
            SubData.ServerId := BasicObject.ServerId;
            if TFieldPhone (BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ENOUGHSPACE, BasicObject.BasicData, SubData) = PROC_FALSE then begin
               for k := 0 to j - 1 do begin
                  if pd^.rGiveItem[j].rName = '' then break;
                  ItemClass.GetItemData (pd^.rGiveItem[j].rName, ItemData);
                  ItemData.rCount := pd^.rGiveItem[j].rCount;
                  ItemData.rOwnerName[0] := 0;
                  TUser (BO).DeleteItem (@ItemData);
               end;
               TLIfeObject (BasicObject).CommandSay('物品窗的空间不足.');
               exit;
               // TFieldPhone (BasicObject.Phone).SendMessage (MANAGERPHONE, FM_ADDITEM, BasicObject.BasicData, SubData);
            end else begin
               TFieldPhone(BasicObject.Manager.Phone).SendMessage (SenderInfo.id, FM_ADDITEM, BasicObject.BasicData, SubData);
            end;
         end;

         for j := 0 to 5 - 1 do begin
            if pd^.rNeedItem[j].rName = '' then break;
            ItemClass.GetItemData (pd^.rNeedItem[j].rName, ItemData);
            if ItemData.rName[0] <> 0 then begin
               ItemData.rCount := pd^.rNeedItem[j].rCount;
               TUser (BO).DeleteItem (@ItemData);
            end;
         end;
         TLIfeObject (BasicObject).CommandSay(pd^.rSayString);

         Result := true;
         exit;
      end;
   end;
end;


constructor TAttackSkill.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;

   if Pointer (BasicObject) = Pointer ($150) then begin
      BasicObject := nil;
   end;

   Boss := nil;
   ObjectBoss := nil;

   DeadAttackName := '';
   TargetID := 0;
   EscapeID := 0;
   EscapeLife := 0;

   boGroup := false;
   boBoss := false;

   TargetPosTick := 0;
   CurNearViewHumanId := 0;
   HateHumanId := 0;

   boGroupSkill := false;
   GroupSkill := nil;

   boSelfTarget := true;

   BowCount := 5;
   boBowAvail := true;
   BowAvailTick := 0;
   BowAvailInterval := 500;
end;

destructor TAttackSkill.Destroy;
begin
   NoticeDie;
   if ObjectBoss <> nil then begin
      ObjectBoss.MemberDie (BasicObject);
   end;
   if GroupSkill <> nil then begin
      GroupSkill.BossDie;
      GroupSkill.Free;
      GroupSkill := nil;
      boGroupSkill := false;
   end;
   inherited Destroy;
end;

procedure TAttackSkill.HelpMe (aMeID, aTargetID, aX, aY : Integer);
begin
   if aTargetID <> 0 then begin
      if TargetID <> aTargetID then begin
         SetHelpTargetIDandPos (aTargetID, aX, aY);
      end;
      if GroupSkill <> nil then begin
         GroupSkill.MoveAttack (aTargetID, aX, aY);
      end else begin
         GroupSkill := nil;
      end;
   end;
end;

procedure TAttackSkill.CancelHelp (aTargetID : Integer);
begin
   if aTargetID <> 0 then begin
      if GroupSkill <> nil then begin
         GroupSkill.CancelTarget (aTargetID);
      end else begin
         GroupSkill := nil;
      end;
   end;
end;

procedure TAttackSkill.SetSelf (aSelf : TBasicObject);
begin
   BasicObject := aSelf;
end;

procedure TAttackSkill.SetBoss (aBoss : TBasicObject);
begin
   Boss := aBoss;
end;

procedure TAttackSkill.SetObjectBoss (aBoss : TDynamicObject);
begin
   ObjectBoss := aBoss;
end;

function TAttackSkill.GetObjectBoss : TDynamicObject;
begin
   Result := ObjectBoss;
end;

procedure TAttackSkill.SetDeadAttackName (aName : String);
begin
   if TLifeObject (BAsicObject).LifeObjectState = los_die then exit;
   
   DeadAttackName := aName;
   if aName <> '' then begin
      TLifeObject (BasicObject).LifeObjectState := los_deadattack;
   end;
end;

procedure TAttackSkill.SetSaveIDandPos (aTargetID : Integer; aTargetX, aTargetY : Word; aNextState : TLifeObjectState);
begin
   TargetStartTick := mmAnsTick;
   
   SaveID := aTargetID;
   TargetX := aTargetX;
   TargetY := aTargetY;

   SaveNextState := aNextState;
end;

procedure TAttackSkill.SetTargetID (aTargetID : Integer; boCaller : Boolean);
var
   SubData : TSubData;
   tmpAttackSkill : TAttackSkill;
   tmpTargetID : Integer;
   BO : TBasicObject;
begin
   if (TLifeObject (BasicObject).LifeObjectState = los_die)
      or (TLifeObject (BasicObject).LifeObjectState = los_init) then exit;

   if TLifeObject (BasicObject).LifeObjectState = los_deadattack then exit;

   if aTargetID = BasicObject.BasicData.id then exit;
   if (aTargetID = 0) and (TargetID <> 0) then begin
      tmpTargetID := TargetID;
      TargetId := aTargetID;
      if (Boss <> nil) and (boSelfTarget = true) then begin
         if Boss.BasicData.Feature.rrace = RACE_NPC then
            // tmpAttackSkill := TNpc(Boss).GetAttackSkill;
            tmpAttackSkill := nil
         else
            tmpAttackSkill := TMonster(Boss).GetAttackSkill;
         if tmpAttackSkill <> nil then begin
            tmpAttackSkill.CancelHelp (tmpTargetID);
         end;
      end;
   end;

   if aTargetID = 0 then begin
      TargetId := aTargetID;
      TLifeObject (BasicObject).LifeObjectState := los_none;
      exit;
   end;

   boSelfTarget := true;
      
   TargetId := aTargetID;
   TLifeObject (BasicObject).LifeObjectState := los_attack;
   if GroupSkill <> nil then begin
      BO := TLifeObject (BasicObject).GetViewObjectByID (TargetID);
      if BO <> nil then begin
         GroupSkill.MoveAttack (TargetID, BO.BasicData.X, BO.BasicData.Y);
      end;
   end else if Boss <> nil then begin
      if Boss.BasicData.Feature.rRace = RACE_NPC then
         tmpAttackSkill := TNpc(Boss).GetAttackSkill
      else
         tmpAttackSkill := TMonster(Boss).GetAttackSkill;

      if tmpAttackSkill <> nil then begin
         if tmpAttackSkill.GetTargetID <> TargetID then begin
            BO := TLifeObject (BasicObject).GetViewObjectByID (TargetID);
            if BO <> nil then begin
               if BO.BasicData.Feature.rFeatureState = wfs_die then begin
                  BO := nil;
                  exit;
               end;
               if tmpAttackSkill.GroupSkill <> nil then begin
                  tmpAttackSkill.HelpMe (BasicObject.BasicData.id, TargetID, BO.BasicData.x, BO.BasicData.y);
               end else begin
                  BO := nil;
               end;
            end;
         end;
      end;
   end else begin
      if (boCaller = true) and (boVassal = true) then begin
         SubData.TargetId := TargetID;
         SubData.VassalCount := VassalCount;
         TLifeObject (BasicObject).SendLocalMessage (NOTARGETPHONE, FM_GATHERVASSAL, BasicObject.BasicData, SubData);
      end;
   end;
end;

procedure TAttackSkill.SetHelpTargetID (aTargetID : Integer);
var
   tmpAttackSkill : TAttackSkill;
begin
   if (TLifeObject (BasicObject).LifeObjectState = los_die)
      or (TLifeObject (BasicObject).LifeObjectState = los_init) then exit;

   if aTargetID = BasicObject.BasicData.id then exit;
   if aTargetID = 0 then begin
      if Boss <> nil then begin
         if Boss.BasicData.Feature.rrace = RACE_NPC then
            // tmpAttackSkill := TNpc(Boss).GetAttackSkill;
            tmpAttackSkill := nil
         else
            tmpAttackSkill := TMonster(Boss).GetAttackSkill;
         if tmpAttackSkill <> nil then begin
            if tmpAttackSkill.GetTargetID <> TargetID then begin
               tmpAttackSkill.CancelHelp (TargetID);
            end;
         end;
      end;
      TargetId := aTargetID;
      TLifeObject (BasicObject).LifeObjectState := los_none;
      exit;
   end;

   boSelfTarget := false;

   TargetId := aTargetID;
   TLifeObject (BasicObject).LifeObjectState := los_attack;
   if GroupSkill <> nil then begin
      GroupSkill.Attack (TargetID);
   end;
end;

procedure TAttackSkill.SetHelpTargetIDandPos (aTargetID, aX, aY : Integer);
begin
   if (TLifeObject (BasicObject).LifeObjectState = los_die)
      or (TLifeObject (BasicObject).LifeObjectState = los_init) then exit;

   if aTargetID = BasicObject.BasicData.id then exit;
   if (aTargetID = 0) or (aTargetID = TargetID) then exit;

   boSelfTarget := false;   
   TargetId := aTargetID;

   if aTargetID = 0 then begin
      TLifeObject (BasicObject).LifeObjectState := los_none;
      exit;
   end;
   TLifeObject (BasicObject).LifeObjectState := los_moveattack;
end;

procedure TAttackSkill.SetEscapeID (aEscapeID : Integer);
var
   i, xx, yy, mx, my, len: integer;
   bo : TBasicObject;
begin
   if aEscapeID = BasicObject.BasicData.id then exit;
   TargetId := aEscapeID;
   TLifeObject (BasicObject).LifeObjectState := los_escape;

   bo := TBasicObject (TLifeObject (BasicObject).GetViewObjectById (TargetId));
   if bo = nil then begin
      TLifeObject (BasicObject).LifeObjectState := los_none
   end else begin
      mx := BasicObject.BasicData.x;
      my := BasicObject.BasicData.y;
      len := 0;

      for i := 0 to 10-1 do begin
         xx := BasicObject.BasicData.X - 6 + Random (12);
         yy := BasicObject.BasicData.y - 6 + Random (12);

         if (len < GetLargeLength (bo.PosX, bo.PosY, xx, yy))
            and BasicObject.Maper.isMoveable (xx, yy) then  begin
            Len := GetLargeLength (bo.PosX, bo.PosY, xx, yy);
            mx := xx; my := yy;
         end;
      end;

      if (mx <> BasicObject.BasicData.x) or (my <> BasicObject.BasicData.y) then begin
         TargetX := mx;
         TargetY := my;
      end;
   end;
end;

procedure TAttackSkill.SetAttackMagic (aAttackMagic : TMagicData);
begin
   AttackMagic := aAttackMagic;

   if AttackMagic.rMagicType = MAGICTYPE_BOWING then begin
      BowCount := 5;
      BowAvailInterval := 500;
   end else begin
      BowCount := 5;
      BowAvailInterval := 300;
   end;
end;

procedure TAttackSkill.SetSelfTarget (boFlag : Boolean);
begin
   boSelfTarget := boFlag;
end;

procedure TAttackSkill.SetGroupSkill;
begin
   if GroupSkill = nil then begin
      boGroupSkill := true;
      GroupSkill := TGroupSkill.Create (BasicObject);
   end else begin
      boGroupSkill := true;
   end;
end;

procedure TAttackSkill.AddGroup (aBasicObject : TBasicObject);
begin
   if GroupSkill <> nil then begin
      GroupSkill.AddMember (aBasicObject);
   end;
end;

procedure TAttackSkill.ProcessNone (CurTick : Integer);
var
   nDis : Integer;
   SubData : TSubData;
begin
   if BasicObject.BasicData.Feature.rRace = RACE_NPC then begin
      if TargetPosTick + 3000 < CurTick then begin
         TargetPosTick := CurTick;
         TargetX := BasicObject.CreateX - TLifeObject (BasicObject).ActionWidth div 2 + Random (TLifeObject (BasicObject).ActionWidth);
         TargetY := BasicObject.CreateY - TLifeObject (BasicObject).ActionWidth div 2 + Random (TLifeObject (BasicObject).ActionWidth);
         exit;
      end;

      if TLifeObject (BasicObject).WalkTick + 200 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         {
         nDis := GetLargeLength (BasicObject.BasicData.X, BasicObject.BasicData.Y, TargetX, TargetY);
         if nDis > 10 then
            TLifeObject (BasicObject).GotoXyStandAI (TargetX, TargetY)
         else
         }
            TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end else begin
      if boAttack = false then begin
         CurNearViewHumanId := 0;
         HateHumanId := 0;
      end;
      if boAutoAttack and (EscapeLife < TLifeObject (BasicObject).CurLife)
         and (CurNearViewHumanId <> 0) then begin
         SetTargetId (CurNearViewHumanId, true);
         CurNearViewHumanId := 0;
         exit;
      end;
      if (EscapeLife < TLifeObject (BasicObject).CurLife)
         and (HateHumanId <> 0) then begin
         SetTargetId (HateHumanId, true);
         HateHumanId := 0;
         exit;
      end;

      if (EscapeLife >= TLifeObject (BasicObject).CurLife)
         and (CurNearViewHumanId <> 0) then begin
         SetEscapeId (CurNearViewHumanId);
         CurNearViewHumanId := 0;
         exit;
      end;

      if (EscapeLife >= TLifeObject (BasicObject).CurLife)
         and (HateHumanId <> 0) then begin
         SetEscapeId (HateHumanId);
         HateHumanId := 0;
         exit;
      end;

      if TargetPosTick + 2000 < CurTick then begin
         TargetPosTick := CurTick;
         if Boss <> nil then begin
            TargetX := Boss.BasicData.x - 3 + Random (6);
            TargetY := Boss.BasicData.y - 3 + Random (6);
         end else begin
            TargetX := BasicObject.CreateX - 3 + Random (6);
            TargetY := BasicObject.CreateY - 3 + Random (6);
         end;
         if TLifeObject (BasicObject).SoundNormal.rWavNumber <> 0 then begin
            SetWordString (SubData.SayString, IntToStr (TLifeObject (BasicObject).SoundNormal.rWavNumber) + '.wav');
            TLifeObject (BasicObject).SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicObject.BasicData, SubData);
         end;
         exit;
      end;

      if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed * 2 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         {
         nDis := GetLargeLength (BasicObject.BasicData.X, BasicObject.BasicData.Y, TargetX, TargetY);
         if nDis > 10 then
            TLifeObject (BasicObject).GotoXyStandAI (TargetX, TargetY)
         else
         }
            TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end;
end;

procedure TAttackSkill.ProcessEscape (CurTick : Integer);
begin
   if BasicObject.BasicData.Feature.rrace = RACE_NPC then begin
   end else begin
      if TargetPosTick + 2000 < CurTick then begin
         TargetPosTick := CurTick;
         TLifeObject (BasicObject).LifeObjectState := los_none;
         exit;
      end;

      // if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed div 2 < CurTick then begin
      if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
         if (BasicObject.BasicData.x = TargetX) and (BasicObject.BasicData.y = TargetY) then
            TLifeObject (BasicObject).LifeObjectState := los_none;
      end;
   end;
end;

procedure TAttackSkill.ProcessFollow (CurTick : Integer);
begin

end;

function TAttackSkill.ProcessAttack (CurTick : Integer; aBasicObject : TBasicObject) : Boolean;
var
   bo : TBasicObject;
   key : word;
   boFlag : Boolean;
   nDis : Integer;
   tx, ty : Word;
   xx, yy : Integer;
begin
   Result := true;
   
   boFlag := false;

   try
      bo := TBasicObject (TLifeObject(BasicObject).GetViewObjectById (TargetId));
   except
      bo := nil;
   end;
   if bo = nil then begin
      boFlag := true;
   end else if bo.BasicData.Feature.rRace = RACE_HUMAN then begin
      if TUser(bo).GetLifeObjectState = los_die then boFlag := true;
   end else begin
      if TLifeObject(bo).LifeObjectState = los_die then boFlag := true;
   end;

   if (boflag = false) and (bo <> nil) then begin
      if bo.BasicData.Feature.rHideState = hs_0 then begin
         boFlag := true;
      end;
   end;

   if boFlag = true then begin
      if TLifeObject (aBasicObject).FboCopy = false then begin
         SetTargetID (0, true);
         Result := false;
      end;
      exit;
   end;

   if aBasicObject.BasicData.Feature.rRace = RACE_NPC then begin
      if GetLargeLength (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY) = 1 then begin
         key := GetNextDirection (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY);
         if key = DR_DONTMOVE then exit;   // 困率捞 0 老锭狼 版快牢单 困率捞 1烙..
         if key <> aBasicObject.BasicData.dir then begin
            TLifeObject(aBasicObject).CommandTurn (key);
         end;
         TLifeObject(aBasicObject).CommandHit (CurTick);
      end else begin
         if TLifeObject(aBasicObject).WalkTick + 50 < CurTick then begin
            TLifeObject(aBasicObject).Walktick := CurTick;
            TLifeObject(aBasicObject).GotoXyStand (bo.Posx, bo.Posy);
         end;
      end;
   end else begin
      if EscapeLife >= TLifeObject(aBasicObject).CurLife then begin
         SetEscapeID (TargetID);
         exit;
      end;

      nDis := GetLargeLength (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY);
      if ((AttackMagic.rMagicType = MAGICTYPE_ONLYBOWING) or (AttackMagic.rMagicType = MAGICTYPE_BOWING)) and (boBowAvail = true) then begin
         if (BowCount < 3) or ((nDis >= 3) and (nDis <= 5)) then begin
         // if (nDis >= 3) and (nDis <= 5) then begin
            key := GetNextDirection (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY);
            if key = DR_DONTMOVE then exit;   // 困率捞 0 老锭狼 版快牢单 困率捞 1烙..
            if key <> aBasicObject.BasicData.dir then begin
               TLifeObject (aBasicObject).CommandTurn (key);
               exit;
            end;

            if TLifeObject(aBasicObject).ShootMagic (AttackMagic, bo) = true then begin
               Dec (BowCount);
               if BowCount <= 0 then begin
                  boBowAvail := false;
                  Case AttackMagic.rMagicType of
                     MAGICTYPE_BOWING :
                        begin
                           BowCount := 5;
                           BowAvailTick := CurTick;
                        end;
                     MAGICTYPE_ONLYBOWING :
                        begin
                           BowCount := 5;
                           BowAvailTick := CurTick;
                        end;
                  end;
               end;
            end;
         end else if nDis < 3 then begin
            {
            key := GetViewDirection (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, BO.PosX, BO.PosY);
            if key = DR_DONTMOVE then exit; // 困率捞 0 老锭狼 版快牢单 困率捞 1烙..
            if key <> aBasicObject.BasicData.dir then begin
               TLifeObject (aBasicObject).CommandTurn (key);
               exit;
            end;
            }
            GetOppositeDirection (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY, tx, ty);
            if not aBasicObject.Maper.isMoveable (tx, ty) then begin
               xx := tx; yy := ty;
               aBasicObject.Maper.GetNearXy (xx, yy);
               tx := xx; ty := yy;
            end;
            TLifeObject(aBasicObject).GotoXyStand (tx, ty);
         end else begin
            TLifeObject(aBasicObject).GotoXyStand (bo.PosX, bo.PosY);
         end;
      end else begin
         if AttackMagic.rMagicType <> MAGICTYPE_ONLYBOWING then begin
            if nDis = 1 then begin
               key := GetNextDirection (aBasicObject.BasicData.X, aBasicObject.BasicData.Y, bo.PosX, bo.PosY);
               if key = DR_DONTMOVE then exit;   // 困率捞 0 老锭狼 版快牢单 困率捞 1烙..
               if key <> aBasicObject.BasicData.dir then begin
                  TLifeObject (aBasicObject).CommandTurn (key);
               end else begin
                  TLifeObject (aBasicObject).CommandHit (CurTick);
               end;
            end else begin
               if TLifeObject(aBasicObject).WalkTick + TLifeObject(aBasicObject).WalkSpeed < CurTick then begin
                  TLifeObject(aBasicObject).WalkTick := CurTick;
                  TLifeObject(aBasicObject).GotoXyStand (bo.Posx, bo.Posy);
               end;
            end;
         end;
         if BowAvailTick + BowAvailInterval < CurTick then begin
            boBowAvail := true;
         end;
      end;
   end;
end;

procedure TAttackSkill.ProcessMoveAttack (Curtick : Integer);
var
   BO : TBasicObject;
begin
   bo := TBasicObject (TLifeObject(BasicObject).GetViewObjectById (TargetId));
   if bo <> nil then begin
      TLifeObject(BasicObject).LifeObjectState := los_attack;
      exit;
   end;
   if BasicObject.BasicData.Feature.rRace = RACE_NPC then begin
      if TLifeObject (BasicObject).WalkTick + 200 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end else begin
      if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed * 2 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end;
end;

procedure TAttackSkill.ProcessDeadAttack (CurTick : Integer);
var
   pUser : TUser;
   key : word;
   boFlag : Boolean;
begin
   boFlag := false;

   pUser := UserList.GetUserPointer (DeadAttackName);
   if pUser = nil then begin
      boFlag := true;
   end else begin
      if pUser.GetLifeObjectState = los_die then boFlag := true;
      if pUser.ServerID <> BasicObject.ServerID then boFlag := true;
   end;

   if boFlag = true then begin
      DeadAttackName := '';
      // TLifeObject (BasicObject).LifeObjectState := los_none;
      TLifeObject (BasicObject).FboAllowDelete := true;
      exit;
   end;

   if GetLargeLength (BasicObject.BasicData.X, BasicObject.BasicData.Y, pUser.PosX, pUser.PosY) = 1 then begin
      key := GetNextDirection (BasicObject.BasicData.X, BasicObject.BasicData.Y, pUser.PosX, pUser.PosY);
      if key = DR_DONTMOVE then exit;
      if key <> BasicObject.BasicData.dir then begin
         TLifeObject(BasicObject).CommandTurn (key);
      end;
      TLifeObject(BasicObject).CommandHit (CurTick);
   end else begin
      if TLifeObject(BasicObject).WalkTick + 50 < CurTick then begin
         TLifeObject(BasicObject).WalkTick := CurTick;
         {
         if TLifeObject(BasicObject).MaxLife >= 5000 then begin
            TLifeObject(BasicObject).GotoXyStandAI (pUser.PosX, pUser.PosY);
         end else begin
         }
            TLifeObject(BasicObject).GotoXyStand (pUser.PosX, pUser.PosY);
         // end;
      end;
   end;
end;

procedure TAttackSkill.ProcessMoveWork (CurTick : Integer);
var
   iLen : Integer;
begin
   // 沥犬洒 格利瘤俊 档馒
   if (BasicObject.BasicData.X = TargetX) and (BasicObject.BasicData.Y = TargetY) then begin
      TargetArrivalTick := CurTick;
      TLifeObject (BasicObject).LifeObjectState := SaveNextState;
      exit;
   end;
   // 茄伎 裹困 捞郴肺 档馒
   iLen := GetLargeLength (BasicObject.BasicData.X, BasicObject.BasicData.Y, TargetX, TargetY);
   if iLen <= 1 then begin
      TargetArrivalTick := CurTick;
      TLifeObject (BasicObject).LifeObjectState := SaveNextState;
      exit;
   end;
   
   if CurTick >= TargetStartTick + 1500 then begin
      TargetArrivalTick := CurTick;
      if TargetID <> 0 then TLifeObject (BasicObject).LifeObjectState := los_attack
      else TLifeObject (BasicObject).LifeObjectState := los_none;
      exit;
   end;
   if BasicObject.BasicData.Feature.rRace = RACE_NPC then begin
      if TLifeObject (BasicObject).WalkTick + 200 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end else begin
      if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end;
end;

function TAttackSkill.ProcessMove (CurTick : Integer) : Boolean;
begin
   Result := false;
   
   if (BasicObject.BasicData.X = TargetX) and (BasicObject.BasicData.Y = TargetY) then begin
      TargetArrivalTick := CurTick;
      Result := true;
      exit;
   end;
   if BasicObject.BasicData.Feature.rRace = RACE_NPC then begin
      if TLifeObject (BasicObject).WalkTick + 200 < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end else begin
      if TLifeObject (BasicObject).WalkTick + TLifeObject (BasicObject).WalkSpeed < CurTick then begin
         TLifeObject (BasicObject).WalkTick := CurTick;
         TLifeObject (BasicObject).GotoXyStand (TargetX, TargetY);
      end;
   end;
end;

procedure TAttackSkill.NoticeDie;
var
   tmpAttackSkill : TAttackSkill;
begin
   if Boss <> nil then begin
      if Boss.BasicData.Feature.rRace = RACE_NPC then
         tmpAttackSkill := TNpc(Boss).GetAttackSkill
      else
         tmpAttackSkill := TMonster(Boss).GetAttackSkill;

      if tmpAttackSkill <> nil then begin
         tmpAttackSkill.MemberDie (BasicObject);
      end;
   end;
end;

procedure TAttackSkill.MemberDie (aBasicObject : TBasicObject);
begin
   if GroupSkill <> nil then begin
      GroupSkill.DeleteMember (aBasicObject);
   end;
end;

constructor TGroupSkill.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;
   MemberList := TList.Create;
end;

destructor TGroupSkill.Destroy;
begin
   if MemberList <> nil then MemberList.Free;
   inherited Destroy;
end;

procedure TGroupSkill.AddMember (aBasicObject : TBasicObject);
begin
   MemberList.Add (aBasicObject);
end;

procedure TGroupSkill.DeleteMember (aBasicObject : TBasicObject);
var
   i : Integer;
begin
   if aBasicObject = nil then exit;
   for i := 0 to MemberList.Count - 1 do begin
      if aBasicObject = MemberList[i] then begin
         MemberList.Delete (i);
         exit;
      end;
   end;
end;

procedure TGroupSkill.ChangeBoss (aBasicObject : TBasicObject);
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then begin
            AttackSkill := TMonster (BO).GetAttackSkill;
         end else if BO.BasicData.Feature.rRace = RACE_NPC then begin
            AttackSkill := TNpc (BO).GetAttackSkill;
         end else begin
            AttackSkill := nil;
         end;
         if AttackSkill <> nil then begin
            AttackSkill.SetBoss (aBasicObject);
         end;
      end;
   end;
end;

procedure TGroupSkill.BossDie;
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then
            AttackSkill := TMonster (BO).GetAttackSkill
         else
            AttackSkill := TNpc (BO).GetAttackSkill;

         if AttackSkill <> nil then begin
            AttackSkill.SetBoss (nil);
         end;
      end;
   end;
end;

procedure TGroupSkill.FollowMe;
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then
            AttackSkill := TMonster (BO).GetAttackSkill
         else
            AttackSkill := TNpc (BO).GetAttackSkill;

         if AttackSkill <> nil then begin
            AttackSkill.TargetX := BasicObject.BasicData.x;
            AttackSkill.TargetY := BasicObject.BasicData.y;
         end;
      end;
   end;
end;

procedure TGroupSkill.FollowEachOther;
begin

end;

procedure TGroupSkill.Attack (aTargetID : Integer);
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then
            AttackSkill := TMonster (BO).GetAttackSkill
         else
            AttackSkill := TNpc (BO).GetAttackSkill;

         if AttackSkill <> nil then begin
            AttackSkill.SetHelpTargetID (aTargetID);
         end;
      end;
   end;
end;

procedure TGroupSkill.MoveAttack (aTargetID, aX, aY : Integer);
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then
            AttackSkill := TMonster (BO).GetAttackSkill
         else
            AttackSkill := TNpc (BO).GetAttackSkill;

         if AttackSkill <> nil then begin
            AttackSkill.SetHelpTargetIDandPos (aTargetID, aX, aY);
         end;
      end;
   end;
end;

procedure TGroupSkill.CancelTarget (aTargetID : Integer);
var
   i : Integer;
   BO : TBasicObject;
   AttackSkill : TAttackSkill;
begin
   for i := 0 to MemberList.Count - 1 do begin
      BO := MemberList.Items [i];
      if BO <> nil then begin
         if BO.BasicData.Feature.rRace = RACE_MONSTER then begin
            AttackSkill := TMonster (BO).GetAttackSkill;
         end else if BO.BasicData.Feature.rRace = RACE_NPC then begin
            AttackSkill := TNpc (BO).GetAttackSkill;
         end else begin
            AttackSkill := nil;
         end;

         if AttackSkill <> nil then begin
            if AttackSkill.TargetID = aTargetID then begin
               AttackSkill.SetTargetID (0, true);
            end;
         end;
      end;
   end;
end;

end.


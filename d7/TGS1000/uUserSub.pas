unit uUserSub;

interface

uses
  Windows, SysUtils, Classes, Usersdb, Deftype, AnsUnit,
  AnsImg2, AUtil32, uSendcls, uAnstick, uLevelexp, svClass, AnsStringCls,
  uDBRecordDef, BasicObj;

const
   DRUGARR_SIZE = 3;

type
   TAttribClass = class
   private
     FBasicObject : TBasicObject;
      
     boAddExp : Boolean;   
     boMan : Boolean;

     boSendValues : Boolean;
     boSendBase : Boolean;

     boRevivalFlag : Boolean;
     boEnergyFlag : Boolean;
     boInPowerFlag : Boolean;
     boOutPowerFlag : Boolean;
     boMagicFlag : Boolean;

     FFeatureState : TFeatureState;

     StartTick : integer;
     CheckIncreaseTick : integer;         // 9 ÃÊ¿¡ ÇÑ¹ø
     CheckDrugTick : integer;         // 1 ÃÊ¿¡ ÇÑ¹ø

     FSendClass : TSendClass;
     function  GetCurInPower: integer;
     procedure SetCurInPower (value: integer);
     function  GetCurOutPower: integer;
     procedure SetCurOutPower (value: integer);
     function  GetCurMagic: integer;
     procedure SetCurMagic (value: integer);
     function  GetCurLife: integer;
     procedure SetCurLife (value: integer);
     function  GetMaxLife: integer;

     function  GetCurHeadLife: integer;
     procedure SetCurHeadLife (value: integer);
     function  GetCurArmLife: integer;
     procedure SetCurArmLife (value: integer);
     function  GetCurLegLife: integer;
     procedure SetCurLegLife (value: integer);

     function  CheckRevival: Boolean;
     function  CheckEnegy: Boolean;
     function  CheckInPower: Boolean;
     function  CheckOutPower: Boolean;
     function  CheckMagic: Boolean;

     procedure SetLifeData;
   public
     ItemDrugArr : array [0..DRUGARR_SIZE-1] of TItemDrugData;
     CurAttribData : TCurAttribData;
     AttribData : TAttribData;
     AttribLifeData : TLifeData;

     ReQuestPlaySoundNumber : integer;

     constructor Create (aBasicObject : TBasicObject; aSendClass: TSendClass);
     destructor Destroy; override;
     procedure Update (CurTick : integer);
     function  AddItemDrug (aDrugName: string): Boolean;

     procedure LoadFromSdb (aCharData : PTDBRecord);
     procedure SaveToSdb (aCharData : PTDBRecord);
     procedure Calculate;

     procedure AddAdaptive (aexp: integer);

     property  CurMagic : Integer read GetCurMagic write SetCurMagic;
     property  CurOutPower : Integer read GetCurOutPower write SetCurOutPower;
     property  CurInPower : Integer read GetCurInPower write SetCurInPower;
     property  CurLife : Integer read GetCurLife write SetCurLife;
     property  MaxLife : Integer read GetMaxLife;

     property  CurHeadLife : Integer read GetCurHeadLife write SetCurHeadLife;
     property  CurArmLife : Integer read GetCurArmLife write SetCurArmLife;
     property  CurLegLife : Integer read GetCurLegLife write SetCurLegLife;

     property  FeatureState : TFeatureState write FFeatureState;

     property  SetAddExpFlag : Boolean write boAddExp;
   public
     function GetAge : Integer;
   end;

   THaveMagicClass = class
   private
     FBasicObject : TBasicObject;
      
     boAddExp : Boolean;

     HaveItemType : integer;
     HaveMagicArr : array [0..HAVEMAGICSIZE-1] of TMagicData;

     WalkingCount : integer;

     FpCurAttackMagic     : PTMagicData;
     FpCurBreathngMagic   : PTMagicData;
     FpCurRunningMagic    : PTMagicData;
     FpCurProtectingMagic : PTMagicData;
     FpCurEctMagic : PTMagicData;

     FSendClass : TSendClass;
     FAttribClass : TAttribClass;
     function  boKeepingMagic (pMagicData: PTMagicData): Boolean;
     procedure DecBreathngAttrib (pMagicData: PTMagicData);

     procedure Dec5SecAttrib (pMagicData: PTMagicData);
     procedure DecEventAttrib (pMagicData: PTMagicData);
     procedure SetLifeData;
     procedure FindAndSendMagic (pMagicData: PTMagicData);
   public
     DefaultMagic : array [0..10-1] of TMagicData;
     HaveMagicLifeData : TLifeData;
     ReQuestPlaySoundNumber : integer;
     constructor Create (aBasicObject : TBasicObject; aSendClass: TSendClass; aAttribClass: TAttribClass);
     destructor Destroy; override;
     function   Update (CurTick : integer): integer;

     procedure LoadFromSdb (aCharData : PTDBRecord);
     procedure SaveToSdb (aCharData : PTDBRecord);
     function  ViewMagic (akey: integer; aMagicData: PTMagicData): Boolean;
     function  ViewBasicMagic (akey: integer; aMagicData: PTMagicData): Boolean;
     function  AddMagic  (aMagicData: PTMagicData): Boolean;
     function  DeleteMagic (akey: integer): Boolean;
     function  AddAttackExp ( atype, aexp: integer): integer;
     function  AddProtectExp ( atype, aexp: integer): integer;
     function  AddEctExp ( atype, aexp: integer): integer;

     procedure SetBreathngMagic (aMagic: PTMagicData);
     procedure SetRunningMagic (aMagic: PTMagicData);
     procedure SetProtectingMagic (aMagic: PTMagicData);
     procedure SetEctMagic (aMagic: PTMagicData);
     function  AddWalking: Boolean;

     // function  SetHaveMagicPercent (akey: integer; aper: integer): Boolean;
     // function  SetDefaultMagicPercent (akey: integer; aper: integer): Boolean;
     function  PreSelectBasicMagic (akey, aper: integer; var RetStr: string): Boolean;
     function  SelectBasicMagic (akey, aper: integer; var RetStr: string): integer;
     // function  FindBasicMagic (akey : Integer) : Integer;
     function  SetHaveItemMagicType (atype: integer): integer;
     function  PreSelectHaveMagic (akey, aper: integer; var RetStr: string): Boolean;
     function  SelectHaveMagic (akey, aper: integer; var RetStr: string): integer;
     function  ChangeMagic (asour, adest: integer): Boolean;
     function  ChangeBasicMagic (asour, adest: integer): Boolean;

     function  DecEventMagic (apmagic: PTMagicData): Boolean;

     function  GetUsedMagicList: string;
     function  GetMagicIndex(aMagicName: string): integer;

     function  FindHaveMagicByName (aMagicName : String) : Integer;

     property  pCurAttackMagic: PTMagicData read FpCurAttackMagic;
     property  pCurBreathngMagic: PTMagicData read FpCurBreathngMagic;
     property  pCurRunningMagic: PTMagicData read FpCurRunningMagic;
     property  pCurProtectingMagic: PTMagicData read FpCurProtectingMagic;

     property  pCurEctMagic: PTMagicData read FpCurEctMagic;
     property  SetAddExpFlag : Boolean write boAddExp;
   end;

   TWearItemClass = class
   private
     boLocked : Boolean;
     FBasicObject : TBasicObject;

     WearFeature : TFeature;
     WearItemArr : array [ARR_BODY..ARR_WEAPON] of TItemData;
     FSendClass : TSendClass;
     FAttribClass : TAttribClass;
     procedure SetLifeData;
   public
     WearItemLifeData : TLifeData;
     ReQuestPlaySoundNumber : integer;
     constructor Create (aBasicObject : TBasicObject; aSendClass: TSendClass; aAttribClass: TAttribClass);
     destructor Destroy; override;
     procedure Update (CurTick : integer);

     function  GetFeature : TFeature;
     procedure LoadFromSdb (aCharData : PTDBRecord);
     procedure SaveToSdb (aCharData : PTDBRecord);

     function  ViewItem (akey: integer; aItemData: PTItemData): Boolean;
     function  AddItem  (aItemData: PTItemData): Boolean;
     procedure DeleteKeyItem (akey: integer);
     function  ChangeItem  (var aItemData: TItemData; var aOldItemData : TItemData): Boolean;
     function  GetWeaponType : Integer;

     procedure SetFeatureState (aFeatureState : TFeatureState);
     procedure SetHiddenState (aHiddenState : THiddenState);
     procedure SetActionState (aActionState : TActionState);
     function  GetHiddenState : THiddenState;
     function  GetActionState : TActionState;

     property Locked : Boolean read boLocked write boLocked;
   end;

   THaveItemClass = class
   private
     boLocked : Boolean;

     FUserName : string;
     FSendClass : TSendClass;
     FAttribClass : TAttribClass;
   public
     HaveItemArr : array [0..HAVEITEMSIZE-1] of TItemData;
     ReQuestPlaySoundNumber : integer;
     constructor Create (aSendClass: TSendClass; aAttribClass: TAttribClass);
     destructor Destroy; override;
     procedure Update (CurTick : integer);

     procedure LoadFromSdb (aCharData : PTDBRecord);
     procedure SaveToSdb (aCharData : PTDBRecord);

     procedure CopyFromHaveItemClass (aHaveItemClass : THaveItemClass);
     procedure CopyFromHaveItem (aItemArr : PTItemData);

     function  FreeSpace: integer;

     function  ViewItem (akey: integer; aItemData: PTItemData): Boolean;
     function  FindItem (aItemData : PTItemData): Boolean;
     function  AddItem  (aItemData: PTItemData): Boolean;
     function  AddKeyItem  (akey, aCount : Integer; var aItemData: TItemData): Boolean;
     function  FindKindItem (akind: integer): integer;
     function  FindItemByMagicKind (aKind: integer): integer;
     function  DeletekeyItem (akey, aCount: integer; aItemData : PTItemData): Boolean;
     function  DeleteItem (aItemData: PTItemData): Boolean;
     function  ChangeItem (asour, adest: integer): Boolean;

     procedure DeleteAllItem;

     procedure Refresh;

     property Locked : Boolean read boLocked write boLocked;     
   end;


implementation

uses
   FSockets, svMain, uUser;

function  GetPermitExp (aLevel, addvalue: integer): integer;
var n : integer;
begin
   n := GetLevelMaxExp (aLevel);
   if n > addvalue then n := addvalue;
   Result := n;
end;

function  AddPermitExp (var aLevel, aExp: integer; addvalue: integer): integer;
var n : integer;
begin
   n := GetLevelMaxExp (aLevel) * 3;
   if n > addvalue then n := addvalue;
   inc (aExp, n);
   aLevel := GetLevel (aExp);
   Result := n;

{  // Á¤»ó
   n := GetLevelMaxExp (aLevel);
   if n > addvalue then n := addvalue;
   inc (aExp, n);
   aLevel := GetLevel (aExp);
   Result := n;
}
{  // ÀüºÎÇã¿ë
   n := GetLevelMaxExp (aLevel);
   if n <> 0 then n := addvalue;
   inc (aExp, n);
   aLevel := GetLevel (aExp);
   Result := n;
}
end;

function Get10000To100 (avalue: integer): string;
var
   n : integer;
   str : string;
begin
   str := InttoStr (avalue div 100) + '.';
   n := avalue mod 100;
   if n >= 10 then str := str + IntToStr (n)
   else str := str + '0'+InttoStr(n);

   Result := str;
end;

function Get10000To120 (avalue: integer): string;
var
   n : integer;
   str : string;
begin
   avalue := avalue * 12 div 10;
   str := InttoStr (avalue div 100) + '.';
   n := avalue mod 100;
   if n >= 10 then str := str + IntToStr (n)
   else str := str + '0'+InttoStr(n);

   Result := str;
end;


///////////////////////////////////
//         TAttribClass
///////////////////////////////////

constructor TAttribClass.Create (aBasicObject : TBasicObject; aSendClass: TSendClass);
begin
   FBasicObject := aBasicObject;
   boAddExp := true;
   ReQuestPlaySoundNumber := 0;
   FSendClass := aSendClass;
end;

destructor TAttribClass.Destroy;
begin
   inherited Destroy;
end;

procedure TAttribClass.SetLifeData;
begin
   FillChar (AttribLifeData, sizeof(TLifeData), 0);
   
   AttribLifeData.damageBody   := 41;
   AttribLifeData.damageHead   := 41;
   AttribLifeData.damageArm    := 41;
   AttribLifeData.damageLeg    := 41;
   AttribLifeData.AttackSpeed  := 70;
   AttribLifeData.avoid        := 25;
   AttribLifeData.recovery     := 50;
   AttribLifeData.armorBody    := 0;
   AttribLifeData.armorHead    := 0;
   AttribLifeData.armorArm     := 0;
   AttribLifeData.armorLeg     := 0;

   TUserObject (FBasicObject).SetLifeData;
end;

function TAttribClass.GetAge : Integer;
begin
   Result := AttribData.cAge;
end;

function  TAttribClass.GetCurHeadLife: integer;
begin
   Result := CurAttribData.CurHeadSeak;
end;

function  TAttribClass.GetCurArmLife: integer;
begin
   Result := CurAttribData.CurArmSeak;
end;

function  TAttribClass.GetCurLegLife: integer;
begin
   Result := CurAttribData.CurLegSeak;
end;

function  TAttribClass.GetCurLife : integer;
begin
   Result := CurAttribData.CurLife;
end;

function  TAttribClass.GetCurMagic : integer;
begin
   Result := CurAttribData.CurMagic;
end;

function  TAttribClass.GetCurOutPower : integer;
begin
   Result := CurAttribData.CurOutPower;
end;

function  TAttribClass.GetCurInPower : integer;
begin
   Result := CurAttribData.CurInPower;
end;

function  TAttribClass.GetMaxLife: integer;
begin
   Result := AttribData.cLife;
end;

procedure TAttribClass.SetCurHeadLife (value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurHeadSeak = Value then exit;
   CurAttribData.CurHeadSeak := Value;
   if CurAttribData.CurHeadSeak > AttribData.cHeadSeak then CurAttribData.CurHeadSeak := AttribData.cHeadSeak;
   boSendValues := TRUE;
end;

procedure TAttribClass.SetCurArmLife (value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurArmSeak = Value then exit;
   CurAttribData.CurArmSeak := Value;
   if CurAttribData.CurArmSeak > AttribData.cArmSeak then CurAttribData.CurArmSeak := AttribData.cArmSeak;
   boSendValues := TRUE;
end;

procedure TAttribClass.SetCurLegLife (value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurLegSeak = Value then exit;
   CurAttribData.CurLegSeak := Value;
   if CurAttribData.CurLegSeak > AttribData.cLegSeak then CurAttribData.CurLegSeak := AttribData.cLegSeak;
   boSendValues := TRUE;
end;

procedure TAttribClass.SetCurLife (Value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurLife = Value then exit;
   CurAttribData.CurLife := Value;
   if CurAttribData.CurLife > AttribData.cLife then CurAttribData.CurLife := AttribData.cLife;
   boSendBase := TRUE;
end;

procedure TAttribClass.SetCurMagic (Value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurMagic = Value then exit;
   CurAttribData.CurMagic := Value;
   if CurAttribData.CurMagic > AttribData.cMagic then CurAttribData.CurMagic := AttribData.cMagic;
   boSendBase := TRUE;
end;

procedure TAttribClass.SetCurInPower (Value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurInPower = Value then exit;
   CurAttribData.CurInPower := Value;
   if CurAttribData.CurInPower > AttribData.cInPower then CurAttribData.CurInPower := AttribData.cInPower;
   boSendBase := TRUE;
end;

procedure TAttribClass.SetCurOutPower (Value: integer);
begin
   if Value < 0 then Value := 0;
   if CurAttribData.CurOutPower = Value then exit;
   CurAttribData.CurOutPower := Value;
   if CurAttribData.CurOutPower > AttribData.cOutPower then CurAttribData.CurOutPower := AttribData.cOutPower;
   boSendBase := TRUE;
end;

procedure TAttribClass.AddAdaptive (aexp: integer);
var oldslevel : integer;
begin
   if boAddExp = false then exit;
   oldslevel := AttribData.cAdaptive;
   if AddPermitExp (AttribData.cAdaptive, AttribData.Adaptive, DEFAULTEXP) <> 0 then
      FSendClass.SendEventString ('ÄÍÐÔ');
   if oldslevel <> AttribData.cAdaptive then boSendValues := TRUE;
end;

function  TAttribClass.CheckRevival: Boolean;
var
   oldslevel : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;

   if boRevivalFlag then begin
      if CurAttribData.CurLife <= 0 then begin
         oldslevel := AttribData.cRevival;
         if AddPermitExp (AttribData.cRevival, AttribData.Revival, DEFAULTEXP) <> 0 then
            FSendClass.SendEventString ('ÔÙÉú');
         if oldslevel <> AttribData.cRevival then boSendValues := TRUE;

         boRevivalFlag := FALSE;
         boEnergyFlag := FALSE;
         boInPowerFlag := FALSE;
         boOutPowerFlag := FALSE;
         boMagicFlag := FALSE;

         Result := TRUE;
      end;
      exit;
   end;
   if (AttribData.cLife - AttribData.cLife div 10) < CurAttribData.CurLife then boRevivalFlag := TRUE;
end;

function  TAttribClass.CheckEnegy: Boolean;
var curslevel, oldslevel : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;

   if boEnergyFlag then begin
      if (AttribData.cEnergy - AttribData.cEnergy div 10) < CurAttribData.CurEnergy then begin
         curslevel := GetLevel (AttribData.Energy);
         oldslevel := curslevel;
         if AddPermitExp (curslevel, AttribData.Energy, DEFAULTEXP) <> 0 then
            FSendClass.SendEventString ('ÔªÆø');
         if oldslevel <> curslevel then boSendBase := TRUE;
         boEnergyFlag := FALSE;
         Result := TRUE;
      end;
      exit;
   end;
   if (AttribData.cEnergy div 10) > CurAttribData.CurEnergy then boEnergyFlag := TRUE;
end;

function  TAttribClass.CheckInPower: Boolean;
var curslevel, oldslevel : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;

   if boInPowerFlag then begin
      if (AttribData.cInPower - AttribData.cInPower div 10) < CurAttribData.CurInPower then begin
         curslevel := GetLevel (AttribData.InPower);
         oldslevel := curslevel;
         if AddPermitExp (curslevel, AttribData.InPower, DEFAULTEXP) <> 0 then
            FSendClass.SendEventString ('ÄÚ¹¦');
         if oldslevel <> curslevel then boSendBase := TRUE;
         boInPowerFlag := FALSE;
         Result := TRUE;
      end;
      exit;
   end;
   if (AttribData.cInPower div 10) > CurAttribData.CurInPower then boInPowerFlag := TRUE;
end;

function  TAttribClass.CheckOutPower: Boolean;
var curslevel, oldslevel : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;

   if boOutPowerFlag then begin
      if (AttribData.cOutPower - AttribData.cOutPower div 10) < CurAttribData.CurOutPower then begin
         curslevel := GetLevel (AttribData.OutPower);
         oldslevel := curslevel;
         if AddPermitExp (curslevel, AttribData.OutPower, DEFAULTEXP) <> 0 then
            FSendClass.SendEventString ('Íâ¹¦');
         if oldslevel <> curslevel then boSendBase := TRUE;
         boOutPowerFlag := FALSE;
         Result := TRUE;
      end;
      exit;
   end;
   if (AttribData.cOutPower div 10) > CurAttribData.CurOutPower then boOutPowerFlag := TRUE;
end;

function  TAttribClass.CheckMagic: Boolean;
var curslevel, oldslevel : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;

   if boMagicFlag then begin
      if (AttribData.cMagic - AttribData.cMagic div 10) < CurAttribData.CurMagic then begin
         curslevel := GetLevel (AttribData.Magic);
         oldslevel := curslevel;
         if AddPermitExp (curslevel, AttribData.Magic, DEFAULTEXP) <> 0 then
            FSendClass.SendEventString ('Îä¹¦');
         if oldslevel <> curslevel then boSendBase := TRUE;
         boMagicFlag := FALSE;
         Result := TRUE;
      end;
      exit;
   end;
   if (AttribData.cMagic div 10) > CurAttribData.CurMagic then boMagicFlag := TRUE;
end;

procedure TAttribClass.LoadFromSdb (aCharData : PTDBRecord);
begin
   ReQuestPlaySoundNumber := 0;
   StartTick := mmAnsTick;
   FFeatureState := wfs_normal;

   boRevivalFlag := FALSE;
   boEnergyFlag := FALSE;
   boInPowerFlag := FALSE;
   boOutPowerFlag := FALSE;
   boMagicFlag := FALSE;

   FillChar (AttribData, sizeof(AttribData), 0);
   FillChar (CurAttribData, sizeof(CurAttribData), 0);
   FillChar (ItemDrugArr, sizeof(ItemDrugArr), 0);

   CheckIncreaseTick := StartTick;
   CheckDrugTick := StartTick;

   boMan := FALSE;

   boMan := false;
   if StrPas (@aCharData^.Sex) = 'ÄÐ' then boMan := true;
   //
   AttribData.Light    := aCharData^.Light;
   AttribData.Dark     := aCharData^.Dark;
   AttribData.Age      := AttribData.Light + AttribData.Dark;
   AttribData.Energy   := aCharData^.Energy;
   AttribData.InPower  := aCharData^.InPower;
   AttribData.OutPower := aCharData^.OutPower;
   AttribData.Magic    := aCharData^.Magic;
   AttribData.Life     := aCharData^.Life;

   with AttribData do begin
      Talent := aCharData^.Talent;
      GoodChar := aCharData^.GoodChar;
      BadChar := aCharData^.BadChar;
{
      str := UserData.GetFieldValueString (aName, 'ÖÆÔìÈÕÆÚ');
      if str <> '' then begin
         try
            lucky := Round (Date - StrToDate (str)) mod 50 + 50;
         except
            lucky := 50;
         end;
      end else begin
         lucky := 50;
      end;
}
      lucky := 50;
      lucky := lucky * 100;
      adaptive := aCharData^.Adaptive;
      revival := aCharData^.Revival;
      immunity := aCharData^.Immunity;
      virtue := aCharData^.Virtue;
   end;

   CurAttribData.CurEnergy    := aCharData^.CurEnergy;
   CurAttribData.CurInPower   := aCharData^.CurInPower;
   CurAttribData.CurOutPower  := aCharData^.CurOutPower;
   CurAttribData.CurMagic     := aCharData^.CurMagic;
   CurAttribData.CurLife      := aCharData^.CurLife;
   CurAttribData.Curhealth    := aCharData^.CurHealth;
   CurAttribData.Cursatiety   := aCharData^.CurSatiety;
   CurAttribData.Curpoisoning := aCharData^.CurPoisoning;
   CurAttribData.CurHeadSeak  := aCharData^.CurHeadSeek;
   CurAttribData.CurArmSeak   := aCharData^.CurArmSeek;
   CurAttribData.CurLegSeak   := aCharData^.CurLegSeek;

   Calculate;

   FSendClass.SendAttribBase (AttribData, CurAttribData);
   FSendClass.SendAttribValues (AttribData, CurAttribData);
   boSendBase := FALSE;
   boSendValues := FALSE;
end;

procedure TAttribClass.SaveToSdb (aCharData : PTDBRecord);
var n : integer;
begin
   if GrobalLightDark = gld_light then begin
      n := aCharData^.Light;
      n := n + (mmAnsTick - StartTick) div 100;
      aCharData^.Light := n;
   end else begin
      n := aCharData^.Dark;
      n := n + (mmAnsTick - StartTick) div 100;
      aCharData^.Dark := n; 
   end;

   aCharData^.CurEnergy := CurAttribData.CurEnergy;
   aCharData^.CurInPower := CurAttribData.CurInPower;
   aCharData^.CurOutPower := CurAttribData.CurOutPower;
   aCharData^.CurMagic := CurAttribData.CurMagic;
   aCharData^.CurLife := CurAttribData.CurLife;
   aCharData^.CurHealth := CurAttribData.Curhealth;
   aCharData^.CurSatiety := CurAttribData.Cursatiety;
   aCharData^.CurPoisoning := CurAttribData.Curpoisoning;
   aCharData^.CurHeadSeek := CurAttribData.CurHeadSeak;
   aCharData^.CurArmSeek := CurAttribData.CurArmSeak;
   aCharData^.CurLegSeek := CurAttribData.CurLegSeak;

   aCharData^.Energy := AttribData.Energy;
   aCharData^.InPower := AttribData.InPower;
   aCharData^.OutPower := AttribData.OutPower;
   aCharData^.Magic := AttribData.Magic;
   aCharData^.Life := AttribData.Life;

   with AttribData do begin
      aCharData^.Talent := Talent;
      aCharData^.GoodChar := GoodChar;
      aCharData^.BadChar := BadChar;
      aCharData^.Adaptive := adaptive;
      aCharData^.Revival := revival;
      aCharData^.Immunity := immunity;
      aCharData^.Virtue := virtue;
   end;

   StartTick := mmAnsTick;

   AttribData.Light    := aCharData^.Light;
   AttribData.Dark     := aCharData^.Dark;
   AttribData.Age      := AttribData.Light + AttribData.Dark;

   Calculate;
end;

procedure TAttribClass.Calculate;
begin
   AttribData.cEnergy   := GetLevel (AttribData.Energy) + 500;     // ±âº»¿ø±â = 5.00
   AttribData.cInPower  := GetLevel (AttribData.InPower) + 1000;   // ±âº»³»°ø = 10.00
   AttribData.cOutPower := GetLevel (AttribData.OutPower) + 1000;  // ±âº»¿Ü°ø = 10.00
   AttribData.cMagic    := GetLevel (AttribData.Magic) + 500;      // ±âº»¹«°ø = 5.00
   AttribData.cLife     := GetLevel (AttribData.Life) + 2000;      // ±âº»È°·Â = 20.00

   AttribData.cAge   := GetLevel (AttribData.Age);
   AttribData.cLight := GetLevel (AttribData.Light + 664);    // ¾çÁ¤±â
   AttribData.cDark  := GetLevel (AttribData.Dark + 664);     // À½Á¤±â

   // ¿ø±â = ±âº»¿ø±â(5) + ³ªÀÌ(50) + ¾à(20) + ³ë·Â(25);
   AttribData.cEnergy := AttribData.cEnergy + (AttribData.cAge div 2);
   // ³»°ø = ±âº»³»°ø (10) + ³ªÀÌ(50) + ...
   AttribData.cInPower := AttribData.cInPower + (AttribData.cAge div 2);
   // ¿Ü°ø = ±âº»¿Ü°ø (10) + ³ªÀÌ(50) + ...
   AttribData.cOutPower := AttribData.cOutPower + (AttribData.cAge div 2);
   // ¹«°ø = ±âº»¹«°ø (10) + ³ªÀÌ(50) + ...
   AttribData.cMagic := AttribData.cMagic + (AttribData.cAge div 2);
   // È°·Â = ±âº»È°·Â(20) + ³ªÀÌ(100) + Á÷¾÷È°·Â + ...
   AttribData.cLife := AttribData.cLife + AttribData.cAge;

   with AttribData do begin
      cTalent := GetLevel (Talent) + (AttribData.cAge div 2);
      cGoodChar := GetLevel (GoodChar);
      cBadChar := GetLevel (BadChar);
//      clucky := GetLevel (lucky);
      clucky := lucky;
      cadaptive := GetLevel (adaptive);
      crevival := GetLevel (revival);
      cimmunity := GetLevel (immunity);
      cvirtue := GetLevel (virtue);

      cHeadSeak := cLife;
      cArmSeak := cLife;
      cLegSeak := cLife;

      cHealth := cLife;
      cSatiety := cLife;
      cPoisoning := cLife;
   end;
   SetLifeData;
end;

function  TAttribClass.AddItemDrug (aDrugName: string): Boolean;
var
   i : integer;
   ItemDrugData : TItemDrugData;
begin
   Result := FALSE;

   ItemDrugClass.GetItemDrugData (aDrugName, ItemDrugData);
   if ItemDrugData.rName[0] = 0 then exit;

   for i := 0 to DRUGARR_SIZE -1 do begin
      if ItemDrugArr[i].rName[0] = 0 then begin
         ItemDrugArr[i] := ItemDrugData;
         ItemDrugArr[i].rUsedCount := 0;
         Result := TRUE;
         CurAttribData.CurPoisoning := CurAttribData.CurPoisoning - CurAttribData.CurPoisoning div 10;
         exit;
      end;
   end;
end;

procedure TAttribClass.Update (CurTick : integer);
   function AddLimitValue (var curvalue: integer; maxvalue, addvalue: integer): Boolean;
   begin
      Result := FALSE;
      if curvalue = maxvalue then exit;
      curvalue := curvalue + addvalue;
      if curvalue > maxvalue then curvalue := maxvalue;
      if curvalue < 0 then curvalue := 0;
      Result := TRUE;
   end;
var
   n, i : integer;
begin

   if CheckRevival  then Calculate;
   if CheckEnegy    then Calculate;
   if CheckInpower  then Calculate;
   if CheckOutpower then Calculate;
   if CheckMagic    then Calculate;

   if CurTick > CheckDrugTick + 100 then begin
      CheckDrugTick := CurTick;
      for i := 0 to DRUGARR_SIZE-1 do begin
         if ItemDrugArr[i].rName[0] = 0 then continue;

         CurAttribData.CurHeadSeak  := CurAttribData.CurHeadSeak + ItemDrugArr[i].rEventHeadLife;
         CurAttribData.CurArmSeak   := CurAttribData.CurArmSeak + ItemDrugArr[i].rEventArmLife;
         CurAttribData.CurLegSeak   := CurAttribData.CurLegSeak + ItemDrugArr[i].rEventLegLife;
         if CurAttribData.CurHeadSeak  > AttribData.cHeadSeak then CurAttribData.CurHeadSeak := AttribData.cHeadSeak;
         if CurAttribData.CurArmSeak   > AttribData.cArmSeak then CurAttribData.CurArmSeak := AttribData.cArmSeak;
         if CurAttribData.CurLegSeak   > AttribData.cLegSeak then CurAttribData.CurLegSeak := AttribData.cLegSeak;

         inc (CurAttribData.CurEnergy, ItemDrugArr[i].rEventEnergy);
         inc (CurAttribData.CurInPower, ItemDrugArr[i].rEventInPower);
         inc (CurAttribData.CurOutPower, ItemDrugArr[i].rEventOutPower);
         inc (CurAttribData.CurMagic, ItemDrugArr[i].rEventMagic);
         inc (CurAttribData.CurLife, ItemDrugArr[i].rEventLife);

         with CurAttribData do begin
            if CurEnergy > AttribData.cEnergy then CurEnergy := AttribData.cEnergy;
            if CurInPower > AttribData.cInPower then CurEnergy := AttribData.cInPower;
            if CurOutPower > AttribData.cOutPower then CurEnergy := AttribData.cOutPower;
            if CurMagic > AttribData.cMagic then CurEnergy := AttribData.cMagic;
            if CurLife > AttribData.cLife then CurEnergy := AttribData.cLife;
         end;

         boSendBase := TRUE;
         boSendValues := TRUE;
         if ItemDrugArr[i].rUsedCount >= 10 then begin 
            FillChar (ItemDrugArr[i], sizeof(TItemDrugData), 0);
         end else inc (ItemDrugArr[i].rUsedCount);
      end;
   end;

   if CurTick > CheckIncreaseTick + 900 then begin
      CheckIncreaseTick := CurTick;
      boSendBase := FALSE;

      n := GetLevel ( (AttribData.Age+(CurTick-StartTick) div 100) );
      if AttribData.cAge <> n then begin
         if (AttribData.cAge div 100) <> (n div 100) then begin
            Calculate;
            FSendClass.SendChatMessage (format ('ÄêÁäÒÑ´ïµ½ %dËê.',[n div 100]), SAY_COLOR_SYSTEM);
         end;
         AttribData.cAge := n;
         boSendBase := TRUE;
      end;

      if GrobalLightDark = gld_light then begin
         n := GetLevel (AttribData.Light+664+(CurTick-StartTick) div 100);
         if AttribData.cLight <> n then begin
            AttribData.cLight := n;
            FSendClass.SendEventString ('ÑôÆø');
            boSendBase := TRUE;
         end;
      end else begin
         n := GetLevel (AttribData.Dark+664+(CurTick-StartTick) div 100);
         if AttribData.cDark <> n then begin
            AttribData.cDark := n;
            FSendClass.SendEventString ('ÒõÆø');
            boSendBase := TRUE;
         end;
      end;

      case FFeatureState of
         wfs_normal   : n := 80;
         wfs_care     : n := 10;
         wfs_sitdown  : n := 150;
         wfs_die      : n := 300;
         else n :=50;
      end;
      n := n + n * AttribData.crevival div 10000;

      CurAttribData.Curhealth    := CurAttribData.Curhealth + n;
      CurAttribData.Cursatiety   := CurAttribData.Cursatiety + n;
      CurAttribData.Curpoisoning := CurAttribData.Curpoisoning + n;
      CurAttribData.CurHeadSeak  := CurAttribData.CurHeadSeak + n;
      CurAttribData.CurArmSeak   := CurAttribData.CurArmSeak + n;
      CurAttribData.CurLegSeak   := CurAttribData.CurLegSeak + n;
      if CurAttribData.Curhealth    > AttribData.cHealth then CurAttribData.Curhealth := AttribData.cHealth;
      if CurAttribData.Cursatiety   > AttribData.cSatiety then CurAttribData.Cursatiety := AttribData.cSatiety;
      if CurAttribData.Curpoisoning > AttribData.cPoisoning then CurAttribData.Curpoisoning := AttribData.cPoisoning;
      if CurAttribData.CurHeadSeak  > AttribData.cHeadSeak then CurAttribData.CurHeadSeak := AttribData.cHeadSeak;
      if CurAttribData.CurArmSeak   > AttribData.cArmSeak then CurAttribData.CurArmSeak := AttribData.cArmSeak;
      if CurAttribData.CurLegSeak   > AttribData.cLegSeak then CurAttribData.CurLegSeak := AttribData.cLegSeak;
      boSendValues := TRUE;

      case FFeatureState of
         wfs_normal   : n := 50;
         wfs_care     : n := 20;
         wfs_sitdown  : n := 70;
         wfs_die      : n := 100;
         else n :=50;
      end;
      n := n + n * AttribData.crevival div 10000;

      if AddLimitValue (CurAttribData.CurEnergy, Attribdata.cEnergy, n div 4) then boSendBase := TRUE;
      if AddLimitValue (CurAttribData.CurInPower, Attribdata.cInPower, n) then boSendBase := TRUE;
      if AddLimitValue (CurAttribData.CurOutPower, Attribdata.cOutPower, n) then boSendBase := TRUE;
      if AddLimitValue (CurAttribData.CurMagic, Attribdata.cMagic, n div 2) then boSendBase := TRUE;
      if AddLimitValue (CurAttribData.CurLife, Attribdata.cLife, n) then boSendBase := TRUE;

      boSendBase := TRUE;
   end;

   if boSendBase then FSendClass.SendAttribBase (AttribData, CurAttribData);
   if boSendValues then FSendClass.SendAttribValues (AttribData, CurAttribData);
   boSendBase := FALSE;
   boSendValues := FALSE;
end;




///////////////////////////////////
//         THaveItemClass
///////////////////////////////////

constructor THaveItemClass.Create (aSendClass: TSendClass; aAttribClass: TAttribClass);
begin
   boLocked := false;
   ReQuestPlaySoundNumber := 0;
   FSendClass := aSendClass;
   FAttribClass := aAttribClass;
   FUserName := '';
end;

destructor THaveItemClass.Destroy;
begin
   inherited destroy;
end;

procedure THaveItemClass.Update (CurTick : integer);
begin

end;

procedure THaveItemClass.LoadFromSdb (aCharData : PTDBRecord);
var
   i, j : integer;
   ItemData : TItemData;
   str : String;
begin
   boLocked := false;
   ReQuestPlaySoundNumber := 0;
   
   FUserName := StrPas (@aCharData^.PrimaryKey);
   for i := 0 to HAVEITEMSIZE-1 do begin
      str := StrPas (@aCharData^.HaveItemArr[i].Name) + ':' + IntToStr (aCharData^.HaveItemArr[i].Color) + ':' + IntToStr (aCharData^.HaveItemArr[i].Count);
      ItemClass.GetWearItemData (str, HaveItemArr[i]);
   end;

   for i := 0 to HAVEITEMSIZE-1 do begin
      if HaveItemArr[i].rName[0] <> 0 then begin
         if HaveItemArr[i].rboDouble = true then begin
            if HaveItemArr[i].rKind = 1 then begin
               ItemClass.GetItemData (StrPas(@HaveItemArr[i].rName), ItemData);
               if StrPas(@ItemData.rName) = StrPas (@HaveItemArr[i].rName) then begin
                  if HaveItemArr[i].rColor <> ItemData.rcolor then begin
                     HaveItemArr[i].rColor := ItemData.rColor;
                  end;
               end;
            end;
         end;
      end;
   end;

   for i := 0 to HAVEITEMSIZE-1 do begin
      if HaveItemArr[i].rName[0] <> 0 then begin
         if HaveItemArr[i].rboDouble = true then begin
            for j := i + 1 to HAVEITEMSIZE - 1 do begin
               if StrPas(@HaveItemArr[i].rName) = StrPas(@HaveItemArr[j].rName) then begin
                  if HaveItemArr[i].rColor = HaveItemArr[j].rColor then begin
                     HaveItemArr[i].rCount := HaveItemArr[i].rCount + HaveItemArr[j].rCount;
                     FillChar (HaveItemArr[j], SizeOf (TItemData), 0);
                  end;
               end;
            end;
         end else begin
            {
            if HaveItemArr[i].rCount >= 10 then begin
               frmMain.WriteLogInfo (format ('HaveItemInfo %s, %s, %d', [aName, StrPas(@HaveItemArr[i].rName), HaveItemArr[i].rCount]));
            end;
            }
            for j := 0 to HAVEITEMSIZE - 1 do begin
               if HaveItemArr[i].rCount <= 1 then break;
               if HaveItemArr[j].rName[0] = 0 then begin
                  HaveItemArr[i].rCount := HaveItemArr[i].rCount - 1;
                  Move (HaveItemArr[i], HaveItemArr[j], SizeOf (TItemData));
                  HaveItemArr[j].rCount := 1;
               end;
            end;
         end;
      end;
   end;

   for i := 0 to HAVEITEMSIZE-1 do begin
      FSendClass.SendHaveItem (i, HaveItemArr[i]);
   end;
end;

procedure THaveItemClass.CopyFromHaveItemClass (aHaveItemClass : THaveItemClass);
var
   i, j : Integer;
   ItemData : TItemData;
   OldItemArr, NewItemArr : array [0..HAVEITEMSIZE - 1] of TItemData;
   Name : String;
   Color, Count : Integer;
begin
   if FAttribClass <> nil then begin
      CopyFromHaveItem (@OldItemArr);
      aHaveItemClass.CopyFromHaveItem (@NewItemArr);
      for i := 0 to HAVEITEMSIZE - 1 do begin
         if OldItemArr[i].rName[0] <> 0 then begin
            for j := 0 to HAVEITEMSIZE - 1 do begin
               if NewItemArr[j].rName[0] <> 0 then begin
                  if StrPas (@OldItemArr[i].rName) = StrPas (@NewItemArr[j].rName) then begin
                     if OldItemArr[i].rColor = NewItemArr[j].rColor then begin
                        if OldItemArr[i].rCount = NewItemArr[j].rCount then begin
                           OldItemArr[i].rName[0] := 0;
                           OldItemArr[i].rColor := 0;
                           OldItemArr[i].rCount := 0;
                           NewItemArr[j].rName[0] := 0;
                           NewItemArr[j].rColor := 0;
                           NewItemArr[j].rCount := 0;
                           break;
                        end else if OldItemArr[i].rCount < NewItemArr[j].rCount then begin
                           NewItemArr[j].rCount := NewItemArr[j].rCount - OldItemArr[i].rCount;
                           OldItemArr[i].rName[0] := 0;
                           OldItemArr[i].rColor := 0;
                           OldItemArr[i].rCount := 0;
                           break;
                        end else begin
                           OldItemArr[i].rCount := OldItemArr[i].rCount - NewItemArr[j].rCount;
                           NewItemArr[j].rName[0] := 0;
                           NewItemArr[j].rColor := 0;
                           NewItemArr[j].rCount := 0;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;
      for i := 0 to HAVEITEMSIZE - 1 do begin
         if NewItemArr[i].rName[0] <> 0 then begin
            for j := 0 to HAVEITEMSIZE - 1 do begin
               if OldItemArr[j].rName[0] <> 0 then begin
                  if StrPas (@NewItemArr[i].rName) = StrPas (@OldItemArr[j].rName) then begin
                     if NewItemArr[i].rColor = OldItemArr[j].rColor then begin
                        if NewItemArr[i].rCount = OldItemArr[j].rCount then begin
                           NewItemArr[i].rName[0] := 0;
                           NewItemArr[i].rColor := 0;
                           NewItemArr[i].rCount := 0;
                           OldItemArr[j].rName[0] := 0;
                           OldItemArr[j].rColor := 0;
                           OldItemArr[j].rCount := 0;
                           break;
                        end else if NewItemArr[i].rCount < OldItemArr[j].rCount then begin
                           OldItemArr[j].rCount := OldItemArr[j].rCount - NewItemArr[i].rCount;
                           NewItemArr[i].rName[0] := 0;
                           NewItemArr[i].rColor := 0;
                           NewItemArr[i].rCount := 0;
                           break;
                        end else begin
                           NewItemArr[i].rCount := NewItemArr[i].rCount - OldItemArr[j].rCount;
                           OldItemArr[j].rName[0] := 0;
                           OldItemArr[j].rColor := 0;
                           OldItemArr[j].rCount := 0;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;

      for i := 0 to HAVEITEMSIZE - 1 do begin
         if OldItemArr[i].rName [0] <> 0 then begin
            // if (aItemData^.rPrice * aItemData^.rCount >= 100) or (aItemData^.rcolor <> 1) then begin
            FSendClass.SendItemMoveInfo (FUserName + ',' + '@¸£´ü' + ',' + StrPas(@OldItemArr[i].rName) + ',' + IntToStr(OldItemArr[i].rCount)
            + ',' + IntToStr(0) + ',' + IntToStr(0) + ',' + IntToStr(0) + ',,');
            // end;
         end;
      end;
      for i := 0 to HAVEITEMSIZE - 1 do begin
         if NewItemArr[i].rName [0] <> 0 then begin
            // if (aItemData^.rPrice * aItemData^.rCount >= 100) or (aItemData^.rcolor <> 1) then begin
            FSendClass.SendItemMoveInfo ('@¸£´ü' + ',' + FUserName + ',' + StrPas(@NewItemArr[i].rName) + ',' + IntToStr(NewItemArr[i].rCount)
            + ',' + IntToStr(0) + ',' + IntToStr(0) + ',' + IntToStr(0) + ',,');
            // end;
         end;
      end;
   end;

   FillChar (HaveItemArr, SizeOf (TItemData) * HAVEITEMSIZE, 0);
   for i := 0 to HAVEITEMSIZE - 1 do begin
      if aHaveItemClass.ViewItem (i, @ItemData) = true then begin
         if ItemData.rName [0] <> 0 then begin
            HaveItemArr[i] := ItemData;
         end;
      end;
   end;
end;

procedure THaveItemClass.CopyFromHaveItem (aItemArr : PTItemData);
begin
   Move (HaveItemArr, aItemArr^, SizeOf (HaveItemArr));
end;

procedure THaveItemClass.SaveToSdb (aCharData : PTDBRecord);
var
   i : integer;
   str, rdstr : String;
begin
   for i := 0 to HAVEITEMSIZE-1 do begin
      str := ItemClass.GetWearItemString (HaveItemArr[i]);
      str := GetValidStr3 (str, rdstr, ':');
      StrPCopy (@aCharData^.HaveItemArr[i].Name, rdstr);
      str := GetValidStr3 (str, rdstr, ':');
      aCharData^.HaveItemArr[i].Color := _StrToInt (rdstr);
      str := GetValidStr3 (str, rdstr, ':');
      aCharData^.HaveItemArr[i].Count := _StrToInt (rdstr);
   end;
end;

function  THaveItemClass.FreeSpace: integer;
var i: integer;
begin
   Result := 0;
   for i := 0 to HAVEITEMSIZE-1 do begin
      if HaveItemArr[i].rName[0] = 0 then Result := Result + 1;
   end;
end;

function  THaveItemClass.ViewItem (akey: integer; aItemData: PTItemData): Boolean;
begin
   FillChar (aItemData^, sizeof(TItemData), 0);
   Result := FALSE;

   if boLocked = true then exit;
   
   if (akey < 0) or (akey > HAVEITEMSIZE-1) then exit;
   if HaveItemArr[akey].rName[0] = 0 then exit;
   Move (HaveItemArr[akey], aItemData^, SizeOf (TItemData));
   Result := TRUE;
end;

function  THaveItemClass.FindItem (aItemData : PTItemData): Boolean;
var
   i : integer;
begin
   Result := false;
   for i := 0 to HAVEITEMSIZE-1 do begin
      if StrPas (@HaveItemArr[i].rName) = StrPas (@aItemData^.rName) then begin
         if HaveItemArr[i].rCount >= aItemData^.rCount then begin
            Result := true;
            exit;
         end;
      end;
   end;
end;

function  THaveItemClass.FindKindItem (akind: integer): integer;
var
   i : integer;
begin
   Result := -1;
   for i := 0 to HAVEITEMSIZE-1 do begin
      if HaveItemArr[i].rkind = akind then begin
         Result := i;
         exit;
      end;
   end;
end;

function  THaveItemClass.FindItemByMagicKind (aKind: integer): integer;
var
   i : integer;
begin
   Result := -1;
   for i := 0 to HAVEITEMSIZE - 1 do begin
      if aKind = MAGICTYPE_WRESTLING then begin
         if HaveItemArr[i].rName[0] = 0 then begin
            Result := i;
            exit;
         end;
      end;
      if (HaveItemArr[i].rName[0] <> 0) and
         (HaveItemArr[i].rWearArr = ARR_WEAPON) and
         (HaveItemArr[i].rHitType = aKind) and
         (HaveItemArr[i].rKind = ITEM_KIND_WEARITEM) then begin
         Result := i;
         exit;
      end;
   end;
end;

function  THaveItemClass.AddKeyItem (aKey, aCount : Integer; var aItemData: TItemData): Boolean;
var
   i : Integer;
   nPos : Integer;
begin
   Result := FALSE;

   if boLocked = true then exit;
   if (aKey < 0) or (aKey > HAVEITEMSIZE - 1) then exit;
   if aItemData.rName[0] = 0 then exit;

   nPos := aKey;
   for i := 0 to HAVEITEMSIZE - 1 do begin
      if StrPas (@HaveItemArr[i].rName) = StrPas (@aItemData.rName) then begin
         if HaveItemArr[i].rColor = aItemData.rColor then begin
            if HaveItemArr[i].rboDouble = true then begin
               nPos := i;
               break;
            end;
         end;
      end;
   end;

   if HaveItemArr[nPos].rName[0] <> 0 then begin
      if StrPas (@HaveItemArr[nPos].rName) <> StrPas (@aItemData.rName) then exit;
      if aItemData.rboDouble = false then exit;
      HaveItemArr[nPos].rCount := HaveItemArr[nPos].rCount + aItemData.rCount;
   end else begin
      HaveItemArr[nPos] := aItemData;
   end;

   FSendClass.SendHaveItem (nPos, HaveItemArr[nPos]);
   ReQuestPlaySoundNumber := HaveItemArr[nPos].rSoundEvent.rWavNumber;

   Result := true;
end;

function  THaveItemClass.AddItem  (aItemData: PTItemData): Boolean;
var i : integer;
begin
   Result := FALSE;

   if boLocked = true then exit;
   if aItemData^.rboDouble then begin
      for i := 0 to HAVEITEMSIZE-1 do begin
         if StrPas (@HaveItemArr[i].rName) <> StrPas (@aItemData^.rName) then continue;
         if HaveItemArr[i].rColor <> aItemData^.rcolor then continue;

         HaveItemArr[i].rCount := HaveItemArr[i].rCount + aItemData^.rCount;
         FSendClass.SendHaveItem (i, HaveItemArr[i]);
         ReQuestPlaySoundNumber := HaveItemArr[i].rSoundEvent.rWavNumber;
         Result := TRUE;
         if (aItemData^.rPrice * aItemData^.rCount >= 100) or (aItemData^.rcolor <> 1) then begin
            if aItemData^.rOwnerName[0] <> 0 then begin
               FSendClass.SendItemMoveInfo (StrPas(@aItemData^.rOwnerName) + ',' + FUserName + ',' + StrPas(@aItemData^.rName) + ',' + IntToStr(aItemData^.rCount)
               + ',' + IntToStr(aItemData^.rOwnerServerID) + ',' + IntToStr(aItemData^.rOwnerX) + ',' + IntToStr(aItemData^.rOwnerY) + ',' + StrPas (@aItemData^.rOwnerIP) + ',');
            end;
         end;
         exit;
      end;
   end;

   for i := 0 to HAVEITEMSIZE-1 do begin
      if HaveItemArr[i].rName[0] = 0 then begin
         Move (aItemData^, HaveItemArr[i], SizeOf (TItemData));
         FSendClass.SendHaveItem (i, HaveItemArr[i]);
         ReQuestPlaySoundNumber := HaveItemArr[i].rSoundEvent.rWavNumber;

         Result := TRUE;

         if (aItemData.rPrice * aItemData.rCount >= 100) or (aItemData.rcolor <> 1) then begin
            if aItemData.rOwnerName[0] <> 0 then begin
               FSendClass.SendItemMoveInfo (StrPas(@aItemData.rOwnerName) + ',' + FUserName + ',' + StrPas(@aItemData.rName) + ',' + IntToStr(aItemData.rCount)
               + ',' + IntToStr(aItemData.rOwnerServerID) + ',' + IntToStr(aItemData.rOwnerX) + ',' + IntToStr(aItemData.rOwnerY) + ',' + StrPas (@aItemData.rOwnerIP) + ',');
            end;
         end;
         exit;
      end;
   end;
end;

function  THaveItemClass.DeleteKeyItem (akey, aCount: integer; aItemData : PTItemData): Boolean;
begin
   Result := FALSE;
   if boLocked = true then exit;
   if (akey < 0) or (akey > HAVEITEMSIZE - 1) then exit;

   if (aItemData^.rPrice * aItemData^.rCount >= 100) or (aItemData^.rcolor <> 1) then begin
      if aItemData^.rOwnerName[0] <> 0 then begin
         FSendClass.SendItemMoveInfo (FUserName + ',' + StrPas(@aItemData^.rOwnerName) + ',' + StrPas(@aItemData^.rName) + ',' + IntToStr(aItemData^.rCount)
         + ',' + IntToStr(aItemData^.rOwnerServerID) + ',' + IntToStr(aItemData^.rOwnerX) + ',' + IntToStr(aItemData^.rOwnerY) + ',' + StrPas (@aItemData^.rOwnerIP) + ',');
      end;
   end;
   
   HaveItemArr[akey].rCount := HaveItemArr[akey].rCount - aCount;
   if HaveItemArr [aKey].rCount <= 0 then begin
      FillChar (HaveItemArr [aKey], SizeOf (TItemData), 0);
   end;

   FSendClass.SendHaveItem (aKey, HaveItemArr[akey]);

   Result := TRUE;
end;

procedure THaveItemClass.DeleteAllItem;
var
   i : Integer;
begin
   for i := 0 to HAVEITEMSIZE - 1 do begin
      FillChar (HaveItemArr [i], SizeOf (TItemData), 0);
      FSendClass.SendHaveItem (i, HaveItemArr[i]);
   end;
end;

function  THaveItemClass.DeleteItem (aItemData: PTItemData): Boolean;
var
   i : integer;
begin
   Result := FALSE;

   if boLocked = true then exit;
   for i := 0 to HAVEITEMSIZE-1 do begin
      if StrPas (@HaveItemArr[i].rName) = StrPas (@aItemData^.rName) then begin
         if HaveItemArr[i].rCount < aItemData^.rCount then exit;

         if (aItemData^.rPrice * aItemData^.rCount >= 100) or (aItemData^.rcolor <> 1) then begin
            if aItemData^.rOwnerName[0] <> 0 then begin
               FSendClass.SendItemMoveInfo (FUserName + ',' + StrPas(@aItemData.rOwnerName) + ',' + StrPas(@aItemData^.rName) + ',' + IntToStr(aItemData^.rCount)
               + ',' + IntToStr(aItemData^.rOwnerServerID) + ',' + IntToStr(aItemData.rOwnerX) + ',' + IntToStr(aItemData^.rOwnerY) + ',' + StrPas (@aItemData^.rOwnerIP) + ',');
            end;
         end;

         HaveItemArr[i].rCount := HaveItemArr[i].rCount - aItemData.rCount;
         if HaveItemArr[i].rCount = 0 then FillChar (HaveItemArr[i], sizeof(TItemData), 0);
         FSendClass.SendHaveItem (i, HaveItemArr[i]);
         Result := TRUE;
         exit;
      end;
   end;
end;

function  THaveItemClass.ChangeItem (asour, adest: integer): Boolean;
var
   ItemData : TItemData;
begin
   Result := FALSE;
   if boLocked = true then exit;
   if (asour < 0) or (asour > HAVEITEMSIZE-1) then exit;
   if (adest < 0) or (adest > HAVEITEMSIZE-1) then exit;

   ItemData := HaveItemArr[asour];
   HaveItemArr[asour] := HaveItemArr[adest];
   HaveItemArr[adest] := ItemData;

   FSendClass.SendHaveItem (asour, HaveItemArr[asour]);
   FSendClass.SendHaveItem (adest, HaveItemArr[adest]);
   Result := TRUE;
end;

procedure THaveItemClass.Refresh;
var
   i : Integer;
begin
   for i := 0 to HAVEITEMSIZE-1 do begin
      FSendClass.SendHaveItem (i, HaveItemArr[i]);
   end;
end;


///////////////////////////////////
//         TWearItemClass
///////////////////////////////////

constructor TWearItemClass.Create (aBasicObject : TBasicObject; aSendClass: TSendClass; aAttribClass: TAttribClass);
begin
   boLocked := false;
   FBasicObject := aBasicObject;
   ReQuestPlaySoundNumber := 0;
   FSendClass := aSendClass;
   FAttribClass := aAttribClass;
end;

destructor TWearItemClass.Destroy;
begin
   inherited destroy;
end;

procedure TWearItemClass.SetLifeData;
var
   i: integer;
begin
   FillChar (WearItemLifeData, sizeof(TLifeData), 0);
   for i := ARR_GLOVES to ARR_WEAPON do begin
      GatherLifeData (WearItemLifeData, WearItemArr[i].rLifeData);
   end;
   TUserObject (FBasicObject).SetLifeData;
end;

procedure TWearItemClass.Update (CurTick : integer);
begin
end;

procedure TWearItemClass.LoadFromSdb (aCharData : PTDBRecord);
var
   i : integer;
   str : String;
begin
   boLocked := false;
   ReQuestPlaySoundNumber := 0;
   FillChar (WearItemArr, sizeof(WearItemArr), 0);
   Fillchar (WearFeature, sizeof(WearFeature), 0);

   if StrPas (@aCharData^.Sex) = INI_SEX_FIELD_MAN then WearFeature.rboMan := TRUE
   else WearFeature.rboMan := FALSE;

   WearFeature.rArr[ARR_BODY*2] := 0;
   str := StrPas (@aCharData^.WearItemArr[4].Name) + ':' + IntToStr(aCharData^.WearItemArr[4].Color) + ':' + IntToStr(aCharData^.WearItemArr[4].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_DOWNUNDERWEAR]);
   str := StrPas (@aCharData^.WearItemArr[2].Name) + ':' + IntToStr(aCharData^.WearItemArr[2].Color) + ':' + IntToStr(aCharData^.WearItemArr[2].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_UPUNDERWEAR]);
   str := StrPas (@aCharData^.WearItemArr[6].Name) + ':' + IntToStr(aCharData^.WearItemArr[6].Color) + ':' + IntToStr(aCharData^.WearItemArr[6].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_SHOES]);
   str := StrPas (@aCharData^.WearItemArr[3].Name) + ':' + IntToStr(aCharData^.WearItemArr[3].Color) + ':' + IntToStr(aCharData^.WearItemArr[3].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_UPOVERWEAR]);
   str := StrPas (@aCharData^.WearItemArr[5].Name) + ':' + IntToStr(aCharData^.WearItemArr[5].Color) + ':' + IntToStr(aCharData^.WearItemArr[5].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_GLOVES]);
   str := StrPas (@aCharData^.WearItemArr[0].Name) + ':' + IntToStr(aCharData^.WearItemArr[0].Color) + ':' + IntToStr(aCharData^.WearItemArr[0].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_HAIR]);
   str := StrPas (@aCharData^.WearItemArr[1].Name) + ':' + IntToStr(aCharData^.WearItemArr[1].Color) + ':' + IntToStr(aCharData^.WearItemArr[1].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_CAP]);
   str := StrPas (@aCharData^.WearItemArr[7].Name) + ':' + IntToStr(aCharData^.WearItemArr[7].Color) + ':' + IntToStr(aCharData^.WearItemArr[7].Count);
   ItemClass.GetWearItemData (str, WearItemArr[ARR_WEAPON]);

   WearFeature.rrace := RACE_HUMAN;
   WearFeature.rFeaturestate := wfs_normal;
   WearFeature.rNameColor := WinRGB (25, 25, 25);
   WearFeature.rTeamColor := 0;

   for i := ARR_GLOVES to ARR_WEAPON do begin
      if WearItemArr[i].rName[0] <> 0 then begin
         WearFeature.rArr [i*2] := WearItemArr[i].rWearShape;
         WearFeature.rArr [i*2+1] := WearItemArr[i].rColor;

         if WearItemArr [6].rKind = ITEM_KIND_WEARITEM2 then begin
            if (i = 2) or (i = 4) then continue;
         end;
         FSendClass.SendWearItem (i, WearItemArr[i]);
      end;
   end;
   SetLifeData;
end;

procedure TWearItemClass.SaveToSdb (aCharData : PTDBRecord);
var
   str, rdstr : String;
begin
   str := ItemClass.GetWearItemString (WearItemArr[ARR_DOWNUNDERWEAR]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[4].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[4].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[4].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_UPUNDERWEAR]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[2].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[2].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[2].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_SHOES]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[6].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[6].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[6].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_UPOVERWEAR]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[3].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[3].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[3].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_GLOVES]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[5].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[5].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[5].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_HAIR]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[0].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[0].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[0].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_CAP]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[1].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[1].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[1].Count := _StrToInt (rdstr);

   str := ItemClass.GetWearItemString (WearItemArr[ARR_WEAPON]);
   str := GetValidStr3 (str, rdstr, ':');
   StrPCopy (@aCharData^.WearItemArr[7].Name, rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[7].Color := _StrToInt (rdstr);
   str := GetValidStr3 (str, rdstr, ':');
   aCharData^.WearItemArr[7].Count := _StrToInt (rdstr);
end;

function TWearItemClass.GetFeature : TFeature;
var
   i : integer;
begin
   WearFeature.rrace := RACE_HUMAN;
   for i := ARR_GLOVES to ARR_WEAPON do begin
      WearFeature.rArr [i*2] := WearItemArr[i].rWearShape;
      WearFeature.rArr [i*2+1] := WearItemArr[i].rColor;
      if WearItemArr[6].rKind = ITEM_KIND_WEARITEM2 then begin
         if (i = 2) or (i = 4) then begin
            WearFeature.rArr [i*2] := 0;
            WearFeature.rArr [i*2+1] := 0;
         end;
      end;
   end;

   if WearFeature.rArr [ARR_GLOVES*2] <> 0 then begin
      WearFeature.rArr [5*2] := WearItemArr[ARR_GLOVES].rWearShape;
      WearFeature.rArr [5*2+1] := WearItemArr[ARR_GLOVES].rColor;
   end;

   case WearItemArr[ARR_WEAPON].rHitMotion of
      0 : WearFeature.rhitmotion := AM_HIT;
      1 : WearFeature.rhitmotion := AM_HIT1;
      2 : WearFeature.rhitmotion := AM_HIT2;
      3 : WearFeature.rhitmotion := AM_HIT3;
      4 : WearFeature.rhitmotion := AM_HIT4;
      5 : WearFeature.rhitmotion := AM_HIT5;
      6 : WearFeature.rhitmotion := AM_HIT6;
   end;

   Result := WearFeature;
end;

function  TWearItemClass.GetWeaponType : Integer;
begin
   if WearItemArr[ARR_WEAPON].rName[0] = 0 then begin
      Result := MAGICTYPE_WRESTLING;
      exit;
   end;

   Result := WearItemArr[ARR_WEAPON].rHitType;
end;

function  TWearItemClass.ViewItem (akey: integer; aItemData: PTItemData): Boolean;
begin
   Result := FALSE;
   if boLocked = true then exit;
   if (akey < ARR_BODY) or (akey > ARR_WEAPON) then begin
      FillChar (aItemData^, sizeof(TItemData), 0);
      exit;
   end;
   if WearItemArr[akey].rName[0] = 0 then begin
      FillChar (aItemData^, sizeof(TItemData), 0);
      exit;
   end;
   Move (WearItemArr[akey], aItemData^, SizeOf (TItemData));
   Result := TRUE;
end;

function  TWearItemClass.AddItem  (aItemData: PTItemData): Boolean;
var
   ItemData : TItemData;
begin
   Result := FALSE;
   if boLocked = true then exit;
   if WearItemArr[aItemData^.rWearArr].rName[0] <> 0 then exit;
   if aItemData^.rName[0] = 0 then exit;
   if (aItemData^.rKind <> ITEM_KIND_WEARITEM) and (aItemData^.rKind <> ITEM_KIND_WEARITEM2) then exit;

   case aItemData^.rSex of
      0:;
      1: if not WearFeature.rboMan then exit;
      2: if WearFeature.rboMan then exit;
   end;

   Move (aItemData^, WearItemArr[aItemData^.rWearArr], SizeOf (TItemData));
   WearItemArr[aItemData^.rWearArr].rCount := 1;

   if (aItemData^.rWearArr = 6) and (aItemData^.rKind = ITEM_KIND_WEARITEM2) then begin
      FillChar (ItemData, SizeOf (TItemData), 0);
      FSendClass.SendWearItem (2, ItemData);
      FSendClass.SendWearItem (4, ItemData);
      FSendClass.SendWearItem (aItemData^.rWearArr, aItemData^);
   end else if (aItemData^.rWearArr = 2) or (aItemData^.rWearArr = 4) then begin
      if WearItemArr [6].rKind <> ITEM_KIND_WEARITEM2 then begin
         FSendClass.SendWearItem (aItemData^.rWearArr, aItemData^);
      end;
   end else begin
      FSendClass.SendWearItem (aItemData^.rWearArr, aItemData^);
   end;
   ReQuestPlaySoundNumber := aItemData^.rSoundEvent.rWavNumber;

   SetLifeData;
   Result := TRUE;
end;

function  TWearItemClass.ChangeItem  (var aItemData: TItemData; var aOldItemData : TItemData): Boolean;
var
   ItemData : TItemData;
begin
   Result := FALSE;

   if boLocked = true then exit;
   if aItemData.rName[0] = 0 then exit;
   if (aItemData.rKind <> ITEM_KIND_WEARITEM) and (aItemData.rKind <> ITEM_KIND_WEARITEM2) then exit;

   case aItemData.rSex of
      0:;
      1: if not WearFeature.rboMan then exit;
      2: if WearFeature.rboMan then exit;
   end;

   if WearItemArr[aItemData.rWearArr].rName[0] = 0 then begin
      FillChar (aOldItemData, SizeOf (TItemData), 0);
   end else begin
      Move (WearItemArr[aItemData.rWearArr], aOldItemData, SizeOf (TItemData));
      FillChar (WearItemArr[aItemDAta.rWearArr], SizeOf (TItemData), 0);
      aOldItemData.rCount := 1;
   end;

   Move (aItemData, WearItemArr[aItemData.rWearArr], SizeOf (TItemData));
   WearItemArr[aItemData.rWearArr].rCount := 1;

   if (aItemData.rWearArr = 6) and (aItemData.rKind = ITEM_KIND_WEARITEM2) then begin
      FillChar (ItemData, SizeOf (TItemData), 0);
      FSendClass.SendWearItem (2, ItemData);
      FSendClass.SendWearItem (4, ItemData);
      FSendClass.SendWearItem (aItemData.rWearArr, aItemData);
   end else if (aItemData.rWearArr = 2) or (aItemData.rWearArr = 4) then begin
      if WearItemArr [6].rKind <> ITEM_KIND_WEARITEM2 then begin
         FSendClass.SendWearItem (aItemData.rWearArr, aItemData);
      end;
   end else begin
      FSendClass.SendWearItem (aItemData.rWearArr, aItemData);
   end;
   ReQuestPlaySoundNumber := aItemData.rSoundEvent.rWavNumber;

   SetLifeData;

   Result := TRUE;
end;

procedure TWearItemClass.DeleteKeyItem (akey: integer);
begin
   if boLocked = true then exit;
   if (akey < ARR_BODY) or (akey > ARR_WEAPON) then exit;

   if (aKey = 6) and (WearItemArr[aKey].rKind = ITEM_KIND_WEARITEM2) then begin
      FSendClass.SendWearItem (2, WearItemArr[2]);
      FSendClass.SendWearItem (4, WearItemArr[4]);
   end;
   FillChar (WearItemArr[akey], sizeof(TItemData), 0);
   FSendClass.SendWearItem (akey, WearItemArr[akey]);
   SetLifeData;
end;

procedure TWearItemClass.SetFeatureState (aFeatureState: TFeatureState);
begin
   WearFeature.rfeaturestate := aFeatureState;
end;

procedure TWearItemClass.SetHiddenState (aHiddenState : THiddenState);
begin
   FBasicObject.BasicData.Feature.rHideState := aHiddenState;
   WearFeature.rHideState := aHiddenState;
end;

procedure TWearItemClass.SetActionState (aActionState : TActionState);
begin
   FBasicObject.BasicData.Feature.rActionState := aActionState;
   WearFeature.rActionState := aActionState;
end;

function TWearItemClass.GetHiddenState : THiddenState;
begin
   Result := WearFeature.rHideState;
end;

function TWearItemClass.GetActionState : TActionState;
begin
   Result := WearFeature.rActionState;
end;

///////////////////////////////////
//         THaveMagicClass
///////////////////////////////////

constructor THaveMagicClass.Create (aBasicObject : TBasicObject; aSendClass: TSendClass; aAttribClass: TAttribClass);
begin
   FBasicObject := aBasicObject;
   boAddExp := true;
   ReQuestPlaySoundNumber := 0;
   FSendClass := aSendClass;
   FAttribClass := aAttribclass;
end;

destructor THaveMagicClass.Destroy;
begin
   inherited destroy;
end;

procedure THaveMagicClass.SetLifeData;
   procedure AddLifeData (p: PTMagicData);
   begin
      if p = nil then exit;
      HaveMagicLifeData.DamageBody      := HaveMagicLifeData.DamageBody      + p^.rLifeData.damageBody + p^.rLifeData.damageBody * p^.rcSkillLevel div INI_SKILL_DIV_DAMAGE;
      HaveMagicLifeData.DamageHead      := HaveMagicLifeData.DamageHead      + p^.rLifeData.damageHead + p^.rLifeData.damageHead * p^.rcSkillLevel div INI_SKILL_DIV_DAMAGE;
      HaveMagicLifeData.DamageArm       := HaveMagicLifeData.DamageArm       + p^.rLifeData.damageArm  + p^.rLifeData.damageArm  * p^.rcSkillLevel div INI_SKILL_DIV_DAMAGE;
      HaveMagicLifeData.DamageLeg       := HaveMagicLifeData.DamageLeg       + p^.rLifeData.damageLeg  + p^.rLifeData.damageLeg  * p^.rcSkillLevel div INI_SKILL_DIV_DAMAGE;
      HaveMagicLifeData.AttackSpeed     := HaveMagicLifeData.AttackSpeed     + p^.rLifeData.AttackSpeed - p^.rLifeData.AttackSpeed * p^.rcSkillLevel div INI_SKILL_DIV_ATTACKSPEED;
      HaveMagicLifeData.avoid           := HaveMagicLifeData.avoid           + p^.rLifeData.avoid;
      HaveMagicLifeData.recovery        := HaveMagicLifeData.recovery        + p^.rLifeData.recovery;
      HaveMagicLifeData.armorBody       := HaveMagicLifeData.armorBody       + p^.rLifeData.armorBody + p^.rLifeData.armorBody * p^.rcSkillLevel div INI_SKILL_DIV_ARMOR;
      HaveMagicLifeData.armorHead       := HaveMagicLifeData.armorHead       + p^.rLifeData.armorHead + p^.rLifeData.armorHead * p^.rcSkillLevel div INI_SKILL_DIV_ARMOR;
      HaveMagicLifeData.armorArm        := HaveMagicLifeData.armorArm        + p^.rLifeData.armorArm  + p^.rLifeData.armorArm  * p^.rcSkillLevel div INI_SKILL_DIV_ARMOR;
      HaveMagicLifeData.armorLeg        := HaveMagicLifeData.armorLeg        + p^.rLifeData.armorLeg  + p^.rLifeData.armorLeg  * p^.rcSkillLevel div INI_SKILL_DIV_ARMOR;
   end;
var
   str : string;
begin
   FillChar (HaveMagicLifeData, sizeof(TLifeData), 0);

   AddLifeData (pCurAttackMagic);
   if pCurAttackMagic <> nil then begin
      HaveMagicLifeData.damageBody := HaveMagicLifeData.damageBody + HaveMagicLifeData.DamageBody * MagicClass.GetSkillDamageBody (pCurAttackMagic^.rcSkillLevel) div 100;
      HaveMagicLifeData.damageHead := HaveMagicLifeData.damageHead;
      HaveMagicLifeData.damageArm  := HaveMagicLifeData.damageArm;
      HaveMagicLifeData.damageLeg  := HaveMagicLifeData.damageLeg;
   end;

   AddLifeData (pCurBreathngMagic);
   AddLifeData (pCurRunningMagic);
   AddLifeData (pCurProtectingMagic);
   if pCurProtectingMagic <> nil then begin
      HaveMagicLifeData.ArmorBody := HaveMagicLifeData.ArmorBody + HaveMagicLifeData.ArmorBody * MagicClass.GetSkillArmorBody (pCurProtectingMagic^.rcSkillLevel) div 100;
   end;

   AddLifeData (pCurEctMagic);

//   if pCurAttackMagic <> nil then                               // ¿Ü°øÀÌ ±Ç¹ýÆÄ±«¿¡ ¿µÇâ
//   if pCurattackMagic.rMagicType = MAGICTYPE_WRESTLING then
//      HaveMagicLifeData.damage := HaveMagicLifeData.Damage + FAttribClass.CurOutPower div 100;

   str := '';
   if pCurAttackMagic <> nil then str := str + StrPas (@pCurAttackMagic^.rName) + ',';
   if pCurBreathngMagic <> nil then str := str + StrPas (@pCurBreathngMagic^.rName) + ',';
   if pCurRunningMagic <> nil then str := str + StrPas (@pCurRunningMagic^.rName) + ',';
   if pCurProtectingMagic <> nil then str := str + StrPas (@pCurProtectingMagic^.rName) + ',';
   if pCurEctMagic <> nil then str := str + StrPas (@pCurEctMagic^.rName) + ',';
   FSendClass.SendUsedMagicString (str);

   TUserObject (FBasicObject).SetLifeData;
end;

procedure THaveMagicClass.LoadFromSdb (aCharData : PTDBRecord);
var
   i: integer;
   str : String;
begin
   ReQuestPlaySoundNumber := 0;
   
   MagicClass.GetMagicData (INI_DEF_WRESTLING, DefaultMagic[default_wrestling], aCharData^.BasicMagicArr[0].Skill);
   MagicClass.GetMagicData (INI_DEF_FENCING, DefaultMagic[default_fencing], aCharData^.BasicMagicArr[1].Skill);
   MagicClass.GetMagicData (INI_DEF_SWORDSHIP, DefaultMagic[default_swordship], aCharData^.BasicMagicArr[2].Skill);
   MagicClass.GetMagicData (INI_DEF_HAMMERING, DefaultMagic[default_hammering], aCharData^.BasicMagicArr[3].Skill);
   MagicClass.GetMagicData (INI_DEF_SPEARING, DefaultMagic[default_spearing], aCharData^.BasicMagicArr[4].Skill);
   MagicClass.GetMagicData (INI_DEF_BOWING, DefaultMagic[default_bowing], aCharData^.BasicMagicArr[5].Skill);
   MagicClass.GetMagicData (INI_DEF_THROWING, DefaultMagic[default_throwing], aCharData^.BasicMagicArr[6].Skill);
   MagicClass.GetMagicData (INI_DEF_RUNNING, DefaultMagic[default_running], aCharData^.BasicMagicArr[8].Skill);
   MagicClass.GetMagicData (INI_DEF_BREATHNG, DefaultMagic[default_breathng], aCharData^.BasicMagicArr[7].Skill);
   MagicClass.GetMagicData (INI_DEF_PROTECTING, DefaultMagic[default_Protecting], aCharData^.BasicMagicArr[9].Skill);

   for i := 0 to 10 -1 do begin
      MagicClass.Calculate_cLifeData (@DefaultMagic[i]);
      FSendClass.SendBasicMagic (i, DefaultMagic[i]);
   end;

   for i := 0 to HAVEMAGICSIZE-1 do begin
      str := StrPas (@aCharData^.HaveMagicArr[i].Name) + ':' + IntToStr (aCharData^.HaveMagicArr[i].Skill);
      MagicClass.GetHaveMagicData (str, HaveMagicArr[i]);
      MagicClass.Calculate_cLifeData (@HaveMagicArr[i]);
      FSendClass.SendHaveMagic (i, HaveMagicArr[i]);
   end;

   WalkingCount := 0;
   FpCurAttackMagic     := nil;
   FpCurBreathngMagic   := nil;
   FpCurRunningMagic    := nil;
   FpCurProtectingMagic := nil;
   FpCurEctMagic        := nil;

   SetLifeData;
end;

procedure THaveMagicClass.SaveToSdb (aCharData : PTDBRecord);
var
   i : integer;
   str, rdstr : String;
begin
   {
   UserData.SetFieldValueInteger (aName, 'Wrestling', DefaultMagic[FindBasicMagic(default_wrestling)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Fencing', DefaultMagic[FindBasicMagic(default_fencing)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Swordship', DefaultMagic[FindBasicMagic(default_swordship)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Hammering', DefaultMagic[FindBasicMagic(default_hammering)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Spearing', DefaultMagic[FindBasicMagic(default_spearing)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Bowing', DefaultMagic[FindBasicMagic(default_bowing)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Throwing', DefaultMagic[FindBasicMagic(default_throwing)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Breathng', DefaultMagic[FindBasicMagic(default_breathng)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Running', DefaultMagic[FindBasicMagic(default_running)].rSkillExp);
   UserData.SetFieldValueInteger (aName, 'Protecting', DefaultMagic[FindBasicMagic(default_Protecting)].rSkillExp);
   }
   aCharData^.BasicMagicArr[0].Skill := DefaultMagic[default_wrestling].rSkillExp;
   aCharData^.BasicMagicArr[1].Skill := DefaultMagic[default_fencing].rSkillExp;
   aCharData^.BasicMagicArr[2].Skill := DefaultMagic[default_swordship].rSkillExp;
   aCharData^.BasicMagicArr[3].Skill := DefaultMagic[default_hammering].rSkillExp;
   aCharData^.BasicMagicArr[4].Skill := DefaultMagic[default_spearing].rSkillExp;
   aCharData^.BasicMagicArr[5].Skill := DefaultMagic[default_bowing].rSkillExp;
   aCharData^.BasicMagicArr[6].Skill := DefaultMagic[default_throwing].rSkillExp;
   aCharData^.BasicMagicArr[8].Skill := DefaultMagic[default_running].rSkillExp;
   aCharData^.BasicMagicArr[7].Skill := DefaultMagic[default_breathng].rSkillExp;
   aCharData^.BasicMagicArr[9].Skill := DefaultMagic[default_Protecting].rSkillExp;

   for i := 0 to HAVEMAGICSIZE-1 do begin
      str := MagicClass.GetHaveMagicString (HaveMagicArr[i]);
      str := GetValidStr3 (str, rdstr, ':');
      StrPCopy (@aCharData^.HaveMagicArr[i].Name, rdstr);
      str := GetValidStr3 (str, rdstr, ':');
      aCharData^.HaveMagicArr[i].Skill := _StrToInt (rdstr);
   end;
end;

procedure THaveMagicClass.FindAndSendMagic (pMagicData: PTMagicData);
var
   i : integer;
begin
   for i := 0 to 10 -1 do begin
      if pMagicData = @DefaultMagic[i] then begin
         FSendClass.SendBasicMagic (i, DefaultMagic[i]);
         exit;
      end;
   end;

   for i := 0 to HAVEMAGICSIZE-1 do begin
      if pMagicData = @HaveMagicArr[i] then begin
         FSendClass.SendHaveMagic (i, HaveMagicArr[i]);
         exit;
      end;
   end;
end;

function  THaveMagicClass.ViewMagic (akey: integer; aMagicData: PTMagicData): Boolean;
begin
   Result := FALSE;
   if (akey < 0) or (akey > HAVEMAGICSIZE-1) then exit;
   if HaveMagicArr[akey].rName[0] = 0 then exit;
   Move (HaveMagicArr[akey], aMagicData^, SizeOf (TMagicData));
   Result := TRUE;
end;

function  THaveMagicClass.ViewBasicMagic (akey: integer; aMagicData: PTMagicData): Boolean;
begin
   Result := FALSE;
   if (akey < 0) or (akey > 10-1) then exit;
   if DefaultMagic[akey].rName[0] = 0 then exit;
   Move (DefaultMagic[akey], aMagicData^, SizeOf (TMagicData));
   Result := TRUE;
end;

function  THaveMagicClass.AddMagic  (aMagicData: PTMagicData): Boolean;
var
   i: integer;
   boFlag : boolean;
   //min, mini : integer;
begin
   Result := FALSE;
   if StrPas (@aMagicData^.rName) = '·çÁéÐý' then begin
      // ¾î¶² °ø°Ý¹«°øÀÌ 99.99°¡ ¾øÀ»°æ¿ì FALSE ¸®ÅÏ
      boFlag := false;
      for i := 0 to 10 - 1 do begin
         Case DefaultMagic[i].rMagictype of
            MAGICTYPE_WRESTLING  ,
            MAGICTYPE_FENCING    ,
            MAGICTYPE_SWORDSHIP  ,
            MAGICTYPE_HAMMERING  ,
            MAGICTYPE_SPEARING   :
               begin
                  if DefaultMagic[i].rcSkillLevel >= 9999 then begin
                     boFlag := true;
                     break;
                  end;
               end;
         end;
      end;
      if boFlag = false then begin
         for i := 0 to HAVEMAGICSIZE - 1 do begin
            Case HaveMagicArr[i].rMagictype of
               MAGICTYPE_WRESTLING  ,
               MAGICTYPE_FENCING    ,
               MAGICTYPE_SWORDSHIP  ,
               MAGICTYPE_HAMMERING  ,
               MAGICTYPE_SPEARING   :
                  begin
                     if HaveMagicArr[i].rcSkillLevel >= 9999 then begin
                        boFlag := true;
                        break;
                     end;
                  end;
            end;
         end;
      end;
      if boFlag = false then exit;
   end;

   if StrPas (@aMagicData^.rName) = 'Áé¶¯°Ë·½' then begin
      // ¿À¼±¹æÀÌ 99.99°¡ ¾Æ´Ò°æ¿ì FALSE ¸®ÅÏ..
      boFlag := false;
      for i := 0 to HAVEMAGICSIZE - 1 do begin
         if StrPas(@HaveMagicArr[i].rName) = '·çÁéÐý' then begin
            if HaveMagicArr[i].rcSkillLevel >= 9999 then begin
               boFlag := true;
               break;
            end;
         end;
      end;
      if boFlag = false then exit;
   end;

   if aMagicData^.rGuildMagictype <> 0 then begin
      for i := 0 to HAVEMAGICSIZE-1 do
         if HaveMagicArr[i].rGuildMagictype <> 0 then exit;
   end;

   for i := 0 to HAVEMAGICSIZE-1 do
      if StrComp (@HaveMagicArr[i].rName, @aMagicData^.rName) = 0 then exit;

   for i := 0 to HAVEMAGICSIZE-1 do begin
      if HaveMagicArr[i].rName[0] = 0 then begin
         Move (aMagicData^, HaveMagicArr[i], SizeOf (TMagicData));
         FSendClass.SendHaveMagic (i, HaveMagicArr[i]);
         Result := TRUE;
         exit;
      end;
   end;
{
   min := 2000000000;
   mini := -1;

   for i := 0 to HAVEMAGICSIZE-1 do begin
      if HaveMagicArr[i].rSkillExp <= min then begin
         min := HaveMagicArr[i].rSkillExp;
         mini := i;
      end;
   end;

   if (mini >= 0) and (mini <= HAVEMAGICSIZE-1) then begin
      if FpCurAttackMagic     = @HaveMagicArr[mini] then exit;
      if FpCurBreathngMagic   = @HaveMagicArr[mini] then exit;
      if FpCurRunningMagic    = @HaveMagicArr[mini] then exit;
      if FpCurProtectingMagic = @HaveMagicArr[mini] then exit;
      if FpCurEctMagic        = @HaveMagicArr[mini] then exit;

      HaveMagicArr[mini] := MagicData;
      FSendClass.SendHaveMagic (mini, HaveMagicArr[mini]);
      Result := TRUE;
      exit;
   end;
}
end;

function  THaveMagicClass.DeleteMagic (akey: integer): Boolean;
begin
   Result := FALSE;
   if (akey < 0) or (akey > HAVEMAGICSIZE-1) then exit;
   if FpCurAttackMagic     = @HaveMagicArr[akey] then exit;
   if FpCurBreathngMagic   = @HaveMagicArr[akey] then exit;
   if FpCurRunningMagic    = @HaveMagicArr[akey] then exit;
   if FpCurProtectingMagic = @HaveMagicArr[akey] then exit;
   if FpCurEctMagic        = @HaveMagicArr[akey] then exit;
   FillChar (HaveMagicArr[akey], sizeof(TMagicData), 0);
   FSendClass.SendHaveMagic (akey, HaveMagicArr[akey]);
   Result := TRUE;
end;

function  THaveMagicClass.GetMagicIndex(aMagicName: string): integer;
var i: integer;
begin
   Result := -1;
   for i := 0 to HAVEMAGICSIZE-1 do begin
      if StrPas(@HaveMagicArr[i].rName) = aMagicName then begin
         Result := i;
         exit;
      end;
   end;
end;

function  THaveMagicClass.GetUsedMagicList: string;
begin
   Result := '';

   if FpCurAttackMagic     <> nil then Result := Result + ' ' + StrPas (@FpCurAttackMagic^.rName);
   if FpCurBreathngMagic   <> nil then Result := Result + ' ' + StrPas (@FpCurBreathngMagic^.rName);
   if FpCurRunningMagic    <> nil then Result := Result + ' ' + StrPas (@FpCurRunningMagic^.rName);
   if FpCurProtectingMagic <> nil then Result := Result + ' ' + StrPas (@FpCurProtectingMagic^.rName);
   if FpCurEctMagic        <> nil then Result := Result + ' ' + StrPas (@FpCurEctMagic^.rName);
end;

function  THaveMagicClass.DecEventMagic (apmagic: PTMagicData): Boolean;
begin
   Result := FALSE;
   if FAttribClass.CurLife < apmagic^.rEventDecLife then exit;
   if FAttribClass.CurMagic < apmagic^.rEventDecMagic then exit;
   if FAttribClass.CurInPower < apmagic^.rEventDecInPower then exit;
   if FAttribClass.CurOutPower < apmagic^.rEventDecOutPower then exit;

   FAttribClass.CurLife := FAttribClass.CurLife - apmagic^.rEventDecLife;
   FAttribClass.CurMagic := FAttribClass.CurMagic - apmagic^.rEventDecMagic;
   FAttribClass.CurInPower := FAttribClass.CurInPower - apmagic^.rEventDecInPower;
   FAttribClass.CurOutPower := FAttribClass.CurOutPower - apmagic^.rEventDecOutPower;
   Result := TRUE;
end;

function  THaveMagicClass.ChangeMagic (asour, adest: integer): Boolean;
var
   MagicData : TMagicData;
begin
   Result := FALSE;
   if (asour < 0) or (asour > HAVEMAGICSIZE-1) then exit;
   if (adest < 0) or (adest > HAVEMAGICSIZE-1) then exit;

   if FpCurAttackMagic     = @HaveMagicArr[asour] then exit;
   if FpCurBreathngMagic   = @HaveMagicArr[asour] then exit;
   if FpCurRunningMagic    = @HaveMagicArr[asour] then exit;
   if FpCurProtectingMagic = @HaveMagicArr[asour] then exit;
   if FpCurEctMagic        = @HaveMagicArr[asour] then exit;

   if FpCurAttackMagic     = @HaveMagicArr[adest] then exit;
   if FpCurBreathngMagic   = @HaveMagicArr[adest] then exit;
   if FpCurRunningMagic    = @HaveMagicArr[adest] then exit;
   if FpCurProtectingMagic = @HaveMagicArr[adest] then exit;
   if FpCurEctMagic        = @HaveMagicArr[adest] then exit;


   MagicData := HaveMagicArr[asour];
   HaveMagicArr[asour] := HaveMagicArr[adest];
   HaveMagicArr[adest] := MagicData;

   FSendClass.SendHaveMagic (asour, HaveMagicArr[asour]);
   FSendClass.SendHaveMagic (adest, HaveMagicArr[adest]);
   Result := TRUE;
end;

function  THaveMagicClass.ChangeBasicMagic (asour, adest: integer): Boolean;
var
   MagicData : TMagicData;
begin
   Result := FALSE;
   if (asour < 0) or (asour > 10-1) then exit;
   if (adest < 0) or (adest > 10-1) then exit;

   if FpCurAttackMagic     = @DefaultMagic[asour] then exit;
   if FpCurBreathngMagic   = @DefaultMagic[asour] then exit;
   if FpCurRunningMagic    = @DefaultMagic[asour] then exit;
   if FpCurProtectingMagic = @DefaultMagic[asour] then exit;

   if FpCurAttackMagic     = @DefaultMagic[adest] then exit;
   if FpCurBreathngMagic   = @DefaultMagic[adest] then exit;
   if FpCurRunningMagic    = @DefaultMagic[adest] then exit;
   if FpCurProtectingMagic = @DefaultMagic[adest] then exit;


   MagicData := DefaultMagic[asour];
   DefaultMagic[asour] := DefaultMagic[adest];
   DefaultMagic[adest] := MagicData;

   FSendClass.SendBasicMagic (asour, DefaultMagic[asour]);
   FSendClass.SendBasicMagic (adest, DefaultMagic[adest]);
   Result := TRUE;
end;

procedure THaveMagicClass.SetBreathngMagic (aMagic: PTMagicData);
begin
   if FpCurBreathngMagic <> nil then begin
      FSendClass.SendChatMessage (StrPas (@FpCurBreathngMagic^.rName) + ' '+'ÖÕÖ¹', SAY_COLOR_SYSTEM);
      FpCurBreathngMagic := nil;
   end else begin
      FpCurBreathngMagic := aMagic;
      if aMagic <> nil then begin
         FSendClass.SendChatMessage (StrPas (@FpCurBreathngMagic^.rName) + ' '+'¿ªÊ¼', SAY_COLOR_SYSTEM);
         FpCurBreathngMagic.rMagicProcessTick := mmAnsTick;
      end;
   end;
   SetLifeData;
end;

procedure THaveMagicClass.SetRunningMagic (aMagic: PTMagicData);
begin
   if FpCurRunningMagic <> nil then begin
      FSendClass.SendChatMessage (StrPas (@FpCurRunningMagic^.rName) + ' '+'ÖÕÖ¹', SAY_COLOR_SYSTEM);
      FpCurRunningMagic := nil;
   end else begin
      FpCurRunningMagic := aMagic;
      if aMagic <> nil then begin
         FSendClass.SendChatMessage (StrPas (@FpCurRunningMagic^.rName) + ' '+'¿ªÊ¼', SAY_COLOR_SYSTEM);
      end;
   end;
   SetLifeData;
end;

procedure THaveMagicClass.SetProtectingMagic (aMagic: PTMagicData);
begin
   if FpCurProtectingMagic <> nil then begin
      FSendClass.SendChatMessage (StrPas (@FpCurProtectingMagic^.rName) + ' '+'ÖÕÖ¹', SAY_COLOR_SYSTEM);
      ReQuestPlaySoundNumber := FpCurProtectingMagic.rSoundEnd.rWavNumber;

      if aMagic = FpCurProtectingMagic then begin
         FpCurProtectingMagic := nil;
         SetLifeData;
         exit;
      end;
      FpCurProtectingMagic := nil;
   end;

   FpCurProtectingMagic := aMagic;
   if aMagic <> nil then begin
      FSendClass.SendChatMessage (StrPas (@FpCurProtectingMagic^.rName) + ' '+'¿ªÊ¼', SAY_COLOR_SYSTEM);
      ReQuestPlaySoundNumber := FpCurProtectingMagic.rSoundStart.rWavNumber;
   end;

   SetLifeData;
end;

procedure THaveMagicClass.SetEctMagic (aMagic: PTMagicData);
begin
   if FpCurEctMagic <> nil then begin
      FSendClass.SendChatMessage (StrPas (@FpCurEctMagic^.rName) + ' '+'ÖÕÖ¹', SAY_COLOR_SYSTEM);
      FpCurEctMagic := nil;
   end else begin
      FpCurEctMagic := aMagic;
      if aMagic <> nil then begin
         FSendClass.SendChatMessage (StrPas (@FpCurEctMagic^.rName) + ' '+'¿ªÊ¼', SAY_COLOR_SYSTEM);
      end;
   end;
   SetLifeData;
end;

{
function  THaveMagicClass.SetHaveMagicPercent (akey: integer; aper: integer): Boolean;
begin
   Result := FALSE;
   if (akey < 0) or (akey > HAVEMAGICSIZE-1) then exit;
   if (aper < 1) or (akey > 10) then exit;

   // HaveMagicArr[akey].rPercent := aper;
   FSendClass.SendHaveMagic (akey, HaveMagicArr[akey]);
   Result := TRUE;
end;
}

{
function  THaveMagicClass.SetDefaultMagicPercent (akey: integer; aper: integer): Boolean;
begin
   Result := FALSE;
   if (akey < 0) or (akey > 10-1) then exit;
   if (aper < 1) or (akey > 10) then exit;

   DefaultMagic[akey].rPercent := aper;

   FSendClass.SendBasicMagic (akey, DefaultMagic[akey]);
   Result := TRUE;
end;
}

function THaveMagicClass.SetHaveItemMagicType (atype: integer): integer;
begin
   HaveItemType := atype;
   Result := 0;
end;

{
function THaveMagicClass.FindBasicMagic (akey : Integer) : Integer;
var
   i : Integer;
begin
   Result := -1;

   if akey < 0 then exit;
   if akey > 10-1 then exit;

   for i := 0 to 10 - 1 do begin
      if aKey = DefaultMagic[i].rMagicType then begin
         Result := i;
         exit;
      end;
   end;
end;
}

function  THaveMagicClass.PreSelectBasicMagic (akey, aper: integer; var RetStr : String): Boolean;
begin
   Result := false;

   if akey < 0 then exit;
   if akey > 10 - 1 then exit;
   if DefaultMagic[akey].rName[0] = 0 then exit;

   Case DefaultMagic[akey].rMagicType of
      MAGICTYPE_WRESTLING  ,
      MAGICTYPE_FENCING    ,
      MAGICTYPE_SWORDSHIP  ,
      MAGICTYPE_HAMMERING  ,
      MAGICTYPE_SPEARING   ,
      MAGICTYPE_BOWING     ,
      MAGICTYPE_THROWING   :
         begin
            // if HaveItemType <> DefaultMagic[akey].rMagicType then begin exit; end;
            RetStr := 'ÒòÍ·²¿»îÁ¦²»×ã,ËùÑ¡ÔñÎä¹¦Ê§°Ü.';
            case aper of
               0..10: exit;
               else RetStr := '';
            end;
         end;
      MAGICTYPE_ECT :
         begin
            if FpCurAttackMagic <> nil then begin
               if FpCurAttackMagic^.rcSkillLevel < 9999 then begin
                  RetStr := '¸¨ÖúÎä¹¦ÒªÔÚÊ¹ÓÃ¹¥»÷ÐÔÎä¹¦µÄ×´Ì¬ÏÂ²ÅÄÜÊ¹ÓÃ.';
                  exit;
               end;
            end;
         end;
   end;

   Result := true;
end;

function  THaveMagicClass.SelectBasicMagic (akey, aper: integer; var RetStr: string): integer;
begin
   Result := SELECTMAGIC_RESULT_NONE;

   case DefaultMagic[akey].rMagicType of
      MAGICTYPE_WRESTLING  : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_FENCING    : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_SWORDSHIP  : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_HAMMERING  : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_SPEARING   : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_BOWING     : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if FpCurEctMagic <> nil then SetEctMagic (nil);
      end;
      MAGICTYPE_THROWING   : begin
         FpCurAttackMagic := @DefaultMagic[akey];
         if FpCurEctMagic <> nil then SetEctMagic (nil);
      end;

      MAGICTYPE_RUNNING    :
         begin
            SetRunningMagic ( @DefaultMagic[akey]);
            if FpCurRunningMagic <> nil then Result := SELECTMAGIC_RESULT_RUNNING
            else Result := SELECTMAGIC_RESULT_NORMAL;
         end;
      MAGICTYPE_BREATHNG   :
         begin
            SetBreathngMagic ( @DefaultMagic[akey]);
            if FpCurBreathngMagic <> nil then Result := SELECTMAGIC_RESULT_SITDOWN
            else Result := SELECTMAGIC_RESULT_NORMAL;

            if FpCurBreathngMagic <> nil then SetProtectingMagic (nil);
         end;
      MAGICTYPE_PROTECTING :
         begin
            SetProtectingMagic ( @DefaultMagic[akey]);

            if FpCurProtectingMagic <> nil then SetBreathngMagic (nil);
         end;
   end;
   SetLifeData;
end;

function  THaveMagicClass.PreSelectHaveMagic (akey, aper: integer; var RetStr: String): Boolean;
begin
   Result := false;
   RetStr := '';
   if akey < 0 then exit;
   if akey > HAVEMAGICSIZE-1 then exit;
   if HaveMagicArr[akey].rName[0] = 0 then exit;

   case HaveMagicArr[akey].rMagicType of
      MAGICTYPE_WRESTLING  ,
      MAGICTYPE_FENCING    ,
      MAGICTYPE_SWORDSHIP  ,
      MAGICTYPE_HAMMERING  ,
      MAGICTYPE_SPEARING   ,
      MAGICTYPE_BOWING     ,
      MAGICTYPE_THROWING   :
         begin
            // if HaveItemType <> HaveMagicArr[akey].rMagicType then begin exit; end;
            RetStr := 'ÒòÍ·²¿»îÁ¦²»×ã,ËùÑ¡ÔñÎä¹¦Ê§°Ü.';
            case aper of
               0..10: exit;
               else RetStr := '';
            end;
         end;
      MAGICTYPE_ECT :
         begin
            if FpCurAttackMagic <> nil then begin
               if FpCurAttackMagic^.rcSkillLevel < 9999 then begin
                  RetStr := '¸¨ÖúÎä¹¦ÒªÔÚÊ¹ÓÃ¹¥»÷ÐÔÎä¹¦µÄ×´Ì¬ÏÂ²ÅÄÜÊ¹ÓÃ.';
                  exit;
               end;
            end;
         end;
   end;

   Result := true;
end;

function  THaveMagicClass.SelectHaveMagic (akey, aper: integer; var RetStr: string): integer;
begin
   RetStr := '';
   Result := SELECTMAGIC_RESULT_FALSE;
   if akey < 0 then exit;
   if akey > HAVEMAGICSIZE-1 then exit;
   if HaveMagicArr[akey].rName[0] = 0 then exit;

   case HaveMagicArr[akey].rMagicType of
      MAGICTYPE_WRESTLING  ,
      MAGICTYPE_FENCING    ,
      MAGICTYPE_SWORDSHIP  ,
      MAGICTYPE_HAMMERING  ,
      MAGICTYPE_SPEARING   ,
      MAGICTYPE_BOWING     ,
      MAGICTYPE_THROWING   :
         begin
            if HaveItemType <> HaveMagicArr[akey].rMagicType then begin exit; end;
            RetStr := '';
            // ÃµÇÏ¼­¹ö Á¦¿Ü
            RetStr := 'ÒòÍ·²¿»îÁ¦²»×ã,ËùÑ¡ÔñÎä¹¦Ê§°Ü.';
            case aper of
               0..10: exit;
               // 11..20: if Random (8) <> 4 then exit;
               // 21..30: if Random (6) <> 3 then exit;
               // 31..40: if Random (4) <> 2 then exit;
               // 41..50: if Random (2) <> 1 then exit;
               else RetStr := '';
            end;
         end;
      MAGICTYPE_ECT :
         begin
            if FpCurAttackMagic <> nil then begin
               if FpCurAttackMagic^.rcSkillLevel < 9999 then begin
                  RetStr := '¸¨ÖúÎä¹¦ÒªÔÚÊ¹ÓÃ¹¥»÷ÐÔÎä¹¦µÄ×´Ì¬ÏÂ²ÅÄÜÊ¹ÓÃ.';
                  exit;
               end;
            end;
         end;
   end;

   Result := SELECTMAGIC_RESULT_NONE;
   case HaveMagicArr[akey].rMagicType of
      MAGICTYPE_WRESTLING  : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_FENCING    : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_SWORDSHIP  : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_HAMMERING  : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_SPEARING   : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if (FpCurEctMagic <> nil) and (FpCurAttackMagic^.rcSkillLevel < 9999) then SetEctMagic (nil);
      end;
      MAGICTYPE_BOWING     : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if FpCurEctMagic <> nil then SetEctMagic (nil);
      end;
      MAGICTYPE_THROWING   : begin
         FpCurAttackMagic := @HaveMagicArr[akey];
         if FpCurEctMagic <> nil then SetEctMagic (nil);
      end;

      MAGICTYPE_RUNNING    :
         begin
            SetRunningMagic ( @HaveMagicArr[akey]);
            if FpCurRunningMagic <> nil then Result := SELECTMAGIC_RESULT_RUNNING
            else Result := SELECTMAGIC_RESULT_NORMAL;
         end;
      MAGICTYPE_BREATHNG   :
         begin
            SetBreathngMagic ( @HaveMagicArr[akey]);
            if FpCurBreathngMagic <> nil then Result := SELECTMAGIC_RESULT_SITDOWN
            else Result := SELECTMAGIC_RESULT_NORMAL;
            if FpCurBreathngMagic <> nil then SetProtectingMagic (nil);
         end;
      MAGICTYPE_PROTECTING :
         begin
            SetProtectingMagic ( @HaveMagicArr[akey]);
            if FpCurProtectingMagic <> nil then SetBreathngMagic (nil);
         end;
      MAGICTYPE_ECT :
         begin
            SetEctMagic ( @HaveMagicArr[akey]);
         end;
   end;
   SetLifeData;
end;

function  THaveMagicClass.AddWalking: Boolean;
var
   oldslevel : integer;
   exp : integer;
begin
   Result := FALSE;

   if boAddExp = false then exit;
   
   if FpCurRunningMagic <> nil then begin
      inc (WalkingCount);
      if WalkingCount >= 10 then begin
         WalkingCount := 0;
         exp := DEFAULTEXP;

         case pCurRunningMagic^.rcSkillLevel of
            0..4999: ReQuestPlaySoundNumber := FpCurRunningMagic.rSoundEvent.rWavNumber;
            5000..8999: ReQuestPlaySoundNumber := FpCurRunningMagic.rSoundEvent.rWavNumber+1;
            else ReQuestPlaySoundNumber := FpCurRunningMagic.rSoundEvent.rWavNumber+2;
         end;

         oldslevel := pCurRunningMagic^.rcSkillLevel;
         AddPermitExp (pCurRunningMagic^.rcSkillLevel, pCurRunningMagic^.rSkillExp, exp);
         if oldslevel <> pCurRunningMagic^.rcSkillLevel then begin
            FindAndSendMagic (pCurRunningMagic);
            FSendClass.SendEventString (StrPas (@pCurRunningMagic^.rname));
         end;
         DecEventAttrib (FpCurRunningMagic);
         Result := TRUE;
      end;
   end;
end;

function  THaveMagicClass.AddAttackExp ( atype, aexp: integer): integer;
var oldslevel : integer;
begin
   Result := 0;

   if boAddExp = false then exit;
   
   // if pCurAttackMagic.rPercent <> 10 then exit;
   oldslevel := pCurAttackMagic.rcSkillLevel;
   Result := AddPermitExp (pCurAttackMagic.rcSkillLevel, pCurAttackMagic.rSkillExp, aexp);
   if oldslevel <> pCurAttackMagic.rcSkillLevel then begin
      FindAndSendMagic (pCurAttackMagic);
      FSendClass.SendEventString (StrPas (@pCurAttackMagic^.rname));
      MagicClass.Calculate_cLifeData (pCurAttackMagic);
   end;

   if pCurEctMagic <> nil then begin
      // oldslevel := pCurEctMagic.rcSkillLevel;
      Result := GetPermitExp (pCurEctMagic.rcSkillLevel, aexp);
      {
      if oldslevel <> pCurEctMagic.rcSkillLevel then begin
         FindAndSendMagic (pCurEctMagic);
         FSendClass.SendEventString (StrPas (@pCurEctMagic^.rname));
         MagicClass.Calculate_cLifeData (pCurEctMagic);
      end;
      }
   end;
end;

function  THaveMagicClass.AddProtectExp ( atype, aexp: integer): integer;
var
   oldslevel : integer;
begin
   Result := 0;

   if boAddExp = false then exit;
   
   if pCurProtectingMagic = nil then exit;
   // if pCurProtectingMagic.rPercent <> 10 then exit;
   oldslevel := pCurProtectingMagic.rcSkillLevel;
   Result := AddPermitExp (pCurProtectingMagic.rcSkillLevel, pCurProtectingMagic.rSkillExp, aexp);
   if oldslevel <> pCurProtectingMagic.rcSkillLevel then begin
      FindAndSendMagic (pCurProtectingMagic);
      FSendClass.SendEventString (StrPas (@pCurProtectingMagic^.rname));
      MagicClass.Calculate_cLifeData (pCurProtectingMagic);
   end;
end;

function  THaveMagicClass.AddEctExp ( atype, aexp: integer): integer;
var
   oldslevel : integer;
begin
   Result := 0;

   if boAddExp = false then exit;
   
   if pCurEctMagic = nil then exit;
   // if pCurEctMagic.rPercent <> 10 then exit;
   oldslevel := pCurEctMagic.rcSkillLevel;
   Result := AddPermitExp (pCurEctMagic.rcSkillLevel, pCurEctMagic.rSkillExp, aexp);
   if oldslevel <> pCurEctMagic.rcSkillLevel then begin
      FindAndSendMagic (pCurEctMagic);
      FSendClass.SendEventString (StrPas (@pCurEctMagic^.rname));
      MagicClass.Calculate_cLifeData (pCurEctMagic);
   end;
end;

function THaveMagicClass.boKeepingMagic (pMagicData: PTMagicData): Boolean;
begin
   Result := TRUE;
   if FAttribClass.CurAttribData.CurEnergy  < pMagicData^.rKeepEnergy then Result := FALSE;
   if FAttribClass.CurAttribData.CurInPower < pMagicData^.rKeepInPower  then Result := FALSE;
   if FAttribClass.CurAttribData.CurOutPower < pMagicData^.rKeepOutPower  then Result := FALSE;
   if FAttribClass.CurAttribData.CurMagic < pMagicData^.rKeepMagic  then Result := FALSE;
   if FAttribClass.CurAttribData.CurLife < pMagicData^.rKeepLife  then Result := FALSE;
end;

procedure THaveMagicClass.Dec5SecAttrib (pMagicData: PTMagicData);
begin
   with FAttribClass do begin
      CurAttribData.CurEnergy  := CurAttribData.CurEnergy - pMagicData^.r5SecDecEnergy;
      CurAttribData.CurInPower := CurAttribData.CurInPower - pMagicData^.r5SecDecInPower;
      CurAttribData.CurOutPower := CurAttribData.CurOutPower - pMagicData^.r5SecDecOutPower;
      CurAttribData.CurMagic := CurAttribData.CurMagic - pMagicData^.r5SecDecMagic;
      CurAttribData.CurLife := CurAttribData.CurLife - pMagicData^.r5SecDecLife;

      if CurAttribData.CurEnergy  < 0 then CurAttribData.CurEnergy := 0;
      if CurAttribData.CurInPower < 0  then CurAttribData.CurInPower := 0;
      if CurAttribData.CurOutPower < 0  then CurAttribData.CurOutPower := 0;
      if CurAttribData.CurMagic < 0  then CurAttribData.CurMagic := 0;
      if CurAttribData.CurLife < 0  then CurAttribData.CurLife := 0;

      if CurAttribData.CurEnergy  > AttribData.cEnergy then CurAttribData.CurEnergy := AttribData.cEnergy;
      if CurAttribData.CurInPower > AttribData.cInPower  then CurAttribData.CurInPower := AttribData.cInPower;
      if CurAttribData.CurOutPower > AttribData.cOutPower  then CurAttribData.CurOutPower := AttribData.cOutPower;
      if CurAttribData.CurMagic > AttribData.cMagic  then CurAttribData.CurMagic := AttribData.cMagic;
      if CurAttribData.CurLife > AttribData.cLife  then CurAttribData.CurLife := AttribData.cLife;
   end;
end;

procedure THaveMagicClass.DecEventAttrib (pMagicData: PTMagicData);
var
   n : integer;
begin
   with FAttribClass do begin
      n := pMagicData^.rEventDecEnergy + pMagicData^.rEventDecEnergy * pMagicData^.rcSkillLevel div INI_SKILL_DIV_EVENT;
      dec (CurAttribData.CurEnergy, n);

      n := pMagicData^.rEventDecInPower + pMagicData^.rEventDecInPower * pMagicData^.rcSkillLevel div INI_SKILL_DIV_EVENT;
      dec (CurAttribData.CurInPower, n);

      n := pMagicData^.rEventDecOutPower + pMagicData^.rEventDecOutPower * pMagicData^.rcSkillLevel div INI_SKILL_DIV_EVENT;
      dec (CurAttribData.CurOutPower, n);

      n := pMagicData^.rEventDecMagic + pMagicData^.rEventDecMagic * pMagicData^.rcSkillLevel div INI_SKILL_DIV_EVENT;
      dec (CurAttribData.CurMagic, n);

      n := pMagicData^.rEventDecLife + pMagicData^.rEventDecLife * pMagicData^.rcSkillLevel div INI_SKILL_DIV_EVENT;
      dec (CurAttribData.CurLife, n);

      if CurAttribData.CurEnergy  < 0 then CurAttribData.CurEnergy := 0;
      if CurAttribData.CurInPower < 0  then CurAttribData.CurInPower := 0;
      if CurAttribData.CurOutPower < 0  then CurAttribData.CurOutPower := 0;
      if CurAttribData.CurMagic < 0  then CurAttribData.CurMagic := 0;
      if CurAttribData.CurLife < 0  then CurAttribData.CurLife := 0;

      if CurAttribData.CurEnergy  > AttribData.cEnergy then CurAttribData.CurEnergy := AttribData.cEnergy;
      if CurAttribData.CurInPower > AttribData.cInPower  then CurAttribData.CurInPower := AttribData.cInPower;
      if CurAttribData.CurOutPower > AttribData.cOutPower  then CurAttribData.CurOutPower := AttribData.cOutPower;
      if CurAttribData.CurMagic > AttribData.cMagic  then CurAttribData.CurMagic := AttribData.cMagic;
      if CurAttribData.CurLife > AttribData.cLife  then CurAttribData.CurLife := AttribData.cLife;
   end;
end;

procedure THaveMagicClass.DecBreathngAttrib (pMagicData: PTMagicData);
var
   max : integer;
begin
   with FAttribClass do begin
      max := AttribData.cEnergy div (6+(12000 - pMagicData^.rcSkillLevel) * 14 div 12000);
      max := max * pMagicData^.rEventBreathngEnergy div 100;
      dec (CurAttribData.CurEnergy, max);

      max := AttribData.cInPower div (6+(12000 - pMagicData^.rcSkillLevel) * 14 div 12000);
      max := max * pMagicData^.rEventBreathngInPower div 100;
      dec (CurAttribData.CurInPower, max);

      max := AttribData.cOutPower div (6+(12000 - pMagicData^.rcSkillLevel) * 14 div 12000);
      max := max * pMagicData^.rEventBreathngOutPower div 100;
      dec (CurAttribData.CurOutPower, max);

      max := AttribData.cMagic div (6+(12000 - pMagicData^.rcSkillLevel) * 14 div 12000);
      max := max * pMagicData^.rEventBreathngMagic div 100;
      dec (CurAttribData.CurMagic, max);

      max := AttribData.cLife div (6+(12000 - pMagicData^.rcSkillLevel) * 14 div 12000);
      max := max * pMagicData^.rEventBreathngLife div 100;
      dec (CurAttribData.CurLife, max);

      if CurAttribData.CurEnergy  < 0 then CurAttribData.CurEnergy := 0;
      if CurAttribData.CurInPower < 0  then CurAttribData.CurInPower := 0;
      if CurAttribData.CurOutPower < 0  then CurAttribData.CurOutPower := 0;
      if CurAttribData.CurMagic < 0  then CurAttribData.CurMagic := 0;
      if CurAttribData.CurLife < 0  then CurAttribData.CurLife := 0;

      if CurAttribData.CurEnergy  > AttribData.cEnergy then CurAttribData.CurEnergy := AttribData.cEnergy;
      if CurAttribData.CurInPower > AttribData.cInPower  then CurAttribData.CurInPower := AttribData.cInPower;
      if CurAttribData.CurOutPower > AttribData.cOutPower  then CurAttribData.CurOutPower := AttribData.cOutPower;
      if CurAttribData.CurMagic > AttribData.cMagic  then CurAttribData.CurMagic := AttribData.cMagic;
      if CurAttribData.CurLife > AttribData.cLife  then CurAttribData.CurLife := AttribData.cLife;
   end;
end;

function THaveMagicClass.FindHaveMagicByName (aMagicName : String) : Integer;
var
   i : Integer;
begin
   Result := -1;
   for i := 0 to HAVEMAGICSIZE - 1 do begin
      if StrPas (@HaveMagicArr[i].rName) = aMagicName then begin
         Result := HaveMagicArr[i].rcSkillLevel;
         exit;
      end;
   end;
end;

function THaveMagicClass.Update (CurTick : integer): integer;
var
   oldslevel : integer;
   closeflag, upflag : Boolean;
begin
   Result := 0;
   if FpCurAttackMagic <> nil then begin
      if CurTick > FpCurAttackMagic.rMagicProcessTick + 500 then begin
         FpCurAttackMagic.rMagicProcessTick := CurTick;
         Dec5SecAttrib (FpCurAttackMagic);
         if not boKeepingMagic (FpCurAttackMagic) then begin Result := RET_CLOSE_ATTACK; exit; end;
      end;
   end;

   if FpCurRunningMagic <> nil then begin
     if CurTick > FpCurRunningMagic.rMagicProcessTick + 500 then begin
        FpCurRunningMagic.rMagicProcessTick := CurTick;
        Dec5SecAttrib (FpCurRunningMagic);
        if not boKeepingMagic (FpCurRunningMagic) then begin Result := RET_CLOSE_RUNNING; exit; end;
     end;
   end;

   if FpCurProtectingMagic <> nil then begin
      if CurTick > FpCurProtectingMagic.rMagicProcessTick + 500 then begin
         FpCurProtectingMagic.rMagicProcessTick := CurTick;
         Dec5SecAttrib (FpCurProtectingMagic);
         if not boKeepingMagic (FpCurProtectingMagic) then begin Result := RET_CLOSE_PROTECTING; exit; end;
      end;
   end;

   if FpCurBreathngMagic <> nil then begin
      if CurTick > FpCurBreathngMagic.rMagicProcessTick + 500 then begin
         case FpCurBreathngMagic.rcSkillLevel of
            0..4999: ReQuestPlaySoundNumber := FpCurBreathngMagic.rSoundEvent.rWavNumber;
            5000..8999: ReQuestPlaySoundNumber := FpCurBreathngMagic.rSoundEvent.rWavNumber+2;
            else ReQuestPlaySoundNumber := FpCurBreathngMagic.rSoundEvent.rWavNumber+4;
         end;
         if not FAttribClass.boMan then ReQuestPlaySoundNumber := ReQuestPlaySoundNumber +1;

         FpCurBreathngMagic.rMagicProcessTick := CurTick;

//         Dec5SecAttrib (FpCurBreathngMagic);
         if not boKeepingMagic (FpCurBreathngMagic) then begin Result := RET_CLOSE_BREATHNG; exit; end;

         closeflag := TRUE;
         if (FpCurBreathngMagic^.rEventDecEnergy < 0) and (FAttribClass.CurAttribData.CurEnergy < FAttribClass.AttribData.cEnergy) then closeflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecInPower < 0) and (FAttribClass.CurAttribData.CurInPower < FAttribClass.AttribData.cInPower) then closeflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecOutPower < 0) and (FAttribClass.CurAttribData.CurOutPower < FAttribClass.AttribData.cOutPower) then closeflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecMagic < 0) and (FAttribClass.CurAttribData.CurMagic < FAttribClass.AttribData.cMagic) then closeflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecLife < 0) and (FAttribClass.CurAttribData.CurLife < FAttribClass.AttribData.cLife) then closeflag := FALSE;
         if closeflag then begin Result := RET_CLOSE_BREATHNG; exit; end;


         upflag := TRUE;
         if (FpCurBreathngMagic^.rEventDecEnergy < 0) and (FAttribClass.CurAttribData.CurEnergy = FAttribClass.AttribData.cEnergy) then upflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecInPower < 0) and (FAttribClass.CurAttribData.CurInPower = FAttribClass.AttribData.cInPower) then upflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecOutPower < 0) and (FAttribClass.CurAttribData.CurOutPower = FAttribClass.AttribData.cOutPower) then upflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecMagic < 0) and (FAttribClass.CurAttribData.CurMagic = FAttribClass.AttribData.cMagic) then upflag := FALSE;
         if (FpCurBreathngMagic^.rEventDecLife < 0) and (FAttribClass.CurAttribData.CurLife = FAttribClass.AttribData.cLife) then upflag := FALSE;

         DecBreathngAttrib (FpCurBreathngMagic);
//         DecEventAttrib (FpCurBreathngMagic);
         FSendClass.SendAttribBase (FAttribClass.AttribData, FAttribClass.CurAttribData);

         if (upflag = true) and (boAddExp = true) then begin
            oldslevel := FpCurBreathngMagic.rcSkillLevel;
            AddPermitExp (FpCurBreathngMagic^.rcSkillLevel, FpCurBreathngMagic^.rSkillExp, DEFAULTEXP);
            if oldslevel <> FpCurBreathngMagic^.rcSkillLevel then begin
               FindAndSendMagic (FpCurBreathngMagic);
               FSendClass.SendEventString (StrPas (@FpCurBreathngMagic^.rName));
            end;

            oldslevel := FAttribClass.AttribData.cGoodChar;
            AddPermitExp (FAttribClass.AttribData.cGoodChar, FAttribClass.AttribData.GoodChar, FpCurBreathngMagic^.rGoodChar);
            if oldslevel <> FAttribClass.AttribData.cGoodChar then begin
               FSendClass.SendAttribValues (FAttribClass.AttribData, FAttribClass.CurAttribData);

            end;
            oldslevel := FAttribClass.AttribData.cBadChar;
            AddPermitExp (FAttribClass.AttribData.cBadChar, FAttribClass.AttribData.BadChar, FpCurBreathngMagic^.rBadChar);
            if oldslevel <> FAttribClass.AttribData.cBadChar then begin
               FSendClass.SendAttribValues (FAttribClass.AttribData, FAttribClass.CurAttribData);
            end;
         end;
      end;
   end;
end;


end.

unit uMopSub;

interface

uses
   Classes, SysUtils, BasicObj, svClass, uAnsTick, AUtil32, DefType;

const
   MOP_DROPITEM_MAX      = 5;
   MOP_HAVEITEM_MAX      = 10;
   MOP_WANTITEM_MAX      = 5;

   MOP_HAVEMAGIC_MAX     = 5;

type
   TMopHaveItemClass = class
   private
      BasicObject : TBasicObject;

      DropItemArr : array [0..MOP_DROPITEM_MAX - 1] of TCheckItem;
      HaveItemArr : array [0..MOP_HAVEITEM_MAX - 1] of TAtomItem;
      WantItemArr : array [0..MOP_WANTITEM_MAX - 1] of String;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      procedure Clear;
      procedure DropItemClear;
      procedure HaveItemClear;
      procedure WantItemClear;

      function DropItemCount : Integer;
      function HaveItemCount : Integer;
      function WantItemCount : Integer;

      function DropItemFreeCount : Integer;
      function HaveItemFreeCount : Integer;
      function WantItemFreeCount : Integer;

      function FindDropItem (aName : String) : Integer;
      function AddDropItem (aName : String; aCount : Integer) : Boolean;
      function DelDropItem (aName : String) : Boolean;

      function FindHaveItem (aName : String) : Integer;
      function AddHaveItem (aName : String; aCount, aColor : Integer) : Boolean;
      function DelHaveItem (aName : String; aColor, aCount : Integer) : Boolean;

      function FindWantItem (aName : String) : Integer;
      function AddWantItem (aName : String) : Boolean;
      function DelWantItem (aName : String) : Boolean;

      procedure DropItemGround;
   end;

   TMopHaveMagicClass = class
   private
      BasicObject : TBasicObject;

      UsedTickArr : array [0..MAGICSPECIAL_LAST - 1] of Integer;
      HaveMagicPos : array [0..MAGICSPECIAL_LAST - 1] of Byte;
      HaveMagicArr : array [0..MOP_HAVEMAGIC_MAX - 1] of TMagicParamData;
      HaveMagicData : array [0..MOP_HAVEMAGIC_MAX - 1] of TMagicData;
   public
      constructor Create (aBasicObject : TBasicObject);
      destructor Destroy; override;

      procedure Clear;
      procedure Init (aMagicStr : String);
      
      function isHaveHideMagic : Boolean;
      function isHaveSameMagic : Boolean;
      function isHaveHealMagic : Boolean;
      function isHaveSwapMagic : Boolean;
      function isHaveEatMagic : Boolean;
      function isHaveKillMagic : Boolean;
      function isHavePickMagic : Boolean;

      function RunHaveSameMagic (aPercent : Integer; var aSubData : TSubData) : Boolean;
      function RunHaveHealMagic (aName : String; aPercent : Integer; var aSubData : TSubData) : Boolean;
      function RunHaveSwapMagic (aPercent : Integer; var aSubData : TSubData) : Boolean;
      function RunHaveEatMagic (aPercent : Integer; aHaveItemClass : TMopHaveItemClass; var aSubData : TSubData) : Boolean;      
      function RunHavePickMagic (aPercent : Integer; aName : String) : Boolean;
      function RunHaveHideMagic (aPercent : Integer) : Boolean;
   end;

implementation

uses
   uMonster;

// TMopHaveItemClass
constructor TMopHaveItemClass.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;
   Clear;
end;

destructor TMopHaveItemClass.Destroy;
begin
   inherited Destroy;
end;

procedure TMopHaveItemClass.Clear;
begin
   DropItemClear;
   HaveItemClear;
   WantItemClear;
end;

procedure TMopHaveItemClass.DropItemClear;
var
   i : Integer;
begin
   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      FillChar (DropItemArr [i], SizeOf (TCheckItem), 0);
   end;
end;

procedure TMopHaveItemClass.HaveItemClear;
var
   i : Integer;
begin
   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      FillChar (HaveItemArr [i], SizeOf (TAtomItem), 0);
   end;
end;

procedure TMopHaveItemClass.WantItemClear;
var
   i : Integer;
begin
   for i := 0 to MOP_WANTITEM_MAX - 1 do begin
      WantItemArr [i] := '';
   end;
end;

function TMopHaveItemClass.DropItemCount : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      if DropItemArr[i].rName <> '' then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.HaveItemCount : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      if HaveItemArr [i].rItemName <> '' then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.WantItemCount : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_WANTITEM_MAX - 1 do begin
      if WantItemArr [i] <> '' then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.DropItemFreeCount : Integer;
begin
   Result := MOP_DROPITEM_MAX - DropItemCount;
end;

function TMopHaveItemClass.HaveItemFreeCount : Integer;
begin
   Result := MOP_HAVEITEM_MAX - HaveItemCount;
end;

function TMopHaveItemClass.WantItemFreeCount : Integer;
begin
   Result := MOP_WANTITEM_MAX - WantItemCount;
end;

function TMopHaveItemClass.FindDropItem (aName : String) : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      if DropItemArr[i].rName = aName then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.AddDropItem (aName : String; aCount : Integer) : Boolean;
var
   i : Integer;
begin
   Result := false;

   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      if DropItemArr [i].rName = '' then begin
         DropItemArr [i].rName := aName;
         DropItemArr [i].rCount := aCount;
         Result := true;
         exit;
      end;
   end;
end;

function TMopHaveItemClass.DelDropItem (aName : String) : Boolean;
var
   i : Integer;
begin
   Result := false;

   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      if DropItemArr [i].rName = aName then begin
         DropItemArr [i].rName := '';
         DropItemArr [i].rCount := 0;
         Result := true;
         exit;
      end;
   end;
end;

function TMopHaveItemClass.FindHaveItem (aName : String) : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      if HaveItemArr [i].rItemName = aName then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.AddHaveItem (aName : String; aCount, aColor : Integer) : Boolean;
var
   i : Integer;
begin
   Result := false;

   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      if HaveItemArr [i].rItemName = '' then begin
         HaveItemArr [i].rItemName := aName;
         HaveItemArr [i].rItemCount := aCount;
         HaveItemArr [i].rColor := aColor;
         Result := true;
         exit;
      end;
   end;
end;

function TMopHaveItemClass.DelHaveItem (aName : String; aColor, aCount : Integer) : Boolean;
var
   i, iCount : Integer;
begin
   Result := false;

   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      if HaveItemArr [i].rItemName = aName then begin
         if HaveItemArr [i].rItemCount > 0 then begin
            if (aColor < 0) or (HaveItemArr [i].rColor = aColor) then begin
               HaveItemArr [i].rItemCount := HaveItemArr [i].rItemCount - aCount;
               if HaveItemArr [i].rItemCount <= 0 then begin
                  HaveItemArr [i].rItemName := '';
                  HaveItemArr [i].rItemCount := 0;
                  HaveItemArr [i].rColor := 0;
               end;
               Result := true;
               exit;
            end;
         end;
      end;
   end;
end;

function TMopHaveItemClass.FindWantItem (aName : String) : Integer;
var
   i, iCount : Integer;
begin
   iCount := 0;
   for i := 0 to MOP_WANTITEM_MAX - 1 do begin
      if WantItemArr [i] = aName then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TMopHaveItemClass.AddWantItem (aName : String) : Boolean;
var
   i : Integer;
begin
   Result := false;
   for i := 0 to MOP_WANTITEM_MAX - 1 do begin
      if WantItemArr [i] = '' then begin
         WantItemArr [i] := aName;
         Result := true;
         exit;
      end;
   end;
end;

function TMopHaveItemClass.DelWantItem (aName : String) : Boolean;
var
   i : Integer;
begin
   Result := false;
   for i := 0 to MOP_WANTITEM_MAX - 1 do begin
      if WantItemArr [i] = aName then begin
         WantItemArr [i] := '';
         Result := true;
         exit;
      end;
   end;
end;

procedure TMopHaveItemClass.DropItemGround;
var
   i : Integer;
   MopName : String;
   ItemData : TItemData;
   SubData : TSubData;
   CheckItem : TCheckItem;
begin
   MopName := StrPas (@BasicObject.BasicData.Name);
   BasicObject.BasicData.nx := BasicObject.BasicData.x;
   BasicObject.BasicData.ny := BasicObject.BasicData.y;

   for i := 0 to MOP_DROPITEM_MAX - 1 do begin
      if DropItemArr[i].rName <> '' then begin
         if ItemClass.GetCheckItemData (MopName, DropItemArr [i], ItemData) = false then continue;
         ItemData.rOwnerName[0] := 0;
         SubData.ItemData := ItemData;
         SubData.ServerId := BasicObject.Manager.ServerId;
         BasicObject.Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicObject.BasicData, SubData);
      end;
   end;
   for i := 0 to MOP_HAVEITEM_MAX - 1 do begin
      if HaveItemArr[i].rItemName <> '' then begin
         if Random (2) = 1 then begin
            CheckItem.rName := HaveItemArr[i].rItemName;
            if ItemClass.GetCheckItemData (MopName, CheckItem, ItemData) = false then continue;
            ItemData.rCount := HaveItemArr[i].rItemCount;
            ItemData.rColor := HaveItemArr[i].rColor;
            ItemData.rOwnerName[0] := 0;
            SubData.ItemData := ItemData;
            SubData.ServerId := BasicObject.Manager.ServerId;
            BasicObject.Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicObject.BasicData, SubData);
         end;
      end;
   end;
   HaveItemClear;
end;

// TMopHaveMagicClass
constructor TMopHaveMagicClass.Create (aBasicObject : TBasicObject);
begin
   BasicObject := aBasicObject;

   FillChar (UsedTickArr, SizeOf (UsedTickArr), 0);
   FillChar (HaveMagicPos, SizeOf (HaveMagicPos), 0);
   FillChar (HaveMagicArr, SizeOf (HaveMagicArr), 0);
   FillChar (HaveMagicData, SizeOf (HaveMagicData), 0);
end;

destructor TMopHaveMagicClass.Destroy;
begin
   inherited Destroy;
end;

procedure TMopHaveMagicClass.Clear;
begin
end;

procedure TMopHaveMagicClass.Init (aMagicStr : String);
var
   i : Integer;
   iName : String;
   Str, rdStr : String;
begin
   iName := StrPas (@BasicObject.BasicData.Name);

   FillChar (UsedTickArr, SizeOf (UsedTickArr), 0);
   FillChar (HaveMagicPos, SizeOf (HaveMagicPos), 0);
   FillChar (HaveMagicArr, SizeOf (HaveMagicArr), 0);
   FillChar (HaveMagicData, SizeOf (HaveMagicData), 0);

   Str := aMagicStr;
   for i := 0 to MOP_HAVEMAGIC_MAX - 1 do begin
      Str := GetValidStr3 (Str, rdStr, ':');
      if rdStr = '' then break;
      if MagicParamClass.GetMagicParamData (iName, rdStr, HaveMagicArr [i]) = true then begin
         MagicClass.GetMagicData (HaveMagicArr [i].MagicName, HaveMagicData [i], 9999);
         if HaveMagicData [i].rMagicType = MAGICTYPE_SPECIAL then begin
            HaveMagicPos [HaveMagicData [i].rFunction] := i + 1;
         end;
      end;
   end;
end;

function TMopHaveMagicClass.isHaveHideMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_HIDE] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHaveSameMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_SAME] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHaveHealMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_HEAL] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHaveSwapMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_SWAP] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHaveEatMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_EAT] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHaveKillMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_KILL] > 0 then Result := true;
end;

function TMopHaveMagicClass.isHavePickMagic : Boolean;
begin
   Result := false;
   if HaveMagicPos [MAGICSPECIAL_PICK] > 0 then Result := true;
end;

function TMopHaveMagicClass.RunHaveSameMagic (aPercent : Integer; var aSubData : TSubData) : Boolean;
var
   ArrPos : Integer;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_SAME] - 1;
   if ArrPos < 0 then exit;
   if UsedTickArr [MAGICSPECIAL_SAME] <> 0 then exit;

   if aPercent <= HaveMagicArr[ArrPos].NumberParam[0] then begin
      UsedTickArr [MAGICSPECIAL_SAME] := mmAnsTick;
      aSubData.HitData.ToHit := HaveMagicArr [ArrPos].NumberParam[1];
      Result := true;
   end;
end;

function TMopHaveMagicClass.RunHaveHealMagic (aName : String; aPercent : Integer; var aSubData : TSubData) : Boolean;
var
   i, ArrPos : Integer;
   boFlag : Boolean;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_HEAL] - 1;
   if ArrPos < 0 then exit;
   if mmAnsTick < UsedTickArr [MAGICSPECIAL_HEAL] + HaveMagicArr[ArrPos].NumberParam [2] then exit;

   boFlag := false;
   for i := 0 to 5 - 1 do begin
      if aName = HaveMagicArr [ArrPos].NameParam [i] then begin
         boFlag := true;
         break;
      end;
   end;
   if boFlag = false then exit;

   if aPercent <= HaveMagicArr [ArrPos].NumberParam [0] then begin
      UsedTickArr [MAGICSPECIAL_HEAL] := mmAnsTick;
      aSubData.HitData.ToHit := HaveMagicArr [ArrPos].NumberParam [1];
      Result := true;
   end;
end;

function TMopHaveMagicClass.RunHaveSwapMagic (aPercent : Integer; var aSubData : TSubData) : Boolean;
var
   ArrPos : Integer;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_SWAP] - 1;
   if ArrPos < 0 then exit;

   if aPercent <= HaveMagicArr[ArrPos].NumberParam[0] then begin
      UsedTickArr [MAGICSPECIAL_SWAP] := mmAnsTick;
      StrPCopy (@aSubData.SubName, HaveMagicArr[ArrPos].NameParam [0]);
      Result := true;
   end;
end;

function TMopHaveMagicClass.RunHaveEatMagic (aPercent : Integer; aHaveItemClass : TMopHaveItemClass; var aSubData : TSubData) : Boolean;
var
   i : Integer;
   ArrPos : Integer;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_EAT] - 1;
   if ArrPos < 0 then exit;

   if mmAnsTick < UsedTickArr [MAGICSPECIAL_EAT] + HaveMagicArr [ArrPos].NumberParam [2] then exit;

   if aPercent > HaveMagicArr[ArrPos].NumberParam [0] then exit;
   if aHaveItemClass.FindHaveItem (HaveMagicArr[ArrPos].NameParam [0]) > 0 then begin
      aHaveItemClass.DelHaveItem (HaveMagicArr [ArrPos].NameParam [0], -1, 1);
      StrPCopy (@aSubData.ItemData.rName, HaveMagicArr[ArrPos].NameParam [0]);
      aSubData.HitData.ToHit := HaveMagicArr[ArrPos].NumberParam [1];
      UsedTickArr [MAGICSPECIAL_EAT] := mmAnsTick;
      Result := true;
      exit;
   end;
end;

function TMopHaveMagicClass.RunHavePickMagic (aPercent : Integer; aName : String) : Boolean;
var
   i : Integer;
   ArrPos : Integer;
   boFlag : Boolean;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_PICK] - 1;
   if ArrPos < 0 then exit;

   if aPercent > HaveMagicArr [ArrPos].NumberParam [0] then exit;

   boFlag := false;
   if HaveMagicArr [ArrPos].NameParam [0] <> '' then begin
      for i := 0 to 5 - 1 do begin
         if aName = HaveMagicArr [ArrPos].NameParam [i] then begin
            boFlag := true;
            break;
         end;
      end;
   end else begin
      boFlag := true;
   end;

   if boflag = true then begin
      UsedTickArr [MAGICSPECIAL_PICK] := mmAnsTick;
      Result := true;
   end;
end;

function TMopHaveMagicClass.RunHaveHideMagic (aPercent : Integer) : Boolean;
var
   i : Integer;
   ArrPos : Integer;
   boFlag : Boolean;
begin
   Result := false;

   ArrPos := HaveMagicPos [MAGICSPECIAL_HIDE] - 1;
   if ArrPos < 0 then exit;

   if HaveMagicArr [ArrPos].NumberParam [2] > 0 then begin
      if mmAnsTick < UsedTickArr [MAGICSPECIAL_HIDE] + HaveMagicArr [ArrPos].NumberParam [1] then exit;
   end;

   if aPercent < HaveMagicArr [ArrPos].NumberParam [0] then exit;
   if aPercent > HaveMagicArr [ArrPos].NumberParam [1] then exit;

   UsedTickArr [MAGICSPECIAL_HIDE] := mmAnsTick;
   
   Result := true;
end;

end.

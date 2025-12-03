unit uDoorGen;

interface

uses
   Classes, SysUtils, BasicObj, DefType, UserSDB, AUtil32, uManager,
   uMonster, AnsStringCls;

type
   TDoorObject = class (TBasicObject)
   private
      DoorName : String;

   protected
      procedure Initial (aName : String; aX, aY: Integer);
      procedure StartProcess; override;
      procedure EndProcess; override;
      function FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Update (CurTick: integer); override;
   end;

   TDoorGen = class
   private
      DataList : TList;
   public
      constructor Create;
      destructor Destroy; override;
   end;

   TItemGen = class (TBasicObject)
   private
      SelfData : TItemGenData;

      UpdatedTick : Integer;
      RegenedTick : Integer;
      CreatedTick : Integer;
   protected
      function FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor Destroy; override;

      function GetSelfData : PTItemGenData;

      procedure Initial (aName : String; aX, aY: Integer);
      procedure StartProcess; override;
      procedure EndProcess; override;

      procedure Update (CurTick: integer); override;
   end;

   TObjectChecker = class (TBasicObject)
   private
      UpdatedTick : Integer;

      DataList : TList;

      boMonsterDie : Boolean;
      boDynamicObjectDie : Boolean;
      MonsterDieTick : Integer;
      DynamicObjectDieTick : Integer;

      HaveMonster : TMonster;
      HaveDynamicObject : TDynamicObject;
   protected
      function FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Initial (aName : String; aX, aY: Integer);
      procedure StartProcess; override;
      procedure EndProcess; override;

      procedure RegenData;

      procedure Update (CurTick: integer); override;

      function GetCurInfo : String;
   end;

   TSoundObj = class (TBasicObject)
   private
      SoundName : String;

      UpdatedTick : Integer;
      PlayedTick : Integer;
      PlayInterval : Integer;
   protected
      function FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Initial (pd : PTCreateSoundObjData);
      procedure StartProcess; override;
      procedure EndProcess; override;

      procedure Update (CurTick: integer); override;
   end;

   TSoundObjList = class
   private
      DataList : TList;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;
      function LoadFromFile (aFileName : String) : Boolean;
      
      procedure Update (CurTick : Integer);
   end;



var
   ItemGen : TItemGen;
   ObjectChecker : TObjectChecker;
   SoundObjList : TSoundObjList;

implementation

uses
   svClass, SubUtil;

// TDoorObject
constructor TDoorObject.Create;
begin

end;

destructor TDoorObject.Destroy;
begin
   inherited Destroy;
end;

procedure TDoorObject.Initial (aName : String; aX, aY: Integer);
begin
   inherited Initial (aName, '');
end;

procedure TDoorObject.StartProcess;
begin

end;

procedure TDoorObject.EndProcess;
begin

end;

function TDoorObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
begin

end;

procedure TDoorObject.Update (CurTick: integer);
begin

end;

// TDoorGen
constructor TDoorGen.Create;
begin

end;

destructor TDoorGen.Destroy;
begin
   inherited Destroy;
end;

// TItemGen
constructor TItemGen.Create;
begin
   inherited Create;
   
   UpdatedTick := 0;
   CreatedTick := 0;
   RegenedTick := 0;

   FillChar (SelfData, SizeOf (TItemGenData), 0);
end;

destructor TItemGen.Destroy;
begin
   inherited Destroy;
end;

function TItemGen.GetSelfData : PTItemGenData;
begin
   Result := @SelfData;
end;

procedure TItemGen.Initial (aName : String; aX, aY: Integer);
begin
   inherited Initial (aName, '');

   BasicData.id := GetNewItemId;

   BasicData.x := aX;
   BasicData.y := aY;
   BasicData.nx := aX;
   BasicData.ny := aY;
   BasicData.ClassKind := CLASS_SERVEROBJ;
   BasicData.Feature.rRace := RACE_ITEM;
   BasicData.Feature.rImageNumber := 0;
   BasicData.Feature.rImageColorIndex := 0;

   UpdatedTick := 0;
   CreatedTick := -30000;
   RegenedTick := 0;

   SelfData.Name := aName;
   SelfData.ItemName := 'ÉúÈâ';
   SelfData.ItemCount := 60;
   SelfData.CreateInterval := 30000;
   SelfData.RegenInterval := 1000;
   SelfData.ItemCreateX := 100;
   SelfData.ItemCreateY := 84;
   SelfData.ItemCreateW := 10;
   SelfData.ItemRegenX := 134;
   SelfData.ItemRegenY := 39;
   SelfData.ItemRegenW := 12; 
end;

procedure TItemGen.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TItemGen.EndProcess;
var
   SubData : TSubData;
begin
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

function TItemGen.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
begin
   Result := PROC_FALSE;

   if isRangeMessage (hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;
end;

procedure TItemGen.Update (CurTick: integer);
var
   i, iCount : Integer;
   xx, yy : Word;
   BasicObject : TBasicObject;
   SubData : TSubData;
begin
   if CurTick < UpdatedTick + 100 then exit;
   UpdatedTick := CurTick;

   iCount := 0;
   for i := 0 to ViewObjectList.Count - 1 do begin
      BasicObject := ViewObjectList.Items [i];
      if BasicObject.BasicData.ClassKind = CLASS_ITEM then begin
         if StrPas (@BasicObject.BasicData.Name) = SelfData.ItemName then begin
            Inc (iCount);
         end;
      end;
   end;

   if CurTick >= CreatedTick + SelfData.CreateInterval then begin
      ItemClass.GetItemData (SelfData.ItemName, SubData.ItemData);

      SignToItem (SubData.ItemData, ServerID, BasicData, '');
      SubData.ItemData.rCount := 1;
      SubData.ServerId := ServerID;

      if SubData.ItemData.rName [0] <> 0 then begin
         for i := 0 to SelfData.ItemCount - iCount - 1 do begin
            xx := SelfData.ItemCreateX - SelfData.ItemCreateW + Random(SelfData.ItemCreateW * 2);
            yy := SelfData.ItemCreateY - SelfData.ItemCreateW + Random(SelfData.ItemCreateW * 2);

            if not Maper.isMoveable (xx, yy) then continue;

            BasicData.nX := xx;
            BasicData.nY := yy;

            Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
         end;
      end;
      CreatedTick := CurTick;
   end;
   if CurTick >= RegenedTick + SelfData.RegenInterval then begin
      ItemClass.GetItemData (SelfData.ItemName, SubData.ItemData);

      SignToItem (SubData.ItemData, ServerID, BasicData, '');
      SubData.ItemData.rCount := 1;
      SubData.ServerId := ServerID;

      if SubData.ItemData.rName [0] <> 0 then begin
         if iCount > 0 then begin
            xx := SelfData.ItemRegenX - SelfData.ItemRegenW + Random(SelfData.ItemRegenW * 2);
            yy := SelfData.ItemRegenY - SelfData.ItemRegenW + Random(SelfData.ItemRegenW * 2);

            if Maper.isMoveable (xx, yy) then begin
               BasicData.nX := xx;
               BasicData.nY := yy;

               Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
            end;
         end;
      end;

      RegenedTick := CurTick;
   end;
end;

// TObjectChecker
constructor TObjectChecker.Create;
begin
   inherited Create;

   UpdatedTick := 0;

   HaveMonster := nil;
   HaveDynamicObject := nil;

   DataList := TList.Create;
end;

destructor TObjectChecker.Destroy;
begin
   if HaveMonster <> nil then begin
      HaveMonster.EndProcess;
      HaveMonster.Free;
      HaveMonster := nil;
   end;
   if HaveDynamicObject <> nil then begin
      HaveDynamicObject.EndProcess;
      HaveMonster.Free;
      HaveMonster := nil;
   end;

   DataList.Clear;
   DataList.Free;
   
   inherited Destroy;
end;

procedure TObjectChecker.Initial (aName : String; aX, aY: Integer);
begin
   inherited Initial (aName, '');

   BasicData.id := GetNewItemId;

   BasicData.x := aX;
   BasicData.y := aY;
   BasicData.nx := aX;
   BasicData.ny := aY;
   BasicData.ClassKind := CLASS_SERVEROBJ;
   BasicData.Feature.rRace := RACE_ITEM;
   BasicData.Feature.rImageNumber := 0;
   BasicData.Feature.rImageColorIndex := 0;

   RegenData;

   UpdatedTick := 0;
   boMonsterDie := false;
   boDynamicObjectDie := false;
   MonsterDieTick := 0;
   DynamicObjectDieTick := 0;
end;

procedure TObjectChecker.RegenData;
begin
   DataList.Clear;
   TDynamicObjectList (Manager.DynamicObjectList).GetDynamicObjects ('ºüÀê»ð', DataList);
end;

procedure TObjectChecker.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TObjectChecker.EndProcess;
var
   SubData : TSubData;
begin
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

function TObjectChecker.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
begin
   Result := PROC_FALSE;

   if isRangeMessage (hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;
end;

procedure TObjectChecker.Update (CurTick: integer);
var
   i, iCount : Integer;
   xx, yy : Word;
   DynamicObject : TDynamicObject;
   SubData : TSubData;
   cdod : TCreateDynamicObjectData;
begin
   {
   if boMonsterDie = true then begin
      if HaveMonster <> nil then begin
         HaveMonster.EndProcess;
         HaveMonster.Free;
         HaveMonster := nil;
      end;
      boMonsterDie := false;
   end;
   if boDynamicObjectDie = true then begin
      if HaveDynamicObject <> nil then begin
         HaveDynamicObject.EndProcess;
         HaveDynamicObject.Free;
         HaveDynamicObject := nil;
      end;
      boDynamicObjectDie := false;
   end;
   }

   if HaveMonster <> nil then begin
      if HaveMonster.boRegisted = true then begin
         if HaveMonster.boAllowDelete = true then begin
            HaveMonster.EndProcess;
            HaveMonster := nil;
         end else begin
            HaveMonster.Update (CurTick);
         end;
      end;
   end;
   if HaveDynamicObject <> nil then begin
      if HaveDynamicObject.boRegisted = true then begin
         if HaveDynamicObject.boAllowDelete = true then begin
            HaveDynamicObject.EndProcess;
            HaveDynamicObject.Free;
            HaveDynamicObject := nil;
         end else begin
            HaveDynamicObject.Update (CurTick);
         end;
      end;
   end;

   if CurTick < UpdatedTick + 100 then exit;

   UpdatedTick := CurTick;

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.Status = dos_Openned then begin
         Inc (iCount);
      end;
   end;

   if iCount < 2 then begin
      if HaveMonster <> nil then begin
         if HaveMonster.boRegisted = true then begin
            HaveMonster.EndProcess;
         end;
      end;
   end else if iCount < 4 then begin
      if HaveMonster = nil then begin
         HaveMonster := TMonster.Create;
         HaveMonster.SetManagerClass (Manager);
         HaveMonster.Initial ('ËÀÀÇÅ®ÊµÏñ', BasicData.X, BasicData.Y, 5);
      end;
      if HaveMonster.boRegisted = false then begin
         HaveMonster.StartProcess;
         HaveMonster.SetHideState (hs_0);
      end;
      if HaveDynamicObject <> nil then begin
         if HaveDynamicObject.boRegisted = true then begin
            if HaveDynamicObject.ObjectStatus = dos_Closed then begin
               HaveDynamicObject.EndProcess;
            end;
         end;
      end;
   end else begin
      if HaveDynamicObject = nil then begin
         FillChar (cdod, SizeOf (TCreateDynamicObjectData), 0);

         DynamicObjectClass.GetDynamicObjectData ('Ñý»ª', cdod.rBasicData);
         cdod.rServerId := Manager.ServerID;
         cdod.rX[0] := 37;
         cdod.rY[0] := 50;

         HaveDynamicObject := TDynamicObject.Create;
         HaveDynamicObject.SetManagerClass (Manager);
         HaveDynamicObject.Initial (@cdod);
      end;
      if HaveDynamicObject.boRegisted = false then begin
         HaveDynamicObject.StartProcess;
      end;
   end;
end;

function TObjectChecker.GetCurInfo : String;
var
   i, iCount : Integer;
   DynamicObject : TDynamicObject;
   Str : String;
begin
   Result := '';

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.Status = dos_Openned then begin
         Inc (iCount);
      end;
   end;

   Str := format ('ºüÀê»ð(%d) ', [iCount]);
   if HaveMonster = nil then begin
      Str := Str + 'ËÀÀÇÅ®(nil) ';
   end else begin
      if HaveMonster.boRegisted = true then begin
         Str := Str + 'ËÀÀÇÅ®(Registed) ';
      end else begin
         Str := Str + 'ËÀÀÇÅ®(UnRegisted) ';
      end;
   end;
   if HaveDynamicObject = nil then begin
      Str := Str + 'Ñý»ª(nil) ';
   end else begin
      if HaveMonster.boRegisted = true then begin
         Str := Str + 'Ñý»ª(Registed) ';
      end else begin
         Str := Str + 'Ñý»ª(UnRegisted) ';
      end;
   end;

   Result := Str;
end;

// TSoundObj
constructor TSoundObj.Create;
begin
   inherited Create;

   SoundName := '';

   UpdatedTick := 0;
   PlayedTick := 0;
   PlayInterval := 0;
end;

destructor TSoundObj.Destroy;
begin
   inherited Destroy;
end;

procedure TSoundObj.Initial (pd : PTCreateSoundObjData);
begin
   inherited Initial (pd^.Name, '');

   BasicData.id := GetNewItemId;

   BasicData.x := pd^.X;
   BasicData.y := pd^.Y;
   BasicData.nx := pd^.X;
   BasicData.ny := pd^.Y;
   BasicData.ClassKind := CLASS_SERVEROBJ;
   BasicData.Feature.rRace := RACE_ITEM;
   BasicData.Feature.rImageNumber := 0;
   BasicData.Feature.rImageColorIndex := 0;

   SoundName := pd^.SoundName;

   UpdatedTick := 0;
   PlayedTick := 0;
   PlayInterval := pd^.PlayInterval;
end;

procedure TSoundObj.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TSoundObj.EndProcess;
var
   SubData : TSubData;
begin
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

function TSoundObj.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
begin
   Result := PROC_FALSE;

   if isRangeMessage (hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;
end;

procedure TSoundObj.Update (CurTick: integer);
var
   i, iCount : Integer;
   xx, yy : Word;
   BasicObject : TBasicObject;
   SubData : TSubData;
begin
   if CurTick < UpdatedTick + 100 then exit;
   UpdatedTick := CurTick;

   if CurTick >= PlayedTick + PlayInterval then begin
      SetWordString (SubData.SayString, SoundName + '.wav'); 
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
      PlayedTick := CurTick;
   end;
end;

// TSoundObjList
constructor TSoundObjList.Create;
begin
   DataList := TList.Create;
   LoadFromFile ('.\Setting\CreateSoundObject.SDB');
end;

destructor TSoundObjList.Destroy;
begin
   Clear;
   DataList.Free;
   
   inherited Destroy;
end;

procedure TSoundObjList.Clear;
var
   i : Integer;
   SoundObj : TSoundObj;
begin
   for i := 0 to DataList.Count - 1 do begin
      SoundObj := DataList.Items [i];
      SoundObj.EndProcess;
      SoundObj.Free;
   end;

   DataList.Clear;
end;

function TSoundObjList.LoadFromFile (aFileName : String) : Boolean;
var
   i : Integer;
   iName : String;
   DB : TUserStringDB;
   SoundObj : TSoundObj;
   csod : TCreateSoundObjData;
   Manager : TManager;
begin
   Result := false;

   if not FileExists (aFileName) then exit;

   DB := TUserStringDB.Create;
   DB.LoadFromFile (aFileName);
   for i := 0 to DB.Count - 1 do begin
      iName := DB.GetIndexName (i);
      if iName = '' then continue;

      csod.Name := iName;
      csod.SoundName := DB.GetFieldValueString (iName, 'SoundName');
      csod.MapID := DB.GetFieldValueInteger (iName, 'MapID');
      csod.X := DB.GetFieldValueInteger (iName, 'X');
      csod.Y := DB.GetFieldValueInteger (iName, 'Y');
      csod.PlayInterval := DB.GetFieldValueInteger (iName, 'PlayInterval');

      Manager := ManagerList.GetManagerByServerID (csod.MapID);
      if Manager <> nil then begin
         SoundObj := TSoundObj.Create;
         SoundObj.SetManagerClass (Manager);
         SoundObj.Initial (@csod);
         SoundObj.StartProcess;

         DataList.Add (SoundObj);
      end;
   end;
   DB.Free;

   Result := true;
end;

procedure TSoundObjList.Update (CurTick : Integer);
var
   i : Integer;
   SoundObj : TSoundObj;
begin
   for i := 0 to DataList.Count - 1 do begin
      SoundObj := DataList.Items [i];
      SoundObj.Update (CurTick);
   end;
end;


end.

unit BasicObj;

interface

uses
  Windows, Classes, SysUtils, svClass, SubUtil, uAnsTick, AnsUnit,
  FieldMsg, MapUnit, DefType, Autil32, uManager, AnsStringCls,
  uObjectEvent;

type
   TBasicObject = class
   private
      FCreateTick : integer;
      FCreateX, FCreateY : integer;
      function  GetPosx: integer;
      function  GetPosy: integer;
      function  GetFeatureState: TFeatureState;
   protected
      FboRegisted : Boolean;
      FboAllowDelete : Boolean;
      FboHaveGuardPos : Boolean;

      FAlarmTick : Integer;      
      
      function  isRange (xx, yy: word) : Boolean;
      function  isRangeMessage (hfu: Longint; Msg: word; var SenderInfo: TBasicData): Boolean;
      function  FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; dynamic;
      function  GetViewObjectById (aid: integer): TBasicObject;

      function  isHitedArea (adir, ax, ay: integer; afunc: byte; var apercent: integer) : Boolean;
      function  GetViewObjectByName (aName: string; aRace: integer): TBasicObject;
      procedure Initial (aName, aViewName : string);
      procedure StartProcess; dynamic;
      procedure EndProcess; dynamic;

      procedure BocChangeFeature;

      procedure BoSysopMessage (astr: string; aSysopScope: integer);
   public
      procedure SetManagerClass (aManager : TManager);
      function  SendLocalMessage (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
      procedure BocSay (astr: string);      
   public
      Manager : TManager;
      Maper : TMaper;
      Phone : TFieldPhone;
      ServerID : Integer;

      BasicData : TBasicData;                         // 傍侩函荐
      ViewObjectList : TList;

      constructor Create;
      destructor  Destroy; override;
      procedure   Update (CurTick: integer); dynamic;
      procedure   BocChangeProperty;

      function    FindViewObject (aBasicObject : TBasicObject) : Boolean;

      property    PosX : integer read GetPosX;
      property    PosY : integer read GetPosY;
      property    CreateX : integer read FCreateX;
      property    CreateY : integer read FCreateY;
      property    CreateTick : integer read FCreateTick;
      property    boAllowDelete: Boolean read FboAllowDelete write FboAllowDelete;
      property    boRegisted : Boolean read FboRegisted;
      property    State : TFeatureState read GetFeatureState;
   end;

   TItemObject = class (TBasicObject)
    private
     SelfItemData : TItemData;
     OwnerId : Integer;
     boAllowPickup : Boolean;
    protected
     procedure   Initial (aItemData: TItemData; aOwnerId, ax, ay: integer);
     procedure   StartProcess; override;
     procedure   EndProcess; override;
     function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
    public
     constructor Create;
     destructor  Destroy; override;
     procedure   Update (CurTick: integer); override;

     property    AllowPickUp : Boolean read boAllowPickup;
   end;

   TItemList = class
   private
      Manager : TManager;

      DataList : TList;
      // function  AllocFunction: pointer;
      // procedure FreeFunction (item: pointer);
      function  GetCount: integer;
   public
      constructor Create (cnt: integer; aManager : TManager);
      destructor  Destroy; override;

      procedure   AllClear;
      procedure   AddItemObject (aItemData: TItemData; aOwnerId, ax, ay: integer);
      procedure   Update (CurTick: integer);
      property    Count : integer read GetCount;
   end;

   TGateObject = class (TBasicObject)
   private
      SelfData : TCreateGateData;

      boActive : Boolean;
      RegenedTick : Integer;
      RemainHour, RemainMin, RemainSec : Word;
   protected
      procedure   Initial;
      procedure   StartProcess; override;
      procedure   EndProcess; override;
      function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor  Destroy; override;

      procedure   Update (CurTick : Integer); override;

      function    GetSelfData : PTCreateGateData;
   end;

   TGateList = class
   private
      DataList : TList;
      
      function  GetCount: integer;
   public
      constructor Create;
      destructor  Destroy; override;

      procedure   Clear;
      procedure   LoadFromFile (aFileName : String);

      procedure   Update (CurTick: integer);

      procedure   SetBSGateActive (boFlag : Boolean);

      property    Count : integer read GetCount;
   end;

   TMirrorObject = class (TBasicObject)
   private
      SelfData : TCreateMirrorData;

      ViewerList : TList;

      boActive : Boolean;
   protected
      procedure   Initial;
      procedure   StartProcess; override;
      procedure   EndProcess; override;
      function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
   public
      constructor Create;
      destructor  Destroy; override;

      procedure   AddViewer (aUser : Pointer);
      function    DelViewer (aUser : Pointer) : Boolean;

      procedure   Update (CurTick : Integer); override;

      function    GetSelfData : PTCreateMirrorData;
   end;

   TMirrorList = class
   private
      DataList : TList;

      function  GetCount: integer;
   public
      constructor Create;
      destructor  Destroy; override;

      function    AddViewer (aStr : String; aUser : Pointer) : Boolean;
      function    DelViewer (aUser : Pointer) : Boolean;

      procedure   Clear;
      procedure   LoadFromFile (aFileName : String);

      procedure   Update (CurTick: integer);

      property    Count : integer read GetCount;
   end;

   TStaticItem = class (TBasicObject)
    private
      CurDurability : integer;
      SelfItemData : TItemData;
      OwnerId : Integer;
    protected
      procedure   Initial (aItemData: TItemData; aOwnerId, ax, ay: integer);
      procedure   StartProcess; override;
      procedure   EndProcess; override;
      function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
    public
      constructor Create;
      destructor  Destroy; override;
      procedure   Update (CurTick: integer); override;
   end;

   TStaticItemList = class
   private
      Manager : TManager;
      DataList : TList;
      // function  AllocFunction: pointer;
      // procedure FreeFunction (item: pointer);
      function  GetCount: integer;
   public
      constructor Create (cnt: integer; aManager: TManager);
      destructor  Destroy; override;

      procedure   Clear;

      function    AddStaticItemObject (aItemData: TItemData; aOwnerId, ax, ay: integer): integer;
      procedure   Update (CurTick: integer);
      property    Count : integer read GetCount;
   end;

   TDynamicObject = class (TBasicObject)
    private
     SelfData : TCreateDynamicObjectData;

     CurLife : Integer;
     EventItemCount : Integer;
     DragDropEvent : TDragDropEvent;

     MemberList : TList;
    protected
     function    FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer; override;
    public
     OpenedTick : Integer;
     OpenedPosX, OpenedPosY : Word;
     ObjectStatus : TDynamicObjectState;
    public
     constructor Create;
     destructor  Destroy; override;

     procedure   Initial (pObjectData: PTCreateDynamicObjectData);
     procedure   StartProcess; override;
     procedure   EndProcess; override;

     procedure   Update (CurTick: integer); override;
     procedure   MemberDie (aBasicObject : TBasicObject);

     property    Status : TDynamicObjectState read ObjectStatus;
   end;

   TDynamicObjectList = class
   private
      Manager : TManager;

      DataList : TList;

      function  GetCount: integer;
   public
      constructor Create (cnt: integer; aManager: TManager);
      destructor  Destroy; override;

      procedure   Clear;
      procedure   ReLoadFromFile;

      function    AddDynamicObject (pObjectData: PTCreateDynamicObjectData): integer;
      function    DeleteDynamicObject (aName : String) : Boolean;
      function    FindDynamicObject (aName : STring) : Integer;

      function    GetDynamicObjects (aName : String; aList : TList) : Integer;
      
      procedure   Update (CurTick: integer);

      property    Count : integer read GetCount;
   end;

   procedure SignToItem (var aItemData : TItemData;aServerID : Integer; var aBasicData : TBasicData; aIP : String);

var
   boShowHitedValue : Boolean = FALSE;
   boShowGuildDuraValue : Boolean = FALSE;

   GateList : TGateList = nil;
   MirrorList : TMirrorList = nil;

implementation

uses
   SvMain, uUser, uNpc, uMonster, uSkills, uLevelExp, UserSDB;

///////////////////////////////
//        TBasicObject
///////////////////////////////

constructor TBasicObject.Create;
begin
   FillChar (BasicData, sizeof(BasicData), 0);
   BasicData.P := Self;
   ViewObjectList := TList.Create;
   // ViewObjectNameList := TStringList.Create;
end;

destructor TBasicObject.Destroy;
var
   i : Integer;
begin
   ViewObjectList.Free;
   // ViewObjectNameList.Free;
   inherited Destroy;
end;

function TBasicObject.FindViewObject (aBasicObject : TBasicObject) : Boolean;
var
   i : Integer;
   BasicObject : TBasicObject;
begin
   Result := false;
   for i := 0 to ViewObjectList.Count - 1 do begin
      BasicObject := ViewObjectList.Items [i];
      if BasicObject = aBasicObject then begin
         Result := true;
         exit;
      end;
   end;
end;

function Check5Hit (adir, ax, ay, myx, myy: integer): integer;
var
   tempdir : byte;
   xx, yy: word;
begin
   Result := 0;

   tempdir := adir;
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 100; exit; end;   //99

   tempdir := adir;
   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;    //90

   tempdir := adir;
   tempdir := GetLeftDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;    //90


   tempdir := adir;
   tempdir := GetRightDirection (tempdir);
   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;     //80

   tempdir := adir;
   tempdir := GetLeftDirection (tempdir);
   tempdir := GetLeftDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;     //80
end;

function Check8Hit (adir, ax, ay, myx, myy: integer): integer;
var
   tempdir : byte;
   xx, yy: word;
begin
   Result := 0;

   tempdir := adir;
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 100; exit; end;      //100

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //70

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //70

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //85

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //85

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //85

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //85

   tempdir := GetRightDirection (tempdir);
   xx := ax; yy := ay;
   GetNextPosition (tempdir, xx, yy);
   if (myx = xx) and (myy = yy) then begin Result := 99; exit; end;       //85
end;

function  TBasicObject.isHitedArea (adir, ax, ay: integer; afunc: byte; var apercent: integer) : Boolean;
var
   xx, yy: word;
begin
   apercent := 0;
   Result := FALSE;
   case afunc of
      MAGICFUNC_NONE   :
         begin
            xx := ax; yy := ay;
            GetNextPosition (adir, xx, yy);
            if (BasicData.x = xx) and (BasicData.y = yy) then begin
               apercent := 100;
               Result := TRUE;
            end;
         end;
      MAGICFUNC_8HIT   :
         begin
            if GetLargeLength (ax, ay, BasicData.x, BasicData.y) > 1 then exit;
            apercent := Check8Hit (adir, ax, ay, BasicData.x, BasicData.y);
            if apercent = 0 then exit;
            Result := TRUE;
         end;
      MAGICFUNC_5HIT   :
         begin
            if GetLargeLength (ax, ay, BasicData.x, BasicData.y) > 1 then exit;
            apercent := Check5Hit (adir, ax, ay, BasicData.x, BasicData.y);
            if apercent = 0 then exit;
            Result := TRUE;
         end;
   end;
end;

procedure TBasicObject.SetManagerClass (aManager : TManager);
begin
   Manager := aManager;
   ServerID := Manager.ServerID;
   Maper := TMaper(Manager.Maper);
   Phone := TFieldPhone (Manager.Phone);
end;

function  TBasicObject.GetPosX: integer;
begin
   Result := BasicData.x;
end;

function  TBasicObject.GetPosY: integer;
begin
   Result := BasicData.y;
end;

function  TBasicObject.GetFeatureState: TFeatureState;
begin
   Result := BasicData.Feature.rfeaturestate;
end;

procedure TBasicObject.Initial (aName, aViewName: String);
begin
   FillChar (BasicData, sizeof(BasicData), 0);
   BasicData.P := Self;
   StrPCopy (@BasicData.Name, aName);
   StrPCopy (@BasicData.ViewName, aViewName);

   BasicData.LifePercent := 100;
   
   FboAllowDelete := FALSE;
   FboRegisted := FALSE;
   FboHaveGuardPos := FALSE;

   FCreateX := 0; FCreateY := 0;
end;

procedure TBasicObject.StartProcess;
begin
   FboRegisted := TRUE;
   FboAllowDelete := FALSE;
   
   BasicData.dir := DR_4;
   BasicData.Feature.rfeaturestate := wfs_normal;

   FCreateX := BasicData.x;
   FCreateY := BasicData.y;
   FCreateTick := mmAnsTick;
   FAlarmTick := 0;

   ViewObjectList.Clear;
end;

procedure TBasicObject.EndProcess;
begin
   ViewObjectList.Clear;

   FboRegisted := FALSE;
end;

function TBasicObject.GetViewObjectById (aid: integer): TBasicObject;
var i : integer;
begin
   Result := nil;
   for i := 0 to ViewObjectList.Count - 1 do begin
      if TBasicObject (ViewobjectList[i]).BasicData.id = aid then begin
         Result := ViewObjectList[i];
         exit;
      end;
   end;
end;

// function    TBasicObject.GetViewObjectByName (aName: string; aRace: integer): TBasicObject;
// 2000.09.18 鞍篮 捞抚狼 按眉啊 乐阑锭 惯积登绰 滚弊荐沥阑 困秦 牢磊眠啊
// 茫栏妨绰 按眉狼 捞抚苞 辆幅肺 八祸茄促 by Lee.S.G
function    TBasicObject.GetViewObjectByName (aName: string; aRace: integer): TBasicObject;
var
   i : integer;
   BObject: TBasicObject;
begin
   Result := nil;
   for i := 0 to ViewObjectList.Count -1 do begin
      BObject := ViewObjectList[i];
      if (BObject.BasicData.Feature.rRace = aRace) and (StrPas (@BObject.BasicData.Name) = aName) then begin
         Result := BObject;
         exit;
      end;
   end;
end;

procedure   TBasicObject.BocSay (astr: string);
var SubData : TSubData;
begin
   SetWordString (SubData.SayString, StrPas (@BasicData.ViewName) + ': '+ astr);
   SendLocalMessage (NOTARGETPHONE, FM_SAY, BasicData, SubData);
end;

procedure   TBasicObject.BocChangeFeature;
var SubData : TSubData;
begin
   SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
end;

procedure   TBasicObject.BocChangeProperty;
var SubData : TSubData;
begin
   SendLocalMessage (NOTARGETPHONE, FM_CHANGEPROPERTY, BasicData, SubData);
end;

procedure   TBasicObject.BoSysopMessage (astr: string; aSysopScope: integer);
var SubData : TSubData;
begin
   if not boShowHitedValue then exit;

   SetWordString (SubData.SayString, StrPas (@BasicData.ViewName) + ': '+ astr);
   SubData.SysopScope := aSysopScope;
   SendLocalMessage (NOTARGETPHONE, FM_SYSOPMESSAGE, BasicData, SubData);
end;

function    TBasicObject.SendLocalMessage (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i : integer;
   Bo : TBasicObject;
begin
   Result := PROC_FALSE;

   if hfu = 0 then begin
      Result := FieldProc (hfu, Msg, SenderInfo, aSubData);
      {
      for i := 0 to ViewObjectList.Count -1 do begin
         Bo := ViewObjectList[i];
         if Bo <> Self then begin
            Bo.FieldProc (hfu, Msg, SenderInfo, aSubData)
         end;
      end;
      }
      i := 0;
      while i < ViewObjectList.Count do begin
         Bo := ViewObjectList[i];
         try
            if Bo <> Self then begin
               Bo.FieldProc (hfu, Msg, SenderInfo, aSubData)
            end;
            Inc (i);
         except
            {
            frmMain.WriteLogInfo (format ('TBasicObject.SendLocalMessage (%s) failed', [ViewObjectNameList[i]]));
            ViewObjectNameList.Delete (i);
            }
            ViewObjectList.Delete (i);
            frmMain.WriteLogInfo (format ('TBasicObject.SendLocalMessage (%s) failed', [StrPas (@BasicData.Name)]));
         end;
      end;

   end else begin
      for i := 0 to ViewObjectList.Count -1 do begin
         Bo := ViewObjectList[i];
         try
            if Bo.BasicData.id = hfu then begin
               result := Bo.FieldProc (hfu, Msg, SenderInfo, aSubData);
               exit;
            end;
         except
            {
            frmMain.WriteLogInfo (format ('TBasicObject.SendLocalMessage (%s) failed', [ViewObjectNameList[i]]));
            ViewObjectNameList.Delete (i);
            }
            ViewObjectList.Delete (i);
            frmMain.WriteLogInfo (format ('TBasicObject.SendLocalMessage (%s) failed', [StrPas (@BasicData.Name)]));
            exit;
         end;
      end;
   end;
end;

function  TBasicObject.isRange ( xx, yy: word) : Boolean;
var x1,x2,y1,y2:integer;
begin
   Result := TRUE;
   x1 := BasicData.x; y1 := BasicData.y;
   x2 := xx; y2 := yy;
   if (x2 < x1-VIEWRANGEWIDTH) then begin Result := FALSE; exit; end;
   if (x2 > x1+VIEWRANGEWIDTH) then begin Result := FALSE; exit; end;
   if (y2 < y1-VIEWRANGEHEIGHT) then begin Result := FALSE; exit; end;
   if (y2 > y1+VIEWRANGEHEIGHT) then begin Result := FALSE; exit; end;
end;

function  TBasicObject.isRangeMessage (hfu: Longint; Msg: word; var SenderInfo: TBasicData): Boolean;
begin
   Result := FALSE;
   if (hfu = BasicData.id) then begin Result := TRUE; exit; end;
   if hfu = NOTARGETPHONE then begin
      if isRange ( SenderInfo.x, SenderInfo.y) then begin Result := TRUE; exit; end;
      if (msg = FM_MOVE) and isRange (SenderInfo.nx, SenderInfo.ny) then begin Result := TRUE; exit; end;
   end;
   if Msg = FM_SHOUT then Result := TRUE;
end;

function  TBasicObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i : integer;
   BasicObject : TBasicObject;
   SubData : TSubData;
   bo1, bo2 : boolean;
begin
   Result := PROC_FALSE;

   if not FboRegisted then begin
      frmMain.WriteLogInfo ('UnRegisted BasicObject.FieldProc was called');
      exit;
   end;

   case Msg of
      FM_GIVEMEADDR : if hfu = BasicData.id then Result := Integer (Self);

      FM_CLICK : if hfu = BasicData.id then SetWordString (aSubData.SayString, StrPas (@BasicData.viewName));
      FM_SHOW :
         begin
            if SenderInfo.id = Basicdata.id then begin
               ViewObjectList.Clear;
               // ViewObjectNameList.Clear;
            end;

            if FindViewObject (SenderInfo.P) = true then begin
               frmMain.WriteLogInfo ('ViewObjectList Duplicate');
               exit;
            end;

            if SenderInfo.Feature.rrace = RACE_HUMAN then begin
               ViewObjectList.Insert (0, SenderInfo.p);
               // ViewObjectNameList.Insert (0, StrPas (@SenderInfo.Name));
            end else begin
               ViewObjectList.Add (SenderInfo.p);
               // ViewObjectNameList.Add (StrPas (@SenderInfo.Name));
            end;
         end;
      FM_HIDE :
         begin
            for i := 0 to ViewObjectList.Count - 1 do begin
               if ViewObjectList[i] = SenderInfo.P then begin
                  ViewObjectList.Delete (i);
                  // ViewObjectNameList.Delete (i);
                  break;
               end;
            end;
         end;
      FM_CREATE :
         begin
            Phone.SendMessage ( BasicData.Id, FM_SHOW, SenderInfo, aSubData);
            if SenderInfo.Id = BasicData.id then begin
               BasicData := SenderInfo;
               if (BasicData.Feature.rRace = RACE_HUMAN) and (BasicData.Feature.rfeaturestate = wfs_die) then exit;
               Maper.MapProc ( BasicData.Id, MM_SHOW, BasicData.x, BasicData.y, BasicData.x, BasicData.y, BasicData);
            end else begin
               Result := PROC_TRUE;
               Phone.SendMessage ( SenderInfo.Id, FM_SHOW, BasicData, SubData);
            end;
         end;
      FM_DESTROY :
         begin
            if SenderInfo.Id = BasicData.id then
               Maper.MapProc (BasicData.Id, MM_HIDE, BasicData.x, BasicData.y, BasicData.x, BasicData.y, BasicData);
            Phone.SendMessage ( BasicData.Id, FM_HIDE, SenderInfo, aSubData);
         end;
      FM_MOVE:
         begin
            bo1 := isRange (SenderInfo.x, SenderInfo.y);
            bo2 := isRange (SenderInfo.nx, SenderInfo.ny);
            if (bo1 = TRUE) and (bo2 = FALSE) then begin
               Phone.SendMessage (SenderInfo.Id, FM_HIDE, BasicData, SubData);
               Phone.SendMessage (BasicData.id, FM_HIDE, SenderInfo, aSubData);
               exit;
            end;
            if (bo1 = FALSE) and (bo2 = TRUE) then begin
               Phone.SendMessage (SenderInfo.Id, FM_SHOW, BasicData, SubData);
               Phone.SendMessage (BasicData.ID, FM_SHOW, SenderInfo, aSubData);
               exit;
            end;
         end;
   end;
end;

procedure TBasicObject.Update(CurTick: integer);
begin
end;


////////////////////////////////////////////////////
//
//             ===  ItemObject  ===
//
////////////////////////////////////////////////////

constructor TItemObject.Create;
begin
   inherited Create;
   boAllowPickup := true;
end;

destructor  TItemObject.Destroy;
begin
   inherited destroy;
end;

function  TItemObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   SubData : TSubData;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   case Msg of
      FM_ADDITEM:
         begin
            if aSubData.ItemData.rCount <> 1 then exit;
            if SelfItemData.rKind = ITEM_KIND_COLORDRUG then exit;
            if SelfItemData.rKind = ITEM_KIND_CHANGER then exit;
            
            if aSubData.ItemData.rKind = ITEM_KIND_COLORDRUG then begin
               if SelfItemData.rboColoring = FALSE then begin Result := PROC_FALSE; exit; end;
               if INI_WHITEDRUG <> StrPas (@aSubData.ItemData.rName) then begin
                  SelfItemData.rColor := aSubData.ItemData.rColor;
                  BasicData.Feature.rImageColorIndex := aSubData.ItemData.rColor;
                  Phone.SendMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
               end else begin
                  SelfItemdata.rColor := SelfItemdata.rColor + aSubData.ItemData.rColor;
                  BasicData.Feature.rImageColorIndex := SelfItemdata.rColor;
                  Phone.SendMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
               end;
               Result := PROC_TRUE;
               exit;
            end;
            if aSubData.ItemData.rKind = ITEM_KIND_CHANGER then begin
               if StrPas (@BasicData.Name) <> aSubData.ItemData.rNameParam [0] then exit;
               FboAllowDelete := true;

               ItemClass.GetItemData (aSubData.ItemData.rNameParam [1], SubData.ItemData);
               if SubData.ItemData.rName [0] <> 0 then begin
                  BasicData.nX := BasicData.X;
                  BasicData.nY := BasicData.Y;
                  SubData.ServerId := Manager.ServerId;
                  Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
                  Result := PROC_TRUE;
               end;
               exit;
            end;
         end;
      FM_PICKUP :
         begin
            if FboAllowDelete then exit;
            {
            if boAllowPickup = false then begin
               if (SenderInfo.x <> BasicData.x) or (SenderInfo.y <> BasicData.y) then begin
                  exit;
               end;
            end;
            }

            SubData.ItemData := SelfItemData;
            SubData.ServerId := ServerId;
            if Phone.SendMessage (SenderInfo.id, FM_ADDITEM, BasicData, SubData) = PROC_TRUE then begin
               FboAllowDelete := TRUE;
            end;
         end;
      FM_SAY :
         begin
         end;
   end;
end;

procedure TItemObject.Initial (aItemData: TItemData; aOwnerId, ax, ay: integer);
var
   iName, iViewName : String;
begin
   iName := StrPas (@aItemData.rName);
   if aItemData.rCount > 1 then iName := iName + ':' + IntToStr (aItemData.rCount);
   iViewName := StrPas (@aItemData.rViewName);
   if aItemData.rCount > 1 then iViewName := iViewName + ':' + IntToStr (aItemData.rCount);

   inherited Initial (iName, iViewName);
   
   OwnerId := aOwnerId;
   SelfItemdata := aItemData;
   BasicData.id := GetNewItemId;
   BasicData.x := ax;
   BasicData.y := ay;
   BasicData.ClassKind := CLASS_ITEM;
   BasicData.Feature.rrace := RACE_ITEM;
   BasicData.Feature.rImageNumber := aItemData.rShape;
   BasicData.Feature.rImageColorIndex := aItemData.rcolor;

   {
   boAllowPickup := true;
   if not Maper.isMoveable (ax, ay) then begin
      boAllowPickup := false;
   end;
   }
end;

procedure TItemObject.StartProcess;
var SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);

   if SelfItemData.rSoundDrop.rWavNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (SelfItemData.rSoundDrop.rWavNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;
end;

procedure TItemObject.EndProcess;
var SubData : TSubData;
begin
   if FboRegisted = FALSE then exit;

   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);
   inherited EndProcess;
end;

procedure   TItemObject.Update (CurTick: integer);
var
   SubData : TSubData;
begin
   if CreateTick + 3 * 60 * 100 < CurTick then FboAllowDelete := TRUE;
   if CurTick >= FAlarmTick + 300 then begin
      SendLocalMessage (NOTARGETPHONE, FM_IAMHERE, BasicData, SubData);
   end;

   {
   if boAllowPickup = false then begin
      if CreateTick + 5*100 < CurTick then begin
         boAllowPickup := true;
      end;
   end;
   }
end;


////////////////////////////////////////////////////
//
//             ===  ItemList  ===
//
////////////////////////////////////////////////////

constructor TItemList.Create (cnt: integer; aManager: TManager);
begin
   Manager := aManager;
   DataList := TList.Create;
end;

destructor TItemList.Destroy;
begin
   AllClear;
   DataList.Free;
   inherited destroy;
end;

procedure TItemList.AllClear;
var
   i : Integer;
   ItemObject : TItemObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      ItemObject := DataList.Items [i];
      ItemObject.EndProcess;
      ItemObject.Free;
   end;
   DataList.Clear;
end;

function  TItemList.GetCount: integer;
begin
   Result := DataList.Count;
end;

procedure TItemList.AddItemObject (aItemData: TItemData; aOwnerId, ax, ay: integer);
var
   ItemObject : TItemObject;
begin
   if DataList.Count > 3000 then exit;

   ItemObject := TItemObject.Create;
   
   ItemObject.SetManagerClass (Manager);
   ItemObject.Initial (aItemData, aOwnerId, ax, ay);
   ItemObject.StartProcess;

   DataList.Add (ItemObject);
end;

procedure TItemList.Update (CurTick: integer);
var
   i : integer;
   ItemObject : TItemObject;
begin
   for i := DataList.Count - 1 downto 0 do begin
      ItemObject := DataList.Items [i];
      if ItemObject.boAllowDelete then begin
         ItemObject.EndProcess;
         ItemObject.Free;
         DataList.delete (i);
      end;
   end;
   
   for i := 0 to DataList.Count - 1 do begin
      ItemObject := DataList.Items [i];
      ItemObject.Update (CurTick);
   end;
end;

////////////////////////////////////////////////////
//
//             ===  GateObject  ===
//
////////////////////////////////////////////////////

constructor TGateObject.Create;
begin
   inherited Create;

   boActive := false;
   RegenedTick := mmAnsTick;

   FillChar (SelfData, SizeOf (TCreateGateData), 0);
end;

destructor TGateObject.Destroy;
begin
   inherited destroy;
end;

function TGateObject.GetSelfData : PTCreateGateData;
begin
   Result := @SelfData;
end;

function TGateObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i : Integer;
   SubData : TSubData;
   ItemData : TItemData;
   pUser : TUser;
   boFlag : Boolean;
   BO : TBasicObject;
   RetStr : String;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   case Msg of
      FM_MOVE :
         begin
            if (SelfData.Kind = GATE_KIND_NORMAL) and (BasicData.nx = 0) and (BasicData.ny = 0) then exit;

            if CheckInArea (SenderInfo.nx, SenderInfo.ny, BasicData.x, BasicData.y, SelfData.Width) then begin
               BO := TBasicObject (SenderInfo.P);
               if BO = nil then exit;
               if not (BO is TUser) then exit;
               pUser := TUser (BO);

               if pUser.MovingStatus = true then begin
                  exit;
               end;

               if boActive = false then begin
                  pUser.SetPosition (SelfData.EjectX, SelfData.EjectY);
                  Case SelfData.Kind of
                     GATE_KIND_NORMAL : pUser.SendClass.SendChatMessage (format ('现在无法进入.%d分%d秒后才会开启.', [RemainHour * 60 + RemainMin, RemainSec]), SAY_COLOR_SYSTEM);
                     GATe_KIND_BS : pUser.SendClass.SendChatMessage (format ('现在无法进入.', [RemainHour * 60 + RemainMin, RemainSec]), SAY_COLOR_SYSTEM);
                  end;
                  exit;
               end;

               boFlag := true;
               if SelfData.NeedAge > 0 then begin
                  if SelfData.NeedAge <= pUser.GetAge then begin
                  end else begin
                     if SelfData.AgeNeedItem > 0 then begin
                        if SelfData.AgeNeedItem <= pUser.GetAge then begin
                           for i := 0 to 5 - 1 do begin
                              if SelfData.NeedItem[i].rName = '' then break;
                              ItemClass.GetItemData (SelfData.NeedItem[i].rName, ItemData);
                              if ItemData.rName[0] <> 0 then begin
                                 ItemData.rCount := SelfData.NeedItem[i].rCount;
                                 boFlag := TUser (BO).FindItem (@ItemData);
                                 if boFlag = false then break;
                              end;
                           end;
                           if boFlag = true then begin
                              for i := 0 to 5 - 1 do begin
                                 if SelfData.NeedItem[i].rName = '' then break;
                                 ItemClass.GetItemData (SelfData.NeedItem[i].rName, ItemData);
                                 if ItemData.rName[0] <> 0 then begin
                                    ItemData.rCount := SelfData.NeedItem[i].rCount;
                                    TUser (BO).DeleteItem (@ItemData);
                                 end;
                              end;
                           end;
                        end else begin
                           boFlag := false;
                        end;
                     end else begin
                        boFlag := false;
                     end;
                  end;
               end;
               
               if boFlag = true then begin
                  if SelfData.Quest <> 0 then begin
                     if QuestClass.CheckQuestComplete (SelfData.Quest, ServerID, RetStr) = false then begin
                        pUser.SetPosition (SelfData.EjectX, SelfData.EjectY);
                        pUser.SendClass.SendChatMessage (SelfData.QuestNotice, SAY_COLOR_SYSTEM);
                        pUser.SendClass.SendChatMessage (RetStr, SAY_COLOR_SYSTEM);
                        exit;
                     end;
                  end;
               end;
               
               if boFlag = true then begin
                  Case SelfData.Kind of
                     GATE_KIND_NORMAL :
                        begin
                           SubData.ServerId := SelfData.TargetServerId;
                           Phone.SendMessage (SenderInfo.id, FM_GATE, BasicData, SubData);
                        end;
                     GATE_KIND_BS :
                        begin
                           pUser.SetPositionBS (SelfData.EjectX, SelfData.EjectY);
                        end;
                  end;
               end else begin
                  if (SelfData.EjectX > 0) and (SelfData.EjectY > 0) then begin
                     pUser.SetPosition (SelfData.EjectX, SelfData.EjectY);
                  end;
                  if SelfData.EjectNotice = '' then begin
                     pUser.SendClass.SendChatMessage ('无法进入.此处为限制出入的地方.', SAY_COLOR_SYSTEM);
                  end else begin
                     pUser.SendClass.SendChatMessage (SelfData.EjectNotice, SAY_COLOR_SYSTEM);
                  end;
               end;
            end;
         end;
   end;
end;

procedure TGateObject.Initial;
var
   iNo : Integer;
begin
   inherited Initial (SelfData.Name, SelfData.ViewName);

   BasicData.id := GetNewItemId;

   if (SelfData.X <> 0) or (SelfData.Y <> 0) then begin
      BasicData.x := SelfData.x;
      BasicData.y := SelfData.y;
   end else begin
      iNo := Random (SelfData.RandomPosCount);
      BasicData.X := SelfData.RandomX [iNo];
      BasicData.Y := SelfData.RandomY [iNo];
   end;

   BasicData.nx := SelfData.targetx;
   BasicData.ny := SelfData.targety;
   BasicData.ClassKind := CLASS_GATE;
   BasicData.Feature.rrace := RACE_ITEM;
   BasicData.Feature.rImageNumber := SelfData.Shape;
   BasicData.Feature.rImageColorIndex := 0;

   boActive := true;
   RegenedTick := mmAnsTick;
end;

procedure TGateObject.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TGateObject.EndProcess;
var
   SubData : TSubData;
begin
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

procedure TGateObject.Update (CurTick : Integer);
begin
   if (SelfData.RegenInterval > 0) and (RegenedTick + 100 <= CurTick) then begin
      Manager.CalcTime (RegenedTick + SelfData.RegenInterval - CurTick, RemainHour, RemainMin, RemainSec);
   end;
   if (SelfData.RegenInterval > 0) and (RegenedTick + SelfData.RegenInterval <= CurTick) then begin
      RegenedTick := CurTick;
      boActive := true;
   end else begin
      if (SelfData.X = 0) and (SelfData.Y = 0) then begin
         if CurTick >= RegenedTick + SelfData.ActiveInterval then begin
            EndProcess;
            Initial;
            StartProcess;
         end;
         exit;
      end;
      if boActive = true then begin
         if (SelfData.RegenInterval > 0) and (RegenedTick + SelfData.ActiveInterval <= CurTick) then begin
            boActive := false;
         end;
      end;
   end;
end;

////////////////////////////////////////////////////
//
//             ===  GateList  ===
//
////////////////////////////////////////////////////

constructor TGateList.Create;
begin
   DataList := TList.Create;

   LoadFromFile ('.\Setting\CreateGate.SDB');
end;

destructor TGateList.Destroy;
begin
   Clear;
   DataList.Free;
   
   inherited Destroy;
end;

procedure TGateList.Clear;
var
   i : Integer;
   GateObject : TGateObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      GateObject := DataList.Items [i];
      if GateObject.boRegisted then begin
         GateObject.EndProcess;
      end;
      GateObject.Free;
   end;
   DataList.Clear;
end;

function TGateList.GetCount: integer;
begin
   Result := DataList.Count;
end;

procedure TGateList.LoadFromFile (aFileName : String);
var
   i, j, xx, yy : integer;
   iName, srcstr, tokenstr : String;
   ItemData : TItemData;
   GateObject : TGateObject;
   pd : PTCreateGateData;
   DB : TUserStringDB;
   Manager : TManager;
begin
   if not FileExists (aFileName) then exit;

   DB := TUserStringDb.Create;
   DB.LoadFromFile (aFileName);

   for i := 0 to DB.Count - 1 do begin
      iName := DB.GetIndexName (i);

      GateObject := TGateObject.Create;
      pd := GateObject.GetSelfData;

      pd^.Name := DB.GetFieldValueString (iName, 'GateName');
      pd^.ViewName := DB.GetFieldValueString (iName, 'ViewName');
      pd^.Kind := DB.GetFieldValueInteger (iname, 'Kind');
      pd^.MapID := DB.GetFieldValueInteger (iname, 'MapID');
      pd^.x := DB.GetFieldValueInteger (iName, 'X');
      pd^.y := DB.GetFieldValueInteger (iName, 'Y');
      pd^.targetx := DB.GetFieldValueInteger (iName, 'TX');
      pd^.targety := DB.GetFieldValueInteger (iName, 'TY');
      pd^.ejectx := DB.GetFieldValueInteger (iName, 'EX');
      pd^.ejecty := DB.GetFieldValueInteger (iName, 'EY');
      pd^.targetserverid := DB.GetFieldValueInteger (iName, 'ServerId');
      pd^.shape := DB.GetFieldValueInteger (iName, 'Shape');
      pd^.Width := DB.GetFieldValueInteger (iName, 'Width');

      pd^.NeedAge := DB.GetFieldValueInteger (iName, 'NeedAge');
      pd^.AgeNeedItem := DB.GetFieldValueInteger (iName, 'AgeNeedItem');

      srcstr := DB.GetFieldValueString (iName, 'NeedItem');
      if srcstr <> '' then begin
         for j := 0 to 5 - 1 do begin
            srcstr := GetValidStr3 (srcstr, tokenstr, ':');
            if tokenstr = '' then break;
            ItemClass.GetItemData (tokenstr, ItemData);
            if ItemData.rName[0] <> 0 then begin
               srcstr := GetValidStr3 (srcstr, tokenstr, ':');
               ItemData.rCount := _StrToInt (tokenstr);
               pd^.NeedItem[j].rName := StrPas (@ItemData.rName);
               pd^.NeedItem[j].rCount := ItemData.rCount;
            end;
         end;
      end;
      pd^.Quest := DB.GetFieldValueInteger (iname, 'Quest');
      pd^.QuestNotice := DB.GetFieldValueString (iname, 'QuestNotice');
      pd^.RegenInterval := DB.GetFieldValueInteger (iName, 'RegenInterval');
      pd^.ActiveInterval := DB.GetFieldValueInteger (iName, 'ActiveInterval');
      pd^.EjectNotice := DB.GetFieldValueString (iname, 'EjectNotice');

      if (pd^.X = 0) and (pd^.Y = 0) then begin
         pd^.RandomPosCount := 0;
         srcstr := DB.GetFieldValueString (iName, 'RandomPos');
         for j := 0 to 10 - 1 do begin
            srcstr := GetValidStr3 (srcstr, tokenstr, ':');
            xx := _StrToInt (tokenstr);
            srcstr := GetValidStr3 (srcstr, tokenstr, ':');
            yy := _StrToInt (tokenstr);
            if (xx = 0) or (yy = 0) then break;
            pd^.RandomX[j] := xx;
            pd^.RandomY[j] := yy;
            Inc (pd^.RandomPosCount);
         end;
      end;

      Manager := ManagerList.GetManagerByServerID (pd^.MapID);
      if Manager <> nil then begin
         GateObject.SetManagerClass (Manager);
         GateObject.Initial;
         GateObject.StartProcess;
         DataList.Add (GateObject);
      end else begin
         GateObject.Free;
      end;
   end;
   DB.Free;
end;

procedure TGateList.Update (CurTick: integer);
var
   i: integer;
   GateObject : TGateObject;
begin
   for i := DataList.Count - 1 downto 0 do begin
      GateObject := DataList.Items [i];
      if GateObject.boAllowDelete then begin
         GateObject.EndProcess;
         GateObject.Free;
         DataList.Delete (i);
      end;
   end;
   
   for i := 0 to DataList.Count - 1 do begin
      GateObject := DataList.Items [i];
      GateObject.Update (CurTick);
   end;
end;

procedure TGateList.SetBSGateActive (boFlag : Boolean);
var
   i: integer;
   GateObject : TGateObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      GateObject := DataList.Items [i];
      if GateObject.SelfData.Kind = GATE_KIND_BS then begin
         GateObject.boActive := boFlag;
      end;
   end;
end;

////////////////////////////////////////////////////
//
//             ===  MirrorObject  ===
//
////////////////////////////////////////////////////

constructor TMirrorObject.Create;
begin
   inherited Create;

   ViewerList := TList.Create;
   
   FillChar (SelfData, SizeOf (TCreateMirrorData), 0);
   boActive := false;
end;

destructor TMirrorObject.Destroy;
begin
   ViewerList.Free;
   
   inherited Destroy;
end;

procedure TMirrorObject.AddViewer (aUser : Pointer);
var
   i : Integer;
begin
   if ViewerList.IndexOf (aUser) >= 0 then exit;
   ViewerList.Add (aUser);

   TUser (aUser).SendClass.SendMap (BasicData, Manager.MapName, Manager.ObjName, Manager.RofName, Manager.TilName, Manager.SoundBase);
   for i := 0 to ViewObjectList.Count - 1 do begin
      TUser (aUser).SendClass.SendShow (TBasicObject (ViewObjectList[i]).BasicData);
   end;
end;

function TMirrorObject.DelViewer (aUser : Pointer) : Boolean;
var
   i, iNo : Integer;
   tmpManager : TManager;
   tmpViewObjectList : TList;
begin
   Result := false;

   iNo := ViewerList.IndexOf (aUser);
   if iNo < 0 then exit;

   tmpManager := TUser (aUser).Manager;
   tmpViewObjectList := TUser (aUser).ViewObjectList;

   TUser (aUser).SendClass.SendMap (TUser (aUser).BasicData, tmpManager.MapName, tmpManager.ObjName, tmpManager.RofName, tmpManager.TilName, tmpManager.SoundBase);
   for i := 0 to tmpViewObjectList.Count - 1 do begin
      TUser (aUser).SendClass.SendShow (TBasicObject (tmpViewObjectList[i]).BasicData);
   end;

   ViewerList.Delete (iNo);

   Result := true;
end;

procedure TMirrorObject.Initial;
begin
   inherited Initial (SelfData.Name, SelfData.Name);

   BasicData.id := GetNewItemId;
   BasicData.x := SelfData.X;
   BasicData.y := SelfData.Y;
   BasicData.ClassKind := CLASS_SERVEROBJ;
   BasicData.Feature.rrace := RACE_ITEM;
   BasicData.Feature.rImageNumber := 0;
   BasicData.Feature.rImageColorIndex := 0;

   boActive := SelfData.boActive;
end;

procedure TMirrorObject.StartProcess;
var
   SubData : TSubData;
begin
   inherited StartProcess;

   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);
end;

procedure TMirrorObject.EndProcess;
var
   SubData : TSubData;
begin
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);

   inherited EndProcess;
end;

function TMirrorObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i : Integer;
   User : TUser;
begin
   Result := PROC_FALSE;

   if isRangeMessage (hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);

   for i := 0 to ViewerList.Count - 1 do begin
      User := ViewerList.Items [i];
      User.FieldProc2 (hfu, Msg, SenderInfo, aSubData);
   end;
end;

procedure TMirrorObject.Update (CurTick : Integer);
begin

end;

function TMirrorObject.GetSelfData : PTCreateMirrorData;
begin
   Result := @SelfData;
end;


////////////////////////////////////////////////////
//
//             ===  MirrorList  ===
//
////////////////////////////////////////////////////

constructor TMirrorList.Create;
begin
   DataList := TList.Create;
   LoadFromFile ('.\Setting\CreateMirror.SDB');
end;

destructor TMirrorList.Destroy;
begin
   Clear;
   DataList.Free;
   
   inherited Destroy;
end;

function TMirrorList.GetCount: integer;
begin
   Result := DataList.Count;
end;

procedure TMirrorList.Clear;
var
   i : Integer;
   MirrorObj : TMirrorObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      MirrorObj := DataList.Items [i];
      MirrorObj.EndProcess;
      MirrorObj.Free;
   end;
   DataList.Clear;
end;

function TMirrorList.AddViewer (aStr : String; aUser : Pointer) : Boolean;
var
   i : Integer;
   MirrorObj : TMirrorObject;
begin
   Result := false;

   for i := 0 to DataList.Count - 1 do begin
      MirrorObj := DataList.Items [i];
      if StrPas (@MirrorObj.BasicData.Name) = aStr then begin
         MirrorObj.AddViewer (aUser);
         Result := true;
         exit;
      end;
   end;
end;

function TMirrorList.DelViewer (aUser : Pointer) : Boolean;
var
   i : Integer;
   MirrorObj : TMirrorObject;
begin
   Result := false;

   for i := 0 to DataList.Count - 1 do begin
      MirrorObj := DataList.Items [i];
      if MirrorObj.DelViewer (aUser) = true then begin
         Result := true;
         exit;
      end;
   end;
end;

procedure TMirrorList.LoadFromFile (aFileName : String);
var
   i : Integer;
   iName : String;
   DB : TUserStringDB;
   MirrorObj : TMirrorObject;
   pd : PTCreateMirrorData;
   Manager : TManager;
begin
   if not FileExists (aFileName) then exit;

   DB := TUserStringDB.Create;
   DB.LoadFromFile (aFileName);

   for i := 0 to DB.Count - 1 do begin
      iName := DB.GetIndexName (i);
      if iName = '' then continue;

      MirrorObj := TMirrorObject.Create;
      pd := MirrorObj.GetSelfData;

      pd^.Name := DB.GetFieldValueString (iName, 'Name');
      pd^.X := DB.GetFieldValueInteger (iName, 'X');
      pd^.Y := DB.GetFieldValueInteger (iName, 'Y');
      pd^.MapID := DB.GetFieldValueInteger (iName, 'MapID');
      pd^.boActive := DB.GetFieldValueBoolean (iName, 'boActive');

      Manager := ManagerList.GetManagerByServerID (pd^.MapID);
      if Manager <> nil then begin
         MirrorObj.SetManagerClass (Manager);
         MirrorObj.Initial;
         MirrorObj.StartProcess;
         DataList.Add (MirrorObj);
      end else begin
         MirrorObj.Free;
      end;
   end;

   DB.Free;
end;

procedure TMirrorList.Update (CurTick: integer);
var
   i : Integer;
   MirrorObj : TMirrorObject;
begin
   for i := 0 to DataList.Count - 1 do begin
      MirrorObj := DataList.Items [i];
      MirrorObj.Update (CurTick);
   end;
end;

////////////////////////////////////////////////////
//
//             ===  StaticItemObject  ===
//
////////////////////////////////////////////////////

constructor TStaticItem.Create;
begin
   inherited Create;
end;

destructor  TStaticItem.Destroy;
begin
   inherited destroy;
end;

function  TStaticItem.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   percent : integer;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   case Msg of
      FM_HIT :
         begin
            if isHitedArea (SenderInfo.dir, SenderInfo.x, SenderInfo.y, aSubData.HitData.HitFunction, percent) then begin
               Dec (CurDurability, 5*100);
            end;
         end;
   end;
end;

procedure TStaticItem.Initial (aItemData: TItemData; aOwnerId, ax, ay: integer);
var
   str : string;
begin
   str := StrPas (@aItemData.rName);
   if aItemData.rCount > 1 then str := str + ':' + IntToStr (aItemData.rCount);
   
   inherited Initial (str, str);
   CurDurability := 10 * 60 * 100;   // 10盒悼救 绝绢瘤瘤 救澜.

   OwnerId := aOwnerId;
   SelfItemdata := aItemData;
   BasicData.id := GetNewStaticItemId;
   BasicData.x := ax;
   BasicData.y := ay;
   BasicData.ClassKind := CLASS_STATICITEM;
   BasicData.Feature.rrace := RACE_STATICITEM;
   BasicData.Feature.rImageNumber := aItemData.rShape;
   BasicData.Feature.rImageColorIndex := aItemData.rcolor;
end;

procedure TStaticItem.StartProcess;
var SubData : TSubData;
begin
   inherited StartProcess;
   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);

   if SelfItemData.rSoundDrop.rWavNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (SelfItemData.rSoundDrop.rWavNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;
end;

procedure TStaticItem.EndProcess;
var SubData : TSubData;
begin
   if FboRegisted = FALSE then exit;
   
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);
   inherited EndProcess;
end;

procedure   TStaticItem.Update (CurTick: integer);
begin
   if CreateTick + CurDurability < CurTick then FboAllowDelete := TRUE;
end;


////////////////////////////////////////////////////
//
//             ===  StaticItemList  ===
//
////////////////////////////////////////////////////

constructor TStaticItemList.Create (cnt: integer; aManager: TManager);
begin
   Manager := aManager;
   DataList := TList.Create;
end;

destructor TStaticItemList.Destroy;
begin
   Clear;
   DataList.Free;
   inherited destroy;
end;

procedure TStaticItemList.Clear;
var
   i : Integer;
   ItemObject : TStaticItem;
begin
   for i := 0 to DataList.Count - 1 do begin
      ItemObject := DataList.Items [i];
      ItemObject.EndProcess;
      ItemObject.Free;
   end;
   DataList.Clear;
end;

function  TStaticItemList.GetCount: integer;
begin
   Result := DataList.Count;
end;

{
function TStaticItemList.AllocFunction: pointer;
begin
   Result := TStaticItem.Create;
end;

procedure TStaticItemList.FreeFunction (item: pointer);
begin
   TStaticItem (item).Free;
end;
}

function  TStaticItemList.AddStaticItemObject (aItemData: TItemData; aOwnerId, ax, ay: integer): integer;
var
   ItemObject : TStaticItem;
begin
   Result := PROC_FALSE;
   if DataList.count > 3000 then exit;
   
   if aItemData.rCount <> 1 then exit;
   if not TMaper(Manager.Maper).isMoveable (ax, ay) then exit;

   ItemObject := TStaticItem.Create;
   ItemObject.SetManagerClass (Manager);
   ItemObject.Initial (aItemData, aOwnerId, ax, ay);
   ItemObject.StartProcess;
   
   DataList.Add (ItemObject);
   Result := PROC_TRUE;
end;

procedure TStaticItemList.Update (CurTick: integer);
var
   i : integer;
   StaticItem : TStaticItem;
begin
   for i := DataList.Count - 1 downto 0 do begin
      StaticItem := DataList.Items [i];
      if StaticItem.boAllowDelete then begin
         StaticItem.EndProcess;
         StaticItem.Free;
         DataList.Delete (i);
      end;
   end;

   for i := 0 to DataList.Count - 1 do begin
      StaticItem := DataList.Items [i];
      StaticItem.UpDate (CurTick);
   end;
end;


////////////////////////////////////////////////////
//
//             ===  DynamicItemObject  ===
//
////////////////////////////////////////////////////

constructor TDynamicObject.Create;
begin
   inherited Create;

   EventItemCount := 0;
   ObjectStatus := dos_Closed;
   MemberList := nil;
   DragDropEvent := nil;
end;

destructor  TDynamicObject.Destroy;
var
   i : Integer;
   AttackSkill : TAttackSkill;
   BO : TBasicObject;
begin
   if DragDropEvent <> nil then DragDropEvent.Free;
   if MemberList <> nil then begin
      for i := MemberList.Count - 1 downto 0 do begin
         BO := MemberList[i];
         if BO <> nil then begin
            AttackSkill := nil;
            if BO.BasicData.Feature.rRace = RACE_MONSTER then begin
               AttackSkill := TMonster (BO).GetAttackSkill;
            end else if BO.BasicData.Feature.rRace = RACE_NPC then begin
               AttackSkill := TNpc (BO).GetAttackSkill;
            end;
            if AttackSkill <> nil then begin
               AttackSkill.SetObjectBoss (nil);
            end;
         end;
      end;
      MemberList.Clear;
      MemberList.Free;
   end;
   inherited destroy;
end;

procedure TDynamicObject.MemberDie (aBasicObject : TBasicObject);
var
   i, j : Integer;
begin
   if MemberList = nil then exit;
   for i := 0 to MemberList.Count - 1 do begin
      if aBasicObject = MemberList[i] then begin
         if aBasicObject.BasicData.Feature.rfeaturestate <> wfs_die then begin
            CurLife := SelfData.rBasicData.rLife;
         end else begin
            for j := 0 to 5 - 1 do begin
               if StrPas (@aBasicObject.BasicData.Name) = SelfData.rDropMop [j].rName then begin
                  SelfData.rDropMop[j].rName := '';
                  break;
               end;
               if StrPas (@aBasicObject.BasicData.Name) = SelfData.rCallNpc [j].rName then begin
                  SelfData.rCallNpc[j].rName := '';
                  break;
               end;
            end;
         end;
         MemberList.Delete (i);
         break;
      end;
   end;
end;

function  TDynamicObject.FieldProc (hfu: Longint; Msg: word; var SenderInfo: TBasicData; var aSubData: TSubData): Integer;
var
   i, j, xx, yy : Integer;
   Sayer, SayStr, Str, dummy1, dummy2 : String;
   percent : Integer;
   SubData : TSubData;
   ItemData : TItemData;
   CurTick, SkillLevel : Integer;
   BO, BO2 : TBasicObject;
   Monster : TMonster;
   Npc : TNpc;
   boFlag : boolean;
   AttackSkill : TAttackSkill;
begin
   Result := PROC_FALSE;
   if isRangeMessage ( hfu, Msg, SenderInfo) = FALSE then exit;
   Result := inherited FieldProc (hfu, Msg, Senderinfo, aSubData);
   if Result = PROC_TRUE then exit;

   CurTick := mmAnsTick;
   case Msg of
      FM_HEAL :
         begin
            if ObjectStatus <> dos_Closed then exit;

            CurLife := CurLife + aSubData.HitData.ToHit;
            if CurLife > SelfData.rBasicData.rLife then CurLife := SelfData.rBasicData.rLife;
            if CurLife > 0 then begin
               SubData.Percent := CurLife * 100 div SelfData.rBasicData.rLife;
               SendLocalMessage (NOTARGETPHONE, FM_LIFEPERCENT, BasicData, SubData);
            end;
         end;
      FM_SAY :
         begin
            if ObjectStatus <> dos_Closed then exit;
            if (SelfData.rBasicData.rKind and DYNOBJ_EVENT_SAY) = DYNOBJ_EVENT_SAY then begin
               if SelfData.rBasicData.rEventSay = '' then exit;
               Str := GetWordString (aSubData.SayString);
               if ReverseFormat (Str, '%s: ' + SelfData.rBasicData.rEventSay, Sayer, dummy1, dummy2, 1) then begin
                  if SelfData.rBasicData.rSoundSpecial.rWavNumber > 0 then begin
                     SetWordString (SubData.SayString, IntToStr (SelfData.rBasicData.rSoundSpecial.rWavNumber) + '.wav');
                     SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                  end;

                  SetWordString (SubData.SayString, StrPas (@BasicData.Name) + ': ' + SelfData.rBasicData.rEventAnswer);
                  SendLocalMessage (NOTARGETPHONE, FM_SAY, BasicData, SubData);
               end;
               exit;
            end;
         end;
      FM_ADDITEM :
         begin
            if ObjectStatus <> dos_Closed then exit;
            if (SelfData.rBasicData.rKind and DYNOBJ_EVENT_ADDITEM) = DYNOBJ_EVENT_ADDITEM then begin
               if DragDropEvent.EventAddItem (StrPas (@aSubData.ItemData.rName), SenderInfo) = true then exit;

               if StrPas (@aSubData.ItemData.rName) <> SelfData.rBasicData.rEventItem.rName then exit;
               Inc (EventItemCount);

               if EventItemCount >= SelfData.rBasicData.rEventItem.rCount then begin
                  if SelfData.rBasicData.rEventDropItem.rName = '' then begin
                     if SelfData.rBasicData.rSoundEvent.rWavNumber > 0 then begin
                        SetWordString (SubData.SayString, IntToStr (SelfData.rBasicData.rSoundSpecial.rWavNumber) + '.wav');
                        SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                     end;
                     ObjectStatus := dos_Openning;
                     BasicData.Feature.rHitMotion := 0;
                     BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Openning)];
                     BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Openning)];
                     SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

                     ObjectStatus := dos_Openned;
                     BasicData.Feature.rHitMotion := 1;
                     BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Openned)];
                     BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Openned)];
                     SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

                     OpenedTick := CurTick;
                     
                     OpenedPosX := SenderInfo.X;
                     OpenedPosY := SenderInfo.Y;
                  end else begin
                     BasicData.nX := BasicData.X;
                     BasicData.nY := BasicData.Y;

                     if SelfData.rBasicData.rSoundSpecial.rWavNumber > 0 then begin
                        SetWordString (SubData.SayString, IntToStr (SelfData.rBasicData.rSoundSpecial.rWavNumber) + '.wav');
                        SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                     end;
                     if ItemClass.GetCheckItemData (StrPas (@BasicData.Name), SelfData.rBasicData.rEventDropItem, ItemData) = true then begin
                        CurLife := CurLife + 1000;
                        ItemData.rCount := SelfData.rBasicData.rEventDropItem.rCount;
                        ItemData.rOwnerName[0] := 0;
                        SubData.ItemData := ItemData;
                        SubData.ServerId := ServerId;
                        Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
                     end;
                  end;
                  EventItemCount := 0;
               end;
               Move (aSubData.ItemData, SubData.ItemData, SizeOf (TItemData));
               SendLocalMessage (SenderInfo.ID, FM_DELITEM, BasicData, SubData);
            end;
         end;
      FM_HIT :
         begin
            if ObjectStatus <> dos_Closed then exit;
            if (SelfData.rBasicData.rKind and DYNOBJ_EVENT_HIT) = DYNOBJ_EVENT_HIT then begin
               if isHitedArea (SenderInfo.dir, SenderInfo.x, SenderInfo.y, aSubData.HitData.HitFunction, percent) then begin
                  BO := GetViewObjectByID (SenderInfo.ID);
                  if BO = nil then exit;
                  if BO.BasicData.Feature.rRace <> RACE_HUMAN then exit;

                  if SelfData.rBasicData.rLife = CurLife then begin
                     for i := 0 to 5 - 1 do begin
                        if SelfData.rDropMop[i].rName = '' then continue;
                        for j := 0 to SelfData.rDropMop[i].rCount - 1 do begin
                           xx := BasicData.x;
                           yy := BasicData.y;
                           if (SelfData.rDropX <> 0) and (SelfData.rDropY <> 0) then begin
                              xx := SelfData.rDropX;
                              yy := SelfData.rDropY;
                           end else begin
                              Maper.GetMoveableXY (xx, yy, 10);
                           end;
                           if Maper.isMoveable (xx, yy) then begin
                              Monster := TMonsterList (Manager.MonsterList).CallMonster (SelfData.rDropMop[i].rName, xx, yy, 4, StrPas (@SenderInfo.Name));
                              if Monster <> nil then begin
                                 AttackSkill := Monster.GetAttackSkill;
                                 if AttackSkill <> nil then begin
                                    AttackSkill.SetObjectBoss (Self);
                                 end;
                                 if MemberList = nil then begin
                                    MemberList := TList.Create;
                                 end;
                                 MemberList.Add (Monster);
                              end;
                           end;
                        end;
                     end;
                     for i := 0 to 5 - 1 do begin
                        if SelfData.rCallNpc[i].rName = '' then continue;
                        for j := 0 to SelfData.rCallNpc[i].rCount - 1 do begin
                           xx := BasicData.x;
                           yy := BasicData.y;
                           if (SelfData.rDropX <> 0) and (SelfData.rDropY <> 0) then begin
                              xx := SelfData.rDropX;
                              yy := SelfData.rDropY;
                           end else begin
                              Maper.GetMoveableXY (xx, yy, 10);
                           end;
                           if Maper.isMoveable (xx, yy) then begin
                              Npc := TNpcList (Manager.NpcList).CallNpc (SelfData.rCallNpc[i].rName, xx, yy, 4, StrPas(@SenderInfo.Name));
                              if Npc <> nil then begin
                                 AttackSkill := Npc.GetAttackSkill;
                                 if AttackSkill <> nil then begin
                                    AttackSkill.SetObjectBoss (Self);
                                 end;
                                 if MemberList = nil then begin
                                    MemberList := TList.Create;
                                 end;
                                 MemberList.Add (Npc);
                              end;
                           end;
                        end;
                     end;
                  end else begin
                     if MemberList <> nil then begin
                        for i := 0 to MemberList.Count - 1 do begin
                           BO2 := MemberList[i];
                           if BO2 <> nil then begin
                              if BO2.BasicData.Feature.rRace = RACE_NPC then begin
                                 AttackSkill := TNpc (BO2).GetAttackSkill;
                              end else begin
                                 AttackSkill := TMonster (BO2).GetAttackSkill;
                              end;
                              AttackSkill.SetDeadAttackName (StrPas (@SenderInfo.Name));
                           end;
                        end;
                     end;
                  end;

                  CurLife := CurLife - aSubData.HitData.damageBody;
                  if CurLife < 0 then CurLife := 0;
                  if CurLife > 0 then begin
                     SubData.Percent := CurLife * 100 div SelfData.rBasicData.rLife;
                     SendLocalMessage (NOTARGETPHONE, FM_STRUCTED, BasicData, SubData);
                  end;

                  if SelfData.rBasicData.rSoundSpecial.rWavNumber > 0 then begin
                     SetWordString (SubData.SayString, IntToStr (SelfData.rBasicData.rSoundSpecial.rWavNumber) + '.wav');
                     SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
                  end;

                  if CurLife > 0 then exit;

                  if SelfData.rNeedAge <> 0 then begin
                     if TUser (BO).GetAge < SelfData.rNeedAge then begin
                        TUser (BO).SendClass.SendChatMessage (format ('%d岁以上才可开启.', [SelfData.rNeedAge]), SAY_COLOR_SYSTEM);
                        exit;
                     end;
                  end;
                  for i := 0 to 5 - 1 do begin
                     if SelfData.rNeedSkill[i].rName = '' then break;
                     SkillLevel := TUser (BO).FindHaveMagicByName (SelfData.rNeedSkill[i].rName);
                     if SelfData.rNeedSkill[i].rLevel > SkillLevel then begin
                        TUser (BO).SendClass.SendChatMessage (format ('%s 修炼值 %s 以上才可开启.', [SelfData.rNeedSkill[i].rName, Get10000To100(SelfData.rNeedSkill[i].rLevel)]), SAY_COLOR_SYSTEM);
                        exit;
                     end;
                  end;

                  for i := 0 to 5 - 1 do begin
                     if SelfData.rNeedItem[i].rName = '' then break;
                     ItemClass.GetItemData (SelfData.rNeedItem[i].rName, ItemData);
                     if ItemData.rName[0] <> 0 then begin
                        ItemData.rCount := SelfData.rNeedItem[i].rCount;
                        boFlag := TUser (BO).FindItem (@ItemData);
                        if boFlag = false then begin
                           TUser (BO).SendClass.SendChatMessage (format ('%s 物品需要 %d个.', [StrPas (@ItemData.rName), ItemData.rCount]), SAY_COLOR_SYSTEM);
                           exit;
                        end;
                     end;
                  end;

                  for i := 0 to 5 - 1 do begin
                     if SelfData.rNeedItem[i].rName = '' then break;
                     ItemClass.GetItemData (SelfData.rNeedItem[i].rName, ItemData);
                     if ItemData.rName[0] <> 0 then begin
                        ItemData.rCount := SelfData.rNeedItem[i].rCount;
                        TUser (BO).DeleteItem (@ItemData);
                     end;
                  end;

                  ObjectStatus := dos_Openned;
                  BasicData.Feature.rHitMotion := 0;
                  BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Openning)];
                  BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Openning)];
                  SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);

                  if (SelfData.rBasicData.rSStep[byte(dos_Openned)] <> 0) and
                     (SelfData.rBasicData.rEStep[byte(dos_Openned)] <> 0) then begin
                     ObjectStatus := dos_Openned;
                     BasicData.Feature.rHitMotion := 1;
                     BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Openned)];
                     BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Openned)];
                     SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
                  end;

                  OpenedTick := CurTick;
                  OpenedPosX := SenderInfo.X;
                  OpenedPosY := SenderInfo.Y;

                  xx := BasicData.nx;
                  yy := BasicData.ny;
                  BasicData.nx := SenderInfo.x;
                  BasicData.ny := SenderInfo.y;
                  for i := 0 to 5 - 1 do begin
                     if SelfData.rGiveItem[i].rName = '' then break;
                     ItemClass.GetChanceItemData (StrPas (@BasicData.Name), SelfData.rGiveItem[i].rName, ItemData);
                     ItemData.rCount := SelfData.rGiveItem[i].rCount;
                     ItemData.rOwnerName[0] := 0;

                     SubData.ItemData := ItemData;
                     SubData.ServerId := ServerId;
                     if TFieldPhone (Manager.Phone).SendMessage (SenderInfo.id, FM_ENOUGHSPACE, BasicData, SubData) = PROC_FALSE then begin
                        Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
                     end else begin
                        TFieldPhone(Manager.Phone).SendMessage (SenderInfo.id, FM_ADDITEM, BasicData, SubData);
                     end;
                  end;
                  BasicData.nx := xx;
                  BasicData.ny := yy;
               end;
            end;
         end;
   end;
end;

procedure TDynamicObject.Initial (pObjectData: PTCreateDynamicObjectData);
var
   i : Integer;
begin
   inherited Initial (pObjectData^.rBasicData.rName, pObjectData^.rBasicData.rViewName);

   Move (pObjectData^, SelfData, sizeof (TCreateDynamicObjectData));

   BasicData.id := GetNewDynamicObjectId;
   BasicData.x := pObjectData^.rx[0];
   BasicData.y := pObjectData^.ry[0];
   BasicData.ClassKind := CLASS_DYNOBJECT;
   BasicData.Feature.rrace := RACE_DYNAMICOBJECT;
   BasicData.Feature.rImageNumber := pObjectData^.rBasicData.rShape;

   ObjectStatus := dos_Closed;
   BasicData.Feature.rHitMotion := 1;
   BasicData.nx := pObjectData^.rBasicData.rSStep[byte(dos_Closed)];
   BasicData.ny := pObjectData^.rBasicData.rEStep[byte(dos_Closed)];

   FboHaveGuardPos := TRUE;
   for i := 0 to 10 - 1 do begin
      BasicData.GuardX [i] := pObjectData^.rBasicData.rGuardX [i];
      BasicData.GuardY [i] := pObjectData^.rBasicData.rGuardY [i];
   end;

   CurLife := pObjectData^.rBasicData.rLife;

   if DragDropEvent = nil then begin
      DragDropEvent := TDragDropEvent.Create (Self);
   end;
end;

procedure TDynamicObject.StartProcess;
var
   SubData : TSubData;
   i, x, y, c, cmax : Integer;
begin
   cmax := 0;
   for i := 0 to 5 - 1 do begin
      if (SelfData.rX[i] = 0) and (SelfData.rY[i] = 0) then begin
         break;
      end;
      inc (cmax);
   end;

   c := Random(cmax);
   x := SelfData.rX[c];
   y := SelfData.rY[c];
   // if not TMaper(Manager.Maper).isMoveable (x, y) then exit;

   BasicData.X := x;
   BasicData.Y := y;

   inherited StartProcess;
   
   Phone.RegisterUser (BasicData.id, FieldProc, BasicData.X, BasicData.Y);
   Phone.SendMessage (0, FM_CREATE, BasicData, SubData);

   if SelfData.rBasicData.rSoundSpecial.rWavNumber <> 0 then begin
      SetWordString (SubData.SayString, IntToStr (SelfData.rBasicData.rSoundSpecial.rWavNumber) + '.wav');
      SendLocalMessage (NOTARGETPHONE, FM_SOUND, BasicData, SubData);
   end;
end;

procedure TDynamicObject.EndProcess;
var
   SubData : TSubData;
begin
   if FboRegisted = FALSE then exit;
   
   Phone.SendMessage (0, FM_DESTROY, BasicData, SubData);
   Phone.UnRegisterUser (BasicData.id, BasicData.x, BasicData.y);
   
   inherited EndProcess;
end;

procedure TDynamicObject.Update (CurTick: integer);
var
   i, xx, yy : Integer;
   ItemData : TItemData;
   SubData : TSubData;
begin
   if FboRegisted = true then begin
      if ObjectStatus = dos_Openned then begin
         if SelfData.rBasicData.rboRemove = true then begin
            if OpenedTick + SelfData.rBasicData.rOpennedInterval <= CurTick then begin
               xx := BasicData.nx;
               yy := BasicData.ny;
               BasicData.nx := OpenedPosX;
               BasicData.ny := OpenedPosY;
               for i := 0 to 5 - 1 do begin
                  if SelfData.rDropItem[i].rName = '' then break;
                  if ItemClass.GetCheckItemData (StrPas (@BasicData.Name), SelfData.rDropItem[i], ItemData) = true then begin
                     ItemData.rOwnerName[0] := 0;
                     SubData.ItemData := ItemData;
                     SubData.ServerId := ServerId;
                     Phone.SendMessage (MANAGERPHONE, FM_ADDITEM, BasicData, SubData);
                  end;
               end;
               BasicData.nx := xx;
               BasicData.ny := yy;

               if SelfData.rBasicData.rRegenInterval = 0 then begin
                  FboAllowDelete := true;
               end else begin
                  EndProcess;
               end;
            end;
         end else begin
            if OpenedTick + SelfData.rBasicData.rOpennedInterval <= CurTick then begin
               CurLife := SelfData.rBasicData.rLife;
               ObjectStatus := dos_Closed;
               BasicData.Feature.rHitMotion := 1;
               BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Closed)];
               BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Closed)];
               SendLocalMessage (NOTARGETPHONE, FM_CHANGEFEATURE, BasicData, SubData);
            end;
         end;
      end else begin
         if DragDropEvent <> nil then begin
            DragDropEvent.EventSay (CurTick);
         end;
      end;
   end else begin
      if (ObjectStatus <> dos_Closed) and (SelfData.rBasicData.rRegenInterval > 0) then begin
         if OpenedTick + SelfData.rBasicData.rRegenInterval <= CurTick then begin
            CurLife := SelfData.rBasicData.rLife;
            ObjectStatus := dos_Closed;
            BasicData.Feature.rHitMotion := 1;
            BasicData.nx := SelfData.rBasicData.rSStep[byte(dos_Closed)];
            BasicData.ny := SelfData.rBasicData.rEStep[byte(dos_Closed)];
            StartProcess;
         end;
      end;
   end;
end;

////////////////////////////////////////////////////
//
//             ===  DynamicObjectList  ===
//
////////////////////////////////////////////////////

constructor TDynamicObjectList.Create (cnt: integer; aManager: TManager);
begin
   Manager := aManager;
   DataList := TList.Create;

   ReLoadFromFile;
end;

destructor TDynamicObjectList.Destroy;
begin
   Clear;
   DataList.Free;
   inherited destroy;
end;

procedure TDynamicObjectList.Clear;
var
   i : Integer;
   DynamicObject : TDynamicObject;
begin
   for i := DataList.Count - 1 downto 0 do begin
      DynamicObject := DataList.Items [i];
      DynamicObject.EndProcess;
      DynamicObject.Free;
      DataList.Delete (i);
   end;
   DataList.Clear;
end;

procedure TDynamicObjectList.ReLoadFromFile;
var
   i : integer;
   FileName : String;
   DynamicObject : TDynamicObject;
   CreateDynamicObjectList : TList;
   pd : PTCreateDynamicObjectData;
begin
   Clear;

   FileName := format ('.\Setting\CreateDynamicObject%d.SDB', [Manager.ServerID]);
   if not FileExists (FileName) then exit;

   CreateDynamicObjectList := TList.Create;
   LoadCreateDynamicObject (FileName, CreateDynamicObjectList);

   for i := 0 to CreateDynamicObjectList.Count -1 do begin
      pd := CreateDynamicObjectList[i];

      DynamicObject := TDynamicObject.Create;
      DynamicObject.SetManagerClass (Manager);
      DynamicObject.Initial (pd);
      DynamicObject.StartProcess;
      DataList.Add (DynamicObject);
   end;

   for i := 0 to CreateDynamicObjectList.Count - 1 do begin
      pd := CreateDynamicObjectList.Items [i];
      Dispose (pd);
   end;
   CreateDynamicObjectList.Clear;
   CreateDynamicObjectList.free;
end;

function  TDynamicObjectList.GetCount: integer;
begin
   Result := DataList.Count;
end;

{
function TDynamicObjectList.AllocFunction: pointer;
begin
   Result := TDynamicObject.Create;
end;

procedure TDynamicObjectList.FreeFunction (item: pointer);
begin
   TDynamicObject (item).Free;
end;
}

function  TDynamicObjectList.AddDynamicObject (pObjectData: PTCreateDynamicObjectData): integer;
var
   DynamicObject : TDynamicObject;
begin
   Result := PROC_FALSE;

   DynamicObject := TDynamicObject.Create;
   DynamicObject.SetManagerClass (Manager);
   DynamicObject.Initial (pObjectData);
   DynamicObject.StartProcess;
   DataList.Add (DynamicObject);

   Result := PROC_TRUE;
end;

function TDynamicObjectList.DeleteDynamicObject (aName : String) : Boolean;
var
   i : Integer;
   DynamicObject : TDynamicObject;
begin
   Result := false;
   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.SelfData.rBasicData.rName = aName then begin
         DynamicObject.FboAllowDelete := true;
         Result := true;
         exit;
      end;
   end;
end;

function TDynamicObjectList.FindDynamicObject (aName : String) : Integer;
var
   i, iCount : Integer;
   DynamicObject : TDynamicObject;
begin
   Result := 0;

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.SelfData.rBasicData.rName = aName then begin
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

function TDynamicObjectList.GetDynamicObjects (aName : String; aList : TList) : Integer;
var
   i, iCount : Integer;
   DynamicObject : TDynamicObject;
begin
   Result := 0;

   iCount := 0;
   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.SelfData.rBasicData.rName = aName then begin
         aList.Add (DynamicObject);
         Inc (iCount);
      end;
   end;

   Result := iCount;
end;

procedure TDynamicObjectList.Update (CurTick: integer);
var
   i : integer;
   DynamicObject : TDynamicObject;
begin
   for i := DataList.Count - 1 downto 0 do begin
      DynamicObject := DataList.Items [i];
      if DynamicObject.boAllowDelete then begin
         DynamicObject.EndProcess;
         DynamicObject.Free;
         DataList.Delete (i);
      end;
   end;

   for i := 0 to DataList.Count - 1 do begin
      DynamicObject := DataList.Items [i];
      DynamicObject.UpDate (CurTick);
   end;
end;

procedure SignToItem (var aItemData : TItemData;aServerID : Integer; var aBasicData : TBasicData; aIP : String);
begin
   if aItemData.rName[0] > 0 then begin
      aItemData.rOwnerRace := aBasicData.Feature.rrace;
      aItemData.rOwnerServerID := aServerID;
      if aBasicData.Feature.rRace <> RACE_HUMAN then begin
         StrPCopy(@aItemData.rOwnerName, '@');
         StrCopy (@aItemData.rOwnerName[1], @aBasicData.Name);
         StrPCopy (@aItemData.rOwnerIP, '');
      end else begin
         StrCopy (@aItemData.rOwnerName, @aBasicData.Name);
         StrPCopy (@aItemData.rOwnerIP, aIP);
      end;
      aItemData.rOwnerX := aBasicData.x;
      aItemData.rOwnerY := aBasicData.y;
      StrPCopy (@aItemData.rOwnerIP, aIP);
   end;
end;

end.
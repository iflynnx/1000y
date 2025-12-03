unit CharCls;

interface

uses
  Windows, SysUtils, Classes, graphics,
  subutil, uanstick, deftype, A2Img, AtzCls, clType, maptype, clmap, backscrn,
  objcls, CTable;

const
   MAGICNEXTTIME = 7;           // 마법프레임이 변하는 시간
   DYNAMICOBJECTTIME = 15;      // DynamicObj가 변화하는 시간

   FRAME_BUFFER_SIZE = 30;

   MESSAGEARR_SIZE = 10;

   CharMaxSiez = 160;
   CHarMaxSiezHalf = 80;

   MovingMagicMaxSiez = 140;
   MovingMagicMaxSiezHalf = 70;

   DynamicObjectMaxSize = 200;
   DynamicObjectMaxSizeHalf = 100;

   BgEffectMaxSize = 140;
   BgEffectMaxSizeHalf = 70;

   CharImageBufferCount = 12;
const
   Color16Table : array [0..3*32-1] of word = (
                0,0,0,
                128,128,128,           // 보통
                84,191,127,            // 초록
                153,108,71,            // 갈색
                145,162,194,           // 파란
                206,68,23,             // 빨간
                71,150,153,            // 청록
                229,200,234,           // 보라
                225,230,157,           // 황토색
                109,0,32,              // 자주
                63,187,239,            // 하늘
                32,32,32,              // 원깜장
                255,0,0,               // 원빨간
                0,255,0,               // 원녹색
                0,0,255,               // 원파란
                255,255,255,           // 원흰색

                0,0,0,
                128,128,128,           // 보통
                84,191,127,            // 초록
                153,108,71,            // 갈색
                145,162,194,           // 파란
                206,68,23,             // 빨간
                71,150,153,            // 청록
                229,200,234,           // 보라
                225,230,157,           // 황토색
                109,0,32,              // 자주
                63,187,239,            // 하늘
                32,32,32,              // 원깜장
                255,0,0,               // 원빨간
                0,255,0,               // 원녹색
                0,0,255,               // 원파란
                255,255,255);          // 원흰색

type
  TRecordMessage = record
     rMsg, rdir, rx, ry: Integer;
     rfeature: TFeature;
     rmotion: integer
  end;

///////////// TBgEffect Class /////////// 010120 ankudo
  TBgEffect = class
  private
    DelayTick : integer;
    FUsed : Boolean;
    FAtzClass : TAtzClass;
    BgEffectShape : integer;
    LightEffectKind :TLightEffectKind;
    BgEffectIndex : integer;
    Realx, Realy : integer;
  public
    BgEffectTime : integer;           // BgEffect가 변화하는 시간
    BgOverValue : integer;

    FFileName : string;
    ID : integer;
    x, y: integer;
    EffectPositionData : TEffectPositionData;
    BgEffectImage : TA2Image;
    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;
    procedure   Initialize (ax, ay: integer; aBgEffectShape: integer; aLightEffectKind: TLightEffectKind);
    procedure   Finalize;
    procedure   Paint(aRealx, aRealy : integer);
    procedure   SetFrame(CurTick : integer);
    function    Update ( CurTick: integer) : Integer;
    property    Used : Boolean read FUsed;
  end;

///////////// TDynamicObject Class /////////// 010102 ankudo
  TDynamicGuard = record
     aCount : Byte;
     aGuardX : array [0..10 -1] of Shortint; // 기준 128;
     aGuardY : array [0..10 -1] of Shortint; // 기준 128;
  end;

  TDynamicObject = Class
  private
    DelayTick : integer;
    FUsed : Boolean;
    FAtzClass : TAtzClass;
    DynamicObjIndex : integer;
    DynamicObjShape : integer;
    RealX, RealY: integer;
    FDynamicGuard : TDynamicGuard;

    StructedTick : integer;
    StructedPercent : integer;
  public
    Id : integer;
    x, y: integer;
    FStartFrame, FEndFrame : Word;

    DynamicObjImage : TA2Image;
    DynamicObjName  : string;
    DynamicObjectState : byte;

    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;

    procedure   Initialize (aItemName: string; aId, ax, ay, aItemShape: integer;aStartFrame, aEndFrame: Word; aState: byte; aDynamicGuard: TDynamicGuard);
    procedure   Finalize;

    procedure   ChangeProperty(pCP : PTSChangeProperty);

    procedure   ProcessMessage (aMsg, aMotion: integer);
    procedure   SetFrame(aDynamicObjectState: byte; CurTick : integer);
    function    IsArea ( ax, ay: integer): Boolean;
    procedure   Paint;
    function    Update ( CurTick: integer) : Integer;
    property    Used : Boolean read FUsed;
    property    DynamicGuard : TDynamicGuard read FDynamicGuard;
  end;

  TItemClass = Class
  private
    FUsed : Boolean;
    FAtzClass : TAtzClass;
    ItemShape : integer;
    ItemColor : integer;
    RealX, RealY: integer;
    Race : byte;
  public
    Id : integer;
    x, y: integer;
    ItemImage : TA2Image;
    ItemName : string;
    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;
    procedure   Initialize (aItemName: string; aRace: byte; aId, ax, ay, aItemshape, aItemcolor: integer);
    procedure   Finalize;
    procedure   SetItemAndColor (aItemshape, aItemColor: integer);

    procedure   ChangeProperty(pCP : PTSChangeProperty);

    function    IsArea ( ax, ay: integer): Boolean;
    procedure   Paint;
    function    Update ( CurTick: integer) : Integer;
    property    Used : Boolean read FUsed;
  end;

  TCharImageBuffer = record
     aCharImage : TA2Image;
     aImageNumber : integer;
  end;

  TCharClass = Class
  private
    TurningTick : integer;
    StructedTick : integer;
    StructedPercent : integer;

    AniList : TList;
    FrameStartTime: Longint;          // 행동 시작한 시간
    ImageNumber : Integer;
    CurFrame : integer;
    CurActionInfo: PTAniInfo;

    OverImage : TA2Image;
    BgEffect : TBgEffect;

    RealX, RealY:integer;
    FUsed : Boolean;
    FAtzClass : TAtzClass;

    CurAction : integer;
    OldMakeFrame : integer;

    BubbleList : TStringList;
    BubbleTick : integer;

    MessageArr : array [0..MESSAGEARR_SIZE-1] of TRecordMessage;

    CharImageBuffer : array [0..CharImageBufferCount-1] of TCharImageBuffer;
    CharImageBufferIndex : integer;

    procedure   SetCurrentFrame (aAniInfo : PTAniInfo; aFrame, CurTime: integer);
    function    FindAnimation ( aact, adir : Integer) : PTAniInfo;
  public
    Name : string;
    id, dir, x, y : integer;
    Feature : TFeature;

    procedure   MakeFrame (aindex, CurTick: integer);
    procedure   AddMessage (aRMsg: TRecordMessage);
    procedure   GetMessage (var aRMsg: TRecordMessage);
    procedure   ViewMessage (var aRMsg: TRecordMessage);
                // BgEffect Initialize부분 코드때문에 추가한것
    procedure   AddBgEffect (aRealx, aRealy: integer; aShape: integer; aLightEffectKind: TLightEffectKind);

    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;
    procedure   Initialize (aName: string; aId, adir, ax, ay: integer; afeature: TFeature);
    procedure   Finalize;

    function    IsArea ( ax, ay: integer): Boolean;
    function    GetArrImageLib (aindex, CurTick: integer): TA2ImageLib;
    procedure   Paint (CurTick: integer);

    function    AllowAddAction: Boolean;
    function    ProcessMessage (aMsg, adir, ax, ay: Integer; afeature: TFeature; amotion: integer): Integer;
    function    Update ( CurTick: integer) : Integer;
    procedure   Say (astr: string);

    procedure   ChangeProperty(pCP : PTSChangeProperty);

    property    Used : Boolean read FUsed;
//    property    Image : TA2Image read CharImage;
  end;

  TCharList = class
  private
    CharDataList : TList;
    ItemDataList : TList;
    MagicDataList : TList;

    DynamicObjDataList : TList;

    FAtzClass : TAtzClass;

//    function isStaticItemID(aid : LongInt) : Boolean; //010127 ankudo isStaticitem을 사용안하구 race값으로 판단함
    function isDynamicObjectStaticItemID(aid : LongInt) : Boolean;
  public
    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;
    procedure   Clear;

    procedure   AddChar (aName: Widestring; aId, adir, ax, ay: integer; afeature: TFeature);
    function    GetChar (aId: integer): TCharClass;
    procedure   DeleteChar (aId: integer);
                // item
    procedure   AddItem (aItemName: string; aRace: byte;aId, ax, ay, aItemShape, aItemColor: integer);
    function    GetItem (aId: integer): TItemClass;
    procedure   DeleteItem (aId: integer);
                // DynamicObject Item 010105 ankudo
    procedure   AddDynamicObjItem (aItemName: string; aId, ax, ay, aItemShape: integer; aStartFrame, aEndFrame: Word; aState: byte; aDynamicGuard: TDynamicGuard);
    procedure   SetDynamicObjItem (aId : integer; aState: byte; aStartFrame, aEndFrame: Word);
    function    GeTDynamicObjItem (aId: integer): TDynamicObject;
    procedure   DeleteDynamicObjItem (aId: integer);

    procedure   AddMagic (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick: integer; aType: byte);
    procedure   GetVarRealPos (var aid, ax, ay: integer);
    function    isMovable (xx, yy: integer): Boolean;

    procedure   PaintText (aCanvas: TCanvas);
    procedure   Paint(CurTick: integer);
    function    UpDate (CurTick: integer): Integer;
    function    UpDataBgEffect (CurTick: integer): integer;
    procedure   MouseMove (x, y: integer);
  end;

   TMagicActionType = (MAT_SHOW, MAT_MOVE, MAT_HIDE, MAT_DESTROY);

   ToldMovingMagic = record
      asid, aeid : LongInt;
      aDeg : integer;
      atx, aty : word;
      aMagicShape : integer;
      amf : byte;
      aspeed : byte;
      aType : byte;
      ax, ay : integer;
    end;

  TMovingMagicClass = Class
  private
   StartId, EndId : longInt;
   speed : word;
   tx, ty, drawX, drawY : integer;
   ActionStartTime : DWORD;
   LifeCycle : integer;
   curframe : Integer;
   ArriveFlag : Boolean;
   Deg, Direction : word;

   MagicCount : integer;
   MagicType : byte;
   OldMovingMagicR : ToldMovingMagic;

    FUsed : Boolean;
    FAtzClass : TAtzClass;
    MagicShape : integer;
    RealX, RealY: integer;
    MsImageLib, MmImageLib, MeImageLib : TA2ImageLib;
    procedure SetAction (aAction : TMagicActionType; CurTime: integer);
  public
    MagicCurAction : TMagicActionType;
    x, y: integer;
//    MagicImage : TA2Image;
    MagicName : string;
    constructor Create (aAtzClass: TAtzClass);
    destructor  Destroy; override;
    procedure   Initialize (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick: integer; aType: byte);
    procedure   Finalize;

    procedure   Paint;
    function    Update ( CurTick: integer) : Integer;
    property    Used : Boolean read FUsed;
  end;


  procedure GetGreenColorAndAdd (acolor: integer; var GreenColor, GreenAdd: integer);

var
   CharList : TCharList;

   CharCenterId : integer = 0;
   CharCenterName : string = '';
   CharPosX : integer = 0;
   CharPosY : integer = 0;

   SelectedChar : integer = 0;
   Selecteditem : integer = 0;
   SelectedDynamicItem : integer = 0;

   CharMoveFrontdieFlag : Boolean = FALSE;

//   ColorIndex : array [0..32-1] of word;

implementation

{$O+}

//////////////////////////////////
//         Moving Magic Class
//////////////////////////////////
// 버그로 인해서 생긴 아이템색을 테이블로 처리함.
procedure GetGreenColorAndAdd (acolor: integer; var GreenColor, GreenAdd: integer);
begin
   if (acolor >= 256) or (acolor < 0) then acolor := 0;
   GreenColor := ColorDataTable[acolor*2];
   GreenAdd := ColorDataTable[acolor*2+1];

//   GreenColor := ColorIndex[acolor mod 32];
//   GreenAdd := acolor div 16;

//   GreenColor := WINRGB (ColorTable[acolor * 3 + 0],ColorTable[acolor * 3 + 1],ColorTable[acolor * 3 + 2] );
//   GreenAdd := acolor div 64;
end;
{
procedure GetGreenColorAndAdd (acolor: integer; var GreenColor, GreenAdd: integer);
begin
   if (acolor >= 256) or (acolor < 0) then acolor := 0;
   GreenColor := ColorDataTable[acolor*2];
   GreenAdd := ColorDataTable[acolor*2+1];
end;
}

{
procedure GetGreenColorAndAdd (acolor: integer; var GreenColor, GreenAdd: integer);
begin
   if acolor < 16 then begin
      GreenColor := ColorIndex[acolor];
      GreenAdd := 0;
   end else begin
      GreenColor := ColorIndex[acolor];
      GreenAdd := 3;
   end;
end;
}



////////////////////////////////////////////////////////////////////////////////
//                           TMovingMagicClass
////////////////////////////////////////////////////////////////////////////////

constructor TMovingMagicClass.Create (aAtzClass: TAtzClass);
begin
   FAtzClass := aAtzClass;
   Fillchar (OldMovingMagicR, Sizeof(OldMovingMagicR),0);
   MagicCount := 0;
   MagicType := 0;
end;

destructor  TMovingMagicClass.Destroy;
begin
   inherited destroy;
end;

procedure   TMovingMagicClass.Initialize (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick: integer; aType: byte);
begin
   if aType > 0 then begin
      MagicCount := 8-1;
      OldMovingMagicR.asid := sid;
      OldMovingMagicR.aeid := eid;
      OldMovingMagicR.aDeg := adeg;
      OldMovingMagicR.atx := atx;
      OldMovingMagicR.aty := aty;
      OldMovingMagicR.aMagicShape := aMagicShape;
      OldMovingMagicR.amf := aMagicShape;
      OldMovingMagicR.aspeed := aspeed;
      OldMovingMagicR.aType := atype;
      OldMovingMagicR.ax := ax;
      OldMovingMagicR.ay := ay;
   end;
   StartId := sid; EndId := eid;
   deg := adeg;
   speed := aspeed;
   x := ax; y := ay;
   Tx := atx; ty := aty;
   MagicShape := aMagicShape;
   MagicType := aType;
   LifeCycle := 30;
   Direction := GetDegDirection ( deg);
   SetAction (MAT_SHOW, mmAnsTick);

   MsImageLib := nil;
   MmImageLib := FAtzClass.GetImageLib ('y'+IntToStr(MagicShape)+'.atz', CurTick);
   MeImageLib := nil;

   RealX := x * UNITX + UNITX div 2;
   RealY := y * UNITY + UNITY div 2;
   FUsed := TRUE;
end;

procedure TMovingMagicClass.SetAction (aAction : TMagicActionType; CurTime: integer);
begin
   MagicCurAction := aAction;
   ActionStartTime := CurTime;
   curframe := 0;
   if MagicCurAction = MAT_SHOW then begin
      DrawX := x*UNITX + UNITXS;
      DrawY := y*UNITY - UNITYS;
      CharList.GetVarRealPos (StartId, DrawX, DrawY);
   end;
   RealX := DrawX;
   RealY := DrawY;
end;

procedure   TMovingMagicClass.Finalize;
begin
   FUsed := FALSE;
end;

procedure   TMovingMagicClass.Paint;
var
   tempframe : integer;
   overValue : integer;
begin
   tempframe := 0;
   overValue := 10;
   case MagicCurAction of
      MAT_SHOW:
         begin
            if MsImageLib = nil then exit;
            case MagicType of
               0 :
                  begin
                     if MmImageLib.Count = 80 then tempframe := curframe + Direction * 10
                     else tempframe := curframe;
                  end;
               1 :
                  begin
                     tempframe := Random(MmImageLib.Count-1);
                     overValue := random (3)+7;
                  end;
            end;
            BackScreen.DrawImageOveray ( MsImageLib.Images[tempframe], DrawX, DrawY, overValue);
         end;
      MAT_MOVE:
         begin
            if MmImageLib = nil then exit;
            case MagicType of
               0 :
                  begin
                     if MmImageLib.Count = 80 then tempframe := curframe + Direction * 10
                     else tempframe := curframe;
                  end;
               1 :
                  begin
                     tempframe := Random(MmImageLib.Count-1);
                     overValue := random (3)+7;
                  end;
            end;
            BackScreen.DrawImageOveray ( MmImageLib.Images[tempframe], DrawX, DrawY, overValue);
         end;
      MAT_HIDE:
         begin
            if MeImageLib = nil then exit;
            case MagicType of
               0 :
                  begin
                     if MmImageLib.Count = 80 then tempframe := curframe + Direction * 10
                     else tempframe := curframe;
                  end;
               1 :
                  begin
                     tempframe := Random(MmImageLib.Count-1);
                     overValue := random (3)+7;
                  end;
            end;
            BackScreen.DrawImageOveray ( MeImageLib.Images[tempframe], DrawX, DrawY, overValue);
         end;
   end;
end;

function    TMovingMagicClass.Update (CurTick: integer) : Integer;
var
   tdrawx, tdrawy, len : integer;
   PassTime : LongInt;
   tdeg : word;
begin
   Result := 0;
   if MagicCurAction = MAT_MOVE then Result := 1;

   PassTime := CurTick - integer(ActionStartTime);                    // 행동이 끝났으면

   case MagicCurAction of
      MAT_SHOW :
         begin
            curframe := PassTime div MAGICNEXTTIME;
            if curframe >= 10 then SetAction (MAT_MOVE, CurTick);
            DrawX := x*UNITX + UNITXS;
            DrawY := y*UNITY - UNITYS;
            CharList.GetVarRealPos (StartId, DrawX, DrawY);
            case MagicType of
               0 : ;
               1 :
                  begin
                     if MagicCount > 0 then begin
                        with OldMovingMagicR do begin
                           CharList.AddMagic (asid, aeid, Random (360), Random(15)+10, ax+Random(5), ay+Random(5), atx+Random(5), aty+Random(5), aMagicShape, CurTick ,0);
                        end;
                        Dec (MagicCount);
                     end;
                  end;
            end;
         end;
      MAT_MOVE :
         begin
            tdrawx := Tx*UNITX+UNITXS;
            tdrawy := ty*UNITY-UNITYS;

            CharList.GetVarRealPos (EndId, tDrawX, tDrawY);

            curframe := curframe + 1;
            if curframe >= 10 then curframe := 0;
            Dec (LifeCycle);

            if LifeCycle = 0 then SetAction (MAT_HIDE, CurTick);
            GetDegNextPosition ( deg, speed, DrawX, DrawY);
            tdeg := GetDeg (DrawX, DrawY, tdrawx, tdrawy);

            len := (DrawX-tDrawx)*(DrawX-tDrawx)+(DrawY-tDrawy)*(DrawY-tDrawy);
            if len < 400 then begin
               Drawx := tDrawx;
               Drawy := tDrawy;
               SetAction (MAT_HIDE, CurTick);
               exit;
            end;

            deg := GetNewDeg (deg, tdeg, 20);
            if ArriveFlag then if abs(deg-tdeg) > 100 then SetAction (MAT_HIDE, CurTick);

            if deg = tdeg then ArriveFlag := TRUE;
            case MagicType of
               0 : ;
               1 :
                  begin
                     if MagicCount > 0 then begin
                        with OldMovingMagicR do begin
                           CharList.AddMagic (asid, aeid, Random(360), Random(15)+10, ax+Random(5), ay+Random(5), atx+Random(5), aty+Random(5), aMagicShape, CurTick ,0);
                        end;
                        Dec (MagicCount);
                     end;
                  end;
            end;
         end;
      MAT_HIDE :
         begin
            curframe := PassTime div MAGICNEXTTIME;
            if curframe >= 10 then SetAction (MAT_DESTROY, CurTick);

            DrawX := tx*UNITX + UNITXS;
            DrawY := ty*UNITY - UNITYS;
            CharList.GetVarRealPos (EndId, DrawX, DrawY);
         end;
      MAT_DESTROY : exit;
   end;
   RealX := DrawX;
   RealY := DrawY;
end;

//////////////////////////////////
//         BgEffect Class
//////////////////////////////////
constructor TBgEffect.Create (aAtzClass: TAtzClass);
begin
   FAtzClass := aAtzClass;
   BgEffectImage := TA2Image.Create (BgEffectMaxSize, BgEffectMaxSize, 0, 0);
end;

destructor  TBgEffect.Destroy;
begin
   BgEffectImage.Free;
   inherited destroy;
end;

procedure   TBgEffect.Initialize (ax, ay: integer; aBgEffectShape: integer; aLightEffectKind: TLightEffectKind);
begin
   BgEffectShape := aBgEffectShape;
   FFileName := format ('_%d.atz', [BgEffectShape]);
   EffectPositionData := EffectPositionClass.GetPosition (FFilename);
   BgOverValue := EffectPositionData.rArr[0];
   if BgOverValue < 1 then BgOverValue := 20;
   BgEffectTime := EffectPositionData.rArr[1];
   if BgEffectTime < 1 then BgEffectTime := 8;

   LightEffectKind := aLightEffectKind;

   RealX := ax * UNITX + UNITX div 2;
   RealY := ay * UNITY + UNITY div 2;
   BgEffectIndex := 0;
   DelayTick := 0;
   FUsed := TRUE;
end;

procedure   TBgEffect.Finalize;
begin
   FFileName := '';
   FUsed := FALSE;
end;

procedure   TBgEffect.Paint(aRealx, aRealy : integer);
begin
   if Used = FALSE then exit;
   if BgEffectImage <> nil then begin
      case LightEffectKind of
         lek_none :
            BackScreen.DrawImageOveray (BgEffectImage, RealX-BgEffectMaxSizeHalf, RealY-BgEffectMaxSizeHalf, BgOverValue);
         lek_follow :
            BackScreen.DrawImageOveray (BgEffectImage, aRealX-BgEffectMaxSizeHalf, aRealY-BgEffectMaxSizeHalf, BgOverValue);
         lek_future :;
      end;
   end;
end;

procedure   TBgEffect.SetFrame(CurTick : integer);
var
   ImageLib : TA2ImageLib;
begin
   if Used = FALSE then exit;
   ImageLib := FAtzClass.GetImageLib (FFileName, CurTick);
   if (ImageLib <> nil) then begin
      if BgEffectIndex > ImageLib.Count -1 then begin
         Finalize; exit;
      end;
   end;

   if (ImageLib <> nil) and (ImageLib.Images[BgEffectIndex] <> nil) then begin
      if BgEffectImage <> nil then BgEffectImage.Free;
      BgEffectImage := TA2Image.Create (BgEffectMaxSize, BgEffectMaxSize, 0, 0);
      BgEffectImage.DrawImage (ImageLib.Images[BgEffectIndex], ImageLib.Images[BgEffectIndex].px+BgEffectMaxSizeHalf, ImageLib.Images[BgEffectIndex].py+BgEffectMaxSizeHalf, TRUE);
      BgEffectImage.Optimize;
   end;

   inc (BgEffectIndex);
end;

function    TBgEffect.Update ( CurTick: integer) : Integer;
begin
   Result := 0;
   if CurTick > DelayTick + BgEffectTime then begin
      DelayTick := CurTick;
      SetFrame(CurTick);
   end;
end;

//////////////////////////////////
//         DynamicObject Class
//////////////////////////////////

constructor TDynamicObject.Create (aAtzClass: TAtzClass);
begin
   FAtzClass := aAtzClass;
   DynamicObjImage := TA2Image.Create (DynamicObjectMaxSize, DynamicObjectMaxSize, 0, 0);
   StructedTick := 0;
   StructedPercent := 0;

   FStartFrame := 0;
   FEndFrame := 0;
end;

destructor  TDynamicObject.Destroy;
begin
   DynamicObjImage.Free;
   inherited destroy;
end;

procedure   TDynamicObject.Initialize (aItemName: string; aId, ax, ay, aItemShape: integer;aStartFrame, aEndFrame: Word; aState: byte; aDynamicGuard: TDynamicGuard);
begin
   DynamicObjName := aItemName;
   id := aid; x := ax; y := ay;
   DynamicObjShape := aItemShape;
   DynamicObjectState := aState;
   if DynamicObjectState = 1 then DynamicObjIndex := Random (5+aStartFrame)
   else DynamicObjIndex := aStartFrame;
   FDynamicGuard := aDynamicGuard;
   FStartFrame := aStartFrame;
   FEndFrame := aEndFrame;
   DelayTick := 0;

   RealX := x * UNITX + UNITX div 2;
   RealY := y * UNITY + UNITY div 2;
   FUsed := TRUE;
end;

procedure   TDynamicObject.Finalize;
begin
   FUsed := FALSE;
   DynamicObjName := '';
   id := 0;
end;

procedure   TDynamicObject.ChangeProperty(pCP : PTSChangeProperty);
begin
   DynamicObjName := StrPas(@pCP^.rNameString);
end;

procedure   TDynamicObject.ProcessMessage (aMsg, aMotion: integer);
begin
   case amsg of
      SM_STRUCTED :
         begin
            StructedTick := mmAnsTick;
            StructedPercent := aMotion;
         end;
   end;
end;

function    TDynamicObject.IsArea ( ax, ay: integer): Boolean;
var
   xp, yp: integer;
   xx, yy: integer;
   pb : pword;
begin
   Result := TRUE;
   xx := RealX + DynamicObjImage.px - DynamicObjectMaxSizeHalf;
   yy := RealY + DynamicObjImage.py - DynamicObjectMaxSizeHalf;

   if (ax <= xx) then Result := FALSE;
   if (ay <= yy) then Result := FALSE;
   if ax >= xx + DynamicObjImage.Width then Result := FALSE;
   if ay >= yy + DynamicObjImage.Height then Result := FALSE;
   if Result = FALSE then exit;

   xp := ax-xx;
   yp := ay-yy;

   pb := PWORD (DynamicObjImage.bits);
   inc (pb, xp + yp*DynamicObjImage.Width);
   if pb^ = 0 then Result := FALSE;
end;

procedure   TDynamicObject.SetFrame(aDynamicObjectState: byte; CurTick : integer);
var
   ImageLib : TA2ImageLib;
begin
   DynamicObjImage.Free;
   DynamicObjImage := TA2Image.Create (DynamicObjectMaxSize, DynamicObjectMaxSize, 0, 0);
   case aDynamicObjectState of
      0 : // ex 상자 : 열리는 모습
         begin
            ImageLib := FAtzClass.GetImageLib (format ('x%d.atz', [DynamicObjShape]),CurTick);
            if ImageLib <> nil then begin
               if DynamicObjIndex > FEndFrame then DynamicObjIndex := FEndFrame;
               if (ImageLib <> nil) and (ImageLib.Images[DynamicObjIndex] <> nil) then begin
                  DynamicObjImage.DrawImage (ImageLib.Images[DynamicObjIndex], ImageLib.Images[DynamicObjIndex].px+DynamicObjectMaxSizeHalf, ImageLib.Images[DynamicObjIndex].py+DynamicObjectMaxSizeHalf, TRUE);
                  DynamicObjImage.Optimize;
               end;
               Inc(DynamicObjIndex)
            end;
         end;
      1 :  // ex 문파초석 화로 : 계속적으로 Scroll됨
         begin
            ImageLib := FAtzClass.GetImageLib (format ('x%d.atz', [DynamicObjShape]), CurTick);
            if ImageLib <> nil then begin
               if DynamicObjIndex > FEndFrame then DynamicObjIndex := FStartFrame;
               if (ImageLib <> nil) and (ImageLib.Images[DynamicObjIndex] <> nil) then begin
                  DynamicObjImage.DrawImage (ImageLib.Images[DynamicObjIndex], ImageLib.Images[DynamicObjIndex].px+DynamicObjectMaxSizeHalf, ImageLib.Images[DynamicObjIndex].py+DynamicObjectMaxSizeHalf, TRUE);
                  DynamicObjImage.Optimize;
               end;
               Inc(DynamicObjIndex)
            end;
         end;
   end;
end;

procedure   TDynamicObject.Paint;
begin
   if DynamicObjImage <> nil then
      BackScreen.DrawImage (DynamicObjImage, RealX-DynamicObjectMaxSizeHalf, RealY-DynamicObjectMaxSizeHalf, TRUE);
   if StructedTick <> 0 then BackScreen.DrawStructed (RealX, RealY, 55, StructedPercent);
end;

function    TDynamicObject.Update ( CurTick: integer) : Integer;
begin
   Result := 0;
   if StructedTick + 200 < CurTick then StructedTick := 0;
   if CurTick > DelayTick + DYNAMICOBJECTTIME then begin
      DelayTick := CurTick;
      SetFrame (DynamicObjectState, CurTick);
   end;
end;

//////////////////////////////////
//         Item Class
//////////////////////////////////

constructor TItemClass.Create (aAtzClass: TAtzClass);
begin
   FAtzClass := aAtzClass;
   ItemImage := TA2Image.Create (140, 140, 0, 0);
end;

destructor  TItemClass.Destroy;
begin
   ItemImage.Free;
   inherited destroy;
end;

procedure   TItemClass.SetItemAndColor (aItemshape, aItemColor: integer);
var
   gc, ga: integer;
   tempImage : TA2Image;
begin
   ItemShape := aItemShape;
   ItemColor := aItemColor;
   tempImage := FAtzClass.GetItemImage (ItemShape);
   ItemImage.Free;
   ItemImage := TA2Image.Create (140, 140, 0, 0);

   GetGreenColorAndAdd (ItemColor, gc, ga);
   ItemImage.DrawImageGreenConvert (TempImage, 70-TempImage.Width div 2, 70-TempImage.Height div 2, gc, ga);
   ItemImage.Optimize;
   RealX := x * UNITX + UNITX div 2;
   RealY := y * UNITY + UNITY div 2;
end;

procedure   TItemClass.Initialize (aItemName: string; aRace: byte; aId, ax, ay, aItemshape, aItemcolor: integer);
var
   gc, ga: integer;
   tempImage : TA2Image;
begin
   ItemName := aItemName;
   id := aid; x := ax; y := ay; ItemShape := aItemShape; ItemColor := aItemColor;
   tempImage := FAtzClass.GetItemImage (ItemShape);
   ItemImage.Free;
   ItemImage := TA2Image.Create (140, 140, 0, 0);

   GetGreenColorAndAdd (ItemColor, gc, ga);
   ItemImage.DrawImageGreenConvert (TempImage, 70-TempImage.Width div 2, 70-TempImage.Height div 2, gc, ga);
   ItemImage.Optimize;
   RealX := x * UNITX + UNITX div 2;
   RealY := y * UNITY + UNITY div 2;
   Race := aRace;
   FUsed := TRUE;
end;

procedure   TItemClass.Finalize;
begin
   FUsed := FALSE;
   ItemName := '';
   id := 0;
   Race := RACE_ITEM;
end;

procedure TItemClass.ChangeProperty(pCP : PTSChangeProperty);
begin
   ItemName := StrPas(@pCP^.rNameString);
end;

function  TItemClass.IsArea ( ax, ay: integer): Boolean;
var
   xp, yp: integer;
   xx, yy: integer;
   pb : pword;
begin
   Result := TRUE;
   xx := RealX +ItemImage.px- 70;
   yy := RealY +ItemImage.py- 70;

   if (ax <= xx) then Result := FALSE;
   if (ay <= yy) then Result := FALSE;
   if ax >= xx + ItemImage.Width then Result := FALSE;
   if ay >= yy + ItemImage.Height then Result := FALSE;
   if Result = FALSE then exit;

   xp := ax-xx;
   yp := ay-yy;

   pb := PWORD (ItemImage.bits);
   inc (pb, xp + yp*ItemImage.Width);
   if pb^ = 0 then Result := FALSE;
end;

procedure   TItemClass.Paint;
begin
   BackScreen.DrawImage (ItemImage, RealX-70, RealY-70, TRUE);
end;

function    TItemClass.Update (CurTick: integer) : Integer;
begin
   Result := 0;
end;


//////////////////////////////////
//         Char Class
//////////////////////////////////

constructor TCharClass.Create (aAtzClass:TAtzClass);
var
   i : integer;
begin
   FAtzClass := aAtzClass;

   for i := 0 to CharImageBufferCount -1 do begin
      CharImageBuffer[i].aCharImage := nil;
      CharImageBuffer[i].aImageNumber := -1;
   end;
   CharImageBuffer[0].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
   CharImageBufferIndex := 0;

   OverImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
   BubbleList := TStringList.Create;
   BgEffect := nil;
end;

destructor  TCharClass.Destroy;
var
   i : integer;
begin
   BubbleList.Free;
   if BgEffect <> nil then BgEffect.Free;
   for i := 0 to CharImageBufferCount -1 do begin
      if CharImageBuffer[i].aCharImage <> nil then CharImageBuffer[i].aCharImage.Free;
   end;

   if OverImage <> nil then OverImage.free;
   inherited destroy;
end;

procedure   TCharClass.AddMessage (aRMsg: TRecordMessage);
var i : integer;
begin
   for i := 1 to 5-1 do MessageArr[i-1] := MessageArr[i];
   FillChar (MessageArr[5-1], sizeof(TRecordMessage), 0);
   for i := 0 to 5-1 do begin
      if MessageArr[i].rmsg = 0 then begin
         MessageArr[i] := aRMsg;
         break;
      end;
   end;
end;

procedure   TCharClass.GetMessage (var aRMsg: TRecordMessage);
var i : integer;
begin
   aRMsg := MessageArr[0];
   for i := 1 to 5-1 do MessageArr[i-1] := MessageArr[i];
   FillChar (MessageArr[5-1], sizeof(TRecordMessage), 0);
end;

procedure   TCharClass.ViewMessage (var aRMsg: TRecordMessage);
begin
   aRMsg := MessageArr[0];
end;

procedure   TCharClass.AddBgEffect (aRealx, aRealy: integer; aShape: integer; aLightEffectKind: TLightEffectKind);
begin
   if BgEffect = nil then begin
      BgEffect := TBgEffect.Create (FAtzClass);
      BgEffect.Initialize (aRealx, aRealy, aShape, aLightEffectKind);
      Feature.rEffectNumber := 0;
   end else begin
      BgEffect.Initialize (aRealx, aRealy, aShape, aLightEffectKind);
      Feature.rEffectNumber := 0;
      exit;
   end;
end;

function    TCharClass.GetArrImageLib (aindex, CurTick: integer): TA2ImageLib;
begin
   if not Feature.rboMan then
      Result := FAtzClass.GetImageLib (char(word('a')+aindex) + format ('%d0.atz', [Feature.rArr[aindex*2]]), CurTick)
   else
      Result := FAtzClass.GetImageLib (char(word('n')+aindex) + format ('%d0.atz', [Feature.rArr[aindex*2]]), CurTick);
end;

function    TCharClass.IsArea ( ax, ay: integer): Boolean;
var
   xp, yp: integer;
   xx, yy: integer;
   pb : pword;
begin
   Result := TRUE;
//   if CharImageBuffer[CharImageBufferIndex].aCharImage = nil then exit;
//   xx := Realx - CharImage.px - CHarMaxSiezHalf;
//   yy := Realy - CharImage.py - CHarMaxSiezHalf;

   xx := Realx + CharImageBuffer[CharImageBufferIndex].aCharImage.px - CHarMaxSiezHalf;
   yy := Realy + CharImageBuffer[CharImageBufferIndex].aCharImage.py - CHarMaxSiezHalf;

   if (ax <= xx) then Result := FALSE;
   if (ay <= yy) then Result := FALSE;
   if ax >= xx + CharImageBuffer[CharImageBufferIndex].aCharImage.Width then Result := FALSE;
   if ay >= yy + CharImageBuffer[CharImageBufferIndex].aCharImage.Height then Result := FALSE;
   if Result = FALSE then exit;

   xp := ax-xx;
   yp := ay-yy;

   pb := PWORD (CharImageBuffer[CharImageBufferIndex].aCharImage.bits);
   inc (pb, xp + yp*CharImageBuffer[CharImageBufferIndex].aCharImage.Width);
   if pb^ = 0 then Result := FALSE;
end;

procedure   TCharClass.Initialize (aName: string; aId, adir, ax, ay: integer; afeature: TFeature);
begin
   Name := aName;
   id := aid; dir := adir; x := ax; y := ay; Feature := aFeature;
   CurFrame := 1;
   CurActionInfo := nil;
   CurAction := -1;
   AniList := Animater.GetAnimationList(aFeature.raninumber);

   FUsed := TRUE;
   OldMakeFrame := -1;

   TurningTick := 0;
   StructedTick := 0;
   StructedPercent := 0;
   BgEffect := nil;
   CharImageBuffer[0].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
   CharImageBufferIndex := 0;
end;

procedure   TCharClass.Finalize;
var
   i : integer;
begin
   if BgEffect <> nil then begin
      BgEffect.Free;
      BgEffect := nil;
   end;
   for i := 0 to CharImageBufferCount -1 do begin
      if CharImageBuffer[i].aCharImage <> nil then CharImageBuffer[i].aCharImage.Free;
      CharImageBuffer[i].aCharImage := nil;
      CharImageBuffer[i].aImageNumber := -1;
   end;
   Name := '';
   id := 0; dir := 0; x := 0; y := 0; FillChar (Feature, sizeof(Feature), 0);
   FUsed := FALSE;
end;

procedure TCharClass.Say (astr: string);
begin
   BubbleTick := mmAnsTick;
   BubbleList.Clear;
   BackScreen.GetBubble (BubbleList, astr);
end;

procedure TCharClass.ChangeProperty(pCP : PTSChangeProperty);
begin
   Name := StrPas(@pCP^.rNameString);
end;

function    TCharClass.ProcessMessage (aMsg, adir, ax, ay: Integer; afeature: TFeature; amotion: integer): Integer;
var
   CurTick : integer;
   xx, yy: word;
   i : integer;
//   RMsg : TRecordMessage;
begin
   Result := 0;
   CurTick := mmAnsTick;
   OldMakeFrame := -1;
{
   if (CurActionInfo <> nil) and (id <> CharCenterId) then begin
      RMsg.rMsg := aMsg;
      RMsg.rdir := adir;
      Rmsg.rx := ax;
      RMsg.ry := ay;
      RMsg.rfeature := aFeature;
      Rmsg.rmotion := amotion;
      AddMessage (RMsg);
      exit;
   end;
}
   case amsg of
      SM_STRUCTED :
         begin
            StructedTick := CurTick;
            StructedPercent := amotion;
         end;
      SM_SAY :;
      SM_CHANGEFEATURE:
         begin
            for i := 0 to CharImageBufferCount -1 do begin
               if CharImageBuffer[i].aCharImage <> nil then CharImageBuffer[i].aCharImage.Free;
               CharImageBuffer[i].aCharImage := nil;
               CharImageBuffer[i].aImageNumber := -1;
            end;
            CharImageBuffer[0].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
            CharImageBufferIndex := 0;
            if Feature.raninumber <> afeature.raninumber then AniList := Animater.GetAnimationList(afeature.raninumber);
            dir := adir; x := ax; y := ay;

            if (Feature.rfeaturestate <> wfs_sitdown) and (aFeature.rFeatureState = wfs_sitdown) then begin
               CurActionInfo := FindAnimation ( AM_SEATDOWN, dir);
               SetCurrentFrame (CurActionInfo,0, CurTick);
               CurAction := SM_MOTION;
            end;

            if (Feature.rfeaturestate = wfs_sitdown) and (aFeature.rFeatureState <> wfs_sitdown) then begin
               CurActionInfo := FindAnimation ( AM_STANDUP, dir);
               SetCurrentFrame (CurActionInfo,0, CurTick);
               CurAction := SM_MOTION;
            end;

            if (Feature.rfeaturestate <> wfs_die) and (aFeature.rFeatureState = wfs_die) then begin
               CurActionInfo := FindAnimation ( AM_DIE, dir);
               SetCurrentFrame (CurActionInfo,0, CurTick);
               CurAction := SM_MOTION;
            end;

            Feature := aFeature;
            if Feature.rEffectNumber > 0 then begin
               AddBgEffect (ax, ay, Feature.rEffectNumber-1, Feature.rEffectKind);
            end;
         end;
      SM_SETPOSITION :
         begin
            dir := adir; x := ax; y := ay;
            Feature := aFeature;
            CurActionInfo := FindAnimation ( AM_TURN, dir);
            SetCurrentFrame (CurActionInfo,0, CurTick);
            CurAction := SM_TURN;
         end;
      SM_TURN :
         begin
            dir := adir; x := ax; y := ay;
            Feature := aFeature;
            CurActionInfo := FindAnimation ( AM_TURN, dir);
            SetCurrentFrame (CurActionInfo,0, CurTick);
            CurAction := SM_TURN;
         end;
      SM_MOTION :
         begin
            dir := adir; x := ax; y := ay;
            CurActionInfo := FindAnimation ( amotion, dir);
            SetCurrentFrame (CurActionInfo,0, CurTick);
            CurAction := SM_MOTION;
         end;
      SM_MOVE :
         begin
            xx := ax; yy := ay;
            GetNextPosition (adir, xx, yy);
            x := xx;
            y := yy;
            dir := adir;
            CurActionInfo := FindAnimation ( AM_MOVE, dir);
            SetCurrentFrame (CurActionInfo, 0, CurTick);
            CurAction := SM_MOVE;
         end;
   end;
end;

function TCharClass.FindAnimation ( aact, adir : Integer) : PTAniInfo;
var
   i : Integer;
   ainfo: PTAniInfo;
begin
   Result := nil;

   case Feature.rFeaturestate of
      wfs_normal  : if aact = AM_TURN then aact := AM_TURN;
      wfs_care    : if aact = AM_TURN then aact := AM_TURN1;
      wfs_sitdown : if aact = AM_TURN then aact := AM_TURN2;
      wfs_die     : if aact = AM_TURN then aact := AM_TURN3;
      wfs_running : if aact = AM_TURN then aact := AM_TURN4;
      wfs_running2 : if aact = AM_TURN then aact := AM_TURN5;
   end;

   case Feature.rFeaturestate of
      wfs_normal  : if aact = AM_TURNNING then aact := AM_TURNNING;
      wfs_care    : if aact = AM_TURNNING then aact := AM_TURNNING1;
      wfs_sitdown : if aact = AM_TURNNING then aact := AM_TURNNING2;
      wfs_die     : if aact = AM_TURNNING then aact := AM_TURNNING3;
      wfs_running : if aact = AM_TURNNING then aact := AM_TURNNING4;
      wfs_running2 : if aact = AM_TURNNING then aact := AM_TURNNING5;
   end;

   case Feature.rFeaturestate of
      wfs_normal  : if aact = AM_MOVE then aact := AM_MOVE;
      wfs_care    : if aact = AM_MOVE then aact := AM_MOVE1;
      wfs_sitdown : if aact = AM_MOVE then aact := AM_MOVE2;
      wfs_die     : if aact = AM_MOVE then aact := AM_MOVE3;
      wfs_running : if aact = AM_MOVE then aact := AM_MOVE4;
      wfs_running2 : if aact = AM_MOVE then aact := AM_MOVE5;
   end;

   for i := 0 to AniList.Count -1 do begin
      ainfo := AniList[i];
      if (ainfo.Action = aact) and (ainfo.direction = adir) then begin
         Result := ainfo;
         break;
      end;
   end;
end;

procedure TCharClass.SetCurrentFrame (aAniInfo : PTAniInfo; aFrame, CurTime: integer);
begin
   if aAniInfo = nil then begin Error := 10; exit; end;
   FrameStartTime := CurTime;
   Curframe := aFrame;
   ImageNumber := aAniInfo^.Frames[CurFrame];
   RealX := x*UNITX + aAniInfo^.Pxs[curframe]+UNITXS;
   RealY := y*UNITY + aAniInfo^.Pys[curframe]-UNITYS;
end;

function    TCharClass.AllowAddAction: Boolean;
begin
   Result := FALSE;
   if CurActionInfo = nil then begin Result := TRUE; exit; end;
   if (CurAction = SM_TURN) then Result := TRUE;
   if (CurActionInfo^.Frame-2 = curframe) then Result := TRUE;
   if Feature.rfeaturestate = wfs_die then Result := FALSE;
   if Feature.rfeaturestate = wfs_sitdown then Result := FALSE;
end;

procedure   TCharClass.MakeFrame (aindex, CurTick: integer);
var
   i, block, bidx : integer;
   addx, addy : integer;
   gc, ga : integer;
   boflag : Boolean;
   ImageLib : TA2ImageLib;
begin
   if (Feature.rTeamColor > 0) and (Feature.rTeamColor < 32) then begin
      addx := CHarMaxSiezHalf;
      addy := CHarMaxSiezHalf - Feature.rTeamColor - Random (2);
   end else begin
      addx := CHarMaxSiezHalf;
      addy := CHarMaxSiezHalf;
   end;

   if aindex = OldMakeFrame then exit;
   OldMakeFrame := aindex;

   block := aindex div 500;
   bidx := aindex mod 500;

   OverImage.Free;
   OverImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);

   for i := 0 to CharImageBufferCount -1 do begin
      if CharImageBuffer[i].aImageNumber = aindex then begin
         if CharImageBuffer[i].aCharImage <> nil then begin
            CharImageBufferIndex := i;
            exit;
         end;
      end;
   end;

   CharImageBufferIndex := -1;
   for i := 0 to CharImageBufferCount -1 do begin
      if CharImageBuffer[i].aImageNumber = -1 then begin
         if CharImageBuffer[i].aCharImage <> nil then begin
            CharImageBufferIndex := i;
            break;
         end;
      end;
   end;

   if CharImageBufferIndex = -1 then begin
      CharImageBufferIndex := Random(CharImageBufferCount - 1);
      if CharImageBufferIndex > CharImageBufferCount then CharImageBufferIndex := 0;
      if CharImageBuffer[CharImageBufferIndex].aCharImage <> nil then begin
         CharImageBuffer[CharImageBufferIndex].aCharImage.Free;
         CharImageBuffer[CharImageBufferIndex].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
      end else begin
         CharImageBuffer[CharImageBufferIndex].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
      end;
   end else begin
      if CharImageBuffer[CharImageBufferIndex].aCharImage <> nil then begin
         CharImageBuffer[CharImageBufferIndex].aCharImage.Free;
         CharImageBuffer[CharImageBufferIndex].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
      end else begin
         CharImageBuffer[CharImageBufferIndex].aCharImage := TA2Image.Create (CharMaxSiez, CharMaxSiez, 0, 0);
      end;
   end;
   CharImageBuffer[CharImageBufferIndex].aImageNumber := aIndex;

   if Feature.rrace = RACE_MONSTER then begin
      with Feature do begin
         ImageLib := FAtzClass.GetImageLib (format ('z%d.atz', [rImageNumber]), CurTick);
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then
            CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+CHarMaxSiezHalf, ImageLib.Images[bidx].py+CHarMaxSiezHalf, FALSE);

         ImageLib := FAtzClass.GetImageLib (format ('z%dm.atz', [rImageNumber]), CurTick);
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then begin
            OverImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+CHarMaxSiezHalf, ImageLib.Images[bidx].py+CHarMaxSiezHalf, FALSE);
         end;
      end;
      CharImageBuffer[CharImageBufferIndex].aCharImage.Optimize;
      OverImage.Optimize;
      exit;
   end;

   with Feature do begin
      if not rboMan then ImageLib := FAtzClass.GetImageLib (format ('0%d%d.atz', [rArr[0],block]), CurTick)
      else               ImageLib := FAtzClass.GetImageLib (format ('1%d%d.atz', [rArr[0],block]), CurTick);
      if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+CHarMaxSiezHalf, ImageLib.Images[bidx].py+CHarMaxSiezHalf, FALSE);
      for i := 0 to 5 do begin
         if not Feature.rboMan then ImageLib := FAtzClass.GetImageLib (char(word('a')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick)
         else               ImageLib := FAtzClass.GetImageLib (char(word('n')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick);
         if ImageLib = nil then continue;
         if ImageLib.Count <= bidx then continue;
         if Feature.rArr[i*2+1] = 0 then begin
            if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, TRUE)
         end else begin
            GetGreenColorAndAdd (Feature.rArr[i*2+1], gc, ga);
            if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImageGreenConvert (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, gc, ga);
         end;
      end;
   end;

   boflag := TRUE;
   case block of
      0 : if CharTable0[bidx] = 1 then boflag := FALSE;
      1 : if CharTable1[bidx] = 1 then boflag := FALSE;
      2 : if CharTable2[bidx] = 1 then boflag := FALSE;
      3 : if CharTable3[bidx] = 1 then boflag := FALSE;
      4 : if CharTable4[bidx] = 1 then boflag := FALSE;
   end;

   if boflag then begin
      for i := 6 to 9 do begin
         if not Feature.rboMan then ImageLib := FAtzClass.GetImageLib (char(word('a')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick)
         else               ImageLib := FAtzClass.GetImageLib (char(word('n')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick);
         if ImageLib = nil then continue;
         if ImageLib.Count <= bidx then continue;
         if Feature.rArr[i*2+1] = 0 then begin
            if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, TRUE)
         end else begin
            GetGreenColorAndAdd (Feature.rArr[i*2+1], gc, ga);
            if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImageGreenConvert (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, gc, ga);
         end;
      end;
      exit;
   end;

   if not Feature.rboMan then ImageLib := FAtzClass.GetImageLib (char(word('a')+9) + format ('%d%d.atz', [Feature.rArr[9*2],block]), CurTick)
   else               ImageLib := FAtzClass.GetImageLib (char(word('n')+9) + format ('%d%d.atz', [Feature.rArr[9*2],block]), CurTick);
   if (ImageLib <> nil) and (ImageLib.Count > bidx) then begin
      if Feature.rArr[9*2+1] = 0 then begin
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, TRUE)
      end else begin
         GetGreenColorAndAdd (Feature.rArr[9*2+1], gc, ga);
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImageGreenConvert (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, gc, ga);
      end;
   end;

   for i := 6 to 8 do begin
      if not Feature.rboMan then ImageLib := FAtzClass.GetImageLib (char(word('a')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick)
      else               ImageLib := FAtzClass.GetImageLib (char(word('n')+i) + format ('%d%d.atz', [Feature.rArr[i*2],block]), CurTick);
      if ImageLib = nil then continue;
      if ImageLib.Count <= bidx then continue;
      if Feature.rArr[i*2+1] = 0 then begin
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImage (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, TRUE)
      end else begin
         GetGreenColorAndAdd (Feature.rArr[i*2+1], gc, ga);
         if (ImageLib <> nil) and (ImageLib.Images[bidx] <> nil) then CharImageBuffer[CharImageBufferIndex].aCharImage.DrawImageGreenConvert (ImageLib.Images[bidx], ImageLib.Images[bidx].px+addx, ImageLib.Images[bidx].py+addy, gc, ga);
      end;
   end;

   CharImageBuffer[CharImageBufferIndex].aCharImage.Optimize;
   OverImage.Optimize;
end;

procedure   TCharClass.Paint(CurTick: integer);
begin
   MakeFrame (ImageNumber, CurTick);
//   if CharImageBuffer[CharImageBufferIndex].aCharImage = nil then exit;
   case Feature.rHideState of
      hs_100 : // 일반적인 모습
         begin
            BackScreen.DrawImageKeyColor (CharImageBuffer[CharImageBufferIndex].aCharImage, RealX-CHarMaxSiezHalf, RealY-CHarMaxSiezHalf);
            BackScreen.DrawImageOveray (OverImage, RealX-CHarMaxSiezHalf, RealY-CHarMaxSiezHalf, 20);
         end;
      hs_0   : // 완전히 보이지 안을경우 그리지 않음
         if id = CharCenterID then BackScreen.DrawRefractive (CharImageBuffer[CharImageBufferIndex].aCharImage, RealX-CHarMaxSiezHalf, RealY-CHarMaxSiezHalf, 4, 3);
      hs_1   : // 은신중임 CharCenterID 일경우 사용자편의로 약간파란색이 가미된 경우 Refracrange : 4 overValue : 3
         BackScreen.DrawRefractive (CharImageBuffer[CharImageBufferIndex].aCharImage, RealX-CHarMaxSiezHalf, RealY-CHarMaxSiezHalf, 4, 3);
      hs_99  : // 은신중 사용자가 은신보는 마법등을 사용시 약간 보이는경우 Refracrange : 4 overValue : 0
         BackScreen.DrawRefractive (CharImageBuffer[CharImageBufferIndex].aCharImage, RealX-CHarMaxSiezHalf, RealY-CHarMaxSiezHalf, 4, 0);
   end;
   if StructedTick <> 0 then BackScreen.DrawStructed (RealX, RealY, 36, StructedPercent); // Char 머리위의 에너지바
end;

function    TCharClass.Update ( CurTick: integer) : Integer;
   procedure NextMessage;
   var
      RMsg : TRecordMessage;
   begin
      CurActionInfo := nil;
      ViewMessage (RMsg);
      if RMsg.rMsg <> 0 then begin
         GetMessage (RMsg);
         with RMsg do
            ProcessMessage (rMsg, rdir, rx, ry, rfeature, rmotion);
      end else begin
         if CurTick > TurningTick + 200 then begin
            TurningTick := CurTick;
            CurActionInfo := FindAnimation ( AM_TURNNING, dir);
            SetCurrentFrame (CurActionInfo,0, CurTick);
            CurAction := SM_TURN;
         end else begin
            CurActionInfo := FindAnimation ( AM_TURN, dir);
            SetCurrentFrame (CurActionInfo, 0, CurTick);
            CurAction := SM_TURN;
         end;
      end;
   end;
var
   PassTick : integer;
begin
   Result := 0;

   if (BubbleList.Count <> 0) and (BubbleTick + 300 < CurTick) then BubbleList.Clear;
   if StructedTick + 200 < CurTick then StructedTick := 0;

   if CurActionInfo <> nil then begin
      PassTick := CurTick - FrameStartTime;                    // 행동이 끝났으면
      if PassTick > (CurActionInfo^.Frametime) then begin
         Result := 1;
         curframe := curframe + 1;
         if CurActionInfo^.Frame <= curframe then NextMessage
         else SetCurrentFrame (CurActionInfo, curframe, CurTick);
      end;
   end else begin
      NextMessage;
   end;
   if CharCenterId = id then begin
      CharPosX := x; CharPosY := y;
      BackScreen.SetCenter (RealX, RealY);
      Map.SetCenter (x, y);
   end;
end;


///////////////////////////////////
//        Char List
///////////////////////////////////

constructor TCharList.Create (aAtzClass: TAtzClass);
begin
{
   for i := 0 to 32-1 do
      ColorIndex[i] := WinRGB (Color16Table[i*3] shr 3, Color16Table[i*3+1] shr 3, Color16Table[i*3+2] shr 3);
}
   FAtzClass := aAtzClass;
   CharDataList := TList.Create;
   ItemDataList := TList.Create;
   DynamicObjDataList := TList.Create;

   MagicDataList := TList.Create;
end;

destructor  TCharList.Destroy;
var i : integer;
begin
   for i := 0 to MagicDataList.Count -1 do TMovingMagicClass (MagicDataList[i]).Free;
   MagicDataList.Free;

   for i := 0 to ItemDataList.Count -1 do TItemClass (ItemDataList[i]).Free;
   ItemDataList.Free;

   for i := 0 to DynamicObjDataList.Count -1 do TDynamicObject (DynamicObjDataList[i]).Free; // Dynamicitem
   DynamicObjDataList.Free;

   for i := 0 to CharDataList.Count -1 do TCharClass (CharDataList[i]).Free;
   CharDataList.Free;

   inherited destroy;
end;

procedure   TCharList.Clear;
var
   i : integer;
begin
   for i := 0 to ItemDataList.Count -1 do TItemClass (ItemDataList[i]).Finalize;
   for i := 0 to CharDataList.Count -1 do TCharClass (CharDataList[i]).Finalize;
   for i := 0 to MagicDataList.Count -1 do TMovingMagicClass (MagicDataList[i]).Free;
   MagicDataList.Clear;
   for i := 0 to DynamicObjDataList.Count -1 do TDynamicObject (DynamicObjDataList[i]).Finalize;
end;

procedure   TCharList.AddChar (aName: Widestring; aId, adir, ax, ay: integer; afeature: TFeature);
var
   i : integer;
   CharClass : TCharClass;
begin
   for i := 0 to CharDataList.Count -1 do begin
      CharClass := CharDataList[i];
      if CharClass.Used = FALSE then begin
         CharClass.Initialize (aName, aId, adir, ax, ay, afeature);
         exit;
      end;
   end;
   CharClass := TCharClass.Create (FAtzClass);
   CharClass.Initialize (aName, aId, adir, ax, ay, afeature);
   CharDataList.Add (CharClass);
//   if opening then Charclass.ProcessMessage (SM_MOTION,
end;

function    TCharList.GetChar (aId: integer): TCharClass;
var i : integer;
begin
   Result := nil;
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass(CharDataList[i]).Used = FALSE then continue;
      if TCharClass(CharDataList[i]).Id = aId then begin
         Result := TCharClass (CharDataList[i]);
         exit;
      end;
   end;
end;

procedure   TCharList.DeleteChar (aId: integer);
var i : integer;
begin
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass(CharDataList[i]).Used = FALSE then continue;
      if TCharClass(CharDataList[i]).Id = aId then begin
         TCharClass (CharDataList[i]).Finalize;
         exit;
      end;
   end;
end;

procedure   TCharList.AddItem (aItemName: string; aRace: byte;aId, ax, ay, aItemShape, aItemColor: integer);
var
   i : integer;
   ItemClass : TItemClass;
begin
   for i := 0 to ItemDataList.Count -1 do begin
      ItemClass := ItemDataList[i];
      if ItemClass.Used = FALSE then begin
         ItemClass.Initialize (aItemName, aRace, aId, ax, ay, aitemShape, aItemColor);
         exit;
      end;
   end;
   ItemClass := TItemClass.Create (FAtzClass);
   ItemClass.Initialize (aItemName, aRace, aId, ax, ay, aItemShape, aItemColor);
   ItemDataList.Add (ItemClass);
end;

function    TCharList.GetItem (aId: integer): TItemClass;
var i : integer;
begin
   Result := nil;
   for i := 0 to ItemDataList.Count -1 do begin
      if TItemClass(ItemDataList[i]).Used = FALSE then continue;
      if TItemClass(ItemDataList[i]).Id = aId then begin
         Result := TItemClass (ItemDataList[i]);
         exit;
      end;
   end;
end;

procedure   TCharList.DeleteItem (aId: integer);
var i : integer;
begin
   for i := 0 to ItemDataList.Count -1 do begin
      if TItemClass(ItemDataList[i]).Used = FALSE then continue;
      if TItemClass(ItemDataList[i]).Id = aId then begin
         TItemClass (ItemDataList[i]).Finalize;
         exit;
      end;
   end;
end;

procedure   TCharList.AddDynamicObjItem (aItemName: string; aId, ax, ay, aItemShape: integer; aStartFrame, aEndFrame: Word; aState: byte; aDynamicGuard: TDynamicGuard);
var
   i : integer;
   DynamicObject : TDynamicObject;
begin
   for i := 0 to DynamicObjDataList.Count -1 do begin
      DynamicObject := DynamicObjDataList[i];
      if DynamicObject.Used = FALSE then begin
         DynamicObject.Initialize (aItemName, aId, ax, ay, aItemShape, aStartFrame, aEndFrame, aState, aDynamicGuard);
         exit;
      end;
   end;
   DynamicObject := TDynamicObject.Create (FAtzClass);
   DynamicObject.Initialize (aItemName, aId, ax, ay, aItemShape, aStartFrame, aEndFrame, aState, aDynamicGuard);
   DynamicObjDataList.Add (DynamicObject);
end;

procedure   TCharList.SetDynamicObjItem (aId : integer; aState: byte; aStartFrame, aEndFrame: Word);
var
   i : integer;
   DynamicObject : TDynamicObject;
begin
   for i := 0 to DynamicObjDataList.Count -1 do begin
      DynamicObject := DynamicObjDataList[i];
      if DynamicObject.Id = aID then begin
         DynamicObject.DynamicObjectState := aState;
         DynamicObject.FStartFrame := aStartFrame;
         DynamicObject.FEndFrame := aEndFrame;
         exit;
      end;
   end;
end;

function    TCharList.GeTDynamicObjItem (aId: integer): TDynamicObject;
var i : integer;
begin
   Result := nil;
   for i := 0 to DynamicObjDataList.Count -1 do begin
      if TDynamicObject(DynamicObjDataList[i]).Used = FALSE then continue;
      if TDynamicObject(DynamicObjDataList[i]).Id = aId then begin
         Result := TDynamicObject (DynamicObjDataList[i]);
         exit;
      end;
   end;
end;

procedure   TCharList.DeleteDynamicObjItem (aId: integer);
var
   i : integer;
begin
   for i:= 0 to DynamicObjDataList.Count -1 do begin
      if TDynamicObject(DynamicObjDataList[i]).Used = FALSE then continue;
      if TDynamicObject(DynamicObjDataList[i]).Id = aId then begin
         TDynamicObject(DynamicObjDataList[i]).Finalize;
         exit;
      end;
   end;
end;


function TCharList.UpDate (CurTick: integer): integer;
var
   i : integer;
begin
   Result := 0;
   for i := MagicDataList.Count -1 downto 0 do begin
      if TMovingMagicClass (MagicDataList[i]).Used = FALSE then continue;
      if TMovingMagicClass (MagicDataList[i]).MagicCurAction = MAT_DESTROY then
         TMovingMagicClass (MagicDataList[i]).Finalize;
   end;
   for i := 0 to MagicDataList.Count -1 do begin
      if TMovingMagicClass (MagicDataList[i]).Used = FALSE then continue;
      if TMovingMagicClass (MagicDataList[i]).Update (CurTick) <> 0 then Result := 1;
   end;

   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      if TCharClass (CharDataList[i]).Update (CurTick) <> 0 then Result := 1;
      {
      if TCharClass (CharDataList[i]).BgEffect <> nil then
         if TCharClass (CharDataList[i]).BgEffect.Update (CurTicK) <> 0 then Result := 1; // BgEffect;
      }
   end;

   for i := 0 to ItemDataList.Count -1 do begin
      if TItemClass (ItemDataList[i]).Used = FALSE then continue;
      if TItemClass (ItemDataList[i]).Update (CurTick) <> 0 then Result := 1;
   end;

   for i := 0 to DynamicObjDataList.Count -1 do begin // aniitem
      if TDynamicObject (DynamicObjDataList[i]).Used = FALSE then continue;
      if TDynamicObject (DynamicObjDataList[i]).Update (CurTick) <> 0 then Result := 1;
   end;

end;

function    TCharList.UpDataBgEffect (CurTick: integer): integer;
var
   i : integer;
begin
   Result := 0;
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).BgEffect <> nil then
         if TCharClass (CharDataList[i]).BgEffect.Update (CurTicK) <> 0 then Result := 1; // BgEffect;
   end;
end;

procedure   TCharList.GetVarRealPos (var aid, ax, ay: integer);
var i : integer;
begin
   if aid = 0 then exit;
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      if TCharClass (CharDataList[i]).id = aid then begin
         ax := TCharClass(CharDataList[i]).RealX;
         ay := TCharClass(CharDataList[i]).RealY;
         exit;
      end;
   end;
end;

function    TCharList.isMovable (xx, yy: integer): Boolean;
var
   i, n : integer;
begin
   Result := FALSE;
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      // 2000.12.05 죽었을경우 케릭터가 지나갈수 있도록 설정 by ankudo
      if CharMoveFrontdieFlag then begin // 서버에서 CharMoveFrontdieFlag를 TRUE로 설정시 죽어있을경우 지나감
         if TCharClass (CharDataList[i]).Feature.rfeaturestate <> wfs_die then
            if (TCharClass (CharDataList[i]).X = xx) and (TCharClass (CharDataList[i]).Y = yy) then exit;
      end else begin
         if (TCharClass (CharDataList[i]).X = xx) and (TCharClass (CharDataList[i]).Y = yy) then exit;
      end;
      if TCharClass (CharDataList[i]).ID = CharCenterId then
         BackScreen.CenterchangeIDPos(TCharClass (CharDataList[i]).X-xx, TCharClass(CharDataList[i]).Y-yy);
   end;
   // 2000.10.01 문파초석을 StaticItem으로써 간주하여 캐릭터가 올라가지 못하도록 수정 by Lee.S.G
   for i := 0 to ItemDataList.Count - 1 do begin
      if TItemClass (ItemDataList[i]).Used = FALSE then continue;
      if TItemClass (ItemDataList[i]).Race = RACE_STATICITEM then begin // race로 구분 010127 ankudo
         if (TItemClass (ItemDataList[i]).X = xx) and (TItemClass (ItemDataList[i]).Y = yy) then exit;
      end;
   end;
   // DynamicObject item
   for i := 0 to DynamicObjDataList.Count - 1 do begin
      with TDynamicObject (DynamicObjDataList[i]) do begin
         if Used = FALSE then continue;
         if isDynamicObjectStaticItemID(Id) then begin
            if (X = xx) and (Y = yy) then exit;
            for n := 0 to DynamicGuard.aCount -1 do begin
               if (DynamicGuard.aGuardX[n] + X = xx) and (DynamicGuard.aGuardY[n] + Y = yy) then exit;
            end;
         end;
      end;
   end;
   Result := TRUE;
end;

procedure   TCharList.MouseMove (x, y: integer);
var i : integer;
begin
   SelectedItem := 0;
   for i := 0 to ItemDataList.Count -1 do begin
      if TItemClass (ItemDataList[i]).Used = FALSE then continue;
      if TItemClass (ItemDataList[i]).IsArea ( x, y) then
         SelectedItem := TItemClass (ItemDataList[i]).id;
   end;

   SelectedDynamicItem := 0;  // Dynamicitem
   for i := 0 to DynamicObjDataList.Count -1 do begin
      if TDynamicObject (DynamicObjDataList[i]).Used = FALSE then continue;
      if TDynamicObject (DynamicObjDataList[i]).IsArea ( x, y) then
         SelectedDynamicItem := TDynamicObject (DynamicObjDataList[i]).id;
   end;

   SelectedChar := 0;
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      if TCharClass (CharDataList[i]).IsArea ( x, y) then
         SelectedChar := TCharClass (CharDataList[i]).id;
   end;
end;

procedure   TCharList.Paint (CurTick: integer);
   function GetGap (a1, a2:integer):integer;
   begin
      if a1 > a2 then Result := a1 - a2
      else Result := a2 - a1;
   end;
var
   i, j, oi, cy, n, m: integer;
   Cl : TCharClass;
   IC : TItemClass;
   AIC : TDynamicObject;
   po : PTObjectData;
   MapCell : TMapCell;
   subMapCell : TMapCell;
   chardieidx : integer;
begin
   for i := 0 to ItemDataList.Count -1 do begin
      IC := TItemClass(ItemDataList[i]);
      if IC.Used = FALSE then continue;
      if IC.Race = RACE_STATICITEM then continue;
//      if isStaticItemID(IC.Id) then continue; race로 판단함
      TItemClass (ItemDataList[i]).Paint;
   end;

   chardieidx := 0; // 죽었을경우 먼저 그림
   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      Cl := CharDataList[i];
      if Cl.Feature.rfeaturestate = wfs_die then begin
         CharDataList.Exchange (chardieidx, i);
         inc (chardieidx);
      end;
   end;

   for i := 0 to MagicDataList.Count -1 do begin
      if TMovingMagicClass (MagicDataList[i]).Used = FALSE then continue;
      TMovingMagicClass (MagicDataList[i]).Paint;
   end;

   for j := Map.Cy-VIEWHEIGHT-3 to Map.Cy+VIEWHEIGHT-1+14 do begin


      for i := Map.Cx-VIEWWIDTH-8 to Map.Cx+VIEWWIDTH do begin
         MapCell := Map.GetCell (i, j);
         oi := MapCell.ObjectId;
         if oi <> 0 then begin
            po := ObjectDataList[oi];
            if po <> nil then begin
               if po.Style = TOB_follow then begin
                  if CurTick > Map.GetMapCellTick(i,j) + po.AniDelay then begin
                     Map.SetMapCellTick (i,j,CurTick);
                     if po.StartID = po.ObjectId then begin
                        inc (MapCell.ObjectNumber);
                        if MapCell.ObjectNumber > po.nBlock -1 then MapCell.ObjectNumber := 0;
                        Map.SetCell (i, j, MapCell);
                        for m := j - po.MHeight to j + (po.MHeight div 2)+2 do begin
                           for n := 0 to po.EndID - po.StartID do begin
                              SubMapCell := Map.GetCell (i+n+(po.IWidth div 32)-1, m);
                              if (SubMapCell.ObjectId > 0) and  (SubMapCell.ObjectId > po.StartID) and (SubMapCell.ObjectId <= po.EndID) then begin
                                 Map.SetMapCellTick (i+n+(po.IWidth div 32)-1,m,CurTick);
                                 inc(SubMapCell.ObjectNumber);
                                 if subMapCell.ObjectNumber > po.nBlock -1 then subMapCell.ObjectNumber := 0;
                                 Map.SetCell (i+n+(po.IWidth div 32)-1, m, subMapCell);
                              end;
                           end;
                        end;
                     end else begin
                     end;
                  end;
               end else MapCell.ObjectNumber := 0;
               BackScreen.DrawImageKeyColor( ObjectDataList.GetObjectImage (oi, MapCell.ObjectNumber, CurTick), i*UNITX, j*UNITY);
            end;
         end;
      end;
{ 예전 Object Draw
      for i := Map.Cx-VIEWWIDTH-8 to Map.Cx+VIEWWIDTH do begin
         MapCell := Map.GetCell (i, j);
         oi := MapCell.ObjectId;
         if oi <> 0 then begin
            po := ObjectDataList[oi];
            if po <> nil then begin
               BackScreen.DrawImageKeyColor( ObjectDataList.GetObjectImage (oi, 0, CurTick), i*UNITX, j*UNITY);
            end;
         end;
      end;
}
      for i := 0 to DynamicObjDataList.Count -1 do begin  // DynamicObjPaint
         AIC := TDynamicObject(DynamicObjDataList[i]);
         if AIC.Used = FALSE then continue;
         if isDynamicObjectStaticItemID(AIC.Id) = FALSE then continue;
         if AIC.y <> j then continue;
         TDynamicObject (DynamicObjDataList[i]).Paint;
      end;

      for i := 0 to CharDataList.Count -1 do begin // 케릭터 paint
         if TCharClass (CharDataList[i]).Used = FALSE then continue;
         Cl := CharDataList[i];
         cy := (CL.RealY+UNITYS) div UNITY;
         if ((CL.Realy+UNITYS) mod UNITY) > (UNITY div 2) then cy := cy + 1;
         if j = cy then begin
            if (Cl.id = SelectedChar) then CL.paint(CurTick)
            else Cl.paint(CurTick);
         end;

         if Cl.Feature.rEffectNumber > 0 then Cl.AddBgEffect (cl.x, cl.y, Cl.Feature.rEffectNumber-1, Cl.Feature.rEffectKind);
         if j = cy then begin
            if Cl.BgEffect <> nil then begin
               Cl.BgEffect.Paint (Cl.Realx+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2 +2], Cl.Realy+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2+1 +2]); // overvalue, Speed 때문에 +2
            end;
         end;
{
         if Cl.dir > 4 then begin // y좌표 다음 object가 Effect위에 그려지는것 방지 Dir 4이상만 해당
            if j = cy + 1 then begin
               if Cl.Feature.rEffectNumber > 0 then Cl.AddBgEffect (cl.x, cl.y, Cl.Feature.rEffectNumber-1, Cl.Feature.rEffectKind);
               if Cl.BgEffect <> nil then begin
                  Cl.BgEffect.Paint (Cl.Realx+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2 +2], Cl.Realy+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2+1 +2]); // overvalue, Speed 때문에 +2
               end;
            end;
         end else begin
            if j = cy - 1 then begin
               if Cl.Feature.rEffectNumber > 0 then Cl.AddBgEffect (cl.x, cl.y, Cl.Feature.rEffectNumber-1, Cl.Feature.rEffectKind);
               if Cl.BgEffect <> nil then begin
                  Cl.BgEffect.Paint (Cl.Realx+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2 +2], Cl.Realy+ cl.BgEffect.EffectPositionData.rArr[Cl.dir *2+1 +2]); // overvalue, Speed 때문에 +2
               end;
            end;
         end;
}
      end;

      for i := 0 to ItemDataList.Count -1 do begin
         IC := TItemClass(ItemDataList[i]);
         if IC.Used = FALSE then continue;
         if IC.Race <> RACE_STATICITEM then continue;
//         if isStaticItemID(IC.Id) = FALSE then continue; race로 판단함
         if IC.y <> j then continue;
         TItemClass (ItemDataList[i]).Paint;
      end;
   end;
end;

procedure   TCharList.PaintText (aCanvas: TCanvas);
var
   i : integer;
   Cl : TCharClass;
   Col : integer;
begin
   for i := 0 to DynamicObjDataList.Count -1 do begin
      if TDynamicObject (DynamicObjDataList[i]).DynamicObjName = '' then continue;
      if TDynamicObject (DynamicObjDataList[i]).Used = FALSE then continue;
      if TDynamicObject (DynamicObjDataList[i]).id = SelectedDynamicItem then begin
         Col := WinRGB (31, 31, 31);
         BackScreen.DrawName ( aCanvas, TDynamicObject (DynamicObjDataList[i]).RealX, TDynamicObject (DynamicObjDataList[i]).RealY, TDynamicObject (DynamicObjDataList[i]).DynamicObjName, Col);
      end;
   end;

   for i := 0 to ItemDataList.Count -1 do begin
      if TItemClass (ItemDataList[i]).Used = FALSE then continue;
      if TItemClass (ItemDataList[i]).id = SelectedItem then begin
         Col := WinRGB (31, 31, 31);
         BackScreen.DrawName ( aCanvas, TItemClass (ItemDataList[i]).RealX, TItemClass (ItemDataList[i]).RealY, TItemClass (ItemDataList[i]).ItemName, Col);
      end;
   end;

   for i := 0 to CharDataList.Count -1 do begin
      if TCharClass (CharDataList[i]).Used = FALSE then continue;
      Cl := CharDataList[i];
      if Cl.Feature.rHideState = hs_100 then begin
         if (Cl.id = SelectedChar) then begin
            Col := WinRGB (31, 31, 31);
            BackScreen.DrawName ( aCanvas, Cl.RealX, Cl.RealY, Cl.Name, Col);
         end;
      end;
      if Cl.BubbleList.Count <> 0 then begin
         BackScreen.DrawBubble ( aCanvas, Cl.RealX, Cl.RealY, Cl.BubbleList);
      end;
   end;
end;

procedure   TCharList.AddMagic (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick: integer; aType: byte);
var
//   i : integer;
   MagicClass : TMovingMagicClass;
begin
{
   for i := 0 to MagicDataList.Count -1 do begin
      MagicClass := MagicDataList[i];
      if MagicClass.Used = FALSE then begin
         MagicClass.Initialize (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick, aType);
         exit;
      end;
   end;
}
   MagicClass := TMovingMagicClass.Create (FAtzClass);
   MagicClass.Initialize (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick, aType);
   MagicDataList.Add (MagicClass);
{
   case aType of
      0 :
         begin
            MagicClass := TMovingMagicClass.Create (FAtzClass);
            MagicClass.Initialize (sid, eid, adeg, aspeed, ax, ay, atx, aty, aMagicShape, CurTick, aType);
            MagicDataList.Add (MagicClass);
         end;
      1 :
         begin
            for i := 0 to 10-1 do begin
               MagicClass := TMovingMagicClass.Create (FAtzClass);
               MagicClass.Initialize (sid, eid, i*36, 25, ax, ay, atx, aty, aMagicShape, CurTick, aType);
               MagicDataList.Add (MagicClass);
            end;
         end;
   end;
}
end;
{
function TCharList.isStaticItemID(aid : LongInt) : Boolean;
var id : Longint;
begin
   Result := FALSE;
   id := aid - 10000;
   if (id mod 10) = 4 then Result := TRUE;
end;
}
function TCharList.isDynamicObjectStaticItemID(aid : LongInt) : Boolean;
var id : Longint;
begin
   Result := FALSE;
   id := aid - 10000;
   if (id mod 10) = 5 then Result := TRUE;
end;

end.






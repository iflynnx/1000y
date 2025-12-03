unit FMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DXClass, DirectX, DXSounds, uSound, Cltype, A2Form, A2Img, uAnsTick,
  ExtCtrls, StdCtrls, BackScrn, CharCls, ClMap, AtzCls, Deftype, subutil,
  PaintLabel, objcls, tilecls, adeftype, AUtil32, IniFiles, CTable, mmsystem,
  uPersonBat; //Log,
  //uActiveMusic;
type
  TFormData = record
     rForm : TForm;
     rOldParent: integer;
     rA2Form : TA2Form;
  end;
  PTFormData = ^TFormData;

  TFrmM = class(TForm)
    PaintLabel: TPaintLabel;
    Timer1: TTimer;
    DXDraw: TDXDraw;
    DXWaveList1: TDXWaveList;
    DXSound1: TDXSound;
    DXTimer1: TDXTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure PaintLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintLabelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintLabelClick(Sender: TObject);
    procedure PaintLabelDblClick(Sender: TObject);
    procedure PaintLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintLabelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PaintLabelStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure Time1TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXTimer1Timer(Sender: TObject; LagCount: Integer);
  private
    { Private declarations }
    FormList : TList;
    function  GetMouseDirection: word;
    procedure DrawChatList;
  public
    EventTick : integer;
    DragItem: TDragItem;

    BottomUpImage : TA2Image;
    AttribLeftImage : TA2Image;
    SoundManager : TSoundManager;

//    BaseAudio : TBaseAudio;
//    BaseAudioVolume : integer;
    ChatList : TStringList;
    procedure AddChat ( astr: string; fcolor, bcolor: integer);
    procedure AddA2Form (aform: TForm; aA2Form: TA2Form);
    procedure DelA2Form (aform:TForm; aA2Form : TA2Form);
    procedure SaveAndDeleteAllA2Form;
    procedure RestoreAndAddAllA2Form;

    procedure SetA2Form (aForm: TForm; aA2Form: TA2Form);
    procedure MoveProcess;
    procedure CheckAndSendClick;
    procedure MessageProcess (var code: TWordComData);

    procedure OnAppMessage (var Msg: TMsg; var Handled: Boolean);
    procedure CheckSome (var code: TWordComData);
  end;

var
   FrmM: TFrmM;
   Keyshift : TShiftState;
var
   GrobalClick : TCClick;
   ClickTick : integer = 0;
   HitTick : integer = 0;
   boShiftAttack : Boolean = TRUE;
   mousecheck : boolean = FALSE;
   RightButtonDown : Boolean = FALSE;

   mouseX, mousey : integer;
   MouseCellX, MouseCelly: integer;

   boShowChat : Boolean = FALSE;

   ClientIni : TIniFile;
//   BaseAudio : TBaseAudio;
//   ActiveBaseAudioList : TActiveBaseAudioList;

implementation

uses
   FLogOn, FSelChar, FBottom, FAttrib, FQuantity, FSearch, FExchange, FSound, FDepository,
   FSearchUser, FbatList, FMuMagicOffer, FcMessageBox;
   //, FNpcView, FMunpaCreate, FMunpaimpo, FcMessageBox, FmunpaWarOffer;


{$R *.DFM}
{$O+}
var
   eventbuffer : array [0..10-1] of integer;

procedure TFrmM.OnAppMessage (var Msg: TMsg; var Handled: Boolean);
begin
   if GetAsyncKeyState(VK_SNAPSHOT) <> 0 then if FrmM.Active then FrmBottom.ClientCapture;

   if (Msg.message >= WM_MOUSEMOVE) and (Msg.message <= WM_MBUTTONDBLCLK) then begin
      inc (eventbuffer[Msg.message - WM_MOUSEMOVE]);
   end;
end;

procedure TFrmM.CheckSome (var code: TWordComData);
var
   PsSCheck : PTSCheck;
   CCheck : TCCheck;
begin
   PsSCheck := @Code.data;
   case PsSCheck^.rCheck of
      1 :
         begin
            CCheck.rMsg := CM_CHECK;
            CCheck.rCheck := PsSCheck^.rCheck;
            CCheck.rTick := 1;
            if not FileExists ('.\South.map') then CCheck.rTick := 0;
            if not FileExists ('.\Southobj.obj') then CCheck.rTick := 0;
            if not FileExists ('.\Southrof.Obj') then CCheck.rTick := 0;
            if not FileExists ('.\Southtil.til') then CCheck.rTick := 0;
         end;
      2 :
         begin
            CCheck.rMsg := CM_CHECK;
            CCheck.rCheck := PsSCheck^.rCheck;
            CCheck.rTick := TimeGetTime;
         end;
   end;
   FrmLogOn.SocketAddData (sizeof(CCheck), @CCheck);
end;

procedure TFrmM.FormCreate(Sender: TObject);
begin
   if doFullScreen in DxDraw.Options then BorderStyle := bsNone
   else BorderStyle := bsDialog;

   Chdir (ExtractFilePath (Application.ExeName));

   ClientIni := TIniFile.Create ('.\ClientIni.ini');
   mainFont := ClientIni.ReadString ('FONT', 'FontName','Arial');  // font read
   // FrmM Font Set
   FrmM.Font.Name := mainFont;
   A2FontClass.SetFont (MainFont);

   FormList := TList.Create;

   SoundManager := TSoundManager.Create (DxSound1, 'wav\wav1000y.atw', 'wav\effect.atw', DXWaveList1);
   SoundManager.Volume := ClientIni.ReadInteger ('SOUND','BASEVOLUME', -1000);

//   BaseAudio := TBaseAudio.Create;
//   BaseAudio.SetVolume (SoundManager.Volume);

   if ClientIni.ReadString ('CLIENT','SOUND','ON') <> 'ON' then boUseSound := FALSE
   else boUseSound := TRUE;

   FrmM.SoundManager.Volume := ClientIni.ReadInteger ('SOUND','BASEVOLUME', -2000);
   FrmM.SoundManager.Volume2 := ClientIni.ReadInteger ('SOUND','EFFECTVOLUME', -2000);

//   ActiveBaseAudioList := TActiveBaseAudioList.Create;

   SoundManager.PlayBaseAudio ('logon.wav', 5);
//   SoundManager.PlayBaseAudio ('1003.wav', 5);

   BottomUpImage := TA2Image.Create (4, 4, 0, 0);
   BottomUpImage.LoadFromFile ('bottomup.bmp');
   AttribLeftImage := TA2Image.Create (4, 4, 0, 0);
   AttribLeftImage.LoadFromFile ('attribleft.bmp');

   BackScreen := TBackScreen.Create;
   DragItem := TDragItem.Create;
   TileDataList := TTileDataList.Create;
   ObjectDataList := TObjectDataList.Create;
   RoofDataList := TObjectDataList.Create;

   Map := TMap.Create;
   EffectPositionClass := TEffectPositionClass.Create;
   Animater := TAnimater.Create;
   AtzClass := TAtzClass.Create('.\sprite\');
   EtcAtzClass := TEtcAtzClass.Create;

   CharList := TCharList.Create (AtzClass);
   ChatList := TStringList.Create;

   PersonBat := TPersonBat.Create;

   Application.OnMessage := OnAppMessage;
end;

procedure TFrmM.FormDestroy(Sender: TObject);
begin

   ClientIni.WriteString ('FONT', 'FontName', mainFont);
   ClientIni.WriteInteger ('SOUND','EFFECTVOLUME', SoundManager.Volume);

   ChatList.free;
   CharList.Free;
   AtzClass.Free;
   Animater.Free;
   EtcAtzClass.Free;
   Map.Free;

   TileDataList.Free;
   ObjectDataList.Free;
   RoofDataList.Free;

   DragItem.Free;
   BackScreen.Free;

   AttribLeftImage.Free;
   BottomUpImage.Free;
   SoundManager.Free;

//   ActiveBaseAudioList.Free;
   PersonBat.Free;

   DXSound1.Finalize;
   FormList.Free;
   ClientIni.Free;
end;

procedure TFrmM.DrawChatList;
var
   i: integer;
begin
//   A2SetFontColor (RGB (12, 12, 12)); // back
   for i := 0 to ChatList.Count -1 do begin
      ATextOut (BackScreen.Back, 20+1, i*16+20+1, WinRGB (1, 1, 1), ChatList[i]);
//      A2TextOut (BackScreen.Back, 20+1, i*16+20+1, ChatList[i]);
   end;

//   A2SetFontColor (clsilver);         // front
   for i := 0 to ChatList.Count -1 do begin
      ATextOut (BackScreen.Back, 20, i*16+20, WinRGB (24, 24, 24), ChatList[i]);
//      A2TextOut (BackScreen.Back, 20, i*16+20, ChatList[i]);
   end;
end;

procedure  TFrmM.AddChat ( astr: string; fcolor, bcolor: integer);
var
   str, rdstr: string;
   col : Integer;
   addflag : Boolean;
begin
   addflag := FALSE;
   str := astr;
   while TRUE do begin
      str := GetValidStr3 (str, rdstr, #13);
      if rdstr = '' then break;

      if chat_outcry then begin // 외치기
         if rdstr[1] = '[' then addflag := TRUE;
      end;

      if chat_Guild then begin  // 길드
         if rdstr[1] = '<' then addflag := TRUE;
      end;

      if chat_notice then begin // 공지사항
         if bcolor = 16912 then addflag := TRUE;
      end;

      if chat_normal then begin  // 일반유저
         if not(bcolor = 16912) and not(rdstr[1] = '<') and not(rdstr[1] = '[') then begin
            addflag := TRUE;
         end;
      end;

      if Addflag then begin
         if ChatList.Count >= 20 then ChatList.delete (0);
         col := MakeLong (fcolor, bcolor);
         ChatList.addObject (rdstr, TObject (col) );
         if SaveChatList.Count > 500 then SaveChatList.Delete (0);
         SaveChatList.Add (rdstr);
      end;
   end;
end;

procedure  TFrmM.SetA2Form (aForm:TForm; aA2Form: TA2Form);
var
   flag : Boolean;
   i: integer;
   pf : PTFormData;
begin
   if (Formlist.Count > 0) and (PTFormData (FormList[0])^.rForm = aForm) then exit;

   for i := 0 to FormList.Count -1 do begin
      pf := FormList[i];
      if pf^.rForm = aForm then begin
         FormList.Delete (i);
         FormList.Insert (0, pf);
         break;
      end;
   end;

   for i := 0 to FormList.count -1 do begin
      pf := FormList[i];
      flag := pf^.rForm.Visible;
      pf^.rForm.visible := FALSE;
      pf^.rForm.parentwindow := 0;
      pf^.rForm.parentwindow := handle;
      pf^.rForm.visible := flag;
   end;
end;

procedure TFrmM.SaveAndDeleteAllA2Form;
var
   i: integer;
   pf : PTFormData;
begin
   for i := 0 to FormList.Count -1 do begin
      pf := FormList[i];
      pf^.rForm.ParentWindow := pf^.roldParent;
   end;
end;

procedure TFrmM.RestoreAndAddAllA2Form;
var
   i: integer;
   pf : PTFormData;
begin
   for i := 0 to FormList.Count -1 do begin
      pf := FormList[i];
      pf^.rForm.ParentWindow := Handle;
   end;
end;

procedure TFrmM.DelA2Form (aform:TForm; aA2Form : TA2Form);
var
   i: integer;
   pf : PTFormData;
begin
   for i := 0 to FormList.Count -1 do begin
      pf := FormList[i];
      if pf^.rForm = aform then begin
        aForm.ParentWindow := pf^.roldParent;
        dispose (pf);
        FormList.Delete (i);
        exit;
      end;
   end;
end;

procedure TFrmM.AddA2Form (aform:TForm; aA2Form : TA2Form);
var pf : PTFormData;
begin
   new (pf);
   pf^.rOldParent := aForm.parentWindow;
   aForm.ParentWindow := Handle;
   pf^.rForm := aForm;
   pf^.rA2Form := aA2Form;
   FormList.Add (pf);
end;

procedure TFrmM.DXDrawInitialize(Sender: TObject);
const
   first : Boolean = TRUE;
begin
   if first then begin
      first := FALSE;
      DxTimer1.Enabled := TRUE;
      FrmLogon.visible := TRUE;
      FrmLogon.FormActivate(Self);
   end;
end;

function  TFrmM.GetMouseDirection: word;
var
   xx, yy: integer;
   MCellX, MCellY : integer;
   Cl, Sl : TCharClass;
begin
   Result := DR_DONTMOVE;
   Cl := CharList.GetChar (CharCenterId);
   if cl = nil then exit;
   xx := BackScreen.Cx + (Mousex-BackScreen.SWidth div 2);
   yy := BackScreen.Cy + (Mousey-BackScreen.SHeight div 2);

   MCellX := xx div UNITX;
   MCellY := yy div UNITY;

   if SelectedChar <> 0 then begin
      SL := CharList.GetChar (SelectedChar);
      if SL <> nil then begin
         MCellX := Sl.X;
         MCellY := SL.Y;
      end;
   end;

   Result := GetViewDirection (cl.x, cl.y, mcellx, mcelly);
end;

var
   SelScreenId : integer = 0;
   SelScreenX : integer = 0;
   SelScreenY : integer = 0;

procedure TFrmM.PaintLabelClick(Sender: TObject);
var
   key : word;
   cHit : TCHit;
   CL : TCharClass;
   CLAtt : TCharClass;
   UserFlag : Boolean;  // 사람인지 아닌지 구별값
   AttactFlag : Boolean;

   iID : integer;
begin
   UserFlag := FALSE;
   AttactFlag := FALSE;
   if (ssShift in KeyShift) then begin
      UserFlag := FALSE;
      AttactFlag := TRUE;
   end;
   if (ssCtrl in KeyShift) then begin
      UserFlag := TRUE;
      AttactFlag := TRUE;
   end;
   // ankudo 020213 shift 일경우 몬스터만 가능 Ctrl일 경우 사람만 가능 나머진 다 적용
   if AttactFlag then begin
      if mmAnsTick < HitTick+200 then exit;
      if boShiftAttack = FALSE then exit;
      HitTick := mmAnsTick;
      Cl := CharList.GetChar (CharCenterId);
      if Cl = nil then exit;
      if Cl.Feature.rfeaturestate = wfs_die then exit;

      if SelectedChar <> 0 then begin
         CLAtt := CharList.GetChar (SelectedChar);
         if CLAtt = nil then exit;
         if UserFlag and (CLAtt.Feature.rrace = RACE_MONSTER) then exit;
         if not UserFlag and (CLAtt.Feature.rrace = RACE_HUMAN) then exit;
      end;

      MouseCellX := (BackScreen.Cx - BackScreen.SWidth div 2 + Mousex) div UNITX;
      MouseCellY := (BackScreen.Cy - BackScreen.SHeight div 2 + Mousey) div UNITY;

      cHit.rmsg := CM_HIT;
      cHit.rkey := GetMouseDirection;
      cHit.rtid := SelectedChar;
      cHit.rtx := MouseCellX;
      cHit.rty := MouseCellY;
      Frmlogon.SocketAddData (sizeof(cHit), @cHit);

      if cHit.rkey <> Cl.dir then CL.ProcessMessage (SM_TURN, cHit.rkey, cl.x, cl.y, cl.feature, 0);
      if (Cl.Feature.rHitMotion <> 5) and (Cl.Feature.rHitMotion <> 6) then
         CL.ProcessMessage (SM_MOTION, cHit.rkey, cl.x, cl.y, cl.feature, Cl.Feature.rhitmotion);
      exit;
   end;

   iID := 0;
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);
   key := GetMouseDirection;

   if SelectedChar <> 0 then iID := SelectedChar;
   if SelectedItem <> 0 then iID := SelectedItem;
   GrobalClick.rmsg := CM_CLICK;
   GrobalClick.rwindow := WINDOW_SCREEN;
   GrobalClick.rclickedId := iID;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := key;
end;

procedure TFrmM.PaintLabelDblClick(Sender: TObject);
var
   iID : integer;
begin
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   iID := 0;
   if SelectedChar <> 0 then iID := SelectedChar;
   if SelectedItem <> 0 then iID := SelectedItem;

   GrobalClick.rmsg := CM_DBLCLICK;
   GrobalClick.rwindow := WINDOW_SCREEN;
   GrobalClick.rclickedId := iID;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := GetMouseDirection;
end;

procedure TFrmM.PaintLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;

   with Source as TDragItem do begin
      case SourceID of
         WINDOW_ITEMS:;
         WINDOW_SCREEN:;
         else exit;
      end;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := DragedId;

      cDragDrop.rdestId := 0;
      if SelectedDynamicItem <> 0 then cDragDrop.rdestId := SelectedDynamicItem;
      if Selecteditem <> 0 then cDragDrop.rdestId := SelectedItem;
      if SelectedChar <> 0 then cDragDrop.rdestId := SelectedChar;
      cdragdrop.rsx := sx;
      cdragdrop.rsy := sy;
      cdragdrop.rdx := mouseCellx;
      cdragdrop.rdy := mouseCelly;

      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_SCREEN;
      case SourceId of
         WINDOW_ITEMS: cDragDrop.rsourkey := Selected;
         WINDOW_WEARS: cDragDrop.rsourkey := Selected;
      end;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop);
   end;
end;

procedure TFrmM.PaintLabelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
   Cl : TCharClass;
   IT : TItemClass;
   AIT : TDynamicObject;
begin
   mouseX := x;
   mousey := y;

   MouseCellX := (BackScreen.Cx - BackScreen.SWidth div 2 + Mousex) div UNITX;
   MouseCellY := (BackScreen.Cy - BackScreen.SHeight div 2 + Mousey) div UNITY;

   CharList.MouseMove (BackScreen.Cx + (Mousex-BackScreen.SWidth div 2), BackScreen.Cy + (Mousey-BackScreen.SHeight div 2));
   if (SelectedChar = 0) and(SelectedItem = 0) then MouseInfoStr := '';
   if SelectedChar <> 0 then begin
      Cl := CharList.GetChar (SelectedChar);
      if Cl <> nil then MouseInfoStr := Cl.Name;
   end;
   if SelectedItem <> 0 then begin
      IT := CharList.GetItem (SelectedItem);
      MouseInfoStr := IT.ItemName;
   end;
   if SelectedDynamicItem <> 0 then begin          // aniItem add by 001217
      AIT := CharList.GetDynamicObjItem (SelectedDynamicItem);
      MouseInfoStr := AIT.DynamicObjName;
   end;

   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_ITEMS then Accept := TRUE;
         if SourceID = WINDOW_SCREEN then Accept := TRUE;
      end;
   end;
end;

procedure TFrmM.PaintLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   mousex := x;
   mousey := y;
   if mbRight = Button then begin
      mousecheck := TRUE;
      RightButtonDown := TRUE;
      exit;
   end;
   SelScreenId := 0;
   if SelectedChar <> 0 then SelScreenId := SelectedChar;

   if SelectedItem <> 0 then SelScreenId := SelectedItem;

   if SelScreenId <> 0 then begin
      SelScreenX := x;
      SelScreenY := y;
   end else begin
      SelScreenX := 0;
      SelScreenY := 0;
   end;
end;

procedure TFrmM.PaintLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   Cl : TCharClass;
   IT : TItemClass;
   AIT : TDynamicObject;
begin
   mouseX := x;
   mousey := y;

   if RightButtonDown then mousecheck := TRUE;
   CharList.MouseMove (BackScreen.Cx + (Mousex-BackScreen.SWidth div 2), BackScreen.Cy + (Mousey-BackScreen.SHeight div 2));
   if (SelectedChar = 0) and(SelectedItem = 0) and (SelectedDynamicItem = 0) then MouseInfoStr := '';
   if SelectedChar <> 0 then begin
      Cl := CharList.GetChar (SelectedChar);
      if Cl <> nil then
         if Cl.Feature.rHideState = hs_100 then MouseInfoStr := Cl.Name;
   end;
   if SelectedItem <> 0 then begin
      IT := CharList.GetItem (SelectedItem);
      MouseInfoStr := IT.ItemName;
   end;

   if SelectedDynamicItem <> 0 then begin          // aniItem add by 001217
      AIT := CharList.GetDynamicObjItem (SelectedDynamicItem);
      MouseInfoStr := AIT.DynamicObjName;
   end;
   if (SelScreenId <> 0) and (abs (SelScreenX-x) + abs (SelScreenY-y) > 10) then PaintLabel.BeginDrag (TRUE);
end;

procedure TFrmM.PaintLabelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   mouseX := x;
   mousey := y;
   RightButtonDown := FALSE;

   if abs (SelScreenX-x) + abs (SelScreenY-y) < 10 then begin
      SelScreenX := 0;
      SelScreenY := 0;
      SelScreenId := 0;
   end;
end;

procedure TFrmM.PaintLabelStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
   DragItem.Dragedid := SelScreenId;
   DragItem.SourceId := WINDOW_SCREEN;
   DragItem.sx := mouseCellX;
   DragItem.sy := mouseCellY;
   DragObject := DragItem;
   SelScreenId := 0;
end;

procedure TFrmM.MoveProcess;
var
   dir, xx, yy : word;
   ckey : TCKey;
   cmove : TCMove;
   Cl : TCharClass;
begin
   if RightButtonDown = FALSE then exit;
   Cl := CharList.GetChar (CharCenterId);
   if Cl = nil then exit;
   if Cl.AllowAddAction = FALSE then exit;

   dir := GetMouseDirection;
   if dir <> DR_DONTMOVE then begin
      if dir <> Cl.dir then begin
         ckey.rmsg := CM_TURN;
         ckey.rkey := dir;
         FrmLogon.SocketAddData (sizeof(ckey), @ckey);
         CL.ProcessMessage (SM_TURN, dir, cl.x, cl.y, cl.feature, 0);
      end else begin
         xx := Cl.x; yy := Cl.y;
         GetNextPosition (dir, xx, yy);
         if Map.isMovable (xx, yy) = FALSE then exit;
         if CharList.isMovable (xx, yy) = FALSE then exit;

         cmove.rmsg := CM_MOVE;
         cmove.rdir := dir;
         cmove.rx := Cl.x;
         cmove.ry := Cl.y;
         FrmLogon.SocketAddData (sizeof(cmove), @cmove);
         CL.ProcessMessage (SM_MOVE, dir, cl.x, cl.y, cl.feature, 0);
      end;
   end;
end;

procedure TFrmM.CheckAndSendClick;
begin
   if mmAnsTick < ClickTick+10 then exit;
   if GrobalClick.rwindow = 0 then exit;
   Frmlogon.SocketAddData (sizeof(GrobalClick), @GrobalClick);
   FillChar (GrobalClick, sizeof(GrobalClick), 0);
end;

procedure TFrmM.MessageProcess (var code: TWordComData);
var
   TagetX, TagetY, len : Word;
   i, n, deg, xx, yy : integer;
   pan, volume, volume2: integer;
   str, rdstr : string;
   cstr : string[1];
   DynamicGuard : TDynamicGuard;

   ItemClass : TItemClass;
   Cl, TL : TCharClass;
   Dt : TDynamicObject;
   pckey : PTCKey;
   psSay : PTSSay;
   psNewMap : PTSNewMap;
   psShow : PTSShow;
   psShowItem : PTSShowItem;
   psHide : PTSHide;
   psTurn : PTSTurn;
   psMove : PTSMove;
   psSetPosition : PTSSetPosition;
   psChatMessage : PTSChatMessage;
   psChangeFeature : PTSChangeFeature;
   psChangeProperty : PTSChangeProperty;
   psMotion : PTSMotion;
   psStructed : PTSStructed;
   psHaveMagic : PTSHaveMagic;
   psHaveItem : PTSHaveItem;
//   psWearItem : PTSWearItem;
   psAttribBase : PTSAttribBase;
   psAttriblife : PTSAttribLife;
   psAttribValues : PTSAttribValues;
   psAttribFightBasic : PTSAttribFightBasic;
   psEventString : PTSEventString;
   psMovingMagic : PTSMovingMagic;
   psSoundString : PTSSoundString;
   psSoundBaseString : PTSSoundBaseString;
   psRainning: PTSRainning;
   psShowInputString : PTSShowInputString;

   PSShowDynamicObject : PTSShowDynamicObject; // DynamicItem Add 010102 ankudo
   PSChangeState : PTSChangeState; // Dynamic Item state Change 010105 ankudo
   PSSShowSpecialWindow : PTSShowSpecialWindow;
   PSTSHideSpecialWindow : PTSHideSpecialWindow;
   PSTSNetState : PTSNetState;
   cCNetState : TCNetState;
begin
   pckey := @Code.data;
   case pckey^.rmsg of
      SM_NETSTATE :
         begin
            PSTSNetState := @Code.data;
            with cCNetState do begin
               rMsg := CM_NETSTATE;
               rID := PSTSNetState^.rID;
               rMadeTick := PSTSNetState^.rMadeTick;
               rCurTick := mmAnsTick;
            end;
            FrmLogon.SocketAddData (sizeof(cCNetState), @cCNetState);

         end;
      SM_HIDESPECIALWINDOW :
         begin
            PSTSHideSpecialWindow := @Code.data;
            case PSTSHideSpecialWindow^.rWindow of
               WINDOW_GROUPWINDOW : FrmbatList.Visible := FALSE;
               WINDOW_ROOMWINDOW : FrmbatList.Visible := FALSE;
               WINDOW_GRADEWINDOW : FrmbatList.Visible := FALSE;
               WINDOW_ITEMLOG : FrmDepository.Visible := FALSE;
               WINDOW_ALERT : FrmDepository.Visible := FALSE;
               WINDOW_AGREE : FrmcMessageBox.Visible := FALSE;
               WINDOW_GUILDMAGIC : FrmMuMagicOffer.Visible := FALSE;
            end;
         end;
      SM_SHOWBATTLEBAR :
         begin
            PersonBat.MessageProcess (Code);
         end;
      SM_SHOWCENTERMSG :
         begin
            PersonBat.MessageProcess (Code);
         end;
      SM_CHECK :
         begin
            CheckSome (Code);
         end;
      SM_LOGITEM :
         begin
            FrmDepository.MessageProcess(Code);
         end;
      SM_SHOWSPECIALWINDOW :
         begin
            FrmDepository.MessageProcess(Code);
            FrmbatList.MessageProcess (Code);
            FrmcMessageBox.MessageProcess(Code);
            FrmMuMagicOffer.MessageProcess(Code);
            {
            FrmMunpaCreate.MessageProcess(Code);
            FrmMunpaimpo.MessageProcess(Code);
            FrmcMessageBox.MessageProcess(Code);
            FrmMunpaWarOffer.MessageProcess(Code);
            }
         end;
      SM_CHARMOVEFRONTDIEFLAG:
         begin // 임시사용 케릭터가 죽은사람위로 지나갈수 있는 경우를 TRUE로 설정
            CharMoveFrontdieFlag := TRUE;
         end;
      SM_SHOWEXCHANGE:  // 교환창
         begin
            FrmExChange.MessageProcess (Code);
         end;
      SM_HIDEEXCHANGE:
         begin
            FrmExchange.Visible := FALSE;
            if FrmQuantity.Visible then FrmQuantity.Visible := FALSE;
         end;
      SM_SHOWCOUNT:     // 수량창
         begin
            FrmQuantity.MessageProcess (Code);
         end;

      // CM_SELECTCOUNT;
      SM_SHOWINPUTSTRING: // 탐색창
         begin
            psShowInputString := @Code.Data;
            FrmSearch.QuantityID :=  psShowInputString.rInputStringid;
            FrmSearch.QuantityData :=  GetWordString (psShowInputString.rWordString);
            FrmSearch.SearchItem;
            FrmSearch.Visible := TRUE;
         end;
      SM_RAINNING : // 비
         begin
            psRainning := @Code.Data;
            with psRainning^ do begin
               BackScreen.SetRainState (TRUE, rspeed, rCount, rOverray, rTick, rRainType);
            end;
         end;
      SM_BOSHIFTATTACK:
         begin
            pckey := @Code.data;
            if pckey^.rkey = 0 then begin
               boShiftAttack := TRUE;
            end
            else begin
               boShiftAttack := FALSE;
            end;
         end;
      SM_SOUNDEFFECT:                                      // 새로운 효과음.
         begin
            if not boUseSound then exit;
            psSoundString := @Code.Data;
            str := StrPas (@psSoundString^.rSoundName);
            TagetX := psSoundString.rX;
            TagetY := psSoundString.rY;

            volume := FrmSound.changeEffectVolume;
//            if volume < -2000 then Volume := -2000;
//            volume2 := FrmM.SoundManager.RangeVolume(CharPosX, CharPosY,TagetX,TagetY,volume);
//            LogObj.WriteLog (5, 'SM_SoundE.. :'+ str);
            pan := FrmM.SoundManager.RangeCompute(CharPosX, TagetX);
            FrmM.SoundManager.NewPlayEffect (str,pan,volume);
         end;
         {
      SM_SOUNDSTRING:                                      // 이전 효과음...
         begin
            if not boUseSound then exit;
            psSoundString := @Code.Data;
            str := StrPas (@psSoundString^.rSoundName);
//            LogObj.WriteLog(5, 'SM_SOUNDSTRING ' + str);
            FrmM.SoundManager.PlayEffect (str);
         end;
          }
      SM_SOUNDBASESTRING : // 배경음악.... 1분정도보다 긴것들
         begin
            if not boUseSound then exit;
            psSoundBaseString := @Code.Data;
            str := GetWordString (psSoundBaseString^.rWordString);
            {
            if str = '' then begin
               ActiveBaseAudioList.clear;
               exit;
            end;
            str := GetValidstr3 (str, rdstr, '.');
            if FileExists ('.\wav\'+rdstr+'.mp3') then str := rdstr+'.mp3'
            else str := GetWordString (psSoundBaseString^.rWordString);
            str :='.\wav\'+str;
            ActiveBaseAudioList.AddActiveMusic (str);
            ActiveBaseAudioList.SetLoops (str, psSoundBaseString^.rRoopCount);
            ActiveBaseAudioList.play (str);
            }
            FrmM.SoundManager.PlayBaseAudio (str, psSoundBaseString^.rRoopCount);
         end;
      SM_SOUNDBASESTRING2: // 효과음향 (바람소리, 천둥소리, 새소리,...)
         begin
//            LogObj.WriteLog(3, '[  SM_SOUNDBASESTRING :  ]');
            if not boUseSound then exit;
            psSoundBaseString := @Code.Data;
            str := GetWordString (psSoundBaseString^.rWordString);
            FrmM.SoundManager.PlayBaseAudio2 (str, psSoundBaseString^.rRoopCount);
         end;
      SM_MOVINGMAGIC :
         begin
            psMovingMagic := @Code.Data;
            with psMovingMagic^ do begin
               Cl := CharList.GetChar (rsid);
               TL := CharList.GetChar (reid);
               if Cl = nil then exit;
               if Tl <> nil then begin xx := Tl.x; yy := Tl.y; end
               else begin xx := rtx; yy := rty; end;
               deg := GetDeg (Cl.x, Cl.y, xx, yy);
               CharList.AddMagic (Cl.Id, reid, deg, rspeed, Cl.x, Cl.y, xx, yy, rmf, mmAnstick, rType)
            end;
         end;
      SM_EVENTSTRING:
         begin
            psEventString := @Code.data;
            FrmAttrib.LbEvent.Caption := GetwordString(psEventString^.rWordstring);
            EventTick := mmAnsTick;
         end;
      SM_MOTION :
         begin
            psMotion := @Code.Data;
            Cl := CharList.GetChar (psMotion^.rid);
            if Cl <> nil then Cl.ProcessMessage (SM_MOTION, cl.dir, cl.x, cl.y, Cl.feature, psMotion^.rmotion);
         end;
      SM_STRUCTED :
         begin
            psStructed := @Code.Data;
            case psStructed^.rRace of
               RACE_HUMAN :
                  begin
                     Cl := CharList.GetChar (psStructed^.rid);
                     if Cl <> nil then Cl.ProcessMessage (SM_STRUCTED, cl.dir, cl.x, cl.y, Cl.feature, psStructed^.rpercent);
                  end;
               RACE_DYNAMICOBJECT :
                  begin
                     Dt := CharList.GetDynamicObjItem (psStructed^.rid);
                     if Dt <> nil then Dt.ProcessMessage (SM_STRUCTED, psStructed^.rpercent);
                  end;
            end;
         end;
      SM_CHATMESSAGE :
         begin
            psChatMessage := @Code.data;
            str := GetwordString(psChatMessage^.rWordstring);
            cstr := str;
            if (cstr = '[') or (cstr = '<') then begin
               if pos (':', str) > 1 then begin
                  str := GetValidStr3 (str, rdstr, ':');
                  str := ChangeDontSay (str);
                  rdstr := rdstr + ':' + str
               end else rdstr := str;
            end else begin
               str := ChangeDontSay (str);
               rdstr := str;
            end;
            AddChat (rdstr, psChatMessage^.rFColor, psChatMessage^.rBColor);
            str := ''; rdstr := '';
         end;
      SM_SAY :
         begin
            psSay := @Code.data;
            str := GetwordString(pssay^.rWordstring);
            str := GetValidStr3 (str, rdstr, ':');
            str := ChangeDontSay (str);
            rdstr := rdstr + ' :' + str;
            AddChat (rdstr, WinRGB (28,28,28), 0);
            Cl := CharList.GetChar (psSay^.rid);
            if Cl <> nil then Cl.Say (rdstr);
            str := ''; rdstr := '';
         end;
      SM_SAYUSEMAGIC :
         begin
            psSay := @Code.data;
            Cl := CharList.GetChar (psSay^.rid);
            if Cl <> nil then Cl.Say (GetwordString(pssay^.rWordstring));
         end;
      SM_NEWMAP :
         begin
            CharList.Clear;
            psNewMap := @Code.data;
            CharCenterId := psNewMap^.rId;
            CharCenterName := StrPas (@psNewMap^.rCharName);

            ObjectDataList.LoadFromFile ( StrPas (@psNewMap^.rObjName) );
            TileDataList.LoadFromFile ( StrPas (@psNewMap^.rTilName) );
            RoofDataList.LoadFromFile ( StrPas (@psNewMap^.rRofName) );
            Map.LoadFromFile (StrPas (@psNewMap^.rmapname), psNewMap^.rx, psNewMap^.ry);
{
            ObjectDataList.LoadFromFile ('foxobj.Obj');
            TileDataList.LoadFromFile ('foxtil.til');
            RoofDataList.LoadFromFile ('');
            Map.LoadFromFile ('fox.map', psNewMap^.rx, psNewMap^.ry);
}
//            MapName := StrPas (@psNewMap^.rmapname);
            Map.SetCenter (psNewMap^.rx, psNewMap^.ry);
            BackScreen.SetCenter (psNewMap^.rx * UNITX, psNewMap^.ry * UNITY);
            BackScreen.Back.Clear(0);

            FrmAttrib.Visible := TRUE;
            FrmBottom.Visible := TRUE;
            FrmBottom.EdChat.SetFocus;
         end;
      SM_SHOWDYNAMICOBJECT : // DynamicItem 010102 ankudo 왕릉아이템 Add
         begin
            PSShowDynamicObject := @Code.Data;
            with PSShowDynamicObject^ do begin
               Fillchar (DynamicGuard, sizeof(DynamicGuard), 0);
               DynamicGuard.aCount := 0;
               for i := 0 to 10 -1 do begin
                  if (rGuardX[i] = 0) and (rGuardY[i] = 0) then break;
                  DynamicGuard.aGuardX[i] := rGuardX[i];
                  DynamicGuard.aGuardY[i] := rGuardY[i];
                  inc (DynamicGuard.aCount);
               end;
               CharList.AddDynamicObjItem (StrPas (@rNameString),rid, rx, ry, rshape, rFrameStart, rFrameEnd, rstate, DynamicGuard);
            end;
         end;
      SM_CHANGESTATE : // DynamicItem 010106 ankudo 왕릉아이템의 상태변경
         begin
            PSChangeState := @Code.Data;
            with PSChangeState^ do begin
               CharList.SetDynamicObjItem (rid, rState, rFrameStart, rFrameEnd);
            end;
         end;
      SM_HIDEDYNAMICOBJECT : // DynamicItem 010106 ankudo 왕릉아이템 삭제
         begin
            PSHide := @Code.Data;
            with PSHide^ do begin
               CharList.DeleteDynamicObjItem (rid);
            end;
         end;
      SM_SHOWITEM :
         begin
            psShowItem := @Code.Data;
            with psshowItem^ do begin
               CharList.AddItem (StrPas (@rNameString), rRace, rid, rx, ry, rshape, rcolor);
            end;
         end;
      SM_HIDEITEM :
         begin
            psHide := @Code.Data;
            with pshide^ do begin
               CharList.DeleteItem (rid);
            end;
         end;
      SM_SHOW :
         begin
            psShow := @Code.Data;
            with psshow^ do begin
               CharList.AddChar (StrPas (@rNameString),rid, rdir, rx, ry, rFeature);
            end;
         end;
      SM_HIDE :
         begin
            psHide := @Code.Data;
            with pshide^ do begin
               CharList.DeleteChar (rid);
            end;
         end;
      SM_SETPOSITION :
         begin
            psSetPosition := @Code.Data;
            with psSetPosition^ do begin
               Cl := CharList.GetChar (rid);
               if Cl <> nil then Cl.ProcessMessage (SM_SETPOSITION, rdir, rx, ry, Cl.feature, 0);
            end;
         end;
      SM_TURN :
         begin
            psTurn := @Code.Data;
            with psTurn^ do begin
               Cl := CharList.GetChar (rid);
               if Cl <> nil then Cl.ProcessMessage (SM_TURN, rdir, rx, ry, Cl.feature, 0);
            end;
         end;
      SM_MOVE :
         begin
            psMove := @Code.Data;
            with psMove^ do begin
               Cl := CharList.GetChar (psMove^.rid);
               if Cl <> nil then Cl.ProcessMessage (SM_MOVE, rdir, rx, ry, Cl.feature, 0);
            end;
         end;
      SM_CHANGEFEATURE :
         begin
            psChangeFeature := @Code.data;
            Cl := CharList.GetChar (psChangeFeature^.rid);
            if Cl <> nil then begin
               Cl.ProcessMessage (SM_CHANGEFEATURE, cl.dir, cl.x, cl.y, psChangeFeature.rfeature, 0);
               exit;
            end;
            { // 원본
            Cl := CharList.GetChar (psChangeFeature^.rid);
            if Cl <> nil then begin
               Cl.ProcessMessage (SM_CHANGEFEATURE, cl.dir, cl.x, cl.y, psChangeFeature.rfeature, 0);
               exit;
            end;
            }
            ItemClass := CharList.GetItem (psChangeFeature^.rid);
            if ItemClass <> nil then begin
               ItemClass.SetItemAndColor (psChangeFeature^.rFeature.rImageNumber, psChangeFeature^.rFeature.rImageColorIndex);
               exit;
            end;
         end;
      SM_CHANGEPROPERTY :
         begin
//            LogObj.WriteLog(5, 'SM_CHANGEPROPERTY');
            psChangeProperty := @Code.data;
            Cl := CharList.GetChar (psChangeProperty^.rid);
            if Cl <> nil then begin
               Cl.ChangeProperty(psChangeProperty);
               exit;
            end;
            ItemClass := CharList.GetItem (psChangeProperty^.rid);
            if ItemClass <> nil then begin
               ItemClass.ChangeProperty (psChangeProperty);
               exit;
            end;
         end;
   end;
end;

procedure TFrmM.Time1TimerTimer(Sender: TObject);
var
   CMouseEvent : TCMouseEvent;
begin
   CMouseEvent.rmsg := CM_MOUSEEVENT;
   move (eventBuffer,CMouseEvent.revent,sizeof(eventBuffer));
   FrmLogon.SocketAddData (sizeof(CMouseEvent), @CMouseEvent);
   Fillchar (eventBuffer, sizeof(eventBuffer),0);
end;

procedure TFrmM.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   DXTimer1.Enabled := FALSE;
end;

const
   NetStateDelayTick = 500;
var
   iMoving : byte = 3;
   DrawTick : integer = 0;

procedure TFrmM.DXTimer1Timer(Sender: TObject; LagCount: Integer);
const
   oldMouseInfo : string = '';
var
   i : integer;
   Cl : TCharClass;
begin
   {
   if FrmBottom.Visible = TRUE then begin
      if mmAnsTick > NetStateDelayTick + DrawTick then begin
         cCKey.rmsg := CM_NETSTATE;
         cCKey.rkey := 0;
         FrmLogon.SocketAddData (sizeof(TCKey), @cCKey);
         DrawTick := mmAnsTick;
      end;
   end;
   }

   Caption := format (Conv('푤쾨:%s:%d:%d:%d'),[CharCenterName, CharPosX, CharPosY,DXTimer1.FrameRate]);
   FrmBottom.LbPos.Caption := format ('%d:%d',[CharPosX, CharPosY]);
   if boDirectClose then begin Close; end;
   if not DXDraw.CanDraw then exit;

   if oldMouseInfo <> mouseinfostr then begin oldmouseinfo := mouseinfostr; FrmAttrib.LbWindowName.Caption := mouseinfostr; end;

   if EventTick <> 0 then begin
      if EventTick + 150 < mmAnsTick then begin EventTick := 0; FrmAttrib.LbEvent.Caption := ''; end;
      FrmAttrib.LbEvent.Font.Color := Random ( clWhite);
   end;

   SoundManager.UpDate (mmAnsTick);

   CharList.Update (mmAnsTick);
   Map.DrawMap(mmAnstick);
   CharList.Paint(mmAnstick);
   CharList.UpDataBgEffect (mmAnstick);
   Cl := CharList.GetChar (CharCenterId);
   if Cl <> nil then if not Map.IsInArea(CL.x, CL.y) then Map.DrawRoof(mmAnsTick);

   CharList.PaintText (nil);
   if boShowChat then DrawChatList;

   if FrmSearchUser.Visible then FrmSearchUser.SetCenterID;

   if FrmAttrib.Visible then FrmAttrib.DrawWearItem;
//   if FrmNpcView.Visible then FrmNpcView.DrawNpcpreview (CharCenterID);
   if not FrmBottom.Visible then BackScreen.Clear;

   BackScreen.UpdateRain; //   BackScreen.ConvertDark; // 사용안함

   for i := FormList.Count -1 downto 0 do begin
      if PTFormData (formList[i])^.rForm.Visible then PTFormData (FormList[i])^.rA2Form.AdxPaint (BackScreen.Back);
   end;

   if FrmSearchUser.Visible then FrmSearchUser.SetCenterID;

   if FrmBottom.Visible then BackScreen.Back.DrawImage (BottomUpImage, 0, 363-BottomUpImage.Height, TRUE);
   if FrmAttrib.Visible then BackScreen.Back.DrawImage (AttribLeftImage, 640-AttribLeftImage.Width-FrmAttrib.Width, 0, TRUE);

   ObjectDataList.UsedTickUpdate (mmAnsTick);
   TileDataList.UsedTickUpdate (mmAnsTick);
   AtzClass.UpDate (mmAnsTick);
//   ActiveBaseAudioList.Update;

   if PersonBat.ShowBar then PersonBat.Draw;
   if PersonBat.ShowBatMsg then PersonBat.BatMessageDraw (104,145, mmAnsTick);

   BackScreen.DrawCanvas (DxDraw.Surface.Canvas, 0, 0);
   DxDraw.Surface.Canvas.Release;
   DxDraw.Flip;

   if Cl <> nil then begin
      case Cl.Feature.rActionState of
         as_Free : MoveProcess;
         as_ice :;
         as_slow :
            begin
               if iMoving > 1 then begin
                  MoveProcess;
                  iMoving := 3;
               end;
               Dec (iMoving);
            end;
      end;
   end;
   CheckAndSendClick;
end;

end.

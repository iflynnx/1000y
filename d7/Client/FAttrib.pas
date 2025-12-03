unit FAttrib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  A2Form, A2Img, aDeftype, Deftype, ExtCtrls, StdCtrls, CharCls, cltype, AtzCls,
  uAnsTick, BackScrn, Gauges, Menus; //Fdyeing,

const
   AttribItemMaxCount = 30;
type
{
  TAttribitemData = record
     ItemName : string[16];
     ItemShape : byte;
     ItemColor : word;
     ItemCount : integer;
     memPos : integer;
  end;
}
  TFrmAttrib = class(TForm)
    A2Form: TA2Form;
    PanelAttrib: TA2Panel;
    LbLight: TA2Label;
    LbDark: TA2Label;
    LbGoodChar: TA2Label;
    LbBadChar: TA2Label;
    LbAdaptive: TA2Label;
    LbRevival: TA2Label;
    LbImmunity: TA2Label;
    Lbtalent: TA2Label;
    LbGil: TA2Label;
    Lbhung: TA2Label;
    LbBok: TA2Label;
    Lbhoa: TA2Label;
    LbChar: TA2ILabel;
    PanelBasic: TA2Panel;
    PanelMagic: TA2Panel;
    PanelItem: TA2Panel;
    PanelSkill: TA2Panel;
    A2ILabel0: TA2ILabel;
    A2ILabel1: TA2ILabel;
    A2ILabel2: TA2ILabel;
    A2ILabel3: TA2ILabel;
    A2ILabel4: TA2ILabel;
    A2ILabel5: TA2ILabel;
    A2ILabel6: TA2ILabel;
    A2ILabel7: TA2ILabel;
    A2ILabel8: TA2ILabel;
    A2ILabel9: TA2ILabel;
    A2ILabel10: TA2ILabel;
    A2ILabel11: TA2ILabel;
    A2ILabel12: TA2ILabel;
    A2ILabel13: TA2ILabel;
    A2ILabel14: TA2ILabel;
    A2ILabel15: TA2ILabel;
    A2ILabel16: TA2ILabel;
    A2ILabel17: TA2ILabel;
    A2ILabel18: TA2ILabel;
    A2ILabel19: TA2ILabel;
    A2ILabel20: TA2ILabel;
    A2ILabel21: TA2ILabel;
    A2ILabel22: TA2ILabel;
    A2ILabel23: TA2ILabel;
    A2ILabel24: TA2ILabel;
    A2ILabel25: TA2ILabel;
    A2ILabel26: TA2ILabel;
    A2ILabel27: TA2ILabel;
    A2ILabel28: TA2ILabel;
    A2ILabel29: TA2ILabel;
    BLabel0: TA2ILabel;
    BLabel1: TA2ILabel;
    BLabel2: TA2ILabel;
    BLabel3: TA2ILabel;
    BLabel4: TA2ILabel;
    BLabel5: TA2ILabel;
    BLabel6: TA2ILabel;
    BLabel7: TA2ILabel;
    BLabel8: TA2ILabel;
    BLabel9: TA2ILabel;
    BLabel10: TA2ILabel;
    BLabel11: TA2ILabel;
    MLabel0: TA2ILabel;
    MLabel1: TA2ILabel;
    MLabel2: TA2ILabel;
    MLabel3: TA2ILabel;
    MLabel4: TA2ILabel;
    MLabel5: TA2ILabel;
    MLabel6: TA2ILabel;
    MLabel7: TA2ILabel;
    MLabel8: TA2ILabel;
    MLabel9: TA2ILabel;
    MLabel10: TA2ILabel;
    MLabel11: TA2ILabel;
    Image1: TImage;
    PgHead: TGauge;
    PGArm: TGauge;
    PGLeg: TGauge;
    LbMoney: TLabel;
    LbWindowName: TLabel;
    LbAge: TLabel;
    LbVirtue: TLabel;
    BLabel12: TA2ILabel;
    BLabel13: TA2ILabel;
    BLabel14: TA2ILabel;
    BLabel15: TA2ILabel;
    BLabel16: TA2ILabel;
    BLabel17: TA2ILabel;
    BLabel18: TA2ILabel;
    BLabel19: TA2ILabel;
    MLabel12: TA2ILabel;
    MLabel13: TA2ILabel;
    MLabel14: TA2ILabel;
    MLabel15: TA2ILabel;
    MLabel16: TA2ILabel;
    MLabel17: TA2ILabel;
    MLabel18: TA2ILabel;
    MLabel19: TA2ILabel;
    LbEvent: TLabel;
    LbSkill0: TLabel;
    LbSkill1: TLabel;
    LbSkill2: TLabel;
    LbSkill3: TLabel;
    LbSkill4: TLabel;
    LbSkill5: TLabel;
    LbSkill6: TLabel;
    LbSkill7: TLabel;
    BLabel20: TA2ILabel;
    BLabel21: TA2ILabel;
    BLabel22: TA2ILabel;
    BLabel23: TA2ILabel;
    BLabel24: TA2ILabel;
    BLabel25: TA2ILabel;
    BLabel26: TA2ILabel;
    BLabel27: TA2ILabel;
    BLabel28: TA2ILabel;
    BLabel29: TA2ILabel;
    MLabel20: TA2ILabel;
    MLabel21: TA2ILabel;
    MLabel22: TA2ILabel;
    MLabel23: TA2ILabel;
    MLabel24: TA2ILabel;
    MLabel25: TA2ILabel;
    MLabel26: TA2ILabel;
    MLabel27: TA2ILabel;
    MLabel28: TA2ILabel;
    MLabel29: TA2ILabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LbCharMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LbCharStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure LbCharMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LbCharDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure LbCharDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ItemLabelDblClick(Sender: TObject);
    procedure ItemLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure A2ILabel0DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ItemLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ItemLabelStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure MLabelDblClick(Sender: TObject);
    procedure MLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MLabelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MLabelStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure BLabel0DblClick(Sender: TObject);
    procedure BLabel0MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BLabel0StartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure LbSkill0Click(Sender: TObject);
    procedure LbSkill0DblClick(Sender: TObject);
    procedure LbSkill0MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure LbSkill4Click(Sender: TObject);
    procedure BLabel0Click(Sender: TObject);
    procedure MLabel0Click(Sender: TObject);
    procedure A2ILabel26Click(Sender: TObject);
    procedure BLabel0Paint(Sender: TObject);
    procedure MLabel0Paint(Sender: TObject);
  private
    { Private declarations }
//     DragDropSelectNum : integer;
//     SelectItem : integer;

    procedure SetFormText;
  public
    { Public declarations }
    ILabels : array [0..AttribItemMaxCount-1] of TA2ILabel;
//    AttribitemData : array [0..AttribItemMaxCount-1] of TAttribitemData;
    {
    MLabels : array [0..20-1] of TA2ILabel;
    BLabels : array [0..20-1] of TA2ILabel;
    }
    MLabels : array [0..30-1] of TA2ILabel;
    BLabels : array [0..30-1] of TA2ILabel;

    SLabels : array [0..8-1] of TLabel;
    CharCenterImage : TA2Image;
    WearStrings : array [0..10] of string;

    procedure MessageProcess (var code: TWordComData);
    procedure DrawWearItem;
    procedure SetItemLabel (Lb : TA2ILabel; aname: string; acolor: byte; shape: word);
    procedure SetMagicLabel (Lb : TA2ILabel; aname: string; acolor: byte; shape: word);

    function  AppKeyDownHook(var Msg: TMessage): Boolean;
    procedure savekeyaction (akey : string);
    procedure setsavekey;


//    procedure ItemClear(aName: string; aCount, idx: integer);
//    procedure CheckattribDragDropItem(aname: string; aCount: integer);

  end;

var
  FrmAttrib: TFrmAttrib;

var
   BasicBuffer : array [0..60-1] of string = (  // key历厘滚欺
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',

   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', '',
   '', '', '', '', ''

   );

var
   savekeyBool : Boolean;
   savekeytextout : Boolean;
   savekey : word;

   savekeyImagelib : TA2ImageLib;
   savekeyImage : TA2Image;

   keyselmagicindex: integer = -1;

implementation

uses FMain, FBottom, FLogOn, FDepository, FQuantity;

{$R *.DFM}

procedure TFrmAttrib.setsavekey;
var
   i: integer;
   str : string;
begin
//   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
   str := '';
   case savekey of
      VK_F5 : str := 'F5';
      VK_F6 : str := 'F6';
      VK_F7 : str := 'F7';
      VK_F8 : str := 'F8';
      VK_F9 : str := 'F9';
      VK_F10 : str := 'F10';
      VK_F11 : str := 'F11';
      VK_F12 : str := 'F12';
      else exit;
   end;

   if keyselmagicindex < 0 then exit;

   if str <> '' then begin
      for i := 0 to 60-1 do begin
         if BasicBuffer[i] = str then begin
            BasicBuffer[i] := '';
            if i > 29 then FrmAttrib.MLabels[i -30].repaint;
            if i < 30 then FrmAttrib.BLabels[i].repaint;
         end;
      end;

      BasicBuffer[KeySelmagicIndex] := str;
      if KeySelmagicIndex > 29 then FrmAttrib.MLabels[KeySelmagicIndex -30].repaint;
      if KeySelmagicIndex < 30 then FrmAttrib.BLabels[KeySelmagicIndex].repaint;
   end;
end;


procedure TFrmAttrib.savekeyaction (akey : string);
var
   i : integer;
begin
   for i := 0 to 60 -1 do begin
      if BasicBuffer[i] = akey then begin
         if i <= 29 then BLabels[i].OnDblClick(BLabels[i]);
         if i > 29 then MLabels[i- 30].OnDblClick(MLabels[i- 30]);
      end;
   end;
end;


var
   Last_X : integer;
   P: TPoint;

function TFrmAttrib.AppKeyDownHook(var Msg: TMessage): Boolean;
begin
   Result := FALSE;
   GetCursorPos (P);
   if (P.x < 640 - 180 + FrmM.Left) or (P.x > 640 + FrmM.Left) then begin
      savekeyBool := FALSE;
      exit;
   end;
   if (P.y > 480 - 117 + FrmM.Top) or (P.y < 144 + FrmM.Top) then begin
      savekeyBool := FALSE;
      exit;
   end;

   case Msg.Msg of
   Cm_AppkeyDown:
      begin
         if savekeyBool then begin
            savekey := TWMKey(Msg).CharCode;
            if (PanelMagic.Visible) or (PanelBasic.Visible) and FrmAttrib.Visible then setsavekey;
         end;
         Result := TRUE;
      end;
   else
      Result := FALSE;
   end;
end;

procedure TFrmAttrib.SetFormText;
begin
   PgHead.Hint := Conv('头部');
   PGArm.Hint := Conv('臂部');
   PGLeg.Hint := Conv('腿部');

   LbSkill0.Hint := Conv('铸造师');
   LbSkill1.Hint := Conv('炼丹师');
   LbSkill2.Hint := Conv('炼金师');
   LbSkill3.Hint := Conv('火药师');
   LbSkill4.Hint := Conv('美容师');
   LbSkill5.Hint := Conv('料理师');
   LbSkill6.Hint := Conv('裁缝师');
   LbSkill7.Hint := Conv('占卜师');
end;


var
   SelWearItemIndex : integer = 0;

const
   SelectedMagicLabel : TA2ILabel = nil;
   SelectedItemLabel : TA2ILabel = nil;
   SelectedWearLabel : TA2ILabel = nil;

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

procedure TFrmAttrib.FormCreate(Sender: TObject);
var i: integer;
begin
   application.HookMainWindow (AppKeyDownHook);

   savekeyImagelib := TA2ImageLib.Create;
   savekeyImagelib.LoadFromFile ('.\ect\funcimg.atz');
   savekeyImage := TA2Image.Create (140,140,0,0);

   Color := clBlack;
   Parent := FrmM;
//   FrmM.AddA2Form (Self, A2form);
   Left := 640-Width; Top := 0;
   SetFormText; // hint text
   // FrmAttrib Set Font
   FrmAttrib.Font.Name := mainFont;
   LbMoney.Font.Name := mainFont;
   LbEvent.Font.Name := mainFont;
   LbWindowName.Font.Name := mainFont;
   LbAge.Font.Name := mainFont;
   LbVirtue.Font.Name := mainFont;

   CharCenterImage := TA2Image.Create (56, 72, 0, 0);
   LbChar.A2Image := CharCenterImage;

   MLabels[0] := MLabel0; MLabels[1] := MLabel1; MLabels[2] := MLabel2;
   MLabels[3] := MLabel3; MLabels[4] := MLabel4; MLabels[5] := MLabel5;
   MLabels[6] := MLabel6; MLabels[7] := MLabel7; MLabels[8] := MLabel8;
   MLabels[9] := MLabel9; MLabels[10] := MLabel10; MLabels[11] := MLabel11;
   MLabels[12] := MLabel12; MLabels[13] := MLabel13; MLabels[14] := MLabel14;
   MLabels[15] := MLabel15; MLabels[16] := MLabel16; MLabels[17] := MLabel17;
   MLabels[18] := MLabel18; MLabels[19] := MLabel19;
   MLabels[20] := MLabel20; MLabels[21] := MLabel21; MLabels[22] := MLabel22;
   MLabels[23] := MLabel23; MLabels[24] := MLabel24; MLabels[25] := MLabel25;
   MLabels[26] := MLabel26; MLabels[27] := MLabel27; MLabels[28] := MLabel28;
   MLabels[29] := MLabel29;

   BLabels[0] := BLabel0; BLabels[1] := BLabel1; BLabels[2] := BLabel2;
   BLabels[3] := BLabel3; BLabels[4] := BLabel4; BLabels[5] := BLabel5;
   BLabels[6] := BLabel6; BLabels[7] := BLabel7; BLabels[8] := BLabel8;
   BLabels[9] := BLabel9; BLabels[10] := BLabel10; BLabels[11] := BLabel11;
   BLabels[12] := BLabel12; BLabels[13] := BLabel13; BLabels[14] := BLabel14;
   BLabels[15] := BLabel15; BLabels[16] := BLabel16; BLabels[17] := BLabel17;
   BLabels[18] := BLabel18; BLabels[19] := BLabel19;
   BLabels[20] := BLabel20; BLabels[21] := BLabel21; BLabels[22] := BLabel22;
   BLabels[23] := BLabel23; BLabels[24] := BLabel24; BLabels[25] := BLabel25;
   BLabels[26] := BLabel26; BLabels[27] := BLabel27; BLabels[28] := BLabel28;
   BLabels[29] := BLabel29;

   ILabels[0] := A2ILabel0; ILabels[1] := A2ILabel1; ILabels[2] := A2ILabel2;
   ILabels[3] := A2ILabel3; ILabels[4] := A2ILabel4; ILabels[5] := A2ILabel5;
   ILabels[6] := A2ILabel6; ILabels[7] := A2ILabel7; ILabels[8] := A2ILabel8;
   ILabels[9] := A2ILabel9; ILabels[10] := A2ILabel10; ILabels[11] := A2ILabel11;
   ILabels[12] := A2ILabel12; ILabels[13] := A2ILabel13; ILabels[14] := A2ILabel14;
   ILabels[15] := A2ILabel15; ILabels[16] := A2ILabel16; ILabels[17] := A2ILabel17;
   ILabels[18] := A2ILabel18; ILabels[19] := A2ILabel19; ILabels[20] := A2ILabel20;
   ILabels[21] := A2ILabel21; ILabels[22] := A2ILabel22; ILabels[23] := A2ILabel23;
   ILabels[24] := A2ILabel24; ILabels[25] := A2ILabel25; ILabels[26] := A2ILabel26;
   ILabels[27] := A2ILabel27; ILabels[28] := A2ILabel28; ILabels[29] := A2ILabel29;

   SLabels[0] := LbSkill0; SLabels[1] := LbSkill1; SLabels[2] := LbSkill2; SLabels[3] := LbSkill3;
   SLabels[4] := LbSkill4; SLabels[5] := LbSkill5; SLabels[6] := LbSkill6; SLabels[7] := LbSkill7;


   for i := 0 to 30-1 do SetMagicLabel (MLabels[i], '', 0, 0);
   for i := 0 to 30-1 do SetMagicLabel (BLabels[i], '', 0, 0);
{
   for i := 0 to AttribItemMaxCount - 1 do begin
      AttribitemData[i].ItemName  := '';
      AttribitemData[i].ItemShape := 0;
      AttribitemData[i].ItemColor := 0;
      AttribitemData[i].ItemCount := 0;
      AttribitemData[i].memPos    := -1;
   end;
   DragDropSelectNum := -1;
   SelectItem := -1;
}
end;

procedure TFrmAttrib.FormDestroy(Sender: TObject);
begin
   application.UnhookMainWindow(AppKeyDownHook);

   savekeyImagelib.Free;
   savekeyImage.Free;

   CharCenterImage.Free;
end;
{
procedure TFrmAttrib.ItemClear(aName: string; aCount, idx: integer);
begin
   if AttribitemData[idx].ItemName <> aName then exit;
   if AttribitemData[idx].ItemCount < aCount then exit;
   AttribitemData[idx].ItemCount := AttribitemData[idx].ItemCount - aCount;
   if AttribitemData[idx].ItemCount = 0 then begin
      AttribitemData[idx].ItemName  := '';
      AttribitemData[idx].ItemShape := 0;
      AttribitemData[idx].ItemColor := 0;
      AttribitemData[idx].ItemCount := 0;
      AttribitemData[idx].memPos    := 0;
      SetItemLabel (ILabels[idx], '', 0, 0);
   end;
end;
}
procedure TFrmAttrib.SetItemLabel (Lb: TA2ILabel; aname: string; acolor: byte; shape: word);
var
   gc, ga: integer;
begin
   Lb.Caption := '';
   GetGreenColorAndAdd (acolor, gc, ga);

   Lb.GreenCol := gc;
   Lb.GreenAdd := ga;

   if shape = 0 then begin
      Lb.A2Image := nil;
      Lb.BColor := 0;
      exit;
   end else
      Lb.A2Image := AtzClass.GetItemImage (shape);
end;

procedure TFrmAttrib.SetMagicLabel (Lb : TA2ILabel; aname: string; acolor: byte; shape: word);
var
   gc, ga: integer;
begin
   Lb.Caption := '';
   Lb.Hint := aname;

   GetGreenColorAndAdd (acolor, gc, ga);

   Lb.GreenCol := gc;
   Lb.GreenAdd := ga;

//   if shape = 0 then begin
//      Lb.A2Image := nil;
//      Lb.BColor := 0;
//      exit;
//   end else
   Lb.A2Image := AtzClass.GetMagicImage (shape);

   KeySelmagicIndex := -1; // 公傍父 困摹函版啊瓷
   if Lb.Hint <> '' then begin
      KeySelmagicIndex := Lb.Tag+30;
      savekeyBool := TRUE;
   end;

end;

procedure TFrmAttrib.MessageProcess (var code: TWordComData);
var
   psAttribValues : PTSAttribValues;
   psAttribBase : PTSAttribBase;
   psWearItem : PTSWearItem;
   psHaveMagic : PTSHaveMagic;
   psHaveItem : PTSHaveItem;
begin
   case Code.Data[0] of
      SM_HAVEITEM :
         begin
            psHaveItem := @Code.Data;
            with pshaveitem^ do begin
               SetItemLabel (ILabels[rkey], StrPas (@rName), pshaveitem^.rColor, rshape);
               if rcount <= 1 then ILabels[rkey].Hint := StrPas (@rName)
               else ILabels[rkey].Hint := StrPas (@rName) + ':' + IntToStr(rCount);
            end;
         end;
      SM_WEARITEM :
         begin
            psWearItem := @Code.Data;
            WearStrings[pswearitem^.rkey] := StrPas (@pswearitem^.rName);
         end;
      SM_BASICMAGIC:
         begin
            psHaveMagic := @Code.Data;
            with pshaveMagic^ do begin
               if StrPas (@rName) <> '' then // enddragpos
                  SetMagicLabel (BLabels[rkey], StrPas (@rName)+':'+Get10000To100 (rSkillLevel), 0, rShape)
               else begin // startdragpos
                  SetMagicLabel (BLabels[rkey], StrPas (@rName), 0, 0);
                  with pshavemagic^ do begin
                     BasicBuffer[rkey] := '';
                     BLabels[rkey].repaint;
                  end;
               end;
            end;
         end;
      SM_HAVEMAGIC :
         begin
            psHaveMagic := @Code.Data;
            with pshaveMagic^ do begin
               if StrPas (@rName) <> '' then // enddragpos
                  SetMagicLabel (MLabels[rkey], StrPas (@rName)+':'+Get10000To100 (rSkillLevel), 0, rShape)
               else begin // startdragpos
                  SetMagicLabel (MLabels[rkey], StrPas (@rName), 0, 0);
                  with pshavemagic^ do begin
                     BasicBuffer[rkey+30] := '';
                     MLabels[rkey].repaint;
                  end;
               end;
            end;
         end;
      SM_ATTRIBBASE :
         begin
            psAttribBase := @Code.Data;
            LbAge.Caption := Get10000To100 (psAttribBase^.rAge);
         end;
      SM_ATTRIB_VALUES :
         begin
            psAttribValues := @Code.Data;
            with psAttribValues^ do begin
               LbLight.Caption := Get10000To100 (rLight);
               LbDark.Caption := Get10000To100 (rDark);
//               LbMagic.Caption := Get10000To100 (rMagic);
               LbTalent.Caption := Get10000To100 (rTalent);
               LbGoodChar.Caption := Get10000To100 (rGoodChar);
               LbBadChar.Caption := Get10000To100 (rBadChar);
//               ListboxAttrib.Items.Add ('玫款 : ' + Get10000To100 (rLucky));
               LbAdaptive.Caption := Get10000To100 (rAdaptive);
               LbRevival.Caption := Get10000To100 (rRevival);
               LbImmunity.Caption := Get10000To100 (rImmunity);
               LbVirtue.Caption := Get10000To100 (rVirtue);

//               LbHealth.Caption := IntToStr (rhealth div 100);
//               LbPoisoning.Caption := IntToStr (rpoisoning div 100);
//               LbSatiety.Caption := IntToStr (rsatiety div 100);
            end;
            PgHead.Progress := psAttribValues^.rHeadSeak;
            PgArm.Progress := psAttribValues^.rArmSeak;
            PgLeg.Progress := psAttribValues^.rLegSeak;
         end;
   end;
end;



function IsInArea (CharImage: TA2Image; ax, ay: integer): Boolean;
var
   xp, yp: integer;
   xx, yy: integer;
   pb : pword;
begin
   Result := TRUE;
   xx := CharImage.px + 28;
   yy := CharImage.py + 36;

   if (ax <= xx) then Result := FALSE;
   if (ay <= yy) then Result := FALSE;
   if ax >= xx + CharImage.Width then Result := FALSE;
   if ay >= yy + CharImage.Height then Result := FALSE;
   if Result = FALSE then exit;

   xp := ax-xx;
   yp := ay-yy;

   pb := PWORD (CharImage.bits);
   inc (pb, xp + yp*CharImage.Width);
   if pb^ = 0 then Result := FALSE;
end;

procedure TFrmAttrib.LbCharMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   i, n : integer;
   CL : TCharClass;
   ImageLib : TA2ImageLib;
begin
   Cl := CharList.GetChar (CharCenterId);
   if Cl = nil then exit;

   n := 0;
   for i := 1 to 10-1 do begin
      ImageLib := Cl.GetArrImageLib (i, mmAnsTick);
      if ImageLib <> nil then begin
         if IsInArea (ImageLib.Images[57], x, y) then n := i;
      end;
   end;
   if n <> 0 then MouseInfoStr := WearStrings[n];

   if SelWearItemIndex <> 0 then TA2ILabel(Sender).BeginDrag (TRUE);
end;

procedure TFrmAttrib.LbCharStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
   DragItem.Selected := SelWearItemIndex;
   DragItem.Dragedid := 0;
   DragItem.SourceId := WINDOW_WEARS;
   DragObject := DragItem;
   SelWearItemIndex := 0;
end;

procedure TFrmAttrib.LbCharMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i, n : integer;
   CL : TCharClass;
   ImageLib : TA2ImageLib;
begin
   Cl := CharList.GetChar (CharCenterId);
   if Cl = nil then exit;

   n := 0;
   for i := 1 to 10-1 do begin
      ImageLib := Cl.GetArrImageLib (i, mmAnsTick);
      if ImageLib <> nil then begin
         if IsInArea (ImageLib.Images[57], x, y) then n := i;
      end;
   end;
   SelWearItemIndex := n;
end;

procedure TFrmAttrib.LbCharDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_ITEMS then Accept := TRUE;
      end;
   end;
end;

procedure TFrmAttrib.LbCharDragDrop(Sender, Source: TObject; X, Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;

   with Source as TDragItem do begin
      if SourceID <> WINDOW_ITEMS then exit;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := DragedId;
      cDragDrop.rdestId := 0;
      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_WEARS;
      cDragDrop.rsourkey := Selected;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop);
   end;
end;

var
   OldFeature : TFeature;

procedure TFrmAttrib.DrawWearItem;
var
   i, gc, ga: integer;
   Cl : TCharClass;
   ImageLib : TA2ImageLib;
begin
   Cl := CharList.GetChar (CharCenterId);
   if Cl = nil then exit;

   if not CompareMem (@OldFeature, @Cl.Feature, sizeof(TFeature)) then begin

      CharCenterImage.Clear (0);

      for i := 0 to 10 -1 do begin
         ImageLib := Cl.GetArrImageLib (i, mmAnsTick);
         if ImageLib <> nil then begin
            GetGreenColorAndAdd (Cl.Feature.rArr[i*2+1], gc, ga);
            if Cl.Feature.rArr[i*2+1] = 0 then
               CharCenterImage.DrawImage (ImageLib.Images[57], ImageLib.Images[57].px+28, ImageLib.Images[57].py+36, TRUE)
            else
//               CharCenterImage.DrawImageGreenConvert (ImageLib.Images[105], ImageLib.Images[105].px+28, ImageLib.Images[105].py+36, ColorIndex[Cl.Feature.rArr[i*2+1]], 0);
               CharCenterImage.DrawImageGreenConvert (ImageLib.Images[57], ImageLib.Images[57].px+28, ImageLib.Images[57].py+36, gc, ga);
         end;
      end;
      OldFeature := Cl.Feature;
      LbChar.A2Image := CharCenterImage;
   end;
end;

procedure TFrmAttrib.ItemLabelDblClick(Sender: TObject);
var
   cClick : TCClick;
begin
   cClick.rmsg := CM_DBLCLICK;
   cClick.rwindow := WINDOW_ITEMS;
   cClick.rclickedId := 0;
   cClick.rShift := KeyShift;
   cClick.rkey := TA2ILabel(Sender).tag;
   Frmlogon.SocketAddData (sizeof(cClick), @cClick);
end;

procedure TFrmAttrib.ItemLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;
   with Source as TDragItem do begin
      case SourceID of
         WINDOW_ITEMLOG, WINDOW_ITEMS, WINDOW_WEARS, WINDOW_SCREEN:;
         else exit;
      end;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := Dragedid;
      cDragDrop.rdestId := 0;
      cDragDrop.rsx := sx;
      cDragDrop.rsy := sy;
      cDragDrop.rdx := 0;
      cDragDrop.rdy := 0;
      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_ITEMS;
      case SourceId of
         WINDOW_ITEMS: cDragDrop.rsourkey := Selected;
         WINDOW_WEARS: cDragDrop.rsourkey := Selected;
      end;
      cDragDrop.rsourkey := Selected;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop); // server r
   end;
end;

{
procedure TFrmAttrib.CheckattribDragDropItem(aname: string; aCount: integer);
var
   i, iCount : integer;
begin
   if (aname = '') or (aCount = 0) then exit;
   iCount := AttribitemData[FrmDepository.DepitemData[DragDropSelectNum].mempos].itemCount;
   if FrmDepository.DepitemData[DragDropSelectNum].mempos <> SelectItem then
      SelectItem := FrmDepository.DepitemData[DragDropSelectNum].mempos;

   if FrmDepository.DepitemData[DragDropSelectNum].memPos = -1 then begin
      if AttribItemData[SelectItem].ItemName <> '' then begin
         for i := 0 to AttribItemMaxCount - 1 do begin
            if AttribitemData[i].ItemName = '' then SelectItem := i;
         end;
      end;
   end;

   if FrmDepository.DepitemData[DragDropSelectNum].ItemCount >= aCount then
      AttribitemData[SelectItem].ItemCount := iCount + aCount
   else begin
      DragDropSelectNum := -1;
      SelectItem := -1;
      exit;
   end;

   if FrmDepository.DepitemData[DragDropSelectNum].ItemName = aname then
      AttribitemData[SelectItem].ItemName := aname
   else begin
      DragDropSelectNum := -1;
      SelectItem := -1;
      exit;
   end;
   AttribitemData[SelectItem].ItemShape := FrmDepository.DepitemData[DragDropSelectNum].ItemShape;
   AttribitemData[SelectItem].ItemColor := FrmDepository.DepitemData[DragDropSelectNum].ItemColor;
   AttribitemData[SelectItem].memPos := DragDropSelectNum;

   SetItemLabel (ILabels[SelectItem], FrmDepository.DepitemData[DragDropSelectNum].ItemName, FrmDepository.DepitemData[DragDropSelectNum].ItemColor, FrmDepository.DepitemData[DragDropSelectNum].ItemShape);
   FrmDepository.ItemClear(aName, aCount,DragDropSelectNum);
   DragDropSelectNum := -1;
   SelectItem := -1;
end;
}
procedure TFrmAttrib.A2ILabel0DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_ITEMS then Accept := TRUE;
         if SourceID = WINDOW_WEARS then Accept := TRUE;
         if SourceID = WINDOW_SCREEN then Accept := TRUE;
         if SourceID = WINDOW_ITEMLOG then Accept := TRUE;
      end;
   end;
end;

procedure TFrmAttrib.ItemLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Temp : TA2ILabel;
begin
   SelectedItemLabel := Ta2ILabel(Sender);
   Temp := Ta2ILabel (Sender);
   if (x < 0) or (y <0) or (x>Temp.Width) or (y>Temp.Height) then begin
      if temp.A2Image <> nil then Temp.BeginDrag (TRUE);
   end;
   MouseInfoStr := TA2ILabel (Sender).Hint;
end;

procedure TFrmAttrib.ItemLabelStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
   if Sender is TA2ILabel then begin
      DragItem.Selected := TA2ILabel(Sender).Tag;
      DragItem.SourceId := WINDOW_ITEMS;
      DragItem.Dragedid := 0;
      DragItem.sx := 0; DragItem.sy := 0;
      DragObject := DragItem;
   end;
end;

procedure TFrmAttrib.MLabelDblClick(Sender: TObject);
begin
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_DBLCLICK;
   GrobalClick.rwindow := WINDOW_MAGICS;
   GrobalClick.rclickedId := 0;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).tag;
end;

procedure TFrmAttrib.MLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;

   with Source as TDragItem do begin
      case SourceID of
         WINDOW_MAGICS:;
         else exit;
      end;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := Dragedid;
      cDragDrop.rdestId := 0;
      cDragDrop.rsx := sx;
      cDragDrop.rsy := sy;
      cDragDrop.rdx := 0;
      cDragDrop.rdy := 0;
      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_MAGICS;
      case SourceId of
         WINDOW_MAGICS: cDragDrop.rsourkey := Selected;
      end;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop);
   end;
end;

procedure TFrmAttrib.MLabelDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_MAGICS then Accept := TRUE;
      end;
   end;
end;

procedure TFrmAttrib.MLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   per : integer;
begin
   if x < 31 then exit;
   if y > 35 then y := 35;
   per := (35- y) div 3;

   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_CLICKPERCENT;
   GrobalClick.rwindow := WINDOW_MAGICS;
   GrobalClick.rclickedId := per;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).Tag;
end;

procedure TFrmAttrib.MLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Temp : TA2ILabel;
begin
   Last_X := X;
   SelectedMagicLabel := TA2ILabel(Sender);
   Temp := TA2ILabel (Sender);
   if (x < 0) or (y <0) or (x>Temp.Width) or (y>Temp.Height) then begin
      if temp.A2Image <> nil then Temp.BeginDrag (TRUE);
   end;
   MouseInfoStr := TA2ILabel (Sender).Hint;

   KeySelmagicIndex := -1;
   if temp.Hint <> '' then begin
      KeySelmagicIndex := TA2ILabel(Sender).Tag+30;
      savekeyBool := TRUE;
   end;
end;

procedure TFrmAttrib.MLabelStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
   if Sender is TA2ILabel then begin
      DragItem.Selected := TA2ILabel(Sender).Tag;
      DragItem.SourceId := WINDOW_MAGICS;
      DragItem.Dragedid := 0;
      DragItem.sx := 0; DragItem.sy := 0;
      DragObject := DragItem;
   end;
end;

procedure TFrmAttrib.BLabel0DblClick(Sender: TObject);
begin
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_DBLCLICK;
   GrobalClick.rwindow := WINDOW_BASICFIGHT;
   GrobalClick.rclickedId := 0;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).Tag;
end;

procedure TFrmAttrib.BLabel0MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Temp : TA2ILabel;
begin
   Last_X := X;
   SelectedMagicLabel := TA2ILabel(Sender);
   Temp := TA2ILabel (Sender);
   if (x < 0) or (y <0) or (x>Temp.Width) or (y>Temp.Height) then begin
      if temp.A2Image <> nil then Temp.BeginDrag (TRUE);
   end;
   MouseInfoStr := TA2ILabel (Sender).Hint;

   KeySelmagicIndex := -1;
   if temp.Hint <> '' then begin
      KeySelmagicIndex := TA2ILabel(Sender).Tag;
      savekeyBool := TRUE;
   end;
end;

procedure TFrmAttrib.FormShow(Sender: TObject);
begin
   BackScreen.SWidth := 640-192;
   BackScreen.SHeight:= 360;
//   FrmM.DXTimerTimer(Self, 0);
end;

procedure TFrmAttrib.FormHide(Sender: TObject);
begin
   BackScreen.SWidth := 640;
   BackScreen.SHeight:= 360;
//   FrmM.DXTimerTimer(Self, 0);
end;

procedure TFrmAttrib.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   MouseInfoStr := '';
end;

procedure TFrmAttrib.BLabel0StartDrag(Sender: TObject; var DragObject: TDragObject);
begin
   if Sender is TA2ILabel then begin
      DragItem.Selected := TA2ILabel(Sender).Tag;
      DragItem.SourceId := WINDOW_BASICFIGHT;
      DragItem.Dragedid := 0;
      DragItem.sx := 0; DragItem.sy := 0;
      DragObject := DragItem;
   end;
end;

procedure TFrmAttrib.LbSkill0Click(Sender: TObject);
begin
//
end;

procedure TFrmAttrib.LbSkill0DblClick(Sender: TObject);
begin
//
end;

procedure TFrmAttrib.LbSkill0MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   LbWindowName.Caption := TLabel (Sender).Hint;
end;

procedure TFrmAttrib.LbSkill4Click(Sender: TObject);
begin
//   Frmdyeing.Visible := not Frmdyeing.Visible;
end;

procedure TFrmAttrib.BLabel0Click(Sender: TObject);
begin
//   GrobalClick : TCClick;
//   ClickTick : integer = 0;
//   savekeyBool := TRUE;
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_CLICK;
   GrobalClick.rwindow := WINDOW_BASICFIGHT;
   GrobalClick.rclickedId := 0;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).Tag;
   //
//   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmAttrib.MLabel0Click(Sender: TObject);
begin
//   savekeyBool := TRUE;
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_CLICK;
   GrobalClick.rwindow := WINDOW_MAGICS;
   GrobalClick.rclickedId := 0;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).Tag;
//   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmAttrib.A2ILabel26Click(Sender: TObject);
begin
   ClickTick := mmAnsTick;
   FillChar (GrobalClick, sizeof(GrobalClick), 0);

   GrobalClick.rmsg := CM_CLICK;
   GrobalClick.rwindow := WINDOW_ITEMS;
   GrobalClick.rclickedId := 0;
   GrobalClick.rShift := KeyShift;
   GrobalClick.rkey := TA2ILabel(Sender).Tag;
end;

procedure TFrmAttrib.BLabel0Paint(Sender: TObject);
var
   idx : integer;
begin
   idx := 0;
   if BasicBuffer [ TA2ILabel(Sender).Tag] <> '' then begin
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F5' then idx := 10;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F6' then idx := 11;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F7' then idx := 12;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F8' then idx := 13;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F9' then idx := 14;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F10' then idx := 15;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F11' then idx := 16;
      if BasicBuffer [ TA2ILabel(Sender).Tag] = 'F12' then idx := 17;

      savekeyImage.DrawImage (TA2ILabel(Sender).A2Image,0,0,FALSE);
      savekeyImage.DrawImage (savekeyImagelib[idx],1,1,TRUE);
      A2DrawImage (TA2ILabel (Sender).Canvas, 0,0, savekeyImage);
   end;
//   TA2ILabel (Sender).Canvas.TextOut (3,2, BasicBuffer [ TA2ILabel(Sender).Tag] );
end;

procedure TFrmAttrib.MLabel0Paint(Sender: TObject);
var
   idx : integer;
begin
   idx := 0;
   if BasicBuffer [ TA2ILabel(Sender).Tag + 30] <> '' then begin
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F5' then idx := 10;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F6' then idx := 11;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F7' then idx := 12;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F8' then idx := 13;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F9' then idx := 14;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F10' then idx := 15;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F11' then idx := 16;
      if BasicBuffer [ TA2ILabel(Sender).Tag+ 30] = 'F12' then idx := 17;

      savekeyImage.DrawImage (TA2ILabel(Sender).A2Image,0,0,FALSE);
      savekeyImage.DrawImage (savekeyImagelib[idx],1,1,TRUE);
      A2DrawImage (TA2ILabel (Sender).Canvas, 0,0, savekeyImage);
   end;
//   TA2ILabel (Sender).Canvas.TextOut (3,2, BasicBuffer [ TA2ILabel(Sender).Tag + 20] );
end;

end.




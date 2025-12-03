unit FBottom;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  adeftype, deftype, StdCtrls, A2Form, ExtCtrls, Autil32, A2Img, CharCls,
  uAnsTick, DXDraws, Gauges, Buttons, Cltype, ctable, log, Acibfile, clmap,
  AtzCls, uPerSonBat;

type

  TFrmBottom = class(TForm)
    Image1: TImage;
    PGEnergy: TGauge;
    PGInPower: TGauge;
    PgOutPower: TGauge;
    PgMagic: TGauge;
    PgLife: TGauge;
    BtnItem: TSpeedButton;
    BtnMagic: TSpeedButton;
    BtnBasic: TSpeedButton;
    BtnAttrib: TSpeedButton;
    BtnSkill: TSpeedButton;
    LbChat: TListBox;
    ListboxUsedMagic: TListBox;
    EdChat: TEdit;
    LbPos: TLabel;
    BtnSelMagic: TA2Button;
    BtnWAttrib: TA2Button;
    procedure FormCreate(Sender: TObject);
    procedure AddChat ( astr: string; fcolor, bcolor: integer);
    procedure LBChatDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure EdChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBoxUsedMagicEnter(Sender: TObject);
    procedure EdChatKeyPress(Sender: TObject; var Key: Char);
    procedure EdChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnItemClick(Sender: TObject);
    procedure BtnMagicClick(Sender: TObject);
    procedure BtnDefMagicClick(Sender: TObject);
    procedure BtnAttribClick(Sender: TObject);
    procedure BtnSkillClick(Sender: TObject);
    procedure BtnItemMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BtnWAttribClick(Sender: TObject);
    procedure BtnSelMagicClick(Sender: TObject);
    procedure EdChatEnter(Sender: TObject);
    procedure LbChatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LbChatClick(Sender: TObject);
    procedure LbChatDblClick(Sender: TObject);
    procedure ListboxUsedMagicDblClick(Sender: TObject);
    procedure LbChatEnter(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure capture(bitmap : Tbitmap);
  public
    { Public declarations }
    curlife, maxlife : integer;
    procedure MessageProcess (var code: TWordComData);
    procedure SetFormText;

    procedure ClientCapture;
  end;

var
   FrmBottom: TFrmBottom;
   chat_outcry, chat_Guild, chat_notice, chat_normal : Boolean;
   MapName : string;
   SaveChatList : TStringList;
   CloseFlag : Boolean = FALSE;

implementation

uses
   FMain, FLogOn, FAttrib, FExchange, FSound, FDepository, FSearchUser,
   FmuOffer, FBatList, FMuMagicOffer;
//   FmunpaCreate, FcMessageBox, FNpcView, FQView, FItemStoreView, FMunpaimpo,
//   FmunpaWarOffer, FMunpaChallenger;

{$R *.DFM}


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

procedure TFrmBottom.SetFormText;
begin
   // FrmBottom Set Font
   FrmBottom.Font.Name := mainFont;
   ListboxUsedMagic.Font.Name := mainFont;
   LbChat.Font.Name := mainFont;
   EdChat.Font.Name := mainFont;
   LbPos.Font.Name := mainFont;
   chat_outcry := TRUE;
   chat_Guild := TRUE;
   chat_notice := TRUE;
   chat_normal := TRUE;

   BtnItem.Hint := Conv('ŒÔ∆∑');
   BtnMagic.Hint := Conv('Œ‰π¶');
   BtnBasic.Hint := Conv('ª˘±æŒ‰π¶');
   BtnAttrib.Hint := Conv(' Ù–‘');
   BtnSkill.Hint := Conv('ºº ı');
end;

procedure TFrmBottom.FormCreate(Sender: TObject);
begin
   Color := clBlack;
   Parent := FrmM;
//   FrmM.AddA2Form (Self, A2form);
   Left := 0; Top := 480-Height;
   SetFormText;
   MapName := '';
   SaveChatList := TStringList.Create;
end;

procedure TFrmBottom.FormDestroy(Sender: TObject);
begin
   SaveChatList.Free;
end;

procedure TFrmBottom.MessageProcess (var code: TWordComData);
var
   str, rdstr: string;
   cstr : string[1];
   pckey : PTCKey;
   psSay : PTSSay;
   psChatMessage : PTSChatMessage;
   psAttribBase : PTSAttribBase;
   psAttriblife : PTSAttribLife;
   psEventString : PTSEventString;
begin
   pckey := @Code.Data;
   case pckey^.rmsg of
      SM_USEDMAGICSTRING :
         begin
            ListboxUsedMagic.Clear;
            psEventString := @Code.data;

            str := GetWordString (psEventString^.rWordString);
            while TRUE do begin
               str := GetValidStr3 (str, rdstr, ',');
               if rdstr = '' then break;
               if ListboxUsedMagic.Items.Count < 4 then
                  ListboxUsedMagic.Items.Add (rdstr);
            end;
         end;
      SM_ATTRIBBASE :
         begin
            psAttribBase := @Code.Data;
            with psAttribBase^ do begin
               maxlife := psAttribBase^.rlife;
               curlife := psAttribBase^.rcurlife;

//               LbAge.Caption := IntToStr (psattribBase^.rage div 100);
//               PGAge.Progress := psattribBase^.rage mod 100;

//               LbEnergy.Caption := IntToStr (psattribBase^.rCurEnergy div 100);
//               LbEnergy.Caption := IntToStr(rCurEnergy div 100) + '/' + IntToStr(rEnergy div 100);
               PGEnergy.MaxValue := psattribBase^.rEnergy;
               PGEnergy.Progress := psattribBase^.rCurEnergy;
//               PGEnergy.Hint := IntToStr(rCurEnergy div 100) + '/' + IntToStr(rEnergy div 100);
               PGEnergy.Hint := Get10000To100(rCurEnergy) + '/' + Get10000To100(rEnergy);


//               LbInPower.Caption := IntToStr(rCurInPower div 100) + '/' + IntToStr(rInPower div 100);
               PGInPower.MaxValue := psattribBase^.rInPower;
               PGInPower.Progress := psattribBase^.rCurInPower;
//               PGInPower.Hint := IntToStr(rCurInPower div 100) + '/' + IntToStr(rInPower div 100);
               PGInPower.Hint := Get10000To100(rCurInPower) + '/' + Get10000To100(rInPower);

//               LbOutPower.Caption := IntToStr(rCurOutPower div 100) + '/' + IntToStr(rOutPower div 100);
               PGOutPower.MaxValue := psattribBase^.rOutPower;
               PGOutPower.Progress := psattribBase^.rCurOutPower;
//               PGOutPower.Hint := IntToStr(rCurOutPower div 100) + '/' + IntToStr(rOutPower div 100);
               PGOutPower.Hint := Get10000To100(rCurOutPower) + '/' + Get10000To100(rOutPower);

//               LbMagic.Caption := IntToStr(psattribbase^.rCurMagic div 100) + '/' + IntToStr(psattribbase^.rMagic div 100);
               PGMagic.MaxValue := psattribBase^.rMagic;
               PGMagic.Progress := psattribBase^.rCurMagic;
//               PGMagic.Hint := IntToStr(psattribbase^.rCurMagic div 100) + '/' + IntToStr(psattribbase^.rMagic div 100);
               PGMagic.Hint := Get10000To100(psattribbase^.rCurMagic) + '/' + Get10000To100(psattribbase^.rMagic);

//               LbLife.Caption := IntToStr(curlife div 100) + '/' + IntToStr(maxlife div 100);
               PGLife.MaxValue := maxlife;
               PGLife.Progress := curlife;
//               PGLife.Hint := IntToStr(curlife div 100) + '/' + IntToStr(maxlife div 100);
               PGLife.Hint := Get10000To100(curlife) + '/' + Get10000To100(maxlife);
            end;
         end;
      SM_ATTRIB_LIFE :
         begin
            psAttribLife := @Code.Data;
            curlife := psAttribLife^.rcurlife;
            PGLife.Progress := curlife;
            PGLife.Hint := IntToStr(curlife) + '/' + IntToStr(maxlife);
//            LbLife.Caption := IntToStr(curlife) + '/' + IntToStr(maxlife);
         end;
      SM_CHATMESSAGE :
         begin

            psChatMessage := @Code.data;

            str := GetwordString(psChatMessage^.rWordstring);
            cstr := str;
            if (cstr = '[') or (cstr = '<') then begin
               if pos(':', str) > 1 then begin
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
            str := GetwordString(psSay^.rWordstring);
            str := GetValidStr3 (str, rdstr, ':');
            str := ChangeDontSay (str);
            rdstr := rdstr + ' :' + str;
            AddChat (rdstr, WinRGB (28,28,28), 0);
            str := ''; rdstr := '';
//            Cl := CharList.GetChar (psSay^.rid);
//            if Cl <> nil then Cl.Say (GetwordString(pssay^.rWordstring));
         end;
   end;
end;

procedure TFrmBottom.AddChat ( astr: string; fcolor, bcolor: integer);
var
   str, rdstr: string;
   col : Integer;
   addflag : Boolean;
begin
//   FrmChatList.AddChat (astr, fcolor, bcolor);
   addflag := FALSE;
   str := astr;
   while TRUE do begin
      str := GetValidStr3 (str, rdstr, #13);
      if rdstr = '' then break;

      if chat_outcry then begin // ø‹ƒ°±‚
         if rdstr[1] = '[' then begin
            addflag := TRUE;
         end;
      end;

      if chat_Guild then begin  // ±ÊµÂ
         if rdstr[1] = '<' then begin
            addflag := TRUE;
         end;
      end;

      if chat_notice then begin // ∞¯¡ˆªÁ«◊
         if bcolor = 16912 then begin
            addflag := TRUE;
         end;
      end;

      if chat_normal then begin  // ¿œπ›¿Ø¿˙
         if not(bcolor = 16912) and not(rdstr[1] = '<') and not(rdstr[1] = '[') then begin
            addflag := TRUE;
         end;
      end;

      if Addflag then begin
         if LbChat.Items.Count >= 4 then LbChat.Items.delete (0);
         col := MakeLong (fcolor, bcolor);
         LbChat.Items.addObject (rdstr, TObject (col) );
      end;

      LbChat.Itemindex := LbChat.Items.Count -1;
      LbChat.Itemindex := -1;
   end;
{ // ø‹ƒ°±‚ æ»∫∏¿Ã±‚ √ﬂ∞°∑Œ πŸ≤Ò
   str := astr;
   while TRUE do begin
      str := GetValidStr3 (str, rdstr, #13);
      if rdstr = '' then break;
      if LbChat.Items.Count >= 4 then LbChat.Items.delete (0);

      col := MakeLong (fcolor, bcolor);
      LbChat.Items.addObject (rdstr, TObject (col) );

      LbChat.Itemindex := LbChat.Items.Count -1;
      LbChat.Itemindex := -1;
   end;
}
end;


function  savefilename: string;
var
   year, mon, day,hour, min, sec, dummy : word;
   str : string;
   function  num(n : integer): string;
   begin
      Result := '';
      if n >= 10 then Result := IntToStr (n)
      else Result := '0'+InttoStr(n);
   end;
begin
   str := '';
   DecodeDate(Date, year, mon, day);
   DecodeTime(Time, hour, min, sec, dummy);
   str := num(year)+Conv('ƒÍ')+num(mon)+Conv('‘¬')+num(day)+Conv('»’');
   str := str + num(hour)+Conv(' ±')+num(min)+Conv('∑÷')+num(sec)+Conv('√Î');
   Result := str;
end;

function DirExists(Name: string): Boolean;
var
   Code: Integer;
begin
   Code := GetFileAttributes(PChar(Name));
   Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

procedure TFrmBottom.capture(bitmap : Tbitmap);
var
   FrmMRect : TRect;
   FrmMDC : HDC;
   FrmMDCcanvas : TCanvas;
begin
   BitMap.Width := FrmM.Width;
   BitMap.Height := FrmM.Height;
   FrmMRect:= Rect(0, 0, FrmM.Width, FrmM.Height);

   FrmMDC := GetWindowDC(FrmM.Handle);
   FrmMDCcanvas := TCanvas.Create;
   FrmMDCcanvas.Handle := FrmMDC;
   Bitmap.Canvas.CopyRect(FrmMRect, FrmMDCcanvas, FrmMRect);
   ReleaseDC(FrmM.Handle, FrmMDC);
   FrmMDCcanvas.Free;
end;

procedure TFrmBottom.ClientCapture;
var
   abitmap : TBitmap;
   CIBfile : TCIBfileA;
   str : string;
begin
   CIBfile := TCIBfileA.Create;
   abitmap := TBitmap.Create;
   capture (abitmap);
   if DirExists('.\capture') then else Mkdir('.\' + 'capture');
   str := SaveFileName;
   aBitMap.SaveToFile ('.\capture\'+str+'.bmp');
   CIBfile.saveToFile ('.\capture\'+str+'.cib', CharCenterName+' '+Map.GetMapName, ReConnectIpAddr, abitmap, SaveChatList);
   CIBfile.Free;
   abitmap.Free;
   AddChat (Conv( 'Capture_File(' ) + str +')', $FFFF, 0);
end;

var
   LbChatClickFlag : Boolean = TRUE;

/////////////////////////////// LbChat events //////////////////////////////////
procedure TFrmBottom.LbChatClick(Sender: TObject);
begin
   Sleep (300);
   if LbChatClickFlag then boShowChat := not boShowChat;
end;

procedure TFrmBottom.LbChatDblClick(Sender: TObject);
{
var
   idx : integer;
   str, rdstr : string;
}
begin
{ // øÏº±∏∑æ∆≥ı¿Ω
   boShowChat := not boShowChat;
   LbChatClickFlag := FALSE;
   idx := TListBox(Sender).itemindex;
   if (idx > -1) and (idx < 4) then begin
      str := LbChat.Items[idx];
      str := GetValidStr3 (str, rdstr, ':');
      EdChat.Text := str;
   end;
   LbChatClickFlag := TRUE;
}
end;

procedure TFrmBottom.LBChatDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   col : integer;
   fcol, bcol, r, g, b: word;
begin
   col := Integer (LbChat.Items.Objects [Index]);

   fcol := LOWORD (Col);
   bcol := HIWORD (col);

   WinVRGB (bcol, r, g, b);
   r := r * 8;
   g := g * 8;
   b := b * 8;
   LbChat.Canvas.Brush.Color := RGB(r, g, b);
   LBChat.Canvas.FillRect (Rect);

   WinVRGB (fcol, r, g, b);
   r := r * 8;
   g := g * 8;
   b := b * 8;
   LbChat.Canvas.Font.Color := RGB (r, g, b);
   LBChat.Canvas.TextOut (Rect.left, Rect.top, LbChat.Items[Index]);
end;

procedure TFrmBottom.LbChatMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   EdChat.SetFocus;
   { ∏∂øÏΩ∫ ø¿∏•¬ ªÁøÎ¿∏∑Œ ∫πªÁ
   tempPoint:= Point (x, y);
   if Button = mbRight then begin
      idx := LbChat.ItemAtPos (tempPoint, FALSE);
      EdChat.Text := LbChat.Items[idx];
   end;
   }
end;
/////////////////////////////// EdChat events //////////////////////////////////
procedure TFrmBottom.EdChatEnter(Sender: TObject);
begin
   SetImeMode (EdChat.Handle, 1);
end;


procedure TFrmBottom.EdChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
const
   KeyDownTick : DWORD = 0;
var
   Cl : TCharClass;
   cKey : TCKey;
   i, cnt : integer;
   str : string;
   cSay : TCSay;
   StringList : TStringList;
begin
   if (ssAlt in Shift) and (Key=word('M')) then begin  // Exit
      if Map.GetMapName <> 'south.map' then exit;
      FrmSearchUser.Visible := not FrmSearchUser.Visible;
   end;

   if (ssAlt in Shift) and (Key=word('X')) then begin  // Exit
      CloseFlag := TRUE;
      FrmLogOn.SocketDisConnect ('','',TRUE);
      exit;
   end;

   if (ssAlt in Shift) and (Key=VK_RETURN) then begin  // Screnn Mode Change
      if (NATION_VERSION = NATION_TAIWAN) or (NATION_VERSION = NATION_CHINA_1) then exit;
      FrmM.SaveAndDeleteAllA2Form;
      FrmM.DXDraw.Finalize;
      if doFullScreen in FrmM.DXDraw.Options then begin
         FrmM.BorderStyle := bsSingle;
         FrmM.ClientWidth := 640;
         FrmM.ClientHeight := 480;
         FrmM.DXDraw.Options := FrmM.DXDraw.Options - [doFullScreen];
      end else begin
         FrmM.BorderStyle := bsNone;
         FrmM.ClientWidth := 640;
         FrmM.ClientHeight := 480;
         FrmM.DXDraw.Options := FrmM.DXDraw.Options + [doFullScreen];
      end;
      FrmM.DXDraw.Initialize;
      FrmM.RestoreAndAddAllA2Form;
      exit;
   end;

   if (key = VK_RETURN) and (EdChat.Text <> '') then begin // Send SayData
      cSay.rmsg := CM_SAY;
      str := EdChat.Text;
      SetWordString (cSay.rWordString, str);
      cnt := sizeof(cSay) - sizeof(TWordString) + SizeOfWordString (cSay.rWordString);
      FrmLogon.SocketAddData (cnt, @csay);
   end;

   if (key = VK_RETURN) or (key = VK_ESCAPE) then begin  // EdChat.Text Clear
      EdChat.Text := '';
      exit;
   end;

   Keyshift := Shift;

   if mmAnsTick < integer(KeyDownTick)+25 then exit;
   KeyDownTick := mmAnsTick;

   case key of
      VK_F1  :
         begin
            if FileExists ('ect\help.txt') then begin
               StringList := TStringList.Create;
               StringList.LoadFromFile ('ect\help.txt');
               for i := 0 to StringList.Count -1 do
                  FrmM.AddChat (StringList[i], $FFFF, 0);
               boShowChat := TRUE;
               StringList.Free;
            end else begin
               AddChat ('Can not Open File [ect\help.txt]', $FFFF, 0);
            end;
         end;
      VK_F5  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F5');
      VK_F6  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F6');
      VK_F7  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F7');
      VK_F8  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F8');
      VK_F9  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F9');
      VK_F10  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F10');
      VK_F11  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F11');
      VK_F12  :
            if not (savekeyBool) then FrmAttrib.savekeyaction ('F12');
      else begin
         if key in [VK_F2,VK_F3,VK_F4] then begin
            ckey.rmsg := CM_KEYDOWN;
            ckey.rkey := key;
            FrmLogon.SocketAddData (sizeof(Ckey), @Ckey);
         end;
         Cl := CharList.GetChar (CharCenterId);
         if Cl = nil then exit;
         if Cl.AllowAddAction = FALSE then exit;

         case key of
            VK_F4 : CL.ProcessMessage (SM_MOTION, cl.dir, cl.x, cl.y, cl.feature, AM_HELLO);
         end;
      end;
      EdChat.SetFocus;
   end;
end;

procedure TFrmBottom.EdChatKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = char (VK_ESCAPE)) or (key = char(VK_RETURN)) then key := char(0);
end;

procedure TFrmBottom.EdChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Keyshift := Shift;
end;

procedure TFrmBottom.ListBoxUsedMagicEnter(Sender: TObject);
begin
   EdChat.SetFocus;
   boShowChat := not boShowChat;
end;

procedure TFrmBottom.BtnItemClick(Sender: TObject);
begin
   savekeyBool := FALSE; // FAttrib¿« savekey ∏∑¿Ω
   FrmAttrib.Visible := TRUE;
   FrmAttrib.LbWindowName.Caption := Conv('ŒÔ∆∑');
   FrmAttrib.LbMoney.Caption := Conv('ŒÔ∆∑');
   FrmAttrib.PanelItem.Visible := TRUE;
   FrmAttrib.PanelMagic.Visible := FALSE;
   FrmAttrib.PanelAttrib.Visible := FALSE;
   FrmAttrib.PanelBasic.Visible := FALSE;
   FrmAttrib.PanelSkill.Visible := FALSE;
end;

procedure TFrmBottom.BtnMagicClick(Sender: TObject);
begin
   savekeyBool := FALSE; // FAttrib¿« savekey ∏∑¿Ω
   FrmAttrib.Visible := TRUE;
   FrmAttrib.LbWindowName.Caption := Conv('Œ‰π¶');
   FrmAttrib.LbMoney.Caption := Conv('Œ‰π¶');
   FrmAttrib.PanelMagic.Visible := TRUE;
   FrmAttrib.PanelItem.Visible := FALSE;
   FrmAttrib.PanelAttrib.Visible := FALSE;
   FrmAttrib.PanelBasic.Visible := FALSE;
   FrmAttrib.PanelSkill.Visible := FALSE;
end;

procedure TFrmBottom.BtnDefMagicClick(Sender: TObject);
begin
   savekeyBool := FALSE; // FAttrib¿« savekey ∏∑¿Ω
   FrmAttrib.Visible := TRUE;
   FrmAttrib.LbWindowName.Caption := Conv('ª˘±æŒ‰π¶');
   FrmAttrib.LbMoney.Caption := Conv('ª˘±æŒ‰π¶');
   FrmAttrib.PanelBasic.Visible := TRUE;
   FrmAttrib.PanelAttrib.Visible := FALSE;
   FrmAttrib.PanelMagic.Visible := FALSE;
   FrmAttrib.PanelItem.Visible := FALSE;
   FrmAttrib.PanelSkill.Visible := FALSE;
end;

procedure TFrmBottom.BtnAttribClick(Sender: TObject);
begin
   savekeyBool := FALSE; // FAttrib¿« savekey ∏∑¿Ω
   FrmAttrib.Visible := TRUE;
   FrmAttrib.LbWindowName.Caption := Conv(' Ù–‘');
   FrmAttrib.LbMoney.Caption := Conv(' Ù–‘');
   FrmAttrib.PanelAttrib.Visible := TRUE;
   FrmAttrib.PanelMagic.Visible := FALSE;
   FrmAttrib.PanelItem.Visible := FALSE;
   FrmAttrib.PanelBasic.Visible := FALSE;
   FrmAttrib.PanelSkill.Visible := FALSE;
end;

procedure TFrmBottom.BtnSkillClick(Sender: TObject);
begin
   savekeyBool := FALSE; // FAttrib¿« savekey ∏∑¿Ω
   FrmAttrib.Visible := TRUE;
   FrmAttrib.LbWindowName.Caption := Conv('ºº ı');
   FrmAttrib.LbMoney.Caption := Conv('ºº ı');
   FrmAttrib.PanelSkill.Visible := TRUE;
   FrmAttrib.PanelAttrib.Visible := FALSE;
   FrmAttrib.PanelMagic.Visible := FALSE;
   FrmAttrib.PanelItem.Visible := FALSE;
   FrmAttrib.PanelBasic.Visible := FALSE;
end;

procedure TFrmBottom.BtnItemMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   MouseInfoStr := TSpeedButton (Sender).Hint;
end;

procedure TFrmBottom.BtnWAttribClick(Sender: TObject);
begin
   if FrmSearchUser.Visible then FrmSearchUser.Visible := FALSE;
   FrmAttrib.Visible := not FrmAttrib.Visible;
//   if FrmNpcView.Visible then FrmNpcView.SetPostion;
//   if FrmItemStoreView.Visible then FrmItemStoreView.SetPostion;
//   if FrmQView.Visible then FrmQView.SetPostion;

//   if FrmcMessageBox.Visible then FrmcMessageBox.SetPostion;
//   if FrmMunpaCreate.Visible then FrmMunpaCreate.SetPostion;
//   if FrmMunpaimpo.Visible then FrmMunpaimpo.SetPostion;
end;

procedure TFrmBottom.BtnSelMagicClick(Sender: TObject);
begin
   FrmSound.Visible := not FrmSound.Visible; // option√¢
//   FrmSelMagic.Visible := not FrmSelMagic.Visible;
end;

procedure TFrmBottom.ListboxUsedMagicDblClick(Sender: TObject);
begin
//   EdChat.SetFocus;
end;

procedure TFrmBottom.LbChatEnter(Sender: TObject);
begin
   LbChat.OnClick (nil);
   EdChat.SetFocus;
end;

procedure TFrmBottom.Timer1Timer(Sender: TObject);
//var i : integer;
begin
{
   if PgLife.Progress < (PgLife.MaxValue * 20 div 100) then begin
      FrmAttrib.ILabels[1].OnDblClick(Self);
   end;
   if PGInPower.Progress < (PGInPower.MaxValue * 10 div 100) then begin
      for i := 0 to 1 do begin
         FrmAttrib.A2ILabel0.OnDblClick (Self);
      end;
   end;
   if PgOutPower.Progress < (PgOutPower.MaxValue * 10 div 100) then begin
      for i := 0 to 1 do begin
         FrmAttrib.A2ILabel0.OnDblClick (Self);
      end;
   end;
}
end;


end.


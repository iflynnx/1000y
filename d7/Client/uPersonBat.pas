unit uPersonBat;

interface

uses
   A2Img, BackScrn, AUtil32, Deftype, uAnsTick, classes;

type
   TPersonBat = class
      private
         PersonBatLib : TA2ImageLib;
         FWinType : Byte;
         RightID, LeftID : string;
         RightWinCount, LeftWinCount : byte;
         RightBarImg, LeftBarImg : TA2Image;
         RightIDEnergy, LeftIDEnergy : byte;

         FShowBar : Boolean;
         FShowBatMsg : Boolean;
         FMsgStringList : TStringList;
         BatMsgText : String;
         BatMsgDelay : integer;
      public
         constructor Create;
         destructor  Destroy; override;

         procedure   Draw;
         procedure   SetID (aRightID, aLeftID : string);
         procedure   SetEnergy (aRightIDEnergy, aLeftIDEnergy : integer);
         procedure   BatMessageDraw (x, y, CurTick: integer);

         procedure   MessageProcess (var code: TWordComData);
         property    ShowBar : Boolean read FShowBar write FShowBar;
         property    ShowBatMsg : Boolean read FShowBatMsg write FShowBatMsg;
   end;

var
   PersonBat : TPersonBat;
implementation

{O+}

function  calculation4 (xMax,xValue,yMax,yValue,aResult : integer): integer;
begin
   Result := 0;
   case aResult of
      1 : Result := (xValue*yMax) div yValue;
      2 : Result := (xMax*yValue) div yMax;
      3 : Result := (xMax*yValue) div xValue;
      4 : Result := (xValue*yMax) div xMax;
   end;
end;

procedure MakeBarImage (aBarImage, SourImage : TA2Image; BarPersent, directionType: byte);
var
   i, n : integer;
   dd, ss, tempSS, Tempbit, TT : PTAns2Color;
   ibp : integer;
begin
   ibp := calculation4 (aBarImage.Width,0,100,BarPersent,2);
   if ibp > aBarImage.Width then ibp := aBarImage.Width;
   dd := SourImage.Bits;
   ss := aBarImage.Bits;

   GetMem (Tempbit, sizeof(TAns2Color)*SourImage.Height);
   TT := Tempbit;
   for i := 0 to SourImage.Height -1 do begin
      move (dd^, TT^, SizeOf(TAns2Color));
      inc (dd, SourImage.Width);
      inc (TT);
   end;
   case directionType of
      0 :
         begin
            TT := Tempbit;
            for i := 0 to SourImage.Height-1 do begin
               tempSS := ss;
               for n := 0 to ibp -1 do begin
                  TempSS^ := TT^; inc (TempSS);
               end;
               inc (ss, aBarImage.Width); inc (TT);
            end;
         end;
      1 :
         begin
            TT := Tempbit;
            for i := 0 to SourImage.Height-1 do begin
               tempSS := ss;
               inc (tempss, aBarImage.Width);
               for n := ibp -1 downto 0 do begin
                  dec (TempSS); TempSS^ := TT^;
               end;
               inc (ss, aBarImage.Width); inc (TT);
            end;
         end;
   end;
   FreeMem (Tempbit);
end;

procedure   TPersonBat.MessageProcess (var code: TWordComData);
var
   PTTSShowBattleBar : PTSShowBattleBar;
   PTTSShowCenterMsg : PTSShowCenterMsg;
   pckey : PTCKey;
begin
   pckey := @Code.data;
   case pckey^.rmsg of
      SM_SHOWBATTLEBAR :
         begin
            PTTSShowBattleBar := @Code.data;
            with PTTSShowBattleBar^ do begin
               FWinType := rWinType;
               LeftID := rLeftName;
               LeftWinCount := rLeftWin;
               LeftIDEnergy := rLeftPercent;
               RightID := rRightName;
               RightWinCount := rRightWin;
               RightIDEnergy := rRightPercent;
            end;
            FShowBar := TRUE;
         end;
      SM_SHOWCENTERMSG :
         begin
            PTTSShowCenterMsg := @Code.data;
            A2SetFontColor (PTTSShowCenterMsg.rColor);
            if FShowBatMsg then FMsgStringList.Add (GetwordString(PTTSShowCenterMsg.rText))
            else begin
               BatMsgText := GetwordString(PTTSShowCenterMsg.rText);
               BatMsgDelay := mmAnsTick;
            end;
            FShowBatMsg := TRUE;
         end;
   end;
end;

constructor TPersonBat.Create;
begin
   PersonBatLib := TA2ImageLib.Create;
   PersonBatLib.LoadFromFile ('.\ect\persw.Atz');

   RightBarImg := TA2Image.Create (140,8,0,0);
   LeftBarImg := TA2Image.Create (140,8,0,0);

   RightIDEnergy := 100;
   LeftIDEnergy := 100;
   RightID := '';
   LeftID := '';
   RightWinCount := 0;
   LeftWinCount := 0;
   FShowBar := FALSE;
   FShowBatMsg := FALSE;

//   BatMsgFontColor := 0;
   BatMsgText := '';
   FMsgStringList := TStringList.Create;

   BatMsgDelay := 0;
end;

destructor  TPersonBat.Destroy;
begin
   inherited destroy;
   RightBarImg.Free;
   LeftBarImg.Free;
   PersonBatLib.Free;
   FMsgStringList.Free;
end;

procedure   TPersonBat.SetID (aRightID, aLeftID : string);
begin
   RightID := aRightID;
   LeftID := aLeftID;
end;

procedure   TPersonBat.SetEnergy (aRightIDEnergy, aLeftIDEnergy : integer);
begin
   RightIDEnergy := aRightIDEnergy;
   LeftIDEnergy := aLeftIDEnergy;
end;

const
   EnergybarLeftstartPos = 20;
   EnergybarRightstartPos = 250;

procedure   TPersonBat.Draw;
var
   i, Leftw, Rightw : integer;
begin
   BackScreen.Back.DrawImage (PersonBatLib.Images[4],218,14,TRUE);
   // Left
   LeftBarImg.Clear (0);
   MakeBarImage (LeftBarImg, PersonBatLib.Images[5], LeftIDEnergy,0);
   BackScreen.Back.DrawImage (LeftBarImg,EnergybarLeftstartPos+51,10+14,TRUE);
   BackScreen.Back.DrawImage (PersonBatLib.Images[0],EnergybarLeftstartPos,10,TRUE);
   BackScreen.Back.DrawImage (PersonBatLib.Images[1],EnergybarLeftstartPos + PersonBatLib.Images[0].Width-2-4,23,TRUE);
   //
   Leftw := LeftWinCount;
   for i := 0 to FWinType-1 do begin
      if Leftw <= i then BackScreen.Back.DrawImage (PersonBatLib.Images[6],160+32-(i*16), 35,TRUE)
      else BackScreen.Back.DrawImage (PersonBatLib.Images[7],160+32-(i*16), 35,TRUE);
   end;
   i := ATextWidth (LeftID);
   ATextOut (BackScreen.Back, 212-i, 6, WinRGB(31,31,31), LeftID);

   // Right
   RightBarImg.Clear (0);
   MakeBarImage (RightBarImg, PersonBatLib.Images[5], RightIDEnergy,1);
   BackScreen.Back.DrawImage (RightBarImg,EnergybarRightstartPos,10+14,TRUE);

   BackScreen.Back.DrawImage (PersonBatLib.Images[2],EnergybarRightstartPos,23,TRUE);
   BackScreen.Back.DrawImage (PersonBatLib.Images[3],EnergybarRightstartPos+PersonBatLib.Images[2].Width-2-4,10,TRUE);

   Rightw := RightWinCount;
   for i := 0 to FWinType-1 do begin
      if Rightw <= i then BackScreen.Back.DrawImage (PersonBatLib.Images[6],6+EnergybarRightstartPos+(i*16), 35,TRUE)
      else BackScreen.Back.DrawImage (PersonBatLib.Images[7],6+EnergybarRightstartPos+(i*16), 35,TRUE);
   end;
   ATextOut (BackScreen.Back, EnergybarRightstartPos, 6, WinRGB(31,31,31), RightID);
end;

procedure   TPersonBat.BatMessageDraw (x, y, CurTick: integer);
var
   str, rdstr : String;
   n : integer;
begin // 한글 20자 Total 40자
   if BatMsgDelay + 300 < mmAnsTick then begin
      if FMsgStringList.Count > 0 then begin
         BatMsgText := FMsgStringList[0];
         FMsgStringList.Delete (0);
         BatMsgDelay := CurTick;
      end else FShowBatMsg := FALSE;
   end;
   BackScreen.Back.DrawImageKeyColor (PersonBatLib.Images[8], x, y, 31,@Darkentbl);
   BackScreen.Back.DrawImageKeyColor (PersonBatLib.Images[9], PersonBatLib.Images[8].Width+x-2, y+2, 31,@Darkentbl);
   str := BatMsgText;
   str := GetValidStr3 (str, rdstr,',');
   if str = '' then begin
      n := ATextWidth (rdstr);
      ATextOut (BackScreen.Back,x+(126-(n div 2)),y+26,WinRGB(31,31,31),rdstr);
   end else begin
      ATextOut (BackScreen.Back,x+10,y+10+8,WinRGB(31,31,31),rdstr);
      ATextOut (BackScreen.Back,x+10,y+10+26,WinRGB(31,31,31),str);
   end;
end;

end.

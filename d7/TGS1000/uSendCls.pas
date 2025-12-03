unit uSendCls;

interface

uses
  Windows, SysUtils, Classes, Usersdb, Deftype, AnsUnit,
  AnsImg2, AUtil32, subutil, uConnect;

type

   TSendClass = class
   private
     Name : String; 
     Connector : TConnector;
   public
     constructor Create;
     destructor Destroy; override;

     procedure SetConnector (aConnector : TConnector);
     procedure SetName (aName : String);

     procedure  SendCancelExChange;
     procedure  SendShowExChange (pexleft, pexright: PTExChangedata);
     procedure  SendShowCount (aCountId, aSourKey, aDestKey, aCntMax: integer; acaption: string);

     procedure  SendShowInputString (aInputStringId: integer; aCaptionString: string; aListString: string);
     procedure  SendShiftAttack (abo: Boolean);
     procedure  SendAttribFightBasic (astr: string);
     procedure  SendAttribBase (var AttribData: TAttribData; var CurAttribData: TCurAttribData);
     procedure  SendAttribValues (var AttribData: TAttribData; var CurAttribData: TCurAttribData);
     procedure  SendChangeFeature (var aSenderinfo: TBasicData);
     procedure  SendChangeProperty (var aSenderinfo: TBasicData);
     procedure  SendSay (var aSenderinfo: TBasicData; astr: string);
     procedure  SendSayUseMagic (var aSenderinfo: TBasicData; astr: string);
     procedure  SendEventString (astr: string);
     procedure  SendUsedMagicString (astr: string);
     procedure  SendShootMagic (var aSenderinfo: TBasicData; atid: integer; ax, ay, abowimage, abowspeed : word; atype : Byte);
     procedure  SendTurn (var aSenderinfo: TBasicData);
     procedure  SendMove (var aSenderinfo: TBasicData);
     procedure  SendMotion (aid, amotion: integer);
     procedure  SendStructed (var aSenderInfo : TBasicData; aPercent: integer);
     procedure  SendChatMessage (astr: string; aColor: byte);
     procedure  SendStatusMessage (astr: string);
     procedure  SendShow (var aSenderinfo: TBasicData);
     procedure  SendHide (var aSenderinfo: TBasicData);
     procedure  SendHaveItem (akey: word; var ItemData: TItemData);
     procedure  SendHaveMagic (akey: word; var MagicData: TMagicData);
     procedure  SendBasicMagic (akey: word; var MagicData: TMagicData);
     procedure  SendWearItem (akey: word; var ItemData: TItemData);
     procedure  SendMap (var aSenderInfo: TBasicData; amap, aobj, arof, atil, aSoundBase: string);
     procedure  SendSetPosition (var aSenderinfo: TBasicData);
     procedure  SendSoundEffect (asoundname: string; ax, ay : Word);

     procedure  SendSoundBase (asoundname: string; aRoopCount: integer);
     procedure  SendSoundBase2 (asoundname: string; aRoopCount: integer);

     procedure  SendItemMoveInfo (ainfostr: string);
     procedure  SendRainning (aRain : TSRainning);

     procedure  SendLogItem (akey: word; var ItemData: TItemData);
     procedure  SendShowSpecialWindow (aWindow : Byte; aCaption : String; aComment : String);
     procedure  SendShowGuildMagicWindow (aMagicWindowData : PTSShowGuildMagicWindow);
     procedure  SendNetState (aID, aTick : Integer);
   end;

implementation

uses
   FSockets, svClass;

///////////////////////////////////
//         TSendClass
///////////////////////////////////
procedure  TSendClass.SendShowCount (aCountID, aSourKey, aDestKey, aCntMax: Integer; aCaption: String);
var
   ComData : TWordComData;
   psCount : PTSCount;
begin
   psCount := @ComData.Data;
   with psCount^ do begin
      rMsg := SM_SHOWCOUNT;
      rCountID := aCountID;
      rSourKey := aSourKey;
      rDestKey := aDestKey;
      rCountCur := 0;
      rCountMax := aCntMax;
      SetWordString (rCountName, aCaption);
      ComData.Size := SizeOf(TSCount) - sizeof(TWordString) + sizeofWordstring(rCountName);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendCancelExChange;
var
   ComData : TWordComData;
   pcKey : PTCKey;
begin
   pcKey := @ComData.Data;
   with pcKey^ do begin
      rmsg := SM_HIDEEXCHANGE;
      ComData.Size := SizeOf (TCKey);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendShowExChange (pexleft, pexright: PTExChangedata);
var
   ComData : TWordComData;
   i : integer;
   str : string;
   psExChange : PTSExChange;
begin
   psExChange := @ComData.Data;
   with psExChange^ do begin
      rmsg := SM_SHOWEXCHANGE;
      rCheckLeft := pexleft^.rboCheck;
      rCheckRight := pexright^.rboCheck;

      str := format ('%s,%s,', [pexright^.rExChangeName, pexleft^.rExChangeName]);

      for i := 0 to 4 - 1 do begin
         if pexleft^.rItems[i].rItemCount <> 0 then begin
            rIcons[i] := pexleft^.rItems[i].ricon;
            rColors[i] := pexleft^.rItems[i].rColor;
            str := str + pexleft^.rItems[i].rItemViewName + ':' + InttoStr (pexleft^.rItems[i].rItemCount) + ',';
         end else begin
            rIcons[i] := 0;
            rColors[i] := 0;
            str := str + ',';
         end;
      end;

      for i := 0 to 4-1 do begin
         if pexright^.rItems[i].rItemCount <> 0 then begin
            rIcons[i+4] := pexright^.rItems[i].ricon;
            rColors[i+4] := pexright^.rItems[i].rColor;
            str := str + pexright^.rItems[i].rItemViewName + ':' + InttoStr (pexright^.rItems[i].rItemCount) + ',';
         end else begin
            rIcons[i+4] := 0;
            rColors[i+4] := 0;
            str := str + ',';
         end;
      end;

      SetWordString (rWordString, str);

      ComData.Size := Sizeof(TSExChange) - sizeof(TWordString) + SizeofWordString(rWordString);
   end;
   
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendShowInputString (aInputStringId: integer; aCaptionString: string; aListString: string);
var
   ComData : TWordComData;
   cnt : integer;
   psShowInputString: PTSShowInputString;
begin
   psShowInputString := @ComData.Data;
   with psShowInputString^ do begin
      rmsg := SM_SHOWINPUTSTRING;
      rInputStringid := aInputStringId;
      SetWordString (rWordString, aCaptionString + ',' + aListString);
      ComData.Size := sizeof(TSShowInputString) - sizeof(TWordString) + sizeofwordstring(rWordString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendRainning (aRain : TSRainning);
var
   ComData : TWordComData;
   psRainning : PTSRainning;
begin
   psRainning := @ComData.Data;
   Move (aRain, psRainning^, SizeOf (TSRainning));
   ComData.Size := SizeOf (TSRainning);
   
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendItemMoveInfo (ainfostr: string);
var
   cnt : integer;
   usd : TStringData;
begin
   usd.rmsg := 1;
   SetWordString (usd.rWordString, ainfostr + Connector.IpAddr + ',');
   cnt := sizeof(usd) - sizeof(TWordString) + sizeofwordstring (usd.rwordstring);
   
   FrmSockets.UdpItemMoveInfoAddData (cnt, @usd);
end;

constructor TSendClass.Create;
begin
   Connector := nil;
end;

destructor TSendClass.Destroy;
begin
   inherited destroy;
end;

procedure TSendClass.SetConnector (aConnector : TConnector);
begin
   Connector := aConnector;
end;

procedure TSendClass.SetName (aName : String);
begin
   Name := aName;
end;

procedure  TSendClass.SendShiftAttack (abo: Boolean);
var
   ComData : TWordComData;
   pcKey: PTCKey;
begin
   pcKey := @ComData.Data;
   with pcKey^ do begin
      rmsg := SM_BOSHIFTATTACK;
      if abo then rkey := 0
      else rkey := 1;
      ComData.Size := SizeOf (TCKey);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendAttribFightBasic (astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psAttribFightBasic: PTSAttribFightBasic;
begin
   psAttribFightBasic := @ComData.Data;
   with psAttribFightBasic^ do begin
      rmsg := SM_ATTRIB_FIGHTBASIC;
      SetWordString (rWordString, astr);
      ComData.Size := sizeof(TSAttribFightBasic) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendAttribValues (var AttribData: TAttribData; var CurAttribData: TCurAttribData);
var
   ComData : TWordComData;
   psAttribValues: PTSAttribValues;
begin
   psAttribValues := @ComData.Data;
   with psAttribValues^ do begin
      rmsg := SM_ATTRIB_VALUES;

      rLight := AttribData.cLight;
      rDark := AttribData.cDark;
      rMagic := AttribData.cMagic;

      rTalent := AttribData.cTalent;
      rGoodChar := AttribData.cGoodChar;
      rBadChar := AttribData.cBadChar;
      rLucky := AttribData.cLucky;
      rAdaptive := AttribData.cAdaptive;
      rRevival := AttribData.cRevival;
      rimmunity := AttribData.cimmunity;
      rVirtue := AttribData.cVirtue;

      rhealth := CurAttribData.Curhealth * 10000 div AttribData.cHealth;
      rsatiety := CurAttribData.Cursatiety * 10000 div AttribData.cSatiety;
      rpoisoning := CurAttribData.Curpoisoning * 10000 div AttribData.cPoisoning;

      rHeadSeak := CurAttribData.CurHeadSeak * 10000 div AttribData.cHeadSeak;
      rArmSeak := CurAttribData.CurArmSeak * 10000 div AttribData.cArmSeak;
      rLegSeak := CurAttribData.CurLegSeak * 10000 div AttribData.cLegSeak;
      ComData.Size := SizeOf (TSAttribValues);
   end;

   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendAttribBase (var AttribData: TAttribData; var CurAttribData: TCurAttribData);
var
   ComData : TWordComData;
   psAttribBase : PTSAttribBase;
begin
   psAttribBase := @ComData.Data;
   with psAttribBase^ do begin
      rmsg := SM_ATTRIBBASE;
      rAge := AttribData.cAge;

      rEnergy := AttribData.cEnergy;
      rCurEnergy := CurAttribData.CurEnergy;

      rInPower := AttribData.cInPower;
      rCurInPower := CurAttribData.CurInPower;

      rOutPower := AttribData.cOutPower;
      rCurOutPower := CurAttribData.CurOutPower;

      rMagic := AttribData.cMagic;
      rCurMagic := CurAttribData.CurMagic;

      rLife := AttribData.cLife;
      rCurLife := CurAttribData.CurLife;
      ComData.Size := SizeOf (TSAttribBase);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendChangeFeature (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psChangeFeature : PTSChangeFeature;
   psChangeState : PTSChangeState;
begin
   if isDynamicObjectID (aSenderInfo.id) then begin
      psChangeState := @ComData.Data;
      with psChangeState^ do begin
         rmsg := SM_CHANGESTATE;
         rId := aSenderInfo.id;
         rState := aSenderInfo.Feature.rHitMotion;
         rFrameStart := aSenderInfo.nx;
         rFrameEnd := aSenderInfo.ny;
         ComData.Size := SizeOf (TSChangeFeature);
      end;
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
   end else begin
      psChangeFeature := @ComData.Data;
      with psChangeFeature^ do begin
         rmsg := SM_CHANGEFEATURE;
         rId := aSenderInfo.id;
         rFeature := aSenderInfo.Feature;
         if rFeature.rrace = RACE_NPC then rFeature.rrace := RACE_MONSTER;
         ComData.Size := SizeOf (TSChangeFeature);
      end;
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
   end;
end;

procedure  TSendClass.SendChangeProperty (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psChangeProperty : PTSChangeProperty;
   str : String;
begin
   psChangeProperty := @ComData.Data;
   with psChangeProperty^ do begin
      str := StrPas (@aSenderInfo.ViewName);
      if aSenderInfo.Guild[0] <> 0 then
         str := str + ',' + StrPas (@aSenderInfo.Guild);
      if Length (str) >= 18 then str := Copy (str, 1, 18);

      rmsg := SM_CHANGEPROPERTY;
      rId := aSenderInfo.id;
      StrPCopy(@rNameString, str);
      ComData.Size := SizeOf (TSChangeProperty);
   end;

   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendEventString (astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psEventString : PTSEventString;
begin
   psEventString := @ComData.Data;
   with psEventString^ do begin
      rmsg := SM_EVENTSTRING;
      SetWordString (rWordString, astr);
      ComData.Size := sizeof(TSEventString) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendUsedMagicString (astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psEventString : PTSEventString;
begin
   psEventString := @ComData.Data;
   with psEventString^ do begin
      rmsg := SM_USEDMAGICSTRING;
      SetWordString (rWordString, astr);
      ComData.Size := sizeof(TSEventString) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendShootMagic (var aSenderinfo: TBasicData; atid: integer; ax, ay, abowimage, abowspeed: word; atype : byte);
var
   ComData : TWordComData;
   psMovingMagic: PTSMovingMagic;
begin
   psMovingMagic := @ComData.Data;
   with psMovingMagic^ do begin
      rmsg := SM_MOVINGMAGIC;
      rsid := aSenderInfo.id;
      reid := atid;
      rtx := ax;
      rty := ay;
      rMoveingstyle := 0;
      rsf := 0;
      rmf := abowimage;
      ref := 0;
      rspeed := abowspeed; //rspeed := 20;

      rafterimage := 0;
      rafterover := 0;
      rtype := atype;
      
      ComData.Size := SizeOf (TSMovingMagic);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;


procedure  TSendClass.SendSayUseMagic (var aSenderinfo: TBasicData; astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psSay : PTSSay;
begin
   psSay := @ComData.Data;
   with psSay^ do begin
      rmsg := SM_SAYUSEMAGIC;
      rId  := aSenderInfo.id;
      rkind := 0;
      SetWordString (rWordString, astr);
      ComData.Size := sizeof(TSSay) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendSay (var aSenderinfo: TBasicData; astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psSay : PTSSay;
begin
   psSay := @ComData.Data;
   with psSay^ do begin
      rmsg := SM_SAY;
      rId  := aSenderInfo.id;
      rkind := 0;
      SetWordString (rWordString, astr);
      ComData.Size := sizeof(TSSay) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendTurn (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psTurn : PTSTurn;
begin
   psTurn := @ComData.Data;
   with psTurn^ do begin
      rmsg := SM_TURN;
      rId := aSenderInfo.id;
      rdir := aSenderInfo.dir;
      rx := aSenderInfo.x;
      ry := aSenderInfo.y;
      ComData.Size := SizeOf (TSTurn);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendMove (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psMove : PTSMove;
begin
   psMove := @ComData.Data;
   with psMove^ do begin
      rmsg := SM_MOVE;
      rId := aSenderInfo.id;
      rdir := aSenderInfo.dir;
      rx := aSenderInfo.x;
      ry := aSenderInfo.y;
      ComData.Size := SizeOf (TSMove);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendSetPosition (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psSetPosition : PTSSetPosition;
begin
   psSetPosition := @ComData.Data;
   with psSetPosition^ do begin
      rmsg := SM_SETPOSITION;
      rid := aSenderInfo.id;
      rdir := aSenderInfo.dir;
      rx := aSenderInfo.x;
      ry := aSenderInfo.y;
      ComData.Size := SizeOf (TSSetPosition);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendMap (var aSenderInfo: TBasicData; amap, aobj, arof, atil, aSoundBase: string);
var
   ComData : TWordComData;
   psNewMap : PTSNewMap;
begin
   SendSoundBase ('', 100);

   psNewMap := @ComData.Data;
   FillChar (psNewMap^, SizeOf (TSNewMap), 0);
   with psNewMap^ do begin
      rmsg := SM_NEWMAP;
      StrPCopy (@rMapName, aMap);
      StrCopy (@rCharName, @aSenderInfo.ViewName);
      rId := aSenderInfo.id;
      rx := aSenderInfo.x;
      ry := aSenderInfo.y;
      StrPCopy (@rObjName, aobj);
      StrPCopy (@rRofName, arof);
      StrPCopy (@rTilName, atil);
      ComData.Size := SizeOf (TSNewMap);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));

   if aSoundBase <> '' then begin
      SendSoundBase (aSoundBase + '.wav', 100);
   end;
end;

procedure  TSendClass.SendShow (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   i, cnt : integer;
   psShow : PTSShow;
   psShowItem : PTSShowItem;
   psShowDynamicObject : PTSShowDynamicObject;
   str : shortstring;
   dod : TDynamicObjectData;
begin
   if aSenderInfo.ClassKind = CLASS_SERVEROBJ then exit;
   
   if (aSenderInfo.Feature.rrace = RACE_HUMAN) or (aSenderInfo.Feature.rRace = RACE_MONSTER)
      or (aSenderInfo.Feature.rRace = RACE_NPC) then begin
      psShow := @ComData.Data;
      with psShow^ do begin
         str := StrPas (@aSenderInfo.ViewName);
         if aSenderInfo.Guild[0] <> 0 then
            str := str + ',' + StrPas (@aSenderInfo.Guild);

         rmsg := SM_SHOW;
         rId := aSenderInfo.id;
         StrPCopy (@rNameString, str);
         rdir := aSenderInfo.dir;
         rx := aSenderInfo.x;
         ry := aSenderInfo.y;
         rFeature := aSenderInfo.Feature;
         if rFeature.rrace = RACE_NPC then rFeature.rrace := RACE_MONSTER;
         SetWordString (rWordString, '');

         ComData.Size := sizeof(TSShow)-sizeof(twordstring)+sizeofwordstring(rwordstring);
      end;
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
      exit;
   end;

   if (aSenderInfo.Feature.rRace = RACE_ITEM)
      or (aSenderInfo.Feature.rRace = RACE_STATICITEM) then begin
      psShowItem := @ComData.Data;
      with psShowItem^ do begin
         rmsg := SM_SHOWITEM;
         rid := aSenderInfo.id;
         rNameString := aSenderInfo.ViewName;
         rx := aSenderInfo.x;
         ry := aSenderInfo.y;
         rShape := aSenderInfo.Feature.rImageNumber;
         rColor := aSenderInfo.Feature.rImageColorIndex;
         rRace := aSenderInfo.Feature.rRace;
         ComData.Size := SizeOf (TSShowItem);
      end;
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
      exit;
   end;

   if aSenderInfo.Feature.rrace = RACE_DYNAMICOBJECT then begin
      psShowDynamicObject := @ComData.Data;
      FillChar (psShowDynamicObject^, SizeOf (TSShowDynamicObject), 0);
      
      DynamicObjectClass.GetDynamicObjectData (StrPas (@aSenderInfo.Name), dod);
      with psShowDynamicObject^ do begin
         rmsg := SM_SHOWDYNAMICOBJECT;
         rid := aSenderInfo.id;
         rNameString := aSenderInfo.ViewName;
         rx := aSenderInfo.x;
         ry := aSenderInfo.y;
         rShape := aSenderInfo.Feature.rImageNumber;
         rState := aSenderInfo.Feature.rHitMotion;
         rFrameStart := aSenderInfo.nx;
         rFrameEnd := aSenderInfo.ny;
         ComData.Size := SizeOf (TSShowDynamicObject);
      end;
      for i := 0 to 10 - 1 do begin
         if (dod.rGuardX [i] = 0) and (dod.rGuardY [i] = 0) then break;
         psShowDynamicObject^.rGuardX [i] := dod.rGuardX [i];
         psShowDynamicObject^.rGuardY [i] := dod.rGuardY [i];
      end;
      
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
      exit;
   end;
end;

procedure TSendClass.SendHide (var aSenderinfo: TBasicData);
var
   ComData : TWordComData;
   psHide : PTSHide;
begin
   if aSenderInfo.ClassKind = CLASS_SERVEROBJ then exit;
   
   psHide := @ComData.Data;
   with psHide^ do begin
      rmsg := SM_HIDE;
      if isObjectItemId (aSenderInfo.id) or isStaticItemId (aSenderInfo.id) then rmsg := SM_HIDEITEM;
      if isDynamicObjectID (aSenderInfo.id) then rmsg := SM_HIDEDYNAMICOBJECT;

      rid := aSenderInfo.id;
      ComData.Size := SizeOf (TSHide);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendMotion (aid, amotion: integer);
var
   ComData : TWordComData;
   psMotion : PTSMotion;
begin
   psMotion := @ComData.Data;
   with psMotion^ do begin
      rmsg := SM_MOTION;
      rId := aid;
      rmotion := amotion;
      ComData.Size := SizeOf (TSMotion);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendStructed (var aSenderInfo : TBasicData; aPercent: integer);
var
   ComData : TWordComData;
   psStructed : PTSStructed;
begin
   psStructed := @ComData.Data;
   with psStructed^ do begin
      rmsg := SM_STRUCTED;
      rId := aSenderInfo.ID;
      if aSenderInfo.Feature.rRace <> RACE_DYNAMICOBJECT then begin
         rRace := RACE_HUMAN;
      end else begin
         rRace := aSenderInfo.Feature.rRace;
      end;
      rpercent := apercent;
      ComData.Size := SizeOf (TSStructed);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;


procedure TSendClass.SendChatMessage (astr: string; aColor: byte);
var
   ComData : TWordComData;
   cnt : integer;
   psChatMessage : PTSChatMessage;
begin
   psChatMessage := @ComData.Data;
   with psChatMessage^ do begin
      rmsg := SM_CHATMESSAGE;
      case acolor of
         SAY_COLOR_NORMAL : begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,0); end;
         SAY_COLOR_SHOUT  : begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,24); end;
         SAY_COLOR_SYSTEM : begin rFColor := WinRGB (22,22, 0); rBColor := WinRGB (0, 0 ,0); end;
         SAY_COLOR_NOTICE : begin rFColor := WinRGB (255 div 8, 255 div 8, 255 div 8); rBColor := WinRGB (133 div 8, 133 div 8, 133 div 8); end;

         SAY_COLOR_GRADE0 : begin rFColor := WinRGB (18, 16, 14); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE1 : begin rFColor := WinRGB (26, 23, 21); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE2 : begin rFColor := WinRGB (31, 29, 27); rBColor := WinRGB (2,4,5); end;
         SAY_COLOR_GRADE3 : begin rFColor := WinRGB (22, 18,  8); rBColor := WinRGB (1,4,11); end;
         SAY_COLOR_GRADE4 : begin rFColor := WinRGB (23, 13,  4); rBColor := WinRGB (1,4,11); end;
         SAY_COLOR_GRADE5 : begin rFColor := WinRGB (31, 29, 21); rBColor := WinRGB (1,4,11); end;

         else begin rFColor := WinRGB (22,22,22); rBColor := WinRGB (0, 0 ,0); end;
      end;

      SetWordString (rWordstring, aStr);
      ComData.Size := Sizeof(TSChatMessage) - Sizeof(TWordString) + sizeofwordstring(rWordString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendStatusMessage (astr: string);
var
   ComData : TWordComData;
   cnt : integer;
   psMessage : PTSMessage;
begin
   psMessage := @ComData.Data;
   with psMessage^ do begin
      rmsg := SM_MESSAGE;
      rkey := MESSAGE_GAMEING;
      SetWordString (rWordstring, astr);
      ComData.Size := Sizeof(TSMessage) - Sizeof(TWordString) + sizeofwordstring(rWordString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendHaveItem (akey: word; var ItemData: TItemData);
var
   ComData : TWordComData;
   psHaveItem : PTSHaveItem;
begin
   psHaveItem := @ComData.Data;
   with psHaveItem^ do begin
      rmsg := SM_HAVEITEM;
      rkey := akey;
      rName := ItemData.rViewName;
      rCount := ItemData.rCount;
      rColor := Itemdata.rcolor;
      rShape := Itemdata.rShape;
      ComData.Size := SizeOf (TSHaveItem);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendWearItem (akey: word; var ItemData: TItemData);
var
   ComData : TWordComData;
   psWearItem : PTSHaveItem;
begin
   psWearItem := @ComData.Data;
   with psWearItem^ do begin
      rmsg := SM_WEARITEM;
      rkey := akey;
      rName := Itemdata.rViewName;
      rColor := Itemdata.rcolor;
      rShape := Itemdata.rShape;
      ComData.Size := SizeOf (TSHaveItem);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));

   if aKey = 1 then begin
      with psWearItem^ do begin
         rmsg := SM_WEARITEM;
         rkey := 5;
         rName := Itemdata.rViewName;
         rColor := Itemdata.rcolor;
         rShape := Itemdata.rShape;
         ComData.Size := SizeOf (TSHaveItem);
      end;
      Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
   end;
end;

procedure TSendClass.SendHaveMagic (akey: word; var MagicData: TMagicData);
var
   ComData : TWordComData;
   psHaveMagic : PTSHaveMagic;
begin
   psHaveMagic := @ComData.Data;
   with psHaveMagic^ do begin
      rmsg := SM_HAVEMAGIC;
      rkey := akey;
      rShape := MagicData.rShape;
      rName := MagicData.rname;
      rSkillLevel := MagicData.rcSkillLevel;
      rpercent := 0;
      ComData.Size := SizeOf (TSHaveMagic);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendBasicMagic (akey: word; var MagicData: TMagicData);
var
   ComData : TWordComData;
   psHaveMagic : PTSHaveMagic;
begin
   psHaveMagic := @ComData.Data;
   with psHaveMagic^ do begin
      rmsg := SM_BASICMAGIC;
      rkey := akey;
      rShape := Magicdata.rShape;
      rName := MagicData.rname;
      rSkillLevel := Magicdata.rcSkillLevel;
      rpercent := 0;
      ComData.Size := SizeOf (TSHaveMagic);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendSoundEffect (asoundname: string; ax, ay : Word);
var
   ComData : TWordComData;
   psSoundString: PTSSoundString;
begin
   psSoundString := @ComData.Data;
   with psSoundString^ do begin
      rmsg := SM_SOUNDEFFECT;
      rHiByte := Length (asoundname);
      rLoByte := 0;
      StrPCopy (@rSoundName, asoundname);
      rX := ax;
      rY := ay;
      ComData.Size := SizeOf (TSSoundString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendSoundBase (asoundname: string; aRoopCount: integer);
var
   ComData : TWordComData;
   cnt : integer;
   psSoundBaseString: PTSSoundBaseString;
begin
   psSoundBaseString := @ComData.Data;
   with psSoundBaseString^ do begin
      rmsg := SM_SOUNDBASESTRING;
      rRoopCount := aroopcount;
      SetWordString (rWordString, asoundname);
      ComData.Size := Sizeof(TSSoundBaseString) - Sizeof(TWordString) + sizeofwordstring(rWordString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendSoundBase2 (asoundname: string; aRoopCount: integer);
var
   ComData : TWordComData;
   cnt : integer;
   psSoundBaseString: PTSSoundBaseString;
begin
   psSoundBaseString := @ComData.Data;
   with psSoundBaseString^ do begin
      rmsg := SM_SOUNDBASESTRING2;
      rRoopCount := aroopcount;
      SetWordString (rWordString, aSoundName);
      ComData.Size := Sizeof(TSSoundBaseString) - Sizeof(TWordString) + sizeofwordstring(rWordString);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendShowSpecialWindow (aWindow : Byte; aCaption : String; aComment : String);
var
   ComData : TWordComData;
   pSShowSpecialWindow : PTSShowSpecialWindow;
begin
   psShowSpecialWindow := @ComData.Data;

   with psShowSpecialWindow^ do begin
      rmsg := SM_SHOWSPECIALWINDOW;
      rWindow := aWindow;
      StrPCopy (@rCaption, aCaption);
      SetWordString (rWordString, aComment);
      ComData.Size := sizeof(TSShowSpecialWindow) - sizeof(TWordString) + sizeofwordstring(rwordstring);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure TSendClass.SendLogItem (akey: word; var ItemData: TItemData);
var
   ComData : TWordComData;
   psLogItem : PTSLogItem;
begin
   psLogItem := @ComData.Data;
   with psLogItem^ do begin
      rmsg := SM_LOGITEM;
      rkey := aKey;
      rName := ItemData.rViewName;
      rCount := ItemData.rCount;
      rColor := Itemdata.rcolor;
      rShape := Itemdata.rShape;
      ComData.Size := SizeOf (TSLogItem);
   end;
   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendShowGuildMagicWindow (aMagicWindowData : PTSShowGuildMagicWindow);
var
   ComData : TWordComData;
begin
   ComData.Size := SizeOf (TSShowGuildMagicWindow);
   Move (aMagicWindowData^, ComData.Data, SizeOf (TSShowGuildMagicWindow));

   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

procedure  TSendClass.SendNetState (aID, aTick : Integer);
var
   ComData : TWordComData;
   pSNetState : PTSNetState;
begin
   ComData.Size := SizeOf (TSNetState);
   
   pSNetState := @ComData.Data;
   pSNetState^.rMsg := SM_NETSTATE;
   pSNetState^.rID := aID;
   pSNetState^.rMadeTick := aTick;

   Connector.AddSendData (@ComData, ComData.Size + SizeOf (Word));
end;

end.

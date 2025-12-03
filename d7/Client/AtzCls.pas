unit AtzCls;

interface

uses
  Windows, SysUtils, Classes, A2Img, deftype, clType, StrDb, uAnsTick, AUtil32;

const
   UnUsedFreeTickDelay = 30000;
   UnUsedFreeTickAtzLibDelay = 20000;

   FreeCountMAXSIZE = 3;

type

  TAtzClass = Class
  private
    UnUsedFreeTick : integer;
    Directory : string;
    DataStringList : TStringList;
    ItemImageLib : TA2ImageLib;
    MagicImageLib : TA2ImageLib;

    FreeCountMAXCount : integer;
    FreeCount : integer;
    BufferFileList : TStringList;
    procedure   Initialize (aDirectory: string);
    procedure   Finalize;
  public
    constructor Create (aDirectory: string);
    destructor  Destroy; override;

    procedure   LoadFormBufferFile(aFileName : string);
    procedure   SaveToBufferFile(aFileName : string);

    procedure   UpDate (CurTick: integer);
    procedure   SetDontFreeLib (aLibNames: string);
    function    GetImageLib (afName: string; CurTick: integer): TA2ImageLib;
    function    GetItemImage (idx: integer): TA2Image;
    function    GetMagicImage (idx: integer): TA2Image;
  end;


   TAnimater = class
    private
      AniStringList : TStringList;
      procedure LoadFromFile (aFileName: string; List : TList);
    public
      constructor Create;
      destructor Destroy; override;
      function GetAnimationList (aindex: integer): TList;
   end;


   TEffectPositionData = record
      rArr : array [0..16-1 +2] of integer; // +2 는 overValue, Speed
   end;
   PTEffectPositionData = ^TEffectPositionData;

   TEffectPositionClass = class
    private
      StringList : TStringList;
      procedure Clear;
    public
      constructor Create;
      destructor Destroy; override;
      procedure LoadFromFile (aFileName: string);
      function GetPosition (aFileName: string): TEffectPositionData;
   end;

   TEtcAtzClass = class
    private
      munetcAtzLib : TA2ImageLib;
    public
      constructor Create;
      destructor Destroy; override;
      function GetEtcAtz (value : integer): TA2Image;
   end;

var
   AtzClass : TAtzClass;
   Animater : TAnimater;
   EffectPositionClass : TEffectPositionClass;
   EtcAtzClass : TEtcAtzClass;

implementation

var
  SearchRec: TSearchRec;

constructor TEffectPositionClass.Create;
begin
   StringList := TStringList.Create;
   LoadFromFile ('.\AtzPosXY.sdb');
end;

destructor TEffectPositionClass.Destroy;
begin
   Clear;
   StringList.Free;
   inherited Destroy;
end;

procedure TEffectPositionClass.Clear;
var
   i: integer;
   p : PTEffectPositionData;
begin
   for i := 0 to StringList.Count -1 do begin
      p := PTEffectPositionData (StringList.Objects[i]);
      dispose (p);
   end;
   StringList.Clear;
end;

procedure TEffectPositionClass.LoadFromFile (aFileName: string);
var
   i, j :integer;
   iname : string;
   StringDb : TStringDb;
   p : PTEffectPositionData;
begin
   if not FileExists (aFileName) then exit;

   StringDb := TStringDb.Create;
   StringDb.LoadFromFile (aFileName);

   for j := 0 to StringDb.Count -1 do begin
      iname := StringDb.GetIndexName(j);
      new (p);
      P^.rArr[0] := StringDb.GetFieldValueInteger (iname, 'OverValue');
      P^.rArr[1] := StringDb.GetFieldValueInteger (iname, 'Speed');
      for i := 0 to 8-1 do begin
         p^.rArr[i*2 +2] := StringDb.GetFieldValueInteger (iname, 'Dir'+IntToStr (i) + 'X'); // overvalue, Speed 때문에 +2
         p^.rArr[i*2+1 +2] := StringDb.GetFieldValueInteger (iname, 'Dir'+IntToStr (i) + 'Y');
      end;
      StringList.AddObject (iname, TObject (p));
   end;
   StringDb.Free;
end;

function  TEffectPositionClass.GetPosition (aFileName: string): TEffectPositionData;
var i:integer;
begin
   FillChar (Result, sizeof(Result), 0);
   for i := 0 to StringList.Count -1 do begin
      if StringList[i] = aFilename then begin
         Result := PTEffectPositionData (StringList.Objects[i])^;
         exit;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//                         TAtzClass                                          //
////////////////////////////////////////////////////////////////////////////////

constructor TAtzClass.Create (aDirectory: string);
begin
   UnUsedFreeTick := mmAnsTick;
   Directory := aDirectory;
   DataStringList := TStringList.Create;
   ItemImageLib := TA2ImageLib.Create;
   ItemImageLib.LoadFromFile ('item.atz');
   MagicImageLib := TA2ImageLib.Create;
   MagicImageLib.LoadFromFile ('magic.atz');
   BufferFileList := TStringList.Create;
   FreeCount := 0;
   FreeCountMAXCount := FreeCountMAXSIZE;
   Initialize (Directory);  // 폴더에 '\' 포함된파라미터
end;

destructor  TAtzClass.Destroy;
var
   i : integer;
   Lib : TA2ImageLib;
begin
   for i := DataStringList.Count - 1  downto 0 do begin
      Lib := TA2ImageLib(DataStringList.Objects[i]);
      if mmAnsTick > Lib.Tag + UnUsedFreeTickAtzLibDelay then begin
         Lib.Free;
         DataStringList.Delete (i);
      end;
   end;
   SaveToBufferFile(Directory + 'Atz.b');
   BufferFileList.Free;
   MagicImageLib.Free;
   ItemImageLib.Free;
   Finalize;
   DataStringList.Free;
   inherited Destroy;
end;

function    TAtzClass.GetItemImage (idx:integer): TA2Image;
begin
   Result := nil;
   if (idx < 0) or (idx >= ItemImageLib.Count) then exit;
   Result := ItemImageLib[idx];
end;

function    TAtzClass.GetMagicImage (idx:integer): TA2Image;
begin
   Result := nil;
   if (idx < 0) or (idx >= MagicImageLib.Count) then exit;
   Result := MagicImageLib[idx];
end;

function    TAtzClass.GetImageLib (afName: string; CurTick : integer): TA2ImageLib;
var
   i : integer;
   ImageLib : TA2ImageLib;
begin
   Result := nil;
   for i := 0 to DataStringList.Count -1 do begin //먼저 DataStringList에서 serch
      if afname = DataStringList[i] then begin
         TA2ImageLib (DataStringList.Objects[i]).Tag := CurTick;
         Result := TA2ImageLib (DataStringList.Objects[i]);
         exit;
      end;
   end;

   if FileExists (Directory + afname) then begin //없으면 File Load
      Imagelib := TA2ImageLib.Create;
      ImageLib.LoadFromFile (Directory + afname);
      DataStringList.AddObject (afname, TObject(ImageLib));
      ImageLib.Tag := CurTick;
      Result := ImageLib;
   end;
end;

procedure   TAtzClass.SetDontFreeLib (aLibNames: string); //
var
   i : integer;
   str, rdstr : string;
   ImageLib : TA2ImageLib;
begin
   str := aLibNames;

   for i := 0 to DataStringList.Count -1 do begin
      ImageLib := TA2ImageLib (DataStringList.Objects[i]);
      if ImageLib.Tag = 2 then ImageLib.Tag := 1;
   end;

   while TRUE do begin
      str := GetValidStr3 (str, rdstr, ',');
      if rdstr = '' then break;
      for i := 0 to DataStringList.Count -1 do begin
         if rdstr = DataStringList[i] then TA2ImageLib (DataStringList.Objects[i]).Tag := 2;
      end;
   end;
end;

procedure   TAtzClass.Initialize (aDirectory: string);  // 폴더에 '\' 포함된파라미터
var
   n, i : integer;
   str : string;
   ImageLib : TA2ImageLib;
   memStatus : TMemoryStatus;
begin
//   exit;
   memStatus.dwLength := SizeOf(memStatus) ;
   Directory := aDirectory;

   if FileExists(Directory + 'Atz.b') then begin
      LoadFormBufferFile(Directory + 'Atz.b');
      for i := 0 to BufferFileList.Count -1 do begin
         GlobalMemoryStatus(memStatus);
         if memStatus.dwAvailPhys < 15000000 then break; // 15M 이하면 load안함
         str := LowerCase(BufferFileList[i]);
         Imagelib := TA2ImageLib.Create;
         ImageLib.LoadFromFile (Directory + str);
         DataStringList.AddObject (str, TObject(ImageLib));
      end;
   end else begin
      n := FindFirst(Directory + '*.atz', faAnyFile, SearchRec);
      if n = 0 then begin
         str := LowerCase(SearchRec.Name);
         Imagelib := TA2ImageLib.Create;
         ImageLib.LoadFromFile (Directory + str);
         DataStringList.AddObject (str, TObject(ImageLib));
      end;

      while TRUE do begin
         n := FindNext(SearchRec);
         GlobalMemoryStatus(memStatus);
         if memStatus.dwAvailPhys < 15000000 then break; // 15M 이하면 load안함
         if n = 0 then begin
            str := LowerCase(SearchRec.Name);
            if Pos ('z',str) <> 1 then begin
               Imagelib := TA2ImageLib.Create;
               ImageLib.LoadFromFile (Directory + str);
               DataStringList.AddObject (str, TObject(ImageLib));
            end;
         end else break;
      end;
   end;
end;

procedure   TAtzClass.Finalize;
var
   i : integer;
   Lib : TA2ImageLib;
begin
   for i := 0 to DataStringList.Count -1 do begin
      Lib := TA2ImageLib(DataStringList.Objects[i]);
      Lib.Free;
   end;
   DataStringList.Clear;
end;

procedure   TAtzClass.LoadFormBufferFile(aFileName : string);
begin
   BufferFileList.LoadFromFile (Directory + 'Atz.b');
end;

procedure   TAtzClass.SaveToBufferFile(aFileName : string);
var
   StringList : TStringList;
   i : integer;
begin
   StringList := TStringList.Create;
   for i := 0 to DataStringList.Count -1 do begin
      StringList.Add (DataStringList[i]);
   end;
   StringList.SaveToFile (Directory + 'Atz.b');
   StringList.Free;
end;

procedure   TAtzClass.UpDate (CurTick: integer);
var
   i : integer;
   Lib : TA2ImageLib;
begin
   if CurTick > UnUsedFreeTick + UnUsedFreeTickDelay then begin
      UnUsedFreeTick := CurTick;
      for i := DataStringList.Count - 1 downto 0 do begin
         Lib := TA2ImageLib(DataStringList.Objects[i]);
         if CurTick > Lib.Tag + UnUsedFreeTickAtzLibDelay then begin
            Lib.Free;
            DataStringList.Delete (i);
            inc (FreeCount);
            if FreeCount > FreeCountMAXCount then begin
               FreeCount := 0;
               exit;
            end;
         end;
      end;
   end;
end;


/////////////////////////////////
//          TAnimater          //
/////////////////////////////////

constructor TAnimater.Create;
var
   i : integer;
   List : TList;
   fname : string;
begin
   AniStringList := TStringList.Create;

   for i := 0 to 50 do begin
      fname := IntToStr (i) + '.atd';
      if FileExists (fname) = FALSE then continue; // ankudo 010213 파일중간것을 고의로 삭제시 나머지것두 로드못함
      List := TList.Create;
      LoadFromFile ( fname, List);
      AniStringList.AddObject (fname, TObject(List));
   end;
   {
   for i := 0 to 100 do begin
      fname := IntToStr (i) + '.atd';
      if FileExists (fname) = FALSE then break;
      List := TList.Create;
      LoadFromFile ( fname, List);
      AniStringList.AddObject (fname, TObject(List));
   end;
   }
end;

destructor TAnimater.Destroy;
var
   i, j : Integer;
   List : TList;
begin
   for j := 0 to AniStringList.Count -1 do begin
      List := TList (AniStringList.Objects[j]);
      for i := 0 to List.Count -1 do dispose (List[i]);
      List.Free;
   end;
   AniStringList.Free;
   inherited Destroy;
end;

function TAnimater.GetAnimationList (aindex: integer): TList;
var
   i : integer;
   fname : string;
begin
   fname := IntToStr (aindex) + '.atd';
   for i := 0 to AniStringList.Count -1 do begin
      if fname = AniStringList[i] then begin
         Result := TList (AnistringList.Objects [i]);
         exit;
      end;
   end;
   Result := TList (AnistringList.Objects [0]);
end;

procedure TAnimater.LoadFromFile (aFileName: string; List : TList);
var
   i, j: integer;
   str : string;
   C : char;
   StringDb : TStringDb;
   pa : PTAniInfo;
begin
   StringDb := TStringDb.Create;
   StringDb.LoadFromFileCode (aFileName);

   for j := 1 to 1000 do begin
      str := StringDb.GetFieldValueString (IntToStr(j), 'Name');
      if str = '' then break;
      new (pa);
      with pa^ do begin
         str := StringDb.GetFieldValueString (IntToStr(j), 'Action');
         Action := -1;
         if CompareText (str, 'TURN') = 0 then Action := AM_TURN;
         if CompareText (str, 'TURN1') = 0 then Action := AM_TURN1;
         if CompareText (str, 'TURN2') = 0 then Action := AM_TURN2;
         if CompareText (str, 'TURN3') = 0 then Action := AM_TURN3;
         if CompareText (str, 'TURN4') = 0 then Action := AM_TURN4;

         if CompareText (str, 'TURNNING') = 0 then Action := AM_TURNNING;
         if CompareText (str, 'TURNNING1') = 0 then Action := AM_TURNNING1;
         if CompareText (str, 'TURNNING2') = 0 then Action := AM_TURNNING2;
         if CompareText (str, 'TURNNING3') = 0 then Action := AM_TURNNING3;
         if CompareText (str, 'TURNNING4') = 0 then Action := AM_TURNNING4;

         if CompareText (str, 'MOVE') = 0 then Action := AM_MOVE;
         if CompareText (str, 'MOVE1') = 0 then Action := AM_MOVE1;
         if CompareText (str, 'MOVE2') = 0 then Action := AM_MOVE2;
         if CompareText (str, 'MOVE3') = 0 then Action := AM_MOVE3;
         if CompareText (str, 'MOVE4') = 0 then Action := AM_MOVE4;

         if CompareText (str, 'HIT') = 0  then Action := AM_HIT;
         if CompareText (str, 'HIT1') = 0  then Action := AM_HIT1;
         if CompareText (str, 'HIT2') = 0  then Action := AM_HIT2;
         if CompareText (str, 'HIT3') = 0  then Action := AM_HIT3;
         if CompareText (str, 'HIT4') = 0  then Action := AM_HIT4;
         if CompareText (str, 'HIT5') = 0  then Action := AM_HIT5;
         if CompareText (str, 'HIT6') = 0  then Action := AM_HIT6;
         if CompareText (str, 'DIE') = 0  then Action := AM_DIE;
         if CompareText (str, 'STRUCTED') = 0  then Action := AM_STRUCTED;

         if CompareText (str, 'SEATDOWN') = 0  then Action := AM_SEATDOWN;
         if CompareText (str, 'STANDUP') = 0  then Action := AM_STANDUP;
         if CompareText (str, 'HELLO') = 0  then Action := AM_HELLO;

         if CompareText (str, 'TURN5') = 0 then Action := AM_TURN5;
         if CompareText (str, 'TURN6') = 0 then Action := AM_TURN6;
         if CompareText (str, 'TURN7') = 0 then Action := AM_TURN7;
         if CompareText (str, 'TURN8') = 0 then Action := AM_TURN8;
         if CompareText (str, 'TURN9') = 0 then Action := AM_TURN9;

         if CompareText (str, 'TURNNING5') = 0 then Action := AM_TURNNING5;
         if CompareText (str, 'TURNNING6') = 0 then Action := AM_TURNNING6;
         if CompareText (str, 'TURNNING7') = 0 then Action := AM_TURNNING7;
         if CompareText (str, 'TURNNING8') = 0 then Action := AM_TURNNING8;
         if CompareText (str, 'TURNNING9') = 0 then Action := AM_TURNNING9;

         if CompareText (str, 'MOVE5') = 0 then Action := AM_MOVE5;
         if CompareText (str, 'MOVE6') = 0 then Action := AM_MOVE6;
         if CompareText (str, 'MOVE7') = 0 then Action := AM_MOVE7;
         if CompareText (str, 'MOVE8') = 0 then Action := AM_MOVE8;
         if CompareText (str, 'MOVE9') = 0 then Action := AM_MOVE9;

         if CompareText (str, 'HIT7') = 0  then Action := AM_HIT7;
         if CompareText (str, 'HIT8') = 0  then Action := AM_HIT8;
         if CompareText (str, 'HIT9') = 0  then Action := AM_HIT9;
{ // 추가할것
         if CompareText (str, 'TURN10') = 0 then Action := AM_TURN10;
         if CompareText (str, 'TURN11') = 0 then Action := AM_TURN11;
         if CompareText (str, 'TURN12') = 0 then Action := AM_TURN12;
         if CompareText (str, 'TURN13') = 0 then Action := AM_TURN13;
         if CompareText (str, 'TURN14') = 0 then Action := AM_TURN14;
         if CompareText (str, 'TURN15') = 0 then Action := AM_TURN15;
         if CompareText (str, 'TURN16') = 0 then Action := AM_TURN16;
         if CompareText (str, 'TURN17') = 0 then Action := AM_TURN17;
         if CompareText (str, 'TURN18') = 0 then Action := AM_TURN18;
         if CompareText (str, 'TURN19') = 0 then Action := AM_TURN19;
         if CompareText (str, 'TURNNING10') = 0 then Action := AM_TURNNING10;
         if CompareText (str, 'TURNNING11') = 0 then Action := AM_TURNNING11;
         if CompareText (str, 'TURNNING12') = 0 then Action := AM_TURNNING12;
         if CompareText (str, 'TURNNING13') = 0 then Action := AM_TURNNING13;
         if CompareText (str, 'TURNNING14') = 0 then Action := AM_TURNNING14;
         if CompareText (str, 'TURNNING15') = 0 then Action := AM_TURNNING15;
         if CompareText (str, 'TURNNING16') = 0 then Action := AM_TURNNING16;
         if CompareText (str, 'TURNNING17') = 0 then Action := AM_TURNNING17;
         if CompareText (str, 'TURNNING18') = 0 then Action := AM_TURNNING18;
         if CompareText (str, 'TURNNING19') = 0 then Action := AM_TURNNING19;
         if CompareText (str, 'MOVE10') = 0 then Action := AM_MOVE10;
         if CompareText (str, 'MOVE11') = 0 then Action := AM_MOVE11;
         if CompareText (str, 'MOVE12') = 0 then Action := AM_MOVE12;
         if CompareText (str, 'MOVE13') = 0 then Action := AM_MOVE13;
         if CompareText (str, 'MOVE14') = 0 then Action := AM_MOVE14;
         if CompareText (str, 'MOVE15') = 0 then Action := AM_MOVE15;
         if CompareText (str, 'MOVE16') = 0 then Action := AM_MOVE16;
         if CompareText (str, 'MOVE17') = 0 then Action := AM_MOVE17;
         if CompareText (str, 'MOVE18') = 0 then Action := AM_MOVE18;
         if CompareText (str, 'MOVE19') = 0 then Action := AM_MOVE19;
         if CompareText (str, 'HIT10') = 0  then Action := AM_HIT10;
         if CompareText (str, 'HIT11') = 0  then Action := AM_HIT11;
         if CompareText (str, 'HIT12') = 0  then Action := AM_HIT12;
         if CompareText (str, 'HIT13') = 0  then Action := AM_HIT13;
         if CompareText (str, 'HIT14') = 0  then Action := AM_HIT14;
         if CompareText (str, 'HIT15') = 0  then Action := AM_HIT15;
         if CompareText (str, 'HIT16') = 0  then Action := AM_HIT16;
         if CompareText (str, 'HIT17') = 0  then Action := AM_HIT17;
         if CompareText (str, 'HIT18') = 0  then Action := AM_HIT18;
         if CompareText (str, 'HIT19') = 0  then Action := AM_HIT19;
}

         if Action = -1 then continue;

         str := StringDb.GetFieldValueString (IntToStr(j), 'Direction');
         if CompareText (str, 'DR_0') = 0   then Direction := DR_0;
         if CompareText (str, 'DR_1') = 0   then Direction := DR_1;
         if CompareText (str, 'DR_2') = 0   then Direction := DR_2;
         if CompareText (str, 'DR_3') = 0   then Direction := DR_3;
         if CompareText (str, 'DR_4') = 0   then Direction := DR_4;
         if CompareText (str, 'DR_5') = 0   then Direction := DR_5;
         if CompareText (str, 'DR_6') = 0   then Direction := DR_6;
         if CompareText (str, 'DR_7') = 0   then Direction := DR_7;

         Frame := StringDb.GetFieldValueInteger (IntToStr(j), 'Frame');
         FrameTime := StringDb.GetFieldValueInteger (IntToStr(j), 'FrameTime');
         c := 'A';
         for i := 0 to Frame-1 do begin
            str := format ('%sF', [c]);
            Frames[i] := StringDb.GetFieldValueInteger (IntToStr(j), str);

            str := format ('%spx', [c]);
            Pxs[i] := StringDb.GetFieldValueInteger (IntToStr(j), str);

            str := format ('%spy', [c]);
            Pys[i] := StringDb.GetFieldValueInteger (IntToStr(j), str);

            inc (c);
         end;
      end;
      List.Add (pa);
   end;
   StringDb.Free;
end;


////////////////////////////////////////////////////////////////////////////////
//                        TEtcAtzClass
////////////////////////////////////////////////////////////////////////////////
constructor TEtcAtzClass.Create;
begin
   munetcAtzLib := TA2ImageLib.Create;
   if not FileExists ('.\ect\munetc.Atz') then exit;
   munetcAtzLib.LoadFromFile ('.\ect\munetc.Atz');
end;

destructor  TEtcAtzClass.Destroy;
begin
   munetcAtzLib.Free;
end;

function    TEtcAtzClass.GetEtcAtz (value : integer): TA2Image;
begin
   Result := nil;
   if (value < 0) and (value > munetcAtzLib.Count-1) then exit;
   if munetcAtzLib.Images[value] <> nil then
      Result := munetcAtzLib.Images[value];
end;

end.

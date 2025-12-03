unit USound;

interface

uses Windows, Classes, SysUtils, DXSounds, AUtil32, MMSystem, Wave,
     DefType, uAnsTick, Log;

const
   SOUND_BUFFER = 50;

   COLLECTIONWAVE_ID = 'ATW0';

type
  TCollectionWaveFileHeader = record
     Ident : array [0..4-1] of char;
     Count : integer;
  end;

  TWaveData = record
     WaveName : array [0..32] of byte;
     WaveSize : integer;
     pwave : pbyte;
  end;
  PTWaveData = ^TWaveData;

   TDxWaveData = record
      WC : TWaveCollectionItem;
      SmallFlag : Boolean;
      UsedTick : integer;
   end;
   PTDxWaveData = ^TDxWaveData;

 TSoundManager = class
  private
   WaveStringList : TStringList;
   NewWaveStringList : TStringList;
   FFileName : string;
   FNewFileName : string;
   FDxWaveList : TDxWaveList;
   DataList : TList;
   FVolume : integer;
   FVolume2 : integer;
   FDXSound: TDXSound;
   FBoPlay : Boolean;
   FRoopCount: integer;
   FRoopCount2: integer;

   function  GetDxWaveData (aName: string): PTDxWaveData;
   procedure SetVolume (Value: integer);
   procedure SetVolume2 (Value: integer);
  public

   AudioBase : TAudioFileStream;
   AudioBase2 : TAudioFileStream;
   constructor Create (aDxSound: TDXSound; aFileName, aNewFileName: string; aDxWaveList:TDXWaveList);
   destructor Destroy; override;

   procedure LoadFormSoundList (aFileName : string);

   function  RangeCompute(X : Integer; TagetX :word) : Integer;
   function  RangeVolume(X,Y : Integer; TagetX,TagetY :word; volume : Integer) : Integer;

   procedure UpDate (CurTime: DWORD);
//   procedure PlayEffect (aEffectName: string);
   procedure NewPlayEffect (aEffectName: string; apan : integer; avolume : Integer);
   procedure PlayBaseAudio (aFileName: string; aRoopCount: integer);
   procedure PlayBaseAudio2 (aFileName: string; aRoopCount: integer);

   property  boPlay: Boolean read FBoPlay write FBoPlay;
   property  Volume: integer read FVolume write SetVolume;
   property  Volume2: integer read FVolume2 write SetVolume2;
   property  DxSound : TDXSound read FDxSound write FDXSound;
 end;
var
   boUseSound : Boolean = TRUE;

implementation

uses FMain, forms;

constructor TSoundManager.Create (aDxSound: TDXSound; aFileName, aNewFileName: string; aDxWaveList:TDXWaveList);
var
   i, pos: integer;
   pdwd : PTDxWaveData;
   Stream : TFileStream;
   Header : TCollectionWaveFileHeader;
   wd : TWaveData;
   buf: array [0..64] of char;
begin
   FBoPlay := TRUE;
   FDXSound := aDxSound;
   AudioBase := nil;
   AudioBase2 := nil;
   FVolume := -1000;
   FVolume2 := -1000;

   FRoopCount := 0;
   FRoopCount2 := 0;

   FFileName := aFileName;
   FNewFileName := aNewFileName;
   FDxWaveList := aDxWaveList;
   DataList := TList.Create;
   WaveStringList := TStringList.Create;
   NewWaveStringList := TStringList.Create;

   if FileExists (aFileName) then begin
      pos := 0;
      try
         Stream := TFileStream.Create (aFileName, fmOpenRead);
         Stream.ReadBuffer (Header, sizeof(TCollectionWaveFileHeader));
         pos := pos + sizeof(TCollectionWaveFileHeader);
         if StrLIComp(PChar(COLLECTIONWAVE_ID), Header.Ident, 4) <> 0 then
            raise Exception.Create('Not a valid Wave Library File');

         for i := 0 to Header.Count - 1 do begin
            Stream.ReadBuffer(wd, SizeOf(TWaveData));

            if wd.WaveSize > 5*1000*1000 then begin
               StrPcopy (buf, 'Stream Read BigSize:' + IntToStr(wd.WaveSize));
               Application.MessageBox (buf, 'USound', 0);
               break;
            end;

            pos := pos + SizeOf(TWaveData);
            Stream.Seek (wd.WaveSize, soFromCurrent);
            WaveStringList.AddObject (StrPas (@wd.WaveName), TObject(pos));
            pos := pos + wd.WaveSize;
         end;
         Stream.Free;
      except
         raise exception.Create ('Audio ERROR');
      end;
   end;

   if FileExists (aNewFileName) then begin
      pos := 0;
      try
         Stream := TFileStream.Create (aNewFileName, fmOpenRead);
         Stream.ReadBuffer (Header, sizeof(TCollectionWaveFileHeader));
         pos := pos + sizeof(TCollectionWaveFileHeader);
         if StrLIComp(PChar(COLLECTIONWAVE_ID), Header.Ident, 4) <> 0 then
            raise Exception.Create('Not a valid Wave Library File');

         for i := 0 to Header.Count - 1 do begin
            Stream.ReadBuffer(wd, SizeOf(TWaveData));

            if wd.WaveSize > 5*1000*1000 then begin
               StrPcopy (buf, 'Stream Read BigSize:' + IntToStr(wd.WaveSize));
               Application.MessageBox (buf, 'USound', 0);
               break;
            end;

            pos := pos + SizeOf(TWaveData);
            Stream.Seek (wd.WaveSize, soFromCurrent);
            NewWaveStringList.AddObject (StrPas (@wd.WaveName), TObject(pos));
            pos := pos + wd.WaveSize;
         end;
         Stream.Free;
      except
         raise exception.Create ('Audio ERROR');
      end;
   end;

   for i := 0 to SOUND_BUFFER -1 do begin
      aDxWaveList.Items.Add;
      aDxWaveList.Items[i].Name := '';

      new (pdwd);
      pdwd^.WC := aDxWaveList.Items[i];
      pdwd^.UsedTick := mmAnsTick;
      DataList.Add(pdwd);
   end;
end;

destructor TSoundManager.Destroy;
var i: integer;
begin
   if Audiobase <> nil then begin
      AudioBase.Stop;
      AudioBase.Free;
      Audiobase := nil;
   end;

   if Audiobase2 <> nil then begin
      AudioBase2.Stop;
      AudioBase2.Free;
      Audiobase2 := nil;
   end;

   for i := 0 to DataList.Count -1 do dispose (DataList[i]);
   DataList.Free;
   inherited Destroy;
end;

procedure TSoundManager.LoadFormSoundList (aFileName : string);
begin
end;

procedure TSoundManager.SetVolume (Value: integer);
begin
   FVolume := Value;
   if AudioBase <> nil then AudioBase.Volume := Value;
end;

procedure TSoundManager.SetVolume2 (Value: integer);
begin
   FVolume2 := Value;
   if AudioBase2 <> nil then AudioBase2.Volume := Value;
end;

procedure TSoundManager.PlayBaseAudio (aFileName: string; aRoopCount: integer);
var
   curname : string;
   WaveFormat: TWaveFormatEx;
begin
   sleep (200);
   if DXSound = nil then exit;
   if DXSound.DSound = nil then exit;

   curname := format ('.\wav\%s', [aFileName]);

   if (AudioBase <> nil) and (AudioBase.FileName = curname) then begin
      FRoopCount := aRoopCount;
      exit;
   end;

   if Audiobase <> nil then begin
      try
         AudioBase.Stop;
         AudioBase.Free;
         Audiobase := nil;
      except
         boUseSound := FALSE;
         exit;
      end;
   end;

   if FileExists (curname) = FALSE then exit;
   FRoopCount := aRoopCount;
   try
      try
         AudioBase := TAudioFileStream.Create(DXSound.DSound);
      except
         raise exception.Create ('Audio ERROR');
      end;
      AudioBase.FileName := curname;
      AudioBase.Looped := FALSE;
      AudioBase.Volume := FVolume;

      //  Setting of format of primary buffer.
      MakePCMWaveFormatEx(WaveFormat, 44100, AudioBase.Format.wBitsPerSample, 2);
      DXSound.Primary.SetFormat(WaveFormat);
      if FboPlay then begin
         AudioBase.Play;
         AudioBase.Volume := FVolume;
      end;
   except
      boUseSound := FALSE;
   end;
end;

procedure TSoundManager.PlayBaseAudio2 (aFileName: string; aRoopCount: integer);
var
   curname : string;
   WaveFormat: TWaveFormatEx;
begin
   exit;
   if DXSound = nil then exit;
   if DXSound.DSound = nil then exit;

   curname := format ('.\wav\%s', [aFileName]);
//   LogObj.WriteLog(3, 'PlayBaseAudio2 ' + curname);

   if (AudioBase2 <> nil) and (AudioBase2.FileName = curname) then begin
      FRoopCount2 := aRoopCount;
      exit;
   end;

   if Audiobase2 <> nil then begin
      AudioBase2.Stop;
      AudioBase2.Free;
      Audiobase2 := nil;
   end;

   if FileExists (curname) = FALSE then exit;
   FRoopCount2 := aRoopCount;

   try
   AudioBase2 := TAudioFileStream.Create(DXSound.DSound);
   except
      raise exception.Create ('Audio ERROR');
   end;
   AudioBase2.FileName := curname;
   AudioBase2.Looped := FALSE;
   AudioBase2.Volume := FVolume2;

   //  Setting of format of primary buffer.
   MakePCMWaveFormatEx(WaveFormat, 44100, AudioBase2.Format.wBitsPerSample, 2);
   DXSound.Primary.SetFormat(WaveFormat);
   if FboPlay then begin
      AudioBase2.Play;
      AudioBase2.Volume := FVolume2;
   end;
//   LogObj.WriteLog(3, 'PlayBaseAudio2 Volume = ' + IntToStr(FVolume));
end;

function  TSoundManager.GetDxWaveData (aName: string): PTDxWaveData;
var i: integer;
begin
   for i := 0 to DataList.Count -1 do begin
      if PTDxWaveData (DataList[i])^.WC.Name = aName then begin
         Result := DataList[i];
         exit;
      end;
   end;
   Result := nil;
end;
function TSoundManager.RangeCompute(X : Integer; TagetX :Word) : Integer;
begin
   if TagetX < X then begin
      Result := -(ABS(TagetX - X)*500);
   end else begin
      Result := (ABS(TagetX - X)*500);
   end;
end;

function TSoundManager.RangeVolume(X,Y : Integer; TagetX,TagetY :word; volume : Integer) : Integer;
begin
   Result := -((ABS(TagetX - X)*400) + (ABS(TagetY - Y)*400)) + volume;
end;

{
procedure TSoundManager.PlayEffect (aEffectName: string);
var
   i, mintick, minidx, pos: integer;
   pdwd : PTDxWaveData;
   Stream : TFileStream;
begin
   pdwd := GetDxWaveData (aEffectName);
   if pdwd <> nil then begin
      pdwd^.UsedTick := mmAnsTick;
      pdwd^.WC.Play (FALSE);
      exit;
   end;

   pdwd := DataList[0];
   mintick := pdwd^.UsedTick;
   minidx := 0;

   for i := 0 to DataList.Count -1 do begin
      pdwd := DataList[i];
      if pdwd^.UsedTick < mintick then begin
         mintick := pdwd^.UsedTick;
         minidx := i;
      end;
   end;

   if FileExists ('.\wav\'+aEffectName) then begin
      pdwd := DataList[minidx];
      pdwd^.WC.Name := aEffectName;
      pdwd^.UsedTick := mmAnsTick;
      pdwd^.WC.Wave.LoadFromFile ('.\wav\'+aEffectName);
      pdwd^.WC.Play (FALSE);
   end else begin
      for i := 0 to WaveStringList.Count -1 do begin
         if WaveStringList[i] = aEffectName then begin
            Pos := integer (WaveStringList.Objects [i]);

            Stream := TFileStream.Create (FFileName, fmOpenRead);
            Stream.Seek (pos, soFromBeginning);

            pdwd := DataList[minidx];
            pdwd^.WC.Name := aEffectName;
            pdwd^.UsedTick := mmAnsTick;
            try
               pdwd^.WC.Wave.LoadFromstream (Stream);
               Stream.Free;
               pdwd^.WC.Play (FALSE);
            except
//               LogObj.WriteLog (5, format ('Exception : %s,%d',[pdwd^.WC.Name,pos]));
               exit;
            end;
         end;
      end;

   end;
end;
}
procedure TSoundManager.NewPlayEffect (aEffectName: string; apan : integer; avolume : Integer);
var
   i, mintick, minidx, pos: integer;
   pdwd : PTDxWaveData;
   Stream : TFileStream;
begin
   pdwd := GetDxWaveData (aEffectName);
   if pdwd <> nil then begin
      pdwd^.UsedTick := mmAnsTick;
      pdwd^.WC.Pan := apan;
      pdwd^.WC.Volume := avolume;
      pdwd^.WC.Play (FALSE);
      exit;
   end;

   pdwd := DataList[0];
   mintick := pdwd^.UsedTick;
   minidx := 0;

   for i := 0 to DataList.Count -1 do begin
      pdwd := DataList[i];
      if pdwd^.UsedTick < mintick then begin
         mintick := pdwd^.UsedTick;
         minidx := i;
      end;
   end;

   if FileExists ('.\wav\'+aEffectName) then begin
      try
         pdwd := DataList[minidx];
         pdwd^.WC.Name := aEffectName;
         pdwd^.UsedTick := mmAnsTick;
         pdwd^.WC.Wave.LoadFromFile ('.\wav\'+aEffectName);
         if pdwd^.WC.Initialized then pdwd^.WC.Restore;
         pdwd^.WC.Pan := apan;
         pdwd^.WC.Volume := avolume;
         pdwd^.WC.Play (FALSE);
      except
         pdwd^.WC.Name := '';
         exit;
      end;
   end else begin
      for i := 0 to NewWaveStringList.Count -1 do begin
         if NewWaveStringList[i] = aEffectName then begin
            Pos := integer (NewWaveStringList.Objects [i]);
            try
               Stream := TFileStream.Create (FNewFileName, fmOpenRead);
               Stream.Seek (pos, soFromBeginning);
               pdwd := DataList[minidx];
               pdwd^.WC.Name := aEffectName;
               pdwd^.UsedTick := mmAnsTick;
               pdwd^.WC.Wave.LoadFromstream (Stream);
               if pdwd^.WC.Initialized then pdwd^.WC.Restore;
               pdwd^.WC.Pan := apan;
               pdwd^.WC.Volume := avolume;
               pdwd^.WC.Play (FALSE);
               Stream.Free;
               exit;
            except
               pdwd^.WC.Name := '';
               exit;
            end;
         end;
      end;
   end;
end;



procedure TSoundManager.UpDate (CurTime: DWORD);
begin
   if FRoopCount >= 0 then begin
      if (AudioBase <> nil) and (AudioBase.Playing = FALSE) then begin
         dec (FRoopCount);
         AudioBase.Position := 0;
         AudioBase.Play;
      end;
   end;

   if FRoopCount2 >= 0 then begin
      if (AudioBase2 <> nil) and (AudioBase2.Playing = FALSE) then begin
         dec (FRoopCount2);
         AudioBase2.Position := 0;
         AudioBase2.Play;
      end;
   end;
end;

end.


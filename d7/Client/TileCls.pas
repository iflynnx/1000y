unit TileCls;

interface

uses Windows, SysUtils, Classes, BmpUtil, A2Img, Autil32, Dialogs;

const
   TileLibId = 'ATZTIL2';

   TileHeaderFileID = 'TILHDF';

   TILE_MAX_COUNT = 4096 +1024;
   CELL_MAX_COUNT = 64;

   TILETYPE_RANDOM    = 0;
   TILETYPE_ANIMATION = 1;
   TILETYPE_OVER      = 2;

   UsedCheckTickDelay = 30000;
   UsedCheckDataTickDelay = 20000;

   FreeCountMAXSIZE = 5;
type
  TFileTileHeader = record
   Ident : array [0..7] of char;
   NTile : Integer;
   FilePos : array [0..1024-1] of integer;
  end;

  TTileData = record
   TileId : integer;
   Style : byte;
   nWCell, nHCell: Integer;
   nBlock : integer;
   TileWidth, TileHeight: Integer;
   MBuffer : array [0..CELL_MAX_COUNT-1] of byte;
   AniDelay : DWORD;
   None : array [0..4-1] of integer;
   Bits : PTAns2Color;
  end;
  PTTileData = ^TTileData;

  TTileDataList = class
  private
   SaveBits : PTAns2Color;
   DataList : TList;
   TempTileAnsImage : TA2Image;
   FFileName : string ;
   UsedCheckTick : integer;

   DataPosArr : array [0..TILE_MAX_COUNT-1] of integer;
   UsedTickBuffer : array [0..TILE_MAX_COUNT-1] of integer;

   FreeCount : integer;
   function  GetCount: integer;
   function  GetTileData (Index: Integer): PTTileData;
   procedure ReFreshDataPos;
  public
   constructor Create;
   destructor Destroy; override;

 	procedure LoadFromHeaderFile(aFileName: String);
 	procedure LoadFromFile(aFileName: String);

  	procedure SaveToFile(aFileName: String);

   function  GetTileImage (index, pos, CurTick:integer):TA2Image;
   function  Add (pTileData: PTTileData): Boolean;
   procedure Delete (Index: Integer);
   procedure Clear;
   procedure UsedTickUpdate (CurTick: integer);


   property  Items [Index:Integer] : PTTileData read GetTileData ; default;
   property  Count : integer read GetCount;
 end;

var
   TileDataList : TTileDataList;

implementation

constructor TTileDataList.Create;
begin
   FFileName := '';
   DataList := TList.Create;
   TempTileAnsImage := TA2Image.Create (32, 24, 0, 0);
   SaveBits := TempTileAnsImage.Bits;
   Clear;
   Fillchar (UsedTickBuffer, sizeof(UsedTickBuffer), 0);
   UsedCheckTick := 0;
   FreeCount := 0;
end;

destructor TTileDataList.Destroy;
begin
   Clear;
   DataList.Free;
   TempTileAnsImage.Bits := SaveBits;
   TempTileansImage.Width := 32;
   TempTileansImage.Height := 24;
   TempTileAnsImage.Free;
   inherited Destroy;
end;

procedure ResizeTile ( sour, dest: PTAns2Color; ow, oh, nw, nh:integer; var px , py:integer);
var
   spb, dpb : PTAns2Color;
   i, j, x, y: integer;
begin
   FillChar (dest^, nw*nh*Sizeof(TAns2Color), 0);

   for j := 0 to nh - 1 do begin
      for i := 0 to nw -1 do begin
         x := i * ow div nw;
         y := j * oh div nh;
         spb := sour;
         inc (spb, x + y * ow);
         dpb := dest;
         inc (dpb, i + j * nw);
         dpb^ := spb^;
      end;
   end;
   px := px * nw div ow;
   py := py * nh div oh;
end;

procedure   TTileDataList.ReFreshDataPos;
var
   i : integer;
   pt : PTTileData;
begin
   FillChar (DataPosArr, sizeof(DataPosArr), $ff);
   for i := 0 to DataList.Count -1 do begin
      pt := DataList[i];
      DataPosArr[pt^.TileId] := i;
   end;
end;

procedure TTileDataList.Clear;
var
   i: Integer;
   pTileData : PTTileData;
begin
   for i := 0 to DataList.Count -1 do begin
      pTileData := Datalist[i];
      if pTileData^.Bits <> nil then FreeMem (pTileData^.Bits);
      Dispose (pTileData);
   end;
   DataList.Clear;
   ReFreshDataPos;
end;

procedure TTileDataList.UsedTickUpdate (CurTick: integer);
var
   i: Integer;
   pTileData : PTTileData;
begin
   if FFileName = '' then exit;
   if CurTick > UsedCheckTick + UsedCheckTickdelay then begin
      UsedCheckTick := CurTick;
      for i := FreeCount to FreeCount + FreeCountMAXSIZE -1 do begin
         if CurTick > UsedTickBuffer[i] + UsedCheckDataTickDelay then begin
            if DataList.Count -1 < i then begin
               FreeCount := 0;
               break;
            end;
            pTileData := Datalist[i];
            if pTileData = nil then continue;
            if pTileData^.Bits <> nil then FreeMem (pTileData^.Bits);
            pTileData^.Bits := nil;
            UsedTickBuffer[i] := CurTick;
         end;
      end;
      inc (FreeCount, FreeCountMAXSIZE);
      if FreeCount+FreeCountMAXSIZE > DataList.Count -1 then FreeCount := 0;
   end;
end;

function  TTileDataList.GetTileImage (index, pos, CurTick:integer):TA2Image;
var
   fh : integer;
   pTileData : PTTileData;
   pw : PTAns2Color;
begin
   Result := TempTileAnsImage;
   if DataPosArr[index] = -1 then begin
      TempTileAnsImage.Bits := SaveBits;
      TempTileansImage.Clear (0);
      exit;
   end;
   pTiledata := DataList[DataPosArr[index]];
   if Pos > (pTileData.nWCell * pTileData.nHCell * pTileData.nBlock) then begin
      TempTileAnsImage.Bits := SaveBits;
      TempTileansImage.Clear (0);
      exit;
   end;

   if pTileData^.Bits = nil then begin
      fh := 0;
      try
         fh := FileOpen (FFileName, fmOpenRead);
         FileSeek (fh, pTileData^.AniDelay, sofrombeginning);
         with pTileData^ do begin
            GetMem (Bits, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
            FileRead (fh, Bits^, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
         end;
         Fileclose (fh);
      except
         if pTileData^.Bits <> nil then FreeMem (pTileData^.Bits);
         if fh <> 0 then FileClose (fh);
         pTileData^.Bits := nil;
         TempTileAnsImage.Bits := SaveBits;
         TempTileansImage.Clear (0);
         exit;
      end;
   end;

   pw := pTileData^.bits;
   if pw <> nil then begin
      UsedTickBuffer [index] := CurTick;
      inc (pw, pTileData^.tileWidth*pTileData^.TileHeight*pos);
      TempTileAnsImage.Bits := pw;
   end else begin
      TempTileAnsImage.Bits := SaveBits;
      TempTileansImage.Clear (0);
      exit;
   end;
end;

function  TTileDataList.GetCount: integer;
begin
   Result := TILE_MAX_COUNT;
end;

function  TTileDataList.GetTileData (Index: Integer): PTTileData;
var dp : integer;
begin
   Result := nil;
   if (index > TILE_MAX_COUNT -1) or (index < 0) then exit;
   dp := DataPosArr[Index];
   if ( dp < DataList.Count) and (dp > -1) then Result := DataList[dp];
end;

function DataListSort ( Item1, Item2: Pointer): integer;
begin
   Result := PTTileData(Item1).TileId - PTTileData(Item2).TileId;
end;

function TTileDataList.Add (pTileData: PTTileData): Boolean;
var
   i : Integer;
   pod : PTTileData;
begin
   Result := FALSE;
   if pTileData = nil then exit;
   for i := 0 to DataList.Count -1 do begin
      pod := DataList[i];
      if (pod^.TileId = pTileData^.TileId) then exit;
   end;
   DataList.Add (pTileData);
   DataList.Sort ( DataListSort);

   ReFreshDataPos;

   Result := TRUE;
end;

procedure TTileDataList.Delete (Index: Integer);
var
   dp : integer;
begin
   if (index > TILE_MAX_COUNT -1) or (index < 0) then exit;
   dp := DataPosArr[index];
   if (dp < DataList.Count) and (dp > -1) then begin
      if PTTileData ( DataList[dp])^.Bits <> nil then FreeMem (PTTileData ( DataList[dp])^.Bits);
      dispose (DataList[dp]);
      DataList.Delete (dp);

      ReFreshDataPos;
   end;
end;

procedure TTileDataList.LoadFromFile(aFileName: String);
var
   i, pos : Integer;
   Stream : TFileStream;
   FileTileHeader : TFileTileHeader;
   pTileData : PTTileData;
   HeaderFile, str,rdstr : string;
begin
   if FileExists (aFileName) = FALSE then exit;
   if FFileName = aFileName then exit;
   FFileName := aFileName;

   str := ExtractFileName(aFileName);
   str := GetValidstr3 (str, rdstr, '.');
   HeaderFile := ExtractFilePath(aFileName) + rdstr + '.hdf';
   if FileExists (HeaderFile) then begin
      LoadFromHeaderFile (HeaderFile);
      exit;
   end;
   pos := 0;
   Clear;

   Stream := nil;
   try
      Stream := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileTileHeader,sizeof(FileTileHeader)); inc (pos, sizeof(FileTileHeader));

      if StrLIComp(PChar(TileLibId), FileTileHeader.Ident, 8) <> 0 then
         raise Exception.Create('Not a valid Tile Library File');

      for i := 0 to FileTileHeader.NTile -1 do begin
         new (pTileData);
         Stream.ReadBuffer ( pTileData^, sizeof(TTileData));
         inc (pos, sizeof(TTileData));

         pTileData^.Bits := nil;
         pTileData^.AniDelay := pos;

         with pTileData^ do begin
            Stream.Seek ((TileWidth*TileHeight*2) * nWCell * nHCell * nBlock, sofromcurrent);
            inc (pos, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
         end;

//         with pTileData^ do GetMem (Bits, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
//         with pTileData^ do Stream.ReadBuffer ( Bits^, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
         DataList.Add ( pTileData);
      end;
      ReFreshDataPos;
   except
      Clear;
   end;
   if Stream <> nil then Stream.Free;
end;

procedure TTileDataList.SaveToFile(aFileName: String);
var
   i : Integer;
   Stream : TFileStream;
   FileTileHeader : TFileTileHeader;
   pTileData : PTTileData;
begin
   Stream := nil;
   try
      Stream  := TFileStream.Create(aFileName, fmCreate);
      FileTileHeader.Ident := TileLibId;
      FileTileHeader.NTile := DataList.Count;

      Stream.WriteBuffer (FileTileHeader,sizeof(FileTileHeader));
      for i := 0 to DataList.Count -1 do begin
         pTileData := DataList[i];
         Stream.WriteBuffer ( pTileData^, sizeof(TTileData));
         with pTileData^ do
            Stream.WriteBuffer ( Bits^, (TileWidth*TileHeight*2) * nWCell * nHCell * nBlock);
      end;
   except
   end;
   if Stream <> nil then Stream.Free;
end;

procedure TTileDataList.LoadFromHeaderFile(aFileName: String);
var
   i : Integer;
   Stream : TFileStream;
   FileTileHeader : TFileTileHeader;
   pTileData : PTTileData;
begin
   if FileExists (aFileName) = FALSE then exit;
   Clear;
   Stream := nil;
   try
      Stream := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileTileHeader,sizeof(FileTileHeader));

      if StrLIComp(PChar(TileHeaderFileID), FileTileHeader.Ident, 8) <> 0 then
         raise Exception.Create('Not a valid Tile Library File');

      for i := 0 to FileTileHeader.NTile -1 do begin
         new (pTileData);
         Stream.ReadBuffer ( pTileData^, sizeof(TTileData));
         pTileData^.Bits := nil;
         DataList.Add ( pTileData);
      end;
      ReFreshDataPos;
   except
      Clear;
   end;
   if Stream <> nil then Stream.Free;
end;

end.

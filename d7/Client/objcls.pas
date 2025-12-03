unit ObjCls;

interface

uses Windows, SysUtils, Classes, BmpUtil, A2Img, AUtil32;

const
   ID1 = 'ATZOBJ1'+#0;
   ID2 = 'ATZOBJ2'+#0;
   ID3 = 'ATZOBJ3'+#0;
   ObjectLibId = 'ATZOBJ3'+#0;


   HeaderFileID = 'OBJH3';
   OBJECT_CELL_MAX = 16*16;
   OBJECT_MAX_COUNT = 4096+1024;

   UsedCheckTickDelay = 40000;
   UsedCheckDataTickDelay = 20000;

   FreeCountMAXSIZE = 5;
type
  TObjType = (TOB_none, TOB_follow, TOB_dummy);

  TFileObjectHeader = record
   Ident : array [0..7] of char;
   NObject : Integer;
  end;

  TObjectData = record // ID3
   ObjectAniId : Integer;      // 애니메이션 Object 구분자
   ObjectId : integer;         // Object Data Index
   Style : TObjType;           // TOB_none: 일반object TOB_follow: aniObject;
   MWidth, MHeight: Integer;   // 1 블럭에 대한 Cell갯수
   nBlock : Integer;           // 블럭 갯수
   StartID : integer;          // ani 시작 ObjectID
   endID : integer;            // ani 끝 ObjectID
   IWidth, IHeight: Integer;   // 가로세로길이
   Ipx, Ipy: Integer;
   MBuffer : array [0..OBJECT_CELL_MAX-1] of byte; // move Control buffer 16*16
   AniDelay : integer;
   DataPos : DWord;
   None : array [0..4-1] of integer;
   Bits : PTAns2Color;
  end;
  PTObjectData = ^TObjectData;

  TObjectData2 = record // ID2
   ObjectId : integer;
   MWidth, MHeight: Integer;
   IWidth, IHeight: Integer;
   Ipx, Ipy: Integer;
   MBuffer : array [0..OBJECT_CELL_MAX-1] of byte;
   AniDelay : DWORD;
   None : array [0..4-1] of integer;
   Bits : PTAns2Color;
  end;
  PTObjectData2 = ^TObjectData2;

  TObjectDataList = class
  private
   SaveBits : PTAns2Color;
   TempObjectAnsImage : TA2Image;
   DataList : TList;
   DataPosArr : array [0..OBJECT_MAX_COUNT-1] of integer;
   UsedTickBuffer : array [0..OBJECT_MAX_COUNT-1] of integer;
   FFileName : string;
   UsedCheckTick : integer;

   FreeCount : integer;

   function  GetCount: integer;
   function  GetObjectData (index: Integer): PTObjectData;
   procedure ReFreshDataPos;
  public
   constructor Create;
   destructor Destroy; override;

   function   LoadFromFileATZOBJ3 (aFileName: String): integer;
   function   LoadFromFileATZOBJ2 (aFileName: String): integer;

 	procedure  LoadFromFile(aFileName: String);
 	procedure  LoadFromHeaderFile(aFileName: String);

  	procedure  SaveToFile(aFileName: String);

   function   GetObjectImage (index, pos, CurTick:integer):TA2Image;

   function   Add (pObjectData: PTObjectData): Boolean;
   procedure  Delete (index: Integer);
   procedure  Clear;
   procedure  UsedTickUpdate (CurTick: integer);


   property   Items [Index:Integer] : PTObjectData read GetObjectData ; default;
   property   Count : integer read GetCount;
 end;

var
   ObjectDataList : TObjectDataList;
   RoofDataList : TObjectDataList;

implementation

constructor TObjectDataList.Create;
begin
   DataList := TList.Create;
   TempObjectAnsImage := TA2Image.Create (32, 24, 0, 0);
   SaveBits := TempObjectAnsImage.Bits;
   FFileName := '';
   Clear;
   UsedCheckTick := 0;
   FreeCount := 0;
   Fillchar (UsedTickBuffer, sizeof(UsedTickBuffer), 0);
end;

destructor TObjectDataList.Destroy;
begin
   Clear;
   DataList.Free;
   TempObjectAnsImage.Bits := SaveBits;
   TempObjectAnsImage.Width := 32;
   TempObjectAnsImage.Height := 24;
   TempObjectAnsImage.Free;
   inherited Destroy;
end;

procedure TObjectDataList.Clear;
var
   i : Integer;
   pObjectData : PTObjectData;
begin
   FillChar (DataPosArr, sizeof(DataPosArr), $FF);
   for i := 0 to DataList.Count -1 do begin
      pObjectData := Datalist[i];
      if pObjectData^.Bits <> nil then FreeMem (pObjectData^.Bits);
      Dispose (pObjectData);
   end;
   DataList.Clear;
end;

procedure  TObjectDataList.ReFreshDataPos;
var
   i : integer;
   po : PTObjectData;
begin
   FillChar (DataPosArr, sizeof(DataPosArr), $ff);
   for i := 0 to DataList.Count -1 do begin
      po := DataList[i];
      DataPosArr[po^.ObjectId] := i;
   end;
end;

procedure TObjectDataList.UsedTickUpdate (CurTick: integer);
var
   i: Integer;
   pObjectData : PTObjectData;
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
            pObjectData := Datalist[i];
            if pObjectData = nil then continue;
            if pObjectData^.Bits <> nil then FreeMem (pObjectData^.Bits);
            pObjectData^.Bits := nil;
            UsedTickBuffer[i] := CurTick;
         end;
      end;
      inc (FreeCount, FreeCountMAXSIZE);
      if FreeCount+FreeCountMAXSIZE > DataList.Count -1 then FreeCount := 0;
   end;
end;

function  TObjectDataList.GetObjectImage (index, pos, CurTick:integer):TA2Image;
var
   pObjectData : PTObjectData;
   pw : PTAns2Color;
   fh : integer;
begin
   Result := TempObjectAnsImage;
   if DataPosArr[index] = -1 then begin
      TempObjectAnsImage.Width := 32;
      TempObjectAnsImage.Height := 24;
      TempObjectAnsImage.Bits := SaveBits;
      TempObjectansImage.Clear (0);
      exit;
   end;
   pObjectdata := DataList[DataPosArr[index]];
   fh := 0;
   if pObjectData^.Bits = nil then begin
      try
         fh := FileOpen (FFileName, fmOpenRead);
         FileSeek (fh, pObjectData^.Datapos, sofrombeginning);
         with pObjectData^ do begin
            GetMem (Bits, (IWidth*IHeight*nBlock*2));
            FileRead (fh, Bits^, (IWidth*IHeight*nBlock*2));
         end;
         FileClose (fh);
      except
         if pObjectData^.Bits <> nil then freeMem (pObjectData^.Bits);
         pObjectData^.Bits := nil;
         if fh <> 0 then FileClose (fh);
         TempObjectAnsImage.Width := 32;
         TempObjectAnsImage.Height := 24;
         TempObjectAnsImage.Bits := SaveBits;
         TempObjectansImage.Clear (0);
         exit;
      end;
   end;

   pw := pObjectData^.bits;
   inc (pw, pObjectData^.IWidth*pObjectData^.IHeight*pos);
   TempObjectAnsImage.Bits := pw;
   TempObjectAnsImage.Width := pObjectdata^.IWidth;
   TempObjectAnsImage.Height := pObjectdata^.IHeight;
   TempObjectAnsImage.px := pObjectdata^.IPx;
   TempObjectAnsImage.py := pObjectdata^.IPY;
   UsedTickBuffer[index] := CurTick;
end;

function  TObjectDataList.GetCount: integer;
begin
   Result := OBJECT_MAX_COUNT;
end;

function  TObjectDataList.GetObjectData (Index: Integer): PTObjectData;
var dp : integer;
begin
   dp := DataPosArr[Index];
   if ( dp < DataList.Count) and (dp > -1) then Result := DataList[dp]
   else Result := nil;
end;

function DataListSort ( Item1, Item2: Pointer): integer;
begin
   Result := PTObjectData(Item1).ObjectId - PTObjectData(Item2).ObjectId;
end;

function TObjectDataList.Add (pObjectData: PTObjectData): Boolean;
var
   i : Integer;
   pod : PTObjectData;
begin
   Result := FALSE;
   for i := 0 to DataList.Count -1 do begin
      pod := DataList[i];
      if pod^.ObjectId = pObjectData^.ObjectId then exit;
   end;
   DataList.Add (pObjectData);
   DataList.Sort ( DataListSort);

   ReFreshDataPos;

   Result := TRUE;
end;

procedure TObjectDataList.Delete (Index: Integer);
var dp : integer;
begin
   dp := DataPosArr[index];
   if (dp < DataList.Count) and (dp > -1) then begin
      if PTObjectData ( DataList[dp])^.Bits <> nil then FreeMem (PTObjectData ( DataList[dp])^.Bits);
      dispose (DataList[dp]);
      DataList.Delete (dp);

      ReFreshDataPos;
   end;
end;

function   TObjectDataList.LoadFromFileATZOBJ3 (aFileName: String): integer;
var
   i, pos : Integer;
   Stream : TFileStream;
   FileObjectHeader : TFileObjectHeader;
   pObjectData : PTObjectData;
   HeaderFile, str, rdstr : string;
begin
   Result := -1;
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
      Stream  := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileObjectHeader,sizeof(FileObjectHeader));
      inc (pos, sizeof (FileObjectHeader));

      if StrLIComp(PChar(ObjectLibId), FileObjectHeader.Ident, 8) <> 0 then
        raise Exception.Create('Not a valid Object Library File');

      for i := 0 to FileObjectHeader.NObject -1 do begin
         new (pObjectData);

         Stream.ReadBuffer ( pObjectData^, sizeof(TObjectData));
         inc (pos, sizeof (TObjectData));
         pObjectData^.Bits := nil;
         pObjectData^.DataPos := Pos;
         Stream.Seek ((pObjectData^.IWidth*pObjectData^.IHeight*pObjectData^.nBlock*2), sofromcurrent);
         inc (pos, (pObjectData^.IWidth*pObjectData^.IHeight*pObjectData^.nBlock*2));
         DataList.Add ( pObjectData);
      end;
      ReFreshDataPos;
      Stream.Free;
   except
      if Stream <> nil then Stream.Free;
      Clear;
      exit;
   end;
   Result := 0;
end;

function   TObjectDataList.LoadFromFileATZOBJ2 (aFileName: String): integer;
var
   i, n : Integer;
   Stream : TFileStream;
   FileObjectHeader : TFileObjectHeader;
   pObjectData2 : PTObjectData2;
   pObjectData : PTObjectData;
   pos : integer;
begin
   Result := -1;

   if FileExists (aFileName) = FALSE then exit;
   if FFileName = aFileName then exit;
   FFileName := aFileName;
   pos := 0;
   Stream := nil;
   Clear;
   try
      Stream  := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileObjectHeader,sizeof(FileObjectHeader));
      inc (pos, sizeof (FileObjectHeader));

      if StrLIComp(PChar(ID2), FileObjectHeader.Ident, 8) <> 0 then
        raise Exception.Create('Not a valid Object Library File');

      for i := 0 to FileObjectHeader.NObject -1 do begin
         new (pObjectData2);
         Stream.ReadBuffer (pObjectData2^, sizeof(TObjectData2));
         inc (pos, sizeof (TObjectData2));

         new (pObjectData);
         with pObjectData^ do begin
            ObjectAniId := 0;
            ObjectId := pObjectData2^.ObjectId;
            Style := TObjType(0);
            MWidth := pObjectData2^.MWidth;
            MHeight := pObjectData2^.MHeight;
            nBlock := 1;
            StartID := -1;
            endID := 0;
            IWidth := pObjectData2^.IWidth;
            IHeight := pObjectData2^.IHeight;
            Ipx := pObjectData2^.Ipx;
            Ipy := pObjectData2^.Ipy;
            for n := 0 to OBJECT_CELL_MAX -1 do begin
               MBuffer[n] := pObjectData2^.MBuffer[n];
            end;
            AniDelay := integer(pObjectData2^.AniDelay);
            DataPos := pos;
            for n := 0 to 4-1 do begin
               None[n] := pObjectData2^.None[n];
            end;
            Bits := nil;
         end;
         DataList.Add (pObjectData);

         if pObjectData2 <> nil then FreeMem (pObjectData2);
         Stream.Seek ((pObjectData2^.IWidth*pObjectData2^.IHeight*2), sofromcurrent);
         inc (pos, (pObjectData2^.IWidth*pObjectData2^.IHeight*2));
      end;
      ReFreshDataPos;
      Stream.Free;
   except
      if Stream <> nil then Stream.Free;
      Clear;
      exit;
   end;
   Result := 0;
end;

procedure TObjectDataList.LoadFromFile(aFileName: String);
var
   Stream : TFileStream;
   FileObjectHeader : TFileObjectHeader;
begin
   if FileExists (aFileName) = FALSE then exit;
   Stream := nil;
   try
      Stream  := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileObjectHeader,sizeof(FileObjectHeader));
      Stream.Free;
   except
      if Stream <> nil then Stream.Free;
      FillChar (FileObjectHeader, sizeof(FileObjectHeader),0);
      exit;
   end;

   if StrLIComp(PChar(ID2), FileObjectHeader.Ident, 8) <> 0 then
   else LoadFromFileATZOBJ2 (aFileName);

   if StrLIComp(PChar(ID3), FileObjectHeader.Ident, 8) <> 0 then
   else LoadFromFileATZOBJ3 (aFileName);
end;

procedure TObjectDataList.LoadFromHeaderFile(aFileName: String);
var
   i : Integer;
   Stream : TFileStream;
   FileObjectHeader : TFileObjectHeader;
   pObjectData : PTObjectData;
begin
   if FileExists (aFileName) = FALSE then exit;
   Clear;
   Stream := nil;
   try
      Stream  := TFileStream.Create(aFileName, fmOpenRead);
      Stream.ReadBuffer (FileObjectHeader,sizeof(FileObjectHeader));

      if StrLIComp(PChar(HeaderFileID), FileObjectHeader.Ident, 8) <> 0 then
        raise Exception.Create('Not a valid Object Library File');

      for i := 0 to FileObjectHeader.NObject -1 do begin
         new (pObjectData);

         Stream.ReadBuffer ( pObjectData^, sizeof(TObjectData));
         pObjectData^.Bits := nil;
         DataList.Add ( pObjectData);
      end;
      ReFreshDataPos;
      Stream.Free;
   except
      if Stream <> nil then Stream.Free;
      Clear;
      exit;
   end;
end;

procedure TObjectDataList.SaveToFile(aFileName: String);
var
   i : Integer;
   Stream : TFileStream;
   FileObjectHeader : TFileObjectHeader;
   pObjectData : PTObjectData;
begin
   Stream  := TFileStream.Create(aFileName, fmCreate);
   FileObjectHeader.Ident := ObjectLibId;
   FileObjectHeader.NObject := DataList.Count;

   Stream.WriteBuffer (FileObjectHeader,sizeof(FileObjectHeader));
   for i := 0 to DataList.Count -1 do begin
      pObjectData := DataList[i];
      Stream.WriteBuffer ( pObjectData^, sizeof(TObjectData));

      with pObjectData^ do
         Stream.WriteBuffer ( Bits^, (IWidth*IHeight*2));
   end;
   Stream.Free;
end;

end.

unit uCryptStringList;

interface

uses
   classes, uCrypt, Sysutils;

const
   FileCryptID1 = 'CPTS1'+#0;
   bufferSize = 256;

type
   TFileCryptStringListHeader = record
      Ident : array [0..7] of char;
      Count : Integer;
   end;
   PTFileCryptStringListHeader = ^TFileCryptStringListHeader;

   TFileCryptItem = record
      Size : integer;
      Data : PChar;
   end;
   PTFileCryptItem = ^TFileCryptItem;

   TCryptStringList = class
      private
         EnStringList : TStringList;
         DeStringList : TStringList;
      public
         constructor Create;
         destructor  Destroy; override;
         procedure   Clear;

         function    AddEnStringList (aStringList: TStringList): Boolean;
         function    GetDeStringList (aStringList: TStringList): Boolean;

         function    LoadFromCryptFile (aFileName: string): boolean;
         procedure   SaveToCryptFile (aFileName: string);
   end;

implementation

constructor TCryptStringList.Create;
begin
   EnStringList := TStringList.Create;
   DeStringList := TStringList.Create;
end;
destructor  TCryptStringList.Destroy;
begin
   inherited Destroy;
   EnStringList.Free;
   DeStringList.Free;
end;

procedure   TCryptStringList.Clear;
begin
   EnStringList.Clear;
   DeStringList.Clear;
end;

function    TCryptStringList.AddEnStringList (aStringList: TStringList): Boolean;
var
   sbuffer, dbuffer, tbuffer : array [0..bufferSize] of char;
   str, rdstr : string;
   i, n, m: integer;
begin
   Result := FALSE;
   if aStringList.Count = 0 then exit;

   DeStringList.Clear;
   for i := 0 to aStringList.Count -1 do begin
      n := Length (aStringList[i]);
      m := n div 4;
      if n mod 4 <> 0 then begin
         n := (m + 1) * 4;
      end else n := m * 4;

      Fillchar (sbuffer, sizeof(sbuffer), 0);
      Fillchar (dbuffer, sizeof(dbuffer), 0);
      Fillchar (tbuffer, sizeof(tbuffer), 0);
      StrPCopy (@sbuffer, aStringList[i]);
      n := EnCryption (@sbuffer, @dbuffer, n);
      str := dbuffer;
      Fillchar (dbuffer, sizeof(dbuffer), 0);
      StrPCopy (@dbuffer, str);
      DeCryption (@dbuffer, @tbuffer, n);
      rdstr := tbuffer;
      if rdstr <> aStringList[i] then begin
         DeStringList.Clear;
         Result := FALSE;
         exit;
      end;
      DeStringList.Add (str);
   end;
   Result := TRUE;
end;

function    TCryptStringList.GetDeStringList (aStringList: TStringList): Boolean;
var
   i : integer;
   sbuffer, dbuffer : array [0..bufferSize] of char;
   str : string;
begin
   Result := FALSE;
   if DeStringList.Count = 0 then exit;

   EnStringList.Clear;
   for i := 0 to DeStringList.Count -1 do begin
      if DeStringList[i] = '' then begin
         EnStringList.Add ('');
         continue;
      end;
      Fillchar (dbuffer, sizeof(dbuffer), 0);
      Fillchar (sbuffer, sizeof(sbuffer), 0);
      StrPCopy (@sbuffer, DeStringList[i]);
      DeCryption (@sbuffer, @dbuffer, Length(DeStringList[i]));
      str := dbuffer;
      EnStringList.Add (str);
   end;
   aStringList.Assign (EnStringList);
   Result := TRUE;
end;

function    TCryptStringList.LoadFromCryptFile (aFileName: string): boolean;
var
   FileCryptStringListHeader : TFileCryptStringListHeader;
   Stream : TFileStream;
   i : integer;
   FileCryptItem : TFileCryptItem;
   buffer : array [0..bufferSize] of char;
   str : string;
begin
   Result := FALSE;
   if not FileExists (aFileName) then exit;

   DeStringList.Clear;
   Stream := nil;
   try
      Stream := TFileStream.Create (aFileName, fmOpenRead);
      fillchar (FileCryptStringListHeader, sizeof(FileCryptStringListHeader), 0);
      Stream.ReadBuffer (FileCryptStringListHeader, sizeof(FileCryptStringListHeader));
      for i := 0 to FileCryptStringListHeader.Count -1 do begin
         Fillchar (FileCryptItem, sizeof (TFileCryptItem), 0);
         Stream.ReadBuffer (FileCryptItem, sizeof(TFileCryptItem));
         Fillchar (buffer, sizeof(buffer), 0);
         Stream.ReadBuffer (buffer, FileCryptItem.Size);
         str := buffer;
         DeStringList.Add (str);
      end;
   except
      if Stream <> nil then Stream.Free;
      exit;
   end;
   if Stream <> nil then Stream.Free;
   Result := TRUE;
end;

procedure   TCryptStringList.SaveToCryptFile (aFileName: string);
var
   FileCryptStringListHeader : TFileCryptStringListHeader;
   Stream : TFileStream;
   i : integer;
   FileCryptItem : TFileCryptItem;
   buffer : array [0..bufferSize] of char;
begin
   if DeStringList.Count = 0 then exit;
   Stream := nil;
   try
      Fillchar (FileCryptStringListHeader, sizeof(FileCryptStringListHeader), 0);
      FileCryptStringListHeader.Ident := FileCryptID1;
      FileCryptStringListHeader.Count := DeStringList.Count;
      Stream := TFileStream.Create (aFileName, fmCreate or fmOpenReadWrite);
      Stream.WriteBuffer (FileCryptStringListHeader, sizeof(TFileCryptStringListHeader));
      for i := 0 to DeStringList.Count -1 do begin
         Fillchar (FileCryptItem, sizeof(TFileCryptItem), 0);
         FileCryptItem.Size := Length(DeStringList[i]);
         Stream.WriteBuffer (FileCryptItem, sizeof(TFileCryptItem));
         Fillchar (buffer, sizeof(buffer), 0);
         StrPCopy (@buffer, DeStringList[i]);
         Stream.WriteBuffer (buffer, FileCryptItem.Size);
      end;
   except
      if Stream <> nil then Stream.Free;
   end;
   if Stream <> nil then Stream.Free;
end;

end.

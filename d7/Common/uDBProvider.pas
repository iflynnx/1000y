unit uDBProvider;

interface

uses
   Windows, Classes, SysUtils, StdCtrls, ComCtrls, mmSystem, uRecordDef,
   uUtil, DefType;

type

   TIndexData = record
      Name : String [32];
      RecordNo : Integer;
   end;
   PTIndexData = ^TIndexData;
   TBlankData = record
      RecordNo : Integer;
   end;
   PTBlankData = ^TBlankData;

   TIndexClass = class
   private
      Header : TIndexHeader;
      RecordBuffer : TIndexData;
      
      DataList : TList;
      LastErrorStr : String;

      function GetCount : Integer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;
      procedure Sort;

      function LoadFromFile (aFileName : String; var aBlankList : TList) : Boolean;
      function SaveToFile (aFileName : String; var aBlankList : TList) : Boolean;

      function Add (aName : String; aRecordNo : Integer) : Byte;
      function Delete (aName : String) : Byte;
      function Select (aName : String) : Integer;
      function SelectByIndex (aIndex : Integer) : Integer;

      function Insert (aName : String; aRecordNo : Integer) : Byte;
      function GetInsertPos (aName : String) : Integer;

      procedure Print (aControl : TMemo);

      property GetLastErrorStr : String read LastErrorStr;
      property Count : Integer read GetCount;
   end;

   TDBProvider = class
   private
      FileName : String;
      DBStream : TFileStream;
      Header : TDBHeader;
      RecordBuffer : TDBRecord;

      IndexClass : TIndexClass;
      BlankList : TList;

      PrintControl : TMemo;

      LastErrorStr : String;

      function GetTotalRecordCount : Integer;
      function GetUsedRecordCount : Integer;
      function GetUnusedRecordCount : Integer;
   public
      constructor Create (aFileName : String);
      destructor Destroy; override;

      function CreateDB : Boolean;
      function OpenDB : Boolean;
      function CloseDB : Boolean;

      function AddBlankRecord (aCount : Integer) : Boolean;

      procedure Clear;

      function SelectDisk (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
      function UpdateDisk (aIndexName : String; aDBRecord : PTDBRecord) : Byte;

      function Select (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
      function Insert (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
      function Delete (aIndexName : String) : Byte;
      function Update (aIndexName : String; aDBRecord : PTDBRecord) : Byte;

      function ChangeDataToStr (aDBRecord : PTDBRecord) : String;
      procedure ChangeStrToData (aStr : String; var DBRecord : TDBRecord);

      procedure SetPrintControl (aMemo : TMemo);
      procedure ShowInfo (aStr : String);

      procedure BackupHeader (aStream : TFileStream);
      function BackupRecord (aStream : TFileStream; aIndex : Integer) : Boolean;

      property TotalRecordCount : Integer read GetTotalRecordCount;
      property UsedRecordCount : Integer read GetUsedRecordCount;
      property UnusedRecordCount : Integer read GetUnusedRecordCount;
   end;

   function IndexSortCompare (Item1, Item2: Pointer): Integer;

var
   DBProvider : TDBProvider = nil;

implementation

uses
   FMain;

function IndexSortCompare (Item1, Item2: Pointer): Integer;
var
   pd1, pd2 : PTIndexData;
begin
   Result := 0;
   
   pd1 := PTIndexData (Item1);
   pd2 := PTIndexData (Item2);

   if pd1^.Name > pd2^.Name then begin
      Result := 1;
   end else if pd1^.Name < pd2^.Name then begin
      Result := -1;
   end;
end;

// TIndexClass

constructor TIndexClass.Create;
begin
   LastErrorStr := '';

   FillChar (Header, SizeOf (TIndexHeader), 0);
   FillChar (RecordBuffer, SizeOf (TIndexData), 0);
   DataList := TList.Create;
end;

destructor TIndexClass.Destroy;
begin
   Clear;
   DataList.Free;

   inherited Destroy;
end;

procedure TIndexClass.Clear;
var
   i : Integer;
   pd : PTIndexData;
begin
   for i := 0 to DataList.Count - 1 do begin
      pd := DataList.Items [i];
      if pd <> nil then Dispose (pd);
   end;
   DataList.Clear;
end;

function TIndexClass.GetCount : Integer;
begin
   Result := DataList.Count;
end;

procedure TIndexClass.Sort;
begin
   DataList.Sort (IndexSortCompare);
end;

function TIndexClass.LoadFromFile (aFileName : String; var aBlankList : TList) : Boolean;
var
   i : Integer;
   nCode : byte;
   nCount : Integer;
   Stream : TFileStream;

   IndexData : TIndexData;
   BlankData : TBlankData;
   pd : PTBlankData;
begin
   Result := false;

   if not FileExists (aFileName) then exit;

   Stream := nil;
   try
      Stream := TFileStream.Create (aFileName, fmOpenReadWrite);
      Stream.ReadBuffer (Header, SizeOf (TIndexHeader));
   except
      if Stream <> nil then Stream.Free;
      exit;
   end;

   Header.ID[3] := 0;
   if StrPas (@Header.ID) <> IndexID then begin
      Stream.Free;
      exit;
   end;

   try
      nCount := 0;
      for i := 0 to Header.IndexRecordCount - 1 do begin
         Stream.ReadBuffer (IndexData, SizeOf (TIndexData));
         nCode := Add (IndexData.Name, IndexData.RecordNo);
         if nCode <> DB_OK then break;
         nCount := nCount + 1;
      end;
      Header.IndexRecordCount := nCount;

      nCount := 0;
      for i := 0 to Header.BlankRecordCount - 1 do begin
         Stream.ReadBuffer (BlankData, SizeOf (TBlankData));
         New (pd);
         pd^.RecordNo := i;
         aBlankList.Add (pd);
         nCount := nCount + 1;
      end;
      Header.BlankRecordCount := nCount;
   except
      if Stream <> nil then Stream.Free;
      exit;
   end;
   Stream.Free;

   Result := true;
end;

function TIndexClass.SaveToFile (aFileName : String; var aBlankList : TList) : Boolean;
var
   i : Integer;
   Stream : TFileStream;

   pid : PTIndexData;
   pbd : PTBlankData;
begin
   Result := false;

   if FileExists (aFileName) then DeleteFile (aFileName);

   StrPCopy (@Header.ID, IndexID);
   Header.IndexRecordCount := DataList.Count;
   Header.BlankRecordCount := aBlankList.Count;

   Stream := nil;
   try
      Stream := TFileStream.Create (aFileName, fmCreate);
      Stream.WriteBuffer (Header, SizeOf (TIndexHeader));
   except
      if Stream <> nil then Stream.Free;
      exit;
   end;
   
   try
      for i := 0 to Header.IndexRecordCount - 1 do begin
         pid := DataList.Items [i];
         Stream.WriteBuffer (pid^, SizeOf (TIndexData));
      end;
      for i := 0 to Header.BlankRecordCount - 1 do begin
         pbd := aBlankList.Items [i];
         Stream.WriteBuffer (pbd^, SizeOf (TBlankData));
      end;
   except
      if Stream <> nil then Stream.Free;
      exit;
   end;

   Stream.Free;
   Result := true;

end;

procedure TIndexClass.Print (aControl : TMemo);
var
   i : Integer;
   pd : PTIndexData;
begin
   for i := 0 to DataList.Count - 1 do begin
      pd := DataList.Items [i];
      aControl.Lines.Add (pd^.Name);
   end;
end;

function TIndexClass.Add (aName : String; aRecordNo : Integer) : Byte;
var
   nPos : Integer;
   pd : PTIndexData;
begin
   Result := DB_OK;

   if aName = '' then begin
      LastErrorStr := 'Invalid Name';
      Result := DB_ERR_INVALIDDATA;
      exit;
   end;

   nPos := Select (aName);
   if nPos >= 0 then begin
      LastErrorStr := 'Invalid Key (same key is already being)';
      Result := DB_ERR_DUPLICATE;
      exit;
   end;

   New (pd);
   pd^.Name := aName;
   pd^.RecordNo := aRecordNo;
   DataList.Add (pd);
end;

function TIndexClass.Insert (aName : String; aRecordNo : Integer) : Byte;
var
   nPos : Integer;
   pd : PTIndexData;
   i : Integer;
begin
   Result := DB_OK;

   if aName = '' then begin
      LastErrorStr := 'Invalid Name';
      Result := DB_ERR_INVALIDDATA;
      exit;
   end;

   nPos := Select (aName);
   if nPos >= 0 then begin
      LastErrorStr := 'Invalid Key (same key is already being)';
      Result := DB_ERR_DUPLICATE;
      exit;
   end;

   New (pd);
   pd^.Name := aName;
   pd^.RecordNo := aRecordNo;

   nPos := GetInsertPos (aName);
   if nPos < 0 then begin
      Result := DB_ERR_DUPLICATE;
      exit;
   end;

   DataList.Insert (nPos, pd);

   {
   for i := 0 to DataList.Count - 1 do begin
      pd := DataList.Items[i];
      frmMain.AddLog (pd^.Name);
   end;
   }
end;

function TIndexClass.Delete (aName : String) : Byte;
var
   nPos : Integer;
   pd : PTIndexData;
begin
   Result := DB_OK;

   nPos := Select (aName);
   if nPos < 0 then begin
      Result := DB_ERR_NOTFOUND;
      exit;
   end;

   pd := DataList.Items [nPos];
   Dispose (pd);

   DataList.Delete (nPos);
end;

function TIndexClass.Select (aName : String) : Integer;
var
   HighPos, LowPos, MidPos : Integer;
   pd : PTIndexData;
begin
   Result := -1;

   LowPos := 0;
   HighPos := DataList.Count - 1;
   MidPos := (LowPos + HighPos) div 2;

   while LowPos <= HighPos do begin
      pd := DataList.Items [MidPos];
      if pd^.Name = aName then begin
         Result := pd^.RecordNo;
         exit;
      end else if pd^.Name > aName then begin
         HighPos := MidPos - 1;
      end else begin
         LowPos := MidPos + 1;
      end;
      MidPos := (LowPos + HighPos) div 2;
   end;
end;

function TIndexClass.SelectByIndex (aIndex : Integer) : Integer;
var
   pd : PTIndexData;
begin
   Result := -1;
   if aIndex >= DataList.Count then exit;

   pd := DataList.Items [aIndex];
   
   Result := pd^.RecordNo;
end;

function TIndexClass.GetInsertPos (aName : String) : Integer;
var
   HighPos, LowPos, MidPos : Integer;
   pd : PTIndexData;
begin
   Result := -1;

   LowPos := 0;
   HighPos := DataList.Count - 1;
   MidPos := (LowPos + HighPos) div 2;

   while LowPos <= HighPos do begin
      pd := DataList.Items [MidPos];
      if pd^.Name = aName then begin
         exit;
      end else if pd^.Name > aName then begin
         HighPos := MidPos - 1;
      end else begin
         LowPos := MidPos + 1;
      end;
      MidPos := (LowPos + HighPos) div 2;
   end;

   if HighPos >= 0 then MidPos := MidPos + 1;
   
   Result := MidPos;
end;

// TDBProvider
constructor TDBProvider.Create (aFileName : String);
begin
   FileName := aFileName;
   DBStream := nil;
   FillChar (Header, sizeof (TDBHeader), 0);
   IndexClass := nil;
   BlankList := nil;
   LastErrorStr := '';

   PrintControl := nil;
end;

destructor TDBProvider.Destroy;
begin
   Clear;
   inherited Destroy;
end;

function TDBProvider.GetTotalRecordCount : Integer;
begin
   Result := Header.RecordCount;
end;

function TDBProvider.GetUsedRecordCount : Integer;
begin
   Result := IndexClass.Count;
end;

function TDBProvider.GetUnusedRecordCount : Integer;
begin
   Result := BlankList.Count;
end;

function TDBProvider.CreateDB : Boolean;
begin
   Result := false;

   Clear;

   if FileExists (FileName) then exit;

   ShowInfo (format ('%s creating...', [FileName]));

   try
      FillChar (Header, SizeOf (TDBHeader), 0);
      StrPCopy (@Header.ID, 'DBID');
      Header.RecordCount := 0;
      Header.RecordDataSize := SizeOf (TDBRecord) - 1;
      Header.RecordFullSize := SizeOf (TDBRecord);
      Header.boSavedIndex := FALSE;
      DBStream := TFileStream.Create (FileName, fmCreate);
      DBStream.WriteBuffer (Header, sizeof (TDBHeader));
      DBStream.Free;
      DBStream := nil;
   except
      exit;
   end;
   
   ShowInfo ('completed');
   Result := true;
end;

function TDBProvider.AddBlankRecord (aCount : Integer) : Boolean;
var
   i : Integer;
   pd : PTBlankData;
begin
   Result := false;
   if DBStream = nil then exit;

   try
      DBStream.Seek (SizeOf (TDBHeader) + Header.RecordCount * Header.RecordFullSize, soFromBeginning);
      
      FillChar (RecordBuffer, SizeOf (TDBRecord), 0);
      for i := 0 to aCount - 1 do begin
         DBStream.WriteBuffer (RecordBuffer, SizeOf (TDBRecord));
         New (pd);
         pd^.RecordNo := Header.RecordCount + i;
         BlankList.Add (pd);
      end;

      Header.RecordCount := Header.RecordCount + aCount;

      DBStream.Seek (0, soFromBeginning);
      DBStream.WriteBuffer (Header, SizeOf (TDBHeader));
   except
      exit;
   end;
   Result := true;
end;

function TDBProvider.OpenDB : Boolean;
var
   i, nPos : Integer;
   TotalRecordCount, nCount : Integer;
   StartTick, EndTick, TickSum : Integer;
   nMin, nSec, nMSec : Word;
   nCode : Byte;
   pd : PTBlankData;
begin
   Result := false;

   Clear;

   if not FileExists (FileName) then exit;

   ShowInfo (format ('%s reading...', [FileName]));

   StartTick := timeGetTime;
   IndexClass := TIndexClass.Create;
   BlankList := TList.Create;

   try
      DBStream := TFileStream.Create (FileName, fmOpenReadWrite);
      DBStream.ReadBuffer (Header, sizeof (TDBHeader));
   except
      exit;
   end;

   // IndexFileName := ChangeFileExt (FileName, '.IDX');
   // if IndexClass.LoadFromFile (IndexFileName, BlankList) = false then begin
   nCount := 0;
   try
      nCount := 0; TotalRecordCount := 0;
      for i := 0 to Header.RecordCount - 1 do begin
         // DBStream.Seek (sizeof (TDBHeader) + (i * Header.RecordFullSize), soFromBeginning);
         DBStream.ReadBuffer (RecordBuffer, sizeof (TDBRecord));
         if RecordBuffer.boUsed = 1 then begin
            nCode := IndexClass.Add (StrPas (@RecordBuffer.PrimaryKey), i);
            if nCode <> DB_OK then begin
               ShowInfo (format ('Invalid Data at %d (%s)', [i + 1, StrPas (@RecordBuffer.PrimaryKey)]));
               ShowInfo (format ('-> %s', [IndexClass.GetLastErrorStr]));
               ShowInfo (format ('-> %s,%s', [StrPas (@RecordBuffer.PrimaryKey), StrPas (@RecordBuffer.MasterName)]));

               nPos := IndexClass.Select (StrPas (@RecordBuffer.PrimaryKey));
               if nPos >= 0 then begin
                  DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
                  DBStream.ReadBuffer (RecordBuffer, sizeof (TDBRecord));
                  ShowInfo (format ('-> %s,%s', [StrPas (@RecordBuffer.PrimaryKey), StrPas (@RecordBuffer.MasterName)]));
               end;

               // 잘못된 레코드는 새로 추가할수 있도록 빈레코드로 한다
               New (pd);
               pd^.RecordNo := i;
               BlankList.Add (pd);

               FillChar (RecordBuffer, SizeOf (TDBRecord), 0);
               DBStream.Seek (sizeof (TDBHeader) + (i * Header.RecordFullSize), soFromBeginning);
               DBStream.WriteBuffer (RecordBuffer, sizeof (TDBRecord));
            end else begin
               nCount := nCount + 1;
            end;
         end else begin
            new (pd);
            pd^.RecordNo := i;
            BlankList.Add (pd);
         end;
         Inc (TotalRecordCount);
      end;
   except
      ShowInfo (format ('Record Read failed at %d', [TotalRecordCount]));
   end;
   EndTick := timeGetTime;

   TickSum := EndTick - StartTick;
   nMin := TickSum div (1000 * 60);
   TickSum := TickSum - (1000 * 60 * nMin);
   nSec := TickSum div 1000;
   TickSum := TickSum - (1000 * nSec);
   nMSec := TickSum;

   ShowInfo (format ('Elasped Time %d min %d sec %d', [nMin, nSec, nMSec]));

   Header.RecordCount := TotalRecordCount;
   
   // end;

   ShowInfo (format ('Record Count (Header Value) : %d', [Header.RecordCount]));
   ShowInfo (format ('Used Record Count   : %d', [IndexClass.Count]));
   ShowInfo (format ('Unused Record Count : %d', [BlankList.Count]));
   ShowInfo ('Sorting...');
   StartTick := timeGetTime;
   IndexClass.Sort;
   EndTick := timeGetTime;

   TickSum := EndTick - StartTick;
   nMin := TickSum div (1000 * 60);
   TickSum := TickSum - (1000 * 60 * nMin);
   nSec := TickSum div 1000;
   TickSum := TickSum - (1000 * nSec);
   nMSec := TickSum;

   ShowInfo (format ('Elasped Time %d min %d sec %d', [nMin, nSec, nMSec]));

   ShowInfo ('read completed');

   // IndexClass.Print (PrintControl);
   Result := true;
end;

function TDBProvider.CloseDB : Boolean;
var
   i : Integer;
   Key : String;
   Data : Pointer;
begin
   Result := true;
   Clear;
end;

procedure TDBProvider.Clear;
var
   i : Integer;
   pd : PTBlankData;
begin
   if DBStream <> nil then DBStream.Free;
   if IndexClass <> nil then IndexClass.Free;
   if BlankList <> nil then begin
      for i := 0 to BlankList.Count - 1 do begin
         pd := BlankList.Items [i];
         Dispose (pd);
      end;
      BlankList.Clear;
      BlankList.Free;
   end;

   DBStream := nil;
   IndexClass := nil;
   BlankList := nil;
end;

function TDBProvider.SelectDisk (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
var
   nPos : Integer;
begin
   Result := DB_OK;
   nPos := IndexClass.Select (aIndexName);
   if nPos < 0 then begin
      Result := DB_ERR_NOTFOUND;
      exit;
   end;

   try
      DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
      DBStream.ReadBuffer (aDBRecord^, sizeof (TDBRecord));

      if StrPas (@aDBRecord^.PrimaryKey) <> aIndexName then begin
         Result := DB_ERR_NOTFOUND;
         exit;
      end;
   except
      Result := DB_ERR_IO;
   end;
end;

function TDBProvider.UpdateDisk (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
var
   nPos : Integer;
   DBRecord : TDBRecord;
begin
   Result := DB_OK;
   nPos := IndexClass.Select (aIndexName);
   if nPos < 0 then begin
      Result := DB_ERR_NOTFOUND;
      exit;
   end;

   try
      DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
      DBStream.ReadBuffer (DBRecord, sizeof (TDBRecord));
      if StrPas (@DBRecord.PrimaryKey) <> aIndexName then begin
         Result := DB_ERR_INVALIDDATA;
         exit;
      end;

      DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
      DBStream.WriteBuffer (aDBRecord^, sizeof (TDBRecord));
   except
      Result := DB_ERR_IO;
      exit;
   end;
end;

function TDBProvider.Select (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
begin
   Result := SelectDisk (aIndexName, aDBRecord);
end;

function TDBProvider.Insert (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
var
   nPos : Integer;
   pd : PTBlankData;
   nCode : Byte;
begin
   Result := DB_OK;

   if BlankList.Count > 0 then begin
      pd := BlankList.Items [0];
      nPos := pd^.RecordNo;

      nCode := IndexClass.Insert (aIndexName, nPos);
      if nCode = DB_OK then begin
         aDBRecord^.boUsed := 1;
         try
            DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
            DBStream.WriteBuffer (aDBRecord^, sizeof (TDBRecord));
         except
            Result := DB_ERR_IO;
            exit;
         end;

         Dispose (pd);
         BlankList.Delete (0);
         // IndexClass.Sort;
      end else begin
         Result := nCode;
      end;
   end else begin
      Result := DB_ERR_NOTENOUGHSPACE;
   end;
end;

function TDBProvider.Delete (aIndexName : String) : Byte;
var
   nPos : Integer;
begin
   Result := DB_OK;

   nPos := IndexClass.Select (aIndexName);
   if nPos < 0 then begin
      Result := DB_ERR_NOTFOUND;
      exit;
   end;

   {
   FillChar (RecordBuffer, sizeof (TDBRecord), 0);

   try
      DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
      DBStream.WriteBuffer (RecordBuffer, sizeof (TDBRecord));
   except
      Result := DB_ERR_IO;
      exit;
   end;

   DataPool.Erase (aIndexName);
   Result := IndexClass.Delete (aIndexName);
   }
end;

function TDBProvider.Update (aIndexName : String; aDBRecord : PTDBRecord) : Byte;
begin
   Result := UpdateDisk (aIndexName, aDBRecord);
end;

procedure TDBProvider.BackupHeader (aStream : TFileStream);
begin
   ShowInfo ('Backup Start');
   aStream.WriteBuffer (Header, SizeOf (TDBHeader));
end;

function TDBProvider.BackupRecord (aStream : TFileStream; aIndex : Integer) : Boolean;
var
   nPos : Integer;
   tmpRecord : TDBRecord;
begin
   Result := false;

   nPos := IndexClass.SelectByIndex (aIndex);
   if nPos < 0 then begin
      ShowInfo ('Backup end');
      exit;
   end;

   DBStream.Seek (sizeof (TDBHeader) + (nPos * Header.RecordFullSize), soFromBeginning);
   DBStream.ReadBuffer (tmpRecord, sizeof (TDBRecord));

   aStream.WriteBuffer (tmpRecord, SizeOf (TDBRecord));

   Result := true;
end;

procedure TDBProvider.SetPrintControl (aMemo : TMemo);
begin
   PrintControl := aMemo;
end;

procedure TDBProvider.ShowInfo (aStr : String);
begin
   if PrintControl = nil then exit;

   PrintControl.Lines.Add (aStr);
end;

function TDBProvider.ChangeDataToStr (aDBRecord : PTDBRecord) : String;
var
   i : Integer;
   RetStr : String;
begin
   RetStr := StrPas (@aDBRecord^.PrimaryKey);
   RetStr := RetStr + ',' + StrPas (@aDBRecord^.MasterName);
   RetStr := RetStr + ',' + StrPas (@aDBRecord^.Guild);
   RetStr := RetStr + ',' + StrPas (@aDBRecord^.LastDate);
   RetStr := RetStr + ',' + StrPas (@aDBRecord^.CreateDate);
   RetStr := RetStr + ',' + StrPas (@aDBRecord^.Sex);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.ServerID);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.X);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Y);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Light);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Dark);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Energy);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.InPower);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.OutPower);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Magic);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Life);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Talent);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.GoodChar);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.BadChar);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Adaptive);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Revival);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Immunity);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.Virtue);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurEnergy);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurInPower);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurOutPower);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurMagic);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurLife);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurHealth);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurSatiety);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurPoisoning);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurHeadSeak);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurArmSeak);
   RetStr := RetStr + ',' + IntToStr (aDBRecord^.CurLegSeak);
   for i := 0 to 10 - 1 do begin
      RetStr := RetStr + ',' + IntToStr (aDBRecord^.BasicMagicArr[i].Skill);
   end;
   for i := 0 to 8 - 1 do begin
      RetStr := RetStr + ',' + StrPas (@aDBRecord^.WearItemArr[i].Name) + ':' + IntToStr (aDBRecord^.WearItemArr[i].Color) + ':' + IntToStr (aDBRecord^.WearItemArr[i].Count);
   end;
   for i := 0 to 30 - 1 do begin
      RetStr := RetStr + ',' + StrPas (@aDBRecord^.HaveItemArr[i].Name) + ':' + IntToStr (aDBRecord^.HaveItemArr[i].Color) + ':' + IntToStr (aDBRecord^.HaveItemArr[i].Count);
   end;
   for i := 0 to 30 - 1 do begin
      RetStr := RetStr + ',' + StrPas (@aDBRecord^.HaveMagicArr[i].Name) + ':' + IntToStr (aDBRecord^.HaveMagicArr[i].Skill);
   end;

   Result := RetStr;
end;

procedure TDBProvider.ChangeStrToData (aStr : String; var DBRecord : TDBRecord);
var
   i : Integer;
   rStr, str, rdstr, cmdStr, keyStr, RetStr : String;
   uPrimaryKey, uMasterName, uGuild, uLastDate, uCreateDate, uSex, uServerId, uX, uY : String;
   uLight, uDark, uEnergy, uInPower, uOutPower, uMagic, uLife, uTalent, uGoodChar : String;
   uBadChar, uAdaptive, uRevival, uImmunity, uVirtue, uCurEnergy, uCurInPower : String;
   uCurOutPower, uCurMagic, uCurLife, uCurHealth, uCurSatiety, uCurPoisoning : String;
   uCurHeadSeak, uCurArmSeak, uCurLegSeak : String;
   uBasicMagic : array[0..10 - 1] of String;
   uWearItem : array[0..8 - 1] of String;
   uHaveItem : array[0..30 - 1] of String;
   uHaveMagic : array[0..30 - 1] of String;
   uname, ucount, ucolor, uskill : String;
begin
   str := aStr;

   str := GetTokenStr (str, uPrimaryKey, ',');
   str := GetTokenStr (str, uMasterName, ',');
   str := GetTokenStr (str, uGuild, ',');
   str := GetTokenStr (str, uLastDate, ',');
   str := GetTokenStr (str, uCreateDate, ',');
   str := GetTokenStr (str, uSex, ',');
   str := GetTokenStr (str, uServerId, ',');
   str := GetTokenStr (str, uX, ',');
   str := GetTokenStr (str, uY, ',');
   str := GetTokenStr (str, uLight, ',');
   str := GetTokenStr (str, uDark, ',');
   str := GetTokenStr (str, uEnergy, ',');
   str := GetTokenStr (str, uInPower, ',');
   str := GetTokenStr (str, uOutPower, ',');
   str := GetTokenStr (str, uMagic, ',');
   str := GetTokenStr (str, uLife, ',');
   str := GetTokenStr (str, uTalent, ',');
   str := GetTokenStr (str, uGoodChar, ',');
   str := GetTokenStr (str, uBadChar, ',');
   str := GetTokenStr (str, uAdaptive, ',');
   str := GetTokenStr (str, uRevival, ',');
   str := GetTokenStr (str, uImmunity, ',');
   str := GetTokenStr (str, uVirtue, ',');
   str := GetTokenStr (str, uCurEnergy, ',');
   str := GetTokenStr (str, uCurInPower, ',');
   str := GetTokenStr (str, uCurOutPower, ',');
   str := GetTokenStr (str, uCurMagic, ',');
   str := GetTokenStr (str, uCurLife, ',');
   str := GetTokenStr (str, uCurHealth, ',');
   str := GetTokenStr (str, uCurSatiety, ',');
   str := GetTokenStr (str, uCurPoisoning, ',');
   str := GetTokenStr (str, uCurHeadSeak, ',');
   str := GetTokenStr (str, uCurArmSeak, ',');
   str := GetTokenStr (str, uCurLegSeak, ',');

   for i := 0 to 10 - 1 do begin
      str := GetTokenStr (str, uBasicMagic[i], ',');
   end;
   for i := 0 to 8 - 1 do begin
      str := GetTokenStr (str, uWearItem[i], ',');
   end;
   for i := 0 to 30 - 1 do begin
      str := GetTokenStr (str, uHaveItem[i], ',');
   end;
   for i := 0 to 30 - 1 do begin
      str := GetTokenStr (str, uHaveMagic[i], ',');
   end;

   StrPCopy (@DBRecord.PrimaryKey, uPrimaryKey);
   StrPCopy (@DBRecord.MasterName, uMasterName);
   StrPCopy (@DBRecord.Guild, uGuild);
   StrPCopy (@DBRecord.LastDate, uLastDate);
   StrPCopy (@DBRecord.CreateDate, uCreateDate);
   StrPCopy (@DBRecord.Sex, uSex);
   DBRecord.ServerID := _StrToInt (uServerId);
   DBRecord.X := _StrToInt (uX);
   DBRecord.Y := _StrToInt (uY);
   DBRecord.Light := _StrToInt (uLight);
   DBRecord.Dark := _StrToInt (uDark);
   DBRecord.Energy := _StrToInt (uEnergy);
   DBRecord.InPower := _StrToInt (uInPower);
   DBRecord.OutPower := _StrToInt (uOutPower);
   DBRecord.Magic := _StrToInt (uMagic);
   DBRecord.Life := _StrToInt (uLife);
   DBRecord.Talent := _StrToInt (uTalent);
   DBRecord.GoodChar := _StrToInt (uGoodChar);
   DBRecord.BadChar := _StrToInt (uBadChar);
   DBRecord.Adaptive := _StrToInt (uAdaptive);
   DBRecord.Revival := _StrToInt (uRevival);
   DBRecord.Immunity := _StrToInt (uImmunity);
   DBRecord.Virtue := _StrToInt (uVirtue);
   DBRecord.CurEnergy := _StrToInt (uCurEnergy);
   DBRecord.CurInPower := _StrToInt (uCurInPower);
   DBRecord.CurOutPower := _StrToInt (uCurOutPower);
   DBRecord.CurMagic := _StrToInt (uCurMagic);
   DBRecord.CurLife := _StrToInt (uCurLife);
   DBRecord.CurHealth := _StrToInt (uCurHealth);
   DBRecord.CurSatiety := _StrToInt (uCurSatiety);
   DBRecord.CurPoisoning := _StrToInt (uCurPoisoning);
   DBRecord.CurHeadSeak := _StrToInt (uCurHeadSeak);
   DBRecord.CurArmSeak := _StrToInt (uCurArmSeak);
   DBRecord.CurLegSeak := _StrToInt (uCurLegSeak);

   for i := 0 to 10 - 1 do begin
      DBRecord.BasicMagicArr[i].Skill := _StrToInt (uBasicMagic[i]);
   end;
   for i := 0 to 8 - 1 do begin
      rdstr := uWearItem[i];
      rdstr := GetTokenStr (rdstr, uname, ':');
      rdstr := GetTokenStr (rdstr, ucolor, ':');
      rdstr := GetTokenStr (rdstr, ucount, ':');

      StrPCopy (@DBRecord.WearItemArr[i].Name, uname);
      DBRecord.WearItemArr[i].Color := _StrToInt (ucolor);
      DBRecord.WearItemArr[i].Count := _StrToInt (ucount);
   end;
   for i := 0 to 30 - 1 do begin
      rdstr := uHaveItem[i];
      rdstr := GetTokenStr (rdstr, uname, ':');
      rdstr := GetTokenStr (rdstr, ucolor, ':');
      rdstr := GetTokenStr (rdstr, ucount, ':');

      StrPCopy (@DBRecord.HaveItemArr[i].Name, uname);
      DBRecord.HaveItemArr[i].Color := _StrToInt (ucolor);
      DBRecord.HaveItemArr[i].Count := _StrToInt (ucount);
   end;
   for i := 0 to 30 - 1 do begin
      rdstr := uHaveMagic[i];
      rdstr := GetTokenStr (rdstr, uname, ':');
      rdstr := GetTokenStr (rdstr, uskill, ':');

      StrPCopy (@DBRecord.HaveMagicArr[i].Name, uname);
      DBRecord.HaveMagicArr[i].Skill := _StrToInt (uskill);
   end;
end;

end.

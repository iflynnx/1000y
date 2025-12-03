unit uRecordDef;

interface

type
   TDBHeader = record
      ID : array[0..4 - 1] of byte;
      RecordCount : Integer;
      RecordDataSize : Integer;
      RecordFullSize : Integer;
      boSavedIndex : Boolean;
      Dummy : array [0..32 - 1] of byte;
   end;
   PTDBHeader = ^TDBHeader;

   TCharData = record
      CharName : array [0..20 - 1] of byte;
      ServerName : array [0..20 - 1] of byte;
   end;

   TDBRecord = record
      boUsed : byte;
      PrimaryKey : array [0..20 - 1] of byte;
      Password : array [0..20 - 1] of byte;
      CharInfo : array [0..5 - 1] of TCharData;
      IpAddr : array [0..20 - 1] of byte;
      UserName : array [0..20 - 1] of byte;
      Birth : array [0..12 - 1] of byte;
      Telephone : array [0..12 - 1] of byte;
      MakeDate : array [0..12 - 1] of byte;
      LastDate : array [0..12 - 1] of byte;
      Address : array [0..64 - 1] of byte;
      Email : array [0..32 - 1] of byte;
      NativeNumber : array [0..20 - 1] of byte;
      MasterKey : array [0..20 - 1] of byte;
      Dummy : array [0..559 - 1] of byte;
   end;
   PTDBRecord = ^TDBRecord;

implementation

end.

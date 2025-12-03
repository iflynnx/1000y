unit uLGRecordDef;

interface

type
   TLGHeader = record
      ID : array[0..4 - 1] of byte;
      RecordCount : Integer;
      RecordDataSize : Integer;
      RecordFullSize : Integer;
      boSavedIndex : Boolean;
      Dummy : array [0..32 - 1] of byte;
   end;
   PTLGHeader = ^TLGHeader;

   TCharData = record
      CharName : String [20];
      ServerName : String [20];
   end;

   TLGRecord = record
      PrimaryKey : String [20];
      PassWord : String [20];
      UserName : String [20];
      Birth : String [20];
      Address : String [50];
      NativeNumber : String [20];
      MasterKey : String [20];
      Email : String [50];
      Phone : String [20];
      ParentName : String [20];
      ParentNativeNumber : String [20];
      CharInfo : array [0..5 - 1] of TCharData;
      IpAddr : String [16];
      MakeDate : String [20];
      LastDate : String [20];
   end;
   PTLGRecord = ^TLGRecord;

{
   TCharData = record
      CharName : array [0..20 - 1] of byte;
      ServerName : array [0..20 - 1] of byte;
   end;

   TLGRecord = record
      PrimaryKey : array [0..21 - 1] of byte;
      Password : array [0..21 - 1] of byte;
      CharInfo : array [0..5 - 1] of TCharData;
      IpAddr : array [0..21 - 1] of byte;
      UserName : array [0..21 - 1] of byte;
      Birth : array [0..21 - 1] of byte;
      Telephone : array [0..21 - 1] of byte;
      MakeDate : array [0..21 - 1] of byte;
      LastDate : array [0..21 - 1] of byte;
      Address : array [0..51 - 1] of byte;
      Email : array [0..51 - 1] of byte;
      NativeNumber : array [0..21 - 1] of byte;
      MasterKey : array [0..21 - 1] of byte;
      Dummy : array [0..128 - 1] of byte;
   end;
   PTLGRecord = ^TLGRecord;
}

implementation

end.

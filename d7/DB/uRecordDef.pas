unit uRecordDef;

interface

const
   IndexID = 'IDX';

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

   TIndexHeader = record
      ID : array[0..4 - 1] of byte;
      IndexRecordCount : Integer;
      BlankRecordCount : Integer;
      FDBUpdateDate : array[0..32 - 1] of byte;
      Dummy : array[0..32 - 1] of byte;
   end;
   PTIndexHeader = ^TIndexHeader;

   TItemData = record
      Name : array [0..20-1] of byte;
      Count : Integer;
      Color : Byte;
      Durability : Byte;
      UpGrade : array [0..4-1] of Byte;
      Dummy : Byte;
   end;

   TMagicData = record
      Name : array [0..20-1] of byte;
      Skill : Integer;
   end;
   TBasicMagicData = record
      Skill : integer;
   end;

   TDBRecord = record
      boUsed : byte;
      PrimaryKey : array [0..20 - 1] of byte;

      MasterName : array [0..20 - 1] of byte;
      Guild : array [0..20 - 1] of byte;
      LastDate : array [0..12 - 1] of byte;
      CreateDate : array [0..12 - 1] of byte;
      Sex : array [0..6 - 1] of byte;

      ServerId : byte;
      x : word;
      y : word;

      Light : Integer;
      Dark : Integer;
      Energy : Integer;
      InPower : Integer;
      OutPower : Integer;
      Magic : Integer;
      Life : Integer;

      Talent : integer;
      GoodChar : integer;
      BadChar : integer;

      Adaptive : integer;
      Revival : integer;
      Immunity : integer;
      Virtue : integer;

      CurEnergy    : integer;
      CurInPower   : integer;
      CurOutPower  : integer;
      CurMagic     : integer;
      CurLife      : integer;
      CurHealth    : integer;
      CurSatiety   : integer;
      CurPoisoning : integer;
      CurHeadSeak  : integer;
      CurArmSeak   : integer;
      CurLegSeak   : integer;

      BasicMagicArr : array [0..10 - 1] of TBasicMagicData;
      WearItemArr : array [0..8 - 1] of TItemData;
      HaveItemArr : array [0..30 - 1] of TItemData;
      HaveMagicArr : array [0..30 - 1] of TMagicData;

      Dummy : array[0..66 - 1] of byte;
   end;
   PTDBRecord = ^TDBRecord;

implementation

end.

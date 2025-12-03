unit uDBRecordDef;

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

   TDBItemData = record
      Name : array [0..20-1] of byte;
      Count : Integer;
      Color : Byte;
      Durability : Byte;
      UpGrade : array [0..4-1] of Byte;
      Dummy : Byte;
   end;

   TDBMagicData = record
      Name : array [0..20-1] of byte;
      Skill : Integer;
   end;
   TDBBasicMagicData = record
      Skill : integer;
   end;

   TDBRecord = record
      PrimaryKey     : array [0..20 - 1] of byte;              // 캐릭명

      MasterName     : array [0..20 - 1] of byte;              // 계정명
      Guild          : array [0..20 - 1] of byte;              // 문파명
      LastDate       : array [0..12 - 1] of byte;              // 최종접속일
      CreateDate     : array [0..12 - 1] of byte;              // 최초접속일
      Sex            : array [0..6 - 1] of byte;               // 성별

      ServerId       : byte;                                   // Map 번호
      x              : word;                                   // X 좌표
      y              : word;                                   // Y 좌표

      Light          : Integer;                                // 양기
      Dark           : Integer;                                // 음기
      Energy         : Integer;                                // 원기
      InPower        : Integer;                                // 내공
      OutPower       : Integer;                                // 외공
      Magic          : Integer;                                // 무공
      Life           : Integer;                                // 활력

      Talent         : integer;                                // 재능
      GoodChar       : integer;                                // 신성
      BadChar        : integer;                                // 마성
      Adaptive       : integer;                                // 내성
      Revival        : integer;                                // 재생
      Immunity       : integer;                                // 면역
      Virtue         : integer;                                // 호연지기

      CurEnergy      : integer;                                // 현재 원기
      CurInPower     : integer;                                // 현재 내공
      CurOutPower    : integer;                                // 현재 외공
      CurMagic       : integer;                                // 현재 무공
      CurLife        : integer;                                // 현재 활력
      CurHealth      : integer;                                // 현재
      CurSatiety     : integer;                                // 현재
      CurPoisoning   : integer;                                // 현재
      CurHeadSeek    : integer;                                // 현재 머리 활력
      CurArmSeek     : integer;                                // 현재 팔 활력
      CurLegSeek     : integer;                                // 현재 다리 활력

      BasicMagicArr  : array [0..10 - 1] of TDBBasicMagicData; // 기본무공
      WearItemArr    : array [0..8 - 1] of TDBItemData;        // 착용아이템
      HaveItemArr    : array [0..30 - 1] of TDBItemData;       // 소유아이템
      HaveMagicArr   : array [0..30 - 1] of TDBMagicData;      // 소유무공

      Dummy : array[0..66 - 1] of byte;
   end;
   PTDBRecord = ^TDBRecord;

   TDBRecordNew = record
      PrimaryKey     : array [0..20 - 1] of byte;              // 캐릭명

      MasterName     : array [0..20 - 1] of byte;              // 계정명
      Guild          : array [0..20 - 1] of byte;              // 문파명
      LastDate       : array [0..12 - 1] of byte;              // 최종접속일
      CreateDate     : array [0..12 - 1] of byte;              // 최초접속일
      Sex            : byte;                                   // 성별
      
      ServerName     : array [0..6 - 1] of byte;               // 서버명
      ServerID       : byte;                                   // Map 번호
      x              : word;                                   // X 좌표
      y              : word;                                   // Y 좌표

      LifeTime       : Integer;                                // 총 접속시간(초)
      
      Energy         : Word;                                   // 원기
      InPower        : Word;                                   // 내공
      OutPower       : Word;                                   // 외공
      Magic          : Word;                                   // 무공
      Life           : Word;                                   // 활력
      Light          : Word;                                   // 양기
      Dark           : Word;                                   // 음기

      Talent         : Word;                                   // 재능
      GoodChar       : Word;                                   // 신성
      BadChar        : Word;                                   // 마성
      Adaptive       : Word;                                   // 내성
      Revival        : Word;                                   // 재생
      Immunity       : Word;                                   // 면역
      LightVirtue    : Word;                                   // 양 호연지기
      DarkVirtue     : Word;                                   // 음 호연지기

      CurEnergy      : Word;                                   // 현재 원기
      CurInPower     : Word;                                   // 현재 내공
      CurOutPower    : Word;                                   // 현재 외공
      CurMagic       : Word;                                   // 현재 무공
      CurBodyLife    : Word;                                   // 현재 몸통 활력
      CurHeadLife    : Word;                                   // 현재 머리 활력
      CurArmLife     : Word;                                   // 현재 팔 활력
      CurLegLife     : Word;                                   // 현재 다리 활력
      CurLight       : Word;                                   // 현재 양기
      CurDark        : Word;                                   // 현재 음기

      BasicMagicArr  : array [0..10 - 1] of TDBBasicMagicData; // 기본무공
      WearItemArr    : array [0..8 - 1] of TDBItemData;        // 착용아이템
      HaveItemArr    : array [0..30 - 1] of TDBItemData;       // 소유아이템
      HaveMagicArr   : array [0..30 - 1] of TDBMagicData;      // 소유무공

      Dummy : array[0..66 - 1] of byte;
   end;
   PTDBRecordNew = ^TDBRecordNew;

implementation

end.

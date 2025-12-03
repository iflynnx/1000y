unit deftype;

interface

uses
	Windows, SysUtils, Classes, AUtil32;

const
   // Packet Message Define
   PACKET_NONE          = 0;
   PACKET_GAME          = 1;
   PACKET_CLIENT        = 2;
   PACKET_GATE          = 3;
   PACKET_DB            = 4;
   PACKET_LOGIN         = 5;
   PACKET_PAID          = 6;
   PACKET_NOTICE        = 7;

   GM_SM_NONE           = 0;
   GM_SM_ADD            = 1;       // 사용자 추가
   GM_SM_DELETE         = 2;       // 계정 대기실 자료 삭제 허용
   GM_SM_REQUESTCLOSE   = 3;       // 사용중인것 해제
//   GM_SM_ADDGUILDNAME = 4;
   GM_SM_ALLOWGUILDNAME = 5;

   GM_CHECK             = 10;
   GM_CHECK_OK          = 11;

   GM_CM_NONE           = 0;
   GM_CM_SAVE           = 1;       // 게임상태                               :  정상
   GM_CM_SAVEANDCLOSE   = 2;       // 계정 대기실에서 게임자료 저장과 해제   :  정상
   GM_CM_CLOSE          = 3;       // 없는 사용자 해제 요청시 해제허가       :  보완
   GM_CM_ADDGUILDNAME   = 4;
   GM_CM_ALLOWGUILDNAME = 5;

   NATION_KOREA         = 1;
   NATION_TAIWAN        = 2;
   NATION_CHINA_1       = 3;

   NATION_VERSION       = NATION_KOREA;
   PROGRAM_VERSION      = 16;

   MONEYMAX = 61000;

   HAVEITEMSIZE = 30;
   HAVEMAGICSIZE = 30;

   VIEWRANGEWIDTH = 10;
   VIEWRANGEHEIGHT = 8;

   DEFAULTEXP    = 10000;     // 이벤트시 얻는 기본 경치

   NAME_SIZE    = 19;         // 한글 9 글자

   NOTARGETPHONE = 0;
   MANAGERPHONE  = 1;

   STARTNEWID = 10000;
   USERMANAGERPOST  = 1000;
   FIELDPOST = 100;

   SAVE_USERDATA_DELAY_TIME = 5 * 60 * 100;

   SAY_COLOR_NORMAL     = 0;
   SAY_COLOR_SHOUT      = 1;
   SAY_COLOR_SYSTEM     = 2;
   SAY_COLOR_NOTICE     = 3;

   SAY_COLOR_GRADE0     = 10;
   SAY_COLOR_GRADE1     = 11;
   SAY_COLOR_GRADE2     = 12;
   SAY_COLOR_GRADE3     = 13;
   SAY_COLOR_GRADE4     = 14;
   SAY_COLOR_GRADE5     = 15;
   {
   SAY_COLOR_GRADE6     = 16;
   SAY_COLOR_GRADE7     = 17;
   SAY_COLOR_GRADE8     = 18;
   SAY_COLOR_GRADE9     = 19;
   }

   HANGON_NONE         = 0;

   ITEM_KIND_NONE       = 0;
   ITEM_KIND_COLORDRUG  = 1;
   ITEM_KIND_BOOK       = 2;
   ITEM_KIND_WEARITEM   = 6;
   ITEM_KIND_ARROW      = 7;
   ITEM_KIND_FLYSWORD   = 8;
   ITEM_KIND_GUILDSTONE = 9;
   ITEM_KIND_DUMMY      = 10;
   ITEM_KIND_STATICITEM = 11;
   ITEM_KIND_DRUG       = 13;
   ITEM_KIND_TICKET     = 18;
   ITEM_KIND_HIDESKILL  = 19;
   ITEM_KIND_CANTMOVE   = 20;
   ITEM_KIND_ITEMLOG    = 21;
   ITEM_KIND_CHANGER    = 22;
   ITEM_KIND_SHOWSKILL  = 23;
   ITEM_KIND_WEARITEM2  = 24;

   GATE_KIND_NORMAL     = 0;
   GATE_KIND_BS         = 1;

   DYNOBJ_EVENT_NONE    = 0;
   DYNOBJ_EVENT_HIT     = 1;
   DYNOBJ_EVENT_ADDITEM = 2;
   DYNOBJ_EVENT_SAY     = 4;
   
   // 0 아무 이벤트도 발생하지 않음
   // 1 때리면 이벤트 발생
   // 2 아이템을 집어넣으면 이벤트 발생
   // 4 말을 걸면 이벤트 발생
   // 3 때리고 아이템 집어넣고
   // 5 때리고 말하고
   // 6 아이템 집어놓고 말하고
   // 7 때리고 아이템 집어넣고 말하고

   DEFAULT_WRESTLING  = 0;              // 위치에 관한
   DEFAULT_FENCING    = 1;
   DEFAULT_SWORDSHIP  = 2;
   DEFAULT_HAMMERING  = 3;
   DEFAULT_SPEARING   = 4;
   DEFAULT_BOWING     = 5;
   DEFAULT_THROWING   = 6;
   DEFAULT_RUNNING    = 7;
   DEFAULT_BREATHNG   = 8;
   DEFAULT_PROTECTING = 9;

   MAGICTYPE_WRESTLING  = 0;              // 위치에 관한
   MAGICTYPE_FENCING    = 1;
   MAGICTYPE_SWORDSHIP  = 2;
   MAGICTYPE_HAMMERING  = 3;
   MAGICTYPE_SPEARING   = 4;
   MAGICTYPE_BOWING     = 5;
   MAGICTYPE_THROWING   = 6;
   MAGICTYPE_RUNNING    = 7;
   MAGICTYPE_BREATHNG   = 8;
   MAGICTYPE_PROTECTING = 9;

   MAGICTYPE_ECT        = 10;

   MAGICTYPE_ONLYBOWING = 11;
   MAGICTYPE_SPECIAL    = 12;
      MAGICSPECIAL_HIDE = 0;
      MAGICSPECIAL_SAME = 1;
      MAGICSPECIAL_HEAL = 2;
      MAGICSPECIAL_SWAP = 3;
      MAGICSPECIAL_EAT  = 4;
      MAGICSPECIAL_KILL = 5;
      MAGICSPECIAL_PICK = 6;

      MAGICSPECIAL_LAST = 7;

   MAGICFUNC_NONE       = 0;
   MAGICFUNC_REFILL     = 1;
   MAGICFUNC_8HIT       = 2;
   MAGICFUNC_5HIT       = 3;

   SELECTMAGIC_RESULT_FALSE   = -1;
   SELECTMAGIC_RESULT_NONE    = 0;
   SELECTMAGIC_RESULT_NORMAL  = 1;
   SELECTMAGIC_RESULT_SITDOWN = 2;
   SELECTMAGIC_RESULT_RUNNING = 3;


   RACE_NONE          = 0;
   RACE_HUMAN         = 1;
   RACE_ITEM          = 2;
   RACE_MONSTER       = 3;
   RACE_NPC           = 4;
   RACE_DYNAMICOBJECT = 5;
   RACE_STATICITEM    = 6;

   CLASS_NONE         = 0;
   CLASS_HUMAN        = 1;
   CLASS_MONSTER      = 2;
   CLASS_NPC          = 3;
   CLASS_ITEM         = 4;
   CLASS_DYNOBJECT    = 5;
   CLASS_GUILDSTONE   = 6;
   CLASS_GUILDNPC     = 7;
   CLASS_GATE         = 8;
   CLASS_STATICITEM   = 9;
   CLASS_DOOR         = 10;
   CLASS_SERVEROBJ    = 11;

   CREATE_NONE        = 0;
   CREATE_ITEM        = 1;
   CREATE_MONSTER     = 2;

   INTRESULT_FALSE   = -1;
   INTRESULT_ARREADY = -2;

   PROC_TRUE    = 0;
   PROC_FALSE   = -1;
   PROC_ARREAY  = -2;

   UPDATE_TRUE  = 0;
   UPDATE_FALSE = -1;

   RET_CLOSE_NONE     = 0;
   RET_CLOSE_RUNNING  = 1;
   RET_CLOSE_BREATHNG = 2;
   RET_CLOSE_ATTACK   = 3;
   RET_CLOSE_PROTECTING = 4;

   DELAYEFFECT_NONE    = 0;


   AM_NONE     =  0;
   AM_DIE      =  1;
   AM_STRUCTED =  2;
   AM_SEATDOWN =  3;
   AM_STANDUP  =  4;
   AM_HELLO    =  5;
   AM_MOTION   =  6;

   AM_TURN     =  10;
   AM_TURN1    =  11;
   AM_TURN2    =  12;
   AM_TURN3    =  13;
   AM_TURN4    =  14;
   AM_TURN5    =  15;
   AM_TURN6    =  16;
   AM_TURN7    =  17;
   AM_TURN8    =  18;
   AM_TURN9    =  19;

   AM_MOVE     =  20;
   AM_MOVE1    =  21;
   AM_MOVE2    =  22;
   AM_MOVE3    =  23;
   AM_MOVE4    =  24;
   AM_MOVE5    =  25;
   AM_MOVE6    =  26;
   AM_MOVE7    =  27;
   AM_MOVE8    =  28;
   AM_MOVE9    =  29;

   AM_HIT      =  30;
   AM_HIT1     =  31;
   AM_HIT2     =  32;
   AM_HIT3     =  33;
   AM_HIT4     =  34;
   AM_HIT5     =  35;
   AM_HIT6     =  36;
   AM_HIT7     =  37;
   AM_HIT8     =  38;
   AM_HIT9     =  39;

   AM_TURNNING  =  40;
   AM_TURNNING1 =  41;
   AM_TURNNING2 =  42;
   AM_TURNNING3 =  43;
   AM_TURNNING4 =  44;
   AM_TURNNING5 =  45;
   AM_TURNNING6 =  46;
   AM_TURNNING7 =  47;
   AM_TURNNING8 =  48;
   AM_TURNNING9 =  49;

{  // 추가할것
   AM_TURN     =  10;
   AM_TURN1    =  11;
   AM_TURN2    =  12;
   AM_TURN3    =  13;
   AM_TURN4    =  14;
   AM_TURN5    =  15;
   AM_TURN6    =  16;
   AM_TURN7    =  17;
   AM_TURN8    =  18;
   AM_TURN9    =  19;
   AM_TURN10   =  20;
   AM_TURN11   =  21;
   AM_TURN12   =  22;
   AM_TURN13   =  23;
   AM_TURN14   =  24;
   AM_TURN15   =  25;
   AM_TURN16   =  26;
   AM_TURN17   =  27;
   AM_TURN18   =  28;
   AM_TURN19   =  29;

   AM_MOVE     =  30;
   AM_MOVE1    =  31;
   AM_MOVE2    =  32;
   AM_MOVE3    =  33;
   AM_MOVE4    =  34;
   AM_MOVE5    =  35;
   AM_MOVE6    =  36;
   AM_MOVE7    =  37;
   AM_MOVE8    =  38;
   AM_MOVE9    =  39;
   AM_MOVE10   =  40;
   AM_MOVE11   =  41;
   AM_MOVE12   =  42;
   AM_MOVE13   =  43;
   AM_MOVE14   =  44;
   AM_MOVE15   =  45;
   AM_MOVE16   =  46;
   AM_MOVE17   =  47;
   AM_MOVE18   =  48;
   AM_MOVE19   =  49;

   AM_HIT      =  50;
   AM_HIT1     =  51;
   AM_HIT2     =  52;
   AM_HIT3     =  53;
   AM_HIT4     =  54;
   AM_HIT5     =  55;
   AM_HIT6     =  56;
   AM_HIT7     =  57;
   AM_HIT8     =  58;
   AM_HIT9     =  59;
   AM_HIT10    =  60;
   AM_HIT11    =  61;
   AM_HIT12    =  62;
   AM_HIT13    =  63;
   AM_HIT14    =  64;
   AM_HIT15    =  65;
   AM_HIT16    =  66;
   AM_HIT17    =  67;
   AM_HIT18    =  68;
   AM_HIT19    =  69;

   AM_TURNNING   =  70;
   AM_TURNNING1  =  71;
   AM_TURNNING2  =  72;
   AM_TURNNING3  =  73;
   AM_TURNNING4  =  74;
   AM_TURNNING5  =  75;
   AM_TURNNING6  =  76;
   AM_TURNNING7  =  77;
   AM_TURNNING8  =  78;
   AM_TURNNING9  =  79;
   AM_TURNNING10 =  70;
   AM_TURNNING11 =  71;
   AM_TURNNING12 =  72;
   AM_TURNNING13 =  73;
   AM_TURNNING14 =  74;
   AM_TURNNING15 =  75;
   AM_TURNNING16 =  76;
   AM_TURNNING17 =  77;
   AM_TURNNING18 =  78;
   AM_TURNNING19 =  79;
}

   ARR_BODY           = 0;
   ARR_GLOVES         = 1;
   ARR_UPUNDERWEAR    = 2;
   ARR_SHOES          = 3;
   ARR_DOWNUNDERWEAR  = 4;

   ARR_UPOVERWEAR     = 6;
   ARR_HAIR           = 7;
   ARR_CAP            = 8;
   ARR_WEAPON         = 9;

   DR_0              = 0;
   DR_1              = 1;
   DR_2              = 2;
   DR_3              = 3;
   DR_4              = 4;
   DR_5              = 5;
   DR_6              = 6;
   DR_7              = 7;
   DR_DONTMOVE       = 8;

   FM_STRING         = 253;
   FM_REBOOT         = 254;
   FM_NONE           = 0;
   FM_CREATE         = 1;
   FM_DESTROY        = 2;
   FM_SHOW           = 3;
   FM_HIDE           = 4;
   FM_MOVE           = 5;
   FM_HIT            = 8;
   FM_SAY            = 9;
   FM_PICKUP         = 11;
   FM_TURN           = 12;
   FM_STRUCTED       = 15;
   FM_CHANGEFEATURE  = 16;
   FM_GIVEMEADDR     = 20;
   FM_ADDATTACKEXP   = 23;
   FM_ADDITEM        = 27;
   FM_DELKEYITEM     = 28;
   FM_ADDMONEY       = 29;
   FM_DELMONEY       = 30;
   FM_SOUNDBASE      = 64;
   FM_GOTOXY         = 73;

   FM_MOTION         = 74;
   FM_DELITEM        = 75;

   FM_GATHERVASSAL   = 76;


   FM_SHOUT          = 100;
   FM_WITHME         = 101;
   FM_ADDPROTECTEXP  = 102;

   FM_SYSOPMESSAGE   = 103;
   FM_BOW            = 104;
   FM_CURRENTUSER    = 105;

   FM_SOUND          = 106;
   FM_CLICK          = 107;

   FM_SAYUSEMAGIC    = 108;
   FM_GUILDATTACK    = 109;

   FM_GATE           = 110;

   FM_ENOUGHSPACE    = 111;

   FM_ALLOWGUILDNAME = 112;
   FM_ALLOWGUILDSYSOPNAME = 113;


   FM_CANCELEXCHANGE = 114;
   FM_SHOWEXCHANGE   = 115;

   FM_REFILL         = 116;

   FM_DBLCLICK       = 117;
   FM_CHANGEPROPERTY = 118;
   FM_REMOVEGUILDMEMBER = 119;
   FM_CHECKGUILDUSER = 120;
   FM_DEADHIT        = 121;
   FM_HEAL           = 122;
   FM_KILL           = 123;
   FM_LIFEPERCENT    = 124;
   FM_IAMHERE        = 125;

   PM_LETMEIN     = 1;
   PM_LETMEOUT    = 2;

   MM_SHOW           = 1;
   MM_HIDE           = 2;
   MM_MOVE           = 3;


   SM_SETCLIENTCONDITION   = 2;

   SM_CONNECTTHRU    =253;
   SM_RECONNECT      =254;
   SM_CLOSE          =255;   // 버전 틀림같음
   SM_NONE           =  0;
   SM_WINDOW         =  1;
   SM_MESSAGE        =  2;
      MESSAGE_NONE         = 0;
      MESSAGE_LOGIN        = 1;
      MESSAGE_CREATELOGIN  = 2;
      MESSAGE_SELCHAR      = 3;
      MESSAGE_GAMEING      = 4;
      MESSAGE_AGREE        = 5;

   SM_CHARINFO       = 3;
   SM_CHATMESSAGE    = 4;

   SM_ATTRIBBASE     = 5;
   SM_HAVEITEM       = 6;
   SM_HAVEMAGIC      = 7;
   SM_WEARITEM       = 8;

   SM_NEWMAP         = 9;
   SM_SHOW           = 10;
   SM_HIDE           = 11;
   SM_SAY            = 12;
   SM_MOVE           = 13;
   SM_TURN           = 15;
   SM_SETPOSITION    = 16;

   SM_CHANGEFEATURE  = 18;
   SM_MAGIC          = 19;
   SM_SOUNDBASE      = 21;

   SM_MOTION         = 22;

   SM_ATTRIB_VALUES     = 23;
   SM_ATTRIB_FIGHTBASIC = 24;
   SM_ATTRIB_LIFE       = 25;

   SM_EVENTSTRING     = 26;
   SM_STRUCTED        = 27;

   SM_SHOWITEM        = 28;
   SM_SHOWMONSTER     = 29;
   SM_HIDEITEM        = 30;
   SM_HIDEMONSTER     = 31;

   SM_USEDMAGICSTRING = 32;
   SM_MOVINGMAGIC     = 33;

   SM_BASICMAGIC      = 34;
   SM_SOUNDSTRING     = 35;

   SM_SAYUSEMAGIC     = 36;
   SM_BOSHIFTATTACK   = 37;

   SM_RAINNING        = 38;
   SM_SOUNDBASESTRING = 39;

   SM_SOUNDBASESTRING2= 40;
   SM_SOUNDEFFECT     = 41;

   SM_SHOWINPUTSTRING = 42;

   SM_HIDEEXCHANGE    = 43;
   SM_SHOWEXCHANGE    = 44;

   SM_SHOWCOUNT       = 45;
   SM_CHANGEPROPERTY  = 46;

   SM_SHOWDYNAMICOBJECT = 47;
   SM_HIDEDYNAMICOBJECT = 48;
   SM_CHANGESTATE       = 49;

   SM_SHOWSPECIALWINDOW = 50;

   SM_LOGITEM           = 51;
   SM_CHECK             = 52;

   // for Battle Server
   SM_SHOWBATTLEBAR     = 53;    // 개인대전시의 화면상단의 활력바를 표시
   SM_SHOWCENTERMSG     = 54;    // 중앙에 사각형을 그리고 문자를 출력

   // saset
   SM_HIDESPECIALWINDOW = 55;    // 화면에 떠있는 SpecialWindow 를 닫도록 클라이언트에게 요청한다
   SM_NETSTATE          = 56;

   SM_CHARMOVEFRONTDIEFLAG = 255; // 임시사용 케릭터가 죽은사람위로 지나갈수 있는 경우를 TRUE로 설정

   WINDOW_NONE        = 0;
   WINDOW_ITEMS       = 1;
   WINDOW_WEARS       = 2;
   WINDOW_SCREEN      = 3;
   WINDOW_BASICFIGHT  = 4;
   WINDOW_MAGICS      = 5;
   WINDOW_EXCHANGE    = 6;

   WINDOW_ITEMLOG     = 7;
   WINDOW_ALERT       = 8;
   WINDOW_AGREE       = 9;

   WINDOW_GUILDMAKE   = 10;
   WINDOW_GUILDINFO   = 11;
   WINDOW_GUILDWAR1   = 12;
   WINDOW_GUILDWAR2   = 13;
   WINDOW_GUILDMAGIC  = 14;

   // USE BATTLE SERVER
   WINDOW_GROUPWINDOW = 20;
   WINDOW_ROOMWINDOW  = 21;
   WINDOW_GRADEWINDOW = 22;

   AGREE_GUILDMAKE    = 0;

   DRAGACTION_NONE              = 0;
   DRAGACTION_DROPITEM          = 2;
   DRAGACTION_ADDEXCHANGEITEM   = 15;

   DRAGACTION_FROMITEMTOLOG     = 16;
   DRAGACTION_FROMLOGTOITEM     = 17;

   CM_IPADDR          = 251;

   CM_NONE            =  0;
   CM_CLOSE           =  1;
   CM_VERSION         =  2;
   CM_IDPASS          =  3;
   CM_CREATEIDPASS    =  4;
   CM_CHANGEPASSWORD  =  5;
   CM_CREATECHAR      =  6;
   CM_DELETECHAR      =  7;
   CM_SELECTCHAR      =  8;
   CM_SOUND           =  9;
   CM_TURN            = 10;
   CM_MOVE            = 11;
   CM_SAY             = 12;
   CM_HIT             = 13;
   CM_PICKUP          = 14;
   CM_KEYDOWN         = 19;
   CM_CLICK           = 20;
   CM_DBLCLICK        = 21;
   CM_DRAGDROP        = 22;
   CM_CLICKPERCENT    = 23;
   CM_CREATEIDPASS2   = 24;
   CM_IDPASSAZACOM    = 25;
   CM_INPUTSTRING     = 26;
   CM_SELECTCOUNT     = 27;
   CM_CANCELEXCHANGE  = 28;
   CM_MOUSEEVENT      = 29;
   CM_WINDOWCONFIRM   = 30;
   CM_CHECK           = 31;
   CM_MAKEGUILDDATA   = 32;
   CM_GUILDINFODATA   = 33;
   CM_AGREEDATA       = 34;
   CM_MAKEGUILDMAGIC  = 35;
   CM_NETSTATE        = 36;
   CM_CREATEIDPASS3   = 37;

   DB_CHECKCONNECT     = 1;
   DB_STRING           = 2;
   DB_CHECKCONNECT_OK  = 3;
   DB_USERFIELDS       = 4;

   HAVEITEMMAXCOUNT     = 3;

   RAINTYPE_RAIN        = 0;
   RAINTYPE_SNOW        = 1;

   NPCFT_NONE           = 0;
   NPCFT_SELL           = 1;
   NPCFT_BUY            = 2;
   NPCFT_DEAL           = 3;
   NPCFT_SAY            = 4;
   NPCFT_HELP           = 5;
   NPCFT_QUEST          = 6;

   NPCFT_GUILDWAR       = 7;

type

   TEffectData = record
     rWavNumber : integer;
     rPercent : integer; // 100분율
   end;
   PTEffectData = ^TEffectData;

   TDbkey = record
     rmsg : byte;
     rconid: integer;
     rkey : word;
   end;
   PTDbKey = ^TDbKey;

   TDbString = record
     rmsg : byte;
     rconid: integer;
     rWordString : TWordString;
   end;
   PTDbString = ^TDbString;

   TNameString = array [0..NAME_SIZE-1] of byte;       // 한글 9글자

   TLightDark = (gld_light, gld_dark);
   TFeatureState = (wfs_normal, wfs_care, wfs_sitdown, wfs_die, wfs_running, wfs_running2);
   THiddenState = (hs_100, hs_0, hs_1, hs_99 );
   TActionState = (as_free, as_ice, as_slow );
   TLightEffectKind = ( lek_none, lek_follow, lek_future ); 

   TFeature = record
     rrace: byte;                     // 사람, 아이템, 동물,
     raninumber: byte;
     rfeaturestate : TFeatureState;          // 0 = normal, 1 = fight, 2 = die
     rboman : Boolean;
     rhitmotion : byte;
     rArr : array [0..31] of byte;    // 사람구성 짝수 이미지 홀수 색상   >> 머리카락, 몸, ...
     rImageNumber : word;             // 동물이나, 아이템일경우.
     rImageColorIndex : byte;         // 몬스터 색상
     rTeamColor: word;                // 길드 색상
     rNameColor: word;                // 이름 색상
     rHideState : THiddenState;
     rActionState : TActionState;
     rEffectNumber : word;
     rEffectKind : TLightEffectKind;
   end;

   TBasicData = record
     P : Pointer;
     id : longint;
     Feature : TFeature;
     dir, x, y, nx, ny: word;
     Name : TNameString;
     ViewName : TNameString;
     Guild: TNameString;
     ClassKind : Byte;
     LifePercent : Byte;
     GuardX : array [0..10 - 1] of ShortInt;
     GuardY : array [0..10 - 1] of ShortInt;
   end;
   PTBasicData = ^TBasicData;

   TLifeData = record
     damageBody : integer;
     damageHead : integer;
     damageArm : integer;
     damageLeg : integer;
     armorBody : integer;
     armorHead : integer;
     armorArm : integer;
     armorLeg : integer;
     AttackSpeed : integer;
     avoid : integer;
     recovery : integer;
     HitArmor : Integer;
   end;

   THitData = record
      damageBody: integer;
      damageHead: integer;
      damageArm : integer;
      damageLeg : integer;
      ToHit : integer;
      HitType : integer;
      HitLevel : integer;
      boHited : Boolean;
      HitedCount : integer;
      HitFunction : integer;
      HitFunctionSkill : integer;
   end;

   TItemData = record
     rName, rViewName : TNameString;

     rSoundEvent : TEffectData;
     rSoundDrop : TEffectData;

     rNeedGrade : integer;
     rcolor : byte;
     rKind : byte;
     rWearArr : byte;
     rWearShape : byte;
     rHitMotion : byte;
     rHitType : byte;

     rLifeData : TLifeData;

     rDurability : integer;
     rCurDurability : integer;
     
     rPrice : integer;
     rCount : integer;
     rShape : word;
     rActionImage : Word;
     rboDouble : Boolean;
     rboColoring : Boolean;
     rSex: integer;
     rNameParam : array [0..2 - 1] of String [20];
     rServerId : integer;
     rx, ry: integer;

     rOwnerRace : Byte;
     rOwnerServerID : Integer;
     rOwnerName : array [0..20 - 1] of byte;
     rOwnerIP : array [0..20 - 1] of byte;
     rOwnerX, rOwnerY : Integer;
   end;
   PTItemdata = ^TItemData;

   TAtomItem = record
      rItemName: String[64];
      rItemCount : Integer;
      rColor : Integer;
   end;
   TCheckSkill = record
      rName : String[64];
      rLevel : Integer;
   end;
   TCheckItem = record
      rName : String[64];
      rCount : Integer;
   end;

   TDynamicObjectData = record
     rName : String[64];
     rViewName : String [20];
     rKind : Byte;
     rShape : Word;
     rLife : Integer;
     rSStep : array [0..3 - 1] of Byte;
     rEStep : array [0..3 - 1] of Byte;
     rSoundEvent : TEffectData;
     rSoundSpecial : TEffectData;
     rGuardX : array [0..10 - 1] of ShortInt;
     rGuardY : array [0..10 - 1] of ShortInt;
     rEventItem : TCheckItem;
     rEventDropItem : TCheckItem;
     rEventSay : String [64];
     rEventAnswer : String [64];
     rboRemove : Boolean;
     rOpennedInterval : Integer;
     rRegenInterval : Integer;
   end;
   PTDynamicObjectData = ^TDynamicObjectData;

   TCreateDynamicObjectData = record
      rBasicData : TDynamicObjectData;
      {
      rState : Integer;
      rRegenInterval : Integer;
      rLife : Integer;
      }
      rNeedAge : Integer;
      rNeedSkill : array[0..5 - 1] of TCheckSkill;
      rNeedItem : array[0..5 - 1] of TCheckItem;
      rGiveItem : array[0..5 - 1] of TCheckItem;
      rDropItem : array[0..5 - 1] of TCheckItem;
      rDropMop : array[0..5 - 1] of TCheckItem;
      rCallNpc : array[0..5 - 1] of TCheckItem;

      rServerId : integer;
      rX, rY: array[0..5] of Integer;
      rDropX, rDropY : Word;
   end;
   PTCreateDynamicObjectData = ^TCreateDynamicObjectData;

   TItemDrugData = record
     rName : TNameString;
     rUsedCount : integer;
     rEventEnergy : integer;        // 때리거나 맞거나 등등의 이벤트때 소비되는양.
     rEventInPower: integer;
     rEventOutPower: integer;
     rEventMagic : integer;
     rEventLife : integer;
     rEventHeadLife : integer;
     rEventArmLife : integer;
     rEventLegLife : integer;
   end;
   PTItemDrugdata = ^TItemDrugData;

   TMagicData = record
     rname : TNameString;
     rGuildMagictype : byte;
     rBowImage : integer;
     rBowSpeed : integer;
     rBowType : Byte;
     // rPercent : integer;
     rShape : integer;
     rMagicType : integer;
     rFunction: byte;

     rSkillExp : integer;
     rcSkillLevel : integer;

     rGoodChar : integer;
     rBadChar : integer;

     rLifeData : TLifeData;
{
     rArmorHead : integer;
     rArmorBody : integer;
     rArmorArm : integer;
     rArmorLeg : integer;
     rDamageHead : integer;
     rDamageBody : integer;
     rDamageArm : integer;
     rDamageLeg : integer;

     ravoid : integer;
     rrecovery : integer;
     rAttackSpeed : integer;
}
     rcLifeData : TLifeData;

     rEventDecEnergy : integer;        // 때리거나 맞거나 등등의 이벤트때 소비되는양.
     rEventDecInPower: integer;
     rEventDecOutPower: integer;
     rEventDecMagic : integer;
     rEventDecLife : integer;

     r5SecDecEnergy : integer;         // 유지할때 5초마다 주는 양
     r5SecDecInPower: integer;
     r5SecDecOutPower: integer;
     r5SecDecMagic : integer;
     r5SecDecLife : integer;

     rEventBreathngEnergy : integer;
     rEventBreathngInPower : integer;
     rEventBreathngOutPower : integer;
     rEventBreathngMagic : integer;
     rEventBreathngLife : integer;

     rKeepEnergy : integer;            // 해지 되지 안을 최소양.
     rKeepInPower: integer;
     rKeepOutPower: integer;
     rKeepMagic : integer;
     rKeepLife : integer;

     rMagicProcessTick : integer;

     rSoundStrike : TEffectData;
     rSoundSwing : TEffectData;
     rSoundStart : TEffectData;
     rSoundEvent : TEffectData;
     rSoundEnd : TEffectData;
   end;
   PTMagicData = ^TMagicData;

   TMagicParamData = record
      ObjectName : String [20];
      MagicName : String [20];
      NameParam : array [0..5 - 1] of String [20];
      NumberParam : array [0..5 - 1] of Integer;
   end;
   PTMagicParamData = ^TMagicParamData;

   TMonsterData = record
     rName : TNameString;
     rViewName : TNameString;
     rSoundNormal : TEffectData;
     rSoundAttack : TEffectData;
     rSoundDie : TEffectData;
     rSoundStructed : TEffectData;

     rAttackName: TNameString;
     rIdleName: TNameString;

     rAnimate : integer;
     rWalkSpeed : integer;
     rdamage : integer;
     rAttackSpeed : integer;
     ravoid : integer;
     rrecovery : integer;
     rspendlife : integer;
     rarmor : integer;
     rHitArmor : Integer;
     rLife : integer;
     rShape: integer;

     rboViewHuman : Boolean;
     rboAutoAttack : Boolean;
     rboAttack : Boolean;
     rEscapeLife : integer;
     rViewWidth : integer;
     rboChangeTarget: Boolean;
     rboBoss: Boolean;
     rboVassal: Boolean;
     rVassalCount: integer;
     rHaveItem : array [0..5 - 1] of TCheckItem;
     rAttackMagic : TMagicData;
     rHaveMagic : String [64];
   end;
   PTMonsterData = ^TMonsterData;

   TNpcData = record                         
     rName : TNameString;
     rViewName : TNameString;
     rAnimate : integer;
     rShape: integer;
     rdamage : integer;
     rAttackSpeed : integer;
     ravoid : integer;
     rrecovery : integer;
     rspendlife : integer;
     rarmor : integer;
     rHitArmor : Integer;
     rLife : integer;
     rboSeller: Boolean;
     rboProtecter: Boolean;
     rboAutoAttack : Boolean;
     rActionWidth : integer;
     rHaveItem : array[0..5] of TCheckItem;

     rSoundNormal : TEffectData;
     rSoundAttack : TEffectData;
     rSoundDie : TEffectData;
     rSoundStructed : TEffectData;

     rNpcText: array [0..64] of byte;
   end;
   PTNpcData = ^TNpcData;

   {
   TNpcData = record
     rname : TNameString;
     rdamage : integer;
     rAttackSpeed : integer;
     ravoid : integer;
     rrecovery : integer;
     rspendlife : integer;
     rarmor : integer;
     rLife : integer;
     rboMan : Boolean;
     rboSeller: Boolean;
     rboProtecter: Boolean;
     rActionWidth : integer;
     rNpcText: TNameString;
     rItemDataArr : array [0..10] of TItemData;
   end;
   PTNpcData = ^TNpcData;
   }
   
   TLifeObjectState = (los_init, los_exit, los_none, los_die, los_escape,
                       los_Attack, los_moveattack, los_deadattack,
                       los_follow, los_stop, los_rest, los_movework,
                       los_eat, los_move, los_kill );

   TExpData = record
      Exp : integer;
      ExpType : integer;
   end;

   TSubData = record
     TargetId : integer;
     VassalCount: integer; // 자신이 사용하게되면 줄어듬...
     ServerId : integer;
     tx, ty: integer;
     ItemData : TItemData;
     HitData : THitData;
     ExpData : TExpData;
     motion : integer;
     percent : byte;
     sysopscope: integer;
     attacker : integer;
     BowImage : integer;
     BowSpeed : integer;
     BowType : Byte;
     SubName: TNameString;
     GuildName : TNameString;
     SayString : TWordString;
     ShoutColor : integer;
   end;

   TCurAttribData = record
     CurEnergy : integer;        // 원기
     CurInPower : integer;       // 내공
     CurOutPower: integer;       // 외공
     CurMagic : integer;         // 무공
     CurLife : integer;          // 활력

     CurHealth : integer;
     CurSatiety : integer;
     CurPoisoning : integer;
     CurHeadSeak : integer;
     CurArmSeak : integer;
     CurLegSeak : integer;
   end;

   TAttribData = record
      Age, cAge : integer;
      Light, cLight : integer;
      Dark, cDark : integer;
      Energy, cEnergy : integer;
      InPower, cInPower: integer;
      OutPower, cOutPower: integer;
      Magic, cMagic: integer;
      Life, cLife: integer;

      cHeadSeak: integer;
      cArmSeak: integer;
      cLegSeak: integer;

      cHealth: integer;
      cSatiety: integer;
      cPoisoning: integer;

      Talent, cTalent : integer;
      GoodChar, cGoodChar : integer;
      BadChar, cBadChar  : integer;
      lucky, clucky    : integer;
      adaptive, cadaptive : integer;      // 적응
      Revival, cRevival : integer;
      immunity, cimmunity : integer;
      virtue, cvirtue   : integer;      // 호연지기
   end;

   TExChangeItem = record
      rIcon: word;
      rItemName : string[64];
      rItemViewName : String [64];
      rItemCount : integer;
      rColor : integer;
      rkey : word;
   end;

   TExChangeData = record
      rExChangeId : LongInt;
      rExChangeName : string [32];
      rboCheck : boolean;
      rItems : array [0..3] of TExChangeItem;
   end;
   PTExChangeData = ^TExChangeData;

   TPosByDieData = record
      rServerID : Integer;
      rDestServerID : Integer;
      rDestX, rDestY : Word;
   end;
   PTPosByDieData = ^TPosByDieData;

   // 문파대전 버전
   {
   TCreateMonsterData = record
      Name : string[64];
      x, y  : Integer;
      Width : Integer;
      Count : integer;
      Member : String;
      Interval : integer;
      DurationLifeTick : integer;
   end;
   PTCreateMonsterData = ^TCreateMonsterData;

   TCreateNpcData = record
      Name : String [20];
      MapID : Integer;
      X, Y  : Integer;
      Width : Integer;
      RegenInterval : Integer;
      FuncNo : Integer;
      BookName : String [64];
   end;
   PTCreateNpcData = ^TCreateNpcData;
   }

   // 2001.5.31 버전
   TCreateMonsterData = record
      mName : string[64];
      Index : integer;
      x, y  : integer;
      Width, CurCount, Count : integer;
      Member : String[64];
      Interval : integer;
      DurationLifeTick : integer;
   end;
   PTCreateMonsterData = ^TCreateMonsterData;

   TCreateNpcData = record
      mName : string[64];
      Index : integer;
      x, y  : integer;
      Width, CurCount, Count : integer;
      Interval : Integer;
      DurationLifeTick : integer;
      BookName : String[64];
   end;
   PTCreateNpcData = ^TCreateNpcData;

   TAreaClassData = record
      Name : String [32];
      Index : Byte;
      Func : String [64];
      Desc : String [128];
   end;
   PTAreaClassData = ^TAreaClassData;

   TCreateGateData = record
      Name : string [64];
      ViewName : String [20];
      MapID : Integer;
      X, Y : integer;
      TargetX, TargetY: integer;
      EjectX, EjectY : integer;
      targetserverid : integer;
      Kind : Byte;
      shape : integer;
      Interval : integer;
      DurationLifeTick : integer;
      Width : Integer;
      NeedAge : Integer;
      AgeNeedItem : Integer;
      NeedItem : array[0..5] of TCheckItem;
      Quest : Integer;
      QuestNotice : String[128];
      RegenInterval : Integer;
      ActiveInterval : Integer;
      EjectNotice : String[128];
      RandomPosCount : Byte;
      RandomX : array [0..10 - 1] of Word;
      RandomY : array [0..10 - 1] of Word;
   end;
   PTCreateGateData = ^TCreateGateData;

   TCreateMirrorData = record
      Name : String [32];
      X, Y, MapID : Integer;
      boActive : Boolean;
   end;
   PTCreateMirrorData = ^TCreateMirrorData;

   TCreateDoorData = record
      Name : String [20];
      DoorName : String [20];
      Shape : Integer;
      MapID, X, Y : Word;
      TMapID, TX, TY : Word;
      Width : Integer;
      NeedAge : Integer;
      NeedItem : String [64];
      NeedQuest : Integer;
      NeedGuild : String [64];
      RegenInterval : Integer;
      ActiveInterval : Integer;
   end;
   PTCreateDoorData = ^TCreateDoorData;

   TGuildNpcData = record
     rName: string [20];
     rX, rY : Integer;
     rSex : Byte;
   end;
   PTGuildNpcData = ^TGuildNpcData;

   TCreateGuildData = record
     Name : string [20];
     Title : String [80];
     MapID : Integer;
     x, y  : integer;
     Durability : Integer;
     MaxDurability : Integer;
     GuildMagic : string [20];
     MagicExp : integer;
     MakeDate : string [20];
     Sysop : string [20];
     SubSysop : array [0..3 - 1] of string [20];
     GuildNpc : array [0..5 - 1] of TGuildNpcData;
     GuildWear : array [0..2 - 1] of TAtomItem;
     BasicPoint, AwardPoint : Integer;
     BattleRejectCount : Word;
     ChallengeGuild : String [20];
     ChallengeGuildUser : String [20];
     ChallengeDate : String [20];
   end;
   PTCreateGuildData = ^TCreateGuildData;

   TMakeGuildData = record
      GuildName : String [20];
      Sysop : String [20];
      AgreeChar : array [0..9 - 1] of String [20];
      boAgree : array [0..9 - 1] of Boolean;
   end;
   PTMakeGuildData = ^TMakeGuildData;

   TSpecialWindowSt = record
      rWindow : Byte;
      rAgreeType : Byte;
      rSenderID : Integer;
   end;
   PTSpecialWindowSt = ^TSpecialWindowSt;

   TNpcFunctionData = record
      Index : Integer;
      FuncType : Byte;
      Text : String [32];
      FileName : String [64];
      StartQuest, NextQuest : Integer;
   end;
   PTNpcFunctionData = ^TNpcFunctionData;

   {
   TCreateGateData = record
      mName : string[64];
      index : integer;
      x, y : integer;
      targetx, targety: integer;
      EjectX, EjectY : integer;
      targetserverid : integer;
      shape : integer;
      Interval : integer;
      DurationLifeTick : integer;
      Width : Integer;
      NeedAge : Integer;
      AgeNeedItem : Integer;
      NeedItem : array[0..5] of TCheckItem;
      Quest : Integer;
      QuestNotice : String [128];
      RegenInterval : Integer;
      ActiveInterval : Integer;
      EjectNotice : String [128];
   end;
   PTCreateGateData = ^TCreateGateData;
   }

   TCreateAreaData = record
      mName : string[64];
      ServerID : Integer;
      X, Y : integer;
      TargetServerID : Integer;
      TargetX, TargetY : Integer;
      Width : Integer;
   end;
   PTCreateAreaData = ^TCreateAreaData;

   TItemGenData = record
      Name : String [20];
      
      ItemName : String [20];
      ItemCount : Integer;

      CreateInterval : Integer;
      RegenInterval : Integer;

      ItemCreateX, ItemCreateY, ItemCreateW : Word;
      ItemRegenX, ItemRegenY, ItemRegenW : Word;
   end;
   PTItemGenData = ^TItemGenData;

   TCreateSoundObjData = record
      Name : String [20];
      SoundName : String [20];
      MapID : Integer;
      X, Y : Word;
      PlayInterval : Integer;
   end;
   PTCreateSoundObjData = ^TCreateSoundObjData;

   {
   TGuildNpcData = record
     rName: string [64];
     rIndex : Integer;
     rX, rY : Integer;
   end;
   PTGuildNpcData = ^TGuildNpcData;

   TCreateGuildData = record
     mName : string [64];
     index : integer;
     x, y  : integer;
     Sysop : string [64];
     SubSysop0, SubSysop1, SubSysop2: string [64];
     Durability : integer;
     GuildMagic : string [64];
     MakeDate : string [64];
     MagicExp : integer;
     GuildNpcDataArr : array [0..5-1] of TGuildNpcData;
   end;
   PTCreateGuildData = ^TCreateGuildData;
   }

///////////////////////////////////
//        Server Structure       //
///////////////////////////////////
   TSExChange = record
      rmsg : byte;
      rIcons : Array [0..8-1] of word;
      rColors : Array [0..8-1] of byte;
      rCheckLeft, rCheckRight: Boolean;
      rWordString: TWordString;   // left name, right name, item name ,,,,
   end;
   PTSExChange = ^TSExChange;

   TSShowInputString = record
      rmsg : byte;
      rInputStringid : LongInt;
      rWordString: TWordString;    // CaptionString, ListString,,,,
   end;
   PTSShowInputString = ^TSShowInputString;

   TSShowSpecialWindow = record
      rMsg : Byte;
      rWindow : Byte;
      rCaption : TNameString;
      rWordString: TWordString;
   end;
   PTSShowSpecialWindow = ^TSShowSpecialWindow;

   // saset
   TSHideSpecialWindow = record
      rMsg : Byte;
      rWindow : Byte;
   end;
   PTSHideSpecialWindow = ^TSHideSpecialWindow;

   TSShowMakeGuildWindow = record
      rMsg : Byte;
      rWindow : Byte;
      rSysopName : String [20];
   end;
   PTSShowMakeGuildWindow = ^TSShowMakeGuildWindow;

   TSShowGuildInfoWindow = record
      rMsg : Byte;
      rWindow : Byte;
      rboEdit : Byte; // if 1 for sysop else for others 
      rGuildName : String [20];
      rGuildX, rGuildY : Word;
      rCreateDate : String [20];
      rSysop : String [20];
      rSubSysop : array [0..3 - 1] of String [20];
      rGuildNpc : array [0..5 - 1] of String [20];
      rGuildNpcX, rGuildNpcY : array [0..5 - 1] of Word;
      rGuildTitle : String [80];
      rGuildMagic : String [20];
      rGuildAward : String [20];
      rGuildDura : Integer;
   end;
   PTSShowGuildInfoWindow = ^TSShowGuildInfoWindow;

   TSShowGuildWarWindow = record
      rMsg : Byte;
      rWindow : Byte;
   end;
   PTSShowGuildWarWindow = ^TSShowGuildWarWindow;

   TSShowGuildMagicWindow = record
      rMsg : Byte;
      rWindow : Byte;
      rSpeed, rDamageBody : Word;                              // 100
      rRecovery, rAvoid : Word;                                // 100
      rDamageHead, rDamageArm, rDamageLeg : Word;
      rArmorBody, rArmorHead, rArmorArm, rArmorLeg : Word;     // 228
      rOutPower, rInPower, rMagicPower, rLife : Word;          // 80
   end;
   PTSShowGuildMagicWindow = ^TSShowGuildMagicWindow;

   TCGuildMagicData = record
      rMsg : Byte;
      rWindow : Byte;
      rMagicName : String [20];
      rMagicType : Byte;   // MAGICTYPE_WRESTLING, MAGICTYPE_FENCING, MAGICTYPE_SWORDSHIP,
                           // MAGICTYPE_HAMMERING, MAGICTYPE_SPEARING
      rSpeed, rDamageBody : Word;                              // 100
      rRecovery, rAvoid : Word;                                // 100
      rDamageHead, rDamageArm, rDamageLeg : Word;
      rArmorBody, rArmorHead, rArmorArm, rArmorLeg : Word;     // 228
      rOutPower, rInPower, rMagicPower, rLife : Word;          // 80
   end;
   PTCGuildMagicData = ^TCGuildMagicData;

   TSShowBattleBar = record
      rMsg : Byte;
      rWinType : Byte;   // 1 : 구슬1개 (1판) 2 : 2개 (3판) 3 : 3개 (5판)
      rLeftName : array [0..60 - 1] of Char;
      rLeftWin : Byte;
      rLeftPercent : Byte;
      rRightName : array [0..60 - 1] of Char;
      rRightWin : Byte;
      rRightPercent : Byte;
   end;
   PTSShowBattleBar = ^TSShowBattleBar;

   TSShowCenterMsg = record
      rMsg : Byte;
      rColor : Word;
      rText : TWordString;
   end;
   PTSShowCenterMsg = ^TSShowCenterMsg;

   TSCount = record
      rmsg : byte;
      rCountid  : LongInt;
      rsourkey : word;
      rdestkey : word;
      rCountCur : LongInt;
      rCountMax : LongInt;
      rCountName: TWordString;
   end;
   PTSCount = ^TSCount;

   TCSelectCount = record
      rmsg : byte;
      rboOk : Boolean;
      rsourkey : word;
      rdestkey : word;
      rCountid  : LongInt;
      rCount : LongInt;
   end;
   PTCSelectCount = ^TCSelectCount;

   TCInputString = record
      rmsg : byte;
      rInputStringId : LongInt;
      rSelectedList : TNameString;
      rInputString : TWordString;
   end;
   PTCInputString = ^TCInputString;

   TSReConnect = record
      rmsg : byte;
      rId : TNameString;
      rPass : TNameString;
      rCharName : TNameString;    // LendName
      rIpAddr : TNameString;      // addr
      rPort : integer;            // port
   end;
   PTSReConnect = ^TSReConnect;

   TSConnectThru = record
      rMsg : Byte;
      rIpAddr : TNameString;
      rPort : Integer;
   end;
   PTSConnectThru = ^TSConnectThru;

   TSRainning = record
      rmsg : byte;
      rspeed: integer;
      rCount: integer;
      rOverray: integer;
      rTick: integer;
      rRainType : byte;
   end;
   PTSRainning = ^TSRainning;

   TSMessage = record
      rmsg : byte;
      rkey : word;
      rWordString : TWordString;
   end;
   PTSMessage = ^TSMessage;

   TSWindow = record
      rmsg : byte;
      rwindow : byte;
      rboShow : Boolean;
   end;
   PTSWindow = ^TSWindow;

   TSNewMap = record
      rmsg : byte;
      rMapName : TNameString;
      rCharName : TNameString;
      rId : LongInt;
      rx, ry: word;
      rObjName : TNameString;
      rTilName : TNameString;
      rRofName : TNameString;
   end;
   PTSNewMap = ^TSNewMap;

   TSShow = record
      rmsg : byte;
      rId : LongInt;
      rNameString: array [0..60 - 1] of byte;
      rdir, rx, ry: word;
      rFeature: TFeature;
      rWordString : TWordString;
   end;
   PTSShow = ^TSShow;

   // AniItem 010102 ankudo
   TDynamicObjectState = (dos_Closed, dos_Openning, dos_Openned, dos_Scroll);
   TSShowDynamicObject = record
      rmsg : byte;
      rId : LongInt;
      rNameString: TNameString;
      rx, ry: word;
      rShape : word;
      rState : Byte;
      rFrameStart, rFrameEnd : Word;
      rGuardX : array [0..10 - 1] of ShortInt;
      rGuardY : array [0..10 - 1] of ShortInt;
   end;
   PTSShowDynamicObject = ^TSShowDynamicObject;

   TSShowItem = record
      rmsg : byte;
      rId : LongInt;
      rNameString: TNameString;
      rx, ry: word;
      rshape : word;
      rcolor: byte;
      rRace : byte;
   end;
   PTSShowItem = ^TSShowItem;

   TSShowMonster = record
      rmsg : byte;
      rId : LongInt;
      rNameString: TNameString;
      rdir, rx, ry: word;
      rshape : word;
      rcolor: byte;
   end;
   PTSShowMonster = ^TSShowMonster;

   TSHide = record
      rmsg : byte;
      rId : LongInt;
   end;
   PTSHide = ^TSHide;

   TSTurn = record
      rmsg : byte;
      rId : LongInt;
      rdir, rx, ry: word;
   end;
   PTSTurn = ^TSTurn;

   TSMove = record
      rmsg : byte;
      rId : LongInt;
      rdir, rx, ry: word;
   end;
   PTSMove = ^TSMove;

   TSSay = record
      rmsg : byte;
      rId : LongInt;
      rkind : byte;
      rWordString: TWordString;
   end;
   PTSSay = ^TSSay;

   TSChatMessage = record
      rmsg : byte;
      rFColor: word;
      rBColor: word;
      rWordString : TWordString;
   end;
   PTSChatMessage = ^TSChatMessage;

   TSChangeFeature = record
      rmsg : byte;
      rId : LongInt;
      rFeature: TFeature;
   end;
   PTSChangeFeature = ^TSChangeFeature;

   TSChangeState = record
      rmsg : byte;
      rId : LongInt;
      rState : byte;
      rFrameStart, rFrameEnd : Word;
   end;
   PTSChangeState = ^TSChangeState;

   TSChangeProperty = record
      rmsg : byte;
      rId : LongInt;
      rNameString: TNameString;
   end;
   PTSChangeProperty = ^TSChangeProperty;

   TSHaveItem = record
      rmsg : byte;
      rkey : byte;
      rName : TNameString;
      rCount : word;
      rColor: byte;
      rShape: word;
   end;
   PTSHaveItem = ^TSHaveItem;

   TSWearItem = record
      rmsg : byte;
      rkey : byte;
      rName : TNameString;
      rColor: byte;
      rShape: word;
   end;
   PTSWearItem = ^TSWearItem;

   TSHaveMagic = record
      rmsg : byte;
      rkey : byte;
      rShape: word;
      rName : TNameString;
      rSkillLevel : word;
      rpercent : byte;
   end;
   PTSHaveMagic = ^TSHaveMagic;

   TSAttribBase = record
      rmsg    : byte;
      rAge    : word;
      rCurEnergy, rEnergy : word;
      rCurInPower, rInPower : word;
      rCurOutPower, rOutPower : word;
      rCurMagic, rMagic : word;
      rCurLife, rLife   : word;
   end;
   PTSAttribBase = ^TSAttribBase;

   TSAttribValues = record
      rmsg      : byte;
      rLight    : word;
      rDark     : word;
      rMagic    : word;
      rtalent   : word;
      rGoodChar : word;
      rBadChar  : word;
      rlucky    : word;
      radaptive : word;      // 적응
      rRevival  : word;      // 재생
      rimmunity : word;
      rvirtue   : word;      // 호연지기

      rhealth    : word;
      rsatiety   : word;
      rpoisoning : word;
      rheadseak  : word;
      rarmseak   : word;
      rlegseak   : word;
   end;
   PTSAttribValues = ^TSAttribValues;
   
   TSAttribFightBasic = record
      rmsg      : byte;
      rWordString : TWordString;
   end;
   PTSAttribFightBasic = ^TSAttribFightBasic;

   TSAttribLife = record
      rmsg : byte;
      rcurLife : word;
   end;
   PTSAttribLife = ^TSAttribLife;

   TSEventString = record
      rmsg : byte;
      rWordString: TWordString;
   end;
   PTSEventString = ^TSEventString;

   TSStructed = record
      rmsg : byte;
      rId : LongInt;
      rRace : Byte;
      rpercent : Byte;
   end;
   PTSStructed = ^TSStructed;

   TSMovingMagic = record
      rmsg : byte;
      rsid, reid : LongInt;            // 쏜사람   , 맞은사람
      rtx, rty : word;                 // 도착지 (맞은사람이 없을경우)
      rMoveingStyle: byte;             // 날라가는 모양
      rsf, rmf, ref: byte;             // 시작 날라감 도착시 모양
      rspeed : byte;                   // 속도
      rafterimage : byte;              // 잔상
      rafterover : byte;               // 잔상 오버레이
      rtype : byte;                    // 0 : default, 1 : 백귀야행술
    end;
   PTSMovingMagic = ^TSMovingMagic;

   TSSoundString = record
      rmsg : byte;
      rHiByte, rLoByte : byte;
      rSoundName : array[0..12] of byte;
      rX, rY : Word;
   end;
   PTSSoundString = ^TSSoundString;

   TSSoundBaseString = record
      rmsg : byte;
      rRoopCount : word;
      rWordString: TWordString;
   end;
   PTSSoundBaseString = ^TSSoundBaseString;

   TSHaveWearItem = record
      rmsg : byte;
      rkey : byte;
      rName : TNameString;
      rColor: byte;
      rShape: word;
   end;
   PTSHaveWearItem = ^TSHaveWearItem;

   TSAttribHeader = record
      rmsg : byte;
      rTrade : TNameString;
      rlevel : byte;
      rexperience : LongInt;
      rnextexperience : LongInt;
      rMoney : Longint;
   end;
   PTSAttribHeader = ^TSAttribHeader;

   TSAttribTail = record
      rmsg : byte;
      rWordString: TWordString;
   end;
   PTSAttribTail = ^TSAttribTail;

   TSAttribMana = record
      rmsg : byte;
      rcurMana : word;
   end;
   PTSAttribMana = ^TSAttribMana;

   TSAttribMoney = record
      rmsg : byte;
      rMoney : LongInt;
   end;
   PTSAttribMoney = ^TSAttribMoney;

   TSAttribExperience = record
      rmsg : byte;
      rExperience : LongInt;
   end;
   PTSAttribExperience = ^TSAttribExperience;

   TSAttribStem = record
      rmsg : byte;
      rcurStem : word;
   end;
   PTSAttribStem = ^TSAttribStem;

   TSSetTilAndObj = record
      rmsg : byte;
      rWordString : TWordString;
   end;
   PTSSetTilAndObj = ^TSSetTilAndObj;

   TSHaveItemInfo = record
      rmsg : byte;
      rkey : byte;
      rShape : word;
      rkind : byte;
      rWordString : TWordString;
   end;
   PTSHaveItemInfo = ^TSHaveItemInfo;

   TSHaveMagicInfo = record
      rmsg : byte;
      rkey : byte;
      rtype : byte;
      rLevel : byte;
      rShape : integer;
      rWordString : TWordString;
   end;
   PTSHaveMagicInfo = ^TSHaveMagicInfo;

   TSMotion = record
      rmsg : byte;
      rId : LongInt;
      rmotion : word;
   end;
   PTSMotion = ^TSMotion;

   TSEffect = record
      rmsg : byte;
      rId : LongInt;
      reffect : byte;
   end;
   PTSEffect = ^TSEffect;

   TSHit = record
      rmsg : byte;
      rid : LongInt;
      rdir : word;
   end;
   PTSHit = ^TSHit;

   TSMagic = record
      rmsg : byte;
      rid : LongInt;
      rdir : word;
   end;
   PTSMagic = ^TSMagic;

   TSMenu = record
      rmsg : byte;
      rid  : LongInt;
      rn : byte;
      rtitlecolor: word;
      rselectcolor :word;
      rdisplaytime : word;
      rIcons : array [0..32-1] of word;
      rMenuTitle : TNameString;
      rWordString: TWordString;
   end;
   PTSMenu = ^TSMenu;

   TSSetPosition = record
      rmsg : byte;
      rid : LongInt;
      rdir : word;
      rx : word;
      ry : word;
   end;
   PTSSetPosition = ^TSSetPosition;

   TSSendDelay = record
      rmsg : byte;
      rsenddelay: word;
   end;
   PTSSendDelay = ^TSSendDelay;

   TSScrollText = record
      rmsg : byte;
      rWordString: TWordString;
   end;
   PTSScrollText = ^TSScrollText;

   TSReEnterAddress = record
      rmsg : byte;
      rWordString: TWordString;
   end;
   PTSReEnterAddress = ^TSReEnterAddress;

   TSLogItem = record
      rmsg : byte;
      rkey : byte;
      rName : TNameString;
      rCount : word;
      rColor: byte;
      rShape: word;
   end;
   PTSLogItem = ^TSLogItem;

   TSCheck = record
      rMsg : Byte;
      rCheck : Byte; // 1이면 맵파일 체크, 2면 클라이언트 Tick 체크
   end;
   PTSCheck = ^TSCheck;

   TWordInfoString = record
      rmsg : byte;
      rWordString: TWordString;
   end;
   PTWordInfoString = ^TWordInfoString;

///////////////////////////////////
//        Client Structure       //
///////////////////////////////////

   TCKey = record
      rmsg : byte;
      rkey : word;
   end;
   PTCKey = ^TCKey;

   TCVer = record
      rmsg : byte;
      rVer : word;
      rNation : word;
   end;
   PTCVer = ^TCVer;

   TCIdPass = record
      rmsg : byte;
      rId : TNameString;
      rPass : TNameString;
   end;
   PTCIdPass = ^TCIdPass;

   TCIdPassAzacom = record
      rmsg : byte;
      rId : TNameString;
      rPass : TNameString;
      rAzaComid : TNameString;
   end;
   PTCIdPassAzaCom = ^TCIdPassAzaCom;

   TCCreateIdPass = record
      rmsg : byte;
      rid : TNameString;
      rPass : TNameString;
      rName : TNameString;
      rTelephone : TNameString;
      rBirth : TNameString;
   end;
   PTCCreateIdPass = ^TCCreateIdPass;

   TCCreateIdPass2 = record
      rmsg : byte;
      rid : TNameString;
      rPass : TNameString;
      rName : TNameString;
      rMasterKey : TNameString;
      rNativeNumber : TNameString;
   end;
   PTCCreateIdPass2 = ^TCCreateIdPass2;

   TCCreateIdPass3 = record
      rMsg : Byte;
      rID : String [12];
      rPass : String [12];
      rName : String [12];
      rNativeNumber : String [15];
      rMasterKey : String [12];
      rEmail : String [32];
      rPhone : String [15];
      rParentName : String [12];
      rParentNativeNumber : String [15];
   end;
   PTCCreateIDPass3 = ^TCCreateIDPass3;

   TCChangePassWord = record
      rmsg : byte;
      rNewPass : TNameString;
   end;
   PTCChangePassWord = ^TCChangePassWord;

   TCCreateChar = record
      rmsg : byte;
      rchar : TNameString;
      rSex : byte;
      rVillage : TNameString;
      rServer : TNameString;
   end;
   PTCCreateChar = ^TCCreateChar;

   TCDeleteChar = record
      rmsg : byte;
      rchar : TNameString;
   end;
   PTCDeleteChar = ^TCDeleteChar;

   TCSelectChar = record
      rmsg : byte;
      rchar : TNameString;
   end;
   PTCSelectChar = ^TCSelectChar;

   TCSay = record
      rmsg : byte;
      rWordString : TWordString;
   end;
   PTCSay = ^TCSay;

   TCMove = record
      rmsg : byte;
      rdir : word;
      rx, ry : word;
   end;
   PTCMove = ^TCMove;

   TCClick = record
      rmsg : byte;
      rwindow : byte;
      rShift : TShiftState;
      rclickedId : LongInt;
      rkey : word;
   end;
   PTCClick = ^TCClick;

   TCDragDrop = record
      rmsg : byte;
      rsourwindow : byte;
      rdestwindow : byte;
      rsourId : LongInt;
      rdestId : LongInt;
      rsx, rsy : word;
      rdx, rdy : word;
      rsourkey : word;
      rdestkey : word;
   end;
   PTCDragDrop = ^TCDragDrop;

   TCHit = record
      rmsg : byte;
      rkey : word;
      rtid : integer;
      rtx, rty: word;
   end;
   PTCHit = ^TCHit;

   TCWindowConfirm = record
      rMsg : Byte;
      rWindow : Word;
      rboCheck : Boolean;
      rButton : Byte;
      rText : String [30];
   end;
   PTCWindowConfirm = ^TCWindowConfirm;

   TCGiveItem = record
      rmsg: byte;
      rkey : word;
      rid : LongInt;
   end;
   PTCGiveItem = ^TCGiveItem;

   TCChangeItem = record
      rmsg : byte;
      rfir, rsec : word;
   end;
   PTCChangeItem = ^TCChangeItem;

   TCChangeMagic = record
      rmsg : byte;
      rfir, rsec : word;
   end;
   PTCChangeMagic = ^TCChangeMagic;

   TCMouseEvent = record
     rmsg : byte;
     revent: array [0..10-1] of integer;
   end;
   PTCMouseEvent = ^TCMouseEvent;

   TCCheck = record
      rMsg : Byte;
      rCheck : Byte;
      rTick : Integer;
      // rCheck가 1이면 rTick = 0 (맵파일없음) or 1 (맵파일있음)
      // rCheck가 2이면 rTick = timeGetTime();
   end;
   PTCCheck = ^TCCheck;

   TCMakeGuildData = record
      rMsg : Byte;
      rGuildName : String [20];
      rSubSysop : array [0..3 - 1] of String [20];
      rAgreeChar : array [0..6 - 1] of String [20];
   end;
   PTCMakeGuildData = ^TCMakeGuildData;

   TCGuildInfoData = record
      rMsg : Byte;
      rGuildName : String [20];
      rGuildX, rGuildY : Word;
      rCreateDate : String [20];
      rSysop : String [20];
      rSubSysop : array [0..3 - 1] of String [20];
      rGuildNpc : array [0..5 - 1] of String [20];
      rGuildNpcX, rGuildNpcY : array [0..5 - 1] of Word;
      rGuildTitle : String [80];
      rGuildMagic : String [20];
      rGuildAward : String [20];
      rGuildDura : Integer;
      rGuildWear1 : String [40];
      rGuildWear2 : String [40];
   end;
   PTCGuildInfoData = ^TCGuildInfoData;

   TCGuildWarData = record
      rMsg : Byte;
      rWGName : String [20];
      rWGSysop : String [20];
      rTime : Byte;
   end;
   PTCGuildWarData = ^TCGuildWarData;

   TSNetState = record
      rMsg : Byte;
      rID : Integer;
      rMadeTick : Integer;
   end;
   PTSNetState = ^TSNetState;

   TCNetState = record
      rMsg : Byte;
      rID : Integer;
      rMadeTick : Integer;
      rCurTick : Integer;
   end;
   PTCNetState = ^TCNetState;


/////////    FSSockM SocketFunction    //////////////

   TSocketSendFunction = procedure (cnt:integer; pb:pbyte) of object;


   // LoginDb Type
   TGMGuildData = record
      rmsg : byte;
      rGuildId: integer;
      rboAllow : Boolean;
      rGuildName: string[20];
      rSysopName: string [20];
   end;
   PTGMGuildData = ^TGMGuildData;

   TGMData = record
      rmsg : byte;
      rLogInId: string[20];
      rLogInPass: string[20];
      rCharName: string[20];
      rWordString : TWordString;
   end;
   PTGMData = ^TGMData;

   TLeaveData = record
      reventTick : integer;
      rboSendSaveAndClose : Boolean;
      GMD : TGMData;
   end;
   PTLeaveData = ^TLeaveData;

///////////////    udp type   ////////////////

  TStringData = record
    rmsg : byte;
    rWordString : TWordString;
  end;
  PTStringData = ^TStringData;

const
   PM_NONE         = 0;
   PM_CHECKPAID    = 1;
   PM_CHECKRESULT  = 2;
   PM_CHECKPAID2    = 3;

type
  TPDData = record
    rmsg : byte;
    rConId : integer;
    rLoginId : string[20];
    rIpaddr : string[20];
    rRemainDay : integer;
    rboTimePay : Boolean;
    rSenderPort : integer;
  end;
  PTPDData = ^TPDData;

  TPDData2 = record
    rmsg : byte;
    rConId : integer;
    rLoginId : string[20];
    rIpaddr : string[20];
    rRemainDay : integer;
    rboTimePay : Boolean;
    rSenderPort : integer;
    rMakeDate : string[20];
  end;
  PTPDData2 = ^TPDData2;


////////////////////////////////////
// Game Server and Notice Server
////////////////////////////////////
const
   GNM_NONE             = 0;
   GNM_INUSER           = 1;
   GNM_OUTUSER          = 2;
   GNM_ALLCLEAR         = 3;

   NGM_NONE             = 0;
   NGM_REQUESTCLOSE     = 1;
   NGM_REQUESTALLUSER   = 2;

   // Login Server Message
   LG_INSERT            =   0;
   LG_SELECT            =   1;
   LG_DELETE            =   2;
   LG_UPDATE            =   3;

   // DB Server Message
   DB_INSERT            =   0;
   DB_SELECT            =   1;
   DB_DELETE            =   2;
   DB_UPDATE            =   3;
   DB_LOCK              =   4;
   DB_UNLOCK            =   5;
   DB_CONNECTTYPE       =   6;
   DB_ITEMSELECT        =   7;
   DB_ITEMUPDATE        =   8;

   // Game Server Message
   GM_CONNECT           =   0;
   GM_DISCONNECT        =   1;
   GM_SENDUSERDATA      =   2;
   GM_SENDGAMEDATA      =   3;
   GM_DUPLICATE         =   4;
   GM_SENDALL           =   5;
   GM_UNIQUEVALUE       =   6;

   // Balance Server Message
   BM_GATEINFO          =   0;

   DB_OK                =   0;
   DB_ERR               =   1;
   DB_ERR_NOTFOUND      =   2;
   DB_ERR_DUPLICATE     =   3;
   DB_ERR_IO            =   4;
   DB_ERR_INVALIDDATA   =   5;
   DB_ERR_NOTENOUGHSPACE =  6;

type
   TConnectInfo = record
      RemoteIP : String;
      RemotePort : Integer;
      LocalPort : Integer;
   end;

   TPaidType = ( pt_none, pt_invalidate, pt_validate, pt_test, pt_timepay, pt_namemoney, pt_nametime, pt_ipmoney, pt_iptime );

   TPaidData = record
      rLoginId : String [20];
      rIpAddr : String [20];
      rRemainDay : Integer;
      rMakeDate : String [20];
      rPaidType : TPaidType;
      rCode : Byte;
   end;
   PTPaidData = ^TPaidData;

   TNoticeData = record
      rMsg : Byte;
      rLoginID : String [20];
      rCharName : String [20];
      rIpAddr : String [20];
      rPaidType : TPaidType;
      rCode : Byte;
   end;
   PTNoticeData = ^TNoticeData;

   TBalanceData = record
      rMsg : Byte;
      rIpAddr : array [0..20 - 1] of char;
      rPort : Integer;
      rUserCount : Integer;
   end;
   PTBalanceData = ^TBalanceData;

   TComData = record
      Size : Integer;
      Data : array [0..4096 - 1] of Byte;
   end;
   PTComData = ^TComData;

   TWordComData = record
      Size : Word;
      Data : array [0..4096 - 1] of Byte;
   end;
   PTWordComData = ^TWordComData; 

implementation

end.

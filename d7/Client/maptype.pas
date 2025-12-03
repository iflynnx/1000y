unit MapType;

interface

uses Windows;

const

   MAP_BLOCK_SIZE = 40;

type
   TMapCell = record
     TileId : word;
     TileNumber : byte;
     TileOverId : word;
     TileOverNumber : byte;
     ObjectId : word;
     ObjectNumber : byte;
     RoofId : word;
     boMove : byte;
   end;
   PTMapCell = ^TMapCell;

  TMapFileInfo = record
    MapIdent : array [0..15] of char;
    MapBlockSize : integer;
    MapWidth : integer;
    MapHeight : integer;
  end;

  TMapBlockData = record
    MapBlockIdent : array [0..15] of char;
    MapChangedCount : Integer;
    MapBufferArr : array [0..MAP_BLOCK_SIZE * MAP_BLOCK_SIZE -1 ] of TMapCell;
  end;
  PTMapBlockData = ^TMapBlockData;

implementation

end.

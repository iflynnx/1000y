unit clmap;

interface

uses Windows, Sysutils, Classes,
     Objcls, TileCls, A2Img, Autil32, maptype, backscrn, cltype,
     deftype, Log, dialogs;

const
   VIEWWIDTH = 11;
   VIEWHEIGHT = 8;

type
  TMap = class
  private
   CurMap : integer;
   MapFileName : string;
   MapWidth, MapHeight : Integer;
   MapLeft, MapTop : integer;
   MapBuffer : array [0..MAP_BLOCK_SIZE*MAP_BLOCK_SIZE*9-1] of TMapCell;
   MapCellTickBuffer : array [0..MAP_BLOCK_SIZE*MAP_BLOCK_SIZE*9-1] of integer;

   procedure  LoadBlockFromFile(afilename:string;axb, ayb, txb, tyb:integer);
   procedure  SetMapBlock (xb, yb:integer; MapBlockData: TMapBlockData);
  public
   Cx, Cy : Integer;
   procedure  SetCell (x, y: integer; MapCell: TMapCell);
   function   GetCell (x, y: integer) : TMapCell;

   procedure  SetMapCellTick (x, y: integer; CurTick: integer);
   function   GetMapCellTick (x, y: integer) : integer;

	constructor Create;
  	destructor Destroy; override;
   procedure  SetCenter ( x, y: integer);
   procedure  LoadFromFile (aFileName: String; ax, ay:integer);
   procedure  DrawMap(CurTick: integer);
   procedure  DrawRoof(CurTick: integer);
   function   isMovable ( x, y: Integer) : Boolean;
   function   isFlyable ( x, y: Integer) : Boolean;
   function   IsInArea ( x, y: integer):Boolean;

   function   GetMapWidth: integer;
   function   GetMapHeight : integer;
   function   GetMapName : string;
  end;

var
   Map : TMap;

implementation

constructor TMap.Create;
begin
   CurMap := 0;
   MapFileName := '';
   Cx := 12; Cy := 12;
   MapWidth := 100; MapHeight := 100;
   MapLeft := 0; MapTop := 0;
end;

destructor TMap.Destroy;
begin
   inherited Destroy;
end;

function  TMap.GetCell (x, y: integer) : TMapCell;
begin
   FillChar (Result, sizeof(Result), 0);
   if ((x-MapLeft) < 0) or ((x-MapLeft) >= MAP_BLOCK_SIZE*3) then exit;
   if ((y-MapTop) < 0) or ((y-MapTop) >= MAP_BLOCK_SIZE*3) then exit;

   if (x < 0) or (x >= MapWidth) or (y < 0) or (y >= MapHeight) then exit;
   Result := MapBuffer[ (x-mapleft) + (y-maptop) * MAP_BLOCK_SIZE * 3];
end;

procedure TMap.SetCell (x, y: integer; MapCell: TMapCell);
begin
   if ((x-MapLeft) < 0) or ((x-MapLeft) >= MAP_BLOCK_SIZE*3) then exit;
   if ((y-MapTop) < 0) or ((y-MapTop) >= MAP_BLOCK_SIZE*3) then exit;

   if (x < 0) or (x >= MapWidth) or (y < 0) or (y >= MapHeight) then exit;
   MapBuffer[ (x-mapleft) + (y-maptop) * MAP_BLOCK_SIZE * 3] := MapCell;
end;

function  TMap.GetMapCellTick (x, y: integer) : integer;
begin
   FillChar (Result, sizeof(Result), 0);
   if ((x-MapLeft) < 0) or ((x-MapLeft) >= MAP_BLOCK_SIZE*3) then exit;
   if ((y-MapTop) < 0) or ((y-MapTop) >= MAP_BLOCK_SIZE*3) then exit;

   if (x < 0) or (x >= MapWidth) or (y < 0) or (y >= MapHeight) then exit;
   Result := MapCellTickBuffer[ (x-mapleft) + (y-maptop) * MAP_BLOCK_SIZE * 3];
end;

procedure TMap.SetMapCellTick (x, y: integer; CurTick : integer);
begin
   if ((x-MapLeft) < 0) or ((x-MapLeft) >= MAP_BLOCK_SIZE*3) then exit;
   if ((y-MapTop) < 0) or ((y-MapTop) >= MAP_BLOCK_SIZE*3) then exit;

   if (x < 0) or (x >= MapWidth) or (y < 0) or (y >= MapHeight) then exit;
   MapCellTickBuffer[ (x-mapleft) + (y-maptop) * MAP_BLOCK_SIZE * 3] := CurTick;
end;

function   TMap.isMovable ( x, y: Integer) : Boolean;
var MapCell : TMapCell;
begin
   Result := TRUE;
   if (x < 0 ) or (y < 0) or (x >= MapWidth) or (y >= MapHeight) then begin Result := FALSE; exit; end;
   MapCell := GetCell (x, y);
   if (MapCell.boMove and 1 <> 0) or (MapCell.boMove and 2 <> 0) then Result := FALSE;
end;

function   TMap.isFlyable ( x, y: Integer) : Boolean;
var MapCell : TMapCell;
begin
   Result := TRUE;
   if (x < 0 ) or (y < 0) or (x >= MapWidth) or (y >= MapHeight) then begin Result := FALSE; exit; end;
   MapCell := GetCell (x, y);
   if (MapCell.boMove and 2 <> 0) then Result := FALSE;
end;

procedure  TMap.SetCenter ( x, y: integer);
var
   flag : boolean;
begin
   flag := FALSE;
   Cx := x; Cy := y;

   if ((Cx div 40)-1) <> (MapLeft div 40) then flag := TRUE;
   if ((Cy div 40)-1) <> (MapTop div 40) then flag := TRUE;

   if flag then LoadFromFile (MapFileName, x, y);
end;

procedure  TMap.DrawMap (CurTick: integer);
var
   i, j: integer;
   MapCell : TMapCell;
begin
   for j := Cy-VIEWHEIGHT-1 to Cy+VIEWHEIGHT+1 do begin
      for i := Cx-VIEWWIDTH to Cx+VIEWWIDTH do begin
         MapCell := GetCell (i, j);
         with MapCell do begin
            if TileId <> 0 then begin
               if TileId > TILE_MAX_COUNT then continue;
               BackScreen.DrawImage ( TileDataList.GetTileImage (TileId, TileNumber, CurTick), i*UNITX, j*UNITY, FALSE);
            end else
               BackScreen.DrawImage ( TileDataList.GetTileImage (0, 0, CurTick), i*UNITX, j*UNITY, FALSE);
            if TileOverId <> 0 then begin
               if TileOverId > TILE_MAX_COUNT then continue;
               BackScreen.DrawImage ( TileDataList.GetTileImage (TileOverId, TileOverNumber, CurTick), i*UNITX, j*UNITY, TRUE);
            end;
         end;
      end;
   end;
end;

procedure  TMap.DrawRoof(CurTick: integer);
var
   i, j: integer;
   MapCell : TMapCell;
begin
   for j := Cy+VIEWHEIGHT-1+16 downto Cy-VIEWHEIGHT-1 do begin
      for i := Cx-VIEWWIDTH to Cx+VIEWWIDTH do begin
         MapCell := GetCell (i, j);
         if MapCell.RoofId <> 0 then
            BackScreen.DrawImage ( RoofDataList.GetObjectImage (MapCell.RoofId, 0, CurTick), i*UNITX, j*UNITY, TRUE);
      end;
   end;
end;

function  TMap.IsInArea (x, y: integer):Boolean;
var MapCell : TMapCell;
begin
   MapCell := GetCell (x, y);
   if MapCell.boMove and 4 = 4 then Result := TRUE
   else Result := FALSE;
end;

procedure TMap.SetMapBlock (xb, yb:integer; MapBlockData: TMapBlockData);
var i, xp, yp : integer;
begin
   for i := 0 to MAP_BLOCK_SIZE -1 do begin
      xp := xb * MAP_BLOCK_SIZE;
      yp := yb * MAP_BLOCK_SIZE;
      yp := yp + i;
      move (MapBlockData.MapBufferArr[i*MAP_BLOCK_SIZE], MapBuffer [xp + yp * MAP_BLOCK_SIZE*3], sizeof(TMapCell) * MAP_BLOCK_SIZE);
   end;
end;

procedure  TMap.LoadBlockFromFile (afilename:string; axb, ayb, txb, tyb:integer);
var
   n : integer;
   flag : Boolean;
//   Stream : TFileStream;
   fh : integer;
   MapBlockdata : TMapBlockData;
begin
   if FileExists (aFileName) = FALSE then begin
//      ShowMessage ('운영자에게 연락하시기 바랍니다. [MAP FEITBlock FALSE]');
      exit;
   end;
   if (txb < 0) or (txb >= 3) or (tyb < 0) or (tyb >= 3) then exit;

   flag := TRUE;
   if (axb < 0) or (axb >= MapWidth div 40) or (ayb < 0) or (ayb >= MapHeight div 40) then flag := FALSE;

   if flag then begin
      n := sizeof(TMapFileInfo) + sizeof(MapBlockData) * (axb + ayb * (MapWidth div 40));
      fh := 0;
      try
         fh := FileOpen (aFileName, fmOpenRead);
         FileSeek (fh, n, 0);
         FileRead (fh, MapBlockData, sizeof(MapBlockData));
         FileClose (fh);
      except
         FillChar (MapBlockData, sizeof(MapBlockData), 0);
         if fh <> 0 then FileClose (fh);
      end;
{
      Stream := TFileStream.Create (aFileName, fmOpenRead);
      Stream.Seek (n, 0);
      Stream.ReadBuffer (MapBlockData, sizeof(MapBlockData));
      Stream.Free;
}
   end else begin
      FillChar (MapBlockData, sizeof(MapBlockData), 0);
   end;

   SetMapBlock (txb, tyb, MapBlockData);
end;

procedure  TMap.LoadFromFile (aFileName: String; ax, ay:integer);
var
   i, j, xb, yb : integer;
   fh : integer;
//   Stream : TFileStream;
   MapInfo : TMapFileInfo;
begin
   if FileExists (aFileName) = FALSE then begin
//      ShowMessage ('운영자에게 연락하시기 바랍니다. [MAP FEIT FALSE]');
      exit;
   end;

   MapFilename := afilename;
{
   Stream := TFileStream.Create (aFileName, fmOpenRead);
   Stream.ReadBuffer (MapInfo, sizeof(MapInfo));
   if StrLIComp(PChar('ATZMAP2'), MapInfo.MapIdent, 8) <> 0 then
      raise Exception.Create('Not a valid Image Library File');
   Stream.Free;
}
   fh := 0;
   try // ankudo
      fh := FileOpen (aFileName, fmOpenRead);
      FileRead (fh, MapInfo, sizeof(MapInfo));
      if StrLIComp(PChar('ATZMAP2'), MapInfo.MapIdent, 8) <> 0 then
         raise Exception.Create('Not a valid Image Library File');
      FileClose (fh);
      MapWidth := MapInfo.MapWidth;
      MapHeight := MapInfo.MapHeight;

      Fillchar (MapBuffer, sizeof(MapBuffer), 0);
      Fillchar (MapCellTickBuffer, sizeof(MapCellTickBuffer), 0);

      xb := ax div MAP_BLOCK_SIZE;
      yb := ay div MAP_BLOCK_SIZE;

      MapLeft := xb * 40-40;
      MapTop := yb * 40-40;

      for j := 0 to 3-1 do begin
         for i := 0 to 3-1 do begin
            LoadBlockFromFile (aFileName, xb-1+i, yb-1+j, i, j);
         end;
      end;
   except
      if fh <> 0 then FileClose (fh);
      MapFilename := '';
      raise exception.Create ('Map ERROR');
   end;
end;

function   TMap.GetMapWidth: integer;
begin
   Result := MapWidth;
end;

function   TMap.GetMapHeight : integer;
begin
   Result := MapHeight;
end;

function   TMap.GetMapName : string;
begin
   Result := LowerCase(MapFileName);
end;

end.

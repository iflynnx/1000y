unit cltype;

interface

uses Controls;

const
   UNITX = 32;
   UNITY = 24;

   UNITXS = 16;
   UNITYS = 12;
type
  TAniInfo = record
     Action : Integer;
     Direction : Integer;
     Frame : Integer;
     FrameTime: Integer;
     Frames : array [0..26-1] of Integer;
     Pxs : array [0..26-1] of Integer;
     Pys : array [0..26-1] of Integer;
  end;
  PTAniInfo = ^TAniInfo;

  TDragItem = class (TDragObject)
    Selected: integer;
    Dragedid: integer;
    StdMode: byte;
    SourceID: Integer;
    sx, sy : word;
  end;

var
  MouseInfoStr : string = '';

//  AnsSocketHandle : integer = 0; 사용안함
  DragItem: TDragItem;

implementation

initialization
begin
   DragItem := TDragItem.Create;
end;

finalization
begin
   DragItem.Free;
end;



end.

unit uSpool;

interface

uses
   Classes, SysUtils, uKeyClass;

type
   TSpool = class
   private
      KeyList : TStringKeyClass;
      DataList : TList;

      function GetData (Index : Integer) : Pointer;
      function GetCount : Integer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      function Get (aKey : String) : Pointer;
      function Put (aKey : String; aData : Pointer; aSize : Integer) : boolean;
      function Erase (aKey : String) : boolean;

      function GetKey (Index : Integer) : String; 

      property Count : Integer read GetCount;
      property Items[Index : Integer] : Pointer read GetData;
   end;

implementation

constructor TSpool.Create;
begin
   KeyList := TStringKeyClass.Create;
   DataList := TList.Create;
end;

destructor TSpool.Destroy;
begin
   Clear;
   KeyList.Free;
   DataList.Free;

   inherited Destroy;
end;

function TSpool.GetData (Index : Integer) : Pointer;
begin
   Result := nil;
   if Index >= DataList.Count then exit;

   Result := DataList.Items [Index];
end;

function TSpool.GetKey (Index : Integer) : String;
begin
   Result := KeyList.GetKey (Index);
end;

function TSpool.GetCount : Integer;
begin
   Result := DataList.Count;
end;

procedure TSpool.Clear;
var
   i : Integer;
   Data : Pointer;
begin
   KeyList.Clear;
   for i := 0 to DataList.Count - 1 do begin
      Data := DataList.Items [i];
      FreeMem (Data);
   end;
   DataList.Clear;
end;

function TSpool.Get (aKey : String) : Pointer;
var
   nPos : Integer;
begin
   Result := nil;

   nPos := KeyList.Select (aKey);
   if nPos < 0 then exit;

   if nPos >= DataList.Count then exit;
   
   Result := DataList.Items [nPos];
end;

function TSpool.Put (aKey : String; aData : Pointer; aSize : Integer) : boolean;
var
   nPos : Integer;
   Data : Pointer;
begin
   Result := false;

   if aSize <= 0 then exit;

   nPos := KeyList.Select (aKey);
   if nPos < 0 then begin
      GetMem (Data, aSize);
      Move (aData^, Data^, aSize);
      KeyList.Add (aKey, DataList.Count);
      DataList.Add (Data);
   end else begin
      if nPos >= DataList.Count then exit;
      Data := DataList.Items [nPos];
      Move (aData^, Data^, aSize);
   end;

   Result := true;
end;

function TSpool.Erase (aKey : String) : boolean;
var
   nPos : Integer;
   Data : Pointer;
begin
   Result := false;

   nPos := KeyList.Select (aKey);
   if nPos <= 0 then exit;
   if nPos >= DataList.Count then exit;

   Data := DataList.Items [nPos];
   FreeMem (Data);

   DataList.Delete (nPos);

   Result := true;
end;

end.

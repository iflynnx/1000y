unit uCSVProvider;

interface

uses
   Classes, SysUtils;

type
   TCSVProvider = class
   private
      FieldList : TStringList;
      DataList : TStringList;

      function GetRecordCount : Integer;
      function GetFieldCount : Integer;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      function AddField (aFieldName : String) : Boolean;
      function DeleteField (aFieldName : String) : Boolean;

      function AddRecord (aName, aStr : String) : Boolean;
      function DeleteRecord (aName) : Boolean;
      function UpdateRecord (aName, aStr : String) : Boolean;

      function LoadFromFile (aFileName : String) : Boolean;
      function SaveToFile (aFileName : String) : Boolean;

      function GetFieldValueInteger (aName, aField : String) : Integer;
      function GetFieldValueString (aName, aField : String) : String;
      function GetFieldValueBoolean (aName, aField : String) : Boolean;

      procedure SetFieldValueInteger (aName, aField : String; aValue : Integer);
      procedure SetFieldValueString (aName, aField, aValue : String);
      procedure SetFieldValueBoolean (aName, aField : String; aValue : Boolean);

      property RecordCount : Integer read GetRecordCount;
      property FieldCount : Integer read GetFieldCount;
   end;

   function GetTokenStr (aSS : String,var aSD : String, aSP : String) : String; 


implementation

function GetTokenStr (aSS : String,var aSD : String, aSP : String) : String;
begin
   
end;

constructor TCSVProvider.Create;
begin
   FieldList := TStringList.Create;
   DataList := TStringList.Create;
end;

destructor TCSVProvider.Destroy;
begin
   FieldList.Clear;
   DataList.Clear;
   FieldList.Free;
   DataList.Free;
   inherited Destroy;
end;

procedure TCSVProvider.Clear;
begin
   FieldList.Clear;
   DataList.Clear;
end;

function TCSVProvider.AddField (aFieldName : String) : Boolean;
begin
   Result := false;
   FieldList.Add (aFieldName);
   Result := true;
end;

function TCSVProvider.DeleteField (aFieldName : String) : Boolean;
var
   i : Integer;
begin
   Result := false;
   for i := 0 to FieldList.Count - 1 do begin
      if aFieldName = FieldList.Strings[i] then begin
         FieldList.Delete (i);
         Result := true;
         exit;
      end;
   end;
end;

function TCSVProvider.GetRecordCount : Integer;
begin
   Result := DataList.Count;
end;

function TCSVProvider.GetFieldCount : Integer;
begin
   Result := FieldList.Count;
end;

function TCSVProvider.AddRecord (aName, aStr : String) : Boolean;
begin
   Result := false;
   DataList.Add (aStr);
   Result := true;
end;

function TCSVProvider.DeleteRecord (aName : String) : Boolean;
var
   i : Integer;
   ss, sd : String;
begin
   for i := 0 to DataList.Count - 1 do begin
      ss := DataList.Strings[i];
   end;
end;

function TCSVProvider.UpdateRecord (aName, aStr : String) : Boolean;
begin

end;

function TCSVProvider.LoadFromFile (aFileName : String) : Boolean;
begin

end;

function TCSVProvider.SaveToFile (aFileName : String) : Boolean;
begin

end;

function TCSVProvider.GetFieldValueInteger (aName, aField : String) : Integer;
begin

end;

function TCSVProvider.GetFieldValueString (aName, aField : String) : String;
begin

end;

function TCSVProvider.GetFieldValueBoolean (aName, aField : String) : Boolean;
begin

end;

procedure TCSVProvider.SetFieldValueInteger (aName, aField : String; aValue : Integer);
begin

end;

procedure TCSVProvider.SetFieldValueString (aName, aField, aValue : String);
begin

end;

procedure TCSVProvider.SetFieldValueBoolean (aName, aField : String; aValue : Boolean);
begin

end;

end.

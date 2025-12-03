unit uResidentRegistrationNumber;

interface

uses
   AUtil32, Sysutils;

function TrimChar (SourStr: string; value : char): String;
function checkResidentRegistrationNumber (aStr : string): Boolean;

implementation

function TrimChar (SourStr: string; value : char): String;
var
   i, n : integer;
   str : string;
begin
   str := SourStr;
   Result := '';
   n := Length (SourStr);
   for i := 1 to n do begin
      if str[i] <> value then Result := Result + str[i];
   end;
end;

function checkResidentRegistrationNumber (aStr : string): Boolean;
var
   i : integer;
   str : string;
begin
   Result := FALSE;
   str := TrimChar (aStr, '-');
   i := Length(str);
   if i <> 13 then exit;
   i := (_StrToInt(str[1])*2)+(_StrToInt(str[2])*3)+(_StrToInt(str[3])*4)
       +(_StrToInt(str[4])*5)+(_StrToInt(str[5])*6)+(_StrToInt(str[6])*7)
       +(_StrToInt(str[7])*8)+(_StrToInt(str[8])*9)+(_StrToInt(str[9])*2)
       +(_StrToInt(str[10])*3)+(_StrToInt(str[11])*4)+(_StrToInt(str[12])*5);
   i := 11 - (i mod 11);
   i := _StrToInt(Copy (IntToStr(i), Length(IntToStr(i)),1));
   if i = _StrToInt(str[13]) then Result := TRUE;
end;

end.

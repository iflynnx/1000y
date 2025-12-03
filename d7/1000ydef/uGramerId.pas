unit uGramerId;

interface

uses
	Windows, SysUtils, Classes, deftype, mmsystem;

   function  isGrammarID ( ID:string):Boolean;
   function  isFullHangul (str: string) : Boolean;

implementation

var
   FontTblBuf : array [0..65536] of byte;
   FontStream : TFileStream;


function isFullHangul (str: string) : Boolean;
var
   data1, data2: byte;
   cho, jung : byte;
//   jong: byte;
   i, len : integer;
   wd : word;
   pb : pbyte;
begin
   Result := TRUE;

   data2 := 0;

   i := 1;
   len := Length (str);

   while TRUE do begin
      if i > len then break;
      pb := @FontTblBuf;
      data1 := byte (str[i]);
      if data1 > 127 then begin
         if i+1 <= len then data2 := byte (str[i + 1]);
         wd := makeword ( data2, data1);
         wd := wd - $8100;
         inc (pb, wd*2);
         data1 := pb^; inc (pb);
         data2 := pb^;
         cho  := (data1 and 124) shr 2;
         jung := (data1 and 3) * 8 + (data2 shr 5);
//         jong := (data2 and 31);
         if cho = 1    then Result := FALSE;             // 초성없음.
         if jung = 2   then Result := FALSE;             // 중성없음
//         if jong = 255 then Result := FALSE;
         if cho > 20   then Result := FALSE;             // 특수문자
         if jung > 29  then Result := FALSE;             // 특수문자

         Inc (i);
      end else begin
      end;
      Inc (i);
   end;
end;

function isGrammarID (ID: string):Boolean;
var
   i : Integer;
   han : Boolean;
   wd : word;
begin
   Result := TRUE;
   han := FALSE;

   for i := 1 to Length(Id) do begin
      wd := word(Id[i]);

      if han then begin han := FALSE; continue; end;

      if (han=FALSE) and (wd > 127) then begin
         han := TRUE;
         continue;
      end;

      if ((word('0') <= wd) and (wd <= word('9'))) or
         ((word('A') <= wd) and (wd <= word('Z'))) or
         ((word('a') <= wd) and (wd <= word('z'))) then begin
      end else Result := FALSE;
   end;
end;


Initialization
begin
   FontStream := TFileStream.Create ('wintosan.tbl', fmOpenRead);
   FontStream.ReadBuffer(FontTblBuf,  65536);
   FontStream.Free;
end;

Finalization
begin

end;

end.

unit Log;

interface

uses
   Windows, SysUtils, Classes, Dialogs;

type

   // 게임 로그를 기록하기 위한 클래스
   TLog = class
   private
      AppName : String;    // Application 명
      FileName : String;   // 로그 파일명
      LogLevel : Integer;  // 로그레벨 0이면 기록하지 않음
      boFirst : Boolean;
   public
      constructor Create (aname, fname : String; level : Integer);
      destructor Destroy; override;

      procedure WriteLog(level : Integer; Str : String);

   end;

var
   LogObj : TLog;

implementation

constructor TLog.Create (aname, fname : String; level : Integer);
{
var
   Stream : TFileStream;
   flag : Boolean;
}
begin
   if level > 0 then ShowMessage ('log션쩌');
   AppName := aname;
   FileName := fname;
   LogLevel := level;
   boFirst := TRUE;
end;

destructor TLog.Destroy;
begin
   WriteLog(1, AppName + '써監션쩌');
   inherited Destroy;
end;

procedure TLog.WriteLog(level : Integer; Str : String);
var
   Stream : TFileStream;
   WritedStr : String;
   WritedArray : array[0..256] of Char;
begin
   if (LogLevel = 0) or (LogLevel < level) then Exit;

   if boFirst = TRUE then begin
      WritedStr := Format ('[%s] %s%s%s', [DateTimeToStr(Now), AppName + '역迦션쩌', Char(10), Char(13)]);
      StrPCopy (WritedArray, WritedStr);

      try
         DeleteFile(FileName);

         Stream := TFileStream.Create(FileName, fmCreate);
         Stream.Seek (0, soFromEnd);
         Stream.WriteBuffer (WritedArray, StrLen(WritedArray));
         Stream.Free;
      except
         on EFOpenError do;
         on EWriteError do;
      end;
      boFirst := FALSE;
   end;

   WritedStr := Format ('[%s] %s%s%s', [DateTimeToStr(Now), Str, Char(10), Char(13)]);
   StrPCopy (WritedArray, WritedStr);

   try
      Stream := TFileStream.Create(FileName, fmOpenReadWrite);
      Stream.Seek (0, soFromEnd);
      Stream.WriteBuffer (WritedArray, StrLen(WritedArray));
      Stream.Free;
   except
      on EFOpenError do;
      on EWriteError do;
   end;
end;

Initialization;
begin
   LogObj := TLog.Create('푤쾨', '1000Y.Log', 0);
end;

Finalization;
begin
   if LogObj <> nil then LogObj.Free;
end;

end.

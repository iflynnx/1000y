unit uProcess;

interface

uses
   Windows, MMSystem, Classes, SysUtils;

type
   TProcessThread = class (TThread)
   private
   protected
      procedure Execute; override;
   public
      constructor Create;
   end;

var
   ProcessThread : TProcessThread;

implementation

uses
   FMain, uConnector;

constructor TProcessThread.Create;
begin
   FreeOnTerminate := True;
   inherited Create (true);
end;

procedure TProcessThread.Execute;
var
   StartTick, CurTick : Integer;
   ElaspedSec : Integer;
begin
   ElaspedSec := 0;
   StartTick := timeGetTime;
   
   while not Terminated do begin
      CurTick := timeGetTime;

      ConnectorList.Update (CurTick);

      frmMain.Update (CurTick);

      if CurTick >= StartTick + 1000 then begin
         ElaspedSec := ElaspedSec + 1;
         frmMain.lblElaspedTime.Caption := IntToStr (ElaspedSec);
         StartTick := CurTick;
      end;
      Sleep (10);
   end;
   frmMain.AddLog ('Thread Exit');
end;

end.

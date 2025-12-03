unit dll_Sock;

interface

uses
   Windows, Graphics, ExtCtrls, log, Forms;

//type
//   TAnsSocketEvent = procedure (aeventstr: shortstring) of object;

   {
function  AllocAnsSocket : LongInt;
procedure FreeAnsSocket (aHandle: LongInt);
function  GetAnsSocketAllowSend (aHandle: LongInt): Boolean;
function  AnsSocketRead (aHandle: LongInt; pb: pbyte; acnt: integer): integer;
function  AnsSocketSend  (aHandle: LongInt; pb: pbyte; acnt: integer): integer;
function  AnsSocketUpDate (aHandle: LongInt): Boolean;
function  SetAnsSocketPort (aHandle: LongInt; aPort: integer): Boolean;
function  SetAnsSocketOnEvent  (aHandle: LongInt; AnsSocketEvent: TAnsSocketEvent): Boolean;
function  SetAnsSocketAddress (aHandle: LongInt; addr: ShortString): Boolean;
function  SetAnsSocketActive (aHandle: LongInt; aActive: Boolean): Boolean;

function  GetPictureBitmap (ahandle: integer): TBitmap;
procedure FreePicture  (ahandle: integer);
function  AllocPicture  (apicname: shortstring): integer;

procedure SetAnsUdpPort (aPort: integer);
procedure SendUdpData (aip, astr: shortstring);
procedure ReceiveUdpData (var astr: shortstring);
}

///////////////////////////////// ¿Œ∆˜º•øÎ /////////////////////////////////////
type
   TTimepayType = (Tpt_actoz, Tpt_timepay, Tpt_Close);

   TCheckNixConnect  = function : Boolean;
   TCheckParam       = function : Boolean;
   TKoreanCheckParam = function (apath : Pchar): Boolean;
   TcomparisonParam  = function : Boolean;
   TErrorMessage     = function : PChar;
   TParamConvert     = procedure (aParamStr : Pchar; Count : integer);
   TcheckCompany     = function : Boolean;
var
   CheckNixConnect : TCheckNixConnect;
   CheckParam : TCheckParam;
   KoreanCheckParam : TKoreanCheckParam;
   comparisonParam : TcomparisonParam;
   ErrorMessage : TErrorMessage;
   ParamConvert : TParamConvert;
   checkCompany : TcheckCompany;

   function Loadtimepay: Boolean;
   function CheckConnect : Boolean;
   function CheckTimePayed(apath : string) : TTimepayType;

implementation
{
//////////////////////////////// AnsSocket /////////////////////////////////////
function  AllocAnsSocket; external 'AnsCSock.dll' name 'AllocAnsSocket';
procedure FreeAnsSocket; external 'AnsCSock.dll' name 'FreeAnsSocket';
function  GetAnsSocketAllowSend; external 'AnsCSock.dll' name 'GetAnsSocketAllowSend';
function  AnsSocketRead; external 'AnsCSock.dll' name 'AnsSocketRead';
function  AnsSocketSend; external 'AnsCSock.dll' name 'AnsSocketSend';
function  AnsSocketUpDate; external 'AnsCSock.dll' name 'AnsSocketUpDate';
function  SetAnsSocketPort; external 'AnsCSock.dll' name 'SetAnsSocketPort';
function  SetAnsSocketOnEvent; external 'AnsCSock.dll' name 'SetAnsSocketOnEvent';
function  SetAnsSocketAddress; external 'AnsCSock.dll' name 'SetAnsSocketAddress';
function  SetAnsSocketActive; external 'AnsCSock.dll' name 'SetAnsSocketActive';

function  GetPictureBitmap; external 'AnsCSock.dll' name 'GetPictureBitmap';
procedure FreePicture; external 'AnsCSock.dll' name 'FreePicture';
function  AllocPicture; external 'AnsCSock.dll' name 'AllocPicture';

procedure SetAnsUdpPort; external 'AnsCSock.dll' name 'SetAnsUdpPort';
procedure SendUdpData; external 'AnsCSock.dll' name 'SendUdpData';
procedure ReceiveUdpData; external 'AnsCSock.dll' name 'ReceiveUdpData';
}

///////////////////////////////// ¿Œ∆˜º•øÎ /////////////////////////////////////
function CheckConnect : Boolean;
begin
   Result := CheckNixConnect;
end;

function CheckTimePayed(apath : string) : TTimepayType;
var
   path : string;
   ErrorMsg : string;
begin
   Result := Tpt_actoz;
   path := apath;

   if KoreanCheckParam(Pchar(path)) then begin       // µŒ∑Á≥›¿œ∞ÊøÏ∏∏ √º≈©
   end else begin
      ParamConvert (Pchar(path), ParamCount);         // ParamConvert±Ó¡ˆ«‘
   end;


   if not CheckParam then begin // param.dat∆ƒ¿œ¿Ã æ¯¿ª∞ÊøÏ ∞¢¿Œ∆˜º•¡§∫∏ ∫∏ø©¡÷∞Ì Ω««‡«œ¡ˆ æ ¿Ω
      Result := Tpt_Close;
      exit;
   end;

   if checkCompany then begin // ¿Œ∆˜º• »∏ªÁ√º≈©
      Result := Tpt_timepay;
      exit;
   end else begin
      ErrorMsg := ErrorMessage; // ¿Œ∆˜º•ø¨∞·¿Ã æ»µ  ø°∑Ø∏ﬁΩ√¡ˆ πﬁ¿Ω
      if ErrorMsg <> '' then begin
         if ErrorMsg = 'actoz' then begin
            exit;
         end;
         Application.MessageBox (Pchar(ErrorMsg), '”√ªß…Ì∑›»œ÷§', 0);
         sleep (500);
         Result := Tpt_Close;
         exit;
      end else begin
         Application.MessageBox ('“ª∏ˆŒ¥÷™¥ÌŒÛ,»œ÷§ ß∞‹.', '”√ªß…Ì∑›»œ÷§', 0);
         Result := Tpt_Close;
      end;
   end;
end;

var
  hlib : THandle = 0;

function Loadtimepay: Boolean;
begin
   hlib := LoadLibrary('TPDLL.dll');
   if hlib < 32 then begin
      Result := FALSE;
   end else begin
      CheckNixConnect := TCheckNixConnect (GetProcAddress (hlib,'CheckNixConnect'));
      CheckParam := TCheckParam (GetProcAddress (hlib,'CheckParam'));
      KoreanCheckParam := TKoreanCheckParam (GetProcAddress (hlib,'KoreanCheckParam'));
      comparisonParam := TcomparisonParam (GetProcAddress (hlib,'comparisonParam')); // ∞∞¡ˆæ ¿ª∞ÊøÏ TRUE;
      ErrorMessage := TErrorMessage (GetProcAddress (hlib,'ErrorMssage'));
      ParamConvert := TParamConvert (GetProcAddress (hlib,'ParamConvert'));
      checkCompany := TcheckCompany (GetProcAddress (hlib,'checkCompany'));
      Result := TRUE;
   end;
end;

Initialization
begin
end;

Finalization
begin
   if hlib >= 32 then begin
      FreeLibrary (hlib);
   end;
end;


end.

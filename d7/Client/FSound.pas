unit FSound;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, MMSystem, USound, StdCtrls, A2Form, ExtCtrls;

type
  TFrmSound = class(TForm)
    BtnOutcry: TA2Button;
    BtnGuild: TA2Button;
    BtnNotice: TA2Button;
    BtnNormal: TA2Button;
    Image1: TImage;
    Imgbaseup: TImage;
    ImgEffectup: TImage;
    Imgbasedown: TImage;
    ImgNormalup: TImage;
    ImgGuildup: TImage;
    ImgOutcryup: TImage;
    ImgNoticeup: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BaseVolumeChange;
    procedure oldBaseVolumeChange;

//    procedure SystemWaveSetVolume(SysVolume: Byte); // 시스템전체볼륨
//    function  SystemWaveGetVolume : byte;
    procedure BtnOutcryClick(Sender: TObject);
    procedure BtnGuildClick(Sender: TObject);
    procedure BtnNoticeClick(Sender: TObject);
    procedure BtnNormalClick(Sender: TObject);
    procedure ImgbaseupMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure ImgbaseupMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure ImgbaseupMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure ImgEffectupMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure ImgEffectupMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure ImgEffectupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    function  changeBaseVolume : Boolean;
    function  changeEffectVolume : integer;

//    function  changesysvolum: boolean;
  end;

var
  FrmSound: TFrmSound;
  BASEVOLUME : integer;  // 현재 안 사용중인 볼륨Value
  EFFECTVOLUME : Integer;

  OLDBASEVOLUME : integer; // 현재 사용중인 볼륨Value
  imgtemp : TBitmap;

const
  baseLeft = 25;
  baseRight = 125;

var
  Boolflag : Boolean;
  Or_baseX : integer;
  Or_sysX : integer;

implementation

uses FMain, FBottom;

{$R *.DFM}

function poscontrol(oMin, oMax, rLeft, rRight, ovalue, rvalue :integer): integer;
var
   otemp, rtemp : integer;
begin
   otemp := (oMax + oMin) - (oMin + oMin);
   rtemp := rright - rLeft;
   if ovalue = 0 then begin
      Result := ((rvalue - rLeft) * otemp) div rtemp;
      exit;
   end;
   if rvalue = 0 then begin
      Result := (((ovalue - OMin)* rtemp) div otemp) + rLeft;
      exit;
   end;
   Result := 0;
end;

//////////////////// FrmSound //////////////////////////////////////////////////
procedure TFrmSound.FormCreate(Sender: TObject);
begin
   Parent := FrmM;
   Color := clBlack;
   Left := 0; Top := 14;

   Boolflag := FALSE; // 사운드 마우스제어 Boolean
   imgtemp := TBitmap.Create;
   imgtemp.Assign (Imgbaseup.Picture.Bitmap);

   BASEVOLUME := -4000; // 배경음악 value
   EffectVolume := - 2000;
   OLDBASEVOLUME := 0;

   BASEVOLUME := FrmM.SoundManager.Volume;
   EffectVolume := FrmM.SoundManager.Volume2;
//   sysVolume := SystemWaveGetVolume; // 시스템볼륨을 얻어옴
//   Orginal_SysVolume := sysVolume;   // 시스템볼륨 저장
   if BASEVOLUME >= 0 then BASEVOLUME := -4000;
   if BASEVOLUME < -10000 then BASEVOLUME := -6000;
   if EffectVolume >= 0 then EffectVolume := -2000;
   if EffectVolume < -10000 then EffectVolume := -4000;

   Imgbaseup.Left := poscontrol (-10000, 0, baseLeft, baseright, BASEVOLUME, 0)-Imgbaseup.width;
   ImgEffectup.Left := poscontrol (-10000, 0, baseLeft, baseright, EffectVolume, 0)-ImgEffectup.Width;

   if Imgbaseup.Left <= baseLeft then Imgbaseup.Left := baseLeft;
   if Imgbaseup.Left >= baseRight then Imgbaseup.Left := baseRight-Imgbaseup.width;
   if ImgEffectup.Left <= baseLeft then ImgEffectup.Left := baseLeft;
   if ImgEffectup.Left >= baseRight then ImgEffectup.Left := baseRight-ImgEffectup.Width;
end;

procedure TFrmSound.FormDestroy(Sender: TObject);
begin
//   SystemWaveSetVolume(Orginal_SysVolume); // 원래의 시스템볼륨으로 복구
   imgtemp.Free;
end;

/////////////////// OPTION CHAT ////////////////////////////////////////////////

procedure TFrmSound.BtnOutcryClick(Sender: TObject);    // For FBottom
begin // 외치기
   if chat_outcry then begin
      chat_outcry := FALSE;
      BtnOutcry.UpImage := BtnOutcry.DownImage;
   end else begin
      chat_outcry := TRUE;
      BtnOutcry.UpImage := ImgOutcryup.Picture;
   end;
end;
procedure TFrmSound.BtnGuildClick(Sender: TObject);
begin // 길드
   if chat_Guild then begin
      chat_Guild := FALSE;
      BtnGuild.UpImage := BtnGuild.DownImage;
   end else begin
      chat_Guild := TRUE;
      BtnGuild.UpImage := ImgGuildup.Picture;
   end;
end;
procedure TFrmSound.BtnNoticeClick(Sender: TObject);
begin // 공지사항
   if chat_notice then begin
      chat_notice := FALSE;
      BtnNotice.UpImage := BtnNotice.DownImage;
   end else begin
      chat_notice := TRUE;
      BtnNotice.UpImage := ImgNoticeup.Picture;
   end;
end;
procedure TFrmSound.BtnNormalClick(Sender: TObject);
begin // 일반 유저대화
   if chat_normal then begin
      chat_normal := FALSE;
      BtnNormal.UpImage := BtnNormal.DownImage;
   end else begin
      chat_normal := TRUE;
      BtnNormal.UpImage := ImgNormalup.Picture;
   end;
end;

/////////////////// OPTION SOUND ///////////////////////////////////////////////
// BaseBolume Chnage
procedure TFrmSound.BaseVolumeChange;
begin
   if FrmM.SoundManager <> nil then FrmM.SoundManager.Volume :=  BASEVOLUME;
//   FrmM.BaseAudio.SetVolume (BASEVOLUME);
//   ClientIni.WriteInteger ('SOUND','BASEVOLUME', BASEVOLUME);
end;
// EffectVolumeChange
procedure TFrmSound.oldBaseVolumeChange; // 현재 사용중이지 않은 볼륨
begin
   if FrmM.SoundManager <> nil then FrmM.SoundManager.Volume2 := OLDBASEVOLUME;
end;

//////////////////////////////  systemVolumeChange  ////////////////////////////
{
procedure TFrmSound.SystemWaveSetVolume(SysVolume: Byte); // 시스템 볼륨 RESET
var Rvol : Byte;
begin
   RVol := SysVolume; // 0 ~ 255 사이값으로 조정;
   waveOutSetVolume (WAVE_MAPPER, Integer( ((SysVolume shl 8) or (RVol shl 24)) ));
end;

function TFrmSound.SystemWaveGetVolume : byte; // GET 시스템 볼륨 value
var temp, vol : Integer;
begin
   waveOutGetVolume(WAVE_MAPPER, @temp);
   vol := Hi( temp );
   Result := vol;
//   RVol := Vol shr 24;
end;
}
{
var
   Captured : Boolean = FALSE;
}
//////////////////////// base Mouse event //////////////////////////////////////
function TFrmSound.changeBaseVolume : boolean;
begin
   BASEVOLUME := -(105-Imgbaseup.Left)*50;
   if Imgbaseup.Left >= 110 then begin
      BASEVOLUME := 0;

   end else if Imgbaseup.Left <= 30 then begin
      BASEVOLUME := -10000;
   end;
   BaseVolumeChange;
   Result := TRUE;
end;

{
function TFrmSound.changeBaseVolume : Boolean;
var
   base : integer;
begin
   base := Imgbaseup.Left;
   if Imgbaseup.Left <= baseLeft then begin
      Imgbaseup.Left := baseLeft;
      base := - 400;
   end;
   if Imgbaseup.Left+Imgbaseup.Width >= baseright then begin
      Imgbaseup.Left := baseright - Imgbaseup.Width;
      base := baseright;
   end;
   BASEVOLUME := poscontrol (-3000, 0, baseLeft, baseright, 0, base);
   BASEVOLUME:= BASEVOLUME -3000;
   BaseVolumeChange;
   Result := TRUE;
end;
}
procedure TFrmSound.ImgbaseupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Boolflag := TRUE;
   Or_baseX := x;
   Imgbaseup.Picture.Assign(Imgbasedown.Picture.Bitmap);
//   SetCapture(Handle);
//   Captured := TRUE;
end;

procedure TFrmSound.ImgbaseupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if Boolflag then begin
      Imgbaseup.Left := Imgbaseup.Left - (Or_baseX - X);
      if Imgbaseup.Left < baseLeft then Imgbaseup.left := baseLeft;
      if Imgbaseup.Left+Imgbaseup.Width > baseright then
         Imgbaseup.Left := baseright - Imgbaseup.width;
      changeBaseVolume;
   end;
end;

procedure TFrmSound.ImgbaseupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Boolflag := FALSE;
   Imgbaseup.Picture.Assign(imgtemp);
//   ReleaseCapture;
//   Captured := FALSE;
end;
///////////////////////// sys Mouse event //////////////////////////////////////
function TFrmSound.changeEffectVolume: Integer;
begin
   Result := -(105-ImgEffectup.Left)*50;
   if ImgEffectup.Left >= 110 then begin
      Result := 0;

   end else if ImgEffectup.Left <= 30 then begin
      Result := -10000;
   end;
//   ClientIni.WriteInteger ('SOUND','EFFECTVOLUME', Result);
end;

{
function TFrmSound.changesysvolum: boolean;
var
   atemp, sys : integer;
begin
   sys := Imgsysup.Left;
   if Imgsysup.Left <= baseLeft then begin
      Imgsysup.Left := baseLeft;
      sys := baseLeft;
   end;
   if Imgsysup.Left+Imgsysup.Width >= baseright then begin
      Imgsysup.Left := baseright - Imgsysup.Width;
      sys := baseright;
   end;

   atemp := poscontrol (0, 255, baseLeft, baseright, 0, sys);
   SystemWaveSetVolume (atemp);
   Result := TRUE;
end;
}
procedure TFrmSound.ImgEffectupMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Boolflag := TRUE;
   Or_baseX := x;
   Imgeffectup.Picture.Assign (Imgbasedown.Picture.Bitmap);
end;

procedure TFrmSound.ImgEffectupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if Boolflag then begin
      ImgEffectup.Left := ImgEffectup.Left - (Or_baseX - X);
      if ImgEffectup.Left < baseLeft then ImgEffectup.left := baseLeft;
      if ImgEffectup.Left+ImgEffectup.Width > baseright then
         ImgEffectup.Left := baseright - ImgEffectup.width;
      EFFECTVOLUME := changeEffectVolume;
   end;
end;

procedure TFrmSound.ImgEffectupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Boolflag := FALSE;
   ImgEffectup.Picture.Assign(imgtemp);
end;

procedure TFrmSound.FormShow(Sender: TObject);
begin
//   changeBaseVolume;
//   changesysvolum;
end;

end.

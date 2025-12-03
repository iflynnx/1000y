unit FSearchUser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, A2Form, CharCls, clmap, A2Img, DXDraws, Autil32;

const
   MapImgWidth = 460;
   MapImgHeight = 345;

type
  TFrmSearchUser = class(TForm)
    A2Form: TA2Form;
    CenterIDLabel: TA2ILabel;
    SearchIDLabel: TA2ILabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
     CenterImage : TA2Image;
//     procedure SetPos (MapWidth,MapHeight,Sx,Sy:integer; SearchID: string);
     procedure SetCenterID;
     procedure SetPostion;
  end;

var
   FrmSearchUser: TFrmSearchUser;

implementation

uses
   FMain, FAttrib, FBottom;
{$R *.DFM}

procedure TFrmSearchUser.FormCreate(Sender: TObject);
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 0;
   Left := 0;
   CenterImage := TA2Image.Create (4,4,0,0);
   CenterImage.Clear (255);
   CenterIdLabel.A2Image := CenterImage;
end;

procedure TFrmSearchUser.FormDestroy(Sender: TObject);
begin
   CenterImage.Free;
end;

procedure TFrmSearchUser.SetCenterID;
var
   x, y : integer;
begin
   x := (MapImgWidth * CharPosX) div Map.GetMapWidth;
   y := (MapImgHeight * CharPosY) div Map.GetMapHeight;
   CenterIdLabel.Hint := CharCenterName;

   CenterIdLabel.Left := x - (CenterIdLabel.Width div 2);
   CenterIdLabel.Top := y - (CenterIdLabel.Height div 2);
end;

procedure TFrmSearchUser.FormShow(Sender: TObject);
begin
   SetPostion;
end;

procedure TFrmSearchUser.SetPostion;
begin
   if FrmAttrib.Visible then begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := ((640 - FrmAttrib.Width) div 2) - (Width div 2);
   end else begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := (640 div 2) - (Width div 2);
   end;
end;

{
procedure TFrmSearchUser.SetPos (MapWidth,MapHeight,Sx,Sy:integer; SearchID: string);
var
   x, y : integer;
begin
   x := (Width * CharPosX) div MapWidth;
   y := (Height * CharPosY) div MapHeight;
   CenterIdLabel.Hint := CharCenterName;
   CenterIdLabel.Left := x;
   CenterIdLabel.Top := y;
   x := (Width * Sx) div MapWidth;
   y := (Height * Sy) div MapHeight;
   SearchIdLabel.Hint := SearchID;
   SearchIdLabel.Left := x;
   SearchIdLabel.Top := y;
end;
}



end.

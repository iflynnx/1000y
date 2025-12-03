unit FDepository;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  A2Form, ExtCtrls, StdCtrls, cltype, Deftype, uAnsTick, AtzCls, A2Img,
  CharCls, aDeftype, Autil32;

const
   DepItemMaxCount = 40;
   DepMessageMaxCount = 8;
   ItembaseImage = 1;
type
  TFrmDepository = class(TForm)
    ILabel0: TA2ILabel;
    ILabel2: TA2ILabel;
    ILabel1: TA2ILabel;
    ILabel3: TA2ILabel;
    ILabel4: TA2ILabel;
    ILabel5: TA2ILabel;
    ILabel6: TA2ILabel;
    ILabel7: TA2ILabel;
    ILabel8: TA2ILabel;
    ILabel9: TA2ILabel;
    ILabel10: TA2ILabel;
    ILabel11: TA2ILabel;
    ILabel12: TA2ILabel;
    ILabel13: TA2ILabel;
    ILabel14: TA2ILabel;
    ILabel16: TA2ILabel;
    ILabel15: TA2ILabel;
    ILabel17: TA2ILabel;
    ILabel18: TA2ILabel;
    ILabel19: TA2ILabel;
    ILabel20: TA2ILabel;
    ILabel21: TA2ILabel;
    ILabel22: TA2ILabel;
    ILabel23: TA2ILabel;
    ILabel24: TA2ILabel;
    ILabel26: TA2ILabel;
    ILabel25: TA2ILabel;
    ILabel27: TA2ILabel;
    ILabel28: TA2ILabel;
    ILabel29: TA2ILabel;
    ILabel30: TA2ILabel;
    ILabel31: TA2ILabel;
    ILabel32: TA2ILabel;
    ILabel33: TA2ILabel;
    ILabel34: TA2ILabel;
    ILabel36: TA2ILabel;
    ILabel35: TA2ILabel;
    ILabel37: TA2ILabel;
    ILabel38: TA2ILabel;
    ILabel39: TA2ILabel;
    A2Form: TA2Form;
    BtnOk: TA2Button;
    BtnCancel: TA2Button;
    A2LabelCaption: TA2Label;
    A2LabelState: TA2Label;
    A2Label0: TA2Label;
    A2Label1: TA2Label;
    A2Label2: TA2Label;
    A2Label3: TA2Label;
    A2Label4: TA2Label;
    A2Label5: TA2Label;
    A2Label6: TA2Label;
    A2Label7: TA2Label;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure ILabelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ILabelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ILabelMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure ILabelStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure ILabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure ILabelCaptionMouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
    procedure ILabelCaptionMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure ILabelCaptionMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
  private
  public
     LabelArr : array [0..DepItemMaxCount-1] of TA2ILabel;
     MessageArr : array [0..DepMessageMaxCount-1] of TA2Label;

     procedure initiaizeItemLabel (Lb: TA2ILabel);
     procedure SetItemLabel (Lb: TA2ILabel; aname: string; acolor: byte; shape: word);
     procedure MessageProcess (var code: TWordComData);
  end;

var
  FrmDepository: TFrmDepository;
  A2baseImageLib : TA2ImageLib;
  A2IMessage : TA2Image;
  MoveFlag : Boolean = FALSE;
implementation

uses FMain, FAttrib, FLogon, FBottom;

{$R *.DFM}
procedure TFrmDepository.MessageProcess (var code: TWordComData);
var
   pckey : PTCKey;
   psSLogItem : PTSLogItem;
   PSSShowSpecialWindow : PTSShowSpecialWindow;
   i : integer;
   str, rdstr : string;
   StringList : TStringList;
begin
   pckey := @code.data;
   case pckey^.rmsg of
      SM_SHOWSPECIALWINDOW :
         begin
            PSSShowSpecialWindow := @Code.data;
            if not FrmAttrib.Visible then FrmAttrib.Visible := TRUE;
            case PSSShowSpecialWindow^.rWindow of
               WINDOW_ITEMLOG :
                  begin
                     MoveFlag := TRUE;
                     for i := 0 to DepMessageMaxCount -1 do begin
                        MessageArr[i].Visible := FALSE;
                     end;
                     for i := 0 to DepItemMaxCount -1 do begin
                        LabelArr[i].Visible := TRUE;
                     end;
                     FrmDepository.Visible := TRUE;
                     FrmDepository.A2LabelCaption.Caption := StrPas(@PSSShowSpecialWindow.rCaption);
                     FrmDepository.A2LabelState.Caption := GetWordString(PSSShowSpecialWindow.rWordString);
                  end;
               WINDOW_ALERT :
                  begin
                     MoveFlag := TRUE;
                     StringList := TStringList.Create;
                     for i := 0 to DepItemMaxCount -1 do begin
                        LabelArr[i].Visible := FALSE;
                     end;
                     for i := 0 to DepMessageMaxCount -1 do begin
                        MessageArr[i].Visible := TRUE;
                        MessageArr[i].Caption := '';
                     end;
                     FrmDepository.A2LabelCaption.Caption := StrPas(@PSSShowSpecialWindow.rCaption);
                     str := GetWordString(PSSShowSpecialWindow.rWordString);
                     i := 0;
                     while TRUE do begin
                        str := GetValidStr3 (str,rdstr, #13);
                        MessageArr[i].Caption := rdstr;
                        inc(i);
                        if str = '' then Break;
                        if i > 7 then break;
                     end;
                     FrmDepository.Visible := TRUE;
                     StringList.Free;
                  end;

            end;
            if PSSShowSpecialWindow.rWindow = WINDOW_ITEMLOG then

         end;
      SM_LOGITEM :
         begin
            psSLogItem := @Code.data;
            with psSLogItem^ do begin
               if StrPas (@rName) <> '' then begin
                  initiaizeItemLabel(LabelArr[rkey]);
                  SetItemLabel (LabelArr[rkey], StrPas (@rName), rColor, rshape);
               end else initiaizeItemLabel(LabelArr[rkey]);
               if rcount <= 1 then LabelArr[rkey].Hint := StrPas (@rName)
               else LabelArr[rkey].Hint := StrPas (@rName) + ':' + IntToStr(rCount);
            end;
            FrmDepository.Visible := TRUE;
         end;
   end;
end;

procedure TFrmDepository.FormCreate(Sender: TObject);
var
   i : integer;
begin
   Top := 10;
   Left := 10;
   FrmM.AddA2Form (Self, A2Form);
   for i := 0 to DepItemMaxCount -1 do begin
      LabelArr[i] := TA2ILabel(FindComponent('ILabel'+IntToStr(i)));
   end;
   for i := 0 to DepMessageMaxCount -1 do begin
      MessageArr[i] := TA2Label(FindComponent('A2Label'+IntToStr(i)));
   end;

   A2baseImagelib := TA2ImageLib.Create;
   A2baseImagelib.LoadFromFile ('.\ect\Deposi.atz');
end;

procedure TFrmDepository.FormDestroy(Sender: TObject);
begin
   A2baseImagelib.Free;
end;

procedure TFrmDepository.initiaizeItemLabel (Lb: TA2ILabel);
begin
   Lb.A2Image := A2baseImagelib.Images[ItembaseImage];
   Lb.OnDragDrop := ILabelDragDrop;
   Lb.OnDragOver := ILabelDragOver;
   Lb.OnMouseMove := ILabelMouseMove;
   Lb.OnStartDrag := ILabelStartDrag;
   Lb.OnMouseDown := ILabelMouseDown;
end;

procedure TFrmDepository.SetItemLabel (Lb: TA2ILabel; aname: string; acolor: byte; shape: word);
var gc, ga: integer;
begin
   Lb.Hint := aname;
   GetGreenColorAndAdd (acolor, gc, ga);

   Lb.GreenCol := gc;
   Lb.GreenAdd := ga;

   if shape = 0 then begin
      Lb.A2Image := nil;
      Lb.BColor := 0;
      exit;
   end else
      Lb.A2Image := AtzClass.GetItemImage (shape);
end;

procedure TFrmDepository.ILabelDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var cDragDrop : TCDragDrop;
begin
   if Source = nil then exit;

   with Source as TDragItem do begin
      if SourceID <> WINDOW_ITEMS then exit;
      cDragDrop.rmsg := CM_DRAGDROP;
      cDragDrop.rsourId := DragedId;
      cDragDrop.rdestId := 0;
      cDragDrop.rsourwindow := SourceId;
      cDragDrop.rdestwindow := WINDOW_ITEMLOG;
      cDragDrop.rsourkey := Selected;
      cDragDrop.rdestkey := TA2ILabel(Sender).tag;
      FrmLogOn.SocketAddData (sizeof(cDragDrop), @cDragDrop);
   end;
end;

procedure TFrmDepository.ILabelDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := FALSE;
   if Source <> nil then begin
      with Source as TDragItem do begin
         if SourceID = WINDOW_ITEMS then begin
            Accept := TRUE;
         end;
      end;
   end;
end;

procedure TFrmDepository.ILabelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   MouseInfoStr := TA2ILabel (Sender).Hint;
end;

procedure TFrmDepository.ILabelStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
   if Sender is TA2ILabel then begin
      DragItem.Selected := TA2ILabel(Sender).Tag;
      DragItem.SourceId := WINDOW_ITEMLOG;
      DragItem.Dragedid := 0;
      DragItem.sx := 0; DragItem.sy := 0;
      DragObject := DragItem;
   end;
end;

procedure TFrmDepository.ILabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   TA2ILabel(Sender).BeginDrag(FALSE);
end;

procedure TFrmDepository.FormShow(Sender: TObject);
begin
   Top := (480 - 117 - Height) div 2;
   if FrmAttrib.Visible then Left := (640 - 180 - Width ) div 2
   else Left := (640 - Width) div 2;
end;

procedure TFrmDepository.BtnOkClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
   CCWindowConfirm.rWindow := WINDOW_ITEMLOG;
   cCWindowConfirm.rboCheck := TRUE;
   cCWindowConfirm.rButton := 0; // 버튼이 여려개 있을경우만 사용 일반은 0이 초기값
   FrmLogon.SocketAddData (sizeof(cCWindowConfirm), @cCWindowConfirm);
   FrmDepository.Visible := FALSE;
end;

procedure TFrmDepository.BtnCancelClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
   CCWindowConfirm.rWindow := WINDOW_ITEMLOG;
   cCWindowConfirm.rboCheck := FALSE;
   cCWindowConfirm.rButton := 0; // 버튼이 여려개 있을경우만 사용 일반은 0이 초기값
   FrmLogon.SocketAddData (sizeof(cCWindowConfirm), @cCWindowConfirm);
   FrmDepository.Visible := FALSE;
end;

var
   Boolflag : Boolean = FALSE;
   Or_baseX : integer =0;
   Or_baseY : integer =0;

function  CheckMaxRight: integer;
begin
   if FrmAttrib.Visible then Result := 640 - FrmAttrib.Width
   else Result := 640;
end;

function  CheckMaxLeft: integer;
begin
   Result := 0;
end;

function  CheckMaxTop: integer;
begin
   Result := 0;
end;

function  CheckMaxBottom: integer;
begin
   if FrmBottom.Visible then Result := (480 - Frmbottom.Height)+10
   else Result := 480;
end;

procedure TFrmDepository.ILabelCaptionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if Boolflag then begin
      FrmDepository.Left := FrmDepository.Left - (Or_baseX - X);
      FrmDepository.Top := FrmDepository.Top - (Or_baseY - Y);
      {
      if FrmDepository.Left < CheckMaxLeft then FrmDepository.left := CheckMaxLeft;
      if FrmDepository.Left+FrmDepository.Width > CheckMaxRight then
         FrmDepository.Left := CheckMaxRight - FrmDepository.width;
      if FrmDepository.Top < CheckMaxTop then FrmDepository.Top := CheckMaxTop;
      if FrmDepository.Top+FrmDepository.Height > CheckMaxBottom then
         FrmDepository.Top := CheckMaxBottom - FrmDepository.Height;
         }
   end;
end;

procedure TFrmDepository.ILabelCaptionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if MoveFlag then begin
      Boolflag := TRUE;
      Or_baseX := X;
      Or_baseY := Y;
   end;
end;


procedure TFrmDepository.ILabelCaptionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Boolflag := FALSE;
end;

end.

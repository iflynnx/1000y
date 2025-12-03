unit FbatList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, BSCommon, Deftype, AUtil32, A2Form, AtzCls, A2Img, ExtCtrls, uPersonBat;

type
  TBatWindowType = (TWT_GList, TWT_RList, TWT_ranking);

  TFrmbatList = class(TForm)
    A2Form: TA2Form;
    A2ListBox: TA2ListBox;
    A2ButtonOK: TA2Button;
    A2ButtonCanCel: TA2Button;
    A2ButtonFight: TA2Button;
    A2ButtonShow: TA2Button;
    A2ButtonRanking: TA2Button;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure A2ButtonOKClick(Sender: TObject);
    procedure A2ButtonCanCelClick(Sender: TObject);
    procedure A2ButtonFightClick(Sender: TObject);
    procedure A2ButtonShowClick(Sender: TObject);
    procedure A2ListBoxDblClick(Sender: TObject);
    procedure A2ButtonRankingClick(Sender: TObject);
    procedure A2ListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure A2ListBoxClick(Sender: TObject);
  private
    ScrollBackImage : TA2Image;
    ListBoxSurface : TA2Image;

  public
     BatWindowType : TBatWindowType;

     procedure MessageProcess (var code: TWordComData);
     procedure SetPostion;
     procedure SetImage(aBatWindowType: TBatWindowType);
     procedure SetListBoxImage;
  end;

var
  FrmbatList: TFrmbatList;

implementation

uses
   FMain, FAttrib, FBottom, FLogOn;

{$R *.DFM}

procedure TFrmbatList.MessageProcess (var code: TWordComData);
var
   PSSShowSpecialWindow : PTSShowSpecialWindow;
   PSSShowListWindow : PTSShowListWindow;
   str, rdstr, rdstr2 : string;
   GroupStr : String;
   RoomStr : String;
   i : integer;
begin
   PSSShowSpecialWindow := @Code.data;
   case PSSShowSpecialWindow^.rWindow of
      WINDOW_GROUPWINDOW :
         begin
            PSSShowListWindow := @Code.data;
            case PSSShowListWindow^.rType of
               0 :
                  begin // show
                     BatWindowType := TWT_GList;
                     PersonBat.ShowBar := FALSE;
                     A2ListBox.Clear;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     while TRUE do begin
                        str := GetValidStr3 (str, rdstr, ',');
                        if rdStr = '' then break;
                        A2ListBox.AddItem (rdstr);
                        if str = '' then break;
                     end;
                     SetImage(BatWindowType);
                     FrmbatList.Visible := TRUE;
                  end;
               1 :
                  begin // Add
                     BatWindowType := TWT_GList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     A2ListBox.AddItem (str);
                  end;
               2 :
                  begin // Delete
                     BatWindowType := TWT_GList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     GroupStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := GroupStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.DeleteItem (i);
                           break;
                        end;
                     end;
                  end;
               3 :
                  begin
                     BatWindowType := TWT_GList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     GroupStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := GroupStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.Items[i] := GroupStr;
                           break;
                        end;
                     end;
                  end;
            end;
         end;
      WINDOW_ROOMWINDOW :
         begin
            PSSShowListWindow := @Code.data;
            case PSSShowListWindow^.rType of
               0 : // show
                  begin
                     BatWindowType := TWT_RList;
                     PersonBat.ShowBar := FALSE;
                     A2ListBox.Clear;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     while TRUE do begin
                        str := GetValidStr3 (str, rdstr, ',');
                        if rdstr = '' then break;
                        A2ListBox.AddItem (rdstr);
                        if str = '' then break;
                     end;
                     SetImage(BatWindowType);
                     FrmbatList.Visible := TRUE;
                  end;
               1 : // Add
                  begin
                     BatWindowType := TWT_RList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     A2ListBox.AddItem (str);
                  end;
               2 : // Delete
                  begin
                     BatWindowType := TWT_RList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     RoomStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := RoomStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.DeleteItem (i);
                           break;
                        end;
                     end;
                  end;
               3 : // update
                  begin
                     BatWindowType := TWT_RList;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     RoomStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := RoomStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.Items[i] := RoomStr;
                           break;
                        end;
                     end;
                  end;
            end;
         end;
      WINDOW_GRADEWINDOW :
         begin
            PSSShowListWindow := @Code.data;
            case PSSShowListWindow^.rType of
               0 : // show
                  begin
                     BatWindowType := TWT_ranking;
                     A2ListBox.Clear;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     while TRUE do begin
                        str := GetValidStr3 (str, rdstr, ',');
                        if rdstr = '' then break;
                        A2ListBox.AddItem (rdstr);
                        if str = '' then break;
                     end;
                     SetImage(BatWindowType);
                     FrmbatList.Visible := TRUE;
                  end;
               1 : // Add
                  begin
                     BatWindowType := TWT_ranking;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     str := GetWordString(PSSShowListWindow^.rWordString);
                     A2ListBox.AddItem (str);
                  end;
               2 : // Delete
                  begin
                     BatWindowType := TWT_ranking;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     RoomStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := RoomStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.DeleteItem (i);
                           break;
                        end;
                     end;
                  end;
               3 : // update
                  begin
                     BatWindowType := TWT_ranking;
                     if not FrmbatList.Visible then FrmbatList.Visible := TRUE;
                     RoomStr := GetWordString(PSSShowListWindow^.rWordString);
                     Str := RoomStr;
                     Str := GetValidStr3 (Str, rdStr, ':');
                     for i := 0 to A2ListBox.Count -1 do begin
                        Str := A2ListBox.Items [i];
                        Str := GetValidStr3 (Str, rdStr2, ':');
                        if rdStr = rdStr2 then begin
                           A2ListBox.Items[i] := RoomStr;
                           break;
                        end;
                     end;
                  end;
            end;
         end;
   end;
end;

procedure TFrmbatList.SetPostion;
begin
   if FrmAttrib.Visible then begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := ((640 - FrmAttrib.Width) div 2) - (Width div 2);
   end else begin
      Top := ((480 - FrmBottom.Height) div 2) - (Height div 2);
      Left := (640 div 2) - (Width div 2);
   end;
end;

procedure TFrmbatList.SetListBoxImage;
var i, x, y : integer;
begin
   A2ListBox.SetScrollTopImage (EtcAtzClass.GetEtcAtz (52),EtcAtzClass.GetEtcAtz (53));
   A2ListBox.SetScrollTrackImage (EtcAtzClass.GetEtcAtz (56),EtcAtzClass.GetEtcAtz (57));
   A2ListBox.SetScrollBottomImage (EtcAtzClass.GetEtcAtz (54),EtcAtzClass.GetEtcAtz (55));
   ScrollBackImage.DrawImage (EtcAtzClass.GetEtcAtz (68),0,0,TRUE);
   ScrollBackImage.DrawImage (EtcAtzClass.GetEtcAtz (69),0,EtcAtzClass.GetEtcAtz (68).Height,TRUE);
   A2ListBox.SetScrollBackImage (ScrollBackImage);

   ListBoxSurface.DrawImage (EtcAtzClass.GetEtcAtz (70),0,-1,TRUE);

   x := EtcAtzClass.GetEtcAtz (70).Width -2;
   for i := 1 to ListBoxSurface.Height div EtcAtzClass.GetEtcAtz (72).Width + 2 do begin
      ListBoxSurface.DrawImage (EtcAtzClass.GetEtcAtz (72),x-2,-1,TRUE);
      inc (x, EtcAtzClass.GetEtcAtz (72).Width-2);
   end;
   y := ListBoxSurface.Height - EtcAtzClass.GetEtcAtz (71).Height;
   ListBoxSurface.DrawImage (EtcAtzClass.GetEtcAtz (71),0, y ,TRUE);
   x := EtcAtzClass.GetEtcAtz (71).Width -2;
   y := ListBoxSurface.Height - EtcAtzClass.GetEtcAtz (72).Height;
   for i := 1 to ListBoxSurface.Height div EtcAtzClass.GetEtcAtz (72).Width + 2 do begin
      ListBoxSurface.DrawImage (EtcAtzClass.GetEtcAtz (72),x-2,y,TRUE);
      inc (x, EtcAtzClass.GetEtcAtz (72).Width-2);
   end;
   y := EtcAtzClass.GetEtcAtz (70).Height -2;
   for i := 1 to 2 do begin
      ListBoxSurface.DrawImage (EtcAtzClass.GetEtcAtz (73),0,y,TRUE);
      inc (y,EtcAtzClass.GetEtcAtz (73).Height);
   end;

   A2ListBox.SetBackImage (ListBoxSurface);
end;

procedure TFrmbatList.SetImage(aBatWindowType: TBatWindowType);
begin
   // Button
   case aBatWindowType of
      TWT_GList :
         begin
            A2ButtonOK.Visible := TRUE;
            A2ButtonCancel.Visible := TRUE;
            A2ButtonRanking.Visible := TRUE;
            A2ButtonFight.Visible := FALSE;
            A2ButtonShow.Visible := FALSE;

            A2ButtonOK.SetUpA2Image (EtcAtzClass.GetEtcAtz (58));
            A2ButtonOK.SetDownA2Image (EtcAtzClass.GetEtcAtz (59));
            A2ButtonCancel.SetUpA2Image (EtcAtzClass.GetEtcAtz (60));
            A2ButtonCancel.SetDownA2Image (EtcAtzClass.GetEtcAtz (61));
            A2ButtonRanking.SetUpA2Image (EtcAtzClass.GetEtcAtz (106));
            A2ButtonRanking.SetDownA2Image(EtcAtzClass.GetEtcAtz (107));
         end;
      TWT_RList :
         begin
            A2ButtonOK.Visible := TRUE;
            A2ButtonCancel.Visible := TRUE;
            A2ButtonRanking.Visible := FALSE;
            A2ButtonFight.Visible := TRUE;
            A2ButtonShow.Visible := TRUE;

            A2ButtonOK.SetUpA2Image (EtcAtzClass.GetEtcAtz (62));
            A2ButtonOK.SetDownA2Image (EtcAtzClass.GetEtcAtz (63));
            A2ButtonCancel.SetUpA2Image (EtcAtzClass.GetEtcAtz (60));
            A2ButtonCancel.SetDownA2Image (EtcAtzClass.GetEtcAtz (61));
            A2ButtonFight.SetUpA2Image (EtcAtzClass.GetEtcAtz (64));
            A2ButtonFight.SetDownA2Image (EtcAtzClass.GetEtcAtz (65));
            A2ButtonShow.SetUpA2Image (EtcAtzClass.GetEtcAtz (66));
            A2ButtonShow.SetDownA2Image (EtcAtzClass.GetEtcAtz (67));
         end;
      TWT_ranking :
         begin
            A2ButtonOK.Visible := TRUE;
            A2ButtonCancel.Visible := TRUE;
            A2ButtonRanking.Visible := TRUE;
            A2ButtonFight.Visible := FALSE;
            A2ButtonShow.Visible := FALSE;

            A2ButtonOK.SetUpA2Image (EtcAtzClass.GetEtcAtz (108));
            A2ButtonOK.SetDownA2Image (EtcAtzClass.GetEtcAtz (109));
            A2ButtonCancel.SetUpA2Image (EtcAtzClass.GetEtcAtz (60));
            A2ButtonCancel.SetDownA2Image (EtcAtzClass.GetEtcAtz (61));
            A2ButtonRanking.SetUpA2Image (EtcAtzClass.GetEtcAtz (110));
            A2ButtonRanking.SetDownA2Image(EtcAtzClass.GetEtcAtz (111));
         end;
   end;
end;

procedure TFrmbatList.FormCreate(Sender: TObject);
var
   i : integer;
begin
   FrmM.AddA2Form (Self, A2Form);
   Top := 0;
   Left := 0;
   ScrollBackImage := TA2Image.Create (16, A2ListBox.Height, 0, 0);
   ListBoxSurface := TA2Image.Create (A2ListBox.Width-16, A2ListBox.Height,0,0);
   for i := 0 to 1000-1 do begin
      A2ListBox.AddItem (format (Conv('¾ÆÀ×ÅÛ %d'),[i]));
   end;
   BatWindowType := TWT_GList;
   SetImage (BatWindowType);
   SetListBoxImage;
end;

procedure TFrmbatList.FormDestroy(Sender: TObject);
begin
   ScrollBackImage.Free;
   ListBoxSurface.Free;
end;

procedure TFrmbatList.FormShow(Sender: TObject);
begin
   A2ListBox.ItemIndex := 0;
   SetPostion;
//   A2ListBox.SetFocus;
end;


procedure TFrmbatList.A2ButtonOKClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   case BatWindowType of
      TWT_GList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GROUPWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_SELECT;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
      TWT_RList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_ROOMWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_MAKE;
            cCWindowConfirm.rText := '';
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
      TWT_ranking :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GRADEWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_SHOWALL;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
//            FrmbatList.Visible := FALSE;
         end;
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmbatList.A2ButtonCanCelClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   case BatWindowType of
      TWT_GList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GROUPWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_EXIT;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
      TWT_RList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_ROOMWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_ROOMEXIT;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
      TWT_ranking :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GRADEWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_GRADEEXIT;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
//            FrmbatList.Visible := FALSE;
         end;
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmbatList.A2ButtonFightClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   case BatWindowType of
      TWT_GList :;
      TWT_RList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_ROOMWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_FIGHT;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmbatList.A2ButtonShowClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   case BatWindowType of
      TWT_GList :;
      TWT_RList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_ROOMWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_SHOW;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
            FrmbatList.Visible := FALSE;
         end;
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmbatList.A2ListBoxDblClick(Sender: TObject);
begin
   case BatWindowType of
      TWT_GList : A2ButtonOk.OnClick (Self);
      TWT_RList : A2ButtonFight.OnClick (Self);
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;


procedure TFrmbatList.A2ButtonRankingClick(Sender: TObject);
var cCWindowConfirm : TCWindowConfirm;
begin
   case BatWindowType of
      TWT_GList :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GROUPWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_GRADE;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
         end;
      TWT_ranking :
         begin
            cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
            cCWindowConfirm.rWindow := WINDOW_GRADEWINDOW;
            cCWindowConfirm.rboCheck := TRUE;
            cCWindowConfirm.rButton := BATTLEBUTTON_SHOWME;
            cCWindowConfirm.rText := '';
            if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
            FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
         end;
   end;
   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

procedure TFrmbatList.A2ListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var cCWindowConfirm : TCWindowConfirm;
begin
   FrmBottom.EdChat.OnKeyDown (Sender, key, Shift);
   if key = 13 then begin
      case BatWindowType of
         TWT_GList :
            begin
               cCWindowConfirm.rMsg := CM_WINDOWCONFIRM;
               cCWindowConfirm.rWindow := WINDOW_GROUPWINDOW;
               cCWindowConfirm.rboCheck := TRUE;
               cCWindowConfirm.rButton := BATTLEBUTTON_SELECT;
               cCWindowConfirm.rText := '';
               if A2ListBox.Items[A2ListBox.ItemIndex] <> '' then cCWindowConfirm.rText := A2ListBox.Items[A2ListBox.ItemIndex];
               FrmLogon.SocketAddData (sizeof(TCWindowConfirm), @cCWindowConfirm);
               FrmbatList.Visible := FALSE;
               if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
            end;
      end;
   end;
end;

procedure TFrmbatList.A2ListBoxClick(Sender: TObject);
begin
//   if FrmBottom.Visible then FrmBottom.FocusControl (FrmBottom.EdChat);
end;

end.

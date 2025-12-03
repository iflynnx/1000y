unit FUpDateID;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmUpDateId = class(TForm)
    BtnCancel: TButton;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmUpDateId: TFrmUpDateId;

implementation

{$R *.DFM}

procedure TFrmUpDateId.BtnCancelClick(Sender: TObject);
begin
   ModalResult := -1;
end;

procedure TFrmUpDateId.FormCreate(Sender: TObject);
begin
//
end;

end.

unit Unit10;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts;

type
  TForm1 = class(TForm)
    Background: TRectangle;
    Start: TButton;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Layout2: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Label2: TLabel;
    Circle1: TCircle;
    procedure StartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Unit2;



procedure TForm1.StartClick(Sender: TObject);
begin
  if not Assigned(Form2) then
    Form2 := TForm2.Create(Application);

  Form2.Show;


  Form1.Hide;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  ProgressBar1.Value := ProgressBar1.Value + 1;
  if ProgressBar1.Value >= 100 then
  begin
    Timer1.Enabled := False;

    if not Assigned(Form2) then
      Application.CreateForm(TForm2, Form2);
    Form2.Show;
    Form1.Hide;
  end;
end;


end.

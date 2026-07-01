unit Unit7;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, System.Math.Vectors, FMX.Controls3D,
  FMX.Layers3D, FMX.ListBox, FireDAC.Comp.Client, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TForm7 = class(TForm)
    lblStudentID, lblFullName, lblCourse, lblYear, lblSemester, lblBalance, lblTotalFees, lblTotalPaid: TLabel;
    edtSearch: TEdit; gridFees, gridPayments: TStringGrid; lstSuggestions: TListBox; Button1, Button2: TButton; SpeedButton1: TSpeedButton;
    FDQ7_Fees, FDQ7_Payments, FDQ7_Students, FDQ7_Suggestions, FDQ7_UpdateBalance: TFDQuery;
    procedure FormShow(Sender: TObject); procedure Rectangle2Click(Sender: TObject); procedure rectAddFeeClick(Sender: TObject); procedure rectAddPaymentClick(Sender: TObject);
    procedure Button1Click(Sender: TObject); procedure Button2Click(Sender: TObject); procedure SpeedButton1Click(Sender: TObject);
  private
    procedure LoadFees; procedure LoadPayments; procedure CalculateTotals;
  public
  end;

var Form7: TForm7; CurrentStudentID: string;

implementation
{$R *.fmx}
uses Unit6, Unit8;

procedure TForm7.FormShow(Sender: TObject);
begin
  FDQ7_Fees.Connection := Form6.FDConnection1; FDQ7_Payments.Connection := Form6.FDConnection1;
  FDQ7_Students.Connection := Form6.FDConnection1; FDQ7_Suggestions.Connection := Form6.FDConnection1;
  FDQ7_UpdateBalance.Connection := Form6.FDConnection1;
end;

procedure TForm7.Rectangle2Click(Sender: TObject);
begin
  if not Form6.FDConnection1.Connected then Exit;
  FDQ7_Students.Close; FDQ7_Students.SQL.Text := 'SELECT * FROM students WHERE student_id = :s OR last_name = :s';
  FDQ7_Students.ParamByName('s').AsString := Trim(edtSearch.Text); FDQ7_Students.Open;
  if FDQ7_Students.IsEmpty then Exit;
  CurrentStudentID := FDQ7_Students.FieldByName('student_id').AsString;
  lblStudentID.Text := CurrentStudentID; lblFullName.Text := FDQ7_Students.FieldByName('last_name').AsString;
  LoadFees; LoadPayments;
end;

procedure TForm7.LoadFees;
var r: integer;
begin
  FDQ7_Fees.Close; FDQ7_Fees.SQL.Text := 'SELECT * FROM student_fees WHERE student_id = :id';
  FDQ7_Fees.ParamByName('id').AsString := CurrentStudentID; FDQ7_Fees.Open;
  gridFees.RowCount := 1; r := 1;
  while not FDQ7_Fees.Eof do begin
    gridFees.RowCount := r + 1;
    gridFees.Cells[0, r] := FDQ7_Fees.FieldByName('fee_name').AsString;
    gridFees.Cells[2, r] := FDQ7_Fees.FieldByName('amount').AsString;
    Inc(r); FDQ7_Fees.Next;
  end;
end;

procedure TForm7.LoadPayments;
var r: integer;
begin
  FDQ7_Payments.Close; FDQ7_Payments.SQL.Text := 'SELECT * FROM student_payments WHERE student_id = :id';
  FDQ7_Payments.ParamByName('id').AsString := CurrentStudentID; FDQ7_Payments.Open;
  gridPayments.RowCount := 1; r := 1;
  while not FDQ7_Payments.Eof do begin
    gridPayments.RowCount := r + 1;
    gridPayments.Cells[0, r] := FDQ7_Payments.FieldByName('payment_date').AsString;
    gridPayments.Cells[1, r] := FDQ7_Payments.FieldByName('amount_paid').AsString;
    Inc(r); FDQ7_Payments.Next;
  end;
  CalculateTotals;
end;

procedure TForm7.CalculateTotals;
var f, p, b: Double; i: integer;
begin
  f := 0; p := 0;
  for i := 1 to gridFees.RowCount-1 do f := f + StrToFloatDef(gridFees.Cells[2,i], 0);
  for i := 1 to gridPayments.RowCount-1 do p := p + StrToFloatDef(gridPayments.Cells[1,i], 0);
  b := f - p;
  lblTotalFees.Text := FormatFloat('P #,##0.00', f); lblBalance.Text := FormatFloat('P #,##0.00', b);

  FDQ7_UpdateBalance.Close;
  FDQ7_UpdateBalance.SQL.Text := 'UPDATE students SET remaining_balance = :bal, is_eligible = :elig WHERE student_id = :id';
  FDQ7_UpdateBalance.ParamByName('bal').AsFloat := b;
  FDQ7_UpdateBalance.ParamByName('id').AsString := CurrentStudentID;

  // ✅ FIXED: Replaced 'iif' with standard 'if'
  if b <= 0 then
    FDQ7_UpdateBalance.ParamByName('elig').AsInteger := 1
  else
    FDQ7_UpdateBalance.ParamByName('elig').AsInteger := 0;

  FDQ7_UpdateBalance.ExecSQL;
end;

procedure TForm7.rectAddFeeClick(Sender: TObject);
var cmd: TFDQuery; a: string;
begin
  a := InputBox('Add Fee', 'Amount:', '0');
  cmd := TFDQuery.Create(nil);
  try
    cmd.Connection := Form6.FDConnection1;
    cmd.SQL.Text := 'INSERT INTO student_fees (student_id, fee_name, amount) VALUES (:id, "Misc", :a)';
    cmd.ParamByName('id').AsString := CurrentStudentID; cmd.ParamByName('a').AsString := a;
    cmd.ExecSQL; LoadFees;
  finally cmd.Free; end;
end;

procedure TForm7.rectAddPaymentClick(Sender: TObject); begin ShowMessage('Payment logic ready'); end;
procedure TForm7.Button1Click(Sender: TObject); begin Form6.Show; Self.Hide; end;
procedure TForm7.Button2Click(Sender: TObject); begin Form8.Show; Self.Hide; end;
procedure TForm7.SpeedButton1Click(Sender: TObject); begin Application.Terminate; end;

end.

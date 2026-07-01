unit Unit6;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, FMX.ListBox, FMX.DateTimeCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt;

type
  TForm6 = class(TForm)
    Layout1, Layout2, Layout3, Layout4: TLayout; Rectangle1, Rectangle2, Rectangle3, Rectangle5, Rectangle6, rectSearch, rectSave, rectUpdate, rectDelete, edtClear, Rectangle11: TRectangle;
    Label1, Label2, Label3, Label4, Label5, Label6, Label7, Label8, Label9, Label10, Label11, Label12, Label13, Label14, Label15, Label16, Label17, Label18, Label19, Label20, Label21, Label22, Label23: TLabel;
    edtSearch, edtStudentID, edtLastName, edtFirstName, edtMiddleName, edtSuffix: TEdit;
    StringGrid1: TStringGrid; StringColumn1, StringColumn2, StringColumn3, StringColumn4, StringColumn5, StringColumn6, StringColumn7, StringColumn8, StringColumn9, StringColumn10, StringColumn11, StringColumn12, StringColumn13: TStringColumn;
    cbCourse, cbYearLevel, cbSection, cbAcadYear: TComboBox; rbRegular, rbIrregular, rb1stSem, rb2ndSem, rbRegistered, rbNotRegistered: TRadioButton;
    dtpEnrolled, DateTimePicker1: TDateEdit; Fees, QR_Code, Button1, btnGenerateID: TButton; SpeedButton1: TSpeedButton; lstSuggestions: TListBox;
    FDConnection1: TFDConnection; FDQ_Students: TFDQuery; FDQ_Suggestions: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure QR_CodeClick(Sender: TObject); procedure FeesClick(Sender: TObject); procedure SpeedButton1Click(Sender: TObject);
    procedure rectSaveClick(Sender: TObject); procedure rectUpdateClick(Sender: TObject); procedure StringGrid1CellClick(const Column: TColumn; const Row: Integer);
    procedure rectDeleteClick(Sender: TObject); procedure FormCreate(Sender: TObject); procedure edtSearchTyping(Sender: TObject);
    procedure edtClearClick(Sender: TObject); procedure rectSearchClick(Sender: TObject); procedure btnGenerateIDClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject); procedure lstSuggestionsClick(Sender: TObject);
  private
    procedure RefreshGrid;
  public
  end;

var Form6: TForm6;

implementation
{$R *.fmx}
uses Unit7, Unit8;

procedure TForm6.FormCreate(Sender: TObject);
begin

    FDConnection1.Connected := False;

FDConnection1.Params.Clear;
FDConnection1.Params.Values['DriverID']   := 'MySQL';
FDConnection1.Params.Values['Server']     := 'localhost';
FDConnection1.Params.Values['Database']   := 'school_db';
FDConnection1.Params.Values['User_Name']  := 'root';
FDConnection1.Params.Values['Password']   := 'Montage#2000';

FDConnection1.Params.Values['SSLMode']    := 'Disable';
FDConnection1.Params.Values['UseSSL']     := '0';

FDConnection1.LoginPrompt := False;
FDConnection1.Connected   := True;

  end;

procedure TForm6.RefreshGrid;
var Row: Integer;
begin
  if not FDConnection1.Connected then Exit;
  FDQ_Students.Close;
  FDQ_Students.SQL.Text := 'SELECT * FROM students ORDER BY last_name ASC';
  FDQ_Students.Open;
  StringGrid1.RowCount := 0;
  if FDQ_Students.IsEmpty then Exit;
  StringGrid1.RowCount := FDQ_Students.RecordCount;
  Row := 0;
  while not FDQ_Students.Eof do begin
    StringGrid1.Cells[0, Row] := FDQ_Students.FieldByName('student_id').AsString;
    StringGrid1.Cells[1, Row] := FDQ_Students.FieldByName('last_name').AsString;
    StringGrid1.Cells[2, Row] := FDQ_Students.FieldByName('first_name').AsString;
    StringGrid1.Cells[5, Row] := FDQ_Students.FieldByName('course').AsString;
    StringGrid1.Cells[12, Row] := FDQ_Students.FieldByName('status').AsString;
    Inc(Row); FDQ_Students.Next;
  end;
end;

procedure TForm6.rectSaveClick(Sender: TObject);
var Cmd: TFDQuery; sType, sSem, sStatus: string;
begin
  if (edtStudentID.Text = '') or (edtLastName.Text = '') then begin ShowMessage('Required fields missing!'); Exit; end;
  if rbRegular.IsChecked then sType := 'Regular' else sType := 'Irregular';
  if rb1stSem.IsChecked then sSem := '1st Sem' else sSem := '2nd Sem';
  if rbRegistered.IsChecked then sStatus := 'Registered' else sStatus := 'Not Registered';
  Cmd := TFDQuery.Create(nil);
  try
    Cmd.Connection := FDConnection1;
    Cmd.SQL.Text := 'INSERT INTO students (student_id, last_name, first_name, middle_name, suffix, course, year_level, section, academic_year, date_enrolled, student_type, semester, status) ' +
                    'VALUES (:id, :lname, :fname, :mname, :suff, :crs, :yl, :sec, :acad, :date, :stype, :sem, :stat)';
    Cmd.ParamByName('id').AsString := edtStudentID.Text;
    Cmd.ParamByName('lname').AsString := edtLastName.Text;
    Cmd.ParamByName('fname').AsString := edtFirstName.Text;
    Cmd.ParamByName('mname').AsString := edtMiddleName.Text;
    Cmd.ParamByName('suff').AsString := edtSuffix.Text;
    Cmd.ParamByName('crs').AsString := cbCourse.Text;
    Cmd.ParamByName('yl').AsString := cbYearLevel.Text;
    Cmd.ParamByName('sec').AsString := cbSection.Text;
    Cmd.ParamByName('acad').AsString := cbAcadYear.Text;
    Cmd.ParamByName('date').AsDate := dtpEnrolled.Date;
    Cmd.ParamByName('stype').AsString := sType;
    Cmd.ParamByName('sem').AsString := sSem;
    Cmd.ParamByName('stat').AsString := sStatus;
    Cmd.ExecSQL; ShowMessage('✅ Saved!'); RefreshGrid; edtClearClick(Sender);
  finally Cmd.Free; end;
end;

procedure TForm6.btnGenerateIDClick(Sender: TObject);
var FirstInitial, LastInitial, BDayString: string;
begin
  if Length(Trim(edtLastName.Text)) > 0 then LastInitial := UpperCase(Trim(edtLastName.Text)[1]) else LastInitial := 'X';
  if Length(Trim(edtFirstName.Text)) > 0 then FirstInitial := UpperCase(Trim(edtFirstName.Text)[1]) else FirstInitial := 'X';
  BDayString := FormatDateTime('yyyymmdd', DateTimePicker1.Date);
  edtStudentID.Text := LastInitial + FirstInitial + '-' + BDayString;
end;

procedure TForm6.rectUpdateClick(Sender: TObject);
var Cmd: TFDQuery; sType, sSem, sStatus: string;
begin
  if edtStudentID.Text = '' then Exit;
  if rbRegular.IsChecked then sType := 'Regular' else sType := 'Irregular';
  if rb1stSem.IsChecked then sSem := '1st Sem' else sSem := '2nd Sem';
  if rbRegistered.IsChecked then sStatus := 'Registered' else sStatus := 'Not Registered';
  Cmd := TFDQuery.Create(nil);
  try
    Cmd.Connection := FDConnection1;
    Cmd.SQL.Text := 'UPDATE students SET last_name=:lname, first_name=:fname, course=:crs, status=:stat WHERE student_id=:id';
    Cmd.ParamByName('id').AsString := edtStudentID.Text; Cmd.ParamByName('lname').AsString := edtLastName.Text; Cmd.ParamByName('fname').AsString := edtFirstName.Text; Cmd.ParamByName('crs').AsString := cbCourse.Text; Cmd.ParamByName('stat').AsString := sStatus;
    Cmd.ExecSQL; ShowMessage('✅ Updated!'); RefreshGrid;
  finally Cmd.Free; end;
end;

procedure TForm6.rectDeleteClick(Sender: TObject);
var Cmd: TFDQuery; id: string;
begin
  if StringGrid1.Selected < 0 then Exit;
  id := StringGrid1.Cells[0, StringGrid1.Selected];
  if MessageDlg('Delete Student '+id+'?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then begin
    Cmd := TFDQuery.Create(nil);
    try
      Cmd.Connection := FDConnection1; Cmd.SQL.Text := 'DELETE FROM students WHERE student_id = :id';
      Cmd.ParamByName('id').AsString := id; Cmd.ExecSQL; RefreshGrid;
    finally Cmd.Free; end;
  end;
end;

procedure TForm6.StringGrid1CellClick(const Column: TColumn; const Row: Integer);
var SelectedID: string;
begin
  if Row < 0 then Exit;
  SelectedID := StringGrid1.Cells[0, Row];
  FDQ_Students.Close;
  FDQ_Students.SQL.Text := 'SELECT * FROM students WHERE student_id = :id';
  FDQ_Students.ParamByName('id').AsString := SelectedID;
  FDQ_Students.Open;
  if not FDQ_Students.IsEmpty then begin
    edtStudentID.Text := FDQ_Students.FieldByName('student_id').AsString;
    edtLastName.Text  := FDQ_Students.FieldByName('last_name').AsString;
    edtFirstName.Text := FDQ_Students.FieldByName('first_name').AsString;
  end;
end;

procedure TForm6.rectSearchClick(Sender: TObject);
begin
  FDQ_Students.Close;
  FDQ_Students.SQL.Text := 'SELECT * FROM students WHERE student_id LIKE :s OR last_name LIKE :s';
  FDQ_Students.ParamByName('s').AsString := '%' + edtSearch.Text + '%';
  FDQ_Students.Open; RefreshGrid;
end;

procedure TForm6.edtSearchChange(Sender: TObject);
begin
  if edtSearch.Text = '' then begin lstSuggestions.Visible := False; Exit; end;
  FDQ_Suggestions.Close; FDQ_Suggestions.SQL.Text := 'SELECT last_name, first_name FROM students WHERE last_name LIKE :s LIMIT 5';
  FDQ_Suggestions.ParamByName('s').AsString := edtSearch.Text + '%'; FDQ_Suggestions.Open;
  lstSuggestions.Items.Clear;
  while not FDQ_Suggestions.Eof do begin
    lstSuggestions.Items.Add(FDQ_Suggestions.FieldByName('last_name').AsString + ', ' + FDQ_Suggestions.FieldByName('first_name').AsString);
    FDQ_Suggestions.Next;
  end;
  lstSuggestions.Visible := lstSuggestions.Items.Count > 0;
end;

procedure TForm6.edtSearchTyping(Sender: TObject); begin rectSearchClick(Sender); end;
procedure TForm6.edtClearClick(Sender: TObject); begin edtStudentID.Text := ''; edtLastName.Text := ''; edtFirstName.Text := ''; edtStudentID.SetFocus; end;
procedure TForm6.lstSuggestionsClick(Sender: TObject); begin edtSearch.Text := lstSuggestions.Items[lstSuggestions.ItemIndex]; lstSuggestions.Visible := False; rectSearchClick(Sender); end;
procedure TForm6.FeesClick(Sender: TObject); begin Form7.Show; Self.Hide; end;
procedure TForm6.QR_CodeClick(Sender: TObject); begin Form8.Show; Self.Hide; end;
procedure TForm6.SpeedButton1Click(Sender: TObject); begin Application.Terminate; end;

end.

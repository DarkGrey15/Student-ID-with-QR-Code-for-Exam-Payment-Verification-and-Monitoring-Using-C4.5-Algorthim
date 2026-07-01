unit Unit8;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Ani,
  System.Net.HttpClient, System.Net.URLClient, System.NetEncoding, FMX.ListBox,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt;

type
  TForm8 = class(TForm)
    // Your existing visual controls from the .fmx:
    rectHeader: TRectangle;
    Label1: TLabel;
    lytBody: TLayout;
    lytLeft: TLayout;
    lytRight: TLayout;
    rectSearch: TRectangle;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Label2: TLabel;
    edtSearch: TEdit;
    btnSearchQR: TRectangle;
    Label3: TLabel;
    Rectangle4: TRectangle;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblStudentID: TLabel;
    lblFullName: TLabel;
    lblCourse: TLabel;
    lblYear: TLabel;
    lblStatus: TLabel;
    rectQRPanel: TRectangle;
    RectAnimation1: TRectAnimation;
    rectQRPanelHeader: TRectangle;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Rectangle5: TRectangle;
    imgQR: TImage;
    Layout1: TLayout;
    btnGenerateQR: TRectangle;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Rectangle9: TRectangle;
    Rectangle10: TRectangle;
    Label22: TLabel;
    Label23: TLabel;
    lblQRContent: TLabel;
    rectSaveQRCode: TRectangle;
    Rectangle12: TRectangle;
    Label25: TLabel;
    Label26: TLabel;
    Layout2: TLayout;
    Rectangle13: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Rectangle14: TRectangle;
    SpeedButton1: TSpeedButton;
    Button3: TButton;
    SaveDialog1: TSaveDialog;
    lstSuggestions: TListBox;

    // New FireDAC queries for this form
    FDQ8_Suggestions: TFDQuery;
    FDQ8_Students: TFDQuery;

    // Events (same names as your old code)
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnGenerateQRClick(Sender: TObject);
    procedure btnSearchQRClick(Sender: TObject);
    procedure rectSaveQRCodeClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure lstSuggestionsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure GenerateOnlineQRCode(const QRData: string);
  public
  end;

var
  Form8: TForm8;

implementation

{$R *.fmx}

uses Unit6, Unit7, Student_Portal7;

procedure TForm8.FormShow(Sender: TObject);
begin
  // Link our queries to the main FDConnection from Form6
  FDQ8_Students.Connection    := Form6.FDConnection1;
  FDQ8_Suggestions.Connection := Form6.FDConnection1;
end;

procedure TForm8.Button1Click(Sender: TObject);
begin
  // Back to Registration form
  Form6.Show;
  Self.Hide;
end;

procedure TForm8.Button2Click(Sender: TObject);
begin
  // Go to Fees form
  Form7.Show;
  Self.Hide;
end;

procedure TForm8.SpeedButton1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm8.btnSearchQRClick(Sender: TObject);
var
  SearchVal, LName, FName: string;
  CommaPos: Integer;
begin
  SearchVal := Trim(edtSearch.Text);
  if SearchVal = '' then Exit;

  CommaPos := Pos(',', SearchVal);

  try
    FDQ8_Students.Close;
    FDQ8_Students.SQL.Clear;

    // If user typed "LastName, FirstName"
    if CommaPos > 0 then
    begin
      LName := Trim(Copy(SearchVal, 1, CommaPos - 1));
      FName := Trim(Copy(SearchVal, CommaPos + 1, Length(SearchVal)));

      FDQ8_Students.SQL.Add(
        'SELECT * FROM students WHERE last_name = :lname AND first_name = :fname');
      FDQ8_Students.ParamByName('lname').AsString := LName;
      FDQ8_Students.ParamByName('fname').AsString := FName;
    end
    else
    begin
      // Otherwise: search by ID or partial last name
      FDQ8_Students.SQL.Add(
        'SELECT * FROM students WHERE student_id = :search OR last_name LIKE :wildcard');
      FDQ8_Students.ParamByName('search').AsString := SearchVal;
      FDQ8_Students.ParamByName('wildcard').AsString := '%' + SearchVal + '%';
    end;

    FDQ8_Students.Open;

    if FDQ8_Students.IsEmpty then
    begin
      ShowMessage('Student not found in database!');
      Exit;
    end;

    // Fill labels
    lblStudentID.Text := FDQ8_Students.FieldByName('student_id').AsString;
    lblFullName.Text  := FDQ8_Students.FieldByName('last_name').AsString + ', ' +
                         FDQ8_Students.FieldByName('first_name').AsString;
    lblCourse.Text    := FDQ8_Students.FieldByName('course').AsString;
    lblYear.Text      := FDQ8_Students.FieldByName('year_level').AsString;

    if FDQ8_Students.FindField('status') <> nil then
      lblStatus.Text := FDQ8_Students.FieldByName('status').AsString
    else
      lblStatus.Text := 'N/A';

  except
    on E: Exception do
      ShowMessage('Database Error: ' + E.Message);
  end;
end;

procedure TForm8.edtSearchChange(Sender: TObject);
var
  SearchText: string;
begin
  SearchText := Trim(edtSearch.Text);

  if SearchText = '' then
  begin
    lstSuggestions.Visible := False;
    lstSuggestions.Items.Clear;
    Exit;
  end;

  try
    FDQ8_Suggestions.Close;
    FDQ8_Suggestions.SQL.Clear;
    FDQ8_Suggestions.SQL.Add(
      'SELECT last_name, first_name FROM students ' +
      'WHERE last_name LIKE :search LIMIT 5');
    FDQ8_Suggestions.ParamByName('search').AsString := SearchText + '%';
    FDQ8_Suggestions.Open;

    lstSuggestions.Items.Clear;
    while not FDQ8_Suggestions.Eof do
    begin
      lstSuggestions.Items.Add(
        FDQ8_Suggestions.FieldByName('last_name').AsString + ', ' +
        FDQ8_Suggestions.FieldByName('first_name').AsString);
      FDQ8_Suggestions.Next;
    end;

    lstSuggestions.Visible := (lstSuggestions.Items.Count > 0);
    lstSuggestions.BringToFront;

  except
    on E: Exception do
      ShowMessage('Suggestion Error: ' + E.Message);
  end;
end;

procedure TForm8.lstSuggestionsClick(Sender: TObject);
begin
  if lstSuggestions.ItemIndex = -1 then Exit;
  edtSearch.Text := lstSuggestions.Items[lstSuggestions.ItemIndex];
  lstSuggestions.Visible := False;
  btnSearchQRClick(Sender);  // Automatically search after choosing suggestion
end;

procedure TForm8.btnGenerateQRClick(Sender: TObject);
begin
  if Trim(lblStudentID.Text) = '' then
  begin
    ShowMessage('Please search for a student first!');
    Exit;
  end;

  lblQRContent.Text := lblStudentID.Text;
  GenerateOnlineQRCode(lblStudentID.Text);
end;

procedure TForm8.GenerateOnlineQRCode(const QRData: string);
var
  Client: THTTPClient;
  Stream: TMemoryStream;
  EncodedData, URL: string;
begin
  Client := THTTPClient.Create;
  Stream := TMemoryStream.Create;
  try
    EncodedData := TNetEncoding.URL.Encode(QRData);
    URL := 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' + EncodedData;

    try
      if Client.Get(URL, Stream).StatusCode = 200 then
      begin
        Stream.Position := 0;
        imgQR.Bitmap.LoadFromStream(Stream);
      end
      else
        ShowMessage('Download Failed. HTTP Status: ' + IntToStr(Client.Get(URL, Stream).StatusCode));
    except
      on E: Exception do
        ShowMessage('Internet error: ' + E.Message);
    end;
  finally
    Stream.Free;
    Client.Free;
  end;
end;

procedure TForm8.rectSaveQRCodeClick(Sender: TObject);
begin
  if (imgQR.Bitmap = nil) or (imgQR.Bitmap.IsEmpty) then
  begin
    ShowMessage('Please generate a QR code first before saving!');
    Exit;
  end;

  SaveDialog1.Title       := 'Save Student QR Code';
  SaveDialog1.Filter      := 'PNG Image|*.png|JPEG Image|*.jpg';
  SaveDialog1.DefaultExt  := 'png';
  SaveDialog1.FileName    := lblStudentID.Text + '_QRCode';

  if SaveDialog1.Execute then
  begin
    imgQR.Bitmap.SaveToFile(SaveDialog1.FileName);
    ShowMessage('QR Code saved to: ' + SaveDialog1.FileName);
  end;
end;

end.

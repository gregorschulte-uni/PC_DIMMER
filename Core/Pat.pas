unit pat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ComCtrls, gnugettext;

type
  Tpatcontrol = class(TForm)
    pattern: TStringGrid;
    optoabfolge: TEdit;
    Open: TButton;
    Save: TButton;
    start: TButton;
    ablauf: TListBox;
    zeilenanzahl: TEdit;
    zeilenlabel: TLabel;
    Button2: TButton;
    Button3: TButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    pendeln: TCheckBox;
    cancel: TButton;
    resetbtn: TButton;
    procedure patternMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PatternSpeichern(StringGrid: TStringGrid; const FileName: String);
    procedure PatternOeffnen(StringGrid: TStringGrid; const FileName: String);
    procedure SaveClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure startClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure resetbtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  patcontrol: Tpatcontrol;

implementation

{$R *.dfm}

procedure Tpatcontrol.patternMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  Col, Row,i: Integer;
begin
  // Mausposition erkennen und bei Klick in letzte Zeile eine neue Zeile anf�gen
  p := pattern.ScreenToClient(Point(x, y));
  pattern.MouseToCell(p.x, p.y, Col, Row);
  if ((pattern.Row=pattern.RowCount-1) and (pattern.Row<299)) then
  begin
  pattern.RowCount:=pattern.RowCount+1;
  for i:=pattern.Row+1 to pattern.RowCount do pattern.Rows[i].CommaText:=inttostr(i)+',-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-';
  zeilenanzahl.Text:=inttostr(strtoint(zeilenanzahl.Text)+1);
  end;
  if pattern.Cells[pattern.Col,pattern.Row]='[+]' then pattern.Cells[pattern.col,pattern.Row]:='-' else pattern.Cells[pattern.col,pattern.Row]:='[+]';
end;

procedure Tpatcontrol.PatternSpeichern(StringGrid: TStringGrid; const FileName: String);
var
  F: TStringList;
  i: Integer;
begin
  F := TStringList.Create;
  try
    F.Add(IntToStr(StringGrid.RowCount));
    F.Add(IntToStr(StringGrid.ColCount));
    for i := 0 to (StringGrid.RowCount - 1) do
      F.Add(StringGrid.Rows[i].CommaText);
    F.SaveToFile(filename);
  finally
    F.Free;
  end;
end;


procedure Tpatcontrol.PatternOeffnen(StringGrid: TStringGrid; const FileName: String);
var
  F: TStringList;
  i: Integer;
begin
  F := TStringList.Create;
  try
    F.LoadFromFile(FileName);
    StringGrid.RowCount := StrToInt(F[0]);
    StringGrid.ColCount := StrToInt(F[1]);
    for i := 0 to (StringGrid.RowCount - 1) do StringGrid.Rows[i].CommaText := F[i + 2];
  finally
    F.Free;
  end;
end;

procedure Tpatcontrol.SaveClick(Sender: TObject);
begin
if savedialog1.execute then patternspeichern(pattern,savedialog1.filename);
end;

procedure Tpatcontrol.OpenClick(Sender: TObject);
begin
if opendialog1.execute then patternoeffnen(pattern,opendialog1.FileName);
zeilenanzahl.Text:=inttostr(pattern.RowCount-1);
end;

procedure Tpatcontrol.FormCreate(Sender: TObject);
var i:integer;
begin
  TranslateComponent(self);
// 5 Reihen schonmal vorkreieren und dann mit Strichen f�llen, sowie die Randbeschriftungen anbringen (maximal 99 Zeilen - so umfangreich wird sicher keine Lichtshow ;)
  pattern.rows[0].CommaText:=',1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32';
  for i:=1 to 99 do pattern.Rows[i].Text:=inttostr(i);
  for i:=1 to pattern.RowCount-1 do pattern.Rows[i].CommaText:=inttostr(i)+',-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-';
end;

procedure Tpatcontrol.startClick(Sender: TObject);
var
zeilen,killold,i,durchlauf:integer;
pat,channel:string;
begin
channel:='';
durchlauf:=0;
ablauf.Clear;
// Alle Informationen auf dem K�stchenwirrwarr sauber in eine Listbox auflisten
for zeilen:=1 to pattern.RowCount do
begin
  pat:=pattern.Rows[zeilen].CommaText;
  pat:=copy(pat,2,length(pat));
  ablauf.Items.CommaText:=ablauf.Items.CommaText+pat;
end;
  // Erste Stelle l�schen, da sonst da nur eine leere Stelle ist (ist ja die �berschrift)
  ablauf.Items.Delete(0);

  // Pro Zeile 32 Eintr�ge, also m�ssen wir zu den Zeilen auch die Spalten durchlaufen lassen
  for zeilen:=0 to pattern.RowCount-2 do
  begin
    for i:=0 to 31 do if ablauf.Items.Strings[i]='[+]' then channel:=channel+','+inttostr(i+1);
    for killold:=0 to 31 do ablauf.Items.Delete(0);
    durchlauf:=durchlauf+1;
    channel:=channel+',next'+inttostr(durchlauf);
  end;

  channel:=copy(channel,2,length(channel)-6);

  ablauf.Clear;
  ablauf.Items.CommaText:=channel;

  // Kan�le 1-32 in Bitz�hlweise �berf�hren, um sp�ter zwischen Ger�ten 1-4 aufteilen zu k�nnen
  if ablauf.Items.Count>0 then
  begin
  for i:=0 to (ablauf.Items.Count-1) do
  begin
    if length(ablauf.Items.Strings[i])<=2 then
    begin
      if ablauf.Items.Strings[i]='32' then ablauf.Items.Strings[i]:='512';
      if ablauf.Items.Strings[i]='31' then ablauf.Items.Strings[i]:='448';
      if ablauf.Items.Strings[i]='30' then ablauf.Items.Strings[i]:='416';
      if ablauf.Items.Strings[i]='29' then ablauf.Items.Strings[i]:='400';
      if ablauf.Items.Strings[i]='28' then ablauf.Items.Strings[i]:='392';
      if ablauf.Items.Strings[i]='27' then ablauf.Items.Strings[i]:='388';
      if ablauf.Items.Strings[i]='26' then ablauf.Items.Strings[i]:='386';
      if ablauf.Items.Strings[i]='25' then ablauf.Items.Strings[i]:='385';

      if ablauf.Items.Strings[i]='24' then ablauf.Items.Strings[i]:='384';
      if ablauf.Items.Strings[i]='23' then ablauf.Items.Strings[i]:='320';
      if ablauf.Items.Strings[i]='22' then ablauf.Items.Strings[i]:='288';
      if ablauf.Items.Strings[i]='21' then ablauf.Items.Strings[i]:='272';
      if ablauf.Items.Strings[i]='20' then ablauf.Items.Strings[i]:='264';
      if ablauf.Items.Strings[i]='19' then ablauf.Items.Strings[i]:='260';
      if ablauf.Items.Strings[i]='18' then ablauf.Items.Strings[i]:='258';
      if ablauf.Items.Strings[i]='17' then ablauf.Items.Strings[i]:='257';

      if ablauf.Items.Strings[i]='16' then ablauf.Items.Strings[i]:='256';
      if ablauf.Items.Strings[i]='15' then ablauf.Items.Strings[i]:='192';
      if ablauf.Items.Strings[i]='14' then ablauf.Items.Strings[i]:='160';
      if ablauf.Items.Strings[i]='13' then ablauf.Items.Strings[i]:='144';
      if ablauf.Items.Strings[i]='12' then ablauf.Items.Strings[i]:='136';
      if ablauf.Items.Strings[i]='11' then ablauf.Items.Strings[i]:='132';
      if ablauf.Items.Strings[i]='10' then ablauf.Items.Strings[i]:='130';
      if ablauf.Items.Strings[i]='9' then ablauf.Items.Strings[i]:='129';

      if ablauf.Items.Strings[i]='8' then ablauf.Items.Strings[i]:='128';
      if ablauf.Items.Strings[i]='7' then ablauf.Items.Strings[i]:='64';
      if ablauf.Items.Strings[i]='6' then ablauf.Items.Strings[i]:='32';
      if ablauf.Items.Strings[i]='5' then ablauf.Items.Strings[i]:='16';
      if ablauf.Items.Strings[i]='4' then ablauf.Items.Strings[i]:='8';
      if ablauf.Items.Strings[i]='3' then ablauf.Items.Strings[i]:='4';
      if ablauf.Items.Strings[i]='2' then ablauf.Items.Strings[i]:='2';
      if ablauf.Items.Strings[i]='1' then ablauf.Items.Strings[i]:='1';
    end;
  end;
  channel:=ablauf.Items.CommaText;
  end;


channel:=channel+'endedesablaufes';
ablauf.Clear;
optoabfolge.text:=channel;
end;



procedure Tpatcontrol.Button2Click(Sender: TObject);
begin
if pattern.RowCount>2 then
begin
  pattern.RowCount:=pattern.RowCount-1;
  zeilenanzahl.Text:=inttostr(strtoint(zeilenanzahl.Text)-1);
end;
end;

procedure Tpatcontrol.Button3Click(Sender: TObject);
begin
if pattern.RowCount<300 then
begin
  pattern.RowCount:=pattern.RowCount+1;
  pattern.Rows[pattern.RowCount-1].CommaText:=inttostr(pattern.RowCount-1)+',-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-';
  zeilenanzahl.Text:=inttostr(strtoint(zeilenanzahl.Text)+1);
end;
end;

procedure Tpatcontrol.resetbtnClick(Sender: TObject);
begin
  if messagedlg('Programmablauf wirklich zur�cksetzen?',mtConfirmation,
     [mbYes,mbNo],0)=mrYes then
     begin
       pattern.RowCount:=2;
       pattern.Rows[1].CommaText:=inttostr(1)+',-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-';
       zeilenanzahl.Text:='1';
     end;
end;

end.



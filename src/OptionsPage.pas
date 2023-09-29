unit OptionsPage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, RichEdit, Menus;

type
  TOptions = record
    CheckYo: boolean;
    NoVarOnly: boolean;
    VarOnly: boolean;
    AlwaysAsk: boolean;
    ToConfirmAbbr: boolean;
    ToConfirmCap: boolean;
    ToConfirmEllipsis: boolean;
    ProposeLast: boolean;
    RegExprs: boolean;
    FastScroll: boolean;
    Mark: boolean;
    WordWrap: boolean;
    LastFile: boolean;
    ToConfirmClose: boolean;
    FBFormat: boolean;
    AutoUnicode: boolean;
    LinesBelow: integer;
    EditorFontName: TFontName;
    EditorFontCharset: TFontCharset;
    EditorFontSize: integer;
    clMark, clBackMark, clEditorWindow: TColor;
    FontEnabled: boolean;
    RegExprsEnabled: boolean;
    ProxyName: string;
    ProxyPort: integer;
    ShowToolBar: boolean;
  end;
  TOptionsForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    cbCheckYo: TCheckBox;
    cbNoVarOnly: TCheckBox;
    cbVarOnly: TCheckBox;
    cbAlwaysAsk: TCheckBox;
    cbToConfirmAbbr: TCheckBox;
    cbToConfirmCap: TCheckBox;
    cbToConfirmEllipsis: TCheckBox;
    cbProposeLast: TCheckBox;
    cbRegExprs: TCheckBox;
    cbFBFormat: TCheckBox;
    Panel1: TPanel;
    bOK: TButton;
    bCancel: TButton;
    Label1: TLabel;
    eLinesBelow: TEdit;
    cbWordWrap: TCheckBox;
    cbLastFile: TCheckBox;
    bFont: TButton;
    FontDialog1: TFontDialog;
    SampleEditor: TRichEdit;
    bMark: TButton;
    ColorDialog1: TColorDialog;
    bBackMark: TButton;
    cbAutoUnicode: TCheckBox;
    cbFastScroll: TCheckBox;
    cbMark: TCheckBox;
    bOKSave: TButton;
    MainMenu1: TMainMenu;
    cbShowToolbar: TCheckBox;
    cbToConfirmClose: TCheckBox;
    procedure bOKClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bFontClick(Sender: TObject);
    procedure bMarkClick(Sender: TObject);
    procedure bBackMarkClick(Sender: TObject);
    procedure cbClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bOKSaveClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetSelBgColor(AColor: TColor);
    procedure ShowEditor;
    function SetOptions: boolean;
    procedure SetColor( Var c: TColor );
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;
  NewYoOptions, YoOptions, DefaultYoOptions: TOptions;

implementation

{$R *.dfm}

procedure TOptionsForm.SetSelBgColor(AColor: TColor);
var
  Format: TCharFormat2;
begin
// костыль для маскировки возможной ошибки EReadError
  try
    FillChar(Format, SizeOf(Format), 0);
    with Format do
    begin
      cbSize := SizeOf(Format);
      dwMask := CFM_BACKCOLOR;
      crBackColor := AColor;
      SampleEditor.Perform(EM_SETCHARFORMAT, SCF_SELECTION, Longint(@Format));
    end;
  except
    on E: EReadError do
      SampleEditor.Text := 'EReadError 1'
  end;
end;

procedure TOptionsForm.ShowEditor;
begin
  with NewYoOptions, SampleEditor do
  begin
    SelectAll;
    with SampleEditor.Font do
    begin
      SelAttributes.Name := NewYoOptions.EditorFontName;
      SelAttributes.Size := NewYoOptions.EditorFontSize;
      SelAttributes.Charset := NewYoOptions.EditorFontCharset;
    end;
    SelStart := 5;
    SelLength := 1;
    if cbMark.Checked then
    begin
      SelAttributes.Color := clMark;
      SetSelBgColor(clBackMark);
    end else
    begin
      SelAttributes.Color := SampleEditor.Font.Color;
      SetSelBgColor(clEditorWindow);
    end;
    SelStart := 0;
    SelLength := 0;
  end
end;

function TOptionsForm.SetOptions: boolean;
begin
  Result := True;
  with NewYoOptions do
  begin
    CheckYo := cbCheckYo.Checked;
    NoVarOnly := cbNoVarOnly.Checked;
    VarOnly := cbVarOnly.Checked;
    AlwaysAsk := cbAlwaysAsk.Checked;
    ToConfirmAbbr := cbToConfirmAbbr.Checked;
    ToConfirmCap := cbToConfirmCap.Checked;
    ToConfirmEllipsis := cbToConfirmEllipsis.Checked;
    ProposeLast := cbProposeLast.Checked;
    RegExprs := cbRegExprs.Checked;
    FastScroll := cbFastScroll.Checked;
    Mark := cbMark.Checked;
    WordWrap := cbWordWrap.Checked;
//    ToConfirm := cbToConfirm.Checked;
    LastFile := cbLastFile.Checked;
    ToConfirmClose := cbToConfirmClose.Checked;
    FBFormat := cbFBFormat.Checked;
    AutoUnicode := cbAutoUnicode.Checked;
    try
      LinesBelow := StrToInt( eLinesBelow.Text );
    except
      Result := False;
    end;
    ShowToolBar := cbShowToolbar.Checked;
  end;
end;

procedure TOptionsForm.bOKClick(Sender: TObject);
begin
  if SetOptions then
    ModalResult := mrOK;
end;

procedure TOptionsForm.bOKSaveClick(Sender: TObject);
begin
  if SetOptions then
    ModalResult := mrYes;
end;

procedure TOptionsForm.bCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  with NewYoOptions do
  begin
    cbCheckYo.Checked := CheckYo;
    cbNoVarOnly.Checked := NoVarOnly;
    cbVarOnly.Checked := VarOnly;
    cbAlwaysAsk.Checked := AlwaysAsk;
    cbToConfirmAbbr.Checked := ToConfirmAbbr;
    cbToConfirmCap.Checked := ToConfirmCap;
    cbToConfirmEllipsis.Checked := ToConfirmEllipsis;
    cbProposeLast.Checked := ProposeLast;
    cbRegExprs.Checked := RegExprs;
    cbFastScroll.Checked := FastScroll;
    cbMark.Checked := Mark;
    cbWordWrap.Checked := WordWrap;
//    cbToConfirm.Checked := ToConfirm;
    cbLastFile.Checked := LastFile;
    cbToConfirmClose.Checked := ToConfirmClose;
    cbFBFormat.Checked := FBFormat;
    cbAutoUnicode.Checked := AutoUnicode;
    eLinesBelow.Text := Format( '%d', [LinesBelow] );
    SampleEditor.Font.Name := EditorFontName;
    SampleEditor.Font.Size := EditorFontSize;
    SampleEditor.Font.Charset := EditorFontCharset;
    bFont.Enabled := FontEnabled;
    cbRegExprs.Enabled := RegExprsEnabled;
    cbShowToolbar.Checked := ShowToolBar;
    cbClick( nil );
    ShowEditor;
  end
end;

procedure TOptionsForm.bFontClick(Sender: TObject);
begin
  with NewYoOptions do
  begin
    FontDialog1.Font.Size := EditorFontSize;
    FontDialog1.Font.Name := EditorFontName;
    FontDialog1.Font.Charset := EditorFontCharset;
    FontDialog1.Font.Style := [];
    if FontDialog1.Execute then
    begin
      EditorFontName := FontDialog1.Font.Name;
      EditorFontSize := FontDialog1.Font.Size;
      EditorFontCharset := FontDialog1.Font.Charset;
      ShowEditor;
    end;
  end;
end;

procedure TOptionsForm.SetColor( Var c: TColor );
begin
  with ColorDialog1 do
  begin
    Color := c;
    if Execute then
    begin
      c := Color;
      ShowEditor;
    end;
  end;
end;

procedure TOptionsForm.bMarkClick(Sender: TObject);
begin
  SetColor( NewYoOptions.clMark );
end;

procedure TOptionsForm.bBackMarkClick(Sender: TObject);
begin
  SetColor( NewYoOptions.clBackMark );
end;

procedure TOptionsForm.cbClick(Sender: TObject);
begin
  cbToConfirmAbbr.Enabled := not cbAlwaysAsk.Checked;
  cbToConfirmEllipsis.Enabled := not cbAlwaysAsk.Checked;
  cbToConfirmCap.Enabled := not cbAlwaysAsk.Checked;
  cbVarOnly.Enabled := not cbNoVarOnly.Checked;
  cbNoVarOnly.Enabled := not cbVarOnly.Checked;
  bMark.Enabled := cbMark.Checked;
  bBackMark.Enabled := cbMark.Checked;
  try
    SampleEditor.WordWrap := cbWordWrap.Checked;
  except
    on E: EReadError do
      SampleEditor.Text := 'EReadError 4'
  end;
  ShowEditor;
end;

procedure TOptionsForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then // Esc
    ModalResult := mrCancel;
end;

end.

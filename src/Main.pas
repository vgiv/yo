unit Main;

{$INCLUDE Yo.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ComCtrls, IniFiles, MyLists,
  RichEdit, ExtCtrls, Mask, RegExpr, GsvUnicodeRichEdit, CommDlg,
  DialogEnc, OptionsPage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, ToolWin, ImgList, StdActns, ActnList, CommCtrl;

Const
  Year = 2019;
  // Цвета
  clDicMark = clRed; // цвет выделения в РС
  clEditorWindow: TColor = clWhite;
  clMarkWrong = clAqua;
  clAskPanelActive = $00FFC0C0;
  clAskPanelPassive = $00C0C0FF;
  //
  LinesBelow0 = 2;
  WordsBufferLength: integer = 5;
  //
  FirstEditorChange: boolean = True;
  RegExprLog: boolean = False;
  FileNamesInList: integer = 0;
  MaxFileNamesInList: integer = 9;
  //
  VerStr = 'Версия:';
  msgAtt = 'Внимание';
  msgError = 'Ошибка';
  msgInfo = 'Информация';
  msgDisorderWord = 'Порядок слов в словаре нарушен словом "%s"';
  msgNoDic = 'Не задан файл словаря';
  msgFileNotFound = 'Файл "%s" не найден';
  msgBadString = 'В строке словаре содержится неверная строка "%s"';
  msgNoYo = 'Слово "%s" из словаря не содержит буквы "Ё"';
  msgNotRegExpr = 'В словаре регулярных выражений содержится неверное выражение "%s"';
  msgWasOldFormatRE = 'Словарь регулярных выражений имеет старый формат.'#13'Прочитайте yo_plus.html, чтобы узнать, как переформатировать его.' ;
  msgRewrite = 'Файл %s существует. Переписать?';
  msgToSave = 'Файл был изменён. Сохранить изменения?';
  msgClear = 'Очистить список последних файлов?';
  msgClearStat = 'Обнулить статистку ёфикации?';
  msgMayBeLost = 'При сохранении файла в данном формате'#13'некоторые символы могут быть потеряны.'#13' Продолжить?';
  msgUTF16BE = 'Файл имеет кодировку UTF-16 (big endian).'#13'К сожалению, программа не сможет его правильно прочитать.';
  msgUTF8Warning = 'Внимание! Файлы формата UTF-8 обычно обрабатываются программой очень медленно.'#13'Вы уверены, что хотите загружать подобные файлы?';
  msgNoMenuItems = 'Эзотерическая ошибка #1: не найден пункт меню "%s"';
  msgLoadDic = 'Загрузка словаря';
  msgLoadRegExprDic = 'Загрузка словаря регулярных выражений';
  NoMenuItemName: string = '';
  StatusBarHint = 't=t1+t2 - полное число проверок (t1 - с заменой, t2 - без земены)'#13#10+
  'A=a1+a2 - число проверок слов с запросом (a1 - с заменой, a2 - без земены)'#13#10+
  'RE=r1+r2 - число применений СРВ (r1 - с заменой, r2 - без земены)'#13#10+
  'REQ - эффективность СРВ'#13#10+
  'E - число замен Ё на Е'#13#10+
  'T - время работы (сек)'#13#10+
  'S - скорость работы (замен/сек)';
  ToolBarHint = 'Дважды щёлкните здесь для настройки панели инструментов';
  OldStatusBarText: string = '';
  MySpaceChars = ' '#$9#$A#$D#$C#160;
  MyWordChars = {'0123456789'
  + 'abcdefghijklmnopqrstuvwxyz'
  + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  + }'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
  + 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя';
// для AskPanel
  mrYe = $FF01;
  mrYo = $FF02;
  mrYeAll = $FF03;
  mrYoAll = $FF04;
  mrUndo = $FF05;
// для Save/Load
  ttRTF = $01;
  ttUTF8 = $02;
  ttUTF16LE = $04;
  ttUTF16BE = $08; // does not support !
  ttUTFsgn = $10;
  ttUTF16 = ttUTF16LE or ttUTF16BE;
  ttUnicode = ttUTF8 or ttUTF16;
  UnicodeSignatureUTF16LE: word = $FEFF;
  UnicodeSignatureUTF16BE: word = $FFFE;
  UnicodeSignatureUTF8a: word = $BBEF;
  UnicodeSignatureUTF8b: byte = $BF;
  AnsiIndex = 0;
  UTF8Index = 1;
  UTF16Index = 2;
  DateFormat = 'dd-mm-yyyy';
  MaxToolButtonsQ = 50;

type
  TDynArrayInt = array of integer;
  TStrCompare = function( Const s1, s2: string ): integer;
  TDic = class
    Ye, Yo: TStringList;  //словарь словоформ
    WordsAsk, WordsAnswer, UserSel: TShortIntList;
    Ye2Ye, Ye2Yo, Yo2Ye, Yo2Yo: TIntegerList;
    constructor Create;
    procedure Clear;
  end;
  TRegExprDic = class
    W0: TStringList;
    W: TStringList;
    RE: TRegExprList;
    Was: TIntegerList;
    constructor Create;
    procedure Clear;
    function AddWord(s: string): boolean;
  end;
  TRichEditU = class(TGsvUnicodeRichEdit)
    private
      procedure SetSelectionMarkColor( AColor: TColor );
      function GetLine(i: integer): WideString;
      procedure PutLine(i: integer; const s: WideString);
      procedure RestoreFocus(Sender: TObject);
    public
      procedure GetLinePosition( Const Idx: integer; Var LineN, PosN: integer );
      procedure UpdateCursorPosition( StatusBar: TStatusBar; PanelN: integer );
      procedure GoAndShowPosition( Const i: integer );
      procedure LoadFromFile( Const FileName: TFileName; const TextType: integer );
      procedure SaveToFile( Const FileName: TFileName; const TextType: integer );
      procedure LinesAdd( Const s: WideString );
      procedure SetSelSize( s: integer );
      procedure SetSelColor( c: TColor );
      function GetSelColor: TColor;
      procedure SetSelBackColor( c: TColor );
      function GetSelBackColor: TColor;
      procedure SetSelStyle( s: TFontStyles );
      procedure SetSelName( Const n: string );
      function GetDefSize: integer;
      property Lines[Index: Integer]: WideString read GetLine write PutLine; default;
      property SelectionMarkColor: TColor write SetSelectionMarkColor;
  end;
  TDialogEx = class(TDialogEnc)
   protected
     procedure DoShow; override;
   public
    TypeOfText: integer;
    function Execute: boolean; override;
  end;
  TOpenDialogEx = class(TDialogEx)
    constructor Create(AOwner: TComponent); override;
  end;
  TSaveDialogEx = class(TDialogEx)
    constructor Create(AOwner: TComponent); override;
    function Execute: boolean; override;
  end;
  TToolButtonX = class(TToolButton)
    constructor Create(AOwner: TComponent); reintroduce;
  end;
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Yo1: TMenuItem;
    StatusBar1: TStatusBar;
    File1: TMenuItem;
    Open1: TMenuItem;
    Saveas1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Selectall1: TMenuItem;
    Help1: TMenuItem;
    Setting1: TMenuItem;
    Yobegin1: TMenuItem;
    Yopos1: TMenuItem;
    FindDialog1: TFindDialog;
    N2: TMenuItem;
    Find1: TMenuItem;
    About1: TMenuItem;
    Moreabout1: TMenuItem;
    Close1: TMenuItem;
    N3: TMenuItem;
    Undo1: TMenuItem;
    odDic: TOpenDialog;
    OpenDic1: TMenuItem;
    OpenRegExprDic1: TMenuItem;
    Copytodicedit1: TMenuItem;
    RemoveMarked1: TMenuItem;
    Clearusersel1: TMenuItem;
    Clearfilelist1: TMenuItem;
    AskPanel: TPanel;
    bYe: TButton;
    bYeAll: TButton;
    bYo: TButton;
    bUndo: TButton;
    bYoAll: TButton;
    bCancel: TButton;
    lSample: TLabel;
    lCaption: TLabel;
    AskBevel: TBevel;
    AskRightRect: TShape;
    AskColorRect: TShape;
    Findreg1: TMenuItem;
    Openfile0: TMenuItem;
    AskLeftRect: TShape;
    Findagain1: TMenuItem;
    Fileprop1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Findyyfwd1: TMenuItem;
    Findyyback1: TMenuItem;
    Save1: TMenuItem;
    Options1: TMenuItem;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    EditPaste1: TEditPaste;
    WindowCascade1: TWindowCascade;
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Saveas1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure DoYoficate( LineN, PosN: integer );
    procedure Yobegin1Click(Sender: TObject);
    procedure Yopos1Click(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FindDialog1Find(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Moreabout1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure Undo1Click(Sender: TObject);
    procedure OpenDic1Click(Sender: TObject);
    procedure OpenRegExprDic1Click(Sender: TObject); //for EditDic
    procedure Copytodicedit1Click(Sender: TObject);
    procedure EditorSelectionChange(Sender: TObject);
    procedure Clearusersel1Click(Sender: TObject);
    procedure Clearfilelist1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bYeClick(Sender: TObject);
    procedure bYoClick(Sender: TObject);
    procedure bYeAllClick(Sender: TObject);
    procedure bYoAllClick(Sender: TObject);
    procedure bUndoClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bYeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bYoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bYeAllMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bYoAllMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Findreg1Click(Sender: TObject);
    procedure Findagain1Click(Sender: TObject);
    function FindMenuItem( ItemName: string ): TMenuItem;
    function FindToolbarItem( ItemName: string ): TToolButtonX;
    procedure AddButtonToToolBar( ItemName: string );
    procedure FormCreate(Sender: TObject);
    procedure Fileprop1Click(Sender: TObject);
    procedure Findyyfwd1Click(Sender: TObject);
    procedure Findyyback1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure FindDialog1Close(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure CreateToolButtons;
    procedure RemoveMarked1Click(Sender: TObject);
  public
    { Public declarations }
    Editor: TRichEditU;
    reAskText: TRichEditU;
    FEdited: boolean;
    YoRunning: boolean;
    AskResult: TModalResult;
    RedefiningKey: TMaskEdit;
    odxText: TOpenDialogEx;
    sdxText: TSaveDialogEx;
    ToolBarImageList: TImageList;
    Testing1: TMenuItem;
    procedure AddToStat( Idx: integer; Const oldWord, newWord: string; DicWordIndex: integer );
    procedure ChangeLetter( Idx: integer; Const oldWord, newWord: string );
    procedure CheckWord( Idx: integer; Const cWord: string; Var ToCancel: boolean );
    procedure CheckWordEx( cLineN, cPosN: integer; Const cNotWord, cWord: string; CurrentChar: char; Var ToCancel: boolean );
    function IsItAbbreviation( c: char; LineN, PosN: integer ): boolean;
    function IsItEllipsis( c: char; LineN, PosN: integer ): boolean;
    procedure Yoficate( LineN0, PosN0: integer );
    function FindReplacement( Const WordYe: string; Var ToAsk: boolean; Var Index, WordToFocusN: integer; Var Always: boolean ): string;
    function SelectWord( Const cWord: string; Const Idx: integer; Var ToCancel: boolean;
      Var DicWordIndex, WordToFocusN: integer;  Var WrongYo: boolean ): string;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure UpdateCursorPos( i: integer );
    procedure StatusInfo( Const s: string );
    procedure ShowStatus;
    procedure WaitCursor;
    procedure NormCursor;
    procedure GoAndShowPosition( const i: integer );
    procedure FileLoad( Const FileName: string; Const FileType: integer );
    function CanBeClosed: boolean;
    procedure SetEdited( Const Value: boolean );
    property Edited: boolean read FEdited write SetEdited;
    procedure ReadIni;
    procedure WriteIni;
    procedure SetWordWrap( Value: boolean );
    procedure ReadParameters;
    function OpenText( Const s: TFileName; Const FileType: integer ): boolean;
    procedure AddUndo(p1, p2: integer; c: char; Color: TColor; OldWord, NewWord: string );
    procedure ClearUndo;
    procedure ClearYYPos;
    procedure MakeUndo;
    function UndoCaption: string;
    function DicExist: boolean;
    procedure WriteToRegExprLog( Const s: string );
    procedure SetMenuItem( ItemName: string; v: boolean );
    procedure SetControls;
    procedure RemoveMarkedLetters;
    procedure AddFileToList( Const s: TFileName; p: integer; const TextType: integer );
    procedure OpenTextInList( Sender: TObject );
    procedure RememberFileNamesPos;
    function GetFileNamesN( Const s: TFileName ): integer;
    function GetFileNamesPos( Const s: TFileName ): integer;
    procedure LoadAll(Sender: TObject; var Done: Boolean);
    procedure WaitStatus( Msg: string );
    procedure WaitStatusIf( Msg: string );
    procedure NoWaitStatus;
    function WaitForAnswer: TModalResult;
    procedure EnableAskControls( v: boolean );
    procedure EnableMenu( v: boolean );
    function FindContext( i: integer; Var SelStart0, SelLength0: integer ): WideString;
    procedure SetAskParams( Const w1, w2: string; WrongYo, ReplacedYo, WrongYe: boolean;
      ToFocusFirst: boolean; Const UndoCaption: string );
    procedure InitAskParams;
    procedure AlignAskPanel;
    function DefineTextWidth( Const s: string; Font: TFont ): integer;
    function FindTextLength( i: integer; Font: TFont ): integer;
    procedure NewEditorWinProc( Var Msg: TMessage );
    procedure SetAskPanelView( v: boolean );
    procedure NewMainFormWinProc( var Msg: TMessage );
    procedure SetButtonHotKey( i: integer; c: char );
    procedure RedefineKeyInit;
    procedure RedefineKeyPress(Sender: TObject; var Key: Char);
    procedure RedefineKey( Sender: TObject );
    procedure InitButtons;
    procedure DisableButtons;
    procedure EnableButtons;
    function GetDicVersion( Const s:string ): string;
    procedure InitData;
    procedure ReadDic;
    procedure ReadRegExprDic;
    procedure CalculateFileProp;
    procedure SaveFile;
    function SaveFileAs: boolean;
    procedure FillToolBarImageList;
    procedure SetToolBarSeparators;
  end;
  // Общие функции
  procedure X( Const s: string );
  function IsEsc: boolean;
  procedure ClearEsc;
  procedure Error( Const Msg: string );
  procedure Info( Const Msg: string );
  function Warning( Const Msg: string; DefaultYes: boolean ): boolean;
  function WarningX( Const Msg: string; DefaultAnswer: word ): word;
  function CanBeRewriten( Const FileName: TFileName ): boolean;
  function RemoveProgramDir( Const FileName: TFileName ): TFileName;
  function AddProgramDir( Const FileName: TFileName ): TFileName;
  procedure SetCaptionAsterix( Form: TForm; Edited: boolean );
  // Функции анализа строк
  function DosFromWin( Const s: string ): string;
  function ContainsChar( Const s: string; c: char ): boolean;
  function IsComment( Const s: string ): boolean;
  function IsNumeric( c: char ): boolean;
  function IsUpper( c: char ): boolean;
  function IsLower( c: char ): boolean;
  function IsAlpha( c: char ): boolean;
  function IsAlphaQ( c: char ): boolean;
  function IsWord( Const s: string ): boolean;
  function IsWordQ( Const s: string ): boolean;
  function IsAnyUpperCase( Const s: string ): boolean;
  function RegExprWordLen( Const s: string ): integer;
  function CopyCase( Const w, wCase: string ): string;
  function IsBlank( c: char ): boolean;
  function PosFrom( Const Substr, S: string; p0: integer ): integer;
  function LastChar( Const s: string ): string;
  function DropLastChar( Const s: string ): string;
  function LC( Const s: string): string;
  function ToYe( Const s: string ): string;
  function IsYo( c: char ): boolean;
  function IsYe( c: char ): boolean;
  function IsYeYo( c: char ): boolean;
  function IsYoIn( Const s: string ): boolean;
  function IsYeYoIn( Const s: string ): boolean;
  function IsYeYoIf( Const s: string ): boolean;
  function ListCmpYe( List: TStringList; i1, i2: integer): integer;
  function ListCmpYeEx( List: TStringList; i1, i2: integer): integer;
  function Cmp( Const s10, s20: string ): integer;
  function CmpYe( Const s10, s20: string ): integer;
  function CmpYeEx( Const s10, s20: string ): integer;
  function CmpYeExLC( Const s10, s20: string ): integer;
  procedure Replace( Var s: string; i: integer; Var s1, s2: string );
  function Cas( i, Mode: integer ): string;
  //
  procedure GetLinePosInEditor( RE: TRichEdit; Const Idx: integer; Var LineN, PosN: integer );
  procedure GoAndShowPositionInEditor( RE: TRichEdit; Const i: integer ); overload;
  procedure GoAndShowPositionInEditor( RE: TRichEditU; Const i: integer ); overload
  procedure UpdateCursorPosInEditor( RE: TRichEdit; StatusBar: TStatusBar; PanelN: integer );
  function FindInStrings( List: TStrings; s: string; Compare: TStrCompare  ): integer;
  function FindInStringsUL( List: TStrings; Const s: string ): integer;
  function FindPlaceInStrings( List: TStrings; p1, p2: integer; Const s: string; Compare: TStrCompare ): integer;
  procedure CopyToDicEdit( Const s: string );
  procedure SetButtonCaption( b: TButton; Const s: string );
  function LookInRegExps( Const cWord: string; Idx: integer; Const Word1, Word2: string; Var WordN: integer ): boolean;
  function IsValidRegExpr( Const s: string; Var ID: integer ): boolean;
//
  procedure FindInText( RE: TRichEdit; FD: TFindDialog; Var FF: boolean; IsRegExp: boolean ); overload;
  procedure FindInText( RE: TRichEditU; FD: TFindDialog; Var FF: boolean; IsRegExp: boolean ); overload;
  function ContainsWideChar( Const s: WideString; c: WideChar ): boolean;
  function UnicodeTextType( Const FileName: TFileName; Auto: boolean ): byte;
  function RTFTextType( Const FileName: TFileName ): byte;

Var
  MainForm: TMainForm;
  Dic: TDic;
  FirstDisorder, WordNoYo: string;
  WasAsk: boolean;
  WrongWord: string;
  FirstFind: boolean;
  FoundLength: integer;
  ProgramDirectory, TextDirectory: TFileName;
  FullIniFileName: TFileName;
  TextFileName: TFileName; //текстовый файл
  RegExprTextFileName: TFileName;
  RegExprLogName: TFileName;
  TextFileType: integer;
  TextFilePos: integer;
  DicFileName: TFileName;  //файл словаря
  RegExprDicFileName: TFileName;  //файл словаря рег. выражений
// таблицы отката и замены
  UndoP1, UndoP2, UndoColor: TIntegerList;
  UndoLetter: string;
  UndoOldWord, UndoNewWord: TStringList;
  ToMakeUndo: boolean;
// координаты окна
  WindowHeight, WindowWidth, WindowTop, WindowLeft: integer;
// файл инициализации
  IniFile: TIniFile;
// для режима рег выражений
  RegExprDic: TRegExprDic;
  WordsBufferLength2: integer;
  tmpRegExpr: TRegExpr;
//
  fRegExprlog: TextFile;
//
  DicReloadRequest, RegExprDicReloadRequest: boolean;
//
  FileNamesFirstItemN: integer;
  FileNamesPos: TIntegerList;
  FileNamesTextType: TIntegerList;
//
  FindEditor: TObject;
//
  RunTime0: TDateTime;
//
  AskFormHeight: integer;
//
  EditorWinProc: TWndMethod;
//
  Buttons: array[1..6] of TButton;
  ButtonsEnabled: array[1..6] of boolean;
  ButtonHotKeys: string[4];
  ButtonTag: integer;
//
  FindRegExpr: TRegExpr;
  IsRegExpr: boolean;
//
  ToCheckAbbreviation: boolean;
  ToCheckEllipsis: boolean;
//
  UndoEnabled: boolean;
//
  FindAgain: boolean;
  FindNextWasPressed: boolean;
  WasFindReg: boolean;
// дял Юникода
  UCF: TGsvUnicodeCharFormat;
  UnicodeType: byte;
//
  odxRTFIndex, sdxRTFIndex: integer;
  AskPanelFocusFirst: boolean;
//
  YYPos: TIntegerList;
//
  UTF8Warning: boolean;
  UTFLength: integer; //длина блока (в словах) для распознавания UTF

Type
 TLetterStat = object
   A, Changed, NotChanged: integer;
   procedure Clear;
 end;

Var
 CheckedLS, AskedLS, RELS: TLetterStat;
 NoRELS: integer;
 WrongYoLS: integer;
 CollectedYo: integer;

Type
  TFileProps = record
    FileName: TFileName;
    FileFormat: string;
  end;

Var
  FileProps: TFileProps;

Type
// список для сбора всех пунктов меню, которых нет на тулбаре
  TMenuItemsX = class(TStringList)
    constructor Create;
  end;

Var
  MenuItemsX: TMenuItemsX;

implementation

{$R *.DFM}

uses About, Math, ShellAPI, Input, StrUtils,
  FileProp, Commons;

{*** Общие функции }

procedure X( Const s: string );
begin
  Application.MessageBox( PChar(s), '', MB_OK );
end;

function IsEsc: boolean;
begin
  Result := GetAsyncKeyState( VK_ESCAPE ) <> 0;
end;

procedure ClearEsc;
// убрать Esc из буфера клавиатуры
begin
  while IsEsc do;
end;

procedure Error( Const Msg: string );
// вывести ошибку
begin
  Application.MessageBox( PChar(Msg), msgError, MB_OK or MB_ICONERROR );
end;

procedure Info( Const Msg: string );
// вывести информацию
begin
  Application.MessageBox( PChar(Msg), msgInfo, MB_OK or MB_ICONINFORMATION );
end;

function Warning( Const Msg: string; DefaultYes: boolean ): boolean;
// вывести предупреждение с вопросом
Var
  DefaultButton: word;
begin
  if DefaultYes then
    DefaultButton := MB_DEFBUTTON1
  else
    DefaultButton := MB_DEFBUTTON2;
  Result :=
    Application.MessageBox( PChar(Msg), msgAtt, MB_YESNO or MB_ICONWARNING or DefaultButton ) = IDYES;
end;

function WarningX( Const Msg: string; DefaultAnswer: word ): word;
// вывести расширенное предупреждение с вопросом
Var
  DefaultButton: word;
begin
  case DefaultAnswer of
    1: DefaultButton := MB_DEFBUTTON1; // Yes
    2: DefaultButton := MB_DEFBUTTON2; // No
    3: DefaultButton := MB_DEFBUTTON3; // Cancel
  else
    DefaultButton := MB_DEFBUTTON3; // Cancel
  end;
  Result := Application.MessageBox( PChar(Msg), msgAtt, MB_YESNOCANCEL or MB_ICONWARNING or DefaultButton );
end;

function CanBeRewriten( Const FileName: TFileName ): boolean;
begin
  Result := Warning( Format( msgRewrite, [FileName]), False );
end;

function RemoveProgramDir( Const FileName: TFileName ): TFileName;
begin
  if ExtractFileDir( FileName ) = ProgramDirectory then
    Result := ExtractFileName( FileName )
  else
    Result := FileName;
end;

function AddProgramDir( Const FileName: TFileName ): TFileName;
begin
  if FileName='' then
    Result := ''
  else if ExtractFileDir( FileName ) = '' then
    Result := ProgramDirectory + '\' + FileName
  else
    Result := FileName;
end;

procedure SetCaptionAsterix( Form: TForm; Edited: boolean );
begin
  with Form do
  if Edited then
  begin
    if (Caption='') or (LastChar(Caption)<>'*') then
      Caption := Caption + ' *';
  end else
  begin
    if LastChar(Caption)='*' then
      Caption := Copy( Caption, 1, Length(Caption)-2 );
  end;
end;

{*** Функции анализа строк }

function DosFromWin( Const s: string ): string;
Const
  s1 = 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю';
  s2 = '‰–“Љ…Ќѓ™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ©жгЄҐ­Јий§екдлў Їа®«¤¦нпзб¬ЁвмЎо';
Var
  p, i: integer;
begin
  Result := s;
  for i := 1 to Length(s) do
  begin
    p := Pos( s[i], s1 );
    if p<>0 then
      Result[i] := s2[p];
  end;
end;

function ContainsChar( Const s: string; c: char ): boolean;
Var
  i: integer;
begin
  for i := 1 to Length(s) do
    if s[i]=c then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function IsComment( Const s: string ): boolean;
begin
  Result := (s='') or (s[1]='#');
end;

function IsNumeric( c: char ): boolean;
// цифра ли это ?
begin
  Result := (c>='0') and (c<='9')
end;

function IsUpper( c: char ): boolean;
// буква ли верхнего регистра ?
begin
  Result :=(c>='А') and (c<='Я') or (c='Ё')
end;

function IsLower( c: char ): boolean;
// буква ли нижнего регистра?
begin
  Result :=(c>='а') and (c<='я') or (c='ё')
end;

function IsAlpha( c: char ): boolean;
// буква ли это?
begin
  Result := IsLower(c) or IsUpper(c);
end;

function IsAlphaQ( c: char ): boolean;
// буква или "?" ли это?
begin
  Result := IsAlpha(c) or (c='?');
end;

function IsWord( Const s: string ): boolean;
// слово ли?
Var
  i: integer;
begin
  for i := 1 to Length(s) do
    if not IsAlpha(s[i]) then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;

function IsWordQ( Const s: string ): boolean;
// словарная ли строка?
Var
  i: integer;
begin
  for i := 1 to Length(s) do
    if not IsAlphaQ(s[i]) then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;

function IsAnyUpperCase( Const s: string ): boolean;
Var
  i: integer;
begin
  Result := False;
  for i := 1 to Length(s) do
  if IsUpper(s[i]) then
  begin
    Result := True;
    Exit;
  end;
end;

function RegExprWordLen( Const s: string ): integer;
Var
  i, L: integer;
begin
  L := Length(s);
  i := 1;
  Result := 0;
  repeat
    while (i<=L) and not IsAlpha(s[i]) do
      Inc(i);
    if i>L then
      Exit;
    Inc( Result );
    while (i<=L) and IsAlpha(s[i]) do
      Inc(i);
    if i>L then
      Exit;
  until False;
end;

function CopyCase( Const w, wCase: string ): string;
// слово w с заглавными как в wCase
Var
  i: integer;
  c: string[1];
begin
  Result := w;
  for i := 1 to Min(Length(wCase),Length(Result)) do
    if IsUpper(wCase[i]) then
    begin
      c := Result[i];
      c := AnsiUpperCase(c);
      Result[i] := c[1];
    end;
end;

function IsBlank( c: char ): boolean;
begin
  Result := ContainsChar( MySpaceChars, c );
end;

function PosFrom( Const Substr, S: string; p0: integer ): Integer;
// позиция подстроки в строке начиная с позиции p0
begin
  Result := Pos( Substr, Copy(S,p0,Length(S)-p0+1) );
  if Result<>0 then
    Result := Result + p0 - 1
  else
    Result := 0;
end;

function LastChar( Const s: string ): string;
begin
  Result := AnsiRightStr( s, 1 );
end;

function DropLastChar( Const s: string ): string;
begin
    Result := AnsiLeftStr( s, Length(s)-1 );
end;

function LC( Const s: string): string;
begin
  Result := AnsiLowerCase(s);
end;

function ToYe( Const s: string ): string;
// преобразовать все ё в е
Var
  i: integer;
begin
  Result := s;
  for i := 1 to Length(s) do
    if s[i]='ё' then
      Result[i] := 'е'
    else if s[i]='Ё' then
      Result[i] := 'Е';
end;

function IsYo( c: char ): boolean;
begin
  Result := c in ['ё','Ё'];
end;

function IsYe( c: char ): boolean;
begin
  Result := c in ['е','Е'];
end;

function IsYeYo( c: char ): boolean;
begin
  Result := c in ['е','Е','ё','Ё'];
end;

function IsYoIn( Const s: string ): boolean;
// есть ли ё ?
Var
  i: integer;
begin
  for i := 1 to Length(s) do
    if IsYo( s[i] ) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function IsYeYoIn( Const s: string ): boolean;
// есть ли е или ё?
Var
  i: integer;
begin
  for i := 1 to Length(s) do
  begin
    if IsYeYo( s[i] ) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function IsYeYoIf( Const s: string ): boolean;
// есть ли е (или ё)?
Var
  i: integer;
begin
  for i := 1 to Length(s) do
  begin
    if IsYe( s[i] ) then
    begin
      Result := True;
      Exit;
    end;
    if YoOptions.CheckYo and IsYo( s[i] ) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function ListCmpYe( List: TStringList; i1, i2: integer): integer;
begin
  Result := CmpYe( List[i1], List[i2] );
end;

function ListCmpYeEx( List: TStringList; i1, i2: integer): integer;
begin
  Result := CmpYeEx( List[i1], List[i2] );
end;

function Cmp( Const s10, s20: string ): integer;
// упорядочение в словарном порядке (АаБб...)
// s10<s20: Result=-1
// s10=s20: Result=0
// s10>s20: Result=1
Var
  s1, s2: string;
  i: integer;
begin
  s1 := LC(s10);
  s2 := LC(s20);
  if s1<s2 then
    Result := -1
  else if s1>s2 then
    Result := 1
  else
  begin
    for i := 1 to Length(s10) do
      if s10[i]<>s20[i] then
      begin
        if s10[i]>s20[i] then
          Result := 1
        else
          Result := -1;
        Exit;
      end;
    Result := 0;
  end;
end;

function CmpYe( Const s10, s20: string ): integer;
// s10<s20: Result=-1
// s10=s20: Result=0
// s10>s20: Result=1
// по функции сравнения Cmp(ToYe)
begin
  Result := Cmp( ToYe(s10), ToYe(s20) );
end;

function CmpYeEx( Const s10, s20: string ): integer;
Var
  s1, s2: string;
begin
  s1 := s10;
  s2 := s20;
  if LastChar(s1)='?' then
    s1 := DropLastChar( s1 );
  if LastChar(s20)='?' then
    s2 := DropLastChar( s2 );
  Result := CmpYe( s1, s2 );
end;

function CmpYeExLC( Const s10, s20: string ): integer;
begin
  Result := CmpYeEx( LC(s10), LC(s20) );
end;

procedure Replace( Var s: string; i: integer; Var s1, s2: string );
// заменить в s s1 на s2 после i
begin
  Delete( s, i, Length(s1) );
  Insert( s2, s, i );
end;

function Cas( i, Mode: integer ): string;
// падеж числительного
Var
  j, k, r: integer;
begin
  j := i mod 10;
  k := i mod 100;
  if (j>=5) and (j<=9) or (j=0) or (k>=11) and (k<=14) then
    r := 3
  else if j=1 then
    r := 1
  else
    r := 2;
  case Mode of
    1: case r of
         1: Result := 'а';
         2: Result := 'ы';
         3: Result := '';
       end;
    2: case r of
         1: Result := 'о';
         2: Result := 'а';
         3: Result := '';
       end;
    3: case r of
         1: Result := 'е';
         2: Result := 'я';
         3: Result := 'й';
       end;
  end;
end;

{*** функции TRichedit }

procedure GetLinePosInEditor( RE: TRichEdit; Const Idx: integer; Var LineN, PosN: integer );
// определить строку и отступ по позиции символа
begin
  with RE do
  begin
    LineN := Perform( EM_EXLINEFROMCHAR, 0, Idx);
    PosN := (Idx - Perform( EM_LINEINDEX, LineN, 0)) + 1;
  end;
end;

procedure GoAndShowPositionInEditor( RE: TRichEdit; const i: integer );
begin
  if i<0 then
    Exit;
  with RE do
  begin
    SelStart := i;
    SelLength := 0;
    Perform(EM_SCROLLCARET, 0, 0);
  end;
end;

procedure GoAndShowPositionInEditor( RE: TRichEditU; const i: integer );
begin
  if i<0 then
    Exit;
  with RE do
  begin
    SelStart := i;
    SelLength := 0;
    EnsureSelVisible;
  end;
end;

procedure UpdateCursorPosInEditor( RE: TRichEdit; StatusBar: TStatusBar; PanelN: integer );
Var
  LineN, PosN: integer;
begin
  GetLinePosInEditor( RE, RE.SelStart, LineN, PosN );
  if PanelN>=0 then
    StatusBar.Panels[0].Text := Format('%d:%d (%d)', [LineN+1, PosN, RE.Lines.Count])
  else
    StatusBar.SimpleText := Format('%d:%d (%d)', [LineN+1, PosN, RE.Lines.Count]);
  StatusBar.Repaint;
end;

procedure FindInText( RE: TRichEdit; FD: TFindDialog; Var FF: boolean; IsRegExp: boolean );
// RE.HideSelection должно быть False
Var
  p: integer;
  SearchTypes: TSearchTypes;
begin
  with RE do
  begin
    SetFocus; // ? чтобы передать русскую раскладку главного окна
    if FF then
      FoundLength := 0;
    if not IsRegExp then
    begin
      SearchTypes := [];
      if frWholeWord in FD.Options then
        SearchTypes := SearchTypes + [stWholeWord];
      if frMatchCase in FD.Options then
        SearchTypes := SearchTypes + [stMatchCase];
      p := FindText( FD.FindText, SelStart+SelLength, High(Integer), SearchTypes );
      FoundLength := Length( FD.FindText );
    end
    else
    with FindRegExpr do
    begin
      ModifierI := not (frMatchCase in FD.Options);
      Expression := FD.FindText;
      InputString := Text;
      p := SelStart;
      Exec(p+SelLength+1);
      p := MatchPos[0]-1;
      FoundLength := MatchLen[0];
    end;
    if p>=0 then
    begin
      GoAndShowPositionInEditor( RE, p );
      SelLength := FoundLength;
      FF := False;
    end
    else
    begin
      SelLength := 0;
      FF := True;
    end;
    if not FindAgain then
      FD.Execute; // возвратить фокус окну поиска
  end;
end;

procedure FindInText( RE: TRichEditU; FD: TFindDialog; Var FF: boolean; IsRegExp: boolean );
// RE.HideSelection должно быть False
Var
  p: integer;
  SearchTypes: TGsvUnicodeSearchTypes;
begin
  with RE do
  begin
    SetFocus; // ? чтобы передать русскую раскладку главного окна
    if FF then
      FoundLength := 0;
    if not IsRegExp then
    begin
      SearchTypes := [];
      if frWholeWord in FD.Options then
        SearchTypes := SearchTypes + [stWideWholeWord];
      if frMatchCase in FD.Options then
        SearchTypes := SearchTypes + [stWideMatchCase];
      p := FindWideText( FD.FindText, SelStart+SelLength, High(Integer), SearchTypes );
      FoundLength := Length( FD.FindText );
    end
    else
    with FindRegExpr do
    begin
      ModifierI := not (frMatchCase in FD.Options);
      Expression := FD.FindText;
      InputString := WideText;
      p := SelStart;
      Exec(p+SelLength+1);
      p := MatchPos[0]-1;
      FoundLength := MatchLen[0];
    end;
    if p>=0 then
    begin
      GoAndShowPositionInEditor( RE, p );
      SelLength := FoundLength;
      FF := False;
    end else
    begin
      SelLength := 0;
      FF := True;
    end;
    if not FindAgain then
      FD.Execute; // возвратить фокус окну поиска
  end;
end;

{*** функции TStringList }

function FindInStrings( List: TStrings; s: string; Compare: TStrCompare ): integer;
// найти строку s в списке List
// по функции сравнения Compare
Var
  i, i1, i2, c: integer;
begin
  if List.Count=0 then
  begin
    Result := -1;
    Exit;
  end;
  i1 := 0;
  i2 := List.Count-1;
  if Compare( List[i1], s )=0 then
  begin
    Result := i1;
    Exit;
  end;
  if Compare( List[i2], s )=0 then
  begin
    Result := i2;
    Exit;
  end;
  while i2-i1>1 do
  begin
    i := (i1+i2) div 2;
    c := Compare( List[i], s );
    if c=0 then
    begin
      Result := i;
      Exit;
    end
    else if c>0 then
      i2 := i
    else
      i1 := i;
  end;
  Result := -1;
end;

Function RestLowerCase( Const s: string ): string;
begin
  if s='' then
    Result := ''
  else
    Result := s[1] + LC(Copy(s,2,Length(s)-1));
end;

function FindInStringsUL( List: TStrings; Const s: string ): integer;
// найти строку s в списке List
// по функции сравнения Cmp
// если нет с точной первой буквой - то можно в другом регистре
begin
  Result := FindInStrings( List, RestLowerCase(s), Cmp );
  if Result<0 then
    Result := FindInStrings( List, LC(s), Cmp );
end;

function FindPlaceInStrings( List: TStrings; p1, p2: integer; Const s: string; Compare: TStrCompare ): integer;
// найти место строки s в списке List, пользуясь функцией Compare
Var
  i, i0, i1, i2, c: integer;
begin
  i1 := p1;
  i2 := p2;
  i := i1;
  repeat
    i0 := i;
    i := (i1+i2) div 2;
    if (i1=i2) or (i=i0) then
      Break;
    c := Compare( List[i], s );
    if c=0 then
    begin
      Result := i;
      Exit;
    end
    else if c>0 then
      i2 := i-1
    else
      i1 := i+1;
  until False;
  if i<List.Count then
  begin
    c := Compare( List[i], s );
    if c>=0 then
      Result := i
    else
      Result := i+1
  end else
    Result := List.Count;
end;

{*** AskForSelection}

function AskForSelection( w1, w2: string; ToFocusFirst, WrongYo, ReplacedYo, WrongYe: boolean ): TModalResult;
// запрос на замену w1 на w2
begin
  MainForm.EnableAskControls( True );
  MainForm.SetAskParams( w1, w2, WrongYo, ReplacedYo, WrongYe, ToFocusFirst, MainForm.UndoCaption );
  MainForm.Show;
  MainForm.NormCursor;
  // спросить
  Result := MainForm.WaitForAnswer;
  MainForm.EnableAskControls( False );
end;

procedure PutToIntegerList( Var IL: TIntegerList; i: integer );
Var
  k: integer;
begin
  if IL.Count=0 then
  begin
    IL.Add(i);
    Exit;
  end;
  for k := IL.Count-1 downto 0 do
    if IL[k]<i then
    begin
      if k=IL.Count-1 then
        IL.Add(i)
      else
        IL.Insert(k+1,i);
      Exit;
    end;
  IL.Insert(0,i);
end;

{ TDic }

procedure TDic.Clear;
begin
  Ye.Clear;
  Yo.Clear;
  WordsAsk.Clear;
  WordsAnswer.Clear;
  UserSel.Clear;
  Ye2Ye.Clear;
  Ye2Yo.Clear;
  Yo2Ye.Clear;
  Yo2Yo.Clear;
end;

constructor TDic.Create;
begin
  Ye := TStringList.Create;
  Yo := TStringList.Create;
  WordsAsk := TShortIntList.Create;
  WordsAnswer := TShortIntList.Create;
  UserSel := TShortIntList.Create;
  Ye2Ye := TIntegerList.Create;
  Ye2Yo := TIntegerList.Create;
  Yo2Ye := TIntegerList.Create;
  Yo2Yo := TIntegerList.Create;
end;

{ TRegExprDic }

constructor TRegExprDic.Create;
begin
  W := TStringList.Create;
  W0 := TStringList.Create;
  RE := TRegExprList.Create;
  Was := TIntegerList.Create;
end;

procedure TRegExprDic.Clear;
begin
  W.Clear;
  W0.Clear;
  RE.Clear;
  Was.Clear;
end;

function TRegExprDic.AddWord(s: string): boolean;
Var
  ss: string;
  RE0: TRegExpr;
function MakeValidRegExpr( s: string ): string;
Var
  i: integer;
  ss: string;
  WasBlank, WasBackslash: boolean;
  Brackets: integer;
begin
  ss := '';
  WasBlank := False;
  WasBackslash := False;
  Brackets := 0;
//
  for i := 1 to Length(s) do
  begin
    if IsBlank(s[i]) then
    begin
      if not WasBlank then
        ss := ss + '\s+'
      else
        WasBlank := True;
    end
    else
    begin
      WasBlank := False;
      if not WasBackslash and ContainsChar( '([', s[i] ) then
        Inc(Brackets)
      else if not WasBackslash and ContainsChar( ')]', s[i] ) then
        Dec(Brackets);
      if Brackets=0 then
      begin
        if IsYeYo( s[i] ) then
        begin
          if IsUpper( s[i] )then
            ss := ss + '('+ '[ЕЁ]' + ')'
          else
            ss := ss + '('+'[её]' + ')';
        end
        else if s[i]='-' then
          ss := ss + '-(\r\n){0,1}'
        else
          ss := ss + s[i];
      end
      else
        ss := ss + s[i];
    end;
    WasBackslash := s[i]='\';
  end;
  if IsAlpha(ss[1]) then
    ss := '\b' + ss;
  if IsAlpha(ss[Length(ss)]) then
    ss := ss + '\b';
  Result := ss;
end;
begin
  Result := True;
  ss := MakeValidRegExpr( s );
  Was.Add( 0 );
  W0.Add( s );
  W.Add( ss );
  RE0 := TRegExpr.Create;
  with RE0 do
  begin
    ModifierM := True;
    ModifierI := True;
    ModifierS := True;
    SpaceChars := MySpaceChars;
    WordChars := MyWordChars;
    Expression := ss;
    try
      Compile;
      RE.Add( RE0 );
    except
      Result := False;
    end;
  end;
end;

{TMainForm}

procedure TMainForm.ReadDic;
// прочитать словарь
Var
  f: TextFile;
  s, sYe, sYe0, sYo, str: string;
  ToAsk: integer;
  f0: file of byte;
  fs, Lines: longint;
  Progress0, Progress: integer;
//
procedure ParseWord( s: string; Var sYe, sYo: string; Var ToAsk: integer );
// разбить строку
begin
  if LastChar(s)='?' then
  begin
    s := DropLastChar( s );
    ToAsk := 1;
  end
  else
    ToAsk := 0;
  sYo := s;
  sYe := ToYe(sYo);
end;
//
begin
  DicVersion := '';
  with Dic do
  begin
    Clear;
    if DicFileName='' then
    begin
      Error( msgNoDic );
      Exit;
    end
    else if not FileExists( DicFileName ) then
    begin
      Error( Format( msgFileNotFound, [DicFileName] ) );
      DicFileName := '';
      Exit;
    end;
    WaitStatusIf( 'Загрузка словаря '+DicFileName+' ...' );
//  определить размер файла в байтах
    AssignFile( f0, DicFileName );
    Reset( f0 );
    fs := FileSize( f0 );
    CloseFile( f0 );
//
    AssignFile( f, DicFileName );
    Reset( f );
    sYe := '';
    FirstDisorder := '';
    WordNoYo := '';
    WrongWord := '';
    Lines := 0;
    Progress0 := -1;
    while not Eof(f) do
    begin
      ReadLn( f, str );
      Inc( Lines );
      Progress := Round(Lines*13.2/fs*100);
      if Progress<>Progress0 then
      begin
        StatusInfo( msgLoadDic+' '+DicFileName+Format( ': %d%% ...', [Progress] ) );
        Progress0 := Progress;
      end;
      if IsComment(str) then // если комментарий
      begin
        if DicVersion='' then
          DicVersion := GetDicVersion(str);
        Continue;
      end;
      s := str;
      sYe0 := sYe;
      ParseWord( s, sYe, sYo, ToAsk );
      if WrongWord='' then
        if not IsWord(sYe) then
          WrongWord := s;
      //записать словоформу
      Ye.Add( sYe );
      Yo.Add( sYo );
      WordsAsk.Add( ToAsk );
      WordsAnswer.Add( 0 );
      Ye2Ye.Add( 0 );
      Ye2Yo.Add( 0 );
      Yo2Ye.Add( 0 );
      Yo2Yo.Add( 0 );
      UserSel.Add( 0 );
      if (FirstDisorder='') and (Cmp(sYe,sYe0)<=0) then
        FirstDisorder := sYo;
      if (WordNoYo='') and not IsYoIn(s) then
        WordNoYo := s;
    end;
    CloseFile( f );
    if DicExist then
    begin
      SetMenuItem( 'Yobegin1', True );
      SetMenuItem( 'Yopos1', True );
    end;
    if (FirstDisorder<>'') then
      Error( Format( msgDisorderWord, [FirstDisorder] ) );
    if WrongWord<>'' then
      Error( Format( msgBadString, [WrongWord] ) )
    else if WordNoYo<>'' then
      Error( Format( msgNoYo, [WordNoYo] ) );
  end;
  SetMenuItem( 'Clearusersel1', False );
  NoWaitStatus;
end;

function IsValidRegExpr( Const s: string; Var ID: integer ): boolean;
begin
  Result := True;
  with tmpRegExpr do
  begin
    Expression := s;
    try
      Compile;
    except
      Result := False;
      ID := LastError;
    end;
  end;
end;

procedure TMainForm.ReadRegExprDic;
Var
  f: TextFile;
  str: string;
  WrongWord: string;
  WasOldFormat: boolean;
begin
  WasOldFormat := False;
  DicREVersion := '';
  with RegExprDic do
  begin
    if RegExprDicFileName='' then
    begin
      YoOptions.RegExprs := False;
      Exit;
    end;
    Clear;
    if not FileExists( RegExprDicFileName ) then
    begin
      Error( Format( msgFileNotFound, [RegExprDicFileName] ) );
      RegExprDicFileName := '';
      Exit;
    end;
    WaitStatusIf( msgLoadRegExprDic+' '+RegExprDicFileName+' ...' );
    AssignFile( f, RegExprDicFileName );
    Reset( f );
    WrongWord := '';
    while not Eof(f) do
    begin
      ReadLn( f, str );
      if IsComment(str) then
      begin
        if DicREVersion='' then
          DicREVersion := GetDicVersion(str);
        Continue;
      end
      else if not AddWord( str ) and (WrongWord='') then
        WrongWord := str;
      WasOldFormat := WasOldFormat or AnsiContainsStr(str, '\0');//(Pos('\0',str)<>0)
    end;
    CloseFile( f );
    if WrongWord<>'' then
      Error( Format( msgNotRegExpr, [WrongWord] ) )
    else if WasOldFormat then
      Error( msgWasOldFormatRE );
    NoWaitStatus;
  end;
end;

procedure TMainForm.AddToStat( Idx: integer; Const oldWord, newWord: string; DicWordIndex: integer );
Var
  loldWord, lnewWord, lsYo, lsYe: string;
begin
  with Editor do
  begin
    loldWord := LC(oldWord);
    if newWord<>'' then
      lnewWord := LC(newWord)
    else
      lnewWord := loldWord;
    if (DicWordIndex>=0) then
    begin
      lsYo := LC(Dic.Yo[DicWordIndex]);
      lsYe := LC(Dic.Ye[DicWordIndex]);
      if loldWord = lsYe then
      begin
        if lnewWord = lsYe then
          Dic.Ye2Ye[DicWordIndex] := Dic.Ye2Ye[DicWordIndex] + 1
        else
          Dic.Ye2Yo[DicWordIndex] := Dic.Ye2Yo[DicWordIndex] + 1;
      end;
      if loldWord = lsYo then
      begin
        if lnewWord = lsYo then
          Dic.Yo2Yo[DicWordIndex] := Dic.Yo2Yo[DicWordIndex] + 1
        else
          Dic.Yo2Ye[DicWordIndex] := Dic.Yo2Ye[DicWordIndex] + 1;
      end;
    end;
  end;
end;

procedure TMainForm.ChangeLetter( Idx: integer; Const oldWord, newWord: string );
Var
  k0, k: integer;
begin
  with Editor do
  begin
    k0 := Idx; // запомнить
    for k := 1 to Length(oldWord) do // по длине слова
    begin
      if oldWord[k]<>newWord[k] then // если буква не равна
      begin
        if WasAsk then // если интерактивная замена - запомнить для отката
          AddUndo( Idx, k0, oldWord[k], GetSelColor, oldWord, newWord );
        SelStart := k0;
        SelLength := 1;
        if YoOptions.Mark then  // если отмечать букву
        begin
          SetSelColor( YoOptions.clMark );
          if YoOptions.clBackMark <> $FFFFFF then
            SetSelBackColor( YoOptions.clBackMark );
        end;
        SelWideText := newWord[k];
        SelLength := 0;
        PutToIntegerList(YYPos,k0+1);
      end;
      Inc( k0 );
    end;
  end;
end;

procedure TMainForm.CheckWord( Idx: integer; Const cWord: string; Var ToCancel: boolean );
// проверить слово
Var
  newWord: string;
  DicWordIndex, WordN: integer;
  WrongYo: boolean;
begin
  with Editor do
  if (Length(cWord)>1) and IsYeYoIn(cWord) then // если длина слова >1
  begin
    ToCancel := False;
    if IsYoIn(cWord) and not YoOptions.CheckYo then
      Exit;
    newWord := SelectWord( cWord, Idx, ToCancel, DicWordIndex, WordN, WrongYo );
    if not ToCancel then
    begin
      Inc( CheckedLS.A );
      if newWord<>'' then
        Inc( CheckedLS.Changed )
      else
        Inc( CheckedLS.NotChanged );
      if WasAsk then
      begin
        Inc( AskedLS.A );
        if newWord<>'' then
          Inc( AskedLS.Changed )
        else
          Inc( AskedLS.NotChanged );
      end;
      if WrongYo then
        Inc(WrongYoLS);
      AddToStat( Idx, cWord, newWord, DicWordIndex );
      if newWord<>'' then
        ChangeLetter( Idx, cWord, newWord );
      ShowStatus;
    end;
  end;
end;

procedure TMainForm.CheckWordEx( cLineN, cPosN: integer; Const cNotWord, cWord: string; CurrentChar: char; Var ToCancel: boolean );
Var
  Idx: integer;
begin
  if not IsYeYoIf( cWord ) then
    Exit;
  Idx := Editor.Perform( EM_LINEINDEX, cLineN, 0 ) + cPosN - 1 - Length(cWord);
  ToCheckAbbreviation := YoOptions.ToConfirmAbbr and IsItAbbreviation( CurrentChar, cLineN, cPosN );
  ToCheckEllipsis := YoOptions.ToConfirmEllipsis and IsItEllipsis( CurrentChar, cLineN, cPosN );
  CheckWord( Idx, cWord, ToCancel );
  if not ToCancel then
    ToCancel := IsEsc;
end;

function ToMetaSymbols( s: string ): string;
Var
  WasNumeric: boolean;
  i: integer;
begin
  Result := '';
  WasNumeric := False;
  for i := 1 to Length(s) do
    if IsNumeric(s[i]) then
    begin
      if not WasNumeric then
      begin
        Result := Result + '\0';
        WasNumeric := True;
      end;
    end
    else
    begin
      Result := Result + s[i];
      WasNumeric := False;
    end;
end;

function TMainForm.IsItAbbreviation( c: char; LineN, PosN: integer ): boolean;
Var
  s: string;
  L: integer;
begin
  Result := False;
  if c='.' then
    with Editor do
    begin
      s := Lines[LineN];
      L := Length(s);
      repeat
        Inc(PosN);
        if PosN>L then
        begin
          PosN := 1;
          repeat
            Inc(LineN);
            if LineN>=Editor.LineCount then
              Exit;
            s := Lines[LineN];
          until s<>'';
        end;
        c := s[PosN];
        Result := IsLower(c);
      until Result or not IsBlank(c);
    end;
end;

function TMainForm.IsItEllipsis( c: char; LineN, PosN: integer ): boolean;
Var
  s: string;
begin
  s := Editor.Lines[LineN];
  s := Copy( s, PosN, Min(3,Length(s)-PosN+1) );
  Result := (Pos('...',s)=1) or (Pos('…',s)=1);
end;

procedure TMainForm.Yoficate( LineN0, PosN0: integer );
// ёфикация со строки LineN0 и позиции PosN0
Var
  i, j: integer;
  s, cWord, s0: string;
  ToCancel: boolean;
  c: char;
  us: string;
  BinaryFound: boolean;
  PosN1: integer;
  LastAlpha: boolean;
  LineN, PosN: integer;  // текущие позиции в текстовом окне
  cNotWord: string;
  BrokenWord: boolean;

procedure FindBinary( Var p: integer );
begin
  us := UpperCase(s);
  p := PosFrom( '<BINARY', us, PosN0 );
  if p=0 then
    p := Length(s)
  else
  begin
    p := p-1;
    BinaryFound := True;
  end;
end;

begin
  ClearEsc;
  ShowStatus;
  WaitCursor;
  ToCancel := False;
  BinaryFound := False;
  c := #10;
  with Editor do // по строкам текста
  begin
    cWord := '';  // накопитель слова
    cNotWord := ' ';
    s := Lines[LineN0];
    BrokenWord := (PosN0<>1) and IsAlpha(s[PosN0]) and IsAlpha(s[PosN0-1]);
    for i := LineN0 to Editor.LineCount-1 do
    begin
      LineN := i;
      if not YoOptions.FastScroll  and (i>LineN0) then  //перейти к позиции
        GoAndShowPosition( Editor.Perform( EM_LINEINDEX, LineN, 0 ) )
      else
        UpdateCursorPos( Editor.Perform( EM_LINEINDEX, LineN, 0 ) );
      s := Lines[i];
      s0 := s;
      if YoOptions.FBFormat then  // если *.fb2 - найти тэг <binary и его начало
        FindBinary( PosN1 )
      else
        PosN1 := Length(s);
      LastAlpha := False;
      for j := PosN0 to PosN1 do
      begin
        PosN := j;
        c := s[j];
        if IsAlpha(c) then // если буква
        begin
          cWord := cWord + c; // добавить к слову
          LastAlpha := True;
        end
        else
        begin
          if LastAlpha then // слово считано
          begin
            if not BrokenWord then
              CheckWordEx( LineN, PosN, cNotWord, cWord, c, ToCancel );
            BrokenWord := False;
            cWord := '';
            cNotWord := c;
            if ToCancel then
              Break;
          end
          else
            cNotWord := cNotWord + c;
          LastAlpha := False;
        end;
      end;
      if not ToCancel and (cWord<>'') then  // проверить последнее слово в проверяемой строке
      begin
        PosN := PosN1+1;
        if not BrokenWord then
          CheckWordEx( LineN, PosN, cNotWord, cWord, c, ToCancel );
        BrokenWord := False;
        cWord := '';
        cNotWord := ' ';// ? зачем-то нужно
      end;
      if ToCancel or BinaryFound then
        Break;
      PosN0 := 1;
    end;
  end;
  NormCursor;
  ShowStatus;
end;

function TMainForm.FindReplacement( Const WordYe: string; Var ToAsk: boolean; Var Index, WordToFocusN: integer; Var Always: boolean ): string;
//найти замену слову с Е
begin
  ToAsk := False;
  Index := FindInStringsUL( Dic.Ye, WordYe );
  if Index>=0 then
  begin
    Result := Dic.Yo[Index];
    Always := Dic.UserSel[Index]<>0;
    if not Always then
    begin
      ToAsk := Dic.WordsAsk[Index]<>0;
      if ToAsk then
        WordToFocusN := Dic.WordsAnswer[Index]
      else
        WordToFocusN := 2;
    end
    else
    begin
      ToAsk := False;
      WordToFocusN := Dic.UserSel[Index];
    end;
  end
  else
  begin
    Result := '';
    WordToFocusN := 1;
  end;
end;

function TMainForm.SelectWord( Const cWord: string; Const Idx: integer; Var ToCancel: boolean;
  Var DicWordIndex, WordToFocusN: integer; Var WrongYo: boolean ): string;
// выбрать слово для замены
{
cWord - слово для замены
Idx - индекс первой (?) буквы в тексте
ToCancel - прервать замену
DicWordIndex - индекс слова в словаре
WordToFocus - номер слова для выделения: 1 (Ye), 2 (Yo),-1 (Cancel)
WrongYo - признак неправильного Ё
Result - новое слово (если нет замены - то '')
}
Var
  ToAsk: boolean; // -1 - ignore, 0 - replace without ask, 1 - ask,
  cLineN, Skip: integer;
  ToFocusFirst: boolean;
  Word1, Word2: string;
  r: TModalResult;
  ReplacedYo, WrongYe, IsYocWord: boolean;
  WordN: integer;
  ALways: boolean;
begin
  ToMakeUndo := False;
  WasAsk := False;
  WordToFocusN := 0;
  if not YoOptions.FastScroll then
    GoAndShowPosition( Idx+Length(Word1) );
  Word1 := ToYe(cWord);
  Word2 := FindReplacement( Word1, ToAsk, DicWordIndex, WordToFocusN, Always );
  ToAsk := ToAsk
    or (Word2<>'') and ToCheckAbbreviation  // если слово может быть сокращением
    or (Word2<>'') and ToCheckEllipsis  // если слово может быть оборванным
    or (Word2<>'') and YoOptions.ToConfirmCap and IsUpper(cWord[1]) and not Always; // если слово может быть именем собственным
  IsYocWord := IsYoIn(cWord);
  WrongYo := IsYocWord and (LC(Word2)<>LC(cWord));
  ReplacedYo := WrongYo and (Word2<>'');
  WrongYe := not IsYocWord and (LC(Word1)=LC(cWord)) and not ToAsk and (WordToFocusN=2);
  if ReplacedYo then
    Word1 := CopyCase( Word2, cWord );
  if (Word2='') and IsYocWord {(cWord<>Word1)} or ReplacedYo then
    Word2 := cWord;
  Word2 := CopyCase( Word2, cWord );
  if not ToAsk and YoOptions.VarOnly and not WrongYo then // если флаг - пропустить, если только интерактивные
  begin
    Result := '';
    Exit;
  end;
  if YoOptions.RegExprs and ToAsk then // если интерактивно - искать рег. выражение
    if LookInRegExps( cWord, Idx, Word1, Word2, WordN ) then
    begin
      ToAsk := False;
      WordToFocusN := WordN;
      if (WordN=1) and (cWord=Word2) or (WordN=2) and (cWord=Word1) then
        Inc( RELS.Changed )
      else
        Inc( RELS.NotChanged );
    end;
  if ToAsk and YoOptions.NoVarOnly then // если флаг - пропустить если нужна интерактивность
  begin // игнорировать
    Result := '';
    Exit;
  end;
  if WrongYo then // неправильное Ё никогда не меняется без запроса
  begin
    if YoOptions.NoVarOnly then
    begin // игнорировать
      Result := '';
      Exit;
    end
    else
      ToAsk := True; // заменить
  end;
  if not ToAsk and YoOptions.AlwaysAsk and (Word2<>'') then // если флаг - всегда спрашивать
    ToAsk := True;
  WasAsk := False;
  if ToAsk then // заменить
  begin
    Editor.GetLinePosition( Idx, cLineN, Skip );
    GoAndShowPosition( Editor.Perform( EM_LINEINDEX, cLineN + YoOptions.LinesBelow, 0 ) ); // отмотать вниз
    GoAndShowPosition( Idx );
    Editor.SelLength := Length(Word1);
    if (WordToFocusN<>0) and YoOptions.ProposeLast and not WrongYo then
      ToFocusFirst := WordToFocusN=1
    else
      ToFocusFirst := not IsYoIn(cWord) or WrongYo;
    r := AskForSelection( Word1, Word2, ToFocusFirst, WrongYo, ReplacedYo, WrongYe );
    if (r=mrYeAll) or (r=mrYoAll) then
    begin
      SetMenuItem( 'Clearusersel1', True );
      if r = mrYeAll then
        Dic.UserSel[DicWordIndex] := 1
      else if r = mrYoAll then
        Dic.UserSel[DicWordIndex] := 2;
      case r of
        mrYeAll: r := mrYe;
        mrYoAll: r := mrYo;
      end;
    end;
    WasAsk := True;
    Editor.SelLength := 0;
    ToMakeUndo := r = mrUndo;
    if ToMakeUndo then //откат
      r := mrCancel;
    case r of
      mrCancel: WordToFocusN := -1;
      mrYe: WordToFocusN := 1;
      mrYo: WordToFocusN := 2;
    end;
    if (DicWordIndex>=0) and (WordToFocusN>0) then
      Dic.WordsAnswer[DicWordIndex] := WordToFocusN;
  end;
  ToCancel := False;
  case WordToFocusN of
    1: Result := Word1;
    2: Result := Word2;
  else
    ToCancel := True;
  end;
  if Result=cWord then
    Result := '';
end;

function GetTextType( const FileName: string; TextType: integer ): integer;
Var
  RTFResult, TextType0: integer;
begin
  RTFResult := RTFTextType( FileName ) or TextType;
  TextType0 := UnicodeTextType( FileName, YoOptions.AutoUnicode );
  if YoOptions.AutoUnicode then
    Result := RTFResult or TextType0
  else
  begin
    if TextType and ttUTF8 <> 0 then
      Result := RTFResult or ttUTF8 or (TextType0 and ttUTFsgn)
    else if TextType and ttUTF16 <> 0 then
      Result := RTFResult or (TextType0 and ttUTF16) or (TextType0 and ttUTFsgn)
    else
      Result := RTFResult;
  end;
end;

procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
// drag-and drop процедура
var
  CFileName: array[0..MAX_PATH] of Char;
  FileType: integer;
begin
  try
    if DragQueryFile(Msg.Drop, 0, CFileName, MAX_PATH) > 0 then
    begin
      if not CanBeClosed then
        Exit;
      RememberFileNamesPos;
      FileType := GetTextType( CFileName, 0 );
      OpenText( CFileName, FileType );
      Msg.Result := 0;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TMainForm.UpdateCursorPos;
begin
  Editor.UpdateCursorPosition( StatusBar1, 0 );
end;

procedure TMainForm.StatusInfo( Const s: string );
begin
  StatusBar1.Panels[1].Text := s;
  StatusBar1.Repaint;
end;

procedure TMainForm.ShowStatus;
Var
  T: TDateTime;
  iT: double;
  REQuality: real;
  s: string;
begin
  T := Now-RunTime0;
  if T<>0.0 then
    iT := 1/T
  else
    iT := 0;
  if RELS.A+NoRELS=0 then
    ReQuality := 0.0
  else
    REQuality := RELS.A/(RELS.A+NoRELS)*100.0;
    s := Format( '%d=%d+%d  A:%d=%d+%d  RE:%d=%d+%d  REQ:%0.1f%%  E:%d  T:%0.2f  S:%d',
      [CheckedLS.A, CheckedLS.Changed, CheckedLS.NotChanged, AskedLS.A, AskedLS.Changed, AskedLS.NotChanged, RELS.A,
        RELS.Changed, RELS.NotChanged, REQuality, WrongYoLS, (Now-RunTime0)*SecsPerDay, Round(CheckedLS.Changed*iT/SecsPerDay)] );
  StatusInfo( s );
end;

procedure TLetterStat.Clear;
begin
  A := 0;
  Changed := 0;
  NotChanged := 0;
end;

procedure TMainForm.WaitCursor;
begin
  Editor.Cursor := crHourGlass;
end;

procedure TMainForm.NormCursor;
begin
  Editor.Cursor := crDefault;
end;

procedure TMainForm.GoAndShowPosition( const i: integer );
begin
  Editor.GoAndShowPosition( i );
  UpdateCursorPos( i );
end;

procedure TMainForm.FileLoad( const FileName: string; Const FileType: integer );
//открыть файл
begin
  WaitCursor;
  with Editor do
  begin
    Clear;
    Editor.LoadFromFile( FileName, FileType );
  end;
  Caption := FileName;
  Edited := False;
  NormCursor;
end;

function TMainForm.CanBeClosed: boolean;
begin
  Result := True;
  if Editor.LineCount=0 then
    Exit;
  if Edited then
    case WarningX( msgToSave, 1 ) of
      IDYES: if TextFileName<>'' then
          SaveFile
        else
          Result := SaveFileAs;
      IDNO: Result := True;
      IDCANCEL: Result := False;
    end;
end;

procedure TMainForm.SetEdited( Const Value: boolean );
begin
  if FEdited = Value then
    Exit;
  FEdited := Value;
  SetCaptionAsterix( Self, Value );
end;

function TMainForm.DicExist: boolean;
begin
  Result := (Dic<>nil) and (Dic.Ye.Count>0);
end;

procedure TMainForm.WriteToRegExprLog( Const s: string );
begin
  if not FileExists( RegExprLogName ) then
    Rewrite( fRegExprlog )
  else
    Append( fRegExprlog );
  if RegExprTextFileName<>TextFileName then
  begin
    if TextFileName<>'' then
      WriteLn( fRegExprlog, ' *** ', TextFileName );
    RegExprTextFileName := TextFileName;
  end;
  WriteLn( fRegExprlog, s );
  CloseFile( fRegExprlog );
end;

procedure TMainForm.ReadIni;
// прочитать ini-файл
Var
  s, ss: string;
  i, j, p: integer;
  TextType: integer;
begin
  IniFile := TIniFile.Create(FullIniFileName);
  with IniFile, YoOptions do
  begin
    AlwaysAsk := ReadBool( 'Yo', 'AlwaysAsk', False );
    Mark := ReadBool( 'Yo', 'Mark', True );
    FastScroll := ReadBool( 'Yo', 'FastScroll', False );
    CheckYo := ReadBool( 'Yo', 'CheckYo', True );
    NoVarOnly := ReadBool( 'Yo', 'NoVarOnly', False );
    VarOnly := ReadBool( 'Yo', 'VarOnly', False );
    WordWrap := ReadBool( 'Yo', 'WordWrap', True );
    ProposeLast := ReadBool( 'Yo', 'ProposeLast', True );
//    ToConfirm := ReadBool( 'Yo', 'ToConfirm', True );
    FBFormat := ReadBool( 'Yo', 'FBFormat', False );
    AutoUnicode := ReadBool( 'Yo', 'AutoUnicode', True );
    RegExprs := ReadBool( 'Yo', 'RegExprs', True );
    LastFile := ReadBool( 'Yo', 'RecallLastFile', True );
    ToConfirmAbbr := ReadBool( 'Yo', 'ToConfirmAbbr', True );
    ToConfirmEllipsis := ReadBool( 'Yo', 'ToConfirmEllipsis', True );
    ToConfirmCap := ReadBool( 'Yo', 'ToConfirmCap', False );
    //
    WindowHeight := ReadInteger( 'Yo', 'WindowHeight', 3*Screen.Height div 4 );
    WindowWidth := ReadInteger( 'Yo', 'WindowWidth', 3*Screen.Width div 4 );
    WindowTop := ReadInteger( 'Yo', 'WindowTop', Screen.Height div 8 );
    WindowLeft := ReadInteger( 'Yo', 'WindowLeft', Screen.Width div 8 );
    //
    EditorFontName := ReadString( 'Yo', 'FontName', 'Courier New' );
    EditorFontSize := ReadInteger( 'Yo', 'FontSize', 10 );
    EditorFontCharset := ReadInteger( 'Yo', 'FontCharset', 1 );
    //
    DicFileName := AddProgramDir( ReadString( 'Yo', 'Dictionary', DicShortFileName0 ) );
    RegExprDicFileName := AddProgramDir( ReadString( 'Yo', 'RegExprDictionary', DicREShortFileName0 ) );
    LinesBelow := ReadInteger( 'Yo', 'LinesBelow', LinesBelow0 );
    ButtonHotKeys := ReadString( 'Yo', 'ButtonHotKeys', '1234' );
//  Colors
    clMark := ReadInteger( 'Colors', 'ColorMark', clBlue );
    clBackMark := ReadInteger( 'Colors', 'ColorBackMark', clYellow );
// Supp
    UTF8Warning := ReadBool( 'Internal', 'UTF8Warning', True );
    UTFLength := ReadInteger( 'Internal', 'UTFLength', 512 );
//  ToolBar
    ShowToolBar := ReadBool( 'ToolBar', 'ShowToolBar', False );
//  кнопки на TToolbar, добавляются слева (!)
    for i := MaxToolButtonsQ downto 1 do
    begin
      s := ReadString( 'ToolBar', Format( 'ToolButton%d', [i] ), '' );
      if s<>'' then
        AddButtonToToolBar( s );
    end;
// Files
    for i := 1 to MaxFileNamesInList do
    begin
      s := ReadString( 'Files', Format( 'Name%d', [i] ), '' );
      TextType := 0;
      if s<>'' then
      begin
        for j := Length(s) downto 1 do
          if s[j]=',' then
          begin
            ss := Copy(s,j+1,Length(s)-j);
            if ContainsChar( ss, 'u' ) then
              TextType := TextType or ttUTF8
            else if ContainsChar( ss, 'U' ) then
              TextType := TextType or ttUTF16LE;
            if ContainsChar( ss, 'S' ) then
              TextType := TextType or ttUTFsgn;
            if ContainsChar( ss, 'R' ) then
              TextType := TextType or ttRTF;
            if TextType<>0 then
              Delete(s,j,Length(s)-j+1);
            Break;
          end;
        p := 0;
        for j := Length(s) downto 1 do
          if s[j]=',' then
          begin
            try
              p := StrToInt( Copy(s,j+1,Length(s)-j) );
            except
              p := 0;
            end;
            s := Copy( s, 1, j-1 );
            Break;
          end;
        AddFileToList( s, p, TextType );
      end;
    end;
//
    if LastFile and (TextFileName='') then
    begin
      i := ReadInteger( 'Files', 'LastFileN', 0 );
      if (i>0) and (FileNamesFirstItemN+i-1<File1.Count) then
      begin
        TextFileName := File1.Items[FileNamesFirstItemN+i-1].Caption;
        TextFileType := FileNamesTextType[i-1];
        odxText.TypeOfText := TextFileType;
      end;
    end;
//меняется только правкой файла !
    WordsBufferLength := ReadInteger( 'Yo', 'WordsBufferLength', 5 );
    WordsBufferLength2 := WordsBufferLength div 2;
    RegExprLog := ReadBool( 'Yo', 'RegExprLog', False );
    TextDirectory := ReadString( 'Yo', 'TextDirectory', '' );
  end;
  MainForm.Width := WindowWidth;
  MainForm.Height := WindowHeight;
  MainForm.Top := WindowTop;
  MainForm.Left := WindowLeft;
//
  with YoOptions do
  begin
    Editor.Font.Name := EditorFontName;
    Editor.Font.Size := EditorFontSize;
    Editor.Font.Charset := EditorFontCharset;
  end;
//
  Toolbar1.Visible := YoOptions.ShowToolbar;
//
  DefaultYoOptions := YoOptions; // сохранить начальные опции
end;

procedure TMainForm.WriteIni;
// записать ини-файл
Var
  i: integer;
  s, ss: string;
begin
  WindowWidth := MainForm.Width;
  WindowHeight := MainForm.Height;
  WindowTop := MainForm.Top;
  WindowLeft := MainForm.Left;
  with IniFile, DefaultYoOptions do
  begin
    WriteBool( 'Yo', 'AlwaysAsk', AlwaysAsk );
    WriteBool( 'Yo', 'Mark', Mark );
    WriteBool( 'Yo', 'FastScroll', FastScroll );
    WriteBool( 'Yo', 'CheckYo', CheckYo );
    WriteBool( 'Yo', 'NoVarOnly', NoVarOnly );
    WriteBool( 'Yo', 'VarOnly', VarOnly );
    WriteBool( 'Yo', 'WordWrap', WordWrap );
    WriteBool( 'Yo', 'ProposeLast', ProposeLast );
    WriteBool( 'Yo', 'FBFormat', FBFormat );
    WriteBool( 'Yo', 'AutoUnicode', AutoUnicode );
    WriteInteger( 'Yo', 'WindowHeight', WindowHeight );
    WriteInteger( 'Yo', 'WindowWidth', WindowWidth );
    WriteInteger( 'Yo', 'WindowTop', WindowTop );
    WriteInteger( 'Yo', 'WindowLeft', WindowLeft );
    WriteBool( 'Yo', 'RegExprs', RegExprs );
    WriteString( 'Yo', 'FontName', EditorFontName );
    WriteInteger( 'Yo', 'FontSize', EditorFontSize );
    WriteInteger( 'Yo', 'FontCharset', EditorFontCharset );
    WriteString( 'Yo', 'Dictionary', DicFileName );
    WriteString( 'Yo', 'RegExprDictionary', RegExprDicFileName );
    WriteBool( 'Yo', 'RecallLastFile', LastFile );
    WriteBool( 'Yo', 'ToConfirmAbbr', ToConfirmAbbr );
    WriteBool( 'Yo', 'ToConfirmEllipsis', ToConfirmEllipsis );
    WriteBool( 'Yo', 'ToConfirmCap', ToConfirmCap );
    DeleteKey( 'Yo', 'LastFileName' );
    DeleteKey( 'Yo', 'LastFilePos' );
    WriteString( 'Yo', 'TextDirectory', TextDirectory );
    WriteString( 'Yo', 'ButtonHotKeys', ButtonHotKeys );
//  Colors
    WriteInteger( 'Colors', 'ColorMark', clMark );
    WriteInteger( 'Colors', 'ColorBackMark', clBackMark );
// Internal
    WriteBool( 'Internal', 'UTF8Warning', UTF8Warning );
//  ToolBar
    WriteBool( 'ToolBar', 'ShowToolBar', ShowToolBar );
    for i := 1 to ToolBar1.ButtonCount do
      if ToolBar1.Buttons[i-1].Name='' then
        WriteString( 'ToolBar', Format( 'ToolButton%d', [i] ), '-' )
      else
        WriteString( 'ToolBar', Format( 'ToolButton%d', [i] ), ToolBar1.Buttons[i-1].Name );
    for i := ToolBar1.ButtonCount+1 to MaxToolButtonsQ do
      DeleteKey( 'ToolBar', Format( 'ToolButton%d', [i] ) );
// Files
    if FileNamesFirstItemN<>0 then
      for i := 1 to MaxFileNamesInList do
      begin
        if FileNamesFirstItemN+i-1 < File1.Count then
        begin
          ss := '';
          if FileNamesTextType[i-1] and ttUTF8 <> 0 then
            ss := ss + 'u'
          else if FileNamesTextType[i-1] and ttUTF16LE <> 0 then
            ss := ss + 'U';
          if FileNamesTextType[i-1] and ttUTFsgn <> 0 then
            ss := ss + 'S';
          if FileNamesTextType[i-1] and ttRTF <> 0 then
            ss := ss + 'R';
          if ss='' then
            s := Format( '%s,%d', [File1.Items[FileNamesFirstItemN+i-1].Caption,FileNamesPos[i-1]] )
          else
            s := Format( '%s,%d,%s', [File1.Items[FileNamesFirstItemN+i-1].Caption,FileNamesPos[i-1],ss] )
        end
        else
          s := '';
        WriteString( 'Files', Format( 'Name%d', [i] ), s );
      end;
    WriteInteger( 'Files', 'LastFileN', GetFileNamesN(TextFileName) );
  end;
end;

procedure TMainForm.SetWordWrap( Value: boolean );
// установить режим заворота строк
begin
  with Editor do
    if WordWrap <> Value then
    begin
      WordWrap := Value;
{$IFDEF TrickyWordWrap}
      Lines[0] := Lines[0];
{$ENDIF}
    end;
end;

procedure TMainForm.ReadParameters;
// прочитать параметры командной строки
Var
  s: string;
begin
  if ParamCount>0 then
  begin
    s := ParamStr(1);
    TextFileName := s;
  end;
end;

function TMainForm.OpenText( Const s: TFileName; Const FileType: integer ): boolean;
// открыть текстовый файл
begin
  if not FileExists( s ) then
  begin
    Error( Format( msgFileNotFound, [s] ) );
    Result := False;
    Exit;
  end;
  WaitStatusIf( 'Загрузка файла '+s+' ...' );
  SetWordWrap( YoOptions.WordWrap ); // ? bad if >64K
  FileLoad( s, FileType );
  GoAndShowPosition( GetFileNamesPos( s ) );
  TextFileType := FileType;
  TextFileName := s;
  AddFileToList( TextFileName, Editor.SelStart, TextFileType );
  TextDirectory := ExtractFileDir( TextFileName );
  Edited := False; //?
  ClearUndo;
  YYPos.Clear;
  NoWaitStatus;
  SetControls;
  Result := True;
end;

procedure TMainForm.AddUndo(p1, p2: integer; c: char; Color: TColor; OldWord, NewWord: string  );
begin
  UndoP1.Add( p1 );
  UndoP2.Add( p2 );
  UndoColor.Add( Color );
  UndoLetter := UndoLetter + c;
  UndoOldWord.Add( OldWord );
  UndoNewWord.Add( NewWord );
  UndoEnabled := True;
  SetMenuItem( 'Undo1', True );
  Undo1.Caption := UndoCaption;
end;

procedure TMainForm.ClearUndo;
begin
  UndoP1.Clear;
  UndoP2.Clear;
  UndoColor.Clear;
  UndoLetter := '';
  UndoOldWord.Clear;
  UndoNewWord.Clear;
  Undo1.Caption := UndoCaption;
  SetMenuItem( 'Undo1', False );
end;

procedure TMainForm.ClearYYPos;
begin
  YYPos.Clear;
  SetMenuItem( 'Findyyfwd1', False );
  SetMenuItem( 'Findyyback1', False );
end;

procedure TMainForm.EditorKeyPress(Sender: TObject; var Key: Char);
begin
  ClearUndo;
  ClearYYPos;
end;

procedure TMainForm.MakeUndo;
begin
  if UndoP1.Count>0 then
  with Editor do
  begin
    SelStart := UndoP2[UndoP1.Count-1];
    SelLength := 1;
    SetSelColor( UndoColor[UndoColor.Count-1] );
    SetSelBackColor( clEditorWindow );
    SelWideText := UndoLetter[UndoP1.Count];
    SelStart := UndoP1[UndoP1.Count-1];
    UndoP1.Delete(UndoP1.Count-1);
    UndoP2.Delete(UndoP2.Count-1);
    UndoColor.Delete(UndoColor.Count-1);
    UndoLetter := DropLastChar(UndoLetter);
    UndoOldWord.Delete(UndoOldWord.Count-1);
    UndoNewWord.Delete(UndoNewWord.Count-1);
    if UndoP1.Count=0 then
      UndoEnabled := False;
    SetMenuItem( 'Undo1', UndoEnabled );
    Undo1.Caption := UndoCaption;
  end;
end;

function TMainForm.UndoCaption: string;
begin
  if UndoP1.Count>0 then
    Result := 'Откат "' + UndoOldWord[UndoOldWord.Count-1] + ' -> ' + UndoNewWord[UndoNewWord.Count-1] + '"'
  else
    Result := 'Откат';
end;

function GetContext( LineN, PosN: integer; cWord: string; Var di: integer ): string;
Var
// вариант с использованием Text работает очень долго !?
// пока оставлен этот - быстрый, но некрасивый
  i, p, n: integer;
  s: string;
  ls: integer;
  c: char;
  ToCut: boolean;
//
function PrevChar: boolean;
begin
  if p>1 then
  begin
    Dec( p );
    if p<=ls then
      c := s[p]
    else if p=ls+1 then
      c := #13
    else
      c := #10;
    Result := True;
  end
  else if i>0 then
  begin
    Dec( i );
    s := MainForm.Editor.Lines[i];
    ls := Length(s);
    p := ls + 2;
    c := #10;
    Result := True;
  end
  else
    Result := False;
end;
//
function NextChar: boolean;
begin
  if p<ls+2 then
  begin
    Inc( p );
    if p<=ls then
      c := s[p]
    else if p=ls+1 then
      c := #13
    else
      c := #10;
    Result := True;
  end
  else if i<MainForm.Editor.LineCount-1 then
  begin
    Inc( i );
    s := MainForm.Editor.Lines[i];
    ls := Length(s);
    p := 1;
    if p<=ls then
      c := s[p]
    else
      c := #13;
    Result := True;
  end
  else
    Result := False;
end;
//
begin
  with MainForm.Editor do
  begin
    i := LineN;
    s := Lines[i];
    ls := Length(s);
    p := PosN;
    Result := cWord;
    di := 0;
    ToCut := False;
    c := ' '; //не #13 или #10
    for n := 1 to WordsBufferLength2 do
    begin
      while PrevChar do
      begin
        Result := c + Result;
        Inc( di );
        if IsAlpha(c) then
          Break;
      end;
      while PrevChar do
      begin
        Result := c + Result;
        Inc( di );
        if not IsAlpha(c) then
        begin
          ToCut := n=WordsBufferLength2;
          Break;
        end;
      end;
    end;
    if ToCut then
    begin
      Result := Copy( Result, 2, Length(Result)-1 );
      Dec( di );
    end;
    i := LineN;
    s := Lines[i];
    ls := Length(s);
    p := PosN + Length(cWord) - 1;
    ToCut := False;
    c := ' '; //не #13 или #10
    for n := 1 to WordsBufferLength2 do
    begin
      while NextChar do
      begin
        Result := Result + c;
        if IsAlpha(c) then
          Break;
      end;
      while NextChar do
      begin
        Result := Result + c;
        if not IsAlpha(c) then
        begin
          ToCut := n=WordsBufferLength2;
          Break;
        end;
      end;
    end;
    if ToCut then
      Result := Copy( Result, 1, Length(Result)-1 );
  end;
end;

function MarkString( s: string; p, q: integer ): string;
begin
  Result := Copy(s,1,p-1)+'<'+Copy(s,p,q)+'>'+Copy(s,p+q,Length(s)-p-q+1)
end;

procedure MatchRegExp( cWord: string; RegStr0: string; RE: TRegExpr; Word1, Word2: string; Var WordN: integer;
  Context: string; di: integer );
Var
  i, j: integer;
  NewWord: string;
  IsNewWord: boolean;
  r: TDynArrayInt;
  OldContext: string;
//
procedure CalcYeYo( s: string; Var r: TDynArrayInt );
Var
  i, k: integer;
begin
  k := 0;
  for i := 1 to Length(s) do
    if IsYeYo( s[i] ) then
    begin
      Inc( k );
      SetLength( r, k+1 );
      r[k] := i;
    end;
end;
//
begin
  OldContext := Context;
  WordN := 0;
  with RE do
  begin
    ModifierI := not IsAnyUpperCase( RegStr0 );
    CalcYeYo( RegStr0, r );
    InputString := Context;
    if Exec(1) then
    repeat
      if MatchPos[0]>0 then
      begin
//
        j := 1;
        IsNewWord := False;
        for i := 1 to SubExprMatchCount do
        begin
          if (MatchLen[i]=1) and IsYeYo(Context[MatchPos[i]]) then
          begin
            Context[MatchPos[i]] := RegStr0[r[j]];
            IsNewWord := IsNewWord or (MatchPos[i]>=1+di) and (MatchPos[i]<=1+di+Length(cWord)-1);
            Inc(j);
          end;
        end;
        Context := CopyCase( Context, OldContext );
        if IsNewWord then
          NewWord := Copy(Context,1+di,Length(cWord))
        else
          NewWord := '';
        if NewWord = Word1 then
          WordN := 1
        else if NewWord = Word2 then
          WordN := 2;
        if WordN<>0 then
          Break;
      end;
    until not ExecNext;
  end;
end;

function NoCR( s: string ): string;
Var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if s[i]=#13 then
      Result := Result + '\n'
    else if s[i]<>#10 then
      Result := Result + s[i];
end;

function LookInRegExps( Const cWord: string; Idx: integer; Const Word1, Word2: string; Var WordN: integer ): boolean;
Var
  i, di: integer;
  Context: string;
  cWordNew, cWords: string;
  LineN, PosN: integer;
  outs: string;
begin
  Result := False;
  MainForm.Editor.GetLinePosition( Idx, LineN, PosN );
  Context := GetContext( LineN, PosN, cWord, di );
  for i := 0 to RegExprDic.W.Count-1 do
  begin
    MatchRegExp( cWord, RegExprDic.W0[i], RegExprDic.RE[i], Word1, Word2, WordN, Context, di );
//
    if WordN<>0 then
    begin
      Result := True;
      RegExprDic.Was[i] := RegExprDic.Was[i] + 1;
      Inc( RELS.A );
      if RegExprLog then
      begin
        if WordN=1 then
          cWordNew := Word1
        else
          cWordNew := Word2;
        if cWord<>cWordNew then
          cWords := cWord + '/' + cWordNew
        else
          cWords := cWord;
        Context := Copy(Context,1,di)+'<'+cWords+'>'+Copy(Context,di+Length(cWord)+1,Length(Context)-di-Length(cWord)+1);
        outs := Format('%d:%d; "%s"; "%s"', [LineN, PosN, NoCR(Context),RegExprDic.W[i]] );
        MainForm.WriteToRegExprLog( outs );
      end;
      Exit;
    end;
  end;
  Inc( NoRELS );
end;

{---}

procedure TMainForm.DoYoficate( LineN, PosN: integer );
begin
  ClearUndo;
  YoRunning := True;
  AskPanel.Visible := True;
  SetAskPanelView( False );
  EnableMenu( False );
  RunTime0 := Now;
  repeat
    ToMakeUndo := False;
    Yoficate( LineN, PosN );
    if ToMakeUndo then
    begin
      MakeUndo;
      Editor.GetLinePosition( Editor.SelStart, LineN, PosN );
    end;
  until not ToMakeUndo;
  YoRunning := False;
  SetAskPanelView( False );
  Constraints.MinWidth := AskBevel.Width;
  EnableMenu( True );
  AskPanel.Visible := False;
  Editor.SetFocus;
end;

procedure TMainForm.Yobegin1Click(Sender: TObject);
begin
  DoYoficate( 0, 1 );
end;

procedure TMainForm.Yopos1Click(Sender: TObject);
Var
  LineN, PosN: integer;
begin
  Editor.GetLinePosition( Editor.SelStart, LineN, PosN );
  DoYoficate( LineN, PosN );
end;

procedure TMainForm.EditorChange(Sender: TObject);
begin
  Edited := True;
  if YoRunning then  // не нужно, если изменения происходят при ёфикации
    Exit;
  SetControls;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RememberFileNamesPos;
  WriteIni;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CanBeClosed;
end;

procedure TMainForm.FindDialog1Find(Sender: TObject);
begin
  FindNextWasPressed := True;
  if FindEditor.ClassType=TRichEditU then
    FindInText( FindEditor as TRichEditU, FindDialog1, FirstFind, IsRegExpr )
  else if FindEditor.ClassType=TRichEdit then
    FindInText( FindEditor as TRichEdit, FindDialog1, FirstFind, IsRegExpr );
end;

procedure TMainForm.Find1Click(Sender: TObject);
begin
  FirstFind := True;
  Editor.SelLength := 0;
  FindEditor := Editor;
  IsRegExpr := False;
  FindDialog1.Options := FindDialog1.Options - [frHideWholeWord];
  FindAgain := False;
  FindNextWasPressed := False;
  FindDialog1.Execute; // первый раз всегда почему-то выполняется с True без вывода формы
  // поэтому придуман дурацкий способ с FindNextWasPressed и onClose;
  WasFindReg := False;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  with AboutForm do
  begin
    DicShortFileName := ExtractFileName( DicFileName );
    DicREShortFileName := ExtractFileName( RegExprDicFileName );
    lVersion.Caption := 'Версия программы: ' + YoVersion;
    lDictionary.Caption := 'Основной словарь: ' + DicShortFileName;
    if DicVersion<>'' then
      lDictionary.Caption := lDictionary.Caption + ' (v.' + DicVersion + ')';
    lDictionary.Caption := lDictionary.Caption + Format( ', %d слов'+Cas(Dic.Ye.Count,2), [Dic.Ye.Count] );
    lRegExprDic.Caption := 'СРВ: ' + DicREShortFileName;
    if DicREVersion<>'' then
      lRegExprDic.Caption := lRegExprDic.Caption + ' (v.' + DicREVersion + ')';
    lRegExprDic.Caption := lRegExprDic.Caption
      + Format( ', %d выражени'+Cas(RegExprDic.W.Count,3), [RegExprDic.W.Count] );
    Left := Self.Left + (Self.Width-AboutForm.Width) div 2;
    Top := Self.Top + (Self.Height-AboutForm.Height) div 2;
    lCopyleft.Caption := Format( '© Владимир Иванов, 2003-%d', [Year] );
    ShowModal;
  end;
end;

procedure TMainForm.Moreabout1Click(Sender: TObject);
begin
  ShellExecute(Handle,'open','http://'+MyHostName+'/yo/yo.html',nil,nil,SW_SHOWNORMAL);
end;

procedure TMainForm.Close1Click(Sender: TObject);
begin
 if CanBeClosed then
 begin
   RememberFileNamesPos;
   Editor.Clear;
   Edited := False;
   YYPos.Clear;
   Caption := '';
   TextFileName := '';
 end;
end;

procedure TMainForm.Undo1Click(Sender: TObject);
begin
  MakeUndo;
end;

procedure TMainForm.OpenDic1Click(Sender: TObject);
begin
  odDic.FileName := DicFileName;
  odDic.InitialDir := ProgramDirectory;
  if odDic.Execute then
    if FileExists( odDic.FileName ) then
    begin
      DicFileName := odDic.FileName;
      ReadDic;
    end
    else
      Error( Format( msgFileNotFound, [odDic.FileName] ) );
end;

procedure TMainForm.OpenRegExprDic1Click(Sender: TObject);
begin
  odDic.FileName := RegExprDicFileName;
  odDic.InitialDir := ProgramDirectory;
  if odDic.Execute then
    if FileExists( odDic.FileName ) then
    begin
      RegExprDicFileName := odDic.FileName;
      ReadRegExprDic;
      YoOptions.RegExprs := True;
    end
    else
      Error( Format( msgFileNotFound, [odDic.FileName] ) );
end;

procedure TMainForm.InitData;
begin
//
  ProgramDirectory := ExtractFileDir( ParamStr(0) );  // каталог программы
  SetCurrentDir(  ProgramDirectory );  // установить как рабочий
//
  DragAcceptFiles(Handle, True);  // обработчик драг-энд-дроп
//
  Editor.MaxLength := $7FFFFFF0;  // максимальная длина текста согласно D5 Richedit sample
//
  TextFileName := '';
//
  ReadParameters;  // параметры командной строки
//
  FullIniFileName := ProgramDirectory + '\' + IniFileName0; // путь к ини-файлу
  RegExprLogName := ProgramDirectory + '\' + RELogName0;
//
  FileNamesPos := TIntegerList.Create;
  FileNamesTextType := TIntegerList.Create;
//
  Editor.Color := clEditorWindow;
  Editor.Font.Color := clBlack; // цвет текста
//
  ReadIni;  // прочитать ини-файл
//
  UndoP1 := TIntegerList.Create; // создать таблицы отката
  UndoP2 := TIntegerList.Create;
  UndoColor := TIntegerList.Create;
  UndoLetter := '';
  UndoOldWord := TStringList.Create;
  UndoNewWord := TStringList.Create;
// для режима СС
  if RegExprLog then
    AssignFile( fRegExprlog, RegExprLogName );
//
  SetMenuItem( 'Yobegin1', False );
  SetMenuItem( 'Yopos1', False );
//
  Dic := TDic.Create;
  RegExprDic := TRegExprDic.Create;
//
  YoRunning := False;
//
  WindowProc := NewMainFormWinProc;
  EditorWinProc := Editor.WindowProc;
  Editor.WindowProc := NewEditorWinProc;
//
  RedefineKeyInit;
//
  with FindRegExpr do
  begin
    FindRegExpr := TRegExpr.Create;
    ModifierM := True;
    ModifierI := True;
    ModifierS := True;
    SpaceChars := MySpaceChars;
    WordChars := MyWordChars;
  end;
  with tmpRegExpr do
  begin
    tmpRegExpr := TRegExpr.Create;
    ModifierM := True;
    ModifierI := True;
    ModifierS := True;
    SpaceChars := MySpaceChars;
    WordChars := MyWordChars;
  end;
  RegExprTextFileName := '';
//
  YYPos := TIntegerList.Create;
//
  StatusBar1.Hint := StatusBarHint;
//
  Application.OnIdle := LoadAll;
end;

procedure TMainForm.Copytodicedit1Click(Sender: TObject);
begin
  CopyToDicEdit( Editor.SelWideText );
end;

procedure TMainForm.SetMenuItem( ItemName: string; v: boolean );
Var
 Item: TMenuItem;
 ToolButton: TToolButton;
begin
  Item := FindMenuItem( ItemName );
  if Item<>nil then
    Item.Enabled := v;
  ToolButton := FindToolbarItem( ItemName );
  if ToolButton<>nil then
    ToolButton.Enabled := v;
end;

procedure TMainForm.SetControls;
Var
  NotZero: boolean;
  Selected: boolean;
begin
  NotZero := Editor.TextLength<>0;
  Selected := Editor.SelLength<>0;
  SetMenuItem( 'Saveas1', NotZero );
  SetMenuItem( 'Save1', NotZero and (TextFileName<>'') );
  SetMenuItem( 'Close1', NotZero );
  SetMenuItem( 'Cut1', NotZero and Selected );
  SetMenuItem( 'Copy1', NotZero and Selected );
  SetMenuItem( 'Selectall1', NotZero );
  SetMenuItem( 'Copytodicedit1', NotZero and Selected );
  SetMenuItem( 'Find1', NotZero );
  SetMenuItem( 'Findreg1', NotZero );
  SetMenuItem( 'Yobegin1', NotZero and DicExist );
  SetMenuItem( 'Yopos1', NotZero and DicExist );
  SetMenuItem( 'Yocollect1', NotZero and DicExist );
  SetMenuItem( 'Clearfilelist1', FileNamesPos.Count>0 );
  SetMenuItem( 'Fileprop1', NotZero );
  SetMenuItem( 'Findyyfwd1', YYPos.Count>0 );
  SetMenuItem( 'Findyyback1', YYPos.Count>0 );
  SetMenuItem( 'Clearstat1', CheckedLS.A<>0 );
  SetMenuItem( 'Stat1', CheckedLS.A<>0 );
  if not YoRunning then
    Cursor := crDefault;
end;

procedure TMainForm.EditorSelectionChange(Sender: TObject);
begin
  UpdateCursorPos( Editor.SelStart );
  if YoRunning then
    Exit;
  SetControls;
end;

procedure CopyToDicEdit( Const s: string );
begin
end;

procedure TMainForm.RemoveMarkedLetters;
Var
  OldSelStart: integer;
begin
  with Editor do
  begin
    OldSelStart := SelStart;
    SelStart := 0;
    SelLength := Length( Text );
    SetSelColor( Editor.Font.Color );
    SetSelBackColor( clEditorWindow );
    SelLength := 0;
    SelStart := OldSelStart;
  end;
end;

procedure TMainForm.Clearusersel1Click(Sender: TObject);
Var
  i: integer;
begin
  for i := 0 to Dic.UserSel.Count-1 do
    Dic.UserSel[i] := 0;
  SetMenuItem( 'Clearusersel1', False );
end;

procedure TMainForm.AddFileToList( Const s: TFileName; p: integer; Const TextType: integer );
// добавить файл в список последних
Var
  NewItem: TMenuItem;
  i: integer;
begin
  if GetFileNamesN( s )<>0 then
    Exit;
  SetMenuItem( 'Clearfilelist1', True );
  if FileNamesInList=0 then
  begin
    File1.Add(NewLine);
    FileNamesFirstItemN := File1.Count;
  end;
  if FileNamesInList < MaxFileNamesInList then
  begin
    Inc( FileNamesInList );
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := s;
    NewItem.OnClick := OpenTextInList;
    NewItem.ShortCut := ShortCut(Word(Ord('0')+FileNamesInList), [ssCtrl]);
    NewItem.Bitmap := Openfile0.Bitmap;
    File1.Add( NewItem );
    FileNamesPos.Add( p );
    FileNamesTextType.Add( TextType );
  end
  else
  begin
    for i := FileNamesFirstItemN to File1.Count-1 do
    if i<File1.Count-1 then
    begin
      File1.Items[i].Caption := File1.Items[i+1].Caption;
      FileNamesPos[i-FileNamesFirstItemN] := FileNamesPos[i-FileNamesFirstItemN+1];
      FileNamesTextType[i-FileNamesFirstItemN] := FileNamesTextType[i-FileNamesFirstItemN+1];
    end
    else
    begin
      File1.Items[i].Caption := s;
      FileNamesPos[i-FileNamesFirstItemN] := p;
      FileNamesTextType[i-FileNamesFirstItemN] := TextType;
    end;
  end;
end;

procedure TMainForm.OpenTextInList(Sender: TObject);
Var
  FileName: string;
  i: integer;
begin
  if not CanBeClosed then
    Exit;
  RememberFileNamesPos;
  with Sender as TMenuItem do
  begin
    FileName := Caption;
    i := MenuIndex;
    OpenText( FileName, FileNamesTextType[i-FileNamesFirstItemN] );
  end;
end;

procedure TMainForm.Clearfilelist1Click(Sender: TObject);
Var
  i: integer;
begin
  if not Warning( msgClear, False ) then
    Exit;
  for i := File1.Count-1 downto FileNamesFirstItemN-1 do
    File1.Items[i].Free;
  FileNamesPos.Clear;
  FileNamesInList := 0;
  SetMenuItem( 'Clearfilelist1', False );
end;

procedure TMainForm.RememberFileNamesPos;
Var
  i: integer;
begin
  if TextFileName='' then
    Exit;
  for i := FileNamesFirstItemN to File1.Count-1 do
    if LC(File1.Items[i].Caption)=LC(TextFileName) then
      FileNamesPos[i-FileNamesFirstItemN] := Editor.SelStart;
end;

function TMainForm.GetFileNamesN( Const s: TFileName ): integer;
Var
  i: integer;
begin
  Result := 0;
  if s='' then
    Exit;
  for i := FileNamesFirstItemN to File1.Count-1 do
    if LC(File1.Items[i].Caption)=LC(s) then
    begin
      Result := i-FileNamesFirstItemN+1;
      Exit;
    end;
end;

function TMainForm.GetFileNamesPos( Const s: TFileName ): integer;
Var
  i: integer;
begin
  i := GetFileNamesN(s);
  if i>0 then
    Result := FileNamesPos[i-1]
  else
    Result := 0;
end;

procedure TMainForm.FormCreate(Sender: TObject);
// создать графические элементы
begin
// редактор
  Editor := TRichEditU.Create( Self );
  with Editor do
  begin
    Parent := Self;
    Left := 0;
    Top := 0;
    Width := 563;
    Height := 290;
    TabStop := False;
    Align := alClient;
    Font.Charset := DEFAULT_CHARSET;
    Font.Color := clWindowText;
    Font.Height := -11;
    Font.Name := 'Courier New';
    Font.Style := [];
    HideSelection := False;
    ParentFont := False;
    PlainText := True;
    ScrollBars := ssBoth;
    TabOrder := 0;
    WordWrap := False;
    OnChange := EditorChange;
    OnKeyPress := EditorKeyPress;
    OnSelChange := EditorSelectionChange;
    PopupMenu := PopupMenu1;
  end;
// окно в панели запроса
  reAskText := TRichEditU.Create( AskPanel );
  with reAskText do
  begin
    Parent := AskPanel;
    Left := 0;
    Top := 1;
    Width := 561;
    Height := 23;
    TabStop := False;
    Enabled := True;
    PlainText := True;
    ReadOnly := True;
    TabOrder := 0;
    WordWrap := False;
    onEnter := RestoreFocus;
  end;
// тулбар
  ToolBarImageList := TImageList.Create( MainForm );
  with ToolBarImageList do
  begin
    Height := 16;
    Width := 16;
    BkColor := clBtnFace;
  end;
  CreateToolButtons; //создаём один раз кнопки для тулбара, пока без битмапов
  with ToolBar1 do
  begin
    Images := ToolBarImageList;
    Hint := ToolBarHint;
  end;
  MenuItemsX := TMenuItemsX.Create; // список для сбора всех пунктов меню, которых нет на тулбаре
//
// создать диалоги
  odxText := TOpenDialogEx.Create( Self );
  sdxText := TSaveDialogEx.Create( Self );
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  EnableAskControls( False );
  Editor.SetFocus;
  AskPanel.Visible := False;
end;

procedure TMainForm.LoadAll(Sender: TObject; var Done: Boolean);
begin
  Application.OnIdle := nil;
//
  Toolbar1.Enabled := False;
//
  ReadDic;
//
  ReadRegExprDic;
//
  if TextFileName<>'' then  //если есть файл - открыть
    if not OpenText( TextFileName, TextFileType ) then
      TextFileName := '';
//
  SetControls;
//
  Edited := False;
//
  Toolbar1.Enabled := True;
end;

procedure TMainForm.WaitStatus(Msg: string);
begin
  WaitCursor;
  OldStatusBarText := StatusBar1.Panels[1].Text;
  StatusInfo( Msg );
  Repaint;
end;

procedure TMainForm.WaitStatusIf(Msg: string);
begin
  WaitStatus( Msg );
end;

procedure TMainForm.NoWaitStatus;
begin
  NormCursor;
  StatusInfo( OldStatusBarText );
  Repaint;
end;

procedure TMainForm.NewEditorWinProc(var Msg: TMessage);
begin
  if YoRunning and ( (Msg.Msg=WM_LBUTTONDOWN) or (Msg.Msg=WM_LBUTTONDBLCLK) ) then
    Exit
  else
    EditorWinProc( Msg );
end;

function TMainForm.WaitForAnswer: TModalResult;
begin
  Editor.ReadOnly := True;
  AskResult := 0;
  repeat
    Application.HandleMessage;
  until AskResult <> 0;
  Result := AskResult;
  Editor.ReadOnly := False;
end;

procedure TMainForm.EnableAskControls( v: boolean );
begin
  if not v then
    InitAskParams;
  bYe.Enabled := v;
  bYo.Enabled := v;
  bYeAll.Enabled := v;
  bYoAll.Enabled := v;
  bUndo.Enabled := v;
  bCancel.Enabled := v;
  if v then
    bUndo.Enabled := UndoEnabled;
  with Constraints do
  if v then
  begin
    MinWidth := Width;
    MaxWidth := Width;
    MinHeight := Height;
    MaxHeight := Height;
  end
  else
  begin
    MinWidth := AskBevel.Width;
    MaxWidth := 0;
    MinHeight := 0;
    MaxHeight := 0;
  end;
  SetAskPanelView( v );
end;

procedure TMainForm.EnableMenu( v: boolean );
Var
  i: integer;
begin
  for i := 0 to MainForm.MainMenu1.Items.Count-1 do
    MainForm.MainMenu1.Items.Items[i].Enabled := v;
  ToolBar1.Enabled := v;
  if not v then
  begin
    MainForm.Edit1.Enabled := True;
    for i := 0 to MainForm.Edit1.Count-1 do
      MainForm.Edit1.Items[i].Enabled := False;
    MainForm.CopyToDicEdit1.Enabled := True;
  end
  else
  begin
    SetControls;
    SetMenuItem( 'Paste1', True );
  end;
end;

procedure TMainForm.bYeClick(Sender: TObject);
begin
  AskResult := mrYe;
end;

procedure TMainForm.bYoClick(Sender: TObject);
begin
  AskResult := mrYo;
end;

procedure TMainForm.bYeAllClick(Sender: TObject);
begin
  AskResult := mrYeAll;
end;

procedure TMainForm.bYoAllClick(Sender: TObject);
begin
  AskResult := mrYoAll;
end;

procedure TMainForm.bUndoClick(Sender: TObject);
begin
  AskResult := mrUndo;
end;

procedure TMainForm.bCancelClick(Sender: TObject);
begin
  AskResult := mrCancel;
end;

function TMainForm.FindContext( i: integer; Var SelStart0, SelLength0: integer ): WideString;
Var
  w, i1, i2: integer;
begin
  with Editor do
  begin
    w := FindTextLength( i, reAskText.Font ) - SelLength;
    i1 := Max( SelStart - w div 2, 1 );
    i2 := Min( SelStart + SelLength + w div 2, Length(Text) );
    Result := Copy( WideText, i1, i2-i1+1 );
    for i := 1 to Length(Result) do
      if Result[i] in [WideChar(#10),WideChar(#13)] then
        Result[i] := ' ';
    SelStart0 := SelStart - i1 + 1; //?
    SelLength0 := SelLength;
  end;
end;

procedure TMainForm.SetAskParams( Const w1, w2: string; WrongYo, ReplacedYo,
  WrongYe: boolean; ToFocusFirst: boolean; Const UndoCaption: string );
Var
  SelStart1, SelLength1: integer;
begin
  // заголовок
  if ReplacedYo then
    lCaption.Caption := 'Странное расположение "Ё"'
  else if WrongYo then
    lCaption.Caption := 'Вероятно, здесь должна быть "Е"'
  else if WrongYe then
    lCaption.Caption := 'Вероятно, здесь должна быть "Ё"'
  else
    lCaption.Caption := 'Выберите верный вариант';
  if WrongYe or WrongYo then
    lCaption.Font.Color := clRed
  else
    lCaption.Font.Color := clNavy;
  // подписи к кнопкам
  SetButtonCaption( bYe, w1 );
  SetButtonCaption( bYo, w2 );
  bUndo.Caption := UndoCaption;
//
  bYeAll.Enabled := not WrongYo;
  bYoAll.Enabled := not WrongYo;
  if Visible and Enabled then
    if ToFocusFirst then
      bYe.SetFocus
    else
      bYo.SetFocus;
  with reAskText do
  begin
    reAskText.Font := Editor.Font;
    reAskText.Font.Size := 12;// Round(Editor.Font.Size*1.2);
    Text := FindContext( reAskText.Width, SelStart1, SelLength1 );
    SelStart := SelStart1;
    SelLength := SelLength1;
    //
    SetSelColor( clRed );
    SetSelStyle( [fsBold] );
    SelLength := 0;
  end;
  AlignAskPanel;
  AskPanelFocusFirst := ToFocusFirst;
end;

procedure TMainForm.InitAskParams;
begin
  // заголовок
  lCaption.Caption := '';
  lCaption.Font.Color := clNavy;
  // подписи к кнопкам
  InitButtons;
  AlignAskPanel;
end;

procedure TMainForm.AlignAskPanel;
Const
  HMargin = 10;
Var
  w: integer;
begin
  // задать ширину формы и кнопок
  w := Max( Max( DefineTextWidth(bYe.Caption,bYe.Font), DefineTextWidth(bYe.Caption,bYe.Font) ), DefineTextWidth(bUndo.Caption,bUndo.Font) ) + 4*HMargin;
  bYe.Width := w;
  bYo.Width := w;
  bUndo.Width := w;
  AskBevel.ClientWidth := Max( w + HMargin + bYeAll.Width, lCaption.Width ) + 2*HMargin;
// не работает ?
//  if AskPanel.ClientWidth<AskBevel.Width then
//  begin
//    AskPanel.ClientWidth := AskBevel.Width;
//    ClientWidth := AskPanel.Width;
//  end;
  AskBevel.Left := ( AskPanel.ClientWidth - AskBevel.Width ) div 2;
  lCaption.Left := AskBevel.Left + (AskBevel.ClientWidth - lCaption.Width) div 2;
  bYe.Left := AskBevel.Left + (AskBevel.ClientWidth-bYe.Width-HMargin-bYeAll.Width) div 2;
  bYo.Left := bYe.Left;
  bUndo.Left := bYe.Left;
  bYeAll.Left := bYe.Left + bYe.Width + HMargin;
  bYoAll.Left := bYo.Left + bYo.Width + HMargin;
  bCancel.Left := bUndo.Left + bUndo.Width + HMargin;
  AskLeftRect.Width := AskBevel.Left;
  AskRightRect.Left := AskBevel.Left + AskBevel.Width;
  AskRightRect.Width := AskPanel.Width - AskRightRect.Left + 1;
  AskColorRect.Width := AskPanel.Width;
  reAskText.Width := AskPanel.Width;
end;

function TMainForm.DefineTextWidth( Const s: string; Font: TFont ): integer;
begin
  lSample.Font := Font;
  Result := lSample.Canvas.TextWidth( s );
end;

function TMainForm.FindTextLength( i: integer; Font: TFont ): integer;
begin
  Result := i div DefineTextWidth('x',Font);
end;

procedure TMainForm.SetAskPanelView( v: boolean );
Var
  c: TColor;
begin
  if v then
    c := clAskPanelActive
  else
  begin
    c := clAskPanelPassive;
    lCaption.Caption := 'Подождите или нажмите Esc';
    AlignAskPanel;
  end;
  AskColorRect.Brush.Color := c;
  lCaption.Color := c;
  AskPanel.Repaint;
end;

procedure TMainForm.NewMainFormWinProc(var Msg: TMessage);
begin
// Не максимизировать и не закрывать, если ёфикация
  if YoRunning and
    (Msg.Msg=WM_SYSCOMMAND) and ( (Msg.WParam=SC_MAXIMIZE) or (Msg.WParam=SC_CLOSE) )
  then
    Exit
  else
    WndProc( Msg );
end;

procedure TMainForm.RedefineKeyInit;
begin
  RedefiningKey := TMaskEdit.Create( MainForm );
  with RedefiningKey do
  begin
    Hide;
    EditMask := 'A';
    Width := 13;
    CharCase := ecUpperCase;
    onKeyPress := RedefineKeyPress;
  end;
end;

procedure TMainForm.SetButtonHotKey( i: integer; c: char );
Var
  p: integer;
  s: string;
begin
  if (i<=0) or (i>4) then
    Exit;
  with Buttons[i] do
  begin
    if ContainsChar( ButtonHotKeys, c ) then
      Exit;
    ButtonHotKeys[i] := c;
    p := Pos( '&', Caption );
    if p<>0 then
    begin
      s := Caption;
      s[p+1] := c;
      Caption := s;
    end;
  end;
end;

procedure TMainForm.RedefineKeyPress(Sender: TObject; var Key: Char);
begin
  with RedefiningKey do
  if Key in [#13,#27] then
  begin
    if Key=#13 then
      SetButtonHotKey( ButtonTag, Text[1] );
    RedefiningKey.Hide;
    bCancel.Cancel := True;
    EnableButtons;
    ClearEsc;
  end;
end;

procedure TMainForm.RedefineKey( Sender: TObject );
Var
  b: TButton;
  s: string;
  p: integer;
begin
  b := Sender as TButton;
  if not b.Enabled then
    Exit;
  with RedefiningKey do
  begin
    Top := b.Top + (b.Height-Height) div 2;
    s := b.Caption;
    p := Pos( '&', s );
    Left := b.Left + (b.Width-Width) div 2 + DefineTextWidth(Copy(s,1,p-1),b.Font) div 2;
    ButtonTag := b.Tag;
    DisableButtons;
    Show;
    bCancel.Cancel := False;
    Parent := AskPanel;
    Text := Char(ButtonHotKeys[b.Tag]);
    SetFocus;
  end;
end;

procedure SetButtonCaption(b: TButton; Const s: string);
begin
  with b do
    Caption := s + ' (&' + ButtonHotKeys[b.Tag] + ')'
end;

procedure TMainForm.InitButtons;
Var
  i: integer;
begin
  Buttons[1] := bYe;
  Buttons[2] := bYo;
  Buttons[3] := bYeAll;
  Buttons[4] := bYoAll;
  Buttons[5] := bUndo;
  Buttons[6] := bCancel;
  for i := 1 to 6 do
    Buttons[i].Tag := i;
  SetButtonCaption( bYe, 'Е' );
  SetButtonCaption( bYo, 'Ё' );
  SetButtonCaption( bYeAll, 'Всегда Е' );
  SetButtonCaption( bYoAll, 'Всегда Ё' );
  bUndo.Caption := 'Откат';
end;

procedure TMainForm.bYeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    RedefineKey( Sender );
end;

procedure TMainForm.bYoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    RedefineKey( Sender );
end;

procedure TMainForm.bYeAllMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    RedefineKey( Sender );
end;

procedure TMainForm.bYoAllMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    RedefineKey( Sender );
end;

procedure TMainForm.DisableButtons;
Var
  i: integer;
begin
  for i := 1 to 6 do
  begin
    ButtonsEnabled[i] := Buttons[i].Enabled;
    Buttons[i].Enabled := False;
  end;
end;

procedure TMainForm.EnableButtons;
Var
  i: integer;
begin
  for i := 1 to 6 do
    Buttons[i].Enabled := ButtonsEnabled[i];
end;

function TMainForm.GetDicVersion( Const s: string ): string;
Var
  p: integer;
begin
  p := Pos( VerStr, s );
  if p<>0 then
    Result := Trim(Copy(s,p+Length(VerStr),Length(s)-p+1-Length(VerStr)))
  else
    Result := '';
end;

procedure TMainForm.Findreg1Click(Sender: TObject);
begin
  FirstFind := True;
  Editor.SelLength := 0;
  FindEditor := Editor;
  IsRegExpr := True;
  FindDialog1.Options := FindDialog1.Options + [frHideWholeWord];
  FindAgain := False;
  FindDialog1.Execute;
//  FindAgain1.Enabled := True;
  WasFindReg := True;
//  FindAgain1.Caption := 'Найти РВ снова';
end;

procedure TMainForm.Findagain1Click(Sender: TObject);
begin
  FindAgain := True;
  FindDialog1Find( Self );
end;

// RichEditU

procedure TRichEditU.SetSelectionMarkColor( AColor: TColor ); // does not work for REU ?
Var
  Format: TCharFormat2;
begin
  FillChar(Format, SizeOf(Format), 0);
  with Format do
  begin
    cbSize := SizeOf(Format);
    dwMask := CFM_COLOR;
    crBackColor := AColor;
    Perform(EM_SETCHARFORMAT, SCF_SELECTION, Longint(@Format));
  end;
end;

function ContainsWideChar( Const s: WideString; c: WideChar ): boolean;
begin
  Result := Pos( c, s ) <> 0;
end;

function TRichEditU.GetLine(i: integer): WideString;
begin
  Result := WideLines[i];
  if (Result<>'') and (Result[Length(Result)]=#$0D) then
    Result := Copy(Result,1,Length(Result)-1);
end;

procedure TRichEditU.PutLine(i: integer; const s: WideString);
Var
  OldSelStart: integer;
begin
  OldSelStart := SelStart;
  SelStart := PositionByLine(i);
  SelLength := PositionByLine(i+1) - SelStart;
  SelWideText := s;
  SelStart := OldSelStart;
  SelLength := 0;
end;

procedure TRichEditU.GetLinePosition( Const Idx: integer; Var LineN, PosN: integer );
// определить строку и отступ по позиции символа
begin
  LineN := Perform( EM_EXLINEFROMCHAR, 0, Idx);
  PosN := (Idx - Perform( EM_LINEINDEX{187}, LineN, 0)) + 1;
end;

procedure TRichEditU.UpdateCursorPosition( StatusBar: TStatusBar; PanelN: integer );
Var
  LineN, PosN: integer;
begin
  GetLinePosition( SelStart, LineN, PosN );
  if PanelN>=0 then
    StatusBar.Panels[0].Text := Format('%d:%d (%d)', [LineN+1, PosN, LineCount])
  else
    StatusBar.SimpleText := Format('%d:%d (%d)', [LineN+1, PosN, LineCount]);
  StatusBar.Repaint;
end;

procedure TRichEditU.GoAndShowPosition( const i: integer );
begin
  if i<0 then
    Exit;
  SelStart := i;
  SelLength := 0;
  EnsureSelVisible;
end;

procedure TRichEditU.LoadFromFile( const FileName: TFileName; Const TextType: integer );
Var
  Flags: integer; // SF_TEXT or SF_RTF or SF_RTFNOOBJS or SF_TEXTIZED or SF_UNICODE
  UnicodeSignature: word;
begin
  Flags := SF_TEXT;
  if TextType and ttRTF <> 0  then
    Flags := Flags or SF_RTF;
  if TextType and ttUTF16LE <> 0 then
    Flags := Flags or SF_UNICODE;
  BeginUpdate;
  inherited LoadFromFile( FileName, Flags );
  UnicodeSignature := Ord(WideText[1]);
  if
    ( UnicodeSignature = UnicodeSignatureUTF16BE )
    or
    ( UnicodeSignature = UnicodeSignatureUTF16LE )
  then
    WideText := Copy(WideText,2,Length(WideText)-1);
  if (TextType and ttUTF8 <> 0) and (TextType and ttUTFsgn = 0) then
    WideText := UTF8Decode(Text);
  EndUpdate;
end;

procedure TRichEditU.SaveToFile( const FileName: TFileName; Const TextType: integer );
Var
  Flags: integer; // SF_TEXT or SF_RTF or SF_RTFNOOBJS or SF_TEXTIZED or SF_UNICODE
  tmpText: WideString;
begin
  Flags := SF_TEXT;
  if TextType and ttRTF <> 0 then
    Flags := Flags or SF_RTF;
  if TextType and ttUTF8 <> 0 then
  begin
    tmpText := WideText;
    BeginUpdate;
    WideText := UTF8Encode(WideText);
    WideText :=
    Char(Lo(UnicodeSignatureUTF8a))
    + Char(Hi(UnicodeSignatureUTF8a))
    + Char(UnicodeSignatureUTF8b) + WideText;
  end
  else if TextType and ttUTF16LE <> 0 then
  begin
    Flags := Flags or SF_UNICODE;
    BeginUpdate;
    WideText := WideChar(UnicodeSignatureUTF16LE) + WideText;
  end;
  inherited SaveToFile( FileName, Flags );
  if TextType and ttUTF8 <> 0 then
  begin
    WideText := tmpText;
    EndUpdate;
  end
  else if TextType and ttUTF16LE <> 0 then
  begin
    EndUpdate;
    WideText := Copy( WideText, 2, Length(WideText)-1 );
  end;
end;

procedure TRichEditU.LinesAdd( Const s: WideString );
begin
  if TextLength=0 then
    WideText := s
  else
    WideText := WideText + #13#10 + s;
end;

procedure TRichEditU.SetSelSize( s: integer );
begin
  UCF := CreateCharFormat( [cfmSize], [] );
  UCF.Size := s;
  UCF.SetSelection;
  UCF.Free;
end;

procedure TRichEditU.SetSelColor( c: TColor );
begin
  UCF := CreateCharFormat( [cfmColor], [] );
  UCF.Color := c;
  UCF.SetSelection;
  UCF.Free;
end;

procedure TRichEditU.SetSelBackColor( c: TColor );
begin
  UCF := CreateCharFormat( [cfmBackColor], [] );
  UCF.BackColor := c;
  UCF.SetSelection;
  UCF.Free;
end;

function TRichEditU.GetSelColor: TColor;
begin
  UCF := CreateCharFormat( [cfmColor], [] );
  UCF.GetSelection;
  Result := UCF.Color;
  UCF.Free;
end;

function TRichEditU.GetSelBackColor: TColor;
begin
  UCF := CreateCharFormat( [cfmBackColor], [] );
  UCF.GetSelection;
  Result := UCF.BackColor;
  UCF.Free;
end;

procedure TRichEditU.SetSelStyle( s: TFontStyles );
// (fsBold, fsItalic, fsUnderline, fsStrikeOut)
// cfeBold, cfeDisabled, cfeEmboss, cfeHidden, cfeImprint, cfeItalic, cfeOutline, cfeProtected, cfeShadow, cfeSmallCaps, cfeStrikeout, cfeSubscript
// работает только с жирностью!
Var
  aEffects: TGsvUnicodeCharFormatEffects;
begin
  aEffects := [];
  if fsBold in s then
    aEffects := aEffects + [cfeBold];
  UCF := CreateCharFormat( [], aEffects );
  UCF.Bold := (fsBold in s);
  UCF.SetSelection;
  UCF.Free;
end;

procedure TRichEditU.SetSelName( Const n: string );
begin
  UCF := CreateCharFormat( [cfmFace], [] );
  UCF.Face := n;
  UCF.SetSelection;
  UCF.Free;
end;

function TRichEditU.GetDefSize: integer;
begin
  UCF := CreateCharFormat( [cfmSize], [] );
  UCF.GetSelection;
  Result := UCF.Size;
  UCF.Free;
end;

// Dialogs

procedure TDialogEx.DoShow;
begin
  if not SaveDialog and YoOptions.AutoUnicode then
    EnableEncoding := False
  else
  begin
    EnableEncoding := True;
    case TypeOfText and ttUnicode of
      0: EncodingIndex := AnsiIndex;
      ttUTF16LE: EncodingIndex := UTF16Index;
      ttUTF8: EncodingIndex := UTF8Index;
    else
      EncodingIndex := AnsiIndex;
    end;
  end;
  inherited DoShow;
end;

function TDialogEx.Execute: boolean;
Var
  tt: word;
begin
  Result := inherited Execute;
  TypeOfText := 0;
  case EncodingIndex of
    AnsiIndex: tt := 0;
    UTF16Index: tt := ttUTF16LE;
    UTF8Index: tt := ttUTF8;
  else
    tt := 0;
  end;
  TypeOfText := TypeOfText or tt;
  if not SaveDialog and (FilterIndex=odxRTFIndex)
    or SaveDialog and (FilterIndex=sdxRTFIndex) then
      TypeOfText := TypeOfText or ttRTF;
end;

constructor TOpenDialogEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := 'Plain text|*.txt|Rich text|*.rtf|FictionBook text|*.fb2|All types|*.*';
  FilterIndex := 4;
  odxRTFIndex := 2;
  SaveDialog := False;
  EncodingStrings := TStringList.Create;
  EncodingStrings.Add( 'ANSI' );
  EncodingStrings.Add( 'UTF-8' );
  EncodingStrings.Add( 'UTF-16' );
  EnableEncoding := True;
end;

constructor TSaveDialogEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := 'Plain text|*.txt|Rich text|*.rtf';
  sdxRTFIndex := 2;
  SaveDialog := True;
  EncodingStrings := TStringList.Create;
  EncodingStrings.Add( 'ANSI' );
  EncodingStrings.Add( 'UTF-8' );
  EncodingStrings.Add( 'UTF-16' );
  EnableEncoding := True;
end;

function TSaveDialogEx.Execute: boolean;
begin
  if TypeOfText and ttRTF <> 0 then
    FilterIndex := sdxRTFIndex
  else
    FilterIndex := 1;
  Result := inherited Execute;
end;

procedure TRichEditU.RestoreFocus(Sender: TObject);
begin
  MainForm.EnableAskControls( True );
  if AskPanelFocusFirst then
    MainForm.bYe.SetFocus
  else
    MainForm.bYo.SetFocus
end;

function UnicodeTextType( const FileName: TFileName; Auto: boolean ): byte;
Const
  u8Q = 20; // минимальное количество слов с D0/D1 для выбора UTF-8
Var
  f: file of word;
  w: word;
  i, u16h, nu16h, u16l, nu16l, u8: integer;
  l, h: byte;
  s: string;
  isUTF8a: boolean;
begin
  AssignFile( f, FileName );
  Reset( f );
  i := 0;
  u16h := 0;
  nu16h := 0;
  u16l := 0;
  nu16l := 0;
  u8 := 0;
  Result := 0;
  s := '';
  isUTF8a := False;
  while not Eof(f) do
  begin
    Read( f, w );
    Inc( i );
    if i=1 then
    begin
      if w=UnicodeSignatureUTF16BE then
        Result := ttUTF16BE or ttUTFsgn
      else if w=UnicodeSignatureUTF16LE then
        Result := ttUTF16LE or ttUTFsgn
      else if w=UnicodeSignatureUTF8a then
        isUTF8a := True;
    end
    else if (i=2) and isUTF8a and (Lo(w) = UnicodeSignatureUTF8b) then
      Result := ttUTF8 or ttUTFsgn;
    l := Lo(w);
    h := Hi(w);
    if Result=0 then
    begin
      if (h=$00) or (h=$04) then //базовый или русский юникод LE
        Inc(u16h)
      else
        Inc(nu16h);
      if (l=$00) or (l=$04) then //базовый или русский юникод BE
        Inc(u16l)
      else
        Inc(nu16l);
    end;
    if w<>13 then
      s := s + Char(w)
    else if not Auto then
      Break;
    if h<>13 then
      s := s + Char(h)
    else if not Auto then
      Break;
    if (h and $FE) = $D0 then
      Inc(u8)
    else if (l and $FE) = $D0 then
      Inc(u8);
    if i>=UTFLength then
      Break;
  end;
  CloseFile( f );
  if (Result = 0) and (Pos( 'encoding="utf-8"', LowerCase(s) ) <> 0) then
    Result := ttUTF8
  else if (Result=0) and Auto then
  begin
    if u8>u8Q then
      Result := ttUTF8
    else if (u16h>=u16l) and (u16h>nu16h) then
      Result := ttUTF16LE
    else if u16l>nu16l then
      Result := ttUTF16BE;
  end;
end;

function RTFTextType( Const FileName: TFileName ): byte;
Var
  Ext: string[4];
begin
  Result := 0;
  Ext := ExtractFileExt( AnsiUpperCase( FileName ) );
  if Ext='.RTF' then
    Result := ttRTF;
end;

procedure TMainForm.CalculateFileProp;
Var
  i: integer;
  f: file of byte;
  TextFileSize: longint;
  nCyr, nYe, nYo, Y: longint;
  sY: string;

procedure CalcStat;
Var
  k: integer;
  s: string;
begin
  nCyr := 0;
  nYe := 0;
  nYo := 0;
  s := Editor.WideText;
  for k := 1 to Editor.TextLength do
  begin
    if IsAlpha(s[k]) then
      Inc( nCyr );
    if IsYe(s[k]) then
      Inc( nYe );
    if IsYo(s[k]) then
      Inc( nYo );
  end;
end;

begin
  CalcStat;
  with FilePropForm.sgProp, FileProps do
  begin
    ColWidths[1] := FilePropForm.ClientWidth-ColWidths[0];
    i := 0;
    //
    Cells[0,i] := 'Имя файла';
    Cells[1,i] := TextFileName;
    //
    Inc( i );
    Cells[0,i] := 'Формат файла';
    Cells[1,i] := '';
    if TextFileName<>'' then
    begin
      if TextFileType and ttUTF8 <> 0 then
        Cells[1,i] := Cells[1,i] + 'UTF-8'
      else if TextFileType and ttUTF16LE <> 0 then
        Cells[1,i] := Cells[1,i] + 'UTF-16LE'
      else if TextFileType and ttUTF16BE <> 0 then
        Cells[1,i] := Cells[1,i] + 'UTF-16BE'
      else
        Cells[1,i] := Cells[1,i] + 'ANSI';
      if TextFileType and ttUTFsgn <> 0 then
        Cells[1,i] := Cells[1,i] + 'sgn';
      if TextFileType and ttRTF <> 0 then
        Cells[1,i] := Cells[1,i] + ', rich text'
      else
        Cells[1,i] := Cells[1,i] + ', plain text';
    end
    else
      Cells[1,i] := '';
    //
    Inc( i );
    Cells[0,i] := 'Длина файла в байтах';
    if TextFileName<>'' then
    begin
      AssignFile( f, TextFileName );
      Reset( f );
      TextFileSize := FileSize( f );
      CloseFile( f );
      Cells[1,i] := Format( '%d', [TextFileSize] );
    end
    else
      Cells[1,i] := '';
    //
    Inc( i );
    Cells[0,i] := 'Длина текста в символах';
    Cells[1,i] := Format( '%d', [Editor.TextLength] );
    //
    Inc( i );
    Cells[0,i] := 'Число символов кириллицы';
    Cells[1,i] := Format( '%d', [nCyr] );
    //
    Inc( i );
    Cells[0,i] := 'Число е';
    Cells[1,i] := Format( '%d', [nYe] );
    //
    Inc( i );
    Cells[0,i] := 'Число ё';
    Cells[1,i] := Format( '%d', [nYo] );
    //
    Inc( i );
    Cells[0,i] := 'Степень ёфикации';
    if nYe<>0 then
      Y := Round(nYo*1500.0/nYe)
    else if nYo>0 then
      Y := 100
    else
      Y := 0;
    if Y=0 then
      sY := 'не ёфицировано'
    else if Y<75 then
      sY := 'возможно, ёфицировано не полностью'
    else
      sY := 'возможно, ёфицировано';
    Cells[1,i] := Format( '%d%% (%s)', [Y,sY] );
  end;
end;

procedure TMainForm.SaveFile;
begin
  WaitCursor;
  Editor.SaveToFile( TextFileName, TextFileType );
  Edited := False;
  NormCursor;
end;

function TMainForm.SaveFileAs: boolean;
begin
  Result := False;
  with sdxText do
  begin
    FileName := TextFileName;
    TypeOfText := TextFileType;
    if Execute then
    begin
      if FileExists( FileName ) and not CanBeRewriten( FileName ) then
        Exit;
      if
        (
          (TextFileType and ttRTF <> 0) and (TypeOfText and ttRTF = 0)
          or
          (TextFileType and ttUnicode <> 0) and (TypeOfText and ttUnicode = 0)
        )
        and not Warning( msgMayBeLost, False ) then
        Exit;  //?
      WaitCursor;
      TextFileType := TypeOfText;
      Editor.SaveToFile( FileName, TextFileType );
      Edited := False;
      NormCursor;
//
      TextDirectory := ExtractFileDir( sdxText.FileName );
      TextFileName := sdxText.FileName;
      Caption := TextFileName;
      AddFileToList( TextFileName, Editor.SelStart, TextFileType );
      Result := True;
    end;
  end;
end;

{--- автоматически сгенерированный процедуры ---}

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if not CanBeClosed then
    Exit;
  odxText.InitialDir := TextDirectory;
  if odxText.Execute then
  begin
    odxText.TypeOfText :=  GetTextType( odxText.FileName, odxText.TypeOfText );
    if odxText.TypeOfText and ttUTF16BE <> 0 then
      Info( msgUTF16BE );
    if odxText.TypeOfText and ttUTF8 <> 0 then
      if UTF8Warning and not Warning( msgUTF8Warning, False ) then
        Exit
      else
        UTF8Warning := False;
    WaitCursor;
    RememberFileNamesPos;
    OpenText( odxText.FileName, odxText.TypeOfText );
    NormCursor;
  end;
end;

procedure TMainForm.Saveas1Click(Sender: TObject);
begin
  if Editor.LineCount=0 then
    Exit;
  SaveFileAs;
end;

procedure TMainForm.Cut1Click(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TMainForm.Copy1Click(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TMainForm.Paste1Click(Sender: TObject);
begin
  Editor.PasteFromClipboard;
  SetWordWrap( YoOptions.WordWrap ); //???
end;

procedure TMainForm.Selectall1Click(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TMainForm.Findyyfwd1Click(Sender: TObject);
Var
  i: integer;
begin
  for i := 0 to YYPos.Count-1 do
  begin
    if YYPos[i] > Editor.SelStart then
    begin
      Editor.SelStart := YYPos[i];
      Exit;
    end;
  end;
end;

procedure TMainForm.Findyyback1Click(Sender: TObject);
Var
  i: integer;
begin
  for i := YYPos.Count-1 downto 0 do
  begin
    if YYPos[i] < Editor.SelStart then
    begin
      Editor.SelStart := YYPos[i];
      Exit;
    end;
  end;
end;

procedure TMainForm.Save1Click(Sender: TObject);
begin
  if (Editor.LineCount=0) or (TextFileName='') then
    Exit;
  SaveFile;
end;

procedure TMainForm.Fileprop1Click(Sender: TObject);
begin
  CalculateFileProp;
  FilePropForm.ShowModal;
end;

procedure TMainForm.FindDialog1Close(Sender: TObject);
begin
  if FindNextWasPressed then
  begin
    SetMenuItem( 'Findagain1', True );
    if WasFindReg then
      FindAgain1.Caption := 'Найти РВ снова'
    else
      FindAgain1.Caption := 'Найти снова';
  end;
end;

procedure TMainForm.Options1Click(Sender: TObject);
Var
  WasEdited: boolean;
  a: integer;
begin
  NewYoOptions := YoOptions;
  with NewYoOptions do
  begin
//    EditorFont := Editor.Font;
    RegExprsEnabled := RegExprDic.W.Count>0;
    FontEnabled := Editor.PlainText;
  end;
  NewYoOptions.clEditorWindow := clEditorWindow;
  a := OptionsForm.ShowModal;
  if  a in [mrOK, mrYes] then
  begin
    if YoOptions.WordWrap <> NewYoOptions.WordWrap then
    begin
      WasEdited := Edited;
      SetWordWrap( NewYoOptions.WordWrap );
      Edited := WasEdited;
    end;
    YoOptions := NewYoOptions;
    with Editor.Font do
    begin
      Name := YoOptions.EditorFontName;
      Size := YoOptions.EditorFontSize;
      Charset := YoOptions.EditorFontCharset;
    end;
    Toolbar1.Visible := YoOptions.ShowToolBar;
    if a = mrYes then
      DefaultYoOptions := YoOptions; // будут сохраняться новые опции
  end;
end;

////////////////////////////////////////////
// Далее идут эзотерические процедуры
// кастомизации тулбара
////////////////////////////////////////////

procedure TMainForm.WMNotify(var Message: TWMNotify);
// обработка настройки тулбара
var
  pnmTB: PNMToolBar;
  ButtonCapt: string;
  Index: integer;
  i: integer;
  Button: TToolButtonX;
begin
  Inherited;
  case Message.NMHdr^.code of
    TBN_GETBUTTONINFO: // вызывается при заполнении левого окна диалога кастомизации
      begin
       pnmTB := PNMToolBar(Message.NMHdr); // структура для описания кнопки - будем её заполнять
       Index := pnmTB^.iItem; // индекс кнопки в ToolBarImageList
       if Index>=ToolBar1.ButtonCount+MenuItemsX.Count then //кончились кнопки
       begin
         Message.Result := 0;
         Exit;
       end;
       i := Index - ToolBar1.ButtonCount; // в MenuItemsX только кнопки, которых нет на тулбаре
       if i<0 then
       begin
         Message.Result := 1;
         Exit;
       end;
       Button := TToolButtonX(MenuItemsX.Objects[i]); // это кнопка для левого окна
       ButtonCapt := Button.Caption; // подпись кнопки
       with pnmTB^ do
       begin
         cchText := Length(ButtonCapt); // количество символов в подписи кнопки
         StrLCopy(pszText, PChar(ButtonCapt), Length(ButtonCapt)); // копирование подписи
       end;
       with pnmTB^.tbButton do // заполняем структуру для кнопки
       begin
         iBitmap := Button.ImageIndex;
         idCommand := Button.ImageIndex; //?
         fsState := TBSTATE_ENABLED;
         fsStyle := TBSTYLE_BUTTON;
         iString := 0;
         dwData := Integer(Button);
       end;
       Message.Result := 1;
     end;
     TBN_BEGINADJUST: // вызывается перед настройкой
     begin
       FillToolBarImageList;
       Message.Result := 1;
     end;
     TBN_ENDADJUST: // вызывается после настройки
     begin
       SetToolBarSeparators; // доработать тулбар
       Message.Result := 1;
     end;
  end;
end;

procedure TMainForm.SetToolBarSeparators;
// установить правильную ширину сепараторов
Var
  i: integer;
begin
  with ToolBar1 do
    for i := 0 to ButtonCount-1 do
      with Buttons[i] do
      begin
        if Caption='' then // признак вставленного сепаратора - пустая подпись
          Width := 8; // установить правильную ширину
        Parent := ToolBar1; //без этого почему-то не работает OnClick
      end;
end;

{ TMenuItemsX }

constructor TMenuItemsX.Create;
// список всех пунктов меню, которых нет на тулбаре
begin
  inherited Create;
  CaseSensitive := False;
  Duplicates := dupError;
  Sorted := False;
end;

{ TToolButtonX }

constructor TToolButtonX.Create(AOwner: TComponent);
// protected hack
begin
  inherited Create(AOwner);
end;

function TMainForm.FindMenuItem( ItemName: string ): TMenuItem;
Var
  i, j: integer;
begin
  for i := 0 to MainMenu1.Items.Count-1 do
  for j := 0 to MainMenu1.Items[i].Count-1 do
    if MainMenu1.Items[i].Items[j].Name=ItemName then
    begin
      Result := MainMenu1.Items[i].Items[j];
      Exit;
    end;
  Result := nil;
end;

function TMainForm.FindToolbarItem( ItemName: string ): TToolButtonX;
Var
  i: integer;
begin
  with ToolBar1 do
    for i := 0 to ButtonCount-1 do
    if Buttons[i].Name = ItemName then
    begin
      Result := TToolButtonX(Buttons[i]);
      Exit;
    end;
  Result := nil;
end;

procedure TMainForm.FillToolBarImageList;
// выполняется каждый раз при вызове окна настройки тулбара
Var
  i, j: integer;
  Button: TToolButtonX;
  Item: TMenuItem;
begin
  MenuItemsX.Clear;
  for i := 0 to MainMenu1.Items.Count-1 do
    for j := 0 to MainMenu1.Items[i].Count-1 do
    begin
      Item := MainMenu1.Items[i].Items[j];
      with Item do
      begin
        if Name = 'Openfile0' then // дошли до списка файлов
          System.Break;
        if Item.Tag=0 then  //кнопка не присвоена
          Continue;
        Button := FindToolbarItem( Item.Name ); // ищем кнопку на тулбере
        if Button=nil then // если её там нет - кнопка будет в левом окне
        begin
          Button := TToolButtonX( Item.Tag );
          ToolBarImageList.AddMasked( Item.Bitmap, clFuchsia );
          Button.FToolBar := nil; // иначе SetImageIndex (точнее, RefreshControl)
                                  // выдает ошибку, если кнопка была удалена с тулбара
          Button.ImageIndex := ToolBarImageList.Count-1;
          Button.FToolBar := Toolbar1; // возвратить, иначе теряются подписи в правом окне
          MenuItemsX.AddObject( Item.Name, TToolButtonX( Item.Tag ) ); // считать кнопку
            // из пункта меню и добавить ссылку на неё в список
        end;
      end;
    end;
end;

procedure TMainForm.CreateToolButtons;
// создаём один раз кнопки для тулбара, пока без битмапов
Var
  i, j: integer;
  Button: TToolButtonX;
  Item: TMenuItem;
begin
  for i := 0 to MainMenu1.Items.Count-1 do
    for j := 0 to MainMenu1.Items[i].Count-1 do
    begin
      Item := MainMenu1.Items[i].Items[j];
      with Item do
      begin
        if Name = 'Openfile0' then // дошли до списка файлов в меню File
          System.Break;
        if Bitmap.Width<>ToolBarImageList.Width then
        begin
          MainMenu1.Items[i].Items[j].Tag := 0;
          Continue;
        end;
        Button := TToolButtonX.Create( Toolbar1 );//если владелец Form1, то получаются дубликаты имён
        with Button do
        begin
          ImageIndex := 0;
          Style := tbsButton;
          Button.Name := Item.Name; //???
          Caption := Item.Caption;
          Hint := Item.Caption;
          OnClick := Item.OnClick;
          Enabled := Item.Enabled;
          Parent := nil;
        end;
        MainMenu1.Items[i].Items[j].Tag := Integer(Button); // в тагах пунктов меню теперь ссылки на кнопки
      end;
    end;
end;

procedure TMainForm.AddButtonToToolBar( ItemName: string );
// помещаем готовую кнопку (или созданный сепаратор) на тулбар
// и добавляем нужный битмап к имиджлисту
Var
  Item: TMenuItem;
begin
  if ItemName<>'-' then // если это кнопка
  begin
    Item := FindMenuItem( ItemName );
    if Item<>nil then
    begin
      ToolBarImageList.AddMasked( Item.Bitmap, clFuchsia );
      with TToolButtonX( Item.Tag ) do // берём ссылку из тага пункта меню
      begin
        ImageIndex := ToolBarImageList.Count-1;
        SetToolBar( ToolBar1 );
      end;
    end
  end
  else // если это сепаратор
  begin
    with TToolButtonX.Create( MainForm.ToolBar1 ) do
    begin
      ToolBarImageList.Add( nil, nil );
      Width := 8;
      Style := tbsSeparator;
      SetToolBar( ToolBar1 );
    end;
  end;
end;

procedure TMainForm.RemoveMarked1Click(Sender: TObject);
begin
  RemoveMarkedLetters;
end;

end.


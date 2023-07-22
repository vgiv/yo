unit GsvUnicodeRichEdit;

{$DEFINE MySearchTypes}

interface

uses
  Windows, Messages, Classes, Controls, StdCtrls, Graphics, RichEdit, Forms;

type
  TGsvCustomUnicodeRichEdit = class;
{$IFNDEF MySearchTypes}
  TGsvUnicodeSearchType  = (stWholeWord, stMatchCase, stSearchUp);
{$ELSE}
  TGsvUnicodeSearchType  = (stWideWholeWord, stWideMatchCase, stWideSearchUp);
{$ENDIF}
  TGsvUnicodeSearchTypes = set of TGsvUnicodeSearchType;
  TGsvUnicodeEditWordBreakProc = function(lpch: PWideChar;
    ichCurrent, cch, code: Integer): Integer; stdcall;
  PGsvUnicodeEditWordBreakProc = ^TGsvUnicodeEditWordBreakProc;
  TGsvUnicodeRichEditModuleNameEvent = procedure(Sender: TObject;
    var aModuleName: String) of object;
  TGsvUnicodeRichEditProtectChange = procedure(Sender: TObject;
    StartPos, EndPos: Integer; var AllowChange: Boolean) of object;
  TGsvUnicodeRichEditResizeEvent = procedure(Sender: TObject;
    Rect: TRect) of object;
  TGsvUnicodeRichEditLinkEvent = procedure(Sender: TObject;
    aMessage: Integer; const aRange: TCharRange) of object;
  TGsvUnicodeRichEditLangChange = procedure(Sender: TObject;
    Charset, PrimaryLangId, SubLangId: Integer) of object;

  TGsvUnicodeCharFormatMask = (cfmBackColor, cfmCharset, cfmColor, cfmFace,
    cfmLCID, cfmOffset, cfmSize, cfmUnderlineType, cfmWeight);
  TGsvUnicodeCharFormatMasks = set of TGsvUnicodeCharFormatMask;
  TGsvUnicodeCharFormatEffect = (cfeBold, cfeDisabled, cfeEmboss, cfeHidden,
    cfeImprint, cfeItalic, cfeOutline, cfeProtected, cfeShadow, cfeSmallCaps,
    cfeStrikeout, cfeSubscript, cfeSuperscript, cfeUnderline);
  TGsvUnicodeCharFormatEffects = set of TGsvUnicodeCharFormatEffect;
  TGsvUnicodeCharFormatUnderlineType = (cfuNone, cfuSingle, cfuDouble,
    cfuDotted, cfuWord);

  TGsvUnicodeParaFormatMask = (pfmAlignment, pfmOffset, pfmRightIndent,
    pfmStartIndent, pfmTabStops);
  TGsvUnicodeParaFormatMasks = set of TGsvUnicodeParaFormatMask;

  TGsvUnicodeCharFormat = class
  public
    constructor Create(aEdit: TGsvCustomUnicodeRichEdit;
                aMasks: TGsvUnicodeCharFormatMasks;
                aEffects: TGsvUnicodeCharFormatEffects);

  private
    FEdit:   TGsvCustomUnicodeRichEdit;
    FFormat: TCharFormat2W;

    function  GetEffect(aMask: DWORD): Boolean;
    procedure SetEffect(const Value: Boolean; aMask: DWORD);

    function  GetBold: Boolean;
    procedure SetBold(const Value: Boolean);
    function  GetDisabled: Boolean;
    procedure SetDisabled(const Value: Boolean);
    function  GetEmboss: Boolean;
    procedure SetEmboss(const Value: Boolean);
    function  GetHidden: Boolean;
    procedure SetHidden(const Value: Boolean);
    function  GetImprint: Boolean;
    procedure SetImprint(const Value: Boolean);
    function  GetItalic: Boolean;
    procedure SetItalic(const Value: Boolean);
    function  GetOutline: Boolean;
    procedure SetOutline(const Value: Boolean);
    function  GetProtected: Boolean;
    procedure SetProtected(const Value: Boolean);
    function  GetShadow: Boolean;
    procedure SetShadow(const Value: Boolean);
    function  GetSmallCaps: Boolean;
    procedure SetSmallCaps(const Value: Boolean);
    function  GetStrikeout: Boolean;
    procedure SetStrikeout(const Value: Boolean);
    function  GetSubscript: Boolean;
    procedure SetSubscript(const Value: Boolean);
    function  GetSuperscript: Boolean;
    procedure SetSuperscript(const Value: Boolean);
    function  GetUnderline: Boolean;
    procedure SetUnderline(const Value: Boolean);

    function  GetFace: string;
    procedure SetFace(const Value: string);
    function  GetWideFace: WideString;
    procedure SetWideFace(const Value: WideString);
    function  GetSize: Integer;
    procedure SetSize(const Value: Integer);
    function  GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function  GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function  GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function  GetCharset: TFontCharset;
    procedure SetCharset(const Value: TFontCharset);
    function  GetLCID: LCID;
    procedure SetLCID(const Value: LCID);
    function  GetPitch: TFontPitch;
    procedure SetPitch(const Value: TFontPitch);
    function  GetOffset: Integer;
    procedure SetOffset(const Value: Integer);
    function  GetWeight: Integer;
    procedure SetWeight(const Value: Integer);
    function  GetUnderlineType: TGsvUnicodeCharFormatUnderlineType;
    procedure SetUnderlineType(const Value: TGsvUnicodeCharFormatUnderlineType);

  public
    procedure GetDefault;
    procedure SetDefault;
    procedure GetSelection;
    procedure SetSelection;

    property Edit: TGsvCustomUnicodeRichEdit read FEdit;

    property Bold: Boolean read GetBold write SetBold;
    property Disabled: Boolean read GetDisabled write SetDisabled;
    property Emboss: Boolean read GetEmboss write SetEmboss;
    property Hidden: Boolean read GetHidden write SetHidden;
    property Imprint: Boolean read GetImprint write SetImprint;
    property Italic: Boolean read GetItalic write SetItalic;
    property Outline: Boolean read GetOutline write SetOutline;
    property CProtected: Boolean read GetProtected write SetProtected;
    property Shadow: Boolean read GetShadow write SetShadow;
    property SmallCaps: Boolean read GetSmallCaps write SetSmallCaps;
    property Strikeout: Boolean read GetStrikeout write SetStrikeout;
    property Subscript: Boolean read GetSubscript write SetSubscript;
    property Superscript: Boolean read GetSuperscript write SetSuperscript;
    property Underline: Boolean read GetUnderline write SetUnderline;

    property Face: string read GetFace write SetFace;
    property WideFace: WideString read GetWideFace write SetWideFace;
    property Size: Integer read GetSize write SetSize;
    property Height: Integer read GetHeight write SetHeight;
    property Color: TColor read GetColor write SetColor;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property Charset: TFontCharset read GetCharset write SetCharset;
    property CLCID: LCID read GetLCID write SetLCID;
    property Pitch: TFontPitch read GetPitch write SetPitch;
    property Offset: Integer read GetOffset write SetOffset;
    property Weight: Integer read GetWeight write SetWeight;
    property UnderlineType: TGsvUnicodeCharFormatUnderlineType read
             GetUnderlineType write SetUnderlineType;
  end;

  TGsvUnicodeParaFormat = class
  public
    constructor Create(aEdit: TGsvCustomUnicodeRichEdit;
                aMasks: TGsvUnicodeParaFormatMasks);

  private
    FEdit:   TGsvCustomUnicodeRichEdit;
    FFormat: TParaFormat2;

    function  GetAlignment: TAlignment;
    procedure SetAlignment(const Value: TAlignment);
    function  GetStartIndent: Integer;
    procedure SetStartIndent(const Value: Integer);
    function  GetRightIndent: Integer;
    procedure SetRightIndent(const Value: Integer);
    function  GetOffset: Integer;
    procedure SetOffset(const Value: Integer);

  public
    procedure SetTabStops(aTabStops: array of Integer);
    function  PixelsToTwips(aPixels: Integer): Integer;
    function  TwipsToPixels(aTwips: Integer): Integer;
    procedure SetFormat;

    property Edit: TGsvCustomUnicodeRichEdit read FEdit;
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    property StartIndent: Integer read GetStartIndent write SetStartIndent;
    property RightIndent: Integer read GetRightIndent write SetRightIndent;
    property Offset: Integer read GetOffset write SetOffset;
  end;

  TGsvUnicodeMemoryStream = class(TMemoryStream)
  public
    RecreateFlags:   Cardinal;
    NeedRecreateWnd: Boolean;
    RecreateRange:   TCharRange;

    function  Write(const Buffer; Count: Longint): Longint; override;
    procedure Rewrite;
    procedure WriteString(const aString: WideString);
    procedure WriteStringBuffer(aString: PWideChar; aLength: Integer);
    function  ReadString: WideString;
  end;

  TGsvRtfMemoryStream = class(TMemoryStream)
  public
    RecreateFlags:   Cardinal;
    NeedRecreateWnd: Boolean;
    RecreateRange:   TCharRange;

    function  Write(const Buffer; Count: Longint): Longint; override;
    procedure Rewrite;
    procedure WriteString(const aString: string);
    procedure WriteStringBuffer(aString: PChar; aLength: Integer);
    function  ReadString: string;
  end;

  TGsvCustomUnicodeRichEdit = class(TWinControl)
  public
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;

  private
    FAlignment:          TAlignment;
    FAutoSelect:         Boolean;
    FAutoSize:           Boolean;
    FAutoURLDetect:      Boolean;
    FBorderStyle:        TBorderStyle;
    FHideScrollBars:     Boolean;
    FHideSelection:      Boolean;
    FMaxLength:          Integer;
    FMaxUndo:            Integer;
    FMultiLine:          Boolean;
    FReadOnly:           Boolean;
    FPlainText:          Boolean;
    FScrollBars:         TScrollStyle;
    FSelectionBar:       Boolean;
    FWantReturns:        Boolean;
    FWantTabs:           Boolean;
    FWordWrap:           Boolean;

    FOnChange:           TNotifyEvent;
    FOnHScroll:          TNotifyEvent;
    FOnLink:             TGsvUnicodeRichEditLinkEvent;
    FOnModuleName:       TGsvUnicodeRichEditModuleNameEvent;
    FOnProtectChange:    TGsvUnicodeRichEditProtectChange;
    FOnResizeRequest:    TGsvUnicodeRichEditResizeEvent;
    FOnSelChange:        TNotifyEvent;
    FOnVScroll:          TNotifyEvent;
    FOnLangChange:       TGsvUnicodeRichEditLangChange;

    FScreenLogPixels:    Integer;
    FOldParaAlignment:   TAlignment;
    FCreating:           Boolean;
    FModified:           Boolean;
    FLastMouseDownShift: TShiftState;
    FLastMouseDownPoint: TPoint;
    FWordBreakProc:      PGsvUnicodeEditWordBreakProc;
    FStream:             TGsvUnicodeMemoryStream;
    FRtfStream:          TGsvRtfMemoryStream;
    FLockUpdate:         Integer;

    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoURLDetect(Value: Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetHideScrollBars(Value: Boolean);
    procedure SetHideSelection(Value: Boolean);
    procedure SetMaxLength(Value: Integer);
    procedure SetMaxLengthEx(Value: Integer);
    procedure SetMaxUndo(Value: Integer);
    procedure SetMultiLine(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetSelectionBar(Value: Boolean);
    procedure SetWordBreakProc(Value: PGsvUnicodeEditWordBreakProc);
    procedure SetWordWrap(Value: Boolean);

    function  GetModified: Boolean;
    procedure SetModified(Value: Boolean);
    function  GetSelLength: Integer;
    procedure SetSelLength(Value: Integer);
    function  GetSelStart: Integer;
    procedure SetSelStart(Value: Integer);
    function  GetSelRange: TCharRange;
    procedure SetSelRange(const Value: TCharRange);
    function  GetCaretPos: TPoint;
    procedure SetCaretPos(const Value: TPoint);
    function  GetSelWideText: WideString;
    procedure SetSelWideText(const Value: WideString);
    function  GetSelWideChar: WideChar;
    procedure SetSelWideChar(Value: WideChar);
    function  GetWideText: WideString;
    procedure SetWideText(const Value: WideString);
    function  GetWideChars(aPosition: Integer): WideChar;
    function  GetWideLines(aIndex: Integer): WideString;

    procedure CMRecreateWnd(var Message: TMessage); message CM_RECREATEWND;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMLangChange(var Msg: TMessage); message WM_INPUTLANGCHANGE;

    procedure AdjustHeight;
    procedure SetSelWideBuffer(const aBuffer: PWideChar; aLength: Integer);
    function  ProtectChange(StartPos, EndPos: Integer): Boolean;
    procedure RequestSize(const Rect: TRect);
    procedure SelectionChange;
    procedure LinkDetected(aMessage: Integer; const aRange: TCharRange);
    procedure DoHScroll;
    procedure DoVScroll;

  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;
    procedure Change; dynamic;
    procedure SetAutoSize(Value: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
              X, Y: Integer); override;

    property  Alignment: TAlignment read FAlignment write SetAlignment
              default taLeftJustify;
    property  AutoSelect: Boolean read FAutoSelect write FAutoSelect
              default False;
    property  AutoSize: Boolean read FAutoSize write SetAutoSize
              default False;
    property  AutoURLDetect: Boolean read FAutoURLDetect write SetAutoURLDetect
              default False;
    property  BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
              default bsSingle;
    property  HideScrollBars: Boolean read FHideScrollBars
              write SetHideScrollBars default True;
    property  HideSelection: Boolean read FHideSelection write SetHideSelection
              default True;
    property  MaxLength: Integer read FMaxLength write SetMaxLength
              default 0;
    property  MaxUndo: Integer read FMaxUndo write SetMaxUndo
              default 100;
    property  MultiLine: Boolean read FMultiLine write SetMultiLine
              default True;
    property  ReadOnly: Boolean read FReadOnly write SetReadOnly
              default False;
    property  PlainText: Boolean read FPLainText write FPlainText
              default False;
    property  ScrollBars: TScrollStyle read FScrollBars write SetScrollBars
              default ssNone;
    property  SelectionBar: Boolean read FSelectionBar write SetSelectionBar
              default False;
    property  WantReturns: Boolean read FWantReturns write FWantReturns
              default True;
    property  WantTabs: Boolean read FWantTabs write FWantTabs
              default False;
    property  WordWrap: Boolean read FWordWrap write SetWordWrap
              default True;

    property  OnChange: TNotifyEvent read FOnChange write FOnChange;
    property  OnHScroll: TNotifyEvent read FOnHScroll write FOnHScroll;
    property  OnLink: TGsvUnicodeRichEditLinkEvent read FOnLink write FOnLink;
    property  OnModuleName: TGsvUnicodeRichEditModuleNameEvent
              read FOnModuleName write FOnModuleName;
    property  OnProtectChange: TGsvUnicodeRichEditProtectChange
              read FOnProtectChange write FOnProtectChange;
    property  OnResizeRequest: TGsvUnicodeRichEditResizeEvent
              read FOnResizeRequest write FOnResizeRequest;
    property  OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;
    property  OnVScroll: TNotifyEvent read FOnVScroll write FOnVScroll;
    property  OnLangChange: TGsvUnicodeRichEditLangChange read FOnLangChange
              write FOnLangChange;

  public
    function  SendMsg(Msg: Cardinal; WParam, LParam: Integer): Integer;
    function  GetControlsAlignment: TAlignment; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure SetSelPositions(aStartPos, aEndPos: Integer);
    procedure EnsureSelVisible;
    function  PositionByPoint(X, Y: Integer): Integer;
    function  PointByPosition(aPosition: Integer): TPoint;
    function  PositionByLine(aLine: Integer): Integer;
    function  LineByPosition(aPosition: Integer): Integer;
    function  WordRangeByPosition(aPosition: Integer): TCharRange;
    function  WideWordByPosition(var aPosition: Integer): WideString;
    function  GetWideTextRange(const aRange: TCharRange): WideString;
    function  FindWideText(const SearchStr: WideString;
              StartPos, EndPos: Integer;
              Options: TGsvUnicodeSearchTypes): Integer;
    procedure TransferStream(aStream: TStream; aMessage, aFlags: Integer);
    procedure SaveToFile(const aFileName: String; aFlags: Integer);
    procedure LoadFromFile(const aFileName: String; aFlags: Integer);
    procedure SetSelWidePString(const aString: PWideChar; aLength: Integer);
    procedure SetSelRtfString(const aString: string);
    procedure SetSelRtfPString(const aString: PChar; aLength: Integer);
    procedure SetRtfPString(const aString: PChar; aLength: Integer);

    function  TextLength: Integer;
    function  LineCount: Integer;
    function  FirstVisibleLine: Integer;
    function  CanUndo: Boolean;
    function  HasSelection: Boolean;
    function  HasText: Boolean;

    procedure Clear;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure ClearSelection;
    procedure SelectAll;
    procedure Undo;
    procedure ClearUndo;

    function  CreateCharFormat(aMasks: TGsvUnicodeCharFormatMasks;
              aEffects: TGsvUnicodeCharFormatEffects): TGsvUnicodeCharFormat;
    function  CreateParaFormat(aMasks: TGsvUnicodeParaFormatMasks):
              TGsvUnicodeParaFormat;

    property  ScreenLogPixels: Integer read FScreenLogPixels;
    property  Modified: Boolean read GetModified write SetModified;
    property  SelLength: Integer read GetSelLength write SetSelLength;
    property  SelStart: Integer read GetSelStart write SetSelStart;
    property  SelRange: TCharRange read GetSelRange write SetSelRange;
    property  SelWideText: WideString read GetSelWideText write SetSelWideText;
    property  SelWideChar: WideChar read GetSelWideChar write SetSelWideChar;
    property  WideText: WideString read GetWideText write SetWideText;
    property  CaretPos: TPoint read GetCaretPos write SetCaretPos;
    property  LastMouseDownShift: TShiftState read FLastMouseDownShift;
    property  LastMouseDownPoint: TPoint read FLastMouseDownPoint;
    property  WordBreakProc: PGsvUnicodeEditWordBreakProc read
              FWordBreakProc write SetWordBreakProc;
    property  WideChars[aPosition: Integer]: WideChar read GetWideChars;
    property  WideLines[aIndex: Integer]: WideString read GetWideLines;
  end;

  TGsvUnicodeRichEdit = class(TGsvCustomUnicodeRichEdit)
  published
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property Color;
    property Constraints;
    property Ctl3D default True;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D default True;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;

    property Alignment;
    property AutoSelect;
    property AutoSize;
    property AutoURLDetect;
    property BorderStyle;
    property HideScrollBars;
    property HideSelection;
    property MaxLength;
    property MaxUndo;
    property MultiLine;
    property ReadOnly;
    property PlainText;
    property ScrollBars;
    property SelectionBar;
    property WantReturns;
    property WantTabs;
    property WordWrap;

    property OnChange;
    property OnHScroll;
    property OnLink;
    property OnModuleName;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSelChange;
    property OnVScroll;
    property OnLangChange;
  end;

function  GsvUnicodeWordBreakProcBySpaceOnly(aText: PWideChar;
          aCurrent, aLength, aCode: Integer): Integer; stdcall;
procedure Register;

implementation

uses
  CommDlg, SysUtils;

const
  RICHEDIT_MODULENAME = 'riched20.dll';
  RICHEDIT_CLASS      = 'RichEdit20W';
  CP_UNICODE          = 1200;
  EM_FINDTEXTW        = (WM_USER + 123);

var
  FRichEditModule: THandle;

type
  PStreamCookie = ^TStreamCookie;
  TStreamCookie = record
    Stream:  TStream;
    Message: Integer;
  end;

procedure Register;
begin
  RegisterComponents('Gsv', [TGsvUnicodeRichEdit]);
end;

function StreamCallback(dwCookie: LongInt; pbBuff: PByte;
  cb: LongInt; var pcb: LongInt): LongInt; stdcall;
var
  pCookie: PStreamCookie;
begin
  pCookie := PStreamCookie(dwCookie);
  try
    if pCookie^.Message = EM_STREAMOUT then
      pcb := pCookie^.Stream.Write(pbBuff^, cb)
    else
      pcb := pCookie^.Stream.Read(pbBuff^, cb);
    Result := 0;
  except
    pcb    := 0;
    Result := 1;
  end;
end;

function GsvUnicodeWordBreakProcBySpaceOnly(aText: PWideChar;
  aCurrent, aLength, aCode: Integer): Integer; stdcall;
var
  p, pL: PWideChar;

  function IsSpace: Boolean;
  begin
    Result := Ord(p^) <= Ord(' ');
  end;

  function GetClassify: Integer;
  begin
    if IsSpace then
      Result := WBF_BREAKAFTER or WBF_BREAKLINE or WBF_ISWHITE
    else
      Result := 0;
  end;

  procedure SkipSpaceLeft;
  begin
    while (p >= pL) and IsSpace do
      Dec(p);
  end;

  procedure SkipNonSpaceLeft;
  begin
    while (p >= pL) and (not IsSpace) do
      Dec(p);
  end;

  procedure SkipSpaceRight;
  begin
    while (p < pL) and IsSpace do
      Inc(p);
  end;

  procedure SkipNonSpaceRight;
  begin
    while (p < pL) and (not IsSpace) do
      Inc(p);
  end;

  function GetLeft: Integer;
  begin
    if aCurrent > 0 then begin
      pL := aText;
      SkipSpaceLeft;
      SkipNonSpaceLeft;
      Inc(p);
      Result := p - aText;
    end
    else
      Result := aCurrent;
  end;

  function GetLeftBreak: Integer;
  begin
    if aCurrent > 0 then begin
      pL := aText;
      SkipNonSpaceLeft;
      SkipSpaceLeft;
      Inc(p);
      Result := p - aText;
    end
    else
      Result := aCurrent;
  end;

  function GetLeftMove: Integer;
  begin
    if aCurrent > 0 then begin
      Dec(p);
      Result := GetLeft;
    end
    else
      Result := aCurrent;
  end;

  function GetRight: Integer;
  begin
    if aCurrent < aLength then begin
      pL := aText + aLength;
      SkipNonSpaceRight;
      SkipSpaceRight;
      Result := p - aText;
    end
    else
      Result := aCurrent;
  end;

  function GetRightBreak: Integer;
  begin
    if aCurrent < aLength then begin
      pL := aText + aLength;
      SkipSpaceRight;
      SkipNonSpaceRight;
      Result := p - aText;
    end
    else
      Result := aCurrent;
  end;

  function GetRightMove: Integer;
  begin
    Result := GetRightBreak;
  end;

begin
  p := aText + aCurrent;
  case aCode of
    WB_CLASSIFY:      Result := GetClassify;
    WB_ISDELIMITER:   Result := Ord(IsSpace);
    WB_LEFT:          Result := GetLeft;
    WB_LEFTBREAK:     Result := GetLeftBreak;
    WB_MOVEWORDLEFT:  Result := GetLeftMove;
    WB_MOVEWORDRIGHT: Result := GetRightMove;
    WB_RIGHT:         Result := GetRight;
    WB_RIGHTBREAK:    Result := GetRightBreak;
    else              Result := 0;
  end;
end;

{ TGsvUnicodeCharFormat }

constructor TGsvUnicodeCharFormat.Create(aEdit: TGsvCustomUnicodeRichEdit;
  aMasks: TGsvUnicodeCharFormatMasks; aEffects: TGsvUnicodeCharFormatEffects);
const
  CFM: array[TGsvUnicodeCharFormatMask] of DWORD = (
    CFM_BACKCOLOR, CFM_CHARSET, CFM_COLOR, CFM_FACE, CFM_LCID, CFM_OFFSET,
    CFM_SIZE, CFM_UNDERLINETYPE, CFM_WEIGHT);
  CFE: array[TGsvUnicodeCharFormatEffect] of DWORD = (
    CFM_BOLD, CFM_DISABLED, CFM_EMBOSS, CFM_HIDDEN, CFM_IMPRINT, CFM_ITALIC,
    CFM_OUTLINE, CFM_PROTECTED, CFM_SHADOW, CFM_SMALLCAPS, CFM_STRIKEOUT,
    CFM_SUBSCRIPT, CFM_SUPERSCRIPT, CFM_UNDERLINE);
var
  icfm: TGsvUnicodeCharFormatMask;
  icfe: TGsvUnicodeCharFormatEffect;
begin
  FEdit := aEdit;
  ZeroMemory(@FFormat, SizeOf(FFormat));
  FFormat.cbSize := SizeOf(FFormat);
  for icfm := Low(TGsvUnicodeCharFormatMask) to
              High(TGsvUnicodeCharFormatMask) do
  begin
    if icfm in aMasks then
      FFormat.dwMask := FFormat.dwMask or CFM[icfm];
  end;
  for icfe := Low(TGsvUnicodeCharFormatEffect) to
              High(TGsvUnicodeCharFormatEffect) do
  begin
    if icfe in aEffects then
      FFormat.dwMask := FFormat.dwMask or CFE[icfe];
  end;
end;

function TGsvUnicodeCharFormat.GetEffect(aMask: DWORD): Boolean;
begin
  Result := (FFormat.dwEffects and aMask) <> 0;
end;

procedure TGsvUnicodeCharFormat.SetEffect(const Value: Boolean; aMask: DWORD);
begin
  if Value then
    FFormat.dwEffects := FFormat.dwEffects or aMask
  else
    FFormat.dwEffects := FFormat.dwEffects and (not aMask);
end;

function TGsvUnicodeCharFormat.GetBold: Boolean;
begin
  Result := GetEffect(CFE_BOLD);
end;

procedure TGsvUnicodeCharFormat.SetBold(const Value: Boolean);
begin
  SetEffect(Value, CFE_BOLD);
end;

function TGsvUnicodeCharFormat.GetDisabled: Boolean;
begin
  Result := GetEffect(CFE_DISABLED);
end;

procedure TGsvUnicodeCharFormat.SetDisabled(const Value: Boolean);
begin
  SetEffect(Value, CFE_DISABLED);
end;

function TGsvUnicodeCharFormat.GetEmboss: Boolean;
begin
  Result := GetEffect(CFE_EMBOSS);
end;

procedure TGsvUnicodeCharFormat.SetEmboss(const Value: Boolean);
begin
  SetEffect(Value, CFE_EMBOSS);
end;

function TGsvUnicodeCharFormat.GetHidden: Boolean;
begin
  Result := GetEffect(CFE_HIDDEN);
end;

procedure TGsvUnicodeCharFormat.SetHidden(const Value: Boolean);
begin
  SetEffect(Value, CFE_HIDDEN);
end;

function TGsvUnicodeCharFormat.GetImprint: Boolean;
begin
  Result := GetEffect(CFE_IMPRINT);
end;

procedure TGsvUnicodeCharFormat.SetImprint(const Value: Boolean);
begin
  SetEffect(Value, CFE_IMPRINT);
end;

function TGsvUnicodeCharFormat.GetItalic: Boolean;
begin
  Result := GetEffect(CFE_ITALIC);
end;

procedure TGsvUnicodeCharFormat.SetItalic(const Value: Boolean);
begin
  SetEffect(Value, CFE_ITALIC);
end;

function TGsvUnicodeCharFormat.GetOutline: Boolean;
begin
  Result := GetEffect(CFE_OUTLINE);
end;

procedure TGsvUnicodeCharFormat.SetOutline(const Value: Boolean);
begin
  SetEffect(Value, CFE_OUTLINE);
end;

function TGsvUnicodeCharFormat.GetProtected: Boolean;
begin
  Result := GetEffect(CFE_PROTECTED);
end;

procedure TGsvUnicodeCharFormat.SetProtected(const Value: Boolean);
begin
  SetEffect(Value, CFE_PROTECTED);
end;

function TGsvUnicodeCharFormat.GetShadow: Boolean;
begin
  Result := GetEffect(CFE_SHADOW);
end;

procedure TGsvUnicodeCharFormat.SetShadow(const Value: Boolean);
begin
  SetEffect(Value, CFE_SHADOW);
end;

function TGsvUnicodeCharFormat.GetSmallCaps: Boolean;
begin
  Result := GetEffect(CFE_SMALLCAPS);
end;

procedure TGsvUnicodeCharFormat.SetSmallCaps(const Value: Boolean);
begin
  SetEffect(Value, CFE_SMALLCAPS);
end;

function TGsvUnicodeCharFormat.GetStrikeout: Boolean;
begin
  Result := GetEffect(CFE_STRIKEOUT);
end;

procedure TGsvUnicodeCharFormat.SetStrikeout(const Value: Boolean);
begin
  SetEffect(Value, CFE_STRIKEOUT);
end;

function TGsvUnicodeCharFormat.GetSubscript: Boolean;
begin
  Result := GetEffect(CFE_SUBSCRIPT);
end;

procedure TGsvUnicodeCharFormat.SetSubscript(const Value: Boolean);
begin
  SetEffect(Value, CFE_SUBSCRIPT);
end;

function TGsvUnicodeCharFormat.GetSuperscript: Boolean;
begin
  Result := GetEffect(CFE_SUPERSCRIPT);
end;

procedure TGsvUnicodeCharFormat.SetSuperscript(const Value: Boolean);
begin
  SetEffect(Value, CFE_SUPERSCRIPT);
end;

function TGsvUnicodeCharFormat.GetUnderline: Boolean;
begin
  Result := GetEffect(CFE_UNDERLINE);
end;

procedure TGsvUnicodeCharFormat.SetUnderline(const Value: Boolean);
begin
  SetEffect(Value, CFE_UNDERLINE);
end;

function TGsvUnicodeCharFormat.GetFace: string;
var
  len: Integer;
begin
  SetLength(Result, LF_FACESIZE);
  len := WideCharToMultiByte(CP_ACP, 0, FFormat.szFaceName, -1, PChar(Result),
    LF_FACESIZE, nil, nil);
  if len = 0 then
    Result := ''
  else
    SetLength(Result, len - 1);
end;

procedure TGsvUnicodeCharFormat.SetFace(const Value: string);
begin
  MultiByteToWideChar(CP_ACP, 0, PChar(Value), Length(Value) + 1,
    FFormat.szFaceName, LF_FACESIZE);
end;

function TGsvUnicodeCharFormat.GetWideFace: WideString;
begin
  Result := PWideChar(@FFormat.szFaceName[0]);
end;

procedure TGsvUnicodeCharFormat.SetWideFace(const Value: WideString);
var
  len: Integer;
begin
  len := Length(Value);
  if len > (LF_FACESIZE - 1) then
    len := LF_FACESIZE - 1;
  CopyMemory(@FFormat.szFaceName[0], PWideChar(Value),
    (len + 1) * SizeOf(WideChar));
end;

function TGsvUnicodeCharFormat.GetSize: Integer;
begin
  Result := FFormat.yHeight div 20;
end;

procedure TGsvUnicodeCharFormat.SetSize(const Value: Integer);
begin
  FFormat.yHeight := Value * 20;
end;

function TGsvUnicodeCharFormat.GetHeight: Integer;
begin
  Result := MulDiv(Size, FEdit.ScreenLogPixels, 72);
end;

procedure TGsvUnicodeCharFormat.SetHeight(const Value: Integer);
begin
  Size := MulDiv(Value, 72, FEdit.ScreenLogPixels);
end;

function TGsvUnicodeCharFormat.GetColor: TColor;
begin
  Result := FFormat.crTextColor;
end;

procedure TGsvUnicodeCharFormat.SetColor(const Value: TColor);
begin
  FFormat.crTextColor := ColorToRGB(Value);
end;

function TGsvUnicodeCharFormat.GetBackColor: TColor;
begin
  Result := FFormat.crBackColor;
end;

procedure TGsvUnicodeCharFormat.SetBackColor(const Value: TColor);
begin
  FFormat.crBackColor := ColorToRGB(Value);
end;

function TGsvUnicodeCharFormat.GetCharset: TFontCharset;
begin
  Result := FFormat.bCharset;
end;

procedure TGsvUnicodeCharFormat.SetCharset(const Value: TFontCharset);
begin
  FFormat.bCharSet := Value;
end;

function TGsvUnicodeCharFormat.GetLCID: LCID;
begin
  Result := FFormat.lid;
end;

procedure TGsvUnicodeCharFormat.SetLCID(const Value: LCID);
begin
  FFormat.lid := Value;
end;

function TGsvUnicodeCharFormat.GetPitch: TFontPitch;
begin
  case (FFormat.bPitchAndFamily and $03) of
    VARIABLE_PITCH: Result := fpVariable;
    FIXED_PITCH:    Result := fpFixed;
    else            Result := fpDefault;
  end;
end;

procedure TGsvUnicodeCharFormat.SetPitch(const Value: TFontPitch);
begin
  case Value of
    fpVariable: FFormat.bPitchAndFamily := VARIABLE_PITCH;
    fpFixed:    FFormat.bPitchAndFamily := FIXED_PITCH;
    else        FFormat.bPitchAndFamily := DEFAULT_PITCH;
  end;
end;

function TGsvUnicodeCharFormat.GetOffset: Integer;
begin
  Result := MulDiv(FFormat.yOffset div 20, FEdit.ScreenLogPixels, 72);
end;

procedure TGsvUnicodeCharFormat.SetOffset(const Value: Integer);
begin
  FFormat.yOffset := MulDiv(Value * 20, 72, FEdit.ScreenLogPixels);
end;

function TGsvUnicodeCharFormat.GetWeight: Integer;
begin
  Result := FFormat.wWeight;
end;

procedure TGsvUnicodeCharFormat.SetWeight(const Value: Integer);
begin
  FFormat.wWeight := Value;
end;

function TGsvUnicodeCharFormat.GetUnderlineType:
  TGsvUnicodeCharFormatUnderlineType;
begin
  case FFormat.bUnderlineType of
    CFU_UNDERLINE:       Result := cfuSingle;
    CFU_UNDERLINEDOUBLE: Result := cfuDouble;
    CFU_UNDERLINEDOTTED: Result := cfuDotted;
    CFU_UNDERLINEWORD:   Result := cfuWord;
    else                 Result := cfuNone;
  end;
end;

procedure TGsvUnicodeCharFormat.SetUnderlineType(
  const Value: TGsvUnicodeCharFormatUnderlineType);
begin
  case Value of
    cfuNone:   FFormat.bUnderlineType := CFU_UNDERLINENONE;
    cfuSingle: FFormat.bUnderlineType := CFU_UNDERLINE;
    cfuDouble: FFormat.bUnderlineType := CFU_UNDERLINEDOUBLE;
    cfuDotted: FFormat.bUnderlineType := CFU_UNDERLINEDOTTED;
    cfuWord:   FFormat.bUnderlineType := CFU_UNDERLINEWORD;
  end;
end;

procedure TGsvUnicodeCharFormat.GetDefault;
begin
  FEdit.SendMsg(EM_GETCHARFORMAT, SCF_DEFAULT, LPARAM(@FFormat));
end;

procedure TGsvUnicodeCharFormat.SetDefault;
begin
  FEdit.SendMsg(EM_SETCHARFORMAT, SCF_DEFAULT, LPARAM(@FFormat));
end;

procedure TGsvUnicodeCharFormat.GetSelection;
begin
  FEdit.SendMsg(EM_GETCHARFORMAT, SCF_SELECTION, LPARAM(@FFormat));
end;

procedure TGsvUnicodeCharFormat.SetSelection;
begin
  FEdit.SendMsg(EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@FFormat));
end;

{ TGsvUnicodeMemoryStream }

function TGsvUnicodeMemoryStream.Write(const Buffer; Count: Integer): Longint;
begin
  // В отличие от TMemoryStream класс TGsvUnicodeMemoryStream не
  // перераспределяет память при каждой новой сессии записи. Вместо
  // этого распределяемая память сохраняется той, которая была при последней
  // операции записи. Таким образом, мощность потока только увеличивается
  // до тех пор, пока не будет сделана явная операция Clear
  Result := inherited Write(Buffer, Count);
  SetPointer(Memory, Position);
end;

// Подготовка к новой сессии записи без перераспределения имеющейся памяти
procedure TGsvUnicodeMemoryStream.Rewrite;
begin
  Position := 0;
  SetPointer(Memory, 0);
end;

// Обнуляет размер и позицию потока, записывает строку в поток и возвращает
// позицию потока в начальное состояние для последующей операции чтения
procedure TGsvUnicodeMemoryStream.WriteString(const aString: WideString);
begin
  Rewrite;
  Write(PWideChar(aString)^, Length(aString) * SizeOf(WideChar));
  Position := 0;
end;

procedure TGsvUnicodeMemoryStream.WriteStringBuffer(aString: PWideChar;
  aLength: Integer);
begin
  Rewrite;
  Write(aString^, aLength * SizeOf(WideChar));
  Position := 0;
end;

// Устанавливает указатель в начало потока, читает содержимое потока и
// сохраняет его в строке
function TGsvUnicodeMemoryStream.ReadString: WideString;
begin
  Position := 0;
  SetLength(Result, Size div SizeOf(WideChar));
  Read(PWideChar(Result)^, Size);
end;

{ TGsvRtfMemoryStream }

function TGsvRtfMemoryStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := inherited Write(Buffer, Count);
  SetPointer(Memory, Position);
end;

procedure TGsvRtfMemoryStream.Rewrite;
begin
  Position := 0;
  SetPointer(Memory, 0);
end;

procedure TGsvRtfMemoryStream.WriteString(const aString: string);
begin
  Rewrite;
  Write(PChar(aString)^, Length(aString));
  Position := 0;
end;

procedure TGsvRtfMemoryStream.WriteStringBuffer(aString: PChar;
  aLength: Integer);
begin
  Rewrite;
  Write(aString^, aLength);
  Position := 0;
end;

function TGsvRtfMemoryStream.ReadString: string;
begin
  Position := 0;
  SetLength(Result, Size);
  Read(PChar(Result)^, Size);
end;

{ TGsvCustomUnicodeRichEdit }

constructor TGsvCustomUnicodeRichEdit.Create(aOwner: TComponent);
var
  DC: HDC;
begin
  inherited Create(aOwner);
  ControlStyle := ControlStyle + [csNeedsBorderPaint] - [csSetCaption];
  if not NewStyleControls then
    ControlStyle := ControlStyle + [csFramed];

  FAlignment        := taLeftJustify;
  FAutoSelect       := False;
  FAutoSize         := False;
  FAutoURLDetect    := False;
  FBorderStyle      := bsSingle;
  FHideScrollBars   := True;
  FHideSelection    := True;
  FMaxLength        := 0;
  FMaxUndo          := 100;
  FMultiLine        := True;
  FReadOnly         := False;
  FPlainText        := False;
  FScrollBars       := ssNone;
  FSelectionBar     := False;
  FWantReturns      := True;
  FWantTabs         := False;
  FWordWrap         := True;
  FOldParaAlignment := Alignment;
  FStream           := TGsvUnicodeMemoryStream.Create;
  FRtfStream        := TGsvRtfMemoryStream.Create;

  DC := GetDC(0);
  FScreenLogPixels := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);

  Ctl3D             := True;
  DoubleBuffered    := False;
  Width             := 185;
  Height            := 89;
  ParentColor       := False;
  ParentCtl3D       := True;
  TabStop           := True;
end;

destructor TGsvCustomUnicodeRichEdit.Destroy;
begin
  FRtfStream.Free;
  FStream.Free;
  inherited Destroy;
end;

procedure TGsvCustomUnicodeRichEdit.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  if FPlainText then
    RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetAutoURLDetect(Value: Boolean);
begin
  FAutoURLDetect := Value;
  if not FPlainText then
    SendMsg(EM_AUTOURLDETECT, Ord(FAutoURLDetect), 0);
end;

procedure TGsvCustomUnicodeRichEdit.SetBorderStyle(Value: TBorderStyle);
begin
  FBorderStyle := Value;
  RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetHideScrollBars(Value: Boolean);
begin
  FHideScrollBars := Value;
  RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetHideSelection(Value: Boolean);
begin
  FHideSelection := Value;
  SendMsg(EM_HIDESELECTION, Ord(FHideSelection), 0);
end;

procedure TGsvCustomUnicodeRichEdit.SetMaxLength(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  SetMaxLengthEx(Value);
end;

procedure TGsvCustomUnicodeRichEdit.SetMaxLengthEx(Value: Integer);
begin
  FMaxLength := Value;
  SendMsg(EM_EXLIMITTEXT, 0, FMaxLength);
end;

procedure TGsvCustomUnicodeRichEdit.SetMaxUndo(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  FMaxUndo := Value;  
  SendMsg(EM_SETUNDOLIMIT, Value, 0);
end;

procedure TGsvCustomUnicodeRichEdit.SetMultiLine(Value: Boolean);
begin
  FMultiLine := Value;
  RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetReadOnly(Value: Boolean);
begin
  FReadOnly := Value;
  SendMsg(EM_SETREADONLY, Ord(FReadOnly), 0);
end;

procedure TGsvCustomUnicodeRichEdit.SetScrollBars(Value: TScrollStyle);
begin
  FScrollBars := Value;
  RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelectionBar(Value: Boolean);
begin
  FSelectionBar := Value;
  RecreateWnd;
end;

procedure TGsvCustomUnicodeRichEdit.SetWordBreakProc(
  Value: PGsvUnicodeEditWordBreakProc);
begin
  FWordBreakProc := Value;
  if Assigned(FWordBreakProc) then
    SendMsg(EM_SETWORDBREAKPROC, 0, LPARAM(FWordBreakProc));
end;

procedure TGsvCustomUnicodeRichEdit.SetWordWrap(Value: Boolean);
begin
  FWordWrap := Value;
  RecreateWnd;
end;

function TGsvCustomUnicodeRichEdit.GetModified: Boolean;
begin
  if HandleAllocated then
    Result := SendMsg(EM_GETMODIFY, 0, 0) <> 0
  else
    Result := FModified;
end;

procedure TGsvCustomUnicodeRichEdit.SetModified(Value: Boolean);
begin
  if HandleAllocated then
    SendMsg(EM_SETMODIFY, Byte(Value), 0)
  else
    FModified := Value;
end;

function TGsvCustomUnicodeRichEdit.GetSelLength: Integer;
var
  CharRange: TCharRange;
begin
  if HandleAllocated then begin
    SendMsg(EM_EXGETSEL, 0, LPARAM(@CharRange));
    Result := CharRange.cpMax - CharRange.cpMin;
  end
  else
    Result := 0;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelLength(Value: Integer);
var
  CharRange: TCharRange;
begin
  SendMsg(EM_EXGETSEL, 0, LPARAM(@CharRange));
  CharRange.cpMax := CharRange.cpMin + Value;
  SendMsg(EM_EXSETSEL, 0, LPARAM(@CharRange));
end;

function TGsvCustomUnicodeRichEdit.GetSelStart: Integer;
var
  CharRange: TCharRange;
begin
  if HandleAllocated then begin
    SendMsg(EM_EXGETSEL, 0, LPARAM(@CharRange));
    Result := CharRange.cpMin;
  end
  else
    Result := 0;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelStart(Value: Integer);
var
  CharRange: TCharRange;
begin
  CharRange.cpMin := Value;
  CharRange.cpMax := Value;
  SendMsg(EM_EXSETSEL, 0, LPARAM(@CharRange));
end;

function TGsvCustomUnicodeRichEdit.GetSelRange: TCharRange;
begin
  if HandleAllocated then
    SendMsg(EM_EXGETSEL, 0, LPARAM(@Result))
  else begin
    Result.cpMin := 0;
    Result.cpMax := 0;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelRange(const Value: TCharRange);
begin
  SendMsg(EM_EXSETSEL, 0, LPARAM(@Value));
end;

function TGsvCustomUnicodeRichEdit.GetCaretPos: TPoint;
var
  CharRange: TCharRange;
begin
  if HandleAllocated then begin
    SendMsg(EM_EXGETSEL, 0, LongInt(@CharRange));
    Result.X := CharRange.cpMax;
    Result.Y := SendMsg(EM_EXLINEFROMCHAR, 0, Result.X);
    Dec(Result.X, SendMsg(EM_LINEINDEX, -1, 0));
  end
  else begin
    Result.X := 0;
    Result.Y := 0;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetCaretPos(const Value: TPoint);
var
  CharRange: TCharRange;
begin
  CharRange.cpMin := SendMsg(EM_LINEINDEX, Value.Y, 0) + Value.X;
  CharRange.cpMax := CharRange.cpMin;
  SendMsg(EM_EXSETSEL, 0, Longint(@CharRange));
end;

function TGsvCustomUnicodeRichEdit.GetSelWideText: WideString;
var
  len1, len2: Integer;
begin
  if HandleAllocated then begin
    len1 := GetSelLength;
    if len1 <> 0 then begin
      SetLength(Result, len1);
      len2 := SendMsg(EM_GETSELTEXT, 0, LPARAM(PWideChar(Result)));
      if len2 <> 0 then begin
        if len1 > len2 then
          SetLength(Result, len2)
        else
          Assert(len1 = len2);
      end
      else
        Result := '';
    end
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TGsvCustomUnicodeRichEdit.SetSelWideText(const Value: WideString);
begin
  SetSelWideBuffer(PWideChar(Value), Length(Value));
end;

function TGsvCustomUnicodeRichEdit.GetSelWideChar: WideChar;
var
  CharRange:  TCharRange;
  TextRange:  TTextRangeW;
  Buffer:     array[0..3] of WideChar;
begin
  if HandleAllocated then begin
    SendMsg(EM_EXGETSEL, 0, LPARAM(@CharRange));
    TextRange.chrg.cpMin := CharRange.cpMin;
    TextRange.chrg.cpMax := CharRange.cpMin + 1;
    TextRange.lpstrText  := Buffer;
    Buffer[0]            := #0;
    SendMsg(EM_GETTEXTRANGE, 0, LPARAM(@TextRange));
    Result := Buffer[0];
  end
  else
    Result := #0;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelWideChar(Value: WideChar);
begin
  SetSelWideBuffer(@Value, 1);
end;

function TGsvCustomUnicodeRichEdit.GetWideText: WideString;
var
  cr: TCharRange;
begin
  cr.cpMin := 0;
  cr.cpMax := -1;
  Result := GetWideTextRange(cr);
end;

procedure TGsvCustomUnicodeRichEdit.SetWideText(const Value: WideString);
begin
  if HandleAllocated then begin
    FStream.WriteString(Value);
    TransferStream(FStream, EM_STREAMIN, SF_TEXT or SF_UNICODE);
  end;
end;

function TGsvCustomUnicodeRichEdit.GetWideChars(aPosition: Integer): WideChar;
var
  r:  TCharRange;
  ws: WideString;
begin
  r.cpMin := aPosition;
  r.cpMax := aPosition + 1;
  ws := GetWideTextRange(r);
  if ws = '' then
    Result := #0
  else
    Result := ws[1];
end;

function TGsvCustomUnicodeRichEdit.GetWideLines(aIndex: Integer): WideString;
var
  r: TCharRange;
begin
  r.cpMin := PositionByLine(aIndex);
  r.cpMax := PositionByLine(aIndex + 1);
  if r.cpMax = r.cpMin then
    Result := ''
  else begin
    Result := GetWideTextRange(r);
  end;
end;

procedure TGsvCustomUnicodeRichEdit.CMRecreateWnd(var Message: TMessage);
begin
  if not (csLoading in ComponentState) then begin
    if HandleAllocated and (not (csDesigning in ComponentState)) then
      FStream.Position := 0;
    inherited;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;
  inherited;
end;

procedure TGsvCustomUnicodeRichEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if not ((csDesigning in ComponentState) and (csLoading in ComponentState)) then
    AdjustHeight;
end;

procedure TGsvCustomUnicodeRichEdit.CMEnter(var Message: TCMGotFocus);
begin
  if FAutoSelect and not (csLButtonDown in ControlState) and not FMultiLine then
    SelectAll;
  inherited;
end;

procedure TGsvCustomUnicodeRichEdit.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    EN_CHANGE: begin
      if not FCreating then
        Change;
    end;
    EN_HSCROLL: DoHScroll;
    EN_VSCROLL: DoVScroll;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.CNNotify(var Message: TWMNotify);
type
  PENLink = ^TENLink;
begin
  inherited;
  with Message do begin
    case NMHdr^.code of
      EN_SELCHANGE:
        SelectionChange;
      EN_REQUESTRESIZE:
        RequestSize(PReqSize(NMHdr)^.rc);
      EN_PROTECTED: begin
        with PENProtected(NMHdr)^.chrg do
          if not ProtectChange(cpMin, cpMax) then
            Result := 1;
      end;
      EN_LINK: begin
        with PENLink(NMHdr)^ do begin
          LinkDetected(msg, chrg);
        end;
      end;
    end;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.WMSetFont(var Message: TWMSetFont);
begin
  inherited;
  if NewStyleControls then
    SendMsg(EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 0);
end;

procedure TGsvCustomUnicodeRichEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if FWantTabs then
    Message.Result := Message.Result or DLGC_WANTTAB
  else
    Message.Result := Message.Result and not DLGC_WANTTAB;
  if FWantReturns then
    Message.Result := Message.Result or DLGC_WANTALLKEYS
  else
    Message.Result := Message.Result and not DLGC_WANTALLKEYS;
end;

procedure TGsvCustomUnicodeRichEdit.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
end;

procedure TGsvCustomUnicodeRichEdit.WMContextMenu(var Message: TWMContextMenu);
begin
  SetFocus;
  inherited;
end;

procedure TGsvCustomUnicodeRichEdit.WMLangChange(var Msg: TMessage);
var
  h: HKL;
begin
  inherited;
  if Assigned(FOnLangChange) then begin
    h := Msg.LParam;
    FOnLangChange(Self, Msg.WParam, (h and $FFFF), ((h shr 16) and $FFFF));
  end;
end;

procedure TGsvCustomUnicodeRichEdit.AdjustHeight;
const
  BorderHeights1: array[Boolean, Boolean] of Integer = ((0, 0), (8, 6));
  BorderHeights2: array[TBevelKind] of Integer = (2, 4, 4, 4);
var
  DC:                  HDC;
  SaveFont:            HFont;
  I:                   Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  if FAutoSize and (not FMultiLine) then begin
    DC := GetDC(0);
    GetTextMetrics(DC, SysMetrics);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    I := BorderHeights1[FBorderStyle = bsSingle, Ctl3D] +
         BorderHeights2[BevelKind];
    if BevelKind <> bkNone then
      Inc(I, (BevelWidth - 1) * 4);
    I := I * GetSystemMetrics(SM_CYBORDER);
    Inc(I, Metrics.tmHeight);
    if Height <> I then
      Height := I;
  end;
end;

// Используется потоковое копирование по следующим причинам:
// a) EM_REPLACESEL не работает с юникодом
// b) EM_SETTEXTEX отсутствует в RichEdit 2.0
procedure TGsvCustomUnicodeRichEdit.SetSelWideBuffer(const aBuffer: PWideChar;
  aLength: Integer);
var
  err: Boolean;
begin
  if aBuffer^ <> #0 then begin
    err := FReadOnly;
    if not err then
      err := (FMaxLength <> 0) and
             ((TextLength + aLength - GetSelLength) > FMaxLength);
    if err then
      MessageBeep(Cardinal(-1))
    else
      SetSelWidePString(aBuffer, aLength);
  end;
end;

function TGsvCustomUnicodeRichEdit.ProtectChange(StartPos, EndPos: Integer):
  Boolean;
begin
  if Assigned(FOnProtectChange) and (FLockUpdate = 0) then
    FOnProtectChange(Self, StartPos, EndPos, Result)
  else
    Result := False;
end;

procedure TGsvCustomUnicodeRichEdit.RequestSize(const Rect: TRect);
begin
  if Assigned(FOnResizeRequest) and (FLockUpdate = 0) then
    FOnResizeRequest(Self, Rect);
end;

procedure TGsvCustomUnicodeRichEdit.SelectionChange;
begin
  if Assigned(FOnSelChange) and (FLockUpdate = 0) then
    FOnSelChange(Self);
end;

procedure TGsvCustomUnicodeRichEdit.LinkDetected(aMessage: Integer;
  const aRange: TCharRange);
begin
  if Assigned(FOnLink) and (FLockUpdate = 0) then
    FOnLink(Self, aMessage, aRange);
end;

procedure TGsvCustomUnicodeRichEdit.DoHScroll;
begin
  if Assigned(FOnHScroll) and (FLockUpdate = 0) then
    FOnHScroll(Self);
end;

procedure TGsvCustomUnicodeRichEdit.DoVScroll;
begin
  if Assigned(FOnVScroll) and (FLockUpdate = 0) then
    FOnVScroll(Self);
end;

procedure TGsvCustomUnicodeRichEdit.CreateWnd;
begin
  FCreating := True;
  try
    inherited CreateWnd;
  finally
    FCreating := False;
  end;
  if FLockUpdate <> 0 then
    SendMsg(WM_SETREDRAW, 0, 0);
  SetMaxLengthEx(FMaxLength);
  SendMsg(EM_SETUNDOLIMIT, FMaxUndo, 0);
  SendMsg(EM_SETTEXTMODE, TM_RICHTEXT + TM_MULTILEVELUNDO + TM_MULTICODEPAGE, 0);
  SendMsg(EM_SETBKGNDCOLOR, 0, ColorToRGB(Color));
  SendMsg(EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_SELCHANGE or
          ENM_REQUESTRESIZE or ENM_PROTECTED or ENM_LINK or ENM_SCROLL);
  SendMsg(EM_GETLANGOPTIONS, FMaxUndo, 0);
  if FSelectionBar then
    SendMsg(EM_SETOPTIONS, ECOOP_SET, ECO_SELECTIONBAR);
  SendMsg(EM_AUTOURLDETECT, Ord(FAutoURLDetect), 0);
  if Assigned(FWordBreakProc) then
    SendMsg(EM_SETWORDBREAKPROC, 0, LPARAM(FWordBreakProc));
  if FStream.NeedRecreateWnd then begin
    TransferStream(FStream, EM_STREAMIN, FStream.RecreateFlags);
    FStream.NeedRecreateWnd := False;
    SetSelRange(FStream.RecreateRange);
    EnsureSelVisible;
  end;
  Modified := FModified;
  AdjustHeight;
end;

procedure TGsvCustomUnicodeRichEdit.DestroyWnd;
begin
  if FPlainText then
    FStream.RecreateFlags := SF_TEXT or SF_UNICODE
  else
    FStream.RecreateFlags := SF_RTF;
  FStream.Rewrite;
  TransferStream(FStream, EM_STREAMOUT, FStream.RecreateFlags);
  FStream.NeedRecreateWnd := True;
  FStream.RecreateRange   := GetSelRange;
  FStream.Position := 0;
  FModified := Modified;
  inherited DestroyWnd;
end;

procedure TGsvCustomUnicodeRichEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[Boolean, TAlignment] of DWORD =
    ((ES_LEFT, ES_RIGHT, ES_CENTER),(ES_RIGHT, ES_LEFT, ES_CENTER));
var
  mn: String;
begin
  if FRichEditModule = 0 then begin
    mn := RICHEDIT_MODULENAME;
    if Assigned(FOnModuleName) then
      FOnModuleName(Self, mn);
    FRichEditModule := LoadLibrary(PChar(mn));
    if FRichEditModule <= HINSTANCE_ERROR then
      FRichEditModule := 0;
  end;
  inherited CreateParams(Params);
  CreateSubClass(Params, RICHEDIT_CLASS);
  with Params do begin
    if FBorderStyle = bsSingle then begin
      if NewStyleControls and Ctl3D then
        ExStyle := ExStyle or WS_EX_CLIENTEDGE
      else
        Style := Style or WS_BORDER;
    end;
    Style := Style and not (WS_BORDER or WS_HSCROLL or WS_VSCROLL or
             ES_AUTOHSCROLL or ES_AUTOVSCROLL or
             ES_CENTER or ES_LEFT or ES_RIGHT or
             ES_MULTILINE or ES_READONLY or ES_NOHIDESEL or ES_WANTRETURN or
             ES_DISABLENOSCROLL);
    Style := Style or Alignments[UseRightToLeftAlignment, FAlignment];
    if not FHideScrollBars then
      Style := Style or ES_DISABLENOSCROLL;
    if not FHideSelection then
      Style := Style or ES_NOHIDESEL;
    if FReadOnly then
      Style := Style or ES_READONLY;
    if FWantReturns then
      Style := Style or ES_WANTRETURN;
    if not FHideScrollBars then
      Style := Style or ES_DISABLENOSCROLL;
    if FMultiLine then begin
      Style := Style or ES_MULTILINE or ES_AUTOVSCROLL;
      if FWordWrap then begin
        case FScrollBars of
          ssNone:       ;
          ssHorizontal: ;
          ssVertical:   Style := Style or WS_VSCROLL;
          ssBoth:       Style := Style or WS_VSCROLL;
        end;
      end
      else begin
        case FScrollBars of
          ssNone:       ;
          ssHorizontal: Style := Style or WS_HSCROLL or ES_AUTOHSCROLL;
          ssVertical:   Style := Style or WS_VSCROLL or ES_AUTOHSCROLL;
          ssBoth:       Style := Style or WS_HSCROLL or WS_VSCROLL or ES_AUTOHSCROLL;
        end;
      end;
    end
    else
      Style := Style or ES_AUTOHSCROLL;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.Loaded;
begin
  inherited Loaded;
  Modified := False;
end;

procedure TGsvCustomUnicodeRichEdit.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) and (FLockUpdate = 0) then
    FOnChange(Self);
end;

procedure TGsvCustomUnicodeRichEdit.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then begin
    FAutoSize := Value;
    AdjustHeight;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FLastMouseDownShift := Shift;
  FLastMouseDownPoint := Point(X, Y);
  inherited;
end;

function TGsvCustomUnicodeRichEdit.SendMsg(Msg: Cardinal;
  WParam, LParam: Integer): Integer;
begin
  if HandleAllocated then
    Result := SendMessage(Handle, Msg, WParam, LParam)
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.GetControlsAlignment: TAlignment;
begin
  Result := FAlignment;
end;

procedure TGsvCustomUnicodeRichEdit.BeginUpdate;
begin
  if FLockUpdate = 0 then
    SendMsg(WM_SETREDRAW, 0, 0);
  Inc(FLockUpdate);
end;

procedure TGsvCustomUnicodeRichEdit.EndUpdate;
begin
  Dec(FLockUpdate);
  Assert(FLockUpdate >= 0);
  if FLockUpdate = 0 then begin
    SendMsg(WM_SETREDRAW, 1, 0);
    Invalidate;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelPositions(aStartPos, aEndPos: Integer);
var
  r: TCharRange;
begin
  r.cpMin := aStartPos;
  r.cpMax := aEndPos;
  SendMsg(EM_EXSETSEL, 0, LPARAM(@r));
end;

procedure TGsvCustomUnicodeRichEdit.EnsureSelVisible;
begin
  SendMsg(EM_SCROLLCARET, 0, 0);
end;

function TGsvCustomUnicodeRichEdit.PositionByPoint(X, Y: Integer): Integer;
var
  p: TPointL;
begin
  if HandleAllocated then begin
    p.x := X;
    p.y := Y;
    Result := SendMsg(EM_CHARFROMPOS, 0, LPARAM(@p));
  end
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.PointByPosition(aPosition: Integer): TPoint;
begin
  if HandleAllocated then begin
    Result.Y := LineByPosition(aPosition);
    Result.X := aPosition - PositionByLine(Result.Y);
  end
  else begin
    Result.X := 0;
    Result.Y := 0;
  end;
end;

function TGsvCustomUnicodeRichEdit.PositionByLine(aLine: Integer): Integer;
begin
  if HandleAllocated then
    Result := SendMsg(EM_LINEINDEX, aLine, 0)
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.LineByPosition(aPosition: Integer): Integer;
begin
  if HandleAllocated then
    Result := SendMsg(EM_EXLINEFROMCHAR, 0, aPosition)
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.WordRangeByPosition(
  aPosition: Integer): TCharRange;
begin
  if HandleAllocated then begin
    Result.cpMin := SendMsg(EM_FINDWORDBREAK, WB_LEFT, aPosition);
    Result.cpMax := SendMsg(EM_FINDWORDBREAK, WB_RIGHTBREAK, aPosition);
  end
  else begin
    Result.cpMin := 0;
    Result.cpMax := 0;
  end;
end;

function TGsvCustomUnicodeRichEdit.WideWordByPosition(
  var aPosition: Integer): WideString;
var
  cr: TCharRange;
begin
  cr     := WordRangeByPosition(aPosition);
  Result := GetWideTextRange(cr);
  Dec(aPosition, cr.cpMin);
  Inc(aPosition);
end;

function TGsvCustomUnicodeRichEdit.GetWideTextRange(
  const aRange: TCharRange): WideString;
var
  r:        TTextRangeW;
  len:      Integer;
  min, max: Integer;
begin
  if HandleAllocated then begin
    min := aRange.cpMin;
    max := aRange.cpMax;
    if min < 0 then
      min := TextLength;
    if max < 0 then
      max := TextLength;
    len := max - min;
    if len > 0 then begin
      r.chrg.cpMin := min;
      r.chrg.cpMax := max;
    end
    else if len < 0 then begin
      r.chrg.cpMin := max;
      r.chrg.cpMax := min;
      len          := -len;
    end;
    if len = 0 then
      Result := ''
    else begin
      SetLength(Result, len);
      r.lpstrText := PWideChar(Result);
      SetLength(Result, SendMsg(EM_GETTEXTRANGE, 0, LPARAM(@r)));
    end;
  end
  else
    Result := '';
end;

function TGsvCustomUnicodeRichEdit.FindWideText(const SearchStr: WideString;
  StartPos, EndPos: Integer; Options: TGsvUnicodeSearchTypes): Integer;
var
  Find:  TFindTextW;
  Flags: Integer;
begin
  with Find.chrg do begin
    cpMin := StartPos;
    cpMax := EndPos;
  end;
  Find.lpstrText := PWideChar(SearchStr);
  Flags := 0;
  if not (stWideSearchUp in Options) then
    Flags := Flags or FR_DOWN;
  if stWideWholeWord in Options then
    Flags := Flags or FR_WHOLEWORD;
  if stWideMatchCase in Options then
    Flags := Flags or FR_MATCHCASE;
  Result := SendMsg(EM_FINDTEXTW, Flags, LPARAM(@Find));
end;

procedure TGsvCustomUnicodeRichEdit.TransferStream(aStream: TStream;
  aMessage, aFlags: Integer);
var
  Cookie: TStreamCookie;
  Stream: TEditStream;
begin
  with Cookie do begin
    Stream  := aStream;
    Message := aMessage;
  end;
  with Stream do begin
    dwCookie    := LongInt(@Cookie);
    dwError     := 0;
    pfnCallback := @StreamCallback;
  end;
  SendMsg(aMessage, aFlags, LPARAM(@Stream));
end;

procedure TGsvCustomUnicodeRichEdit.SaveToFile(const aFileName: String;
  aFlags: Integer);
var
  str: TFileStream;
begin
  if aFileName <> '' then begin
    str := TFileStream.Create(aFileName, fmCreate);
    try
      TransferStream(str, EM_STREAMOUT, aFlags);
    finally
      str.Free;
    end;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.LoadFromFile(const aFileName: String;
  aFlags: Integer);
var
  str: TFileStream;
begin
  if (aFileName <> '') and FileExists(aFileName) then begin
    str := TFileStream.Create(aFileName, fmOpenRead);
    try
      TransferStream(str, EM_STREAMIN, aFlags);
    finally
      str.Free;
    end;
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelWidePString(
  const aString: PWideChar; aLength: Integer);
begin
  if aLength <> 0 then begin
    FStream.WriteStringBuffer(aString, aLength);
    TransferStream(FStream, EM_STREAMIN, SF_TEXT or SFF_SELECTION or SF_UNICODE);
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetSelRtfString(const aString: string);
begin
  SetSelRtfPString(PChar(aString), Length(aString));
end;

procedure TGsvCustomUnicodeRichEdit.SetSelRtfPString(const aString: PChar;
  aLength: Integer);
begin
  if aLength <> 0 then begin
    FRtfStream.WriteStringBuffer(aString, aLength);
    TransferStream(FRtfStream, EM_STREAMIN, SF_RTF or SFF_SELECTION);
  end;
end;

procedure TGsvCustomUnicodeRichEdit.SetRtfPString(const aString: PChar;
  aLength: Integer);
begin
  if aLength <> 0 then begin
    FRtfStream.WriteStringBuffer(aString, aLength);
    TransferStream(FRtfStream, EM_STREAMIN, SF_RTF);
  end;
end;

function TGsvCustomUnicodeRichEdit.TextLength: Integer;
var
  tl: TGetTextLengthEx;
begin
  if HandleAllocated then begin
    tl.flags    := GTL_DEFAULT;
    tl.codepage := CP_UNICODE;
    Result      := SendMsg(EM_GETTEXTLENGTHEX, WPARAM(@tl), 0);
  end
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.LineCount: Integer;
begin
  Result := LineByPosition(TextLength) + 1;
end;

function TGsvCustomUnicodeRichEdit.FirstVisibleLine: Integer;
begin
  if HandleAllocated then
    Result := SendMsg(EM_GETFIRSTVISIBLELINE, 0, 0)
  else
    Result := 0;
end;

function TGsvCustomUnicodeRichEdit.CanUndo: Boolean;
begin
  if HandleAllocated then
    Result := SendMsg(EM_CANUNDO, 0, 0) <> 0
  else
    Result := False;
end;

function TGsvCustomUnicodeRichEdit.HasSelection: Boolean;
var
  r: TCharRange;
begin
  r := GetSelRange;
  Result := r.cpMin <> r.cpMax;
end;

function TGsvCustomUnicodeRichEdit.HasText: Boolean;
begin
  Result := TextLength <> 0;
end;

procedure TGsvCustomUnicodeRichEdit.Clear;
begin
  SetWideText('');
  ClearUndo;
  Modified := False;
end;

procedure TGsvCustomUnicodeRichEdit.CopyToClipboard;
begin
  SendMsg(WM_COPY, 0, 0);
end;

procedure TGsvCustomUnicodeRichEdit.CutToClipboard;
begin
  SendMsg(WM_CUT, 0, 0);
end;

procedure TGsvCustomUnicodeRichEdit.PasteFromClipboard;
begin
  SendMsg(WM_PASTE, 0, 0);
end;

procedure TGsvCustomUnicodeRichEdit.ClearSelection;
begin
  SendMsg(WM_CLEAR, 0, 0);
end;

procedure TGsvCustomUnicodeRichEdit.SelectAll;
begin
  SendMsg(EM_SETSEL, 0, -1);
end;

procedure TGsvCustomUnicodeRichEdit.Undo;
begin
  SendMsg(WM_UNDO, 0, 0);
end;

procedure TGsvCustomUnicodeRichEdit.ClearUndo;
begin
  SendMsg(EM_EMPTYUNDOBUFFER, 0, 0);
end;

function TGsvCustomUnicodeRichEdit.CreateCharFormat(
  aMasks: TGsvUnicodeCharFormatMasks; aEffects: TGsvUnicodeCharFormatEffects):
  TGsvUnicodeCharFormat;
begin
  Result := TGsvUnicodeCharFormat.Create(Self, aMasks, aEffects);
end;

function TGsvCustomUnicodeRichEdit.CreateParaFormat(
  aMasks: TGsvUnicodeParaFormatMasks): TGsvUnicodeParaFormat;
begin
  Result := TGsvUnicodeParaFormat.Create(Self, aMasks);
end;

{ TGsvUnicodeParaFormat }

constructor TGsvUnicodeParaFormat.Create(aEdit: TGsvCustomUnicodeRichEdit;
  aMasks: TGsvUnicodeParaFormatMasks);
var
  ipfm: TGsvUnicodeParaFormatMask;
const
  PFM: array[TGsvUnicodeParaFormatMask] of DWORD = (
    PFM_ALIGNMENT, PFM_OFFSET, PFM_RIGHTINDENT, PFM_STARTINDENT, PFM_TABSTOPS
  );
begin
  FEdit := aEdit;
  ZeroMemory(@FFormat, SizeOf(FFormat));
  FFormat.cbSize := SizeOf(FFormat);
  for ipfm := Low(TGsvUnicodeParaFormatMask) to
              High(TGsvUnicodeParaFormatMask) do
  begin
    if ipfm in aMasks then
      FFormat.dwMask := FFormat.dwMask or PFM[ipfm];
  end;
end;

function TGsvUnicodeParaFormat.GetAlignment: TAlignment;
begin
  case FFormat.wAlignment of
    PFA_LEFT:   Result := taLeftJustify;
    PFA_RIGHT:  Result := taRightJustify;
    PFA_CENTER: Result := taCenter;
    else        Result := taLeftJustify;
  end;
end;

procedure TGsvUnicodeParaFormat.SetAlignment(const Value: TAlignment);
const
  AL: array[TAlignment] of DWORD = (PFA_LEFT, PFA_RIGHT, PFA_CENTER);
begin
  FFormat.wAlignment := AL[Value];
end;

function TGsvUnicodeParaFormat.GetStartIndent: Integer;
begin
  Result := TwipsToPixels(FFormat.dxStartIndent);
end;

procedure TGsvUnicodeParaFormat.SetStartIndent(const Value: Integer);
begin
  FFormat.dxStartIndent := PixelsToTwips(Value);
end;

function TGsvUnicodeParaFormat.GetOffset: Integer;
begin
  Result := TwipsToPixels(FFormat.dxOffset);
end;

procedure TGsvUnicodeParaFormat.SetOffset(const Value: Integer);
begin
  FFormat.dxOffset := PixelsToTwips(Value);
end;

function TGsvUnicodeParaFormat.GetRightIndent: Integer;
begin
  Result := TwipsToPixels(FFormat.dxRightIndent);
end;

procedure TGsvUnicodeParaFormat.SetRightIndent(const Value: Integer);
begin
  FFormat.dxRightIndent := PixelsToTwips(Value);
end;

procedure TGsvUnicodeParaFormat.SetTabStops(aTabStops: array of Integer);
var
  i, cnt: Integer;
begin
  cnt := Length(aTabStops);
  if cnt > MAX_TAB_STOPS - 1 then
    cnt := MAX_TAB_STOPS - 1;
  FFormat.cTabCount := cnt;
  for i := 0 to Pred(cnt) do
    FFormat.rgxTabs[i] := PixelsToTwips(aTabStops[i]);
end;

function TGsvUnicodeParaFormat.PixelsToTwips(aPixels: Integer): Integer;
begin
  Result := MulDiv(aPixels, 20 * 72, FEdit.ScreenLogPixels);
end;

function TGsvUnicodeParaFormat.TwipsToPixels(aTwips: Integer): Integer;
begin
  Result := MulDiv(aTwips, FEdit.ScreenLogPixels, 20 * 72);
end;

procedure TGsvUnicodeParaFormat.SetFormat;
begin
  SendMessage(FEdit.Handle, EM_SETPARAFORMAT, 0, LPARAM(@FFormat));
end;

initialization

finalization
  if FRichEditModule <> 0 then
    FreeLibrary(FRichEditModule);

end.


// Диалог с возможностью выбора колдировки

unit DialogEnc;

interface

uses SysUtils, Classes, Dialogs, Windows, Messages, CommDlg;

type

  TCommandEvent = procedure(ControlID: Word) of object;

  TDialogEnc = class(TOpenDialog)
  private {Private declarations}
	  FTemplateRes: PChar;
  	FOnCommand: TCommandEvent;
	  procedure SetTemplateRes (const Value: PChar);
    procedure OpenDialog1OnShow(Sender: TObject);
    procedure OpenDialog1OnCommand(ControlID: Word);
  protected {Protected declarations}
	  procedure WndProc (var Message: TMessage); override;
  public {Public declarations}
    SaveDialog: boolean; // эьл диалог сохранения?
    EnableEncoding: boolean; // можно ли выбирать кодировку?
    EncodingStrings: TStrings; // строка для кодировки
    EncodingIndex: integer;  // индекс кодировки
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: boolean; override;
    // The attributes used to specify a custom logo template
    property TemplateRes: PChar read FTemplateRes write SetTemplateRes;
  published {Published declarations}
	  property OnCommand: TCommandEvent read FOnCommand write FOnCommand;
  end;

// procedure Register;

implementation

{$R DialogEnc.res}

const
  idEncoding = 257;
  LB_FILETYPES_ID = 1089;
  LB_DRIVES_ID = 1091;
  strSave = 'Save';
  strType = 'Save as types:';
  strSaveIn = 'Save in:';

Var
  TmpEncodingIndex: integer;

procedure TDialogEnc.SetTemplateRes(const Value: PChar);
begin
	FTemplateRes := Value;
	Self.Template := Value;
end;

procedure TDialogEnc.WndProc(var Message: TMessage);
begin
	Message.Result := 0;
	if (Message.Msg = WM_COMMAND) then
	begin
		if Assigned(FOnCommand) then
			FOnCommand(Message.WParamLo);
	end;
	inherited WndProc(Message);
end;

procedure TDialogEnc.OpenDialog1OnShow(Sender: TObject);
Var
  i: integer;
  Wnd, h: HWND;
begin
//
  if SaveDialog then
  begin
    Wnd := GetParent(Self.Handle);
    SendMessage(Wnd, CDM_SETCONTROLTEXT, idOk, Longint(PChar(strSave)));
    SendMessage(Wnd, CDM_SETCONTROLTEXT, LB_FILETYPES_ID, Longint(PChar(strType)));
    SendMessage(Wnd, CDM_SETCONTROLTEXT, LB_DRIVES_ID, Longint(PChar(strSaveIn)));
  end;
//
  h := GetDlgItem(Self.Handle,idEncoding);
  EnableWindow( h, EnableEncoding );
  if not EnableEncoding then
    Exit;
  with EncodingStrings do
    for i := 0 to EncodingStrings.Count-1 do
      SendMessage(h, CB_ADDSTRING, 0, LongInt(PChar(Strings[i])) );
  SendMessage(h, CB_SETCURSEL, EncodingIndex, 0);
  TmpEncodingIndex := EncodingIndex;
end;

constructor TDialogEnc.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnShow := OpenDialog1OnShow;
  OnCommand := OpenDialog1OnCommand;
  EnableEncoding := True;
  SaveDialog := False;
  EncodingStrings := TStringList.Create;
  TemplateRes := Windows.MakeIntResource(131);
end;

destructor TDialogEnc.Destroy;
begin
  EncodingStrings.Free;
end;

procedure TDialogEnc.OpenDialog1OnCommand(ControlID: Word);
Var
  h: HWND;
begin
  if ControlID = idEncoding then
  begin
    h := GetDlgItem(Self.Handle,idEncoding);
    if h <= 0 then
      Exit;
    TmpEncodingIndex := SendMessage(h, CB_GETCURSEL, 0, 0);
  end;
end;

function TDialogEnc.Execute: boolean;
begin
  Result := inherited Execute;
  if Result then
    EncodingIndex := TmpEncodingIndex;
end;

end.

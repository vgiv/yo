unit Input;

{$INCLUDE Yo.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TInputForm = class(TForm)
    lInput: TLabel;
    eInput: TEdit;
    bOK: TButton;
    bCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetInteger( Var v: integer; vmin, vmax: integer );
  end;

var
  InputForm: TInputForm;

implementation

{$R *.DFM}

{ TInputForm }

procedure TInputForm.GetInteger(Var v: integer; vmin, vmax: integer );
Var
  r: TModalResult;
begin
  Caption := '';
  lInput.Caption := '¬ведите число: ';
  eInput.Left := lInput.Left + lInput.Width + 3;
  repeat
    eInput.Text := Format( '%d', [v] );
    r := ShowModal;
    if r=mrOK then
      try
        v := StrToInt( eInput.Text );
        if (vmin>vmax) or (v<vmin) or (v>vmax) then
        begin
          Caption := Format( '%d <= x <= %d', [vmin,vmax] );
          r := 0;
        end;
      except
        r := 0;
      end;
  until r<>0;
end;

procedure TInputForm.FormShow(Sender: TObject);
begin
  eInput.SetFocus;
end;

procedure TInputForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode = VK_Escape then
    ModalResult := mrCancel
  else if Msg.CharCode = VK_Return then
    ModalResult := mrOK;
end;

end.

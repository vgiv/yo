unit FileProp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids;

type
  TFilePropForm = class(TForm)
    sgProp: TStringGrid;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FilePropForm: TFilePropForm;

implementation

{$R *.dfm}

procedure TFilePropForm.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if Msg.CharCode = VK_ESCAPE then
    ModalResult := mrCancel;
end;

end.

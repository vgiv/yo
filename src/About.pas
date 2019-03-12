unit About;

{$INCLUDE Yo.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TAboutForm = class(TForm)
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    lVersion: TLabel;
    lCopyleft: TLabel;
    lEmail: TLabel;
    lURL: TLabel;
    Image1: TImage;
    lDictionary: TLabel;
    Bevel1: TBevel;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    lRegExprDic: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure lEmailDblClick(Sender: TObject);
    procedure lURLDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses
 FMXUtils, Commons;

{$R *.DFM}

procedure TAboutForm.Button1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TAboutForm.lEmailDblClick(Sender: TObject);
begin
  ExecuteFile('mailto:vgivanov@mail.ru?Subject=Yo','','',SW_NORMAL);
end;

procedure TAboutForm.lURLDblClick(Sender: TObject);
begin
  ExecuteFile('http://'+MyHostName+'/yo/yo.html','','',SW_NORMAL);
end;

end.

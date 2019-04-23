program Yol;

{$INCLUDE Yo.inc}

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  About in 'About.pas' {AboutForm},
  MyLists in 'MyLists.pas',
  Input in 'Input.pas' {InputForm},
  WindowsXPTheme,
  RegExpr in 'RegExpr.pas',
  FileProp in 'FileProp.pas' {FilePropForm},
  DialogEnc in 'DialogEnc.pas',
  OptionsPage in 'OptionsPage.pas' {OptionsForm},
  Commons in 'Commons.pas';

{MorphoGen}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TInputForm, InputForm);
  Application.CreateForm(TFilePropForm, FilePropForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  MainForm.InitData;
  Application.Run;
end.

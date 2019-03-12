unit WindowsXPLib;

interface

uses Windows, SysUtils;


type
  HTHEME = THANDLE;

const
  WM_THEMECHANGED  = $031A;

var
  hUxTheme: HINST;
  IsWinXP:  Boolean;
  UseTheme: Boolean;

  OpenThemeData:       function (hwnd: HWND; pszClassList: LPCWSTR): HTHEME; stdcall;
  DrawThemeBackground: function (hTheme: HTHEME; hdc: HDC; iPartId, iStateId: Integer; const pRect: TRECT; pClipRect: PRECT): HRESULT; stdcall;
  CloseThemeData:      function (hTheme: HTHEME): HRESULT; stdcall;
  DrawThemeText:       function(hTheme: HTHEME; hdc: HDC; iPartId, iStateId: Integer; pszText: LPCWSTR; iCharCount: Integer; dwTextFlags, dwTextFlags2: DWORD; const pRect: TRECT): HRESULT; stdcall;

  procedure IsWinXPCheck;

implementation

procedure IsWinXPCheck;
begin
  IsWinXP:=False;
  if Win32Platform=VER_PLATFORM_WIN32_NT then if Win32BuildNumber>=2462 then IsWinXP:=True;
end;


initialization
  IsWinXPCheck;
  hUxTheme:=0;
  UseTheme:=False;
  if IsWinXP then
  begin
    hUxTheme:=LoadLibrary('uxtheme.dll');
    if hUxTheme<>0 then
    begin
      UseTheme:=True;
      @OpenThemeData:=GetProcAddress(hUxTheme,'OpenThemeData');
      @DrawThemeBackground:=GetProcAddress(hUxTheme,'DrawThemeBackground');
      @CloseThemeData:=GetProcAddress(hUxTheme,'CloseThemeData');
      @DrawThemeText:=GetProcAddress(hUxTheme,'DrawThemeText');
    end;
//    usetheme:=false;
  end;

finalization
  if hUxTheme<>0 then FreeLibrary(hUxTheme);

end.

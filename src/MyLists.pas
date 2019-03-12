unit MyLists;

interface

uses
  Classes, RegExpr;

type
  TIntegerList = class(TList)  //список целых
    procedure Add( const v: integer );
    procedure Insert( const p: integer; const v: integer );
    destructor Destroy; override;
    function GetValue(Index: integer): integer;
    procedure SetValue(Index: integer; v: integer);
    property Values[Index: Integer]: integer read GetValue write SetValue; default;
  end;
  TShortIntList = class(TList)  //список целых
    procedure Add( const v: shortint );
    procedure Insert( const p: integer; const v: shortint );
    destructor Destroy; override;
    function GetValue(Index: integer): shortint;
    procedure SetValue(Index: integer; v: shortint);
    property Values[Index: Integer]: shortint read GetValue write SetValue; default;
  end;
  TRegExprList = class(TList)  //список регулярных выражений
    procedure Add( const v: TRegExpr );
    destructor Destroy; override;
    function GetValue(Index: integer): TRegExpr;
    property Values[Index: Integer]: TRegExpr read GetValue; default;
  end;

implementation

{TIntegerList}

procedure TIntegerList.Add( const v: integer );
Var
  pv: ^integer;
begin
  New( pv );
  pv^ := v;
  inherited Add( pv );
end;

procedure TIntegerList.Insert( const p: integer; const v: integer );
Var
  pv: ^integer;
begin
  New( pv );
  pv^ := v;
  inherited Insert( p, pv );
end;

destructor TIntegerList.Destroy;
Var
  i: integer;
begin
  for i := 0 to Count-1 do
    FreeMem( Items[i], SizeOf(integer) );
  inherited Destroy;
end;

function TIntegerList.GetValue(Index: integer): integer;
Var
  pv: ^integer;
begin
  pv := Items[Index];
  Result := pv^;
end;

procedure TIntegerList.SetValue(Index: integer; v: integer);
Var
  pv: ^integer;
begin
  pv := Items[Index];
  pv^ := v;
end;

{TShortIntList}

procedure TShortIntList.Add( const v: shortint );
Var
  pv: ^shortint;
begin
  New( pv );
  pv^ := v;
  inherited Add( pv );
end;

procedure TShortIntList.Insert( const p: integer; const v: shortint );
Var
  pv: ^shortint;
begin
  New( pv );
  pv^ := v;
  inherited Insert( p, pv );
end;

destructor TShortIntList.Destroy;
Var
  i: integer;
begin
  for i := 0 to Count-1 do
    FreeMem( Items[i], SizeOf(shortint) );
  inherited Destroy;
end;

function TShortIntList.GetValue(Index: integer): shortint;
Var
  pv: ^shortint;
begin
  pv := Items[Index];
  Result := pv^;
end;

procedure TShortIntList.SetValue(Index: integer; v: shortint);
Var
  pv: ^shortint;
begin
  pv := Items[Index];
  pv^ := v;
end;

{TRegExprList}

procedure TRegExprList.Add( const v: TRegExpr );
Var
  pv: ^TRegExpr;
begin
  New( pv );
  pv^ := v;
  inherited Add( pv );
end;

destructor TRegExprList.Destroy;
Var
  i: integer;
begin
  for i := 0 to Count-1 do
    FreeMem( Items[i], SizeOf(TRegExpr) );
  inherited Destroy;
end;

function TRegExprList.GetValue(Index: integer): TRegExpr;
Var
  pv: ^TRegExpr;
begin
  pv := Items[Index];
  Result := pv^;
end;

end.



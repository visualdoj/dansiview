{$MODE FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}
unit dansiview_overloads;

interface

uses
  dansiview;

// Overload classic pascal string routines
function Copy(const S: TAnsiView; Index: SizeInt; Count: SizeInt): TAnsiView; inline; overload;
function Pos(const SubStr: TAnsiView; S: TAnsiView): SizeInt; inline; overload;
function Pos(C: AnsiChar; const S: TAnsiView): SizeInt; inline; overload;
function Low(const S: TAnsiView): SizeInt; inline; overload;
function High(const S: TAnsiView): SizeInt; inline; overload;
function Length(const S: TAnsiView): SizeInt; inline; overload;
procedure Insert(const Source: TAnsiView; var S: AnsiString; Index: SizeInt); inline; overload;
function Trim(const S: TAnsiView): TAnsiView; inline; overload;
function Split(const S: TAnsiView;
               const Delim: TAnsiView;
               out Left: TAnsiView;
               out Right: TAnsiView): Boolean; inline; overload;

implementation

function Copy(const S: TAnsiView; Index: SizeInt; Count: SizeInt): TAnsiView;
begin
  Result := dansiview.AnsiCopy(S, Index, Count);
end;

function Pos(const SubStr: TAnsiView; S: TAnsiView): SizeInt;
begin
  Result := dansiview.AnsiPos(SubStr, S);
end;

function Pos(C: AnsiChar; const S: TAnsiView): SizeInt;
begin
  Result := dansiview.AnsiPos(C, S);
end;

function Length(const S: TAnsiView): SizeInt;
begin
  Result := dansiview.AnsiLength(S);
end;

function Low(const S: TAnsiView): SizeInt;
begin
  Result := dansiview.AnsiLow(S);
end;

function High(const S: TAnsiView): SizeInt;
begin
  Result := dansiview.AnsiHigh(S);
end;

procedure Insert(const Source: TAnsiView; var S: AnsiString; Index: SizeInt);
begin
  dansiview.AnsiInsert(Source, S, Index);
end;

function Trim(const S: TAnsiView): TAnsiView;
begin
  Result := dansiview.AnsiTrim(S);
end;

function Split(const S: TAnsiView;
               const Delim: TAnsiView;
               out Left: TAnsiView;
               out Right: TAnsiView): Boolean;
begin
  Result := dansiview.AnsiSplit(S, Delim, Left, Right);
end;

end.

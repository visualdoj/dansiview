{$MODE FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}
unit dansiview;

interface

type
TAnsiEnumerator = record
private
  FCurrent: PAnsiChar;
  FTail: PAnsiChar;
  function GetCurrent: AnsiChar; inline;
public
  procedure Init(S: PAnsiChar; L: SizeUInt);
  procedure Done; inline;
  function MoveNext: Boolean; inline;
  property Current: AnsiChar read GetCurrent;
end;

TAnsiView = record
private
  FData: PAnsiChar;
  FLength: SizeUInt;
  function GetTail: PAnsiChar; inline;
  procedure SetTail(Tail: PAnsiChar); inline;
  function GetChar(Index: PtrUInt): AnsiChar; inline;
  procedure SetChar(Index: PtrUInt; C: AnsiChar); inline;
public
  // Pseudo constructor and destructor
  procedure Init(Data: PAnsiChar; Length: SizeUInt);
  procedure Done; inline;

  // Returns enumerator (for for-in loops support)
  function GetEnumerator: TAnsiEnumerator; inline;

  // Converts to AnsiString
  function ToString: AnsiString; inline;

  // Checks if the string has no characters, i.e. whether Length=0
  function IsEmpty: Boolean; inline;

  // Compares the string with the Other, returns:
  //    <0: Self is less than Other
  //     0: Self and Other are equal
  //    >0: Self is greater than Other
  function Compare(const Other: TAnsiView): LongInt; inline;

  // Checks if the string begins with the prefix
  function StartsWith(const Prefix: TAnsiView; Beg: LongInt; _End: LongInt): Boolean;
  function StartsWith(const Prefix: TAnsiView): Boolean;

  // Checks if the string ends with the postfix
  function EndsWith(const Postfix: TAnsiView): Boolean;
  function EndsWith(const Postfix: TAnsiView; Beg: LongInt; _End: LongInt): Boolean;

  // Access to the fields
  property Data: PAnsiChar read FData write FData;
  property Tail: PAnsiChar read GetTail write SetTail;
  property Length: SizeUInt read FLength write FLength;
  // No setter to prevent ocasionally damaging of const string
  property Chars[Index: SizeUInt]: AnsiChar read GetChar {write SetChar}; default;
end;

// Handy constructors
function AnsiView(Data: PAnsiChar; Tail: PAnsiChar): TAnsiView; inline;
function AnsiView(Data: PAnsiChar; Size: SizeUInt): TAnsiView; inline;

// Classic pascal string routines
function Copy(const S: TAnsiView; Index: SizeInt; Count: SizeInt): TAnsiView; overload;
function Pos(const SubStr: TAnsiView; S: TAnsiView): SizeInt; overload;
function Pos(C: AnsiChar; const S: TAnsiView): SizeInt; inline; overload;
function Low(const S: TAnsiView): SizeInt; inline; overload;
function High(const S: TAnsiView): SizeInt; inline; overload;
function Length(const S: TAnsiView): SizeInt; inline; overload;
procedure Insert(const Source: TAnsiView; var S: AnsiString; Index: SizeInt); inline; overload;
function TrimRight(S: TAnsiView): TAnsiView; overload;
function TrimLeft(S: TAnsiView): TAnsiView; overload;
function Trim(const S: TAnsiView): TAnsiView; inline; overload;

//
//  Split
//
//      Splits a string by the specified delimiter.
//
//  Parameters:
//
//      S: the string
//      Delim: the delimiter
//
//  Returns:
//
//      Result: True if S contains Delim, False otherwise
//      Left: contains part of the string before the Delim if Result=True
//      Right: contains part of the string after the Delim if Result=True
//
function Split(const S: TAnsiView;
               const Delim: TAnsiView;
               out Left: TAnsiView;
               out Right: TAnsiView): Boolean; overload;

// Some implicit conversions
operator := (P: PAnsiChar): TAnsiView; inline;
operator := (const S: AnsiString): TAnsiView; inline;
operator := (const S: ShortString): TAnsiView; inline;
operator := (const Buf: array of AnsiChar): TAnsiView; inline;

// Comparison operators
operator = (A, B: TAnsiView): Boolean; inline;
operator < (A, B: TAnsiView): Boolean; inline;
operator > (A, B: TAnsiView): Boolean; inline;
operator <= (A, B: TAnsiView): Boolean; inline;
operator >= (A, B: TAnsiView): Boolean; inline;
operator in (A, B: TAnsiView): Boolean;

implementation

function _Compare(A, B: TAnsiView): LongInt;
begin
  Result := A.Length - B.Length;
  if Result < 0 then begin
    Result := CompareByte(A.Data^, B.Data^, A.Length);
    if Result = 0 then
      Result := -1;
  end else if Result > 0 then begin
    Result := CompareByte(A.Data^, B.Data^, B.Length);
    if Result = 0 then
      Result := 1;
  end else begin
    Result := CompareByte(A.Data^, B.Data^, A.Length);
  end;
end;

procedure TAnsiEnumerator.Init(S: PAnsiChar; L: SizeUInt);
begin
  FCurrent := S - 1;
  FTail := S + L;
end;

procedure TAnsiEnumerator.Done;
begin
end;

function TAnsiEnumerator.GetCurrent: AnsiChar;
begin
  Result := FCurrent^;
end;

function TAnsiEnumerator.MoveNext: Boolean;
begin
  Inc(FCurrent);
  Result := FCurrent < FTail;
end;

function TAnsiView.GetTail: PAnsiChar;
begin
  Result := FData + FLength
end;

procedure TAnsiView.SetTail(Tail: PAnsiChar);
begin
  FLength := Tail - FData;
end;

function TAnsiView.GetChar(Index: PtrUInt): AnsiChar;
begin
  Result := FData[Index - 1];
end;

procedure TAnsiView.SetChar(Index: PtrUInt; C: AnsiChar);
begin
  FData[Index - 1] := C;
end;

procedure TAnsiView.Init(Data: PAnsiChar; Length: SizeUInt);
begin
  FData := Data;
  FLength := Length;
end;

procedure TAnsiView.Done;
begin
end;

function TAnsiView.StartsWith(const Prefix: TAnsiView): Boolean;
begin
  Result := (Length >= Prefix.Length) and (CompareByte(FData^, Prefix.Data^, Prefix.Length) = 0);
end;

function TAnsiView.StartsWith(const Prefix: TAnsiView; Beg: LongInt; _End: LongInt): Boolean;
begin
  Result := ((_End - Beg) >= Prefix.Length) and (CompareByte((FData + Beg)^, Prefix.Data^, Prefix.Length) = 0);
end;

function TAnsiView.EndsWith(const Postfix: TAnsiView): Boolean;
begin
  Result := (Length >= Postfix.Length) and (CompareByte((FData + FLength - Postfix.Length)^, Postfix.Data^, Postfix.Length) = 0);
end;

function TAnsiView.EndsWith(const Postfix: TAnsiView; Beg: LongInt; _End: LongInt): Boolean;
begin
  Result := ((_End - Beg) >= Postfix.Length) and (CompareByte((FData + _End - Postfix.Length)^, Postfix.Data^, Postfix.Length) = 0);
end;

function TAnsiView.GetEnumerator: TAnsiEnumerator;
begin
  Result.FCurrent := FData - 1;
  Result.FTail := Tail;
end;

function TAnsiView.ToString: AnsiString;
begin
  SetString(Result, Data, Length);
end;

function TAnsiView.IsEmpty: Boolean;
begin
  Result := FLength = 0;
end;

function TAnsiView.Compare(const Other: TAnsiView): LongInt;
begin
  Result := _Compare(Self, Other);
end;

function AnsiView(Data: PAnsiChar; Tail: PAnsiChar): TAnsiView;
begin
  Result.FData := Data;
  Result.FLength := Tail - Data;
end;

function AnsiView(Data: PAnsiChar; Size: SizeUInt): TAnsiView;
begin
  Result.FData := Data;
  Result.FLength := Size;
end;

function Copy(const S: TAnsiView; Index: SizeInt; Count: SizeInt): TAnsiView;
begin
  Result.Data := S.Data + Index - 1;
  if Result.Data > S.Tail then
    Result.Data := S.Tail;
  Result.Length := Count;
  if Result.Tail > S.Tail then
    Result.Tail := S.Tail;
end;

function Pos(const SubStr: TAnsiView; S: TAnsiView): SizeInt;
begin
  if SubStr.Length <= 0 then
    Exit(1);
  Result := IndexChar(S.Data^, S.Length, SubStr.Data^) + 1;
  while Result <> 0 do begin
    if CompareByte((S.Data + Result)^, (SubStr.Data + 1)^, SubStr.Length - 1) = 0 then
      Exit;
    Inc(S.FData, Result);
    Result := IndexChar(S.Data^, S.Length, SubStr.Data^) + 1;
  end;
end;

function Pos(C: AnsiChar; const S: TAnsiView): SizeInt;
begin
  Result := IndexChar(S.Data^, S.Length, C) + 1;
end;

function Length(const S: TAnsiView): SizeInt;
begin
  Result := S.Length;
end;

function Low(const S: TAnsiView): SizeInt;
begin
  Result := 1;
end;

function High(const S: TAnsiView): SizeInt;
begin
  Result := S.Length;
end;

procedure Insert(const Source: TAnsiView; var S: AnsiString; Index: SizeInt);
var
  OldLength: SizeInt;
begin
  OldLength := Length(S);
  SetLength(S, OldLength + Source.Length);
  Move(S[Index], S[Length(S) - (OldLength - Index + 1)], OldLength - Index + 1);
  Move(Source.Data^, S[Index], Source.Length);
end;

const
  WHITESPACE = [#9,#10,#13,#32];

function TrimRight(S: TAnsiView): TAnsiView;
begin
  while S.Length > 0 do begin
    if not (S[S.Length] in WHITESPACE) then
      break;
    Dec(S.FLength);
  end;
  Result := S;
end;

function TrimLeft(S: TAnsiView): TAnsiView;
var
  I: LongInt;
begin
  I := 1;
  while I <= S.Length do begin
    if not (S[I] in WHITESPACE) then
      break;
    Inc(I);
  end;
  Result := Copy(S, I, S.Length - I + 1);
end;

function Trim(const S: TAnsiView): TAnsiView;
begin
  Result := TrimRight(TrimLeft(S));
end;

function Split(const S: TAnsiView;
               const Delim: TAnsiView;
               out Left: TAnsiView;
               out Right: TAnsiView): Boolean;
var
  P: SizeInt;
begin
  P := Pos(Delim, S);
  Result := P <> 0;
  if Result then begin
    Left := AnsiView(S.Data, P - 1);
    Right := AnsiView(S.Data + P - 1 + Delim.Length, S.Length - P + 1 - Delim.Length);
  end;
end;

operator := (P: PAnsiChar): TAnsiView;
begin
  Result.Data := P;
  Result.Tail := Result.Data + StrLen(P);
end;

operator := (const S: AnsiString): TAnsiView;
begin
  Result.Data := @S[1];
  Result.Length := System.Length(S);
end;

operator := (const S: ShortString): TAnsiView; inline;
begin
  Result.Data := @S[1];
  Result.Length := System.Length(S);
end;

operator := (const Buf: array of AnsiChar): TAnsiView;
begin
  Result.Data := @Buf[0];
  Result.Tail := Result.Data + System.Length(Buf);
end;

operator = (A, B: TAnsiView): Boolean;
begin
  if A.Length <> B.Length then
    Exit(False);
  Result := CompareByte(A.Data^, B.Data^, A.Length) = 0;
end;

operator < (A, B: TAnsiView): Boolean;
begin
  Result := _Compare(A, B) < 0;
end;

operator > (A, B: TAnsiView): Boolean;
begin
  Result := _Compare(A, B) > 0;
end;

operator <= (A, B: TAnsiView): Boolean;
begin
  Result := _Compare(A, B) <= 0;
end;

operator >= (A, B: TAnsiView): Boolean;
begin
  Result := _Compare(A, B) >= 0;
end;

operator in (A, B: TAnsiView): Boolean;
begin
  Result := Pos(A, B) <> 0;
end;

end.

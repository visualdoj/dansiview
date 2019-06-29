{$MODE FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}
uses
  dansiview,
  dansiview_overloads;

var
  A: AnsiString;
  P: PAnsiChar;
  V, W: TAnsiView;
  C: AnsiChar;
  L, R: TAnsiView;

procedure TestCompare(const A, B: TAnsiView);
begin
  Writeln('"', A.ToString, '" ?  "', B.ToString, '": =', A = B, ' <>', A <> B, ' <', A < B, ' <=', A <= B, ' >', A > B, ' >=', A >= B);
end;

// Valid if the setter is uncommented
//procedure TryToChangeConst(const S: TAnsiView);
//begin
//  S[1] := 'g';
//end;

procedure It(const A: TAnsiView);
var
  I: LongInt;
begin
  for I := 0 to A.Length do begin
    Writeln(A[I]);
  end;
end;

function FromOpenArray(const A: array of AnsiChar): TAnsiView;
var
  I: LongInt;
begin
  for I := Low(A) to High(A) do begin
    Writeln(A[I]);
  end;
  Result := A;
end;

begin
  // Check implicit conversions and classic pascal functions
  V := 'String literal';
  Writeln(Pos('r', V));
  Writeln(Length(V));
  Writeln(High(V));
  Writeln(V.ToString);
  P := 'PAnsiChar';
  Writeln(Pos('n', P));
  Writeln(Length(P));
  V := P;
  Writeln(V.ToString);
  A := 'AnsiString';
  Writeln(Pos('s', A));
  Writeln(Length(A));
  V := A;
  Writeln(V.ToString);
  Writeln(Copy('xyz', 2, 2).ToString);
  // dansiview_overloads
  Writeln(Copy('xyz', 2, 2).ToString);

  TestCompare('aa', 'aa');
  TestCompare('aa', 'ab');
  TestCompare('a', 'ab');
  TestCompare('ab', 'aa');
  TestCompare('ab', 'a');

  V := 'some';
  W := 'string with some words';
  Writeln(V in W);
  for C in W do
    Write(C, ' ');
  Writeln;

  V := 'var=expr';
  Write('Split: ', Split(V, '=', L, R), ' ');
  Writeln('"', L.ToString, '" "', R.ToString, '"');

  A := 'This is test for Insert.';
  Insert('working ', A, 9);
  Writeln(A);

  Writeln(A <> '');
  Writeln('' <> A);

  Writeln(Trim(TAnsiView('  '#9#32#10#13'asdfas'#9#32#10#13'  ')).ToString);
end.

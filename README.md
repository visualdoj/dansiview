# dansiview

Library implements yet another string type - `TAnsiView`. This is an object that refers to a constant contiguous sequence of `AnsiChar`s. Purpose of `TAnsiView` is similar as open array of chars: read-only access to string of any type.

It holds a pair `<Data,Length>` and does not allocate or own any memory.

## Construction and destruction

You can construct `TAnsiView` with handy functions `AnsiView`:

```
uses
  dansiview;

...

var
  S: AnsiString;
  A: TAnsiView;

...

  S := 'hello world';
  A := AnsiView(@S[1], 5);
```

The object does not require manual destruction. But you can use pseudo constructors and destructors if you want to do it in a consistent way:

```
  A.Init(@S[1], 5);

...

  A.Done;
```

Also the library supports implicit conversion from AnsiString, ShortString, null-terminated PAnsiChar and an Open Array:

```
  // S may be AnsiString, ShortString, PAnsiChar or an 'array of AnsiChar'
  A := S;
```

That means if a function has an argument of `TAnsiView` type, for example

```
procedure Foo(const A: TAnsiView);
```

then this argument allows a string of almost any default string type.

## Convert to AnsiString

You can build an `AnsiString` with `.ToString` method:

```
var
  S: AnsiString;
  A: TAnsiView;

...

  S := A.ToString;
```

Since this conversion is expensive (it allocates memory and constructs new string), the library does not provide implicit conversions to an AnsiString.

## Access to string data

```
var
  A: TAnsiView;
  I: LongInt;
  C: AnsiChar;

...

  A := 'hello world!';

  // Print length of the string
  Writeln(A.Length);

  // Access with pointer to beginning of the string
  Writeln(A.Data[0]);

  // Access with default property (starting with 1)
  Writeln(A[1]);

  // Iterate over characters with for-to loop
  for I := Low(A) to High(A) do
    Write(A[I]);
  Writeln;

  // Iterate over characters with for-in loop
  for C in A do
    Write(C);
  Writeln;
```

## Classic pascal string routines

One of the most powerful feature of the library is overloaded classic pascal routines. Look at the following code that extracts a substring:

```
var
  A, B: TAnsiView;

...

  A := 'This is a string';
  B := Copy(A, 6, 2);
```

If B is `AnsiString`, this code requires 1) destuct B 2) allocate memory for new string 3) copy data from A to new memory. But for `TAnsiView` it requires only computation of new pointer and length.

The library overloads following functions: `Copy`, `Pos`, `Low`, `High`, `Length`, `Insert`, `TrimLeft`, `TrimRight`, `Trim`.

## Operators

All comparison operators `=`, `<>`, `<`, `<=`, `>`, `>=` are supported. Operator `in` for checking whenever one string contains another is also supported.

## Other methods and functions

```
var
  A: TAnsiView;
  L, R: TAnsiView;

...

  // Check if string is empty (i.e. Length=0)
  if A.IsEmpty then
    Exit;

  // Split string with a separator
  A := 'var=expr';
  if Split(A, '=', L, R) then
    Writeln('Splitted to: "', L.ToString, '" "', R.ToString, '"');

  // Check string for prefix and postfix
  A := 'AAA BBB';
  if A.StartsWith('AAA') then
    Writeln('A sarts with AAA');
  if A.EndsWith('BBB') then
    Writeln('A ends with BBB');
```

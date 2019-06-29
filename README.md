# dansiview

Library implements yet another string type - `TAnsiView`. This is an object that refers to a constant contiguous sequence of `AnsiChar`s. Purpose of `TAnsiView` is similar as open array of chars: read-only access to string of any type.

It holds a pair `<Data,Length>` and does not allocate or own any memory.

## Construction and destruction

You can construct `TAnsiView` with handy functions `AnsiView`:

```pascal
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

The object does not require manual destruction. But you can use pseudo constructors and destructors if you prefer to do it in a consistent way with other objects:

```pascal
  A.Init(@S[1], 5);

...

  A.Done;
```

Also the library supports implicit conversion from AnsiString, ShortString, null-terminated PAnsiChar and an Open Array:

```pascal
  // S may be AnsiString, ShortString, PAnsiChar or an 'array of AnsiChar'
  A := S;
```

That means if a function has an argument of `TAnsiView` type, for example

```pascal
procedure Foo(const A: TAnsiView);
```

then this argument allows a string of almost any default string type.

## Convert to AnsiString

You can build an `AnsiString` with `.ToString` method:

```pascal
var
  S: AnsiString;
  A: TAnsiView;

...

  S := A.ToString;
```

Since this conversion is expensive (it allocates memory and constructs new string), the library does not provide implicit conversions to an AnsiString.

## Access to string data

```pascal
var
  A: TAnsiView;
  I: LongInt;
  C: AnsiChar;
  P: PAnsiChar;

...

  A := 'hello world!';

  // Print length of the string
  Writeln(A.Length);

  // Access with pointer to beginning of the string
  Writeln(A.Data[0]);

  // Access with default property (starting with 1)
  Writeln(A[1]);

  // Iterate over characters with for-to loop
  for I := 1 to A.Length do
    Write(A[I]);
  Writeln;

  // Iterate over characters with for-in loop
  for C in A do
    Write(C);
  Writeln;

  // Iterate over characters with end pointer
  P := A.Data;
  while P < A.Tail do begin
    Write(P^);
    Inc(P);
  end;
  Writeln;
```

## UTF-8

If your string contains UTF-8 encoded string you should not access to separate `AnsiChar`s. Instead, you should use UTF-8 decoding iterator. The library does not provide it, but my another library [dutf8](https://github.com/visualdoj/dunicode) does.

## Random access to characters

You can read characters with default array property as `A[I]`. Indexing starts with `1` to mimic `AnsiString` behaviour and ends with `A.Length`. You cannot write with the property. It is done to prevent damaging of constant and non-unique strings.

There is more low-level way to access characters: property `Data: PAnsiChar` that returns pointer to first character. With this property you can access characters the same way you access with array property: `A.Data[I]`, but indexing starts with `0` and ends with `A.High`.

You can write to `A.Data[I]`, but it is your responsibility to make sure you can actually do it. Consider following example with wrong code:

```pascal
const
  C = 'some constant string';
var
  A: TAnsiView;
  S1, S2: AnsiString;

// ...

  A := C;
  // WRONG! We will damage the constant C
  A.Data[2] := 'x';

  // Build some string
  S1 := C + '2';
  // Make reference copy from S2 to S1
  S2 := S1;
  // Get pointer to S2
  A := S2;
  // WRONG! We will damage S1
  A.Data[2] := 'x';
```

## Classic pascal string routines

One of the most powerful feature of the library is overloaded classic pascal routines. Look at the following code that extracts a substring:

```pascal
uses
  dansiview;

...

var
  A, B: TAnsiView;

...

  A := 'This is a string';
  B := AnsiCopy(A, 6, 2);
```

If B is `AnsiString`, this `Copy` requires 1) destuct B 2) allocate memory for new string 3) copy data from A to new memory. But with `TAnsiView` it requires only computation of new pointer and length.

Unit [`dansiview_overloads`](dansiview_overloads.pas) overloads standard functions without the `Ansi` prefix:

```pascal
uses
  dansiview,
  dansiview_overloads;

...

var
  A, B: TAnsiView;

...

  A := 'This is a string';
  B := Copy(A, 6, 2);
```

But these overloads are not done in the main `dansiview` unit because it is not possible to properly overload some builtin functions without overriding them.

The library overloads following functions: `Copy`, `Pos`, `Low`, `High`, `Length`, `Insert`, `TrimLeft`, `TrimRight`, `Trim`.

## Operators

All comparison operators `=`, `<>`, `<`, `<=`, `>`, `>=` are supported. Operator `in` for checking whenever one string contains another is also supported.

## Other methods and functions

```pascal
var
  A: TAnsiView;
  L, R: TAnsiView;

...

  // Check if string is empty (i.e. Length=0)
  if A.IsEmpty then
    Exit;

  // Split string with a separator
  A := 'var=expr';
  if AnsiSplit(A, '=', L, R) then
    Writeln('Splitted to: "', L.ToString, '" "', R.ToString, '"');

  // Check string for prefix and postfix
  A := 'AAA BBB';
  if A.StartsWith('AAA') then
    Writeln('A sarts with AAA');
  if A.EndsWith('BBB') then
    Writeln('A ends with BBB');
```

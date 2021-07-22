unit UCalcProcessor;

interface

uses
  Windows, SysUtils;

type
  TCalcProcessor = class
  public
    class function Add(X, Y: Double): Double;
    class function Subtract(X, Y: Double): Double;
    class function Mult(X, Y: Double): Double;
    class function Divide(X, Y: Double): Double;
  end;

implementation

{ TCalcProcessor }

class function TCalcProcessor.Add(X, Y: Double): Double;
begin
  Result := X + Y;
end;

class function TCalcProcessor.Subtract(X, Y: Double): Double;
begin
  Result := X - Y;
end;

class function TCalcProcessor.Mult(X, Y: Double): Double;
begin
  Result := X * Y;
end;

class function TCalcProcessor.Divide(X, Y: Double): Double;
begin
  Result := X / Y;
end;

end.

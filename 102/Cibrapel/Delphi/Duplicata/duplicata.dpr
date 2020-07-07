program duplicata;

uses
  Forms,
  unitImprime in 'unitImprime.pas' {formImprime};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformImprime, formImprime);
  Application.Run;
end.

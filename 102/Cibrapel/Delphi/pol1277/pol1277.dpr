program pol1277;

uses
  Forms,
  aparas in 'aparas.pas' {frmAparas};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmAparas, frmAparas);
  Application.Run;
end.

program pgi1317;

uses
  Forms,
  imprimir in 'imprimir.pas' {frmNota};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmNota, frmNota);
  Application.Run;
end.

program PGI1024;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  Pesq_item in 'Pesq_item.pas' {frmPesq_item_padrao},
  uDuplicidade in 'uDuplicidade.pas' {frmDuplicidade},
  uDimensional in 'uDimensional.pas' {frmDimensional},
  uVersao in 'U:\Plugin\Fontes\uVersao.pas',
  uConexao in '..\..\..\uConexao.pas' {dmConexao: TDataModule},
  uFuncoes in '..\..\..\uFuncoes.pas',
  uAguarde in '..\..\..\uAguarde.pas' {frmAguarde};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmConexao, dmConexao);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.

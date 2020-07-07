unit uDuplicidade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, StdCtrls, cxButtons, ExtCtrls,
  cxControls, cxContainer, cxEdit, cxLabel;

type
  TfrmDuplicidade = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cxButton1: TcxButton;
    lblCodIitem: TcxLabel;
    lblNumContagem: TcxLabel;
    lblLocalFab: TcxLabel;
    lblNumFolha: TcxLabel;
    lblCodUsuario: TcxLabel;
    Label7: TLabel;
    lblSit: TcxLabel;
    procedure cxButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDuplicidade: TfrmDuplicidade;

implementation

uses uPrincipal;

{$R *.dfm}

procedure TfrmDuplicidade.cxButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDuplicidade.FormShow(Sender: TObject);
begin
  lblCodIitem.Caption := frmPrincipal.qryGen.Fields[0].AsString;
  lblNumContagem.Caption := frmPrincipal.qryGen.Fields[1].AsString;
  lblLocalFab.Caption := frmPrincipal.qryGen.Fields[2].AsString;
  lblNumFolha.Caption := frmPrincipal.qryGen.Fields[3].AsString;
  lblCodUsuario.Caption := frmPrincipal.qryGen.Fields[4].AsString;
  lblSit.Caption := frmPrincipal.qryGen.Fields[5].AsString;
end;

end.

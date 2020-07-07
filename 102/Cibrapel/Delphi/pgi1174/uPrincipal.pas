unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QRCtrls, QuickRpt, ExtCtrls, StdCtrls, DB, ADODB;

type
  TForm1 = class(TForm)
    qpRel: TQuickRep;
    qryRel: TADOQuery;
    qryRelcod_nat_oper: TIntegerField;
    qryRelden_nat_oper: TStringField;
    qryRelcod_fiscal: TIntegerField;
    qryRelie_sub_trib: TStringField;
    qryRelcod_cliente: TStringField;
    qryRelnom_cliente: TStringField;
    qryRelendereco: TStringField;
    qryRelbairro: TStringField;
    qryRelcidade: TStringField;
    qryRelestado: TStringField;
    qryRelcep: TStringField;
    qryRelfone: TStringField;
    qryRelend_cobranca: TStringField;
    qryRelnum_cnpj: TStringField;
    qryRelinsc_estadual: TStringField;
    qryRelnum_docum: TStringField;
    qryRelval_docum: TFloatField;
    qryReldat_emis: TDateTimeField;
    qryReldat_vencto: TDateTimeField;
    qryRelnum_nota: TIntegerField;
    qryReldesconto_de: TFloatField;
    qryRelpagto_ate: TDateTimeField;
    qryRelval_extenso1: TStringField;
    qryRelval_extenso2: TStringField;
    DetailBand1: TQRBand;
    QRShape6: TQRShape;
    QRLabel1: TQRLabel;
    QRShape2: TQRShape;
    QRShape3: TQRShape;
    QRShape7: TQRShape;
    QRShape8: TQRShape;
    QRLabel2: TQRLabel;
    QRShape9: TQRShape;
    QRShape10: TQRShape;
    QRShape11: TQRShape;
    QRShape1: TQRShape;
    QRShape12: TQRShape;
    QRShape13: TQRShape;
    QRShape14: TQRShape;
    QRShape4: TQRShape;
    QRShape15: TQRShape;
    QRShape16: TQRShape;
    QRShape17: TQRShape;
    QRShape18: TQRShape;
    QRShape19: TQRShape;
    QRShape20: TQRShape;
    QRShape21: TQRShape;
    QRShape22: TQRShape;
    QRShape23: TQRShape;
    QRShape24: TQRShape;
    QRShape25: TQRShape;
    QRShape5: TQRShape;
    QRShape26: TQRShape;
    QRLabel4: TQRLabel;
    QRShape27: TQRShape;
    QRLabel3: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRLabel8: TQRLabel;
    QRLabel9: TQRLabel;
    QRLabel10: TQRLabel;
    QRLabel11: TQRLabel;
    QRLabel12: TQRLabel;
    QRLabel13: TQRLabel;
    QRLabel14: TQRLabel;
    QRLabel15: TQRLabel;
    QRLabel16: TQRLabel;
    QRLabel17: TQRLabel;
    QRLabel18: TQRLabel;
    QRLabel19: TQRLabel;
    QRLabel20: TQRLabel;
    QRLabel21: TQRLabel;
    QRLabel22: TQRLabel;
    QRLabel23: TQRLabel;
    QRLabel24: TQRLabel;
    QRLabel25: TQRLabel;
    QRLabel26: TQRLabel;
    QRLabel27: TQRLabel;
    QRLabel28: TQRLabel;
    QRLabel29: TQRLabel;
    QRLabel30: TQRLabel;
    QRLabel5: TQRLabel;
    imgLogo: TQRImage;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRDBText5: TQRDBText;
    QRDBText6: TQRDBText;
    QRDBText7: TQRDBText;
    QRDBText8: TQRDBText;
    QRDBText9: TQRDBText;
    QRDBText10: TQRDBText;
    QRDBText11: TQRDBText;
    QRDBText12: TQRDBText;
    QRDBText13: TQRDBText;
    QRDBText14: TQRDBText;
    QRDBText15: TQRDBText;
    QRDBText16: TQRDBText;
    QRDBText17: TQRDBText;
    QRDBText18: TQRDBText;
    QRLabel31: TQRLabel;
    QRLabel32: TQRLabel;
    QRMemo1: TQRMemo;
    QRDBText19: TQRDBText;
    QRDBText20: TQRDBText;
    QRDBText21: TQRDBText;
    QRLabel33: TQRLabel;
    QRLabel34: TQRLabel;
    QRLabel35: TQRLabel;
    conexao: TADOConnection;
    QRDBText22: TQRDBText;
    procedure FormShow(Sender: TObject);
    procedure qpRelAfterPrint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormShow(Sender: TObject);
begin
  qryRel.Close;
  qryRel.SQL.Text:= ' select cod_nat_oper, den_nat_oper, cod_fiscal, ie_sub_trib, cod_cliente,  '+
                    ' nom_cliente, endereco , bairro, cidade, estado , cep , fone,end_cobranca, '+
                    ' num_cnpj, insc_estadual , num_docum , val_docum , dat_emis, dat_vencto, '+
                    ' num_nota , desconto_de , pagto_ate , val_extenso1 , val_extenso2 '+
                    ' from  duplicata_885 order by num_docum ';
  qryRel.Open;
  qpRel.Preview;
  close;
end;

procedure TForm1.qpRelAfterPrint(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
var linha,cCaminho : string;
    arq   : TextFile;
begin
  //verifico se o arquivo do banco existe
  cCaminho :=  ExtractFilePath(Application.ExeName)+'Banco.ini';
  if FileExists(cCaminho) then
    begin
      try
        AssignFile(arq,cCaminho);
        Reset(arq);
        ReadLn(arq,linha);
        CloseFile(arq);
        conexao.Close;
        conexao.ConnectionString := linha;
        conexao.Open;
      except
        ShowMessage('Erro na conexão com a base de dados!');
      end;
    end;
end;    
end.

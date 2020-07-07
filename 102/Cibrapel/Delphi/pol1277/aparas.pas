unit aparas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, QuickRpt, ExtCtrls;

type
  TfrmAparas = class(TForm)
    banco: TADOConnection;
    sqlAparas: TADOQuery;
    QRAparas: TQuickRep;
    TitleBand1: TQRBand;
    QRShape1: TQRShape;
    QRImage1: TQRImage;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    QRShape2: TQRShape;
    QRShape3: TQRShape;
    sqlPeriodo: TADOQuery;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRLabel3: TQRLabel;
    QRGroup1: TQRGroup;
    QRBand2: TQRBand;
    QRBand3: TQRBand;
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
    QRDBText19: TQRDBText;
    sqlAparascod_empresa: TStringField;
    sqlAparascod_fornecedor: TStringField;
    sqlAparasnum_aviso_rec: TIntegerField;
    sqlAparasnum_seq_ar: TIntegerField;
    sqlAparasdat_entrada_nf: TDateTimeField;
    sqlAparasnum_nf: TIntegerField;
    sqlAparascod_item: TStringField;
    sqlAparasqtd_declarad_nf: TBCDField;
    sqlAparaspre_unit_nf: TBCDField;
    sqlAparasval_liquido_item: TBCDField;
    sqlAparaspeso_balanca: TBCDField;
    sqlAparaspreco_cotacao: TBCDField;
    sqlAparasval_cotacao: TBCDField;
    sqlAparasdif_qtd: TBCDField;
    sqlAparasden_status: TStringField;
    sqlAparasusuario: TStringField;
    sqlAparasden_empresa: TStringField;
    sqlAparasraz_social: TStringField;
    sqlAparasden_item_reduz: TStringField;
    QRLabel18: TQRLabel;
    QRShape6: TQRShape;
    QRShape7: TQRShape;
    QRShape8: TQRShape;
    QRShape9: TQRShape;
    QRShape10: TQRShape;
    QRShape11: TQRShape;
    QRShape12: TQRShape;
    QRShape13: TQRShape;
    QRShape14: TQRShape;
    QRShape15: TQRShape;
    QRShape18: TQRShape;
    QRShape4: TQRShape;
    QRLabel15: TQRLabel;
    QRDBText5: TQRDBText;
    QRDBText6: TQRDBText;
    QRLabel4: TQRLabel;
    QRLabel5: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRLabel9: TQRLabel;
    QRLabel10: TQRLabel;
    QRLabel11: TQRLabel;
    QRLabel12: TQRLabel;
    QRLabel13: TQRLabel;
    QRLabel14: TQRLabel;
    QRLabel17: TQRLabel;
    QRLabel16: TQRLabel;
    QRShape5: TQRShape;
    QRBand1: TQRBand;
    QRExpr1: TQRExpr;
    QRExpr2: TQRExpr;
    QRLabel8: TQRLabel;
    QRExpr3: TQRExpr;
    QRExpr4: TQRExpr;
    QRExpr5: TQRExpr;
    QRExpr6: TQRExpr;
    sqlPeriododat_ini: TDateTimeField;
    sqlPeriododat_fim: TDateTimeField;
    procedure FormCreate(Sender: TObject);
    function conectaBanco: String;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAparas: TfrmAparas;
  sMsg, sCaminho, sConexao, sArqBanco, sUsuario, sCodempresa: String;

implementation

{$R *.dfm}

procedure TfrmAparas.FormCreate(Sender: TObject);
var
   sQuery: String;
begin

   sqlAparas.Close;
   sqlPeriodo.Close;
   
   sCodempresa := ParamStr(1);
   sUsuario := ParamStr(2);

   sCaminho := ExtractFilePath(Application.ExeName);
   sArqBanco := 'Banco.ini';

   sConexao := conectaBanco;

   if sConexao = '' then
      begin
         sMsg := 'Naõ foi ler o arquivo ' + sArqBanco + ' no caminho ' + sCaminho;
         MessageDlg(sMsg,mtWarning,[mbOK],1);
      end
   else
      begin
         Banco.ConnectionString := sConexao;

         sQuery := sqlPeriodo.SQL.Text
           + ' and cod_empresa = ' + QuotedStr(sCodempresa)
           + ' and usuario = ' + QuotedStr(sUsuario);

         sqlPeriodo.SQL.Text :=  sQuery;
         sqlPeriodo.Open;

         sQuery := sqlAparas.SQL.GetText
           + ' and relat_pol1277_885.cod_empresa = ' + QuotedStr(sCodempresa)
           + ' and relat_pol1277_885.usuario = ' + QuotedStr(sUsuario);

         sqlAparas.SQL.Text :=  sQuery;
         sqlAparas.Open;
         if sqlAparas.IsEmpty then
            begin
               sMsg := 'Não há dados a serem impresos ' ;
               MessageDlg(sMsg,mtWarning,[mbOK],1);
            end
         else
            QRAparas.Preview;
      end;

   Close;

end;

function TfrmAparas.conectaBanco: String;
var
   sLinha, sArquivo: String;
   fArq: TextFile;
begin

   sArquivo := sCaminho + sArqBanco;
   
   //verifico se o arquivo do banco existe

   if not FileExists(sArquivo) then
      conectaBanco := ''
   else
      begin
         AssignFile(fArq,sArquivo);
         Reset(fArq);
         ReadLn(fArq, sLinha);
         CloseFile(fArq);
         conectaBanco := sLinha;
      end;

end;

procedure TfrmAparas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Application.Terminate;
end;

end.

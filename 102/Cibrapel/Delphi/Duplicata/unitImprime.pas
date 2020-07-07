unit unitImprime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QuickRpt, ExtCtrls, QRCtrls, DB, ADODB;

type
  TformImprime = class(TForm)
    qrDuplicata: TQuickRep;
    Banco: TADOConnection;
    queryDupl: TADOQuery;
    bandaDetalhe: TQRSubDetail;
    QRImage1: TQRImage;
    QRLabel1: TQRLabel;
    QRLabel5: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel2: TQRLabel;
    QRShape1: TQRShape;
    QRShape2: TQRShape;
    QRLabel3: TQRLabel;
    QRLabel8: TQRLabel;
    QRShape3: TQRShape;
    QRDBText1: TQRDBText;
    queryDuplcod_nat_oper: TIntegerField;
    queryDuplden_nat_oper: TStringField;
    queryDuplcod_fiscal: TIntegerField;
    queryDuplie_sub_trib: TStringField;
    queryDuplcod_cliente: TStringField;
    queryDuplnom_cliente: TStringField;
    queryDuplendereco: TStringField;
    queryDuplbairro: TStringField;
    queryDuplcidade: TStringField;
    queryDuplestado: TStringField;
    queryDuplcep: TStringField;
    queryDuplfone: TStringField;
    queryDuplend_cobranca: TStringField;
    queryDuplnum_cnpj: TStringField;
    queryDuplinsc_estadual: TStringField;
    queryDuplnum_docum: TStringField;
    queryDuplval_docum: TBCDField;
    queryDupldat_emis: TDateTimeField;
    queryDupldat_vencto: TDateTimeField;
    queryDuplnum_nota: TIntegerField;
    queryDupldesconto_de: TBCDField;
    queryDuplpagto_ate: TDateTimeField;
    queryDuplval_extenso1: TStringField;
    queryDuplval_extenso2: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formImprime: TformImprime;

implementation

{$R *.dfm}

procedure TformImprime.FormCreate(Sender: TObject);
begin
   queryDupl.Active := true;
   qrDuplicata.Preview;
   Close;
end;

procedure TformImprime.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Application.Terminate;
end;

end.

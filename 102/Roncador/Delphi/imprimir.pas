unit imprimir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QuickRpt, ExtCtrls, QRCtrls, dxmdaset;

type
  TfrmNota = class(TForm)
    qrImprimir: TQuickRep;
    bandaTitulo: TQRBand;
    QRShape1: TQRShape;
    QRLabel1: TQRLabel;
    QRLabel3: TQRLabel;
    QRLabel4: TQRLabel;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRLabel2: TQRLabel;
    QRDBText5: TQRDBText;
    QRLabel5: TQRLabel;
    QRDBText6: TQRDBText;
    QRLabel6: TQRLabel;
    QRDBText7: TQRDBText;
    QRShape2: TQRShape;
    QRLabel7: TQRLabel;
    QRDBText8: TQRDBText;
    QRDBText9: TQRDBText;
    QRLabel8: TQRLabel;
    QRDBText10: TQRDBText;
    QRLabel9: TQRLabel;
    QRDBText11: TQRDBText;
    QRLabel10: TQRLabel;
    QRDBText12: TQRDBText;
    QRLabel11: TQRLabel;
    QRDBText13: TQRDBText;
    QRLabel12: TQRLabel;
    QRDBText14: TQRDBText;
    QRSubDetail1: TQRSubDetail;
    GroupHeaderBand1: TQRBand;
    QRLabel13: TQRLabel;
    QRLabel14: TQRLabel;
    QRLabel15: TQRLabel;
    QRLabel16: TQRLabel;
    QRShape3: TQRShape;
    QRDBText15: TQRDBText;
    QRDBText16: TQRDBText;
    QRDBText17: TQRDBText;
    QRDBText18: TQRDBText;
    QRShape4: TQRShape;
    QRShape5: TQRShape;
    QRLabel17: TQRLabel;
    QRLabel18: TQRLabel;
    QRLabel19: TQRLabel;
    QRDBText19: TQRDBText;
    QRDBText20: TQRDBText;
    QRShape6: TQRShape;
    QRLabel20: TQRLabel;
    QRLabel21: TQRLabel;
    QRShape9: TQRShape;
    QRShape8: TQRShape;
    QRDBText21: TQRDBText;
    QRShape7: TQRShape;
    QRShape10: TQRShape;
    QRDBText22: TQRDBText;
    QRDBText23: TQRDBText;
    QRShape12: TQRShape;
    QRLabel24: TQRLabel;
    QRShape11: TQRShape;
    QRBand1: TQRBand;
    QRLabel22: TQRLabel;
    QRDBText24: TQRDBText;
    QRShape13: TQRShape;
    nota: TdxMemData;
    ads: TdxMemData;
    notanum_nota: TStringField;
    notacod_orig: TStringField;
    notaraz_orig: TStringField;
    notaend_orig: TStringField;
    notacid_orig: TStringField;
    notaest_orig: TStringField;
    notacep_orig: TStringField;
    notacod_dest: TStringField;
    notaraz_dest: TStringField;
    notacid_dest: TStringField;
    notaest_dest: TStringField;
    notacep_dest: TStringField;
    notacgc_dest: TStringField;
    notadat_emis: TStringField;
    notadat_venc: TStringField;
    notacrc_cont: TStringField;
    notaval_nota: TFloatField;
    adsnum_ad: TIntegerField;
    adscod_desp: TIntegerField;
    adsnom_des: TStringField;
    adsval_ad: TFloatField;
    notacgc_orig: TStringField;
    notaend_dest: TStringField;
    adsnum_docum: TIntegerField;
    QRLabel23: TQRLabel;
    QRDBText25: TQRDBText;
    QRLabel25: TQRLabel;
    QRLabel26: TQRLabel;
    notaNOM_CONT: TStringField;
    QRShape14: TQRShape;
    QRShape15: TQRShape;
    QRShape16: TQRShape;
    QRShape17: TQRShape;
    QRShape18: TQRShape;
    QRShape19: TQRShape;
    QRShape20: TQRShape;
    QRShape21: TQRShape;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }

    function checaArquivos(): Boolean;
    function leNota(): Boolean;
    function leAds(): Boolean;


  public
    { Public declarations }
  end;

var
  frmNota: TfrmNota;
  sMsg, sCaminho: String;

implementation

{$R *.dfm}

procedure TfrmNota.FormCreate(Sender: TObject);

begin

   sCaminho := ExtractFilePath(Application.ExeName);

   if checaArquivos() then
      if leNota() then
         if leAds() then
            qrImprimir.Preview;
   Close;

end;

procedure TfrmNota.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Application.Terminate;
end;

function TfrmNota.checaArquivos: Boolean;
var
   sArquivo: String;
   bRet: Boolean;
begin

   bRet := True;
   sArquivo := sCaminho + 'nota.txt';

   if not FileExists(sArquivo) then
      begin
         sMsg := 'Não foi possivel localizar o arquivo: '+sArquivo;
         MessageDlg(sMsg,mtWarning,[mbOK],1);
         bRet := False;
      end
   else
      begin
         sArquivo := sCaminho + 'ads.txt';
         if not FileExists(sArquivo) then
            begin
               sMsg := 'Não foi possivel localizar o arquivo: '+sArquivo;
               MessageDlg(sMsg,mtWarning,[mbOK],1);
               bRet := False;
            end
      end;

   Result := bRet;

end;

function TfrmNota.leNota: Boolean;
var
   f: TextFile;
   linha: String;
   listastring: TStringList;
   bRet: Boolean;
begin

   bRet := False;

   try
       listastring := TStringList.Create;
       AssignFile(f, sCaminho+ 'nota.txt');
       Reset(f);
       Readln(f,linha);

       nota.Open;
       nota.Insert;

       listastring.Delimiter := ';';
       listastring.QuoteChar := '|';
       listastring.DelimitedText := linha;
       notanum_nota.AsString := listastring[0];
       notacod_orig.AsString := listastring[1];
       notaraz_orig.AsString := listastring[2];
       notaend_orig.AsString := listastring[3];
       notacid_orig.AsString := listastring[4];
       notaest_orig.AsString := listastring[5];
       notacep_orig.AsString := listastring[6];
       notacgc_orig.AsString := listastring[7];
       notacod_dest.AsString := listastring[8];
       notaraz_dest.AsString := listastring[9];
       notaend_dest.AsString := listastring[10];
       notacid_dest.AsString := listastring[11];
       notaest_dest.AsString := listastring[12];
       notacep_dest.AsString := listastring[13];
       notacgc_dest.AsString := listastring[14];
       notadat_emis.AsString := listastring[15];
       notadat_venc.AsString := listastring[16];
       notanom_cont.AsString := listastring[17];
       notacrc_cont.AsString := listastring[18];
       notaval_nota.AsFloat := StrToFloat(listastring[19]);

       nota.Post;
       bRet := True;
   Except on e : Exception do
       ShowMessage('Erro na leitura do arquivo nota.txt - '+e.Message);
   end;

   Result := bRet;

end;

function TfrmNota.leAds: Boolean;
var
   f: TextFile;
   linha: String;
   listastring: TStringList;
   bRet: Boolean;
begin

   bRet := False;

   try
       listastring := TStringList.Create;
       AssignFile(f, sCaminho+ 'ads.txt');
       Reset(f);
       ads.Open;

       While not eof(f) do
         begin
           Readln(f,linha);
           ads.Insert;
           listastring.Delimiter := ';';
           listastring.QuoteChar := '|';
           listastring.DelimitedText := linha;
           adsnum_docum.AsString := listastring[0];
           adsnum_ad.AsString := listastring[1];
           adscod_desp.AsString := listastring[2];
           adsnom_des.AsString := listastring[3];
           adsval_ad.AsFloat := StrToFloat(listastring[4]);
           ads.Post;
         End;
       listastring.Free;
       Closefile(f);
       bRet := True;
   Except on e : Exception do
         ShowMessage('Erro na leitura do arquivo ads.txt - '+e.Message);
   end;

   Result := bRet;

end;



end.

unit Uprincipal;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;


type
 TEtiqueta = Record
    id_registro : String[10];
    cod_empresa :String[2];
    den_empresa : String[100];
    num_om : String[10];
    num_pedido : String[10];
    num_seq: String[10];
    cod_item : String[30];
    den_item:String[100];
    peso_unit : String[10];
    item_cliente :String[30];
    cod_cliente :String[15];
    nom_cliente :String[100];
    num_lote : String[15];
    qtd_lote : String[10];
    qtd_etiqueta : String[10];
    peso_item : String[10];
    cod_embal : String[15];
    peso_embal : String[10];
    dat_user : String[50];
    ies_impressao :String[1];
    qtd_embal : String[10];
    peso_bruto : String[10];
  end;

  TfrmEtiqueta = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure imprimeEtiqueta(etiqueta : TEtiqueta);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEtiqueta: TfrmEtiqueta;
  num_om :String;

implementation

uses uConexao, uFuncoes, DB;

{$R *.dfm}

procedure TfrmEtiqueta.FormCreate(Sender: TObject);
var etiqueta: TEtiqueta;
    i:integer;
    qtde_lote : integer;
begin
  cod_empresa   := ParamStr(1);
  num_om        := ParamStr(2);

  //cod_empresa   := '01';
  //num_om        := '32';

  if(not empty(cod_empresa) and not empty(num_om))then
    begin
      dmConexao.qryGenInformix.Close;
      dmConexao.qryGenInformix.SQL.Text := ' select id_registro ,cod_empresa , den_empresa, num_om, num_pedido, '+
                                           '   num_seq , cod_item, den_item, peso_unit, item_cliente,cod_cliente ,'+
                                           '   nom_cliente ,num_lote ,qtd_lote ,qtd_etiqueta ,peso_item ,cod_embal ,'+
                                           '   peso_embal ,dat_user ,ies_impressao ,qtd_embal,(peso_item + peso_embal) peso_bruto '+
                                           ' from etiqueta_912 where cod_empresa = '+aspas(cod_empresa)+' and num_om ='+num_om;
      dmConexao.qryGenInformix.Open;

      if(not dmConexao.qryGenInformix.IsEmpty)then
        begin
          etiqueta.id_registro   := dmConexao.qryGenInformix.FieldByName('id_registro').AsString;
          etiqueta.cod_empresa   := dmConexao.qryGenInformix.FieldByName('cod_empresa').AsString;
          etiqueta.den_empresa   := dmConexao.qryGenInformix.FieldByName('den_empresa').AsString;
          etiqueta.num_om        := dmConexao.qryGenInformix.FieldByName('num_om').AsString;
          etiqueta.num_pedido    := dmConexao.qryGenInformix.FieldByName('num_pedido').AsString;
          etiqueta.num_seq       := dmConexao.qryGenInformix.FieldByName('num_seq').AsString;
          etiqueta.cod_item      := dmConexao.qryGenInformix.FieldByName('cod_item').AsString;
          etiqueta.den_item      := dmConexao.qryGenInformix.FieldByName('den_item').AsString;
          etiqueta.peso_unit     := dmConexao.qryGenInformix.FieldByName('peso_unit').AsString;
          etiqueta.item_cliente  := dmConexao.qryGenInformix.FieldByName('item_cliente').AsString;
          etiqueta.nom_cliente   := dmConexao.qryGenInformix.FieldByName('nom_cliente').AsString;
          etiqueta.num_lote      := dmConexao.qryGenInformix.FieldByName('num_lote').AsString;
          etiqueta.qtd_lote      := dmConexao.qryGenInformix.FieldByName('qtd_lote').AsString;
          etiqueta.qtd_etiqueta  := dmConexao.qryGenInformix.FieldByName('qtd_etiqueta').AsString;
          etiqueta.peso_item     := dmConexao.qryGenInformix.FieldByName('peso_item').AsString;
          etiqueta.cod_embal     := dmConexao.qryGenInformix.FieldByName('cod_embal').AsString;
          etiqueta.peso_embal    := dmConexao.qryGenInformix.FieldByName('peso_embal').AsString;
          etiqueta.dat_user      := dmConexao.qryGenInformix.FieldByName('dat_user').AsString;
          etiqueta.ies_impressao := dmConexao.qryGenInformix.FieldByName('ies_impressao').AsString;
          etiqueta.qtd_embal     := dmConexao.qryGenInformix.FieldByName('qtd_embal').AsString;
          etiqueta.peso_bruto    := dmConexao.qryGenInformix.FieldByName('peso_bruto').AsString;

          qtde_lote := 0;

          for i:=1 to StrToInt(etiqueta.qtd_etiqueta) do
            begin

              if(i=StrToInt(etiqueta.qtd_etiqueta))then // caso seja a ultima impressão verifica se tem algum resto na qtde e envia todo o restante
                begin
                 etiqueta.qtd_embal := IntToStr( StrToInt(etiqueta.qtd_lote) - qtde_lote);
                end;

              qtde_lote := qtde_lote +  StrToInt(etiqueta.qtd_embal);

              //ShowMessage(IntToStr(i)+' qtde embal: '+etiqueta.qtd_embal);
              imprimeEtiqueta(etiqueta);
            end;
        end;

    end ;

  Application.Terminate;
end;

procedure TfrmEtiqueta.imprimeEtiqueta(etiqueta: TEtiqueta);
var   F: textfile;
begin
  // realiza a impressão da etiqueta
  AssignFile(F,'LPT1');
  Rewrite(F);
  Writeln(F,'^XA');
  Writeln(F,'^MMT');
  Writeln(F,'^PW703');
  Writeln(F,'^LL0839');
  Writeln(F,'^LS0');
  Writeln(F,'^FT320,128^XG000.GRF,1,1^FS');
  Writeln(F,'^FT128,128^XG001.GRF,1,1^FS');
  Writeln(F,'^FT32,160^XG002.GRF,1,1^FS');
  Writeln(F,'^FT320,160^XG003.GRF,1,1^FS');
  Writeln(F,'^FT32,256^XG004.GRF,1,1^FS');
  Writeln(F,'^FT32,448^XG005.GRF,1,1^FS');
  Writeln(F,'^FT32,384^XG006.GRF,1,1^FS');
  Writeln(F,'^FT32,768^XG007.GRF,1,1^FS');
  Writeln(F,'^FT32,544^XG008.GRF,1,1^FS');
  Writeln(F,'^FT224,576^XG009.GRF,1,1^FS');
  Writeln(F,'^FT480,640^XG010.GRF,1,1^FS');
  Writeln(F,'^FT64,640^XG011.GRF,1,1^FS');
  Writeln(F,'^FT256,640^XG012.GRF,1,1^FS');
  Writeln(F,'^FO667,41^GB0,754,1^FS');
  Writeln(F,'^FO33,317^GB632,0,3^FS');
  Writeln(F,'^FO34,224^GB632,0,2^FS');
  Writeln(F,'^FO34,686^GB632,0,3^FS');
  Writeln(F,'^FO34,591^GB633,0,3^FS');
  Writeln(F,'^FO34,496^GB633,0,3^FS');
  Writeln(F,'^FO33,411^GB632,0,2^FS');
  Writeln(F,'^FO34,128^GB633,0,3^FS');
  Writeln(F,'^FO33,793^GB632,0,1^FS');
  Writeln(F,'^FO32,40^GB0,754,1^FS');
  Writeln(F,'^FO34,40^GB633,0,2^FS');
  Writeln(F,'^FT47,196^A0N,28,28^FH\^FD'+etiqueta.cod_cliente+'^FS');
  Writeln(F,'^FT316,196^A0N,28,28^FH\^FD'+etiqueta.dat_user+'^FS');
  Writeln(F,'^FO423,593^GB0,94,3^FS');
  Writeln(F,'^FO222,593^GB0,94,3^FS');
  Writeln(F,'^FO221,500^GB0,94,3^FS');
  Writeln(F,'^FO299,129^GB0,94,3^FS');
  Writeln(F,'^FT451,672^A0N,28,28^FH\^FD'+etiqueta.peso_bruto+'^FS');
  Writeln(F,'^FT248,672^A0N,28,28^FH\^FD'+etiqueta.peso_embal+'^FS');
  Writeln(F,'^FT47,295^A0N,28,28^FH\^FD'+etiqueta.num_lote+'^FS');
  Writeln(F,'^FT52,672^A0N,28,28^FH\^FD'+etiqueta.peso_item+'^FS');
  Writeln(F,'^FT47,580^A0N,28,28^FH\^FD'+etiqueta.peso_unit+'^FS');
  Writeln(F,'^FT47,478^A0N,28,28^FH\^FD'+etiqueta.den_item+'^FS');
  Writeln(F,'^FT247,580^A0N,28,28^FH\^FD'+etiqueta.qtd_etiqueta+'^FS');
  Writeln(F,'^FT47,393^A0N,28,28^FH\^FD'+etiqueta.cod_item+'^FS');
  Writeln(F,'^BY1,3,87^FT423,588^BCN,,N,N');
  Writeln(F,'^FD>:'+etiqueta.qtd_embal+'^FS');
  Writeln(F,'^BY1,3,82^FT349,406^BCN,,N,N');
  Writeln(F,'^FD>:'+etiqueta.cod_item+'^FS');
  Writeln(F,'^BY1,3,78^FT349,309^BCN,,N,N');
  Writeln(F,'^FD>:'+etiqueta.num_lote+'^FS');
  Writeln(F,'^PQ1,0,1,Y^XZ');
  Writeln(F,'^XA^ID000.GRF^FS^XZ');
  Writeln(F,'^XA^ID001.GRF^FS^XZ');
  Writeln(F,'^XA^ID002.GRF^FS^XZ');
  Writeln(F,'^XA^ID003.GRF^FS^XZ');
  Writeln(F,'^XA^ID004.GRF^FS^XZ');
  Writeln(F,'^XA^ID005.GRF^FS^XZ');
  Writeln(F,'^XA^ID006.GRF^FS^XZ');
  Writeln(F,'^XA^ID007.GRF^FS^XZ');
  Writeln(F,'^XA^ID008.GRF^FS^XZ');
  Writeln(F,'^XA^ID009.GRF^FS^XZ');
  Writeln(F,'^XA^ID010.GRF^FS^XZ');
  Writeln(F,'^XA^ID011.GRF^FS^XZ');
  Writeln(F,'^XA^ID012.GRF^FS^XZ');
  CloseFile(F);
end;

end.

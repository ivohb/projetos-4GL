unit te;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QRCtrls, QuickRpt, ExtCtrls, DB, dxmdaset,
  cxLookAndFeelPainters, StdCtrls, cxButtons;

type
  TForm1 = class(TForm)
    relatorio: TQuickRep;
    PageHeaderBand1: TQRBand;
    QRLabel1: TQRLabel;
    QRSubDetail1: TQRSubDetail;
    GroupHeaderBand1: TQRBand;
    QRLabel2: TQRLabel;
    QRLabel3: TQRLabel;
    QRLabel4: TQRLabel;
    nome: TQRDBText;
    idade: TQRDBText;
    sexo: TQRDBText;
    dados: TdxMemData;
    dadosnome: TStringField;
    dadosidade: TIntegerField;
    dadossexo: TStringField;
    cxButton1: TcxButton;
    procedure QRSubDetail1BeforePrint(Sender: TQRCustomBand;
      var PrintBand: Boolean);
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     cor:boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.QRSubDetail1BeforePrint(Sender: TQRCustomBand;
  var PrintBand: Boolean);
begin
  if(cor) then
     sender.Color := clGray
  else
    sender.Color := clWindow;
end;

procedure TForm1.cxButton1Click(Sender: TObject);
var 
   f:TextFile; 
   linha:String;
   listastring: TStringList ;
begin
  if(FileExists(ExtractFilePath(Application.ExeName)+ 'teste.txt')) then
     begin
       try
       listastring := TStringList.Create;
       AssignFile(f, ExtractFilePath(Application.ExeName)+ 'teste.txt');
       Reset(f);
       dados.Open;
       While not eof(f) do
         begin
           Readln(f,linha);

           dados.Insert;

           listastring.Delimiter := ' ';
           listastring.QuoteChar := '|';
           listastring.DelimitedText := linha;
           dadosnome.AsString := listastring[0];
           dadosidade.AsString := listastring[1];
           dadossexo.AsString := listastring[2];
           dados.Post;
         End;
       listastring.Free;
       Closefile(f);

       relatorio.Preview;
       Except on e : Exception do
         ShowMessage('Erro no processo de imrpessão com msg:'+e.Message);
       end;
     end
   else
     Application.MessageBox('teste.txt não foi encontrado!','Verifique arquivo',MB_OK+MB_ICONERROR);
end;

end.

unit Pesq_item;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxPSGlbl, dxPSUtl, dxPSEngn,
  dxPrnPg, dxBkgnd, dxWrap, dxPrnDev, dxPSCompsProvider, dxPSFillPatterns,
  dxPSEdgePatterns, ADODB, dxPSCore, dxPScxGridLnk, dxStatusBar,
  cxContainer, cxTextEdit, StdCtrls, ExtCtrls, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, cxMaskEdit,
  cxDropDownEdit, ImgList, cxButtonEdit, cxCheckBox, cxImageComboBox,
  cxDBLookupComboBox, cxCurrencyEdit;

type
  TfrmPesq_item_padrao = class(TForm)
    ToolBar1: TToolBar;
    btnPesquisar: TToolButton;
    btnConfirmar: TToolButton;
    btnVoltar: TToolButton;
    cxGridPesq: TcxGrid;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3Level1: TcxGridLevel;
    Panel1: TPanel;
    Label2: TLabel;
    dxStatusBarItem: TdxStatusBar;
    dtsItem: TDataSource;
    edtGrup: TcxTextEdit;
    qryItem: TADOQuery;
    edtitem: TcxTextEdit;
    Label1: TLabel;
    edtDesc: TcxTextEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtLocal: TcxTextEdit;
    edtfamlia: TcxTextEdit;
    Label5: TLabel;
    cxGrid3DBTableView1den_item: TcxGridDBColumn;
    qryItemcod_item: TStringField;
    qryItemden_item: TStringField;
    qryItemcod_unid_med: TStringField;
    cxGrid3DBTableView1cod_item: TcxGridDBColumn;
    cxGrid3DBTableView1cod_unid_med: TcxGridDBColumn;
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure edtGrupKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure qryItemAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPesq_item_padrao: TfrmPesq_item_padrao;

implementation

uses  uConexao, uPrincipal, uFuncoes;

{$R *.dfm}

procedure TfrmPesq_item_padrao.btnPesquisarClick(Sender: TObject);
  var cSql_var : string; 
begin
  if qryItem.Active then
    qryItem.next;
  qryItem.Close;


  cSql_var := ' select cod_item,den_item,cod_unid_med from item '
           +  ' 	where cod_empresa = ' + QuotedStr(cod_empresa)
           +  '   and ies_situacao <> ''C'' ';

  if not empty(edtitem.Text) then
    cSql_var := cSql_var +' and upper(cod_item) like '       + QuotedStr('%'+Trim(edtitem.Text)+'%');

  if not empty(edtDesc.Text) then
    cSql_var := cSql_var +' and upper(den_item) like '       + QuotedStr('%'+Trim(edtDesc.Text)+'%');
  
  if not empty(edtLocal.Text) then
    cSql_var := cSql_var +' and upper(cod_local_estoq) like '+ QuotedStr('%'+Trim(edtLocal.Text)+'%');

  if not empty(edtfamlia.Text) then
    cSql_var := cSql_var +' and upper(cod_familia) like '    + QuotedStr('%'+Trim(edtfamlia.Text)+'%');

  if not empty(edtGrup.Text) then
    cSql_var := cSql_var +' and upper(gru_ctr_estoq) like '    + QuotedStr('%'+Trim(edtGrup.Text)+'%');
    
  qryitem.SQL.Text := cSql_var;

  qryItem.Open;

  if qryItem.IsEmpty then
    Application.MessageBox('Não existe registro para a pesquisa informada','Mensagem',MB_ICONINFORMATION)
  else
    qryItem.First;

end;

procedure TfrmPesq_item_padrao.btnVoltarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPesq_item_padrao.edtGrupKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    btnPesquisarClick(Self);
end;

procedure TfrmPesq_item_padrao.FormShow(Sender: TObject);
begin
  if pos('|',frmPrincipal.edtItem.Text) <> 0 then
    edtitem.Text := leftAte(frmPrincipal.edtItem.Text,'|')
  else
    edtitem.Text := frmPrincipal.edtItem.Text;
  edtitem.SetFocus;
end;

procedure TfrmPesq_item_padrao.btnConfirmarClick(Sender: TObject);
begin
	ModalResult := mrok
end;

procedure TfrmPesq_item_padrao.qryItemAfterOpen(DataSet: TDataSet);
begin
  btnConfirmar.Enabled := not qryItem.IsEmpty;
end;

end.

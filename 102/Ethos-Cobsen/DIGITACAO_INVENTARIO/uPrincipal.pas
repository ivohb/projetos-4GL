unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, cxExportGrid4Link, ComCtrls, ImgList, AppEvnts,
  ToolWin, ExtCtrls, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxContainer, cxTextEdit, cxMaskEdit,
  cxSpinEdit, cxLabel, cxCurrencyEdit, cxButtonEdit, cxLookAndFeelPainters,
  StdCtrls, cxButtons, cxDropDownEdit,Registry, QuickRpt, QRCtrls, DateUtils;

type
  TfrmPrincipal = class(TForm)
    qryGen: TADOQuery;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    ApplicationEvents1: TApplicationEvents;
    ToolBar1: TToolBar;
    btnExcluir: TToolButton;
    ToolButton5: TToolButton;
    btnFechar: TToolButton;
    Panel1: TPanel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    edtContagem: TcxSpinEdit;
    cxLabel1: TcxLabel;
    edtQtd: TcxCurrencyEdit;
    edtFolha: TcxCurrencyEdit;
    cxLabel2: TcxLabel;
    edtItem: TcxButtonEdit;
    qryPesquisa: TADOQuery;
    dsPesquisa: TDataSource;
    cxGrid1DBTableView1cod_item: TcxGridDBColumn;
    cxGrid1DBTableView1den_item: TcxGridDBColumn;
    cxGrid1DBTableView1cod_unid_med: TcxGridDBColumn;
    cxGrid1DBTableView1qtd_contada: TcxGridDBColumn;
    cxGrid1DBTableView1num_folha: TcxGridDBColumn;
    cxGrid1DBTableView1dat_hor_inclusao: TcxGridDBColumn;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    edtUm: TcxTextEdit;
    btnIncluir: TcxButton;
    cmd: TADOCommand;
    edtLocalFab: TcxComboBox;
    cxLabel7: TcxLabel;
    edtSit: TcxComboBox;
    cxGrid1DBTableView1ies_situa_qtd: TcxGridDBColumn;
    cxLabel8: TcxLabel;
    edtLocalEst: TcxComboBox;
    edtLote: TcxTextEdit;
    cxLabel9: TcxLabel;
    cxGrid1DBTableView1cod_local: TcxGridDBColumn;
    cxGrid1DBTableView1num_lote: TcxGridDBColumn;
    btnRel: TToolButton;
    Panel2: TPanel;
    QuickRep1: TQuickRep;
    qryRel: TADOQuery;
    qryRelcod_item: TStringField;
    qryRelden_item: TStringField;
    qryRelcod_local: TStringField;
    qryRelnum_lote: TStringField;
    qryRelcod_unid_med: TStringField;
    qryRelqtd_contada_1: TBCDField;
    qryRelqtd_contada_2: TBCDField;
    qryRelqtd_contada_3: TBCDField;
    qryRelqtd_contada_4: TBCDField;
    qryRelqtd_contada_5: TBCDField;
    QRBand1: TQRBand;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    QRLabel3: TQRLabel;
    QRSysData1: TQRSysData;
    qryRelies_situa_qtd: TStringField;
    QRShape1: TQRShape;
    QRBand2: TQRBand;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRDBText5: TQRDBText;
    QRDBText6: TQRDBText;
    QRLabel4: TQRLabel;
    QRLabel5: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRLabel8: TQRLabel;
    QRLabel9: TQRLabel;
    QRShape2: TQRShape;
    QRDBText7: TQRDBText;
    QRDBText8: TQRDBText;
    QRDBText9: TQRDBText;
    QRDBText10: TQRDBText;
    QRDBText11: TQRDBText;
    QRLabel10: TQRLabel;
    QRLabel11: TQRLabel;
    QRLabel12: TQRLabel;
    QRLabel13: TQRLabel;
    QRLabel14: TQRLabel;
    QRLabel15: TQRLabel;
    btnExportar: TToolButton;
    btnLimpar: TToolButton;
    qryItens: TADOQuery;
    cxGrid1DBTableView1num_contagem: TcxGridDBColumn;
    btnExcel: TToolButton;
    SaveDialog1: TSaveDialog;
    qryDim: TADOQuery;
    qryDimies_endereco: TStringField;
    qryDimies_volume: TStringField;
    qryDimies_dat_producao: TStringField;
    qryDimies_dat_validade: TStringField;
    qryDimies_comprimento: TStringField;
    qryDimies_largura: TStringField;
    qryDimies_altura: TStringField;
    qryDimies_diametro: TStringField;
    qryDimies_peca: TStringField;
    qryDimies_serie: TStringField;
    qryRellocal_fabrica: TStringField;
    QRDBText12: TQRDBText;
    qryData: TADOQuery;
    qryGen2: TADOQuery;
    qryGen3: TADOQuery;
    cxGrid1DBTableView1cod_usuario: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure btnFecharClick(Sender: TObject);
    procedure edtItemPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure edtItemExit(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
    procedure qryPesquisaAfterOpen(DataSet: TDataSet);
    procedure btnExcluirClick(Sender: TObject);
    Function GetDOSUser:String;
    procedure btnRelClick(Sender: TObject);
    procedure QRBand2BeforePrint(Sender: TQRCustomBand;
      var PrintBand: Boolean);
    procedure btnLimparClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnExcelClick(Sender: TObject);
    procedure edtItemKeyPress(Sender: TObject; var Key: Char);
    function  iif(Condicao : Boolean; Verdadeiro, Falso : Variant) : Variant;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  cod_usuario_so: string;
  divergencia : boolean;
  inv_local_fabrica   : string;
  inv_ver_duplic      : string;
  inv_lote_padrao     : string;
  inv_val_lote_padrao : string;
  inv_ver_lista_dupl  : string;
  inv_usuario_so      : string;
  inv_lista_unica     : string;
  inv_ult_cont_lista  : string;
  formato_data_bd     : string;
  formato_datahora_bd : string;
  inv_serie_ife       : string;
  serie_ife           : integer;  

implementation

uses uConexao,uFuncoes,uVersao, Pesq_item, uDuplicidade, uDimensional,
  cxVGrid, Math;

{$R *.dfm}

Function TfrmPrincipal.GetDOSUser:String;
var Len			: Integer;
		pDosEnv	: PChar;
begin
	//-- Rotina de resgate das variáveis de ambiente DOS --------------------------------------------------------------------------
	Result 	:='';
	Len 		:= Length('USERNAME');
	PDosEnv := GetEnvironmentStrings;

	while not(Copy(pDosEnv, 1, 8) = 'USERNAME') do
  	Inc(PDosEnv, StrLen(PDosEnv) + 1);

	Result := StrPas(PDosEnv + Len + 1);
  //-----------------------------------------------------------------------------------------------------------------------------
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var Registro : TRegistry;
begin
  Application.Title := 'PGI1024';
  Self.Caption := Self.Caption + ' V.' + GetBuildInfo;
  cod_empresa   := ParamStr(1);
  cod_usuario   := ParamStr(2);

  serie_ife := 0;

  if Length(TRIM(cod_empresa)) = 0 then
    cod_empresa := InputBox('cod_empresa','cod_empresa',parametro('cod_emp_padrao'));//parametro('cod_emp_padrao');

  if Length(TRIM(cod_usuario)) = 0 then
    cod_usuario := InputBox('cod_usuario','cod_usuario',parametro('usuario_padrao'));//parametro('usuario_padrao');

  {
  qrygen.Close;
  qryGen.SQL.Text := 'select nom_usuario from pg_usuario where cod_usuario = '+QuotedStr(cod_usuario);
  qrygen.Open;

  if not qryGen.Eof then
    StatusBar1.Panels[0].Text := 'Usuário: '+trim(cod_usuario)+'|'+trim(qryGen.Fields[0].AsString)
  else
    StatusBar1.Panels[0].Text := 'Usuário não encontrado';
  }

  if Base_Dados = 1 then
    begin
      formato_data_bd := 'dd/mm/yyyy';
      formato_datahora_bd := 'yyyy-mm-dd hh:nn:ss';
    end
  else if Base_Dados = 2 then
    begin
      formato_data_bd := 'yyyy-mm-dd';
      formato_datahora_bd := 'yyyy-mm-dd hh:nn:ss';
    end
  else if Base_Dados = 3 then
    begin
      formato_data_bd := 'yyyy-mm-dd hh:nn:ss';
      formato_datahora_bd := 'yyyy-mm-dd hh:nn:ss';
    end
  else
    begin
      formato_data_bd := 'dd/mm/yyyy';
      formato_datahora_bd := 'yyyy-mm-dd hh:nn:ss';
    end;

  // Parâmetro que indica se utiliza o usuário do Windows
  try
    inv_usuario_so := parametro('inv_usuario_so');
  except
    inv_usuario_so := 'N';
  end;

  if inv_usuario_so = 'S' then
    begin
      //-- Busca o usuario logado
      Registro 					:= TRegistry.Create;
      Registro.RootKey 	:= HKEY_LOCAL_MACHINE;

      if Registro.OpenKey('Network\Logon', false) then
        cod_usuario_so := trim(Registro.ReadString('username'))
      else
        cod_usuario_so := trim(GetDOSUser);

      Registro.Free;
    end
  else
    cod_usuario_so := cod_usuario;

  StatusBar1.Panels[0].Text := 'Usuário: '+cod_usuario_so;

  // Parâmetro que indica se utiliza o campo de local fábrica.
  try
    inv_local_fabrica := parametro('inv_local_fabrica');
  except
    inv_local_fabrica := 'N';
  end;

  if inv_local_fabrica = 'N' then
    begin
      edtLocalFab.Properties.ReadOnly := true;
      edtLocalFab.Enabled := false;
    end
  else
    begin
      edtLocalFab.Properties.ReadOnly := false;
      edtLocalFab.Enabled := true;
    end;

  // Parâmetro que indica se verifica duplicidade
  try
    inv_ver_duplic := parametro('inv_ver_duplic');
  except
    inv_ver_duplic := 'N';
  end;

  // Parâmetro que indica se verifica se item já foi digitado em outra lista
  try
    inv_ver_lista_dupl := parametro('inv_ver_lista_dupl');
  except
    inv_ver_lista_dupl := 'N';
  end;

  // Parâmetro que indica se verifica se a lista será única por contagem
  try
    inv_lista_unica := parametro('inv_lista_unica');
  except
    inv_lista_unica := 'N';
  end;

  // Parâmetro que indica lote padrão, e o valor do lote
  try
    inv_lote_padrao := parametro('inv_lote_padrao');
  except
    inv_lote_padrao := 'N';
  end;

  if inv_lote_padrao = 'S' then
    begin
      try
        inv_val_lote_padrao := parametro('inv_val_lote_padrao');
      except
        inv_val_lote_padrao := 'INVENTARIO';
      end;
    end
  else
    begin
      inv_val_lote_padrao := '';
    end;

  // Parâmetro que indica se será utilizada a última contagem do item para exportação, ou a últma contagem de cada lista digitada para o item.
  try
    inv_ult_cont_lista := parametro('inv_ult_cont_lista');
  except
    inv_ult_cont_lista := 'N';
  end;

  // Parâmetro que indica se utiliza a série (etiqueta) IFE
  try
    inv_serie_ife := parametro('inv_serie_ife');
  except
    inv_serie_ife := 'N';
  end;

  // Carrega combo de locais
  qryGen.Close;
  qryGen.SQL.Text := 'SELECT cod_local,den_local FROM local WHERE cod_empresa='+QuotedStr(cod_empresa)+' order by cod_local';
  qryGen.Open;

  while not qryGen.Eof do
    begin
      edtLocalEst.Properties.Items.Add(trim(qryGen.Fields[0].AsString)+' | '+trim(qryGen.Fields[1].AsString));
      qryGen.Next;
    end;

  qryPesquisa.Close;
  qryPesquisa.Parameters.ParamByName('p_cod_empresa').Value := cod_empresa;
  if trim(cod_usuario) <> 'admlog' then
    begin
      qryGen.Close;
      qryGen.SQL.Text := ' select * '
                       + '   from usuario_substituto_912'
                       + '  where cod_empresa = ' + QuotedStr(cod_empresa)
                       + '    and cod_usuario = ' + QuotedStr(cod_usuario_so);
      qryGen.Open;
      if qryGen.IsEmpty then
        begin
          qryPesquisa.SQL[5] := ' and a.cod_usuario = '+QuotedStr(cod_usuario_so);

          btnRel.Visible := false;
          btnExportar.Visible := false;
          btnLimpar.Visible := false;
        end
      else
        begin
          qryPesquisa.SQL[5] := '';

          btnRel.Visible := true;
          btnExportar.Visible := true;
          btnLimpar.Visible := true;
        end;
    end
  else
    begin
      qryPesquisa.SQL[5] := '';
      btnRel.Visible := true;
      btnExportar.Visible := true;
      btnLimpar.Visible := true;
    end;

  qryPesquisa.Open;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  with dmConexao do
    begin
      qryGenInformix.Close;
      qryGenInformix.SQL.Text := ' INSERT INTO pg_par_conexao VALUES (' +
                                 QuotedStr(cod_usuario) + ',' +
                                 QuotedStr(TRIM(Application.ExeName )) + ')';
      qryGenInformix.ExecSQL;
    end;

  edtItem.SetFocus;
  edtSit.ItemIndex := 0;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  qryGen.Close;
  qryGen.SQL.Text := ' DELETE FROM pg_par_conexao WHERE cod_usuario = ' +
                      QuotedStr(cod_usuario) + ' and nom_programa = ' +
                      QuotedStr(TRIM(Application.ExeName));
  qryGen.ExecSQL;
end;

procedure TfrmPrincipal.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  MessageDlg('Ocorreu um erro durante o processo.'+#13+'Reinicie a aplicação e tente novamente.'+#13+e.Message, mtError ,[mbOk], 0);
end;

procedure TfrmPrincipal.btnFecharClick(Sender: TObject);
begin
  dmConexao.connInformix.Close;
  Application.Terminate;
end;

procedure TfrmPrincipal.edtItemPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  frmPesq_item_padrao := TfrmPesq_item_padrao.Create(Self);
  frmPesq_item_padrao.showModal;
  if frmPesq_item_padrao.ModalResult = mrok then
    edtitem.text := trim(frmPesq_item_padrao.qryItemcod_item.asString)+' | '+trim(frmPesq_item_padrao.qryItemden_item.asString)
  else
    edtItem.text := '';
end;

procedure TfrmPrincipal.edtItemExit(Sender: TObject);
begin
  screen.Cursor := crHourGlass;
  Update;

  // Sempre zera a variável da série IFE
  serie_ife := 0;

  // Verifica se o código foi digitado diretamente
  if ((Pos('|',edtItem.Text) = 0) and (trim(edtItem.Text) <> '')) then
    begin
      qryGen.Close;
      qryGen.SQL.Text := 'select cod_item,den_item from item where cod_empresa='+QuotedStr(cod_empresa)+' and ies_situacao <> ''C'' and cod_item = '+QuotedStr(trim(edtItem.Text));
      qrygen.Open;
      if not qryGen.Eof then
        edtItem.Text := trim(qryGen.Fields[0].AsString)+' | '+trim(qryGen.Fields[1].AsString)
      else
        edtItem.Text := '';
    end;

  qryGen.Close;
  qryGen.SQL.Text := 'SELECT a.cod_unid_med,b.cod_local,b.den_local,a.ies_ctr_estoque, a.ies_ctr_lote  '+
                     ' FROM item a                                         '+
                     ' LEFT OUTER JOIN local b ON b.cod_empresa=a.cod_empresa   '+
                     '                        AND b.cod_local=a.cod_local_estoq '+
                     ' WHERE a.cod_empresa = '+QuotedStr(cod_empresa)+
                     ' AND a.cod_item = '+QuotedStr(trim(leftAte(edtItem.Text,'|')));
  qryGen.Open;

  if ((trim(qryGen.Fields[3].AsString) = 'N')) then
    begin
      MessageDlg('Item não controla estoque.', mtError ,[mbOk], 0);
      edtItem.SetFocus;
      screen.Cursor := crDefault;
      Update;
      exit;
    end;

  if trim(qryGen.Fields[4].AsString) = 'N' then
    begin
      edtLote.Text := '';
      edtLote.Properties.ReadOnly := true;
    end
  else
    begin
      if inv_lote_padrao = 'S' then
        begin
          edtLote.Text := inv_val_lote_padrao;
          edtLote.Properties.ReadOnly := true;
        end
      else
        begin
          edtLote.Properties.ReadOnly := false;
          edtLote.Text := '';
        end;
    end;

  if not qryGen.Eof then
    begin
      edtUm.Text    := trim(qryGen.Fields[0].Value);
      edtLocalEst.ItemIndex := edtLocalEst.Properties.Items.IndexOf(trim(qryGen.Fields[1].AsString)+' | '+trim(qryGen.Fields[2].AsString));
    end
  else
    begin
      edtUm.Text    := '';
      edtLocalEst.Text := '';
    end;
  screen.Cursor := crDefault;
  Update;
end;

procedure TfrmPrincipal.btnIncluirClick(Sender: TObject);
var ies_dimensional, endereco, peca, serie : string;
    volume,comprimento, largura, altura, diametro : real;
    dat_producao, dat_validade : TDateTime;
begin
  // Validações
  if trim(edtItem.Text) = '' then
    begin
      MessageDlg('Informe o item.', mtError ,[mbOk], 0);
      edtItem.SetFocus;
      exit;
    end;

  if ((inv_local_fabrica = 'S') and (trim(edtLocalFab.Text) = '')) then
    begin
      MessageDlg('Informe o local da fábrica.', mtError ,[mbOk], 0);
      edtLocalFab.SetFocus;
      exit;
    end;

  if trim(edtFolha.Text) = '' then
    begin
      MessageDlg('Informe o número da folha.', mtError ,[mbOk], 0);
      edtFolha.SetFocus;
      exit;
    end;

  if ((trim(edtQtd.Text) <> '') and (edtQtd.Value < 0)) then
    begin
      MessageDlg('Informe a quantidade corretamente.', mtError ,[mbOk], 0);
      edtQtd.SetFocus;
      exit;
    end;

  qryGen.Close;
  qryGen.SQL.Text := 'select par_txt from par_plugin_912 where cod_empresa = '+QuotedStr(cod_empresa)+' and cod_parametro = ''lote_PGI1024'' ';
  qryGen.Open;

  if(qryGen.Fields[0].AsString <> 'N') then
    begin
      if ((not edtLote.Properties.ReadOnly) and (trim(edtLote.Text) = '')) then
        begin
        MessageDlg('Informe o lote.', mtError ,[mbOk], 0);
        edtLote.SetFocus;
        exit;
      end;
    end;

  // Verifica se a contagem já foi digitada
  if inv_ver_duplic = 'S' then
    begin
      qryGen.Close;
      qryGen.SQL.Text := 'SELECT cod_item,num_contagem,local_fabrica,num_folha,cod_usuario,ies_situa_qtd  '+
                         ' FROM itens_invent_912                                                          '+
                         ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                         ' AND cod_item = '+QuotedStr(trim(leftAte(edtItem.Text,'|')))+
                         ' AND num_contagem = '+edtContagem.Text+
                         iif(inv_ver_lista_dupl = 'S','',' AND num_folha = '+edtFolha.Text)+
                         ' AND ies_situa_qtd = '+QuotedStr(copy(trim(edtSit.Text),1,1))+
                         //' AND local_fabrica = '+QuotedStr(edtLocalFab.Text)+
                         ' AND cod_local = '+QuotedStr(trim(leftAte(edtLocalEst.Text,'|')))+
                         ' AND num_lote '+ iif(trim(edtLote.Text)='',' is null ', ' = '+QuotedStr(trim(edtLote.Text)));
      qryGen.Open;

      if not qryGen.IsEmpty then
        begin
          frmDuplicidade := TfrmDuplicidade.Create(Self);
          frmDuplicidade.ShowModal;
          frmDuplicidade.Free;
          exit;
        end;
    end;

  // Verifica se a lista já foi digitada
  if inv_lista_unica = 'S' then
    begin
      qryGen.Close;
      qryGen.SQL.Text := 'SELECT cod_item,num_contagem,local_fabrica,num_folha,cod_usuario,ies_situa_qtd  '+
                         ' FROM itens_invent_912                                                          '+
                         ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                         ' AND num_contagem = '+edtContagem.Text+
                         ' AND num_folha = '+edtFolha.Text;
      qryGen.Open;

      if not qryGen.IsEmpty then
        begin
          MessageDlg('Folha já digitada para a '+edtContagem.Text+'ª contagem.'+#13+'Usuário: '+cod_usuario_so+#13+'Item: '+trim(qryGen.Fields[0].AsString), mtError ,[mbOk], 0);
          exit;
        end;
    end;

  // Verifica se o item possui dimensional, e abre a tela para digitação
  ies_dimensional := 'N';
  endereco := ' ';
  peca := ' ';
  serie := ' ';
  volume := 0;
  comprimento := 0;
  largura := 0;
  altura := 0;
  diametro := 0;
  dat_producao := strtodate('01/01/1900');
  dat_validade := strtodate('01/01/1900');

  qryDim.Close;
  qryDim.SQL.Text := 'SELECT  ies_endereco, ies_volume, ies_dat_producao, ies_dat_validade, ies_comprimento, ies_largura, ies_altura, ies_diametro, reservado_1 as ies_peca, reservado_2 as ies_serie '+
                     ' FROM item_ctr_grade                                             '+
                     ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                     ' AND cod_item = '+QuotedStr(trim(leftAte(edtItem.Text,'|')))+
                     ' AND (ies_endereco = ''S'' or          '+
                     '      ies_volume = ''S'' or            '+
                     '      ies_dat_producao = ''S'' or      '+
                     '      ies_dat_validade = ''S'' or      '+
                     '      ies_comprimento = ''S'' or       '+
                     '      ies_largura = ''S'' or           '+
                     '      ies_altura = ''S'' or            '+
                     '      ies_diametro = ''S'' or          '+
                     '      reservado_1 = ''S'' or           '+
                     '      reservado_2 = ''S'')';
  qryDim.Open;

  if not qryDim.IsEmpty then
    begin
      ies_dimensional := 'S';

      // Caso seja etiqueta ife, assume o comprimento lido na etiqueta
      if ((inv_serie_ife = 'S') and (serie_ife > 0)) then
        begin
          qryGen.Close;
          qrygen.SQL.Text := 'SELECT comprimento FROM etiq_887 WHERE cod_empresa='+QuotedStr(cod_empresa)+' AND serie = '+IntToStr(serie_ife);
          qryGen.Open;

          if ((not qryGen.IsEmpty) and (not qryGen.Fields[0].IsNull) and (qryGen.Fields[0].AsFloat > 0)) then
            comprimento := qryGen.Fields[0].AsFloat;
        end;

      // Se o comprimento for encontrado na etiqueta, e for o único dimensional não abre a tela
      if((comprimento > 0) and
          (qryDimies_endereco.Value = 'N') and
          (qryDimies_volume.Value = 'N') and
          (qryDimies_dat_producao.Value = 'N') and
          (qryDimies_dat_validade.Value = 'N') and
          (qryDimies_comprimento.Value = 'S') and
          (qryDimies_largura.Value = 'N') and
          (qryDimies_altura.Value = 'N') and
          (qryDimies_diametro.Value = 'N') and
          (qryDimies_peca.Value = 'N') and
          (qryDimies_serie.Value = 'N')) then
        begin
          // somente arredonda o valor
          comprimento := RoundTo(comprimento,0);
        end
      else
        begin
          frmDimensional := TfrmDimensional.Create(Self);

          if qryDimies_endereco.Value = 'N' then
            frmDimensional.cxVerticalGrid1Endereco.Visible := false;
          if qryDimies_volume.Value = 'N' then
            frmDimensional.cxVerticalGrid1Volume.Visible := false;
          if qryDimies_dat_producao.Value = 'N' then
            frmDimensional.cxVerticalGrid1DataProducao.Visible := false;
          if qryDimies_dat_validade.Value = 'N' then
            frmDimensional.cxVerticalGrid1DataValidade.Visible := false;
          if qryDimies_comprimento.Value = 'N' then
            frmDimensional.cxVerticalGrid1Comprimento.Visible := false;
          if qryDimies_largura.Value = 'N' then
            frmDimensional.cxVerticalGrid1Largura.Visible := false;
          if qryDimies_altura.Value = 'N' then
            frmDimensional.cxVerticalGrid1Altura.Visible := false;
          if qryDimies_diametro.Value = 'N' then
            frmDimensional.cxVerticalGrid1Diametro.Visible := false;
          if qryDimies_peca.Value = 'N' then
            frmDimensional.cxVerticalGrid1Peca.Visible := false;
          if qryDimies_serie.Value = 'N' then
            frmDimensional.cxVerticalGrid1Serie.Visible := false;

          frmDimensional.ShowModal;

          if frmDimensional.ModalResult = mrOK then
            begin
              if qryDimies_endereco.Value = 'S' then
                endereco := UpperCase(frmDimensional.cxVerticalGrid1Endereco.Properties.Value);
              if qryDimies_volume.Value = 'S' then
                volume := frmDimensional.cxVerticalGrid1Volume.Properties.Value;
              if qryDimies_dat_producao.Value = 'S' then
                dat_producao := frmDimensional.cxVerticalGrid1DataProducao.Properties.Value;
              if qryDimies_dat_validade.Value = 'S' then
                dat_validade := frmDimensional.cxVerticalGrid1DataValidade.Properties.Value;
              if qryDimies_comprimento.Value = 'S' then
                comprimento := frmDimensional.cxVerticalGrid1Comprimento.Properties.Value;
              if qryDimies_largura.Value = 'S' then
                largura := frmDimensional.cxVerticalGrid1Largura.Properties.Value;
              if qryDimies_altura.Value = 'S' then
                altura := frmDimensional.cxVerticalGrid1Altura.Properties.Value;
              if qryDimies_diametro.Value = 'S' then
                diametro := frmDimensional.cxVerticalGrid1Diametro.Properties.Value;
              if qryDimies_peca.Value = 'S' then
                peca := UpperCase(frmDimensional.cxVerticalGrid1Peca.Properties.Value);
              if qryDimies_serie.Value = 'S' then
                serie := UpperCase(frmDimensional.cxVerticalGrid1Serie.Properties.Value);
            end
          else
            exit;

          frmDimensional.Free;
        end;
    end;

  screen.Cursor := crHourGlass;
  Update;

    try
      //Verifica se o item não está na tabela de inventário para gravar
      qrygen.Close;
      qryGen.SQL.Text := ' SELECT * FROM itens_invent '+
                         ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                         ' AND cod_item = '+QuotedStr(trim(leftAte(edtItem.Text,'|')));
      qryGen.Open;

      qrygen2.Close;
      qryGen2.SQL.Text := ' SELECT * FROM estoque_lote '+
                          ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                          ' AND cod_item = '+QuotedStr(trim(leftAte(edtItem.Text,'|')));
      qryGen2.Open;

      if ((qryGen.IsEmpty) and not(qryGen2.IsEmpty)) then
        begin
          if Application.MessageBox('Item não está preparado para inventário. Deseja inclui-lo?','Mensagem',MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2) = IdYes then
            begin
              cmd.CommandText := 'INSERT INTO itens_invent_912 (cod_empresa,cod_item,num_contagem,local_fabrica,cod_local,ies_dimensional, num_lote,endereco, num_volume, dat_hor_producao, dat_hor_validade, comprimento, largura, altura, diametro , '+
                                 '                              num_peca, num_serie,qtd_contada,ies_situa_qtd,num_folha,cod_usuario,dat_hor_inclusao) VALUES '+
                                 ' ('+QuotedStr(cod_empresa)+','+QuotedStr(trim(leftAte(edtItem.Text,'|')))+','+edtContagem.Text+','+QuotedStr(qryGen2.FieldByName('num_lote').AsString+' ')+','+QuotedStr(trim(leftAte(edtLocalEst.Text,'|')))+','+QuotedStr(ies_dimensional)+
                                 ' , '+iif(trim(edtLote.Text)='',' null ',QuotedStr(trim(edtLote.Text)))+', '+QuotedStr(endereco)+','+FloatToStr(volume)+', '+fData(QuotedStr(DateToStr(dat_producao)))+', '+fData(QuotedStr(DateToStr(dat_validade)))+' , '+FloatToStr(comprimento)+
                                 ' ,'+FloatToStr(largura)+', '+FloatToStr(altura)+', '+FloatToStr(diametro)+', '+QuotedStr(peca)+', '+QuotedStr(serie)+
                                 ' ,'+StringReplace(StringReplace(edtqtd.Text,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+','+QuotedStr(copy(trim(edtSit.Text),1,1))+','+edtFolha.Text+','+QuotedStr(cod_usuario_so)+','+fData(QuotedStr(DateToStr(now)))+' )';
              cmd.Execute;
            end;
        end
      else
        begin
          cmd.CommandText := 'INSERT INTO itens_invent_912 (cod_empresa,cod_item,num_contagem,local_fabrica,cod_local,ies_dimensional, num_lote,endereco, num_volume, dat_hor_producao, dat_hor_validade, comprimento, largura, altura, diametro , '+
                             '                              num_peca, num_serie,qtd_contada,ies_situa_qtd,num_folha,cod_usuario,dat_hor_inclusao) VALUES '+
                             ' ('+QuotedStr(cod_empresa)+','+QuotedStr(trim(leftAte(edtItem.Text,'|')))+','+edtContagem.Text+','+QuotedStr(edtLocalFab.Text+' ')+','+QuotedStr(trim(leftAte(edtLocalEst.Text,'|')))+','+QuotedStr(ies_dimensional)+
                             ' , '+iif(trim(edtLote.Text)='',' null ',QuotedStr(trim(edtLote.Text)))+', '+QuotedStr(endereco)+','+FloatToStr(volume)+', '+fData(QuotedStr(DateToStr(dat_producao)))+', '+fData(QuotedStr(DateToStr(dat_validade)))+' , '+FloatToStr(comprimento)+
                             ' ,'+FloatToStr(largura)+', '+FloatToStr(altura)+', '+FloatToStr(diametro)+', '+QuotedStr(peca)+', '+QuotedStr(serie)+
                             ' ,'+StringReplace(StringReplace(edtqtd.Text,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+','+QuotedStr(copy(trim(edtSit.Text),1,1))+','+edtFolha.Text+','+QuotedStr(cod_usuario_so)+','+fData(QuotedStr(DateToStr(now)))+' )';
          cmd.Execute;
        end;

      qryPesquisa.Close;
      qryPesquisa.Open;
      edtItem.Text := '';
      edtUm.Text := '';
      edtLocalEst.Text := '';
      edtLote.Text := '';
      //edtLocal.Text := '';
      edtQtd.Text := '0';
      edtItem.SetFocus;
      edtSit.ItemIndex := 0;
      serie_ife := 0;
      screen.Cursor := crDefault;
      Update;
    except  on e : Exception do
      begin
        screen.Cursor := crDefault;
        Update;
        MessageDlg('Falha na inclusão da contagem.'+#13+'Verifique os valores e tente novamente.'+#13+'Mensagem de ERRO : '+e.Message, mtError ,[mbOk], 0);
      end
    end;
end;

procedure TfrmPrincipal.qryPesquisaAfterOpen(DataSet: TDataSet);
begin
  btnExcluir.Enabled := not qryPesquisa.IsEmpty;
  btnRel.Enabled := not qryPesquisa.IsEmpty;
  btnExportar.Enabled := not qryPesquisa.IsEmpty;
  btnExcel.Enabled := not qryPesquisa.IsEmpty;
  cxGrid1DBTableView1.DataController.Groups.FullExpand;
end;

procedure TfrmPrincipal.btnExcluirClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente excluir a contagem selecionada?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      screen.Cursor := crHourGlass;
      Update;
      try
        cmd.CommandText := 'DELETE FROM itens_invent_912 '+
                           ' WHERE cod_empresa = '+QuotedStr(cod_empresa)+
                           ' AND cod_item = '+QuotedStr(qryPesquisa.FieldByName('cod_item').Value)+
                           ' AND ies_situa_qtd = '+QuotedStr(qryPesquisa.FieldByName('ies_situa_qtd').Value)+
                           ' AND num_contagem = '+qryPesquisa.FieldByName('num_contagem').AsString+
                           ' AND local_fabrica = '+QuotedStr(qryPesquisa.FieldByName('local_fabrica').Value)+
                           ' AND cod_local = '+QuotedStr(trim(qryPesquisa.FieldByName('cod_local').Value))+
                           ' AND num_folha = '+qryPesquisa.FieldByName('num_folha').AsString+
                           ' AND num_lote '+ iif(trim(qryPesquisa.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryPesquisa.FieldByName('num_lote').AsString)));
        cmd.Execute;
        qryPesquisa.Close;
        qryPesquisa.Open;
        screen.Cursor := crDefault;
        Update;
      except
        screen.Cursor := crDefault;
        Update;
        MessageDlg('Falha na exclusão da contagem.'+#13+'Verifique os valores e tente novamente.', mtError ,[mbOk], 0);
      end;
    end;
end;

procedure TfrmPrincipal.btnRelClick(Sender: TObject);
begin
  if MessageDlg('Listar apenas as divergências?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      divergencia := true;
      QRLabel2.Caption := '(DIVERGÊNCIAS)';
    end
  else
    begin
      divergencia := false;
      QRLabel2.Caption := '';
    end;

  if Base_Dados = 2 then
    qryRel.SQL.Text := StringReplace(qryRel.SQL.Text,'nvl','isnull',[rfReplaceAll]);

  qryRel.Close;
  qryRel.Parameters.ParamByName('p_cod_empresa').Value := cod_empresa;
  qryRel.Open;

  QuickRep1.PreviewModal;

end;

procedure TfrmPrincipal.QRBand2BeforePrint(Sender: TQRCustomBand;
  var PrintBand: Boolean);
var contagens : array[1..5] of real;
    num_contagens: integer;
begin
  num_contagens:=0;
  if divergencia then
    begin
      if not qryRelqtd_contada_1.IsNull then
        begin
          contagens[1] := qryRelqtd_contada_1.Value;
          inc(num_contagens);
        end;
      if not qryRelqtd_contada_2.IsNull then
        begin
          contagens[2] := qryRelqtd_contada_2.Value;
          inc(num_contagens);
        end;
      if not qryRelqtd_contada_3.IsNull then
        begin
          contagens[3] := qryRelqtd_contada_3.Value;
          inc(num_contagens);
        end;
      if not qryRelqtd_contada_4.IsNull then
        begin
          contagens[4] := qryRelqtd_contada_4.Value;
          inc(num_contagens);
        end;
      if not qryRelqtd_contada_5.IsNull then
        begin
          contagens[5] := qryRelqtd_contada_5.Value;
          inc(num_contagens);
        end;

      if num_contagens > 1 then
        PrintBand := true
      else
        PrintBand := false;

      if ((not qryRelqtd_contada_1.IsNull) and
          ((qryRelqtd_contada_1.Value = contagens[2]) or
          (qryRelqtd_contada_1.Value = contagens[3]) or
          (qryRelqtd_contada_1.Value = contagens[4]) or
          (qryRelqtd_contada_1.Value = contagens[5]))
          ) then
        PrintBand := false
      else if ((not qryRelqtd_contada_2.IsNull) and
          ((qryRelqtd_contada_2.Value = contagens[1]) or
          (qryRelqtd_contada_2.Value = contagens[3]) or
          (qryRelqtd_contada_2.Value = contagens[4]) or
          (qryRelqtd_contada_2.Value = contagens[5]))
          ) then
        PrintBand := false
      else if ((not qryRelqtd_contada_3.IsNull) and
          ((qryRelqtd_contada_3.Value = contagens[1]) or
          (qryRelqtd_contada_3.Value = contagens[2]) or
          (qryRelqtd_contada_3.Value = contagens[4]) or
          (qryRelqtd_contada_3.Value = contagens[5]))
          ) then
        PrintBand := false
      else if ((not qryRelqtd_contada_4.IsNull) and
          ((qryRelqtd_contada_4.Value = contagens[1]) or
          (qryRelqtd_contada_4.Value = contagens[2]) or
          (qryRelqtd_contada_4.Value = contagens[3]) or
          (qryRelqtd_contada_4.Value = contagens[5]))
          ) then
        PrintBand := false
      else if ((not qryRelqtd_contada_5.IsNull) and
          ((qryRelqtd_contada_5.Value = contagens[1]) or
          (qryRelqtd_contada_5.Value = contagens[2]) or
          (qryRelqtd_contada_5.Value = contagens[3]) or
          (qryRelqtd_contada_5.Value = contagens[4]))
          ) then
        PrintBand := false;

    end
  else
    PrintBand := true;

end;

procedure TfrmPrincipal.btnLimparClick(Sender: TObject);
begin
  if MessageDlg('Isto irá apagar todas as digitações já salvas para a empresa corrente.'+#13+'Deseja continuar?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      try
        screen.Cursor := crHourGlass;
        cmd.CommandText := 'DELETE FROM itens_invent_912 WHERE cod_empresa = '+QuotedStr(cod_empresa);
        cmd.Execute;
        screen.Cursor := crDefault;
        qryPesquisa.Close;
        qryPesquisa.Open;
        MessageDlg('Dados excluídos com sucesso.', mtInformation ,[mbOk], 0);
      except
        screen.Cursor := crDefault;
        MessageDlg('Falha na limpeza das tabelas.'+#13+'Verifique se não há outro programa em execução.', mtError ,[mbOk], 0);
      end;

    end;
end;

procedure TfrmPrincipal.btnExportarClick(Sender: TObject);
var cData, cHora, cQtdSaldo: String;
begin
  if MessageDlg('Isto irá atualizar o inventário no Logix,'+#13+'com a última contagem de cada item.'+#13+'Deseja continuar?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      try
        dmConexao.connInformix.BeginTrans;
        screen.Cursor := crHourGlass;
        qryItens.Close;
        qryItens.SQL.Text := '';
        qryItens.SQL.Text := ' SELECT a.cod_empresa,a.cod_item,a.ies_dimensional,b.ies_tip_item,a.cod_local,a.num_lote,a.ies_situa_qtd, '+
                             ' a.endereco, a.num_volume, a.dat_hor_producao, a.dat_hor_validade, a.comprimento, a.largura, a.altura, a.diametro, a.num_peca, a.num_serie, '+
                             ' sum(a.qtd_contada) as qtd_contada '+
                             ' FROM itens_invent_912 a '+
                             ' inner join item b on b.cod_empresa=a.cod_empresa '+
                             '                  and b.cod_item=a.cod_item '+
                             ' WHERE a.cod_empresa = '+QuotedStr(cod_empresa)+
                             ' AND a.num_contagem = (SELECT max(num_contagem) FROM itens_invent_912 WHERE cod_empresa=a.cod_empresa '+
                             '                       AND cod_item=a.cod_item AND cod_local=a.cod_local AND nvl(num_lote,'' '')=nvl(a.num_lote,'' '') '+
                             '                       AND ies_situa_qtd=a.ies_situa_qtd ###) ';

        if inv_ult_cont_lista = 'S' then
          qryItens.SQL.Text := StringReplace(qryItens.SQL.Text,'###',' AND num_folha=a.num_folha ',[rfReplaceAll])
        else
          qryItens.SQL.Text := StringReplace(qryItens.SQL.Text,'###',' ',[rfReplaceAll]);

        if Base_Dados = 2 then
          qryItens.SQL.Text := StringReplace(qryItens.SQL.Text,'nvl','isnull',[rfReplaceAll]);

        qryItens.SQL.Add(' GROUP BY a.cod_empresa,a.cod_item,a.ies_dimensional,b.ies_tip_item,a.cod_local, '+
                         ' a.num_lote,a.ies_situa_qtd,a.endereco, a.num_volume, a.dat_hor_producao, a.dat_hor_validade, '+
                         ' a.comprimento, a.largura, a.altura, a.diametro, a.num_peca, a.num_serie order by a.cod_item ');
        qryItens.Open;
        qryItens.First;
        //qryItens.RecordCount;

        while not qryItens.Eof do
          begin
            cQtdSaldo := '0';
            cData := '';
            cHora := '';
            if qryItens.FieldByName('ies_dimensional').AsString = 'S' then
              begin
                qryData.Close;
                qryData.SQL.Text := ' SELECT DISTINCT dat_selecao, hor_selecao FROM itens_invent_grade '+
                                    ' WHERE cod_empresa =  '+QuotedStr(cod_empresa)+
                                    ' AND cod_item IN (SELECT cod_item FROM itens_invent WHERE cod_empresa = '+QuotedStr(cod_empresa)+') ';
                qryData.Open;

                cData := qryData.FieldByName('dat_selecao').AsString;
                cHora := qryData.FieldByName('hor_selecao').AsString;
              end
            else
              begin
                qryData.Close;
                qryData.SQL.Text := ' SELECT DISTINCT dat_selecao, hor_selecao FROM itens_invent '+
                                    ' WHERE cod_empresa =  '+QuotedStr(cod_empresa)+
                                    ' AND cod_item NOT IN (SELECT cod_item FROM itens_invent_grade WHERE cod_empresa = '+QuotedStr(cod_empresa)+') ';
                qryData.Open;

                cData := qryData.FieldByName('dat_selecao').AsString;
                cHora := qryData.FieldByName('hor_selecao').AsString;
              end;

            // verifica se existe na itens_invent
            qrygen.Close;
            qryGen.SQL.Text := ' SELECT count(*)        '+
                               ' FROM itens_invent      '+
                               ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                               ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                               ' AND cod_local_estoq = '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                               ' AND ies_situa_qtd = '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                               ' AND num_lote '+ iif(trim(qryItens.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)));
            qryGen.Open;

            if ((not qryGen.Eof) and (qryGen.Fields[0].AsInteger > 0)) then
              begin
                cmd.CommandText := ' UPDATE itens_invent SET      '+
                                   ' qtd_estoque_cont = '+iif(Base_Dados = 2,' isnull', ' nvl')+'(qtd_estoque_cont,0) + '+StringReplace(StringReplace(qryItens.FieldByName('qtd_contada').Value,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+
                                   ' ,ies_situacao = ''D'' '+
                                   ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                   ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                   ' AND cod_local_estoq = '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                   ' AND ies_situa_qtd = '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                                   ' AND num_lote '+ iif(trim(qryItens.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)));
                cmd.Execute;
              end
            else
              begin
                //Verifico se tem estoque e jogo a qtd_saldo na variavel para gravar item_invent
                qrygen.Close;
                qryGen.SQL.Text := ' SELECT *        '+
                                   ' FROM estoque_lote      '+
                                   ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                   ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                   ' AND cod_local = '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                   ' AND ies_situa_qtd = '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                                   ' AND num_lote '+ iif(trim(qryItens.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)));
                qryGen.Open;

                if not qryGen.IsEmpty then
                  cQtdSaldo := qryGen.FieldByName('qtd_saldo').AsString;

                cmd.CommandText := ' INSERT INTO itens_invent (cod_empresa, cod_item, ies_tip_item, cod_local_estoq, cod_sublocacao, num_lote, ies_situa_qtd, qtd_estoque_sist, qtd_estoque_cont, '+
                                   ' dat_selecao, hor_selecao, num_cartao, num_seq, ies_situacao, num_cartao_orig, num_seq_orig) '+
                                   ' VALUES ('+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+', '+QuotedStr(qryItens.FieldByName('cod_item').Value)+', '+QuotedStr(qryItens.FieldByName('ies_tip_item').Value)+', '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                             ', '+QuotedStr(qryItens.FieldByName('cod_local').Value)+', '+iif(trim(qryItens.FieldByName('num_lote').AsString)='',' null ', QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)))+', '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                                             ', '+StringReplace(StringReplace(cQtdSaldo,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+', '+StringReplace(StringReplace(qryItens.FieldByName('qtd_contada').Value,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+
                                             ', '+QuotedStr(FormatDateTime('dd-mm-yyyy',StrToDateTime(cData)))+' , '+QuotedStr(cHora)+', 0, 1, ''D'', 0, 1)';
                cmd.Execute;

                qrygen2.Close;
                qryGen2.SQL.Text := ' SELECT * FROM estoque_lote '+
                                    ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                    ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                    ' AND num_lote <> '+QuotedStr(qryItens.FieldByName('num_lote').AsString);
                qryGen2.Open;

                while not qryGen2.Eof do
                  begin
                    cQtdSaldo := qryGen2.FieldByName('qtd_saldo').AsString;

                    qrygen.Close;
                    qryGen.SQL.Text := ' SELECT count(*)        '+
                                       ' FROM itens_invent      '+
                                       ' WHERE cod_empresa = '+QuotedStr(qryGen2.FieldByName('cod_empresa').Value)+
                                       ' AND cod_item = '+QuotedStr(qryGen2.FieldByName('cod_item').Value)+
                                       ' AND cod_local_estoq = '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+
                                       ' AND ies_situa_qtd = '+QuotedStr(qryGen2.FieldByName('ies_situa_qtd').Value)+
                                       ' AND num_lote '+ iif(trim(qryGen2.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryGen2.FieldByName('num_lote').AsString)));
                    qryGen.Open;

                    if ((not qryGen.Eof) and (qryGen.Fields[0].AsInteger = 0)) then
                      begin
                        cmd.CommandText := ' INSERT INTO itens_invent (cod_empresa, cod_item, ies_tip_item, cod_local_estoq, cod_sublocacao, num_lote, ies_situa_qtd, qtd_estoque_sist, qtd_estoque_cont, '+
                                           ' dat_selecao, hor_selecao, num_cartao, num_seq, ies_situacao, num_cartao_orig, num_seq_orig) '+
                                           ' VALUES ('+QuotedStr(qryGen2.FieldByName('cod_empresa').Value)+', '+QuotedStr(qryGen2.FieldByName('cod_item').Value)+', '+QuotedStr(qryItens.FieldByName('ies_tip_item').Value)+', '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+
                                                     ', '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+', '+iif(trim(qryGen2.FieldByName('num_lote').AsString)='',' null ', QuotedStr(trim(qryGen2.FieldByName('num_lote').AsString)))+', '+QuotedStr(qryGen2.FieldByName('ies_situa_qtd').Value)+
                                                     ', '+StringReplace(StringReplace(cQtdSaldo,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+', 0, '+QuotedStr(FormatDateTime('dd-mm-yyyy',StrToDateTime(cData)))+' , '+QuotedStr(cHora)+', 0, 1, ''D'', 0, 1)';
                        cmd.Execute;
                      end;
                    qryGen2.Next;
                  end;
              end;

            // ITENS COM CONTROLE DIMENSIONAL
            cQtdSaldo := '0';
            if qryItens.FieldByName('ies_dimensional').AsString = 'S' then
              begin
                // verifica se existe na itens_invent_grade
                qrygen.Close;
                qryGen.SQL.Text := 'SELECT num_trans         '+
                                   ' FROM itens_invent_grade '+
                                   ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                   ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                   ' AND cod_local_estoq = '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                   ' AND ies_situa_qtd = '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                                   ' AND num_lote '+ iif(trim(qryItens.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)))+
                                   ' AND endereco = '+QuotedStr(qryItens.FieldByName('endereco').Value)+
                                   ' AND num_volume = '+qryItens.FieldByName('num_volume').AsString+
                                   ' AND dat_hor_producao = '+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_producao').AsDateTime))+
                                   ' AND dat_hor_valid = '+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_validade').AsDateTime))+
                                   ' AND peca = '+QuotedStr(qryItens.FieldByName('num_peca').AsString)+
                                   ' AND serie = '+QuotedStr(qryItens.FieldByName('num_serie').AsString)+
                                   ' AND comprimento = '+qryItens.FieldByName('comprimento').AsString+
                                   ' AND largura = '+qryItens.FieldByName('largura').AsString+
                                   ' AND altura = '+qryItens.FieldByName('altura').AsString+
                                   ' AND diametro = '+qryItens.FieldByName('diametro').AsString;
                qryGen.Open;

                if ((not qryGen.Eof) and (qryGen.Fields[0].AsInteger > 0)) then
                  begin
                    cmd.CommandText := ' UPDATE itens_invent_grade SET      '+
                                       ' qtd_estoque_cont = '+iif(Base_Dados = 2,' isnull', ' nvl')+'(qtd_estoque_cont,0) + '+StringReplace(StringReplace(qryItens.FieldByName('qtd_contada').Value,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+
                                       ' ,ies_situacao = ''D'' '+
                                       ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                       ' AND num_trans = '+qryGen.Fields[0].AsString;
                    cmd.Execute;
                  end
                else
                  begin
                    qrygen.Close;
                    qryGen.SQL.Text := ' SELECT *        '+
                                       ' FROM estoque_lote      '+
                                       ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                       ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                       ' AND cod_local = '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                       ' AND ies_situa_qtd = '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+
                                       ' AND num_lote '+ iif(trim(qryItens.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)));
                    qryGen.Open;

                    if not qryGen.IsEmpty then
                      cQtdSaldo := qryGen.FieldByName('qtd_saldo').AsString;

                    cmd.CommandText := 'INSERT INTO itens_invent_grade (cod_empresa, '+iif(Base_Dados = 2,'','num_trans,')+' cod_item, cod_grade_1, cod_grade_2, cod_grade_3, cod_grade_4, cod_grade_5, ies_tip_item, cod_local_estoq, cod_sublocacao, num_lote, ies_situa_qtd,'+
                                       '                                qtd_estoque_sist, qtd_estoque_cont, dat_selecao, hor_selecao, num_cartao, num_seq, ies_situacao, num_cartao_orig, num_seq_orig, origem_info, endereco, num_volume, '+
                                       '                                dat_hor_producao, dat_hor_valid, peca, serie, comprimento, largura, altura, diametro, dat_hor_reserva_1, dat_hor_reserva_2, dat_hor_reserva_3, qtd_reservada_1, qtd_reservada_2,'+
                                       '                                qtd_reservada_3, num_reserva_1, num_reserva_2, num_reserva_3, texto_reservado) VALUES '+
                                       ' ('+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+', '+iif(Base_Dados = 2,'','0,')+' '+QuotedStr(qryItens.FieldByName('cod_item').Value)+', '' '', '' '', '' '', '' '', '' '', '+QuotedStr(qryItens.FieldByName('ies_tip_item').Value)+', '+QuotedStr(qryItens.FieldByName('cod_local').Value)+', '+QuotedStr(qryItens.FieldByName('cod_local').Value)+
                                       ' , '+iif(trim(qryItens.FieldByName('num_lote').AsString)='',' null ', QuotedStr(trim(qryItens.FieldByName('num_lote').AsString)))+', '+QuotedStr(qryItens.FieldByName('ies_situa_qtd').Value)+', '+StringReplace(StringReplace(cQtdSaldo,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+', '+StringReplace(StringReplace(qryItens.FieldByName('qtd_contada').Value,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+
                                       ' , '+QuotedStr(FormatDateTime('dd-mm-yyyy',StrToDateTime(cData)))+', '+QuotedStr(cHora)+', 0, 0, ''D'', 0, 0, ''D'', '+QuotedStr(qryItens.FieldByName('endereco').Value)+', '+qryItens.FieldByName('num_volume').AsString+
                                       ' , '+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_producao').AsDateTime))+','+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_validade').AsDateTime))+', '+QuotedStr(qryItens.FieldByName('num_peca').AsString)+
                                       ' , '+QuotedStr(qryItens.FieldByName('num_serie').AsString)+
                                       ' , '+qryItens.FieldByName('comprimento').AsString+', '+qryItens.FieldByName('largura').AsString+', '+qryItens.FieldByName('altura').AsString+', '+qryItens.FieldByName('diametro').AsString+', ''01/01/1900'', ''01/01/1900'', ''01/01/1900'', 0, 0, 0, 0, 0, 0, '' '')';
                    cmd.Execute;
                    
                    qrygen2.Close;
                    qryGen2.SQL.Text := ' SELECT * FROM estoque_lote '+
                                        ' WHERE cod_empresa = '+QuotedStr(qryItens.FieldByName('cod_empresa').Value)+
                                        ' AND cod_item = '+QuotedStr(qryItens.FieldByName('cod_item').Value)+
                                        ' AND num_lote <> '+QuotedStr(qryItens.FieldByName('num_lote').AsString);
                    qryGen2.Open;

                    while not qryGen2.Eof do
                      begin
                        cQtdSaldo := qryGen2.FieldByName('qtd_saldo').AsString;

                        qrygen.Close;
                        qryGen.SQL.Text := ' SELECT count(*)         '+
                                           ' FROM itens_invent_grade '+
                                           ' WHERE cod_empresa = '+QuotedStr(qryGen2.FieldByName('cod_empresa').Value)+
                                           ' AND cod_item = '+QuotedStr(qryGen2.FieldByName('cod_item').Value)+
                                           ' AND cod_local_estoq = '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+
                                           ' AND ies_situa_qtd = '+QuotedStr(qryGen2.FieldByName('ies_situa_qtd').Value)+
                                           ' AND num_lote '+ iif(trim(qryGen2.FieldByName('num_lote').AsString)='',' is null ', ' = '+QuotedStr(trim(qryGen2.FieldByName('num_lote').AsString)));
                        qryGen.Open;

                        if ((not qryGen.Eof) and (qryGen.Fields[0].AsInteger = 0)) then
                          begin
                            qrygen.Close;

                            cmd.CommandText := 'INSERT INTO itens_invent_grade (cod_empresa, '+iif(Base_Dados = 2,'','num_trans,')+' cod_item, cod_grade_1, cod_grade_2, cod_grade_3, cod_grade_4, cod_grade_5, ies_tip_item, cod_local_estoq, cod_sublocacao, num_lote, ies_situa_qtd,'+
                                           '                                qtd_estoque_sist, qtd_estoque_cont, dat_selecao, hor_selecao, num_cartao, num_seq, ies_situacao, num_cartao_orig, num_seq_orig, origem_info, endereco, num_volume, '+
                                           '                                dat_hor_producao, dat_hor_valid, peca, serie, comprimento, largura, altura, diametro, dat_hor_reserva_1, dat_hor_reserva_2, dat_hor_reserva_3, qtd_reservada_1, qtd_reservada_2,'+
                                           '                                qtd_reservada_3, num_reserva_1, num_reserva_2, num_reserva_3, texto_reservado) VALUES '+
                                           ' ('+QuotedStr(qryGen2.FieldByName('cod_empresa').Value)+', '+iif(Base_Dados = 2,'','0,')+' '+QuotedStr(qryGen2.FieldByName('cod_item').Value)+', '' '', '' '', '' '', '' '', '' '', '+QuotedStr(qryItens.FieldByName('ies_tip_item').Value)+', '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+', '+QuotedStr(qryGen2.FieldByName('cod_local').Value)+
                                           ' , '+iif(trim(qryGen2.FieldByName('num_lote').AsString)='',' null ', QuotedStr(trim(qryGen2.FieldByName('num_lote').AsString)))+', '+QuotedStr(qryGen2.FieldByName('ies_situa_qtd').Value)+', '+StringReplace(StringReplace(cQtdSaldo,'.','',[rfReplaceAll]),',','.',[rfReplaceAll])+', 0 '+
                                           ' , '+QuotedStr(FormatDateTime('dd-mm-yyyy',StrToDateTime(cData)))+', '+QuotedStr(cHora)+', 0, 0, ''D'', 0, 0, ''D'', '+QuotedStr(qryItens.FieldByName('endereco').Value)+', '+qryItens.FieldByName('num_volume').AsString+
                                           ' , '+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_producao').AsDateTime))+','+QuotedStr(FormatDateTime('dd-mm-yyyy',qryItens.FieldByName('dat_hor_validade').AsDateTime))+', '+QuotedStr(qryItens.FieldByName('num_peca').AsString)+
                                           ' , '+QuotedStr(qryItens.FieldByName('num_serie').AsString)+
                                           ' , '+qryItens.FieldByName('comprimento').AsString+', '+qryItens.FieldByName('largura').AsString+', '+qryItens.FieldByName('altura').AsString+', '+qryItens.FieldByName('diametro').AsString+', ''01/01/1900'', ''01/01/1900'', ''01/01/1900'', 0, 0, 0, 0, 0, 0, '' '')';
                            cmd.Execute;
                          end;
                        qryGen2.Next;
                      end;
                  end;
              end;
            qryItens.Next;
          end;
        dmConexao.connInformix.CommitTrans;
        screen.Cursor := crDefault;
        MessageDlg('Dados exportados com sucesso.', mtInformation ,[mbOk], 0);
      except on e:Exception do
        begin
          dmConexao.connInformix.RollbackTrans;
          screen.Cursor := crDefault;
          MessageDlg('Falha na exportação dos dados.'+#13+'Reinicie a aplicação e tente novamente.'+#13+e.Message, mtError ,[mbOk], 0);
        end;
      end;

    end;
end;

procedure TfrmPrincipal.btnExcelClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    begin
      screen.Cursor := crHourGlass;
      ExportGrid4ToExcel(SaveDialog1.FileName,cxGrid1);
      screen.Cursor := crDefault;
      MessageDlg('Dados exportados com sucesso.', mtInformation ,[mbOk], 0);
    end;
end;

procedure TfrmPrincipal.edtItemKeyPress(Sender: TObject; var Key: Char);
var cod_item,cod_local,num_lote: string;
    comprimento: real;
    tmp_serie_ife: integer;
begin
  if Key = #13 then
    begin
      if inv_serie_ife = 'S' then
        begin
          if(Pos('|',edtItem.Text) = 0) then
            begin
              qrygen.Close;
              qryGen.SQL.Text := 'SELECT cod_item,cod_local,num_lote,comprimento FROM etiq_887 WHERE cod_empresa='+QuotedStr(cod_empresa)+' AND serie = '+trim(edtItem.Text);
              qryGen.Open;

              if not qryGen.IsEmpty then
                begin
                  tmp_serie_ife := strtoint(trim(edtItem.Text));
                  cod_item := trim(qryGen.Fields[0].AsString);
                  cod_local := trim(qryGen.Fields[1].AsString);
                  num_lote := trim(qryGen.Fields[2].AsString);
                  comprimento := qryGen.Fields[3].AsFloat;

                  // subsstitui a serie pelo item encontrado
                  edtItem.Text := cod_item;
                  // Já muda o foco do campo, pois o programa irá executar as validações
                  edtFolha.SetFocus;

                  // Grava a serie na variável global
                  serie_ife := tmp_serie_ife;

                  // Atualiza os campos pela etiqueta
                  qryGen.Close;
                  qrygen.SQL.Text := 'SELECT cod_local,den_local FROM local WHERE cod_empresa = '+QuotedStr(cod_empresa)+'  AND cod_local = '+QuotedStr(cod_local);
                  qrygen.Open;

                  if not qryGen.IsEmpty then
                    edtLocalEst.ItemIndex := edtLocalEst.Properties.Items.IndexOf(trim(qryGen.Fields[0].AsString)+' | '+trim(qryGen.Fields[1].AsString));

                  edtLote.Text := num_lote;

                  edtQtd.Value := comprimento;
                end
              else
                begin
                  serie_ife := 0;
                end;
            end;
        end;
    end;
end;

function TfrmPrincipal.iif(Condicao: Boolean; Verdadeiro,
  Falso: Variant): Variant;
begin
   if Condicao then
      Result := Verdadeiro
   else
      Result := Falso;
end;

end.

#---------------------------------------------------------------#
#--Objetivo: Efetuar apontamento dos dados contidos no record---#
#                        p_man                                  #
#--------------------------par�metros---------------------------#
#                           nenhum                              #
#--------------------------retorno l�gico-----------------------#
#             TRUE, processo completado;                        #
#            FALSE, pocesso interrompido por um erro critico    #
#---------------------------------------------------------------#
 
DATABASE logix

GLOBALS
   DEFINE p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,         
          p_status             SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          sql_stmt             CHAR(900),
          p_caminho            CHAR(080),
          p_ies_tip_movto      CHAR(01),
          p_transac_consumo    INTEGER,
          p_transac_apont      INTEGER,
          p_transac_pai        INTEGER,
          p_num_trans_atual    INTEGER,
          p_msg                CHAR(150),
          p_mensagem           CHAR(150),
          p_ies_situa          CHAR(01),
          p_num_seq_orig       INTEGER,
          p_cod_tip_apon       CHAR(01),
          p_num_seq_apo_mestre INTEGER, 
          p_num_seq_apo_oper   INTEGER,
          p_ies_sucata         SMALLINT
          
DEFINE p_dat_movto             DATE,
       p_dat_proces            DATE,
       p_hor_operac            CHAR(08),
       p_qtd_movto             DECIMAL(10,3)

DEFINE p_seq_reg_mestre     INTEGER,
       p_num_seq_reg        INTEGER,
       p_tip_movto          CHAR(01),
       p_ies_ctr_lote       CHAR(01),
       p_tip_producao       CHAR(01)
       
DEFINE p_cod_oper_sp         LIKE par_pcp.cod_estoque_sp,        
       p_cod_oper_rp         LIKE par_pcp.cod_estoque_rp,           
       p_cod_oper_sucata     LIKE par_pcp.cod_estoque_rn,   
       p_cod_local_refug     LIKE item.cod_local_estoq,             
       p_cod_local_sucat     LIKE item.cod_local_estoq,             
       p_cod_local_retrab    LIKE item.cod_local_estoq, 
       p_cod_local_div_qtd   LIKE item.cod_local_estoq
   
   DEFINE p_man                RECORD LIKE man_apont_885.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_parametros_885     RECORD LIKE parametros_885.*

END GLOBALS

#--vari�veis modular de uso geral--#

DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
       p_audit_logix        RECORD LIKE audit_logix.*,
       p_apont_min          RECORD LIKE apont_min.*,
       p_apo_oper           RECORD LIKE apo_oper.*,
       p_cfp_aptm           RECORD LIKE cfp_aptm.*,
       p_cfp_apms           RECORD LIKE cfp_apms.*,
       p_cfp_appr           RECORD LIKE cfp_appr.*,
       p_chf_compon         RECORD LIKE chf_componente.*,
       p_man_apo_mestre     RECORD LIKE man_apo_mestre.*,
       p_man_apo_detalhe    RECORD LIKE man_apo_detalhe.*,
       p_man_tempo_producao RECORD LIKE man_tempo_producao.*,
       p_man_comp_consumido RECORD LIKE man_comp_consumido.*,
       p_man_item_produzido RECORD LIKE man_item_produzido.*,
       p_programa           RECORD LIKE man_apo_nest_405.*

DEFINE p_qtd_boas           LIKE ordens.qtd_planej,
       p_qtd_refug          LIKE ordens.qtd_planej,
       p_qtd_sucata         LIKE ordens.qtd_planej,
       p_qtd_apont          LIKE ordens.qtd_planej,
       p_cod_local_estoq    LIKE item.cod_local_estoq,
       p_qtd_estorno        LIKE ordens.qtd_planej
       
DEFINE p_tip_operacao       CHAR(01),
       p_num_transac        INTEGER,
       p_num_ordem          INTEGER,
       m_cod_item           CHAR(15)    

#----------------------------------#
FUNCTION pol1269b_aponta_producao()#
#----------------------------------#

   LET p_msg = NULL
   LET p_ies_tip_movto = 'N'
      
   IF p_man.tip_movto = 'R' THEN          #apontamento de refugo
      LET p_qtd_refug  = p_man.qtd_movto
      LET p_qtd_boas = 0
      LET p_qtd_sucata = 0
      LET p_tip_producao = "R"                               
      LET p_ies_situa = 'R'                                  
   ELSE
      IF p_man.tip_movto = 'S' THEN         #apontamento de sucata
         LET p_qtd_boas = 0
         LET p_qtd_refug  = 0
         LET p_qtd_sucata = p_man.qtd_movto
         LET p_tip_producao = "B"                               
         LET p_ies_situa = 'L'                                  
         LET p_man.item = p_parametros_885.cod_item_sucata          
         LET p_man.lote = p_parametros_885.num_lote_sucata
         IF p_man.lote = ' ' THEN
            LET p_man.lote = NULL
         END IF
         LET p_man.comprimento = 0
         LET p_man.largura = 0
         LET p_man.altura = 0
         LET p_man.diametro = 0
         LET p_cod_oper_rp = p_cod_oper_sucata
      ELSE                            #apontamento de boas
         LET p_qtd_refug  = 0
         
         IF p_ies_sucata THEN
            LET p_qtd_sucata = p_man.qtd_movto
            LET p_qtd_boas = 0
         ELSE
            LET p_qtd_sucata = 0
            LET p_qtd_boas = p_man.qtd_movto
         END IF
         
         LET p_tip_producao = "B"                               
         LET p_ies_situa = 'L'                                  
      END IF
   END IF

   IF NOT pol1269b_ins_mestre() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1269b_ins_detalhe() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1269b_ins_tempo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269b_grava_ordens() THEN
      RETURN FALSE
   END IF

   IF p_man.tip_movto = 'R' THEN          
      IF NOT pol1269b_ins_man_def() THEN                      
         RETURN FALSE                                        
      END IF                                                 
   END IF
   
   IF NOT pol1269_baixa_necessidade() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269b_gra_tabs_velhas() THEN                  
      RETURN FALSE                                        
   END IF                                                 
                                                                                                                          
   LET p_qtd_movto = p_man.qtd_movto                           

   IF NOT pol1269b_aponta_estoque() THEN                   
      RETURN FALSE                                        
   END IF                                                 
                                                             
   IF NOT pol1269b_insere_item_produzido() THEN                  
      RETURN FALSE                                        
   END IF                                                 
                                                          
   LET p_tip_movto = 'E'                                  
                                                          
   IF NOT pol1269b_insere_chf_componente() THEN            
      RETURN FALSE                                        
   END IF                                                 

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1269b_ins_mestre()
#----------------------------#
      
   LET p_man_apo_mestre.empresa         = p_man.empresa
   LET p_man_apo_mestre.seq_reg_mestre  = 0
   LET p_man_apo_mestre.sit_apontamento = 'A'
   LET p_man_apo_mestre.tip_moviment    = 'N'
   LET p_man_apo_mestre.data_producao   = p_dat_movto
   LET p_man_apo_mestre.ordem_producao  = p_man.ordem_producao
   LET p_man_apo_mestre.item_produzido  = p_man.item
   LET p_man_apo_mestre.secao_requisn   = ' '
   LET p_man_apo_mestre.usu_apontamento = p_user
   LET p_man_apo_mestre.data_apontamento= p_dat_proces  
   LET p_man_apo_mestre.hor_apontamento = p_hor_operac
   LET p_man_apo_mestre.usuario_estorno = ''
   LET p_man_apo_mestre.data_estorno    = ''
   LET p_man_apo_mestre.hor_estorno     = ''
   LET p_man_apo_mestre.apo_automatico  = 'N'
   LET p_man_apo_mestre.seq_reg_origem  = ''
   LET p_man_apo_mestre.observacao      = ''
   LET p_man_apo_mestre.seq_registro_integracao = ''

   INSERT INTO man_apo_mestre (
      empresa, 
      #seq_reg_mestre,
      sit_apontamento, 
      tip_moviment, 
      data_producao, 
      ordem_producao, 
      item_produzido, 
      secao_requisn, 
      usu_apontamento, 
      data_apontamento, 
      hor_apontamento, 
      usuario_estorno, 
      data_estorno, 
      hor_estorno, 
      apo_automatico, 
      seq_reg_origem, 
      observacao, 
      seq_registro_integracao) 
   VALUES(p_man_apo_mestre.empresa,  
          #p_man_apo_mestre.seq_reg_mestre,       
          p_man_apo_mestre.sit_apontamento, 
          p_man_apo_mestre.tip_moviment,    
          p_man_apo_mestre.data_producao,   
          p_man_apo_mestre.ordem_producao,  
          p_man_apo_mestre.item_produzido,  
          p_man_apo_mestre.secao_requisn,   
          p_man_apo_mestre.usu_apontamento, 
          p_man_apo_mestre.data_apontamento,
          p_man_apo_mestre.hor_apontamento, 
          p_man_apo_mestre.usuario_estorno, 
          p_man_apo_mestre.data_estorno,    
          p_man_apo_mestre.hor_estorno,     
          p_man_apo_mestre.apo_automatico,  
          p_man_apo_mestre.seq_reg_origem,  
          p_man_apo_mestre.observacao,      
          p_man_apo_mestre.seq_registro_integracao)
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA MAN_APO_MESTRE'  
      RETURN FALSE
   END IF  

   LET p_seq_reg_mestre = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1269b_ins_detalhe()
#----------------------------#
      
   LET p_man_apo_detalhe.empresa            = p_man.empresa
   LET p_man_apo_detalhe.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_apo_detalhe.roteiro_fabr       = p_man.cod_roteiro
   LET p_man_apo_detalhe.altern_roteiro     = p_man.altern_roteiro
   LET p_man_apo_detalhe.sequencia_operacao = NULL
   LET p_man_apo_detalhe.operacao           = p_man.operacao
   LET p_man_apo_detalhe.unid_produtiva     = p_man.unid_produtiva
   LET p_man_apo_detalhe.centro_trabalho    = p_man.centro_trabalho
   LET p_man_apo_detalhe.arranjo_fisico     = p_man.arranjo
   LET p_man_apo_detalhe.centro_custo       = p_man.centro_custo
   LET p_man_apo_detalhe.atualiza_eqpto_min = 'N'
   LET p_man_apo_detalhe.eqpto              = p_man.eqpto
   LET p_man_apo_detalhe.atlz_ferr_min      = 'N'
   LET p_man_apo_detalhe.ferramental        = p_man.ferramenta
   LET p_man_apo_detalhe.operador           = p_man.matricula
   LET p_man_apo_detalhe.observacao         = ''
   LET p_man_apo_detalhe.nome_programa      = p_man.nom_prog

  INSERT INTO man_apo_detalhe (
     empresa, 
     seq_reg_mestre, 
     roteiro_fabr, 
     altern_roteiro, 
     sequencia_operacao, 
     operacao, 
     unid_produtiva, 
     centro_trabalho, 
     arranjo_fisico, 
     centro_custo, 
     atualiza_eqpto_min, 
     eqpto, 
     atlz_ferr_min, 
     ferramental, 
     operador, 
     observacao,
     nome_programa)
  VALUES(p_man_apo_detalhe.empresa,           
         p_man_apo_detalhe.seq_reg_mestre,    
         p_man_apo_detalhe.roteiro_fabr,      
         p_man_apo_detalhe.altern_roteiro,    
         p_man_apo_detalhe.sequencia_operacao,
         p_man_apo_detalhe.operacao,          
         p_man_apo_detalhe.unid_produtiva,    
         p_man_apo_detalhe.centro_trabalho,   
         p_man_apo_detalhe.arranjo_fisico,    
         p_man_apo_detalhe.centro_custo,      
         p_man_apo_detalhe.atualiza_eqpto_min,
         p_man_apo_detalhe.eqpto,             
         p_man_apo_detalhe.atlz_ferr_min,     
         p_man_apo_detalhe.ferramental,       
         p_man_apo_detalhe.operador,    
         p_man_apo_detalhe.observacao,    
         p_man_apo_detalhe.nome_programa)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA MAN_APO_DETALHE'  
      RETURN FALSE
   END IF  
  
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1269b_ins_tempo()
#--------------------------#

   LET p_man_tempo_producao.empresa            = p_man.empresa
   LET p_man_tempo_producao.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_tempo_producao.seq_registro_tempo = 0
   LET p_man_tempo_producao.turno_producao     = p_man.turno
   LET p_man_tempo_producao.data_ini_producao  = p_man.dat_ini_producao
   LET p_man_tempo_producao.hor_ini_producao   = p_man.hor_inicial
   LET p_man_tempo_producao.dat_final_producao = p_man.dat_fim_producao
   LET p_man_tempo_producao.hor_final_producao = p_man.hor_fim
   LET p_man_tempo_producao.periodo_produtivo  = 'A' # Tipo A=produ��o Tipo I=parada
   LET p_man_tempo_producao.tempo_tot_producao = p_man.qtd_hor 
   LET p_man_tempo_producao.tmp_ativo_producao = p_man.qtd_hor #descontar tempo de paradas, se houver
   LET p_man_tempo_producao.tmp_inatv_producao = 0 # tempo da parada, se for tipo I
   
   INSERT INTO man_tempo_producao(
      empresa,           
      seq_reg_mestre,    
      #seq_registro_tempo,
      turno_producao,    
      data_ini_producao, 
      hor_ini_producao,  
      dat_final_producao,
      hor_final_producao,
      periodo_produtivo, 
      tempo_tot_producao,
      tmp_ativo_producao,
      tmp_inatv_producao)
   VALUES(p_man_tempo_producao.empresa,           
          p_man_tempo_producao.seq_reg_mestre,    
          #p_man_tempo_producao.seq_registro_tempo,
          p_man_tempo_producao.turno_producao,    
          p_man_tempo_producao.data_ini_producao, 
          p_man_tempo_producao.hor_ini_producao,  
          p_man_tempo_producao.dat_final_producao,
          p_man_tempo_producao.hor_final_producao,
          p_man_tempo_producao.periodo_produtivo, 
          p_man_tempo_producao.tempo_tot_producao,
          p_man_tempo_producao.tmp_ativo_producao,
          p_man_tempo_producao.tmp_inatv_producao)
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA MAN_TEMPO_PRODUCAO'  
      RETURN FALSE
   END IF  
  
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1269b_grava_ordens()
#-----------------------------#
   
   DEFINE p_dat_inicio LIKE ordens.dat_ini
   
   SELECT dat_ini
     INTO p_dat_inicio
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.ordem_producao

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS.DAT_INI'  
      RETURN FALSE
   END IF

   IF p_dat_inicio is null then
      LET p_dat_inicio = p_dat_movto
   END IF

   UPDATE ordens
      SET qtd_boas   = qtd_boas + p_qtd_boas,
          qtd_refug  = qtd_refug + p_qtd_refug,
          qtd_sucata = qtd_sucata + p_qtd_sucata,
          dat_ini    = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.ordem_producao

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS.DAT_INI'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1269b_gra_tabs_velhas()
#---------------------------------#
  
  DEFINE p_dat_char    CHAR(23)
  
  LET p_apo_oper.cod_empresa     = p_man.empresa
  LET p_apo_oper.dat_producao    = p_dat_movto
  LET p_apo_oper.cod_item        = p_man.item
  LET p_apo_oper.num_ordem       = p_man.ordem_producao
  LET p_apo_oper.num_seq_operac  = p_man.sequencia_operacao
  LET p_apo_oper.cod_operac      = p_man.operacao
  LET p_apo_oper.cod_cent_trab   = p_man.centro_trabalho
  LET p_apo_oper.cod_arranjo     = p_man.arranjo
  LET p_apo_oper.cod_cent_cust   = p_man.centro_custo
  LET p_apo_oper.cod_turno       = p_man.turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial
  LET p_apo_oper.hor_fim         = p_man.hor_fim
  LET p_apo_oper.qtd_boas        = p_qtd_boas
  LET p_apo_oper.qtd_refugo      = p_qtd_refug
  LET p_apo_oper.qtd_sucata      = p_qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.local
  LET p_apo_oper.cod_tip_movto   = p_ies_tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = p_dat_proces
  LET p_apo_oper.nom_usuario     = p_man.nom_usuario

  INSERT INTO apo_oper(
     cod_empresa,
     dat_producao,
     cod_item,
     num_ordem,
     num_seq_operac,
     cod_operac,
     cod_cent_trab,
     cod_arranjo,
     cod_cent_cust,
     cod_turno,
     hor_inicio,
     hor_fim,
     qtd_boas,
     qtd_refugo,
     qtd_sucata,
     cod_tip_movto,
     num_conta,
     cod_local,
     qtd_horas,
     dat_apontamento,
     nom_usuario)
     
   VALUES(
     p_apo_oper.cod_empresa,
     p_apo_oper.dat_producao,
     p_apo_oper.cod_item,
     p_apo_oper.num_ordem,
     p_apo_oper.num_seq_operac,
     p_apo_oper.cod_operac,
     p_apo_oper.cod_cent_trab,
     p_apo_oper.cod_arranjo,
     p_apo_oper.cod_cent_cust,
     p_apo_oper.cod_turno,
     p_apo_oper.hor_inicio,
     p_apo_oper.hor_fim,
     p_apo_oper.qtd_boas,
     p_apo_oper.qtd_refugo,
     p_apo_oper.qtd_sucata,
     p_apo_oper.cod_tip_movto,
     p_apo_oper.num_conta,
     p_apo_oper.cod_local,
     p_apo_oper.qtd_horas,
     p_apo_oper.dat_apontamento,
     p_apo_oper.nom_usuario)

 
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA APO_OPER'  
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2] # apo_oper.num_processo

  LET p_cfp_apms.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_apms.num_seq_registro = p_num_seq_reg
  LET p_cfp_apms.cod_tip_movto    = p_apo_oper.cod_tip_movto
  LET p_cfp_apms.ies_situa    = "A"
  LET p_cfp_apms.dat_producao   = p_apo_oper.dat_producao
  LET p_cfp_apms.num_ordem      = p_apo_oper.num_ordem
  
  IF p_man.eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET p_cfp_apms.cod_cent_trab      = p_apo_oper.cod_cent_trab
  LET p_cfp_apms.cod_unid_prod      = p_man.unid_produtiva
  LET p_cfp_apms.cod_roteiro        = p_man.cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_man.altern_roteiro
  LET p_cfp_apms.num_seq_operac     = NULL
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = p_apo_oper.num_conta
  LET p_cfp_apms.cod_local          = p_apo_oper.cod_local
  LET p_cfp_apms.dat_apontamento    = p_dat_proces
  LET p_cfp_apms.hor_apontamento    = p_hor_operac
  LET p_cfp_apms.nom_usuario_resp   = p_apo_oper.nom_usuario
  LET p_cfp_apms.tex_apont          = NULL
  LET p_cfp_apms.dat_estorno     = NULL
  LET p_cfp_apms.hor_estorno     = NULL
  LET p_cfp_apms.nom_usu_estorno = NULL

  INSERT INTO cfp_apms VALUES(p_cfp_apms.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA CFP_APMS'  
      RETURN FALSE
   END IF

  LET p_qtd_apont = p_apo_oper.qtd_boas+p_apo_oper.qtd_refugo+p_apo_oper.qtd_sucata

  LET p_cfp_appr.cod_empresa        = p_apo_oper.cod_empresa
  LET p_cfp_appr.num_seq_registro   = p_num_seq_reg
  LET p_cfp_appr.dat_producao       = p_apo_oper.dat_producao
  LET p_cfp_appr.cod_item           = p_apo_oper.cod_item
  LET p_cfp_appr.cod_turno          = p_apo_oper.cod_turno
  LET p_cfp_appr.qtd_produzidas     = p_qtd_apont
  LET p_cfp_appr.qtd_pecas_boas     = p_apo_oper.qtd_boas
  LET p_cfp_appr.qtd_sucata         = p_apo_oper.qtd_sucata
  LET p_cfp_appr.qtd_defeito_real   = p_apo_oper.qtd_refugo
  LET p_cfp_appr.qtd_defeito_padrao = 0
  LET p_cfp_appr.qtd_ciclos         = 0
  LET p_cfp_appr.num_operador       = p_man.matricula

  INSERT INTO cfp_appr VALUES(p_cfp_appr.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA CFP_APMS'  
      RETURN FALSE
   END IF

  LET p_cfp_aptm.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_aptm.num_seq_registro = p_num_seq_reg
  LET p_cfp_aptm.dat_producao     = p_apo_oper.dat_producao
  LET p_cfp_aptm.cod_turno        = p_apo_oper.cod_turno
  LET p_cfp_aptm.ies_periodo      = "A"
  LET p_cfp_aptm.cod_parada       = NULL

  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_fim
  LET p_cfp_aptm.hor_fim_periodo = p_dat_char
  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_inicio
  LET p_cfp_aptm.hor_ini_periodo = p_dat_char

  LET p_cfp_aptm.hor_ini_assumido = p_cfp_aptm.hor_ini_periodo
  LET p_cfp_aptm.hor_fim_assumido = p_cfp_aptm.hor_fim_periodo
  LET p_cfp_aptm.hor_tot_periodo  = p_man.qtd_hor 
  LET p_cfp_aptm.hor_tot_assumido = p_cfp_aptm.hor_tot_periodo

  INSERT INTO cfp_aptm VALUES(p_cfp_aptm.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA CFP_APTM'  
      RETURN FALSE
   END IF
   
   INSERT INTO man_relc_tabela
    VALUES(p_man.empresa,
           p_seq_reg_mestre,
           p_num_seq_reg,
           p_tip_producao)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA MAN_RELC_TABELA'  
      RETURN FALSE
   END IF

   INSERT INTO apont_sequencia_885 #ser� utilizada na rotina de estorno
    VALUES(p_man.empresa,
           p_man.num_seq_apont,
           p_seq_reg_mestre,
           p_num_seq_reg)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA APONT_SEQUENCIA_885'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1269b_aponta_estoque()#
#--------------------------------#

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
      
   LET p_cod_tip_apon = 'A'

   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO p_cod_local_estoq,
          p_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_man.empresa
      AND cod_item = p_man.item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO CTR LOTE DA TABELA ITEM: ',p_man.item  
      RETURN FALSE
   END IF
      
   LET p_item.cod_empresa   = p_man.empresa
   LET p_item.cod_item      = p_man.item
   LET p_item.cod_local     = p_cod_local_estoq
   LET p_item.num_lote      = p_man.lote
   LET p_item.comprimento   = p_man.comprimento
   LET p_item.largura       = p_man.largura    
   LET p_item.altura        = p_man.altura     
   LET p_item.diametro      = p_man.diametro  
    
   LET p_item.cod_operacao  = p_cod_oper_rp
   
   LET p_item.ies_situa     = p_ies_situa
   LET p_item.qtd_movto     = p_qtd_movto
   LET p_item.dat_movto     = p_dat_movto
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.num_prog      = p_man.nom_prog
   LET p_item.num_docum     = p_man.ordem_producao
   LET p_item.num_seq       = 0
   
   LET p_item.tip_operacao  = 'E' #Entrada
   
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.turno
   LET p_item.trans_origem  = 0
   LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
   
   LET p_transac_apont = p_num_trans_atual
   LET p_transac_pai = p_num_trans_atual

   IF NOT pol1269_ins_transacoes() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1269b_insere_item_produzido()#
#----------------------------------------#

   LET p_man_item_produzido.empresa               = p_man.empresa
   LET p_man_item_produzido.seq_reg_mestre        = p_seq_reg_mestre
   LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   LET p_man_item_produzido.tip_movto             = 'N'
   LET p_man_item_produzido.item_produzido        = p_estoque_lote_ender.cod_item
   LET p_man_item_produzido.lote_produzido        = p_estoque_lote_ender.num_lote
   LET p_man_item_produzido.grade_1               = p_estoque_lote_ender.cod_grade_1
   LET p_man_item_produzido.grade_2               = p_estoque_lote_ender.cod_grade_2
   LET p_man_item_produzido.grade_3               = p_estoque_lote_ender.cod_grade_3
   LET p_man_item_produzido.grade_4               = p_estoque_lote_ender.cod_grade_4
   LET p_man_item_produzido.grade_5               = p_estoque_lote_ender.cod_grade_5
   LET p_man_item_produzido.num_peca              = p_estoque_lote_ender.num_peca
   LET p_man_item_produzido.serie                 = p_estoque_lote_ender.num_serie
   LET p_man_item_produzido.volume                = p_estoque_lote_ender.num_volume
   LET p_man_item_produzido.comprimento           = p_estoque_lote_ender.comprimento
   LET p_man_item_produzido.largura               = p_estoque_lote_ender.largura
   LET p_man_item_produzido.altura                = p_estoque_lote_ender.altura
   LET p_man_item_produzido.diametro              = p_estoque_lote_ender.diametro
   LET p_man_item_produzido.local                 = p_estoque_lote_ender.cod_local
   LET p_man_item_produzido.endereco              = p_estoque_lote_ender.endereco
   LET p_man_item_produzido.tip_producao          = p_tip_producao
   LET p_man_item_produzido.qtd_produzida         = p_qtd_movto
   LET p_man_item_produzido.qtd_convertida        = 0
   LET p_man_item_produzido.sit_est_producao      = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_item_produzido.data_producao         = p_estoque_lote_ender.dat_hor_producao
   LET p_man_item_produzido.data_valid            = p_estoque_lote_ender.dat_hor_validade
   LET p_man_item_produzido.conta_ctbl            = ''
   LET p_man_item_produzido.moviment_estoque      = p_transac_pai
   LET p_man_item_produzido.seq_reg_normal        = ''
   LET p_man_item_produzido.observacao            = p_estoque_lote_ender.tex_reservado
   LET p_man_item_produzido.identificacao_estoque = ' '
   
   IF NOT pol1269b_ins_item_produzido() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1269b_ins_item_produzido()#
#-------------------------------------#
   
  INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
     #seq_registro_item,    
     tip_movto,            
     item_produzido,       
     lote_produzido,       
     grade_1,              
     grade_2,              
     grade_3,              
     grade_4,              
     grade_5,              
     num_peca,             
     serie,                
     volume,               
     comprimento,          
     largura,              
     altura,               
     diametro,             
     local,                
     endereco,             
     tip_producao,         
     qtd_produzida,        
     qtd_convertida,       
     sit_est_producao,     
     data_producao,        
     data_valid,           
     conta_ctbl,           
     moviment_estoque,     
     seq_reg_normal,       
     observacao,           
     identificacao_estoque)
   VALUES(
     p_man_item_produzido.empresa,              
     p_man_item_produzido.seq_reg_mestre,       
     #p_man_item_produzido.seq_registro_item,    
     p_man_item_produzido.tip_movto,            
     p_man_item_produzido.item_produzido,       
     p_man_item_produzido.lote_produzido,       
     p_man_item_produzido.grade_1,              
     p_man_item_produzido.grade_2,              
     p_man_item_produzido.grade_3,              
     p_man_item_produzido.grade_4,              
     p_man_item_produzido.grade_5,              
     p_man_item_produzido.num_peca,             
     p_man_item_produzido.serie,                
     p_man_item_produzido.volume,               
     p_man_item_produzido.comprimento,          
     p_man_item_produzido.largura,              
     p_man_item_produzido.altura,               
     p_man_item_produzido.diametro,             
     p_man_item_produzido.local,                
     p_man_item_produzido.endereco,             
     p_man_item_produzido.tip_producao,         
     p_man_item_produzido.qtd_produzida,        
     p_man_item_produzido.qtd_convertida,       
     p_man_item_produzido.sit_est_producao,     
     p_man_item_produzido.data_producao,        
     p_man_item_produzido.data_valid,           
     p_man_item_produzido.conta_ctbl,           
     p_man_item_produzido.moviment_estoque,     
     p_man_item_produzido.seq_reg_normal,       
     p_man_item_produzido.observacao,           
     p_man_item_produzido.identificacao_estoque)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA MAN_ITEM_PRODUZIDO'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1269b_insere_chf_componente()
#--------------------------------------#

  LET p_chf_compon.empresa            = p_estoque_lote_ender.cod_empresa
  LET p_chf_compon.sequencia_registro = p_num_seq_reg
  LET p_chf_compon.tip_movto          = p_tip_movto
  LET p_chf_compon.item_componente    = p_estoque_lote_ender.cod_item
  LET p_chf_compon.qtd_movto          = p_qtd_movto
  LET p_chf_compon.local_estocagem    = p_estoque_lote_ender.cod_local
  LET p_chf_compon.endereco           = p_estoque_lote_ender.endereco
  LET p_chf_compon.num_volume         = p_estoque_lote_ender.num_volume
  LET p_chf_compon.grade_1            = p_estoque_lote_ender.cod_grade_1
  LET p_chf_compon.grade_2            = p_estoque_lote_ender.cod_grade_2
  LET p_chf_compon.grade_3            = p_estoque_lote_ender.cod_grade_3
  LET p_chf_compon.grade_4            = p_estoque_lote_ender.cod_grade_4
  LET p_chf_compon.grade_5            = p_estoque_lote_ender.cod_grade_5
  LET p_chf_compon.pedido_venda       = p_estoque_lote_ender.num_ped_ven
  LET p_chf_compon.seq_pedido_venda   = p_estoque_lote_ender.num_seq_ped_ven
  LET p_chf_compon.sit_qtd_item       = p_estoque_lote_ender.ies_situa_qtd
  LET p_chf_compon.peca               = p_estoque_lote_ender.num_peca
  LET p_chf_compon.serie_componente   = p_estoque_lote_ender.num_serie
  LET p_chf_compon.comprimento        = p_estoque_lote_ender.comprimento
  LET p_chf_compon.largura            = p_estoque_lote_ender.largura
  LET p_chf_compon.altura             = p_estoque_lote_ender.altura
  LET p_chf_compon.diametro           = p_estoque_lote_ender.diametro
  LET p_chf_compon.lote               = p_estoque_lote_ender.num_lote
  LET p_chf_compon.dat_hor_producao   = p_estoque_lote_ender.dat_hor_producao
  LET p_chf_compon.dat_hor_validade   = p_estoque_lote_ender.dat_hor_validade
  
  if p_tip_movto = 'S' then
     LET p_chf_compon.reservado = p_tip_producao
  else
     LET p_chf_compon.reservado = null
  end if
  
  INSERT INTO chf_componente VALUES(p_chf_compon.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA CHF_COMPONENTE'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1269b_ins_man_def()
#------------------------------#
   
   INSERT INTO man_def_producao(
     empresa,
     seq_reg_mestre,
     seq_registro_item,
     motivo_defeito,
     qtd_defeito_real,
     qtd_defeito_padrao,
     observacao)
   VALUES(p_cod_empresa,
          p_seq_reg_mestre,
          1,
          0,
          p_man.qtd_movto,
          0,
          " ")
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA MAN_DEF_PRODUCAO'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1269b_insere_man_consumo()#
#-------------------------------------#

   LET p_man_comp_consumido.empresa            = p_estoque_lote_ender.cod_empresa
   LET p_man_comp_consumido.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_comp_consumido.seq_registro_item  = 0
   LET p_man_comp_consumido.tip_movto          = p_ies_tip_movto
   LET p_man_comp_consumido.item_componente    = p_estoque_lote_ender.cod_item
   LET p_man_comp_consumido.grade_1            = p_estoque_lote_ender.cod_grade_1  
   LET p_man_comp_consumido.grade_2            = p_estoque_lote_ender.cod_grade_2  
   LET p_man_comp_consumido.grade_3            = p_estoque_lote_ender.cod_grade_3  
   LET p_man_comp_consumido.grade_4            = p_estoque_lote_ender.cod_grade_4  
   LET p_man_comp_consumido.grade_5            = p_estoque_lote_ender.cod_grade_5  
   LET p_man_comp_consumido.num_peca           = p_estoque_lote_ender.num_peca     
   LET p_man_comp_consumido.serie              = p_estoque_lote_ender.num_serie    
   LET p_man_comp_consumido.volume             = p_estoque_lote_ender.num_volume   
   LET p_man_comp_consumido.comprimento        = p_estoque_lote_ender.comprimento  
   LET p_man_comp_consumido.largura            = p_estoque_lote_ender.largura      
   LET p_man_comp_consumido.altura             = p_estoque_lote_ender.altura       
   LET p_man_comp_consumido.diametro           = p_estoque_lote_ender.diametro     
   LET p_man_comp_consumido.lote_componente    = p_estoque_lote_ender.num_lote    
   LET p_man_comp_consumido.local_estoque      = p_estoque_lote_ender.cod_local     
   LET p_man_comp_consumido.endereco           = p_estoque_lote_ender.endereco
   LET p_man_comp_consumido.qtd_baixa_prevista = p_qtd_movto                        
   LET p_man_comp_consumido.qtd_baixa_real     = p_qtd_movto                        
   LET p_man_comp_consumido.sit_est_componente = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_comp_consumido.data_producao      = p_estoque_lote_ender.dat_hor_producao
   LET p_man_comp_consumido.data_valid         = p_estoque_lote_ender.dat_hor_validade
   LET p_man_comp_consumido.conta_ctbl         = ' '
   LET p_man_comp_consumido.moviment_estoque   = p_transac_consumo
   LET p_man_comp_consumido.mov_estoque_pai    = p_transac_pai
   LET p_man_comp_consumido.seq_reg_normal     = ''
   LET p_man_comp_consumido.observacao         = p_tip_producao
   LET p_man_comp_consumido.identificacao_estoque = ''
   LET p_man_comp_consumido.depositante        = ''
   
   IF NOT pol1269b_ins_man_consumo() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1269b_ins_man_consumo()#
#----------------------------------#

   INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
     #seq_registro_item, 
     tip_movto,         
     item_componente,   
     grade_1,           
     grade_2,           
     grade_3,           
     grade_4,           
     grade_5,           
     num_peca,          
     serie,             
     volume,            
     comprimento,       
     largura,           
     altura,            
     diametro,          
     lote_componente,   
     local_estoque,     
     endereco,          
     qtd_baixa_prevista,
     qtd_baixa_real,    
     sit_est_componente,
     data_producao,     
     data_valid,        
     conta_ctbl,        
     moviment_estoque,  
     mov_estoque_pai,   
     seq_reg_normal,    
     observacao,        
     identificacao_estoque,
     depositante)
   VALUES (
     p_man_comp_consumido.empresa,                   
     p_man_comp_consumido.seq_reg_mestre,    
     #p_man_comp_consumido.seq_registro_item, 
     p_man_comp_consumido.tip_movto,         
     p_man_comp_consumido.item_componente,   
     p_man_comp_consumido.grade_1,           
     p_man_comp_consumido.grade_2,           
     p_man_comp_consumido.grade_3,           
     p_man_comp_consumido.grade_4,           
     p_man_comp_consumido.grade_5,           
     p_man_comp_consumido.num_peca,         
     p_man_comp_consumido.serie,             
     p_man_comp_consumido.volume,            
     p_man_comp_consumido.comprimento,       
     p_man_comp_consumido.largura,           
     p_man_comp_consumido.altura,            
     p_man_comp_consumido.diametro,          
     p_man_comp_consumido.lote_componente,   
     p_man_comp_consumido.local_estoque,     
     p_man_comp_consumido.endereco,          
     p_man_comp_consumido.qtd_baixa_prevista,
     p_man_comp_consumido.qtd_baixa_real,    
     p_man_comp_consumido.sit_est_componente,
     p_man_comp_consumido.data_producao,     
     p_man_comp_consumido.data_valid,        
     p_man_comp_consumido.conta_ctbl,        
     p_man_comp_consumido.moviment_estoque,  
     p_man_comp_consumido.mov_estoque_pai,   
     p_man_comp_consumido.seq_reg_normal,    
     p_man_comp_consumido.observacao,        
     p_man_comp_consumido.identificacao_estoque,
     p_man_comp_consumido.depositante)     
     
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA MAN_COMP_CONSUMIDO'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1269b_insere_relac()#
#-------------------------------#
   
   DEFINE p_count INTEGER
   
   SELECT COUNT(*)
     INTO p_count
     FROM est_trans_relac 
    WHERE cod_empresa = p_cod_empresa
      AND num_transac_orig = p_transac_consumo
      AND num_transac_dest = p_transac_pai

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA EST_TRANS_RELAC'  
      RETURN FALSE
   END IF
  
   IF p_count > 0 THEN
      RETURN TRUE
   END IF
     
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto)
   VALUES(
      p_cod_empresa, 0,
      p_transac_consumo,
      p_estoque_lote_ender.cod_item,
      p_transac_pai,
      p_man.item,
      p_dat_movto)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA EST_TRANS_RELAC'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1269b_estorna_producao()#
#-----------------------------------#
   
   DEFINE p_ies_implant  CHAR(01)
   
   DECLARE cq_apo CURSOR FOR
    SELECT num_seq_apo_mestre,
           num_seq_apo_oper
      FROM apont_sequencia_885
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_apont = p_num_seq_orig
   
   FOREACH cq_apo INTO p_num_seq_apo_mestre, p_num_seq_apo_oper 
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA APONT_SEQUENCIA_885'  
         RETURN FALSE
      END IF

      IF NOT pol1269_checa_apont() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1269b_estorna_novas() THEN
         RETURN FALSE
      END IF       

      IF NOT pol1269b_estorna_velhas() THEN
         RETURN FALSE
      END IF       
   
   END FOREACH
   
   #estorna as saidas (baixa de material e poss�vei transfer�ncias)
   
   LET p_tip_operacao = 'S'
   LET p_ies_tip_movto = 'R'
   
   DECLARE cq_trans_b CURSOR FOR
    SELECT num_transac
      FROM apont_trans_885
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_apont = p_num_seq_orig
       AND cod_tip_apon = 'B'
   
   FOREACH cq_trans_b INTO p_num_transac
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA APONT_TRANS_885:B'  
         RETURN FALSE
      END IF
            
      IF NOT pol1269b_estorna_estoq() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   #estorna as entradas (apontamentos de boas ou refugos)

   LET p_tip_operacao = 'E'
   
   DECLARE cq_trans_a CURSOR FOR
    SELECT num_transac,
           ies_implant
      FROM apont_trans_885
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_apont = p_num_seq_orig
       AND cod_tip_apon = 'A'
   
   FOREACH cq_trans_a INTO p_num_transac, p_ies_implant
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA APONT_TRANS_885:A'  
         RETURN FALSE
      END IF

      IF NOT pol1269b_verif_estoq() THEN
         RETURN FALSE
      END IF
            
      IF NOT pol1269b_estorna_estoq() THEN
         RETURN FALSE
      END IF

      IF p_ies_implant = 'S' THEN
      ELSE
         IF NOT pol1269b_estorna_ordem() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH

   UPDATE apont_trans_885
      SET cod_tip_movto = 'R'
    WHERE cod_empresa = p_cod_empresa
      AND num_seq_apont = p_num_seq_orig

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO TABELA APONT_TRANS_885'
      RETURN FALSE
   END IF
   
   DELETE FROM baixas_pendentes_885
    WHERE cod_empresa = p_cod_empresa
      AND num_sequencia = p_num_seq_orig
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TABELA BAIXAS_PENDENTES_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
      
#--------------------------------#
FUNCTION pol1269b_estorna_novas()#
#--------------------------------#
   
   UPDATE man_apo_mestre 
      SET sit_apontamento = 'C',
          tip_moviment = 'E',
          usuario_estorno = p_user,
          data_estorno = p_dat_proces,
          hor_estorno = p_hor_operac
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_num_seq_apo_mestre

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA MAN_APO_MESTRE'  
      RETURN FALSE
   END IF

   DECLARE cq_est_produzido CURSOR FOR
    SELECT * 
      FROM man_item_produzido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_num_seq_apo_mestre
   
   FOREACH cq_est_produzido INTO p_man_item_produzido.*
   
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA MAN_ITEM_PRODUZIDO'
         RETURN FALSE
      END IF

      LET p_man_item_produzido.tip_movto = 'E'
      LET p_man_item_produzido.seq_registro_item = 0 #campo serial
   
      IF NOT pol1269b_ins_item_produzido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   DECLARE cq_consumo CURSOR FOR
    SELECT * 
      FROM man_comp_consumido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_num_seq_apo_mestre
   
   FOREACH cq_consumo  INTO p_man_comp_consumido.*   

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA MAN_COMP_CONSUMIDO'
         RETURN FALSE
      END IF

      LET p_man_comp_consumido.tip_movto = 'E'
      LET p_man_comp_consumido.seq_registro_item = 0 #campo serial
   
      IF NOT pol1269b_ins_man_consumo() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1269b_estorna_velhas()#
#---------------------------------#

   UPDATE apo_oper
      SET cod_tip_movto = 'E'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = p_num_seq_apo_oper

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA APO_OPER'  
      RETURN FALSE
   END IF

   UPDATE cfp_apms 
      SET cod_tip_movto = 'E',
          ies_situa = 'C', 
          dat_estorno = p_dat_proces,
          hor_estorno = p_hor_operac,
          nom_usu_estorno = p_user
    WHERE cod_empresa      = p_cod_empresa
      AND num_seq_registro = p_num_seq_apo_oper

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA CFP_APMS'  
      RETURN FALSE
   END IF

   UPDATE chf_componente
      SET tip_movto = 'R'
    WHERE empresa            = p_cod_empresa
      AND sequencia_registro = p_num_seq_apo_oper

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO APONTAMENTO DA TABELA CHF_COMPONENTE'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1269b_estorna_estoq()#
#--------------------------------#

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD
   
   DEFINE p_estoque_trans RECORD LIKE estoque_trans.*
   
   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF
   
   LET p_num_ordem = p_estoque_trans.num_docum
   LET m_cod_item = p_estoque_trans.cod_item

   LET p_item.cus_unit      = p_estoque_trans.cus_unit_movto_p
   LET p_item.cus_tot       = p_estoque_trans.cus_tot_movto_p
   LET p_item.num_conta     = p_estoque_trans.num_conta

   LET p_item.cod_empresa   = p_estoque_trans.cod_empresa
   LET p_item.cod_item      = p_estoque_trans.cod_item
   LET p_item.cod_operacao  = p_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = p_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = p_estoque_trans.dat_movto   
   LET p_item.num_prog      = p_estoque_trans.num_prog 
   LET p_item.num_docum     = p_estoque_trans.num_docum
   LET p_item.num_seq       = p_estoque_trans.num_seq  
   LET p_item.trans_origem  = p_estoque_trans.num_transac
      
   IF p_tip_operacao = 'S' THEN
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_orig
      LET p_item.num_lote      = p_estoque_trans.num_lote_orig
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_orig
   ELSE
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_dest
      LET p_item.num_lote      = p_estoque_trans.num_lote_dest
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_dest  
   END IF

   LET p_ies_situa = p_item.ies_situa #ser� usado no estorno da ordem
   LET p_qtd_estorno = p_estoque_trans.qtd_movto #ser� usado no estorno da ordem

   SELECT comprimento,
          largura,    
          altura,     
          diametro   
     INTO p_item.comprimento,  
          p_item.largura,      
          p_item.altura,       
          p_item.diametro     
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = p_tip_operacao 
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac 
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.turno
   
   SELECT ies_ctr_lote
     INTO p_item.ies_ctr_lote
     FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_item.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ITEM'  
      RETURN FALSE
   END IF
   
   IF p_item.ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   END IF
      
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1269b_verif_estoq()#
#------------------------------#
   
   DEFINE p_cod_item        LIKE estoque_lote_ender.cod_item,
          p_num_lote        LIKE estoque_lote_ender.num_lote,
          p_comprimento     LIKE estoque_lote_ender.comprimento,
          p_largura         LIKE estoque_lote_ender.largura,    
          p_altura          LIKE estoque_lote_ender.altura,     
          p_diametro        LIKE estoque_lote_ender.diametro,
          p_qtd_saldo       LIKE estoque_lote_ender.qtd_saldo,
          p_qtd_reservada   LIKE estoque_loc_reser.qtd_reservada
             
   SELECT a.cod_item,
          a.cod_local_est_dest,
          a.num_lote_dest,
          a.ies_sit_est_dest,
          a.qtd_movto,
          b.comprimento,
          b.largura,
          b.altura,
          b.diametro
     INTO p_cod_item,
          p_cod_local_estoq,
          p_num_lote,
          p_ies_situa,
          p_qtd_movto,
          p_comprimento,
          p_largura,
          p_altura, 
          p_diametro
     FROM estoque_trans a, estoque_trans_end b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.num_transac = p_num_transac
      AND a.cod_empresa = b.cod_empresa
      AND a.num_transac = b.num_transac
      

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS/ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   IF p_num_lote IS NULL OR p_num_lote = ' ' OR LENGTH(p_num_lote) = 0 THEN
      LET p_ies_ctr_lote = 'N'
   ELSE
      LET p_ies_ctr_lote = 'S'
   END IF

   IF p_ies_ctr_lote = 'S' THEN
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote = p_num_lote
   ELSE
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF   

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') VERIFICANDO SALDO NA TAB ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      AND cod_local   = p_cod_local_estoq
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL THEN
      LET p_qtd_reservada = 0
   END IF
   
   LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   
   IF p_qtd_saldo < p_qtd_movto THEN
      LET p_mensagem = 'TABELA ESTOQUE_LOTE SEM SALDO PARA ESTORNAR - ITEM:', p_cod_item
      LET p_msg = p_mensagem
      RETURN FALSE
   END IF

   IF p_ies_ctr_lote = 'S' THEN
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND comprimento = p_comprimento
         AND largura = p_largura
         AND altura = p_altura
         AND diametro = p_diametro
         AND num_lote = p_num_lote
   ELSE
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND comprimento = p_comprimento
         AND largura = p_largura
         AND altura = p_altura
         AND diametro = p_diametro
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') VERIFICANDO SALDO NA TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF

   LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
      
   IF p_qtd_saldo < p_qtd_movto THEN
      LET p_mensagem = 'TABELA ESTOQUE_LOTE_ENDER SEM SALDO PARA ESTORNAR - ITEM:', p_cod_item
      LET p_msg = p_mensagem
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1269b_estorna_ordem()#
#--------------------------------#

   DEFINE  p_cod_compon      LIKE ord_compon.cod_item_compon,
           p_qtd_necessaria  LIKE ord_compon.qtd_necessaria,
           p_num_neces       LIKE necessidades.num_neces,
           p_qtd_baixar      LIKE estoque_trans.qtd_movto,
           p_cod_item        LIKE item.cod_item
   
   LET p_qtd_boas = 0
   LET p_qtd_refug = 0
   LET p_qtd_sucata = 0
   
   SELECT cod_item
     INTO p_cod_item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
     
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS:ITEM'  
      RETURN FALSE
   END IF
   
   IF p_ies_situa = 'L' THEN
      IF m_cod_item = p_cod_item THEN
         LET p_qtd_boas = p_qtd_estorno
      ELSE
         LET p_qtd_sucata = p_qtd_estorno
      END IF
   ELSE
      LET p_qtd_refug = p_qtd_estorno
   END IF
      
   UPDATE ordens
      SET qtd_boas = qtd_boas - p_qtd_boas,
          qtd_refug = qtd_refug - p_qtd_refug,
          qtd_sucata = qtd_sucata - p_qtd_sucata
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNADO TABELA ORDENS'  
      RETURN FALSE
   END IF

   DECLARE cq_neces CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_item_pai
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem

   FOREACH cq_neces INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_num_neces

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORD_COMPON:CQ_NECES'  
         RETURN FALSE
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_estorno

      UPDATE necessidades
         SET qtd_saida = qtd_saida - p_qtd_baixar
       WHERE cod_empresa = p_cod_empresa
         AND num_neces   = p_num_neces

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ESTORNADO TABELA NECESSIDADES'  
         RETURN FALSE
      END IF  
         
   END FOREACH

   RETURN TRUE

END FUNCTION
   
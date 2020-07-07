#-------------------------------------------------------------------#
# PROGRAMA: pol1168                                                 #
# OBJETIVO: APONTAMENTO DE PRODU��O                                 #
# CLIENTE.: USIMATIC                                                #
# DATA....: 22/08/2011                                              #
# POR.....: IVO H BARBOSA                                           #
#-------------------------------------------------------------------#

DATABASE logix

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
       	 p_num_programa       LIKE man_apo_nest_405.num_programa,
         p_msg                CHAR(300),
       	 p_tem_lote           SMALLINT,
         p_cod_status         CHAR(10),
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_id_registro        SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_staus              SMALLINT,
         p_ies_cons           SMALLINT,
         p_cod_defeito        DECIMAL(3,0),
         p_cod_uni_funcio     CHAR(10),
         p_qtd_saida          DECIMAL(14,7),
         p_produzida          DECIMAL(14,7),
         p_coeficente         DECIMAL(14,7),
         p_qtd_rateio         DECIMAL(14,7),
         p_janela             SMALLINT,
         p_prog_apontado      INTEGER,
         p_prog_criticado     INTEGER,
         p_sdo_op             INTEGER

   DEFINE p_cod_nivel         SMALLINT,
          p_date_time         DATETIME YEAR TO SECOND,
          p_dat_proces        DATETIME YEAR TO SECOND,
          p_cod_tip_movto     CHAR(01),
          p_sem_estoque       SMALLINT,
          p_sequencia         INTEGER,
          p_criticou          SMALLINT,
          p_tem_critica       SMALLINT,
          p_dat_char          CHAR(23),
          p_dat_aux           CHAR(10),
          p_gerar             CHAR(02),
          p_fantasma          CHAR(01),
          p_explodiu          CHAR(01),
          p_ies_par_cst       CHAR(01),
          p_grava_oplote      CHAR(01),
          p_rastreia          CHAR(01),
          p_saldo_txt         CHAR(23),
          p_saldo_tx2         CHAR(11),
          p_cod_proces        CHAR(01),
          p_ies_forca_apont   CHAR(01),
          p_seq_reg_mestre    INTEGER,
          p_num_transac_pai   INTEGER,
          p_tip_producao      CHAR(01),
          p_tip_movto         CHAR(01),
          p_cod_erro          CHAR(7),
          p_qtd_hor_unit      DECIMAL(11,7),
          p_tem_material      SMALLINT,
          p_dat_movto         DATE,
          p_hor_movto         CHAR(08),
          p_qtd_apontada      dec(10,3),
          p_qtd_apontar       decimal(10,3),
          p_ultima_op         integer,
          p_ultimo_id         integer,
          p_baixa_sucata      decimal(10,3),
          p_tip_oper          CHAR(01),
          p_item_pai          CHAR(15),
          p_qtd_critica       INTEGER
          
          
   DEFINE p_cod_local_insp    LIKE item.cod_local_insp,
          p_num_neces         LIKE necessidades.num_neces,
          p_ies_ctr_estoque   LIKE item.ies_ctr_estoque,
          p_ies_ctr_lote      LIKE item.ies_ctr_lote,
          p_ies_tem_inspecao  LIKE item.ies_tem_inspecao,
          p_num_ordem         LIKE ordens.num_ordem,
          p_cod_item          LIKE ordens.cod_item,
          p_cod_item_pai      LIKE ordens.cod_item_pai,
          p_cod_local_estoq   LIKE item.cod_local_estoq,
          p_ies_tip_item      LIKE item.ies_tip_item,
          p_ctr_estoque       LIKE item.ies_ctr_estoque,
          p_ctr_lote          LIKE item.ies_ctr_lote,
          p_sofre_baixa       LIKE item_man.ies_sofre_baixa,
          p_ies_baixa_comp    LIKE item_man.ies_baixa_comp,
          p_cod_compon        LIKE ordens.cod_item,
          p_qtd_reservada     LIKE estoque_loc_reser.qtd_reservada,
          p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
          p_tot_saldo         LIKE estoque_lote.qtd_saldo,
          p_qtd_transf        LIKE estoque_lote.qtd_saldo,
          p_qtd_boas          LIKE ordens.qtd_planej,
          p_qtd_refug         LIKE ordens.qtd_planej,
          p_qtd_sucata        LIKE ordens.qtd_planej,
          p_qtd_apont         LIKE ordens.qtd_planej,
          p_saldo_op          LIKE ordens.qtd_planej,
          p_dat_inicio        LIKE ord_oper.dat_inicio,
          p_cod_roteiro       LIKE ordens.cod_roteiro,
          p_num_altern_roteiro LIKE ordens.num_altern_roteiro,
          p_cod_operacao      LIKE estoque_trans.cod_operacao,
          p_parametros        LIKE par_pcp.parametros,
          p_num_seq_reg       LIKE cfp_apms.num_seq_registro,
          p_empresa           LIKE mcg_filial.empresa,
          p_filial            LIKE mcg_filial.filial,
          p_area_livre        LIKE par_cst.area_livre,
          p_dat_fecha_ult_man LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup LIKE par_estoque.dat_fecha_ult_sup,
          p_ies_custo_medio   LIKE par_estoque.ies_custo_medio,
          p_ies_mao_obra      LIKE par_con.ies_mao_obra,
          p_qtd_necessaria    LIKE ord_compon.qtd_necessaria,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_ies_situa         LIKE ordens.ies_situa,
          p_ies_situa_orig    LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest    LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig    LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest    LIKE estoque_trans.cod_local_est_dest,
          p_cod_local_prod    LIKE estoque_trans.cod_local_est_dest,
          p_num_conta         LIKE estoque_trans.num_conta,
          p_num_lote_orig     LIKE estoque_lote.num_lote,
          p_num_lote_dest     LIKE estoque_lote.num_lote,
          p_num_transac_orig  LIKE estoque_trans.num_transac,
          p_num_transac       LIKE estoque_lote_ender.num_transac,
          p_qtd_movto         LIKE estoque_trans.qtd_movto,
          p_qtd_prod          LIKE estoque_trans.qtd_movto,
          p_sdo_prog          LIKE estoque_trans.qtd_movto,
          p_qtd_baixar        LIKE estoque_trans.qtd_movto,
          p_ies_largura       LIKE item_ctr_grade.ies_largura,
          p_ies_altura        LIKE item_ctr_grade.ies_altura,
          p_ies_diametro      LIKE item_ctr_grade.ies_diametro,
          p_ies_comprimento   LIKE item_ctr_grade.ies_comprimento,
          p_ies_serie         LIKE item_ctr_grade.reservado_2,
          p_ies_dat_producao  LIKE item_ctr_grade.ies_dat_producao,
          p_largura           LIKE estoque_lote_ender.largura,
          p_altura            LIKE estoque_lote_ender.altura,
          p_diametro          LIKE estoque_lote_ender.diametro,
          p_comprimento       LIKE estoque_lote_ender.comprimento,
          p_cod_unid_prod     LIKE cent_trabalho.cod_unid_prod,
          p_nom_profis        LIKE tx_profissional.nom_profis,
          p_cod_operac        LIKE ord_oper.cod_operac

   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
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
          p_programa           RECORD LIKE man_apo_nest_405.*,
          p_man                RECORD LIKE man_apo_logix_405.*
          

   DEFINE pr_men               ARRAY[1] OF RECORD    
          num_ordem            INTEGER,
          cod_item             char(15)
   END RECORD
   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol1168-12.00.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   #CALL log001_acessa_usuario("ESPEC999","")     
   #    RETURNING p_status, p_cod_empresa, p_user

   LET p_user = 'pol1168'   
   LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1168_proces_apto(p_user) RETURNING p_msg, p_qtd_critica
   END IF

END MAIN

#----------------------------------------#
 FUNCTION pol1168_proces_apto(p_user_log)#
#----------------------------------------#
   
   DEFINE p_user_log CHAR(08)
   
   LET p_user = p_user_log
   LET p_qtd_critica = 0

   IF NOT pol1168_cria_tabs() then
      RETURN p_msg, p_qtd_critica
   END IF

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1168") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1168 AT 10,20 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_programa CURSOR WITH HOLD FOR
    SELECT DISTINCT
           cod_empresa,
           num_programa
      FROM man_apo_nest_405
     WHERE tip_registro IN ('P','C')

   FOREACH cq_programa INTO p_cod_empresa, p_num_programa

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO AO LER PROXIMO PROGRAMA DA TAB MAN_APO_NEST_405'
         CALL pol1168_erro_critico()
         EXIT FOREACH
      END IF

      DISPLAY p_cod_empresa TO cod_empresa

      IF not pol1168_grava_id_nest() THEN
         CALL pol1168_erro_critico()
         EXIT FOREACH
      END IF

      CALL log085_transacao("BEGIN")
      
      IF NOT pol1168_proces_programa() THEN
         CALL log085_transacao("ROLLBACK")
         CALL pol1168_erro_critico()
         EXIT FOREACH
      ELSE
         CALL log085_transacao("COMMIT")
      END IF

      LET p_msg = ''
      
   END FOREACH
   
   IF p_qtd_critica > 0 THEN
      CALL pol1168_envia_email()
   END IF
   
   RETURN p_msg,p_qtd_critica
   
END FUNCTION

#-----------------------------#
FUNCTION pol1168_envia_email()#
#-----------------------------#

   DEFINE p_caminho_jar CHAR(080),
          p_comando     CHAR(200)
   
   LET p_caminho_jar = NULL
   
   DECLARE cq_caminho CURSOR FOR
    SELECT DISTINCT nom_caminho
      FROM path_logix_v2
     WHERE cod_sistema = 'JAR'
       AND cod_empresa  = p_cod_empresa

   FOREACH cq_caminho INTO p_caminho

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO AO LER CAMINHO DO SISTEMA JAR NA TAB PATH_LOGIX_V2'
         CALL pol1168_erro_critico()
         RETURN
      END IF
      
      LET p_caminho_jar = p_caminho
      EXIT FOREACH
   
   END FOREACH
   
   IF p_caminho_jar IS NULL THEN
      LET p_msg = 'CAMINHO DO SISTEMA JAR N�O CADASTRADO NA LOG1100'
      RETURN
   END IF
   
   LET p_comando = p_caminho_jar CLIPPED,'Apontamento.bat '
   CALL conout(p_comando)
   CALL runOnClient(p_comando)

END FUNCTION

#-------------------------------#
 FUNCTION pol1168_erro_critico()
#-------------------------------#

   LET p_dat_proces = CURRENT
    
   INSERT INTO erro_critico_405
      VALUES (p_cod_empresa,
              p_user,
              p_num_programa,
              p_dat_proces,
              p_cod_erro,
              p_msg)
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' INSERINDO NA TAB ERRO_CRITICO_405'
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_grava_id_nest()
#-------------------------------#

   LET p_id_registro = 1
   
   DECLARE cq_id_nest cursor for
    SELECT *
      FROM man_apo_nest_405
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = p_num_programa
   
   FOREACH cq_id_nest into p_programa.*

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO LENDO PROGRAMA DA TAB MAN_APO_NEST_405'
         RETURN FALSE
      END IF
      
      IF p_id_registro = 1 then
         delete from man_apo_nest_405
          where cod_empresa  = p_cod_empresa
            and num_programa = p_num_programa
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_msg = 'ERRO DELETANDO PROGRAMA DA TAB MAN_APO_NEST_405'
            RETURN FALSE
         END IF
      END IF
      
      LET p_programa.id_registro = p_id_registro
      
      INSERT INTO man_apo_nest_405 VALUES(p_programa.*)

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO INSERINDO PROGRAMA DA TAB MAN_APO_NEST_405'
         RETURN FALSE
      END IF
      
      LET p_id_registro = p_id_registro + 1
   
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1168_proces_programa()#
#----------------------------------#
   
   LET p_cod_tip_movto = 'N'
   LET p_dat_movto = TODAY
   LET p_hor_movto = TIME
   LET p_msg = ''
   
   if not pol1168_bloqueia_tab() then
      RETURN false
   end if
   
   DELETE FROM consumo_tmp_405
   DELETE FROM sucata_tmp_405
   
   IF NOT pol1168_le_parametros() THEN
      RETURN FALSE
   END IF
   
   if not pol1168_deleta_erro() then
      RETURN false
   end if
   
   let p_tem_critica = false
   
   if not pol1168_consiste_dados() then
      RETURN false
   end if
   
   IF p_tem_critica then
      call pol1168_critica_man_nest() RETURNING p_staus
      LET p_qtd_critica = p_qtd_critica + 1
      RETURN TRUE
   END IF

   DECLARE cq_mat CURSOR FOR
    SELECT cod_empresa,
           num_ordem,         
           cod_item,  
           cod_compon,        
           cod_roteiro,       
           num_altern_roteiro,
           num_seq_operac,
           (qtd_boas+qtd_refugo+qtd_sucata),
           qtd_baixar,
           baixa_sucata    
      FROM man_apo_logix_405
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = p_num_programa
       AND cod_status   = 'I'
       AND num_ordem > 0

   FOREACH cq_mat INTO
           p_man.cod_empresa,
           p_man.num_ordem,
           p_man.cod_item,
           p_man.cod_compon,
           p_man.cod_roteiro,
           p_man.num_altern_roteiro,
           p_man.num_seq_operac,
           p_qtd_prod,
           p_man.qtd_baixar,
           p_man.baixa_sucata

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA MAN_APO_LOGIX_405 - CQ_MAT'
         RETURN FALSE
      END IF                                           

      LET pr_men[1].num_ordem = p_man.num_ordem
      LET pr_men[1].cod_item  = p_man.cod_item
      CALL pol1168_exib_mensagem()
   
      IF NOT pol1168_le_material() THEN 
         RETURN FALSE
      END IF

      IF NOT pol1168_le_sucata() THEN 
         RETURN FALSE
      END IF
   
   END FOREACH

   LET p_criticou = FALSE
   
   IF NOT pol1168_checa_material() THEN 
      RETURN FALSE
   END IF

   IF NOT pol1168_checa_sucata() THEN 
      RETURN FALSE
   END IF

   IF p_criticou THEN
      call pol1168_critica_man_nest() RETURNING p_staus
      LET p_qtd_critica = p_qtd_critica + 1
      RETURN TRUE
   END IF

   let p_tip_oper = 'A'
   let p_cod_uni_funcio = null
   
   IF not pol1168_aponta_programa() then
      RETURN FALSE
   END IF

   let p_tip_oper = 'B'
   
   IF not pol1168_baixa_especial() then
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION
   
#---------------------------------------#
FUNCTION pol1168_forca_apont(p_cod_item)
#---------------------------------------#

   define p_cod_item    like item.cod_item,
          p_forca_apont char(01)

   SELECT ies_forca_apont
     INTO p_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      let p_forca_apont = 'N'
   END IF

   RETURN (p_forca_apont)
   
END FUNCTION

#------------------------------#
FUNCTION pol1168_le_parametros()
#------------------------------#

   SELECT parametros
     INTO p_parametros
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL LER DADOS DA TABELA PAR_PCP'
      RETURN FALSE
   END IF
   
   LET p_grava_oplote = p_parametros[116,116]
   LET p_rastreia     = p_parametros[50,50]
   
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL LER DADOS DA TABELA PAR_ESTOQUE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#---------------------------------#
FUNCTION pol1168_critica_man_nest()
#---------------------------------#

   UPDATE man_apo_nest_405
      set tip_registro = 'C'
    where cod_empresa  = p_programa.cod_empresa
      and num_programa = p_programa.num_programa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL ATUALIZAR A TABELA MAN_APO_NEST_405'
      RETURN FALSE
   END IF
   
   DELETE FROM man_apo_logix_405
    WHERE cod_empresa  = p_programa.cod_empresa
      AND num_programa = p_programa.num_programa
      AND cod_status   = 'I'
   
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL DELETAR REGISTROS DA TAB MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1168_bloqueia_tab()
#------------------------------#

   LOCK TABLE man_erro_405 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL BLOQUEAR A TABELA MAN_ERRO_405'
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#----------------------------#
FUNCTION pol1168_deleta_erro()
#----------------------------#

   delete from man_erro_405
    where cod_empresa = p_cod_empresa
      and num_programa = p_num_programa
   
   if status <> 0 then
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL DELETAR MENSAGENS DA TABELA MAN_ERRO_405'
      RETURN false
   end if

   delete from erro_critico_405
    where cod_empresa = p_cod_empresa
      and num_programa = p_num_programa
   
   if status <> 0 then
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL DELETAR MENSAGENS DA TABELA ERRO_CRITICO_405'
      RETURN false
   end if
   
   RETURN true
   
end FUNCTION

#----------------------#
FUNCTION empty(p_campo)
#----------------------#
   
   DEFINE p_campo char(20)
   
   IF p_campo is null OR
      p_campo = ' '   THEN
      RETURN TRUE
   end if
   
   RETURN FALSE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1168_consiste_dados()
#-------------------------------#
   
   DECLARE cq_consiste CURSOR for
    select *
      from man_apo_nest_405
     where cod_empresa  = p_cod_empresa
       and num_programa = p_num_programa
       and (qtd_boas > 0 OR qtd_refugo > 0)
       and num_ordem > 0
       
   FOREACH cq_consiste into p_programa.*

      if status <> 0 then
         let p_cod_erro = STATUS
         let p_msg = 'ERRO AO LER OS DADOS DO PROGRAMA PARA CONSISTENCIA'
         RETURN false
      end if
      
      INITIALIZE p_man TO NULL
      let p_criticou = false
      
      let p_man.cod_empresa = p_programa.cod_empresa
      let p_man.num_ordem   = p_programa.num_ordem
      let p_man.num_programa= p_programa.num_programa
      let p_man.cod_operac  = p_programa.cod_operac
      
      if not pol1168_checa_ordem() then
         return false
      end if
      
      IF p_man.cod_item IS NULL THEN
         LET p_tem_critica = true
         CONTINUE FOREACH
      END IF
      
      if not pol1168_checa_operacao() then
         return false
      end if

      if not pol1168_checa_operador() then
         return false
      end if

      if not pol1168_checa_componente() then
         return false
      end if
      
      if p_programa.qtd_boas is null then
         let p_programa.qtd_boas = 0
      end if
      
      if p_programa.qtd_boas < 0 then
         let p_msg = 'QUANTIDADE DE BOAS A APONTAR INVALIDA'
         call pol1168_insere_erro()
      end if

      if p_programa.qtd_refugo is null then
         let p_programa.qtd_refugo  = 0
      end if

      if p_programa.qtd_refugo < 0 then
         let p_msg = 'QUANTIDADE A REFUGAR INVALIDA'
         call pol1168_insere_erro()
      end if

      let p_man.qtd_boas   = p_programa.qtd_boas
      let p_man.qtd_refugo = p_programa.qtd_refugo
      let p_man.cod_defeito = p_programa.cod_defeito
      let p_man.qtd_sucata = 0
      
      let p_qtd_apontar = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata
      
      IF p_sdo_op < p_qtd_apontar THEN
         LET p_ies_forca_apont = pol1168_forca_apont(p_man.cod_item)
         IF p_ies_forca_apont = 'N' then
            LET p_msg = 'QUANTIDADE A APONTAR MAIOR QUE O SALDO DA OPERACAO'
            CALL pol1168_insere_erro()
         END IF
      END IF
      
      if p_programa.pes_unit is null then
         let p_programa.pes_unit = 0
      end if

      if p_programa.pes_sucata is null or p_programa.pes_sucata < 0 then
         let p_programa.pes_sucata = 0
      end if
      
      if p_programa.pes_unit < 0 then
         let p_msg = 'PESO UNITARIO INVALIDO'
         call pol1168_insere_erro()
      end if
            
      call pol1168_checa_tempo_unit()

      if p_criticou then
         LET p_tem_critica = true
         CONTINUE FOREACH
      end if
      
      let p_man.cod_compon = p_programa.cod_item_compon
      let p_man.qtd_hor = p_qtd_hor_unit * p_qtd_apontar

      if p_man.qtd_hor > 9999 then
         let p_msg = 'TEMPO DE CORTE EXCESSIVO. VERIFIQUE-O NO NEXT'
         call pol1168_insere_erro()
      end if

      call pol1168_calc_data_hora()

      IF p_dat_fecha_ult_man IS NOT NULL THEN
         IF p_man.dat_inicial <= p_dat_fecha_ult_man THEN
            LET p_msg = 'A MANUFATURA JA ESTA FECHADA'
            call pol1168_insere_erro()
         END IF
      END IF

      IF p_dat_fecha_ult_sup IS NOT NULL THEN
         IF p_man.dat_inicial < p_dat_fecha_ult_sup THEN
            LET p_msg = 'O ESTOQUE JA ESTA FECHADO'
            call pol1168_insere_erro()
         END IF
      END IF
      
      if p_criticou then
         LET p_tem_critica = true
         CONTINUE FOREACH
      end if

      if not pol1168_insere_man() then
         return false
      end if
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1168_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#-----------------------------#
FUNCTION pol1168_checa_ordem()
#-----------------------------#

   if empty(p_programa.num_ordem) then
      let p_msg = 'ORDEM DE PRODUCAO INVALIDA'
      call pol1168_insere_erro()
      return true
   end if

   SELECT (qtd_planej - qtd_boas - qtd_refug  - qtd_sucata),
          ies_situa,
          cod_item,
          cod_local_prod,
          num_lote,
          cod_roteiro,                                 
          num_altern_roteiro,                             
          dat_ini
     INTO p_qtd_saldo,
          p_ies_situa,
          p_man.cod_item,
          p_man.cod_local,
          p_man.num_lote,
          p_man.cod_roteiro,
          p_man.num_altern_roteiro,
          p_dat_inicio
     FROM ordens
    WHERE cod_empresa = p_man.cod_empresa
      AND num_ordem   = p_programa.num_ordem
                                                         
   IF STATUS = 100 THEN                                    
      let p_msg = 'ORDEM DE PRODUCAO INEXISTENTE NO LOGIX'
      call pol1168_insere_erro()
      return true
   ELSE
      if status <> 0 then
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO ORDEM NA TABELA ORDENS DO LOGIX'
         return false
      end if
   END IF                                                 
   
   if p_ies_situa <> '4' then
      let p_msg = 'ORDEM DE PRODUCAO NAO ESTA LIBERADA NO LOGIX'
      call pol1168_insere_erro()
   end if
                                                          
   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN     
      LET p_dat_inicio = p_dat_movto           
   END IF                                                 
   
   let p_man.dat_inicio = p_dat_inicio
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1168_checa_operacao()
#--------------------------------#

   DEFINE p_num_seq   integer,
          p_cod_recur char(05)
   
   if empty(p_programa.cod_operac) then
      let p_msg = 'CODIGO DA OPERACAO INVALIDO'
      call pol1168_insere_erro()
      return true
   end if
   
   DECLARE cq_operacao CURSOR FOR
   SELECT num_seq_operac
		 FROM ord_oper
    WHERE cod_empresa = p_man.cod_empresa
	    AND num_ordem   = p_man.num_ordem
      AND cod_item    = p_man.cod_item
      AND cod_operac  = p_man.cod_operac
      AND num_seq_operac  = 1
      AND ies_apontamento = 'S'
    ORDER BY num_seq_operac

   FOREACH cq_operacao into p_num_seq
   
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO SEQUENCIA DA OPERACAO NA TABELA ORD_OPER'
         return false
      END IF
      
      let p_man.num_seq_operac = p_num_seq
      exit FOREACH
      
   END FOREACH
   
   if p_man.num_seq_operac is null then
      let p_msg = 'OPERACAO NAO PREVISTA PARA A ORDEM OU NAO APONTAVEL'
      call pol1168_insere_erro()
      return true
   end if
   
   SELECT cod_cent_trab,
          cod_arranjo,
          cod_cent_cust,
          ies_oper_final,
          (qtd_planejada -
           qtd_boas      -
           qtd_refugo    -
           qtd_sucata)
     INTO p_man.cod_cent_trab,
          p_man.cod_arranjo,
          p_man.cod_cent_cust,
          p_man.oper_final,
          p_sdo_op
		 FROM ord_oper
    WHERE cod_empresa    = p_man.cod_empresa
	    AND num_ordem      = p_man.num_ordem
      AND cod_item       = p_man.cod_item
      AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DA OPERACAO NA TABELA ORD_OPER'
      return false
   END IF

   DECLARE cq_recurso CURSOR FOR
    SELECT a.cod_recur
      FROM rec_arranjo a,
           recurso b
     WHERE a.cod_empresa   = p_man.cod_empresa
       AND a.cod_arranjo   = p_man.cod_arranjo
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_recur     = a.cod_recur
       AND b.ies_tip_recur = '2'
       
   FOREACH cq_recurso INTO p_cod_recur 

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO CODIGO DO RECURSO NAS TABELAS REC_ARRANJO/RECURSO'
         RETURN FALSE
      END IF
         
      LET p_man.cod_recur = p_cod_recur
         
   END FOREACH
   
   if p_man.cod_recur is null then
      let p_man.cod_recur = ' '
   end if
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1168_checa_componente()
#----------------------------------#

   if empty(p_programa.cod_item_compon) then
      let p_msg = 'CODIGO DO COMPONENTE INVALIDO'
      call pol1168_insere_erro()
      return true
   end if
   
   select count(item_componente)
     into p_count
     from man_op_componente_operacao
    where empresa            = p_man.cod_empresa
      and ordem_producao     = p_man.num_ordem
      and sequencia_operacao = p_man.num_seq_operac
      and item_componente    = p_programa.cod_item_compon
           
   IF STATUS = 100 THEN
      let p_msg = 'COMPONENTE NAO PREVISTO P/ BAIXA NA TABELA MAN_OP_COMPONENTE_OPERACAO'
      call pol1168_insere_erro()
   ELSE
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO COMPONENTE DA TABELA MAN_OP_COMPONENTE_OPERACAO'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1168_checa_operador()
#--------------------------------#

   IF empty(p_programa.operador) then
      LET p_msg = 'CODIGO DO OPERADOR ESTA NULO'
      CALL pol1168_insere_erro()
      RETURN TRUE
   END IF
   
   SELECT nom_funcionario
     FROM funcionario
    WHERE cod_empresa = p_cod_empresa
      AND num_matricula  = p_programa.operador
            
   IF STATUS = 100 THEN
      let p_msg = 'CODIGO DO OPERADOR NAO CADSTRADO NO RHU08300'
      call pol1168_insere_erro()
   ELSE
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO OPERADOR NA TABELA FUNCIONARIO'
         RETURN FALSE
      END IF
   END IF   

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1168_checa_tempo_unit()
#---------------------------------#
   
   DEFINE p_hh, p_mm, p_ss INTEGER,
          p_hora           CHAR(06)
   
   if empty(p_programa.tempo_unit) OR p_programa.tempo_unit = 0 then
      let p_msg = 'TEMPO DE CORTE INVIADO. VERIFIQUE-O NO NEXT'
      call pol1168_insere_erro()
      return 
   end if
   
   let p_hora = p_programa.tempo_unit[1,2],
                p_programa.tempo_unit[4,5],
                p_programa.tempo_unit[7,8]
 
   for p_ind = 1 to LENGTH(p_hora)
      if p_hora[p_ind] MATCHES '[0123456789]' then
      else
         let p_msg = 'TEMPO UNITARIO INVALIDO'
         call pol1168_insere_erro()
         return 
      end if
   end for
   
   let p_hh = p_programa.tempo_unit[1,2]
   let p_mm = p_programa.tempo_unit[4,5]
   let p_ss = p_programa.tempo_unit[7,8]
   
   if p_hh > 23 or p_mm > 59 or p_ss > 59 then
      let p_msg = 'TEMPO UNITARIO INVALIDO'
      call pol1168_insere_erro()
   end if   
   
   let p_qtd_hor_unit = p_hh + ((p_mm * 60 + p_ss) / 3600)
   

END FUNCTION
                         
#-------------------------------#
FUNCTION pol1168_calc_data_hora()
#-------------------------------#

   DEFINE p_hi             CHAR(02),
          p_mi             CHAR(02),
          p_si             CHAR(02),
          p_hf             INTEGER,
          p_mf             INTEGER,
          p_sf             INTEGER,
          p_dat_ini        CHAR(10),
          p_hor_ini        CHAR(8),
          p_hor_fim        CHAR(8),
          p_segundo_ini    INTEGER,
          p_segundo_fim    INTEGER,
          p_tmp_producao   INTEGER,
          p_dat_fim        DATE
          
   LET p_tmp_producao = p_man.qtd_hor * 3600
   
   LET p_dat_ini = p_dat_movto
   LET p_dat_fim = p_dat_ini
   LET p_hor_ini = p_hor_movto
   
   LET p_man.dat_inicial = p_dat_ini
   LET p_man.hor_inicial = p_hor_ini
   
   LET p_hi = p_hor_ini[1,2]
   
   CALL pol1168_calcula_turno(p_hi)
   
   LET p_mi = p_hor_ini[4,5]
   LET p_si = p_hor_ini[7,8]
   LET p_segundo_ini = (p_hi * 3600)+(p_mi * 60)+(p_si)
   LET p_segundo_fim = p_segundo_ini + p_tmp_producao + 60

   LET p_hf = p_segundo_fim / 3600
   LET p_segundo_fim = p_segundo_fim - p_hf * 3600
   LET p_mf = p_segundo_fim / 60
   LET p_sf = p_segundo_fim - p_mf * 60


   WHILE p_hf > 23
      LET p_hf = p_hf - 24
      LET p_dat_fim = p_dat_fim + 1
   END WHILE   
      
   LET p_hi = p_hf USING '&&'
   LET p_mi = p_mf USING '&&'
   LET p_si = p_sf USING '&&'
   LET p_hor_fim = p_hi,':',p_mi,':',p_si

   LET p_man.dat_final = p_dat_fim
   LET p_man.hor_final = p_hor_fim

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_calcula_turno(p_hi)
#-----------------------------------#

   DEFINE p_hi SMALLINT
   
   IF p_hi >= 6 AND p_hi < 14 THEN
      LET p_man.cod_turno = '1'
   ELSE
      IF p_hi >= 14 AND p_hi < 22 THEN
         LET p_man.cod_turno = '2'
      ELSE
         LET p_man.cod_turno = '3'
      END IF
   END IF
   
END FUNCTION
   
#-----------------------------#
 FUNCTION pol1168_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO man_erro_405
      VALUES (p_programa.cod_empresa,
              p_programa.num_programa,
              p_man.num_ordem,
              p_msg)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','apont_erro_405')
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1168_insere_man()
#----------------------------#
   
   DEFINE p_id_man_apont INTEGER
   
   LET p_man.nom_prog = 'POL1168'
   LET p_man.nom_usuario = p_user
   LET p_man.cod_status = 'I'
   LET p_man.dat_atualiz = CURRENT
   LET p_man.integr_min = 'N'
   LET p_man.matricula = p_programa.operador
   LET p_man.tip_movto = 'N'

   let p_man.qtd_baixar = p_programa.pes_unit
   let p_man.baixa_sucata = p_programa.pes_sucata
   
   if not pol1168_le_ferramenta() then
      return false
   end if

   if not pol1168_le_uni_funcio() then
      return false
   end if

   SELECT cod_unid_prod 
     INTO p_man.unid_produtiva
     FROM cent_trabalho
    WHERE cod_empresa   = p_man.cod_empresa
      AND cod_cent_trab = p_man.cod_cent_trab

   IF STATUS <> 0 THEN
      LET p_man.unid_produtiva = ' '
   END IF
   
   select max(id_man_apont)
     into p_id_man_apont
     from man_apo_logix_405
    where cod_empresa = p_man.cod_empresa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO PROXIMO ID DA DA TABELA MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   IF p_id_man_apont IS NULL THEN
      LET p_id_man_apont = 1
   ELSE
      LET p_id_man_apont = p_id_man_apont + 1
   END IF
   
   LET p_man.id_man_apont = p_id_man_apont
   LET p_man.dat_apontamento = CURRENT YEAR TO SECOND
   
   INSERT INTO man_apo_logix_405
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO PE�AS BOAS NA TABELA MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1168_le_ferramenta()
#-------------------------------#

   DEFINE p_parametro      LIKE consumo.parametro,
          p_cod_ferramenta LIKE consumo_fer.cod_ferramenta

   DEFINE p_seq_processo LIKE man_processo_item.seq_processo

   DECLARE cq_proces CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa             = p_man.cod_empresa         
      AND item                = p_man.cod_item     
      AND roteiro             = p_man.cod_roteiro         
      AND roteiro_alternativo = p_man.num_altern_roteiro  
      AND operacao            = p_man.cod_operac          
      
   FOREACH cq_proces INTO p_seq_processo

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO TABELA MAN_PROCESSO_ITEM'
         RETURN FALSE
      END IF

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = p_seq_processo

      FOREACH cq_fer INTO p_cod_ferramenta
         IF STATUS <> 0 THEN
            let p_cod_erro = STATUS
            let p_msg = 'ERRO LENDO TABELA MAN_FERRAMENTA_PROCESSO'
            RETURN FALSE
         END IF
         EXIT FOREACH
      END FOREACH

      EXIT FOREACH

   END FOREACH 
      
   IF p_cod_ferramenta IS NULL THEN
      LET p_cod_ferramenta = 0
   END IF
   
   LET p_man.cod_ferramenta = p_cod_ferramenta
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_le_uni_funcio()
#-------------------------------#

   DEFINE p_cod_uni_funcio LIKE uni_funcional.cod_uni_funcio
   
   DECLARE cq_funcio CURSOR FOR 
	  SELECT cod_uni_funcio 
		  FROM uni_funcional
		 WHERE cod_empresa      =  p_man.cod_empresa
			 AND cod_centro_custo =  p_man.cod_cent_cust
       AND dat_validade_ini <= CURRENT YEAR TO SECOND  
       AND dat_validade_fim >= CURRENT YEAR TO SECOND					
																		
	 FOREACH cq_funcio INTO p_cod_uni_funcio

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO CODIGO DA DA TABELA UNI_FUNCIONAL'
         RETURN FALSE
      END IF
					
		  IF p_cod_uni_funcio IS NOT NULL THEN
				 EXIT FOREACH
			END IF 
					
	 END FOREACH
   
   let p_man.unid_funcional = p_cod_uni_funcio
   
   return true

end FUNCTION

#------------------------------#
FUNCTION pol1168_atualiza_man()
#------------------------------#

   UPDATE man_apo_nest_405
      set tip_registro = 'A',
          qtd_apontada = qtd_apontada + qtd_boas + qtd_refugo
    where cod_empresa  = p_cod_empresa
      and num_programa = p_num_programa
      and num_ordem    = p_man.num_ordem

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL ATUALIZAR A TABELA MAN_APO_NEST_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1168_aponta_programa()
#---------------------------------#

   INITIALIZE p_man TO NULL
   
   DECLARE cq_man CURSOR FOR
    SELECT *
      FROM man_apo_logix_405
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = p_num_programa
       AND cod_status   = 'I'
       AND num_ordem > 0
       
   FOREACH cq_man INTO p_man.*

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA MAN_APO_LOGIX_405 - CQ_MAN'
         RETURN FALSE
      END IF                                           

      LET pr_men[1].num_ordem = p_man.num_ordem
      LET pr_men[1].cod_item  = p_man.cod_item
      CALL pol1168_exib_mensagem()

      if not pol1168_atualiza_man() then
         return false
      end if

      IF NOT pol1168_ins_mestre() THEN
         RETURN FALSE
      END IF

      IF NOT pol1168_ins_detalhe() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1168_ins_tempo() THEN
         RETURN FALSE
      END IF

      IF NOT pol1168_atuali_ord_oper() THEN
         RETURN FALSE
      END IF

      let p_qtd_sucata = 0
      let p_qtd_refug  = p_man.qtd_refugo
            
      IF p_man.oper_final = 'S' THEN
         let p_qtd_boas = p_man.qtd_boas
      else
         let p_qtd_boas = 0
      end if

      IF (p_qtd_boas + p_qtd_refug + p_qtd_sucata) > 0 THEN
         If not pol1168_grava_ordens() THEN
            Return false
         End if
      End If

      LET p_qtd_boas  = 0
      LET p_qtd_refug = 0
      
      If p_man.qtd_refugo > 0 then
         LET p_qtd_refug = p_man.qtd_refugo
         LET p_tip_producao = "R"
         let p_man.qtd_hor = p_qtd_hor_unit * p_qtd_refug
         call pol1168_calc_data_hora()
         
         IF NOT pol1168_gra_tabs_velhas() THEN
            RETURN FALSE
         END IF
         
         LET p_qtd_movto = p_qtd_refug
         LET p_ies_situa = 'R'

         If not pol1168_le_est_lote_ender() then
            RETURN true
         End if
         
         LET p_qtd_prod = p_qtd_refug
         LET p_cod_operacao = NULL
         IF NOT pol1168_aponta_estoque() THEN
            RETURN FALSE
         END IF
            
         IF NOT pol1168_insere_man_item() THEN
            RETURN FALSE
         END IF

         LET p_tip_movto = 'E'
   
         IF NOT pol1168_insere_chf_componente() THEN
            RETURN FALSE
         END IF
            
         IF NOT pol1168_ins_man_def() THEN
            RETURN FALSE
         END IF

         LET p_cod_operacao = NULL
         LET p_qtd_prod = p_man.qtd_refugo

         IF NOT pol1168_baixa_material() THEN 
            RETURN FALSE
         END IF
         
         let p_dat_movto = p_man.dat_final
         let p_hor_movto = p_man.hor_final
         
      End if
      
      LET p_qtd_refug = 0
      
      If p_man.qtd_boas > 0 then
         LET p_qtd_boas = p_man.qtd_boas
         LET p_tip_producao = "B"
         let p_man.qtd_hor = p_qtd_hor_unit * p_qtd_boas
         call pol1168_calc_data_hora()

         IF NOT pol1168_gra_tabs_velhas() THEN
            RETURN FALSE
         END IF
         
         LET p_qtd_movto = p_qtd_boas
         LET p_ies_situa = 'L'
         
         If not pol1168_le_est_lote_ender() then
            RETURN true
         End if
         
         IF p_man.oper_final = 'S' THEN
            LET p_qtd_prod = p_qtd_boas
            LET p_cod_operacao = NULL
            IF NOT pol1168_aponta_estoque() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_num_transac_pai = 0
            IF p_tem_lote THEN
            else
               CALL pol1168_ender_carrega()
            END IF
            LET p_estoque_lote_ender.cod_local = ' '
            LET p_estoque_lote_ender.num_lote  = ' '
         End if
         
         IF NOT pol1168_insere_man_item() THEN
            RETURN FALSE
         END IF

         LET p_tip_movto = 'E'
   
         IF NOT pol1168_insere_chf_componente() THEN
            RETURN FALSE
         END IF

         LET p_cod_operacao = NULL
         LET p_qtd_prod = p_man.qtd_boas

         IF NOT pol1168_baixa_material() THEN 
            RETURN FALSE
         END IF

      END IF

      IF NOT pol1168_ins_apont_proces() THEN
         RETURN FALSE
      END IF
      
      let p_cod_status = 'A'
      
      IF NOT pol1168_atualiza_apo_logix() THEN 
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1168_baixa_especial()
#-------------------------------#

   DEFINE p_boas          DECIMAL(10,3),
          p_pes_boas      DECIMAL(10,3),
          p_refugo        DECIMAL(10,3),
          p_pes_sucata    DECIMAL(10,3),
          p_cod_tip_desp  DECIMAL(4,0),
          p_cod_cc        DECIMAL(4,0),
          p_dat_atu       DATE,
          p_cod_txt       CHAR(04),
          p_bx_apont_boa  DECIMAL(10,3),
          p_bx_apont_ref  DECIMAL(10,3)
          

   let p_criticou = false

   LET p_man.cod_empresa = p_cod_empresa
   LET p_man.num_ordem = 0
   LET p_man.nom_prog = 'POL1168'
   LET p_man.nom_usuario = p_user  
   LET p_dat_atu = TODAY

   DECLARE cq_atu_apont cursor for
    select id_registro
      from man_apo_nest_405
     where cod_empresa  = p_cod_empresa
       and num_programa = p_num_programa
       and num_ordem    = 0
   
   FOREACH cq_atu_apont into p_id_registro
           
      if status <> 0 then
         call log003_err_sql('Lendo','man_apo_nest_405:cq_atu_apont')
         RETURN FALSE
      end if
      
      update man_apo_nest_405
         set tip_registro = 'A',
             qtd_apontada = qtd_apontada + qtd_boas + qtd_refugo
       where cod_empresa  = p_cod_empresa
         and num_programa = p_num_programa
         and id_registro  = p_id_registro
   
   END FOREACH
   
   DECLARE cq_bx_esp cursor for
    select cod_item,
           cod_item_compon,
           (qtd_boas   * (pes_unit+pes_sucata)),
           (qtd_refugo * (pes_unit+pes_sucata))
      from man_apo_nest_405
     where cod_empresa  = p_cod_empresa
       and num_programa = p_num_programa
       and num_ordem = 0
   
   FOREACH cq_bx_esp into 
           p_item_pai,
           p_cod_compon, 
           p_bx_apont_boa,
           p_bx_apont_ref
           
      if status <> 0 then
         call log003_err_sql('Lendo','man_apo_nest_405:cq_bx_esp')
         RETURN FALSE
      end if
      
      if p_bx_apont_boa is null then
         let p_bx_apont_boa = 0
      end if

      if p_bx_apont_ref is null then
         let p_bx_apont_ref = 0
      end if
      
      let p_qtd_baixar = p_bx_apont_boa + p_bx_apont_ref
      
      if p_qtd_baixar <= 0 then
         CONTINUE foreach
      end if

      if not pol1168_le_item_man() then
         Return false
      end if
      
      IF p_ies_tip_item = 'T' OR 
         p_ctr_estoque  = 'N' OR
         p_sofre_baixa  = 'N' THEN
         CONTINUE FOREACH
      END IF

      LET p_cod_local_orig = p_cod_local_estoq

      LET p_sem_estoque = FALSE

      IF NOT pol1168_checa_estoque() THEN
         RETURN FALSE
      END IF

      IF p_sem_estoque THEN
         LET p_saldo_txt = p_qtd_baixar
         LET p_msg = 'LOCAL: ', p_cod_local_orig CLIPPED, 
                     ' ITEM: ',p_cod_compon CLIPPED, 
                     ' NECESSITA: ', p_saldo_txt CLIPPED, 
                     ' SALDO: '
         let p_saldo_txt = p_qtd_saldo
         LET p_msg = p_msg CLIPPED, ' ', p_saldo_txt
         RETURN FALSE
      END IF         

      INITIALIZE p_cod_operacao, p_cod_uni_funcio,
         p_cod_cc,p_cod_tip_desp TO NULL

      select parametro_texto
        into p_cod_operacao
        from min_par_modulo 
       where empresa = p_cod_empresa
         and parametro = 'OPER_EST_BX_FER_912'
      
      if status <> 0 then
         call log003_err_sql('Lendo','min_par_modulo')
         Return false
      end if
      
      if p_cod_operacao is null then
         let p_msg = 'Operacao de baixa p/ material sem OP nao encontrada'
         Return false
      end if
      
      IF p_item_pai[1,4] = 'FERR' THEN
         SELECT parametro_texto 
           INTO p_cod_uni_funcio
           FROM min_par_modulo 
          WHERE empresa = p_cod_empresa
            AND parametro='UNI_FUNC_BX_FER_912'
      ELSE
         IF p_item_pai[1,4] = 'DISP' THEN
            SELECT parametro_texto 
              INTO p_cod_uni_funcio
              FROM min_par_modulo 
             WHERE empresa = p_cod_empresa
               AND parametro='UNI_FUNC_BX_DISP_912'
         ELSE
            SELECT parametro_texto 
              INTO p_cod_uni_funcio
              FROM min_par_modulo 
             WHERE empresa = p_cod_empresa
               AND parametro='UNI_FUNC_BX_GER_912'
         END IF
      END IF

      if p_cod_uni_funcio is null then
         let p_msg = 'Unid funcional p/ baixa de material sem OP nao encontrada'
         Return false
      end if

      SELECT cod_centro_custo
        INTO p_cod_cc
        FROM uni_funcional 
       WHERE cod_empresa = p_cod_empresa
         AND cod_uni_funcio = p_cod_uni_funcio
         AND DATE(dat_validade_ini) <= p_dat_atu
         AND DATE(dat_validade_fim) >= p_dat_atu
  
      if p_cod_cc is null then
         let p_msg = 'Centro de custo p/ baixa de material sem OP nao encontrada'
         Return false
      end if
                
      SELECT cod_tip_despesa
        INTO p_cod_tip_desp
        FROM item_sup
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_compon
      
      if p_cod_tip_desp is null then
         let p_msg = 'Tipo de despesa p/ baixa de material sem OP nao encontrada'
         Return false
      end if
             
      LET p_num_conta = StrZero(p_cod_cc, 4) CLIPPED, StrZero(p_cod_tip_desp, 4)
      
      LET p_coeficente = 1
      
      IF NOT pol1168_baixa_compon() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION strZero(valor, tamanho)
#------------------------------#	
		
		DEFINE valor    INTEGER,
		       tamanho  INTEGER,
		       retorno  CHAR(30),
		       qtdZeros INTEGER,
		       val_txt  CHAR(30)
		       
		LET val_txt = valor
		LET qtdZeros = tamanho - LENGTH(val_txt);
		LET retorno = ""
		
		FOR p_ind = 1 TO qtdZeros
			  LET retorno = retorno CLIPPED, "0"
		END FOR
    
    LET retorno = retorno CLIPPED, val_txt CLIPPED
		
		RETURN(retorno)
		
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_atualiza_apo_logix()
#-----------------------------------#

   update man_apo_logix_405
      set cod_status = p_cod_status
    WHERE cod_empresa  = p_man.cod_empresa
      and id_man_apont = p_man.id_man_apont
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO REGISTRO DA TABELA MAN_APO_LOGIX_405'
      return false
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1168_ins_mestre()
#----------------------------#
   
   LET p_man_apo_mestre.empresa         = p_man.cod_empresa
   LET p_man_apo_mestre.seq_reg_mestre  = 0
   LET p_man_apo_mestre.sit_apontamento = 'A'
   LET p_man_apo_mestre.tip_moviment    = 'N'
   LET p_man_apo_mestre.data_producao   = p_man.dat_inicial
   LET p_man_apo_mestre.ordem_producao  = p_man.num_ordem
   LET p_man_apo_mestre.item_produzido  = p_man.cod_item
   LET p_man_apo_mestre.secao_requisn   = p_man.unid_funcional
   LET p_man_apo_mestre.usu_apontamento = p_user
   LET p_man_apo_mestre.data_apontamento= p_dat_movto  
   LET p_man_apo_mestre.hor_apontamento = p_hor_movto
   LET p_man_apo_mestre.usuario_estorno = ''
   LET p_man_apo_mestre.data_estorno    = ''
   LET p_man_apo_mestre.hor_estorno     = ''
   LET p_man_apo_mestre.apo_automatico  = 'N'
   LET p_man_apo_mestre.seq_reg_origem  = ''
   LET p_man_apo_mestre.observacao      = ''
   LET p_man_apo_mestre.seq_registro_integracao = ''

   INSERT INTO man_apo_mestre (
      empresa, 
      seq_reg_mestre,
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
          p_man_apo_mestre.seq_reg_mestre,       
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO DADOS DA TABELA MAN_APO_MESTRE'
      return false
   END IF

   LET p_seq_reg_mestre = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1168_ins_tempo()
#--------------------------#

   LET p_man_tempo_producao.empresa            = p_man.cod_empresa
   LET p_man_tempo_producao.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_tempo_producao.seq_registro_tempo = 0
   LET p_man_tempo_producao.turno_producao     = p_man.cod_turno
   LET p_man_tempo_producao.data_ini_producao  = p_man.dat_inicial
   LET p_man_tempo_producao.hor_ini_producao   = EXTEND(p_man.hor_inicial, HOUR TO MINUTE)
   LET p_man_tempo_producao.dat_final_producao = p_man.dat_final
   LET p_man_tempo_producao.hor_final_producao = EXTEND(p_man.hor_final, HOUR TO MINUTE)
   LET p_man_tempo_producao.periodo_produtivo  = 'A' # Tipo A=produ��o Tipo I=parada
   LET p_man_tempo_producao.tempo_tot_producao = p_man.qtd_hor 
   LET p_man_tempo_producao.tmp_ativo_producao = p_man.qtd_hor #descontar tempo de paradas, se houver
   LET p_man_tempo_producao.tmp_inatv_producao = 0 # tempo da parada, se for tipo I
   
   INSERT INTO man_tempo_producao(
      empresa,           
      seq_reg_mestre,    
      seq_registro_tempo,
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
          p_man_tempo_producao.seq_registro_tempo,
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO DADOS DA TABELA MAN_TEMPO_PRODUCAO'
      return false
   END IF
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1168_atuali_ord_oper()
#---------------------------------#
   
   DEFINE p_qtd_sdo_op      DECIMAL(10,3),
          d_qtd_planejada   DECIMAL(10,3),
          d_tot_apont       DECIMAL(10,3),
          d_qtd_apontar     DECIMAL(10,3)
          
    SELECT dat_inicio,
           qtd_planejada,
           (qtd_boas  + qtd_refugo + qtd_sucata)
      INTO p_dat_inicio,
           d_qtd_planejada,
           d_tot_apont
      FROM ord_oper
    WHERE cod_empresa    = p_man.cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DA TABELA ORD_OPER'
      return false
   END IF
   
   LET d_qtd_apontar = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata
   LET d_tot_apont = d_tot_apont + d_qtd_apontar

   IF d_tot_apont > d_qtd_planejada THEN
      let p_msg = 'Quantidade a apontar maior que saldo da ordem'
      return false
   END IF
   
   IF p_dat_inicio IS NULL THEN
      LET p_dat_inicio = p_man.dat_inicio
   end if
   
   UPDATE ord_oper
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refugo = qtd_refugo + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_inicio = p_dat_inicio
    WHERE cod_empresa    = p_man.cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS DA TABELA ORD_OPER'
      return false
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1168_ins_detalhe()
#----------------------------#
      
   LET p_man_apo_detalhe.empresa            = p_man.cod_empresa
   LET p_man_apo_detalhe.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_apo_detalhe.roteiro_fabr       = p_man.cod_roteiro
   LET p_man_apo_detalhe.altern_roteiro     = p_man.num_altern_roteiro
   LET p_man_apo_detalhe.sequencia_operacao = p_man.num_seq_operac
   LET p_man_apo_detalhe.operacao           = p_man.cod_operac
   LET p_man_apo_detalhe.unid_produtiva     = p_man.unid_produtiva
   LET p_man_apo_detalhe.centro_trabalho    = p_man.cod_cent_trab
   LET p_man_apo_detalhe.arranjo_fisico     = p_man.cod_arranjo
   LET p_man_apo_detalhe.centro_custo       = p_man.cod_cent_cust
   LET p_man_apo_detalhe.atualiza_eqpto_min = 'N'
   LET p_man_apo_detalhe.eqpto              = p_man.cod_eqpto
   LET p_man_apo_detalhe.atlz_ferr_min      = 'N'
   LET p_man_apo_detalhe.ferramental        = p_man.cod_ferramenta
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA MAN_APO_DETALHE'
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1168_gra_tabs_velhas()
#---------------------------------#
  
  LET p_apo_oper.cod_empresa     = p_man.cod_empresa
  LET p_apo_oper.dat_producao    = p_man.dat_inicial
  LET p_apo_oper.cod_item        = p_man.cod_item
  LET p_apo_oper.num_ordem       = p_man.num_ordem
  LET p_apo_oper.num_seq_operac  = p_man.num_seq_operac
  LET p_apo_oper.cod_operac      = p_man.cod_operac
  LET p_apo_oper.cod_cent_trab   = p_man.cod_cent_trab
  LET p_apo_oper.cod_arranjo     = p_man.cod_arranjo
  LET p_apo_oper.cod_cent_cust   = p_man.cod_cent_cust
  LET p_apo_oper.cod_turno       = p_man.cod_turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial
  LET p_apo_oper.hor_fim         = p_man.hor_final
  LET p_apo_oper.qtd_boas        = p_qtd_boas
  LET p_apo_oper.qtd_refugo      = p_qtd_refug
  LET p_apo_oper.qtd_sucata      = p_qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.cod_local
  LET p_apo_oper.cod_tip_movto   = p_man.tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = p_man.dat_apontamento
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA APO_OPER'
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2] # apo_oper.num_processo

  LET p_cfp_apms.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_apms.num_seq_registro = p_num_seq_reg
  LET p_cfp_apms.cod_tip_movto    = p_apo_oper.cod_tip_movto

  IF p_man.tip_movto  = "E" THEN
    LET p_cfp_apms.ies_situa    = "C"
  ELSE
    LET p_cfp_apms.ies_situa    = "A"
  END IF

  LET p_cfp_apms.dat_producao   = p_apo_oper.dat_producao
  LET p_cfp_apms.num_ordem      = p_apo_oper.num_ordem
  
  IF p_man.cod_eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.cod_eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.cod_ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.cod_ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET  p_cfp_apms.cod_cent_trab     = p_apo_oper.cod_cent_trab
  LET p_cfp_apms.cod_unid_prod      = p_man.unid_produtiva
  LET p_cfp_apms.cod_roteiro        = p_man.cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_man.num_altern_roteiro
  LET p_cfp_apms.num_seq_operac     = p_apo_oper.num_seq_operac
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = p_apo_oper.num_conta
  LET p_cfp_apms.cod_local          = p_apo_oper.cod_local
  LET p_cfp_apms.dat_apontamento    = EXTEND(p_apo_oper.dat_apontamento, YEAR TO DAY)
  LET p_cfp_apms.hor_apontamento    = EXTEND(p_apo_oper.dat_apontamento, HOUR TO SECOND)
  LET p_cfp_apms.nom_usuario_resp   = p_user
  LET p_cfp_apms.tex_apont          = NULL

  IF p_man.tip_movto = "E"  THEN
    LET p_cfp_apms.dat_estorno     = p_dat_movto
    LET p_cfp_apms.hor_estorno     = p_hor_movto
    LET p_cfp_apms.nom_usu_estorno = p_user
  ELSE
    LET p_cfp_apms.dat_estorno     = NULL
    LET p_cfp_apms.hor_estorno     = NULL
    LET p_cfp_apms.nom_usu_estorno = NULL
  END IF

  INSERT INTO cfp_apms VALUES(p_cfp_apms.*)
  
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA CFP_APMS'
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA CFP_APPR'
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA CFP_APTM'
      RETURN FALSE
   END IF
   
   INSERT INTO man_relc_tabela
    VALUES(p_man.cod_empresa,
           p_seq_reg_mestre,
           p_num_seq_reg,
           p_tip_producao)

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA MAN_RELC_TABELA'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#----------------------------------#   
FUNCTION pol1168_ins_apont_proces()
#----------------------------------#
   
   insert into apont_proces_405
    values(p_man.cod_empresa,
           p_man.id_man_apont,
           p_num_seq_reg,
           p_seq_reg_mestre)
           
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA APONT_PROCES_405'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1168_cria_tabs()
#---------------------------#

   DROP TABLE consumo_tmp_405
   
   CREATE   TABLE consumo_tmp_405(
      cod_empresa CHAR(02),
      cod_compon  CHAR(15),
      cod_local   CHAR(15),
      qtd_neces   DECIMAL(10,3),
      qtd_saldo   DECIMAL(10,3)
   );
   
	 IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO CRIANDO TABELA TEMPORARIA CONSUMO_TMP_405'
			RETURN FALSE
	 END IF

   DROP TABLE sucata_tmp_405
   
   CREATE  TABLE sucata_tmp_405(
      cod_empresa CHAR(02),
      cod_compon  CHAR(15),
      cod_local   CHAR(15),
      qtd_neces   DECIMAL(10,3),
      qtd_saldo   DECIMAL(10,3)
   );
   
	 IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO CRIANDO TABELA TEMPORARIA SUCATA_TMP_405'
			RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION
           
#-----------------------------#
FUNCTION pol1168_le_material()
#-----------------------------#
   
   DEFINE p_num_sequencia INTEGER

   DECLARE cq_lm CURSOR FOR
    SELECT item_componente,
           qtd_necess,
           local_baixa,
           sequencia_componente
      from man_op_componente_operacao
     where empresa            = p_man.cod_empresa
       and ordem_producao     = p_man.num_ordem
       and item_pai           = p_man.cod_item
       and roteiro            = p_man.cod_roteiro
       and num_altern_roteiro = p_man.num_altern_roteiro
       and sequencia_operacao = p_man.num_seq_operac
     order by sequencia_componente
     
   FOREACH cq_lm INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_orig,
           p_num_sequencia

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO COMPONENTES DA TABELA MAN_OP_COMPONENTE_OPERACAO'
         RETURN FALSE
      END IF  

      IF p_cod_compon = p_man.cod_compon then
         LET p_qtd_baixar = p_man.qtd_baixar * p_qtd_prod
      ELSE
         LET p_qtd_baixar = p_qtd_necessaria * p_qtd_prod
      END IF

      IF p_qtd_baixar <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1168_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' OR 
         p_ctr_estoque  = 'N' OR
         p_sofre_baixa  = 'N' THEN
         CONTINUE FOREACH
      END IF

      SELECT qtd_neces
        FROM consumo_tmp_405
       WHERE cod_compon = p_cod_compon
         AND cod_local  = p_cod_local_orig
      
      IF STATUS = 0 THEN
         UPDATE consumo_tmp_405
            SET qtd_neces = qtd_neces + p_qtd_baixar
          WHERE cod_compon = p_cod_compon
            AND cod_local  = p_cod_local_orig
      ELSE
         IF STATUS = 100 THEN
            INSERT INTO consumo_tmp_405
               VALUES(p_man.cod_empresa, 
                      p_cod_compon, 
                      p_cod_local_orig, 
                      p_qtd_baixar,0) 
         ELSE
            CALL log003_err_sql('Lendo','consumo_tmp_405')
            Return FALSE
         END IF
      END IF 
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1168_le_sucata()
#---------------------------#
   
   DEFINE p_num_sequencia INTEGER

   DECLARE cq_ls CURSOR FOR
    SELECT item_componente,
           sequencia_componente
      from man_op_componente_operacao
     where empresa            = p_man.cod_empresa
       and ordem_producao     = p_man.num_ordem
       and item_pai           = p_man.cod_item
       and roteiro            = p_man.cod_roteiro
       and num_altern_roteiro = p_man.num_altern_roteiro
       and sequencia_operacao = p_man.num_seq_operac
     order by sequencia_componente
     
   FOREACH cq_ls INTO 
           p_cod_compon, 
           p_num_sequencia

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO COMPONENTES DA TABELA MAN_OP_COMPONENTE_OPERACAO'
         RETURN FALSE
      END IF  

      IF p_cod_compon = p_man.cod_compon then
         LET p_qtd_baixar = p_man.baixa_sucata * p_qtd_prod
      ELSE
         LET p_qtd_baixar = 0
      END IF

      IF p_qtd_baixar <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1168_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' OR 
         p_ctr_estoque  = 'N' OR
         p_sofre_baixa  = 'N' THEN
         CONTINUE FOREACH
      END IF

      LET p_cod_local_orig = p_cod_local_estoq
      
      SELECT qtd_neces
        FROM sucata_tmp_405
       WHERE cod_compon = p_cod_compon
         AND cod_local  = p_cod_local_orig
      
      IF STATUS = 0 THEN
         UPDATE sucata_tmp_405
            SET qtd_neces = qtd_neces + p_qtd_baixar
          WHERE cod_compon = p_cod_compon
            AND cod_local  = p_cod_local_orig
      ELSE
         IF STATUS = 100 THEN
            INSERT INTO sucata_tmp_405
               VALUES(p_man.cod_empresa, 
                      p_cod_compon, 
                      p_cod_local_orig, 
                      p_qtd_baixar,0) 
         ELSE
            CALL log003_err_sql('Lendo','consumo_tmp_405')
            Return FALSE
         END IF
      END IF 
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol1168_checa_material()
#-------------------------------#
   
   DECLARE cq_cm CURSOR FOR
    SELECT cod_empresa,
           cod_compon,
           cod_local,
           qtd_neces
      FROM consumo_tmp_405
     WHERE qtd_neces > 0
     
   FOREACH cq_cm INTO 
           p_man.cod_empresa,
           p_cod_compon, 
           p_cod_local_orig,
           p_qtd_baixar

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA CONSUMO_TMP_405'
         RETURN FALSE
      END IF  

      LET p_saldo_txt = p_qtd_baixar
      LET p_msg = 'LOCAL: ', p_cod_local_orig CLIPPED, 
                  ' ITEM: ',p_cod_compon CLIPPED, 
                  ' NECESSITA: ', p_saldo_txt CLIPPED, 
                  ' SALDO: '

      LET p_sem_estoque = FALSE

      IF NOT pol1168_checa_estoque() THEN
         RETURN FALSE
      END IF

      IF p_sem_estoque THEN
         let p_saldo_txt = p_qtd_saldo
         LET p_msg = p_msg CLIPPED, ' ', p_saldo_txt
         CALL pol1168_insere_erro()
      END IF         

      UPDATE consumo_tmp_405
         SET qtd_saldo = p_qtd_saldo
       WHERE cod_compon = p_cod_compon
         AND cod_local  = p_cod_local_orig

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO ATUALIZANDO TABELA CONSUMO_TMP_405'
         RETURN FALSE
      END IF  
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1168_checa_sucata()
#------------------------------#
   
   DECLARE cq_cs CURSOR FOR
    SELECT cod_empresa,
           cod_compon,
           cod_local,
           qtd_neces
      FROM sucata_tmp_405
     WHERE qtd_neces > 0
     
   FOREACH cq_cs INTO 
           p_man.cod_empresa,
           p_cod_compon, 
           p_cod_local_orig,
           p_qtd_baixar

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA SUCATA_TMP_405'
         RETURN FALSE
      END IF  

      LET p_saldo_txt = p_qtd_baixar
      LET p_msg = 'LOCAL: ', p_cod_local_orig CLIPPED, 
                  ' ITEM: ',p_cod_compon CLIPPED, 
                  ' NECESSITA: ', p_saldo_txt CLIPPED, 
                  ' SALDO: '

      LET p_sem_estoque = FALSE

      IF NOT pol1168_checa_estoque() THEN
         RETURN FALSE
      END IF

      IF p_sem_estoque THEN
         let p_saldo_txt = p_qtd_saldo
         LET p_msg = p_msg CLIPPED, ' ', p_saldo_txt
         call pol1168_insere_erro()
      END IF         

      UPDATE sucata_tmp_405
         SET qtd_saldo = p_qtd_saldo
       WHERE cod_compon = p_cod_compon
         AND cod_local  = p_cod_local_orig

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO ATUALIZANDO TABELA SUCATA_TMP_405'
         RETURN FALSE
      END IF  
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1168_checa_estoque()
#-------------------------------#

	 SELECT SUM(qtd_saldo)
		 INTO p_qtd_saldo
		 FROM estoque_lote_ender
		WHERE cod_empresa   = p_man.cod_empresa
		  AND cod_item      = p_cod_compon
		  AND cod_local     = p_cod_local_orig
      AND ies_situa_qtd IN ('L','E')

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO SALDO DA TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_man.cod_empresa
      AND cod_item    = p_cod_compon
      AND cod_local   = p_cod_local_orig
         
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO RESERVA DE MATERIAL DA TABELA ESTOQUE_LOC_RESER'
      RETURN FALSE
   END IF  
  
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
   
   
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_baixar THEN
      LET p_sem_estoque = TRUE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_baixa_material()
#-------------------------------#
   
   DEFINE p_num_sequencia INTEGER,
          p_local         CHAR(10)

   DECLARE cq_bm CURSOR FOR
    SELECT item_componente,
           qtd_necess,
           local_baixa,
           sequencia_componente
      from man_op_componente_operacao
     where empresa            = p_man.cod_empresa
       and ordem_producao     = p_man.num_ordem
       and item_pai           = p_man.cod_item
       and roteiro            = p_man.cod_roteiro
       and num_altern_roteiro = p_man.num_altern_roteiro
       and sequencia_operacao = p_man.num_seq_operac
     order by sequencia_componente
     
   FOREACH cq_bm INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_orig,
           p_num_sequencia

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO COMPONENTES DA TABELA MAN_OP_COMPONENTE_OPERACAO'
         RETURN FALSE
      END IF  
      
      IF p_man.baixa_sucata IS NULL THEN
         LET p_man.baixa_sucata = 0
      END IF
      
      IF p_cod_compon = p_man.cod_compon then
         LET p_qtd_baixar = p_man.qtd_baixar * p_qtd_prod
         LET p_qtd_rateio = (p_man.qtd_baixar + p_man.baixa_sucata) * p_qtd_prod
      ELSE
         LET p_qtd_baixar = p_qtd_necessaria * p_qtd_prod
         LET p_qtd_rateio = p_qtd_baixar
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1168_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' OR 
         p_ctr_estoque  = 'N' OR
         p_sofre_baixa  = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      LET p_local = p_cod_local_estoq
      
      LET p_coeficente = 0
      
      DECLARE cq_neces CURSOR FOR
       SELECT cod_item_pai,
              qtd_necessaria
         FROM ord_compon 
        WHERE num_ordem = p_man.num_ordem 
          AND cod_empresa = p_cod_empresa 
          AND cod_item_compon = p_cod_compon
      
      FOREACH cq_neces INTO p_num_neces, p_qtd_necessaria
        
         IF STATUS <> 0 THEN
            let p_cod_erro = STATUS
            let p_msg = 'ERRO LENDO TABELA DE COMPONENTES DA OP'
            RETURN FALSE
         END IF  
         
         LET p_qtd_saida = p_qtd_necessaria * p_qtd_prod
         
         UPDATE necessidades
            SET qtd_saida = qtd_saida + p_qtd_saida
          where num_ordem = p_man.num_ordem 
            and cod_empresa = p_cod_empresa 
            and num_neces   = p_num_neces

         IF STATUS <> 0 THEN
            let p_cod_erro = STATUS
            let p_msg = 'ATUALIZANDO TABELA DE NECESSIDADES DA OP'
            RETURN FALSE
         END IF  
         
         LET p_coeficente = p_qtd_saida / p_qtd_rateio
         
      END FOREACH      
      
      IF p_coeficente = 0 THEN
         LET p_coeficente = 1
      END IF
      
      LET p_coeficente = 1
      
      #---efetua a baixa do componente
      
      LET p_cod_proces = 'B'
      LET p_cod_operacao = null
      
      IF NOT pol1168_baixa_compon() THEN
         RETURN FALSE
      END IF

      #---efetua a baixa da sucata
      IF p_man.baixa_sucata > 0 THEN
         IF p_cod_compon = p_man.cod_compon then
            LET p_qtd_baixar = p_man.baixa_sucata * p_qtd_prod
            LET p_cod_local_orig = p_local
            LET p_cod_proces = 'S'
            LET p_cod_operacao = null
            IF NOT pol1168_baixa_compon() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1168_le_item_man()
#-----------------------------#

   SELECT a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.ies_tip_item,
          a.cod_local_estoq,
          b.ies_sofre_baixa
     INTO p_ctr_estoque,
          p_ctr_lote,
          p_ies_tip_item,
          p_cod_local_estoq,
          p_sofre_baixa
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_man.cod_empresa
      AND a.cod_item    = p_cod_compon
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DAS TABELAS ITEM E ITEM_MAN'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1168_baixa_compon()
#------------------------------#

   DECLARE cq_bel CURSOR FOR
		SELECT *
      FROM estoque_lote_ender
	   WHERE cod_empresa = p_man.cod_empresa
	     AND cod_item    = p_cod_compon
       AND cod_local   = p_cod_local_orig
       AND qtd_saldo   > 0
       AND ies_situa_qtd IN ('L','E')
     ORDER BY dat_hor_producao
     
   FOREACH cq_bel INTO p_estoque_lote_ender.*
   
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA ESTOQUE_LOTE_ENDER'
         RETURN FALSE
      END IF  

      IF p_estoque_lote_ender.qtd_saldo > p_qtd_baixar THEN
         LET p_qtd_movto = p_qtd_baixar
         LET p_qtd_baixar = 0
      ELSE
         LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_qtd_movto
      END IF

      IF NOT pol1168_baixa_lote() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1168_baixa_estoque() THEN
         RETURN FALSE
      END IF

      LET p_ies_situa_orig = p_estoque_lote_ender.ies_situa_qtd
      LET p_ies_situa_dest = NULL 
      LET p_num_lote_orig  = p_estoque_lote_ender.num_lote
      LET p_num_lote_dest  = NULL
      LET p_cod_local_dest = NULL
   
      LET p_tip_movto = 'S'
      
      IF NOT pol1168_grava_estoq_trans() THEN
         RETURN FALSE
      END IF
      
      IF p_tip_oper = 'A' THEN
         IF NOT pol1168_insere_man_consumo() THEN
            RETURN FALSE
         END IF
         IF NOT pol1168_insere_chf_componente() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_qtd_baixar > 0 THEN
      LET p_cod_erro = ''
      LET p_msg = 'COMPONENTE ', p_cod_compon CLIPPED, 
                  ' SEM SALDO SUFUCIENTE PARA BAIXAR.'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1168_baixa_lote()
#----------------------------#

   IF p_estoque_lote_ender.qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   END IF
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS DA TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF  

   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND num_lote      = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   ELSE
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
         AND num_lote        IS NULL
   END IF
   
   IF STATUS <> 0 OR p_qtd_saldo < p_estoque_lote_ender.qtd_saldo THEN
      let p_cod_erro = STATUS
      LET p_msg = "ITEM ", p_estoque_lote_ender.cod_item CLIPPED, " COM DIVERG�NCIA\n",
                  "ENTRE AS TABELAS ESTOQUE_LOTE\n",
                  "E ESTOQUE_LOTE_ENDER. \n", 
                  "O APONTAMENTO SER� CANCELADO\n"
      RETURN FALSE
   END IF  

   IF p_qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_num_transac
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_num_transac
   END IF
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS DA TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_baixa_estoque()
#-------------------------------#
         
   IF p_estoque_lote_ender.ies_situa_qtd = 'L' THEN
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_movto,
             dat_ult_saida = p_dat_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   ELSE
      UPDATE estoque
         SET qtd_lib_excep = qtd_lib_excep - p_qtd_movto,
             dat_ult_saida = p_dat_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   END IF

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS DA TABELA ESTOQUE'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_grava_estoq_trans()
#-----------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01)
   
   INITIALIZE p_estoque_trans.* TO NULL

   IF p_cod_operacao IS NULL THEN
      IF NOT pol1168_le_operacao() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_tip_oper = 'A' THEN
   
      SELECT ies_com_detalhe
        INTO p_ies_com_detalhe
        FROM estoque_operac
       WHERE cod_empresa  = p_man.cod_empresa
         AND cod_operacao = p_cod_operacao

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA ESTOQUE_OPERAC'
         RETURN FALSE
      END IF

      IF p_ies_com_detalhe = 'S' THEN 
         IF p_cod_proces MATCHES '[BS]' THEN
            SELECT num_conta_debito 
              INTO p_num_conta
              FROM estoque_operac_ct
             WHERE cod_empresa  = p_man.cod_empresa
               AND cod_operacao = p_cod_operacao
         ELSE
            SELECT num_conta_credito 
              INTO p_num_conta
              FROM estoque_operac_ct
             WHERE cod_empresa  = p_man.cod_empresa
              AND cod_operacao = p_cod_operacao
         END IF
         IF STATUS <> 0 THEN
            let p_cod_erro = STATUS
            let p_msg = 'ERRO LENDO DADOS DA TABELA ESTOQUE_OPERAC_CT'
           RETURN FALSE
         END IF
      ELSE
         LET p_num_conta = NULL
      END IF
      
      LET p_estoque_trans.num_docum = p_man.num_ordem
   Else
      LET p_estoque_trans.num_docum = p_num_programa
   END IF
   
   LET p_estoque_trans.cod_empresa        = p_estoque_lote_ender.cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = p_dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_dat_movto
   LET p_estoque_trans.dat_proces         = p_dat_movto
   LET p_estoque_trans.hor_operac         = p_hor_movto
   LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = p_man.nom_prog
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = p_cod_uni_funcio
   LET p_estoque_trans.nom_usuario        = p_man.nom_usuario
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest

    INSERT INTO estoque_trans(
          cod_empresa,
          num_transac,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.num_transac,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA ESTOQUE_TRANS'
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   IF NOT pol1168_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol1168_insere_estoq_audit() THEN
      RETURN FALSE
   END IF

   IF p_tip_oper = 'A' THEN
      IF NOT pol1168_apont_transac() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1168_le_operacao()
#-----------------------------#

   IF p_cod_proces = 'B' THEN   #se for baixa de material
      SELECT cod_estoque_sp    
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_man.cod_empresa
   ELSE                
      IF p_cod_proces = 'T' THEN  #se for transfer�ncia entre local
         SELECT cod_estoque_ac
           INTO p_cod_operacao
           FROM par_pcp
          WHERE cod_empresa = p_man.cod_empresa       
      ELSE
         IF p_cod_proces = 'S' THEN  #se for baixa de sucata
            SELECT cod_estoque_sn
              INTO p_cod_operacao
              FROM par_pcp
             WHERE cod_empresa = p_man.cod_empresa       
         ELSE
            SELECT cod_estoque_rp     #se for entrada do item produzido
              INTO p_cod_operacao
              FROM par_pcp
             WHERE cod_empresa = p_man.cod_empresa
         END IF
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS DA TABELA ESTOQUE'
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol1168_ins_est_trans_end()
#------------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.num_transac      = p_num_transac_orig
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f 
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA ESTOQUE_TRANS_END'
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_insere_estoq_audit()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            p_dat_movto,
            p_man.nom_prog)

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA ESTOQUE_AUDITORIA'
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_apont_transac()
#-------------------------------#

  INSERT INTO apont_transac_405 
     VALUES(p_estoque_trans.cod_empresa, 
            p_man.id_man_apont,
            p_num_transac_orig, 
            p_tip_movto)

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA APONT_TRANSAC_405'
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1168_insere_man_item()
#---------------------------------#

   LET p_man_item_produzido.empresa               = p_man.cod_empresa
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
   LET p_man_item_produzido.moviment_estoque      = p_num_transac_pai
   LET p_man_item_produzido.seq_reg_normal        = ''
   LET p_man_item_produzido.observacao            = p_estoque_lote_ender.tex_reservado
   LET p_man_item_produzido.identificacao_estoque = ' '
   
  INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
     seq_registro_item,    
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
     p_man_item_produzido.seq_registro_item,    
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA MAN_ITEM_PRODUZIDO'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1168_ins_man_def()
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
          p_man.cod_defeito,
          p_qtd_movto,
          0,
          " ")
   
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA MAN_DEF_PRODUCAO'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_insere_man_consumo()
#-----------------------------------#

   LET p_man_comp_consumido.empresa            = p_estoque_lote_ender.cod_empresa
   LET p_man_comp_consumido.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_comp_consumido.seq_registro_item  = 0
   LET p_man_comp_consumido.tip_movto          = p_cod_tip_movto
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
   LET p_man_comp_consumido.qtd_baixa_prevista = p_qtd_movto * p_coeficente                       
   LET p_man_comp_consumido.qtd_baixa_real     = p_qtd_movto * p_coeficente                       
   LET p_man_comp_consumido.sit_est_componente = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_comp_consumido.data_producao      = p_estoque_lote_ender.dat_hor_producao
   LET p_man_comp_consumido.data_valid         = p_estoque_lote_ender.dat_hor_validade
   LET p_man_comp_consumido.conta_ctbl         = p_num_conta
   LET p_man_comp_consumido.moviment_estoque   = p_num_transac_orig
   LET p_man_comp_consumido.mov_estoque_pai    = p_num_transac_pai
   LET p_man_comp_consumido.seq_reg_normal     = ''
   LET p_man_comp_consumido.observacao         = p_tip_producao
   LET p_man_comp_consumido.identificacao_estoque = ''
   LET p_man_comp_consumido.depositante        = ''

   INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
     seq_registro_item, 
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
     p_man_comp_consumido.seq_registro_item, 
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA MAN_COMP_CONSUMIDO'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1168_insere_chf_componente()
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
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO REGISTRO NA TABELA CHF_COMPONENTE'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1168_grava_ordens()
#-----------------------------#

   select dat_ini
     into p_dat_inicio
     from ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS NA TABELA ORDENS'
      RETURN FALSE
   END IF

   IF p_dat_inicio is null then
      let p_dat_inicio = p_man.dat_inicio
   end if

   UPDATE ordens
      SET qtd_boas   = qtd_boas + p_qtd_boas,
          qtd_refug  = qtd_refug + p_qtd_refug,
          qtd_sucata = qtd_sucata + p_qtd_sucata,
          dat_ini    = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO DADOS NA TABELA ORDENS'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1168_le_item()
#-------------------------#

   SELECT cod_local_estoq,
          cod_local_insp,
          ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao
     INTO p_cod_local_estoq,
          p_cod_local_insp,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tem_inspecao
     FROM item
    WHERE cod_empresa = p_man.cod_empresa
      AND cod_item    = p_man.cod_item

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DA TABELA ITEM'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1168_le_est_lote_ender()
#----------------------------------#

   Let p_tem_lote = false

   IF NOT pol1168_le_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1168_le_ctr_grade(p_man.cod_item) THEN
      RETURN FALSE
   END IF

   IF p_ies_ctr_lote = 'S' THEN
      LET p_num_lote = p_man.num_lote
   ELSE
      INITIALIZE p_num_lote TO NULL
   END IF
   
   IF p_ies_dat_producao = 'S' THEN
      LET p_dat_aux = p_man.dat_inicial
      LET p_dat_char = p_dat_aux, " ", p_man.hor_inicial
      LET p_date_time = p_dat_char
   ELSE
      LET p_date_time = "1900-01-01 00:00:00"   
   END IF
   
   IF p_num_lote IS NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_man.cod_empresa
         AND cod_item         = p_man.cod_item
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND largura          = p_largura
         AND altura           = p_altura
         AND diametro         = p_diametro
         AND comprimento      = p_comprimento
         AND dat_hor_producao = p_date_time
         AND num_lote           IS NULL
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_man.cod_empresa
         AND cod_item         = p_man.cod_item
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND largura          = p_largura
         AND altura           = p_altura
         AND diametro         = p_diametro
         AND comprimento      = p_comprimento
         AND dat_hor_producao = p_date_time
         AND num_lote         = p_num_lote
   END IF   

   if status = 0 then
      let p_tem_lote = true
   else
      if status <> 100 then
         call log003_err_sql('Lendo','estoque_lote_ender')
         RETURN false
      end if
   end if
   
   RETURN true
   
END FUNCTION

#--------------------------------#
FUNCTION pol1168_aponta_estoque()
#--------------------------------#

   LET p_cod_proces  = 'E'
   
   IF p_tem_lote THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT pol1168_atualiza_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      CALL pol1168_ender_carrega()
      IF NOT pol1168_insere_lote_ender() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_num_lote IS NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa      = p_man.cod_empresa
         AND cod_item         = p_man.cod_item
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND num_lote           IS NULL
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa      = p_man.cod_empresa
         AND cod_item         = p_man.cod_item
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND num_lote         = p_num_lote
   END IF   

   IF STATUS = 0 THEN
      IF NOT pol1168_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol1168_lote_carrega()
         IF NOT pol1168_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO PRODUTO DA TABELA P_ESTOQUE_LOTE'
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1168_atualiza_estoque() THEN
      RETURN FALSE
   END IF

   LET p_num_lote_orig  = NULL
   LET p_cod_local_orig = NULL
   LET p_ies_situa_orig = NULL
   LET p_num_lote_dest  = p_num_lote
   LET p_cod_local_dest = p_cod_local_estoq
   LET p_ies_situa_dest = p_ies_situa

   LET p_tip_movto = 'E'

   IF NOT pol1168_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   LET p_num_transac_pai = p_num_transac_orig
      
   RETURN TRUE
  
END FUNCTION

#---------------------------------------#
FUNCTION pol1168_le_ctr_grade(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item      LIKE item.cod_item,
          p_cod_lin_prod  LIKE item.cod_lin_prod,
          p_cod_lin_recei LIKE item.cod_lin_recei,
          p_cod_seg_merc  LIKE item.cod_seg_merc,
          p_cod_cla_uso   LIKE item.cod_cla_uso,
          p_cod_familia   LIKE item.cod_familia
   
   SELECT cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso,
          cod_familia
     INTO p_cod_lin_prod,
          p_cod_lin_recei,
          p_cod_seg_merc,
          p_cod_cla_uso,
          p_cod_familia
     FROM item
    WHERE cod_empresa = p_man.cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DA TABELA ITEM'
      RETURN FALSE
   END IF
   
   SELECT ies_largura,
          ies_altura,
          ies_diametro,
          ies_comprimento,
          reservado_2,
          ies_dat_producao
     INTO p_ies_largura,
          p_ies_altura,
          p_ies_diametro,
          p_ies_comprimento,
          p_ies_serie,
          p_ies_dat_producao
     FROM item_ctr_grade
    WHERE cod_empresa   = p_man.cod_empresa
      AND cod_item      = p_cod_item
      AND cod_lin_prod  = p_cod_lin_prod
      AND cod_lin_recei = p_cod_lin_recei
      AND cod_seg_merc  = p_cod_seg_merc
      AND cod_cla_uso   = p_cod_cla_uso
      AND cod_familia   = p_cod_familia

   IF STATUS = 100 THEN
      LET p_ies_largura      = 'N'
      LET p_ies_altura       = 'N'
      LET p_ies_diametro     = 'N'
      LET p_ies_comprimento  = 'N'
      LET p_ies_serie        = 'N'
      LET p_ies_dat_producao = 'N'
   ELSE
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO DADOS DA TABELA ITEM_CTR_GRADE'
         RETURN FALSE
      END IF
   END IF

   LET p_largura = 0
   LET p_altura = 0
   LET p_diametro = 0
   LET p_comprimento = 0

   IF p_ies_largura = 'S' THEN
   END IF

   IF p_ies_altura = 'S' THEN
   END IF
   
   IF p_ies_diametro = 'S' THEN
   END IF

   IF p_ies_comprimento = 'S' THEN
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1168_atualiza_lote_ender()
#------------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO PRODUTO NA TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1168_ender_carrega()
#-------------------------------#

   LET p_estoque_lote_ender.cod_empresa   = p_man.cod_empresa
	 LET p_estoque_lote_ender.cod_item      = p_man.cod_item
	 LET p_estoque_lote_ender.cod_local     = p_cod_local_estoq
	 LET p_estoque_lote_ender.num_lote      = p_num_lote
   LET p_estoque_lote_ender.largura       = p_largura
   LET p_estoque_lote_ender.altura        = p_altura
   LET p_estoque_lote_ender.diametro      = p_diametro
   LET p_estoque_lote_ender.comprimento   = p_comprimento
   LET p_estoque_lote_ender.num_serie     = ' '
   LET p_estoque_lote_ender.dat_hor_producao = p_date_time
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
   LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1168_insere_lote_ender()
#-----------------------------------#

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          num_transac,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.num_transac,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO PRODUTO NA TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1168_atualiza_lote()
#-------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_man.cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO PRODUTO NA TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1168_lote_carrega()
#------------------------------#

   LET p_estoque_lote.cod_empresa   = p_man.cod_empresa
	 LET p_estoque_lote.cod_item      = p_man.cod_item
	 LET p_estoque_lote.cod_local     = p_cod_local_estoq
	 LET p_estoque_lote.num_lote      = p_num_lote
	 LET p_estoque_lote.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote.qtd_saldo     = p_qtd_movto
	 LET p_estoque_lote.num_transac   = 0

END FUNCTION

#-----------------------------#
FUNCTION pol1168_insere_lote()
#-----------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo,
          num_transac)  
          VALUES(p_estoque_lote.cod_empresa,
                 p_estoque_lote.cod_item,
                 p_estoque_lote.cod_local,
                 p_estoque_lote.num_lote,
                 p_estoque_lote.ies_situa_qtd,
                 p_estoque_lote.qtd_saldo,
                 p_estoque_lote.num_transac)
                 
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO INSERINDO PRODUTO NA TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1168_atualiza_estoque()
#---------------------------------#

   IF p_estoque_lote_ender.ies_situa_qtd = 'L' THEN
      UPDATE estoque
         SET qtd_liberada    = qtd_liberada + p_qtd_movto,
             dat_ult_entrada = p_dat_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   ELSE
      UPDATE estoque
         SET qtd_rejeitada   = qtd_rejeitada + p_qtd_movto,
             dat_ult_entrada = p_dat_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   END IF

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ATUALIZANDO PRODUTO NA TABELA ESTOQUE'
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION



#-----FIM DO PROGRAMA------------------#

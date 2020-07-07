#-------------------------------------------------------------------#
# OBJETIVO: SUCATEAMENTO DE BOBINA                                  #
# DATA....: 03/03/2011                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_dat_movto          DATE,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_num_bobina         CHAR(20),
          p_ies_apon           SMALLINT,
          p_num_transac        INTEGER,
          p_dat_transfer       DATE,
          p_num_transac_de     INTEGER,
          p_num_transac_para   INTEGER,
          p_qtd_bob_transf    INTEGER,
          p_qtd_txt           CHAR(10)
               
   DEFINE p_tela               RECORD
          dat_ini              DATE,
          dat_fim              DATE,
          dat_transfer         DATE,
          cod_item             CHAR(15),
          num_lote             CHAR(15)
   END RECORD
     
   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*
   
   DEFINE p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_cod_local          LIKE item.cod_local_estoq,
          p_item_orig          LIKE item.cod_item,
          p_cod_item           LIKE item.cod_item,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_ies_situa          LIKE estoque_lote.ies_situa_qtd,
          p_qtd_movto          LIKE estoque_lote.qtd_saldo
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1087-05.10.06"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1087_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1087_menu()
#----------------------#
          
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1087") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1087 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1087_carrega_boninas() THEN
      RETURN
   END IF
      
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1087_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'operação efetuada com sucesso !'
         ELSE
            LET p_ies_cons = TRUE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Processar" "Processa a transferência das bobinas"
         IF p_ies_cons THEN
            CALL log085_transacao("BEGIN")
            CALL pol1087_processar() RETURNING p_status
            MESSAGE ''
            IF p_status THEN
               ERROR 'Processamento efetuado com sucesso !'
               CALL log085_transacao("COMMIT")
               LET p_ies_cons = FALSE
               NEXT OPTION 'Fim'
            ELSE
               CALL log085_transacao("ROLLBACK")
               ERROR 'Operação cancelada !!!'
            END IF 
         ELSE
            ERROR 'informe os parãmetros previamente!!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Consultar" "Consulta as divergências encontradas no processamento"
         CALL pol1087_consultar()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1087

END FUNCTION

#---------------------------#
FUNCTION pol1087_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE

END FUNCTION
   
#--------------------------#
FUNCTION pol1087_informar()
#--------------------------#

   CALL pol1087_limpa_tela()

   SELECT EXTEND(dat_transfer, YEAR TO DAY)
     INTO p_dat_transfer
     FROM dat_transfer_885
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dat_transfer_885')     
      RETURN FALSE
   END IF
   
   LET p_tela.dat_ini = p_dat_transfer + 1
   LET p_tela.cod_item = '010040011'
   LET p_tela.num_lote = 'CIB2010'
   LET p_tela.dat_ini = '30/12/2008'
   LET p_tela.dat_fim = '31/12/2010'
   LET p_tela.dat_transfer = '03/01/2011'
  
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatorio!!!'
            NEXT FIELD dat_ini
         END IF
         
         IF p_tela.dat_ini <= p_dat_transfer THEN
            ERROR 'Data inicial deve ser maior que ',p_dat_transfer,
                  '(última transferência)'
            #NEXT FIELD dat_ini
         END IF
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_fim IS NULL THEN
               ERROR 'Campo com preenchimento obrigatorio!!!'
               NEXT FIELD dat_fim
            END IF
            IF p_tela.dat_transfer IS NULL THEN
               ERROR 'Campo com preenchimento obrigatorio!!!'
               NEXT FIELD dat_transfer
            END IF
            IF p_tela.dat_fim IS NOT NULL THEN
               IF p_tela.dat_ini > p_tela.dat_fim THEN
                  ERROR "Data final menor que data inicial !!!"
                  NEXT FIELD dat_fim
               END IF 
            END IF
         END IF
            
   END INPUT

   IF INT_FLAG  THEN
      CALL pol1087_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1087_carrega_boninas()
#--------------------------------#
   
   DEFINE p_ies_carga CHAR(01)
      
   SELECT ies_carga
     INTO p_ies_carga
     FROM bob_carga_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','bob_carga_885')     
      RETURN FALSE
   END IF
   
   IF p_ies_carga = 'S' THEN
      RETURN TRUE
   END IF
  
   CALL log085_transacao("BEGIN")  
  
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "UNL"
      
   LET p_nom_arquivo = 'bobinas.unl'
   LET p_arq_origem = p_caminho CLIPPED, p_nom_arquivo

   LOAD FROM p_arq_origem INSERT INTO bob_tmp_885

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD","bob_tmp_885")
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   UPDATE bob_carga_885 SET ies_carga = 'S'

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("update","bob_carga_885")
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1087_processar()
#---------------------------#
   
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF
   
   LET p_qtd_bob_transf = 0
   
   DELETE FROM bob_erro_885
      
   DECLARE cq_bob CURSOR FOR
    SELECT DISTINCT num_bobina
      FROM bob_tmp_885
   
   FOREACH cq_bob INTO p_num_bobina
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','bob_tmp_885:cq_bob')
         RETURN FALSE
      END IF
      
      MESSAGE 'Processando... ', p_num_bobina
      
      LET p_ies_apon = FALSE
      
      DECLARE cq_apon CURSOR FOR
       SELECT *
         FROM estoque_trans
        WHERE cod_empresa IN ('02','O2')
          AND (cod_operacao  = 'TDM+' OR
               cod_operacao  = 'APOM' OR
               cod_operacao  = 'IMPL' OR
               cod_operacao  = 'APON')
          AND ies_tip_movto = 'N'
          AND num_lote_dest = p_num_bobina
          AND dat_movto    >= p_tela.dat_ini
          AND dat_movto    <= p_tela.dat_fim
      
      FOREACH cq_apon INTO p_estoque_trans.*
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','estoque_trans:cq_apon')
            RETURN FALSE
         END IF

         LET p_ies_apon = TRUE
                          
         SELECT num_transac_rev
           FROM estoque_trans_rev
          WHERE cod_empresa = p_estoque_trans.cod_empresa
            AND num_transac_normal = p_estoque_trans.num_transac
         
         IF STATUS = 0 OR STATUS = -284 THEN
            CONTINUE  FOREACH
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('lendo','estoque_trans_rev:cq_apon')
               RETURN FALSE
            END IF
         END IF
         
         IF NOT pol1087_baixa_estoque() THEN
            RETURN FALSE
         END IF
                    
      END FOREACH
      
      IF NOT p_ies_apon THEN
         LET p_msg = 'Bobina nao foi apontada pelo processo de integracao'
         IF NOT pol1087_critica() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH

   UPDATE dat_transfer_885 SET dat_transfer = p_tela.dat_fim
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','dat_transfer_885')     
      RETURN FALSE
   END IF
   
   LET p_qtd_txt = p_qtd_bob_transf
   LET p_msg = 'Número de bobinas sucateadas: ', p_qtd_txt
   CALL log0030_mensagem(p_msg,'info')
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1087_baixa_estoque()
#-------------------------------#

   DEFINE p_qtd_liberada, p_qtd_lib_excep DECIMAL(10,2)
   
   SELECT COUNT(num_transac)
     INTO p_count
     FROM estoque_lote
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender:1')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_msg = 'Bobina nao encontrada na tab estoque_lote'
      IF NOT pol1087_critica() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   DELETE FROM estoque_lote
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   SELECT COUNT(num_transac)
     INTO p_count
     FROM estoque_lote_ender
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender:1')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_msg = 'Bobina nao encontrada na tab estoque_lote_ender'
      IF NOT pol1087_critica() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   SELECT qtd_liberada,
          qtd_lib_excep
     INTO p_qtd_liberada,
          p_qtd_lib_excep
     FROM estoque
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque')
      RETURN FALSE
   END IF
   
   IF p_estoque_trans.ies_sit_est_dest = 'L' THEN
      IF p_estoque_trans.qtd_movto < p_qtd_liberada THEN
         LET p_qtd_liberada = p_qtd_liberada - p_estoque_trans.qtd_movto
      ELSE
         LET p_qtd_liberada = 0
      END IF
   ELSE
      IF p_estoque_trans.ies_sit_est_dest = 'E' THEN
         IF p_estoque_trans.qtd_movto < p_qtd_lib_excep THEN
            LET p_qtd_lib_excep = p_qtd_lib_excep - p_estoque_trans.qtd_movto
         ELSE
            LET p_qtd_lib_excep = 0
         END IF
      ELSE
         LET p_msg = 'Status da bobina: ', p_estoque_trans.ies_sit_est_dest, 
                     ' status esperados: L/E'
         IF NOT pol1087_critica() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF
   END IF
   
   UPDATE estoque
      SET qtd_liberada  = p_qtd_liberada,
          qtd_lib_excep = p_qtd_lib_excep
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque')
      RETURN FALSE
   END IF

   IF NOT pol1087_de_para_item() THEN
      RETURN FALSE
   END IF
         
   DELETE FROM bob_tmp_885 WHERE num_bobina = p_num_bobina

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','bob_tmp_885')
      RETURN FALSE
   END IF

   IF p_estoque_trans.cod_empresa = '02' THEN
      LET p_qtd_bob_transf = p_qtd_bob_transf + 1
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1087_de_para_item()
#------------------------------#
   
   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_estoque_trans.num_transac
   
   IF STATUS <> 0 THEN     
      CALL log003_err_sql('Lendo','estoque_trans_end')
      RETURN FALSE
   END IF

   SELECT par_txt                                                                
     INTO p_cod_operacao                                                         
     FROM par_sup_pad                                                            
    WHERE cod_empresa   = p_estoque_trans.cod_empresa                                          
      AND den_parametro = 'Operacao de Baixa de estoque itens orig.'             
                                                                                    
   IF STATUS <> 0 THEN     
      CALL log003_err_sql('Lendo','par_sup_pad:de')
      RETURN FALSE
   END IF
   
   LET p_item_orig = p_estoque_trans.cod_item
   
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_lote_orig      = p_estoque_trans.num_lote_dest
   LET p_estoque_trans.cod_local_est_orig = p_estoque_trans.cod_local_est_dest
   LET p_estoque_trans.ies_sit_est_orig   = p_estoque_trans.ies_sit_est_dest
   LET p_estoque_trans.num_lote_dest      = NULL
   LET p_estoque_trans.cod_local_est_dest = NULL
   LET p_estoque_trans.ies_sit_est_dest   = NULL  
   LET p_estoque_trans.dat_movto          = p_tela.dat_transfer
   LET p_estoque_trans.dat_proces         = p_tela.dat_transfer
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.num_prog           = 'POL1087'

   IF NOT pol1087_ins_est_trans() THEN
      RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.num_transac    = p_num_transac
   LET p_estoque_trans_end.cod_operacao   = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.dat_movto      = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.num_prog       = p_estoque_trans.num_prog
   
   IF NOT pol1087_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol1087_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   LET p_num_transac_de = p_num_transac

   IF NOT pol1087_le_local() THEN
      RETURN FALSE
   END IF

   SELECT par_txt 
     INTO p_cod_operacao
	   FROM par_sup_pad
	  WHERE cod_empresa = p_estoque_trans.cod_empresa
	    AND den_parametro = 'Operacao de Baixa de estoque itens dest.'        

   IF STATUS <> 0 THEN     
      CALL log003_err_sql('Lendo','par_sup_pad:para')
      RETURN FALSE
   END IF

   LET p_estoque_trans.cod_item           = p_tela.cod_item
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_lote_dest      = p_tela.num_lote
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.ies_sit_est_dest   = 'L'  
   LET p_estoque_trans.ies_sit_est_orig   = NULL
   LET p_estoque_trans.num_lote_orig      = NULL
   LET p_estoque_trans.cod_local_est_orig = NULL

   IF NOT pol1087_ins_est_trans() THEN
      RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.num_transac    = p_num_transac
   LET p_estoque_trans_end.cod_operacao   = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.cod_item       = p_estoque_trans.cod_item
   
   IF NOT pol1087_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol1087_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   LET p_num_transac_para = p_num_transac

                     
   IF NOT pol1087_ins_trans_relac() THEN
      RETURN FALSE
   END IF

   IF NOT pol1087_atualiza_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1087_le_local()
#--------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local
     FROM item
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_tela.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","item")       
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1087_ins_est_trans()
#-------------------------------#

    INSERT INTO estoque_trans(
          cod_empresa,
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
     CALL log003_err_sql('Inserindo','estoque_trans')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol1087_ins_est_trans_end()
#------------------------------------#

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1087_ins_est_auditoria()
#-----------------------------------#

  DEFINE p_dat_corrent DATETIME YEAR TO SECOND
  
  LET p_dat_corrent = CURRENT
  
  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa, 
            p_num_transac, 
            p_user, 
            p_dat_corrent,
            'pol1087')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1087_ins_trans_relac()
#---------------------------------#

   DEFINE p_est_trans_relac RECORD LIKE est_trans_relac.*,
          p_num_nivel          LIKE item_man.num_nivel
   
   SELECT num_nivel
     INTO p_num_nivel
     FROM item_man
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_item
   
   IF STATUS <> 0 THEN
      LET p_num_nivel = 0
   END IF

   LET p_est_trans_relac.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_est_trans_relac.num_transac_orig = p_num_transac_de
   LET p_est_trans_relac.num_transac_dest = p_num_transac_para
   LET p_est_trans_relac.cod_item_orig    = p_item_orig
   LET p_est_trans_relac.cod_item_dest    = p_estoque_trans.cod_item
   LET p_est_trans_relac.dat_movto        = p_estoque_trans.dat_movto
   LET p_est_trans_relac.num_nivel        = p_num_nivel
   
   INSERT INTO est_trans_relac
     VALUES(p_est_trans_relac.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','est_trans_relac')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION	 

#-------------------------#
FUNCTION pol1087_critica()
#-------------------------#

   INSERT INTO bob_erro_885
    VALUES(p_num_bobina, p_msg)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','bob_erro_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1087_consultar()
#---------------------------#

   DEFINE pr_div     ARRAY[1000] OF RECORD
          num_bobina  CHAR(20),
          mensagem    CHAR(70)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10871") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10871 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_ind = 1
    
   DECLARE cq_erro CURSOR FOR
    SELECT num_bobina,
           mensagem
      FROM bob_erro_885
   
   FOREACH cq_erro INTO 
           pr_div[p_ind].num_bobina,
           pr_div[p_ind].mensagem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','bob_erro_885')           
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_div TO sr_div.*
   
   CLOSE WINDOW w_pol10871
   
END FUNCTION
      
#----------------------------------#
FUNCTION pol1087_atualiza_estoque()
#----------------------------------#

   LET p_cod_item  = p_tela.cod_item
   LET p_num_lote  = p_tela.num_lote
   LET p_ies_situa = 'L'
   LET p_qtd_movto = p_estoque_trans.qtd_movto
   LET p_cod_empresa = p_estoque_trans.cod_empresa
   
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_tela.cod_item
      AND num_lote      = p_tela.num_lote
      AND ies_situa_qtd = p_ies_situa

   IF STATUS = 0 THEN
      IF NOT pol1087_atu_est_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol1087_ins_est_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote:2')
         RETURN FALSE
      END IF
   END IF
      
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa      
      AND cod_item      = p_tela.cod_item    
      AND num_lote      = p_tela.num_lote    
      AND ies_situa_qtd = p_ies_situa        

   IF STATUS = 0 THEN
      IF NOT pol1087_atu_est_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol1087_carrega_lote_ender()
         IF NOT pol1087_ins_est_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote_ender:2')
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1087_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1087_atu_est_lote()
#------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1087_atu_est_lote_ender()
#-----------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote_ender")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1087_atu_estoque()
#----------------------------#

   DEFINE p_qtd_liberada    LIKE estoque.qtd_liberada,
          p_qtd_impedida    LIKE estoque.qtd_impedida,
          p_qtd_rejeitada   LIKE estoque.qtd_rejeitada,
          p_qtd_lib_excep   LIKE estoque.qtd_lib_excep,
          p_dat_ult_entrada LIKE estoque.dat_ult_entrada,
          p_dat_ult_saida   LIKE estoque.dat_ult_saida

   SELECT qtd_liberada,
          qtd_impedida,
          qtd_rejeitada,
          qtd_lib_excep, 
          dat_ult_entrada,
          dat_ult_saida
     INTO p_qtd_liberada,
          p_qtd_impedida,
          p_qtd_rejeitada,
          p_qtd_lib_excep,
          p_dat_ult_entrada,
          p_dat_ult_saida
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      LET p_qtd_liberada  = 0
      LET p_qtd_impedida  = 0
      LET p_qtd_rejeitada = 0
      LET p_qtd_lib_excep = 0
      LET p_dat_ult_entrada = ''
      LET p_dat_ult_saida   = ''
   
      IF NOT pol1087_ins_estoque() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque')
         RETURN FALSE
      END IF      
   END IF  

   IF p_ies_situa = 'L' THEN
      LET p_qtd_liberada  = p_qtd_liberada  + p_qtd_movto 
   ELSE
      IF p_ies_situa = 'E' THEN
         LET p_qtd_lib_excep = p_qtd_lib_excep + p_qtd_movto 
      ELSE
         LET p_qtd_rejeitada = p_qtd_rejeitada + p_qtd_movto
      END IF
   END IF
            
   IF p_qtd_movto > 0 THEN
      LET p_dat_ult_entrada = p_tela.dat_transfer
   ELSE
      LET p_dat_ult_saida = p_tela.dat_transfer
   END IF
      
   UPDATE estoque
      SET qtd_lib_excep   = p_qtd_lib_excep,
          qtd_liberada    = p_qtd_liberada,
          qtd_impedida    = p_qtd_impedida,
          qtd_rejeitada   = p_qtd_rejeitada,          
          dat_ult_entrada = p_dat_ult_entrada,
          dat_ult_saida   = p_dat_ult_saida
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1087_ins_estoque()
#-----------------------------#

   INSERT INTO estoque(
      cod_empresa,
      cod_item,
      qtd_liberada,
      qtd_impedida,
      qtd_rejeitada,
      qtd_lib_excep,
      qtd_disp_venda,
      qtd_reservada,
      dat_ult_invent,
      dat_ult_entrada,
      dat_ult_saida)
      VALUES(p_cod_empresa,p_cod_item,0,0,0,0,0,0,'','','')
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1087_carrega_lote_ender()
#-----------------------------------#

   LET p_estoque_lote_ender.cod_empresa        = p_cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_cod_item
	 LET p_estoque_lote_ender.cod_local          = p_cod_local
	 LET p_estoque_lote_ender.num_lote           = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
   LET p_estoque_lote_ender.largura            = 0
   LET p_estoque_lote_ender.altura             = 0
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.diametro           = 0
   LET p_estoque_lote_ender.comprimento        = 0
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
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

#------------------------------------#
FUNCTION pol1087_ins_est_lote_ender()
#------------------------------------#

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
     CALL log003_err_sql('Inserindo', 'estoque_lote_ender')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1087_ins_est_lote()
#------------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)
          VALUES(p_cod_empresa,
                 p_cod_item,
                 p_cod_local,
                 p_num_lote,
                 p_ies_situa,
                 p_qtd_movto)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_lote')
     RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION

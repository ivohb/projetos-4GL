#-------------------------------------------------------------------#
# PROGRAMA: pol0797                                                 #
# OBJETIVO: BAIXA AUTOMÁTICA DE ITENS REJEITADOS                    #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 28/04/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,       
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_ies_info           SMALLINT, 
          p_caminho            CHAR(080),
          p_msg                CHAR(500),
          p_current            DATETIME YEAR TO SECOND 

   DEFINE p_tela               RECORD
          dat_movto            DATE 
   END RECORD 
   
   DEFINE p_cod_local_rejei    LIKE par_rejei_454.cod_local_rejei,
          p_cod_oper_baixa     LIKE par_rejei_454.cod_oper_baixa,
          p_num_conta          LIKE  par_rejei_454.num_conta,
          p_num_transac_orig   LIKE estoque_trans.num_transac,
          p_dat_fecha_ult_sup  DATE 

          
   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*

   DEFINE pr_lote             ARRAY[3000] OF RECORD
          cod_item            LIKE item.cod_item,
          den_item            LIKE item.den_item,
          num_lote            LIKE estoque_lote.num_lote,
          qtd_saldo           LIKE estoque_lote.qtd_saldo
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0797-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0797.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0797_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0797_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0797") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0797 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   SELECT cod_local_rejei,
          cod_oper_baixa,
          num_conta
     INTO p_cod_local_rejei,
          p_cod_oper_baixa,
          p_num_conta
     FROM par_rejei_454
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_rejei_454')
      RETURN
   END IF
   
    LET p_ies_cons = FALSE
    LET p_ies_info = FALSE 
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ o processamento"
         CALL pol0797_limpa_tela()
         CALL pol0797_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados com sucesso !!!"
            LET p_ies_info = TRUE
            NEXT OPTION 'Processar'
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_info = FALSE
         END IF 
      COMMAND "Consultar" "Consulta os lotes rejeitados em estoque"
         IF pol0797_consultar() THEN
            MESSAGE 'Operação efetuada com sucesso !!!'
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Processar" "Processa a baixa dos lotes rejeitados"
         IF p_ies_info THEN
            CALL pol0797_processar() RETURNING p_status
            IF p_status THEN
               ERROR "Processamento efetuado com sucesso !!!"   
               LET p_ies_info = FALSE
            ELSE
               ERROR 'Operação canceada!!!'
            END IF
            CALL pol0797_limpa_tela()
         ELSE
            ERROR 'Informe os parâmetros previamente!!!'
            NEXT OPTION "Informar"
         END IF 
         NEXT OPTION "Fim" 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0797_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0797

END FUNCTION

#----------------------------#
 FUNCTION pol0797_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0797_informar()
#--------------------------#
   
   INITIALIZE p_tela TO NULL
   

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD dat_movto
         IF p_tela.dat_movto IS NULL THEN
            ERROR "Campo com prenchimento obrigatório!"
            NEXT FIELD dat_movto
         END IF
         
         SELECT dat_fecha_ult_sup
           INTO p_dat_fecha_ult_sup
           FROM par_estoque
          WHERE cod_empresa = p_cod_empresa
          
          IF STATUS <> 0 THEN 
             CALL log003_err_sql('lendo','par_estoque')
             NEXT FIELD dat_movto
          END IF 
          
          IF p_tela.dat_movto < p_dat_fecha_ult_sup THEN 
             ERROR 'A data informada é menor do que a data do último fechamento!'
             NEXT FIELD dat_movto
          END IF 

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0797_consultar()
#---------------------------#

   INITIALIZE pr_lote TO NULL
   LET p_index = 1

   DECLARE cq_ele CURSOR FOR
    SELECT cod_item,
           num_lote,
           qtd_saldo
      FROM estoque_lote_ender
     WHERE cod_empresa   = p_cod_empresa
       AND cod_local     = p_cod_local_rejei
       AND ies_situa_qtd = 'R'
       
   FOREACH cq_ele INTO 
           pr_lote[p_index].cod_item,
           pr_lote[p_index].num_lote,
           pr_lote[p_index].qtd_saldo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender')
         RETURN FALSE
      END IF   
      
      SELECT den_item
        INTO pr_lote[p_index].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_lote[p_index].cod_item
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','item')
         RETURN FALSE
      END IF   
      
      LET p_index = p_index + 1
      
      IF p_index > 3000 THEN
         ERROR 'Limite de linhas da grade ultrapassado!!!'
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_index = 1 THEN
      CALL log0030_mensagem('Não há lotes rejeitados','exclamation')      
   ELSE     
      CALL SET_COUNT(p_index - 1)
      DISPLAY ARRAY pr_lote TO  sr_lote.*
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0797_processar()
#---------------------------#
    
   IF pol0797_ver_saldo() THEN 
   ELSE
      MESSAGE 'Não existem registros para excluir!!!'
      RETURN FALSE 
   END IF

   IF log004_confirm(18,35) THEN
   ELSE
     MESSAGE 'Operação cancelada !!!'
     RETURN FALSE 
   END IF
   
   MESSAGE 'Aguarde!... Processando:' 
   
   DECLARE cq_el CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa   = p_cod_empresa
       AND cod_local     = p_cod_local_rejei
       AND ies_situa_qtd = 'R'
       
   FOREACH cq_el INTO p_estoque_lote_ender.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender')
         RETURN FALSE
      END IF   

      DISPLAY p_estoque_lote_ender.cod_item AT 21,35
      
      IF NOT pol0797_atualiza_estoque() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0797_delete_estoque_lote() THEN
         RETURN FALSE
      END IF

      IF NOT pol0797_insere_estoque_trans() THEN
         RETURN FALSE
      END IF

      LET p_num_transac_orig = SQLCA.SQLERRD[2]

      IF NOT pol0797_insere_estoque_trans_end() THEN
         RETURN FALSE
      END IF
   
      IF NOT pol0797_insere_estoque_auditoria() THEN
         RETURN FALSE
      END IF
   
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','estoque_lote_ender')
         RETURN FALSE
      END IF   
   
   END FOREACH
   LET p_index  = 0 
   RETURN TRUE        

END FUNCTION

#----------------------------------#
FUNCTION pol0797_ver_saldo()
#----------------------------------#
 

     LET p_count   = 0 

    SELECT COUNT(*) 
      INTO p_count 
      FROM estoque_lote_ender
     WHERE cod_empresa   = p_cod_empresa
       AND cod_local     = p_cod_local_rejei
       AND ies_situa_qtd = 'R'

   IF STATUS <> 0 THEN
      LET  p_count = 0 
      RETURN FALSE
   END IF   


   IF p_count >  0 THEN 
      RETURN   TRUE
   ELSE 
      RETURN   FALSE
   END  IF 
 END FUNCTION          
 
#----------------------------------#
FUNCTION pol0797_atualiza_estoque()
#----------------------------------#

   UPDATE estoque
      SET qtd_rejeitada = qtd_rejeitada - p_estoque_lote_ender.qtd_saldo
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_lote_ender.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque')
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0797_delete_estoque_lote()
#-------------------------------------#
   
   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN    
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND num_lote      = p_estoque_lote_ender.num_lote
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   ELSE 
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND num_lote      IS NULL 
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   END IF 
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote_ender')
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0797_insere_estoque_trans()
#--------------------------------------#

   INITIALIZE p_estoque_trans.* TO NULL
   
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.num_docum          = '1'   
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = p_tela.dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_tela.dat_movto
   LET p_estoque_trans.cod_operacao       = p_cod_oper_baixa
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.qtd_movto          = p_estoque_lote_ender.qtd_saldo
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.cod_local_est_orig = p_estoque_lote_ender.cod_local
   LET p_estoque_trans.cod_local_est_dest = NULL
   LET p_estoque_trans.num_lote_orig      = p_estoque_lote_ender.num_lote
   LET p_estoque_trans.num_lote_dest      = NULL
   LET p_estoque_trans.ies_sit_est_orig   = p_estoque_lote_ender.ies_situa_qtd
   LET p_estoque_trans.ies_sit_est_dest   = NULL
   LET p_estoque_trans.cod_turno          = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.num_prog           = "POL0797"

   INSERT INTO estoque_trans
      VALUES(p_estoque_trans.*)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_trans')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------------#
 FUNCTION pol0797_insere_estoque_trans_end()
#------------------------------------------#

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
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   

#------------------------------------------#
FUNCTION pol0797_insere_estoque_auditoria()
#------------------------------------------#
  
  LET p_current = CURRENT  
  
  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac_orig, p_user, p_current,'POL0797')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#-----------------------#
 FUNCTION pol0797_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

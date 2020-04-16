#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DO LAUDO DE ANALISE                             #
# PROGRAMA: POL0324                                                 #
# MODULOS.: POL0324 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: PROGRAMAS PARA DESBLOQUEAR LAUDOS                       #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 11/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_transport    LIKE clientes.nom_cliente,
          p_status           SMALLINT,
          p_comprime         CHAR(01),
          p_houve_erro       SMALLINT,
          comando            CHAR(80),
          p_nom_arquivo      CHAR(100),
          p_nom_help         CHAR(200),
          p_nom_tela         CHAR(200),
      #   p_versao           CHAR(17),
          p_versao           CHAR(18),
          g_ies_ambiente     CHAR(01),
          p_caminho          CHAR(080),
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          i                  SMALLINT,
          p_i                SMALLINT,
          p_msg              CHAR(500),
          p_hoje             DATE,
          p_trans_nota_fiscal  INTEGER

END GLOBALS
             
   DEFINE mr_laudo_mest_petrom  RECORD LIKE laudo_mest_petrom.*,
          mr_laudo_mest_petromr RECORD LIKE laudo_mest_petrom.*,
          mr_txt_desbl_petrom   RECORD LIKE txt_desbl_petrom.*
 
   DEFINE ma_tela   ARRAY[50]  OF RECORD
      den_analise              LIKE it_analise_petrom.den_analise,
      especificacao_de         LIKE laudo_item_petrom.especificacao_de,
      especificacao_ate        LIKE laudo_item_petrom.especificacao_ate,
      tipo_valor               LIKE laudo_item_petrom.tipo_valor,
      resultado                LIKE laudo_item_petrom.resultado  
   END RECORD 

   DEFINE m_ies_cons           SMALLINT

DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT 
   LET p_versao = "POL0324-10.02.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0324.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL0324'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user

   IF p_status = 0  THEN
      CALL pol0324_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0324_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0324") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0324 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET m_ies_cons = FALSE

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0324","CO") THEN
            IF pol0324_consulta() THEN
               IF m_ies_cons THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0324_paginacao("SEGUINTE")

      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0324_paginacao("ANTERIOR")       

      COMMAND "Excluir" "Exclui o Laudo."
         HELP 003
         MESSAGE ""
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0324","EX") THEN
               CALL pol0324_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF
   
      COMMAND "Modificar" "Modifica os dados do Laudo."
         HELP 003
         MESSAGE ""
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0324","MO") THEN
               IF mr_laudo_mest_petrom.nota_emitida = 'S' THEN
                  ERROR 'Laudo já foi impresso, não pode ser modificado.'
               ELSE
                  CALL pol0324_modificacao()
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
   
      COMMAND KEY ("D") "Desbloqueia Laudo" "Processa o desbloqueio do laudo."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0324","IN") THEN
               CALL pol0324_controle_desbloqueio()           
            END IF
         ELSE
            ERROR "Consulte Previamente para efetuar o desbloqueio."
            NEXT OPTION "Consultar"
         END IF
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0324_sobre()
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0

      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0324

END FUNCTION

#--------------------------------------#
 FUNCTION pol0324_controle_desbloqueio()
#--------------------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03241") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol03241 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE mr_txt_desbl_petrom.* TO NULL
   CALL pol0324_busca_texto()

   MENU "OPCAO"
      COMMAND "Desbloqueia Laudo" "Processa o desbloqueio do laudo."
         HELP 002
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0324","MO") THEN
            IF mr_laudo_mest_petrom.laudo_bloqueado = 'S' THEN
               IF pol0324_insere_txt_desbloq() THEN
                  IF log004_confirm(21,45) THEN
                     IF pol0324_processa_desbloqueio() THEN
                        ERROR "Desbloqueio efetuado com sucesso." 
                     END IF  
                  ELSE
                     ERROR "Desbloqueio Cancelado." 
                  END IF 
               ELSE
                  ERROR "Desbloqueio Cancelado." 
               END IF 
            ELSE
               MESSAGE 'Laudo não está bloqueado.' ATTRIBUTE(REVERSE)
            END IF
         END IF

      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU

   CURRENT WINDOW IS w_pol0324
   CLOSE WINDOW w_pol03241

END FUNCTION

#------------------------------------#
 FUNCTION pol0324_insere_txt_desbloq()
#------------------------------------#

   CURRENT WINDOW IS w_pol03241
   LET INT_FLAG =  FALSE

   INPUT BY NAME mr_txt_desbl_petrom.*  WITHOUT DEFAULTS

      BEFORE FIELD num_laudo
         NEXT FIELD texto
      
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION  

#-----------------------------#
 FUNCTION pol0324_busca_texto()
#-----------------------------#

   LET mr_txt_desbl_petrom.cod_empresa = p_cod_empresa
   LET mr_txt_desbl_petrom.num_laudo   = mr_laudo_mest_petrom.num_laudo

   SELECT texto 
     INTO mr_txt_desbl_petrom.texto
     FROM txt_desbl_petrom
    WHERE cod_empresa = p_cod_empresa
      AND num_laudo   = mr_txt_desbl_petrom.num_laudo
      
   DISPLAY BY NAME mr_txt_desbl_petrom.cod_empresa 
   DISPLAY BY NAME mr_txt_desbl_petrom.num_laudo 
   DISPLAY BY NAME mr_txt_desbl_petrom.texto

END FUNCTION

#--------------------------------------#
 FUNCTION pol0324_processa_desbloqueio()
#--------------------------------------#
   IF mr_laudo_mest_petrom.laudo_bloqueado = 'S' THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      
      LET p_hoje = TODAY
      
        UPDATE laudo_mest_petrom
           SET laudo_bloqueado = 'N',
               usuario_desbl   = p_user,
               dat_desbloq     = p_hoje 
         WHERE cod_empresa = p_cod_empresa
           AND num_laudo   = mr_laudo_mest_petrom.num_laudo
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("ATUALIZACAO","LAUDO_MEST_PETROM")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

        DELETE FROM txt_desbl_petrom
         WHERE cod_empresa = p_cod_empresa
           AND num_laudo   = mr_laudo_mest_petrom.num_laudo
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DELETE","TXT_DESBL_PETROM")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

        INSERT INTO txt_desbl_petrom VALUES (mr_txt_desbl_petrom.*) 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","TXT_DESBL_PETROM")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
   ELSE
      ERROR 'Laudo não está bloqueado.'
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
#  COMMIT WORK
   RETURN TRUE
 
END FUNCTION

#--------------------------#
 FUNCTION pol0324_consulta()
#--------------------------#

   DEFINE sql_stmt,
          where_clause CHAR(300)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON laudo_mest_petrom.num_laudo,
                                     laudo_mest_petrom.num_om,
                                     laudo_mest_petrom.num_nff,
                                     laudo_mest_petrom.qtd_laudo,
                                     laudo_mest_petrom.dat_emissao,
                                     laudo_mest_petrom.cod_item_petrom,
                                     laudo_mest_petrom.cod_cliente,
                                     laudo_mest_petrom.lote_tanque,
                                     laudo_mest_petrom.nota_emitida,
                                     laudo_mest_petrom.laudo_bloqueado,
                                     laudo_mest_petrom.tipo,
                                     laudo_mest_petrom.usuario_desbl,
                                     laudo_mest_petrom.dat_desbloq,
                                     laudo_mest_petrom.texto_1,
                                     laudo_mest_petrom.texto_2,
                                     laudo_mest_petrom.texto_3    

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0324                    

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Consulta Cancelada."
      RETURN FALSE
   END IF

   SELECT * FROM laudo_usu_petrom
   WHERE cod_empresa = p_cod_empresa
     AND cod_usuario = p_user
   IF SQLCA.SQLCODE = 0 THEN
      LET sql_stmt = "SELECT * FROM laudo_mest_petrom ",
                     " WHERE cod_empresa = '",p_cod_empresa,"'",
                     " AND tipo = '2' ",
                     " AND ",where_clause CLIPPED,
                     " ORDER BY num_laudo "
   ELSE
      LET sql_stmt = "SELECT * FROM laudo_mest_petrom ",
                     " WHERE cod_empresa = '",p_cod_empresa,"'",
                     " AND ",where_clause CLIPPED,
                     " ORDER BY num_laudo "
   END IF

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   
   OPEN cq_padrao
   IF STATUS <> 0 THEN
      LET p_msg = "Não foi possivel efetuar a leitura dos dados,\n",
                  "para os parâmetros informados. Verifique se você\n",
                  "informou a data com as barras, ou seja, no\n",
                  "formato dd/mm/aaaa. Ex: 25/10/2013" 
   
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   FETCH cq_padrao INTO mr_laudo_mest_petrom.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET m_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET m_ies_cons = TRUE
      CALL pol0324_carrega_array()
      MESSAGE "Consulta Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      RETURN TRUE 
   END IF

END FUNCTION
               
#-------------------------------#
 FUNCTION pol0324_carrega_array()
#-------------------------------#

   DEFINE l_ind          SMALLINT,
          l_tip_analise  LIKE it_analise_petrom.tip_analise

   LET l_ind = 1
   INITIALIZE ma_tela TO NULL
   
   DECLARE cq_array CURSOR FOR
    SELECT tip_analise, 
           especificacao_de, 
           especificacao_ate, 
           tipo_valor,
           resultado
      FROM laudo_item_petrom
     WHERE cod_empresa = p_cod_empresa
       AND num_laudo   = mr_laudo_mest_petrom.num_laudo

   FOREACH cq_array INTO l_tip_analise,
                         ma_tela[l_ind].especificacao_de,  
                         ma_tela[l_ind].especificacao_ate,  
                         ma_tela[l_ind].tipo_valor,  
                         ma_tela[l_ind].resultado  

      SELECT den_analise
        INTO ma_tela[l_ind].den_analise
        FROM it_analise_petrom
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = l_tip_analise

      LET l_ind = l_ind + 1

   END FOREACH

   CALL pol0324_exibe_dados() 

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF

   CALL SET_COUNT(l_ind)
   IF l_ind > 6 THEN
      DISPLAY ARRAY ma_tela TO s_laudo.*
   ELSE
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_laudo.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF  

END FUNCTION

#-----------------------------------#
 FUNCTION pol0324_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao          CHAR(20)

   IF m_ies_cons THEN
      LET mr_laudo_mest_petromr.* = mr_laudo_mest_petrom.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO
                            mr_laudo_mest_petrom.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO
                            mr_laudo_mest_petrom.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_laudo_mest_petrom.* = mr_laudo_mest_petromr.*
            EXIT WHILE
         END IF                                            

         SELECT *
           INTO mr_laudo_mest_petrom.*
           FROM laudo_mest_petrom
          WHERE cod_empresa = mr_laudo_mest_petrom.cod_empresa
            AND num_laudo   = mr_laudo_mest_petrom.num_laudo
         
         IF SQLCA.SQLCODE = 0 THEN
            CALL pol0324_exibe_dados() 
            CALL pol0324_carrega_array()
            EXIT WHILE
         END IF
      END WHILE        
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION    

#-----------------------------#
 FUNCTION pol0324_exibe_dados()
#-----------------------------#

   DEFINE l_tipo         CHAR(10),
          l_ies_situacao CHAR(1)

   IF mr_laudo_mest_petrom.tipo = '1' THEN
      LET l_tipo = 'PETROM'
   ELSE
      LET l_tipo = 'EXXONMOBIL'
   END IF

   DISPLAY BY NAME mr_laudo_mest_petrom.cod_empresa
   DISPLAY BY NAME mr_laudo_mest_petrom.num_laudo
   DISPLAY BY NAME mr_laudo_mest_petrom.num_om
   DISPLAY BY NAME mr_laudo_mest_petrom.num_nff
   DISPLAY BY NAME mr_laudo_mest_petrom.ser_nff
   DISPLAY BY NAME mr_laudo_mest_petrom.cod_item_petrom
   DISPLAY BY NAME mr_laudo_mest_petrom.dat_emissao
   DISPLAY BY NAME mr_laudo_mest_petrom.cod_cliente
   DISPLAY BY NAME mr_laudo_mest_petrom.lote_tanque
   DISPLAY BY NAME mr_laudo_mest_petrom.qtd_laudo
   DISPLAY BY NAME mr_laudo_mest_petrom.tipo
   DISPLAY BY NAME mr_laudo_mest_petrom.nota_emitida
   DISPLAY BY NAME mr_laudo_mest_petrom.laudo_bloqueado
   DISPLAY BY NAME mr_laudo_mest_petrom.texto_1
   DISPLAY BY NAME mr_laudo_mest_petrom.texto_2
   DISPLAY BY NAME mr_laudo_mest_petrom.texto_3
   DISPLAY BY NAME mr_laudo_mest_petrom.usuario_desbl
   DISPLAY BY NAME mr_laudo_mest_petrom.dat_desbloq
   DISPLAY BY NAME mr_laudo_mest_petrom.cod_transport
   DISPLAY l_tipo TO den_tipo
   CALL pol0324_busca_den_item()
   CALL pol0324_busca_nom_cliente()
   CALL pol0324_verifica_transport() RETURNING p_status

   IF mr_laudo_mest_petrom.tipo = '1' THEN

      IF mr_laudo_mest_petrom.num_nff IS NULL THEN
         SELECT num_nff
            INTO 
               mr_laudo_mest_petrom.num_nff
         FROM ordem_montag_mest
         WHERE cod_empresa = mr_laudo_mest_petrom.cod_empresa
           AND num_om = mr_laudo_mest_petrom.num_om
         IF mr_laudo_mest_petrom.num_nff IS NOT NULL THEN
            SELECT sit_nota_fiscal
              INTO l_ies_situacao
              FROM fat_nf_mestre
             WHERE empresa     = mr_laudo_mest_petrom.cod_empresa
               AND nota_fiscal = mr_laudo_mest_petrom.num_nff
            IF l_ies_situacao = "C" THEN
               LET mr_laudo_mest_petrom.num_nff = NULL
            END IF
            DISPLAY BY NAME mr_laudo_mest_petrom.num_nff
         END IF
      END IF

      IF p_status = FALSE THEN
         SELECT transportadora
           INTO mr_laudo_mest_petrom.cod_transport
           FROM fat_nf_mestre
          WHERE empresa     = mr_laudo_mest_petrom.cod_empresa
            AND nota_fiscal = mr_laudo_mest_petrom.num_nff
         IF mr_laudo_mest_petrom.cod_transport IS NOT NULL AND
            mr_laudo_mest_petrom.cod_transport <> " " THEN
            SELECT nom_cliente
               INTO p_nom_transport
            FROM clientes
            WHERE cod_cliente = mr_laudo_mest_petrom.cod_transport
            DISPLAY BY NAME mr_laudo_mest_petrom.cod_transport
            DISPLAY p_nom_transport TO den_transport
         END IF
      END IF

      IF mr_laudo_mest_petrom.qtd_laudo = 0 THEN
         SELECT trans_nota_fiscal
           INTO p_trans_nota_fiscal
           FROM fat_nf_mestre
          WHERE empresa     = mr_laudo_mest_petrom.cod_empresa
            AND nota_fiscal = mr_laudo_mest_petrom.num_nff
         
         IF STATUS <> 0 THEN
            LET mr_laudo_mest_petrom.qtd_laudo = 0
         ELSE         
            SELECT qtd_item
              INTO mr_laudo_mest_petrom.qtd_laudo
              FROM fat_nf_item
             WHERE empresa     = mr_laudo_mest_petrom.cod_empresa
               AND trans_nota_fiscal = p_trans_nota_fiscal
               AND item        = mr_laudo_mest_petrom.cod_item
            IF mr_laudo_mest_petrom.qtd_laudo IS NULL THEN
               LET mr_laudo_mest_petrom.qtd_laudo = 0  
            END IF
         END IF
         
         DISPLAY BY NAME mr_laudo_mest_petrom.qtd_laudo
      END IF

   END IF

END FUNCTION       

#--------------------------------#
 FUNCTION pol0324_busca_den_item() 
#--------------------------------#

   DEFINE l_den_item LIKE item.den_item

   SELECT den_item_petrom
      INTO l_den_item
   FROM item_petrom
   WHERE cod_empresa = p_cod_empresa
     AND cod_item_petrom = mr_laudo_mest_petrom.cod_item_petrom

   DISPLAY l_den_item TO den_item        

END FUNCTION

#-----------------------------------#
 FUNCTION pol0324_busca_nom_cliente()
#-----------------------------------#

   DEFINE l_nom_cliente          LIKE clientes.nom_cliente 

 IF mr_laudo_mest_petrom.ies_es = 'S' THEN
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes 
    WHERE cod_cliente = mr_laudo_mest_petrom.cod_cliente
 ELSE
   SELECT raz_social
     INTO l_nom_cliente
     FROM fornecedor 
    WHERE cod_fornecedor = mr_laudo_mest_petrom.cod_cliente
 END IF
 
   DISPLAY l_nom_cliente TO nom_cliente

END FUNCTION      

#-----------------------------------#
 FUNCTION pol0324_cursor_for_update()
#-----------------------------------#
    DECLARE cm_laudo CURSOR FOR
     SELECT *
       INTO mr_laudo_mest_petrom.*
       FROM laudo_mest_petrom
      WHERE cod_empresa = mr_laudo_mest_petrom.cod_empresa
        AND num_laudo   = mr_laudo_mest_petrom.num_laudo

   FOR UPDATE
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_laudo
   FETCH cm_laudo
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","LAUDO_MEST_PETROM")
   END CASE                       

   RETURN FALSE

END FUNCTION

#--------------------------#
 FUNCTION pol0324_exclusao()
#--------------------------#

   IF mr_laudo_mest_petrom.nota_emitida = 'S' THEN
      LET  p_msg = 'Laudo já foi impresso. Excluir assim mesmo ?.'
      IF log0040_confirm(20,25, p_msg) THEN
	    ELSE
	       ERROR 'Operação cancelada.'
	       RETURN FALSE
	    END IF
   ELSE
      IF NOT log004_confirm(21,45) THEN
	       ERROR 'Operação cancelada.'
	       RETURN FALSE
	    END IF
   END IF

   IF pol0324_cursor_for_update() THEN
         DELETE FROM laudo_mest_petrom
         WHERE CURRENT OF cm_laudo 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","LAUDO_MEST_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN
         END IF

         DELETE FROM pa_laudo_petrom
         WHERE cod_empresa = p_cod_empresa
           AND num_laudo = mr_laudo_mest_petrom.num_laudo
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","PA_LAUDO_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN
         END IF

         DELETE FROM laudo_item_petrom
         WHERE cod_empresa = p_cod_empresa
           AND num_laudo = mr_laudo_mest_petrom.num_laudo   
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            LET parametro.texto = 'EXCLUSAO DO LAUDONUMERO ', mr_laudo_mest_petrom.num_laudo USING '<<<<<<'
            CALL func002_grava_auadit(parametro) RETURNING p_status
            MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE mr_laudo_mest_petrom.* TO NULL
            CLEAR FORM
         ELSE
            CALL log003_err_sql("EXCLUSAO","LAUDO_ITEM_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      
      CLOSE cm_laudo
   
   END IF

END FUNCTION    

#-----------------------------#
 FUNCTION pol0324_modificacao()
#-----------------------------#
   IF pol0324_cursor_for_update() THEN
      LET mr_laudo_mest_petromr.* = mr_laudo_mest_petrom.*
      IF pol0324_entrada_dados() THEN
         UPDATE laudo_mest_petrom
            SET num_nff         = mr_laudo_mest_petrom.num_nff,
                qtd_laudo       = mr_laudo_mest_petrom.qtd_laudo,
                cod_transport   = mr_laudo_mest_petrom.cod_transport,
                texto_1         = mr_laudo_mest_petrom.texto_1,
                texto_2         = mr_laudo_mest_petrom.texto_2,
                texto_3         = mr_laudo_mest_petrom.texto_3
         WHERE CURRENT OF cm_laudo

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log003_err_sql("MODIFICACAO","LAUDO_MEST_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_laudo_mest_petrom.* = mr_laudo_mest_petromr.*
         ERROR "Modificação Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         CALL pol0324_exibe_dados()
      END IF
      CLOSE cm_laudo
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0324_entrada_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0324
   
   INPUT BY NAME mr_laudo_mest_petrom.num_nff, 
                 mr_laudo_mest_petrom.qtd_laudo,
                 mr_laudo_mest_petrom.cod_transport,
                 mr_laudo_mest_petrom.texto_1,
                 mr_laudo_mest_petrom.texto_2,
                 mr_laudo_mest_petrom.texto_3 WITHOUT DEFAULTS  

      AFTER FIELD cod_transport
         IF mr_laudo_mest_petrom.cod_transport IS NOT NULL AND
            mr_laudo_mest_petrom.cod_transport <> ' ' THEN
            IF pol0324_verifica_transport() = FALSE THEN
               ERROR 'Transportadora não cadastrada.'
               NEXT FIELD cod_transport
            END IF 
         END IF  

      ON KEY(control-z)
         CALL pol0324_popup()
 
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0324
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET m_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0324_verifica_transport()
#------------------------------------#

   DEFINE l_den_transport LIKE clientes.nom_cliente
   
   SELECT nom_cliente
      INTO l_den_transport
   FROM clientes
   WHERE cod_cliente = mr_laudo_mest_petrom.cod_transport
   IF SQLCA.SQLCODE = 0 THEN
      DISPLAY l_den_transport TO den_transport
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION 

#-----------------------#
 FUNCTION pol0324_popup()
#-----------------------#

   CASE 
      WHEN INFIELD(cod_transport)  
         LET mr_laudo_mest_petrom.cod_transport = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0324
         DISPLAY BY NAME mr_laudo_mest_petrom.cod_transport
   END CASE
   
END FUNCTION    

#-----------------------#
 FUNCTION pol0324_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
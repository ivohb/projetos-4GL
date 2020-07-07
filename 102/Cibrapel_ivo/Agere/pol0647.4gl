#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO TRIM X LOGIX
# PROGRAMA: pol0647                                                 #
# OBJETIVO: ACESSO AOS APONTAMENTOS/COSUMOS CRITICADOS              #
# AUTOR...: IVO HB                                                  #
# DATA....: 03/10/2007                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item           LIKE item.cod_item,
          p_cod_itema          LIKE item.cod_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_den_item           LIKE item.den_item,
          p_den_empresa        LIKE empresa.cod_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_num_op             LIKE ordens.num_ordem,
          p_num_opa            LIKE ordens.num_ordem,
          p_num_seq_apont      LIKE apont_erro_885.numsequencia,
          p_den_critica        LIKE apont_erro_885.mensagem,
          p_den_familia        LIKE familia.den_familia,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_cod_tip_cli        LIKE clientes.cod_tip_cli
          
   DEFINE p_retorno            SMALLINT,
          p_salto              SMALLINT,
          p_imprimiu           SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                INTEGER,
          p_dat_consumo        DATE,
          p_status             SMALLINT,
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
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_opcao              CHAR(01),
          p_msg                CHAR(100),
          p_listar             SMALLINT,
          p_qtd_reg            INTEGER,
          p_numsequencia_ant   INTEGER,
          p_numsequencia       INTEGER

   DEFINE p_apont             RECORD LIKE apont_trim_885.*,
          p_aponta            RECORD LIKE apont_trim_885.*,
          p_consu             RECORD LIKE consu_mat_885.*,
          p_consua            RECORD LIKE consu_mat_885.*
          
   DEFINE p_papel             RECORD 
          numsequencia        INTEGER,
          datconsumo          DATETIME YEAR TO DAY,
          datregistro         DATETIME YEAR TO SECOND,
          mensagem            CHAR(70),
          coditem             CHAR(15),
          denitem             CHAR(70),
          numlote             CHAR(15),
          qtdconsumo          DECIMAL(10,3),
          iesrefugo           CHAR(01)
   END RECORD

   DEFINE p_papel_ant         RECORD 
          numsequencia        INTEGER,
          datconsumo          DATETIME YEAR TO DAY,
          datregistro         DATETIME YEAR TO SECOND,
          mensagem            CHAR(70),
          coditem             CHAR(15),
          denitem             CHAR(70),
          numlote             CHAR(15),
          qtdconsumo          DECIMAL(10,3),
          iesrefugo           CHAR(01)
   END RECORD

   DEFINE p_criticas          ARRAY[2000] OF RECORD
          num_ordem           LIKE ordens.num_ordem,
          cod_maquina         LIKE apont_trim_885.codmaquina,
          qtd_prod            DECIMAL(8,0),
          den_critica         LIKE apont_erro_885.mensagem
   END RECORD

   DEFINE p_erros             ARRAY[2000] OF RECORD
          dat_consumo         LIKE cons_erro_885.datconsumo,
          den_critica         LIKE cons_erro_885.mensagem
   END RECORD

   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0647-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0647.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      IF pol0647_le_empresa() THEN
         CALL pol0647_controle()
      END IF
   END IF
END MAIN

#----------------------------#
FUNCTION pol0647_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","EMPRESA")       
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0647_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0647") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0647 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Apontamento" "Inconsistências na integração de apontamento"
         HELP 001
         MESSAGE ""
         CALL pol0647_apontamneto()
      COMMAND "Consumo" "Inconsistências na integração de consumido"
         HELP 001
         MESSAGE ""
         CALL pol0647_consumo()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0647_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0647

END FUNCTION

#-----------------------------#
FUNCTION pol0647_apontamneto()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06471") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06471 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Inconsistências" "Exibe as inconsistências"
         CALL pol0647_apon_erros() RETURNING p_listar
         IF p_listar THEN
            ERROR 'Operacão efetuada com sucesso!!!'
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operacão cancelada!!!'
         END IF
      COMMAND "Listar" "Lista as inconsistências"
         IF p_listar THEN
            CALL pol0647_apont_lista()
         ELSE
            ERROR 'Execute a opção Exibir previamente!!!'
            NEXT OPTION 'Exibir'
         END IF
      COMMAND "Consultar" "Consulta dados do apontamento"
         CALL pol0647_apon_consulta()
      {COMMAND "Modificar" "Modifica dados da tela"
         IF p_ies_cons THEN
            CALL pol0647_apon_modifica() RETURNING p_status
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui apontamento da tela"
         IF p_ies_cons THEN
            CALL pol0647_apon_exclui() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF}
      COMMAND "Seguinte" "Exibe o proximo apontamento da consulta"
         CALL pol0647_apon_pagina("S")
      COMMAND "Anterior" "Exibe apontamento Anterior"
         CALL pol0647_apon_pagina("A")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 006
         MESSAGE ""
         EXIT MENU

   END MENU
   CLOSE WINDOW w_pol06471

END FUNCTION

#----------------------------#
FUNCTION pol0647_apon_erros()
#----------------------------#

   LET p_num_opa = p_num_op
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06472") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06472 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_num_op TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_num_op WITHOUT DEFAULTS FROM numordem

      AFTER FIELD numordem
         IF NOT pol647_le_ops_criticadas_trim() THEN
            IF p_num_op IS NOT NULL THEN
               LET p_msg = 'Ordem de produção sem inconsistências!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               NEXT FIELD numordem
            ELSE
               LET p_msg = 'Não há inconsistências ne apontamento!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               RETURN FALSE
            END IF
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   CALL pol0647_exibe_criticas()

   CLOSE WINDOW w_pol06472
   
   RETURN  TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol647_le_ops_criticadas_trim()
#--------------------------------------#

   LET p_index = 1
   LET p_count = 0
   INITIALIZE p_criticas TO NULL
   
   IF p_num_op IS NOT NULL THEN

      DECLARE cq_critica_trim1 CURSOR FOR
       SELECT DISTINCT
              a.numsequencia,
              a.numordem,
              b.codmaquina,
              b.qtdprod,
              a.mensagem
         FROM apont_erro_885 a,
              apont_trim_885 b
        WHERE a.codempresa   = p_cod_empresa
          AND a.numordem     = p_num_op
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
          AND b.statusregistro = '2'
       UNION SELECT numsequencia,0,'',0, mensagem
                 FROM apont_erro_885
                WHERE numsequencia = 0
        ORDER BY 2
               
      FOREACH cq_critica_trim1 INTO 
              p_num_seq_apont,
              p_criticas[p_index].num_ordem,
              p_criticas[p_index].cod_maquina,
              p_criticas[p_index].qtd_prod,
              p_criticas[p_index].den_critica

         LET p_index = p_index + 1
         LET p_count = p_count + 1

         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF

      END FOREACH
      
   ELSE

      DECLARE cq_critica_trim2 CURSOR FOR
       SELECT DISTINCT
              a.numsequencia,
              a.numordem,
              b.codmaquina,
              b.qtdprod,
              a.mensagem
         FROM apont_erro_885 a,
              apont_trim_885 b
        WHERE a.codempresa   = p_cod_empresa
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
          AND b.statusregistro = '2'
       UNION SELECT numsequencia,0,'',0, mensagem
                 FROM apont_erro_885
                WHERE numsequencia = 0
        ORDER BY 2
               
      FOREACH cq_critica_trim2 INTO 
              p_num_seq_apont,
              p_criticas[p_index].num_ordem,
              p_criticas[p_index].cod_maquina,
              p_criticas[p_index].qtd_prod,
              p_criticas[p_index].den_critica

         LET p_index = p_index + 1
         LET p_count = p_count + 1
         
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
         
      END FOREACH
      
   END IF

   IF p_count = 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0647_exibe_criticas()
#-------------------------------#

   LET p_qtd_reg = p_index - 1
   
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_criticas TO s_criticas.*

END FUNCTION

#------------------------------------#
FUNCTION pol0647_apont_escolhe_saida()
#------------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0647.tmp"
         START REPORT pol0647_apon_lista TO p_caminho
      ELSE
         START REPORT pol0647_apon_lista TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol0647_apont_lista()
#----------------------------#

   IF NOT pol0647_apont_escolhe_saida() THEN
      RETURN
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 

   DISPLAY "Aguarde!... Imprimindo..." AT 19,10

   LET p_imprimiu = FALSE

   FOR p_index = 1 TO p_qtd_reg

       DISPLAY p_criticas[p_index].num_ordem AT 19,36
       OUTPUT TO REPORT pol0647_apon_lista()
       LET p_imprimiu = TRUE
         
   END FOR
   
   FINISH REPORT pol0647_apon_lista

   CALL pol0647_finaliza()

END FUNCTION

#--------------------------#
FUNCTION pol0647_finaliza()
#--------------------------#

   MESSAGE ""
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
   END IF

END FUNCTION

#---------------------------#
 REPORT pol0647_apon_lista()
#---------------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_6lpp, p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL0647",
               COLUMN 022, "INCONSISTENCIAS NO APONTAMENTO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  NUM ORDEM  MAQ  QTD PROD             DESCRICAO DO PROBLEMA'
         PRINT COLUMN 001, '  ---------- ---- -------- --------------------------------------------------'
      
      ON EVERY ROW

         PRINT COLUMN 003, p_criticas[p_index].num_ordem USING '##########',
               COLUMN 014, p_criticas[p_index].cod_maquina[1,4],
               COLUMN 019, p_criticas[p_index].qtd_prod USING '+<<<<<<<',
               COLUMN 028, p_criticas[p_index].den_critica

      ON LAST ROW

         WHILE LINENO < 63
            PRINT
         END WHILE
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
END REPORT

#-------------------------------#
FUNCTION pol0647_apon_consulta()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_aponta.* = p_apont.*
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
      apont_trim_885.numordem,
      apont_trim_885.numpedido,
      apont_trim_885.coditem

   IF INT_FLAG THEN
      LET p_apont.* = p_aponta.*
      CALL pol0647_exibe_dados_apont()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

  LET sql_stmt = "SELECT numsequencia FROM apont_trim_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  "   AND statusregistro = '2' ",
                  " ORDER BY numordem "
                  
   PREPARE cursor_apont FROM sql_stmt   
   DECLARE cq_apont SCROLL CURSOR WITH HOLD FOR cursor_apont

   OPEN cq_apont

   FETCH cq_apont INTO p_num_seq_apont

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF NOT pol0647_le_apont() THEN
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = TRUE
         CALL pol0647_exibe_dados_apont()
      END IF
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0647_exibe_dados_apont()
#----------------------------------#

   IF NOT pol0647_le_item(p_apont.coditem) THEN
      RETURN
   END IF

   CLEAR FORM
   DISPLAY p_apont.codempresa  TO cod_empresa
   DISPLAY p_apont.numordem    TO numordem
   DISPLAY p_apont.numpedido   TO numpedido
   DISPLAY p_apont.coditem     TO coditem
   DISPLAY p_apont.num_lote    TO num_lote
   DISPLAY p_apont.codmaquina  TO codmaquina
   DISPLAY p_apont.tipmovto    TO tipmovto
   DISPLAY p_apont.qtdprod     TO qtdprod
   DISPLAY p_apont.largura     TO largura
   DISPLAY p_apont.tubete      TO tubete
   DISPLAY p_apont.diametro    TO diametro
   DISPLAY p_apont.comprimento TO comprimento
   DISPLAY p_apont.codturno    TO codturno
   DISPLAY p_apont.inicio      TO inicio
   DISPLAY p_apont.fim         TO fim
   DISPLAY p_apont.pesoteorico TO pesoteorico
   DISPLAY p_apont.consumorefugo TO consumorefugo
   DISPLAY p_apont.iesdevolucao TO iesdevolucao
   DISPLAY p_apont.numsequencia TO numsequencia
   
   CALL pol0647_le_erro_apont_885()

END FUNCTION

#----------------------------------#
FUNCTION pol0647_le_item(p_cod_item)
#-----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   SELECT den_item,
          den_item_reduz
     INTO p_den_item,
          p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      LET p_den_item = 'ITEM NAO CADASTRADO!!!'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ITEM")       
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#-------------------------#
FUNCTION pol0647_le_apont()
#-------------------------#

   LET p_houve_erro = FALSE
   
   SELECT *
     INTO p_apont.*
     FROM apont_trim_885
    WHERE codempresa     = p_cod_empresa
      AND numsequencia   = p_num_seq_apont
      AND statusregistro = '2'

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
      ELSE
         LET p_houve_erro = TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#----------------------------------#
FUNCTION pol0647_le_erro_apont_885()
#----------------------------------#

   LET p_count = 0
   
   DECLARE cq_885 CURSOR FOR
    SELECT mensagem
      FROM apont_erro_885
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","APONT_ERRO_885")       
       RETURN
    END IF

   FOREACH cq_885 INTO p_den_critica

      IF p_count < 6 THEN      
         CALL pol0647_exibe_mensagens()
      ELSE
         EXIT FOREACH
      END IF
      
   END FOREACH
   
END FUNCTION

#---------------------------------#
FUNCTION pol0647_exibe_mensagens()
#---------------------------------#

   LET p_count = p_count + 1
      
   IF p_count = 1 THEN
      DISPLAY p_den_critica TO critica_1
   ELSE
      IF p_count = 2 THEN
         DISPLAY p_den_critica TO critica_2
      ELSE
         IF p_count = 3 THEN
            DISPLAY p_den_critica TO critica_3
         ELSE
            IF p_count = 4 THEN
               DISPLAY p_den_critica TO critica_4
            ELSE
               DISPLAY p_den_critica TO critica_5
            END IF
         END IF
      END IF
   END IF
   
END FUNCTION

#---------------------------------#
FUNCTION pol0647_apon_pagina(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)

   IF p_ies_cons THEN
      LET p_aponta.* = p_apont.*
      WHILE TRUE
         CASE
            WHEN p_op = "S" FETCH NEXT     cq_apont INTO p_num_seq_apont
            WHEN p_op = "A" FETCH PREVIOUS cq_apont INTO p_num_seq_apont
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_apont.* = p_aponta.*
            EXIT WHILE
         END IF

         IF pol0647_le_apont() THEN  
            CALL pol0647_exibe_dados_apont()
            EXIT WHILE
         ELSE
            IF p_houve_erro THEN
               EXIT WHILE
            END IF
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#--------------------------------#
 FUNCTION pol0647_apon_bloqueia()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_interf CURSOR FOR
    SELECT * 
      INTO p_apont.*                                              
      FROM apont_trim_885  
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont
       FOR UPDATE

    OPEN cm_interf
   FETCH cm_interf
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","APONT_TRIM_885:BLOQUEANDO REG")
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol0647_apon_modifica()
#-------------------------------#

   LET p_retorno = FALSE

   IF pol0647_apon_bloqueia() THEN

      LET p_aponta.* = p_apont.*
      LET INT_FLAG = FALSE
      IF pol0647_apon_edita("M") THEN
         LET p_apont.tiporegistro = 'A'
         LET p_apont.statusregistro = '0'
         LET p_apont.usuario = p_user

         UPDATE apont_trim_885 
            SET apont_trim_885.* = p_apont.*
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","APONT_TRIM_885:UPDATE")
         END IF
      ELSE
         LET p_apont.* = p_aponta.*
         CALL pol0647_exibe_dados_apont()
      END IF
      
      CLOSE cm_interf
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#------------------------------------#
FUNCTION pol0647_apon_edita(p_funcao)
#------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET p_opcao = '1'
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol06471

   INPUT p_apont.numordem,
         p_apont.numpedido,
         p_apont.coditem,
         p_apont.num_lote,
         p_apont.codmaquina,
         p_apont.tipmovto,
         p_apont.qtdprod,
         p_apont.largura,
         p_apont.tubete,
         p_apont.diametro,
         p_apont.comprimento,
         p_apont.codturno,
         p_apont.inicio,
         p_apont.fim,
         p_apont.pesoteorico,
         p_apont.consumorefugo,
         p_apont.iesdevolucao,
         p_apont.numsequencia
        
         WITHOUT DEFAULTS
         
         FROM 
         numordem,
         numpedido,
         coditem,
         num_lote,
         codmaquina,
         tipmovto,
         qtdprod,
         largura,
         tubete,
         diametro,
         comprimento,
         codturno,
         inicio,
         fim,
         pesoteorico,
         consumorefugo,
         iesdevolucao,
         numsequencia
        
      AFTER FIELD numpedido
         SELECT cod_empresa
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_apont.numpedido
         
         IF STATUS = 100 THEN
            ERROR 'Pedido inexistente !!!'
            NEXT FIELD numpedido
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LENDO","PEDIDOS")
               RETURN FALSE
            END IF
         END IF

      AFTER FIELD coditem
        
         IF NOT pol0647_le_item(p_apont.coditem) THEN 
            RETURN FALSE
         END IF
         
         IF STATUS = 100 THEN
            ERROR 'Item inexistente !!!'
            NEXT FIELD coditem
         END IF         

         DISPLAY p_den_item TO den_item
         
      AFTER FIELD codmaquina
         IF p_apont.codmaquina IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD codmaquina
         END IF         

      AFTER FIELD codturno
         SELECT cod_turno
           FROM turno
          WHERE cod_empresa = p_cod_empresa
            AND cod_turno   = p_apont.codturno
            
      AFTER FIELD tipmovto
         IF p_apont.tipmovto MATCHES '[FRSP]' THEN
         ELSE
            ERROR 'Valor Ilegal p/ o campo!!!'
            NEXT FIELD tipmovto
         END IF

      AFTER FIELD qtdprod
         IF p_apont.qtdprod IS NULL THEN
            ERROR 'Valor Ilegal p/ o campo!!!'
            NEXT FIELD qtdprod
         END IF
         

      AFTER FIELD inicio
         IF p_apont.inicio IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD inicio
         END IF
       
      AFTER FIELD fim
         IF p_apont.fim IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD fim
         END IF

      AFTER FIELD num_lote
         IF p_apont.num_lote IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD num_lote
         END IF

      AFTER FIELD largura
         IF p_apont.largura IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD largura
         END IF

      AFTER FIELD tubete
         IF p_apont.tubete IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD tubete
         END IF

      AFTER FIELD diametro
         IF p_apont.diametro IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD diametro
         END IF

      AFTER FIELD comprimento
         IF p_apont.comprimento IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD comprimento
         END IF

      ON KEY (control-z)
         CALL pol0647_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol06471

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0647_apon_exclui()
#----------------------------#

   LET p_retorno = FALSE
   
   IF pol0647_apon_bloqueia() THEN
      
      IF log004_confirm(18,35) THEN

         UPDATE apont_trim_885 
            SET tiporegistro   = 'E',
                statusregistro = '9',
                usuario        = p_user
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont
          
         IF STATUS = 0 THEN
            DELETE FROM apont_erro_885
             WHERE codempresa   = p_cod_empresa
               AND numsequencia = p_num_seq_apont
            IF STATUS = 0 THEN
               INITIALIZE p_apont TO NULL
               CLEAR FORM
               DISPLAY p_cod_empresa TO cod_empresa
               LET p_retorno = TRUE
            ELSE
               CALL log003_err_sql("EXCLUSAO","APONT_ERRO_885:EXCLUINDO")
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","APONT_TRIM_885:EXCLUINDO")
         END IF
      END IF
      
      CLOSE cm_interf
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#-----------------------#
FUNCTION pol0647_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(coditem)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)

      IF p_opcao = '1' THEN
         CURRENT WINDOW IS w_pol06471
         LET p_apont.coditem = p_codigo
      ELSE
         CURRENT WINDOW IS w_pol064710
         LET p_papel.coditem = p_codigo
      END IF
      
      DISPLAY p_codigo TO coditem

      WHEN INFIELD(codturno)
         CALL log009_popup(8,25,"TURNOS","turno",
                     "cod_turno","den_turno","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol06471
         IF p_codigo IS NOT NULL THEN
            LET p_apont.codturno = p_codigo CLIPPED
            DISPLAY p_codigo TO codturno
         END IF

   END CASE
   
END FUNCTION

#-------------------------#
FUNCTION pol0647_consumo()
#-------------------------#

   LET p_listar = FALSE
   LET p_ies_cons = FALSE

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06473") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06473 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "inconsistências" "Exibe as mensagens de erro"
         CALL pol0647_consu_erros() RETURNING p_listar
         IF p_listar THEN
            ERROR 'Operacão efetuada com sucesso!!!'
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operacão cancelada!!!'
         END IF
      COMMAND "Detalhes" "Exibe os dados do consumo criticado"
         CALL pol0647_consu_dados()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 006
         MESSAGE ""
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol064710

END FUNCTION


#----------------------------#
FUNCTION pol0647_consu_erros()
#----------------------------#

   INITIALIZE p_dat_consumo TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_dat_consumo WITHOUT DEFAULTS FROM dat_consumo

      AFTER FIELD dat_consumo
         IF NOT pol647_le_cosu_criticados() THEN
            IF p_dat_consumo IS NOT NULL THEN
               LET p_msg = 'data de consumo sem inconsistências!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               NEXT FIELD dat_consumo
            ELSE
               LET p_msg = 'Não há inconsistências no consumo!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               RETURN FALSE
            END IF
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   CALL pol0647_exibe_erros()

   CLOSE WINDOW w_pol06473
   
   RETURN  TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol647_le_cosu_criticados()
#-----------------------------------#

   LET p_index = 1
   LET p_count = 0
   INITIALIZE p_erros TO NULL
   
   IF p_dat_consumo IS NOT NULL THEN

      DECLARE cq_erros1 CURSOR FOR
       SELECT DISTINCT
              datconsumo,
              mensagem
         FROM cons_erro_885
        WHERE codempresa = p_cod_empresa
          AND datconsumo = p_dat_consumo
        UNION SELECT datconsumo, 
                      mensagem
                 FROM cons_erro_885 
                WHERE codempresa   = p_cod_empresa
                  AND numsequencia = 0
         ORDER BY 1,2
               
      FOREACH cq_erros1 INTO 
              p_erros[p_index].dat_consumo,
              p_erros[p_index].den_critica

         LET p_index = p_index + 1
         LET p_count = p_count + 1

         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF

      END FOREACH
      
   ELSE

      DECLARE cq_erros2 CURSOR FOR
       SELECT DISTINCT
              datconsumo,
              mensagem
         FROM cons_erro_885
        WHERE codempresa  = p_cod_empresa
        UNION SELECT datconsumo, 
                      mensagem
                 FROM cons_erro_885 
                WHERE codempresa   = p_cod_empresa
                  AND numsequencia = 0
         ORDER BY 1,2
               
      FOREACH cq_erros2 INTO 
              p_erros[p_index].dat_consumo,
              p_erros[p_index].den_critica

         LET p_index = p_index + 1
         LET p_count = p_count + 1
         
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
         
      END FOREACH
      
   END IF

   IF p_count = 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0647_exibe_erros()
#-----------------------------#

   LET p_qtd_reg = p_index - 1
   
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_erros TO s_erros.*

END FUNCTION

#-----------------------------#
FUNCTION pol0647_consu_dados()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06474") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06474 AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   DISPLAY p_cod_empresa TO cod_empresa   


   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados do consumo criticado"
         CALL pol0647_consulta_dados()
      COMMAND "Seguinte" "Exibe o proximo apontamento da consulta"
         CALL pol0647_consu_pagina("S")
      COMMAND "Anterior" "Exibe apontamento Anterior"
         CALL pol0647_consu_pagina("A")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 006
         MESSAGE ""
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol06474

END FUNCTION


#-------------------------------#
FUNCTION pol0647_consulta_dados()
#-------------------------------#

   CLEAR FORM
   LET p_papel_ant.* = p_papel.*
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
      cons_erro_885.datconsumo,
      cons_erro_885.mensagem

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_papel.* = p_papel_ant.*
         CALL pol0647_consu_exibe_dados()
      END IF
      ERROR "Consulta Cancelada"
      RETURN
   END IF

  LET sql_stmt = "SELECT DISTINCT numsequencia, datconsumo, mensagem ", 
                 "  FROM cons_erro_885 ",
                 " WHERE ", where_clause CLIPPED,
                 "   AND codempresa = '",p_cod_empresa,"' ",
                 " ORDER BY datconsumo, mensagem "
                  
   PREPARE consu_apont FROM sql_stmt   
   DECLARE cq_consu SCROLL CURSOR WITH HOLD FOR consu_apont

   OPEN cq_consu

   FETCH cq_consu INTO 
         p_papel.numsequencia,
         p_papel.datconsumo,
         p_papel.mensagem

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF NOT pol0647_le_dados_consumo() THEN
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = TRUE
         CALL pol0647_consu_exibe_dados()
      END IF
   END IF

END FUNCTION


#---------------------------------#
FUNCTION pol0647_le_dados_consumo()
#---------------------------------#

   LET p_houve_erro = FALSE
   
   DECLARE cq_pri CURSOR FOR
   SELECT datregistro,
          coditem,
          numlote,
          qtdconsumo,
          iesrefugo
     FROM cons_papel_885
    WHERE codempresa     = p_cod_empresa
      AND numsequencia   = p_papel.numsequencia

   FOREACH cq_pri 
        INTO p_papel.datregistro,
          p_papel.coditem,
          p_papel.numlote,
          p_papel.qtdconsumo,
          p_papel.iesrefugo


      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Dados do consumo')
         RETURN FALSE
      END IF
   
      EXIT FOREACH
      
   END FOREACH

   IF p_papel.iesrefugo = 'N' THEN
      LET p_papel.iesrefugo = 'B'
   ELSE
      LET p_papel.iesrefugo = 'R'
   END IF
   
   IF NOT pol0647_le_item(p_papel.coditem) THEN
      RETURN FALSE
   END IF
   
   LET p_papel.denitem = p_den_item

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0647_consu_exibe_dados()
#----------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa   TO cod_empresa
   DISPLAY BY NAME p_papel.*

END FUNCTION

#---------------------------------#
FUNCTION pol0647_consu_pagina(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)

   IF p_ies_cons THEN
      LET p_papel_ant.* = p_papel.*
      WHILE TRUE
         CASE
            WHEN p_op = "S" FETCH NEXT cq_consu INTO 
                 p_papel.numsequencia,
                 p_papel.datconsumo,
                 p_papel.mensagem
            WHEN p_op = "A" FETCH PREVIOUS cq_consu INTO 
                 p_papel.numsequencia,
                 p_papel.datconsumo,
                 p_papel.mensagem
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_papel.* = p_papel_ant.*
            EXIT WHILE
         END IF

         IF pol0647_le_dados_consumo() THEN  
            CALL pol0647_consu_exibe_dados()
         ELSE
            LET p_papel.* = p_papel_ant.*
         END IF

         EXIT WHILE
         
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0647_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

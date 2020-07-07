#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO TRIM PAPEL X LOGIX
# OBJETIVO: ACESSO AOS APONTAMENTOS/COSUMOS CRITICADOS              #
# DATA....: 07/09/2008                                              #
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
          p_msg                CHAR(70),
          p_listar             SMALLINT,
          p_qtd_reg            INTEGER

   DEFINE p_apont             RECORD LIKE apont_papel_885.*,
          p_aponta            RECORD LIKE apont_papel_885.*,
          p_papel             RECORD LIKE cons_insumo_885.*,
          p_papela            RECORD LIKE cons_insumo_885.*

   DEFINE p_criticas          ARRAY[2000] OF RECORD
          num_ordem           LIKE ordens.num_ordem,
          cod_maquina         LIKE apont_papel_885.codmaquina,
          qtd_prod            DECIMAL(8,0),
          den_critica         LIKE apont_erro_885.mensagem
   END RECORD

   DEFINE p_erros             ARRAY[2000] OF RECORD
          num_ordem           LIKE ordens.num_ordem,
          cod_item            LIKE item.cod_item,
          den_critica         LIKE cons_erro_885.mensagem
   END RECORD

   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0830-05.00.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0830.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      IF pol0830_le_empresa() THEN
         CALL pol0830_controle()
      END IF
   END IF
END MAIN

#----------------------------#
FUNCTION pol0830_le_empresa()
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
 FUNCTION pol0830_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0830") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0830 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Apontamento" "Inconsistências na integração de apontamento"
         HELP 001
         MESSAGE ""
         CALL pol0830_apontamneto()
      {COMMAND "Consumo" "Inconsistências na integração de consumido"
         HELP 001
         MESSAGE ""
         CALL pol0830_consumo()}
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
   CLOSE WINDOW w_pol0830

END FUNCTION

#-----------------------------#
FUNCTION pol0830_apontamneto()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08302") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08302 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Inconsistências" "Exibe as inconsistências"
         CALL pol0830_apon_erros() RETURNING p_listar
         IF p_listar THEN
            ERROR 'Operacão efetuada com sucesso!!!'
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operacão cancelada!!!'
         END IF
      COMMAND "Listar" "Lista as inconsistências"
         IF p_listar THEN
            CALL pol0830_apont_lista()
         ELSE
            ERROR 'Execute a opção Exibir previamente!!!'
            NEXT OPTION 'Exibir'
         END IF
      COMMAND "Consultar" "Consulta dados do apontamento"
         CALL pol0830_apon_consulta()
      COMMAND "Modificar" "Modifica dados da tela"
         IF p_ies_cons THEN
            CALL pol0830_apon_modifica() RETURNING p_status
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
            CALL pol0830_apon_exclui() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o proximo apontamento da consulta"
         CALL pol0830_apon_pagina("S")
      COMMAND "Anterior" "Exibe apontamento Anterior"
         CALL pol0830_apon_pagina("A")
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
   CLOSE WINDOW w_pol08302

END FUNCTION

#----------------------------#
FUNCTION pol0830_apon_erros()
#----------------------------#

   LET p_num_opa = p_num_op
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08301") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08301 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_num_op TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_num_op WITHOUT DEFAULTS FROM numordem

      AFTER FIELD numordem
         IF NOT pol0830_le_ops_criticadas_trim() THEN
            IF p_num_op IS NOT NULL THEN
               LET p_msg = 'Ordem de produção sem inconsistências!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               NEXT FIELD numordem
            ELSE
               LET p_msg = 'Não há inconsistências ne apontamento!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               EXIT INPUT
            END IF
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   CALL pol0830_exibe_criticas()

   CLOSE WINDOW w_pol08301
   
   RETURN  TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0830_le_ops_criticadas_trim()
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
              b.pesobalanca,
              a.mensagem
         FROM apont_erro_885 a,
              apont_papel_885 b
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
              b.pesobalanca,
              a.mensagem
         FROM apont_erro_885 a,
              apont_papel_885 b
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
FUNCTION pol0830_exibe_criticas()
#-------------------------------#

   LET p_qtd_reg = p_index - 1
   
   IF p_qtd_reg > 0 THEN
      CALL SET_COUNT(p_index - 1)
      DISPLAY ARRAY p_criticas TO s_criticas.*
   END IF
   
END FUNCTION

#------------------------------------#
FUNCTION pol0830_apont_escolhe_saida()
#------------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0830.tmp"
         START REPORT pol0830_apon_lista TO p_caminho
      ELSE
         START REPORT pol0830_apon_lista TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol0830_apont_lista()
#----------------------------#

   IF NOT pol0830_apont_escolhe_saida() THEN
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
       OUTPUT TO REPORT pol0830_apon_lista()
       LET p_imprimiu = TRUE
         
   END FOR
   
   FINISH REPORT pol0830_apon_lista

   CALL pol0830_finaliza()

END FUNCTION

#--------------------------#
FUNCTION pol0830_finaliza()
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
 REPORT pol0830_apon_lista()
#---------------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_6lpp, p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0830",
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
FUNCTION pol0830_apon_consulta()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_aponta.* = p_apont.*
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
      apont_papel_885.numordem,
      apont_papel_885.coditem,
      apont_papel_885.numlote,
      apont_papel_885.codmaquina

   IF INT_FLAG THEN
      LET p_apont.* = p_aponta.*
      CALL pol0830_exibe_dados_apont()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

  LET sql_stmt = "SELECT numsequencia FROM apont_papel_885 ",
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
      IF NOT pol0830_le_apont() THEN
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = TRUE
         CALL pol0830_exibe_dados_apont()
      END IF
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0830_exibe_dados_apont()
#----------------------------------#

   IF NOT pol0830_le_item(p_apont.coditem) THEN
      RETURN
   END IF

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   DISPLAY p_apont.codempresa  TO cod_empresa
   DISPLAY p_apont.numordem    TO numordem
   DISPLAY p_apont.numsequencia TO numsequencia
   DISPLAY p_apont.coditem     TO coditem
   DISPLAY p_apont.numlote     TO numlote
   DISPLAY p_apont.codmaquina  TO codmaquina
   DISPLAY p_apont.tipmovto    TO tipmovto
   DISPLAY p_apont.pesobalanca TO pesobalanca
   DISPLAY p_apont.largura     TO largura
   DISPLAY p_apont.tubete      TO tubete
   DISPLAY p_apont.diametro    TO diametro
   DISPLAY p_apont.comprimento TO comprimento
   DISPLAY p_apont.codturma    TO codturma
   DISPLAY p_apont.datproducao TO datproducao
   DISPLAY p_apont.tempoproducao TO tempoproducao
   
   CALL pol0830_le_erro_apont_885()

END FUNCTION

#----------------------------------#
FUNCTION pol0830_le_item(p_cod_item)
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
FUNCTION pol0830_le_apont()
#-------------------------#

   LET p_houve_erro = FALSE
   
   SELECT *
     INTO p_apont.*
     FROM apont_papel_885
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
FUNCTION pol0830_le_erro_apont_885()
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
         CALL pol0830_exibe_mensagens()
      ELSE
         EXIT FOREACH
      END IF
      
   END FOREACH
   
END FUNCTION

#---------------------------------#
FUNCTION pol0830_exibe_mensagens()
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
FUNCTION pol0830_apon_pagina(p_op)
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

         IF pol0830_le_apont() THEN  
            CALL pol0830_exibe_dados_apont()
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
 FUNCTION pol0830_apon_bloqueia()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_interf CURSOR FOR
    SELECT * 
      INTO p_apont.*                                              
      FROM apont_papel_885  
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont
       FOR UPDATE

    OPEN cm_interf
   FETCH cm_interf
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","apont_papel_885:BLOQUEANDO REG")
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol0830_apon_modifica()
#-------------------------------#

   LET p_retorno = FALSE

   IF pol0830_apon_bloqueia() THEN

      LET p_aponta.* = p_apont.*
      LET INT_FLAG = FALSE
      IF pol0830_apon_edita("M") THEN
         LET p_apont.statusregistro = '0'
         LET p_apont.usuario = p_user

         UPDATE apont_papel_885 
            SET apont_papel_885.* = p_apont.*
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","apont_papel_885:UPDATE")
         END IF
      ELSE
         LET p_apont.* = p_aponta.*
         CALL pol0830_exibe_dados_apont()
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
FUNCTION pol0830_apon_edita(p_funcao)
#------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET p_opcao = '1'
   
   INPUT p_apont.numordem,
         p_apont.numsequencia,
         p_apont.coditem,
         p_apont.numlote,
         p_apont.codmaquina,
         p_apont.tipmovto,
         p_apont.pesobalanca,
         p_apont.largura,
         p_apont.tubete,
         p_apont.diametro,
         p_apont.comprimento,
         p_apont.codturma,
         p_apont.datproducao,
         p_apont.tempoproducao
        
         WITHOUT DEFAULTS
         
         FROM 
         numordem,
         numsequencia,
         coditem,
         numlote,
         codmaquina,
         tipmovto,
         pesobalanca,
         largura,
         tubete,
         diametro,
         comprimento,
         codturma,
         datproducao,
         tempoproducao
        
      AFTER FIELD coditem
        
         IF NOT pol0830_le_item(p_apont.coditem) THEN 
            RETURN FALSE
         END IF
         
         IF STATUS = 100 THEN
            ERROR 'Item inexistente !!!'
            NEXT FIELD coditem
         END IF         

         DISPLAY p_den_item TO den_item

      AFTER FIELD numlote
         IF p_apont.numlote IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD numlote
         END IF
         
      AFTER FIELD codmaquina
         IF p_apont.codmaquina IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD codmaquina
         END IF         

      AFTER FIELD tipmovto
         IF p_apont.tipmovto MATCHES '[FRSE]' THEN
         ELSE
            ERROR 'Valor Ilegal p/ o campo!!!'
            NEXT FIELD tipmovto
         END IF

      AFTER FIELD pesobalanca
         IF p_apont.pesobalanca IS NULL THEN
            ERROR 'Valor Ilegal p/ o campo!!!'
            NEXT FIELD pesobalanca
         END IF
         
      AFTER FIELD datproducao
         IF p_apont.datproducao IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD datproducao
         END IF
       
      AFTER FIELD tempoproducao
         IF p_apont.tempoproducao IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD tempoproducao
         END IF

      ON KEY (control-z)
         CALL pol0830_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0830_apon_exclui()
#----------------------------#

   LET p_retorno = FALSE
   
   IF pol0830_apon_bloqueia() THEN
      
      IF log004_confirm(18,35) THEN

         UPDATE apont_papel_885 
            SET statusregistro = '9',
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
            CALL log003_err_sql("EXCLUSAO","apont_papel_885:EXCLUINDO")
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
FUNCTION pol0830_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(coditem)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)

      IF p_opcao = '1' THEN
         CURRENT WINDOW IS w_pol08302
         LET p_apont.coditem = p_codigo
      ELSE
         CURRENT WINDOW IS w_pol08303
         LET p_papel.coditem = p_codigo
      END IF
      
      DISPLAY p_codigo TO coditem

      WHEN INFIELD(codturma)
         CALL log009_popup(8,25,"TURNOS","turno",
                     "cod_turno","den_turno","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08302
         IF p_codigo IS NOT NULL THEN
            LET p_apont.codturma = p_codigo CLIPPED
            DISPLAY p_codigo TO codturma
         END IF

   END CASE
   
END FUNCTION

#-------------------------#
FUNCTION pol0830_consumo()
#-------------------------#

   LET p_listar = FALSE
   LET p_ies_cons = FALSE

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08303") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08303 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Inconsistências" "Exibe as inconsistências"
         CALL pol0830_consu_erros() RETURNING p_listar
         IF p_listar THEN
            ERROR 'Operacão efetuada com sucesso!!!'
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operacão cancelada!!!'
         END IF
      COMMAND "Listar" "Lista as inconsistências"
         IF p_listar THEN
            CALL pol0830_consumo_lista()
         ELSE
            ERROR 'Execute a opção Exibir previamente!!!'
            NEXT OPTION 'Exibir'
         END IF
      COMMAND "Consultar" "Consulta dados do apontamento"
         CALL pol0830_consu_consulta()
      {COMMAND "Modificar" "Modifica dados da tela"
         IF p_ies_cons THEN
            CALL pol0830_consu_modifica() RETURNING p_status
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF}
      COMMAND "Excluir" "Exclui apontamento da tela"
         IF p_ies_cons THEN
            CALL pol0830_consu_exclui() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o proximo apontamento da consulta"
         CALL pol0830_consu_pagina("S")
      COMMAND "Anterior" "Exibe apontamento Anterior"
         CALL pol0830_consu_pagina("A")
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
 
   CLOSE WINDOW w_pol08303

END FUNCTION

#----------------------------#
FUNCTION pol0830_consu_erros()
#----------------------------#

   LET p_num_opa = p_num_op
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08304") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08304 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_num_op TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_num_op WITHOUT DEFAULTS FROM numordem

      AFTER FIELD numordem
         IF NOT pol0830_le_cosu_criticados() THEN
            IF p_num_op IS NOT NULL THEN
               LET p_msg = 'Ordem de produção sem inconsistências!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               NEXT FIELD numordem
            ELSE
               LET p_msg = 'Não há inconsistências no consumo!'
               CALL log0030_mensagem(p_msg,'exclamation') 
               EXIT INPUT
            END IF
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   CALL pol0830_exibe_erros()

   CLOSE WINDOW w_pol08303
   
   RETURN  TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0830_le_cosu_criticados()
#-----------------------------------#

   LET p_index = 1
   LET p_qtd_reg = 0
   INITIALIZE p_erros TO NULL
   
   IF p_num_op IS NOT NULL THEN

      DECLARE cq_erros1 CURSOR FOR
       SELECT DISTINCT
              a.numsequencia,
              a.numordem,
              a.coditem,
              b.mensagem
         FROM cons_insumo_885 a,
              cons_erro_885 b
        WHERE a.codempresa     = p_cod_empresa
          AND a.numordem       = p_num_op
          AND a.statusregistro = '2'
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
          
        UNION SELECT 0, 0, '', mensagem
                 FROM cons_erro_885 
                WHERE numsequencia = 0
        ORDER BY 2
               
      FOREACH cq_erros1 INTO 
              p_num_seq_apont,
              p_erros[p_index].num_ordem,
              p_erros[p_index].cod_item,
              p_erros[p_index].den_critica

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_erros1')
            RETURN FALSE
         END IF

         LET p_index = p_index + 1
         LET p_qtd_reg = p_qtd_reg + 1

         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF

      END FOREACH
      
   ELSE

      DECLARE cq_erros2 CURSOR FOR
       SELECT DISTINCT
              a.numsequencia,
              a.numordem,
              a.coditem,
              b.mensagem
         FROM cons_insumo_885 a,
              cons_erro_885 b
        WHERE a.codempresa     = p_cod_empresa
          AND a.statusregistro = '2'
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
          
        UNION SELECT 0, 0, '', mensagem
                 FROM cons_erro_885 
                WHERE numsequencia = 0
        ORDER BY 2
               
      FOREACH cq_erros2 INTO 
              p_num_seq_apont,
              p_erros[p_index].num_ordem,
              p_erros[p_index].cod_item,
              p_erros[p_index].den_critica

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_erros2')
            RETURN FALSE
         END IF

         LET p_index = p_index + 1
         LET p_qtd_reg = p_qtd_reg + 1
         
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
         
      END FOREACH
      
   END IF

   IF p_qtd_reg = 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0830_exibe_erros()
#-----------------------------#

   IF p_qtd_reg > 0 THEN
      LET p_qtd_reg = p_index - 1
      CALL SET_COUNT(p_index - 1)
      DISPLAY ARRAY p_erros TO s_erros.*
   END IF
   
END FUNCTION


#------------------------------#
FUNCTION pol0830_consumo_lista()
#------------------------------#

   IF NOT pol0830_consu_escolhe_saida() THEN
      RETURN
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 

   DISPLAY "Aguarde!... Imprimindo..." AT 20,10

   LET p_imprimiu = FALSE

   FOR p_index = 1 TO p_qtd_reg

       DISPLAY p_erros[p_index].cod_item AT 20,36
       OUTPUT TO REPORT pol0830_consu_lista()
       LET p_imprimiu = TRUE
         
   END FOR
   
   FINISH REPORT pol0830_consu_lista

   CALL pol0830_finaliza()

END FUNCTION

#---------------------------#
 REPORT pol0830_consu_lista()
#---------------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 60
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_6lpp, p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0830",
               COLUMN 022, "INCONSISTENCIAS NO CONSUMO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'NUM ORDEM  COD ITEM                  DESCRICAO DO PROBLEMA'
         PRINT COLUMN 001, '---------- --------------- --------------------------------------------------'
      
      ON EVERY ROW

         PRINT COLUMN 001, p_erros[p_index].num_ordem USING '##########',
               COLUMN 012, p_erros[p_index].cod_item,
               COLUMN 028, p_erros[p_index].den_critica

      ON LAST ROW

         WHILE LINENO < 57
            PRINT
         END WHILE
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
END REPORT

#------------------------------------#
FUNCTION pol0830_consu_escolhe_saida()
#------------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0830.tmp"
         START REPORT pol0830_consu_lista TO p_caminho
      ELSE
         START REPORT pol0830_consu_lista TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0830_consu_consulta()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_papela.* = p_papel.*
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
      cons_insumo_885.numordem,
      cons_insumo_885.coditem,
      cons_insumo_885.numlote

   IF INT_FLAG THEN
      LET p_papel.* = p_papela.*
      CALL pol0830_consu_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

  LET sql_stmt = "SELECT numsequencia FROM cons_insumo_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  "   AND statusregistro = '2' ",
                  " ORDER BY numordem "
                  
   PREPARE consu_apont FROM sql_stmt   
   DECLARE cq_consu SCROLL CURSOR WITH HOLD FOR consu_apont

   OPEN cq_consu

   FETCH cq_consu INTO p_num_seq_apont

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF NOT pol0830_le_consu() THEN
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = TRUE
         CALL pol0830_consu_exibe_dados()
      END IF
   END IF

END FUNCTION


#-------------------------#
FUNCTION pol0830_le_consu()
#-------------------------#

   LET p_houve_erro = FALSE
   
   SELECT *
     INTO p_papel.*
     FROM cons_insumo_885
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
FUNCTION pol0830_consu_exibe_dados()
#----------------------------------#

   CLEAR FORM
   DISPLAY p_papel.codempresa   TO cod_empresa
   DISPLAY p_papel.numordem     TO numordem
   DISPLAY p_papel.coditem      TO coditem
   DISPLAY p_papel.numlote      TO numlote
   DISPLAY p_papel.qtdconsumida TO qtdconsumida
   DISPLAY p_papel.codmaqpapel  TO codmaqpapel
   DISPLAY p_papel.datconsumo   TO datconsumo
   DISPLAY p_papel.iesrefugo    TO iesrefugo
   DISPLAY p_papel.numsequencia TO numsequencia
   
   CALL pol0830_le_cons_erro_885()

END FUNCTION

#----------------------------------#
FUNCTION pol0830_le_cons_erro_885()
#----------------------------------#

   LET p_count = 0
   
   DECLARE cq_erro_cons CURSOR FOR
    SELECT mensagem
      FROM cons_erro_885
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","CONS_ERRO_885")       
       RETURN
    END IF

   FOREACH cq_erro_cons INTO p_den_critica
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cons_erro_885')
         EXIT FOREACH
      END IF

      IF p_count < 6 THEN      
         CALL pol0830_exibe_mensagens()
      ELSE
         EXIT FOREACH
      END IF
      
   END FOREACH
   
END FUNCTION

#---------------------------------#
FUNCTION pol0830_consu_pagina(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)

   IF p_ies_cons THEN
      LET p_papela.* = p_papel.*
      WHILE TRUE
         CASE
            WHEN p_op = "S" FETCH NEXT     cq_consu INTO p_num_seq_apont
            WHEN p_op = "A" FETCH PREVIOUS cq_consu INTO p_num_seq_apont
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_papel.* = p_papela.*
            EXIT WHILE
         END IF

         IF pol0830_le_consu() THEN  
            CALL pol0830_consu_exibe_dados()
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
 FUNCTION pol0830_consu_bloqueia()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_bloq CURSOR FOR
    SELECT codempresa
      FROM cons_insumo_885  
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont
       FOR UPDATE

    OPEN cm_bloq
   FETCH cm_bloq
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","cons_insumo_885:BLOQUEANDO REG")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0830_consu_exclui()
#-----------------------------#

   LET p_retorno = FALSE
   
   IF pol0830_consu_bloqueia() THEN
      
      IF log004_confirm(18,35) THEN

         UPDATE cons_insumo_885 
            SET statusregistro = '9',
                usuario        = p_user
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont
          
         IF STATUS = 0 THEN
            DELETE FROM cons_erro_885
             WHERE codempresa   = p_cod_empresa
               AND numsequencia = p_num_seq_apont
            IF STATUS = 0 THEN
               INITIALIZE p_papel TO NULL
               CLEAR FORM
               DISPLAY p_cod_empresa TO cod_empresa
               LET p_retorno = TRUE
            ELSE
               CALL log003_err_sql("EXCLUSAO","CONS_ERRO_885:EXCLUINDO")
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","cons_insumo_885:EXCLUINDO")
         END IF
      END IF
      
      CLOSE cm_bloq
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#-------------------------------#
FUNCTION pol0830_consu_modifica()
#-------------------------------#

   LET p_retorno = FALSE

   IF pol0830_consu_bloqueia() THEN

      LET p_papela.* = p_papel.*
      LET INT_FLAG = FALSE
      IF pol0830_consu_edita("M") THEN
         LET p_papel.statusregistro = '0'
         LET p_papel.usuario = p_user

         UPDATE cons_insumo_885 
            SET cons_insumo_885.* = p_papel.*
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","cons_insumo_885:UPDATE")
         END IF
      ELSE
         LET p_papel.* = p_papela.*
         CALL pol0830_consu_exibe_dados()
      END IF
      
      CLOSE cm_bloq
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#------------------------------------#
FUNCTION pol0830_consu_edita(p_funcao)
#------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET p_opcao = '2'
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol08305

   INPUT p_papel.numordem,
         p_papel.coditem,
         p_papel.numlote,
         p_papel.qtdconsumida,
         p_papel.codmaqpapel,
         p_papel.datconsumo,
         p_papel.iesrefugo
        
         WITHOUT DEFAULTS
         
          FROM numordem,
			         coditem,
			         numlote,
			         qtdconsumida,
			         codmaqpapel,
			         datconsumo,
			         iesrefugo
         

      AFTER FIELD numordem
         IF p_papel.numordem IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD numordem
         END IF         

         SELECT COUNT(num_ordem)
           INTO p_count
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_papel.numordem
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ordens')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            ERROR 'Ordem inexistente !!!'
            NEXT FIELD numordem
         END IF

      AFTER FIELD coditem
        
         IF NOT pol0830_le_item(p_papel.coditem) THEN 
            RETURN FALSE
         END IF
         
         IF STATUS = 100 THEN
            ERROR 'Item inexistente !!!'
            NEXT FIELD coditem
         END IF         

      AFTER FIELD codmaqpapel
         IF p_papel.codmaqpapel IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD codmaqpapel
         END IF         

      AFTER FIELD qtdconsumida
         IF p_papel.qtdconsumida IS NULL OR p_papel.qtdconsumida = 0 THEN
            ERROR 'Valor ilegal p/ o campo!!!'
            NEXT FIELD qtdconsumida
         END IF
         
      AFTER FIELD numlote
         IF p_papel.numlote IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!!!'
            NEXT FIELD numlote
         END IF

      ON KEY (control-z)
         CALL pol0830_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol08305

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

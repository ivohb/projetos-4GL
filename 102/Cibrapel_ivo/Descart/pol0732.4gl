#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO TRIM X LOGIX                                 #
# PROGRAMA: pol0732                                                 #
# OBJETIVO: ACESSO AOS ROMANEIOS CRITICADOS                         #
# AUTOR...: IVO HB                                                  #
# DATA....: 03/10/2007                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_om             LIKE romaneio_885.numromaneio,
          p_num_oma            LIKE romaneio_885.numromaneio,
          p_num_versao         INTEGER,
          p_seq_item           LIKE roma_item_885.numsequencia,
          p_seq_itema          LIKE roma_item_885.numsequencia,
          p_den_item           LIKE item.den_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.cod_empresa,
          p_num_seq_apont      LIKE roma_erro_885.num_sequencia,
          p_den_critica        LIKE roma_erro_885.den_erro,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_cod_tip_cli        LIKE clientes.cod_tip_cli,
          p_den_rota           CHAR(40), #LIKE rota_885.den_rota,
          p_den_veiculo        LIKE veiculo_885.den_veiculo,
          p_den_cidade         LIKE cidades.den_cidade
          
   DEFINE p_retorno            SMALLINT,
          p_salto              SMALLINT,
          p_imprimiu           SMALLINT,
          p_msg                CHAR(100),
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
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(600),
          p_cabec              CHAR(44),
          p_cod_transp         CHAR(02),
          p_cod_transp_auto    CHAR(02)

   DEFINE p_roma              RECORD LIKE romaneio_885.*,
          p_romaa             RECORD LIKE romaneio_885.*

   DEFINE p_romaneios         ARRAY[2000] OF RECORD
          num_romaneio        LIKE romaneio_885.numromaneio,
          num_sequencia       LIKE roma_erro_885.num_sequencia,
          den_erro            LIKE roma_erro_885.den_erro
   END RECORD

   DEFINE p_roma_item         RECORD
          numromaneio         LIKE roma_item_885.numromaneio,
          tipooperacao        LIKE roma_item_885.tipooperacao,
          numpedido           LIKE roma_item_885.numpedido,
          numseqitem          LIKE roma_item_885.numseqitem,
          coditem             LIKE roma_item_885.coditem,
          qtdpecas            LIKE roma_item_885.qtdpecas,
          tolmais             LIKE roma_item_885.tolmais,
          qtdvolumes          LIKE roma_item_885.qtdvolumes,
          numlote             LIKE roma_item_885.numlote,
          largura             LIKE roma_item_885.largura,
          tubete              LIKE roma_item_885.tubete,
          diametro            LIKE roma_item_885.diametro,
          comprimento         LIKE roma_item_885.comprimento,
          pesoitem            LIKE roma_item_885.pesoitem
   END RECORD

   DEFINE p_roma_aux          RECORD
          numromaneio         LIKE roma_item_885.numromaneio,
          tipooperacao        LIKE roma_item_885.tipooperacao,
          numpedido           LIKE roma_item_885.numpedido,
          numseqitem          LIKE roma_item_885.numseqitem,
          coditem             LIKE roma_item_885.coditem,
          qtdpecas            LIKE roma_item_885.qtdpecas,
          tolmais             LIKE roma_item_885.tolmais,
          qtdvolumes          LIKE roma_item_885.qtdvolumes,
          numlote             LIKE roma_item_885.numlote,
          largura             LIKE roma_item_885.largura,
          tubete              LIKE roma_item_885.tubete,
          diametro            LIKE roma_item_885.diametro,
          comprimento         LIKE roma_item_885.comprimento,
          pesoitem            LIKE roma_item_885.pesoitem
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0732-05.00.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0732.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol0732_controle()
   END IF
END MAIN


#--------------------------#
 FUNCTION pol0732_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0732") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0732 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0732_le_parametros() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dos Romaneios Criticados"
         CALL pol0732_exibe_criticas()
      COMMAND "Listar" "Lista as Criticas da Importação de Romaneios"
         CALL pol0732_lista_criticas()
      COMMAND "Acessar" "Acesso aos Romaneio Criticado"
         CALL pol0732_acessa_romaneio()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0732_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol0732

END FUNCTION

#------------------------------#
FUNCTION pol0732_le_parametros()
#------------------------------#


   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","EMPRESA")       
      RETURN FALSE
   END IF

   SELECT substring(par_vdp_txt,215,2)
     INTO p_cod_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_cod_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

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
         LET p_cod_emp_ger = p_cod_empresa
      END IF
   END IF

   RETURN TRUE
      
END FUNCTION


#--------------------------------#
FUNCTION pol0732_exibe_criticas()
#--------------------------------#

   LET p_num_oma = p_num_om
   CLEAR FORM 
   DISPLAY p_cod_emp_ofic TO cod_empresa
   INITIALIZE p_num_om TO NULL
   
   INPUT p_num_om WITHOUT DEFAULTS FROM numromaneio

      AFTER FIELD numromaneio
         IF NOT pol647_le_romaneio_885() THEN
            ERROR 'Não há críticas para o romaneio informado !!!'
            NEXT FIELD numromaneio
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      ERROR "Consulta Cancelada"
      IF p_ies_cons THEN
         LET p_num_om = p_num_oma
         CALL pol647_le_romaneio_885() RETURNING p_status
         CALL pol0732_exibe_romaneios()
      ELSE
         LET p_ies_cons = FALSE
      END IF
      RETURN
   END IF

   IF p_count = 0 THEN
      CALL log0030_mensagem('Não há romaneios criticados.','exclamation')      
      RETURN
   END IF
   
   LET p_ies_cons = TRUE

   CALL pol0732_exibe_romaneios()

END FUNCTION

#--------------------------------#
FUNCTION pol647_le_romaneio_885()
#--------------------------------#

   LET p_index = 1
   LET p_count = 0
   INITIALIZE p_romaneios TO NULL
   
   IF p_num_om IS NOT NULL THEN

      DECLARE cq_roma_1 CURSOR FOR
       SELECT a.numromaneio,
              b.num_sequencia,
              b.den_erro
         FROM romaneio_885 a,
              roma_erro_885 b
        WHERE a.codempresa     = p_cod_empresa
          AND a.numromaneio    = p_num_om
          AND a.statusregistro = '2'
          AND b.cod_empresa    = a.codempresa
          AND b.num_sequencia  = a.numsequencia
        #UNION (SELECT '', num_sequencia, den_erro
        #         FROM roma_erro_885 
        #        WHERE num_sequencia = 0 AND cod_empresa = p_cod_empresa)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","romaneio_885:cq_roma_1")       
      END IF
      
      FOREACH cq_roma_1 INTO p_romaneios[p_index].*
         LET p_index = p_index + 1
         LET p_count = p_count + 1
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
      END FOREACH
      
      IF p_count = 0 THEN
         RETURN FALSE
      END IF
      
   ELSE

      DECLARE cq_roma_2 CURSOR FOR
       SELECT a.numromaneio,
              b.num_sequencia,
              b.den_erro
         FROM romaneio_885 a,
              roma_erro_885 b
        WHERE a.codempresa     = p_cod_empresa
          AND a.statusregistro = '2'
          AND b.cod_empresa    = a.codempresa
          AND b.num_sequencia  = a.numsequencia
        UNION SELECT '', num_sequencia, den_erro
                 FROM roma_erro_885 
                WHERE num_sequencia = 0 AND cod_empresa = p_cod_empresa
        ORDER BY 1

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","romaneio_885:cq_roma_2")       
      END IF
      
      FOREACH cq_roma_2 INTO p_romaneios[p_index].*

         LET p_index = p_index + 1
         LET p_count = p_count + 1
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
      END FOREACH
      
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0732_exibe_romaneios()
#-------------------------------#

   CALL SET_COUNT(p_index - 1)

   IF ARR_COUNT() > 11 THEN
      DISPLAY ARRAY p_romaneios TO s_romaneios.*
   ELSE
      INPUT ARRAY p_romaneios WITHOUT DEFAULTS FROM s_romaneios.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION


#--------------------------------#
FUNCTION pol0732_lista_criticas()
#--------------------------------#

   LET p_ies_cons = FALSE
   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO empresa
   LET p_cabec = 'ROMANEIOS CRITICADOS NA IMPORTACAO'
   
   CONSTRUCT BY NAME where_clause ON
       romaneio_885.numromaneio
          
   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      ERROR "Listagem Cancelada"
      DISPLAY '' TO numromaneio
      RETURN
   END IF

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0732.tmp"
         START REPORT pol0732_roma_lista TO p_caminho
      ELSE
         START REPORT pol0732_roma_lista TO p_nom_arquivo
      END IF
   END IF

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   LET p_imprimiu = FALSE

   LET sql_stmt = "SELECT numsequencia  FROM romaneio_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  "   AND statusregistro = '2' ",
                  " ORDER BY numromaneio "

   PREPARE romaneio FROM sql_stmt   
   DECLARE cq_roma CURSOR FOR romaneio

   FOREACH cq_roma INTO p_num_seq_apont
   
      DECLARE cq_erro_roma CURSOR FOR
       SELECT a.numromaneio,
              b.den_erro
         FROM romaneio_885 a,
              roma_erro_885 b
        WHERE a.codempresa    = p_cod_empresa
          AND a.numsequencia  = p_num_seq_apont
          AND b.cod_empresa   = a.codempresa
          AND b.num_sequencia = a.numsequencia
      
      FOREACH cq_erro_roma INTO p_num_om, p_den_critica

         DISPLAY p_num_seq_apont AT 20,35
         OUTPUT TO REPORT pol0732_roma_lista()
         LET p_imprimiu = TRUE
         
      END FOREACH
   
   END FOREACH
   
   FINISH REPORT pol0732_roma_lista

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         ERROR "Relatório impresso na impressora ", p_nom_arquivo
      ELSE
         ERROR "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF

END FUNCTION

#--------------------------#
 REPORT pol0732_roma_lista()
#--------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 041, "INTEGRACAO LOGIX X TRIM",
               COLUMN 072, "PAG: ", PAGENO USING "&&&&"
               
         PRINT COLUMN 001, "pol0732",
               COLUMN 020, p_cabec,
               COLUMN 064, TODAY USING "dd/mm/yy", " ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "  ROMANEIO       SEQUENCIA                  DESCRICAO DA CRITICA"
         PRINT COLUMN 001, "--------------- ------------ ---------------------------------------------------"
      
      ON EVERY ROW

         PRINT COLUMN 001, p_num_om,
               COLUMN 017, p_num_seq_apont USING '###########&', 
               COLUMN 030, p_den_critica[1,51]

      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
END REPORT


#---------------------------------#
FUNCTION pol0732_acessa_romaneio()
#---------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07321") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 

   OPEN WINDOW w_pol07321 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF STATUS <> 0  THEN
      LET p_msg = 'Caminho não cadastrado p/ empresa: ',p_cod_empresa
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN
   END IF
      
   DISPLAY p_cod_emp_ofic TO cod_empresa
   
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol0732_romaneio_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
{      COMMAND "Modificar" "Modifica Dados da Tabela"
         IF p_ies_cons THEN
            IF pol0732_romaneio_modifica() THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF}
      COMMAND "Excluir" "Exclui Dados da Tabela"
         IF p_ies_cons THEN
            IF pol0732_romaneio_exclui() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item da Consulta"
         CALL pol0732_romaneio_pagina("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior da Consulta"
         CALL pol0732_romaneio_pagina("ANTERIOR")
      COMMAND "Itens" "Acesso aos Itens do Pedido"
         IF p_ies_cons THEN
            CALL pol0732_acessa_itens()
         ELSE
            ERROR "Consulte previamente para acessar os itens"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol07321

END FUNCTION


#-----------------------------------#
FUNCTION pol0732_romaneio_consulta()
#-----------------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa
   LET p_romaa.* = p_roma.*
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
         romaneio_885.numromaneio,
         romaneio_885.tipooperacao,
         romaneio_885.coderptranspor,
         romaneio_885.placaveiculo,
         romaneio_885.codveiculo,
         romaneio_885.codtipcarga,
         romaneio_885.codpercurso,
         romaneio_885.codtipfrete,
         romaneio_885.valfrete,
         romaneio_885.codciddest,
         romaneio_885.pesobalanca,
         romaneio_885.pesocarregado

      ON KEY (control-z)
         CALL pol0732_popup()

   END CONSTRUCT

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_roma.* = p_romaa.*
      CALL pol0732_exibe_dados_romaneio()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

  LET sql_stmt = "SELECT numsequencia FROM romaneio_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  "   AND statusregistro = '2' ",
                  " ORDER BY numromaneio "
                  
   PREPARE var_roma FROM sql_stmt   
   DECLARE cq_roma_885 SCROLL CURSOR WITH HOLD FOR var_roma

   OPEN cq_roma_885

   FETCH cq_roma_885 INTO p_num_seq_apont

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
   ELSE 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Lendo','cq_roma_885')
      ELSE
         IF NOT pol0732_le_romaneio_885() THEN
         ELSE
            LET p_ies_cons = TRUE
            CALL pol0732_exibe_dados_romaneio()
         END IF
      END IF
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION pol0732_exibe_dados_romaneio()
#-------------------------------------#

   CLEAR FORM

   DISPLAY BY NAME p_roma.*
    
   DISPLAY p_roma.codempresa     TO cod_empresa
   DISPLAY p_roma.numromaneio    TO numromaneio
   DISPLAY p_num_seq_apont       TO numsequencia
   DISPLAY p_roma.tipooperacao   TO tipooperacao
   DISPLAY p_roma.coderptranspor TO coderptranspor
   DISPLAY p_roma.placaveiculo   TO placaveiculo
   DISPLAY p_roma.codveiculo     TO codveiculo
   DISPLAY p_roma.codtipcarga    TO codtipcarga
   DISPLAY p_roma.codpercurso    TO codpercurso
   DISPLAY p_roma.codtipfrete    TO codtipfrete
   DISPLAY p_roma.valfrete       TO valfrete
   DISPLAY p_roma.codciddest     TO codciddest
   DISPLAY p_roma.pesobalanca    TO pesobalanca
   DISPLAY p_roma.pesocarregado  TO pesocarregado

   CALL pol0732_le_roma_erro_885()

END FUNCTION



#---------------------------------#
FUNCTION pol0732_le_romaneio_885()
#---------------------------------#

   LET p_houve_erro = FALSE
   
   SELECT *
     INTO p_roma.*
     FROM romaneio_885
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
FUNCTION pol0732_le_roma_erro_885()
#----------------------------------#

   LET p_count = 0
   
   DECLARE cq_roma_erro CURSOR FOR
    SELECT den_erro
      FROM roma_erro_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_sequencia = p_num_seq_apont

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","ROMA_ERRO_885")       
       RETURN
    END IF

   FOREACH cq_roma_erro INTO p_den_critica
      
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
                  IF p_count = 5 THEN
                     DISPLAY p_den_critica TO critica_5
                  ELSE
                     EXIT FOREACH
                  END IF
               END IF
            END IF
         END IF
      END IF
      
   END FOREACH
   
END FUNCTION


#-------------------------------------#
FUNCTION pol0732_romaneio_pagina(p_op)
#-------------------------------------#

   DEFINE p_op CHAR(08)

   IF p_ies_cons THEN
      LET p_romaa.* = p_roma.*
      WHILE TRUE
         CASE
            WHEN p_op = "SEGUINTE" FETCH NEXT     cq_roma_885 INTO p_num_seq_apont
            WHEN p_op = "ANTERIOR" FETCH PREVIOUS cq_roma_885 INTO p_num_seq_apont
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_roma.* = p_romaa.*
            EXIT WHILE
         END IF

         IF pol0732_le_romaneio_885() THEN  
            CALL pol0732_exibe_dados_romaneio()
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


#------------------------------------#
 FUNCTION pol0732_romaneio_bloq_reg()
#------------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_roma CURSOR WITH HOLD FOR
    SELECT * 
      INTO p_roma.*                                              
      FROM romaneio_885  
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_num_seq_apont

    OPEN cm_roma
   FETCH cm_roma
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","ROMANEIO_885:BLOQUEANDO REG")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0732_romaneio_modifica()
#-----------------------------------#

   LET p_retorno = FALSE

   IF pol0732_romaneio_bloq_reg() THEN

      LET p_romaa.* = p_roma.*
      LET INT_FLAG = FALSE
      IF pol0732_romaneio_edita() THEN
         LET p_roma.statusproces = '2'
         LET p_roma.statusregistro = '0'

         UPDATE romaneio_885 
            SET romaneio_885.* = p_roma.*
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","ROMANEIO_885:UPDATE")
         END IF
      ELSE
         LET p_roma.* = p_romaa.*
         CALL pol0732_exibe_dados_romaneio()
      END IF
      
      CLOSE cm_roma
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------------#
FUNCTION pol0732_romaneio_edita()
#--------------------------------#

   INPUT p_roma.numromaneio,
         p_roma.tipooperacao,
         p_roma.coderptranspor,
         p_roma.placaveiculo,
         p_roma.codveiculo,
         p_roma.codtipcarga,
         p_roma.codpercurso,
         p_roma.codtipfrete,
         p_roma.valfrete,
         p_roma.codciddest,
         p_roma.pesobalanca,
         p_roma.pesocarregado
         
         WITHOUT DEFAULTS
         
         FROM numromaneio,
              tipooperacao,
              coderptranspor,
              placaveiculo,
              codveiculo,
              codtipcarga,
              codpercurso,
              codtipfrete,
              valfrete,
              codciddest,
              pesobalanca,
              pesocarregado

      AFTER FIELD numromaneio
         IF p_roma.numromaneio IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD numromaneio
         END IF
         
      AFTER FIELD coderptranspor
         IF p_roma.coderptranspor IS NOT NULL THEN
            IF NOT pol0732_le_transp() THEN
               NEXT FIELD coderptranspor
            END IF
         END IF

      AFTER FIELD codveiculo
         IF p_roma.codveiculo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD codveiculo
         END IF

         IF NOT pol0732_le_veiculo() THEN
            NEXT FIELD codveiculo
         END IF

      AFTER FIELD codciddest
         IF p_roma.codciddest IS NOT NULL THEN
            IF NOT pol0732_le_cidade() THEN
               NEXT FIELD codciddest
            END IF
         END IF

      AFTER FIELD pesobalanca
         IF p_roma.pesobalanca <= 0 THEN
            ERROR 'Valor ilegal para o campo'
            NEXT FIELD pesobalanca
         END IF

      AFTER FIELD pesocarregado
         IF p_roma.pesocarregado <= 0 THEN
            ERROR 'Valor ilegal para o campo'
            NEXT FIELD pesocarregado
         END IF
         
      ON KEY (control-z)
         CALL pol0732_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol0732_le_transp()
#---------------------------#

   SELECT nom_reduzido
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_roma.coderptranspor
      AND (cod_tip_cli = p_cod_transp OR
           cod_tip_cli = p_cod_transp_auto)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","CLIENTES")       
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0732_le_veiculo()
#----------------------------#

   SELECT den_veiculo
     INTO p_den_veiculo
     FROM veiculo_885
    WHERE cod_veiculo = p_roma.codveiculo
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","VEICULO_885")       
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0732_le_cidade()
#---------------------------#

   SELECT den_cidade
     INTO p_den_cidade
     FROM cidades
    WHERE cod_cidade = p_roma.codciddest
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","CIDADES")       
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0732_romaneio_exclui()
#---------------------------------#

   LET p_retorno = FALSE
   
   IF pol0732_romaneio_bloq_reg() THEN
      
      IF log004_confirm(18,35) THEN

         UPDATE romaneio_885 
            SET statusregistro = 'E'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont
          
         IF STATUS = 0 THEN
 
            DELETE FROM roma_erro_885
             WHERE cod_empresa   = p_cod_empresa
               AND num_sequencia = p_num_seq_apont

            IF STATUS = 0 THEN
               INITIALIZE p_roma TO NULL
               CLEAR FORM
               DISPLAY p_cod_emp_ofic TO cod_empresa
               LET p_retorno = TRUE
            ELSE
               CALL log003_err_sql("EXCLUSAO","ROMA_ERRO_885:EXCLUINDO")
            END IF
         ELSE
            CALL log003_err_sql("EXCLUINDO","ROMANEIO_885:EXCLUINDO")
         END IF
      END IF
      
      CLOSE cm_roma
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#-----------------------#
FUNCTION pol0732_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(coditem)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)

         CURRENT WINDOW IS w_pol07322
         LET p_roma_item.coditem = p_codigo
         DISPLAY p_codigo TO s_roma_item[s_index].coditem

      WHEN INFIELD(coderptranspor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
   
         CURRENT WINDOW IS w_pol07321
         LET p_roma.coderptranspor = p_codigo
         DISPLAY p_codigo TO coderptranspor

      WHEN INFIELD(codciddest)
         CALL log009_popup(8,20,"CIDADES","cidades",
                     "cod_cidade","den_cidade","","N","") 
            RETURNING p_codigo
            
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         LET p_roma.codciddest = p_codigo CLIPPED
         DISPLAY p_codigo TO codciddest

      WHEN INFIELD(codveiculo)
         CALL log009_popup(8,20,"VEICULOS","veiculo_885",
                     "cod_veiculo","den_veiculo","","N","") 
            RETURNING p_codigo
            
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         LET p_roma.codveiculo = p_codigo CLIPPED
         DISPLAY p_codigo TO codveiculo
   
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol0732_acessa_itens()
#------------------------------#

   IF NOT pol0732_consulta_itens() THEN
      RETURN
   END IF

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07322") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07322 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_emp_ofic TO cod_empresa

   CALL pol0732_exibe_itens()
   
   MENU "OPCAO"
      COMMAND "Modificar" "Modifica Dados da Tabela"
         CALL pol0732_itens_modifica()
         ERROR p_msg
      COMMAND "Excluir" "Esclui Dados da Tabela"
         IF log004_confirm(18,35) THEN
            CALL pol0732_itens_exclui()
            ERROR p_msg
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item da Consulta"
         CALL pol0732_itens_pagina("S")
      COMMAND "Anterior" "Exibe o Item Anterior da Consulta"
         CALL pol0732_itens_pagina("A")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol07322

END FUNCTION

#-------------------------------#
FUNCTION pol0732_consulta_itens()
#-------------------------------#

   DECLARE cq_roma_item SCROLL CURSOR WITH HOLD FOR
   SELECT numsequencia
     FROM roma_item_885
    WHERE codempresa     = p_cod_empresa
      AND numseqpai      = p_roma.numsequencia
      AND statusregistro <> 'E'
   OPEN cq_roma_item

   FETCH cq_roma_item INTO p_seq_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0732_exibe_itens()
#-----------------------------#

   IF pol0732_le_roma_item() THEN
      DISPLAY BY NAME p_roma_item.*
   END IF

END FUNCTION

#------------------------------#
FUNCTION  pol0732_le_roma_item()
#------------------------------#

   SELECT numromaneio,
          tipooperacao,
          numpedido,
          numseqitem,
          coditem,
          qtdpecas,
          tolmais,
          qtdvolumes,
          numlote,
          largura,
          tubete,
          diametro,
          comprimento,
          pesoitem
     INTO p_roma_item.*
     FROM roma_item_885
    WHERE codempresa   = p_cod_empresa
      AND numsequencia = p_seq_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0732_item_bloq_reg()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_item CURSOR WITH HOLD FOR
    SELECT numsequencia
      FROM roma_item_885  
     WHERE codempresa   = p_cod_empresa
       AND numsequencia = p_seq_item

    OPEN cm_item
   FETCH cm_item
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","ROMA_ITEM_885:BLOQUEANDO REG")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol0732_itens_modifica()
#--------------------------------#

   LET p_msg = 'Operação cancelada!!!'

   CALL log085_transacao("BEGIN")

   IF pol0732_item_bloq_reg() THEN

      LET p_roma_aux.* = p_roma_item.*

      IF pol0732_edita_roma_item() THEN

         UPDATE roma_item_885
            SET tipooperacao   = p_roma_item.tipooperacao,
                numpedido      = p_roma_item.numpedido,
                numseqitem     = p_roma_item.numseqitem,
                coditem        = p_roma_item.coditem,
                qtdpecas       = p_roma_item.qtdpecas,
                tolmais        = p_roma_item.tolmais,
                qtdvolumes     = p_roma_item.qtdvolumes,
                numlote        = p_roma_item.numlote,
                largura        = p_roma_item.largura,
                tubete         = p_roma_item.tubete,
                diametro       = p_roma_item.diametro,
                comprimento    = p_roma_item.comprimento,
                pesoitem       = p_roma_item.pesoitem,
                statusproces   = '2',
                statusregistro = '0'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_seq_item

         IF STATUS = 0 THEN
            CALL log085_transacao("COMMIT")
            LET p_msg = 'Operação efetuada com sucesso!!!'
         ELSE
            CALL log003_err_sql("MODIFICACAO","ROMA_ITEM_885:UPDATE")
         END IF
      ELSE
         LET p_roma_item.* = p_roma_aux.*
         DISPLAY BY NAME p_roma_item.*
      END IF
      
      CLOSE cm_item
      
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol0732_edita_roma_item()
#---------------------------------#

   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_roma_item.* 
      WITHOUT DEFAULTS  
      
      AFTER FIELD tipooperacao
         IF p_roma_item.tipooperacao MATCHES '[01]' THEN
         ELSE
            ERROR 'Valor Ilegal p/ o campo!'
            NEXT FIELD tipooperacao
         END IF
      
      AFTER FIELD numpedido
         IF p_roma_item.numpedido IS NULL THEN
            ERROR 'Campo c/ preenchimento obrigatório!'
            NEXT FIELD numpedido
         END IF
         
         SELECT num_pedido 
           FROM pedidos
          WHERE cod_empresa    = p_cod_empresa
            AND num_pedido     = p_roma_item.numpedido
            AND ies_sit_pedido <> '9'
            
         IF STATUS = 100 THEN
            ERROR 'Pedido Inválido!'
            NEXT FIELD numpedido
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","ITEM")       
               RETURN FALSE
            END IF
         END IF
         
      AFTER FIELD numseqitem
         IF p_roma_item.numseqitem IS NULL THEN
            ERROR 'Campo c/ preenchimento obrigatório!'
            NEXT FIELD numseqitem
         END IF

      AFTER FIELD coditem
         IF p_roma_item.coditem IS NULL THEN
            ERROR 'Campo c/ preenchimento obrigatório!'
            NEXT FIELD coditem
         END IF
 
         SELECT den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_roma_item.coditem

         IF STATUS <> 0 THEN
            CALL log003_err_sql("LEITURA","ITEM")       
            NEXT FIELD coditem
         END IF
         
      AFTER FIELD qtdpecas
         IF p_roma_item.qtdpecas IS NULL OR p_roma_item.qtdpecas = 0THEN
            ERROR 'Por favor, informe a quantidade a faturar!'
            NEXT FIELD qtdpecas
         END IF
         
      ON KEY (control-z)
         CALL pol0732_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#----------------------------------#
FUNCTION pol0732_itens_pagina(p_op)
#----------------------------------#

   DEFINE p_op CHAR(01)

   IF p_ies_cons THEN
      LET p_seq_itema = p_seq_item

      WHILE TRUE

         CASE
            WHEN p_op = "S" 
                 FETCH NEXT     cq_roma_item INTO p_seq_item
            WHEN p_op = "A" 
                 FETCH PREVIOUS cq_roma_item INTO p_seq_item
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_seq_item = p_seq_itema
            EXIT WHILE
         END IF

         SELECT numsequencia
           FROM roma_item_885
          WHERE codempresa     = p_cod_empresa
            AND numsequencia   = p_seq_item
            AND statusregistro <> 'E'

         IF STATUS = 0 THEN 
             CALL pol0732_exibe_itens()
             EXIT WHILE
         END IF

      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol0732_itens_exclui()
#------------------------------#

   LET p_msg = 'Operação cancelada!!!'
   
   IF pol0732_item_bloq_reg() THEN

      UPDATE roma_item_885 
         SET statusregistro = 'E'
       WHERE codempresa   = p_cod_empresa
         AND numsequencia = p_seq_item
         
      IF STATUS = 0 THEN
         INITIALIZE p_roma_item TO NULL
         CLEAR FORM
         DISPLAY p_cod_emp_ofic TO cod_empresa
         LET p_msg = 'Operação efetuada com secesso!!!'
         CALL log085_transacao("COMMIT")
      ELSE
         CALL log003_err_sql("EXCLUINDO","ROMA_ITEM_885:EXCLUINDO")
         CALL log085_transacao("ROLLBACK")
      END IF
      
      CLOSE cm_item
      
   END IF

END FUNCTION


#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0815                                                 #
# OBJETIVO: Romaneios enviados pelo Trim                            #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 26/02/09                                                #
# CONVERS�O 10.02: 31/03/2015 - IVO                                 #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq_pai        INTEGER,
          p_num_seq_item       INTEGER,
          P_Comprime           CHAR(01),
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
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_seq_ant            INTEGER
          
          
   DEFINE p_roma_item_885    RECORD 
          numromaneio        LIKE roma_item_885.numromaneio,
          codciddest         LIKE roma_item_885.codciddest,
          numsequencia       LIKE roma_item_885.numsequencia,
          identificador      LIKE roma_item_885.identificador,
          tipooperacao       LIKE roma_item_885.tipooperacao,
          numseqpai          LIKE roma_item_885.numseqpai,
          numpedido          LIKE roma_item_885.numpedido,
          coditem            LIKE roma_item_885.coditem,
          numlote            LIKE roma_item_885.numlote,
          pesoitem           LIKE roma_item_885.pesoitem,
          pesobrutoitem      LIKE roma_item_885.pesobrutoitem,
          qtdvolumes         LIKE roma_item_885.qtdvolumes,
          qtdpecas           LIKE roma_item_885.qtdpecas,
          tolmais            LIKE roma_item_885.tolmais,
          qtdpacote          LIKE roma_item_885.qtdpacote,
          statusregistro     LIKE roma_item_885.statusregistro
   END RECORD         

   DEFINE p_numromaneio       LIKE roma_item_885.numromaneio,
          p_den_cidade        LIKE cidades.den_cidade
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0815-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0815_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0815_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0815") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0815 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consultar romaneio na tela"
         CALL pol0815_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Opera��o efetuada com sucesso!!!'
            LET p_ies_cons = TRUE 
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_ies_cons = FALSE 
            ERROR "Opera��o Cancelada!!!"
         END IF
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0815_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0815_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0815

END FUNCTION

#--------------------------#
 FUNCTION pol0815_informar()
#--------------------------#
   
   INITIALIZE p_numromaneio TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT p_numromaneio WITHOUT DEFAULTS
    FROM numromaneio
    
      AFTER FIELD numromaneio
         IF p_numromaneio IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio!!!"
            NEXT FIELD numromaneio       
         END IF 

         SELECT MAX(numsequencia)
           INTO p_num_seq_pai
           FROM romaneio_885 
          WHERE codempresa  = p_cod_empresa
            AND numromaneio = p_numromaneio
            
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("lendo", "romaneio_885")
            NEXT FIELD numromaneio 
         END IF
         
         IF p_num_seq_pai IS NULL THEN
            ERROR 'Romaneio inexistente.'
            NEXT FIELD numromaneio 
         END IF            
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0815_consulta() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0815_consulta()
#--------------------------#

   DEFINE  sql_stmt CHAR(500)

 
   LET sql_stmt = "SELECT numsequencia ",
                  "  FROM roma_item_885 ",
                  " WHERE numromaneio   = '",p_numromaneio,"' ",
                  "   AND numseqpai = '",p_num_seq_pai,"' ",
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  " order by numsequencia"
               

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_seq_item

   IF STATUS = 100 THEN
      ERROR "Argumentos de pesquisa n�o encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0815_exibe_dados() THEN
         LET p_ies_cons = TRUE
      ELSE
         LET p_ies_cons = FALSE
      END IF
   END IF
   
   RETURN p_ies_cons

END FUNCTION

#------------------------------#
 FUNCTION pol0815_exibe_dados()
#------------------------------#

  SELECT numromaneio,
         codciddest,
         numsequencia,
         identificador,
         tipooperacao,
         numseqpai,
         numpedido,
         coditem,
         numlote,
         pesoitem,
         pesobrutoitem,
         qtdvolumes,
         qtdpecas,
         tolmais,
         qtdpacote,
         statusregistro
    INTO p_roma_item_885.*
    FROM roma_item_885
   WHERE codempresa  = p_cod_empresa
     AND numromaneio = p_numromaneio
     AND numsequencia = p_num_seq_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','roma_item_885')
      RETURN FALSE 
   END IF 
    
   SELECT den_cidade
     INTO p_den_cidade
     FROM cidades
    WHERE cod_empresa = p_cod_empresa
      AND cod_cidade  = p_roma_item_885.codciddest
   
   IF STATUS <> 0 THEN
      LET p_den_cidade = NULL
   END IF

   DISPLAY BY NAME p_roma_item_885.*
   DISPLAY p_den_cidade TO den_cidade
   
   RETURN TRUE

END FUNCTION


#-----------------------------------#
 FUNCTION pol0815_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_seq_ant = p_num_seq_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_seq_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_seq_item
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o"
            LET p_num_seq_item = p_seq_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0815_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#--------------------------#
 FUNCTION pol0815_listagem()
#--------------------------#     

   IF NOT pol0815_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0815_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   
   SELECT numromaneio,
          codciddest,
          numsequencia,
          identificador,
          tipooperacao,
          numseqpai,
          numpedido,
          coditem,
          numlote,
          pesoitem,
          pesobrutoitem,
          qtdvolumes,
          qtdpecas,
          tolmais,
          qtdpacote,
          statusregistro
     FROM roma_item_885
    WHERE cod_empresa  = p_cod_empresa
      AND numromaneio  = p_numromaneio
 ORDER BY numromaneio
   
   FOREACH cq_impressao INTO 
           p_roma_item_885.numromaneio,
           p_roma_item_885.codciddest,
           p_roma_item_885.numsequencia,
           p_roma_item_885.identificador,
           p_roma_item_885.tipooperacao,
           p_roma_item_885.numseqpai,
           p_roma_item_885.numpedido,
           p_roma_item_885.coditem,
           p_roma_item_885.numlote,
           p_roma_item_885.pesoitem,
           p_roma_item_885.pesobrutoitem,
           p_roma_item_885.qtdvolumes,
           p_roma_item_885.qtdpecas,
           p_roma_item_885.tolmais,
           p_roma_item_885.qtdpacote,
           p_roma_item_885.statusregistro
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','roma_item_885')
         EXIT FOREACH
      END IF      
      
      SELECT den_cidade
        INTO p_den_cidade
        FROM cidades
       WHERE cod_empresa = p_cod_empresa
         AND cod_cidade  = p_roma_item_885.codciddest
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cidades')
         EXIT FOREACH
      END IF     
     
      OUTPUT TO REPORT pol0815_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0815_relat   
   
   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso!!!'
   END IF

  
END FUNCTION 

#-------------------------------#
 FUNCTION pol0815_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0815.tmp"
         START REPORT pol0815_relat TO p_caminho
      ELSE
         START REPORT pol0815_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0815_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol0815_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_comprime, p_den_empresa, 
               COLUMN 173, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0938",
               COLUMN 067, "ROMANEIOS ENVIADOS PELO TRIM",
               COLUMN 163, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' Romaneio  Cid.   Nome da cidade sqi Identifi.   Opera��o  Seq. roma. Pedido    Cod. item          Lote      Peso liquido  Peso bruto   Volumes   Qdt. pe�as Tolerancia Qtd. pac.  S'
         PRINT COLUMN 001, '---------- -----  -------------- --- ---------- ---------- ---------- ------ --------------- --------------- ------------ ------------ ---------- ---------- ---------- ---------- -'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_roma_item_885.numromaneio           USING '##########',
               COLUMN 012, p_roma_item_885.codciddest,
               COLUMN 019, p_den_cidade,
               COLUMN 034, p_roma_item_885.numsequencia          USING '##########',
               COLUMN 038, p_roma_item_885.identificador         USING '##########',
               COLUMN 049, p_roma_item_885.tipooperacao          USING '##########',
               COLUMN 060, p_roma_item_885.numseqpai             USING '##########',
               COLUMN 071, p_roma_item_885.numpedido             USING '######',
               COLUMN 078, p_roma_item_885.coditem,
               COLUMN 094, p_roma_item_885.numlote,
               COLUMN 110, p_roma_item_885.pesoitem              USING '######&.&&&&&',
               COLUMN 123, p_roma_item_885.pesobrutoitem         USING '######&.&&&&&',
               COLUMN 136, p_roma_item_885.qtdvolumes            USING '##########',
               COLUMN 147, p_roma_item_885.qtdpecas              USING '######&.&&&',
               COLUMN 158, p_roma_item_885.tolmais               USING '######&.&&&',
               COLUMN 169, p_roma_item_885.qtdpacote             USING '#######&.&&',
               COLUMN 180, p_roma_item_885.statusregistro
              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#




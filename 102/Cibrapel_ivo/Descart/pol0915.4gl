#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0915                                                 #
# OBJETIVO: APONTAMENTO do Trim Box                                 #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 26/02/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
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
          p_last_row           SMALLINT
          
   DEFINE p_apont_trim_885    RECORD 
          numsequencia         LIKE apont_trim_885.numsequencia,
          numordem             LIKE apont_trim_885.numordem,
          numpedido            LIKE apont_trim_885.numpedido,
          coditem              LIKE apont_trim_885.coditem,
          num_lote             LIKE apont_trim_885.num_lote,
          codmaquina           LIKE apont_trim_885.codmaquina,
          inicio               LIKE apont_trim_885.inicio,
          fim                  LIKE apont_trim_885.fim,
          qtdprod              LIKE apont_trim_885.qtdprod,
          tipmovto             LIKE apont_trim_885.tipmovto,
          comprimento          LIKE apont_trim_885.comprimento,
          largura              LIKE apont_trim_885.largura,
          diametro             LIKE apont_trim_885.diametro,
          tubete               LIKE apont_trim_885.tubete,
          consumorefugo        LIKE apont_trim_885.consumorefugo,
          pesoteorico          LIKE apont_trim_885.pesoteorico,
          iesdevolucao         LIKE apont_trim_885.iesdevolucao,
          usuario              LIKE apont_trim_885.usuario,
          statusregistro       LIKE apont_trim_885.statusregistro,
          datageracao          LIKE apont_trim_885.datageracao
   END RECORD         

   DEFINE p_numsequencia       LIKE apont_trim_885.numsequencia,
          p_numsequencia_ant   LIKE apont_trim_885.numsequencia,
          p_numordem           LIKE apont_trim_885.numordem,
          p_tip_quantidade     CHAR(01)

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0915-05.00.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0915_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0915_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0915") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0915 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   IF NOT pol0915_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO codempresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa uma ordem para ser consultada ou listada"
         CALL pol0915_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso!!!'
            LET p_ies_cons = TRUE 
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO codempresa
            ERROR "Operação Cancelada!!!"
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0915_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0915_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Listar" "Listagem"
         IF p_ies_cons = TRUE THEN
            CALL pol0915_listagem()
         ELSE 
            ERROR "Informe previamente os parâmetros a serem listados!!!"
         END IF     
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0915

END FUNCTION

#----------------------------#
FUNCTION pol0915_le_empresa()
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

   RETURN TRUE 

END FUNCTION

#--------------------------#
 FUNCTION pol0915_informar()
#--------------------------#
   
   INITIALIZE p_numordem TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO codempresa
   LET INT_FLAG = FALSE
   
   INPUT p_numordem WITHOUT DEFAULTS
    FROM numordem
    
      AFTER FIELD numordem
         IF p_numordem IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio!!!"
            NEXT FIELD numordem       
         END IF 

         SELECT DISTINCT numordem
           FROM apont_trim_885 
          WHERE codempresa  = p_cod_empresa
            AND numordem    = p_numordem
            
         IF STATUS = 100 THEN 
            ERROR "Ordem não encontrada!!!"
            NEXT FIELD numordem 
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("lendo", "apont_trim_885")
               NEXT FIELD numordem
            END IF 
         END IF 
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0915_consulta() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0915_consulta()
#--------------------------#

   DEFINE  sql_stmt CHAR(500)

 
   LET sql_stmt = "SELECT numsequencia ",
                  "  FROM apont_trim_885 ",
                  " WHERE numordem   = '",p_numordem,"' ",
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  " order by numsequencia"
               

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_numsequencia

   IF STATUS = 100 THEN
      ERROR "Argumentos de pesquisa não encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0915_exibe_dados() THEN
         LET p_ies_cons = TRUE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol0915_exibe_dados()
#------------------------------#

  SELECT numsequencia,
         numordem,
         numpedido,
         coditem,
         num_lote,
         codmaquina,
         inicio,
         fim,
         qtdprod,
         tipmovto,
         comprimento,
         largura,
         diametro,
         tubete,
         consumorefugo,
         pesoteorico,
         iesdevolucao,
         usuario,
         statusregistro,
         datageracao
    INTO p_apont_trim_885.*
    FROM apont_trim_885
   WHERE codempresa   = p_cod_empresa
     AND numsequencia = p_numsequencia
     

   IF STATUS = 0 THEN
      
      IF p_apont_trim_885.iesdevolucao IS NULL THEN
         LET p_apont_trim_885.iesdevolucao = 'N'
      END IF
      IF p_apont_trim_885.qtdprod < 0 THEN 
         LET p_tip_quantidade = 'R'
      ELSE 
         LET p_tip_quantidade = 'A'
      END IF 
      DISPLAY p_tip_quantidade TO tip_quantidade
      DISPLAY BY NAME p_apont_trim_885.*
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0915_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_numsequencia_ant = p_numsequencia

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_numsequencia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_numsequencia
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_numsequencia = p_numsequencia_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0915_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#--------------------------#
 FUNCTION pol0915_listagem()
#--------------------------#     

   IF NOT pol0915_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0915_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT numsequencia,
          numordem,
          numpedido,
          coditem,
          num_lote,
          codmaquina,
          inicio,
          fim,
          qtdprod,
          tipmovto,
          comprimento,
          largura,
          diametro,
          tubete,
          consumorefugo,
          pesoteorico,
          iesdevolucao,
          usuario,
          statusregistro
     FROM apont_trim_885
    WHERE codempresa = p_cod_empresa
      AND numordem   = p_numordem
 ORDER BY numsequencia 
   
   FOREACH cq_impressao INTO 
           p_apont_trim_885.numsequencia,
           p_apont_trim_885.numordem,
           p_apont_trim_885.numpedido,
           p_apont_trim_885.coditem,
           p_apont_trim_885.num_lote,
           p_apont_trim_885.codmaquina,
           p_apont_trim_885.inicio,
           p_apont_trim_885.fim,
           p_apont_trim_885.qtdprod,
           p_apont_trim_885.tipmovto,
           p_apont_trim_885.comprimento,
           p_apont_trim_885.largura,
           p_apont_trim_885.diametro,
           p_apont_trim_885.tubete,
           p_apont_trim_885.consumorefugo,
           p_apont_trim_885.pesoteorico,
           p_apont_trim_885.iesdevolucao,
           p_apont_trim_885.usuario,
           p_apont_trim_885.statusregistro
           

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','apont_trim_885')
         EXIT FOREACH
      END IF      
      
      IF p_apont_trim_885.qtdprod < 0 THEN 
         LET p_tip_quantidade = 'R'
      ELSE 
         LET p_tip_quantidade = 'A'
      END IF 
      
      IF p_apont_trim_885.iesdevolucao IS NULL THEN
         LET p_apont_trim_885.iesdevolucao = 'N'
      END IF
      
      OUTPUT TO REPORT pol0915_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT POL0915_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF

  
END FUNCTION 

#-------------------------------#
 FUNCTION pol0915_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0915.tmp"
         START REPORT POL0915_relat TO p_caminho
      ELSE
         START REPORT POL0915_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0915_le_den_empresa()
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
 REPORT pol0915_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_comprime, p_den_empresa, 
               COLUMN 221, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol0915",
               COLUMN 082, "APONTAMENTOS ENVIADOS PELO TRIM BOX",
               COLUMN 200, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, ' Num seq   Num ordem  Num pedido    Cod item        Num lote     Cod maquina      Inicio                 Fim           Qtd prod    TM TO Comprimento  Largura    Diametro    Tubete    Cons refugo      Peso      DEV  Usuario   STA'
         PRINT COLUMN 002, '---------- ---------- ---------- --------------- --------------- ----------- ------------------- ------------------- ------------- -- -- ----------- ---------- ---------- ---------- ------------- ------------- --- ---------- ---'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_apont_trim_885.numsequencia   USING "##########",
               COLUMN 013, p_apont_trim_885.numordem       USING "##########",
               COLUMN 024, p_apont_trim_885.numpedido      USING "##########",
               COLUMN 035, p_apont_trim_885.coditem,       
               COLUMN 051, p_apont_trim_885.num_lote,
               COLUMN 067, p_apont_trim_885.codmaquina,
               COLUMN 079, p_apont_trim_885.inicio,
               COLUMN 099, p_apont_trim_885.fim,
               COLUMN 119, p_apont_trim_885.qtdprod        USING "-,###,##&.&&&",
               COLUMN 133, p_apont_trim_885.tipmovto,
               COLUMN 136, p_tip_quantidade,
               COLUMN 140, p_apont_trim_885.comprimento    USING "##########",
               COLUMN 151, p_apont_trim_885.largura        USING "##########",
               COLUMN 162, p_apont_trim_885.diametro       USING "##########",
               COLUMN 173, p_apont_trim_885.tubete         USING "##########",
               COLUMN 184, p_apont_trim_885.consumorefugo  USING "#,###,##&.&&&",
               COLUMN 198, p_apont_trim_885.pesoteorico    USING "#,###,##&.&&&",
               COLUMN 212, p_apont_trim_885.iesdevolucao,
               COLUMN 216, p_apont_trim_885.usuario,
               COLUMN 227, p_apont_trim_885.statusregistro
               
         

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




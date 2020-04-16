#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0912                                                 #
# OBJETIVO: CONSULTA APONTAMENTO DE BOBINAS                         #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 19/02/09                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          
   DEFINE p_Apont_papel_885    RECORD 
          numsequencia         LIKE Apont_papel_885.numsequencia,
          numordem             LIKE Apont_papel_885.numordem,
          numlote              LIKE Apont_papel_885.numlote,
          codmaquina           LIKE Apont_papel_885.codmaquina,
          coditem              LIKE Apont_papel_885.coditem,
          largura              LIKE Apont_papel_885.largura,
          diametro             LIKE Apont_papel_885.diametro,
          tubete               LIKE Apont_papel_885.tubete,
          comprimento          LIKE Apont_papel_885.comprimento,
          pesobalanca          LIKE Apont_papel_885.pesobalanca,
          estorno              LIKE Apont_papel_885.estorno,
          datproducao          LIKE Apont_papel_885.datproducao,
          tempoproducao        LIKE Apont_papel_885.tempoproducao,
          statusregistro       LIKE Apont_papel_885.statusregistro,
          tipmovto             LIKE Apont_papel_885.tipmovto,
          iesdevolucao         LIKE Apont_papel_885.iesdevolucao,
          usuario              LIKE Apont_papel_885.usuario
   END RECORD         

   DEFINE p_numsequencia       LIKE Apont_papel_885.numsequencia,
          p_numsequencia_ant   LIKE Apont_papel_885.numsequencia,
          p_numordem           LIKE Apont_papel_885.numordem,
          p_tip_quantidade     CHAR(03)

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0912-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0912_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0912_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0912") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0912 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO codempresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta apontamento enviado pelo trim"
         CALL pol0912_consulta() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE 
         ELSE
            ERROR "Operação Cancelada!!!"
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0912_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0912_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      {COMMAND "Listar" "Listagem"
         IF p_ies_cons = TRUE THEN
            CALL pol0912_listagem()
         ELSE 
            ERROR "Informe previamente os parâmetros a serem listados!!!"
         END IF     }
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0912

END FUNCTION


#--------------------------#
 FUNCTION pol0912_consulta()
#--------------------------#

   DEFINE  sql_stmt     CHAR(500),
           where_clause CHAR(500)

   CLEAR FORM
   DISPLAY p_cod_empresa TO codempresa
   
   LET INT_FLAG = FALSE   
   LET p_numsequencia_ant = p_numsequencia
   
   CONSTRUCT BY NAME where_clause ON
      apont_papel_885.numordem,
      apont_papel_885.coditem,
      apont_papel_885.numlote,
      apont_papel_885.codmaquina

 
    IF INT_FLAG THEN      
      IF p_ies_cons THEN
         LET p_numsequencia = p_numsequencia_ant
         CALL pol0915_exibe_dados()
      END IF
      
      RETURN
   END IF

   LET sql_stmt = "SELECT numsequencia, numordem ",
                  "  FROM apont_papel_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND codempresa = '",p_cod_empresa,"' ",
                  " order by numordem "
               

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF

   LET p_ies_cons = FALSE
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_numsequencia

   IF STATUS = 100 THEN
      LET p_msg = "Argumentos de pesquisa não encontrados"
      CALL log0030_mensagem(p_msg,'info')
   ELSE 
      IF STATUS = 0 THEN
         IF pol0912_exibe_dados() THEN
            LET p_ies_cons = TRUE
         END IF
      ELSE
         CALL log003_err_sql('Criando','var_query')
      END IF
   END IF
   
   RETURN p_ies_cons

END FUNCTION

#------------------------------#
 FUNCTION pol0912_exibe_dados()
#------------------------------#

  SELECT numsequencia,
         numordem,
         numlote,
         codmaquina,
         coditem,
         largura,
         diametro,
         tubete,
         comprimento,
         pesobalanca,
         estorno,
         datproducao,
         tempoproducao,
         statusregistro,
         tipmovto,
         iesdevolucao,
         usuario            
    INTO p_Apont_papel_885.*
    FROM Apont_papel_885
   WHERE codempresa   = p_cod_empresa
     AND numsequencia = p_numsequencia
     

   IF STATUS = 0 THEN
      
      IF p_Apont_papel_885.iesdevolucao IS NULL THEN
         LET p_Apont_papel_885.iesdevolucao = 'N'
      END IF
      IF p_Apont_papel_885.estorno = 1 THEN 
         LET p_tip_quantidade = 'E'
      ELSE 
         LET p_tip_quantidade = 'A'
      END IF 
      DISPLAY p_tip_quantidade TO tip_quantidade
      DISPLAY BY NAME p_Apont_papel_885.*
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0912_paginacao(p_funcao)
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
      
      IF pol0912_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#--------------------------#
 FUNCTION pol0912_listagem()
#--------------------------#     

   IF NOT pol0912_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0912_le_den_empresa() THEN
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
          numlote,
          codmaquina,
          coditem,
          largura,
          diametro,
          tubete,
          comprimento,
          pesobalanca,
          estorno,
          datproducao,
          tempoproducao,
          statusregistro,
          tipmovto,
          iesdevolucao,
          usuario
            
     FROM Apont_papel_885
    WHERE codempresa = p_cod_empresa
      AND numordem   = p_numordem
 ORDER BY numsequencia
   
   FOREACH cq_impressao INTO 
           p_Apont_papel_885.numsequencia,
           p_Apont_papel_885.numordem,
           p_Apont_papel_885.numlote,
           p_Apont_papel_885.codmaquina,
           p_Apont_papel_885.coditem,
           p_Apont_papel_885.largura,
           p_Apont_papel_885.diametro,
           p_Apont_papel_885.tubete,
           p_Apont_papel_885.comprimento,
           p_Apont_papel_885.pesobalanca,
           p_Apont_papel_885.estorno,
           p_Apont_papel_885.datproducao,
           p_Apont_papel_885.tempoproducao,
           p_Apont_papel_885.statusregistro,
           p_Apont_papel_885.tipmovto,
           p_Apont_papel_885.iesdevolucao,
           p_Apont_papel_885.usuario
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Apont_papel_885')
         EXIT FOREACH
      END IF      
      
      IF p_Apont_papel_885.iesdevolucao IS NULL THEN
         LET p_Apont_papel_885.iesdevolucao = 'N'
      END IF
      
      IF p_Apont_papel_885.estorno = 1 THEN 
         LET p_tip_quantidade = '1-R'
      ELSE 
         LET p_tip_quantidade = '0-A'
      END IF 
     
      OUTPUT TO REPORT pol0912_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0912_relat   
   
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
 FUNCTION pol0912_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0912.tmp"
         START REPORT pol0912_relat TO p_caminho
      ELSE
         START REPORT pol0912_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0912_le_den_empresa()
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
 REPORT pol0912_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_comprime, p_den_empresa, 
               COLUMN 174, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol0915",
               COLUMN 072, "APONTAMENTOS ENVIADOS PELO TRIM PAPEL",
               COLUMN 154, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, ' Num seq   Num ordem     Cod item        Num lote     Cod maquina     Peso      TM  TO Comprimento  Largura    Diametro    Tubete      Data producao     Tempo prod DEV  Usuario   STA'
         PRINT COLUMN 002, '---------- ---------- --------------- --------------- ----------- ------------- -- --- ----------- ---------- ---------- ---------- -------------------- ---------- --- ---------- ---'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_Apont_papel_885.numsequencia   USING "##########",
               COLUMN 013, p_Apont_papel_885.numordem       USING "##########",
               COLUMN 024, p_Apont_papel_885.coditem,       
               COLUMN 040, p_Apont_papel_885.numlote[1,15],
               COLUMN 056, p_Apont_papel_885.codmaquina,
               COLUMN 068, p_Apont_papel_885.pesobalanca    USING "#,###,##&.&&&",
               COLUMN 082, p_Apont_papel_885.tipmovto,
               COLUMN 085, p_tip_quantidade,
               COLUMN 090, p_Apont_papel_885.comprimento    USING "##########",
               COLUMN 101, p_Apont_papel_885.largura        USING "##########",
               COLUMN 112, p_Apont_papel_885.diametro       USING "##########",
               COLUMN 123, p_Apont_papel_885.tubete         USING "##########",
               COLUMN 135, p_Apont_papel_885.datproducao,
               COLUMN 155, p_Apont_papel_885.tempoproducao  USING "##########",
               COLUMN 166, p_Apont_papel_885.iesdevolucao,
               COLUMN 170, p_Apont_papel_885.usuario,
               COLUMN 181, p_Apont_papel_885.statusregistro USING "##&"
               
         

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
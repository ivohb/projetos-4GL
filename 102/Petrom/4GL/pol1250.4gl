#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1250                                                 #
# OBJETIVO: ERROS DA ANÁLISE DO CONHECIMENTO DE FRETE               #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 03/01/14                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_chamou             CHAR(07)
         
END GLOBALS

DEFINE p_den_transpor          CHAR(36),
       p_placa                 CHAR(07),
       p_cid_orig              CHAR(05),
       p_cid_dest              CHAR(05)
       
DEFINE p_erro RECORD
  cod_empresa        char(02),
  cod_transpor       char(15),
  num_conhec         decimal(7,0),
  ser_conhec         char(3),
  ssr_conhec         decimal(2,0),
  den_erro           char(500),
  dat_ini_proces     date,
  hor_ini_proces     char(08)
END RECORD

DEFINE p_erroa RECORD
  cod_empresa        char(02),
  cod_transpor       char(15),
  num_conhec         decimal(7,0),
  ser_conhec         char(3),
  ssr_conhec         decimal(2,0),
  den_erro           char(500),
  dat_ini_proces     date,
  hor_ini_proces     char(08)
END RECORD

DEFINE m_den_cidade  CHAR(30)

MAIN
   CALL log0180_conecta_usuario()
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   
   LET p_versao = "pol1250-10.02.07"
   CALL pol1161_versao_prg(p_versao)
   
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_status = 0; LET p_user = 'admlog'

   IF p_status = 0 THEN
      CALL pol1250_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1250_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1250") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1250 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1250_limpa_tela()

   IF NUM_ARGS() > 0  THEN
      LET p_chamou = ARG_VAL(1)
   ELSE
      LET p_chamou = NULL
   END IF
   
   IF p_chamou = 'pol1251' THEN
      IF pol1250_consulta() THEN
         ERROR 'Consulta efetuada com sucesso !!!'
      ELSE
         ERROR 'consulta cancela !!!'
      END IF 
   END IF
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1250_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1250_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1250_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Informar" "Informar dados complementares"
         IF p_ies_cons THEN
            IF pol1250_inc_placa() THEN
               ERROR 'Operação efetuada com sucesso.'
            ELSE
               ERROR 'Operação cancelada.'
            END IF
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      #COMMAND "Listar" "Listagem dos registros cadastrados."
      #   CALL pol1250_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1250_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1250

END FUNCTION

#-----------------------#
 FUNCTION pol1250_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "   Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br.com\n\n ",
               "      LOGIX 10.02\n",
               "   www.grupoaceex.com.br\n",
               "     (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1250_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1250_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   DECLARE cq_erro CURSOR FOR
    SELECT cod_empresa, 
           cod_transpor,
           num_conhec,  
           ser_conhec,  
           ssr_conhec  
      FROM erro_conhec_455
   FOREACH cq_erro INTO
         p_erro.cod_empresa, 
         p_erro.cod_transpor,
         p_erro.num_conhec,  
         p_erro.ser_conhec,  
         p_erro.ssr_conhec  
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_erro')
         EXIT FOREACH
      END IF
      
      SELECT ies_incl_cap
        FROM frete_sup
       WHERE cod_empresa  =  p_erro.cod_empresa
         AND cod_transpor =  p_erro.cod_transpor
         AND num_conhec   =  p_erro.num_conhec 
         AND ser_conhec   =  p_erro.ser_conhec  
         AND ssr_conhec   =  p_erro.ssr_conhec   
      
      IF STATUS = 100 THEN
         DELETE FROM erro_conhec_455
          WHERE cod_empresa  = p_erro.cod_empresa  
            AND cod_transpor = p_erro.cod_transpor 
            AND num_conhec   = p_erro.num_conhec   
            AND ser_conhec   = p_erro.ser_conhec   
            AND ssr_conhec   = p_erro.ssr_conhec   
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_erro')
            EXIT FOREACH
         END IF
      END IF
   
   END FOREACH   
   
   CALL pol1250_limpa_tela()
   LET p_erroa.* = p_erro.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      erro_conhec_455.cod_empresa,        
      erro_conhec_455.cod_transpor,  
      erro_conhec_455.num_conhec,    
      erro_conhec_455.dat_ini_proces

      ON KEY (control-z)
         CALL pol1250_popup()

   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1250_limpa_tela()
         ELSE
            LET p_erro.* = p_erroa.*
            CALL pol1250_exibe_dados() 
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM erro_conhec_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_empresa, dat_ini_proces, cod_transpor, num_conhec"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_erro.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1250_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------#
 FUNCTION pol1250_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_empresa)
         CALL log009_popup(8,10,"Empresas","empresa",
              "cod_empresa","den_empresa","","N"," 1=1 order by cod_empresa") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_erro.cod_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_empresa
         END IF

      WHEN INFIELD(cod_transpor)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_erro.cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(cid_orig)
         CALL log009_popup(8,10,"Cidades","cidades",
              "cod_cidade","den_cidade","","N"," 1=1 order by den_cidade") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cid_orig = p_codigo CLIPPED
            DISPLAY p_codigo TO cid_orig
         END IF

      WHEN INFIELD(cid_dest)
         CALL log009_popup(8,10,"Cidades","cidades",
              "cod_cidade","den_cidade","","N"," 1=1 order by den_cidade") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cid_dest = p_codigo CLIPPED
            DISPLAY p_codigo TO cid_dest
         END IF

   END CASE 

END FUNCTION 

#------------------------------#
 FUNCTION pol1250_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_erro.*
   
   CALL pol1250_le_den_empresa(p_erro.cod_empresa)
   DISPLAY p_den_empresa TO den_empresa

   CALL pol1250_le_den_transpor(p_erro.cod_transpor)
   DISPLAY p_den_transpor TO den_transpor
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
 FUNCTION pol1250_le_den_empresa(p_cod)#
#--------------------------------------#

   DEFINE p_cod CHAR(02)
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod
   
   IF STATUS <> 0 THEN
      LET p_den_empresa = ''
   END IF

END FUNCTION

#--------------------------------------#
FUNCTION pol1250_le_den_transpor(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT raz_social
     INTO p_den_transpor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_transpor = NULL
   END IF  

END FUNCTION

#-----------------------------------#
 FUNCTION pol1250_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_erroa.* = p_erro.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_erro.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_erro.*
      
      END CASE

      IF STATUS = 0 THEN
         CALL pol1250_exibe_dados() RETURNING p_status
         EXIT WHILE
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_erro.* = p_erroa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#---------------------------#

FUNCTION pol1250_inc_placa()#
#---------------------------#
   
   SELECT placa_veic,
          cidade_orig,
          cidade_dest
     INTO p_placa,
          p_cid_orig,
          p_cid_dest
     FROM placa_veic_455
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_erro.cod_transpor
      AND num_conhec   = p_erro.num_conhec
      AND ser_conhec   = p_erro.ser_conhec
      AND ssr_conhec   = p_erro.ssr_conhec
    
   IF STATUS = 100 THEN
      INITIALIZE p_placa, p_cid_orig, p_cid_dest TO NULL
   END IF
          
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1250a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1250a AT 07,05 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET INT_FLAG = FALSE
   LET p_status = FALSE

   INPUT p_placa, p_cid_orig, p_cid_dest
      WITHOUT DEFAULTS FROM placa_veic, cid_orig, cid_dest
   
   AFTER FIELD cid_orig
      
      IF p_cid_orig IS NOT NULL THEN
         IF NOT pol1250_le_cidade(p_cid_orig) THEN
            ERROR 'Cidade inexistente no Logix.'
            NEXT FIELD cid_orig
         ELSE
            DISPLAY m_den_cidade TO den_cid_orig
         END IF
      END IF

   AFTER FIELD cid_dest

      IF p_cid_dest IS NOT NULL THEN
         IF NOT pol1250_le_cidade(p_cid_dest) THEN
            ERROR 'Cidade inexistente no Logix.'
            NEXT FIELD cid_dest
         ELSE
            DISPLAY m_den_cidade TO den_cid_dest
         END IF
      END IF
   
   AFTER INPUT
      IF NOT INT_FLAG THEN
         IF p_placa IS NULL THEN
            ERROR 'Por favor, informe a placa do veículo.'
            NEXT FIELD placa_veic
         END IF
      END IF

   ON KEY (control-z)
      CALL pol1250_popup()
   
   END INPUT
   
   IF NOT INT_FLAG THEN
      IF ins_placa() THEN
         LET p_status = TRUE 
      END IF
   END IF
   
   CLOSE WINDOW w_pol1250a
   
   RETURN p_status

END FUNCTION

#--------------------------------#
FUNCTION pol1250_le_cidade(l_cid)#
#--------------------------------#
   
   DEFINE l_cid     CHAR(05)
   
   SELECT den_cidade
     INTO m_den_cidade
     FROM cidades
    WHERE cod_cidade = l_cid

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','Cidades')
      LET m_den_cidade = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   

#-------------------#
FUNCTION ins_placa()#
#-------------------#

   SELECT 1
     FROM placa_veic_455
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_erro.cod_transpor
      AND num_conhec   = p_erro.num_conhec
      AND ser_conhec   = p_erro.ser_conhec
      AND ssr_conhec   = p_erro.ssr_conhec
    
   IF STATUS = 100 THEN

      INSERT INTO placa_veic_455 
      VALUES(
         p_erro.cod_empresa, 
         p_erro.cod_transpor,
         p_erro.num_conhec,  
         p_erro.ser_conhec,  
         p_erro.ssr_conhec, 
         p_placa, 
         p_cid_orig,
         p_cid_dest)
   ELSE
      UPDATE placa_veic_455
         SET placa_veic = p_placa,
             cidade_orig = p_cid_orig,
             cidade_dest = p_cid_dest
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_erro.cod_transpor
      AND num_conhec   = p_erro.num_conhec
      AND ser_conhec   = p_erro.ser_conhec
      AND ssr_conhec   = p_erro.ssr_conhec
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('GRAVANDO','placa_veic_455')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
{
#--------------------------#
 FUNCTION pol1250_listagem()
#--------------------------#     

   IF NOT pol1250_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1250_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM erro_conhec_455 a
     ORDER BY cod_transpor, chapa
  
   FOREACH cq_impressao INTO p_erro.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      CALL pol1250_le_den_transpor(p_erro.cod_transpor)
      
      CALL pol1250_seta_carreta()
      CALL pol1250_seta_carga()
      
      OUTPUT TO REPORT pol1250_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1250_finaliza_relat()

   RETURN
     
END FUNCTION 

#------------------------------#
FUNCTION pol1250_seta_carreta()#
#------------------------------#

   CASE p_erro.tip_erro
      WHEN 'B' LET p_tip_erro = 'BI-TREM'
      WHEN 'C' LET p_tip_erro = 'CARRETA'
      WHEN 'T' LET p_tip_erro = 'TRUCK'
   END CASE

END FUNCTION

#----------------------------#
FUNCTION pol1250_seta_carga()#
#----------------------------#

   CASE p_erro.tip_carga
      WHEN 'G' LET p_tip_carga = 'GRANEL'
      WHEN 'S' LET p_tip_carga = 'SECA'
   END CASE

END FUNCTION
      
#-------------------------------#
 FUNCTION pol1250_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1250_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1250.tmp'
         START REPORT pol1250_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1250_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1250_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1250_relat   

   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
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
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1250_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1250",
               COLUMN 010, "CARRETAS P/ CONTROLE DE FRETE",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   NOME                                 CHAPA      TIPO    CARGA'                                
         PRINT COLUMN 001, '---------------- ------------------------------------ ---------- ------- -------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   NOME                                 CHAPA      TIPO    CARGA'                                
         PRINT COLUMN 001, '---------------- ------------------------------------ ---------- ------- -------'

      ON EVERY ROW

         PRINT COLUMN 001, p_erro.cod_transpor,
               COLUMN 018, p_den_transpor,
               COLUMN 055, p_erro.chapa,
               COLUMN 066, p_tip_erro,
               COLUMN 074, p_tip_carga
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#

#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1285 - RELAÇÃO DE CONHECIMENTOS BLOQUEADOS           #
# AUTOR...: IVO BO                                                  #
# DATA....: 23/06/2014                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       p_den_empresa        LIKE empresa.den_empresa,
       p_user               LIKE usuario.nom_usuario,
       p_status             SMALLINT,
       p_index              SMALLINT,
       s_index              SMALLINT,
       p_ind                SMALLINT,
       s_ind                SMALLINT,
       p_count              SMALLINT,
       p_houve_erro         SMALLINT,
       p_ies_impressao      CHAR(01),
       g_ies_ambiente       CHAR(01),
       p_caminho            CHAR(080),
       p_versao             CHAR(18),
       p_nom_arquivo        CHAR(100),
       p_nom_tela           CHAR(200),
       p_ies_cons           SMALLINT,
       p_msg                CHAR(500),
       p_last_row           SMALLINT,
       p_query              CHAR (3000),
       comando              CHAR(80),
       p_opcao              CHAR(01)	

END GLOBALS

DEFINE p_cod_transpor       CHAR(15),        	  
       p_den_transpor       CHAR(36),        	  
       p_dat_refer          DATE
       

DEFINE p_relat              RECORD
       dat_entrada          DATE,
       num_conhec           INTEGER,
       ser_conhec           CHAR(03),
       cod_transpor         CHAR(15),
       den_transpor         CHAR(36),
       val_frete            DECIMAL(12,2),
       divergencia          char(78)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1285-10.02.01  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1285_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1285_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1285") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1285 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1285_limpa_tela()

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para listegem"
         IF pol1285_informar() THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso!'
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operação cancelada!'
            LET p_ies_cons = FALSE
            NEXT OPTION 'Fim'
         END IF
      COMMAND "Listar" "Listagem dos documentos"
         IF p_ies_cons THEN
            CALL pol1285_listagem()
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'
         END IF
         LET p_ies_cons = FALSE
         NEXT OPTION 'Fim'
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1285

END FUNCTION

#----------------------------#
FUNCTION pol1285_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION
      
#--------------------------#
FUNCTION pol1285_informar()#
#--------------------------#
      
   INITIALIZE p_dat_refer TO NULL
     
   CALL pol1285_limpa_tela()
         
   LET INT_FLAG = FALSE
   
   INPUT p_dat_refer
      WITHOUT DEFAULTS 
        FROM dat_refer    
	  
      AFTER INPUT
         
        IF NOT INT_FLAG THEN
           IF p_dat_refer IS NULL THEN
              ERROR 'Campo com preenchimento obrigatório.'
              NEXT FIELD dat_refer
           END IF
        END IF
          	 
	 END INPUT
	 
	 IF INT_FLAG THEN
	    RETURN FALSE
	 END IF
	 
	 RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1285_le_den_transpor(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)

   SELECT raz_social
     INTO p_den_transpor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod
         
   IF STATUS = 100 THEN 
   
      SELECT nom_cliente
        INTO p_den_transpor
        FROM clientes
       WHERE cod_cliente = p_cod
         
      IF STATUS <> 0 THEN 
         LET p_den_transpor = NULL
      END IF  
      
   END IF
   
END FUNCTION

#--------------------------#
FUNCTION pol1285_listagem()#
#--------------------------#

   IF NOT pol1285_le_den_empresa() THEN
      RETURN
   END IF   

   IF NOT pol1285_escolhe_saida() THEN
   		RETURN 
   END IF

   MESSAGE 'Processando...'
   #lds CALL LOG_refresh_display()

   LET p_count = 0
   
   DECLARE cq_impressao CURSOR FOR 
    SELECT dat_entrada_conhec, num_conhec, 
           ser_conhec, cod_transpor, val_frete 
      FROM frete_sup
     WHERE cod_empresa = p_cod_empresa
       AND ies_incl_cap = 'X'
       AND dat_entrada_conhec <= p_dat_refer
     ORDER BY dat_entrada_conhec

   FOREACH cq_impressao INTO 
      p_relat.dat_entrada,
      p_relat.num_conhec, 
      p_relat.ser_conhec, 
      p_relat.cod_transpor, 
      p_relat.val_frete

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'CURSOR: cq_impressao')
         EXIT FOREACH 
      END IF 
   
      CALL pol1285_le_den_transpor(p_relat.cod_transpor)
      LET p_relat.den_transpor = p_den_transpor
      
      IF NOT pol1285_le_divergencia() THEN
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1285_relat()     
                            
      LET p_count = p_count + 1
   
   END FOREACH
      
   CALL pol1285_finaliza_relat()


END FUNCTION

#--------------------------------#
FUNCTION pol1285_le_divergencia()
#--------------------------------#

   SELECT divergencia 
     INTO p_relat.divergencia
     FROM conhec_proces_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = p_relat.cod_transpor
      AND num_conhec = p_relat.num_conhec
      AND ser_conhec = p_relat.ser_conhec

   IF STATUS = 100 THEN
      IF NOT pol1285_le_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','conhec_proces_455')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1285_le_erro()
#-------------------------#

   SELECT den_erro 
     INTO p_relat.divergencia
     FROM erro_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = p_relat.cod_transpor
      AND num_conhec = p_relat.num_conhec
      AND ser_conhec = p_relat.ser_conhec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','erro_conhec_455')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1285_le_den_empresa()
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

#-------------------------------#
 FUNCTION pol1285_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1285_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1285.tmp' 
         START REPORT pol1285_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1285_relat TO p_nom_arquivo
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol1285_finaliza_relat()#
#---------------------------------#

   FINISH REPORT pol1285_relat   
   
   IF p_count = 0 THEN
      LET p_msg = "NENHUM CONHECIMENTO BLOQUEADO FOI ENCONTRADO P/ A DATA INFORMADA'"
      CALL log0030_mensagem(p_msg, 'excla')
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
 REPORT pol1285_relat()#
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 059, "CONHECIMENTOS DE FRETE BLOQUEADOS",
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL1285",
               COLUMN 059, "DATA DE REFERENCIA: ", p_dat_refer USING "dd/mm/yyyy",
               COLUMN 115, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------"

         PRINT
         PRINT COLUMN 001, 'DAT ENTRADA CONHEC  SER   VAL FRETE  TRANSPORTADORA  DESCRICAO                      DIVERGENCIA'
         PRINT COLUMN 001, '----------- ------- --- ------------ --------------- ------------------------------ ------------------------------------------------------------'

      PAGE HEADER
	  
         PRINT COLUMN 135, "PAG. ", PAGENO USING "####&"
         PRINT
         PRINT COLUMN 001, 'DAT ENTRADA CONHEC  SER   VAL FRETE  TRANSPORTADORA  DESCRICAO                      DIVERGENCIA'
         PRINT COLUMN 001, '----------- ------- --- ------------ --------------- ------------------------------ ------------------------------------------------------------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.dat_entrada USING 'dd/mm/yyyy',
               COLUMN 013, p_relat.num_conhec USING '######9',
               COLUMN 021, p_relat.ser_conhec,
               COLUMN 025, p_relat.val_frete USING '#,###,##&.&&',
               COLUMN 038, p_relat.cod_transpor,
               COLUMN 054, p_relat.den_transpor[1,30],
               COLUMN 085, p_relat.divergencia[1,60]
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

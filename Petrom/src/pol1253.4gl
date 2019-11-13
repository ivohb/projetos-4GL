#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1253 - RELAÇÃO DE DOCUMENTOS POR USUÁRIO             #
# OBJETIVO: LISTAR NF DE ENTRADA E/OU SAIDA PARA ENVIO A SEGURADORA #
# AUTOR...: IVO BO                                                  #
# DATA....: 23/06/2014                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       p_den_empresa        LIKE empresa.den_empresa,
       p_user               LIKE usuario.nom_usuario,
       p_num_seq            INTEGER,
       P_Comprime           CHAR(01),
       p_descomprime        CHAR(01),
       p_6lpp               CHAR(100),
       p_8lpp               CHAR(100),
       p_rowid              INTEGER,
       p_retorno            SMALLINT,
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
       p_dat_ini            DATE,
       p_dat_fim            DATE,
       p_ies_entrada        CHAR(01),
       p_ies_saida          CHAR(01),
       p_tip_frete          CHAR(01),
       p_pct_seguro         DECIMAL(6,2),
       p_dat_vencto_ddr     DATE,
       p_ies_ddr            CHAR(01),
       p_num_transac        INTEGER,
       p_dat_nfs            DATETIME YEAR TO DAY
       
DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE p_relat              RECORD
       dat_nf               DATE,
       num_nf               INTEGER,
       cli_fornec           CHAR(15),
       cod_transpor         CHAR(15),
       den_transpor         CHAR(36),
       num_conhec           INTEGER,
       ser_conhec           CHAR(03),
       ssr_conhec           INTEGER,
       tip_frete            CHAR(01),
       dat_conhec           DATE,
       cod_cid_orig         CHAR(05),
       den_cid_orig         CHAR(30),
       est_origem           CHAR(02),
       cod_cid_dest         CHAR(05),
       den_cid_dest         CHAR(30),
       est_destino          CHAR(02),
       val_nota             DECIMAL(12,2),
       val_seguradora       DECIMAL(12,2),
       dat_ddr              CHAR(18)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1253-10.02.00  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1253_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1253_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1253") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1253 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1253_limpa_tela()

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para listegem"
         IF pol1253_informar() THEN
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
            CALL pol1253_listagem()
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
   
   CLOSE WINDOW w_pol1253

END FUNCTION

#----------------------------#
FUNCTION pol1253_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION
      
#--------------------------#
FUNCTION pol1253_informar()#
#--------------------------#
      
   INITIALIZE p_dat_ini, 
      p_dat_fim, p_cod_transpor TO NULL
      
   CALL pol1253_limpa_tela()
   
   LET p_ies_entrada = 'S'
   LET p_ies_saida = 'S'
      
   LET INT_FLAG = FALSE
   
   INPUT p_dat_ini,
         p_dat_fim,
         p_cod_transpor,
         p_ies_entrada,
         p_ies_saida
      WITHOUT DEFAULTS 
        FROM dat_ini,      
             dat_fim,      
             cod_transpor, 
             ies_entrada,   
             ies_saida     
	  
	    AFTER FIELD cod_transpor
	    
	       IF p_cod_transpor IS NOT NULL THEN
            CALL pol1253_le_den_transpor(p_cod_transpor)
          
            IF p_den_transpor IS NULL THEN 
               ERROR 'Transportadora inexistente.'
               NEXT FIELD cod_transpor
            END IF  
         
            DISPLAY p_den_transpor TO den_transpor
	       ELSE
	          LET p_den_transpor = NULL
	       END IF   
	       
	       DISPLAY p_den_transpor TO den_transpor

      ON KEY (control-z)
         CALL pol1253_popup()

      AFTER INPUT
         
        IF NOT INT_FLAG THEN
           IF p_dat_ini IS NOT NULL THEN
              IF p_dat_fim IS NOT NULL THEN
                 IF p_dat_fim < p_dat_ini THEN
                    ERROR 'Período inválido.'
                    NEXT FIELD dat_ini
                 END IF
              END IF
           END IF
        END IF
          	 
	 END INPUT
	 
	 IF INT_FLAG THEN
	    RETURN FALSE
	 END IF
	 
	 RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1253_le_den_transpor(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT nom_cliente
     INTO p_den_transpor
     FROM clientes
    WHERE cod_cliente = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_transpor = NULL
   END IF  

END FUNCTION
   
#-----------------------#
FUNCTION pol1253_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 07", p_versao)
         
         CURRENT WINDOW IS w_pol1253
         IF p_codigo IS NOT NULL THEN
            LET p_cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF
	 
   END CASE
   
END FUNCTION
	  
#------------------------------#
FUNCTION pol1253_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE INPUT
         EXIT INPUT
         
   END INPUT

END FUNCTION

#-----------------------#
FUNCTION pol1253_query()#
#-----------------------#

   LET p_query = 
       "SELECT cod_transpor, num_conhec, ser_conhec, ssr_conhec, tip_frete, ",
       " dat_conhec, cidade_orig, cidade_dest FROM conhec_proces_455 ",
       " WHERE cod_empresa = '",p_cod_empresa,"' "

   IF p_dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_conhec >= '",p_dat_ini,"' "
   END IF
   
   IF p_dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_conhec <= '",p_dat_fim,"' "
   END IF
   
   IF p_cod_transpor IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_transpor = '",p_cod_transpor,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY tip_frete, dat_conhec "

END FUNCTION   

#--------------------------#
FUNCTION pol1253_listagem()#
#--------------------------#

   IF NOT pol1253_le_par_frete() THEN
      RETURN
   END IF

   IF NOT pol1253_escolhe_saida() THEN
   		RETURN 
   END IF

   IF NOT pol1253_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   LET p_count       = 0
   
   CALL pol1253_query()
   
   PREPARE var_imp FROM p_query   
   DECLARE cq_impressao CURSOR FOR var_imp

   FOREACH cq_impressao INTO 
      p_relat.cod_transpor, 
      p_relat.num_conhec, 
      p_relat.ser_conhec, 
      p_relat.ssr_conhec, 
      p_relat.tip_frete,
      p_relat.dat_conhec, 
      p_relat.cod_cid_orig, 
      p_relat.cod_cid_dest

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         EXIT FOREACH 
      END IF 
   
      LET pr_men[1].mensagem = 'Conhecimento: ', p_relat.num_conhec
      CALL pol1253_exib_mensagem()

      CALL pol1253_le_den_transpor(p_relat.cod_transpor)
      LET p_relat.den_transpor = p_den_transpor
      CALL pol1253_le_cidade_orig()
      CALL pol1253_le_cidade_dest()
      
      IF p_relat.tip_frete = 'V' THEN
         IF NOT pol1253_le_nf_saida() THEN
            EXIT FOREACH
         END IF      
      ELSE
         IF NOT pol1253_le_ddr() THEN
            EXIT FOREACH
         END IF
         IF p_ies_ddr = 'N' THEN
            CONTINUE FOREACH
         END IF
         IF p_dat_vencto_ddr > TODAY THEN
            LET p_relat.dat_ddr = p_dat_vencto_ddr, 'Vencida'
         ELSE
            LET p_relat.dat_ddr = p_dat_vencto_ddr
         END IF
         IF NOT pol1253_le_nf_entrada() THEN
            EXIT FOREACH
         END IF
      END IF
         
      LET p_count = p_count + 1
   
   END FOREACH
      
   CALL pol1253_finaliza_relat()


END FUNCTION

#--------------------------------#
FUNCTION pol1253_le_cidade_orig()#
#--------------------------------#

   SELECT den_cidade,
          cod_uni_feder
     INTO p_relat.den_cid_orig,
          p_relat.est_origem
     FROM cidades
    WHERE cod_cidade = p_relat.cod_cid_orig

   IF STATUS <> 0 THEN
      INITIALIZE p_relat.den_cid_orig,
          p_relat.est_origem TO NULL
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1253_le_cidade_dest()#
#--------------------------------#

   SELECT den_cidade,
          cod_uni_feder
     INTO p_relat.den_cid_dest,
          p_relat.est_destino
     FROM cidades
    WHERE cod_cidade = p_relat.cod_cid_dest

   IF STATUS <> 0 THEN
      INITIALIZE p_relat.den_cid_dest,
          p_relat.est_destino TO NULL
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1253_le_par_frete()#
#------------------------------#

   SELECT pct_seguro
     INTO p_pct_seguro
     FROM par_frete_455
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo', 'par_frete_455')
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1253_le_ddr()#
#------------------------#

   SELECT ies_ddr,
          dat_vencto_ddr
     INTO p_ies_ddr,
          p_dat_vencto_ddr
     FROM transportador_455
    WHERE cod_transpor = p_relat.cod_transpor
   
   IF STATUS = 100 THEN
      LET p_msg = 'Transportadora ', p_relat.cod_transpor CLIPPED, '\n',
           'não cadastrada no POL1252.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'transportador_455')
         RETURN FALSE
      END IF
   END IF 

   RETURN TRUE

END FUNCTION      

#------------------------------#
 FUNCTION pol1253_le_nf_saida()#
#------------------------------#

   DECLARE cq_x_nff CURSOR FOR
    SELECT trans_nota_fiscal_fatura
      FROM frete_sup_x_nff 
     WHERE cod_empresa = p_cod_empresa
       AND num_conhec = p_relat.num_conhec
       AND ser_conhec = p_relat.ser_conhec
       AND ssr_conhec = p_relat.ssr_conhec

   FOREACH cq_x_nff INTO p_num_transac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_x_nff')
         RETURN FALSE
      END IF
         
      SELECT cliente,
             nota_fiscal,
             dat_hor_emissao,
             val_nota_fiscal
        INTO p_relat.cli_fornec,
             p_relat.num_nf,    
             p_relat.dat_nf,    
             p_relat.val_nota  
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal = p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_nf_mestre')
         RETURN FALSE
      END IF
      
      LET p_relat.val_seguradora = p_relat.val_nota * p_pct_seguro

      OUTPUT TO REPORT pol1253_relat(p_relat.tip_frete)            
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION      

#--------------------------------#
 FUNCTION pol1253_le_nf_entrada()#
#--------------------------------#

   DECLARE cq_nfe CURSOR FOR
    SELECT cod_fornecedor,
           num_nf,
           dat_emis_nf,
           val_tot_nf_d
      FROM nf_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_conhec = p_relat.num_conhec 
       AND ser_conhec = p_relat.ser_conhec 
       AND ssr_conhec = p_relat.ssr_conhec 

   FOREACH cq_nfe INTO 
      p_relat.cli_fornec,
      p_relat.num_nf,    
      p_relat.dat_nf,    
      p_relat.val_nota  
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_x_nff')
         RETURN FALSE
      END IF
               
      LET p_relat.val_seguradora = p_relat.val_nota * p_pct_seguro

      OUTPUT TO REPORT pol1253_relat(p_relat.tip_frete)            
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION      

#--------------------------------#
 FUNCTION pol1253_le_den_empresa()
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
 FUNCTION pol1253_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1253_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1253.tmp' 
         START REPORT pol1253_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1253_relat TO p_nom_arquivo
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol1253_finaliza_relat()#
#---------------------------------#

   FINISH REPORT pol1253_relat   
   
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

#---------------------------------#
 REPORT pol1253_relat(p_tip_frete)#
#---------------------------------#
    
   DEFINE p_tip_frete CHAR(01)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 088, "RELACAO DE NOTAS FISCAIS PARA A SEGURADORA",
               COLUMN 187, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL1253",
               COLUMN 093, "PERIODO: ", p_dat_ini, " - ", p_dat_fim,
               COLUMN 167, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'EMISSAO NF NUM NF CLIENTE/FORNEC           TRANSPORTADORA              CONHEC   EMISSAO  CIDADE/UF ORIGEM                  CIDADE/UF DESTINO                   VAL NOTA   VAL SEGURO VALIDADE CARTA DDR'
         PRINT COLUMN 001, '---------- ------ --------------- ------------------------------------ ------ ---------- --------------------------------- --------------------------------- ------------ ---------- ------------------'

      PAGE HEADER
	  
         PRINT COLUMN 187, "PAG. ", PAGENO USING "####&"
         PRINT
         PRINT COLUMN 001, 'EMISSAO NF NUM NF CLIENTE/FORNEC           TRANSPORTADORA              CONHEC   EMISSAO  CIDADE/UF ORIGEM                  CIDADE/UF DESTINO                   VAL NOTA   VAL SEGURO VALIDADE CARTA DDR'
         PRINT COLUMN 001, '---------- ------ --------------- ------------------------------------ ------ ---------- --------------------------------- --------------------------------- ------------ ---------- ------------------'
               
      BEFORE GROUP OF p_tip_frete
         
         SKIP TO TOP OF PAGE
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.dat_nf USING 'dd/mm/yyyy',
               COLUMN 012, p_relat.num_nf USING '#####9',
               COLUMN 019, p_relat.cli_fornec,
               COLUMN 035, p_relat.den_transpor,
               COLUMN 072, p_relat.num_conhec USING '#####&',
               COLUMN 079, p_relat.dat_conhec,
               COLUMN 090, p_relat.den_cid_orig CLIPPED,'/',p_relat.est_origem,
               COLUMN 124, p_relat.den_cid_dest CLIPPED,'/',p_relat.est_destino,
               COLUMN 158, p_relat.val_nota USING '#,###,##&.&&',
               COLUMN 171, p_relat.val_seguradora USING '###,##&.&&',
               COLUMN 182, p_relat.dat_ddr
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

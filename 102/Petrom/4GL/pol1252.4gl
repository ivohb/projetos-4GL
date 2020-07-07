#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1252                                                 #
# OBJETIVO: TRANSPORTADORES PARA CONTROLE DE FRETE                  #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 02/06/14                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
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
          p_excluiu            SMALLINT
         
END GLOBALS


DEFINE p_transportador   RECORD LIKE transportador_455.*,
       p_transportadora  RECORD LIKE transportador_455.*

DEFINE p_relat   RECORD
      cod_transpor    CHAR(15),
      den_transpor    CHAR(36),
      cod_cnd_pgto    INTEGER,
      den_cnd_pgto    CHAR(30),
      pct_frete_peso  DECIMAL(5,2), 
      pct_ad_valorem  DECIMAL(5,2), 
      pct_gris        DECIMAL(5,2), 
      val_despacho    DECIMAL(12,2),
      val_tas         DECIMAL(12,2),
      val_trt         DECIMAL(12,2),
      ies_ddr         CHAR(01),
      dat_vencto_ddr  DATE
END RECORD

DEFINE p_den_transpor   CHAR(40),          
       p_den_cnd_pgto   CHAR(30),
       p_cod_transpor   CHAR(15)
       
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1252-10.02.06  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1252_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1252_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1252") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1252 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NUM_ARGS() > 0  THEN
      LET p_cod_transpor = ARG_VAL(1) 
      IF p_cod_transpor IS NOT NULL THEN
         CALL pol1252_consulta() RETURNING p_status
      END IF
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1252_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         LET p_cod_transpor = NULL
         IF pol1252_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1252_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1252_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1252_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1252_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1252_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1252

END FUNCTION

#---------------------------#
FUNCTION pol1252_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1252_inclusao()
#--------------------------#

   CALL pol1252_limpa_tela()
   
   INITIALIZE p_transportador TO NULL
   LET p_transportador.pct_frete_peso = 0
   LET p_transportador.pct_ad_valorem = 0
   LET p_transportador.pct_gris       = 0
   LET p_transportador.val_despacho   = 0
   LET p_transportador.val_tas        = 0
   LET p_transportador.val_trt        = 0

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1252_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1252_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1252_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1252_insere()
#------------------------#

   INSERT INTO transportador_455 VALUES (p_transportador.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","transportador_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1252_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_transportador.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_transpor

         IF p_funcao = "M" THEN
            NEXT FIELD cod_cnd_pgto
         END IF
      
      AFTER FIELD cod_transpor

         IF p_transportador.cod_transpor IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_transpor   
         END IF
         
         SELECT cod_transpor
           FROM transportador_455
          WHERE cod_transpor = p_transportador.cod_transpor
         
         IF STATUS = 0 THEN
            ERROR 'Transportador já cadastrada no pol1252.'
            NEXT FIELD cod_transpor   
         END IF
          
         CALL pol1252_le_nom_transpor(p_transportador.cod_transpor)
          
         IF p_den_transpor IS NULL THEN 
            ERROR 'Transportador inválido.'
            NEXT FIELD cod_transpor
         END IF  
         
         DISPLAY p_den_transpor TO den_transpor

      AFTER FIELD cod_cnd_pgto

         IF p_transportador.cod_cnd_pgto IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cnd_pgto   
         END IF
                   
         CALL pol1252_le_den_cond(p_transportador.cod_cnd_pgto)
          
         IF p_den_cnd_pgto IS NULL THEN 
            ERROR 'Condiçãod de pagamento inválida.'
            NEXT FIELD cod_cnd_pgto
         END IF  
         
         DISPLAY p_den_cnd_pgto TO den_cnd_pgto

      AFTER FIELD ies_ddr

         IF p_transportador.ies_ddr MATCHES '[SN]' THEN 
         ELSE
            ERROR "Informe S ou N para o campo."
            NEXT FIELD ies_ddr   
         END IF
      
      BEFORE FIELD dat_vencto_ddr
      
         IF p_transportador.ies_ddr = 'N' THEN
            LET p_transportador.dat_vencto_ddr = NULL
            DISPLAY ' ' TO dat_vencto_ddr
            EXIT INPUT
         END IF

      ON KEY (control-z)
         CALL pol1252_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_transportador.cod_cnd_pgto IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório."
               NEXT FIELD dat_corte   
            END IF

            IF p_transportador.ies_ddr = 'S' THEN
               IF p_transportador.dat_vencto_ddr IS NULL THEN 
                  ERROR "Campo com preenchimento obrigatório."
                  NEXT FIELD dat_vencto_ddr   
               END IF
            ELSE
               LET p_transportador.dat_vencto_ddr = NULL
               DISPLAY ' ' TO dat_vencto_ddr
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1252_le_nom_transpor(p_cod)#
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
FUNCTION pol1252_le_den_cond(p_cond)#
#-----------------------------------#
   
   DEFINE p_cond INTEGER
   
   SELECT des_cnd_pgto
     INTO p_den_cnd_pgto
     FROM cond_pgto_cap
    WHERE cnd_pgto = p_cond
         
   IF STATUS <> 0 THEN 
      LET p_den_cnd_pgto = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1252_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_transportador.cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(cod_cnd_pgto)
         CALL log009_popup(8,10,"CONDIÇÃO DE PAGAMENTO","cond_pgto_cap",
              "cnd_pgto","des_cnd_pgto","","N"," 1=1 order by des_cnd_pgto") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_transportador.cod_cnd_pgto = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cnd_pgto
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1252_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1252_limpa_tela()
   LET p_transportadora.* = p_transportador.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      transportador_455.cod_transpor     
      BEFORE CONSTRUCT
         DISPLAY p_cod_transpor TO cod_transpor

      ON KEY (control-z)
         CALL pol1252_popup()

   END CONSTRUCT
         
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1252_limpa_tela()
         ELSE
            LET p_transportador.* = p_transportadora.*
            CALL pol1252_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM transportador_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_transpor"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_transportador.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1252_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1252_exibe_dados()
#------------------------------#

   DEFINE p_transpor CHAR(15)
   
   LET p_transpor = p_transportador.cod_transpor
   
   SELECT * 
     INTO p_transportador.*
     FROM transportador_455
    WHERE cod_transpor = p_transportador.cod_transpor
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','transportador_455')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_transportador.*
   
   CALL pol1252_le_nom_transpor(p_transportador.cod_transpor)
   DISPLAY p_den_transpor to den_transpor
   CALL pol1252_le_den_cond(p_transportador.cod_cnd_pgto)
   DISPLAY p_den_cnd_pgto to den_cnd_pgto
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1252_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_transportadora.* = p_transportador.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_transportador.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_transportador.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_transpor
           FROM transportador_455
          WHERE cod_transpor = p_transportador.cod_transpor
            
         IF STATUS = 0 THEN
            IF pol1252_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_transportador.* = p_transportadora.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1252_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_transpor 
      FROM transportador_455  
     WHERE cod_transpor = p_transportador.cod_transpor
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","transportador_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1252_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_transportadora.* = p_transportador.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1252_prende_registro() THEN
      IF pol1252_edita_dados("M") THEN
         IF pol1252_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_transportador.* = p_transportadora.*
      CALL pol1252_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol1252_atualiza()
#--------------------------#

   UPDATE transportador_455
      SET transportador_455.* = p_transportador.*
     WHERE cod_transpor = p_transportador.cod_transpor

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "transportador_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1252_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1252_prende_registro() THEN
      IF pol1252_deleta() THEN
         INITIALIZE p_transportador TO NULL
         CALL pol1252_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#------------------------#
FUNCTION pol1252_deleta()
#------------------------#

   DELETE FROM transportador_455
    WHERE cod_transpor = p_transportador.cod_transpor

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","transportador_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1252_listagem()
#--------------------------#     

   IF NOT pol1252_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1252_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.cod_transpor, 
           b.raz_social,
           a.cod_cnd_pgto,
           c.des_cnd_pgto,
           a.pct_peso_frete,
           a.ies_ddr,
           a.dat_vencto_ddr
      FROM transportador_455 a, fornecedor b, cond_pgto_cap c
     WHERE a.cod_transpor = b.cod_fornecedor
       AND a.cod_cnd_pgto = c.cnd_pgto
     ORDER BY a.cod_transpor
  
   FOREACH cq_impressao 
      INTO p_relat.cod_transpor,
           p_relat.den_transpor,
           p_relat.cod_cnd_pgto,
           p_relat.den_cnd_pgto,
           p_relat.pct_frete_peso,
           p_relat.pct_ad_valorem,
           p_relat.pct_gris,      
           p_relat.val_despacho,  
           p_relat.val_tas,       
           p_relat.val_trt,       
           p_relat.ies_ddr,
           p_relat.dat_vencto_ddr
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      OUTPUT TO REPORT pol1252_relat() 

      LET p_count = 1
      
   END FOREACH

   CALL pol1252_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1252_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1252_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1252.tmp'
         START REPORT pol1252_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1252_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1252_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1252_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1252_relat   

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
 REPORT pol1252_relat()
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
               
         PRINT COLUMN 001, "pol1252",
               COLUMN 010, "PARAMETROS P/ CONTROLE DE FRETE",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADOR   COND PGTO FRT PESO VALOREM GRIS  V.DESPACHO  VAL TAS    VAL TRT   DDR DT V DDR'                                
         PRINT COLUMN 001, '--------------- --------- -------- ------- ----- ---------- ---------- ---------- --- ----------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADOR   COND PGTO FRT PESO VALOREM GRIS  V.DESPACHO  VAL TAS    VAL TRT   DDR DT V DDR'                                
         PRINT COLUMN 001, '--------------- --------- -------- ------- ----- ---------- ---------- ---------- --- ----------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_transpor,
               COLUMN 017, p_relat.cod_cnd_pgto USING '########&',
               COLUMN 029, p_relat.pct_frete_peso USING '#&.&&',
               COLUMN 037, p_relat.pct_ad_valorem USING '#&.&&',
               COLUMN 044, p_relat.pct_gris USING '#&.&&', 
               COLUMN 050, p_relat.val_despacho USING '###,##&.&&',
               COLUMN 061, p_relat.val_tas USING '###,##&.&&',
               COLUMN 072, p_relat.val_trt USING '###,##&.&&',       
               COLUMN 084, p_relat.ies_ddr,       
               COLUMN 087, p_relat.dat_vencto_ddr
                              
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

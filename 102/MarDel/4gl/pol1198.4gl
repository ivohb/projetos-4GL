#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1198                                                 #
# OBJETIVO: UNIDADES DE MEDIDA P/ EDI VW                            #
# AUTOR...: IVO BL                                                  #
# DATA....: 16/05/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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
          p_last_row           SMALLINT,
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100),
          p_msg                CHAR(300)
  
   DEFINE p_unimed_edi_vw_5054    RECORD LIKE unimed_edi_vw_5054.*
      
   DEFINE p_cod_uni_med        LIKE unimed_edi_vw_5054.cod_uni_med,
          P_cod_uni_med_ant    LIKE unimed_edi_vw_5054.cod_uni_med
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1198-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1198_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1198_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1198") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1198 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1198_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1198_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            CALL pol1198_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1198_consulta() RETURNING p_status
         IF p_status THEN
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Seguinte" 
            ELSE
               CALL pol1198_limpa_tela()
               ERROR 'Argumentos de pesquisa não encontrados !!!'
            END IF 
         ELSE
            CALL pol1198_limpa_tela()
            ERROR 'Operação cancelada!!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1198_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1198_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1198_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
        IF p_ies_cons THEN
           CALL pol1198_exclusao() RETURNING p_retorno
           IF p_retorno THEN
              ERROR 'Exclusão efetuada com sucesso !!!'
           ELSE
              ERROR 'Operação cancelada !!!'
           END IF
        ELSE
           ERROR "Consulte previamente para fazer a exclusão !!!"
        END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1198_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1198_sobre()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1198_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1198

END FUNCTION

#-----------------------#
 FUNCTION pol1198_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1198_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1198_inclusao()
#--------------------------#

   CALL pol1198_limpa_tela()
   INITIALIZE P_unimed_edi_vw_5054.* TO NULL
   
   IF pol1198_edita_dados("I") THEN
      INSERT INTO unimed_edi_vw_5054
       VALUES(p_unimed_edi_vw_5054.*)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Inserindo", "unimed_edi_vw_5054")   
      ELSE         
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1198_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME P_unimed_edi_vw_5054.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_uni_med
      IF p_funcao = 'M' THEN
         NEXT FIELD des_uni_med
      END IF
      
      AFTER FIELD cod_uni_med
      IF P_unimed_edi_vw_5054.cod_uni_med IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_uni_med   
      END IF
      
      SELECT cod_uni_med
        FROM unimed_edi_vw_5054
       WHERE cod_uni_med = P_unimed_edi_vw_5054.cod_uni_med
       
      IF STATUS = 0 THEN
         ERROR "Unidade de medida já cadastrada !!!"
         NEXT FIELD cod_uni_med
      END IF
                 
      AFTER FIELD des_uni_med
      IF P_unimed_edi_vw_5054.des_uni_med IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD des_uni_med   
      END IF
            
{      ON KEY (control-z)
         CALL pol1198_popup() }
       
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

{
#-----------------------#
 FUNCTION pol1198_popup()
#-----------------------#

    DEFINE p_codigo CHAR(15)
 
    CASE
       WHEN INFIELD(cod_uni_med)
         CALL log009_popup(8,10,"UNIDADES","unid_med",
                     "cod_unid_med","den_unid_med_30","","N","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         current WINDOW is w_pol1198
         IF p_codigo IS NOT NULL THEN
            LET P_unimed_edi_vw_5054.cod_uni_med = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_uni_med
         END IF
    END CASE 
    
END FUNCTION         
}
#--------------------------#
 FUNCTION pol1198_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1198_limpa_tela()
   
   LET p_cod_uni_med_ant = p_cod_uni_med
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      unimed_edi_vw_5054.cod_uni_med,
      unimed_edi_vw_5054.des_uni_med
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_uni_med = p_cod_uni_med_ant   
         CALL pol1198_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1198_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT cod_uni_med ",
                  "  FROM unimed_edi_vw_5054 ",
                  " WHERE ", where_clause CLIPPED,
                  " order by cod_uni_med "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_uni_med

   IF STATUS = 0 THEN
      IF pol1198_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('Lendo','unimed_edi_vw_5054')
      END IF
   END IF

   CALL pol1198_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1198_exibe_dados()
#------------------------------#
  
  SELECT des_uni_med 
    INTO p_unimed_edi_vw_5054.des_uni_med
    FROM unimed_edi_vw_5054
   WHERE cod_uni_med = p_cod_uni_med
   
  IF STATUS <> 0 THEN 
     RETURN FALSE 
  END IF  
  
  DISPLAY p_cod_uni_med                 TO cod_uni_med
  DISPLAY p_unimed_edi_vw_5054.des_uni_med TO des_uni_med
 
  RETURN TRUE
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol1198_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_uni_med_ant = p_cod_uni_med

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_uni_med
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_uni_med
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_uni_med = p_cod_uni_med_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol1198_exibe_dados() THEN
         EXIT WHILE
      END IF
       
    END WHILE

END FUNCTION


#----------------------------------#
 FUNCTION pol1198_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_uni_med 
      FROM unimed_edi_vw_5054  
     WHERE cod_uni_med = p_cod_uni_med
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","unimed_edi_vw_5054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1198_modificacao()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   LET p_retorno = FALSE
   LET P_unimed_edi_vw_5054.cod_uni_med = P_cod_uni_med
   
   IF pol1198_prende_registro() THEN
      IF pol1198_edita_dados("M") THEN
         UPDATE unimed_edi_vw_5054
            SET des_uni_med = P_unimed_edi_vw_5054.des_uni_med
          WHERE cod_uni_med = P_cod_uni_med

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","unimed_edi_vw_5054")
         END IF
      ELSE
         CALL pol1198_exibe_dados() RETURNING p_status
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

#--------------------------#
 FUNCTION pol1198_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1198_prende_registro() THEN
      DELETE FROM unimed_edi_vw_5054
			 WHERE cod_uni_med = p_cod_uni_med
    		
      IF STATUS = 0 THEN               
         INITIALIZE P_unimed_edi_vw_5054 TO NULL
         CALL pol1198_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","unimed_edi_vw_5054")
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

#-------------------------#
FUNCTION pol1198_listagem()
#-------------------------#     

   IF NOT pol1198_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1198_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT cod_uni_med,
           des_uni_med
      FROM unimed_edi_vw_5054
     ORDER BY cod_uni_med
   
   FOREACH cq_impressao INTO 
           P_unimed_edi_vw_5054.cod_uni_med,
           P_unimed_edi_vw_5054.des_uni_med

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','unimed_edi_vw_5054')
         EXIT FOREACH
      END IF      
               
      OUTPUT TO REPORT pol1198_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1198_relat   
   
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

#------------------------------#
FUNCTION pol1198_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1198.tmp"
         START REPORT pol1198_relat TO p_caminho
      ELSE
         START REPORT pol1198_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1198_le_empresa()
#---------------------------#

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
 REPORT pol1198_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1198",
               COLUMN 023, "UNIDADES DE MEDIDA",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '                     Código       Descrição'
         PRINT COLUMN 002, '                     ------ -------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 023, P_unimed_edi_vw_5054.cod_uni_med,
               COLUMN 030, P_unimed_edi_vw_5054.des_uni_med
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1198_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.01 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
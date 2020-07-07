#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1037                                                 #
# OBJETIVO: ACERTO DAS CONTAS CONTÁBEIS                             #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 07/05/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
   
   DEFINE p_tela               RECORD
          ano                  CHAR(04),
          mes                  CHAR(02)
   END RECORD 
         
   DEFINE p_den_mes            CHAR(09) 
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1037-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1037_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1037_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1037") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1037 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1037_limpa_tela()
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados á serem processados"
         CALL pol1037_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Parâmetros informados com sucesso !!!'
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Processar" "Processa dados já informados"
         IF p_ies_cons = TRUE THEN 
            IF pol1037_processar() THEN
               LET p_ies_cons = FALSE
               ERROR 'Processamento efetuado com sucesso !!!'
            ELSE
               ERROR 'Operação cancela !!!'
            END IF
         ELSE
            ERROR "Informe os dados previamente !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1037_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1037

END FUNCTION

#-----------------------#
FUNCTION pol1037_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1037_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION  

#--------------------------#
 FUNCTION pol1037_informar()
#--------------------------#
   
   LET INT_FLAG = FALSE 
   CALL pol1037_limpa_tela()
   INITIALIZE p_tela.* TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
              
      AFTER FIELD ano
      IF p_tela.ano IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD ano   
      END IF
          
      IF p_tela.ano < 1899 THEN 
         ERROR "Valor ilegal para o campo em quetão !!!"
         NEXT FIELD ano
      END IF   
      
      AFTER FIELD mes
      IF p_tela.mes IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD mes   
      END IF
      
      IF p_tela.mes < 1  OR
         p_tela.mes > 12 THEN
         ERROR "Valor ilegal para o campo em quetão !!!"
         NEXT FIELD mes   
      END IF
      
      CALL pol1037_checa_mes()
          
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1037_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1037_checa_mes()
#---------------------------#

   CASE 
      
      WHEN p_tela.mes = 1
         LET p_den_mes = "JANEIRO"
      
      WHEN p_tela.mes = 2
         LET p_den_mes = "FEVEREIRO"
         
      WHEN p_tela.mes = 3
         LET p_den_mes = "MARÇO"
         
      WHEN p_tela.mes = 4
         LET p_den_mes = "ABRIL"
         
      WHEN p_tela.mes = 5
         LET p_den_mes = "MAIO"
         
      WHEN p_tela.mes = 6
         LET p_den_mes = "JUNHO"
         
      WHEN p_tela.mes = 7
         LET p_den_mes = "JULHO"
         
      WHEN p_tela.mes = 8
         LET p_den_mes = "AGOSTO"
         
      WHEN p_tela.mes = 9
         LET p_den_mes = "SETEMBRO"
         
      WHEN p_tela.mes = 10
         LET p_den_mes = "OUTUBRO"
         
      WHEN p_tela.mes = 11
         LET p_den_mes = "NOVEMBRO"
         
      WHEN p_tela.mes = 12
         LET p_den_mes = "DEZEMBRO"
         
   END CASE 
   
   DISPLAY p_den_mes TO den_mes
   
END FUNCTION 
  
#---------------------------#
 FUNCTION pol1037_processar()
#---------------------------#
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   UPDATE ctb_lanc_ctbl_ctb
      SET cta_deb        = num_cta_certa
    WHERE empresa        = p_cod_empresa
      AND periodo_contab = p_tela.ano
      AND segmto_periodo = p_tela.mes
      AND cta_deb        IN (SELECT num_cta_errada FROM troca_conta_912)
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Modificando", "ctb_lanc_ctbl_ctb")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   UPDATE ctb_lanc_ctbl_ctb
      SET cta_cre        = num_cta_certa
    WHERE empresa        = p_cod_empresa
      AND periodo_contab = p_tela.ano
      AND segmto_periodo = p_tela.mes
      AND cta_cre        IN (SELECT num_cta_errada FROM troca_conta_912)          
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Modificando", "ctb_lanc_ctbl_ctb_2")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
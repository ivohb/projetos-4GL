#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1167                                                 #
# OBJETIVO: TEXTO DA OPERA��O DO ITEM                               #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 21/09/12                                                #
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
          p_last_row           SMALLINT
          
   DEFINE p_seq_processo       LIKE man_processo_item.seq_processo,
          p_opcao              CHAR(01),
          p_cod_operac         CHAR(05),
          p_den_operac         CHAR(30)

   DEFINE pr_txt               ARRAY[99] of RECORD
          num_seq              INTEGER,
          tex_processo         CHAR(70)
   END RECORD          
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1167-12.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1167_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1167_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1167") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1167 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1167_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol1167_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1167

END FUNCTION

#-----------------------#
 FUNCTION pol1167_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol1167_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_txt TO NULL
   INITIALIZE p_cod_operac TO NULL
   LET p_opcao = 'I'
   
   IF pol1167_edita_dados() THEN      
      IF pol1167_edita_txt('I') THEN      
         CALL log085_transacao("BEGIN")
         IF pol1167_grava_dados() THEN  
            CALL log085_transacao("COMMIT")                                                   
            RETURN TRUE                                                                    
         END IF  
         CALL log085_transacao("ROLLBACK")                                                                    
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1167_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_cod_operac WITHOUT DEFAULTS
    FROM cod_operac
            
      AFTER FIELD cod_operac
      IF p_cod_operac IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_operac   
      END IF
                            
      SELECT den_operac
        INTO p_den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac = p_cod_operac
       
      IF STATUS = 100 THEN
         LET p_msg = "Opera��o n�o cadastrado !!!"
         CALL log0030_mensagem(p_msg,'exclamation')
         NEXT FIELD cod_operac
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','operacao')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY p_den_operac TO den_operac
      
      LET p_count = 0
      
      SELECT COUNT(operacao)
        INTO p_count
        FROM man_processo_item
       WHERE empresa = p_cod_empresa
         AND operacao = p_cod_operac
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','consumo')
         RETURN FALSE
      END IF 
  
      IF p_count = 0 THEN
         LET p_msg = "Essa opera��o n�o est� relacionada a um item"
         CALL log0030_mensagem(p_msg,'exclamation')
         NEXT FIELD cod_operac
      END IF
      
      ON KEY (control-z)
         CALL pol1167_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1167_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_operac)
         CALL log009_popup(8,10,"OPERA��ES","operacao",
              "cod_operac","den_operac","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cod_operac = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_operac
         END IF

   END CASE 

END FUNCTION 

#-------------------------------------#
 FUNCTION pol1167_edita_txt(p_funcao)
#-------------------------------------#     

   DEFINE p_funcao CHAR(01)
   
   INPUT ARRAY pr_txt
      WITHOUT DEFAULTS FROM sr_txt.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      AFTER FIELD tex_processo

      AFTER ROW
         IF NOT INT_FLAG THEN                                    
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN    
            ELSE
               IF pr_txt[p_index].tex_processo IS NULL THEN
                  ERROR 'Campo com preenchimento obrigat�rio !!!'
                  NEXT FIELD tex_processo
               END IF
               CALL pol1167_refaz_seqeuncia()
            END IF
         END IF

      AFTER DELETE
         CALL pol1167_refaz_seqeuncia()

      AFTER INSERT
         CALL pol1167_refaz_seqeuncia()
            
      AFTER INPUT
         IF NOT INT_FLAG THEN                                    
            FOR p_ind = 1 TO ARR_COUNT()
               IF pr_txt[p_ind].tex_processo IS NULL AND pr_txt[p_ind].num_seq IS NOT NULL THEN
                  LET p_msg = 'Uma ou mais seq�ncia est� sem\n o texto correspondente !!!'
                  CALL log0030_mensagem(p_msg, 'exclamation')
                  NEXT FIELD tex_processo
               END IF
            END FOR
            LET p_ind = p_ind - 1
         END IF

   END INPUT 

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
         
END FUNCTION

#---------------------------------#
FUNCTION pol1167_refaz_seqeuncia()#
#---------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_txt[p_ind].tex_processo IS NOT NULL THEN
          LET pr_txt[p_ind].num_seq = p_ind
          DISPLAY p_ind TO sr_txt[p_ind].num_seq
       END IF
   END FOR

END FUNCTION

#-----------------------------#
 FUNCTION pol1167_grava_dados()
#-----------------------------#

   DECLARE cq_consu CURSOR FOR
   SELECT DISTINCT
          seq_processo
     FROM man_processo_item
    WHERE empresa = p_cod_empresa
      AND operacao  = p_cod_operac
   
   FOREACH cq_consu INTO p_seq_processo
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','CONSUMO')
         RETURN FALSE
      END IF
      
      SELECT MAX(seq_texto_processo)
        INTO p_num_seq
        FROM man_texto_processo
       WHERE empresa  = p_cod_empresa
         AND seq_processo = p_seq_processo
         AND tip_texto = 'G'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','CONSUMO_TXT')
         RETURN FALSE
      END IF
      
      IF p_num_seq IS NULL THEN
         LET p_num_seq = 0
      END IF
      
      FOR p_index = 1 TO p_ind
          IF pr_txt[p_index].tex_processo IS NOT NULL THEN
             LET p_num_seq = p_num_seq + 1
             INSERT INTO man_texto_processo
              VALUES(p_cod_empresa,
                     p_seq_processo,
                     'G',
                     p_num_seq,
                     pr_txt[p_index].tex_processo)
             IF STATUS <> 0 THEN
                CALL log003_err_sql('Inserindo','consumo_txt')
                RETURN FALSE
             END IF
          END IF        
      END FOR
                     
   END FOREACH
      
   RETURN TRUE
      
END FUNCTION

#-------FIM DO PROGRAMA BL-----------#
{ALTERA�OES


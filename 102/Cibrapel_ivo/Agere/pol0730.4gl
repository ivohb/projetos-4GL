#-------------------------------------------------------------------#
# PROGRAMA: pol0730                                                 #
# OBJETIVO: MECANISMO DE ENTRADA DA NOTA FISCAL                     #
# CLIENTE.: CIBRAPEL                                                #
# DATA....: 27/01/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(70),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT

  
   DEFINE p_cod_item          LIKE item.cod_item

   DEFINE p_tela         RECORD
          num_aviso_rec  LIKE nf_sup.num_aviso_rec,
          nf             LIKE nf_sup.num_nf,
          ser_nf         LIKE nf_sup.ser_nf,
          ssr_nf         LIKE nf_sup.ssr_nf,
          dat_nf         LIKE nf_sup.dat_emis_nf,
          dat_ini        LIKE nf_sup.dat_emis_nf,
          dat_fim        LIKE nf_sup.dat_emis_nf,
          cod_fornecedor LIKE fornecedor.cod_fornecedor,
          raz_social     LIKE fornecedor.raz_social
   END RECORD 

   DEFINE pr_item             ARRAY[500] OF RECORD
          cod_item            LIKE item.cod_item,
          tip_item            LIKE item.ies_tip_item,
          den_item            LIKE item.den_item
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0730-05.10.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0730_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0730_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0730") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0730 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol0730_limpa_tela()
   
   MENU "OPCAO"
    COMMAND "Informar" "Informa parâmetros p/ a pesquisa"
       CALL pol0730_informar() RETURNING p_status
       IF p_status THEN      
          ERROR 'Parâmetros infomados com sucesso !!!'
          LET p_ies_cons = TRUE
          NEXT OPTION 'Exibir'
       ELSE
          ERROR 'Operação cancelada !!!'
          LET p_ies_cons = FALSE
          NEXT OPTION 'Fim'
       END IF
    COMMAND "Exibir" "Exibe o mecanismo de entrada da Nota Fiscal"
       IF p_ies_cons THEN
          IF log004_confirm(18,35) THEN
             MESSAGE 'AGUARDE!... PROCESSANDO.'
#             CALL pol0730_exibir() RETURNING p_status
             IF p_status THEN      
                ERROR 'Processamento efetuado com sucesso !!!'
             ELSE 
                ERROR 'Operação cancelada !!!'
             END IF
             LET p_ies_cons = FALSE
             CALL pol0730_limpa_tela()
             NEXT OPTION 'Fim'
          END IF
       ELSE
          ERROR 'Informe previamente os parâmetros!!!'
          NEXT OPTION 'Informar'
       END IF
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0730

END FUNCTION

#----------------------------#
FUNCTION pol0730_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol0730_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE
   CALL pol0730_limpa_tela()
    
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD num_aviso_rec
         IF p_tela.num_aviso_rec IS NOT NULL THEN
            IF NOT pol0730_le_nf_sup() THEN
               ERROR p_msg
               NEXT FIELD num_aviso_rec
            END IF
            CALL pol0730_exibe_nf()
            EXIT INPUT
         END IF

      AFTER FIELD dat_ini    
         IF p_tela.dat_ini IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD dat_ini       
         END IF 

         AFTER FIELD dat_fim   
         IF p_tela.dat_fim IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD dat_fim
         ELSE
            IF p_tela.dat_ini > p_tela.dat_fim THEN
               ERROR "Data Inicial nao pode ser maior que data Final"
               NEXT FIELD dat_ini
            END IF 
            IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
               ERROR "Periodo nao pode ser maior que 720 Dias"
               NEXT FIELD dat_ini
            END IF 
         END IF 
      
      AFTER FIELD cod_fornecedor
         INITIALIZE p_tela.raz_social TO NULL
         IF p_tela.cod_fornecedor IS NOT NULL THEN
            SELECT raz_social
              INTO p_tela.raz_social
              FROM fornecedor
             WHERE cod_fornecedor = p_tela.cod_fornecedor
            IF STATUS <> 0 THEN
               ERROR 'Fornecedor Inexistente !!!'
               NEXT FIELD cod_fornecedor
            END IF
         END IF
      
         DISPLAY p_tela.raz_social TO raz_social

      ON KEY (control-z)
         CALL pol0730_popup()

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0730_le_nf_sup()
#---------------------------#

   SELECT num_nf,
          ser_nf,
          ssr_nf,
          dat_emis_nf,
          cod_fornecedor
     INTO p_tela.nf,
          p_tela.ser_nf,
          p_tela.ssr_nf,
          p_tela.dat_nf,
          p_tela.cod_fornecedor
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE            
      IF STATUS = 100 THEN
         LET p_msg = 'AR INEXISTENTE!... '
      ELSE
         CALL log003_err_sql('Lendo','NF_SUP')
      END IF
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0730_exibe_nf()
#--------------------------#

   CALL pol0730_le_fornec() RETURNING p_status

   DISPLAY p_tela.nf TO nf
   DISPLAY p_tela.ser_nf TO ser_nf
   DISPLAY p_tela.ssr_nf TO ssr_nf
   DISPLAY p_tela.dat_nf TO dat_nf
   DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
   DISPLAY p_tela.raz_social TO raz_social

END FUNCTION

#---------------------------#
FUNCTION pol0730_le_fornec()
#---------------------------#

   SELECT raz_social
     INTO p_tela.raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor
   
   IF STATUS <> 0 THEN
      LET p_tela.raz_social = 'ERRO lendo fornec'
      CALL log003_err_sql('Lendo','Fornecedor')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0730_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0730
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

   END CASE
   
END FUNCTION

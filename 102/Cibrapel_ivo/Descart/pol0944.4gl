#-------------------------------------------------------------------#
# PROGRAMA: pol0944                                                 #
# OBJETIVO: CONSULTA DE MOVIMENTOS COPIADOS PELO POL0665            #
# CLIENTE.: CIBRAPEL                                                #
# DATA....: 10/06/2009                                              #
# POR.....: WILLIANS                                                #
# ALTERACÃO MOTIVO                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
        	p_den_empresa        LIKE empresa.den_empresa,
        	p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
        	p_user               LIKE usuario.nom_usuario,
        	p_id_ajust           INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_msg                CHAR(150),
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
          p_ies_cons           SMALLINT,
          p_tip_ajust          CHAR(01),
          p_tem_lote           SMALLINT,
          p_num_processo       INTEGER,
          p_cod_status         CHAR(01),
          p_ies_info           SMALLINT

   
   DEFINE p_tela               RECORD
          num_aviso_rec        LIKE aviso_rec.num_aviso_rec,
          num_nf               LIKE nf_sup.num_nf,
          cod_fornecedor       LIKE nf_sup.cod_fornecedor
   END RECORD 
   
   DEFINE p_num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          p_num_nf             LIKE nf_sup.num_nf,
          p_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          p_raz_social         LIKE fornecedor.raz_social
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0944-05.10.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0944_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0944_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0944") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0944 AT 2,2 WITH FORM p_nom_tela 
    ATTRIBUTES(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol0944_le_empresa_ofic() THEN
      RETURN
   END IF
   
   CALL pol0944_limpa_tela()
   LET p_ies_info = FALSE 

   MENU "OPCAO"
      COMMAND "Informar" "Informa os parâmetros para a consulta"
         CALL pol0944_limpa_tela()
         CALL pol0944_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados com sucesso !!!"
            LET p_ies_info = TRUE
            NEXT OPTION 'Consultar'
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_info = FALSE
         END IF 
      COMMAND "Consultar" "Consulta dos dados já informados com sucesso"
         IF p_ies_info THEN
           # CALL pol0944_consultar() RETURNING p_status
            IF p_status THEN
               ERROR "Consulta efetuada com sucesso !!!"   
               LET p_ies_info = FALSE
            ELSE
               ERROR 'Operação canceada!!!'
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!!!'
            NEXT OPTION "Informar"
         END IF 
         NEXT OPTION "Fim" 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0944

END FUNCTION

#---------------------------------#
 FUNCTION pol0944_le_empresa_ofic()
#---------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
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
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#--------------------------#
FUNCTION pol0944_informar()
#--------------------------#
   
   INITIALIZE p_tela TO NULL
   

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_aviso_rec
         IF p_tela.num_aviso_rec IS NULL THEN
            NEXT FIELD num_nf
         END IF

         SELECT num_nf,
                dat_emis_nf,
                cod_fornecedor
           INTO p_tela.num_nf,
                p_dat_emis_nf,
                p_tela.cod_fornecedor
           FROM nf_sup
          WHERE cod_empresa    = p_cod_empresa
            AND num_aviso_rec  = p_tela.num_aviso_rec

         IF STATUS = 100 THEN
            ERROR 'AR não encontrado!!!'
            NEXT FIELD num_aviso_rec
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'nf_sup')
               NEXT FIELD num_aviso_rec
            END IF 
         END IF
         
         SELECT raz_social
           INTO p_raz_social
           FROM fornecedor
          WHERE cod_fornecedor = p_tela.cod_fornecedor
           
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'fornecedor')
         END IF 
         
         DISPLAY p_tela.num_nf         TO num_nf
         DISPLAY p_dat_emis_nf         TO dat_emis_nf
         DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
         DISPLAY p_raz_social          TO raz_social
         
         IF NOT pol0944_ve_possibilidade() THEN 
            NEXT FIELD num_aviso_rec
         END IF
         
         EXIT INPUT
         
         AFTER FIELD num_nf
            IF p_tela.num_nf IS NULL THEN 
               NEXT FIELD num_aviso_rec
            END IF 
            
         AFTER FIELD cod_fornecedor
            IF p_tela.cod_fornecedor IS NULL THEN 
               ERROR "Campo com prenchimento obrigatório!!!"
               NEXT FIELD cod_fornecedor
            END IF 
         
            SELECT num_aviso_rec,
                   dat_emis_nf
              INTO p_tela.num_aviso_rec,
                   p_dat_emis_nf
              FROM nf_sup
             WHERE cod_empresa    = p_cod_empresa
               AND num_nf         = p_tela.num_nf
               AND cod_fornecedor = p_tela.cod_fornecedor
            
            IF STATUS = 100 THEN
               ERROR 'NF não encontrada ou não é do fornecedor informado!!!'
               NEXT FIELD num_nf
            ELSE 
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql('lendo', 'nf_sup')
                  NEXT FIELD cod_fornecedor
               END IF 
            END IF
         
            SELECT raz_social
              INTO p_raz_social
              FROM fornecedor
             WHERE cod_fornecedor = p_tela.cod_fornecedor
            
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'fornecedor')
            END IF 
         
            DISPLAY p_tela.num_aviso_rec  TO num_aviso_rec
            DISPLAY p_dat_emis_nf         TO dat_emis_nf
            DISPLAY p_raz_social          TO raz_social
            
            IF NOT pol0944_ve_possibilidade() THEN 
               NEXT FIELD num_nf
            END IF 
            
   ON KEY (control-z)
      CALL pol0944_popup()
   
   END INPUT

   IF INT_FLAG THEN
      
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0944_ve_possibilidade()
#----------------------------------#

   SELECT num_aviso_rec
     FROM ar_proces_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      
   IF STATUS = 100 THEN 
      ERROR "Ar não copiado !!!"
      RETURN FALSE 
   ELSE 
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','ar_proces_885')
         RETURN FALSE 
      END IF 
   END IF 
   
   RETURN TRUE 
   
END FUNCTION

#----------------------------#
 FUNCTION pol0944_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0944_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0944
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_fornecedor = p_codigo CLIPPED
            DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
         END IF

   END CASE
   

END FUNCTION


  
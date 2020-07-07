#-----------------------------------------------------------------#
# PROGRAMA: pol0842                                               #
# OBJETIVO: SOLICITACAO DE MATERIAL DEBITO DIRETO - ESPECIFICOS   #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_reg_saida_dd_885     RECORD LIKE reg_saida_dd_885.*,
          p_reg_saida_dd_885     RECORD LIKE reg_saida_dd_885.*,
          p_audit_ar_dd_885      RECORD LIKE audit_ar_dd_885.*

   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_qtd_saldo        LIKE aviso_rec.qtd_declarad_nf,
          p_nom_aprovante    LIKE reg_saida_dd_885.nom_aprovante,
          p_den_obs1         LIKE reg_saida_dd_885.den_obs1,
          p_ies_cons         SMALLINT,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          pa_curr1           SMALLINT,
          sc_curr1           SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT,
          p_den_item         CHAR(67), 
          p_cod_usuario      CHAR(08),
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_mensag           CHAR(200),
          z_i                SMALLINT,
          w_i                SMALLINT,
          p_i                SMALLINT,
          p_msg              CHAR(100)

   DEFINE t_devolv ARRAY[500] OF RECORD
      num_solicit      LIKE aviso_rec.num_seq,
      nom_solicit      LIKE reg_saida_dd_885.nom_solicit,
      den_item         LIKE reg_saida_dd_885.den_item,
      qtd_retirada     LIKE reg_saida_dd_885.qtd_retirada,
      qtd_devolvida    LIKE reg_saida_dd_885.qtd_retirada  
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "pol0842-10.02.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0842_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0842_controle()
#--------------------------#
 DEFINE l_count INTEGER

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0842") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0842 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Entrada de dados"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0842","CO") THEN 
            IF pol0842_entrada_dados() THEN
               IF p_ies_cons THEN 
                  NEXT OPTION "Informa"
               END IF
            ELSE
               ERROR "Processo cancelado"
            END IF    
         END IF
      COMMAND "Informa" "Informa qtantidade entregue"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0842","MO") THEN 
            IF p_ies_cons THEN 
               IF pol0842_informa_devolucao() THEN 
                  CALL pol0842_processa()
                  IF p_houve_erro THEN
                     ERROR "Processamento Cancelado " 
                     NEXT OPTION "Consultar"
                  ELSE  
                     COMMIT WORK
                     ERROR "Liberacao efetuada com sucesso " 
                     NEXT OPTION "Informar"
                  END IF
               ELSE
                  ERROR "Processamento Cancelado " 
                  NEXT OPTION "Consultar"               
               END IF    
            ELSE
               ERROR "Informe os dados antes de Processar"
               NEXT OPTION "Consultar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0842_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0842

END FUNCTION

#-------------------------------#
 FUNCTION pol0842_entrada_dados()
#-------------------------------#
   INITIALIZE  p_reg_saida_dd_885.*,
               t_devolv            TO NULL
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0842

   LET INT_FLAG = FALSE  
   INPUT p_reg_saida_dd_885.nom_solicit,
         p_reg_saida_dd_885.den_item,
         p_reg_saida_dd_885.den_obs1
   WITHOUT DEFAULTS  
    FROM nom_solicit,
         den_item,
         den_obs1  

    AFTER FIELD den_obs1
       IF p_reg_saida_dd_885.den_obs1 IS NULL THEN     
          ERROR 'INFORME MOTIVO DA DEVOLUCAO'
          NEXT FIELD den_obs1
       ELSE
          LET p_den_obs1 = p_reg_saida_dd_885.den_obs1
          CALL pol0842_carrega_tela()
       END IF 
          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0842
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE 
   END IF
 
END FUNCTION

#-----------------------------#
FUNCTION pol0842_carrega_tela()
#-----------------------------#
 DEFINE sql_stmt, 
        where_clause   CHAR(300)
        
 LET p_i =  1

 IF p_reg_saida_dd_885.nom_solicit IS NOT NULL  THEN
    LET where_clause = "nom_solicit LIKE '%",p_reg_saida_dd_885.nom_solicit CLIPPED,"%" 
    IF p_reg_saida_dd_885.den_item IS NOT NULL THEN 
       LET where_clause = where_clause CLIPPED," AND den_item LIKE '%",p_reg_saida_dd_885.den_item CLIPPED,"%" 
    END IF    
 ELSE
    IF p_reg_saida_dd_885.den_item IS NOT NULL THEN 
       LET where_clause = "den_item LIKE '%",p_reg_saida_dd_885.den_item CLIPPED,"%" 
    ELSE
       LET where_clause = "1 = 1" 
    END IF   
 END IF 


 LET sql_stmt = "SELECT * FROM reg_saida_dd_885 ",
                " WHERE ", where_clause CLIPPED,"'", 
                " AND cod_empresa = '", p_cod_empresa,"'",
                " ORDER BY num_solicit DESC"

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao CURSOR FOR var_query
 FOREACH cq_padrao INTO p_reg_saida_dd_885.*
    LET t_devolv[p_i].num_solicit    = p_reg_saida_dd_885.num_solicit
    LET t_devolv[p_i].nom_solicit    = p_reg_saida_dd_885.nom_solicit 
    LET t_devolv[p_i].den_item       = p_reg_saida_dd_885.den_item    
    LET t_devolv[p_i].qtd_retirada   = p_reg_saida_dd_885.qtd_retirada 
    LET t_devolv[p_i].qtd_devolvida  = 0  
    LET p_i = p_i + 1
 END FOREACH       

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_devolv TO s_devolv.*
   END DISPLAY

END FUNCTION


#----------------------------------#
FUNCTION pol0842_informa_devolucao()
#----------------------------------#
  CALL log006_exibe_teclas("01", p_versao)

   INPUT ARRAY t_devolv WITHOUT DEFAULTS FROM s_devolv.*

      BEFORE FIELD qtd_devolvida   
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD qtd_devolvida  
        IF t_devolv[pa_curr].qtd_devolvida > t_devolv[pa_curr].qtd_retirada THEN
           ERROR 'Qtde entregue nao pode ser maior que solicitada'
           NEXT FIELD qtd_devolvida 
        END IF 

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_devolv[pa_curr+1].num_solicit IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD ies_liber
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN FALSE
   ELSE
      RETURN TRUE   
   END IF

END FUNCTION

#---------------------------#
 FUNCTION pol0842_processa()
#---------------------------#
DEFINE l_qtd_devolv   DECIMAL(12,3)
   LET p_houve_erro = FALSE
   BEGIN WORK

   FOR w_i = 1  TO 500 

      IF t_devolv[w_i].num_solicit IS NULL THEN
         EXIT FOR 
      END IF
      
      IF t_devolv[w_i].qtd_devolvida > 0 THEN 
         SELECT * 
           INTO p_reg_saida_dd_885.*
           FROM reg_saida_dd_885  
             WHERE cod_empresa = p_cod_empresa 
               AND num_solicit = t_devolv[w_i].num_solicit                         
         
         UPDATE saldo_ar_dd_885 
            SET qtd_retirada = qtd_retirada - t_devolv[w_i].qtd_devolvida
          WHERE cod_empresa = p_cod_empresa 
            AND num_ar      = p_reg_saida_dd_885.num_ar
            AND num_seq     = p_reg_saida_dd_885.num_seq

         LET p_audit_ar_dd_885.cod_empresa  = p_reg_saida_dd_885.cod_empresa
         LET p_audit_ar_dd_885.num_ar       = p_reg_saida_dd_885.num_ar       
         LET p_audit_ar_dd_885.cod_item     = p_reg_saida_dd_885.cod_item 
         LET p_audit_ar_dd_885.num_seq      = p_reg_saida_dd_885.num_seq 
         LET p_audit_ar_dd_885.den_item     = p_reg_saida_dd_885.den_item 
         LET p_audit_ar_dd_885.dat_ocor     = TODAY
         LET p_audit_ar_dd_885.usuario      = p_user
         LET p_audit_ar_dd_885.texto        = 'QUANTIDADE DEVOLVIDA - ', t_devolv[w_i].qtd_devolvida, ' REFERENTE SOLICITACAO ', p_reg_saida_dd_885.num_solicit, ' Motivo - ',p_den_obs1 CLIPPED
         INSERT INTO audit_ar_dd_885  VALUES  (p_audit_ar_dd_885.*)

         LET l_qtd_devolv =   t_devolv[w_i].qtd_devolvida * -1
                   
         LET p_reg_saida_dd_885.qtd_retirada    =  l_qtd_devolv
         LET p_reg_saida_dd_885.den_obs1        =  p_den_obs1
            
         INITIALIZE     p_reg_saida_dd_885.den_obs2, 
                        p_reg_saida_dd_885.den_obs3    TO NULL
                                
         INSERT INTO reg_saida_dd_885 VALUES (p_reg_saida_dd_885.*)

      END IF 
   END FOR
   
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION

#-----------------------#
 FUNCTION pol0842_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
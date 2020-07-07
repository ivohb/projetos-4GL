#-----------------------------------------------------------------#
# PROGRAMA: pol0841                                               #
# OBJETIVO: SOLICITACAO DE MATERIAL DEBITO DIRETO - ESPECIFICOS   #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_solicit_dd_885      RECORD LIKE solicit_dd_885.*,
          p_reg_saida_dd_885    RECORD LIKE reg_saida_dd_885.*,
          p_audit_ar_dd_885     RECORD LIKE audit_ar_dd_885.*,
          p_usu_aprov_reserva   RECORD LIKE usu_aprov_reserva.*

   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_qtd_saldo        LIKE aviso_rec.qtd_declarad_nf,
          p_nom_aprovante    LIKE solicit_dd_885.nom_aprovante,
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
          p_i                SMALLINT

   DEFINE t_sol_parc ARRAY[500] OF RECORD
      ies_liber        CHAR(01)
   END RECORD

   DEFINE t_solicit ARRAY[500] OF RECORD
      num_solicit      LIKE aviso_rec.num_seq,
      nom_solicit      LIKE solicit_dd_885.nom_solicit,
      den_item         LIKE solicit_dd_885.den_item,
      qtd_solicitada   LIKE solicit_dd_885.qtd_solicitada,
      qtd_entregue     LIKE solicit_dd_885.qtd_solicitada  
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "POL0841-05.10.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0841_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0841_controle()
#--------------------------#
 DEFINE l_count INTEGER

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0841") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0841 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Entrada de dados"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0841","CO") THEN 
            IF pol0841_entrada_dados() THEN
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
         IF log005_seguranca(p_user,"VDP","pol0841","MO") THEN 
            IF p_ies_cons THEN 
               IF pol0841_informa_liberacao() THEN 
                  CALL pol0841_processa()
                  IF p_houve_erro THEN
                     ERROR "Processamento Cancelado " 
                     NEXT OPTION "Consultar"
                  ELSE  
                     #COMMIT WORK
                     CALL log085_transacao("COMMIT")
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

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0841

END FUNCTION

#-------------------------------#
 FUNCTION pol0841_entrada_dados()
#-------------------------------#
   INITIALIZE  p_solicit_dd_885.*,
               t_solicit            TO NULL
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0841

   LET INT_FLAG = FALSE  
   INPUT p_solicit_dd_885.nom_solicit
   WITHOUT DEFAULTS  
    FROM nom_solicit  

    AFTER FIELD nom_solicit     
       CALL pol0841_carrega_tela()
          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0841
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE 
   END IF
 
END FUNCTION

#-----------------------------#
FUNCTION pol0841_carrega_tela()
#-----------------------------#
 DEFINE sql_stmt, 
        where_clause   CHAR(300)
        
 LET p_i =  1

 LET where_clause = '%',p_solicit_dd_885.nom_solicit CLIPPED,'%' 

 LET sql_stmt = "SELECT * FROM solicit_dd_885 ",
                " WHERE nom_solicit LIKE '", where_clause CLIPPED,"'", 
                " AND cod_empresa = '", p_cod_empresa,"'",
                " AND ies_aprovado = 'S'",
                " ORDER BY num_solicit "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao CURSOR FOR var_query
 FOREACH cq_padrao INTO p_solicit_dd_885.*
    LET t_solicit[p_i].num_solicit    = p_solicit_dd_885.num_solicit
    LET t_solicit[p_i].nom_solicit    = p_solicit_dd_885.nom_solicit 
    LET t_solicit[p_i].den_item       = p_solicit_dd_885.den_item    
    LET t_solicit[p_i].qtd_solicitada = p_solicit_dd_885.qtd_solicitada 
    LET t_solicit[p_i].qtd_entregue   = 0  
    LET p_i = p_i + 1
 END FOREACH       

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_solicit TO s_solicit.*
   END DISPLAY

END FUNCTION


#----------------------------------#
FUNCTION pol0841_informa_liberacao()
#----------------------------------#
  CALL log006_exibe_teclas("01", p_versao)

   INPUT ARRAY t_solicit WITHOUT DEFAULTS FROM s_solicit.*

      BEFORE FIELD qtd_entregue   
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD qtd_entregue  
        IF t_solicit[pa_curr].qtd_entregue > t_solicit[pa_curr].qtd_solicitada THEN
           ERROR 'Qtde entregue nao pode ser maior que solicitada'
           NEXT FIELD qtd_entregue 
        END IF 
        
        IF t_solicit[pa_curr].qtd_entregue < t_solicit[pa_curr].qtd_solicitada AND 
           t_solicit[pa_curr].qtd_entregue <> 0  THEN
           IF log0040_confirm(18,35,"ENTREGA PARCIAL, CANCELA SALDO RESTANTE??") THEN
              LET  t_sol_parc[pa_curr].ies_liber = 'C'
           ELSE
              LET  t_sol_parc[pa_curr].ies_liber = 'P'
           END IF
        ELSE
           LET  t_sol_parc[pa_curr].ies_liber = 'S'    
        END IF    

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_solicit[pa_curr+1].num_solicit IS NULL THEN 
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
 FUNCTION pol0841_processa()
#---------------------------#

   LET p_houve_erro = FALSE
   #BEGIN WORK
   CALL log085_transacao("BEGIN")

   FOR w_i = 1  TO 500 

      IF t_solicit[w_i].num_solicit IS NULL THEN
         EXIT FOR 
      END IF
      
      IF t_solicit[w_i].qtd_entregue > 0 THEN 
         SELECT * 
           INTO p_solicit_dd_885.*
           FROM solicit_dd_885  
             WHERE cod_empresa = p_cod_empresa 
               AND num_solicit = t_solicit[w_i].num_solicit                         
         IF t_sol_parc[w_i].ies_liber = 'S' THEN 
            DELETE FROM solicit_dd_885 
             WHERE cod_empresa = p_cod_empresa 
               AND num_solicit = t_solicit[w_i].num_solicit                         
         ELSE
            IF t_sol_parc[w_i].ies_liber = 'C' THEN       
               DELETE FROM solicit_dd_885 
                WHERE cod_empresa = p_cod_empresa 
                  AND num_solicit = t_solicit[w_i].num_solicit                         
            ELSE
               IF t_sol_parc[w_i].ies_liber = 'P' THEN       
                  UPDATE solicit_dd_885 SET qtd_solicitada = qtd_solicitada - t_solicit[w_i].qtd_entregue
                   WHERE cod_empresa = p_cod_empresa 
                     AND num_solicit = t_solicit[w_i].num_solicit                         
               END IF       
            END IF    
         END IF 
         
         UPDATE saldo_ar_dd_885 
            SET qtd_retirada = qtd_retirada + t_solicit[w_i].qtd_entregue
          WHERE cod_empresa = p_cod_empresa 
            AND num_ar      = p_solicit_dd_885.num_ar
            AND num_seq     = p_solicit_dd_885.num_seq

         LET p_audit_ar_dd_885.cod_empresa  = p_solicit_dd_885.cod_empresa
         LET p_audit_ar_dd_885.num_ar       = p_solicit_dd_885.num_ar       
         LET p_audit_ar_dd_885.cod_item     = p_solicit_dd_885.cod_item 
         LET p_audit_ar_dd_885.num_seq      = p_solicit_dd_885.num_seq 
         LET p_audit_ar_dd_885.den_item     = p_solicit_dd_885.den_item 
         LET p_audit_ar_dd_885.dat_ocor     = TODAY
         LET p_audit_ar_dd_885.usuario      = p_user
         LET p_audit_ar_dd_885.texto        = 'QUANTIDADE ENTREGUE - ', t_solicit[w_i].qtd_entregue, ' REFERENTE SOLICITACAO ', p_solicit_dd_885.num_solicit
         INSERT INTO audit_ar_dd_885  VALUES  (p_audit_ar_dd_885.*)
            
         SELECT *
           INTO p_reg_saida_dd_885.*
           FROM reg_saida_dd_885
          WHERE cod_empresa = p_cod_empresa 
            AND num_solicit = t_solicit[w_i].num_solicit                         
         IF SQLCA.sqlcode = 0 THEN 
            UPDATE reg_saida_dd_885 SET qtd_retirada = qtd_retirada + t_solicit[w_i].qtd_entregue
             WHERE cod_empresa = p_cod_empresa 
               AND num_solicit = t_solicit[w_i].num_solicit                         
         ELSE
            LET p_reg_saida_dd_885.cod_empresa     =  p_solicit_dd_885.cod_empresa      
            LET p_reg_saida_dd_885.num_solicit     =  p_solicit_dd_885.num_solicit    
            LET p_reg_saida_dd_885.num_ar          =  p_solicit_dd_885.num_ar         
            LET p_reg_saida_dd_885.nom_aprovante   =  p_solicit_dd_885.nom_aprovante  
            LET p_reg_saida_dd_885.nom_solicit     =  p_solicit_dd_885.nom_solicit    
            LET p_reg_saida_dd_885.cod_cent_cust   =  p_solicit_dd_885.cod_cent_cust
            LET p_reg_saida_dd_885.dat_solicit     =  p_solicit_dd_885.dat_solicit    
            LET p_reg_saida_dd_885.cod_item        =  p_solicit_dd_885.cod_item       
            LET p_reg_saida_dd_885.num_seq         =  p_solicit_dd_885.num_seq        
            LET p_reg_saida_dd_885.den_item        =  p_solicit_dd_885.den_item       
            LET p_reg_saida_dd_885.qtd_solicitada  =  p_solicit_dd_885.qtd_solicitada
            LET p_reg_saida_dd_885.qtd_retirada    =  t_solicit[w_i].qtd_entregue  
               
            INITIALIZE     p_reg_saida_dd_885.den_obs1, 
                           p_reg_saida_dd_885.den_obs2, 
                           p_reg_saida_dd_885.den_obs3    TO NULL
                                   
            INSERT INTO reg_saida_dd_885 VALUES (p_reg_saida_dd_885.*)

         END IF    
      END IF 
   END FOR
   
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
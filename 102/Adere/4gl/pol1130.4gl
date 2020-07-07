#-----------------------------------------------------------------#
# SISTEMA.: INTEGRA��O LOGIX X PW1                                #
# PROGRAMA: pol1130                                               #
# OBJETIVO: MANUTENCAO DA TABELA PCT_AJUST_MAN912                 #
# AUTOR...: IVO                                                   #
# DATA....: 12/06/2006                                            #
# ALTERADO: 12/12/2006 po ANA PAULA                               #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT

   DEFINE p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_nom_arquivo_back     CHAR(100),
          g_usa_visualizador     SMALLINT

   DEFINE g_ies_grafico          SMALLINT
   DEFINE p_versao               CHAR(18) 

   DEFINE m_den_empresa          LIKE empresa.den_empresa,
          m_consulta_ativa       SMALLINT,
          m_esclusao_ativa       SMALLINT,
          sql_stmt               CHAR(5000),
          where_clause           CHAR(5000),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          p_nom_tela              CHAR(200),
          p_last_row             SMALLINT,
          p_den_empresa          LIKE empresa.den_empresa,
          p_msg                  CHAR(500)

   DEFINE mr_ajust_man912      RECORD LIKE pct_ajust_man912.*
   
   DEFINE  m_versao_ant          SMALLINT 

END GLOBALS


MAIN
   LET p_versao = 'pol1130-10.02.03' 

   WHENEVER ANY ERROR CONTINUE

#   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 120

   WHENEVER ANY ERROR STOP

   DEFER INTERRUPT

   LET p_nom_tela = log140_procura_caminho('pol1130.iem')

   OPTIONS
      PREVIOUS KEY control-b,
      NEXT     KEY control-f,
      INSERT   KEY control-i,
      DELETE   KEY control-e,
      HELP    FILE p_nom_tela

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1130_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1130_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1130") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1130 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa

   MENU 'OPCAO'
      COMMAND 'Incluir' 'Inclui um novo item na tabela pct_ajust_man912.'
         HELP 001
         MESSAGE ''
         IF  log005_seguranca(p_user, 'VDP', 'pol1130', 'IN') THEN
             CALL pol1130_inclusao()
         END IF

      COMMAND 'Modificar' 'Modifica um item existente na tabela pct_ajust_man912.'
         HELP 002
         MESSAGE ''
         IF m_consulta_ativa THEN
            IF NOT m_versao_ant THEN 
               IF log005_seguranca(p_user, 'VDP', 'pol1130', 'EX') THEN
                  CALL pol1130_modifica()
               END IF
            ELSE 
               ERROR 'Somente e permitido modificar versoes atuais.'
            END IF  
         ELSE
            ERROR ' Consulte previamente para fazer a modifica��o. '
         END IF
      
      COMMAND 'Consultar' 'Pesquisa a tabela pct_ajust_man912.'
         HELP 004
         MESSAGE ''
         IF  log005_seguranca(p_user, 'VDP' , 'pol1130', 'CO') THEN
             CALL pol1130_consulta()
         END IF

      COMMAND "Anterior" "Exibe o item anterior encontrado na pesquisa."
         HELP 006
         MESSAGE ''
         IF m_consulta_ativa THEN
            CALL pol1130_paginacao("ANTERIOR")
         ELSE
            ERROR " N�o existe nenhuma consulta ativa. "
         END IF

      COMMAND "Seguinte" "Exibe o proximo item encontrado na pesquisa."
         HELP 005
         MESSAGE ''
         IF m_consulta_ativa THEN
            CALL pol1130_paginacao("SEGUINTE")
         ELSE
            ERROR " N�o existe nenhuma consulta ativa. "
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1130_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

      COMMAND 'Fim'       'Retorna ao menu anterior.'
         HELP 008
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1130
   
END FUNCTION

#--------------------------#
 FUNCTION pol1130_inclusao()
#--------------------------#
   DEFINE l_qtd_lotes        SMALLINT,
          l_ind              SMALLINT 
   
   SELECT *
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa
   
   IF sqlca.sqlcode = 0 THEN
      ERROR "Valores j� cadastrado p/ essa Empresa."
      RETURN
   END IF
   
   IF pol1130_entrada_dados("INCLUSAO") THEN
      WHENEVER ERROR CONTINUE
         CALL log085_transacao("BEGIN")
                  
         INSERT INTO pct_ajust_man912 VALUES (mr_ajust_man912.*)
      
      IF sqlca.sqlcode = 0 THEN
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclus�o efetuada com sucesso!" ATTRIBUTE(REVERSE)
      ELSE
         CALL log085_transacao("ROLLBACK")
         CALL log003_err_sql("INCLUSAO","PCT_AJUST_MAN912")
      END IF
      WHENEVER ERROR STOP
   ELSE
      MESSAGE "Inclus�o cancelada." ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol1130_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_operac)
         CALL log009_popup(8,10,"Opera��o","operacao",
              "cod_operac","den_operac","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET mr_ajust_man912.cod_operac = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_operac
         END IF
   END CASE 

END FUNCTION 

#-----------------------------------#
 FUNCTION pol1130_modifica()
#-----------------------------------#
   DEFINE l_num_versao      SMALLINT 
   
   IF pol1130_entrada_dados("MODIFICACAO") THEN
      WHENEVER ERROR CONTINUE
      BEGIN WORK
      
      UPDATE pct_ajust_man912
         SET pct_ajust_man912.* = mr_ajust_man912.*
       WHERE cod_empresa = p_cod_empresa
         
      IF sqlca.sqlcode = 0 THEN
         COMMIT WORK
         MESSAGE ' Modifica��o efetuada com sucesso. ' ATTRIBUTE(REVERSE)
         LET m_consulta_ativa = TRUE
      ELSE
         CALL log003_err_sql("MODIFICACAO","PCT_AJUST_MAN912")
         ROLLBACK WORK
         LET m_consulta_ativa = FALSE
      END IF
   ELSE
      LET m_consulta_ativa = TRUE
      MESSAGE ' Modifica��o cancelada. ' ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION pol1130_entrada_dados(l_funcao)
#-------------------------------------------#
    DEFINE l_funcao     CHAR(015),
           l_resto      INTEGER,
           l_count      SMALLINT 

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_pol1130 
    
    LET INT_FLAG = 0
    
    IF l_funcao = "INCLUSAO" THEN 
       INITIALIZE mr_ajust_man912.* TO NULL 
       CLEAR FORM 
       LET mr_ajust_man912.cod_empresa = p_cod_empresa
       DISPLAY p_cod_empresa TO cod_empresa
    END IF 
    
    INPUT BY NAME mr_ajust_man912.* 
          WITHOUT DEFAULTS 
       
       AFTER FIELD pct_ajus_insumo
          IF mr_ajust_man912.pct_ajus_insumo IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD pct_ajus_insumo
          END IF 

       AFTER FIELD aponta_eqpto_recur
          IF mr_ajust_man912.aponta_eqpto_recur IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD aponta_eqpto_recur
          END IF 
       
          IF mr_ajust_man912.aponta_eqpto_recur <> 'S' AND
             mr_ajust_man912.aponta_eqpto_recur <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD aponta_eqpto_recur
          END IF 
       
       AFTER FIELD aponta_ferramenta
          IF mr_ajust_man912.aponta_ferramenta IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD aponta_ferramenta
          END IF 

          IF mr_ajust_man912.aponta_ferramenta <> 'S' AND
             mr_ajust_man912.aponta_ferramenta <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD aponta_ferramenta
          END IF 
       
       AFTER FIELD finaliza
          IF mr_ajust_man912.finaliza IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD finaliza
          END IF 

          IF mr_ajust_man912.finaliza <> 'S' AND
             mr_ajust_man912.finaliza <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD finaliza
          END IF 
       
       AFTER FIELD aponta_refugo
          IF mr_ajust_man912.aponta_refugo IS NULL THEN 
             let mr_ajust_man912.aponta_refugo = 0
          END IF 

       AFTER FIELD aponta_parada
          IF mr_ajust_man912.aponta_parada IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD aponta_parada
          END IF 

          IF mr_ajust_man912.aponta_parada <> 'S' AND
             mr_ajust_man912.aponta_parada <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD aponta_parada
          END IF 

       ON KEY (f1,control-w)
          CALL pol1130_help()

       AFTER FIELD cod_operac
          IF mr_ajust_man912.cod_operac IS NULL THEN 
             ERROR 'Campo de preenchimento obrigat�rio.'
             NEXT FIELD cod_operac
          END IF 
          
          IF not pol1130_le_operac() THEN
             NEXT FIELD cod_operac
          END IF 
                    

       AFTER INPUT
          If not INT_FLAG then
             if mr_ajust_man912.prog_export_op is null then
                ERROR 'Campo com preenchimento obrigat�rio!'
                NEXT FIELD prog_export_op
             end if
             if mr_ajust_man912.prog_import_op is null then
                ERROR 'Campo com preenchimento obrigat�rio!'
                NEXT FIELD prog_import_op
             end if
          End if             

      ON KEY (control-z)
         CALL pol1130_popup()
          
    END INPUT
    
    IF INT_FLAG THEN 
       LET INT_FLAG = FALSE 
       RETURN FALSE 
    END IF 
        
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1130_le_operac()#
#---------------------------#

   SELECT den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_ajust_man912.cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','operacao')
      RETURN FALSE
   End IF

   RETURN TRUE
   
END FUNCTION

     
      
#------------------------------#
 FUNCTION pol1130_consulta()
#------------------------------#

 INITIALIZE sql_stmt, where_clause TO NULL
 INITIALIZE mr_ajust_man912.* TO NULL
 CLEAR FORM 
 DISPLAY BY NAME mr_ajust_man912.*
 DISPLAY p_cod_empresa TO cod_empresa
  
 LET sql_stmt = 
    "SELECT * ",
    "  FROM pct_ajust_man912 ",
    " WHERE cod_empresa = '",p_cod_empresa,"'"
    
 WHENEVER ERROR CONTINUE
 PREPARE var_query FROM sql_stmt
 DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_consulta
 FETCH cq_consulta INTO mr_ajust_man912.*
 WHENEVER ERROR STOP
 
    IF sqlca.sqlcode = 0 THEN
       CALL pol1130_exibe_dados()
       LET m_consulta_ativa = TRUE
       MESSAGE 'Consulta efetuada com sucesso. ' ATTRIBUTE(REVERSE)
    ELSE
       IF sqlca.sqlcode = 100 THEN
          MESSAGE "Argumentos de Pesquisa n�o encontrados" ATTRIBUTE(REVERSE)
          LET m_consulta_ativa = FALSE
       ELSE
          LET m_consulta_ativa = FALSE
          CALL log003_err_sql("CONSULTA","PCT_AJUST_MAN912")
       END IF
    END IF
 
END FUNCTION

#-----------------------------#
 FUNCTION pol1130_exibe_dados()
#-----------------------------#
   CALL log006_exibe_teclas('01', p_versao)
   
   CURRENT WINDOW IS w_pol1130
   
   DISPLAY BY NAME mr_ajust_man912.*
   
   
END FUNCTION

#------------------------------------#
  FUNCTION pol1130_paginacao(l_funcao)
#------------------------------------#
   DEFINE l_funcao            CHAR(015)
   
   WHILE TRUE
      WHENEVER ERROR CONTINUE
      CASE l_funcao
         WHEN "SEGUINTE" FETCH NEXT     cq_consulta INTO mr_ajust_man912.*
         WHEN "ANTERIOR" FETCH PREVIOUS cq_consulta INTO mr_ajust_man912.*
      END CASE
      WHENEVER ERROR STOP
   
      IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode = 100 THEN
            MESSAGE ' N�o existem mais itens nesta dire��o. ' 
               ATTRIBUTE(REVERSE)
            EXIT WHILE
         ELSE
            CALL log003_err_sql("PAGINACAO2","PCT_AJUST_MAN912")
            EXIT WHILE
         END IF
      ELSE
         SELECT *
           INTO mr_ajust_man912.* 
           FROM pct_ajust_man912
          WHERE cod_empresa = p_cod_empresa
            
         IF SQLCA.sqlcode <> 0 THEN
            CONTINUE WHILE
         ELSE
            CALL pol1130_exibe_dados()
            EXIT WHILE
         END IF
      END IF
   END WHILE
END FUNCTION

#------------------------------------#
 FUNCTION pol1130_help()
#------------------------------------#

END FUNCTION

#-----------------------#
 FUNCTION pol1130_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

# PARA COMPILAR NO 4JS, INSIRA UMA CHAVE ({) NA LINHA A SEGUIR
{
#----------------------------------#
FUNCTION log085_transacao(p_transac)
#----------------------------------#

   DEFINE p_transac CHAR(08)

   CASE p_transac
      WHEN "BEGIN"    BEGIN WORK
      WHEN "COMMIT"   COMMIT WORK
      WHEN "ROLLBACK" ROLLBACK WORK
   END CASE
         
END FUNCTION 

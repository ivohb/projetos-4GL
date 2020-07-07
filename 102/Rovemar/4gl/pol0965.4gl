#-----------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X EGA                                #
# PROGRAMA: pol0965                                               #
# OBJETIVO: MANUTENCAO DA TABELA rovpct_ajust_man912                 #
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
#   DEFINE p_versao               CHAR(17)
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
          p_den_empresa          LIKE empresa.den_empresa

   DEFINE mr_ajust_man912      RECORD LIKE rovpct_ajust_man912.*
   
   DEFINE  m_versao_ant          SMALLINT 

END GLOBALS


MAIN
   LET p_versao = 'pol0965-10.02.00' 

   WHENEVER ANY ERROR CONTINUE

#   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 120

   WHENEVER ANY ERROR STOP

   DEFER INTERRUPT

   LET p_nom_tela = log140_procura_caminho('pol0965.iem')

   OPTIONS
      PREVIOUS KEY control-b,
      NEXT     KEY control-f,
      INSERT   KEY control-i,
      DELETE   KEY control-e,
      HELP    FILE p_nom_tela

#   CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario('VDP','LIBLIC')
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol0965_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0965_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0965") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0965 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa

   MENU 'OPCAO'
      COMMAND 'Incluir' 'Inclui um novo item na tabela rovpct_ajust_man912.'
         HELP 001
         MESSAGE ''
         IF  log005_seguranca(p_user, 'VDP', 'pol0965', 'IN') THEN
             CALL pol0965_inclusao()
         END IF

      COMMAND 'Modificar' 'Modifica um item existente na tabela rovpct_ajust_man912.'
         HELP 002
         MESSAGE ''
         IF m_consulta_ativa THEN
            IF NOT m_versao_ant THEN 
               IF log005_seguranca(p_user, 'VDP', 'pol0965', 'EX') THEN
                  CALL pol0965_modifica()
               END IF
            ELSE 
               ERROR 'Somente e permitido modificar versoes atuais.'
            END IF  
         ELSE
            ERROR ' Consulte previamente para fazer a modificação. '
         END IF
      
      COMMAND 'Consultar' 'Pesquisa a tabela rovpct_ajust_man912.'
         HELP 004
         MESSAGE ''
         IF  log005_seguranca(p_user, 'VDP' , 'pol0965', 'CO') THEN
             CALL pol0965_consulta()
         END IF

      COMMAND "Anterior" "Exibe o item anterior encontrado na pesquisa."
         HELP 006
         MESSAGE ''
         IF m_consulta_ativa THEN
            CALL pol0965_paginacao("ANTERIOR")
         ELSE
            ERROR " Não existe nenhuma consulta ativa. "
         END IF

      COMMAND "Seguinte" "Exibe o proximo item encontrado na pesquisa."
         HELP 005
         MESSAGE ''
         IF m_consulta_ativa THEN
            CALL pol0965_paginacao("SEGUINTE")
         ELSE
            ERROR " Não existe nenhuma consulta ativa. "
         END IF
      
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

      COMMAND 'Fim'       'Retorna ao menu anterior.'
         HELP 008
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0965
   
END FUNCTION

#--------------------------#
 FUNCTION pol0965_inclusao()
#--------------------------#
   DEFINE l_qtd_lotes        SMALLINT,
          l_ind              SMALLINT 
   
   SELECT *
     FROM rovpct_ajust_man912
    WHERE cod_empresa = p_cod_empresa
   
   IF sqlca.sqlcode = 0 THEN
      ERROR "Valores já cadastrado p/ essa Empresa."
      RETURN
   END IF
   
   IF pol0965_entrada_dados("INCLUSAO") THEN
      WHENEVER ERROR CONTINUE
         CALL log085_transacao("BEGIN")
                  
         INSERT INTO rovpct_ajust_man912 VALUES (mr_ajust_man912.*)
      
      IF sqlca.sqlcode = 0 THEN
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusão efetuada com sucesso!" ATTRIBUTE(REVERSE)
      ELSE
         CALL log085_transacao("ROLLBACK")
         CALL log003_err_sql("INCLUSAO","rovpct_ajust_man912")
      END IF
      WHENEVER ERROR STOP
   ELSE
      MESSAGE "Inclusão cancelada." ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0965_modifica()
#-----------------------------------#
   DEFINE l_num_versao      SMALLINT 
   
   IF pol0965_entrada_dados("MODIFICACAO") THEN
      WHENEVER ERROR CONTINUE
      BEGIN WORK
      
      UPDATE rovpct_ajust_man912
         SET rovpct_ajust_man912.* = mr_ajust_man912.*
       WHERE cod_empresa = p_cod_empresa
         
      IF sqlca.sqlcode = 0 THEN
         COMMIT WORK
         MESSAGE ' Modificação efetuada com sucesso. ' ATTRIBUTE(REVERSE)
         LET m_consulta_ativa = TRUE
      ELSE
         ROLLBACK WORK
         LET m_consulta_ativa = FALSE
         CALL log003_err_sql("MODIFICACAO","rovpct_ajust_man912")
      END IF
   ELSE
      LET m_consulta_ativa = TRUE
      MESSAGE ' Modificação cancelada. ' ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION pol0965_entrada_dados(l_funcao)
#-------------------------------------------#
    DEFINE l_funcao     CHAR(015),
           l_resto      INTEGER,
           l_count      SMALLINT 

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_pol0965 
    
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
             ERROR 'Campo de preenchimento obrigatório.'
             NEXT FIELD pct_ajus_insumo
          END IF 

       AFTER FIELD aponta_eqpto_recur
          IF mr_ajust_man912.aponta_eqpto_recur IS NULL THEN 
             ERROR 'Campo de preenchimento obrigatório.'
             NEXT FIELD aponta_eqpto_recur
          END IF 
       
          IF mr_ajust_man912.aponta_eqpto_recur <> 'S' AND
             mr_ajust_man912.aponta_eqpto_recur <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD aponta_eqpto_recur
          END IF 
       
       AFTER FIELD aponta_ferramenta
          IF mr_ajust_man912.aponta_ferramenta IS NULL THEN 
             ERROR 'Campo de preenchimento obrigatório.'
             NEXT FIELD aponta_ferramenta
          END IF 

          IF mr_ajust_man912.aponta_ferramenta <> 'S' AND
             mr_ajust_man912.aponta_ferramenta <> 'N' THEN 
             ERROR 'Valor ilegal p/ o campo'
             NEXT FIELD aponta_ferramenta
          END IF 

       ON KEY (f1,control-w)
          CALL pol0965_help()

    END INPUT
    
    IF INT_FLAG THEN 
       LET INT_FLAG = FALSE 
       RETURN FALSE 
    END IF 
        
    RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol0965_consulta()
#------------------------------#

 INITIALIZE sql_stmt, where_clause TO NULL
 INITIALIZE mr_ajust_man912.* TO NULL
 CLEAR FORM 
 DISPLAY BY NAME mr_ajust_man912.*
 DISPLAY p_cod_empresa TO cod_empresa
  
 LET sql_stmt = 
    "SELECT * ",
    "  FROM rovpct_ajust_man912 ",
    " WHERE cod_empresa = '",p_cod_empresa,"'"
    
 WHENEVER ERROR CONTINUE
 PREPARE var_query FROM sql_stmt
 DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_consulta
 FETCH cq_consulta INTO mr_ajust_man912.*
 WHENEVER ERROR STOP
 
    IF sqlca.sqlcode = 0 THEN
       CALL pol0965_exibe_dados()
       LET m_consulta_ativa = TRUE
       MESSAGE 'Consulta efetuada com sucesso. ' ATTRIBUTE(REVERSE)
    ELSE
       IF sqlca.sqlcode = 100 THEN
          MESSAGE "Argumentos de Pesquisa não encontrados" ATTRIBUTE(REVERSE)
          LET m_consulta_ativa = FALSE
       ELSE
          LET m_consulta_ativa = FALSE
          CALL log003_err_sql("CONSULTA","rovpct_ajust_man912")
       END IF
    END IF
 
END FUNCTION

#-----------------------------#
 FUNCTION pol0965_exibe_dados()
#-----------------------------#
   CALL log006_exibe_teclas('01', p_versao)
   
   CURRENT WINDOW IS w_pol0965
   
   DISPLAY BY NAME mr_ajust_man912.*
   
   
END FUNCTION

#------------------------------------#
  FUNCTION pol0965_paginacao(l_funcao)
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
            MESSAGE ' Não existem mais itens nesta direção. ' 
               ATTRIBUTE(REVERSE)
            EXIT WHILE
         ELSE
            CALL log003_err_sql("PAGINACAO2","rovpct_ajust_man912")
            EXIT WHILE
         END IF
      ELSE
         SELECT *
           INTO mr_ajust_man912.* 
           FROM rovpct_ajust_man912
          WHERE cod_empresa = p_cod_empresa
            
         IF SQLCA.sqlcode <> 0 THEN
            CONTINUE WHILE
         ELSE
            CALL pol0965_exibe_dados()
            EXIT WHILE
         END IF
      END IF
   END WHILE
END FUNCTION

#------------------------------------#
 FUNCTION pol0965_help()
#------------------------------------#

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

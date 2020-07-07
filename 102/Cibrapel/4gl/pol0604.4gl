#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                 #
# PROGRAMA: pol0604                                                 #
# OBJETIVO: DE-PARA MAQUINA                                         #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 03/06/2007                                              #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_empresaa       LIKE empresa.cod_empresa,
          p_cod_empresa_plano  LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
END GLOBALS
          
   DEFINE p_de_para_maq_885   RECORD LIKE de_para_maq_885.*,
          p_de_para_maq_885a  RECORD LIKE de_para_maq_885.* 

   DEFINE p_den_recur         LIKE recurso.den_recur,
          p_des_compon        LIKE componente.des_compon,
          p_den_cent_trab     LIKE cent_trabalho.den_cent_trab,
          p_nom_cent_cust     LIKE cad_cc.nom_cent_cust,
          p_den_arranjo       LIKE arranjo.den_arranjo,
          p_den_operac        LIKE operacao.den_operac,
          p_cod_maq_trim      LIKE de_para_maq_885.cod_maq_trim,
          p_cod_maq_trima     LIKE de_para_maq_885.cod_maq_trim,
          p_den_conta         LIKE plano_contas.den_conta



MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT

   LET p_versao = "pol0604-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0604.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0604_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0604_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0604") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0604 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol0604_le_par_con() THEN
      RETURN
   END IF
   
   LET p_cod_empresaa = p_cod_empresa
      
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0604_inclusao() THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0604_modificacao() THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0604_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0604_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0604_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0604_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0604","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0604_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0604.tmp'
                     START REPORT pol0604_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0604_relat TO p_nom_arquivo
               END IF
               CALL pol0604_emite_relatorio()   
               FINISH REPORT pol0604_relat   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
                  CONTINUE MENU
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
                  IF p_ies_impressao = "S" THEN
                     MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                        ATTRIBUTE(REVERSE)
                     IF g_ies_ambiente = "W" THEN
                        LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
                        RUN comando
                     END IF
                  ELSE
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo 
                        ATTRIBUTE(REVERSE)
                  END IF                              
               END IF
            END IF                                                     
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0604

END FUNCTION


#--------------------------#
 FUNCTION pol0604_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_de_para_maq_885.* TO NULL
   LET p_de_para_maq_885.cod_empresa = p_cod_empresa

   IF pol0604_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO de_para_maq_885 VALUES (p_de_para_maq_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	       CALL log003_err_sql("INCLUSAO","DE_PARA_MAQ_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0604_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_de_para_maq_885.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_maq_trim
         IF p_funcao = 'M' THEN
            NEXT FIELD cod_recur
         END IF
      
      AFTER FIELD cod_maq_trim
         IF LENGTH(p_de_para_maq_885.cod_maq_trim) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_maq_trim   
         END IF

         CALL pol0604_le_de_para_maq_885()

         IF STATUS = 0 THEN
            ERROR 'Máquina Trim já Cadastrada !!!'
            NEXT FIELD cod_maq_trim
         ELSE
            IF STATUS = 100 THEN
            ELSE
               CALL log003_err_sql("LEITURA","DE_PARA_MAQ_885")       
               RETURN FALSE
           END IF
        END IF

      AFTER FIELD ies_onduladeira
         IF p_de_para_maq_885.ies_onduladeira MATCHES "[SN]" THEN
         ELSE
            ERROR "Valor Ilegal p/ o Campo !!!"
            NEXT FIELD ies_onduladeira   
         END IF
      

      AFTER FIELD cod_recur
         IF LENGTH(p_de_para_maq_885.cod_recur) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_recur   
         END IF

         CALL pol0604_le_recurso()

         IF STATUS = 100 THEN
            ERROR 'Máquina Logix Não Cadastrada !!!'
            NEXT FIELD cod_recur
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","RECURSO")       
               RETURN FALSE
            END IF
         END IF

         DISPLAY p_den_recur TO den_recur

      
      AFTER FIELD cod_compon
         IF LENGTH(p_de_para_maq_885.cod_compon) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_compon   
         END IF

        CALL pol0604_le_componente()

         IF STATUS = 100 THEN
            ERROR 'Equipmaneto Não Cadastrado !!!'
            NEXT FIELD cod_compon
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","RECURSO")       
               RETURN FALSE
           END IF
        END IF

        DISPLAY p_des_compon TO des_compon
     
      AFTER FIELD cod_cent_trab
         IF LENGTH(p_de_para_maq_885.cod_cent_trab) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cent_trab   
         END IF

         CALL pol0604_le_cent_trabalho()

         IF STATUS = 100 THEN
            ERROR 'Centro de Trabalho Não Cadastrado !!!'
            NEXT FIELD cod_cent_trab
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","RECURSO")       
               RETURN FALSE
            END IF
         END IF

         DISPLAY p_den_cent_trab TO den_cent_trab
     
      AFTER FIELD cod_cent_cust
         IF LENGTH(p_de_para_maq_885.cod_cent_cust) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cent_cust   
         END IF

         CALL pol0604_le_cad_cc()

         IF STATUS = 100 THEN
            ERROR 'Centro de Custo Não Cadastrado !!!'
            NEXT FIELD cod_cent_cust
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","CAD_CC")       
               RETURN FALSE
            END IF
         END IF

         DISPLAY p_nom_cent_cust TO nom_cent_cust

      AFTER FIELD cod_arranjo
         IF LENGTH(p_de_para_maq_885.cod_arranjo) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_arranjo   
         END IF

         CALL pol0604_le_arranjo()

         IF STATUS = 100 THEN
            ERROR 'Arranjo Não Cadastrado !!!'
            NEXT FIELD cod_arranjo
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","RECURSO")       
               RETURN FALSE
            END IF
         END IF

         DISPLAY p_den_arranjo TO den_arranjo

      AFTER FIELD cod_operac
         IF LENGTH(p_de_para_maq_885.cod_operac) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_operac   
         END IF

         CALL pol0604_le_operacao()

         IF STATUS = 100 THEN
            ERROR 'Operacao Não Cadastrada !!!'
            NEXT FIELD cod_operac
         ELSE
            IF STATUS = 0 THEN
            ELSE
               CALL log003_err_sql("LEITURA","RECURSO")       
               RETURN FALSE
            END IF
         END IF

         DISPLAY p_den_operac TO den_operac
     
      AFTER FIELD pct_refugo
         IF LENGTH(p_de_para_maq_885.pct_refugo) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD pct_refugo   
         END IF

      AFTER FIELD num_conta
         INITIALIZE p_den_conta TO NULL
         
         IF p_de_para_maq_885.num_conta IS NOT NULL THEN

            CALL pol0604_le_conta()

            IF STATUS = 100 THEN
               ERROR 'Conta Inexistente!!!'
               NEXT FIELD num_conta
            ELSE
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo','Conta')
                  RETURN FALSE
               END IF
            END IF

         END IF
         
         DISPLAY p_den_conta TO den_conta
     
      ON KEY (control-z)
         CALL pol0604_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0604_le_de_para_maq_885()
#-----------------------------------#

   SELECT cod_empresa
     FROM de_para_maq_885
    WHERE cod_empresa  = p_cod_empresa
      AND cod_maq_trim = p_de_para_maq_885.cod_maq_trim

END FUNCTION

#----------------------------#
FUNCTION pol0604_le_recurso()
#----------------------------#

   SELECT den_recur
     INTO p_den_recur
     FROM recurso
    WHERE cod_empresa   = p_cod_empresa
      AND cod_recur     = p_de_para_maq_885.cod_recur
      AND ies_tip_recur = '2'

END FUNCTION

#------------------------------#
FUNCTION pol0604_le_componente()
#------------------------------#

   SELECT des_compon
     INTO p_des_compon
     FROM componente
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon   = p_de_para_maq_885.cod_compon

END FUNCTION

#---------------------------------#
FUNCTION pol0604_le_cent_trabalho()
#---------------------------------#

   SELECT den_cent_trab
     INTO p_den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_trab = p_de_para_maq_885.cod_cent_trab

END FUNCTION

#---------------------------#
FUNCTION pol0604_le_par_con()
#---------------------------#

   SELECT cod_empresa_plano 
     INTO p_cod_empresa_plano
     FROM par_con  
    WHERE cod_empresa   = p_cod_empresa

   IF STATUS = 100 THEN
     INITIALIZE p_cod_empresa_plano TO NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_con')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0604_le_cad_cc()
#---------------------------#
   
   IF  p_cod_empresa_plano  IS NULL THEN
       SELECT nom_cent_cust
         INTO p_nom_cent_cust
         FROM cad_cc
        WHERE cod_empresa   = p_cod_empresa
          AND cod_cent_cust = p_de_para_maq_885.cod_cent_cust
   ELSE       
        SELECT nom_cent_cust
         INTO p_nom_cent_cust
         FROM cad_cc
        WHERE cod_empresa   = p_cod_empresa_plano
          AND cod_cent_cust = p_de_para_maq_885.cod_cent_cust
   END IF   
        
END FUNCTION

#----------------------------#
FUNCTION pol0604_le_arranjo()
#----------------------------#

   SELECT den_arranjo
     INTO p_den_arranjo
     FROM arranjo
    WHERE cod_empresa = p_cod_empresa
      AND cod_arranjo = p_de_para_maq_885.cod_arranjo

END FUNCTION

#----------------------------#
FUNCTION pol0604_le_operacao()
#----------------------------#

   SELECT den_operac
     INTO p_den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac  = p_de_para_maq_885.cod_operac

END FUNCTION

#--------------------------#
FUNCTION pol0604_le_conta()
#--------------------------#

   SELECT den_conta
     INTO p_den_conta
     FROM plano_contas
    WHERE cod_empresa = p_cod_empresa
      AND num_conta   = p_de_para_maq_885.num_conta
            
END FUNCTION

#-----------------------#
FUNCTION pol0604_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_recur)
         LET p_codigo = log009_popup(8,10,"RECURSOS","recurso",
                        "cod_recur","den_recur","man0060","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_recur = p_codigo
           DISPLAY p_codigo TO cod_recur
         END IF

      WHEN INFIELD(cod_compon)
         LET p_codigo = log009_popup(8,10,"EQUIPAMENTOS","componente",
                        "cod_compon","des_compon","man0010","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_compon = p_codigo
           DISPLAY p_codigo TO cod_compon
         END IF
     
      WHEN INFIELD(cod_cent_trab)
         LET p_codigo = log009_popup(8,10,"CENTROS DE TRABALHO","cent_trabalho",
                        "cod_cent_trab","den_cent_trab","man0100","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_cent_trab = p_codigo
           DISPLAY p_codigo TO cod_cent_trab
         END IF

      WHEN INFIELD(cod_cent_cust)
         IF p_cod_empresa_plano IS NOT NULL THEN
            LET p_cod_empresa = p_cod_empresa_plano
         END IF
         LET p_codigo = log009_popup(8,10,"CENTROS DE CUSTO","cad_cc",
                        "cod_cent_cust","nom_cent_cust","con0480","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         LET p_cod_empresa = p_cod_empresaa
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_cent_cust = p_codigo
           DISPLAY p_codigo TO cod_cent_cust
         END IF

      WHEN INFIELD(cod_arranjo)
         LET p_codigo = log009_popup(8,10,"ARRANJOS","arranjo",
                        "cod_arranjo","den_arranjo","man0080","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_arranjo = p_codigo
           DISPLAY p_codigo TO cod_arranjo
         END IF

      WHEN INFIELD(cod_operac)
         LET p_codigo = log009_popup(8,10,"OPERAÇÕES","operacao",
                        "cod_operac","den_operac","man0071","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.cod_operac = p_codigo
           DISPLAY p_codigo TO cod_operac
         END IF

      WHEN INFIELD(num_conta)
         LET p_codigo = log009_popup(8,10,"CONTAS COBTÁBEIS","plano_contas",
                        "num_conta","den_conta","","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0604
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_maq_885.num_conta = p_codigo
           DISPLAY p_codigo TO num_conta
         END IF

   END CASE

END FUNCTION 

#--------------------------#
 FUNCTION pol0604_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_de_para_maq_885a.* = p_de_para_maq_885.*

   CONSTRUCT BY NAME where_clause ON
      de_para_maq_885.cod_maq_trim,
      de_para_maq_885.cod_recur,
      de_para_maq_885.cod_compon,
      de_para_maq_885.cod_cent_trab,
      de_para_maq_885.cod_cent_cust,
      de_para_maq_885.cod_arranjo,
      de_para_maq_885.cod_operac

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_de_para_maq_885.* = p_de_para_maq_885a.*
      CALL pol0604_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_maq_trim ",
                  "  FROM de_para_maq_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_maq_trim"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","DE_PARA_MAQ_885")            
      LET p_ies_cons = FALSE
      RETURN
   END IF
   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_maq_trim

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0604_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0604_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_de_para_maq_885.*
    FROM de_para_maq_885
   WHERE cod_empresa  = p_cod_empresa
     AND cod_maq_trim = p_cod_maq_trim
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","DE_PARA_MAQ_885")            
      LET p_ies_cons = FALSE
      RETURN
   END IF

   CLEAR FORM
   DISPLAY BY NAME p_de_para_maq_885.*
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol0604_le_recurso()

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","RECURSO")            
   END IF
   
   DISPLAY p_den_recur TO den_recur

   CALL pol0604_le_componente()
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","COMPONENETE")            
   END IF

   DISPLAY p_des_compon TO des_compon

   CALL pol0604_le_cent_trabalho()
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","CENT_TRABALHO")            
   END IF

   DISPLAY p_den_cent_trab TO den_cent_trab
   
   CALL pol0604_le_cad_cc()

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","CAD_CC")            
   END IF
   
   DISPLAY p_nom_cent_cust TO nom_cent_cust
   
   CALL pol0604_le_arranjo()

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ARRANJO")            
   END IF

   DISPLAY p_den_arranjo TO den_arranjo

   CALL pol0604_le_operacao()
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","OPERACAO")            
   END IF
   
   DISPLAY p_den_operac TO den_operac

   CALL pol0604_le_conta()
   
   IF STATUS <> 0 THEN
      LET p_den_conta = NULL
   END IF

   DISPLAY p_den_conta TO den_conta
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0604_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_maq_trima = p_cod_maq_trim
      WHILE TRUE
         
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_cod_maq_trim
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_cod_maq_trim
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_cod_maq_trim = p_cod_maq_trima
            EXIT WHILE
         END IF
         
         LET p_de_para_maq_885.cod_maq_trim = p_cod_maq_trim
         CALL pol0604_le_de_para_maq_885()

         IF STATUS = 0 THEN
            CALL pol0604_exibe_dados()
            EXIT WHILE
         END IF
            
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0604_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * 
     INTO p_de_para_maq_885.*                                              
     FROM de_para_maq_885  
    WHERE cod_empresa  = p_cod_empresa
      AND cod_maq_trim = p_cod_maq_trim
   FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","DE_PARA_MAQ_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0604_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0604_cursor_for_update() THEN
      LET p_cod_maq_trima = p_cod_maq_trim

      IF pol0604_entrada_dados("M") THEN

         UPDATE de_para_maq_885 
            SET de_para_maq_885.* = p_de_para_maq_885.*
          WHERE cod_empresa  = p_cod_empresa
            AND cod_maq_trim = p_cod_maq_trim
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","DE_PARA_MAQ_885")
         END IF
      ELSE
         LET p_cod_maq_trim = p_cod_maq_trima
         CALL pol0604_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0604_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0604_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE

         DELETE FROM de_para_maq_885
          WHERE cod_empresa  = p_cod_empresa
            AND cod_maq_trim = p_cod_maq_trim

         IF STATUS = 0 THEN
            INITIALIZE p_de_para_maq_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","de_para_maq_885")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  



#-----------------------------------#
 FUNCTION pol0604_emite_relatorio()
#-----------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","EMPRESA")            
      RETURN
   END IF

   DECLARE cq_de_para CURSOR FOR
    SELECT * 
      FROM de_para_maq_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_maq_trim, cod_recur

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","DE_PARA_MAQ_885")            
      RETURN
   END IF

   FOREACH cq_de_para INTO p_de_para_maq_885.*
   
      OUTPUT TO REPORT pol0604_relat() 

      LET p_count = 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0604_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 041, "INTEGRACAO LOGIX X TRIM",
               COLUMN 072, "PAG: ", PAGENO USING "&&&&"
               
         PRINT COLUMN 001, "pol0604",
               COLUMN 041, "DE-PARA MAQUINAS",
               COLUMN 064, TODAY USING "dd/mm/yy", " ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, " MAQ TRIM   MAQ LOGIX   EQUIPAMENTO       C TRAB   C CUST   ARRANJO   OPERACAO"
         PRINT COLUMN 001, " --------   ---------   ---------------   ------   ------   -------   --------"
      
      ON EVERY ROW

         PRINT COLUMN 002, p_de_para_maq_885.cod_maq_trim,
               COLUMN 013, p_de_para_maq_885.cod_recur,
               COLUMN 025, p_de_para_maq_885.cod_compon,
               COLUMN 043, p_de_para_maq_885.cod_cent_trab,
               COLUMN 052, p_de_para_maq_885.cod_cent_cust,
               COLUMN 061, p_de_para_maq_885.cod_arranjo,
               COLUMN 071, p_de_para_maq_885.cod_operac

      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 027, '* * * ULTIMA FOLHA * * *'
         
                        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#


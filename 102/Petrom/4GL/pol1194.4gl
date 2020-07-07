#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1194                                                 #
# OBJETIVO: ANÁLISE DE CRÉDITO                                      #
# AUTOR...: IVO BL                                                  #
# DATA....: 22/04/2013                                              #
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
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
                   
END GLOBALS

DEFINE pr_pergunta         ARRAY[30] OF RECORD
       cod_pergunta        LIKE perguntas_455.cod_pergunta,
       descricao           LIKE perguntas_455.descricao,
       val_formula         LIKE analise_pergunta_455.val_formula,
       val_comparativo     LIKE perguntas_455.val_comparativo,
       pct_peso            LIKE perguntas_455.pct_peso,
       debitar             LIKE analise_pergunta_455.ies_debitar
END RECORD

DEFINE pr_compl            ARRAY[30] OF RECORD
       pct_peso_lido       LIKE perguntas_455.pct_peso,
       formula             LIKE analise_pergunta_455.formula,
       tipo                CHAR(01),
       observacao          CHAR(600)
END RECORD

DEFINE p_tela               RECORD
       cod_cliente          LIKE analise_455.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente,
       prz_validade         LIKE analise_455.prz_validade,
       dat_refer_vigen      LIKE analise_455.dat_refer_vigen,
       dat_ini_vigencia     LIKE validade_indicador_455.dat_ini_vigencia,
       dat_fim_vigencia     LIKE validade_indicador_455.dat_fim_vigencia,
       num_processo         LIKE analise_455.num_processo,
       num_versao           LIKE analise_455.num_versao,          
       cod_status           LIKE analise_455.cod_status  
END RECORD

DEFINE p_telaa              RECORD
       cod_cliente          LIKE analise_455.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente,
       prz_validade         LIKE analise_455.prz_validade,
       dat_refer_vigen      LIKE analise_455.dat_refer_vigen,
       dat_ini_vigencia     LIKE validade_indicador_455.dat_ini_vigencia,
       dat_fim_vigencia     LIKE validade_indicador_455.dat_fim_vigencia,
       num_processo         LIKE analise_455.num_processo,
       num_versao           LIKE analise_455.num_versao,          
       cod_status           LIKE analise_455.cod_status  
END RECORD


DEFINE p_num_processo      LIKE analise_455.num_processo,
       p_num_versao        LIKE analise_455.num_versao,
       m_num_processo      LIKE analise_455.num_processo,
       m_num_versao        LIKE analise_455.num_versao,
       p_formula           LIKE analise_pergunta_455.formula,
       p_ind_formula       LIKE analise_pergunta_455.formula,
       p_operando          LIKE formulas_455.operando,
       p_tipo              LIKE formulas_455.tipo,
       p_cod_indicador     LIKE indicadores_455.cod_indicador,
       p_valor             CHAR(15),
       where_clause        CHAR(500),
       sql_stmt            CHAR(500),
       p_val_formula       DECIMAL(12,2),
       p_faturamento       DECIMAL(12,2),
       p_lucro             DECIMAL(12,2),
       p_val_refer         DECIMAL(12,2),
       p_val_credito       DECIMAL(12,2),
       p_val_analista      DECIMAL(12,2),
       p_val_gerente       DECIMAL(12,2),
       p_val_vendedor      DECIMAL(12,2),
       p_val_aprovador     DECIMAL(12,2),
       p_pct_desc          DECIMAL(5,2),
       p_dat_proces        DATE,
       p_funcao            CHAR(01),
       p_den_status        CHAR(30),
       p_debitar           CHAR(01),
       p_observacao        CHAR(600),
       p_cod_status        CHAR(10)

DEFINE p_analise           RECORD LIKE analise_455.*

DEFINE p_tip_docum      CHAR(05),
       p_num_docum      CHAR(10),
       p_cod_empre      CHAR(02),
       p_user_destino   CHAR(08),
       p_email_destino  CHAR(50),
       p_nom_destino    CHAR(50),
       p_user_emitente  CHAR(08),
       p_email_emitente CHAR(50),
       p_nom_emitente   CHAR(50),
       p_den_comando    CHAR(80),
       p_imp_linha      CHAR(80),
       p_den_docum      CHAR(30),
       p_titulo         CHAR(60),
       p_assunto        CHAR(30),
       p_cod_origem     CHAR(15),
       p_nom_origem     CHAR(10),
       p_arquivo        CHAR(30)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1194-10.02.04"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1194_controle()
   END IF
   
END MAIN

#--------------------------#
FUNCTION pol1194_controle()#
#--------------------------#

   SELECT COUNT(funcao)
     INTO p_count
     FROM usuario_funcao_455
    WHERE cod_usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','usuario_funcao_455')
      RETURN
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'Usuário não cadastrado no POL1187'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF
   
   IF p_count = 1 THEN
      SELECT funcao
        INTO p_funcao
        FROM usuario_funcao_455
       WHERE cod_usuario = p_user

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','usuario_funcao_455')
         RETURN
      END IF
   ELSE
      LET p_funcao = pol1194_sel_usuario()
   END IF
   
   IF p_funcao MATCHES '[AG]' THEN
   ELSE
      LET p_msg = 'Usuário na autorizado a\n',
                  'utilizar esse processo.\n',
                  'Consulte o POL1187.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF

   LET p_val_analista = 0
   LET p_val_gerente = 0
   LET p_val_vendedor = 0
   LET p_val_aprovador = 0
   
   IF pol1194_cria_temp() THEN
      CALL pol1194_menu()
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1194_sel_usuario()#
#-----------------------------#

   DEFINE pr_func         ARRAY[10] OF RECORD
          funcao          CHAR(01),
          descricao       CHAR(12)
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1194b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1194b AT 9,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_ind = 1
   LET INT_FLAG = FALSE
   
   DECLARE cq_user CURSOR FOR
    SELECT funcao FROM usuario_funcao_455
     WHERE cod_usuario = p_user

   FOREACH cq_user INTO pr_func[p_ind].funcao
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_user')
         RETURN ''
      END IF       
      
      CASE pr_func[p_ind].funcao
         WHEN 'A' LET pr_func[p_ind].descricao = 'Analista'
         WHEN 'G' LET pr_func[p_ind].descricao = 'Gerente'
         WHEN 'V' LET pr_func[p_ind].descricao = 'Vendedor'
         WHEN 'P' LET pr_func[p_ind].descricao = 'Aprovador'
      END CASE
      
      LET p_ind = p_ind + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_func TO sr_func.*

   LET p_ind = ARR_CURR()
   LET s_ind = SCR_LINE() 

   CLOSE WINDOW w_pol1194b
   
   RETURN pr_func[p_ind].funcao
   
END FUNCTION
   

#---------------------------#
FUNCTION pol1194_cria_temp()#
#---------------------------#

   CREATE TEMP TABLE val_formula_455(
	    valor           CHAR(80)
   );
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","VAL_FORMULA_455")
			RETURN FALSE
	 END IF
	 
	 INSERT INTO val_formula_455 VALUES(' ')

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","VAL_FORMULA_455")
			RETURN FALSE
	 END IF

   CREATE TEMP TABLE indicador_tmp_455 (
      cod_indicador	Char(05),
      valor       	Decimal(12,2)
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","INDICADOR_TMP_455")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------#
 FUNCTION pol1194_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1194") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1194 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1194_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1194_consulta() THEN
            ERROR 'Operação efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1194_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1194_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1194_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui análise do Gerente e retorna p/ a Analista"
         IF p_ies_cons THEN
            CALL pol1194_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND KEY ("R") "concluiR" "Concluir o processo de análise"
         IF p_ies_cons THEN
            CALL pol1194_concluir() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  

      #COMMAND "Listar" "Listagem dos registros cadastrados."
      #   CALL pol1194_listagem() RETURNING p_status

      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1194_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1194

END FUNCTION

#----------------------------#
FUNCTION pol1194_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1194_sobre()
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

#--------------------------#
 FUNCTION pol1194_inclusao()
#--------------------------#

   IF p_funcao = 'A' THEN
   ELSE
      LET p_msg = 'Somente o Analista de Cré-\n',
                  'dito pode incluir análise.\n',
                  'Consulte o POL1187.'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF

   CALL pol1194_limpa_tela()

   INITIALIZE p_tela TO NULL
   LET p_opcao = 'I'
   
   IF pol1194_edita_dados() THEN      
      IF pol1194_edita_pergunta() THEN    
         CALL log085_transacao("BEGIN")  
         IF pol1194_insere_tabelas() THEN 
            CALL log085_transacao("COMMIT")                                                    
            RETURN TRUE                                                                    
         END IF                           
         CALL log085_transacao("ROLLBACK")                                           
      END IF
   END IF

   CALL pol1194_limpa_tela()
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1194_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      BEFORE FIELD cod_cliente
         IF p_opcao = 'M' THEN
            NEXT FIELD prz_validade
         END IF
      
      AFTER FIELD cod_cliente
         IF p_tela.cod_cliente IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cliente   
         END IF
                            
         SELECT nom_cliente
           INTO p_tela.nom_cliente
           FROM clientes
          WHERE cod_cliente = p_tela.cod_cliente
       
         IF STATUS = 100 THEN
            ERROR "Cliente inixistente."
            NEXT FIELD cod_cliente
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('lendo','clientes')
               RETURN FALSE
            END IF 
         END IF

         DISPLAY p_tela.nom_cliente TO nom_cliente
      
      AFTER FIELD prz_validade

         IF p_tela.prz_validade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD prz_validade   
         END IF

         IF p_opcao = 'M' THEN
            EXIT INPUT
         END IF
      
      AFTER FIELD dat_refer_vigen
      
         IF p_tela.dat_refer_vigen IS NOT NULL THEN
            IF NOT pol1194_tem_indicadores() THEN
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD dat_refer_vigen
            END IF
            LET p_tela.dat_refer_vigen = p_tela.dat_fim_vigencia
            DISPLAY p_tela.dat_refer_vigen  TO dat_refer_vigen 
            DISPLAY p_tela.dat_ini_vigencia TO dat_ini_vigencia
            DISPLAY p_tela.dat_fim_vigencia TO dat_fim_vigencia
         END IF
      
      ON KEY (control-z)
         CALL pol1194_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF p_opcao = 'M' THEN
   ELSE   
      IF NOT pol1194_le_perguntas() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1194_tem_indicadores()#
#---------------------------------#

   SELECT DISTINCT
          dat_ini_vigencia,
          dat_fim_vigencia
     INTO p_tela.dat_ini_vigencia,
          p_tela.dat_fim_vigencia
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND dat_ini_vigencia <= p_tela.dat_refer_vigen
      AND dat_fim_vigencia >= p_tela.dat_refer_vigen

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'Não há indicadores cadastrados, \n',
                     'p/ a data de refeência informada.'
      ELSE
         LET p_msg = 'Erro (',STATUS,') lendo validade_indicador_455'
      END IF
      RETURN FALSE
   END IF

   SELECT DISTINCT cod_indicador
     INTO p_cod_indicador
     FROM pct_faturamento_455
     
   IF STATUS <> 0 THEN
      LET p_msg = 'Erro (',STATUS,') lendo pct_faturamento_455'
      RETURN FALSE
   END IF
   
   SELECT valor
     INTO p_faturamento
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND cod_indicador = p_cod_indicador
      AND dat_ini_vigencia = p_tela.dat_ini_vigencia
      AND dat_fim_vigencia = p_tela.dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Erro (',STATUS,') lendo validade_indicador_455'
      RETURN FALSE
   END IF
   
   SELECT DISTINCT cod_indicador
     INTO p_cod_indicador
     FROM pct_lucro_455
     
   IF STATUS <> 0 THEN
      LET p_msg = 'Erro (',STATUS,') lendo pct_lucro_455'
      RETURN FALSE
   END IF
   
   SELECT valor
     INTO p_lucro
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND cod_indicador = p_cod_indicador
      AND dat_ini_vigencia = p_tela.dat_ini_vigencia
      AND dat_fim_vigencia = p_tela.dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Erro (',STATUS,') lendo validade_indicador_455'
      RETURN FALSE
   END IF
   
   DELETE FROM indicador_tmp_455
   
   INSERT INTO indicador_tmp_455 (
      cod_indicador,
      valor) 
   SELECT cod_indicador, valor
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND dat_ini_vigencia = p_tela.dat_ini_vigencia
      AND dat_fim_vigencia = p_tela.dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Erro (',STATUS,') carregando indicador_tmp_455'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#-----------------------#
 FUNCTION pol1194_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CURRENT WINDOW IS w_pol1194
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE
   
END FUNCTION 
   
#------------------------------#
FUNCTION pol1194_le_perguntas()#
#------------------------------#

   INITIALIZE pr_pergunta, pr_compl TO NULL
   LET p_index = 1
   
   DECLARE cq_pergunta CURSOR FOR
    SELECT cod_pergunta,
           descricao,
           pct_peso,	      
           val_comparativo,
           tipo
      FROM perguntas_455
     ORDER BY descricao
   
   FOREACH cq_pergunta INTO 
      pr_pergunta[p_index].cod_pergunta,
      pr_pergunta[p_index].descricao,
      pr_pergunta[p_index].pct_peso,
      pr_pergunta[p_index].val_comparativo,
      pr_compl[p_index].tipo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pergunta')
         RETURN FALSE
      END IF
      
      LET pr_compl[p_index].pct_peso_lido = pr_pergunta[p_index].pct_peso
      LET pr_pergunta[p_index].val_formula = ''
      
      IF pr_compl[p_index].tipo = 'C' THEN
         IF NOT pol1194_calc_formula(pr_pergunta[p_index].cod_pergunta) THEN
            RETURN FALSE
         END IF
         IF NOT pol1194_ve_condicao(pr_pergunta[p_index].cod_pergunta) THEN
            RETURN FALSE
         END IF
         LET pr_pergunta[p_index].debitar = p_debitar
         LET pr_pergunta[p_index].val_formula = p_val_formula
         LET pr_compl[p_index].formula = p_ind_formula
      END IF
      
      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_pergunta 
      WITHOUT DEFAULTS FROM sr_pergunta.*
         BEFORE INPUT
         EXIT INPUT
   END INPUT

   IF NOT pol1194_calc_val_refer() THEN
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION pol1194_calc_formula(p_cod_pergunta)#
#--------------------------------------------#

   DEFINE p_cod_pergunta LIKE perguntas_455.cod_pergunta

   SELECT COUNT(cod_pergunta)
     INTO p_count
     FROM formulas_455
    WHERE cod_pergunta = p_cod_pergunta

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','formulas_455')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'Não a fórmula cadastrada\n',
                  'para a pergunta ',p_cod_pergunta CLIPPED,
                  'Use o POL1191, p/ cadstrar'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_formula = ''
   LET p_ind_formula = ''
   
   DECLARE cq_oper CURSOR FOR
    SELECT operando, tipo
      FROM formulas_455
     WHERE cod_pergunta = p_cod_pergunta
     ORDER BY num_sequencia
   
   FOREACH cq_oper INTO
      p_operando, p_tipo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','formulas_455')
         RETURN FALSE
      END IF
      
      LET p_ind_formula = p_ind_formula CLIPPED, p_operando CLIPPED
      
      IF p_tipo = 'I' THEN
         IF NOT pol1194_le_valor() THEN
            RETURN FALSE
         END IF
         LET p_formula = p_formula CLIPPED, p_valor
      ELSE
         LET p_formula = p_formula CLIPPED, p_operando CLIPPED
      END IF

   END FOREACH

   LET sql_stmt = "UPDATE val_formula_455 ",
                  "   SET valor = ",p_formula CLIPPED
   
   PREPARE upd FROM sql_stmt CLIPPED
   EXECUTE upd
   
   IF STATUS = -410 THEN
      LET p_msg = 'Ocorreu divisão por zero no cálcu-\n',
                  'lo da fórmula da pergunta ',p_cod_pergunta CLIPPED,'.\n',
                  'Utilize o POL1191 e corrija a\n',
                  'fórmula, ou utilize o POL1189 e\n',
                  'altere o valor do indicador que\n',
                  'está sendo usado como divisor.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN 
         LET p_cod_status = STATUS
         LET p_msg = 'Pergunta: ', p_cod_pergunta, 
               '\n EERO ', p_cod_status CLIPPED, ' CALCULANDO FÓRMULA\n ', p_formula
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   END IF
   
   SELECT valor INTO p_val_formula FROM val_formula_455

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT","VAL_FORMULA_455")    
      RETURN FALSE
   END IF
   
   RETURN TRUE           

END FUNCTION

#-------------------------------------------#
FUNCTION pol1194_ve_condicao(p_cod_pergunta)#
#-------------------------------------------#

   DEFINE p_cod_pergunta LIKE perguntas_455.cod_pergunta,
          p_condicao     LIKE perguntas_455.condicao_debitar

   LET p_retorno = 'N'
   
   SELECT condicao_debitar
      INTO p_condicao
      FROM perguntas_455
     WHERE cod_pergunta = p_cod_pergunta
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','formulas_455')
      RETURN FALSE
   END IF
   
   CASE p_condicao
      WHEN '>' 
         IF p_val_formula > pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
      WHEN '>=' 
         IF p_val_formula >= pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
      WHEN '<' 
         IF p_val_formula < pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
      WHEN '<=' 
         IF p_val_formula <= pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
      WHEN '=' 
         IF p_val_formula = pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
      WHEN '<>' 
         IF p_val_formula <> pr_pergunta[p_index].val_comparativo THEN
            LET p_debitar = "S"
         ELSE
            LET p_debitar = "N"
         END IF
   END CASE
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1194_le_valor()#
#--------------------------#
   
   DEFINE p_val_indic INTEGER
   
   SELECT valor
     INTO p_val_indic
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND cod_indicador = p_operando
      AND dat_ini_vigencia = p_tela.dat_ini_vigencia
      AND dat_fim_vigencia = p_tela.dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','validade_indicador_455')
      RETURN FALSE
   END IF
   
   LET p_valor = p_val_indic
   
   RETURN TRUE

END FUNCTION   
   
#--------------------------------#   
FUNCTION pol1194_calc_val_refer()#
#--------------------------------#

   DEFINE p_pct_aplicado	 DECIMAL(4,2) 
   
   IF p_faturamento < 0 THEN
      LET p_val_refer = 0
   ELSE
      SELECT pct_aplicado
        INTO p_pct_aplicado
        FROM pct_faturamento_455
       WHERE valor_de  <= p_faturamento
         AND valor_ate >= p_faturamento
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','pct_faturamento_455')
         RETURN FALSE
      END IF
   
      LET p_val_refer = p_faturamento * p_pct_aplicado / 100
   END IF
   
   IF p_lucro >= 0 THEN
      SELECT pct_aplicado
        INTO p_pct_aplicado
        FROM pct_lucro_455
       WHERE valor_de  <= p_lucro 
         AND valor_ate >= p_lucro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','pct_lucro_455')
         RETURN FALSE
      END IF

      LET p_val_refer = (p_val_refer + (p_lucro * p_pct_aplicado / 100))
   END IF
   
   DISPLAY p_val_refer TO val_referencia
   
   RETURN TRUE

END FUNCTION
   
#---------------------------------#
 FUNCTION pol1194_edita_pergunta()#
#---------------------------------#     

   INPUT ARRAY pr_pergunta
      WITHOUT DEFAULTS FROM sr_pergunta.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
         CALL pol1194_val_credito()
         DISPLAY p_val_credito to val_credito

      AFTER FIELD pct_peso
      
         IF pr_pergunta[p_index].pct_peso IS NULL THEN
           IF pr_pergunta[p_index].cod_pergunta IS NOT NULL THEN
              ERROR 'Campo com preenchimento obrigatório!'
              NEXT FIELD pct_peso
           END IF       
        ELSE
           IF pr_pergunta[p_index].cod_pergunta IS NULL THEN
              ERROR 'Essa linha da grade não deve ser preenchida' 
              NEXT FIELD pct_peso
           END IF       
        END IF
        
      AFTER FIELD debitar
      
         IF pr_pergunta[p_index].debitar IS NULL THEN
           IF pr_pergunta[p_index].cod_pergunta IS NOT NULL THEN
              ERROR 'Campo com preenchimento obrigatório!'
              NEXT FIELD debitar
           END IF       
        ELSE
           IF pr_pergunta[p_index].cod_pergunta IS NULL THEN
              LET pr_pergunta[p_index].debitar = NULL
              DISPLAY '' TO sr_pergunta[s_index].debitar 
           END IF       
        END IF         
     
     AFTER ROW         

        IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
             OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
        ELSE
           IF pr_pergunta[p_index].cod_pergunta IS NULL THEN
              NEXT FIELD pct_peso
           END IF       
        END IF
      
      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            FOR p_ind = 1 TO ARR_COUNT()
                IF pr_pergunta[p_ind].debitar IS NULL AND 
                      pr_pergunta[p_ind].cod_pergunta IS NOT NULL THEN
                   ERROR 'Preencha corretamente a coluna Debitar'
                   NEXT FIELD debitar
                END IF
             END FOR
          END IF

      ON KEY (control-d)
         CALL pol1194_detalhes()
      ON KEY (control-o)
         CALL pol1194_observacao()
                 
   END INPUT 

   IF INT_FLAG THEN
      IF p_opcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1194_exibe_dados() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-----------------------------#
FUNCTION pol1194_val_credito()#
#-----------------------------#

   LET p_pct_desc = 0
   
   FOR p_ind = 1 to ARR_COUNT()
       IF pr_pergunta[p_ind].debitar = 'S' THEN
          LET p_pct_desc = p_pct_desc + pr_pergunta[p_ind].pct_peso
       END IF
   END FOR
   
   LET p_val_credito = p_val_refer * ((100 - p_pct_desc) / 100)  
   
END FUNCTION       

#--------------------------#
FUNCTION pol1194_detalhes()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1194a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1194a AT 04,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY pr_pergunta[p_index].cod_pergunta TO cod_pergunta
   DISPLAY pr_pergunta[p_index].descricao TO descricao
   
   IF pr_compl[p_index].tipo = 'R' THEN
      DISPLAY 'Repondida' TO tipo
   ELSE
      DISPLAY 'Calculada' TO tipo
   END IF
   
   DISPLAY pr_compl[p_index].formula TO formula
   DISPLAY p_faturamento TO faturamento
   DISPLAY p_lucro TO lucro

   CALL pol1194_exibe_indicadores()
   
   LET INT_FLAG = FALSE
   CLOSE WINDOW w_pol1194a

END FUNCTION

#-----------------------------------#
FUNCTION pol1194_exibe_indicadores()#
#-----------------------------------# 

   DEFINE pr_indicador ARRAY[50] OF RECORD
      cod_indicador    LIKE indicadores_455.cod_indicador,
      des_indicador    LIKE indicadores_455.descricao,
      val_indicador    LIKE validade_indicador_455.valor
   END RECORD
   
   LET p_ind = 1
   
   DECLARE cq_exib CURSOR FOR
    SELECT t.cod_indicador,
           i.descricao,
           t.valor
      FROM indicador_tmp_455 t
           LEFT OUTER JOIN indicadores_455 i
             ON i.cod_indicador = t.cod_indicador

   FOREACH cq_exib INTO 
      pr_indicador[p_ind].cod_indicador,
      pr_indicador[p_ind].des_indicador,
      pr_indicador[p_ind].val_indicador

      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH", "cq_exib")
         RETURN
      END IF 
      
      LET p_ind = p_ind + 1
   
      IF p_ind > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   DISPLAY ARRAY pr_indicador TO sr_indicador.*
   
END FUNCTION

#----------------------------#
FUNCTION pol1194_observacao()#
#----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1194c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1194c AT 05,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1194_edita_observacao()
   
   LET INT_FLAG = FALSE
   CLOSE WINDOW w_pol1194a

END FUNCTION

#----------------------------------#
FUNCTION pol1194_edita_observacao()#
#----------------------------------#

   LET p_observacao = pr_compl[p_index].observacao

   {SELECT observacao
     INTO p_observacao
     FROM analise_pergunta_455
    WHERE cod_cliente  = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao   = p_tela.num_versao
      AND cod_pergunta = pr_pergunta[p_index].cod_pergunta

   IF STATUS = 100 THEN
      LET p_observacao = ''
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','analise_pergunta_455')
         RETURN
      END IF
   END IF}
   
   LET INT_FLAG = FALSE
   
   INPUT p_observacao 
      WITHOUT DEFAULTS FROM observacao
      
      AFTER FIELD observacao
      
   END INPUT

   IF NOT INT_FLAG THEN
      LET pr_compl[p_index].observacao = p_observacao
   END IF
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol1194_insere_tabelas()#
#---------------------------------#
   
   LET p_dat_proces = TODAY

   IF p_opcao = 'I' THEN
      IF NOT pol1194_num_processo() THEN
         RETURN FALSE
      END IF
   END IF
   
   CALL pol1194_set_dados()
   
   IF NOT pol1194_ins_analise() THEN
      RETURN FALSE
   END IF

   IF NOT pol1194_ins_perguntas() THEN
      RETURN FALSE
   END IF

   IF p_opcao = 'I' THEN
      IF NOT pol1194_ins_indicadores() THEN
         RETURN FALSE
      END IF
   END IF

   DISPLAY p_tela.num_processo TO num_processo
   DISPLAY p_tela.num_versao   TO num_versao
   DISPLAY p_tela.cod_status   TO cod_status
   LET p_den_status = pol1194_den_status()
   DISPLAY p_den_status TO den_status        
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1194_den_status()#
#----------------------------#

   IF p_tela.cod_status = 1 THEN
      RETURN 'Sob a avaliação do Analista'
   ELSE
      IF p_tela.cod_status = 2 THEN
         RETURN 'Sob a valiação do Gerente'
      ELSE
         IF p_tela.cod_status = 3 THEN
            RETURN 'Aguardando aprovação'
         ELSE 
            RETURN 'Aprovado'
         END IF
      END IF
   END IF
   
END FUNCTION
            
#------------------------------#
FUNCTION pol1194_num_processo()#
#------------------------------#
   
   INITIALIZE p_analise TO NULL
   
   SELECT MAX(num_processo)
     INTO p_num_processo
     FROM analise_455
    WHERE cod_cliente = p_tela.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','analise_455')
      RETURN FALSE
   END IF    
   
   IF p_num_processo IS NULL THEN
      LET p_num_processo = 0
   END IF
   
   LET p_num_processo = p_num_processo + 1
   LET p_tela.num_processo = p_num_processo
   LET p_tela.num_versao = 1
   LET p_tela.cod_status = 1
   LET p_val_analista = p_val_credito

   RETURN TRUE

END FUNCTION      

#---------------------------#
FUNCTION pol1194_set_dados()#
#---------------------------#

   LET p_analise.cod_cliente	     = p_tela.cod_cliente
   LET p_analise.num_processo	     = p_tela.num_processo
   LET p_analise.num_versao	       = p_tela.num_versao
   LET p_analise.val_credito	     = p_val_credito
   LET p_analise.val_referencia	   = p_val_refer
   LET p_analise.val_analista 	   = p_val_analista
   LET p_analise.val_gerente  	   = p_val_gerente
   LET p_analise.val_vendedor  	   = p_val_vendedor
   LET p_analise.val_aprovador 	   = p_val_aprovador
   LET p_analise.prz_validade	     = p_tela.prz_validade
   LET p_analise.dat_inclusao	     = p_dat_proces
   LET p_analise.dat_alteracao	   = NULL
   LET p_analise.cod_status	       = p_tela.cod_status
   LET p_analise.usuario_inclusao	 = p_user
   LET p_analise.usuario_alteracao = NULL
   LET p_analise.dat_refer_vigen	 = p_tela.dat_refer_vigen

END FUNCTION      

#-----------------------------#
FUNCTION pol1194_ins_analise()#
#-----------------------------#

   INSERT INTO analise_455
      VALUES(p_analise.*)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT", "analise_455")
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION      

#-------------------------------#
FUNCTION pol1194_ins_perguntas()#
#-------------------------------#
   
   DELETE FROM analise_pergunta_455
    WHERE cod_cliente = p_analise.cod_cliente
      AND num_processo = p_analise.num_processo
      AND num_versao = p_analise.num_versao
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "analise_pergunta_455")
      RETURN FALSE
   END IF 

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_pergunta[p_ind].cod_pergunta IS NOT NULL THEN

		      LET p_formula = pr_compl[p_ind].formula
		      LET p_val_formula = pr_pergunta[p_ind].val_formula
          
		      INSERT INTO analise_pergunta_455
		       VALUES (p_analise.cod_cliente,
		               p_analise.num_processo,
		               p_analise.num_versao,
		               pr_pergunta[p_ind].cod_pergunta,
		               pr_compl[p_ind].pct_peso_lido,
		               pr_pergunta[p_ind].pct_peso,
		               p_formula,
		               p_val_formula,
		               pr_pergunta[p_ind].val_comparativo,
		               pr_pergunta[p_ind].debitar,
		               pr_compl[p_ind].observacao)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "analise_pergunta_455")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   RETURN TRUE
      
END FUNCTION

#---------------------------------#
FUNCTION pol1194_ins_indicadores()#
#---------------------------------#

   DECLARE cq_indicador CURSOR FOR
    SELECT cod_indicador,
           valor
      FROM indicador_tmp_455

   FOREACH cq_indicador INTO p_cod_indicador, p_valor

      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH", "cq_indicador")
         RETURN FALSE
      END IF 
          
		  INSERT INTO analise_indicador_455
		    VALUES (p_analise.cod_cliente,
		            p_analise.num_processo,
		            p_analise.num_versao,
		            p_cod_indicador,
		            p_valor)
		
		  IF STATUS <> 0 THEN 
		     CALL log003_err_sql("INSERT", "analise_indicador_455")
		     RETURN FALSE
		  END IF

   END FOREACH
         
   RETURN TRUE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1194_consulta()
#--------------------------#

   CALL pol1194_limpa_tela()
   LET p_telaa.* = p_tela.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      analise_455.cod_cliente,
      analise_455.dat_refer_vigen,
      analise_455.num_processo,
      analise_455.num_versao,
      analise_455.cod_status
      
      ON KEY (control-z)
         CALL pol1194_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      CALL pol1194_limpa_tela()
      IF p_ies_cons THEN 
         IF p_excluiu THEN
         ELSE
            LET p_tela.* = p_telaa.*
            CALL pol1194_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt = 
          "SELECT DISTINCT cod_cliente, ",
          " num_processo, num_versao, cod_status ",
          "  FROM analise_455 ",
          " WHERE ", where_clause CLIPPED,
          " ORDER BY cod_cliente, num_processo, cod_status"

   IF p_opcao = 'L' THEN
      RETURN TRUE
   END IF

   LET p_ies_cons = FALSE

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO 
      p_tela.cod_cliente,
      p_tela.num_processo,
      p_tela.num_versao,
      p_tela.cod_status

   IF STATUS = 0 THEN
      IF pol1194_exibe_dados() THEN
         LET p_ies_cons = TRUE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      ELSE
         CALL log003_err_sql('FOREACH','cq_padrao')
      END IF
   END IF
   
   RETURN p_ies_cons

END FUNCTION

#------------------------------#
 FUNCTION pol1194_exibe_dados()
#------------------------------#

   LET p_excluiu = FALSE

   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','clientes')
      RETURN FALSE 
   END IF

   SELECT val_credito,
          val_referencia,
          prz_validade,
          cod_status,
          dat_refer_vigen,
          val_analista,
          val_gerente
     INTO p_val_credito,
          p_val_refer,
          p_tela.prz_validade,
          p_tela.cod_status,
          p_tela.dat_refer_vigen,
          p_val_analista,
          p_val_gerente
     FROM analise_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao = p_tela.num_versao
      AND cod_status = p_tela.cod_status
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','analise_455')
      RETURN FALSE 
   END IF
   
   IF NOT pol1194_tem_indicadores() THEN
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_tela.*
   LET p_den_status = pol1194_den_status()   
   DISPLAY p_den_status TO den_status        
   
   IF NOT pol1194_monta_grade() THEN
      RETURN FALSE
   END IF
   
   DISPLAY p_val_refer TO val_referencia
   DISPLAY p_val_credito TO val_credito
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1194_monta_grade()#
#-----------------------------#

   INITIALIZE pr_pergunta, pr_compl TO NULL
   LET p_index = 1

   DECLARE cq_grade CURSOR FOR
    SELECT analise_pergunta_455.cod_pergunta,
           analise_pergunta_455.peso_cadastrado,	      
           analise_pergunta_455.peso_informado,
           analise_pergunta_455.formula,
           analise_pergunta_455.val_formula,
           analise_pergunta_455.val_comparativo,
           analise_pergunta_455.ies_debitar,
           perguntas_455.descricao,
           perguntas_455.tipo,
           analise_pergunta_455.observacao
      FROM analise_pergunta_455, perguntas_455
     WHERE analise_pergunta_455.cod_cliente = p_tela.cod_cliente
       AND analise_pergunta_455.num_processo = p_tela.num_processo
       AND analise_pergunta_455.num_versao = p_tela.num_versao
       AND perguntas_455.cod_pergunta = analise_pergunta_455.cod_pergunta
     ORDER BY perguntas_455.descricao
   
   FOREACH cq_grade INTO 
      pr_pergunta[p_index].cod_pergunta,
      pr_compl[p_index].pct_peso_lido,
      pr_pergunta[p_index].pct_peso,
      pr_compl[p_index].formula,
      pr_pergunta[p_index].val_formula,
      pr_pergunta[p_index].val_comparativo,
      pr_pergunta[p_index].debitar,
      pr_pergunta[p_index].descricao,
      pr_compl[p_index].tipo,
      pr_compl[p_index].observacao
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_grade')
         RETURN FALSE
      END IF
            
      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_pergunta 
      WITHOUT DEFAULTS FROM sr_pergunta.*
         BEFORE INPUT
         EXIT INPUT
   END INPUT

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1194_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_telaa.* = p_tela.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
              p_tela.cod_cliente, p_tela.num_processo, p_tela.num_versao, p_tela.cod_status
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
              p_tela.cod_cliente, p_tela.num_processo, p_tela.num_versao, p_tela.cod_status
         
      END CASE

      IF STATUS = 0 THEN
         
         SELECT COUNT(cod_cliente)
           INTO p_count
           FROM analise_455
          WHERE cod_cliente  = p_tela.cod_cliente
            AND num_processo = p_tela.num_processo
            AND num_versao = p_tela.num_versao
            AND cod_status = p_tela.cod_status
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "analise_455")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1194_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tela.* = p_telaa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1194_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_cliente 
      FROM analise_455  
     WHERE cod_cliente  = p_tela.cod_cliente
       AND num_processo = p_tela.num_processo
       AND num_versao = p_tela.num_versao
       AND cod_status = p_tela.cod_status
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","analise_455")
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1194_checa_permissao()#
#---------------------------------#

   IF p_funcao = 'A' THEN
      IF p_tela.cod_status = '1' AND p_tela.num_versao = 1 THEN
      ELSE
         LET p_msg = 'O registro da tela só está\n',
                     'disponível para consulta.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   ELSE
      IF p_tela.cod_status = '2' AND p_tela.num_versao = 2 THEN
      ELSE
         LET p_msg = 'O registro da tela só está\n',
                     'disponível para consulta.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION
   
#-----------------------------#
 FUNCTION pol1194_modificacao()
#-----------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o processo a modificar !!!", "exclamation")
      RETURN FALSE
   END IF
   
   IF NOT pol1194_checa_permissao() THEN
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   LET p_dat_proces = TODAY
   
   IF NOT pol1194_carrega_indicadores() THEN
      RETURN FALSE
   END IF
      
   IF pol1194_prende_registro() THEN
     IF pol1194_edita_dados() THEN
      IF pol1194_edita_pergunta() THEN
         IF pol1194_modify_tabelas() THEN
            LET p_retorno = TRUE
         END IF
      END IF
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

#-------------------------------------#
FUNCTION pol1194_carrega_indicadores()#
#-------------------------------------#

   DELETE FROM indicador_tmp_455
   
   INSERT INTO indicador_tmp_455 (
      cod_indicador,
      valor) 
   SELECT cod_indicador, val_indicador
     FROM analise_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','indicador_tmp_455')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1194_modify_tabelas()#
#--------------------------------#
   
   IF p_funcao = 'A' THEN
      LET p_val_analista = p_val_credito
      LET p_val_gerente = 0
   ELSE
      LET p_val_gerente = p_val_credito
   END IF
   
   UPDATE analise_455
      SET val_credito = p_val_credito,
          val_analista = p_val_analista,
          val_gerente = p_val_gerente,
          prz_validade = p_tela.prz_validade,
          dat_alteracao = p_dat_proces,
          usuario_alteracao = p_user
    WHERE cod_cliente = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao = p_tela.num_versao   
      AND cod_status = p_tela.cod_status       
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','analise_455')
      RETURN FALSE
   END IF
   
   LET p_analise.cod_cliente   = p_tela.cod_cliente 
   LET p_analise.num_processo = p_tela.num_processo
   LET p_analise.num_versao   = p_tela.num_versao
   
   IF NOT pol1194_ins_perguntas() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1194_exclusao()
#--------------------------#
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o processo a excluír !!!", "exclamation")
      RETURN FALSE
   END IF

   IF NOT pol1194_checa_permissao() THEN
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1194_prende_registro() THEN
      IF pol1194_deleta_tabelas() THEN
         CALL pol1194_limpa_tela()
         LET p_excluiu = TRUE
         LET p_retorno = TRUE                       
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   LET p_opcao = 'E'
   
   IF NOT pol1194_email() THEN
      LET p_msg = 'A análise foi concluída\n',
                  'com sucesso, porém, houve\n',
                  'erro no envio do email ao\n',
                  'Gerente.'
      CALL log003_err_sql(p_msg,'excla')
   ELSE
      IF p_houve_erro THEN
         LET p_msg = 'A análise foi concluída\n',
                     'com sucesso, porém, há\n',
                     'usuário sem email cadas-\n',
                     'do no Logix.'
         CALL log003_err_sql(p_msg,'excla')
      END IF
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------------#
FUNCTION pol1194_deleta_tabelas()#
#--------------------------------#

   DELETE FROM analise_455
    WHERE cod_cliente  = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao = p_tela.num_versao
         
   IF STATUS <> 0 THEN               
      CALL log003_err_sql('DELETE','analise_455')
      RETURN FALSE
   END IF

   IF p_funcao = 'G' THEN
      UPDATE analise_455
         SET cod_status = 1,
             usuario_alteracao = p_user
       WHERE cod_cliente  = p_tela.cod_cliente
         AND num_processo = p_tela.num_processo
         AND num_versao = 1
      IF STATUS <> 0 THEN               
         CALL log003_err_sql('UPDATE','analise_indicador_455')
         RETURN FALSE
      END IF
   ELSE
      DELETE FROM analise_indicador_455
       WHERE cod_cliente  = p_tela.cod_cliente
         AND num_processo = p_tela.num_processo
         AND num_versao = p_tela.num_versao
         
      IF STATUS <> 0 THEN               
         CALL log003_err_sql('DELETE','analise_indicador_455')
         RETURN FALSE
      END IF
   END IF
        
   DELETE FROM analise_pergunta_455
    WHERE cod_cliente  = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao = p_tela.num_versao
         
   IF STATUS <> 0 THEN               
      CALL log003_err_sql('DELETE','analise_pergunta_455')
      RETURN FALSE
   END IF

   DELETE FROM analise_usuario_455
    WHERE cod_cliente  = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
         
   IF STATUS <> 0 THEN               
      CALL log003_err_sql('DELETE','analise_usuario_455')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1194_concluir()#
#--------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o processo a concluir !!!", "exclamation")
      RETURN FALSE
   END IF

   IF NOT pol1194_checa_permissao() THEN
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
      
   LET p_opcao = 'R'
   
   IF p_funcao = 'A' THEN
      LET p_tela.cod_status = 2
   ELSE
      LET p_tela.cod_status = 3
   END IF

   CALL log085_transacao("BEGIN")  

   UPDATE analise_455
      SET cod_status = p_tela.cod_status,
          usuario_alteracao = p_user
    WHERE cod_cliente = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      #AND num_versao = p_tela.num_versao          
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','analise_455')
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF

   IF p_funcao = 'A' THEN
      LET p_tela.num_versao = 2
      LET p_val_gerente = p_val_analista
      CALL pol1194_insere_tabelas() RETURNING p_status
   ELSE
      LET p_status = TRUE
      DISPLAY p_tela.cod_status to cod_status
   END IF
         
   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   IF NOT pol1194_ins_analise_usuario() THEN
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF

   LET p_den_status = pol1194_den_status()
   DISPLAY p_den_status TO den_status        

   CALL log085_transacao("COMMIT")  
   
   LET p_excluiu = TRUE

   LET p_opcao = 'C'
   
   IF NOT pol1194_email() THEN
      LET p_msg = 'A análise foi concluída\n',
                  'com sucesso, porém, houve\n',
                  'erro no envio do email ao\n',
                  'Gerente.'
      CALL log003_err_sql(p_msg,'excla')
   ELSE
      IF p_houve_erro THEN
         LET p_msg = 'A análise foi concluída\n',
                     'com sucesso, porém, há\n',
                     'usuário sem email cadas-\n',
                     'do no Logix.'
         CALL log003_err_sql(p_msg,'excla')
      END IF
   END IF
   
   CALL pol1194_limpa_tela()
      
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1194_ins_analise_usuario()#
#-------------------------------------#

   INSERT INTO analise_usuario_455
      (cod_cliente,
       num_processo,
       num_versao,
       cod_usuario,
       funcao) 
    VALUES(p_tela.cod_cliente,
           p_tela.num_processo,
           p_tela.num_versao,
           p_user,
           p_funcao)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'analise_usuario_455')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1194_email()#
#-----------------------#

   IF NOT pol1194_cria_tabs() THEN
      RETURN FALSE
   END IF

   IF NOT pol1194_grava_tab_email() THEN
      RETURN FALSE
   END IF

   IF NOT pol1194_envia_email() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1194_cria_tabs()#
#---------------------------#

   DROP TABLE envia_email_912
   CREATE TEMP TABLE envia_email_912  (
    cod_origem     CHAR(15),
    nom_origem     CHAR(10),
    num_docum      CHAR(10),
    num_versao     CHAR(03),
    tip_docum      CHAR(05),
    cod_empresa    CHAR(02),
    cod_usuario    CHAR(10),
    email_usuario  CHAR(50),
    nom_usuario    CHAR(50),
    cod_emitente   CHAR(10),
    email_emitente CHAR(50),
    nom_emitente   CHAR(50)
  );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","envia_email_912")
			RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1194_grava_tab_email()#
#---------------------------------#

   DEFINE p_email  RECORD
    cod_origem     CHAR(15),
    nom_origem     CHAR(10),
    num_docum      CHAR(10),
    num_versao     CHAR(03),
    tip_docum      CHAR(05),
    cod_empresa    CHAR(02),
    cod_usuario    CHAR(10),
    email_usuario  CHAR(50),
    nom_usuario    CHAR(50),
    cod_emitente   CHAR(10),
    email_emitente CHAR(50),
    nom_emitente   CHAR(50)
   END RECORD
   
   LET p_email.cod_origem = p_tela.cod_cliente
   LET p_email.nom_origem = 'Cliente'
   LET p_email.num_docum = p_tela.num_processo
   LET p_email.num_versao = p_tela.num_versao
   LET p_email.cod_empresa = p_cod_empresa
   LET p_email.cod_emitente = p_user
   
   SELECT nom_funcionario,
          e_mail
     INTO p_email.nom_emitente,
          p_email.email_emitente
     FROM usuarios
    WHERE cod_usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','usuarios')
      RETURN FALSE
   END IF   

   IF p_funcao = 'A' THEN
      LET p_email.tip_docum = 'ANC'
      LET sql_stmt = 
          " SELECT uf.cod_usuario, u.nom_funcionario, u.e_mail ",
          "   FROM usuario_funcao_455 uf, usuarios u ",
          "  WHERE uf.funcao = 'G' AND uf.cod_usuario = u.cod_usuario"
   ELSE
      IF p_opcao = 'C' THEN
         LET p_email.tip_docum = 'GEC'
         LET sql_stmt = 
             " SELECT uf.cod_usuario, u.nom_funcionario, u.e_mail ",
             "   FROM usuario_funcao_455 uf, usuarios u ",
             "  WHERE uf.funcao IN ('V','P') AND uf.cod_usuario = u.cod_usuario"
      ELSE
         LET p_email.tip_docum = 'GEE'
         LET sql_stmt = 
             " SELECT uf.cod_usuario, u.nom_funcionario, u.e_mail ",
             "   FROM usuario_funcao_455 uf, usuarios u ",
             "  WHERE uf.funcao = 'A' AND uf.cod_usuario = u.cod_usuario"
      END IF      
   END IF
   
   PREPARE var_dest FROM sql_stmt   
   DECLARE cq_destino CURSOR FOR var_dest
   
   FOREACH cq_destino INTO 
      p_email.cod_usuario, p_email.nom_usuario, p_email.email_usuario
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_destino')
         RETURN FALSE
      END IF
      
      INSERT INTO envia_email_912
        VALUES(p_email.*)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','envia_email_912')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1194_envia_email()#
#-----------------------------#

   LET p_assunto = 'Conclusão análise de crédito'
   LET p_houve_erro = FALSE
   
   DECLARE cq_le_de CURSOR FOR
    SELECT DISTINCT
           cod_emitente,
           email_emitente,
           nom_emitente,
           tip_docum
      FROM envia_email_912
     ORDER BY cod_emitente

   FOREACH cq_le_de INTO p_user_emitente, p_email_emitente, p_nom_emitente, p_tip_docum

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','envia_email_912:cq_le_de')
         RETURN FALSE
      END IF
     
      DECLARE cq_le_para CURSOR FOR
       SELECT DISTINCT 
              cod_usuario, 
              email_usuario,
              nom_usuario
         FROM envia_email_912
        WHERE cod_emitente = p_user_emitente
   
      FOREACH cq_le_para INTO p_user_destino, p_email_destino, p_nom_destino 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','envia_email_912:cq_le_para')
            RETURN FALSE
         END IF

         SELECT nom_caminho
           INTO p_den_comando
           FROM log_usu_dir_relat 
          WHERE usuario = p_user_destino
            AND empresa = p_cod_empresa 
            AND sistema_fonte = 'LST' 
            AND ambiente = g_ies_ambiente
  
         IF STATUS <> 0 THEN
            LET p_msg = 'CAMINHO DO RELATORIO NAO CADASTRADO P/ USUARIO ', p_user_destino
            CALL log0030_mensagem(p_msg,'excla')
            CONTINUE FOREACH
         END IF

         CASE p_tip_docum

            WHEN 'ANC' 
               LET p_titulo = 'Análise de crédito concluída'
         
            WHEN 'GEC'
               LET p_titulo = 'Análise de crédito, p/ sua apreciação e/ou aprovação'
            
            WHEN 'GEE'
               LET p_titulo = 'Análise de crédito rejeitada p/ sua reavaliação'

         END CASE
            
         LET p_arquivo = p_user_emitente CLIPPED, '-', p_user_destino CLIPPED, '.lst'
         LET p_den_comando = p_den_comando CLIPPED, p_arquivo
         
         START REPORT pol1194_relat TO p_den_comando
      
         DECLARE cq_le_docs CURSOR FOR
          SELECT num_docum,
                 cod_empresa,
                 cod_origem,
                 nom_origem
            FROM envia_email_912
           WHERE cod_usuario  = p_user_destino
             AND cod_emitente = p_user_emitente
             AND tip_docum = p_tip_docum   
           ORDER BY cod_empresa, num_docum     

         FOREACH cq_le_docs INTO  
                 p_num_docum,     
                 p_cod_empre,
                 p_cod_origem,
                 p_nom_origem

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','envia_email_912:cq_le_docs')
               EXIT FOREACH
            END IF
                  
            LET p_imp_linha = p_nom_origem CLIPPED,':',p_cod_origem CLIPPED, 
                   ' - Processo:',p_num_docum CLIPPED
         
            OUTPUT TO REPORT pol1194_relat() 
      
         END FOREACH

         FINISH REPORT pol1194_relat  
      
         IF p_email_emitente IS NULL OR p_email_destino IS NULL THEN
            LET p_houve_erro = TRUE
         ELSE
            CALL log5600_envia_email(p_email_emitente, p_email_destino, p_assunto, p_den_comando, 2)
         END IF
            
      END FOREACH
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION


#---------------------#
 REPORT pol1194_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, 'A/C. ', p_nom_destino
         PRINT
         PRINT COLUMN 001, p_titulo
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 001, p_nom_emitente
        
END REPORT


{                                
#--------------------------#     
 FUNCTION pol1194_listagem()     
#--------------------------#     
                                 

   LET p_telaa.* = p_tela.*
   
   LET p_opcao = 'L'
   
   IF NOT pol1194_consulta() THEN
      ERROR 'Operação cancelada.'
      RETURN FALSE
   END IF
   
   IF NOT pol1194_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1194_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   PREPARE query FROM sql_stmt   
   DECLARE cq_impressao CURSOR  FOR query

   FOREACH cq_impressao INTO
      p_tela.cod_cliente,
      p_tela.dat_ini_vigencia,
      p_tela.dat_fim_vigencia
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_impressao')
         EXIT FOREACH
      END IF 
   
      SELECT nom_cliente
        INTO p_tela.nom_cliente
        FROM clientes
       WHERE cod_cliente = p_tela.cod_cliente
      
      IF STATUS <> 0 THEN
         LET p_tela.nom_cliente = ''
      END IF                                                             
     
      OUTPUT TO REPORT pol1194_relat(p_tela.cod_cliente) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1194_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   IF p_ies_cons THEN
      LET p_tela.* = p_telaa.*
      CALL pol1194_exibe_dados()
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1194_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1194_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1194.tmp'
         START REPORT pol1194_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1194_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1194_le_den_empresa()
#--------------------------------#

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

#-----------------------------------#
 REPORT pol1194_relat(p_cod_cliente)#
#-----------------------------------#
    
   DEFINE p_cod_cliente   LIKE clientes.cod_cliente,
          p_cod_indicador LIKE indicadores_455.cod_indicador,
          p_valor         LIKE analise_455.valor,
          p_descricao     LIKE indicadores_455.descricao
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1194   VALIDADE DOS INDICADORES P/ ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1194   VALIDADE DOS INDICADORES P/ ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
               
      BEFORE GROUP OF p_cod_cliente

         SKIP TO TOP OF PAGE
                            
      ON EVERY ROW

         PRINT
         PRINT COLUMN 005, 'Cliente:  ', p_tela.cod_cliente CLIPPED, ' - ', p_tela.nom_cliente CLIPPED
         PRINT COLUMN 005, 'Vigencia: ', p_tela.dat_ini_vigencia, ' - ', p_tela.dat_fim_vigencia
         PRINT
         PRINT COLUMN 001, 'INDCADOR         DESCRICAO                     VALOR'
         PRINT COLUMN 001, '--------  ------------------------------  ----------------'

         DECLARE cq_imp CURSOR FOR
           SELECT v.cod_indicador,
                  v.valor,
                  i.descricao
             FROM analise_455  v
                  LEFT OUTER JOIN indicadores_455 i
                    ON i.cod_indicador = v.cod_indicador  
            WHERE v.cod_cliente = p_tela.cod_cliente
              AND v.dat_ini_vigencia = p_tela.dat_ini_vigencia
              AND v.dat_fim_vigencia = p_tela.dat_fim_vigencia
            ORDER BY i.descricao
   
         FOREACH cq_imp INTO 
            p_cod_indicador, p_valor, p_descricao
      
            IF STATUS <> 0 THEN
               CALL log003_err_sql('FOREACH','cq_pergunta')
               RETURN 
            END IF
            
            PRINT COLUMN 001, p_cod_indicador,
                  COLUMN 011, p_descricao,
                  COLUMN 043, p_valor USING '#,###,###,##&,&&'
   
         END FOREACH

         PRINT
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#

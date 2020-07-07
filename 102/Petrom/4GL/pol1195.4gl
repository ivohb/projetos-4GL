#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1195                                                 #
# OBJETIVO: APROVAÇÃO DE ANÁLISE DE CRÉDITO                         #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 08/05/2013                                              #
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
          p_excluiu            SMALLINT

END GLOBALS

DEFINE p_dat_ini_vigencia LIKE validade_indicador_455.dat_ini_vigencia,
       p_dat_fim_vigencia LIKE validade_indicador_455.dat_fim_vigencia

DEFINE p_funcao           CHAR(01),
       p_dat_proces       DATE,
       p_den_status       CHAR(30)


DEFINE p_chave            RECORD
       num_processo       LIKE analise_455.num_processo,
       num_versao         LIKE analise_455.num_versao,  
       cod_cliente        LIKE analise_455.cod_cliente 
END RECORD

DEFINE p_chavea           RECORD
       num_processo       LIKE analise_455.num_processo,
       num_versao         LIKE analise_455.num_versao,  
       cod_cliente        LIKE analise_455.cod_cliente 
END RECORD
       
DEFINE p_tela               RECORD
       num_processo         LIKE analise_455.num_processo,
       num_versao           LIKE analise_455.num_versao,          
       cod_status           LIKE analise_455.cod_status,  
       prz_validade         LIKE analise_455.prz_validade,
       cod_cliente          LIKE analise_455.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente,
       faturamento          LIKE analise_455.val_credito,
       lucro                LIKE analise_455.val_credito,
       dat_refer_vigen      LIKE analise_455.dat_refer_vigen,
       val_referencia       LIKE analise_455.val_referencia,
       val_analista         LIKE analise_455.val_analista,  
       val_gerente          LIKE analise_455.val_gerente,   
       val_vendedor         LIKE analise_455.val_vendedor,  
       val_aprovador        LIKE analise_455.val_aprovador,
       observacao           LIKE analise_455.observacao
END RECORD

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
       p_arquivo        CHAR(30),
       sql_stmt         CHAR(500)

DEFINE p_pergunta   RECORD
   cod_pergunta	    Char(05),
   descricao	      Char(40),
   tipo	            Char(01),
   peso_cad	        Decimal(4,2),
   val_comparativo	Decimal(12,2),
   condicao_debitar Char(02),
   peso_info        Decimal(4,2),
   ies_debitar      Char(01)
END RECORD   
       
DEFINE p_indicador  RECORD
   cod_indicador    char(08),
   descricao        char(30),
   valor            Decimal(12,2)
END RECORD
  
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1195-10.02.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      IF pol1195_controle() THEN
         CALL pol1195_menu()
      END IF
   END IF
   
END MAIN

#--------------------------#
FUNCTION pol1195_controle()#
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
      LET p_msg = 'Usuário não cadastrado no pol1195'
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
      LET p_funcao = pol1195_sel_usuario()
   END IF
   
   {IF p_funcao MATCHES '[VP]' THEN
   ELSE
      LET p_msg = 'Usuário não autorizado a\n',
                  'utilizar esse processo.\n',
                  'Consulte o pol1195.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF}

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1195_sel_usuario()#
#-----------------------------#

   DEFINE pr_func         ARRAY[10] OF RECORD
          funcao          CHAR(01),
          descricao       CHAR(12)
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1195b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1195b AT 9,30 WITH FORM p_nom_tela
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

   CLOSE WINDOW w_pol1195b
   
   RETURN pr_func[p_ind].funcao
   
END FUNCTION
   
#----------------------#
 FUNCTION pol1195_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1195") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1195 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1195_consulta() THEN
            ERROR 'Operação efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Operação cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1195_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1195_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
       IF p_funcao MATCHES '[VP]' THEN
         IF p_ies_cons THEN
            CALL pol1195_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_chave TO cod_indicador
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
       ELSE
          ERROR 'USUÁRIO SEM ACESSO A ESSA OPÇÃO'
       END IF
      COMMAND KEY ("P") "aProvar" "Aprovar o crédito do cliente"
         IF p_funcao = 'P' THEN
            IF p_ies_cons THEN
              IF pol1195_checa_permissao() THEN
                  IF log004_confirm(18,35) THEN      
                     CALL pol1195_aprova_credito() RETURNING p_status
                     IF p_status THEN
                        ERROR 'Operação efetuada com sucesso !!!'
                     ELSE
                        ERROR 'Operação cancelada !!!'
                     END IF
                  ELSE
                     ERROR 'Operação cancelada !!!'
                  END IF
               END IF
            ELSE
               ERROR "Consulte previamente para fazer a exclusão !!!"
            END IF   
         ELSE
            ERROR 'USUÁRIO SEM ACESSO A ESSA OPÇÃO'
         END IF
      COMMAND "Rejeitar" "Rejeita o processo, p/ o Gerente reavaliar"
         IF p_funcao = 'P' THEN
            IF p_ies_cons THEN
               CALL pol1195_rejeitar() RETURNING p_status
               IF p_status THEN
                  ERROR 'Operação efetuada com sucesso !!!'
               ELSE
                  ERROR 'Operação cancelada !!!'
               END IF
            ELSE
               ERROR "Consulte previamente para fazer a exclusão !!!"
            END IF   
         ELSE
            ERROR 'USUÁRIO SEM ACESSO A ESSA OPÇÃO'
         END IF
      COMMAND "Listar" "Imprime a analise da tela"
         CALL pol1195_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1195_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1195

END FUNCTION

#-----------------------#
 FUNCTION pol1195_sobre()
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

#---------------------------#
FUNCTION pol1195_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1195_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1195_limpa_tela()
   LET p_chavea = p_chave
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      analise_455.dat_refer_vigen,
      analise_455.num_processo,
      analise_455.cod_cliente
      
   IF INT_FLAG THEN
      CALL pol1195_limpa_tela()
      IF p_ies_cons THEN 
         IF p_excluiu THEN
         ELSE
            CALL pol1195_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF

   LET p_ies_cons = FALSE
   
   LET sql_stmt = "SELECT num_processo, num_versao, cod_cliente ",
                  "  FROM analise_455 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND num_versao = 2 ",
                  "   AND cod_status > 2 ",
                  " ORDER BY cod_cliente, num_processo"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_chave.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      RETURN FALSE
   END IF
   
   IF pol1195_exibe_dados() THEN
      LET p_ies_cons = TRUE
   END IF
   
   RETURN p_ies_cons

END FUNCTION

#------------------------------#
 FUNCTION pol1195_exibe_dados()
#------------------------------#
   
   LET p_excluiu = FALSE
   
   SELECT num_processo,   
          num_versao,     
          cod_status,     
          prz_validade,   
          cod_cliente,    
          dat_refer_vigen,
          val_analista,   
          val_gerente,    
          val_vendedor,   
          val_aprovador,
          observacao,
          val_referencia 
     INTO p_tela.num_processo,   
          p_tela.num_versao,     
          p_tela.cod_status,     
          p_tela.prz_validade,   
          p_tela.cod_cliente,    
          p_tela.dat_refer_vigen,
          p_tela.val_analista,   
          p_tela.val_gerente,    
          p_tela.val_vendedor,   
          p_tela.val_aprovador,
          p_tela.observacao,
          p_tela.val_referencia
     FROM analise_455
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
      AND num_versao = p_chave.num_versao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "analise_455")
      RETURN FALSE
   END IF

   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_chave.cod_cliente

   IF STATUS <> 0 THEN
      LET p_tela.nom_cliente = ''
   END IF
   
   IF NOT pol1195_le_indicadores() THEN
      LET p_tela.faturamento = NULL
      LET p_tela.lucro = NULL
   END IF
   
   DISPLAY BY NAME p_tela.*
   DISPLAY p_dat_ini_vigencia TO dat_ini_vigencia
   DISPLAY p_dat_fim_vigencia TO dat_fim_vigencia
   
   LET p_den_status = pol1195_den_status()
   DISPLAY p_den_status TO den_status        

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1195_den_status()#
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

#--------------------------------#
FUNCTION pol1195_le_indicadores()#
#--------------------------------#

   DEFINE p_cod_indicador LIKE pct_faturamento_455.cod_indicador

   SELECT DISTINCT
          dat_ini_vigencia,
          dat_fim_vigencia
     INTO p_dat_ini_vigencia,
          p_dat_fim_vigencia
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND dat_ini_vigencia <= p_tela.dat_refer_vigen
      AND dat_fim_vigencia >= p_tela.dat_refer_vigen

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','PERIODO DE VIGÊNCIA')
      RETURN FALSE
   END IF
   
   SELECT DISTINCT cod_indicador
     INTO p_cod_indicador
     FROM pct_faturamento_455
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','INDICADOR DE FATURAMENTO')
      RETURN FALSE
   END IF
   
   SELECT valor
     INTO p_tela.faturamento
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND cod_indicador = p_cod_indicador
      AND dat_ini_vigencia = p_dat_ini_vigencia
      AND dat_fim_vigencia = p_dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','VALOR DO FATURAMENTO')
      RETURN FALSE
   END IF
   
   SELECT DISTINCT cod_indicador
     INTO p_cod_indicador
     FROM pct_lucro_455
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','INDICADOR DO LUCRO')
      RETURN FALSE
   END IF
   
   SELECT valor
     INTO p_tela.lucro
     FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND cod_indicador = p_cod_indicador
      AND dat_ini_vigencia = p_dat_ini_vigencia
      AND dat_fim_vigencia = p_dat_fim_vigencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','INDICADOR DO LUCRO')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1195_paginacao(p_opcao)
#-----------------------------------#

   DEFINE p_opcao CHAR(01)

   LET p_chavea = p_chave
   
   WHILE TRUE
      CASE
         WHEN p_opcao = "S" FETCH NEXT cq_padrao INTO p_chave.*
                                                       
         WHEN p_opcao = "A" FETCH PREVIOUS cq_padrao INTO p_chave.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cliente
           FROM analise_455
          WHERE cod_cliente = p_chave.cod_cliente
            AND num_processo = p_chave.num_processo
            AND num_versao = p_chave.num_versao
            AND cod_status > 2
         IF STATUS = 0 THEN
            CALL pol1195_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_chave = p_chavea
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1195_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_cliente 
      FROM analise_455  
     WHERE cod_cliente = p_chave.cod_cliente
       AND num_processo = p_chave.num_processo
       AND num_versao = p_chave.num_versao
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
FUNCTION pol1195_checa_permissao()#
#---------------------------------#

   IF p_tela.cod_status <> '3' THEN
      LET p_msg = 'O registro da tela só está\n',
                  'disponível para consulta.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
 FUNCTION pol1195_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione um registro previamente.", "info")
      RETURN p_retorno
   END IF
   
   IF NOT pol1195_checa_permissao() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG  = FALSE
   
   IF pol1195_prende_registro() THEN
      IF pol1195_edita_dados() THEN
         IF pol11163_atualiza() THEN
            IF pol1195_ins_usuario() THEN
               LET p_retorno = TRUE
            END IF
         END IF
      ELSE
         CALL pol1195_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   IF p_funcao = 'V' OR p_retorno = FALSE THEN
      RETURN p_retorno
   END IF

   LET p_msg = 'Modificação efetuada com sucesso.\n\n',
	             'Deseja aprovar o crédito agora?' 
	 
	 IF log0040_confirm(20,25,p_msg) THEN
	    CALL pol1195_aprova_credito() RETURNING p_retorno
   END IF
   
   RETURN p_retorno

END FUNCTION

#------------------------------#
 FUNCTION pol1195_edita_dados()
#------------------------------#

   DEFINE p_opcao CHAR(01)
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS
                       
      BEFORE FIELD val_vendedor

         IF p_funcao = "P" THEN
            NEXT FIELD val_aprovador
         END IF
      
      AFTER FIELD val_vendedor

        IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
             OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
        ELSE
            ERROR 'Exc = Salvar   Ctrl+C = Cancelar'
            NEXT FIELD val_vendedor
        END IF

      ON KEY (control-z)
         CALL pol1195_popup()
          
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE analise_455
      SET val_vendedor = p_tela.val_vendedor,
          val_aprovador = p_tela.val_aprovador,
          cod_status = p_tela.cod_status
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
      AND num_versao = p_chave.num_versao
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "analise_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1195_ins_usuario()
#----------------------------#

   SELECT cod_usuario
     FROM analise_usuario_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND num_processo = p_tela.num_processo
      AND num_versao = p_tela.num_versao
      AND funcao = p_funcao
       
   IF STATUS = 0 THEN
      UPDATE analise_usuario_455
         SET cod_usuario = p_user
       WHERE cod_cliente = p_tela.cod_cliente
         AND num_processo = p_tela.num_processo
         AND num_versao = p_tela.num_versao
         AND funcao = p_funcao
   ELSE
      IF STATUS = 100 THEN
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
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,') AO ACESSAR\n',
                  'A TABELA ANALISE_USUARIO_455'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1195_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      
      WHEN INFIELD(val_aprovador)
         LET p_codigo = pol1195_exibe_valores()
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.val_aprovador = p_codigo CLIPPED
            DISPLAY p_tela.val_aprovador TO val_aprovador
         END IF
      
   END CASE 

END FUNCTION 

#-------------------------------#
FUNCTION pol1195_exibe_valores()
#-------------------------------#

   DEFINE pr_valor           ARRAY[3] OF RECORD
          valor              LIKE analise_455.val_credito
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1195a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1195a AT 20,60 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   LET p_ind = 3
   LET pr_valor[1].valor = p_tela.val_analista
   LET pr_valor[2].valor = p_tela.val_gerente
   LET pr_valor[3].valor = p_tela.val_vendedor
   
   CALL SET_COUNT(p_ind)
      
   DISPLAY ARRAY pr_valor TO sr_valor.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1195a
   
   IF NOT INT_FLAG THEN
      RETURN pr_valor[p_ind].valor
   ELSE
      RETURN NULL
   END IF
   
END FUNCTION

#---------------------------#
 FUNCTION pol1195_rejeitar()#
#---------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione um registro previamente.", "info")
      RETURN p_retorno
   END IF

   IF NOT pol1195_checa_permissao() THEN
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1195_prende_registro() THEN
      IF pol1195_rejei_processo() THEN
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      DISPLAY p_tela.cod_status TO cod_status
      LET p_den_status = pol1195_den_status()
      DISPLAY p_den_status TO den_status        
      DISPLAY p_tela.val_vendedor TO val_vendedor
      DISPLAY p_tela.val_aprovador TO val_aprovador
   ELSE
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol1195_env_email() THEN
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
      ELSE
         CALL log0030_mensagem('Operaçõ efetuada c/ sucesso!','excla')
      END IF
   END IF
   
   CALL pol1195_limpa_tela()

   RETURN TRUE

END FUNCTION  

#--------------------------------#
FUNCTION pol1195_rejei_processo()#
#--------------------------------#

   DELETE FROM analise_usuario_455
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
      AND num_versao = p_chave.num_versao

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","analise_usuario_455")
      RETURN FALSE
   END IF

   LET p_tela.cod_status = 2
   LET p_tela.val_vendedor = 0
   LET p_tela.val_aprovador = 0

   UPDATE analise_455
      SET val_vendedor = p_tela.val_vendedor,
          val_aprovador = p_tela.val_aprovador,
          cod_status = p_tela.cod_status
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "analise_455")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1195_aprova_credito()
#--------------------------------#
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione um registro previamente.", "info")
      RETURN FALSE
   END IF

   IF p_tela.val_aprovador <= 0 THEN
      LET p_msg = 'O valor a aprovar está zerado.\n\n',
                  'Aprovar o crédito mesmo assim?.'
      IF NOT log0040_confirm(20,25,p_msg) THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_dat_proces = TODAY
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1195_grava_credito() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   DISPLAY p_tela.cod_status TO cod_status
   LET p_den_status = pol1195_den_status()
   DISPLAY p_den_status TO den_status        

   CALL log0030_mensagem('Aprovação efetuada c/ sucesso!','excla')
   CALL pol1195_limpa_tela()
   LET p_excluiu = TRUE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1195_grava_credito()#
#-------------------------------#
   
   DEFINE p_dat_cre_ant   CHAR(10),
          p_val_cre_ant   DECIMAL(12,2),
          p_num_cpf_cgc   CHAR(11),
          p_ies_aprovacao CHAR(01),
          p_texto         CHAR(200),
          p_valor         CHAR(13),
          p_hota          CHAR(08)
   
   SELECT val_limite_cred,
          dat_val_lmt_cr
     INTO p_val_cre_ant,
          p_dat_cre_ant
     FROM cli_credito
    WHERE cod_cliente = p_tela.cod_cliente
     
   IF STATUS <> 0 THEN
      LET p_val_cre_ant = 0
      LET p_dat_cre_ant = ''
   END IF
   
   IF p_val_cre_ant IS NULL THEN
      LET p_val_cre_ant = 0
   END IF
   
   SELECT cliente
     FROM cre_cli_cca_compl
    WHERE cliente = p_tela.cod_cliente
      AND campo = 'dat_atualiz_limite_cred'

   IF STATUS <> 0 THEN
      INSERT INTO cre_cli_cca_compl (
         cliente, campo, parametro_dat) 
       VALUES(p_tela.cod_cliente, 'dat_atualiz_limite_cred', p_dat_proces)
   ELSE
      UPDATE cre_cli_cca_compl SET parametro_dat = p_dat_proces
       WHERE cliente = p_tela.cod_cliente
         AND campo = 'dat_atualiz_limite_cred'
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('GRAVANDO','CRE_CLI_CCA_COMPL')
      RETURN FALSE
   END IF

   SELECT MAX(seq_auditoria) 
     INTO p_count
     FROM cre_audit_cli_cca 
    WHERE cliente = p_tela.cod_cliente
   
   IF p_count IS NULL THEN
      LET p_count = 1
   ELSE
      LET p_count = p_count + 1
   END IF
   
   SELECT num_cgc_cpf 
     INTO p_num_cpf_cgc
     FROM clientes 
    WHERE cod_cliente = p_tela.cod_cliente
   
   IF STATUS <> 0 THEN
      LET p_num_cpf_cgc = ' '
   END IF

   INSERT INTO cre_audit_cli_cca (
     cliente,   seq_auditoria, campo_alterado, 
     val_ant,   val_atual,     programa_alteracao, 
     usu_alter, dat_alteracao, cnpj_cpf, observacao) 
   VALUES(p_tela.cod_cliente, p_count, 'VALOR LIMITE CREDITO',
          p_val_cre_ant, p_tela.val_aprovador, 'POL1195',
          p_user, p_dat_proces, p_num_cpf_cgc, p_tela.observacao)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','CRE_AUDIT_CLI_CCA')
      RETURN FALSE
   END IF
   
   SELECT COUNT(cod_cliente)
     INTO p_count
     FROM credcad_cod_cli
    WHERE cod_cliente = p_tela.cod_cliente
   
   IF p_count = 0 THEN
      INSERT INTO credcad_cod_cli (
        cod_cliente,   cod_empresa,        num_docum,   
        ies_tip_docum, ies_ctr_atual_emis, ies_ctr_atual_bxa) 
      VALUES(p_tela.cod_cliente, ' ', ' ', ' ', NULL, NULL)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','CREDCAD_COD_CLI')
         RETURN FALSE
      END IF
   END IF
   
   UPDATE cli_credito
      SET val_limite_cred = p_tela.val_aprovador,
          dat_val_lmt_cr = p_tela.prz_validade,
          dat_atualiz = p_dat_proces
    WHERE cod_cliente = p_tela.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','CLI_CREDITO')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
      
   SELECT val_credito_conced,
          dat_credito_conced,
          ies_aprovacao
     INTO p_val_cre_ant,
          p_dat_cre_ant,
          p_ies_aprovacao 
     FROM credcad_cli 
    WHERE cod_cliente = p_tela.cod_cliente
   
   IF STATUS <> 0 THEN
      LET p_val_cre_ant = 0
      LET p_dat_cre_ant = ' '
      LET p_ies_aprovacao = 'N'
   END IF

   IF p_val_cre_ant IS NULL THEN
      LET p_val_cre_ant = 0
   END IF

   LET p_valor = p_val_cre_ant
   
   LET p_texto = 'cliente = ',p_tela.cod_cliente CLIPPED, ' /',
          'valor do credito antes = ',p_valor
  
   LET p_valor = p_tela.val_aprovador
   LET p_texto = p_texto CLIPPED, ' /',
          'valor do credito atual = ', p_valor CLIPPED, ' /',
          'data anterior = ', p_dat_cre_ant CLIPPED, ' /',
          'data atual = ', p_tela.prz_validade, ' /',
          'indicador anterior = ', p_ies_aprovacao, ' /',
          'indicador atual = N'
   
   LET p_hota = TIME
         
   INSERT INTO audit_logix (
      cod_empresa, texto, num_programa, data, hora, usuario) 
    VALUES(p_cod_empresa, p_texto, 'POL1195', p_dat_proces, p_hota, p_user)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT", "AUDIT_LOGIX")
      RETURN FALSE
   END IF

   UPDATE credcad_cli 
      SET val_credito_conced = p_tela.val_aprovador,
          dat_credito_conced = p_tela.prz_validade, 
          ies_aprovacao = 'S' 
    WHERE cod_cliente = p_tela.cod_cliente
   
   LET p_tela.cod_status = 4
   
   UPDATE analise_455
      SET cod_status = p_tela.cod_status
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
      #AND num_versao = p_chave.num_versao
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "ANALISE_455")
      RETURN FALSE
   END IF

   UPDATE analise_455
      SET val_credito = p_tela.val_aprovador,
          observacao = p_tela.observacao
    WHERE cod_cliente = p_chave.cod_cliente
      AND num_processo = p_chave.num_processo
      AND num_versao = p_chave.num_versao
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "ANALISE_455")
      RETURN FALSE
   END IF
     
   IF NOT pol1195_ins_usuario() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1195_env_email()#
#---------------------------#

   IF NOT pol1195_cria_tabs() THEN
      RETURN FALSE
   END IF

   IF NOT pol1195_grava_tab_email() THEN
      RETURN FALSE
   END IF

   IF NOT pol1195_envia_email() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1195_cria_tabs()#
#---------------------------#

   DROP TABLE envia_email_912
   CREATE  TABLE envia_email_912  (
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
FUNCTION pol1195_grava_tab_email()#
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

   LET p_email.tip_docum = 'APR'
   
   LET sql_stmt = 
          " SELECT uf.cod_usuario, u.nom_funcionario, u.e_mail ",
          "   FROM usuario_funcao_455 uf, usuarios u ",
          "  WHERE uf.funcao = 'G' AND uf.cod_usuario = u.cod_usuario"
   
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
FUNCTION pol1195_envia_email()#
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

            WHEN 'APR'
               LET p_titulo = 'Análise de crédito rejeitada p/ sua reavaliação'

         END CASE
            
         LET p_arquivo = p_user_emitente CLIPPED, '-', p_user_destino CLIPPED, '.lst'
         LET p_den_comando = p_den_comando CLIPPED, p_arquivo
         
         START REPORT pol1195_email TO p_den_comando
      
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
         
            OUTPUT TO REPORT pol1195_email() 
      
         END FOREACH

         FINISH REPORT pol1195_email  
      
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
 REPORT pol1195_email()
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
      
#--------------------------#
 FUNCTION pol1195_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1195_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1195_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   OUTPUT TO REPORT pol1195_relat() 

   LET p_count = 1
      
   FINISH REPORT pol1195_relat   
   
   CALL pol1195_finaliza_relat()
   
   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1195_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1195_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1195.tmp'
         START REPORT pol1195_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1195_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1195_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1195_finaliza_relat()#
#--------------------------------#

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
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#---------------------#
 REPORT pol1195_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 047, "ANALISE DE CREDITO",
               COLUMN 073, "PAG. ", PAGENO USING "#&"
               
         PRINT COLUMN 000, "POL1195",
               COLUMN 017, "VIGENCIA: ", p_dat_ini_vigencia USING 'dd/mm/yyyy', ' - ', 
                                         p_dat_fim_vigencia USING 'dd/mm/yyyy',
               COLUMN 061, "VALIDADE: ", p_tela.prz_validade USING 'dd/mm/yyyy'

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 006, 'Cliente: ', p_tela.cod_cliente CLIPPED, ' ', p_tela.nom_cliente
         PRINT

      ON EVERY ROW

        PRINT COLUMN 001, '                                              CONDICAO PESO  PESO  VALOR'
        PRINT COLUMN 001, 'PERGUNTAS                                TIPO DEBITAR  CAD   INFO  COMP  DEBITAR'
        PRINT COLUMN 001, '---------------------------------------- ---- -------- ----- ----- ----- -------'
        
        DECLARE cq_pergunta CURSOR FOR
         SELECT a.cod_pergunta,
                a.descricao,
                a.tipo,
                a.pct_peso,
                a.val_comparativo,
                a.condicao_debitar,
                b.peso_informado,
                b.ies_debitar
           FROM perguntas_455 a,
                analise_pergunta_455 b
          WHERE b.cod_cliente  = p_tela.cod_cliente
            AND b.num_processo = p_tela.num_processo
            AND b.num_versao   = p_tela.num_versao
            AND b.cod_pergunta = a.cod_pergunta
                            
        FOREACH cq_pergunta INTO p_pergunta.*
           
           IF STATUS <> 0 THEN
              CALL log003_err_sql('FOREACH','cq_pergunta')
              RETURN
           END IF
           
           PRINT COLUMN 001, p_pergunta.descricao,
                 COLUMN 043, p_pergunta.tipo,
                 COLUMN 050, p_pergunta.condicao_debitar,
                 COLUMN 056, p_pergunta.peso_cad USING '#&.&&',
                 COLUMN 062, p_pergunta.peso_info USING '#&.&&',
                 COLUMN 068, p_pergunta.val_comparativo USING '#&.&&',
                 COLUMN 077, p_pergunta.ies_debitar
        
        END FOREACH   
        
        PRINT
        PRINT COLUMN 001, 'INDICADORES                                 VALOR'
        PRINT COLUMN 001, '-------- ------------------------------ -------------'
        
        DECLARE cq_indicador CURSOR FOR
         SELECT a.cod_indicador,
                a.descricao,
                b.val_indicador
           FROM indicadores_455 a,
                analise_indicador_455 b
          WHERE b.cod_cliente  = p_tela.cod_cliente
            AND b.num_processo = p_tela.num_processo
            AND b.cod_indicador = a.cod_indicador
                            
        FOREACH cq_indicador INTO p_indicador.*
           
           IF STATUS <> 0 THEN
              CALL log003_err_sql('FOREACH','cq_indicador')
              RETURN
           END IF
           
           PRINT COLUMN 001, p_indicador.cod_indicador,
                 COLUMN 010, p_indicador.descricao,
                 COLUMN 041, p_indicador.valor USING '##,###,##&.&&'
        
        END FOREACH
         
      ON LAST ROW
        
        LET p_last_row = TRUE
        PRINT
        PRINT COLUMN 001, "--------------------------------------------------------------------------------"
        PRINT COLUMN 001, ' VAL CALCULADO   VAL ANALISTA    VAL GERENTE     VAL VENDEDOR   VAL APROVADOR'
        PRINT COLUMN 001, p_tela.val_referencia USING '###,###,##&.&&',
              COLUMN 001, p_tela.val_analista   USING '###,###,##&.&&',
              COLUMN 001, p_tela.val_gerente    USING '###,###,##&.&&',
              COLUMN 001, p_tela.val_vendedor   USING '###,###,##&.&&',
              COLUMN 001, p_tela.val_aprovador  USING '###,###,##&.&&'
        PRINT COLUMN 001, "--------------------------------------------------------------------------------"
        
      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           #PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           #PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#
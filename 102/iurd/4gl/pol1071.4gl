#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: EMPRESTIMOS CONSIGNADOS
# PROGRAMA: pol1071                                                 #
# OBJETIVO: CARGA E CONSISTÊNCIA DOS DADOS DOS ARQUIVOS DOS BANCOS  #
# AUTOR...: IVO                                                     #
# DATA....: 30/11/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
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
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_cpf                CHAR(14),
          p_cod_bco            DECIMAL(3,0),
          p_ano_mes_demis      CHAR(07)                   
  
   DEFINE p_arq_banco          RECORD LIKE arq_banco_265.*,
          p_diverg_consig      RECORD LIKE diverg_consig_265.*,
          p_contr_consig       RECORD LIKE contr_consig_265.*,
          p_hist_movto         RECORD LIKE hist_movto_265.*
          

   DEFINE p_cod_banco          LIKE banco_265.cod_banco,
          p_cod_evento         LIKE evento_265.cod_evento,
          p_cod_reembolso      LIKE evento_265.cod_evento,
          p_cod_tip_reg        LIKE banco_265.cod_tip_reg,
          p_cod_tip_lido       LIKE banco_265.cod_tip_reg,
          p_dat_termino        LIKE banco_265.dat_termino,
          p_campo              LIKE layout_265.campo,
          p_posi_ini           LIKE layout_265.posicao,
          p_posi_fim           LIKE layout_265.posicao,
          p_tamanho            LIKE layout_265.tamanho,
          p_posi_id            LIKE layout_265.posicao,
          p_tama_id            LIKE layout_265.tamanho,
          p_num_contrato       LIKE arq_banco_265.num_contrato,
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_cod_uni_feder      LIKE cidades.cod_uni_feder,
          p_nom_funcionario    LIKE funcionario.nom_funcionario,
          m_dat_vencto         LIKE contr_consig_265.dat_vencto,
          p_val_parcela        LIKE contr_consig_265.val_parcela,
          m_qtd_parcela        LIKE contr_consig_265.qtd_parcela,
          m_num_parcela        LIKE contr_consig_265.num_parcela,
          m_dat_solicitacao    LIKE contr_consig_265.dat_contrato,
          m_val_emprestimo     LIKE contr_consig_265.val_emprestimo

   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD
          

   DEFINE p_dat_atu            CHAR(10),
          p_mes_atu            SMALLINT,
          p_ano_atu            SMALLINT,
          p_hor_atu            CHAR(08),
          p_ies_ambiente       CHAR(01),
          p_qtd_erro           INTEGER,
          p_registro           CHAR(300),
          p_id_registro        INTEGER,
          p_dat_ref            CHAR(06),
          p_mes_ano_ref        CHAR(07),
          p_nome_arq_csv       CHAR(16),
          p_dat_arq            CHAR(06),
          p_arq_existe         SMALLINT,
          p_chave              CHAR(300),
          p_query              CHAR(300),
          p_numero_cpf         CHAR(19),
          p_ind_carga          SMALLINT,
          p_ja_carregou        SMALLINT,
          p_ja_consistiu       SMALLINT,
          p_ja_arbitrou        SMALLINT,
          p_den_banco          CHAR(15),
          p_arquivo            CHAR(15),
          p_consistido         CHAR(15),
          p_reg_lido           SMALLINT,
          p_dat_char           CHAR(10),
          p_data               DATE,
          p_dat_liquidacao     DATE,
          p_dat_liq_contr      DATE,
          p_dat_referencia     DATE,
          p_dat_afasta         DATE,
          p_dat_demis          DATE,
          p_val_30             DECIMAL(12,2),
          p_val_dif            DECIMAL(12,2),
          p_val_txt            CHAR(12),
          p_val_evento         DECIMAL(12,2),
          p_val_acerto         DECIMAL(12,2),
          p_obs                CHAR(300),
          p_cod_status         CHAR(01),
          p_tip_diverg         CHAR(01),
          p_extensao           CHAR(03),
          p_estado             CHAR(02),
          m_cod_empresa        CHAR(02),
          m_num_matricula      INTEGER,
          p_id_reg_hist        INTEGER,
          p_mes_ref            INTEGER,
          p_ano_ref            INTEGER,
          p_ano_mes_ref        CHAR(07),
          p_tem_desconto       SMALLINT,
          p_nom_usuario        CHAR(08),
          p_nom_user           CHAR(08),
          p_tip_evento         INTEGER,
          p_tip_acerto         INTEGER,
          p_dat_afastamento    DATE,
          p_pri_consit         SMALLINT
          
   DEFINE p_tela               RECORD
          mes_ref              CHAR(02),
          ano_ref              CHAR(04)
          #cod_banco            DECIMAL(3,0)
   END RECORD

   DEFINE p_erro               RECORD
          cod_banco            DECIMAL(3,0),
          mes_ref              CHAR(02),
          ano_ref              CHAR(04)      
   END RECORD

   DEFINE pr_erro_carga        ARRAY[1000] OF RECORD    
          num_registro         CHAR(6),
          den_erro             CHAR(75)
   END RECORD
     
   DEFINE pr_carga             ARRAY[100] OF RECORD    
          den_banco            CHAR(15),
          arquivo              CHAR(15),
          reg_lido             SMALLINT,
          consistido           CHAR(10)
   END RECORD

   DEFINE pr_empresa    ARRAY[1000] OF RECORD 
          cod_empresa   CHAR(02),
          den_empresa   CHAR(30)
   END RECORD

END GLOBALS
      
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1071-10.02.35"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1071_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1071_menu()
#----------------------#
          
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1071") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1071 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
     
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1071_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso !'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Carregar'
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Carregar" "Processa a carga dos arquivos textos"
         IF p_ies_cons THEN
            CALL pol1071_carregar() RETURNING p_status
            IF p_status THEN
               CALL pol1071_exib_resumo()
               NEXT OPTION 'Consistir'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF 
         ELSE
            ERROR 'Informe os parâmentors previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Erros" "Exibe os erros encontrados durante a carga"
         CALL pol1071_exibe_erros() RETURNING p_status
         IF p_status THEN
            ERROR 'Consulta efetuada com sucesso !'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consistir" "Processa a consistência dos dados"
         IF p_ies_cons THEN
            CALL pol1071_consistencia() RETURNING p_status
            LET pr_men[1].mensagem = 'FIM DO PROCESSAMENTO!'
            CALL pol1071_exib_mensagem()
            IF p_status THEN
               CALL log0030_mensagem('Consistência efetuada com sucesso !','excla')
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
               NEXT OPTION 'Informar'
            END IF 
            LET pr_men[1].mensagem = ' '
            CALL pol1071_exib_mensagem()
         ELSE
            ERROR 'Informe os parâmentors previamente!'
            NEXT OPTION 'Informar'
         END IF
         MESSAGE ''
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1071_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1071

END FUNCTION


#-----------------------#
 FUNCTION pol1071_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1071_cria_temp()
#---------------------------#

   DROP TABLE banco_temp_265
   
   CREATE temp TABLE banco_temp_265(
		registro CHAR(300))

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","banco_temp_265:criando")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1071_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#--------------------------#
FUNCTION pol1071_informar()
#--------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_dat_atu = TODAY
   LET p_mes_atu = p_dat_atu[4,5]
   LET p_ano_atu = p_dat_atu[7,10]
   LET p_tela.mes_ref = p_mes_atu USING '&&'
   LET p_tela.ano_ref = p_ano_atu USING '&&&&'
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

   AFTER FIELD mes_ref
      IF p_tela.mes_ref <= 0 OR
         p_tela.mes_ref > 12 THEN
         ERROR 'Valor inválido p/ o campo!'
         NEXT FIELD mes_ref
      END IF

   AFTER FIELD ano_ref
      IF p_tela.ano_ref < 2000 OR
         p_tela.ano_ref > p_ano_atu THEN
         ERROR 'Valor inválido p/ o campo!'
         NEXT FIELD ano_ref
      END IF
     
   AFTER INPUT
      IF NOT INT_FLAG THEN
         IF p_tela.mes_ref IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD mes_ref
         END IF
         IF p_tela.ano_ref IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD ano_ref
         END IF
         
         LET p_dat_ref = p_tela.mes_ref, p_tela.ano_ref 
         LET p_mes_ano_ref = p_tela.mes_ref, '/', p_tela.ano_ref 
         LET p_dat_char = '01/',p_mes_ano_ref 
         LET p_data = p_dat_char  
         LET p_dat_referencia = p_data
         LET p_dat_liq_contr = p_data
         LET p_nome_arq_csv = 'consig',p_tela.ano_ref,p_tela.mes_ref,'.csv'

      END IF
   
   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   LET p_mes_ref = p_tela.mes_ref
   LET p_ano_ref = p_tela.ano_ref
   LET p_ano_mes_ref = EXTEND(p_data, YEAR TO MONTH)
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol1071_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         LET p_codigo = pol1071_le_bancos()
         IF p_codigo IS NOT NULL THEN
           #LET p_tela.cod_banco = p_codigo
           DISPLAY p_codigo TO cod_banco
         END IF
   END CASE 

END FUNCTION 

#---------------------------#
 FUNCTION pol1071_le_bancos()
#---------------------------#

   DEFINE pr_bancos  ARRAY[2000] OF RECORD
          cod_banco  LIKE banco_265.cod_banco,
          nom_banco  LIKE bancos.nom_banco
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10714") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10691 AT 5,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_pop_bco CURSOR FOR
   
    SELECT cod_banco
      FROM banco_265
     ORDER BY cod_banco

   FOREACH cq_pop_bco
      INTO pr_bancos[p_ind].cod_banco   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_pop_bco')
         EXIT FOREACH
      END IF
      
      SELECT nom_banco
        INTO pr_bancos[p_ind].nom_banco
        FROM bancos
       WHERE cod_banco = pr_bancos[p_ind].cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','bancos')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_bancos TO sr_bancos.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10691
   
   IF NOT INT_FLAG THEN
      RETURN pr_bancos[p_ind].cod_banco
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1071_exibe_erros()
#-----------------------------#

   DEFINE pr_erros     ARRAY[2000] OF RECORD
          den_banco    LIKE banco_265.den_reduz,
          mes_ano_ref  LIKE carga_erro_265.mes_ano_ref,
          nom_arquivo  LIKE carga_erro_265.nom_arquivo,
          num_registro LIKE carga_erro_265.num_registro,
          dat_proces   LIKE carga_erro_265.dat_proces,
          hor_proces   LIKE carga_erro_265.hor_proces,
          den_erro     LIKE carga_erro_265.den_erro
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10711") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10711 AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_dat_atu = TODAY
   LET p_ano_atu = p_dat_atu[7,10]
   LET INT_FLAG = FALSE
   
   INITIALIZE p_erro TO NULL
   
   INPUT BY NAME p_erro.*
      WITHOUT DEFAULTS

   AFTER FIELD cod_banco
   
      IF p_erro.cod_banco IS NOT NULL THEN
         SELECT COUNT(cod_banco)
           INTO p_count
           FROM carga_erro_265
          WHERE cod_banco = p_erro.cod_banco
         
         IF p_count = 0 THEN
            ERROR 'Não há erros de carga p/ o banco informado!'
            NEXT FIELD cod_banco
         END IF
      END IF
      
   AFTER FIELD mes_ref

      LET p_mes_ano_ref = NULL
   
      IF p_erro.mes_ref IS NULL THEN
         LET p_erro.ano_ref = NULL
         DISPLAY p_erro.ano_ref TO ano_ref
         EXIT INPUT
      END IF
      
      IF p_erro.mes_ref <= 0 OR
         p_erro.mes_ref > 12 THEN
         ERROR 'Valor inválido p/ o campo!'
         NEXT FIELD mes_ref
      END IF
      
   AFTER FIELD ano_ref
      
      IF p_erro.ano_ref IS NULL THEN
         ERROR 'Campo com preenchimento obrigatório!'
         NEXT FIELD ano_ref
      END IF
            
      IF p_erro.ano_ref < 2000 OR
         p_erro.ano_ref > p_ano_atu THEN
         ERROR 'Valor inválido p/ o campo!'
         NEXT FIELD ano_ref
      END IF
        
      LET p_mes_ano_ref = p_erro.mes_ref, '/', p_erro.ano_ref 
   
   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   LET p_index = 1
   LET p_chave = ' 1 = 1 '
   
   IF p_erro.cod_banco IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_banco = '",p_erro.cod_banco,"' "
   END IF

   IF p_mes_ano_ref IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND mes_ano_ref = '",p_mes_ano_ref,"' "
   END IF

   LET p_query = 
       "SELECT cod_banco,mes_ano_ref,nom_arquivo,num_registro, ",
       "       dat_proces,hor_proces,den_erro ",
       "  FROM carga_erro_265 WHERE ",p_chave CLIPPED,
       " ORDER BY cod_banco,mes_ano_ref,nom_arquivo, num_registro "

   PREPARE cunsulta FROM p_query    
   DECLARE cq_cons_erros CURSOR FOR cunsulta
   
   FOREACH cq_cons_erros INTO
           p_cod_banco,
           pr_erros[p_index].mes_ano_ref,
           pr_erros[p_index].nom_arquivo,
           pr_erros[p_index].num_registro,
           pr_erros[p_index].dat_proces,
           pr_erros[p_index].hor_proces,
           pr_erros[p_index].den_erro   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_erros')
         RETURN FALSE
      END IF
      
      SELECT den_reduz
        INTO pr_erros[p_index].den_banco
        FROM banco_265
       WHERE cod_banco = p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','banco_265')
         RETURN FALSE
      END IF
         
      LET p_index = p_index + 1
      
      IF p_index > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem("Não há erros de carga !!!", "exclamation")
      RETURN FALSE
   END IF
      
   CALL SET_COUNT(p_index - 1)     
      
   DISPLAY ARRAY pr_erros TO sr_erros.*
             
   CLOSE WINDOW w_pol10711
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1071_carregar()
#--------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   if pol1071_ja_arbitrou() then
      RETURN false
   end if

   if not pol1071_le_consistencias() then
      RETURN false
   end if

   if p_ja_consistiu then
      let p_msg = 'A carga do mês informado já foi\n',
                  'efetuada e devidamente consistida.\n',
                  'Pretende efetuar a recarga de\n',
                  'todos os bancos???'
      IF log0040_confirm(20,25,p_msg) = TRUE THEN
      ELSE
         RETURN FALSE
      END IF
                  
      CALL log085_transacao("BEGIN")
      if not pol1071_limpa_tabelas() then
         CALL log085_transacao("ROLLBACK")
         RETURN false
      end if
      CALL log085_transacao("COMMIT")
   end if

   IF NOT pol1071_cria_temp() THEN
      RETURN FALSE
   END IF

   LET p_ind_carga = 0
   INITIALIZE pr_carga TO NULL
   
   SELECT nom_caminho,
          ies_ambiente 
     INTO p_caminho,
          p_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "UNL"

   DECLARE cq_bancos CURSOR WITH HOLD FOR
    SELECT cod_banco,
           den_reduz,
           cod_tip_reg,
           dat_termino
      FROM banco_265
     ORDER BY cod_banco
   
   FOREACH cq_bancos INTO p_cod_banco, p_den_banco, p_cod_tip_reg, p_dat_termino
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","cq_bancos")
         RETURN FALSE
      END IF

      IF p_dat_termino IS NOT NULL THEN
         IF p_dat_termino < TODAY THEN
            CONTINUE FOREACH
         END IF
      END IF
   
      LET p_arq_existe = TRUE
      LET p_qtd_erro = 0
      LET p_reg_lido = 0
      LET p_consistido = ''
      
      INITIALIZE pr_erro_carga, p_num_reg TO NULL
      
      LET p_extensao = p_cod_banco USING '&&&'
      LET p_nom_arquivo = 
          'CONSIG',p_tela.ano_ref,p_tela.mes_ref,'.',p_extensao
      LET p_arq_origem = p_caminho CLIPPED, p_nom_arquivo

      SELECT COUNT(id_registro)                      
        INTO p_count                                 
        FROM arq_banco_265                           
       WHERE nom_arq_txt = p_nom_arquivo             
                                                     
      IF STATUS <> 0 THEN                            
         CALL log003_err_sql("Lendo","arq_banco_265:count")
         RETURN FALSE                                
      END IF                                         
                                                     
      IF p_count > 0 THEN                            
         LET p_ja_carregou = TRUE                   
      ELSE                                           
         LET p_ja_carregou = FALSE                  
      END IF                                         

      delete from banco_temp_265
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Deletando","banco_temp_265")
         RETURN FALSE
      END IF
   
      LOAD from p_arq_origem INSERT INTO banco_temp_265

      IF STATUS <> 0 AND STATUS <> -805 THEN 
         CALL log003_err_sql("LOAD","arq_banco.txt")
         RETURN FALSE
      END IF
   
      IF STATUS = -805 THEN
         IF NOT p_ja_carregou THEN
            LET p_msg = "Arquivo nao encontrado no caminho ", p_arq_origem
            CALL pol1071_erro_carga()
            IF NOT pol1071_ins_erro_carga() THEN
               RETURN FALSE
            END IF
            LET p_arquivo = 'Inexistente'
         else
            LET p_arquivo = 'Carga anterior'
         END IF
         CALL pol1071_resumo()
         CONTINUE FOREACH
      END IF
           
      CALL log085_transacao("BEGIN")

      DELETE FROM arq_banco_265
       WHERE nom_arq_txt = p_nom_arquivo
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Deletando","arq_banco_265")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
     
      IF NOT pol1071_proces_carga() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      IF p_qtd_erro > 0 THEN
         LET p_arq_destino = p_caminho CLIPPED, p_nom_arquivo CLIPPED, '-ERRO'
      ELSE
         LET p_arq_destino = p_caminho CLIPPED, p_nom_arquivo CLIPPED, '-PROCES'
      END IF            

      IF p_ies_ambiente = 'W' THEN
         LET p_comando = 'move ', p_arq_origem CLIPPED, ' ', p_arq_destino
      ELSE
         LET p_comando = 'mv ', p_arq_origem CLIPPED, ' ', p_arq_destino
      END IF
      
      RUN p_comando RETURNING p_status

      IF p_status = FALSE THEN
         IF p_qtd_erro = 0 THEN
            CALL log085_transacao("COMMIT")
            LET p_arquivo = 'Carregado'
            LET p_consistido = 'Pendente'
         ELSE
            CALL log085_transacao("ROLLBACK")
            LET p_arquivo = 'Descartado'
            LET p_consistido = ''
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_msg = "Nao foi possivel renomear o arquivo "
         CALL pol1071_erro_carga()
         LET p_arquivo = 'Descartado'
         LET p_consistido = ''
      END IF

      IF NOT pol1071_ins_erro_carga() THEN
         RETURN FALSE
      END IF
      
      CALL pol1071_resumo()
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1071_le_consistencias()
#---------------------------------#

   SELECT COUNT(id_registro)
     INTO p_count
     FROM arq_banco_265
    WHERE dat_referencia = p_dat_referencia
      AND cod_status <> 'P'
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","arq_banco_265")
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      let p_ja_consistiu = TRUE
   ELSE
      let p_ja_consistiu = FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1071_limpa_tabelas()
#-------------------------------#

   DELETE FROM contr_consig_265
     WHERE id_arq_banco in 
      (select id_registro FROM arq_banco_265
        WHERE dat_referencia = p_dat_referencia)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando","contr_consig_265")
      RETURN FALSE
   END IF

   DELETE FROM arq_banco_265
    WHERE dat_referencia = p_dat_referencia
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando","arq_banco_265")
      RETURN FALSE
   END IF

   DELETE FROM diverg_consig_265
    WHERE dat_referencia = p_dat_referencia
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando","diverg_consig_265")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1071_erro_carga()
#----------------------------#

   LET p_qtd_erro = p_qtd_erro + 1
   LET pr_erro_carga[p_qtd_erro].num_registro = p_num_reg
   LET pr_erro_carga[p_qtd_erro].den_erro = p_msg

END FUNCTION

#-------------------------------#
FUNCTION pol1071_ins_erro_carga()
#-------------------------------#

   DELETE FROM carga_erro_265
    WHERE nom_arquivo = p_nom_arquivo
       
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando","carga_erro_265")
      RETURN FALSE
   END IF
  
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   
   FOR p_ind = 1 TO p_qtd_erro
      IF pr_erro_carga[p_ind].den_erro IS NOT NULL THEN
         INSERT INTO carga_erro_265
          VALUES(p_cod_banco,
                 p_mes_ano_ref,
                 p_nom_arquivo,
                 pr_erro_carga[p_ind].num_registro,
                 p_dat_atu,
                 p_hor_atu,
                 pr_erro_carga[p_ind].den_erro)
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Insereindo","carga_erro_265")
            RETURN FALSE
         END IF
      END IF
   END FOR   

   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol1071_resumo()
#------------------------#

   LET p_ind_carga = p_ind_carga + 1
   LET pr_carga[p_ind_carga].den_banco  = p_den_banco 
   LET pr_carga[p_ind_carga].arquivo    = p_arquivo
   LET pr_carga[p_ind_carga].reg_lido   = p_reg_lido
   LET pr_carga[p_ind_carga].consistido = p_consistido

END FUNCTION
   
#------------------------------#
FUNCTION pol1071_proces_carga()
#------------------------------#

   DEFINE p_pri_reg        SMALLINT,
          p_banco          CHAR(03),
          p_dat_vencto     CHAR(10),
          p_dat_solicit    CHAR(10),
          p_num_parcela    CHAR(03),
          p_qtd_parcela    CHAR(03),
          p_val_emprestimo CHAR(12),
          p_val_parcela    CHAR(12),
          p_posi_header    INTEGER,
          p_posi_bco_header INTEGER,
          p_bco_arq        CHAR(03),
          p_num_cpf        CHAR(19),
          p_contrato       INTEGER

          
   LET p_pri_reg = TRUE
   
   SELECT MAX(id_registro)
     INTO p_id_registro
     FROM arq_banco_265

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","arq_banco_265")
      RETURN FALSE
   END IF
   
   IF p_id_registro IS NULL THEN
      LET p_id_registro = 0
   END IF
         
   SELECT posicao,
          tamanho
     INTO p_posi_id,
          p_tama_id
     FROM layout_265
    WHERE cod_banco = p_cod_banco
      AND campo     = 'IDENTIFICADOR'

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","layout_265")
      RETURN FALSE
   END IF
   
   SELECT posi_header,
          posi_bco_header
     INTO p_posi_header,
          p_posi_bco_header
     FROM banco_265
    WHERE cod_banco = p_cod_banco

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","banco_265")
      RETURN FALSE
   END IF

   DECLARE cq_temp CURSOR FOR
    SELECT registro
      FROM banco_temp_265

   FOREACH cq_temp INTO p_registro   
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","cq_temp")
         RETURN FALSE
      END IF

      IF p_pri_reg THEN
         LET p_pri_reg = FALSE
         LET p_dat_arq = p_registro[p_posi_header,(p_posi_header + 5)]
         LET p_bco_arq = p_registro[p_posi_bco_header,(p_posi_bco_header + 2)]
         
         IF p_dat_arq <> p_dat_ref THEN
            LET p_msg = "Data do header diferente da data informada - H = ",p_dat_arq," R = ",p_dat_ref
            CALL pol1071_erro_carga()
         END IF

         IF p_bco_arq <> p_extensao THEN
            LET p_msg = "Cod. banco no header diferente do cod. banco cadastrado"
            CALL pol1071_erro_carga()
         END IF
         
         IF p_qtd_erro > 0 THEN
            RETURN TRUE
         END IF
      END IF
      
      LET p_posi_fim = p_posi_id + p_tama_id - 1
      LET p_cod_tip_lido = p_registro[p_posi_id, p_posi_fim]
      
      IF p_cod_tip_lido <> p_cod_tip_reg THEN
         CONTINUE FOREACH
      END IF
      
      LET p_reg_lido = p_reg_lido + 1
      INITIALIZE p_arq_banco TO NULL
                  
      LET p_banco                     = pol1071_le_layout('BANCO')
      LET p_num_reg                   = pol1071_le_layout('CONTADOR')
      LET p_arq_banco.nom_funcionario = pol1071_le_layout('FUNCIONARIO')
      LET p_num_cpf                   = pol1071_le_layout('CPF') 
      LET p_dat_vencto                = pol1071_le_layout('DATA')
      LET p_num_parcela               = pol1071_le_layout('PARCELA')
      LET p_qtd_parcela               = pol1071_le_layout('PRAZO')
      LET p_dat_solicit               = pol1071_le_layout('SOLICITACAO')
      LET p_val_emprestimo            = pol1071_le_layout('EMPRESTIMO')
      LET p_val_parcela               = pol1071_le_layout('PRESTACAO')
      LET p_contrato                  = pol1071_le_layout('CONTRATO')
      LET p_arq_banco.num_contrato    = p_contrato
      LET p_arq_banco.dat_referencia  = p_dat_referencia
      LET p_arq_banco.nom_arq_txt     = p_nom_arquivo   
      LET p_arq_banco.cod_status      = 'P'
      LET p_arq_banco.cod_tip_contr   = 'N'

      IF p_banco IS NULL THEN
         LET p_msg = "Código do banco está nulo"
         CALL pol1071_erro_carga()
      ELSE
         SELECT cod_banco
           FROM banco_265
          WHERE cod_banco = p_banco
         
         IF STATUS = 100 THEN
            LET p_msg = "O banco enviado não está cadastrado"
            CALL pol1071_erro_carga()
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','banco_265')
               RETURN FALSE
            END IF
            LET p_arq_banco.cod_banco = p_banco
         END IF
      END IF

      IF p_num_reg IS NULL THEN
         LET p_msg = "Conteúdo do contador está nulo"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_num_seq = p_num_reg
         IF STATUS <> 0 THEN
            LET p_msg = "Conteúdo do contador não é numérico"
            CALL pol1071_erro_carga()
         ELSE
            LET p_arq_banco.num_seq_txt = p_num_seq
         END IF
      END IF      

      IF p_arq_banco.nom_funcionario IS NULL OR
         LENGTH(p_arq_banco.nom_funcionario) = 0  THEN
         LET p_msg = "Nome do funcionário está nulo"
         CALL pol1071_erro_carga()
      END IF      

      IF p_num_cpf IS NULL THEN
         LET p_msg = "Número do CPF está nulo"
         CALL pol1071_erro_carga()
      ELSE
         IF LENGTH(p_num_cpf) < 11 THEN
            LET p_msg = "O número do CPF não é válido"
            CALL pol1071_erro_carga()
         ELSE
            LET p_arq_banco.num_cpf = p_num_cpf[1,3],'.',p_num_cpf[4,6],'.',                            
                                      p_num_cpf[7,9],'-',p_num_cpf[10,11]                                     
         END IF
      END IF    
      
      IF p_dat_vencto IS NULL OR p_dat_vencto = '00000000' THEN
         LET p_msg = "A data de vencimento nâo e válida"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_arq_banco.dat_vencto = p_dat_vencto
         IF STATUS <> 0 THEN
            LET p_msg = "Conteúdo da data de vencimento não é uma data válida"
            CALL pol1071_erro_carga()
         END IF
      END IF    
      
      IF p_num_parcela IS NULL THEN
         LET p_msg = "Número da parcela está nulo"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_arq_banco.num_parcela = p_num_parcela
         IF STATUS <> 0 THEN
            LET p_msg = "O número da parcela não é um valor numérico"
            CALL pol1071_erro_carga()
         END IF
      END IF    
        
      IF p_qtd_parcela IS NULL THEN
         LET p_msg = "A quantidade de parcela está nula"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_arq_banco.qtd_parcela = p_qtd_parcela
         IF STATUS <> 0 THEN
            LET p_msg = "A quantidade de parcela não é um valor numérico"
            CALL pol1071_erro_carga()
         END IF
      END IF    

      IF p_dat_solicit = '00000000' THEN
         LET p_dat_solicit = NULL
      ELSE
         LET STATUS = 0
         LET p_arq_banco.dat_solicitacao = p_dat_solicit
         IF STATUS <> 0 THEN
            LET p_msg = "Conteúdo da data de solicitação não é uma data válida"
            CALL pol1071_erro_carga()
         END IF
      END IF    

      IF p_val_emprestimo IS NULL THEN
         LET p_msg = "O valor do empréstimo está nula"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_arq_banco.val_emprestimo = p_val_emprestimo / 100
         IF STATUS <> 0 THEN
            LET p_msg = "O valor do empréstimo não é um valor numérico"
            CALL pol1071_erro_carga()
         END IF
      END IF    

      IF p_val_parcela IS NULL THEN
         LET p_msg = "O valor da parcela está nula"
         CALL pol1071_erro_carga()
      ELSE
         LET STATUS = 0
         LET p_arq_banco.val_parcela = p_val_parcela / 1000
         IF STATUS <> 0 THEN
            LET p_msg = "O valor da parcela não é um valor numérico"
            CALL pol1071_erro_carga()
         END IF
      END IF    

      IF p_arq_banco.num_contrato IS NULL THEN
         LET p_msg = "O número do contrato está nulo"
         CALL pol1071_erro_carga()
      END IF    
      
      IF p_qtd_erro = 0 THEN
         IF NOT pol1071_ins_arq_banco() THEN
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1071_busca_empresa()
#------------------------------#

   DEFINE p_cod_emp CHAR(02),
          p_mat     INTEGER,
          p_pri_emp CHAR(02),
          p_pri_mat INTEGER

   INITIALIZE p_estado TO NULL
   LET m_cod_empresa = ' '
   LET m_num_matricula = 0
         
   DECLARE cq_busca CURSOR FOR
    SELECT cod_empresa,
           num_matricula,
           uf,
           id_registro
      FROM hist_movto_265
     WHERE num_cpf = p_numero_cpf
       AND dat_referencia = p_dat_referencia
       AND tip_evento = '1'

   FOREACH cq_busca INTO
           m_cod_empresa,
           m_num_matricula,
           p_estado,
           p_id_reg_hist
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','hist_movto_265:cq_busca')   
         RETURN FALSE
      END IF

      IF NOT pol1071_atu_hist_265() THEN
         RETURN FALSE
      END IF

      IF NOT pol1071_atu_arq_bco() THEN
         RETURN FALSE
      END IF
      
      LET p_tem_desconto = TRUE
      
      RETURN TRUE
   
   END FOREACH
   
   LET p_tem_desconto = FALSE
   
   DECLARE cq_emp_mat CURSOR FOR
    SELECT a.cod_empresa,
           a.num_matricula
      FROM fun_infor a, funcionario b
     WHERE a.num_cpf = p_numero_cpf
       AND a.cod_empresa = b.cod_empresa
       AND a.num_matricula = b.num_matricula
       AND b.dat_demis IS NULL
   
   FOREACH cq_emp_mat INTO m_cod_empresa, m_num_matricula 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fun_infor:1')   
         RETURN FALSE
      END IF

      SELECT uni_feder                                                                            
        INTO p_cod_uni_feder                                                                      
        FROM empresa                                                                              
       WHERE cod_empresa = m_cod_empresa                                                              
     
      IF STATUS <> 0 THEN                                                                         
         LET p_estado = NULL                                                                
      ELSE                 
         IF p_cod_uni_feder = 'RJ' THEN                                                           
            LET p_estado = p_cod_uni_feder                                                     
         ELSE
            LET p_estado = 'BR'
         END IF
      END IF                                                                                      
                  
      IF NOT pol1071_atu_arq_bco() THEN
         RETURN FALSE
      END IF
      
      RETURN TRUE

   END FOREACH

   DECLARE cq_dat_demis CURSOR FOR
    SELECT a.cod_empresa,
           a.num_matricula
      FROM fun_infor a, funcionario b
     WHERE a.num_cpf = p_numero_cpf
       AND a.cod_empresa = b.cod_empresa
       AND a.num_matricula = b.num_matricula
     ORDER BY b.dat_demis DESC
   
   FOREACH cq_dat_demis INTO m_cod_empresa, m_num_matricula 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fun_infor:1')   
         RETURN FALSE
      END IF

      SELECT uni_feder                                                                            
        INTO p_cod_uni_feder                                                                      
        FROM empresa                                                                              
       WHERE cod_empresa = m_cod_empresa                                                              
     
      IF STATUS <> 0 THEN                                                                         
         LET p_estado = NULL                                                                
      ELSE                 
         IF p_cod_uni_feder = 'RJ' THEN                                                           
            LET p_estado = p_cod_uni_feder                                                     
         ELSE
            LET p_estado = 'BR'
         END IF
      END IF                                                                                      
      
      IF NOT pol1071_atu_arq_bco() THEN
         RETURN FALSE
      END IF

      RETURN TRUE

   END FOREACH

   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1071_atu_hist_265()
#-----------------------------#

	UPDATE hist_movto_265
      SET cod_banco = p_cod_banco
   WHERE id_registro = p_id_reg_hist
   AND cod_evento in(select distinct cod_evento from evento_265
   WHERE cod_banco = p_cod_banco)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','hist_movto_265')   
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1071_atu_arq_bco()
#-----------------------------#
   
   UPDATE arq_banco_265 
      SET cod_empresa = m_cod_empresa,
          num_matricula = m_num_matricula,
          uf = p_estado
    WHERE id_registro = p_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','arq_banco_265')   
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1071_le_layout(p_campo)
#---------------------------------#

   DEFINE p_campo LIKE layout_265.campo
   
   SELECT posicao,
          tamanho
     INTO p_posi_ini,
          p_tamanho
     FROM layout_265
    WHERE cod_banco = p_cod_banco
      AND campo     = p_campo

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","layout_265")
      RETURN ""
   END IF

   LET p_posi_fim = p_posi_ini + p_tamanho - 1

   RETURN p_registro[p_posi_ini, p_posi_fim] CLIPPED

END FUNCTION

#-------------------------------#
FUNCTION pol1071_ins_arq_banco()
#-------------------------------#

   LET p_arq_banco.cod_empresa   = ' '  
   LET p_arq_banco.num_matricula = 0
   LET p_id_registro = p_id_registro + 1
   LET p_arq_banco.id_registro = p_id_registro
   
   INSERT INTO arq_banco_265
    VALUES(p_arq_banco.*)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Inserindo","arq_banco_265")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1071_grava_contrato()
#--------------------------------#
   
   SELECT dat_liquidacao
     INTO p_dat_liquidacao
     FROM contr_consig_265
    WHERE cod_banco    = p_cod_banco
      AND num_contrato = p_num_contrato
   
   IF STATUS = 100 THEN 
      INITIALIZE p_dat_liquidacao TO NULL
      IF NOT pol1071_ins_contrato() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         
         LET p_nom_usuario = 'POL1071'
         
         IF p_dat_liquidacao IS NULL        OR
            p_dat_liquidacao = " "          OR 
            p_dat_liquidacao = '30/12/1899' OR
            p_tem_desconto = TRUE        THEN
            INITIALIZE p_dat_liquidacao TO NULL
         ELSE
            DECLARE cq_audit CURSOR FOR
             SELECT nom_usuario
               FROM contr_audit_265
              WHERE num_contrato = p_num_contrato
                AND cod_banco    = p_cod_banco
              ORDER BY dat_operacao desc
            
            FOREACH cq_audit INTO p_nom_user
               
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo','contr_audit_265')
                  RETURN FALSE
               END IF
                              
               LET p_nom_usuario = p_nom_user
               EXIT FOREACH
            
            END FOREACH
         END IF
         
         IF p_nom_usuario = 'POL1071' THEN
            INITIALIZE p_dat_liquidacao TO NULL 
            UPDATE contr_consig_265
               SET num_parcela    = m_num_parcela,
                   qtd_parcela    = m_qtd_parcela,
                   dat_vencto     = m_dat_vencto,
                   cod_empresa    = m_cod_empresa,
                   num_matricula  = m_num_matricula,
                   dat_liquidacao = p_dat_liquidacao
             WHERE cod_banco    = p_cod_banco
               AND num_contrato = p_num_contrato
         
            IF STATUS <> 0 THEN  
               CALL log003_err_sql("Atualizando","contr_consig_265")
               RETURN FALSE
            END IF
         END IF
      ELSE
         CALL log003_err_sql("Lendo","contr_consig_265")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1071_ins_contrato()
#------------------------------#

   INITIALIZE p_contr_consig TO NULL
   
   LET p_contr_consig.id_arq_banco    = p_id_registro
   LET p_contr_consig.cod_empresa     = m_cod_empresa  
   LET p_contr_consig.num_cpf         = p_numero_cpf
   LET p_contr_consig.num_matricula   = m_num_matricula     
   LET p_contr_consig.nom_funcionario = p_nom_funcionario
   LET p_contr_consig.cod_banco       = p_cod_banco
   LET p_contr_consig.num_contrato    = p_num_contrato
   LET p_contr_consig.cod_tip_contr   = 'N' 
   LET p_contr_consig.val_parcela     = p_val_parcela
   LET p_contr_consig.qtd_parcela     = m_qtd_parcela
   LET p_contr_consig.num_parcela     = m_num_parcela
   LET p_contr_consig.dat_contrato    = m_dat_solicitacao 
   LET p_contr_consig.val_emprestimo  = m_val_emprestimo
   LET p_contr_consig.valor_30        = 0
   LET p_contr_consig.dat_vencto      = m_dat_vencto
   LET p_contr_consig.cod_status      = 'A'
   LET p_contr_consig.uf              = p_estado
   LET p_contr_consig.dat_liquidacao  = null
   LET p_contr_consig.dat_rescisao    = null
   LET p_contr_consig.dat_afastamento = null
         
   INSERT INTO contr_consig_265
    VALUES(p_contr_consig.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Inserindo","contr_consig_265")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1071_atu_contr()
#---------------------------#

   UPDATE contr_consig_265
      SET dat_rescisao   = p_dat_demis,
          valor_30       = p_val_30,
          dat_liquidacao = p_dat_demis
    WHERE num_cpf = p_numero_cpf
      AND cod_banco = p_cod_banco
      AND cod_empresa = m_cod_empresa
      AND num_matricula = m_num_matricula

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualizando","contr_consig_265")
   END IF
      
END FUNCTION
   
#-----------------------------#
FUNCTION pol1071_exib_resumo()
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10712") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10712 AT 7,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_tela.mes_ref TO mes_ref
   DISPLAY p_tela.ano_ref TO ano_ref

   CALL SET_COUNT(p_ind_carga)     
      
   DISPLAY ARRAY pr_carga TO sr_carga.*
             
   CLOSE WINDOW w_pol10712
      
END FUNCTION

#-----------------------------#
FUNCTION pol1071_ja_arbitrou()
#-----------------------------#

   SELECT COUNT(id_registro)
     INTO p_count
     FROM diverg_consig_265
    WHERE dat_referencia = p_dat_referencia
      AND dat_acerto_prev IS NOT NULL
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","diverg_consig_265")
      RETURN true
   END IF

   IF p_count > 0 THEN
      LET p_msg = 'A consitência, para o período informado\n',
                  'já foi efetuada e, inclusive, já foram\n',
                  'arbitradas ', p_count USING '&&&&', ' divergência(s)!\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN true      
   END IF

    RETURN false
    
 end FUNCTION
 
#------------------------------#
FUNCTION pol1071_consistencia()
#------------------------------#

   DEFINE p_bco_txt CHAR(04),
          l_msg     CHAR(150)

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   if pol1071_ja_arbitrou() then
      RETURN false
   end if

   LET pr_men[1].mensagem = 'Verificando carga dos bancos, aguarde. '
   CALL pol1071_exib_mensagem()
   
   LET p_msg = NULL
   LET p_tip_evento = 1
   LET p_tip_acerto = 5
   
   DECLARE cq_bcos CURSOR FOR
    SELECT cod_banco
      FROM banco_265
     WHERE TO_CHAR(dat_termino, 'YYYY-MM') >= p_ano_mes_ref
        OR dat_termino IS NULL
     ORDER BY cod_banco
   
   FOREACH cq_bcos INTO p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","cq_bcos")
         RETURN FALSE
      END IF
      
      SELECT COUNT(cod_banco)
        INTO p_count
        FROM arq_banco_265
       WHERE cod_banco      = p_cod_banco
         AND dat_referencia = p_dat_referencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','arq_banco_265:2')
         RETURN FALSE
      END IF
   
      IF p_count = 0 THEN
         LET p_bco_txt = p_cod_banco USING '&&&', ' '
         LET p_msg = p_msg CLIPPED, p_bco_txt
      END IF

   END FOREACH
  
   IF p_msg IS NOT NULL THEN
      LET p_msg = p_msg CLIPPED, ': banco(s) não carregado(s)!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE      
   END IF
        
   LET pr_men[1].mensagem = 'Verificando fechamento da folha '
   CALL pol1071_exib_mensagem()

   IF NOT pol1071_checa_fechamento() THEN
      RETURN FALSE
   END IF

   IF NOT pol1071_checa_eventos() THEN
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   DELETE FROM diverg_consig_265
    WHERE dat_referencia = p_dat_referencia
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando","diverg_consig_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   UPDATE arq_banco_265
      SET cod_status = 'P'
    WHERE dat_referencia = p_dat_referencia
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Update","arq_banco_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
         
   LET pr_men[1].mensagem = 'Carregando dados da folha, aguarde. '
   CALL pol1071_exib_mensagem()

   IF NOT pol1071_carrega_hist() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   CALL log085_transacao("BEGIN")

   LET pr_men[1].mensagem = 'Vai ler informações complementares, aguarde. '
   CALL pol1071_exib_mensagem()
  
   CALL pol1071_pega_info_compl() RETURNING p_status
   
   IF NOT p_status THEN   
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'informações complementares concluidas . '
   CALL pol1071_exib_mensagem()
   
   CALL log085_transacao("COMMIT")

   CALL log085_transacao("BEGIN")

   IF NOT pol1071_proces_banco() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
         
   CALL log085_transacao("COMMIT")

   CALL log085_transacao("BEGIN")

   LET pr_men[1].mensagem = 'Vai processsar dados da folha, aguarde . '
   CALL pol1071_exib_mensagem()
   
   IF NOT pol1071_proces_folha() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   CALL log085_transacao("BEGIN")                                                                      
                  
   LET pr_men[1].mensagem = 'Vai verificar demitidos. '
   CALL pol1071_exib_mensagem()
	
   IF NOT pol1071_checa_demitido() THEN                                                                   
      CALL log085_transacao("ROLLBACK")                                                                
      RETURN FALSE                                                                                     
   END IF                                                                                              

   CALL log085_transacao("COMMIT")

   CALL log085_transacao("BEGIN")

   LET p_tip_evento = 4
   
   LET pr_men[1].mensagem = 'Vai processar reembolso. '
   CALL pol1071_exib_mensagem()

   IF NOT pol1071_proces_rembolso() THEN # paulo pediu para não processar reembolso
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   CALL log085_transacao("BEGIN")    

   LET pr_men[1].mensagem = 'Vai liquidar contratos. '
   CALL pol1071_exib_mensagem()

   IF NOT pol1071_liqui_contr() THEN                                                                   
      CALL log085_transacao("ROLLBACK")                                                                
      RETURN FALSE                                                                                     
   END IF                                                                                              

   LET pr_men[1].mensagem = 'Liquidou contratos. '
   CALL pol1071_exib_mensagem()

   CALL log085_transacao("COMMIT")

   #CALL log085_transacao("BEGIN")                                                                      

   #IF NOT pol1071_multi_banco() THEN                                                                   
   #   CALL log085_transacao("ROLLBACK")                                                                
   #   RETURN FALSE                                                                                     
   #END IF                                                                                              
                                                                                                       
   CALL log085_transacao("COMMIT")                                                                     

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1071_checa_fechamento()
#----------------------------------#

   LET p_ind = 0
   
   DECLARE cq_emp CURSOR FOR
    SELECT cod_empresa
      FROM empresa
     WHERE cod_empresa IN
      (SELECT DISTINCT cod_empresa FROM hist_movto
        WHERE dat_referencia = p_dat_referencia)
   
   FOREACH cq_emp INTO m_cod_empresa
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_emp')
         RETURN FALSE
      END IF

      SELECT cod_empresa
        FROM migrou_protheus_265
       WHERE cod_empresa = m_cod_empresa
         AND dat_migrou <= p_dat_referencia

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','cq_emp')
            RETURN FALSE
         END IF
      END IF
      
      SELECT COUNT(cod_empresa)
        INTO p_count
        FROM ultimo_proces
       WHERE cod_empresa = m_cod_empresa
         AND MONTH(dat_referencia) = p_tela.mes_ref
         AND YEAR(dat_referencia)  = p_tela.ano_ref
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ultimo_proces')
         RETURN FALSE
      END IF

      IF p_count = 0 THEN
         LET p_ind = p_ind + 1
         LET pr_empresa[p_ind].cod_empresa = m_cod_empresa
         SELECT den_empresa
           INTO pr_empresa[p_ind].den_empresa
           FROM empresa
          WHERE cod_empresa = m_cod_empresa
         IF STATUS <> 0 THEN
            LET pr_empresa[p_ind].den_empresa = NULL
         END IF
      END IF
   
   END FOREACH

   IF p_ind > 0 THEN
      CALL pol1071_exibe_empresas()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1071_exibe_empresas()
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10713") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10713 AT 6,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_ind)
   DISPLAY ARRAY pr_empresa TO sr_empresa.*

END FUNCTION

#-------------------------------#
FUNCTION pol1071_carrega_hist()
#-------------------------------#

   INITIALIZE p_hist_movto TO NULL
   
   LET p_hist_movto.cod_status = 'P'
   
   DELETE FROM hist_movto_265
    WHERE dat_referencia = p_dat_referencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','hist_movto_265')
      RETURN FALSE
   END IF
   
   SELECT COUNT(dat_referencia)
     INTO p_count
     FROM hist_movto_265
    WHERE dat_referencia = p_dat_referencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','hist_movto_265:1')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      CALL log0030_mensagem(
         'Não foi possivel regravar os eventos na tabela hist_movto_265','excla')
      RETURN FALSE
   END IF
   
   DECLARE cq_carrega CURSOR FOR
   SELECT cod_empresa,
          num_matricula,
          dat_referencia,
          cod_tip_proc,
          cod_categoria,
          cod_evento,
          dat_pagto,
          ies_calculado,
          qtd_horas,
          val_evento
     FROM hist_movto                                                                        
    WHERE dat_referencia = p_dat_referencia                                                   
      AND cod_evento IN
          (SELECT DISTINCT cod_evento 
             FROM evento_265
            WHERE tip_evento IN (1,4))
     ORDER BY num_matricula, cod_empresa
   
   FOREACH cq_carrega INTO 
       p_hist_movto.cod_empresa,   
       p_hist_movto.num_matricula, 
       p_hist_movto.dat_referencia,
       p_hist_movto.cod_tip_proc,  
       p_hist_movto.cod_categoria, 
       p_hist_movto.cod_evento,    
       p_hist_movto.dat_pagto,     
       p_hist_movto.ies_calculado, 
       p_hist_movto.qtd_horas,     
       p_hist_movto.val_evento    

      IF STATUS <> 0 THEN                                                                      
         CALL log003_err_sql('Lendo','hist_movto:cq_carrega')                                      
         RETURN FALSE                                                                          
      END IF       

      SELECT cod_empresa
        FROM migrou_protheus_265
       WHERE cod_empresa = p_hist_movto.cod_empresa
         AND dat_migrou <= p_dat_referencia

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','cq_emp')
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol1071_le_estado(p_hist_movto.cod_empresa) THEN 
         RETURN FALSE
      END IF

      LET p_hist_movto.uf = p_estado

      SELECT num_cpf
        INTO p_hist_movto.num_cpf
        FROM fun_infor
       WHERE cod_empresa   = p_hist_movto.cod_empresa
         AND num_matricula = p_hist_movto.num_matricula
      
      IF STATUS <> 0 THEN                                                                      
         CALL log003_err_sql('Lendo','fun_infor:cq_carrega')                                      
         RETURN FALSE                                                                          
      END IF  
      
 	  	SELECT DISTINCT tip_evento
	  	  INTO p_hist_movto.tip_evento
	  	  FROM evento_265
	  	 WHERE cod_evento = p_hist_movto.cod_evento
	  	   AND estado     = p_estado

      IF STATUS = 100 THEN 
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN                                                                      
            CALL log003_err_sql('Lendo','evento_265:cq_carrega')                                      
            RETURN FALSE                                                                          
         END IF
      END IF       

      LET p_hist_movto.cod_banco = 0 
      
      IF NOT pol1071_le_banco_contr() THEN
         RETURN FALSE
      END IF                                                       
      
      IF p_hist_movto.cod_banco = 0 THEN
         CONTINUE FOREACH
      END IF

      SELECT MAX(id_registro)
        INTO p_hist_movto.id_registro
        FROM hist_movto_265

      IF STATUS <> 0 THEN                                                                      
         CALL log003_err_sql('Lendo','hist_movto_265:cq_carrega')                                      
         RETURN FALSE                                                                          
      END IF       
      
      IF p_hist_movto.id_registro IS NULL THEN
         LET p_hist_movto.id_registro = 1
      ELSE
         LET p_hist_movto.id_registro = p_hist_movto.id_registro + 1
      END IF

      INSERT INTO hist_movto_265
       VALUES(p_hist_movto.*)
      
      IF STATUS <> 0 THEN                                                                      
         CALL log003_err_sql('inserindo','hist_movto_265:cq_carrega')                                      
         RETURN FALSE                                                                          
      END IF       
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION            

#--------------------------------#
FUNCTION pol1071_le_banco_contr()
#--------------------------------#                                              

   SELECT COUNT(DISTINCT cod_banco)
     INTO p_count
		 FROM arq_banco_265	                                                   	
    WHERE num_cpf = p_hist_movto.num_cpf                                       
		  AND dat_referencia = p_dat_referencia
                                                                                
   IF STATUS <> 0 THEN                                                                          
      CALL log003_err_sql('Lendo','arq_banco_265:cq_cb')                                          
      RETURN FALSE                                                                              
   END IF                                                                    

   IF p_count > 1 THEN      
      DECLARE cq_codb2 CURSOR FOR                                                   
       SELECT DISTINCT                                                            	
              cod_banco                                                           	
   		   FROM arq_banco_265	                                                   	
        WHERE num_cpf = p_hist_movto.num_cpf                                       
		      AND dat_referencia = p_dat_referencia
		      AND val_parcela = p_hist_movto.val_evento                                 
	                                                                              
   	  FOREACH cq_codb2 INTO p_cod_banco                                             
                                                                             
         IF STATUS <> 0 THEN                                                                          
            CALL log003_err_sql('Lendo','arq_banco_265:cq_cb')                                          
            RETURN FALSE                                                                              
         END IF                                                                    

         SELECT cod_banco
	         FROM evento_265                                            	
	        WHERE cod_evento = p_hist_movto.cod_evento                  	
	          AND estado     = p_estado 
	          AND cod_banco  = p_cod_banco

         IF STATUS = 0 THEN                                                                          
            LET p_hist_movto.cod_banco = p_cod_banco                                  
            RETURN TRUE                                                              
         END IF                                                                    
                                                                                
      END FOREACH                                                                  

      DECLARE cq_codb3 CURSOR FOR                                                   
       SELECT DISTINCT                                                            	
              cod_banco                                                           	
   		   FROM arq_banco_265	                                                   	
        WHERE num_cpf = p_hist_movto.num_cpf                                       
		      AND dat_referencia = p_dat_referencia
	                                                                              
   	  FOREACH cq_codb3 INTO p_cod_banco                                             
                                                                             
         IF STATUS <> 0 THEN                                                                          
            CALL log003_err_sql('Lendo','arq_banco_265:cq_cb')                                          
            RETURN FALSE                                                                              
         END IF                                                                    

         SELECT cod_banco
	         FROM evento_265                                            	
	        WHERE cod_evento = p_hist_movto.cod_evento                  	
	          AND estado     = p_estado 
	          AND cod_banco  = p_cod_banco

         IF STATUS = 0 THEN                                                                          
            LET p_hist_movto.cod_banco = p_cod_banco                                  
            RETURN TRUE                                                              
         END IF                                                                    
                                                                                                                                                                
      END FOREACH                                                                  
   ELSE
      IF p_count = 1 THEN
         DECLARE cq_codb1 CURSOR FOR                                                   
          SELECT DISTINCT                                                            	
                 cod_banco                                                           	
       	    FROM arq_banco_265	                                                   	
           WHERE num_cpf = p_hist_movto.num_cpf                                       
		         AND dat_referencia = p_dat_referencia
	                                                                              
   	     FOREACH cq_codb1 INTO p_cod_banco                                             
                                                                             
            IF STATUS <> 0 THEN                                                                          
               CALL log003_err_sql('Lendo','arq_banco_265:cq_cb')                                          
               RETURN FALSE                                                                              
            END IF                                                                    
                                                                                
            LET p_hist_movto.cod_banco = p_cod_banco                                  
                                                                                
            RETURN TRUE                                                              
                                                                                
         END FOREACH                                                                  
      END IF
   END IF   

   DECLARE cq_evento_265 CURSOR FOR
    SELECT cod_banco
	    FROM evento_265                                            	
	   WHERE cod_evento = p_hist_movto.cod_evento                  	
	     AND estado     = p_estado 
	   ORDER BY cod_banco                                	

   FOREACH cq_evento_265 INTO p_cod_banco                                                             

      IF STATUS <> 0 THEN                                                                         
         CALL log003_err_sql('Lendo','evento_265:cq_carrega')                                         
         RETURN FALSE                                                                             
      END IF                                                         
                                                                  
      SELECT COUNT(DISTINCT cod_banco)
        INTO p_count                                 
        FROM contr_consig_265                                                     
       WHERE num_cpf   = p_hist_movto.num_cpf    
         AND cod_banco = p_cod_banco
         AND (dat_liquidacao IS NULL OR
              TO_CHAR(dat_liquidacao, 'YYYY-MM') >= p_ano_mes_ref)
                                                                                
      IF STATUS <> 0 THEN                                                                             
         CALL log003_err_sql('Lendo','arq_banco_265:cq_cbc')                                             
         RETURN FALSE                                                                                 
      END IF                                                                    
      
      IF p_count > 0 THEN
         LET p_hist_movto.cod_banco = p_cod_banco                                  
         EXIT FOREACH                                                            
      END IF                                                                                
   
   END FOREACH                                                                  
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1071_pega_cod_banco()
#-------------------------------#

   DECLARE cq_bco1 CURSOR FOR                            
    SELECT cod_banco,                                         
           dat_vencto                                         
      FROM contr_consig_265                                   
     WHERE cod_empresa   = p_hist_movto.cod_empresa           
       AND num_cpf       = p_hist_movto.num_cpf               
       AND num_matricula = p_hist_movto.num_matricula         
     ORDER BY dat_vencto DESC                                     
                                                              
   FOREACH cq_bco1 INTO p_cod_banco, p_data                                                    
                                                              
      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql('Lendo','contr_consig_265:1')    
         RETURN FALSE                                         
      END IF                                                  
      
      SELECT COUNT(cod_banco)
        INTO p_count
        FROM evento_265
       WHERE cod_evento = p_hist_movto.cod_evento
         AND estado     = p_estado
         AND cod_banco  = p_cod_banco

      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql('Lendo','eventos_265:1')    
         RETURN FALSE                                         
      END IF                                                  
      
      IF p_count > 0 THEN                                        
         RETURN TRUE                                             
      END IF
      
   END FOREACH                                                

   DECLARE cq_bco2 CURSOR FOR                            
    SELECT cod_banco,                                         
           dat_vencto                                         
      INTO p_count                                            
      FROM contr_consig_265                                   
     WHERE num_cpf = p_hist_movto.num_cpf
     ORDER BY dat_vencto DESC                                     
                                                              
   FOREACH cq_bco2 INTO p_cod_banco, p_data                                                    
                                                              
      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql('Lendo','contr_consig_265:1')    
         RETURN FALSE                                         
      END IF                                                  
                                                              
      SELECT COUNT(cod_banco)
        INTO p_count
        FROM evento_265
       WHERE cod_evento = p_hist_movto.cod_evento
         AND estado     = p_estado
         AND cod_banco  = p_cod_banco

      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql('Lendo','eventos_265:1')    
         RETURN FALSE                                         
      END IF                                                  
      
      IF p_count > 0 THEN                                        
         RETURN TRUE                                             
      END IF
                                                 
   END FOREACH                                                

   LET p_cod_banco = 0
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------#
FUNCTION pol1071_checa_eventos()
#-------------------------------#

   DEFINE p_bco_txt CHAR(03)
   
   LET p_msg = NULL
   
   DECLARE cq_cb CURSOR FOR
    SELECT DISTINCT cod_banco   
      FROM arq_banco_265
     WHERE cod_status     = 'P'
       AND dat_referencia = p_dat_referencia
           
   FOREACH cq_cb INTO p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cb')
         RETURN FALSE
      END IF
      
      LET p_bco_txt = p_cod_banco USING '&&&'
      
      SELECT COUNT(cod_evento)
        INTO p_count
        FROM evento_265
       WHERE cod_banco  = p_cod_banco
         AND tip_evento = '1'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','evento_265:tipo-1')
         RETURN FALSE
      END IF
   
      IF p_count = 0 THEN
         LET p_msg = 'Banco ',p_bco_txt,' sem evento de desconto.\n'
      END IF

      SELECT COUNT(cod_evento)
        INTO p_count
        FROM evento_265
       WHERE cod_banco  = p_cod_banco
         AND tip_evento = '4'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','evento_265:tipo-4')
         RETURN FALSE
      END IF
   
      IF p_count = 0 THEN
         LET p_msg = p_msg CLIPPED, 'Banco ',p_bco_txt,' sem evento de reembolso.\n'
      END IF
      
   END FOREACH
   
   IF p_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#Busca empresa, matricula e ultimo movimento 
#de folha do funcionário e atualiza tabela
#arq_banco_265 

#---------------------------------#
FUNCTION pol1071_pega_info_compl()
#---------------------------------#
     
   LET p_tip_diverg = 'B'
   LET p_val_evento = 0
   LET p_val_30     = 0
   LET p_dat_demis  = ''
   LET p_dat_afasta = ''

   DECLARE cq_parte1 CURSOR WITH HOLD FOR                                                         
    SELECT id_registro,                                                                              
           num_contrato,                                                                             
           num_cpf,                                                                                  
           cod_banco,
           nom_funcionario,
           dat_vencto,
           val_parcela,     
           qtd_parcela,     
           num_parcela,     
           dat_solicitacao, 
           val_emprestimo  
      FROM arq_banco_265                                                                             
     WHERE cod_status = 'P'                                                                          
       AND dat_referencia = p_dat_referencia  
     ORDER BY num_cpf, cod_banco
                                                                                                     
   FOREACH cq_parte1 INTO                                                                            
           p_id_registro,                                                                            
           p_num_contrato,                                                                           
           p_numero_cpf,                                                                             
           p_cod_banco,
           p_nom_funcionario,
           m_dat_vencto,
           p_val_parcela,     
           m_qtd_parcela,     
           m_num_parcela,     
           m_dat_solicitacao, 
           m_val_emprestimo  
                                                                                                     
      IF STATUS <> 0 THEN                                                                            
         CALL log003_err_sql('Lendo','cq_parte1')                                                    
         RETURN FALSE                                                                                
      END IF                                                                                         
      
      LET pr_men[1].mensagem = 'Processando 1... ', p_num_contrato
      CALL pol1071_exib_mensagem()
      
      IF NOT pol1071_busca_empresa() THEN
         RETURN FALSE
      END IF
      
      SELECT cod_empresa
        FROM migrou_protheus_265
       WHERE cod_empresa = m_cod_empresa
         AND dat_migrou <= p_dat_referencia

      IF STATUS = 0 THEN
         LET p_cod_status = 'M'
         IF NOT pol1071_atu_status() THEN                                                         
            RETURN FALSE                                                                             
         END IF                                                                                      
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','cq_emp')
            RETURN FALSE
         END IF
      END IF
      
      LET p_val_dif = p_val_parcela                                                                  
      LET p_obs = NULL     
      LET p_val_evento = 0  
      LET p_cod_status = NULL                                                                   

      IF m_num_matricula = 0 THEN     
         LET p_obs  = 'Verificar se e funcionario da empresa.'    
         LET p_mensagem = 'CPF inexistente'                                   
      ELSE                 
         IF NOT pol1071_grava_contrato() THEN
            RETURN FALSE
         END IF
         IF p_dat_liquidacao IS NULL OR
            p_dat_liquidacao = " "   OR 
            p_dat_liquidacao = '30/12/1899' THEN   
         ELSE
            LET p_cod_status = 'D'
            #LET p_obs = 'Cobranca de repasse para contrato liquidado.'   
            #LET p_mensagem = 'Contrato liquidado'                            
         END IF
      END IF                                                                                         

      IF p_obs IS NOT NULL THEN                                                                      
         IF NOT pol1071_ins_diverg() THEN                                                            
            RETURN FALSE                                                                             
         END IF                                                                                      
         LET p_cod_status = 'D'   
      ELSE      
         IF p_cod_status IS NULL THEN                                                            
            LET p_cod_status = 'C'
         END IF
      END IF                                                                                         

      IF NOT pol1071_atu_status() THEN                                                         
         RETURN FALSE                                                                             
      END IF                                                                                      
                                                                                                 
   END FOREACH                                                                                       

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1071_le_desconto()
#-----------------------------#

   SELECT SUM(val_evento)                                                             
     INTO p_val_evento                                                                      
     FROM hist_movto_265                                                                       
    WHERE dat_referencia = p_dat_referencia                                                   
      AND num_cpf        = p_numero_cpf
      AND uf             = p_estado
      AND tip_evento     = '1'
      AND cod_banco      = p_cod_banco
      AND cod_empresa    = m_cod_empresa
      AND num_matricula  = m_num_matricula
                                                                                            
   IF STATUS <> 0 THEN                                                                      
      CALL log003_err_sql('Lendo','hist_movto:1')                                      
      RETURN FALSE                                                                          
   END IF            
   
   IF p_val_evento IS NULL THEN
      LET p_val_evento = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION                                                                       

#--------------------------------#
FUNCTION pol1071_le_estado(p_emp)
#--------------------------------#

   DEFINE p_emp CHAR(02)
   
   SELECT uni_feder
     INTO p_estado
     FROM empresa
    WHERE cod_empresa = p_emp

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF
   
   IF p_estado <> 'RJ' THEN
      LET p_estado = 'BR'
   END IF
   
   RETURN TRUE
   
END FUNCTION                                                                       

#-----------------------------#
FUNCTION pol1071_proces_banco()
#-----------------------------#

   DECLARE cq_pb CURSOR WITH HOLD FOR
    SELECT DISTINCT 
           cod_banco   
      FROM arq_banco_265
     WHERE cod_status     = 'C'
       AND dat_referencia = p_dat_referencia
           
   FOREACH cq_pb INTO p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_pb')
         RETURN FALSE
      END IF
      
      IF NOT pol1071_consi_banco() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION
         
#-----------------------------#
FUNCTION pol1071_consi_banco()
#-----------------------------#

   LET p_tip_diverg = 'F'
   LET p_val_evento = 0
   LET p_val_30     = 0
   LET p_dat_demis  = ''
   LET p_dat_afasta = ''

   DECLARE cq_parte2 CURSOR WITH HOLD FOR                                                           
    SELECT num_cpf,     
           uf,  
           cod_empresa,
           num_matricula,                                                                             
           SUM(val_parcela)                                                                            
      FROM arq_banco_265                                                                               
     WHERE dat_referencia = p_dat_referencia  
       AND cod_banco  = p_cod_banco                                                                   
       AND cod_status = 'C'                                                                            
     GROUP BY num_cpf, uf, cod_empresa, num_matricula                                                  
     ORDER BY num_cpf                                                                                  
                                                                                                       
   FOREACH cq_parte2 INTO                                                                              
           p_numero_cpf, 
           p_estado, 
           m_cod_empresa,
           m_num_matricula,                                                                             
           p_val_parcela                                                                               
                                                                                                       
      IF STATUS <> 0 THEN                                                                              
         CALL log003_err_sql('Lendo','cq_bxf')                                                         
         RETURN FALSE                                                                                  
      END IF                                                                                           

      LET pr_men[1].mensagem = 'Processando 2... ', p_numero_cpf, ' ', p_cod_banco
      CALL pol1071_exib_mensagem()
      INITIALIZE p_dat_afastamento   TO NULL
      DECLARE cq_fic cursor for
      SELECT dat_ini_afasta                                         
        FROM ficha_afasta                                              
       WHERE cod_empresa   = m_cod_empresa                             
         AND num_matricula = m_num_matricula                           
         AND (TO_CHAR(dat_ini_afasta, 'YYYY-MM') <= p_ano_mes_ref
              AND (TO_CHAR(dat_fim_afasta, 'YYYY-MM') >= p_ano_mes_ref))
	    
	    FOREACH cq_fic into p_dat_afastamento
	                                                                  
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_fic')                                                         
            RETURN FALSE                                                                                  
         END IF
         
         EXIT FOREACH
         
      END FOREACH

      UPDATE contr_consig_265
         SET dat_afastamento = p_dat_afastamento
       WHERE num_cpf = p_numero_cpf

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','contr_consig_265')                                                         
         RETURN FALSE                                                                                  
      END IF
                                                                                    
      IF NOT pol1071_le_desconto() THEN                                                                
         RETURN FALSE                                                                                  
      END IF              
      
      LET p_cod_status = 'L'

      IF p_val_parcela <> p_val_evento THEN

         IF NOT pol1071_checa_diverg() THEN                                                               
            RETURN FALSE                                                                                  
         END IF                                                                                           
                                                                                                       
         IF p_obs IS NOT NULL THEN    
            IF NOT pol1071_ins_diverg() THEN                                                              
               RETURN FALSE                                                                               
            END IF                                                                                        
            LET p_cod_status = 'D'                                                                        
         END IF                                                                                           
      
      END IF
                                                                                                 
      IF NOT pol1071_atu_tabs_origens() THEN                                                                
         RETURN FALSE                                                                                  
      END IF                                                                                           
                                                                                                    
      LET p_tip_diverg = 'F'
                                                                                              
   END FOREACH                                                                                         
   
   RETURN TRUE
   
END FUNCTION
  
#----------------------------#
FUNCTION pol1071_liqui_contr()
#----------------------------#

   DEFINE p_liquida SMALLINT
   
   LET p_data = TODAY
   
   DECLARE cq_liquida CURSOR FOR
    SELECT cod_banco
      FROM banco_265
   
   FOREACH cq_liquida INTO p_cod_banco
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','banco_265:cq_liquida')
         RETURN FALSE
      END IF
      
      DECLARE cq_le_contr CURSOR FOR
       SELECT num_contrato
         FROM contr_consig_265
        WHERE cod_banco = p_cod_banco                     
          AND dat_liquidacao IS NULL
               
      FOREACH cq_le_contr INTO p_num_contrato
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','contr_consig_265:cq_le_contr')
            RETURN FALSE
         END IF
         
         SELECT DISTINCT num_contrato 
           FROM arq_banco_265     
          WHERE dat_referencia = p_dat_referencia   
            AND cod_banco      = p_cod_banco         
            AND num_contrato   = p_num_contrato
      
         IF STATUS = 100 THEN
            IF NOT pol1071_liquida_contrato() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','contr_consig_265:cq_le_contr')
               RETURN FALSE
            END IF
         END IF
               
      END FOREACH
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1071_liquida_contrato()
#----------------------------------#

   DEFINE p_dat_operacao DATETIME YEAR TO SECOND
   
   UPDATE contr_consig_265                                   
      SET dat_liquidacao = p_data                                  
    WHERE cod_banco    = p_cod_banco                               
      AND num_contrato = p_num_contrato                            
                                                                
   IF STATUS <> 0 THEN                                             
      CALL log003_err_sql('Atualizando','contr_consig_265')        
      RETURN FALSE                                                 
   END IF                                                          
                                                                
   LET p_dat_operacao = CURRENT                                    
                                                             
   INSERT INTO contr_audit_265                                     
    VALUES(p_cod_empresa,                                          
           'POL1071',                                              
           p_num_contrato,                                         
           'Liquidou',                                             
           p_dat_operacao, 
           p_cod_banco)                                         
                                                                   
   IF STATUS <> 0 THEN                                             
      CALL log003_err_sql('Inserindo','contr_audit_265')           
      RETURN FALSE                                                 
   END IF                                                          

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1071_ins_diverg()
#---------------------------#


   DEFINE l_desc_evento_tot         DECIMAL(12,2)
   INITIALIZE p_diverg_consig TO NULL
   
   SELECT MAX(id_registro)
     INTO p_diverg_consig.id_registro
     FROM diverg_consig_265
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','diverg_consig_265')
      RETURN FALSE
   END IF
   
   IF p_diverg_consig.id_registro IS NULL THEN
      LET p_diverg_consig.id_registro = 0
   END IF

   IF m_num_matricula = 0 OR m_cod_empresa = 0 THEN
   ELSE
      SELECT nom_funcionario                                   
        INTO p_nom_funcionario                                 
        FROM funcionario                                       
       WHERE cod_empresa   = m_cod_empresa                         
         AND num_matricula = m_num_matricula                       
                                                               
      IF STATUS = 100 THEN                                     
         LET p_nom_funcionario = NULL                          
      ELSE                                                      
         IF STATUS <> 0 THEN                                   
            CALL log003_err_sql('Lendo','funcionario:nome')    
            RETURN FALSE                                       
         END IF                                                
      END IF         
   END IF                                          
   
   LET p_diverg_consig.id_registro    = p_diverg_consig.id_registro + 1
   LET p_diverg_consig.cod_empresa    = m_cod_empresa
   LET p_diverg_consig.cod_banco      = p_cod_banco  
   LET p_diverg_consig.num_cpf        = p_numero_cpf 
   LET p_diverg_consig.num_matricula  = m_num_matricula
   LET p_diverg_consig.dat_referencia = p_dat_referencia
   IF p_val_30 IS NULL OR p_val_30 = 0 THEN
      LET p_diverg_consig.val_acerto  = p_val_dif
      LET p_diverg_consig.tip_acerto  = p_tip_acerto
   ELSE
      IF p_ano_mes_demis = p_ano_mes_ref  THEN
		LET p_diverg_consig.val_acerto  = p_val_30
		LET p_diverg_consig.tip_acerto  = 5
      ELSE
	    	LET p_diverg_consig.val_acerto  = p_val_dif
        LET p_diverg_consig.tip_acerto  = p_tip_acerto
	  END IF
    END IF
   
     LET l_desc_evento_tot = 0 
	 SELECT SUM(hist_movto.val_evento)
	       INTO l_desc_evento_tot
     FROM hist_movto                                                                     
    WHERE dat_referencia = p_dat_referencia 
	  AND cod_empresa=m_cod_empresa
      AND num_matricula=m_num_matricula	  
      AND cod_evento IN
          (SELECT DISTINCT cod_evento 
             FROM evento_265
            WHERE tip_evento IN (1)
			  AND estado=p_estado)
  
    IF l_desc_evento_tot > 0  THEN 
		LET p_diverg_consig.val_folha       = l_desc_evento_tot
	ELSE
		LET p_diverg_consig.val_folha       = p_val_evento
	END IF 
   
   LET p_diverg_consig.observacao     = p_obs
   LET p_diverg_consig.cod_status     = 'I'
   LET p_diverg_consig.tip_diverg     = p_tip_diverg
   LET p_diverg_consig.dat_rescisao    = p_dat_demis
   LET p_diverg_consig.dat_afastamento = p_dat_afasta
   LET p_diverg_consig.valor_30        = p_val_30
   LET p_diverg_consig.uf              = p_estado
   LET p_diverg_consig.val_banco       = p_val_parcela
   LET p_diverg_consig.mensagem        = p_mensagem
   LET p_diverg_consig.nom_funcionario = p_nom_funcionario
   LET p_diverg_consig.tip_evento      = p_tip_evento
   
   INSERT INTO diverg_consig_265
    VALUES(p_diverg_consig.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','diverg_consig_265')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1071_le_emp_mat()
#----------------------------#

   DECLARE cq_empmat CURSOR FOR
    SELECT DISTINCT
           cod_empresa,
           num_matricula                                                                       
      FROM arq_banco_265                                                                               
     WHERE dat_referencia = p_dat_referencia                                                                      
       AND num_cpf   = p_numero_cpf  
       AND cod_banco = p_cod_banco                                                                  
   
   FOREACH cq_empmat INTO m_cod_empresa, m_num_matricula
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','arq_banco_265:matricula')
         RETURN FALSE
      END IF 
      
      EXIT FOREACH
   END FOREACH
   
   IF m_cod_empresa IS NULL THEN
      LET m_cod_empresa = ' '
      LET m_num_matricula = 0
   END IF                       

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1071_le_empresa()
#-----------------------------#

   DECLARE cq_empresa CURSOR FOR
    SELECT cod_empresa,
           num_matricula                                                                       
      FROM arq_banco_265                                                                               
     WHERE num_cpf   = p_numero_cpf                                                                    
       AND dat_referencia = p_dat_referencia                                                           
   
   FOREACH cq_empresa INTO m_cod_empresa, m_num_matricula
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','arq_banco_265:matricula')
         RETURN FALSE
      END IF 
      
      EXIT FOREACH
   END FOREACH
   
   IF m_cod_empresa IS NULL THEN
      LET m_cod_empresa = ' '
      LET m_num_matricula = 0
   END IF                       

   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1071_atu_status()
#----------------------------#

   UPDATE arq_banco_265
      SET cod_status = p_cod_status
    WHERE id_registro = p_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','arq_banco_265')
      RETURN FALSE
   END IF
                  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1071_atu_tabs_origens()
#---------------------------------#

   UPDATE arq_banco_265
      SET cod_status = p_cod_status
    WHERE num_cpf        = p_numero_cpf 
      AND dat_referencia = p_dat_referencia    
      AND uf             = p_estado
      AND cod_empresa    = m_cod_empresa
      AND num_matricula  = m_num_matricula
      AND cod_banco      = p_cod_banco
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','arq_banco_265')
      RETURN FALSE
   END IF

   UPDATE hist_movto_265
      SET cod_status = p_cod_status
    WHERE num_cpf        = p_numero_cpf 
      AND dat_referencia = p_dat_referencia    
      AND uf             = p_estado
      AND cod_empresa    = m_cod_empresa
      AND num_matricula  = m_num_matricula
      AND cod_banco      = p_cod_banco
      AND tip_evento     = '1'
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','hist_movto_265')
      RETURN FALSE
   END IF
                  
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1071_checa_diverg()
#------------------------------#
  
   LET p_obs = NULL                                                                                 
   LET p_dat_demis = ''
   LET p_dat_afasta = ''
   LET p_val_30 = 0
   LET p_mensagem = 'Valores diferentes'
   
   {IF p_val_evento > p_val_parcela THEN
      LET p_val_dif = p_val_evento - p_val_parcela
      IF NOT pol1071_checa_acerto() THEN
         RETURN FALSE
      END IF
      IF p_val_dif = p_val_acerto THEN
         LET p_val_evento = p_val_parcela
      END IF
   END IF}
   
   IF p_val_evento > p_val_parcela THEN
      LET p_val_dif = p_val_evento - p_val_parcela
   ELSE
      LET p_val_dif = p_val_parcela - p_val_evento        
   END IF
   
   LET p_val_txt = p_val_dif

   IF NOT pol1071_ve_afastado() THEN
      RETURN FALSE
   END IF

   IF p_obs IS NOT NULL THEN
      LET p_tip_diverg = 'B'
      RETURN TRUE
   END IF

   IF NOT pol1071_ve_demitido() THEN
      RETURN FALSE
   END IF

   IF p_obs IS NOT NULL THEN
      LET p_mensagem = 'Demitido'
      LET p_tip_diverg = 'B'
      RETURN TRUE
   END IF
   
   IF p_val_evento = 0 THEN            
      LET p_tip_diverg = 'B'                                                 
      LET p_obs = 'Ver porque nao descontou na Folha'               
      RETURN TRUE                                                                           
   END IF                                                                                   

   IF p_val_evento < p_val_parcela THEN
      LET p_obs = 'Verificar se nao existe novo Contrato. ',
                  'Verificar se nao houve Renegociacao. ',
                  'Verificar se nao acabou algum Contrato.'
      RETURN TRUE
   END IF
   
   IF p_val_evento > p_val_parcela THEN
      LET p_obs = 'Ver se vai Reembolsar R$ ', p_val_txt CLIPPED, ' ',         
                  'Ver se foi prorrogado o prazo de Termino. ',
                  'Ver se e desconto de meses anteriores. '  
      RETURN TRUE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1071_checa_acerto()
#-----------------------------#

   LET p_val_acerto = 0
   
   SELECT val_acerto                        
     INTO p_val_acerto                         
     FROM diverg_consig_265                    
    WHERE num_cpf       = p_numero_cpf         
      AND cod_banco     = p_cod_banco          
      AND num_matricula = m_num_matricula      
      AND cod_empresa   = m_cod_empresa        
      AND dat_acerto_prev = p_dat_referencia   
      AND tip_acerto      = 1                  

   IF STATUS = 100  THEN                                         
      LET p_val_acerto = 0
   ELSE
      IF STATUS <> 0 THEN                                         
         CALL log003_err_sql('Lendo','diverg_consig_265:val_acerto')          
         RETURN FALSE                                               
      END IF
   END IF               
   
   IF p_val_acerto IS NULL THEN
      LET p_val_acerto = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION                                         

#-----------------------------#
FUNCTION pol1071_ve_afastado()
#-----------------------------#

   DEFINE p_dat_ini DATE,
          p_dat_fim DATE

   DECLARE cq_afas CURSOR FOR          
   SELECT dat_ini_afasta                                         
     INTO p_data                                                    
     FROM ficha_afasta                                              
    WHERE cod_empresa   = m_cod_empresa                             
      AND num_matricula = m_num_matricula                           
      AND (TO_CHAR(dat_ini_afasta, 'YYYY-MM') = p_ano_mes_ref
           AND (TO_CHAR(dat_fim_afasta, 'YYYY-MM') >= p_ano_mes_ref))

	  FOREACH cq_afas INTO p_data
	                                                                  
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','cq_afas')                                                         
          RETURN FALSE                                                                                  
       END IF
         
      LET p_obs = 'INSS – Nao repassar a parcela.'                  
      LET p_dat_afasta = p_data                                     
      RETURN TRUE                                                   
         
    END FOREACH

   SELECT MAX(dat_ini_afasta)                                                                   
     INTO p_dat_ini                                                                               
     FROM ficha_afasta                                                                         
    WHERE cod_empresa   = m_cod_empresa                                                                         
      AND num_matricula = m_num_matricula  
      AND TO_CHAR(dat_ini_afasta, 'YYYY-MM') < p_ano_mes_ref

   IF STATUS <> 0 THEN                                         
      CALL log003_err_sql('Lendo','ficha_afasta:2')          
      RETURN FALSE                                               
   END IF                                                        
   
   IF p_dat_ini IS NULL THEN
      RETURN TRUE
   END IF

   SELECT dat_fim_afasta                                                                   
     INTO p_dat_fim                                                                               
     FROM ficha_afasta                                                                         
    WHERE cod_empresa    = m_cod_empresa                                                                         
      AND num_matricula  = m_num_matricula 
      AND dat_ini_afasta = p_dat_ini

   IF STATUS <> 0 THEN                                         
      CALL log003_err_sql('Lendo','ficha_afasta:3')          
      RETURN FALSE                                               
   END IF                                                        

                                                                                                                
   IF p_dat_fim IS NULL OR EXTEND(p_dat_fim, YEAR TO MONTH) > p_ano_mes_ref THEN
      LET p_obs = 'INSS – Continuou repassando a parcela para o BANCO. ',                                       
                  'Aumentar 1 mes a mais a cada parcela repassada depois do Afastamento.'                       
      LET p_dat_afasta = p_dat_ini                                                                
   END IF                                                                                     

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1071_ve_demitido()
#----------------------------#
   
   SELECT dat_demis 
     INTO p_data
     FROM funcionario
    WHERE cod_empresa   = m_cod_empresa
      AND num_matricula = m_num_matricula

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','funcionario')
      RETURN FALSE
   END IF
   
   IF p_data IS NOT NULL THEN
   
      LET p_dat_demis = p_data
      LET p_ano_mes_demis = EXTEND(p_data, YEAR TO MONTH)
      IF p_ano_mes_demis < p_ano_mes_ref THEN
         LET p_obs = 
               'Demissao em mes anterior ao de referencia, banco enviou repasse indevido ',                                   
               'Verificar se houve já houve o repasse dos 30% para o Banco. '   
            SELECT SUM(val_evento)                             
              INTO p_val_30                                    
              FROM movto_demitidos                             
             WHERE cod_empresa   = m_cod_empresa                 
               AND num_matricula = m_num_matricula     
               AND TO_CHAR(dat_referencia, 'YYYY-MM') = p_ano_mes_demis
               AND cod_evento IN                               
                   (SELECT cod_evento                          
                      FROM evento_265                          
                     WHERE estado = p_estado                   
                       AND tip_evento = '2')                   
   
            IF STATUS = 100 THEN
               RETURN TRUE
            ELSE
               IF STATUS <> 0 THEN                                                                  
                  CALL log003_err_sql('Lendo','movto_demitidos:1')                                  
                  RETURN FALSE                                                                      
               END IF
            END IF                                                                               
                                                                                                 
            IF p_val_30 IS NULL THEN  
               LET p_val_30 = 0
            END IF
            CALL pol1071_atu_contr()       
      ELSE
         IF p_ano_mes_demis = p_ano_mes_ref THEN
           
            SELECT SUM(val_evento)                             
              INTO p_val_30                                    
              FROM movto_demitidos                             
             WHERE cod_empresa   = m_cod_empresa                 
               AND num_matricula = m_num_matricula     
               AND TO_CHAR(dat_referencia, 'YYYY-MM') = p_ano_mes_ref
               AND cod_evento IN                               
                   (SELECT cod_evento                          
                      FROM evento_265                          
                     WHERE estado = p_estado                   
                       AND tip_evento = '2')                   
   
            IF STATUS = 100 THEN
               RETURN TRUE
            ELSE
               IF STATUS <> 0 THEN                                                                  
                  CALL log003_err_sql('Lendo','movto_demitidos:1')                                  
                  RETURN FALSE                                                                      
               END IF
            END IF                                                                               
                                                                                                 
            IF p_val_30 IS NULL THEN  
               LET p_val_30 = 0
            END IF

            LET p_obs = 'Demissao – Repassar os 30% da rescisao, nao repassar a parcela.'     
            CALL pol1071_atu_contr()                                                          
         END IF
      END IF                                                                               
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1071_proces_folha()
#------------------------------#

   CALL pol1071_inicia_variaveis()
   LET p_cod_status = 'D'      

   DECLARE cq_folha CURSOR WITH HOLD FOR 
    SELECT SUM(val_evento),                                                                             
           num_matricula,
           cod_empresa,
           num_cpf,
           uf,
           cod_banco                                                                     
      FROM hist_movto_265                                                                              
     WHERE dat_referencia = p_dat_referencia    
       AND cod_status     = 'P'
       AND tip_evento     = 1
     GROUP BY num_matricula, cod_empresa, num_cpf, uf, cod_banco
     ORDER BY num_cpf, cod_banco, num_matricula, cod_empresa
   
   FOREACH cq_folha INTO                                                                           
           p_val_dif,                                                                              
           m_num_matricula,
           m_cod_empresa,
           p_numero_cpf,
           p_estado,
           p_cod_banco                                                                        
              
      IF STATUS <> 0 THEN                                                                          
         CALL log003_err_sql('Lendo','hist_movto_265:cq_folha')                                        
         RETURN FALSE                                                                              
      END IF                                                                                       

      LET pr_men[1].mensagem = 'Processando 3... ', m_num_matricula 
      CALL pol1071_exib_mensagem()
      
      IF NOT pol1071_checa_acerto() THEN
         RETURN FALSE
      END IF
      
      LET p_val_dif = p_val_dif - p_val_acerto
      
      IF p_val_dif <= 0 THEN
         CONTINUE FOREACH
      END IF

      LET p_val_evento  = p_val_dif                                                              
      LET p_mensagem    = NULL                                                                   
      LET p_val_evento  = p_val_dif                                                              
      LET p_val_parcela = 0                                                                                                               
      LET p_mensagem    = 'Sem repasse p/ o Banco'                                               
      LET p_obs         = NULL
     
      IF NOT pol1071_ve_demitido() THEN
         RETURN FALSE
      END IF
      
      IF p_obs IS NULL THEN
      
         LET p_obs = 
              'Verificar se o funcionario voltou do Afastamento. ',                                                  
              'Verificar se o Emprestimo so vai começar no próximo Mes/Ano. ',                    
              'Verificar se não houve prorrogação de Contrato.'                                   
      END IF
      
      IF NOT pol1071_ins_diverg() THEN                                                                
         RETURN FALSE                                                                                 
      END IF                                                                                          

      IF NOT pol1071_update_hist_265() THEN                                                             
         RETURN FALSE                                                                              
      END IF                                                                                       

   END FOREACH  

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1071_update_hist_265()
#---------------------------------#

   UPDATE hist_movto_265                                     
      SET cod_status = p_cod_status                             
    WHERE cod_empresa   = m_cod_empresa                         
      AND num_matricula = m_num_matricula                       
      AND num_cpf       = p_numero_cpf                          
      AND uf            = p_estado                              
      AND cod_banco     = p_cod_banco                           
      AND tip_evento    = p_tip_evento                          
      AND dat_referencia = p_dat_referencia                     
                                                                                                          
   IF STATUS <> 0 THEN                                                                             
      CALL log003_err_sql('Update','hist_movto_265:cq_folha')                                           
      RETURN FALSE                                                                                 
   END IF       
   
   RETURN TRUE
   
END FUNCTION                                                                                                                                                                                                  

#--------------------------------#
FUNCTION pol1071_checa_demitido()
#--------------------------------#
   
   DEFINE p_cod_evento LIKE movto_demitidos.cod_evento,
          l_numero_cpf         CHAR(19)
   
   LET p_tip_diverg = 'B'
   
   DECLARE cq_demitidos CURSOR FOR
    SELECT cod_empresa,
           num_matricula, 
           cod_evento,                                      
           SUM(val_evento)
     FROM movto_demitidos                                                  
    WHERE TO_CHAR(dat_referencia, 'YYYY-MM') = p_ano_mes_ref 
      AND cod_evento IN (SELECT DISTINCT cod_evento FROM evento_265 WHERE tip_evento = '2')                   
    GROUP BY cod_empresa, num_matricula, cod_evento

   FOREACH cq_demitidos INTO 
           m_cod_empresa,
           m_num_matricula,
           p_cod_evento,                                                        
           p_val_30
   
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','movto_demitidos:cq_demitidos')
          RETURN FALSE
       END IF

        SELECT uni_feder
          INTO p_estado
          FROM empresa
         WHERE cod_empresa = m_cod_empresa

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','empresa:cq_demitidos')
          RETURN FALSE
       END IF

       IF p_estado <> 'RJ' THEN
          LET p_estado = 'BR'
       END IF
       
       SELECT COUNT(cod_evento)
         INTO p_count
         FROM evento_265 
        WHERE cod_evento = p_cod_evento
          AND estado     = p_estado 
          AND tip_evento = '1'
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','evento_265:cq_demitidos')
          RETURN FALSE
       END IF
       
       IF p_count = 0 THEN
          CONTINUE FOREACH
       END IF

      SELECT dat_demis 
        INTO p_data
        FROM funcionario
       WHERE cod_empresa   = m_cod_empresa
         AND num_matricula = m_num_matricula

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'contr_consig_265:cq_demitidos')
         RETURN FALSE
      END IF
      
      SELECT DISTINCT num_cpf
        INTO l_numero_cpf
        FROM fun_infor
       WHERE cod_empresa   = m_cod_empresa
         AND num_matricula = m_num_matricula
      
      IF STATUS <> 0 THEN                                                                      
         CALL log003_err_sql('Lendo','fun_infor:cq_contrato')                                      
         RETURN FALSE                                                                          
      END IF  
      
      IF p_data IS NULL OR p_data = '' THEN
         CONTINUE FOREACH
      END IF

      LET p_dat_demis  = p_data

      DECLARE cq_contrato CURSOR FOR
       SELECT cod_banco,
              num_cpf
         FROM contr_consig_265
        WHERE num_cpf = l_numero_cpf         
          AND dat_liquidacao IS NULL
     
      FOREACH cq_contrato INTO 
              p_cod_banco,
              p_numero_cpf

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'contr_consig_265:cq_contrato')
            RETURN FALSE
         END IF

         SELECT COUNT(mensagem)
           INTO p_count
           FROM diverg_consig_265
          WHERE cod_empresa = m_cod_empresa
            AND num_cpf     = l_numero_cpf
            AND cod_banco   = p_cod_banco
            AND mensagem    = 'Demitido'
            AND dat_referencia = p_dat_referencia
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','diverg_consig_265:cq_demitidos')
            RETURN FALSE
         END IF
      
         IF p_count > 0 THEN
            CONTINUE FOREACH
         END IF
      
         CALL pol1071_atu_contr()                                                          

         LET p_val_evento  = p_val_30
         LET p_val_parcela = 0
         LET p_dat_afasta = ''
         LET p_mensagem = 'Demitido'

         LET p_obs = 'Demissao – Repassar os 30% da rescisao, nao repassar a parcela.'     

         IF NOT pol1071_ins_diverg() THEN                                                                
            RETURN FALSE                                                                                 
         END IF

      END FOREACH
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1071_proces_rembolso()
#---------------------------------#

   LET p_tip_diverg = 'F'
   
   CALL pol1071_inicia_variaveis()

   LET p_mensagem = 'Reembolso nao previsto'
   LET p_val_parcela = 0
   LET p_cod_status = 'D'      

   DECLARE cq_reemb CURSOR WITH HOLD FOR                                                           
    SELECT SUM(val_evento),                                                                             
           num_matricula,
           cod_empresa,
           num_cpf,
           uf,
           cod_banco                                                                     
      FROM hist_movto_265                                                                              
     WHERE dat_referencia = p_dat_referencia    
       AND cod_status     = 'P'
       AND tip_evento     = 4
     GROUP BY num_matricula, cod_empresa, num_cpf, uf, cod_banco
     ORDER BY num_cpf, cod_banco, num_matricula, cod_empresa
   
   FOREACH cq_reemb INTO                                                                           
           p_val_dif,                                                                              
           m_num_matricula,
           m_cod_empresa,
           p_numero_cpf,
           p_estado,
           p_cod_banco                                                                        
              
      IF STATUS <> 0 THEN                                                                          
         CALL log003_err_sql('Lendo','hist_movto_265:cq_folha')                                        
         RETURN FALSE                                                                              
      END IF                                                                                       
      
      LET p_tip_acerto = 5
      LET p_obs = NULL
      
      SELECT id_registro
        INTO p_id_registro
        FROM diverg_consig_265
       WHERE num_cpf       = p_numero_cpf
         AND cod_banco     = p_cod_banco
         AND num_matricula = m_num_matricula
         AND cod_empresa   = m_cod_empresa
         AND dat_acerto_prev = p_dat_referencia
         AND val_acerto      = p_val_dif
         AND tip_acerto      = 2
      
      IF STATUS = 0 THEN                                                                          
         LET p_tip_acerto = 2
         LET p_obs = 'Reembolsado R$ ', p_val_dif USING '<<<<<<.<<'
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','hist_movto_265:cq_folha')                                        
            RETURN FALSE                                                                              
         END IF
      END IF                                                                                       

      LET p_val_evento = p_val_dif

      LET pr_men[1].mensagem = 'Processando 4... ', m_num_matricula 
      CALL pol1071_exib_mensagem()
         
      IF p_obs IS NULL THEN                                                                                                                                                                                                                    
         LET p_obs = 'Ver se reembolso refere-se a descontos anteriores indevidos. ',                 
                     'Ver se nao foi reembolso previsto por conciliacoes anteriores.'                 
      END IF
                                                                                                      
      IF NOT pol1071_ins_diverg() THEN                                                             
         RETURN FALSE                                                                              
      END IF                                                                                       

      IF NOT pol1071_update_hist_265() THEN                                                             
         RETURN FALSE                                                                              
      END IF                                                                                       
                                                                                                      
   END FOREACH                                                                                   
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1071_atu_status_hist()
#---------------------------------#

   UPDATE hist_movto_265
      SET cod_status = p_cod_status
    WHERE id_registro = p_id_reg_hist
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','hist_movto_265')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1071_inicia_variaveis()
#---------------------------------#

   LET p_val_parcela  = 0
   LET p_val_evento = 0
   LET p_val_30     = 0
   LET p_val_dif    = 0
   LET p_dat_demis  = ''
   LET p_dat_afasta = ''
   LET p_estado     = ''

END FUNCTION

#-----------------------------#
FUNCTION pol1071_multi_banco()
#-----------------------------#
   DEFINE  l_num_cpf        CHAR (19),
           l_num_cpf_ant    CHAR (19),
		   l_cod_banco_ant  DECIMAL(3,0),
		   l_count          Integer
   
   CALL pol1071_inicia_variaveis()
   
   LET p_tip_diverg = 'B'
   LET l_count = 0 
   
   LET p_mensagem = NULL
   
   LET l_cod_banco_ant =  0 
   INITIALIZE l_num_cpf, l_num_cpf_ant    TO NULL
   
   IF NOT pol1071_cria_temp_cpf_banco() THEN
      RETURN FALSE
   END IF
  
   INSERT INTO  cpf_banco_temp_265 
   SELECT DISTINCT num_cpf,  count(*) contador
      FROM arq_banco_265
     WHERE num_matricula  > 0
       AND dat_referencia = p_dat_referencia
       GROUP BY  num_cpf
       HAVING count(*)>1
  
	DECLARE cq_multi CURSOR FOR
		SELECT DISTINCT
                num_cpf,
                cod_banco,
                cod_empresa,
                num_matricula
             FROM arq_banco_265
          WHERE dat_referencia = p_dat_referencia
            AND num_cpf IN (SELECT num_cpf FROM cpf_banco_temp_265 )
          ORDER BY num_cpf, cod_banco

         FOREACH cq_multi INTO l_num_cpf, p_cod_banco, m_cod_empresa, m_num_matricula
      
	        IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','arq_banco_265:cq_multi')
               RETURN FALSE
            END IF 
			
			
			LET pr_men[1].mensagem = 'Processando 5... ', p_numero_cpf 
			CALL pol1071_exib_mensagem()
	  
	        IF  (l_num_cpf     = l_num_cpf_ant)   
			        AND (p_cod_banco  <> l_cod_banco_ant ) THEN 			
			        LET l_count = l_count + 1
				      LET p_val_parcela = 0
				      LET p_obs = 'Funcionario com emprestimos em ',l_count USING "&&", ' bancos'
				
				IF NOT pol1071_ins_diverg() THEN
					RETURN FALSE
				END IF
			ELSE 
			    LET l_count		        = 1
			    LET l_num_cpf_ant 		= l_num_cpf
				LET l_cod_banco_ant   	= p_cod_banco
            END IF	
         END FOREACH 
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1071_cria_temp_cpf_banco()
#--------------------------------------#

   DROP TABLE cpf_banco_temp_265
   
   CREATE temp TABLE cpf_banco_temp_265(
			num_cpf         CHAR (19),
			contador        integer)

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","cpf_banco_temp_265:criando")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION


#---FIM DO PROGRAMA---#

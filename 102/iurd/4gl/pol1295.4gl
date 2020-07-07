#-------------------------------------------------------------------#
# OBJETIVO: USUÁRIOS PARA EXCLUSãO DE BAIXAS PENDENTES              #
# DATA....: 10/04/2015                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_msg                CHAR(500),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80)
                       
END GLOBALS

DEFINE p_tela               RECORD
       mes_ref              CHAR(02),
       ano_ref              CHAR(04)
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
       p_data               DATE,
       p_dat_referencia     DATE,
       p_dat_char           CHAR(10),
       p_mes_ref            INTEGER,
       p_ano_ref            INTEGER,
       p_ano_mes_ref        CHAR(07),
       m_num_matricula      INTEGER,
       m_cod_empresa        CHAR(02),
       p_numero_cpf         CHAR(19),
       p_nome_arq_csv       CHAR(16),
       p_dat_ult_proces     DATE

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1295-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1295" ) RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

	CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
	
	IF p_status = 0 THEN
 		CALL pol1295_controle()
	END IF
	
END MAIN

#--------------------------#
 FUNCTION pol1295_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1295") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1295 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1295_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso !'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Processar'
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Processar" "Processa a geração do arquivo CSV"
         IF p_ies_cons THEN
            CALL pol1295_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação concuida'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF 
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Informe os parâmentors previamente!'
            NEXT OPTION 'Informar'
         END IF         
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior."
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1295

END FUNCTION

#--------------------------#
FUNCTION pol1295_informar()
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

#--------------------------#
FUNCTION pol1295_processar()
#--------------------------#

   SELECT nom_caminho
     INTO p_caminho
    FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "CSV"

   IF STATUS = 100 THEN
      LET p_msg = 'Caminho não cadastrado na\n LOG1100 para o sistema CSV.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN                                                                            
         CALL log003_err_sql('Lendo','path_logix_v2')                                                    
         RETURN FALSE                                                                                
      END IF
   END IF                                                                                         
   
   LET p_nom_arquivo = p_caminho, p_nome_arq_csv
   
   START REPORT pol1295_relat TO p_nom_arquivo
   
   LET p_count = 0
   
   DECLARE cq_gera CURSOR WITH HOLD FOR                                                         
    SELECT id_registro,    
           cod_empresa,  
           num_cpf,                                                                                  
           num_matricula                                                                        
      FROM arq_banco_265                                                                             
     WHERE dat_referencia = p_dat_referencia  
     ORDER BY num_cpf
                                                                                                     
   FOREACH cq_gera INTO                                                                            
           p_id_registro,  
           m_cod_empresa,                                                                          
           p_numero_cpf,   
           m_num_matricula                                                                          
                                                                                                     
      IF STATUS <> 0 THEN                                                                            
         CALL log003_err_sql('Lendo','cq_gera')                                                    
         EXIT FOREACH                                                                                
      END IF                                                                                         
      
      CALL pol1295_le_ult_proces()
      
      OUTPUT TO REPORT pol1295_relat()
      
      LET p_count = p_count + 1
      
   END FOREACH   

   FINISH REPORT pol1295_relat
   
   IF p_count > 0 THEN
      LET p_msg = 'Arquivo gerado no caminho ',p_nom_arquivo
   ELSE
      LET p_msg = 'Não há dados, para os parâmetros informados.'
   END IF
   
   CALL log0030_mensagem(p_msg,'info')
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1295_le_ult_proces()
#-------------------------------#

   SELECT MAX(dat_referencia)
     INTO p_dat_ult_proces
     FROM hist_movto
    WHERE cod_empresa = m_cod_empresa
      AND num_matricula = m_num_matricula

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','hist_movto')
      LET p_dat_ult_proces = NULL
   END IF

END FUNCTION

#---------------------#
REPORT pol1295_relat()#
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
   FORMAT
   
      ON EVERY ROW
         PRINT m_cod_empresa,     '|',
               p_numero_cpf,      '|',
               m_num_matricula,   '|',
               p_dat_ult_proces,  '|'
               
END REPORT         
   
   
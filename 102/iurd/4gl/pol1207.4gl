#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1207                                                 #
# OBJETIVO: UNIDADE FUNCIONAL ADMINISTRATIVA                        #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 10/07/2013                                              #
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
          p_erro               CHAR(10)

END GLOBALS

DEFINE p_cod_uni_funcio       CHAR(10),
       p_den_uni_funcio       CHAR(30)

DEFINE pr_item ARRAY[30] OF RECORD
       cod_uni_feder     CHAR(02),
       estado            CHAR(25),
       cod_uni_funcio    CHAR(10),
       den_uni_funcio    CHAR(30)
END RECORD       

DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1207-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1207'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1207_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1207_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1207") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1207 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1207_cria_tabela() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_opcao = 'I'
         CALL pol1207_processa() RETURNING p_ies_cons
         IF p_ies_cons THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1207_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         LET p_opcao = 'M'
         CALL pol1207_processa() RETURNING p_ies_cons
         IF p_ies_cons THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1207_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         LET p_opcao = 'C'
         CALL pol1207_processa() RETURNING p_ies_cons
         IF p_ies_cons THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1207_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1207_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1207

END FUNCTION

#------------------------#
 FUNCTION pol1207_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1207_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------------#
FUNCTION pol1207_cria_tabela()#
#-----------------------------#

   LET p_msg = 'estados_265'

   IF NOT log0150_verifica_se_tabela_existe(p_msg) THEN
      create table estados_265 (
         sigla      char(02) not null,
         estado     char(30) not null
      );

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' criando\n',
                      'tabela estados_265.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF

      create unique index estados_265
         on estados_265(sigla);
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' criando indice\n',
                      'para a tabela estados_265.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
      
      CALL pol1127_ins_estado()
   END IF      

   LET p_msg = 'uni_funcio_adm_265'

   IF NOT log0150_verifica_se_tabela_existe(p_msg) THEN
      
      LET p_msg = 'Tabela uni_funcio_adm_265 não\n',
                  'não existe. Favor criá-la.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   SELECT COUNT(cod_uni_feder)
     INTO p_count
     FROM uni_funcio_adm_265
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','uni_funcio_adm_265')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      CALL pol1207_ins_uni() 
   END IF
   
   RETURN TRUE

END FUNCTION
#----------------------------#
FUNCTION pol1127_ins_estado()#
#----------------------------#

   INSERT INTO estados_265 values('GO','Goiás              ')
   INSERT INTO estados_265 values('MT','Mato Grosso        ')
   INSERT INTO estados_265 values('MS','Mato Grosso do Sul ')
   INSERT INTO estados_265 values('DF','Distrito Federal   ')
   INSERT INTO estados_265 values('AM','Amazonas           ')
   INSERT INTO estados_265 values('AC','Acre               ')
   INSERT INTO estados_265 values('RO','Rondônia           ')
   INSERT INTO estados_265 values('RR','Roraima            ')
   INSERT INTO estados_265 values('AP','Amapá              ')
   INSERT INTO estados_265 values('TO','Tocantins          ')
   INSERT INTO estados_265 values('PA','Para               ')
   INSERT INTO estados_265 values('MA','Maranhão           ')
   INSERT INTO estados_265 values('PI','Piaui              ')
   INSERT INTO estados_265 values('CE','Ceara              ')
   INSERT INTO estados_265 values('RN','Rio Grande do Norte')
   INSERT INTO estados_265 values('PB','Paraiba            ')
   INSERT INTO estados_265 values('PE','Pernambuco         ')
   INSERT INTO estados_265 values('SE','Sergipe            ')
   INSERT INTO estados_265 values('AL','Alagoas            ')
   INSERT INTO estados_265 values('BA','Bahia              ')
   INSERT INTO estados_265 values('SP','São Paulo          ')
   INSERT INTO estados_265 values('MG','Minas Gerais       ')
   INSERT INTO estados_265 values('RJ','Rio de Janeiro     ')
   INSERT INTO estados_265 values('ES','Espirito Santo     ')
   INSERT INTO estados_265 values('PR','Parana             ')
   INSERT INTO estados_265 values('SC','Santa Catarina     ')
   INSERT INTO estados_265 values('RS','Rio Grande do Sul  ')

END FUNCTION

#-------------------------#
FUNCTION pol1207_ins_uni()#
#-------------------------#

   INSERT INTO uni_funcio_adm_265 VALUES('AC','1000101001')
   INSERT INTO uni_funcio_adm_265 VALUES('AL','1000201001')
   INSERT INTO uni_funcio_adm_265 VALUES('AP','1000301001')
   INSERT INTO uni_funcio_adm_265 VALUES('AM','1000401010')
   INSERT INTO uni_funcio_adm_265 VALUES('BA','1000501001')
   INSERT INTO uni_funcio_adm_265 VALUES('DF','1000601000')
   INSERT INTO uni_funcio_adm_265 VALUES('CE','1000701001')
   INSERT INTO uni_funcio_adm_265 VALUES('ES','1000801000')
   INSERT INTO uni_funcio_adm_265 VALUES('GO','1000901001')
   INSERT INTO uni_funcio_adm_265 VALUES('MA','1001001001')
   INSERT INTO uni_funcio_adm_265 VALUES('MT','1001101001')
   INSERT INTO uni_funcio_adm_265 VALUES('MS','1001201000')
   INSERT INTO uni_funcio_adm_265 VALUES('MG','1001301001')
   INSERT INTO uni_funcio_adm_265 VALUES('PA','1001401000')
   INSERT INTO uni_funcio_adm_265 VALUES('PB','1001501001')
   INSERT INTO uni_funcio_adm_265 VALUES('PR','1001601000')
   INSERT INTO uni_funcio_adm_265 VALUES('PE','1001701001')
   INSERT INTO uni_funcio_adm_265 VALUES('PI','1001801001')
   INSERT INTO uni_funcio_adm_265 VALUES('RN','1002001001')
   INSERT INTO uni_funcio_adm_265 VALUES('RS','1002101000')
   INSERT INTO uni_funcio_adm_265 VALUES('RO','1002201001')
   INSERT INTO uni_funcio_adm_265 VALUES('RR','1002301001')
   INSERT INTO uni_funcio_adm_265 VALUES('SC','1002401000')
   INSERT INTO uni_funcio_adm_265 VALUES('SE','1002601001')
   INSERT INTO uni_funcio_adm_265 VALUES('TO','1002701001')

END FUNCTION

#--------------------------#
FUNCTION pol1207_processa()#
#--------------------------#

   IF NOT p_ies_cons THEN
      IF NOT pol1207_carregar() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_opcao = 'C' THEN
      CALL SET_COUNT(p_ind - 1)
      DISPLAY ARRAY pr_item TO sr_item.*
      RETURN TRUE
   END IF
   
   IF NOT pol1207_modificar() THEN
      RETURN FALSE
   END IF

   IF NOT pol1207_gravar() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1207_carregar()#
#--------------------------#

   LET p_ind = 1
   
   DECLARE cq_carrega CURSOR FOR
    SELECT cod_uni_feder,
           cod_uni_funcio
      FROM uni_funcio_adm_265
   
   FOREACH cq_carrega INTO     
           pr_item[p_ind].cod_uni_feder,
           pr_item[p_ind].cod_uni_funcio
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_carrega')
         RETURN FALSE
      END IF          

      LET p_cod_uni_funcio = pr_item[p_ind].cod_uni_funcio
      LET pr_item[p_ind].den_uni_funcio = pol1207_le_uni_funcio()
            
      SELECT estado
        INTO pr_item[p_ind].estado
        FROM estados_265
       WHERE sigla = pr_item[p_ind].cod_uni_feder
      
      IF STATUS <> 0 THEN
         LET pr_item[p_ind].estado = ''
      END IF          

      LET p_ind = p_ind + 1
   
   END FOREACH

END FUNCTION

#-------------------------------#
FUNCTION pol1207_le_uni_funcio()#
#-------------------------------#

   LET p_den_uni_funcio = ''
   
   DECLARE cq_uni CURSOR FOR
    SELECT den_uni_funcio
      FROM uni_funcional
     WHERE cod_uni_funcio = p_cod_uni_funcio
   
   FOREACH cq_uni INTO p_den_uni_funcio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_uni')
      END IF          
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN p_den_uni_funcio

END FUNCTION
   
#---------------------------#
FUNCTION pol1207_modificar()#
#---------------------------#

   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
         ATTRIBUTES(INSERT ROW = TRUE, DELETE ROW = TRUE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         IF pr_item[p_ind].cod_uni_feder IS NULL THEN
            NEXT FIELD cod_uni_feder   
         ELSE
            IF pr_item[p_ind].cod_uni_funcio IS NULL THEN
               NEXT FIELD cod_uni_funcio   
            END IF
         END IF
            
      AFTER FIELD cod_uni_feder
       
         IF pr_item[p_ind].cod_uni_feder IS NOT NULL THEN

            FOR p_index = 1 TO ARR_COUNT()                                                                        
                IF p_index <> p_ind THEN                                                                            
                   IF pr_item[p_index].cod_uni_feder = pr_item[p_ind].cod_uni_feder THEN    
                      ERROR "Estado já informado !!!"                                               
                      NEXT FIELD cod_uni_feder   
                   END IF                                                                                           
                END IF                                                                                              
            END FOR                                                                                                
         
            SELECT estado 
              INTO pr_item[p_ind].estado
              FROM estados_265 
             WHERE sigla = pr_item[p_ind].cod_uni_feder
            IF STATUS = 0 THEN
               DISPLAY pr_item[p_ind].estado TO sr_item[s_ind].estado
            END IF
            
         END IF
         
      AFTER FIELD cod_uni_funcio
       
         IF pr_item[p_ind].cod_uni_funcio IS NOT NULL THEN
            LET p_cod_uni_funcio = pr_item[p_ind].cod_uni_funcio
            LET pr_item[p_ind].den_uni_funcio = pol1207_le_uni_funcio()
      
            IF pr_item[p_ind].den_uni_funcio IS NULL OR
               pr_item[p_ind].den_uni_funcio = '' THEN
               CALL log0030_mensagem('Unidade funcional enexistente','excla')
               NEXT FIELD cod_uni_funcio
            ELSE
               DISPLAY pr_item[p_ind].den_uni_funcio TO sr_item[s_ind].den_uni_funcio
            END IF
         ELSE
            IF pr_item[p_ind].cod_uni_feder IS NOT NULL THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD cod_uni_funcio
            END IF
         END IF
      
      
      AFTER INPUT
         IF NOT INT_FLAG THEN

         END IF

      ON KEY (control-z)
         CALL pol1207_popup()

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#-----------------------#
 FUNCTION pol1207_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_uni_funcio)
         CALL log009_popup(8,25,"UNIDADE FUNCIONAL","uni_funcional",
                     "cod_uni_funcio","den_uni_funcio","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1207
         IF p_codigo IS NOT NULL THEN
            LET pr_item[p_ind].cod_uni_funcio = p_codigo 
            DISPLAY p_codigo TO sr_item[s_ind].cod_uni_funcio
         END IF
   END CASE 

END FUNCTION 

#-------------------------#
 FUNCTION pol1207_gravar()#
#-------------------------#

   DROP TABLE uni_temp_265
   
   CREATE TEMP TABLE uni_temp_265(
      cod_uni_feder        CHAR(02),
	    cod_uni_funcio       CHAR(10)
   )
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","UNI_TEMP_265")
			RETURN FALSE
	 END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_item[p_ind].cod_uni_feder IS NOT NULL THEN
          INSERT INTO uni_temp_265 
           VALUES(pr_item[p_ind].cod_uni_feder, pr_item[p_ind].cod_uni_funcio)

          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERT", "uni_temp_265")
             RETURN FALSE
          END IF 
       END IF 
   END FOR
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1207_ins_audit() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   DELETE FROM uni_funcio_adm_265
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "uni_funcio_adm_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_item[p_ind].cod_uni_feder IS NOT NULL THEN
          
		       INSERT INTO uni_funcio_adm_265
		       VALUES (pr_item[p_ind].cod_uni_feder,
		               pr_item[p_ind].cod_uni_funcio)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "uni_funcio_adm_265")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol1207_ins_audit()#
#---------------------------#

   DEFINE p_cod_uni_feder  CHAR(02),
          p_cod_uni_funcio CHAR(10)
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_item[p_ind].cod_uni_feder IS NOT NULL THEN
          SELECT cod_uni_funcio
            FROM uni_funcio_adm_265
           WHERE cod_uni_feder  = pr_item[p_ind].cod_uni_feder
             AND cod_uni_funcio = pr_item[p_ind].cod_uni_funcio
          IF STATUS = 100 THEN
             LET parametro.texto = 'INCLUSAO DA UNIDADE FUNCIONAL ', 
                 pr_item[p_ind].cod_uni_funcio CLIPPED, ' P/ O ESTADO ', pr_item[p_ind].cod_uni_feder 
             IF NOT pol1161_grava_auadit(parametro) THEN
                RETURN FALSE
             END IF
          END IF
       END IF
   END FOR

   DECLARE cq_del CURSOR FOR
    SELECT cod_uni_feder,
           cod_uni_funcio
      FROM uni_funcio_adm_265
     WHERE cod_uni_feder NOT IN 
            (SELECT cod_uni_feder FROM uni_temp_265)
   
   FOREACH cq_del INTO p_cod_uni_feder, p_cod_uni_funcio
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_DEL')
         RETURN FALSE
      END IF
      
      LET parametro.texto = 'EXCLUSAO DE UNIDADE FUNCIONAL ', 
            p_cod_uni_funcio CLIPPED, ' DO ESTADO ', p_cod_uni_feder 
      IF NOT pol1161_grava_auadit(parametro) THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   


#--------------FIM DO PROGRAMA--------------#
{
      
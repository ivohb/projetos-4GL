#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1179                                                 #
# OBJETIVO: IMPORTAÇÃO DE FUNCIONÁRIO DA FOLHA RM                   #
# AUTOR...: IVO BJB                                                 #
# DATA....: 21/1/2012                                               #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE 
      p_cod_empresa        LIKE empresa.cod_empresa,
      p_den_empresa        LIKE empresa.den_empresa,
      p_user               LIKE usuario.nom_usuario,
      p_status             SMALLINT,
      comando              CHAR(80),
      p_ies_impressao      CHAR(01),
      g_ies_ambiente       CHAR(01),
      p_versao             CHAR(18),
      p_nom_arquivo        CHAR(100),
      p_caminho            CHAR(080),
      p_last_row           SMALLINT

END GLOBALS


DEFINE p_num_seq            SMALLINT,                
       p_rowid              INTEGER,                   
       p_index              SMALLINT,                  
       s_index              SMALLINT,                  
       p_ind                SMALLINT,                  
       s_ind                SMALLINT,                  
       p_count              SMALLINT,                  
       p_houve_erro         SMALLINT,                  
       p_nom_tela           CHAR(200),                 
       p_ies_cons           SMALLINT,                  
       p_msg                CHAR(500),                 
       p_texto              CHAR(10),                  
       p_opcao              CHAR(01),                   
       p_dat_ini_process    DATETIME YEAR TO DAY,
       p_hor_ini_process    DATETIME HOUR TO SECOND,
       p_hor_inclusao       CHAR(08),
       p_dat_inclusao       DATE,
       p_erro               CHAR(10),
       p_ies_processado     CHAR(01),
       p_dat_hor_process    DATETIME YEAR TO SECOND,
       p_dat_process        DATETIME YEAR TO DAY,
       p_cod_turno          INTEGER,
       p_cod_categoria      CHAR(01),
       p_cod_vinculo        INTEGER,
       p_ies_bate_ponto     CHAR(01),
       p_ies_forma_pagto    CHAR(01),
       p_ies_socio_gremio   CHAR(01),
       p_ativ_laboral       CHAR(01),
       p_ies_adto           CHAR(01),
       p_cod_cep            CHAR(09),
       p_chave_funcio       INTEGER,
       p_instancia          CHAR(30),
       sql_stmt             CHAR(2000)
       
DEFINE pr_erro              ARRAY[1000] OF RECORD  
       cod_empresa          CHAR(02),
       num_matricula        INTEGER,
       den_erro             CHAR(75)
END RECORD

DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE p_func        RECORD
  cod_empresa        char(02),
  num_matricula      decimal(8,0),
  nom_funcionario    char(30),
  cod_uni_funcio     char(10),
  cod_cargo          decimal(5,0),
  dat_admissao       DATETIME YEAR TO DAY,
  dat_demissao       DATETIME YEAR TO DAY,
  cod_turno          decimal(4,0),
  cod_escala         decimal(4,0),
  end_funcionario    char(30),
  end_complementar   char(20),
  cod_cep            char(09),
  nom_cidade         char(30),
  sigla_estado       char(02),
  nom_bairro         char(30),
  dat_nascimento     DATETIME YEAR TO DAY,
  num_cpf            char(14),
  ies_processado     char(01),
  dat_hor_proces     DATETIME YEAR TO SECOND,
  cod_usuario        char(08),
  id_registro        INTEGER
END RECORD
  
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1179-10.02.23"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   #CALL log001_acessa_usuario("ESPEC999","")
   #   RETURNING p_status, p_cod_empresa, p_user
   
   LET p_status = 0
   LET p_cod_empresa = '01'
   LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol1179_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1179_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'admlog'  #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1179_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1179_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1179") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1179 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET pr_men[1].mensagem = 'CHECANDO ÚLTIMO PROCESSAMENTO'
   CALL pol1179_exib_mensagem()

   #IF NOT pol1179_checa_proces() THEN
   #   LET p_houve_erro = TRUE
   #   RETURN
   #END IF
   
   LET p_dat_hor_process = CURRENT YEAR TO SECOND
   LET p_dat_process = CURRENT YEAR TO DAY
   
   IF NOT pol1179_processa() THEN
      LET p_houve_erro = TRUE
   ELSE
      LET p_houve_erro = FALSE
   END IF
   
   IF p_msg IS NULL THEN
      LET pr_men[1].mensagem = 'PROCESSAMENTO CONCLUIDO!'
   ELSE
      LET pr_men[1].mensagem = p_msg
   END IF
   
   CALL pol1179_exib_mensagem()
   SLEEP 3
   
END FUNCTION

#------------------------------#
FUNCTION pol1179_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#------------------------------#
FUNCTION pol1179_checa_proces()#
#------------------------------#

   DEFINE	p_hor_atu              DATETIME HOUR TO SECOND,
          p_hor_proces           CHAR(08),
          p_h_m_s                CHAR(10),
          p_qtd_segundo          INTEGER,
          p_data                 DATETIME YEAR TO DAY,
          p_hora                 DATETIME HOUR TO SECOND,
          p_processa             SMALLINT,
          p_encontrou            SMALLINT,
          p_hh                   INTEGER,
          p_mm                   INTEGER,
          p_ss                   INTEGER,
          p_hoje                 DATE

   LET p_processa = FALSE
   LET p_encontrou = FALSE
   LET p_hor_atu = CURRENT HOUR TO SECOND
   
   DECLARE cq_audit CURSOR FOR
    SELECT data,
           hora
      FROM audit_logix
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = 'pol1179'
     ORDER BY data desc, hora DESC

   FOREACH cq_audit INTO p_data, p_hora
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_audit')
         RETURN FALSE
      END IF

      LET p_encontrou = TRUE

  
      IF p_hora > p_hor_atu THEN
         LET p_h_m_s = '24:00:00' - (p_hora - p_hor_atu)
      ELSE
         LET p_h_m_s = (p_hor_atu - p_hora)
      END IF
   
      LET p_hor_proces = p_h_m_s[2,9]
   
      LET p_hh = p_hor_proces[1,2]
      LET p_mm = p_hor_proces[4,5]
      LET p_ss = p_hor_proces[7,8]
      
      LET p_qtd_segundo = (p_hh * 3600) + (p_mm * 60) + p_ss
         
      IF p_qtd_segundo > 60 THEN
         LET p_processa = TRUE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   IF p_encontrou THEN
      IF NOT p_processa THEN
         RETURN FALSE
      END IF
   END IF 

   LET p_msg = 'GERAÇÃO DA GRADE DE APROVACAO P/ NFE'
   
   LET p_hoje = TODAY
   LET p_hor_proces = p_hor_atu
   
   INSERT INTO audit_logix
    VALUES(p_cod_empresa,
           p_msg,
           'pol1179',
           p_hoje,
           p_hor_proces,
           p_user)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_logix')
      RETURN FALSE
   END IF
   
   LET p_dat_ini_process = p_hoje
   LET p_hor_ini_process = p_hor_proces
   LET p_dat_inclusao = p_hoje
   LET p_hor_inclusao = p_hor_proces
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1179_guarda_erro()#
#-----------------------------#

   LET p_ind = p_ind + 1
   LET pr_erro[p_ind].cod_empresa = p_func.cod_empresa
   LET pr_erro[p_ind].num_matricula = p_func.num_matricula
   LET pr_erro[p_ind].den_erro = p_msg

END FUNCTION   

#----------------------------#
FUNCTION pol1179_insere_erro()#
#----------------------------#
   
   LET p_ies_processado = 'C'
   LET p_num_seq = p_num_seq + 1
   
   INSERT INTO func_erro_5054
   VALUES(p_func.cod_empresa,
          p_func.num_matricula,
          p_num_seq,
          p_msg)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
                
#--------------------------#
FUNCTION pol1179_processa()#
#--------------------------#

   SELECT parametro_texto
     INTO p_instancia
     FROM min_par_modulo
    WHERE empresa = '01'
      AND parametro = 'INSTANCIA_RM'
   
   IF STATUS = 100 THEN
      LET p_instancia = ''
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF
   
   LET p_instancia = log9900_conversao_minusculo(p_instancia)
   
   LET sql_stmt =
   " SELECT * FROM ", p_instancia CLIPPED, "func_rm_5054 ",
   "  WHERE cod_empresa IS NOT NULL     ",
   "    AND num_matricula IS NOT NULL   ",
   "    AND ies_processado IN ('N','C') ",
   "  ORDER BY dat_hor_proces "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_proces CURSOR WITH HOLD FOR var_query
                      
   FOREACH cq_proces INTO p_func.*

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_PROCES'
         LET p_num_seq = 0
         LET p_func.cod_empresa = NULL
         LET p_func.num_matricula = NULL
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
      
      LET p_ies_processado = 'S'

      LET pr_men[1].mensagem = 'CONSISTINDO DADOS'
      CALL pol1179_exib_mensagem()

      IF NOT pol1179_consiste() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_processado = 'S' THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol1179_importa_func() THEN
            CALL log085_transacao("ROLLBACK")
            CALL pol1179_insere_erro()  RETURNING p_status
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
         END IF
      END IF

      LET pr_men[1].mensagem = 'ATUALUZANDO FUNC_RM_5054'
      CALL pol1179_exib_mensagem()

      LET sql_stmt = "UPDATE ", p_instancia CLIPPED,"func_rm_5054 ",
      " SET ies_processado = '",p_ies_processado,"',",
      "     cod_usuario = '",p_user,"' ",
      " WHERE id_registro = '",p_func.id_registro,"' "
  
      PREPARE var_upd FROM sql_stmt
      EXECUTE var_upd

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA FUNC_RM_5054'
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
     
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1179_consiste()#
#--------------------------#

   LET p_num_seq = 0
   
   DELETE FROM func_erro_5054
    WHERE cod_empresa = p_func.cod_empresa
      AND num_matricula = p_func.num_matricula

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' DELETANDO MATRICULA ', 
                  p_func.num_matricula, ' DA TAB FUNC_ERRO_5054'
      CALL pol1179_insere_erro()  RETURNING p_status
      RETURN FALSE
   END IF
   
   SELECT den_uni_funcio
     FROM uni_funcional
    WHERE cod_empresa    = p_func.cod_empresa
      AND cod_uni_funcio = p_func.cod_uni_funcio
      AND dat_validade_fim > p_dat_hor_process

   IF STATUS = 100 THEN
      LET p_msg = 'UNIDADE FUNCIONAL INEXISTENTE NO LOGIX'
      CALL pol1179_insere_erro()  RETURNING p_status
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_func.cod_uni_funcio CLIPPED, ' NA TAB UNI_FUNCIONAL'
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
   
   SELECT den_cargo
     FROM cargo
    WHERE cod_empresa = p_func.cod_empresa
      AND cod_cargo = p_func.cod_cargo
      AND DATE(dat_validade_fim) > p_dat_process

   IF STATUS = 100 THEN
      LET p_msg = 'CARGO INEXISTENTE NO LOGIX'
      CALL pol1179_insere_erro()  RETURNING p_status
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_func.cod_cargo CLIPPED, ' NA TABELA CARGO'
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_turno
     INTO p_cod_turno
     FROM escala
    WHERE cod_empresa = p_func.cod_empresa
      AND cod_escala = p_func.cod_escala

   IF STATUS = 100 THEN
      LET p_msg = 'ESCLA INEXISTENTE NO LOGIX'
      CALL pol1179_insere_erro()  RETURNING p_status
      LET p_cod_turno = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_func.cod_escala CLIPPED, ' NA TABELA ESCALA'
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
   
   IF p_cod_turno IS NOT NULL THEN
      IF p_cod_turno <> p_func.cod_cargo THEN
         LET p_msg = 'O TURNO ENVIADO EXISTE, MAS NAO EH O ESPERADO P/ A ESCALA ', p_func.cod_escala
         CALL pol1179_insere_erro()  RETURNING p_status
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1179_importa_func()#
#------------------------------#

   LET p_msg = NULL

   SELECT nom_funcionario
     FROM funcionario
    WHERE cod_empresa = p_func.cod_empresa
      AND num_matricula = p_func.num_matricula
   
   IF STATUS = 100 THEN
      IF NOT pol1179_adiciona() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT pol1179_altualiza() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO MAT ', 
                  p_func.num_matricula CLIPPED, ' NA TABELA FUNCIONARIO'
         CALL pol1179_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
     
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1179_adiciona()#
#--------------------------#

   LET pr_men[1].mensagem = 'INSERINDO FUNCIONARIO '
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_funcionario() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO FUN_FONETICA'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_fonetica() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO RHU_FIC_UNI_FUNC'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_fic_uni_func() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO RHU_FIC_SAL_FUNCIO'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_fic_sal_funcio() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO FUN_DIVERSOS'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_diversos() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO FUN_INFOR'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_infor() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO FUN_CONTRATO'
   CALL pol1179_exib_mensagem()
   
   IF NOT pol1179_fun_contrato() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO FUN_SALARIO'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_salario() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO FUN_IDENTIDADE'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_identidade() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO FUN_SINDICATO'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_sindicato() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO FUN_ESPELHO_PONTO'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_fun_espelho_ponto() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO RHU_FUNCIO_NOM'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_funcio_nom() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO ALTERAC_SAUDE'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_alterac_saude() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO RHU_FUN_PREVIDENC'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_fun_previdenc() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO SIL_DIMENSAO_FUNCIO'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_sil_dimensao_funcio() THEN
      RETURN FALSE
   END IF
   
   LET pr_men[1].mensagem = 'INSERINDO RHU_FICHA_QUADRO_FUNCIONAL'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_ficha_quadro_funcional() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO RHU_AUDIT_TAB_RHU'
   CALL pol1179_exib_mensagem()

   IF NOT pol1179_rhu_audit_tab_rhu() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION      
   
#-----------------------------#
FUNCTION pol1179_funcionario()#
#-----------------------------#

   LET p_ies_forma_pagto  = 'D'
   LET p_ies_socio_gremio = 'N'
   LET p_ativ_laboral     = '1'
   LET p_ies_adto         = 'N'
   LET p_cod_vinculo      = 10
   LET p_cod_categoria    = 'D'
   LET p_ies_bate_ponto   = 'S'

   INSERT INTO funcionario(
      cod_empresa,      
      num_matricula,    
      nom_funcionario,  
      num_registro,     
      cod_uni_funcio,   
      cod_cargo,
      dat_admis,
      dat_opcao_fgts,
      dat_ult_reaj_sal,
      cod_escala,
      ies_forma_pagto,  #D=Dinheiro
      ies_socio_gremio, #N=Não
      turno,
      ativ_laboral,     #1
      cod_categoria,    #D
      cod_vinculo,      #10
      ies_bate_ponto,   #S
      ies_adto,         #N=Não
      nom_completo,
      dat_atualiz)
   VALUES(p_func.cod_empresa,
          p_func.num_matricula,
          p_func.nom_funcionario,
          p_func.num_matricula,
          p_func.cod_uni_funcio,
          p_func.cod_cargo,
          p_func.dat_admissao,
          p_func.dat_admissao,
          p_func.dat_admissao,
          p_func.cod_escala,
          p_ies_forma_pagto,
          p_ies_socio_gremio,
          p_func.cod_turno,
          p_ativ_laboral,
          p_cod_categoria,
          p_cod_vinculo,
          p_ies_bate_ponto,
          p_ies_adto,
          p_func.nom_funcionario,
          p_dat_hor_process)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUNCIONARIO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#------------------------------#              
FUNCTION pol1179_fun_fonetica()#
#------------------------------#    

   INSERT INTO fun_fonetica
    VALUES(p_func.cod_empresa,   
           p_func.nom_funcionario,
           p_func.num_matricula)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_FONETICA'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#----------------------------------#              
FUNCTION pol1179_rhu_fic_uni_func()#
#----------------------------------#    

   INSERT INTO rhu_fic_uni_func
    VALUES(p_func.cod_empresa, 0,   
           p_func.num_matricula,
           p_dat_process,
           p_func.cod_uni_funcio,0)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_FIC_UNI_FUNC'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#------------------------------------#    
FUNCTION pol1179_rhu_fic_sal_funcio()#
#------------------------------------#

   INSERT INTO rhu_fic_sal_funcio (
      empresa,           
      matricula,         
      dat_alter_salario, 
      seq_alteracao_dat, 
      categoria,         
      cod_salarial,      
      val_salario_hor,   
      abrev_faix_salario,
      sit_cargo,         
      salario,           
      motivo_reajus,     
      dat_inclusao,      
      num_regra_reajus,  
      usuario,           
      funcao,            
      dat_ini_vigencia,  
      cargo,             
      tip_alteracao,     
      tip_sal_contratual,
      val_salario_mensal)
    VALUES(p_func.cod_empresa,
           p_func.num_matricula,
           p_dat_process, 1,
           p_ies_forma_pagto, 0, 0, 'DS',
           '', 0, 4,
           p_dat_process,
           '', p_user,
           'POL1179',
           p_dat_process,
           p_func.cod_cargo,
           'A', 'M', 0)
           
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_FIC_SAL_FUNCIO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        
           

#------------------------------#              
FUNCTION pol1179_fun_diversos()#
#------------------------------#    

   INSERT INTO fun_diversos (
      cod_empresa,
      num_matricula)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_DIVERSOS'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#---------------------------#              
FUNCTION pol1179_fun_infor()#
#---------------------------#    
   
   LET p_cod_cep = pol1179_tira_formato(p_func.cod_cep)
   
   INSERT INTO fun_infor (
      cod_empresa,
      num_matricula,
      end_funcio,
      end_compl,
      cod_cep)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,
           p_func.end_funcionario,
           p_func.end_complementar,
           p_cod_cep)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_INFOR'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-------------------------------------#
FUNCTION pol1179_tira_formato(p_campo)#
#-------------------------------------#

   DEFINE p_campo   CHAR(20),
          p_retorno CHAR(20)
   
   LET p_retorno = ''
   
   FOR p_ind = 1 TO LENGTH(p_campo)
       IF p_campo[p_ind] MATCHES '[0123456789]' THEN
          LET p_retorno = p_retorno CLIPPED, p_campo[p_ind]
       END IF
   END FOR
   
   RETURN p_retorno

END FUNCTION

#------------------------------#              
FUNCTION pol1179_fun_contrato()#
#------------------------------#    
   
   INSERT INTO fun_contrato (
      cod_empresa,
      num_matricula)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_CONTRATO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        
   
#-----------------------------#              
FUNCTION pol1179_fun_salario()#
#-----------------------------#    
   
   INSERT INTO fun_salario (
      cod_empresa,
      num_matricula,
      salario)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,0)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_SALARIO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#--------------------------------#              
FUNCTION pol1179_fun_identidade()#
#--------------------------------#    
   
   INSERT INTO fun_identidade (
      cod_empresa,
      num_matricula,
      num_cart_ident)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,'')

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_IDENTIDADE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-------------------------------#              
FUNCTION pol1179_fun_sindicato()#
#-------------------------------#    
   
   INSERT INTO fun_sindicato (
      cod_empresa,
      num_matricula,
      cod_sindicato_repr)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,16)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_SINDICATO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-----------------------------------#              
FUNCTION pol1179_fun_espelho_ponto()#
#-----------------------------------#    
   
   INSERT INTO fun_espelho_ponto (
      cod_empresa,
      num_matricula,
      ies_isento_espelho,
      ignorar_marcacao_intermed)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,'N','N')

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_ESPELHO_PONTO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#--------------------------------#              
FUNCTION pol1179_rhu_funcio_nom()#
#--------------------------------#    
   
   INSERT INTO rhu_funcio_nom (
      empresa,
      matricula,
      nom_completo)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,
           p_func.nom_funcionario)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_FUNCIO_NOM'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        
          
#-------------------------------#              
FUNCTION pol1179_alterac_saude()#
#-------------------------------#    
   
   DEFINE p_den_cargo CHAR(30)
   
   DECLARE cq_cargo CURSOR FOR
    SELECT den_cargo
      FROM cargo
     WHERE cod_empresa = p_func.cod_empresa
       AND cod_cargo = p_func.cod_cargo
       AND dat_validade_ini <= p_dat_hor_process
       AND dat_validade_fim >= p_dat_hor_process

   FOREACH cq_cargo INTO p_den_cargo

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ', 
                     p_func.cod_cargo CLIPPED, ' DA TAB CARGO'
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   INSERT INTO alterac_saude (
      cod_empresa,
      dat_alteracao,
      num_matricula,
      cod_saude_depend,
      nome,
      dat_admis,
      num_cpf,
      den_cargo,
      cod_entid_saude)
    VALUES(p_func.cod_empresa,   
           p_dat_process,
           p_func.num_matricula, 0,
           p_func.nom_funcionario,
           p_dat_process,
           p_func.num_cpf,
           p_den_cargo,0)
           
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB ALTERAC_SAUDE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-----------------------------------#              
FUNCTION pol1179_rhu_fun_previdenc()#
#-----------------------------------#    
   
   INSERT INTO rhu_fun_previdenc (
      empresa,
      matricula,
      pl_prvd_privada)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,0)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_FUN_PREVIDENC'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-------------------------------------#              
FUNCTION pol1179_sil_dimensao_funcio()#
#-------------------------------------#    
   
   SELECT MAX(chave_funcio) 
     INTO p_chave_funcio
     FROM sil_dimensao_funcio
   
   IF p_chave_funcio IS NULL THEN
      LET p_chave_funcio = 0
   END IF
   
   LET p_chave_funcio = p_chave_funcio + 1
   
   INSERT INTO sil_dimensao_funcio (
      chave_funcio,      
      empresa,           
      matricula,         
      nom_funcio,        
      dat_admissao,      
      cargo,             
      unid_funcional,    
      escala,            
      bate_ponto,        
      fma_pagto,         
      cidade_endereco)
   VALUES(p_chave_funcio,
          p_func.cod_empresa,
          p_func.num_matricula,
          p_func.nom_funcionario,
          p_dat_process,
          p_func.cod_cargo,
          p_func.cod_uni_funcio,
          p_func.cod_escala,
          'S',p_ies_forma_pagto,
          p_func.end_funcionario)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB SIL_DIMENSAO_FUNCIO'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#--------------------------------------------#              
FUNCTION pol1179_rhu_ficha_quadro_funcional()#
#--------------------------------------------#    
   
   INSERT INTO rhu_ficha_quadro_funcional (
      empresa,        
      matricula,      
      dat_alteracao,  
      unid_funcional, 
      cargo,          
      ativ_laboral,   
      turno,          
      usuario_atualiz,
      rotina_atualiz)
    VALUES(p_func.cod_empresa,   
           p_func.num_matricula,
           p_dat_process,
           p_func.cod_uni_funcio,
           p_func.cod_cargo,1,
           p_func.cod_turno,
           p_user,
           'POL1179')

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_FICHA_QUADRO_FUNCIONAL'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#-----------------------------------#
FUNCTION pol1179_rhu_audit_tab_rhu()#
#-----------------------------------#
   
   IF NOT pol1179_ins_audit('funcionario',
            'nom_completo', p_func.nom_funcionario) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'dat_admis', p_dat_process) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'cod_escala', p_func.cod_escala) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'turno', p_func.cod_turno) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'cod_cargo', p_func.cod_cargo) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'ies_adto', p_ies_adto) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'cod_vinculo', p_cod_vinculo) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('funcionario',
            'ies_forma_pgto', p_ies_forma_pagto) THEN
      RETURN FALSE
   END IF

   IF NOT pol1179_ins_audit('fun_infor',
            'num_cpf', p_func.num_cpf) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------------------------------#
FUNCTION pol1179_ins_audit(p_tab, p_campo, p_conteudo)#
#-----------------------------------------------------#

   DEFINE p_tab      CHAR(20),
          p_campo    CHAR(20),
          p_conteudo CHAR(50)

   INSERT INTO rhu_audit_tab_rhu (
      empresa,       
      matricula,     
      tip_ocorren,   
      dat_ocorren,   
      nom_tabela,    
      nom_campo,     
      conteudo_atual,
      usuario,       
      funcao)
   VALUES(p_func.cod_empresa,   
          p_func.num_matricula,'I',
          p_dat_hor_process,
          p_tab,
          p_campo,
          p_conteudo,
          p_user,
          'POL1179')
          
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ', 
                  p_func.num_matricula CLIPPED, ' NA TAB RHU_AUDIT_TAB_RHU'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        

#---------------------------#
FUNCTION pol1179_altualiza()#
#---------------------------#

   UPDATE funcionario
      SET nom_funcionario = p_func.nom_funcionario,
          cod_uni_funcio  = p_func.cod_uni_funcio,
          cod_cargo       = p_func.cod_cargo,
          cod_escala      = p_func.cod_escala,
          nom_completo    = p_func.nom_funcionario,
          dat_atualiz     = p_dat_process
    WHERE cod_empresa   = p_func.cod_empresa
      AND num_matricula = p_func.num_matricula

   IF STATUS <> 0 THEN   
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO MATRICULA ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUNCIONARIO'
      CALL pol1179_insere_erro()  RETURNING p_status
      RETURN FALSE
   END IF
   
   LET p_cod_cep = pol1179_tira_formato(p_func.cod_cep)
   
   UPDATE fun_infor
      SET end_funcio = p_func.end_funcionario,
          end_compl  = p_func.end_complementar,
          cod_cep    = p_cod_cep,
          num_cpf    = p_func.num_cpf,
          dat_nascimento = p_func.dat_nascimento
    WHERE cod_empresa   = p_func.cod_empresa
      AND num_matricula = p_func.num_matricula

   IF STATUS <> 0 THEN   
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO MATRICULA ', 
                  p_func.num_matricula CLIPPED, ' NA TAB FUN_INFOR'
      CALL pol1179_insere_erro()  RETURNING p_status
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#---------FIM DO PROGRAMA BJB-------------#
{ALTERAÇÕES


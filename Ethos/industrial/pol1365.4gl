#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1365                                                 #
# OBJETIVO: APONTAMENTOS PRODUÇÃO - INTEGRAÇÃO NEST                 #
# AUTOR...: IVO                                                     #
# DATA....: 25/02/19                                                #
#-------------------------------------------------------------------#
# Ver parâmetros de exibição de tela e item sucata na LOG00087      #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
           
END GLOBALS

DEFINE ma_erros            ARRAY[500] OF RECORD
       num_ordem           INTEGER,
       cod_item            CHAR(15),
       den_erro            CHAR(500)
END RECORD

DEFINE m_processo          CHAR(30),
       p_criticou          SMALLINT,
       p_tem_critica       SMALLINT,
       p_qtd_hor_unit      DECIMAL(11,7),
       m_houve_erro        SMALLINT,
       m_nom_tela          CHAR(200),
       p_msg               CHAR(500),
       p_cod_erro          CHAR(10),
       m_tipo_sgbd         CHAR(03),
       m_dat_proces        CHAR(19),
       m_cod_user          CHAR(08),
       m_num_programa      VARCHAR(50),
       m_count             INTEGER,
       m_qtd_erro          INTEGER,
       m_dat_atu           CHAR(19),
       m_ies_atu_man       SMALLINT

DEFINE p_man               RECORD
       cod_empresa         CHAR(2),                            
       num_ordem           INTEGER,                              
       cod_item            CHAR(15),                              
       num_docum           CHAR(10),                                       
       cod_compon          CHAR(15),                            
       num_lote            CHAR(15),                                        
       dat_inicial         DATE  ,                               
       dat_final           DATE  ,                                 
       cod_recur           CHAR(5),                                        
       cod_operac          CHAR(5)  ,                             
       num_seq_operac      DECIMAL(3,0)  ,                    
       oper_final          CHAR(1)  ,                             
       cod_cent_trab       CHAR(5)  ,                          
       cod_cent_cust       DECIMAL(4,0),                               
       cod_arranjo         CHAR(5)  ,                            
       qtd_refugo          DECIMAL(10,3)  ,                       
       qtd_sucata          DECIMAL(10,3)  ,                       
       qtd_boas            DECIMAL(10,3)  ,                         
       qtd_baixar          DECIMAL(10,3)  ,                       
       comprimento         INTEGER,                                      
       largura             INTEGER,                                          
       altura              INTEGER,                                           
       diametro            INTEGER,                                         
       tip_movto           CHAR(1)  ,                              
       cod_local_prod      CHAR(10),                                  
       cod_local_estoq     CHAR(10),                                 
       qtd_hor             DECIMAL(11,7)  ,                          
       matricula           CHAR(8),                                        
       cod_turno           CHAR(1)  ,                              
       hor_inicial         DATETIME HOUR TO SECOND  ,            
       hor_final           DATETIME HOUR TO SECOND  ,              
       unid_funcional      CHAR(10),                                  
       dat_atualiz         DATETIME YEAR TO SECOND  ,            
       ies_terminado       CHAR(1),                                    
       cod_eqpto           CHAR(15),                                       
       cod_ferramenta      CHAR(15),                                  
       integr_min          CHAR(1),                                       
       nom_prog            CHAR(8)  ,                               
       nom_usuario         CHAR(8)  ,                            
       cod_status          CHAR(1)  ,                             
       num_programa        CHAR(50)  ,                          
       id_man_apont        INTEGER  ,                           
       dat_inicio          DATE,                                          
       cod_roteiro         CHAR(15),                                     
       num_altern_roteiro  DECIMAL(3,0),                          
       unid_produtiva      CHAR(5),                                   
       dat_apontamento     DATETIME YEAR TO SECOND  ,        
       cod_defeito         DECIMAL(3,0),                                 
       baixa_sucata        DECIMAL(10,3),
       id_nest             INTEGER                              
END RECORD

DEFINE p_dat_fecha_ult_man LIKE par_estoque.dat_fecha_ult_man,
       p_dat_fecha_ult_sup LIKE par_estoque.dat_fecha_ult_sup,
       p_dat_inicio        LIKE ord_oper.dat_inicio,
       p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
       m_qtd_necess        LIKE man_op_componente_operacao.qtd_necess
       
DEFINE p_programa          RECORD             
    cod_empresa            char(2),             
    num_programa           char(50),            
    num_ordem              integer,             
    cod_operac             char(5),             
    cod_item_compon        char(15),            
    qtd_produzida          decimal(10,3),       
    pes_unit               decimal(14,7),       
    tempo_unit             char(8),             
    tip_registro           char(1),             
    cod_item               char(15),            
    qtd_boas               decimal(10,3),       
    qtd_apontada           decimal(10,3),       
    qtd_refugo             decimal(10,3),       
    cod_defeito            decimal(3,0),        
    pes_sucata             decimal(14,7),       
    dat_import             date,                
    flag                   varchar(1),          
    id_registro            integer,             
    operador               char(15),            
    tempo_corte_prog        decimal(10,4),      
    metro_linear            decimal(17,4),      
    dat_integracao          char(19)            
   END RECORD

DEFINE  p_sdo_op            DECIMAL(10,3),
        p_qtd_apontar       decimal(10,3),
        p_ies_forca_apont   char(01),
        p_ies_situa         char(01),
        p_dat_movto         DATE,
        p_hor_movto         CHAR(08)

DEFINE p_w_apont_prod   RECORD 													
   cod_empresa         char(2),                         
   cod_item            char(15), 
   num_ordem           integer, 
   num_docum           char(10), 
   cod_roteiro         char(15), 
   num_altern          dec(2,0), 
   cod_operacao        char(5), 
   num_seq_operac      dec(3,0), 
   cod_cent_trab       char(5), 
   cod_arranjo         char(5), 
   cod_equip           char(15), 
   cod_ferram          char(15), 
   num_operador        char(15), 
   num_lote            char(15), 
   hor_ini_periodo     datetime hour to minute, 
   hor_fim_periodo     datetime hour to minute, 
   cod_turno           dec(3,0), 
   qtd_boas            dec(10,3), 
   qtd_refug           dec(10,3), 
   qtd_total_horas     dec(10,2), 
   cod_local           char(10), 
   cod_local_est       char(10), 
   dat_producao        date, 
   dat_ini_prod        date, 
   dat_fim_prod        date, 
   cod_tip_movto       char(1), 
   estorno_total       char(1), 
   ies_parada          smallint, 
   ies_defeito         smallint, 
   ies_sucata          smallint, 
   ies_equip_min       char(1), 
   ies_ferram_min      char(1), 
   ies_sit_qtd         char(1), 
   ies_apontamento     char(1), 
   tex_apont           char(255), 
   num_secao_requis    char(10), 
   num_conta_ent       char(23), 
   num_conta_saida     char(23), 
   num_programa        char(8), 
   nom_usuario         char(8), 
   num_seq_registro    integer, 
   observacao          char(200), 
   cod_item_grade1     char(15), 
   cod_item_grade2     char(15), 
   cod_item_grade3     char(15), 
   cod_item_grade4     char(15), 
   cod_item_grade5     char(15), 
   qtd_refug_ant       dec(10,3), 
   qtd_boas_ant        dec(10,3), 
   tip_servico         char(1), 
   abre_transacao      smallint, 
   modo_exibicao_msg   smallint, 
   seq_reg_integra     integer, 
   endereco            integer, 
   identif_estoque     char(30), 
   sku                 char(25), 
   finaliza_operacao   char(1)
END RECORD

DEFINE m_cod_compon     LIKE man_apo_logix_405.cod_compon,        
       m_cod_recur      LIKE man_apo_logix_405.cod_recur,       
       m_oper_final     LIKE man_apo_logix_405.oper_final,       
       m_cent_cust      LIKE man_apo_logix_405.cod_cent_cust,       
       m_qtd_sucata     LIKE man_apo_logix_405.qtd_sucata,       
       m_qtd_baixar     LIKE man_apo_logix_405.qtd_baixar,        
       m_unid_funcio    LIKE man_apo_logix_405.unid_funcional,        
       m_dat_atualiz    LIKE man_apo_logix_405.dat_atualiz,        
       m_ies_terminado  LIKE man_apo_logix_405.ies_terminado,       
       m_id_apont       LIKE man_apo_logix_405.id_man_apont,       
       m_pes_unit       LIKE item.pes_unit,
       m_unid_item      LIKE item.cod_unid_med,
       m_unid_sucata    LIKE item.cod_unid_med


DEFINE m_cod_sucata     CHAR(15), 
       m_local_sucata   CHAR(10), 
       m_cod_item       CHAR(15),
       m_fat_conver     DECIMAL(12,5),
       m_qtd_conver     DECIMAL(15,3),
       m_qtd_movto      DECIMAL(10,3), 
       m_cod_defeito    DECIMAL(3,0),
       m_num_ordem      INTEGER,
       m_num_seq_oper   INTEGER,
       m_qtd_apontar    DECIMAL(10,3),
       m_status_nest    CHAR(01),
       m_exib_msg       SMALLINT

MAIN

   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_processo = 'Executando via bat'
      LET m_exib_msg = FALSE
   ELSE
      CALL log0180_conecta_usuario()
      CALL log001_acessa_usuario("ESPEC999","")     
          RETURNING p_status, p_cod_empresa, p_user
      LET m_processo = 'Executando via menu'
      LET m_exib_msg = TRUE
   END IF
   
   IF p_status = 0 THEN
      CALL pol1365_proces_apto(p_user, p_cod_empresa,"") 
   END IF
   
   IF m_exib_msg THEN
      IF p_tem_critica THEN
         LET p_msg = 'Alguns registros de apontamento foram criticados',
                     'Consulte as mensagens no pol1366.'
      ELSE
         LET p_msg = 'Todos os registros foram apontados com sucesso.'
      END IF
      CALL log0030_mensagem(p_msg,'info')
   END IF
         
END MAIN

#------------------------------#
FUNCTION pol1365_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '06'
   END IF

   IF l_param2_user IS NULL THEN
      LET l_param2_user = 'job0003'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   LET m_processo = 'Executando via JOB0003'

   CALL pol1365_proces_apto(p_user, p_cod_empresa,"") 

   {IF p_qtd_critica > 0 THEN
      CALL pol1365_logix_envia_email()
      #CALL pol1365_java_envia_email()
   END IF}
   
   IF m_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#------------------------------------------#
FUNCTION pol1365_proces_apto(l_u, l_e, l_p)#
#------------------------------------------#
 
   DEFINE l_u       CHAR(08),
          l_e       CHAR(02),
          l_p       CHAR(08)

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   LET p_versao = "pol1365-12.00.05  "
   CALL func002_versao_prg(p_versao)
   
   LET m_houve_erro = FALSE

   LET p_user = l_u
   LET p_cod_empresa = l_e
   
   IF l_p IS NOT NULL THEN
      LET m_processo = 'Executando via ',l_p
   END IF

   LET m_tipo_sgbd = LOG_getCurrentDBType()
   LET p_msg = m_processo

   LET m_dat_atu = EXTEND(CURRENT, YEAR TO SECOND)

   CALL pol1365_ins_proc(m_dat_atu)

   IF NOT pol1365_inicia_proc() THEN
      LET m_houve_erro = TRUE
   ELSE
      LET p_msg = 'PROCESSO EFETUADO COM SUCESSO'
   END IF

   LET m_dat_atu = EXTEND(CURRENT, YEAR TO SECOND)

   CALL pol1365_ins_proc(m_dat_atu)
   
   IF NOT m_houve_erro THEN
      IF NOT pol1365_atu_proces('N') THEN
         LET m_houve_erro = TRUE
      END IF
   END IF

END FUNCTION   

#-----------------------------#
FUNCTION pol1365_inicia_proc()#
#_----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_nom_tela TO NULL
   CALL log130_procura_caminho("pol1365") RETURNING m_nom_tela
   LET  m_nom_tela = m_nom_tela CLIPPED 
   OPEN WINDOW w_pol1365 AT 10,20 WITH FORM m_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   #lds CALL LOG_refresh_display()
   
   LET p_tem_critica = FALSE
   
   IF NOT pol1365_chec_proces() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1365_exec_proces() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1365_chec_proces()#
#-----------------------------#

   DEFINE l_ies_proces      CHAR(01),
          l_dat_atu         CHAR(19)
   
   LET l_dat_atu = EXTEND(CURRENT, YEAR TO SECOND)
      
   SELECT dat_proces,
          ies_proces,
          cod_usuario
     INTO m_dat_proces,
          l_ies_proces,
          m_cod_user
     FROM proces_apont_405
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' LENDO TABELA PROCES_APONT_405'
      RETURN FALSE
   END IF
   
   IF STATUS = 100 THEN
      
      INSERT INTO proces_apont_405
       VALUES(p_cod_empresa,l_dat_atu,'S',p_user)
      
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO ',p_cod_erro CLIPPED, 
               ' INSRTINDO DADOS NA TABELA PROCES_APONT_405'
         RETURN FALSE
      END IF
      
      RETURN TRUE
   END IF
   
   {IF l_ies_proces = 'S' THEN
      IF pol1365_retorna() THEN
         LET p_msg = 'JA EXISTE UM PROCESSO EM ANDAMENTO - USUÁRIO ', m_cod_user 
         RETURN FALSE
      END IF
   END IF}
   
   IF NOT pol1365_atu_proces('S') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1365_atu_proces(l_ies_proces)#
#----------------------------------------#

   DEFINE l_ies_proces      CHAR(01),
          l_dat_atu         CHAR(19)
   
   LET l_dat_atu = EXTEND(CURRENT, YEAR TO SECOND)

   UPDATE proces_apont_405
      SET ies_proces = l_ies_proces,
          dat_proces = l_dat_atu,
          cod_usuario = p_user
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, 
               ' ATUALIZANDO DADOS NA TABELA PROCES_APONT_405'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1365_retorna()#
#-------------------------#

   DEFINE l_dat_atu          DATE,
          l_hor_atu          CHAR(08),
          l_temp_atu         INTEGER,
          l_temp_tab         INTEGER,
          l_temp_dif         INTEGER,
          l_hora             INTEGER,
          l_minuto           INTEGER,
          l_segundo          INTEGER
   
   LET l_dat_atu = TODAY
   LET l_hor_atu = TIME

   LET l_hora = l_hor_atu[1,2]
   LET l_minuto = l_hor_atu[4,5]
   LET l_segundo = l_hor_atu[7,8]
   LET l_temp_atu = (l_hora * 3600) + (l_minuto * 60) + l_segundo

   LET l_hora = m_dat_proces[12,13]
   LET l_minuto = m_dat_proces[15,16]
   LET l_segundo = m_dat_proces[18,19]
   LET l_temp_tab = (l_hora * 3600) + (l_minuto * 60) + l_segundo
   
   IF l_temp_atu < l_temp_tab THEN
      LET l_temp_atu = l_temp_atu + 86400
   END IF
   
   LET l_temp_dif = l_temp_atu - l_temp_tab
   
   IF l_temp_dif > 1800 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1365_ins_proc(l_data)#
#--------------------------------#

   DEFINE l_data       CHAR(19),
          l_id         INTEGER
  
   LET l_id = 0
  
   INSERT INTO exec_proces_405(
    cod_empresa,
    cod_usuario,
    dat_exec,   
    mensagem,
    id_registro)
   VALUES(p_cod_empresa, p_user, l_data, p_msg, l_id)

END FUNCTION

#-----------------------------#
FUNCTION pol1365_exec_proces()#
#-----------------------------#

   CALL man8246_cria_temp_fifo()

   DECLARE cq_programa CURSOR WITH HOLD FOR
    SELECT DISTINCT num_programa
      FROM man_apo_nest_405
     WHERE tip_registro IN ('P','C')
       AND cod_empresa = p_cod_empresa

   FOREACH cq_programa INTO m_num_programa

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO AO LER PROXIMO PROGRAMA DA TAB MAN_APO_NEST_405'
         RETURN FALSE
      END IF
   
      LET p_criticou = FALSE
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1365_chek_programa() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      IF p_criticou THEN
         IF NOT pol1365_critica_man_nest() then
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      ELSE

         LET m_qtd_erro = 0
         INITIALIZE ma_erros TO NULL
         
         IF NOT pol1365_aponta_prog() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF  
          
         IF p_criticou THEN
            CALL log085_transacao("ROLLBACK")
            IF NOT pol1365_gra_erros() THEN
               RETURN FALSE
            END IF
            LET m_status_nest = 'C'
            LET p_tem_critica = TRUE
         ELSE
            CALL log085_transacao("COMMIT")      
            LET m_status_nest = 'A'
         END IF
         
         UPDATE man_apo_nest_405 SET tip_registro = m_status_nest
          WHERE cod_empresa  = p_programa.cod_empresa
            AND num_programa = p_programa.num_programa

         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_msg = 'ERRO ',p_cod_erro,' ATUALIZANDO TAB MAN_APO_NEST_405'
            RETURN FALSE
         END IF
         
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION   

#-----------------------------#
 FUNCTION pol1365_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO man_erro_405
      VALUES (p_programa.cod_empresa,
              p_programa.num_programa,
              p_man.num_ordem,
              p_msg, m_dat_atu)

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro, ' INSERINDO CRITICA NA TAB MAN_ERRO_405'
      RETURN FALSE
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1365_gra_erros()#
#---------------------------#
   
   DEFINE l_ind     INTEGER

   IF NOT pol1365_deleta_erro() THEN
      RETURN FALSE
   END IF
   
   FOR l_ind = 1 TO m_qtd_erro
   
      LET p_man.num_ordem = ma_erros[l_ind].num_ordem
      LET p_msg = ma_erros[l_ind].den_erro
      
      IF NOT pol1365_insere_erro() THEN
         RETURN FALSE
      END IF
      
   END FOR
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1365_deleta_erro()
#----------------------------#

   DELETE FROM man_erro_405
    WHERE cod_empresa = p_cod_empresa
      AND num_programa = m_num_programa
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'NAO FOI POSSIVEL DELETAR CRITICAS DA TABELA MAN_ERRO_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1365_chek_programa()#
#--------------------------------#
   
   LET p_dat_movto = TODAY
   LET p_hor_movto = TIME
   
   IF NOT pol1365_deleta_erro() THEN
      RETURN FALSE
   END IF
     
   IF NOT pol1365_consiste_dados() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1365_consiste_dados()
#-------------------------------#

   IF not pol1365_le_fechamento() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_consiste CURSOR FOR
    SELECT *
      FROM man_apo_nest_405
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = m_num_programa
       
   FOREACH cq_consiste INTO p_programa.*

      if status <> 0 then
         let p_cod_erro = STATUS
         let p_msg = 'ERRO AO LER OS DADOS DO PROGRAMA PARA CONSISTENCIA'
         RETURN false
      end if
      
      INITIALIZE p_man TO NULL
      
      let p_man.cod_empresa = p_programa.cod_empresa
      let p_man.num_ordem   = p_programa.num_ordem
      let p_man.num_programa= p_programa.num_programa
      let p_man.cod_operac  = p_programa.cod_operac
      
      if not pol1365_checa_ordem() then
         return false
      end if
      
      IF p_msg IS NOT NULL THEN
         IF NOT pol1365_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
           
      if not pol1365_checa_operacao() then
         return false
      end if

      IF p_msg IS NOT NULL THEN
         IF NOT pol1365_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      if p_programa.qtd_refugo is null OR p_programa.qtd_refugo < 0 then
         let p_programa.qtd_refugo  = 0
      end if

      let p_man.qtd_refugo = p_programa.qtd_refugo
      let p_man.cod_defeito = p_programa.cod_defeito
      let p_man.qtd_boas   = p_programa.qtd_produzida - p_man.qtd_refugo
      
      if p_man.qtd_boas < 0 then
         let p_msg = 'QUANTIDADE DE BOAS A APONTAR INVALIDA'
         call pol1365_insere_erro()
      end if
      
      let p_qtd_apontar = p_man.qtd_boas + p_man.qtd_refugo 

      if p_qtd_apontar <= 0 then
         let p_msg = 'QUANTIDADE PRODUZIDA INVALIDA'
         call pol1365_insere_erro()
      end if
      
      IF p_sdo_op < p_qtd_apontar THEN
         LET p_ies_forca_apont = pol1365_forca_apont(p_man.cod_item)
         IF p_ies_forca_apont = 'N' then
            LET p_msg = 'QUANTIDADE A APONTAR MAIOR QUE O SALDO DA OPERACAO'
            CALL pol1365_insere_erro()
         END IF
      END IF
      
      if p_programa.pes_unit is null then
         let p_programa.pes_unit = 0
      end if

      if p_programa.pes_sucata is null or p_programa.pes_sucata < 0 then
         let p_programa.pes_sucata = 0
      end if

      let p_man.qtd_sucata = p_programa.pes_sucata
      
      IF p_man.qtd_sucata > 0 THEN
         
         IF NOT pol1365_le_it_sucata() THEN
            return FALSE
         end IF
      END if
               
      if p_programa.pes_unit < 0 then
         let p_msg = 'PESO UNITARIO INVALIDO'
         call pol1365_insere_erro()
      end if
            
      CALL pol1365_checa_tempo_unit()

      IF p_msg IS NOT NULL THEN
         IF NOT pol1365_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_man.cod_compon = p_programa.cod_item_compon

      CALL pol1365_calc_data_hora()
      
      IF p_dat_fecha_ult_man IS NOT NULL THEN
         IF p_man.dat_inicial <= p_dat_fecha_ult_man THEN
            LET p_msg = 'A MANUFATURA JA ESTA FECHADA'
            IF not pol1365_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF

      IF p_dat_fecha_ult_sup IS NOT NULL THEN
         IF p_man.dat_inicial < p_dat_fecha_ult_sup THEN
            LET p_msg = 'O ESTOQUE JA ESTA FECHADO'
            IF not pol1365_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      IF NOT p_criticou then
         IF NOT pol1365_insere_man() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1365_checa_ordem()
#-----------------------------#
   
   LET p_msg = NULL

   if p_programa.num_ordem is NULL OR p_programa.num_ordem = 0  then
      let p_msg = 'ORDEM DE PRODUCAO INVALIDA'
      return true
   end if

   SELECT (qtd_planej - qtd_boas - qtd_refug  - qtd_sucata),
          ies_situa,
          cod_item,
          cod_local_prod,
          cod_local_estoq,
          num_lote,
          cod_roteiro,                                 
          num_altern_roteiro,                             
          dat_ini
     INTO p_qtd_saldo,
          p_ies_situa,
          p_man.cod_item,
          p_man.cod_local_prod,
          p_man.cod_local_estoq,
          p_man.num_lote,
          p_man.cod_roteiro,
          p_man.num_altern_roteiro,
          p_dat_inicio
     FROM ordens
    WHERE cod_empresa = p_man.cod_empresa
      AND num_ordem   = p_programa.num_ordem
                                                         
   IF STATUS = 100 THEN                                    
      let p_msg = 'ORDEM DE PRODUCAO INEXISTENTE NO LOGIX'
      call pol1365_insere_erro()
      return true
   ELSE
      if status <> 0 then
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO ORDEM NA TABELA ORDENS DO LOGIX'
         return false
      end if
   END IF                                                 
   
   if p_ies_situa <> '4' then
      let p_msg = 'ORDEM DE PRODUCAO NAO ESTA LIBERADA NO LOGIX'
      call pol1365_insere_erro()
   end if
                                                          
   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN     
      LET p_dat_inicio = p_dat_movto           
   END IF                                                 
   
   let p_man.dat_inicio = p_dat_inicio
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1365_checa_operacao()
#--------------------------------#

   DEFINE p_num_seq   integer,
          p_cod_recur char(05)

   LET p_msg = NULL
   
   if p_programa.cod_operac is NULL then
      let p_msg = 'CODIGO DA OPERACAO INVALIDO'
      return true
   end if
   
   DECLARE cq_operacao CURSOR FOR
   SELECT num_seq_operac
		 FROM ord_oper
    WHERE cod_empresa = p_man.cod_empresa
	    AND num_ordem   = p_man.num_ordem
      AND cod_item    = p_man.cod_item
      AND cod_operac  = p_man.cod_operac
      AND num_seq_operac  = 1
      AND ies_apontamento = 'S'
    ORDER BY num_seq_operac

   FOREACH cq_operacao into p_num_seq
   
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO SEQUENCIA DA OPERACAO NA TABELA ORD_OPER'
         return false
      END IF
      
      LET p_man.num_seq_operac = p_num_seq
      EXIT FOREACH
      
   END FOREACH
   
   if p_man.num_seq_operac is null then
      let p_msg = 'OPERACAO NAO PREVISTA PARA A ORDEM OU NAO APONTAVEL'
      return true
   end if
   
   SELECT cod_cent_trab,
          cod_arranjo,
          cod_cent_cust,
          ies_oper_final,
          (qtd_planejada -
           qtd_boas      -
           qtd_refugo    -
           qtd_sucata)
     INTO p_man.cod_cent_trab,
          p_man.cod_arranjo,
          p_man.cod_cent_cust,
          p_man.oper_final,
          p_sdo_op
		 FROM ord_oper
    WHERE cod_empresa    = p_man.cod_empresa
	    AND num_ordem      = p_man.num_ordem
      AND cod_item       = p_man.cod_item
      AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO DADOS DA OPERACAO NA TABELA ORD_OPER'
      return false
   END IF

   DECLARE cq_recurso CURSOR FOR
    SELECT a.cod_recur
      FROM rec_arranjo a,
           recurso b
     WHERE a.cod_empresa   = p_man.cod_empresa
       AND a.cod_arranjo   = p_man.cod_arranjo
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_recur     = a.cod_recur
       AND b.ies_tip_recur = '2'
       
   FOREACH cq_recurso INTO p_cod_recur 

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO CODIGO DO RECURSO NAS TABELAS REC_ARRANJO/RECURSO'
         RETURN FALSE
      END IF
         
      LET p_man.cod_recur = p_cod_recur
         
   END FOREACH
   
   if p_man.cod_recur is null then
      let p_man.cod_recur = ' '
   end if
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1365_forca_apont(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item    like item.cod_item,
          p_forca_apont char(01)

   SELECT ies_forca_apont
     INTO p_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      let p_forca_apont = 'N'
   END IF

   RETURN (p_forca_apont)
   
END FUNCTION

#------------------------------#
FUNCTION pol1365_le_it_sucata()#
#------------------------------#

   SELECT cod_item, cod_defeito
     INTO m_cod_sucata, m_cod_defeito
     FROM item_sucata_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = p_man.cod_operac

   IF STATUS = 100 THEN                                    
      let p_msg = 'ITEM SUCATA DA OPERAÇÃO ', p_man.cod_operac 
      let p_msg = p_msg CLIPPED, ' NÃO CADASTRADO NO POL1367'
      call pol1365_insere_erro()
   ELSE
      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO ORDEM NA TABELA ITEM_SUCATA_304'
         RETURN FALSE
      END IF
   END IF                                                 

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1365_le_itens()#
#--------------------------#

   SELECT pes_unit,
          cod_unid_med
     INTO m_pes_unit, m_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
	    LET p_msg = 'ERRO: ',p_cod_erro CLIPPED, ' LENDO TAB ITEM:PESO'
	    RETURN FALSE
	 END IF

   SELECT cod_unid_med,
          cod_local
     INTO m_unid_sucata,
          m_local_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_sucata
	        
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
	    LET p_msg = 'ERRO: ',p_cod_erro CLIPPED, ' LENDO TAB ITEM:SUCATA'
	    RETURN FALSE
	 END IF
	 
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1365_w_sucata()
#---------------------------#
	
	DROP TABLE w_sucata

  CREATE TEMP TABLE w_sucata	(	
     cod_sucata      	CHAR(15),
     qtd_apont	        DECIMAL(15,3),
     fat_conversao	    DECIMAL(12,5),
     qtd_convertida  	DECIMAL(15,3),
     motivo_sucata 	  DECIMAL(3,0)
   );	

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' CRIANDO TABELA W_SUCATA '
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#---------------------------------#
FUNCTION pol1365_checa_tempo_unit()
#---------------------------------#
   
   DEFINE p_hh, p_mm, p_ss INTEGER,
          p_hora           CHAR(06),
          p_ind            INTEGER
   
   LET p_msg = NULL
   
   if p_programa.tempo_unit is null OR p_programa.tempo_unit = 0 then
      let p_msg = 'TEMPO DE CORTE INVIADO. VERIFIQUE-O NO NEXT'
      return 
   end if
   
   let p_hora = p_programa.tempo_unit[1,2],
                p_programa.tempo_unit[4,5],
                p_programa.tempo_unit[7,8]
 
   for p_ind = 1 to LENGTH(p_hora)
      if p_hora[p_ind] MATCHES '[0123456789]' then
      else
         let p_msg = 'TEMPO UNITARIO INVALIDO'
         return 
      end if
   end for
   
   let p_hh = p_programa.tempo_unit[1,2]
   let p_mm = p_programa.tempo_unit[4,5]
   let p_ss = p_programa.tempo_unit[7,8]
   
   if p_hh > 23 or p_mm > 59 or p_ss > 59 then
      let p_msg = 'TEMPO UNITARIO INVALIDO'
      RETURN
   end if   
   
   let p_qtd_hor_unit = p_hh + ((p_mm * 60 + p_ss) / 3600)
   
   let p_man.qtd_hor = p_qtd_hor_unit * p_qtd_apontar

   if p_man.qtd_hor > 9999 then
      let p_msg = 'TEMPO DE CORTE EXCESSIVO. VERIFIQUE-O NO NEST'
   end if

END FUNCTION

#-------------------------------#
FUNCTION pol1365_calc_data_hora()
#-------------------------------#

   DEFINE p_hi             CHAR(02),
          p_mi             CHAR(02),
          p_si             CHAR(02),
          p_hf             INTEGER,
          p_mf             INTEGER,
          p_sf             INTEGER,
          p_dat_ini        CHAR(10),
          p_hor_ini        CHAR(8),
          p_hor_fim        CHAR(8),
          p_segundo_ini    INTEGER,
          p_segundo_fim    INTEGER,
          p_tmp_producao   INTEGER,
          p_dat_fim        DATE
          
   LET p_tmp_producao = p_man.qtd_hor * 3600
   
   LET p_dat_ini = p_dat_movto
   LET p_dat_fim = p_dat_ini
   LET p_hor_ini = p_hor_movto
   
   LET p_man.dat_inicial = p_dat_ini
   LET p_man.hor_inicial = p_hor_ini
   
   LET p_hi = p_hor_ini[1,2]
   
   CALL pol1365_calcula_turno(p_hi)
   
   LET p_mi = p_hor_ini[4,5]
   LET p_si = p_hor_ini[7,8]
   LET p_segundo_ini = (p_hi * 3600)+(p_mi * 60)+(p_si)
   LET p_segundo_fim = p_segundo_ini + p_tmp_producao + 60

   LET p_hf = p_segundo_fim / 3600
   LET p_segundo_fim = p_segundo_fim - p_hf * 3600
   LET p_mf = p_segundo_fim / 60
   LET p_sf = p_segundo_fim - p_mf * 60


   WHILE p_hf > 23
      LET p_hf = p_hf - 24
      LET p_dat_fim = p_dat_fim + 1
   END WHILE   
      
   LET p_hi = p_hf USING '&&'
   LET p_mi = p_mf USING '&&'
   LET p_si = p_sf USING '&&'
   LET p_hor_fim = p_hi,':',p_mi,':',p_si

   LET p_man.dat_final = p_dat_fim
   LET p_man.hor_final = p_hor_fim

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1365_calcula_turno(p_hi)
#-----------------------------------#

   DEFINE p_hi SMALLINT
   
   IF p_hi >= 6 AND p_hi < 14 THEN
      LET p_man.cod_turno = '1'
   ELSE
      IF p_hi >= 14 AND p_hi < 22 THEN
         LET p_man.cod_turno = '2'
      ELSE
         LET p_man.cod_turno = '3'
      END IF
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1365_le_fechamento()#
#-------------------------------#

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL LER DADOS DA TABELA PAR_ESTOQUE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1365_insere_man()
#----------------------------#
   
   DEFINE p_id_man_apont INTEGER
   
   LET p_man.nom_prog = 'POL1365'
   LET p_man.nom_usuario = p_user
   LET p_man.cod_status = 'I'
   LET p_man.dat_atualiz = CURRENT
   LET p_man.integr_min = 'N'
   LET p_man.matricula = p_programa.operador
   LET p_man.tip_movto = 'N'
   LET p_man.id_nest = p_programa.id_registro  

   let p_man.qtd_baixar = p_programa.pes_unit
   let p_man.baixa_sucata = p_programa.pes_sucata
   
   if not pol1365_le_ferramenta() then
      return false
   end if

   if not pol1365_le_uni_funcio() then
      return false
   end if

   SELECT cod_unid_prod 
     INTO p_man.unid_produtiva
     FROM cent_trabalho
    WHERE cod_empresa   = p_man.cod_empresa
      AND cod_cent_trab = p_man.cod_cent_trab

   IF STATUS <> 0 THEN
      LET p_man.unid_produtiva = ' '
   END IF
   
   SELECT MAX(id_man_apont)
     INTO p_id_man_apont
     FROM man_apo_logix_405
    WHERE cod_empresa = p_man.cod_empresa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ERRO LENDO PROXIMO ID DA DA TABELA MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   IF p_id_man_apont IS NULL THEN
      LET p_id_man_apont = 1
   ELSE
      LET p_id_man_apont = p_id_man_apont + 1
   END IF
   
   LET p_man.id_man_apont = p_id_man_apont
   LET p_man.dat_apontamento = CURRENT YEAR TO SECOND
   
   DELETE FROM man_apo_logix_405
    WHERE cod_empresa = p_cod_empresa
      AND id_nest = p_programa.id_registro

   IF STATUS <> 0 THEN 
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ', p_cod_erro, ' DELETANDO REGISTRO DA TABELA MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   INSERT INTO man_apo_logix_405
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      let p_cod_erro = STATUS
      let p_msg = 'ERRO ', p_cod_erro, ' INSERINDO PEÇAS BOAS NA TABELA MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1365_le_ferramenta()
#-------------------------------#

   DEFINE p_cod_ferramenta LIKE consumo_fer.cod_ferramenta,
          p_seq_processo   LIKE man_processo_item.seq_processo
          
   DECLARE cq_proces CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa        = p_man.cod_empresa  
      AND item           = p_man.cod_item     
      AND roteiro        = p_man.cod_roteiro
      AND roteiro_alternativo = p_man.num_altern_roteiro
      AND operacao         = p_man.cod_operac
 
   FOREACH cq_proces INTO p_seq_processo

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO ',p_cod_erro CLIPPED, 'LENDO TABELA MAN_PROCESSO_ITEM'
         RETURN FALSE
      END IF

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_man.cod_empresa
          AND seq_processo = p_seq_processo

      FOREACH cq_fer INTO p_cod_ferramenta

         IF STATUS <> 0 THEN
            let p_cod_erro = STATUS
            let p_msg = 'ERRO ',p_cod_erro CLIPPED, 'LENDO TABELA FERRAMENTA'
            RETURN FALSE
         END IF

         EXIT FOREACH
         
      END FOREACH

      EXIT FOREACH

   END FOREACH 

   IF p_cod_ferramenta IS NULL THEN
      LET p_cod_ferramenta = 0
   END IF
   
   LET p_man.cod_ferramenta = p_cod_ferramenta
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1365_le_uni_funcio()
#-------------------------------#

   DEFINE p_cod_uni_funcio LIKE uni_funcional.cod_uni_funcio
   
   DECLARE cq_funcio CURSOR FOR 
	  SELECT cod_uni_funcio 
		  FROM uni_funcional
		 WHERE cod_empresa      =  p_man.cod_empresa
			 AND cod_centro_custo =  p_man.cod_cent_cust
       AND dat_validade_ini <= CURRENT YEAR TO SECOND  
       AND dat_validade_fim >= CURRENT YEAR TO SECOND					
																		
	 FOREACH cq_funcio INTO p_cod_uni_funcio

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO LENDO CODIGO DA DA TABELA UNI_FUNCIONAL'
         RETURN FALSE
      END IF
					
		  IF p_cod_uni_funcio IS NOT NULL THEN
				 EXIT FOREACH
			END IF 
					
	 END FOREACH
   
   let p_man.unid_funcional = p_cod_uni_funcio
   
   return true

end FUNCTION

#---------------------------------#
FUNCTION pol1365_critica_man_nest()
#---------------------------------#

   UPDATE man_apo_nest_405
      set tip_registro = 'C'
    where cod_empresa  = p_programa.cod_empresa
      and num_programa = p_programa.num_programa

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL ATUALIZAR A TABELA MAN_APO_NEST_405'
      RETURN FALSE
   END IF
   
   DELETE FROM man_apo_logix_405
    WHERE cod_empresa  = p_programa.cod_empresa
      AND num_programa = p_programa.num_programa
      AND cod_status   = 'I'
   
   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'NAO FOI POSSIVEL DELETAR REGISTROS DA TAB MAN_APO_LOGIX_405'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1365_aponta_prog()#
#-----------------------------#
   
   DEFINE l_id_nest     INTEGER
   
   INITIALIZE p_w_apont_prod.* TO NULL
   
   DECLARE cq_aponta CURSOR FOR
    SELECT cod_empresa,                                        
           num_ordem,                                          
           cod_item,                                            
           num_docum,                                            
           cod_compon,                                                               
           num_lote,                            
           dat_inicial,                               
           dat_final,             
           cod_recur,                           
           cod_operac,                             
           num_seq_operac,                             
           oper_final,                                         
           cod_cent_trab,                              
           cod_cent_cust,                               
           cod_arranjo,                                
           qtd_refugo,                        
           qtd_sucata,                           
           qtd_boas,                               
           qtd_baixar,                                  
           tip_movto,                             
           cod_local_prod,               
           cod_local_estoq,       
           qtd_hor,                                 
           matricula,             
           cod_turno,                   
           hor_inicial,                 
           hor_final,                   
           unid_funcional,                  
           dat_atualiz,                           
           ies_terminado,                           
           cod_eqpto,                    
           cod_ferramenta,               
           integr_min,                   
           nom_prog,                     
           nom_usuario,                  
           id_man_apont,                       
           cod_roteiro,             
           num_altern_roteiro,
           id_nest     
      FROM man_apo_logix_405
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = m_num_programa
       AND cod_status   = 'I'
       AND num_ordem > 0

   FOREACH cq_aponta INTO 
           p_w_apont_prod.cod_empresa,          
           p_w_apont_prod.num_ordem,            
           p_w_apont_prod.cod_item,             
           p_w_apont_prod.num_docum,            
           m_cod_compon,         
           p_w_apont_prod.num_lote,             
           p_w_apont_prod.dat_ini_prod,         
           p_w_apont_prod.dat_fim_prod,         
           m_cod_recur,         
           p_w_apont_prod.cod_operacao,         
           p_w_apont_prod.num_seq_operac,       
           m_oper_final,        
           p_w_apont_prod.cod_cent_trab,        
           m_cent_cust,         
           p_w_apont_prod.cod_arranjo,          
           p_w_apont_prod.qtd_refug,            
           m_qtd_sucata,        
           p_w_apont_prod.qtd_boas,             
           m_qtd_baixar,         
           p_w_apont_prod.cod_tip_movto,        
           p_w_apont_prod.cod_local,            
           p_w_apont_prod.cod_local_est,        
           p_w_apont_prod.qtd_total_horas,      
           p_w_apont_prod.num_operador,         
           p_w_apont_prod.cod_turno,            
           p_w_apont_prod.hor_ini_periodo,      
           p_w_apont_prod.hor_fim_periodo,      
           m_unid_funcio,        
           m_dat_atualiz,        
           m_ies_terminado,     
           p_w_apont_prod.cod_equip,            
           p_w_apont_prod.cod_ferram,           
           p_w_apont_prod.ies_equip_min,        
           p_w_apont_prod.num_programa,         
           p_w_apont_prod.nom_usuario,          
           m_id_apont,          
           p_w_apont_prod.cod_roteiro,          
           p_w_apont_prod.num_altern,
           l_id_nest         

      IF STATUS <> 0 THEN
         let p_cod_erro = STATUS
         let p_msg = 'ERRO ', p_cod_erro CLIPPED,
             ' LENDO DADOS DA TABELA MAN_APO_LOGIX_405 - cq_aponta'
         RETURN FALSE
      END IF                                           

      LET m_cod_item = p_w_apont_prod.cod_item
      LET m_num_ordem = p_w_apont_prod.num_ordem
      LET m_num_seq_oper = p_w_apont_prod.num_seq_operac
      LET m_qtd_apontar = p_w_apont_prod.qtd_boas + p_w_apont_prod.qtd_refug
      
      DISPLAY m_num_ordem TO num_ordem
      #lds CALL LOG_refresh_display()

      IF NOT pol1365_cria_w_parada() THEN
         RETURN FALSE
      END IF
      
   	  CALL man8237_cria_tables_man8237()
      CALL pol1365_cria_w_alt_comp_wms()
            
      LET p_w_apont_prod.dat_producao	=	p_w_apont_prod.dat_fim_prod
			LET p_w_apont_prod.estorno_total        = "N"
			LET p_w_apont_prod.ies_sit_qtd 					=	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL

			SELECT COUNT(*) INTO m_count  FROM w_parada
			
			IF m_count > 0 THEN
			   LET p_w_apont_prod.ies_parada = 1
			ELSE
			   LET p_w_apont_prod.ies_parada = 0
			END IF      
      
      LET p_w_apont_prod.ies_defeito = 0 
      LET m_ies_atu_man = FALSE
      LET p_w_apont_prod.ies_sucata = 0

			IF p_w_apont_prod.cod_ferram = ' '   OR  
			   p_w_apont_prod.cod_ferram IS NULL THEN 
				 LET p_w_apont_prod.cod_ferram = NULL
				 LET p_w_apont_prod.ies_ferram_min =  "N"
			ELSE 
				 LET p_w_apont_prod.ies_ferram_min =  "S"
			END IF 				
            
      LET p_w_apont_prod.num_secao_requis = m_unid_funcio
      LET p_w_apont_prod.observacao = '  '
      LET p_w_apont_prod.finaliza_operacao = 'N'
      LET p_w_apont_prod.tip_servico = ' '
			LET p_w_apont_prod.abre_transacao 			= FALSE
			LET p_w_apont_prod.modo_exibicao_msg 		= 1
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
  
      IF NOT manr24_cria_w_apont_prod(1)THEN 
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO ', p_cod_erro CLIPPED, ' CRIANDO TABELA W_APONT_PROD'      
         RETURN FALSE
      END IF                                           
      
      IF NOT pol1365_cria_w_compon() THEN
         RETURN FALSE
      END IF
                  
      LET m_qtd_apontar = p_w_apont_prod.qtd_boas + p_w_apont_prod.qtd_refug
      
      IF NOT manr24_cria_w_comp_baixa (1) THEN   
		   	 LET p_msg = 'NÃO FOI POSSIVEL CRIAR A TABELA W_COMP_BAIXA' 	                      	
		     RETURN FALSE                                                          	                    	                                                            
      END IF                                                                                             

      IF NOT pol1365_carrega_baixa() THEN 
         RETURN FALSE
      END IF      
      
      IF p_criticou THEN
         RETURN TRUE
      END IF
      
      IF NOT manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN   
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO ', p_cod_erro CLIPPED, ' INCLUINDO DADOS NA TABELA W_APONT_PROD'      
         RETURN FALSE
      END IF
            
      DELETE FROM man_log_apo_prod 
       WHERE empresa = p_cod_empresa
         AND ordem_producao = m_num_ordem
         
	    IF NOT manr27_processa_apontamento()  THEN 
	       LET p_criticou = TRUE
         IF NOT pol1365_le_erros() THEN
	 			    RETURN FALSE
	 			 END IF			
	 			 RETURN TRUE
	 	  ELSE
         UPDATE man_apo_logix_405 SET cod_status = 'A'
          WHERE cod_empresa  = p_programa.cod_empresa
            AND num_programa = p_programa.num_programa
            AND id_nest = l_id_nest
            AND id_man_apont = m_id_apont
            
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_msg = 'ERRO ',p_cod_erro,' ATUALIZANDO TAB MAN_APO_LOGIX_405'
            RETURN FALSE
         END IF
	    END IF 
      
      IF m_ies_atu_man THEN
         IF NOT pol1365_atu_man('N') THEN
            RETURN FALSE
         END IF
      END IF
         
   END FOREACH
         
END FUNCTION
   
#--------------------------#
FUNCTION pol1365_le_erros()#
#--------------------------#
   
   DEFINE l_erro  CHAR(500)
   
   DECLARE cq_erro CURSOR FOR 	
		SELECT texto_detalhado  	
		 	FROM man_log_apo_prod	
     WHERE empresa = p_cod_empresa
       AND ordem_producao = m_num_ordem
		  
   FOREACH cq_erro INTO l_erro	
  				
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' LENDO ERROS DA TAB MAN_LOG_APO_PROD '
         RETURN FALSE
      END IF 

      LET m_qtd_erro = m_qtd_erro + 1
      
      IF m_qtd_erro > 500 THEN
         EXIT FOREACH
      END IF
      
      LET ma_erros[m_qtd_erro].num_ordem = m_num_ordem
      LET ma_erros[m_qtd_erro].cod_item = m_cod_item
      LET ma_erros[m_qtd_erro].den_erro = l_erro 
         
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1365_cria_w_parada()#
#--------------------------------#
	
	DROP TABLE w_parada

	CREATE TEMP TABLE w_parada (
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' CRIANDO TABELA W_PARADA '
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#-------------------------------------#
FUNCTION pol1365_cria_w_alt_comp_wms()#
#-------------------------------------#
  
  DROP TABLE w_alt_comp_wms
  
  CREATE TEMP TABLE w_alt_comp_wms (
  componente     CHAR(15), 
  local_baixa    CHAR(10), 
  qtd_necessaria DEC(14,7), 
  qtd_baixa      DEC(15,3), 
  tip_movto      CHAR(1))

END FUNCTION

#-------------------------------#
FUNCTION pol1365_cria_w_compon()#
#-------------------------------#

   DROP TABLE w_compon
   
   CREATE TEMP TABLE w_compon (
   cod_item    CHAR(15), 
   qtd_movto   DEC(15,3), 
   num_docum   CHAR(10), 
   grade_1     CHAR(15), 
   grade_2     CHAR(15), 
   grade_3     CHAR(15), 
   grade_4     CHAR(15), 
   grade_5     CHAR(15))

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' CRIANDO TABELA W_COMPON '
      RETURN FALSE
   END IF 

   {INSERT INTO w_compon 
    VALUES(m_cod_compon, m_qtd_baixar, m_num_ordem, ' ', ' ', ' ', ' ', ' ')

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' INSERINDO DADOS NA TABELA W_COMPON '
      RETURN FALSE
   END IF }
      
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1365_atu_man(l_forca)#
#--------------------------------#
   
   DEFINE l_forca    CHAR(01)

	 UPDATE item_man SET ies_forca_apont = l_forca
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      let p_cod_erro = STATUS
      let p_msg = 'ATUALIZANDO DADOS DA TABELA ITEM_MAN'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1365_carrega_baixa()#																						
#-------------------------------#

   DEFINE l_compon    RECORD                                      
     cod_item_pai 		LIKE estoque_lote_ender.cod_item,         
     cod_item 		    LIKE estoque_lote_ender.cod_item,         
     num_lote 		    LIKE estoque_lote_ender.num_lote,         
     cod_local 		    LIKE estoque_lote_ender.cod_local,          
     endereco 		    LIKE estoque_lote_ender.endereco,         
     num_serie 		  	LIKE estoque_lote_ender.num_serie,          
     num_volume 		  LIKE estoque_lote_ender.num_volume,       
     comprimento		 	LIKE estoque_lote_ender.comprimento,		  
     largura 		     	LIKE estoque_lote_ender.largura, 		        
     altura 			    LIKE estoque_lote_ender.altura, 			    
     diametro 		    LIKE estoque_lote_ender.diametro, 		    
     num_peca 		    LIKE estoque_lote_ender.num_peca, 		    
     dat_producao 		DATE, 		                                
     hor_producao 		CHAR(08), 		                            
     dat_valid 		    DATE, 		                                  
     hor_valid 		    CHAR(08), 		                              
     identif_estoque 	LIKE estoque_lote_ender.identif_estoque,    
     deposit 		     	LIKE estoque_lote_ender.deposit, 		        
     qtd_transf 		  DECIMAL(15,3), 		                        
     cod_grade_1      LIKE estoque_lote_ender.cod_grade_1,       
     cod_grade_2      LIKE estoque_lote_ender.cod_grade_2,       
     cod_grade_3      LIKE estoque_lote_ender.cod_grade_3,       
     cod_grade_4      LIKE estoque_lote_ender.cod_grade_4,       
     cod_grade_5      LIKE estoque_lote_ender.cod_grade_5        
   END RECORD                                                     

   DEFINE l_dat_hor_producao LIKE estoque_lote_ender.dat_hor_producao,       
   		    l_dat_hor_validade LIKE estoque_lote_ender.dat_hor_validade,
   		    l_qtd_saldo        LIKE estoque_lote_ender.qtd_saldo,
   		    l_qtd_neces        LIKE ord_compon.qtd_necessaria,
   		    l_cod_compon       LIKE ord_compon.cod_item_compon,
   		    l_local            LIKE ord_compon.cod_local_baixa,
   		    l_baixa            CHAR(01),
   		    l_ctr_lote         CHAR(01),
   		    l_lote             CHAR(15),
   		    l_ies_chapa        CHAR(01),
   		    l_ies_tipo         CHAR(01),
   		    l_ies_situacao     CHAR(01)
   
   SELECT DISTINCT local_baixa 
     INTO l_local
     FROM man_op_componente_operacao 
    WHERE empresa = p_cod_empresa 
      AND ordem_producao = m_num_ordem
      AND item_componente = m_cod_compon
      AND sequencia_operacao = p_w_apont_prod.num_seq_operac

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'ERRO ',p_cod_erro CLIPPED, ' LENDO TABELA MAN_OP_COMPONENTE_OPERACAO '
      RETURN FALSE
   END IF       
   
   LET l_qtd_neces = (m_qtd_baixar * m_qtd_apontar) + m_qtd_sucata	
   LET l_cod_compon = m_cod_compon   
   
   DECLARE cq_lt_ender CURSOR FOR                                                          
    SELECT num_lote,                                                                          
		    cod_local,                                                                            
				endereco,                                                                            	
				num_serie,                                                                           	
				num_volume,                                                                          	
				comprimento,                                                                         	
				largura,                                                                             	
				altura,                                                                              	
				diametro,                                                                            	
				num_peca,                                                                            	
				dat_hor_producao,                                                                    	
				dat_hor_validade,                                                                    	
				identif_estoque,                                                                     	
				deposit,                                                                             	
				cod_grade_1,                                                                         	
				cod_grade_2,                                                                         	
				cod_grade_3,                                                                         	
				cod_grade_4,                                                                         	
				cod_grade_5,                                                                         	
				qtd_saldo                                                                            	
     FROM estoque_lote_ender                                                                  
		 WHERE cod_empresa = p_cod_empresa                                                        
		   AND cod_item = l_cod_compon                                                            
		   AND cod_local = l_local                                                                
		   AND ies_situa_qtd = 'L'                                                                
		   AND qtd_saldo > 0                                                                      
                                                                                           
   FOREACH cq_lt_ender INTO                                                                   
		    l_compon.num_lote,                                                                    
		    l_compon.cod_local, 		                                                               
		    l_compon.endereco, 		                                                               
		    l_compon.num_serie, 		                                                               
		    l_compon.num_volume,                                                                  
		    l_compon.comprimento,                                                                 
		    l_compon.largura, 				                                                             
		    l_compon.altura, 			                                                               
		    l_compon.diametro, 		                                                               
		    l_compon.num_peca, 		                                                               
		    l_dat_hor_producao,                                                                   
		    l_dat_hor_validade, 		                                                               
		    l_compon.identif_estoque,                                                             
		    l_compon.deposit,                                                                     
		    l_compon.cod_grade_1,                                                                 
		    l_compon.cod_grade_2,                                                                 
		    l_compon.cod_grade_3,                                                                 
		    l_compon.cod_grade_4,                                                                 
		    l_compon.cod_grade_5,                                                                 
		    l_qtd_saldo                                                                           
                                                                                           				                                                                                     	
      IF STATUS <> 0 THEN                                                                     
         LET p_cod_erro = STATUS                                                              
         LET p_msg = 'ERRO ',p_cod_erro CLIPPED,' LENDO CURSOR CQ_LT_ENDER'                   
         RETURN FALSE                                                                         
      END IF		                                                                              
                                                                                           
      IF l_qtd_saldo < l_qtd_neces THEN                                                       
         LET l_compon.qtd_transf = l_qtd_saldo                                                
         LET l_qtd_neces = l_qtd_neces - l_qtd_saldo                                          
      ELSE                                                                                    
         LET L_compon.qtd_transf = l_qtd_neces                                                
         LET l_qtd_neces = 0                                                                  
      END IF                                                                                  
                                                                                           
      LET l_compon.cod_item_pai = m_cod_item                                                  
	    LET l_compon.cod_item = l_cod_compon                                                    
	                                                                                            
	    LET l_compon.dat_producao = EXTEND(l_dat_hor_producao, YEAR TO DAY)                     
      LET l_compon.hor_producao = EXTEND(l_dat_hor_producao, HOUR TO SECOND)                  
      LET l_compon.dat_valid    = EXTEND(l_dat_hor_validade, YEAR TO DAY)                     
 	    LET l_compon.hor_valid    = EXTEND(l_dat_hor_validade, HOUR TO SECOND)                  
                                                                                           
      INSERT INTO w_comp_baixa                                                                
      	VALUES (l_compon.*)                                                                   
      	                                                                                      
      IF STATUS <> 0 THEN                                                                     
	       LET p_cod_erro = STATUS                                                              
	       LET p_msg = 'ERRO ',p_cod_erro CLIPPED,' INSERINDO DADOS NA TABELA W_COMP_BAIXA'     
	    	  RETURN FALSE                                                                        
      END IF	                                                                                
                                                                                              
      IF l_qtd_neces <= 0 THEN                                                                
         EXIT FOREACH                                                                         
      END IF                                                                                  
                                                                                              
   END FOREACH                                                                                
                                                                                              
   IF l_qtd_neces > 0 THEN                                                                    
      LET p_msg = 'ITEM ',l_cod_compon CLIPPED, ' LOCAL ',l_local CLIPPED,
                  ' SEM SALDO SUFICIENTE P/ CONSUMIR '  
      LET m_qtd_erro = m_qtd_erro + 1
      
      IF m_qtd_erro <= 500 THEN
         LET ma_erros[m_qtd_erro].num_ordem = m_num_ordem
         LET ma_erros[m_qtd_erro].cod_item = m_cod_item
         LET ma_erros[m_qtd_erro].den_erro = p_msg 
      END if   
      
      LET p_criticou = TRUE
      RETURN TRUE                                                                            
   END IF                                                                                     

   SELECT cod_local_estoq
     INTO m_local_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_sucata
	        
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
	    LET p_msg = 'ERRO: ',p_cod_erro CLIPPED, ' LENDO TAB ITEM:SUCATA'
	    RETURN FALSE
	 END IF

   LET l_compon.qtd_transf = m_qtd_sucata * (-1)                                           
                                                                                                 
   LET l_compon.cod_item_pai = m_cod_item                                                  
   LET l_compon.cod_item = m_cod_sucata                                                          
	 LET l_compon.cod_local = m_local_sucata                                                             
                                                                                           	     
   INSERT INTO w_comp_baixa                                                                
   	VALUES (l_compon.*)                                                                          
   	                                                                                             
   IF STATUS <> 0 THEN                                                                           
      LET p_cod_erro = STATUS                                                                    
	    LET p_msg = 'ERRO ',p_cod_erro CLIPPED,' INSERINDO DADOS NA TABELA W_COMP_BAIXA:suc'       
	 	  RETURN FALSE                                                                               
	 END IF	                                                                                       
       
   RETURN TRUE
				
END FUNCTION
     

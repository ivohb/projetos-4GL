#-------------------------------------------------------------------#
# PROGRAMA: pol1093                                                 #
# OBJETIVO: gera OPs ap�s gera��o do MRP Logix                      #
# CLIENTE.: POLIMETRI                                               #
# DATA....: 17/03/2011                                              #
# POR.....: Paulo Cesar Martinez    BL                              #
# DATA   ALTERA��O                                                  #
#
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(300),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT,
         p_query_num_o        CHAR(750),
         p_qry_ordem          CHAR(900),
         p_query              CHAR(800),
         p_erro               CHAR(10)

   DEFINE p_txt_aux           CHAR(30),
          p_dat_liberac       DATE,
          p_dat_abertura      DATE

   DEFINE p_parametros        LIKE par_pcp.parametros,
          p_cod_lin_prod      LIKE item.cod_lin_prod, 
          p_cod_lin_recei     LIKE item.cod_lin_recei,       
          p_cod_seg_merc      LIKE item.cod_seg_merc,        
          p_cod_cla_uso       LIKE item.cod_cla_uso,
          p_num_ordem         LIKE ordens.num_ordem,
          p_num_ordem_prx     LIKE ordens.num_ordem,
          p_num_neces         LIKE ordens.num_neces,
          p_dat_entrega       LIKE ordens.dat_entrega,
          p_qtd_planej        LIKE ordens.qtd_planej, 
          p_cod_item          LIKE item.cod_item,
          p_cod_item_pai      LIKE item.cod_item,
          p_prz_entrega       LIKE ped_dem.prz_entrega,
          p_cod_local_estoq   LIKE ordens.cod_local_estoq,
          p_cod_local_prod    LIKE ordens.cod_local_prod,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_qtd_dias_horizon  LIKE horizonte.qtd_dias_horizon,
          p_cod_cent_trab     LIKE ord_compon.cod_cent_trab,
          p_ies_tip_item      LIKE item.ies_tip_item
                   
   
   DEFINE p_ordens            RECORD LIKE ordens.*,
          p_necessidades      RECORD LIKE necessidades.*,
          p_ord_compon        RECORD LIKE ord_compon.*,
          p_ord_oper          RECORD LIKE ord_oper.*,
          p_item_man          RECORD LIKE item_man.*

   DEFINE p_ped_dem           RECORD 
          cod_empresa         CHAR(2),          
          num_projeto         CHAR(08),         
          num_pedido          DECIMAL(6,0),     
          num_seq             DECIMAL(3,0),     
          cod_item_pai        CHAR(15),         
          num_op_pai          INTEGER,          
          prz_entrega         DATE,             
          qtd_saldo           DECIMAL(10,3)     
   END RECORD
   
   DEFINE p_item_ordem        RECORD
          num_ordem           INTEGER, 
          cod_item            CHAR(15),          
          cod_item_pai        CHAR(15),         
          qtd_planej          DECIMAL(17,6),
          dat_entrega         DATE,
          dat_abert           DATE,
          dat_liberac         DATE,
          ies_origem          CHAR(1),
          p_qtd_necessaria    DECIMAL(10,3),          
          cod_local_estoq     CHAR(10),
          cod_local_prod      CHAR(10)
   END RECORD

   DEFINE p_tela              RECORD
          dat_ini             DATE,
          dat_fim             DATE
   END RECORD
   
END GLOBALS
          
MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol1093-12.00.03"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 15
   DEFER INTERRUPT

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1093_controle()
   END IF
END MAIN
   
#-------------------------#
FUNCTION pol1093_controle()
#-------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1093") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1093 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1093_cria_tab_tmp() THEN
      RETURN FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros para o processamento"
         IF pol1093_entrada_dados() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Opera��o cancelada !!!'
         END IF
      COMMAND "Processar"  "Processa a gera��o das ordens de produ��o"
         IF p_ies_cons THEN
            CALL pol1093_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Opera��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
               CALL pol1093_limpa_tela()
            END IF
            LET p_ies_cons = FALSE
            NEXT OPTION 'Fim'
         ELSE
            ERROR 'Informe os par�metros previamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1093_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1093

END FUNCTION
 
#-----------------------#
 FUNCTION pol1093_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1093_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL

END FUNCTION

#------------------------------#
FUNCTION pol1093_cria_tab_tmp()
#------------------------------#

   DROP TABLE ops_tmp_5000
   
   CREATE TEMP TABLE ops_tmp_5000 (
      num_op INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','ops_tmp_5000')
      RETURN FALSE
   END IF
   
   DROP TABLE neces_tmp_5000
   
   CREATE TEMP TABLE neces_tmp_5000 (
      num_neces INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','neces_tmp_5000')
      RETURN FALSE
   END IF

   LET p_msg = 'ops_consolid_454'

   IF NOT log0150_verifica_se_tabela_existe(p_msg) THEN
      CREATE TABLE ops_consolid_454 (
         cod_empresa   CHAR(02) not null,
         num_ordem     INTEGER not null
      );

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' criando\n',
                      'tabela ops_consolid_454.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF

      CREATE UNIQUE INDEX ops_consolid_454
         ON ops_consolid_454(cod_empresa, num_ordem);
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' criando indice\n',
                      'para a tabela ops_consolid_454.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   END IF      
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1093_entrada_dados()
#-------------------------------#
 
   CALL pol1093_limpa_tela()
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

   AFTER INPUT
     IF INT_FLAG THEN
        CALL pol1093_limpa_tela()
        RETURN FALSE
     ELSE
        IF p_tela.dat_ini IS NULL THEN
           ERROR "Data inicial deve ser preenchida."
           NEXT FIELD dat_ini
        END IF
        IF p_tela.dat_fim IS NULL THEN
           ERROR "Data final deve ser preenchida."
           NEXT FIELD dat_fim
        END IF
        IF p_tela.dat_fim < p_tela.dat_ini THEN
           ERROR "Data final deve ser maior ou igual a inicial."
           NEXT FIELD dat_ini
        END IF
     END IF

   END INPUT

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1093_cria_tmp()#
#--------------------------#

   DROP TABLE numero_tmp
   
   CREATE TEMP TABLE numero_tmp(
      cod_empresa    CHAR(02),
	    num_ordem      INTEGER
	 )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","numero_tmp")
			RETURN FALSE
	 END IF

   DROP TABLE itens_tmp
   
   CREATE TEMP  TABLE itens_tmp(
	    cod_item        CHAR(15),
	    qtd_planej      DECIMAL(17,6)
	 )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","itens_tmp")
			RETURN FALSE
	 END IF
	 
	 RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1093_processar()
#---------------------------#

   IF NOT log004_confirm(16,32) THEN
      RETURN FALSE
   END IF
   
   SELECT parametros
     INTO p_parametros 
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT","PAR_PCP")
      RETURN FALSE
   END IF
   
   IF NOT pol1093_cria_tmp() THEN
      RETURN FALSE
   END IF   
   
   IF NOT pol1093_coleta_itens() THEN
      RETURN FALSE
   END IF   

   IF NOT pol1093_proces_mrp() THEN
      RETURN FALSE
   END IF
   

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1093_bloqueia_tab()
#------------------------------#

   LOCK TABLE ped_dem IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Bloqueando','ped_dem')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1093_monta_select()
#------------------------------#
   
   INITIALIZE p_query TO NULL

   LET p_query = 
       " select cod_item,cod_item_pai,round(sum(qtd_planej),6) qtd_planej ",
       " from ordens ",
       " where ies_situa = '1'"

   LET p_query = p_query CLIPPED," AND cod_empresa = '",p_cod_empresa,"'"

   LET p_query = p_query CLIPPED,
       " AND dat_entrega between '",p_tela.dat_ini,"'",
       " AND '",p_tela.dat_fim,"'"

   LET p_query = p_query CLIPPED,
       " GROUP BY cod_item, cod_item_pai order BY cod_item, cod_item_pai" 

END FUNCTION

#--------------------------#
FUNCTION pol1093_le_ordens()
#---------------------------#
   
   DEFINE p_num_ordem INTEGER
   
   INITIALIZE p_query_num_o TO NULL
   DELETE FROM numero_tmp

   DECLARE cq_num_ordem CURSOR FOR 
     SELECT num_ordem 
       FROM ordens 
      WHERE cod_empresa = p_cod_empresa
        AND ies_situa = '1'
        AND dat_entrega >= p_tela.dat_ini
        AND dat_entrega <= p_tela.dat_fim
        AND cod_item = p_cod_item
        AND num_ordem NOT IN
            (SELECT num_ordem FROM ops_consolid_454
              WHERE cod_empresa = ordens.cod_empresa)

   FOREACH cq_num_ordem INTO p_num_ordem
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_num_ordem')
         RETURN FALSE
      END IF
      
      INSERT INTO numero_tmp VALUES(p_cod_empresa, p_num_ordem)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','numero_tmp')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1093_le_aen()
#------------------------#

   DEFINE p_projeto CHAR(10)
   
   SELECT cod_lin_prod,                          
          cod_lin_recei,                            
          cod_seg_merc,                             
          cod_cla_uso                               
     INTO p_cod_lin_prod,                           
          p_cod_lin_recei,                          
          p_cod_seg_merc,                           
          p_cod_cla_uso                             
     FROM item                                      
    WHERE cod_empresa = p_cod_empresa               
      AND cod_item    = p_cod_item                  
                                                 
   IF STATUS <> 0 THEN      
      LET p_projeto = NULL                        
      CALL log003_err_sql('Lendo','item:AEN')       
   ELSE                                                    
      LET p_projeto =                      
          p_cod_lin_prod  USING '&&',               
          p_cod_lin_recei USING '&&',               
          p_cod_seg_merc  USING '&&',               
          p_cod_cla_uso   USING '&&'                
   END IF
   
   RETURN(p_projeto)

END FUNCTION

#------------------------------#
FUNCTION pol1093_coleta_itens()#
#------------------------------#

   DECLARE cq_gera CURSOR WITH HOLD FOR 
    SELECT cod_item, 
           round(SUM(qtd_planej),6)
    FROM ordens 
   WHERE cod_empresa = p_cod_empresa
     AND ies_situa = '1'
     AND dat_entrega >= p_tela.dat_ini
     AND dat_entrega <= p_tela.dat_fim
     AND num_ordem NOT IN
         (SELECT ops_consolid_454.num_ordem FROM ops_consolid_454
           WHERE ops_consolid_454.cod_empresa = ordens.cod_empresa)
   GROUP BY cod_item
   
   FOREACH cq_gera INTO 
           p_cod_item,
           p_qtd_planej

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_gera')
         RETURN FALSE
      END IF
      
      IF p_qtd_planej <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      INSERT INTO itens_tmp
        VALUES(p_cod_item, p_qtd_planej)
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','ITENS_TMP')
         RETURN FALSE
      END IF
            
   END FOREACH
      
   RETURN TRUE

END FUNCTION
      


#----------------------------#
FUNCTION pol1093_proces_mrp()
#----------------------------#

   DEFINE p_proces SMALLINT
   

   LET p_proces = FALSE
   
   DECLARE cq_gera CURSOR WITH HOLD FOR 
    SELECT cod_item, 
           qtd_planej
    FROM itens_tmp
   
   FOREACH cq_gera INTO 
           p_cod_item,
           p_qtd_planej

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_gera')
         RETURN FALSE
      END IF
      
      IF p_item_ordem.qtd_planej <= 0 THEN
         CONTINUE FOREACH
      END IF

      LET p_cod_item_pai = '0'

      LET p_proces = TRUE

      LET p_item_ordem.qtd_planej   = p_qtd_planej
      LET p_item_ordem.cod_item     = p_cod_item
      LET p_item_ordem.cod_item_pai = p_cod_item_pai
      
#----- Levanto todos os numeros de ordem que utilizam este item dentro do periodo selecionado
   		
   		IF NOT pol1093_le_ordens() THEN
   		   RETURN FALSE
   		END IF

      CALL log085_transacao("BEGIN")
      
      IF NOT pol1093_gera_op() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF      

      CALL log085_transacao("COMMIT")
      
   END FOREACH
   
   IF NOT p_proces THEN
      LET p_msg = 'N�o h� dados a serem processados, \n',
                  'para os par�metros informados!\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
      
#----------------------------#
FUNCTION pol1093_del_ordens()
#----------------------------#

   IF NOT pol1074_ins_op() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 1
      
   WHILE p_count > 0

      DECLARE cq_temp_op CURSOR FOR
       SELECT num_op FROM ops_tmp_5000
      
      FOREACH cq_temp_op INTO p_num_ordem
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_ops')  
            RETURN FALSE
         END IF
         
         DECLARE cq_le_neces CURSOR FOR
          SELECT num_neces 
            FROM necessidades
           WHERE cod_empresa = p_cod_empresa
             AND num_ordem   = p_num_ordem
         
         FOREACH cq_le_neces INTO p_num_neces

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_ops')  
               RETURN FALSE
            END IF
            
            IF NOT pol1093_ins_neces_tmp() THEN
               RETURN FALSE
            END IF
         
         END FOREACH

                  
      END FOREACH
      
      IF NOT pol1093_del_ops_tmp() THEN
         RETURN FALSE
      END IF
      
      LET p_count = 0
      
      DECLARE cq_neces_temp CURSOR FOR
       SELECT num_neces FROM neces_tmp_5000
      
      FOREACH cq_neces_temp INTO p_num_neces

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_neces_temp')  
            RETURN FALSE
         END IF
      
         SELECT num_ordem
           INTO p_num_ordem
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_neces   = p_num_neces

         IF STATUS = 0 THEN
            IF NOT pol1074_ins_op() THEN
               RETURN FALSE
            END IF
            LET p_count = 1
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('Lendo','cq_neces_temp')  
               RETURN FALSE
            END IF
         END IF
         
      END FOREACH

      IF NOT pol1093_del_neces_tmp() THEN
         RETURN FALSE
      END IF
      
   END WHILE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1093_del_neces_tmp()
#------------------------------#

   DELETE FROM neces_tmp_5000
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','neces_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1093_del_ops_tmp()
#------------------------------#

   DELETE FROM ops_tmp_5000 
                  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ops_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1093_ins_neces_tmp()
#------------------------------#

   INSERT INTO neces_tmp_5000 VALUES(p_num_neces)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','neces_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1074_ins_op()
#------------------------#

   INSERT INTO ops_tmp_5000 VALUES(p_num_ordem)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ops_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

 
#-----------------------------#
FUNCTION pol1093_del_ped_dem()
#-----------------------------#

   LET p_ped_dem.num_projeto = pol1093_le_aen()
      
   IF p_ped_dem.num_projeto IS NULL THEN
      RETURN FALSE
   END IF

   DELETE FROM ped_dem
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_dem.num_projeto
      AND cod_item    = p_cod_item
      AND prz_entrega = p_prz_entrega

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ped_dem')
      RETURN FALSE
   END IF

   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1093_ins_ped_dem()
#-----------------------------#

   INSERT INTO ped_dem
    VALUES(p_ped_dem.cod_empresa,
           p_ped_dem.num_projeto,
           p_ped_dem.cod_item_pai,
           p_ped_dem.prz_entrega,
           p_ped_dem.qtd_saldo)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ped_dem')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1093_le_item_man()
#-----------------------------#

   SELECT *
     INTO p_item_man.*
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1093_le_horizonte()
#------------------------------#

   SELECT qtd_dias_horizon
     INTO p_qtd_dias_horizon
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_item_man.cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1093_le_item()
#-------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF

   IF p_cod_local_estoq IS NULL THEN
      LET p_cod_local_estoq = ' ' 
   END IF
   
  RETURN TRUE
  
END FUNCTION
#------------------------#
FUNCTION pol1093_gera_op()
#------------------------#

   INSERT INTO ops_consolid_454
     SELECT * FROM numero_tmp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'ops_consolid_454')
      RETURN FALSE
   END IF
   
   IF NOT pol1093_ins_ordem() THEN
      RETURN FALSE
   END IF

   IF NOT pol1093_ins_roteiro() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1093_ins_necessidades() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1093_ins_ordem()
#---------------------------#

   DEFINE p_op_compl RECORD LIKE ordens_complement.*

   IF NOT pol1093_prx_num_op() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1093_le_item_man() THEN
      RETURN FALSE
   END IF

   IF NOT pol1093_le_horizonte() THEN
      RETURN FALSE
   END IF

   IF NOT pol1093_le_item() THEN
      RETURN FALSE
   END IF
   
	IF NOT pol1093_pega_dados() THEN
			RETURN FALSE
	END IF		


   LET p_dat_liberac = p_item_ordem.dat_liberac
   LET p_dat_abertura = p_item_ordem.dat_abert
      
   INITIALIZE p_ordens TO NULL

   LET p_ordens.cod_empresa        = p_cod_empresa
   LET p_ordens.num_ordem          = p_num_ordem
   LET p_ordens.num_neces          = 0
   LET p_ordens.num_versao         = 0
   LET p_ordens.cod_item           = p_cod_item
   LET p_ordens.cod_item_pai       = p_cod_item_pai
   LET p_ordens.dat_entrega        = p_item_ordem.dat_entrega
   LET p_ordens.dat_liberac        = p_dat_liberac
   LET p_ordens.dat_abert          = p_dat_abertura 
   LET p_ordens.qtd_planej         = p_qtd_planej
   LET p_ordens.pct_refug          = 0
   LET p_ordens.qtd_boas           = 0
   LET p_ordens.qtd_refug          = 0
   LET p_ordens.qtd_sucata         = 0
   LET p_ordens.cod_local_prod     = p_item_ordem.cod_local_prod
   LET p_ordens.cod_local_estoq    = p_item_ordem.cod_local_estoq
   LET p_ordens.num_docum          = '0'
   LET p_ordens.ies_lista_ordem    = p_item_man.ies_lista_ordem
   LET p_ordens.ies_lista_roteiro  = p_item_man.ies_lista_roteiro
   LET p_ordens.ies_origem         = p_item_ordem.ies_origem
   LET p_ordens.ies_situa          = '4'
   LET p_ordens.ies_abert_liber    = p_item_man.ies_abert_liber
   LET p_ordens.ies_baixa_comp     = p_item_man.ies_baixa_comp
   LET p_ordens.ies_apontamento    = p_item_man.ies_apontamento
   LET p_ordens.dat_atualiz        = TODAY
   LET p_ordens.num_lote           = p_num_ordem
   LET p_ordens.cod_roteiro        = p_item_man.cod_roteiro
   LET p_ordens.num_altern_roteiro = p_item_man.num_altern_roteiro

   INSERT INTO ordens VALUES (p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','Ordens')
      RETURN FALSE
   END IF

   INITIALIZE p_op_compl  TO NULL

   LET p_op_compl.cod_empresa    = p_ordens.cod_empresa
   LET p_op_compl.num_ordem      = p_ordens.num_ordem
   LET p_op_compl.cod_grade_1    = " "
   LET p_op_compl.cod_grade_2    = " "
   LET p_op_compl.cod_grade_3    = " "
   LET p_op_compl.cod_grade_4    = " "
   LET p_op_compl.cod_grade_5    = " "
   LET p_op_compl.num_lote       = p_ordens.num_lote
   LET p_op_compl.ies_tipo       = "N"
   LET p_op_compl.num_prioridade = 9999

   INSERT INTO ordens_complement VALUES (p_op_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','ordens_complement')
      RETURN  FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1093_prx_num_op()
#----------------------------#

   SELECT prx_num_ordem
     INTO p_num_ordem
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_op')
      RETURN FALSE
   END IF

   IF p_num_ordem IS NULL THEN
      LET p_num_ordem = 1
   END IF

   LET p_num_ordem_prx = p_num_ordem + 1
   LET p_num_ordem = p_num_ordem + 1

   UPDATE par_mrp
      SET prx_num_ordem = p_num_ordem_prx
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_op')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1093_ins_roteiro()
#-----------------------------#

   DEFINE p_tem_roteiro  SMALLINT,
          l_seq_processo INTEGER
   
   DEFINE
          l_tipo              char(01),
          l_linha             integer,
          l_texto             char(70),
          l_seq               integer,
          l_compon            char(15),
          l_qtd_neces         decimal(10,3),
          l_pct_refugo        decimal(5,2),
          l_ies_tip_item      char(01)
   
   LET p_tem_roteiro = FALSE
   LET p_cod_cent_trab = NULL

 	DECLARE cq_roteiro CURSOR FOR 
    SELECT seq_operacao, 
           operacao, 
           centro_trabalho, 
           arranjo, 
           centro_custo, 
           qtd_tempo, 
           qtd_tempo_setup, 
           seq_processo, 
           apontar_operacao, 
           imprimir_operacao, 
           operacao_final, 
           pct_retrabalho, 
           qtd_tempo,
		       item
      FROM man_processo_item
        WHERE empresa         = p_cod_empresa
          AND item            = p_ordens.cod_item
          AND roteiro         = p_ordens.cod_roteiro
          AND roteiro_alternativo  = p_ordens.num_altern_roteiro
          AND ((validade_inicial IS NULL AND validade_final IS NULL)
           OR  (validade_inicial IS NULL AND validade_final >= p_dat_liberac)
           OR  (validade_final IS NULL AND validade_inicial <= p_dat_liberac)
           OR  (p_dat_liberac BETWEEN validade_inicial AND validade_final))
      
   FOREACH cq_roteiro INTO 
           p_ord_oper.num_seq_operac,
           p_ord_oper.cod_operac,
           p_ord_oper.cod_cent_trab,
           p_ord_oper.cod_arranjo,
           p_ord_oper.cod_cent_cust,
           p_ord_oper.qtd_horas,
           p_ord_oper.qtd_horas_setup,
           l_seq_processo,
           p_ord_oper.ies_apontamento,
           p_ord_oper.ies_impressao,
           p_ord_oper.ies_oper_final,
           p_ord_oper.pct_refug,
           p_ord_oper.tmp_producao,
           p_ord_oper.cod_item


      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','man_processo_item')
         RETURN FALSE
      END IF

       LET p_ord_oper.num_processo = l_seq_processo USING '<<<<<<<'
                 
      LET p_tem_roteiro = TRUE
      
      IF p_cod_cent_trab IS NULL THEN
         LET p_cod_cent_trab = p_ord_oper.cod_cent_trab
      END IF
      
      LET p_ord_oper.cod_empresa   = p_cod_empresa
      LET p_ord_oper.num_ordem     = p_ordens.num_ordem
      LET p_ord_oper.cod_item      = p_ordens.cod_item
      LET p_ord_oper.dat_entrega   = p_ordens.dat_entrega
#      LET p_ord_oper.dat_inicio    = p_ordens.dat_ini
      LET p_ord_oper.qtd_planejada = p_ordens.qtd_planej
      LET p_ord_oper.qtd_boas      = p_ordens.qtd_boas  
      LET p_ord_oper.qtd_refugo    = p_ordens.qtd_refug
      LET p_ord_oper.qtd_sucata    = p_ordens.qtd_sucata 
      LET p_ord_oper.seq_processo  = 0

         INSERT INTO ord_oper(
            cod_empresa,
            num_ordem,
            cod_item,
            cod_operac,
            num_seq_operac,
            cod_cent_trab,
            cod_arranjo,
            cod_cent_cust,
            dat_entrega,
            dat_inicio,
            qtd_planejada,
            qtd_boas,
            qtd_refugo,
            qtd_sucata,
            qtd_horas,
            qtd_horas_setup,
            ies_apontamento,
            ies_impressao,
            ies_oper_final,
            pct_refug,
            tmp_producao,
            num_processo,
            seq_processo)                                     
         VALUES(p_ord_oper.*)
                    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','ord_oper')
         RETURN FALSE
      END IF

      SELECT COUNT(*) INTO p_count FROM man_oper_compl
       WHERE empresa = p_cod_empresa
         AND ordem_producao = p_ord_oper.num_ordem
         AND operacao = p_ord_oper.cod_operac
         AND sequencia_operacao = p_ord_oper.num_seq_operac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','man_oper_compl')
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN
         INSERT INTO man_oper_compl(
                empresa,
                ordem_producao,
                operacao,
                sequencia_operacao)
         VALUES (p_cod_empresa,
                 p_ord_oper.num_ordem,
                 p_ord_oper.cod_operac,
                 p_ord_oper.num_seq_operac)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','man_oper_compl')
            RETURN FALSE
         END IF
      END IF

      DECLARE cq_cons_txt CURSOR WITH HOLD FOR
       SELECT tip_texto, 
              seq_texto_processo,
              texto_processo[1,70]
         FROM man_texto_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = l_seq_processo            
            
      FOREACH cq_cons_txt INTO l_tipo, l_linha, l_texto

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_texto_processo')
            RETURN FALSE
         END IF            
               
         INSERT INTO ord_oper_txt 
          VALUES (p_cod_empresa,
                  p_ord_oper.num_ordem,                                      
                  p_ord_oper.num_processo,                              
                  l_tipo,                                  
                  l_linha,                             
                  l_texto,NULL)                              
               

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','ord_oper_txt')
             RETURN FALSE
         END IF
          
      END FOREACH
            
      DECLARE cq_estr_oper CURSOR WITH HOLD FOR
       SELECT seq_componente,
              item_componente, 
              qtd_necessaria, 
              pct_refugo 
         FROM man_estrutura_operacao
        WHERE empresa      = p_cod_empresa 
          AND item_pai     = p_ordens.cod_item
          AND seq_processo = l_seq_processo            

      FOREACH cq_estr_oper INTO l_seq, l_compon, l_qtd_neces, l_pct_refugo
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_estrutura_operacao')
            RETURN FALSE
         END IF
            
         SELECT ies_tip_item
           INTO l_ies_tip_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = l_compon
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_estrutura_operacao')
            RETURN FALSE
         END IF
            
         INSERT INTO man_op_componente_operacao 
          VALUES (p_cod_empresa,
                  p_ordens.num_ordem,                                                              
                  p_ordens.cod_roteiro ,                                                           
                  p_ordens.num_altern_roteiro,                                                     
                  p_ord_oper.num_seq_operac,                                           
                  p_ordens.cod_item,                                                         
                  l_compon,                                               
                  l_ies_tip_item,                                                  
                  p_ordens.dat_entrega,                                                            
                  l_qtd_neces,                                                    
                  p_ordens.cod_local_prod,                                                         
                  p_ord_oper.cod_cent_cust,                                                                              
                  l_pct_refugo,                                                    
                  l_seq,
                  l_seq_processo)     
                                                                                       
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','man_op_componente_operacao')
            RETURN FALSE
         END IF
               
      END FOREACH  
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1093_ins_necessidades()
#-------------------------------------#

   DEFINE p_cod_item_compon LIKE estrutura.cod_item_compon, 
          p_qtd_necessaria  LIKE estrutura.qtd_necessaria,  
          p_pct_refug       LIKE estrutura.pct_refug,
          p_tem_strut       SMALLINT,
          p_num_sequencia   INTEGER

   INITIALIZE p_necessidades TO NULL     

   LET p_tem_strut = FALSE           
   
   DECLARE cq_neces CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug,
           num_sequencia
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
     ORDER BY num_sequencia

   FOREACH cq_neces INTO 
           p_cod_item_compon, 
           p_qtd_necessaria,  
           p_pct_refug,
           p_num_sequencia       
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_grade')
         RETURN FALSE
      END IF
      
      LET p_tem_strut = TRUE
      
      If Not Pol1093_Prx_Num_Neces() Then                                          
         Return False                                                              
      End If     
      
      LET p_qtd_necessaria = p_qtd_necessaria + (p_qtd_necessaria * p_pct_refug / 100)                                                                 
                                                                                   
      LET p_necessidades.cod_empresa      = p_ordens.cod_empresa                   
      LET p_necessidades.num_neces        = p_num_neces                        
      LET p_necessidades.num_versao       = p_ordens.num_versao                    
      LET p_necessidades.cod_item_pai     = p_ordens.cod_item                      
      LET p_necessidades.cod_item         = p_cod_item_compon                      
      LET p_necessidades.qtd_necessaria   = p_ordens.qtd_planej * p_qtd_necessaria
      LET p_necessidades.num_ordem        = p_ordens.num_ordem                     
      LET p_necessidades.qtd_saida        = 0                                      
      LET p_necessidades.num_docum        = 0                     
      LET p_necessidades.dat_neces        = p_ordens.dat_entrega                   
      LET p_necessidades.ies_origem       = 3                    
      LET p_necessidades.ies_situa        = 4                     
      LET p_necessidades.num_neces_consol = 0                                      

      {SELECT SUM(qtd_necessaria) 
        INTO p_necessidades.qtd_necessaria 
        FROM necessidades 
       WHERE cod_empresa = p_cod_empresa 
         AND num_ordem in (SELECT num_ordem FROM numero_tmp)
         AND cod_item = p_necessidades.cod_item
       GROUP BY ies_situa}

                                                                                   
      INSERT INTO necessidades  VALUES (p_necessidades.*)                         
                                                                                   
      IF sqlca.sqlcode <> 0 THEN                                                   
         CALL log003_err_sql('Inserindo','Necessidades')                           
         RETURN FALSE                                                              
      END IF         

      INSERT INTO neces_complement (
        cod_empresa, 
        num_neces, 
        cod_grade_1, 
        cod_grade_2, 
        cod_grade_3, 
        cod_grade_4, 
        cod_grade_5, 
        ordem_producao_pai,
        sequencia_it_operacao, 
        seq_processo) 
      VALUES(p_necessidades.cod_empresa, 
             p_necessidades.num_neces ,' ',' ',' ',' ',' ',NULL, 0, 0)

      IF sqlca.sqlcode <> 0 THEN                                                   
         CALL log003_err_sql('Inserindo','NECES_COMPLEMENT')                           
         RETURN FALSE                                                              
      END IF         

      SELECT ies_tip_item
        INTO p_ies_tip_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_compon
         
      IF sqlca.sqlcode <> 0 THEN                                                   
         CALL log003_err_sql('Lendo','item:tipo')                           
         RETURN FALSE                                                              
      END IF         

      	INSERT INTO ord_compon(
         	cod_empresa,      
         	num_ordem,        
         	cod_item_pai,     
         	cod_item_compon,  
         	ies_tip_item,     
         	dat_entrega,      
         	qtd_necessaria,   
         	cod_local_baixa,  
         	cod_cent_trab,    
         	pct_refug) VALUES(  
                     p_necessidades.cod_empresa,
                     p_necessidades.num_ordem,
                     p_necessidades.num_neces,
                     p_necessidades.cod_item,
                     p_ies_tip_item,
                     p_necessidades.dat_neces,
                     p_qtd_necessaria,
                     p_ordens.cod_local_prod,
                     p_cod_cent_trab,
                     p_pct_refug)
   
      		IF sqlca.sqlcode <> 0 THEN                                                   
         		CALL log003_err_sql('Inserindo','ord_compon')                           
         		RETURN FALSE                                                              
      		END IF
      
   END FOREACH       

   IF NOT p_tem_strut THEN
      LET p_msg = 'Item ', p_cod_item CLIPPED, ' sem estrutura!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1093_prx_num_neces()
#-------------------------------#

   SELECT prx_num_neces
     INTO p_num_neces
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_neces')
      RETURN FALSE
   END IF

   IF p_num_neces IS NULL THEN
      LET p_num_neces = 1
   END IF
   
   LET p_num_neces = p_num_neces + 1
   
   
   UPDATE par_mrp
      SET prx_num_neces = p_num_neces
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_neces')
      RETURN FALSE
   END IF
   
#   LET p_num_neces = p_num_neces
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1093_pega_dados()
#-----------------------------#

#----- Pego alguns dados da OP com menor data de entrega
	DECLARE cq_data CURSOR FOR 
  SELECT num_ordem, dat_entrega, dat_abert, dat_liberac, cod_local_prod, cod_local_estoq, ies_origem 
    FROM ordens
  	WHERE ies_situa = '1'
      AND cod_empresa = p_cod_empresa
      AND num_ordem IN (SELECT num_ordem FROM numero_tmp)
    ORDER BY dat_entrega
       
	FOREACH cq_data INTO 
  	p_item_ordem.num_ordem, p_item_ordem.dat_entrega, 
  	p_item_ordem.dat_abert, p_item_ordem.dat_liberac, 
  	p_item_ordem.cod_local_prod, p_item_ordem.cod_local_estoq,
  	p_item_ordem.ies_origem 
       
    EXIT FOREACH
  END FOREACH
   
  RETURN TRUE
   
END FUNCTION


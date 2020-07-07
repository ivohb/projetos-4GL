#------------------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O DO LOGIX x EGA - MAN912                                 #
# PROGRAMA: pol0455                                                            #
# OBJETIVO: EXPORTA��O DO LOGIX x EGA                                          #
# AUTOR...: IVO H BARBOSA             R                                        #
# DATA....: 11/11/2005                                                         #
# ALTERADO: 12/12/2006 por ANA PAULA                                           #
#------------------------------------------------------------------------------#
 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_cod_item             LIKE item.cod_item,
          p_num_ordem            LIKE ordens.num_ordem,
          m_num_ordem            LIKE ordens.num_ordem,
          p_dat_abert            LIKE ordens.dat_abert,
          p_status               SMALLINT,
          p_qtd_pc_geme          SMALLINT,
          p_pc_por_oper          INTEGER,
          p_pc_hora              INTEGER,
          p_tmp_ciclo            INTEGER,
          l_ies_situacao         CHAR(01),
          p_msg                  CHAR(500)

   DEFINE l_relat                SMALLINT,
          l_cont                 INTEGER,
          l_cod_arranjo          LIKE rec_arranjo.cod_arranjo,
          l_cod_recur            LIKE rec_arranjo.cod_recur,
          l_cod_operac           LIKE ord_oper.cod_operac,
          p_dat_ini              DATE,
          p_qtd_planej             LIKE ordens.qtd_planej,
          p_hor_ini              DATETIME HOUR TO SECOND,
          p_dat_aux              CHAR(10),
          p_hor_aux              CHAR(08),
          p_dat_oper             CHAR(08),
          p_hor_oper             CHAR(06),
          p_index                SMALLINT,
          s_index                SMALLINT
          

   DEFINE p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_nom_arquivo_back     CHAR(100),
          g_usa_visualizador     SMALLINT

   DEFINE g_ies_grafico          SMALLINT

#    DEFINE p_versao               CHAR(17) 
    DEFINE p_versao               CHAR(18)


   DEFINE pr_op      ARRAY[900] OF RECORD
          num_ordem  LIKE ordens.num_ordem,
          ies_situa  LIKE ordens.ies_situa,
          cod_item   LIKE ordens.cod_item,
          qtd_saldo  LIKE ordens.qtd_planej
   END RECORD

     DEFINE m_den_empresa          LIKE empresa.den_empresa,
            m_consulta_ativa       SMALLINT,
            m_esclusao_ativa       SMALLINT,
            sql_stmt               CHAR(5000),
            where_clause           CHAR(5000),
            comando                CHAR(080),
            m_comando              CHAR(080),
            p_caminho              CHAR(60),
            w_caminho              CHAR(50),
            p_men                  CHAR(100),
            m_caminho              CHAR(150),
            p_last_row             SMALLINT,
            m_processa             SMALLINT,
            m_primeira_vez         SMALLINT, 
            m_arquivo_nf           CHAR(150),
            m_arquivo_ud           CHAR(150),
            m_msg                  CHAR(100),
            p_den_empresa          LIKE empresa.den_empresa

    DEFINE 
           l_pes_unit           LIKE item.pes_unit,
           w_operac             LIKE oper_ega_man912.cod_operac_ega
    
    DEFINE lr_dados_item        RECORD 
                                     cod_item          CHAR(26),    
                                     den_item          CHAR(40),    
                                     cod_operac        CHAR(5),
                                     cod_oper_ega      DECIMAL(9,0),   
                                     pecas_hora        DECIMAL(10,0),
                                     pecas_setup       DECIMAL(3,0), 
                                     alarme_rej        DECIMAL(3,0),  
                                     pecas_operac      DECIMAL(5,0),
                                     peso_unit         DECIMAL(15,0)
                                  END RECORD      

   DEFINE lr_dados_ordem         RECORD 
             num_ordem           DECIMAL(9,0),
             cod_item            CHAR(26),          
             cod_operac          DECIMAL(9,0),
             cod_recur           DECIMAL(3,0),
             num_seq_operac      DECIMAL(2,0),
             cod_status          CHAR(2),
             qtd_ordem           DECIMAL(8,0),
             cod_roteiro         LIKE ordens.cod_roteiro,
             num_altern_roteiro  LIKE ordens.num_altern_roteiro
   END RECORD
                                  
END GLOBALS

MAIN
     CALL log0180_conecta_usuario()
     LET p_versao = 'pol0455-12.00.00'
     WHENEVER ANY ERROR CONTINUE

#     CALL log1400_isolation()
     SET ISOLATION TO DIRTY READ
     SET LOCK MODE TO WAIT 120

     WHENEVER ANY ERROR STOP

     DEFER INTERRUPT

     CALL log140_procura_caminho("pol.iem") RETURNING m_caminho

##   LET m_caminho = log140_procura_caminho('pol0455.iem')

     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         INSERT   KEY control-i,
         DELETE   KEY control-e,
         HELP    FILE m_caminho

#     CALL log001_acessa_usuario('VDP')
     CALL log001_acessa_usuario("ESPEC999","")
          RETURNING p_status, p_cod_empresa, p_user
     
     IF  p_status = 0 THEN
         CALL pol0455_controle()
     END IF
 END MAIN

#--------------------------#
 FUNCTION pol0455_controle()
#--------------------------#

   CALL log006_exibe_teclas('01', p_versao)
   CALL log130_procura_caminho("pol0455") RETURNING m_caminho

   OPEN WINDOW w_pol0455 AT 2,2  WITH FORM  m_caminho 
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


#  LET m_caminho = log1300_procura_caminho('pol0455','')
#  OPEN WINDOW w_pol0455 AT 2,2 WITH FORM m_caminho
#      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   
   CURRENT WINDOW IS w_pol0455
   DISPLAY p_cod_empresa TO cod_empresa           
            
   MENU 'OPCAO'
       COMMAND 'Cadastrar' 'Cadastra Ordens p/ Exporta��o'
           HELP 001
           IF pol0455_cadastrar() then
              ERROR 'Cadastro de ordens efetuado com sucesso !!!'
           ELSE
              ERROR 'Opera��o cancelada !!!'
           END IF
       COMMAND 'Exportar' 'Exporta as Ordens e Produtos p/ Sistema EGA.'
           HELP 001
           MESSAGE ''
           IF log005_seguranca(p_user, 'VDP', 'pol0455', 'IN') THEN
#              IF pol0455_parametros_ok() THEN
                 CALL pol0455_exportar()
#              END IF
           END IF
       COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0455_sobre()       
       COMMAND KEY ("!")
           PROMPT "Digite o comando : " FOR m_comando
           RUN m_comando

       COMMAND 'Fim'       'Retorna ao menu anterior.'
           HELP 008
           EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0455

END FUNCTION

#---------------------------#
FUNCTION pol0455_cadastrar()
#---------------------------# 

   IF pol0455_aceita_itens() THEN
      IF pol0455_grava_ordens() THEN
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0455_aceita_itens()
#-----------------------------#

   CALL log130_procura_caminho("pol04551") RETURNING m_caminho
   LET m_caminho = m_caminho CLIPPED
   OPEN WINDOW w_pol04551 AT 7,13 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_op CURSOR FOR 
    SELECT num_ordem
      FROM ordens_export_912
     WHERE cod_empresa = p_cod_empresa
   
   LET p_index = 1
   
   FOREACH cq_op INTO pr_op[p_index].num_ordem
 
      CALL pol0455_le_ordem()                 
         
      LET p_index = p_index + 1

      IF p_index > 900 THEN
         ERROR 'Quantidade de linhas da grade ultrapassada !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_op
      WITHOUT DEFAULTS FROM sr_op.*
      ATTRIBUTES(INSERT ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      BEFORE FIELD num_ordem
         LET p_num_ordem = pr_op[p_index].num_ordem
         
      AFTER FIELD num_ordem
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_op[p_index].num_ordem IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigat�rio !!!"
               LET pr_op[p_index].num_ordem = p_num_ordem
               NEXT FIELD num_ordem
            END IF
         END IF
         IF pr_op[p_index].num_ordem IS NOT NULL THEN
            IF pol0455_repetiu_cod() THEN
               ERROR "Ordem ",pr_op[p_index].num_ordem," j� Informada !!!"
               LET pr_op[p_index].num_ordem = p_num_ordem
               NEXT FIELD num_ordem
            ELSE
               CALL pol0455_le_ordem()
               IF NOT pol0455_consiste_ordem() THEN
                  NEXT FIELD num_ordem
               END IF
               DISPLAY pr_op[p_index].ies_situa TO sr_op[s_index].ies_situa
               DISPLAY pr_op[p_index].cod_item  TO sr_op[s_index].cod_item
               DISPLAY pr_op[p_index].qtd_saldo TO sr_op[s_index].qtd_saldo
            END IF
         END IF
         
   END INPUT 

   CLOSE WINDOW w_pol04551
   CURRENT WINDOW IS w_pol0455
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF   
   
END FUNCTION

#--------------------------#
FUNCTION pol0455_le_ordem()
#--------------------------#

   INITIALIZE pr_op[p_index].ies_situa,
              pr_op[p_index].cod_item,
              pr_op[p_index].qtd_saldo,
              p_dat_ini TO NULL

   SELECT ies_situa,
          cod_item,
          dat_ini,
          qtd_planej,
          qtd_planej - qtd_boas - qtd_refug - qtd_sucata
     INTO pr_op[p_index].ies_situa,
          pr_op[p_index].cod_item,
          p_dat_ini,
          p_qtd_planej,
          pr_op[p_index].qtd_saldo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = pr_op[p_index].num_ordem

END FUNCTION

#-------------------------------#
FUNCTION pol0455_consiste_ordem()
#-------------------------------#

   IF STATUS <> 0 THEN 
      ERROR "Ordem inexistente !!!"
   ELSE
      IF pr_op[p_index].ies_situa <> '4' THEN
         ERROR "Ordem n�o est� liberada !!!"
      ELSE
         IF pr_op[p_index].qtd_saldo <= 0 THEN
            ERROR "Ordem sem saldo !!!"
         ELSE
            IF p_dat_ini IS NULL THEN
               ERROR "Ordem sem data de in�cio !!!"
            ELSE
               IF p_qtd_planej = pr_op[p_index].qtd_saldo THEN
                  ERROR 'Ordem sem apontamentos!!! '
               ELSE
                  RETURN TRUE
               END IF
            END IF
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0455_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_op[p_ind].num_ordem = pr_op[p_index].num_ordem THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0455_grava_ordens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM ordens_export_912
     WHERE cod_empresa = p_cod_empresa

   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELE��O","ORDENS_EXPORT_912")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
   
       IF pr_op[p_ind].num_ordem IS NOT NULL THEN

          INSERT INTO ordens_export_912
          VALUES (p_cod_empresa, pr_op[p_ind].num_ordem)
   
          IF STATUS <> 0 THEN 
             CALL log003_err_sql("INCLUS�O","ORDENS_EXPORT_912")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF
          
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      

   WHENEVER ERROR STOP

   RETURN TRUE
   
END FUNCTION


#--------------------------#
 FUNCTION pol0455_exportar()
#--------------------------# 
   DEFINE lr_nf_mestre           RECORD LIKE nf_mestre.*,
          lr_nf_item             RECORD LIKE nf_item.*,
          l_ver_sincr1           CHAR(100),
          l_ver_sincr2           SMALLINT  
      
   INITIALIZE lr_nf_item.*, lr_nf_mestre.* TO NULL 
   INITIALIZE p_caminho TO NULL
   
   SELECT nom_caminho
		  INTO w_caminho
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0455_cria_temps() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF

   IF pol0455_le_ordens() THEN
      CALL log085_transacao("COMMIT")
      IF pol0455_exporta_ordens() THEN
         CALL pol0455_exporta_item()
         DELETE FROM ordens_export_912
          WHERE cod_empresa = p_cod_empresa
      END IF
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   
END FUNCTION 

#----------------------------#
FUNCTION pol0455_cria_temps()
#----------------------------#

   WHENEVER ERROR CONTINUE
   
   DROP TABLE ord_oper_temp;

   CREATE TABLE ord_oper_temp
   (
      num_ordem  INTEGER,
      cod_item   CHAR(15),
      qtd_planej DECIMAL(10,3),
      cod_operac CHAR(09),      # cod. opera��o do EGA
      cod_recur  CHAR(03),
      dat_ini    CHAR(08),      # formato aaaammdd
      hor_ini    CHAR(08),      # formato hhmmss
      cod_oper_l CHAR(05),       # cod. opera��o do LOGIX
      peca_hora  INTEGER
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ord_oper_temp")
      RETURN FALSE
   END IF

   DROP TABLE item_temp;

   CREATE TEMP TABLE item_temp
   (
     cod_item CHAR(15)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","item_temp")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0455_le_ordens()
#--------------------------------#
   
   DEFINE     l_qtd_boas     LIKE ord_oper.qtd_boas,
              l_qtd_refugo   LIKE ord_oper.qtd_refugo,
              l_qtd_sucata   LIKE ord_oper.qtd_sucata,
              l_qtd_apont    LIKE ord_oper.qtd_planejada,
              l_num_ordem    CHAR(09),
              l_dat_oper     DATE,
			        l_oper_final   LIKE ord_oper.ies_oper_final,
			        p_dat_entrega  DATE,
			        p_dat_hoje     CHAR(10)

   MESSAGE "Agurde!...    Lendo Ordens. " ATTRIBUTE(REVERSE)  
 
   LET l_dat_oper = '01/01/2020'
   LET p_dat_hoje = TODAY
   LET p_dat_hoje[1] = '0'
   LET p_dat_hoje[2] = '1'
   LET p_dat_entrega = p_dat_hoje
   
 
   DECLARE cq_dados_op CURSOR FOR 
    SELECT a.num_ordem, 
           a.cod_item,
           a.cod_roteiro,
           a.num_altern_roteiro
      FROM ordens a
     WHERE (a.cod_empresa = p_cod_empresa
       AND  a.ies_situa   = '4' 
       AND  a.dat_entrega >= p_dat_entrega   #Ivo 01/06/11
       AND (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata) > 0) #Ivo 07/06/11
        OR (a.num_ordem IN 
            (SELECT b.num_ordem 
               FROM ordens_export_912 b
              WHERE b.cod_empresa = a.cod_empresa))
       ORDER BY num_ordem

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ordens/ordens_export_912")
      RETURN FALSE
   END IF
                 
   FOREACH cq_dados_op INTO lr_dados_ordem.num_ordem,
                            lr_dados_ordem.cod_item,
                            lr_dados_ordem.cod_roteiro,
                            lr_dados_ordem.num_altern_roteiro

							
      SELECT UNIQUE cod_empresa
        FROM peca_geme_man912
       WHERE cod_empresa    = p_cod_empresa
         AND cod_peca_gemea = lr_dados_ordem.cod_item

      IF STATUS = 0 THEN 
         CONTINUE FOREACH
      END IF
      
      LET l_num_ordem = lr_dados_ordem.num_ordem USING '&&&&&&&&&'
	  INITIALIZE ies_oper_final  TO NULL
      
      DECLARE cq_operacoes CURSOR FOR                  
       SELECT trim(cod_operac), 
              num_seq_operac, 
              cod_arranjo,
              qtd_planejada,
              qtd_boas,
              qtd_refugo,
              qtd_sucata,
			        ies_oper_final
         FROM ord_oper
        WHERE cod_empresa      = p_cod_empresa
          AND num_ordem        = lr_dados_ordem.num_ordem
          AND ies_apontamento <> 'F'
        ORDER BY num_seq_operac
      
      FOREACH cq_operacoes INTO 
              l_cod_operac,
              lr_dados_ordem.num_seq_operac,
              l_cod_arranjo,
              lr_dados_ordem.qtd_ordem,
              l_qtd_boas,
              l_qtd_refugo,
              l_qtd_sucata,
			        l_oper_final
	  
			  
         SELECT cod_operac_ega
           INTO lr_dados_ordem.cod_operac
           FROM oper_ega_man912
          WHERE cod_empresa = p_cod_empresa
            AND cod_operac  = l_cod_operac
     
         IF sqlca.sqlcode <> 0 THEN
            CONTINUE FOREACH
         END IF

         LET l_qtd_apont = l_qtd_boas + l_qtd_refugo + l_qtd_sucata
         LET lr_dados_ordem.qtd_ordem = lr_dados_ordem.qtd_ordem - l_qtd_apont

         IF lr_dados_ordem.qtd_ordem <= 0 THEN
            CONTINUE FOREACH
         END IF

        SELECT ies_situacao
           INTO l_ies_situacao
           FROM movto_ega_drummer
          WHERE cod_empresa      = p_cod_empresa
            AND num_ordem        = lr_dados_ordem.num_ordem
            AND trim(cod_operac) = lr_dados_ordem.cod_operac
            
         IF SQLCA.sqlcode = NOTFOUND THEN
         ELSE
            IF l_qtd_apont = 0 THEN
            ELSE
               IF l_ies_situacao = 'N' THEN
                  CONTINUE FOREACH
               END IF
            END IF
         END IF
         
         SELECT a.cod_recur
           INTO l_cod_recur
           FROM rec_arranjo a
          WHERE a.cod_empresa = p_cod_empresa
            AND a.cod_arranjo = l_cod_arranjo
            AND a.cod_recur IN
                 (SELECT b.cod_recur FROM recurso b
                   WHERE b.cod_empresa   = a.cod_empresa
                     AND b.cod_recur     = a.cod_recur
                     AND b.ies_tip_recur = '2')
         
         IF l_cod_recur IS NULL THEN
            CONTINUE FOREACH
         END IF

         SELECT cod_maquina_ega
           INTO lr_dados_ordem.cod_recur
           FROM maq_ega_man912
          WHERE cod_empresa = p_cod_empresa
            AND cod_maquina = l_cod_recur
 
         IF sqlca.sqlcode <> 0 THEN
            CONTINUE FOREACH
         END IF      
           
         SELECT COUNT(*)
           INTO l_cont
           FROM ct_rec_equip
          WHERE cod_empresa = p_cod_empresa
            AND cod_recur   = l_cod_recur
         
         IF l_cont IS NULL OR l_cont = 0 THEN
            CONTINUE FOREACH
         END IF
         
         SELECT EXTEND(dat_ini_planejada, YEAR TO DAY),
                EXTEND(dat_ini_planejada, HOUR TO SECOND)
           INTO p_dat_ini,
                p_hor_ini
           FROM man_oper_compl
          WHERE empresa            = p_cod_empresa
            AND ordem_producao     = lr_dados_ordem.num_ordem
            AND operacao           = l_cod_operac
            AND sequencia_operacao = lr_dados_ordem.num_seq_operac
            
         IF STATUS <> 0 THEN
            LET l_dat_oper = l_dat_oper + 1
            LET p_dat_ini = l_dat_oper
            LET p_hor_ini = '00:00:00'
         END IF
         
         LET p_dat_aux = p_dat_ini
         LET p_hor_aux = p_hor_ini
         LET p_dat_oper = p_dat_aux[7,10],p_dat_aux[4,5],p_dat_aux[1,2]
         LET p_hor_oper = p_hor_aux[1,2],p_hor_aux[4,5],p_hor_aux[7,8]
         
         SELECT qtd_pecas_ciclo
           INTO p_pc_hora
           FROM man_processo_item
          WHERE empresa             = p_cod_empresa                       
            AND item                = lr_dados_ordem.cod_item             
            AND roteiro             = lr_dados_ordem.cod_roteiro          
            AND roteiro_alternativo = lr_dados_ordem.num_altern_roteiro   
            AND seq_operacao        = lr_dados_ordem.num_seq_operac       
       
         IF STATUS <> 0 THEN
            LET p_pc_hora = 0
         END IF
         
         INSERT INTO ord_oper_temp
            VALUES(lr_dados_ordem.num_ordem,
                   lr_dados_ordem.cod_item,
                   lr_dados_ordem.qtd_ordem,
                   lr_dados_ordem.cod_operac,
                   lr_dados_ordem.cod_recur,
                   p_dat_oper,
                   p_hor_oper,
                   l_cod_operac,
                   p_pc_hora)

         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUS�O","ord_oper_temp")
            RETURN FALSE
         END IF
         
         ERROR 'Ordem: ', lr_dados_ordem.num_ordem
                                
      END FOREACH
      
   END FOREACH 
   
   RETURN TRUE

END FUNCTION 

#--------------------------------#
FUNCTION pol0455_exporta_ordens()
#--------------------------------#

   SELECT COUNT(num_ordem)
     INTO l_cont
     FROM ord_oper_temp
     
   IF l_cont = 0 THEN
      ERROR 'N�o h� Ordens p/ Exportar... Opera��o Cancelada!!!'
      RETURN FALSE
   END IF
   
   INITIALIZE p_caminho TO NULL
   LET p_caminho = w_caminho CLIPPED
   LET p_caminho = p_caminho CLIPPED, "EGAOFNV.TXT"

   START REPORT pol0455_relat_ordem TO p_caminho 

   LET lr_dados_ordem.cod_status = '00'
   LET lr_dados_ordem.num_seq_operac = -1
   LET l_cont = FALSE
   
   DECLARE cq_imp_ord CURSOR FOR
    SELECT num_ordem,
           cod_item,
           qtd_planej,
           cod_operac,
           cod_recur,
           peca_hora
      FROM ord_oper_temp
     ORDER BY cod_recur, 
              dat_ini,hor_ini      
              
   FOREACH cq_imp_ord INTO
           lr_dados_ordem.num_ordem,
           lr_dados_ordem.cod_item,
           lr_dados_ordem.qtd_ordem,
           lr_dados_ordem.cod_operac,
           lr_dados_ordem.cod_recur,
           p_pc_hora
      
      ERROR 'Ordem: ', lr_dados_ordem.num_ordem
      
      LET p_pc_por_oper = 0
      LET p_pc_hora = 0

      OUTPUT TO REPORT pol0455_relat_ordem(lr_dados_ordem.cod_recur)
      LET l_cont = TRUE
      
   END FOREACH
   
   FINISH REPORT pol0455_relat_ordem
   LET p_men = 'Exportado nos Arquivos: ',p_caminho CLIPPED

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 REPORT pol0455_relat_ordem(p_cod_recur)
#---------------------------------------#

   DEFINE p_cod_recur CHAR(03)
                                 
   OUTPUT LEFT   MARGIN 0  
          TOP    MARGIN 0  
          BOTTOM MARGIN 0  
          PAGE   LENGTH 1

      ORDER EXTERNAL BY p_cod_recur
      
   FORMAT 
   
      BEFORE GROUP OF p_cod_recur
      
#         LET lr_dados_ordem.num_seq_operac = 1

      ON EVERY ROW 
      
#         LET lr_dados_ordem.num_seq_operac = lr_dados_ordem.num_seq_operac + 1
      
         PRINT COLUMN 001, lr_dados_ordem.num_ordem USING '&&&&&&&&&',
               COLUMN 010, lr_dados_ordem.cod_item,
               COLUMN 036, lr_dados_ordem.cod_operac USING '&&&&&&&&&',
               COLUMN 045, p_pc_hora USING '&&&&&&&&&&',
               COLUMN 055, p_pc_por_oper USING '&&&&&',
               COLUMN 060, '000', #lr_dados_ordem.cod_recur USING '&&&',  
               COLUMN 063, lr_dados_ordem.num_seq_operac USING '--',
               COLUMN 065, lr_dados_ordem.cod_status,        
               COLUMN 067, lr_dados_ordem.qtd_ordem USING '&&&&&&&&'
                  
END REPORT                  

#------------------------------#
 FUNCTION pol0455_exporta_item()
#------------------------------#

    DEFINE l_num_seq_operac   LIKE consumo.num_seq_operac,
	       l_ies_oper_final   LIKE consumo_compl.ies_oper_final
	
   INITIALIZE p_caminho TO NULL
   LET p_caminho = w_caminho CLIPPED
   LET p_caminho = p_caminho CLIPPED, "EGAPCNV.TXT"
    
   START REPORT pol0455_relat_exp_item TO p_caminho 
   
   LET m_num_ordem = 0
   
   DECLARE cq_item CURSOR FOR
    SELECT a.num_ordem,
           a.cod_item,
           a.cod_oper_l,
           a.cod_operac,
           b.den_item, 
           b.pes_unit 
      FROM ord_oper_temp a, item b
     WHERE b.cod_item     = a.cod_item
       AND b.cod_empresa  = p_cod_empresa
       AND b.ies_situacao = 'A'
     ORDER BY a.num_ordem
   
   FOREACH cq_item INTO
           p_num_ordem,
           lr_dados_item.cod_item,
           lr_dados_item.cod_operac,
           lr_dados_item.cod_oper_ega,
           lr_dados_item.den_item,    
           l_pes_unit

      ERROR 'Item: ', lr_dados_item.cod_item
      
      DECLARE cq_operit CURSOR FOR 
       SELECT a.qtd_pecas_ciclo,
              a.qtd_tempo_setup,
	            a.seq_operacao,
	            a.operacao_final
         FROM man_processo_item a, item_man c
        WHERE a.empresa = c.cod_empresa
          AND a.item = c.cod_item
          AND a.roteiro_alternativo = c.num_altern_roteiro
          AND a.roteiro = c.cod_roteiro
          AND a.empresa  = p_cod_empresa
          AND a.item     = lr_dados_item.cod_item
          AND a.operacao = lr_dados_item.cod_operac
      
      FOREACH cq_operit INTO 
              lr_dados_item.pecas_hora,
              lr_dados_item.pecas_setup,
			        l_num_seq_operac,
					    l_ies_oper_final 

			  
		    SELECT qtd_ciclo_peca,                         
		    	     qtd_peca_ciclo                          
		      INTO p_tmp_ciclo,           
		    		   lr_dados_item.pecas_operac                           
		      FROM ciclo_peca_454                        
		     WHERE cod_empresa 	= p_cod_empresa          
		       AND cod_item 	= lr_dados_item.cod_item     
		       AND cod_operac  	= lr_dados_item.cod_operac 
		       AND num_seq_operac = l_num_seq_operac       
		  
		  
		     IF STATUS <> 0 THEN
			      LET lr_dados_item.pecas_operac = 1
			      LET p_tmp_ciclo = 0
         END IF
			  
#        Em 06/12/2011 ficou acertado com o Bruno do EGA que para a �ltima opera��o do item o peso seria igual a 1 e para as demais igual a 0
		 
		 IF l_ies_oper_final   = 'S'  THEN 
		     LET lr_dados_item.peso_unit = 9999
		 ELSE
		     LET lr_dados_item.peso_unit = 1
		 END IF 
		 
         LET lr_dados_item.alarme_rej = 0
         LET lr_dados_item.pecas_hora = lr_dados_item.pecas_hora * 100
         
         OUTPUT TO REPORT pol0455_relat_exp_item()
         
         #INITIALIZE lr_dados_item.* TO NULL - o usu�rio pediu p/ n�o exportar componentes
         #CALL pol0455_exporta_item_compon()
   
         EXIT FOREACH
               
      END FOREACH

      INITIALIZE lr_dados_item.* TO NULL
      
   END FOREACH  
    
   FINISH REPORT pol0455_relat_exp_item    
   LET p_men = p_men CLIPPED," e ", p_caminho CLIPPED
   CALL log0030_mensagem(p_men,"orientation")
   ERROR 'Processamento efetuado com sucesso!!!'

END FUNCTION 

#-------------------------------------#
FUNCTION pol0455_exporta_item_compon()
#-------------------------------------#

   DECLARE cq_item_compon CURSOR FOR
    SELECT a.cod_item_compon, b.den_item, b.pes_unit
      FROM ord_compon a, item b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.num_ordem    = p_num_ordem
       AND b.cod_empresa  = a.cod_empresa
       AND b.cod_item     = a.cod_item_compon
       AND a.cod_item_compon NOT IN
           (SELECT cod_item FROM item_temp)

   FOREACH cq_item_compon INTO 
           lr_dados_item.cod_item,
           lr_dados_item.den_item,    
           l_pes_unit
                         
      LET lr_dados_item.peso_unit = l_pes_unit * 100000
      LET lr_dados_item.cod_oper_ega  = 0
      LET lr_dados_item.pecas_hora  = 0
      LET lr_dados_item.pecas_setup = 0
      LET lr_dados_item.pecas_operac = 0
      LET lr_dados_item.alarme_rej = 0
         
      OUTPUT TO REPORT pol0455_relat_exp_item()
      
      INSERT INTO item_temp
         VALUES(lr_dados_item.cod_item)
         
   END FOREACH
      
END FUNCTION

#--------------------------------#
 REPORT pol0455_relat_exp_item()
#--------------------------------#
                                  
    OUTPUT LEFT   MARGIN 0  
           TOP    MARGIN 0  
           BOTTOM MARGIN 0
           PAGE   LENGTH 1
    
    FORMAT 
       ON EVERY ROW 
          PRINT COLUMN 001, lr_dados_item.cod_item,
                COLUMN 027, lr_dados_item.den_item[1,40],
                COLUMN 067, lr_dados_item.cod_oper_ega USING '&&&&&&&&&',
                COLUMN 076, lr_dados_item.pecas_hora USING '&&&&&&&&&&', 
                COLUMN 086, lr_dados_item.pecas_setup USING '&&&',
                COLUMN 089, lr_dados_item.alarme_rej USING '&&&',
                COLUMN 092, lr_dados_item.pecas_operac USING '&&&&&',
                COLUMN 097, lr_dados_item.peso_unit USING '&&&&&&&&&&',
                COLUMN 107, p_tmp_ciclo USING '&&&'
          
END REPORT 

#-----------------------#
 FUNCTION pol0455_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
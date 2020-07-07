#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A PAGAR                                          #
# PROGRAMA: pol0475                                                 #
# OBJETIVO: EXPORTA PPAP - INTEGRAÇÃO LOGIX X PROTHEUS              #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 17/04/2006                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_filial         CHAR(02),
          p_user               LIKE usuario.nom_usuario,
          p_cod_item           LIKE item.cod_item,
          p_cod_item_compon    LIKE item.cod_item,
          p_cod_user           LIKE usuarios.cod_usuario,
          p_den_item           LIKE item.den_item_reduz,
          p_qk1_desc           LIKE item.den_item,
          p_den_compon         LIKE item.den_item,
          p_cod_compon         LIKE item.cod_item,
          p_seq_versao         LIKE cad_des.seq_versao,
          p_cod_arranjo        LIKE consumo.cod_arranjo,
          p_cod_recur          LIKE rec_arranjo.cod_recur,
          p_cod_operac         LIKE consumo.cod_operac,
          p_cod_cent_trab      LIKE consumo.cod_cent_trab, 
          p_cod_roteiro        LIKE consumo.cod_roteiro,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_neces          LIKE estrutura.qtd_necessaria,
          p_pes_unit           LIKE item.pes_unit,
          p_qtd_recur          LIKE rec_arranjo.qtd_recur,
          p_ies_tip_recur      LIKE recurso.ies_tip_recur,
          p_qtd_pecas_ciclo    LIKE consumo.qtd_pecas_ciclo,
          p_den_recur          VARCHAR(50),
          p_cod_nivel          INTEGER,
          p_achou              SMALLINT,
          p_revinv             CHAR(02),
          p_dig_1              SMALLINT,
          p_dig_2              SMALLINT,
          p_dat_revisao        CHAR(08),
          p_dat_txt            CHAR(10),
          p_num_seq            SMALLINT,
          p_sequen             INTEGER,
          p_sub_seq            INTEGER,
          p_sequen_c           CHAR(03),
          p_sub_seq_c          CHAR(03),
          p_ind                SMALLINT,
          p_input              CHAR(01),
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
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
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(3000),
          where_clause         CHAR(300),
          p_loop               SMALLINT,
          p_msg                CHAR(500),
          p_ja_exportou        SMALLINT,
		      p_pcseg              DEC(7,4),
          p_instancia          CHAR(30)
		      
 
   DEFINE p_item_ppap_970  RECORD LIKE item_ppap_970.*,
          p_item_ppap_970a RECORD LIKE item_ppap_970.*

   DEFINE p_tela          RECORD
          cod_item        LIKE item.cod_item,
          cod_revisao     CHAR(2),
          dat_revisao     DATE,
          cod_peca_ppap   CHAR(40)     
   END RECORD

   DEFINE pr_revinv       ARRAY[10] OF RECORD
          letra           CHAR(01)
   END RECORD
    
   DEFINE pr_compon       ARRAY[200] OF RECORD
          cod_compon      LIKE item.cod_item,
          cod_operac      LIKE operacao.cod_operac,
          den_operac      LIKE operacao.den_operac,
          cod_oper_p      CHAR(07),
          cod_simbolo     LIKE simbolo_itaesbra.cod_simbolo,
          den_simbolo     LIKE simbolo_itaesbra.den_simbolo
   END RECORD

   DEFINE p_qkk010 RECORD
    qkk_filial varchar(2), 
    qkk_peca   varchar(40), 
    qkk_rev    varchar(2), 
    qkk_proces varchar(4), 
    qkk_revinv varchar(2), 
    qkk_nope   varchar(7), 
    qkk_desc   varchar(80), 
    qkk_pecalo varchar(20), 
    qkk_maq    varchar(10), 
    qkk_nommaq varchar(50), 
    qkk_seqant varchar(5), 
    qkk_seqpos varchar(5), 
    qkk_chave  varchar(8), 
    qkk_planta varchar(3), 
    qkk_pccicl varchar(10), #float, 
    qkk_qtdh   varchar(10), #float, 
    qkk_pchora varchar(10), #float, 
    qkk_pcseg  varchar(10), #float, 
    qkk_bitmap varchar(20), 
    qkk_sbope  varchar(2), 
    qkk_tpope  varchar(1), 
    qkk_item   varchar(4), 
    qkk_area   varchar(30), 
    qkk_func   varchar(50), 
    qkk_msblql varchar(1), 
    qkk_luva   varchar(1), 
    qkk_bota   varchar(1), 
    qkk_abafad varchar(1), 
    qkk_oculos varchar(1), 
    qkk_aventa varchar(1), 
    qkk_mangot varchar(1), 
    qkk_simita varchar(2), 
    qkk_mascar varchar(1), 
    d_e_l_e_t_ varchar(1), 
    r_e_c_n_o_ integer
   END RECORD

   DEFINE p_qk1010 RECORD
    qk1_filial varchar(2),
    qk1_peca   varchar(40), 
    qk1_rev    varchar(2), 
    qk1_revinv varchar(2), 
    qk1_dtrevi varchar(8), 
    qk1_pccli  varchar(40), 
    qk1_descli varchar(30), 
    qk1_ppap   varchar(40), 
    qk1_desc   varchar(150), 
    qk1_codcli varchar(6), 
    qk1_lojcli varchar(2), 
    qk1_nomcli varchar(40), 
    qk1_ndes   varchar(30), 
    qk1_revdes varchar(15), 
    qk1_dtrdes varchar(8), 
    qk1_projet varchar(40), 
    qk1_alteng varchar(100), 
    qk1_dteng  varchar(8), 
    qk1_doc    varchar(30), 
    qk1_tplogo varchar(1), 
    qk1_codequ varchar(5), 
    qk1_produt varchar(15), 
    qk1_revi   varchar(2), 
    qk1_just   varchar(50), 
    qk1_status varchar(1), 
    qk1_dtence varchar(8),
    qk1_dtreab varchar(8), 
    qk1_licpk  varchar(10), #float, 
    qk1_lscpk  varchar(10), #float, 
    qk1_altdoc varchar(20), 
    qk1_nalprj varchar(1), 
    qk1_codvcl varchar(20), 
    qk1_revcli varchar(2), 
    qk1_dtrevc varchar(8), 
    qk1_cjtdes varchar(30), 
    qk1_cjtrev varchar(2), 
    qk1_cjrevd varchar(8), 
    qk1_pesoli varchar(10), #float, 
    qk1_cjpeso varchar(10), #float, 
    qk1_qtdecj varchar(10), #float, 
    qk1_codigo varchar(15), 
    qk1_usuari varchar(50), 
    qk1_visto  varchar(50), 
    qk1_tipo   varchar(1), 
    qk1_pecseg varchar(1), 
    qk1_fluxo  varchar(1), 
    qk1_msblql varchar(1), 
    qk1_dtelab varchar(8), 
    qk1_okapro varchar(1), 
    qk1_dtvist varchar(8), 
    d_e_l_e_t_ varchar(1), 
    r_e_c_n_o_ integer, 
    r_e_c_d_e_l_ integer 
   END RECORD

   DEFINE p_qk2010 RECORD
    qk2_filial   varchar(2), 
    qk2_peca     varchar(40), 
    qk2_rev      varchar(2), 
    qk2_revinv   varchar(2), 
    qk2_item     varchar(4), 
    qk2_codcar   varchar(8), 
    qk2_desc     varchar(50), 
    qk2_espe     varchar(50), 
    qk2_tpcar    varchar(1), 
    qk2_prodpr   varchar(1), 
    qk2_planoc   varchar(1), 
    qk2_tol      varchar(13), 
    qk2_lie      varchar(13), 
    qk2_lse      varchar(13), 
    qk2_esp      varchar(1), 
    qk2_simb     varchar(2), 
    qk2_um       varchar(2), 
    qk2_chave    varchar(08),
    qk2_ppap     varchar(04),
    r_e_c_d_e_l_ integer, 
    d_e_l_e_t_   varchar(1), 
    r_e_c_n_o_   integer 
   END RECORD

   DEFINE p_qz3010 RECORD
	    qz3_filial VARCHAR (2),   
	    qz3_proces VARCHAR (4),   
	    qz3_peca   VARCHAR (15),  
	    qz3_revisa VARCHAR (3),   
	    qz3_sequen VARCHAR (7),   
	    qz3_maquin VARCHAR (10),  
	    qz3_operad VARCHAR (10),  
	    qz3_qtde   varchar(10), #FLOAT,         
	    qz3_maoobr varchar(10), #FLOAT,         
	    qz3_msblql VARCHAR (1),   
	    d_e_l_e_t_ VARCHAR (1),   
	    r_e_c_n_o_ INTEGER        
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0475-10.02.35"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0475.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0475_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0475_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0475") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0475 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_filial = p_cod_empresa
   
   CALL pol0475_carrega_letra()

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados nas tabelas"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0475_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0475_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0475_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0475_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0475_sobre()
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
   CLOSE WINDOW w_pol0475

END FUNCTION

#-----------------------#
 FUNCTION pol0475_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------#
FUNCTION pol0475_carrega_letra()
#------------------------------#

   LET pr_revinv[1].letra = 'Y'
   LET pr_revinv[2].letra = 'X'
   LET pr_revinv[3].letra = 'W'
   LET pr_revinv[4].letra = 'V'
   LET pr_revinv[5].letra = 'U'
   LET pr_revinv[6].letra = 'T'
   LET pr_revinv[7].letra = 'S'
   LET pr_revinv[8].letra = 'R'
   LET pr_revinv[9].letra = 'Q'
   LET pr_revinv[10].letra = 'P'

END FUNCTION

#-----------------------#
FUNCTION pol0475_incluir()
#-----------------------#

   LET p_retorno = FALSE
   
   IF pol0475_aceita_chave() THEN 
      IF pol0475_carrega_compon() THEN
         IF pol0475_aceita_operacao() THEN
            IF pol0475_grava_itens() THEN
               LET p_retorno = TRUE
            END IF
         END IF
      END IF
   END IF
   
   RETURN(p_retorno)
   
END FUNCTION

#-----------------------------#
FUNCTION pol0475_aceita_chave()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0475
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET p_input = 'C'
   LET p_tela.cod_revisao = '00'
   LET p_tela.dat_revisao = TODAY
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

      AFTER FIELD cod_item

         IF p_tela.cod_item IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD cod_item
         END IF

         SELECT den_item_reduz, 
                den_item,
                ies_tip_item,
                pes_unit
           INTO p_den_item, 
                p_qk1_desc,
                p_ies_tip_item,
                p_pes_unit
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela.cod_item

          IF STATUS <> 0 THEN 
             ERROR "Item Inexistente !!!"
             NEXT FIELD cod_item
          END IF
          
          IF p_ies_tip_item MATCHES '[FPB]' THEN 
          else
             ERROR "Informe um item do tipo F, P ou B !!!"
             NEXT FIELD cod_item
          END IF

          DISPLAY p_den_item TO den_item
          
          let p_ja_exportou = false
          
          SELECT cod_empresa
            FROM item_ppap_970
           WHERE cod_empresa = p_cod_empresa
             AND cod_item    = p_tela.cod_item
          IF STATUS = 0 THEN 
             let p_ja_exportou = true
             let p_msg = 'Esse item já foi exportado ao\n ',
                         'Protheus! Deseja reexportá-lo?'
             IF log0040_confirm(20,25,p_msg) = TRUE THEN
             else
                NEXT FIELD cod_item
             end if
          END IF
          
          IF p_tela.cod_peca_ppap IS NULL OR
             p_tela.cod_peca_ppap = ' ' THEN
             LET p_tela.cod_peca_ppap = p_tela.cod_item
             DISPLAY p_tela.cod_peca_ppap TO cod_peca_ppap
          END IF
          
      AFTER INPUT
      
         IF INT_FLAG = 0 THEN
            IF p_tela.cod_revisao IS NULL THEN
               ERROR 'Informe o código da revisão !!!'
               NEXT FIELD cod_revisao
            END IF
            
            IF p_tela.dat_revisao IS NULL THEN
               ERROR 'Informe a data da revisão !!!'
               NEXT FIELD dat_revisao
            END IF
            
            IF p_tela.cod_peca_ppap IS NULL THEN
               ERROR 'Informe a peca PPAP !!!'

               NEXT FIELD cod_peca_ppap
            END IF
            
            INITIALIZE p_dat_txt, p_dat_revisao TO NULL
            LET p_dat_txt = p_tela.dat_revisao
            LET p_dat_revisao = p_dat_txt[7,10], p_dat_txt[4,5], p_dat_txt[1,2]
         
         END IF

      ON KEY (control-z)
         CALL pol0475_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION 

#-------------------------------#
FUNCTION pol0475_carrega_compon()
#-------------------------------#

   IF NOT pol0475_cria_temps() THEN
      RETURN FALSE
   END IF
   
   LET p_cod_nivel = 0
   LET p_qtd_neces = 1
   
   INSERT INTO compon_1
      VALUES(p_cod_nivel,p_tela.cod_item,p_qtd_neces)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INSERÇÃO","compon_1")
      RETURN FALSE
   END IF
   
   LET p_cod_nivel = p_cod_nivel + 1
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_tela.cod_item
     
   FOREACH cq_compon INTO p_cod_item_compon, p_qtd_neces
   
      SELECT *
        FROM compon_1
       WHERE cod_compon = p_cod_item_compon

      IF SQLCA.sqlcode = NOTFOUND THEN

         INSERT INTO compon_1
            VALUES(p_cod_nivel,p_cod_item_compon,p_qtd_neces)

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INSERÇÃO","compon_1")
            RETURN FALSE
         END IF

      END IF
      
   END FOREACH

   LET p_loop = TRUE
   
   WHILE p_loop
   
      IF NOT pol0375_carrega_compon_filho() THEN
         RETURN FALSE
      END IF
   
   END WHILE

   LET p_num_seq = 0
   
   DECLARE cq_item CURSOR FOR
    SELECT cod_compon
      FROM compon_1
      
   FOREACH cq_item INTO p_cod_item
   
      SELECT cod_roteiro
        INTO p_cod_roteiro
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         
      IF STATUS <> 0 THEN
         CONTINUE FOREACH
      END IF
      
      DECLARE cq_oper CURSOR FOR
       SELECT cod_operac
         FROM consumo
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_cod_item
          AND (cod_roteiro = p_cod_roteiro OR 
               cod_roteiro IS NULL)
        ORDER BY num_seq_operac DESC
      
      FOREACH cq_oper INTO p_cod_operac
         
         LET p_num_seq = p_num_seq + 1
         
         INSERT INTO item_oper
            VALUES(p_cod_item, p_cod_operac, p_num_seq)

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INCLUSÃO","item_oper")
            RETURN FALSE
         END IF
            
      END FOREACH
   
   END FOREACH
            
   RETURN TRUE
      
END FUNCTION 

#--------------------------------------#
FUNCTION pol0375_carrega_compon_filho()
#--------------------------------------#

   DELETE FROM compon_3
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","compon_3")
      RETURN FALSE
   END IF
   
   DECLARE cq_compon_1 CURSOR FOR
    SELECT a.cod_compon
      FROM compon_1 a
     WHERE a.cod_compon NOT IN (SELECT b.cod_compon FROM compon_2 b)
   
   FOREACH cq_compon_1 INTO p_cod_item

      INSERT INTO compon_2
         VALUES(p_cod_item)

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","compon_2")
         RETURN FALSE
      END IF

      DECLARE cq_estru CURSOR FOR     
       SELECT cod_item_compon,
              qtd_necessaria
         FROM estrutura
        WHERE cod_empresa  = p_cod_empresa
          AND cod_item_pai = p_cod_item
      
      FOREACH cq_estru INTO p_cod_item_compon, p_qtd_neces
           
         INSERT INTO compon_3
            VALUES(p_cod_item_compon, p_qtd_neces)

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INSERÇÃO","compon_3")
            RETURN FALSE
         END IF

      END FOREACH
      
   END FOREACH
   
   SELECT COUNT(*)
     INTO p_count
     FROM compon_3

   IF p_count = 0 THEN
      LET p_loop = FALSE
      RETURN TRUE
   END IF
   
   LET p_cod_nivel = p_cod_nivel + 1
   
   DECLARE cq_compon_3 CURSOR FOR
    SELECT cod_compon,
           qtd_neces 
      FROM compon_3
   
   FOREACH cq_compon_3 INTO p_cod_item_compon, p_qtd_neces
      
      SELECT * 
        FROM compon_1
       WHERE cod_compon = p_cod_item_compon
      
      IF SQLCA.sqlcode = NOTFOUND THEN
        
         INSERT INTO compon_1
            VALUES(p_cod_nivel,p_cod_item_compon, p_qtd_neces)

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INSERÇÃO","compon_1")
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
  
#----------------------------#
FUNCTION pol0475_cria_temps()
#----------------------------#
  
   DROP TABLE compon_1;
   CREATE  TABLE compon_1   
   (
      cod_nivel     INTEGER,
      cod_compon    CHAR(15),
      qtd_neces     DECIMAL(14,7)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","compon_1")
      RETURN FALSE
   END IF
   
   DROP TABLE compon_2;
   CREATE  TABLE compon_2
   (
      cod_compon    CHAR(15)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","compon_2")
      RETURN FALSE
   END IF
 
   DROP TABLE compon_3;
   CREATE  TABLE compon_3
   (
      cod_compon    CHAR(15),
      qtd_neces     DECIMAL(14,7)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","compon_3")
      RETURN FALSE
   END IF

   DROP TABLE item_oper;
   CREATE  TABLE item_oper
   (
      cod_compon    CHAR(15),
      cod_operac    CHAR(05),
      num_seq       SMALLINT
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","item_oper")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0475_aceita_operacao()
#--------------------------------#

   INITIALIZE pr_compon TO NULL
   
   DECLARE cq_operacao CURSOR FOR 
    SELECT *
      FROM item_oper
     ORDER BY 3 DESC
   
   LET p_index = 1
   
   FOREACH cq_operacao INTO 
           pr_compon[p_index].cod_compon,
           pr_compon[p_index].cod_operac,
           p_num_seq
 
      SELECT den_operac
        INTO pr_compon[p_index].den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = pr_compon[p_index].cod_operac

      LET pr_compon[p_index].cod_simbolo = 'A3'

      SELECT den_simbolo
        INTO pr_compon[p_index].den_simbolo
        FROM simbolo_itaesbra
       WHERE cod_empresa = p_cod_empresa
         AND cod_simbolo = pr_compon[p_index].cod_simbolo      
      
      SELECT num_seq, num_sub_seq
        INTO p_sequen, p_sub_seq
			  FROM ciclo_peca_970
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_item =pr_compon[p_index].cod_compon

      LET p_sequen_c = p_sequen USING '&&&'
      LET p_sub_seq_c = p_sub_seq USING '&&&'
      LET pr_compon[p_index].cod_oper_p = p_sequen_c,'-',p_sub_seq_c
      
      IF pr_compon[p_index].cod_oper_p = '000-000' OR 
         pr_compon[p_index].cod_oper_p IS NULL THEN
         LET pr_compon[p_index].cod_oper_p = '099-099'
      END IF

      LET p_index = p_index + 1

      IF p_index > 200 THEN
         ERROR 'Limite de linhas ultrapassado !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_compon
      WITHOUT DEFAULTS FROM sr_compon.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
         INITIALIZE p_den_compon TO NULL
         
         SELECT den_item
           INTO p_den_compon
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_compon
         DISPLAY p_den_compon TO den_compon
         
      BEFORE FIELD cod_oper_p
         
      AFTER FIELD cod_oper_p
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN 
            IF pr_compon[p_index+1].cod_compon IS NULL THEN
               NEXT FIELD cod_simbolo
            END IF
         END IF
         IF pr_compon[p_index].cod_oper_p IS NOT NULL THEN
#            LET p_cod_compon = pr_compon[p_index].cod_compon
            IF pol0475_repetiu_cod() THEN
               ERROR "Operação ",pr_compon[p_index].cod_oper_p," já lançada "
               NEXT FIELD cod_oper_p
            END IF
         END IF

      AFTER FIELD cod_simbolo
         IF pr_compon[p_index].cod_simbolo IS NOT NULL THEN
            SELECT den_simbolo
              INTO pr_compon[p_index].den_simbolo
              FROM simbolo_itaesbra
             WHERE cod_empresa = p_cod_empresa
               AND cod_simbolo = pr_compon[p_index].cod_simbolo
            IF STATUS <> 0 THEN
               ERROR 'Simbolo Inexistente !!!'
               NEXT FIELD cod_simbolo
            END IF
            DISPLAY pr_compon[p_index].den_simbolo TO sr_compon[s_index].den_simbolo
         END IF
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN 
            IF pr_compon[p_index+1].cod_compon IS NULL THEN
               NEXT FIELD cod_oper_p
            END IF
         END IF
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
            FOR p_ind = 1 TO ARR_COUNT()
                IF pr_compon[p_ind].cod_oper_p IS NULL THEN
                   ERROR "A coluna operação Protheus não está totalmente preenchida !!!"
                   NEXT FIELD cod_oper_p
                END IF
                IF pr_compon[p_ind].cod_simbolo IS NULL THEN
                   ERROR "A coluna símbolo não está totalmente preenchida !!!"
                   NEXT FIELD cod_simbolo
                END IF
            END FOR
         END IF
                
      ON KEY (control-z)
         CALL pol0475_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#-------------------------------#
FUNCTION pol0475_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_compon[p_ind].cod_oper_p = pr_compon[p_index].cod_oper_p THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0475_deleta_item()
#-----------------------------#

   delete from compon_ppap_970
    where cod_empresa = p_cod_empresa
      and cod_item    = p_tela.cod_item

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("DELETANDO","compon_ppap_970")    
      RETURN FALSE
   END IF

   delete from item_ppap_970
    where cod_empresa = p_cod_empresa
      and cod_item    = p_tela.cod_item
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("DELETANDO","item_ppap_970")    
      RETURN FALSE
   END IF

   LET sql_stmt =
   "UPDATE ", p_instancia CLIPPED,"QK1010  ",
   "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ ",
   " WHERE qk1_filial = '",p_cod_filial,"' ",  
   "   AND qk1_peca   = '",p_tela.cod_item,"' ",               
   "   AND qk1_rev    = '",p_tela.cod_revisao,"' "     
   
   PREPARE upd_qk1010 FROM sql_stmt CLIPPED
   EXECUTE upd_qk1010
      
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("update","qk1010")    
      RETURN FALSE
   END IF

   LET sql_stmt =
   "UPDATE ", P_INSTANCIA CLIPPED,"QKK010  ",
   "   SET d_e_l_e_t_ = '*' ",
   " WHERE qkk_filial = '",p_cod_filial,"' ",  
   "   AND qkk_peca   = '",p_tela.cod_item,"' ",               
   "   AND qkk_rev    = '",p_tela.cod_revisao,"' "     
   
   PREPARE upd_qkk010 FROM sql_stmt CLIPPED
   EXECUTE upd_qkk010
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("update","qkk010")    
      RETURN FALSE
   END IF

   LET sql_stmt =
   "UPDATE ", p_instancia CLIPPED,"qk2010  ",
   "   SET d_e_l_e_t_ = '*', r_e_c_d_e_l_= r_e_c_n_o_ ",
   " WHERE qk2_filial = '",p_cod_filial,"' ",  
   "   AND qk2_peca   = '",p_tela.cod_item,"' ",               
   "   AND qk2_rev    = '",p_tela.cod_revisao,"' "     
   
   PREPARE upd_qk2010 FROM sql_stmt CLIPPED
   EXECUTE upd_qk2010
        
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("update","qk2010")    
      RETURN FALSE
   END IF 
   
   LET sql_stmt =
   "UPDATE ", p_instancia CLIPPED,"qz3010  ",
   "   SET d_e_l_e_t_ = '*' ",
   " WHERE qz3_filial = '",p_cod_filial,"' ",  
   "   AND qz3_peca   = '",p_tela.cod_item,"' ",               
   "   AND qz3_revisa = '",p_tela.cod_revisao,"' "     
   
   PREPARE upd_qz3010 FROM sql_stmt CLIPPED
   EXECUTE upd_qz3010
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("update","qz3010")    
      RETURN FALSE
   END IF 
    
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0475_grava_itens()
#-----------------------------#

   SELECT parametro_texto
     INTO p_instancia
     FROM min_par_modulo
    WHERE empresa = '01'
      AND parametro = 'INSTANCIA_PROTHEUS'
   
   IF STATUS = 100 THEN
      LET p_instancia = ''
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF
   
   #LET p_instancia = log9900_conversao_minusculo(p_instancia)

   CALL log085_transacao("BEGIN") 

   if p_ja_exportou then
      IF NOT pol0475_deleta_item() then
         CALL log085_transacao("ROLLBACK") 
         return false
      end if
   end if
         

   INSERT INTO item_ppap_970
      VALUES(p_cod_empresa,
             p_tela.cod_item,
             p_tela.cod_revisao,
             p_tela.dat_revisao,
             p_tela.cod_peca_ppap)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","item_ppap_970")    
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF

   INITIALIZE p_qkk010, p_qk1010, p_qk2010 TO NULL
   
     {inicializa atab p_qk1010}
    
   let p_dat_txt = TODAY      
          
   LET  p_qk1010.qk1_filial  =  ' '  
   LET  p_qk1010.qk1_peca  =  ' '              
   LET  p_qk1010.qk1_rev  =  ' '                   
   LET  p_qk1010.qk1_revinv  =  ' '                   
   LET  p_qk1010.qk1_dtrevi  =  ' '                  
   LET  p_qk1010.qk1_pccli  =  ' '                    
   LET  p_qk1010.qk1_descli  =  ' '              
   LET  p_qk1010.qk1_ppap  =  ' '              
   LET  p_qk1010.qk1_desc  =  ' '                    
   LET  p_qk1010.qk1_codcli  =  ' '   
   LET  p_qk1010.qk1_lojcli  =  '01'                     
   LET  p_qk1010.qk1_nomcli  =  ' '                      
   LET  p_qk1010.qk1_ndes  =  ' '                  
   LET  p_qk1010.qk1_revdes  =  ' '                   
   LET  p_qk1010.qk1_dtrdes  =  ' '                   
   LET  p_qk1010.qk1_projet  =  ' '      
#   LET  p_qk1010.qk1_motivo  = ' '              
   LET  p_qk1010.qk1_alteng  =  ' '                   
   LET  p_qk1010.qk1_dteng  =  ' '                    
   LET  p_qk1010.qk1_doc  =  ' '                 
   LET  p_qk1010.qk1_tplogo  =  ' '                 
   LET  p_qk1010.qk1_codequ  =  ' '                
   LET  p_qk1010.qk1_produt  =  ' '                   
   LET  p_qk1010.qk1_revi  =  ' '                    
   LET  p_qk1010.qk1_just  =  ' '                   
   LET  p_qk1010.qk1_status  =  '1'                   
   LET  p_qk1010.qk1_dtence  =  ' '                  
   LET  p_qk1010.qk1_dtreab  =  ' '         
   LET  p_qk1010.qk1_licpk   = '1,33'            
   LET  p_qk1010.qk1_lscpk   = '1,67'            
   LET  p_qk1010.qk1_altdoc  = ' '          
   LET  p_qk1010.qk1_nalprj  = ' '          
   LET  p_qk1010.qk1_codvcl  = ' '                                            
   LET  p_qk1010.qk1_revcli  = ' '       
   LET  p_qk1010.qk1_dtrevc  = ' '       
   LET  p_qk1010.qk1_cjtdes  = ' '       
   LET  p_qk1010.qk1_cjtrev  = ' '       
   LET  p_qk1010.qk1_cjrevd  = ' '       
   LET  p_qk1010.qk1_pesoli  = '0'         
   LET  p_qk1010.qk1_cjpeso  = '0'         
   LET  p_qk1010.qk1_qtdecj  = '0'         
   LET  p_qk1010.qk1_codigo  = ' '       
   LET  p_qk1010.qk1_usuari  = ' '       
   LET  p_qk1010.qk1_visto   = ' '       
   LET  p_qk1010.qk1_tipo 	 = ' '       
   LET  p_qk1010.qk1_pecseg  = ' '  
   LET  p_qk1010.qk1_fluxo   = ' '
   LET  p_qk1010.qk1_msblql  = ' '
   LET  p_qk1010.qk1_dtelab  = p_dat_txt[7,10], p_dat_txt[4,5], p_dat_txt[1,2]
   LET  p_qk1010.qk1_okapro  = ' '
   LET  p_qk1010.qk1_dtvist  = ' '
   LET  p_qk1010.d_e_l_e_t_  = ' '          
   LET  p_qk1010.r_e_c_n_o_  = 0           
   LET  p_qk1010.r_e_c_d_e_l_ = 0           
                                           
      {inicializa a tab qkk010}                     
                                            
   LET  p_qkk010.qkk_filial  = ' '         
   LET  p_qkk010.qkk_peca    = ' '            
   LET  p_qkk010.qkk_rev     = ' '         
   LET  p_qkk010.qkk_proces  = ' '          
   LET  p_qkk010.qkk_revinv  = ' '         
   LET  p_qkk010.qkk_nope    = ' '         
   LET  p_qkk010.qkk_desc    = ' ' 
   LET  p_qkk010.qkk_pecalo  = ' '      
   LET  p_qkk010.qkk_maq     = ' '         
   LET  p_qkk010.qkk_nommaq  = ' '   
   LET  p_qkk010.qkk_seqant  = ' '          
   LET  p_qkk010.qkk_seqpos  = ' '          
   LET  p_qkk010.qkk_chave   = ' ' 
   LET  p_qkk010.qkk_planta  = ' '          
   LET  p_qkk010.qkk_pccicl  = 0          
   LET  p_qkk010.qkk_qtdh 	 = 0
   LET  p_qkk010.qkk_pchora  = 0
   LET  p_qkk010.qkk_pcseg 	 = 0
   LET  p_qkk010.qkk_bitmap  = ' '          
   LET  p_qkk010.qkk_sbope   = ' '         
   LET  p_qkk010.qkk_tpope   = ' '         
   LET  p_qkk010.qkk_item    = ' '         
   LET  p_qkk010.qkk_area    = ' '         
   LET  p_qkk010.qkk_func    = ' '  
   LET  p_qkk010.qkk_msblql  = ' '  
   LET  p_qkk010.qkk_luva    = 'N'
   LET  p_qkk010.qkk_bota    = 'N'
   LET  p_qkk010.qkk_abafad  = 'N'
   LET  p_qkk010.qkk_oculos  = 'N'
   LET  p_qkk010.qkk_aventa  = 'N'
   LET  p_qkk010.qkk_mangot  = 'N'
   LET  p_qkk010.qkk_simita  = ' '
   LET  p_qkk010.qkk_mascar  = ' '
   LET p_qkk010.d_e_l_e_t_   = ' '         
   LET p_qkk010.r_e_c_n_o_   = 0          

      {inicializa a tab p_qz3010}

   LET p_qz3010.qz3_filial   = ' '
   LET p_qz3010.qz3_proces   = ' '
   LET p_qz3010.qz3_peca     = ' '
   LET p_qz3010.qz3_revisa   = ' '
   LET p_qz3010.qz3_sequen   = ' '
   LET p_qz3010.qz3_maquin   = ' '
   LET p_qz3010.qz3_operad   = ' '
   LET p_qz3010.qz3_qtde     = 0
   LET p_qz3010.qz3_maoobr   = 0
   LET p_qz3010.qz3_msblql   = ' '
   LET p_qz3010.d_e_l_e_t_   = ' '
   LET p_qz3010.r_e_c_n_o_   = 0

     
      {inicializa a tab p_qk2010}
   
   LET p_qk2010.qk2_filial  =  ' '   
   LET p_qk2010.qk2_peca    =  ' '            
   LET p_qk2010.qk2_rev     =  ' '            
   LET p_qk2010.qk2_revinv  =  ' '            
   LET p_qk2010.qk2_item    =  ' '            
   LET p_qk2010.qk2_codcar  =  ' '            
   LET p_qk2010.qk2_desc    =  ' '            
   LET p_qk2010.qk2_espe    =  ' '            
   LET p_qk2010.qk2_tpcar   =  ' '            
   LET p_qk2010.qk2_prodpr  =  ' '            
   LET p_qk2010.qk2_planoc  =  ' '            
   LET p_qk2010.qk2_tol     =  ' '            
   LET p_qk2010.qk2_lie     =  ' '            
   LET p_qk2010.qk2_lse     =  ' '            
   LET p_qk2010.qk2_esp     =  ' '            
   LET p_qk2010.qk2_simb    =  ' '            
   LET p_qk2010.qk2_um      =  ' '            
   LET p_qk2010.qk2_chave   = ' '    
   LET p_qk2010.qk2_ppap    = ' '
   LET p_qk2010.d_e_l_e_t_  =  ' '            
   LET p_qk2010.r_e_c_n_o_  = 0               
   LET p_qk2010.r_e_c_d_e_l_= 0               

   LET p_dig_1 = p_tela.cod_revisao[1] + 1
   LET p_dig_2 = p_tela.cod_revisao[2] + 1
   LET p_revinv[1] = pr_revinv[p_dig_1].letra
   LET p_revinv[2] = pr_revinv[p_dig_2].letra
   
   LET p_achou = FALSE

   LET sql_stmt = "SELECT r_e_c_n_o_ FROM ", p_instancia CLIPPED, "qk1010 ORDER BY 1 DESC "

   PREPARE var_qk1 FROM sql_stmt CLIPPED
   DECLARE cq_qk1 CURSOR FOR var_qk1
   
   FOREACH cq_qk1 INTO p_qk1010.r_e_c_n_o_
      LET p_achou = TRUE
      EXIT FOREACH
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_qk1010.r_e_c_n_o_ = 1
   ELSE
      LET p_qk1010.r_e_c_n_o_ = p_qk1010.r_e_c_n_o_ + 1
   END IF

   LET p_achou = FALSE

   LET sql_stmt = "SELECT r_e_c_n_o_ FROM ", p_instancia CLIPPED, "qk2010 ORDER BY 1 DESC "

   PREPARE var_qk2 FROM sql_stmt CLIPPED
   DECLARE cq_qk2 CURSOR FOR var_qk2

   FOREACH cq_qk2 INTO p_qk2010.r_e_c_n_o_
      LET p_achou = TRUE
      EXIT FOREACH
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_qk2010.r_e_c_n_o_ = 1
   ELSE
      LET p_qk2010.r_e_c_n_o_ = p_qk2010.r_e_c_n_o_ + 1
   END IF

   LET p_achou = FALSE

   LET sql_stmt = "SELECT r_e_c_n_o_ FROM ", p_instancia CLIPPED, "qkk010 ORDER BY 1 DESC "

   PREPARE var_qkk FROM sql_stmt CLIPPED
   DECLARE cq_qkk CURSOR FOR var_qkk
   
   FOREACH cq_qkk INTO p_qkk010.r_e_c_n_o_
      LET p_achou = TRUE
      EXIT FOREACH
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_qkk010.r_e_c_n_o_ = 1
   ELSE
      LET p_qkk010.r_e_c_n_o_ = p_qkk010.r_e_c_n_o_ + 1
   END IF

   LET p_achou = FALSE

   LET sql_stmt = "SELECT r_e_c_n_o_ FROM ", p_instancia CLIPPED, "qz3010 ORDER BY 1 DESC "

   PREPARE var_qz3 FROM sql_stmt CLIPPED
   DECLARE cq_qz3 CURSOR FOR var_qz3
   
   FOREACH cq_qz3 INTO p_qz3010.r_e_c_n_o_
      LET p_achou = TRUE
      EXIT FOREACH
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_qz3010.r_e_c_n_o_ = 1
   ELSE
      LET p_qz3010.r_e_c_n_o_ = p_qz3010.r_e_c_n_o_ + 1
   END IF

   LET p_qk1010.qk1_filial   = p_cod_empresa
   LET p_qk1010.qk1_peca     = p_tela.cod_item #p_tela.cod_peca_ppap
   LET p_qk1010.qk1_desc     = p_qk1_desc
   LET p_qk1010.qk1_rev      = p_tela.cod_revisao
   LET p_qk1010.qk1_dtrevi   = p_dat_revisao
   LET p_qk1010.qk1_revinv = p_revinv

   SELECT MAX(seq_versao)
     INTO p_seq_versao
     FROM cad_des
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item
       
   IF p_seq_versao IS NOT NULL THEN
      SELECT cod_desen,
             num_versao,
             dat_desen
        INTO p_qk1010.qk1_descli,
             p_qk1010.qk1_revcli,
             p_dat_txt
        FROM cad_des
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_tela.cod_item
         AND seq_versao  = p_seq_versao
         
      LET p_qk1010.qk1_dtrevc = p_dat_txt[7,10], p_dat_txt[4,5], p_dat_txt[1,2]
      #LET p_qk1010.qk1_ndes = p_qk1010.qk1_descli
   END IF
   
#   LET p_qk1010.qk1_dtrevi = p_tela.dat_revisao
   LET  p_qk1010.qk1_pccli = p_tela.cod_peca_ppap

   DECLARE cq_cli_item CURSOR FOR
    SELECT cod_cliente_matriz,
           cod_item_cliente
      FROM cliente_item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_tela.cod_item
    
    FOREACH cq_cli_item INTO 
            p_qk1010.qk1_codcli,
            p_qk1010.qk1_pccli
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql("Lendo","cliente_item")    
          CALL log085_transacao("ROLLBACK") 
          RETURN FALSE
       END IF
       
       EXIT FOREACH
    
    END FOREACH
    
    if p_qk1010.qk1_codcli is null or
       p_qk1010.qk1_codcli = ' ' then
    else
       select nom_cliente
         into p_qk1010.qk1_nomcli
         from clientes
        where cod_cliente = p_qk1010.qk1_codcli
       if status <> 0 then
          let p_qk1010.qk1_nomcli = ' '
       end if
    end if
       
    LET p_qk1010.qk1_pesoli = p_pes_unit
    
   LET sql_stmt = " INSERT INTO ", p_instancia CLIPPED, "qk1010( ",
    "qk1_filial,   qk1_peca,   qk1_rev, ",
    "qk1_revinv,   qk1_dtrevi, qk1_pccli, ",
    "qk1_descli,   qk1_ppap,   qk1_desc, ",
    "qk1_codcli,   qk1_lojcli, qk1_nomcli, ",
    "qk1_ndes,     qk1_revdes, qk1_dtrdes, ",
    "qk1_projet,   qk1_alteng, qk1_dteng, ",
    "qk1_doc,      qk1_tplogo, qk1_codequ, ",
    "qk1_produt,   qk1_revi,   qk1_just, ",
    "qk1_status,   qk1_dtence, qk1_dtreab, ",
    "qk1_licpk,    qk1_altdoc, qk1_lscpk, ",
    "qk1_nalprj,   qk1_codvcl, qk1_revcli, ",
    "qk1_dtrevc,   qk1_cjtdes, qk1_cjtrev, ",
    "qk1_cjrevd,   qk1_pesoli, qk1_cjpeso, ",
    "qk1_qtdecj,   qk1_codigo, qk1_usuari, ",
    "qk1_visto,    qk1_tipo,   qk1_pecseg, ",
    "qk1_fluxo,    qk1_msblql, qk1_dtelab, ",
    "qk1_okapro,   qk1_dtvist, d_e_l_e_t_, ",
    "r_e_c_n_o_,   r_e_c_d_e_l_) VALUES(",
   "'",p_qk1010.qk1_filial,"','",p_qk1010.qk1_peca,"','",p_qk1010.qk1_rev,"','",p_qk1010.qk1_revinv,"',",
   "'",p_qk1010.qk1_dtrevi,"','",p_qk1010.qk1_pccli,"','",p_qk1010.qk1_descli,"','",p_qk1010.qk1_ppap,"',",
   "'",p_qk1010.qk1_desc,"','",p_qk1010.qk1_codcli,"','",p_qk1010.qk1_lojcli,"','",p_qk1010.qk1_nomcli,"',",
   "'",p_qk1010.qk1_ndes,"','",p_qk1010.qk1_revdes,"','",p_qk1010.qk1_dtrdes,"','",p_qk1010.qk1_projet,"',",
   "'",p_qk1010.qk1_alteng,"','",p_qk1010.qk1_dteng,"','",p_qk1010.qk1_doc,"','",p_qk1010.qk1_tplogo,"',",
   "'",p_qk1010.qk1_codequ,"','",p_qk1010.qk1_produt,"','",p_qk1010.qk1_revi,"','",p_qk1010.qk1_just,"',",
   "'",p_qk1010.qk1_status,"','",p_qk1010.qk1_dtence,"','",p_qk1010.qk1_dtreab,"','",p_qk1010.qk1_licpk,"',",
   "'",p_qk1010.qk1_altdoc,"','",p_qk1010.qk1_lscpk,"','",p_qk1010.qk1_nalprj,"','",p_qk1010.qk1_codvcl,"',",
   "'",p_qk1010.qk1_revcli,"','",p_qk1010.qk1_dtrevc,"','",p_qk1010.qk1_cjtdes,"','",p_qk1010.qk1_cjtrev,"',",
   "'",p_qk1010.qk1_cjrevd,"','",p_qk1010.qk1_pesoli,"','",p_qk1010.qk1_cjpeso,"','",p_qk1010.qk1_qtdecj,"',",
   "'",p_qk1010.qk1_codigo,"','",p_qk1010.qk1_usuari,"','",p_qk1010.qk1_visto,"','",p_qk1010.qk1_tipo,"',",
   "'",p_qk1010.qk1_pecseg,"','",p_qk1010.qk1_fluxo,"','",p_qk1010.qk1_msblql,"','",p_qk1010.qk1_dtelab,"',",
   "'",p_qk1010.qk1_okapro,"','",p_qk1010.qk1_dtvist,"','",p_qk1010.d_e_l_e_t_,"',",
   "",p_qk1010.r_e_c_n_o_,",",p_qk1010.r_e_c_d_e_l_,")"
   
   PREPARE inc_qk1010 FROM sql_stmt CLIPPED
   EXECUTE inc_qk1010
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","qk1010")    
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF

   LET p_qk2010.qk2_filial   = p_cod_empresa
   LET p_qk2010.qk2_rev      = p_tela.cod_revisao
   LET p_qk2010.qk2_peca     = p_tela.cod_item #p_tela.cod_peca_ppap
   LET p_qk2010.qk2_item     = '0001'
   LET p_qk2010.qk2_codcar   = '0001'
   LET p_qk2010.qk2_desc     = '0001'
   LET p_qk2010.qk2_espe     = '0001'
   LET p_qk2010.qk2_tpcar    = '1'
   LET p_qk2010.qk2_prodpr   = '1'
   LET p_qk2010.qk2_planoc   = '2'
   LET p_qk2010.qk2_tol      = '100'
   LET p_qk2010.qk2_lie      = '-1'
   LET p_qk2010.qk2_lse      = '1'
   LET p_qk2010.qk2_esp      = '2'
   LET p_qk2010.qk2_simb     = 'F1'
   LET p_qk2010.qk2_um       = 'MM'         
   LET p_qk2010.qk2_revinv = p_revinv

   LET sql_stmt = " INSERT INTO ", p_instancia clipped, "qk2010( ",
   " qk2_filial, qk2_peca,   qk2_rev,    qk2_revinv, ",
   " qk2_item,   qk2_codcar, qk2_desc,   qk2_espe, ",
   " qk2_tpcar,  qk2_prodpr, qk2_planoc, qk2_tol, ",
   " qk2_lie,    qk2_lse,    qk2_esp,    qk2_simb, ",
   " qk2_um,     qk2_chave,  qk2_ppap,   r_e_c_d_e_l_, ",
   " d_e_l_e_t_, r_e_c_n_o_)  VALUES (",
   "'",p_qk2010.qk2_filial,"','",p_qk2010.qk2_peca,"','",p_qk2010.qk2_rev,"','",p_qk2010.qk2_revinv,"',",
   "'",p_qk2010.qk2_item,"','",p_qk2010.qk2_codcar,"','",p_qk2010.qk2_desc,"','",p_qk2010.qk2_espe,"',",
   "'",p_qk2010.qk2_tpcar,"','",p_qk2010.qk2_prodpr,"','",p_qk2010.qk2_planoc,"','",p_qk2010.qk2_tol,"',",
   "'",p_qk2010.qk2_lie,"','",p_qk2010.qk2_lse,"','",p_qk2010.qk2_esp,"','",p_qk2010.qk2_simb,"',",
   "'",p_qk2010.qk2_um,"','",p_qk2010.qk2_chave,"','",p_qk2010.qk2_ppap,"',",p_qk2010.r_e_c_d_e_l_,",",
   "'",p_qk2010.d_e_l_e_t_,"',",p_qk2010.r_e_c_n_o_,")" 

   PREPARE inc_qk2010 FROM sql_stmt CLIPPED
   EXECUTE inc_qk2010
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","qk2010")    
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF
   
   LET p_qkk010.qkk_filial   = p_cod_empresa
   LET p_qkk010.qkk_peca     = p_tela.cod_item #p_tela.cod_peca_ppap
   LET p_qz3010.qz3_peca     = p_tela.cod_item
   LET p_qkk010.qkk_rev      = p_tela.cod_revisao
   LET p_qz3010.qz3_revisa   = p_tela.cod_revisao
   LET p_qkk010.qkk_revinv   = p_revinv
   
   FOR p_ind = 1 TO ARR_COUNT()

       INSERT INTO compon_ppap_970
          VALUES(p_cod_empresa,
                 p_tela.cod_item,
                 pr_compon[p_ind].cod_compon,
                 pr_compon[p_ind].cod_operac,
                 pr_compon[p_ind].cod_oper_p,
                 pr_compon[p_ind].cod_simbolo)

       IF SQLCA.SQLCODE <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","compon_ppap_970")    
          CALL log085_transacao("ROLLBACK") 
          RETURN FALSE
       END IF
       
       let p_qkk010.qkk_pecalo = pr_compon[p_ind].cod_compon
       LET p_qz3010.qz3_sequen = pr_compon[p_ind].cod_oper_p
       
       SELECT qtd_peca_ciclo,
              qtd_peca_hor
         INTO p_qkk010.qkk_pccicl,
              p_qkk010.qkk_pchora
         FROM ciclo_peca_970
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = pr_compon[p_ind].cod_compon
          
       IF STATUS <> 0 THEN
          LET p_qkk010.qkk_pccicl = 0
          LET p_qkk010.qkk_pchora = 0
       END IF
       
	   LET p_pcseg            = 1 / p_qkk010.qkk_pchora 
       LET p_qkk010.qkk_pcseg = p_pcseg
       
       LET p_qkk010.qkk_maq =  ' '
       LET p_qkk010.qkk_desc = ' '
       LET p_qkk010.qkk_area = ' '
              
       SELECT cod_roteiro 
         INTO p_cod_roteiro
         FROM item_man
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = pr_compon[p_ind].cod_compon
       
        SELECT cod_arranjo,
               cod_operac,
               cod_cent_trab,
               qtd_pecas_ciclo
          INTO p_cod_arranjo,
               p_cod_operac,
               p_cod_cent_trab,
               p_qtd_pecas_ciclo
          FROM consumo
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = pr_compon[p_ind].cod_compon
           AND (cod_roteiro = p_cod_roteiro OR cod_roteiro IS NULL)
           
	      DECLARE cq_arr CURSOR FOR                   
	         SELECT cod_recur,
	                qtd_recur                          
	           FROM rec_arranjo                         
	          WHERE cod_empresa = p_cod_empresa         
	            AND cod_arranjo = p_cod_arranjo         
	          ORDER BY 1                                
	                                                    
	      FOREACH cq_arr INTO p_cod_recur, p_qtd_recur            
	          
	           SELECT den_recur,
	                  ies_tip_recur                        
	             INTO p_den_recur,
	                  p_ies_tip_recur                 
	             FROM recurso                           
	            WHERE cod_empresa   = p_cod_empresa     
	              AND cod_recur     = p_cod_recur   
             
             IF p_ies_tip_recur = '2' THEN
                let p_qkk010.qkk_maq    = p_cod_recur
				LET p_qkk010.qkk_nommaq = p_den_recur
             ELSE
                IF p_ies_tip_recur = '1' THEN 			
                   LET p_qkk010.qkk_qtdh = p_qtd_recur
                END IF
             END IF
	        
	      END FOREACH                                 

          LET p_qz3010.qz3_maquin = p_qkk010.qkk_maq
          LET p_qz3010.qz3_maoobr = p_qkk010.qkk_qtdh          
          
          SELECT den_operac
            INTO p_qkk010.qkk_desc
            FROM operacao
           WHERE cod_empresa = p_cod_empresa
             AND cod_operac  = p_cod_operac
              
          SELECT den_cent_trab
            INTO p_qkk010.qkk_area
            FROM cent_trabalho
           WHERE cod_empresa    = p_cod_empresa
             AND cod_cent_trab  = p_cod_cent_trab
          
       LET p_qkk010.qkk_tpope = 0
       
       SELECT cod_tip_oper
         INTO p_qkk010.qkk_tpope
         FROM simbolo_itaesbra
        WHERE cod_empresa = p_cod_empresa
          AND cod_simbolo = pr_compon[p_ind].cod_simbolo
              
       LET p_qkk010.qkk_nope     = pr_compon[p_ind].cod_oper_p
       LET p_qkk010.qkk_sbope    = pr_compon[p_ind].cod_simbolo
       
       LET p_qkk010.qkk_item     = pol0475_formata(p_ind)

       IF NOT pol0475_ins_qkk010()  THEN 
          RETURN FALSE
       END IF
       
   END FOR
   
   CALL log085_transacao("COMMIT") 
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0475_ins_qkk010()
#---------------------------#

   LET sql_stmt = " INSERT INTO ", p_instancia CLIPPED, "qkk010( ",
       "qkk_filial,   qkk_peca,   qkk_rev,    qkk_proces,  ",
       "qkk_revinv,   qkk_nope,   qkk_desc,   qkk_pecalo,  ",
       "qkk_maq,      qkk_nommaq, qkk_seqant, qkk_seqpos,  ",
       "qkk_chave,    qkk_planta, qkk_pccicl, qkk_qtdh,    ",
       "qkk_pchora,   qkk_pcseg,  qkk_bitmap, qkk_sbope,   ",
       "qkk_tpope,    qkk_item,   qkk_area,   qkk_func,    ",
       "qkk_msblql,   qkk_luva,   qkk_bota,   qkk_abafad,  ",
       "qkk_oculos,   qkk_aventa, qkk_mangot, qkk_simita,  ",
       "qkk_mascar,   d_e_l_e_t_, r_e_c_n_o_) VALUES (",
   "'",p_qkk010.qkk_filial,"','",p_qkk010.qkk_peca,"','",p_qkk010.qkk_rev,"','",p_qkk010.qkk_proces,"',",
   "'",p_qkk010.qkk_revinv,"','",p_qkk010.qkk_nope,"','",p_qkk010.qkk_desc,"','",p_qkk010.qkk_pecalo,"',",
   "'",p_qkk010.qkk_maq,"','",p_qkk010.qkk_nommaq,"','",p_qkk010.qkk_seqant,"','",p_qkk010.qkk_seqpos,"',",
   "'",p_qkk010.qkk_chave,"','",p_qkk010.qkk_planta,"','",p_qkk010.qkk_pccicl,"','",p_qkk010.qkk_qtdh,"',",
   "'",p_qkk010.qkk_pchora,"','",p_qkk010.qkk_pcseg,"','",p_qkk010.qkk_bitmap,"','",p_qkk010.qkk_sbope,"',",
   "'",p_qkk010.qkk_tpope,"','",p_qkk010.qkk_item,"','",p_qkk010.qkk_area,"','",p_qkk010.qkk_func,"',",
   "'",p_qkk010.qkk_msblql,"','",p_qkk010.qkk_luva,"','",p_qkk010.qkk_bota,"','",p_qkk010.qkk_abafad,"',",
   "'",p_qkk010.qkk_oculos,"','",p_qkk010.qkk_aventa,"','",p_qkk010.qkk_mangot,"','",p_qkk010.qkk_simita,"',",
   "'",p_qkk010.qkk_mascar,"','",p_qkk010.d_e_l_e_t_,"',",p_qkk010.r_e_c_n_o_,")"

   PREPARE inc_qkk010 FROM sql_stmt CLIPPED
   EXECUTE inc_qkk010
   
   IF STATUS = 0 THEN
      LET p_qkk010.r_e_c_n_o_ = p_qkk010.r_e_c_n_o_ + 1
   ELSE
      IF STATUS <> -239 THEN 
         CALL log003_err_sql("INCLUSAO","qkk010")    
         CALL log085_transacao("ROLLBACK") 
         RETURN FALSE
      END IF
   END IF

   LET sql_stmt = " INSERT INTO ", p_instancia CLIPPED, "qz3010( ",
       "qz3_filial,   qz3_proces,   qz3_peca,  ",
       "qz3_revisa,   qz3_sequen,   qz3_maquin,",
       "qz3_operad,   qz3_qtde,     qz3_maoobr,",
       "qz3_msblql,   d_e_l_e_t_,   r_e_c_n_o_) VALUES (",
   "'",p_qz3010.qz3_filial,"','",p_qz3010.qz3_proces,"','",p_qz3010.qz3_peca,"',",
   "'",p_qz3010.qz3_revisa,"','",p_qz3010.qz3_sequen,"','",p_qz3010.qz3_maquin,"',",
   "'",p_qz3010.qz3_operad,"','",p_qz3010.qz3_qtde,"','",p_qz3010.qz3_maoobr,"',",
   "'",p_qz3010.qz3_msblql,"','",p_qz3010.d_e_l_e_t_,"',",p_qz3010.r_e_c_n_o_,")"
   
   PREPARE inc_qz3010 FROM sql_stmt CLIPPED
   EXECUTE inc_qz3010
  
   IF STATUS = 0 THEN
      LET p_qz3010.r_e_c_n_o_ = p_qz3010.r_e_c_n_o_ + 1
   ELSE
      IF STATUS <> -239 THEN 
         CALL log003_err_sql("INCLUSAO","qz3010")    
         CALL log085_transacao("ROLLBACK") 
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol0475_formata(p_item)
#-------------------------------#

   DEFINE p_item     SMALLINT,
          p_retorno  CHAR(04),
          p_item_txt CHAR(04)
          
   LET p_item_txt = p_item
   
   IF LENGTH(p_item_txt CLIPPED) = 3 THEN
      LET p_retorno = '0',p_item_txt CLIPPED
   ELSE
      IF LENGTH(p_item_txt CLIPPED) = 2 THEN
         LET p_retorno = '00',p_item_txt CLIPPED
      ELSE
         IF LENGTH(p_item_txt CLIPPED) = 1 THEN
            LET p_retorno = '000',p_item_txt CLIPPED
         ELSE
            LET p_retorno = p_item_txt
         END IF
      END IF
   END IF
   RETURN (p_retorno)
   
END FUNCTION

#--------------------------#
 FUNCTION pol0475_consulta()
#--------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_item_ppap_970a.* = p_item_ppap_970.*
   
   CONSTRUCT BY NAME where_clause ON 
      item_ppap_970.cod_item,
      item_ppap_970.cod_revisao,
      item_ppap_970.dat_revisao,
      item_ppap_970.cod_peca_ppap

      ON KEY (control-z)
         CALL log009_popup(8,25,"ITENS","item_ppap_970",
                     "cod_item","","","S","") 
            RETURNING p_item_ppap_970.cod_item
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0475
         IF p_item_ppap_970.cod_item IS NOT NULL THEN
            DISPLAY p_item_ppap_970.cod_item TO cod_item
         END IF
         
   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0475

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_item_ppap_970.* = p_item_ppap_970a.*
      CALL pol0475_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_ppap_970 ",
                  " WHERE ", where_clause CLIPPED,                 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_item"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_item_ppap_970.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0475_exibe_dados()
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0475_exibe_dados()
#-----------------------------------#

   CLEAR FORM
   INITIALIZE p_den_item TO NULL
   
   SELECT den_item_reduz
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ppap_970.cod_item
  
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_item_ppap_970.cod_item TO cod_item
   DISPLAY p_den_item TO den_item
   DISPLAY p_item_ppap_970.cod_revisao   TO cod_revisao
   DISPLAY p_item_ppap_970.dat_revisao   TO dat_revisao
   DISPLAY p_item_ppap_970.cod_peca_ppap TO cod_peca_ppap
 
   CALL pol0475_exibe_compon()
   
 END FUNCTION

#------------------------------#
 FUNCTION pol0475_exibe_compon()
#------------------------------#

   DECLARE cq_comp CURSOR FOR 
    SELECT cod_compon,
           cod_oper_logix,
           cod_oper_siga,
           cod_simbolo
      FROM compon_ppap_970
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_item_ppap_970.cod_item

   LET p_index = 1
   
   FOREACH cq_comp INTO 
           pr_compon[p_index].cod_compon,
           pr_compon[p_index].cod_operac,
           pr_compon[p_index].cod_oper_p,
           pr_compon[p_index].cod_simbolo
           
      INITIALIZE pr_compon[p_index].den_operac TO NULL

      SELECT den_operac
        INTO pr_compon[p_index].den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = pr_compon[p_index].cod_operac

      SELECT den_simbolo
        INTO pr_compon[p_index].den_simbolo
        FROM simbolo_itaesbra
       WHERE cod_empresa = p_cod_empresa
         AND cod_simbolo = pr_compon[p_index].cod_simbolo      
          
      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_compon TO  sr_compon.*

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0475_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_item_ppap_970a.* = p_item_ppap_970.*
      CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                         p_item_ppap_970.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                         p_item_ppap_970.*
      END CASE

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Nao Existem Mais Itens Nesta Direção"
         LET p_item_ppap_970.* = p_item_ppap_970a.*
      ELSE
         CALL pol0475_exibe_dados()
      END IF
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0475_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0475
         IF p_codigo IS NOT NULL THEN
            IF p_input = 'C' THEN 
               LET p_tela.cod_item = p_codigo
               DISPLAY p_codigo TO cod_item
            ELSE
               LET pr_compon[p_index].cod_compon = p_codigo
               DISPLAY p_codigo TO sr_compon[s_index].cod_compon
            END IF
         END IF
         
      WHEN INFIELD(cod_simbolo)
         CALL log009_popup(8,25,"SIMBOLOS","simbolo_itaesbra",
                     "cod_simbolo","den_simbolo","pol0376","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0475
         IF p_codigo IS NOT NULL THEN
            LET pr_compon[p_index].cod_simbolo = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_simbolo
         END IF

   END CASE

END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#

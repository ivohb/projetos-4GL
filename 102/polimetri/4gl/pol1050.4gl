#-------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                              #
# PROGRAMA: pol1050                                                 #
# OBJETIVO: APONTAMENTO NA PRODU��O                                 #
# AUTOR...: WILLIANS                                                #
# DATA....: 25/08/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,
          p_user                LIKE usuario.nom_usuario,
          p_cod_cliente         LIKE clientes.cod_cliente,
          p_nom_cliente         LIKE clientes.nom_cliente,
          p_den_item_reduz      LIKE item.den_item_reduz,
          p_ies_forca_apont     CHAR(01),
          p_ies_tip_apont       CHAR(01),
          p_tem_erro            SMALLINT,
          p_consistido          SMALLINT,
          p_val_total           DECIMAL(11,2),
          p_qtd_solic           DECIMAL(10,2),
          p_opcao               CHAR(01),
          p_status              SMALLINT,
          p_count               SMALLINT,
          p_houve_erro          SMALLINT,
          comando               CHAR(80),
          p_ies_impressao       CHAR(01),
          g_ies_ambiente        CHAR(01),
          p_versao              CHAR(18),
          p_nom_arquivo         CHAR(100),
          p_nom_tela            CHAR(200),
          p_nom_help            CHAR(200),
          p_ies_cons            SMALLINT,
          p_caminho             CHAR(080),
          p_dat_txt             CHAR(10),
          p_dat_inv             CHAR(10),
          p_tot_ger             DECIMAL(13,2),
          p_retorno             SMALLINT,
          p_index               SMALLINT,
          s_index               SMALLINT,
          p_ind                 SMALLINT,
          s_ind                 SMALLINT,
          sql_stmt              CHAR(500),          
          where_clause          CHAR(500),          
          p_6lpp                CHAR(100),
          p_8lpp                CHAR(100),
          p_msg                 CHAR(600),
          p_last_row            SMALLINT,
          p_Comprime            CHAR(01),
          p_descomprime         CHAR(01),
          p_repetiu             SMALLINT,
          p_cod_embal_int       CHAR(3), 
          p_cod_embal_matriz    CHAR(3),
          p_den_defeito         CHAR(30),
          p_num_transac         INTEGER,
          p_cod_operacao        CHAR(5)

END GLOBALS
            
   DEFINE p_estoque_trans       RECORD LIKE estoque_trans.*,
          p_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
          p_estoque_lote_ender  RECORD LIKE estoque_lote_ender.*


   DEFINE p_apont_balan_454 RECORD          
    cod_empresa char(2),
    id_registro integer,
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    cod_roteiro char(15),
    num_rot_alt decimal(2,0),
    num_lote char(15),
    dat_inicial datetime year to day,
    dat_final datetime year to day,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_unid_prod char(5),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_apon char(1),
    tip_operacao char(1),
    cod_local_prod char(10),
    cod_local_est char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial datetime hour to second,
    hor_final datetime hour to second,
    unid_funcional char(10),
    dat_atualiz datetime year to second,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_processo integer,
    num_proc_ant integer,
    num_proc_dep integer,
    num_transac integer,
    mensagem char(210),
    dat_process datetime year to second
END RECORD

   
   DEFINE p_tela                RECORD 
          num_ordem             LIKE ordens.num_ordem,     
          cod_item              CHAR(15), 
          pes_unit              LIKE item.pes_unit,                                 
          pes_unit_embal        LIKE embalagem.pes_unit,
          pes_total             LIKE embalagem.pes_unit,
          qtd_pecas             DECIMAL(8,3),
          dat_inicial           DATE,
          hor_inicial           DATETIME HOUR TO MINUTE,
          dat_final             DATE,
          hor_final             DATETIME HOUR TO MINUTE,
          cod_turno             LIKE turno.cod_turno,
          num_matricula         char(08),
          cod_ferramenta        char(15),
          cod_eqpto             LIKE componente.cod_compon,
          qtd_rejei             DECIMAL(8,3),
          cod_defeito           DECIMAL(3,0)
   END RECORD
          
   DEFINE p_cod_item            LIKE item.cod_item,       
          p_den_item            LIKE item.den_item,
          p_num_docum           LIKE ordens.num_docum,
          p_num_docum_ant       LIKE ordens.num_docum,                  
          p_qtd_necessaria      LIKE ord_compon.qtd_necessaria,
          p_cod_local           LIKE ord_compon.cod_local_baixa,
          p_ctr_estoque         LIKE item.ies_ctr_estoque, 
          p_ctr_lote            LIKE item.ies_ctr_lote,
          p_ies_tip_item        LIKE item.ies_tip_item,
          p_sofre_baixa         LIKE item_man.ies_sofre_baixa,
          p_qtd_saldo           LIKE estoque_lote_ender.qtd_saldo,
          p_qtd_reservada       LIKE estoque_loc_reser.qtd_reservada,
          p_ies_oper_final      LIKE ord_oper.ies_oper_final,
          p_cod_item_compon     LIKE ord_compon.cod_item_compon,
          p_qtd_falta           CHAR(15),
          p_qtd_baixar          LIKE ord_compon.qtd_necessaria,
          p_cod_unid_med        LIKE item.cod_unid_med,
          p_hora_atual          DATETIME HOUR TO SECOND,
          p_parametro           LIKE consumo.parametro,
          p_qtd_horas           DECIMAL(11,7),
          p_qtd_hor_chr         CHAR(10),
          p_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup,
          p_qtd_estoque         LIKE estoque_lote.qtd_saldo,
          p_ies_situa           LIKE ordens.ies_situa,
          p_cod_embal           LIKE item_embalagem.cod_embal,
          p_qtd_boas            LIKE ordens.qtd_boas,
          p_qtd_pend            LIKE ordens.qtd_boas,
          p_qtd_refugos         LIKE ordens.qtd_refug,
          p_qtd_transf          LIKE ordens.qtd_refug,
          p_num_lote_refug      LIKE estoque_lote.num_lote,
          p_cod_local_refug     LIKE estoque_lote.cod_local,
          p_cod_item_refug      LIKE item.cod_item,
          p_qtd_sucatas         LIKE ordens.qtd_sucata,
          p_qtd_planej          LIKE ordens.qtd_planej,
          p_qtd_saldo_op        LIKE ordens.qtd_planej,
          p_msg_cod_item_compon CHAR(15),
          p_num_pedido          DECIMAL(6,0),
          p_num_seq_pedido      DECIMAL(5,0),  
          p_qtd_pecas           INTEGER,
          p_qtd_rejei           INTEGER,
          p_qtd_apont           DECIMAL(10,3),
          p_num_ordem           LIKE ordens.num_ordem,
          p_num_ordem_ant       LIKE ordens.num_ordem,
          p_id_registro         INTEGER,
          p_id_registro_ant     INTEGER,
          p_nom_usuario         CHAR(08),
          p_den_erro            CHAR(250),
          p_txt_1               CHAR(70),
          p_txt_2               CHAR(70),
          p_txt_3               CHAR(70),
          p_hor_inicial         DATETIME HOUR TO SECOND,
          p_hor_final           DATETIME HOUR TO SECOND,
          p_cod_ferramenta      char(15),
          p_cod_eqpto           char(15),
          p_matricula           char(08),
          p_cod_status          CHAR(01), 
          p_den_turno           LIKE turno.den_turno,         
          p_cod_turno           LIKE turno.cod_turno,
          p_dat_inicial         DATE,
          p_dat_final           DATE
           
   DEFINE pr_paradas            ARRAY[100] OF RECORD
          dat_par_inicial       DATE,
          hor_par_inicial       DATETIME HOUR TO SECOND,
          dat_par_final         DATE,
          hor_par_final         DATETIME HOUR TO SECOND,
          cod_parada            LIKE cfp_para.cod_parada,
          des_parada            LIKE cfp_para.des_parada
   END RECORD
   
   DEFINE pr_erros              ARRAY[200] OF RECORD
          den_erro              CHAR(250)
   END RECORD
         

   #-----------------------------------#
    # vari�vel p/ fun��o substr #
    # par�metros de retorno #

   DEFINE r_01 VARCHAR(255),
          r_02 VARCHAR(255),
          r_03 VARCHAR(255),
          r_04 VARCHAR(255),
          r_05 VARCHAR(255),
          r_06 VARCHAR(255),
          r_07 VARCHAR(255),
          r_08 VARCHAR(255),
          r_09 VARCHAR(255),
          r_10 VARCHAR(255),
          r_11 VARCHAR(255),
          r_12 VARCHAR(255),
          r_13 VARCHAR(255)
    
    # par�metros recebidos #
          
   DEFINE texto      VARCHAR(255),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)

    # vari�veis de uso interno
    
   DEFINE num_carac  SMALLINT,
          ret        VARCHAR(255)

   DEFINE p_param    RECORD 
          dat_ini    DATE,
          dat_fim    DATE,
          ies_listar CHAR(01)
   END RECORD          

DEFINE p_relat      RECORD
       dat_producao   DATE,
       num_ordem      INTEGER,
       cod_operac     CHAR(05),
       qtd_1050       INTEGER,
       qtd_r27        INTEGER,
       difer          INTEGER
END RECORD       

          
#-----------------------------------#

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   
   DEFER INTERRUPT
   LET p_versao = "pol1050-12.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1050.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_status = 0
   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   
   IF p_status = 0  THEN
      CALL pol1050_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1050_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1050") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1050 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   CALL pol1050_limpa_tela()

   MENU "MENU"
      
      COMMAND KEY ("N") "apoNtar" "Apontamento de produ��o."
         IF pol1050_informar() THEN
            CALL pol1050_aponta("N")
            IF p_tem_erro THEN
               LET p_msg = 'Houve cr�ticas no apontamento !!!'
               CALL pol1050_exib_erro()
            ELSE
               LET p_msg = 'Apontamento(s) efetuado(s) com sucesso !!!'
               CALL log0030_mensagem(p_msg,'excla')
            END IF
         ELSE
            ERROR "Opera��o Cancelada !!!"
         END IF        
      COMMAND "Consultar" "Acesso a op��es administrativas do programa."
         IF NOT pol1050_checa_administrador() THEN
            IF p_msg IS NOT NULL THEN
               CALL log0030_mensagem(p_msg, "exclamation")
            END IF
         ELSE
            CALL pol1050_opcoes()
         END IF                   
      COMMAND "Duplicitade" "Relat�rio de duplicidades"
         CALL pol1050_duplicidade()
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa."
         CALL pol1050_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   
   END MENU
  
   CLOSE WINDOW w_pol1050

END FUNCTION

#-----------------------#
 FUNCTION pol1050_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 05.10 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------------#
 FUNCTION pol1050_limpa_tela()
#-----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#---------------------------#
FUNCTION pol1050_exib_erro()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1050b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1050b AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   
   IF NOT pol1050_carrega_erros() THEN
      RETURN FALSE
   END IF

   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_erros TO sr_erros.*
   

END FUNCTION

#--------------------------#
 FUNCTION pol1050_informar()
#--------------------------#
   
   LET INT_FLAG = FALSE
   LET p_count  = 0
   
   #WHILE INT_FLAG = FALSE  - Manuel
      IF pol1050_informa_apontamento() THEN
         IF pol1050_informa_paradas() THEN 
            LET p_count = p_count + 1
         END IF 
      END IF 
   #END WHILE              - Manuel
   
   IF p_count = 0 THEN
      RETURN FALSE
   END IF 
   
   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol1050_checa_aen()
#---------------------------#

   DEFINE   p_cod_lin_prod         decimal(2,0),
	          p_cod_lin_recei        decimal(2,0),
	          p_cod_seg_merc         decimal(2,0),
	          p_cod_cla_uso          decimal(2,0),
            p_qtd_nivel_aen       integer

   SELECT qtd_nivel_aen
     INTO p_qtd_nivel_aen
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","pct_ajust_man912")
      RETURN FALSE
   END IF

	  if p_qtd_nivel_aen = 0 then
       LET p_msg = 'Apontamento de produ��o, em sua totalidade � efetuado\n',
                   'pela integra��o com EGA e o pol1050 n�o deve ser utilizado!'
       call log0030_mensagem(p_msg,'excla')
       RETURN FALSE
    end if

   select cod_lin_prod,
	        cod_lin_recei,
	        cod_seg_merc,
	        cod_cla_uso
	   into p_cod_lin_prod,
	        p_cod_lin_recei,
          p_cod_seg_merc,
          p_cod_cla_uso
     from item
    where cod_empresa = p_cod_empresa
      and cod_item    = p_cod_item
	    
   if status <> 0 then
      CALL log003_err_sql("LENDO","item")
      RETURN FALSE 
	 end if
	       
	 if p_qtd_nivel_aen < 4 then
	    let p_cod_cla_uso = 0
	 end if

	 if p_qtd_nivel_aen < 3 then
	    let p_cod_seg_merc = 0
	 end if

	 if p_qtd_nivel_aen < 2 then
	    let p_cod_lin_recei = 0
	 end if
	       
	 select cod_lin_prod
	   from aen_ega_logix_912
	  where cod_lin_prod  = p_cod_lin_prod
	    and cod_lin_recei = p_cod_lin_recei
	    and cod_seg_merc  = p_cod_seg_merc
	    and cod_cla_uso   = p_cod_cla_uso
	       
	  if status = 0 then
       LET p_msg = 'Item ', p_cod_item CLIPPED, ' � apontado pela integra��o com EGA\n',
                   'e n�o pode ser apontado pelo pol1050!'
       call log0030_mensagem(p_msg,'excla')
       RETURN FALSE
    else   
       if (status <> 0) and 
          (status <> 100) 	   then
          CALL log003_err_sql("LENDO","aen_ega_logix_912")
          RETURN FALSE 
       end if      
   end if
	 
	 RETURN TRUE

END FUNCTION 


#--------------------------------#
FUNCTION pol1050_cria_tab_balan()#
#--------------------------------#

   DROP TABLE apont_balan_454
   CREATE TEMP  TABLE apont_balan_454(
    cod_empresa char(2),
    id_registro integer,
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    cod_roteiro char(15),
    num_rot_alt decimal(2,0),
    num_lote char(15),
    dat_inicial datetime year to day,
    dat_final datetime year to day,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_unid_prod char(5),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_apon char(1),
    tip_operacao char(1),
    cod_local_prod char(10),
    cod_local_est char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial datetime hour to second,
    hor_final datetime hour to second,
    unid_funcional char(10),
    dat_atualiz datetime year to second,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_processo integer,
    num_proc_ant integer,
    num_proc_dep integer,
    num_transac integer,
    mensagem char(210),
    dat_process datetime year to second
  )


	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","APONT_BALAN_454")
			RETURN FALSE
	 END IF
 
   RETURN TRUE

END FUNCTION   

#-------------------------------------#
 FUNCTION pol1050_informa_apontamento()
#-------------------------------------#
   
   IF NOT pol1050_cria_tab_balan() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE 
   INITIALIZE p_tela, p_cod_item TO NULL
   CALL pol1050_limpa_tela()
   LET p_tela.dat_inicial = TODAY 
   LET p_tela.dat_final   = TODAY

   LET p_tela.qtd_pecas = 0
   LET p_tela.qtd_rejei = 0
        
   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD num_ordem
         
         IF p_tela.cod_item IS NOT NULL THEN
            NEXT FIELD cod_item
         END IF   
         
         LET p_num_ordem = NULL

      AFTER FIELD num_ordem
         
         IF p_tela.num_ordem IS NULL THEN
            NEXT FIELD cod_item
         END IF 
         
         IF NOT pol1050_le_op() THEN
            NEXT FIELD num_ordem
         END IF
         
         if NOT pol1050_checa_aen() then
            NEXT FIELD num_ordem
         END IF
         
         IF p_ies_situa <> '4' THEN
            ERROR "Esta ordem n�o est� liberada !!!"
            NEXT FIELD num_ordem
         END IF

         IF NOT pol1050_le_man() THEN
            NEXT FIELD num_ordem
         END IF
         
         #IF p_ies_tip_apont = '1' THEN
            LET p_ies_tip_apont = '2'
            LET p_num_ordem = p_tela.num_ordem
         #   LET p_tela.num_ordem = NULL
         #   NEXT FIELD cod_item
         #END IF
                  
         IF NOT pol1050_le_balan() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF p_qtd_saldo_op <= 0 THEN
               ERROR "N�o h� saldo suficiente para realizar um apontamento nesta OP !!!"
               NEXT FIELD num_ordem
            END IF
         END IF 

         IF NOT pol1050_le_embal() THEN
            RETURN FALSE
         END IF

         IF NOT pol1050_le_operacao() THEN
            RETURN FALSE
         END IF
                     
      BEFORE FIELD cod_item
         LET p_tela.cod_item = p_cod_item
         
         IF p_tela.num_ordem IS NOT NULL THEN
            NEXT FIELD pes_unit
         END IF   

      AFTER FIELD cod_item
         
         IF p_tela.cod_item IS NULL THEN
            NEXT FIELD num_ordem
         END IF   
         
         LET p_cod_item = p_tela.cod_item

         if NOT pol1050_checa_aen() then
            NEXT FIELD cod_item
         END IF
         
         IF NOT pol1050_le_man() THEN
            RETURN FALSE
         END IF
         
         LET p_ies_tip_apont = '1'
         #IF p_ies_tip_apont <> '1' THEN
         #   ERROR 'Item n�o parametrizado para apontar por item!'
         #   NEXT FIELD cod_item
         #END IF
         
         IF p_num_ordem IS NULL THEN
            IF NOT pol1050_le_pri_op() THEN
               RETURN FALSE
            END IF
            IF p_num_ordem IS NULL THEN
               ERROR 'N�o h� ordem liberada e com saldo p/ esse item!'
               NEXT FIELD cod_item
            END IF
         END IF
         
         LET p_tela.num_ordem = p_num_ordem
         DISPLAY p_num_ordem TO num_ordem
         
         IF NOT pol1050_le_op() THEN
            RETURN FALSE
         END IF
                  
         IF NOT pol1050_le_balan() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF p_qtd_saldo_op <= 0 THEN
               ERROR "N�o h� saldo suficiente apontar a quantidade informada !!!"
               NEXT FIELD cod_item
            END IF
         END IF 

         IF NOT pol1050_le_embal() THEN
            RETURN FALSE
         END IF

         IF NOT pol1050_le_operacao() THEN
            RETURN FALSE
         END IF
         
      AFTER FIELD pes_unit
         IF p_tela.pes_unit IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD pes_unit
         END IF   
         
         IF p_tela.pes_unit <= 0 THEN
            ERROR "Valor ilegal para o campo em quest�o !!!"
            NEXT FIELD pes_unit
         END IF
         
      AFTER FIELD pes_unit_embal
         IF p_tela.pes_unit_embal IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD pes_unit_embal
         END IF   
         
         IF p_tela.pes_unit_embal < 0 THEN
            ERROR "Valor ilegal para o campo em quest�o !!!"
            NEXT FIELD pes_unit_embal
         END IF
         
      AFTER FIELD pes_total
         IF p_tela.pes_total IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD pes_total
         END IF   
         
         IF p_tela.pes_total <= 0 THEN
            ERROR "Valor ilegal para o campo em quest�o !!!"
            NEXT FIELD pes_total
         END IF
         
         IF p_tela.pes_total <= p_tela.pes_unit_embal THEN
            ERROR "O peso total deve ser maior do que o peso da embalagem !!!"
            NEXT FIELD pes_total
         END IF 
         
         LET p_qtd_pecas = (p_tela.pes_total - p_tela.pes_unit_embal)/p_tela.pes_unit
         
         DISPLAY p_qtd_pecas TO qtd_pecas   
         
         LET p_tela.qtd_pecas = p_qtd_pecas
                    
      AFTER FIELD qtd_pecas

         IF p_tela.qtd_pecas IS NULL THEN
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_pecas
         END IF 

         LET p_qtd_apont = p_tela.qtd_pecas + p_tela.qtd_rejei
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF p_qtd_apont > p_qtd_saldo_op THEN
               ERROR "Quantidades boas + rejeitadas + pendentes maior que o saldo da OP !!!"
               NEXT FIELD qtd_pecas
            END IF
         END IF 

         IF NOT pol1050_verifica_componentes() THEN
            NEXT FIELD qtd_pecas
         END IF
         
      AFTER FIELD dat_inicial
         IF p_tela.dat_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_inicial
         END IF 
      
      BEFORE FIELD hor_inicial
         IF p_ies_tip_apont = '1' THEN
            LET p_tela.hor_inicial = '00:00'
            DISPLAY p_tela.hor_inicial TO hor_inicial
            NEXT FIELD dat_final
         END IF
      
      AFTER FIELD hor_inicial
         IF p_tela.hor_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD hor_inicial
         END IF
      
      AFTER FIELD dat_final
         IF p_tela.dat_final IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_final
         END IF
       
      BEFORE FIELD hor_final
         IF p_ies_tip_apont = '1' THEN
            LET p_tela.hor_final = '00:00'
            DISPLAY p_tela.hor_final TO hor_final
            NEXT FIELD cod_turno
         END IF

      AFTER FIELD hor_final
         IF p_tela.hor_final IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD hor_final
         END IF

         IF NOT pol1050_pega_turno() THEN
            RETURN FALSE
         END IF
         
         LET p_tela.cod_turno = p_cod_turno
         DISPLAY p_cod_turno TO cod_turno
         DISPLAY p_den_turno TO den_turno

      AFTER FIELD cod_turno
         IF p_tela.cod_turno IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD cod_turno
         END IF 
         
         LET p_cod_turno = p_tela.cod_turno
         
         SELECT den_turno
           INTO p_den_turno
           FROM turno
          WHERE cod_empresa = p_cod_empresa
            AND cod_turno   = p_cod_turno
         
         IF STATUS <> 0 THEN
            ERROR 'Turno n�o cadastrado!'
            NEXT FIELD cod_turno
         END IF
         
         DISPLAY p_den_turno TO den_turno          

      AFTER FIELD num_matricula
         IF p_tela.num_matricula IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD num_matricula
         END IF 
         
         SELECT num_matricula
           FROM funcionario
          WHERE cod_empresa   = p_cod_empresa
            AND num_matricula = p_tela.num_matricula
            
         IF STATUS = 100 THEN
            ERROR "Operador n�o encontrado na tabela funcionario !!!"
            NEXT FIELD num_matricula
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("Lendo", "funcionario")
               RETURN FALSE
            END IF 
         END IF
            
      AFTER FIELD cod_ferramenta
         IF p_tela.cod_ferramenta IS NOT NULL THEN
            
            SELECT cod_ferram
              FROM ferramentas
             WHERE cod_empresa = p_cod_empresa
               AND cod_ferram  = p_tela.cod_ferramenta
               
            IF STATUS = 100 THEN
               ERROR "Ferramenta n�o encontrada na tabela ferramentas !!!"
               NEXT FIELD cod_ferramenta
            ELSE
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("Lendo", "ferramentas")
                  RETURN FALSE
               END IF 
            END IF 
            
         END IF 
         
         LET p_apont_balan_454.cod_ferramenta = p_tela.cod_ferramenta
         
      AFTER FIELD cod_eqpto
         IF p_tela.cod_eqpto IS NOT NULL THEN
         
            SELECT cod_compon
              FROM componente
             WHERE cod_empresa = p_cod_empresa
               AND cod_compon  = p_tela.cod_eqpto

            IF STATUS = 100 THEN
               ERROR "Equipamento n�o encontrado na tabela componente !!!"
               NEXT FIELD cod_eqpto
            ELSE
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("Lendo", "componente")
                  RETURN FALSE
               END IF 
            END IF
         END IF
         
         LET p_apont_balan_454.cod_eqpto = p_tela.cod_eqpto
      
      AFTER FIELD qtd_rejei
      
         IF p_tela.qtd_rejei IS NULL THEN
            LET p_tela.qtd_rejei = 0
         ELSE
            LET p_qtd_apont = p_tela.qtd_pecas + p_tela.qtd_rejei
            IF p_ies_forca_apont = 'S' THEN
            ELSE
               IF p_qtd_apont > p_qtd_saldo_op THEN
                  ERROR "Quantidades boas + rejeitadas + pendentes maior que o saldo da OP !!!"
                  NEXT FIELD qtd_rejei
               END IF
            END IF
            IF NOT pol1050_verifica_componentes() THEN
               NEXT FIELD qtd_rejei
            END IF
         END IF 

         IF p_qtd_apont <= 0 THEN
            ERROR "A quantidade de pe�as + rejeitadas deve ser maior que zero !!!"
            NEXT FIELD qtd_pecas
         END IF 
                  
         IF p_tela.qtd_rejei = 0 THEN
            LET p_tela.cod_defeito = NULL
            DISPLAY ' ' TO cod_defeito
            DISPLAY ' ' TO den_defeito
            EXIT INPUT
         END IF

     AFTER FIELD cod_defeito
        
        IF p_tela.cod_defeito IS NULL THEN
           ERROR 'Campo com preenchimento obrigat�rio!'
           NEXT FIELD cod_defeito
        END IF
        
        SELECT den_defeito
          INTO p_den_defeito
          FROM defeito
         WHERE cod_empresa = p_cod_empresa
           AND cod_defeito = p_tela.cod_defeito
        
        IF STATUS <> 0 THEN
           ERROR 'Defeito n�o cadastrado!'
           NEXT FIELD cod_defeito
        END IF
        
        DISPLAY p_den_defeito TO den_defeito
                
      AFTER INPUT 
         IF NOT INT_FLAG THEN 
            IF p_tela.pes_total IS NULL THEN
               ERROR "Campo com prenchimento obrigat�rio !!!"
               NEXT FIELD pes_total
            END IF 
            
            IF p_tela.dat_final > TODAY THEN 
               ERROR "A data final n�o pode ser superior a data atual !!!"
               NEXT FIELD dat_final
            END IF 
      
            IF p_tela.dat_inicial > p_tela.dat_final THEN
               ERROR "A data inicial n�o pode ser maior que a data final !!!"
               NEXT FIELD dat_inicial
            END IF
         
            LET p_hora_atual = CURRENT HOUR TO SECOND  
         
            IF p_tela.dat_final = TODAY THEN
               IF p_tela.hor_final > p_hora_atual THEN
                  ERROR "A hora final n�o pode ser maior que a hora atual !!!"
                  NEXT FIELD hor_final
               END IF 
            END IF 
                        
            IF NOT pol1050_checa_data_de_fechamento() THEN
               IF p_msg IS NULL THEN
                  RETURN FALSE
               END IF 
               CALL log0030_mensagem(p_msg, "exclamation")
               NEXT FIELD dat_final 
            END IF 
            
            IF p_tela.dat_inicial = p_tela.dat_final THEN
               IF p_tela.hor_final < p_tela.hor_inicial THEN 
                  ERROR "A hora inicial n�o deve ser menor que a hora final !!!"
                  NEXT FIELD hor_inicial
               END IF 
               IF p_tela.hor_final > p_tela.hor_inicial THEN
                  LET p_qtd_hor_chr = p_tela.hor_final - p_tela.hor_inicial
               ELSE
                  LET p_qtd_hor_chr = '00:00'
               END IF
            ELSE
               IF p_tela.dat_inicial = '00:00' AND p_tela.dat_final = '00:00' THEN
                  LET p_qtd_hor_chr = '00:00'
               ELSE
                  LET p_qtd_hor_chr = '24:00:00' - (p_tela.hor_inicial - p_tela.hor_final)           
               END IF
            END IF
            
            IF p_qtd_hor_chr <> '00:00' THEN
               LET p_qtd_horas = pol1050_formata_hora()
            ELSE
               LET p_qtd_horas = 0
            END IF
                        
         END IF 
         
      ON KEY (control-z)
         CALL pol1050_popup('IA')
         
   END INPUT
   
   IF INT_FLAG = FALSE THEN
      RETURN TRUE 
   ELSE
      CALL pol1050_limpa_tela()
      RETURN FALSE
   END IF
      
END FUNCTION 

#---------------------------------#
 FUNCTION pol1050_informa_paradas()
#---------------------------------#

   LET INT_FLAG = FALSE 
   INITIALIZE pr_paradas TO NULL
   LET p_index = 1
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_paradas
      WITHOUT DEFAULTS FROM sr_paradas.*
      ATTRIBUTES(INSERT ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

            
      AFTER FIELD dat_par_inicial

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_paradas[p_index].dat_par_inicial IS NULL THEN
               ERROR "Campo com prenchimento obrigat�rio !!!"
               NEXT FIELD dat_par_inicial
            END IF
         END IF
               
      BEFORE FIELD hor_par_inicial
         IF pr_paradas[p_index].dat_par_inicial IS NULL THEN
            NEXT FIELD dat_par_inicial
         END IF 
         
       
      AFTER FIELD hor_par_inicial
         IF pr_paradas[p_index].hor_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD hor_par_inicial
         END IF 

         IF pr_paradas[p_index].dat_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_par_inicial
         END IF 
         
      BEFORE FIELD dat_par_final
         IF pr_paradas[p_index].hor_par_inicial IS NULL THEN
            NEXT FIELD hor_par_inicial
         END IF 
      
         IF pr_paradas[p_index].dat_par_final IS NULL THEN
            LET pr_paradas[p_index].dat_par_final = p_tela.dat_final
         END IF
            
      AFTER FIELD dat_par_final
         IF pr_paradas[p_index].dat_par_final IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_par_final
         END IF 

         IF pr_paradas[p_index].dat_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_par_inicial
         END IF 
        
         IF pr_paradas[p_index].hor_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD hor_par_inicial
         END IF
         
      BEFORE FIELD hor_par_final
         IF pr_paradas[p_index].dat_par_final IS NULL THEN
            NEXT FIELD dat_par_final
         END IF 

      AFTER FIELD hor_par_final
         IF pr_paradas[p_index].hor_par_final IS NULL THEN
            NEXT FIELD hor_par_final
         END IF 

         IF pr_paradas[p_index].dat_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_par_inicial
         END IF 
        
         IF pr_paradas[p_index].hor_par_inicial IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD hor_par_inicial
         END IF
            
         IF pr_paradas[p_index].dat_par_final IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD dat_par_final
         END IF
         
      BEFORE FIELD cod_parada
         IF pr_paradas[p_index].hor_par_final IS NULL THEN
            NEXT FIELD hor_par_final
         END IF 

      AFTER FIELD cod_parada
         IF pr_paradas[p_index].cod_parada IS NULL THEN
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD cod_parada
         END IF
                  
         SELECT des_parada
           INTO pr_paradas[p_index].des_parada
           FROM cfp_para
          WHERE cod_empresa = p_cod_empresa
            AND cod_parada  = pr_paradas[p_index].cod_parada
               
         IF STATUS = 100 THEN
            ERROR "Parada n�o cadastrada na tabela cfp_para !!!"
            NEXT FIELD cod_parada
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("Lendo", "cfp_para")
               RETURN FALSE
            END IF 
         END IF 
            
         DISPLAY pr_paradas[p_index].des_parada TO sr_paradas[s_index].des_parada  
                   
      AFTER ROW
         
         IF NOT INT_FLAG THEN
            IF pr_paradas[p_index].dat_par_inicial IS NOT NULL THEN                                                         
               IF pr_paradas[p_index].dat_par_final IS NULL THEN                                                            
                  IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN                                
                     DISPLAY "" TO sr_paradas[s_index].dat_par_inicial                                                      
                     LET pr_paradas[p_index].dat_par_inicial = NULL                                                           
                  ELSE                                                                                                      
                     NEXT FIELD dat_par_inicial                                                                             
                  END IF                                                                                                    
               END IF                                                                                                       
            END IF                                                                                                          
                                                                                                                            
            IF pr_paradas[p_index].dat_par_inicial < p_tela.dat_inicial THEN                                                
               ERROR "A data inicial da parada n�o pode ser menor do que a data inicial da produ��o !!!"                    
               NEXT FIELD dat_par_inicial                                                                                   
            END IF                                                                                                          
                                                                                                                            
            IF pr_paradas[p_index].dat_par_final > p_tela.dat_final THEN                                                    
               ERROR "A data final da parada n�o pode ser maior do que a data final da produ��o !!!"                        
               NEXT FIELD dat_par_final                                                                                     
            END IF                                                                                                          
                                                                                                                            
            IF pr_paradas[p_index].dat_par_inicial = pr_paradas[p_index].dat_par_final THEN                                 
               IF pr_paradas[p_index].hor_par_inicial >= pr_paradas[p_index].hor_par_final THEN                             
                  ERROR "A hora inicial da parada deve ser menor do que a hora final da parada !!!"                         
                  NEXT FIELD hor_par_inicial                                                                                
               END IF                                                                                                       
            ELSE                                                                                                            
               IF pr_paradas[p_index].dat_par_inicial > pr_paradas[p_index].dat_par_final THEN                              
                  ERROR "A data inicial da parada n�o pode ser maior do que a data final da parada !!!"                     
                  NEXT FIELD dat_par_inicial                                                                                
               END IF                                                                                                       
            END IF                                                                                                          
                                                                                                                            
            IF pr_paradas[p_index].dat_par_final = p_tela.dat_final THEN                                                    
               IF pr_paradas[p_index].hor_par_final > p_tela.hor_final THEN                                                 
                  ERROR "A hora final da parada n�o pode ser maior do que a hora final da produ��o !!!"                     
                  NEXT FIELD hor_par_final                                                                                  
               END IF                                                                                                       
            END IF                                                                                                          
                                                                                                                            
            IF pr_paradas[p_index].dat_par_inicial = p_tela.dat_inicial THEN                                                
               IF pr_paradas[p_index].hor_par_inicial < p_tela.hor_inicial THEN                                             
                  ERROR "A hora inicial da parada n�o pode ser menor do que a hora inicial da produ��o !!!"                 
                  NEXT FIELD hor_par_inicial                                                                                
               END IF                                                                                                       
            END IF                                                                                                          
        END IF
        
      AFTER INPUT 
         
         IF NOT INT_FLAG THEN
            IF NOT pol1050_verifica_array() THEN                                                                                                      
               ERROR "Prencha corretamente todos os valores nos campos da grade !!!"                                                                  
               NEXT FIELD dat_par_inicial                                                                                                             
            END IF                                                                                                                                    
                                                                                                                                                      
            LET p_repetiu = FALSE                                                                                                                     
                                                                                                                                                      
            FOR p_ind = 1 TO ARR_COUNT()                                                                                                              
               FOR p_index = 1 TO ARR_COUNT()                                                                                                         
                  IF p_index = p_ind THEN                                                                                                             
                     CONTINUE FOR                                                                                                                     
                  END IF                                                                                                                              
                  IF pr_paradas[p_ind].dat_par_inicial = pr_paradas[p_index].dat_par_inicial THEN                                                     
                     IF pr_paradas[p_ind].hor_par_inicial > pr_paradas[p_index].hor_par_inicial THEN                                                  
                        IF NOT pr_paradas[p_index].dat_par_final = pr_paradas[p_ind].dat_par_inicial THEN                                             
                           LET p_repetiu = TRUE                                                                                                       
                           EXIT FOR                                                                                                                   
                        ELSE                                                                                                                          
                           IF pr_paradas[p_index].hor_par_final >= pr_paradas[p_ind].hor_par_inicial THEN                                             
                              LET p_repetiu = TRUE                                                                                                    
                              EXIT FOR                                                                                                                
                           END IF                                                                                                                     
                        END IF                                                                                                                        
                     ELSE                                                                                                                             
                        IF NOT pr_paradas[p_ind].dat_par_final = pr_paradas[p_index].dat_par_inicial THEN                                             
                           LET p_repetiu = TRUE                                                                                                       
                           EXIT FOR                                                                                                                   
                        ELSE                                                                                                                          
                           IF pr_paradas[p_ind].hor_par_final >= pr_paradas[p_index].hor_par_inicial THEN                                             
                              LET p_repetiu = TRUE                                                                                                    
                              EXIT FOR                                                                                                                
                           END IF                                                                                                                     
                        END IF                                                                                                                        
                     END IF                                                                                                                           
                  ELSE                                                                                                                                
                     IF pr_paradas[p_ind].dat_par_inicial > pr_paradas[p_index].dat_par_inicial THEN                                                  
                        IF pr_paradas[p_index].dat_par_final > pr_paradas[p_ind].dat_par_inicial THEN                                                 
                           LET p_repetiu = TRUE                                                                                                       
                           EXIT FOR                                                                                                                   
                        ELSE                                                                                                                          
                           IF pr_paradas[p_index].dat_par_final = pr_paradas[p_ind].dat_par_inicial THEN                                              
                              IF NOT pr_paradas[p_index].hor_par_final < pr_paradas[p_ind].hor_par_inicial THEN                                       
                                 LET p_repetiu = TRUE                                                                                                 
                                 EXIT FOR                                                                                                             
                              END IF                                                                                                                  
                           END IF                                                                                                                     
                        END IF                                                                                                                        
                     ELSE                                                                                                                             
                        IF pr_paradas[p_ind].dat_par_final > pr_paradas[p_index].dat_par_inicial THEN                                                 
                           LET p_repetiu = TRUE                                                                                                       
                           EXIT FOR                                                                                                                   
                        ELSE                                                                                                                          
                           IF pr_paradas[p_ind].dat_par_final = pr_paradas[p_index].dat_par_inicial THEN                                              
                              IF NOT pr_paradas[p_ind].hor_par_final < pr_paradas[p_index].hor_par_inicial THEN                                       
                                 LET p_repetiu = TRUE                                                                                                 
                                 EXIT FOR                                                                                                             
                              END IF                                                                                                                  
                           END IF                                                                                                                     
                        END IF                                                                                                                        
                     END IF                                                                                                                           
                  END IF                                                                                                                              
               END FOR                                                                                                                                
               IF p_repetiu THEN                                                                                                                      
                  EXIT FOR                                                                                                                            
               END IF                                                                                                                                 
            END FOR                                                                                                                                   
                                                                                                                                                      
            IF p_repetiu THEN                                                                                                                         
               ERROR "Existem mais de uma parada que est�o contidas no mesmo intervalo de tempo !!!"                                                  
               NEXT FIELD dat_par_inicial                                                                                                             
            END IF                                                                                                                                    
         END IF  
      
      ON KEY (control-z)
         CALL pol1050_popup('IP')
         
   END INPUT
   
   IF INT_FLAG THEN
      CALL pol1050_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT log0040_confirm(20,25,"Confirma os dados informados ?") THEN  
      RETURN FALSE
   END IF 
         
   IF NOT pol1050_coleta_dados() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#----------------------#
FUNCTION pol1050_le_op()
#----------------------#

   SELECT cod_item,                                
          num_docum,                                     
          ies_situa,                                     
          qtd_planej,                                    
          qtd_boas,                                      
          qtd_refug,                                     
          qtd_sucata,                                    
          cod_local_prod,                                
          cod_local_estoq,                               
          num_lote,                                      
          cod_roteiro,                                   
          num_altern_roteiro                             
     INTO p_cod_item,                                    
          p_num_docum,                                   
          p_ies_situa,                                   
          p_qtd_planej,                                  
          p_qtd_boas,                                    
          p_qtd_refugos,                                 
          p_qtd_sucatas,                                 
          p_apont_balan_454.cod_local_prod,              
          p_apont_balan_454.cod_local_est,               
          p_apont_balan_454.num_lote,                    
          p_apont_balan_454.cod_roteiro,                 
          p_apont_balan_454.num_rot_alt                  
     FROM ordens                                         
    WHERE cod_empresa = p_cod_empresa                    
      AND num_ordem   = p_tela.num_ordem                 

   IF STATUS = 100 THEN
      ERROR "Ordem inexistente !!!"
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "ordens")
         RETURN FALSE
      END IF 
   END IF 

   IF p_qtd_planej IS NULL OR p_qtd_planej < 0 THEN                                     
      LET p_qtd_planej = 0                                                              
   END IF                                                                               
                                                                                        
   IF p_qtd_boas IS NULL OR p_qtd_boas < 0 THEN                                         
      LET p_qtd_boas = 0                                                                
   END IF                                                                               
                                                                                        
   IF p_qtd_refugos IS NULL OR p_qtd_refugos < 0 THEN                                   
      LET p_qtd_refugos = 0                                                             
   END IF                                                                               
                                                                                        
   IF p_qtd_sucatas IS NULL OR p_qtd_sucatas < 0 THEN                                   
      LET p_qtd_sucatas = 0                                                             
   END IF                                                                               
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1050_le_balan()
#--------------------------#

   SELECT SUM(qtd_boas + qtd_refugo)                                                           
     INTO p_qtd_pend                                                                    
     FROM apont_balan_454                                                               
    WHERE cod_empresa = p_cod_empresa                                                   
      AND num_ordem   = p_tela.num_ordem                                                
      AND cod_status IN ('N','P')                                                       
                                                                                        
   IF STATUS <> 0 THEN                                                                  
      CALL log003_err_sql("Lendo", "apont_balan_454")                                   
      RETURN FALSE                                                                      
   END IF                                                                               
                                                                                        
   IF p_qtd_pend IS NULL THEN                                                           
      LET p_qtd_pend = 0                                                                
   END IF                                                                               
                                                                                                                                                                                
   LET p_qtd_saldo_op = p_qtd_planej - p_qtd_boas - p_qtd_refugos - p_qtd_sucatas       
                                                                                        
   SELECT den_item,                                                                     
          pes_unit                                                                      
     INTO p_den_item,                                                                   
          p_tela.pes_unit                                                               
     FROM item                                                                          
    WHERE cod_empresa = p_cod_empresa                                                   
      AND cod_item    = p_cod_item                                                      
                                                                                        
   IF STATUS <> 0 THEN                                                                  
      CALL log003_err_sql("Lendo", "item")                                              
      RETURN FALSE                                                                      
   END IF                                                                               
                                                                                        
   DISPLAY p_ies_situa           TO ies_situa                                           
   DISPLAY p_qtd_planej          TO qtd_planej                                          
   DISPLAY p_qtd_saldo_op        TO qtd_saldo                                           
   DISPLAY p_qtd_pend            TO qtd_pend                                            
   DISPLAY p_cod_item            TO cod_item                                            
   DISPLAY p_den_item            TO den_item                                            
                                                                                        
   LET p_qtd_saldo_op = p_qtd_saldo_op - p_qtd_pend                                     
                                                                                  
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1050_le_embal()
#--------------------------#

   SELECT a.cod_embal,                                  
          b.cod_embal_matriz                                  
     INTO p_cod_embal_int,                                    
          p_cod_embal_matriz                                  
     FROM item_embalagem a,                                   
          embalagem b                                         
    WHERE a.cod_empresa   = p_cod_empresa                     
      AND a.cod_item      = p_cod_item                        
      AND a.cod_embal     = b.cod_embal                       
      AND a.ies_tip_embal IN ('I','N')                        
                                                              
   IF STATUS = 100 THEN                                       
      LET p_tela.pes_unit_embal = 0                           
   ELSE                                                       
      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql("Lendo", "item_embalagem")       
         RETURN FALSE                                         
      END IF                                                  
                                                              
      IF p_cod_embal_matriz IS NOT NULL THEN                  
         LET p_cod_embal = p_cod_embal_matriz                 
      ELSE                                                    
         LET p_cod_embal = p_cod_embal_int                    
      END IF                                                  
                                                              
      SELECT pes_unit                                         
        INTO p_tela.pes_unit_embal                            
        FROM embalagem                                        
       WHERE cod_embal = p_cod_embal                          
                                                              
      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql("Lendo", "embalagem")            
         RETURN FALSE                                         
      END IF                                                  
                                                              
   END IF          
   
   RETURN TRUE

END FUNCTION                                           

#-----------------------------#
FUNCTION pol1050_le_operacao()
#-----------------------------#

   SELECT cod_operac,                               
          num_seq_operac,                                 
          cod_cent_trab,                                  
          cod_arranjo,                                    
          cod_cent_cust                                   
     INTO p_apont_balan_454.cod_operac,                   
          p_apont_balan_454.num_seq_operac,               
          p_apont_balan_454.cod_cent_trab,                
          p_apont_balan_454.cod_arranjo,                  
          p_apont_balan_454.cod_cent_cust                 
     FROM ord_oper                                        
    WHERE cod_empresa    = p_cod_empresa                  
      AND num_ordem      = p_tela.num_ordem               
      AND ies_oper_final = 'S'                            
                                                          
   IF STATUS <> 0 THEN                                    
      CALL log003_err_sql("Lendo", "ord_oper")            
      RETURN FALSE                                        
   END IF                                                 
                                                          
   DISPLAY p_tela.pes_unit_embal TO pes_unit_embal        

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1050_le_man()
#------------------------#

   SELECT ies_tip_apont,
          ies_forca_apont
     INTO p_ies_tip_apont,
          p_ies_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Item_man')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION      

#--------------------------#
FUNCTION pol1050_le_pri_op()
#--------------------------#

   DEFINE p_ano_mes_entrega CHAR(07),
          p_dat_corrente    DATE,
          p_dat_entrega     DATE,
          p_num_op          INTEGER
   
   LET p_dat_corrente = TODAY
   LET p_ano_mes_entrega = EXTEND(p_dat_corrente, YEAR TO MONTH)
   
   LET p_num_ordem = NULL
   
   DECLARE cq_ops CURSOR FOR
    SELECT num_ordem,
           dat_entrega
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
       AND ies_situa   = '4'

   FOREACH cq_ops INTO p_num_op, p_dat_entrega
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens:cq_ops')
         RETURN FALSE
      END IF
      
      IF EXTEND(p_dat_entrega, YEAR TO MONTH) = p_ano_mes_entrega THEN
         LET p_num_ordem = p_num_op      
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION      
     

#----------------------------------#
 FUNCTION pol1050_popup(p_parametro)
#----------------------------------#

   DEFINE p_codigo    CHAR(15),
          p_parametro CHAR(02)

   CASE
     WHEN INFIELD(cod_ferramenta)
         IF p_parametro = 'IA' THEN
            CALL log009_popup(8,10,"FERRAMENTAS","ferramentas",
                        "cod_ferram","den_ferram","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_tela.cod_ferramenta = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_ferramenta
            END IF
         END IF
         
     WHEN INFIELD(cod_turno)
         IF p_parametro = 'IA' THEN
            CALL log009_popup(8,10,"TURNOS","turno",
                        "cod_turno","den_turno","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_tela.cod_turno = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_turno
            END IF
         END IF

     WHEN INFIELD(cod_eqpto)
         IF p_parametro = 'IA' THEN
            CALL log009_popup(8,10,"EQUIPAMENTOS","componente",
                        "cod_compon","des_compon","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_tela.cod_eqpto = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_eqpto
            END IF
         END IF
         
     WHEN INFIELD(num_matricula)
         IF p_parametro = 'IA' THEN
            CALL log009_popup(8,10,"OPERADORES","funcionario",
                        "num_matricula","nom_funcionario","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_tela.num_matricula = p_codigo CLIPPED
               DISPLAY p_codigo TO num_matricula
            END IF
         END IF
          
     WHEN INFIELD(cod_parada)
         IF p_parametro = 'IP' THEN
            CALL log009_popup(8,10,"PARADAS","cfp_para",
                        "cod_parada","des_parada","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET pr_paradas[p_index].cod_parada = p_codigo CLIPPED
               DISPLAY p_codigo TO sr_paradas[s_index].cod_parada
            END IF
         END IF 
         
     WHEN INFIELD(nom_usuario)
         IF p_parametro = 'CT' THEN
            CALL log009_popup(8,10,"USU�RIOS","usuarios",
                        "cod_usuario","nom_funcionario","","N","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_nom_usuario = p_codigo CLIPPED
               DISPLAY p_codigo TO nom_usuario
            END IF
         END IF 
     
     WHEN INFIELD(num_ordem)
       IF p_parametro = 'CP' OR p_parametro = 'LP' THEN
     
         LET p_codigo = pol1050_popup_pendentes()
         
         IF p_parametro = 'CP' THEN
            CURRENT WINDOW IS w_pol10501
         END IF
         
         IF p_parametro = 'LP' THEN
            CURRENT WINDOW IS w_pol10502
         END IF
                  
         IF p_codigo IS NOT NULL THEN
            LET p_num_ordem = p_codigo
            DISPLAY p_codigo TO num_ordem
         END IF  
       END IF 

     WHEN INFIELD(cod_defeito)
         IF p_parametro = 'IA' THEN
            CALL log009_popup(8,10,"DEFEITOS","defeito",
                        "cod_defeito","den_defeito","","S","")
                 RETURNING p_codigo
            CALL log006_exibe_teclas("01",p_versao)
            IF p_codigo IS NOT NULL THEN
               LET p_tela.cod_defeito = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_defeito
            END IF
         END IF         

   END CASE 
   
END FUNCTION 

#--------------------------------#
 FUNCTION pol1050_verifica_array()
#--------------------------------#

   DEFINE p_ies_correto SMALLINT
   
   LET p_ies_correto = TRUE
   
   FOR p_ind = 1 TO ARR_COUNT()  
      IF pr_paradas[p_ind].dat_par_inicial   IS NOT NULL THEN 
   
         IF pr_paradas[p_ind].hor_par_inicial   IS NULL OR 
            pr_paradas[p_ind].dat_par_final     IS NULL OR 
            pr_paradas[p_ind].hor_par_final     IS NULL OR 
            pr_paradas[p_ind].cod_parada        IS NULL THEN
         
            LET p_ies_correto = FALSE
            EXIT FOR
         END IF
      END IF
   END FOR   
      
   RETURN (p_ies_correto) 
   
END FUNCTION         

#-----------------------------#
 FUNCTION pol1050_pega_pedido()
#-----------------------------#

   DEFINE p_carac     CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3)

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
       
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_num_pedido     = p_numpedido
   LET p_num_seq_pedido = p_numseq

END FUNCTION


#------------------------------------------#
 FUNCTION pol1050_checa_data_de_fechamento()
#------------------------------------------#
   
   LET p_msg = NULL
   
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("lendo", "par_estoque")
      RETURN FALSE
   END IF 
   
   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_tela.dat_final <= p_dat_fecha_ult_man THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL !!!'
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_tela.dat_final < p_dat_fecha_ult_sup THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL !!!'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE 
   
END FUNCTION 

#------------------------------#
 FUNCTION pol1050_formata_hora()
#------------------------------#

   DEFINE p_hor   DECIMAL(9,7),
          p_min   integer,
          p_seg   integer
   
   LET p_qtd_hor_chr = p_qtd_hor_chr[2,9]
   
   IF p_qtd_hor_chr[1] = ' ' THEN 
      LET p_qtd_hor_chr[1] = 0
   END IF 
      
   LET p_hor = p_qtd_hor_chr[1,2]
   LET p_min = p_qtd_hor_chr[4,5]
   LET p_seg = p_qtd_hor_chr[7,8]  
   
   IF p_seg IS NULL THEN
      LET p_seg = 0
   END IF
   
   LET p_min = p_min * 60
   LET p_seg = p_seg + p_min
   LET p_hor = p_hor + (p_seg/3600)
   
   RETURN (p_hor)
 
END FUNCTION    

#--------------------------------------#
 FUNCTION pol1050_verifica_componentes()
#--------------------------------------#
   
   IF p_qtd_apont <= 0 THEN
      RETURN TRUE
   END IF
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_tela.num_ordem
       
   FOREACH cq_compon INTO
           p_cod_item_compon, 
           p_qtd_necessaria,
           p_cod_local

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ord_compon')
         RETURN FALSE
      END IF  
            
      IF NOT pol1050_le_item() THEN
         RETURN FALSE
      END IF

      IF NOT pol1050_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ctr_estoque = 'N' OR p_sofre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol1050_verifica_estoque() THEN
         RETURN FALSE
      END IF
      
      LET p_qtd_baixar = p_qtd_apont * p_qtd_necessaria
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_qtd_falta           = p_qtd_baixar - p_qtd_saldo
         LET p_msg_cod_item_compon = p_cod_item_compon
         LET p_msg = "N�o h� quantidade suficiente para realizar baixa no estoque, pois falta(m) ", 
                     p_qtd_falta CLIPPED, p_cod_unid_med CLIPPED, " do componente ", p_msg_cod_item_compon CLIPPED, " !!!"
         CALL log0030_mensagem(p_msg, 'exclamation')
         RETURN FALSE
      END IF  
         
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
 FUNCTION pol1050_le_item()
#-------------------------#

   SELECT ies_ctr_estoque,
          cod_unid_med,
          ies_ctr_lote,
          ies_tip_item,
          den_item
     INTO p_ctr_estoque,
          p_cod_unid_med,
          p_ctr_lote,
          p_ies_tip_item,
          p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1050_le_item_man()
#-----------------------------#

   SELECT ies_sofre_baixa
     INTO p_sofre_baixa
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon

   IF STATUS = 100 THEN
      LET p_sofre_baixa = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_man')
         RETURN FALSE
      END IF
   END IF  

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1050_verifica_estoque()
#----------------------------------#

   SELECT SUM(qtd_saldo)
     INTO p_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_cod_item_compon
	    AND cod_local     = p_cod_local
	    AND ies_situa_qtd = 'L'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender')
      RETURN FALSE
   END IF  

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon
      AND cod_local   = p_cod_local
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser')
      RETURN FALSE
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1050_coleta_dados()
#------------------------------#
   
   DEFINE p_ies_recur SMALLINT,
          p_hor_char  CHAR(08)
      
   IF NOT pol1050_prox_identificador() THEN
      RETURN FALSE
   END IF
   
   CALL pol1050_pega_pedido()
   
   LET p_apont_balan_454.cod_empresa    = p_cod_empresa
   LET p_apont_balan_454.num_ordem      = p_tela.num_ordem
   LET p_apont_balan_454.num_pedido     = p_num_pedido
   LET p_apont_balan_454.num_seq_pedido = p_num_seq_pedido
   LET p_apont_balan_454.cod_item       = p_cod_item
   LET p_apont_balan_454.dat_inicial    = p_tela.dat_inicial
   LET p_apont_balan_454.dat_final      = p_tela.dat_final
   
   LET p_hor_char                       = p_tela.hor_inicial, ':00' 
   LET p_apont_balan_454.hor_inicial    = p_hor_char
   
   LET p_hor_char                       = p_tela.hor_final, ':00'    
   LET p_apont_balan_454.hor_final      = p_hor_char

   IF p_qtd_horas IS NULL THEN
      LET p_apont_balan_454.qtd_hor = 0
   ELSE
      LET p_apont_balan_454.qtd_hor = p_qtd_horas
   END IF
   
   LET p_apont_balan_454.matricula      = p_tela.num_matricula
   LET p_apont_balan_454.tip_apon       = 'F'
   LET p_apont_balan_454.qtd_refugo     = 0
   LET p_apont_balan_454.qtd_sucata     = 0
   LET p_apont_balan_454.qtd_boas       = p_tela.qtd_pecas
   LET p_apont_balan_454.qtd_refugo     = p_tela.qtd_rejei   
   LET p_apont_balan_454.nom_prog       = 'pol1050'
   LET p_apont_balan_454.nom_usuario    = p_user
   LET p_apont_balan_454.cod_status     = 'N'
   LET p_apont_balan_454.largura        = 0
   LET p_apont_balan_454.comprimento    = 0
   LET p_apont_balan_454.altura         = 0
   LET p_apont_balan_454.diametro       = 0
   LET p_apont_balan_454.tip_operacao   = 'F'
   LET p_apont_balan_454.ies_terminado  = 'N'
   LET p_apont_balan_454.num_processo   = 0
   LET p_apont_balan_454.num_proc_ant   = 0 
   LET p_apont_balan_454.num_proc_dep   = 0
   LET p_apont_balan_454.oper_final     = 'S'
   LET p_apont_balan_454.num_lote       = pol1050_calcula_lote()
   LET p_apont_balan_454.cod_turno      = p_cod_turno
      
   LET p_ies_recur = FALSE
      
   DECLARE cq_recurso CURSOR FOR   
    SELECT a.cod_recur
      FROM rec_arranjo a,
           recurso b
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.cod_arranjo   = p_apont_balan_454.cod_arranjo
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_recur     = a.cod_recur
       AND b.ies_tip_recur = '2'
       
   FOREACH cq_recurso INTO p_apont_balan_454.cod_recur

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_recurso')
         RETURN FALSE
      END IF
         
      LET p_ies_recur = TRUE
      
      EXIT FOREACH 
         
   END FOREACH

   IF NOT p_ies_recur THEN
      LET p_msg = 'Recurso n�o cadastrado para o arranjo ',p_apont_balan_454.cod_arranjo CLIPPED, ' !!!'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF

  SELECT cod_unid_prod 
    INTO p_apont_balan_454.cod_unid_prod
    FROM cent_trabalho
   WHERE cod_empresa   = p_cod_empresa
     AND cod_cent_trab = p_apont_balan_454.cod_cent_trab

  IF STATUS = 100 THEN
     LET p_msg = 'Unidade produtiva n�o cadastrada na tabela cent_trabalho ',
                 'para centro de trabalho = ', p_apont_balan_454.cod_cent_trab
  ELSE
     IF STATUS <> 0 THEN
        LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA CENT_TRABALHO'
        RETURN FALSE
     END IF
  END IF
   
   IF p_apont_balan_454.cod_unid_prod IS NULL THEN
      LET p_apont_balan_454.cod_unid_prod = ' '
   END IF
   
   LET p_apont_balan_454.dat_atualiz  = CURRENT            
   LET p_apont_balan_454.num_transac  = 0
   
   DECLARE cq_funcio CURSOR FOR 
	  SELECT cod_uni_funcio 
		  FROM uni_funcional a, ord_oper b
		 WHERE a.cod_empresa      = p_cod_empresa
			 AND a.cod_empresa      = b.cod_empresa
			 AND a.cod_centro_custo = b.cod_cent_cust
		   AND b.num_ordem        = p_apont_balan_454.num_ordem
			 AND b.cod_operac       = p_apont_balan_454.cod_operac
		 	 AND b.num_seq_operac   = p_apont_balan_454.num_seq_operac
       AND a.dat_validade_ini <=CURRENT YEAR TO SECOND  
       AND a.dat_validade_fim >=CURRENT YEAR TO SECOND					
																		
	 FOREACH cq_funcio INTO p_apont_balan_454.unid_funcional 

      IF SQLCA.SQLCODE<> 0 THEN
	       CALL log003_err_sql("Lendo","cq_funcio" )
	    END IF 
					
		  IF p_apont_balan_454.unid_funcional IS NOT NULL THEN
				 EXIT FOREACH
			END IF 
					
	 END FOREACH
   
   IF NOT pol1050_insere_dados() THEN
      RETURN FALSE
   END IF

   RETURN TRUE   

END FUNCTION

#------------------------------#
FUNCTION pol1050_calcula_lote()
#------------------------------#

   DEFINE p_dia  INTEGER,
          p_lote CHAR(15),
          p_dig  CHAR(02)
   
   LET p_dia = DAY(TODAY)
   
   IF p_dia <= 5 THEN
      LET p_dig = '-1'
   ELSE
      IF p_dia <= 10 THEN
         LET p_dig = '-2'
      ELSE
         IF p_dia <= 15 THEN
            LET p_dig = '-3'
         ELSE
            IF p_dia <= 20 THEN
               LET p_dig = '-4'
            ELSE
               IF p_dia <= 25 THEN
                  LET p_dig = '-5'
               ELSE
                  LET p_dig = '-6'
               END IF
            END IF
         END IF
      END IF
   END IF
   
   LET p_lote = p_tela.num_ordem USING '<<<<<<<<<', p_dig
   
   RETURN(p_lote)
   
END FUNCTION
         
#------------------------------------#
 FUNCTION pol1050_prox_identificador()
#------------------------------------#
   
   DEFINE p_id_registro_apont INTEGER,
          p_id_registro_hist  INTEGER
   
   SELECT MAX(id_registro)
     INTO p_id_registro_hist
     FROM hist_apont_bl_454
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','hist_apont_bl_454')
      RETURN FALSE
   END IF
   
   IF p_id_registro_hist IS NOT NULL THEN
      LET p_id_registro_hist = p_id_registro_hist + 1
   ELSE
      LET p_id_registro_hist = 1
   END IF 
   
   LET p_apont_balan_454.id_registro = p_id_registro_hist
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1050_pega_turno()
#----------------------------#

   DEFINE p_minutos    SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora_seg   CHAR(08),
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04)
   
   LET p_hora_seg = p_tela.hor_inicial
   LET p_hora     = p_hora_seg[1,5]
   LET p_minutos  = (p_hora[1,2] * 60) + p_hora[4,5]

   LET p_msg = 'HORA INICIO APONTAMENTO FORA DOS TURNOS LOGIX'
   
   DECLARE cq_turno CURSOR FOR
    SELECT cod_turno,
           hor_ini_normal,
           hor_fim_normal,
           den_turno
      FROM turno
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_turno INTO 
           p_cod_turno,
           p_hor_ini,
           p_hor_fim,
           p_den_turno
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor:cq_turno')
         RETURN FALSE
      END IF
      
      LET p_min_ini = (p_hor_ini[1,2] * 60) + p_hor_ini[3,4]   
      LET p_min_fim = (p_hor_fim[1,2] * 60) + p_hor_fim[3,4]   
      
      IF p_min_fim < p_min_ini THEN
         LET p_min_fim = p_min_fim + 1440
         IF p_minutos < p_min_ini THEN
            LET p_minutos = p_minutos + 1440
         END IF
      END IF
      
      IF p_minutos >= p_min_ini AND p_minutos < p_min_fim THEN
         LET p_msg = NULL
         EXIT FOREACH
      END IF

   END FOREACH

   IF p_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1050_insere_dados()
#------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   LET p_apont_balan_454.dat_process = CURRENT
   
   INSERT INTO apont_balan_454
      VALUES(p_apont_balan_454.*)
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','apont_balan_454')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   IF pr_paradas IS NOT NULL THEN
      IF NOT pol1050_insere_paradas() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF
   
   CALL log085_transacao("COMMIT")
         
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1050_insere_paradas()
#--------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
      IF pr_paradas[p_ind].dat_par_inicial IS NOT NULL THEN 
         INSERT INTO apont_parada_454(
          cod_empresa,
          id_registro,
          dat_inicial,
          hor_inicial,
          dat_final,  
          hor_final,  
          cod_parada)
            VALUES(
             p_cod_empresa,
             p_apont_balan_454.id_registro,
             pr_paradas[p_ind].dat_par_inicial,
             pr_paradas[p_ind].hor_par_inicial,
             pr_paradas[p_ind].dat_par_final,
             pr_paradas[p_ind].hor_par_final,
             pr_paradas[p_ind].cod_parada)
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Inserindo","apont_parada_454")
            RETURN FALSE
         END IF
      ELSE
         EXIT FOR
      END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION      

#-------------------------------------#
 FUNCTION pol1050_checa_administrador()
#-------------------------------------#

   LET p_msg = NULL
   
   SELECT cod_usuario
     FROM usuario_adm_454
    WHERE cod_usuario = p_user
      
   IF STATUS = 100 THEN
      LET p_msg = "Usu�rio n�o autorizado � acionar esta fun��o !!!"
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "usuario_adm_454")
         RETURN FALSE
      END IF 
   END IF 
   
   RETURN TRUE
   
END FUNCTION

#------------------------#
 FUNCTION pol1050_opcoes()
#------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10505") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10505 AT 3,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1050_limpa_tela()
         
   MENU "OP��ES"
      
      {COMMAND "Pendentes" "Consulta/Listagem/Exclus�o dos apontamentos pendentes."
         LET p_ies_cons = FALSE
         CALL pol1050_pendentes()}
      COMMAND "Processados" "Consulta/Listagem dos apontamentos processados com sucesso."
         LET p_ies_cons = FALSE
         CALL pol1050_processados() 
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   
   END MENU
   
   CLOSE WINDOW w_pol10505
   
END FUNCTION

#---------------------------#
 FUNCTION pol1050_pendentes()
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10501") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10501 AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1050_limpa_tela()
   LET p_ies_cons = FALSE
      
   MENU "PENDENTES"
      
      COMMAND "Consultar" "Consulta dos apontamentos pendentes."
         IF NOT pol1050_consultar_pendentes() THEN
            ERROR "Consulta cancelada !!!"
            LET p_ies_cons = FALSE
         ELSE
            ERROR "Consulta efetuada com sucesso !!!"
            NEXT OPTION "Seguinte"
         END IF
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1050_paginacao_pendentes("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1050_paginacao_pendentes("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Listar" "Listagem dos apontamentos pendentes."
         IF NOT pol1050_listar_pendentes() THEN
            ERROR "Opera��o cancelada !!!"
         ELSE
            ERROR "Listagem efetuada com sucesso !!!"
         END IF
      COMMAND "Excluir" "Exclus�o dos apontamentos pendentes."
         IF p_ies_cons THEN
            IF NOT pol1050_excluir_pendentes() THEN
               ERROR "Opera��o cancelada !!!"
            ELSE
               ERROR "Exclus�o efetuada com sucesso !!!"
            END IF
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Reprocessar" "Processa apontamentos criticados."
         IF log004_confirm(20,25) THEN
            CALL pol1050_aponta("P")
            IF p_tem_erro THEN
               LET p_msg = 'Houve cr�ticas no apontamento !!!'
            ELSE
               LET p_msg = 'Apontamento(s) efetuado(s) com sucesso !!!'
            END IF
            CALL log0030_mensagem(p_msg,'exclamation')
         END IF
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   
   END MENU
   
   CLOSE WINDOW w_pol10501
   
END FUNCTION

#-------------------------------------#
 FUNCTION pol1050_consultar_pendentes()
#-------------------------------------#
      
   CALL pol1050_limpa_tela()
      
   LET p_id_registro_ant = p_id_registro
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      apont_balan_454.num_ordem
      
      ON KEY (control-z)
         CALL pol1050_popup('CP')
         
   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_id_registro = p_id_registro_ant
         CALL pol1050_exibe_pendentes() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT id_registro, num_ordem, dat_inicial, hor_inicial",
                  "  FROM apont_balan_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY num_ordem, dat_inicial, hor_inicial"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1050_exibe_pendentes() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#---------------------------------#
 FUNCTION pol1050_exibe_pendentes()
#---------------------------------#
   
   SELECT num_ordem,
          cod_item,
          qtd_boas,
          qtd_refugo,
          nom_usuario,
          dat_inicial,
          hor_inicial,
          dat_final,
          hor_final,
          cod_status
     INTO p_num_ordem,
          p_cod_item,
          p_qtd_pecas,
          p_qtd_rejei,
          p_nom_usuario,
          p_dat_inicial,
          p_hor_inicial,
          p_dat_final,
          p_hor_final,
          p_cod_status         
     FROM apont_balan_454
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = p_id_registro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "apont_balan_454")
      RETURN FALSE
   END IF
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "item")
      RETURN FALSE
   END IF
   
   IF NOT pol1050_carrega_erros() THEN
      RETURN FALSE
   END IF
   
   CALL pol1050_limpa_tela()
      
   DISPLAY p_num_ordem   TO num_ordem
   DISPLAY p_qtd_pecas   TO qtd_pecas
   DISPLAY p_qtd_rejei   TO qtd_rejei
   DISPLAY p_cod_item    TO cod_item
   DISPLAY p_nom_usuario TO nom_usuario
   DISPLAY p_den_item    TO den_item   
   DISPLAY p_dat_inicial TO dat_inicial
   DISPLAY p_hor_inicial TO hor_inicial
   DISPLAY p_dat_final   TO dat_final
   DISPLAY p_hor_final   TO hor_final
   DISPLAY p_cod_status  TO cod_status   
   
   IF p_index > 1 THEN
   
      CALL SET_COUNT(p_index - 1)
      
      IF p_index > 9 THEN
         DISPLAY ARRAY pr_erros TO sr_erros.*
      ELSE
         INPUT ARRAY pr_erros
            WITHOUT DEFAULTS FROM sr_erros.*
            ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
         
            BEFORE INPUT
               EXIT INPUT
            
         END INPUT
      END IF
   
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1050_carrega_erros()
#-------------------------------#

   INITIALIZE pr_erros TO NULL
   LET p_index = 1 
   
   DECLARE cq_erros CURSOR FOR
   
    SELECT den_erro
      FROM apont_erro_454
     WHERE cod_empresa = p_cod_empresa
       AND id_registro = p_id_registro
       
   FOREACH cq_erros
      INTO p_den_erro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_erros")
         RETURN FALSE
      END IF
            
      CALL substr(p_den_erro,70,3,'S') 
           RETURNING p_txt_1, p_txt_2, p_txt_3
           
      IF p_txt_1 IS NOT NULL THEN
         LET pr_erros[p_index].den_erro = p_txt_1
         LET p_index = p_index + 1
         
         IF p_txt_2 IS NOT NULL THEN
            LET pr_erros[p_index].den_erro = p_txt_2
            LET p_index = p_index + 1
           
            IF p_txt_3 IS NOT NULL THEN
               LET pr_erros[p_index].den_erro = p_txt_3
               LET p_index = p_index + 1
            END IF
         END IF
      END IF
      
      IF p_index > 200 THEN
         ERROR "Limite de grade ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol1050_paginacao_pendentes(p_funcao)
#---------------------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      
      LET p_id_registro_ant = p_id_registro
      
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                            
            WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro 
                            
         END CASE

         IF status = 100 THEN
            ERROR "Nao existem mais itens nesta dire��o !!!"
            LET p_id_registro = p_id_registro_ant 
            EXIT WHILE
         END IF

         
         SELECT COUNT(num_ordem)
           INTO p_count
           FROM apont_balan_454
          WHERE cod_empresa = p_cod_empresa
            AND id_registro = p_id_registro
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo", "apont_balan_454")
            EXIT WHILE 
         END IF 
         
         IF p_count > 0 THEN
            CALL pol1050_exibe_pendentes() RETURNING p_status
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "N�o existe nenhuma consulta ativa !!!"
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol1050_listar_pendentes()
#----------------------------------#
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10502") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10502 AT 7,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   CALL pol1050_limpa_tela()
      
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      apont_balan_454.num_ordem
      
      ON KEY(control-z)
         CALL pol1050_popup('LP')
         
   END CONSTRUCT
   
   IF INT_FLAG THEN    
      RETURN FALSE 
   END IF
   
   IF NOT pol1050_escolhe_saida_pendentes() THEN
   		RETURN FALSE
   END IF
   
   IF NOT pol1050_le_empresa() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 0

   LET sql_stmt = "SELECT id_registro, num_ordem, cod_item, qtd_boas, qtd_refugo,",
                  "  nom_usuario,  dat_inicial, hor_inicial",
                  "  FROM apont_balan_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY num_ordem, dat_inicial, hor_inicial"

   PREPARE var_query_1 FROM sql_stmt   
   
   DECLARE cq_listar_pendencias CURSOR FOR var_query_1
        
   FOREACH cq_listar_pendencias
      INTO p_id_registro,
           p_num_ordem,
           p_cod_item,
           p_qtd_pecas,
           p_qtd_rejei,
           p_nom_usuario
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "Cursor: cq_listar_pendencias")
         RETURN FALSE
      END IF
      
      SELECT den_item_reduz
        INTO p_den_item_reduz 
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "item")
         RETURN FALSE
      END IF   
      
      OUTPUT TO REPORT pol1050_relat_pendentes()
      
      LET p_count = 1
      
   END FOREACH
   
   FINISH REPORT pol1050_relat_pendentes
   
   IF p_count = 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      RETURN FALSE
   ELSE 
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1050_popup_pendentes()
#--------------------------------#

   DEFINE pr_ordens_pendentes ARRAY[1000] OF RECORD
          num_ordem           INTEGER
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10504") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10504 AT 5,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   DECLARE cq_ordens_pendentes CURSOR FOR
   
    SELECT num_ordem
      FROM apont_balan_454
     WHERE cod_empresa = p_cod_empresa
       AND cod_status  = 'P'

   FOREACH cq_ordens_pendentes 
      INTO pr_ordens_pendentes[p_ind].num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Cursor: cq_ordens_pendentes')
         RETURN FALSE
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_ordens_pendentes TO sr_ordens_pendentes.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10504
   
   IF NOT INT_FLAG THEN
      RETURN pr_ordens_pendentes[p_ind].num_ordem
   ELSE
      LET INT_FLAG = FALSE
      RETURN ""
   END IF
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1050_escolhe_saida_pendentes()
#----------------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1050.tmp"
         START REPORT pol1050_relat_pendentes TO p_caminho
      ELSE
         START REPORT pol1050_relat_pendentes TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   


#-------------------------------#
 REPORT pol1050_relat_pendentes()
#-------------------------------#
      
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
             
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 069, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1050",
               COLUMN 013, "LISTAGEM DOS APONTAMENTOS PENDENTES",
               COLUMN 050, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         
      PAGE HEADER  
          
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 069, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1050",
               COLUMN 013, "LISTAGEM DOS APONTAMENTOS PENDENTES",
               COLUMN 050, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
                            
      ON EVERY ROW
         
         PRINT
         PRINT COLUMN 001, '   Ordem       Item           Descricao          Boas     Rejeitadas  Usuario'
         PRINT COLUMN 001, '---------- --------------- ------------------ ----------- ----------- ---------'
         
         PRINT COLUMN 001, p_num_ordem       USING "##########",
               COLUMN 012, p_cod_item,
               COLUMN 028, p_den_item_reduz, 
               COLUMN 047, p_qtd_pecas       USING "######&.&&&",
               COLUMN 059, p_qtd_rejei       USING "######&.&&&",
               COLUMN 071, p_nom_usuario
       
         PRINT
         PRINT COLUMN 037, 'Erros' 
         PRINT COLUMN 001, '     ---------------------------------------------------------------------'
        
         DECLARE cq_listar_erros CURSOR FOR
        
          SELECT den_erro
            FROM apont_erro_454
           WHERE cod_empresa = p_cod_empresa
             AND id_registro = p_id_registro
       
         FOREACH cq_listar_erros
            INTO p_den_erro
      
            IF STATUS <> 0 THEN
               CALL log003_err_sql("lendo", "cursor: cq_listar_erros")
               RETURN
            END IF
             
            CALL substr(p_den_erro,69,3,'S') 
               RETURNING p_txt_1, p_txt_2, p_txt_3
           
            IF p_txt_1 IS NOT NULL THEN
               PRINT COLUMN 006, p_txt_1
              
               IF p_txt_2 IS NOT NULL THEN
                  PRINT COLUMN 006, p_txt_2
           
                  IF p_txt_3 IS NOT NULL THEN
                     PRINT COLUMN 006, p_txt_3   
                  END IF
               END IF
            END IF
         
         END FOREACH
      
      ON LAST ROW
      
         LET p_last_row = TRUE
      
         PAGE TRAILER
      
            IF p_last_row = TRUE THEN             
               PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
            ELSE 
               PRINT " "
            END IF

END REPORT

#---------------------------------#
 FUNCTION pol1050_prende_registro()
#---------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT id_registro 
      FROM apont_balan_454  
     WHERE cod_empresa = p_cod_empresa 
       AND id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","apont_balan_454")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol1050_excluir_pendentes()
#-----------------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1050_prende_registro() THEN
      
      UPDATE apont_balan_454
         SET cod_status  = 'E'
       WHERE cod_empresa = p_cod_empresa
         AND id_registro = p_id_registro 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Modificando", "apont_balan_454")
      ELSE
      
         INSERT INTO hist_apont_bl_454  
	       SELECT * 
	         FROM apont_balan_454
          WHERE cod_empresa = p_cod_empresa
            AND id_registro = p_id_registro
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Inserindo", "hist_apont_bl_454")
         ELSE
      
            DELETE FROM apont_balan_454
			       WHERE cod_empresa = p_cod_empresa
               AND id_registro = p_id_registro
            		
            IF STATUS <> 0 THEN               
               CALL log003_err_sql("Excluindo","apont_balan_454")                       
            ELSE
               
               SELECT id_registro
                 FROM apont_parada_454
                WHERE cod_empresa = p_cod_empresa
                  AND id_registro = p_id_registro
                  
               IF STATUS = 0 THEN
               
                  INSERT INTO hist_parada_bl_454 
	                SELECT * 
	                  FROM apont_parada_454
                   WHERE cod_empresa = p_cod_empresa
                     AND id_registro = p_id_registro
               
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql("Inserindo", "hist_parada_bl_454")
                  ELSE
                  
                     DELETE FROM apont_parada_454
                      WHERE cod_empresa = p_cod_empresa
                        AND id_registro = p_id_registro
                        
                     IF STATUS <> 0 THEN               
                        CALL log003_err_sql("Excluindo","apont_parada_454")                       
                        CALL log085_transacao("ROLLBACK")
                        RETURN FALSE
                     END IF
                  END IF
               ELSE
                  IF STATUS <> 100 THEN
                     CALL log003_err_sql("Lendo","apont_parada_454")
                     CALL log085_transacao("ROLLBACK")
                     RETURN FALSE
                  END IF
               END IF
                     
               DELETE FROM apont_erro_454
                WHERE cod_empresa = p_cod_empresa
                  AND id_registro = p_id_registro
                        
               IF STATUS = 0 THEN               
                  CALL pol1050_limpa_tela()
                  LET p_retorno = TRUE                          
               ELSE
                  CALL log003_err_sql("Excluindo","apont_erro_454")
               END IF                   
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
     
#-----------------------------#
 FUNCTION pol1050_processados()
#-----------------------------#
      
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10506") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10506 AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   CALL pol1050_limpa_tela()
      
   MENU "PROCESSADOS"
      
      COMMAND "Consultar" "Consulta dos apontamentos processados com sucesso."
         IF NOT pol1050_consultar_processados() THEN
            ERROR "Opera��o cancelada !!!"
         ELSE
            ERROR "Consulta efetuada com sucesso !!!"
         END IF
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1050_paginacao_processados("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1050_paginacao_processados("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Listar" "Listagem dos apontamentos processados."
         IF NOT pol1050_listar_processados() THEN
            ERROR "Opera��o cancelada !!!"
         ELSE
            ERROR "Listagem efetuada com sucesso !!!"
         END IF
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   
   END MENU
   
   CLOSE WINDOW w_pol10506
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol1050_consultar_processados()
#---------------------------------------#
      
   CALL pol1050_limpa_tela()
      
   LET p_id_registro_ant = p_id_registro
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      hist_apont_bl_454.num_ordem,
      hist_apont_bl_454.nom_usuario,
      hist_apont_bl_454.dat_inicial,
      hist_apont_bl_454.dat_final
      
      ON KEY (control-z)
         CALL pol1050_popup('CT')
         
   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_id_registro = p_id_registro_ant
         CALL pol1050_exibe_processados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT id_registro, num_ordem, dat_inicial, hor_inicial",
                  "  FROM hist_apont_bl_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY num_ordem, dat_inicial, hor_inicial"

   PREPARE var_query_2 FROM sql_stmt   
   DECLARE cq_consultar_processados SCROLL CURSOR WITH HOLD FOR var_query_2

   OPEN cq_consultar_processados

   FETCH cq_consultar_processados INTO p_id_registro

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1050_exibe_processados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1050_exibe_processados()
#-----------------------------------#
   
   SELECT num_ordem,
          cod_status,
          nom_usuario,
          dat_inicial,
          dat_final,
          qtd_boas,
          qtd_refugo,
          cod_item,
          hor_inicial,
          hor_final,
          cod_ferramenta,
          cod_eqpto,
          matricula
     INTO p_num_ordem,
          p_cod_status,
          p_nom_usuario,
          p_dat_inicial,
          p_dat_final,
          p_qtd_pecas,
          p_qtd_rejei,
          p_cod_item,
          p_hor_inicial,
          p_hor_final,
          p_cod_ferramenta,
          p_cod_eqpto,
          p_matricula
     FROM hist_apont_bl_454
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = p_id_registro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "apont_balan_454")
      RETURN FALSE
   END IF
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "item")
      RETURN FALSE
   END IF
   
   IF NOT pol1050_carrega_paradas() THEN
      RETURN FALSE
   END IF
   
   CALL pol1050_limpa_tela()
   
   DISPLAY p_num_ordem      TO num_ordem
   DISPLAY p_cod_status     TO cod_status
   DISPLAY p_qtd_pecas      TO qtd_pecas 
   DISPLAY p_qtd_rejei      TO qtd_rejei
   DISPLAY p_cod_item       TO cod_item
   DISPLAY p_nom_usuario    TO nom_usuario
   DISPLAY p_den_item       TO den_item
   DISPLAY p_dat_inicial    TO dat_inicial
   DISPLAY p_hor_inicial    TO hor_inicial
   DISPLAY p_dat_final      TO dat_final
   DISPLAY p_hor_final      TO hor_final
   
   IF p_cod_ferramenta IS NOT NULL THEN
      DISPLAY p_cod_ferramenta TO cod_ferramenta
   END IF
   
   IF p_cod_eqpto IS NOT NULL THEN
      DISPLAY p_cod_eqpto TO cod_eqpto
   END IF
   
   IF p_matricula IS NOT NULL THEN
      DISPLAY p_matricula TO num_matricula     
   END IF
   
   IF p_index > 1 THEN
   
      CALL SET_COUNT(p_index - 1)
   
      IF p_index > 4 THEN
         DISPLAY ARRAY pr_paradas TO sr_paradas.*
      ELSE
         INPUT ARRAY pr_paradas
            WITHOUT DEFAULTS FROM sr_paradas.*
            ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
         
            BEFORE INPUT
               EXIT INPUT
            
         END INPUT
      END IF
   
   END IF 
      
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 FUNCTION pol1050_carrega_paradas()
#---------------------------------#

   LET p_index = 1
   
   DECLARE cq_carrega_pr_paradas CURSOR FOR
   
    SELECT dat_inicial,
           hor_inicial,
           dat_final,
           hor_final,
           cod_parada
      FROM hist_parada_bl_454
     WHERE cod_empresa = p_cod_empresa
       AND id_registro = p_id_registro
       
   FOREACH cq_carrega_pr_paradas
      INTO pr_paradas[p_index].dat_par_inicial,
           pr_paradas[p_index].hor_par_inicial,
           pr_paradas[p_index].dat_par_final,
           pr_paradas[p_index].hor_par_final,
           pr_paradas[p_index].cod_parada
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "Cursor:cq_carrega_pr_paradas")
         RETURN FALSE
      END IF
      
      SELECT des_parada
        INTO pr_paradas[p_index].des_parada
        FROM cfp_para
       WHERE cod_empresa = p_cod_empresa
         AND cod_parada  = pr_paradas[p_index].cod_parada
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "cfp_para")
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 100 THEN
         ERROR "Limite de grade ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------------------#
 FUNCTION pol1050_paginacao_processados(p_funcao)
#-----------------------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      
      LET p_id_registro_ant = p_id_registro
      
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_consultar_processados INTO p_id_registro
                            
            WHEN p_funcao = "A" FETCH PREVIOUS cq_consultar_processados INTO p_id_registro 
                            
         END CASE

         IF status = 100 THEN
            ERROR "Nao existem mais itens nesta dire��o !!!"
            LET p_id_registro = p_id_registro_ant 
            EXIT WHILE
         END IF

         IF p_id_registro = p_id_registro_ant THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(num_ordem)
           INTO p_count
           FROM hist_apont_bl_454
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_num_ordem
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo", "apont_balan_454")
            EXIT WHILE 
         END IF 
         
         IF p_count > 0 THEN
            CALL pol1050_exibe_processados() RETURNING p_status
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "N�o existe nenhuma consulta ativa !!!"
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol1050_listar_processados()
#------------------------------------#
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10503") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10503 AT 7,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   CALL pol1050_limpa_tela()
      
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      hist_apont_bl_454.num_ordem,
      hist_apont_bl_454.dat_inicial,
      hist_apont_bl_454.dat_final
   
   IF INT_FLAG THEN    
      RETURN FALSE 
   END IF
   
   IF NOT pol1050_escolhe_saida_processados() THEN
   		RETURN FALSE
   END IF
   
   IF NOT pol1050_le_empresa() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 0

   LET sql_stmt = "SELECT id_registro, num_ordem, cod_item, ",
                  " dat_inicial, hor_inicial, dat_final, hor_final,", 
                  " qtd_boas, qtd_refugo, cod_ferramenta, cod_eqpto, matricula,",
                  " cod_status, nom_usuario",
                  "  FROM hist_apont_bl_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY num_ordem, dat_inicial, hor_inicial"

   PREPARE var_query_3 FROM sql_stmt   
   
   DECLARE cq_listar_processados CURSOR FOR var_query_3
        
   FOREACH cq_listar_processados
      INTO p_id_registro,
           p_num_ordem,
           p_cod_item,
           p_dat_inicial,
           p_hor_inicial,
           p_dat_final,
           p_hor_final,
           p_qtd_pecas,
           p_qtd_rejei,
           p_cod_ferramenta,
           p_cod_eqpto,
           p_matricula,
           p_cod_status,
           p_nom_usuario
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "Cursor: cq_listar_processados")
         RETURN FALSE
      END IF
      
      SELECT den_item_reduz
        INTO p_den_item_reduz 
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "item")
         RETURN FALSE
      END IF   
      
      OUTPUT TO REPORT pol1050_relat_processados()
      
      LET p_count = 1
      
   END FOREACH
   
   FINISH REPORT pol1050_relat_processados
   
   IF p_count = 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      RETURN FALSE
   ELSE 
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1050_escolhe_saida_processados()
#------------------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1050.tmp"
         START REPORT pol1050_relat_processados TO p_caminho
      ELSE
         START REPORT pol1050_relat_processados TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 REPORT pol1050_relat_processados()
#---------------------------------#
      
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
           
   FORMAT                                                                                                                                                                                   
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa,                                                                                                                                                   
               COLUMN 146, "PAG.: ", PAGENO USING "####&"                                                                                                                                   
                                                                                                                                                                                               
         PRINT COLUMN 001, "pol1050",                                                                                                                                                       
               COLUMN 050, "LISTAGEM DOS APONTAMENTOS EM GERAL",                                                                                                                            
               COLUMN 127, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME                                                                                                               
                                                                                                                                                                                               
         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"   
         
         PRINT                                                                                                                                                                              
         PRINT COLUMN 001, '   Ordem         Item           Descricao        Inicio      As       Fim        As        Boas      Rejeitadas   Ferramenta      Equipamento    Operador Status Usuario'    
         PRINT COLUMN 001, '----------- --------------- ------------------ ---------- -------- ---------- -------- ------------ ------------ --------------- --------------- -------- ------ --------'
                                                                                                                                                                                               
      PAGE HEADER                                                                                                                                                                           
                                                                                                                                                                                               
         PRINT COLUMN 001, p_den_empresa,                                                                                                                                                   
               COLUMN 146, "PAG.: ", PAGENO USING "####&"                                                                                                                                   
                                                                                                                                                                                               
         PRINT COLUMN 001, "pol1050",                                                                                                                                                       
               COLUMN 050, "LISTAGEM DOS APONTAMENTOS EM GERAL",                                                                                                                            
               COLUMN 127, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME                                                                                                               
                                                                                                                                                                                               
         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"   
         
         PRINT                                                                                                                                                                              
         PRINT COLUMN 001, '   Ordem         Item           Descricao        Inicio      As       Fim        As        Boas      Rejeitadas   Ferramenta      Equipamento    Operador Status Usuario'    
         PRINT COLUMN 001, '----------- --------------- ------------------ ---------- -------- ---------- -------- ------------ ------------ --------------- --------------- -------- ------ --------'
      
      ON EVERY ROW                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                
         PRINT COLUMN 002, p_num_ordem       USING "##########",                                                                                                                            
               COLUMN 013, p_cod_item,                                                                                                                                                      
               COLUMN 029, p_den_item_reduz,                                                                                                                                                
               COLUMN 048, p_dat_inicial,                                                                                                                                                   
               COLUMN 059, p_hor_inicial,                                                                                                                                                   
               COLUMN 068, p_dat_final,                                                                                                                                                     
               COLUMN 079, p_hor_final,                                                                                                                                                     
               COLUMN 089, p_qtd_pecas       USING "#######&.&&&",                                                                                                                           
               COLUMN 101, p_qtd_rejei       USING "#######&.&&&",                                                                                                                           
               COLUMN 114, p_cod_ferramenta,                                                                                                                                                
               COLUMN 130, p_cod_eqpto,                                                                                                                                                     
               COLUMN 146, p_matricula,                                                                                                                                                     
               COLUMN 155, p_cod_status,                                                                                                                                                    
               COLUMN 162, p_nom_usuario                                                                                                                                                    
         
      ON LAST ROW
      
         LET p_last_row = TRUE
      
         PAGE TRAILER
      
            IF p_last_row = TRUE THEN             
               PRINT COLUMN 057, "* * * ULTIMA FOLHA * * *"
            ELSE 
               PRINT " "
            END IF
        
END REPORT

#---------------------------------#
 FUNCTION pol1050_aponta(p_estatus)
#---------------------------------#

   DEFINE	l_id_reg		INTEGER,
          p_num_reg 		INTEGER,
          p_indice  		INTEGER,
          p_ind     		INTEGER,
          x_hor_ini  		CHAR(10),
	        x_hor_fim  		CHAR(10),
	        p_cod_parada 	CHAR(5),
	        p_cod_status 	CHAR(01),
	        p_estatus    	CHAR(01),
			    l_num_ordem 	INTEGER,      #MANUEL EM 19-03-2013
			    l_num_docum   CHAR(15),
			    l_cod_item    CHAR(15),
			    l_cod_operac  CHAR(05),
			    l_qtd_boas    DECIMAL(10,3),
			    l_qtd_apona   DECIMAL(10,3),
			    l_qtd_apond   DECIMAL(10,3),
			    l_qtd_aponc   DECIMAL(10,3),
			    l_qtd_apor27  DECIMAL(10,3),
			    l_txt1        CHAR(10),
			    l_txt2        CHAR(10),
			    p_dat_producao DATE
	        

   DEFINE p_hor_atu    CHAR(08),
	        p_hor_menos1 CHAR(08),
	        p_hh         INTEGER,
	        p_mm         INTEGER,
	        p_ss         INTEGER,
	        p_dat_atu    DATE

   DEFINE p_registro ARRAY[100] OF RECORD
          rowid      INTEGER
   END RECORD
				
   DEFINE p_w_apont_prod   RECORD 													
				cod_empresa     CHAR(2), 													
				cod_item        CHAR(15), 														
				num_ordem       INTEGER, 
				num_docum       CHAR(10), 
				cod_roteiro     CHAR(15), 
				num_altern      DEC(2,0), 
				cod_operacao    CHAR(5), 
				num_seq_operac  DEC(3,0), 
				cod_cent_trab   CHAR(5), 
				cod_arranjo     CHAR(5), 
				cod_equip       CHAR(15), 
				cod_ferram      CHAR(15), 
				num_operador    CHAR(15), 
				num_lote        CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno       DEC(3,0), 
				qtd_boas        DEC(10,3), 
				qtd_refug       DEC(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local       CHAR(10), 
				cod_local_est   CHAR(10), 
				dat_producao    DATE, 
				dat_ini_prod    DATE, 
				dat_fim_prod    DATE, 
				cod_tip_movto   CHAR(1), 
				estorno_total   CHAR(1), 
				ies_parada      SMALLINT, 
				ies_defeito     SMALLINT, 
				ies_sucata      SMALLINT, 
				ies_equip_min   CHAR(1), 
				ies_ferram_min  CHAR(1), 
				ies_sit_qtd     CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont       CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent   CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa    CHAR(8), 
				nom_usuario     CHAR(8), 
				num_seq_registro INTEGER, 
				observacao      CHAR(200), 
				cod_item_grade1 CHAR(15), 
				cod_item_grade2 CHAR(15), 
				cod_item_grade3 CHAR(15), 
				cod_item_grade4 CHAR(15), 
				cod_item_grade5 CHAR(15), 
				qtd_refug_ant   DECIMAL(10,3), 
				qtd_boas_ant    DECIMAL(10,3), 
				tip_servico     CHAR(1), 
				abre_transacao  SMALLINT,
				modo_exibicao_msg SMALLINT, 
				seq_reg_integra INTEGER, 
				endereco        INTEGER, 
				identif_estoque CHAR(30), 
				sku             CHAR(25),
				finaliza_operacao CHAR(1)
   END RECORD

   DEFINE  p_w_parada RECORD
				cod_parada 						CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO SECOND ,
				hor_fim_periodo 			DATETIME HOUR TO SECOND,
				hor_tot_periodo 			DECIMAL(7,2)
   END RECORD 

   LET p_tem_erro = FALSE
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0456_w_parada() THEN
      RETURN
   END IF
   
   DELETE FROM man_log_apo_prod	
         WHERE empresa = p_cod_empresa   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELE��O","man_log_apo_prod")
   END IF

   CALL log085_transacao("COMMIT")
		
   DISPLAY "Aguarde... efetuando o apontamento !!!" AT 16,15
  
   DECLARE cq_apont SCROLL CURSOR WITH HOLD FOR 	
    SELECT cod_empresa,
           cod_item,
           num_ordem,
           cod_operac,
           num_seq_operac,
           cod_cent_trab,
           cod_turno,
           cod_arranjo,
           cod_eqpto,
           cod_ferramenta,
           hor_inicial,
           hor_final,
           qtd_refugo,
           qtd_boas,
           qtd_hor,
           cod_local_prod,
           cod_local_est, 
           dat_inicial,
           dat_final,
           matricula,
		       ies_terminado, 
		       id_registro,
		       num_lote, 
		       cod_roteiro, 
		       num_rot_alt,
		       unid_funcional,
		       cod_status
      FROM apont_balan_454
		 WHERE cod_empresa = p_cod_empresa
		   AND cod_status  = p_estatus
		   AND nom_usuario = p_user
	   ORDER BY id_registro
			         	 
	 FOREACH cq_apont INTO 	
	    p_w_apont_prod.cod_empresa,
			p_w_apont_prod.cod_item,
			p_w_apont_prod.num_ordem,
			p_w_apont_prod.cod_operacao ,
			p_w_apont_prod.num_seq_operac,
			p_w_apont_prod.cod_cent_trab ,
			p_w_apont_prod.cod_turno ,
			p_w_apont_prod.cod_arranjo ,
			p_w_apont_prod.cod_equip ,
			p_w_apont_prod.cod_ferram ,
			p_w_apont_prod.hor_ini_periodo,
			p_w_apont_prod.hor_fim_periodo,
			p_w_apont_prod.qtd_refug ,
			p_w_apont_prod.qtd_boas ,
			p_w_apont_prod.qtd_total_horas ,
			p_w_apont_prod.cod_local ,
			p_w_apont_prod.cod_local_est ,
			p_w_apont_prod.dat_ini_prod ,
			p_w_apont_prod.dat_fim_prod ,
			p_w_apont_prod.num_operador ,
			p_w_apont_prod.finaliza_operacao,
			l_id_reg,
			p_w_apont_prod.num_lote,
			p_w_apont_prod.cod_roteiro,
			p_w_apont_prod.num_altern,
			p_w_apont_prod.num_secao_requis,
			p_cod_status

	    IF STATUS <> 0 THEN
	    	 CALL log003_err_sql("Lendo","cq_apont:1" )
	    END IF 
	    
      LET l_num_ordem = p_w_apont_prod.num_ordem   #MANUEL EM 19-03-2013
      
      LET p_dat_atu = TODAY
      LET p_hor_atu = TIME
      LET p_hh = p_hor_atu[1,2]
      LET p_mm = p_hor_atu[4,5]
      LET p_ss = p_hor_atu[7,8]
      
      IF p_ss >= 30 THEN
         LET p_ss = p_ss - 30
      ELSE
         LET p_ss = p_ss + 30
         IF p_mm > 0 THEN
            LET p_mm = p_mm - 1
         ELSE
            LET p_mm = p_mm + 59
            LET p_hh = p_hh - 1
         END IF
      END IF
      
      LET p_hor_menos1 = p_hh USING '&&', ':', p_mm USING '&&', ':', p_ss USING '&&'
      
      SELECT COUNT(a.seq_reg_mestre) 
        INTO p_count
        FROM man_apo_mestre a, 
             man_item_produzido b 
       WHERE a.empresa = p_cod_empresa 
         AND b.empresa = a.empresa
         AND a.seq_reg_mestre = b.seq_reg_mestre 
         AND a.ordem_producao = p_w_apont_prod.num_ordem 
         AND a.data_apontamento = p_dat_atu 
         AND (b.qtd_produzida = p_w_apont_prod.qtd_boas OR 
              b.qtd_produzida = p_w_apont_prod.qtd_refug)
         AND a.hor_apontamento BETWEEN p_hor_menos1 AND p_hor_atu
      
	    IF STATUS <> 0 THEN
	    	 CALL log003_err_sql("Lendo","man_apo_mestre:count" )
	    END IF 

      IF p_count > 0 THEN	    
         UPDATE apont_balan_454
            SET cod_status  = 'D'
   	      WHERE cod_empresa = p_cod_empresa
   	        AND id_registro = l_id_reg
   	      CONTINUE FOREACH
   	   END IF

	    SELECT num_docum
	      INTO p_w_apont_prod.num_docum
	      FROM ordens
	     WHERE cod_empresa = p_cod_empresa
	       AND num_ordem   = p_w_apont_prod.num_ordem

	    IF SQLCA.SQLCODE<> 0 THEN
	    	 CALL log003_err_sql("Lendo","ordens:num_docum" )
	    END IF 

			LET p_w_apont_prod.cod_tip_movto = 'N'
					
			IF p_w_apont_prod.cod_cent_trab IS NULL OR
			   p_w_apont_prod.cod_cent_trab = ' '   THEN 
				 LET p_w_apont_prod.cod_cent_trab = 0
			END IF 
			
			IF p_w_apont_prod.cod_arranjo = ' '   OR
			   p_w_apont_prod.cod_arranjo IS NULL THEN 
				 LET p_w_apont_prod.cod_arranjo = 0
			END IF 
			
			IF p_w_apont_prod.cod_ferram = ' '   OR  
			   p_w_apont_prod.cod_ferram IS NULL THEN 
				 INITIALIZE p_w_apont_prod.cod_ferram  TO NULL
				 LET p_w_apont_prod.ies_ferram_min =  "N"
			ELSE 
					LET p_w_apont_prod.ies_ferram_min =  "S"
			END IF 				
			
			IF p_w_apont_prod.cod_equip = ' '   OR 
			   p_w_apont_prod.cod_equip IS NULL THEN
				 LET p_w_apont_prod.ies_equip_min = "N"
         INITIALIZE p_w_apont_prod.cod_equip  TO NULL		 
			ELSE
				 LET p_w_apont_prod.ies_equip_min = "S"	
			END IF 
			
			LET p_num_lote_refug = p_w_apont_prod.num_lote 
			LET p_cod_item_refug = p_w_apont_prod.cod_item
			LET p_w_apont_prod.dat_producao	=	p_w_apont_prod.dat_ini_prod
			LET p_dat_producao = p_w_apont_prod.dat_producao
			LET p_w_apont_prod.estorno_total = "N"

      #Ivo 30/09/2013...
      LET l_num_docum = l_num_ordem
      LET l_cod_item  = p_w_apont_prod.cod_item
      LET l_cod_operac = p_w_apont_prod.cod_operacao
      LET l_qtd_boas = p_w_apont_prod.qtd_boas
      
      SELECT SUM(qtd_movto)
        INTO l_qtd_apona
        FROM estoque_trans
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = l_cod_item
         AND num_docum = l_num_docum
         AND dat_movto = p_dat_producao
         AND num_prog = 'POL1050'
      
      IF STATUS <> 0 THEN
	    	 CALL log003_err_sql("Lendo","estoque_trans:1" )
	    END IF 
	    
	    IF l_qtd_apona IS NULL THEN
	       LET l_qtd_apona = 0
	    END IF	 
	    #...at� aqui      	    


			IF p_w_apont_prod.qtd_refug > 0 THEN 
	       LET p_qtd_transf = p_w_apont_prod.qtd_refug
				 LET p_w_apont_prod.ies_defeito = 1
			ELSE
				 LET p_w_apont_prod.ies_defeito = 0
			END IF 
			
			LET p_w_apont_prod.ies_sucata 					= 0
			LET p_w_apont_prod.ies_sit_qtd 					=	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL
			LET p_w_apont_prod.num_programa 				= 'POL1050'
			LET p_w_apont_prod.nom_usuario 					= p_user
			LET p_w_apont_prod.cod_item_grade1 			= NULL
			LET p_w_apont_prod.cod_item_grade2 			= NULL
			LET p_w_apont_prod.cod_item_grade3 			= NULL
			LET p_w_apont_prod.cod_item_grade4 			= NULL
			LET p_w_apont_prod.cod_item_grade5 			= NULL
			LET p_w_apont_prod.qtd_refug_ant 				= NULL
			LET p_w_apont_prod.qtd_boas_ant 				= NULL
			LET p_w_apont_prod.abre_transacao 			= 1
			LET p_w_apont_prod.modo_exibicao_msg 		= 0
			LET p_w_apont_prod.seq_reg_integra 			= NULL
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
      LET p_w_apont_prod.ies_parada           = 0
      
	 	  IF manr24_cria_w_apont_prod(0)  THEN 

	 		   CALL man8246_cria_temp_fifo()
	 		   CALL man8237_cria_tables_man8237()

			   DELETE FROM w_parada
         
         DECLARE cq_para CURSOR FOR
          SELECT dat_inicial, 
                 dat_final,    
                 hor_inicial,
                 hor_final,
                 cod_parada                 #Manuel
            FROM apont_parada_454
           WHERE cod_empresa = p_cod_empresa
             AND id_registro = l_id_reg
         
         FOREACH cq_para INTO
                 p_w_parada.dat_ini_parada,
                 p_w_parada.dat_fim_parada,
                 p_w_parada.hor_ini_periodo,
                 p_w_parada.hor_fim_periodo,
                 p_w_parada.cod_parada

 		 				IF SQLCA.SQLCODE <> 0 THEN 
						   CALL log003_err_sql('Lendo','apont_parada_454')
							 RETURN
						END IF 

            IF p_w_parada.dat_ini_parada = p_w_parada.dat_fim_parada THEN
               LET p_qtd_hor_chr = 
                   p_w_parada.hor_fim_periodo - p_w_parada.hor_ini_periodo
            ELSE
               LET p_qtd_hor_chr =  
                   '24:00:00' - (p_w_parada.hor_ini_periodo - p_w_parada.hor_fim_periodo)           
            END IF
            
            LET p_w_parada.hor_tot_periodo = pol1050_formata_hora()
 
 		 				INSERT INTO w_parada VALUES (p_w_parada.*)    
 		 				   
 		 				IF SQLCA.SQLCODE <> 0 THEN 
						   CALL log003_err_sql('inserir','w_parada')
							 RETURN
						END IF 
						
            LET p_w_apont_prod.ies_parada = 1   #Manuel
            
         END FOREACH
				
				 #IF p_ies_tip_apont = '1' THEN
				    #LET p_w_apont_prod.num_ordem = NULL
				 #END IF
				
	 		   IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incluindo apontamento
	 			
 	 			    IF p_w_apont_prod.ies_defeito = 1  THEN             #apontando defeitos
		 			     IF pol0456_w_defeito() THEN 
		 				      INSERT INTO w_defeito 
		 				        VALUES(p_tela.cod_defeito,
		 				               p_w_apont_prod.qtd_refug)
		 			     END IF 
		 		    END IF 
	 				  
	 			    IF manr27_processa_apontamento(p_w_apont_prod.*)  THEN #processando apontamento
	 			       LET p_cod_status = 'S'	 
	 			    ELSE
	 			       LET p_qtd_transf = 0 				     
	 			    END IF 
	 	     END IF 
	 	  END IF
	 	  
	 	  DELETE FROM w_apont_prod 
	 	  
	 	  IF p_qtd_transf > 0 THEN
	 	     CALL log085_transacao("BEGIN")
	 	     IF NOT pol1050_transf_refugo() THEN
	 	        CALL log085_transacao("ROLLBACK")
	 	     ELSE
	 	        CALL log085_transacao("COMMIT")
	 	     END IF
	 	  END IF
	 	  
	 	  LET p_houve_erro = FALSE
	 	  
	 		CALL log085_transacao("BEGIN")

      DELETE FROM apont_erro_454
       WHERE cod_empresa = p_cod_empresa
         AND id_registro = l_id_reg
	 		
		 	DECLARE cq_erro CURSOR FOR 	
		 	 SELECT texto_resumo  	
		 		 FROM man_log_apo_prod	
		 		WHERE empresa 		 = p_cod_empresa
				AND   ordem_producao = l_num_ordem 				# MANUEL EM 19-03-2013
		  
		  FOREACH cq_erro INTO 	
		  				p_msg

			   IF STATUS <> 0 THEN
	          CALL log003_err_sql("Lendo","cq_erro")
	          CALL log085_transacao("ROLLBACK")
	          LET p_houve_erro = TRUE
	          EXIT FOREACH
	       END IF
		  	 
	  	   LET p_tem_erro = TRUE
	  	   LET p_cod_status = 'P'
	  	   LET p_id_registro = l_num_ordem
		  	 
         INSERT INTO apont_erro_454
          VALUES (p_cod_empresa,
                  p_id_registro,
                  p_msg)

  			 IF STATUS <> 0 THEN
	          CALL log003_err_sql("Inclusao","apont_erro_454")
	          CALL log085_transacao("ROLLBACK")
	          LET p_houve_erro = TRUE
	          EXIT FOREACH
	       END IF  
	       
		  END FOREACH

      IF NOT p_houve_erro THEN

         DELETE FROM man_log_apo_prod	
		    	WHERE empresa = p_cod_empresa
            AND ordem_producao = l_num_ordem 				# MANUEL EM 19-03-2013
         
         CALL log085_transacao("COMMIT")
      END IF
      
      #Ivo 30/09/2013...
      
      SELECT SUM(qtd_movto)
        INTO l_qtd_apond
        FROM estoque_trans
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = l_cod_item
         AND num_docum = l_num_docum
         AND dat_movto = p_dat_producao
         AND num_prog = 'POL1050'
      
      IF STATUS <> 0 THEN
	    	 CALL log003_err_sql("Lendo","estoque_trans:2" )
	    END IF 
	    
	    IF l_qtd_apond IS NULL THEN
	       LET l_qtd_apond = 0
	    END IF	 
	    
	    LET l_qtd_apor27 = l_qtd_apond - l_qtd_apona
	    LET l_txt1 = l_qtd_boas
	    LET l_txt2 = l_qtd_apor27

	    IF l_qtd_apor27 > l_qtd_boas THEN
         LET p_msg = 'Qtd enviada  para manr27: ', l_txt1 CLIPPED, ' -> ',
	                   'Qtd apontada pela manr27: ', l_txt2 CLIPPED
      ELSE
         LET p_msg = NULL
	    END IF
	    
      UPDATE apont_balan_454
             SET cod_status  = p_cod_status,
                 mensagem = p_msg
	     WHERE cod_empresa = p_cod_empresa
	       AND id_registro = l_id_reg


	    IF l_qtd_apor27 > l_qtd_boas THEN
	       CALL log0030_mensagem(p_msg,'info')
	    END IF
	       
	    #...at� aqui      	    
     	
   END FOREACH

   DISPLAY "                                      " AT 16,15
   
   IF NOT manda_para_historico() THEN  # Manuel
      RETURN  FALSE
   END IF  
    
END FUNCTION

#----------------------------#
 FUNCTION pol0456_w_defeito()#
#----------------------------#

	

	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(10,3)
		)

	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 

END FUNCTION 

#---------------------------#
 FUNCTION pol0456_w_parada()
#---------------------------#
	

	DROP TABLE w_parada

	CREATE TEMP TABLE w_parada (
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)

	IF SQLCA.SQLCODE <> 0 THEN
	  CALL log003_err_sql('criando','w_parada')
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 

END FUNCTION 

# Manuel -  daqui ...

#-------------------------------#
 FUNCTION manda_para_historico()#
#-------------------------------#

	
	
	CALL log085_transacao("BEGIN")

    INSERT INTO hist_parada_bl_454 
	  SELECT * FROM apont_parada_454
     WHERE cod_empresa = '01'
       AND id_registro IN
          (select id_registro
             FROM apont_balan_454
            WHERE cod_status='S'
              AND cod_empresa='01')

	IF SQLCA.SQLCODE <> 0 THEN
	    CALL log003_err_sql("Inclusao","hist_parada_bl_454")
		CALL log085_transacao("ROLLBACK")
		RETURN FALSE
	END IF 
	
	INSERT INTO hist_apont_bl_454  
	SELECT * FROM  apont_balan_454
   WHERE cod_status = 'S'

	IF SQLCA.SQLCODE <> 0 THEN
	    CALL log003_err_sql("Inclusao","hist_apont_bl_454")
		CALL log085_transacao("ROLLBACK")
		RETURN FALSE
	END IF 
	
   DELETE FROM apont_parada_454
     WHERE cod_empresa='01'
       AND id_registro IN
           (SELECT id_registro
              FROM  apont_balan_454
             WHERE cod_status='S'
               AND cod_empresa='01')
		
    IF SQLCA.SQLCODE <> 0 THEN
	    CALL log003_err_sql("dELETE","apont_parada_454")
		  CALL log085_transacao("ROLLBACK")
		  RETURN FALSE
	 END IF 
		
	 DELETE FROM  apont_balan_454
	
	CALL log085_transacao("COMMIT")
	  
	RETURN TRUE

END FUNCTION 

# ... at� aqui


#Fun��o para separa��o do texto

#-------------------------#
FUNCTION substr(parametro)
#-------------------------#

 DEFINE parametro  RECORD 
        texto      VARCHAR(255),
        tam_linha  SMALLINT,
        qtd_linha  SMALLINT,
        justificar CHAR(01)
 END RECORD

   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET qtd_linha  = parametro.qtd_linha
   LET justificar = parametro.justificar
   
   CALL limpa_retorno()
   
   IF checa_parametros() THEN
      CALL separa_texto()
   END IF
   
   CASE qtd_linha

      WHEN  1 RETURN r_01
      WHEN  2 RETURN r_01,r_02
      WHEN  3 RETURN r_01,r_02,r_03
      WHEN  4 RETURN r_01,r_02,r_03,r_04
      WHEN  5 RETURN r_01,r_02,r_03,r_04,r_05
      WHEN  6 RETURN r_01,r_02,r_03,r_04,r_05,r_06
      WHEN  7 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07
      WHEN  8 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08
      WHEN  9 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09
      WHEN 10 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10
      WHEN 11 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11
      WHEN 12 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12
      WHEN 13 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13

   END CASE
   
   
END FUNCTION 


#--------------------------------#
 FUNCTION limpa_retorno()
#--------------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13 TO NULL 
              
END FUNCTION

#----------------------------------#
 FUNCTION checa_parametros()
#----------------------------------#

   IF texto IS NULL OR texto = ' ' THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha < 20 OR tam_linha > 255 THEN
         RETURN FALSE
      END IF 
   END IF

   IF qtd_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF qtd_linha < 1 OR qtd_linha > 13 THEN
         RETURN FALSE
      END IF 
   END IF

   IF justificar IS NULL THEN
      RETURN FALSE
   ELSE
      IF justificar <> 'S' AND justificar <> 'N' THEN
         RETURN FALSE
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION


#--------------------------------#
 FUNCTION separa_texto()
#--------------------------------#
          
   LET r_01 = quebra_texto()
   LET r_02 = quebra_texto()
   LET r_03 = quebra_texto()
   LET r_04 = quebra_texto()
   LET r_05 = quebra_texto()
   LET r_06 = quebra_texto()
   LET r_07 = quebra_texto()
   LET r_08 = quebra_texto()
   LET r_09 = quebra_texto()
   LET r_10 = quebra_texto()
   LET r_11 = quebra_texto()
   LET r_12 = quebra_texto()
   LET r_13 = quebra_texto()
      
              
END FUNCTION

#-----------------------------#
FUNCTION quebra_texto()
#-----------------------------#

   DEFINE ind SMALLINT,
          p_des_texto CHAR(255)

   LET num_carac = LENGTH(texto)
   IF num_carac = 0 THEN
      RETURN ''
   END IF
   
   IF num_carac <= tam_linha THEN
      LET p_des_texto = texto
      INITIALIZE texto TO NULL
      RETURN(p_des_texto)
   END IF

   FOR ind = tam_linha+1 TO 1 step -1
      IF texto[ind] = ' ' then
         LET ret = texto[1,ind-1]
         LET texto = texto[ind+1,num_carac]
         EXIT FOR
      END IF
   END FOR 

   LET ret = ret CLIPPED
   IF justificar = 'S' THEN
      IF LENGTH(ret) < tam_linha THEN
         CALL justifica()
      END IF
   END IF 
              
   RETURN(ret)
   
END FUNCTION

#--------------------#
FUNCTION justifica()
#-------------------#

   DEFINE ind, y, p_branco, p_tam, p_tem_branco SMALLINT
   DEFINE p_tex VARCHAR(255)
   
   LET y = 1
   LET p_branco = tam_linha - LENGTH(ret)

   WHILE p_branco > 0   
      LET p_tam = LENGTH(ret)
      LET p_tem_branco = FALSE
      FOR ind = y TO p_tam
         IF ret[ind] = ' ' THEN
            LET p_tem_branco = TRUE
            LET p_tex = ret[1,ind],' ',ret[ind+1,p_tam]
            LET p_branco = p_branco - 1
            LET ret = p_tex
            LET y = ind + 2
            WHILE ret[y] = ' '
               LET y = y + 1
            END WHILE
            IF y >= LENGTH(ret) THEN
               LET y = 1
            END IF
            EXIT FOR
         END IF
      END FOR
      IF NOT p_tem_branco THEN
         LET y = 1
      END IF
   END WHILE 
      
END FUNCTION

#------------------------------#
FUNCTION pol1050_transf_refugo()
#------------------------------#
   
   DEFINE p_dat_hoje DATE
   
   LET p_dat_hoje = TODAY
   LET p_cod_local_refug = '03'
   
   SELECT MAX(num_transac)
     INTO p_num_transac
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item_refug
      AND num_lote_dest = p_num_lote_refug
      AND qtd_movto = p_qtd_transf
      AND ies_tip_movto = 'N'
      AND dat_movto = p_tela.dat_inicial
      AND ies_sit_est_dest = 'R'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','estoque_trans.num_transac') 
      RETURN FALSE
   END IF
   
   IF p_num_transac IS NULL THEN
      LET p_msg = 'N�o foi poss�vel ler o movimento de\n ',
                  'apontamento das pe�as refugadas, na\n',
                  'tabela estoque_trans!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF NOT pol1050_transf_movto() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1050_transf_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1050_transf_movto()
#------------------------------#

   SELECT cod_estoque_ac    
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','par_pcp.cod_estoque_ac') 
     RETURN FALSE
   END IF

   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','estoque_trans') 
      RETURN FALSE
   END IF
   
   LET p_cod_local = p_estoque_trans.cod_local_est_dest
   
   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','estoque_trans_end') 
      RETURN FALSE
   END IF
   
   LET p_estoque_trans.cod_local_est_orig = p_estoque_trans.cod_local_est_dest
   LET p_estoque_trans.num_lote_orig 	  = p_estoque_trans.num_lote_dest
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_refug
   LET p_estoque_trans.num_prog = 'POL1050'
   LET p_estoque_trans.dat_proces = TODAY
   LET p_estoque_trans.hor_operac = TIME
   LET p_estoque_trans.cod_operacao = p_cod_operacao
   LET p_estoque_trans.num_transac = 0
   
   INSERT INTO estoque_trans
    VALUES(p_estoque_trans.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_trans') 
      RETURN FALSE
   END IF
   
   LET p_num_transac = SQLCA.SQLERRD[2]
   LET p_estoque_trans_end.num_transac = p_num_transac
   LET p_estoque_trans_end.cod_operacao = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog = p_estoque_trans.num_prog
    
   INSERT INTO estoque_trans_end
    VALUES(p_estoque_trans_end.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_trans_end') 
      RETURN FALSE
   END IF
    
  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa, 
            p_num_transac, 
            p_user, 
            p_estoque_trans.dat_proces,
            p_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_auditoria') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1050_transf_estoque()
#--------------------------------#

   SELECT *
     INTO p_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 100 THEN
      LET p_estoque_lote_ender.qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender') 
         RETURN FALSE
      END IF
   END IF
   
   IF p_estoque_lote_ender.qtd_saldo < p_qtd_transf THEN
      LET p_msg = 'Tabela estoque_lote_ender sem saldo\n',
                  'de refugo suficiente, para efetuar\n',
                  'a transfer�ncia de local!\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF NOT pol1050_atu_lote_ender() THEN
      RETURN FALSE
   END IF

   SELECT num_transac,
          qtd_saldo
     INTO p_num_transac,
          p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote') 
         RETURN FALSE
      END IF
   END IF
   
   IF p_qtd_saldo < p_qtd_transf THEN
      LET p_msg = 'Tabela estoque_lote sem saldo\n',
                  'de refugo suficiente, para \n',
                  'efetuar a transfer�ncia de local!\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF NOT pol1050_atu_estoque_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1050_atu_lote_ender()
#--------------------------------#
   
   IF p_estoque_lote_ender.qtd_saldo > p_qtd_transf THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo - p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque_lote_ender.local_padrao') 
      RETURN FALSE
   END IF
      
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local_refug
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 0 THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      IF STATUS = 100 THEN
         LET p_estoque_lote_ender.cod_local = p_cod_local_refug
         LET p_estoque_lote_ender.qtd_saldo = p_qtd_transf
         LET p_estoque_lote_ender.num_transac = 0
         INSERT INTO estoque_lote_ender
          VALUES(p_estoque_lote_ender.*)
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote_ender') 
         RETURN FALSE
      END IF
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque_lote_ender.local_refugo') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1050_atu_estoque_lote()
#---------------------------------#
   
   IF p_qtd_saldo > p_qtd_transf THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo - p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque_lote.local_padrao') 
      RETURN FALSE
   END IF
      
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local_refug
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 0 THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo + p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      IF STATUS = 100 THEN
         LET p_estoque_lote_ender.cod_local = p_cod_local_refug
         LET p_estoque_lote_ender.num_transac = 0
         INSERT INTO estoque_lote
          VALUES(p_cod_empresa,
                 p_cod_item_refug,
                 p_cod_local_refug,
                 p_num_lote_refug,'R',
                 p_qtd_transf,0)
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote.local_refugo') 
         RETURN FALSE
      END IF
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque_lote.local_refugo') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1050_duplicidade()#
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1050a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1050a AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol1050_info_param() RETURNING p_status

   CLOSE WINDOW w_pol1050a

   IF NOT p_status THEN
      CALL pol1050_limpa_tela()
      ERROR 'Opera��o cancelada.'
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1050_info_param()#
#----------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_param TO NULL
   LET p_param.ies_listar = 'T'
   
   INPUT BY NAME p_param.* WITHOUT DEFAULTS

   AFTER INPUT
     IF INT_FLAG THEN
        RETURN FALSE
     ELSE
        IF p_param.dat_ini IS NULL THEN
           ERROR "Data inicial deve ser preenchida."
           NEXT FIELD dat_ini
        END IF
        IF p_param.dat_fim IS NULL THEN
           ERROR "Data final deve ser preenchida."
           NEXT FIELD dat_fim
        END IF
        IF p_param.dat_fim < p_param.dat_ini THEN
           ERROR "Data final deve ser maior ou igual a inicial."
           NEXT FIELD dat_ini
        END IF
     END IF

   END INPUT
   
   CALL pol1050_lista_dupl()
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1050_lista_dupl()#
#----------------------------#
  
   IF NOT pol1050_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1050_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.dat_inicial,
           a.num_ordem,
           a.cod_operac,
           SUM(a.qtd_boas + a.qtd_refugo)
      FROM hist_apont_bl_454 a
     WHERE a.cod_empresa = p_cod_empresa
       AND a.dat_inicial >= p_param.dat_ini
       AND a.dat_inicial <= p_param.dat_fim
       AND a.cod_status = 'S'
     GROUP BY a.dat_inicial, a.num_ordem, a.cod_operac
     ORDER BY a.dat_inicial, a.num_ordem
   
   FOREACH cq_impressao INTO 
           p_relat.dat_producao,
           p_relat.num_ordem,
           p_relat.cod_operac,
           p_relat.qtd_1050

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      

    SELECT SUM(c.qtd_produzida)
      INTO p_relat.qtd_r27
      FROM man_apo_mestre b,
           man_item_produzido c,
           man_apo_detalhe d
     WHERE b.empresa = p_cod_empresa
       AND b.data_producao = p_relat.dat_producao
       AND b.ordem_producao = p_relat.num_ordem
       AND c.empresa = b.empresa
       AND c.seq_reg_mestre = b.seq_reg_mestre
       AND c.tip_movto = 'N'
       AND d.empresa = b.empresa
       AND d.seq_reg_mestre = b.seq_reg_mestre
       AND d.operacao = p_relat.cod_operac
       AND d.nome_programa = 'POL1050'

      IF p_relat.qtd_1050 IS NULL THEN
         LET p_relat.qtd_1050 = 0
      END IF

      IF p_relat.qtd_r27 IS NULL THEN
         LET p_relat.qtd_r27 = 0
      END IF
      
      LET p_relat.difer = p_relat.qtd_1050 - p_relat.qtd_r27

      IF p_relat.difer = 0 THEN
         LET p_relat.difer = NULL
         IF p_param.ies_listar = 'D' THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      OUTPUT TO REPORT pol1050_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1050_relat   
   
   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1050_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1050.tmp"
         START REPORT pol1050_relat TO p_caminho
      ELSE
         START REPORT pol1050_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1050_le_empresa()
#---------------------------#

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

#----------------------#
 REPORT pol1050_relat()#
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
   
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 074, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1050",
               COLUMN 025, "APONTAMENTOS DO POL1050",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------"
         PRINT

         PRINT COLUMN 001, "   DATA     ORDEM    OPER  QTD 1050 QTD R27  DIFER"
         PRINT COLUMN 001, "---------- --------- ----- -------- -------- --------"

      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 074, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1050",
               COLUMN 025, "APONTAMENTOS DO POL1050",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "   DATA     ORDEM    OPER  QTD 1050 QTD R27  DIFER"
         PRINT COLUMN 001, "---------- --------- ----- -------- -------- --------"
 
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.dat_producao USING 'dd/mm/yyyy',
               COLUMN 012, p_relat.num_ordem USING '#########',
               COLUMN 022, p_relat.cod_operac,
               COLUMN 028, p_relat.qtd_1050 USING '########',
               COLUMN 037, p_relat.qtd_r27 USING '########',
               COLUMN 046, p_relat.difer USING '########'
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA ---------BI--------------------#
#-----------------------------------------------------------------#
# PROGRAMA: pol0643                                               #
# OBJETIVO: COPIA DE estoque                                      #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS 
   DEFINE p_estoque_trans    RECORD LIKE estoque_trans.*, 
          p_estoque_trans_end    RECORD LIKE estoque_trans_end.*,          
          p_estoque          RECORD LIKE estoque.*,
          p_estoque_lote     RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender     RECORD LIKE estoque_lote_ender.*,                      
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT, 
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_mensag           CHAR(200),
          w_i                SMALLINT,
          p_i                SMALLINT,
          p_ind              SMALLINT,
          p_ies_cons         CHAR(001), 
          p_cod_emp_orig     CHAR(002),
          p_cod_emp_oper     CHAR(002),
          p_den_item         LIKE item.den_item,
          p_pes_unit         LIKE item.pes_unit,
          p_data_ent         DATE,
          p_cod_unid_med     LIKE item.cod_unid_med,
          p_msg              char(300)


   DEFINE ma_tela1 ARRAY[500] OF RECORD
      cod_item       LIKE nf_item.cod_item,
      den_item       CHAR(36),        
      qtd_dif        LIKE estoque_trans.qtd_movto,
      qtd_movto      LIKE estoque_trans.qtd_movto
   END RECORD

   DEFINE mr_tela              RECORD
      cod_empresa         LIKE empresa.cod_empresa
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
##   CALL log0180_conecta_usuario()
   LET p_versao = "POL0643-10.02.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0643_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0643_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0643") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0643 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa itens"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0643","CO") THEN 
            CALL pol0643_informa()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Efetiva"
            END IF
         END IF

      COMMAND "Processar" "Gera recebimento da nf"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0643","MO") THEN 
            IF p_ies_cons THEN 
               IF pol0643_efetiva() THEN
                  COMMIT WORK 
                  ERROR 'ATUALIZACAO EFETUADA COM SUCESSO'
               ELSE
                  ROLLBACK WORK 
                  ERROR 'PROBLEMAS DURANTE ATUALIZACAO - VERIFIQUE'
               END IF       
               NEXT OPTION "Fim"
            ELSE
               ERROR "Informe os dados Antes de Processar"
               NEXT OPTION "Consultar"
            END IF
         END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0643_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0643

END FUNCTION

#-----------------------#
FUNCTION pol0643_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION pol0643_informa()
#--------------------------#
 
   CLEAR FORM
   LET mr_tela.cod_empresa = p_cod_empresa
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0643

   SELECT cod_emp_oper
     INTO p_cod_emp_oper
     FROM par_desc_oper
    WHERE cod_emp_ofic = p_cod_empresa 

   IF pol0643_entrada_dados() THEN
   ELSE
      LET INT_FLAG = 1
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   ELSE
      LET p_ies_cons = TRUE 
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0643_entrada_dados()
#-------------------------------#

DEFINE l_cod_item  LIKE item.cod_item,
       l_qtd_ofic  LIKE estoque_trans.qtd_movto,
       l_qtd_oper  LIKE estoque_trans.qtd_movto,
       l_qtd_dif   LIKE estoque_trans.qtd_movto,
       l_den_item  CHAR(45),
       l_ind       INTEGER 
 
  CALL log006_exibe_teclas("02 03 07", p_versao)
  CURRENT WINDOW IS w_pol0643
  LET l_ind = 1 

  INPUT ARRAY ma_tela1 WITHOUT DEFAULTS
         FROM s_processo.*
  
      BEFORE ROW
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
         
      AFTER FIELD cod_item
         IF ma_tela1[pa_curr].cod_item IS NULL THEN 
            EXIT INPUT 
         ELSE
            SELECT den_item[1,36]
              INTO ma_tela1[pa_curr].den_item   
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = ma_tela1[pa_curr].cod_item
             IF sqlca.sqlcode <> 0 THEN
                ERROR 'ITEM NAO CACASTRADO'
             ELSE
                DISPLAY ma_tela1[pa_curr].den_item TO s_processo[sc_curr].den_item
                
                SELECT qtd_liberada 
                  INTO l_qtd_ofic
                  FROM estoque 
                 WHERE cod_empresa = p_cod_empresa 
                   AND cod_item    =  ma_tela1[pa_curr].cod_item
                IF sqlca.sqlcode <> 0 THEN 
                   LET l_qtd_ofic = 0 
                END IF 
                   
                SELECT qtd_liberada 
                  INTO l_qtd_oper
                  FROM estoque 
                 WHERE cod_empresa = p_cod_emp_oper 
                   AND cod_item    =  ma_tela1[pa_curr].cod_item
                IF sqlca.sqlcode <> 0 THEN 
                   LET l_qtd_oper = 0 
                END IF 
                   
                LET ma_tela1[pa_curr].qtd_dif  =  l_qtd_ofic - l_qtd_oper    
                DISPLAY ma_tela1[pa_curr].qtd_dif TO s_processo[sc_curr].qtd_dif  
             END IF 
         END IF    

      AFTER FIELD qtd_movto
         IF ma_tela1[pa_curr].qtd_movto IS NULL OR 
            ma_tela1[pa_curr].qtd_movto = 0  THEN
            ERROR 'Campo de preenchimento obrigatorio'
            NEXT FIELD qtd_movto
         END IF    

     ON KEY (control-z)
        CALL pol0643_popup()

  END INPUT
  
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol0643
  
  IF INT_FLAG THEN
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#-------------------------#
 FUNCTION pol0643_efetiva()
#-------------------------#
 DEFINE l_num_res       INTEGER

   MESSAGE "Atualizando estoque ...!!!"
      ATTRIBUTE (REVERSE) 
 
   BEGIN WORK 

 FOR p_ind = 1 TO 500 
   
    IF ma_tela1[p_ind].cod_item IS NULL THEN
       EXIT FOR
    END IF 
    
    INITIALIZE p_estoque_trans.num_seq, 
               p_estoque_trans.num_conta, 
               p_estoque_trans.num_secao_requis, 
               p_estoque_trans.cod_local_est_orig, 
               p_estoque_trans.num_lote_orig, 
               p_estoque_trans.ies_sit_est_orig,
               p_estoque_trans.num_lote_dest, 
               p_estoque_trans.cod_turno,
               p_estoque_lote_ender.num_lote,
               p_estoque_lote.num_lote   TO NULL 
    

    LET p_estoque_trans.cod_empresa        = p_cod_emp_oper 
    LET p_estoque_trans.num_transac        = 0 
    LET p_estoque_trans.cod_item           = ma_tela1[p_ind].cod_item
    LET p_estoque_trans.dat_movto          = TODAY
    LET p_estoque_trans.dat_ref_moeda_fort = TODAY 
    LET p_estoque_trans.cod_operacao       = 'IMPL'
    LET p_estoque_trans.num_docum          = '1'
    LET p_estoque_trans.ies_tip_movto      = 'N' 
    LET p_estoque_trans.qtd_movto          = ma_tela1[p_ind].qtd_movto
    LET p_estoque_trans.cus_unit_movto_p   = 0 
    LET p_estoque_trans.cus_tot_movto_p    = 0 
    LET p_estoque_trans.cus_unit_movto_f   = 0  
    LET p_estoque_trans.cus_tot_movto_f    = 0  
    LET p_estoque_trans.ies_sit_est_dest    = 'L'
    LET p_estoque_trans.nom_usuario         = p_user
    LET p_estoque_trans.dat_proces          = TODAY
    LET p_estoque_trans.hor_operac          = '01:00:00'
    LET p_estoque_trans.num_prog            = 'POL0643'

    SELECT cod_local_estoq 
      INTO p_estoque_trans.cod_local_est_dest 
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_estoque_trans.cod_item 
    LET p_estoque_trans.num_transac = 0
    INSERT INTO estoque_trans VALUES (p_estoque_trans.*)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO", "ESTOQUE_TRANS")
       RETURN FALSE
    END IF    
    
    LET l_num_res = SQLCA.SQLERRD[2]
    
    LET p_estoque_trans_end.cod_empresa = p_cod_emp_oper
    LET p_estoque_trans_end.num_transac = l_num_res
    LET p_estoque_trans_end.endereco    = ' '
    LET p_estoque_trans_end.num_volume  = 0 
    LET p_estoque_trans_end.qtd_movto   = ma_tela1[p_ind].qtd_movto
    LET p_estoque_trans_end.cod_grade_1 = ' '
    LET p_estoque_trans_end.cod_grade_2 = ' '
    LET p_estoque_trans_end.cod_grade_3 = ' '
    LET p_estoque_trans_end.cod_grade_4 = ' '
    LET p_estoque_trans_end.cod_grade_5 = ' '
    LET p_estoque_trans_end.dat_hor_prod_ini = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.dat_hor_prod_fim = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.vlr_temperatura = 0 
    LET p_estoque_trans_end.endereco_origem = ' '
    LET p_estoque_trans_end.num_ped_ven = 0 
    LET p_estoque_trans_end.num_seq_ped_ven = 0 
    LET p_estoque_trans_end.dat_hor_producao = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.dat_hor_validade = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.num_peca   = ' '
    LET p_estoque_trans_end.num_serie  = ' '
    LET p_estoque_trans_end.comprimento = 0 
    LET p_estoque_trans_end.largura     = 0 
    LET p_estoque_trans_end.altura      = 0 
    LET p_estoque_trans_end.diametro    = 0 
    LET p_estoque_trans_end.dat_hor_reserv_1 = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.dat_hor_reserv_2 = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.dat_hor_reserv_3 = '1900-01-01 00:00:00'
    LET p_estoque_trans_end.qtd_reserv_1 = 0 
    LET p_estoque_trans_end.qtd_reserv_2 = 0 
    LET p_estoque_trans_end.qtd_reserv_3 = 0 
    LET p_estoque_trans_end.num_reserv_1 = 0 
    LET p_estoque_trans_end.num_reserv_2 = 0 
    LET p_estoque_trans_end.num_reserv_3 = 0 
    LET p_estoque_trans_end.tex_reservado = ' '
    LET p_estoque_trans_end.cus_unit_movto_p = 0 
    LET p_estoque_trans_end.cus_unit_movto_f = 0 
    LET p_estoque_trans_end.cus_tot_movto_p  = 0 
    LET p_estoque_trans_end.cus_tot_movto_f  = 0 
    LET p_estoque_trans_end.cod_item = ma_tela1[p_ind].cod_item
    LET p_estoque_trans_end.dat_movto = TODAY 
    LET p_estoque_trans_end.cod_operacao = 'IMPL'
    LET p_estoque_trans_end.ies_tip_movto = 'N'
    LET p_estoque_trans_end.num_prog = 'POL0643' 
    
    INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO", "ESTOQUE_TRANS_END")
       RETURN FALSE
    END IF    
    
    SELECT * 
      INTO p_estoque_lote.*
      FROM estoque_lote 
     WHERE cod_empresa = p_cod_emp_oper
       AND cod_item   = ma_tela1[p_ind].cod_item
       AND cod_local   = p_estoque_trans.cod_local_est_dest
	   AND ies_situa_qtd = 'L'
       AND num_lote IS NULL 
    
    IF sqlca.sqlcode = 0 THEN  
       UPDATE estoque_lote SET qtd_saldo = qtd_saldo + ma_tela1[p_ind].qtd_movto
        WHERE cod_empresa = p_cod_emp_oper
          AND cod_item   = ma_tela1[p_ind].cod_item
          AND cod_local   = p_estoque_trans.cod_local_est_dest
		  AND ies_situa_qtd = 'L'
          AND num_lote IS NULL 
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ATUALIZACAO", "ESTOQUE_LOTE")
          RETURN FALSE
       END IF    
    ELSE   
       LET p_estoque_lote.cod_empresa = p_cod_emp_oper
       LET p_estoque_lote.cod_item    = ma_tela1[p_ind].cod_item
       LET p_estoque_lote.cod_local   = p_estoque_trans.cod_local_est_dest
       LET p_estoque_lote.ies_situa_qtd = 'L' 
       LET p_estoque_lote.qtd_saldo = ma_tela1[p_ind].qtd_movto
       LET p_estoque_lote.num_transac = 0 
      
       INSERT INTO estoque_lote VALUES (p_estoque_lote.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO", "ESTOQUE_LOTE")
          RETURN FALSE
       END IF    
    END IF
    
    SELECT * 
      INTO p_estoque_lote_ender.*
      FROM estoque_lote_ender 
     WHERE cod_empresa = p_cod_emp_oper
       AND cod_item   = ma_tela1[p_ind].cod_item
	   AND ies_situa_qtd = 'L'
       AND cod_local   = p_estoque_trans.cod_local_est_dest
       AND num_lote IS NULL 
    IF sqlca.sqlcode = 0 THEN 
       UPDATE estoque_lote_ender 
          SET qtd_saldo = qtd_saldo + ma_tela1[p_ind].qtd_movto
        WHERE cod_empresa = p_cod_emp_oper
          AND cod_item   = ma_tela1[p_ind].cod_item
          AND cod_local  = p_estoque_trans.cod_local_est_dest
          AND num_lote IS NULL 
		  AND ies_situa_qtd = 'L'
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ATUALIZACAO", "ESTOQUE_LOTE")
          RETURN FALSE
       END IF    
    ELSE 
       LET p_estoque_lote_ender.cod_empresa   = p_cod_emp_oper
       LET p_estoque_lote_ender.cod_item      = ma_tela1[p_ind].cod_item
       LET p_estoque_lote_ender.cod_local     = p_estoque_trans.cod_local_est_dest
       LET p_estoque_lote_ender.endereco      = ' '
       LET p_estoque_lote_ender.num_volume    = 0 
       LET p_estoque_lote_ender.cod_grade_1   = ' '
       LET p_estoque_lote_ender.cod_grade_2   = ' '
       LET p_estoque_lote_ender.cod_grade_3   = ' '
       LET p_estoque_lote_ender.cod_grade_4   = ' '
       LET p_estoque_lote_ender.cod_grade_5   = ' '
       LET p_estoque_lote_ender.dat_hor_producao = '1900-01-01 00:00:00' 
       LET p_estoque_lote_ender.num_ped_ven = 0 
       LET p_estoque_lote_ender.num_seq_ped_ven = 0 
       LET p_estoque_lote_ender.ies_situa_qtd = 'L'
       LET p_estoque_lote_ender.qtd_saldo = ma_tela1[p_ind].qtd_movto
       LET p_estoque_lote_ender.num_transac = 0 
       LET p_estoque_lote_ender.ies_origem_entrada = ' '
       LET p_estoque_lote_ender.dat_hor_validade = '1900-01-01 00:00:00' 
       LET p_estoque_lote_ender.num_peca = ' '
       LET p_estoque_lote_ender.num_serie = ' '
       LET p_estoque_lote_ender.comprimento = 0 
       LET p_estoque_lote_ender.largura = 0 
       LET p_estoque_lote_ender.altura = 0 
       LET p_estoque_lote_ender.diametro = 0 
       LET p_estoque_lote_ender.dat_hor_reserv_1 = '1900-01-01 00:00:00' 
       LET p_estoque_lote_ender.dat_hor_reserv_2 = '1900-01-01 00:00:00' 
       LET p_estoque_lote_ender.dat_hor_reserv_3 = '1900-01-01 00:00:00' 
       LET p_estoque_lote_ender.qtd_reserv_1 = 0 
       LET p_estoque_lote_ender.qtd_reserv_2 = 0 
       LET p_estoque_lote_ender.qtd_reserv_3 = 0 
       LET p_estoque_lote_ender.num_reserv_1 = 0 
       LET p_estoque_lote_ender.num_reserv_2 = 0 
       LET p_estoque_lote_ender.num_reserv_3 = 0 
       LET p_estoque_lote_ender.tex_reservado = ' '
       
       INSERT INTO estoque_lote_ender VALUES (p_estoque_lote_ender.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO", "ESTOQUE_LOTE_ENDER")
          RETURN FALSE
       END IF    
    END IF 
    
    SELECT * 
      INTO p_estoque.*
      FROM estoque 
     WHERE cod_empresa = p_cod_emp_oper
       AND cod_item   = ma_tela1[p_ind].cod_item
    IF sqlca.sqlcode = 0 THEN 
       UPDATE estoque 
          SET qtd_liberada = qtd_liberada + ma_tela1[p_ind].qtd_movto
        WHERE cod_empresa  = p_cod_emp_oper
          AND cod_item     = ma_tela1[p_ind].cod_item
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ATUALIZACAO", "ESTOQUE")
          RETURN FALSE
       END IF    
    ELSE
       LET p_estoque.cod_empresa   = p_cod_emp_oper
       LET p_estoque.cod_item      = ma_tela1[p_ind].cod_item
       LET p_estoque.qtd_liberada  = ma_tela1[p_ind].qtd_movto
       LET p_estoque.qtd_impedida   = 0
       LET p_estoque.qtd_rejeitada  = 0 
       LET p_estoque.qtd_lib_excep  = 0
       LET p_estoque.qtd_disp_venda = 0
       LET p_estoque.qtd_reservada  = 0  
       LET p_estoque.dat_ult_invent  = TODAY
       LET p_estoque.dat_ult_entrada = TODAY
       LET p_estoque.dat_ult_saida   = TODAY
       INSERT INTO estoque VALUES (p_estoque.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO", "ESTOQUE")
          RETURN FALSE
       END IF 
    END IF       
 END FOR  
 RETURN TRUE  
END FUNCTION


#------------------------#
 FUNCTION pol0643_popup()
#------------------------#
 DEFINE p_cod_item_pe  CHAR(15)

 CASE
    WHEN infield(cod_item)
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
         LET p_cod_item_pe = vdp373_popup_item(p_cod_empresa) 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_cod_item_pe IS NOT NULL THEN
            LET ma_tela1.cod_item[pa_curr] = p_cod_item_pe
            DISPLAY ma_tela1[pa_curr].cod_item TO
                     s_itens[sc_curr].cod_item
         END IF 
 END CASE
 END FUNCTION



#------------------------------ FIM DE PROGRAMA -------------------------------#


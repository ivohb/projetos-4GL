#-----------------------------------------------------------------# 
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: POL0771                                               # 
# OBJETIVO: COPIA DE ITENS                                        #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_dat_ini            DATE, 
          p_cod_empresa        CHAR(02),
          p_cod_emp_cad        CHAR(02),
          p_ies_estoque        CHAR(01),
          p_ies_pedido         CHAR(01),
          p_ies_pgto_docum     CHAR(01),
          p_cancel             INTEGER,
          p_comando            CHAR(80),
          p_path_pol           CHAR(100),
          p_r                  CHAR(001),
          p_i                  SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_houve_erro         SMALLINT,
          p_conta              INTEGER,
          p_resposta           CHAR(1),
          p_data               DATE,
          p_hora               CHAR(05),
          p_versao             CHAR(18),  
          p_cod_item           LIKE item.cod_item,
          p_den_item           LIKE item.den_item_reduz,
          p_empresas_885       RECORD LIKE empresas_885.*, 
          p_par_pcp            RECORD LIKE par_pcp.*,
          p_cliente_item       RECORD LIKE cliente_item.*,
          p_estrutura          RECORD LIKE estrutura.*,
          p_consumo            RECORD LIKE consumo.*,
          p_consumo_compl      RECORD LIKE consumo_compl.*,
          p_item_vdp           RECORD LIKE item_vdp.*,          
          p_item_embalagem     RECORD LIKE item_embalagem.*,
          p_msg                CHAR(100)
                 
   DEFINE p_tela RECORD
      cod_item_de      LIKE item.cod_item,
      cod_item_ate     LIKE item.cod_item
   END RECORD

   DEFINE t_empresa ARRAY[100] OF RECORD
      cod_empresa LIKE empresa.cod_empresa,
      den_empresa LIKE empresa.den_empresa,
      ies_selec   CHAR(01) 
   END RECORD

   DEFINE p_user            LIKE usuario.nom_usuario,
          p_status          SMALLINT,
          p_ies_situa       SMALLINT,
          p_help            CHAR(080),
          p_nom_tela        CHAR(080),
          p_arquivo         CHAR(80),
          p_caminho         CHAR(080),
          p_ies_ctr_estoque LIKE item.ies_ctr_estoque,
          p_cod_loc_estoq   LIKE item.cod_local_estoq,
          p_ies_tem_inspecao LIKE item.ies_tem_inspecao,
          p_cod_local_insp  LIKE item.cod_local_insp,
          p_ies_ctr_lote    LIKE item.ies_ctr_lote

END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0771-10.02.01"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ 
   DEFER INTERRUPT 
   CALL log140_procura_caminho("pol07710")
      RETURNING p_caminho
   LET p_help = p_caminho CLIPPED
   OPTIONS
      HELP FILE  p_help
  
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0771_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0771_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0771") RETURNING p_nom_tela
   OPEN WINDOW w_pol0771 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0011
         MESSAGE ""
         IF log005_Seguranca(p_user,"MANUFAT","pol0771","IN") THEN 
            SELECT cod_emp_gerencial
              INTO p_cod_emp_cad
              FROM empresas_885
             WHERE cod_emp_oficial = p_cod_empresa
            IF SQLCA.sqlcode <> 0 THEN 
               SELECT cod_emp_oficial
                 INTO p_cod_emp_cad
                 FROM empresas_885
                WHERE cod_emp_gerencial = p_cod_empresa
               IF SQLCA.sqlcode <> 0 THEN
                  ERROR 'EMPRESA NAO PERMITE COPIAS'
               ELSE    
                  IF pol0771_entrada_parametros() THEN 
                     NEXT OPTION "Processar"
                  ELSE
                     NEXT OPTION "Fim"
                  END IF
               END IF    
            ELSE 
               IF pol0771_entrada_parametros() THEN 
                  NEXT OPTION "Processar"
               ELSE
                  NEXT OPTION "Fim"
               END IF
            END IF    
         END IF
      COMMAND "Processar" "Processa Copia de Produtos"
         HELP 0130
         IF log005_seguranca(p_user,"MANUFAT","pol0771","MO") THEN 
            IF pol0771_processa_copia() THEN 
               ERROR "Copia Efetuada com Sucesso !!!"
            ELSE
               ERROR "Processo cancelado"
            END IF 
         END IF
         NEXT OPTION "Fim"
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0771_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         COMMAND "Fim"        "Retorna ao Menu Anterior"
         HELP 0008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0771

END FUNCTION

#-----------------------------------#
FUNCTION pol0771_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0771
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela.* TO NULL 

   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      AFTER FIELD cod_item_de
      IF p_tela.cod_item_de IS NOT NULL THEN
         SELECT * 
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_tela.cod_item_de
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Item nao Cadastrado" 
            NEXT FIELD cod_item_de
         END IF 
      ELSE
         ERROR "O Campo Item de nao pode ser Nulo"
         NEXT FIELD cod_item_de
      END IF 

      AFTER FIELD cod_item_ate
      IF p_tela.cod_item_ate IS NOT NULL THEN
         SELECT * 
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_tela.cod_item_ate
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Item nao Cadastrado" 
            NEXT FIELD cod_item_ate
         END IF 
         IF p_tela.cod_item_ate < p_tela.cod_item_de THEN
            ERROR "O Campo Item ate nao pode ser Menor que Item de"
            NEXT FIELD cod_item_de
         ELSE
            IF p_tela.cod_item_ate <> p_tela.cod_item_de THEN
               PROMPT "Confirma Intervalo de Itens (S,N): " FOR p_r
               LET p_r = UPSHIFT(p_r)
               IF p_r = "N" THEN 
                  NEXT FIELD cod_item_de
               END IF 
            END IF 
         END IF 
      ELSE
         ERROR "O Campo Item ate nao pode ser Nulo"
         NEXT FIELD cod_item_ate
      END IF 

      ON KEY (control-z)
         CALL pol0771_popup()

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0771
   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      LET p_status = FALSE
      RETURN FALSE
   ELSE
      LET p_status = TRUE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------#
FUNCTION pol0771_popup()
#----------------------#

   CASE
      WHEN INFIELD(cod_item_de)
         LET p_tela.cod_item_de = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0771
         IF p_tela.cod_item_de IS NOT NULL THEN
            DISPLAY BY NAME p_tela.cod_item_de
         END IF
      WHEN INFIELD(cod_item_ate)
         LET p_tela.cod_item_ate = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0771
         IF p_tela.cod_item_ate IS NOT NULL THEN
            DISPLAY BY NAME p_tela.cod_item_ate
         END IF
   END CASE

END FUNCTION

#-------------------------------#
FUNCTION pol0771_processa_copia()
#-------------------------------#
  DEFINE l_cod_it_ant    LIKE item.cod_item,
         l_num_ult_com   CHAR(07)  

   IF log004_confirm(16,33) THEN
 
      #BEGIN WORK 
      CALL log085_transacao("BEGIN")
      
         LET l_cod_it_ant = ' '
 
         DECLARE cq_est CURSOR FOR
         SELECT *
         FROM estrutura
         WHERE cod_empresa = p_cod_empresa
           AND cod_item_pai BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item_pai  

         FOREACH cq_est INTO p_estrutura.* 
 
            IF p_estrutura.cod_item_pai <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_estrutura.cod_item_pai  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM estrutura
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item_pai = p_estrutura.cod_item_pai
               
               IF p_conta > 0 THEN
                   DELETE FROM estrutura 
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item_pai = p_estrutura.cod_item_pai
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","ESTRUTURA")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_estrutura.cod_empresa = p_cod_emp_cad 
            INSERT INTO estrutura VALUES (p_estrutura.*)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","ESTRUTURA")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

         LET l_cod_it_ant = ' '

         DECLARE cq_cons CURSOR FOR
         SELECT *
         FROM consumo
         WHERE cod_empresa = p_cod_empresa
           AND cod_item BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item   

         FOREACH cq_cons INTO p_consumo.* 
 
            IF p_consumo.cod_item <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_consumo.cod_item  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM consumo
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item     = p_consumo.cod_item
               
               IF p_conta > 0 THEN
                   DELETE FROM consumo
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item = p_consumo.cod_item
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","CONSUMO")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_consumo.cod_empresa = p_cod_emp_cad 
            INSERT INTO consumo VALUES (p_consumo.*)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","CONSUMO")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

         LET l_cod_it_ant = ' '

         DECLARE cq_consc CURSOR FOR
         SELECT *
         FROM consumo_compl
         WHERE cod_empresa = p_cod_empresa
           AND cod_item BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item   

         FOREACH cq_consc INTO p_consumo_compl.* 
 
            IF p_consumo_compl.cod_item <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_consumo_compl.cod_item  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM consumo_compl
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item     = p_consumo_compl.cod_item
               
               IF p_conta > 0 THEN
                   DELETE FROM consumo_compl
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item = p_consumo_compl.cod_item
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","CONSUMO_COMPL")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_consumo_compl.cod_empresa = p_cod_emp_cad 
            INSERT INTO consumo_compl VALUES (p_consumo_compl.*)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","CONSUMO_COMPL")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

         SELECT *
           INTO p_par_pcp.*
           FROM par_pcp
          WHERE cod_empresa = p_cod_empresa 

         DELETE FROM par_pcp WHERE cod_empresa = p_cod_emp_cad 
         IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("EXCLUSAO","PAR_PCP")
           LET p_houve_erro = TRUE
         END IF
         
         LET p_par_pcp.cod_empresa = p_cod_emp_cad 
         INSERT INTO par_pcp VALUES (p_par_pcp.*) 
 
         IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("INCLUSAO","PAR_PCP")
           LET p_houve_erro = TRUE
         END IF

         LET l_cod_it_ant = ' '

         DECLARE cq_cit CURSOR FOR
         SELECT *
         FROM cliente_item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item   

         FOREACH cq_cit INTO p_cliente_item.* 
 
            IF p_cliente_item.cod_item <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_cliente_item.cod_item  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM cliente_item
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item     = p_cliente_item.cod_item
               
               IF p_conta > 0 THEN
                   DELETE FROM cliente_item
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item = p_cliente_item.cod_item
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","CLIENTE_ITEM")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_cliente_item.cod_empresa = p_cod_emp_cad 
            INSERT INTO cliente_item VALUES (p_cliente_item.*)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","CLIENTE_ITEM")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

         LET l_cod_it_ant = ' '

         DECLARE cq_itemb CURSOR FOR
         SELECT *
         FROM item_embalagem
         WHERE cod_empresa = p_cod_empresa
           AND cod_item BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item   

         FOREACH cq_itemb INTO p_item_embalagem.* 
 
            IF p_item_embalagem.cod_item <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_item_embalagem.cod_item  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM item_embalagem
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item     = p_item_embalagem.cod_item
               
               IF p_conta > 0 THEN
                   DELETE FROM item_embalagem
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item = p_item_embalagem.cod_item
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","ITEM_EMBALAGEM")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_item_embalagem.cod_empresa = p_cod_emp_cad 
            INSERT INTO item_embalagem (cod_empresa, 
                                        cod_item,
                                        cod_embal,
                                        ies_tip_embal,
                                        qtd_padr_embal,
                                        vol_padr_embal,
                                        ind_multi_volume) 
                                VALUES (p_item_embalagem.cod_empresa,
                                        p_item_embalagem.cod_item,      
                                        p_item_embalagem.cod_embal,     
                                        p_item_embalagem.ies_tip_embal, 
                                        p_item_embalagem.qtd_padr_embal,
                                        p_item_embalagem.vol_padr_embal,
										p_item_embalagem.ind_multi_volume)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","ITEM_EMBALAGEM")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

         LET l_cod_it_ant = ' '

         DECLARE cq_itvdp CURSOR FOR
         SELECT *
         FROM item_vdp
         WHERE cod_empresa = p_cod_empresa
           AND cod_item BETWEEN p_tela.cod_item_de AND p_tela.cod_item_ate
         ORDER BY cod_item   

         FOREACH cq_itvdp INTO p_item_vdp.* 
 
            IF p_item_vdp.cod_item <> l_cod_it_ant THEN
            
               LET l_cod_it_ant = p_item_vdp.cod_item  
            
               LET p_conta = 0 
                                      
               SELECT count(*)
                 INTO p_conta
                 FROM item_vdp
                WHERE cod_empresa  = p_cod_emp_cad 
                  AND cod_item     = p_item_vdp.cod_item
               
               IF p_conta > 0 THEN
                   DELETE FROM item_vdp
                    WHERE cod_empresa = p_cod_emp_cad 
                     AND cod_item = p_item_vdp.cod_item
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","ITEM_VDP")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END IF 
            END IF 
               
            LET p_item_vdp.cod_empresa = p_cod_emp_cad 
            INSERT INTO item_vdp VALUES (p_item_vdp.*)
            IF SQLCA.SQLCODE <> 0 THEN
               IF SQLCA.SQLCODE <> -239 AND
                  SQLCA.SQLCODE <> -268 THEN
                  CALL log003_err_sql("INCLUSAO","ITEM_VDP")
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF 
         END FOREACH

      IF p_houve_erro = FALSE THEN
         #COMMIT WORK 
         CALL log085_transacao("COMMIT")
         MESSAGE "Copia Efetuada com Sucesso !!!"
            ATTRIBUTE(REVERSE)
         RETURN TRUE    
      ELSE
         #ROLLBACK WORK 
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

   END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0771_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------- FIM DE PROGRAMA ---------------------------------#

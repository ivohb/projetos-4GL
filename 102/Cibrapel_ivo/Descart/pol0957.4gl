#-----------K-------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0957                                                 #
# OBJETIVO: COMPONENTES DA ORDEM                                    #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 05/09/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT
         
   
   DEFINE p_familia_baixar_885 RECORD LIKE familia_baixar_885.*
   
   DEFINE p_num_ordem          LIKE ord_compon.num_ordem,
          p_num_docum          LIKE ordens.num_docum,
          p_cod_item_compon    LIKE ord_compon.cod_item_compon,
          p_cod_item_pai       LIKE ord_compon.cod_item_pai,
          p_ies_tip_item       LIKE ord_compon.ies_tip_item,
          p_dat_entrega        LIKE ord_compon.dat_entrega,
          p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,
          p_cod_local_baixa    LIKE ord_compon.cod_local_baixa,
          p_cod_cent_trab      LIKE ord_compon.cod_cent_trab,
          p_pct_refug          LIKE ord_compon.pct_refug,
          p_den_item_compon    LIKE item.den_item_reduz,
          p_den_item_pai       LIKE item.den_item_reduz,
          p_den_local          LIKE local.den_local,
          p_den_cent_trab      LIKE cent_trabalho.den_cent_trab,
          p_den_item           LIKE item.den_item_reduz,
          p_ies_situa          LIKE ordens.ies_situa,
          p_cod_item_alter     LIKE ord_compon.cod_item_compon,
          p_cod_item_inclu     LIKE ord_compon.cod_item_compon,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_qtd_planejada      LIKE ordens.qtd_planej,
          p_chamada            CHAR(01)
           
   DEFINE p_num_neces          CHAR(15),
          p_num_neces_ant      CHAR(15)
          
   DEFINE pr_compon            ARRAY[50] OF RECORD
          item_opcional        LIKE ord_compon.cod_item_compon,
          den_item_opcional    LIKE item.den_item_reduz
   END RECORD 
   
   DEFINE p_ord_compon         RECORD LIKE ord_compon.*
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0957-05.00.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0957_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0957_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0957") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0957 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol0957_le_empresa_ofic() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         IF p_ies_cons THEN 
            CALL pol0957_inclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Inclusão efetuada com sucesso !!!'
               LET p_ies_cons = FALSE 
            ELSE
               ERROR 'Operação cancelada !!!'
               LET p_ies_cons = FALSE
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a inclusão !!!"
            NEXT OPTION "Consultar"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol0957_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0957_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol0957_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            CALL pol0957_limpa_tela()
            ERROR 'Operação cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0957_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0957_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Listar" "Listagem"
         IF p_ies_cons = TRUE THEN
            CALL pol0957_listagem()
         ELSE 
            ERROR "Informe previamente os parâmetros a serem listados!!!"
         END IF     
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0957

END FUNCTION

#----------------------------#
 FUNCTION pol0957_limpa_tela()
#----------------------------#

   CLEAR FORM 
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION   

#--------------------------------#
FUNCTION pol0957_le_empresa_ofic()
#--------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#--------------------------#
 FUNCTION pol0957_inclusao()
#--------------------------#
   
   CALL pol0957_limpa_tela()
   
   DISPLAY p_num_ordem       TO num_ordem
   DISPLAY p_num_docum       TO num_docum
   DISPLAY p_cod_item_pai    TO cod_item_pai
   DISPLAY p_den_item_pai    TO den_item_pai
      
   INITIALIZE p_cod_item_inclu, 
              p_dat_entrega, 
              p_qtd_necessaria, 
              p_cod_cent_trab, 
              p_pct_refug 
      TO NULL
   
   LET p_chamada = 'I'
   
   IF pol0957_inseri_dados() THEN
   
      IF pol0957_prx_num_neces() THEN 
      ELSE
         RETURN FALSE 
      END IF 
   
      CALL log085_transacao("BEGIN")
     
      IF NOT pol0957_ins_compon(p_cod_emp_ofic) THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF NOT pol0957_ins_compon(p_cod_emp_ger) THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF NOT pol0957_ins_neces(p_cod_emp_ofic) THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF NOT pol0957_ins_neces(p_cod_emp_ger) THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      DISPLAY p_num_neces TO num_neces
      
      CALL log085_transacao("COMMIT") 
   ELSE 
      RETURN FALSE 
   END IF 
   
   RETURN TRUE 
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0957_prx_num_neces()
#-------------------------------#

   DEFINE p_prx_num_neces INTEGER
   
   SELECT prx_num_neces
     INTO p_prx_num_neces
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa
    
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','par_mrp')
      RETURN FALSE 
   END IF 
   
   IF p_prx_num_neces IS NULL THEN
      LET p_num_neces = 0
   ELSE
      LET p_num_neces = p_prx_num_neces + 1
   END IF

   UPDATE par_mrp
      SET prx_num_neces = p_num_neces
    WHERE cod_empresa   = p_cod_empresa
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('modificando','par_mrp')
      RETURN FALSE 
   END IF 
   
   RETURN TRUE 

END FUNCTION 
   
#------------------------------------#
FUNCTION pol0957_ins_compon(p_cod_emp)
#------------------------------------#

   DEFINE p_cod_emp LIKE empresa.cod_empresa
   
      INSERT INTO ord_compon 
                (cod_empresa,
                 num_ordem,
                 cod_item_pai,
                 cod_item_compon,
                 ies_tip_item,
                 dat_entrega,
                 qtd_necessaria,
                 cod_local_baixa,
                 cod_cent_trab,
                 pct_refug)
     
         VALUES (p_cod_emp,
                 p_num_ordem,
                 p_num_neces,
                 p_cod_item_inclu,
                 p_ies_tip_item,
                 p_dat_entrega,
                 p_qtd_necessaria,
                 p_cod_local_estoq,
                 p_cod_cent_trab,
                 p_pct_refug)
     
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","ord_compon")  
	       RETURN FALSE
	    END IF
	    
	    RETURN TRUE
	    
END FUNCTION

#-----------------------------------#
FUNCTION pol0957_ins_neces(p_cod_emp)
#-----------------------------------#

   DEFINE p_cod_emp LIKE empresa.cod_empresa
   
      INSERT INTO necessidades 
                (cod_empresa,
                 num_neces,
                 num_versao,
                 cod_item,
                 cod_item_pai,
                 num_ordem,
                 dat_neces,
                 qtd_necessaria,
                 qtd_saida,
                 num_docum,
                 ies_origem,
                 ies_situa,
                 num_neces_consol)
                 
         VALUES (p_cod_emp,
                 p_num_neces,
                 0,
                 p_cod_item_inclu,
                 p_cod_item_pai,
                 p_num_ordem,
                 p_dat_entrega,
                 p_qtd_necessaria,
                 0,
                 p_num_docum,
                 p_ies_situa,
                 1,
                 0)
                 
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","necessidades")  
	       RETURN FALSE
	    END IF
	    
	    RETURN TRUE
	    
END FUNCTION
	       
#-----------------------#
 FUNCTION pol0957_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cent_trab)
         CALL log009_popup(8,10,"CENTRO DE TRABALHO","cent_trabalho",
              "cod_cent_trab","den_cent_trab","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cod_cent_trab = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cent_trab
         END IF
      
      WHEN INFIELD(cod_item_compon)
         CALL pol0957_popup_compon() RETURNING p_codigo
         CURRENT WINDOW IS w_pol0957
         
         IF p_chamada = 'I' THEN
            IF p_codigo IS NOT NULL THEN
               LET p_cod_item_inclu = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_item_compon
            END IF
         ELSE
            IF p_codigo IS NOT NULL THEN
               LET p_cod_item_alter = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_item_compon
            END IF
         END IF  
   END CASE 

END FUNCTION 

#------------------------------#
 FUNCTION pol0957_popup_compon()
#------------------------------#
   
   DEFINE sql_stmt CHAR(500)
   
   LET p_index = 1
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09571") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09571 AT 8,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, FORM LINE FIRST)
   
   LET INT_FLAG = FALSE

   IF p_chamada = 'I' THEN
      LET sql_stmt = "SELECT item_opcional ",
                     "  FROM man_it_opc_grade ",
                     " WHERE empresa  = '",p_cod_empresa,"' ",
                     "   AND item_pai = '",p_cod_item_pai,"' ",
                     " ORDER BY item_opcional"
   ELSE
      LET sql_stmt = "SELECT item_alternativo ",
                     "  FROM man_it_altern_grd ",
                     " WHERE empresa            = '",p_cod_empresa,"' ",
                     "   AND item_pai           = '",p_cod_item_pai,"' ",
                     "   AND item_componente    = '",p_cod_item_compon,"' ",
                     " ORDER BY item_alternativo"
   END IF 
   
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_compon CURSOR FOR var_query

   FOREACH cq_compon INTO 
           pr_compon[p_index].item_opcional 
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("lendo","man_it_opc_grade")
         RETURN 
      END IF 
    
    SELECT den_item_reduz
      INTO pr_compon[p_index].den_item_opcional
      FROM item 
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = pr_compon[p_index].item_opcional 
       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("lendo","item")
         RETURN 
      END IF
            
      LET p_index = p_index + 1
       
      IF p_index > 1000 THEN
         ERROR 'Limite de Grades ultrapassado'
         EXIT FOREACH
      END IF
       
   END FOREACH
   
   CALL SET_COUNT(P_index - 1)
    
   DISPLAY ARRAY pr_compon TO sr_compon.* 
   
   LET p_index = ARR_CURR()
    
   CLOSE WINDOW w_pol09571
   
   IF INT_FLAG THEN
      RETURN ('')
   ELSE
      RETURN (pr_compon[p_index].item_opcional)
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol0957_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol0957_limpa_tela()
   
   INITIALIZE p_cod_item_inclu, 
              p_cod_item_alter,
              p_dat_entrega, 
              p_qtd_necessaria, 
              p_cod_cent_trab, 
              p_pct_refug,
              p_num_ordem,
              p_num_neces,
              p_num_docum,
              p_cod_item_compon,
              p_cod_item_pai,
              p_ies_tip_item,
              p_cod_local_baixa,
              p_den_item_compon,
              p_den_item_pai,
              p_den_local,
              p_den_cent_trab,
              p_den_item 
      TO NULL
   
   LET p_num_neces_ant = p_num_neces
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE
   
   INITIALIZE p_num_ordem TO NULL 
   
   INPUT p_num_ordem WITHOUT DEFAULTS FROM num_ordem 
   
      AFTER FIELD num_ordem 
         IF p_num_ordem IS NULL THEN 
            ERROR 'Campo com prenchimento obrigatório !!!'
            NEXT FIELD num_ordem
         END IF 
         
         SELECT ies_situa
           INTO p_ies_situa
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_num_ordem
            
         IF STATUS = 100 THEN 
            ERROR 'Ordem de produção não existe !!!'
            NEXT FIELD num_ordem
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'ordens')
               RETURN FALSE
            END IF 
         END IF 
         
         IF p_ies_situa MATCHES '[34]' THEN 
         ELSE   
            ERROR 'O status atual da ordem não permite modificações !!!'
            RETURN FALSE 
         END IF 
         
   END INPUT 
         
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_num_neces = p_num_neces_ant
         CALL pol0957_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR 
    SELECT cod_item_pai # numero da necessidade
      FROM ord_compon 
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem   
     ORDER BY cod_item_pai

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_neces

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol0957_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol0957_exibe_dados()
#------------------------------#

   SELECT num_docum,
          cod_item,
          qtd_planej
     INTO p_num_docum,
          p_cod_item_pai,
          p_qtd_planejada
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','ordens')
      RETURN FALSE 
   END IF
   
   SELECT cod_item_compon,
          ies_tip_item,
          dat_entrega,
          qtd_necessaria,
          cod_local_baixa,
          cod_cent_trab,
          pct_refug
     INTO p_cod_item_compon,
          p_ies_tip_item,
          p_dat_entrega,
          p_qtd_necessaria,
          p_cod_local_baixa,
          p_cod_cent_trab,
          p_pct_refug
     FROM ord_compon
    WHERE cod_empresa  = p_cod_empresa
      AND num_ordem    = p_num_ordem
      AND cod_item_pai = p_num_neces
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','ord_compon')
      RETURN FALSE 
   END IF
   
   SELECT den_item_reduz
     INTO p_den_item_compon
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','item')
      RETURN FALSE 
   END IF
   
   SELECT den_item_reduz
     INTO p_den_item_pai
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_pai
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','item_pai')
      RETURN FALSE 
   END IF
   
   SELECT den_local
     INTO p_den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local   = p_cod_local_baixa
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','local')
      RETURN FALSE 
   END IF
   
   SELECT den_cent_trab
     INTO p_den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_trab = p_cod_cent_trab
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','cent_trabalho')
      RETURN FALSE 
   END IF
   
   CALL pol0957_pega_den_tip_item()    

   DISPLAY p_num_ordem       TO num_ordem
   DISPLAY p_num_neces       TO num_neces
   DISPLAY p_num_docum       TO num_docum
   DISPLAY p_cod_item_compon TO cod_item_compon
   DISPLAY p_cod_item_pai    TO cod_item_pai
   DISPLAY p_ies_tip_item    TO ies_tip_item
   DISPLAY p_dat_entrega     TO dat_entrega
   DISPLAY p_qtd_necessaria  TO qtd_necessaria
   DISPLAY p_cod_local_baixa TO cod_local_baixa
   DISPLAY p_cod_cent_trab   TO cod_cent_trab
   DISPLAY p_pct_refug       TO pct_refug
   DISPLAY p_den_item_compon TO den_item_compon
   DISPLAY p_den_item_pai    TO den_item_pai
   DISPLAY p_den_local       TO den_local
   DISPLAY p_den_cent_trab   TO den_cent_trab
   DISPLAY p_den_item        TO den_item
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0957_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_neces_ant = p_num_neces

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_neces
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_neces
         
      END CASE
      
      IF STATUS = 0 THEN
         SELECT num_ordem
           FROM ord_compon
          WHERE cod_empresa  = p_cod_empresa
            AND num_ordem    = p_num_ordem
            AND cod_item_pai = p_num_neces
            
         IF STATUS = 0 THEN
            CALL pol0957_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_num_neces = p_num_neces_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol0957_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM ord_compon  
     WHERE cod_empresa  = p_cod_empresa
       AND num_ordem    = p_num_ordem
       AND cod_item_pai = p_num_neces
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","ord_compon")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0957_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0957_prende_registro() THEN
      DELETE FROM ord_compon
			WHERE cod_empresa  IN (p_cod_emp_ger, p_cod_emp_ofic)
    		AND num_ordem    = p_num_ordem
    		AND cod_item_pai = p_num_neces

      IF STATUS = 0 THEN               
         LET p_retorno = TRUE
      ELSE
         CALL log003_err_sql("Excluindo","ord_compon")
      END IF
      
      IF p_retorno THEN
         DELETE FROM necessidades
		    	WHERE cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic)
    		    AND num_ordem   = p_num_ordem
        		AND num_neces   = p_num_neces
      
         IF STATUS = 0 THEN               
            CALL pol0957_limpa_tela()
         ELSE
            CALL log003_err_sql("Excluindo","necessidades")
            LET p_retorno = FALSE
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
 FUNCTION pol0957_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   LET p_chamada = 'M'

   IF pol0957_prende_registro() THEN
      IF pol0957_modifica_dados() THEN
         
         UPDATE ord_compon
            SET cod_item_compon = p_cod_item_alter,
                ies_tip_item    = p_ies_tip_item,
                dat_entrega     = p_dat_entrega,
                qtd_necessaria  = p_qtd_necessaria,
                cod_local_baixa = p_cod_local_estoq,
                cod_cent_trab   = p_cod_cent_trab,
                pct_refug       = p_pct_refug
          WHERE cod_empresa     IN (p_cod_emp_ger, p_cod_emp_ofic)
            AND cod_item_pai    = p_num_neces
            AND cod_item_compon = p_cod_item_compon

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","ord_compon")
         END IF
         
         IF p_retorno THEN
            UPDATE necessidades
               SET cod_item        = p_cod_item_alter,
                   dat_neces       = p_dat_entrega,
                   qtd_necessaria  = (p_qtd_necessaria * p_qtd_planejada)
             WHERE cod_empresa     IN (p_cod_emp_ger, p_cod_emp_ofic)
               AND cod_item_pai    = p_cod_item_pai
               AND num_neces       = p_num_neces

            IF STATUS <> 0 THEN
               LET p_retorno = FALSE
               CALL log003_err_sql("Modificando","necessidades")
            END IF   
         END IF           
      ELSE
         CALL pol0957_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      LET p_cod_item_compon = p_cod_item_alter 
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION
 
#--------------------------------#
 FUNCTION pol0957_modifica_dados()
#--------------------------------#
   
   LET p_cod_item_alter = p_cod_item_compon  
   LET INT_FLAG = FALSE
              
   INPUT p_cod_item_alter, 
         p_dat_entrega,
         p_qtd_necessaria,
         p_cod_cent_trab, 
         p_pct_refug 
 WITHOUT DEFAULTS 
    FROM cod_item_compon,
         dat_entrega,
         qtd_necessaria,
         cod_cent_trab,
         pct_refug
         
         AFTER FIELD cod_item_compon
         IF p_cod_item_alter IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item_compon   
         END IF
         
         IF p_cod_item_alter = p_cod_item_compon THEN 
            
            SELECT pct_refug
              INTO p_pct_refug
              FROM ord_compon
             WHERE cod_empresa     = p_cod_empresa
               AND cod_item_pai    = p_num_neces
            
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','ord_compon')
               RETURN FALSE 
            END IF
               
         ELSE
            
            SELECT qtd_necessaria,
                   pct_refugo
              INTO p_qtd_necessaria,
                   p_pct_refug
              FROM man_it_altern_grd
             WHERE empresa          = p_cod_empresa
               AND item_pai         = p_cod_item_pai
               AND item_componente  = p_cod_item_compon
               AND item_alternativo = p_cod_item_alter
         
            IF STATUS = 100 THEN 
               ERROR 'Este item não é alternativo !!!'
               NEXT FIELD cod_item_compon
            ELSE
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql('lendo','man_it_altern_grd')
                  RETURN FALSE 
               END IF
            END IF 
         END IF 
         
         SELECT den_item_reduz,
                ies_tip_item
           INTO p_den_item_compon,
                p_ies_tip_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item_alter
         
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','item')
           RETURN FALSE 
        END IF 
         
        CALL pol0957_pega_den_tip_item() 
          
        SELECT cod_local_estoq
          INTO p_cod_local_estoq
          FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_cod_item_alter
      
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','item')
           RETURN FALSE 
        END IF 
         
        SELECT den_local
          INTO p_den_local
          FROM local
         WHERE cod_empresa = p_cod_empresa
           AND cod_local   = p_cod_local_estoq
      
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','local')
           RETURN FALSE 
        END IF
         
        DISPLAY p_pct_refug       TO pct_refug
        DISPLAY p_qtd_necessaria  TO qtd_necessaria
        DISPLAY p_cod_local_estoq TO cod_local_baixa
        DISPLAY p_den_local       TO den_local 
        DISPLAY p_den_item_compon TO den_item_compon 
        DISPLAY p_ies_tip_item    TO ies_tip_item
        DISPLAY p_den_item        TO den_item
         
        AFTER FIELD dat_entrega
        IF p_dat_entrega IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD dat_entrega   
        END IF
                 
        AFTER FIELD qtd_necessaria
        IF p_qtd_necessaria IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD qtd_necessaria   
        END IF
         
        IF p_qtd_necessaria <= 0 THEN 
           ERROR 'Valor ilegal para o campo em questão !!!'
           NEXT FIELD qtd_necessaria
        END IF 
         
        AFTER FIELD cod_cent_trab
        IF p_cod_cent_trab IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD cod_cent_trab   
        END IF
         
        SELECT cod_cent_trab
          FROM cent_trabalho
         WHERE cod_empresa       = p_cod_empresa
           AND cod_cent_trab     = p_cod_cent_trab
     
        IF STATUS = 100 THEN
           ERROR 'O código do centro de trabalho não existe !!!'
           NEXT FIELD cod_cent_trab
        ELSE 
           IF STATUS <> 0 THEN 
              CALL log003_err_sql('lendo','cent_trabalho')
              RETURN FALSE 
           END IF 
        END IF
         
        SELECT den_cent_trab
          INTO p_den_cent_trab
          FROM cent_trabalho
         WHERE cod_empresa   = p_cod_empresa
           AND cod_cent_trab = p_cod_cent_trab
     
       IF STATUS <> 0 THEN 
          CALL log003_err_sql('lendo','cent_trabalho')
          RETURN FALSE 
       END IF
         
       DISPLAY p_den_cent_trab TO den_cent_trab
         
       AFTER FIELD pct_refug
       IF p_pct_refug IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD pct_refug   
       END IF
        
       IF p_pct_refug < 0 THEN 
          ERROR "Valor ilegal para o campo em questão !!!"
          NEXT FIELD pct_refug
       END IF 
         
       IF p_pct_refug >= 100 THEN 
          ERROR "Valor ilegal para o campo em questão !!!"
          NEXT FIELD pct_refug
       END IF
       
       ON KEY(control-z)
          CALL pol0957_popup()
         
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol0957_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol0957_inseri_dados()
#------------------------------#
     
   LET INT_FLAG = FALSE
              
   INPUT p_cod_item_inclu, 
         p_dat_entrega,
         p_qtd_necessaria,
         p_cod_cent_trab, 
         p_pct_refug 
 WITHOUT DEFAULTS 
    FROM cod_item_compon,
         dat_entrega,
         qtd_necessaria,
         cod_cent_trab,
         pct_refug
         
         AFTER FIELD cod_item_compon
         IF p_cod_item_inclu IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item_compon   
         END IF
         
         SELECT qtd_necessaria,
                pct_refugo
           INTO p_qtd_necessaria,
                p_pct_refug
           FROM man_it_opc_grade
          WHERE empresa          = p_cod_empresa
            AND item_pai         = p_cod_item_pai
            AND item_opcional    = p_cod_item_inclu
              
         IF STATUS = 100 THEN 
            ERROR 'Este item não é opcional !!!'
            NEXT FIELD cod_item_compon
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','man_it_opc_grade')
               RETURN FALSE 
            END IF
         END IF 
         
         
         SELECT den_item_reduz,
                ies_tip_item
           INTO p_den_item_compon,
                p_ies_tip_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item_inclu
         
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','item')
           RETURN FALSE 
        END IF 
         
        CALL pol0957_pega_den_tip_item() 
          
        SELECT cod_local_estoq
          INTO p_cod_local_estoq
          FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_cod_item_inclu
      
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','item')
           RETURN FALSE 
        END IF 
         
        SELECT den_local
          INTO p_den_local
          FROM local
         WHERE cod_empresa = p_cod_empresa
           AND cod_local   = p_cod_local_estoq
      
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('lendo','local')
           RETURN FALSE 
        END IF
         
        DISPLAY p_pct_refug       TO pct_refug
        DISPLAY p_qtd_necessaria  TO qtd_necessaria
        DISPLAY p_cod_local_estoq TO cod_local_baixa
        DISPLAY p_den_local       TO den_local 
        DISPLAY p_den_item_compon TO den_item_compon 
        DISPLAY p_ies_tip_item    TO ies_tip_item
        DISPLAY p_den_item        TO den_item
         
        AFTER FIELD dat_entrega
        IF p_dat_entrega IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD dat_entrega   
        END IF
         
        IF p_dat_entrega < TODAY THEN 
           ERROR 'Valor ilegal para o campo em questão !!!'
           NEXT FIELD dat_entrega
        END IF 
        
        AFTER FIELD qtd_necessaria
        IF p_qtd_necessaria IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD qtd_necessaria   
        END IF
         
        IF p_qtd_necessaria <= 0 THEN 
           ERROR 'Valor ilegal para o campo em questão !!!'
           NEXT FIELD qtd_necessaria
        END IF 
         
        AFTER FIELD cod_cent_trab
        IF p_cod_cent_trab IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD cod_cent_trab   
        END IF
         
        SELECT cod_cent_trab
          FROM cent_trabalho
         WHERE cod_empresa       = p_cod_empresa
           AND cod_cent_trab     = p_cod_cent_trab
     
        IF STATUS = 100 THEN
           ERROR 'O código do centro de trabalho não existe !!!'
           NEXT FIELD cod_cent_trab
        ELSE 
           IF STATUS <> 0 THEN 
              CALL log003_err_sql('lendo','cent_trabalho')
              RETURN FALSE 
           END IF 
        END IF
         
        SELECT den_cent_trab
          INTO p_den_cent_trab
          FROM cent_trabalho
         WHERE cod_empresa   = p_cod_empresa
           AND cod_cent_trab = p_cod_cent_trab
     
       IF STATUS <> 0 THEN 
          CALL log003_err_sql('lendo','cent_trabalho')
          RETURN FALSE 
       END IF
         
       DISPLAY p_den_cent_trab TO den_cent_trab
         
       AFTER FIELD pct_refug
       IF p_pct_refug IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD pct_refug   
       END IF
        
       IF p_pct_refug < 0 THEN 
          ERROR "Valor ilegal para o campo em questão !!!"
          NEXT FIELD pct_refug
       END IF 
         
       IF p_pct_refug >= 100 THEN 
          ERROR "Valor ilegal para o campo em questão !!!"
          NEXT FIELD pct_refug
       END IF
       
       ON KEY(control-z)
          CALL pol0957_popup()
         
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol0957_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol0957_pega_den_tip_item()
#-----------------------------------#

   CASE p_ies_tip_item
      WHEN 'C' LET p_den_item = 'COMPRADO'
      WHEN 'P' LET p_den_item = 'PRODUZIDO'
      WHEN 'B' LET p_den_item = 'BENEFICIADO'
      WHEN 'F' LET p_den_item = 'FINAL'
      WHEN 'T' LET p_den_item = 'FANTASMA'
   END CASE 
   
END FUNCTION 

#--------------------------#
 FUNCTION pol0957_listagem()
#--------------------------#     

   IF NOT pol0957_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0957_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT num_ordem,
           cod_item_pai,
           cod_item_compon,
           ies_tip_item,
           dat_entrega,
           qtd_necessaria,
           cod_local_baixa,
           cod_cent_trab,
           pct_refug
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem
  ORDER BY cod_item_pai, cod_item_compon 
   
   FOREACH cq_impressao INTO p_ord_compon.* 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ord_compon')
         EXIT FOREACH
      END IF      
      
      SELECT den_item_reduz
        INTO p_den_item_compon             
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ord_compon.cod_item_compon
         
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','item')
         EXIT FOREACH 
      END IF 
      
      SELECT den_item_reduz
        INTO p_den_item_pai             
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ord_compon.cod_item_pai
         
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','item')
         EXIT FOREACH 
      END IF 
        
      OUTPUT TO REPORT pol0957_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0957_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso!!!'
   END IF

  
END FUNCTION 

#-------------------------------#
 FUNCTION pol0957_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0957.tmp"
         START REPORT pol0957_relat TO p_caminho
      ELSE
         START REPORT pol0957_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0957_le_den_empresa()
#--------------------------------#

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

#---------------------#
 REPORT pol0957_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 103, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol0915",
               COLUMN 054, "COMPONENTES DA ORDEM",
               COLUMN 123, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '  Ordem        Item pai          Descricao         Componente         Descricao       T  Dat. entrega    Quantidade     Local baixa  Centro  Refugo(%)'
         PRINT COLUMN 002, '----------  ---------------  ------------------  ---------------  ------------------  -  ------------  ---------------  -----------  ------  ---------'
                            
      ON EVERY ROW

         PRINT COLUMN 003, p_ord_compon.num_ordem        USING "##########",
               COLUMN 015, p_ord_compon.cod_item_pai,    
               COLUMN 032, p_den_item_pai,   
               COLUMN 052, p_ord_compon.cod_item_compon,
               COLUMN 069, p_den_item_compon,       
               COLUMN 089, p_ord_compon.ies_tip_item,
               COLUMN 092, p_ord_compon.dat_entrega,
               COLUMN 106, p_ord_compon.qtd_necessaria   USING "######&.&&&&&&&",
               COLUMN 123, p_ord_compon.cod_local_baixa,    
               COLUMN 136, p_ord_compon.cod_cent_trab,    
               COLUMN 144, p_ord_compon.pct_refug        USING "##&.&&&"
               
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
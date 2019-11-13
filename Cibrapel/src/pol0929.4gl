#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol0929                                                 #
# OBJETIVO: PEDIDO DE COMPRA                                        #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 27/04/2009                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_ies_zoom           SMALLINT,
          p_retorno            SMALLINT,
          p_msg                CHAR(80),
          p_ind                SMALLINT,
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
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500)  
          

   DEFINE p_tex_observ     LIKE texto_sup.tex_observ,
          p_den_transpor   LIKE clientes.nom_cliente,
          p_num_oc         LIKE ordem_sup.num_oc,
          p_ies_situa_oc   LIKE ordem_sup.ies_situa_oc,
          p_ies_situa_ped  LIKE pedido_sup.ies_situa_ped,
          p_num_versao     LIKE pedido_sup.num_versao,
          p_cod_item       LIKE item.cod_item,
          p_cod_fornecedor LIKE ordem_sup.cod_fornecedor,
          p_cnd_pgto       LIKE ordem_sup.cnd_pgto,
          p_cod_mod_embar  LIKE ordem_sup.cod_mod_embar,
          p_cod_comprador  LIKE ordem_sup.cod_comprador,
          p_num_pedido     LIKE ordem_sup.num_pedido

   DEFINE p_tela          RECORD
          num_pedido      LIKE pedido_sup.num_pedido,
          cod_loc_ent     LIKE texto_sup.num_texto,
          cod_loc_cob     LIKE texto_sup.num_texto,
          cod_transpor    LIKE clientes.cod_cliente,
          val_tot_ped     LIKE pedido_sup.val_tot_ped,
          cnd_pgto        LIKE ordem_sup.cnd_pgto,
          cod_mod_embar   LIKE ordem_sup.cod_mod_embar,
          cod_comprador   LIKE ordem_sup.cod_comprador,
          cod_fornecedor  LIKE fornecedor.cod_fornecedor,
          nom_fornecedor  LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_consulta      RECORD
          num_pedido      LIKE pedido_sup.num_pedido
   END RECORD
   
   DEFINE pr_oc           ARRAY[100] OF RECORD
          num_oc          LIKE ordem_sup.num_oc,
          val_oc          DECIMAL(10,2),
          den_item        LIKE item.den_item,
          qtd_solic       LIKE ordem_sup.qtd_solic,
          pre_unit_oc     LIKE ordem_sup.pre_unit_oc
   END RECORD
   
   DEFINE p_ped_sup       RECORD LIKE pedido_sup.*
   
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0929-05.00.01"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0929_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0929_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0929") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0929 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Gera o pedido de compra"
         CALL pol0929_incluir() RETURNING p_status
         IF p_status THEN
            ERROR "Inclusão de Dados Efetuada c/ Sucesso !!!"
         ELSE
            ERROR "Operação Cancelada !!!"
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND "Modificar" "Modifica o pedido de compra"
         IF p_ies_cons THEN
            CALL pol0929_modificar() RETURNING p_status
            IF p_status THEN
               ERROR "Modificação de Dados Efetuada c/ Sucesso !!!"
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Excluir" "Exclui o pedido de compras"
         IF p_ies_cons THEN
            IF p_tela.num_pedido IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
               CALL pol0929_excluir() RETURNING p_status
               IF p_status THEN
                  ERROR "Exclusão de Dados Efetuada c/ Sucesso !!!"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Consultar" "Consulta o pedido de compra"
         CALL pol0929_consulta() RETURNING p_status
         IF p_status THEN
            ERROR 'Consulta efetuada com sucesso!'
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0929

END FUNCTION


#-------------------------#
FUNCTION pol0929_incluir()
#-------------------------#

   LET p_ies_zoom = FALSE

   IF pol0929_info_cabec() THEN 
      INITIALIZE pr_oc TO NULL
      LET p_index = 1
      IF pol0929_info_ocs() THEN
         IF pol0929_grava_pedido() THEN
            RETURN TRUE
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#----------------------------#
FUNCTION pol0929_info_cabec()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE
      
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      BEFORE INPUT
   
         IF NOT pol0929_le_local_defout() THEN
            RETURN FALSE
         END IF
         
         DISPLAY p_tela.cod_loc_ent TO cod_loc_ent
         DISPLAY p_tela.cod_loc_cob TO cod_loc_cob
      
      BEFORE FIELD num_pedido
         NEXT FIELD cod_loc_ent
         
      AFTER FIELD cod_loc_ent

         IF p_tela.cod_loc_ent IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD cod_loc_ent
         END IF

         IF NOT pol0929_le_texto_sup(p_tela.cod_loc_ent, 'E') THEN
            NEXT FIELD cod_loc_ent
         END IF
         
         DISPLAY p_tex_observ TO den_loc_ent

      AFTER FIELD cod_loc_cob

         IF p_tela.cod_loc_cob IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD cod_loc_cob
         END IF
         
         IF NOT pol0929_le_texto_sup(p_tela.cod_loc_cob, 'C') THEN
            NEXT FIELD cod_loc_cob
         END IF

         DISPLAY p_tex_observ TO den_loc_cob

      AFTER FIELD cod_transpor

         IF p_tela.cod_transpor IS NOT NULL THEN
            IF NOT pol0929_le_transpor() THEN
               NEXT FIELD cod_transpor
            END IF
            DISPLAY p_den_transpor TO den_transpor
         END IF

      ON KEY (control-z)
         CALL pol0929_popup()
               
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0929_le_local_defout()
#---------------------------------#

   DEFINE p_num_texto LIKE par_sup.num_texto_padrao
   
   SELECT num_texto_padrao 
     INTO p_num_texto
     FROM par_sup  
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_sup')
      RETURN FALSE
   END IF
   
   SELECT num_texto 
     INTO p_tela.cod_loc_ent
     FROM texto_sup  
    WHERE cod_empresa   = p_cod_empresa
      AND ies_tip_texto = 'E'
      AND num_texto     = p_num_texto
      AND num_seq       = 1   
      
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','texto_sup')
      RETURN FALSE
   END IF
   
   SELECT num_texto 
     INTO p_tela.cod_loc_cob
     FROM texto_sup  
    WHERE cod_empresa   = p_cod_empresa
      AND ies_tip_texto = 'C'
      AND num_texto     = p_num_texto
      AND num_seq       = 1   
      
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','texto_sup')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------------------#
FUNCTION pol0929_le_texto_sup(p_cod_local, p_tip)
#------------------------------------------------#

   DEFINE p_cod_local LIKE texto_sup.num_texto,
          p_tip       CHAR(01)
   
   SELECT tex_observ 
     INTO p_tex_observ
     FROM texto_sup  
    WHERE cod_empresa   = p_cod_empresa
      AND ies_tip_texto = p_tip
      AND num_texto     = p_cod_local
      AND num_seq       = 1
   
   IF STATUS = 0 THEN 
      RETURN TRUE
   ELSE
      CALL log003_err_sql('Lendo','texto_sup')
      LET p_tex_observ = NULL
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0929_le_transpor()
#-----------------------------#

   DEFINE p_cod_class CHAR(01)
   
   SELECT nom_cliente,
          cod_class
     INTO p_den_transpor,
          p_cod_class
     FROM clientes
    WHERE cod_cliente = p_tela.cod_transpor

   IF STATUS = 0 THEN
      IF p_cod_class = 'T' THEN 
         RETURN TRUE
      ELSE
         ERROR 'Código informado não é um Transportador!'
         RETURN FALSE
      END IF
   END IF
   
   IF STATUS = 100 THEN
      ERROR "Transportador não cadastrado!"
   ELSE
      CALL log003_err_sql('Lendo','clientes')
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------#
FUNCTION pol0929_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_loc_ent)
         CALL log009_popup(8,10,"LOCAIS","texto_sup",
                     "num_texto","tex_observ","","S",
                     "  ies_tip_texto = 'E' and num_seq = 1 order by tex_observ") 
                     RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
          
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_loc_ent = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_loc_ent
         END IF      
         
      WHEN INFIELD(cod_loc_cob)
         CALL log009_popup(8,10,"LOCAIS","texto_sup",
                     "num_texto","tex_observ","","S",
                     "  ies_tip_texto = 'C' and num_seq = 1 order by tex_observ") 
                     RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
          
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_loc_cob = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_loc_cob
         END IF      

      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_transpor = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(num_oc)
         CALL pol0929_escolhe_oc() RETURNING p_codigo
         IF p_codigo IS NOT NULL THEN
            LET pr_oc[p_index].num_oc = p_codigo
            DISPLAY pr_oc[p_index].num_oc TO sr_oc[s_index].num_oc
         END IF

   END CASE

END FUNCTION 

#----------------------------#
FUNCTION pol0929_escolhe_oc()
#----------------------------#

   DEFINE pr_ordem ARRAY[1000] OF RECORD
          num_oc   LIKE ordem_sup.num_oc
   END RECORD
   
   DEFINE p_ind SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09291") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09291 AT 6,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_ind = 1
   LET INT_FLAG = FALSE
   INITIALIZE pr_ordem TO NULL
   
   DECLARE cq_ordem CURSOR FOR
    SELECT num_oc
      FROM ordem_sup
     WHERE cod_empresa      = p_cod_empresa
       AND num_pedido       = 0
       AND ies_situa_oc     = 'A'
       AND ies_versao_atual = 'S' 
       AND cod_fornecedor   = p_tela.cod_fornecedor
       AND cnd_pgto         = p_tela.cnd_pgto
       AND cod_mod_embar    = p_tela.cod_mod_embar
       AND cod_comprador    = p_tela.cod_comprador

   FOREACH cq_ordem INTO pr_ordem[p_ind].num_oc
      LET p_ind = p_ind + 1
      IF p_ind > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado!','excla')
         EXIT FOREACH
      END IF
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_ordem TO  sr_ordem.*
      LET p_ind = ARR_CURR()
   
   CLOSE WINDOW w_pol09291
   
   IF NOT INT_FLAG THEN
      IF pr_ordem[p_ind].num_oc IS NOT NULL THEN
         RETURN(pr_ordem[p_ind].num_oc)
      END IF
   END IF
   
   RETURN('')

END FUNCTION
      
       
#-------------------------#
FUNCTION pol0929_info_ocs()
#-------------------------#

   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_index)
  
   INPUT ARRAY pr_oc
      WITHOUT DEFAULTS FROM sr_oc.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      AFTER FIELD num_oc

         IF pr_oc[p_index].num_oc IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               ERROR "Campo com preenchimento obrigatório!"
               NEXT FIELD num_oc
            END IF
         ELSE
            IF pol0929_repetiu_cod() THEN
               ERROR 'OC já relacionada nesse pedido!'
               NEXT FIELD num_oc
            END IF
         
            IF NOT pol0929_le_oc() THEN
               NEXT FIELD num_oc
            END IF

         END IF

      ON KEY (control-z)
         IF p_ies_zoom THEN
            CALL pol0929_popup()
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0929_le_oc()
#-----------------------#

   SELECT ies_situa_oc,
          cod_item,
          qtd_solic,
          pre_unit_oc,
          cod_fornecedor,
          cnd_pgto,
          cod_mod_embar,
          cod_comprador,
          num_pedido
     INTO p_ies_situa_oc,
          p_cod_item,
          pr_oc[p_index].qtd_solic,
          pr_oc[p_index].pre_unit_oc,
          p_cod_fornecedor,
          p_cnd_pgto,
          p_cod_mod_embar,
          p_cod_comprador,
          p_num_pedido
     FROM ordem_sup
    WHERE cod_empresa      = p_cod_empresa
      AND num_oc           = pr_oc[p_index].num_oc
      AND ies_versao_atual =  'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_sup')
      RETURN FALSE
   END IF
   
   IF p_num_pedido <> 0 THEN
      IF p_tela.num_pedido IS NULL OR (p_num_pedido <> p_tela.num_pedido) THEN
         ERROR 'OC já está incluída em outro pedido de compra!'
         RETURN FALSE
      END IF
   END IF

   IF p_ies_situa_oc <> 'A' THEN
      ERROR 'OC não está aberta!'
      RETURN FALSE
   END IF

   IF p_cod_fornecedor IS NULL THEN
      ERROR 'OC sem Fornecedor!'
      RETURN FALSE
   END IF

   IF p_cnd_pgto <=0 THEN
      ERROR 'OC sem condições de pagamento!'
      RETURN FALSE
   END IF

   IF p_cod_mod_embar <=0 THEN
      ERROR 'OC sem modo de embarque!'
      RETURN FALSE
   END IF
   
   IF p_cod_comprador = 0 THEN
      ERROR 'OC sem código de comprador!'
      RETURN FALSE
   END IF
   
   LET pr_oc[p_index].val_oc = pr_oc[p_index].qtd_solic * pr_oc[p_index].pre_unit_oc
   
   CALL pol0929_le_item()
   
   DISPLAY pr_oc[p_index].val_oc      TO sr_oc[s_index].val_oc
   DISPLAY pr_oc[p_index].den_item    TO sr_oc[s_index].den_item
   DISPLAY pr_oc[p_index].qtd_solic   TO sr_oc[s_index].qtd_solic
   DISPLAY pr_oc[p_index].pre_unit_oc TO sr_oc[s_index].pre_unit_oc
   
   IF p_tela.val_tot_ped IS NULL THEN
      
      CALL pol0929_le_fornec()
   
      LET p_tela.cod_fornecedor = p_cod_fornecedor
      LET p_tela.cnd_pgto       = p_cnd_pgto
      LET p_tela.cod_mod_embar  = p_cod_mod_embar
      LET p_tela.cod_comprador  = p_cod_comprador
      
      DISPLAY p_tela.cnd_pgto       TO cnd_pgto
      DISPLAY p_tela.cod_mod_embar  TO cod_mod_embar
      DISPLAY p_tela.cod_comprador  TO cod_comprador
      DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
      DISPLAY p_tela.nom_fornecedor TO nom_fornecedor

   ELSE
      IF p_tela.cod_fornecedor <> p_cod_fornecedor THEN
         ERROR 'Informe uma OC com o mesmo fornecedor das atuais!'
         RETURN FALSE
      END IF
      IF p_tela.cnd_pgto <> p_cnd_pgto THEN
         ERROR 'Informe uma OC com a mesma cond pgto das atuais!'
         RETURN FALSE
      END IF
      IF p_tela.cod_mod_embar <> p_cod_mod_embar THEN
         ERROR 'Informe uma OC com o mesmo modo de embarque das atuais!'
         RETURN FALSE
      END IF
      IF p_tela.cod_comprador <> p_cod_comprador THEN
         ERROR 'Informe uma OC com o mesmo comprador das atuais!'
         RETURN FALSE
      END IF
   END IF

   CALL pol0929_calc_total()
   
   LET p_ies_zoom = TRUE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0929_le_item()
#-------------------------#

   SELECT den_item
     INTO pr_oc[p_index].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'item')
      LET  pr_oc[p_index].den_item = NULL
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0929_le_fornec()
#----------------------------#
    
   SELECT raz_social
     INTO p_tela.nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'fornecedor')
       LET p_tela.nom_fornecedor = NULL
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0929_calc_total()
#----------------------------#

   LET p_tela.val_tot_ped = 0
   
   FOR p_ind = 1 TO ARR_COUNT()
       LET p_tela.val_tot_ped = p_tela.val_tot_ped + pr_oc[p_ind].val_oc
   END FOR
   
   DISPLAY p_tela.val_tot_ped TO val_tot_ped

END FUNCTION

#-------------------------------#
FUNCTION pol0929_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_oc[p_ind].num_oc = pr_oc[p_index].num_oc THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0929_grava_pedido()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0929_atu_numped() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF      
        
   IF NOT pol0929_grava_tabs() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF      

   CALL log085_transacao("COMMIT")
   
   DISPLAY p_num_pedido TO num_pedido
   DISPLAY 'A' TO ies_situa_ped
   
   RETURN TRUE
     
END FUNCTION

#----------------------------#
FUNCTION pol0929_atu_numped()
#----------------------------#

   DECLARE cq_prende CURSOR FOR
   SELECT par_val 
     FROM par_sup_pad  
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = 'num_prx_pc'
         FOR UPDATE 
   
   OPEN cq_prende
   FETCH cq_prende INTO p_num_pedido
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","par_sup_pad")
      RETURN FALSE
   ELSE
      UPDATE par_sup_pad 
         SET par_val = (p_num_pedido + 1)
       WHERE cod_empresa   = p_cod_empresa
         AND cod_parametro = 'num_prx_pc'   
  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando', 'par_sup_pad')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
     
END FUNCTION

#----------------------------#
FUNCTION pol0929_grava_tabs()
#----------------------------#

   IF NOT pol0929_ins_pedido_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol0929_ins_audit_sup() THEN
      RETURN FALSE
   END IF

   IF NOT atu_ordem_sup() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0929_ins_pedido_sup()
#--------------------------------#

   INITIALIZE p_ped_sup TO NULL

   LET p_num_versao = 1
   LET p_ped_sup.cod_empresa = p_cod_empresa
   LET p_ped_sup.num_pedido = p_num_pedido
   LET p_ped_sup.num_versao = 1
   LET p_ped_sup.ies_versao_atual = 'S'
   LET p_ped_sup.ies_situa_ped = 'A'
   LET p_ped_sup.dat_emis = TODAY
   LET p_ped_sup.dat_liquidac = ''
   LET p_ped_sup.cod_fornecedor = p_tela.cod_fornecedor
   LET p_ped_sup.cod_moeda = 1
   LET p_ped_sup.cnd_pgto = p_tela.cnd_pgto
   LET p_ped_sup.cod_mod_embar = p_tela.cod_mod_embar
   LET p_ped_sup.num_texto_loc_entr = p_tela.cod_loc_ent
   LET p_ped_sup.num_texto_loc_cobr = p_tela.cod_loc_cob
   LET p_ped_sup.cod_transpor = p_tela.cod_transpor
   LET p_ped_sup.val_tot_ped = p_tela.val_tot_ped
   LET p_ped_sup.cod_comprador = p_tela.cod_comprador
   LET p_ped_sup.ies_impresso = 'N'
   LET p_ped_sup.ies_ped_automatic = 'N'
   
   INSERT INTO pedido_sup(
      cod_empresa,
      num_pedido,
      num_versao,
      ies_versao_atual,
      ies_situa_ped,
      dat_emis,
      dat_liquidac,
      cod_fornecedor,
      cod_moeda,
      cnd_pgto,
      cod_mod_embar,
      num_texto_loc_entr,
      num_texto_loc_cobr,
      cod_transpor,    
      val_tot_ped,
      cod_comprador,
      ies_impresso,
      ies_ped_automatic)
   VALUES(p_ped_sup.*)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo', 'pedido_sup')
      RETURN FALSE
   END IF
   
   RETURN TRUE
     
END FUNCTION

#--------------------------------#
FUNCTION pol0929_ins_audit_sup()
#--------------------------------#

   DEFINE p_audit_sup RECORD LIKE audit_sup.*

   LET p_audit_sup.cod_empresa      = p_cod_empresa
   LET p_audit_sup.num_pedido_ordem = p_ped_sup.num_pedido
   LET p_audit_sup.ies_tipo         = '1'
   LET p_audit_sup.num_versao       = p_ped_sup.num_versao
   LET p_audit_sup.nom_usuario      = p_user
   LET p_audit_sup.dat_proces       = p_ped_sup.dat_emis
   LET p_audit_sup.hor_operac       = TIME
   LET p_audit_sup.num_prog         = 'POL0929'
         
   INSERT INTO audit_sup(
      cod_empresa,
      num_pedido_ordem,
      ies_tipo,
      num_versao,
      nom_usuario,
      dat_proces,
      hor_operac,
      num_prog)
   VALUES(p_audit_sup.*)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo', 'audit_sup')
      RETURN FALSE
   END IF
   
   RETURN TRUE
     
END FUNCTION

#----------------------#
FUNCTION atu_ordem_sup()
#----------------------#

   LET p_count = 0
   
   FOR p_ind = 1 TO ARR_COUNT()
   
      UPDATE ordem_sup
         SET num_pedido        = p_num_pedido,
             num_versao_pedido = p_num_versao
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = pr_oc[p_ind].num_oc
         AND ies_versao_atual = 'S'
             
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Atualizando', 'ordem_sup')
         RETURN FALSE
      END IF
      
      LET p_count = p_count + 1
      
      SELECT cod_item
        INTO p_cod_item
        FROM ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = pr_oc[p_ind].num_oc
         AND ies_versao_atual = 'S'

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo', 'ordem_sup:aos')
         RETURN FALSE
      END IF
        
      LET p_msg = 'Ultima compra do ITEM na empresa'
      
      IF NOT pol0929_ins_sup_par(1) THEN
         RETURN FALSE
      END IF

      LET p_msg = 'Ultima compra do ITEM x FORNECEDOR na empresa'
      
      IF NOT pol0929_ins_sup_par(2) THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0929_ins_sup_ctr() THEN
         RETURN FALSE
      END IF
      
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0929_ins_sup_par(p_seq)
#----------------------------------#

   DEFINE p_seq SMALLINT,
          p_emp CHAR(02),
          p_oc  INTEGER,
          p_dat CHAR(10)

   DECLARE cq_sup CURSOR FOR
    SELECT sup_par_oc.empresa,
           sup_par_oc.ordem_compra,
           pedido_sup.dat_emis
      FROM ordem_sup,
           sup_par_oc,
           pedido_sup
     WHERE ordem_sup.cod_empresa       = p_cod_empresa
       AND ordem_sup.num_oc           <> pr_oc[p_ind].num_oc
       AND ordem_sup.ies_versao_atual  = 'S'
       AND ordem_sup.ies_situa_oc     <> 'C'
       AND ordem_sup.cod_item          = p_cod_item
       AND sup_par_oc.empresa          = ordem_sup.cod_empresa
       AND sup_par_oc.ordem_compra     = ordem_sup.num_oc
       AND sup_par_oc.parametro        = 'ultima_compra_item'
       AND sup_par_oc.seq_parametro    = p_seq
       AND pedido_sup.cod_empresa      = ordem_sup.cod_empresa
       AND pedido_sup.num_pedido       = ordem_sup.num_pedido
       AND pedido_sup.ies_versao_atual = 'S'
       AND pedido_sup.dat_emis        <= p_ped_sup.dat_emis 
     ORDER BY pedido_sup.dat_emis DESC,
              sup_par_oc.ordem_compra DESC
   
   FOREACH cq_sup INTO p_emp, p_oc, p_dat

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','sup_par_oc')
         RETURN FALSE
      END IF
      
      INSERT INTO sup_par_oc(
         empresa,
         ordem_compra,
         parametro,
         seq_parametro,
         des_parametro,
         parametro_ind,
         parametro_texto,
         parametro_val,
         parametro_num,
         parametro_dat)
      VALUES(p_cod_empresa,
             pr_oc[p_ind].num_oc,
             'ultima_compra_item',
             p_seq,
             p_msg,
             '',
             p_emp,
             '',
             p_oc,
             p_dat)
             
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','sup_par_oc')
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0929_ins_sup_ctr()
#-----------------------------#

   DEFINE p_qtd_neces DECIMAL(10,3)
   
   DECLARE cq_est CURSOR FOR
    SELECT cod_item_comp, 
           qtd_necessaria 
      FROM estrut_ordem_sup  
     WHERE cod_empresa = p_cod_empresa
       AND num_oc      = pr_oc[p_ind].num_oc
     ORDER BY cod_item_comp

   FOREACH cq_est INTO p_cod_item, p_qtd_neces
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_ordem_sup')
         RETURN FALSE
      END IF
      
      LET p_qtd_neces = p_qtd_neces * pr_oc[p_ind].qtd_solic
      
      SELECT item
        FROM sup_ctr_ped_compra
       WHERE empresa       = p_cod_empresa
         AND pedido_compra = p_num_pedido
         AND item          = p_cod_item

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','sup_ctr_ped_compra')
         RETURN FALSE
      END IF
         
      INSERT INTO sup_ctr_ped_compra(
         empresa,
         pedido_compra,
         item,
         qtd,
         qtd_enviada)
      VALUES(p_cod_empresa,
             p_num_pedido,
             p_cod_item,
             p_qtd_neces,0)
             
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','sup_ctr_ped_compra')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0929_consulta()
#--------------------------#

   INITIALIZE p_consulta TO NULL
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_consulta.*
      WITHOUT DEFAULTS
      
      AFTER FIELD num_pedido
      
         IF p_consulta.num_pedido IS NULL THEN
            ERROR "Campo com preenchimento obrigatório"
            NEXT FIELD num_pedido
         END IF
   
         LET p_tela.num_pedido = p_consulta.num_pedido
         
         IF NOT pol0929_checa_pedido() THEN
            NEXT FIELD num_pedido
         END IF
            
   END INPUT
   
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   IF NOT pol0929_exibe_ocs() THEN
      RETURN FALSE
   END IF

   CALL SET_COUNT(p_index)
   
   IF p_index > 9 THEN
      DISPLAY ARRAY pr_oc TO sr_oc.*
   ELSE
      INPUT ARRAY pr_oc WITHOUT DEFAULTS FROM sr_oc.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
      
   LET p_ies_cons = TRUE
   
   RETURN TRUE
      
END FUNCTION 

#------------------------------#
FUNCTION pol0929_checa_pedido()
#------------------------------#

   SELECT MAX(num_versao)
     INTO p_num_versao
     FROM pedido_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup:1')
      RETURN FALSE
   END IF
   
   IF p_num_versao IS NULL THEN
      ERROR 'Pedido Inexistente!'
      RETURN FALSE
   END IF
            
   SELECT ies_situa_ped,
          cod_transpor,
          cnd_pgto,
          cod_mod_embar,
          cod_comprador,
          cod_fornecedor,
          num_texto_loc_entr,
          num_texto_loc_cobr,
          val_tot_ped,
          dat_emis
     INTO p_ies_situa_ped,
          p_tela.cod_transpor,
          p_tela.cnd_pgto,
          p_tela.cod_mod_embar,
          p_tela.cod_comprador,
          p_tela.cod_fornecedor,
          p_tela.cod_loc_ent,
          p_tela.cod_loc_cob,
          p_tela.val_tot_ped,
          p_ped_sup.dat_emis
     FROM pedido_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_consulta.num_pedido
      AND num_versao  = p_num_versao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup:2')
      RETURN FALSE
   END IF

   LET p_cod_fornecedor = p_tela.cod_fornecedor
   CALL pol0929_le_fornec()
   
   DISPLAY p_ies_situa_ped TO ies_situa_ped
   DISPLAY BY NAME p_tela.*
   
   CALL pol0929_le_texto_sup(p_tela.cod_loc_ent, 'E') RETURNING p_status
   DISPLAY p_tex_observ TO den_loc_ent
   CALL pol0929_le_texto_sup(p_tela.cod_loc_cob, 'C') RETURNING p_status
   DISPLAY p_tex_observ TO den_loc_cob

   CALL pol0929_le_transpor() RETURNING p_status
   DISPLAY p_den_transpor TO den_transpor
               
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0929_exibe_ocs()
#---------------------------#

   LET p_index = 1
   
   DECLARE cq_ocs CURSOR FOR
    SELECT num_oc,
           cod_item,
           qtd_solic,
           pre_unit_oc
      FROM ordem_sup
     WHERE cod_empresa      = p_cod_empresa
       AND num_pedido       = p_tela.num_pedido
       AND ies_versao_atual =  'S'

   FOREACH cq_ocs INTO 
           pr_oc[p_index].num_oc,
           p_cod_item,
           pr_oc[p_index].qtd_solic,
           pr_oc[p_index].pre_unit_oc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ocs')
         RETURN FALSE
      END IF
      
      LET pr_oc[p_index].val_oc = pr_oc[p_index].qtd_solic * pr_oc[p_index].pre_unit_oc
      
      CALL pol0929_le_item()
   
      LET p_index = p_index + 1
      
   END FOREACH
   
   LET p_index = p_index - 1
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0929_checa_situacao()
#--------------------------------#

   IF p_ies_situa_ped <> 'A' THEN
      LET p_msg = 'Situação do pedido não permite essa operação!'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0929_modificar()
#---------------------------#

   IF NOT pol0929_checa_situacao() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_zoom = TRUE
   
   IF NOT pol0929_info_ocs() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0929_atualiza_pedido()THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0929_atualiza_pedido()
#---------------------------------#

   IF NOT pol0929_exclui_ped_oc() THEN
      RETURN FALSE
   END IF
   
   LET p_num_pedido = p_tela.num_pedido
   
   IF NOT atu_ordem_sup() THEN
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      CALL pol0929_atu_pedido() RETURNING p_status
   ELSE
      CALL pol0929_exc_pedido() RETURNING p_status
   END IF

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#-------------------------------#
FUNCTION pol0929_exclui_ped_oc()
#-------------------------------#

   DECLARE cq_epoc CURSOR FOR
    SELECT num_oc
      FROM ordem_sup
     WHERE cod_empresa      = p_cod_empresa
       AND num_pedido       = p_tela.num_pedido
       AND ies_versao_atual =  'S'

   FOREACH cq_epoc INTO p_num_oc
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_epoc')
         RETURN FALSE
      END IF
      
      DELETE FROM sup_par_oc
       WHERE empresa      = p_cod_empresa
         AND ordem_compra = p_num_oc
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','sup_par_oc')
         RETURN FALSE
      END IF
            
   END FOREACH
            
   UPDATE ordem_sup
      SET num_pedido        = 0,
          num_versao_pedido = 0
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM sup_ctr_ped_compra
    WHERE empresa       = p_cod_empresa
      AND pedido_compra = p_tela.num_pedido
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','sup_ctr_ped_compra')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0929_atu_pedido()
#----------------------------#

   UPDATE pedido_sup
      SET val_tot_ped = p_tela.val_tot_ped
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido
      AND num_versao  = p_num_versao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','pedido_sup')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0929_exc_pedido()
#----------------------------#

   DELETE FROM pedido_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','pedido_sup')
      RETURN FALSE
   END IF

   DELETE FROM audit_sup
    WHERE cod_empresa      = p_cod_empresa
      AND num_pedido_ordem = p_tela.num_pedido
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','audit_sup')
      RETURN FALSE
   END IF

   DELETE FROM sup_ctr_ped_compra
    WHERE empresa       = p_cod_empresa
      AND pedido_compra = p_tela.num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','sup_ctr_ped_compra')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0929_excluir()
#-------------------------#

   IF NOT pol0929_checa_situacao() THEN
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF

   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0929_exclui_ped_oc() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   IF NOT pol0929_exc_pedido() THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   
   RETURN TRUE

END FUNCTION

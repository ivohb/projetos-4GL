#-------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O LOGIX X TRIM                                 #
# PROGRAMA: pol0607                                                 #
# OBJETIVO: CADASTRO DOS DADOS PADR�O DE ITEM                       #
# AUTOR...: IVO HON�RIO BARBOSA                                     #
# DATA....: 16/06/2007                                              #
# TABELA..: p_par_item_885                                          #
# CONVERS�O 10.02: 16/07/2014 - IVO                                 #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_tecla              INTEGER,
          p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_cont2              SMALLINT,
          p_ies_tip_item       LIKE par_item_885.ies_tip_item,  
          p_ies_ctr_estoque    LIKE par_item_885.ies_ctr_estoque,  
          p_ies_ctr_lote       LIKE par_item_885.ies_ctr_lote,  
          p_ies_tem_inspecao   LIKE par_item_885.ies_tem_inspecao, 
          p_ies_mrp_apont      LIKE par_item_885.ies_mrp_apont,  
          p_ies_sofre_baixa    LIKE par_item_885.ies_sofre_baixa,  
          p_num_casa_dec       LIKE par_item_885.num_casa_dec, 
          p_plano_neces        LIKE par_item_885.plano_neces, 
          p_cod_local_estoq    LIKE par_item_885.cod_local_estoq, 
          p_cod_local_insp     LIKE par_item_885.cod_local_insp, 
          p_cod_local_receb    LIKE par_item_885.cod_local_receb, 
          p_cod_local_prod     LIKE par_item_885.cod_local_prod, 
          p_qtd_prog_minima    LIKE par_item_885.qtd_prog_minima, 
          p_qtd_prog_maxima    LIKE par_item_885.qtd_prog_maxima,
          p_qtd_prog_multipla  LIKE par_item_885.qtd_prog_multipla, 
          p_qtd_prog_fixa      LIKE par_item_885.qtd_prog_fixa, 
          p_qtd_estoq_seg      LIKE par_item_885.qtd_estoq_seg, 
          p_fat_conver         LIKE par_item_885.fat_conver, 
          p_pct_ipi            LIKE par_item_885.pct_ipi, 
          p_pct_refug          LIKE par_item_885.pct_refug, 
          p_cod_cla_fisc       LIKE par_item_885.cod_cla_fisc, 
          p_tempo_ressup       LIKE par_item_885.tempo_ressup, 
          p_cod_familia        LIKE par_item_885.cod_familia, 
          p_cod_roteiro        LIKE par_item_885.cod_roteiro, 
          p_gru_ctr_estoq      LIKE par_item_885.gru_ctr_estoq, 
          p_qtd_dias_min_ord   LIKE par_item_885.qtd_dias_min_ord, 
          p_cod_horizon        LIKE par_item_885.cod_horizon, 
          p_num_altern_roteiro LIKE par_item_885.num_altern_roteiro, 
          p_cod_lin_prod       LIKE par_item_885.cod_lin_prod, 
          p_cod_lin_recei      LIKE par_item_885.cod_lin_recei, 
          p_cod_seg_merc       LIKE par_item_885.cod_seg_merc, 
          p_cod_cla_uso        LIKE par_item_885.cod_cla_uso, 
          p_ies_forca_apont    LIKE par_item_885.ies_forca_apont,  
          p_ies_abert_liber    LIKE par_item_885.ies_abert_liber,  
          p_ies_baixa_comp     LIKE par_item_885.ies_baixa_comp,  
          p_ies_lista_ordem    LIKE par_item_885.ies_lista_ordem,  
          p_ies_lista_roteiro  LIKE par_item_885.ies_lista_roteiro,  
          p_ies_apontamento    LIKE par_item_885.ies_apontamento,  
          p_ies_tip_apont      LIKE par_item_885.ies_tip_apont,  
          p_ies_apont_aut      LIKE par_item_885.ies_apont_aut,
          p_msg                CHAR(100)  
          
          
   DEFINE p_par_item_885       RECORD LIKE par_item_885.*,
          p_par_item_885a      RECORD LIKE par_item_885.* 

   DEFINE p_cod_clas_item      LIKE par_item_885.cod_clas_item,
          p_cod_clas_itema     LIKE par_item_885.cod_clas_item,
          p_zoom_clas_fisc     SMALLINT
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0607-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0607.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0607_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0607_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0607") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0607 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0607_inclusao() THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0607_modificacao() THEN
               ERROR 'Modifica��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0607_exclusao() THEN
               MESSAGE 'Exclus�o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0607_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0607_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0607_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
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
   CLOSE WINDOW w_pol0607

END FUNCTION

#--------------------------#
 FUNCTION pol0607_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0607_inicializa()
   LET p_par_item_885.cod_empresa = p_cod_empresa
   
   IF pol0607_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_item_885 VALUES (p_par_item_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 CALL log003_err_sql("INCLUSAO","par_item_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION pol0607_inicializa()
#----------------------------#

   INITIALIZE p_par_item_885 TO NULL
   
   LET p_par_item_885.ies_ctr_estoque   = 'N'
   LET p_par_item_885.ies_ctr_lote      = 'N'
   LET p_par_item_885.ies_tem_inspecao  = 'N'
   LET p_par_item_885.ies_sofre_baixa   = 'N'
   LET p_par_item_885.ies_apont_aut     = 'N'
   LET p_par_item_885.ies_forca_apont   = 'N'
   
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0607_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_par_item_885.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_clas_item
         IF p_funcao = 'M' THEN
            NEXT FIELD ies_tip_item
         END IF
      
      AFTER FIELD cod_clas_item
         IF LENGTH(p_par_item_885.cod_clas_item) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_clas_item   
         END IF

         IF NOT pol0607_le_par_item_885() THEN
            NEXT FIELD cod_clas_item   
         END IF
         
      AFTER FIELD ies_tip_item
         IF LENGTH(p_par_item_885.ies_tip_item) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD ies_tip_item   
         END IF

         IF p_par_item_885.ies_tip_item = 'T' OR
            p_par_item_885.ies_tip_item = 'P' OR
            p_par_item_885.ies_tip_item = 'C' OR
            p_par_item_885.ies_tip_item = 'F' OR
            p_par_item_885.ies_tip_item = 'B' THEN
         ELSE
            ERROR 'Tipo de item inv�lido !!!'
            NEXT FIELD ies_tip_item
         END IF

      AFTER FIELD num_casa_dec
         IF p_par_item_885.num_casa_dec IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD num_casa_dec   
         END IF
     
      AFTER FIELD plano_neces
         IF p_par_item_885.plano_neces IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD plano_neces   
         END IF
     
      BEFORE FIELD cod_local_estoq
         IF p_par_item_885.ies_ctr_estoque = 'N' THEN
            LET p_par_item_885.cod_local_estoq = NULL
            DISPLAY '' TO cod_local_estoq
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2002 THEN
               NEXT FIELD plano_neces
            ELSE
               NEXT FIELD cod_local_insp
            END IF
         END IF
         
      AFTER FIELD cod_local_estoq
         IF LENGTH(p_par_item_885.cod_local_estoq) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_local_estoq   
         END IF

         IF NOT pol0607_le_local(p_par_item_885.cod_local_estoq) THEN
            NEXT FIELD cod_local_estoq   
         END IF

      BEFORE FIELD cod_local_insp
         IF p_par_item_885.ies_tem_inspecao = 'N' THEN
            LET p_par_item_885.cod_local_insp = NULL
            DISPLAY '' TO cod_local_insp
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2002 THEN
               NEXT FIELD cod_local_estoq
            ELSE
               NEXT FIELD cod_local_receb
            END IF
         END IF
         
      AFTER FIELD cod_local_insp
         IF LENGTH(p_par_item_885.cod_local_insp) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_local_insp   
         END IF

         IF NOT pol0607_le_local(p_par_item_885.cod_local_insp) THEN
            NEXT FIELD cod_local_insp   
         END IF

      AFTER FIELD cod_local_receb
         IF LENGTH(p_par_item_885.cod_local_receb) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_local_receb   
         END IF

         IF NOT pol0607_le_local(p_par_item_885.cod_local_receb) THEN
            NEXT FIELD cod_local_receb   
         END IF

      AFTER FIELD cod_local_prod
         IF LENGTH(p_par_item_885.cod_local_prod) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_local_prod   
         END IF

         IF NOT pol0607_le_local(p_par_item_885.cod_local_prod) THEN
            NEXT FIELD cod_local_prod   
         END IF

      AFTER FIELD qtd_prog_minima
         IF LENGTH(p_par_item_885.qtd_prog_minima) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_prog_minima   
         END IF

      AFTER FIELD qtd_prog_maxima
         IF LENGTH(p_par_item_885.qtd_prog_maxima) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_prog_maxima   
         END IF

      AFTER FIELD qtd_prog_multipla
         IF LENGTH(p_par_item_885.qtd_prog_multipla) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_prog_multipla   
         END IF

      AFTER FIELD qtd_prog_fixa
         IF LENGTH(p_par_item_885.qtd_prog_fixa) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_prog_fixa   
         END IF

      AFTER FIELD qtd_estoq_seg
         IF LENGTH(p_par_item_885.qtd_estoq_seg) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_estoq_seg   
         END IF

      AFTER FIELD fat_conver
         IF LENGTH(p_par_item_885.fat_conver) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD fat_conver   
         END IF

      AFTER FIELD pct_ipi
         IF LENGTH(p_par_item_885.pct_ipi) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD pct_ipi   
         END IF

      AFTER FIELD pct_refug
         IF LENGTH(p_par_item_885.pct_refug) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD pct_refug   
         END IF

      BEFORE FIELD cod_cla_fisc
         LET p_zoom_clas_fisc = FALSE
      
      AFTER FIELD cod_cla_fisc
         IF LENGTH(p_par_item_885.cod_cla_fisc) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_cla_fisc   
         END IF

         IF NOT p_zoom_clas_fisc THEN
            IF NOT pol0607_le_clas_fiscal() THEN
               NEXT FIELD cod_cla_fisc   
            END IF
         END IF
         
         DISPLAY p_par_item_885.pct_ipi TO pct_ipi

      AFTER FIELD tempo_ressup
         IF LENGTH(p_par_item_885.tempo_ressup) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD tempo_ressup   
         END IF

      AFTER FIELD cod_familia
         IF LENGTH(p_par_item_885.cod_familia) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_familia   
         END IF

         IF NOT pol0607_le_familia() THEN
            NEXT FIELD cod_familia   
         END IF

      AFTER FIELD cod_roteiro
         IF LENGTH(p_par_item_885.cod_roteiro) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_roteiro   
         END IF

         IF NOT pol0607_le_roteiro() THEN
            NEXT FIELD cod_roteiro
         END IF

      AFTER FIELD gru_ctr_estoq
         IF LENGTH(p_par_item_885.gru_ctr_estoq) > 0 THEN 
            IF NOT pol0607_le_grupo_ctr_estoq() THEN
               NEXT FIELD gru_ctr_estoq   
            END IF
         END IF

      AFTER FIELD qtd_dias_min_ord
         IF LENGTH(p_par_item_885.qtd_dias_min_ord) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD qtd_dias_min_ord   
         END IF
         
      AFTER FIELD cod_horizon
         IF LENGTH(p_par_item_885.cod_horizon) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_horizon   
         END IF
         
      BEFORE FIELD cod_lin_prod
         IF p_par_item_885.cod_lin_prod IS NULL THEN
            LET p_par_item_885.cod_lin_prod  = 0
            LET p_par_item_885.cod_lin_recei = 0
            LET p_par_item_885.cod_seg_merc  = 0
            LET p_par_item_885.cod_cla_uso   = 0
         END IF
         
      AFTER FIELD cod_lin_prod
         IF LENGTH(p_par_item_885.cod_lin_prod) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_lin_prod   
         END IF

      AFTER FIELD cod_lin_recei
         IF LENGTH(p_par_item_885.cod_lin_recei) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_lin_recei   
         END IF
    
      AFTER FIELD cod_seg_merc
         IF LENGTH(p_par_item_885.cod_seg_merc) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_seg_merc   
         END IF

      AFTER FIELD cod_cla_uso
         IF LENGTH(p_par_item_885.cod_cla_uso) = 0 THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_cla_uso   
         END IF
         
         IF NOT pol0607_le_linha_prod() THEN
            NEXT FIELD cod_lin_prod
         END IF

      ON KEY (control-z)
         CALL pol0607_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0607_le_par_item_885()
#-----------------------------------#

   SELECT cod_empresa
     FROM par_item_885
    WHERE cod_empresa   = p_cod_empresa
      AND cod_clas_item = p_par_item_885.cod_clas_item

   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 0 THEN
         ERROR 'Os dados padr�o dessa classifica��o j� est�o cadastrados !!!'
      ELSE
         CALL log003_err_sql("LEITURA","par_item_885")       
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------------#
FUNCTION pol0607_le_local(p_cod_local)
#------------------------------------#
   
   DEFINE p_cod_local LIKE local.cod_local

   SELECT den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local   = p_cod_local

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Local N�o Cadastrado !!!'
      ELSE
         CALL log003_err_sql("LEITURA","local")       
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#----------------------------#
FUNCTION pol0607_le_familia()
#----------------------------#

   SELECT den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_par_item_885.cod_familia

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Familia N�o Cadastrada !!!'
      ELSE
         CALL log003_err_sql("LEITURA","grupo_ctr_estoq")       
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION pol0607_le_roteiro()
#----------------------------#

   SELECT den_roteiro
     FROM roteiro
    WHERE cod_empresa = p_cod_empresa
      AND cod_roteiro = p_par_item_885.cod_roteiro
      
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Roteiro N�o Cadastrado !!!'
      ELSE
         CALL log003_err_sql("LEITURA","grupo_ctr_estoq") 
         RETURN FALSE      
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------------#
FUNCTION pol0607_le_grupo_ctr_estoq()
#-----------------------------------#

   SELECT den_gru_ctr_estoq
     FROM grupo_ctr_estoq
    WHERE cod_empresa   = p_cod_empresa
      AND gru_ctr_estoq = p_par_item_885.gru_ctr_estoq

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Grupo de Controle de Estoque N�o Cadastrado !!!'
      ELSE
         CALL log003_err_sql("LEITURA","grupo_ctr_estoq")       
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#----------------------------------#
FUNCTION pol0607_le_linha_prod()
#----------------------------------#

   SELECT den_estr_linprod 
     FROM linha_prod 
    WHERE cod_lin_prod  = p_par_item_885.cod_lin_prod
      AND cod_lin_recei = p_par_item_885.cod_lin_recei
      AND cod_seg_merc  = p_par_item_885.cod_seg_merc
      AND cod_cla_uso   = p_par_item_885.cod_cla_uso

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Linha de Produ��o N�o Cadastrado !!!'
      ELSE
         CALL log003_err_sql("LEITURA","linha_prod")       
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#--------------------------------#
FUNCTION pol0607_le_clas_fiscal()
#--------------------------------#

   DECLARE cq_clas_fisc CURSOR FOR
    SELECT pct_ipi 
      FROM clas_fiscal
     WHERE cod_cla_fisc = p_par_item_885.cod_cla_fisc

   OPEN cq_clas_fisc
   FETCH cq_clas_fisc INTO p_par_item_885.pct_ipi

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         ERROR 'Classifica��o Fiscal N�o Cadastrado !!!'
      ELSE
         CALL log003_err_sql("LEITURA","clas_fiscal")       
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-----------------------#
FUNCTION pol0607_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_local_estoq)
         LET p_codigo = log009_popup(8,10,"LOCAL DE ESTOQUE","local",
                        "cod_local","den_local","sup0470","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_local_estoq = p_codigo
           DISPLAY p_codigo TO cod_local_estoq
         END IF

      WHEN INFIELD(cod_local_insp)
         LET p_codigo = log009_popup(8,10,"LOCAL DE ESTOQUE","local",
                        "cod_local","den_local","sup0470","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_local_insp = p_codigo
           DISPLAY p_codigo TO cod_local_insp
         END IF

      WHEN INFIELD(cod_local_receb)
         LET p_codigo = log009_popup(8,10,"LOCAL DE ESTOQUE","local",
                        "cod_local","den_local","sup0470","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_local_receb = p_codigo
           DISPLAY p_codigo TO cod_local_receb
         END IF

      WHEN INFIELD(cod_local_prod)
         LET p_codigo = log009_popup(8,10,"LOCAL DE ESTOQUE","local",
                        "cod_local","den_local","sup0470","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_local_prod = p_codigo
           DISPLAY p_codigo TO cod_local_prod
         END IF

      WHEN INFIELD(gru_ctr_estoq)
         LET p_codigo = log009_popup(8,10,"GRUPO CONT. DE ESTOQUE","grupo_ctr_estoq",
                        "gru_ctr_estoq","den_gru_ctr_estoq","sup0270","S","") 
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.gru_ctr_estoq = p_codigo
           DISPLAY p_codigo TO gru_ctr_estoq
         END IF

      WHEN INFIELD(cod_cla_fisc)
         CALL pol0607_escolhe_clas_fisc() 

      WHEN INFIELD(cod_lin_prod)
         CALL pol0607_escolhe_linha_prod() 

      WHEN INFIELD(cod_familia)
         LET p_codigo = log009_popup(8,10,"FAMILIAS DE PRODUTOS ","familia",
                        "cod_familia","den_familia","","S","") 
                        
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_familia = p_codigo
           DISPLAY p_codigo TO cod_familia
         END IF

      WHEN INFIELD(cod_roteiro)
         LET p_codigo = log009_popup(8,10,"ROTEIROS","roteiro",
                        "cod_roteiro","den_roteiro","","S","") 
                        
         CALL log006_exibe_teclas("01",p_versao)
         CURRENT WINDOW IS w_pol0607
         
         IF p_codigo IS NOT NULL THEN
           LET p_par_item_885.cod_roteiro = p_codigo
           DISPLAY p_codigo TO cod_roteiro
         END IF

   END CASE

END FUNCTION 

#-----------------------------------#
FUNCTION pol0607_escolhe_clas_fisc()
#-----------------------------------#

   DEFINE pr_clas_fisc      ARRAY[2000] OF RECORD
          cod_cla_fisc      LIKE clas_fiscal.cod_cla_fisc,
          pct_ipi           LIKE clas_fiscal.pct_ipi,
          cod_unid_med_fisc LIKE clas_fiscal.cod_unid_med_fisc,
          ies_tributa_ipi   LIKE clas_fiscal.ies_tributa_ipi
   END RECORD

   INITIALIZE p_nom_tela, pr_clas_fisc TO NULL 
   CALL log130_procura_caminho("pol06071") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06071 AT 6,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET INT_FLAG = FALSE
   LET p_index = 1
   
   DECLARE cq_c_fisc CURSOR FOR
    SELECT *
      FROM clas_fiscal
    
   FOREACH cq_c_fisc INTO pr_clas_fisc[p_index].*
      LET p_index = p_index + 1
      IF p_index > 2000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou.','info')
         EXIT FOREACH
      END IF
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_clas_fisc TO sr_clas_fisc.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
   
   CLOSE   WINDOW    w_pol06071
   CURRENT WINDOW IS w_pol0607

   IF NOT INT_FLAG THEN
      LET p_par_item_885.cod_cla_fisc = pr_clas_fisc[p_index].cod_cla_fisc
      LET p_par_item_885.pct_ipi      = pr_clas_fisc[p_index].pct_ipi
      DISPLAY p_par_item_885.cod_cla_fisc TO cod_cla_fisc
      DISPLAY p_par_item_885.pct_ipi      TO pct_ipi
      LET p_zoom_clas_fisc = TRUE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0607_escolhe_linha_prod()
#-----------------------------------#

   DEFINE pr_linha          ARRAY[2000] OF RECORD
          cod_lin_prod      LIKE linha_prod.cod_lin_prod,
          cod_lin_recei     LIKE linha_prod.cod_lin_recei,
          cod_seg_merc      LIKE linha_prod.cod_seg_merc,
          cod_cla_uso       LIKE linha_prod.cod_cla_uso,
          den_estr_linprod  LIKE linha_prod.den_estr_linprod
   END RECORD

   INITIALIZE p_nom_tela, pr_linha TO NULL 
   CALL log130_procura_caminho("pol06072") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06072 AT 6,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET INT_FLAG = FALSE
   LET p_index = 1
   
   DECLARE cq_lin CURSOR FOR
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           den_estr_linprod
      FROM linha_prod
    
   FOREACH cq_lin INTO pr_linha[p_index].*
      LET p_index = p_index + 1
      IF p_index > 2000 THEN
         ERROR 'Limite de Linhas Ultrapassado !!!'
         EXIT FOREACH
      END IF
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_linha TO sr_linha.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
   
   CLOSE   WINDOW    w_pol06072
   CURRENT WINDOW IS w_pol0607

   IF NOT INT_FLAG THEN
      LET p_par_item_885.cod_lin_prod  = pr_linha[p_index].cod_lin_prod
      LET p_par_item_885.cod_lin_recei = pr_linha[p_index].cod_lin_recei
      LET p_par_item_885.cod_seg_merc  = pr_linha[p_index].cod_seg_merc
      LET p_par_item_885.cod_cla_uso   = pr_linha[p_index].cod_cla_uso
      DISPLAY p_par_item_885.cod_lin_prod        TO cod_lin_prod
      DISPLAY p_par_item_885.cod_lin_recei       TO cod_lin_recei
      DISPLAY p_par_item_885.cod_seg_merc        TO cod_seg_merc
      DISPLAY p_par_item_885.cod_cla_uso         TO cod_cla_uso
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0607_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_item_885a.* = p_par_item_885.*

   CONSTRUCT BY NAME where_clause ON
      par_item_885.cod_clas_item

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_par_item_885.* = p_par_item_885a.*
      CALL pol0607_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_clas_item ",
                  "  FROM par_item_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_clas_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","par_item_885")            
      LET p_ies_cons = FALSE
      RETURN
   END IF
   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_clas_item

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0607_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0607_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_par_item_885.*
     FROM par_item_885
    WHERE cod_empresa  = p_cod_empresa
      AND cod_clas_item = p_cod_clas_item
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","par_item_885")            
      LET p_ies_cons = FALSE
      RETURN
   END IF

   CLEAR FORM
   DISPLAY BY NAME p_par_item_885.*
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0607_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_clas_itema = p_cod_clas_item
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao INTO p_cod_clas_item
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_cod_clas_item
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_cod_clas_item = p_cod_clas_itema
            EXIT WHILE
         END IF
         
         SELECT cod_empresa
           FROM par_item_885
          WHERE cod_empresa   = p_cod_empresa
            AND cod_clas_item = p_cod_clas_item

         IF STATUS = 0 THEN
            CALL pol0607_exibe_dados()
            EXIT WHILE
         END IF
            
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0607_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT cod_empresa
     FROM par_item_885  
    WHERE cod_empresa  = p_cod_empresa
      AND cod_clas_item = p_cod_clas_item
   FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_item_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0607_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0607_cursor_for_update() THEN
      LET p_cod_clas_itema = p_cod_clas_item

      IF pol0607_entrada_dados("M") THEN

         UPDATE par_item_885 
            SET par_item_885.* = p_par_item_885.*
          WHERE cod_empresa  = p_cod_empresa
            AND cod_clas_item = p_cod_clas_item

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","par_item_885")
         END IF

      ELSE
         LET p_cod_clas_item = p_cod_clas_itema
         CALL pol0607_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0607_exclusao()
#--------------------------#

   LET p_retorno = FALSE

   IF pol0607_cursor_for_update() THEN

      IF log004_confirm(18,35) THEN
 
         DELETE FROM par_item_885
          WHERE cod_empresa  = p_cod_empresa
            AND cod_clas_item = p_cod_clas_item
 
         IF STATUS = 0 THEN
            INITIALIZE p_par_item_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_item_885")
         END IF
      END IF
 
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  



#-------------------------------- FIM DE PROGRAMA -----------------------------#
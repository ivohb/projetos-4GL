#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE QUALIDADE                                   #
# PROGRAMA: pol0493                                                 #
# MODULOS.: pol0493 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ANALISES REALIZADAS  - COMIL                            #
# AUTOR...: LOGOCENTER ABC - IVO                                    #
# DATA....: 06/11/2006                                              #
# ALTERADO: 21/12/2007 por Ana Paula - versao 14                    #
#						19/05/2009 Thiago - retirar o insert da tabela 					#
#						audit_laudo_comil 				
#           12/03/10(Ivo) inserir na tabela audit_laudo_comil				#
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_cod_local     LIKE item.cod_local_estoq,
          p_num_transac1  LIKE estoque_lote.num_transac,
          p_num_transac2  LIKE estoque_lote_ender.num_transac,
          p_qtd_saldo     LIKE estoque_lote.qtd_saldo,
          p_cod_operacao  LIKE estoque_trans.cod_operacao,
          p_val           DECIMAL(12,4),
          p_resu          DECIMAL(12,4),
          p_val_calc      DECIMAL(12,4),
          p_sit_lote      CHAR(01),
          p_val_granu     DECIMAL(12,3),
          p_msg           CHAR(500),
          p_val_conc      DECIMAL(12,3),
          p_val_atu       DECIMAL(12,3),
          p_tem_granu     SMALLINT,
          p_sinal         CHAR(02),
          p_erro_critico  SMALLINT,
          p_ind           SMALLINT,
          l_ind           SMALLINT,
          p_val_varia     DECIMAL(10,4),
          p_val_de        DECIMAL(10,4),
          p_val_ate       DECIMAL(10,4),
          p_num_seq       INTEGER,
          p_index         SMALLINT,
          s_index         SMALLINT,
          p_status        SMALLINT,
          p_tem_analises  SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sql_stmt        CHAR(300),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_tip_situacao  CHAR(01)

   DEFINE mr_analise_comil       RECORD LIKE analise_comil.*,
          mr_estoque_trans       RECORD LIKE estoque_trans.*,
          mr_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
          m_num_transac_orig     INTEGER
   
END GLOBALS
   
   DEFINE w_i             SMALLINT

   DEFINE mr_tela    RECORD 
      cod_item       LIKE analise_comil.cod_item,
      granu          CHAR(01),
      tipo_granulo   LIKE malhas_comil.tipo_granulo,
      num_lote       LIKE estoque_trans.num_lote_orig,
      tip_situacao   CHAR(01),
      dat_analise    LIKE analise_comil.dat_analise,
      hor_analise    LIKE analise_comil.hor_analise
   END RECORD 

   DEFINE mr_telat   RECORD 
      cod_item       LIKE analise_comil.cod_item,
      granu          CHAR(01),
      tipo_granulo   LIKE malhas_comil.tipo_granulo,
      num_lote       LIKE estoque_trans.num_lote_orig,
      tip_situacao   CHAR(01),
      dat_analise    LIKE analise_comil.dat_analise,
      hor_analise    LIKE analise_comil.hor_analise
   END RECORD 
   
   DEFINE ma_tela ARRAY[50] OF RECORD 
      tip_analise    LIKE analise_comil.tip_analise,
      den_analise    LIKE it_analise_comil.den_analise,
      val_de         LIKE especific_comil.val_especif_de,
      val_ate        LIKE especific_comil.val_especif_ate,
      #variacao       LIKE especific_comil.variacao,
      sinal          LIKE especific_comil.tipo_valor,
      situa_analise  LIKE analise_comil.situa_analise,
      val_analise    LIKE analise_comil.val_analise
   END RECORD 

   DEFINE ma_tela_compl ARRAY[50] OF RECORD 
          metodo        LIKE especific_comil.metodo
   END RECORD 

   DEFINE pr_gran_popup       ARRAY[100] OF RECORD
          tipo_granulo        LIKE malhas_comil.tipo_granulo
   END RECORD

   
   DEFINE pr_granu ARRAY[50] OF RECORD 
          tipo_granulo LIKE malhas_comil.tipo_granulo,
          cod_malha    LIKE anal_granu_comil.cod_malha,
          resultado    LIKE anal_granu_comil.resultado,
          min_malha    LIKE malhas_comil.min_malha,
          max_malha    LIKE malhas_comil.max_malha
   END RECORD

   DEFINE pr_reult ARRAY[200] OF RECORD 
          cod_result  LIKE result_analise741.cod_result,
          den_result  LIKE result_analise741.den_result
   END RECORD

    
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	LET p_versao = "pol0493-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0493.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0493_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0493_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0493") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0493 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0493","IN") THEN
            IF pol0493_inclusao('I') THEN
               IF pol0493_entrada_item("I") THEN
                  CALL pol0493_grava_dados()
               END IF
            END IF
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0493","CO") THEN
            IF pol0493_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0493_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0493_paginacao("ANTERIOR") 
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF mr_tela.tip_situacao = 'L' THEN
               ERROR 'LOTE JÁ ESTÁ LIBERADO !!!. - OPERAÇÃO NÃO PERMITIDA'
               CONTINUE MENU
            END IF
            IF log005_seguranca(p_user,"VDP","pol0493","MO") THEN
               CALL pol0493_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF mr_tela.tip_situacao = 'L' THEN
               ERROR 'LOTE JÁ ESTÁ LIBERADO !!!. - OPERAÇÃO NÃO PERMITIDA'
               CONTINUE MENU
            END IF
            IF log005_seguranca(p_user,"VDP","pol0493","EX") THEN
               CALL pol0493_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND KEY ("B") "liBerar" "Libera lote fora das especificações"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF mr_tela.tip_situacao = 'L' THEN
               ERROR 'LOTE JÁ ESTÁ LIBERADO !!!. - OPERAÇÃO DESNECESSÁRIA'
               CONTINUE MENU
            END IF
            IF log005_seguranca(p_user,"VDP","pol0493","EX") THEN
               IF pol0493_liberar() THEN
                  ERROR 'Operação efetuada com sucesso !!!'
               ELSE
                  ERROR 'Operação cancelada !!!'
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Granulometria" "Consulta o Resultado da Granulometria"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF mr_tela.granu <> 'S' THEN
               ERROR 'Item sem granulometria !!! - Operação Cancelada'
               CONTINUE MENU
            END IF
            IF log005_seguranca(p_user,"VDP","pol0493","EX") THEN
               CALL pol0493_exibe_granu()
            END IF
         ELSE
            ERROR "Consulte Previamente o item p/ ter acesso à Grunolometria"
         END IF 
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0493","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0493_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0493.tmp'
                     START REPORT pol0493_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0493_relat TO p_nom_arquivo
               END IF
               CALL pol0493_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0493_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0493_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0493

END FUNCTION
 
#-----------------------------------#
 FUNCTION pol0493_inclusao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao          CHAR(01),
          p_entrou_na_granu SMALLINT
          
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0493
   LET p_entrou_na_granu = FALSE
   
   IF p_funcao = 'I' THEN
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela TO NULL
      LET p_houve_erro = FALSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET mr_tela.dat_analise = TODAY
      LET mr_tela.hor_analise = CURRENT HOUR TO SECOND
   END IF
   
   LET INT_FLAG =  FALSE
   
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD cod_item 
         IF mr_tela.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_item       
         ELSE
            IF pol0493_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF   
         END IF

         CALL pol0493_busca_itens_analise()

         IF p_tem_analises = 0 THEN
            ERROR 'Não há análises associada a esse item !!!'
             NEXT FIELD cod_item
         END IF
         
         DISPLAY mr_tela.granu TO granu
   
      AFTER FIELD tipo_granulo
         IF mr_tela.tipo_granulo IS NULL THEN
            ERROR "Campo com preenchimento obrigatorio !!!"
            NEXT FIELD tipo_granulo
         END IF
   
      AFTER FIELD num_lote
         IF mr_tela.num_lote IS NULL THEN
            ERROR "Campo com preenchimento obrigatório."
            NEXT FIELD num_lote 
         END IF
                  
     AFTER FIELD tip_situacao
        
        IF mr_tela.tip_situacao = 'I' THEN
           IF NOT pol0493_lote() THEN
              ERROR p_msg
              NEXT FIELD num_lote 
           END IF
        ELSE
           IF mr_tela.tip_situacao = 'L' THEN
           ELSE
              ERROR "Valor ilegal para o campo !!!"
              NEXT FIELD tip_situacao
           END IF
        END IF   

         SELECT COUNT(cod_item)
           INTO p_count
           FROM analise_comil
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND num_lote    = mr_tela.num_lote
         
         IF p_count > 0 THEN
            ERROR "Analises já cadastradas p/ o item/lote informados !!!"
            NEXT FIELD num_lote 
         END IF
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF mr_tela.num_lote IS NULL THEN
               ERROR "Informe o número do lote!"
               NEXT FIELD num_lote 
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0493_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0493

   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0493_atualiza_granu_conc()
#-------------------------------------#

   LET p_val_granu = pol0493_calcula_resu888()
   LET p_val_conc  = pol0493_concentracao()

   FOR p_ind = 1 TO l_ind
       IF ma_tela[p_ind].tip_analise = '888888' THEN
          LET ma_tela[p_ind].val_analise = p_val_granu
          LET ma_tela[p_ind].situa_analise = 'P'
          CALL pol0493_exibe_status(p_ind)
       END IF
       IF ma_tela[p_ind].tip_analise = '999999' THEN
          LET ma_tela[p_ind].val_analise = p_val_conc
          LET ma_tela[p_ind].situa_analise = 'P'
          CALL pol0493_exibe_status(p_ind)
       END IF
   END FOR
       
END FUNCTION

#-------------------------------#
 FUNCTION pol0493_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item,
          cod_local_estoq
     INTO l_den_item,
          p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#----------------------#
FUNCTION pol0493_lote()
#----------------------#

   SELECT num_transac,
          qtd_saldo
     INTO p_num_transac1,
          p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = mr_tela.cod_item
      AND cod_local     = p_cod_local
      AND num_lote      = mr_tela.num_lote
      AND ies_situa_qtd = mr_tela.tip_situacao
      
   IF STATUS <> 0 THEN
      LET p_msg = "Lote Inexistente na Estoque_lote!!!"
      RETURN FALSE
   END IF

   SELECT num_transac
     INTO p_num_transac2
     FROM estoque_lote_ender
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item       = mr_tela.cod_item
      AND cod_local      = p_cod_local
      AND num_lote       = mr_tela.num_lote
      AND ies_situa_qtd  = mr_tela.tip_situacao

   IF STATUS <> 0 THEN
      LET p_msg = "Lote Inexistente na Estoque_lote_ender!!!"
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------# 
 FUNCTION pol0493_verifica_se_eh_tanque()
#---------------------------------------# 
   DEFINE l_ies_tanque          CHAR(1)

   DECLARE cq_tanque CURSOR FOR
    SELECT ies_tanque
      FROM especific_comil
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item

     OPEN cq_tanque 
    FETCH cq_tanque INTO l_ies_tanque

    CLOSE cq_tanque

   IF l_ies_tanque = 'S' THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#-------------------------------------#
 FUNCTION pol0493_busca_itens_analise()
#-------------------------------------#

   DEFINE p_ind SMALLINT
   
   LET p_ind = 1
   LET p_tem_analises = 0
   LET mr_tela.granu = 'N'
   LET p_tem_granu = FALSE
   
   DECLARE cq_itens CURSOR FOR
    SELECT tip_analise, 
           val_especif_de,
           val_especif_ate,
           #variacao,
           tipo_valor,
           metodo
      FROM especific_comil
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item
       
   FOREACH cq_itens INTO ma_tela[p_ind].tip_analise,
                         ma_tela[p_ind].val_de,
                         ma_tela[p_ind].val_ate,
                         #ma_tela[p_ind].variacao,
                         ma_tela[p_ind].sinal,
                         ma_tela_compl[p_ind].metodo

      IF ma_tela[p_ind].tip_analise = '888888' OR
         ma_tela[p_ind].tip_analise = '999999' THEN
         LET mr_tela.granu = 'S'
         LET p_tem_granu   = TRUE
      END IF
      
      SELECT den_analise  
        INTO ma_tela[p_ind].den_analise
        FROM it_analise_comil
       WHERE cod_empresa  = p_cod_empresa
         AND tip_analise  = ma_tela[p_ind].tip_analise

      LET p_ind = p_ind + 1
      LET p_tem_analises = p_tem_analises + 1
      
   END FOREACH

   LET pa_curr = p_ind
   
   CALL SET_COUNT(p_ind - 1)
   
   IF p_tem_analises > 0 THEN
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0493_entrada_item(p_funcao) 
#--------------------------------------#
   DEFINE p_funcao           CHAR(01),
          l_ind              SMALLINT

   IF mr_tela.granu = 'S' THEN
      CALL pol0493_granulometria(p_funcao)
      CLOSE WINDOW w_pol04931
      CURRENT WINDOW IS w_pol0493
      IF p_erro_critico THEN
         RETURN FALSE
      END IF
#      IF p_funcao = 'I' THEN
         CALL pol0493_atualiza_granu_conc()
#      END IF
   END IF

   LET INT_FLAG =  FALSE

    INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      BEFORE FIELD val_analise
         IF ma_tela[pa_curr].tip_analise = '888888' OR
            ma_tela[pa_curr].tip_analise = '999999' THEN
            LET p_val_atu = ma_tela[pa_curr].val_analise
         END IF

      AFTER FIELD val_analise
         {IF ma_tela[pa_curr].tip_analise = '888888' OR
            ma_tela[pa_curr].tip_analise = '999999' THEN
            IF ma_tela[pa_curr].val_analise <> p_val_atu THEN
               LET ma_tela[pa_curr].val_analise = p_val_atu
               LET p_msg = 
                   'O resultado dessa analise é calculado automaticamente. Favor não alterar.'
               CALL log0030_mensagem(p_msg,"exclamation")
               NEXT FIELD val_analise
            END IF
         END IF}

         IF ma_tela[pa_curr].val_analise IS NOT NULL THEN
            IF ma_tela[pa_curr].tip_analise IS NULL OR
               ma_tela[pa_curr].tip_analise = ' ' THEN
               ERROR 'Não contém Tipo de Análise para esta Linha.'
               INITIALIZE ma_tela[pa_curr].val_analise TO NULL  
               NEXT FIELD val_analise
            END IF
         END IF
         
         IF ma_tela[pa_curr].tip_analise IS NOT NULL THEN
            LET ma_tela[pa_curr].situa_analise = 'P'
            CALL pol0493_exibe_status(pa_curr)
            DISPLAY ma_tela[pa_curr].situa_analise TO s_itens[sc_curr].situa_analise
         END IF
   
      ON KEY (control-z)
         
         SELECT COUNT(tip_analise)
           INTO p_count
           FROM result_analise741
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = ma_tela[pa_curr].tip_analise
         
         IF p_count > 0 THEN
            CALL pol0493_popup()
         END IF

         DISPLAY ma_tela[pa_curr].situa_analise TO s_itens[sc_curr].situa_analise
            
      AFTER INPUT
       IF INT_FLAG = 0 THEN 
          FOR l_ind = 1 TO pa_curr
             IF ma_tela[l_ind].tip_analise IS NOT NULL THEN
                IF ma_tela[l_ind].val_analise IS NULL THEN
                   LET pa_curr = l_ind
                   ERROR 'Existem análise sem resultado !!!'
                   NEXT FIELD val_analise
                END IF  
             END IF 
          END FOR
       END IF
 

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0493
   
   IF INT_FLAG THEN
      IF p_funcao = "M" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusao Cancelada"
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE 
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol0493_calcula_resu888()
#--------------------------------#

   LET p_val_calc = 0
   
   DECLARE cq_malhas CURSOR FOR
    SELECT a.val_malha, 
           b.resultado
      FROM malhas_comil     a,
           anal_granu_comil b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.tipo_granulo= mr_tela.tipo_granulo
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_malha   = a.cod_malha
       AND b.cod_item    = mr_tela.cod_item
       AND b.num_lote    = mr_tela.num_lote

   FOREACH cq_malhas INTO p_val, p_resu
      IF p_resu IS NULL THEN
         LET p_resu = 0
      END IF

      IF p_val IS NULL THEN
         LET p_val = 0
      END IF
      
      LET p_val = p_val / 100
      LET p_val_calc = p_val_calc + p_val * p_resu
   
   END FOREACH
   
   RETURN p_val_calc
   
END FUNCTION 

#-----------------------------#
FUNCTION pol0493_concentracao()
#-----------------------------#

   DEFINE p_cod_lin_prod  LIKE item.cod_lin_prod, 
          p_cod_lin_recei LIKE item.cod_lin_recei, 
          p_cod_seg_merc  LIKE item.cod_seg_merc, 
          p_cod_cla_uso   LIKE item.cod_cla_uso

   LET p_val_calc = 0
   
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
      AND cod_item    = mr_tela.cod_item

   
   DECLARE cq_malhas_conc CURSOR FOR
    SELECT a.resultado
      FROM anal_granu_comil a,
           malha_conc_comil c
     WHERE c.cod_empresa   = p_cod_empresa
       AND c.cod_lin_prod  = p_cod_lin_prod
       AND c.cod_lin_recei = p_cod_lin_recei
       AND c.cod_seg_merc  = p_cod_seg_merc
       AND c.cod_cla_uso   = p_cod_cla_uso
       AND a.cod_empresa   = c.cod_empresa
       AND a.cod_malha     = c.cod_malha
       AND a.cod_item      = mr_tela.cod_item
       AND a.num_lote      = mr_tela.num_lote

   FOREACH cq_malhas_conc INTO p_resu
      IF p_resu IS NULL THEN
         LET p_resu = 0
      END IF

      LET p_val_calc = p_val_calc + p_resu
   
   END FOREACH
   
   RETURN p_val_calc

END FUNCTION

#-------------------------------------#
FUNCTION pol0493_exibe_status(pa_curr)
#-------------------------------------#

   DEFINE pa_curr SMALLINT
   
   IF ma_tela[pa_curr].val_de <> ma_tela[pa_curr].val_ate THEN
      IF ma_tela[pa_curr].val_analise >= ma_tela[pa_curr].val_de AND
         ma_tela[pa_curr].val_analise <= ma_tela[pa_curr].val_ate THEN
         LET ma_tela[pa_curr].situa_analise = 'L'
      END IF
   ELSE
      {IF ma_tela[pa_curr].variacao > 0 THEN
         LET p_val_varia = ma_tela[pa_curr].val_de * ma_tela[pa_curr].variacao / 100
         LET p_val_de    = ma_tela[pa_curr].val_de - p_val_varia
         LET p_val_ate   = ma_tela[pa_curr].val_ate + p_val_varia
         IF ma_tela[pa_curr].val_analise >= p_val_de AND
            ma_tela[pa_curr].val_analise <= p_val_ate THEN
            LET ma_tela[pa_curr].situa_analise = 'L'
         END IF
      ELSE}
         IF ma_tela[pa_curr].sinal IS NULL THEN
            LET p_sinal = '='
         ELSE
            LET p_sinal = ma_tela[pa_curr].sinal
         END IF
         IF p_sinal = '=' THEN
            IF ma_tela[pa_curr].val_analise = ma_tela[pa_curr].val_de THEN
               LET ma_tela[pa_curr].situa_analise = 'L'
            END IF
         ELSE
            IF p_sinal = '>' THEN
               IF ma_tela[pa_curr].val_analise > ma_tela[pa_curr].val_de THEN
                  LET ma_tela[pa_curr].situa_analise = 'L'
               END IF
            ELSE
               IF p_sinal = '<' THEN
                  IF ma_tela[pa_curr].val_analise < ma_tela[pa_curr].val_de THEN
                     LET ma_tela[pa_curr].situa_analise = 'L'
                  END IF
               ELSE
                  IF p_sinal = '>=' THEN
                     IF ma_tela[pa_curr].val_analise >= ma_tela[pa_curr].val_de THEN
                        LET ma_tela[pa_curr].situa_analise = 'L'
                     END IF
                  ELSE      
                     IF p_sinal = '<=' THEN
                        IF ma_tela[pa_curr].val_analise <= ma_tela[pa_curr].val_de THEN
                           LET ma_tela[pa_curr].situa_analise = 'L'
                        END IF
                     END IF
                  END IF
               END IF
            END IF
         END IF   
      #END IF
   END IF
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0493_grava_dados()
#-----------------------------#

   LET p_houve_erro = FALSE
   
   CALL log085_transacao("BEGIN")
   
   FOR w_i = 1 TO 50
      IF ma_tela[w_i].tip_analise IS NOT NULL AND
         ma_tela[w_i].val_analise IS NOT NULL THEN 
         WHENEVER ERROR CONTINUE
         INSERT INTO analise_comil 
         VALUES (p_cod_empresa,
                 mr_tela.cod_item, 
                 mr_tela.tipo_granulo,       
                 mr_tela.dat_analise,
                 mr_tela.hor_analise, 
                 mr_tela.num_lote,
                 ma_tela[w_i].tip_analise, 
                 ma_tela_compl[w_i].metodo,
                 ma_tela[w_i].val_analise,
                 ma_tela[w_i].situa_analise)
                                 
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","ANALISE_comil")
            CALL log085_transacao("ROLLBACK")
            EXIT FOR
         END IF
      END IF
   END FOR

   IF p_houve_erro = FALSE THEN
      IF mr_tela.tip_situacao = 'I' THEN
         CALL pol0493_movimenta_estoque('A')
      END IF
   END IF
   
   IF p_houve_erro = FALSE THEN
      CALL log085_transacao("COMMIT")
      IF LENGTH(p_msg) < 30 THEN
         DISPLAY 'L'        TO tip_situacao
      END IF
      ERROR p_msg
   ELSE
      CALL log085_transacao("ROLLBACK")
      CLEAR FORM
      ERROR "Operação Cancelada"
   END IF    
               
   LET p_ies_cons = TRUE
                  
END FUNCTION

#-------------------------#
FUNCTION pol0493_liberar()
#-------------------------#
   
   SELECT *
     FROM laudo_usu_comil
    WHERE cod_empresa = p_cod_empresa
      AND cod_usuario = p_user
   
   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Usuário sem permissão p/ essa operação","exclamation")
      RETURN FALSE
   END IF

   IF NOT pol0493_lote() THEN
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   
   CALL log085_transacao("BEGIN")
   
   IF mr_tela.tip_situacao = 'I' THEN

      CALL pol0493_movimenta_estoque('L')
      
      IF p_houve_erro = FALSE THEN
         CALL log085_transacao("COMMIT")
         DISPLAY 'L'        TO mr_tela.tip_situacao
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF    

   END IF
END FUNCTION

#---------------------------------------#
FUNCTION pol0493_movimenta_estoque(p_op)
#---------------------------------------#

   DEFINE w_i  SMALLINT,
          p_op CHAR(01)

   LET p_msg = "Operação efetuada. Porém, há item(ns) fora das espcificações"
   
   IF p_op <> 'L' THEN
      FOR w_i = 1 TO 50
          IF ma_tela[w_i].situa_analise = 'P' THEN
             RETURN 
          END IF
      END FOR
   END IF
   
   LET p_msg = "Operação Efetuada com Sucesso"
   
   LET p_houve_erro = FALSE

   IF mr_tela.tip_situacao = 'I' THEN

      UPDATE estoque_lote
         SET ies_situa_qtd = 'L'
       WHERE num_transac = p_num_transac1
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","ESTOQUE_LOTE")
         LET p_houve_erro = TRUE
         RETURN
      END IF
   
      UPDATE estoque_lote_ender
         SET ies_situa_qtd = 'L'
       WHERE num_transac = p_num_transac2
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","ESTOQUE_LOTE_ENDER")
         LET p_houve_erro = TRUE
         RETURN
      END IF
   
      UPDATE estoque
         SET qtd_liberada = qtd_liberada + p_qtd_saldo,
             qtd_impedida = qtd_impedida - p_qtd_saldo
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","ESTOQUE")
         LET p_houve_erro = TRUE
         RETURN
      END IF

      IF NOT pol0493_insere_trans() THEN
         LET p_houve_erro = TRUE
         RETURN 
      END IF

      INSERT INTO audit_laudo_comil
       VALUES(p_cod_empresa, mr_tela.cod_item, mr_tela.num_lote, p_user, TODAY) 
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","AUDIT_LAUDO_COMIL")
         LET p_houve_erro = TRUE
      END IF
   END IF

END FUNCTION


#-------------------------------#
 FUNCTION pol0493_insere_trans()
#-------------------------------#
   
   INITIALIZE mr_estoque_trans.*, p_cod_operacao TO NULL

   SELECT par_txt 
     INTO p_cod_operacao        
     FROM par_sup_pad  
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'operac_est_sup879'      

   IF sqlca.sqlcode <> 0 THEN
      LET p_cod_operacao = 0
   END IF

   LET mr_estoque_trans.cod_empresa        = p_cod_empresa
   LET mr_estoque_trans.num_transac        = 0
   LET mr_estoque_trans.cod_item           = mr_tela.cod_item
   LET mr_estoque_trans.dat_movto          = TODAY
   LET mr_estoque_trans.dat_ref_moeda_fort = TODAY
   LET mr_estoque_trans.dat_proces         = TODAY
   LET mr_estoque_trans.hor_operac         = TIME
   LET mr_estoque_trans.ies_tip_movto      = "N"
   LET mr_estoque_trans.cod_operacao       = p_cod_operacao
   LET mr_estoque_trans.num_prog           = "POL0493"
   LET mr_estoque_trans.num_docum          = NULL
   LET mr_estoque_trans.num_seq            = NULL
   LET mr_estoque_trans.cus_unit_movto_p   = 0
   LET mr_estoque_trans.cus_tot_movto_p    = 0
   LET mr_estoque_trans.cus_unit_movto_f   = 0
   LET mr_estoque_trans.cus_tot_movto_f    = 0
   LET mr_estoque_trans.num_conta          = NULL
   LET mr_estoque_trans.num_secao_requis   = NULL
   LET mr_estoque_trans.nom_usuario        = p_user
   LET mr_estoque_trans.qtd_movto          = p_qtd_saldo
   LET mr_estoque_trans.ies_sit_est_orig   = 'I'
   LET mr_estoque_trans.ies_sit_est_dest   = 'L'
   LET mr_estoque_trans.cod_local_est_orig = p_cod_local
   LET mr_estoque_trans.cod_local_est_dest = p_cod_local
   LET mr_estoque_trans.num_lote_orig      = mr_tela.num_lote
   LET mr_estoque_trans.num_lote_dest      = mr_tela.num_lote

   INSERT INTO estoque_trans VALUES (mr_estoque_trans.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","ESTOQUE_TRANS")
      RETURN FALSE
   END IF

   LET m_num_transac_orig = SQLCA.SQLERRD[2]

   IF NOT pol0493_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0493_ins_est_trans_end()
#------------------------------------#

   INITIALIZE mr_estoque_trans_end   TO NULL

   LET mr_estoque_trans_end.cod_empresa      = mr_estoque_trans.cod_empresa
   LET mr_estoque_trans_end.num_transac      = m_num_transac_orig
   LET mr_estoque_trans_end.endereco         =  " "
   LET mr_estoque_trans_end.num_volume       = 0
   LET mr_estoque_trans_end.qtd_movto        = mr_estoque_trans.qtd_movto
   LET mr_estoque_trans_end.cod_grade_1      = " "
   LET mr_estoque_trans_end.cod_grade_2      = " "
   LET mr_estoque_trans_end.cod_grade_3      = " "
   LET mr_estoque_trans_end.cod_grade_4      = " "
   LET mr_estoque_trans_end.cod_grade_5      = " "
   LET mr_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.vlr_temperatura  = 0
   LET mr_estoque_trans_end.endereco_origem  = " "
   LET mr_estoque_trans_end.num_ped_ven      = 0
   LET mr_estoque_trans_end.num_seq_ped_ven  = 0
   LET mr_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.num_peca         = " "
   LET mr_estoque_trans_end.num_serie        = " "
   LET mr_estoque_trans_end.comprimento      = 0
   LET mr_estoque_trans_end.largura          = 0
   LET mr_estoque_trans_end.altura           = 0
   LET mr_estoque_trans_end.diametro         = 0
   LET mr_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.qtd_reserv_1     = 0
   LET mr_estoque_trans_end.qtd_reserv_2     = 0
   LET mr_estoque_trans_end.qtd_reserv_3     = 0
   LET mr_estoque_trans_end.num_reserv_1     = 0
   LET mr_estoque_trans_end.num_reserv_2     = 0
   LET mr_estoque_trans_end.num_reserv_3     = 0
   LET mr_estoque_trans_end.tex_reservado    = " "
   LET mr_estoque_trans_end.cus_unit_movto_p = 0
   LET mr_estoque_trans_end.cus_unit_movto_f = 0
   LET mr_estoque_trans_end.cus_tot_movto_p  = 0
   LET mr_estoque_trans_end.cus_tot_movto_f  = 0
   LET mr_estoque_trans_end.cod_item         = mr_estoque_trans.cod_item
   LET mr_estoque_trans_end.dat_movto        = mr_estoque_trans.dat_movto
   LET mr_estoque_trans_end.cod_operacao     = mr_estoque_trans.cod_operacao
   LET mr_estoque_trans_end.ies_tip_movto    = mr_estoque_trans.ies_tip_movto
   LET mr_estoque_trans_end.num_prog         = mr_estoque_trans.num_prog

   INSERT INTO estoque_trans_end VALUES (mr_estoque_trans_end.*)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS_END")
      RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, m_num_transac_orig, p_user, TODAY,'pol0493')

  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("INSERÇÃO","estoque_auditoria")
     RETURN FALSE
  END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0493_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM COMIL","item_comil",
              "cod_item_comil","den_item_comil","POL0490","S","")
            RETURNING mr_tela.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0493
         IF mr_tela.cod_item IS NOT NULL THEN
            DISPLAY mr_tela.cod_item TO cod_item
            CALL pol0493_verifica_item() RETURNING p_status
         END IF

      WHEN INFIELD (tipo_granulo)
         LET p_codigo = pol0493_pega_granulo()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0493
         IF p_codigo IS NOT NULL THEN
            LET mr_tela.tipo_granulo = p_codigo CLIPPED
            DISPLAY mr_tela.tipo_granulo TO tipo_granulo
         END IF

      WHEN INFIELD(cod_malha)
         CALL log009_popup(8,25,"MALHAS","malhas_comil",
                     "cod_malha","","pol0495","S","")
            RETURNING pr_granu[pa_curr].cod_malha

         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol04931
         DISPLAY pr_granu[pa_curr].cod_malha TO sr_granu[sc_curr].cod_malha
         
      WHEN INFIELD(val_analise)
         LET ma_tela[pa_curr].val_analise = pol0493_result_anal()
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0493
         DISPLAY ma_tela[pa_curr].val_analise TO s_itens[sc_curr].val_analise
            
   END CASE
 
END FUNCTION

#-----------------------------#
FUNCTION pol0493_pega_granulo()
#-----------------------------#

   DEFINE p_index SMALLINT
   DEFINE s_index SMALLINT 
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04933") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04933 AT 7,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_gran_popup CURSOR FOR 
      SELECT UNIQUE tipo_granulo
        FROM malhas_comil
       ORDER BY 1
       
   LET p_index = 1
   
   FOREACH cq_gran_popup INTO pr_gran_popup[p_index].*
      LET p_index = p_index + 1
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_gran_popup TO sr_gran_popup.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol04933
   
   IF INT_FLAG = 0 THEN
      RETURN pr_gran_popup[p_index].tipo_granulo
   ELSE
      LET INT_FLAG = 0
      RETURN ''
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0493_result_anal()
#-----------------------------#

   DEFINE p_den_analise LIKE it_analise_comil.den_analise

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04932") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04932 AT 6,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   SELECT den_analise
     INTO p_den_analise
     FROM it_analise_comil
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = ma_tela[pa_curr].tip_analise
      
   DISPLAY p_den_analise TO den_analise

   LET p_index = 1
   
   DECLARE cq_result CURSOR FOR
    SELECT cod_result,
           den_result
      FROM result_analise741
     WHERE cod_empresa = p_cod_empresa
       AND tip_analise = ma_tela[pa_curr].tip_analise
     ORDER BY cod_result
     
   FOREACH cq_result INTO pr_reult[p_index].*
      LET p_index = p_index + 1
   END FOREACH

   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_reult TO sr_reult.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()

   CLOSE WINDOW w_pol04932
   
   RETURN pr_reult[p_index].cod_result

END FUNCTION

#--------------------------------#
 FUNCTION pol0493_consulta_itens()
#--------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0493
   INITIALIZE ma_tela TO NULL
   CLEAR FORM
   
   LET mr_tela.granu = 'N'
   LET p_tem_granu = FALSE
   LET l_ind = 1

   DECLARE c_item CURSOR WITH HOLD FOR
    SELECT a.tip_analise, 
           b.val_especif_de,
           b.val_especif_ate,
           #b.variacao,
           b.tipo_valor,
           a.metodo,
           a.situa_analise,
           a.val_analise
      FROM analise_comil a,
           especific_comil b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = mr_tela.cod_item
      AND a.dat_analise = mr_tela.dat_analise
      AND a.hor_analise = mr_tela.hor_analise
      AND a.num_lote    = mr_tela.num_lote
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item
      AND b.tip_analise = a.tip_analise
    ORDER BY a.tip_analise 

   FOREACH c_item INTO ma_tela[l_ind].tip_analise,
                       ma_tela[l_ind].val_de,
                       ma_tela[l_ind].val_ate,
                       #ma_tela[l_ind].variacao,
                       ma_tela[l_ind].sinal,
                       ma_tela_compl[l_ind].metodo,
                       ma_tela[l_ind].situa_analise,
                       ma_tela[l_ind].val_analise

      IF ma_tela[l_ind].tip_analise = '888888' OR
         ma_tela[l_ind].tip_analise = '999999' THEN
         LET mr_tela.granu = 'S'
         LET p_tem_granu   = TRUE
      END IF

      SELECT den_analise
        INTO ma_tela[l_ind].den_analise
        FROM it_analise_comil
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = ma_tela[l_ind].tip_analise

      LET l_ind = l_ind + 1

   END FOREACH 

   IF l_ind = 1 THEN
      RETURN FALSE
   END IF
      
   DISPLAY BY NAME mr_tela.*
   DISPLAY p_cod_empresa TO cod_empresa
   CALL pol0493_verifica_item() RETURNING p_status

   DECLARE cq_lt CURSOR FOR
    SELECT ies_situa_qtd
      FROM estoque_lote
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item
       AND num_lote    = mr_tela.num_lote
       AND cod_local   = p_cod_local

   FOREACH cq_lt INTO mr_tela.tip_situacao
   
      DISPLAY mr_tela.tip_situacao TO tip_situacao
      EXIT FOREACH
      
   END FOREACH
   
   LET pa_curr = l_ind
   
   LET l_ind = l_ind - 1
  
   CALL SET_COUNT(l_ind)

   IF l_ind > 7 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
      END DISPLAY 
   ELSE
       INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
          BEFORE INPUT
             EXIT INPUT
       END INPUT    
   END IF
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE  
      RETURN TRUE 
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION pol0493_consulta()
#--------------------------#
   
   DEFINE where_clause CHAR(300)  
   
   CLEAR FORM
   LET INT_FLAG = FALSE
   DISPLAY p_cod_empresa TO cod_empresa
 
   CONSTRUCT BY NAME where_clause ON analise_comil.cod_item,
                                     analise_comil.num_lote,
                                     analise_comil.dat_analise,
                                     analise_comil.hor_analise
                                     
   CALL log006_exibe_teclas("01",p_versao)
   
   CURRENT WINDOW IS w_pol0493
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = " SELECT unique cod_item, tipo_granulo, ",
                  "        num_lote, dat_analise, hor_analise ",
                  " FROM analise_comil ",
                  " WHERE cod_empresa = '",p_cod_empresa,"' ",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY 1, 2, 3, 4 "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao INTO 
         mr_tela.cod_item,
         mr_tela.tipo_granulo,
         mr_tela.num_lote,
         mr_tela.dat_analise,
         mr_tela.hor_analise
         
   IF SQLCA.SQLCODE = NOTFOUND THEN
      CLEAR FORM 
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF pol0493_consulta_itens() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0493_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_telat.* = mr_tela.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
																					         mr_tela.cod_item,
																					         mr_tela.tipo_granulo,
																					         mr_tela.num_lote,
																					         mr_tela.dat_analise,
																					         mr_tela.hor_analise

            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
																					         mr_tela.cod_item,
																					         mr_tela.tipo_granulo,
																					         mr_tela.num_lote,
																					         mr_tela.dat_analise,
																					         mr_tela.hor_analise
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não existem mais itens nesta Direção"
            LET mr_tela.* = mr_telat.* 
            EXIT WHILE
         END IF
         
         SELECT COUNT(cod_empresa)
           INTO p_count
           FROM analise_comil
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND num_lote    = mr_tela.num_lote
         
         IF p_count > 0 THEN
            IF pol0493_consulta_itens() THEN
               EXIT WHILE
            END IF
         END IF
         
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------#
 FUNCTION pol0493_modificacao()
#-----------------------------#
   
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0493

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE

   CALL log085_transacao("BEGIN")

   IF pol0493_entrada_item("M") THEN
      DELETE FROM analise_comil 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND num_lote    = mr_tela.num_lote
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
         CALL log003_err_sql("EXCLUSAO","ANALISE_comil")
         RETURN
      END IF
      CALL pol0493_grava_dados()
   ELSE
      ERROR "Operação Cancelada"
      CALL log085_transacao("ROLLBACK")
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION pol0493_exclusao()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0493
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")

      DELETE FROM analise_comil 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND dat_analise = mr_tela.dat_analise
         AND hor_analise = mr_tela.hor_analise
         AND num_lote = mr_tela.num_lote

      IF SQLCA.SQLCODE <> 0 THEN
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("EXCLUSAO","ANALISE_comil")
         CALL log085_transacao("ROLLBACK")
         RETURN
      END IF

      DELETE FROM anal_granu_comil 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND num_lote    = mr_tela.num_lote

      IF SQLCA.SQLCODE <> 0 THEN
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("EXCLUSAO","anal_granu_comil")
         CALL log085_transacao("ROLLBACK")
         RETURN
      END IF

      CALL log085_transacao("COMMIT")

      MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      INITIALIZE mr_tela.* TO NULL
      CLEAR FORM
   END IF
 
END FUNCTION   

#----------------------------------#
FUNCTION pol0493_granulometria(p_op)
#----------------------------------#

   DEFINE pa_ind SMALLINT,
          sc_ind SMALLINT,
          p_op   CHAR(01)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04931") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04931 AT 7,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_erro_critico = TRUE
   
   WHENEVER ERROR CONTINUE

   DROP TABLE granu_tmp;
   CREATE  TABLE granu_tmp
     (
      tipo_granulo CHAR(15),
      cod_malha    CHAR(05),
      resultado    DECIMAL(7,3),
      min_malha    DECIMAL(7,3),
      max_malha    DECIMAL(7,3)
      ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","GRANU_TMP")
      RETURN
   END IF

   DROP TABLE granu_aux;
   CREATE  TABLE granu_aux
     (
      num_seq       INTEGER,
      tipo_granulo  CHAR(15),
      cod_malha     CHAR(05),
      resultado     DECIMAL(7,3),
      min_malha     DECIMAL(7,3),
      max_malha     DECIMAL(7,3)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","GRANU_AUX")
      RETURN
   END IF

   DECLARE cq_grava_tmp CURSOR FOR
    SELECT cod_malha,
           resultado 
      FROM anal_granu_comil
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item
       AND num_lote    = mr_tela.num_lote

   FOREACH cq_grava_tmp INTO pr_granu[1].cod_malha, pr_granu[1].resultado
      SELECT min_malha,
             max_malha
        INTO pr_granu[1].min_malha,
             pr_granu[1].max_malha
        FROM malhas_comil
       WHERE cod_empresa  = p_cod_empresa
         AND tipo_granulo = mr_tela.tipo_granulo
         AND cod_malha    = pr_granu[1].cod_malha
      
      INSERT INTO granu_tmp
       VALUES(mr_tela.tipo_granulo,
              pr_granu[1].cod_malha, 
              pr_granu[1].resultado,
              pr_granu[1].min_malha,
              pr_granu[1].max_malha)
   END FOREACH
   
   DECLARE cq_granus CURSOR FOR
    SELECT tipo_granulo,
           cod_malha,
           min_malha,
           max_malha
      FROM malhas_comil
     WHERE cod_empresa  = p_cod_empresa
       AND tipo_granulo = mr_tela.tipo_granulo
       
   FOREACH cq_granus INTO pr_granu[1].tipo_granulo,
                          pr_granu[1].cod_malha,
                          pr_granu[1].min_malha,
                          pr_granu[1].max_malha

      SELECT cod_malha
        FROM granu_tmp
       WHERE cod_malha    = pr_granu[1].cod_malha
         AND tipo_granulo = pr_granu[1].tipo_granulo

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      END IF
      
      INSERT INTO granu_tmp
       VALUES(pr_granu[1].tipo_granulo,
              pr_granu[1].cod_malha,
              0,
              pr_granu[1].min_malha,
              pr_granu[1].max_malha)
       
   END FOREACH

   LET pa_ind = 0
   
   WHILE TRUE

      SELECT MAX(LENGTH(cod_malha)) 
        INTO p_count
        FROM granu_tmp
      
      IF p_count IS NULL OR p_count = 0 THEN
         EXIT WHILE
      END IF

      DECLARE cq_class CURSOR FOR
       SELECT tipo_granulo,
              cod_malha,
              resultado,
              min_malha,
              max_malha
         FROM granu_tmp
        WHERE LENGTH(cod_malha) = p_count
        ORDER BY tipo_granulo,cod_malha DESC 
        
      FOREACH cq_class INTO pr_granu[1].*
         LET pa_ind = pa_ind + 1
         INSERT INTO granu_aux
           VALUES(pa_ind,
                  pr_granu[1].tipo_granulo,
                  pr_granu[1].cod_malha,
                  pr_granu[1].resultado,
                  pr_granu[1].min_malha,
                  pr_granu[1].max_malha)
      END FOREACH

      DELETE FROM granu_tmp
       WHERE LENGTH(cod_malha) = p_count
      
   END WHILE
   
   INITIALIZE pr_granu TO NULL
   
   LET pa_ind = 1

   DECLARE cq_granu_aux CURSOR FOR
    SELECT num_seq,
           tipo_granulo,
           cod_malha,
           resultado, 
           min_malha,
           max_malha
      FROM granu_aux
     ORDER BY num_seq DESC

   FOREACH cq_granu_aux INTO 
           p_num_seq, 
           pr_granu[pa_ind].tipo_granulo,
           pr_granu[pa_ind].cod_malha,
           pr_granu[pa_ind].resultado,
           pr_granu[pa_ind].min_malha,
           pr_granu[pa_ind].max_malha
           
      LET pa_ind = pa_ind + 1
   END FOREACH
   
   LET p_ind = pa_ind - 1
   
   CALL SET_COUNT(pa_ind - 1)

   IF p_op = 'C' THEN
     RETURN
   END IF

   INPUT ARRAY pr_granu
      WITHOUT DEFAULTS FROM sr_granu.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET pa_ind = ARR_CURR()
         LET sc_ind = SCR_LINE()

      AFTER FIELD resultado
      
         IF pr_granu[pa_ind].resultado > 100 THEN
            ERROR 'Porcentagem acima do valor máximo !!!'
            NEXT FIELD resultado
         ELSE
            IF pr_granu[pa_ind].resultado < pr_granu[pa_ind].min_malha OR
               pr_granu[pa_ind].resultado > pr_granu[pa_ind].max_malha THEN
               ERROR 'Resultado nao compreende o limite minimo e maximo !!!'
               NEXT FIELD resultado
            END IF               
         END IF

      AFTER INPUT 
         IF NOT INT_FLAG THEN
            FOR l_ind = 1 TO p_ind
                IF pr_granu[l_ind].resultado IS NULL THEN
                   ERROR 'Existem resultados nulos. Por favor, preencha-os!!!'
                   NEXT FIELD resultado
                ELSE   
                   
                END IF
            END FOR
         END IF

      ON KEY (control-z)
         CALL pol0493_popup()

   END INPUT

   LET p_erro_critico = FALSE
   
   IF NOT INT_FLAG THEN
      IF NOT pol0493_grava_granu() THEN
         LET p_erro_critico = TRUE
      END IF
   END IF
   
   LET INT_FLAG = FALSE

   RETURN

END FUNCTION

#------------------------------#
FUNCTION pol0493_checa_malha()
#------------------------------#

   SELECT cod_empresa
     FROM malhas_comil
    WHERE cod_empresa  = p_cod_empresa
      AND tipo_granulo = pr_granu[pa_curr].tipo_granulo
      AND cod_malha    = pr_granu[pa_curr].cod_malha
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION 

#-------------------------------#
FUNCTION pol0493_repetiu_codigo()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = pa_curr THEN
          CONTINUE FOR
       END IF
       IF pr_granu[p_ind].cod_malha = pr_granu[pa_curr].cod_malha THEN
          RETURN TRUE
       END IF
   END FOR
   
   RETURN FALSE

END FUNCTION 

#----------------------------#
FUNCTION pol0493_grava_granu()
#----------------------------#

   DELETE FROM anal_granu_comil
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND num_lote    = mr_tela.num_lote
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELEÇÃO', 'anal_granu_comil')
      RETURN FALSE
   END IF
   
   FOR pa_curr = 1 TO ARR_COUNT()
       IF pr_granu[pa_curr].cod_malha IS NULL THEN
          CONTINUE FOR
       END IF
       INSERT INTO anal_granu_comil
        VALUES(p_cod_empresa,
               mr_tela.cod_item,
               mr_tela.num_lote,
               pr_granu[pa_curr].cod_malha,
               pr_granu[pa_curr].resultado)
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INCLUSÃO', 'anal_granu_comil')
          RETURN FALSE
       END IF
   END FOR

   RETURN TRUE
      
END FUNCTION

#----------------------------#
FUNCTION pol0493_exibe_granu()
#----------------------------#

   CALL pol0493_granulometria('C')
   
   DISPLAY ARRAY pr_granu TO sr_granu.*

      CLOSE WINDOW w_pol04931
      CURRENT WINDOW IS w_pol0493

END FUNCTION

#-----------------------------------#
 FUNCTION pol0493_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_listar CURSOR FOR
    SELECT * 
      FROM analise_comil
     WHERE cod_empresa = p_cod_empresa
      ORDER BY cod_item, num_lote, tip_analise, dat_analise, hor_analise

   FOREACH cq_listar INTO mr_analise_comil.*

      OUTPUT TO REPORT pol0493_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#---------------------#
 REPORT pol0493_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 085, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "pol0493                      ANÁLISES REALIZADAS",
               COLUMN 067, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT
         PRINT COLUMN 001, "     ITEM          DATA      HORA   NUM LOTE ANALISE       METODO           VALOR    STATUS"
         PRINT COLUMN 001, "--------------- ---------- -------- -------- ------- -------------------- ---------- ------"
                           
      ON EVERY ROW

         PRINT COLUMN 001, mr_analise_comil.cod_item,
               COLUMN 017, mr_analise_comil.dat_analise,
               COLUMN 028, mr_analise_comil.hor_analise,
               COLUMN 037, mr_analise_comil.num_lote,
               COLUMN 046, mr_analise_comil.tip_analise USING '######',
               COLUMN 054, mr_analise_comil.metodo,
               COLUMN 075, mr_analise_comil.val_analise USING '####&.&&&&',
               COLUMN 089, mr_analise_comil.situa_analise
        
END REPORT

#-----------------------#
 FUNCTION pol0493_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------------FIM DO PROGRAMA-----------------#
#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A PAGAR                                          #
# PROGRAMA: ESP0184                                                 #
# MODULOS.: ESP0184 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELACAO DE CHEQUES UTILIZADOS P/ PAGAMENTO DE AP'S      #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 07/03/2006                                              #
#Conversao: Thiago																									#
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa     LIKE empresa.cod_empresa,
          p_den_empresa     LIKE empresa.den_empresa,  
          p_user            LIKE usuario.nom_usuario,
          p_ies_alt_val_pag LIKE tipo_valor.ies_alt_val_pag,
          p_cod_port_cart   LIKE cheque_mestre.cod_portador,
          p_cod_port_caixa  LIKE cheque_mestre.cod_portador,
          p_cod_port_carteira LIKE cheque_mestre.cod_portador,
          p_num_cpf_cgc     LIKE cheque_mestre.num_cpf_cgc,
          p_num_seq         LIKE caixa_mestre.num_sequencia,
          p_num_seq_histor  LIKE caixa_mestre.num_sequencia,
          p_val_saldo       LIKE cheque_mestre.val_saldo,
          p_den_histor      LIKE caixa_histor.den_histor,
          p_par_data        LIKE par_che_pad.par_data,
          p_tab_cheq        SMALLINT,
          p_tab_port        SMALLINT,
          p_num_lote_novo   INTEGER,
          p_num_lote        CHAR(10),
          p_tip_portador    CHAR(01),
          p_qtd_cheques     SMALLINT,
          p_status          SMALLINT,
          p_qtd_linhas      SMALLINT,
          p_houve_erro      SMALLINT,
          p_index           SMALLINT,
          s_index           SMALLINT,
          p_ind             SMALLINT,
          comando           CHAR(80),
      #   p_versao          CHAR(17),
          p_versao          CHAR(18),
          p_ies_impressao   CHAR(001),
          g_ies_ambiente    CHAR(001),
          p_nom_arquivo     CHAR(100),
          p_arquivo         CHAR(025),
          p_caminho         CHAR(080),
          p_nom_tela        CHAR(200),
          p_nom_help        CHAR(200),
          sql_stmt          CHAR(300),
          p_r               CHAR(001),
          p_count           SMALLINT,
          p_ies_cons        SMALLINT,
          p_last_row        SMALLINT,
          p_grava           SMALLINT, 
          pa_curr           SMALLINT,
          pa_curr1          SMALLINT,
          sc_curr           SMALLINT,
          sc_curr1          SMALLINT,
          w_i               SMALLINT,
          w_a               SMALLINT

   DEFINE p_ap                 RECORD LIKE ap.*,
          p_ap_valores         RECORD LIKE ap_valores.*,
          p_che_ap_vetor_mestt RECORD LIKE che_ap_vetor_mest.*,
          p_che_ap_vetor_mest  RECORD LIKE che_ap_vetor_mest.*,
          p_che_ap_vetor_item  RECORD LIKE che_ap_vetor_item.*,
          p_cc_saldo_vetor     RECORD LIKE cc_saldo_vetor.*,
          p_caixa_mestre       RECORD LIKE caixa_mestre.*,
          p_caixa_histor       RECORD LIKE caixa_histor.*,
          p_trb_checonc        RECORD LIKE trb_checonc.*
          
   DEFINE p_cheques      RECORD
      cod_empresa        CHAR(02),
      num_cheque         CHAR(10),
      cod_banco          DECIMAL(4,0),
      cod_agencia        CHAR(07),
      num_conta          CHAR(10),
      num_cpf_cgc        CHAR(19),
      val_saldo          DECIMAL(13,2),
      tip_portador       CHAR(01),
      dat_movto          DATE
   END RECORD

   DEFINE p_portadores   RECORD
      cod_empresa        CHAR(02),
      cod_banco          DECIMAL(4,0),
      cod_agencia        CHAR(07),
      num_conta          CHAR(15),
      cod_port_carteira  DECIMAL(4,0),
      cod_port_caixa     DECIMAL(4,0),
      num_lote_remessa   DECIMAL(5,0)
   END RECORD

   DEFINE p_che_ap_vetor RECORD 
      raz_social LIKE fornecedor.raz_social           
   END RECORD 

   DEFINE p_tela RECORD 
      cod_empresa_ap LIKE che_ap_vetor_mest.cod_empresa_ap,
      num_ap         LIKE che_ap_vetor_mest.num_ap,
      val_nom_ap     LIKE ap.val_nom_ap,
      dat_pgto       LIKE che_ap_vetor_mest.dat_pgto,
      dat_cancel     LIKE che_ap_vetor_mest.dat_cancel,
      cod_fornecedor LIKE fornecedor.cod_fornecedor,
      val_tot_dinh   LIKE che_ap_vetor_mest.val_tot_dinh,
      val_tot_cheq   LIKE che_ap_vetor_mest.val_tot_cheq,
      val_total      LIKE che_ap_vetor_mest.val_total
   END RECORD 

   DEFINE p_tela1 RECORD 
      cod_fornecedor LIKE che_ap_vetor_mest.cod_fornecedor,
      raz_social     LIKE fornecedor.raz_social,
      data_de        LIKE che_ap_vetor_mest.dat_pgto, 
      data_ate       LIKE che_ap_vetor_mest.dat_pgto,
      num_ap         LIKE che_ap_vetor_mest.num_ap,
      cod_empresa_ap LIKE che_ap_vetor_mest.cod_empresa_ap,
      qtd_copias     SMALLINT
   END RECORD 

   DEFINE p_tela2 RECORD 
      num_cheque1    LIKE cheque_mestre.num_cheque
   END RECORD 

   DEFINE p_tela3 RECORD 
      num_cheque     LIKE che_ap_vetor_item.num_cheque,
      cod_banco      LIKE che_ap_vetor_item.cod_banco,
      cod_agencia    LIKE che_ap_vetor_item.cod_agencia,
      num_conta      LIKE che_ap_vetor_item.num_conta
   END RECORD 

   DEFINE t_ch_item ARRAY[2000] OF RECORD 
      cod_empresa_ch LIKE che_ap_vetor_item.cod_empresa_ch,
      num_cheque     LIKE che_ap_vetor_item.num_cheque,
      cod_banco      LIKE che_ap_vetor_item.cod_banco,
      cod_agencia    LIKE che_ap_vetor_item.cod_agencia,
      num_conta      LIKE che_ap_vetor_item.num_conta, 
      val_cheque     LIKE che_ap_vetor_item.val_cheque,
      dat_vencto     LIKE che_ap_vetor_item.dat_vencto,
      ies_devolvido  LIKE che_ap_vetor_item.ies_devolvido,
      ies_excluir    CHAR(01) 
   END RECORD 

   DEFINE t_ch_item1 ARRAY[500] OF RECORD 
      cod_empresa    LIKE che_ap_vetor_item.cod_empresa_ch,
      num_cheque     LIKE che_ap_vetor_item.num_cheque,
      cod_banco      LIKE che_ap_vetor_item.cod_banco,
      cod_agencia    LIKE che_ap_vetor_item.cod_agencia,
      num_conta      LIKE che_ap_vetor_item.num_conta, 
      val_cheque     LIKE che_ap_vetor_item.val_cheque,
      ies_devolvido  LIKE che_ap_vetor_item.ies_devolvido,
      ies_excluir    CHAR(01) 
   END RECORD 

   DEFINE p_relat RECORD
      cod_empresa_ap LIKE che_ap_vetor_mest.cod_empresa_ap,
      num_ap         LIKE che_ap_vetor_mest.num_ap, 
      dat_pgto       LIKE che_ap_vetor_mest.dat_pgto,
      dat_cancel     LIKE che_ap_vetor_mest.dat_cancel,
      cod_fornecedor LIKE che_ap_vetor_mest.cod_fornecedor,
      val_tot_cheq   LIKE che_ap_vetor_mest.val_tot_cheq,
      val_tot_dinh   LIKE che_ap_vetor_mest.val_tot_dinh,
      val_total      LIKE che_ap_vetor_mest.val_total,   
      num_cheque     LIKE che_ap_vetor_item.num_cheque, 
      cod_banco      LIKE che_ap_vetor_item.cod_banco,
      cod_agencia    LIKE che_ap_vetor_item.cod_agencia, 
      val_cheque     LIKE che_ap_vetor_item.val_cheque,
      dat_vencto     LIKE che_ap_vetor_item.dat_vencto,
      ies_devolvido  LIKE che_ap_vetor_item.ies_devolvido
   END RECORD

   DEFINE p_banco      RECORD 
          cod_banco    LIKE caixa_docto.cod_banco,
          tip_cobranca CHAR(1),
          tax_desconto DECIMAL(6,2)
   END RECORD

   DEFINE p_agencia    ARRAY[100] OF RECORD 
          cod_empresa  LIKE empresa.cod_empresa,
          cod_agencia  LIKE caixa_docto.cod_agencia,
          num_conta    LIKE caixa_docto.num_conta
   END RECORD

   DEFINE p_agencia_popup ARRAY[100] OF RECORD 
          cod_agencia     LIKE caixa_docto.cod_agencia,
          num_conta       LIKE caixa_docto.num_conta
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "ESP0184-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("esp0184.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("CAP")
   CALL log001_acessa_usuario("CAP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL esp0184_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0184_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp0184") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp0184 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET p_tab_cheq = FALSE
   LET p_tab_port = FALSE
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0184","IN") THEN
            IF esp0184_inclusao() THEN
               IF esp0184_entrada_item("INCLUSAO") THEN
                  CALL esp0184_grava_dados()
               END IF
            END IF
         END IF
      COMMAND KEY("H") "Consultar Cheque" "Consulta Cheques da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0184","CO") THEN
            IF esp0184_consulta_cheque() THEN
               IF esp0184_consulta_ap() THEN
                  NEXT OPTION "Modificar"
               END IF
            END IF
         END IF
      COMMAND KEY("C") "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0184","CO") THEN
            IF esp0184_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL esp0184_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL esp0184_paginacao("ANTERIOR") 
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0184","MO") THEN
               IF p_tela.dat_cancel IS NULL THEN
                  CALL esp0184_modificacao()
               ELSE
                  ERROR "AP X Cheques Cancelado/Baixado, nao pode ser Modificado"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0184","EX") THEN
               CALL esp0184_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND KEY("N") "caNcela" "Cancela associacao Ad X Cheque"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0184","EX") THEN
               IF p_tela.dat_cancel IS NULL THEN
                  CALL esp0184_cancel()
               ELSE
                  ERROR "AP X Cheques ja esta Cancelado"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer o Cancelamento"
         END IF 
      COMMAND "Listar" "Lista dados da Tabela"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0184","CO") THEN
            CALL esp0184_listar()
         END IF
      COMMAND "Baixar" "Processa a baixa dos cheques"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0184","MO") THEN
               IF esp0184_aceita_banco() THEN
                  CALL log085_transacao("BEGIN")
                  WHENEVER ERROR CONTINUE
                  IF esp0184_baixar() THEN
                     CALL log085_transacao("COMMIT")
                     ERROR "Baixa efetuada com sucesso !!!" ATTRIBUTE(REVERSE)
                     LET p_ies_cons = FALSE
                  ELSE
                     CALL log085_transacao("ROLBACK")
                     ERROR "Operação cancelada"
                  END IF
               ELSE
                  ERROR "Operação cancelada"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a baixa"
         END IF
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
   CLOSE WINDOW w_esp0184

END FUNCTION
 
#--------------------------#
 FUNCTION esp0184_inclusao()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0184
   INITIALIZE p_tela.* TO NULL
   INITIALIZE p_ap.* TO NULL
   INITIALIZE p_ap_valores.* TO NULL
   INITIALIZE p_che_ap_vetor_mest.* TO NULL
   INITIALIZE p_che_ap_vetor_item.* TO NULL
   INITIALIZE p_che_ap_vetor.* TO NULL
   INITIALIZE t_ch_item TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   LET p_tela.val_tot_dinh = 0
   LET p_tela.val_tot_cheq = 0 
   LET p_tela.val_total    = 0  

   LET INT_FLAG =  FALSE
   INPUT BY NAME p_tela.num_ap,  
                 p_tela.cod_empresa_ap,
                 p_tela.dat_pgto
      WITHOUT DEFAULTS  

      AFTER FIELD num_ap 
      IF p_tela.num_ap IS NULL THEN
         ERROR "O Campo Num AP nao pode ser Nulo"
         NEXT FIELD num_ap       
      END IF

      AFTER FIELD cod_empresa_ap
      IF p_tela.cod_empresa_ap IS NULL THEN
         ERROR "O Campo Cod Empresa nao pode ser Nulo"
         NEXT FIELD cod_empresa_ap
      ELSE
         SELECT den_empresa
           FROM empresa
          WHERE cod_empresa = p_tela.cod_empresa_ap
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Empresa Inexistente!!!"
            NEXT FIELD cod_empresa_ap
         END IF
      END IF

      SELECT num_ap
        FROM che_ap_vetor_mest
       WHERE cod_empresa_ap = p_tela.cod_empresa_ap
         AND num_ap = p_tela.num_ap
      IF SQLCA.SQLCODE = 0 THEN
         ERROR "AP ja relacionada com cheques"
         NEXT FIELD num_ap        
      END IF
         
      SELECT cod_fornecedor,
             val_nom_ap,
             ies_lib_pgto_cap,
             ies_lib_pgto_sup
         INTO p_tela.cod_fornecedor,
              p_tela.val_nom_ap,
              p_ap.ies_lib_pgto_cap,
              p_ap.ies_lib_pgto_sup
      FROM ap             
      WHERE cod_empresa = p_tela.cod_empresa_ap
        AND num_ap = p_tela.num_ap
        AND ies_versao_atual = "S"

      IF SQLCA.SQLCODE <> 0 THEN
         ERROR "AP não cadastrada na Empresa ",p_tela.cod_empresa_ap
         NEXT FIELD num_ap        
      END IF

      IF p_ap.ies_lib_pgto_cap = "N" THEN 
         ERROR "AP Bloqueada pelo Contas a Pagar"
         NEXT FIELD num_ap        
      END IF

      IF p_ap.ies_lib_pgto_sup = "N" THEN
         ERROR "AP Bloqueada pelo Suprimentos"
         NEXT FIELD num_ap        
      END IF

      SELECT raz_social      
        INTO p_che_ap_vetor.raz_social 
        FROM fornecedor 
       WHERE cod_fornecedor = p_tela.cod_fornecedor  
      
      DISPLAY BY NAME p_tela.cod_fornecedor,
                      p_che_ap_vetor.raz_social 
      
      DECLARE cq_ap_valores CURSOR FOR
       SELECT * 
         FROM ap_valores                     
        WHERE cod_empresa = p_tela.cod_empresa_ap
          AND num_ap = p_tela.num_ap
          AND ies_versao_atual = "S"

      FOREACH cq_ap_valores INTO p_ap_valores.*

         SELECT ies_alt_val_pag
           INTO p_ies_alt_val_pag
           FROM tipo_valor                     
          WHERE cod_empresa = p_ap_valores.cod_empresa
            AND cod_tip_val = p_ap_valores.cod_tip_val
         
         IF SQLCA.SQLCODE = 0 THEN
            IF p_ies_alt_val_pag = "+" THEN
               LET p_tela.val_nom_ap = p_tela.val_nom_ap + 
                   p_ap_valores.valor
            ELSE
               IF p_ies_alt_val_pag = "-" THEN
                  LET p_tela.val_nom_ap = p_tela.val_nom_ap - 
                      p_ap_valores.valor
               END IF
            END IF
         END IF
   
      END FOREACH

      DISPLAY BY NAME p_tela.val_nom_ap

      AFTER FIELD dat_pgto
      IF p_tela.dat_pgto IS NULL THEN
         ERROR "O Campo Data Pagto nao pode ser Nulo"
         NEXT FIELD dat_pgto      
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION esp0184_entrada_item(p_funcao) 
#--------------------------------------#

   DEFINE p_funcao CHAR(11)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0184
   IF p_funcao = 'INCLUSAO' THEN
      INITIALIZE t_ch_item TO NULL
   END IF

   LET INT_FLAG =  FALSE
   INPUT ARRAY t_ch_item WITHOUT DEFAULTS FROM s_ch_item.*

      BEFORE FIELD cod_empresa_ch 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD cod_empresa_ch 
      IF t_ch_item[pa_curr].cod_empresa_ch IS NOT NULL THEN
         
         SELECT den_empresa
           FROM empresa
          WHERE cod_empresa = t_ch_item[pa_curr].cod_empresa_ch
       
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Empresa inexistante !!!"
            NEXT FIELD cod_empresa_ch 
         END IF

         SELECT par_num 
           INTO p_cod_port_cart
           FROM par_che_pad  
          WHERE cod_empresa   = t_ch_item[pa_curr].cod_empresa_ch
            AND cod_parametro = "cod_port_carteira"      
         
         IF STATUS <> 0 OR p_cod_port_cart IS NULL THEN
            ERROR "Portador_carteira não cadastrado na tabela PAR_CHE_PAD"
            NEXT FIELD cod_empresa_ch 
         END IF

      END IF
      
      BEFORE FIELD num_cheque 
      IF t_ch_item[pa_curr].cod_empresa_ch IS NULL THEN
         ERROR "Campo com preenchimento obrigatório"
         NEXT FIELD cod_empresa_ch 
      END IF

      AFTER FIELD num_cheque 
      IF t_ch_item[pa_curr].num_cheque IS NULL THEN
         ERROR "O Campo Num Cheque nao pode ser Nulo"
         NEXT FIELD num_cheque    
      END IF

      AFTER FIELD cod_banco 
      IF t_ch_item[pa_curr].cod_banco IS NULL THEN
         ERROR "O Campo Cod Banco nao pode ser Nulo"
         NEXT FIELD cod_banco     
      END IF

      AFTER FIELD cod_agencia    
      IF t_ch_item[pa_curr].cod_agencia IS NULL THEN
         ERROR "O Campo Cod Agencia nao pode ser Nulo"
         NEXT FIELD cod_agencia   
      END IF

      AFTER FIELD num_conta      
      IF t_ch_item[pa_curr].num_conta IS NULL THEN
         ERROR "O Campo Num Conta nao pode ser Nulo"
         NEXT FIELD num_conta     
      END IF

      SELECT val_saldo
#             dat_vencto
        INTO t_ch_item[pa_curr].val_cheque
#             t_ch_item[pa_curr].dat_vencto
        FROM cheque_mestre
       WHERE cod_empresa      = t_ch_item[pa_curr].cod_empresa_ch
         AND num_cheque       = t_ch_item[pa_curr].num_cheque
         AND cod_banco        = t_ch_item[pa_curr].cod_banco
         AND cod_agencia      = t_ch_item[pa_curr].cod_agencia
         AND num_conta        = t_ch_item[pa_curr].num_conta
         AND cod_portador     = p_cod_port_cart
         AND ies_situa_cheque = "N"
         AND ies_bordero      = "2"

      IF SQLCA.sqlcode = NOTFOUND THEN
         ERROR "Cheque inexistente ou já baixado"
         NEXT FIELD num_cheque    
      END IF

      DISPLAY t_ch_item[pa_curr].val_cheque TO s_ch_item[sc_curr].val_cheque
#      DISPLAY t_ch_item[pa_curr].dat_vencto TO s_ch_item[sc_curr].dat_vencto

#      IF t_ch_item[pa_curr].dat_vencto = 0 THEN
#         ERROR "Cheque sem saldo !!!"
#         NEXT FIELD num_cheque    
#      END IF

      SELECT num_cheque
        FROM che_ap_vetor_item
       WHERE cod_empresa_ch = t_ch_item[pa_curr].cod_empresa_ch
         AND num_cheque     = t_ch_item[pa_curr].num_cheque
         AND cod_banco      = t_ch_item[pa_curr].cod_banco
         AND cod_agencia    = t_ch_item[pa_curr].cod_agencia
         AND num_conta      = t_ch_item[pa_curr].num_conta
         AND num_ap        <> p_tela.num_ap 
         AND dat_cancel IS NULL 

      IF SQLCA.SQLCODE = 0 THEN
         ERROR "Cheque ja Utilizado p/ Pagar outra AP"
         NEXT FIELD cod_empresa_ch
      END IF

      FOR w_i = 1 TO ARR_COUNT()
         IF w_i = pa_curr THEN
            CONTINUE FOR
         ELSE
            IF t_ch_item[w_i].cod_empresa_ch = t_ch_item[pa_curr].cod_empresa_ch AND
               t_ch_item[w_i].num_cheque     = t_ch_item[pa_curr].num_cheque AND
               t_ch_item[w_i].cod_banco      = t_ch_item[pa_curr].cod_banco AND
               t_ch_item[w_i].cod_agencia    = t_ch_item[pa_curr].cod_agencia AND	
               t_ch_item[w_i].num_conta      = t_ch_item[pa_curr].num_conta THEN
               ERROR "Cheque Já  Informado" 
               NEXT FIELD cod_empresa_ch
            END IF
         END IF
      END FOR

      DISPLAY t_ch_item[pa_curr].val_cheque TO s_ch_item[sc_curr].val_cheque

      BEFORE FIELD dat_vencto 
      IF t_ch_item[pa_curr].dat_vencto IS NULL THEN
         LET t_ch_item[pa_curr].dat_vencto = TODAY
      END IF
      
      AFTER FIELD dat_vencto 
      IF t_ch_item[pa_curr].dat_vencto IS NULL THEN
         ERROR "O Campo Data de Vencimento nao pode ser Nulo"
         NEXT FIELD dat_vencto
      END IF

      BEFORE FIELD ies_devolvido
      IF t_ch_item[pa_curr].ies_devolvido IS NULL THEN
         LET t_ch_item[pa_curr].ies_devolvido = "N"
      END IF

      AFTER FIELD ies_devolvido 
      IF p_funcao = "INCLUSAO" THEN
         IF t_ch_item[pa_curr].ies_devolvido <> "N" THEN
            ERROR "Na Inclusão, o campo devolvido deve ser = N"
            NEXT FIELD ies_devolvido
         END IF
      ELSE
         IF t_ch_item[pa_curr].ies_devolvido <> "N" AND 
            t_ch_item[pa_curr].ies_devolvido <> "S" THEN
            ERROR 'Informe "S" p/ devolvido e "N" p/ não devolvido'
            NEXT FIELD ies_devolvido
         END IF
      END IF

      AFTER FIELD ies_excluir 
      IF t_ch_item[pa_curr].ies_excluir IS NULL THEN 
         LET t_ch_item[pa_curr].ies_excluir = "N" 
         DISPLAY t_ch_item[pa_curr].ies_excluir TO 
                 s_ch_item[sc_curr].ies_excluir
      ELSE
         IF t_ch_item[pa_curr].ies_excluir <> "N" AND 
            p_funcao = "INCLUSAO" THEN
            ERROR "O Campo Excluir nao pode ser Diferente de N"
            NEXT FIELD ies_excluir   
         ELSE
            IF t_ch_item[pa_curr].ies_excluir <> "S" AND 
               t_ch_item[pa_curr].ies_excluir <> "N" AND  
               p_funcao = "MODIFICACAO" THEN
               ERROR "O Campo Excluir nao pode ser Diferente de S ou N"
               NEXT FIELD ies_excluir   
            END IF
         END IF
      END IF
      
      IF t_ch_item[pa_curr].ies_excluir = "S" AND
         p_funcao = "MODIFICACAO" THEN  
         DELETE FROM che_ap_vetor_item
         WHERE cod_empresa_ch = t_ch_item[pa_curr].cod_empresa_ch
           AND num_cheque     = t_ch_item[pa_curr].num_cheque
           AND cod_banco      = t_ch_item[pa_curr].cod_banco      
           AND cod_agencia    = t_ch_item[pa_curr].cod_agencia    
           AND num_conta      = t_ch_item[pa_curr].num_conta  
           AND dat_cancel IS null                           
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","CHE_AP_VETOR_ITEM")
            EXIT INPUT
         END IF
      END IF

      ON KEY (control-z)
         CALL esp0184_popup()
            RETURNING t_ch_item[pa_curr].cod_empresa_ch,
                      t_ch_item[pa_curr].num_cheque,
                      t_ch_item[pa_curr].cod_banco,
                      t_ch_item[pa_curr].cod_agencia,
                      t_ch_item[pa_curr].num_conta,
                      t_ch_item[pa_curr].val_cheque,
                      t_ch_item[pa_curr].ies_devolvido,
                      t_ch_item[pa_curr].ies_excluir
            CURRENT WINDOW IS w_esp0184
            IF t_ch_item[pa_curr].cod_empresa_ch IS NOT NULL THEN
               DISPLAY t_ch_item[pa_curr].cod_empresa_ch TO 
                       s_ch_item[sc_curr].cod_empresa_ch
               DISPLAY t_ch_item[pa_curr].num_cheque TO 
                       s_ch_item[sc_curr].num_cheque
               DISPLAY t_ch_item[pa_curr].cod_banco TO 
                       s_ch_item[sc_curr].cod_banco 
               DISPLAY t_ch_item[pa_curr].cod_agencia TO
                       s_ch_item[sc_curr].cod_agencia 
               DISPLAY t_ch_item[pa_curr].num_conta TO
                       s_ch_item[sc_curr].num_conta 
               DISPLAY t_ch_item[pa_curr].val_cheque TO
                       s_ch_item[sc_curr].val_cheque
               DISPLAY t_ch_item[pa_curr].ies_devolvido TO
                       s_ch_item[sc_curr].ies_devolvido
               DISPLAY t_ch_item[pa_curr].ies_excluir TO 
                       s_ch_item[sc_curr].ies_excluir
            END IF


   END INPUT

   IF NOT INT_FLAG THEN
      LET p_tela.val_tot_cheq = 0
      FOR w_i = 1 TO 2000
         IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
            t_ch_item[w_i].num_cheque IS NOT NULL AND   
            t_ch_item[w_i].ies_excluir = "N" THEN  
            LET p_tela.val_tot_cheq = p_tela.val_tot_cheq + 
                                      t_ch_item[w_i].val_cheque
         END IF
      END FOR
      DISPLAY BY NAME p_tela.val_tot_cheq
      INPUT BY NAME p_tela.val_tot_dinh
         WITHOUT DEFAULTS

         AFTER FIELD val_tot_dinh 
         IF p_tela.val_tot_dinh IS NULL THEN
            ERROR "O Campo Dinheiro nao pode ser Nulo"
            NEXT FIELD val_tot_dinh  
         ELSE
            LET p_tela.val_total = p_tela.val_tot_dinh + p_tela.val_tot_cheq
            DISPLAY BY NAME p_tela.val_total 
         END IF

      END INPUT
   END IF

#  IF p_tela.val_total <> p_tela.val_nom_ap THEN
#     PROMPT "Valor Total Diferente do Valor da AP - Continua(S,N): " FOR p_r
#     LET p_r = UPSHIFT(p_r)
#  ELSE
#     LET p_r = "S" 
#  END IF        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184
   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusao Cancelada"
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
   ELSE
      LET p_r = "S" 
      RETURN TRUE 
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION esp0184_grava_dados()
#-----------------------------#

   LET p_houve_erro = FALSE

{  IF p_tela.val_total <> p_tela.val_saldo_ad THEN
      PROMPT "Valor Total Diferente do Valor da AP - Continua(S,N): " FOR p_r
      LET p_r = UPSHIFT(p_r)
   ELSE
      LET p_r = "S" 
   END IF   }

   IF p_r = "S" THEN
      INSERT INTO che_ap_vetor_mest 
         VALUES (p_tela.cod_empresa_ap,
                 p_tela.num_ap,        
                 p_tela.dat_pgto,      
                 null,
                 p_tela.cod_fornecedor, 
                 p_tela.val_tot_cheq,
                 p_tela.val_tot_dinh,
                 p_tela.val_total)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","CHE_AP_VETOR_MEST")
         RETURN
      END IF

      FOR w_i = 1 TO 2000
         IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
            t_ch_item[w_i].num_cheque IS NOT NULL THEN 
            INSERT INTO che_ap_vetor_item 
               VALUES (p_tela.cod_empresa_ap,
                       p_tela.num_ap,        
                       t_ch_item[w_i].cod_empresa_ch,
                       t_ch_item[w_i].num_cheque, 
                       t_ch_item[w_i].cod_banco,
                       t_ch_item[w_i].cod_agencia,
                       t_ch_item[w_i].num_conta,     
                       t_ch_item[w_i].val_cheque,    
                       t_ch_item[w_i].ies_devolvido,
                       NULL,
                       t_ch_item[w_i].dat_vencto)
            IF SQLCA.SQLCODE <> 0 THEN 
      	       LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","CHE_AP_VETOR_ITEM")
               EXIT FOR
            END IF
         END IF
      END FOR

      IF p_houve_erro = FALSE THEN
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
   END IF
               
END FUNCTION

#-----------------------#
 FUNCTION esp0184_popup()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp01842") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp01842 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   INITIALIZE p_tela2.*,
              t_ch_item1 TO NULL
   CLEAR FORM

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela2.num_cheque1 
      WITHOUT DEFAULTS  

      AFTER FIELD num_cheque1
      IF p_tela2.num_cheque1 IS NULL THEN
         ERROR "O Campo Num Cheque nao pode ser Nulo"
         NEXT FIELD num_cheque1
      ELSE
         SELECT UNIQUE num_cheque
         FROM cheque_mestre
         WHERE num_cheque MATCHES p_tela2.num_cheque1 
         IF SQLCA.SQLCODE = 100 THEN
            ERROR "Cheque Inexistente"
            NEXT FIELD num_cheque1
         END IF
      END IF

   END INPUT

   IF INT_FLAG THEN
      INITIALIZE p_tela2.*,
                 t_ch_item1 TO NULL
      CLOSE WINDOW w_esp01842
      LET t_ch_item1[1].cod_empresa   = t_ch_item[pa_curr].cod_empresa_ch
      LET t_ch_item1[1].num_cheque    = t_ch_item[pa_curr].num_cheque
      LET t_ch_item1[1].cod_banco     = t_ch_item[pa_curr].cod_banco
      LET t_ch_item1[1].cod_agencia   = t_ch_item[pa_curr].cod_agencia
      LET t_ch_item1[1].num_conta     = t_ch_item[pa_curr].num_conta
      LET t_ch_item1[1].val_cheque    = t_ch_item[pa_curr].val_cheque
      LET t_ch_item1[1].ies_devolvido = t_ch_item[pa_curr].ies_devolvido
      LET t_ch_item1[1].ies_excluir   = t_ch_item[pa_curr].ies_excluir
      RETURN t_ch_item1[1].*
   END IF

   DECLARE c_item1 CURSOR WITH HOLD FOR
   SELECT cod_empresa,
          num_cheque,
          cod_banco,     
          cod_agencia,   
          num_conta,  
          val_saldo
   FROM cheque_mestre
   WHERE num_cheque MATCHES p_tela2.num_cheque1 

   LET w_a = 1
   FOREACH c_item1 INTO t_ch_item1[w_a].cod_empresa,
                        t_ch_item1[w_a].num_cheque,  
                        t_ch_item1[w_a].cod_banco,     
                        t_ch_item1[w_a].cod_agencia,     
                        t_ch_item1[w_a].num_conta,     
                        t_ch_item1[w_a].val_cheque

      LET t_ch_item1[w_a].ies_devolvido = "N"
      LET t_ch_item1[w_a].ies_excluir = "N"
      LET w_a = w_a + 1

   END FOREACH 

   LET w_a = w_a - 1
  
   CALL SET_COUNT(w_a)

   LET INT_FLAG = FALSE
   INPUT ARRAY t_ch_item1 WITHOUT DEFAULTS FROM s_ch_item1.*

      BEFORE FIELD cod_empresa
         LET pa_curr1 = ARR_CURR()
         LET sc_curr1 = SCR_LINE()

      AFTER FIELD cod_empresa
      IF t_ch_item1[pa_curr1].cod_empresa IS NULL THEN
         EXIT INPUT
      END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE p_tela2.*,
                 t_ch_item1 TO NULL
      CLOSE WINDOW w_esp01842
      LET t_ch_item1[1].cod_empresa   = t_ch_item[pa_curr].cod_empresa_ch
      LET t_ch_item1[1].num_cheque    = t_ch_item[pa_curr].num_cheque
      LET t_ch_item1[1].cod_banco     = t_ch_item[pa_curr].cod_banco
      LET t_ch_item1[1].cod_agencia   = t_ch_item[pa_curr].cod_agencia
      LET t_ch_item1[1].num_conta     = t_ch_item[pa_curr].num_conta
      LET t_ch_item1[1].val_cheque    = t_ch_item[pa_curr].val_cheque
      LET t_ch_item1[1].ies_devolvido = t_ch_item[pa_curr].ies_devolvido
      LET t_ch_item1[1].ies_excluir   = t_ch_item[pa_curr].ies_excluir
      RETURN t_ch_item1[1].*
   ELSE
      CLOSE WINDOW w_esp01842
      RETURN t_ch_item1[pa_curr1].*
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION esp0184_consulta_ap()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0184
   INITIALIZE p_che_ap_vetor.*, 
              t_ch_item TO NULL
   CLEAR FORM

   SELECT cod_empresa_ap,
          num_ap,
          dat_pgto,
          dat_cancel,
          cod_fornecedor,
          val_tot_cheq,
          val_tot_dinh,
          val_total
      INTO p_tela.cod_empresa_ap,
           p_tela.num_ap,        
           p_tela.dat_pgto,      
           p_tela.dat_cancel,    
           p_tela.cod_fornecedor,
           p_tela.val_tot_cheq, 
           p_tela.val_tot_dinh, 
           p_tela.val_total
   FROM che_ap_vetor_mest
   WHERE cod_empresa_ap = p_che_ap_vetor_mest.cod_empresa_ap
     AND num_ap = p_che_ap_vetor_mest.num_ap

   SELECT raz_social      
      INTO p_che_ap_vetor.raz_social 
   FROM fornecedor 
   WHERE cod_fornecedor = p_tela.cod_fornecedor  

   LET p_tela.val_nom_ap = p_tela.val_total

   DISPLAY BY NAME p_tela.*,
                   p_che_ap_vetor.raz_social 

   DECLARE c_item CURSOR WITH HOLD FOR
   SELECT cod_empresa_ch,
          num_cheque,
          cod_banco,     
          cod_agencia,   
          num_conta,  
          val_cheque,
          ies_devolvido,
          dat_vencto
   FROM che_ap_vetor_item
   WHERE cod_empresa_ap = p_che_ap_vetor_mest.cod_empresa_ap
     AND num_ap = p_che_ap_vetor_mest.num_ap
   ORDER BY cod_empresa_ch, num_cheque

   LET w_i = 1
   LET p_qtd_cheques = 0
   
   FOREACH c_item INTO t_ch_item[w_i].cod_empresa_ch,
                       t_ch_item[w_i].num_cheque,   
                       t_ch_item[w_i].cod_banco,     
                       t_ch_item[w_i].cod_agencia,     
                       t_ch_item[w_i].num_conta,     
                       t_ch_item[w_i].val_cheque,
                       t_ch_item[w_i].ies_devolvido,
                       t_ch_item[w_i].dat_vencto

      LET t_ch_item[w_i].ies_excluir = "N"
      LET w_i = w_i + 1
      LET p_qtd_cheques = p_qtd_cheques + 1

   END FOREACH 

   IF w_i = 1 THEN
      ERROR "AP nao Possui Cheques Cadastrados"
      LET p_ies_cons = TRUE  
      RETURN TRUE 
   END IF

   LET w_i = w_i - 1
  
   CALL SET_COUNT(w_i)

   IF w_i > 7 THEN 
      DISPLAY ARRAY t_ch_item TO s_ch_item.*
      END DISPLAY 
   ELSE
     INPUT ARRAY t_ch_item WITHOUT DEFAULTS FROM s_ch_item.*      
        BEFORE INPUT
           EXIT INPUT
     END INPUT
        
   END IF
   
   LET p_ies_cons = TRUE  
   
   RETURN TRUE

END FUNCTION   

#---------------------------------#
 FUNCTION esp0184_consulta_cheque()
#---------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp01843") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp01843 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_tela3.* TO NULL
   CLEAR FORM

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela3.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_cheque
      IF p_tela3.num_cheque IS NULL THEN
         ERROR "O Campo Num Cheque nao pode ser Nulo"
         NEXT FIELD num_cheque   
      END IF

      AFTER FIELD cod_banco 
      IF p_tela3.cod_banco IS NULL THEN
         ERROR "O Campo Cod Banco nao pode ser Nulo"
         NEXT FIELD cod_banco    
      END IF

      AFTER FIELD cod_agencia
      IF p_tela3.cod_agencia IS NULL THEN
         ERROR "O Campo Cod Agencia nao pode ser Nulo"
         NEXT FIELD cod_agencia  
      END IF

      AFTER FIELD num_conta     
      IF p_tela3.num_conta IS NULL THEN
         ERROR "O Campo Numero da Conta nao pode ser Nulo"
         NEXT FIELD num_conta 
      END IF

      SELECT UNIQUE cod_empresa_ap,
                    num_ap
         INTO p_che_ap_vetor_mest.cod_empresa_ap,  
              p_che_ap_vetor_mest.num_ap           
      FROM che_ap_vetor_item 
   #  WHERE cod_empresa_ch = p_cod_empresa
      WHERE num_cheque = p_tela3.num_cheque
        AND cod_banco = p_tela3.cod_banco 
        AND cod_agencia = p_tela3.cod_agencia
        AND num_conta = p_tela3.num_conta 
        AND dat_cancel IS NULL            
      IF SQLCA.SQLCODE <> 0 THEN
         ERROR "Cheque nao Cadastrado em Nenhuma AP"
         NEXT FIELD num_cheque
      END IF

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      CLOSE WINDOW w_esp01843 
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      CLOSE WINDOW w_esp01843 
      RETURN TRUE
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION esp0184_consulta()
#--------------------------#

   DEFINE where_clause CHAR(300)  
   CLEAR FORM

   LET INT_FLAG = FALSE
   CONSTRUCT BY NAME where_clause ON 
      che_ap_vetor_mest.num_ap,
      che_ap_vetor_mest.cod_empresa_ap,
      che_ap_vetor_mest.cod_fornecedor
                                     
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT * FROM che_ap_vetor_mest ",
                  "WHERE ", where_clause CLIPPED,                 
                  "ORDER BY num_ap, cod_empresa_ap "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao INTO p_che_ap_vetor_mest.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF esp0184_consulta_ap() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      ELSE
         CLEAR FORM
         ERROR "Consulta Cancelada"
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION esp0184_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_che_ap_vetor_mestt.* = p_che_ap_vetor_mest.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_che_ap_vetor_mest.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_che_ap_vetor_mest.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direcao"
            LET p_che_ap_vetor_mest.* = p_che_ap_vetor_mestt.* 
            EXIT WHILE
         END IF
        
         SELECT * INTO p_che_ap_vetor_mest.* FROM che_ap_vetor_mest
         WHERE cod_empresa_ap = p_che_ap_vetor_mest.cod_empresa_ap
           AND num_ap = p_che_ap_vetor_mest.num_ap
  
         IF SQLCA.SQLCODE = 0 THEN 
            IF esp0184_consulta_ap() THEN
               LET p_ies_cons = TRUE
               EXIT WHILE
            END IF
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------------#
FUNCTION esp0184_cheque_no_portador()
#-----------------------------------#

   FOR p_ind = 1 TO p_qtd_cheques

      IF NOT esp0184_checa_cheques() THEN
         RETURN FALSE
      END IF

   END FOR

   RETURN TRUE
   
END FUNCTION


#-----------------------------#
 FUNCTION esp0184_modificacao()
#-----------------------------#

{   IF NOT esp0184_cheque_no_portador() THEN
      ERROR 'Operação cancelada!!!'
      RETURN 
   END IF      
}
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_esp0184

   SELECT MAX(a.dat_ref)
     INTO p_cc_saldo_vetor.dat_ref
     FROM cc_saldo_vetor a, 
          cc_agente_vetor b
    WHERE a.cod_agente = b.cod_agente
      AND b.ies_cofre = "S" 

   IF p_cc_saldo_vetor.dat_ref IS NOT NULL AND
      (p_cc_saldo_vetor.dat_ref >= p_tela.dat_pgto OR
       p_cc_saldo_vetor.dat_ref >= p_tela.dat_cancel) THEN
      ERROR "Data de Pagto/Canc Menor que Data Ult Fech Cofre"
      RETURN
   END IF

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.dat_pgto
      WITHOUT DEFAULTS  

      AFTER FIELD dat_pgto
      IF p_tela.dat_pgto IS NULL THEN
         ERROR "O Campo Data Pagto nao pode ser Nulo"
         NEXT FIELD dat_pgto      
      END IF

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_esp0184
   IF INT_FLAG THEN
      ERROR "Modificacao Cancelada"
      LET p_ies_cons = FALSE
      CLEAR FORM
      RETURN
   END IF

   CALL log085_transacao("BEGIN")
      
      IF esp0184_entrada_item("MODIFICACAO") THEN
         IF p_r = "S" THEN
            DELETE FROM che_ap_vetor_item 
            WHERE cod_empresa_ap = p_tela.cod_empresa_ap
              AND num_ap = p_tela.num_ap
            IF SQLCA.SQLCODE <> 0 THEN 
               CALL log085_transacao("ROLLBACK")
               CALL log003_err_sql("EXCLUSAO","CHE_AP_VETOR_ITEM")
               RETURN
            END IF
            FOR w_i = 1 TO 2000
               IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
                  t_ch_item[w_i].num_cheque IS NOT NULL AND  
                  t_ch_item[w_i].ies_excluir <> "S" THEN
                  INSERT INTO che_ap_vetor_item 
                     VALUES (p_tela.cod_empresa_ap,
                             p_tela.num_ap,        
                             t_ch_item[w_i].cod_empresa_ch,
                             t_ch_item[w_i].num_cheque, 
                             t_ch_item[w_i].cod_banco,
                             t_ch_item[w_i].cod_agencia,
                             t_ch_item[w_i].num_conta,     
                             t_ch_item[w_i].val_cheque,    
                             t_ch_item[w_i].ies_devolvido, 
                             NULL,
                             t_ch_item[w_i].dat_vencto)
                  IF SQLCA.SQLCODE <> 0 THEN 
      	             LET p_houve_erro = TRUE
                     CALL log003_err_sql("INCLUSAO","CHE_AP_VETOR_ITEM")
                     EXIT FOR
                  END IF
               END IF
            END FOR
         ELSE	
            CALL log085_transacao("ROLLBACK")
            CLEAR FORM
            RETURN
         END IF
         IF p_houve_erro THEN
            CALL log085_transacao("ROLLBACK")
            RETURN
         ELSE	
            UPDATE che_ap_vetor_mest
               SET dat_pgto     = p_tela.dat_pgto,     
                   val_tot_dinh = p_tela.val_tot_dinh,  
                   val_tot_cheq = p_tela.val_tot_cheq,  
                   val_total    = p_tela.val_total      
            WHERE cod_empresa_ap = p_tela.cod_empresa_ap
              AND num_ap = p_tela.num_ap 
            IF SQLCA.SQLCODE <> 0 THEN 
               CALL log085_transacao("ROLLBACK")
	       CALL log003_err_sql("ALTERACAO","CHE_AP_VETOR_MEST")
               RETURN
            ELSE
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificacao Efetuada com Sucesso" 
                  ATTRIBUTE(REVERSE)
            END IF
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         ERROR "Modificacao Cancelada"
         LET p_ies_cons = FALSE
         CLEAR FORM
      END IF

END FUNCTION   

#------------------------#
 FUNCTION esp0184_cancel()
#------------------------#

   IF NOT esp0184_cheque_no_portador() THEN
      ERROR 'Operação cancelada!!!'
      RETURN
   END IF      

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK                   
         UPDATE che_ap_vetor_mest
            SET dat_cancel = TODAY
         WHERE cod_empresa_ap = p_tela.cod_empresa_ap
           AND num_ap = p_tela.num_ap    
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("ALTERACAO","CHE_AP_VETOR_MEST")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN
         ELSE
            FOR w_i = 1 TO p_qtd_cheques
               IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
                  t_ch_item[w_i].num_cheque IS NOT NULL AND  
                  t_ch_item[w_i].cod_banco IS NOT NULL AND  
                  t_ch_item[w_i].cod_agencia IS NOT NULL AND  
                  t_ch_item[w_i].num_conta IS NOT NULL THEN 
                  UPDATE che_ap_vetor_item
                     SET dat_cancel = TODAY
                  WHERE cod_empresa_ap = p_tela.cod_empresa_ap
                    AND num_ap = p_tela.num_ap    
                    AND cod_empresa_ch = t_ch_item[w_i].cod_empresa_ch
                    AND num_cheque     = t_ch_item[w_i].num_cheque     
                    AND cod_banco      = t_ch_item[w_i].cod_banco      
                    AND cod_agencia    = t_ch_item[w_i].cod_agencia    
                    AND num_conta      = t_ch_item[w_i].num_conta  
                  IF SQLCA.SQLCODE <> 0 THEN
                     LET p_houve_erro = TRUE 
                     EXIT FOR
                  END IF
               END IF
            END FOR
         END IF
         IF p_houve_erro THEN
            LET p_ies_cons = FALSE
            CALL log003_err_sql("ALTERACAO","CHE_AP_VETOR_ITEM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         ELSE
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            LET p_che_ap_vetor_mest.dat_cancel = TODAY
            DISPLAY BY NAME p_che_ap_vetor_mest.dat_cancel           
            LET p_ies_cons = FALSE
            MESSAGE "Cancelamento Efetuado com Sucesso" ATTRIBUTE(REVERSE)
            CLEAR FORM
         END IF
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION esp0184_exclusao()
#--------------------------#

   IF NOT esp0184_cheque_no_portador() THEN
      ERROR 'Operação cancelada!!!'
      RETURN 
   END IF      

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184

   SELECT MAX(a.dat_ref)
      INTO p_cc_saldo_vetor.dat_ref
   FROM cc_saldo_vetor a, cc_agente_vetor b
   WHERE a.cod_agente = b.cod_agente
     AND b.ies_cofre = "S" 

   IF p_cc_saldo_vetor.dat_ref IS NOT NULL AND
      (p_cc_saldo_vetor.dat_ref >= p_tela.dat_pgto OR
       p_cc_saldo_vetor.dat_ref >= p_tela.dat_cancel) THEN
      ERROR "Data de Pagto/Canc Menor que Data Ult Fech Cofre"
      RETURN
   END IF

   LET p_houve_erro = FALSE
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK                   
         DELETE FROM che_ap_vetor_mest
         WHERE cod_empresa_ap = p_tela.cod_empresa_ap
           AND num_ap = p_tela.num_ap    
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("EXCLUSAO","CHE_AP_VETOR_MEST")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN
         END IF

         FOR w_i = 1 TO p_qtd_cheques
            DELETE FROM che_ap_vetor_item
            WHERE cod_empresa_ch = t_ch_item[w_i].cod_empresa_ch
              AND num_cheque     = t_ch_item[w_i].num_cheque     
              AND cod_banco      = t_ch_item[w_i].cod_banco      
              AND cod_agencia    = t_ch_item[w_i].cod_agencia    
              AND num_conta      = t_ch_item[w_i].num_conta  
            IF SQLCA.SQLCODE <> 0 THEN
               LET p_houve_erro = TRUE 
               EXIT FOR
            END IF
         END FOR

         IF p_houve_erro THEN
            LET p_ies_cons = FALSE
            CALL log003_err_sql("EXCLUSAO","CHE_AP_VETOR_ITEM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         ELSE
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            LET p_ies_cons = FALSE
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            CLEAR FORM
         END IF
   END IF
 
END FUNCTION   

#------------------------#
 FUNCTION esp0184_listar()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp01841") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp01841 AT 12,14 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Selecionar" "Seleciona a Opcao Desejada"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0184","CO") THEN
            IF esp0184_imprime() THEN
               IF esp0184_emite_relatorio() THEN
                  IF p_ies_impressao = "S" THEN
                     MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                        ATTRIBUTE(REVERSE)
                     IF g_ies_ambiente = "W" THEN
                        LET comando = "lpdos.bat ", p_caminho CLIPPED, 
                                      " ", p_nom_arquivo
                        RUN comando
                     END IF
                  ELSE
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo, " " 
                        ATTRIBUTE(REVERSE)
                  END IF                              
                  NEXT OPTION "Fim"
               END IF 
            END IF
         END IF
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
   CLOSE WINDOW w_esp01841

END FUNCTION

#-------------------------#
 FUNCTION esp0184_imprime()
#-------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp01841
   INITIALIZE p_tela1.* TO NULL
   CLEAR FORM

   LET p_tela1.num_ap = p_tela.num_ap  
   LET p_tela1.cod_empresa_ap = p_tela.cod_empresa_ap

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela1.cod_fornecedor,  
                 p_tela1.data_de, 
                 p_tela1.data_ate, 
                 p_tela1.num_ap, 
                 p_tela1.cod_empresa_ap,
                 p_tela1.qtd_copias
      WITHOUT DEFAULTS  

      AFTER FIELD cod_fornecedor 
      IF p_tela1.cod_fornecedor IS NOT NULL THEN
         SELECT UNIQUE cod_fornecedor
         FROM che_ap_vetor_mest
         WHERE cod_fornecedor = p_tela1.cod_fornecedor 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Fornecedor nao Cadastrado"
            NEXT FIELD cod_fornecedor 
         END IF
         SELECT raz_social      
            INTO p_tela1.raz_social
         FROM fornecedor 
         WHERE cod_fornecedor = p_tela1.cod_fornecedor  
         DISPLAY BY NAME p_tela1.raz_social 
      ELSE
         DISPLAY " " TO raz_social 
      END IF

      AFTER FIELD data_ate
      IF p_tela1.data_de IS NOT NULL AND   
         p_tela1.data_ate < p_tela1.data_de THEN
         ERROR "O Campo Data Final nao pode ser Menor que Data Inicial"
         NEXT FIELD data_de      
      ELSE
         IF p_tela1.data_de IS NULL AND   
            p_tela1.data_ate IS NOT NULL THEN
            ERROR "Informar Previamente a Data Inicial"
            NEXT FIELD data_de      
         ELSE
            IF p_tela1.data_de IS NOT NULL AND   
               p_tela1.data_ate IS NULL THEN
               ERROR "O Campo Data Final nao pode ser Nulo"
               NEXT FIELD data_ate      
            END IF
         END IF
      END IF

      AFTER FIELD cod_empresa_ap 
      IF p_tela1.cod_empresa_ap IS NOT NULL AND
         p_tela1.num_ap IS NULL THEN 
         ERROR "Informar Previamente o Numero da AP"
         NEXT FIELD num_ap        
      ELSE
         IF p_tela1.num_ap IS NOT NULL AND
            p_tela1.cod_empresa_ap IS NULL THEN 
            ERROR "O Campo Codigo da Empresa nao pode ser Nulo"
            NEXT FIELD cod_empresa_ap        
         ELSE
            IF p_tela1.num_ap IS NOT NULL AND
               p_tela1.cod_empresa_ap IS NOT NULL THEN 
               SELECT * 
               FROM che_ap_vetor_mest
               WHERE cod_empresa_ap = p_tela1.cod_empresa_ap
                 AND num_ap = p_tela1.num_ap
               IF SQLCA.SQLCODE <> 0 THEN
                  ERROR "AP nao Cadastrada"
                  NEXT FIELD num_ap        
               END IF
            END IF
         END IF
      END IF

      BEFORE FIELD qtd_copias
      LET p_tela1.qtd_copias = 1

      AFTER FIELD qtd_copias
      IF p_tela1.qtd_copias IS NULL THEN 
         LET p_tela1.qtd_copias = 1
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp01841
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Selecao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION esp0184_emite_relatorio()
#---------------------------------#

   INITIALIZE p_che_ap_vetor_mest.*,
              p_che_ap_vetor_item.*,
              p_relat.* TO NULL

   IF log028_saida_relat(21,42) IS NOT NULL THEN 
      MESSAGE " Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT esp0184_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ("LST") RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, "esp0184.tmp" 
            START REPORT esp0184_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT esp0184_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE  
   END IF

   LET p_count = 0
   
   SELECT den_empresa
      INTO p_den_empresa
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   IF p_tela1.cod_fornecedor IS NOT NULL AND
      p_tela1.data_de IS NULL AND
      p_tela1.data_ate IS NULL AND
      p_tela1.num_ap IS NULL AND
      p_tela1.cod_empresa_ap IS NULL THEN 
      LET sql_stmt = "SELECT * FROM che_ap_vetor_mest ",
                     "WHERE cod_fornecedor = '", p_tela1.cod_fornecedor, "' ",
                     "ORDER BY cod_fornecedor, dat_pgto, num_ap "
   ELSE
      IF p_tela1.cod_fornecedor IS NULL AND
         p_tela1.data_de IS NOT NULL AND
         p_tela1.data_ate IS NOT NULL AND
         p_tela1.num_ap IS NULL AND
         p_tela1.cod_empresa_ap IS NULL THEN 
         LET sql_stmt = "SELECT * FROM che_ap_vetor_mest ",
                        "WHERE dat_pgto BETWEEN '", p_tela1.data_de, "' ",
                        " AND '", p_tela1.data_ate, "' ",
                        "ORDER BY cod_fornecedor, dat_pgto, num_ap "
      ELSE
         IF p_tela1.cod_fornecedor IS NULL AND
            p_tela1.data_de IS NULL AND
            p_tela1.data_ate IS NULL AND
            p_tela1.num_ap IS NOT NULL AND
            p_tela1.cod_empresa_ap IS NOT NULL THEN 
            LET sql_stmt = "SELECT * FROM che_ap_vetor_mest ",
                           "WHERE cod_empresa_ap = '", 
                           p_tela1.cod_empresa_ap, "' ",
                           " AND num_ap = '", p_tela1.num_ap, "' ",
                           "ORDER BY cod_fornecedor, dat_pgto, num_ap "
         ELSE
            IF p_tela1.cod_fornecedor IS NULL AND    
               p_tela1.data_de IS NULL AND
               p_tela1.data_ate IS NULL AND 
               p_tela1.num_ap IS NULL AND  
               p_tela1.cod_empresa_ap IS NULL THEN
               LET sql_stmt = "SELECT * FROM che_ap_vetor_mest ",
                              "ORDER BY cod_fornecedor, dat_pgto, num_ap "
            END IF
         END IF
      END IF 
   END IF 

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query

#  FOR w_i = 1 TO p_tela1.qtd_copias

   FOREACH cq_relat INTO p_che_ap_vetor_mest.*

      LET p_relat.cod_empresa_ap = p_che_ap_vetor_mest.cod_empresa_ap
      LET p_relat.num_ap = p_che_ap_vetor_mest.num_ap   
      LET p_relat.dat_pgto =  p_che_ap_vetor_mest.dat_pgto      
      LET p_relat.dat_cancel =  p_che_ap_vetor_mest.dat_cancel      
      LET p_relat.cod_fornecedor = p_che_ap_vetor_mest.cod_fornecedor
      LET p_relat.val_tot_cheq = p_che_ap_vetor_mest.val_tot_cheq  
      LET p_relat.val_tot_dinh = p_che_ap_vetor_mest.val_tot_dinh  
      LET p_relat.val_total = p_che_ap_vetor_mest.val_total

      DECLARE cq_item CURSOR FOR
      SELECT * 
      FROM che_ap_vetor_item
      WHERE cod_empresa_ap = p_che_ap_vetor_mest.cod_empresa_ap
        AND num_ap = p_che_ap_vetor_mest.num_ap
      ORDER BY dat_vencto

      FOREACH cq_item INTO p_che_ap_vetor_item.*

         LET p_relat.num_cheque = p_che_ap_vetor_item.num_cheque    
         LET p_relat.cod_banco = p_che_ap_vetor_item.cod_banco     
         LET p_relat.cod_agencia = p_che_ap_vetor_item.cod_agencia
         LET p_relat.val_cheque = p_che_ap_vetor_item.val_cheque
         LET p_relat.ies_devolvido = p_che_ap_vetor_item.ies_devolvido
         LET p_relat.dat_vencto = p_che_ap_vetor_item.dat_vencto

         OUTPUT TO REPORT esp0184_relat(p_relat.*)
         LET p_count = p_count + 1

      END FOREACH 
      INITIALIZE p_relat.* TO NULL

   END FOREACH 

#  END FOR

   IF p_count = 0 THEN
      ERROR "Nao Existem Dados para serem Listados" 
   ELSE
      ERROR "Relatorio Processado com Sucesso"
   END IF
   FINISH REPORT esp0184_relat   

   RETURN TRUE

END FUNCTION  

#----------------------------#
 REPORT esp0184_relat(p_relat)
#----------------------------# 

   DEFINE p_relat RECORD
      cod_empresa_ap   LIKE che_ap_vetor_mest.cod_empresa_ap,
      num_ap           LIKE che_ap_vetor_mest.num_ap, 
      dat_pgto         LIKE che_ap_vetor_mest.dat_pgto,
      dat_cancel       LIKE che_ap_vetor_mest.dat_cancel,
      cod_fornecedor   LIKE che_ap_vetor_mest.cod_fornecedor,
      val_tot_cheq     LIKE che_ap_vetor_mest.val_tot_cheq,
      val_tot_dinh     LIKE che_ap_vetor_mest.val_tot_dinh,
      val_total        LIKE che_ap_vetor_mest.val_total,   
      num_cheque       LIKE che_ap_vetor_item.num_cheque, 
      cod_banco        LIKE che_ap_vetor_item.cod_banco,
      cod_agencia      LIKE che_ap_vetor_item.cod_agencia, 
      val_cheque       LIKE che_ap_vetor_item.val_cheque,
      dat_vencto       LIKE che_ap_vetor_item.dat_vencto,
      ies_devolvido    LIKE che_ap_vetor_item.ies_devolvido
   END RECORD

   DEFINE p_raz_social LIKE fornecedor.raz_social

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

{
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
0        1         2         3         4         5         6         7 
{2345678901234567890123456789012345678901234567890123456789012345678901234567890
ESP0081                       RELATORIO DE CONSUMO MEDIO                 FL. ##&
PERIODO DE 99/99/999  ATE  99/99/999      EXTRAIDO EM DD/MM/YY AS HH.MM.SS HRS.
 
EM EM NUM.   COD.ITEM        QUANT.        VALOR          COD.ITEM        QUANT.        VALOR 
OR DS PEDIDO ORIGEM          ORIGEM        ORIGEM         DESTINO         DESTINO       DESTINO  
-- -- ------ --------------- ------------- ------------- --------------- ------------- -------------
XX XX XXXXXX XXXXXXXXXXXXXXX ##,##&.&&&&&& ##,###,##&.&& XXXXXXXXXXXXXXX ##,##&.&&&&&& ##,###,##&.&&
0        1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890
}

   FORMAT

      PAGE HEADER  

      #  PRINT log500_determina_cpp(132) 
      #  PRINT log500_condensado(true)

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 045, "Relacao de Cheques Para Pagamento de AP's",
               COLUMN 122, "FL.: ", PAGENO USING "#####&"
         PRINT COLUMN 001, "ESP0184", 
               COLUMN 030, "Periodo: ", p_tela1.data_de, " a ", 
                            p_tela1.data_ate,
               COLUMN 094, "EXTRAIDO EM ", TODAY, " AS ", TIME, " HRS." 
         PRINT "----------------------------------------",
               "----------------------------------------",
               "----------------------------------------",
               "------------"

      BEFORE GROUP OF p_relat.cod_fornecedor

         SKIP TO TOP OF PAGE    

         SELECT raz_social
            INTO p_raz_social
         FROM fornecedor
         WHERE cod_fornecedor = p_relat.cod_fornecedor

         PRINT COLUMN 001, "Fornecedor: ", p_relat.cod_fornecedor, 
               " - ", p_raz_social
         PRINT "----------------------------------------",
               "----------------------------------------",
               "----------------------------------------",
               "------------"    

      BEFORE GROUP OF p_relat.num_ap        

         PRINT COLUMN 001, "Num. AP.",
               COLUMN 010, p_relat.num_ap USING "#####&",
               COLUMN 019, "Empresa",
               COLUMN 027, p_relat.cod_empresa_ap,
               COLUMN 033, "Valor",
               COLUMN 039, p_relat.val_total USING "##,###,##&.&&", 
               COLUMN 053, "Pagto",
               COLUMN 060, p_relat.dat_pgto USING "dd/mm/yyyy",
               COLUMN 072, "Cancel", 
               COLUMN 080, p_relat.dat_cancel USING "dd/mm/yyyy"

      BEFORE GROUP OF p_relat.dat_vencto

         PRINT COLUMN 001, "Num. Cheque",
               COLUMN 013, "Banco",
               COLUMN 024, "Agencia",
               COLUMN 033, "Valor Ch",
               COLUMN 044, "Data Vencto",
               COLUMN 057, "Dev."  

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_cheque, 
               COLUMN 014, p_relat.cod_banco USING "###&",
               COLUMN 024, p_relat.cod_agencia,
               COLUMN 031, p_relat.val_cheque USING "###,##&.&&",
               COLUMN 044, p_relat.dat_vencto USING "dd/mm/yyyy",
               COLUMN 058, p_relat.ies_devolvido

      AFTER GROUP OF p_relat.dat_vencto    

         SKIP  1 LINE
         PRINT COLUMN 001, "SUB-TOTAL: ", 
               COLUMN 014, "CHEQUE: ", GROUP SUM(p_relat.val_cheque)
                                       USING "####,###,###,##&.&&"
         PRINT "----------------------------------------",
               "----------------------------------------",
               "----------------------------------------",
               "------------"

      AFTER GROUP OF p_relat.num_ap        

         SKIP  1 LINE
         PRINT COLUMN 001, "TOTAL: ", 
               COLUMN 014, "CHEQUE: ", GROUP SUM(p_relat.val_cheque)
                                       USING "####,###,###,##&.&&",
               COLUMN 044, "DINH.: ", p_relat.val_tot_dinh 
                                      USING "####,###,###,##&.&&",
               COLUMN 073, "GERAL: ", p_relat.val_total 
         PRINT "----------------------------------------",
               "----------------------------------------",
               "----------------------------------------",
               "------------"

         IF p_last_row THEN
         #  PRINT log500_condensado(false);
         END IF

      ON LAST ROW

         LET p_last_row = TRUE 

      PAGE TRAILER

         PRINT COLUMN 001, "+---------------------------------------", 
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------+"

END REPORT

#------------------------------#
FUNCTION esp0184_aceita_banco()
#------------------------------#

   IF p_tela.dat_cancel IS NOT NULL THEN
     MESSAGE "Operação não permitida p/ relacionamento cancelado. "
        ATTRIBUTE(REVERSE)
     RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   
   IF p_tab_cheq THEN
      DELETE FROM che_baixar_vetor
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELEÇÃO","che_baixar_vetor")
         RETURN FALSE
      END IF
   ELSE
      CREATE TEMP TABLE che_baixar_vetor
      (
      cod_empresa        CHAR(02),
      num_cheque         CHAR(10),
      cod_banco          DECIMAL(4,0),
      cod_agencia        CHAR(07),
      num_conta          CHAR(10),
      num_cpf_cgc        CHAR(19),
      val_saldo          DECIMAL(13,2),
      tip_portador       CHAR(01),
      dat_movto          DATE
      );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","che_baixar_vetor")
         RETURN FALSE
      END IF
      LET p_tab_cheq = TRUE
   END IF
   
   LET p_count = 0
   
   FOR p_ind = 1 TO p_qtd_cheques

      INITIALIZE p_cod_port_caixa, p_par_data TO NULL
      SELECT par_num
        INTO p_cod_port_caixa
        FROM par_che_pad  
       WHERE cod_empresa   = t_ch_item[p_ind].cod_empresa_ch
         AND cod_parametro = "cod_port_caixa"      
         
      IF STATUS <> 0 OR p_cod_port_caixa IS NULL THEN
         MESSAGE "Portador_caixa não cadastrado na tab PAR_CHE_PAD ",
               t_ch_item[p_ind].cod_empresa_ch ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF

      SELECT par_data
        INTO p_par_data
        FROM par_che_pad  
       WHERE cod_empresa   = t_ch_item[p_ind].cod_empresa_ch
         AND cod_parametro = "dat_process_che"      
         
      IF STATUS <> 0 OR p_par_data IS NULL THEN
         MESSAGE "Data de processamento não cadastrado na tab PAR_CHE_PAD ",
               t_ch_item[p_ind].cod_empresa_ch ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF

      IF NOT esp0184_checa_cheques() THEN
         SLEEP 3
         CONTINUE FOR
      END IF
      
      INSERT INTO che_baixar_vetor
         VALUES(t_ch_item[p_ind].cod_empresa_ch,
                t_ch_item[p_ind].num_cheque,
                t_ch_item[p_ind].cod_banco,
                t_ch_item[p_ind].cod_agencia,
                t_ch_item[p_ind].num_conta,
                p_num_cpf_cgc,
                t_ch_item[p_ind].val_cheque,
                p_tip_portador,
                p_par_data)

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","che_baixar_vetor")
         RETURN FALSE
      END IF
      
      LET p_count = p_count + 1
      
   END FOR

   IF p_count = 0 THEN
      MESSAGE "NÃO EXISTEM CHEQUES PARA BAIXAR !!!"
      RETURN FALSE
   END IF 

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp01844") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_esp01844 AT 5,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE p_banco, p_agencia TO NULL

   INPUT BY NAME p_banco.* WITHOUT DEFAULTS  

      AFTER FIELD cod_banco
         SELECT cod_banco 
           FROM portador
          WHERE ies_tip_portador = "B"
         
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Banco inexistente !!!"
            NEXT FIELD cod_banco
         END IF
         
         NEXT FIELD tip_cobranca
         
      AFTER FIELD tip_cobranca
         IF p_banco.tip_cobranca IS NULL THEN
            ERROR "Campo c/ preenchimento obrigatório !!!"
            NEXT FIELD tip_cobranca
         END IF
         
         IF NOT (p_banco.tip_cobranca = "S" OR
                 p_banco.tip_cobranca = "C" OR
                 p_banco.tip_cobranca = "D") THEN
            ERROR "Tipo de cobranca inválido !!!"
            NEXT FIELD tip_cobranca
         END IF
         
      BEFORE FIELD tax_desconto
         IF p_banco.tip_cobranca <> "D" THEN
            LET p_banco.tax_desconto = 0
            EXIT INPUT
         END IF

      AFTER FIELD tax_desconto
         IF p_banco.tax_desconto IS NULL THEN
            ERROR "Campo com preenchimeto obrigatório !!!"
            NEXT FIELD tax_desconto
         END IF
         
      ON KEY (control-z)
         CALL esp01844_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      IF esp0184_aceita_agencia() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION 

#-------------------------------#
FUNCTION esp0184_checa_cheques()
#-------------------------------#

      INITIALIZE p_cod_port_cart TO NULL
      SELECT par_num
        INTO p_cod_port_cart
        FROM par_che_pad  
       WHERE cod_empresa   = t_ch_item[p_ind].cod_empresa_ch
         AND cod_parametro = "cod_port_carteira"      
         
      IF STATUS <> 0 OR p_cod_port_cart IS NULL THEN
         MESSAGE "Portador_carteira não cadastrado na tab PAR_CHE_PAD ",
               t_ch_item[p_ind].cod_empresa_ch ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF

      SELECT num_cpf_cgc,
             val_saldo,
             ies_tip_portador
        INTO p_num_cpf_cgc,
             p_val_saldo,
             p_tip_portador
        FROM cheque_mestre
       WHERE cod_empresa      = t_ch_item[p_ind].cod_empresa_ch
         AND num_cheque       = t_ch_item[p_ind].num_cheque
         AND cod_banco        = t_ch_item[p_ind].cod_banco
         AND cod_agencia      = t_ch_item[p_ind].cod_agencia
         AND num_conta        = t_ch_item[p_ind].num_conta
         AND cod_portador     = p_cod_port_cart
         AND ies_situa_cheque = "N"
         AND ies_bordero      = "2"

      IF SQLCA.sqlcode = NOTFOUND THEN
         MESSAGE "Cheque nº ",trim(t_ch_item[p_ind].num_cheque),
                 " não está mais no portador carteira (ch de terceiros) !!!" 
            ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF

   RETURN TRUE
      
END FUNCTION

#-------------------------------#
FUNCTION esp0184_aceita_agencia()
#-------------------------------#

   LET p_index = 1
   LET p_qtd_linhas = 0
   
   DECLARE cq_cheques CURSOR FOR
    SELECT UNIQUE cod_empresa
      FROM che_baixar_vetor
     ORDER BY 1
     
#    SELECT UNIQUE cod_empresa_ch       
#      FROM che_ap_vetor_item
#     WHERE cod_empresa_ap = p_tela.cod_empresa_ap
#       AND num_ap         = p_tela.num_ap
#     ORDER BY 1
      
   FOREACH cq_cheques INTO p_agencia[p_index].cod_empresa
      LET p_index = p_index + 1
      LET p_qtd_linhas = p_qtd_linhas + 1
   END FOREACH

   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY p_agencia WITHOUT DEFAULTS FROM s_agencia.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW     
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()     

      AFTER FIELD cod_agencia
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
            IF p_agencia[p_index+1].cod_empresa IS NULL THEN
               NEXT FIELD cod_agencia
            END IF
         END IF

         IF p_agencia[p_index].cod_agencia IS NULL THEN
            ERROR "Campo com preenchimento obrigatório!!!"
            NEXT FIELD cod_agencia
         END IF

      AFTER FIELD num_conta
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF p_agencia[p_index+1].cod_empresa IS NULL THEN
               ERROR "Não existem mais linhas nessa direção !!!"
               NEXT FIELD num_conta
            END IF
         END IF

         IF p_agencia[p_index].num_conta IS NULL THEN
            ERROR "Campo com preenchimento obrigatório!!!"
            NEXT FIELD num_conta
         END IF

         IF NOT esp0184_conta_existe() THEN
            ERROR "Conta enexistente!!!"
            NEXT FIELD cod_agencia
         END IF

      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF NOT esp0184_conta_existe() THEN
               ERROR "Conta enexistente!!!"
               NEXT FIELD cod_agencia
            END IF
            FOR p_ind = 1 TO p_qtd_linhas
                IF p_agencia[p_ind].cod_agencia IS NULL THEN
                   ERROR "Preencha a agência e conta de todas as empresas!!!"
                   NEXT FIELD cod_agencia
                END IF
                IF p_agencia[p_ind].num_conta IS NULL THEN
                   ERROR "Preencha a agência e conta de todas as empresas!!!"
                   NEXT FIELD num_conta
                END IF
            END FOR
         END IF      
      
      ON KEY (control-z)
         CALL esp01844_popup()

   END INPUT 

   CLOSE WINDOW w_esp01844
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0184

   IF INT_FLAG = 0 THEN
      IF esp0184_grava_contas() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
FUNCTION esp0184_conta_existe()
#------------------------------#

    SELECT cod_banco
      FROM cheque_banco 
     WHERE cod_empresa  = p_agencia[p_index].cod_empresa
       AND cod_banco    = p_banco.cod_banco
       AND cod_agencia  = p_agencia[p_index].cod_agencia
       AND num_conta    = p_agencia[p_index].num_conta
       AND ies_tip_cobr = p_banco.tip_cobranca
    
    IF SQLCA.sqlcode = NOTFOUND THEN
       RETURN FALSE
    ELSE
       RETURN TRUE
    END IF
    
END FUNCTION

#------------------------------#
FUNCTION esp0184_grava_contas()
#------------------------------#

   WHENEVER ERROR CONTINUE

   IF p_tab_port THEN
      DELETE FROM emp_conta_vetor
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELEÇÃO","emp_conta_vetor")
         RETURN FALSE
      END IF
   ELSE
      CREATE TEMP TABLE emp_conta_vetor
      (
      cod_empresa        CHAR(02),
      cod_banco          DECIMAL(4,0),
      cod_agencia        CHAR(07),
      num_conta          CHAR(15),
      cod_port_carteira  DECIMAL(4,0),
      cod_port_caixa     DECIMAL(4,0),
      num_lote_remessa   DECIMAL(5,0)
      );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","emp_conta_vetor")
         RETURN FALSE
      END IF
      LET p_tab_port = TRUE
   END IF
   
   FOR p_ind = 1 TO p_qtd_linhas

       SELECT par_num 
         INTO p_cod_port_carteira
         FROM par_che_pad  
        WHERE cod_empresa   = p_agencia[p_ind].cod_empresa
          AND cod_parametro = "cod_port_carteira"
       IF SQLCA.SQLCODE <> 0 THEN 
          CALL log003_err_sql("LEITURA","par_che_pad")
          RETURN FALSE
       END IF
          
       SELECT par_num 
         INTO p_cod_port_caixa
         FROM par_che_pad  
        WHERE cod_empresa   = p_agencia[p_ind].cod_empresa
          AND cod_parametro = "cod_port_caixa"
       IF SQLCA.SQLCODE <> 0 THEN 
          CALL log003_err_sql("LEITURA","par_che_pad")
          RETURN FALSE
       END IF

      INITIALIZE p_num_lote TO NULL
      
      SELECT par_num 
        INTO p_num_lote
        FROM par_che_pad  
       WHERE cod_empresa   = p_agencia[p_ind].cod_empresa
         AND cod_parametro = "num_bord_cheque"

      IF p_num_lote IS NULL THEN 
         LET p_num_lote_novo = 0
      ELSE
         LET p_num_lote_novo = p_num_lote
      END IF
      
      LET p_num_lote_novo = p_num_lote_novo + 1

       INSERT INTO emp_conta_vetor
          VALUES(p_agencia[p_ind].cod_empresa,
                 p_banco.cod_banco,
                 p_agencia[p_ind].cod_agencia,
                 p_agencia[p_ind].num_conta,
                 p_cod_port_carteira,
                 p_cod_port_caixa,
                 p_num_lote_novo)
                 
       IF SQLCA.SQLCODE <> 0 THEN 
          CALL log003_err_sql("INCLUSÃO","emp_conta_vetor")
          RETURN FALSE
       END IF

      UPDATE par_che_pad 
         SET par_num = p_num_lote_novo
       WHERE cod_empresa   = p_agencia[p_ind].cod_empresa
         AND cod_parametro = 'num_bord_cheque'

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ALTERAÇÃO","par_che_pad")
         RETURN FALSE
      END IF
       
   END FOR

   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION esp0184_baixar()
#------------------------#

   IF log004_confirm(19,41) THEN
   ELSE
      RETURN FALSE
   END IF

   MESSAGE "Processando baixa dos cheques" ATTRIBUTE(REVERSE)

   IF NOT esp0184_transf_caixa() THEN
      RETURN FALSE
   END IF

   IF NOT esp0184_transf_banco() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#------------------------------#
FUNCTION esp0184_transf_caixa()
#------------------------------#

   CALL esp0184_dados_comuns("TCCH")
   
   DECLARE cq_baixar CURSOR FOR
    SELECT a.*, b.*
      FROM che_baixar_vetor a,
           emp_conta_vetor  b
     WHERE a.cod_empresa = b.cod_empresa

   FOREACH cq_baixar INTO
           p_cheques.*,
           p_portadores.*

      LET p_caixa_mestre.cod_empresa = p_cheques.cod_empresa
      LET p_caixa_mestre.dat_movto   = p_cheques.dat_movto

      CALL esp0184_le_caixa_mestre()

      LET p_caixa_mestre.num_sequencia      = p_num_seq
      LET p_caixa_mestre.ies_situa_lanc     = p_cheques.tip_portador
      LET p_caixa_mestre.val_lancado        = p_cheques.val_saldo
      LET p_caixa_mestre.cod_portador       = p_portadores.cod_port_caixa
      LET p_caixa_mestre.ies_tip_portador   = p_cheques.tip_portador
      
      INSERT INTO caixa_mestre
         VALUES(p_caixa_mestre.*)
              
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","caixa_mestre")
         RETURN FALSE
      END IF

      LET p_caixa_histor.cod_empresa = p_caixa_mestre.cod_empresa
      LET p_caixa_histor.dat_movto   = p_caixa_mestre.dat_movto
              
      CALL esp0184_le_caixa_histor()
      
      LET p_den_histor = "CH ", trim(p_cheques.cod_banco),  "-", 
                                trim(p_cheques.cod_agencia),"-",
                                trim(p_cheques.num_conta),  "-", 
                                trim(p_cheques.num_cheque)

      LET p_caixa_histor.num_sequencia  = p_caixa_mestre.num_sequencia
      LET p_caixa_histor.num_seq_histor = p_num_seq_histor
      LET p_caixa_histor.ies_situa_lanc = p_caixa_mestre.ies_situa_lanc
      LET p_caixa_histor.val_lancado    = p_caixa_mestre.val_lancado
      LET p_caixa_histor.den_histor     = p_den_histor
      LET p_caixa_histor.dat_atualiz    = TODAY
      LET p_caixa_histor.hora           = TIME
      
      INSERT INTO caixa_histor
         VALUES(p_caixa_histor.*)
              
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","caixa_mestre")
         RETURN FALSE
      END IF

      UPDATE cheque_mestre 
         SET cod_portador = p_caixa_mestre.cod_portador, ies_tip_portador = "C" 
       WHERE cod_empresa  = p_cheques.cod_empresa
         AND num_cheque   = p_cheques.num_cheque
         AND cod_banco    = p_cheques.cod_banco
         AND cod_agencia  = p_cheques.cod_agencia
         AND num_conta    = p_cheques.num_conta
         AND num_cpf_cgc  = p_cheques.num_cpf_cgc

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ALTERAÇÃO","cheque_mestre")
         RETURN FALSE
      END IF

      UPDATE caixa_docto 
         SET cod_port_saida = 0,
             dat_entr_movto     = p_caixa_mestre.dat_movto,
             ies_tip_movto_entr = p_caixa_mestre.ies_tip_movto,
             dat_saida_movto    = NULL,
             ies_tip_port_saida = NULL
       WHERE cod_empresa  = p_cheques.cod_empresa
         AND num_cheque   = p_cheques.num_cheque
         AND cod_banco    = p_cheques.cod_banco
         AND cod_agencia  = p_cheques.cod_agencia
         AND num_conta    = p_cheques.num_conta
         AND num_cpf_cgc  = p_cheques.num_cpf_cgc

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ALTERAÇÃO","caixa_docto")
         RETURN FALSE
      END IF
              
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION esp0184_dados_comuns(p_tip_movto)
#-----------------------------------------#

   DEFINE p_tip_movto LIKE caixa_mestre.ies_tip_movto
   
   LET p_caixa_mestre.ies_tip_reg   = "D"
   LET p_caixa_mestre.ies_tip_movto = p_tip_movto
   LET p_caixa_mestre.num_lote_lanc_cont = 0
   LET p_caixa_mestre.dat_lanc_cont      = NULL

   LET p_caixa_histor.ies_tip_reg   = p_caixa_mestre.ies_tip_reg
   LET p_caixa_histor.ies_tip_movto = p_caixa_mestre.ies_tip_movto
   LET p_caixa_histor.nom_usuario   = p_user

END FUNCTION

#--------------------------------#
FUNCTION esp0184_le_caixa_mestre()
#--------------------------------#

   SELECT MAX (num_sequencia) 
     INTO p_num_seq
     FROM caixa_mestre  
    WHERE cod_empresa   = p_caixa_mestre.cod_empresa
      AND dat_movto     = p_caixa_mestre.dat_movto
      AND ies_tip_reg   = p_caixa_mestre.ies_tip_reg
      AND ies_tip_movto = p_caixa_mestre.ies_tip_movto
      
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 1
   ELSE
      LET p_num_seq = p_num_seq + 1
   END IF

END FUNCTION

#--------------------------------#
FUNCTION esp0184_le_caixa_histor()
#--------------------------------#

   SELECT MAX (num_seq_histor) 
     INTO p_num_seq_histor
     FROM caixa_histor        
    WHERE cod_empresa   = p_tela.cod_empresa_ap
      AND dat_movto     = p_caixa_histor.dat_movto
      AND ies_tip_reg   = p_caixa_histor.ies_tip_reg
      AND ies_tip_movto = p_caixa_histor.ies_tip_movto
      AND num_sequencia = p_caixa_mestre.num_sequencia
      
   IF p_num_seq_histor IS NULL THEN
      LET p_num_seq_histor = 1
   ELSE
      LET p_num_seq_histor = p_num_seq_histor + 1
   END IF

END FUNCTION

#-----------------------------#
FUNCTION esp0184_transf_banco()
#-----------------------------#

   LET p_trb_checonc.ies_tip_docum = 'CR'
   LET p_trb_checonc.num_lote_conc = 0
   LET p_trb_checonc.num_seq_conc  = 0
   LET p_trb_checonc.val_movto     = 0
   
   DECLARE cq_pri_reg CURSOR FOR
   SELECT cod_empresa,
          cod_banco,
          cod_agencia,
          num_conta,
          num_lote_remessa
     FROM emp_conta_vetor
    ORDER BY cod_empresa

   FOREACH cq_pri_reg INTO
          p_trb_checonc.cod_empresa,
          p_trb_checonc.cod_banco,
          p_trb_checonc.num_agencia,
          p_trb_checonc.num_conta,
          p_trb_checonc.num_docum

      EXIT FOREACH
   END FOREACH
   
   CALL esp0184_dados_comuns("DPCH")
   
   DECLARE cq_baixar_bco CURSOR FOR
    SELECT a.*, b.*
      FROM che_baixar_vetor a,
           emp_conta_vetor  b
     WHERE a.cod_empresa = b.cod_empresa
     ORDER BY b.cod_empresa

   FOREACH cq_baixar_bco INTO
           p_cheques.*,
           p_portadores.*

      IF p_portadores.cod_empresa <> p_trb_checonc.cod_empresa THEN
         INSERT INTO trb_checonc 
                VALUES (p_trb_checonc.*)
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INCLUSÃO","trb_checonc")
            RETURN FALSE
         END IF
         LET p_trb_checonc.cod_empresa = p_portadores.cod_empresa
         LET p_trb_checonc.cod_banco   = p_portadores.cod_banco
         LET p_trb_checonc.num_agencia = p_portadores.cod_agencia
         LET p_trb_checonc.num_conta   = p_portadores.num_conta
         LET p_trb_checonc.num_docum   = p_portadores.num_lote_remessa
         LET p_trb_checonc.val_movto   = 0
      END IF
      
      LET p_caixa_mestre.cod_empresa = p_cheques.cod_empresa
      LET p_caixa_mestre.dat_movto   = p_cheques.dat_movto
      LET p_trb_checonc.val_movto = p_trb_checonc.val_movto + p_cheques.val_saldo
      LET p_trb_checonc.dat_movto = p_cheques.dat_movto
      
      CALL esp0184_le_caixa_mestre()

      LET p_caixa_mestre.num_sequencia      = p_num_seq
      LET p_caixa_mestre.ies_situa_lanc     = "D"
      LET p_caixa_mestre.val_lancado        = p_cheques.val_saldo
      LET p_caixa_mestre.cod_portador       = p_portadores.cod_banco
      LET p_caixa_mestre.ies_tip_portador   = "B"
      
      INSERT INTO caixa_mestre
         VALUES(p_caixa_mestre.*)
              
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","caixa_mestre")
         RETURN FALSE
      END IF

      LET p_caixa_histor.cod_empresa = p_caixa_mestre.cod_empresa
      LET p_caixa_histor.dat_movto   = p_caixa_mestre.dat_movto
              
      CALL esp0184_le_caixa_histor()
      
      LET p_den_histor = "CH ", trim(p_cheques.cod_banco),"-", 
                                trim(p_cheques.cod_agencia),"-",
                                trim(p_cheques.num_conta),"-", 
                                trim(p_cheques.num_cheque),"*",
                                trim(p_cheques.num_cpf_cgc)
      LET p_caixa_histor.num_sequencia  = p_caixa_mestre.num_sequencia
      LET p_caixa_histor.num_seq_histor = p_num_seq_histor
      LET p_caixa_histor.ies_situa_lanc = p_caixa_mestre.ies_situa_lanc
      LET p_caixa_histor.val_lancado    = p_caixa_mestre.val_lancado
      LET p_caixa_histor.den_histor     = p_den_histor
      LET p_caixa_histor.dat_atualiz    = TODAY
      LET p_caixa_histor.hora           = TIME
      
      INSERT INTO caixa_histor
         VALUES(p_caixa_histor.*)
              
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","caixa_mestre")
         RETURN FALSE
      END IF

      UPDATE cheque_mestre 
         SET cod_portador     = p_caixa_mestre.cod_portador, 
             ies_tip_portador = p_caixa_mestre.ies_tip_portador,
             cod_agencia_det  = p_portadores.cod_agencia,
             num_conta_banco  = p_portadores.num_conta,
             ies_situa_cheque = "T",
             val_saldo        = 0,
             ies_bordero      = "2",
             dat_remessa      = p_caixa_mestre.dat_movto,
             num_lote_remessa = p_portadores.num_lote_remessa,
             dat_atualiz      = TODAY 
       WHERE cod_empresa  = p_cheques.cod_empresa
         AND num_cheque   = p_cheques.num_cheque
         AND cod_banco    = p_cheques.cod_banco
         AND cod_agencia  = p_cheques.cod_agencia
         AND num_conta    = p_cheques.num_conta
         AND num_cpf_cgc  = p_cheques.num_cpf_cgc

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ALTERAÇÃO","cheque_mestre")
         RETURN FALSE
      END IF

      UPDATE caixa_docto 
         SET cod_port_saida     = p_caixa_mestre.cod_portador,
             ies_tip_port_saida = p_caixa_mestre.ies_tip_portador,
             dat_saida_movto    = p_caixa_mestre.dat_movto,
             ies_tip_movto_said = p_caixa_mestre.ies_tip_movto,
             nom_usuario        = p_user 
       WHERE cod_empresa  = p_cheques.cod_empresa
         AND num_cheque   = p_cheques.num_cheque
         AND cod_banco    = p_cheques.cod_banco
         AND cod_agencia  = p_cheques.cod_agencia
         AND num_conta    = p_cheques.num_conta
         AND num_cpf_cgc  = p_cheques.num_cpf_cgc

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ALTERAÇÃO","caixa_docto")
         RETURN FALSE
      END IF

   END FOREACH

   INSERT INTO trb_checonc 
      VALUES (p_trb_checonc.*)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSÃO","trb_checonc")
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION
      
#-----------------------#
FUNCTION esp01844_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         CALL log009_popup(6,20,"BANCOS P/ DEPÓSITO","portador",
                     "cod_portador","nom_portador","","","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp01844
         IF p_codigo IS NOT NULL THEN
            LET p_banco.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF
      WHEN INFIELD(cod_agencia)
         CALL esp0184_popup_agencia(p_agencia[p_index].cod_empresa) RETURNING
              p_agencia[p_index].cod_agencia, p_agencia[p_index].num_conta
         CALL log006_exibe_teclas("01 02 03 07", p_versao)    
         CURRENT WINDOW IS w_esp01844
         DISPLAY p_agencia[p_index].cod_agencia  TO s_agencia[p_index].cod_agencia
         DISPLAY p_agencia[p_index].num_conta    TO s_agencia[p_index].num_conta
         
   END CASE

END FUNCTION

#----------------------------------------#
FUNCTION esp0184_popup_agencia(p_empresa)
#----------------------------------------#

   DEFINE p_index, s_index SMALLINT,
          p_empresa        LIKE empresa.cod_empresa

   INITIALIZE p_nom_tela, p_agencia_popup TO NULL
   CALL log130_procura_caminho("esp01845") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_esp01845 AT 7,19 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1
   
   DECLARE cq_agencia CURSOR FOR
   SELECT cod_agencia, 
          num_conta 
     FROM cheque_banco 
    WHERE cod_empresa  = p_empresa
      AND cod_banco    = p_banco.cod_banco
      AND ies_tip_cobr = p_banco.tip_cobranca
    ORDER BY 1,2

   FOREACH cq_agencia INTO p_agencia_popup[p_index].*
      LET p_index = p_index + 1
   END FOREACH

   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_agencia_popup TO s_agencia_popup.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_esp01845
   
   IF INT_FLAG = 0 THEN
      RETURN p_agencia_popup[p_index].cod_agencia, 
             p_agencia_popup[p_index].num_conta
   ELSE
      LET INT_FLAG = 0
      RETURN "",""
   END IF
   
    
END FUNCTION

#---------------------#
FUNCTION trim(p_texto)
#---------------------#
    
   DEFINE p_texto CHAR(80)
   
   RETURN p_texto CLIPPED
   
END FUNCTION


#------------------------------ FIM DE PROGRAMA -------------------------------#

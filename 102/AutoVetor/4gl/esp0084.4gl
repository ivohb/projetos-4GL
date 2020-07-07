#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A PAGAR                                          #
# PROGRAMA: ESP0084                                                 #
# MODULOS.: ESP0084 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELACAO DE CHEQUES UTILIZADOS P/ PAGAMENTO DE AD'S      #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 26/01/2004                                              #
#Conversao: Thiago																									#
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_versao        CHAR(17),
      #   p_versao        CHAR(18),
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
          w_i             SMALLINT,
          w_a             SMALLINT

   DEFINE p_ad_mestre          RECORD LIKE ad_mestre.*,
          p_che_ad_vetor_mest  RECORD LIKE che_ad_vetor_mest.*,
          p_che_ad_vetor_mestt RECORD LIKE che_ad_vetor_mest.*,
          p_che_ad_vetor_item  RECORD LIKE che_ad_vetor_item.*,
          p_cc_saldo_vetor     RECORD LIKE cc_saldo_vetor.*

   DEFINE p_che_ad_vetor RECORD 
      raz_social LIKE fornecedor.raz_social           
   END RECORD 

   DEFINE p_tela RECORD 
      num_ad         LIKE che_ad_vetor_mest.num_ad,
      cod_empresa_ad LIKE che_ad_vetor_mest.cod_empresa_ad,
      val_saldo_ad   LIKE ad_mestre.val_saldo_ad,
      dat_pgto       LIKE che_ad_vetor_mest.dat_pgto,
      dat_cancel     LIKE che_ad_vetor_mest.dat_cancel,
      cod_fornecedor LIKE fornecedor.cod_fornecedor,
      val_tot_dinh   LIKE che_ad_vetor_mest.val_tot_dinh,
      val_tot_cheq   LIKE che_ad_vetor_mest.val_tot_cheq,
      val_total      LIKE che_ad_vetor_mest.val_total    
   END RECORD 

   DEFINE p_tela1 RECORD 
      cod_fornecedor LIKE che_ad_vetor_mest.cod_fornecedor,
      raz_social     LIKE fornecedor.raz_social,
      data_de        LIKE che_ad_vetor_mest.dat_pgto, 
      data_ate       LIKE che_ad_vetor_mest.dat_pgto,
      num_ad         LIKE che_ad_vetor_mest.num_ad,
      cod_empresa_ad LIKE che_ad_vetor_mest.cod_empresa_ad,
      qtd_copias     SMALLINT
   END RECORD 

   DEFINE p_tela2 RECORD 
      num_cheque1    LIKE cheque_mestre.num_cheque
   END RECORD 

   DEFINE p_tela3 RECORD 
      num_cheque     LIKE che_ad_vetor_item.num_cheque,
      cod_banco      LIKE che_ad_vetor_item.cod_banco,
      cod_agencia    LIKE che_ad_vetor_item.cod_agencia,
      num_conta      LIKE che_ad_vetor_item.num_conta
   END RECORD 

   DEFINE t_ch_item ARRAY[500] OF RECORD 
      cod_empresa_ch LIKE che_ad_vetor_item.cod_empresa_ch,
      num_cheque     LIKE che_ad_vetor_item.num_cheque,
      cod_banco      LIKE che_ad_vetor_item.cod_banco,
      cod_agencia    LIKE che_ad_vetor_item.cod_agencia,
      num_conta      LIKE che_ad_vetor_item.num_conta, 
      val_cheque     LIKE che_ad_vetor_item.val_cheque,
      dat_vencto     LIKE che_ad_vetor_item.dat_vencto,
      ies_devolvido  LIKE che_ad_vetor_item.ies_devolvido,
      ies_excluir    CHAR(01) 
   END RECORD 

   DEFINE t_ch_item1 ARRAY[500] OF RECORD 
      cod_empresa    LIKE che_ad_vetor_item.cod_empresa_ch,
      num_cheque     LIKE che_ad_vetor_item.num_cheque,
      cod_banco      LIKE che_ad_vetor_item.cod_banco,
      cod_agencia    LIKE che_ad_vetor_item.cod_agencia,
      num_conta      LIKE che_ad_vetor_item.num_conta, 
      val_cheque     LIKE che_ad_vetor_item.val_cheque,
      ies_devolvido  LIKE che_ad_vetor_item.ies_devolvido,
      ies_excluir    CHAR(01) 
   END RECORD 

   DEFINE p_relat RECORD
      cod_empresa_ad LIKE che_ad_vetor_mest.cod_empresa_ad,
      num_ad         LIKE che_ad_vetor_mest.num_ad, 
      dat_pgto       LIKE che_ad_vetor_mest.dat_pgto,
      dat_cancel     LIKE che_ad_vetor_mest.dat_cancel,
      cod_fornecedor LIKE che_ad_vetor_mest.cod_fornecedor,
      val_tot_cheq   LIKE che_ad_vetor_mest.val_tot_cheq,
      val_tot_dinh   LIKE che_ad_vetor_mest.val_tot_dinh,
      val_total      LIKE che_ad_vetor_mest.val_total,   
      num_cheque     LIKE che_ad_vetor_item.num_cheque, 
      cod_banco      LIKE che_ad_vetor_item.cod_banco,
      cod_agencia    LIKE che_ad_vetor_item.cod_agencia, 
      val_cheque     LIKE che_ad_vetor_item.val_cheque,
      dat_vencto     LIKE che_ad_vetor_item.dat_vencto,
      ies_devolvido  LIKE che_ad_vetor_item.ies_devolvido
   END RECORD

END GLOBALS

MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "ESP0084-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("esp0084.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("CAP")
  CALL log001_acessa_usuario("CAP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL esp0084_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0084_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp0084") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp0084 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0084","IN") THEN
            IF esp0084_inclusao() THEN
               IF esp0084_entrada_item("INCLUSAO") THEN
                  CALL esp0084_grava_dados()
               END IF
            END IF
         END IF
      COMMAND KEY("H") "Consultar Cheque" "Consulta Cheques da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0084","CO") THEN
            IF esp0084_consulta_cheque() THEN
               IF esp0084_consulta_ad() THEN
                  NEXT OPTION "Modificar"
               END IF
            END IF
         END IF
      COMMAND KEY("C") "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0084","CO") THEN
            IF esp0084_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL esp0084_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL esp0084_paginacao("ANTERIOR") 
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0084","MO") THEN
               IF p_tela.dat_cancel IS NULL THEN
                  CALL esp0084_modificacao()
               ELSE
                  ERROR "AD X Cheques Cancelado, nao pode ser Modificado"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0084","EX") THEN
               CALL esp0084_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND KEY("N") "caNcela" "Cancela associacao Ad X Cheque"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CAP","esp0084","EX") THEN
               IF p_tela.dat_cancel IS NULL THEN
                  CALL esp0084_cancel()
               ELSE
                  ERROR "AD X Cheques ja esta cancelado"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer o Cancelamento"
         END IF 
      COMMAND "Listar" "Lista dados da Tabela"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0084","CO") THEN
            CALL esp0084_listar()
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
   CLOSE WINDOW w_esp0084

END FUNCTION
 
#--------------------------#
 FUNCTION esp0084_inclusao()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0084
   INITIALIZE p_tela.* TO NULL
   INITIALIZE p_ad_mestre.* TO NULL
   INITIALIZE p_che_ad_vetor_mest.* TO NULL
   INITIALIZE p_che_ad_vetor_item.* TO NULL
   INITIALIZE p_che_ad_vetor.* TO NULL
   INITIALIZE t_ch_item TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   LET p_tela.val_tot_dinh = 0
   LET p_tela.val_tot_cheq = 0 
   LET p_tela.val_total    = 0  

   LET INT_FLAG =  FALSE
   INPUT BY NAME p_tela.num_ad,  
                 p_tela.cod_empresa_ad,
                 p_tela.dat_pgto
      WITHOUT DEFAULTS  

      AFTER FIELD num_ad 
      IF p_tela.num_ad IS NULL THEN
         ERROR "O Campo Num AD nao pode ser Nulo"
         NEXT FIELD num_ad       
      END IF

      AFTER FIELD cod_empresa_ad
      IF p_tela.cod_empresa_ad IS NULL THEN
         ERROR "O Campo Cod Empresa nao pode ser Nulo"
         NEXT FIELD cod_empresa_ad
      ELSE
         SELECT * 
         FROM che_ad_vetor_mest
         WHERE cod_empresa_ad = p_tela.cod_empresa_ad
           AND num_ad = p_tela.num_ad
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "AD já Cadastrada"
            NEXT FIELD num_ad        
         END IF
         SELECT cod_fornecedor,
                val_saldo_ad 
            INTO p_tela.cod_fornecedor,
                 p_tela.val_saldo_ad        
         FROM ad_mestre      
         WHERE cod_empresa = p_tela.cod_empresa_ad
           AND num_ad = p_tela.num_ad
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Num AD nao Cadastrada"
            NEXT FIELD num_ad        
         ELSE
            SELECT raz_social      
               INTO p_che_ad_vetor.raz_social 
            FROM fornecedor 
            WHERE cod_fornecedor = p_tela.cod_fornecedor  
            DISPLAY BY NAME p_tela.val_saldo_ad,           
                            p_tela.cod_fornecedor,
                            p_che_ad_vetor.raz_social 
         END IF
      END IF

      AFTER FIELD dat_pgto
      IF p_tela.dat_pgto IS NULL THEN
         ERROR "O Campo Data Pagto nao pode ser Nulo"
         NEXT FIELD dat_pgto      
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0084
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION esp0084_entrada_item(p_funcao) 
#--------------------------------------#

   DEFINE p_funcao CHAR(11)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0084

   LET INT_FLAG =  FALSE
   INPUT ARRAY t_ch_item WITHOUT DEFAULTS FROM s_ch_item.*

      BEFORE FIELD cod_empresa_ch 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD cod_empresa_ch 
      IF t_ch_item[pa_curr].cod_empresa_ch IS NULL AND 
         t_ch_item[pa_curr].num_cheque IS NOT NULL AND  
         p_funcao = "MODIFICACAO" THEN  
         ERROR "O Campo Codigo da Empresa nao pode ser Nulo"
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
      SELECT *
      FROM che_ad_vetor_item
      WHERE cod_empresa_ch = t_ch_item[pa_curr].cod_empresa_ch
        AND num_cheque     = t_ch_item[pa_curr].num_cheque
        AND cod_banco      = t_ch_item[pa_curr].cod_banco
        AND cod_agencia    = t_ch_item[pa_curr].cod_agencia
        AND num_conta      = t_ch_item[pa_curr].num_conta
        AND num_ad        <> p_tela.num_ad 
        AND dat_cancel IS NULL 
      IF SQLCA.SQLCODE = 0 THEN
         ERROR "Cheque já Utilizado p/ Pagar outra AD"
         NEXT FIELD cod_empresa_ch
      END IF
      SELECT val_saldo
         INTO t_ch_item[pa_curr].val_cheque
      FROM cheque_mestre 
      WHERE cod_empresa = t_ch_item[pa_curr].cod_empresa_ch
        AND num_cheque  = t_ch_item[pa_curr].num_cheque  
        AND cod_banco   = t_ch_item[pa_curr].cod_banco
        AND cod_agencia = t_ch_item[pa_curr].cod_agencia
        AND num_conta   = t_ch_item[pa_curr].num_conta
      IF SQLCA.SQLCODE <> 0 THEN
         PROMPT "Cheque nao Cadastrado, Deseja Prosseguir (S,N): " FOR p_r
         LET p_r = UPSHIFT(p_r)
         IF p_r = "S" THEN
            NEXT FIELD val_cheque  
         ELSE
            NEXT FIELD cod_empresa_ch
         END IF
      ELSE
         DISPLAY t_ch_item[pa_curr].val_cheque TO s_ch_item[sc_curr].val_cheque
         NEXT FIELD dat_vencto
      END IF

      BEFORE FIELD dat_vencto    
      IF p_funcao = "INCLUSAO" THEN
         LET t_ch_item[pa_curr].dat_vencto = TODAY
      END IF

      AFTER FIELD dat_vencto 
      IF t_ch_item[pa_curr].dat_vencto IS NULL THEN
         ERROR "O Campo Data de Vencimento nao pode ser Nulo"
         NEXT FIELD dat_vencto
      END IF

      BEFORE FIELD ies_devolvido
      LET t_ch_item[pa_curr].ies_devolvido = "N"

      AFTER FIELD ies_devolvido 
      IF t_ch_item[pa_curr].ies_devolvido <> "N" AND 
         p_funcao = "INCLUSAO" THEN
         ERROR "O Campo Devolvido nao pode ser Diferente de N"
         NEXT FIELD ies_devolvido
      ELSE
         IF t_ch_item[pa_curr].ies_devolvido <> "N" AND 
            t_ch_item[pa_curr].ies_devolvido <> "S" THEN
            ERROR "O Campo Devolvido nao pode ser Diferente de N ou S"
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
         DELETE FROM che_ad_vetor_item
         WHERE cod_empresa_ch = t_ch_item[pa_curr].cod_empresa_ch
           AND num_cheque     = t_ch_item[pa_curr].num_cheque
           AND cod_banco      = t_ch_item[pa_curr].cod_banco      
           AND cod_agencia    = t_ch_item[pa_curr].cod_agencia    
           AND num_conta      = t_ch_item[pa_curr].num_conta  
           AND dat_cancel IS null                           
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","CHE_AD_VETOR_ITEM")
            EXIT INPUT
         END IF
      END IF

      ON KEY (control-z)
         CALL esp0084_popup()
            RETURNING t_ch_item[pa_curr].cod_empresa_ch,
                      t_ch_item[pa_curr].num_cheque,
                      t_ch_item[pa_curr].cod_banco,
                      t_ch_item[pa_curr].cod_agencia,
                      t_ch_item[pa_curr].num_conta,
                      t_ch_item[pa_curr].val_cheque,
                      t_ch_item[pa_curr].ies_devolvido,
                      t_ch_item[pa_curr].ies_excluir
            CURRENT WINDOW IS w_esp0084
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
      FOR w_i = 1 TO 500
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

   IF p_tela.val_total <> p_tela.val_saldo_ad THEN
      PROMPT "Valor Total Diferente do Valor da AD - Continua(S,N): " FOR p_r
      LET p_r = UPSHIFT(p_r)
   ELSE
      LET p_r = "S" 
   END IF        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0084
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
      RETURN TRUE 
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION esp0084_grava_dados()
#-----------------------------#

   LET p_houve_erro = FALSE

{  IF p_tela.val_total <> p_tela.val_saldo_ad THEN
      PROMPT "Valor Total Diferente do Valor da AD - Continua(S,N): " FOR p_r
      LET p_r = UPSHIFT(p_r)
   ELSE
      LET p_r = "S" 
   END IF   }

   IF p_r = "S" THEN
      INSERT INTO che_ad_vetor_mest 
         VALUES (p_tela.cod_empresa_ad,
                 p_tela.num_ad,        
                 p_tela.dat_pgto,      
                 null,
                 p_tela.cod_fornecedor, 
                 p_tela.val_tot_cheq,
                 p_tela.val_tot_dinh,
                 p_tela.val_total)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","CHE_AD_VETOR_MEST")
         RETURN
      END IF

      FOR w_i = 1 TO 500
         IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
            t_ch_item[w_i].num_cheque IS NOT NULL THEN 
            INSERT INTO che_ad_vetor_item 
               VALUES (p_tela.cod_empresa_ad,
                       p_tela.num_ad,        
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
               CALL log003_err_sql("INCLUSAO","CHE_AD_VETOR_ITEM")
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
 FUNCTION esp0084_popup()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp00842") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp00842 AT 2,2 WITH FORM p_nom_tela 
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
      END IF

   END INPUT

   IF INT_FLAG THEN
      INITIALIZE p_tela2.*,
                 t_ch_item1 TO NULL
      CLOSE WINDOW w_esp00842
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
      CLOSE WINDOW w_esp00842
      RETURN t_ch_item1[1].*
   ELSE
      CLOSE WINDOW w_esp00842
      RETURN t_ch_item1[pa_curr1].*
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION esp0084_consulta_ad()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0084
   INITIALIZE p_che_ad_vetor.*, 
              t_ch_item TO NULL
   CLEAR FORM

   SELECT cod_empresa_ad,
          num_ad,
          dat_pgto,
          dat_cancel,
          cod_fornecedor,
          val_tot_cheq,
          val_tot_dinh,
          val_total    
      INTO p_tela.cod_empresa_ad,
           p_tela.num_ad,        
           p_tela.dat_pgto,      
           p_tela.dat_cancel,    
           p_tela.cod_fornecedor,
           p_tela.val_tot_cheq, 
           p_tela.val_tot_dinh, 
           p_tela.val_total 
   FROM che_ad_vetor_mest
   WHERE cod_empresa_ad = p_che_ad_vetor_mest.cod_empresa_ad
     AND num_ad = p_che_ad_vetor_mest.num_ad

   SELECT raz_social      
      INTO p_che_ad_vetor.raz_social 
   FROM fornecedor 
   WHERE cod_fornecedor = p_tela.cod_fornecedor  
   LET p_tela.val_saldo_ad = p_tela.val_total
   DISPLAY BY NAME p_tela.*,
                   p_che_ad_vetor.raz_social 

   DECLARE c_item CURSOR WITH HOLD FOR
   SELECT cod_empresa_ch,
          num_cheque,
          cod_banco,     
          cod_agencia,   
          num_conta,  
          val_cheque,
          ies_devolvido,
          dat_vencto
   FROM che_ad_vetor_item
   WHERE cod_empresa_ad = p_che_ad_vetor_mest.cod_empresa_ad
     AND num_ad = p_che_ad_vetor_mest.num_ad
   ORDER BY num_cheque

   LET w_i = 1
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

   END FOREACH 

   IF w_i = 1 THEN
      ERROR "AD nao Possui Cheques Cadastrados"
      LET p_ies_cons = TRUE  
      RETURN TRUE 
   END IF

   LET w_i = w_i - 1
  
   CALL SET_COUNT(w_i)

   DISPLAY ARRAY t_ch_item TO s_ch_item.*
   END DISPLAY 

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE  
      RETURN TRUE 
   END IF

END FUNCTION   

#---------------------------------#
 FUNCTION esp0084_consulta_cheque()
#---------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp00843") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp00843 AT 2,2 WITH FORM p_nom_tela 
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

      SELECT UNIQUE cod_empresa_ad,
                    num_ad
         INTO p_che_ad_vetor_mest.cod_empresa_ad,  
              p_che_ad_vetor_mest.num_ad           
      FROM che_ad_vetor_item 
      WHERE cod_empresa_ch = p_cod_empresa
        AND num_cheque = p_tela3.num_cheque
        AND cod_banco = p_tela3.cod_banco 
        AND cod_agencia = p_tela3.cod_agencia
        AND num_conta = p_tela3.num_conta 
        AND dat_cancel IS NULL            
      IF SQLCA.SQLCODE <> 0 THEN
         ERROR "Cheque nao Cadastrado em Nenhuma AD"
         NEXT FIELD num_cheque
      END IF

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      CLOSE WINDOW w_esp00843 
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      CLOSE WINDOW w_esp00843 
      RETURN TRUE
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION esp0084_consulta()
#--------------------------#

   DEFINE where_clause CHAR(300)  
   CLEAR FORM

   LET INT_FLAG = FALSE
   CONSTRUCT BY NAME where_clause ON che_ad_vetor_mest.num_ad,
                                     che_ad_vetor_mest.cod_empresa_ad,
                                     che_ad_vetor_mest.cod_fornecedor
                                     
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0084
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT * FROM che_ad_vetor_mest ",
                  "WHERE ", where_clause CLIPPED,                 
                  "ORDER BY num_ad, cod_empresa_ad "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao INTO p_che_ad_vetor_mest.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF esp0084_consulta_ad() THEN
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
 FUNCTION esp0084_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_che_ad_vetor_mestt.* = p_che_ad_vetor_mest.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_che_ad_vetor_mest.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_che_ad_vetor_mest.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direcao"
            LET p_che_ad_vetor_mest.* = p_che_ad_vetor_mestt.* 
            EXIT WHILE
         END IF
        
         SELECT * INTO p_che_ad_vetor_mest.* FROM che_ad_vetor_mest
         WHERE cod_empresa_ad = p_che_ad_vetor_mest.cod_empresa_ad
           AND num_ad = p_che_ad_vetor_mest.num_ad
  
         IF SQLCA.SQLCODE = 0 THEN 
            IF esp0084_consulta_ad() THEN
               LET p_ies_cons = TRUE
               EXIT WHILE
            END IF
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------#
 FUNCTION esp0084_modificacao()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_esp0084

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
   CURRENT WINDOW IS w_esp0084
   IF INT_FLAG THEN
      ERROR "Modificacao Cancelada"
      LET p_ies_cons = FALSE
      CLEAR FORM
      RETURN
   END IF

   BEGIN WORK
      IF esp0084_entrada_item("MODIFICACAO") THEN
         IF p_r = "S" THEN
            DELETE FROM che_ad_vetor_item 
            WHERE cod_empresa_ad = p_tela.cod_empresa_ad
              AND num_ad = p_tela.num_ad
            IF SQLCA.SQLCODE <> 0 THEN 
               ROLLBACK WORK 
               CALL log003_err_sql("EXCLUSAO","CHE_AD_VETOR_ITEM")
               RETURN
            END IF
            FOR w_i = 1 TO 500
               IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
                  t_ch_item[w_i].num_cheque IS NOT NULL AND  
                  t_ch_item[w_i].ies_excluir <> "S" THEN
                  INSERT INTO che_ad_vetor_item 
                     VALUES (p_tela.cod_empresa_ad,
                             p_tela.num_ad,        
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
                     CALL log003_err_sql("INCLUSAO","CHE_AD_VETOR_ITEM")
                     EXIT FOR
                  END IF
               END IF
            END FOR
         ELSE	
            ROLLBACK WORK 
            CLEAR FORM
            RETURN
         END IF
         IF p_houve_erro THEN
            ROLLBACK WORK 
            RETURN
         ELSE	
            UPDATE che_ad_vetor_mest
               SET dat_pgto     = p_tela.dat_pgto,     
                   val_tot_dinh = p_tela.val_tot_dinh,  
                   val_tot_cheq = p_tela.val_tot_cheq,  
                   val_total    = p_tela.val_total      
            WHERE cod_empresa_ad = p_tela.cod_empresa_ad
              AND num_ad = p_tela.num_ad 
            IF SQLCA.SQLCODE <> 0 THEN 
               ROLLBACK WORK 
	       CALL log003_err_sql("ALTERACAO","CHE_AD_VETOR_MEST")
               RETURN
            ELSE
               COMMIT WORK 
               MESSAGE "Modificacao Efetuada com Sucesso" 
                  ATTRIBUTE(REVERSE)
            END IF
         END IF
      ELSE
         ROLLBACK WORK 
         ERROR "Modificacao Cancelada"
         LET p_ies_cons = FALSE
         CLEAR FORM
      END IF

END FUNCTION   
#------------------------#
 FUNCTION esp0084_cancel()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0084
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      BEGIN WORK                   
         UPDATE che_ad_vetor_mest
            SET dat_cancel = TODAY
         WHERE cod_empresa_ad = p_tela.cod_empresa_ad
           AND num_ad = p_tela.num_ad    
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("EXCLUSAO","CHE_AD_VETOR_MEST")
            ROLLBACK WORK
            RETURN
         ELSE
            FOR w_i = 1 TO 500
               IF t_ch_item[w_i].cod_empresa_ch IS NOT NULL AND
                  t_ch_item[w_i].num_cheque IS NOT NULL AND  
                  t_ch_item[w_i].cod_banco IS NOT NULL AND  
                  t_ch_item[w_i].cod_agencia IS NOT NULL AND  
                  t_ch_item[w_i].num_conta IS NOT NULL THEN 
                  UPDATE che_ad_vetor_item
                     SET dat_cancel = TODAY
                  WHERE cod_empresa_ch = t_ch_item[w_i].cod_empresa_ch
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
            CALL log003_err_sql("ALTERACAO","CHE_AD_VETOR_ITEM")
            ROLLBACK WORK
         ELSE
            COMMIT WORK
            LET p_che_ad_vetor_mest.dat_cancel = TODAY
            DISPLAY BY NAME p_che_ad_vetor_mest.dat_cancel           
            LET p_ies_cons = FALSE
            MESSAGE "Cancelamento Efetuado com Sucesso" ATTRIBUTE(REVERSE)
            CLEAR FORM
         END IF
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION esp0084_exclusao()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0084

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
      BEGIN WORK                   
         DELETE FROM che_ad_vetor_mest
         WHERE cod_empresa_ad = p_tela.cod_empresa_ad
           AND num_ad = p_tela.num_ad    
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("EXCLUSAO","CHE_AD_VETOR_MEST")
            ROLLBACK WORK
            RETURN
         END IF

         FOR w_i = 1 TO 500
            DELETE FROM che_ad_vetor_item
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
            CALL log003_err_sql("EXCLUSAO","CHE_AD_VETOR_ITEM")
            ROLLBACK WORK
         ELSE
            COMMIT WORK
            LET p_ies_cons = FALSE
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            CLEAR FORM
         END IF
   END IF
 
END FUNCTION   

#------------------------#
 FUNCTION esp0084_listar()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp00841") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp00841 AT 12,14 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Selecionar" "Seleciona a Opcao Desejada"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"CAP","esp0084","CO") THEN
            IF esp0084_imprime() THEN
               IF esp0084_emite_relatorio() THEN
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
   CLOSE WINDOW w_esp00841

END FUNCTION

#-------------------------#
 FUNCTION esp0084_imprime()
#-------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp00841
   INITIALIZE p_tela1.* TO NULL
   CLEAR FORM

   LET p_tela1.num_ad = p_tela.num_ad  
   LET p_tela1.cod_empresa_ad = p_tela.cod_empresa_ad

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela1.cod_fornecedor,  
                 p_tela1.data_de, 
                 p_tela1.data_ate, 
                 p_tela1.num_ad, 
                 p_tela1.cod_empresa_ad,
                 p_tela1.qtd_copias
      WITHOUT DEFAULTS  

      AFTER FIELD cod_fornecedor 
      IF p_tela1.cod_fornecedor IS NOT NULL THEN
         SELECT UNIQUE cod_fornecedor
         FROM che_ad_vetor_mest
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

      AFTER FIELD cod_empresa_ad 
      IF p_tela1.cod_empresa_ad IS NOT NULL AND
         p_tela1.num_ad IS NULL THEN 
         ERROR "Informar Previamente o Numero da AD"
         NEXT FIELD num_ad        
      ELSE
         IF p_tela1.num_ad IS NOT NULL AND
            p_tela1.cod_empresa_ad IS NULL THEN 
            ERROR "O Campo Codigo da Empresa nao pode ser Nulo"
            NEXT FIELD cod_empresa_ad        
         ELSE
            IF p_tela1.num_ad IS NOT NULL AND
               p_tela1.cod_empresa_ad IS NOT NULL THEN 
               SELECT * 
               FROM che_ad_vetor_mest
               WHERE cod_empresa_ad = p_tela1.cod_empresa_ad
                 AND num_ad = p_tela1.num_ad
               IF SQLCA.SQLCODE <> 0 THEN
                  ERROR "AD nao Cadastrada"
                  NEXT FIELD num_ad        
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
   CURRENT WINDOW IS w_esp00841
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Selecao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION esp0084_emite_relatorio()
#---------------------------------#

   INITIALIZE p_che_ad_vetor_mest.*,
              p_che_ad_vetor_item.*,
              p_relat.* TO NULL

   IF log028_saida_relat(21,42) IS NOT NULL THEN 
      MESSAGE " Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT esp0084_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'esp0084.tmp' 
            START REPORT esp0084_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT esp0084_relat TO p_nom_arquivo
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
      p_tela1.num_ad IS NULL AND
      p_tela1.cod_empresa_ad IS NULL THEN 
      LET sql_stmt = "SELECT * FROM che_ad_vetor_mest ",
                     "WHERE cod_fornecedor = '", p_tela1.cod_fornecedor, "' ",
                     "ORDER BY cod_fornecedor, dat_pgto, num_ad "
   ELSE
      IF p_tela1.cod_fornecedor IS NULL AND
         p_tela1.data_de IS NOT NULL AND
         p_tela1.data_ate IS NOT NULL AND
         p_tela1.num_ad IS NULL AND
         p_tela1.cod_empresa_ad IS NULL THEN 
         LET sql_stmt = "SELECT * FROM che_ad_vetor_mest ",
                        "WHERE dat_pgto BETWEEN '", p_tela1.data_de, "' ",
                        " AND '", p_tela1.data_ate, "' ",
                        "ORDER BY cod_fornecedor, dat_pgto, num_ad "
      ELSE
         IF p_tela1.cod_fornecedor IS NULL AND
            p_tela1.data_de IS NULL AND
            p_tela1.data_ate IS NULL AND
            p_tela1.num_ad IS NOT NULL AND
            p_tela1.cod_empresa_ad IS NOT NULL THEN 
            LET sql_stmt = "SELECT * FROM che_ad_vetor_mest ",
                           "WHERE cod_empresa_ad = '", 
                           p_tela1.cod_empresa_ad, "' ",
                           " AND num_ad = '", p_tela1.num_ad, "' ",
                           "ORDER BY cod_fornecedor, dat_pgto, num_ad "
         ELSE
            IF p_tela1.cod_fornecedor IS NULL AND    
               p_tela1.data_de IS NULL AND
               p_tela1.data_ate IS NULL AND 
               p_tela1.num_ad IS NULL AND  
               p_tela1.cod_empresa_ad IS NULL THEN
               LET sql_stmt = "SELECT * FROM che_ad_vetor_mest ",
                              "ORDER BY cod_fornecedor, dat_pgto, num_ad "
            END IF
         END IF
      END IF 
   END IF 

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query

#  FOR w_i = 1 TO p_tela1.qtd_copias

   FOREACH cq_relat INTO p_che_ad_vetor_mest.*

      LET p_relat.cod_empresa_ad = p_che_ad_vetor_mest.cod_empresa_ad
      LET p_relat.num_ad = p_che_ad_vetor_mest.num_ad   
      LET p_relat.dat_pgto =  p_che_ad_vetor_mest.dat_pgto      
      LET p_relat.dat_cancel =  p_che_ad_vetor_mest.dat_cancel      
      LET p_relat.cod_fornecedor = p_che_ad_vetor_mest.cod_fornecedor
      LET p_relat.val_tot_cheq = p_che_ad_vetor_mest.val_tot_cheq  
      LET p_relat.val_tot_dinh = p_che_ad_vetor_mest.val_tot_dinh  
      LET p_relat.val_total = p_che_ad_vetor_mest.val_total

      DECLARE cq_item CURSOR FOR
      SELECT * 
      FROM che_ad_vetor_item
      WHERE cod_empresa_ad = p_che_ad_vetor_mest.cod_empresa_ad
        AND num_ad = p_che_ad_vetor_mest.num_ad

             
      FOREACH cq_item INTO p_che_ad_vetor_item.*

         LET p_relat.num_cheque = p_che_ad_vetor_item.num_cheque    
         LET p_relat.cod_banco = p_che_ad_vetor_item.cod_banco     
         LET p_relat.cod_agencia = p_che_ad_vetor_item.cod_agencia
         LET p_relat.val_cheque = p_che_ad_vetor_item.val_cheque
         LET p_relat.ies_devolvido = p_che_ad_vetor_item.ies_devolvido
         LET p_relat.dat_vencto = p_che_ad_vetor_item.dat_vencto

         OUTPUT TO REPORT esp0084_relat(p_relat.*)
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
   FINISH REPORT esp0084_relat   

   RETURN TRUE

END FUNCTION  

#----------------------------#
 REPORT esp0084_relat(p_relat)
#----------------------------# 

   DEFINE p_relat RECORD
      cod_empresa_ad   LIKE che_ad_vetor_mest.cod_empresa_ad,
      num_ad           LIKE che_ad_vetor_mest.num_ad, 
      dat_pgto         LIKE che_ad_vetor_mest.dat_pgto,
      dat_cancel       LIKE che_ad_vetor_mest.dat_cancel,
      cod_fornecedor   LIKE che_ad_vetor_mest.cod_fornecedor,
      val_tot_cheq     LIKE che_ad_vetor_mest.val_tot_cheq,
      val_tot_dinh     LIKE che_ad_vetor_mest.val_tot_dinh,
      val_total        LIKE che_ad_vetor_mest.val_total,   
      num_cheque       LIKE che_ad_vetor_item.num_cheque, 
      cod_banco        LIKE che_ad_vetor_item.cod_banco,
      cod_agencia      LIKE che_ad_vetor_item.cod_agencia, 
      val_cheque       LIKE che_ad_vetor_item.val_cheque,
      dat_vencto       LIKE che_ad_vetor_item.dat_vencto,
      ies_devolvido    LIKE che_ad_vetor_item.ies_devolvido
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
               COLUMN 045, "Relacao de Cheques Para Pagamento de AD's",
               COLUMN 122, "FL.: ", PAGENO USING "#####&"
         PRINT COLUMN 001, "ESP0084", 
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
         PRINT "========================================",
               "========================================",
               "========================================",
               "============"

      BEFORE GROUP OF p_relat.num_ad        

         PRINT COLUMN 001, "Num. AD.",
               COLUMN 010, p_relat.num_ad USING "#####&",
               COLUMN 019, "Empresa",
               COLUMN 027, p_relat.cod_empresa_ad,
               COLUMN 033, "Valor",
               COLUMN 039, p_relat.val_total USING "##,###,##&.&&", 
               COLUMN 053, "Pagto",
               COLUMN 060, p_relat.dat_pgto USING "dd/mm/yyyy",
               COLUMN 072, "Cancel", 
               COLUMN 080, p_relat.dat_cancel USING "dd/mm/yyyy"

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

      AFTER GROUP OF p_relat.num_ad        

         SKIP  1 LINE
         PRINT COLUMN 001, "TOTAL: ", 
               COLUMN 014, "CHEQUE: ", GROUP SUM(p_relat.val_cheque)
                                       USING "####,###,###,##&.&&",
               COLUMN 044, "DINH.: ", p_relat.val_tot_dinh 
                                      USING "####,###,###,##&.&&",
               COLUMN 073, "GERAL: ", p_relat.val_total 
         PRINT "========================================",
               "========================================",
               "========================================",
               "============"

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
#------------------------------ FIM DE PROGRAMA -------------------------------#

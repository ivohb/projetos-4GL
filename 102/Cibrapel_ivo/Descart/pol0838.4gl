#-----------------------------------------------------------------#
# PROGRAMA: pol0838                                               #
# OBJETIVO: CONTAGEM DE ITENS DE DEBITO DIRETO                    #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_nf_sup            RECORD LIKE nf_sup.*,
          p_aviso_rec         RECORD LIKE aviso_rec.*,
          p_audit_ar_dd_885   RECORD LIKE audit_ar_dd_885.*,
          p_saldo_ar_dd_885   RECORD LIKE saldo_ar_dd_885.*

   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_fornecedor   LIKE fornecedor.raz_social,
          p_ies_cons         SMALLINT,
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
          p_i                SMALLINT

   DEFINE t_aviso_rec ARRAY[500] OF RECORD
      num_seq          LIKE aviso_rec.num_seq,
      cod_item         LIKE aviso_rec.cod_item,
      qtd_declarad_nf  LIKE aviso_rec.qtd_declarad_nf,        
      den_item         LIKE aviso_rec.den_item 
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "POL0838-05.10.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0838_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0838_controle()
#--------------------------#

   INITIALIZE p_nf_sup.*, 
              p_aviso_rec.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0838") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0838 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Notas Fiscais"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0838","CO") THEN 
            CALL pol0838_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Processa"
            END IF
         END IF
      COMMAND "Processa" "Executa contagem"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0838","MO") THEN 
            IF p_ies_cons THEN 
               CALL pol0838_processa()
               IF p_houve_erro THEN
                  ERROR "Processamento Cancelado " 
                  NEXT OPTION "Consultar"
               END IF  
               #COMMIT WORK
               CALL log085_transacao("COMMIT")
               ERROR "Contagem efetuada com sucesso " 
               NEXT OPTION "Consultar"
            ELSE
               ERROR "Consulte Previamente Antes de Processar"
               NEXT OPTION "Consultar"
            END IF
         END IF

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0838

END FUNCTION

#--------------------------#
 FUNCTION pol0838_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0838

   LET p_nf_sup.num_aviso_rec = NULL 
   IF pol0838_entrada_dados() THEN
      CALL pol0838_exibe_dados()
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_nf_sup.num_aviso_rec = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0838_entrada_dados()
#-------------------------------#
 DEFINE l_count  INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0838

   LET INT_FLAG = FALSE  
   INPUT p_nf_sup.num_aviso_rec
   WITHOUT DEFAULTS  
    FROM num_aviso_rec 

    AFTER FIELD num_aviso_rec     
    IF p_nf_sup.num_aviso_rec IS NOT NULL THEN
       SELECT * INTO p_nf_sup.*
       FROM nf_sup                  
       WHERE cod_empresa = p_cod_empresa            
         AND num_aviso_rec = p_nf_sup.num_aviso_rec
       IF SQLCA.SQLCODE <> 0 THEN
          ERROR "AR nao cadastrada" 
          NEXT FIELD num_aviso_rec
       ELSE
          IF p_nf_sup.ies_especie_nf <> 'NF' AND 
             p_nf_sup.ies_especie_nf <> 'NFF' THEN 
             ERROR "Tipo de nota fiscal, nao controla estoque ",p_nf_sup.ies_especie_nf 
             NEXT FIELD num_aviso_rec
          END IF   
          LET l_count = 0
                  
          SELECT COUNT(*)
            INTO l_count 
            FROM saldo_ar_dd_885
           WHERE cod_empresa = p_cod_empresa
             AND num_ar      = p_nf_sup.num_aviso_rec
          IF l_count > 0 THEN 
             ERROR 'Contagem ja efetuada para este AR'
             NEXT FIELD num_aviso_rec
          END IF         
       END IF
    ELSE 
       ERROR "O Campo AR nao pode ser Nulo"
       NEXT FIELD num_aviso_rec       
    END IF
    
    SELECT raz_social
      INTO p_nom_fornecedor
      FROM fornecedor
     WHERE cod_fornecedor = p_nf_sup.cod_fornecedor
        
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0838
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0838_exibe_dados()
#------------------------------#
 DEFINE l_ies_ctr_estoque  LIKE item.ies_ctr_estoque
   
   DISPLAY BY NAME p_nf_sup.num_aviso_rec,
                   p_nf_sup.cod_fornecedor,
                   p_nf_sup.num_nf,
                   p_nf_sup.ies_especie_nf
                   
   DISPLAY p_nom_fornecedor TO nom_fornecedor                

   INITIALIZE t_aviso_rec TO NULL
   DECLARE c_aviso_rec CURSOR FOR
   SELECT num_seq,
          cod_item,
          den_item,
          qtd_declarad_nf
   FROM aviso_rec
   WHERE cod_empresa   = p_cod_empresa
     AND num_aviso_rec = p_nf_sup.num_aviso_rec

   LET p_i = 1
   FOREACH c_aviso_rec INTO p_aviso_rec.num_seq,      
                            p_aviso_rec.cod_item, 
                            p_aviso_rec.den_item,      
                            p_aviso_rec.qtd_declarad_nf
      SELECT ies_ctr_estoque
        INTO l_ies_ctr_estoque
        FROM item
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item    = p_aviso_rec.cod_item
         
      IF l_ies_ctr_estoque <> 'N' THEN 
         CONTINUE FOREACH
      END IF          

      LET t_aviso_rec[p_i].num_seq         = p_aviso_rec.num_seq
      LET t_aviso_rec[p_i].cod_item        = p_aviso_rec.cod_item
      LET t_aviso_rec[p_i].den_item        = p_aviso_rec.den_item
      LET t_aviso_rec[p_i].qtd_declarad_nf = p_aviso_rec.qtd_declarad_nf
      
      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_aviso_rec TO s_aviso_rec.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#---------------------------#
 FUNCTION pol0838_processa()
#---------------------------#

   LET p_houve_erro = FALSE
   #BEGIN WORK
   CALL log085_transacao("BEGIN")

   FOR w_i = 1  TO 500 

      IF t_aviso_rec[w_i].num_seq IS NULL THEN
         EXIT FOR 
      END IF

      LET p_saldo_ar_dd_885.cod_empresa  = p_nf_sup.cod_empresa
      LET p_saldo_ar_dd_885.num_ar       = p_nf_sup.num_aviso_rec       
      LET p_saldo_ar_dd_885.cod_item     = t_aviso_rec[w_i].cod_item
      LET p_saldo_ar_dd_885.num_seq      = t_aviso_rec[w_i].num_seq
      LET p_saldo_ar_dd_885.den_item     = t_aviso_rec[w_i].den_item
      LET p_saldo_ar_dd_885.qtd_item     = t_aviso_rec[w_i].qtd_declarad_nf
      LET p_saldo_ar_dd_885.qtd_retirada = 0
      INSERT INTO saldo_ar_dd_885  VALUES  (p_saldo_ar_dd_885.*)

      LET p_audit_ar_dd_885.cod_empresa  = p_nf_sup.cod_empresa
      LET p_audit_ar_dd_885.num_ar       = p_nf_sup.num_aviso_rec       
      LET p_audit_ar_dd_885.cod_item     = t_aviso_rec[w_i].cod_item
      LET p_audit_ar_dd_885.num_seq      = t_aviso_rec[w_i].num_seq
      LET p_audit_ar_dd_885.den_item     = t_aviso_rec[w_i].den_item
      LET p_audit_ar_dd_885.dat_ocor     = TODAY
      LET p_audit_ar_dd_885.usuario      = p_user
      LET p_audit_ar_dd_885.texto        = 'QUANTIDADE RECEBIDA - ', t_aviso_rec[w_i].qtd_declarad_nf
      INSERT INTO audit_ar_dd_885  VALUES  (p_audit_ar_dd_885.*)
      
   END FOR
   
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#


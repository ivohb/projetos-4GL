#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                     #
# PROGRAMA: POL0653                                                     #
# OBJETIVO: EXPORTAÇÃO DE ENTRADAS DE INSUMOS P/ O TRIM                 #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 19/10/2007                                                  #
#-----------------------------------------------------------------------#

DATABASE logix
 
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_exportar           SMALLINT
          
   DEFINE p_num_seq            LIKE estoque_trans.num_seq,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_trans_operacao     LIKE estoque_trans.cod_operacao,
          p_pre_unit_nf        LIKE aviso_rec.pre_unit_nf,
          p_cod_oper_ent_vrqtd LIKE parametros_885.cod_oper_ent_vrqtd,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_num_aviso_rec      CHAR(10)


   DEFINE p_insumo             RECORD LIKE insumo_885.*
   
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0653-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0653.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0653_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0653_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0653") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0653 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   WHENEVER ERROR CONTINUE

   IF NOT pol0653_le_empresas() THEN
      RETURN FALSE
   END IF

   IF NOT pol0653_le_par_sup() THEN
      RETURN
   END IF

   IF NOT pol0653_le_parametros_885() THEN
      RETURN
   END IF

   
   CALL pol0653_exporta_entradas()
   
   CLOSE WINDOW w_pol0653
   
END FUNCTION

#-----------------------------#
FUNCTION pol0653_le_empresas()
#-----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
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
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0653_le_par_sup()
#----------------------------#

   SELECT cod_operac_estoq_l
     INTO p_cod_operacao
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","PAR_SUP")
      RETURN FALSE
   END IF

   IF p_cod_operacao IS NULL THEN
      CALL log0030_mensagem(
             "Operação de inspesão não cadastrada",
             "exclamation")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0653_le_parametros_885()
#-----------------------------------#

   SELECT cod_oper_ent_vrqtd
     INTO p_cod_oper_ent_vrqtd
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","parametros_885")       
      RETURN FALSE
   END IF

   IF p_cod_oper_ent_vrqtd IS NULL THEN
      CALL log0030_mensagem(
             "Operação de quantidade/valor não cadastrada",
             "exclamation")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol0653_exporta_entradas()
#----------------------------------#


   DECLARE cq_insumo CURSOR WITH HOLD FOR
    SELECT a.num_transac,
           a.num_lote_dest,
           a.cod_item,
           a.num_docum,
           a.num_seq,
           a.dat_movto,
           a.qtd_movto,
           a.ies_tip_movto,
           a.cod_operacao
      FROM estoque_trans a,
           item b
     WHERE a.cod_empresa    = p_cod_empresa
       AND a.num_seq        IS NOT NULL
       AND a.cod_operacao   IN (p_cod_operacao,p_cod_oper_ent_vrqtd)
       AND a.ies_tip_movto  IN ('N','R')
       AND ies_sit_est_dest IN ('L','E')
       AND b.cod_empresa    = a.cod_empresa
       AND b.cod_item       = a.cod_item
       AND b.cod_familia IN (SELECT c.cod_familia
                               FROM familia_insumo_885 c
                              WHERE c.cod_empresa = b.cod_empresa)
       AND a.num_transac NOT IN (SELECT d.num_sequencia
                                   FROM insumo_885 d
                                  WHERE d.cod_empresa = a.cod_empresa)
     
   FOREACH cq_insumo INTO
           p_insumo.num_sequencia, 
           p_insumo.num_lote,
           p_insumo.cod_item,
           p_num_aviso_rec,
           p_num_seq,
           p_insumo.dat_movto,
           p_insumo.qtd_movto,
           p_insumo.tip_movto,
           p_trans_operacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","CLIENTES")
         RETURN
      END IF

      DISPLAY p_insumo.cod_item TO cod_item
      # Refresh de tela
      #lds CALL LOG_refresh_display()

      LET p_exportar = TRUE
      
      IF p_insumo.tip_movto = 'N' THEN
         IF NOT pol0653_exporta_normal() THEN
            EXIT FOREACH
         END IF
      ELSE
         IF NOT pol0653_exporta_reversao() THEN
            EXIT FOREACH
         END IF
      END IF

      IF NOT p_exportar THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol0653_le_trans_end() THEN
         EXIT FOREACH
      END IF
      
      IF NOT p_exportar THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol0653_le_item() THEN
         EXIT FOREACH
      END IF

     IF NOT pol0653_le_fornecedor() THEN
        EXIT FOREACH
     END IF

     CALL pol0653_le_fardos()

      CALL log085_transacao("BEGIN")

      IF NOT pol0653_insere_insumo() THEN
         CALL log085_transacao("ROLLBACK")
         EXIT FOREACH
      END IF

      CALL log085_transacao("COMMIT")
      
   END FOREACH
   
END FUNCTION

#-------------------------------#
FUNCTION pol0653_exporta_normal()
#-------------------------------#

   LET p_insumo.val_movto = NULL

   SELECT pre_unit_nf
     INTO p_pre_unit_nf
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_emp_ofic
      AND num_aviso_rec = p_num_aviso_rec
      AND cod_item      = p_insumo.cod_item
      AND num_seq       = p_num_seq

   IF STATUS = 100 THEN
      SELECT pre_unit_nf
        INTO p_pre_unit_nf
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         AND cod_item      = p_insumo.cod_item
         AND num_seq       = p_num_seq
      IF STATUS <> 0 THEN
         LET p_exportar = FALSE
         RETURN TRUE
      ELSE
         SELECT cod_fornecedor,
                num_nf,
                dat_emis_nf,
                dat_entrada_nf
           INTO p_insumo.cod_fornecedor,
                p_insumo.num_nf,
                p_insumo.dat_emis_nf,
                p_insumo.dat_entrada_nf
           FROM nf_sup
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_num_aviso_rec
      END IF
   ELSE
      SELECT cod_fornecedor,
             num_nf,
             dat_emis_nf,
             dat_entrada_nf
        INTO p_insumo.cod_fornecedor,
             p_insumo.num_nf,
             p_insumo.dat_emis_nf,
             p_insumo.dat_entrada_nf
        FROM nf_sup
       WHERE cod_empresa   = p_cod_emp_ofic
         AND num_aviso_rec = p_num_aviso_rec
   END IF             

   IF p_pre_unit_nf IS NULL THEN
      LET p_pre_unit_nf = 0
   END IF
   
   LET p_insumo.val_movto = p_insumo.qtd_movto * p_pre_unit_nf
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0653_exporta_reversao()
#----------------------------------#

   SELECT DISTINCT 
          cod_fornecedor,
          num_nf,
          dat_emis_nf
     INTO p_insumo.cod_fornecedor,
          p_insumo.num_nf,
          p_insumo.dat_emis_nf
     FROM insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND num_ar      = p_num_aviso_rec
      AND num_lote    = p_insumo.num_lote
    
   IF STATUS = 100 THEN
      LET p_exportar = FALSE
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','insumo_885')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0653_le_trans_end()
#------------------------------#

   SELECT largura,
          altura,
          diametro
     INTO p_insumo.largura,
          p_insumo.tubete,
          p_insumo.diametro
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_insumo.num_sequencia

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","ESTOQUE_TRANS_END")
       RETURN FALSE
    END IF

    RETURN TRUE
    
END FUNCTION

#-------------------------#
FUNCTION pol0653_le_item()
#-------------------------#

   DEFINE p_cod_familia LIKE item.cod_familia
   
   SELECT cod_familia
     INTO p_cod_familia
     FROM item
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_insumo.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","item")
      RETURN FALSE
   END IF

   SELECT cod_empresa
     FROM familia_insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND ies_bobina  = 'S'
   
   IF STATUS = 0 THEN
      LET p_insumo.ies_bobina = 'S'
   ELSE
      IF STATUS = 100 THEN
         LET p_insumo.ies_bobina = 'N'
      ELSE
         CALL log003_err_sql("LEITURA","familia_insumo_885")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0653_le_fornecedor()
#-------------------------------#

   SELECT raz_social
     INTO p_insumo.nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_insumo.cod_fornecedor
   
   IF STATUS = 100 THEN
      INITIALIZE p_insumo.nom_fornecedor TO NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Fornecedor')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0653_le_fardos()
#----------------------------#

   SELECT qtd_fardo
     INTO p_insumo.qtd_fardos
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_emp_ofic
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq_ar    = p_num_seq
      AND num_lote      = p_insumo.num_lote

   IF STATUS <> 0 THEN
      LET p_insumo.qtd_fardos = 0
   END IF   
        
END FUNCTION

#-------------------------------#
FUNCTION pol0653_insere_insumo()
#-------------------------------#
   
   LET p_insumo.cod_empresa  = p_cod_empresa
   LET p_insumo.cod_status   = 0
   LET p_insumo.num_ar       = p_num_aviso_rec
   LET p_insumo.num_seq_ar   = p_num_seq

   INSERT INTO insumo_885
    VALUES(p_insumo.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSÃO","INSUMO_885")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

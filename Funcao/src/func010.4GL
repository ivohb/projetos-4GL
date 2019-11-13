#---------------------------------------------------------------#
#-------Objetivo: gerar  título no CRE--------------------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#--------------------------parâmetros---------------------------#
# Informações básicas, conforme RECORD mr_titulo logo abaixo    #
#--------------------------retorno lógico-----------------------#
#       TRUE, para sucesso na operação;                         #
#       ou FALSE, para falha na operação                        #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          p_user                 CHAR(08)

END GLOBALS

DEFINE mr_titulo         RECORD
       cod_empresa       CHAR(02),
       num_docum         CHAR(14),
       dat_emissao       DATE,
       dat_vencto        DATE,
       val_docum         DECIMAL(12,2),
       cod_cliente       CHAR(15),
       cod_cnd_pgto      DECIMAL(2,0),
       num_pedido        CHAR(16),
       num_nf            CHAR(14),
       ser_nf            CHAR(02),
       tip_nf            CHAR(02),   
       empresa_dest      CHAR(02),
       cod_portador      DECIMAL(4,0)              
END RECORD

DEFINE mr_docum          RECORD LIKE docum.*

DEFINE m_dat_proces      DATE

#------------------------------------#
FUNCTION func010_gera_docum(lr_docum)#
#------------------------------------#

   DEFINE lr_docum       RECORD
       cod_empresa       CHAR(02),
       num_docum         CHAR(14),
       dat_emissao       DATE,
       dat_vencto        DATE,
       val_docum         DECIMAL(12,2),
       cod_cliente       CHAR(15),
       cod_cnd_pgto      DECIMAL(2,0),
       num_pedido        CHAR(16),
       num_nf            CHAR(14),
       ser_nf            CHAR(02),
       tip_nf            CHAR(02),
       empresa_dest      CHAR(02),   
       cod_portador      DECIMAL(4,0)    
   END RECORD

   LET mr_titulo.* = lr_docum.*
   
   IF NOT func010_processa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func010_processa()#
#--------------------------#

   IF NOT func010_le_par_cre() THEN
      RETURN FALSE
   END IF

   IF NOT func010_ins_docum() THEN
      RETURN FALSE
   END IF

   IF NOT func010_ins_docum_aen() THEN
      RETURN FALSE
   END IF
   
   IF NOT func010_ins_docum_port() THEN
      RETURN FALSE
   END IF
   
   IF NOT func010_ins_cre_doc() THEN
      RETURN FALSE
   END IF

   IF NOT func010_ins_cre_info() THEN
      RETURN FALSE
   END IF

   IF NOT func010_ins_credcad() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION func010_le_par_cre()#
#----------------------------#

   SELECT dat_proces_doc
     INTO m_dat_proces
     FROM par_cre

   IF STATUS <> 0 THEN
      LET m_dat_proces = TODAY
   END IF
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#   
FUNCTION func010_ins_docum()#
#---------------------------#   

   INITIALIZE mr_docum TO NULL
   
   SELECT ies_tip_portador
     INTO mr_docum.ies_tip_portador 
     FROM portador
    WHERE cod_portador = mr_titulo.cod_portador

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','func010:portador')
      RETURN FALSE
   END IF
   
   LET mr_docum.cod_empresa       = mr_titulo.cod_empresa
   LET mr_docum.num_docum         = mr_titulo.num_docum
   LET mr_docum.ies_tip_docum     = 'NS'
   LET mr_docum.dat_emis          = mr_titulo.dat_emissao
   LET mr_docum.dat_vencto_s_desc = mr_titulo.dat_vencto
   LET mr_docum.ies_cobr_juros    = 'N'
   LET mr_docum.cod_cliente       = mr_titulo.cod_cliente      
   LET mr_docum.val_liquido       = mr_titulo.val_docum
   LET mr_docum.val_bruto         = mr_titulo.val_docum
   LET mr_docum.val_saldo         = mr_titulo.val_docum
   LET mr_docum.val_fat           = mr_titulo.val_docum
   LET mr_docum.val_desc_dia      = 0
   LET mr_docum.ies_tip_cobr      = 'S'
   LET mr_docum.pct_juro_mora     = 0
   LET mr_docum.cod_portador      = mr_titulo.cod_portador
   LET mr_docum.ies_cnd_bordero   = NULL
   LET mr_docum.ies_situa_docum   = 'N'
   LET mr_docum.dat_alter_situa   = mr_titulo.dat_emissao
   LET mr_docum.ies_pgto_docum    = 'A'
   LET mr_docum.ies_pendencia     = 'N'
   LET mr_docum.cod_tip_comis     = 0
   LET mr_docum.val_desc_comis    = 0
   LET mr_docum.ies_tip_emis_docum= 'N'
   LET mr_docum.num_lote_remessa  = 0
   LET mr_docum.dat_gravacao      = TODAY 
   LET mr_docum.cod_cnd_pgto      = NULL
   LET mr_docum.cod_deb_cred_cl   = NULL
   LET mr_docum.ies_ctr_endosso   = 'N'
   LET mr_docum.cod_mercado       = 'I'
   LET mr_docum.num_lote_lanc_cont= 0
   LET mr_docum.dat_atualiz       = m_dat_proces

  INSERT INTO docum 
   VALUES(mr_docum.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','docum')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION func010_ins_docum_aen()#
#-------------------------------#
   
   DEFINE lr_aen    RECORD LIKE docum_aen.*
   DEFINE l_valor   DECIMAL(12,2),
          l_cod_aen CHAR(08),
          l_num_seq INTEGER
          
   LET l_num_seq = 0          
   
   INITIALIZE lr_aen.* TO NULL
   
   DECLARE cq_aen CURSOR FOR
    SELECT cod_aen, 
           SUM(valor)
      FROM docum_aen_tmp_912
     WHERE cod_emp_dest = mr_titulo.empresa_dest
      GROUP BY cod_aen

   FOREACH cq_aen INTO l_cod_aen, l_valor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','func010:cq_aen')
         RETURN FALSE
      END IF
      
      LET l_num_seq = l_num_seq + 1
      
      LET lr_aen.cod_empresa   = mr_docum.cod_empresa
      LET lr_aen.num_docum     = mr_docum.num_docum
      LET lr_aen.ies_tip_docum = mr_docum.ies_tip_docum
      LET lr_aen.num_seq_docum = l_num_seq
      LET lr_aen.cod_lin_prod  = l_cod_aen[1,2]
      LET lr_aen.cod_lin_recei = l_cod_aen[3,4]
      LET lr_aen.cod_seg_merc  = l_cod_aen[5,6]
      LET lr_aen.cod_cla_uso   = l_cod_aen[7,8]
      LET lr_aen.pct_rateio    = l_valor / mr_docum.val_liquido * 100
      LET lr_aen.dat_atualiz   = TODAY

     INSERT INTO docum_aen
      VALUES(lr_aen.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','docum_aen')
         RETURN FALSE
      END IF

   END FOREACH

   SELECT SUM(pct_rateio)
     INTO l_valor
     FROM docum_aen
    WHERE cod_empresa = mr_docum.cod_empresa
      AND num_docum   = mr_docum.num_docum

   IF STATUS <> 0 OR l_valor IS NULL THEN
      CALL log003_err_sql('SELECT','docum_aen')
      RETURN FALSE
   END IF
   
   IF l_valor <> 100 THEN
      
      LET l_valor = 100 - l_valor
      
      UPDATE docum_aen 
         SET pct_rateio = pct_rateio + l_valor
       WHERE cod_empresa = mr_docum.cod_empresa
         AND num_docum   = mr_docum.num_docum
         AND num_seq_docum = l_num_seq
   
      IF STATUS <> 0 OR l_valor IS NULL THEN
         CALL log003_err_sql('SELECT','docum_aen')
         RETURN FALSE
      END IF
   
   END IF
   
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func010_ins_docum_port()#
#--------------------------------#
   
   DEFINE lr_port    RECORD LIKE docum_port.*
   
   INITIALIZE lr_port.* TO NULL
   
   LET lr_port.cod_empresa        = mr_docum.cod_empresa
   LET lr_port.num_docum          = mr_docum.num_docum
   LET lr_port.ies_tip_docum      = mr_docum.ies_tip_docum
   LET lr_port.num_seq_docum      = 1
   LET lr_port.dat_alter_portador = m_dat_proces
   LET lr_port.ies_tip_cobr       = 'S'
   LET lr_port.cod_portador       = 0
   LET lr_port.ies_tip_portador   = 'X'
   LET lr_port.dat_atualiz        = TODAY

  INSERT INTO docum_port 
   VALUES(lr_port.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','docum_port')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION func010_ins_cre_doc()#
#------------------------------#
   
   DEFINE lr_cre_doc    RECORD LIKE cre_doc_port_compl.*
   
   INITIALIZE lr_cre_doc.* TO NULL
   
   LET lr_cre_doc.empresa            = mr_docum.cod_empresa  
   LET lr_cre_doc.num_docum          = mr_docum.num_docum    
   LET lr_cre_doc.tip_docum          = mr_docum.ies_tip_docum
   LET lr_cre_doc.sequencia_docum    = 1
   LET lr_cre_doc.contab_transf_port = 'N'
   LET lr_cre_doc.lote_lancto_contab = 0
   LET lr_cre_doc.dat_contabiliz     = ''
   LET lr_cre_doc.dat_atual_estorno  = ''
   LET lr_cre_doc.lote_ctbl_estorno  = 0

  INSERT INTO cre_doc_port_compl 
   VALUES(lr_cre_doc.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cre_doc_port_compl')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION func010_ins_cre_info()#
#------------------------------#

   DEFINE lr_cre_info   RECORD LIKE cre_info_adic_doc.*
   DEFINE l_dat         CHAR(19)
   
   INITIALIZE lr_cre_info.* TO NULL

   LET l_dat = EXTEND(m_dat_proces, YEAR TO DAY)
   LET l_dat = l_dat CLIPPED, TIME
   
   LET lr_cre_info.empresa         = mr_docum.cod_empresa  
   LET lr_cre_info.docum           = mr_docum.num_docum    
   LET lr_cre_info.tip_docum       = mr_docum.ies_tip_docum
   LET lr_cre_info.sequencia_docum = 1
   LET lr_cre_info.campo           = 'determinacao_entrada_portador'
   LET lr_cre_info.par_existencia  = 'E'
   LET lr_cre_info.parametro_texto = 'N'
   LET lr_cre_info.parametro_val   = mr_docum.val_liquido
   LET lr_cre_info.parametro_qtd   = NULL
   LET lr_cre_info.parametro_dat   = l_dat
     
  INSERT INTO cre_info_adic_doc
   VALUES(lr_cre_info.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cre_info_adic_doc')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func010_ins_credcad()#
#-----------------------------#

   INSERT INTO credcad_cod_cli 
    VALUES(mr_docum.cod_cliente,
           mr_docum.cod_empresa,
           mr_docum.num_docum,
           mr_docum.ies_tip_docum, 'N', NULL)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cre_info_adic_doc')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

       
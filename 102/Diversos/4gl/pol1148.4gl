#-----------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                                 #
# PROGRAMA: pol1148                                                     #
# OBJETIVO: INSPE플O DE ENTRADA                                         #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 10/05/2012                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item           LIKE ar_oc_cbc.cod_item,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_cod_local_insp     LIKE item.cod_local_insp,
          p_cod_local_ar       LIKE item.cod_local_insp,
          p_num_transac        LIKE estoque_lote.num_transac,
          p_num_transac_orig   LIKE aviso_rec_estoque.num_transac,
          p_cod_operacao       LIKE par_sup.cod_operac_estoq_l,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_insp_normal    LIKE estoque_lote.qtd_saldo,
          p_qtd_insp_excepc    LIKE estoque_lote.qtd_saldo,
          p_ies_liberacao_insp LIKE aviso_rec.ies_liberacao_insp,
          p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          p_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
          p_fator              LIKE ordem_sup.fat_conver_unid,
          p_num_oc             LIKE aviso_rec.num_oc,
          p_zz2_flag           CHAR(01),
          p_zz2_obs            CHAR(100),
          p_qtd_inspecionada   LIKE aviso_rec.qtd_liber,
          p_qtd_pc_a_insp      LIKE estoque_lote.qtd_saldo,
          p_qtd_pc_excep       LIKE estoque_lote.qtd_saldo,
          p_qtd_pc_insp        LIKE estoque_lote.qtd_saldo,
          p_qtd_total          LIKE aviso_rec.qtd_liber,
          p_difer              LIKE estoque_lote.qtd_saldo,
          p_qtd_recebida       LIKE aviso_rec.qtd_recebida,
          p_rowid              INTEGER,
          p_rowid_ar           INTEGER,
          p_count              SMALLINT,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_endereco           LIKE estoque_trans_end.endereco
          
   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_auditoria  RECORD LIKE estoque_auditoria.*

   DEFINE 	p_zz2          RECORD 
			zz2_filial   CHAR(02),               
			zz2_produt   CHAR(15),               
    	zz2_ar       char(15),               
	    zz2_seqar    DECIMAL(3,0),           
	    zz2_lote     char(16),               
	    zz2_qtdlib    decimal(12,2),          
	    zz2_qtrej    decimal(12,2),          
	    zz2_qtexce   DECIMAL(12,2),          
	    zz2_flag     char(1),                
	    zz2_obs      char(100),              
	    zz2_saldo    DECIMAL(12,2),          
	    zz2_numseq   CHAR(06),               
	    zz2_data     CHAR(08),  
      zz2_tpreg    CHAR(02),
      zz2_numop    CHAR(09),
      zz2_seqlot   CHAR(02),		
      d_e_l_e_t_   CHAR(01),               
      r_e_c_n_o_   INTEGER
   END RECORD

   DEFINE p_aen              RECORD 
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
  END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1148-10.02.08"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1148.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED

   {CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1148_controle()
   END IF}

   LET p_user = 'SIGA'
   CALL pol1148_controle()
   
END MAIN

#--------------------------#
 FUNCTION pol1148_controle()
#--------------------------#
   
   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE

   IF pol1148_processa() THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   WHENEVER ERROR STOP
   
END FUNCTION

#--------------------------#
FUNCTION pol1148_processa()
#--------------------------#

   DEFINE p_posi SMALLINT

   DECLARE cq_zz2 CURSOR FOR
   SELECT zz2_filial, 
          zz2_produt, 
          zz2_ar,     
          zz2_seqar,  
          zz2_lote,   
          zz2_qtdlib,  
          zz2_qtrej,  
          zz2_qtexce, 
          zz2_flag,   
          zz2_obs,    
          zz2_saldo,  
          zz2_numseq, 
          zz2_data,   
		  zz2_tpreg,   
          zz2_numop,
		  zz2_seqlot,
          d_e_l_e_t_, 
          r_e_c_n_o_,    
          rowid
     FROM dadosadv@prd:zz2010
    WHERE zz2_flag IN ('N','E')

   FOREACH cq_zz2 INTO 
           p_zz2.zz2_filial,  
           p_zz2.zz2_produt,  
           p_zz2.zz2_ar,      
           p_zz2.zz2_seqar,   
           p_zz2.zz2_lote,    
           p_zz2.zz2_qtdlib,   
           p_zz2.zz2_qtrej,   
           p_zz2.zz2_qtexce,  
           p_zz2.zz2_flag,    
           p_zz2.zz2_obs,     
           p_zz2.zz2_saldo,   
           p_zz2.zz2_numseq,  
           p_zz2.zz2_data,  
           p_zz2.zz2_tpreg,    
           p_zz2.zz2_numop, 
		   p_zz2.zz2_seqlot,
           p_zz2.d_e_l_e_t_,  
           p_zz2.r_e_c_n_o_,  
           p_rowid

      LET p_cod_empresa = p_zz2.zz2_filial
      
      IF  p_cod_empresa = ' ' 
      OR  p_cod_empresa = '0' 
      OR  p_cod_empresa = '0 'THEN 
         CONTINUE FOREACH
      END IF   
      
      SELECT cod_operac_estoq_l
        INTO p_cod_operacao
        FROM logix@prd:par_sup
       WHERE cod_empresa = p_cod_empresa

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LEITURA","PAR_SUP")
         RETURN FALSE
      END IF

      LET p_zz2_flag  = "E"

      SELECT cod_local_insp,
             cod_local_estoq,
             cod_lin_prod, 
             cod_lin_recei,
             cod_seg_merc, 
             cod_cla_uso             
        INTO p_cod_local_insp, p_cod_local_estoq, p_aen.*
        FROM logix@prd:item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_zz2.zz2_produt
      
      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET p_zz2_obs = 'PRODUTO INEXISTENTE'
         IF NOT pol1148_atualiza_zz2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF

      IF p_zz2.zz2_tpreg = 'OP' THEN
      ELSE
         IF p_zz2.zz2_tpreg <> 'AR' THEN
            LET p_zz2_obs = 'TIPO DE REGISTRO INVALIDO'
            IF NOT pol1148_atualiza_zz2() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
      END IF         

      IF p_zz2.zz2_tpreg = 'AR' THEN
      
         SELECT (qtd_rejeit + qtd_liber + qtd_liber_excep),                                               
                qtd_recebida,                                                                             
                ies_liberacao_insp,                                                                       
                num_aviso_rec,                                                                            
                num_oc,                                                                                   
                cod_local_estoq,                                                                          
                rowid                                                                                     
           INTO p_qtd_inspecionada,                                                                       
                p_qtd_recebida,                                                                           
                p_ies_liberacao_insp,                                                                     
                p_num_aviso_rec,                                                                          
                p_num_oc,                                                                                 
                p_cod_local_ar,                                                                           
                p_rowid_ar                                                                                
           FROM logix@prd:aviso_rec                                                                       
          WHERE cod_empresa   = p_cod_empresa                                                             
            AND num_aviso_rec = p_zz2.zz2_ar                                                              
            AND cod_item      = p_zz2.zz2_produt                                                          
            AND num_seq       = p_zz2.zz2_seqar                                                           
                                                                                                          
         IF SQLCA.SQLCODE = NOTFOUND THEN                                                                 
            LET p_zz2_obs = 'AR/PRODUTO/SEQUENCIA INEXISTENTE'                                            
            IF NOT pol1148_atualiza_zz2() THEN                                                            
               RETURN FALSE                                                                               
            ELSE                                                                                          
               CONTINUE FOREACH                                                                           
            END IF                                                                                        
         END IF                                                                                           
                                                                                                          
         IF p_cod_local_ar IS NOT NULL THEN                                                               
            IF p_cod_local_ar <> ' ' THEN                                                                 
               LET p_cod_local_insp = p_cod_local_ar                                                      
            END IF                                                                                        
         END IF                                                                                           
                                                                                                          
         IF p_ies_liberacao_insp = "S" THEN                                                               
            LET p_zz2_obs = 'Item: ', p_zz2.zz2_produt, ' Ja inspecionado'                                
            IF NOT pol1148_atualiza_zz2() THEN                                                            
               RETURN FALSE                                                                               
            ELSE                                                                                          
               CONTINUE FOREACH                                                                           
            END IF                                                                                        
         END IF                                                                                           
                                                                                                          
         SELECT cod_fornecedor                                                                            
           INTO p_cod_fornecedor                                                                          
           FROM logix@prd:nf_sup                                                                          
          WHERE cod_empresa   = p_cod_empresa                                                             
            AND num_aviso_rec = p_num_aviso_rec      

         SELECT fat_conver_unid                    
           INTO p_fator                            
           FROM logix@prd:ordem_sup                
          WHERE cod_empresa = p_cod_empresa        
            AND num_oc      = p_num_oc             
            AND ies_versao_atual = 'S'             
                                                   
         IF SQLCA.sqlcode = NOTFOUND THEN          
            LET p_fator = 1                        
         END IF                                    
                                                   
         IF p_fator = 0 OR p_fator IS NULL THEN    
            LET p_fator = 1                        
         END IF      
      ELSE                              
         LET p_fator = 1       
         LET p_zz2.zz2_ar    = p_zz2.zz2_numop
         LET p_zz2.zz2_seqar = 0                                             
      END IF
      
      LET p_qtd_pc_insp = (p_zz2.zz2_qtdlib + p_zz2.zz2_qtrej + p_zz2.zz2_qtexce)
      
      IF p_qtd_pc_insp = 0 THEN
         LET p_zz2_obs = 'SOMATORIA DAS QUANTIDADES INSPECIONADAS = 0'
         IF NOT pol1148_atualiza_zz2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
            
      SELECT *
        INTO p_estoque_lote.*
        FROM logix@prd:estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_zz2.zz2_produt
         AND cod_local     = p_cod_local_insp
         AND num_lote      = p_zz2.zz2_lote
         AND ies_situa_qtd = 'I'

      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_cod_local_insp = p_cod_local_estoq
         SELECT *
           INTO p_estoque_lote.*
           FROM logix@prd:estoque_lote
          WHERE cod_empresa   = p_cod_empresa
            AND cod_item      = p_zz2.zz2_produt
            AND cod_local     = p_cod_local_insp
            AND num_lote      = p_zz2.zz2_lote
            AND ies_situa_qtd = 'I'
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_zz2_obs = 'LOTE INEXISTENTE - ESTOQUE_LOTE'
            IF NOT pol1148_atualiza_zz2() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
      END IF

      SELECT *
        INTO p_estoque_lote_ender.*
        FROM logix@prd:estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_zz2.zz2_produt
         AND cod_local     = p_cod_local_insp
         AND num_lote      = p_zz2.zz2_lote
         AND ies_situa_qtd = 'I'
     
      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_zz2_obs = 'LOTE INEXISTENTE - ESTOQUE_LOTE_ENDER'
         IF NOT pol1148_atualiza_zz2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      LET p_qtd_pc_a_insp = p_estoque_lote.qtd_saldo
      
      IF p_qtd_pc_insp > p_qtd_pc_a_insp THEN
         LET p_difer = p_qtd_pc_insp - p_qtd_pc_a_insp
         IF p_difer >= 1 THEN
            LET p_zz2_obs = 'QUANTIDADE A INSPECIONAR > SALDO DO LOTE'
            IF NOT pol1148_atualiza_zz2() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
      END IF

      UPDATE logix@prd:estoque
         SET qtd_liberada  = qtd_liberada  + p_zz2.zz2_qtdlib,
             qtd_rejeitada = qtd_rejeitada + p_zz2.zz2_qtrej,
             qtd_lib_excep = qtd_lib_excep + p_zz2.zz2_qtexce,
             qtd_impedida  = qtd_impedida  - p_qtd_pc_insp
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_zz2.zz2_produt
      
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("ATUALIZA플O","ESTOQUE")
         RETURN FALSE
      END IF

      IF p_zz2.zz2_tpreg = 'AR' THEN      
         UPDATE logix@prd:aviso_rec                                                      
            SET qtd_liber          = qtd_liber       + (p_zz2.zz2_qtdlib / p_fator),      
                qtd_rejeit         = qtd_rejeit      + (p_zz2.zz2_qtrej / p_fator),      
                qtd_liber_excep    = qtd_liber_excep + (p_zz2.zz2_qtexce / p_fator),     
                ies_liberacao_insp = 'S',                                                
                ies_liberacao_cont = 'S',                                                
                ies_liberacao_ar   = '1',                                                
                ies_situa_ar       = 'E',                                                
                val_compl_estoque  = 0,                                                  
                cod_local_estoq    = p_cod_local_estoq                                   
          WHERE rowid = p_rowid_ar                                                       
                                                                                         
         IF SQLCA.SQLCODE <> 0 THEN                                                      
            CALL log003_err_sql("ATUALIZA플O","AVISO_REC")                               
            RETURN FALSE                                                                 
         END IF                                                                          
      END IF
      
      IF NOT pol1148_mov_estoque() THEN
         RETURN FALSE
      END IF

      LET p_zz2_flag  = "S"
      LET p_zz2_obs = 'Processo efetuado com sucesso'

      IF NOT pol1148_atualiza_zz2() THEN
         RETURN FALSE
      END IF
         
   END FOREACH
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1148_mov_estoque()
#-----------------------------#

   LET p_estoque_lote.qtd_saldo = p_estoque_lote.qtd_saldo -
       (p_zz2.zz2_qtdlib + p_zz2.zz2_qtrej + p_zz2.zz2_qtexce)
   
   IF p_estoque_lote.qtd_saldo >= 1 THEN
      UPDATE logix@prd:estoque_lote
         SET qtd_saldo = p_estoque_lote.qtd_saldo
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote.num_transac

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("AUTUALIZA플O","ESTOQUE_LOTE")
         RETURN FALSE
      END IF
         
      UPDATE logix@prd:estoque_lote_ender
         SET qtd_saldo = p_estoque_lote.qtd_saldo
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("AUTUALIZA플O","ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
   ELSE
      DELETE FROM logix@prd:estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote.num_transac

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELE플O","ESTOQUE_LOTE")
         RETURN FALSE
      END IF
         
      DELETE FROM logix@prd:estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELE플O","ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
   END IF

   LET p_count = 0
   
   IF p_zz2.zz2_qtdlib > 0 THEN
      LET p_estoque_lote.ies_situa_qtd = 'L'
      LET p_estoque_lote.qtd_saldo = p_zz2.zz2_qtdlib
      SELECT num_transac
        INTO p_num_transac
        FROM logix@prd:estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_zz2.zz2_produt
         AND cod_local     = p_cod_local_estoq
         AND num_lote      = p_zz2.zz2_lote
         AND ies_situa_qtd = 'L'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET p_estoque_lote.num_transac = 0
         IF NOT pol1148_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1148_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF p_zz2.zz2_qtrej > 0 THEN
      LET p_estoque_lote.ies_situa_qtd = 'R'
      LET p_estoque_lote.qtd_saldo = p_zz2.zz2_qtrej
      SELECT num_transac
        INTO p_num_transac
        FROM logix@prd:estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_zz2.zz2_produt
         AND cod_local     = p_cod_local_estoq
         AND num_lote      = p_zz2.zz2_lote
         AND ies_situa_qtd = 'R'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET p_estoque_lote.num_transac = 0
         IF NOT pol1148_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1148_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_zz2.zz2_qtexce > 0 THEN
      LET p_estoque_lote.ies_situa_qtd = 'E'
      LET p_estoque_lote.qtd_saldo = p_zz2.zz2_qtexce
      SELECT num_transac
        INTO p_num_transac
        FROM logix@prd:estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_zz2.zz2_produt
         AND cod_local     = p_cod_local_estoq
         AND num_lote      = p_zz2.zz2_lote
         AND ies_situa_qtd = 'E'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET p_estoque_lote.num_transac = 0
         IF NOT pol1148_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1148_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1148_insere_lote()
#-----------------------------#

   LET p_estoque_lote.cod_local = p_cod_local_estoq

   INSERT INTO logix@prd:estoque_lote
      VALUES(p_estoque_lote.*)
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUS홒","ESTOQUE_LOTE")
      RETURN FALSE
   END IF
      
   LET p_estoque_lote_ender.cod_local     = p_cod_local_estoq
   LET p_estoque_lote_ender.num_transac   = 0
   LET p_estoque_lote_ender.qtd_saldo     = p_estoque_lote.qtd_saldo
   LET p_estoque_lote_ender.ies_situa_qtd = p_estoque_lote.ies_situa_qtd
   INSERT INTO logix@prd:estoque_lote_ender
      VALUES(p_estoque_lote_ender.*)
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUS홒","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF
      
   LET p_endereco =   p_estoque_lote_ender.endereco 
      
   IF NOT pol1148_insere_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1148_atualiza_lote()
#-------------------------------#
   INITIALIZE p_endereco   TO  NULL 
   
   UPDATE logix@prd:estoque_lote
      SET qtd_saldo = qtd_saldo + p_estoque_lote.qtd_saldo
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("AUTUALIZA플O","ESTOQUE_LOTE")
      RETURN FALSE
   END IF

   SELECT num_transac, endereco
     INTO p_num_transac, p_endereco
     FROM logix@prd:estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_zz2.zz2_produt
      AND cod_local     = p_cod_local_estoq
      AND num_lote      = p_zz2.zz2_lote
      AND ies_situa_qtd = p_estoque_lote.ies_situa_qtd

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("LEITURA","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF
         
   UPDATE logix@prd:estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_estoque_lote.qtd_saldo
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("AUTUALIZA플O","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF

   
   IF NOT pol1148_insere_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#-----------------------------#
FUNCTION pol1148_insere_trans()
#-----------------------------#

#    LET  p_count = p_count + 1
    LET  p_estoque_trans.cod_empresa        = p_cod_empresa
    LET  p_estoque_trans.dat_movto          = TODAY
    LET  p_estoque_trans.dat_proces         = TODAY
    LET  p_estoque_trans.hor_operac         = TIME
    LET  p_estoque_trans.ies_tip_movto      = "N"
    LET  p_estoque_trans.cod_operacao       = p_cod_operacao
    LET  p_estoque_trans.cod_item           = p_zz2.zz2_produt
    LET  p_estoque_trans.num_transac        = 0
    LET  p_estoque_trans.num_prog           = "pol1148"
    LET  p_estoque_trans.num_docum          = p_zz2.zz2_ar
    LET  p_estoque_trans.num_seq            = p_zz2.zz2_seqar # p_count
    LET  p_estoque_trans.cus_unit_movto_p   =  0
    LET  p_estoque_trans.cus_tot_movto_p    =  0
    LET  p_estoque_trans.cus_unit_movto_f   =  0
    LET  p_estoque_trans.cus_tot_movto_f    =  0
    LET  p_estoque_trans.num_conta          =  NULL
    LET  p_estoque_trans.num_secao_requis   =  NULL
    LET  p_estoque_trans.cod_local_est_orig =  p_cod_local_insp
    LET  p_estoque_trans.cod_local_est_dest =  p_cod_local_estoq
    LET  p_estoque_trans.num_lote_orig      =  p_zz2.zz2_lote
    LET  p_estoque_trans.num_lote_dest      =  p_zz2.zz2_lote
    LET  p_estoque_trans.ies_sit_est_orig   =  "I"
    LET  p_estoque_trans.ies_sit_est_dest   =  p_estoque_lote.ies_situa_qtd
    LET  p_estoque_trans.cod_turno          =  NULL
    LET  p_estoque_trans.nom_usuario        =  p_user
    LET  p_estoque_trans.qtd_movto          =  p_estoque_lote.qtd_saldo
    LET  p_estoque_trans.dat_ref_moeda_fort =  TODAY     

    INSERT INTO logix@prd:estoque_trans VALUES (p_estoque_trans.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","ESTOQUE_TRANS")
         RETURN FALSE
      END IF       

     LET p_num_transac = SQLCA.SQLERRD[2]

     LET p_estoque_trans_end.cod_empresa = p_cod_empresa
     LET p_estoque_trans_end.num_transac = p_num_transac
     LET p_estoque_trans_end.endereco    = p_endereco
     LET p_estoque_trans_end.num_volume  = 0
     LET p_estoque_trans_end.qtd_movto = p_estoque_trans.qtd_movto
     LET p_estoque_trans_end.cod_grade_1 = " "
     LET p_estoque_trans_end.cod_grade_2 = " "
     LET p_estoque_trans_end.cod_grade_3 = " "
     LET p_estoque_trans_end.cod_grade_4 = " "
     LET p_estoque_trans_end.cod_grade_5 = " "
     LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.vlr_temperatura = 0
     LET p_estoque_trans_end.endereco_origem = " "
     LET p_estoque_trans_end.num_ped_ven = 0
     LET p_estoque_trans_end.num_seq_ped_ven = 0
     LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.num_peca = " "
     LET p_estoque_trans_end.num_serie = " "
     LET p_estoque_trans_end.comprimento = 0
     LET p_estoque_trans_end.largura = 0
     LET p_estoque_trans_end.altura = 0
     LET p_estoque_trans_end.diametro = 0
     LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.qtd_reserv_1 = 0
     LET p_estoque_trans_end.qtd_reserv_2 = 0
     LET p_estoque_trans_end.qtd_reserv_3 = 0
     LET p_estoque_trans_end.num_reserv_1 = 0
     LET p_estoque_trans_end.num_reserv_2 = 0
     LET p_estoque_trans_end.num_reserv_3 = 0
     LET p_estoque_trans_end.tex_reservado = " "
     LET p_estoque_trans_end.cus_unit_movto_p = 0
     LET p_estoque_trans_end.cus_unit_movto_f = 0
     LET p_estoque_trans_end.cus_tot_movto_p = 0
     LET p_estoque_trans_end.cus_tot_movto_f = 0
     LET p_estoque_trans_end.cod_item      = p_estoque_trans.cod_item
     LET p_estoque_trans_end.dat_movto     = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.cod_operacao  = p_estoque_trans.cod_operacao
     LET p_estoque_trans_end.dat_movto     = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.ies_tip_movto = p_estoque_trans.ies_tip_movto
     LET p_estoque_trans_end.num_prog = "pol1148"

     INSERT INTO logix@prd:estoque_trans_end
        VALUES (p_estoque_trans_end.*)

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSER플O","ESTOQUE_TRANS_END")
        RETURN FALSE
     END IF
     
     INSERT INTO logix@prd:est_trans_area_lin
        VALUES (p_cod_empresa, p_num_transac, p_aen.*)

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSER플O","est_trans_area_lin")
        RETURN FALSE
     END IF
     
    LET p_estoque_auditoria.cod_empresa = p_cod_empresa
    LET p_estoque_auditoria.num_transac = p_num_transac
    LET p_estoque_auditoria.nom_usuario = p_user
    LET p_estoque_auditoria.dat_hor_proces = CURRENT
    LET p_estoque_auditoria.num_programa = 'pol1148'
    
    INSERT INTO logix@prd:estoque_auditoria 
       VALUES(p_estoque_auditoria.*)

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSER플O","estoque_auditoria")
        RETURN FALSE
     END IF
   
   IF p_zz2.zz2_tpreg = 'AR' THEN
   
      SELECT num_transac                                              
        INTO p_num_transac_orig                                       
        FROM aviso_rec_estoque                                        
       WHERE cod_empresa   = p_cod_empresa                            
         AND num_aviso_rec = p_zz2.zz2_ar                             
         AND num_seq       = p_zz2.zz2_seqar                          
                                                                      
        IF SQLCA.SQLCODE = 0 THEN                                     
           INSERT INTO sup_mov_orig_dest                              
            VALUES(p_cod_empresa,                                     
                   p_num_transac_orig,                                
                   p_num_transac,                                     
                   "3")                                               
                                                                      
           IF SQLCA.SQLCODE <> 0 THEN                                 
              CALL log003_err_sql("INSER플O","sup_mov_orig_dest")     
              RETURN FALSE                                            
           END IF                                                     
        END IF                                                        
   
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1148_atualiza_zz2()
#-----------------------------#

   LET p_zz2_obs = p_zz2_obs CLIPPED, ' ', TODAY, ' ', TIME

   UPDATE dadosadv@prd:zz2010
      SET zz2_flag = p_zz2_flag,
          zz2_obs  = p_zz2_obs
    WHERE rowid = p_rowid
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("ATUALIZA플O","ZZ2")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#


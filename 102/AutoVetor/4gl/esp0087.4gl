#------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                  #
# PROGRAMA: ESP0087                                                            #
# MODULOS.: ESP0087                                                            #
# OBJETIVO: RECALCULAR AS DUPLICATAS DAS NOTAS NAO EMITIDAS                    #
# AUTOR...: POLO INFORMATICA                                                   #
# DATA....: 05/03/2004                                                         #
#Conversao: Thiago																														 #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa       CHAR(02),
          p_ies_processou     SMALLINT,
          comando             CHAR(80),
          p_cont              SMALLINT,
          p_num_dupl_or       SMALLINT,
          p_versao            CHAR(18),
          p_val_tot_dupl      LIKE nf_mestre.val_tot_mercadoria,
          p_dat_vencto_sd     LIKE nf_duplicata.dat_vencto_sd,
          p_dig_duplicata     LIKE nf_duplicata.dig_duplicata,
          p_val_duplic_st     LIKE nf_duplicata.val_duplic,
          p_fat_nf_mestre       RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_duplicata       RECORD LIKE fat_nf_duplicata.*,
          p_nf_duplicata      RECORD LIKE nf_duplicata.*,
          p_cond_pgto_item    RECORD LIKE cond_pgto_item.*,
          p_limite_dupl_vetor RECORD LIKE limite_dupl_vetor.* 

   DEFINE p_user              LIKE usuario.nom_usuario,
          p_val_tot_nff       DEC(15,3),
          p_val_tot_nff_or    DEC(15,3),
          p_val_tot_aux       CHAR(015),  
          p_nom_help          CHAR(200),
          p_nom_tela          CHAR(200),
          p_r                 CHAR(001),
          p_proc              CHAR(001),
          p_qtd_parcelas      SMALLINT,
          p_status            SMALLINT,
          p_ies_situa         SMALLINT,
          p_houve_erro        SMALLINT,
          p_dias              SMALLINT,
          p_i                 SMALLINT,
          p_data1             DATE,
          p_data2             DATE,
          p_data3             DATE,
          p_data4             DATE,
          p_data5             DATE,
          p_data              DATE,
          p_data_ini          DATE
END GLOBALS

   DEFINE p_count             SMALLINT
 
MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   CALL log0180_conecta_usuario()
   DEFER INTERRUPT 
   LET p_versao = "ESP0087-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0123.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      LET p_ies_processou = FALSE
      CALL esp0087_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION esp0087_controle()
#--------------------------#
DEFINE l_ies_st       	 CHAR(01),
       l_ies_sbs_trib 	 CHAR(01),
       l_count        	 INTEGER,
       l_prim         	 CHAR(01),
       l_val_tributo_tot LIKE fat_mestre_fiscal.val_tributo_tot

   INITIALIZE p_fat_nf_mestre.*,		#FAT_NF_MESTRE
              p_fat_nf_duplicata.*,		#FAT_NF_DUPLICATA
              p_nf_duplicata.*,
              p_limite_dupl_vetor.* TO NULL

   OPEN WINDOW w_esp0087 AT 2,6 WITH 10 ROWS, 70 COLUMNS
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY "RECALCULO DE DUPLICATAS" AT 1,23
   DISPLAY "------------------------------",
           "------------------------------",
           "----------" AT 2,1
   LET p_houve_erro = FALSE
   SELECT val_limite
      INTO p_limite_dupl_vetor.val_limite
   FROM limite_dupl_vetor 
   WHERE cod_empresa = p_cod_empresa

   DECLARE cq_notas CURSOR FOR 
   SELECT * FROM fat_nf_mestre
   WHERE empresa  = p_cod_empresa
     AND sit_impressao = "N"
   

   LET p_count = 1
   FOREACH cq_notas INTO p_fat_nf_mestre.*

      LET p_num_dupl_or = 1																			#verifica o numero de duplicatas referenta a uma
      SELECT count(*) 																					#nota fiscal
         INTO p_num_dupl_or
      FROM fat_nf_duplicata
      WHERE empresa = p_cod_empresa 
        AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal

      IF p_num_dupl_or <= 1 THEN
         CONTINUE FOREACH
      END IF

      
      DISPLAY "VERSAO :" AT 4,15
      DISPLAY p_versao AT 4,23
      DISPLAY "NOTA FISCAL     :" AT 5,5
      DISPLAY p_fat_nf_mestre.nota_fiscal AT 5,23

      LET p_val_tot_nff_or = p_fat_nf_mestre.val_nota_fiscal
      LET p_val_tot_nff = p_fat_nf_mestre.val_nota_fiscal
      LET p_count = 1

##      aquioooooo  checar se possui 
      SELECT COUNT(*)																		#parametro que verifica a tributa��o
        INTO l_count
        FROM obf_par_fisc_compl
       WHERE empresa           = p_cod_empresa 
         AND nat_oper_grp_desp = p_fat_nf_mestre.natureza_operacao
         AND campo             = 'cond_pgto_subst_trib'
      
      	SELECT SUM(VAL_TRIBUTO_TOT)
      	INTO l_val_tributo_tot
      	FROM FAT_MESTRE_FISCAL
				WHERE EMPRESA =p_cod_empresa
				AND TRIBUTO_BENEF = 'ICMS'
				AND TRANS_NOTA_FISCAL = p_fat_nf_mestre.trans_nota_fiscal
					
      IF l_count > 0 AND l_val_tributo_tot > 0 THEN 										###acertar aqui
         LET l_ies_sbs_trib = 'S'
      ELSE
         LET l_ies_sbs_trib = 'N'
      END IF       
      
      IF l_ies_sbs_trib = 'S' THEN   
         
         SELECT MIN(dat_vencto_sdesc) 
           INTO p_dat_vencto_sd
           FROM fat_nf_duplicata
          WHERE empresa  = p_cod_empresa 
            AND trans_nota_fiscal   = p_fat_nf_mestre.trans_nota_fiscal		## acertar aqui
            AND val_duplicata   = l_val_tributo_tot
            
         DECLARE cq_idd CURSOR FOR 
          SELECT seq_duplicata,val_duplicata
            FROM fat_nf_duplicata 
           WHERE empresa     = p_cod_empresa 
             AND trans_nota_fiscal         = p_fat_nf_mestre.trans_nota_fiscal
             AND dat_vencto_sdesc   = p_dat_vencto_sd
             AND val_duplicata      = l_val_tributo_tot
           ORDER BY val_duplicata   
         FOREACH cq_idd INTO p_dig_duplicata,p_val_duplic_st
           EXIT FOREACH
         END FOREACH
      ELSE
         LET p_val_duplic_st = 0
         LET p_dat_vencto_sd = '31/12/1899'
         LET p_dig_duplicata = 0
      END IF       
      
      LET p_val_tot_nff_or = p_val_tot_nff_or  - p_val_duplic_st

      IF l_ies_sbs_trib = 'N' THEN   
         DECLARE cq_dupl CURSOR FOR 
         SELECT * FROM fat_nf_duplicata
         WHERE empresa = p_cod_empresa 
           AND trans_nota_fiscal     = p_fat_nf_mestre.trans_nota_fiscal
         ORDER by seq_duplicata
         
         FOREACH cq_dupl INTO p_fat_nf_duplicata.*
         
            IF p_fat_nf_duplicata.seq_duplicata = 1 THEN 
               LET p_data_ini = p_fat_nf_duplicata.dat_vencto_sdesc
            END IF
            
            IF p_fat_nf_duplicata.val_duplicata <= p_limite_dupl_vetor.val_limite AND
               p_count = 1 THEN
               DISPLAY "DUPLICATA       :" AT 6,5
               DISPLAY p_fat_nf_duplicata.num_duplicata AT 6,23
               LET p_qtd_parcelas = p_val_tot_nff / p_limite_dupl_vetor.val_limite
               IF p_qtd_parcelas < 1 THEN
                  LET p_qtd_parcelas = 1
               ELSE
                  IF p_qtd_parcelas = 2 AND 
                     p_num_dupl_or <> 4 THEN
                     LET p_qtd_parcelas = 1
                  ELSE
                     IF p_qtd_parcelas = 3 AND 
                        p_num_dupl_or = 4 THEN
                        LET p_qtd_parcelas = 2
                     ELSE 
                        IF p_qtd_parcelas = 4 THEN 
                           LET p_qtd_parcelas = 3
                        ELSE 
                           IF p_qtd_parcelas > 5 THEN 
                              LET p_qtd_parcelas = 5
                           END IF
                        END IF
                     END IF
                  END IF
               END IF
               LET p_fat_nf_mestre.val_nota_fiscal = p_val_tot_nff / p_qtd_parcelas
               DISPLAY "VALOR DUPLICATA :" AT 7,5
               DISPLAY p_fat_nf_mestre.val_nota_fiscal USING "####,###,###,##&.&&" AT 7,23
               LET p_count = p_count + 1
            END IF
         
         END FOREACH
      ELSE
         LET l_prim = 'S'
         DECLARE cq_dupls CURSOR FOR 
         SELECT * FROM fat_nf_duplicata
         WHERE empresa = p_cod_empresa 
           AND trans_nota_fiscal     = p_fat_nf_mestre.trans_nota_fiscal         
           AND seq_duplicata <> p_dig_duplicata
         ORDER by seq_duplicata
         
         FOREACH cq_dupls INTO p_fat_nf_duplicata.*
         
            IF l_prim = 'S' THEN 
               LET p_data_ini = p_fat_nf_duplicata.dat_vencto_sdesc
            END IF
            
            LET l_prim = 'N'            
            
            IF p_fat_nf_duplicata.val_duplicata <= p_limite_dupl_vetor.val_limite AND
               p_count = 1 THEN
               DISPLAY "DUPLICATA       :" AT 6,5
               DISPLAY p_fat_nf_duplicata.num_duplicata AT 6,23
               LET p_qtd_parcelas = (p_val_tot_nff - p_val_duplic_st) / p_limite_dupl_vetor.val_limite
               LET p_qtd_parcelas = p_qtd_parcelas  + 1 
               IF p_qtd_parcelas < 1 THEN
                  LET p_qtd_parcelas = 1
               ELSE
                  IF p_qtd_parcelas = 2 AND 
                     p_num_dupl_or <> 4 THEN
                     LET p_qtd_parcelas = 1
                  ELSE
                     IF p_qtd_parcelas = 3 AND 
                        p_num_dupl_or = 4 THEN
                        LET p_qtd_parcelas = 2
                     ELSE 
                        IF p_qtd_parcelas = 4 THEN 
                           LET p_qtd_parcelas = 3
                        ELSE 
                           IF p_qtd_parcelas > 5 THEN 
                              LET p_qtd_parcelas = 5
                           END IF
                        END IF
                     END IF
                  END IF
               END IF
               LET p_fat_nf_mestre.val_nota_fiscal = (p_val_tot_nff - p_val_duplic_st) / p_qtd_parcelas
               DISPLAY "VALOR DUPLICATA :" AT 7,5
               DISPLAY p_val_tot_nff USING "####,###,###,##&.&&" AT 7,23
               LET p_count = p_count + 1
            END IF
         
         END FOREACH
      END IF    

      IF p_houve_erro = FALSE AND
         p_count > 1 THEN
         CALL esp0087_pega_datas() 
         IF esp0087_deleta_duplic() THEN
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF
         IF esp0087_insere_duplic() THEN
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF
      END IF

   END FOREACH

   IF p_count = 1 THEN
      PROMPT "Nao Existem Duplicatas a serem Processadas - Tecle <Enter>...!!!"
      FOR p_r
      RETURN
   END IF

   IF p_houve_erro THEN 
      PROMPT "Problemas Durante o Processamento - Tecle <Enter>...!!!"
      FOR p_r
   ELSE
      PROMPT "Processamento Executado Normalmente - Tecle <Enter>...!!!"
      FOR p_r
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION esp0087_pega_datas()#
#-----------------------------#
 DEFINE p_data_ent      DATE,
        p_num_pedido    LIKE pedidos.num_pedido,
        l_dias_med      DECIMAL(4,0) ,
        l_data_hor_emi	date 
 
 SELECT MAX(pedido)
   INTO p_num_pedido
   FROM fat_nf_item
  WHERE empresa = p_cod_empresa 
    AND trans_nota_fiscal   = p_fat_nf_mestre.trans_nota_fiscal
  
 SELECT MAX(prz_entrega)
   INTO p_data_ent
   FROM ped_itens 
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido = p_num_pedido 
    
  let l_data_hor_emi = p_fat_nf_mestre.dat_hor_emissao
 
 IF l_data_hor_emi > p_data_ent THEN  #data de emiss�o 10.2 � date time
    LET p_data_ent = p_fat_nf_mestre.dat_hor_emissao USING "dd/mm/yyyy"
 END IF   
 
 IF p_num_dupl_or = 4 AND 
    p_qtd_parcelas = 1 THEN
    SELECT AVG(qtd_dias_sd)
      INTO l_dias_med
      FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_fat_nf_mestre.cond_pagto
    LET p_data1 = p_data_ent + l_dias_med UNITS DAY
 ELSE  
   DECLARE cq_data CURSOR FOR 
    SELECT * FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_fat_nf_mestre.cond_pagto
   
   FOREACH cq_data INTO p_cond_pgto_item.*
   
			CASE 
				WHEN p_cond_pgto_item.sequencia = 1
					IF p_num_dupl_or = 5 AND p_qtd_parcelas = 3 THEN
						LET p_data1 = p_data_ent + p_cond_pgto_item.qtd_dias_sd  UNITS DAY
					END IF
				WHEN p_cond_pgto_item.sequencia = 2
					IF p_num_dupl_or = 3 AND p_qtd_parcelas = 1 THEN
						LET p_data1 = p_data_ent + p_cond_pgto_item.qtd_dias_sd  UNITS DAY
					ELSE 
						IF p_num_dupl_or = 4 AND p_qtd_parcelas = 2 THEN
							LET p_data1 = p_data_ent + p_cond_pgto_item.qtd_dias_sd UNITS DAY
						END IF 
					END IF
				WHEN p_cond_pgto_item.sequencia = 3
					IF p_num_dupl_or = 5 AND p_qtd_parcelas = 1 THEN
						LET p_data1 = p_data_ent + p_cond_pgto_item.qtd_dias_sd  UNITS DAY
					ELSE
						IF p_num_dupl_or = 5 AND p_qtd_parcelas = 3 THEN
							LET p_data2 = p_data_ent + p_cond_pgto_item.qtd_dias_sd  UNITS DAY
						END IF
					END IF 
				WHEN p_cond_pgto_item.sequencia = 4
					IF p_num_dupl_or = 4 AND p_qtd_parcelas = 2 THEN
						LET p_data2 = p_data_ent + p_cond_pgto_item.qtd_dias_sd UNITS DAY
					END IF
				WHEN p_cond_pgto_item.sequencia = 5
					IF p_num_dupl_or = 5 AND p_qtd_parcelas = 3 THEN
						LET p_data3 = p_data_ent + p_cond_pgto_item.qtd_dias_sd  UNITS DAY
					END IF
			END CASE

   END FOREACH
 END IF 
          
END FUNCTION

#-------------------------------#
 FUNCTION esp0087_deleta_duplic()
#-------------------------------#
 {
   DELETE FROM nf_duplicata
   WHERE cod_empresa     =  p_cod_empresa
     AND num_nff         =  p_fat_nf_mestre.trans_nota_fiscal
     AND dig_duplicata <> p_dig_duplicata 
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("DELECAO","NF_DUPLICATA")
      RETURN TRUE
   END IF
}
   DELETE FROM fat_nf_duplicata
   WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
     AND seq_duplicata <> p_dig_duplicata 
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("DELECAO","fat_nf_duplicata")
      RETURN TRUE
   END IF 

   RETURN FALSE
 
END FUNCTION

#-------------------------------#
 FUNCTION esp0087_insere_duplic()
#-------------------------------#
DEFINE l_ies_st  CHAR (01)

   LET p_val_tot_aux = p_val_tot_nff
 
###LET p_data = p_data_ini + p_dias UNITS DAY

   LET p_val_tot_dupl = 0
   LET l_ies_st = 'N'
 
   FOR p_i = 1 TO p_qtd_parcelas

     IF p_i <> p_dig_duplicata THEN

         IF p_i = p_qtd_parcelas THEN
            LET p_fat_nf_mestre.val_nota_fiscal = p_val_tot_nff_or - p_val_tot_dupl
         END IF 
         
         IF l_ies_st = 'N' THEN 
            IF p_i = 1 THEN 
               LET p_data = p_data1
            ELSE
               IF p_i = 2 THEN
                  LET p_data = p_data2
               ELSE
                  LET p_data = p_data3
               END IF
            END IF
         ELSE
            IF p_i = 2 THEN 
               LET p_data = p_data1
            ELSE
               IF p_i = 3 THEN
                  LET p_data = p_data2
               ELSE
                  LET p_data = p_data3
               END IF
            END IF    
         END IF  
         
         LET p_val_tot_dupl = p_val_tot_dupl + p_fat_nf_mestre.val_nota_fiscal
        
       {  INSERT INTO nf_duplicata
            VALUES (p_cod_empresa,
                    p_fat_nf_mestre.trans_nota_fiscal,
                    p_fat_nf_mestre.trans_nota_fiscal,
                    p_i,
                    0,
                    p_fat_nf_mestre.val_nota_fiscal,
                    p_data,
                    NULL,
                    0)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","NF_DUPLICATA")
            LET p_houve_erro = TRUE
            EXIT FOR
         END IF}
        
         INSERT INTO fat_nf_duplicata
            VALUES (p_cod_empresa,
                    p_fat_nf_mestre.trans_nota_fiscal,
                    p_i,
                    p_fat_nf_mestre.val_nota_fiscal,
                    NULL,
                    p_data,
                    0,
                    p_fat_nf_mestre.val_nota_fiscal,
                    NULL,
                    0,
                    ' ',
                    ' ',
                    NULL,
                    " ",
                    " "
                    )
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","fat_nf_duplicata")
            LET p_houve_erro = TRUE
            EXIT FOR
         END IF    
     ELSE
         LET l_ies_st = 'S'
         LET p_qtd_parcelas = p_qtd_parcelas  + 1
     END IF
      
   END FOR

   IF p_houve_erro THEN 
      RETURN TRUE  
   ELSE
      RETURN FALSE
   END IF
 
END FUNCTION
#------------------------------ FIM DE PROGRAMA -------------------------------#
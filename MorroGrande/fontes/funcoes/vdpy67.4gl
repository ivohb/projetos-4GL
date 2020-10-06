#-----------------------------------------------------------------#
# MODULO..: VDP                                                   #
# SISTEMA.: EPL ALTERAR DATA BASE DOS BOLETOS DE LOCACAO          #
# PROGRAMA: vdpy67                                              #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 20/05/2016                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS


#---------------------------------------------------#
 FUNCTION vdpy67_acerta_data_base_vencto_duplicata(l_cod_empresa, l_trans_nota_fiscal, l_dat_refer, l_modo_exibicao)
#---------------------------------------------------#
    DEFINE l_cod_empresa               LIKE empresa.cod_empresa
    DEFINE l_trans_nota_fiscal         LIKE fat_nf_mestre.trans_nota_fiscal
    DEFINE l_dat_refer                 DATE
    DEFINE l_dat_refer2 CHAR(10)
    DEFINE l_dat_refer3 DATE
    DEFINE l_verifica_mes CHAR(2)
    
    DEFINE l_dat_instal                DATE
    DEFINE l_modo_exibicao             SMALLINT
    DEFINE lr_fat_nf_mestre            RECORD LIKE fat_nf_mestre.*
    DEFINE l_dat_refer4 CHAR(2)
    DEFINE l_dat_refer44 INTEGER
    DEFINE lr_loc_faturado            RECORD
                 	cod_empresa char(2),
				   cod_contrato integer,
				   num_nf integer,
				   cod_cliente char(15),
				   cod_repres decimal(4,0),
				   data_process DATE,
				   periodo_de DATE,
				   periodo_ate DATE,
				   valor DECIMAL(20,2),
				   num_pedido decimal(6,0)
   
            END RECORD
    
    {SELECT *
      INTO lr_loc_faturado.*
      FROM geo_loc_faturado
     WHERE cod_empresa = l_cod_empresa
       AND num_pedido IN (SELECT DISTINCT b.pedido
                            FROM fat_nf_mestre a, fat_nf_item b
                           WHERE a.empresa = b.empresa
                             AND a.empresa = l_cod_empresa
                             AND a.trans_nota_fiscal = l_trans_nota_fiscal
                             AND a.trans_nota_fiscal = b.trans_nota_fiscal
                             AND a.sit_nota_fiscal = 'N'
                             AND b.seq_item_nf = 1)
    IF sqlca.sqlcode = 0 THEN
       SELECT dat_instal
         INTO l_dat_instal
         FROM geo_loc_mestre
        WHERE cod_empresa = l_cod_empresa
          AND cod_contrato = lr_loc_faturado.cod_contrato
          
       IF sqlca.sqlcode = 0 THEN
          LET l_dat_refer4 = EXTEND(l_dat_instal, DAY TO DAY)
          IF l_dat_refer4 = "31" THEN
             LET l_dat_refer4 = "30"
          END IF
          
          LET l_verifica_mes = EXTEND(TODAY, MONTH TO MONTH)
          IF l_verifica_mes = "2" OR l_verifica_mes = "02" THEN
             LET l_dat_refer44 = l_dat_refer4
             IF l_dat_refer44 > 28 THEN
             	LET l_dat_refer4 = "28"
             END IF
          END IF
          
          LET l_dat_refer2 = l_dat_refer4 USING "&&","/", EXTEND(TODAY, MONTH TO MONTH),"/",EXTEND(TODAY,YEAR TO YEAR)
          LET l_dat_refer3= l_dat_refer2
          RETURN TRUE, TRUE, l_dat_refer3
       END IF 
    END IF 
                 }            
    
    RETURN TRUE, FALSE, TODAY 
END FUNCTION


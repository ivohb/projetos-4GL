#------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                  #
# PROGRAMA: POL0470                                                            #
# MODULOS.: POL0470 - LOG0010 - LOG0040 - LOG0050 - LOG0060                    #
#           LOG0280 - LOG0380 - LOG1300 - LOG1400                              #
# OBJETIVO: ATUALIZACAO DA TABELA CTR_METAS_KANAFLEX (BATCH)                   #
# AUTOR...: POLO INFORMATICA                                                   #
# DATA....: 11/08/2006                                                         #
#------------------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_comando            CHAR(80),
          p_i                  SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
      #   p_versao             CHAR(17),               
          p_versao             CHAR(18),               
          p_status             SMALLINT,
          p_help               CHAR(080),
          p_nom_tela           CHAR(080),
          p_caminho            CHAR(080),
          p_r                  CHAR(001)
    

   DEFINE p_ctr_metas_kanaflex RECORD LIKE ctr_metas_kanaflex.*,
          p_fat_nf_mestre      RECORD LIKE fat_nf_mestre.*,   #Will - 25/10/10
          p_semana_siv         RECORD LIKE semana_siv.*,
          p_fat_nf_item        RECORD LIKE fat_nf_item.*,     #Will - 25/10/10
          p_pedidos            RECORD LIKE pedidos.*,
          p_dat_emissao        DATE,                          #Will - 25/10/10
          p_cod_repres         LIKE pedidos.cod_repres        #Will - 25/10/10

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ERROR STOP 
   SET ISOLATION TO DIRTY READ 
   DEFER INTERRUPT 
   LET p_versao = "POL0470-10.02.01"
   CALL log140_procura_caminho("pol0470.iem") RETURNING p_help    
   LET p_help = p_help CLIPPED
   OPTIONS
      HELP FILE p_help
  
#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN 
      CALL pol0470_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0470_controle()
#-------------------------#

   INITIALIZE p_ctr_metas_kanaflex.*,
              p_semana_siv.*,
              p_pedidos.*,
              p_fat_nf_mestre.*,       #Will - 25/10/10              
              p_fat_nf_item.* TO NULL  #Will - 25/10/10
  
   LET p_houve_erro = FALSE
   BEGIN WORK

   DECLARE cq_wfat CURSOR FOR
   SELECT * FROM fat_nf_mestre                  #Will - 25/10/10
   WHERE empresa       = p_cod_empresa          #Will - 25/10/10
     AND sit_impressao = "N"                    #Will - 25/10/10
     AND tip_nota_fiscal IN ("FATPRDSV" , "FATSERV")          #Ivo  = 25/10/10

   FOREACH cq_wfat INTO p_fat_nf_mestre.*

      SELECT COUNT(*)
      INTO p_count
      FROM ctr_stat_kanaflex
      WHERE cod_empresa = p_cod_empresa
        AND num_nff = p_fat_nf_mestre.nota_fiscal #Will - 25/10/10
 
      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF

      DECLARE cq_item CURSOR FOR
      SELECT pedido,                                                 #will - 25/10/10
             SUM(qtd_item),                                          #will - 25/10/10
             SUM(val_liquido_item)                                   #will - 25/10/10
        FROM fat_nf_item                                             #will - 25/10/10
       WHERE empresa = p_cod_empresa                                 #will - 25/10/10
         AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal   #will - 25/10/10      
       GROUP BY pedido

      FOREACH cq_item INTO p_fat_nf_item.pedido,
                           p_fat_nf_item.qtd_item,
                           p_fat_nf_item.val_liquido_item

         SELECT cod_tip_venda
            INTO 
                p_pedidos.cod_tip_venda
         FROM pedidos
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido = p_fat_nf_item.pedido
        
         IF SQLCA.SQLCODE <> 0 THEN
            CONTINUE FOREACH
         END IF
         
         LET p_dat_emissao = EXTEND(p_fat_nf_mestre.dat_hor_emissao, YEAR TO DAY) #Will - 25/10/10
         
         SELECT * 
            INTO p_semana_siv.* 
         FROM semana_siv
         WHERE dat_inicio <= p_dat_emissao  #Will - 25/10/10
           AND dat_fim    >= p_dat_emissao  #Will - 25/10/10
         
         IF SQLCA.SQLCODE <> 0 THEN 
            CONTINUE FOREACH
         END IF
         
         SELECT cod_repres                         #Will - 25/10/10
           INTO p_cod_repres                       #Will - 25/10/10
           FROM pedidos                            #Will - 25/10/10
          WHERE cod_empresa = p_cod_empresa        #Will - 25/10/10
            AND num_pedido  = p_fat_nf_item.pedido #Will - 25/10/10
         
         SELECT *
            INTO p_ctr_metas_kanaflex.*
         FROM ctr_metas_kanaflex
         WHERE cod_empresa = p_cod_empresa
           AND cod_repres =  p_cod_repres          #Will - 25/10/10
           AND ano_refer = p_semana_siv.ano_referencia
           AND mes_refer = p_semana_siv.mes_referencia
           AND sem_refer = p_semana_siv.num_semana
           AND cod_tip_venda = p_pedidos.cod_tip_venda
         
         IF SQLCA.SQLCODE = 0 THEN
            UPDATE ctr_metas_kanaflex
               SET val_realizada = val_realizada + p_fat_nf_item.val_liquido_item,  #Will - 25/10/10
                   qtd_realizada = qtd_realizada + p_fat_nf_item.qtd_item       #Will - 25/10/10
            WHERE cod_empresa = p_cod_empresa
              AND cod_repres = p_cod_repres        #Will - 25/10/10
              AND ano_refer = p_semana_siv.ano_referencia
              AND mes_refer = p_semana_siv.mes_referencia
              AND sem_refer = p_semana_siv.num_semana
              AND cod_tip_venda = p_pedidos.cod_tip_venda
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("ALTERACAO","CTR_METAS_KANAFLEX")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF
         ELSE
            LET p_ctr_metas_kanaflex.cod_empresa = p_cod_empresa
            LET p_ctr_metas_kanaflex.cod_repres = p_cod_repres                       #Will - 25/10/10
            LET p_ctr_metas_kanaflex.ano_refer = p_semana_siv.ano_referencia
            LET p_ctr_metas_kanaflex.mes_refer = p_semana_siv.mes_referencia
            LET p_ctr_metas_kanaflex.sem_refer = p_semana_siv.num_semana
            LET p_ctr_metas_kanaflex.cod_tip_venda = p_pedidos.cod_tip_venda
            LET p_ctr_metas_kanaflex.val_origem = 0
            LET p_ctr_metas_kanaflex.qtd_origem = 0
            LET p_ctr_metas_kanaflex.val_remanejada = 0
            LET p_ctr_metas_kanaflex.qtd_remanejada = 0
            LET p_ctr_metas_kanaflex.val_realizada = p_fat_nf_item.val_liquido_item  #Will - 25/10/10
            LET p_ctr_metas_kanaflex.qtd_realizada = p_fat_nf_item.qtd_item          #Will - 25/10/10
            INSERT INTO ctr_metas_kanaflex
               VALUES (p_ctr_metas_kanaflex.*)
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","CTR_METAS_KANAFLEX")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF
         END IF

      END FOREACH

      IF p_houve_erro THEN
         EXIT FOREACH
      END IF

      IF p_houve_erro = FALSE THEN
         INSERT INTO ctr_stat_kanaflex
            VALUES (p_cod_empresa,
                    p_fat_nf_mestre.nota_fiscal,   #Will - 25/10/10
                    "N")
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","CTR_STAT_KANAFLEX")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF
      END IF

   END FOREACH

   IF p_houve_erro THEN
      ROLLBACK WORK
   ELSE
      COMMIT WORK
   END IF

END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
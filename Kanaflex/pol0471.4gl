#---------------------------------------------------------------------------#  
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: POL0471                                                         #
# MODULOS.: POL0471 - LOG0010 - LOG0030 - LOG0040 - LOG0050                 #
#           LOG0280 - LOG1200 - LOG1300 - LOG1400 - LOG1500                 #
# OBJETIVO: CANCELAMENTO DE REPRESENTANTES                                  #
# DATA....: 14/08/2006                                                      #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_ies_situacao       LIKE fat_nf_mestre.sit_nota_fiscal,
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(80),
          comando              CHAR(80),
          p_houve_erro         SMALLINT,
          p_status             SMALLINT,
          p_ies_cons           SMALLINT,
          p_count              SMALLINT,
          p_i                  SMALLINT,
          p_msg                CHAR(100)

   DEFINE p_fat_nf_item        RECORD LIKE fat_nf_item.*,            #Will - 25/10/10
          p_fat_nf_mestre      RECORD LIKE fat_nf_mestre.*,          #Will - 25/10/10
          p_ctr_metas_kanaflex RECORD LIKE ctr_metas_kanaflex.*,
          p_pedidos            RECORD LIKE pedidos.*,
          p_semana_siv         RECORD LIKE semana_siv.*,
          p_dat_emissao        DATE,                                 #Will - 25/10/10 
          p_trans_nota_fiscal  LIKE fat_nf_mestre.trans_nota_fiscal, #Will - 25/10/10
          p_cod_repres         LIKE pedidos.cod_repres               #Will - 25/10/10

#  DEFINE p_versao    CHAR(17)
   DEFINE p_versao    CHAR(18)
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0471-10.02.04"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   CALL log140_procura_caminho("pol0471.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0471_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0471_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0471") RETURNING comando    
   OPEN WINDOW w_pol0471 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros de Entrada"
         HELP 0009
         MESSAGE ""
            IF pol0471_entrada_parametros() THEN
               ERROR 'Parâmetros informados com sucesso!'
               NEXT OPTION "Cancelar"
            ELSE
               ERROR 'Operação cancelada!'
            END IF
      COMMAND "Cancelar" "Cancelar Representantes"
         HELP 0010
            IF p_ies_cons THEN
               IF pol0471_cancela_repres() THEN
                  NEXT OPTION "Fim"
               END IF
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
               NEXT OPTION "Informar"
            END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0471_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0471

END FUNCTION

#-----------------------------------#
FUNCTION pol0471_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0471


   INITIALIZE p_fat_nf_item.*,        #will - 25/10/10
              p_fat_nf_mestre.*,      #will - 25/10/10
              p_ctr_metas_kanaflex.*,
              p_pedidos.*,
              p_semana_siv.* TO NULL
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE

   INPUT BY NAME p_fat_nf_mestre.nota_fiscal, 
        p_fat_nf_mestre.serie_nota_fiscal, 
        p_fat_nf_mestre.subserie_nf   WITHOUT DEFAULTS

      AFTER FIELD nota_fiscal  
      
         IF p_fat_nf_mestre.nota_fiscal IS NULL THEN  #will - 25/10/10
            ERROR "Informe o número da nota"
            NEXT FIELD nota_fiscal 
         END IF       

      AFTER FIELD serie_nota_fiscal  
      
         IF p_fat_nf_mestre.serie_nota_fiscal IS NULL THEN  
            ERROR "Informe a série da nota"
            NEXT FIELD serie_nota_fiscal 
         END IF       
        
      AFTER FIELD subserie_nf  
      
         IF p_fat_nf_mestre.subserie_nf IS NULL THEN  
            ERROR "Informe a série da nota"
            NEXT FIELD subserie_nf 
         END IF       

   
      AFTER INPUT

				IF NOT INT_FLAG THEN
				
         SELECT sit_nota_fiscal,                                #will - 25/10/10
                dat_hor_emissao,                                #will - 25/10/10
                trans_nota_fiscal                               #will - 25/10/10
           INTO p_ies_situacao,                                 #will - 25/10/10
                p_fat_nf_mestre.dat_hor_emissao,                #will - 25/10/10
                p_trans_nota_fiscal                             #will - 25/10/10
           FROM fat_nf_mestre                                   #will - 25/10/10
          WHERE empresa         = p_cod_empresa                 #will - 25/10/10
            AND sit_nota_fiscal = "C"                           #will - 25/10/10
            AND nota_fiscal     = p_fat_nf_mestre.nota_fiscal   #will - 25/10/10
            AND tip_nota_fiscal IN ("FATPRDSV" , "FATSERV") 
            AND serie_nota_fiscal = p_fat_nf_mestre.serie_nota_fiscal
            AND subserie_nf = p_fat_nf_mestre.subserie_nf
         
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Nota Fiscal nao Cancelada"
            NEXT FIELD nota_fiscal 
         END IF
                         
         SELECT *
         FROM ctr_stat_kanaflex
         WHERE cod_empresa = p_cod_empresa
           AND num_nff     = p_fat_nf_mestre.nota_fiscal   #will - 25/10/10
           AND ies_situa   = "C"
           AND ser_nf = p_fat_nf_mestre.serie_nota_fiscal
           AND sser_nf = p_fat_nf_mestre.subserie_nf
         
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Nota Fiscal Ja Processada"
            NEXT FIELD nota_fiscal 
         END IF

       END IF
      
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0471

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN FALSE
   END IF

   LET p_ies_cons = TRUE 
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0471_cancela_repres()
#--------------------------------#    

   BEGIN WORK

   DECLARE cq_item CURSOR FOR
   SELECT pedido,                                  #will - 25/10/10
          SUM(qtd_item),                           #will - 25/10/10
          SUM(val_liquido_item)                    #will - 25/10/10
    FROM fat_nf_item                               #will - 25/10/10
   WHERE empresa           = p_cod_empresa         #will - 25/10/10
     AND trans_nota_fiscal = p_trans_nota_fiscal   #will - 25/10/10  
   GROUP BY pedido

   FOREACH cq_item INTO p_fat_nf_item.pedido,
                        p_fat_nf_item.qtd_item,
                        p_fat_nf_item.val_liquido_item

      SELECT cod_tip_venda,
             cod_repres
        INTO p_pedidos.cod_tip_venda,
             p_cod_repres
       FROM pedidos
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido = p_fat_nf_item.pedido
      
      IF SQLCA.SQLCODE <> 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET p_dat_emissao = EXTEND(p_fat_nf_mestre.dat_hor_emissao, YEAR TO DAY) #Will - 25/10/10
      
      SELECT * 
         INTO 
             p_semana_siv.* 
      FROM semana_siv
      WHERE dat_inicio <= p_dat_emissao   #Will - 25/10/10
        AND dat_fim    >= p_dat_emissao   #Will - 25/10/10
      
      IF SQLCA.SQLCODE <> 0 THEN
         CONTINUE FOREACH
      END IF
            
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
            SET val_realizada = val_realizada - p_fat_nf_item.val_liquido_item,
                qtd_realizada = qtd_realizada - p_fat_nf_item.qtd_item
         WHERE cod_empresa = p_cod_empresa
           AND cod_repres =  p_cod_repres       #Will - 25/10/10
           AND ano_refer = p_semana_siv.ano_referencia
           AND mes_refer = p_semana_siv.mes_referencia
           AND sem_refer = p_semana_siv.num_semana
           AND cod_tip_venda = p_pedidos.cod_tip_venda
         
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("ALTERACAO","CTR_METAS_KANAFLEX")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF
      END IF

   END FOREACH

   IF p_houve_erro = FALSE THEN
   
      INSERT INTO ctr_stat_kanaflex(      
         cod_empresa,
         num_nff,
         ies_situa,
         ser_nf,
         sser_nf)      
         VALUES (p_cod_empresa,
                 p_fat_nf_mestre.nota_fiscal,'C',
                 p_fat_nf_mestre.serie_nota_fiscal,
                 p_fat_nf_mestre.subserie_nf)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","CTR_STAT_KANAFLEX")
         LET p_houve_erro = TRUE
      END IF
   END IF

   IF p_houve_erro THEN
      ROLLBACK WORK
      RETURN FALSE
   ELSE
      COMMIT WORK
      MESSAGE "Meta Atualizada com Sucesso...!!!" ATTRIBUTE(REVERSE)
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0471_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
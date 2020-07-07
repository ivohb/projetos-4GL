#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: POL0136                                                 #
# MODULOS.: POL0136 LOG0010 LOG0030 LOG0050 LOG0060 LOG0130 LOG0280 #
# OBJETIVO: CONSISTE NOTAS FISCAIS DA CAIRU                         #
# CLIENTE.: CAIRU                                                   #
# DATA....: 18/01/2001                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
       	 p_user              LIKE usuario.nom_usuario,
       	 p_status            SMALLINT,
       	 comando             CHAR(80),
         p_num_programa      CHAR(007),
       	 p_nom_arquivo       CHAR(100),
       	 p_den_empresa       LIKE empresa.den_empresa,
       	 p_msg                CHAR(500)

# DEFINE  p_versao  CHAR(17) #Favor Nao Alterar esta linha (SUPORTE)
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

 END GLOBALS



 DEFINE p_aviso_rec        LIKE nf_sup.num_aviso_rec,
        p_cod_item         LIKE item.cod_item,
       	p_ies_tip_item     LIKE item.ies_tip_item,
        p_num_ar           LIKE aviso_rec.num_aviso_rec

MAIN
  CALL log0180_conecta_usuario()
	LET p_versao = "pol0136-10.02.00"
  LET p_num_programa = "POL0136"                       
  WHENEVER ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
  WHENEVER ERROR STOP
                       
  DEFER INTERRUPT
                       
  CALL log130_procura_caminho("sup.iem") RETURNING comando
  OPTIONS
    FIELD ORDER UNCONSTRAINED,
    HELP FILE comando

  LET p_num_ar = arg_val(1)

# CALL log001_acessa_usuario("SUPRIMEN")
  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol036_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol036_controle()
#--------------------------#

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("cto0180") RETURNING comando

   DECLARE ct_ar     CURSOR FOR
   SELECT nf_sup.num_aviso_rec  FROM aviso_rec_compl,  nf_sup  
    WHERE nf_sup.cod_empresa = p_cod_empresa                  AND          
          aviso_rec_compl.cod_empresa=nf_sup.cod_empresa      AND 
          aviso_rec_compl.num_aviso_rec=nf_sup.num_aviso_rec  AND 
          aviso_rec_compl.ies_situacao="C"                    AND
          nf_sup.ies_nf_com_erro="S" 
          

 FOREACH ct_ar INTO p_aviso_rec
       

   IF sqlca.sqlcode = 0        
   THEN
      DELETE   FROM nf_sup_erro 
       WHERE num_aviso_rec=p_aviso_rec
      
        IF sqlca.sqlcode = 0          THEN
           UPDATE nf_sup   SET ies_nf_com_erro="N" 
            WHERE cod_empresa=p_cod_empresa
              AND num_aviso_rec=p_aviso_rec
           IF sqlca.sqlcode <>  0
           THEN
              CALL log003_err_sql("UPDATE","NF_SUP")
              EXIT FOREACH  
           END IF
        END IF
   END IF
 END FOREACH  


END FUNCTION


#-----------------------#
 FUNCTION pol0136_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

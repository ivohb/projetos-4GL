#-----------------------------------------------------------------#
# MODULO..: VDP                                                   #
# SISTEMA.: EPL PARA GRAVAR NUMERO DA REMESSA PARA CONTROLE DE SALDO #
# PROGRAMA: vdp0747y                                              #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 24/02/2016                                            #
#-----------------------------------------------------------------#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS
    

{#-------------------------------#
 FUNCTION vdp0747y_after_commit()
#-------------------------------#
   DEFINE l_empresa LIKE fat_nf_mestre.empresa
   DEFINE l_usuario LIKE usuarios.cod_usuario
   DEFINE l_trans_nota_fiscal LIKE fat_nf_mestre.trans_nota_fiscal
   DEFINE l_modo_exibicao SMALLINT
   DEFINE l_msg CHAR(999)
   DEFINE l_cod_repres decimal(4,0)
   DEFINE lr_remessa RECORD
               cod_empresa char(2),
			   num_remessa integer,
			   ser_remessa char(3),
			   trans_remessa integer,
			   sit_remessa CHAR(1),
			   tipo_movto char(1),
			   transportadora varchar(15),
			   cod_item char(15),
			   qtd_movto decimal(20,5),
			   num_nf integer,
			   ser_nf char(3),
			   trans_nota_fiscal integer
		 END RECORD
   
   LET l_empresa = LOG_getVar("empresa")
   LET l_usuario = LOG_getVar("usuario")
   LET l_trans_nota_fiscal = LOG_getVar("trans_nota_fiscal")
   LET l_modo_exibicao = LOG_getVar("modo_exibicao")
   
   DECLARE cq_remessa CURSOR WITH HOLD FOR 
   SELECT a.empresa, a.nota_fiscal, a.serie_nota_fiscal, a.trans_nota_fiscal,
          "A", "E", a.transportadora, b.item, b.qtd_item
     FROM fat_nf_mestre a, fat_nf_item b
    WHERE a.empresa = b.empresa
      AND a.trans_nota_fiscal = b.trans_nota_fiscal
      AND a.empresa = l_empresa
      AND a.trans_nota_fiscal = l_trans_nota_fiscal
      AND a.natureza_operacao = '10'
   
   
   FOREACH cq_remessa INTO lr_remessa.*
      
      select a.cod_repres
        INTO l_cod_repres
		from representante a, clientes b
       where a.num_cgc = b.num_cgc_cpf
		 AND b.cod_cliente = lr_remessa.transportadora
      if sqlca.sqlcode <> 0 THEN
         CALL log0030_mensagem("Representante não encontrado","excl")
         EXIT FOREACH
      END IF
      LET lr_remessa.transportadora = l_cod_repres
      INSERT INTO geo_remessa_movto VALUES (lr_remessa.*)
      
   END FOREACH
   
END FUNCTION


#------------------------------------------#
FUNCTION vdp0747y_after_efetiva_nota_fiscal()
#------------------------------------------#
   DEFINE l_empresa LIKE fat_nf_mestre.empresa
   DEFINE l_usuario LIKE usuarios.cod_usuario
   DEFINE l_trans_nota_fiscal LIKE fat_nf_mestre.trans_nota_fiscal
   DEFINE l_modo_exibicao SMALLINT
   DEFINE l_msg CHAR(999)
   DEFINE l_transportadora char(15)
   DEFINE l_cod_repres decimal(4,0)
   
   LET l_empresa = LOG_getVar("empresa")
   LET l_usuario = LOG_getVar("usuario")
   LET l_trans_nota_fiscal = LOG_getVar("trans_nota_fiscal")
   LET l_modo_exibicao = LOG_getVar("modo_exibicao")
   
   SELECT a.transportadora
     INTO l_transportadora
     FROM fat_nf_mestre a
    WHERE a.empresa = l_empresa
      AND a.trans_nota_fiscal = l_trans_nota_fiscal
      AND a.natureza_operacao = '10'
   
   IF sqlca.sqlcode = 0 THEN
      select a.cod_repres
        INTO l_cod_repres
		from representante a, clientes b
       where a.num_cgc = b.num_cgc_cpf
		 AND b.cod_cliente = l_transportadora
      if sqlca.sqlcode <> 0 THEN
         CALL log0030_mensagem("Representante não encontrado","excl")
         RETURN FALSE
      END IF
   END IF 
   RETURN TRUE
END FUNCTION}
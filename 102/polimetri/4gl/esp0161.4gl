#------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                  #
# PROGRAMA: ESP0161                                                            #
# MODULOS.: ESP0161                                                            #
# OBJETIVO: GERACAO DA TABELA EST_HIST_POLIMETRI                               #
# AUTOR...: POLO INFORMATICA                                                   #
# DATA....: 27/07/2005                                                         #
#------------------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
          p_user              LIKE usuario.nom_usuario,
          comando             CHAR(80),
          p_count             SMALLINT,
      #   p_versao            CHAR(17),               
          p_versao            CHAR(18),
          p_nom_help          CHAR(200),
          p_nom_tela          CHAR(200),
          p_status            SMALLINT,
          p_houve_erro        SMALLINT
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT 
   LET p_versao = "ESP0161-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("esp0161.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL esp0161_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0161_controle()
#--------------------------#

   IF esp0161_cria_tabela() THEN
      INSERT INTO est_hist_polimetri
      SELECT * FROM estoque_hist
      WHERE cod_empresa = p_cod_empresa
   END IF
      
END FUNCTION  

#-----------------------------#
 FUNCTION esp0161_cria_tabela()
#-----------------------------#

   WHENEVER ERROR CONTINUE

   DROP TABLE est_hist_polimetri;

   CREATE TABLE est_hist_polimetri
     (
      cod_empresa char(2) not null,
      cod_item char(15) not null,
      mes_ref decimal(2,0) not null,
      ano_ref decimal(4,0) not null,
      ano_mes_ref decimal(6,0) not null,
      qtd_entrada decimal(15,3) not null,
      qtd_saida decimal(15,3) not null,
      qtd_mes_ant decimal(15,3) not null,
      cus_unit_medio decimal(17,6) not null,
      cus_unit_forte decimal(17,6) not null,
      cus_unit_medio_rep decimal(17,6) not null,
      cus_unit_forte_rep decimal(17,6) not null
     );
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA EST_HIST_POLIMETRI")
      RETURN FALSE
   END IF                                                                      

   RETURN TRUE  
    
END FUNCTION  
#------------------------------ FIM DE PROGRAMA -------------------------------#

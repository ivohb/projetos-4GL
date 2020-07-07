#-----------------------------------------------------------------#
# PROGRAMA: pol0799                                               #
# OBJETIVO: Limpeza de base de dados                              #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS 
   DEFINE p_empresas_885             RECORD LIKE empresas_885.*,
          p_cod_empresa              LIKE empresa.cod_empresa,
          p_den_empresa              LIKE empresa.den_empresa,
          p_user                     LIKE usuario.nom_usuario, 
          p_ies_cons                 SMALLINT,
          p_last_row                 SMALLINT,
          p_conta                    SMALLINT,
          p_cont                     SMALLINT,
          pa_curr                    SMALLINT,
          sc_curr                    SMALLINT,
          p_status                   SMALLINT,
          p_funcao                   CHAR(15),
          p_houve_erro               SMALLINT, 
          p_comando                  CHAR(80),
          p_caminho                  CHAR(80),
          p_help                     CHAR(80),
          p_erro                     CHAR(01),
          p_cancel                   INTEGER,
          p_nom_tela                 CHAR(80),
          p_mensag                   CHAR(200),
          w_i                        SMALLINT,
          p_i                        SMALLINT

   DEFINE p_tela             RECORD
      nom_tabela          CHAR(30)  
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0799-05.10.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0799_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0799_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0799") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0799 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Processa" "Limpeza historico banco de dados"
         HELP 2010
         MESSAGE ""
         CALL pol0799_processa()                     
         IF p_ies_cons THEN 
            NEXT OPTION "Fim"
         END IF
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
         
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0799

END FUNCTION

#--------------------------#
 FUNCTION pol0799_processa()
#--------------------------#
 
   CLEAR FORM
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0799
   
   #BEGIN WORK
   CALL log085_transacao("BEGIN")

   DECLARE c_emp CURSOR FOR
   SELECT cod_emp_gerencial
     FROM empresas_885
   ORDER BY cod_emp_gerencial
   
   FOREACH c_emp INTO p_empresas_885.cod_emp_gerencial

      DELETE FROM empresa WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM usuario_empresa WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM path_logix_v2 WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM nf_mestre  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM wfat_mestre  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM nf_item  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM wfat_item  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM nf_item_fiscal  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM wfat_item_fiscal  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM nf_duplicata  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM wfat_duplic  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM nf_movto_dupl  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM docum  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM docum_txt  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM docum_pgto  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM docum_pgto_txt  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM adocum  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM docum_abat  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM docum_banco  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM docum_banco_txt  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM docum_emis  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM docum_escr  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM ad_mestre  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM ap  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM ad_ap  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
     
      DELETE FROM ap_obser  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM audit_vdp  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM audit_cap  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM item  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

      DELETE FROM item_vdp  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      DELETE FROM item_sup  WHERE cod_empresa = p_empresas_885.cod_emp_gerencial      
      
      DELETE FROM item_man WHERE cod_empresa = p_empresas_885.cod_emp_gerencial      
      
      DELETE FROM estoque WHERE cod_empresa = p_empresas_885.cod_emp_gerencial            
      
      DELETE FROM estoque_lote WHERE cod_empresa = p_empresas_885.cod_emp_gerencial            

      DELETE FROM estoque_lote_ender WHERE cod_empresa = p_empresas_885.cod_emp_gerencial            
      
      DELETE FROM estoque_trans WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                  

      DELETE FROM funcionario WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                  
      
      DELETE FROM movto WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                        

      DELETE FROM hist_movto WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                        

      DELETE FROM hist_funcio WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                        

      DELETE FROM ultimo_proces WHERE cod_empresa = p_empresas_885.cod_emp_gerencial                        
      
   END FOREACH

   DELETE FROM empresas_885

   #COMMIT WORK 
   CALL log085_transacao("COMMIT")

   ERROR "Limpeza encerrada"
 
END FUNCTION

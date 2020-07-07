#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0975                                                 #
# OBJETIVO: ATUALIZAÇÃO DE TRANSFERÊNCIAS DO LOGIX                  #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 29/09/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT
         
  
   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*
   
   DEFINE p_estoque_trans_end  RECORD LIKE estoque_trans_end.*
   
   DEFINE p_erro               CHAR(100),
          p_nom_aud_usuario    LIKE estoque_auditoria.nom_usuario,
          p_dat_aud_hor_proces LIKE estoque_auditoria.dat_hor_proces,
          p_num_aud_programa   LIKE estoque_auditoria.num_programa,
          p_num_transac        LIKE estoque_trans.num_transac 

                    
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0975-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0975_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0975_controle()
#--------------------------#
   
   IF NOT pol0975_le_empresa_ofic() THEN
      RETURN
   END IF
   
   CALL pol0975_processar() 

END FUNCTION

#---------------------------------#
 FUNCTION pol0975_le_empresa_ofic()
#---------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
   ELSE
      IF STATUS <> 100 THEN
         LET p_estoque_trans.num_transac = 0
         LET p_erro = 'Erro: ',STATUS, 'Lendo tabela empresas_885 !'
         IF NOT pol0975_grava_erro() THEN   
            RETURN FALSE
         END IF 
         RETURN FALSE 
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         
         IF STATUS <> 0 THEN
            LET p_estoque_trans.num_transac = 0
            LET p_erro = 'Erro: ',STATUS, 'Lendo tabela empresas_885 !'
            IF NOT pol0975_grava_erro() THEN   
               RETURN FALSE
            END IF 
            RETURN FALSE 
         ELSE
            LET p_cod_emp_ger = p_cod_empresa
            LET p_cod_empresa = p_cod_emp_ofic
         END IF
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#---------------------------#
 FUNCTION pol0975_processar()
#---------------------------#
   
   DECLARE cq_estoque_trans CURSOR FOR 
         
   SELECT *
     FROM estoque_trans
    WHERE cod_empresa  = p_cod_emp_ofic
      AND cod_operacao = 'TRAN'
      AND num_transac NOT IN
          (SELECT num_transac FROM transf_proces_885
            WHERE cod_empresa = p_cod_emp_ofic)
      
   FOREACH cq_estoque_trans INTO p_estoque_trans.*
   
      IF STATUS <> 0 THEN 
         LET p_erro = 'Erro: ',STATUS, 'Lendo cursor cq_estoque_trans !'
         IF NOT pol0975_grava_erro() THEN 
            RETURN
         END IF 
         RETURN 
      END IF 
  
      CALL log085_transacao("BEGIN")
      
      IF NOT pol0975_transfere() THEN
         CALL log085_transacao("ROLLBACK")
         IF NOT pol0975_grava_erro() THEN
            RETURN
         END IF
         RETURN 
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH 
   
   RETURN  
  
END FUNCTION 

#---------------------------#
FUNCTION pol0975_grava_erro()
#---------------------------#

   INSERT INTO transf_erro_885 
        VALUES(p_cod_emp_ofic, 
               p_estoque_trans.num_transac, 
               p_erro)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
                
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0975_transfere()
#---------------------------#
  
  IF NOT pol0975_inseri_estoque_trans() THEN 
     RETURN FALSE 
  END IF 
  
  IF NOT pol0975_inseri_estoque_trans_end() THEN 
     RETURN FALSE 
  END IF
  
  IF NOT pol0975_inseri_estoque_auditoria() THEN 
     RETURN FALSE 
  END IF
  
  IF NOT pol0975_atualiza_estoque() THEN 
     RETURN FALSE 
  END IF
    
  RETURN TRUE  
   
END FUNCTION 

#--------------------------------------#
 FUNCTION pol0975_inseri_estoque_trans()
#--------------------------------------#
   
   LET p_estoque_trans.hor_operac  = TIME 
   LET p_estoque_trans.num_prog    = 'POL0975'
       
   INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_cod_emp_ger,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)
          
      IF STATUS <> 0 THEN 
         LET p_erro = 'Erro: ',STATUS, 'Inserindo tabela estoque_trans !'
         IF NOT pol0975_grava_erro() THEN   
            RETURN FALSE
         END IF 
         RETURN FALSE   
      END IF 
      
      LET p_num_transac = SQLCA.SQLERRD[2]
      
   RETURN TRUE 
   
END FUNCTION  

#------------------------------------------#
 FUNCTION pol0975_inseri_estoque_trans_end()
#------------------------------------------#
   
   IF NOT pol0975_le_estoque_trans_end() THEN 
      RETURN FALSE 
   END IF 
   
   LET p_estoque_trans_end.num_prog = 'POL0975'
   
   INSERT INTO estoque_trans_end(
          cod_empresa,
          num_transac,
          endereco,
          num_volume,
          qtd_movto,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_prod_ini,
          dat_hor_prod_fim,
          vlr_temperatura,
          endereco_origem,
          num_ped_ven,
          num_seq_ped_ven,
          dat_hor_producao,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          dat_reserv_1,
          dat_reserv_2,
          dat_reserv_3,
          num_reserv_1,   
          num_reserv_2,
          num_reserv_3,
          tex_reservado,
          cus_unit_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_p,
          cus_tot_movto_f,
          cod_item,
          dat_movto,       
          cod_operacao,
          ies_tip_movto,
          num_prog)
          
          VALUES (p_cod_emp_ger,
                  p_num_transac,
                  p_estoque_trans_end.endereco,
                  p_estoque_trans_end.num_volume,
                  p_estoque_trans_end.qtd_movto,
                  p_estoque_trans_end.cod_grade_1,
                  p_estoque_trans_end.cod_grade_2,
                  p_estoque_trans_end.cod_grade_3,
                  p_estoque_trans_end.cod_grade_4,
                  p_estoque_trans_end.cod_grade_5,
                  p_estoque_trans_end.dat_hor_prod_ini,
                  p_estoque_trans_end.dat_hor_prod_fim,
                  p_estoque_trans_end.vlr_temperatura,
                  p_estoque_trans_end.endereco_origem,
                  p_estoque_trans_end.num_ped_ven,
                  p_estoque_trans_end.num_seq_ped_ven,
                  p_estoque_trans_end.dat_hor_producao,
                  p_estoque_trans_end.dat_hor_validade,
                  p_estoque_trans_end.num_peca,
                  p_estoque_trans_end.num_serie,
                  p_estoque_trans_end.comprimento,
                  p_estoque_trans_end.largura,
                  p_estoque_trans_end.altura,
                  p_estoque_trans_end.diametro,
                  p_estoque_trans_end.dat_hor_reserv_1,
                  p_estoque_trans_end.dat_hor_reserv_2,
                  p_estoque_trans_end.dat_hor_reserv_3,
                  p_estoque_trans_end.dat_reserv_1,
                  p_estoque_trans_end.dat_reserv_2,
                  p_estoque_trans_end.dat_reserv_3,
                  p_estoque_trans_end.num_reserv_1,   
                  p_estoque_trans_end.num_reserv_2,
                  p_estoque_trans_end.num_reserv_3,
                  p_estoque_trans_end.tex_reservado,
                  p_estoque_trans_end.cus_unit_movto_p,
                  p_estoque_trans_end.cus_unit_movto_f,
                  p_estoque_trans_end.cus_tot_movto_p,
                  p_estoque_trans_end.cus_tot_movto_f,
                  p_estoque_trans_end.cod_item,
                  p_estoque_trans_end.dat_movto,       
                  p_estoque_trans_end.cod_operacao,
                  p_estoque_trans_end.ies_tip_movto,
                  p_estoque_trans_end.num_prog)
          
      IF STATUS <> 0 THEN 
         LET p_erro = 'Erro: ',STATUS, 'Inserindo tabela estoque_trans_end !'
         IF NOT pol0975_grava_erro() THEN   
            RETURN FALSE 
         END IF 
         RETURN FALSE  
      END IF 
   
   RETURN TRUE 

END FUNCTION

#--------------------------------------#
 FUNCTION pol0975_le_estoque_trans_end()
#--------------------------------------#
   
   SELECT *
     INTO p_estoque_trans_end.* 
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_emp_ofic
      AND num_transac = p_estoque_trans.num_transac
      
   IF STATUS <> 0 THEN
      LET p_erro = 'Erro: ',STATUS, 'Lendo tabela estoque_trans_end !'
      IF NOT pol0975_grava_erro() THEN   
         RETURN FALSE 
      END IF 
      RETURN FALSE 
   END IF  
   
   RETURN TRUE 

END FUNCTION

#------------------------------------------#
 FUNCTION pol0975_inseri_estoque_auditoria()
#------------------------------------------#
   
   LET p_nom_aud_usuario    = p_estoque_trans.nom_usuario
   LET p_dat_aud_hor_proces = CURRENT 
   LET p_num_aud_programa   = 'POL0975'
   
   INSERT INTO estoque_auditoria(
          cod_empresa,
          num_transac,
          nom_usuario,
          dat_hor_proces,
          num_programa)
          
          VALUES (p_cod_emp_ger,
                  p_num_transac,
                  p_nom_aud_usuario,
                  p_dat_aud_hor_proces,
                  p_num_aud_programa) 
   
   IF STATUS <> 0 THEN 
      LET p_erro = 'Erro: ',STATUS, 'Inserindo tabela estoque_auditoria !'
      IF NOT pol0975_grava_erro() THEN   
         RETURN FALSE  
      END IF 
      RETURN FALSE 
   END IF        
   
   RETURN TRUE 

END FUNCTION

#daqui
#----------------------------------#
 FUNCTION pol0975_atualiza_estoque()
#----------------------------------#

   

   RETURN TRUE 
   
END FUNCTION 
   

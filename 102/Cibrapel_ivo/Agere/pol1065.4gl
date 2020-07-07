DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_val_tot              DECIMAL(15,2),
         p_pes_unit             DECIMAL(15,6),
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_cod_item_comp        LIKE item.cod_item, 
         p_cod_emp1             LIKE empresa.cod_empresa,
         p_cod_emp2             LIKE empresa.cod_empresa,
         p_cod_emp3             LIKE empresa.cod_empresa,
         p_cod_emp4             LIKE empresa.cod_empresa,
         p_cod_emp5             LIKE empresa.cod_empresa,
         p_cod_empg1            LIKE empresa.cod_empresa,
         p_cod_empg2            LIKE empresa.cod_empresa,
         p_cod_empg3            LIKE empresa.cod_empresa,
         p_cod_empg4            LIKE empresa.cod_empresa,
         p_cod_empg5            LIKE empresa.cod_empresa,
         p_num_om               LIKE nf_item.num_om,
         p_ies_tip_controle     LIKE nat_operacao.ies_tip_controle,
         p_qtd_saldo            LIKE nf_item.qtd_item,  
         p_pct_saldo            DECIMAL(7,4),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT

  DEFINE p_ped_itens           RECORD LIKE ped_itens.*
  DEFINE p_ped_itens_peso_885  RECORD LIKE ped_itens_peso_885.*
  DEFINE p_empresas_885        RECORD LIKE empresas_885.*             
  DEFINE p_pedidos             RECORD LIKE pedidos.* 
  DEFINE p_audit_vdp           RECORD LIKE audit_vdp.*
  
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_ind                  INTEGER,
         p_cancel               INTEGER
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL1065-05.10.01" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()             
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP FILE p_help,
    PREVIOUS KEY control-b,
    NEXT     KEY control-f

  CALL log001_acessa_usuario("VDP","LIC_LIB")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol1065_controle()
  END IF
END MAIN

#---------------------------#
 FUNCTION pol1065_controle()
#---------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol1065") RETURNING p_nom_tela 
  OPEN WINDOW w_pol1065 AT 5,3  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND  "Processar"    "Gera base para relatorios de pedidos "
      LET p_ind = 1
      DECLARE cq_emp CURSOR FOR 
        SELECT * 
          FROM empresas_885
         WHERE cod_emp_oficial = p_cod_empresa  
      FOREACH cq_emp INTO p_empresas_885.* 

		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	

         IF p_ind = 1 THEN 
            LET p_cod_emp1 = p_empresas_885.cod_emp_oficial 
            LET p_cod_empg1 = p_empresas_885.cod_emp_gerencial
         ELSE   
            IF p_ind = 2 THEN 
               LET p_cod_emp2 = p_empresas_885.cod_emp_oficial 
               LET p_cod_empg2 = p_empresas_885.cod_emp_gerencial
            ELSE   
               IF p_ind = 3 THEN 
                  LET p_cod_emp3 = p_empresas_885.cod_emp_oficial
                  LET p_cod_empg3 = p_empresas_885.cod_emp_gerencial 
               ELSE   
                  IF p_ind = 4 THEN 
                     LET p_cod_emp4 = p_empresas_885.cod_emp_oficial
                     LET p_cod_empg4 = p_empresas_885.cod_emp_gerencial 
                  ELSE   
                     LET p_cod_emp5 = p_empresas_885.cod_emp_oficial
                     LET p_cod_empg5 = p_empresas_885.cod_emp_gerencial 
                  END IF 
               END IF 
            END IF 
         END IF 
         LET p_ind = p_ind + 1
      END FOREACH             

      CALL pol1065_cria_temp()

      IF pol1065_processa() THEN 
         ERROR 'Cancelamentos efetuados'
         NEXT OPTION "Fim"
      ELSE
         ERROR 'PROBLEMA DURANTE CANCELAMENTO, PROCESSO CANCELADO'
         NEXT OPTION "Fim"
      END IF    

     COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
      
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol1065
END FUNCTION

#-----------------------------#
 FUNCTION pol1065_cria_temp()
#-----------------------------#

   WHENEVER ERROR CONTINUE
   DROP TABLE ped_del
   WHENEVER ERROR STOP
   
   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE ped_del
     (
      cod_empresa     CHAR(02),
      num_pedido      DECIMAL(6,0),
      num_sequencia   INTEGER,
      cod_item        CHAR(15) 
     );
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-ped_del")
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1065_processa()
#-----------------------------#

  DISPLAY 'PROCESSANDO CANCELAMENTO DE PEDIDOS'  AT 7,10

  BEGIN WORK

  DECLARE cq_ped CURSOR FOR
    SELECT * 
      FROM ped_itens_peso_885 
     WHERE cod_empresa  IN (p_cod_emp1, p_cod_empg1) 
       AND qtd_saldo > 0
       
  FOREACH cq_ped INTO p_ped_itens_peso_885.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

   LET p_pct_saldo = (p_ped_itens_peso_885.qtd_saldo / p_ped_itens_peso_885.qtd_peca_solic) 
   
   LET p_pct_saldo = p_pct_saldo * 100
  
   IF p_pct_saldo <= 10 THEN
      IF pol1065_cancela_pedido() THEN
      ELSE
         ROLLBACK WORK
         RETURN FALSE
      END IF        
   END IF 

  END FOREACH              

  IF pol1065_canc_ped_peso_885() THEN
     COMMIT WORK 
     RETURN TRUE
  ELSE
     ROLLBACK WORK
     RETURN FALSE
  END IF
           
END FUNCTION

#---------------------------------#
 FUNCTION pol1065_cancela_pedido()
#---------------------------------#

 INSERT INTO ped_del VALUES (p_ped_itens_peso_885.cod_empresa, 
                             p_ped_itens_peso_885.num_pedido,
                             p_ped_itens_peso_885.num_sequencia,
                             p_ped_itens_peso_885.cod_item)
 
 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("INCLUSAO","PED_DEL")
    RETURN FALSE
 END IF                              

 UPDATE ped_itens_orig_885 
    SET qtd_peca_cancel = qtd_peca_cancel + p_ped_itens_peso_885.qtd_saldo
  WHERE cod_empresa    = p_ped_itens_peso_885.cod_empresa
    AND num_pedido     = p_ped_itens_peso_885.num_pedido
    AND num_sequencia  = p_ped_itens_peso_885.num_sequencia
    AND cod_item       = p_ped_itens_peso_885.cod_item  	

 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("ATUALIZACAO","PED_ITENS_ORIG_885")
    RETURN FALSE
 END IF                              

 SELECT (qtd_pecas_solic-qtd_pecas_atend-qtd_pecas_cancel)
   INTO p_qtd_saldo
   FROM ped_itens 
  WHERE cod_empresa    = p_cod_emp1
    AND num_pedido     = p_ped_itens_peso_885.num_pedido
    AND num_sequencia  = p_ped_itens_peso_885.num_sequencia
    AND cod_item       = p_ped_itens_peso_885.cod_item  	

 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("LEITURA 1","PED_ITENS")
    RETURN FALSE
 END IF                              

 UPDATE ped_itens 
    SET qtd_pecas_cancel = qtd_pecas_cancel + p_qtd_saldo
  WHERE cod_empresa    = p_cod_emp1
    AND num_pedido     = p_ped_itens_peso_885.num_pedido
    AND num_sequencia  = p_ped_itens_peso_885.num_sequencia
    AND cod_item       = p_ped_itens_peso_885.cod_item  	

 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("ATUALIZACAO 1","PED_ITENS")
    RETURN FALSE
 END IF                              

 SELECT (qtd_pecas_solic-qtd_pecas_atend-qtd_pecas_cancel)
   INTO p_qtd_saldo
   FROM ped_itens 
  WHERE cod_empresa    = p_cod_empg1
    AND num_pedido     = p_ped_itens_peso_885.num_pedido
    AND num_sequencia  = p_ped_itens_peso_885.num_sequencia
    AND cod_item       = p_ped_itens_peso_885.cod_item  	

 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("LEITURA 2","PED_ITENS")
    RETURN FALSE
 END IF                              

 UPDATE ped_itens 
    SET qtd_pecas_cancel = qtd_pecas_cancel + p_qtd_saldo
  WHERE cod_empresa    = p_cod_empg1
    AND num_pedido     = p_ped_itens_peso_885.num_pedido
    AND num_sequencia  = p_ped_itens_peso_885.num_sequencia
    AND cod_item       = p_ped_itens_peso_885.cod_item  	

 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("ATUALIZACAO 2","PED_ITENS")
    RETURN FALSE
 END IF                              

 LET p_audit_vdp.cod_empresa = p_ped_itens_peso_885.cod_empresa
 LET p_audit_vdp.num_pedido = p_ped_itens_peso_885.num_pedido
 LET p_audit_vdp.tipo_informacao = 'M'
 LET p_audit_vdp.tipo_movto = 'A'
 LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',p_ped_itens_peso_885.cod_item,' SEQ. ',p_ped_itens_peso_885.num_sequencia,' QTDE ',p_ped_itens_peso_885.qtd_saldo
 LET p_audit_vdp.num_programa = 'POL1065'
 LET p_audit_vdp.data = TODAY
 LET p_audit_vdp.hora = TIME
 LET p_audit_vdp.usuario = p_user
 INSERT INTO audit_vdp
       (cod_empresa, 
        num_pedido, 
        tipo_informacao, 
        tipo_movto, 
        texto, 
        num_programa,  
        data, 
        hora, 
        usuario) 
 VALUES 
       (p_audit_vdp.cod_empresa, 
        p_audit_vdp.num_pedido, 
        p_audit_vdp.tipo_informacao, 
        p_audit_vdp.tipo_movto, 
        p_audit_vdp.texto, 
        p_audit_vdp.num_programa,  
        p_audit_vdp.data, 
        p_audit_vdp.hora, 
        p_audit_vdp.usuario) 
 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("INCLUSAO","AUDIT_VDP")
    RETURN FALSE
 END IF 

 RETURN TRUE 

END FUNCTION


#-----------------------------------#
 FUNCTION pol1065_canc_ped_peso_885()
#-----------------------------------#

  DECLARE cq_del CURSOR FOR
    SELECT * 
      FROM ped_del 
       
  FOREACH cq_del INTO p_ped_itens_peso_885.cod_empresa,
                      p_ped_itens_peso_885.num_pedido,
                      p_ped_itens_peso_885.num_sequencia,
                      p_ped_itens_peso_885.cod_item  

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

     DELETE FROM ped_itens_peso_885
      WHERE cod_empresa   = p_ped_itens_peso_885.cod_empresa   
        AND num_pedido    = p_ped_itens_peso_885.num_pedido    
        AND num_sequencia = p_ped_itens_peso_885.num_sequencia 
        AND cod_item      = p_ped_itens_peso_885.cod_item      
      
     IF SQLCA.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","AUDIT_VDP")
        RETURN FALSE
     END IF 
   
  END FOREACH 

 RETURN TRUE 

END FUNCTION

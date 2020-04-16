# FUNÇÕES: FUNC002                                                 #

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

DEFINE    p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_cancelar       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_num_pedido         LIKE pedidos.num_pedido

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL1065-10.02.13  " 
  CALL func002_versao_prg(p_versao)

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

   CALL log001_acessa_usuario("ESPEC999","") 
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
  OPEN WINDOW w_pol1065 AT 5,15  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND  "Processar"    "Cancela saldo e pedidos até 10% "

      CALL pol1065_cria_temp()

      IF pol1065_processa() THEN 
         ERROR 'Operação efetuada com sucesso.'
         NEXT OPTION "Fim"
      ELSE
         ERROR 'Operação cancelada.'
         NEXT OPTION "Fim"
      END IF    

    COMMAND "Sobre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)

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
FUNCTION pol1065_le_desconto()#
#-----------------------------#

      SELECT pct_desc_valor,
             pct_desc_qtd
        INTO p_pct_desc_valor,
             p_pct_desc_qtd
        FROM desc_nat_oper_885
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
	
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','desc_nat_oper_885')
         RETURN FALSE
      END IF
            
      RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1065_processa()
#-----------------------------#
  
  DEFINE l_pct_faturado   DECIMAL(5,2),
         l_fat_real       DECIMAL(10,3)
  
  DISPLAY 'PROCESSANDO CANCELAMENTO DE PEDIDOS'  AT 7,10


  DECLARE cq_ped CURSOR WITH HOLD FOR
    SELECT a.* 
      FROM ped_itens a, pedidos b
     WHERE a.cod_empresa = p_cod_empresa
       AND b.cod_empresa = a.cod_empresa
       AND a.num_pedido = b.num_pedido
       AND b.ies_sit_pedido NOT IN ('O','S','B','Z','9')   
       AND NOT EXISTS (
           SELECT f.cod_empresa FROM pedido_finalizado_885 f
            WHERE f.cod_empresa = a.cod_empresa
              AND f.num_pedido = a.num_pedido
              AND f.num_sequencia = a.num_sequencia)
       
  FOREACH cq_ped INTO p_ped_itens.*

     IF STATUS <> 0 THEN
        CALL log003_err_sql('FOREACH','info')
        RETURN FALSE
     END IF
   
   LET p_num_pedido = p_ped_itens.num_pedido
   
   IF NOT pol1065_le_desconto() THEN
      RETURN FALSE
   END IF
   
   IF p_pct_desc_qtd > 0 THEN
      LET l_pct_faturado = 100 - p_pct_desc_qtd
      LET l_fat_real = p_ped_itens.qtd_pecas_atend * 100 / l_pct_faturado
   ELSE
      LET l_fat_real = p_ped_itens.qtd_pecas_atend
   END IF
      
   LET p_qtd_saldo = p_ped_itens.qtd_pecas_solic - 
                     l_fat_real - 
                     p_ped_itens.qtd_pecas_cancel - 
                     p_ped_itens.qtd_pecas_romaneio
      
   LET p_pct_saldo = p_qtd_saldo / p_ped_itens.qtd_pecas_solic * 100
  
   IF p_pct_saldo <= 10 THEN
      DISPLAY p_ped_itens.num_pedido TO num_pedido
          #lds CALL LOG_refresh_display()	

      LET p_qtd_saldo = p_ped_itens.qtd_pecas_solic - 
                     p_ped_itens.qtd_pecas_atend - 
                     p_ped_itens.qtd_pecas_cancel - 
                     p_ped_itens.qtd_pecas_romaneio
      
      IF p_qtd_saldo < 0 THEN
         LET p_qtd_saldo = 0
      END IF
      
      BEGIN WORK
      
      IF pol1065_cancela_pedido() THEN
         COMMIT WORK
      ELSE
         ROLLBACK WORK
         RETURN FALSE
      END IF        
   END IF 

  END FOREACH              

  RETURN TRUE
             
END FUNCTION

#---------------------------------#
 FUNCTION pol1065_cancela_pedido()
#---------------------------------#

 DEFINE p_count INTEGER
 
 INSERT INTO ped_del VALUES (p_ped_itens.cod_empresa, 
                             p_ped_itens.num_pedido,
                             p_ped_itens.num_sequencia,
                             p_ped_itens.cod_item)
 
 IF SQLCA.sqlcode <> 0 THEN 
    CALL log003_err_sql("INCLUSAO","PED_DEL")
    RETURN FALSE
 END IF                              

 {DELETE FROM ped_itens_peso_885
  WHERE cod_empresa   = p_ped_itens.cod_empresa   
    AND num_pedido    = p_ped_itens.num_pedido    
    AND num_sequencia = p_ped_itens.num_sequencia 
    AND cod_item      = p_ped_itens.cod_item      
      
 IF STATUS <> 0 THEN 
    CALL log003_err_sql("DELETE","ped_itens_peso_885")
    RETURN FALSE
 END IF }
 
 IF p_qtd_saldo > 0 THEN
    IF NOT pol1065_canc_ped_itens() THEN
       RETURN FALSE
    END IF
 END IF
  
 INSERT INTO pedido_finalizado_885
  VALUES (p_cod_empresa, 
          p_ped_itens.num_pedido, 
          p_ped_itens.num_sequencia,
          p_qtd_saldo,
          p_user,
          getdate(),
          'POL1065')
 
 IF STATUS <> 0 THEN 
    CALL log003_err_sql("INSERT 1","PEDIDO_FINALIZADO_885")
    RETURN FALSE
 END IF                              

 RETURN TRUE 

END FUNCTION
 
#--------------------------------#
FUNCTION pol1065_canc_ped_itens()#
#--------------------------------#

    UPDATE ped_itens 
       SET qtd_pecas_cancel = qtd_pecas_cancel + p_qtd_saldo
     WHERE cod_empresa    = p_cod_empresa
       AND num_pedido     = p_ped_itens.num_pedido
       AND num_sequencia  = p_ped_itens.num_sequencia
       AND cod_item       = p_ped_itens.cod_item  	

    IF STATUS <> 0 THEN 
       CALL log003_err_sql("ATUALIZACAO 1","PED_ITENS")
       RETURN FALSE
    END IF                              
 
 LET p_audit_vdp.cod_empresa = p_ped_itens.cod_empresa
 LET p_audit_vdp.num_pedido = p_ped_itens.num_pedido
 LET p_audit_vdp.tipo_informacao = 'M'
 LET p_audit_vdp.tipo_movto = 'C'
 LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',p_ped_itens.cod_item,' SEQ. ',
        p_ped_itens.num_sequencia,' QTDE ',p_qtd_saldo
        
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
 
 IF STATUS <> 0 THEN 
    CALL log003_err_sql("INCLUSAO","AUDIT_VDP")
    RETURN FALSE
 END IF 

 RETURN TRUE 

END FUNCTION



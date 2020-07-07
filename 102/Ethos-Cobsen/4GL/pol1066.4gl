DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_dat_emissao          DATE, 
         p_status               SMALLINT,
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_last_row             SMALLINT 

  DEFINE p_tela RECORD
            cod_empresa  CHAR(02),
            num_pedido   LIKE ped_itens.num_pedido,
            qtd_acum     DECIMAL(9,0),  
            num_ult_nf   LIKE nf_mestre.num_nff,
            qtd_atend    DECIMAL(9,0),
            qtd_dif      DECIMAL(9,0)
                END RECORD

  DEFINE p_ped_itens         RECORD LIKE ped_itens.*
  DEFINE p_audit_vdp         RECORD LIKE audit_vdp.*
  DEFINE p_log_versao_prg    RECORD LIKE log_versao_prg.*
  
  DEFINE p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_count                INTEGER
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL1066-10.02.01" #Favor nao alterar esta linha (SUPORTE)
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
    CALL pol1066_controle()
  END IF
END MAIN

#-----------------------------#
 FUNCTION pol1066_controle()
#-----------------------------#
  INITIALIZE p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol1066") RETURNING p_nom_tela 
  OPEN WINDOW w_pol1066 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1066_atualiza_versao() 

  MENU "OPCAO"
    COMMAND "Informar"    "Informa Dados"
      MESSAGE ""
      CALL pol1066_entrada_dados()
      MESSAGE "                 "
 
     COMMAND KEY ("P") "P_confirmar"    "Confirma Programacao do cliente "
      MESSAGE ""
        IF p_tela.num_pedido IS NULL THEN 
           MESSAGE "Nao existem dados para confirmacao"  ATTRIBUTE(REVERSE)
        ELSE
          IF log004_confirm(22,45) THEN
             ERROR " Em Processamento... "
             IF pol1066_corrige_ped_itens() THEN 
                MESSAGE "Confirmacao Executada com Sucesso"  ATTRIBUTE(REVERSE)
             ELSE
                MESSAGE "Problema durante atualizacao"  ATTRIBUTE(REVERSE)
             END IF    
          END IF
        END IF  
 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1066_sobre()
         
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
      
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol1066
END FUNCTION

#----------------------------------#
 FUNCTION pol1066_atualiza_versao()
#----------------------------------#
  DEFINE p_num_prog    CHAR(08),   
         p_num_vers    CHAR(09),   
         p_dat_alte    DATE   
  
  WHENEVER ERROR CONTINUE

   LET p_num_prog = p_versao[1,7]
   LET p_num_vers = p_versao[9,16]
   LET p_dat_alte = TODAY 

   SELECT * 
     INTO p_log_versao_prg.*
     FROM log_versao_prg
    WHERE num_programa = p_num_progr  
   IF SQLCA.SQLCODE <> 0 THEN
      LET p_log_versao_prg.num_programa = p_num_prog
      LET p_log_versao_prg.num_versao = p_num_vers
      LET p_log_versao_prg.dat_alteracao = p_dat_alte
      INSERT INTO log_versao_prg VALUES (p_log_versao_prg.*)
   ELSE
      IF p_log_versao_prg.num_versao <> p_num_vers THEN 
         UPDATE log_versao_prg SET num_versao = p_num_vers, 
                                   dat_alteracao = p_dat_alte
          WHERE num_programa = p_num_progr  
      END IF      
   END IF                              

END FUNCTION

#--------------------------------#
 FUNCTION pol1066_entrada_dados()
#--------------------------------#
 
  CLEAR FORM
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol1066
  DISPLAY p_cod_empresa TO cod_empresa


  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

  AFTER FIELD num_pedido
     IF p_tela.num_pedido IS NULL THEN
        ERROR "Informe o num. do pedido"
        NEXT FIELD num_pedido
     ELSE
        SELECT COUNT(*) 
          INTO p_count
          FROM pedidos 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_tela.num_pedido
        IF p_count > 0 THEN 
        ELSE
          ERROR "pedido inexistente"
          NEXT FIELD num_pedido
        END IF              
     END IF   

  AFTER FIELD qtd_acum 
     IF p_tela.qtd_acum IS NULL THEN
        ERROR "Informe a quantidade acumulada"
        NEXT FIELD qtd_acum
     END IF 
     
  AFTER FIELD num_ult_nf
     IF p_tela.num_ult_nf IS NULL THEN
        ERROR "Informe o num. da nota"
        NEXT FIELD num_ult_nf
     ELSE
        SELECT dat_emissao
          INTO p_dat_emissao
          FROM nf_mestre 
         WHERE cod_empresa = p_cod_empresa
           AND num_nff     = p_tela.num_ult_nf
        IF SQLCA.sqlcode <> 0 THEN 
          ERROR "nota inexistente"
          NEXT FIELD num_ult_nf
        ELSE
          LET  p_tela.qtd_atend = 0 
          SELECT SUM(qtd_pecas_atend)
            INTO p_tela.qtd_atend
            FROM ped_itens 
           WHERE cod_empresa = p_cod_empresa 
             AND num_pedido  = p_tela.num_pedido
             AND prz_entrega <= p_dat_emissao
          IF p_tela.qtd_atend IS NULL THEN 
             LET p_tela.qtd_atend = 0 
          END IF
          IF p_tela.qtd_acum > p_tela.qtd_atend THEN        
             LET p_tela.qtd_dif = p_tela.qtd_acum - p_tela.qtd_atend 
          ELSE
             LET p_tela.qtd_dif = p_tela.qtd_atend - p_tela.qtd_dif 
          END IF    
          DISPLAY  p_tela.qtd_atend TO qtd_atend
          DISPLAY  p_tela.qtd_dif   TO qtd_dif     
        END IF                    
     END IF

  END INPUT 

END FUNCTION

#-----------------------------------#
 FUNCTION pol1066_corrige_ped_itens()
#-----------------------------------#
 DEFINE l_count  INTEGER
 
    IF p_tela.qtd_acum > p_tela.qtd_atend THEN 
       SELECT * 
         INTO p_ped_itens.*
         FROM ped_itens 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido  = p_tela.num_pedido
          AND num_sequencia = 0 
       IF SQLCA.sqlcode = 0 THEN 
          UPDATE ped_itens SET qtd_pecas_solic = qtd_pecas_solic + p_tela.qtd_dif,
                               qtd_pecas_atend = qtd_pecas_atend + p_tela.qtd_dif 
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido  = p_tela.num_pedido
             AND num_sequencia = 0 
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("ATUALIZACAO","PED_ITENS 1")
             RETURN FALSE
          END IF

          LET p_audit_vdp.cod_empresa = p_cod_empresa
          LET p_audit_vdp.num_pedido = p_tela.num_pedido
          LET p_audit_vdp.tipo_informacao = 'M' 
          LET p_audit_vdp.tipo_movto = 'I'
          LET p_audit_vdp.texto = 'ALTERACAO SEQUENCIA 0 + ',p_tela.qtd_dif 
          LET p_audit_vdp.num_programa = 'pol1066'
          LET p_audit_vdp.data =  TODAY
          LET p_audit_vdp.hora =  TIME 
          LET p_audit_vdp.usuario = p_user
          LET p_audit_vdp.num_transacao = 0  
          INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","audit_vdp")
             RETURN FALSE
          END IF
       ELSE
          DECLARE cq_ped_it CURSOR FOR
            SELECT * 
              FROM ped_itens 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_tela.num_pedido
             ORDER BY num_sequencia DESC
          FOREACH cq_ped_it INTO p_ped_itens.*
            EXIT FOREACH
          END FOREACH
          LET p_ped_itens.num_sequencia = 0 
          LET p_ped_itens.qtd_pecas_solic = p_tela.qtd_dif
          LET p_ped_itens.qtd_pecas_atend = p_tela.qtd_dif
          LET p_ped_itens.qtd_pecas_cancel = 0
          INSERT INTO ped_itens VALUES (p_ped_itens.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","PED_ITENS 1")
             RETURN FALSE
          END IF

          LET p_audit_vdp.cod_empresa = p_cod_empresa
          LET p_audit_vdp.num_pedido = p_tela.num_pedido
          LET p_audit_vdp.tipo_informacao = 'M' 
          LET p_audit_vdp.tipo_movto = 'I'
          LET p_audit_vdp.texto = 'INCLUSAO SEQUENCIA 0  ',p_tela.qtd_dif 
          LET p_audit_vdp.num_programa = 'pol1066'
          LET p_audit_vdp.data =  TODAY
          LET p_audit_vdp.hora =  TIME 
          LET p_audit_vdp.usuario = p_user
          LET p_audit_vdp.num_transacao = 0  
          INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","audit_vdp")
             RETURN FALSE
          END IF
       END IF
    ELSE
       UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_tela.qtd_dif 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido  = p_tela.num_pedido
          AND num_sequencia = 1 
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ATUALIZACAO","PED_ITENS 1")
          RETURN FALSE
       END IF

       LET p_audit_vdp.cod_empresa = p_cod_empresa
       LET p_audit_vdp.num_pedido = p_tela.num_pedido
       LET p_audit_vdp.tipo_informacao = 'M' 
       LET p_audit_vdp.tipo_movto = 'I'
       LET p_audit_vdp.texto = 'ALTERACAO SEQUENCIA 1 - ',p_tela.qtd_dif 
       LET p_audit_vdp.num_programa = 'pol1066'
       LET p_audit_vdp.data =  TODAY
       LET p_audit_vdp.hora =  TIME 
       LET p_audit_vdp.usuario = p_user
       LET p_audit_vdp.num_transacao = 0  
       INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","audit_vdp")
          RETURN FALSE
       END IF
    END IF  
    
    RETURN TRUE 
       
END FUNCTION
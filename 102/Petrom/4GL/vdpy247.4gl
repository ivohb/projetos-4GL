 DATABASE logix

#---------------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_informacoes_especificas(l_empresa,
                                                   l_tipo_nota,
                                                   l_serie_nota,
                                                   l_modo_exibicao_msg)
#---------------------------------------------------------------------#
  DEFINE l_empresa            LIKE empresa.cod_empresa,
         l_tipo_nota          CHAR(1),
         l_serie_nota         LIKE nf_mestre.ser_nff,
         l_modo_exibicao_msg  SMALLINT

  DEFINE l_transacao_nfe      INTEGER,
         l_num_pedido_cli     LIKE pedidos.num_pedido_cli,
         l_nitem              DECIMAL(3,0),
         l_seq_ped            DECIMAL(5,0),
         l_pedido             LIKE pedidos.num_pedido,
         l_den_texto_1        LIKE ped_itens_texto.den_texto_1
  
  DEFINE l_nota_relac         DECIMAL(6,0),
         l_chave_acesso       LIKE obf_nf_eletr.chave_acesso          

  WHENEVER ERROR CONTINUE
   DECLARE cq_t_ident_nfe CURSOR FOR
    SELECT transacao_nfe
      FROM t_ident_nfe
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE","cq_t_ident_nfe",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_t_ident_nfe INTO l_transacao_nfe
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("FOREACH","cq_t_ident_nfe",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_t_prod_serv CURSOR FOR
       SELECT nitem, seq_ped, pedido
         FROM t_prod_serv
        WHERE transacao_nfe = l_transacao_nfe
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR","cq_t_prod_serv",l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_t_prod_serv INTO l_nitem, l_seq_ped, l_pedido
     WHENEVER ERROR STOP 
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR","cq_t_prod_serv",l_modo_exibicao_msg)
        RETURN FALSE
     END IF
        
        INITIALIZE l_num_pedido_cli TO NULL
        
        #Busca o número do pedido do cliente
        WHENEVER ERROR CONTINUE
          SELECT num_pedido_cli
            INTO l_num_pedido_cli
            FROM pedidos
           WHERE cod_empresa = l_empresa
             AND num_pedido  = l_pedido
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
        
           IF  l_num_pedido_cli IS NOT NULL
           AND l_num_pedido_cli <> " " THEN        
           
              LET l_num_pedido_cli = LOG_AllTrim(log0800_filter_number(l_num_pedido_cli))
              
              INITIALIZE l_den_texto_1 TO NULL
              
              WHENEVER ERROR CONTINUE
                SELECT den_texto_1
                  INTO l_den_texto_1
                  FROM ped_itens_texto
                 WHERE cod_empresa   = l_empresa
                   AND num_pedido    = l_pedido
                   AND num_sequencia = l_seq_ped
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN #Encontrou número
                 IF l_den_texto_1[1] = "0" 
                 OR l_den_texto_1[1] = "1" 
                 OR l_den_texto_1[1] = "2" 
                 OR l_den_texto_1[1] = "3" 
                 OR l_den_texto_1[1] = "4" 
                 OR l_den_texto_1[1] = "5" 
                 OR l_den_texto_1[1] = "6" 
                 OR l_den_texto_1[1] = "7" 
                 OR l_den_texto_1[1] = "8" 
                 OR l_den_texto_1[1] = "9" THEN
                    LET l_seq_ped = log0800_filter_number(l_den_texto_1[1,6]) USING "<<<<<<"
                 END IF
              END IF
           
              #IF vdpr125_t_prod_serv_leitura(l_transacao_nfe, l_seq_ped, l_modo_exibicao_msg) THEN
              #
              #   CALL vdpr125_t_prod_serv_set_xped(l_num_pedido_cli)
              #
              #   IF NOT vdpr125_t_prod_serv_modifica(l_modo_exibicao_msg) THEN
              #      RETURN FALSE
              #   END IF
              #END IF
              
              WHENEVER ERROR CONTINUE
                UPDATE t_prod_serv
                   SET xped           = l_num_pedido_cli,
                       nitemped       = l_seq_ped
                 WHERE transacao_nfe  = l_transacao_nfe
                   AND nitem          = l_nitem
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 CALL log0030_processa_err_sql("UPDATE","t_prod_serv",l_modo_exibicao_msg)
                 RETURN FALSE
              END IF

           END IF
        END IF    
        
     END FOREACH
              
     FREE cq_t_prod_serv   
              
  END FOREACH 
              
  FREE cq_t_ident_nfe

  RETURN TRUE

 END FUNCTION
#-------------------------------------------------------------------#
# PROGRAMA: POL0203                                                 #
# MODULOS.: POL0203 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO DE PEDIDO INTERNO                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_num_pag       INTEGER,
		      p_trans_config  INTEGER,
          p_erro          SMALLINT,
          p_comprime      CHAR(01),
          comando         CHAR(80),
          p_nom_arquivo   CHAR(100),
          p_nom_tela      CHAR(200),
          p_count         SMALLINT,
          p_nom_help      CHAR(200),
          p_ies_lista     SMALLINT,
          p_ies_impressao CHAR(01),
          p_versao        CHAR(18),
          p_ind           SMALLINT,
          p_ies_cons      SMALLINT,
          g_ies_ambiente  CHAR(01),
          p_caminho       CHAR(080),
          p_i             INTEGER,
          pa_curr         SMALLINT,
          sc_curr         SMALLINT,
          p_cod_cidade    CHAR(005),
          p_tip_entrega   DECIMAL(1,0),
          p_ies_incid_ipi DECIMAL(1,0),
          p_cod_nat_oper  LIKE nat_operacao.cod_nat_oper,
          p_ies_frete     LIKE pedidos.ies_frete,
          p_msg           char(300),

          p_tributo_benef      CHAR(20),
          p_micro_empresa      CHAR(01),
          p_regiao_fiscal      CHAR(10),
          p_grp_classif_fisc   CHAR(10),
          p_grp_fiscal_item    CHAR(10),
          p_grp_fisc_cliente   CHAR(10),
          p_matriz             CHAR(22),
          p_ies_tributo        SMALLINT,
          p_cod_tip_carteira   char(02),
          p_cod_uni_feder      char(03),
          p_ies_finalidade     char(01),
          p_cod_familia        LIKE item.cod_familia,
          p_gru_ctr_estoq      LIKE item.gru_ctr_estoq,
          p_cod_cla_fisc       LIKE item.cod_cla_fisc,
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_cod_item           like item.cod_item,
          p_seq_acesso         LIKE obf_ctr_acesso.sequencia_acesso,
          p_chave              CHAR(11),
          p_query              CHAR(600),
          p_endereco          CHAR(10),
          p_ies_tipo           LIKE estoque_operac.ies_tipo
          
          


   DEFINE p_tela RECORD
      cod_empresa         LIKE empresa.cod_empresa,
      dat_ini             DATE,
      dat_fim             DATE,
      num_pedido1         LIKE pedido_dig_mest.num_pedido,
      num_pedido2         LIKE pedido_dig_mest.num_pedido,
      ies_comis           CHAR(1)
   END RECORD 

   DEFINE p_tela1 RECORD
      cod_empresa         LIKE empresa.cod_empresa
   END RECORD 

   DEFINE p_endereco RECORD
          p_ender          CHAR(10)
   END RECORD 

   DEFINE t_pedidos ARRAY[1000] OF RECORD
          ies_imprime      CHAR(01), 
          num_pedido       DECIMAL(6,0), 
          nom_cliente      CHAR(35), 
          dat_emis_repres  DATE, 
          nom_repres       CHAR(20)
  END RECORD

   DEFINE p_relat RECORD 
      num_pedido          LIKE pedido_dig_mest.num_pedido,
      cod_cliente         LIKE pedido_dig_mest.cod_cliente,          
      cod_repres          LIKE pedido_dig_mest.cod_repres,           
      num_pedido_cli      LIKE pedido_dig_mest.num_pedido_cli,   
      dat_emis_repres     LIKE pedido_dig_mest.dat_emis_repres,  
      pct_desc_adic       LIKE pedido_dig_mest.pct_desc_adic,   
      cod_transpor        LIKE pedido_dig_mest.cod_transpor,    
      cod_consig          LIKE pedido_dig_mest.cod_consig,      
      cod_nat_oper        LIKE pedido_dig_mest.cod_nat_oper,    
      cod_cnd_pgto        LIKE pedido_dig_mest.cod_cnd_pgto,    
      num_pedido_repres   LIKE pedido_dig_mest.num_pedido_repres,
      num_list_preco      LIKE pedido_dig_mest.num_list_preco,
      pct_desc_adicp      LIKE pedido_dig_mest.pct_desc_adic, 
      nom_cliente         LIKE clientes.nom_cliente,
      num_cgc_cpf         LIKE clientes.num_cgc_cpf,
      end_cliente         LIKE clientes.end_cliente,  
      num_telefone        LIKE clientes.num_telefone,
      cod_cep             LIKE clientes.cod_cep,      
      raz_social          LIKE representante.raz_social,
      den_cidade          LIKE cidades.den_cidade,
      cod_uni_feder       LIKE cidades.cod_uni_feder,
      den_nat_oper        LIKE nat_operacao.den_nat_oper,
      den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
      tip_entrega         CHAR (015),
      nom_transpor        LIKE clientes.nom_cliente,
      nom_consig          LIKE clientes.nom_cliente, 
      num_sequencia       LIKE pedido_dig_item.num_sequencia,
      cod_item            LIKE pedido_dig_item.cod_item, 
      qtd_pecas_solic     LIKE pedido_dig_item.qtd_pecas_solic, 
      pre_unit            DECIMAL(15,4),
      pct_desc_adici      LIKE pedido_dig_item.pct_desc_adic, 
      prz_entrega         LIKE pedido_dig_item.prz_entrega,
      den_item 	          LIKE item.den_item,
      cod_unid_med        LIKE item.cod_unid_med,
      pes_unit            LIKE item.pes_unit,
      pct_ipi             LIKE item.pct_ipi,
      email_contato       LIKE cli_hayward.email_contato, 
      obs_contato         LIKE cli_hayward.obs_contato,
      preco_bruto         DECIMAL(15,4),
      preco_liq           DECIMAL(15,4),
      preco_ipi           LIKE pedido_dig_item.pre_unit, 
      perc_desc           LIKE ped_itens_desc.pct_desc_1,
      pct_comis           LIKE pedido_dig_mest.pct_comissao,
      p_tex_obs_1         LIKE ped_observacao.tex_observ_1, 
      p_tex_obs_2         LIKE ped_observacao.tex_observ_2, 
      p_den_tex_1         LIKE ped_itens_texto.den_texto_1, 
      p_den_tex_2         LIKE ped_itens_texto.den_texto_2, 
      p_den_tex_3         LIKE ped_itens_texto.den_texto_3, 
      p_den_tex_4         LIKE ped_itens_texto.den_texto_4, 
      p_den_tex_5         LIKE ped_itens_texto.den_texto_5,  
      p_desc_rel          CHAR(27),
      perc_desc_at        LIKE ped_itens_desc.pct_desc_1,
      ies_ac_fin          CHAR(03), 
      ies_ac_com          CHAR(03),
      des_frete           CHAR(03),
      ies_aceite          CHAR(01)
   END RECORD 

END GLOBALS

MAIN
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT 
   LET p_versao="pol0203-10.02.16"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0203.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0203_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0203_controle()
#--------------------------#

   CALL pol0203_cria_t_pedido()
   LET p_comprime = ascii 15
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0203") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   LET  p_num_pag = 0
   OPEN WINDOW w_pol0203 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros para impressao"
      HELP 000 
      LET p_ies_cons = FALSE
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","POL0203","IN")  THEN
         IF pol0203_entrada_dados() THEN
            LET p_ies_cons = TRUE
            ERROR "Operação efetuada com sucesso"
            NEXT OPTION "Listar"
         ELSE
            ERROR "Funcao Cancelada"
            NEXT OPTION "Fim"
         END IF 
      END IF 

      COMMAND "Batch" "Escolhe pedidos em batch para impressao"
      HELP 000 
      LET p_ies_cons = FALSE
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","POL0203","IN")  THEN
         IF pol0203_entrada_dados_2() THEN
            LET p_ies_cons = TRUE
            ERROR "Operação efetuada com sucesso"
            NEXT OPTION "Listar"
         ELSE
            ERROR "Funcao Cancelada"
            NEXT OPTION "Fim"
         END IF 
      END IF 

      COMMAND "Listar" "Lista relatorio"
      HELP 002
      LET p_count = 0
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","POL0203","MO") THEN
         IF p_ies_cons = TRUE THEN 
            IF log028_saida_relat(17,42) IS NOT NULL THEN
               MESSAGE " Processando a extracao do relatorio ... " 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0203_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0203.tmp'
                     START REPORT pol0203_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0203_relat TO p_nom_arquivo
               END IF
               LET  p_count = 0
               #CALL pol0203_emite_relatorio_dig()
               CALL pol0203_emite_relatorio_ped()
               CALL pol0203_emite_relat()
               IF p_count = 0 THEN
                  ERROR "Nao existem dados para serem listados" 
                     ATTRIBUTE(REVERSE)
               ELSE
                  ERROR "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
               END IF
               FINISH REPORT pol0203_relat   
            ELSE
               CONTINUE MENU
            END IF                                                            
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                 p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo,
                       " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      ELSE
         ERROR "Informe a referencia para impressao"
         NEXT OPTION "Informar"
      END IF 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0203_sobre() 
      COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 000
      MESSAGE ""
      EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0203

END FUNCTION

#-----------------------#
FUNCTION pol0203_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
 FUNCTION pol0203_cria_t_pedido()
#-------------------------------#

   WHENEVER ERROR CONTINUE
   DROP TABLE t_pedido

   CREATE TEMP TABLE chave_tmp_7662 
   (chave CHAR(11)   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','chave_tmp_7662')
      RETURN
   END IF
   
   
   CREATE  TABLE t_pedido 
   (num_ped DECIMAL(6,0) 
   );

   WHENEVER ERROR STOP 

   WHENEVER ERROR CONTINUE
   DROP TABLE t_relat 

   CREATE TEMP TABLE t_relat  
   (num_pedido          DECIMAL(6,0), 
    cod_cliente         CHAR(15), 
    cod_repres          DECIMAL(4,0),
    num_pedido_cli      CHAR(25),
    dat_emis_repres     DATE,  
    pct_desc_adic       DECIMAL(4,2),
    cod_transpor        CHAR(15),
    cod_consig          CHAR(15),
    cod_nat_oper        INTEGER, 
    cod_cnd_pgto        DECIMAL(3,0),
    num_pedido_repres   CHAR(10),
    num_list_preco      DECIMAL(4,0),
    pct_desc_adicp      DECIMAL(4,2),
    nom_cliente         CHAR(36),
    num_cgc_cpf         CHAR(19), 
    end_cliente         CHAR(36), 
    num_telefone        CHAR(15),  
    cod_cep             CHAR(9),  
    raz_social          CHAR(36), 
    den_cidade          CHAR(30),  
    cod_uni_feder       CHAR(2),  
    den_nat_oper        CHAR(30),
    den_cnd_pgto        CHAR(30),  
    tip_entrega         CHAR(15),  
    nom_transpor        CHAR(36), 
    nom_consig          CHAR(36),  
    num_sequencia       DECIMAL(5,0),  
    cod_item            CHAR(15), 
    qtd_pecas_solic     DECIMAL(10,3),
    pre_unit            DECIMAL(17,6),
    pct_desc_adici      DECIMAL(4,2),
    prz_entrega         DATE, 
    den_item 	          CHAR(76),  
    cod_unid_med        CHAR(3), 
    pes_unit            DECIMAL(10,5),
    pct_ipi             DECIMAL(6,3), 
    email_contato       CHAR(60), 
    obs_contato         CHAR(60),  
    preco_bruto         DECIMAL(15,4),
    preco_liq           DECIMAL(15,4),
    preco_ipi           DECIMAL(17,6), 
    perc_desc           DECIMAL(5,2), 
    pct_comis           DECIMAL(4,2),  
    p_tex_obs_1         CHAR(75), 
    p_tex_obs_2         CHAR(75), 
    p_den_tex_1         CHAR(76), 
    p_den_tex_2         CHAR(76),
    p_den_tex_3         CHAR(76), 
    p_den_tex_4         CHAR(76), 
    p_den_tex_5         CHAR(76), 
    p_desc_rel          CHAR(27),
    perc_desc_at        DECIMAL(5,2),
    ies_ac_fin          CHAR(03), 
    ies_ac_com          CHAR(03),
    des_frete           CHAR(03),
    ies_aceite          CHAR(01)
   );
   WHENEVER ERROR STOP 

END FUNCTION

#-------------------------------#     
 FUNCTION pol0203_monta_tela1()     
#-------------------------------#     
DEFINE l_cod_cliente  LIKE clientes.cod_cliente,
       l_cod_repres   LIKE representante.cod_repres,
       l_tem_ped      SMALLINT

   LET l_tem_ped = FALSE
   
   INITIALIZE t_pedidos TO NULL
   DECLARE c_ped_b CURSOR FOR
   SELECT num_pedido,
          cod_cliente,
          dat_emis_repres,
          cod_repres
   FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND ies_sit_pedido = 'E'
   ORDER BY cod_repres,
            dat_emis_repres

   LET p_i = 1
   FOREACH c_ped_b INTO   t_pedidos[p_i].num_pedido,
                          l_cod_cliente,
                          t_pedidos[p_i].dat_emis_repres,
                          l_cod_repres 
                          
      LET t_pedidos[p_i].ies_imprime = 'S'

      SELECT nom_cliente[1,35]
         INTO t_pedidos[p_i].nom_cliente
      FROM clientes
      WHERE cod_cliente = l_cod_cliente

      SELECT raz_social[1,20]
         INTO t_pedidos[p_i].nom_repres
      FROM representante
      WHERE cod_repres = l_cod_repres

      LET p_i = p_i + 1

   END FOREACH
 RETURN TRUE 
END FUNCTION

#-------------------------------#
 FUNCTION pol0203_entrada_dados()
#-------------------------------#
   
   DEFINE sql_stmt     CHAR(800),
          l_num_pedido INTEGER,
          l_tem_ped    SMALLINT
   
   INITIALIZE p_tela.* TO NULL 
   LET p_tela.cod_empresa = p_cod_empresa
   LET p_tela.ies_comis = "S"
   LET INT_FLAG = FALSE
   DISPLAY BY NAME p_tela.cod_empresa

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
   
      AFTER FIELD dat_fim
        IF p_tela.dat_fim IS NOT NULL THEN
           IF p_tela.dat_ini IS NULL THEN
              ERROR 'Informe a data inicial'
              NEXT FIELD dat_ini
           END IF       
           IF p_tela.dat_fim < p_tela.dat_ini THEN 
              ERROR 'Data final deve ser maior ou igual a data inicial'
              NEXT FIELD dat_ini
           END IF
           LET p_tela.num_pedido1 = NULL
           LET p_tela.num_pedido2 = NULL
           NEXT FIELD ies_comis    
        END IF   
      
      BEFORE FIELD num_pedido1 
         LET p_tela.dat_ini = NULL
         LET p_tela.dat_fim = NULL
      
      AFTER FIELD num_pedido1 
         IF p_tela.num_pedido1 IS NULL THEN
            ERROR "Campo de preenchimento obrigatorio"
            NEXT FIELD num_pedido1  
         ELSE
            SELECT num_pedido
            FROM pedidos
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_tela.num_pedido1
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Pedido nao Cadastrado"
               NEXT FIELD num_pedido1
            END IF
         END IF

      AFTER FIELD num_pedido2 
         IF p_tela.num_pedido2 IS NULL THEN
            ERROR "Campo de preenchimento obrigatorio"
            NEXT FIELD num_pedido2   
         ELSE
            SELECT num_pedido
            FROM pedidos
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_tela.num_pedido2
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Pedido nao Cadastrado"
               NEXT FIELD num_pedido2
            END IF            
            IF p_tela.num_pedido1 > p_tela.num_pedido2 THEN
               ERROR "Pedido De nao pode ser maior que Pedido ate"
               NEXT FIELD num_pedido1
            END IF 
         END IF
    
   END INPUT

   IF int_flag THEN
      RETURN FALSE
   END IF

   DELETE FROM t_pedido
   LET l_tem_ped = FALSE
   
   LET sql_stmt =
       "  SELECT num_pedido FROM pedidos ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "  AND ies_sit_pedido <> '9' "
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND dat_pedido >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND dat_pedido <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.num_pedido1 IS NOT NULL THEN
      IF p_tela.num_pedido1 > 0 THEN      
         LET sql_stmt = sql_stmt CLIPPED, " AND num_pedido >= ",p_tela.num_pedido1
      END IF
   END IF

   IF p_tela.num_pedido2 IS NOT NULL THEN
      IF p_tela.num_pedido2 > 0 THEN      
         LET sql_stmt = sql_stmt CLIPPED, " AND num_pedido <= ",p_tela.num_pedido2
      END IF
   END IF

    PREPARE var_ped1 FROM sql_stmt
    
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_ped1")
       RETURN FALSE
    END IF

    DECLARE cq_le_ped1 CURSOR FOR var_ped1

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","var_ped1")
        RETURN FALSE
    END IF

    FREE var_ped1

    OPEN cq_le_ped1

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_le_ped1")
       RETURN FALSE
    END IF

    FOREACH cq_le_ped1 INTO l_num_pedido
   
       IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_le_ped1")
          RETURN FALSE
       END IF

       INSERT INTO t_pedido VALUES(l_num_pedido)   
   
       IF STATUS <> 0 THEN
          CALL log003_err_sql("INSERT","t_pedido")
          RETURN FALSE
       END IF
       
       LET l_tem_ped = TRUE
       
   END FOREACH
   
   IF NOT l_tem_ped THEN
      CALL log0030_mensagem('Não há pedidos para o parâmetros informados.','info')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#---------------------------------#
 FUNCTION pol0203_entrada_dados_2()
#---------------------------------#

DEFINE l_num_pedido  LIKE pedidos.num_pedido

  CALL log130_procura_caminho("pol02031") RETURNING comando
  OPEN WINDOW w_pol02031 AT 2,3 WITH FORM comando
       ATTRIBUTE(BORDER, FORM LINE 1, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol0203_monta_tela1() 
   
   IF p_i <= 1 THEN
      CALL log0030_mensagem('Não há pedidos em análise.','info')
      RETURN FALSE
   END IF
       
   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET INT_FLAG = FALSE
   
   INPUT ARRAY t_pedidos WITHOUT DEFAULTS FROM s_pedidos.*

      BEFORE FIELD ies_imprime    
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD ies_imprime
      IF t_pedidos[pa_curr].ies_imprime IS NULL THEN
         LET t_pedidos[pa_curr].ies_imprime = 'N'
         DISPLAY t_pedidos[pa_curr].ies_imprime TO s_pedidos[sc_curr].ies_imprime
      END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_pedidos[pa_curr+1].num_pedido IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD ies_imprime
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN 
   END IF

   FOR p_i = 1 TO 1000 
     IF t_pedidos[p_i].num_pedido IS NULL THEN
        EXIT FOR
     END IF 
     IF t_pedidos[p_i].ies_imprime = 'S' THEN 
        LET l_num_pedido = t_pedidos[p_i].num_pedido 
        SELECT *
          FROM t_pedido 
         WHERE num_ped = l_num_pedido
        IF SQLCA.sqlcode <> 0 THEN  
           INSERT INTO t_pedido
            VALUES (l_num_pedido)
        END IF  
     END IF         
   END FOR
   CLOSE WINDOW w_pol02031
   RETURN TRUE
END FUNCTION    

#-------------------------------------#
 FUNCTION pol0203_emite_relatorio_dig()
#-------------------------------------#

   LET p_count = 0   

   LET p_relat.p_desc_rel = "PEDIDO AGUARDANDO LIBERACAO"

   SELECT den_empresa   
      INTO p_den_empresa
   FROM empresa 
   WHERE cod_empresa = p_cod_empresa
 
   DECLARE cq_pedido CURSOR FOR
   SELECT num_pedido,
          cod_cliente,
          cod_repres,
          num_pedido_cli,
          dat_emis_repres,
          pct_desc_adic,
          cod_transpor,
          cod_consig,
          cod_nat_oper,
          cod_cnd_pgto,
          num_pedido_repres, 
          num_list_preco,     
          pct_desc_adic,
          pct_comissao,
          ies_tip_entrega,
          ies_frete,
          cod_tip_carteira,
          ies_finalidade
   FROM pedidos, 
        t_pedido
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = num_ped
     AND ies_sit_pedido = 'E'   
 
   FOREACH cq_pedido INTO p_relat.num_pedido,  
                          p_relat.cod_cliente,          
                          p_relat.cod_repres,           
                          p_relat.num_pedido_cli,   
                          p_relat.dat_emis_repres,  
                          p_relat.pct_desc_adic,   
                          p_relat.cod_transpor,    
                          p_relat.cod_consig,      
                          p_relat.cod_nat_oper,    
                          p_relat.cod_cnd_pgto,    
                          p_relat.num_pedido_repres,
                          p_relat.num_list_preco,
                          p_relat.pct_desc_adicp,
                          p_relat.pct_comis,
                          p_tip_entrega,
                          p_ies_frete,
                          p_cod_tip_carteira,
                          p_ies_finalidade      

      IF p_tela.ies_comis <> "S" THEN
         LET p_relat.pct_comis = 0 
      END IF

      IF p_ies_frete = '3' THEN
         LET p_relat.des_frete = 'FOB'
      ELSE
         LET p_relat.des_frete = 'CIF'
      END IF

      LET p_relat.ies_ac_fin ='Nao' 
      LET p_relat.ies_ac_com ='Nao' 
    
      SELECT nom_cliente,
             num_cgc_cpf,
             end_cliente,
             num_telefone,
             cod_cep,
             cod_cidade 
         INTO p_relat.nom_cliente,  
              p_relat.num_cgc_cpf, 
              p_relat.end_cliente,
              p_relat.num_telefone,
              p_relat.cod_cep,
              p_cod_cidade 
      FROM clientes
      WHERE cod_cliente = p_relat.cod_cliente  

      SELECT raz_social     
         INTO p_relat.raz_social        
      FROM representante 
      WHERE cod_repres = p_relat.cod_repres     

      SELECT den_cidade,
             cod_uni_feder
         INTO p_relat.den_cidade,  
              p_relat.cod_uni_feder
      FROM cidades 
      WHERE cod_cidade = p_cod_cidade 

      SELECT den_nat_oper
         INTO p_relat.den_nat_oper      
      FROM nat_operacao
      WHERE cod_nat_oper = p_relat.cod_nat_oper   

      SELECT den_cnd_pgto
         INTO p_relat.den_cnd_pgto      
      FROM cond_pgto   
      WHERE cod_cnd_pgto = p_relat.cod_cnd_pgto 

      CASE (p_tip_entrega)
         WHEN 1
            LET p_relat.tip_entrega = "TOTAL"
         WHEN 2
            LET p_relat.tip_entrega = "TOTAL/PARCIAL"
         WHEN 3
            LET p_relat.tip_entrega = "PARCIAL/PARCIAL"
         OTHERWISE
            LET p_relat.tip_entrega = "NAO CADASTRADA"
      END CASE 

      SELECT nom_cliente    
         INTO p_relat.nom_transpor    
      FROM clientes    
      WHERE cod_cliente = p_relat.cod_transpor  

      SELECT nom_cliente    
         INTO p_relat.nom_consig      
      FROM clientes    
      WHERE cod_cliente = p_relat.cod_consig    

      INITIALIZE p_relat.email_contato,
                 p_relat.obs_contato   TO NULL 

      DECLARE cq_email CURSOR FOR
         SELECT email_contato,
                obs_contato 
         FROM cli_hayward 
         WHERE cod_cliente = p_relat.cod_cliente   
      FOREACH cq_email INTO p_relat.email_contato,
                            p_relat.obs_contato
         EXIT FOREACH
      END FOREACH
        
      SELECT tex_observ_1,
             tex_observ_2
         INTO p_relat.p_tex_obs_1,   
              p_relat.p_tex_obs_2    
      FROM pedido_dig_obs
      WHERE cod_empresa = p_cod_empresa      
        AND num_pedido = p_relat.num_pedido

      IF SQLCA.sqlcode <> 0 THEN 
         INITIALIZE p_relat.p_tex_obs_1,   
                    p_relat.p_tex_obs_2  TO NULL 
      END IF 
                       
      SELECT den_texto_1, 
             den_texto_2, 
             den_texto_3, 
             den_texto_4, 
             den_texto_5  
         INTO p_relat.p_den_tex_1,   
              p_relat.p_den_tex_2,   
              p_relat.p_den_tex_3,   
              p_relat.p_den_tex_4,   
              p_relat.p_den_tex_5    
      FROM pedido_dig_texto
      WHERE cod_empresa = p_cod_empresa      
        AND num_pedido = p_relat.num_pedido
        AND num_sequencia = 0                  
      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_relat.p_den_tex_1,   
                    p_relat.p_den_tex_2,   
                    p_relat.p_den_tex_3,   
                    p_relat.p_den_tex_4,   
                    p_relat.p_den_tex_5  TO NULL 
      END IF

      DECLARE cq_item CURSOR FOR
      SELECT UNIQUE num_sequencia,
                    cod_item,      
                    qtd_pecas_solic,
                    pre_unit,
                    pct_desc_adic,
                    prz_entrega 
      FROM pedido_dig_item
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_relat.num_pedido 

      FOREACH cq_item INTO p_relat.num_sequencia,
                           p_relat.cod_item,
                           p_relat.qtd_pecas_solic, 
                           p_relat.pre_unit,          
                           p_relat.pct_desc_adici,
                           p_relat.prz_entrega 

         SELECT den_item,
                cod_unid_med,
                pes_unit   
            INTO p_relat.den_item,        
                 p_relat.cod_unid_med, 
                 p_relat.pes_unit
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_relat.cod_item 

            LET p_relat.perc_desc   = pol0203_calcula_desc()             
            LET p_relat.preco_bruto = p_relat.pre_unit
            IF  p_relat.perc_desc   > 0 THEN
                LET p_relat.preco_liq = p_relat.pre_unit * 
                                        ((100 - p_relat.perc_desc) / 100)
            ELSE
               LET p_relat.preco_liq = p_relat.pre_unit
            END IF

         SELECT cod_nat_oper
            INTO p_cod_nat_oper
         FROM ped_dig_it_nat
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_relat.num_pedido
           AND num_sequencia = p_relat.num_sequencia
        
         IF SQLCA.SQLCODE <> 0 THEN  
            let p_cod_nat_oper = p_relat.cod_nat_oper
         end if

         LET p_cod_item = p_relat.cod_item
         LET p_cod_cliente = p_relat.cod_cliente
         LET p_cod_uni_feder = p_relat.cod_uni_feder
         
         if not pol0203_le_param_fisc() then
 #           let p_ies_incid_ipi = 0
         end if

 #        IF p_ies_incid_ipi > 1 THEN
 #           LET p_relat.pct_ipi = 0
 #        END IF

	IF  p_relat.pct_ipi  IS NULL THEN
		LET p_relat.pct_ipi = 0
	END IF
  
 
         IF p_relat.qtd_pecas_solic > 0 AND
            p_relat.preco_liq       > 0 AND
            p_relat.pct_ipi         > 0 THEN
            LET p_relat.preco_ipi = ((p_relat.preco_liq * 
                                      p_relat.qtd_pecas_solic * 
                                      p_relat.pct_ipi) / 100)
         ELSE 
            LET p_relat.preco_ipi = 0
         END IF

         INSERT INTO t_relat 
            VALUES(p_relat.*)                              
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INSERT TABELA-TEMPORARIA","T_RELAT")
            EXIT FOREACH
         END IF

      END FOREACH   
      INITIALIZE p_relat.* TO NULL
      LET p_relat.p_desc_rel = "PEDIDO AGUARDANDO LIBERACAO"
      LET p_count = p_count + 1
      
   END FOREACH   

END FUNCTION

#-------------------------------------#
 FUNCTION pol0203_emite_relatorio_ped()
#-------------------------------------#
   
   DEFINE l_sit_ped           CHAR(01)
   
   LET p_count = 0   

   DECLARE cq_pedido_c CURSOR FOR
   SELECT num_pedido,
          cod_cliente,
          cod_repres,
          num_pedido_cli,
          dat_emis_repres,
          pct_desc_adic,
          cod_transpor,
          cod_consig,
          cod_nat_oper,
          cod_cnd_pgto,
          num_pedido_repres, 
          num_list_preco,     
          pct_desc_adic,
          pct_comissao,
          ies_tip_entrega,
          ies_frete,
          ies_sit_pedido,
          ies_aceite
   FROM pedidos, 
        t_pedido
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = num_ped
     AND ies_sit_pedido <> '9'
 
   FOREACH cq_pedido_c INTO p_relat.num_pedido,  
                            p_relat.cod_cliente,          
                            p_relat.cod_repres,           
                            p_relat.num_pedido_cli,   
                            p_relat.dat_emis_repres,  
                            p_relat.pct_desc_adic,   
                            p_relat.cod_transpor,    
                            p_relat.cod_consig,      
                            p_relat.cod_nat_oper,    
                            p_relat.cod_cnd_pgto,    
                            p_relat.num_pedido_repres,
                            p_relat.num_list_preco,
                            p_relat.pct_desc_adicp,
                            p_relat.pct_comis,
                            p_tip_entrega,
                            p_ies_frete,
                            l_sit_ped,
                            p_relat.ies_aceite    

      IF l_sit_ped = 'E' THEN
         LET p_relat.p_desc_rel = "PEDIDO AGUARDANDO LIBERACAO"
      ELSE
         LET p_relat.p_desc_rel = "PEDIDO EM CARTEIRA"
      END IF
      
      IF p_tela.ies_comis <> "S" THEN
         LET p_relat.pct_comis = 0 
      END IF

      SELECT nom_cliente,
             num_cgc_cpf,
             end_cliente,
             num_telefone,
             cod_cep,
             cod_cidade 
         INTO p_relat.nom_cliente,  
              p_relat.num_cgc_cpf, 
              p_relat.end_cliente,
              p_relat.num_telefone,
              p_relat.cod_cep,
              p_cod_cidade 
      FROM clientes
      WHERE cod_cliente = p_relat.cod_cliente  

      SELECT raz_social     
         INTO p_relat.raz_social        
      FROM representante 
      WHERE cod_repres = p_relat.cod_repres     

      IF p_ies_frete = '3' THEN
         LET p_relat.des_frete = 'FOB'
      ELSE
         LET p_relat.des_frete = 'CIF'
      END IF

      LET p_relat.ies_ac_fin ='Sim' 
      LET p_relat.ies_ac_com ='Sim' 
    
      SELECT den_cidade,
             cod_uni_feder
         INTO p_relat.den_cidade,  
              p_relat.cod_uni_feder
      FROM cidades 
      WHERE cod_cidade = p_cod_cidade 

      SELECT den_nat_oper
         INTO p_relat.den_nat_oper      
      FROM nat_operacao
      WHERE cod_nat_oper = p_relat.cod_nat_oper   

      SELECT den_cnd_pgto
         INTO p_relat.den_cnd_pgto      
      FROM cond_pgto   
      WHERE cod_cnd_pgto = p_relat.cod_cnd_pgto 

      CASE (p_tip_entrega)
         WHEN 1
            LET p_relat.tip_entrega = "TOTAL"
         WHEN 2
            LET p_relat.tip_entrega = "TOTAL/PARCIAL"
         WHEN 3
            LET p_relat.tip_entrega = "PARCIAL/PARCIAL"
         OTHERWISE
            LET p_relat.tip_entrega = "NAO CADASTRADA"
      END CASE 

      SELECT nom_cliente    
         INTO p_relat.nom_transpor    
      FROM clientes    
      WHERE cod_cliente = p_relat.cod_transpor  

      SELECT nom_cliente    
         INTO p_relat.nom_consig      
      FROM clientes    
      WHERE cod_cliente = p_relat.cod_consig    

      INITIALIZE p_relat.email_contato,
                 p_relat.obs_contato   TO NULL 

      SELECT email_contato,
             obs_contato 
         INTO p_relat.email_contato,
              p_relat.obs_contato
      FROM cli_hayward 
      WHERE cod_cliente = p_relat.cod_cliente   

      SELECT tex_observ_1,
             tex_observ_2
         INTO p_relat.p_tex_obs_1,   
              p_relat.p_tex_obs_2    
      FROM ped_observacao
      WHERE cod_empresa = p_cod_empresa      
        AND num_pedido = p_relat.num_pedido

      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_relat.p_tex_obs_1,   
                    p_relat.p_tex_obs_2  TO NULL   
      END IF 

      SELECT den_texto_1, 
             den_texto_2, 
             den_texto_3, 
             den_texto_4, 
             den_texto_5  
        INTO p_relat.p_den_tex_1,   
             p_relat.p_den_tex_2,   
             p_relat.p_den_tex_3,   
             p_relat.p_den_tex_4,   
             p_relat.p_den_tex_5    
      FROM ped_itens_texto
      WHERE cod_empresa = p_cod_empresa      
        AND num_pedido = p_relat.num_pedido
        AND num_sequencia = 0                  

      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_relat.p_den_tex_1,   
                    p_relat.p_den_tex_2,   
                    p_relat.p_den_tex_3,   
                    p_relat.p_den_tex_4,   
                    p_relat.p_den_tex_5  TO NULL 
      END IF

      DECLARE cq_itemp CURSOR FOR
      SELECT UNIQUE num_sequencia,
                    cod_item,      
                    (qtd_pecas_solic-qtd_pecas_atend-qtd_pecas_romaneio-qtd_pecas_cancel),
                    pre_unit,
                    pct_desc_adic,
                    prz_entrega 
      FROM ped_itens
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_relat.num_pedido 
        AND (qtd_pecas_solic-qtd_pecas_atend-qtd_pecas_romaneio-qtd_pecas_cancel) > 0

      FOREACH cq_itemp INTO p_relat.num_sequencia,
                            p_relat.cod_item,
                            p_relat.qtd_pecas_solic, 
                            p_relat.pre_unit,          
                            p_relat.pct_desc_adici,
                            p_relat.prz_entrega 

         SELECT den_item,
                cod_unid_med,
                pes_unit  
            INTO p_relat.den_item,        
                 p_relat.cod_unid_med, 
                 p_relat.pes_unit         
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_relat.cod_item 

            LET p_relat.perc_desc   = pol0203_calcula_desc_c()             
            LET p_relat.preco_bruto = p_relat.pre_unit
            IF  p_relat.perc_desc   > 0 THEN
                LET p_relat.preco_liq = p_relat.pre_unit * 
                                        ((100 - p_relat.perc_desc) / 100)
            ELSE
               LET p_relat.preco_liq = p_relat.pre_unit
            END IF

         SELECT cod_nat_oper
           INTO p_cod_nat_oper
           FROM ped_item_nat
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_relat.num_pedido
            AND num_sequencia = p_relat.num_sequencia

         IF SQLCA.SQLCODE <> 0 THEN  
            let p_cod_nat_oper = p_relat.cod_nat_oper
         end if
         
         LET p_cod_item = p_relat.cod_item
         LET p_cod_cliente = p_relat.cod_cliente
         LET p_cod_uni_feder = p_relat.cod_uni_feder
         
         if not pol0203_le_param_fisc() then
 #           let p_ies_incid_ipi = 0
         end if
         
 #        IF p_ies_incid_ipi > 1 THEN
 #           LET p_relat.pct_ipi = 0
  #       END IF
  
  
  	IF  p_relat.pct_ipi  IS NULL THEN
		LET p_relat.pct_ipi = 0
	END IF
  

         IF p_relat.qtd_pecas_solic > 0 AND
            p_relat.preco_liq       > 0 AND
            p_relat.pct_ipi         > 0 THEN
            LET p_relat.preco_ipi = ((p_relat.preco_liq * 
                                      p_relat.qtd_pecas_solic * 
                                      p_relat.pct_ipi) / 100)
         ELSE 
            LET p_relat.preco_ipi = 0
         END IF

         INSERT INTO t_relat 
            VALUES(p_relat.*)                              
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INSERT TABELA-TEMPORARIA","T_RELAT")
            EXIT FOREACH
         END IF

      END FOREACH   
      INITIALIZE p_relat.* TO NULL
      LET p_count = p_count + 1

   END FOREACH   
   DELETE FROM t_pedido          

END FUNCTION

#------------------------------#
 FUNCTION pol0203_calcula_desc()
#------------------------------# 

   DEFINE p_ped_dig_item_desc       RECORD LIKE ped_dig_item_desc.*,
          p_ped_itens_desc          RECORD LIKE ped_itens_desc.*,
          p_cod_item_comp           LIKE estrutura_vdp.cod_item_compon,
          p_ped_den_item_reduz      LIKE item.den_item_reduz,
          p_val                     DECIMAL(17,6),
          p_pct_desc                DECIMAL(5,2)

   SELECT cod_item_compon
      INTO p_cod_item_comp 
   FROM estrutura_vdp 
   WHERE cod_empresa = p_cod_empresa 
     AND cod_item    = p_relat.cod_item
   IF sqlca.sqlcode  = 0 THEN
      LET p_relat.cod_item = p_cod_item_comp
      SELECT den_item_reduz
         INTO p_ped_den_item_reduz 
      FROM item
      WHERE cod_empresa = p_cod_empresa 
        AND cod_item    = p_cod_item_comp
   END IF 

   LET p_val = 100
   LET p_pct_desc = 0

   IF p_relat.pct_desc_adicp > 0 THEN  # pedido_dig_mest
      LET p_val = p_val * ((100 - p_relat.pct_desc_adicp)/100)
   END IF

   IF p_relat.pct_desc_adici > 0 THEN  # pedido_dig_item
      LET p_val = p_val * ((100 - p_relat.pct_desc_adici)/100)
   END IF

   SELECT *                
      INTO p_ped_dig_item_desc.* 
   FROM ped_dig_item_desc #  ped_dig_item_desc
   WHERE cod_empresa   = p_cod_empresa 
     AND num_pedido    = p_relat.num_pedido
     AND num_sequencia = 0 
   IF sqlca.sqlcode = 0 THEN  
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_1)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_2)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_3)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_4)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_5)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_6)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_7)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_8)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_9)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_10)/100)
   END IF
  
   SELECT *               
      INTO p_ped_itens_desc.*
   FROM ped_dig_item_desc #  ped_dig_item_desc
   WHERE cod_empresa   = p_cod_empresa 
     AND num_pedido    = p_relat.num_pedido
     AND num_sequencia = p_relat.num_sequencia
   IF sqlca.sqlcode = 0 THEN  
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_1)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_2)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_3)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_4)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_5)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_6)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_7)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_8)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_9)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_10)/100)
   END IF

   LET p_pct_desc = 100 - p_val   

   RETURN p_pct_desc

END FUNCTION

#--------------------------------#
 FUNCTION pol0203_calcula_desc_c()
#--------------------------------# 

   DEFINE p_ped_dig_item_desc   RECORD LIKE ped_dig_item_desc.*,
          p_ped_itens_desc      RECORD LIKE ped_itens_desc.*,
          p_cod_item_comp       LIKE estrutura_vdp.cod_item_compon,
          p_ped_den_item_reduz  LIKE item.den_item_reduz,
          p_val                 DECIMAL(17,6),
          p_pct_desc            DECIMAL(5,2)

   SELECT cod_item_compon
      INTO p_cod_item_comp 
   FROM estrutura_vdp 
   WHERE cod_empresa = p_cod_empresa 
     AND cod_item    = p_relat.cod_item
   IF sqlca.sqlcode  = 0 THEN
      LET p_relat.cod_item = p_cod_item_comp
      SELECT den_item_reduz
         INTO p_ped_den_item_reduz 
      FROM item
      WHERE cod_empresa = p_cod_empresa 
        AND cod_item    = p_cod_item_comp
   END IF 

   LET p_val = 100
   LET p_pct_desc = 0

   IF p_relat.pct_desc_adicp > 0 THEN  # pedido_dig_mest
      LET p_val = p_val * ((100 - p_relat.pct_desc_adicp)/100)
   END IF

   IF p_relat.pct_desc_adici > 0 THEN  # pedido_dig_item
      LET p_val = p_val * ((100 - p_relat.pct_desc_adici)/100)
   END IF

   SELECT *                
      INTO p_ped_dig_item_desc.* 
   FROM ped_itens_desc #  ped_itens_desc
   WHERE cod_empresa   = p_cod_empresa 
     AND num_pedido    = p_relat.num_pedido
     AND num_sequencia = 0 
   IF sqlca.sqlcode = 0 THEN  
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_1)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_2)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_3)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_4)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_5)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_6)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_7)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_8)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_9)/100)
      LET p_val = p_val * ((100 - p_ped_dig_item_desc.pct_desc_10)/100)
   END IF
  
   SELECT *               
      INTO p_ped_itens_desc.*
   FROM ped_itens_desc #  ped_itens_desc
   WHERE cod_empresa   = p_cod_empresa 
     AND num_pedido    = p_relat.num_pedido
     AND num_sequencia = p_relat.num_sequencia
   IF sqlca.sqlcode = 0 THEN  
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_1)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_2)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_3)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_4)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_5)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_6)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_7)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_8)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_9)/100)
      LET p_val = p_val * ((100 - p_ped_itens_desc.pct_desc_10)/100)
   END IF

   LET p_pct_desc = 100 - p_val   

   RETURN p_pct_desc

END FUNCTION

#-----------------------------#
 FUNCTION pol0203_emite_relat()                              
#-----------------------------# 

   DECLARE cq_relat CURSOR FOR
   SELECT * FROM t_relat
   ORDER BY p_desc_rel, num_pedido,
            num_sequencia
   
   FOREACH cq_relat INTO p_relat.* 
   
   
   SELECT des_ESP_ITEM[1,10]
    INTO p_endereco.p_ender
    FROM esp_item_sup 
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_relat.cod_item
     AND ies_tip_inf = '06'

      OUTPUT TO REPORT pol0203_relat(p_relat.*)                               
 
      LET p_count = p_count + 1
 
      INITIALIZE p_endereco.p_ender TO NULL
      INITIALIZE p_relat.* TO NULL

   END FOREACH   
   DELETE FROM t_relat           

END FUNCTION

#----------------------------#
 REPORT pol0203_relat(p_relat)                              
#----------------------------# 

   DEFINE p_relat RECORD 
      num_pedido          LIKE pedido_dig_mest.num_pedido,
      cod_cliente         LIKE pedido_dig_mest.cod_cliente,          
      cod_repres          LIKE pedido_dig_mest.cod_repres,           
      num_pedido_cli      LIKE pedido_dig_mest.num_pedido_cli,   
      dat_emis_repres     LIKE pedido_dig_mest.dat_emis_repres,  
      pct_desc_adic       LIKE pedido_dig_mest.pct_desc_adic,   
      cod_transpor        LIKE pedido_dig_mest.cod_transpor,    
      cod_consig          LIKE pedido_dig_mest.cod_consig,      
      cod_nat_oper        LIKE pedido_dig_mest.cod_nat_oper,    
      cod_cnd_pgto        LIKE pedido_dig_mest.cod_cnd_pgto,    
      num_pedido_repres   LIKE pedido_dig_mest.num_pedido_repres,
      num_list_preco      LIKE pedido_dig_mest.num_list_preco,
      pct_desc_adicp      LIKE pedido_dig_mest.pct_desc_adic, 
      nom_cliente         LIKE clientes.nom_cliente,
      num_cgc_cpf         LIKE clientes.num_cgc_cpf,
      end_cliente         LIKE clientes.end_cliente,  
      num_telefone        LIKE clientes.num_telefone,
      cod_cep             LIKE clientes.cod_cep,      
      raz_social          LIKE representante.raz_social,
      den_cidade          LIKE cidades.den_cidade,
      cod_uni_feder       LIKE cidades.cod_uni_feder,
      den_nat_oper        LIKE nat_operacao.den_nat_oper,
      den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
      tip_entrega         CHAR (015),
      nom_transpor        LIKE clientes.nom_cliente,
      nom_consig          LIKE clientes.nom_cliente, 
      num_sequencia       LIKE pedido_dig_item.num_sequencia,
      cod_item            LIKE pedido_dig_item.cod_item, 
      qtd_pecas_solic     LIKE pedido_dig_item.qtd_pecas_solic,
      pre_unit            DECIMAL(15,4),
      pct_desc_adici      LIKE pedido_dig_item.pct_desc_adic, 
      prz_entrega         LIKE pedido_dig_item.prz_entrega,
      den_item 	          LIKE item.den_item,
      cod_unid_med        LIKE item.cod_unid_med,
      pes_unit            LIKE item.pes_unit,
      pct_ipi             LIKE item.pct_ipi,
      email_contato       LIKE cli_hayward.email_contato, 
      obs_contato         LIKE cli_hayward.obs_contato,
      preco_bruto         DECIMAL(15,4),
      preco_liq           DECIMAL(15,4),
      preco_ipi           LIKE pedido_dig_item.pre_unit, 
      perc_desc           LIKE ped_itens_desc.pct_desc_1,
      pct_comis           LIKE pedido_dig_mest.pct_comissao,
      p_tex_obs_1         LIKE ped_observacao.tex_observ_1, 
      p_tex_obs_2         LIKE ped_observacao.tex_observ_2, 
      p_den_tex_1         LIKE ped_itens_texto.den_texto_1, 
      p_den_tex_2         LIKE ped_itens_texto.den_texto_2, 
      p_den_tex_3         LIKE ped_itens_texto.den_texto_3, 
      p_den_tex_4         LIKE ped_itens_texto.den_texto_4, 
      p_den_tex_5         LIKE ped_itens_texto.den_texto_5,  
      p_desc_rel          CHAR(27),
      perc_desc_at        LIKE ped_itens_desc.pct_desc_1,
      ies_ac_fin          CHAR(03), 
      ies_ac_com          CHAR(03),
      des_frete           CHAR(03),
      ies_aceite          CHAR(01)
   END RECORD ,
   p_val_total            DEC(15,2)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 6
          PAGE   LENGTH 66

   FORMAT

      PAGE HEADER  

         LET p_num_pag = p_num_pag+1
         PRINT COLUMN 001, p_comprime, p_den_empresa,"  ",p_relat.p_desc_rel, 
               COLUMN 103, "PEDIDO NUMERO *** ", p_relat.num_pedido, " ***"
         PRINT COLUMN 001, "POL0203",
               COLUMN 054, "P E D I D O    I N T E R N O",
               COLUMN 125, "FL. ", p_num_pag USING "###&"
         PRINT COLUMN 001, "DATA EMISSAO: ", TODAY,
               COLUMN 096, "EXTRAIDO EM ",TODAY USING "DD/MM/YY"," AS ",
                           TIME," HRS." 
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------*"
         PRINT COLUMN 043, "*** D A D O S      D O      C L I E N T E ***"
         SKIP 1 LINE 
         PRINT COLUMN 001, "COD. CLIENTE..: ", p_relat.cod_cliente,
               COLUMN 034, "CNPJ.CPF.: ", p_relat.num_cgc_cpf,
                           " ", p_relat.nom_cliente  
         PRINT COLUMN 001, "REPRESENTANTE.: ", p_relat.cod_repres,
                           " ", p_relat.raz_social   
         PRINT COLUMN 001, "ENDERECO......: ", p_relat.end_cliente,  
               COLUMN 075, "FONE....: ", p_relat.num_telefone 
         PRINT COLUMN 001, "CIDADE........: ", p_relat.den_cidade,
               COLUMN 075, "CEP.....: ", p_relat.cod_cep,     
               COLUMN 105, "UF.... ", p_relat.cod_uni_feder  
         PRINT COLUMN 001, "CIDADE ENTREG.: ", p_relat.den_cidade, 
               COLUMN 075, "CEP.....: " ,p_relat.cod_cep 
         PRINT COLUMN 001, "ENDERECO ENTR.: "
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------*"
         PRINT COLUMN 046, "*** D A D O S    D O    P E D I D O ***"
         SKIP 1 LINE 
         PRINT COLUMN 001, "PEDIDO CLIENTE: ", p_relat.num_pedido_cli,
               COLUMN 045, "OPERACAO......: ", p_relat.cod_nat_oper USING "###&", " ",p_relat.den_nat_oper,
               COLUMN 098, "ENTREGA.......: " ,p_relat.tip_entrega 
         PRINT COLUMN 001, "DATA EMISS....: ", p_relat.dat_emis_repres,
               COLUMN 045, "COND. PGTO....: ", p_relat.cod_cnd_pgto, " ",p_relat.den_cnd_pgto,
               COLUMN 098, "ACEITE........: ", p_relat.ies_aceite
         PRINT COLUMN 001, "% DESC. ADIC..: ", p_relat.pct_desc_adic,  
               COLUMN 045, "PEDIDO REPRES.: ", p_relat.num_pedido_repres
               #COLUMN 098, "ACEITE FINAN..: ", p_relat.ies_ac_fin
         PRINT COLUMN 001, "TABELA PRECO..: ", p_relat.num_list_preco,
               COLUMN 045, "COMISSAO......: ", p_relat.pct_comis,
               COLUMN 098, "FRETE.........: ", p_relat.des_frete
         PRINT COLUMN 001, "TRANSPORTADORA: ", p_relat.cod_transpor, " ",
                           p_relat.nom_transpor 
         PRINT COLUMN 001, "CONSIGNATARIO : ", p_relat.cod_consig,    
                           p_relat.nom_consig   
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------*"
         PRINT COLUMN 001, " ITEM PRODUTO",
               COLUMN 021, "UN  DESCRICAO DO PRODUTO"
         PRINT COLUMN 026, "SOLICITADA",
               COLUMN 056, "PESO BRUTO",
               COLUMN 067, "PRECO BRUTO",
               COLUMN 080, "PRECO LIQ",
               COLUMN 090, "% DESC",     
               COLUMN 097, "PCT.IPI",     
               COLUMN 105, "VAL IPI",     
               COLUMN 113, "ENTREGA",
               COLUMN 122, "ENDERECO"

      BEFORE GROUP OF p_relat.num_pedido  
         SKIP TO TOP OF PAGE

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_sequencia USING "####&",
               COLUMN 007, p_relat.cod_item[1,13], 
               COLUMN 021, p_relat.cod_unid_med, 
               COLUMN 025, p_relat.den_item  
         PRINT COLUMN 026, p_relat.qtd_pecas_solic USING "##,##&.&&&",
               COLUMN 055, p_relat.qtd_pecas_solic * p_relat.pes_unit  USING "###,##&.&&&&",
               COLUMN 064, p_relat.preco_bruto USING "##,##&.&&&&",
               COLUMN 075, p_relat.preco_liq   USING "##,##&.&&&&",
               COLUMN 089, p_relat.perc_desc   USING "##&.&&",
               COLUMN 096, p_relat.pct_ipi     USING "##&.&&",
               COLUMN 097, p_relat.preco_ipi   USING "##,##&.&&",
               COLUMN 113, p_relat.prz_entrega USING "dd/mm/yy",
               COLUMN 122, p_endereco.p_ender

      AFTER GROUP OF p_relat.num_pedido  

         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------*"
         PRINT COLUMN 001, "T O T A I S...:  PESO...: ", 
                           group sum(p_relat.qtd_pecas_solic * p_relat.pes_unit)
                           USING "###,##&.&&&&",
               COLUMN 052, "VALOR BRUTO..: ", group sum(p_relat.preco_bruto * 
                                                        p_relat.qtd_pecas_solic)
                           USING "##,###,##&.&&",
               COLUMN 088, "VALOR LIQ....: ", group sum(p_relat.preco_liq *
                                                        p_relat.qtd_pecas_solic)
                           USING "##,###,##&.&&" 
         PRINT COLUMN 018, "PECAS..: ", group sum(p_relat.qtd_pecas_solic)
                           USING "####,##&",
               COLUMN 052, "VALOR IPI....: ", group sum(p_relat.preco_ipi)
                           USING "##,###,##&.&&",
               COLUMN 088, "VALOR TOTAL..: ", group sum(p_relat.preco_ipi +  
                           (p_relat.preco_liq * p_relat.qtd_pecas_solic))
                           USING "##,###,##&.&&" 
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------*"
 
         IF p_relat.email_contato IS NOT NULL THEN	
            PRINT COLUMN 001, "OBSERVACAO...: ", p_relat.email_contato  
            PRINT COLUMN 016, p_relat.obs_contato 
            IF p_relat.p_tex_obs_1 IS NOT NULL THEN
               PRINT COLUMN 001, p_relat.p_tex_obs_1       
               PRINT COLUMN 001, p_relat.p_tex_obs_2       
               IF p_relat.p_den_tex_1 IS NOT NULL THEN
                  PRINT COLUMN 001, p_relat.p_den_tex_1       
                  PRINT COLUMN 001, p_relat.p_den_tex_2       
                  PRINT COLUMN 001, p_relat.p_den_tex_3       
                  PRINT COLUMN 001, p_relat.p_den_tex_4       
                  PRINT COLUMN 001, p_relat.p_den_tex_5
               END IF
            ELSE 
               IF p_relat.p_den_tex_1 IS NOT NULL THEN
                  PRINT COLUMN 001, p_relat.p_den_tex_1       
                  PRINT COLUMN 001, p_relat.p_den_tex_2       
                  PRINT COLUMN 001, p_relat.p_den_tex_3       
                  PRINT COLUMN 001, p_relat.p_den_tex_4       
                  PRINT COLUMN 001, p_relat.p_den_tex_5
               END IF
            END IF
         ELSE 
            IF p_relat.p_tex_obs_1 IS NOT NULL THEN
               PRINT COLUMN 001, p_relat.p_tex_obs_1       
               PRINT COLUMN 001, p_relat.p_tex_obs_2       
               IF p_relat.p_den_tex_1 IS NOT NULL THEN
                  PRINT COLUMN 001, p_relat.p_den_tex_1       
                  PRINT COLUMN 001, p_relat.p_den_tex_2       
                  PRINT COLUMN 001, p_relat.p_den_tex_3       
                  PRINT COLUMN 001, p_relat.p_den_tex_4       
                  PRINT COLUMN 001, p_relat.p_den_tex_5
               END IF
            ELSE 
               IF p_relat.p_den_tex_1 IS NOT NULL THEN
                  PRINT COLUMN 001, p_relat.p_den_tex_1       
                  PRINT COLUMN 001, p_relat.p_den_tex_2       
                  PRINT COLUMN 001, p_relat.p_den_tex_3       
                  PRINT COLUMN 001, p_relat.p_den_tex_4       
                  PRINT COLUMN 001, p_relat.p_den_tex_5
               END IF
            END IF
         END IF
         LET p_num_pag = 0          

END REPORT


#------------------------------ LEITURA DOS PARÂMETROS FISCAIS -------------------------------#

#-------------------------------#
FUNCTION pol0203_le_param_fisc()
#-------------------------------#

   DEFINE p_tip_item        CHAR(01),
          p_cod_movto_estoq LIKE nat_operacao.cod_movto_estoq,
          m_msg             CHAR(600),
          p_sem_tributo     SMALLINT,
          p_tip_config      like obf_tributo_benef.tip_config,
          p_prioridade      like obf_tributo_benef.prioridade,
          p_ies_tipo        char(01)
   
   LET p_msg = NULL
   LET m_msg = "Configuração fiscal não encontrada para o tributo(s) abaixo:","\n"   
   LET p_sem_tributo = FALSE
   
   LET p_ies_tipo = 'S' 
   
   SELECT parametro_ind
    INTO p_tip_item
    FROM vdp_parametro_item 
   WHERE empresa   = p_cod_empresa
     AND item      = p_cod_item
     AND parametro = 'tipo_item'
  
   
	IF STATUS = 100 THEN
		LET p_tip_item = 'P' 
	ELSE	
		IF STATUS <> 0 THEN
			CALL log003_err_sql('Lendo','vdp_parametro_item')
			RETURN FALSE
		END IF
	END IF
		
   LET p_tributo_benef = 'IPI'
   
   SELECT COUNT(a.tributo_benef)
     INTO p_count
     FROM obf_oper_fiscal a, obf_tributo_benef b
    WHERE a.empresa           = p_cod_empresa
      AND a.origem            = p_ies_tipo
      AND a.nat_oper_grp_desp = p_cod_nat_oper
      AND a.Tip_Item          IN ('A',p_tip_item) 
      AND b.empresa           = a.empresa 
      AND b.tributo_benef     = a.tributo_benef 
      AND b.ativo             IN ('S','A') 
      AND a.tributo_benef     = p_tributo_benef

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tributos')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      RETURN FALSE
   END IF

   SELECT cod_lin_prod,                             
          cod_lin_recei,                                     
          cod_seg_merc,                                      
          cod_cla_uso,                                       
          cod_familia,                                       
          gru_ctr_estoq,                                     
          cod_cla_fisc,                                      
          cod_unid_med                                       
     INTO p_cod_lin_prod,                                    
          p_cod_lin_recei,                                   
          p_cod_seg_merc,                                    
          p_cod_cla_uso,                                     
          p_cod_familia,                                     
          p_gru_ctr_estoq,                                   
          p_cod_cla_fisc,                                    
          p_cod_unid_med                                     
     FROM item                                               
    WHERE cod_empresa  = p_cod_empresa                       
      AND cod_item     = p_cod_item          
      AND ies_situacao = 'A'                                 
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   SELECT tip_parametro
     INTO p_micro_empresa
     FROM vdp_cli_parametro
    WHERE cliente   = p_relat.cod_cliente 
      AND parametro = 'microempresa'

   LET p_ies_tributo = FALSE
      
   DECLARE cq_tributos CURSOR FOR
    SELECT a.tributo_benef, b.tip_config, b.prioridade
      FROM obf_oper_fiscal a, obf_tributo_benef b
     WHERE a.empresa           = p_cod_empresa
       AND a.origem            = 'S'
       AND a.nat_oper_grp_desp = p_cod_nat_oper
       AND a.tip_item          IN ('A',p_tip_item) 
       AND b.empresa           = a.empresa 
       AND b.tributo_benef     = a.tributo_benef 
       AND b.ativo             IN ('S','A') 
       AND a.tributo_benef     = p_tributo_benef
     ORDER BY b.tip_config, b.prioridade   

   FOREACH  cq_tributos INTO
            p_tributo_benef, p_tip_config, p_prioridade

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tributos')
         RETURN FALSE
      END IF

      LET p_ies_tributo = FALSE
      
      DECLARE cq_acesso CURSOR FOR
       SELECT sequencia_acesso
         FROM obf_ctr_acesso
        WHERE empresa         = p_cod_empresa
          AND controle_acesso = p_tributo_benef
          AND origem          = p_ies_tipo
        ORDER BY num_ctr_acesso DESC
      
      FOREACH cq_acesso INTO p_seq_acesso
      
         LET p_seq_acesso = p_seq_acesso CLIPPED
         
         IF LENGTH(p_seq_acesso) = 0  or p_seq_acesso = ' ' THEN
            CONTINUE FOREACH
         END IF
         
         CALL pol0203_pega_chave()

         IF NOT pol0203_checa_tributo() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_tributo THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      IF NOT p_ies_tributo THEN
         LET p_sem_tributo = TRUE
      END IF

   END FOREACH
      
   IF NOT p_sem_tributo THEN
      RETURN FALSE
   END IF

  
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0203_pega_chave()
#----------------------------#

   DEFINE m_ind       SMALLINT,
          p_letra     CHAR(01)
   
   DELETE FROM chave_tmp_7662
   INITIALIZE p_chave TO NULL
   
   FOR m_ind = 2 TO LENGTH(p_seq_acesso)
       
       LET p_letra = p_seq_acesso[m_ind]
       
       IF p_letra = '|' THEN
          IF p_chave IS NOT NULL THEN
             INSERT INTO chave_tmp_7662 VALUES(p_chave)
             INITIALIZE p_chave TO NULL
          END IF
       ELSE
          LET p_chave = p_chave CLIPPED, p_letra
       END IF
   
   END FOR
      
END FUNCTION

#-------------------------------#
FUNCTION pol0203_checa_tributo()
#-------------------------------#

   DEFINE p_cheve_ok SMALLINT
  
   LET p_ies_tipo = 'S' 
   LET p_cheve_ok = FALSE
   LET p_matriz = 'SSSSSSSSSSSSSSSSSSSSSS'

   LET p_query = 
       "SELECT trans_config ,   incide, aliquota FROM obf_config_fiscal ",   
       " WHERE empresa = '",p_cod_empresa,"' ",
       " AND origem  = '",p_ies_tipo,"' ",
       " AND tributo_benef = '",p_tributo_benef,"' "

   
	   
   DECLARE cq_chave CURSOR FOR
    SELECT chave
      FROM chave_tmp_7662
   
   FOREACH cq_chave INTO p_chave
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_chave')
         RETURN FALSE
      END IF
      
      LET p_cheve_ok = TRUE
      
      CASE p_chave
      
      WHEN 'NAT_OPER' 
         LET p_query  = p_query CLIPPED, " AND nat_oper_grp_desp = '",p_cod_nat_oper,"' "
         LET p_matriz[1] = 'N'
      
      WHEN 'REGIAO' 
         IF NOT pol0203_le_obf_regiao() THEN
            RETURN FALSE
         END IF
		 LET p_matriz[2] = 'N'
		 IF p_regiao_fiscal IS NULL THEN 
			LET p_query  = p_query CLIPPED, " AND grp_fiscal_regiao IS NULL"
		 ELSE
			LET p_query  = p_query CLIPPED, " AND grp_fiscal_regiao = '",p_regiao_fiscal,"' "
		 END IF 	

      WHEN 'ESTADO'
         LET p_query  = p_query CLIPPED, " AND estado = '",p_cod_uni_feder,"' "
         LET p_matriz[3] = 'N'

      WHEN 'MUNICIPIO' 
         LET p_query  = p_query CLIPPED, " AND municipio = '",p_cod_cidade,"' "
         LET p_matriz[4] = 'N'

      WHEN 'CARTEIRA' 
         LET p_query  = p_query CLIPPED, " AND carteira = '",p_cod_tip_carteira,"' "
         LET p_matriz[5] = 'N'

      WHEN 'FINALIDADE' 
         LET p_query  = p_query CLIPPED, " AND finalidade = '",p_ies_finalidade,"' "
         LET p_matriz[6] = 'N'

      WHEN 'FAMILIA_IT' 
         LET p_query  = p_query CLIPPED, " AND familia_item = '",p_cod_familia,"' "
         LET p_matriz[7] = 'N'

      WHEN 'GRP_ESTOQUE' 
         LET p_query  = p_query CLIPPED, " AND grupo_estoque = '",p_gru_ctr_estoq,"' "
         LET p_matriz[8] = 'N'

      WHEN 'GRP_CLASSIF' 
         IF NOT pol0203_le_obf_cl_fisc() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_classif = '",p_grp_classif_fisc,"' "
         LET p_matriz[9] = 'N'

      WHEN 'CLAS_FISC' 
         LET p_query  = p_query CLIPPED, " AND classif_fisc = '",p_cod_cla_fisc,"' "
         LET p_matriz[10] = 'N'

      WHEN 'LIN_PROD' 
         LET p_query  = p_query CLIPPED, " AND linha_produto = '",p_cod_lin_prod,"' "
         LET p_matriz[11] = 'N'

      WHEN 'LIN_REC' 
         LET p_query  = p_query CLIPPED, " AND linha_receita = '",p_cod_lin_recei,"' "
         LET p_matriz[12] = 'N'

      WHEN 'SEGTO_MERC' 
         LET p_query  = p_query CLIPPED, " AND segmto_mercado = '",p_cod_seg_merc,"' "
         LET p_matriz[13] = 'N'

      WHEN 'CLASSE_USO' 
         LET p_query  = p_query CLIPPED, " AND classe_uso = '",p_cod_cla_uso,"' "
         LET p_matriz[14] = 'N'

      WHEN 'UNID_MED' 
         LET p_query  = p_query CLIPPED, " AND unid_medida = '",p_cod_unid_med,"' "
         LET p_matriz[15] = 'N'

      WHEN 'GRP_ITEM' 
         IF NOT pol0203_le_obf_fisc_item() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grupo_fiscal_item = '",p_grp_fiscal_item,"' "
         LET p_matriz[17] = 'N'

      WHEN 'ITEM' 
         LET p_query  = p_query CLIPPED, " AND item = '",p_cod_item,"' "
         LET p_matriz[18] = 'N'

      WHEN 'MICRO_EMPR' 
         LET p_query  = p_query CLIPPED, " AND micro_empresa = '",p_micro_empresa,"' "
         LET p_matriz[19] = 'N'

      WHEN 'GRP_CLIENTE' 
         IF NOT pol0203_le_obf_fisc_cli() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_cliente = '",p_grp_fisc_cliente,"' "
         LET p_matriz[20] = 'N'

      WHEN 'CLIENTE' 
         LET p_query  = p_query CLIPPED, " AND cliente = '",p_cod_cliente,"' "
         LET p_matriz[21] = 'N'

      WHEN 'X'
      WHEN 'BONIF'
      WHEN 'VIA_TRANSP'
      
      OTHERWISE 
         LET p_cheve_ok = FALSE
  
   END CASE
   
   END FOREACH

   IF p_cheve_ok THEN

 #     LET p_query  = p_query CLIPPED, " AND matriz        = '",p_matriz,"' "
   
      PREPARE var_query FROM p_query   
      DECLARE cq_obf_cfg CURSOR FOR var_query

      FOREACH cq_obf_cfg INTO p_trans_config,  p_ies_incid_ipi, p_relat.pct_ipi

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','cq_obf_cfg')
            RETURN FALSE
         END IF
      
         LET p_ies_tributo = TRUE
         EXIT FOREACH
      
   
      END FOREACH
   
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0203_le_obf_regiao()
#-------------------------------#

   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = p_cod_empresa
         AND tributo_benef = p_tributo_benef
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
	  ELSE
            IF STATUS <> 0 THEN
				CALL log003_err_sql('Lendo1', 'obf_regiao_fiscal')
				RETURN FALSE
			END IF	  
      END IF
   ELSE
            IF STATUS <> 0 THEN
				CALL log003_err_sql('Lendo2', 'obf_regiao_fiscal')
				RETURN FALSE
			END IF	  
   END IF
     
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION pol0203_le_obf_cl_fisc()
#-------------------------------#

   SELECT grupo_classif_fisc
     INTO p_grp_classif_fisc
     FROM obf_grp_cl_fisc
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND classif_fisc  = p_cod_cla_fisc
   
   IF STATUS = 100 THEN
      LET p_grp_classif_fisc = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_regiao_fiscal')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0203_le_obf_fisc_item()
#---------------------------------#

   SELECT grupo_fiscal_item
     INTO p_grp_fiscal_item
     FROM obf_grp_fisc_item
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND item          = p_cod_item
   
   IF STATUS = 100 THEN
      LET p_grp_fiscal_item = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_item')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0203_le_obf_fisc_cli()
#---------------------------------#

   SELECT grp_fiscal_cliente
     INTO p_grp_fisc_cliente
     FROM obf_grp_fisc_cli
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND cliente       = p_relat.cod_cliente
   
   IF STATUS = 100 THEN
      LET p_grp_fisc_cliente = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_cli')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

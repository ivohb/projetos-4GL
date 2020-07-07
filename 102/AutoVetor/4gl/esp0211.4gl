#-------------------------------------------------------------------#
# PROGRAMA: esp0211                                                 #
# MODULOS.: esp0211 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO DE PEDIDO INTERNO                             #
#Conversao: Thiago																									#
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_num_pag       INTEGER,
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
          p_i             SMALLINT,
          p_ies_cons      SMALLINT,
          g_ies_ambiente  CHAR(01),
          p_caminho       CHAR(080),
          p_cod_cidade    CHAR(005),
          p_tip_entrega   DEC(1,0),
          p_ies_incid_ipi DEC(1,0),
          p_cod_nat_oper  LIKE nat_operacao.cod_nat_oper,
          p_ies_frete     LIKE pedidos.ies_frete


   DEFINE p_tela RECORD
      cod_empresa         LIKE empresa.cod_empresa,
      num_pedido1         LIKE pedido_dig_mest.num_pedido,
      num_pedido2         LIKE pedido_dig_mest.num_pedido
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
      des_frete           CHAR(03)
   END RECORD 

END GLOBALS

MAIN
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT 
   LET p_versao="ESP0211-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("esp0211.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL esp0211_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0211_controle()
#--------------------------#

   CALL esp0211_cria_t_pedido()
   LET p_comprime = ascii 15
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp0211") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   LET  p_num_pag = 0
   OPEN WINDOW w_esp0211 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros para impressao"
      HELP 000 
      LET p_ies_cons = FALSE
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","esp0211","IN")  THEN
         IF esp0211_entrada_dados() THEN
            LET p_ies_cons = TRUE
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
      IF log005_seguranca(p_user,"VDP","esp0211","MO") THEN
         IF p_ies_cons = TRUE THEN 
            IF log028_saida_relat(17,42) IS NOT NULL THEN
               MESSAGE " Processando a extracao do relatorio ... " 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT esp0211_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'esp0211.tmp'
                     START REPORT esp0211_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT esp0211_relat TO p_nom_arquivo
               END IF
               CALL esp0211_emite_relatorio_dig()
               CALL esp0211_emite_relatorio_ped()
               CALL esp0211_emite_relat()
               IF p_count = 0 THEN
                  ERROR "Nao existem dados para serem listados" 
                     ATTRIBUTE(REVERSE)
               ELSE
                  ERROR "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
               END IF
               FINISH REPORT esp0211_relat   
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

   CLOSE WINDOW w_esp0211

END FUNCTION

#-------------------------------#
 FUNCTION esp0211_cria_t_pedido()
#-------------------------------#

   WHENEVER ERROR CONTINUE
   DROP TABLE t_pedido

   CREATE TEMP TABLE t_pedido 
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
    den_item 	        CHAR(76),  
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
    des_frete           CHAR(03)
   );
   WHENEVER ERROR STOP 

END FUNCTION

#-------------------------------#
 FUNCTION esp0211_entrada_dados()
#-------------------------------#

   INITIALIZE p_tela.* TO NULL 
   LET p_tela.cod_empresa = p_cod_empresa
   DISPLAY BY NAME p_tela.cod_empresa

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_pedido1 
         IF p_tela.num_pedido1 IS NULL THEN
            ERROR "Campo de preenchimento obrigatorio"
            NEXT FIELD num_pedido1  
         ELSE
            SELECT num_pedido
            FROM pedido_dig_mest
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_tela.num_pedido1
            IF SQLCA.SQLCODE <> 0 THEN
               SELECT num_pedido
                 FROM pedidos            
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_tela.num_pedido1
               IF SQLCA.SQLCODE <> 0 THEN
                  ERROR "Pedido nao Cadastrado"
                  NEXT FIELD num_pedido1
               END IF
            END IF
         END IF

      AFTER FIELD num_pedido2 
         IF p_tela.num_pedido2 IS NULL THEN
            ERROR "Campo de preenchimento obrigatorio"
            NEXT FIELD num_pedido2   
         ELSE
            SELECT num_pedido
            FROM pedido_dig_mest
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_tela.num_pedido2
            IF SQLCA.SQLCODE <> 0 THEN
               SELECT num_pedido
                 FROM pedidos            
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_tela.num_pedido2
               IF SQLCA.SQLCODE <> 0 THEN
                  ERROR "Pedido nao Cadastrado"
                  NEXT FIELD num_pedido2
               END IF
            END IF
            IF p_tela.num_pedido1 > p_tela.num_pedido2 THEN
               ERROR "Pedido De nao pode ser maior que Pedido ate"
               NEXT FIELD num_pedido1
            END IF 
         END IF
    
   END INPUT

   IF int_flag = 0 THEN
      LET p_ind = p_tela.num_pedido2 - p_tela.num_pedido1
      LET p_ind = p_ind + 1
      FOR p_i = 1 TO p_ind
         INSERT INTO t_pedido
            VALUES (p_tela.num_pedido1)
         LET p_tela.num_pedido1 = p_tela.num_pedido1 + 1
      END FOR
      RETURN TRUE 
   ELSE
      RETURN FALSE 
   END IF

END FUNCTION 

#-------------------------------------#
 FUNCTION esp0211_emite_relatorio_dig()
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
          ies_frete
   FROM pedido_dig_mest, 
        t_pedido
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = num_ped
 
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
                          p_ies_frete      

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
                pes_unit,
                pct_ipi    
           INTO p_relat.den_item,        
                p_relat.cod_unid_med, 
                p_relat.pes_unit,         
                p_relat.pct_ipi
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_relat.cod_item 

            LET p_relat.perc_desc   = esp0211_calcula_desc()             
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
            SELECT ies_incid_ipi
               INTO p_ies_incid_ipi 
            FROM fiscal_par
            WHERE cod_empresa   = p_cod_empresa
             AND  cod_nat_oper  = p_relat.cod_nat_oper
             AND  cod_uni_feder = p_relat.cod_uni_feder 
            IF SQLCA.SQLCODE = 0 THEN               
               IF p_ies_incid_ipi <> 1 THEN
                  LET p_relat.pct_ipi = 0
               END IF
            ELSE
               SELECT ies_incid_ipi
                  INTO p_ies_incid_ipi 
               FROM fiscal_par
               WHERE cod_empresa   = p_cod_empresa
                AND  cod_nat_oper  = p_relat.cod_nat_oper
                AND  cod_uni_feder IS NULL
               IF SQLCA.SQLCODE = 0 THEN               
                  IF p_ies_incid_ipi <> 1 THEN
                     LET p_relat.pct_ipi = 0
                  END IF
               ELSE
                  LET p_relat.pct_ipi = 0
               END IF   
            END IF
         ELSE
            SELECT ies_incid_ipi
               INTO p_ies_incid_ipi 
            FROM fiscal_par
            WHERE cod_empresa   = p_cod_empresa
             AND  cod_nat_oper  = p_cod_nat_oper
             AND  cod_uni_feder = p_relat.cod_uni_feder 
            IF SQLCA.SQLCODE = 0 THEN               
               IF p_ies_incid_ipi <> 1 THEN
                  LET p_relat.pct_ipi = 0
               END IF
            ELSE
               SELECT ies_incid_ipi
                  INTO p_ies_incid_ipi 
               FROM fiscal_par
               WHERE cod_empresa   = p_cod_empresa
                AND  cod_nat_oper  = p_cod_nat_oper
                AND  cod_uni_feder = p_relat.cod_uni_feder 
               IF SQLCA.SQLCODE = 0 THEN               
                  IF p_ies_incid_ipi <> 1 THEN
                     LET p_relat.pct_ipi = 0
                  END IF
               ELSE
                  LET p_relat.pct_ipi = 0        
               END IF   
            END IF
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
 FUNCTION esp0211_emite_relatorio_ped()
#-------------------------------------#

   LET p_count = 0   

   LET p_relat.p_desc_rel = "PEDIDO EM CARTEIRA"

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
          ies_frete       
   FROM pedidos, 
        t_pedido
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = num_ped
 
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
                            p_ies_frete       

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
                    qtd_pecas_solic,
                    pre_unit,
                    pct_desc_adic,
                    prz_entrega 
      FROM ped_itens
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_relat.num_pedido 

      FOREACH cq_itemp INTO p_relat.num_sequencia,
                            p_relat.cod_item,
                            p_relat.qtd_pecas_solic, 
                            p_relat.pre_unit,          
                            p_relat.pct_desc_adici,
                            p_relat.prz_entrega 

         SELECT den_item,
                cod_unid_med,
                pes_unit,
                pct_ipi    
            INTO p_relat.den_item,        
                 p_relat.cod_unid_med, 
                 p_relat.pes_unit,         
                 p_relat.pct_ipi
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_relat.cod_item 

            LET p_relat.perc_desc   = esp0211_calcula_desc_c()             
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
            SELECT ies_incid_ipi
               INTO p_ies_incid_ipi 
            FROM fiscal_par
            WHERE cod_empresa   = p_cod_empresa
             AND  cod_nat_oper  = p_relat.cod_nat_oper
             AND  cod_uni_feder = p_relat.cod_uni_feder 
            IF SQLCA.SQLCODE = 0 THEN               
               IF p_ies_incid_ipi <> 1 THEN
                  LET p_relat.pct_ipi = 0
               END IF
            ELSE
               SELECT ies_incid_ipi
                   INTO p_ies_incid_ipi 
                FROM fiscal_par
                WHERE cod_empresa   = p_cod_empresa
                 AND  cod_nat_oper  = p_relat.cod_nat_oper
                 AND  cod_uni_feder IS NULL  
                IF SQLCA.SQLCODE = 0 THEN               
                   IF p_ies_incid_ipi <> 1 THEN
                      LET p_relat.pct_ipi = 0
                   END IF            
                ELSE
                   LET p_relat.pct_ipi = 0
                END IF    
            END IF
         ELSE
            SELECT ies_incid_ipi
               INTO p_ies_incid_ipi 
            FROM fiscal_par
            WHERE cod_empresa   = p_cod_empresa
             AND  cod_nat_oper  = p_cod_nat_oper
             AND  cod_uni_feder = p_relat.cod_uni_feder 
            IF SQLCA.SQLCODE = 0 THEN               
               IF p_ies_incid_ipi <> 1 THEN
                  LET p_relat.pct_ipi = 0
               END IF
            ELSE
               SELECT ies_incid_ipi
                   INTO p_ies_incid_ipi 
                FROM fiscal_par
                WHERE cod_empresa   = p_cod_empresa
                 AND  cod_nat_oper  = p_relat.cod_nat_oper
                 AND  cod_uni_feder IS NULL
                IF SQLCA.SQLCODE = 0 THEN               
                   IF p_ies_incid_ipi <> 1 THEN
                      LET p_relat.pct_ipi = 0
                   END IF            
                ELSE
                   LET p_relat.pct_ipi = 0
                END IF    
            END IF
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
      LET p_relat.p_desc_rel = "PEDIDO EM CARTEIRA"
      LET p_count = p_count + 1

   END FOREACH   
   DELETE FROM t_pedido          

END FUNCTION

#------------------------------#
 FUNCTION esp0211_calcula_desc()
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
 FUNCTION esp0211_calcula_desc_c()
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
 FUNCTION esp0211_emite_relat()                              
#-----------------------------# 

   DECLARE cq_relat CURSOR FOR
   SELECT * FROM t_relat
   ORDER BY num_pedido,
            num_sequencia
   
   FOREACH cq_relat INTO p_relat.* 

      OUTPUT TO REPORT esp0211_relat(p_relat.*)                              
 
      INITIALIZE p_relat.* TO NULL

   END FOREACH   
   DELETE FROM t_relat           

END FUNCTION

#----------------------------#
 REPORT esp0211_relat(p_relat)                              
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
      des_frete           CHAR(03)
   END RECORD ,
   p_val_total            DEC(15,2)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 6
          PAGE   LENGTH 66

   FORMAT

      PAGE HEADER  

         LET p_num_pag = p_num_pag+1
         PRINT log500_determina_cpp(132) CLIPPED;
         PRINT log500_condensado(true)
         PRINT COLUMN 001, p_comprime, p_den_empresa,"  ",p_relat.p_desc_rel, 
               COLUMN 103, "PEDIDO NUMERO *** ", p_relat.num_pedido, " ***"
         PRINT COLUMN 054, "P E D I D O    I N T E R N O",
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
               COLUMN 045, "COND. PGTO....: ", p_relat.cod_cnd_pgto, " ",p_relat.den_cnd_pgto
         PRINT COLUMN 001, "% DESC. CAPA..: ", p_relat.pct_desc_adic,  
               COLUMN 045, "PEDIDO REPRES.: ", p_relat.num_pedido_repres
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
               COLUMN 023, "DESCRICAO DO PRODUTO",
               COLUMN 090, "SOLICITADA",
               COLUMN 101, "ENVIADA",     
               COLUMN 110, " ENTREGA"

      BEFORE GROUP OF p_relat.num_pedido  
         SKIP TO TOP OF PAGE

      ON EVERY ROW
      
         PRINT COLUMN 001, p_relat.num_sequencia USING "####&",
               COLUMN 007, p_relat.cod_item, 
               COLUMN 023, p_relat.den_item[1,65],  
               COLUMN 090, p_relat.qtd_pecas_solic USING "#######&.&&&",
##               COLUMN 101, p_relat.perc_desc   USING "##&.&&",
               COLUMN 120, p_relat.prz_entrega USING "dd/mm/yyyy"
         PRINT       

      AFTER GROUP OF p_relat.num_pedido  

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
#------------------------------ FIM DE PROGRAMA -------------------------------#

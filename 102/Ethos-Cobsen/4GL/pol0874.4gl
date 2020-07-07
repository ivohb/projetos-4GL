#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0874                                               #
# MODULOS.: pol0874 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG1200 - LOG1300 - LOG1400                 #
# OBJETIVO: VARIACAO DA PROGRAMACAO DO CLIENTE                    #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_cod_cliente          LIKE pedidos.cod_cliente,
         p_cod_cnd_pgto         LIKE pedidos.cod_cnd_pgto,
         p_cnd_pgto_list        LIKE ped_cond_pgto_list.cod_cnd_pgto,
         p_ies_preco            LIKE pedidos.ies_preco,
         p_num_list_preco       LIKE pedidos.num_list_preco,
         p_num_versao_lista     LIKE pedidos.num_versao_lista,
         p_num_nff_ult          LIKE pedidos_qfp.num_nff_ult,
         p_qtd_estoque          LIKE estoque.qtd_liberada,
         p_dat_emissao          LIKE fat_nf_mestre.dat_hor_emissao,
         p_dat_emis_ult         LIKE fat_nf_mestre.dat_hor_emissao,
         p_qtd_embarcado        LIKE fat_nf_item.qtd_item,
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_qtd_pecas_cancel     LIKE ped_itens.qtd_pecas_cancel,
         p_cod_item_cliente     LIKE cliente_item.cod_item_cliente,
         p_num_pedido_ant       LIKE ped_itens_qfp.num_pedido,
         p_identif              LIKE pedidos_edi_pe1.identif_prog_atual,
         p_dat_limite           DATE,
         p_release              CHAR(40),
         p_saldo                DECIMAL(10,3),
         p_des_alter            CHAR(40),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT,
         p_possui_it            CHAR(01),
         p_msg                  CHAR(500),
         p_hoje                 DATE 

  DEFINE t_ped_itens_qfp  ARRAY[500] OF RECORD
                          prz_entrega      LIKE ped_itens_qfp.prz_entrega,
                          qtd_solic        LIKE ped_itens_qfp.qtd_solic,
                          qtd_solic_nova   LIKE ped_itens_qfp.qtd_solic_nova,
                          qtd_solic_aceita LIKE ped_itens_qfp.qtd_solic_aceita,
                          qtd_variacao     DECIMAL(07,0),
                          sit_programa     CHAR(09)     
                         END RECORD,
         p_ind            SMALLINT

  DEFINE p_ped_itens_qfp     RECORD LIKE ped_itens_qfp.*
  DEFINE p_ped_itens_qfp_pe5 RECORD LIKE ped_itens_qfp_pe5.*
  DEFINE p_pedidos_edi_te1   RECORD LIKE pedidos_edi_te1.*
  DEFINE p_ped_itens_qfpr    RECORD LIKE ped_itens_qfp.*
  DEFINE p_ped_itens_texto   RECORD LIKE ped_itens_texto.*
  DEFINE p_ped_itens_can     RECORD LIKE ped_itens.*
  DEFINE p_ped_itens         RECORD LIKE ped_itens.*
  DEFINE p_ped_itens_ex      RECORD LIKE ped_itens.*
  DEFINE p_audit_vdp         RECORD LIKE audit_vdp.*
  
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_cancel               INTEGER
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

{  >>  OS 115462 - INICIO  <<  }
   DEFINE
      mr_par_vdp      RECORD  LIKE  par_vdp.*,
      m_cod_tip_carteira_ant  LIKE  pedidos.cod_tip_carteira,
      m_cod_tip_carteira      LIKE  pedidos.cod_tip_carteira,
      m_qtd_decimais_cart     DECIMAL(1,0),
      m_qtd_decimais_par      DECIMAL(1,0)
{  >>  OS 115462 - FINAL  <<  }

   DEFINE m_nom_cliente       LIKE clientes.nom_cliente
MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "pol0874-10.02.00" #Favor nao alterar esta linha (SUPORTE)
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
    CALL pol0874_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION pol0874_controle()
#---------------------------------------------------------------------#
  INITIALIZE p_ped_itens_qfp.*, p_ped_itens_qfpr.*, p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0874") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0874 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

{  >>  OS 115462 - INICIO  <<  }
   SELECT * INTO mr_par_vdp.* FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      ERROR " Parametros do Sistema nao cadastrados (VDP1400) "
   END IF

   CALL pol0874_cria_temp()

   LET m_qtd_decimais_par = mr_par_vdp.par_vdp_txt[43,43]
{  >>  OS 115462 - FINAL  <<  }

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Programacao do cliente"
      HELP 0004
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0874","CO") THEN 
         SELECT par_data
           INTO p_dat_limite
           FROM par_vdp_pad
          WHERE cod_parametro = 'dat_lim_pgm_kanban'
            AND cod_empresa = p_cod_empresa
         IF SQLCA.sqlcode <> 0 THEN      
            MESSAGE "PARAMETRO dat_lim_pgm_kanban NAO CADASTRADO NA par_vdp_pad"
         ELSE
            CALL pol0874_consulta_ped_itens_qfp()
            MESSAGE "                 "
         END IF    
      END IF
    COMMAND KEY ("O") "cOnfirmar"    "Confirma Programacao do cliente "
      HELP 2043
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0874","MO") THEN
        IF t_ped_itens_qfp[1].prz_entrega IS NULL THEN 
           MESSAGE "Nao existem dados para confirmacao"  ATTRIBUTE(REVERSE)
        ELSE
          IF log004_confirm(22,45) THEN
             ERROR " Em Processamento... "
             CALL pol0874_prepara_ped_itens()
             IF sqlca.sqlcode = 0 THEN
                MESSAGE "Confirmacao Executada com Sucesso"  ATTRIBUTE(REVERSE)
                CALL pol0874_deleta_ped_itens_qfp()
                IF sqlca.sqlcode = 0 THEN
                   CALL pol0874_deleta_pedidos_qfp()
                   IF SQLCA.sqlcode = 0  THEN
                      NEXT OPTION "Consultar"
                   END IF
                END IF
            END IF
          END IF
        END IF  
      END IF
    COMMAND "Seguinte"   "Exibe Programacao seguinte"
      HELP 0005
      MESSAGE ""
      CALL pol0874_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe Programacao anterior "
      HELP 0006
      MESSAGE ""
      CALL pol0874_paginacao("ANTERIOR")
    COMMAND "Excluir"  "Exclui Programacao do cliente"
      HELP 0003
      MESSAGE ""
      IF   p_ped_itens_qfp.num_pedido IS NOT NULL
      THEN IF   log005_seguranca(p_user,"VDP","pol0874","EX")
           THEN CALL pol0874_exclusao_ped_itens_qfp()
           END IF
      ELSE 
      #  CALL log0030_mensagem("Consulte previamente para fazer a exclusao. ",
      #                        "exclamation")  
         MESSAGE "Consulte Previamente para fazer a Exclusao !!!" 
            ATTRIBUTE (REVERSE)
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0874_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0874
END FUNCTION

#---------------------------#
 FUNCTION pol0874_cria_temp()
#---------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE t_ped_it;
   CREATE TABLE t_ped_it
   (
    cod_empresa        CHAR(02),
    num_pedido         DECIMAL(6,0),
    cod_item           CHAR(15)
   );

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF
   WHENEVER ERROR STOP
END FUNCTION

#------------------------------------------#
 FUNCTION pol0874_consulta_ped_itens_qfp()
#------------------------------------------#
  DEFINE where_clause, sql_stmt CHAR(650),
         l_count     INTEGER

  CLEAR FORM
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol0874
  DISPLAY p_cod_empresa TO cod_empresa

  LET p_num_pedido_ant   = 0
#####aquiooooo  LET p_tela.dat_prog = "31/12/2999"

  LET p_ped_itens_qfpr.* = p_ped_itens_qfp.*
  INITIALIZE p_ped_itens_qfp.*,
             t_ped_itens_qfp  TO NULL

  CALL pol0874_separa_kanban()

  CONSTRUCT BY NAME where_clause ON ped_itens_qfp.num_pedido,
                                    ped_itens_qfp.cod_item,
                                    pedidos.cod_cliente

  IF   int_flag
  THEN LET int_flag = 0
       LET p_ped_itens_qfp.* = p_ped_itens_qfpr.*
       CALL log006_exibe_teclas("01", p_versao)
       CURRENT WINDOW IS w_pol0874
       CALL pol0874_exibe_dados()
       ERROR " Consulta Cancelada "
       RETURN
  END IF

  LET sql_stmt = "SELECT UNIQUE ped_itens_qfp.num_pedido, ",
                 "ped_itens_qfp.cod_item, pedidos_qfp.num_nff_ult, ",
                 "pedidos.cod_cliente,pedidos_qfp.cod_item_cliente ",
                 "FROM ped_itens_qfp, pedidos, OUTER pedidos_qfp ",
                 "WHERE ped_itens_qfp.cod_empresa = '",p_cod_empresa,"' ",
                 "AND ", where_clause CLIPPED, " ",
                 "AND pedidos_qfp.cod_empresa = ped_itens_qfp.cod_empresa ",
                 "AND pedidos_qfp.num_pedido  = ped_itens_qfp.num_pedido ",
                 "AND pedidos.cod_empresa     = ped_itens_qfp.cod_empresa ",
                 "AND pedidos.num_pedido      = ped_itens_qfp.num_pedido  ",
                 "AND EXISTS (SELECT * FROM t_ped_it WHERE ped_itens_qfp.cod_empresa = t_ped_it.cod_empresa ",
                 "AND ped_itens_qfp.num_pedido = t_ped_it.num_pedido)"

  PREPARE var_query FROM sql_stmt

  DECLARE cq_ped_itens_qfp SCROLL CURSOR WITH HOLD FOR var_query
  OPEN  cq_ped_itens_qfp
  FETCH cq_ped_itens_qfp INTO p_ped_itens_qfp.num_pedido,
                              p_ped_itens_qfp.cod_item,
                              p_num_nff_ult,
                              p_cod_cliente,
                              p_cod_item_cliente
  
     IF   sqlca.sqlcode = NOTFOUND THEN
           MESSAGE "Argumentos de Pesquisa nao Encontrados !!!" ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
     ELSE MESSAGE " Consultando ... "
          LET p_ies_cons = TRUE
          IF   p_num_nff_ult IS NULL #pol0874_verifica_pedidos_qfp() = FALSE
          THEN LET p_num_nff_ult = 0
          END IF
          IF p_ped_itens_qfp.num_pedido <> p_num_pedido_ant THEN
             LET p_num_pedido_ant = p_ped_itens_qfp.num_pedido 
             IF pol0874_verifica_pedido() THEN
                CALL pol0874_verifica_nff()
                LET p_qtd_embarcado = 0
                LET p_saldo         = 0
             END IF
             IF pol0874_verifica_estoque() THEN
             ELSE
                LET p_qtd_estoque = 0
             END IF
          END IF
     
          SELECT cod_item_cliente 
            INTO p_cod_item_cliente 
            FROM cliente_item
           WHERE cod_empresa = p_cod_empresa
             AND cod_cliente_matriz = p_cod_cliente 
             AND cod_item = p_ped_itens_qfp.cod_item
           
           LET p_hoje = TODAY 
           
           SELECT COUNT(*) 
             INTO l_count
             FROM ped_itens a,
                  item_kanban_547 b
            WHERE a.cod_empresa = b.cod_empresa
              AND a.cod_item    = b.cod_item
              AND a.num_pedido  = p_ped_itens_qfp.num_pedido
              AND b.dat_inicio  <= p_hoje
              AND b.dat_termino >= p_hoje 
              AND a.cod_empresa = p_cod_empresa
              
          IF l_count > 0 THEN 
          ELSE
             CALL pol0874_monta_dados_consulta()
             CALL log006_exibe_teclas("01 02", p_versao)
             CURRENT WINDOW IS w_pol0874
             IF p_possui_it = 'S' THEN 
                CALL pol0874_exibe_dados()
                LET int_flag = 0
             END IF    
          END IF    
     END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0874_separa_kanban()
#-------------------------------#
 DEFINE l_count  INTEGER
 
  SELECT COUNT(*)
    INTO l_count
    FROM t_ped_it
    
  IF l_count > 0 THEN 
  ELSE   
     DECLARE cq_pdiq CURSOR FOR
     SELECT UNIQUE cod_empresa, num_pedido, cod_item  
       FROM ped_itens_qfp
     FOREACH cq_pdiq  INTO p_ped_itens_qfp.cod_empresa, p_ped_itens_qfp.num_pedido, p_ped_itens_qfp.cod_item 
        LET l_count = 0
        
        LET p_hoje = TODAY  
        
        SELECT COUNT(*)
          INTO l_count 
          FROM item_kanban_547 
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_ped_itens_qfp.cod_item   
           AND dat_inicio  <= p_hoje
           AND dat_termino >= p_hoje
        IF l_count = 0 THEN 
        ELSE
          INSERT INTO t_ped_it VALUES (p_ped_itens_qfp.cod_empresa, 
                                       p_ped_itens_qfp.num_pedido, 
                                       p_ped_itens_qfp.cod_item )
        END IF    
     END FOREACH 
           
  END IF 
        
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_verifica_pedidos_qfp()
#---------------------------------------------------------------------#
  SELECT num_nff_ult
    INTO p_num_nff_ult
    FROM pedidos_qfp
   WHERE pedidos_qfp.cod_empresa = p_cod_empresa
     AND pedidos_qfp.num_pedido  = p_ped_itens_qfp.num_pedido

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_verifica_pedido()
#---------------------------------------------------------------------#
  INITIALIZE p_cod_cliente, p_ies_preco TO NULL
  LET p_cnd_pgto_list    = 0
  LET p_cod_cnd_pgto     = 0
  LET p_num_list_preco   = 0
  LET p_num_versao_lista = 0

  SELECT cod_cnd_pgto
    INTO p_cnd_pgto_list
    FROM ped_cond_pgto_list
   WHERE ped_cond_pgto_list.cod_empresa = p_cod_empresa
     AND ped_cond_pgto_list.num_pedido  = p_ped_itens_qfp.num_pedido

  IF   sqlca.sqlcode <> 0
  THEN LET p_cnd_pgto_list = 0
  END IF

  SELECT   cod_cliente,   cod_cnd_pgto,   ies_preco,   num_list_preco,
           num_versao_lista,   cod_tip_carteira
    INTO p_cod_cliente, p_cod_cnd_pgto, p_ies_preco, p_num_list_preco,
         p_num_versao_lista, m_cod_tip_carteira
    FROM pedidos
   WHERE pedidos.cod_empresa = p_cod_empresa
     AND pedidos.num_pedido  = p_ped_itens_qfp.num_pedido

  IF   sqlca.sqlcode = 0
  THEN IF   p_cnd_pgto_list = 0
       THEN
       ELSE LET p_cod_cnd_pgto = p_cnd_pgto_list
       END IF
       RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_verifica_nff()
#---------------------------------------------------------------------#
  LET p_dat_emis_ult = 0

  SELECT dat_hor_emissao
    INTO p_dat_emis_ult
    FROM fat_nf_mestre
   WHERE fat_nf_mestre.empresa = p_cod_empresa
     AND fat_nf_mestre.nota_fiscal     = p_num_nff_ult
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_verifica_qtd_nff()
#---------------------------------------------------------------------#
  DEFINE p_qtd_item           LIKE fat_nf_item.qtd_item,
         p_num_nff            LIKE fat_nf_mestre.nota_fiscal,
         p_cod_tip_carteira   LIKE item_vdp.cod_tip_carteira

  LET p_qtd_embarcado = 0
  LET p_saldo         = 0

  SELECT cod_tip_carteira
    INTO p_cod_tip_carteira
    FROM item_vdp
   WHERE item_vdp.cod_empresa = p_cod_empresa
     AND item_vdp.cod_item    = p_ped_itens_qfp.cod_item

# selecao para tabela de natureza de operacao, solicitado pelo Geraldo - 20/09/95
#
  DECLARE c_fat_nf_item CURSOR WITH HOLD FOR 
  SELECT fat_nf_mestre.nota_fiscal, fat_nf_mestre.dat_hor_emissao, fat_nf_item.qtd_item
    INTO p_num_nff, p_dat_emissao, p_qtd_item
    FROM fat_nf_mestre, fat_nf_item, nat_operacao
   WHERE fat_nf_mestre.empresa         = p_cod_empresa
     AND fat_nf_mestre.cliente         = p_cod_cliente
     AND fat_nf_mestre.sit_nota_fiscal        = "N"
     AND fat_nf_mestre.tip_carteira    = p_cod_tip_carteira
      AND fat_nf_mestre.natureza_operacao        = nat_operacao.cod_nat_oper
     AND (nat_operacao.ies_estatistica = "T"
      OR  nat_operacao.ies_estatistica = "Q")
     AND fat_nf_mestre.empresa         = fat_nf_item.empresa
     AND fat_nf_mestre.trans_nota_fiscal             = fat_nf_item.trans_nota_fiscal
     AND fat_nf_item.pedido            = p_ped_itens_qfp.num_pedido
     AND fat_nf_item.item              = p_ped_itens_qfp.cod_item

  OPEN  c_fat_nf_item
  FETCH c_fat_nf_item
  IF   sqlca.sqlcode = 0
  THEN FOREACH c_fat_nf_item
          IF   p_num_nff     >  p_num_nff_ult
           AND p_dat_emissao >= p_dat_emis_ult
          THEN LET  p_qtd_embarcado = p_qtd_embarcado + p_qtd_item
          END IF
       END FOREACH
       LET p_saldo = p_qtd_embarcado * (- 1)
       RETURN TRUE
  ELSE LET p_qtd_embarcado = 0
       RETURN FALSE
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_verifica_estoque()
#---------------------------------------------------------------------#
  LET p_qtd_estoque = 0

  SELECT qtd_liberada
    INTO p_qtd_estoque
    FROM estoque
   WHERE estoque.cod_empresa = p_cod_empresa
     AND estoque.cod_item    = p_ped_itens_qfp.cod_item

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_monta_dados_consulta()
#---------------------------------------------------------------------#
  CALL log085_transacao("BEGIN")

  LET p_possui_it = 'N'  

  DECLARE e_ped_itens_qfp CURSOR WITH HOLD FOR
    SELECT * 
      FROM ped_itens_qfp
     WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
       AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
       AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
     ORDER BY prz_entrega
  CALL set_count(0)
  LET p_ind = 1
  FOREACH e_ped_itens_qfp INTO p_ped_itens_qfp.*  

    SELECT * 
      INTO p_ped_itens_qfp_pe5.*
      FROM ped_itens_qfp_pe5
     WHERE cod_empresa = p_ped_itens_qfp.cod_empresa
       AND num_pedido = p_ped_itens_qfp.num_pedido 
       AND num_sequencia = p_ped_itens_qfp.num_sequencia
       AND cod_item      = p_ped_itens_qfp.cod_item       

    IF sqlca.sqlcode <> 0 THEN 
       CONTINUE FOREACH
    END IF

    IF p_ped_itens_qfp.prz_entrega > p_dat_limite THEN 
       CONTINUE FOREACH
    END IF    

#   IF p_tela.ies_data = "A" THEN
#      IF p_ped_itens_qfp_pe5.dat_abertura > p_tela.dat_prog THEN
#         CONTINUE FOREACH
#      END IF
#   ELSE 
#      IF p_ped_itens_qfp.prz_entrega > p_tela.dat_prog THEN
#         CONTINUE FOREACH
#      END IF
#   END IF

#   IF p_ped_itens_qfp_pe5.ies_programacao = "8" THEN
#      CONTINUE FOREACH      
#   END IF

#   LET p_ok ="N"     
##   IF p_tela.ies_firme  = "S"  AND 
##      p_tela.ies_requis = "S"  AND 
##      p_tela.ies_planej = "S"  THEN 
##      LET p_ok ="S"     
##   ELSE 
##      IF p_ped_itens_qfp_pe5.ies_programacao = "1" AND 
##         p_tela.ies_firme = "S" THEN
##         LET p_ok ="S"     
##      ELSE 
##         IF p_ped_itens_qfp_pe5.ies_programacao = "3" AND 
##            p_tela.ies_requis= "S" THEN
##            LET p_ok ="S"     
##         ELSE 
##            IF p_ped_itens_qfp_pe5.ies_programacao = "4" AND 
##               p_tela.ies_planej= "S" THEN
##               LET p_ok ="S"     
##            END IF
##         END IF
##      END IF
##   END IF

##   IF p_ok = "N" THEN
##      CONTINUE FOREACH
##   END IF 

   IF p_ped_itens_qfp_pe5.ies_programacao = "1" THEN
      LET t_ped_itens_qfp[p_ind].sit_programa = "FIRME    " 
   ELSE 
      IF p_ped_itens_qfp_pe5.ies_programacao = "3" THEN
         LET t_ped_itens_qfp[p_ind].sit_programa = "REQUISIC."
      ELSE 
         IF p_ped_itens_qfp_pe5.ies_programacao = "4" THEN
            LET t_ped_itens_qfp[p_ind].sit_programa = "PLANEJADO"
         ELSE 
            LET t_ped_itens_qfp[p_ind].sit_programa = "DOL      "
         END IF
      END IF
   END IF

   LET p_possui_it = 'S' 

#   IF p_tela.ies_data = "A" THEN
#      LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp_pe5.dat_abertura
#   ELSE
      LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp.prz_entrega
#   END IF

   LET t_ped_itens_qfp[p_ind].qtd_solic       = p_ped_itens_qfp.qtd_solic
   LET t_ped_itens_qfp[p_ind].qtd_solic_nova  = p_ped_itens_qfp.qtd_solic_nova

    LET t_ped_itens_qfp[p_ind].qtd_solic_aceita=p_ped_itens_qfp.qtd_solic_aceita
    IF p_ped_itens_qfp.qtd_solic_aceita = 0 THEN
       LET p_ped_itens_qfp.qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_nova
       LET t_ped_itens_qfp[p_ind].qtd_solic_aceita=p_ped_itens_qfp.qtd_solic_aceita
       LET p_qtd_variacao      = p_ped_itens_qfp.qtd_solic_nova  
    ELSE 
       LET p_qtd_variacao      = p_ped_itens_qfp.qtd_solic_aceita
    END IF
    LET t_ped_itens_qfp[p_ind].qtd_variacao   = p_qtd_variacao
    LET p_ind = p_ind + 1
  END FOREACH

  IF sqlca.sqlcode = 0 THEN 
     CALL log085_transacao("COMMIT")
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ATUALIZA-2","PED_ITENS_QFP")
        CALL log085_transacao("ROLLBACK")
     END IF
  ELSE 
     CALL log003_err_sql("ATUALIZA-3","PED_ITENS_QFP")
     CALL log085_transacao("ROLLBACK")
  END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0874_saldo()
#--------------------------#
    LET p_saldo = p_saldo
                + p_ped_itens_qfp.qtd_solic_nova

    IF   p_saldo > 0
    THEN LET p_ped_itens_qfp.qtd_solic_aceita = p_saldo
         LET p_saldo                          = 0
    ELSE LET p_ped_itens_qfp.qtd_solic_aceita = 0
    END IF

  UPDATE ped_itens_qfp
     SET qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita
   WHERE ped_itens_qfp.cod_empresa   = p_cod_empresa
     AND ped_itens_qfp.num_pedido    = p_ped_itens_qfp.num_pedido
     AND ped_itens_qfp.cod_item      = p_ped_itens_qfp.cod_item
     AND ped_itens_qfp.prz_entrega   = p_ped_itens_qfp.prz_entrega

  IF   sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("ATUALIZA-1","PED_ITENS_QFP")
  END IF
END FUNCTION

#-------------------------------------#
 FUNCTION pol0874_prepara_ped_itens()
#-------------------------------------#
   CALL log085_transacao("BEGIN")

   DECLARE pr_ped_itens_qfp CURSOR WITH HOLD FOR
   SELECT ped_itens_qfp.*
      FROM ped_itens_qfp
   WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
     AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
   ORDER BY num_sequencia

   FOREACH pr_ped_itens_qfp INTO p_ped_itens_qfp.*

      SELECT * 
        INTO p_ped_itens_qfp_pe5.*
        FROM ped_itens_qfp_pe5
       WHERE cod_empresa = p_ped_itens_qfp.cod_empresa
         AND num_pedido = p_ped_itens_qfp.num_pedido 
         AND num_sequencia = p_ped_itens_qfp.num_sequencia
         AND cod_item = p_ped_itens_qfp.cod_item       

      IF p_ped_itens_qfp_pe5.ies_programacao = "8" THEN
         CONTINUE FOREACH      
      END IF

      IF p_ped_itens_qfp.prz_entrega > p_dat_limite THEN 
         CONTINUE FOREACH
      END IF    

      IF pol0874_verifica_pedido() THEN
         CALL pol0874_le_list_preco_item()  
         LET p_ped_itens.pre_unit = p_pre_unit
         IF p_ped_itens_qfp.prz_entrega >= TODAY THEN
            CALL pol0874_le_ped_itens()
            IF p_prog_inex  = "N" THEN
               IF p_ped_itens.qtd_pecas_reserv   > 0 OR
                  p_ped_itens.qtd_pecas_romaneio > 0 THEN
                  CONTINUE FOREACH
               ELSE 
                  IF p_ped_itens_qfp.qtd_solic_aceita = 0  THEN
##### cancelamento
                     CALL pol0874_atualiza_ped_itens_1()
                  ELSE
                     CALL pol0874_atualiza_ped_itens_2()
                  END IF
               END IF
            ELSE 
               CALL pol0874_grava_ped_itens()
            END IF
         END IF
      END IF
   END FOREACH

   IF SQLCA.SQLCODE = 0 THEN 
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("GRAVACAO_1","PED_ITENS")
         CALL log085_transacao("ROLLBACK")
      END IF
   ELSE 
      CALL log003_err_sql("GRAVACAO_2","PED_ITENS")
      CALL log085_transacao("ROLLBACK")
   END IF

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_le_list_preco_item()
#---------------------------------------------------------------------#
#  >>  OS 115462 - INICIO  <<  #
   SELECT pre_unit 
     INTO p_pre_unit
     FROM desc_preco_item 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item    = p_ped_itens_qfp.cod_item
      AND num_list_preco = 1
   IF sqlca.sqlcode <> 0 THEN
      CALL pol0874_le_preco_item_ped_itens()
      IF p_pre_unit = 0 THEN  
         ERROR "ITEM ",p_ped_itens_qfp.cod_item,"  SEM PRECO NA LISTA 1" 
      END IF
   END IF

END FUNCTION   

#---------------------------------------------------------------------#
 FUNCTION pol0874_le_preco_item_ped_itens()
#---------------------------------------------------------------------#
  DEFINE p_prazo                LIKE ped_itens.prz_entrega

  SELECT MAX(prz_entrega)
    INTO p_prazo
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item

  SELECT pre_unit
    INTO p_pre_unit
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
     AND ped_itens.prz_entrega = p_prazo

  IF   p_pre_unit IS NULL
  THEN LET p_pre_unit = 0
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_le_ped_itens()
#---------------------------------------------------------------------#
  LET p_count_ped = 0

  SELECT count(*)    
    INTO p_count_ped    
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
     AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega

  IF p_count_ped = 0 THEN
     LET p_prog_inex = "S"
  ELSE 
     LET p_prog_inex = "N"
  END IF

  DECLARE cq_ped_ex CURSOR FOR
  SELECT ped_itens.*
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
     AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega
   ORDER BY prz_entrega desc
  FOREACH cq_ped_ex INTO p_ped_itens_ex.* 
      EXIT FOREACH
  END FOREACH
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0874_atualiza_ped_itens_1()
#-----------------------------------------#

  DEFINE p_cod_item_cli  LIKE cliente_item.cod_item_cliente,
         p_alter_tecnica LIKE pedidos_edi_pe6.alter_tecnica

  LET p_qtd_pecas_cancel = 0
  IF p_ped_itens.qtd_pecas_solic IS NULL THEN 
     LET p_ped_itens.qtd_pecas_solic = 0
  END IF
   
  IF p_ped_itens.qtd_pecas_atend IS NULL THEN 
     LET p_ped_itens.qtd_pecas_atend = 0
  END IF 

  LET p_qtd_pecas_cancel = p_ped_itens.qtd_pecas_solic
                         - p_ped_itens.qtd_pecas_atend

  IF p_qtd_pecas_cancel IS NULL THEN 
     LET p_qtd_pecas_cancel = 0
  END IF 

  SELECT MAX(num_sequencia)
    INTO p_ped_itens.num_sequencia
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
     AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega
    
  UPDATE ped_itens
     SET qtd_pecas_cancel     = p_qtd_pecas_cancel
  WHERE ped_itens.cod_empresa = p_cod_empresa
    AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
    AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
    AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega

  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("ATUALIZA_1","PED_ITENS")
  END IF
  LET p_audit_vdp.cod_empresa = p_cod_empresa
  LET p_audit_vdp.num_pedido = p_ped_itens_qfp.num_pedido
  LET p_audit_vdp.tipo_informacao = 'M' 
  LET p_audit_vdp.tipo_movto = 'I'
  LET p_audit_vdp.texto = 'CANCELAMENTO ENTREGA ',p_ped_itens_qfp.prz_entrega,' QUANTIDADE ',p_qtd_pecas_cancel
  LET p_audit_vdp.num_programa = 'pol0874'
  LET p_audit_vdp.data =  TODAY
  LET p_audit_vdp.hora =  TIME 
  LET p_audit_vdp.usuario = p_user
  LET p_audit_vdp.num_transacao = 0  
  INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","audit_vdp")
  END IF
  
# aqui         
  SELECT cod_item_cliente 
     INTO p_cod_item_cli
  FROM cliente_item
  WHERE cod_empresa = p_cod_empresa
    AND cod_item = p_ped_itens_qfp.cod_item

  INITIALIZE p_identif TO NULL

  SELECT identif_prog_atual
    INTO p_identif
    FROM pedidos_edi_pe1 
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_ped_itens_qfp.num_pedido
  IF p_identif IS NOT NULL THEN
     LET p_release = 'RELEASE ',p_identif  
  ELSE
     INITIALIZE p_release TO NULL
  END IF   

  SELECT alter_tecnica
     INTO p_alter_tecnica
  FROM pedidos_edi_pe6 
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido  = p_ped_itens_qfp.num_pedido

  LET p_des_alter = "REVISAO ",p_alter_tecnica

  SELECT *
  FROM item_esp 
  WHERE cod_empresa = p_cod_empresa
    AND cod_item = p_ped_itens_qfp.cod_item
    AND num_seq = 1
  IF SQLCA.SQLCODE = 0 THEN
     UPDATE item_esp
        SET des_esp_item = p_des_alter     
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_ped_itens_qfp.cod_item
       AND num_seq = 1
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("ATUALIZA_1","ITEM_ESP")
     END IF
  ELSE
     INSERT INTO item_esp
        VALUES (p_cod_empresa,
                p_ped_itens_qfp.cod_item,
                1,
                p_des_alter)
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO_1","ITEM_ESP")
     END IF
  END IF

  SELECT *
  FROM ped_itens_texto
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido  = p_ped_itens_qfp.num_pedido
    AND num_sequencia = p_ped_itens.num_sequencia
  IF SQLCA.SQLCODE = 0 THEN
     UPDATE ped_itens_texto SET den_texto_2 = p_des_alter,
                                den_texto_5 = p_release
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_qfp.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
  ELSE
     INSERT INTO ped_itens_texto
        VALUES (p_cod_empresa,
                p_ped_itens_qfp.num_pedido,
                p_ped_itens.num_sequencia,
                NULL,
                p_des_alter,
                NULL,
                NULL,
                p_release)
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
     END IF
  END IF    
##aqui         
                
  CALL pol0874_incl_ped_of_pcp()

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_atualiza_ped_itens_2()
#---------------------------------------------------------------------#
   UPDATE ped_itens
      SET qtd_pecas_solic  = p_ped_itens_qfp.qtd_solic_aceita,
          qtd_pecas_cancel = 0,
          pre_unit         = p_ped_itens.pre_unit
    WHERE ped_itens.cod_empresa = p_cod_empresa
      AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
      AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
      AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega
   IF   sqlca.sqlcode <> 0
   THEN CALL log003_err_sql("ATUALIZA_3","PED_ITENS")
   END IF
  
  CALL pol0874_incl_ped_of_pcp()

END FUNCTION
	
#---------------------------------------------------------------------#
 FUNCTION pol0874_grava_ped_itens()
#---------------------------------------------------------------------#

  DEFINE p_atualiz CHAR(1) 

  DEFINE p_cod_item_cli  LIKE cliente_item.cod_item_cliente,
         p_alter_tecnica LIKE pedidos_edi_pe6.alter_tecnica,
         l_des_1         CHAR(76),
         l_des_2         CHAR(76),
         l_num_seq       INTEGER
         
  LET p_atualiz = "N"

  IF p_atualiz = "N" THEN
     LET p_ped_itens.cod_empresa = p_cod_empresa                 
     LET p_ped_itens.num_pedido = p_ped_itens_qfp.num_pedido
     LET p_ped_itens.cod_item = p_ped_itens_qfp.cod_item
     LET p_ped_itens.pct_desc_adic = 0                             
     LET p_ped_itens.qtd_pecas_solic = p_ped_itens_qfp.qtd_solic_aceita
     LET p_ped_itens.qtd_pecas_atend = 0                             
     LET p_ped_itens.qtd_pecas_cancel = 0                             
     LET p_ped_itens.qtd_pecas_reserv = 0                             
     LET p_ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega
     LET p_ped_itens.val_desc_com_unit = 0                             
     LET p_ped_itens.val_frete_unit = 0                             
     LET p_ped_itens.val_seguro_unit = 0                             
     LET p_ped_itens.qtd_pecas_romaneio = 0                             
     LET p_ped_itens.pct_desc_bruto = 0                             

     SELECT MAX(num_sequencia)
        INTO p_ped_itens.num_sequencia
     FROM ped_itens
     WHERE ped_itens.cod_empresa = p_cod_empresa
       AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido

     IF p_ped_itens.num_sequencia IS NULL THEN 
        LET p_ped_itens.num_sequencia = 0
     END IF

     LET p_ped_itens.num_sequencia = p_ped_itens.num_sequencia + 1

     IF SQLCA.SQLCODE = 0 THEN  
        INSERT INTO ped_itens VALUES (p_ped_itens.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","PED_ITENS")
        END IF

        LET p_audit_vdp.cod_empresa = p_cod_empresa
        LET p_audit_vdp.num_pedido = p_ped_itens_qfp.num_pedido
        LET p_audit_vdp.tipo_informacao = 'M' 
        LET p_audit_vdp.tipo_movto = 'I'
        LET p_audit_vdp.texto = 'INCLUSAO SEQUENCIA ',p_ped_itens.num_sequencia,' ENTREGA ',p_ped_itens.prz_entrega,' QUANTIDADE ',p_ped_itens.qtd_pecas_solic
        LET p_audit_vdp.num_programa = 'pol0874'
        LET p_audit_vdp.data =  TODAY
        LET p_audit_vdp.hora =  TIME 
        LET p_audit_vdp.usuario = p_user
        LET p_audit_vdp.num_transacao = 0  
        INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","audit_vdp")
        END IF

     #  aqui         
        SELECT cod_item_cliente 
           INTO p_cod_item_cli
        FROM cliente_item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_ped_itens_qfp.cod_item

        INITIALIZE l_des_1,
                   l_des_2 TO NULL

        INITIALIZE p_identif TO NULL

        SELECT identif_prog_atual
          INTO p_identif
          FROM pedidos_edi_pe1 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_itens_qfp.num_pedido
        IF p_identif IS NOT NULL THEN
           LET p_release = 'RELEASE ',p_identif  
        ELSE
           INITIALIZE p_release TO NULL
        END IF   

        SELECT alter_tecnica
          INTO p_alter_tecnica
          FROM pedidos_edi_pe6 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_itens_qfp.num_pedido
        IF SQLCA.sqlcode = 0 THEN 
           LET p_des_alter = "REVISAO ",p_alter_tecnica
           DECLARE cq_te1 CURSOR FOR
           SELECT *
             FROM pedidos_edi_te1 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_ped_itens_qfp.num_pedido
           FOREACH cq_te1 INTO p_pedidos_edi_te1.* 
             LET l_des_1 = p_pedidos_edi_te1.texto_1,' ',p_pedidos_edi_te1.texto_2[1,30]
             LET l_des_2 = p_pedidos_edi_te1.texto_2[31,40],' ',p_pedidos_edi_te1.texto_3
             EXIT FOREACH            
           END FOREACH

           LET l_num_seq =  p_ped_itens.num_sequencia
           WHILE TRUE 
              SELECT *
                INTO p_ped_itens_texto.*
              FROM ped_itens_texto
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido  = p_ped_itens_qfp.num_pedido
                AND num_sequencia = l_num_seq	
              IF SQLCA.SQLCODE = 0 THEN
                 IF l_num_seq = p_ped_itens.num_sequencia THEN 
                    UPDATE ped_itens_texto SET den_texto_2 = p_des_alter,
                                               den_texto_3 = l_des_1,
                                               den_texto_4 = l_des_2,
                                               den_texto_5 = p_release
                     WHERE cod_empresa = p_cod_empresa
                       AND num_pedido  = p_ped_itens_qfp.num_pedido
                       AND num_sequencia = l_num_seq
                 ELSE
                    IF (p_ped_itens_texto.den_texto_3 IS NULL OR
                        p_ped_itens_texto.den_texto_3 = " ") AND   
                       (p_ped_itens_texto.den_texto_4 IS NULL OR
                        p_ped_itens_texto.den_texto_4 = " ") THEN    
                       UPDATE ped_itens_texto SET den_texto_3 = l_des_1,
                                                  den_texto_4 = l_des_2
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens_qfp.num_pedido
                          AND num_sequencia = l_num_seq
                    ELSE
                       EXIT WHILE 
                    END IF 
                 END IF       
              ELSE
                 INSERT INTO ped_itens_texto
                    VALUES (p_cod_empresa,
                            p_ped_itens_qfp.num_pedido,
                            l_num_seq,
                            NULL,
                            p_des_alter,    
                            l_des_1,
                            l_des_2,
                            p_release)
                 IF SQLCA.SQLCODE <> 0 THEN 
                    CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
                 END IF
              END IF   
              LET l_num_seq = l_num_seq - 1
              IF l_num_seq = 0 THEN
                 EXIT WHILE 
              END IF 
              
           END WHILE 
               
           SELECT *
             FROM item_esp 
            WHERE cod_empresa = p_cod_empresa
              AND cod_item = p_ped_itens_qfp.cod_item
              AND num_seq = 1
           IF SQLCA.SQLCODE = 0 THEN
              UPDATE item_esp
                 SET des_esp_item = p_des_alter     
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item = p_ped_itens_qfp.cod_item
                 AND num_seq = 1
              IF SQLCA.SQLCODE <> 0 THEN 
                 CALL log003_err_sql("ATUALIZA_1","ITEM_ESP")
              END IF
           ELSE
              INSERT INTO item_esp
              VALUES (p_cod_empresa,
                      p_ped_itens_qfp.cod_item,
                      1,
                      p_des_alter)
              IF SQLCA.SQLCODE <> 0 THEN 
                 CALL log003_err_sql("INCLUSAO_1","ITEM_ESP")
              END IF
           END IF
           # aqui         
        ELSE
           DECLARE cq_te11 CURSOR FOR
           SELECT *
             FROM pedidos_edi_te1 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_ped_itens_qfp.num_pedido
           FOREACH cq_te11 INTO p_pedidos_edi_te1.* 
             LET l_des_1 = p_pedidos_edi_te1.texto_1,' ',p_pedidos_edi_te1.texto_2[1,30]
             LET l_des_2 = p_pedidos_edi_te1.texto_2[31,40],' ',p_pedidos_edi_te1.texto_3
             EXIT FOREACH            
           END FOREACH

           LET l_num_seq =  p_ped_itens.num_sequencia
           WHILE TRUE 
            SELECT *
              INTO p_ped_itens_texto.*
              FROM ped_itens_texto
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido  = p_ped_itens_qfp.num_pedido
                AND num_sequencia = l_num_seq	
              IF SQLCA.SQLCODE = 0 THEN
                 IF l_num_seq = p_ped_itens.num_sequencia THEN 
                    UPDATE ped_itens_texto SET den_texto_2 = p_des_alter,
                                               den_texto_3 = l_des_1,
                                               den_texto_4 = l_des_2,
                                               den_texto_5 = p_release
                     WHERE cod_empresa = p_cod_empresa
                       AND num_pedido  = p_ped_itens_qfp.num_pedido
                       AND num_sequencia = l_num_seq
                 ELSE
                    IF (p_ped_itens_texto.den_texto_3 IS NULL OR
                        p_ped_itens_texto.den_texto_3 = " ") AND   
                       (p_ped_itens_texto.den_texto_4 IS NULL OR
                        p_ped_itens_texto.den_texto_4 = " ") THEN    
                       UPDATE ped_itens_texto SET den_texto_3 = l_des_1,
                                                  den_texto_4 = l_des_2
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens_qfp.num_pedido
                          AND num_sequencia = l_num_seq
                    ELSE
                       EXIT WHILE 
                    END IF 
                 END IF       
              ELSE
                 INSERT INTO ped_itens_texto
                    VALUES (p_cod_empresa,
                            p_ped_itens_qfp.num_pedido,
                            l_num_seq,
                            NULL,
                            p_des_alter,    
                            l_des_1,
                            l_des_2,
                            p_release)
                 IF SQLCA.SQLCODE <> 0 THEN 
                    CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
                 END IF
              END IF   
              LET l_num_seq = l_num_seq - 1
              IF l_num_seq = 0 THEN
                 EXIT WHILE 
              END IF 
              
           END WHILE 
        END IF    
     ELSE 
        RETURN FALSE
     END IF
     CALL pol0874_incl_ped_of_pcp()
  END IF	

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_deleta_ped_itens_qfp()
#---------------------------------------------------------------------#
  CALL log085_transacao("BEGIN")

  DELETE FROM ped_itens_qfp
  WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
    AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
    AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
  IF SQLCA.sqlcode <> 0 THEN 
     CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP")
     CALL log085_transacao("ROLLBACK")
  ELSE
     DELETE FROM ped_itens_qfp_pe5
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_qfp.num_pedido
        AND cod_item    = p_ped_itens_qfp.cod_item
     IF SQLCA.sqlcode <> 0 THEN 
        CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE5")
        CALL log085_transacao("ROLLBACK")
     ELSE
        DELETE from pedidos_edi_pe1 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_itens_qfp.num_pedido
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE1")
           CALL log085_transacao("ROLLBACK")
        ELSE
           DELETE from pedidos_edi_pe2 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_ped_itens_qfp.num_pedido
           IF SQLCA.sqlcode <> 0 THEN 
              CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE2")
              CALL log085_transacao("ROLLBACK")
           ELSE
              DELETE from pedidos_edi_pe3 
               WHERE cod_empresa = p_cod_empresa
                 AND num_pedido  = p_ped_itens_qfp.num_pedido
              IF SQLCA.sqlcode <> 0 THEN 
                 CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE3")
                 CALL log085_transacao("ROLLBACK")
              ELSE
                 DELETE from pedidos_edi_pe4 
                  WHERE cod_empresa = p_cod_empresa
                    AND num_pedido  = p_ped_itens_qfp.num_pedido
                 IF SQLCA.sqlcode <> 0 THEN 
                    CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE4")
                    CALL log085_transacao("ROLLBACK")
                 ELSE
                    DELETE from pedidos_edi_pe5 
                     WHERE cod_empresa = p_cod_empresa
                       AND num_pedido  = p_ped_itens_qfp.num_pedido
                    IF SQLCA.sqlcode <> 0 THEN 
                       CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE5")
                       CALL log085_transacao("ROLLBACK")
                    ELSE
                       DELETE from pedidos_edi_pe6 
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens_qfp.num_pedido
                       IF SQLCA.sqlcode <> 0 THEN 
                          CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE6")
                          CALL log085_transacao("ROLLBACK")
                       ELSE
                          DELETE from pedidos_edi_te1 
                           WHERE cod_empresa = p_cod_empresa
                             AND num_pedido  = p_ped_itens_qfp.num_pedido
                          IF SQLCA.sqlcode <> 0 THEN 
                             CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_TE1")
                             CALL log085_transacao("ROLLBACK")
                          ELSE
                             CALL log085_transacao("COMMIT")
                          END IF 
                       END IF 
                    END IF
                 END IF             
              END IF 
           END IF 
        END IF          
     END IF     
  END IF 

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_deleta_pedidos_qfp()
#---------------------------------------------------------------------#
  CALL log085_transacao("BEGIN")

  DELETE FROM pedidos_qfp
  WHERE pedidos_qfp.cod_empresa = p_cod_empresa
    AND pedidos_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
 
  IF SQLCA.sqlcode = 0 THEN
     CALL log085_transacao("COMMIT")
     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("DELECAO_1","PEDIDOS_QFP")
        CALL log085_transacao("ROLLBACK")
     END IF
  ELSE 
     CALL log003_err_sql("DELECAO_2","PEDIDOS_QFP")
     CALL log085_transacao("ROLLBACK")
  END IF

  INITIALIZE p_ped_itens_qfp.*, p_ped_itens.*, p_num_nff_ult,
             p_qtd_estoque, p_qtd_embarcado TO NULL
  FOR p_ind = 1 TO 100
      INITIALIZE t_ped_itens_qfp[p_ind].* TO NULL
  END FOR
  CLEAR FORM

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_exclusao_ped_itens_qfp()
#---------------------------------------------------------------------#
 CALL log085_transacao("BEGIN")
IF log004_confirm(22,45) THEN 
   WHENEVER ERROR CONTINUE
   DELETE FROM ped_itens_qfp
    WHERE ped_itens_qfp.cod_empresa = p_ped_itens_qfp.cod_empresa
      AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
      AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
   IF sqlca.sqlcode = 0 THEN 
      CALL log085_transacao("COMMIT")
      IF SQLCA.sqlcode = 0 THEN
         FOR p_ind = 1 TO 100
             INITIALIZE t_ped_itens_qfp[p_ind].* TO NULL
         END FOR
      ELSE 
         CALL log003_err_sql("EXCLUSAO_1","PED_ITENS_QFP")
         CALL log085_transacao("ROLLBACK")
      END IF
   ELSE 
      CALL log003_err_sql("EXCLUSAO_2","PED_ITENS_QFP")
      CALL log085_transacao("ROLLBACK")
   END IF
  
   CALL log085_transacao("BEGIN")

   DELETE FROM pedidos_qfp
    WHERE pedidos_qfp.cod_empresa = p_ped_itens_qfp.cod_empresa
      AND pedidos_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
   IF SQLCA.sqlcode = 0 THEN
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode = 0 THEN
         MESSAGE " Exclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
         INITIALIZE p_ped_itens_qfp.*, p_ped_itens_qfpr.*, p_num_nff_ult,
                    p_qtd_estoque, p_qtd_embarcado TO NULL
         CLEAR FORM
      ELSE 
         CALL log003_err_sql("EXCLUSAO_1","PEDIDOS_QFP")
         CALL log085_transacao("ROLLBACK")
      END IF
   ELSE 
      CALL log003_err_sql("EXCLUSAO_2","PEDIDOS_QFP")
      CALL log085_transacao("ROLLBACK")
   END IF
   WHENEVER ERROR STOP
ELSE 
   CALL log085_transacao("ROLLBACK")
END IF
MESSAGE "                            "
ERROR " Execute novamente a Consulta  "
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_paginacao(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF   p_ies_cons
  THEN LET p_ped_itens_qfpr.* = p_ped_itens_qfp.*
       WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE"
                         FETCH NEXT     cq_ped_itens_qfp INTO 
                            p_ped_itens_qfp.num_pedido,p_ped_itens_qfp.cod_item,
                            p_num_nff_ult, p_cod_cliente,p_cod_item_cliente
         WHEN p_funcao = "ANTERIOR"
                         FETCH PREVIOUS cq_ped_itens_qfp INTO 
                            p_ped_itens_qfp.num_pedido,p_ped_itens_qfp.cod_item,
                            p_num_nff_ult, p_cod_cliente,p_cod_item_cliente
       END CASE
       IF   sqlca.sqlcode = NOTFOUND
       THEN ERROR " Nao existem mais itens nesta direcao "
            EXIT WHILE
       END IF
       WHENEVER ERROR CONTINUE  
       IF   p_num_nff_ult IS NULL #pol0874_verifica_pedidos_qfp() = FALSE
       THEN LET p_num_nff_ult = 0
       END IF
       IF pol0874_verifica_pedido() THEN
          CALL pol0874_verifica_nff()
          LET p_qtd_embarcado = 0
          LET p_saldo         = 0
       END IF
       IF   pol0874_verifica_estoque()
       THEN 
       ELSE LET p_qtd_estoque = 0
       END IF  
       CALL pol0874_monta_dados_consulta()
       WHENEVER ERROR STOP
       IF SQLCA.sqlcode = 0 OR 
          SQLCA.sqlcode = -284 THEN 
          IF p_ped_itens_qfp.num_pedido = p_ped_itens_qfpr.num_pedido AND 
             p_ped_itens_qfp.cod_item   = p_ped_itens_qfpr.cod_item THEN 
          ELSE 
             IF p_possui_it = 'S' THEN 
                CALL pol0874_exibe_dados()
                EXIT WHILE
             ELSE
                ERROR 'PEDIDO NAO POSSUI PROGRAMACAO '
                EXIT WHILE 
             END IF       
          END IF
       END IF
       END WHILE
  ELSE ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_help()
#---------------------------------------------------------------------#
  CASE
    WHEN infield(num_pedido)      CALL showhelp(2044)
  END CASE
 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0874_exibe_dados()
#---------------------------------------------------------------------#
  DEFINE p_count SMALLINT
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_cod_cliente TO cod_cliente
  DISPLAY p_cod_item_cliente TO p_cod_item_cliente
#  DISPLAY p_tela.dat_prog    TO dat_prog                
#  DISPLAY p_tela.ies_data    TO ies_data                
#  DISPLAY p_tela.ies_firme   TO ies_firme           
#  DISPLAY p_tela.ies_requis  TO ies_requis          
#  DISPLAY p_tela.ies_planej  TO ies_planej          
  CALL pol0874_verifica_cliente()
  DISPLAY BY NAME p_ped_itens_qfp.num_pedido,
                  p_ped_itens_qfp.cod_item,
                  p_num_nff_ult,
                  p_qtd_estoque,
                  p_qtd_embarcado

  CALL set_count(p_ind - 1)
  IF   p_ind < 10
  THEN LET p_count = p_ind - 1
       FOR p_ind = 1 TO p_count
           DISPLAY t_ped_itens_qfp[p_ind].* TO s_ped_itens_qfp[p_ind].*
       END FOR
  ELSE DISPLAY ARRAY t_ped_itens_qfp TO s_ped_itens_qfp.*
       LET int_flag = 0
  END IF
  LET p_ind = p_ind - 1
END FUNCTION

#----------------------------------#
 FUNCTION pol0874_incl_ped_of_pcp()
#----------------------------------#
#
# INCLUI O ITEN NA TABELA DE PEDIDOS ORDEM DE FABRICACAO OU NA TABELA
# DE PEDIDOS P.C.P CONFORME A INDICACAO NA TABELA DE LINHA DE PRODUTO
# BUSCA A LINHA DE PRODUTO DO ITEM NA TABELA DE PRODUTOS
#
  DEFINE  p_ped_ord_fabr         RECORD LIKE ped_ord_fabr.*,
          p_ped_pcp              RECORD LIKE ped_pcp.*
  DEFINE  p_cod_lin_prod         LIKE item.cod_lin_prod,
          p_cod_lin_recei        LIKE item.cod_lin_recei,
          p_cod_seg_merc         LIKE item.cod_seg_merc,
          p_cod_cla_uso          LIKE item.cod_cla_uso,
          p_ies_emite_of         LIKE linha_prod.ies_emite_of,
          p_num_sequencia        LIKE ped_itens.num_sequencia

 SELECT cod_lin_prod, cod_lin_recei,
        cod_seg_merc, cod_cla_uso
   INTO p_cod_lin_prod,  p_cod_lin_recei,
        p_cod_seg_merc,  p_cod_cla_uso
   FROM item    
  WHERE item.cod_item    = p_ped_itens_qfp.cod_item
    AND item.cod_empresa = p_cod_empresa
 IF   sqlca.sqlcode = 0 
 THEN
 ELSE RETURN
 END IF

 SELECT ies_emite_of  INTO p_ies_emite_of
   FROM linha_prod
  WHERE linha_prod.cod_lin_prod  = p_cod_lin_prod
    AND linha_prod.cod_lin_recei = p_cod_lin_recei
    AND linha_prod.cod_seg_merc  = p_cod_seg_merc
    AND linha_prod.cod_cla_uso   = p_cod_cla_uso
    AND linha_prod.ies_emite_of  = "2"
 IF   sqlca.sqlcode = 0 
 THEN
 ELSE RETURN
 END IF
 
 DECLARE c_ped_itens CURSOR FOR
  SELECT num_sequencia  INTO p_num_sequencia
    FROM ped_itens
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_ped_itens_qfp.num_pedido
     AND prz_entrega = p_ped_itens_qfp.prz_entrega

 FOREACH c_ped_itens  INTO p_num_sequencia

    LET p_ped_pcp.cod_empresa       = p_cod_empresa
    LET p_ped_pcp.num_pedido        = p_ped_itens.num_pedido
    LET p_ped_pcp.num_sequencia     = p_num_sequencia
    INITIALIZE p_ped_pcp.qtd_cancelada, p_ped_pcp.prz_entrega_ant TO NULL
    LET p_ped_pcp.nom_usuario       = p_user
           LET p_ped_pcp.num_transacao     = 0
    INSERT INTO ped_pcp VALUES (p_ped_pcp.*)
    IF   sqlca.sqlcode = 0 
    THEN RETURN 
    ELSE CALL log003_err_sql("INCLUSAO","PED_PCP")
    END IF
 END FOREACH 

 END FUNCTION

#---------------------------------#
FUNCTION pol0874_verifica_cliente()
#---------------------------------#
   INITIALIZE m_nom_cliente TO NULL

   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   DISPLAY m_nom_cliente TO nom_cliente

   IF SQLCA.SQLCODE <> 0        AND 
      p_cod_cliente IS NOT NULL AND
      p_cod_cliente <> " "      THEN
      ERROR "Cliente nao encontrado."
   END IF
END FUNCTION

#-----------------------#
 FUNCTION pol0874_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
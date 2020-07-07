#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: POL0212                                               #
# OBJETIVO: VARIACAO DA PROGRAMACAO DO CLIENTE     - BI           #
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
         p_dat_emissao          DATE, #LIKE fat_nf_mestre.dat_emissao,
         p_dat_emis_ult         DATE, #LIKE fat_nf_mestre.dat_emissao,
         p_qtd_embarcado        LIKE fat_nf_item.qtd_item,
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_qtd_pecas_cancel     DECIMAL(10,3),
         p_qtd_firme            DECIMAL(10,3),
         p_cod_item_cliente     LIKE cliente_item.cod_item_cliente,
         p_cod_item             LIKE item.cod_item,
         p_identif              LIKE pedidos_edi_pe1.identif_prog_atual,
         p_release              CHAR(40),
         p_saldo                DECIMAL(10,3),
         p_ship_date            DATE,
         p_tipo_item            CHAR(10),
         p_dat_entrega          DATE,
         p_dat_ult_nff          DATE,
         p_index                SMALLINT,
         s_index                SMALLINT,
         p_comm                 CHAR(01),
         p_e_kanban             CHAR(01), 
         p_des_alter            CHAR(40),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT,
         p_msg                  CHAR(500),
         p_hoje                 DATE,
         p_den_tipo             CHAR(6),
         p_ind                  SMALLINT,
         p_count                INTEGER,
         P_Comprime             CHAR(01),
         p_descomprime          CHAR(01),
         p_6lpp                 CHAR(100),
         p_8lpp                 CHAR(100),
         p_imprimiu             SMALLINT,
         p_parametro            CHAR(25)

   DEFINE p_dat_ini            DATE,
          p_dat_fim            DATE
          

   DEFINE p_qtd_dias_entrega    INTEGER,
          p_qtd_dias_cadastro   INTEGER

  DEFINE t_ped_itens_qfp  ARRAY[500] OF RECORD
                          ies_atualiza     CHAR(01), 
                          prz_entrega      LIKE ped_itens_qfp.prz_entrega,
                          qtd_solic        LIKE ped_itens_qfp.qtd_solic,
                          qtd_atendida     LIKE ped_itens_qfp.qtd_solic,
                          qtd_solic_nova   LIKE ped_itens_qfp.qtd_solic_nova,
                          qtd_solic_aceita LIKE ped_itens_qfp.qtd_solic_aceita,
                          qtd_variacao     DECIMAL(07,0),
                          sit_programa     CHAR(11),
                          acao             CHAR(20)
  END RECORD
  
  DEFINE t_ped_itens_seq  ARRAY[500] OF RECORD    
         num_sequencia    integer,
         ship_date        DATE
  END RECORD

  DEFINE p_tela   RECORD
                   identif_arq CHAR(09),
                   dat_arq     DATE,    
                   qtd_acum    DECIMAL(9,0), 
                   qtd_ped     DECIMAL(9,0),  
                   ies_data    CHAR(1),
                   ies_firme   CHAR(1),
                   ies_requis  CHAR(1),
                   ies_planej  CHAR(1),
                   dat_prog    DATE    
                 END RECORD

  DEFINE p_ped_itens_qfp     RECORD LIKE ped_itens_qfp.*
  DEFINE p_ped_itens_qfp_pe5 RECORD LIKE ped_itens_qfp_pe5.*
  DEFINE p_pedidos_edi_te1   RECORD LIKE pedidos_edi_te1.*
  DEFINE p_ped_itens_qfpr    RECORD LIKE ped_itens_qfp.*
  DEFINE p_ped_itens_texto   RECORD LIKE ped_itens_texto.*
  DEFINE p_ped_itens_can     RECORD LIKE ped_itens.*
  DEFINE p_ped_itens         RECORD LIKE ped_itens.*
  DEFINE p_ped_itens_ex      RECORD LIKE ped_itens.*
  DEFINE p_audit_vdp         RECORD LIKE audit_vdp.*
  DEFINE p_log_versao_prg    RECORD LIKE log_versao_prg.*
  
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

DEFINE p_efetivada RECORD
       cod_empresa      char(02),
       num_pedido       integer,                            
       num_sequencia    integer,                            
       cod_item         char(15),                           
       dat_proces       date,                               
       prz_entrega      date,                               
       qtd_solic        decimal(10,2),                      
       qtd_nova         decimal(10,2),                      
       qtd_aceita       decimal(10,2),                      
       sit_programa     char(11),                           
       cod_usuario      char(08),
       mensagem         char(25)                  
END RECORD

{  >>  OS 115462 - INICIO  <<  }
   DEFINE
      mr_par_vdp      RECORD  LIKE  par_vdp.*,
      m_cod_tip_carteira_ant  LIKE  pedidos.cod_tip_carteira,
      m_cod_tip_carteira      LIKE  pedidos.cod_tip_carteira,
      m_qtd_decimais_cart     DECIMAL(1,0),
      m_qtd_decimais_par      DECIMAL(1,0)
{  >>  OS 115462 - FINAL  <<  }

   DEFINE m_nom_cliente       LIKE clientes.nom_cliente,
          g_ies_ambiente      CHAR(01),
          comando             CHAR(80),
          p_den_empresa       CHAR(36),
          p_den_item          CHAR(18)

   DEFINE p_relat RECORD
   cod_empresa      char(02),
   num_pedido       integer,                                
   num_sequencia    integer,                                
   cod_item         char(15),                               
   dat_proces       date,                                   
   prz_entrega      date,                                   
   qtd_solic        decimal(10,2),                          
   qtd_nova         decimal(10,2),                          
   qtd_aceita       decimal(10,2),                          
   sit_programa     char(11),                               
   cod_usuario      char(08),   
   mensagem         char(25)                             
   END RECORD
   
MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0212-10.02.46"
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()             
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
    CALL pol0212_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION pol0212_controle()
#---------------------------------------------------------------------#
  INITIALIZE p_ped_itens_qfp.*, p_ped_itens_qfpr.*, p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("POL0212") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0212 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

{  >>  OS 115462 - INICIO  <<  }
   SELECT * INTO mr_par_vdp.* FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      ERROR " Parametros do Sistema nao cadastrados (VDP1400) "
   END IF

   CALL pol0212_atualiza_versao() 

   CALL pol0212_cria_temp()

   LET m_qtd_decimais_par = mr_par_vdp.par_vdp_txt[43,43]
{  >>  OS 115462 - FINAL  <<  }

  MENU "OPCAO"
    COMMAND "fiRme"    "Processa toda programação firme"
      IF pol0212_processa_firme() THEN
         ERROR 'Operação efetuada com sucesso'
      ELSE
         ERROR 'Operação cancelada'
      END IF
    COMMAND "Consultar"    "Consulta Programacao do cliente"
      HELP 0004
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","POL0212","CO")
      THEN CALL pol0212_consulta_ped_itens_qfp()
           MESSAGE "                 "
      END IF
    COMMAND "Processar" "Confirma a Programacao do cliente "
      HELP 2043
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","POL0212","MO") THEN
        IF t_ped_itens_qfp[1].prz_entrega IS NULL THEN 
           MESSAGE "Nao existem dados para confirmacao"  ATTRIBUTE(REVERSE)
        ELSE
          IF log004_confirm(22,45) THEN
             ERROR " Em Processamento... "
             CALL pol0212_prepara_ped_itens()
             IF p_comm = 'S' THEN
                MESSAGE "Confirmacao Executada com Sucesso"  ATTRIBUTE(REVERSE)
                CALL pol0212_deleta_ped_itens_qfp()
                IF sqlca.sqlcode = 0 THEN
                   CALL pol0212_deleta_pedidos_qfp()
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
      CALL pol0212_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe Programacao anterior "
      HELP 0006
      MESSAGE ""
      CALL pol0212_paginacao("ANTERIOR")
    COMMAND "Excluir"  "Exclui Programacao do cliente"
      HELP 0003
      MESSAGE ""
      IF   p_ped_itens_qfp.num_pedido IS NOT NULL
      THEN IF   log005_seguranca(p_user,"VDP","POL0212","EX")
           THEN CALL pol0212_exclusao_ped_itens_qfp()
           END IF
      ELSE 
         MESSAGE "Consulte Previamente para fazer a Exclusao !!!" 
            ATTRIBUTE (REVERSE)
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0212_sobre()
    COMMAND "Listar" "Listgem das programações efetivadas"
         CALL pol0212_listagem()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0212
END FUNCTION

#----------------------------------#
 FUNCTION pol0212_atualiza_versao()
#----------------------------------#
  DEFINE p_num_prog    CHAR(08),   
         p_num_vers    CHAR(09),   
         p_dat_alte    DATE   
  
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

#---------------------------#
 FUNCTION pol0212_cria_temp()
#---------------------------#

   DROP TABLE t_ped_it;
   CREATE TABLE t_ped_it
   (
    cod_empresa        CHAR(02),
    num_pedido         DECIMAL(6,0),
    cod_item           CHAR(15)
   );

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","t_ped_it")
   END IF

   DROP TABLE prog_tmp;
   CREATE TABLE prog_tmp (
     ies_atualiza     CHAR(01),      
     prz_entrega      date,                               
     qtd_solic        dec(10,3),                          
     qtd_atendida     dec(10,3),                          
     qtd_solic_nova   dec(10,3),                          
     qtd_solic_aceita dec(10,3),                          
     qtd_variacao     DECIMAL(07,0),                      
     sit_programa     CHAR(11),                           
     acao             CHAR(20)                            
   );                                                          

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","prog_tmp")
   END IF
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol0212_consulta_ped_itens_qfp()
#---------------------------------------------#

  DEFINE where_clause, sql_stmt CHAR(650),
         l_count     INTEGER

  CLEAR FORM
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol0212
  DISPLAY p_cod_empresa TO cod_empresa
  
  LET INT_FLAG = FALSE
  LET p_tela.dat_prog = "31/12/2999"
  LET p_ped_itens_qfpr.* = p_ped_itens_qfp.*
  INITIALIZE p_ped_itens_qfp.*,
             t_ped_itens_qfp  TO NULL

  CALL pol0212_carrega_kanban()

  CONSTRUCT BY NAME where_clause ON ped_itens_qfp.num_pedido,
                                    ped_itens_qfp.cod_item,
                                    pedidos.cod_cliente

  IF INT_FLAG THEN
     LET p_ies_cons = FALSE
     INITIALIZE p_ped_itens_qfp to NULL
     ERROR 'Operação cancelada.'
     RETURN
  END IF
  
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

  AFTER FIELD ies_data
     IF p_tela.ies_data IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD ies_data 
     END IF   
     
  AFTER FIELD ies_firme
     IF p_tela.ies_firme IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD ies_firme
     END IF
                                                                  
  AFTER FIELD ies_requis
     IF p_tela.ies_requis IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD ies_requis 
     END IF                                                                  

  AFTER FIELD ies_planej 
     IF p_tela.ies_planej IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD ies_planej 
     END IF                                                                  

  AFTER FIELD dat_prog   
     IF p_tela.dat_prog   IS NULL THEN
        LET p_tela.dat_prog = "31/13/2999"         
     END IF   

  END INPUT 
                                                               
  IF int_flag THEN 
     LET int_flag = 0
     INITIALIZE p_ped_itens_qfp to null
     LET p_ies_cons = FALSE
     CLEAR FORM
     DISPLAY p_cod_empresa to cod_empresa
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
                 "AND pedidos.num_pedido      = ped_itens_qfp.num_pedido  "

  PREPARE var_query FROM sql_stmt

  DECLARE cq_ped_itens_qfp SCROLL CURSOR WITH HOLD FOR var_query
  OPEN  cq_ped_itens_qfp
  FETCH cq_ped_itens_qfp 
        INTO p_ped_itens_qfp.num_pedido,
             p_ped_itens_qfp.cod_item,
             p_num_nff_ult,
             p_cod_cliente,
             p_cod_item_cliente
  
  IF STATUS <> 0 THEN
     MESSAGE "Argumentos de Pesquisa nao Encontrados !!!" ATTRIBUTE(REVERSE)
     LET p_ies_cons = FALSE
     RETURN
  END IF
  
  CALL pol0212_pega_dados()
  CALL pol0212_monta_dados_consulta()  
  CALL pol0212_exibe_dados()                                            
  CALL pol0212_marca_atualiz()                                          
  LET int_flag = 0                                                      
  
END FUNCTION

#---------------------------#
FUNCTION pol0212_pega_dados()
#---------------------------#

  MESSAGE " Consultando ... "
  LET p_ies_cons = TRUE
          
  IF p_num_nff_ult IS NULL THEN 
     LET p_num_nff_ult = 0
  END IF
          
  IF pol0212_verifica_pedido() THEN
     CALL pol0212_verifica_nff()
     LET p_qtd_embarcado = 0
     LET p_saldo         = 0
  END IF
          
  IF pol0212_verifica_estoque() THEN
  ELSE
     LET p_qtd_estoque = 0
  END IF
     
  IF p_cod_item_cliente IS NULL THEN                                     
     SELECT cod_item_cliente                                             
       INTO p_cod_item_cliente                                           
       FROM cliente_item                                                 
      WHERE cod_empresa = p_cod_empresa                                  
        AND cod_cliente_matriz = p_cod_cliente                           
        AND cod_item = p_ped_itens_qfp.cod_item                          
  END IF                                                                 
                                                                         
   SELECT identif_prog_atual,                                            
          dat_prog_atual                                                 
     INTO p_tela.identif_arq,                                            
          p_tela.dat_arq                                                 
     FROM pedidos_edi_pe1                                                
    WHERE cod_empresa = p_cod_empresa                                    
      AND num_pedido  = p_ped_itens_qfp.num_pedido                       
                                                                 
   LET p_identif = p_tela.identif_arq                                    
                                                                 
   LET  p_tela.qtd_acum  = 0                                             
   SELECT qtd_receb_acum                                                 
     INTO p_tela.qtd_acum                                                
     FROM pedidos_edi_pe2                                                
    WHERE cod_empresa = p_cod_empresa                                    
      AND num_pedido  = p_ped_itens_qfp.num_pedido                       
   IF sqlca.sqlcode <> 0 THEN                                            
      LET  p_tela.qtd_acum  = 0                                          
   ELSE                                                                  
      LET p_tela.qtd_acum = p_tela.qtd_acum / 1000                       
   END IF                                                                
                                                                         
   LET p_hoje = TODAY                                                    
                                                                         

END FUNCTION

#-------------------------------#
 FUNCTION pol0212_carrega_kanban()
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
        IF l_count > 0 THEN 
        ELSE
          INSERT INTO t_ped_it VALUES (p_ped_itens_qfp.cod_empresa, 
                                       p_ped_itens_qfp.num_pedido, 
                                       p_ped_itens_qfp.cod_item )
        END IF    
     END FOREACH 
           
  END IF 
        
END FUNCTION
        

#-----------------------------------#
 FUNCTION pol0212_verifica_pedido()
#-----------------------------------#
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
 FUNCTION pol0212_verifica_nff()
#---------------------------------------------------------------------#
  LET p_dat_emis_ult = 0

  SELECT dat_hor_emissao
    INTO p_dat_emis_ult
    FROM fat_nf_mestre
   WHERE fat_nf_mestre.empresa = p_cod_empresa
     AND fat_nf_mestre.nota_fiscal = p_num_nff_ult
     AND fat_nf_mestre.cliente = p_cod_cliente
     
  IF STATUS = 0 THEN
      LET  p_tela.qtd_ped = 0 
      SELECT SUM(qtd_pecas_atend)
        INTO p_tela.qtd_ped
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido  =  p_ped_itens_qfp.num_pedido 
         AND prz_entrega <= p_dat_ult_nff
   
      IF p_tela.qtd_ped IS NULL THEN 
         LET p_tela.qtd_ped = 0 
      END IF 
  else
     LET p_dat_emis_ult = NULL
  end if    
  
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0212_verifica_estoque()
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

#----------------------------------------#
 FUNCTION pol0212_monta_dados_consulta()
#----------------------------------------#
  
   DEFINE p_achou SMALLINT
  
   LET p_qtd_firme = 0 
   CALL set_count(0)
   LET p_ind = 1
   INITIALIZE t_ped_itens_qfp, t_ped_itens_seq TO NULL
   
   LET p_cod_item = p_ped_itens_qfp.cod_item

   DECLARE e_ped_itens_qfp CURSOR WITH HOLD FOR
    SELECT * 
      FROM ped_itens_qfp
     WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
       AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
       AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
     ORDER BY prz_entrega

   FOREACH e_ped_itens_qfp INTO p_ped_itens_qfp.*  

      LET p_achou = FALSE

      DECLARE cq_pi cursor FOR
       SELECT * 
         FROM ped_itens_qfp_pe5
        WHERE cod_empresa = p_ped_itens_qfp.cod_empresa
          AND num_pedido = p_ped_itens_qfp.num_pedido 
          AND num_sequencia = p_ped_itens_qfp.num_sequencia
          AND cod_item      = p_ped_itens_qfp.cod_item       

      FOREACH cq_pi INTO p_ped_itens_qfp_pe5.*
   
         IF sqlca.sqlcode <> 0 THEN 
            EXIT FOREACH
         END IF
       
         LET p_achou = TRUE
       
         EXIT FOREACH
    
      END FOREACH
    
      IF NOT p_achou THEN
         CONTINUE FOREACH
      END IF
    
      IF p_tela.ies_data = "A" THEN
         IF p_ped_itens_qfp_pe5.dat_abertura > p_tela.dat_prog THEN
            CONTINUE FOREACH
         END IF
      ELSE 
         IF p_ped_itens_qfp.prz_entrega > p_tela.dat_prog THEN
            CONTINUE FOREACH
         END IF
      END IF

      IF p_ped_itens_qfp_pe5.ies_programacao = "8" THEN
         CONTINUE FOREACH      
      END IF
   
      LET p_ok ="N"     
      IF p_tela.ies_firme  = "S"  AND 
         p_tela.ies_requis = "S"  AND 
         p_tela.ies_planej = "S"  THEN 
         LET p_ok ="S"     
      ELSE 
         IF p_ped_itens_qfp_pe5.ies_programacao = "1" AND 
            p_tela.ies_firme = "S" THEN
            LET p_ok ="S"     
         ELSE 
            IF p_ped_itens_qfp_pe5.ies_programacao = "3" AND 
               p_tela.ies_requis= "S" THEN
               LET p_ok ="S"     
            ELSE 
               IF p_ped_itens_qfp_pe5.ies_programacao = "4" AND 
                  p_tela.ies_planej= "S" THEN
                  LET p_ok ="S"     
               END IF
            END IF
         END IF
      END IF

      IF p_ok = "N" THEN
         CONTINUE FOREACH
      END IF 

      IF p_ped_itens_qfp_pe5.ies_programacao = "1" THEN
         LET t_ped_itens_qfp[p_ind].sit_programa = "FIRME    " 
      ELSE 
         IF p_ped_itens_qfp_pe5.ies_programacao = "3" THEN
            LET t_ped_itens_qfp[p_ind].sit_programa = "REQUISICAO"
         ELSE 
            IF p_ped_itens_qfp_pe5.ies_programacao = "4" THEN
               LET t_ped_itens_qfp[p_ind].sit_programa = "PLANEJADO"
            ELSE 
               LET t_ped_itens_qfp[p_ind].sit_programa = "DOL      "
            END IF
         END IF
      END IF

      IF p_tela.ies_data = "A" THEN
         LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp_pe5.dat_abertura
      ELSE
         LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp.prz_entrega
      END IF
      
      LET p_dat_entrega = t_ped_itens_qfp[p_ind].prz_entrega
      
      CALL pol0212_ck_data()

      LET t_ped_itens_qfp[p_ind].ies_atualiza    = 'S'
      LET t_ped_itens_qfp[p_ind].qtd_solic       = p_ped_itens_qfp.qtd_solic
      LET t_ped_itens_qfp[p_ind].qtd_atendida    = p_ped_itens_qfp.qtd_atend
      LET t_ped_itens_qfp[p_ind].qtd_solic_nova  = p_ped_itens_qfp.qtd_solic_nova
      LET p_ped_itens_qfp.qtd_solic_aceita       = p_ped_itens_qfp.qtd_solic_nova

      LET t_ped_itens_qfp[p_ind].qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita
      
      IF p_ped_itens_qfp.qtd_solic_aceita = 0 then
         LET p_qtd_variacao  = p_ped_itens_qfp.qtd_solic - p_ped_itens_qfp.qtd_atend
      ELSE
         LET p_qtd_variacao  = p_ped_itens_qfp.qtd_solic_nova - p_ped_itens_qfp.qtd_solic 
      END IF

      LET t_ped_itens_qfp[p_ind].qtd_variacao   = p_qtd_variacao
      LET p_qtd_firme = p_qtd_firme + p_qtd_variacao
      LET t_ped_itens_seq[p_ind].num_sequencia = p_ped_itens_qfp.num_sequencia
      LET t_ped_itens_seq[p_ind].ship_date = p_ped_itens_qfp.prz_entrega
      CALL pol0212_acao()
      
      LET p_ind = p_ind + 1
 
   END FOREACH


END FUNCTION

#----------------------#
FUNCTION pol0212_acao()
#----------------------#

   IF p_dat_entrega < (TODAY - 7) THEN
      LET t_ped_itens_qfp[p_ind].acao = 'DESCARTAR'
   ELSE
      CALL pol0212_le_ped_itens() 
      IF p_prog_inex  = "N" THEN
         IF p_ped_itens.qtd_pecas_reserv   > 0 OR
            p_ped_itens.qtd_pecas_romaneio > 0 THEN
            LET t_ped_itens_qfp[p_ind].acao = 'DESCARTAR'
         ELSE 
            IF t_ped_itens_qfp[p_ind].qtd_solic_nova = 0  THEN
               LET t_ped_itens_qfp[p_ind].acao = 'CANCELAR'
            ELSE
               LET t_ped_itens_qfp[p_ind].acao = 'DESCARTAR'
            END IF
         END IF
      ELSE
         LET t_ped_itens_qfp[p_ind].acao = 'INCLUIR'
      END IF
   END IF
   
END FUNCTION

#-------------------------#
FUNCTION pol0212_ck_data()
#-------------------------#
   
   IF p_dat_entrega < (TODAY - 7) THEN
      LET t_ped_itens_qfp[p_ind].sit_programa = "PRZ ANTIGO"
      RETURN
   END IF
   
   IF p_dat_entrega < TODAY THEN
      LET t_ped_itens_qfp[p_ind].sit_programa = "PRZ VENCIDO"
      RETURN
   END IF
   
   LET p_qtd_dias_entrega = p_dat_entrega - TODAY

   SELECT qtd_dias
     INTO p_qtd_dias_cadastro
     FROM item_kanban_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      IF p_cod_item[1,2] = 'QA' THEN
         LET p_parametro = 'QTD_DIAS_ITEM_QA'
      ELSE
         IF p_cod_item[1,2] = 'QH' THEN
            LET p_parametro = 'QTD_DIAS_ITEM_QH'
         ELSE
            LET p_parametro = 'QTD_DIAS_ITEM_COMUM'
         END IF
      END IF
      CALL pol0212_le_parametro()
   END IF          
   
   IF p_qtd_dias_cadastro IS NULL THEN
      LET p_qtd_dias_cadastro = 0
   END IF
   
   IF p_qtd_dias_entrega < p_qtd_dias_cadastro THEN
      LET t_ped_itens_qfp[p_ind].sit_programa = "PRZ CURTO"
   ELSE
      LET t_ped_itens_qfp[p_ind].sit_programa = "PRZ OK"
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0212_le_parametro()
#-----------------------------#

   SELECT parametro_numerico
     INTO p_qtd_dias_cadastro
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = p_parametro
   IF STATUS <> 0 THEN
      LET p_qtd_dias_cadastro = 0
   END IF
   
END FUNCTION

   

#--------------------------#
 FUNCTION pol0212_saldo()
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
 FUNCTION pol0212_prepara_ped_itens()
#-------------------------------------#
  
   DEFINE p_gra_efetiv SMALLINT
   
   #Obs: se der erro critico, gerar uma critica p/ o relatório e
   #continuar o processo.
   
   LET p_ind = 1 
   
   FOR p_ind = 1 to 500 
       IF t_ped_itens_qfp[p_ind].prz_entrega IS NULL THEN 
          EXIT FOR
       END IF

       LET p_efetivada.cod_empresa  = p_cod_empresa
       LET p_efetivada.num_pedido   = p_ped_itens_qfp.num_pedido
       LET p_efetivada.num_sequencia= t_ped_itens_seq[p_ind].num_sequencia
       LET p_ship_date = t_ped_itens_seq[p_ind].ship_date
       LET p_efetivada.cod_item     = p_ped_itens_qfp.cod_item
       LET p_efetivada.dat_proces   = TODAY
       LET p_efetivada.prz_entrega  = t_ped_itens_qfp[p_ind].prz_entrega
       LET p_efetivada.qtd_solic    = t_ped_itens_qfp[p_ind].qtd_solic
       LET p_efetivada.qtd_nova     = t_ped_itens_qfp[p_ind].qtd_solic_nova
       LET p_efetivada.qtd_aceita   = t_ped_itens_qfp[p_ind].qtd_solic_aceita
       LET p_efetivada.sit_programa = t_ped_itens_qfp[p_ind].sit_programa
       LET p_efetivada.cod_usuario  = p_user
       LET p_gra_efetiv = TRUE
       
       IF t_ped_itens_qfp[p_ind].ies_atualiza  = 'S' THEN     
          IF pol0212_item_inativo() THEN
             LET p_efetivada.mensagem = 'ITEM INATIVO. VERIFIQUE O PEDIDO'
             CALL pol0212_grava_efetivacao()
             CONTINUE FOR
          END IF
          IF t_ped_itens_qfp[p_ind].prz_entrega >= (TODAY - 7) THEN
             LET p_ped_itens_qfp.prz_entrega = t_ped_itens_qfp[p_ind].prz_entrega
             CALL pol0212_le_ped_itens()
             IF p_prog_inex  = "N" THEN
                IF p_ped_itens.qtd_pecas_reserv   > 0 OR
                   p_ped_itens.qtd_pecas_romaneio > 0 THEN
                   LET p_efetivada.mensagem = 'DESCARTADA: TEM RESERVA' #tirar do relatório
                   LET p_gra_efetiv = FALSE
                ELSE 
                   IF t_ped_itens_qfp[p_ind].qtd_solic_nova = 0  THEN
                      CALL log085_transacao("BEGIN")
                      IF pol0212_atualiza_ped_itens_1() THEN 
                         CALL log085_transacao("COMMIT")
                         LET p_efetivada.mensagem = 'PROGRAMACAO CANCELADA'
                      ELSE
                         CALL log085_transacao("ROLLBACK")
                      END IF 
                   ELSE
                      LET p_efetivada.mensagem = 'DESCARTADA:PROG EXISTENTE'  #tirar do relatório
                      LET p_gra_efetiv = FALSE
                   END IF            
                END IF               
             ELSE 
                IF pol0212_prazo_maior_60() THEN
                   LET p_efetivada.mensagem = 'ULTIMA VENDA A MAIS DE 60 DIAS'
                ELSE
                   CALL log085_transacao("BEGIN")
                   IF pol0212_grava_ped_itens() THEN
                      CALL log085_transacao("COMMIT")
                      LET p_efetivada.mensagem = 'PROGRAMACAO INCLUIDA'
                   ELSE
                      CALL log085_transacao("ROLLBACK")
                   END IF 
                END IF
             END IF
          ELSE
             LET p_efetivada.mensagem = 'DESCARTADA: PRAZO ANTIGO'  #tirar do relatório
             LET p_gra_efetiv = FALSE
          END IF
       ELSE
          LET p_efetivada.mensagem = 'DESCARTADA PELO USUARIO'
       END IF 
       
       IF p_gra_efetiv THEN
          CALL pol0212_grava_efetivacao()
       ELSE
          CALL pol0212_grava_descartada()
       END IF
       
   END FOR     

END FUNCTION

#------------------------------#
FUNCTION pol0212_item_inativo()#
#------------------------------#

   SELECT cod_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_efetivada.cod_item
      AND ies_situacao <> 'A'
   
   IF STATUS = 0 THEN
      RETURN TRUE
   END IF
   
   RETURN FALSE

END FUNCTION

#--------------------------------#
FUNCTION pol0212_prazo_maior_60()#
#--------------------------------#
   
   DEFINE p_dias INTEGER
   
   IF p_efetivada.prz_entrega > p_ped_itens_ex.prz_entrega THEN
      LET p_dias = p_efetivada.prz_entrega - p_ped_itens_ex.prz_entrega
      IF p_dias > 60 THEN
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION   
   
#----------------------------------#
FUNCTION pol0212_grava_efetivacao()
#----------------------------------#

   INSERT INTO prog_efetivada_547
    VALUES(p_efetivada.*)
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Insert','prog_efetivada_547')
   END IF
   
END FUNCTION

#----------------------------------#
FUNCTION pol0212_grava_descartada()
#----------------------------------#

   INSERT INTO prog_descartada_547
    VALUES(p_efetivada.*)
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Insert','prog_descartada_547')
   END IF
   
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0212_le_list_preco_item()
#---------------------------------------------------------------------#
#  >>  OS 115462 - INICIO  <<  #

   LET p_pre_unit = 0
   IF p_cod_cliente = '1' THEN 
      SELECT pre_unit 
        INTO p_pre_unit
        FROM desc_preco_item 
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item    = p_ped_itens_qfp.cod_item
         AND num_list_preco = 1 
      IF STATUS <> 0 THEN
         LET p_pre_unit = 0
      END IF      
   ELSE
      SELECT pre_unit 
        INTO p_pre_unit
        FROM desc_preco_item 
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item    = p_ped_itens_qfp.cod_item
         AND num_list_preco = 1106 
      IF STATUS <> 0 THEN
         LET p_pre_unit = 0
      END IF      
   END IF          
   
   IF p_pre_unit = 0 THEN
      CALL pol0212_le_preco_item_ped_itens()
      IF p_pre_unit = 0 THEN  
         ERROR "ITEM ",p_ped_itens_qfp.cod_item,"  SEM PRECO NA LISTA 1" 
      END IF
   END IF

END FUNCTION   

#---------------------------------------------------------------------#
 FUNCTION pol0212_le_preco_item_ped_itens()
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
 FUNCTION pol0212_le_ped_itens()
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
   ORDER BY prz_entrega desc

  FOREACH cq_ped_ex INTO p_ped_itens_ex.* 
      EXIT FOREACH
  END FOREACH
  
END FUNCTION
 

#-----------------------------------------#
 FUNCTION pol0212_atualiza_ped_itens_1()
#-----------------------------------------#

  DEFINE p_cod_item_cli  LIKE cliente_item.cod_item_cliente,
         p_alter_tecnica LIKE pedidos_edi_pe6.alter_tecnica

  LET p_qtd_pecas_cancel = p_ped_itens.qtd_pecas_solic
                         - p_ped_itens.qtd_pecas_atend

  IF p_qtd_pecas_cancel IS NULL THEN
     LET p_qtd_pecas_cancel = 0
  END IF  

  UPDATE ped_itens
     SET qtd_pecas_cancel     = p_qtd_pecas_cancel
  WHERE ped_itens.cod_empresa = p_cod_empresa
    AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
    AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
    AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega

  IF STATUS <> 0 THEN 
     LET p_efetivada.mensagem = 'ERRO ', STATUS
     LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' CANCEL PED_ITENS'
     RETURN FALSE 
  END IF
  
  LET p_audit_vdp.cod_empresa = p_cod_empresa
  LET p_audit_vdp.num_pedido = p_ped_itens_qfp.num_pedido
  LET p_audit_vdp.tipo_informacao = 'M' 
  LET p_audit_vdp.tipo_movto = 'I'
  LET p_audit_vdp.texto = 'CANCELAMENTO ENTREGA ',p_ped_itens_qfp.prz_entrega,' QUANTIDADE ',p_qtd_pecas_cancel, ' IDENT. RND ',p_tela.identif_arq,' / ',p_tela.dat_arq 
  LET p_audit_vdp.num_programa = 'POL0212'
  LET p_audit_vdp.data =  TODAY
  LET p_audit_vdp.hora =  TIME 
  LET p_audit_vdp.usuario = p_user
  LET p_audit_vdp.num_transacao = 0  
  
  INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
  
  IF STATUS <> 0 THEN 
     LET p_efetivada.mensagem = 'ERRO ', STATUS
     LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' CANCEL AUDIT_VDP INS'
     RETURN FALSE
  END IF
  
# aqui         
  SELECT cod_item_cliente 
     INTO p_cod_item_cli
  FROM cliente_item
  WHERE cod_empresa = p_cod_empresa
    AND cod_cliente_matriz = p_cod_cliente 
    AND cod_item = p_ped_itens_qfp.cod_item

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
     IF STATUS <> 0 THEN 
        LET p_efetivada.mensagem = 'ERRO ', STATUS
        LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' CANCEL ITEM_ESP UPD'
        RETURN FALSE
     END IF
  ELSE
     INSERT INTO item_esp
        VALUES (p_cod_empresa,
                p_ped_itens_qfp.cod_item,
                1,
                p_des_alter)
     IF STATUS <> 0 THEN 
        LET p_efetivada.mensagem = 'ERRO ', STATUS
        LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' CANCEL ITEM_ESP INS'
        RETURN FALSE
     END IF
  END IF


   IF p_ped_itens.num_sequencia IS NULL  THEN 
        SELECT max(num_sequencia) 
          INTO  p_ped_itens.num_sequencia       
          FROM  ped_itens
         WHERE ped_itens.cod_empresa = p_cod_empresa
           AND ped_itens.num_pedido  = p_ped_itens_qfp.num_pedido
           AND ped_itens.cod_item    = p_ped_itens_qfp.cod_item
           AND ped_itens.prz_entrega = p_ped_itens_qfp.prz_entrega
  END IF

  SELECT *
  FROM ped_itens_texto
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido  = p_ped_itens_qfp.num_pedido
    AND num_sequencia = p_ped_itens.num_sequencia
    
  IF STATUS = 0 THEN
     UPDATE ped_itens_texto SET den_texto_2 = p_des_alter,
                                den_texto_5 = p_release
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_qfp.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
  ELSE    
     IF p_ped_itens.num_sequencia > 0 THEN                  
            INSERT INTO ped_itens_texto
                   VALUES (p_cod_empresa,
                     p_ped_itens_qfp.num_pedido,
                     p_ped_itens.num_sequencia,
                     NULL,
                     p_des_alter,
                     NULL,
                     NULL,
                     p_release)
          IF STATUS <> 0 THEN 
             LET p_efetivada.mensagem = 'ERRO ', STATUS
             LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' CANCEL PED_ITENS_TEXTO INS'
             RETURN FALSE
          END IF
     END IF
  END IF    
                
  RETURN TRUE 
  
END FUNCTION

	
#----------------------------------#
 FUNCTION pol0212_grava_ped_itens()
#----------------------------------#

  DEFINE p_cod_item_cli  LIKE cliente_item.cod_item_cliente,
         p_alter_tecnica LIKE pedidos_edi_pe6.alter_tecnica,
         l_des_1         CHAR(76),
         l_des_2         CHAR(76),
         l_txt_1         CHAR(76),
         l_num_seq       INTEGER
         
  #IF p_ped_itens.pre_unit IS NULL THEN 
     CALL pol0212_le_list_preco_item()
     LET p_ped_itens.pre_unit = p_pre_unit 
  #END IF  

     LET p_ped_itens.cod_empresa = p_cod_empresa                 
     LET p_ped_itens.num_pedido = p_ped_itens_qfp.num_pedido
     LET p_ped_itens.cod_item = p_ped_itens_qfp.cod_item
     LET p_ped_itens.pct_desc_adic = 0                             
     LET p_ped_itens.qtd_pecas_solic = t_ped_itens_qfp[p_ind].qtd_solic_nova
     LET p_ped_itens.qtd_pecas_atend = 0                             
     LET p_ped_itens.qtd_pecas_cancel = 0                             
     LET p_ped_itens.qtd_pecas_reserv = 0                             
     LET p_ped_itens.prz_entrega = t_ped_itens_qfp[p_ind].prz_entrega
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

     INSERT INTO ped_itens VALUES (p_ped_itens.*)

        IF STATUS <> 0 THEN 
           LET p_efetivada.mensagem = 'ERRO ', STATUS
           LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT PED_ITENS'
           RETURN FALSE 
        END IF
   
     SELECT num_pedido
       FROM ped_itens_ethos
      WHERE cod_empresa = p_ped_itens.cod_empresa
        AND num_pedido = p_ped_itens.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
    
     IF STATUS <> 0 THEN
        INSERT INTO ped_itens_ethos
         VALUES(p_ped_itens.cod_empresa,
                p_ped_itens.num_pedido,
                p_ped_itens.num_sequencia,
                p_ship_date)

        IF STATUS <> 0 THEN 
           LET p_efetivada.mensagem = 'ERRO ', STATUS
           LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT PED_ITENS_ETHOS'
           RETURN FALSE 
        END IF
     END IF
     
   
        LET p_audit_vdp.cod_empresa = p_cod_empresa
        LET p_audit_vdp.num_pedido = p_ped_itens_qfp.num_pedido
        LET p_audit_vdp.tipo_informacao = 'M' 
        LET p_audit_vdp.tipo_movto = 'I'
        LET p_audit_vdp.texto = 'INCLUSAO SEQUENCIA ',p_ped_itens.num_sequencia,' ENTREGA ',p_ped_itens.prz_entrega,' QUANTIDADE ',p_ped_itens.qtd_pecas_solic, ' IDENT. RND ',p_tela.identif_arq,' / ',p_tela.dat_arq 
        LET p_audit_vdp.num_programa = 'POL0212'
        LET p_audit_vdp.data =  TODAY
        LET p_audit_vdp.hora =  TIME 
        LET p_audit_vdp.usuario = p_user
        LET p_audit_vdp.num_transacao = 0  
        INSERT INTO audit_vdp VALUES (p_audit_vdp.*)

        IF STATUS <> 0 THEN 
           LET p_efetivada.mensagem = 'ERRO ', STATUS
           LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT AUDIT_VDP'
           RETURN FALSE
        END IF

   
     #  aqui         
        SELECT cod_item_cliente 
           INTO p_cod_item_cli
        FROM cliente_item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_ped_itens_qfp.cod_item
          AND cod_cliente_matriz = p_cod_cliente

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
        
        IF STATUS = 0 THEN 
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
              IF p_e_kanban = 'S' AND p_cod_cliente = '1' THEN 
                 LET l_txt_1 = 'KANBAN ', p_ped_itens_texto.den_texto_1
              ELSE
                 LET p_count = 0 
                 SELECT COUNT(*) 
                   INTO p_count
                   FROM ped_itens_texto
                  WHERE cod_empresa = p_cod_empresa
                    AND num_pedido  = p_ped_itens_qfp.num_pedido
                    AND num_sequencia = 0
                    AND den_texto_1 like '%JIT%'	
                 IF p_count > 0 THEN  
                    LET l_txt_1 = 'JIT ', p_ped_itens_texto.den_texto_1  
                 ELSE
                    LET l_txt_1 = ''
                 END IF    
              END IF   
              SELECT *
                INTO p_ped_itens_texto.*
              FROM ped_itens_texto
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido  = p_ped_itens_qfp.num_pedido
                AND num_sequencia = l_num_seq	
              IF STATUS = 0 THEN
                 IF l_num_seq = p_ped_itens.num_sequencia THEN 
                    UPDATE ped_itens_texto SET den_texto_1 = l_txt_1,
                                               den_texto_2 = p_des_alter,
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
                       
                       UPDATE ped_itens_texto SET den_texto_1 = l_txt_1,
                                                  den_texto_3 = l_des_1,
                                                  den_texto_4 = l_des_2
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens_qfp.num_pedido
                          AND num_sequencia = l_num_seq
                    ELSE
                       EXIT WHILE 
                    END IF 
                 END IF       
              ELSE
                 IF l_num_seq > 0 THEN
                    INSERT INTO ped_itens_texto
                       VALUES (p_cod_empresa,
                            p_ped_itens_qfp.num_pedido,
                            l_num_seq,
                            l_txt_1,
                            p_des_alter,    
                            l_des_1,
                            l_des_2,
                            p_release)

                    IF STATUS <> 0 THEN 
                       LET p_efetivada.mensagem = 'ERRO ', STATUS
                       LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT PED_ITENS_TEXTO'
                       RETURN FALSE
                    END IF
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
              IF STATUS <> 0 THEN 
                 LET p_efetivada.mensagem = 'ERRO ', STATUS
                 LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' ATUALIZ ITEM_ESP'
                 RETURN FALSE
              END IF
           ELSE
              INSERT INTO item_esp
              VALUES (p_cod_empresa,
                      p_ped_itens_qfp.cod_item,
                      1,
                      p_des_alter)
              IF STATUS <> 0 THEN 
                 LET p_efetivada.mensagem = 'ERRO ', STATUS
                 LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT ITEM_ESP'
                 RETURN FALSE
              END IF
           END IF
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
            IF p_e_kanban = 'S' AND p_cod_cliente = '1' THEN 
               LET l_txt_1 = 'KANBAN ', p_ped_itens_texto.den_texto_1
            ELSE
               LET p_count = 0 
               SELECT COUNT(*) 
                 INTO p_count
                 FROM ped_itens_texto
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_ped_itens_qfp.num_pedido
                  AND num_sequencia = 0
                  AND den_texto_1 like '%JIT%'	
               IF p_count > 0 THEN  
                  LET l_txt_1 = 'JIT ', p_ped_itens_texto.den_texto_1  
               ELSE
                  LET l_txt_1 = ''
               END IF    
            END IF   
            SELECT *
              INTO p_ped_itens_texto.*
              FROM ped_itens_texto
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido  = p_ped_itens_qfp.num_pedido
                AND num_sequencia = l_num_seq	
              IF SQLCA.SQLCODE = 0 THEN
                 IF l_num_seq = p_ped_itens.num_sequencia THEN 
                    UPDATE ped_itens_texto SET den_texto_1 = l_txt_1,
                                               den_texto_2 = p_des_alter,
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
                       UPDATE ped_itens_texto SET den_texto_1 = l_txt_1,
                                                  den_texto_3 = l_des_1,
                                                  den_texto_4 = l_des_2
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens_qfp.num_pedido
                          AND num_sequencia = l_num_seq
                    ELSE
                       EXIT WHILE 
                    END IF 
                 END IF       
              ELSE
                 IF l_num_seq > 0 THEN
                    INSERT INTO ped_itens_texto
                       VALUES (p_cod_empresa,
                            p_ped_itens_qfp.num_pedido,
                            l_num_seq,
                            l_txt_1,
                            p_des_alter,    
                            l_des_1,
                            l_des_2,
                            p_release)
                    IF STATUS <> 0 THEN 
                       LET p_efetivada.mensagem = 'ERRO ', STATUS
                       LET p_efetivada.mensagem = p_efetivada.mensagem CLIPPED, ' INSERT PED_ITENS_TEXTO'
                       RETURN FALSE
                    END IF
                 END IF
              END IF   
              LET l_num_seq = l_num_seq - 1
              IF l_num_seq = 0 THEN
                 EXIT WHILE 
              END IF 
              
           END WHILE 
        END IF    

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0212_deleta_ped_itens_qfp()
#---------------------------------------------------------------------#
  CALL log085_transacao("BEGIN")

  DELETE FROM ped_itens_qfp
  WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
    AND ped_itens_qfp.num_pedido  = p_ped_itens.num_pedido
    AND ped_itens_qfp.cod_item    = p_ped_itens.cod_item
  IF SQLCA.sqlcode <> 0 THEN 
     CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP")
     CALL log085_transacao("ROLLBACK")
  ELSE
     DELETE FROM ped_itens_qfp_pe5
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens.num_pedido
        AND cod_item    = p_ped_itens.cod_item
     IF SQLCA.sqlcode <> 0 THEN 
        CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE5")
        CALL log085_transacao("ROLLBACK")
     ELSE
        DELETE from pedidos_edi_pe1 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_itens.num_pedido
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE1")
           CALL log085_transacao("ROLLBACK")
        ELSE
           DELETE from pedidos_edi_pe2 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_ped_itens.num_pedido
           IF SQLCA.sqlcode <> 0 THEN 
              CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE2")
              CALL log085_transacao("ROLLBACK")
           ELSE
              DELETE from pedidos_edi_pe3 
               WHERE cod_empresa = p_cod_empresa
                 AND num_pedido  = p_ped_itens.num_pedido
              IF SQLCA.sqlcode <> 0 THEN 
                 CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE3")
                 CALL log085_transacao("ROLLBACK")
              ELSE
                 DELETE from pedidos_edi_pe4 
                  WHERE cod_empresa = p_cod_empresa
                    AND num_pedido  = p_ped_itens.num_pedido
                 IF SQLCA.sqlcode <> 0 THEN 
                    CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE4")
                    CALL log085_transacao("ROLLBACK")
                 ELSE
                    DELETE from pedidos_edi_pe5 
                     WHERE cod_empresa = p_cod_empresa
                       AND num_pedido  = p_ped_itens.num_pedido
                    IF SQLCA.sqlcode <> 0 THEN 
                       CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE5")
                       CALL log085_transacao("ROLLBACK")
                    ELSE
                       DELETE from pedidos_edi_pe6 
                        WHERE cod_empresa = p_cod_empresa
                          AND num_pedido  = p_ped_itens.num_pedido
                       IF SQLCA.sqlcode <> 0 THEN 
                          CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP_PE6")
                          CALL log085_transacao("ROLLBACK")
                       ELSE
                          DELETE from pedidos_edi_te1 
                           WHERE cod_empresa = p_cod_empresa
                             AND num_pedido  = p_ped_itens.num_pedido
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
 FUNCTION pol0212_deleta_pedidos_qfp()
#---------------------------------------------------------------------#
  CALL log085_transacao("BEGIN")

  DELETE FROM pedidos_qfp
  WHERE pedidos_qfp.cod_empresa = p_cod_empresa
    AND pedidos_qfp.num_pedido  = p_ped_itens.num_pedido
 
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
 FUNCTION pol0212_exclusao_ped_itens_qfp()
#---------------------------------------------------------------------#

 CALL log085_transacao("BEGIN")

IF log004_confirm(22,45) THEN 
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
ELSE 
   CALL log085_transacao("ROLLBACK")
END IF
MESSAGE "                            "
ERROR " Execute novamente a Consulta  "

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0212_paginacao(p_funcao)
#---------------------------------------------------------------------#
  
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons THEN
     LET p_ped_itens_qfpr.* = p_ped_itens_qfp.*
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

       IF p_ped_itens_qfp.num_pedido = p_ped_itens_qfpr.num_pedido AND 
          p_ped_itens_qfp.cod_item   = p_ped_itens_qfpr.cod_item THEN
       ELSE 
          CALL pol0212_pega_dados()
          EXIT WHILE
       END IF
       
     END WHILE
  ELSE   
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
  
END FUNCTION


#------------------------------#
 FUNCTION pol0212_exibe_dados()
#------------------------------#
  DEFINE p_count SMALLINT
         
         
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa

   SELECT tipo_item
     INTO p_tipo_item
     FROM item_kanban_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      AND cod_item_cliente = p_cod_item_cliente
  
  IF STATUS <> 0 THEN
     LET p_tipo_item = 'COMUM'
     LET p_e_kanban = 'N'
  ELSE
     LET p_e_kanban = 'S'
  END IF

  
  DISPLAY p_tipo_item  TO kanban
  
  DISPLAY p_cod_cliente TO cod_cliente
  DISPLAY p_cod_item_cliente TO p_cod_item_cliente
  DISPLAY p_tela.dat_prog    TO dat_prog                
  DISPLAY p_tela.ies_data    TO ies_data                
  DISPLAY p_tela.ies_firme   TO ies_firme           
  DISPLAY p_tela.ies_requis  TO ies_requis          
  DISPLAY p_tela.ies_planej  TO ies_planej 
  DISPLAY p_tela.identif_arq TO identif_arq
  DISPLAY p_tela.dat_arq     TO dat_arq    
  DISPLAY p_tela.qtd_acum    TO qtd_acum     
  DISPLAY p_tela.qtd_ped     TO qtd_ped
  CALL pol0212_verifica_cliente()
  DISPLAY BY NAME p_ped_itens_qfp.num_pedido,
                  p_ped_itens_qfp.cod_item,
                  p_num_nff_ult,
                  p_qtd_estoque,
                  p_qtd_embarcado


END FUNCTION

#-------------------------------#
 FUNCTION pol0212_marca_atualiz()
#------------------------------#

   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY t_ped_itens_qfp
      WITHOUT DEFAULTS FROM s_ped_itens_qfp.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
    
      AFTER FIELD ies_atualiza      
         IF t_ped_itens_qfp[p_index].ies_atualiza <> 'S' THEN
            LET t_ped_itens_qfp[p_index+1].ies_atualiza = 'S'
            DISPLAY 'S' to s_ped_itens_qfp[s_index].ies_atualiza
         END IF
         
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF t_ped_itens_qfp[p_index+1].prz_entrega IS NULL THEN
               NEXT FIELD ies_atualiza
            END IF
         END IF
         
         
   END INPUT
   
END FUNCTION


#---------------------------------#
FUNCTION pol0212_verifica_cliente()
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
 FUNCTION pol0212_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
FUNCTION pol0212_listagem()
#--------------------------#
   
   DEFINE p_query, where_clause CHAR(600),
          l_count  INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol02121") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol02121 AT 07,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause 
     ON prog_efetivada_547.num_pedido,
        prog_efetivada_547.cod_item,
        prog_efetivada_547.cod_usuario
 
   IF int_flag THEN
      ERROR " Operação Cancelada"
      RETURN
    END IF

   LET p_query  = 
       "SELECT * ",
       "  FROM prog_efetivada_547 ",
       " WHERE ", where_clause CLIPPED,
       "   AND cod_empresa = '",p_cod_empresa,"' "
   
   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   
   INPUT p_dat_ini, p_dat_fim
      WITHOUT DEFAULTS FROM dat_ini, dat_fim
      
      AFTER FIELD dat_fim   
         IF p_dat_fim IS NOT NULL THEN
            IF p_dat_ini IS NOT NULL THEN
               IF p_dat_ini > p_dat_fim THEN
                  ERROR "Data Inicial nao pode ser maior que data Final"
                  NEXT FIELD dat_ini
               END IF 
               IF p_dat_fim - p_dat_ini > 720 THEN 
                  ERROR "Periodo nao pode ser maior que 720 Dias"
                  NEXT FIELD dat_ini
               END IF 
            END IF
         END IF

   END INPUT

   CURRENT WINDOW IS w_pol0212
   
   IF INT_FLAG THEN
      ERROR 'Operação cancelada.'
      RETURN
   END IF

   IF p_dat_ini IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND dat_proces >= '",p_dat_ini,"' "
   END IF

   IF p_dat_fim IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND dat_proces <= '",p_dat_fim,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY cod_usuario, num_pedido, prz_entrega "

   IF NOT pol0212_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0212_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   LET p_imprimiu    = FALSE
   LET p_last_row    = FALSE
   LET p_hoje = TODAY                                                    
   
   PREPARE var_query FROM p_query   
   DECLARE cq_relat CURSOR FOR var_query

   FOREACH cq_relat INTO p_relat.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_relat')
         ERROR 'Operação abortada.'
         EXIT FOREACH
      END IF

      SELECT den_item_reduz
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_relat.cod_empresa
         AND cod_item = p_relat.cod_item
      
      IF STATUS <> 0 THEN
         LET p_den_item = 'NAO CADASTRADO'
      END IF
      
      SELECT COUNT(*)
        INTO l_count 
        FROM item_kanban_547 
       WHERE cod_empresa = p_relat.cod_empresa
         AND cod_item    = p_relat.cod_item  
         AND dat_inicio  <= p_hoje
         AND dat_termino >= p_hoje

      IF l_count > 0 THEN 
         LET p_den_tipo = "KANBAN"
      ELSE
         LET p_den_tipo = ""
      END IF
      
      OUTPUT TO REPORT pol0212_relat() 
      
      LET p_imprimiu = TRUE
      
   END FOREACH
   
   CALL pol0212_finalaliza_imp()
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0212_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol0212_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0212.tmp'
         START REPORT pol0212_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol0212_relat TO p_nom_arquivo
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol0212_finalaliza_imp()
#--------------------------------#

   FINISH REPORT pol0212_relat  
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION
   
#--------------------------------#
 FUNCTION pol0212_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------#
 REPORT pol0212_relat()#
#----------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 132, "PAG:", PAGENO USING "##&"
               
         PRINT COLUMN 001, "POL0212",
               COLUMN 028, "EFETIVACAO DE PROGRAMACAO DE ENTREGA -",
               COLUMN 067, "PERIODO: ", p_dat_ini USING 'dd/mm/yyyy', ' - ', p_dat_fim USING 'dd/mm/yyyy',
               COLUMN 121, TODAY USING "dd/mm/yyyy", " ", TIME
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'EFETIVADO  PEDIDO SEQ ITEM                DESCRICAO      ENTREGA    QUD SOLIC QTD NOVA   SITUACAO    USUARIO  MENSAGEM                  TIPO'
         PRINT COLUMN 001, '---------- ------ --- --------------- ------------------ ---------- --------- --------- ----------- -------- ------------------------- ------'
          
      PAGE HEADER  
         
         PRINT COLUMN 125, "PAG:", PAGENO USING "##&"
         PRINT COLUMN 001, 'EFETIVADO  PEDIDO SEQ ITEM                DESCRICAO      ENTREGA    QUD SOLIC QTD NOVA   SITUACAO    USUARIO  MENSAGEM                  TIPO'
         PRINT COLUMN 001, '---------- ------ --- --------------- ------------------ ---------- --------- --------- ----------- -------- ------------------------- ------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.dat_proces USING 'dd/mm/yyyy',
               COLUMN 012, p_relat.num_pedido USING '#####&',
               COLUMN 019, p_relat.num_sequencia USING '##&',
               COLUMN 023, p_relat.cod_item,
               COLUMN 039, p_den_item,
               COLUMN 058, p_relat.prz_entrega USING 'dd/mm/yyyy',
               COLUMN 069, p_relat.qtd_solic USING '#####&.&&',
               COLUMN 079, p_relat.qtd_nova USING '#####&.&&',
               COLUMN 089, p_relat.sit_programa,
               COLUMN 101, p_relat.cod_usuario,
               COLUMN 110, p_relat.mensagem,
               COLUMN 136, p_den_tipo

      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT



#--------------------------------#
FUNCTION pol0212_processa_firme()#
#--------------------------------#

   DEFINE where_clause, sql_stmt CHAR(650),
          l_count                INTEGER,
          p_item_ant             CHAR(15),
          p_pedido_ant           INTEGER
          
   CLEAR FORM
   CURRENT WINDOW IS w_pol0212
   DISPLAY p_cod_empresa TO cod_empresa
  
   LET INT_FLAG = FALSE

   INITIALIZE p_ped_itens_qfp, p_tela,
              t_ped_itens_qfp  TO NULL

   LET p_item_ant = '0'
   LET p_pedido_ant = 0
   
   MESSAGE "Aguarde... Processando!"

   CALL pol0212_carrega_kanban()

   LET p_tela.dat_prog = "31/12/2999"
   LET p_tela.ies_data = 'A' 
   LET p_tela.ies_firme = 'S'
   LET p_tela.ies_requis = 'N' 
   LET p_tela.ies_planej = 'N'
    
   DECLARE cq_firme CURSOR WITH HOLD FOR
    SELECT DISTINCT
           ped_itens_qfp.num_pedido,
           ped_itens_qfp.cod_item, 
           pedidos_qfp.num_nff_ult,
           pedidos.cod_cliente,
           pedidos_qfp.cod_item_cliente
      FROM ped_itens_qfp, pedidos, ped_itens_qfp_pe5, OUTER pedidos_qfp
     WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
       AND pedidos_qfp.cod_empresa   = ped_itens_qfp.cod_empresa
       AND pedidos_qfp.num_pedido    = ped_itens_qfp.num_pedido
       AND pedidos.cod_empresa       = ped_itens_qfp.cod_empresa
       AND pedidos.num_pedido        = ped_itens_qfp.num_pedido   
       AND ped_itens_qfp_pe5.cod_empresa = ped_itens_qfp.cod_empresa
       AND ped_itens_qfp_pe5.num_pedido = ped_itens_qfp.num_pedido 
       AND ped_itens_qfp_pe5.num_sequencia = ped_itens_qfp.num_sequencia
       AND ped_itens_qfp_pe5.cod_item      = ped_itens_qfp.cod_item     
       AND ped_itens_qfp_pe5.ies_programacao = '1'       

   FOREACH cq_firme INTO
      p_ped_itens_qfp.num_pedido,
      p_ped_itens_qfp.cod_item,
      p_num_nff_ult,
      p_cod_cliente,
      p_cod_item_cliente
  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_firme')
         EXIT FOREACH
      END IF

      #IF p_cod_cliente = '849' THEN #Felipe pediu para despresar esse cliente
      #   CONTINUE FOREACH #Felipe pediu para reconsiderar
      #END IF
      
      IF p_ped_itens_qfp.num_pedido = p_pedido_ant AND 
         p_ped_itens_qfp.cod_item   = p_item_ant   THEN
         CONTINUE FOREACH
      END IF
      
      LET p_pedido_ant = p_ped_itens_qfp.num_pedido
      LET p_item_ant = p_ped_itens_qfp.cod_item
      
      CALL pol0212_pega_dados()
      
      INITIALIZE t_ped_itens_qfp TO NULL
      
      CALL pol0212_carrega_itens()  
      
      LET p_comm = 'N'
      
      CALL pol0212_prepara_ped_itens()
      
      IF p_comm = 'S' THEN
         CALL pol0212_deleta_ped_itens_qfp()
         CALL pol0212_deleta_pedidos_qfp()
      END IF
      
      CALL pol0212_ins_prog()
      
   END FOREACH
   
   MESSAGE ""

   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol0212_ins_prog()
#--------------------------#
 
   FOR p_count = 1 TO 500

      IF t_ped_itens_qfp[p_count].ies_atualiza = 'S' THEN    
         INSERT INTO prog_tmp VALUES (t_ped_itens_qfp[p_count].*)
      END IF

   END FOR
   
END FUNCTION


#--------------------------------#
 FUNCTION pol0212_carrega_itens()
#--------------------------------#
  
   DEFINE p_achou SMALLINT
  
   LET p_qtd_firme = 0 
   CALL set_count(0)
   LET p_ind = 1
   INITIALIZE t_ped_itens_qfp, t_ped_itens_seq TO NULL
   
   LET p_cod_item = p_ped_itens_qfp.cod_item

   DECLARE cq_ped_itens_qfp CURSOR WITH HOLD FOR
    SELECT ped_itens_qfp.* 
      FROM ped_itens_qfp, ped_itens_qfp_pe5
     WHERE ped_itens_qfp.cod_empresa = p_cod_empresa
       AND ped_itens_qfp.num_pedido  = p_ped_itens_qfp.num_pedido
       AND ped_itens_qfp.cod_item    = p_ped_itens_qfp.cod_item
       AND ped_itens_qfp_pe5.cod_empresa = ped_itens_qfp.cod_empresa
       AND ped_itens_qfp_pe5.num_pedido = ped_itens_qfp.num_pedido 
       AND ped_itens_qfp_pe5.num_sequencia = ped_itens_qfp.num_sequencia
       AND ped_itens_qfp_pe5.cod_item      = ped_itens_qfp.cod_item  
       AND ped_itens_qfp_pe5.ies_programacao = '1'     
     ORDER BY prz_entrega

   FOREACH cq_ped_itens_qfp INTO p_ped_itens_qfp.*  

      LET p_achou = FALSE

      DECLARE cq_pi cursor FOR
       SELECT * 
         FROM ped_itens_qfp_pe5
        WHERE cod_empresa = p_ped_itens_qfp.cod_empresa
          AND num_pedido = p_ped_itens_qfp.num_pedido 
          AND num_sequencia = p_ped_itens_qfp.num_sequencia
          AND cod_item      = p_ped_itens_qfp.cod_item       

      FOREACH cq_pi INTO p_ped_itens_qfp_pe5.*
   
         IF sqlca.sqlcode <> 0 THEN 
            EXIT FOREACH
         END IF
       
         LET p_achou = TRUE
       
         EXIT FOREACH
    
      END FOREACH
    
      IF NOT p_achou THEN
         CONTINUE FOREACH
      END IF
    
      IF p_tela.ies_data = "A" THEN
         IF p_ped_itens_qfp_pe5.dat_abertura > p_tela.dat_prog THEN
            CONTINUE FOREACH
         END IF
      ELSE 
         IF p_ped_itens_qfp.prz_entrega > p_tela.dat_prog THEN
            CONTINUE FOREACH
         END IF
      END IF

      IF p_ped_itens_qfp_pe5.ies_programacao = "8" THEN
         CONTINUE FOREACH      
      END IF
   
      LET p_ok ="N"     
      IF p_tela.ies_firme  = "S"  AND 
         p_tela.ies_requis = "S"  AND 
         p_tela.ies_planej = "S"  THEN 
         LET p_ok ="S"     
      ELSE 
         IF p_ped_itens_qfp_pe5.ies_programacao = "1" AND 
            p_tela.ies_firme = "S" THEN
            LET p_ok ="S"     
         ELSE 
            IF p_ped_itens_qfp_pe5.ies_programacao = "3" AND 
               p_tela.ies_requis= "S" THEN
               LET p_ok ="S"     
            ELSE 
               IF p_ped_itens_qfp_pe5.ies_programacao = "4" AND 
                  p_tela.ies_planej= "S" THEN
                  LET p_ok ="S"     
               END IF
            END IF
         END IF
      END IF

      IF p_ok = "N" THEN
         CONTINUE FOREACH
      END IF 

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

      IF p_tela.ies_data = "A" THEN
         LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp_pe5.dat_abertura
      ELSE
         LET t_ped_itens_qfp[p_ind].prz_entrega  = p_ped_itens_qfp.prz_entrega
      END IF
      
      LET p_dat_entrega = t_ped_itens_qfp[p_ind].prz_entrega
      
      CALL pol0212_ck_data()

      LET t_ped_itens_qfp[p_ind].ies_atualiza    = 'S'
      LET t_ped_itens_qfp[p_ind].qtd_solic       = p_ped_itens_qfp.qtd_solic
      LET t_ped_itens_qfp[p_ind].qtd_atendida    = p_ped_itens_qfp.qtd_atend
      LET t_ped_itens_qfp[p_ind].qtd_solic_nova  = p_ped_itens_qfp.qtd_solic_nova
      LET p_ped_itens_qfp.qtd_solic_aceita       = p_ped_itens_qfp.qtd_solic_nova

      LET t_ped_itens_qfp[p_ind].qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita
      
      IF p_ped_itens_qfp.qtd_solic_aceita = 0 then
         LET p_qtd_variacao  = p_ped_itens_qfp.qtd_solic - p_ped_itens_qfp.qtd_atend
      ELSE
         LET p_qtd_variacao  = p_ped_itens_qfp.qtd_solic_nova - p_ped_itens_qfp.qtd_solic 
      END IF

      LET t_ped_itens_qfp[p_ind].qtd_variacao   = p_qtd_variacao
      LET p_qtd_firme = p_qtd_firme + p_qtd_variacao
      LET t_ped_itens_seq[p_ind].num_sequencia = p_ped_itens_qfp.num_sequencia
      LET t_ped_itens_seq[p_ind].ship_date = p_ped_itens_qfp.prz_entrega
      CALL pol0212_acao()
      
      LET p_ind = p_ind + 1
 
   END FOREACH


END FUNCTION



#-----FIM DO PROGRAMA BI------#

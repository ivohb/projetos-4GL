#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: POL0360                                               #
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
         p_num_pedido           LIKE ped_itens_qfp.num_pedido,
         p_cod_item             char(15),
         p_saldo                DECIMAL(10,3),
         p_des_alter            CHAR(40),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT,
         l_count                SMALLINT,
         p_msg                  CHAR(500),
         p_ind                  INTEGER,
         p_index                INTEGER,
         p_achou                SMALLINT

  DEFINE p_num_seq              INTEGER,
         p_prz_entrega          DATE,
         p_sit_prog             CHAR(10),
         p_qtd_solic_nova       DECIMAL(10,3),
         p_qtd_solic_aceita     DECIMAL(10,3),
         p_qtd_enviada          DECIMAL(10,3),
         p_qtd_itens            INTEGER
         
  DEFINE pr_compl               ARRAY[200] OF RECORD
         sequencia              INTEGER,
         qtd_sub                DECIMAL(10,3)
  END RECORD       
  
  DEFINE t_ped_itens_qfp_547_vv  ARRAY[500] OF RECORD
         prz_entrega      LIKE ped_itens_qfp.prz_entrega,
         qtd_solic        LIKE ped_itens_qfp.qtd_solic,
         qtd_solic_nova   LIKE ped_itens_qfp.qtd_solic_nova,
         qtd_solic_aceita LIKE ped_itens_qfp.qtd_solic_aceita,
         qtd_variacao     DECIMAL(07,0),
         sit_programa     CHAR(09),
         qtd_nfs          DECIMAL(07,0),
         atualisar        CHAR(01)    
  END RECORD
 
         

  DEFINE p_tela   RECORD
                   ies_data    CHAR(1),
                   ies_firme   CHAR(1),
                   ies_requis  CHAR(1),
                   ies_planej  CHAR(1),
                   dat_prog    DATE    
                 END RECORD

  DEFINE p_ped_itens_qfp_547_vv     RECORD LIKE ped_itens_qfp_547_vv.*
  DEFINE p_ped_itens_qfp_pe5_547_vv RECORD LIKE ped_itens_qfp_pe5_547_vv.*
  DEFINE p_ped_it_qfp_pe5_cl_547_vv RECORD LIKE ped_it_qfp_pe5_cl_547_vv.*
  DEFINE p_ped_itens_qfpr    RECORD LIKE ped_itens_qfp_547_vv.*
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
         p_prog_existe        CHAR(001),
         p_help                 CHAR(080),
         p_count                INTEGER,
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
  LET p_versao = "POL0360-10.02.30" 
  WHENEVER ANY ERROR CONTINUE
  CALL log0180_conecta_usuario()       
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
    CALL pol0360_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION pol0360_controle()
#---------------------------------------------------------------------#
  
  INITIALIZE p_ped_itens_qfp_547_vv.*, p_ped_itens_qfpr.*, p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("POL0360") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0360 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

{  >>  OS 115462 - INICIO  <<  }
   SELECT * INTO mr_par_vdp.* FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      ERROR " Parametros do Sistema nao cadastrados (VDP1400) "
   END IF

   LET m_qtd_decimais_par = mr_par_vdp.par_vdp_txt[43,43]
{  >>  OS 115462 - FINAL  <<  }
  
  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Programacao do cliente"
      HELP 0004
      MESSAGE ""
      LET p_ies_cons = FALSE
      CALL pol0360_consulta_ped_itens_qfp()
      IF p_ies_cons then
         ERROR 'Consulta efetuada com sucesso!'
      ELSE
         ERROR 'Operação cancelada!'
      END IF
    COMMAND KEY ("N") "coNfirmar"    "Confirma Programacao do cliente "
      HELP 2043
      MESSAGE ""
      IF p_ies_cons THEN
         IF pol0360_processa() then
            ERROR 'Operação efetuada com sucesso!'
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      ELSE
         ERROR 'Execute a consulta previamente!'
         NEXT OPTION "Consultar"
      END IF
    COMMAND "Seguinte"   "Exibe Programacao seguinte"
      HELP 0005
      MESSAGE ""
      CALL pol0360_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe Programacao anterior "
      HELP 0006
      MESSAGE ""
      CALL pol0360_paginacao("ANTERIOR")
    COMMAND "Excluir"  "Exclui Programacao do cliente"
      HELP 0003
      MESSAGE ""
      IF   p_ped_itens_qfp_547_vv.num_pedido IS NOT NULL
      THEN IF   log005_seguranca(p_user,"VDP","POL0360","EX")
           THEN CALL pol0360_exclusao_ped_itens_qfp()
           END IF
      ELSE 
         MESSAGE "Consulte Previamente para fazer a Exclusao !!!" 
            ATTRIBUTE (REVERSE)
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0360_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0360
END FUNCTION


#---------------------------#
FUNCTION pol0360_cria_temp()
#---------------------------#

   DROP TABLE prog_temp_547
   
   CREATE TEMP TABLE prog_temp_547(
		num_sequencia    INTEGER,
		prz_entrega      DATE,
		qtd_solic        DECIMAL(10,3),
		qtd_solic_nova   DECIMAL(10,3),
		qtd_solic_aceita DECIMAL(10,3),
		qtd_variacao     DECIMAL(10,3),
		sit_programa     CHAR(10),
		num_seq_ped      INTEGER,
		qtd_nfs          DECIMAL(07,0)
	)

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","prog_temp_547:criando")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION


#---------------------------------------------------------------------#
 FUNCTION pol0360_consulta_ped_itens_qfp()
#---------------------------------------------------------------------#
  DEFINE where_clause, sql_stmt CHAR(750)

  IF NOT pol0360_cria_temp() THEN
     RETURN FALSE
  END IF

  LET INT_FLAG = FALSE
  CLEAR FORM
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol0360
  DISPLAY p_cod_empresa TO cod_empresa

  LET p_tela.dat_prog = "31/12/2999"
  LET p_ped_itens_qfpr.* = p_ped_itens_qfp_547_vv.*
  
  INITIALIZE p_ped_itens_qfp_547_vv.* TO NULL

  CONSTRUCT BY NAME where_clause ON ped_itens_qfp_547_vv.num_pedido,
                                    ped_itens_qfp_547_vv.cod_item,
                                    pedidos.cod_cliente

  IF INT_FLAG THEN
     CLEAR FORM
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
        LET p_tela.dat_prog = "31/12/2999"         
     END IF   

  END INPUT
                                                                 
  IF INT_FLAG THEN
     CLEAR FORM
     RETURN
  END IF

  LET sql_stmt = "SELECT UNIQUE ped_itens_qfp_547_vv.num_pedido, ",
                 "ped_itens_qfp_547_vv.cod_item, pedidos_qfp_547_vv.num_nff_ult, ",
                 "pedidos.cod_cliente,pedidos_qfp_547_vv.cod_item_cliente ",
                 "FROM ped_itens_qfp_547_vv, pedidos, OUTER pedidos_qfp_547_vv ",
                 "WHERE ped_itens_qfp_547_vv.cod_empresa = '",p_cod_empresa,"' ",
                 "AND ", where_clause CLIPPED, " ",
                 "AND pedidos_qfp_547_vv.cod_empresa = ped_itens_qfp_547_vv.cod_empresa ",
                 "AND pedidos_qfp_547_vv.num_pedido  = ped_itens_qfp_547_vv.num_pedido ",
                 "AND pedidos.cod_empresa     = ped_itens_qfp_547_vv.cod_empresa ",
                 "AND pedidos.num_pedido      = ped_itens_qfp_547_vv.num_pedido  "

  PREPARE var_query FROM sql_stmt

  DECLARE cq_ped_itens_qfp_547_vv SCROLL CURSOR WITH HOLD FOR var_query
  OPEN  cq_ped_itens_qfp_547_vv
  FETCH cq_ped_itens_qfp_547_vv INTO
        p_ped_itens_qfp_547_vv.num_pedido,
        p_ped_itens_qfp_547_vv.cod_item,
        p_num_nff_ult,
        p_cod_cliente,
        p_cod_item_cliente
                              
  IF STATUS <> 0 THEN
     MESSAGE "Argumentos de Pesquisa nao Encontrados !!!" ATTRIBUTE(REVERSE)
     LET p_ies_cons = FALSE
     RETURN
  END IF
  
  IF p_num_nff_ult IS NULL THEN 
     LET p_num_nff_ult = 0
  END IF
 
  IF pol0360_verifica_pedido() THEN
     LET p_qtd_embarcado = 0
     LET p_saldo         = 0
  END IF
  
  IF pol0360_verifica_estoque() THEN
  ELSE
     LET p_qtd_estoque = 0
  END IF

  SELECT cod_item_cliente 
    INTO p_cod_item_cliente 
    FROM cliente_item
   WHERE cod_empresa = p_cod_empresa
     AND cod_cliente_matriz = p_cod_cliente 
     AND cod_item = p_ped_itens_qfp_547_vv.cod_item

   if pol0360_monta_dados_consulta() then
      CALL pol0360_exibe_dados()
      LET p_ies_cons = TRUE
   ELSE
      let p_ies_cons = TRUE
      CALL pol0360_paginacao("SEGUINTE")
      IF NOT p_achou THEN         
         CALL log0030_mensagem('Não há programações a serem exibidas.','info')    
         LET p_ies_cons = FALSE
      END IF  
   end if

   LET int_flag = 0

END FUNCTION

#----------------------------------#
 FUNCTION pol0360_verifica_pedido()
#----------------------------------#
 
  INITIALIZE p_cod_cliente, p_ies_preco TO NULL
 
  LET p_cnd_pgto_list    = 0
  LET p_cod_cnd_pgto     = 0
  LET p_num_list_preco   = 0
  LET p_num_versao_lista = 0

  SELECT cod_cnd_pgto
    INTO p_cnd_pgto_list
    FROM ped_cond_pgto_list
   WHERE ped_cond_pgto_list.cod_empresa = p_cod_empresa
     AND ped_cond_pgto_list.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

  IF STATUS <> 0 THEN 
     LET p_cnd_pgto_list = 0
  END IF

  SELECT cod_cliente,   cod_cnd_pgto,   ies_preco,   num_list_preco,
         num_versao_lista,   cod_tip_carteira
    INTO p_cod_cliente, p_cod_cnd_pgto, p_ies_preco, p_num_list_preco,
         p_num_versao_lista, m_cod_tip_carteira
    FROM pedidos
   WHERE pedidos.cod_empresa = p_cod_empresa
     AND pedidos.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

  IF STATUS = 0  THEN 
     IF p_cnd_pgto_list = 0 THEN
     ELSE 
        LET p_cod_cnd_pgto = p_cnd_pgto_list
     END IF
     RETURN TRUE
  ELSE 
     RETURN FALSE
  END IF
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol0360_verifica_estoque()
#-----------------------------------#
  LET p_qtd_estoque = 0

  SELECT qtd_liberada
    INTO p_qtd_estoque
    FROM estoque
   WHERE estoque.cod_empresa = p_cod_empresa
     AND estoque.cod_item    = p_ped_itens_qfp_547_vv.cod_item

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
  
END FUNCTION

#---------------------------------------#
 FUNCTION pol0360_monta_dados_consulta()
#---------------------------------------#

  DEFINE l_count     INTEGER,
         p_qtd_solic DECIMAL(10,3),
         p_count_kb  INTEGER
  
  DELETE FROM prog_temp_547
  
  INITIALIZE t_ped_itens_qfp_547_vv to null
  
  LET p_num_pedido = p_ped_itens_qfp_547_vv.num_pedido
  LET p_cod_item   = p_ped_itens_qfp_547_vv.cod_item
  LET p_ind = 1 
  LET l_count = 0 
   
  DECLARE e_ped_itens_qfp_547_vv CURSOR WITH HOLD FOR
    SELECT * 
      FROM ped_itens_qfp_547_vv
     WHERE ped_itens_qfp_547_vv.cod_empresa = p_cod_empresa
       AND ped_itens_qfp_547_vv.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
       AND ped_itens_qfp_547_vv.cod_item    = p_ped_itens_qfp_547_vv.cod_item
     ORDER BY prz_entrega
     
  FOREACH e_ped_itens_qfp_547_vv INTO p_ped_itens_qfp_547_vv.*  
     
     if status <> 0 then
        call log003_err_sql('Lendo','ped_itens_qfp_547_vv')
        exit FOREACH
     end if
  
     DECLARE cq_pe5 CURSOR FOR
      SELECT * 
        FROM ped_itens_qfp_pe5_547_vv #obtém dat_abertura e ies_programacao
       WHERE cod_empresa   = p_ped_itens_qfp_547_vv.cod_empresa
         AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido 
         AND num_sequencia = p_ped_itens_qfp_547_vv.num_sequencia
         AND cod_item      = p_ped_itens_qfp_547_vv.cod_item       

     FOREACH cq_pe5 INTO p_ped_itens_qfp_pe5_547_vv.*
     
        if status <> 0 then
           call log003_err_sql('Lendo','ped_itens_qfp_547_vv')
        else
           LET l_count = 1
        end if
        
        EXIT FOREACH
     END FOREACH
     
     IF l_count = 0 THEN 
        CONTINUE FOREACH
     END IF
     
     LET l_count = 0
     
     IF p_tela.ies_data = "A" THEN
        IF p_ped_itens_qfp_pe5_547_vv.dat_abertura > p_tela.dat_prog THEN
           CONTINUE FOREACH
        END IF
     ELSE 
        IF p_ped_itens_qfp_547_vv.prz_entrega > p_tela.dat_prog THEN
           CONTINUE FOREACH
        END IF
     END IF

     IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "8" THEN
       CONTINUE FOREACH      
     END IF

     LET p_ok ="N"     
     IF p_tela.ies_firme  = "S"  AND 
        p_tela.ies_requis = "S"  AND 
        p_tela.ies_planej = "S"  THEN 
        LET p_ok ="S"     
     ELSE 
        IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "1" AND 
           p_tela.ies_firme = "S" THEN
           LET p_ok ="S"     
        ELSE 
##### AQUIOOOOOOOOO OS00702   16685244   16858934
           LET p_count_kb = 0 
           SELECT count(*)
             INTO p_count_kb
             FROM item_kanban_547
            WHERE cod_empresa = p_cod_empresa 
              AND cod_item    = p_ped_itens_qfp_547_vv.cod_item
              AND dat_termino > TODAY
           
           #IF  p_count_kb > 0 THEN
           #    LET p_ok ="S"
           #    LET p_ped_itens_qfp_pe5_547_vv.ies_programacao = "1"
           #ELSE 
######     

           IF  p_count_kb > 0 THEN
               IF p_ped_itens_qfp_547_vv.cod_item =  '16685244' OR 
                    p_ped_itens_qfp_547_vv.cod_item = '16858934' THEN
               ELSE
                  LET p_ok ="N"
               END IF
           ELSE 

              IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "3" AND 
                 p_tela.ies_requis= "S" THEN
                 LET p_ok ="S"     
              ELSE 
                 IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "4" AND 
                    p_tela.ies_planej= "S" THEN
                    LET p_ok ="S"     
                 END IF
              END IF
           END IF    
        END IF
     END IF

     IF p_ok = "N" THEN
        CONTINUE FOREACH
     END IF 

     IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "1" THEN
        LET t_ped_itens_qfp_547_vv[p_ind].sit_programa = "FIRME    " 
     ELSE 
        IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "3" THEN
           LET t_ped_itens_qfp_547_vv[p_ind].sit_programa = "REQUISIC."
        ELSE 
           IF p_ped_itens_qfp_pe5_547_vv.ies_programacao = "4" THEN
              LET t_ped_itens_qfp_547_vv[p_ind].sit_programa = "PLANEJADO"
           ELSE 
              LET t_ped_itens_qfp_547_vv[p_ind].sit_programa = "DOL      "
           END IF
        END IF
     END IF

     IF p_tela.ies_data = "A" THEN
        LET t_ped_itens_qfp_547_vv[p_ind].prz_entrega  = p_ped_itens_qfp_pe5_547_vv.dat_abertura
     ELSE
        LET t_ped_itens_qfp_547_vv[p_ind].prz_entrega  = p_ped_itens_qfp_547_vv.prz_entrega
     END IF

     DECLARE cq_qs CURSOR FOR
      SELECT qtd_pecas_solic
        FROM ped_itens
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
         AND cod_item    = p_ped_itens_qfp_547_vv.cod_item  
         AND prz_entrega = t_ped_itens_qfp_547_vv[p_ind].prz_entrega
    
     FOREACH cq_qs INTO p_qtd_solic
        IF STATUS <> 0 THEN
           CALL log003_err_sql('Lendo','ped_itens:cq_qs')
           RETURN FALSE
        END IF
        LET p_ped_itens_qfp_547_vv.qtd_solic = p_qtd_solic
        EXIT FOREACH
     END FOREACH
     
     LET t_ped_itens_qfp_547_vv[p_ind].qtd_solic        = p_ped_itens_qfp_547_vv.qtd_solic
     LET t_ped_itens_qfp_547_vv[p_ind].qtd_solic_nova   = p_ped_itens_qfp_547_vv.qtd_solic_nova
     
     IF p_ped_itens_qfp_547_vv.qtd_solic_aceita = 0 THEN
        LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_ped_itens_qfp_547_vv.qtd_solic_nova
     END IF

     LET t_ped_itens_qfp_547_vv[p_ind].qtd_solic_aceita = p_ped_itens_qfp_547_vv.qtd_solic_aceita
     LET p_qtd_variacao  = p_ped_itens_qfp_547_vv.qtd_solic_nova - p_ped_itens_qfp_547_vv.qtd_solic
     LET t_ped_itens_qfp_547_vv[p_ind].qtd_variacao   = p_qtd_variacao
  
     INSERT INTO prog_temp_547
      VALUES(p_ind,
             t_ped_itens_qfp_547_vv[p_ind].prz_entrega,
             t_ped_itens_qfp_547_vv[p_ind].qtd_solic,
             t_ped_itens_qfp_547_vv[p_ind].qtd_solic_nova,
             t_ped_itens_qfp_547_vv[p_ind].qtd_solic_aceita,
             t_ped_itens_qfp_547_vv[p_ind].qtd_variacao,
             t_ped_itens_qfp_547_vv[p_ind].sit_programa,
             p_ped_itens_qfp_547_vv.num_seq_ped,0)
      
     IF STATUS <> 0 THEN
        CALL log003_err_sql('INSERINDO','prog_temp_547')
        RETURN FALSE
     END IF
  
     LET p_ind = p_ind + 1

  END FOREACH
  
  LET p_qtd_itens = p_ind - 1
  
  IF p_qtd_itens = 0 then
     RETURN FALSE
  END IF
  
  IF NOT pol0360_ident_programacao() THEN
     RETURN FALSE
  END IF

  IF NOT pol0360_remonta_grade() THEN
     RETURN FALSE
  END IF

  RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0360_ident_programacao()
#-----------------------------------#
  
  DEFINE p_prz_array DATE,
         p_qtd_sub   DECIMAL(10,3)
  
  INITIALIZE pr_compl TO NULL
  LET p_index = 0
  
  DECLARE cq_id CURSOR FOR
   SELECT num_sequencia,
          qtd_solic_nova,
          prz_entrega,
          sit_programa,
          qtd_solic_aceita
     FROM prog_temp_547
    ORDER BY prz_entrega
  
  FOREACH cq_id INTO p_num_seq, p_qtd_solic_nova, p_prz_entrega, p_sit_prog, p_qtd_solic_aceita

     IF STATUS <> 0 THEN
        CALL log003_err_sql('LENDO','prog_temp_547')
        RETURN FALSE
     END IF
     
     IF p_prz_entrega = TODAY THEN
        IF p_num_seq < p_qtd_itens THEN
           LET p_prz_array = t_ped_itens_qfp_547_vv[p_num_seq + 1].prz_entrega
           IF p_prz_array = p_prz_entrega THEN        #próxima data de entrega = data lida
              LET p_sit_prog = 'ATRASO'
           ELSE
              IF NOT pol0360_ch_prz_entrega() THEN
                 RETURN FALSE
              END IF
              IF p_sit_prog = 'NOVA' THEN
                 LET p_sit_prog = 'ATRASO'
              END IF
           END IF
        ELSE
           IF NOT pol0360_ch_prz_entrega() THEN
              RETURN FALSE
           END IF
        END IF
     ELSE
        IF NOT pol0360_ch_prz_entrega() THEN
           RETURN FALSE
        END IF
     END IF             
     
     LET p_qtd_enviada = 0
     LET p_qtd_sub = 0
     
     IF p_sit_prog = 'ATRASO' AND p_num_nff_ult > 0 THEN
        IF NOT pol0360_ve_nfs_saidas() THEN
           RETURN FALSE
        END IF
        IF p_qtd_enviada <= p_qtd_solic_aceita THEN
           LET p_qtd_solic_aceita = p_qtd_solic_aceita - p_qtd_enviada
        ELSE
           LET p_qtd_sub = p_qtd_enviada - p_qtd_solic_aceita
           LET p_qtd_solic_aceita = 0
           IF p_num_seq < p_qtd_itens THEN
              LET pr_compl[p_num_seq].sequencia = p_num_seq + 1
              LET pr_compl[p_num_seq].qtd_sub   = p_qtd_sub
              LET p_index = p_index + 1
           END IF
        END IF
     END IF
     
     UPDATE prog_temp_547 
        SET sit_programa = p_sit_prog, 
            qtd_solic_aceita = p_qtd_solic_aceita,
            qtd_nfs = p_qtd_enviada
      WHERE num_sequencia = p_num_seq

     IF STATUS <> 0 THEN
        CALL log003_err_sql('UPDATE','PROG_TEMP_547')
        RETURN FALSE
     END IF
           
  END FOREACH

  FOR p_ind = 1 TO p_index
  
     UPDATE prog_temp_547 
        SET sit_programa = 'ALTERADA', 
            qtd_solic_aceita = qtd_solic_aceita - pr_compl[p_ind].qtd_sub
      WHERE num_sequencia = pr_compl[p_ind].sequencia

     IF STATUS <> 0 THEN
        CALL log003_err_sql('UPDATE','PROG_TEMP_547')
        RETURN FALSE
     END IF

  END FOR
  
  RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0360_ve_nfs_saidas()
#--------------------------------#
   
   SELECT SUM(qtd_item)
     INTO p_qtd_enviada
     FROM fat_nf_item a, fat_nf_mestre b
    WHERE a.empresa = p_cod_empresa
      AND a.pedido  = p_num_pedido
      AND a.item    = p_cod_item
      AND b.empresa = a.empresa
      AND b.cliente = p_cod_cliente
      AND b.nota_fiscal > p_num_nff_ult
      AND b.trans_nota_fiscal = a.trans_nota_fiscal      
   
     IF STATUS <> 0 THEN
        CALL log003_err_sql('LENDO','FAT_NF_ITEM')
        RETURN FALSE
     END IF
     
     IF p_qtd_enviada IS NULL THEN
        LET p_qtd_enviada = 0
     END IF
     
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol0360_remonta_grade()
#--------------------------------#

  LET p_ind = 1
  INITIALIZE t_ped_itens_qfp_547_vv TO NULL
  
  DECLARE cq_remonta CURSOR FOR
   SELECT prz_entrega,
          qtd_solic,
          qtd_solic_nova,
          qtd_solic_aceita,
          qtd_variacao,
          sit_programa,
          qtd_nfs
     FROM prog_temp_547
    ORDER BY prz_entrega
  
  FOREACH cq_remonta INTO 
          t_ped_itens_qfp_547_vv[p_ind].prz_entrega,     
          t_ped_itens_qfp_547_vv[p_ind].qtd_solic,       
          t_ped_itens_qfp_547_vv[p_ind].qtd_solic_nova,  
          t_ped_itens_qfp_547_vv[p_ind].qtd_solic_aceita,
          t_ped_itens_qfp_547_vv[p_ind].qtd_variacao,    
          t_ped_itens_qfp_547_vv[p_ind].sit_programa,
          t_ped_itens_qfp_547_vv[p_ind].qtd_nfs
                    
     IF STATUS <> 0 THEN
        CALL log003_err_sql('LENDO','prog_temp_547')
        RETURN FALSE
     END IF
     
     IF t_ped_itens_qfp_547_vv[p_ind].sit_programa = 'ATRASO' THEN
        LET t_ped_itens_qfp_547_vv[p_ind].qtd_variacao = 0
     END IF
     
     LET t_ped_itens_qfp_547_vv[p_ind].atualisar = 'N'
     
     IF t_ped_itens_qfp_547_vv[p_ind].qtd_solic_aceita > 0 THEN
        IF t_ped_itens_qfp_547_vv[p_ind].sit_programa <> 'FIRME' THEN
           LET t_ped_itens_qfp_547_vv[p_ind].atualisar = 'S'
        END IF
     END IF
     
     LET p_ind = p_ind + 1
     
  END FOREACH
  
  RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0360_ch_prz_entrega()
#--------------------------------#
  
  DEFINE p_qtd_pecas DECIMAL(10,3)
  
  SELECT qtd_pecas_solic
    INTO p_qtd_pecas
    FROM ped_itens
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_num_pedido
     AND cod_item    = p_cod_item
     AND prz_entrega = p_prz_entrega

  IF STATUS = 100 THEN
     LET p_sit_prog = 'NOVA'
  ELSE
     IF STATUS = 0 THEN
        IF p_qtd_pecas <> p_qtd_solic_nova THEN
           LET p_sit_prog = 'ALTERADA'
        END IF
     ELSE
        CALL log003_err_sql('LENDO','PED_ITENS')
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE
  
END FUNCTION            

#--------------------------#
FUNCTION pol0360_processa()
#--------------------------#

   LET p_count = 0
  
    FOR p_index = 1 to ARR_COUNT()
      IF t_ped_itens_qfp_547_vv[p_index].atualisar = 'S' THEN
         LET p_count = 1
      END IF
   END FOR
 
   IF p_count = 0 THEN
      LET p_msg = 'NENHUMA PROGRAMAÇÃO FOI SELECIONADA\n',
                  'CONTINUAR ASSIM MESMO ???'
   ELSE
      LET p_msg = 'Confirma a operação?'
   END IF

   IF NOT log0040_confirm(6,10,p_msg) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0360_prepara_ped_itens() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol0360_deleta_ped_itens_qfp() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol0360_deleta_pedidos_qfp() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0360_prepara_ped_itens()
#------------------------------------#
   
   DEFINE p_dat_atu DATE
   
   INITIALIZE p_ped_itens_qfp_547_vv TO NULL

   LET p_ped_itens_qfp_547_vv.cod_empresa = p_cod_empresa
   LET p_ped_itens_qfp_547_vv.num_pedido  = p_num_pedido
   LET p_ped_itens_qfp_547_vv.cod_item    = p_cod_item
   
   LET p_dat_atu = TODAY
   LET p_count = 0
   
   DECLARE cq_itens CURSOR WITH HOLD FOR
   SELECT num_sequencia,   
          prz_entrega,     
          qtd_solic,       
          qtd_solic_nova,  
          qtd_solic_aceita,
          num_seq_ped,
          sit_programa      
     FROM prog_temp_547
    WHERE prz_entrega >= p_dat_atu
      AND qtd_solic_aceita > 0
      AND (sit_programa = 'ATRASO' OR
           sit_programa = 'ALTERADA' OR
           sit_programa = 'NOVA')
   ORDER BY prz_entrega

   FOREACH cq_itens INTO 
           p_ped_itens_qfp_547_vv.num_sequencia,
           p_ped_itens_qfp_547_vv.prz_entrega,
           p_ped_itens_qfp_547_vv.qtd_solic,
           p_ped_itens_qfp_547_vv.qtd_solic_nova,
           p_ped_itens_qfp_547_vv.qtd_solic_aceita,
           p_ped_itens_qfp_547_vv.num_seq_ped,
           p_sit_prog

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','prog_temp_547:cq_itens')
         RETURN FALSE
      END IF
      
      LET p_index = p_ped_itens_qfp_547_vv.num_sequencia
      
      IF t_ped_itens_qfp_547_vv[p_index].atualisar = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      LET p_count = p_count + 1
      
      SELECT * 
        INTO p_ped_it_qfp_pe5_cl_547_vv.*
        FROM ped_it_qfp_pe5_cl_547_vv
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
         AND cod_item    = p_cod_item
         AND num_sequencia = p_ped_itens_qfp_547_vv.num_sequencia

      IF STATUS <> 0 THEN
         INITIALIZE p_ped_it_qfp_pe5_cl_547_vv.* TO NULL
      END IF

      IF pol0360_verifica_pedido() THEN
         IF p_sit_prog = 'ALTERADA' THEN
            IF NOT pol0360_le_ped_itens() THEN
               RETURN FALSE
            END IF
            IF p_prog_existe  = "S" THEN
               IF p_ped_itens.qtd_pecas_reserv   > 0 OR
                  p_ped_itens.qtd_pecas_romaneio > 0 THEN
                  CONTINUE FOREACH
               ELSE 
                  IF NOT pol0360_atualiza_ped_itens_2() THEN
                     RETURN FALSE
                  END IF
               END IF
            END IF
         ELSE 
            CALL pol0360_le_list_preco_item()  
            LET p_ped_itens.pre_unit = p_pre_unit
            IF NOT pol0360_grava_ped_itens() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0360_le_list_preco_item()
#---------------------------------------------------------------------#

   SELECT pre_unit 
     INTO p_pre_unit
     FROM desc_preco_item 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item    = p_ped_itens_qfp_547_vv.cod_item
      AND num_list_preco = 293

   IF sqlca.sqlcode <> 0 THEN
      CALL pol0360_le_preco_item_ped_itens()
      IF p_pre_unit = 0 THEN  
         ERROR "ITEM ",p_ped_itens_qfp_547_vv.cod_item,"  SEM PRECO NA LISTA 1" 
      END IF
   END IF

END FUNCTION   

#---------------------------------------------------------------------#
 FUNCTION pol0360_le_preco_item_ped_itens()
#---------------------------------------------------------------------#
  DEFINE p_prazo                LIKE ped_itens.prz_entrega

  SELECT MAX(prz_entrega)
    INTO p_prazo
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp_547_vv.cod_item

  SELECT MAX(pre_unit)
    INTO p_pre_unit
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
     AND ped_itens.cod_item    = p_ped_itens_qfp_547_vv.cod_item
     AND ped_itens.prz_entrega = p_prazo

  IF   p_pre_unit IS NULL
  THEN LET p_pre_unit = 0
  END IF
END FUNCTION

#-------------------------------#
 FUNCTION pol0360_le_ped_itens()
#-------------------------------#
  
  DEFINE p_min_seq INTEGER
  
  SELECT MIN(num_sequencia)
    INTO p_min_seq
    FROM ped_itens
   WHERE ped_itens.cod_empresa   = p_cod_empresa
     AND ped_itens.num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
     AND ped_itens.cod_item      = p_ped_itens_qfp_547_vv.cod_item
     AND ped_itens.prz_entrega   = p_ped_itens_qfp_547_vv.prz_entrega
  
  IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','ped_itens:sequencia')   
     RETURN FALSE
  END IF
  
  IF p_min_seq IS NULL OR p_min_seq = 0 THEN
     LET p_prog_existe = "N"
     RETURN TRUE
  END IF
  
  SELECT ped_itens.*
    INTO p_ped_itens.*
    FROM ped_itens
   WHERE ped_itens.cod_empresa   = p_cod_empresa
     AND ped_itens.num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
     AND ped_itens.cod_item      = p_ped_itens_qfp_547_vv.cod_item
     AND ped_itens.prz_entrega   = p_ped_itens_qfp_547_vv.prz_entrega
     AND ped_itens.num_sequencia = p_min_seq 

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','ped_itens:dados')   
     RETURN FALSE
  END IF

  LET p_prog_existe = "S"
  
  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0360_atualiza_ped_itens_1()
#---------------------------------------------------------------------#

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
    AND ped_itens.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
    AND ped_itens.cod_item    = p_ped_itens_qfp_547_vv.cod_item
    AND ped_itens.prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega
    AND ped_itens.num_sequencia = p_ped_itens_qfp_547_vv.num_seq_ped

  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("ATUALIZA_1","PED_ITENS")
  END IF
  
  LET p_audit_vdp.cod_empresa = p_cod_empresa
  LET p_audit_vdp.num_pedido = p_ped_itens_qfp_547_vv.num_pedido
  LET p_audit_vdp.tipo_informacao = 'M' 
  LET p_audit_vdp.tipo_movto = 'I'
  LET p_audit_vdp.texto = 'CANCELAMENTO ENTREGA ',p_ped_itens_qfp_547_vv.prz_entrega,' QUANTIDADE ',p_qtd_pecas_cancel
  LET p_audit_vdp.num_programa = 'POL0360'
  LET p_audit_vdp.data =  TODAY
  LET p_audit_vdp.hora =  TIME 
  LET p_audit_vdp.usuario = p_user
  LET p_audit_vdp.num_transacao = 0  
  INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","audit_vdp")
  END IF
  
  SELECT cod_item_cliente 
    INTO p_cod_item_cli
    FROM cliente_item
   WHERE cod_empresa = p_cod_empresa
     AND cod_cliente_matriz = p_cod_cliente 
     AND cod_item = p_ped_itens_qfp_547_vv.cod_item

  SELECT alter_tecnica
    INTO p_alter_tecnica
    FROM pedidos_edi_pe6 
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

                
  CALL pol0360_incl_ped_of_pcp()

END FUNCTION

#---------------------------------------#
 FUNCTION pol0360_atualiza_ped_itens_2()
#---------------------------------------#

  DEFINE p_atualiz CHAR(1) 

  DEFINE p_cod_item_cli  LIKE cliente_item.cod_item_cliente,
         p_alter_tecnica LIKE pedidos_edi_pe6.alter_tecnica

  UPDATE ped_itens 
     SET qtd_pecas_solic = p_ped_itens_qfp_547_vv.qtd_solic_aceita
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
     AND num_sequencia = p_ped_itens.num_sequencia

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","PED_ITENS")
     RETURN FALSE
  END IF

  LET p_audit_vdp.cod_empresa = p_cod_empresa
  LET p_audit_vdp.num_pedido = p_ped_itens_qfp_547_vv.num_pedido
  LET p_audit_vdp.tipo_informacao = 'M' 
  LET p_audit_vdp.tipo_movto = 'I'
  LET p_audit_vdp.texto = 'ALTERACAO SEQUENCIA ',p_ped_itens.num_sequencia,' QUANTIDADE ',p_ped_itens_qfp_547_vv.qtd_solic_aceita 
  LET p_audit_vdp.num_programa = 'POL0360'
  LET p_audit_vdp.data =  TODAY
  LET p_audit_vdp.hora =  TIME 
  LET p_audit_vdp.usuario = p_user
  LET p_audit_vdp.num_transacao = 0  

  INSERT INTO audit_vdp VALUES (p_audit_vdp.*)

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","audit_vdp")
     RETURN FALSE
  END IF

  LET l_count = 0 
  SELECT count(*)
    INTO l_count 
    FROM ped_itens_texto
   WHERE cod_empresa   = p_cod_empresa  
     AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
     AND num_sequencia = p_ped_itens.num_sequencia
  IF l_count > 0 THEN 
     UPDATE ped_itens_texto  SET den_texto_1 = p_ped_it_qfp_pe5_cl_547_vv.ident_prog
      WHERE cod_empresa   = p_cod_empresa  
        AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
  ELSE    
     INSERT INTO ped_itens_texto
     VALUES (p_cod_empresa,
             p_ped_itens_qfp_547_vv.num_pedido,
             p_ped_itens.num_sequencia,
             p_ped_it_qfp_pe5_cl_547_vv.ident_prog,
             NULL,
             NULL,
             NULL,
             NULL)
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
        RETURN FALSE
     END IF
  END IF    

 
 RETURN TRUE

END FUNCTION
	
#----------------------------------#
 FUNCTION pol0360_grava_ped_itens()
#----------------------------------#

  LET p_ped_itens.cod_empresa = p_cod_empresa                 
  LET p_ped_itens.num_pedido = p_ped_itens_qfp_547_vv.num_pedido
  LET p_ped_itens.cod_item = p_ped_itens_qfp_547_vv.cod_item
  LET p_ped_itens.pct_desc_adic = 0                             
  LET p_ped_itens.qtd_pecas_solic = p_ped_itens_qfp_547_vv.qtd_solic_aceita
  LET p_ped_itens.qtd_pecas_atend = 0                             
  LET p_ped_itens.qtd_pecas_cancel = 0                             
  LET p_ped_itens.qtd_pecas_reserv = 0                             
  LET p_ped_itens.prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega
  LET p_ped_itens.val_desc_com_unit = 0                             
  LET p_ped_itens.val_frete_unit = 0                             
  LET p_ped_itens.val_seguro_unit = 0                             
  LET p_ped_itens.qtd_pecas_romaneio = 0                             
  LET p_ped_itens.pct_desc_bruto = 0
  
  SELECT MAX(num_sequencia)
    INTO p_ped_itens.num_sequencia
    FROM ped_itens
   WHERE cod_empresa = p_ped_itens.cod_empresa
     AND num_pedido  = p_ped_itens.num_pedido

  IF p_ped_itens.num_sequencia IS NULL THEN
     LET p_ped_itens.num_sequencia = 0
  END IF
  
  LET p_ped_itens.num_sequencia = p_ped_itens.num_sequencia + 1
  
  INSERT INTO ped_itens VALUES (p_ped_itens.*)

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","PED_ITENS")
     RETURN FALSE
  END IF

  LET p_audit_vdp.cod_empresa = p_cod_empresa
  LET p_audit_vdp.num_pedido = p_ped_itens_qfp_547_vv.num_pedido
  LET p_audit_vdp.tipo_informacao = 'M' 
  LET p_audit_vdp.tipo_movto = 'I'
  LET p_audit_vdp.texto = 'INCLUSAO SEQUENCIA ',p_ped_itens.num_sequencia,' ENTREGA ',p_ped_itens.prz_entrega,' QUANTIDADE ',p_ped_itens.qtd_pecas_solic 
  LET p_audit_vdp.num_programa = 'POL0360'
  LET p_audit_vdp.data =  TODAY
  LET p_audit_vdp.hora =  TIME 
  LET p_audit_vdp.usuario = p_user
  LET p_audit_vdp.num_transacao = 0  
  INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","audit_vdp")
     RETURN FALSE
  END IF

  LET l_count = 0 
  SELECT count(*)
    INTO l_count 
    FROM ped_itens_texto
   WHERE cod_empresa   = p_cod_empresa  
     AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
     AND num_sequencia = p_ped_itens.num_sequencia
  IF l_count > 0 THEN 
     UPDATE ped_itens_texto  SET den_texto_1 = p_ped_it_qfp_pe5_cl_547_vv.ident_prog
      WHERE cod_empresa   = p_cod_empresa  
        AND num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
  ELSE    
     INSERT INTO ped_itens_texto
     VALUES (p_cod_empresa,
             p_ped_itens_qfp_547_vv.num_pedido,
             p_ped_itens.num_sequencia,
             p_ped_it_qfp_pe5_cl_547_vv.ident_prog,
             NULL,
             NULL,
             NULL,
             NULL)
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
        RETURN FALSE
     END IF
  END IF    

  RETURN TRUE
  
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0360_deleta_ped_itens_qfp()
#---------------------------------------------------------------------#

  DELETE FROM ped_itens_qfp_547_vv
  WHERE ped_itens_qfp_547_vv.cod_empresa = p_cod_empresa
    AND ped_itens_qfp_547_vv.num_pedido  = p_num_pedido
    AND ped_itens_qfp_547_vv.cod_item    = p_cod_item

  IF STATUS <> 0 then
     CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP")
     RETURN FALSE
  END IF
  
  RETURN TRUE
  
END FUNCTION

#-------------------------------------#
 FUNCTION pol0360_deleta_pedidos_qfp()
#-------------------------------------#
  
  DELETE FROM pedidos_qfp_547_vv
  WHERE pedidos_qfp_547_vv.cod_empresa = p_cod_empresa
    AND pedidos_qfp_547_vv.num_pedido  = p_num_pedido
 
  IF STATUS <> 0 then
     CALL log003_err_sql("DELECAO_2","PED_ITENS_QFP")
     RETURN FALSE
  END IF
  
  INITIALIZE p_ped_itens_qfp_547_vv.*, p_ped_itens.*, p_num_nff_ult,
             p_qtd_estoque, p_qtd_embarcado, t_ped_itens_qfp_547_vv TO NULL

  CLEAR FORM

  RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION pol0360_exclusao_ped_itens_qfp()
#----------------------------------------#
BEGIN WORK
IF   log004_confirm(22,45)
THEN 
     DELETE FROM ped_itens_qfp_547_vv
                   WHERE ped_itens_qfp_547_vv.cod_empresa = p_ped_itens_qfp_547_vv.cod_empresa
                     AND ped_itens_qfp_547_vv.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
                     AND ped_itens_qfp_547_vv.cod_item    = p_ped_itens_qfp_547_vv.cod_item
     IF   sqlca.sqlcode = 0
     THEN COMMIT WORK
          IF   sqlca.sqlcode = 0
          THEN FOR p_ind = 1 TO 100
                      INITIALIZE t_ped_itens_qfp_547_vv[p_ind].* TO NULL
               END FOR
          ELSE CALL log003_err_sql("EXCLUSAO_1","PED_ITENS_QFP")
               ROLLBACK WORK
          END IF
     ELSE CALL log003_err_sql("EXCLUSAO_2","PED_ITENS_QFP")
          ROLLBACK WORK
     END IF
     BEGIN WORK
     DELETE FROM pedidos_qfp_547_vv
                   WHERE pedidos_qfp_547_vv.cod_empresa = p_ped_itens_qfp_547_vv.cod_empresa
                     AND pedidos_qfp_547_vv.num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
     IF   sqlca.sqlcode = 0
     THEN COMMIT WORK
          IF   sqlca.sqlcode = 0
          THEN MESSAGE " Exclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
               INITIALIZE p_ped_itens_qfp_547_vv.*, p_ped_itens_qfpr.*, p_num_nff_ult,
                          p_qtd_estoque, p_qtd_embarcado TO NULL
               CLEAR FORM
          ELSE CALL log003_err_sql("EXCLUSAO_1","PEDIDOS_QFP")
               ROLLBACK WORK
          END IF
     ELSE CALL log003_err_sql("EXCLUSAO_2","PEDIDOS_QFP")
          ROLLBACK WORK
     END IF
     
ELSE ROLLBACK WORK
END IF

  MESSAGE "                            "
  ERROR " Execute novamente a Consulta  "
END FUNCTION

#------------------------------------#
 FUNCTION pol0360_paginacao(p_funcao)
#------------------------------------#
  
  DEFINE p_funcao            CHAR(20)
  
  LET p_achou = TRUE
  
  IF p_ies_cons THEN 
     LET p_ped_itens_qfpr.* = p_ped_itens_qfp_547_vv.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE"
                         FETCH NEXT     cq_ped_itens_qfp_547_vv INTO 
                            p_ped_itens_qfp_547_vv.num_pedido,p_ped_itens_qfp_547_vv.cod_item,
                            p_num_nff_ult, p_cod_cliente,p_cod_item_cliente
                            
         WHEN p_funcao = "ANTERIOR"
                         FETCH PREVIOUS cq_ped_itens_qfp_547_vv INTO 
                            p_ped_itens_qfp_547_vv.num_pedido,p_ped_itens_qfp_547_vv.cod_item,
                            p_num_nff_ult, p_cod_cliente,p_cod_item_cliente
       END CASE
     
       IF sqlca.sqlcode = NOTFOUND THEN 
          ERROR " Nao existem mais itens nesta direcao "
          LET p_achou = FALSE
          EXIT WHILE
       END IF
     
       IF p_num_nff_ult IS NULL THEN 
          LET p_num_nff_ult = 0
       END IF
       
       IF pol0360_verifica_pedido() THEN
          LET p_qtd_embarcado = 0
          LET p_saldo         = 0
       END IF
       
       IF pol0360_verifica_estoque() THEN 
       ELSE 
          LET p_qtd_estoque = 0
       END IF  
       
       if pol0360_monta_dados_consulta() then
          CALL pol0360_exibe_dados()
          EXIT WHILE
       end if
       
     END WHILE
  ELSE 
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
  
END FUNCTION

#-----------------------#
 FUNCTION pol0360_help()
#-----------------------#
  
  CASE
    WHEN infield(num_pedido)  
       CALL showhelp(2044)
  END CASE
  
 END FUNCTION

#------------------------------#
 FUNCTION pol0360_exibe_dados()
#------------------------------#
 
  DEFINE p_count SMALLINT
  
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_cod_cliente TO cod_cliente
  DISPLAY p_cod_item_cliente TO p_cod_item_cliente
  DISPLAY p_tela.dat_prog    TO dat_prog                
  DISPLAY p_tela.ies_data    TO ies_data                
  DISPLAY p_tela.ies_firme   TO ies_firme           
  DISPLAY p_tela.ies_requis  TO ies_requis          
  DISPLAY p_tela.ies_planej  TO ies_planej          
  CALL pol0360_verifica_cliente()
  DISPLAY BY NAME p_ped_itens_qfp_547_vv.num_pedido,
                  p_ped_itens_qfp_547_vv.cod_item,
                  p_num_nff_ult,
                  p_qtd_estoque,
                  p_qtd_embarcado

  CALL set_count(p_ind - 1)
  
  INPUT ARRAY t_ped_itens_qfp_547_vv 
      WITHOUT DEFAULTS FROM s_ped_itens_qfp.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

     AFTER FIELD atualisar

  END INPUT
  
END FUNCTION

#----------------------------------#
 FUNCTION pol0360_incl_ped_of_pcp()
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
  WHERE item.cod_item    = p_ped_itens_qfp_547_vv.cod_item
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
     AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
     AND prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega

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
FUNCTION pol0360_verifica_cliente()
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
 FUNCTION pol0360_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------FIM DO PROGRAMA BI----------#

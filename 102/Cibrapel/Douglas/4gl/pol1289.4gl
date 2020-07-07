#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1289                                                 #
# OBJETIVO: Cadastro de Notas x Tabela de Preco                     #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 23/07/2015                                              #
# FUNÇÕES:                                                          #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       p_den_empresa        LIKE empresa.den_empresa,
       p_user               LIKE usuario.nom_usuario,
       p_alterado           SMALLINT,
       p_versao             CHAR(18),
       p_status             SMALLINT,
       p_nom_tela           CHAR(200),
       p_ies_cons           SMALLINT,
       p_sem_saldo          SMALLINT,
       p_retorno            SMALLINT,
       p_opcao              CHAR(1),
       p_ind                SMALLINT,
       s_ind                SMALLINT,
       p_msg                CHAR(500),
       ies_finalizar        CHAR(1),
       p_index              SMALLINT,
       s_index              SMALLINT,
       p_comprime           CHAR(01),
       p_descomprime        CHAR(01),
       p_6lpp               CHAR(100),
       p_8lpp               CHAR(100),
       p_nom_arquivo        CHAR(100),
       comando              CHAR(80),
       p_caminho            CHAR(080),
       g_ies_ambiente       CHAR(01),
       p_ies_impressao      CHAR(01),
       p_last_row           SMALLINT,
       p_id_tabela          INTEGER,
       p_id_versao          INTEGER,
       p_count              SMALLINT
END GLOBALS

DEFINE p_nf_x_tab_frete_885   RECORD LIKE nf_x_tab_frete_885.*,
       p_nf_x_tab_frete_885_a RECORD LIKE nf_x_tab_frete_885.*,
       p_cod_fornecedor       LIKE fornecedor.cod_fornecedor,
       p_raz_social           LIKE fornecedor.raz_social,
       p_num_nf               LIKE nf_sup.num_nf ,
       p_ies_especie_nf       LIKE nf_sup.ies_especie_nf,
       p_dat_emis_nf          LIKE nf_sup.dat_emis_nf,
       p_cod_transpor         LIKE clientes.cod_cliente,
       p_nom_transpor         LIKE clientes.nom_cliente,
       p_versao_tabela        LIKE tab_frete_885.versao,
       p_origem               LIKE tab_frete_885.origem,
       p_destino              LIKE tab_frete_885.destino,       
       p_val_tonelada         LIKE tab_frete_885.val_tonelada, 
       p_peso_balanca         LIKE aviso_rec.qtd_recebida,
       p_tara_minima          LIKE transportador_placa_885.tara_minima,
       p_num_aviso_rec        LIKE aviso_rec.num_aviso_rec
MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 5
    DEFER INTERRUPT
    LET p_versao = "pol1289-10.02.00 "
    OPTIONS
        NEXT KEY control-f,
        INSERT KEY control-i,
        DELETE KEY control-e,
        PREVIOUS KEY control-b
    
    CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
    {LET p_cod_empresa = '02'; LET p_user = 'admlog'; LET p_status = 0}
    
    IF p_status = 0 THEN
        CALL pol1289_menu()
    END IF
    
END MAIN

#---------------------#
FUNCTION pol1289_menu()
#---------------------#

    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho( "pol1289" ) RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol1289 AT 2,1 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
    DISPLAY p_cod_empresa TO cod_empresa
    
    MENU "OPCAO"
        COMMAND "Incluir" "Inclui dados na tabela."
            CALL pol1289_inclusao() RETURNING p_status
            IF p_status THEN
                ERROR 'Inclusão efetuada com sucesso !!!'
                LET p_ies_cons = FALSE
            ELSE
                ERROR 'Operação cancelada !!!'
            END IF
        COMMAND "Consultar" "Consulta dados da tabela."
            IF pol1289_consulta() THEN
                ERROR 'Consulta efetuada com sucesso !!!'
                NEXT OPTION "Seguinte"
            ELSE
                ERROR 'consulta cancela !!!'
            END IF
        COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
            IF p_ies_cons THEN
                CALL pol1289_paginacao("S")
            ELSE
                ERROR "Não existe nenhuma consulta ativa !!!"
            END IF
        COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
            IF p_ies_cons THEN
                CALL pol1289_paginacao("A")
            ELSE
                ERROR "Não existe nenhuma consulta ativa !!!"
            END IF
        COMMAND "Modificar" "Modifica dados da tabela."
            IF p_ies_cons THEN
                CALL pol1289_modificacao() RETURNING p_status
                IF p_status THEN
                    ERROR 'Modificação efetuada com sucesso !!!'
                ELSE
                    ERROR 'Operação cancelada !!!'
                END IF
            ELSE
                ERROR "Consulte previamente para fazer a modificacao !!!"
            END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1289_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
        COMMAND "Listar" "Listagem dos registros cadastrados."
            CALL pol1289_listagem()
        COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
            CALL pol1289_exibe_versao()
        COMMAND KEY ("!")
            PROMPT "Digite o comando : " FOR comando
            RUN comando
            PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
            DATABASE logix
        COMMAND "Fim"       "Retorna ao menu anterior."
            EXIT MENU
    END MENU
    
    CLOSE WINDOW w_pol1289
    
END FUNCTION

#---------------------------#
FUNCTION pol1289_limpa_tela()
#---------------------------#

    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1289_inclusao()
#--------------------------#
    
	DEFINE p_funcao CHAR(01)
    LET p_funcao   = 'I'
    
	CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    INITIALIZE p_nf_x_tab_frete_885.* TO NULL
    LET p_nf_x_tab_frete_885.tip_frete = 'C'
    DISPLAY p_nf_x_tab_frete_885.tip_frete TO tip_frete
    
    LET INT_FLAG  = FALSE
    
    IF pol1289_edita_dados(p_funcao) THEN
        RETURN TRUE
    END IF
    
    IF INT_FLAG = 0 THEN
        RETURN TRUE
    ELSE
        LET INT_FLAG = 0
        CLEAR FORM
    END IF

    RETURN FALSE

END FUNCTION

#--------------------------------------#
FUNCTION pol1289_edita_dados(p_funcao)
#--------------------------------------#
    
	DEFINE p_funcao CHAR(01)
    LET INT_FLAG  = FALSE
    LET p_tara_minima = 0
    
    INPUT p_nf_x_tab_frete_885.num_aviso_rec,
          p_nf_x_tab_frete_885.cod_transpor,
          p_nf_x_tab_frete_885.num_placa,
          p_nf_x_tab_frete_885.tabela,
          p_nf_x_tab_frete_885.tip_frete
        WITHOUT DEFAULTS
           FROM num_aviso_rec,
                cod_transpor,
                num_placa,
                tabela,
                tip_frete
        BEFORE FIELD num_aviso_rec
        IF p_funcao = 'M' THEN
            NEXT FIELD tip_frete
        END IF
                
        AFTER FIELD num_aviso_rec
        IF p_funcao = 'I' THEN
            IF p_nf_x_tab_frete_885.num_aviso_rec IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD num_aviso_rec
            ELSE
            	
              SELECT COUNT(num_aviso_rec)
                INTO p_count
                FROM nf_x_tab_frete_885
               WHERE cod_empresa = p_cod_empresa
                 AND num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
                IF STATUS <> 0 THEN
                    CALL log003_err_sql('lendo','nf_x_tab_frete_885')
                    RETURN FALSE
                END IF

                IF p_count > 0 THEN
                   ERROR "Já existe registro para este documento!!! - Use a opção modificar"
                   NEXT FIELD num_aviso_rec
                END IF
      
                SELECT sum(qtd_recebida) as total_qtd_recebida
                  INTO p_peso_balanca
                  FROM aviso_rec ar
                 WHERE ar.cod_empresa = p_cod_empresa
                   AND ar.num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
                            
                IF STATUS = 100 THEN
                    ERROR 'AR não Localizada.'
                    NEXT FIELD num_aviso_rec
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','nf_sup')
                        RETURN FALSE
                    END IF
                    SELECT ns.num_nf,
                           ns.ies_especie_nf,
                           ns.dat_emis_nf,
                           ns.cod_fornecedor,
                           f.raz_social
                      INTO p_num_nf,
                           p_ies_especie_nf,
                           p_dat_emis_nf,
                           p_cod_fornecedor,
                           p_raz_social
                      FROM nf_sup ns,
                           fornecedor f
                     WHERE ns.cod_empresa = p_cod_empresa
                       AND ns.num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
                       AND ns.cod_fornecedor = f.cod_fornecedor
                               
                    IF STATUS = 100 THEN
                        ERROR 'AR não Localizada.'
                        NEXT FIELD num_aviso_rec
                    ELSE
                        IF STATUS <> 0 THEN
                            CALL log003_err_sql('SELECT','nf_sup')
                            RETURN FALSE
                        END IF
                        LET p_nf_x_tab_frete_885.peso_balanca = p_peso_balanca
                        
                        DISPLAY p_num_nf             TO num_nf
                        DISPLAY p_ies_especie_nf     TO ies_especie_nf
                        DISPLAY p_dat_emis_nf        TO dat_emis_nf
                        DISPLAY p_cod_fornecedor     TO cod_fornecedor
                        DISPLAY p_raz_social         TO raz_social
                        DISPLAY p_peso_balanca       TO peso_balanca

                    END IF
                END IF
            END IF
            NEXT FIELD tip_frete
       END IF

       BEFORE FIELD tip_frete
        IF p_nf_x_tab_frete_885.tip_frete IS NULL THEN
           LET p_nf_x_tab_frete_885.tip_frete = 'C'
        END IF 

       AFTER FIELD tip_frete
        IF p_nf_x_tab_frete_885.tip_frete IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD tip_frete
        ELSE
	        NEXT FIELD cod_transpor
        END IF   
            
        AFTER FIELD cod_transpor
            IF p_nf_x_tab_frete_885.cod_transpor IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD cod_transpor
            ELSE
                SELECT cl.nom_cliente
                  INTO p_nom_transpor
                  FROM fornec_tara_minima_885 ft,
                       clientes cl
                 WHERE ft.cod_fornecedor = p_cod_fornecedor
                   AND ft.cod_transpor   = p_nf_x_tab_frete_885.cod_transpor
                   AND ft.cod_transpor   = cl.cod_cliente
                   
                IF STATUS = 100 THEN
                    ERROR 'Transportador não Localizado.'
                    NEXT FIELD cod_transpor
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','transportador_placa_885')
                        RETURN FALSE
                    END IF
                    
                    DISPLAY p_nom_transpor TO nom_transpor
                END IF
            
            END IF
        
        AFTER FIELD num_placa
            IF p_nf_x_tab_frete_885.cod_transpor IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD cod_transpor
            ELSE
                IF p_nf_x_tab_frete_885.num_placa IS NULL THEN
                    ERROR "Campo com preenchimento obrigatório !!!"
                    NEXT FIELD num_placa
                END IF
                
                SELECT tara_minima
                  INTO p_tara_minima  {tara minima é em tonelada???}
                  FROM transportador_placa_885
                 WHERE cod_transpor = p_nf_x_tab_frete_885.cod_transpor
                   AND num_placa    = p_nf_x_tab_frete_885.num_placa
                           
                IF STATUS = 100 THEN
                    ERROR 'Placa não Localizada.'
                    NEXT FIELD num_placa
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','transportador_placa_885')
                        RETURN FALSE
                    ELSE
                        IF p_tara_minima IS NULL THEN
                            LET p_nf_x_tab_frete_885.peso_pagar = p_peso_balanca
                        ELSE
                            IF p_peso_balanca > p_tara_minima THEN
                    	        LET p_nf_x_tab_frete_885.peso_pagar = p_peso_balanca
                            ELSE
                                LET p_nf_x_tab_frete_885.peso_pagar = p_tara_minima
                            END IF
                    	END IF
                    
                        DISPLAY p_nf_x_tab_frete_885.peso_pagar TO peso_pagar
                        NEXT FIELD tabela
                    END IF
                END IF
            END IF
        
        AFTER FIELD tabela
            IF p_nf_x_tab_frete_885.tabela IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD tabela
            ELSE
                SELECT versao,
                       origem,
                       destino,
                       val_tonelada
                  INTO p_nf_x_tab_frete_885.versao,
                       p_origem,
                       p_destino,
                       p_nf_x_tab_frete_885.val_tonelada
                  FROM tab_frete_885
                 WHERE tabela = p_nf_x_tab_frete_885.tabela
                   AND versao_atual = 'S'
                   
                IF STATUS = 100 THEN
                    ERROR 'Tabela não Localizada.'
                    NEXT FIELD tabela
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','tab_frete_885')
                        RETURN FALSE
                    END IF

                    LET p_nf_x_tab_frete_885.val_frete = (p_nf_x_tab_frete_885.val_tonelada/1000 ) * p_nf_x_tab_frete_885.peso_pagar
                    
                    DISPLAY p_nf_x_tab_frete_885.versao       TO versao
                    DISPLAY p_origem                          TO origem
                    DISPLAY p_destino                         TO destino
                    DISPLAY p_nf_x_tab_frete_885.val_tonelada TO val_tonelada
                    DISPLAY p_nf_x_tab_frete_885.val_frete    TO val_frete
                END IF            	
            
            END IF
                        
      ON KEY (control-z)
         CALL pol1289_popup()
         
    END INPUT
    
    IF INT_FLAG THEN
        RETURN FALSE
    END IF
    
    IF p_funcao = 'I' THEN
        IF pol1289_insere() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF

    IF p_funcao = 'M' THEN
        IF pol1289_altera() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF
    
END FUNCTION

#-----------------------#
 FUNCTION pol1289_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1289
         IF p_codigo IS NOT NULL THEN
            LET p_nf_x_tab_frete_885.cod_transpor = p_codigo CLIPPED
            DISPLAY p_nf_x_tab_frete_885.cod_transpor TO cod_transpor
         END IF
  
      WHEN INFIELD(num_placa)
         CALL pol1289_popup_placa() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1289
         IF p_codigo IS NOT NULL THEN
            LET p_nf_x_tab_frete_885.num_placa = p_codigo CLIPPED
            DISPLAY p_nf_x_tab_frete_885.num_placa TO num_placa
         END IF

      WHEN INFIELD(tabela)
         CALL pol1289_popup_tabela() RETURNING p_codigo,
                                               p_versao_tabela,
                                               p_val_tonelada,
                                               p_origem,
                                               p_destino
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1289
         IF p_codigo IS NOT NULL THEN
            LET p_nf_x_tab_frete_885.tabela       = p_codigo CLIPPED
            LET p_nf_x_tab_frete_885.versao       = p_versao_tabela CLIPPED
            LET p_nf_x_tab_frete_885.val_tonelada = p_val_tonelada  CLIPPED
            
            DISPLAY p_nf_x_tab_frete_885.tabela       TO tabela
            DISPLAY p_nf_x_tab_frete_885.versao       TO versao
            DISPLAY p_nf_x_tab_frete_885.val_tonelada TO val_tonelada
            DISPLAY p_origem  TO origem
            DISPLAY p_destino TO destino
            
         END IF
                     
   END CASE

END FUNCTION

#-----------------------------#
FUNCTION pol1289_popup_placa()#
#-----------------------------#
    DEFINE l_index SMALLINT
    DEFINE pr_placas ARRAY[100] OF RECORD 	
           cod_transpor LIKE clientes.cod_cliente,
           nom_transpor LIKE clientes.nom_cliente,
           num_placa    LIKE transportador_placa_885.num_placa
    END RECORD
    
    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho("pol12891") RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol12891 AT 2,16 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
    
    LET l_index = 1
    
    DECLARE cq_placa CURSOR FOR 
    SELECT tp.cod_transpor,  
           cl.nom_cliente, 
           tp.num_placa
      FROM transportador_placa_885 tp, 
           clientes cl
     WHERE tp.cod_transpor = cl.cod_cliente
       AND tp.cod_transpor = p_nf_x_tab_frete_885.cod_transpor
     ORDER BY 1,2,3
 
    FOREACH cq_placa INTO pr_placas[l_index].*
        LET l_index = l_index + 1
        
        IF l_index > 100 THEN
            LET p_msg = 'Limite de grade ultrapassado !!!'
            CALL log0030_mensagem(p_msg,'exclamation')
            EXIT FOREACH
        END IF
                
    END FOREACH

    CALL SET_COUNT(l_index -1)

    DISPLAY ARRAY pr_placas TO sr_placas.* 
    
    LET p_index = ARR_CURR()
    LET s_index = SCR_LINE()

    CLOSE WINDOW w_pol12891

    IF INT_FLAG = 0 THEN
        RETURN pr_placas[p_index].num_placa
    ELSE
        LET INT_FLAG = 0
        RETURN FALSE
    END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1289_popup_tabela()#
#-----------------------------#
    DEFINE l_index SMALLINT
    DEFINE sql_stmt,
           where_clause CHAR(500)
           
    DEFINE pr_tabelas ARRAY[100] OF RECORD 	
           tabela       LIKE tab_frete_885.tabela,
           versao       LIKE tab_frete_885.versao,
           val_tonelada LIKE tab_frete_885.val_tonelada,
           den_origem       LIKE tab_frete_885.origem,
           den_destino      LIKE tab_frete_885.destino
    END RECORD
    
    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho("pol12892") RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol12892 AT 2,16 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    DISPLAY p_cod_empresa TO cod_empresa
    
    LET l_index = 1
    
    CONSTRUCT BY NAME where_clause ON 
        tab_frete_885.origem,
        tab_frete_885.destino
        
   IF INT_FLAG THEN
      RETURN "" 
   END IF
    
    LET sql_stmt = "SELECT tabela,versao,val_tonelada,origem,destino",
                   "  FROM tab_frete_885 ",
                   " WHERE ", where_clause CLIPPED,
                   "  AND versao_atual = 'S'",
                   " ORDER BY 1,2,3 "
    
    PREPARE var_query FROM sql_stmt
    DECLARE cq_tabela CURSOR WITH HOLD FOR var_query
    
    OPEN cq_padrao
    
    FOREACH cq_tabela INTO pr_tabelas[l_index].*
        LET l_index = l_index + 1
        
        IF l_index > 100 THEN
            LET p_msg = 'Limite de grade ultrapassado !!!'
            CALL log0030_mensagem(p_msg,'exclamation')
            EXIT FOREACH
        END IF
    END FOREACH

    CALL SET_COUNT(l_index -1)

    DISPLAY ARRAY pr_tabelas TO sr_tabelas.*
    
    LET p_index = ARR_CURR()
    LET s_index = SCR_LINE()

    CLOSE WINDOW w_pol12892

    IF INT_FLAG = 0 THEN
        RETURN pr_tabelas[p_index].tabela,
               pr_tabelas[p_index].versao,
               pr_tabelas[p_index].val_tonelada,
               pr_tabelas[p_index].den_origem,
               pr_tabelas[p_index].den_destino
    ELSE
        LET INT_FLAG = 0
        RETURN FALSE
    END IF

END FUNCTION

#-----------------------#
FUNCTION pol1289_insere()
#-----------------------#

    CALL log085_transacao("BEGIN")
    
    INSERT INTO nf_x_tab_frete_885 (
                cod_empresa,
                num_aviso_rec,
                tip_frete,
                cod_transpor,
                num_placa,
                tabela,
                versao,
                val_tonelada,
                peso_balanca,
                peso_pagar,
                val_frete)
     VALUES (p_cod_empresa,
             p_nf_x_tab_frete_885.num_aviso_rec,
             p_nf_x_tab_frete_885.tip_frete,
             p_nf_x_tab_frete_885.cod_transpor,
             p_nf_x_tab_frete_885.num_placa,
             p_nf_x_tab_frete_885.tabela,
             p_nf_x_tab_frete_885.versao,
             p_nf_x_tab_frete_885.val_tonelada,
             p_nf_x_tab_frete_885.peso_balanca,
             p_nf_x_tab_frete_885.peso_pagar,
             p_nf_x_tab_frete_885.val_frete )
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "INSERT", "nf_x_tab_frete_885" )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1289_altera()
#-----------------------#
    
    CALL log085_transacao("BEGIN")
    
    IF pol1289_prende_registro() THEN
    ELSE
        RETURN FALSE
    END IF
    
    UPDATE nf_x_tab_frete_885
       SET tip_frete    = p_nf_x_tab_frete_885.tip_frete,
           cod_transpor = p_nf_x_tab_frete_885.cod_transpor,
           num_placa    = p_nf_x_tab_frete_885.num_placa,
           tabela       = p_nf_x_tab_frete_885.tabela,
           versao       = p_nf_x_tab_frete_885.versao,
           val_tonelada = p_nf_x_tab_frete_885.val_tonelada,
           peso_balanca = p_nf_x_tab_frete_885.peso_balanca,
           peso_pagar   = p_nf_x_tab_frete_885.peso_pagar,
           val_frete    = p_nf_x_tab_frete_885.val_frete
     WHERE cod_empresa  = p_cod_empresa 
       AND num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "UPDATE", 'nf_x_tab_frete_885' )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1289_consulta()
#--------------------------#
    
    DEFINE sql_stmt,
           where_clause CHAR(500)
    
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    LET p_nf_x_tab_frete_885_a = p_nf_x_tab_frete_885
    LET INT_FLAG = FALSE
    LET p_ies_cons = FALSE
    
    CONSTRUCT BY NAME where_clause ON
                      p_nf_x_tab_frete_885.num_aviso_rec,
                      p_nf_x_tab_frete_885.tip_frete,
                      p_nf_x_tab_frete_885.cod_transpor,
                      p_nf_x_tab_frete_885.num_placa,
                      p_nf_x_tab_frete_885.tabela,
                      p_nf_x_tab_frete_885.versao,
                      p_nf_x_tab_frete_885.val_tonelada,
                      p_nf_x_tab_frete_885.peso_balanca,
                      p_nf_x_tab_frete_885.peso_pagar,
                      p_nf_x_tab_frete_885.val_frete 
    
    END CONSTRUCT
    
    IF INT_FLAG THEN
        IF p_ies_cons THEN
            LET p_nf_x_tab_frete_885 = p_nf_x_tab_frete_885_a
            CALL pol1289_exibe_dados() RETURNING p_status
        END IF
        RETURN FALSE
    END IF
    
    LET sql_stmt = "SELECT cod_empresa, num_aviso_rec, tip_frete, cod_transpor, num_placa, ",
                   " tabela, versao, val_tonelada, peso_balanca, peso_pagar, val_frete ",
                   "  FROM nf_x_tab_frete_885 ",
                   " WHERE cod_empresa = ",p_cod_empresa, 
                   "   AND", where_clause CLIPPED,
                   " ORDER BY num_aviso_rec "
    
    PREPARE var_query FROM sql_stmt
    DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
    
    OPEN cq_padrao
    
    FETCH cq_padrao INTO p_nf_x_tab_frete_885.cod_empresa,
                         p_nf_x_tab_frete_885.num_aviso_rec,
                         p_nf_x_tab_frete_885.tip_frete,
                         p_nf_x_tab_frete_885.cod_transpor,
                         p_nf_x_tab_frete_885.num_placa,
                         p_nf_x_tab_frete_885.tabela,
                         p_nf_x_tab_frete_885.versao,
                         p_nf_x_tab_frete_885.val_tonelada,
                         p_nf_x_tab_frete_885.peso_balanca,
                         p_nf_x_tab_frete_885.peso_pagar,
                         p_nf_x_tab_frete_885.val_frete
    
    IF STATUS = NOTFOUND THEN
        CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
        LET p_ies_cons = FALSE
        RETURN FALSE
    ELSE
        IF pol1289_exibe_dados() THEN
            LET p_ies_cons = TRUE
            RETURN TRUE
        END IF
    END IF
    
    RETURN FALSE
    
END FUNCTION

#--------------------------------------#
FUNCTION pol1289_modificacao()
#--------------------------------------#
    
    DEFINE p_funcao CHAR(01)
    
    LET p_retorno = FALSE
    LET INT_FLAG  = FALSE
    LET p_funcao   = 'M'
    
    IF pol1289_edita_dados(p_funcao) THEN
		RETURN TRUE
	ELSE
		RETURN FALSE
    END IF
    
    IF p_retorno THEN
        CALL log085_transacao("COMMIT")
    ELSE
        CALL log085_transacao("ROLLBACK")
    END IF
    
    RETURN p_retorno
    
END FUNCTION

#--------------------------------#
FUNCTION pol1289_prende_registro()
#--------------------------------#
    
    CALL log085_transacao("BEGIN")
    
    DECLARE cq_prende CURSOR FOR
    SELECT *
      FROM nf_x_tab_frete_885
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
    
    FOR UPDATE
    
    OPEN cq_prende
    FETCH cq_prende
    
    IF STATUS = 0 THEN
        RETURN TRUE
    ELSE
        CALL log003_err_sql("Lendo","nf_x_tab_frete_885")
        RETURN FALSE
    END IF
    
END FUNCTION

#----------------------------------#
FUNCTION pol1289_paginacao(p_funcao)
#----------------------------------#
    
    DEFINE p_funcao   CHAR(01)
    
    LET p_nf_x_tab_frete_885_a.* = p_nf_x_tab_frete_885.*
    
    WHILE TRUE
        CASE
            WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_nf_x_tab_frete_885.*
    
            WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_nf_x_tab_frete_885.*
        END CASE
    
        IF STATUS = 0 THEN
            CALL pol1289_exibe_dados() RETURNING p_status
            EXIT WHILE
        ELSE
            IF STATUS = 100 THEN
                ERROR "Não existem mais itens nesta direção !!!"
                LET p_nf_x_tab_frete_885.* = p_nf_x_tab_frete_885_a.*
            ELSE
                CALL log003_err_sql('Lendo','cq_padrao_2')
            END IF
            EXIT WHILE
        END IF
    END WHILE
    
END FUNCTION

#------------------------------#
FUNCTION pol1289_exibe_dados()
#------------------------------#

    SELECT sum(qtd_recebida) as total_qtd_recebida
      INTO p_peso_balanca
      FROM aviso_rec ar
     WHERE ar.cod_empresa = p_cod_empresa
        AND ar.num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
                            
    IF STATUS = 100 THEN
        ERROR 'AR não Localizada.'
    ELSE
        IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','nf_sup')
            RETURN FALSE
        END IF
    END IF
                           
	SELECT ns.num_nf,
		   ns.ies_especie_nf,
		   ns.dat_emis_nf,
		   ns.cod_fornecedor,
		   f.raz_social
	  INTO p_num_nf,
		   p_ies_especie_nf,
		   p_dat_emis_nf,
		   p_cod_fornecedor,
		   p_raz_social
	  FROM nf_sup ns,
		   fornecedor f
	 WHERE ns.cod_empresa = p_cod_empresa
	   AND ns.num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
	   AND ns.cod_fornecedor = f.cod_fornecedor
			   
	IF STATUS = 100 THEN
		ERROR 'AR não Localizada.'
	ELSE
		IF STATUS <> 0 THEN
			CALL log003_err_sql('SELECT','nf_sup')
			RETURN FALSE
		END IF
		LET p_nf_x_tab_frete_885.peso_balanca = p_peso_balanca
		
		DISPLAY p_num_nf             TO num_nf
		DISPLAY p_ies_especie_nf     TO ies_especie_nf
		DISPLAY p_dat_emis_nf        TO dat_emis_nf
		DISPLAY p_cod_fornecedor     TO cod_fornecedor
		DISPLAY p_raz_social         TO raz_social
		DISPLAY p_peso_balanca       TO peso_balanca

	END IF
 
     SELECT cl.nom_cliente
      INTO p_nom_transpor
      FROM fornec_tara_minima_885 ft,
    	   clientes cl
     WHERE ft.cod_fornecedor = p_cod_fornecedor
       AND ft.cod_transpor   = p_nf_x_tab_frete_885.cod_transpor
       AND ft.cod_transpor   = cl.cod_cliente
       
    IF STATUS = 100 THEN
    	ERROR 'Transportador não Localizado.'
    ELSE
    	IF STATUS <> 0 THEN
    		CALL log003_err_sql('SELECT','transportador_placa_885')
    		RETURN FALSE
    	END IF
    	
    	DISPLAY p_nom_transpor TO nom_transpor
    END IF

	SELECT versao,
    	   origem,
    	   destino,
    	   val_tonelada
      INTO p_nf_x_tab_frete_885.versao,
    	   p_origem,
    	   p_destino,
    	   p_nf_x_tab_frete_885.val_tonelada
      FROM tab_frete_885
     WHERE tabela = p_nf_x_tab_frete_885.tabela
       AND versao_atual = 'S'
       
    IF STATUS = 100 THEN
    	ERROR 'Tabela não Localizada.'
    ELSE
    	IF STATUS <> 0 THEN
    		CALL log003_err_sql('SELECT','tab_frete_885')
    		RETURN FALSE
    	END IF
    
    	LET p_nf_x_tab_frete_885.val_frete = p_nf_x_tab_frete_885.val_tonelada * p_nf_x_tab_frete_885.peso_balanca
    	
    	DISPLAY p_nf_x_tab_frete_885.versao       TO versao
    	DISPLAY p_origem                          TO origem
    	DISPLAY p_destino                         TO destino
    	DISPLAY p_nf_x_tab_frete_885.val_tonelada TO val_tonelada
    	DISPLAY p_nf_x_tab_frete_885.val_frete    TO val_frete
    END IF
    SELECT ns.num_nf,
           ns.ies_especie_nf,
           ns.dat_emis_nf,
           ns.cod_fornecedor,
           f.raz_social
      INTO p_num_nf,
           p_ies_especie_nf,
           p_dat_emis_nf,
           p_cod_fornecedor,
           p_raz_social
           FROM nf_sup ns,
           fornecedor f
      WHERE ns.cod_empresa = p_cod_empresa
         AND ns.num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec
         AND ns.cod_fornecedor = f.cod_fornecedor
                               
    IF STATUS = 100 THEN
        ERROR 'AR não Localizada.'
    ELSE
        IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','nf_sup')
            RETURN FALSE
        END IF
        LET p_nf_x_tab_frete_885.peso_balanca = p_peso_balanca
                        
        DISPLAY p_num_nf             TO num_nf
        DISPLAY p_ies_especie_nf     TO ies_especie_nf
        DISPLAY p_dat_emis_nf        TO dat_emis_nf
        DISPLAY p_cod_fornecedor     TO cod_fornecedor
        DISPLAY p_raz_social         TO raz_social
        DISPLAY p_peso_balanca       TO peso_balanca

    END IF
    
    DISPLAY by NAME p_nf_x_tab_frete_885.*
    
    RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1289_exclusao()
#--------------------------#

    IF NOT log004_confirm(18,35) THEN
        RETURN FALSE
    END IF

    LET p_retorno = FALSE
    LET p_ies_cons = FALSE
   
    IF pol1289_prende_registro() THEN
        DELETE FROM nf_x_tab_frete_885
			  WHERE cod_empresa = p_cod_empresa
			    AND num_aviso_rec = p_nf_x_tab_frete_885.num_aviso_rec

        IF STATUS = 0 THEN
            INITIALIZE p_nf_x_tab_frete_885.* TO NULL
            INITIALIZE p_nf_x_tab_frete_885_a.* TO NULL
            CLEAR FORM
            LET p_retorno = TRUE
        ELSE
            CALL log003_err_sql('DELETE','nf_x_tab_frete_885')
        END IF
        CLOSE cq_prende
    END IF

    IF p_retorno THEN
        CALL log085_transacao("COMMIT")
    ELSE
        CALL log085_transacao("ROLLBACK")
    END IF

    RETURN p_retorno

END FUNCTION


#--------------------------#
FUNCTION pol1289_listagem()
#--------------------------#

    IF NOT pol1289_escolhe_saida() THEN
        RETURN
    END IF

    IF NOT pol1289_le_den_empresa() THEN
        RETURN
    END IF

    LET p_comprime    = ascii 15
    LET p_descomprime = ascii 18
    LET p_6lpp        = ascii 27, "2"
    LET p_8lpp        = ascii 27, "0"

    LET p_count = 0

    DECLARE cq_impressao CURSOR FOR

    SELECT cod_empresa, num_aviso_rec, tip_frete, cod_transpor, num_placa,
           tabela, versao, val_tonelada, peso_balanca, peso_pagar, val_frete
      FROM nf_x_tab_frete_885
     WHERE cod_empresa = p_cod_empresa 
     ORDER BY num_aviso_rec

    FOREACH cq_impressao
       INTO p_nf_x_tab_frete_885.cod_empresa,
            p_nf_x_tab_frete_885.num_aviso_rec,
            p_nf_x_tab_frete_885.tip_frete,
            p_nf_x_tab_frete_885.cod_transpor,
            p_nf_x_tab_frete_885.num_placa,
            p_nf_x_tab_frete_885.tabela,
            p_nf_x_tab_frete_885.versao,
            p_nf_x_tab_frete_885.val_tonelada,
            p_nf_x_tab_frete_885.peso_balanca,
            p_nf_x_tab_frete_885.peso_pagar,
            p_nf_x_tab_frete_885.val_frete
        IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
            RETURN
        END IF

        OUTPUT TO REPORT pol1289_relat(p_nf_x_tab_frete_885.num_aviso_rec)

        LET p_count = 1

    END FOREACH

    FINISH REPORT pol1289_relat

    IF p_count = 0 THEN
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
            CALL log0030_mensagem(p_msg, 'exclamation')
        END IF
        ERROR 'Relatório gerado com sucesso !!!'
    END IF

    RETURN

END FUNCTION

#-------------------------------#
FUNCTION pol1289_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1289.tmp"
         START REPORT pol1289_relat TO p_caminho
      ELSE
         START REPORT pol1289_relat TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1289_le_den_empresa()
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

#-----------------------------------#
REPORT pol1289_relat(p_num_aviso_rec)
#-----------------------------------#

   DEFINE p_num_aviso_rec LIKE nf_x_tab_frete_885.num_aviso_rec

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   FORMAT

      PAGE HEADER

         PRINT COLUMN 002,  p_den_empresa,
               COLUMN 073, "PAG. ", PAGENO USING "####&"

         PRINT COLUMN 002, "pol1289",
               COLUMN 013, "NOTAS X TABELA DE PRECO",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 002, "-------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "Num.Aviso Rec. Frete Cod.Transp Num.Placa Tabela Versao Tonelada Balança Pagar Frete "
         PRINT
      
      ON EVERY ROW
      
         PRINT COLUMN 002, p_nf_x_tab_frete_885.num_aviso_rec USING "#########",
               COLUMN 017, p_nf_x_tab_frete_885.tip_frete, 
               COLUMN 023, p_nf_x_tab_frete_885.cod_transpor,
               COLUMN 034, p_nf_x_tab_frete_885.num_placa,
               COLUMN 044, p_nf_x_tab_frete_885.tabela,
               COLUMN 050, p_nf_x_tab_frete_885.versao,
               COLUMN 057, p_nf_x_tab_frete_885.val_tonelada USING '###,##&.&&',
               COLUMN 066, p_nf_x_tab_frete_885.peso_balanca USING '###,##&.&&',
               COLUMN 074, p_nf_x_tab_frete_885.peso_pagar USING '###,##&.&&',
               COLUMN 090, p_nf_x_tab_frete_885.val_frete USING '###,##&.&&'
               
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE
           PRINT " "
        END IF

END REPORT

#-------------------------------------#
FUNCTION pol1289_exibe_versao()
#-------------------------------------#
    
    LET p_msg = p_versao CLIPPED, "\n","\n",
                "LOGIX 10.02 ","\n","\n",
                " Home page: www.aceex.com.br","\n","\n",
                " (0xx11) 4991-6667 ","\n","\n"
                
    CALL log0030_mensagem(p_msg,"excla")
    
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
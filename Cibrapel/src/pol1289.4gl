#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1289                                                 #
# OBJETIVO: NOTAS DE NOTAS X TABELA DE PRECO                        #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 20/08/15                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
END GLOBALS

DEFINE p_nf_tab               RECORD LIKE nf_x_tab_frete_885.*,
       p_nf_tab_a             RECORD LIKE nf_x_tab_frete_885.*,
       p_cod_fornecedor       LIKE fornecedor.cod_fornecedor,
       p_raz_social           LIKE fornecedor.raz_social,
       p_num_nf               LIKE nf_sup.num_nf ,
       p_ies_especie_nf       LIKE nf_sup.ies_especie_nf,
       p_dat_emis_nf          LIKE nf_sup.dat_emis_nf,
       p_cod_transpor         LIKE clientes.cod_cliente,
       p_nom_transpor         LIKE clientes.nom_cliente,
       p_versao_tabela        LIKE tab_frete_885.versao,
       p_val_tonelada         LIKE tab_frete_885.val_tonelada, 
       p_peso_balanca         LIKE aviso_rec.qtd_recebida,
       p_tara_minima          LIKE nf_x_tab_frete_885.tara_minima,
       p_num_aviso_rec        LIKE aviso_rec.num_aviso_rec
       
DEFINE p_qtd_recebida         DECIMAL(10,3),
       p_tot_recebida         DECIMAL(10,3),
       p_cod_unid             CHAR(02),
       p_cod_item             CHAR(15),
       p_ies_apara            SMALLINT,
       p_transp_nor           CHAR(02),
       p_transp_auto          CHAR(02),
       p_cod_tip_cli          CHAR(02),
       p_den_rota             CHAR(50),
       p_tabela               CHAR(06)

DEFINE p_parametro     RECORD
       cod_empresa   CHAR(02),
       num_ar        INTEGER,
       usuario       CHAR(08),
       operacao      CHAR(10),
       programa      CHAR(10)
END RECORD

DEFINE p_tela              RECORD
       dat_ini             DATE,
       dat_fim             DATE,
       ies_situacao        CHAR(01),
       cod_transpor        CHAR(15)
END RECORD

DEFINE p_relat             RECORD
       cod_transpor        CHAR(15),   
       nom_transpor        CHAR(36),  
       dat_lancamento      DATE,   
       num_nf              INTEGER,
       num_aviso_rec       INTEGER,    
       peso_pagar          DECIMAL(10,3),       
       tabela              INTEGER,           
       versao              INTEGER,           
       val_tonelada        DECIMAL(12,2),      
       val_frete           DECIMAL(12,2)
END RECORD      
       
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1289-10.02.02  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1289_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1289_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1289") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1289 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1289_parametros() THEN
      CLOSE WINDOW w_pol1289
      RETURN
   END IF
   
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
         IF p_ies_cons AND p_nf_tab.num_aviso_rec IS NOT NULL THEN
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
         IF p_ies_cons AND p_nf_tab.num_aviso_rec IS NOT NULL THEN
            CALL pol1289_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem das baixas pendentes"
         CALL pol1289_listagem() RETURNING p_status
         CLOSE WINDOW w_pol12892
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
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

#----------------------------#
FUNCTION pol1289_parametros()#
#----------------------------#

   SELECT substring(par_vdp_txt,215,2)
     INTO p_transp_nor
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel ler parâmetro do\n',
                  'transportador na tabela par_vdp.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel ler parâmetro do\n',
                  'transportador na tabela par_vdp_pad.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

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

   CALL pol1289_limpa_tela()
   
   INITIALIZE p_nf_tab TO NULL
   
   LET p_nf_tab.cod_empresa = p_cod_empresa
   LET p_nf_tab.ies_situacao = 'A'
   LET p_nf_tab.dat_lancamento = TODAY

   DISPLAY 'ABERTO' TO den_situacao
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1289_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1289_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1289_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1289_insere()
#------------------------#
 
   INSERT INTO nf_x_tab_frete_885 VALUES (p_nf_tab.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","nf_x_tab_frete_885")       
      RETURN FALSE
   END IF
   
   IF NOT pol1289_grava_audit('INCLUIU') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1289_grava_audit(l_operacao)
#---------------------------------------#

   DEFINE l_operacao CHAR(10)

   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.num_ar = p_nf_tab.num_aviso_rec
   LET p_parametro.usuario = p_user
   LET p_parametro.operacao = l_operacao
   LET p_parametro.programa = 'POL1289'
   
   CALL func002_ins_operacao(p_parametro) RETURNING p_status
   
   RETURN p_status

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1289_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_nf_tab.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD num_aviso_rec
        
      IF p_funcao = 'M' THEN
         NEXT FIELD cod_transpor
      END IF
                
      AFTER FIELD num_aviso_rec

         IF p_nf_tab.num_aviso_rec IS NULL THEN
             ERROR "Campo com preenchimento obrigatório !!!"
             NEXT FIELD num_aviso_rec
         END IF

         SELECT COUNT(num_aviso_rec)
           INTO p_count
           FROM nf_x_tab_frete_885
          WHERE num_aviso_rec = p_nf_tab.num_aviso_rec
            AND cod_empresa = p_cod_empresa
                 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','nf_x_tab_frete_885')
            NEXT FIELD num_aviso_rec
         END IF

         IF p_count > 0 THEN
            ERROR "AR já cadastrado no pol1289 - Use a opção modificar"
            NEXT FIELD num_aviso_rec
         END IF

         IF NOT pol1289_le_nf(p_nf_tab.num_aviso_rec) THEN
            NEXT FIELD num_aviso_rec
         END IF

         IF NOT pol1289_le_recebimento() THEN
            NEXT FIELD num_aviso_rec
         END IF
         
         LET p_nf_tab.peso_balanca = p_tot_recebida     
                                                                       
         DISPLAY p_num_nf             TO num_nf                        
         DISPLAY p_ies_especie_nf     TO ies_especie_nf                
         DISPLAY p_dat_emis_nf        TO dat_emis_nf                   
         DISPLAY p_cod_fornecedor     TO cod_fornecedor                
         DISPLAY p_raz_social         TO raz_social                    
         DISPLAY p_tot_recebida       TO peso_balanca                  
                        
      AFTER FIELD cod_transpor
      
         IF p_nf_tab.cod_transpor IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_transpor
         END IF
         
         LET p_msg = NULL
         
         IF NOT pol1289_le_transp(p_nf_tab.cod_transpor) THEN
            NEXT FIELD cod_transpor
         END IF
         
         IF p_msg IS NOT NULL THEN
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD cod_transpor
         END IF
         
         DISPLAY p_nom_transpor TO nom_transpor
         
      AFTER FIELD num_placa
      
         IF p_nf_tab.num_placa IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_placa
         END IF
         
         LET p_msg = NULL
         
         IF NOT pol1289_le_placa() THEN
            NEXT FIELD num_placa
         END IF

         IF p_msg IS NOT NULL THEN
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD num_placa
         END IF
         
         DISPLAY p_nf_tab.tara_minima TO tara_minima         
         DISPLAY p_nf_tab.peso_pagar TO peso_pagar         

      AFTER FIELD cod_rota
      
         IF p_nf_tab.cod_rota IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_rota
         END IF
         
         LET p_msg = NULL
         
         IF NOT pol1289_le_tabela(p_nf_tab.cod_rota) THEN
            NEXT FIELD cod_rota
         END IF
         
         IF p_msg IS NOT NULL THEN
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD cod_rota
         END IF
         
         LET p_nf_tab.val_frete = p_nf_tab.peso_pagar * p_nf_tab.val_tonelada
         
         DISPLAY p_den_rota TO p_den_rota
         DISPLAY p_nf_tab.tabela TO tabela
         DISPLAY p_nf_tab.versao TO versao
         DISPLAY p_nf_tab.val_tonelada TO val_tonelada
         DISPLAY p_nf_tab.val_frete TO val_frete
         

      ON KEY (control-z)
         CALL pol1289_popup('E')

         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1289_le_nf(l_ar)
#---------------------------#

   DEFINE l_ar     INTEGER
   
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
      AND ns.num_aviso_rec = l_ar         
      AND ns.cod_fornecedor = f.cod_fornecedor              
                                                            
   IF STATUS <> 0 THEN                                      
      CALL log003_err_sql('SELECT','nf_sup')                
      RETURN FALSE                              
   END IF         
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1289_le_recebimento()
#--------------------------------#
                                          
   LET p_tot_recebida = 0  
   LET p_msg = NULL                                                            
                                                                                                
   DECLARE cq_qtd CURSOR FOR                                                                    
   SELECT cod_item, qtd_recebida, cod_unid_med_nf                                                         
     FROM aviso_rec ar                                                                          
    WHERE ar.cod_empresa = p_cod_empresa                                                        
      AND ar.num_aviso_rec = p_nf_tab.num_aviso_rec                                             
                                                                                                
   FOREACH cq_qtd INTO p_cod_item, p_qtd_recebida, p_cod_unid                                               
                                                                                       
      IF STATUS <> 0 THEN                                                                       
         CALL log003_err_sql('FOREACH','cq_qtd')                                                
         RETURN FALSE                                                               
      END IF      
      
      {LET p_ies_apara = FALSE
      
      IF NOT pol1289_checa_item() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_apara THEN
         LET p_msg = 'O AR informado é de aparas. Utilize\n',
                     'o módulo de estrada de aparas.'                   
         CALL log0030_mensagem(p_msg,'info')                                                 
         RETURN FALSE                                                                        
      END IF}
                                                                                                         
      IF UPSHIFT(p_cod_unid) = 'KG' THEN                                                        
         LET p_qtd_recebida = p_qtd_recebida / 1000                                             
      ELSE                                                                                      
         IF UPSHIFT(p_cod_unid) = 'TN' OR UPSHIFT(p_cod_unid) = 'TO' THEN                                                     
         ELSE                                                                                   
            LET p_msg = 'Unidade de medida da NF é inesperada: ', p_cod_unid                    
            CALL log0030_mensagem(p_msg,'info')                                                 
            RETURN FALSE                                                                        
         END IF                                                                                 
      END IF                                                                                    
                                                                                                
      LET p_tot_recebida = p_tot_recebida + p_qtd_recebida                                      
                                                                                                
   END FOREACH                                                                                  

   IF p_tot_recebida = 0 THEN
      LET p_msg = 'A quantidade recebida não é válida\n',
                  'Verifique a inspeção do AR.'
      CALL log0030_mensagem(p_msg,'info')                                                 
      RETURN FALSE                                                                        
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1289_checa_item()
#---------------------------#

   DEFINE p_cod_familia LIKE item.cod_familia
   
   SELECT cod_familia                        
     INTO p_cod_familia                         
     FROM item                                  
    WHERE cod_empresa = p_cod_empresa           
      AND cod_item = p_cod_item                                                                                 
                                             
   IF STATUS <> 0 THEN                                                                          
      CALL log003_err_sql('FOREACH','cq_qtd')                                                   
      RETURN FALSE                                                                  
   END IF         
   
   SELECT ies_apara
     FROM familia_insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND ies_apara   = 'S'
   
   IF STATUS = 0 THEN
      LET p_ies_apara = TRUE
   ELSE                                             
      IF STATUS <> 100 THEN                                                                          
         CALL log003_err_sql('FOREACH','cq_qtd')                                                   
      END IF         
   END IF
                                 
   RETURN TRUE                                                                  

END FUNCTION

#----------------------------#
 FUNCTION pol1289_popup(p_op)
#----------------------------#

   DEFINE p_codigo CHAR(15),
          p_op     CHAR(01)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)         
         
         IF p_op = 'L' THEN
            CURRENT WINDOW IS w_pol12892
            IF p_codigo IS NOT NULL THEN
               LET p_tela.cod_transpor = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_transpor
            END IF
         ELSE
            CURRENT WINDOW IS w_pol1289
            IF p_codigo IS NOT NULL THEN
               LET p_nf_tab.cod_transpor = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_transpor
            END IF
         END IF
  
      WHEN INFIELD(num_placa)
         CALL pol1289_popup_placa() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1289
         
         IF p_codigo IS NOT NULL THEN
            LET p_nf_tab.num_placa = p_codigo CLIPPED
            DISPLAY p_nf_tab.num_placa TO num_placa
         END IF

      WHEN INFIELD(cod_rota)
         CALL log009_popup(8,25,"ROTAS","rotas_885",
                     "cod_rota","den_rota","pol1297","N","") 
            RETURNING p_codigo
            
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         
         CURRENT WINDOW IS w_pol1289
         
         IF p_codigo IS NOT NULL THEN
            LET p_nf_tab.cod_rota = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_rota
         END IF

   END CASE

END FUNCTION

#-----------------------------#
FUNCTION pol1289_popup_placa()#
#-----------------------------#

    DEFINE pr_placas ARRAY[5000] OF RECORD 	
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
    
    LET p_index = 1
    
    DECLARE cq_placa CURSOR FOR 
    SELECT tp.cod_transpor,  
           cl.nom_cliente, 
           tp.num_placa
      FROM transportador_placa_885 tp, 
           clientes cl
     WHERE tp.cod_transpor = cl.cod_cliente
       AND tp.cod_transpor = p_nf_tab.cod_transpor
     ORDER BY tp.cod_transpor, cl.nom_cliente, tp.num_placa 
 
    FOREACH cq_placa INTO pr_placas[p_index].*
        
        IF STATUS <> 0 THEN
           CALL log003_err_sql('FOREACH','cq_placa')
           CLOSE WINDOW w_pol12891
           RETURN ''
        END IF
         
        LET p_index = p_index + 1
        
        IF p_index > 5000 THEN
            LET p_msg = 'Limite de grade ultrapassado !!!'
            CALL log0030_mensagem(p_msg,'exclamation')
            EXIT FOREACH
        END IF
                
    END FOREACH

    CALL SET_COUNT(p_index - 1)

    DISPLAY ARRAY pr_placas TO sr_placas.* 
    
    LET p_index = ARR_CURR()
    LET s_index = SCR_LINE()

    CLOSE WINDOW w_pol12891

    IF INT_FLAG = 0 THEN
        RETURN pr_placas[p_index].num_placa
    ELSE
        LET INT_FLAG = 0
        RETURN ''
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1289_le_transp(l_cod)
#--------------------------------#

   DEFINE l_cod        CHAR(15)
   
   SELECT nom_cliente, cod_tip_cli                                          
     INTO p_nom_transpor, p_cod_tip_cli                                                       
     FROM clientes                                                          
    WHERE cod_cliente = l_cod                                  
                                                                                
   IF STATUS = 100 THEN                                                         
       LET p_msg = 'Transportador não cadastrado.'                                    
   ELSE                                                                         
       IF STATUS <> 0 THEN                                                      
           CALL log003_err_sql('SELECT','clientes')              
           RETURN FALSE 
       END IF                                                                   
       
       IF p_cod_tip_cli = p_transp_nor OR p_cod_tip_cli = p_transp_auto THEN
          SELECT COUNT(num_placa)
            INTO p_count
            FROM transportador_placa_885
           WHERE cod_transpor = l_cod
          
          IF STATUS <> 0 THEN                                                      
             CALL log003_err_sql('SELECT','transportador_placa_885')              
             RETURN FALSE 
          END IF    
          IF p_count = 0 THEN
             LET p_msg = 'Esse transportador não tem placas\n',
                         'cadastradas no POL1287.'                                                               
          END IF
       ELSE
          LET p_msg = 'Esse código não é um transportador'
       END IF                                                                                                                          
   END IF                                                                       
                                                                            
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1289_le_placa()
#--------------------------#

   LET p_tara_minima = 0                      
                                                           
   SELECT tara_minima                                      
     INTO p_tara_minima                                    
     FROM transportador_placa_885                          
    WHERE cod_transpor = p_nf_tab.cod_transpor             
      AND num_placa    = p_nf_tab.num_placa                
                                                           
   IF STATUS = 100 THEN                                    
      LET p_msg = 'Placa não Localizada.'                       
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','transportador_placa_885')
         RETURN FALSE
      END IF
      
      SELECT cod_transpor
        FROM fornec_tara_minima_885
       WHERE cod_fornecedor = p_cod_fornecedor
         AND cod_transpor = p_nf_tab.cod_transpor  
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','fornec_tara_minima_885')
         RETURN FALSE
      ELSE
         IF STATUS = 100 THEN
            LET p_tara_minima = NULL
         END IF
      END IF
      
      LET p_nf_tab.tara_minima = p_tara_minima
      
      IF p_tara_minima IS NULL OR p_tara_minima = ' ' THEN
         LET p_nf_tab.peso_pagar = p_nf_tab.peso_balanca
      ELSE      
         IF p_tot_recebida < p_tara_minima THEN            
          	LET p_nf_tab.peso_pagar = p_tara_minima
       	 END IF
      END IF
   END IF       
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1289_le_tabela(l_cod)
#-------------------------------#
   
   DEFINE l_cod      INTEGER

   LET p_den_rota = pol1289_le_rota(l_cod)
   
   IF p_den_rota IS NULL THEN                                    
      LET p_msg = 'Rota não cadastrada no POL1297.'                       
      RETURN TRUE
   END IF
   
   SELECT tabela, versao, val_tonelada
     INTO p_nf_tab.tabela,
          p_nf_tab.versao,
          p_nf_tab.val_tonelada
     FROM tab_frete_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_rota = l_cod
      AND versao_atual = 'S'

   IF STATUS = 100 THEN                                    
      LET p_msg = 'Não há tabela de preços\n no POL1288 para essa rota.'                                       
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','transportador_placa_885')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1289_le_rota(l_cod)
#------------------------------#
   
   DEFINE l_cod      INTEGER
   
   SELECT den_rota
     INTO p_den_rota
     FROM rotas_885
    WHERE cod_rota = l_cod

   IF STATUS <> 0 THEN
      LET p_den_rota = NULL
   END IF

   RETURN p_den_rota

END FUNCTION
   

#--------------------------#
 FUNCTION pol1289_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1289_limpa_tela()
   LET p_nf_tab_a.* = p_nf_tab.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      p_nf_tab.num_aviso_rec,    
      p_nf_tab.cod_transpor,                     
      p_nf_tab.num_placa,                        
      p_nf_tab.tabela,
      p_nf_tab.ies_situacao                 

      ON KEY (control-z)
         CALL pol1289_popup('C')

   END CONSTRUCT
         
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1289_limpa_tela()
         ELSE
            LET p_nf_tab = p_nf_tab_a
            CALL pol1289_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM nf_x_tab_frete_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",                 
                  " ORDER BY num_aviso_rec "
    
   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
    
   OPEN cq_padrao
    
   FETCH cq_padrao INTO p_nf_tab.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
   ELSE
      IF STATUS = 0 THEN
         IF pol1289_exibe_dados() THEN
            LET p_ies_cons = TRUE
            RETURN TRUE
         END IF
      ELSE
         CALL log003_err_sql('FETCH','cq_padrao')
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1289_exibe_dados()
#------------------------------#

   IF NOT pol1289_le_nf(p_nf_tab.num_aviso_rec) THEN
      RETURN FALSE
   END IF

   IF NOT pol1289_le_clientes(p_nf_tab.cod_transpor) THEN
      RETURN FALSE
   END IF
   
   LET p_den_rota = pol1289_le_rota(p_nf_tab.cod_rota)
                                     
   DISPLAY BY NAME p_nf_tab.*
   
		DISPLAY p_num_nf         TO num_nf
		DISPLAY p_ies_especie_nf TO ies_especie_nf
		DISPLAY p_dat_emis_nf    TO dat_emis_nf
		DISPLAY p_cod_fornecedor TO cod_fornecedor
		DISPLAY p_raz_social     TO raz_social
    DISPLAY p_nom_transpor   TO nom_transpor
    DISPLAY p_den_rota       TO den_rota
    
    IF p_nf_tab.ies_situacao = 'A' THEN
       DISPLAY 'ABERTO' TO den_situacao
    ELSE
       DISPLAY 'FECHADO' TO den_situacao
    END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1289_le_clientes(l_cod)
#----------------------------------#
   
   DEFINE l_cod       CHAR(15)
   
   SELECT nom_cliente                                         
     INTO p_nom_transpor                                                    
     FROM clientes                                                          
    WHERE cod_cliente = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1289_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_nf_tab_a.* = p_nf_tab.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_nf_tab.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_nf_tab.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT num_aviso_rec
           FROM nf_x_tab_frete_885
          WHERE num_aviso_rec = p_nf_tab.num_aviso_rec
            AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            IF pol1289_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_transportador.* = p_transportadora.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1289_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT num_aviso_rec
      FROM nf_x_tab_frete_885
     WHERE num_aviso_rec = p_nf_tab.num_aviso_rec
       AND cod_empresa = p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","transportador_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1289_modificacao()
#-----------------------------#
      
   LET p_retorno = FALSE

   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "info")
      RETURN p_retorno
   END IF

   IF p_nf_tab.ies_situacao = 'F' THEN
      CALL log0030_mensagem("AR Fechado não pode ser modificado !!!", "info")
      RETURN p_retorno
   END IF

   LET p_nf_tab_a.* = p_nf_tab.*

   IF pol1289_prende_registro() THEN
      IF pol1289_edita_dados("M") THEN
         IF pol1289_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_nf_tab.* = p_nf_tab_a.*
         CALL pol1289_exibe_dados() RETURN p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_transportador.* = p_transportadora.*
      CALL pol1289_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol1289_atualiza()
#--------------------------#

   UPDATE nf_x_tab_frete_885
      SET nf_x_tab_frete_885.* = p_nf_tab.*
    WHERE num_aviso_rec = p_nf_tab.num_aviso_rec
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "nf_x_tab_frete_885")
      RETURN FALSE
   END IF

   IF NOT pol1289_grava_audit('ALTEROU') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1289_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "info")
      RETURN p_retorno
   END IF

   IF p_nf_tab.ies_situacao = 'F' THEN
      CALL log0030_mensagem("AR Fechado não pode ser excluído !!!", "info")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1289_prende_registro() THEN
      IF pol1289_deleta() THEN
         INITIALIZE p_nf_tab TO NULL
         CALL pol1289_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
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

#------------------------#
FUNCTION pol1289_deleta()
#------------------------#

   DELETE FROM nf_x_tab_frete_885
    WHERE num_aviso_rec = p_nf_tab.num_aviso_rec
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","nf_x_tab_frete_885")
      RETURN FALSE
   END IF

   IF NOT pol1289_grava_audit('EXCLUIU') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1289_informar()#
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12892") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12892 AT 6,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_tela.ies_situacao = 'A'
      
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 

      AFTER FIELD cod_transpor
      
         IF p_tela.cod_transpor IS NOT NULL THEN
            LET p_msg = NULL
            IF NOT pol1289_le_transp(p_tela.cod_transpor) THEN
               NEXT FIELD cod_transpor
            END IF
         END IF
         
         IF p_msg IS NOT NULL THEN
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD cod_transpor
         END IF
         
         DISPLAY p_nom_transpor TO nom_transpor
      
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
         
            IF p_tela.dat_ini IS NOT NULL THEN
               IF p_tela.dat_fim IS NOT NULL THEN
                  IF p_tela.dat_ini > p_tela.dat_fim THEN
                     ERROR 'Periodo inválido.'
                     NEXT FIELD dat_ini
                  END IF
               END IF
            END IF
         END IF
  
      ON KEY (control-z)
         CALL pol1289_popup('L')

      
   END INPUT
        
   RETURN NOT INT_FLAG

END FUNCTION

#--------------------------#
FUNCTION pol1289_listagem()#
#--------------------------#
   
   DEFINE p_chave, sql_stmt   CHAR(600),
          l_versao            CHAR(2)

   CALL pol1289_informar() RETURNING p_status
   
   IF NOT p_status THEN
      CALL pol1289_limpa_tela()
      RETURN FALSE
   END IF
   
   IF NOT pol1289_le_den_empresa() THEN
      RETURN FALSE
   END IF

   IF NOT pol1289_inicializa_relat() THEN
      RETURN FALSE
   END IF

   LET p_count = 0
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND dat_lancamento >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND dat_lancamento <= '",p_tela.dat_fim,"' "
   END IF
   
   
   IF p_tela.cod_transpor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_transpor = '",p_tela.cod_transpor,"' "
   END IF

   IF p_tela.ies_situacao <> 'T' THEN
      LET p_chave = p_chave CLIPPED, 
          " AND ies_situacao = '",p_tela.ies_situacao,"' "
   END IF

   LET sql_stmt = 
        "SELECT cod_transpor, dat_lancamento, num_aviso_rec,  ",
        " peso_pagar, tabela, versao, val_tonelada, val_frete",
        "  FROM nf_x_tab_frete_885 WHERE ",p_chave CLIPPED, 
        " ORDER BY cod_transpor, dat_lancamento "

   PREPARE var_query2 FROM sql_stmt   
   DECLARE cq_relat CURSOR FOR var_query2
   
   FOREACH cq_relat INTO 
      p_relat.cod_transpor,
      p_relat.dat_lancamento,
      p_relat.num_aviso_rec,
      p_relat.peso_pagar,
      p_relat.tabela,
      p_relat.versao,
      p_relat.val_tonelada,
      p_relat.val_frete
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_relat')
         EXIT FOREACH
      END IF
      
      LET p_tabela = p_relat.tabela USING '<<<<<'
      LET l_versao = p_relat.versao USING '<<'
      LET p_tabela = p_tabela CLIPPED, '/', l_versao
      
      SELECT num_nf
        INTO p_relat.num_nf
        FROM nf_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_relat.num_aviso_rec 

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','nf_sup')
         EXIT FOREACH
      END IF
                  
      OUTPUT TO REPORT pol1289_relat(p_relat.cod_transpor)
      
      LET p_count = p_count + 1
   
   END FOREACH

   CALL pol1289_finaliza_relat()
   CALL log0030_mensagem(p_msg, 'excla')
   
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

#----------------------------------#
FUNCTION pol1289_inicializa_relat()#
#----------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1289_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1289.tmp' 
         START REPORT pol1289_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1289_relat TO p_nom_arquivo
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1289_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1289_relat
   
   IF p_count = 0 THEN
      LET p_msg = "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF
     
END FUNCTION 

#------------------------------------#
 REPORT pol1289_relat(l_cod_transpor)#
#------------------------------------#
    
   DEFINE l_cod_transpor        CHAR(15)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
     
      ORDER EXTERNAL BY l_cod_transpor          
   
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 046, 'FRETE DE ENTRADA',
               COLUMN 073, 'PAG:', PAGENO USING '##&'
         PRINT COLUMN 001, 'POL1289             PERIODO:',
               COLUMN 030, p_tela.dat_ini USING 'dd/mm/yyyy',
               COLUMN 41, '-',
               COLUMN 043, p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 062, 'EMISSAO:',
               COLUMN 071, TODAY
         PRINT '--------------------------------------------------------------------------------'
        
      PAGE HEADER
	  
         PRINT COLUMN 001,  'Transportador: ', l_cod_transpor, ' - ', p_relat.nom_transpor,
               COLUMN 073, 'PAG:', PAGENO USING '##&'
         PRINT
         PRINT COLUMN 001, 'DATA        NOTA     PESO     TABELA VAL TON VALOR FRETE'
         PRINT COLUMN 001, '---------- ------ ----------- ------ ------- ------------'

      BEFORE GROUP OF l_cod_transpor

         SELECT nom_cliente
           INTO p_relat.nom_transpor
           FROM clientes
          WHERE cod_cliente = l_cod_transpor
      
         IF STATUS <> 0 THEN
            LET p_relat.nom_transpor = ''
         END IF
         
         PRINT
         PRINT COLUMN 001,  'Transportador: ', l_cod_transpor, ' - ', p_relat.nom_transpor
         PRINT
         PRINT COLUMN 001, 'DATA        NOTA     PESO     TABELA VAL TON VALOR FRETE'
         PRINT COLUMN 001, '---------- ------ ----------- ------ ------- ------------'
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.dat_lancamento,
               COLUMN 012, p_relat.num_nf USING '#####&',
               COLUMN 019, p_relat.peso_pagar USING '######&.&&&',
               COLUMN 031, p_tabela,
               COLUMN 038, p_relat.val_tonelada USING '###&.&&',
               COLUMN 046, p_relat.val_frete USING '#,###,##&.&&'

      AFTER GROUP OF l_cod_transpor
         
         PRINT
         PRINT COLUMN 022, 'Total do transportador:',
               COLUMN 046, GROUP SUM(p_relat.val_frete) USING '#,###,##&.&&'
         PRINT
                                             
      ON LAST ROW

         PRINT
         PRINT COLUMN 033, 'Total geral:',
               COLUMN 046, SUM(p_relat.val_frete) USING '#,###,##&.&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT




#-------------------------------- FIM DE PROGRAMA BL-----------------------------#

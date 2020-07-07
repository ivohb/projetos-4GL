#-------------------------------------------------------------------#
# PROGRAMA: pol0739                                                 #
# MODULOS.: pol0739-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE FICHA TÉCNICA - TORO                        #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 18/02/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_raz_social         LIKE fornecedor.raz_social,
          p_den_item           LIKE item.den_item,
          p_nom_item_reduz     LIKE item.den_item_reduz,
          p_cod_fornecedor     LIKE item_ppte_159.cod_fornecedor,
          p_cod_item           LIKE item_ppte_159.cod_item,
          p_user               LIKE usuario.nom_usuario,
          p_ies_den_mat_prima  CHAR(01),
          p_ies_comprimento    CHAR(01),
          p_ies_tol_compr      CHAR(01),
          p_ies_largura        CHAR(01),
          p_ies_tol_largura    CHAR(01),
          p_ies_espessura      CHAR(01),
          p_ies_tol_espessura  CHAR(01),
          p_ies_gramatura      CHAR(01),
          p_ies_gramatura_min  CHAR(01),
          p_ies_gramatura_max  CHAR(01),
          p_ies_peso           CHAR(01),
          p_ies_peso_min       CHAR(01),
          p_ies_peso_max       CHAR(01),
          p_ies_lado_corte     CHAR(01), 
          p_ies_compr_lamina   CHAR(01),
          p_ies_largura_lamina CHAR(01),
          p_ies_batidas_hora   CHAR(01),
          p_ies_cavidade       CHAR(01),
          p_ies_qtd_pecas_emb  CHAR(01),
          p_ies_qtd_etiq_emb   CHAR(01),
          p_ies_pecas_pacote   CHAR(01),
          p_ies_area_aplicacao CHAR(01),
          p_ies_alt_aplicacao  CHAR(01),
          p_ies_tol_resina     CHAR(01),
          p_ies_fornecedor     CHAR(01),
          p_ies_cod_tip_mat    CHAR(01),
          p_ies_observacao     CHAR(01),
          p_ies_dia_validade   CHAR(01),
          p_ies_den_mat_prima1 CHAR(01),
          p_ies_comprimento1   CHAR(01),
          p_ies_tol_compr1     CHAR(01),
          p_ies_largura1       CHAR(01),
          p_ies_tol_largura1   CHAR(01),
          p_ies_espessura1     CHAR(01),
          p_ies_tol_espessura1 CHAR(01),
          p_ies_gramatura1     CHAR(01),
          p_ies_gramatura_min1 CHAR(01),
          p_ies_gramatura_max1 CHAR(01),
          p_ies_peso1          CHAR(01),
          p_ies_peso_min1      CHAR(01),
          p_ies_peso_max1      CHAR(01),
          p_ies_lado_corte1    CHAR(01), 
          p_ies_compr_lamina1  CHAR(01),
          p_ies_largura_lamina1 CHAR(01),
          p_ies_batidas_hora1  CHAR(01),
          p_ies_cavidade1      CHAR(01),
          p_ies_qtd_pecas_emb1 CHAR(01),
          p_ies_qtd_etiq_emb1  CHAR(01),
          p_ies_pecas_pacote1  CHAR(01),
          p_ies_area_aplicacao1 CHAR(01),
          p_ies_alt_aplicacao1 CHAR(01),
          p_ies_tol_resina1    CHAR(01),
          p_ies_cod_tip_mat1   CHAR(01),
          p_ies_observacao1    CHAR(01),
          p_ies_dia_validade1  CHAR(01),
          p_ies_fornecedor1    CHAR(01),
          p_den_mat_prima      CHAR(76),
          p_comprimento        INTEGER,
          p_tol_compr          DECIMAL(10,2),
          p_largura            INTEGER,
          p_tol_largura        DECIMAL(10,2),
          p_espessura          INTEGER,
          p_tol_espessura      DECIMAL(10,2),
          p_gramatura          INTEGER,
          p_gramatura_min      INTEGER,
          p_gramatura_max      INTEGER,
          p_peso               INTEGER,
          p_peso_min           INTEGER,
          p_peso_max           INTEGER,
          p_lado_corte         CHAR(10), 
          p_compr_lamina       INTEGER,
          p_largura_lamina     INTEGER,
          p_batidas_hora       INTEGER,
          p_cavidade           INTEGER,
          p_qtd_pecas_emb      INTEGER,
          p_qtd_etiq_emb       INTEGER,
          p_pecas_pacote       INTEGER,
          p_area_aplicacao     DECIMAL(10,2),
          p_alt_aplicacao      DECIMAL(10,2),
          p_tol_resina         DECIMAL(10,2),
          p_cod_tip_mat        DECIMAL(3,0),
          p_observacao         CHAR(75),
          p_tipo_material      CHAR(15),
          p_dia_validade       INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_cont               SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_campo              CHAR(10),
          p_data               DATE,
          p_hora               CHAR(08),
          p_texto              CHAR(200),
          p_texto1             CHAR(200),
          p_texto2             CHAR(200),
          p_texto3             CHAR(200),
          p_texto4             CHAR(200),
          p_texto5             CHAR(200),
          p_texto6             CHAR(200),
          p_texto7             CHAR(200),
          p_texto8             CHAR(200),
          p_texto9             CHAR(200),
          p_texto10            CHAR(200),
          p_texto11            CHAR(200),
          p_texto12            CHAR(200),
          p_texto13            CHAR(200),
          p_texto14            CHAR(200),
          p_texto15            CHAR(200),
          p_texto16            CHAR(200),
          p_texto17            CHAR(200),
          p_texto18            CHAR(200),
          p_texto19            CHAR(200),
          p_texto20            CHAR(200),
          p_texto21            CHAR(200),
          p_texto22            CHAR(200),
          p_texto23            CHAR(200),
          p_texto24            CHAR(200),
          p_texto25            CHAR(200),
          p_texto26            CHAR(200),
          p_texto27            CHAR(200),
          p_texto28            CHAR(200),
          p_tex                CHAR(70),
          p_cont1              SMALLINT, 
          p_cont2              SMALLINT,
          p_cont3              SMALLINT,
          p_cont4              SMALLINT,
          p_cont5              SMALLINT,
          p_cont6              SMALLINT,
          p_cont7              SMALLINT,
          p_cont8              SMALLINT,
          p_cont9              SMALLINT,
          p_cont10             SMALLINT,
          p_cont11             SMALLINT,
          p_cont12             SMALLINT,
          p_cont13             SMALLINT,
          p_cont14             SMALLINT,
          p_cont15             SMALLINT,
          p_cont16             SMALLINT,
          p_cont17             SMALLINT,
          p_cont18             SMALLINT,
          p_cont19             SMALLINT,
          p_cont20             SMALLINT,
          p_cont21             SMALLINT,
          p_cont22             SMALLINT,
          p_cont23             SMALLINT,
          p_cont24             SMALLINT,
          p_cont25             SMALLINT,
          p_cont26             SMALLINT,
          p_cont27             SMALLINT,
          p_cont28             SMALLINT,
          p_contador           SMALLINT, 
          p_contador1          SMALLINT, 
          p_contador2          SMALLINT,
          p_contador3          SMALLINT,
          p_contador4          SMALLINT,
          p_contador5          SMALLINT,
          p_contador6          SMALLINT,
          p_contador7          SMALLINT,
          p_contador8          SMALLINT,
          p_contador9          SMALLINT,
          p_contador10         SMALLINT,
          p_contador11         SMALLINT,
          p_contador12         SMALLINT,
          p_contador13         SMALLINT,
          p_contador14         SMALLINT,
          p_contador15         SMALLINT,
          p_contador16         SMALLINT,
          p_contador17         SMALLINT,
          p_contador18         SMALLINT,
          p_contador19         SMALLINT,
          p_contador20         SMALLINT,
          p_contador21         SMALLINT,
          p_contador22         SMALLINT,
          p_contador23         SMALLINT,
          p_contador24         SMALLINT,
          p_contador25         SMALLINT,
          p_contador26         SMALLINT,
          p_contador27         SMALLINT,
          p_contador28         SMALLINT,
          ans                  CHAR(01),
          p_msg                CHAR(500)
          
   DEFINE p_item_ppte_159       RECORD LIKE item_ppte_159.*,
          p_item_ppte_159a      RECORD LIKE item_ppte_159.*
          
           
   DEFINE p_item_ppte_req_159   RECORD LIKE item_ppte_req_159.*,
          p_item_ppte_req_159a  RECORD LIKE item_ppte_req_159.* 
          
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0739-10.02.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0739.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0739_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0739_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0739") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0739 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0739_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0739_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0739_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0739_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0739_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0739_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    	 CALL pol0739_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0739

END FUNCTION

#--------------------------#
 FUNCTION pol0739_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_item_ppte_159.* TO NULL
   LET p_item_ppte_159.cod_empresa = p_cod_empresa

   IF pol0739_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO item_ppte_159 VALUES (p_item_ppte_159.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
      ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0739_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0739

     INITIALIZE p_ies_den_mat_prima1  TO NULL 
     INITIALIZE p_ies_comprimento1    TO NULL   
     INITIALIZE p_ies_tol_compr1      TO NULL    
     INITIALIZE p_ies_largura1        TO NULL       
     INITIALIZE p_ies_tol_largura1    TO NULL   
     INITIALIZE p_ies_espessura1      TO NULL    
     INITIALIZE p_ies_tol_espessura1  TO NULL
     INITIALIZE p_ies_gramatura1      TO NULL    
     INITIALIZE p_ies_gramatura_min1  TO NULL
     INITIALIZE p_ies_gramatura_max1  TO NULL
     INITIALIZE p_ies_peso1           TO NULL         
     INITIALIZE p_ies_peso_min1       TO NULL     
     INITIALIZE p_ies_peso_max1       TO NULL     
     INITIALIZE p_ies_lado_corte1     TO NULL   
     INITIALIZE p_ies_compr_lamina1   TO NULL 
     INITIALIZE p_ies_largura_lamina1 TO NULL
     INITIALIZE p_ies_batidas_hora1   TO NULL  
     INITIALIZE p_ies_cavidade1       TO NULL      
     INITIALIZE p_ies_qtd_pecas_emb1  TO NULL 
     INITIALIZE p_ies_qtd_etiq_emb1   TO NULL  
     INITIALIZE p_ies_pecas_pacote1   TO NULL  
     INITIALIZE p_ies_area_aplicacao1 TO NULL
     INITIALIZE p_ies_alt_aplicacao1  TO NULL
     INITIALIZE p_ies_tol_resina1     TO NULL
     INITIALIZE p_ies_cod_tip_mat1    TO NULL
     INITIALIZE p_ies_observacao1     TO NULL 
     INITIALIZE p_ies_fornecedor1     TO NULL 
     INITIALIZE p_ies_dia_validade1   TO NULL 
     
      LET p_cont = 0
      LET p_cont1 = 0    
      LET p_cont2 = 0      
      LET p_cont3 = 0        
      LET p_cont4 = 0    
      LET p_cont5 = 0      
      LET p_cont6 = 0  
      LET p_cont7 = 0      
      LET p_cont8 = 0  
      LET p_cont9 = 0  
      LET p_cont10 = 0           
      LET p_cont11 = 0       
      LET p_cont12 = 0       
      LET p_cont13 = 0      
      LET p_cont14 = 0   
      LET p_cont15 = 0 
      LET p_cont16 = 0   
      LET p_cont17 = 0       
      LET p_cont18 = 0  
      LET p_cont19 = 0   
      LET p_cont20 = 0   
      LET p_cont21 = 0 
      LET p_cont22 = 0 
      LET p_cont23 = 0     
      LET p_cont24 = 0    
      LET p_cont25 = 0     
      LET p_cont26 = 0  
      LET p_cont27 = 0
      LET p_cont28 = 0
      
      LET p_contador = 0
      LET p_contador1 = 0    
      LET p_contador2 = 0      
      LET p_contador3 = 0        
      LET p_contador4 = 0    
      LET p_contador5 = 0      
      LET p_contador6 = 0  
      LET p_contador7 = 0      
      LET p_contador8 = 0  
      LET p_contador9 = 0  
      LET p_contador10 = 0           
      LET p_contador11 = 0       
      LET p_contador12 = 0       
      LET p_contador13 = 0      
      LET p_contador14 = 0   
      LET p_contador15 = 0 
      LET p_contador16 = 0   
      LET p_contador17 = 0       
      LET p_contador18 = 0  
      LET p_contador19 = 0   
      LET p_contador20 = 0   
      LET p_contador21 = 0 
      LET p_contador22 = 0 
      LET p_contador23 = 0     
      LET p_contador24 = 0    
      LET p_contador25 = 0     
      LET p_contador26 = 0  
      LET p_contador27 = 0
      LET p_contador28 = 0

  INPUT BY NAME p_item_ppte_159.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_mat_prima
      END IF 
      
      
    AFTER FIELD cod_item
    IF p_item_ppte_159.cod_item IS NULL THEN 
        ERROR "Campo com preenchimento obrigatório !!!"
        NEXT FIELD cod_item
      ELSE 
        SELECT den_item
        INTO p_den_item
        FROM item
        WHERE cod_item    = p_item_ppte_159.cod_item 
          AND cod_empresa = p_cod_empresa

          IF SQLCA.sqlcode <> 0 THEN
             ERROR "Codigo do Item nao Cadastrado na Tabela ITEM !!!" 
             NEXT FIELD cod_item
          END IF
               
        SELECT c.cod_grp_ctr_estoq 
        FROM  item a, item_ppte_req_159 c
        WHERE a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		    AND   a.cod_empresa   = c.cod_empresa
        AND   a.cod_item = p_item_ppte_159.cod_item
        AND  c.cod_empresa = p_cod_empresa
            
         IF STATUS <> 0 THEN
            ERROR "Parametros Do Grupo Do Item Não Cadastrado No POL0743!!!" 
            NEXT FIELD cod_item
         END IF
               
            SELECT cod_item
            FROM item_ppte_159
            WHERE cod_item = p_item_ppte_159.cod_item
			        AND   cod_empresa = p_cod_empresa
			  
            
          IF STATUS = 0 THEN 
            ERROR "Item Ja Cadastrado"
            NEXT FIELD cod_item
          END IF    
               
         DISPLAY p_item_ppte_159.cod_item TO cod_item         
         DISPLAY p_den_item TO den_item 

                                 
           SELECT ies_den_mat_prima,
                  ies_comprimento,    
                  ies_tol_compr,      
                  ies_largura,        
                  ies_tol_largura,    
                  ies_espessura,      
                  ies_tol_espessura,  
                  ies_gramatura,      
                  ies_gramatura_min,  
                  ies_gramatura_max,  
                  ies_peso,           
                  ies_peso_min,       
                  ies_peso_max,       
                  ies_lado_corte,      
                  ies_compr_lamina,   
                  ies_largura_lamina, 
                  ies_batidas_hora,   
                  ies_cavidade,       
                  ies_qtd_pecas_emb,  
                  ies_qtd_etiq_emb,   
                  ies_pecas_pacote,   
                  ies_area_aplicacao, 
                  ies_alt_aplicacao, 
                  ies_tol_resina,     
                  ies_cod_tip_mat,    
                  ies_observacao, 
                  ies_fornecedor,    
                  ies_dia_validade   
            INTO
                  p_ies_den_mat_prima1,
                  p_ies_comprimento1,    
                  p_ies_tol_compr1,      
                  p_ies_largura1,        
                  p_ies_tol_largura1,    
                  p_ies_espessura1,      
                  p_ies_tol_espessura1,  
                  p_ies_gramatura1,      
                  p_ies_gramatura_min1,  
                  p_ies_gramatura_max1,  
                  p_ies_peso1,           
                  p_ies_peso_min1,       
                  p_ies_peso_max1,       
                  p_ies_lado_corte1,      
                  p_ies_compr_lamina1,   
                  p_ies_largura_lamina1, 
                  p_ies_batidas_hora1,   
                  p_ies_cavidade1,       
                  p_ies_qtd_pecas_emb1,  
                  p_ies_qtd_etiq_emb1,   
                  p_ies_pecas_pacote1,   
                  p_ies_area_aplicacao1, 
                  p_ies_alt_aplicacao1, 
                  p_ies_tol_resina1,     
                  p_ies_cod_tip_mat1,    
                  p_ies_observacao1, 
                  p_ies_fornecedor1,    
                  p_ies_dia_validade1    
           FROM   item a, item_ppte_req_159 c
           WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		   AND    a.cod_empresa   = c.cod_empresa
           AND    a.cod_item = p_item_ppte_159.cod_item
           AND    c.cod_empresa = p_cod_empresa
      
 
  IF p_ies_den_mat_prima1 =   'S' THEN
     LET p_cont1 = 1
  END IF  
  
  IF  p_ies_comprimento1 =    'S' THEN
     LET p_cont2 = 1
  END IF  
  
  IF  p_ies_tol_compr1 =      'S' THEN
     LET p_cont3 = 1
  END IF  
  
  IF p_ies_largura1 =         'S' THEN
     LET p_cont4 = 1
  END IF  
  
  IF  p_ies_tol_largura1 =    'S' THEN
     LET p_cont5 = 1
  END IF  
  
  IF  p_ies_espessura1 =      'S' THEN
     LET p_cont6 = 1
  END IF  
  
  IF  p_ies_tol_espessura1 =  'S' THEN
     LET p_cont7 = 1
  END IF  
  
  IF  p_ies_gramatura1 =      'S' THEN
     LET p_cont8 = 1
  END IF  
  
  IF  p_ies_gramatura_min1 =  'S' THEN
     LET p_cont9 = 1
  END IF  
  
  IF  p_ies_gramatura_max1 =  'S' THEN
     LET p_cont10 = 1
  END IF  
  
  IF  p_ies_peso1 =           'S' THEN
     LET p_cont11 = 1
  END IF  
  
  IF   p_ies_peso_min1 =      'S' THEN
     LET p_cont12 = 1
  END IF  
  
  IF  p_ies_peso_max1 =       'S' THEN
     LET p_cont13 = 1
  END IF  
  
  IF   p_ies_lado_corte1 =    'S' THEN
     LET p_cont14 = 1
  END IF  
  
  IF  p_ies_compr_lamina1 =   'S' THEN
     LET p_cont15 = 1
  END IF  
  
  IF   p_ies_largura_lamina1 ='S' THEN
     LET p_cont16 = 1
  END IF 
   
  IF  p_ies_batidas_hora1 =   'S' THEN
     LET p_cont17 = 1
  END IF 
   
  IF   p_ies_cavidade1 =      'S' THEN
     LET p_cont18 = 1
  END IF 
   
  IF   p_ies_qtd_pecas_emb1 = 'S' THEN
     LET p_cont19 = 1
  END IF  
  
  IF   p_ies_qtd_etiq_emb1 =  'S' THEN
     LET p_cont20 = 1
  END IF  
  
  IF   p_ies_pecas_pacote1 =  'S' THEN
     LET p_cont21 = 1
  END IF  
  
  IF   p_ies_area_aplicacao1 ='S' THEN
     LET p_cont22 = 1
  END IF  
  
  IF   p_ies_alt_aplicacao1 = 'S' THEN
     LET p_cont23 = 1
  END IF  
  
  IF   p_ies_tol_resina1 =    'S' THEN
     LET p_cont24 = 1
  END IF  
  
  IF   p_ies_cod_tip_mat1 =   'S' THEN
     LET p_cont25 = 1
  END IF  
  
  IF   p_ies_observacao1 =    'S' THEN
     LET p_cont26 = 1
  END IF  

  IF   p_ies_dia_validade1 =  'S' THEN
     LET p_cont27 = 1
  END IF  

  IF   p_ies_fornecedor1 =    'S' THEN
     LET p_cont28 = 1
  END IF  
    
  LET p_cont = p_cont1 + p_cont2 + p_cont3 + p_cont4 + p_cont5 + p_cont6 + p_cont7 + p_cont8 + p_cont9 + p_cont10 + p_cont11 + p_cont12 + p_cont13 + p_cont14 + p_cont15 + p_cont16 + p_cont17 + p_cont18 + p_cont19 + p_cont20 + p_cont21 + p_cont22 + p_cont23 + p_cont24 + p_cont25 + p_cont26 + p_cont27 + p_cont28
           NEXT FIELD cod_fornecedor
     END IF 

   BEFORE FIELD cod_fornecedor           
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN 
          SELECT c.ies_fornecedor
          INTO   p_ies_fornecedor
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa

        IF p_ies_fornecedor = 'N' THEN  
          NEXT FIELD den_mat_prima
        END IF
     END IF
             
    AFTER FIELD cod_fornecedor
           LET p_contador28 = 1
    LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28     
        IF p_item_ppte_159.cod_fornecedor IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD cod_fornecedor 
         
     ELSE 
        SELECT raz_social
         INTO p_raz_social
         FROM fornecedor
         WHERE cod_fornecedor = p_item_ppte_159.cod_fornecedor
         
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Item nao Cadastrado na Tabela FORNECEDOR !!!" 
            NEXT FIELD cod_fornecedor
         END IF       
         
            SELECT cod_item,cod_fornecedor
            FROM item_ppte_159
            WHERE cod_item = p_item_ppte_159.cod_item 
			AND   cod_empresa = p_cod_empresa
            AND cod_fornecedor   = p_item_ppte_159.cod_fornecedor 
         
      IF STATUS = 0 THEN
            ERROR "Código do ITEM/FORNECEDOR já Cadastrada na Tabela item_ppte_159 !!!"
            NEXT FIELD cod_fornecedor
      END IF         
      
            DISPLAY p_item_ppte_159.cod_fornecedor TO cod_fornecedor         
            DISPLAY p_raz_social TO raz_social
    END IF 
           
   BEFORE FIELD den_mat_prima           
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN 
          SELECT c.ies_den_mat_prima
          INTO   p_ies_den_mat_prima
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
          
        IF p_ies_den_mat_prima = 'N' THEN  
          NEXT FIELD comprimento
        END IF
     END IF   
          
    AFTER FIELD den_mat_prima
           LET p_contador1 = 1
    LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28     
        IF p_item_ppte_159.den_mat_prima IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD den_mat_prima  
        END IF  
          

   BEFORE FIELD comprimento
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_comprimento
          INTO   p_ies_comprimento
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_comprimento = 'N' THEN
           NEXT FIELD tol_compr
        END IF 
     END IF 
          
   AFTER FIELD comprimento
           LET p_contador2 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28         
        IF p_item_ppte_159.comprimento IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD comprimento 
        END IF  
          
          
   BEFORE FIELD tol_compr
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_tol_compr
          INTO   p_ies_tol_compr
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_tol_compr = 'N' THEN
           NEXT FIELD largura
        END IF 
     END IF 
          
   AFTER FIELD tol_compr
           LET p_contador3 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.tol_compr IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD tol_compr  
        END IF
          
          
   BEFORE FIELD largura
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_largura
          INTO   p_ies_largura
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_largura = 'N' THEN
          NEXT FIELD tol_largura
        END IF 
     END IF 
          
          AFTER FIELD largura
           LET p_contador4 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.largura IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD largura 
        END IF 
          
  BEFORE FIELD tol_largura
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_tol_largura
          INTO   p_ies_tol_largura
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_tol_largura = 'N' THEN
          NEXT FIELD espessura
        END IF 
     END IF 
           
         AFTER FIELD tol_largura
           LET p_contador5 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.tol_largura IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD tol_largura 
        END IF 
        
           
  BEFORE FIELD espessura
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_espessura
          INTO   p_ies_espessura
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_espessura = 'N' THEN
          NEXT FIELD tol_espessura
        END IF 
     END IF 
          
        AFTER FIELD espessura
           LET p_contador6 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.espessura IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD espessura 
        END IF 
        
          
  BEFORE FIELD tol_espessura
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_tol_espessura
          INTO   p_ies_tol_espessura
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_tol_espessura = 'N' THEN
          NEXT FIELD gramatura
      END IF 
    END IF 
          
         AFTER FIELD tol_espessura
           LET p_contador7 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.tol_espessura IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD tol_espessura 
        END IF 
          
  BEFORE FIELD gramatura
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_gramatura
          INTO   p_ies_gramatura
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_gramatura = 'N' THEN
          NEXT FIELD gramatura_min
        END IF 
     END IF 
          
         AFTER FIELD gramatura
           LET p_contador8 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.gramatura IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD gramatura
        END IF 
          
  BEFORE FIELD gramatura_min
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
     IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_gramatura_min
          INTO   p_ies_gramatura_min
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_gramatura_min = 'N' THEN
          NEXT FIELD gramatura_max
        END IF 
     END IF 
          
         AFTER FIELD gramatura_min
           LET p_contador9 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.gramatura_min IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD gramatura_min 
        END IF 
          
  BEFORE FIELD gramatura_max
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_gramatura_max
          INTO   p_ies_gramatura_max
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_gramatura_max = 'N' THEN
          NEXT FIELD peso
        END IF 
    END IF 
          
         AFTER FIELD gramatura_max
           LET p_contador10 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.gramatura_max IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD gramatura_max  
        END IF 
          
  BEFORE FIELD peso
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_peso
          INTO   p_ies_peso
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_peso = 'N' THEN
          NEXT FIELD peso_min
        END IF 
   END IF 
          
         AFTER FIELD peso
           LET p_contador11 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.peso IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD peso  
        END IF 
          
  BEFORE FIELD peso_min
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN  
          SELECT c.ies_peso_min
          INTO   p_ies_peso_min
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item   
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_peso_min = 'N' THEN
          NEXT FIELD peso_max
        END IF 
   END IF 
          
         AFTER FIELD peso_min
           LET p_contador12 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.peso_min IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD peso_min
         END IF 
          
   BEFORE FIELD peso_max  
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_peso_max
          INTO   p_ies_peso_max
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
        IF p_ies_peso_max = 'N' THEN
          NEXT FIELD lado_corte
        END IF 
   END IF 
          
         AFTER FIELD peso_max 
           LET p_contador13 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.peso_max  IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD peso_max  
        END IF 
          
  BEFORE FIELD lado_corte
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_lado_corte
          INTO   p_ies_lado_corte
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_lado_corte = 'N' THEN
          NEXT FIELD compr_lamina
      END IF 
  END IF 
          
         AFTER FIELD lado_corte
           LET p_contador14 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.lado_corte IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD lado_corte 
        END IF 
          
  BEFORE FIELD compr_lamina
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_compr_lamina
          INTO   p_ies_compr_lamina
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
     IF p_ies_compr_lamina = 'N' THEN
          NEXT FIELD largura_lamina
     END IF 
  END IF 
          
         AFTER FIELD compr_lamina
           LET p_contador15 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.compr_lamina IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD compr_lamina  
        END IF 
          
  BEFORE FIELD largura_lamina
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_largura_lamina
          INTO   p_ies_largura_lamina
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
       IF p_ies_largura_lamina = 'N' THEN
          NEXT FIELD batidas_hora
       END IF 
   END IF 
          
         AFTER FIELD largura_lamina
           LET p_contador16 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.largura_lamina IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD largura_lamina 
        END IF 
          
   BEFORE FIELD batidas_hora
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_batidas_hora
          INTO   p_ies_batidas_hora
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_batidas_hora = 'N' THEN
         NEXT FIELD cavidade
      END IF 
   END IF 
          
         AFTER FIELD batidas_hora
           LET p_contador17 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.batidas_hora IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD batidas_hora  
        END IF 
          
  BEFORE FIELD cavidade
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_cavidade
          INTO   p_ies_cavidade
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
       IF p_ies_cavidade = 'N' THEN
          NEXT FIELD pecas_pacote
       END IF 
    END IF 
          
         AFTER FIELD cavidade
           LET p_contador18 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.cavidade IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD cavidade 
        END IF 

  BEFORE FIELD pecas_pacote
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_pecas_pacote
          INTO   p_ies_pecas_pacote
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
       IF p_ies_pecas_pacote = 'N' THEN
          NEXT FIELD area_aplicacao
       END IF 
    END IF 
          
         AFTER FIELD pecas_pacote
           LET p_contador19 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.pecas_pacote IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD pecas_pacote
        END IF 
          
  BEFORE FIELD area_aplicacao
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_area_aplicacao
          INTO   p_ies_area_aplicacao
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_area_aplicacao = 'N' THEN
          NEXT FIELD alt_aplicacao
      END IF 
   END IF 
          
         AFTER FIELD area_aplicacao
           LET p_contador20 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.area_aplicacao IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD area_aplicacao 
        END IF 
          
   BEFORE FIELD alt_aplicacao
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_alt_aplicacao
          INTO   p_ies_alt_aplicacao
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_alt_aplicacao = 'N' THEN
          NEXT FIELD tol_resina
      END IF 
   END IF 
          
         AFTER FIELD alt_aplicacao
           LET p_contador21 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.alt_aplicacao IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD alt_aplicacao  
        END IF 
          
  BEFORE FIELD tol_resina
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_tol_resina
          INTO   p_ies_tol_resina
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_tol_resina = 'N' THEN
          NEXT FIELD cod_tip_mat
      END IF 
    END IF 
          
         AFTER FIELD tol_resina
           LET p_contador22 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.tol_resina IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD tol_resina 
        END IF 
          
  BEFORE FIELD cod_tip_mat
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_cod_tip_mat
          INTO   p_ies_cod_tip_mat
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
     IF p_ies_cod_tip_mat = 'N' THEN
          NEXT FIELD dia_validade
     END IF 
   END IF 
          
         AFTER FIELD cod_tip_mat
           LET p_contador23 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.cod_tip_mat IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD cod_tip_mat  
        END IF 


  BEFORE FIELD dia_validade
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
              
    IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_dia_validade
          INTO   p_ies_dia_validade
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
      IF p_ies_dia_validade = 'N' THEN
         NEXT FIELD qtd_pecas_emb
      END IF 
  END IF 
         
        AFTER FIELD dia_validade
           LET p_contador24 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.dia_validade IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD dia_validade
        END IF 

          
  BEFORE FIELD qtd_pecas_emb    
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
  IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_qtd_pecas_emb
          INTO   p_ies_qtd_pecas_emb
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
    IF p_ies_qtd_pecas_emb = 'N' THEN
          NEXT FIELD qtd_etiq_emb
    END IF 
  END IF 
          
         AFTER FIELD qtd_pecas_emb
           LET p_contador25 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.qtd_pecas_emb IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD qtd_pecas_emb  
        END IF 
          
  BEFORE FIELD qtd_etiq_emb
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_qtd_etiq_emb
          INTO   p_ies_qtd_etiq_emb
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
     IF p_ies_qtd_etiq_emb = 'N' THEN
          NEXT FIELD observacao
     END IF 
  END IF 
          
         AFTER FIELD qtd_etiq_emb
           LET p_contador26 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.qtd_etiq_emb IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD qtd_etiq_emb 
        END IF 
          

          
  BEFORE FIELD observacao
          SELECT c.cod_grp_ctr_estoq 
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
            
   IF SQLCA.sqlcode = 0 THEN
          SELECT c.ies_observacao
          INTO   p_ies_observacao
          FROM   item a, item_ppte_req_159 c
          WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		  AND    a.cod_empresa   = c.cod_empresa
          AND    a.cod_item = p_item_ppte_159.cod_item
          AND    c.cod_empresa = p_cod_empresa
     IF p_ies_observacao = 'N' THEN
         NEXT FIELD tipo_material
          
     END IF 
   END IF 
         
        AFTER FIELD observacao
           LET p_contador27 = 1
           LET p_contador = p_contador1 + p_contador2 + p_contador3 + p_contador4 + p_contador5 + p_contador6 + p_contador7 + p_contador8 + p_contador9 + p_contador10 + p_contador11 + p_contador12 + p_contador13 + p_contador14 + p_contador15 + p_contador16 + p_contador17 + p_contador18 + p_contador19 + p_contador20 + p_contador21 + p_contador22 + p_contador23 + p_contador24 + p_contador25 + p_contador26 + p_contador27 + p_contador28      
        IF p_item_ppte_159.observacao IS NULL THEN   
           ERROR "CAMPO COM PREENCHIMENTO OBRIGATORIO"
           NEXT FIELD observacao
        END IF 
        
     AFTER INPUT 
                SELECT ies_den_mat_prima,
                  ies_comprimento,    
                  ies_tol_compr,      
                  ies_largura,        
                  ies_tol_largura,    
                  ies_espessura,      
                  ies_tol_espessura,  
                  ies_gramatura,      
                  ies_gramatura_min,  
                  ies_gramatura_max,  
                  ies_peso,           
                  ies_peso_min,       
                  ies_peso_max,       
                  ies_lado_corte,      
                  ies_compr_lamina,   
                  ies_largura_lamina, 
                  ies_batidas_hora,   
                  ies_cavidade,       
                  ies_qtd_pecas_emb,  
                  ies_qtd_etiq_emb,   
                  ies_pecas_pacote,   
                  ies_area_aplicacao, 
                  ies_alt_aplicacao, 
                  ies_tol_resina,     
                  ies_cod_tip_mat,    
                  ies_observacao, 
                  ies_fornecedor,    
                  ies_dia_validade   
            INTO
                  p_ies_den_mat_prima1,
                  p_ies_comprimento1,    
                  p_ies_tol_compr1,      
                  p_ies_largura1,        
                  p_ies_tol_largura1,    
                  p_ies_espessura1,      
                  p_ies_tol_espessura1,  
                  p_ies_gramatura1,      
                  p_ies_gramatura_min1,  
                  p_ies_gramatura_max1,  
                  p_ies_peso1,           
                  p_ies_peso_min1,       
                  p_ies_peso_max1,       
                  p_ies_lado_corte1,      
                  p_ies_compr_lamina1,   
                  p_ies_largura_lamina1, 
                  p_ies_batidas_hora1,   
                  p_ies_cavidade1,       
                  p_ies_qtd_pecas_emb1,  
                  p_ies_qtd_etiq_emb1,   
                  p_ies_pecas_pacote1,   
                  p_ies_area_aplicacao1, 
                  p_ies_alt_aplicacao1, 
                  p_ies_tol_resina1,     
                  p_ies_cod_tip_mat1,    
                  p_ies_observacao1, 
                  p_ies_fornecedor1,    
                  p_ies_dia_validade1    
           FROM   item a, item_ppte_req_159 c
           WHERE  a.gru_ctr_estoq = c.cod_grp_ctr_estoq
		   AND    a.cod_empresa   = c.cod_empresa
           AND    a.cod_item = p_item_ppte_159.cod_item
           AND    c.cod_empresa = p_cod_empresa
      
 
  IF p_ies_den_mat_prima1 =   'S' THEN
     LET p_cont1 = 1
  END IF  
  
  IF  p_ies_comprimento1 =    'S' THEN
     LET p_cont2 = 1
  END IF  
  
  IF  p_ies_tol_compr1 =      'S' THEN
     LET p_cont3 = 1
  END IF  
  
  IF p_ies_largura1 =         'S' THEN
     LET p_cont4 = 1
  END IF  
  
  IF  p_ies_tol_largura1 =    'S' THEN
     LET p_cont5 = 1
  END IF  
  
  IF  p_ies_espessura1 =      'S' THEN
     LET p_cont6 = 1
  END IF  
  
  IF  p_ies_tol_espessura1 =  'S' THEN
     LET p_cont7 = 1
  END IF  
  
  IF  p_ies_gramatura1 =      'S' THEN
     LET p_cont8 = 1
  END IF  
  
  IF  p_ies_gramatura_min1 =  'S' THEN
     LET p_cont9 = 1
  END IF  
  
  IF  p_ies_gramatura_max1 =  'S' THEN
     LET p_cont10 = 1
  END IF  
  
  IF  p_ies_peso1 =           'S' THEN
     LET p_cont11 = 1
  END IF  
  
  IF   p_ies_peso_min1 =      'S' THEN
     LET p_cont12 = 1
  END IF  
  
  IF  p_ies_peso_max1 =       'S' THEN
     LET p_cont13 = 1
  END IF  
  
  IF   p_ies_lado_corte1 =    'S' THEN
     LET p_cont14 = 1
  END IF  
  
  IF  p_ies_compr_lamina1 =   'S' THEN
     LET p_cont15 = 1
  END IF  
  
  IF   p_ies_largura_lamina1 ='S' THEN
     LET p_cont16 = 1
  END IF 
   
  IF  p_ies_batidas_hora1 =   'S' THEN
     LET p_cont17 = 1
  END IF 
   
  IF   p_ies_cavidade1 =      'S' THEN
     LET p_cont18 = 1
  END IF 
   
  IF   p_ies_qtd_pecas_emb1 = 'S' THEN
     LET p_cont19 = 1
  END IF  
  
  IF   p_ies_qtd_etiq_emb1 =  'S' THEN
     LET p_cont20 = 1
  END IF  
  
  IF   p_ies_pecas_pacote1 =  'S' THEN
     LET p_cont21 = 1
  END IF  
  
  IF   p_ies_area_aplicacao1 ='S' THEN
     LET p_cont22 = 1
  END IF  
  
  IF   p_ies_alt_aplicacao1 = 'S' THEN
     LET p_cont23 = 1
  END IF  
  
  IF   p_ies_tol_resina1 =    'S' THEN
     LET p_cont24 = 1
  END IF  
  
  IF   p_ies_cod_tip_mat1 =   'S' THEN
     LET p_cont25 = 1
  END IF  
  
  IF   p_ies_observacao1 =    'S' THEN
     LET p_cont26 = 1
  END IF  

  IF   p_ies_dia_validade1 =  'S' THEN
     LET p_cont27 = 1
  END IF  

  IF   p_ies_fornecedor1 =    'S' THEN
     LET p_cont28 = 1
  END IF  
    
  LET p_cont = p_cont1 + p_cont2 + p_cont3 + p_cont4 + p_cont5 + p_cont6 + p_cont7 + p_cont8 + p_cont9 + p_cont10 + p_cont11 + p_cont12 + p_cont13 + p_cont14 + p_cont15 + p_cont16 + p_cont17 + p_cont18 + p_cont19 + p_cont20 + p_cont21 + p_cont22 + p_cont23 + p_cont24 + p_cont25 + p_cont26 + p_cont27 + p_cont28
     
     IF p_funcao <> "MODIFICACAO" THEN
       IF p_contador <> p_cont THEN 
       PROMPT "Faltam Campos a Serem Preenchidos, S Continuar/ N Cancelar (S/N)"
     FOR CHAR ans
     IF ( ans = "s" OR ans = "S" ) THEN
        NEXT FIELD den_mat_prima
       ELSE 
      LET INT_FLAG = TRUE 
         EXIT INPUT  

       END IF
     END IF    
    END IF     

       
             
      ON KEY (control-z)
          CALL pol0739_popup()

                          
   END INPUT 



 IF p_item_ppte_159.cod_item IS NOT NULL AND p_funcao <> "MODIFICACAO" THEN
   LET p_campo = "pol0739"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Inclusão do item ",p_item_ppte_159.cod_item CLIPPED," ","Fornecedor"," ",p_item_ppte_159.cod_fornecedor CLIPPED
   
  INSERT INTO audit_ppte_159 
  VALUES(p_cod_empresa,
         p_item_ppte_159.cod_item, 
         p_campo,
         p_data,
         p_hora,
         p_user,
         p_texto)
 END IF
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0739

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0739_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_item_ppte_159.* TO NULL
   LET p_item_ppte_159a.* = p_item_ppte_159.*

   CONSTRUCT BY NAME where_clause ON item_ppte_159.cod_item 
  
      ON KEY (control-z)
         CALL pol0739_popup()

          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0739

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_item_ppte_159.* = p_item_ppte_159a.*
      CALL pol0739_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM item_ppte_159 ",
                  " where ", where_clause CLIPPED,  
                  "   and cod_empresa = '",p_cod_empresa,"' ",  				  
                  "ORDER BY cod_item "

     PREPARE var_query FROM sql_stmt   
     DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
     OPEN cq_padrao
     FETCH cq_padrao INTO p_item_ppte_159.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
     ELSE 
      LET p_ies_cons = TRUE
      CALL pol0739_exibe_dados()
   END IF

END FUNCTION



#------------------------------#
 FUNCTION pol0739_exibe_dados()
#------------------------------#

INITIALIZE p_raz_social TO NULL
 
 SELECT den_item
 INTO p_den_item
 FROM item
 WHERE cod_item = p_item_ppte_159.cod_item
 AND   cod_empresa = p_cod_empresa
 
 SELECT raz_social
 INTO p_raz_social
 FROM fornecedor
 WHERE cod_fornecedor = p_item_ppte_159.cod_fornecedor 
 
 
  IF p_raz_social IS NULL THEN
   LET p_raz_social = NULL
   END IF    

 DISPLAY BY NAME p_item_ppte_159.*
 DISPLAY p_den_item TO den_item
 DISPLAY p_raz_social TO raz_social

   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0739_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_item_ppte_159.*                                              
     FROM item_ppte_159
    WHERE cod_empresa = p_cod_empresa
    AND cod_item = p_item_ppte_159.cod_item
   # AND   cod_fornecedor = p_item_ppte_159.cod_fornecedor
    
        
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
       RETURN TRUE
     ELSE
       CALL log003_err_sql("LEITURA","item_ppte_159")   
       RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0739_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   LET p_den_mat_prima = p_item_ppte_159.den_mat_prima
   LET p_comprimento   = p_item_ppte_159.comprimento
   LET p_tol_compr     = p_item_ppte_159.tol_compr
   LET p_largura       = p_item_ppte_159.largura
   LET p_tol_largura   = p_item_ppte_159.tol_largura
   LET p_espessura     = p_item_ppte_159.espessura
   LET p_tol_espessura = p_item_ppte_159.tol_espessura
   LET p_gramatura     = p_item_ppte_159.gramatura
   LET p_gramatura_min = p_item_ppte_159.gramatura_min
   LET p_gramatura_max = p_item_ppte_159.gramatura_max
   LET p_peso          = p_item_ppte_159.peso
   LET p_peso_min      = p_item_ppte_159.peso_min
   LET p_peso_max      = p_item_ppte_159.peso_max
   LET p_lado_corte    = p_item_ppte_159.lado_corte
   LET p_compr_lamina  = p_item_ppte_159.compr_lamina
   LET p_largura_lamina= p_item_ppte_159.largura_lamina
   LET p_batidas_hora  = p_item_ppte_159.batidas_hora
   LET p_cavidade      = p_item_ppte_159.cavidade
   LET p_qtd_pecas_emb = p_item_ppte_159.qtd_pecas_emb
   LET p_qtd_etiq_emb  = p_item_ppte_159.qtd_etiq_emb
   LET p_pecas_pacote  = p_item_ppte_159.pecas_pacote
   LET p_area_aplicacao= p_item_ppte_159.area_aplicacao
   LET p_alt_aplicacao = p_item_ppte_159.alt_aplicacao
   LET p_tol_resina    = p_item_ppte_159.tol_resina
   LET p_cod_tip_mat   = p_item_ppte_159.cod_tip_mat
   LET p_observacao    = p_item_ppte_159.observacao
   LET p_tipo_material = p_item_ppte_159.tipo_material
   LET p_dia_validade  = p_item_ppte_159.dia_validade
   

   IF pol0739_cursor_for_update() THEN
      LET p_item_ppte_159a.* = p_item_ppte_159.*
      IF pol0739_entrada_dados("MODIFICACAO") THEN
         UPDATE item_ppte_159
            SET den_mat_prima = p_item_ppte_159.den_mat_prima,
                comprimento   = p_item_ppte_159.comprimento,
                tol_compr     = p_item_ppte_159.tol_compr,
                largura       = p_item_ppte_159.largura,
                tol_largura   = p_item_ppte_159.tol_largura,
                espessura     = p_item_ppte_159.espessura,
                tol_espessura = p_item_ppte_159.tol_espessura,
                gramatura     = p_item_ppte_159.gramatura,
                gramatura_min = p_item_ppte_159.gramatura_min,
                gramatura_max = p_item_ppte_159.gramatura_max,
                peso          = p_item_ppte_159.peso,
                peso_min      = p_item_ppte_159.peso_min,
                peso_max      = p_item_ppte_159.peso_max,
                lado_corte    = p_item_ppte_159.lado_corte,
                compr_lamina  = p_item_ppte_159.compr_lamina,
                largura_lamina= p_item_ppte_159.largura_lamina,
                batidas_hora  = p_item_ppte_159.batidas_hora,
                cavidade      = p_item_ppte_159.cavidade,
                qtd_pecas_emb = p_item_ppte_159.qtd_pecas_emb,
                qtd_etiq_emb  = p_item_ppte_159.qtd_etiq_emb,
                pecas_pacote  = p_item_ppte_159.pecas_pacote,
                area_aplicacao= p_item_ppte_159.area_aplicacao,
                alt_aplicacao = p_item_ppte_159.alt_aplicacao,
                tol_resina    = p_item_ppte_159.tol_resina,
                cod_tip_mat   = p_item_ppte_159.cod_tip_mat,
                observacao    = p_item_ppte_159.observacao,
                tipo_material = p_item_ppte_159.tipo_material,
                dia_validade  = p_item_ppte_159.dia_validade
               WHERE cod_empresa = p_item_ppte_159.cod_empresa
               AND cod_item = p_item_ppte_159.cod_item     
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","item_ppte_159")
         END IF
      ELSE
         LET p_item_ppte_159.* = p_item_ppte_159a.*
         CALL pol0739_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

  IF p_den_mat_prima  <> p_item_ppte_159.den_mat_prima  THEN
     LET p_texto1 = "MODIFICADO den_mat_prima de ",p_den_mat_prima CLIPPED," ","Para ",p_item_ppte_159.den_mat_prima CLIPPED 
  END IF  
  
  IF  p_comprimento   <> p_item_ppte_159.comprimento    THEN
     LET p_texto2 = "MODIFICADO comprimento de ",p_comprimento USING '<<<&'," "," Para ",p_item_ppte_159.comprimento USING '<<<&' 
  END IF  
  
  IF  p_tol_compr     <> p_item_ppte_159.tol_compr      THEN
     LET p_texto3 = "MODIFICADO tol_compr de ",p_tol_compr USING '<<<&'," ","Para ",p_item_ppte_159.tol_compr USING '<<<&'
  END IF  
  
  IF  p_largura       <> p_item_ppte_159.largura        THEN
     LET p_texto4 = "MODIFICADO largura  de ",p_largura USING '<<<&'," ","Para ",p_item_ppte_159.largura USING '<<<&'
  END IF  
  
  IF  p_tol_largura   <> p_item_ppte_159.tol_largura    THEN
     LET p_texto5 = "MODIFICADO tol_largura de ",p_tol_largura USING '<<<&'," ","Para ",p_item_ppte_159.tol_largura USING '<<<&' 
  END IF  
  
  IF  p_espessura     <> p_item_ppte_159.espessura      THEN
     LET p_texto6 = "MODIFICADO espessura de ",p_espessura USING '<<<&'," ","Para ",p_item_ppte_159.espessura USING '<<<&' 
  END IF  
  
  IF  p_tol_espessura <> p_item_ppte_159.tol_espessura  THEN
     LET p_texto7 = "MODIFICADO tol_espessura de ",p_tol_espessura USING '<<<&'," ","Para ",p_item_ppte_159.tol_espessura USING '<<<&' 
  END IF  
  
  IF  p_gramatura     <> p_item_ppte_159.gramatura      THEN
     LET p_texto8 = "MODIFICADO gramatura de ",p_gramatura USING '<<<&'," ","Para ",p_item_ppte_159.gramatura USING '<<<&' 
  END IF  
  
  IF  p_gramatura_min <> p_item_ppte_159.gramatura_min  THEN
     LET p_texto9 = "MODIFICADO gramatura_min de ",p_gramatura_min USING '<<<&'," ","Para ",p_item_ppte_159.gramatura_min USING '<<<&' 
  END IF  
  
  IF  p_gramatura_max <> p_item_ppte_159.gramatura_max  THEN
     LET  p_texto10 = "MODIFICADO gramatura_max de ",p_gramatura_max USING '<<<&'," ","Para ",p_item_ppte_159.gramatura_max USING '<<<&'  
  END IF  
  
  IF  p_peso          <> p_item_ppte_159.peso           THEN
     LET  p_texto11 = "MODIFICADO peso de ",p_peso USING '<<<&'," ","Para ",p_item_ppte_159.peso USING '<<<&' 
  END IF  
  
  IF  p_peso_min      <> p_item_ppte_159.peso_min       THEN
     LET  p_texto12 = "MODIFICADO peso_min de ",p_peso_min USING '<<<&'," ","Para ",p_item_ppte_159.peso_min USING '<<<&' 
  END IF  
  
  IF  p_peso_max      <> p_item_ppte_159.peso_max       THEN
     LET  p_texto13 = "MODIFICADO peso_max de ",p_peso_max USING '<<<&'," ","Para ",p_item_ppte_159.peso_max USING '<<<&' 
  END IF  
  
  IF  p_lado_corte    <> p_item_ppte_159.lado_corte     THEN
     LET  p_texto14 = "MODIFICADO lado_corte de ",p_lado_corte CLIPPED," ","Para ",p_item_ppte_159.lado_corte CLIPPED 
  END IF  
  
  IF  p_compr_lamina  <> p_item_ppte_159.compr_lamina   THEN
     LET  p_texto15 = "MODIFICADO compr_lamina de ",p_compr_lamina USING '<<<&'," ","Para ",p_item_ppte_159.compr_lamina USING '<<<&' 
  END IF  
  
  IF  p_largura_lamina<> p_item_ppte_159.largura_lamina THEN
     LET  p_texto16 = "MODIFICADO largura_lamina de ",p_largura_lamina USING '<<<&'," ","Para ",p_item_ppte_159.largura_lamina USING '<<<&' 
  END IF 
   
  IF  p_batidas_hora  <> p_item_ppte_159.batidas_hora   THEN
     LET  p_texto17 = "MODIFICADO batidas_hora de ",p_batidas_hora USING '<<<&'," ","Para ",p_item_ppte_159.batidas_hora USING '<<<&' 
  END IF 
   
  IF  p_cavidade      <> p_item_ppte_159.cavidade       THEN
     LET  p_texto18 = "MODIFICADO cavidade de ",p_cavidade USING '<<<&'," ","Para ",p_item_ppte_159.cavidade USING '<<<&' 
  END IF 
   
  IF  p_qtd_pecas_emb <> p_item_ppte_159.qtd_pecas_emb  THEN
     LET  p_texto19 = "MODIFICADO qtd_pecas_emb de ",p_qtd_pecas_emb USING '<<<&'," ","Para ",p_item_ppte_159.qtd_pecas_emb USING '<<<&' 
  END IF  
  
  IF  p_qtd_etiq_emb  <> p_item_ppte_159.qtd_etiq_emb   THEN
     LET  p_texto20 = "MODIFICADO qtd_etiq_emb de ",p_qtd_etiq_emb USING '<<<&'," ","Para ",p_item_ppte_159.qtd_etiq_emb USING '<<<&' 
  END IF  
  
  IF  p_pecas_pacote  <> p_item_ppte_159.pecas_pacote   THEN
     LET  p_texto21 = "MODIFICADO pecas_pacote de ",p_pecas_pacote USING '<<<&'," ","Para ",p_item_ppte_159.pecas_pacote USING '<<<&' 
  END IF  
  
  IF  p_area_aplicacao<> p_item_ppte_159.area_aplicacao THEN
     LET  p_texto22 = "MODIFICADO area_aplicacao de ",p_area_aplicacao USING '<<<&'," ","Para ",p_item_ppte_159.area_aplicacao USING '<<<&' 
  END IF  
  
  IF  p_alt_aplicacao <> p_item_ppte_159.alt_aplicacao  THEN
     LET  p_texto23 = "MODIFICADO alt_aplicacao de ",p_alt_aplicacao USING '<<<&'," ","Para ",p_item_ppte_159.alt_aplicacao USING '<<<&' 
  END IF  
  
  IF  p_tol_resina    <> p_item_ppte_159.tol_resina     THEN
     LET  p_texto24 = "MODIFICADO tol_resina de ",p_tol_resina USING '<<<&'," ","Para ",p_item_ppte_159.tol_resina USING '<<<&' 
  END IF  
  
  IF  p_cod_tip_mat   <> p_item_ppte_159.cod_tip_mat    THEN
     LET  p_texto25 = "MODIFICADO cod_tip_mat de ",p_cod_tip_mat USING '<<<&'," ","Para ",p_item_ppte_159.cod_tip_mat USING '<<<&' 
  END IF  
  
  IF  p_observacao    <> p_item_ppte_159.observacao     THEN
     LET  p_texto26 = "MODIFICADO observacao de ",p_observacao CLIPPED," ","Para ",p_item_ppte_159.observacao CLIPPED 
  END IF  

    IF  p_dia_validade<> p_item_ppte_159.dia_validade   THEN
     LET  p_texto27 = "MODIFICADO observacao de ",p_dia_validade CLIPPED," ","Para ",p_item_ppte_159.dia_validade CLIPPED 
  END IF  




   LET p_campo = "pol0739"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Modificação do item ",p_item_ppte_159.cod_item CLIPPED," ",
       p_texto1  CLIPPED,
       p_texto2  CLIPPED,
       p_texto3  CLIPPED,
       p_texto4  CLIPPED,
       p_texto5  CLIPPED,
       p_texto6  CLIPPED,
       p_texto7  CLIPPED,
       p_texto8  CLIPPED,
       p_texto9  CLIPPED,
       p_texto10 CLIPPED,
       p_texto11 CLIPPED,
       p_texto12 CLIPPED,
       p_texto13 CLIPPED,
       p_texto14 CLIPPED,
       p_texto15 CLIPPED,
       p_texto16 CLIPPED,
       p_texto17 CLIPPED,
       p_texto18 CLIPPED,
       p_texto19 CLIPPED,
       p_texto20 CLIPPED,
       p_texto21 CLIPPED,
       p_texto22 CLIPPED,
       p_texto23 CLIPPED,
       p_texto24 CLIPPED,
       p_texto25 CLIPPED,
       p_texto26 CLIPPED,
       p_texto27 CLIPPED
     
 IF p_texto1 IS NOT NULL THEN   
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto1
            )
  END IF       
         
  IF p_texto2 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto2
            )   
  END IF 
         
  IF p_texto3 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto3
            )   
    END IF 
         
  IF p_texto4 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto4
            )   
    END IF 
         
  IF p_texto5 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto5
            )   
    END IF 
         
  IF p_texto6 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto6
            )   
    END IF 
         
  IF p_texto7 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto7
            )   
    END IF 
         
  IF p_texto8 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto8
            )   
    END IF 
         
  IF p_texto9 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto9
            )   
    END IF 
         
  IF p_texto10 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto10
            )   
    END IF 
         
  IF p_texto11 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto11
            )   
    END IF 
         
  IF p_texto12 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto12
            )   
    END IF 
         
  IF p_texto13 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto13
            )   
    END IF 
         
  IF p_texto14 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto14
            )   
    END IF 
         
  IF p_texto15 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto15
            )   
    END IF 
         
  IF p_texto16 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto16
            )   
    END IF 
         
  IF p_texto17 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto17
            )   
  END IF 
         
  IF p_texto18 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto18
            )   
  END IF 
         
  IF p_texto19 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto19
            )   
  END IF 
         
  IF p_texto20 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto20
            )   
  END IF 
         
  IF p_texto21 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto21
            )   
  END IF 
         
  IF p_texto22 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto22
            )   
  END IF 
         
  IF p_texto23 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto23
            )   
  END IF 
         
  IF p_texto24 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
           p_item_ppte_159.cod_item, 
           p_campo,
           p_data,
           p_hora,
           p_user,
           p_texto24
           )   
  END IF 
         
  IF p_texto25 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto25
            )   
  END IF 
         
  IF p_texto26 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto26
            )   
  END IF 
         

  IF p_texto27 IS NOT NULL THEN 
     INSERT INTO audit_ppte_159 
     VALUES(p_cod_empresa,
            p_item_ppte_159.cod_item, 
            p_campo,
            p_data,
            p_hora,
            p_user,
            p_texto26
            )   
  END IF 


   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 

#--------------------------#
 FUNCTION pol0739_exclusao()
#--------------------------#

   LET p_campo = "pol0739"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Exclusão do item ",p_item_ppte_159.cod_item CLIPPED," ","Fornecedor"," ",p_item_ppte_159.cod_fornecedor CLIPPED
   
  INSERT INTO audit_ppte_159 
  VALUES(p_cod_empresa,
         p_item_ppte_159.cod_item, 
         p_campo,
         p_data,
         p_hora,
         p_user,
         p_texto)

   LET p_retorno = FALSE
   IF pol0739_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM item_ppte_159
         WHERE cod_empresa = p_item_ppte_159.cod_empresa
         AND cod_item = p_item_ppte_159.cod_item
      
      
         IF STATUS = 0 THEN
            INITIALIZE p_item_ppte_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","item_ppte_159")
         END IF
      END IF
      CLOSE cm_padrao
   END IF



   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0739_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_item_ppte_159a.* = p_item_ppte_159.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_item_ppte_159.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_item_ppte_159.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_item_ppte_159.* = p_item_ppte_159a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_item_ppte_159.*
           FROM item_ppte_159
          WHERE cod_empresa  = p_item_ppte_159.cod_empresa 
          AND cod_item       = p_item_ppte_159.cod_item
          AND (cod_fornecedor = p_item_ppte_159.cod_fornecedor 
          OR  cod_fornecedor IS NULL)  
          
        
        
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0739_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0739_popup()
#-----------------------#
    DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
      CALL sup162_popup_fornecedor() 

      RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
      
      CURRENT WINDOW IS w_pol0720
      IF p_codigo IS NOT NULL THEN
         LET p_item_ppte_159.cod_fornecedor = p_codigo CLIPPED
         DISPLAY p_codigo TO p_item_ppte_159.cod_fornecedor
      END IF
                  
   END CASE 
         
         
   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0739
         IF p_codigo IS NOT NULL THEN
           LET p_item_ppte_159.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
END FUNCTION 

#-----------------------#
 FUNCTION pol0739_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#
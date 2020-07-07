#-------------------------------------------------------------------#
# OBJETIVO: ROTA DE FRETE - CIBRAPEL                                #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_imprimiu           SMALLINT,
          p_salto              SMALLINT,
          p_cod_cid_orig       CHAR(05),
          p_cod_cid_dest       CHAR(05),
          p_cod_veiculo        CHAR(15),
          p_cod_tip_carga      CHAR(01),
          p_val_frete          DECIMAL(12,2),
          p_tip_transp         CHAR(02),
          p_tip_transp_auto    CHAR(02),
          p_num_versao         INTEGER,
          p_ies_versao_atual   CHAR(01), 
          p_dat_atualiz        DATE,
          p_den_transpor       CHAR(36),
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_den_cidade         LIKE cidades.den_cidade,
          p_den_cidade2        LIKE cidades.den_cidade,
          p_den_veiculo        LIKE veiculo_885.den_veiculo,
          p_user               LIKE usuario.nom_usuario,
          p_numerador          SMALLINT,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_tela               CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_hora               SMALLINT,
          p_msg                CHAR(100) 
         
          
          
          
   DEFINE p_frete_rota_885     RECORD LIKE frete_rota_885.*,
          p_frete_rota_885a    RECORD LIKE frete_rota_885.*

   DEFINE p_relat              RECORD        
          cod_transpor         LIKE frete_rota_885.cod_transpor,
          nom_reduzido         LIKE clientes.nom_reduzido,
          den_cidade           LIKE cidades.den_cidade,
          cod_veiculo          LIKE frete_rota_885.cod_veiculo,
          cod_tip_carga        LIKE frete_rota_885.cod_tip_carga,
          cod_tip_frete        LIKE frete_rota_885.cod_tip_frete,
          cod_percurso         LIKE frete_rota_885.cod_percurso,
          val_frete            LIKE frete_rota_885.val_frete
   END RECORD
           

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0746-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0746.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0746_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0746_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_tela TO NULL 
   CALL log130_procura_caminho("pol0746") RETURNING p_tela
   LET p_tela = p_tela CLIPPED 
   OPEN WINDOW w_pol0746 AT 2,2 WITH FORM p_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    DISPLAY p_cod_empresa TO cod_empresa

   SELECT substring(par_vdp_txt,215,2)
     INTO p_tip_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0746_inclusao() THEN
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
            IF pol0746_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0746_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0746_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0746_paginacao("ANTERIOR")
      COMMAND "Listar" "Listagem de fretes p/ conferência"
         IF log005_seguranca(p_user,"VDP","pol0746","IN")  THEN
            CALL pol0746_listar()
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
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
   CLOSE WINDOW w_pol0746

END FUNCTION

#--------------------------#
 FUNCTION pol0746_inclusao()
#--------------------------#

   CLEAR FORM
   INITIALIZE p_frete_rota_885.* TO NULL
   LET p_frete_rota_885.cod_empresa = p_cod_empresa
   LET p_frete_rota_885.num_versao = 1
   LET p_frete_rota_885.ies_versao_atual = 'S'
   LET p_frete_rota_885.dat_atualiz = CURRENT
   
   IF pol0746_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO frete_rota_885 VALUES (p_frete_rota_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql('Inserindo','frete_rota_885')
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
 FUNCTION pol0746_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   LET INT_FLAG = FALSE

    INPUT BY NAME p_frete_rota_885.*  WITHOUT DEFAULTS
                          
      BEFORE FIELD cod_transpor
        IF p_funcao = "M" THEN
         NEXT FIELD val_frete
      END IF 
      
      AFTER FIELD cod_transpor
      
         SELECT nom_cliente
           INTO p_den_transpor
           FROM clientes
          WHERE cod_cliente = p_frete_rota_885.cod_transpor
            AND cod_tip_cli IN (p_tip_transp, p_tip_transp_auto)
         
         IF STATUS <> 0 THEN
            ERROR 'Transportador Inválido!!!'
            NEXT FIELD cod_transpor
         END IF
         
         DISPLAY p_den_transpor TO den_transpor
            
      AFTER FIELD cod_cid_orig
        IF p_frete_rota_885.cod_cid_orig IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_cid_orig
        ELSE 
          SELECT den_cidade
          INTO p_den_cidade
          FROM cidades
          WHERE cod_cidade = p_frete_rota_885.cod_cid_orig

         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo da Cidade nao Cadastrado na Tabela CIDADE !!!" 
            NEXT FIELD cod_cid_orig
         END IF
                              
         DISPLAY p_frete_rota_885.cod_cid_orig TO cod_cid_orig         
         DISPLAY p_den_cidade TO den_cidade 
          NEXT FIELD cod_cid_dest
       END IF
                           
      AFTER FIELD cod_cid_dest
        IF p_frete_rota_885.cod_cid_dest IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_cid_dest
     ELSE 
          SELECT den_cidade
          INTO p_den_cidade2
          FROM cidades
          WHERE cod_cidade = p_frete_rota_885.cod_cid_dest

         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo da Cidade nao Cadastrado na Tabela CIDADE !!!" 
            NEXT FIELD cod_cid_dest
         END IF
               
                               
         DISPLAY p_frete_rota_885.cod_cid_dest TO cod_cid_dest
         DISPLAY p_den_cidade2 TO den_cidade2 
          NEXT FIELD cod_veiculo
       END IF
       
        AFTER FIELD cod_veiculo
        IF p_frete_rota_885.cod_veiculo IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_veiculo
     ELSE 
          SELECT den_veiculo
          INTO p_den_veiculo
          FROM veiculo_885
          WHERE cod_veiculo = p_frete_rota_885.cod_veiculo

         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do veiculo nao Cadastrado na Tabela VEICULOS_885 !!!" 
            NEXT FIELD cod_veiculo
            
         END IF
                     
          
                              
         DISPLAY p_frete_rota_885.cod_veiculo TO cod_veiculo
         DISPLAY p_den_veiculo TO den_veiculo
          NEXT FIELD cod_tip_carga
       END IF
     
       BEFORE FIELD cod_tip_carga
        IF p_frete_rota_885.cod_tip_carga IS NULL THEN
           LET p_frete_rota_885.cod_tip_carga = 'N'
        END IF 

       AFTER FIELD cod_tip_carga
        IF p_frete_rota_885.cod_tip_carga IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_tip_carga
        END IF     

       AFTER FIELD cod_tip_frete
        IF p_frete_rota_885.cod_tip_frete MATCHES '[RP]' THEN 
        ELSE
          ERROR "Valor impróprio para o campo !!!"
          NEXT FIELD cod_tip_frete
        END IF     

       BEFORE FIELD cod_percurso
        IF p_frete_rota_885.cod_percurso IS NULL THEN
           LET p_frete_rota_885.cod_percurso = '1'
        END IF 
         
       AFTER FIELD cod_percurso
        IF p_frete_rota_885.cod_percurso MATCHES '[12]' THEN 
        ELSE
          ERROR "Valor impróprio para o campo !!!"
          NEXT FIELD cod_percurso
        END IF     

             SELECT cod_empresa
             FROM frete_rota_885
             WHERE cod_empresa = p_cod_empresa
             AND cod_transpor  =  p_frete_rota_885.cod_transpor
             AND cod_cid_dest = p_frete_rota_885.cod_cid_dest
             AND cod_cid_orig = p_frete_rota_885.cod_cid_orig
             AND cod_veiculo = p_frete_rota_885.cod_veiculo
             AND cod_tip_carga = p_frete_rota_885.cod_tip_carga
             AND cod_tip_frete = p_frete_rota_885.cod_tip_frete
             AND cod_percurso = p_frete_rota_885.cod_percurso
             
              IF SQLCA.sqlcode = 0 THEN    
             ERROR "Registro Ja Cadastrado"
             NEXT FIELD cod_veiculo
            END IF   
     
      AFTER FIELD val_frete
        IF p_frete_rota_885.val_frete IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD val_frete
        END IF 
        
        IF p_funcao = 'M' THEN
           EXIT INPUT
        END IF
       
   
      ON KEY (control-z)
          CALL pol0746_popup()
                          
   END INPUT 


  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0746

   IF INT_FLAG  THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF 

END FUNCTION


#--------------------------#
 FUNCTION pol0746_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_frete_rota_885.* TO NULL
   LET p_frete_rota_885a.* = p_frete_rota_885.*

   CONSTRUCT BY NAME where_clause ON 
      frete_rota_885.cod_transpor,
      frete_rota_885.cod_cid_orig,
      frete_rota_885.cod_cid_dest,
      frete_rota_885.cod_veiculo,
      frete_rota_885.cod_tip_frete
      
      ON KEY (control-z)
         CALL pol0746_popup()

          
   END CONSTRUCT      
    
 

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_frete_rota_885.* = p_frete_rota_885a.*
      CALL pol0746_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM frete_rota_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "   AND ies_versao_atual = 'S' ",
                  " ORDER BY cod_transpor, cod_cid_orig, cod_cid_dest"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_frete_rota_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0746_exibe_dados()

      
   END IF

END FUNCTION



#------------------------------#
 FUNCTION pol0746_exibe_dados()
#------------------------------#

 SELECT den_cidade
 INTO p_den_cidade
 FROM cidades
 WHERE cod_cidade = p_frete_rota_885.cod_cid_orig
          
 SELECT den_cidade
 INTO p_den_cidade2
 FROM cidades
 WHERE cod_cidade = p_frete_rota_885.cod_cid_dest
 
 SELECT den_veiculo
 INTO p_den_veiculo
 FROM veiculo_885
 WHERE cod_veiculo = p_frete_rota_885.cod_veiculo

 SELECT nom_cliente
   INTO p_den_transpor
   FROM clientes
  WHERE cod_cliente = p_frete_rota_885.cod_transpor
    AND cod_tip_cli IN (p_tip_transp, p_tip_transp_auto)

 DISPLAY BY NAME p_frete_rota_885.*
 DISPLAY p_den_transpor TO den_transpor
 DISPLAY p_den_cidade TO den_cidade 
 DISPLAY p_den_cidade2 TO den_cidade2
 DISPLAY p_den_veiculo TO den_veiculo
   
 LET p_val_frete = p_frete_rota_885.val_frete
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0746_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_frete_rota_885.*                                              
     FROM frete_rota_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor  = p_frete_rota_885.cod_transpor
      AND cod_cid_orig  = p_frete_rota_885.cod_cid_orig
      AND cod_cid_dest  = p_frete_rota_885.cod_cid_dest
      AND cod_veiculo   = p_frete_rota_885.cod_veiculo
      AND cod_tip_carga = p_frete_rota_885.cod_tip_carga
      AND ies_versao_atual = 'S'
   FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
   

      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","frete_rota_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0746_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0746_cursor_for_update() THEN
      LET p_frete_rota_885a.* = p_frete_rota_885.*

      IF pol0746_entrada_dados("M") AND 
         p_frete_rota_885.val_frete <>  p_frete_rota_885a.val_frete THEN
         UPDATE frete_rota_885 
            SET ies_versao_atual = 'N'
          WHERE cod_empresa      = p_cod_empresa
            AND cod_transpor     = p_frete_rota_885.cod_transpor
            AND cod_cid_orig     = p_frete_rota_885.cod_cid_orig
            AND cod_cid_dest     = p_frete_rota_885.cod_cid_dest
            AND cod_veiculo      = p_frete_rota_885.cod_veiculo
            AND cod_tip_carga    = p_frete_rota_885.cod_tip_carga
            AND cod_tip_frete    = p_frete_rota_885.cod_tip_frete
            AND cod_percurso     = p_frete_rota_885.cod_percurso
            AND num_versao       = p_frete_rota_885.num_versao
            AND ies_versao_atual = 'S'
         IF STATUS <> 0 THEN
            CALL log003_err_sql("MODIFICACAO","FRETE_ROTA_885")
         ELSE
            LET p_frete_rota_885.num_versao = p_frete_rota_885.num_versao + 1
            LET p_frete_rota_885.ies_versao_atual = 'S'
            INSERT INTO frete_rota_885
               VALUES(p_frete_rota_885.*)
            IF STATUS <> 0 THEN
               CALL log003_err_sql("INCLUSAO","FRETE_ROTA_885:2")
            ELSE
               LET p_retorno = TRUE
               LET p_ies_cons = FALSE
               DISPLAY p_frete_rota_885.num_versao TO num_versao
            END IF
         END IF
      END IF
   END IF
   
   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_frete_rota_885.* = p_frete_rota_885a.*
      CALL pol0746_exibe_dados()
   END IF

   RETURN p_retorno

END FUNCTION 



#-----------------------------------#
 FUNCTION pol0746_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_frete_rota_885a.* = p_frete_rota_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_frete_rota_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_frete_rota_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_frete_rota_885.* = p_frete_rota_885a.* 
            EXIT WHILE
         END IF

            CALL pol0746_exibe_dados()
            EXIT WHILE

      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0746_popup()
#-----------------------#
  DEFINE p_codigo CHAR(15)
    
    CASE
      WHEN INFIELD(cod_cid_orig)
         CALL log009_popup(5,12,"CIDADES","cidades",
              "cod_cidade","den_cidade","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0746
         IF p_codigo IS NOT NULL THEN
           LET p_frete_rota_885.cod_cid_orig  = p_codigo
           DISPLAY p_codigo TO cod_cid_orig
         END IF
   END CASE
   
       CASE
      WHEN INFIELD(cod_cid_dest)
         CALL log009_popup(5,12,"CIDADES","cidades",
              "cod_cidade","den_cidade","","S","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0746
         IF p_codigo IS NOT NULL THEN
           LET p_frete_rota_885.cod_cid_dest = p_codigo
           DISPLAY p_codigo TO cod_cid_dest
         END IF

      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_frete_rota_885.cod_transpor = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF

   END CASE
   
   CASE
      WHEN INFIELD(cod_veiculo)
         CALL log009_popup(5,12,"VEICULO_885","veiculo_885",
              "cod_veiculo","den_veiculo","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0700
         IF p_codigo IS NOT NULL THEN
           LET p_frete_rota_885.cod_veiculo = p_codigo
           DISPLAY p_codigo TO cod_veiculo
         END IF
   END CASE
   
   

  END FUNCTION 

#------------------------#
FUNCTION pol0746_listar()
#------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0732.tmp"
         START REPORT pol0746_relat TO p_caminho
      ELSE
         START REPORT pol0746_relat TO p_nom_arquivo
      END IF
   END IF

   #LET p_comprime    = ascii 15
   #LET p_descomprime = ascii 18

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   LET p_imprimiu = FALSE
   
   DECLARE cq_imp CURSOR FOR
    SELECT cod_transpor,
           cod_cid_dest,
           cod_veiculo,
           cod_tip_carga,
           cod_tip_frete,
           cod_percurso,
           val_frete
      FROM frete_rota_885
     WHERE cod_empresa      = p_cod_empresa
       AND ies_versao_atual = 'S'
     ORDER BY cod_transpor,
              cod_cid_dest,
              cod_veiculo,
              cod_tip_carga,
              cod_tip_frete,
              cod_percurso
   
   FOREACH cq_imp INTO 
           p_relat.cod_transpor,
           p_cod_cidade,
           p_relat.cod_veiculo,
           p_relat.cod_tip_carga,
           p_relat.cod_tip_frete,
           p_relat.cod_percurso,
           p_relat.val_frete
                              
      LET p_imprimiu = TRUE
         
      DISPLAY p_relat.cod_transpor AT 21,30
      DISPLAY p_cod_cidade AT 21,50

      SELECT den_cidade
        INTO p_relat.den_cidade
        FROM cidades
       WHERE cod_cidade = p_cod_cidade
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','cidades')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF
      
      SELECT nom_reduzido
        INTO p_relat.nom_reduzido
        FROM clientes
       WHERE cod_cliente = p_relat.cod_transpor
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','clientes')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF

      OUTPUT TO REPORT pol0746_relat()

      INITIALIZE p_relat TO NULL
         
   END FOREACH
   
   FINISH REPORT pol0746_relat

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         ERROR "Relatório impresso na impressora ", p_nom_arquivo
      ELSE
         ERROR "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF

END FUNCTION

#----------------------#
 REPORT pol0746_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 070, "PAG: ", PAGENO USING "&&&&&"
               
         PRINT COLUMN 001, "POL0778",
               COLUMN 021, 'VALOR DO FRETE POR TRANSPORTADORA',
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "TRANSPORTADORA        NOME         CIDADE DESTINO    VEICULO   TC TF TP   VAL FRETE"
         PRINT COLUMN 001, "--------------- --------------- ------------------- ---------- -- -- -- -----------"
      
      ON EVERY ROW
--------------- --------------- ------------------- ---------- -- -- -----------
         PRINT COLUMN 001, p_relat.cod_transpor,
               COLUMN 017, p_relat.nom_reduzido,
               COLUMN 033, p_relat.den_cidade[1,19],
               COLUMN 053, p_relat.cod_veiculo[1,10],
               COLUMN 065, p_relat.cod_tip_carga,
               COLUMN 068, p_relat.cod_tip_frete,
               COLUMN 071, p_relat.cod_percurso,
               COLUMN 073, p_relat.val_frete USING '####,##&.&&'

      ON LAST ROW

         LET p_salto = LINENO
         
         IF p_salto < 63 THEN
            LET p_salto = 63 - p_salto
            SKIP p_salto LINES
         END IF

         PRINT COLUMN 030,  '* * * ULTIMA FOLHA * * *'
            
         
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
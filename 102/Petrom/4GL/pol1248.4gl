#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1248                                                 #
# OBJETIVO: VEICULOS PARA CONTROLE DE FRETE                         #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 20/10/13                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
 
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
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

DEFINE p_den_transpor      CHAR(36),
       p_cod_tip_veiculo       CHAR(07),
       p_tip_carga         CHAR(06),
       p_cod_transpor      CHAR(15),
       p_des_tip_veiculo   CHAR(15)

DEFINE p_carreta       RECORD LIKE carreta_455.*,
       p_carretaa       RECORD LIKE carreta_455.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1248-10.02.04  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")  RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1248_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1248_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1248") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1248 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NUM_ARGS() > 0  THEN
      LET p_cod_transpor = ARG_VAL(1) 
      IF p_cod_transpor IS NOT NULL THEN
         CALL pol1248_consulta() RETURNING p_status
      END IF
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1248_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         LET p_cod_transpor = NULL
         IF pol1248_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1248_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1248_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1248_modificacao() RETURNING p_status  
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
            CALL pol1248_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1248_listagem()
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
   CLOSE WINDOW w_pol1248

END FUNCTION

#---------------------------#
FUNCTION pol1248_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1248_inclusao()
#--------------------------#

   CALL pol1248_limpa_tela()
   
   INITIALIZE p_carreta TO NULL
   LET p_carreta.peso_minimo = 0
   LET p_carreta.ies_dif_preco = 'N'
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1248_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1248_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1248_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1248_insere()
#------------------------#

   INSERT INTO carreta_455 VALUES (p_carreta.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","carreta_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1248_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_carreta.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_transpor

         IF p_funcao = "M" THEN
            NEXT FIELD cod_tip_veiculo
         END IF
      
      AFTER FIELD cod_transpor

         IF p_carreta.cod_transpor IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_transpor   
         END IF

         CALL pol1248_le_den_transpor(p_carreta.cod_transpor)
          
         IF p_den_transpor IS NULL THEN 
            ERROR 'Transportadora inexistente.'
            NEXT FIELD cod_transpor
         END IF  
         
         DISPLAY p_den_transpor TO den_transpor

      BEFORE FIELD chapa

         IF p_funcao = "M" THEN
            NEXT FIELD cod_tip_veiculo
         END IF

      AFTER FIELD chapa

         IF p_carreta.chapa IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD chapa   
         END IF
         
         SELECT cod_transpor
           FROM carreta_455
          WHERE cod_transpor = p_carreta.cod_transpor
            AND chapa = p_carreta.chapa
         
         IF STATUS = 0 THEN
            ERROR 'Transportador/chapa já cadastrados no pol1248.'
            NEXT FIELD cod_transpor   
         END IF

      AFTER FIELD cod_tip_veiculo

         IF p_carreta.cod_tip_veiculo IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_tip_veiculo   
         END IF

         CALL pol1248_le_des_veiculo(p_carreta.cod_tip_veiculo)
          
         IF p_des_tip_veiculo IS NULL THEN 
            ERROR 'Veículo não cadastrado no POL1266.'
            NEXT FIELD cod_tip_veiculo
         END IF  
         
         DISPLAY p_des_tip_veiculo TO des_tip_veiculo
          
      ON KEY (control-z)
         CALL pol1248_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_carreta.peso_minimo IS NULL THEN 
               LET p_carreta.peso_minimo = 0
            END IF

            IF p_carreta.qtd_eixo IS NULL OR p_carreta.qtd_eixo = 0 THEN 
               ERROR 'Por favor, informe a quantidade de eixos.'
               NEXT FIELD qtd_eixo
            END IF

            IF p_carreta.ies_dif_preco MATCHES "[SN]" THEN 
            ELSE
               ERROR 'Por favor, informe S/N p/ esse campo.'
               NEXT FIELD ies_dif_preco
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1248_le_den_transpor(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT raz_social
     INTO p_den_transpor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_transpor = NULL
   END IF  

END FUNCTION

#-------------------------------------#
FUNCTION pol1248_le_des_veiculo(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT des_tip_veiculo
     INTO p_des_tip_veiculo
     FROM tip_veiculo_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_veiculo = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_des_tip_veiculo = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1248_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_carreta.cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(cod_tip_veiculo)
         CALL log009_popup(8,10,"TIPO DE VEÍCULO","tip_veiculo_455",
              "cod_tip_veiculo","des_tip_veiculo","POL1266","S"," 1=1 order by des_tip_veiculo") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_carreta.cod_tip_veiculo = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tip_veiculo
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1248_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1248_limpa_tela()
   LET p_carretaa.* = p_carreta.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      carreta_455.cod_transpor,     
      carreta_455.chapa,
      carreta_455.cod_tip_veiculo,
      carreta_455.tip_carga
      BEFORE CONSTRUCT
         DISPLAY p_cod_transpor TO cod_transpor

      ON KEY (control-z)
         CALL pol1248_popup()

   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1248_limpa_tela()
         ELSE
            LET p_carreta.* = p_carretaa.*
            CALL pol1248_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM carreta_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_transpor"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_carreta.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1248_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1248_exibe_dados()
#------------------------------#

   DEFINE p_transpor CHAR(15),
          p_chapa    CHAR(10)
   
   LET p_transpor = p_carreta.cod_transpor
   LET p_chapa = p_carreta.chapa
   
   SELECT *
     INTO p_carreta.*
     FROM carreta_455
    WHERE cod_transpor = p_transpor
      AND chapa = p_chapa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'carreta_455')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_carreta.*
   
   CALL pol1248_le_den_transpor(p_transpor)
   DISPLAY p_den_transpor to den_transpor

   CALL pol1248_le_des_veiculo(p_carreta.cod_tip_veiculo)
   DISPLAY p_des_tip_veiculo to des_tip_veiculo
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1248_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_carretaa.* = p_carreta.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_carreta.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_carreta.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_transpor
           FROM carreta_455
          WHERE cod_transpor = p_carreta.cod_transpor
            AND chapa = p_carreta.chapa
            
         IF STATUS = 0 THEN
            IF pol1248_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_carreta.* = p_carretaa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1248_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_transpor 
      FROM carreta_455  
     WHERE cod_transpor = p_carreta.cod_transpor
       AND chapa = p_carreta.chapa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","carreta_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1248_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_carretaa.* = p_carreta.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1248_prende_registro() THEN
      IF pol1248_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_carreta.* = p_carretaa.*
      CALL pol1248_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE carreta_455
      SET carreta_455.* = p_carreta.*
    WHERE cod_transpor = p_carreta.cod_transpor
      AND chapa = p_carreta.chapa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "carreta_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1248_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1248_prende_registro() THEN
      IF pol1248_deleta() THEN
         INITIALIZE p_carreta TO NULL
         CALL pol1248_limpa_tela()
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
FUNCTION pol1248_deleta()
#------------------------#

   DELETE FROM carreta_455
    WHERE cod_transpor = p_carreta.cod_transpor
      AND chapa = p_carreta.chapa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","carreta_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1248_listagem()
#--------------------------#     

   IF NOT pol1248_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1248_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM carreta_455 
     ORDER BY cod_transpor, chapa
  
   FOREACH cq_impressao INTO p_carreta.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      CALL pol1248_le_den_transpor(p_carreta.cod_transpor)
      
      CALL pol1248_seta_carga()
      CALL pol1248_le_des_veiculo()
      
      OUTPUT TO REPORT pol1248_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1248_finaliza_relat()

   RETURN
     
END FUNCTION 

#----------------------------#
FUNCTION pol1248_seta_carga()#
#----------------------------#

   CASE p_carreta.tip_carga
      WHEN 'G' LET p_tip_carga = 'GRANEL'
      WHEN 'S' LET p_tip_carga = 'SECA'
   END CASE

END FUNCTION
      
#-------------------------------#
 FUNCTION pol1248_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1248_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1248.tmp'
         START REPORT pol1248_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1248_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1248_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1248_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1248_relat   

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
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1248_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1248",
               COLUMN 010, "CARRETAS P/ CONTROLE DE FRETE",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   NOME                           CHAPA          TIPO      CARGA'                                
         PRINT COLUMN 001, '---------------- ------------------------------ ---------- ------------- -------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   NOME                           CHAPA          TIPO      CARGA'                                
         PRINT COLUMN 001, '---------------- ------------------------------ ---------- ------------- -------'

      ON EVERY ROW

         PRINT COLUMN 001, p_carreta.cod_transpor,
               COLUMN 018, p_den_transpor[1,30],
               COLUMN 049, p_carreta.chapa,
               COLUMN 060, p_des_tip_veiculo[1,13],
               COLUMN 074, p_tip_carga
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#

#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0917                                                 #
# OBJETIVO: LISTAGEM DE PESOS TRANSPORTADOS                         #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 05/03/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_info           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_chave              CHAR(500)
                       
   
   DEFINE p_tela               RECORD 
          dat_ini              DATE,
          dat_fim              DATE,
          cod_transpor         LIKE frete_solicit_885.cod_transpor,
          nom_reduzido         LIKE clientes.nom_reduzido,
          num_chapa            LIKE frete_solicit_885.num_chapa
   END RECORD  
   
   DEFINE P_relat              RECORD 
          dat_cadastro         DATE,
          cod_transpor         LIKE frete_solicit_885.cod_transpor,
          nom_reduzido         LIKE clientes.nom_reduzido,
          num_chapa            LIKE frete_solicit_885.num_chapa,
          cod_veiculo          LIKE frete_solicit_885.cod_veiculo,
          peso_carga           LIKE frete_solicit_885.peso_carga
   END RECORD            
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0917-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0917_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0917_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0917") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0917 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0917_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa
   LET p_cod_empresa = p_cod_emp_ofic

   IF NOT pol0917_cria_tab_tmp() THEN
      RETURN
   END IF
      
   LET p_ies_info = FALSE  
   
   MENU "OPCAO"
      COMMAND "Informar" "Informe dados á serem listados"
         CALL pol0917_Informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Dados informados com sucesso!!!'
            LET p_ies_info = TRUE
            NEXT OPTION "Listar" 
         ELSE
            LET p_ies_info = FALSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Listar" "Listagem dos parâmetros já informados com sucesso"
         IF p_ies_info THEN
            CALL pol0917_listar()
         ELSE
            ERROR "Informe primeiro os parâmetros!!!"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0917

END FUNCTION

#----------------------------#
FUNCTION pol0917_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#-----------------------------#
FUNCTION pol0917_cria_tab_tmp()
#-----------------------------#

   DROP TABLE dados_tmp_885
   
   CREATE TABLE dados_tmp_885
     (
      dat_cadastro       DATE,
      cod_transpor       CHAR(15),
      num_chapa          CHAR(10),
      cod_veiculo        CHAR(15),
      peso_carga         DECIMAL(10,3)
     );
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","dados_tmp_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0917_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol0917_Informar()
#--------------------------#
   
   DEFINE sql_stmt CHAR(600)
   
   CALL pol0917_limpa_tela()
   
   INITIALIZE p_tela TO NULL
   
   DELETE FROM dados_tmp_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletanto','dados_tmp_885')
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME P_tela.* WITHOUT DEFAULTS
   
   AFTER FIELD cod_transpor
   IF p_tela.cod_transpor IS NOT NULL THEN 
      SELECT nom_reduzido
        INTO p_tela.nom_reduzido
        FROM clientes 
       WHERE cod_cliente = p_tela.cod_transpor
    
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'clientes')
         NEXT FIELD cod_transpor
      END IF 
    
      DISPLAY p_tela.nom_reduzido TO nom_reduzido
   END IF 
       
   AFTER INPUT 
   IF NOT INT_FLAG THEN
      IF p_tela.dat_ini IS NOT NULL AND
         p_tela.dat_fim IS NOT NULL THEN 
         IF p_tela.dat_ini > p_tela.dat_fim THEN 
            ERROR "A data inicial é maior que a data final!!!"
            NEXT FIELD dat_ini
         END IF
      END IF 
   END IF
    
   ON KEY (control-z)
      CALL pol0917_popup()
    
   END INPUT 
    
          
  IF INT_FLAG THEN
     CALL pol0917_limpa_tela()
     RETURN FALSE
  END IF

  INITIALIZE p_chave TO NULL
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "

   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND CONVERT(CHAR(10),dat_cadastro,103) >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND CONVERT(CHAR(10),dat_cadastro,103) <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.cod_transpor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_transpor = '",p_tela.cod_transpor,"' "
   END IF
   
   IF p_tela.num_chapa IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND num_chapa = '",p_tela.num_chapa,"' "
   END IF


   LET sql_stmt = " SELECT CONVERT(CHAR(10),dat_cadastro,103),",
                  " cod_transpor, num_chapa, cod_veiculo, peso_carga",
                  " FROM frete_solicit_885 WHERE ",p_chave CLIPPED,
                  " ORDER BY dat_cadastro"

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      CALL pol0917_limpa_tela()
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao CURSOR WITH HOLD FOR var_query

   FOREACH cq_padrao 
             
             INTO p_relat.dat_cadastro,
                  p_relat.cod_transpor,
                  p_relat.num_chapa,
                  p_relat.cod_veiculo,
                  p_relat.peso_carga
   
      INSERT INTO dados_tmp_885(
                  dat_cadastro, 
                  cod_transpor, 
                  num_chapa, 
                  cod_veiculo, 
                  peso_carga) 
           VALUES(p_relat.dat_cadastro, 
                  p_relat.cod_transpor, 
                  p_relat.num_chapa, 
                  p_relat.cod_veiculo, 
                  p_relat.peso_carga)
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('inserindo', 'dados_tmp_885')
         RETURN FALSE
      END IF 
              
   END FOREACH
   
   SELECT COUNT(cod_transpor)
     INTO p_count
     FROM dados_tmp_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dados_tmp_885')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      CALL log0030_mensagem('Argumentos de pesquisa não encontrados','excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0917_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_transpor   = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF
         
   END CASE 

END FUNCTION       
         
#------------------------#
 FUNCTION pol0917_Listar()
#------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED
         START REPORT pol0917_relat TO p_caminho
      ELSE
         START REPORT pol0917_relat TO p_nom_arquivo
      END IF
   END IF
    
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'Empresa')
      RETURN
   END IF 
   

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)
       
   DECLARE cq_transp CURSOR FOR
  
   SELECT dat_cadastro,
          cod_transpor,
          num_chapa,
          cod_veiculo,
          peso_carga
     FROM dados_tmp_885
 ORDER BY dat_cadastro,
          cod_transpor,
          num_chapa

   FOREACH cq_transp INTO 
           p_relat.dat_cadastro,
           p_relat.cod_transpor,
           p_relat.num_chapa,
           p_relat.cod_veiculo,
           p_relat.peso_carga
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'cq_transp')
         RETURN FALSE 
      END IF 
      
      SELECT nom_reduzido
        INTO p_relat.nom_reduzido
        FROM clientes
       WHERE cod_cliente = p_relat.cod_transpor
       
      IF STATUS = 100 THEN 
         LET p_relat.nom_reduzido = NULL 
      ELSE 
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'clientes')
            RETURN FALSE 
         END IF 
      END IF 
      
       
      OUTPUT TO REPORT pol0917_relat(P_relat.dat_cadastro) 
      
      LET p_count = 1 
      
   END FOREACH

   FINISH REPORT pol0917_relat

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF p_count = 0 THEN
      ERROR "Não existem dados a serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
   END IF

  
END FUNCTION 

#-----------------------------------#
 REPORT pol0917_relat(p_dat_cadastro)
#-----------------------------------#
  
  DEFINE p_dat_cadastro LIKE frete_solicit_885.dat_cadastro
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 2
          BOTTOM MARGIN 2
          PAGE   LENGTH 66
          
  ORDER EXTERNAL BY p_dat_cadastro     
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "POL0917",
               COLUMN 021, "PESO TRANSPORTADO POR CAMINHÃO",
               COLUMN 057,  CURRENT
         PRINT
         PRINT
         PRINT COLUMN 001, "   DATA    TRANSPORTADOR        NOME       CHAPA      VEICULO         PESO"
         PRINT COLUMN 001, "---------- --------------- --------------- ------- --------------- -------------"
         
      ON EVERY ROW

         PRINT COLUMN 001, p_Relat.dat_cadastro,
               COLUMN 012, p_Relat.cod_transpor,
               COLUMN 028, p_Relat.nom_reduzido,
               COLUMN 044, p_Relat.num_chapa,
               COLUMN 052, p_relat.cod_veiculo,
               COLUMN 068, p_relat.peso_carga    USING '#,###,##&.&&&'
      
      AFTER GROUP OF p_dat_cadastro 
         PRINT
         PRINT COLUMN 054, 'TOTAL DO DIA:', 
                            GROUP SUM(p_relat.peso_carga)  USING '##,###,##&.&&&'
         SKIP 3 LINES   
      
      
      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 033, "* * * ULTIMA FOLHA * * *"
           LET p_last_row = FALSE
        ELSE 
           PRINT " "
        END IF
         
                        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#




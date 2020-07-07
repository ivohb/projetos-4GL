#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                   #
# PROGRAMA: pol0805                                                 #
# MODULOS.: pol0805-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: RELATÓRIO NOTAS FISCAIS DE SAIDA                        #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 28/11/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_status             SMALLINT,
          p_count              SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_expande            CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_tot_cli            DECIMAL(15,2),
          p_tot_ger            DECIMAL(15,2)
          
   DEFINE p_tela        RECORD
      dat_ini           DATE,
      dat_fim           DATE
   END RECORD 

   DEFINE p_cliente     RECORD
      cod_cliente       LIKE clientes.cod_cliente,
      nom_cliente       LIKE clientes.nom_cliente
   END RECORD

   DEFINE p_relat         RECORD 
          num_nff         LIKE nf_mestre.num_nff,
          dat_emissao     LIKE nf_mestre.dat_emissao,
          cod_cliente     LIKE clientes.cod_cliente,
          nom_cliente     LIKE clientes.nom_cliente,
          val_tot_nff     LIKE nf_mestre.val_tot_nff
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0805-05.10.00"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0805_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0805_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0805") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0805 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF pol0805_cria_temp() THEN
            IF pol0805_informar() THEN
               MESSAGE "Parâmetros informados com sucesso !!!" ATTRIBUTE(REVERSE)
               LET p_ies_cons = TRUE
               NEXT OPTION "Listar"
            ELSE
               CLEAR FORM
               DISPLAY p_cod_empresa TO cod_empresa
               ERROR "Operação Cancelada !!!"
            END IF
         END IF 
      COMMAND "Listar" "Lista Notas Fiscais de Saída"
         MESSAGE ""
         IF log0280_saida_relat(18,35) IS NOT NULL THEN
            IF p_ies_impressao = "S" THEN
               CALL log150_procura_caminho ('LST') RETURNING p_caminho
               LET p_caminho = p_caminho CLIPPED, 'pol0805.tmp'
               START REPORT pol0805_relat  TO p_caminho
            ELSE
               START REPORT pol0805_relat TO p_nom_arquivo
            END IF
            MESSAGE " Processando a Extracao do Relatorio..." 
            CALL pol0805_emite_relatorio()   
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
  
   CLOSE WINDOW w_pol0805

END FUNCTION


#-----------------------------#
FUNCTION pol0805_cria_temp()
#-----------------------------#

   DROP TABLE cli_sel_tmp;

   CREATE TABLE cli_sel_tmp
   (
      cod_cliente CHAR(15)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","cli_sel_tmp")
      RETURN FALSE
   END IF

   DROP TABLE nf_mark_temp;

   RETURN TRUE

END FUNCTION



#--------------------------#
FUNCTION pol0805_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini       
      END IF 

      AFTER FIELD dat_fim   
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF 
         IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
            ERROR "Periodo nao pode ser maior que 720 Dias"
            NEXT FIELD dat_ini
         END IF 
      END IF 
      
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0805_aceita_clientes() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0805_aceita_clientes()
#--------------------------------#

   INITIALIZE where_clause TO NULL

   CONSTRUCT BY NAME where_clause ON 
       clientes.cod_cliente,
       clientes.nom_cliente,
       clientes.cod_cidade

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF where_clause IS NULL THEN
      ERROR 'Aguarde!... Carregando dados.'
      INSERT INTO cli_sel_tmp
       SELECT cod_cliente FROM clientes
      
      IF STATUS = 0 THEN 
         RETURN TRUE
      ELSE
         CALL log003_err_sql('Inserindo','cli_sel_tmp')
         RETURN FALSE
      END IF
   END IF

   LET sql_stmt = "SELECT cod_cliente FROM clientes ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","clientes")            
      RETURN FALSE
   END IF

   OPEN cq_padrao

   ERROR 'Aguarde!... Carregando dados.'
   
   FOREACH cq_padrao INTO p_cod_cliente

      INSERT INTO cli_sel_tmp
        VALUES(p_cod_cliente)

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("Inserindo","cli_sel_tmp")
         RETURN FALSE
      END IF

   END FOREACH

   SELECT COUNT(cod_cliente)
     INTO p_count
     FROM cli_sel_tmp
   
   IF p_count = 0 THEN
      MESSAGE 'Argumentos de Pesquisa Não Encontrado !!!' ATTRIBUTE(REVERSE)
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 FUNCTION pol0805_emite_relatorio()
#---------------------------------#

   SELECT den_empresa 
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_expande     = ascii 14
   
   DECLARE cq_nf_mestre CURSOR FOR
    SELECT nf_mestre.num_nff,
           nf_mestre.dat_emissao,
           nf_mestre.cod_cliente,
           nf_mestre.val_tot_nff
      FROM nf_mestre
     WHERE nf_mestre.cod_empresa = p_cod_empresa
       AND (nf_mestre.dat_emissao BETWEEN p_tela.dat_ini AND p_tela.dat_fim)
       AND nf_mestre.cod_cliente
           IN (SELECT cli_sel_tmp.cod_cliente FROM cli_sel_tmp)
     ORDER BY nf_mestre.cod_cliente
     
   FOREACH cq_nf_mestre INTO
           p_relat.num_nff,
           p_relat.dat_emissao,
           p_relat.cod_cliente,
           p_relat.val_tot_nff

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_nf_mestre')
         EXIT FOREACH
      END IF
   
      SELECT nom_cliente
        INTO p_relat.nom_cliente
        FROM clientes
       WHERE cod_cliente  = p_relat.cod_cliente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Clientes')
         EXIT FOREACH
      END IF
         
      OUTPUT TO REPORT pol0805_relat(p_relat.cod_cliente)
      
      LET p_count = p_count + 1
      
   END FOREACH

   IF p_count > 0 THEN
      MESSAGE "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "Não existem dados para os parâmetros informados" ATTRIBUTE(REVERSE)
   END IF
   
   FINISH REPORT pol0805_relat   

   IF p_ies_impressao = "S" THEN
      ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
      LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
      RUN comando
   ELSE
      ERROR "Relatorio Gravado no Arquivo ",p_nom_arquivo
   END IF
   
END FUNCTION 


#----------------------------------#
REPORT pol0805_relat(p_cod_cliente)
#----------------------------------#

   DEFINE p_cod_cliente LIKE clientes.cod_cliente

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 2
          PAGE  LENGTH 66
   
      ORDER EXTERNAL BY p_cod_cliente
          
   FORMAT

      PAGE HEADER
   
         PRINT
         PRINT COLUMN 001,  p_den_empresa,
               COLUMN 042, "NOTAS FISCAIS DE SAIDA",
               COLUMN 071, "PAG: ", PAGENO USING "&&&&&"
         
         PRINT COLUMN 001, "pol0805",
               COLUMN 017, "PERIODO: ", p_tela.dat_ini, " - ", p_tela.dat_fim,
               COLUMN 052, "EMISSAO: ", TODAY USING "DD/MM/YYYY", " - ", TIME
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 0001, 'NUM NF DT EMISSAO COD CLIENTE     RAZ SOCIAL                            VALOR NF'
         PRINT COLUMN 0001, '------ ---------- --------------- ------------------------------ ---------------'

      BEFORE GROUP OF p_cod_cliente
      
         SKIP TO TOP OF PAGE
         
      ON EVERY ROW

        PRINT COLUMN 001, p_relat.num_nff USING '######',
               COLUMN 008, p_relat.dat_emissao,
               COLUMN 019, p_relat.cod_cliente,
               COLUMN 035, p_relat.nom_cliente[1,30],
               COLUMN 066, p_relat.val_tot_nff USING '####,###,##&.&&'

      AFTER GROUP OF p_cod_cliente
         PRINT COLUMN 0001, p_negrito
         PRINT COLUMN 051, 'TOTAL CLIENTE: ',
               COLUMN 066, GROUP SUM(p_relat.val_tot_nff) USING '####,###,##&.&&'
         PRINT COLUMN 0001, p_normal
         
      ON LAST ROW
      
         PRINT COLUMN 001, p_negrito
         PRINT COLUMN 051, 'TOTAL GERAL..: ',
               COLUMN 066, SUM(p_relat.val_tot_nff) USING '####,###,##&.&&'
         PRINT COLUMN 0001, p_normal
         
END REPORT


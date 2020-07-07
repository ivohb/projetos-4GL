#-------------------------------------------------------------------#
# PROGRAMA: pol1220                                                 #
# CLIENTE.: KF                                                      #
# OBJETIVO: UNIDADES QUE RECEBERÃO O EDI                            #
# AUTOR...: IVO                                                     #
# DATA....: 28/08/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_fornecedor     LIKE fornec_edi_454.cod_fornecedor,
          p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_raz_social         LIKE fornecedor.raz_social,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_last_row           SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_msg                CHAR(300),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100)
          
          
   DEFINE p_fornec_edi_454       RECORD LIKE fornec_edi_454.*,
          p_fornec_edi_454a      RECORD LIKE fornec_edi_454.* 
          
END GLOBALS

DEFINE p_relat     RECORD
       cod_fornecedor     LIKE fornecedor.cod_fornecedor,              
       num_cgc_cpf        LIKE fornecedor.num_cgc_cpf,
       raz_social         LIKE fornecedor.raz_social,
       nom_contato        LIKE fornecedor.nom_contato,
       num_telefone       LIKE fornecedor.num_telefone,
       e_mail             LIKE fornec_compl.e_mail,
       email_secund       LIKE fornec_compl.email_secund
END RECORD                  
          
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1220-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1220.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1220_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1220_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1220") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1220 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa to cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol1220_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol1220_exclusao() THEN
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
         CALL pol1220_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1220_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1220_paginacao("ANTERIOR")
      COMMAND "Listar" "Listagem"
         CALL pol1220_listagem()     
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1220_sobre()
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1220

END FUNCTION

#--------------------------#
 FUNCTION pol1220_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
   INITIALIZE p_fornec_edi_454.* TO NULL

   IF pol1220_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO fornec_edi_454 VALUES (p_fornec_edi_454.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
      ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa to cod_empresa
   END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol1220_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   let INT_FLAG = false;
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1220

   INPUT BY NAME p_fornec_edi_454.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_fornecedor
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD raz_social
      END IF 
      
      AFTER FIELD cod_fornecedor
      IF p_fornec_edi_454.cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_fornecedor
      ELSE
         SELECT raz_social
         INTO p_raz_social
         FROM fornecedor
         WHERE cod_fornecedor = p_fornec_edi_454.cod_fornecedor
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Fornecedor nao Cadastrado no Logix !!!" 
            NEXT FIELD cod_fornecedor
         END IF
                  
           SELECT cod_fornecedor
           INTO p_cod_fornecedor
           FROM fornec_edi_454
          WHERE cod_fornecedor = p_fornec_edi_454.cod_fornecedor
            
          
         IF STATUS = 0 THEN
            ERROR "Fornecedor já Cadastrado no EDI !!!"
            NEXT FIELD cod_fornecedor
         END IF
         
         DISPLAY p_raz_social TO raz_social 
      END IF
         
         ON KEY (control-z)
            LET p_cod_fornecedor = sup162_popup_fornecedor()
            IF p_cod_fornecedor IS NOT NULL THEN
               LET p_fornec_edi_454.cod_fornecedor = p_cod_fornecedor
               CURRENT WINDOW IS w_pol1220
               DISPLAY p_fornec_edi_454.cod_fornecedor TO cod_fornecedor
            END IF
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1220

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol1220_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   LET INT_FLAG = false;
   
   LET p_fornec_edi_454a.* = p_fornec_edi_454.*

   CONSTRUCT BY NAME where_clause ON fornec_edi_454.cod_fornecedor
  
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_fornec_edi_454.* = p_fornec_edi_454a.*
      CALL pol1220_exibe_dados()
      CLEAR FORM         
      DISPLAY p_cod_empresa to cod_empresa
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM fornec_edi_454 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_fornecedor "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_fornec_edi_454.*
   IF status <> 0 THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol1220_exibe_dados()
      ERROR 'Operação efetuada com sucesso'
   END IF
   

END FUNCTION

#------------------------------#
 FUNCTION pol1220_exibe_dados()
#------------------------------#
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_fornec_edi_454.cod_fornecedor

   DISPLAY BY NAME p_fornec_edi_454.*
   DISPLAY p_raz_social TO raz_social
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol1220_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_fornec_edi_454.*                                              
     FROM fornec_edi_454
    WHERE cod_fornecedor = p_fornec_edi_454.cod_fornecedor
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","fornec_edi_454")   
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1220_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol1220_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM fornec_edi_454
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_fornec_edi_454.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa to cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","fornec_edi_454")
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
 FUNCTION pol1220_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_fornec_edi_454a.* = p_fornec_edi_454.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_fornec_edi_454.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_fornec_edi_454.*
         END CASE

         IF status <> 0 THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_fornec_edi_454.* = p_fornec_edi_454a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_fornec_edi_454.*
           FROM fornec_edi_454
          WHERE cod_fornecedor = p_fornec_edi_454.cod_fornecedor 
           
                
         IF status = 0 THEN  
            CALL pol1220_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol1220_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------#
FUNCTION pol1220_listagem()
#-------------------------#     

   IF NOT pol1220_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1220_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT b.cod_fornecedor,                 
           b.num_cgc_cpf,                    
           b.raz_social,
           b.nom_contato,         
           b.num_telefone,                   
           c.e_mail,                         
           c.email_secund                    
     FROM fornec_edi_454 a,                  
          fornecedor b,                      
          fornec_compl c                     
    WHERE a.cod_fornecedor = b.cod_fornecedor
      AND a.cod_fornecedor = c.cod_fornecedor
    ORDER BY b.num_cgc_cpf                   
   
   FOREACH cq_impressao INTO 
           p_relat.cod_fornecedor,
           p_relat.num_cgc_cpf,   
           p_relat.raz_social,    
           p_relat.nom_contato,   
           p_relat.num_telefone,  
           p_relat.e_mail,        
           p_relat.email_secund  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
               
      OUTPUT TO REPORT pol1220_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1220_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1220_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1220.tmp"
         START REPORT pol1220_relat TO p_caminho
      ELSE
         START REPORT pol1220_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1220_le_empresa()
#---------------------------#

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

#---------------------#
 REPORT pol1220_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 116, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1220",
               COLUMN 050, "UNIDADES PARA ENVIO DE EDI",
               COLUMN 103, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  FORNECEDOR        C.N.P.J            RAZAO SOCIAL / CONTATO                  TELEFONE                EMAILs'
         PRINT COLUMN 001, '--------------- ------------------- ---------------------------------------- --------------- ------------------------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 116, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1220",
               COLUMN 050, "UNIDADES PARA ENVIO DE EDI",
               COLUMN 103, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  FORNECEDOR        C.N.P.J            RAZAO SOCIAL / CONTATO                  TELEFONE                EMAILs'
         PRINT COLUMN 001, '--------------- ------------------- ---------------------------------------- --------------- ------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_fornecedor,
               COLUMN 017, p_relat.num_cgc_cpf,
               COLUMN 037, p_relat.raz_social[1,40],
               COLUMN 078, p_relat.num_telefone,
               COLUMN 094, p_relat.e_mail

         IF p_relat.nom_contato IS NOT NULL OR
            p_relat.email_secund IS NOT NULL THEN
            PRINT COLUMN 037, p_relat.nom_contato,
                  COLUMN 094, p_relat.email_secund
         ELSE
            LET p_msg = ''
         END IF
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
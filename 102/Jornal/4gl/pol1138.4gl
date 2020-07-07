#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: INTEGRAÇÃO LOGIX X OMC                                  #
# PROGRAMA: pol1138                                                 #
# OBJETIVO: Consulta dos clientes rejeitados pelo logix             #
# AUTOR...: Willians                                                #
# DATA....: 17/04/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
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
          p_comando            CHAR(200),
          comando              CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT

   DEFINE p_id_registro        INTEGER,
          p_id_registroa       INTEGER,
          p_excluiu            SMALLINT,
          P_cod_cliente        CHAR(15),
          p_nom_cliente        CHAR(35),
          p_num_cnpj_cpf       CHAR(15),
          p_tip_cliente        CHAR(01),
          p_motivo             CHAR(70)

   DEFINE pr_motivo            ARRAY[100] OF RECORD      
          motivo               CHAR(70)
   END RECORD
   
   DEFINE p_clientes           RECORD
          cod_cliente	         LIKE clientes_509.cod_cliente,
          num_cnpj_cpf         LIKE clientes_509.num_cnpj_cpf,
          tip_cliente	         LIKE clientes_509.tip_cliente,
          nom_cliente	         LIKE clientes_509.nom_cliente,
          nom_reduzido         LIKE clientes_509.nom_reduzido,
          end_cliente	         LIKE clientes_509.end_cliente,
          den_bairro	         LIKE clientes_509.den_bairro,
          cidade               LIKE clientes_509.cidade,
          cod_cidade           LIKE clientes_509.cod_cidade,
          cod_cep              LIKE clientes_509.cod_cep,
          estado               LIKE clientes_509.estado,
          num_telefone         LIKE clientes_509.num_telefone,
          num_fax	             LIKE clientes_509.num_fax,
          insc_municipal       LIKE clientes_509.insc_municipal,
          insc_estadual        LIKE clientes_509.insc_estadual,
          end_cob              LIKE clientes_509.end_cob,
          bairro_cob           LIKE clientes_509.bairro_cob,
          cidade_cob           LIKE clientes_509.cidade_cob,
          cod_cid_cob	         LIKE clientes_509.cod_cid_cob,
          estado_cob           LIKE clientes_509.estado_cob,
          cod_cep_cob	         LIKE clientes_509.cod_cep_cob,
          contato              LIKE clientes_509.contato,
          cli_fornec           LIKE clientes_509.cli_fornec,
          email1	             LIKE clientes_509.email1,
          email2	             LIKE clientes_509.email2,
          email3	             LIKE clientes_509.email3
   END RECORD	        
                   
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1138-10.02.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1138_menu()
   END IF

END MAIN

#----------------------#
 FUNCTION pol1138_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1138") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1138 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
     
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1138_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1138_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1138_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados dos clientes rejeitados."
         IF p_ies_cons THEN
            CALL pol1138_modificar() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
     COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1138_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1138_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1138_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1138

END FUNCTION

#-----------------------#
 FUNCTION pol1138_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION     

#----------------------------#
FUNCTION pol1138_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION

#--------------------------#
FUNCTION pol1138_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1138_limpa_tela()
   LET p_id_registroa = p_id_registro
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      clientes_509.cod_cliente,
      clientes_509.nom_cliente,
      clientes_509.num_cnpj_cpf,
      clientes_509.tip_cliente
      
      ON KEY (control-z)
         CALL pol1138_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1138_limpa_tela()
         ELSE
            LET p_id_registro = p_id_registroa
            CALL pol1138_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT id_registro, cod_cliente",
                  "  FROM clientes_509 ",
                  " WHERE ", where_clause CLIPPED, 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "   AND cod_estatus = 'R' ",
				          "   AND id_registro IN (SELECT id_cliente FROM rejeicao_cli_509) ",
                  " ORDER BY cod_cliente"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1138_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1138_exibe_dados()
#------------------------------#
   
   SELECT cod_cliente,
          nom_cliente,
          num_cnpj_cpf,
          tip_cliente
     INTO p_cod_cliente,
          p_nom_cliente,
          p_num_cnpj_cpf,
          p_tip_cliente
     FROM clientes_509
    WHERE id_registro = p_id_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "clientes_509")
      RETURN FALSE
   END IF
      
   DISPLAY p_cod_cliente  TO cod_cliente
   DISPLAY p_nom_cliente  TO nom_cliente
   DISPLAY p_num_cnpj_cpf TO num_cnpj_cpf
   DISPLAY p_tip_cliente  TO tip_cliente
                                       
   CALL pol1138_le_motivo()
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1138_le_motivo()
#--------------------------#

   INITIALIZE pr_motivo to null
   LET p_ind = 1
   
   DECLARE cq_mot CURSOR FOR
    SELECT motivo
      FROM rejeicao_cli_509
     WHERE id_cliente = p_id_registro
  ORDER BY motivo

   FOREACH cq_mot 
      INTO pr_motivo[p_ind].motivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','CQ_MOT')       
         RETURN
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 100 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   CALL SET_COUNT(p_ind - 1)

   IF p_ind > 10 THEN
      DISPLAY ARRAY pr_motivo TO sr_motivo.*
   ELSE
      INPUT ARRAY pr_motivo WITHOUT DEFAULTS FROM sr_motivo.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION
   
   

#-----------------------------------#
 FUNCTION pol1138_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_id_registroa = p_id_registro
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cliente
           FROM clientes_509
          WHERE id_registro = p_id_registro
            
         IF STATUS = 0 THEN
            CALL pol1138_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_id_registro = p_id_registroa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#-----------------------#
FUNCTION pol1138_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11381
         IF p_codigo IS NOT NULL THEN
            LET p_clientes.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

   END CASE   

END FUNCTION

#----------------------------------#
 FUNCTION pol1138_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT id_registro 
      FROM clientes_509  
     WHERE id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH","CQ_PRENDE")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1138_modificar()
#--------------------------#

   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF pol1138_prende_registro() THEN
      IF pol1138_edita_cliente() THEN
         
         UPDATE clientes_509
            SET cod_cliente	   = p_clientes.cod_cliente,	  
                num_cnpj_cpf   = p_clientes.num_cnpj_cpf,  
                tip_cliente	   = p_clientes.tip_cliente,	  
                nom_cliente	   = p_clientes.nom_cliente,	  
                nom_reduzido   = p_clientes.nom_reduzido,  
                end_cliente	   = p_clientes.end_cliente,	  
                den_bairro	   = p_clientes.den_bairro,	  
                cidade         = p_clientes.cidade,        
                cod_cidade     = p_clientes.cod_cidade,    
                cod_cep        = p_clientes.cod_cep,       
                estado         = p_clientes.estado,       
                num_telefone   = p_clientes.num_telefone,  
                num_fax	       = p_clientes.num_fax,	      
                insc_municipal = p_clientes.insc_municipal,
                insc_estadual  = p_clientes.insc_estadual, 
                end_cob        = p_clientes.end_cob,       
                bairro_cob     = p_clientes.bairro_cob,    
                cidade_cob     = p_clientes.cidade_cob,    
                cod_cid_cob	   = p_clientes.cod_cid_cob,	  
                estado_cob     = p_clientes.estado_cob,    
                cod_cep_cob	   = p_clientes.cod_cep_cob,	  
                contato        = p_clientes.contato,
                email1	       = p_clientes.email1,	      
                email2	       = p_clientes.email2,	      
                email3	       = p_clientes.email3,               
                cli_fornec     = p_clientes.cli_fornec
          WHERE id_registro    = p_id_registro
                            
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE", "clientes_509")
         ELSE
            LET p_retorno = TRUE
         END IF
               
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      CALL pol1138_consiste_registro() RETURNING p_status
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   CALL pol1138_exibe_dados()
   
   RETURN p_retorno

END FUNCTION

#------------------------------#
FUNCTION pol1138_edita_cliente()
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11381") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11381 AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   SELECT cod_cliente,	   
          num_cnpj_cpf,   
          tip_cliente,	   
          nom_cliente,	   
          nom_reduzido,   
          end_cliente,	   
          den_bairro,	   
          cidade,         
          cod_cidade,     
          cod_cep,        
          estado,         
          num_telefone,   
          num_fax,	       
          insc_municipal, 
          insc_estadual,  
          end_cob,        
          bairro_cob,     
          cidade_cob,     
          cod_cid_cob,	   
          estado_cob,     
          cod_cep_cob,	   
          contato,        
          cli_fornec,
          email1,	       
          email2,	       
          email3,
          nom_arquivo
     INTO p_clientes.*,
          p_nom_arquivo
     FROM clientes_509
    WHERE id_registro = p_id_registro   
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "clientes_509")
      RETURN FALSE
   END IF 
          
   INPUT BY NAME p_clientes.* 
      WITHOUT DEFAULTS
   
      ON KEY (control-z)
         CALL pol1138_popup()

   END INPUT
   
   CLOSE WINDOW w_pol11381
   
	 IF INT_FLAG THEN
      RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#----------------------------------#
FUNCTION pol1138_consiste_registro()
#----------------------------------#

   DELETE FROM rejeicao_cli_509
    WHERE id_cliente = p_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','rejeicao_cli_509')
      RETURN FALSE
   END IF

   IF p_clientes.cli_fornec MATCHES '[CF]' THEN
      IF p_clientes.cli_fornec = 'C' THEN
         IF NOT pol1138_consiste_cliente() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1138_consiste_fornec() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_msg = 'IDENTIFICADOR CLIENTE/FORNECEDOR INVALIDO'
      CALL pol1138_ins_rejei_cli()
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1138_consiste_cliente()
#---------------------------------#

   DEFINE p_cid_ibeg INTEGER
   
   IF p_clientes.cod_cliente IS NULL THEN
      LET p_msg = 'CODIGO DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   END IF

   IF p_clientes.tip_cliente IS NULL THEN
      LET p_msg = 'TIPO DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      IF p_clientes.tip_cliente MATCHES '[AFJ]' THEN
      ELSE
         LET p_msg = 'TIPO DO CLIENTE INVALIDO'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.num_cnpj_cpf IS NULL THEN
      LET p_msg = 'CGC/CPF DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      IF LENGTH(p_clientes.num_cnpj_cpf) = 14 OR 
         LENGTH(p_clientes.num_cnpj_cpf) = 11 THEN
      ELSE
         LET p_msg = 'CGC/CPF DO CLIENTE INVALIDO'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.nom_cliente IS NULL THEN
      LET p_msg = 'NOME DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   END IF

   IF p_clientes.end_cliente IS NULL THEN
      LET p_msg = 'ENDERECO DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      SELECT count(cod_cliente) 
		    INTO p_count 
		    FROM clientes_509
		   WHERE cod_cliente = p_clientes.cod_cliente
		     AND end_cliente LIKE '%,%'  
		
      IF p_count = 0 THEN 
         LET p_msg = 'ENDERECO DO CLIENTE NAO CONTEM VIRGULA'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF
   
   IF p_clientes.cod_cidade IS NULL THEN
      LET p_msg = 'COD CIDADE DO CLIENTE ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      LET p_cid_ibeg = p_clientes.cod_cidade
      
      SELECT cidade_logix
        FROM obf_cidade_ibge
		   WHERE cidade_ibge = p_cid_ibeg
      
      IF STATUS = 100 THEN
         LET p_msg = 'COD COD CIDADE NAO CADASTRADO NA OBF_CIDADE_IBGE'
         CALL pol1138_ins_rejei_cli()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO COD CIDADE')
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1138_consiste_fornec()
#---------------------------------#

   DEFINE p_cid_ibeg INTEGER
   
   IF p_clientes.cod_cliente IS NULL THEN
      LET p_msg = 'CODIGO DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   END IF

   IF p_clientes.tip_cliente IS NULL THEN
      LET p_msg = 'TIPO DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      IF p_clientes.tip_cliente MATCHES '[AFJ]' THEN
      ELSE
         LET p_msg = 'TIPO DO FORNECEDOR INVALIDO'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.num_cnpj_cpf IS NULL THEN
      LET p_msg = 'CGC/CPF DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      IF LENGTH(p_clientes.num_cnpj_cpf) = 14 OR 
         LENGTH(p_clientes.num_cnpj_cpf) = 11 THEN
      ELSE
         LET p_msg = 'CGC/CPF DO FORNECEDOR INVALIDO'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.nom_cliente IS NULL THEN
      LET p_msg = 'NOME DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   END IF

   IF p_clientes.end_cliente IS NULL THEN
      LET p_msg = 'ENDERECO DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      SELECT count(cod_cliente) 
		    INTO p_count 
		    FROM clientes_509
		   WHERE cod_cliente = p_clientes.cod_cliente
		     AND end_cliente LIKE '%,%'  
		
      IF p_count = 0 THEN 
         LET p_msg = 'ENDERECO DO FORNECEDOR NAO CONTEM VIRGULA'
         CALL pol1138_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.cod_cidade IS NULL THEN
      LET p_msg = 'COD CIDADE DO FORNECEDOR ESTA NULO'
      CALL pol1138_ins_rejei_cli()
   ELSE
      LET p_cid_ibeg = p_clientes.cod_cidade
      
      SELECT cidade_logix
        FROM obf_cidade_ibge
		   WHERE cidade_ibge = p_cid_ibeg
      
      IF STATUS = 100 THEN
         LET p_msg = 'COD CIDADE NAO CADASTRADO NA OBF_CIDADE_IBGE'
         CALL pol1138_ins_rejei_cli()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO COD CIDADE')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1138_ins_rejei_cli()
#-------------------------------#

   INSERT INTO rejeicao_cli_509
    VALUES(p_cod_empresa,
           p_nom_arquivo,
           p_id_registro,
           p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','rejeicao_cli_509')
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1138_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1138_prende_registro() THEN
      DELETE FROM clientes_509
			 WHERE id_registro = p_id_registro

      IF STATUS = 0 THEN               
         
         DELETE FROM rejeicao_cli_509
          WHERE id_cliente = p_id_registro 
         
         IF STATUS = 0 THEN
         
    #        INITIALIZE p_clientes.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
            LET p_excluiu = TRUE                     
         ELSE
            CALL log003_err_sql("Excluindo","rejeicao_cli_509")
         END IF
      ELSE
         CALL log003_err_sql("Excluindo","clientes_509")
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
 FUNCTION pol1138_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1138_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1138_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_cliente,
          nom_cliente,
          num_cnpj_cpf,
          tip_cliente,
          id_registro
     FROM clientes_509
 ORDER BY cod_cliente                          
  
   FOREACH cq_impressao 
      INTO p_cod_cliente,
           p_nom_cliente,
           p_num_cnpj_cpf,
           p_tip_cliente,
           p_id_registro
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      DECLARE cq_motivo CURSOR FOR
      
      SELECT motivo
        FROM rejeicao_cli_509
       WHERE id_cliente = p_id_registro
       
      FOREACH cq_motivo
         INTO p_motivo
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'CURSOR: cq_motivo')
            RETURN
         END IF
         
         EXIT FOREACH
         
      END FOREACH
         
      OUTPUT TO REPORT pol1138_relat(p_cod_cliente) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1138_relat   
   
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
 FUNCTION pol1138_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1138.tmp"
         START REPORT pol1138_relat TO p_caminho
      ELSE
         START REPORT pol1138_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1138_le_den_empresa()
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
 REPORT pol1138_relat(p_cod_cliente)
#----------------------------------#
    
   DEFINE p_cod_cliente LIKE clientes_509.cod_cliente
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, p_comprime,
               COLUMN 088, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1138",
               COLUMN 019, "CLIENTES REJEITADOS - LOGIX X OMC",
               COLUMN 068, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "------------------------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_cod_cliente
         
         PRINT
         PRINT COLUMN 002, "Cliente: ", p_cod_cliente, " - ", p_nom_cliente, " CNPJ/CPF: ", p_num_cnpj_cpf, " Tipo: ", p_tip_cliente
         PRINT
         PRINT COLUMN 002, '                                         Motivos'
         PRINT COLUMN 002, '         --------------------------------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 011, p_motivo

      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 033, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

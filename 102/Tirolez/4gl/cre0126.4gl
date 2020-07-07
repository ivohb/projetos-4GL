#-----------------------------------------------------------------#
# SISTEMA.: CRECEBER                                              #
# PROGRAMA: CRE0126                                               #
# OBJETIVO: MANUTENCAO DA TABELA TIROLEZ_CLIENTES                 #
# AUTOR...: KARINE DO NASCIEMENTO  - BI                           #
# MODIFICA��O....: 
# - 25/05/2006 - ivo                                              #
# Campo Zona                                                      #
#    Alterar tamanho do campo TIROLEZ_CLIENTES.COD_ZONA           #
#    aumentar para 5 caracteres.                                  #
# - 27/05/16 IVO                                                  #
# Campo Atendimento:                                              #
#    Ser� armazenado no campo TIROLEZ_CLIENTES.PAR_TXT            #
#      na posi��o 12 com 2.                                       #
#    O campo � validado com a tabela                              #
#      TIROLEZ_CLI_ATENDIMENTO.COD_ATENDIMENTO. (2h)              #
#                                                                 #
# - 30/05/16 - IVO                                                #
#   Programa continha erro de l�gia na consulta e na modifica��o  #
#   Fiz os ajustes neces�rios para funiconar corretamente  (3h)   #
#-----------------------------------------------------------------#

{
Esta sem valida��o o campo Faixa de produto utilizada para validar os produtos no coletor:
1-Este campo sempre tem que ter numeros de 01 a 99
2-a tabela que ele deve validar � a tabela tirolez_coletor_item_validade  
e no campo tabela, se existir pode aceitar, como nesta tabela � tabela por produto, 
logicamente teremos a tabela 01 com mais de 140 registros, sendo assim a unica 
consist�ncia � ver se existe nesta tabela esta numero de tabela existe e mais nada.
Com isto eu vou saber se existe a tabela e deixar o sisstema proseguir.
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
           p_user                 LIKE usuario.nom_usuario,
           p_status               SMALLINT

    DEFINE p_ies_impressao        CHAR(001),
           g_ies_ambiente         CHAR(001),
           p_nom_arquivo          CHAR(100),
           p_nom_arquivo_back     CHAR(100),
           p_msg                  CHAR(300)
           
    DEFINE g_ies_grafico          SMALLINT

    DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

    DEFINE m_den_empresa          LIKE empresa.den_empresa
    DEFINE m_consulta_ativa       SMALLINT

    DEFINE sql_stmt               CHAR(800),
           m_last_row             SMALLINT,
           where_clause           CHAR(400),
           m_cod_cliente          CHAR(15)

    DEFINE m_comando              CHAR(080)

    DEFINE m_caminho              CHAR(150)

    DEFINE m_camh_help_cre0126   CHAR(150)


    DEFINE mr_tirolez_clientes       RECORD LIKE tirolez_clientes.*,
           mr_tirolez_clientesr      RECORD LIKE tirolez_clientes.*

    DEFINE m_nom_cliente             LIKE clientes.nom_cliente

DEFINE p_tela             RECORD
       cod_canal          CHAR(02),
       den_canal          CHAR(40),
       cod_atividade      CHAR(02),
       cod_atendimento    CHAR(02),
       den_atividade      CHAR(40),
       aceita_peso        CHAR(01),
       pct_peso           DECIMAL(2,0),
       faixa_produto      CHAR(02),
       ies_edi            CHAR(01),
       ies_integra        CHAR(01)
END RECORD

DEFINE p_den_canal     CHAR(40),
       p_den_atividade CHAR(40),       
       p_den_atendimento CHAR(40)
MAIN

     CALL log0180_conecta_usuario()

    LET p_versao = 'CRE0126-10.02.09' 

    WHENEVER ANY ERROR CONTINUE

    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120

    WHENEVER ANY ERROR STOP

    DEFER INTERRUPT

    LET m_camh_help_cre0126 = log140_procura_caminho('cre0126.iem')

    OPTIONS

        PREVIOUS KEY control-b,
        NEXT     KEY control-f,
        HELP     FILE m_camh_help_cre0126

    CALL log001_acessa_usuario('CRECEBER','LOGERP')
         RETURNING p_status, p_cod_empresa, p_user

    IF  p_status = 0 THEN
        CALL cre0126_controle()
    END IF
END MAIN

#---------------------------#
FUNCTION cre0126_controle()
#---------------------------#
    CALL log006_exibe_teclas('01', p_versao)

    CALL cre0126_inicia_variaveis()

    LET m_caminho = log1300_procura_caminho('cre0126','')
    OPEN WINDOW w_cre0126 AT 2,1 WITH FORM m_caminho
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
    MENU 'OPCAO'
        COMMAND 'Incluir'   'Inclui um novo item na tabela tirolez_clientes.'
            HELP 001
            MESSAGE ''
            IF  log005_seguranca(p_user, 'CRECEBER', 'CRE0126', 'IN') THEN
                 CALL cre0126_inclusao_tirolez_clientes()
            END IF

        COMMAND 'Modificar' 'Modifica um item existente na tabela tirolez_clientes.'
            HELP 002
            MESSAGE ''
            IF  m_consulta_ativa THEN
                IF  log005_seguranca(p_user, 'CRECEBER', 'CRE0126', 'MO') THEN
                    CALL cre0126_modificacao_tirolez_clientes()
                END IF
            ELSE
                ERROR ' Consulte previamente para fazer a modifica��o. '
            END IF

       COMMAND 'Excluir'   'Exclui um item existente na tabela tirolez_clientes.'
           HELP 003
           MESSAGE ''
           IF  m_consulta_ativa THEN
               IF  log005_seguranca(p_user, 'CRECEBER', 'CRE0126', 'EX') THEN
                   CALL cre0126_exclusao_tirolez_clientes()
               END IF
           ELSE
               ERROR ' Consulte previamente para fazer a exclus�o. '
           END IF

        COMMAND 'Consultar' 'Pesquisa a tabela tirolez_clientes.'
            HELP 004
            MESSAGE ''
            IF  log005_seguranca(p_user, 'CRECEBER' , 'CRE0126', 'CO') THEN
                CALL cre0126_consulta_tirolez_clientes()
            END IF

        COMMAND 'Seguinte'  'Exibe o pr�ximo item encontrado na pesquisa.'
            HELP 005
            MESSAGE ''
            IF  m_consulta_ativa THEN
                CALL cre0126_paginacao('SEGUINTE')
            ELSE
                ERROR ' N�o existe nenhuma consulta ativa. '
            END IF

        COMMAND 'Anterior'  'Exibe o item anterior encontrado na pesquisa'
            HELP 006
            MESSAGE ''
            IF  m_consulta_ativa THEN
                CALL cre0126_paginacao('ANTERIOR')
            ELSE
                ERROR ' N�o existe nenhuma consulta ativa. '
            END IF

        COMMAND 'Listar'    'Lista a tabela tirolez_clientes.'
            HELP 007
            MESSAGE ''
            IF  log005_seguranca(p_user, 'CRECEBER', 'CRE0126', 'CO') THEN
                IF  log0280_saida_relat(16,30) IS NOT NULL THEN
                    CALL cre0126_lista_tirolez_clientes()
                END IF
            END IF
       COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL cre0126_sobre()
       COMMAND KEY ('!')
            PROMPT 'Digite o comando : ' FOR m_comando
            RUN m_comando
            PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

        COMMAND 'Fim'       'Retorna ao menu anterior.'
            HELP 008
            EXIT MENU
    END MENU

    CLOSE WINDOW w_cre0126
END FUNCTION

#-----------------------#
 FUNCTION cre0126_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------------#
FUNCTION cre0126_inicia_variaveis()
#---------------------------------#
    LET m_consulta_ativa           = FALSE

    INITIALIZE mr_tirolez_clientes.*  TO NULL
    INITIALIZE mr_tirolez_clientesr.* TO NULL
    INITIALIZE m_nom_cliente          TO NULL

END FUNCTION

#-----------------------------------------#
FUNCTION cre0126_inclusao_tirolez_clientes()
#-----------------------------------------#
    LET mr_tirolez_clientesr.*         = mr_tirolez_clientes.*

    INITIALIZE mr_tirolez_clientes.* TO NULL

    CLEAR FORM

    IF  cre0126_entrada_dados('INCLUSAO') THEN
        WHENEVER ERROR CONTINUE        
        INSERT INTO tirolez_clientes 	(cod_cliente,
																	     cod_ean,
																	     cod_setor,
																	     cod_zona,
																	     cod_roteiro,
																	     cod_empresa,
																	     desc_finan,
																	     cod_seguimento,
																	     cod_tip_perueiro,
																	     ies_tip_desc,
																	     cod_ean1,
																	     aceita_um_terco,
																	     preco_flag,
																	     par_txt)
        VALUES (mr_tirolez_clientes.cod_cliente,
	              mr_tirolez_clientes.cod_ean,
	              mr_tirolez_clientes.cod_setor,
	              mr_tirolez_clientes.cod_zona,
	              mr_tirolez_clientes.cod_roteiro,
	              mr_tirolez_clientes.cod_empresa,
	              mr_tirolez_clientes.desc_finan,
	              mr_tirolez_clientes.cod_seguimento,
	              mr_tirolez_clientes.cod_tip_perueiro,
	              mr_tirolez_clientes.ies_tip_desc,
	              mr_tirolez_clientes.cod_ean1,
	              mr_tirolez_clientes.aceita_um_terco,
	              mr_tirolez_clientes.preco_flag,
	              mr_tirolez_clientes.par_txt)
        WHENEVER ERROR STOP

        IF  sqlca.SQLCODE = 0 THEN
            MESSAGE ' Inclus�o efetuada com sucesso. ' ATTRIBUTE(REVERSE)
        ELSE
            CALL log003_err_sql('INCLUSAO','TIROLEZ_CLIENTES')
        END IF
    ELSE
        LET mr_tirolez_clientes.*     = mr_tirolez_clientesr.*
        CLEAR FORM
        ERROR ' Inclus�o Cancelada. '
    END IF
END FUNCTION


#----------------------------------------#
FUNCTION cre0126_entrada_dados(l_funcao)
#----------------------------------------#
    DEFINE l_funcao           CHAR(015),
           l_count            INTEGER

    IF  l_funcao = 'INCLUSAO' THEN
        CALL log006_exibe_teclas('01 02 03 07', p_versao)
    ELSE
        CALL log006_exibe_teclas('01 02 07', p_versao)
    END IF

    CURRENT WINDOW IS w_cre0126
    LET int_flag = FALSE

    INPUT BY NAME mr_tirolez_clientes.cod_cliente,
                  mr_tirolez_clientes.cod_ean,
                  mr_tirolez_clientes.cod_setor,
                  mr_tirolez_clientes.cod_zona,
                  mr_tirolez_clientes.cod_roteiro,
                  mr_tirolez_clientes.cod_empresa,
                  mr_tirolez_clientes.desc_finan,
                  mr_tirolez_clientes.ies_tip_desc,
                  mr_tirolez_clientes.cod_seguimento,
                  mr_tirolez_clientes.cod_tip_perueiro,
                  mr_tirolez_clientes.cod_ean1,
                  mr_tirolez_clientes.aceita_um_terco,
                  mr_tirolez_clientes.preco_flag,
                  p_tela.*
       WITHOUT DEFAULTS

          BEFORE FIELD cod_cliente
            IF l_funcao = 'MODIFICACAO' THEN
               NEXT FIELD cod_ean
            END IF
            IF g_ies_grafico THEN
               --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
            ELSE
               DISPLAY '( Zoom )' AT 3,68
            END IF

          AFTER FIELD cod_cliente
          IF mr_tirolez_clientes.cod_cliente IS NULL OR
             mr_tirolez_clientes.cod_cliente = ' ' THEN
             ERROR 'Informe o c�dido do cliente'
             NEXT FIELD cod_cliente
          ELSE
             IF cre0126_verifica_inclusao() THEN
                ERROR 'Registro j� cadastrado.'
                NEXT FIELD cod_cliente
             END IF
             IF NOT cre0126_verifica_cliente() THEN
                  ERROR "Cliente n�o cadastrado."
                  LET m_nom_cliente = NULL
                  DISPLAY m_nom_cliente TO nom_cliente
                  NEXT FIELD cod_cliente
              ELSE
               DISPLAY m_nom_cliente TO nom_cliente
              END IF
           END IF

           BEFORE FIELD cod_ean
             IF g_ies_grafico THEN
                --# CALL fgl_dialog_setkeylabel('Control-Z','NULL')
             ELSE
                DISPLAY '--------' AT 3,68
             END IF
          AFTER FIELD cod_empresa
          	 IF mr_tirolez_clientes.cod_empresa IS NOT NULL THEN 
          	 		IF NOT cre0126_verifica_empresa() THEN 
          	 			ERROR'Empresa n�o cadastrada!!!'
          	 			NEXT FIELD cod_empresa
          	 		END IF 
          	 END IF 

          AFTER FIELD desc_finan
             IF mr_tirolez_clientes.desc_finan IS NULL THEN
                LET mr_tirolez_clientes.desc_finan = 0
                DISPLAY mr_tirolez_clientes.desc_finan TO desc_finan
             END IF
             IF mr_tirolez_clientes.desc_finan < 0 THEN
                ERROR 'Valor informado inv�lido'
                NEXT FIELD desc_finan
             END IF
             IF mr_tirolez_clientes.desc_finan > 100 THEN
                ERROR 'Desconto financeiro maior que 100 %.'
                NEXT FIELD desc_finan
             END IF

 {     AFTER FIELD cod_ean1
        IF mr_tirolez_clientes.cod_ean1 IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_ean1
          END IF }
    AFTER FIELD cod_seguimento
    		IF mr_tirolez_clientes.cod_seguimento IS NOT NULL THEN
    			IF NOT cre0126_verifica_seguimento() THEN 
    				ERROR'Seguimento n�o cadastrado!!!'
    				NEXT FIELD cod_seguimento
    			END IF 
    		END IF 
    AFTER FIELD cod_tip_perueiro
    		IF mr_tirolez_clientes.cod_tip_perueiro IS NOT NULL THEN 
    			IF NOT cre0126_verifica_perueiro() THEN 
    				ERROR'Tipo de perueiro n�o cadastrado!!!'
    				NEXT FIELD cod_tip_perueiro
    			END IF 
    		END IF 

    AFTER FIELD aceita_um_terco
    
        {IF mr_tirolez_clientes.aceita_um_terco IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD aceita_um_terco
        END IF  
        
        SELECT UNIQUE aceita_um_terco 
         FROM tirolez_clientes
         WHERE aceita_um_terco = mr_tirolez_clientes.aceita_um_terco
              
      IF mr_tirolez_clientes.aceita_um_terco != 'S' AND 
         mr_tirolez_clientes.aceita_um_terco != 'N'THEN 
         ERROR "Campo invalido tipo deve ser S(Sim) ou N(N�o)!!!" 
         NEXT FIELD aceita_um_terco
      END IF}
      
      
    AFTER FIELD preco_flag
    	IF mr_tirolez_clientes.preco_flag IS NULL THEN 											#campo adicionado a pedido do cliente 23/07/09
	      ERROR "Campo com preenchimento obrigat�rio !!!"
	      NEXT FIELD preco_flag
      ELSE 
	      IF mr_tirolez_clientes.preco_flag != 'S' AND 
	         mr_tirolez_clientes.preco_flag != 'N'THEN 
	         ERROR "Campo invalido tipo deve ser S(Sim) ou N(N�o)!!!" 
	         NEXT FIELD preco_flag
	      END IF
	    END IF 
      
    AFTER FIELD cod_canal
       
       IF p_tela.cod_canal IS NOT NULL THEN
          CALL cre0126_le_canal()
          IF p_den_canal IS NULL THEN
             ERROR 'Canal n�o cadastrado no POL1237'
             NEXT FIELD cod_canal
          END IF
          DISPLAY p_den_canal TO den_canal
       END IF
       
    AFTER FIELD cod_atividade
       
       IF p_tela.cod_atividade IS NOT NULL THEN
          CALL cre0126_le_atividade()
          IF p_den_atividade IS NULL THEN
             ERROR 'Atividade n�o cadastrada no POL1238'
             NEXT FIELD cod_atividade
          END IF
          DISPLAY p_den_atividade TO den_atividade
       END IF

    AFTER FIELD cod_atendimento
       
       IF p_tela.cod_atendimento IS NOT NULL THEN
          CALL cre0126_le_atendimento()
          IF p_den_atendimento IS NULL THEN
             ERROR 'Atendimento inv�lido'
             NEXT FIELD cod_atendimento
          END IF
          DISPLAY p_den_atendimento TO den_atendimento
       END IF

    AFTER FIELD aceita_peso
       
       IF p_tela.aceita_peso MATCHES '[SN]' THEN
       ELSE
          ERROR 'Informe S/N para esse campo.'
          NEXT FIELD aceita_peso
       END IF

    AFTER FIELD ies_edi
       
       IF p_tela.ies_edi MATCHES '[SN]' THEN
       ELSE
          ERROR 'Informe S/N para esse campo.'
          NEXT FIELD ies_edi
       END IF

    AFTER FIELD ies_integra
       
       IF p_tela.ies_integra MATCHES '[SN]' THEN
       ELSE
          ERROR 'Informe S/N para esse campo.'
          NEXT FIELD ies_integra
       END IF

    ON KEY (control-w)
        CALL cre0126_help()

    ON KEY (control-z, f4)
        CALL cre0126_pop_ups()

    AFTER FIELD faixa_produto
    
       IF p_tela.faixa_produto IS NULL THEN
          ERROR 'Informe a faixa de produto.'
          NEXT FIELD faixa_produto
       END IF
    
       SELECT COUNT(*)
         INTO l_count
         FROM tirolez_coletor_item_validade
        WHERE tabela = p_tela.faixa_produto
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('SELECT','tirolez_coletor_item_validade')
          NEXT FIELD faixa_produto
       END IF
       
       IF l_count = 0 THEN
          ERROR 'Faixa de produto inv�lida.'
          NEXT FIELD faixa_produto
       END IF

    END INPUT

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cre0126

    IF  INT_FLAG THEN
        LET INT_FLAG = FALSE
        RETURN FALSE
    END IF

    IF p_tela.cod_canal IS NULL THEN
       LET p_tela.cod_canal = '  '
    END IF

    IF p_tela.cod_atividade IS NULL THEN
       LET p_tela.cod_atividade = '  '
    END IF

    IF p_tela.cod_atendimento IS NULL THEN
       LET p_tela.cod_atendimento = '  '
    END IF

    IF p_tela.pct_peso IS NULL THEN
       LET p_tela.pct_peso = '  '
    END IF

    IF p_tela.faixa_produto IS NULL THEN
       LET p_tela.faixa_produto = '  '
    END IF
    
    LET mr_tirolez_clientes.par_txt[1,1] = p_tela.aceita_peso
    LET mr_tirolez_clientes.par_txt[2,3] = p_tela.pct_peso
    LET mr_tirolez_clientes.par_txt[4,5] = p_tela.cod_canal
    LET mr_tirolez_clientes.par_txt[6,7] = p_tela.cod_atividade
    LET mr_tirolez_clientes.par_txt[8,9] = p_tela.faixa_produto
    LET mr_tirolez_clientes.par_txt[10,10] = p_tela.ies_edi
    LET mr_tirolez_clientes.par_txt[11,11] = p_tela.ies_integra
    LET mr_tirolez_clientes.par_txt[12,13] = p_tela.cod_atendimento

    RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION cre0126_le_canal()#
#--------------------------#

   SELECT den_canal
     INTO p_den_canal
     FROM tirolez_canal
    WHERE cod_canal = p_tela.cod_canal
   
   IF STATUS <> 0 THEN
      LET p_den_canal = NULL
   END IF

END FUNCTION
   
#------------------------------#
FUNCTION cre0126_le_atividade()#
#------------------------------#

   SELECT den_atividade
     INTO p_den_atividade
     FROM tirolez_atividade
    WHERE cod_atividade = p_tela.cod_atividade
   
   IF STATUS <> 0 THEN
      LET p_den_atividade = NULL
   END IF

END FUNCTION

#--------------------------------#
FUNCTION cre0126_le_atendimento()#
#--------------------------------#

   SELECT den_atendimento
     INTO p_den_atendimento
     FROM tirolez_cli_atendimento
    WHERE cod_atendimento = p_tela.cod_atendimento
       
   IF STATUS <> 0 THEN
      LET p_den_atendimento = NULL
   END IF

END FUNCTION
   
    
#---------------------------------#
FUNCTION cre0126_verifica_cliente()
#---------------------------------#
  WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO m_nom_cliente
      FROM clientes
     WHERE cod_cliente = mr_tirolez_clientes.cod_cliente
  WHENEVER ERROR STOP

    IF  sqlca.SQLCODE = 0 THEN
        RETURN TRUE
    ELSE
        INITIALIZE m_nom_cliente TO NULL
        RETURN FALSE
    END IF

END FUNCTION


#----------------------------------#
FUNCTION cre0126_verifica_inclusao()
#----------------------------------#
  WHENEVER ERROR CONTINUE
    SELECT cod_cliente,
			     cod_ean,
			     cod_setor,
			     cod_zona,
			     cod_roteiro,
			     cod_empresa,
			     desc_finan,
			     cod_seguimento,
			     cod_tip_perueiro,
			     ies_tip_desc,
			     cod_ean1,
			     aceita_um_terco,
			     preco_flag 
    FROM tirolez_clientes
     WHERE cod_cliente = mr_tirolez_clientes.cod_cliente
  WHENEVER ERROR STOP

    IF  sqlca.SQLCODE = 0 OR
        sqlca.SQLCODE = -284 THEN
        RETURN TRUE
    ELSE
        RETURN FALSE
    END IF

END FUNCTION
#----------------------------------#
FUNCTION cre0126_verifica_empresa()
#----------------------------------#
DEFINE l_den_empresa	LIKE empresa.den_empresa

	SELECT den_empresa
	INTO l_den_empresa
	FROM empresa
	WHERE cod_empresa = mr_tirolez_clientes.cod_empresa
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den_empresa TO den_empresa
		RETURN TRUE 	
	END IF 
	
END FUNCTION
#------------------------------------#
FUNCTION cre0126_verifica_seguimento()
#------------------------------------#
DEFINE l_den_seguimento LIKE tirolez_seguimento.den_seguimento

	SELECT den_seguimento 
	INTO l_den_seguimento
	FROM tirolez_seguimento
	WHERE cod_seguimento = mr_tirolez_clientes.cod_seguimento
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den_seguimento TO den_seguimento
		RETURN TRUE 	
	END IF 

END FUNCTION
#----------------------------------#
FUNCTION cre0126_verifica_perueiro()
#----------------------------------#
DEFINE l_nom_frete	CHAR(30)
	
	SELECT nom_frete
	INTO l_nom_frete
	FROM tirolez_tipo_frete
	WHERE COD_FRETE = mr_tirolez_clientes.cod_tip_perueiro
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_nom_frete TO nom_frete
		RETURN TRUE 	
	END IF 

END FUNCTION
#---------------------#
FUNCTION cre0126_help()
#---------------------#
    OPTIONS
        HELP FILE m_camh_help_cre0126

    CASE
        WHEN INFIELD(cod_cliente)      CALL SHOWHELP(101)
        WHEN INFIELD(cod_ean)          CALL SHOWHELP(102)
        WHEN INFIELD(cod_setor)        CALL SHOWHELP(103)
        WHEN INFIELD(cod_zona)         CALL SHOWHELP(104)
        WHEN INFIELD(cod_roteiro)      CALL SHOWHELP(105)
        WHEN INFIELD(cod_empresa)      CALL SHOWHELP(106)
        WHEN INFIELD(desc_finan)       CALL SHOWHELP(107)
        WHEN INFIELD(cod_seguimento)   CALL SHOWHELP(108)
        WHEN INFIELD(cod_tip_perueiro) CALL SHOWHELP(109)
        WHEN INFIELD(ies_tip_desc)     CALL SHOWHELP(110)
        WHEN INFIELD(cod_ean1)         CALL SHOWHELP(111)
        WHEN INFIELD(aceita_um_terco)  CALL SHOWHELP(112)
    END CASE
    CURRENT WINDOW IS w_cre0126
END FUNCTION

#-----------------------------------------#
FUNCTION cre0126_bloqueia_tirolez_clientes()
#-----------------------------------------#

    DECLARE cmr_tirolez_clientes CURSOR FOR
       SELECT  cod_cliente,
					     cod_ean,
					     cod_setor,
					     cod_zona,
					     cod_roteiro,
					     cod_empresa,
					     desc_finan,
					     cod_seguimento,
					     cod_tip_perueiro,
					     ies_tip_desc,
					     cod_ean1,
					     aceita_um_terco,
					     preco_flag
         FROM tirolez_clientes
        WHERE tirolez_clientes.cod_cliente = mr_tirolez_clientes.cod_cliente
    FOR UPDATE

    CALL log085_transacao("BEGIN")

    WHENEVER ERROR CONTINUE

    OPEN  cmr_tirolez_clientes

    WHENEVER ERROR STOP

    IF  SQLCA.SQLCODE = 0 THEN
    WHENEVER ERROR CONTINUE

    FETCH cmr_tirolez_clientes INTO mr_tirolez_clientes.*

        WHENEVER ERROR STOP

        CASE
            WHEN sqlca.SQLCODE = 0
                RETURN TRUE

            WHEN sqlca.SQLCODE = NOTFOUND
                CALL log0030_mensagem(' Registro n�o mais existe na tabela.\nExecute a consulta novamente. ',
                                      'exclamation')

            OTHERWISE
                CALL log003_err_sql('LEITURA','TIROLEZ_CLIENTES')
        END CASE

        WHENEVER ERROR CONTINUE

        CLOSE cmr_tirolez_clientes
        FREE  cmr_tirolez_clientes

        WHENEVER ERROR STOP
    ELSE
        CALL log003_err_sql('LEITURA','TIROLEZ_CLIENTES')
    END IF

    CALL log085_transacao("ROLLBACK")

    RETURN FALSE
END FUNCTION

#---------------------------------------------#
FUNCTION cre0126_modificacao_tirolez_clientes()
#---------------------------------------------#

    LET mr_tirolez_clientesr.* = mr_tirolez_clientes.*

    IF  cre0126_bloqueia_tirolez_clientes() THEN
        #CALL cre0126_exibe_dados()

        IF  cre0126_entrada_dados('MODIFICACAO') THEN
            WHENEVER ERROR CONTINUE
               UPDATE tirolez_clientes
                  SET cod_ean              = mr_tirolez_clientes.cod_ean,
                      cod_setor            = mr_tirolez_clientes.cod_setor,
                      cod_zona             = mr_tirolez_clientes.cod_zona,
                      cod_roteiro          = mr_tirolez_clientes.cod_roteiro,
                      cod_empresa          = mr_tirolez_clientes.cod_empresa,
                      desc_finan           = mr_tirolez_clientes.desc_finan,
                      cod_seguimento       = mr_tirolez_clientes.cod_seguimento,
                      cod_tip_perueiro     = mr_tirolez_clientes.cod_tip_perueiro,
                      ies_tip_desc         = mr_tirolez_clientes.ies_tip_desc,
                      cod_ean1             = mr_tirolez_clientes.cod_ean1,
                      aceita_um_terco      = mr_tirolez_clientes.aceita_um_terco,
                      preco_flag					 = mr_tirolez_clientes.preco_flag,
                      par_txt              = mr_tirolez_clientes.par_txt
                      
                      
               WHERE cod_cliente           = mr_tirolez_clientes.cod_cliente
            WHENEVER ERROR STOP
            IF  sqlca.SQLCODE = 0 THEN
                CLOSE cmr_tirolez_clientes
                INITIALIZE mr_tirolez_clientes.* TO NULL
                CALL log085_transacao("COMMIT")
                MESSAGE ' Modifica��o efetuada com sucesso. ' ATTRIBUTE(REVERSE)
            ELSE
                CALL log003_err_sql('MODIFICACAO','TIROLEZ_CLIENTES')
                CLOSE cmr_tirolez_clientes
                CALL log085_transacao("ROLLBACK")
                LET mr_tirolez_clientes.* = mr_tirolez_clientesr.*
                CALL cre0126_exibe_dados()
            END IF
        ELSE
            CLOSE cmr_tirolez_clientes
            CALL log085_transacao("ROLLBACK")
            LET mr_tirolez_clientes.* = mr_tirolez_clientesr.*
            CALL cre0126_exibe_dados()
            ERROR ' Modifica��o cancelada. '
        END IF
    END IF
END FUNCTION

#-----------------------------------------#
FUNCTION cre0126_exclusao_tirolez_clientes()
#-----------------------------------------#
    IF  cre0126_bloqueia_tirolez_clientes() THEN
        #CALL cre0126_exibe_dados()

        IF  log004_confirm(17,45)  THEN
            WHENEVER ERROR CONTINUE

            DELETE FROM tirolez_clientes
            WHERE CURRENT OF cmr_tirolez_clientes

            WHENEVER ERROR STOP

            IF  sqlca.SQLCODE = 0 THEN
                CLOSE cmr_tirolez_clientes

                CALL log085_transacao("COMMIT")

                MESSAGE ' Exclus�o efetuada com sucesso. '
                   ATTRIBUTE(REVERSE)

                INITIALIZE mr_tirolez_clientes.*  TO NULL
                INITIALIZE mr_tirolez_clientesr.* TO NULL
                INITIALIZE m_nom_cliente          TO NULL

                #CALL cre0126_exibe_dados()
            ELSE
                CALL log003_err_sql('EXCLUSAO','TIROLEZ_CLIENTES')

                CLOSE cmr_tirolez_clientes

                CALL log085_transacao("ROLLBACK")
            END IF
        ELSE
            CLOSE cmr_tirolez_clientes

            CALL log085_transacao("ROLLBACK")
            ERROR ' Exclus�o cancelada. '
        END IF
    END IF
END FUNCTION


#-----------------------------------------#
FUNCTION cre0126_consulta_tirolez_clientes()
#-----------------------------------------#

    LET where_clause       =  NULL

    CALL cre0126_inicia_variaveis()

    CALL log006_exibe_teclas('01 02 07 08', p_versao)
    CURRENT WINDOW IS w_cre0126

    CLEAR FORM
    CONSTRUCT BY NAME where_clause ON tirolez_clientes.cod_cliente,
                                      tirolez_clientes.cod_ean,
                                      tirolez_clientes.cod_setor,
                                      tirolez_clientes.cod_zona,
                                      tirolez_clientes.cod_roteiro,
                                      tirolez_clientes.cod_empresa,
                                      tirolez_clientes.desc_finan,
                                      tirolez_clientes.cod_seguimento,
                                      tirolez_clientes.cod_tip_perueiro,
                                      tirolez_clientes.ies_tip_desc,
                                      tirolez_clientes.cod_ean1,
                                      tirolez_clientes.aceita_um_terco,
                                      tirolez_clientes.preco_flag
        ON KEY (control-w)
            CALL cre0126_help()

    END CONSTRUCT
    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cre0126

    IF  int_flag THEN
        LET int_flag = FALSE
        ERROR ' Consulta cancelada. '
    ELSE
        CALL cre0126_prepara_consulta()
    END IF

    CALL cre0126_exibe_dados()

    CALL log006_exibe_teclas('01 09', p_versao)
    CURRENT WINDOW IS w_cre0126
END FUNCTION

#---------------------------------#
FUNCTION cre0126_prepara_consulta()
#---------------------------------#
    LET sql_stmt = 'SELECT tirolez_clientes.cod_cliente, ',
						        			 'tirolez_clientes.cod_ean, ',
						        			 'tirolez_clientes.cod_setor, ',
						        			 'tirolez_clientes.cod_zona, ',
						        			 'tirolez_clientes.cod_roteiro, ',
						        			 'tirolez_clientes.cod_empresa, ',
						        			 'tirolez_clientes.desc_finan, ',
						        			 'tirolez_clientes.cod_seguimento, ',
						        			 'tirolez_clientes.cod_tip_perueiro, ',
													 'tirolez_clientes.ies_tip_desc, ',
													 'tirolez_clientes.cod_ean1, ',
													 'tirolez_clientes.aceita_um_terco, ',
												 	 'tirolez_clientes.preco_flag, par_txt ', 
						                   ' FROM tirolez_clientes',
                   ' WHERE ', where_clause CLIPPED ,
                   ' ORDER BY cod_cliente '

    PREPARE var_tirolez_clientes FROM sql_stmt

    DECLARE cq_tirolez_clientes SCROLL CURSOR WITH HOLD FOR var_tirolez_clientes

    OPEN  cq_tirolez_clientes
    FETCH cq_tirolez_clientes INTO mr_tirolez_clientes.*

    IF  sqlca.SQLCODE = 0 THEN

        MESSAGE ' Consulta efetuada com sucesso. '
           ATTRIBUTE (REVERSE)

        LET m_consulta_ativa = TRUE
    ELSE
        LET m_consulta_ativa = FALSE
        CLEAR FORM
        CALL log0030_mensagem(' Argumentos de pesquisa n�o encontrados. ','info')
    END IF
END FUNCTION

#------------------------------------#
FUNCTION cre0126_paginacao(l_funcao)
#------------------------------------#
    DEFINE l_funcao            CHAR(010)

    LET mr_tirolez_clientesr.* = mr_tirolez_clientes.*

    WHILE TRUE
        IF  l_funcao = 'SEGUINTE' THEN
            FETCH NEXT     cq_tirolez_clientes INTO mr_tirolez_clientes.*
        ELSE
            FETCH PREVIOUS cq_tirolez_clientes INTO mr_tirolez_clientes.*
        END IF

        IF  sqlca.SQLCODE = 0 THEN
            WHENEVER ERROR CONTINUE
             SELECT cod_cliente
               FROM tirolez_clientes
              WHERE cod_cliente = mr_tirolez_clientes.cod_cliente
            WHENEVER ERROR STOP

            IF SQLCA.SQLCODE = 0 OR SQLCA.SQLCODE = -284 THEN
               CALL cre0126_exibe_dados()
               #LET mr_tirolez_clientesr.*  =  mr_tirolez_clientes.*
               EXIT WHILE
            END IF
        ELSE
            ERROR ' N�o existem mais itens nesta dire��o. '
            LET mr_tirolez_clientes.* = mr_tirolez_clientesr.*
            EXIT WHILE
        END IF
    END WHILE

    

END FUNCTION

#-------------------------#
 FUNCTION cre0126_pop_ups()
#-------------------------#
   DEFINE l_cod_empresa   		LIKE empresa.cod_empresa,
          l_cod_cliente   		LIKE clientes.cod_cliente,
          l_cod_seguimento 		LIKE tirolez_seguimento.cod_seguimento,
          l_cod_tip_perueiro	LIKE tirolez_clientes.cod_tip_perueiro,
          p_codigo            CHAR(15)
          

   INITIALIZE l_cod_empresa, l_cod_cliente TO NULL

   CASE
      WHEN INFIELD (cod_empresa)
         LET l_cod_empresa = cre307_popup_empresa()
         IF l_cod_empresa IS NOT NULL THEN
            CURRENT WINDOW IS w_cre0126
            LET mr_tirolez_clientes.cod_empresa = l_cod_empresa
            DISPLAY BY NAME mr_tirolez_clientes.cod_empresa
         END IF

      WHEN INFIELD (cod_cliente)
         LET l_cod_cliente = cre314_popup_clientes()
         CURRENT WINDOW IS w_cre0126
         IF l_cod_cliente IS NOT NULL AND
            l_cod_cliente <> ' ' THEN
            LET mr_tirolez_clientes.cod_cliente = l_cod_cliente
            DISPLAY mr_tirolez_clientes.cod_cliente TO cod_cliente
         END IF
		 WHEN INFIELD (cod_seguimento)
		 		 CALL log009_popup(8,10,"CODIGO SEGUIMENTO","TIROLEZ_SEGUIMENTO","cod_seguimento","den_seguimento","","N","") 
				 	RETURNING l_cod_seguimento
				 CALL log006_exibe_teclas("01 02 07", p_versao)
		 		 CURRENT WINDOW IS w_cre0126
         IF l_cod_seguimento IS NOT NULL AND
            l_cod_seguimento <> ' ' THEN
            LET mr_tirolez_clientes.cod_seguimento = l_cod_seguimento
            DISPLAY mr_tirolez_clientes.cod_seguimento TO cod_seguimento
         END IF
		 WHEN INFIELD (cod_tip_perueiro)
		 		 CALL log009_popup(8,10,"CODIGO PERUEIRO","TIROLEZ_TIPO_FRETE", "cod_frete","nom_frete","","N","") 
				 	RETURNING l_cod_tip_perueiro
				 CALL log006_exibe_teclas("01 02 07", p_versao)
		 		 CURRENT WINDOW IS w_cre0126
         IF l_cod_tip_perueiro IS NOT NULL AND
            l_cod_tip_perueiro <> ' ' THEN
            LET mr_tirolez_clientes.cod_tip_perueiro = l_cod_tip_perueiro
            DISPLAY mr_tirolez_clientes.cod_tip_perueiro TO cod_tip_perueiro
         END IF
		 WHEN INFIELD (cod_canal)
		 		 CALL log009_popup(8,10,"CANAL DE VENDA","tirolez_canal","cod_canal","den_canal","","N","") 
				 	RETURNING p_codigo
				 CALL log006_exibe_teclas("01 02 07", p_versao)
		 		 CURRENT WINDOW IS w_cre0126
         IF p_codigo IS NOT NULL AND
            p_codigo <> ' ' THEN
            LET p_tela.cod_canal = p_codigo
            DISPLAY p_codigo TO cod_canal
         END IF
		 WHEN INFIELD (cod_atividade)
		 		 CALL log009_popup(8,10,"ATIVIDADES","tirolez_atividade","cod_atividade","den_atividade","","N","") 
				 	RETURNING p_codigo
				 CALL log006_exibe_teclas("01 02 07", p_versao)
		 		 CURRENT WINDOW IS w_cre0126
         IF p_codigo IS NOT NULL AND
            p_codigo <> ' ' THEN
            LET p_tela.cod_atividade = p_codigo
            DISPLAY p_codigo TO cod_atividade
         END IF

		 WHEN INFIELD (cod_atendimento)
		 		 CALL log009_popup(8,10,"ATENDIMENTO","tirolez_cli_atendimento","cod_atendimento","den_atendimento","","N","") 
				 	RETURNING p_codigo
				 CALL log006_exibe_teclas("01 02 07", p_versao)
		 		 CURRENT WINDOW IS w_cre0126
         IF p_codigo IS NOT NULL AND
            p_codigo <> ' ' THEN
            LET p_tela.cod_atendimento = p_codigo
            DISPLAY p_codigo TO cod_atendimento
         END IF


   END CASE

   CALL log006_exibe_teclas ("01 02 03 07", p_versao)
   CURRENT WINDOW IS w_cre0126
END FUNCTION

#----------------------------#
FUNCTION cre0126_exibe_dados()
#----------------------------#
   WHENEVER ERROR CONTINUE
   
   LET m_cod_cliente = mr_tirolez_clientes.cod_cliente
   
    SELECT * INTO mr_tirolez_clientes.*
      FROM tirolez_clientes
     WHERE cod_cliente = m_cod_cliente
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('SELECT','tirolez_clientes')
     END IF
   
     SELECT nom_cliente
       INTO m_nom_cliente
       FROM clientes
      WHERE cod_cliente = mr_tirolez_clientes.cod_cliente
   WHENEVER ERROR STOP

    DISPLAY BY NAME mr_tirolez_clientes.cod_cliente,
                    mr_tirolez_clientes.cod_ean,
                    mr_tirolez_clientes.cod_setor,
                    mr_tirolez_clientes.cod_zona,
                    mr_tirolez_clientes.cod_roteiro,
                    mr_tirolez_clientes.cod_empresa,
                    mr_tirolez_clientes.desc_finan,
                    mr_tirolez_clientes.cod_seguimento,
                    mr_tirolez_clientes.cod_tip_perueiro,
                    mr_tirolez_clientes.ies_tip_desc,
                    mr_tirolez_clientes.cod_ean1,
                    mr_tirolez_clientes.aceita_um_terco,
                    mr_tirolez_clientes.preco_flag

  DISPLAY m_nom_cliente TO nom_cliente

    LET p_tela.aceita_peso = mr_tirolez_clientes.par_txt[1,1]
    LET p_tela.pct_peso = mr_tirolez_clientes.par_txt[2,3]
    LET p_tela.cod_canal = mr_tirolez_clientes.par_txt[4,5]
    LET p_tela.cod_atividade = mr_tirolez_clientes.par_txt[6,7]
    LET p_tela.faixa_produto = mr_tirolez_clientes.par_txt[8,9]
    LET p_tela.ies_edi = mr_tirolez_clientes.par_txt[10,10]
    LET p_tela.ies_integra = mr_tirolez_clientes.par_txt[11,11]
    LET p_tela.cod_atendimento = mr_tirolez_clientes.par_txt[12,13]

    CALL cre0126_le_canal()
    CALL cre0126_le_atividade()
    CALL cre0126_le_atendimento()
    DISPLAY BY NAME p_tela.*
    DISPLAY p_den_canal to den_canal
    DISPLAY p_den_atividade to den_atividade
    DISPLAY p_den_atendimento to den_atendimento
    CALL cre0126_verifica_empresa() RETURNING p_status
    CALL cre0126_verifica_seguimento() RETURNING p_status
    CALL cre0126_verifica_perueiro() RETURNING p_status

END FUNCTION

#--------------------------------------#
FUNCTION cre0126_lista_tirolez_clientes()
#--------------------------------------#

    DEFINE lr_relat               RECORD LIKE tirolez_clientes.*
    DEFINE l_mensagem             CHAR(100)

    MESSAGE ' Processando a extra��o do relat�rio ... ' ATTRIBUTE(REVERSE)

    WHENEVER ERROR CONTINUE
    SELECT den_empresa INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP
    IF  p_ies_impressao = 'S' THEN
        IF  g_ies_ambiente = 'U' THEN
            START REPORT cre0126_relat TO PIPE p_nom_arquivo
        ELSE
            CALL log150_procura_caminho('LST') RETURNING m_caminho
            LET m_caminho = m_caminho CLIPPED, 'cre0126.tmp'
            START REPORT cre0126_relat TO m_caminho
     END IF
    ELSE
        START REPORT cre0126_relat TO p_nom_arquivo
    END IF

    DECLARE cl_tirolez_clientes CURSOR FOR
    SELECT  *
      INTO mr_tirolez_clientes.*
      FROM tirolez_clientes

    OPEN  cl_tirolez_clientes
    FETCH cl_tirolez_clientes INTO lr_relat.*
    IF  sqlca.SQLCODE = 0 THEN
        WHILE sqlca.SQLCODE = 0
            INITIALIZE m_nom_cliente TO NULL
            OUTPUT TO REPORT cre0126_relat(lr_relat.*)
            FETCH cl_tirolez_clientes INTO lr_relat.*
        END WHILE
    ELSE
        INITIALIZE lr_relat.* TO NULL
        OUTPUT TO REPORT cre0126_relat(lr_relat.*)
        CALL log0030_mensagem(' N�o existem dados para serem listados. ' ,'info')
    END IF
    CLOSE cl_tirolez_clientes

    FINISH REPORT cre0126_relat
    IF  g_ies_ambiente = 'W'   AND  p_ies_impressao = 'S'  THEN
        LET m_comando = 'lpdos.bat ',
                   m_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
        RUN m_comando
    END IF

    IF  p_ies_impressao = 'S' THEN
        CALL log0030_mensagem('Relat�rio gravado com sucesso','info')
    ELSE
        LET  l_mensagem = 'Relat�rio gravado no arquivo ',p_nom_arquivo CLIPPED
        CALL log0030_mensagem(l_mensagem,'info')
    END IF
END FUNCTION

#--------------------------------------#
REPORT cre0126_relat(lr_tirolez_clientes)
#--------------------------------------#
    DEFINE lr_tirolez_clientes RECORD LIKE tirolez_clientes.*

 OUTPUT   LEFT MARGIN 0
           TOP MARGIN 0
        BOTTOM MARGIN 1
          PAGE LENGTH 64
{
                                                TIP TIPO  
CODIGO AEN     SET ZONA ROT EMP %DESCONTO  DESC SEG PERU CODIGO EAN1
-------------- --- ---- --- --- ---------- ---- --- ---- --------------
XXXXXXXXXXXXXX XX   XX  XXX XX  9999,999    X    X   X   XXXXXXXXXXXXXX
CLIENTE: XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

}

FORMAT
   PAGE HEADER
        PRINT log5211_retorna_configuracao(PAGENO,64,85) CLIPPED;
        PRINT COLUMN 001, m_den_empresa
        PRINT COLUMN 001, 'CRE0126',
              COLUMN 023, 'COMPLEMENTO CLIENTE (TIROLEZ_CLIENTES)',
              COLUMN 074, 'FL. ', PAGENO USING '####'
        PRINT COLUMN 043, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy',
              COLUMN 067, 'AS ', TIME,
              COLUMN 079, 'HRS.'
        SKIP 1 LINE
         PRINT COLUMN 001, '                                                TIP TIPO                ACEITA PRECO'
         PRINT COLUMN 001, 'CODIGO EAN     SET ZONA ROT EMP %DESCONTO  DESC SEG PERU CODIGO EAN1    TERCO  FLAG'
         PRINT COLUMN 001, '-------------- --- ---- --- --- ---------- ---- --- ---- -------------- ----- ------'

         ON EVERY ROW
             PRINT COLUMN 001, lr_tirolez_clientes.cod_ean,
                   COLUMN 016, lr_tirolez_clientes.cod_setor,
                   COLUMN 020, lr_tirolez_clientes.cod_zona,
                   COLUMN 025, lr_tirolez_clientes.cod_roteiro,
                   COLUMN 030, lr_tirolez_clientes.cod_empresa,
                   COLUMN 033, lr_tirolez_clientes.desc_finan USING '###.&&&',
                   COLUMN 045, lr_tirolez_clientes.ies_tip_desc,
                   COLUMN 050, lr_tirolez_clientes.cod_seguimento,
                   COLUMN 054, lr_tirolez_clientes.cod_tip_perueiro,
                   COLUMN 058, lr_tirolez_clientes.cod_ean1,
                   COLUMN 075, lr_tirolez_clientes.aceita_um_terco,
                   COLUMN 081, lr_tirolez_clientes.preco_flag 
 
             WHENEVER ERROR CONTINUE
             SELECT nom_cliente
               INTO m_nom_cliente
               FROM clientes
             WHERE cod_cliente = lr_tirolez_clientes.cod_cliente
             WHENEVER ERROR STOP

             PRINT COLUMN 001, 'CLIENTE: ',
                   COLUMN 009, lr_tirolez_clientes.cod_cliente,
                   COLUMN 024, ' - ',
                   COLUMN 027, m_nom_cliente
             SKIP 1 LINE

        ON LAST ROW
            LET m_last_row = TRUE
        PAGE TRAILER
            IF  m_last_row = TRUE
               THEN PRINT '* * * ULTIMA FOLHA * * *'
            ELSE PRINT ' '
            END IF
END REPORT
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1074                                                 #
# OBJETIVO: CONSULTA POR FUNCIONÁRIO                                #
# AUTOR...: IVO                                                     #
# DATA....: 02/11/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          p_last_row           SMALLINT

   DEFINE p_cod_banco          LIKE contr_consig_265.cod_banco,
          p_num_contrato       LIKE contr_consig_265.num_contrato,
          p_qtd_parcela        LIKE contr_consig_265.qtd_parcela,
          p_num_parcela        LIKE contr_consig_265.num_parcela,
          p_den_reduz          LIKE banco_265.den_reduz, 
          p_observacao         LIKE diverg_consig_265.observacao,
          p_cod_tipo           LIKE tip_acerto_265.cod_tipo,
          p_den_tipo           LIKE tip_acerto_265.den_tipo,
          p_dat_liquidacao     DATE,
          p_num_cpf            CHAR(19),
          p_num_cpfa           CHAR(19),        
          p_dat_referencia     DATETIME YEAR TO MONTH,
          p_dat_char           CHAR(10),
          p_data               DATE

   DEFINE p_consulta           RECORD
          cod_empresa          LIKE contr_consig_265.cod_empresa,    
          uf                   LIKE contr_consig_265.uf,             
          num_contrato         LIKE contr_consig_265.num_contrato,
          num_cpf              LIKE contr_consig_265.num_cpf,        
          nom_funcionario      LIKE contr_consig_265.nom_funcionario,
          num_matricula        LIKE contr_consig_265.num_matricula 
   END RECORD
   
   DEFINE p_tela               RECORD
          cod_empresa          LIKE contr_consig_265.cod_empresa,     
          uf                   LIKE contr_consig_265.uf,   
          num_contrato         LIKE contr_consig_265.num_contrato,
          num_cpf              LIKE contr_consig_265.num_cpf,         
          nom_funcionario      LIKE contr_consig_265.nom_funcionario, 
          num_matricula        LIKE contr_consig_265.num_matricula,   
          dat_rescisao         LIKE contr_consig_265.dat_rescisao,     
          valor_30             LIKE contr_consig_265.valor_30,        
          dat_afastamento      LIKE contr_consig_265.dat_afastamento,
          cod_banco            LIKE contr_consig_265.cod_banco
   END RECORD
   
   DEFINE pr_contrato          ARRAY[2000] OF RECORD
          edita                CHAR(01),
          cod_banco            LIKE contr_consig_265.cod_banco,
          dat_contrato         LIKE contr_consig_265.dat_contrato,
          num_cont             LIKE contr_consig_265.num_contrato,
          val_parcela          LIKE contr_consig_265.val_parcela, 
          dat_vencto           LIKE contr_consig_265.dat_vencto, 
          num_parcela          LIKE contr_consig_265.num_parcela,    
          qtd_parcela          LIKE contr_consig_265.qtd_parcela,    
          observacao           CHAR(3),
          dat_liquidacao       LIKE contr_consig_265.dat_liquidacao
   END RECORD

   DEFINE pr_diverg            ARRAY[100] OF RECORD
          edita                CHAR(01),
          mes_ano              CHAR(07),            
          tip_acerto           CHAR(30),               
          val_acerto           DECIMAL(10,2),         
          dat_acerto           DATE
   END RECORD

   DEFINE pr_obs            ARRAY[100] OF RECORD
          observacao        LIKE diverg_consig_265.observacao
   END RECORD
   
   
   DEFINE p_contrato           RECORD
          uf                   CHAR(02),             
          cod_empresa          CHAR(02),    
          num_matricula        CHAR(15),
          dat_rescisao         DATE,
          valor_30             DECIMAL(12,2),
          dat_afastamento      DATE,
          num_contrato         CHAR(15),   
          mes_ano              CHAR(07),
          parcela              CHAR(06),        
          val_parcela          DECIMAL(12,2),    
          dat_liquidacao       DATE,
          cod_banco            DECIMAL(3,0)
   END RECORD
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1074-10.02.05"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1074_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1074_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1074") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1074 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados dos contratos"
         CALL pol1074_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            NEXT OPTION "Seguinte"
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modificar dados das divergências"
         IF p_ies_cons THEN
            CALL pol1074_modificar() RETURNING p_status
         ELSE
            ERROR 'Consulte previamente !!!'
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1074_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1074_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1074_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1074

END FUNCTION

#-----------------------#
FUNCTION pol1074_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------#
FUNCTION pol1074_valida_cpf(cpf)
#------------------------------#

    DEFINE cpf          char(14),
           p_cpf        char(14),
           digCalculado char(02),
           digEnviado   char(02),
           d1           integer,
           d2           integer,
           resto        integer,
           carac        char(01),
           dig          integer

    let p_cpf = null
    
    for p_ind = 1 to length(cpf)
        let carac = cpf[p_ind]
        if carac MATCHES "[0123456789]" then
           let p_cpf = p_cpf CLIPPED, carac
        end if
    end for
    
    if length(p_cpf) <> 11 then
       return false
    end if
    
		let d1 = 0
		let d2 = 0

		for p_ind = 1 to 9
			let dig = p_cpf[p_ind]
			let d1 = d1 + (11 - p_ind) * dig
			let d2 = d2 + (12 - p_ind) * dig
		end for
		
		let resto = (d1 MOD 11)
		
		if (resto < 2) then
			 let d1 = 0
		else
			let d1 = 11 - resto
    end if
    
		let d2 = d2 + 2 * d1
		
		let resto = (d2 MOD 11)

		if (resto < 2) then
			 let d2 = 0
		else
			let d2 = 11 - resto
    end if

		let digEnviado = p_cpf[10,11]
		let digCalculado = d1 using "&", d2 using "&"

		return (digEnviado = digCalculado)

end FUNCTION


#---------------------------#
FUNCTION pol1074_consultar()
#---------------------------#

   DEFINE sql_stmt CHAR(800)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_num_cpfa = p_num_cpf
   LET INT_FLAG = FALSE
   INITIALIZE p_consulta to null
   
   INPUT BY NAME p_consulta.*
      WITHOUT DEFAULTS

   AFTER FIELD num_cpf
      
      if p_consulta.num_cpf is not null then
         if not pol1074_valida_cpf(p_consulta.num_cpf) then
            let p_msg = 'CPF inválido!\n'
            call log0030_mensagem(p_msg,'excla')
            next field num_cpf
         end if            
         select count(num_cpf)
           into p_count
           from contr_consig_265
          where num_cpf = p_consulta.num_cpf
         if p_count =0 then
            let p_msg = 'Não há contrato cadastrado,\n',
                         'para o CPF informado!'
            call log0030_mensagem(p_msg,'excla')
            next field num_cpf
         end if
      end if
      
   END INPUT
           
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_num_cpf = p_num_cpfa
         CALL pol1074_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt =
      "SELECT DISTINCT num_cpf ",
      " FROM contr_consig_265 ",
      " WHERE cod_empresa LIKE '","%",p_consulta.cod_empresa CLIPPED,"%","' ",
      "   AND num_contrato LIKE '","%",p_consulta.num_contrato CLIPPED,"%","' ",
      "   AND uf LIKE '","%",p_consulta.uf CLIPPED,"%","' ",
      "   AND num_cpf LIKE '","%",p_consulta.num_cpf CLIPPED,"%","' ",
      "   AND nom_funcionario LIKE '","%",p_consulta.nom_funcionario CLIPPED,"%","' ",
      " ORDER BY num_cpf"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_cpf

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1074_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1074_exibe_dados()
#------------------------------#

   INITIALIZE p_tela TO NULL
   
   DECLARE cq_primeiro CURSOR FOR
   SELECT cod_empresa,    
          uf,    
          num_contrato,
          num_cpf,         
          nom_funcionario,
          num_matricula,
          dat_rescisao,
          valor_30,
          dat_afastamento
     FROM contr_consig_265
    WHERE num_cpf = p_num_cpf    

   FOREACH cq_primeiro
     INTO p_tela.cod_empresa,
          p_tela.uf,
          p_tela.num_contrato,
          p_tela.num_cpf,
          p_tela.nom_funcionario,
          p_tela.num_matricula,
          p_tela.dat_rescisao,
          p_tela.valor_30,
          p_tela.dat_afastamento
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','contr_consig_265:cq_primeiro')   
         RETURN FALSE
      END IF
      EXIT FOREACH
   
   END FOREACH
   
   DISPLAY p_tela.cod_empresa     TO cod_empresa
   DISPLAY p_tela.uf              TO uf              
   DISPLAY p_tela.num_contrato    TO num_contrato              
   DISPLAY p_tela.num_cpf         TO num_cpf         
   DISPLAY p_tela.nom_funcionario TO nom_funcionario  
   DISPLAY p_tela.num_matricula   TO num_matricula   
   DISPLAY p_tela.dat_rescisao    TO dat_rescisao                  
   DISPLAY p_tela.dat_afastamento TO dat_afastamento               
   DISPLAY p_tela.valor_30        TO valor_30                      

   LET p_index = 1
   INITIALIZE pr_contrato TO NULL
   
   DECLARE cq_cont CURSOR FOR
    SELECT cod_banco,
           dat_contrato,  
           num_contrato,  
           val_parcela,   
           dat_vencto,    
           num_parcela,   
           qtd_parcela,   
           dat_liquidacao
      FROM contr_consig_265
     WHERE num_cpf = p_num_cpf     

   FOREACH cq_cont INTO 
           pr_contrato[p_index].cod_banco,
           pr_contrato[p_index].dat_contrato,      
           pr_contrato[p_index].num_cont,      
           pr_contrato[p_index].val_parcela,       
           pr_contrato[p_index].dat_vencto,        
           pr_contrato[p_index].num_parcela,       
           pr_contrato[p_index].qtd_parcela,       
           pr_contrato[p_index].dat_liquidacao     
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','contr_consig_265:2')   
         RETURN FALSE
      END IF

      LET p_cod_banco = pr_contrato[p_index].cod_banco
      LET p_dat_referencia = pr_contrato[p_index].dat_vencto 
    
      SELECT COUNT(id_registro)
        INTO p_count
        FROM diverg_consig_265
       WHERE cod_empresa    = p_tela.cod_empresa
         AND num_cpf        = p_num_cpf
         AND num_matricula  = p_tela.num_matricula
         AND cod_banco      = p_cod_banco
         AND dat_referencia = p_dat_referencia
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','diverg_consig_265:1')   
         RETURN FALSE
      END IF
      
      IF p_count > 0 THEN
         LET pr_contrato[p_index].observacao = 'Sim'
      ELSE
         LET pr_contrato[p_index].observacao = 'Não'
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 2000 THEN
         LET p_msg = 'Limete de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_contrato 
      WITHOUT DEFAULTS FROM sr_contrato.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1074_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_cpfa = p_num_cpf

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_cpf                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_cpf         
      END CASE

      IF STATUS = 0 THEN
         CALL pol1074_exibe_dados() RETURNING p_status
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_num_cpf = p_num_cpfa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
      END IF    

      EXIT WHILE
      
   END WHILE

END FUNCTION

#---------------------------#
FUNCTION pol1074_modificar()
#---------------------------#

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_contrato WITHOUT DEFAULTS FROM sr_contrato.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

         CALL pol1074_exibe_afast()
   
      AFTER FIELD edita

         IF pr_contrato[p_index].edita IS NOT NULL THEN
            LET pr_contrato[p_index].edita = NULL
            NEXT FIELD edita
         ELSE
            IF FGL_LASTKEY() = 2016 THEN
               EXIT INPUT
            END IF
         END IF      

         IF FGL_LASTKEY() = 2000 THEN    
         ELSE
            IF pr_contrato[p_index].num_cont IS NULL THEN   
               NEXT FIELD edita
            END IF
         END IF

      ON KEY (control-d)
         IF pr_contrato[p_index].num_cont IS NOT NULL THEN
            CALL pol1074_exibe_diverg()
         END IF
         
      ON KEY (control-e)
         IF pr_contrato[p_index].num_cont IS NOT NULL THEN
            CALL pol1074_edita_contrato()
            CALL pol1074_exibe_afast()
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1074_exibe_afast()
#-----------------------------#

   INITIALIZE p_tela TO NULL                             

   IF pr_contrato[p_index].num_cont IS NOT NULL THEN  

      SELECT cod_empresa,    
             uf,    
             num_cpf,         
             nom_funcionario,
             num_matricula,
             dat_rescisao,                                       
             dat_afastamento,                                      
             valor_30,
             dat_liquidacao           
        INTO p_tela.cod_empresa,       
             p_tela.uf,                
             p_tela.num_cpf,           
             p_tela.nom_funcionario,   
             p_tela.num_matricula,
             p_tela.dat_rescisao,                                  
             p_tela.dat_afastamento,                               
             p_tela.valor_30,
             pr_contrato[p_index].dat_liquidacao           
        FROM contr_consig_265
       WHERE cod_banco    = pr_contrato[p_index].cod_banco
         AND num_contrato = pr_contrato[p_index].num_cont
         AND num_cpf      = p_num_cpf

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','contr_consig_265:2')   
         RETURN FALSE
      END IF
   
   END IF                                               

   DISPLAY pr_contrato[p_index].dat_liquidacao TO 
           sr_contrato[s_index].dat_liquidacao 
   
   DISPLAY p_tela.cod_empresa     TO cod_empresa
   DISPLAY p_tela.uf              TO uf              
   DISPLAY p_tela.num_cpf         TO num_cpf         
   DISPLAY p_tela.nom_funcionario TO nom_funcionario  
   DISPLAY p_tela.num_matricula   TO num_matricula   
   DISPLAY p_tela.dat_rescisao    TO dat_rescisao                  
   DISPLAY p_tela.dat_afastamento TO dat_afastamento               
   DISPLAY p_tela.valor_30        TO valor_30                      
                                                                   
END FUNCTION

#----------------------------------#
 FUNCTION pol1074_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT uf,                               
           cod_empresa,                         
           num_matricula,                       
           dat_rescisao,                        
           valor_30,                            
           dat_afastamento,                     
           num_contrato,                        
           val_parcela,                         
           dat_liquidacao,                      
           qtd_parcela,                         
           num_parcela,                         
           dat_vencto,
           cod_banco
      INTO p_contrato.uf,                       
           p_contrato.cod_empresa,              
           p_contrato.num_matricula,            
           p_contrato.dat_rescisao,             
           p_contrato.valor_30,                 
           p_contrato.dat_afastamento,          
           p_contrato.num_contrato,             
           p_contrato.val_parcela,              
           p_contrato.dat_liquidacao,           
           p_qtd_parcela,                       
           p_num_parcela,                       
           p_dat_char,
           p_contrato.cod_banco
      FROM contr_consig_265                     
     WHERE cod_banco    = p_cod_banco           
       AND num_contrato = p_num_contrato        
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","contr_consig_265:3")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1074_edita_contrato()
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10741") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10741 AT 10,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_cod_banco    = pr_contrato[p_index].cod_banco
   LET p_num_contrato = pr_contrato[p_index].num_cont


   IF pol1074_prende_registro() THEN
      
      LET p_dat_liquidacao = p_contrato.dat_liquidacao
      
      IF pol1074_aceita_dados() THEN
         
         UPDATE contr_consig_265
            SET dat_liquidacao  = p_contrato.dat_liquidacao,
                cod_empresa     = p_contrato.cod_empresa
                #dat_rescisao    = p_contrato.dat_rescisao,     
                #valor_30        = p_contrato.valor_30,              
                #dat_afastamento = p_contrato.dat_afastamento
          WHERE cod_banco    = p_cod_banco           
            AND num_contrato = p_num_contrato        
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "contr_consig_265")
            CALL log085_transacao("ROLLBACK")
         ELSE
            IF pol1074_ins_audit() THEN
               CALL log085_transacao("COMMIT")
            ELSE
               CALL log085_transacao("ROLLBACK")
            END IF
         END IF
      
      END IF

      CLOSE cq_prende

   END IF

   CLOSE WINDOW w_pol10741
   
END FUNCTION

#--------------------------#
FUNCTION pol1074_ins_audit()
#--------------------------#

   DEFINE p_dat_operacao DATETIME YEAR TO SECOND
   
   IF p_dat_liquidacao = p_contrato.dat_liquidacao THEN
      RETURN TRUE
   END IF
   
   IF p_contrato.dat_liquidacao IS NULL or
      p_contrato.dat_liquidacao = ''    THEN
      LET p_msg = 'Re-abriu'
   ELSE
      LET p_msg = 'Liquidou'
   END IF
   
   LET p_dat_operacao = CURRENT
   
   INSERT INTO contr_audit_265
    VALUES(p_cod_empresa,
           p_user,
           p_num_contrato,
           p_msg,
           p_dat_operacao,
           p_contrato.cod_banco)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','contr_audit_265')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1074_aceita_dados()
#------------------------------#

   LET INT_FLAG = FALSE

   LET p_contrato.parcela = p_num_parcela USING '&&','/',p_qtd_parcela USING '&&'
   LET p_contrato.mes_ano = p_dat_char[4,5],'/',p_dat_char[7,10]
   
   INPUT BY NAME p_contrato.* WITHOUT DEFAULTS

      AFTER FIELD cod_empresa
      
         IF p_contrato.cod_empresa IS NULL THEN
            ERROR 'Campo com preenchimento obrigat´rorio!'
            NEXT FIELD cod_empresa
         END IF
         
         SELECT den_empresa
           INTO p_den_empresa
           FROM empresa
          WHERE cod_empresa = p_contrato.cod_empresa
         
         IF STATUS <> 0 THEN
            ERROR 'Empresa inválida!'
            NEXT FIELD cod_empresa
         END IF
         
         DISPLAY p_den_empresa TO den_empresa
      
      ON KEY (control-z)
         CALL pol1074_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1074_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_empresa)
         
         CALL log009_popup(8,25,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1098
         
         IF p_codigo IS NOT NULL THEN
            LET p_contrato.cod_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_empresa
         END IF

   END CASE 

END FUNCTION 

#------------------------------#
FUNCTION pol1074_exibe_diverg()
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10742") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10742 AT 8,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_cod_banco    = pr_contrato[p_index].cod_banco
   LET p_num_contrato = pr_contrato[p_index].num_cont
   
   SELECT den_reduz
     INTO p_den_reduz
     FROM banco_265
    WHERE cod_banco = p_cod_banco

   IF STATUS <> 0 THEN
      LET p_den_reduz = NULL
   END IF
   
   DISPLAY p_cod_banco    TO cod_banco
   DISPLAY p_den_reduz    TO den_reduz
   DISPLAY p_num_contrato TO num_contrato

   LET p_dat_referencia = pr_contrato[p_index].dat_vencto
   LET p_ind = 1
   INITIALIZE pr_diverg, pr_obs TO NULL
   
   DECLARE cq_div CURSOR FOR
    SELECT dat_referencia,
           val_acerto,     
           tip_acerto,     
           dat_acerto_prev,
           observacao,
           num_cpf
      FROM diverg_consig_265
     WHERE cod_empresa    = p_tela.cod_empresa
       AND num_cpf        = p_tela.num_cpf
       AND num_matricula  = p_tela.num_matricula
       AND cod_banco      = p_cod_banco
       AND cod_status    <> 'E'
     ORDER BY num_cpf, dat_referencia

   FOREACH cq_div INTO
           p_dat_char,  
           pr_diverg[p_ind].val_acerto,   
           p_cod_tipo,   
           pr_diverg[p_ind].dat_acerto,
           pr_obs[p_ind].observacao
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','diverg_consig_265:cq_div')   
         RETURN FALSE
      END IF
      
      SELECT den_tipo
        INTO p_den_tipo
        FROM tip_acerto_265
       WHERE cod_tipo = p_cod_tipo
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tip_acerto_265')   
         RETURN FALSE
      END IF
      
      LET pr_diverg[p_ind].tip_acerto = p_cod_tipo, ' - ', p_den_tipo      
      LET pr_diverg[p_ind].mes_ano = p_dat_char[6,7], '/', p_dat_char[1,4]
      LET p_ind = p_ind + 1
      
      IF p_ind > 100 THEN
         LET p_msg = 'Limete de linhas da grade ultrapasou!'
         CALL log0030_mensagem(p_msg, 'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_diverg WITHOUT DEFAULTS FROM sr_diverg.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         DISPLAY pr_obs[p_ind].observacao TO observacao
   
      AFTER FIELD edita

         IF pr_diverg[p_ind].edita IS NOT NULL THEN
            LET pr_diverg[p_ind].edita = NULL
            NEXT FIELD edita
         ELSE
            IF FGL_LASTKEY() = 2016 THEN
               EXIT INPUT
            END IF
         END IF      

         IF FGL_LASTKEY() = 2000 THEN    
         ELSE
            IF pr_diverg[p_ind].mes_ano IS NULL THEN   
               NEXT FIELD edita
            END IF
         END IF
        
   END INPUT

END FUNCTION

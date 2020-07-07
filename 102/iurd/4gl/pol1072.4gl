#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1072                                                 #
# OBJETIVO: TRATAMENTO DAS DIVERGÊNCIAS                             #
# AUTOR...: IVO                                                     #
# DATA....: 01/12/10                                                #
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
          p_arbitrou           SMALLINT,
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

   DEFINE p_dat_char           CHAR(10),
          p_data               DATE,
          p_dat_referencia     DATE,
          p_dat_acerto         DATETIME YEAR TO MONTH,
          p_mes_refer          CHAR(07),
          p_ano_mes            CHAR(07),
          p_mes_acert          CHAR(07),
          p_mes_ano            CHAR(07),
          p_val_acerto         DECIMAL(12,2),
          p_cod_status         CHAR(01)
   
   DEFINE p_den_reduz          LIKE banco_265.den_reduz,          
          p_cod_banco          LIKE banco_265.cod_banco 
         
   DEFINE p_acerto             RECORD
          mes_acerto           CHAR(07),
          val_acerto           DECIMAL(12,2),
          tip_acerto           DECIMAL(2,0),
          den_tipo             CHAR(25),
          observacao           CHAR(450)
   END RECORD
   
   DEFINE p_tela               RECORD
          cod_banco            DECIMAL(3,0), 
          den_reduz            CHAR(15), 
          num_cpf              CHAR(15), 
          cod_acerto           DECIMAL(1,0),  
          nom_func             CHAR(50),
          mes_ref              CHAR(02),   
          ano_ref              CHAR(04)
   END RECORD 
          
   DEFINE pr_func              ARRAY[1000] OF RECORD    
          edita                CHAR(01),
          funcionario          CHAR(36),
          cpf                  CHAR(19),
          dat_acerto           CHAR(07),
          cod_tipo             DECIMAL(2,0),
          dat_conciliacao      DATE,
          nom_usuario          CHAR(08)
   END RECORD

   DEFINE pr_id                ARRAY[1000] OF RECORD    
          id_registro          INTEGER
   END RECORD
             
END GLOBALS
          
MAIN      
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
	 LET p_versao = "pol1072-10.02.11"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1072_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1072_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1072") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1072 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta de divergências"
         CALL pol1072_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            LET p_ies_cons = TRUE
            NEXT OPTION "Modificar"
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modificar dados das divergências"
         IF p_ies_cons THEN
            LET p_arbitrou = FALSE
            CALL pol1072_modificar() RETURNING p_status
            IF p_arbitrou THEN
               ERROR 'Operação efetuada com sucesso !!!'
               LET p_ies_cons = TRUE
            ELSE
               LET p_ies_cons = FALSE
               ERROR 'Operação cancelada !!!'
            END IF 
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION "Consultar"
         END IF
      {COMMAND "Listar" "Listar as divergências"
         CALL pol1072_listar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF }
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1072_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1072

END FUNCTION

#-----------------------#
FUNCTION pol1072_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1072_consultar()
#---------------------------#

   CALL pol1072_limpa_tela()
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_tela.cod_acerto = 5
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

   AFTER FIELD num_cpf
      
      if p_tela.num_cpf is not null then
         if not pol1072_valida_cpf(p_tela.num_cpf) then
            let p_msg = 'CPF inválido!\n'
            call log0030_mensagem(p_msg,'excla')
            next field num_cpf
         end if            
         select count(num_cpf)
           into p_count
           from diverg_consig_265
          where num_cpf = p_tela.num_cpf
         if p_count =0 then
            let p_msg = 'Não há divergência cadastrada,\n',
                         'para o CPF informado!'
            call log0030_mensagem(p_msg,'excla')
            next field num_cpf
         end if
      end if

   AFTER FIELD cod_banco
      
      IF p_tela.cod_banco IS NULL THEN
         ERROR 'Campo com preenchimento obrigatório!'
         NEXT FIELD cod_banco
      END IF
      
      SELECT den_reduz
        INTO p_tela.den_reduz
        FROM banco_265
       WHERE cod_banco = p_tela.cod_banco
      
      IF STATUS = 100 THEN
         ERROR 'Banco não cadastrado no sistema de consignação!'
         NEXT FIELD cod_banco
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','banco_265')
            NEXT FIELD cod_banco
         END IF
      END IF
      
      DISPLAY p_tela.den_reduz TO den_reduz

      SELECT MAX(dat_referencia)
        INTO p_dat_referencia
        FROM diverg_consig_265
       WHERE cod_banco = p_tela.cod_banco
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','diverg_consig_265')
         NEXT FIELD cod_banco
      END IF
      
      IF p_dat_referencia IS NULL THEN
         LET p_dat_char = '01/01/1967'
         LET p_data = p_dat_char  
         LET p_dat_referencia = p_data
      END IF
      
      LET p_ano_mes = YEAR(p_dat_referencia)  USING '&&&&', '/',
                        MONTH(P_Dat_Referencia) USING '&&'

      LET p_mes_ano = MONTH(p_dat_referencia) USING '&&', '/',
                      YEAR(p_dat_referencia)  USING '&&&&'
      
      AFTER FIELD cod_acerto
         IF p_tela.cod_acerto > 0 THEN
         		SELECT den_tipo
           		FROM tip_acerto_265
          		WHERE cod_tipo = p_tela.cod_acerto   

         		IF STATUS <> 0 THEN
            	ERROR 'Tipo inválido!'
            	NEXT FIELD cod_acerto
         		END IF
        END IF 		

      AFTER FIELD mes_ref
         
         IF p_tela.mes_ref IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD mes_ref
         ELSE
            IF p_tela.mes_ref <= 0 OR p_tela.mes_ref > 12 THEN
               ERROR 'Valor inválido para o campo!'
               NEXT FIELD mes_ref
            END IF
            LET p_tela.mes_ref = p_tela.mes_ref USING '&&'   
            DISPLAY p_tela.mes_ref TO mes_ref
         END IF
         
      AFTER FIELD ano_ref
        
         IF p_tela.ano_ref IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD ano_ref
         END IF

      ON KEY (control-z)
         CALL pol1072_popup()

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.mes_ref IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD mes_ref
            END IF
         
            IF p_tela.ano_ref IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD ano_ref
            END IF
         
            LET p_mes_refer = p_tela.ano_ref,'/',p_tela.mes_ref
         
         END IF

   END INPUT

   IF INT_FLAG  THEN
      CALL pol1072_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT pol1072_le_func() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1072_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1072_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,10,"BANCOS","banco_265",
              "cod_banco","den_reduz","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF

      WHEN INFIELD(tip_acerto)
         CALL log009_popup(8,12,"TIPOS DE ACERTO","tip_acerto_265",
              "cod_TIPO","den_TIPO","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_acerto.tip_acerto = p_codigo CLIPPED
            DISPLAY p_codigo TO tip_acerto
         END IF

      WHEN INFIELD(cod_acerto)
         CALL log009_popup(8,12,"TIPOS DE ACERTO","tip_acerto_265",
              "cod_TIPO","den_TIPO","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_acerto = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_acerto
         END IF

   END CASE 

END FUNCTION 

#-------------------------#
FUNCTION pol1072_le_func()
#-------------------------#

   DEFINE p_query CHAR(600),
          p_mesano CHAR(07)
   
   LET p_index = 1
   INITIALIZE pr_func, pr_id TO NULL
   
   LET p_query = 
   "SELECT nom_funcionario, num_cpf, tip_acerto, id_registro, ",
   "       dat_acerto_prev, dat_conciliacao, nom_usuario ",
   "  FROM diverg_consig_265 ",
   " WHERE cod_status <> 'E' ",
   "   AND cod_banco  = '",p_tela.cod_banco,"' ",
   "   AND num_cpf LIKE '","%",p_tela.num_cpf CLIPPED,"%","' ",
   "   AND nom_funcionario LIKE '","%",p_tela.nom_func CLIPPED,"%","' "
   
   IF p_tela.cod_acerto > 0  THEN
      LET p_query = p_query CLIPPED, "   AND tip_acerto = '",p_tela.cod_acerto,"' "
   END IF   

   IF p_tela.mes_ref IS NOT NULL THEN
      LET p_dat_char = '01/',p_tela.mes_ref,'/',p_tela.ano_ref 
      LET p_data = p_dat_char  
      LET p_mesano = EXTEND(p_data, YEAR TO MONTH)
      LET p_query = p_query CLIPPED, " AND  to_char(dat_referencia, 'YYYY-MM') = '",p_mesano,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY nom_funcionario, dat_referencia "
        
   PREPARE cunsulta FROM p_query    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE', 'cunsulta')
      RETURN FALSE
   END IF
   
   DECLARE cq_func CURSOR FOR cunsulta
         
   FOREACH cq_func INTO
           pr_func[p_index].funcionario,
           pr_func[p_index].cpf,
           pr_func[p_index].cod_tipo,
           pr_id[p_index].id_registro,
           p_dat_char,
           pr_func[p_index].dat_conciliacao,
           pr_func[p_index].nom_usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_func')
         RETURN FALSE
      END IF

      LET pr_func[p_index].dat_acerto = p_dat_char[6,7],'/',p_dat_char[1,4]                          
      LET p_index = p_index + 1
      
      IF p_index > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Não há divergências, para os parâmetros informados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)     

   INPUT ARRAY pr_func 
      WITHOUT DEFAULTS FROM sr_func.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1072_modificar()
#--------------------------#
           
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_func WITHOUT DEFAULTS FROM sr_func.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

         CALL pol1072_exibe_obs()
   
      AFTER FIELD edita

         IF pr_func[p_index].edita IS NOT NULL THEN
            LET pr_func[p_index].edita = NULL
            NEXT FIELD edita
         ELSE
            IF FGL_LASTKEY() = 2016 THEN
               EXIT INPUT
            ELSE
               IF FGL_LASTKEY() = 13 THEN
                  IF pr_func[p_index].cpf IS NOT NULL THEN
                     CALL pol1072_edita_func()
                  END IF
                  NEXT FIELD edita
               END IF
            END IF
         END IF      

         IF FGL_LASTKEY() = 2000 THEN    
         ELSE
            IF pr_func[p_index].cpf IS NULL THEN   
               NEXT FIELD edita
            END IF
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1072_exibe_obs()
#---------------------------#

   INITIALIZE p_acerto TO NULL 
   
   IF pr_id[p_index].id_registro IS NOT NULL THEN
      SELECT tip_acerto,                                         
             val_acerto,                                             
             dat_acerto_prev,                                        
             observacao,
             cod_status                                              
        INTO p_acerto.tip_acerto,
             p_acerto.val_acerto,
             p_dat_char,
             p_acerto.observacao,
             p_cod_status
        FROM diverg_consig_265                                       
       WHERE id_registro = pr_id[p_index].id_registro                
                                                                     
      IF STATUS <> 0 THEN                                            
         CALL log003_err_sql('Lendo','diverg_consig_265:1') 
         INITIALIZE p_acerto TO NULL  
      ELSE
         LET p_acerto.mes_acerto = p_dat_char[6,7],'/',p_dat_char[1,4]
         LET p_acerto.den_tipo   = pol1072_le_tipo(p_acerto.tip_acerto)
      END IF                                                         
   END IF
   
   DISPLAY BY NAME p_acerto.*

END FUNCTION

#------------------------------#
FUNCTION pol1072_le_tipo(p_tipo)
#------------------------------#

   DEFINE p_tipo    INTEGER,
          p_retorno CHAR(25)

   SELECT den_tipo
     INTO p_retorno
     FROM tip_acerto_265
    WHERE cod_tipo = p_tipo
      
   IF STATUS = 100 THEN
      LET p_retorno = "Tipo não cadastrado"
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tip_acerto_265')
      END IF
   END IF

   RETURN (p_retorno)
   
END FUNCTION

#----------------------------#
FUNCTION pol1072_edita_func()
#----------------------------#
     
   DEFINE p_tip_txt CHAR(02),
          p_val_txt CHAR(12),
          p_tip_ant DECIMAL(2,0)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1072a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1072a AT 10,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_acerto.*
      WITHOUT DEFAULTS

      AFTER FIELD mes_acerto
         
         IF p_acerto.mes_acerto <> '  /    ' THEN
            LET p_ano_mes = p_acerto.mes_acerto[4,7],'/',p_acerto.mes_acerto[1,2]
            IF p_ano_mes < p_mes_refer THEN
               LET p_mes_ano = p_mes_refer[1,2],'/',p_acerto.mes_acerto[4,7]
               ERROR 'O acerto deve ser maior ou igual a ', p_mes_ano,'!'
               NEXT FIELD mes_acerto
            END IF
            IF NOT pol1072_valida_mes(p_acerto.mes_acerto) THEN
               ERROR 'Valor inválido para o campo!'
               NEXT FIELD mes_acerto
            END IF
         ELSE
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD mes_acerto
         END IF
          
      AFTER FIELD val_acerto
      
         IF p_acerto.val_acerto IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD val_acerto
         END IF
      
      BEFORE FIELD tip_acerto
         LET p_tip_ant = p_acerto.tip_acerto
      
      AFTER FIELD tip_acerto
         
         SELECT den_tipo
           INTO p_acerto.den_tipo
           FROM tip_acerto_265
          WHERE cod_tipo = p_acerto.tip_acerto   

         IF STATUS <> 0 THEN
            ERROR 'Tipo inválido!'
            NEXT FIELD tip_acerto
         END IF
         
         DISPLAY p_acerto.den_tipo TO den_tipo
                  
         IF p_acerto.tip_acerto <> p_tip_ant THEN
            LET p_tip_txt = p_acerto.tip_acerto                          
            LET p_val_txt = p_acerto.val_acerto                          
            LET p_msg = '(',p_tip_txt CLIPPED,') - ',p_acerto.den_tipo   
            LET p_msg = p_msg CLIPPED, ' R$ ', p_val_txt                 
            LET p_acerto.observacao = p_msg
            DISPLAY p_msg TO observacao
         END IF
      
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF p_acerto.mes_acerto = '  /    ' OR
               p_acerto.mes_acerto = '' OR p_acerto.mes_acerto IS NULL THEN
               LET p_acerto.tip_acerto = 5
               DISPLAY p_acerto.tip_acerto TO tip_acerto
               SELECT den_tipo
                 INTO p_acerto.den_tipo
                 FROM tip_acerto_265
                WHERE cod_tipo = p_acerto.tip_acerto   
               DISPLAY p_acerto.den_tipo TO den_tipo
               LET p_acerto.observacao = p_acerto.den_tipo
               DISPLAY p_acerto.den_tipo TO observacao
            ELSE
               IF p_acerto.tip_acerto = 5 THEN
                  ERROR 'Informe o tipo de acerto!'
                  NEXT FIELD tip_acerto
               END IF
            END IF
         END IF
                   
      ON KEY (control-z)
         CALL pol1072_popup()

   END INPUT

   CLOSE WINDOW w_pol1072a
   
   CURRENT WINDOW IS w_pol1072

   IF INT_FLAG  THEN
      CALL pol1072_exibe_obs()
      RETURN
   END IF
   
   LET p_arbitrou = TRUE
   
   CALL pol1072_grava_arbitragem() RETURNING p_status
   LET pr_func[p_index].dat_acerto = p_acerto.mes_acerto
   LET pr_func[p_index].cod_tipo = p_acerto.tip_acerto
   LET pr_func[p_index].dat_conciliacao = TODAY
   LET pr_func[p_index].nom_usuario = p_user
   
   DISPLAY p_acerto.mes_acerto TO sr_func[s_index].dat_acerto
   DISPLAY p_acerto.tip_acerto TO sr_func[s_index].cod_tipo
   DISPLAY TODAY TO sr_func[s_index].dat_conciliacao
   DISPLAY p_user TO sr_func[s_index].nom_usuario
   
   CALL pol1072_exibe_obs()
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1072_valida_mes(p_mes_ano)
#-------------------------------------#

   DEFINE p_mes_ano CHAR(07),
          p_mes     INTEGER,
          p_ano     INTEGER,
          p_mes_atu CHAR(07)
   
   LET p_mes = p_mes_ano[1,2]
   LET p_ano = p_mes_ano[4,7]
   
   IF p_mes < 1 OR p_mes > 12 OR p_mes IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
   IF p_ano < YEAR(TODAY) OR p_ano IS NULL THEN
      RETURN FALSE
   END IF

   IF p_mes < MONTH(TODAY) AND p_ano <= YEAR(TODAY) THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE
   
END FUNCTION
    
#----------------------------------#
FUNCTION pol1072_grava_arbitragem()
#----------------------------------#

   LET p_dat_char = '01/',p_acerto.mes_acerto[1,2],'/',p_acerto.mes_acerto[4,7]
   LET p_data = p_dat_char  
   LET p_dat_acerto = p_data   
   LET p_data = TODAY
   
   IF p_acerto.tip_acerto = 6 THEN
      LET p_cod_status = 'E'
   ELSE
      LET p_cod_status = 'A'
      IF p_acerto.tip_acerto = 7 THEN
         IF NOT pol1072_liquida_contr() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
     
   UPDATE diverg_consig_265
      SET val_acerto      = p_acerto.val_acerto,
          tip_acerto      = p_acerto.tip_acerto,
          dat_acerto_prev = p_dat_acerto,
          dat_conciliacao = p_data,
          nom_usuario     = p_user,
          observacao      = p_acerto.observacao,
          cod_status      = p_cod_status          
    WHERE id_registro = pr_id[p_index].id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','diverg_consig_265')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1072_liquida_contr()
#------------------------------#

   DEFINE p_cod_banco DECIMAL(3,0),
          p_num_cpf   CHAR(19)
          
   SELECT cod_banco,
          num_cpf
     INTO p_cod_banco,
          p_num_cpf
     FROM diverg_consig_265
    WHERE id_registro = pr_id[p_index].id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','diverg_consig_265:2')  
      RETURN FALSE
   END IF
   
   LET p_data = TODAY
   
   UPDATE contr_consig_265
      SET dat_liquidacao = p_data
    WHERE cod_banco = p_cod_banco
      AND num_cpf   = p_num_cpf
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','contr_consig_265')  
      RETURN FALSE
   END IF
   
   RETURN TRUE

   
END FUNCTION

#------------------------------#
FUNCTION pol1072_valida_cpf(cpf)
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



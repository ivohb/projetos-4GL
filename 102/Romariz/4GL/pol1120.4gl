#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1120                                                 #
# OBJETIVO: ANÁLISES POR PRAZO DE VALIDADE                          #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 10/11/11                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,        
		      p_operacao           CHAR(10),
		      p_mensagem           CHAR(300),
		      p_id_registro        INTEGER,
		      p_cod_familia        char(05),
		      p_cod_familiaa       char(05),
          p_dat_atual          date,
          p_txt_tip            char(10),
		      p_tip_analise        decimal(6,0),
		      p_tip_analisea       decimal(6,0),
          p_dat_analise        DATE,
          p_dat_analisea       DATE,
          p_dat_vali_ini       DATE,
          p_dat_vali_inia      DATE,
          p_txt_val            char(15)

   DEFINE p_analise            RECORD
          cod_empresa          CHAR(02),
          tip_analise          DECIMAL(6,0),
          metodo               CHAR(20),              
          cod_familia          CHAR(5),              
          cod_item             CHAR(15),             
          dat_vali_ini         DATE,        
          dat_vali_fim         DATE,        
          dat_analise          DATE,        
          em_analise           CHAR(01),
          resultado            CHAR(250)
   END RECORD     
   
   DEFINE p_relat              RECORD LIKE analise_vali_915.*
   
   DEFINE p_den_analise_port   CHAR(30),
          p_ies_validade       CHAR(01),
          p_today              DATE,
          p_den_familia        CHAR(30),
          p_den_item           CHAR(76)      
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1120-10.02.04"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL POL1120_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION POL1120_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1120") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1120 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1120_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1120_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1120_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1120_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1120_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_tip_analise TO tip_analise

               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1120_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1120_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1120_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1120

END FUNCTION

#-----------------------#
 FUNCTION pol1120_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
	
#--------------------------#
 FUNCTION pol1120_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_analise.* TO NULL
   LET INT_FLAG  = FALSE

   IF pol1120_edita_dados() THEN
      CALL log085_transacao("BEGIN")
      
      INSERT INTO analise_vali_915 
           VALUES (p_analise.cod_empresa,
                   p_analise.tip_analise,
                   p_analise.metodo,
                   p_analise.cod_familia,
                   p_analise.cod_item,
                   p_analise.dat_vali_ini,
                   p_analise.dat_vali_fim,
                   p_analise.dat_analise,
                   p_analise.em_analise,
                   p_analise.resultado,
                   p_user)
                   
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","analise_vali_915")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         LET p_operacao = 'INCLUIU'
         LET p_cod_familia = p_analise.cod_familia
         LET p_txt_tip = p_analise.tip_analise
         LET p_mensagem = 'Tipo: ', p_txt_tip CLIPPED, 
                          ' validade: ', p_analise.dat_vali_ini, ' a ', p_analise.dat_vali_fim,
                          ' valor: ', p_analise.resultado CLIPPED
         If not pol1120_grava_audit() then
            CALL log085_transacao("ROLLBACK")
         Else      
            CALL log085_transacao("COMMIT")
            RETURN TRUE
         end if
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION pol1120_grava_audit()
#----------------------------#
   
   select max(id_registro)
     into p_id_registro
     from analise_audit_915
    where cod_empresa = p_cod_empresa

   if p_id_registro is null then
      let p_id_registro = 1
   else
      let p_id_registro = p_id_registro + 1
   end if    
   
   let p_dat_atual = TODAY

   
   INSERT INTO analise_audit_915
         VALUES (p_id_registro,
                 p_cod_empresa,
                 p_analise.cod_item,  
                 '',
                 p_cod_familia,      
                 p_dat_atual,
                 '',
                 p_user,
                 p_operacao,
                 p_mensagem)
   
   if status <> 0 then
      call log003_err_sql('Inserindo', 'analise_audit_915')
      RETURN FALSE
   end if
   
   RETURN TRUE
   
end FUNCTION

#------------------------------#
 FUNCTION pol1120_edita_dados()
#------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   LET p_analise.cod_empresa = p_cod_empresa
   LET p_today = TODAY

      
   LET p_analise.dat_analise = p_today

      
   INPUT BY NAME p_analise.tip_analise,
                 p_analise.cod_familia,
                 p_analise.cod_item
      WITHOUT DEFAULTS
                       
      AFTER FIELD tip_analise
      IF p_analise.tip_analise IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD tip_analise   
      END IF
          
      SELECT den_analise_port,
             ies_validade
        INTO p_den_analise_port,
             p_ies_validade
        FROM it_analise_915
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = p_analise.tip_analise
         
      IF STATUS = 100 THEN 
         ERROR 'Análise não cadastrada !!!'
         NEXT FIELD tip_analise
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','it_analise_915')
            RETURN FALSE
         END IF 
      END IF  
      
      if p_ies_validade = 'N' then
         ERROR 'Informe um análise por validade !!!'
         NEXT FIELD tip_analise
      end if
      
      DISPLAY p_den_analise_port TO den_analise_port
      
      AFTER FIELD cod_familia 
      IF p_analise.cod_familia IS NOT NULL THEN 
         
         SELECT den_familia
           INTO p_den_familia
           FROM familia
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_analise.cod_familia
            
         IF STATUS = 100 THEN
            ERROR "Família não cadastrada !!!"
            NEXT FIELD cod_familia
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','familia')
               RETURN FALSE
            END IF
         END IF
         
         DISPLAY p_den_familia TO den_familia
         EXIT INPUT         
      END IF
      
      AFTER FIELD cod_item

      IF p_analise.cod_item IS NULL THEN
         NEXT FIELD cod_familia
      end if
       
      SELECT den_item_portugues                    
        INTO p_den_item
        FROM item_915                              
       WHERE cod_empresa = p_cod_empresa        
         AND cod_item_analise = p_analise.cod_item   
                                                      
      IF STATUS = 100 THEN                      
         ERROR "Item não cadastrado no pol1118 !!!"        
         NEXT FIELD cod_item                    
      ELSE                                      
         IF STATUS <> 0 THEN                    
            CALL log003_err_sql('lendo','item') 
            RETURN FALSE                        
         END IF                                 
      END IF                                    
                                                      
      DISPLAY p_den_item TO den_item
            
      ON KEY (control-z)
         CALL pol1120_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   if not pol1020_aceita_validade() then
      RETURN false
   end if
   
   RETURN true
   
end FUNCTION

#---------------------------#
FUNCTION pol1120_le_metodo()
#---------------------------#

    SELECT metodo
      INTO p_analise.metodo
      FROM especific_915
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_analise.cod_item
       AND tip_analise = p_analise.tip_analise
       AND cod_cliente IS NULL 

   if status <> 0 then
      call log003_err_sql('Lendo','especific_915')
      let p_analise.metodo = ''
   end if
   
   display p_analise.metodo to metodo
   
end FUNCTION

#--------------------------------#
FUNCTION pol1020_aceita_validade()
#--------------------------------#

   INPUT BY NAME p_analise.metodo,
                 p_analise.dat_analise,
                 p_analise.dat_vali_ini,
                 p_analise.dat_vali_fim,
                 p_analise.em_analise,
                 p_analise.resultado
      WITHOUT DEFAULTS
   
      AFTER FIELD dat_vali_ini
      IF p_analise.dat_vali_ini IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD dat_vali_ini   
      END IF
            
      AFTER FIELD dat_vali_fim
      IF p_analise.dat_vali_fim IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD dat_vali_fim   
      END IF
      
      IF p_analise.dat_vali_fim < p_analise.dat_vali_ini THEN
         ERROR "A data inicial não pode ser maior que a data final !"
         NEXT FIELD dat_vali_fim 
      END IF

      AFTER FIELD em_analise
      IF p_analise.em_analise MATCHES "[SN]" THEN
      else
         ERROR "Valor inválido para o campo !!!"
         NEXT FIELD em_analise   
      END IF     
                  
      AFTER FIELD resultado
      IF p_analise.resultado IS NULL THEN 
         let p_analise.em_analise = 'S' 
      else
         let p_analise.em_analise = 'N' 
      END IF     
      
      DISPLAY p_analise.em_analise to em_analise
      
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1120_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(tip_analise)
         CALL log009_popup(8,10,"Tipo de análises","it_analise_915",
              "tip_analise","den_analise_port","","S","  ies_validade = 'S'") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_analise.tip_analise = p_codigo CLIPPED
            DISPLAY p_codigo TO tip_analise
         END IF
         
      WHEN INFIELD(cod_familia)
         
         CALL log009_popup(8,25,"FAMILIAS","familia",
                     "cod_familia","den_familia","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1120
         
         IF p_codigo IS NOT NULL THEN
            LET p_analise.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF
      
      WHEN INFIELD(cod_item)
         {LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1120
         IF p_codigo IS NOT NULL THEN
           LET p_analise.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF}

         CALL log009_popup(9,13,"ITEM ANALISE","item_915","cod_item_analise",
                                "den_item_portugues","POL0337","S","")
            RETURNING p_codigo

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1120

         IF p_codigo IS NOT NULL THEN
            let p_analise.cod_item = p_codigo
            DISPLAY p_analise.cod_item TO cod_item
         END IF
         
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1120_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)
		  
		  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_tip_analisea = p_tip_analise
   LET p_cod_familiaa = p_cod_familia
   LET p_dat_analisea = p_dat_analise
   LET p_dat_vali_inia = p_dat_vali_ini
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      analise_vali_915.tip_analise,
      analise_vali_915.cod_familia,
      analise_vali_915.cod_item,
      analise_vali_915.dat_analise,
      analise_vali_915.dat_vali_ini,
      analise_vali_915.dat_vali_fim,
      analise_vali_915.em_analise,
      analise_vali_915.resultado
      
      ON KEY (control-z)
         CALL pol1120_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_tip_analise = p_tip_analisea
         LET p_cod_familia = p_cod_familiaa
         LET p_dat_analise = p_dat_analisea
         CALL pol1120_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF
      
   LET sql_stmt = "SELECT cod_familia, tip_analise, dat_analise, dat_vali_ini",
                  "  FROM analise_vali_915 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY dat_analise"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_familia, p_tip_analise, p_dat_analise, p_dat_vali_ini


   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1120_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1120_exibe_dados()
#------------------------------#
   
   INITIALIZE p_den_familia, p_den_item TO NULL
   
   IF p_cod_familia <> "  " THEN
   	SELECT tip_analise,
          metodo,
          cod_familia, 
          cod_item, 
          dat_vali_ini, 
          dat_vali_fim,
          dat_analise,
          em_analise,
          resultado
     INTO p_analise.tip_analise,
          p_analise.metodo,
          p_analise.cod_familia, 
          p_analise.cod_item,
          p_analise.dat_vali_ini,
          p_analise.dat_vali_fim, 
          p_analise.dat_analise,
          p_analise.em_analise,
          p_analise.resultado
     FROM analise_vali_915
    	WHERE cod_empresa = p_cod_empresa
     	AND tip_analise = p_tip_analise
     	AND cod_familia = p_cod_familia
      AND dat_analise = p_dat_analise
      AND dat_vali_ini = p_dat_vali_ini

  ELSE
   	SELECT tip_analise,
          metodo,
          cod_familia, 
          cod_item, 
          dat_vali_ini, 
          dat_vali_fim,
          dat_analise,
          em_analise,
          resultado
     INTO p_analise.tip_analise,
          p_analise.metodo,
          p_analise.cod_familia, 
          p_analise.cod_item,
          p_analise.dat_vali_ini,
          p_analise.dat_vali_fim, 
          p_analise.dat_analise,
          p_analise.em_analise,
          p_analise.resultado
     FROM analise_vali_915
    	WHERE cod_empresa = p_cod_empresa
     	AND tip_analise = p_tip_analise
      AND dat_analise = p_dat_analise
      AND dat_vali_ini = p_dat_vali_ini
   END IF	
   
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "analise_vali_915")
      RETURN FALSE
   END IF
   
   SELECT den_analise_port
     INTO p_den_analise_port
     FROM it_analise_915
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = p_analise.tip_analise
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','it_analise_915')
      RETURN FALSE 
   END IF
   
   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_analise.cod_familia
   
   IF STATUS = 100 THEN
      
      SELECT den_item_portugues
        INTO p_den_item
        FROM item_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_analise = p_analise.cod_item
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','item')
         RETURN FALSE 
      END IF
   
   ELSE
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','familia')
         RETURN FALSE 
      END IF
   
   END IF
   
   DISPLAY p_analise.tip_analise  TO tip_analise
   DISPLAY p_den_analise_port     TO den_analise_port
   DISPLAY p_analise.metodo       to metodo
   DISPLAY p_analise.cod_familia  TO cod_familia 
   DISPLAY p_den_familia          TO den_familia
   DISPLAY p_analise.cod_item     TO cod_item 
   DISPLAY p_den_item             TO den_item
   DISPLAY p_analise.dat_vali_ini TO dat_vali_ini
   DISPLAY p_analise.dat_vali_fim TO dat_vali_fim
   DISPLAY p_analise.dat_analise  TO dat_analise
   DISPLAY p_analise.em_analise   TO em_analise
   DISPLAY p_analise.resultado    TO resultado
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1120_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_tip_analisea = p_tip_analise
   LET p_cod_familiaa = p_cod_familia
   LET p_dat_analisea = p_dat_analise
   LET p_dat_vali_inia = p_dat_vali_ini
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
            p_cod_familia, p_tip_analise, p_dat_analise, p_dat_vali_ini
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
            p_cod_familia, p_tip_analise, p_dat_analise, p_dat_vali_ini
      
      END CASE

      IF STATUS = 0 THEN
   		   IF p_cod_familia <> "  " THEN
            SELECT tip_analise
              FROM analise_vali_915
    			   WHERE cod_empresa = p_cod_empresa
     			     AND tip_analise = p_tip_analise
     			     AND cod_familia = p_cod_familia
     			     AND dat_analise = p_dat_analise
     			     AND dat_vali_ini = p_dat_vali_ini
     	   ELSE
            SELECT tip_analise
              FROM analise_vali_915
    			   WHERE cod_empresa = p_cod_empresa
     			     AND tip_analise = p_tip_analise
     			     AND dat_analise = p_dat_analise
     			     AND dat_vali_ini = p_dat_vali_ini
     	   END IF		 
            
         IF STATUS = 0 THEN
            CALL pol1120_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tip_analise = p_tip_analisea
            LET p_cod_familia = p_cod_familiaa
            LET p_dat_analise = p_dat_analisea
            LET p_dat_vali_ini = p_dat_vali_inia
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1120_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   	IF p_cod_familia <> "  " THEN
   		DECLARE cq_prende CURSOR FOR
    	SELECT tip_analise 
      	FROM analise_vali_915  
      	WHERE cod_empresa = p_cod_empresa
       	AND tip_analise = p_tip_analise
       	AND cod_familia = p_cod_familia
 	      AND dat_analise = p_dat_analise
	      AND dat_vali_ini = p_dat_vali_ini
       	FOR UPDATE 
     ELSE
   		DECLARE cq_prende CURSOR FOR
    	SELECT tip_analise 
      	FROM analise_vali_915  
      	WHERE cod_empresa = p_cod_empresa
       	AND tip_analise = p_tip_analise
 	      AND dat_analise = p_dat_analise
 			  AND dat_vali_ini = p_dat_vali_ini
       	AND cod_familia IS NULL
       	FOR UPDATE 
    END IF   	
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","analise_vali_915")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1120_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE   
   LET INT_FLAG  = FALSE
   
   IF pol1120_prende_registro() THEN
      IF pol1020_aceita_validade() THEN
        IF p_cod_familia <> "  " THEN   
         UPDATE analise_vali_915
            SET dat_vali_ini = p_analise.dat_vali_ini, 
                dat_vali_fim = p_analise.dat_vali_fim,
                em_analise   = p_analise.em_analise,
                resultado    = p_analise.resultado,
                usuario      = p_user
    				WHERE cod_empresa = p_cod_empresa
     				AND tip_analise = p_tip_analise
     				AND cod_familia = p_cod_familia
 			      AND dat_analise = p_dat_analise
 			      AND dat_vali_ini = p_dat_vali_ini
     		ELSE
         UPDATE analise_vali_915
            SET dat_vali_ini = p_analise.dat_vali_ini, 
                dat_vali_fim = p_analise.dat_vali_fim,
                em_analise   = p_analise.em_analise,
                resultado    = p_analise.resultado,
                usuario      = p_user
    				WHERE cod_empresa = p_cod_empresa
     				AND tip_analise = p_tip_analise
     				AND cod_familia IS NULL
 			      AND dat_analise = p_dat_analise
 			      AND dat_vali_ini = p_dat_vali_ini
     		END IF		
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "analise_vali_915")
         ELSE
            LET p_operacao = 'ALTEROU'
            LET p_cod_familia = p_analise.cod_familia
            LET p_txt_tip = p_analise.tip_analise
            LET p_mensagem = 'Tipo: ', p_txt_tip CLIPPED, 
                             ' validade: ', p_analise.dat_vali_ini, ' a ', p_analise.dat_vali_fim,
                             ' valor: ', p_analise.resultado CLIPPED
            If pol1120_grava_audit() then
               LET p_retorno = TRUE
            End if
         END IF
      ELSE
         CALL pol1120_exibe_dados() RETURNING p_status
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
 FUNCTION pol1120_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1120_prende_registro() THEN
   		IF p_cod_familia <> "  " THEN
      	DELETE FROM analise_vali_915
    		WHERE cod_empresa = p_cod_empresa
     		AND tip_analise = p_tip_analise
     		AND cod_familia = p_cod_familia
	      AND dat_analise = p_dat_analise
 	      AND dat_vali_ini = p_dat_vali_ini
     	ELSE
      	DELETE FROM analise_vali_915
    		WHERE cod_empresa = p_cod_empresa
     		AND tip_analise = p_tip_analise
	      AND dat_analise = p_dat_analise
	      AND dat_vali_ini = p_dat_vali_ini
     		AND cod_familia IS NULL
     	END IF 	

      IF STATUS = 0 THEN               
         LET p_operacao = 'EXCLUIU'
         LET p_cod_familia = p_analise.cod_familia
         LET p_txt_tip = p_analise.tip_analise
         LET p_mensagem = 'Tipo: ', p_txt_tip CLIPPED, 
                          ' validade: ', p_analise.dat_vali_ini, ' a ', p_analise.dat_vali_fim,
                          ' valor: ', p_analise.resultado CLIPPED
         If pol1120_grava_audit() then
            INITIALIZE p_analise.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE                    
         End if
      ELSE
         CALL log003_err_sql("Excluindo","analise_vali_915")
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
{
#--------------------------#
 FUNCTION pol1120_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1120_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1120_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT tip_analise,
          nom_contato,
          num_agencia,
          nom_agencia,
          num_conta,
          cod_tip_reg,
          dat_termino
     FROM analise_vali_915
 ORDER BY tip_analise                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE tip_analise = p_relat.tip_analise
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1120_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1120_relat   
   
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

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1120_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1120.tmp"
         START REPORT pol1120_relat TO p_caminho
      ELSE
         START REPORT pol1120_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1120_le_den_empresa()
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

#---------------------#
 REPORT pol1120_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1120",
               COLUMN 042, "BANCOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Banco          Descricao                       Contato              Agencia           Descricao                Conta       Identif   Termino'
         PRINT COLUMN 002, '----- ------------------------------ ------------------------------ ------- ------------------------------ --------------- -------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_relat.tip_analise   USING "###",
               COLUMN 008, p_nom_banco,
               COLUMN 039, p_relat.nom_contato,
               COLUMN 070, p_relat.num_agencia,
               COLUMN 078, p_relat.nom_agencia,
               COLUMN 109, p_relat.num_conta,
               COLUMN 131, p_relat.cod_tip_reg USING "##",
               COLUMN 134, p_relat.dat_termino
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT



#-------------------------------- FIM DE PROGRAMA -----------------------------#
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1108                                                 #
# OBJETIVO: AEN PARA FILTRO NA INTEGRAÇÃO EGA X LOGIX               #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 01/08/11                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
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
          p_msg                CHAR(300),
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_nivel              INTEGER,
          p_den_linha          CHAR(20),
          p_achou              SMALLINT
         
   DEFINE p_aen               RECORD LIKE aen_ega_logix_912.*,
          p_aen_ant           RECORD LIKE aen_ega_logix_912.*
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1108-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol1108_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1108_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1108") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1108 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   select qtd_nivel_aen
     into p_nivel
     from pct_ajust_man912
    where cod_empresa = p_cod_empresa
    
   if status <> 0 then
      CALL log003_err_sql('lendo','pct_ajust_man912')
      return
   end if
   
   display p_nivel to par_nivel

   if p_nivel = 0 then
      let p_msg = 'Nivel de área/linha não\n',
                  'cadastrada no POL0450!\n'
      call log0030_mensagem(p_msg,'excla')
      return
   end if
      
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1108_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1108_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1108_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1108_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1108_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_banco TO cod_banco
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1108_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1108_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1108

END FUNCTION

#-----------------------#
 FUNCTION pol1108_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol1108_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   display p_nivel to par_nivel
   INITIALIZE p_aen.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   LET p_opcao = 'I'
   LET p_aen.cod_lin_prod = 0
   LET p_aen.cod_lin_recei = 0
   LET p_aen.cod_seg_merc = 0
   LET p_aen.cod_cla_uso = 0

   IF pol1108_edita_dados() THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO aen_ega_logix_912 VALUES (p_aen.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","aen_ega_logix_912")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1108_edita_dados()
#------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT by name p_aen.* WITHOUT DEFAULTS
                       
      AFTER FIELD cod_lin_prod
         IF p_aen.cod_lin_prod IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_lin_prod   
         END IF
      
         if not pol1108_le_aen() then
            RETURN false
         end if
         
         if not p_achou then
            ERROR 'Área/linha inexistente do Logix!!!'
            NEXT FIELD cod_lin_prod
         end if
                       
         DISPLAY p_den_linha TO den_linha

      BEFORE FIELD cod_lin_recei
         if p_nivel < 2 then
            EXIT INPUT
         end if

      AFTER FIELD cod_lin_recei
         IF p_aen.cod_lin_recei IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_lin_recei   
         END IF
         
         if not pol1108_le_aen() then
            RETURN false
         end if
         
         if not p_achou then
            ERROR 'Área/linha inexistente do Logix!!!'
            NEXT FIELD cod_lin_recei
         end if
      
         DISPLAY p_den_linha TO den_linha

      BEFORE FIELD cod_seg_merc
         if p_nivel < 3 then
            EXIT INPUT
         end if

      AFTER FIELD cod_seg_merc
         IF p_aen.cod_seg_merc IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_seg_merc   
         END IF
          
         if not pol1108_le_aen() then
            RETURN false
         end if
         
         if not p_achou then
            ERROR 'Área/linha inexistente do Logix!!!'
            NEXT FIELD cod_seg_merc
         end if
      
         DISPLAY p_den_linha TO den_linha

      BEFORE FIELD cod_cla_uso
         if p_nivel < 4 then
            EXIT INPUT
         end if

      AFTER FIELD cod_cla_uso
         IF p_aen.cod_cla_uso IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cla_uso   
         END IF
          
         if not pol1108_le_aen() then
            RETURN false
         end if
         
         if not p_achou then
            ERROR 'Área/linha inexistente do Logix!!!'
            NEXT FIELD cod_cla_uso
         end if
      
         DISPLAY p_den_linha TO den_linha

      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            select cod_lin_prod
              from aen_ega_logix_912
             WHERE cod_lin_prod = p_aen.cod_lin_prod
              and cod_lin_recei = p_aen.cod_lin_recei
              and cod_seg_merc  = p_aen.cod_seg_merc
              and cod_cla_uso   = p_aen.cod_cla_uso
            if status = 0 then
               error 'Área/linha já cadastrada no pol1108!' 
               next field cod_lin_prod
            end if
         END IF
      
      ON KEY (control-z)
         CALL pol1108_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      display p_nivel to par_nivel
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1108_le_aen()
#------------------------#

   let p_achou = false
   
   SELECT den_estr_linprod
     INTO p_den_linha
     FROM linha_prod
    WHERE cod_lin_prod  = p_aen.cod_lin_prod
      and cod_lin_recei = p_aen.cod_lin_recei
      and cod_seg_merc  = p_aen.cod_seg_merc
      and cod_cla_uso   = p_aen.cod_cla_uso
         
   IF STATUS = 0 THEN 
      let p_achou = true
   ELSE
      IF STATUS <> 100 THEN 
         CALL log003_err_sql('lendo','linha_prod')
         RETURN FALSE
      END IF 
   END IF  

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1108_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol1106_le_lin_prod('1')
                   
         IF p_codigo IS NOT NULL THEN
            LET p_aen.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF

      WHEN INFIELD(cod_lin_recei)
         LET p_codigo = pol1106_le_lin_prod('2')
                   
         IF p_codigo IS NOT NULL THEN
            LET p_aen.cod_lin_recei = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_recei
         END IF

      WHEN INFIELD(cod_seg_merc)
         LET p_codigo = pol1106_le_lin_prod('3')
                   
         IF p_codigo IS NOT NULL THEN
            LET p_aen.cod_seg_merc = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_seg_merc
         END IF

      WHEN INFIELD(cod_cla_uso)
         LET p_codigo = pol1106_le_lin_prod('4')
                   
         IF p_codigo IS NOT NULL THEN
            LET p_aen.cod_cla_uso = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cla_uso
         END IF

   END CASE 

END FUNCTION 

#---------------------------------#
FUNCTION pol1106_le_lin_prod(p_cod)
#---------------------------------#

   DEFINE pr_linha      ARRAY[500] OF RECORD
          codigo        decimal(2,0),
          nome          char(20)
   END RECORD
   
   DEFINE p_retorno     decimal(2,0),
          sql_stmt      CHAR(800),
          p_cod         CHAR(01)
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11081") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11081 AT 5,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER,  FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   Case
      when p_cod = '1' 
         LET sql_stmt = 
            "select cod_lin_prod, den_estr_linprod ",
            " from linha_prod ",
            " WHERE cod_lin_recei = '0' ",
            "   and cod_seg_merc  = '0' ",
            "   and cod_cla_uso   = '0' ",
            " order by den_estr_linprod "
      when p_cod = '2' 
         LET sql_stmt = 
            "select cod_lin_recei, den_estr_linprod ",
            " from linha_prod ",
            " WHERE cod_lin_prod  = '",p_aen.cod_lin_prod,"' ",
            "   and cod_seg_merc  = '0' ",
            "   and cod_cla_uso   = '0' ",
            " order by den_estr_linprod "
      when p_cod = '3' 
         LET sql_stmt = 
            "select cod_seg_merc, den_estr_linprod ",
            " from linha_prod ",
            " WHERE cod_lin_prod  = '",p_aen.cod_lin_prod,"' ",
            "   and cod_lin_recei = '",p_aen.cod_lin_recei,"' ",
            "   and cod_cla_uso   = '0' ",
            " order by den_estr_linprod "
      when p_cod = '4' 
         LET sql_stmt = 
            "select cod_cla_uso, den_estr_linprod ",
            " from linha_prod ",
            " WHERE cod_lin_prod  = '",p_aen.cod_lin_prod,"' ",
            "   and cod_lin_recei = '",p_aen.cod_lin_recei,"' ",
            "   and cod_seg_merc  = '",p_aen.cod_seg_merc,"' ",
            " order by den_estr_linprod "
   End Case
   
   PREPARE p_query FROM sql_stmt   
   DECLARE cq_linha CURSOR FOR p_query

   FOREACH cq_linha INTO
           pr_linha[p_ind].codigo,
           pr_linha[p_ind].nome

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','linha_prod:1')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhum registro foi encontrado, na tabela linha_prod!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_linha TO sr_linha.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 

   CLOSE WINDOW w_pol11081
         
   IF NOT INT_FLAG THEN
      let p_retorno = pr_linha[p_ind].codigo
      RETURN(p_retorno)
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1108_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   display p_nivel to par_nivel
   LET p_aen_ant.* = p_aen.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      aen_ega_logix_912.cod_lin_prod,
      aen_ega_logix_912.cod_lin_recei,
      aen_ega_logix_912.cod_seg_merc,
      aen_ega_logix_912.cod_cla_uso
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            display p_nivel to par_nivel
         ELSE
            LET p_aen.* = p_aen_ant.*
            CALL pol1108_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * FROM aen_ega_logix_912 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_aen.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1108_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1108_exibe_dados()
#------------------------------#
   

   display by name p_aen.*
   call pol1108_le_aen() RETURNING p_status
   display p_den_linha to den_linha
      
   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol1108_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_aen_ant.* = p_aen.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_aen.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_aen.*
      
      END CASE

      IF STATUS = 0 THEN
         call pol1108_le_aen() RETURNING p_status
         if p_achou then
            CALL pol1108_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_aen.* = p_aen_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1108_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_lin_prod 
      FROM aen_ega_logix_912  
     WHERE cod_lin_prod  = p_aen.cod_lin_prod
       and cod_lin_recei = p_aen.cod_lin_recei
       and cod_seg_merc  = p_aen.cod_seg_merc
       and cod_cla_uso   = p_aen.cod_cla_uso
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","aen_ega_logix_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1108_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   
   IF pol1108_prende_registro() THEN
      IF pol1108_edita_dados() THEN
         
         UPDATE aen_ega_logix_912
            SET cod_lin_prod  = p_aen.cod_lin_prod,
                cod_lin_recei = p_aen.cod_lin_recei,
                cod_seg_merc  = p_aen.cod_seg_merc, 
                cod_cla_uso   = p_aen.cod_cla_uso
          WHERE CURRENT OF cq_prende
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "aen_ega_logix_912")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1108_exibe_dados() RETURNING p_status
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
 FUNCTION pol1108_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1108_prende_registro() THEN
      DELETE FROM aen_ega_logix_912
			WHERE CURRENT OF cq_prende

      IF STATUS = 0 THEN               
         INITIALIZE p_aen TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         display p_nivel to par_nivel
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","aen_ega_logix_912")
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
 FUNCTION pol1108_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1108_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1108_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_banco,
          nom_contato,
          num_agencia,
          nom_agencia,
          num_conta,
          cod_tip_reg,
          dat_termino
     FROM aen_ega_logix_912
 ORDER BY cod_banco                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE cod_banco = p_relat.cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1108_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1108_relat   
   
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
 FUNCTION pol1108_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1108.tmp"
         START REPORT pol1108_relat TO p_caminho
      ELSE
         START REPORT pol1108_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1108_le_den_empresa()
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
 REPORT pol1108_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1108",
               COLUMN 042, "BANCOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Banco          Descricao                       Contato              Agencia           Descricao                Conta       Identif   Termino'
         PRINT COLUMN 002, '----- ------------------------------ ------------------------------ ------- ------------------------------ --------------- -------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_relat.cod_banco   USING "###",
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
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1241                                                 #
# OBJETIVO: EMPRESAS PARA MANUTENÇÃO INDUSTRIAL                     #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/10/12                                                #
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
          p_excluiu            SMALLINT,
          p_nom_funcionario    CHAR(40)
         
END GLOBALS


DEFINE p_empresa_manut   RECORD 
  cod_empresa        char(02),
  dat_corte          date,
  usuario_email      char(08)
END RECORD

DEFINE p_empresa_manuta  RECORD 
  cod_empresa        char(02),
  dat_corte          date,
  usuario_email      char(08)
END RECORD

   DEFINE p_relat   RECORD
      cod_empresa   CHAR(02),
      den_empresa   CHAR(40),
      dat_corte     DATE,
      usuario_email char(08)
   END RECORD

DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD
          
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1241-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   #LET p_status = 0

   LET parametro.num_programa = 'POL1241'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1241_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1241_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1241") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1241 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1241_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1241_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1241_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1241_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1241_modificacao() RETURNING p_status  
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
            CALL pol1241_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1241_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1241_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1241

END FUNCTION

#-----------------------#
 FUNCTION pol1241_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1241_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1241_inclusao()
#--------------------------#

   CALL pol1241_limpa_tela()
   
   INITIALIZE p_empresa_manut TO NULL

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1241_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1241_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1241_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1241_insere()
#------------------------#

   INSERT INTO empresa_manut_ind_1099 VALUES (p_empresa_manut.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","empresa_manut_ind_1099")       
      RETURN FALSE
   END IF

   LET parametro.texto = 'INCLUSAO NA GRADE DA EMPRESA ', p_empresa_manut.cod_empresa 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1241_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_empresa_manut.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_empresa

         IF p_funcao = "M" THEN
            NEXT FIELD dat_corte
         END IF
      
      AFTER FIELD cod_empresa

         IF p_empresa_manut.cod_empresa IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_empresa   
         END IF
         
         SELECT cod_empresa
           FROM empresa_manut_ind_1099
          WHERE cod_empresa = p_empresa_manut.cod_empresa
         
         IF STATUS = 0 THEN
            ERROR 'Empresa já cadastrada no pol1241.'
            NEXT FIELD cod_empresa   
         END IF
          
         CALL pol1241_le_nom_empresa(p_empresa_manut.cod_empresa)
          
         IF p_den_empresa IS NULL THEN 
            ERROR 'Empresa inválida.'
            NEXT FIELD cod_empresa
         END IF  
         
         DISPLAY p_den_empresa TO den_empresa

      AFTER FIELD usuario_email

         IF p_empresa_manut.usuario_email IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD usuario_email   
         END IF

         CALL pol1241_le_nom_usuario(p_empresa_manut.usuario_email)
          
         IF p_nom_funcionario IS NULL THEN 
            ERROR 'Usuário inválido.'
            NEXT FIELD usuario_email
         END IF  
         
         DISPLAY p_nom_funcionario to nom_funcionario
         
      ON KEY (control-z)
         CALL pol1241_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF p_empresa_manut.dat_corte IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD dat_corte   
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1241_le_nom_empresa(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(10)
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_empresa = NULL
   END IF  

END FUNCTION

#-------------------------------------#
FUNCTION pol1241_le_nom_usuario(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(08)
   
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_nom_funcionario = NULL
   END IF  

END FUNCTION


#-----------------------#
 FUNCTION pol1241_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_empresa)
         CALL log009_popup(8,10,"Empresas","empresa",
              "cod_empresa","den_empresa","","N"," 1=1 order by cod_empresa") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_empresa_manut.cod_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_empresa
         END IF

      WHEN INFIELD(usuario_email)
         CALL log009_popup(8,10,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N"," 1=1 order by cod_usuario") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_empresa_manut.usuario_email = p_codigo CLIPPED
            DISPLAY p_codigo TO usuario_email
         END IF
         
      {WHEN INFIELD(dat_corte)
         LET p_codigo = pol1241_le_notas()
         IF p_codigo IS NOT NULL THEN
           LET p_empresa_manut.dat_corte = p_codigo
           DISPLAY p_empresa_manut.dat_corte TO dat_corte
         END IF}

   END CASE 

END FUNCTION 

#--------------------------#
FUNCTION pol1241_le_notas()#
#--------------------------#

   DEFINE pr_notas  ARRAY[2000] OF RECORD
          num_nota     INTEGER,
          dat_entrada  DATE,
          fornecedor   CHAR(30)
   END RECORD
   
   DEFINE p_cod_fornecedor      CHAR(15),
          p_raz_social          CHAR(30),
          p_num_nf              CHAR(07),
          p_dat_entrada         DATE,
          p_ser_nf              CHAR(03),
          p_ssr_nf              DECIMAL(2,0),
          p_emp_ad              CHAR(02),
          p_num_ad              INTEGER,
          p_num_ap              INTEGER,
          p_descarta            SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1241a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1241a AT 5,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 0
    
   DECLARE cq_notas CURSOR FOR
    SELECT DISTINCT
           n.num_nf,
           n.dat_entrada_nf,
           f.raz_social,
           n.ser_nf,
           n.ssr_nf,
           n.cod_fornecedor
      FROM nf_sup n, fornecedor f, aviso_rec a
     WHERE n.cod_empresa = p_empresa_manut.cod_empresa
       AND n.cod_fornecedor = f.cod_fornecedor
       AND n.dat_entrada_nf >= '01/01/2012'
       AND n.ies_especie_nf in ('NF', 'NFS', 'REC', 'NFE', 'DOC', 'NFM')
       AND a.cod_empresa = n.cod_empresa
       AND a.num_aviso_rec = n.num_aviso_rec
       AND (a.num_pedido IS NULL OR a.num_pedido = ' ' OR a.num_pedido = 0)
       AND n.cnd_pgto_nf NOT IN 
           (SELECT cnd_pgto FROM cond_pgto_cap WHERE ies_pagamento = '3')
     ORDER BY n.dat_entrada_nf

   FOREACH cq_notas INTO 
           p_num_nf,
           p_dat_entrada,
           p_raz_social,
           p_ser_nf,
           p_ssr_nf,
           p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_notas')
         EXIT FOREACH
      END IF

      SELECT cod_empresa_destin
        INTO p_emp_ad
        FROM emp_orig_destino
       WHERE cod_empresa_orig = p_empresa_manut.cod_empresa
   
      IF STATUS <> 0 THEN
         LET p_emp_ad = p_empresa_manut.cod_empresa
      END IF
      
      SELECT num_ad
        INTO p_num_ad
        FROM ad_mestre
       WHERE cod_empresa = p_emp_ad
         AND num_nf = p_num_nf
         AND ser_nf = p_ser_nf
         AND ssr_nf = p_ssr_nf
         AND cod_fornecedor = p_cod_fornecedor
         
      IF STATUS <> 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET p_descarta = FALSE
      
      DECLARE cq_ad_ap CURSOR FOR
       SELECT num_ap
         FROM ad_ap
        WHERE cod_empresa = p_emp_ad
          AND num_ad = p_num_ad
        ORDER BY num_ap
      
      FOREACH cq_ad_ap INTO p_num_ap
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_ad_ap')
            EXIT FOREACH
         END IF
      
         SELECT COUNT(num_ap)
           INTO p_count
           FROM ap
          WHERE cod_empresa = p_emp_ad
            AND num_ap = p_num_ap
            AND ies_versao_atual = 'S' 
            AND dat_pgto IS NOT NULL 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ap')
            LET p_descarta = TRUE
            EXIT FOREACH
         END IF
         
         IF p_count > 0 THEN
            LET p_descarta = TRUE
            EXIT FOREACH
         END IF
      
      END FOREACH
      
      IF p_descarta THEN
         CONTINUE FOREACH
      END IF
         
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF

      LET pr_notas[p_ind].num_nota = p_num_nf
      LET pr_notas[p_ind].dat_entrada = p_dat_entrada
      LET pr_notas[p_ind].fornecedor = p_raz_social
           
   END FOREACH
      
   CALL SET_COUNT(p_ind)
   
   DISPLAY ARRAY pr_notas TO sr_notas.*

   LET p_ind = ARR_CURR()
   LET s_ind = SCR_LINE() 

   CLOSE WINDOW w_pol1241a
   
   IF NOT INT_FLAG THEN
      RETURN pr_notas[p_ind].dat_entrada
   ELSE
      RETURN NULL
   END IF
   
END FUNCTION


#--------------------------#
 FUNCTION pol1241_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1241_limpa_tela()
   LET p_empresa_manuta.* = p_empresa_manut.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      empresa_manut_ind_1099.cod_empresa,     
      empresa_manut_ind_1099.dat_corte,
      empresa_manut_ind_1099.usuario_email
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1241_limpa_tela()
         ELSE
            LET p_empresa_manut.* = p_empresa_manuta.*
            CALL pol1241_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM empresa_manut_ind_1099 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_empresa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_empresa_manut.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1241_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1241_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_empresa_manut.*
     FROM empresa_manut_ind_1099
    WHERE cod_empresa = p_empresa_manut.cod_empresa
     
   DISPLAY BY NAME p_empresa_manut.*
   
   CALL pol1241_le_nom_empresa(p_empresa_manut.cod_empresa)
   DISPLAY p_den_empresa to den_empresa
   CALL pol1241_le_nom_usuario(p_empresa_manut.usuario_email)
   DISPLAY p_nom_funcionario to nom_funcionario
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1241_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01),
          p_emp_lida CHAR(02)

   LET p_empresa_manuta.* = p_empresa_manut.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_empresa_manut.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_empresa_manut.*
      
      END CASE

      IF STATUS = 0 THEN
         LET p_emp_lida = p_empresa_manut.cod_empresa
         SELECT *
           INTO p_empresa_manut.*
           FROM empresa_manut_ind_1099
          WHERE cod_empresa = p_emp_lida
            
         IF STATUS = 0 THEN
            CALL pol1241_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_empresa_manut.* = p_empresa_manuta.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1241_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM empresa_manut_ind_1099  
     WHERE cod_empresa = p_empresa_manut.cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","empresa_manut_ind_1099")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1241_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1241_prende_registro() THEN
      IF pol1241_edita_dados("M") THEN
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
      LET p_empresa_manut.* = p_empresa_manuta.*
      CALL pol1241_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE empresa_manut_ind_1099
      SET dat_corte = p_empresa_manut.dat_corte,
          usuario_email = p_empresa_manut.usuario_email
     WHERE cod_empresa = p_empresa_manut.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "empresa_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'ALTERACAO DA DATA DE CORTE DA EMPRESA ', p_empresa_manut.cod_empresa 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1241_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1241_prende_registro() THEN
      IF pol1241_deleta() THEN
         INITIALIZE p_empresa_manut TO NULL
         CALL pol1241_limpa_tela()
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
FUNCTION pol1241_deleta()
#------------------------#

   DELETE FROM empresa_manut_ind_1099
    WHERE cod_empresa = p_empresa_manut.cod_empresa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","empresa_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'EXCLUSAO DA EMPRESA ', p_empresa_manut.cod_empresa 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1241_listagem()
#--------------------------#     

   IF NOT pol1241_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1241_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.cod_empresa, 
           b.den_empresa,
           a.dat_corte,
           a.usuario_email
      FROM empresa_manut_ind_1099 a, Empresa b
     WHERE a.cod_empresa = b.cod_empresa
     ORDER BY a.cod_empresa
  
   FOREACH cq_impressao 
      INTO p_relat.cod_empresa,
           p_relat.den_empresa,
           p_relat.dat_corte,
           p_relat.usuario_email
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      CALL pol1241_le_nom_usuario(p_relat.usuario_email)
     
      OUTPUT TO REPORT pol1241_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1241_relat   
   
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
 FUNCTION pol1241_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(18,35) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1241.tmp"
         START REPORT pol1241_relat TO p_caminho
      ELSE
         START REPORT pol1241_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1241_le_den_empresa()
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

#----------------------#
 REPORT pol1241_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 078, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1241",
               COLUMN 010, "EMPRESA PARA MANUTENCAO INDUSTRIAL",
               COLUMN 058, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'EMPRESA                                     DAT CORTE  EMITENTE DE EMAIL'                                
         PRINT COLUMN 001, '-- ---------------------------------------- ---------- --------------------------------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_empresa,
               COLUMN 004, p_relat.den_empresa,
               COLUMN 045, p_relat.dat_corte,
               COLUMN 056, p_relat.usuario_email, ' ', p_nom_funcionario[1,23]
                              
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

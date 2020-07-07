##----------------------------------------------------------##
##  POL0753 - CADASTRO DE REPRESENTANTE - COMISSAO          ##
# CONVERSÃO 10.02: 17/07/2014 - IVO                          #
# FUNÇÕES: FUNC002                                           #
##----------------------------------------------------------##
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_nom_rep           LIKE representante.raz_social,
         p_cod_repres        LIKE representante.cod_repres,
         p_nom_ger           LIKE representante.raz_social,
         p_msg               CHAR(100)
 
  DEFINE p_repres_885        RECORD LIKE repres_885.*,
         p_ger_com_885       RECORD LIKE ger_com_885.*,      
         p_repres_885r       RECORD LIKE repres_885.*,     
         p_representante     RECORD LIKE representante.*      

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0753-10.02.00  "
   CALL func002_versao_prg(p_versao)
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0753.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0753_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0753_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0753") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0753 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0753","IN") THEN
        CALL pol0753_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_repres_885.cod_gerente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0753","MO") THEN
               CALL pol0753_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_repres_885.cod_gerente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0753","EX") THEN
               CALL pol0753_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0753","CO") THEN
           CALL pol0753_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0753_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0753_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0753
END FUNCTION

#--------------------------------------#
 FUNCTION pol0753_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  INITIALIZE p_repres_885 TO NULL
  
  IF  pol0753_entrada_dados("INCLUSAO") THEN
      BEGIN WORK
      INSERT INTO repres_885 VALUES (p_repres_885.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","repres_885")       
      ELSE
          COMMIT WORK 
          MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol0753_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0753
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_repres_885.*,
               p_nom_rep,
               p_nom_ger  TO NULL
    DISPLAY BY NAME p_repres_885.*
    DISPLAY BY NAME p_nom_rep
    DISPLAY BY NAME p_nom_ger
  END IF
  INPUT   BY NAME p_repres_885.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_repres 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD pct_rep_ofi
      END IF

    AFTER FIELD cod_repres 
      IF p_repres_885.cod_repres  IS NOT NULL THEN
         LET p_cod_repres =  p_repres_885.cod_repres
         IF pol0753_verifica_representante() THEN
            ERROR "Representante nao cadastrado como representante" 
            NEXT FIELD cod_repres
         ELSE 
            LET p_nom_rep = p_representante.raz_social 
            DISPLAY BY NAME p_nom_rep
         END IF
         IF pol0753_verifica_duplicidade() THEN
         ELSE
            ERROR "Representante ja cadastrado" 
            NEXT FIELD cod_repres 
         END IF  
      ELSE ERROR "O campo cod_repres nao pode ser nulo."
           NEXT FIELD cod_repres
      END IF

    AFTER FIELD cod_gerente 
      IF p_repres_885.cod_gerente  IS NOT NULL THEN
         LET p_cod_repres =  p_repres_885.cod_gerente
         IF pol0753_verifica_representante() THEN
            ERROR "Gerente nao cadastrado como representante" 
            NEXT FIELD cod_gerente
         ELSE 
            LET p_nom_ger = p_representante.raz_social 
            DISPLAY BY NAME p_nom_ger
         END IF
         
         SELECT * 
           INTO p_ger_com_885.*
           FROM ger_com_885
          WHERE cod_gerente = p_repres_885.cod_gerente
         IF SQLCA.sqlcode <> 0 THEN 
            ERROR 'Gerente nao cadastrado para comissoes'
            NEXT FIELD cod_gerente 
         ELSE
            LET  p_repres_885.pct_ger_ofi = p_ger_com_885.pct_com_ofi
            LET  p_repres_885.pct_ger_ger = p_ger_com_885.pct_com_ger
         END IF    
      ELSE ERROR "O campo cod_repres nao pode ser nulo."
           NEXT FIELD cod_gerente
      END IF

    AFTER FIELD pct_rep_ofi
      IF p_repres_885.pct_rep_ofi IS NOT NULL THEN
      ELSE
         LET p_repres_885.pct_rep_ofi = 0   
      END IF 

    AFTER FIELD pct_rep_ger
      IF p_repres_885.pct_rep_ger IS NOT NULL THEN
      ELSE
         LET p_repres_885.pct_rep_ger = 0               
      END IF

    AFTER FIELD val_garantia   
      IF p_repres_885.val_garantia   IS NOT NULL THEN
      ELSE 
         LET p_repres_885.val_garantia = 0
      END IF 

    BEFORE FIELD dat_exp_gar
      IF p_funcao = "INCLUSAO" THEN
         LET p_repres_885.dat_exp_gar = '31/12/1899'
      END IF    
    
    AFTER FIELD dat_exp_gar 
      IF p_repres_885.dat_exp_gar IS NULL THEN
         ERROR "Data nao pode ser nula" 
         NEXT FIELD dat_exp_gar   
      END IF 

    AFTER FIELD tip_perc 
      IF p_repres_885.tip_perc IS NULL THEN
         ERROR "Campo de Preenchimento obrigatorio"
         NEXT FIELD tip_perc 
      ELSE
         IF p_repres_885.tip_perc <> 'I' AND 
            p_repres_885.tip_perc <> 'S' THEN 
            ERROR "Preenchimento invalido" 
            NEXT FIELD tip_perc 
         END IF    
      END IF 

    AFTER FIELD tip_comis
      IF p_repres_885.tip_comis IS NULL THEN
         ERROR "Campo de Preenchimento obrigatorio"
         NEXT FIELD tip_comis 
      ELSE
         IF p_repres_885.tip_comis <> 'R' AND 
            p_repres_885.tip_comis <> 'V' THEN 
            ERROR "Preenchimento invalido" 
            NEXT FIELD tip_comis
         END IF    
      END IF 

    AFTER FIELD ies_exp
      IF p_repres_885.ies_exp  IS NULL THEN
         ERROR "Campo deve ser S ou N" 
         NEXT FIELD ies_exp
      ELSE
         IF p_repres_885.ies_exp  <> 'S' AND 
            p_repres_885.ies_exp  <> 'N' THEN
            ERROR "Campo deve ser S ou N" 
            NEXT FIELD ies_exp
         END IF 
      END IF 

    AFTER FIELD pct_ger_ofi
      IF p_repres_885.pct_ger_ofi IS NOT NULL THEN
      ELSE
         LET p_repres_885.pct_ger_ofi = 0   
      END IF 

    AFTER FIELD pct_ger_ger
      IF p_repres_885.pct_ger_ger IS NOT NULL THEN
      ELSE
         LET p_repres_885.pct_ger_ger = 0               
      END IF

   ON KEY (control-z)
        CALL pol0753_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0753
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#--------------------------#
 FUNCTION pol0753_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON cod_repres,
                                   cod_gerente
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0753
 IF int_flag THEN
   LET int_flag = 0 
   LET p_repres_885.* = p_repres_885r.*
   CALL pol0753_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM repres_885 ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_repres "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD  FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_repres_885.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_cod_repres = p_repres_885.cod_repres
      IF pol0753_verifica_representante() THEN
         LET p_nom_rep = " NAO CADASTRADO"
      ELSE
         LET p_nom_rep = p_representante.raz_social    
      END IF

      LET p_cod_repres = p_repres_885.cod_gerente
      IF pol0753_verifica_representante() THEN
         LET p_nom_ger = " NAO CADASTRADO"
      ELSE
         LET p_nom_ger = p_representante.raz_social    
      END IF

      LET p_ies_cons = TRUE
   END IF
    CALL pol0753_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0753_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_repres_885.* 
  DISPLAY BY NAME p_nom_rep
  DISPLAY BY NAME p_nom_ger
END FUNCTION

#------------------------------------#
 FUNCTION pol0753_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_repres_885r.* = p_repres_885.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_repres_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_repres_885.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_repres_885.* = p_repres_885r.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_repres_885.* FROM repres_885    
        WHERE cod_repres  = p_repres_885.cod_repres
  
        IF sqlca.sqlcode = 0 THEN 
           LET p_cod_repres = p_repres_885.cod_repres
           IF pol0753_verifica_representante() THEN
              LET p_nom_rep = " NAO CADASTRADO"
           ELSE
              LET p_nom_rep = p_representante.raz_social    
           END IF
           
           LET p_cod_repres = p_repres_885.cod_gerente
           IF pol0753_verifica_representante() THEN
              LET p_nom_ger = " NAO CADASTRADO"
           ELSE
              LET p_nom_ger = p_representante.raz_social    
           END IF
           CALL pol0753_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0753_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_repres_885.*                                              
     FROM repres_885      
    WHERE cod_repres = p_repres_885.cod_repres
 FOR UPDATE 
   BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE sqlca.sqlcode
     
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","TABELA")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION


#----------------------------------#
 FUNCTION pol0753_modificacao()
#----------------------------------#
   IF pol0753_cursor_for_update() THEN
      LET p_repres_885r.* = p_repres_885.*
      IF pol0753_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE repres_885 SET  cod_gerente  = p_repres_885.cod_gerente,
                                pct_rep_ofi  = p_repres_885.pct_rep_ofi,
                                pct_rep_ger  = p_repres_885.pct_rep_ger,
                                val_garantia = p_repres_885.val_garantia,
                                dat_exp_gar  = p_repres_885.dat_exp_gar,
                                tip_perc     = p_repres_885.tip_perc,
                                tip_comis    = p_repres_885.tip_comis,
                                ies_exp      = p_repres_885.ies_exp,
                                pct_ger_ofi  = p_repres_885.pct_ger_ofi,
                                pct_ger_ger  = p_repres_885.pct_ger_ger
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_repres_885.* = p_repres_885r.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_repres_885.cod_repres
         LET p_cod_repres = p_repres_885.cod_repres
         IF pol0753_verifica_representante() THEN
            LET p_nom_rep = " NAO CADASTRADO"
         ELSE
            LET p_nom_rep = p_representante.raz_social    
         END IF
         
         LET p_cod_repres = p_repres_885.cod_gerente
         IF pol0753_verifica_representante() THEN
            LET p_nom_ger = " NAO CADASTRADO"
         ELSE
            LET p_nom_ger = p_representante.raz_social    
         END IF
         CALL pol0753_exibe_dados()            
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0753_exclusao()
#----------------------------------------#
   IF pol0753_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM repres_885    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_repres_885.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             ROLLBACK WORK
          END IF
          WHENEVER ERROR STOP
       ELSE
          ROLLBACK WORK
       END IF
       CLOSE cm_padrao
   END IF
 END FUNCTION  

#---------------------------------------#
 FUNCTION pol0753_verifica_representante()
#---------------------------------------#
DEFINE p_cont      SMALLINT

SELECT raz_social
  INTO p_representante.raz_social
  FROM representante               
 WHERE cod_repres  = p_cod_repres

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#--------------------------------------#
 FUNCTION pol0753_verifica_duplicidade()
#--------------------------------------#
DEFINE p_cont      SMALLINT

SELECT *  
  INTO p_repres_885.*
  FROM repres_885
 WHERE cod_repres = p_cod_repres

IF SQLCA.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0753_popup()
#-----------------------#
  DEFINE p_cod_gerente        LIKE representante.cod_repres,
         l_cod_repres         LIKE representante.cod_repres
  CASE
    WHEN infield(cod_repres)
         CALL log009_popup(6,25,"GERENTE","representante",
                          "cod_repres","raz_social",
                          "vdp0050","N","") RETURNING l_cod_repres
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0753 
         IF   l_cod_repres IS NOT NULL OR
              l_cod_repres <> " " 
         THEN
              LET p_repres_885.cod_repres  = l_cod_repres
              DISPLAY BY NAME p_repres_885.cod_repres
         END IF
         
    WHEN infield(cod_gerente)
         CALL log009_popup(6,25,"GERENTE","representante",
                          "cod_repres","raz_social",
                          "vdp0050","N","") RETURNING p_cod_gerente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0753 
         IF   p_cod_gerente IS NOT NULL OR
              p_cod_gerente <> " " 
         THEN
              LET p_repres_885.cod_gerente  = p_cod_gerente
              DISPLAY BY NAME p_repres_885.cod_gerente
         END IF
                  
  END CASE
END FUNCTION


#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1371                                                 #
# OBJETIVO: Cópia de registros entre empresas                       #
# AUTOR...: IVO                                                     #
# DATA....: 04/06/19                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           p_comando       CHAR(80)
END GLOBALS

DEFINE m_msg               CHAR(150),
       m_id                INTEGER, 
       m_tipo              INTEGER, 
       m_tabela            CHAR(40),
       m_campo             CHAR(30),
       m_emp_orig          CHAR(02),
       m_emp_dest          CHAR(02),
       m_qtd_reg           INTEGER,
       m_insert            CHAR(1500),
       m_nom_camp          CHAR(15)

MAIN

   CALL log0180_conecta_usuario()
   CALL log001_acessa_usuario("ESPEC999","") 
      RETURNING p_status, p_cod_empresa, p_user
    
   IF p_status = 0  THEN      
      CALL pol1371_controle()
   END IF
   
END MAIN       

#--------------------------#
FUNCTION pol1371_controle()#
#--------------------------#
   
   DEFINE l_nom_tela           CHAR(200)
   
   LET p_versao = 'pol1371-10.02.00  '   

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1371") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1371 AT 5,10 WITH FORM l_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Processar" "Processa a cópia de registros"
         ERROR 'Aguarde!... processando.'
         CALL pol1371_processar() RETURNING p_status
         IF p_status THEN
            LET m_msg = 'Operação efetuada com sucesso.'
         ELSE
            IF m_msg IS NULL OR m_msg = ' ' THEN
               LET m_msg = 'Operação cancelada.'
            END IF
         END IF
         CALL log0030_mensagem(m_msg,'info')
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1371

END FUNCTION

#---------------------------#
FUNCTION pol1371_processar()#
#---------------------------#

   LET m_emp_orig = '02'
   LET m_emp_dest = '12'
   
   DECLARE cq_syst CURSOR FOR
    SELECT a.id, a.name, b.tabname 
      FROM syscolumns a, systables b
     WHERE a.id = b.tabid 
       AND a.name  IN ('empresa','cod_empresa')
       AND b.tabname not in (SELECT tabela FROM nao_copiar_885)
    
   FOREACH cq_syst INTO m_id, m_campo, m_tabela
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_syst')
         RETURN FALSE
      END IF
      
      IF NOT pol1371_conta_reg() THEN
         RETURN FALSE
      END IF
      
      IF m_qtd_reg = 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1371_le_campos() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION
      
#---------------------------#
FUNCTION pol1371_conta_reg()#
#---------------------------#
   
   DEFINE l_query      CHAR(800)
   
   LET l_query = 
          "SELECT COUNT(*) FROM ",m_tabela,
          " WHERE ",m_campo, " = '",m_emp_orig,"' "
   
   PREPARE var_count FROM l_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","var_count")
      RETURN FALSE
   END IF
   
   DECLARE cq_count SCROLL CURSOR FOR var_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_count")
      RETURN FALSE
   END IF
    
   OPEN cq_count
    
   FETCH cq_count INTO m_qtd_reg

   IF STATUS = 100 THEN
      LET m_qtd_reg = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("FETCH","cq_count")
         RETURN FALSE
      END IF
   END IF
        
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1371_le_campos()#
#---------------------------#
   
   DEFINE l_ies_virgula    SMALLINT,
          l_delete         CHAR(100),
          l_campo          CHAR(30)
   
   #LET l_delete = "delete from ", m_tabela CLIPPED,
    #   " where ",m_campo CLIPPED, " = '",m_emp_dest,"' "

   #PREPARE var_del FROM l_delete
   #EXECUTE var_del

   #IF STATUS <> 0 THEN 
   #   CALL log003_err_sql("DELETE",m_tabela)
   #   RETURN FALSE
   #END IF
       
   LET l_ies_virgula = FALSE
   
   LET m_insert = 'INSERT INTO ',m_tabela CLIPPED,' SELECT '

   DECLARE cq_campo CURSOR FOR   
    SELECT name, colid
      FROM syscolumns 
     WHERE id = m_id
    order by colid
    
   FOREACH cq_campo INTO m_campo

      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_campo")
         RETURN FALSE
      END IF
      
      IF l_ies_virgula THEN
         LET m_insert = m_insert CLIPPED, ','
      END IF
      
      LET l_campo = DOWNSHIFT(m_campo)
      
      IF (l_campo = 'empresa') OR (l_campo = 'cod_empresa') THEN
         LET m_insert = m_insert CLIPPED," '",m_emp_dest,"' "
         LET m_nom_camp = m_campo
      ELSE
         LET m_insert = m_insert CLIPPED, ' ', m_campo
      END IF
      
      LET l_ies_virgula = TRUE
      
   END FOREACH
   
   LET m_insert = m_insert CLIPPED, ' FROM ',m_tabela CLIPPED,
          ' WHERE ',m_nom_camp CLIPPED," = '",m_emp_orig,"' "
   
   insert into tab_insere values(m_insert)
   
   PREPARE var_ins FROM m_insert
   EXECUTE var_ins
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("INSERT",m_tabela)
      RETURN FALSE
   END IF
   
   INSERT INTO nao_copiar_885 VALUES(m_tabela)
   
   RETURN TRUE

END FUNCTION
   
   

#---------------------------------------------------------------------#
# PROGRAMA: pol0658                                                   #
# OBJETIVO: REPLICA FOLHA                                             #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_registro      INTEGER,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_dat_ini           CHAR(10),
         p_mes_ini           CHAR(02),
         p_ano_ini           CHAR(04), 
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(18),
         p_ies_gr            CHAR(1),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_last_row          SMALLINT,
         p_ies_cons          SMALLINT,
         p_houve_erro        SMALLINT,
         p_msg               CHAR(100)


  DEFINE p_hist_movto         RECORD LIKE hist_movto.*,        
         p_hist_funcio        RECORD LIKE hist_funcio.*,        
         p_empresas_885      RECORD LIKE empresas_885.*,
         p_movto_ferias       RECORD LIKE movto_ferias.*,
         p_movto_demit        RECORD LIKE movto_demitidos.*,
         p_rhu_mov_prog_fer   RECORD LIKE rhu_mov_prog_fer.*,
         p_fun_bc_pensao_alim RECORD LIKE fun_bc_pensao_alim.*,
         p_movto_folha_cap    RECORD LIKE movto_folha_cap.*,
         p_movto_rescisao_cap RECORD LIKE movto_rescisao_cap.*,
         p_movto_ferias_cap   RECORD LIKE movto_ferias_cap.*,
         p_ultimo_proces      RECORD LIKE ultimo_proces.*,
         p_funcionario        RECORD LIKE funcionario.*,
         p_movto              RECORD LIKE movto.*
   
{  DEFINE p_movto              RECORD
					cod_empresa          char(2),
					num_matricula        decimal(8,0),
					cod_tip_proc         decimal(2,0),
					cod_evento           SMALLINT,
					qtd_horas            decimal(5,2),
					val_evento           decimal(13,2),
					num_parcela          decimal(3,0),
					dat_ini_desc         DATETIME YEAR TO DAY,
					dat_fim_desc         DATETIME YEAR TO DAY,
					nom_usuario_incl     char(8),
					dat_incl_evento      DATETIME YEAR TO SECOND,
					dat_alt_evento       DATETIME YEAR TO DAY,
					nom_usuario_alt      char(8),
					ies_excluido         char(1),
					ies_origem           char(1),
					num_lote             SMALLINT,
					forma_evento         char(1),
					tip_benef_evento     char(1),
					identif_benef        char(15),
					cod_funcao           char(8)
  END RECORD
 } 
  DEFINE p_tela  RECORD
                   cod_empresa    LIKE empresa.cod_empresa,
                   mes_ref        CHAR(2), 
                   ano_ref        CHAR(4)
                 END RECORD

 END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 60
  DEFER INTERRUPT
  LET p_versao = "POL0658-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0658.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      INITIALIZE p_tela.* TO NULL
      CALL pol0658_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0658_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0658") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0658 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"RHUMANOS","pol0658","CO") THEN
        IF pol0658_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia "         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"RHUMANOS","pol0658","CO") THEN
        IF p_tela.mes_ref IS NOT NULL THEN
           CALL pol0658_processa()
        ELSE
           ERROR "Informe dados para processamento"
           NEXT OPTION "Informar"
        END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
      CALL pol0658_sobre()
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
  CLOSE WINDOW w_pol0658
END FUNCTION

#----------------------------------------#
 FUNCTION pol0658_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_pol0658
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa

  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

     AFTER FIELD mes_ref     
        IF p_tela.mes_ref      IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD mes_ref  
        ELSE
           IF p_tela.mes_ref < '01' OR 
              p_tela.mes_ref > '12' THEN
              ERROR "Mes invalido" 
              NEXT FIELD mes_ref  
           ELSE      
              IF pol0658_checa_par() THEN
                 ERROR "Empresa para copia sem paramentros cadastrados" 
                 NEXT FIELD mes_ref  
              END IF
           END IF
        END IF

     AFTER FIELD ano_ref    
        IF p_tela.ano_ref     IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD ano_ref 
        END IF 

   END INPUT

  IF int_flag <> 0 THEN
     RETURN FALSE 
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0658_checa_par()
#----------------------------------------# 

 SELECT * 
   INTO p_empresas_885.*		
   FROM empresas_885 
  WHERE cod_emp_gerencial = p_cod_empresa

 IF sqlca.sqlcode <> 0 THEN 
    RETURN TRUE 
 ELSE 
    RETURN FALSE 
 END IF
    
END FUNCTION 

#----------------------------#
 FUNCTION pol0658_processa()
#----------------------------#
  DEFINE p_cont   SMALLINT,
         l_count  SMALLINT,
         l_cod_centro_custo LIKE unidade_funcional.cod_centro_custo

   CALL log085_transacao("BEGIN") 

   DECLARE cq_func CURSOR FOR 
     SELECT * 
       FROM funcionario 
      WHERE cod_empresa = p_cod_empresa 
   FOREACH cq_func INTO p_funcionario.*
   
      SELECT cod_centro_custo
        INTO l_cod_centro_custo
        FROM unidade_funcional
       WHERE cod_uni_funcio  = p_funcionario.cod_uni_funcio
       
       LET l_count = 0
       
       SELECT COUNT(*)
         INTO l_count
         FROM cc_n_trans
        WHERE cod_empresa_dest = p_empresas_885.cod_emp_oficial
          AND cod_cent_cust    = l_cod_centro_custo 
       IF l_count > 0 THEN 
          CONTINUE FOREACH 
       END IF    

       ERROR "Processando a copia de movimentos "ATTRIBUTE(REVERSE)
       LET p_cont = 0

       CALL pol0658_checa_funcionario()
     
       DELETE
         FROM movto                          
        WHERE cod_empresa        = p_empresas_885.cod_emp_oficial
          AND MONTH(dat_ini_desc) = p_tela.mes_ref
          AND YEAR(dat_ini_desc)  = p_tela.ano_ref
          AND num_matricula       =  p_funcionario.num_matricula
          IF SQLCA.SQLCODE <> 0   AND 
             SQLCA.SQLCODE <> 100 THEN 
	     LET p_houve_erro = TRUE
	     CALL log003_err_sql("DELECAO","movto")
	     EXIT FOREACH        
          END IF                                    
         
       DELETE
         FROM hist_movto                          
        WHERE cod_empresa            = p_empresas_885.cod_emp_oficial
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula         =  p_funcionario.num_matricula
          IF SQLCA.SQLCODE <> 0   AND 
             SQLCA.SQLCODE <> 100 THEN 
	     LET p_houve_erro = TRUE
	     CALL log003_err_sql("DELECAO","hist_movto")
	     EXIT FOREACH        
          END IF                                    

       DELETE
         FROM movto_folha_cap                          
        WHERE cod_empresa            = p_empresas_885.cod_emp_oficial
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula         =  p_funcionario.num_matricula
          IF SQLCA.SQLCODE <> 0   AND 
             SQLCA.SQLCODE <> 100 THEN 
	     LET p_houve_erro = TRUE
	     CALL log003_err_sql("DELECAO","movto_folha_cap")
	     EXIT FOREACH        
          END IF                                    
     
      DECLARE cq_hmov CURSOR FOR
        SELECT *
          FROM hist_movto                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula         =  p_funcionario.num_matricula
     
      FOREACH cq_hmov INTO p_hist_movto.*              
     
        DISPLAY "Fun:..."  at 8,15
        DISPLAY p_hist_movto.num_matricula at 8,26 
     
        LET p_hist_movto.cod_empresa = p_empresas_885.cod_emp_oficial
     
        INSERT INTO hist_movto VALUES (p_hist_movto.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","hist_movto")
	   EXIT FOREACH        
        END IF                                    
     
      END FOREACH
      
      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   
      DECLARE cq_mov CURSOR FOR
        SELECT *
          FROM movto                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_ini_desc)  = p_tela.ano_ref  
           AND MONTH(dat_ini_desc) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_mov INTO p_movto.*              
     
        display "Fun:..."  at 8,15
        display p_movto.num_matricula at 8,26 
     
        LET p_movto.cod_empresa = p_empresas_885.cod_emp_oficial
        LET p_movto.nom_usuario_incl = 'POL0658'
        
        INSERT INTO movto
                                       (movto.cod_empresa,
					movto.num_matricula,
					movto.cod_tip_proc,
					movto.cod_evento,
					movto.qtd_horas,
					movto.val_evento,
					movto.num_parcela,
					movto.dat_ini_desc,
					movto.dat_fim_desc,
					movto.nom_usuario_incl,
					movto.dat_incl_evento,
					movto.dat_alt_evento,
					movto.nom_usuario_alt,
					movto.ies_excluido,
					movto.ies_origem,
					movto.num_lote,
					movto.forma_evento,
					movto.tip_benef_evento,
					movto.identif_benef,
  			  	        movto.cod_funcao)
				VALUES
				       (p_movto.cod_empresa,
					p_movto.num_matricula,
					p_movto.cod_tip_proc,
					p_movto.cod_evento,
					p_movto.qtd_horas,
					p_movto.val_evento,
					p_movto.num_parcela,
					p_movto.dat_ini_desc,
					p_movto.dat_fim_desc,
					p_movto.nom_usuario_incl,
					p_movto.dat_incl_evento,
					p_movto.dat_alt_evento,
					p_movto.nom_usuario_alt,
					p_movto.ies_excluido,
					p_movto.ies_origem,
					p_movto.num_lote,
					p_movto.forma_evento,
					p_movto.tip_benef_evento,
					p_movto.identif_benef,
					p_movto.cod_funcao)
     
#        INSERT INTO movto VALUES (p_movto.*)
        IF SQLCA.SQLCODE <> 0  THEN 
      	   LET p_houve_erro = TRUE
      	   MESSAGE p_num_registro
	         CALL log003_err_sql("INCLUSAO","movto")
	         EXIT FOREACH        
        END IF                                    
     
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      
      ERROR "Processando a copia de hist_funcio "ATTRIBUTE(REVERSE)
     
      DELETE
        FROM hist_funcio                    
       WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
         AND YEAR(dat_referencia)  = p_tela.ano_ref  
         AND MONTH(dat_referencia) = p_tela.mes_ref
         AND num_matricula    =  p_funcionario.num_matricula

      IF SQLCA.SQLCODE <> 0   AND 
         SQLCA.SQLCODE <> 100 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("DELECAO","hist_funcio")
	 EXIT FOREACH        
      END IF                                    
       
      DECLARE cq_hfun CURSOR FOR
        SELECT *
          FROM hist_funcio                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_hfun INTO p_hist_funcio.*              
         
        LET p_hist_funcio.cod_empresa = p_empresas_885.cod_emp_oficial 
     
        INSERT INTO hist_funcio  VALUES (p_hist_funcio.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","hist_funcio")
	   EXIT FOREACH        
        END IF                                    
        
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      ERROR "Processando a copia integracao cap "ATTRIBUTE(REVERSE)

        DELETE 
          FROM movto_folha_cap                    
         WHERE cod_empresa           = p_empresas_885.cod_emp_oficial
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula         =  p_funcionario.num_matricula


      DECLARE cq_movc CURSOR FOR
        SELECT *
          FROM movto_folha_cap                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_movc INTO p_movto_folha_cap.*              
     
        display "Fun:..."  at 8,15
        display p_movto_folha_cap.num_matricula at 8,26 
     
        LET p_movto_folha_cap.cod_empresa = p_empresas_885.cod_emp_oficial
        LET p_movto_folha_cap.cod_funcao = 'POL0658'
        LET p_movto_folha_cap.nom_usuario = p_user
     
        INSERT INTO movto_folha_cap VALUES (p_movto_folha_cap.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","movto_folha_cap")
	   EXIT FOREACH        
        END IF                                    
     
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      ERROR "Processando a copia de pensao aliment "ATTRIBUTE(REVERSE)
     
      DELETE
        FROM fun_bc_pensao_alim                    
       WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
         AND YEAR(dat_atualizacao)  = p_tela.ano_ref  
         AND MONTH(dat_atualizacao) = p_tela.mes_ref
         AND num_matricula    =  p_funcionario.num_matricula

      IF SQLCA.SQLCODE <> 0   AND 
         SQLCA.SQLCODE <> 100 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("DELECAO","fun_bc_pensao_alim")
	 EXIT FOREACH        
      END IF                                    
       
      DECLARE cq_pal CURSOR FOR
        SELECT *
          FROM fun_bc_pensao_alim                     
         WHERE cod_empresa = p_cod_empresa
         AND YEAR(dat_atualizacao)  = p_tela.ano_ref  
         AND MONTH(dat_atualizacao) = p_tela.mes_ref
         AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_pal INTO p_fun_bc_pensao_alim.*              
         
        LET p_fun_bc_pensao_alim.cod_empresa = p_empresas_885.cod_emp_oficial 
     
        INSERT INTO fun_bc_pensao_alim  VALUES (p_fun_bc_pensao_alim.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","fun_bc_pensao_alim")
	   EXIT FOREACH        
        END IF                                    
        
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      ERROR "Processando a copia demitidos "ATTRIBUTE(REVERSE)
      LET p_cont = 0
     
      DELETE
        FROM movto_demitidos                    
       WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
         AND MONTH(dat_referencia) = p_tela.mes_ref  
         AND YEAR(dat_referencia)  = p_tela.ano_ref 
         AND num_matricula    =  p_funcionario.num_matricula

      IF SQLCA.SQLCODE <> 0   AND 
         SQLCA.SQLCODE <> 100 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("DELECAO","movto_demitidos")
	 EXIT FOREACH        
      END IF                                    
      
      DECLARE cq_demit CURSOR FOR
        SELECT *
          FROM movto_demitidos                    
         WHERE cod_empresa = p_cod_empresa
           AND MONTH(dat_referencia) = p_tela.mes_ref  
           AND YEAR(dat_referencia)  = p_tela.ano_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_demit INTO p_movto_demit.* 
     
        LET p_movto_demit.cod_empresa = p_empresas_885.cod_emp_oficial 
      
        INSERT INTO movto_demitidos  VALUES (p_movto_demit.*) 
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","movto_demitidos")
	   EXIT FOREACH        
        END IF                                    
        
      END FOREACH     

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      ERROR "Processando a copia integracao demitidos cap "ATTRIBUTE(REVERSE)

        DELETE
          FROM movto_rescisao_cap                    
         WHERE cod_empresa = p_empresas_885.cod_emp_oficial
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula

      DECLARE cq_movrc CURSOR FOR
        SELECT *
          FROM movto_rescisao_cap                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_movrc INTO p_movto_rescisao_cap.*              
     
        display "Fun:..."  at 8,15
        display p_movto_rescisao_cap.num_matricula at 8,26 
     
        LET p_movto_rescisao_cap.cod_empresa = p_empresas_885.cod_emp_oficial
        LET p_movto_rescisao_cap.cod_funcao = 'POL0658'
        LET p_movto_rescisao_cap.nom_usuario = p_user
     
        INSERT INTO movto_rescisao_cap VALUES (p_movto_rescisao_cap.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","movto_rescisao_cap")
	   EXIT FOREACH        
        END IF                                    
     
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   
      
      ERROR "Processando a copia ferias "ATTRIBUTE(REVERSE)
     
      DELETE
        FROM movto_ferias                    
       WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
         AND MONTH(dat_ini_progr) = p_tela.mes_ref  
         AND YEAR(dat_ini_progr)  = p_tela.ano_ref 
         AND num_matricula    =  p_funcionario.num_matricula
      IF SQLCA.SQLCODE <> 0   AND 
         SQLCA.SQLCODE <> 100 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("DELECAO","movto_ferias")
	 EXIT FOREACH        
      END IF                                    
     
      DECLARE cq_feria CURSOR FOR
        SELECT *
          FROM movto_ferias                    
         WHERE cod_empresa = p_cod_empresa
           AND MONTH(dat_ini_progr) = p_tela.mes_ref  
           AND YEAR(dat_ini_progr)  = p_tela.ano_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_feria INTO p_movto_ferias.*
     
        LET p_movto_ferias.cod_empresa = p_empresas_885.cod_emp_oficial 
         
        INSERT INTO movto_ferias  VALUES (p_movto_ferias.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","movto_ferias")
	   EXIT FOREACH        
        END IF                                    
      END FOREACH     

      DELETE
        FROM rhu_mov_prog_fer                          
       WHERE empresa           = p_empresas_885.cod_emp_gerencial
         AND matricula         = p_funcionario.num_matricula      
           AND MONTH(dat_ini_progr) = p_tela.mes_ref  
           AND YEAR(dat_ini_progr)  = p_tela.ano_ref 
         IF SQLCA.SQLCODE <> 0   AND 
            SQLCA.SQLCODE <> 100 THEN 
	    LET p_houve_erro = TRUE
	    CALL log003_err_sql("DELECAO","rhu_mov_prog_fer")
	    EXIT FOREACH        
         END IF                                    

      DECLARE cq_rmf CURSOR FOR
        SELECT *
          FROM rhu_mov_prog_fer
         WHERE empresa = p_cod_empresa
           AND matricula         = p_funcionario.num_matricula      
           AND MONTH(dat_ini_progr) = p_tela.mes_ref  
           AND YEAR(dat_ini_progr)  = p_tela.ano_ref 
      FOREACH cq_rmf INTO p_rhu_mov_prog_fer.*
      
         LET p_rhu_mov_prog_fer.empresa    = p_empresas_885.cod_emp_oficial 
          
         INSERT INTO rhu_mov_prog_fer  VALUES (p_rhu_mov_prog_fer.*)
         
         IF SQLCA.SQLCODE <> 0  THEN 
	    LET p_houve_erro = TRUE
	    CALL log003_err_sql("INCLUSAO","rhu_mov_prog_fer")
	    EXIT FOREACH        
         END IF                                    
      END FOREACH 

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

      ERROR "Processando a copia integracao ferias cap "ATTRIBUTE(REVERSE)
        DELETE
          FROM movto_ferias_cap                    
         WHERE cod_empresa = p_empresas_885.cod_emp_oficial
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula

      DECLARE cq_movfc CURSOR FOR
        SELECT *
          FROM movto_ferias_cap                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_referencia)  = p_tela.ano_ref  
           AND MONTH(dat_referencia) = p_tela.mes_ref 
           AND num_matricula    =  p_funcionario.num_matricula
     
      FOREACH cq_movfc INTO p_movto_ferias_cap.*              
     
        display "Fun:..."  at 8,15
        display p_movto_ferias_cap.num_matricula at 8,26 
     
        LET p_movto_ferias_cap.cod_empresa = p_empresas_885.cod_emp_oficial
        LET p_movto_ferias_cap.cod_funcao = 'POL0658'
        LET p_movto_ferias_cap.nom_usuario = p_user
     
        INSERT INTO movto_ferias_cap VALUES (p_movto_ferias_cap.*)
        IF SQLCA.SQLCODE <> 0  THEN 
	   LET p_houve_erro = TRUE
	   CALL log003_err_sql("INCLUSAO","movto_ferias_cap")
	   EXIT FOREACH        
        END IF                                    
     
      END FOREACH

      IF  p_houve_erro THEN
          EXIT FOREACH 
      END IF   

  END FOREACH 

  ERROR "Processando a copia ultimo_proces "ATTRIBUTE(REVERSE)

    DELETE
      FROM ultimo_proces
     WHERE cod_empresa = p_cod_empresa
       AND YEAR(dat_referencia)  = p_tela.ano_ref  
       AND MONTH(dat_referencia) = p_tela.mes_ref

  DECLARE cq_ultp CURSOR FOR
    SELECT *
      FROM ultimo_proces
     WHERE cod_empresa = p_cod_empresa
       AND YEAR(dat_referencia)  = p_tela.ano_ref  
       AND MONTH(dat_referencia) = p_tela.mes_ref
  
  FOREACH cq_ultp INTO p_ultimo_proces.*              

    LET p_ultimo_proces.cod_empresa = p_empresas_885.cod_emp_oficial
    LET p_ultimo_proces.nom_usuario = 'POL0658'
  
    INSERT INTO ultimo_proces VALUES (p_ultimo_proces.*)
    IF SQLCA.SQLCODE <> 0  THEN 
	LET p_houve_erro = TRUE
	CALL log003_err_sql("INCLUSAO","ultimo_proces")
	EXIT FOREACH        
    END IF                                    
  
  END FOREACH

  IF  p_houve_erro THEN
      CALL log085_transacao("ROLLBACK") 
      MESSAGE "Problemas ocorridos durante copia" ATTRIBUTE(REVERSE)
  ELSE
      CALL log085_transacao("COMMIT") 
      MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
  END IF   
END FUNCTION

#------------------------------------#
 FUNCTION pol0658_checa_funcionario()
#------------------------------------#
 DEFINE l_count  INTEGER,
        l_fun_sindicato      RECORD LIKE fun_sindicato.*,
        l_fun_adicional      RECORD LIKE fun_adicional.*,
        l_fun_cesta_basica   RECORD LIKE fun_cesta_basica.*,
        l_fun_conta_bancaria RECORD LIKE fun_conta_bancaria.*,
        l_fun_contrato       RECORD LIKE fun_contrato.*,
        l_fun_diversos       RECORD LIKE fun_diversos.*,
        l_fun_identidade     RECORD LIKE fun_identidade.*,
        l_fun_imposto_renda  RECORD LIKE fun_imposto_renda.*,
        l_fun_infor          RECORD LIKE fun_infor.*,
        l_fun_salario        RECORD LIKE fun_salario.*,
        l_funcionario_senha  RECORD LIKE funcionario_senha.*,
        l_fun_plano_saude    RECORD LIKE fun_plano_saude.*         
         
  SELECT COUNT(*)
    INTO l_count 
    FROM funcionario 
   WHERE cod_empresa    = p_empresas_885.cod_emp_oficial
     AND num_matricula  = p_funcionario.num_matricula 
  IF l_count = 0 THEN    
     LET p_funcionario.cod_empresa =  p_empresas_885.cod_emp_oficial
     INSERT INTO funcionario VALUES (p_funcionario.*)
  END IF 
     
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_diversos
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_diversos.*
       FROM fun_diversos
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_diversos.cod_empresa =  p_empresas_885.cod_emp_oficial  
        INSERT INTO fun_diversos VALUES (l_fun_diversos.*)
     END IF    
  END IF 
         
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_sindicato
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_sindicato.*
       FROM fun_sindicato
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_sindicato.cod_empresa =  p_empresas_885.cod_emp_oficial 
        INSERT INTO fun_sindicato VALUES (l_fun_sindicato.*)
     END IF    
  END IF 
   
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_adicional
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_adicional.*
       FROM fun_adicional
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_adicional.cod_empresa =  p_empresas_885.cod_emp_oficial  
        INSERT INTO fun_adicional VALUES (l_fun_adicional.*)
     END IF    
  END IF 
  
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_cesta_basica
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_cesta_basica.*
       FROM fun_cesta_basica
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_cesta_basica.cod_empresa =  p_empresas_885.cod_emp_oficial 
        INSERT INTO fun_cesta_basica VALUES (l_fun_cesta_basica.*)
     END IF    
  END IF 
  
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_conta_bancaria
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_conta_bancaria.*
       FROM fun_conta_bancaria
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_conta_bancaria.cod_empresa =  p_empresas_885.cod_emp_oficial 
        INSERT INTO fun_conta_bancaria VALUES (l_fun_conta_bancaria.*)
     END IF    
  END IF 

  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_contrato
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_contrato.*
       FROM fun_contrato
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_contrato.cod_empresa =  p_empresas_885.cod_emp_oficial
        INSERT INTO fun_contrato VALUES (l_fun_contrato.*)
     END IF    
  END IF 

  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_identidade
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_identidade.*
       FROM fun_identidade
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_identidade.cod_empresa =  p_empresas_885.cod_emp_oficial 
        INSERT INTO fun_identidade VALUES (l_fun_identidade.*)
     END IF    
  END IF 
  
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_imposto_renda
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_imposto_renda.*
       FROM fun_imposto_renda
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_imposto_renda.cod_empresa =  p_empresas_885.cod_emp_oficial  
        INSERT INTO fun_imposto_renda VALUES (l_fun_imposto_renda.*)
     END IF    
  END IF 
  
  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_infor
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_infor.*
       FROM fun_infor
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_infor.cod_empresa =  p_empresas_885.cod_emp_oficial
        INSERT INTO fun_infor VALUES (l_fun_infor.*)
     END IF    
  END IF 

  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_salario
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_fun_salario.*
       FROM fun_salario
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_fun_salario.cod_empresa =  p_empresas_885.cod_emp_oficial
        INSERT INTO fun_salario VALUES (l_fun_salario.*)
     END IF    
  END IF 

  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM funcionario_senha
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN    
     SELECT * 
       INTO l_funcionario_senha.*
       FROM funcionario_senha
      WHERE cod_empresa   = p_cod_empresa
        AND num_matricula = p_funcionario.num_matricula     
     IF sqlca.sqlcode = 0 THEN  
        LET l_funcionario_senha.cod_empresa =  p_empresas_885.cod_emp_oficial 
        INSERT INTO funcionario_senha VALUES (l_funcionario_senha.*)
     END IF    
  END IF 

  LET l_count = 0 
  SELECT COUNT(*) 
    INTO l_count 
    FROM fun_plano_saude
   WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
     AND num_matricula = p_funcionario.num_matricula     
  IF l_count = 0 THEN
     DECLARE cq_sau CURSOR FOR
        SELECT * 
          FROM fun_plano_saude
         WHERE cod_empresa   = p_cod_empresa
           AND num_matricula = p_funcionario.num_matricula     
        FOREACH cq_sau INTO l_fun_plano_saude.*
           LET l_fun_plano_saude.cod_empresa =  p_empresas_885.cod_emp_oficial 
           INSERT INTO fun_plano_saude VALUES (l_fun_plano_saude.*)
        END FOREACH     
  END IF 

END FUNCTION

#-----------------------#
 FUNCTION pol0658_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
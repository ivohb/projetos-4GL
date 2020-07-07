#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1242                                                 #
# OBJETIVO: EFETUAR A CONTAGEM DE FERRAMENTAS DA MANUT. INDUSTRIAL  #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 13/11/13                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          p_num_transac        INTEGER
         
END GLOBALS

DEFINE p_num_seq_operac     LIKE consumo.num_seq_operac,
       p_cod_operac         LIKE consumo.cod_operac,
       p_parametro          LIKE consumo.parametro,
       p_cod_ferramenta     LIKE consumo_fer.cod_ferramenta,
       p_tem_ferramenta     INTEGER,
       p_num_processo       CHAR(07),
       p_dat_ini_process    DATE,
       p_hor_ini_process    CHAR(08),
       p_dat_corte          DATE,
       p_erro               CHAR(10),
       p_id_nf_proces       INTEGER,
       p_id_registro        INTEGER,
       p_cod_item           CHAR(15),
       p_cod_compon         CHAR(15),
       p_qtd_necessaria     DECIMAL(14,7),
       p_qtd_item           DECIMAL(14,7),       
       p_ies_tip_item       CHAR(01)
       
       
DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE pr_erro              ARRAY[3000] OF RECORD  
       cod_empresa          CHAR(02),
       num_transac          INTEGER,
       den_erro             CHAR(500)
END RECORD

DEFINE p_item RECORD
       id_registro    INTEGER,
       cod_item       CHAR(15),
       qtd_item       DECIMAL(10,3),
       explodiu       CHAR(01)
END RECORD

DEFINE p_nf_proces    RECORD
  id_nf_proces        INTEGER,
  cod_empresa         CHAR(02),
  num_transac         INTEGER,
  seq_item_nf         INTEGER,
  cod_item            CHAR(15),
  qtd_item            DECIMAL(10,3),
  cod_nat_oper        INTEGER
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   LET p_versao = "pol1242-10.02.03"
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
   
   IF p_status = 0 THEN
      CALL pol1242_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1242_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   #CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   #CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   #CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'pol1242'   #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1242_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1242_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1242") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1242 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_dat_ini_process = TODAY
   LET p_hor_ini_process = TIME
   LET p_ind = 0
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1242_processa() THEN
      CALL log085_transacao("ROLLBACK")
      LET pr_men[1].mensagem = 'PROCESSAMENTO COM ERRO. CONSULTE TABELA ERRO_CONTAGEM_1099'
   ELSE
      CALL log085_transacao("COMMIT")
      LET pr_men[1].mensagem = 'PROCESSAMENTO EFETUADO C/ SUCESSO'
   END IF

   CALL pol1242_exib_mensagem()

   CALL pol1242_grava_erro()
     
END FUNCTION

#------------------------------#
FUNCTION pol1242_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#-----------------------------#
FUNCTION pol1242_guarda_erro()#
#-----------------------------#

   LET p_ind = p_ind + 1
   LET pr_erro[p_ind].cod_empresa = p_cod_empresa
   LET pr_erro[p_ind].num_transac = p_num_transac
   LET pr_erro[p_ind].den_erro = p_msg
   LET p_houve_erro = TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1242_grava_erro()#
#----------------------------#

   FOR p_index = 1 to p_ind
     
     IF pr_erro[p_index].cod_empresa IS NOT NULL THEN
        INSERT INTO erro_contagem_1099
         VALUES(pr_erro[p_index].cod_empresa,
                pr_erro[p_index].num_transac,
                pr_erro[p_index].den_erro,
                p_dat_ini_process,
                p_hor_ini_process)

        IF STATUS <> 0 THEN
           EXIT FOR
        END IF
     END IF
     
   END FOR
   
END FUNCTION

#---------------------------#
FUNCTION pol1242_cria_temp()#
#---------------------------#

   DROP TABLE item_temp_1099

   CREATE  TABLE item_temp_1099(
       id_registro    INTEGER,
       cod_item       CHAR(15),
       qtd_item       DECIMAL(10,3),
       explodiu       CHAR(01)
    );
         
   IF STATUS <> 0 THEN 
      LET p_erro = STATUS
      DELETE FROM item_temp_1099
   END IF

   SELECT COUNT(*)
     INTO p_count
     FROM item_temp_1099
   
   IF p_count > 0 THEN
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' CRIANDO A TABELA ITEM_TEMP_1099'
      LET p_num_transac = 0
      CALL pol1242_guarda_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1242_ins_item()#
#--------------------------#
   
   LET p_item.id_registro = p_item.id_registro + 1
   
   INSERT INTO item_temp_1099
     VALUES(p_item.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA ITEM_TEMP_1099'
      CALL pol1242_guarda_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1242_ins_nf_proces()#
#-------------------------------#
   
   LET p_id_nf_proces = p_id_nf_proces + 1
   LET p_nf_proces.id_nf_proces = p_id_nf_proces
   
   INSERT INTO nf_proces_1099(
      id_nf_proces,
      cod_empresa,
      num_transac,
      seq_item_nf,
      cod_nat_oper)  
   VALUES(p_nf_proces.id_nf_proces,
          p_nf_proces.cod_empresa,
          p_nf_proces.num_transac,
          p_nf_proces.seq_item_nf,
          p_nf_proces.cod_nat_oper)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA ITEM_TEMP_1099'
      CALL pol1242_guarda_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1242_processa()#
#--------------------------#

   IF NOT pol1242_cria_temp() THEN
      RETURN FALSE
   END IF

   SELECT MAX(id_nf_proces)
     INTO p_id_nf_proces
     FROM nf_proces_1099

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO ULTIMO REGISTRO DA TABELA NF_PROCES_1099'
      LET p_num_transac = 0
      CALL pol1242_guarda_erro()
      RETURN FALSE
   END IF
   
   IF p_id_nf_proces IS NULL THEN
      LET p_id_nf_proces = 0
   END IF
   
   DECLARE cq_emps CURSOR FOR
    SELECT cod_empresa,
           dat_corte
      FROM empresa_manut_ind_1099
   
   FOREACH cq_emps INTO p_cod_empresa, p_dat_corte                 
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_EMPS'
         LET p_num_transac = 0
         CALL pol1242_guarda_erro()
         RETURN FALSE
      END IF
      
      SELECT MAX(num_transac)
        INTO p_num_transac
        FROM nf_proces_1099
       WHERE cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO ULTIMA NOTA PROCESSADA NA TABELA NF_PROCES_1099'
         LET p_num_transac = 0
         CALL pol1242_guarda_erro()
         RETURN FALSE
      END IF
      
      IF p_num_transac IS NULL THEN
         LET p_num_transac = 0
      END IF
#
### MANUEL EM 10-01-2014 - ALTEREI O PROGRAMA PARA PEGAR APENAS NOTAS FATURADAS POIS PODERIA OCORRER DE CONTAR AS NOTAS DE UM SEMIELABORADO 
### QUANDO MANDASSE PARA BENEFICIAMENTO E DEPOIS NOVAMENTE NA EXPLOSAO DE UM ITEM FATURADO, ASSIM VAI CONTAR UMA UNICA VEZ. 
#      
      DECLARE cq_itens CURSOR FOR
       SELECT fat_nf_item.empresa,
              fat_nf_item.trans_nota_fiscal,
              fat_nf_item.seq_item_nf,
              fat_nf_item.item,
              fat_nf_item.qtd_item,
              fat_nf_item.natureza_operacao
         FROM fat_nf_item, 
              fat_nf_mestre,
              nat_operacao,
              estoque_operac
        WHERE fat_nf_mestre.empresa = p_cod_empresa
          AND fat_nf_mestre.trans_nota_fiscal > p_num_transac
          AND DATE(fat_nf_mestre.dat_hor_emissao) >= p_dat_corte
          AND fat_nf_mestre.status_nota_fiscal = 'F'
          AND fat_nf_item.empresa = fat_nf_mestre.empresa
          AND fat_nf_item.trans_nota_fiscal = fat_nf_mestre.trans_nota_fiscal
          AND nat_operacao.cod_nat_oper = fat_nf_item.natureza_operacao
          AND estoque_operac.cod_empresa = fat_nf_mestre.empresa
          AND estoque_operac.cod_operacao = nat_operacao.cod_movto_estoq
          AND estoque_operac.ies_com_quantidade = 'S'
		  AND nat_operacao.ies_emite_dupl='S'
      
      FOREACH cq_itens INTO 
              p_nf_proces.cod_empresa,
              p_nf_proces.num_transac,
              p_nf_proces.seq_item_nf,
              p_nf_proces.cod_item,
              p_nf_proces.qtd_item,
              p_nf_proces.cod_nat_oper

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_ITENS'
            LET p_num_transac = 0
            CALL pol1242_guarda_erro()
            RETURN FALSE
         END IF

         IF NOT pol1242_ins_nf_proces() THEN
            RETURN FALSE
         END IF
         
         DELETE FROM item_temp_1099
         
         LET p_num_transac = p_nf_proces.num_transac
         
         LET p_item.id_registro = 0
         LET p_item.cod_item = p_nf_proces.cod_item
         LET p_item.qtd_item = p_nf_proces.qtd_item
         LET p_item.explodiu = 'N'
         
         IF NOT pol1242_ins_item() THEN
            RETURN FALSE
         END IF

         IF NOT pol1242_explode_estrutura() THEN
            RETURN FALSE
         END IF

         IF NOT pol1242_add_contagem() THEN
            RETURN FALSE
         END IF
      
      END FOREACH         

   END FOREACH

END FUNCTION
   
#-----------------------------------#         
FUNCTION pol1242_explode_estrutura()#
#-----------------------------------#

   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM item_temp_1099
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       LET p_erro = STATUS
       LET p_msg = 'ERRO ', p_erro CLIPPED, ' CONTANDO ITENS NA TABELA ITEM_TEMP_1099'
       CALL pol1242_guarda_erro()
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_explode CURSOR FOR
     SELECT id_registro,
            cod_item,
            qtd_item
       FROM item_temp_1099
      WHERE explodiu = 'N'
    
    FOREACH cq_explode INTO p_id_registro, p_cod_item, p_qtd_item
    
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_EXPLODE'
         CALL pol1242_guarda_erro()
         RETURN FALSE
      END IF
       
       UPDATE item_temp_1099
          SET explodiu = 'S'
        WHERE id_registro = p_id_registro

       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO TABELA ITEM_TEMP_1099'
          CALL pol1242_guarda_erro()
          RETURN FALSE
       END IF
       
       DECLARE cq_estrut CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_item
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
             
       FOREACH cq_estrut INTO p_cod_compon, p_qtd_necessaria

          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_ESTRUT'
             CALL pol1242_guarda_erro()
             RETURN FALSE
          END IF
          
          IF NOT pol1242_le_tip_item() THEN
             RETURN FALSE
          END IF
          
          IF p_ies_tip_item = 'P' THEN
          ELSE
             CONTINUE FOREACH
          END IF
          
          LET p_item.cod_item = p_cod_compon
          LET p_item.qtd_item = p_qtd_item * p_qtd_necessaria
          LET p_item.explodiu = 'N'

          IF NOT pol1242_ins_item() THEN
             RETURN FALSE
          END IF
         
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1242_le_tip_item()
#-----------------------------#
          
   SELECT ies_tip_item 
     INTO p_ies_tip_item
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_compon
             
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TIPO DO ITEM ', p_cod_compon
      CALL pol1242_guarda_erro()
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

   #- ler item_temp
   #- ler consumo
   #- ler consumo_fer 
   #- atualizar qtd_acum_ativ_osp, se existir

#------------------------------#
FUNCTION pol1242_add_contagem()#
#------------------------------#

   DEFINE p_posi_ini, p_posi_fim INTEGER
   
   DECLARE cq_cont CURSOR FOR
    SELECT cod_item, qtd_item
      FROM item_temp_1099
   
   FOREACH cq_cont INTO p_cod_item, p_qtd_item
   
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_CONT'
          CALL pol1242_guarda_erro()
          RETURN FALSE
       END IF
       
       DECLARE cq_consumo CURSOR FOR
        SELECT num_seq_operac, cod_operac, parametro
          FROM consumo
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_cod_item
       
       FOREACH cq_consumo INTO p_num_seq_operac, p_cod_operac, p_parametro

          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_CONSUMO'
             CALL pol1242_guarda_erro()
             RETURN FALSE
          END IF
          
          LET p_posi_ini = LENGTH(p_parametro) - 6
          LET p_posi_fim = LENGTH(p_parametro)
          LET p_num_processo = p_parametro[p_posi_ini, p_posi_fim]
    
#--Daqui Alterado por Manuel em 29-11-2013 criei cursor para ler o ferramental pois uma operacao pode ter divesas ferran
        DECLARE cq_ferr CURSOR FOR	
          SELECT cod_ferramenta
            FROM consumo_fer 
           WHERE cod_empresa = p_cod_empresa
             AND num_processo = p_num_processo

			 
		FOREACH cq_ferr INTO   p_cod_ferramenta
		
	      IF STATUS <> 0 THEN
			LET p_erro = STATUS
			LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_FERR'
			CALL pol1242_guarda_erro()
			RETURN FALSE
	      END IF		 
			 
          IF p_cod_ferramenta[1,1] <> 'F' THEN
             CONTINUE FOREACH
          END IF
          
		  LET p_tem_ferramenta = 0 
		  
          SELECT COUNT(*) 
            INTO p_tem_ferramenta
            FROM qtd_acum_ativ_osp 
           WHERE empresa = p_cod_empresa
             AND cod_equip = p_cod_ferramenta
			 AND tip_apont = 'Q'


          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA QTD_ACUM_ATIV_OSP'
             CALL pol1242_guarda_erro()
             RETURN FALSE
          END IF
          
          
		  IF p_tem_ferramenta =  0 THEN
             CONTINUE FOREACH
          END IF
		  
          UPDATE qtd_acum_ativ_osp 
             SET qtd_apont_acum = qtd_apont_acum + p_qtd_item
           WHERE empresa = p_cod_empresa
             AND cod_equip = p_cod_ferramenta
			 AND tip_apont = 'Q'

          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO TABELA QTD_ACUM_ATIV_OSP'
             CALL pol1242_guarda_erro()
             RETURN FALSE
          END IF

		END FOREACH

#--Ate aqui Alterado por Manuel em 29-11-2013 

		
          INSERT INTO nf_item_proces_1099
           VALUES(p_id_nf_proces, p_cod_item,
                  p_qtd_item, p_cod_operac,
                  p_num_seq_operac, p_cod_ferramenta)
                  
          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO NA TABELA NF_ITEM_PROCES_1099'
             CALL pol1242_guarda_erro()
             RETURN FALSE
          END IF
            
      END FOREACH
   
   END FOREACH
      
   RETURN TRUE

END FUNCTION

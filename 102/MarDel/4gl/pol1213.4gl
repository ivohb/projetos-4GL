#-------------------------------------------------------------------#
# PROGRAMA: pol1213                                                 #
# OBJETIVO: EXPORTA��O DE ENTRADAS, SA�DAS E SALDOS - FIAT          #
# AUTOR...: ACEEX                                                   #
# DATA....: 16/07/2013                                              #
# ALTERA��O: 29/04/15 - IVO - ADAPTA��O PARA RODAR PELO AGENDADOR   #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
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
          p_erro               CHAR(120),
          p_cod_erro           CHAR(10)

END GLOBALS
   
DEFINE p_cod_fornecedor    CHAR(15),
       p_num_nf            INTEGER,
       p_ser_nf            CHAR(03),
       p_ssr_nf            INTEGER,
       p_especie           CHAR(03),
       p_dat_emissao       DATE,
       p_dat_entrada       DATE,
       p_num_cnpj          CHAR(20),
       p_num_ar            INTEGER,
       p_cfop              CHAR(05),
       p_cnpj              CHAR(15),
       p_cod_item          CHAR(15),
       p_item_cli          CHAR(30),
       p_quantidade        CHAR(13),
       p_cod_mardel        CHAR(09),
       p_cod_min           CHAR(09),
       p_dat_exportar      DATE,
       p_dat_proces        DATE,
       p_tip_saldo         CHAR(01),
       p_hor_proces        CHAR(08),
       p_dat_arq           CHAR(08),
       p_hor_arq           CHAR(06),
       p_qtd_reg           CHAR(09),
       p_ident             CHAR(03),
       p_cod_cliente       CHAR(15),
       p_num_transac       INTEGER,
       p_tip_item          CHAR(01),
       p_qtd_saldo         DECIMAL(10,3),
       p_item_cliente      CHAR(11),
       p_qtd_erro          INTEGER
       

DEFINE p_nota              RECORD
       cod_empresa         CHAR(02),
       ar_transac          INTEGER,
       ies_nota            CHAR(01),
       fornecedor          CHAR(09),
       desenho             CHAR(11),
       desenho_fab         CHAR(01),
       dat_Movto           CHAR(08),
       hor_movto           CHAR(09),
       num_nf              CHAR(12),
       ser_nf              CHAR(03),
       ssr_nf              CHAR(02),
       dat_emis_nf         CHAR(08),
       quantidade          CHAR(13),
       tip_movto           CHAR(03),
       acao                CHAR(01),
       cnpj                CHAR(14),
       cfop                CHAR(04),
       tip_nf              CHAR(02)
END RECORD

DEFINE p_saldo             RECORD
       fornecedor          CHAR(09),
       desenho             CHAR(11),
       desenho_fab         CHAR(01),
       dat_saldo           CHAR(08),
       saldo               CHAR(18),
       explodir            CHAR(01)
END RECORD

DEFINE ma_erro             ARRAY[500] OF RECORD
       erro                CHAR(120)
END RECORD

DEFINE m_cfops             LIKE min_par_modulo.parametro_texto

MAIN
   LET p_versao = "pol1213-10.02.30  "

   #CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   LET p_cod_empresa = '02' 
   LET p_user = 'admlog'  
   LET p_status = 0
      
   IF p_status = 0 THEN
      CALL pol1213_controle() 
   END IF
   
END MAIN

#------------------------------#
FUNCTION pol1213_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user   
   }

   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '02'
   END IF
   
   IF l_param2_user IS NULL THEN
      LET l_param2_user = 'pol1213'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   CALL pol1213_controle() 
   
   IF p_qtd_erro > 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION   

#---------------------------#
 FUNCTION pol1213_controle()#
#---------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1213") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1213 AT 5,10 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
 
    WHENEVER ANY ERROR CONTINUE
    SET ISOLATION TO DIRTY READ
    SET LOCK MODE TO WAIT 600
    
    CALL func002_versao_prg(p_versao)
    
    DELETE FROM nota_diverg_5054
    
    LET p_qtd_erro = 0
    INITIALIZE ma_erro TO NULL
    
    IF NOT pol1213_cria_temp() THEN
       CALL pol1213_grava_erro() 
       CLOSE WINDOW w_pol1213
       RETURN
    END IF
    
    IF NOT pol1213_le_parametros() THEN
       CALL pol1213_grava_erro()
       CLOSE WINDOW w_pol1213
       RETURN
    END IF

    CALL pol1213_processar()
    
    CLOSE WINDOW w_pol1213

END FUNCTION

 #-----------------------------#
 FUNCTION pol1213_guarda_erro()#
 #-----------------------------#
    LET p_qtd_erro = p_qtd_erro + 1
    LET ma_erro[p_qtd_erro].erro = p_erro

END FUNCTION    

#----------------------------#
FUNCTION pol1213_grava_erro()#
#----------------------------#
   
   DEFINE l_dat_hor    CHAR(20)
   
   LET l_dat_hor = CURRENT
   
   FOR p_ind = 1 TO p_qtd_erro
       IF ma_erro[p_ind].erro IS NOT NULL THEN
          INSERT INTO nota_diverg_5054
           VALUES(l_dat_hor, ma_erro[p_ind].erro)
       END IF
   END FOR

END FUNCTION
    
#---------------------------#
FUNCTION pol1213_cria_temp()#
#---------------------------#

   DROP TABLE nota_temp_5054
   CREATE TEMP TABLE nota_temp_5054 (
       cod_empresa         CHAR(02),
       ar_transac          INTEGER,
       ies_nota            CHAR(01),
       fornecedor          CHAR(09),
       desenho             CHAR(11),
       desenho_fab         CHAR(01),
       dat_Movto           CHAR(08),
       hor_movto           CHAR(09),
       num_nf              CHAR(12),
       ser_nf              CHAR(03),
       ssr_nf              CHAR(02),
       dat_emis_nf         CHAR(08),
       quantidade          CHAR(13),
       tip_movto           CHAR(03),
       acao                CHAR(01),
       cnpj                CHAR(14),
       cfop                CHAR(04),
       tip_nf              CHAR(02)
   );
   
	 IF STATUS <> 0 THEN 
	    LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' CRIANDO TABELA NOTA_TEMP_5054'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
	 END IF

   DROP TABLE mat_temp_5054
   CREATE TEMP TABLE mat_temp_5054 (
       fornecedor          CHAR(09),
       desenho             CHAR(11),
       desenho_fab         CHAR(01),
       dat_saldo           CHAR(08),
       saldo               CHAR(18),
       explodir            CHAR(01)
   );
   
	 IF STATUS <> 0 THEN 
	    LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' CRIANDO TABELA MAT_TEMP_5054'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
	 END IF

   {DROP TABLE cfop_tmp_5054
   CREATE TEMP  TABLE cfop_tmp_5054 (
       cod_operacao        CHAR(06)
   );
   
	 IF STATUS <> 0 THEN 
	    LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' CRIANDO TABELA CFOP_TMP_5054'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
	 END IF}
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1213_tira_formato(p_campo)#
#-------------------------------------#
   
   DEFINE p_campo    CHAR(20),
          p_retorno  CHAR(20),
          p_dig      CHAR(01)
   
   LET p_retorno = ''
   
   FOR p_ind = 1 TO LENGTH(p_campo)
       LET p_dig = p_campo[p_ind]
       IF p_dig MATCHES'[.,/-]' THEN
       ELSE
          LET p_retorno = p_retorno CLIPPED, p_dig
       END IF
   END FOR
   
   RETURN p_retorno

END FUNCTION
   
#-------------------------------#
FUNCTION pol1213_le_parametros()#
#-------------------------------#
     
   SELECT parametro_texto
     INTO p_cod_mardel
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'COD_MARDEL_NA_FIAT'
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' LENDO COD_MARDEL_NA_FIAT NA TABELA MIN_PAR_MODULO'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
   END IF
   
   IF p_cod_mardel IS NULL THEN
			LET p_erro = 'O COD_MARDEL_NA_FIAT ESTA NULO NA TABELA MIN_PAR_MODULO'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
	 END IF

   SELECT parametro_texto
     INTO p_tip_saldo
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'SALDO_A_EXPORTAR'
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' LENDO SALDO_A_EXPORTAR NA TABELA MIN_PAR_MODULO'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
   END IF
   
   IF p_tip_saldo = 'F' THEN
   ELSE
      LET p_tip_saldo = 'C'
   END IF
      
   SELECT parametro_dat
     INTO p_dat_exportar
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'DATA_INICIO_EXPORTAR'
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
			LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			     ' LENDO DATA_INICIO_EXPORTAR NA TABELA MIN_PAR_MODULO'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
   END IF

   IF p_dat_exportar IS NULL THEN
			LET p_erro = 'A DATA_INICIO_EXPORTAR ESTA NULA NA TABELA MIN_PAR_MODULO'
			CALL pol1213_guarda_erro() 
			RETURN FALSE
	 END IF
  
   LET p_cod_min = p_cod_mardel
   LET p_cod_mardel = p_cod_mardel USING '&&&&&&&&&'

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1213_processar()#
#---------------------------#
   
    LET p_qtd_erro = 0
    INITIALIZE ma_erro TO NULL

    CALL log085_transacao("BEGIN")
    
    CALL pol1213_exp_entrada()
    
    IF p_qtd_erro > 0 THEN
       CALL log085_transacao("ROLLBACK")
       CALL pol1213_grava_erro() 
    ELSE
       CALL log085_transacao("COMMIT")
    END IF

    LET p_cod_erro = 0
    INITIALIZE ma_erro TO NULL
   
    CALL log085_transacao("BEGIN")
    
    CALL pol1213_exp_saida()
    
    IF p_qtd_erro > 0 THEN
       CALL log085_transacao("ROLLBACK")
       CALL pol1213_grava_erro() 
    ELSE
       CALL log085_transacao("COMMIT")
    END IF

    LET p_cod_erro = 0
    INITIALIZE ma_erro TO NULL
   
    CALL pol1213_exp_material()
    
    IF p_qtd_erro > 0 THEN
       CALL pol1213_grava_erro() 
    END IF
      
END FUNCTION

#-----------------------------#
FUNCTION pol1213_exp_entrada()#
#-----------------------------#
   
   DEFINE p_txt CHAR(50)
   
   SELECT cod_empresa FROM item WHERE 1=2
      
   DECLARE cq_nfe CURSOR FOR
    SELECT n.num_nf,
           n.ser_nf,
           n.ssr_nf,
           n.ies_especie_nf,
           n.dat_emis_nf,
           n.dat_entrada_nf,
           n.num_aviso_rec,
           n.cod_fornecedor,
           n.cod_operacao,
           a.cod_item,
           sum(a.qtd_recebida)
      FROM nf_sup n, aviso_rec a, fornec_nf_5054 f, item_cliente_5054 i
     WHERE n.cod_empresa = p_cod_empresa
       AND n.dat_entrada_nf >= p_dat_exportar
       AND n.cod_fornecedor = f.cod_fornecedor
       AND a.cod_empresa = n.cod_empresa
       AND a.num_aviso_rec = n.num_aviso_rec
       AND a.cod_item = i.cod_item
       AND i.cod_empresa = a.cod_empresa
       AND n.num_aviso_rec NOT IN 
           (SELECT e.ar_transac 
              FROM nota_exportada_5054 e
             WHERE e.cod_empresa = p_cod_empresa)
       GROUP BY 
           n.num_nf,
           n.ser_nf,
           n.ssr_nf,
           n.ies_especie_nf,
           n.dat_emis_nf,
           n.dat_entrada_nf,
           n.num_aviso_rec,
           n.cod_fornecedor,
           n.cod_operacao,
           a.cod_item
                     
   FOREACH cq_nfe INTO
           p_num_nf,
           p_ser_nf,
           p_ssr_nf,
           p_especie,
           p_dat_emissao,
           p_dat_entrada,
           p_num_ar,
           p_cod_fornecedor,
           p_cfop,
           p_cod_item,
           p_quantidade

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			      ' LENDO NOTAS DE ENTRADA NA TABELA NF_SUP'
			   CALL pol1213_guarda_erro() 
			   RETURN
      END IF
            
      DISPLAY p_num_nf TO entrada
      #lds CALL LOG_refresh_display()

      LET p_nota.cod_empresa = p_cod_empresa
      LET p_nota.ar_transac = p_num_ar
      LET p_nota.ies_nota = 'E'
      LET p_nota.fornecedor = p_cod_mardel 
      LET p_nota.num_nf = p_num_nf USING '&&&&&&&&&&&&'
      LET p_nota.ser_nf = p_ser_nf USING '&&&'
      LET p_nota.ssr_nf = p_ssr_nf USING '&&'
      LET p_nota.desenho_fab = 'E'
      LET p_nota.dat_Movto = p_dat_entrada USING 'yyyymmdd'
      LET p_nota.hor_movto = '000000000' 
      LET p_nota.dat_emis_nf = p_dat_emissao USING 'yyyymmdd'
      LET p_nota.tip_movto = 'REC'
      LET p_nota.acao = 'I'
      LET p_nota.cfop = pol1213_tira_formato(p_cfop)
      LET p_nota.cfop = p_nota.cfop USING '&&&&'
      LET p_nota.quantidade = pol1213_tira_formato(p_quantidade) 
      LET p_nota.quantidade = p_nota.quantidade USING '&&&&&&&&&&&&&'

      SELECT num_cgc_cpf
        INTO p_num_cnpj
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS = 100 THEN
         LET p_erro = 'O FORNECEDOR ', p_cod_fornecedor CLIPPED, 
			      ' NAO ESTA CADASTRADO NA TABELA FORNECEDOR'
			   CALL pol1213_guarda_erro() 
			   CONTINUE FOREACH
      ELSE      
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
		   	      ' LENDO CNPJ DO DORNECEDOR NA TABELA FORNECEDOR'
			      CALL pol1213_guarda_erro() 
			      RETURN
         END IF
      END IF
         
      LET p_cnpj = pol1213_tira_formato(p_num_cnpj)
      LET p_nota.cnpj = p_cnpj[2,15]
                                             
      SELECT tipo_fiat
        INTO p_nota.tip_nf
        FROM tipo_nf_5054
       WHERE tipo_logix = p_especie
         AND entrada_saida = 'E'

      IF STATUS = 100 THEN
         LET p_cod_erro = p_num_nf
         LET p_erro = 'NOTA DE ENTRADA ', p_cod_erro CLIPPED, 
                      ' ESPECIE ', p_especie, 
                      ' NAO CADASTRADA NO POL1214'
			   CALL pol1213_guarda_erro() 
			   CONTINUE FOREACH
      ELSE      
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
		   	      ' LENDO TIPO_FIAT_FIAT NA TABELA TIPO_NF_5054'
			      CALL pol1213_guarda_erro() 
			      RETURN
         END IF
      END IF
         
      IF NOT pol1213_desenho() THEN
         RETURN
      END IF

      IF p_item_cliente IS NULL THEN
         LET p_erro = 'NF DE ENTRADA - NAO FOI POSSIVEL LOCALIZAR O DESENHO DO ITEM ', 
                p_cod_item CLIPPED, ' NA TABELA CLIENTE_ITEM'
			   CALL pol1213_guarda_erro() 
			   CONTINUE FOREACH
      END IF
         
      LET p_nota.desenho = p_item_cliente
         
      INSERT INTO nota_temp_5054
       VALUES(p_nota.*)
        
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'NF DE ENTRADA - ERRO DE STATUS ', p_cod_erro CLIPPED,
  	        ' INSERINDO NOTA DE ENTRADA NA TABELA NOTA_TEMP_5054'
 	       CALL pol1213_guarda_erro() 
			   RETURN
      END IF
      
   END FOREACH   

   IF p_qtd_erro = 0 THEN
      CALL pol1213_imp_nota('ENT.TXT')
   END IF   
   
END FUNCTION

#-------------------------#
FUNCTION pol1213_desenho()#
#-------------------------#

   DEFINE p_it_cli CHAR(11)
   
   LET p_item_cliente = NULL
         
   DECLARE cq_desenho CURSOR FOR
    SELECT cod_item_cliente
      FROM cliente_item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_cod_item
             
   FOREACH cq_desenho INTO p_it_cli             

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
             'LENDO DESENHO DO ITEM NA TABELA CLIENTE_ITEM'
			   CALL pol1213_guarda_erro() 
         RETURN FALSE
      END IF
            
      LET p_item_cliente = pol1213_zero(p_it_cli,11)
   
      EXIT FOREACH
            
   END FOREACH  
   
   RETURN TRUE

END FUNCTION
   

#----------------------------------------#
FUNCTION pol1213_zero(p_campo, p_tamanho)#
#----------------------------------------#

   DEFINE p_retorno CHAR(80),
          p_campo   CHAR(80),
          p_tamanho INTEGER,
          p_qtd_zero INTEGER
   
   LET p_retorno = ''
   LET p_qtd_zero  = p_tamanho - LENGTH(p_campo)
   
   FOR p_ind = 1 TO p_qtd_zero
       LET p_retorno = p_retorno CLIPPED, '0'
   END FOR
   
   LET p_retorno = p_retorno CLIPPED, p_campo CLIPPED
   
   RETURN p_retorno

END FUNCTION

#---------------------------#
FUNCTION pol1213_exp_saida()#
#---------------------------#
   
   DEFINE p_hor_emisso CHAR(08),
          p_dat_hor DATETIME YEAR TO SECOND
   
   DELETE FROM nota_temp_5054
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			      ' DELETANDO REGISTROS DA TABELA NOTA_TEMP_5054'
			CALL pol1213_guarda_erro() 
      RETURN
   END IF
   
   DECLARE cq_nfs CURSOR FOR
    SELECT m.nota_fiscal, 
           m.serie_nota_fiscal, 
           m.subserie_nf, 
           m.espc_nota_fiscal,
           m.trans_nota_fiscal,
           m.cliente,
           f.item,
           sum(f.qtd_item)
      FROM fat_nf_mestre m, fat_nf_item f, 
           cliente_nf_5054 c, item_cliente_5054 i,
           nat_operacao n
     WHERE m.empresa = p_cod_empresa
       AND DATE(m.dat_hor_emissao) >= p_dat_exportar
       AND m.cliente = c.cod_cliente
       AND m.natureza_operacao = n.cod_nat_oper
       AND n.ies_estatistica IN ('T')
       AND f.empresa = m.empresa
       AND f.trans_nota_fiscal = m.trans_nota_fiscal
       AND f.item = i.cod_item
       AND f.empresa = i.cod_empresa
       AND m.trans_nota_fiscal NOT IN 
           (SELECT e.ar_transac 
              FROM nota_exportada_5054 e
             WHERE e.cod_empresa = p_cod_empresa)
       GROUP BY
           m.nota_fiscal, 
           m.serie_nota_fiscal, 
           m.subserie_nf, 
           m.espc_nota_fiscal,
           m.trans_nota_fiscal,
           m.cliente,
           f.item

   FOREACH cq_nfs INTO
           p_num_nf,
           p_ser_nf,
           p_ssr_nf,
           p_especie,
           p_num_transac,
           p_cod_cliente,
           p_cod_item,
           p_quantidade

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			         ' LENDO NOTAS DE SAIDA DA TABELA FAT_NF_MESTRE'
			   CALL pol1213_guarda_erro() 
         RETURN
      END IF

      SELECT DATE(dat_hor_emissao), 
             dat_hor_emissao
        INTO p_dat_emissao,
             p_dat_hor
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal = p_num_transac 

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			         ' LENDO DATA DE EMISSAO DA TABELA FAT_NF_MESTRE'
			   CALL pol1213_guarda_erro() 
         RETURN
      END IF

      DISPLAY p_num_nf TO saida
      #lds CALL LOG_refresh_display()	

      LET p_nota.cod_empresa = p_cod_empresa
      LET p_nota.ar_transac = p_num_transac
      LET p_nota.ies_nota = 'S'
      LET p_nota.fornecedor = p_cod_mardel 
      LET p_nota.num_nf = p_num_nf USING '&&&&&&&&&&&&'
      LET p_nota.ser_nf = p_ser_nf USING '&&&'
      LET p_nota.ssr_nf = p_ssr_nf USING '&&'
      LET p_nota.desenho_fab = 'E'
      LET p_nota.dat_Movto = p_dat_emissao USING 'yyyymmdd'
      LET p_hor_emisso = EXTEND(p_dat_hor, HOUR TO SECOND)
      LET p_nota.hor_movto = p_hor_emisso[1,2], 
             p_hor_emisso[4,5], p_hor_emisso[7,8], '000'
      LET p_nota.dat_emis_nf = p_dat_emissao USING 'yyyymmdd'
      LET p_nota.tip_movto = 'ENV'
      LET p_nota.acao = 'I'
      
      LET p_count = LENGTH(p_quantidade) #BANCO DA MARDEL EST� RETORNANDO QUANTIDADE C/ 6 CASAS DECIMAIS
      
      IF p_count > 3 THEN
         LET p_quantidade = p_quantidade[1,p_count-3] 
      END IF
      
      LET p_nota.quantidade = pol1213_tira_formato(p_quantidade) 
      LET p_nota.quantidade = p_nota.quantidade USING '&&&&&&&&&&&&&'


      SELECT num_cgc
        INTO p_num_cnpj
        FROM empresa
       WHERE cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			         ' LENDO CNPJ DA EMPRESA DA TABELA EMPRESA'
			   CALL pol1213_guarda_erro() 
         RETURN
      END IF
         
      LET p_cnpj = pol1213_tira_formato(p_num_cnpj)
      LET p_nota.cnpj = p_cnpj[2,15]
         
      SELECT tipo_fiat
        INTO p_nota.tip_nf
        FROM tipo_nf_5054
       WHERE tipo_logix = p_especie
         AND entrada_saida = 'S'

      IF STATUS = 100 THEN
         LET p_cod_erro = p_num_nf
         LET p_erro = 'NOTA DE SAIDA ', p_cod_erro CLIPPED,
			         ' ESPECIE ', p_especie CLIPPED, 
			         ' NAO CADASTRADA NA TABELA TIPO_NF_5054'
         CALL pol1213_guarda_erro()
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			            ' LENDO TIPO DE NOTA FIAT DA TABELA TIPO_NF_5054'
			      CALL pol1213_guarda_erro() 
            RETURN
         END IF
      END IF
      
      INITIALIZE p_cfop TO NULL
      
      DECLARE cq_pri_cfop CURSOR FOR           
      SELECT DISTINCT
             cod_fiscal
        FROM fat_nf_item_fisc
       WHERE empresa = p_cod_empresa 
         AND trans_nota_fiscal = p_num_transac

      FOREACH cq_pri_cfop INTO p_cfop

         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			            ' LENDO CFOP DA TABELA FAT_NF_ITEM_FISC'
			      CALL pol1213_guarda_erro() 
            RETURN
         END IF
         
         EXIT FOREACH
      
      END FOREACH
      
      IF p_cfop IS NULL THEN
         LET p_cfop = '0.000'
      END IF
         
      LET p_nota.cfop = pol1213_tira_formato(p_cfop)
      LET p_nota.cfop = p_nota.cfop USING '&&&&'

      IF NOT pol1213_desenho() THEN
         RETURN
      END IF

      IF p_item_cliente IS NULL THEN
         LET p_erro = 'NF DE SAIDA - NAO FOI POSSIVEL LOCALIZAR O DESENHO DO ITEM ', 
                p_cod_item CLIPPED, ' NA TABELA CLIENTE_ITEM'
			   CALL pol1213_guarda_erro() 
			   CONTINUE FOREACH
      END IF
         
      LET p_nota.desenho = p_item_cliente
                  
      INSERT INTO nota_temp_5054
       VALUES(p_nota.*)
       
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'NF DE SAIDA - ERRO DE STATUS ', p_cod_erro CLIPPED,
  	        ' INSERINDO NOTA DE ENTRADA NA TABELA NOTA_TEMP_5054'
 	       CALL pol1213_guarda_erro() 
			   RETURN
      END IF
      
   END FOREACH

   IF p_qtd_erro = 0 THEN
      CALL pol1213_imp_nota('SAI.TXT')
   END IF
               
END FUNCTION

#-------------------------------#
FUNCTION pol1213_imp_nota(p_ext)#
#-------------------------------#

   DEFINE p_ext      CHAR(07),
          l_imp      SMALLINT,
          l_cont     INTEGER
   
   LET l_imp = FALSE
   
   SELECT COUNT(fornecedor)
     INTO p_count 
     FROM nota_temp_5054
   
   LET p_count = p_count + 1
   LET l_cont = 0
   
   #CALL log150_procura_caminho("TXT") RETURNING p_caminho
   
   SELECT nom_caminho INTO p_caminho 
   FROM path_logix_v2 WHERE cod_empresa = p_cod_empresa
    AND cod_sistema = 'TXT'
    AND ies_ambiente = 'W'

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
		    ' LENDO CAMINHO DOS ARQUIVOS TEXTOS DA TAB PATH_LOGIX_V2'
		  CALL pol1213_guarda_erro() 
		  RETURN
   END IF
   
   LET p_dat_proces = TODAY 
   LET p_hor_proces = TIME
   LET p_dat_arq = p_dat_proces USING 'yyyymmdd'
   LET p_hor_arq = p_hor_proces[1,2],p_hor_proces[4,5],p_hor_proces[7,8]
   LET p_qtd_reg = p_count USING '&&&&&&&&&'
   LET p_ident = 'TOP'
   
   LET p_nom_arquivo = p_caminho CLIPPED,
       'NOTAS_CT_',p_cod_min CLIPPED,'_',p_dat_arq,p_hor_arq,'_',p_ext
      
   START REPORT pol1213_relat_nf TO p_nom_arquivo
      
   DECLARE cq_nf_temp CURSOR FOR
    SELECT * FROM nota_temp_5054
   
   FOREACH cq_nf_temp INTO p_nota.*

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			      ' LENDO DADOS DA TABELA NOTA_TEMP_5054'
			   CALL pol1213_guarda_erro() 
			   RETURN
      END IF
      
      SELECT cod_empresa
        FROM nota_exportada_5054
       WHERE cod_empresa = p_cod_empresa
         AND ar_transac = p_nota.ar_transac
         AND ies_nota = p_nota.ies_nota
      
      IF STATUS = 100 THEN
         INSERT INTO nota_exportada_5054
          VALUES(p_cod_empresa, p_nota.ar_transac, p_nota.ies_nota)
         
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			         ' INSERINDO DADOS NA TABELA NOTA_EXPORTADA_5054'
			      CALL pol1213_guarda_erro() 
			      RETURN
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
			         ' LENDO DADOS DA TABELA NOTA_EXPORTADA_5054'
			      CALL pol1213_guarda_erro() 
			      RETURN
         END IF
      END IF                
            
      OUTPUT TO REPORT pol1213_relat_nf()
      
      LET l_imp = TRUE
      LET l_cont = l_cont + 1
      
   END FOREACH
   
   IF NOT l_imp THEN
      INITIALIZE p_nota.* TO NULL
      OUTPUT TO REPORT pol1213_relat_nf()
   END IF
      
   FINISH REPORT pol1213_relat_nf
   
END FUNCTION

#------------------------#
REPORT pol1213_relat_nf()#
#------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
   FORMAT
   
      FIRST PAGE HEADER  
         PRINT p_ident, p_cod_mardel, p_dat_arq, p_hor_arq, p_qtd_reg
      
      ON EVERY ROW
         PRINT 
          p_nota.fornecedor, 
          p_nota.desenho,    
          p_nota.desenho_fab,
          p_nota.dat_Movto,  
          p_nota.hor_movto,  
          p_nota.num_nf,     
          p_nota.ser_nf,     
          p_nota.ssr_nf,     
          p_nota.dat_emis_nf,
          p_nota.quantidade, 
          p_nota.tip_movto,  
          p_nota.acao,       
          p_nota.cnpj,       
          p_nota.cfop,       
          p_nota.tip_nf     

END REPORT         

#------------------------------#
FUNCTION pol1213_exp_material()#
#------------------------------#
   
   DEFINE sql_stmt CHAR(800)
   
   DELETE FROM mat_temp_5054
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
                   ' DELETANDO DADOS DA TABELA MAT_TEMP_5054'
      CALL pol1213_guarda_erro() 
			RETURN
   END IF   
      
   IF p_tip_saldo = 'C' THEN                                                                
      LET sql_stmt =                                                                            
          "SELECT cod_item, tip_item FROM item_cliente_5054 ",                                  
          " WHERE tip_item IN ('C','B') ",                                                      
          "   AND cod_empresa = '",p_cod_empresa,"' ",                                          
          " ORDER BY cod_item, tip_item "                                                       
   ELSE                                                                                         
      LET sql_stmt =                                                                            
          "SELECT cod_item, tip_item FROM item_cliente_5054 ",                                  
          "  WHERE cod_empresa = '",p_cod_empresa,"' ",                                         
          " ORDER BY cod_item, tip_item "                                                       
   END IF                                                                                       
                                                                                             
   PREPARE var_query FROM sql_stmt                                                              
   DECLARE cq_item CURSOR FOR var_query                                                         
                                                                                                
   FOREACH cq_item INTO p_cod_item, p_tip_item                                                  
                                                                                                
      IF STATUS <> 0 THEN                                                                       
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
                      ' LENDO DADOS DA TABELA ITEM_CLIENTE_5054'
         CALL pol1213_guarda_erro() 
			   RETURN
      END IF                                                                                    
                                                                                                
      DISPLAY p_cod_item TO item                                                                
      #lds CALL LOG_refresh_display()                                                           
                                                                                                
      SELECT (qtd_liberada + qtd_impedida + qtd_lib_excep)                                      
        INTO p_qtd_saldo                                                                        
        FROM estoque                                                                            
       WHERE cod_item = p_cod_item                                                              
         AND cod_empresa = p_cod_empresa                                                        
                                                                                             
      IF STATUS = 100 THEN                                                                      
         LET p_qtd_saldo = 0                                                                    
      ELSE                                                                                      
         IF STATUS <> 0 THEN                                                                    
            LET p_cod_erro = STATUS
            LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
                         ' LENDO DADOS DA TABELA ESTOQUE'
            CALL pol1213_guarda_erro() 
			      RETURN
         END IF                                                                                 
      END IF                                                                                    
                                                                                                
      LET p_saldo.fornecedor = p_cod_mardel                                                     
      LET p_saldo.desenho_fab = 'E'                                                             
      LET p_saldo.dat_saldo = TODAY USING 'yyyymmdd'                                            
      LET p_saldo.saldo = pol1213_tira_formato(p_qtd_saldo)                                     
      LET p_saldo.saldo = p_saldo.saldo USING '&&&&&&&&&&&&&&&&&&'                              
                                                                                                
      IF p_tip_item MATCHES '[PF]' THEN                                                         
         LET p_saldo.explodir = 'S'                                                             
      ELSE                                                                                      
         LET p_saldo.explodir = 'N'                                                             
      END IF                                                                                    
                                                                                             
      IF NOT pol1213_desenho() THEN                                                             
         RETURN                                                                        
      END IF                                                                                    

      IF p_item_cliente IS NULL THEN
         LET p_erro = 'EXPORTANDO SALDO - NAO FOI POSSIVEL LOCALIZAR O DESENHO DO ITEM ', 
                p_cod_item CLIPPED, ' NA TABELA CLIENTE_ITEM'
			   CALL pol1213_guarda_erro() 
			   CONTINUE FOREACH
      END IF
                                                                                                
      LET p_saldo.desenho = p_item_cliente                                                      
                                                                                                
      INSERT INTO mat_temp_5054                                                                 
       VALUES(p_saldo.*)                                                                        
                                                                                                
      IF STATUS <> 0 THEN                                                                       
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
                      ' INSERINDO DADOS NA TABELA MAT_TEMP_5054'
         CALL pol1213_guarda_erro() 
			   RETURN
      END IF                                                                                    
                                                                                                
   END FOREACH                                                                                  
   
   IF p_qtd_erro = 0 THEN
      CALL pol1213_imp_saldo()
   END IF
                                                                                                
END FUNCTION

#---------------------------#
FUNCTION pol1213_imp_saldo()#
#---------------------------#
   
   DEFINE l_imp      SMALLINT
   
   LET l_imp = FALSE
   
   SELECT COUNT(desenho)                                                                        
     INTO p_count                                                                               
     FROM mat_temp_5054                                                                         
 
   LET p_count = p_count + 2
   
   #CALL log150_procura_caminho("TXT") RETURNING p_caminho
   
   SELECT nom_caminho INTO p_caminho 
   FROM path_logix_v2 WHERE cod_empresa = p_cod_empresa
    AND cod_sistema = 'TXT'
    AND ies_ambiente = 'W'

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
		    ' LENDO CAMINHO DOS ARQUIVOS TEXTOS DA TAB PATH_LOGIX_V2'
		  CALL pol1213_guarda_erro() 
		  RETURN
   END IF
   
   LET p_dat_proces = TODAY 
   LET p_hor_proces = TIME
   LET p_dat_arq = p_dat_proces USING 'yyyymmdd'
   LET p_hor_arq = p_hor_proces[1,2],p_hor_proces[4,5],p_hor_proces[7,8]
   LET p_qtd_reg = p_count USING '&&&&&&&&&'
   LET p_ident = 'TOP'
   
   LET p_nom_arquivo = p_caminho CLIPPED,
       'SALDO_CT_',p_cod_min CLIPPED,'_',p_dat_arq,p_hor_arq,'.TXT'
   
   START REPORT pol1213_relat_sd TO p_nom_arquivo
      
   DECLARE cq_sd_temp CURSOR FOR
    SELECT * FROM mat_temp_5054
   
   FOREACH cq_sd_temp INTO p_saldo.*

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_erro = 'ERRO DE STATUS ', p_cod_erro CLIPPED,
                      ' LENDO DADOS NA TABELA MAT_TEMP_5054'
         CALL pol1213_guarda_erro() 
			   RETURN
      END IF
   
      OUTPUT TO REPORT pol1213_relat_sd()
      
      LET l_imp = TRUE
      
   END FOREACH
   
   IF NOT l_imp THEN
      INITIALIZE p_saldo.* TO NULL
      OUTPUT TO REPORT pol1213_relat_sd()
   END IF
   
   FINISH REPORT pol1213_relat_sd
   
END FUNCTION

#------------------------#
REPORT pol1213_relat_sd()#
#------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
   FORMAT
   
      FIRST PAGE HEADER  
         PRINT p_ident, p_cod_mardel, p_dat_arq, p_hor_arq, p_qtd_reg, p_tip_saldo
      
      ON EVERY ROW
         PRINT 
          p_saldo.fornecedor, 
          p_saldo.desenho,    
          p_saldo.desenho_fab,
          p_saldo.dat_saldo,  
          p_saldo.saldo,  
          p_saldo.explodir     

      ON LAST ROW
         PRINT "FOO", p_qtd_reg
         
END REPORT         
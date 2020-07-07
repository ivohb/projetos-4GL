{
1)      Notas do dia 01/08 a 10/08 – ajustar o peso das notas (bruto e liquido);
2)      Notas do dia 01/08 até hoje – ajustar os pesos da roma_item_885, 
          das ordens de montagem e das notas fiscais para os casos onde o TRIM 
          gravou o pesoliquido e pesocarregado incorreto;
3)      Ajustar a base do DW.


CREATE TABLE pol1309_erro_885 (
  cod_empresa     CHAR(02),
  num_romaneio    INTEGER,
  den_erro        CHAR(80),
  dat_proces      DATETIME
);

CREATE INDEX pol1309_erro_885 ON
 pol1309_erro_885(cod_empresa, num_romaneio);


CREATE TABLE solic_fatura_885 (
 cod_empresa    CHAR(02),
 num_solicit    INTEGER,
 num_om         INTEGER,
 num_pedido     INTEGER,
 seq_item       INTEGER,
 peso_liq       DECIMAL(10,2),
 peso_bruto     DECIMAL(10,2),
 num_nf         INTEGER
);

CREATE INDEX solic_fatura_885 ON
 solic_fatura_885(cod_empresa, num_solicit);


CREATE TABLE nf_ajust_885 (
 cod_empresa    CHAR(02),
 num_solicit    INTEGER,
 num_nf         INTEGER,
 dat_ajuste     DATETIME,
 peso_liq_ant   DECIMAL(10,2),
 peso_liq_atu   DECIMAL(10,2),
 peso_bru_ant   DECIMAL(10,2),
 peso_bru_atu   DECIMAL(10,2),
 ies_justific   CHAR(01)
);


CREATE UNIQUE INDEX nf_ajust_885 ON
 nf_ajust_885(cod_empresa, num_solicit, num_nf);

CREATE INDEX nf_ajust_885_2 ON
 nf_ajust_885(cod_empresa, num_solicit);
  
}
  




DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_msg                CHAR(150)

END GLOBALS

DEFINE p_tela              RECORD
       dat_ini             DATE,
       dat_fim             DATE,
       num_solicit         INTEGER
END RECORD

DEFINE p_ies_cons          SMALLINT,
       p_dat_ini           CHAR(10),
       p_dat_fim           CHAR(10),
       p_num_solicit       INTEGER,
       p_num_sequencia     INTEGER,
       p_pesoliqcarregado  DECIMAL(10,3),
       p_pesocarregado     DECIMAL(10,3),
       p_criticou          SMALLINT,
       p_den_erro          CHAR(80),
       p_seq_item          INTEGER,
       p_num_om            INTEGER,
       p_num_pedido        INTEGER,
       p_num_trasac        INTEGER,
       p_num_nf            INTEGER,
       p_cod_item          CHAR(15),
       p_qtd_pecas         DECIMAL(10,3),
       p_peso_liq          DECIMAL(10,2),
       p_peso_bruto        DECIMAL(10,2),
       p_qtd_reservada     DECIMAL(10,3),
       p_pes_om_item       DECIMAL(10,2),
       p_peso_unit         DECIMAL(10,2),
       p_tol_peso          DECIMAL(10,2),
       p_ajustou_nf        SMALLINT,
       p_dat_atu           CHAR(10)
       
DEFINE p_relat             RECORD
 cod_empresa    CHAR(02),
 num_solicit    INTEGER,
 num_nf         INTEGER,
 dat_ajuste     DATE,
 peso_liq_ant   DECIMAL(10,2),
 peso_liq_atu   DECIMAL(10,2),
 peso_bru_ant   DECIMAL(10,2),
 peso_bru_atu   DECIMAL(10,2),
 ies_justific   CHAR(01)
END RECORD
       
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1309-12.00.07  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") 
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1309_controle()
   END IF
   
END MAIN

#---------------------------#
 FUNCTION pol1309_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1309") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1309 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1309_limpa_tela()
        
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros p/ o processamento"
         CALL pol1309_informar('C') RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Parâmetros informados com sucesso.'
            NEXT OPTION "Processar"
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1309_limpa_tela()
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Processar" "Processa o ajuste do peso"
         IF p_ies_cons THEN
            IF pol1309_processar() THEN
               ERROR 'Operação efetuada com sucesso.'
            ELSE
               CALL pol1309_limpa_tela()
               ERROR 'Operação cancelada.'
            END IF
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'informe os parâmetros previamente.'
         END IF
         MESSAGE ''
      COMMAND "Listar" "Listagem das notas alteradas"
         IF pol1309_listagem() THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND "Erros" "Exibe romaneios criticados."
         CALL pol1309_exibe_erros()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa."
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1309

END FUNCTION

#----------------------------#
 FUNCTION pol1309_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#------------------------------#
FUNCTION pol1309_informar(l_op)#
#------------------------------#
   
   DEFINE l_op      CHAR(01)
   
   CALL pol1309_limpa_tela()
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   
   LET p_tela.dat_ini = '01/08/2016'   
   LET p_tela.dat_fim = TODAY
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
      
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Preencha a data inicial'
            NEXT FIELD dat_ini
         END IF

         IF p_tela.dat_fim IS NULL THEN
            ERROR 'Preencha a data final'
            NEXT FIELD dat_fim
         END IF
         
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR 'Periodo inválido.'
            NEXT FIELD dat_ini
         END IF
  
   END INPUT
   
   LET p_dat_ini = EXTEND(p_tela.dat_ini, YEAR TO DAY)
   LET p_dat_fim = EXTEND(p_tela.dat_fim, YEAR TO DAY)
   
   IF p_tela.num_solicit IS NULL THEN
      LET p_tela.num_solicit = 0
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1309_processar()#
#---------------------------#
   
   DEFINE l_query   CHAR(800)

   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF
   
   LET p_dat_atu = TODAY
   
   SELECT parametro_numerico
     INTO p_tol_peso
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'TOLERANCIA_DIF_PESO'

   IF STATUS = 100 THEN           
      LET p_tol_peso = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF

   IF p_tol_peso IS NULL THEN           
      LET p_tol_peso = 0
   END IF

     #AND TO_CHAR(datageracao, 'YYYY-MM-DD') >= p_dat_ini
     #AND TO_CHAR(datageracao, 'YYYY-MM-DD') <= p_dat_fim

   LET l_query =
       "SELECT DISTINCT numromaneio, MAX(numsequencia) FROM romaneio_885 ",
       " WHERE codempresa = '",p_cod_empresa,"' ",
         " AND statusregistro = '1' ",
         " AND EXTEND(datageracao, YEAR  TO DAY) >= '",p_tela.dat_ini,"' ",
         " AND EXTEND(datageracao, YEAR  TO DAY) <= '",p_tela.dat_fim,"' ",
         " AND numromaneio IN (SELECT numromaneio FROM romaneio_erro_885) ",
         " AND numromaneio NOT IN ",
             " (SELECT num_solicit FROM solic_fatura_885 WHERE cod_empresa = '",p_cod_empresa,"') "
   
   IF p_tela.num_solicit > 0 THEN  
      LET l_query = l_query CLIPPED,  " AND numromaneio = '",p_tela.num_solicit,"' "
   END IF
   
   LET l_query = l_query CLIPPED, " GROUP BY numromaneio ORDER BY numromaneio "

   PREPARE var_query FROM l_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE', 'var_query')
      RETURN FALSE
   END IF
      
   DECLARE cq_roma CURSOR WITH HOLD FOR var_query
       
   FOREACH cq_roma INTO p_num_solicit, p_num_sequencia
      
      IF STATUS <> 0 THEN           
         CALL log003_err_sql('FOREACH','cq_roma')
         RETURN FALSE
      END IF
      
      MESSAGE 'Romaneio: ', p_num_solicit USING '<<<<<<<<<<<<'
        #lds CALL LOG_refresh_display()
 
      IF NOT pol1309_del_tabs() THEN
         RETURN FALSE
      END IF
      
      LET p_criticou = FALSE
      
      IF NOT pol1309_rateia_peso() THEN
         RETURN FALSE
      END IF     
      
      IF p_criticou THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol1309_recalc_peso() THEN
         RETURN FALSE
      END IF     

      IF p_criticou THEN
         DELETE FROM solic_fatura_885
          WHERE cod_empresa = p_cod_empresa
            AND num_solicit = p_num_solicit
         CONTINUE FOREACH
      END IF
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1309_ajusta_nf() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF     
      
      #IF p_ajustou_nf THEN
         IF NOT pol1309_ajusta_om() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF     
      #END IF
      
      CALL log085_transacao("COMMIT")
      
   END FOREACH
       
   RETURN TRUE
           
END FUNCTION

#-----------------------------#
FUNCTION pol1309_rateia_peso()
#-----------------------------#
   
   DEFINE p_coefic_liq     DECIMAL(17,9),
          p_coefic_bru     DECIMAL(17,9),
          l_peso_liq       DECIMAL(10,3),
          l_peso_bru       DECIMAL(10,3),
          l_dif_liq        DECIMAL(10,3),
          l_dif_bru        DECIMAL(10,3),
          l_numsequencia   INTEGER

    SELECT pesobalanca
     INTO  l_peso_bru
     FROM romaneio_885
    WHERE codempresa = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF

   IF l_peso_bru <= 0 THEN
      LET p_den_erro = 'O TRIM NÃO ENVIOU O PESO BALANÇA NA ROMANEIO_885'
      IF NOT pol1309_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT SUM(pesocarregado)
     INTO p_pesocarregado
     FROM roma_item_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885:sum')
      RETURN FALSE
   END IF
   
   IF p_pesocarregado IS NULL THEN
      LET p_pesocarregado = 0
   END IF
   
   IF p_pesocarregado <= 0 THEN
      LET p_den_erro = 'O TRIM NÃO ENVIOU O PESO CARREGADO NA ROMA_ITEM_885'
      IF NOT pol1309_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_criticou THEN
      RETURN TRUE
   END IF
   
   LET p_coefic_bru = l_peso_bru / p_pesocarregado

   UPDATE roma_item_885
      SET pesobrutoitem = pesocarregado * p_coefic_bru
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','roma_item_885:peso_bruto')
      RETURN FALSE
   END IF

   SELECT SUM(pesobrutoitem)
     INTO p_pesocarregado
     FROM roma_item_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885:sum_pesoitem')
      RETURN FALSE
   END IF
   
   LET l_dif_bru = l_peso_bru - p_pesocarregado
   
   IF l_dif_bru <> 0 THEN
      DECLARE cq_ajusta CURSOR FOR
       SELECT numsequencia 
         FROM roma_item_885
        WHERE codempresa  = p_cod_empresa
          AND numromaneio = p_num_solicit
          AND numseqpai   = p_num_sequencia

      FOREACH cq_ajusta INTO l_numsequencia 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_ajusta')
            RETURN TRUE
         END IF
      
         UPDATE roma_item_885
            SET pesobrutoitem = pesobrutoitem + l_dif_bru
          WHERE codempresa  = p_cod_empresa
            AND numromaneio = p_num_solicit
            AND numseqpai   = p_num_sequencia
            AND numsequencia = l_numsequencia
         
         EXIT FOREACH
         
      END FOREACH   
      
   END IF

   UPDATE roma_item_885
      SET pesoitem = pesobrutoitem - pesopalete 
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','roma_item_885:pesoitem')
      RETURN FALSE
   END IF   
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1309_del_tabs()
#--------------------------#

   DELETE FROM pol1309_erro_885
    WHERE cod_empresa = p_cod_empresa
      AND num_romaneio = p_num_solicit
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','pol1309_erro_885')
      RETURN FALSE
   END IF

   DELETE FROM solic_fatura_885
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','solic_fatura_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1309_insere_erro()
#-----------------------------#
   
   DEFINE p_dat_hor DATETIME YEAR TO SECOND
   
   LET p_criticou      = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND
   
   INSERT INTO pol1309_erro_885
    VALUES(p_cod_empresa,
           p_num_solicit,
           p_den_erro,
           p_dat_hor)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','pol1309_erro_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1309_exibe_erros()
#----------------------------#
   
   DEFINE lr_erro   ARRAY[1000] OF RECORD
      num_romaneio  INTEGER,
      den_erro      CHAR(80)      
   END RECORD
   
   LET p_index = 1
   
   DECLARE cq_erro CURSOR FOR
    SELECT num_romaneio,
           den_erro
      FROM pol1309_erro_885
     WHERE cod_empresa = p_cod_empresa
  
   FOREACH cq_erro INTO lr_erro[p_index].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_erro')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
   
      IF p_index > 1000 THEN
         LET p_msg = 'Limite de linha da grade ultrapassou'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há romaneios criticados no recalculo do peso.'
      CALL log0030_mensagem(p_msg,'info')
   ELSE
      CALL SET_COUNT(p_index - 1)      
      DISPLAY ARRAY lr_erro TO sr_erro.*   
   END IF       

END FUNCTION

#-----------------------------#
FUNCTION pol1309_recalc_peso()#
#-----------------------------#
   
   DECLARE cq_solicit CURSOR FOR
    SELECT num_om
      FROM solicit_fat_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit
       AND cod_status = 'N'
   
   FOREACH cq_solicit INTO p_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_solicit')
         RETURN FALSE
      END IF
      
      DECLARE cq_om_item CURSOR FOR
       SELECT i.num_pedido,
              i.num_sequencia,
              i.qtd_reservada,
              m.num_nff
         FROM ordem_montag_mest m, ordem_montag_item i
        WHERE m.cod_empresa  = p_cod_empresa
          AND m.num_om = p_num_om
          AND i.cod_empresa = m.cod_empresa
          AND i.num_om = m.num_om
          AND m.ies_sit_om = 'F'

      FOREACH cq_om_item INTO
         p_num_pedido,
         p_seq_item,
         p_qtd_reservada,
         p_num_nf
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_om_item')
            RETURN FALSE
         END IF
         
         IF p_num_nf IS NOT NULL THEN
            SELECT COUNT(*)
              INTO p_count
              FROM fat_nf_mestre
             WHERE empresa = p_cod_empresa
               AND nota_fiscal = p_num_nf
               AND sit_nota_fiscal = 'N'

            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','fat_nf_mestre')
               RETURN FALSE
            END IF
         
            IF p_count = 0 THEN
               LET p_den_erro = 'NF ', p_num_nf, ' DA OM ', p_num_om, ' ENEXISTENTE OU CANCELADA '
               IF NOT pol1309_insere_erro() THEN
                  RETURN FALSE
               END IF
               EXIT FOREACH
            END IF
            
            IF p_count > 1 THEN
               LET p_den_erro = 'NF ', p_num_nf, ' DA OM ', p_num_om, ' REPLICADA '
               IF NOT pol1309_insere_erro() THEN
                  RETURN FALSE
               END IF
               EXIT FOREACH
            END IF
            
         END IF
               
         SELECT SUM(qtdpecas),
                SUM(pesoitem),
                SUM(pesobrutoitem)
           INTO p_qtd_pecas,
                p_peso_liq,
                p_peso_bruto
           FROM roma_item_885
          WHERE codempresa  = p_cod_empresa
            AND numromaneio = p_num_solicit
            AND numseqpai   = p_num_sequencia
            AND numpedido = p_num_pedido
            AND numseqitem = p_seq_item
   
         IF STATUS <> 0 THEN
               LET p_den_erro = 'STATUS: ',STATUS USING '<<<<<<<'
               LET p_den_erro = p_den_erro CLIPPED, ' LENDO TABELA ROMA_ITEM_885'
               IF NOT pol1309_insere_erro() THEN
                  RETURN FALSE
               END IF
               EXIT FOREACH
         END IF
         
         IF p_qtd_pecas IS NULL THEN
            LET p_qtd_pecas = 0
         END IF

         IF p_peso_liq IS NULL THEN
            LET p_peso_liq = 0
         END IF

         IF p_peso_bruto IS NULL THEN
            LET p_peso_bruto = 0
         END IF
      
         IF p_qtd_reservada <> p_qtd_pecas THEN
            LET p_peso_unit = p_peso_liq / p_qtd_pecas
            LET p_peso_liq = p_qtd_reservada * p_peso_unit
            LET p_peso_unit = p_peso_bruto / p_qtd_pecas
            LET p_peso_bruto = p_qtd_reservada * p_peso_unit
         END IF
      
         IF NOT pol1309_ins_fatura() THEN
            RETURN FALSE
         END IF
      
      END FOREACH 
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1309_ins_fatura()#
#----------------------------#
 
   INSERT INTO solic_fatura_885
    VALUES(p_cod_empresa,  
           p_num_solicit, 
           p_num_om, 
           p_num_pedido, 
           p_seq_item, 
           p_peso_liq, 
           p_peso_bruto,
           p_num_nf)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','solic_fatura_885')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1309_ajusta_nf()#
#---------------------------#

   DEFINE p_peso_nf_liq       DECIMAL(10,2),
          p_peso_nf_brut      DECIMAL(10,2),
          p_peso_calc_liq     DECIMAL(10,2),
          p_peso_calc_brut    DECIMAL(10,2),
          p_trans_nf          INTEGER,
          p_dif_peso          DECIMAL(10,2)
   
   LET p_ajustou_nf = FALSE
             
   DECLARE cq_aju_nf CURSOR FOR
    SELECT num_nf,
           SUM(peso_liq),
           SUM(peso_bruto)
      FROM solic_fatura_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit
     GROUP BY num_nf

   FOREACH cq_aju_nf INTO p_num_nf, p_peso_calc_liq, p_peso_calc_brut

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_aju_nf')
         RETURN FALSE
      END IF
      
      IF p_num_nf IS NULL OR p_num_nf = 0 THEN
         CONTINUE FOREACH
      END IF
      
      SELECT trans_nota_fiscal, peso_liquido, peso_bruto 
        INTO p_trans_nf, p_peso_nf_liq, p_peso_nf_brut
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND nota_fiscal = p_num_nf
         AND status_nota_fiscal = 'F'
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','FAT_NF_MESTRE:nf')
         RETURN FALSE
      END IF
      
      IF p_peso_nf_liq < p_peso_calc_liq THEN
         LET p_dif_peso = p_peso_calc_liq - p_peso_nf_liq
      ELSE
         LET p_dif_peso = p_peso_nf_liq - p_peso_calc_liq
      END IF
      
      IF p_dif_peso = 0 THEN
         IF p_peso_nf_brut < p_peso_calc_brut THEN
            LET p_dif_peso = p_peso_calc_brut - p_peso_nf_brut
         ELSE
            LET p_dif_peso = p_peso_nf_brut - p_peso_calc_brut
         END IF
      END IF
      
      IF p_dif_peso > p_tol_peso THEN
      
         UPDATE fat_nf_mestre
            SET peso_liquido = p_peso_calc_liq,
                peso_bruto = p_peso_calc_brut
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal = p_trans_nf

         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE','FAT_NF_MESTRE')
            RETURN FALSE
         END IF

         INSERT INTO nf_ajust_885
          VALUES(p_cod_empresa, p_num_solicit, p_num_nf,
                 getDate(), p_peso_nf_liq, p_peso_calc_liq,
                 p_peso_nf_brut, p_peso_calc_brut, 'N')
 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','NF_AJUST_885')
            RETURN FALSE
         END IF
         
         LET p_ajustou_nf = TRUE
         
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1309_ajusta_om()#
#---------------------------#

   DECLARE cq_aju_om CURSOR FOR
    SELECT num_om,
           num_pedido,
           seq_item,
           peso_liq
      FROM solic_fatura_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit

   FOREACH cq_aju_om INTO 
      p_num_om, p_num_pedido, p_seq_item, p_pes_om_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_aju_om')
         RETURN FALSE
      END IF
      
      UPDATE ordem_montag_item
         SET pes_total_item = p_pes_om_item
       WHERE cod_empresa = p_cod_empresa
         AND num_om = p_num_om
         AND num_pedido = p_num_pedido
         AND num_sequencia = p_seq_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ordem_montag_item')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1309_listagem()#
#--------------------------#
   
   DEFINE l_query     CHAR(800)
   
   CALL pol1309_informar('L') RETURNING p_status
   
   IF NOT p_status THEN
      CALL pol1309_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT pol1309_le_den_empresa() THEN
      RETURN FALSE
   END IF

   IF NOT pol1309_inicializa_relat() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 0
   
   LET l_query =
       "SELECT * FROM nf_ajust_885 ",
       " WHERE cod_empresa = '",p_cod_empresa,"' ",
         " AND ies_justific = 'N' ",
         " AND EXTEND(dat_ajuste, YEAR  TO DAY) >= '",p_tela.dat_ini,"' ",
         " AND EXTEND(dat_ajuste, YEAR  TO DAY) <= '",p_tela.dat_fim,"' "
   
   IF p_tela.num_solicit > 0 THEN  
      LET l_query = l_query CLIPPED,  " AND num_solicit = '",p_tela.num_solicit,"' "
   END IF
   
   LET l_query = l_query CLIPPED, " ORDER BY dat_ajuste, num_solicit, num_nf "

   PREPARE var_query2 FROM l_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE', 'var_query2')
      RETURN FALSE
   END IF
      
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query2
       
   FOREACH cq_relat INTO  p_relat.*
      
      IF STATUS <> 0 THEN           
         CALL log003_err_sql('FOREACH','cq_relat')
         RETURN FALSE
      END IF
      
      MESSAGE 'Romaneio: ', p_relat.num_solicit USING '<<<<<<<<<<<<'
        #lds CALL LOG_refresh_display()
               
      OUTPUT TO REPORT pol1309_relat()
      
      LET p_count = p_count + 1
   
   END FOREACH

   CALL pol1309_finaliza_relat()
   CALL log0030_mensagem(p_msg, 'excla')
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1309_le_den_empresa()
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

#----------------------------------#
FUNCTION pol1309_inicializa_relat()#
#----------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1309_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1309.tmp' 
         START REPORT pol1309_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1309_relat TO p_nom_arquivo
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1309_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1309_relat
   
   IF p_count = 0 THEN
      LET p_msg = "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF
     
END FUNCTION 

#----------------------#
 REPORT pol1309_relat()#
#----------------------#
   
   DEFINE P_LAST_ROW SMALLINT
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
     
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 040, 'NOTAS COM PESOS AJUSTADOS',
               COLUMN 073, 'PAG. ', PAGENO USING '##&'
         PRINT COLUMN 001, 'PROCES DE:',
               COLUMN 013, p_tela.dat_ini USING 'dd/mm/yyyy',
               COLUMN 024, 'ATE:',
               COLUMN 029, p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 053, 'EMISSAO:',
               COLUMN 062, TODAY, ' ', TIME
         PRINT '--------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'ROMANEIO    NUM NF   DAT AJUST  PES LIQ ANT PES LIQ ATU PES BRU ANT PES BRU ATU'
         PRINT COLUMN 001, '----------- -------- ---------- ----------- ----------- ----------- -----------'
        
      PAGE HEADER
	  
         PRINT COLUMN 073, 'PAG. ', PAGENO USING '##&'               
         PRINT
         PRINT COLUMN 001, 'ROMANEIO    NUM NF   DAT AJUST  PES LIQ ANT PES LIQ ATU PES BRU ANT PES BRU ATU'
         PRINT COLUMN 001, '----------- -------- ---------- ----------- ----------- ----------- -----------'
      
      ON EVERY ROW
         
         PRINT COLUMN 001, p_relat.num_solicit USING '###########',
               COLUMN 013, p_relat.num_nf USING '########',
               COLUMN 022, p_relat.dat_ajuste USING 'dd/mm/yyyy',
               COLUMN 033, p_relat.peso_liq_ant USING '####,##&.&&',
               COLUMN 045, p_relat.peso_liq_atu USING '####,##&.&&',
               COLUMN 057, p_relat.peso_bru_ant USING '####,##&.&&',
               COLUMN 069, p_relat.peso_bru_atu USING '####,##&.&&'
                                             
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT



#--------------FIM DO PROGRAMA-------------#

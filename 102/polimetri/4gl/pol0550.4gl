------------------------------------------------------------------------------#
# PROGRAMA: pol0550                                                           #
# OBJETIVO: GRAVA CENTROS DE TRABRALHO/CUSTO NA ORD_OPER                      #
#           A PARTIR DA TABELA ARRANJO_DRUMMER                                #
# DATA....: 02/03/2007                                                        #
# ALTERADO: 02/03/2007 - ANA PAULA                                            #
#-----------------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_arranjo        LIKE arranjo.cod_arranjo,
          p_cod_recur          LIKE recurso.cod_recur,
          p_cod_cent_trab      LIKE arranjo_drummer.cod_cent_trab,
          p_cod_cent_cust      LIKE arranjo_drummer.cod_cent_cust,
          p_rowid              INTEGER,
          p_count              INTEGER,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_mem                CHAR(01),
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(500)

     DEFINE p_num_ordem      LIKE ordens.num_ordem
               
     DEFINE pr_arranjo        ARRAY[500] OF RECORD
            cod_arranjo      LIKE arranjo.cod_arranjo,
            den_arranjo      LIKE arranjo.den_arranjo
     END RECORD
                 

 END GLOBALS
            

MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol0550-10.02.00' 

   SET LOCK MODE TO WAIT 120

   DEFER INTERRUPT

   LET p_caminho = log140_procura_caminho('pol0550.iem')

   OPTIONS
       PREVIOUS KEY control-b,
       NEXT     KEY control-f,
       INSERT   KEY control-i,
       DELETE   KEY control-e,
       HELP    FILE p_caminho

  CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_caminho TO NULL 
   CALL log130_procura_caminho("pol0550") RETURNING p_caminho
   LET p_caminho = p_caminho CLIPPED 
   OPEN WINDOW w_pol0550 AT 2,2 WITH FORM p_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE 18, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF  p_status = 0 THEN
       CALL pol0550_controle()
   END IF

   WHENEVER ERROR STOP

   CLOSE WINDOW w_pol0550
   
END MAIN

#--------------------------#
 FUNCTION pol0550_controle()
#--------------------------#

   CALL log085_transacao("BEGIN")

   IF pol0550_verifica() THEN
      CALL log085_transacao("COMMIT")
      PROMPT 'Processamento efetuado com sucesso !!!' FOR p_mem
      IF p_ind > 0 THEN
         CALL pol0550_exibe_arranjos()
      END IF
   ELSE
      CALL log085_transacao("ROLLBACK")
      PROMPT 'Operação cancelada devido a erro no processamento !!!' FOR p_mem
   END IF
   
END FUNCTION

#--------------------------#
FUNCTION pol0550_verifica()
#--------------------------#
   
   WHENEVER ERROR CONTINUE
   
   DROP TABLE arranjo_tmp;

   CREATE TEMP TABLE arranjo_tmp
   (
     cod_arranjo CHAR(05)
   );
   
   MESSAGE 'Aguarde...   Processando Ordem: ' ATTRIBUTE(REVERSE)

   LET p_ind = 0

   DECLARE cq_ordens CURSOR FOR
   SELECT num_ordem 
     FROM ordens
    WHERE cod_empresa = p_cod_empresa 
      AND ies_situa   = '3'

   FOREACH cq_ordens INTO p_num_ordem
   
      DISPLAY p_num_ordem AT 18,33
      
      DECLARE cq_oper CURSOR FOR 
       SELECT cod_arranjo,
              rowid
         FROM ord_oper
        WHERE cod_empresa = p_cod_empresa
          AND num_ordem   = p_num_ordem
         
      FOREACH cq_oper INTO p_cod_arranjo, p_rowid

         SELECT cod_cent_trab,
                cod_cent_cust
           INTO p_cod_cent_trab,
                p_cod_cent_cust
           FROM arranjo_drummer
          WHERE cod_empresa = p_cod_empresa
            AND cod_arranjo = p_cod_arranjo
                   
           IF SQLCA.sqlcode = NOTFOUND THEN 
              SELECT cod_arranjo
                FROM arranjo_tmp
               WHERE cod_arranjo = p_cod_arranjo
              IF SQLCA.sqlcode = NOTFOUND THEN 
                 LET p_ind = p_ind + 1
                 INSERT INTO arranjo_tmp
                  VALUES(p_cod_arranjo)
              END IF
           ELSE
              UPDATE ord_oper
                 SET cod_cent_trab = p_cod_cent_trab,
                     cod_cent_cust = p_cod_cent_cust
               WHERE rowid = p_rowid
              IF STATUS <> 0 THEN
                 CALL log003_err_sql("UPDATE","ORD_OPER")
                 LET p_ind = 0
                 RETURN FALSE
              END IF
           END IF
           
      END FOREACH

   END FOREACH
 
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0550_exibe_arranjos()
#--------------------------------#


   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol05501") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol05501 AT 7,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1
   
   DECLARE cq_tmp CURSOR FOR 
    SELECT * FROM arranjo_tmp
     ORDER BY 1

   FOREACH cq_tmp INTO pr_arranjo[p_index].cod_arranjo
   
      INITIALIZE pr_arranjo[p_index].den_arranjo TO NULL
      SELECT den_arranjo 
       INTO pr_arranjo[p_index].den_arranjo
       FROM arranjo
      WHERE cod_empresa = p_cod_empresa
        AND cod_arranjo = pr_arranjo[p_index].cod_arranjo

      LET p_index = p_index + 1
      
   END FOREACH
   
   CALL SET_COUNT(p_index)

   DISPLAY ARRAY pr_arranjo TO sr_arranjo.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()

   CURRENT WINDOW IS w_pol0550

END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#

   


   
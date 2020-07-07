#-------------------------------------------------------------------#
# PROGRAMA: pol0757                                                 #
# OBJETIVO: RELATORIO DE COMISSOES REPRESENTANTES - OFICIAL         #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
          p_den_empresa       LIKE empresa.den_empresa,
          p_ies_impressao     CHAR(01),
          g_ies_ambiente      CHAR(01),
          p_user              LIKE usuario.nom_usuario,
          p_ies_base_ir       CHAR(01),  
          p_nom_cliente       LIKE clientes.nom_cliente,
          p_nom_repres        LIKE representante.raz_social, 
          p_nom_gerente       LIKE representante.raz_social,
          p_num_cgc_cpf       LIKE representante.num_cgc,  
          p_cod_repres        LIKE representante.cod_repres,
          p_cod_gerente       LIKE representante.cod_repres,
          p_lanc_com_885      RECORD LIKE lanc_com_885.*,
          p_lanc_acerto_com_885 RECORD LIKE lanc_acerto_com_885.*,
          p_com_fut_885       RECORD LIKE com_fut_885.*,
          p_val_bruto         DEC(15,2), 
          p_val_base_ir       DEC(15,2), 
          p_val_liq           DEC(15,2), 
          p_val_ir            DEC(15,2), 
          p_versao            CHAR(18),
          p_rec_erro,
          p_ped_erro,
          p_val               SMALLINT,
          p_ies_cons          SMALLINT,
          p_inicio            SMALLINT,
          p_houve_erro        SMALLINT,
          p_erro              SMALLINT,
          p_situac            CHAR(70),
          p_incons            CHAR(01),
          p_liber             CHAR(01),
          p_ies_calc_pag      CHAR(01),
          p_count             SMALLINT,
          p_achou             SMALLINT,
          p_status            SMALLINT,
          p_last_row          SMALLINT,
          comando             CHAR(80),
          p_nom_arquivo       CHAR(100),
          p_caminho           CHAR(080),
          p_nom_tela          CHAR(200),
          p_nom_help          CHAR(200)
 
   DEFINE p_relat RECORD
      den_empresa  LIKE empresa.den_empresa,
      cod_gerente  LIKE repres_885.cod_gerente,      
      cod_repres   LIKE lanc_com_885.cod_repres,
      cod_cliente  LIKE clientes.cod_cliente,
      num_nff      LIKE lanc_com_885.num_nff,
      num_pedido   LIKE ped_itens.num_pedido,
      num_docum    LIKE lanc_com_885.num_docum, 
      ies_tip_lanc LIKE lanc_com_885.ies_tip_lanc,
      ies_origem   LIKE lanc_com_885.ies_origem, 
      dat_pagto    LIKE lanc_com_885.dat_pagto,
      val_base_com     LIKE lanc_com_885.val_base_com ,     
      pct_comis    LIKE lanc_com_885.pct_comis,
      val_com_rep  LIKE lanc_com_885.val_com_rep
   END RECORD

   DEFINE p_tela RECORD
      dat_de       DATE,
      dat_ate      DATE,
      dat_pagto    DATE
   END RECORD

   DEFINE t_tot_rep RECORD
          cod_gerente       DECIMAL(4,0),
          cod_repres        DECIMAL(4,0),
          val_bruto         DECIMAL(15,2),
          val_base_com          DECIMAL(15,2),
          val_ir            DECIMAL(15,2),
          val_liquido       DECIMAL(15,2)
   END RECORD

END GLOBALS

MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0757-05.10.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0757.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0757_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0757_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0757") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0757 AT 3,03 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros para impressao"
      HELP 001
      LET p_ies_cons = FALSE
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0757","IN") THEN
         IF pol0757_entrada_dados() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
         ELSE
            ERROR "Funcao Cancelada"
            NEXT OPTION "Fim"
         END IF 
      END IF 

      COMMAND "Processar" "Processa a listagem do relatorio."
      HELP 002
      LET p_count = 0
      LET p_achou = FALSE
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0757","MO") THEN
         IF p_ies_cons = TRUE THEN 
           IF pol0757_calcula_valores()  THEN 
            IF log028_saida_relat(16,40) IS NOT NULL THEN
               MESSAGE " Processando a extracao do relatorio ... " 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0757_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0757.tmp'
                     START REPORT pol0757_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0757_relat TO p_nom_arquivo
               END IF
               CALL pol0757_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao existem dados para serem listados" 
                     ATTRIBUTE(REVERSE)
               ELSE
                  ERROR "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
               END IF
               FINISH REPORT pol0757_relat   
            ELSE
               CONTINUE MENU 
            END IF                                                            

            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " 
                  ATTRIBUTE(REVERSE)
            END IF                              
           END IF                                                            
            NEXT OPTION "Fim"
         END IF 
      ELSE
         ERROR "Informe a referencia para impressao"
         NEXT OPTION "Informar"
      END IF 
      COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0757

END FUNCTION

#----------------------------------------#
 FUNCTION pol0757_entrada_dados()
#----------------------------------------#
 
   INITIALIZE p_tela.* TO NULL

   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD dat_de     
      IF p_tela.dat_de IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_de        
      END IF 

      AFTER FIELD dat_ate    
      IF p_tela.dat_ate IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_ate       
      ELSE
         IF p_tela.dat_de > p_tela.dat_ate THEN
            ERROR "data de nao pode ser maior que data ate"
            NEXT FIELD dat_de        
         END IF 
      END IF 

      AFTER FIELD dat_pagto  
      IF p_tela.dat_pagto IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_pagto     
      END IF 

      AFTER INPUT
      IF int_flag = 0 THEN
      END IF 
   
   END INPUT

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION 

#---------------------------------#
 FUNCTION pol0757_calcula_valores()
#---------------------------------#
 DEFINE l_ies_sem_mov  CHAR(01)

WHENEVER ERROR CONTINUE
DROP TABLE t_tot_rep

 CREATE  TEMP   TABLE t_tot_rep 
 (cod_gerente       DECIMAL(4,0),
  cod_repres        DECIMAL(4,0),
  val_bruto         DECIMAL(15,2),
  val_base_com      DECIMAL(15,2),
  val_ir            DECIMAL(15,2),
  val_liquido       DECIMAL(15,2)
 );
WHENEVER ERROR STOP

 LET p_count = 0

 LET p_ies_calc_pag = 'S'
 
 SELECT count(*)
   INTO p_count
   FROM lanc_com_885 a,
        repres_885 b                
  WHERE a.cod_repres  = b.cod_repres 
    AND a.cod_empresa = p_cod_empresa
    AND a.dat_pagto   = p_tela.dat_pagto
    AND a.ies_origem  in ("P","I")  
    AND b.tip_comis   = 'R'

  IF p_count > 0 THEN  
     ERROR "PERIODO JA PROCESSADO DESEJA REPROCESSAR"
     IF log004_confirm(10,20)  THEN
        LET p_ies_calc_pag = 'S'
     ELSE
        LET p_ies_calc_pag = 'N'
     END IF       
  END IF 

IF p_ies_calc_pag = 'S' THEN
   DECLARE cq_repres CURSOR FOR
   SELECT cod_gerente,cod_repres
     FROM repres_885
    WHERE tip_comis = 'R' 
   ORDER BY cod_gerente,cod_repres
   FOREACH cq_repres INTO p_cod_gerente,p_cod_repres  

    DELETE FROM lanc_com_885                
     WHERE cod_empresa  = p_cod_empresa
       AND dat_pagto    = p_tela.dat_pagto
       AND cod_repres   = p_cod_repres
       AND ies_origem   IN ("P","I")
    
     LET t_tot_rep.val_bruto   = 0
     LET t_tot_rep.val_base_com    = 0
     LET t_tot_rep.val_liquido = 0
     LET t_tot_rep.val_ir      = 0
     LET t_tot_rep.cod_repres  = p_cod_repres 
     LET t_tot_rep.cod_gerente = p_cod_gerente

     LET l_ies_sem_mov = 'S'
   
     DECLARE cq_total CURSOR FOR
     SELECT * 
     FROM lanc_com_885                
     WHERE cod_empresa = p_cod_empresa
       AND dat_pagto   = p_tela.dat_pagto
       AND cod_repres  = p_cod_repres   
   
     FOREACH cq_total INTO p_lanc_com_885.*  
     
        LET l_ies_sem_mov = 'N'
        IF p_lanc_com_885.ies_tip_lanc = "C" THEN
           LET t_tot_rep.val_bruto = t_tot_rep.val_bruto + p_lanc_com_885.val_com_rep
        ELSE
           LET t_tot_rep.val_bruto = t_tot_rep.val_bruto - p_lanc_com_885.val_com_rep
        END IF
   
        IF p_lanc_com_885.ies_origem <> "X" AND 
           p_lanc_com_885.ies_origem <> "Y" THEN
           IF p_lanc_com_885.ies_origem <> "R"  THEN 
              IF p_lanc_com_885.ies_tip_lanc = "C" THEN
                 LET t_tot_rep.val_base_com = t_tot_rep.val_base_com + p_lanc_com_885.val_com_rep
              ELSE
                 LET t_tot_rep.val_base_com = t_tot_rep.val_base_com - p_lanc_com_885.val_com_rep
              END IF
           END IF    
        ELSE
           SELECT des_lanc,
                  ies_base_ir
              INTO p_nom_cliente, 
                   p_ies_base_ir  
           FROM lanc_acerto_com_885
           WHERE cod_empresa    = p_cod_empresa      
             AND num_docum      = p_lanc_com_885.num_nff
             AND cod_repres     = p_lanc_com_885.cod_repres
#           IF p_ies_base_ir = "S" THEN
#              IF p_lanc_com_885.ies_tip_lanc = "C" THEN
#                 LET t_tot_rep.val_base_com = t_tot_rep.val_base_com + p_lanc_com_885.val_com_rep
#              ELSE
#                 LET t_tot_rep.val_base_com = t_tot_rep.val_base_com - p_lanc_com_885.val_com_rep
#              END IF
#           END IF
        END IF 
   
     END FOREACH

     IF l_ies_sem_mov = 'S' THEN 
        LET p_lanc_com_885.cod_empresa  = p_cod_empresa
        LET p_lanc_com_885.num_docum    = '0'
        LET p_lanc_com_885.num_nff      = 0
        LET p_lanc_com_885.cod_repres   = p_cod_repres
        LET p_lanc_com_885.dat_proces   = TODAY
        LET p_lanc_com_885.val_base_com = 0   
        LET p_lanc_com_885.pct_comis    = 0 
        LET p_lanc_com_885.ies_tip_lanc = "C"                 
        LET p_lanc_com_885.ies_origem   = "F"
        LET p_lanc_com_885.nom_usuario  = p_user
        LET p_lanc_com_885.val_com_rep  = 0
        LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto    
        LET p_lanc_com_885.dat_ini_per  = p_tela.dat_de     
        LET p_lanc_com_885.dat_fim_per  = p_tela.dat_ate  
        
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSAO","LANCAMENTO PG")
           RETURN FALSE
        END IF                                                        
     END IF 
     
#    IF t_tot_rep.val_bruto > 0 THEN
       
       LET t_tot_rep.val_ir = t_tot_rep.val_base_com * 0
       IF t_tot_rep.val_ir < 10 THEN
          LET t_tot_rep.val_ir = 0
       END IF        
       LET t_tot_rep.val_liquido = t_tot_rep.val_bruto - t_tot_rep.val_ir
   
       INSERT INTO t_tot_rep VALUES (t_tot_rep.*)

       LET p_lanc_com_885.cod_empresa  = p_cod_empresa
       LET p_lanc_com_885.num_docum    = '0'
       LET p_lanc_com_885.num_nff      = 0
       LET p_lanc_com_885.cod_repres   = p_cod_repres
       LET p_lanc_com_885.dat_proces   = TODAY
       LET p_lanc_com_885.val_base_com  = 0   
       LET p_lanc_com_885.pct_comis    = 0               
       LET p_lanc_com_885.ies_tip_lanc = "D"
       LET p_lanc_com_885.ies_origem   = "P"
       LET p_lanc_com_885.nom_usuario  = p_user
       LET p_lanc_com_885.val_com_rep  = t_tot_rep.val_liquido
       LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto   
       LET p_lanc_com_885.dat_ini_per  = p_tela.dat_de   
       LET p_lanc_com_885.dat_fim_per  = p_tela.dat_ate    
       INSERT into lanc_com_885 values (p_lanc_com_885.*)
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INCLUSAO","LANCAMENTO PG")
          RETURN FALSE 
       END IF                                                        
   
       IF t_tot_rep.val_ir > 0 THEN
          LET p_lanc_com_885.ies_origem   = "I"
          LET p_lanc_com_885.val_com_rep     = t_tot_rep.val_ir        
          INSERT into lanc_com_885 values (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("INCLUSAO","LANCAMENTO IR")
             RETURN FALSE 
          END IF   
       END IF                     
#    END IF                        
   
   END FOREACH
END IF      
 RETURN TRUE 
END FUNCTION 

#---------------------------------#
 FUNCTION pol0757_emite_relatorio()
#---------------------------------#
DEFINE l_cod_rep   LIKE representante.cod_repres

   LET p_last_row = FALSE
   LET p_count    = 0
   LET p_inicio   = 0

   SELECT den_empresa   
      INTO p_relat.den_empresa
   FROM empresa 
   WHERE cod_empresa = p_cod_empresa
   IF sqlca.sqlcode <> 0 THEN
      LET p_relat.den_empresa = "EMPRESA NAO CADASTRADA" 
      LET p_den_empresa = NULL                
   ELSE 
      LET p_den_empresa = p_relat.den_empresa
   END IF 

   DECLARE cq_reprel CURSOR FOR  
    SELECT a.cod_repres,b.cod_gerente
      FROM t_tot_rep a, repres_885 b
     WHERE a.cod_repres = b.cod_repres  
     ORDER BY a.cod_gerente, b.cod_repres
    
   FOREACH  cq_reprel INTO l_cod_rep, p_cod_gerente         

      SELECT raz_social,
             num_cgc
        INTO p_nom_repres,
             p_num_cgc_cpf
        FROM representante          
       WHERE cod_repres = l_cod_rep   
      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_nom_repres,
                    p_num_cgc_cpf TO NULL 
      END IF   
      
      SELECT raz_social
         INTO p_nom_gerente
      FROM representante          
      WHERE cod_repres = p_cod_gerente
      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_nom_gerente TO NULL 
      END IF   
      
      DECLARE cq_relat CURSOR FOR
      SELECT * 
      FROM lanc_com_885 
      WHERE cod_empresa = p_cod_empresa
        AND dat_pagto   = p_tela.dat_pagto
        AND ies_origem not in ("P","I")
        AND cod_repres = l_cod_rep 
      ORDER BY ies_origem,
               num_docum
      
      FOREACH cq_relat INTO p_lanc_com_885.*
      
         LET p_relat.cod_gerente  = p_cod_gerente
         LET p_relat.cod_repres   = p_lanc_com_885.cod_repres  
        
         SELECT cod_cliente
           INTO p_relat.cod_cliente 
           FROM nf_mestre
          WHERE cod_empresa = p_cod_empresa 
            AND num_nff     = p_lanc_com_885.num_nff   
         LET p_relat.num_nff      = p_lanc_com_885.num_nff     
         SELECT MAX(num_pedido)
           INTO p_relat.num_pedido
           FROM nf_item
          WHERE cod_empresa = p_cod_empresa 
            AND num_nff     = p_lanc_com_885.num_nff   
         LET p_relat.num_docum    = p_lanc_com_885.num_docum  
         LET p_relat.ies_tip_lanc = p_lanc_com_885.ies_tip_lanc 
         LET p_relat.ies_origem   = p_lanc_com_885.ies_origem 
         LET p_relat.dat_pagto    = p_lanc_com_885.dat_pagto 
         LET p_relat.val_base_com = p_lanc_com_885.val_base_com       
         LET p_relat.pct_comis    = p_lanc_com_885.pct_comis 
         LET p_relat.val_com_rep  = p_lanc_com_885.val_com_rep 
      
         SELECT raz_social,
                num_cgc
            INTO p_nom_repres,
                 p_num_cgc_cpf
         FROM representante          
         WHERE cod_repres = p_relat.cod_repres   
         IF sqlca.sqlcode <> 0 THEN
            INITIALIZE p_nom_repres,
                       p_num_cgc_cpf TO NULL 
         END IF   
      
         IF p_relat.ies_origem <> "X" AND 
            p_relat.ies_origem <> "Y" THEN
            SELECT nom_cliente
               INTO p_nom_cliente  
            FROM clientes 
            WHERE cod_cliente = p_relat.cod_cliente
            IF sqlca.sqlcode <> 0 THEN
               INITIALIZE p_nom_cliente TO NULL 
            END IF
            IF p_relat.ies_origem = "R" THEN 
               SELECT MAX(cod_item)
                 INTO p_com_fut_885.cod_item 
                 FROM com_fut_885
                WHERE cod_empresa  = p_cod_empresa 
                  AND num_nff      = p_lanc_com_885.num_nff
                  AND cod_repres   = p_lanc_com_885.cod_repres
                  AND val_base_com = p_lanc_com_885.val_base_com
                  INITIALIZE p_relat.cod_cliente TO NULL
                  LET p_relat.cod_cliente = 'It. ',p_com_fut_885.cod_item
            END IF    
         ELSE
            SELECT des_lanc,
                   ies_base_ir
               INTO p_nom_cliente, 
                    p_ies_base_ir  
            FROM lanc_acerto_com_885
            WHERE cod_empresa    = p_cod_empresa      
              AND num_docum      = p_relat.num_nff 
              AND cod_repres     = p_relat.cod_repres
                  
            IF sqlca.sqlcode <> 0 THEN
               INITIALIZE p_nom_cliente TO NULL 
            END IF
         END IF 

         IF p_relat.ies_origem = "R" THEN
            LET p_relat.val_base_com = 0
         END IF    
      
         OUTPUT TO REPORT pol0757_relat(p_relat.*,p_nom_repres,p_num_cgc_cpf,p_nom_gerente) 
         INITIALIZE p_relat.* TO NULL 
         LET p_count = p_count + 1 
      
      END FOREACH

      DECLARE cq_relft CURSOR FOR
      SELECT * 
        FROM com_fut_885 
       WHERE cod_empresa = p_cod_empresa
         AND dat_pagto   = p_tela.dat_pagto
         AND dat_libera IS NULL 
         AND cod_repres = l_cod_rep 
       ORDER BY num_nff
       
      FOREACH cq_relft INTO p_com_fut_885.*   

         LET p_relat.cod_gerente  = p_cod_gerente
         LET p_relat.cod_repres   = p_com_fut_885.cod_repres  
         
         SELECT cod_cliente
           INTO p_relat.cod_cliente 
           FROM nf_mestre
          WHERE cod_empresa = p_cod_empresa 
            AND num_nff     = p_com_fut_885.num_nff   
            
         LET p_relat.num_nff  = p_com_fut_885.num_nff    

         SELECT MAX(num_pedido)
           INTO p_relat.num_pedido
           FROM nf_item
          WHERE cod_empresa = p_cod_empresa 
            AND num_nff     = p_com_fut_885.num_nff   
      
         LET p_relat.num_docum    = p_com_fut_885.num_nff 
         LET p_relat.ies_tip_lanc = 'C' 
         LET p_relat.ies_origem   = 'H' 
         LET p_relat.dat_pagto    = p_com_fut_885.dat_pagto 
         LET p_relat.val_base_com = p_com_fut_885.val_base_com       
         LET p_relat.pct_comis    = p_com_fut_885.pct_comis 
         LET p_relat.val_com_rep  = 0
          
         SELECT nom_cliente
            INTO p_nom_cliente  
         FROM clientes 
         WHERE cod_cliente = p_relat.cod_cliente
         IF sqlca.sqlcode <> 0 THEN
            INITIALIZE p_nom_cliente TO NULL 
         END IF

         LET p_relat.cod_cliente = 'it ',p_com_fut_885.cod_item

         OUTPUT TO REPORT pol0757_relat(p_relat.*,p_nom_repres,p_num_cgc_cpf,p_nom_gerente) 
         INITIALIZE p_relat.* TO NULL 
         LET p_count = p_count + 1 
      
      END FOREACH 
      
   END FOREACH 
END FUNCTION 

#---------------------------------------------------------------------#
 REPORT pol0757_relat(p_relat,p_nom_repres,p_num_cgc_cpf,p_nom_gerente)
#---------------------------------------------------------------------#

   DEFINE p_relat RECORD
      den_empresa  LIKE empresa.den_empresa,
      cod_gerente  LIKE repres_885.cod_gerente,      
      cod_repres   LIKE lanc_com_885.cod_repres,
      cod_cliente  LIKE clientes.cod_cliente,
      num_nff      LIKE lanc_com_885.num_nff,
      num_pedido   LIKE ped_itens.num_pedido,
      num_docum    LIKE lanc_com_885.num_docum, 
      ies_tip_lanc LIKE lanc_com_885.ies_tip_lanc,
      ies_origem   LIKE lanc_com_885.ies_origem, 
      dat_pagto    LIKE lanc_com_885.dat_pagto,
      val_base_com LIKE lanc_com_885.val_base_com ,     
      pct_comis    LIKE lanc_com_885.pct_comis,
      val_com_rep  LIKE lanc_com_885.val_com_rep
   END RECORD

   DEFINE p_nom_repres  LIKE representante.raz_social,
          p_num_cgc_cpf LIKE representante.num_cgc,
          p_nom_gerente LIKE representante.raz_social  

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   ORDER EXTERNAL BY p_relat.cod_gerente,
                     p_relat.cod_repres,
                     p_relat.ies_origem

   FORMAT

      PAGE HEADER  
         PRINT log500_determina_cpp(132)
         PRINT log500_condensado(true)
         PRINT COLUMN 001, p_den_empresa[1,25],
               COLUMN 032, "Relacao de Comissoes - REPRESENTANTES - ",
                           "Periodo ", p_tela.dat_de, " ate ", p_tela.dat_ate,
               COLUMN 121, "Folha: ", pageno using "####&"

         PRINT COLUMN 001, "POL0757",
               COLUMN 114, "Emissao: ", TODAY        
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, "NUMERO",
               COLUMN 016, "PEDIDO",
               COLUMN 024, "CLIENTE",
               COLUMN 088, "BASE",
               COLUMN 095, "PERC",  
               COLUMN 106, "VALOR"

         PRINT COLUMN 001, "NOTA",
               COLUMN 085, "CALCULO",
               COLUMN 094, "COMIS",  
               COLUMN 106, "COMIS"
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         SKIP 1 LINE
         PRINT COLUMN 001, "GERENTE : ", p_relat.cod_gerente, " - ",
                           p_nom_gerente                          
         PRINT COLUMN 001, "REPRESENTANTE : ", p_relat.cod_repres, " - ",
                           p_nom_repres,                          
               COLUMN 070, "CNPJ: ", p_num_cgc_cpf
         SKIP 1 LINE  

      BEFORE GROUP OF p_relat.cod_repres
         SKIP TO TOP OF PAGE

      ON EVERY ROW
 
         IF p_relat.num_docum IS NOT NULL THEN
            PRINT COLUMN 001, p_relat.num_docum;
         ELSE
            PRINT COLUMN 001, p_relat.num_nff USING "#####&";
         END IF 
         PRINT COLUMN 016, p_relat.num_pedido USING "#####&",        
               COLUMN 024, p_relat.cod_cliente,   
               COLUMN 042, p_nom_cliente[1,25],              
               COLUMN 082, p_relat.val_base_com  USING "####,##&.&&",
               COLUMN 095, p_relat.pct_comis USING "&.&&", 
               COLUMN 101, p_relat.val_com_rep  USING "###,##&.&&"

      AFTER GROUP OF p_relat.ies_origem

         SKIP 1 LINE          
         IF p_relat.ies_origem = "B" THEN
            PRINT COLUMN 001, "TOTAL LIQUIDACOES: ";
         ELSE
            IF p_relat.ies_origem = "F" THEN
               PRINT COLUMN 001, "TOTAL VENDAS: ";
            ELSE
               IF p_relat.ies_origem = "V" THEN
                  PRINT COLUMN 001, "TOTAL DEVOLUCOES: ";
               ELSE
                  IF p_relat.ies_origem = "T" THEN
                     PRINT COLUMN 001, "TOTAL DESCONTOS: "; 
                  ELSE
                     IF p_relat.ies_origem = "R" THEN
                        PRINT COLUMN 001, "TOTAL CLICHES LIB: ";
                     ELSE
                        IF p_relat.ies_origem = "H" THEN  
                           PRINT COLUMN 001, "TOTAL CLICHES FUTURO: ";
                        ELSE
                           IF p_relat.ies_origem = "X" THEN
                              PRINT COLUMN 001, "OUTROS CREDITOS: ";
                           ELSE                
                              PRINT COLUMN 001, "OUTROS DEBITOS: ";
                           END IF    
                        END IF    
                     END IF
                  END IF    
               END IF
            END IF
         END IF
          
         PRINT COLUMN 083, group sum(p_relat.val_base_com) USING "##,###,##&.&&",
               COLUMN 096, group sum(p_relat.val_com_rep) USING "##,###,##&.&&"
         SKIP 1 LINE          

      AFTER GROUP OF p_relat.cod_repres

          SELECT *    
            INTO t_tot_rep.*
            FROM t_tot_rep 
           WHERE cod_repres = p_relat.cod_repres                      

         SKIP 2 LINES 
         PRINT COLUMN 020, "TOTAL BRUTO : ", 
               t_tot_rep.val_bruto   USING "###,###,##&.&&"
         PRINT COLUMN 020, "BASE  IR    : ", 
               t_tot_rep.val_base_com USING "###,###,##&.&&"
         PRINT COLUMN 020, "IR RECOLHIDO: ", t_tot_rep.val_ir  USING "###,###,##&.&&"
         PRINT COLUMN 020, "A RECEBER   : ", t_tot_rep.val_liquido USING "###,###,##&.&&"
         LET p_inicio = 0                       
         LET t_tot_rep.val_bruto = 0
         LET t_tot_rep.val_base_com = 0
         LET t_tot_rep.val_liquido = 0
         LET t_tot_rep.val_ir = 0

      ON LAST ROW

         SKIP 1 LINE          
         PRINT COLUMN 001, "TOTAL GERAL: ",        
               COLUMN 083, sum(p_relat.val_base_com) USING "##,###,##&.&&",
               COLUMN 096, sum(p_relat.val_com_rep) USING "##,###,##&.&&"

END REPORT
#------------------------------ FIM DE PROGRAMA -------------------------------#

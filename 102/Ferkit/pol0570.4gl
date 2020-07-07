#------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                             #
# PROGRAMA: pol0570   -  APONT. DE ORDENS DE PRODUCAO POR PEDIDO   #
#------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_caminho                CHAR(80),
          p_nom_tela               CHAR(80),  
          comando                  CHAR(80),   
          p_ind                    SMALLINT,
          p_ies_pend               CHAR(01),
          pa_curr                  INTEGER,
          sc_curr                  INTEGER,
          l_saldo                  SMALLINT,
          p_msg                    CHAR(300),
          p_hoje                   DATE,
          p_cod_operacao           CHAR(05),
          m_msg                    CHAR(100)
          
           
   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

   DEFINE p_num_pedido             LIKE pedidos.num_pedido,
          p_num_ped_ch             CHAR(10),
          p_num_ordem              LIKE ordens.num_ordem,
          p_man_apont_454          RECORD LIKE man_apont_454.*,
          p_man_apont_erro_454     RECORD LIKE man_apont_erro_454.*,
          p_trans_pendentes        RECORD LIKE trans_pendentes.*,
          p_pedidos                RECORD LIKE pedidos.*,
          p_ordens                 RECORD LIKE ordens.*,
          p_ord_oper               RECORD LIKE ord_oper.*,
          p_estrutura              RECORD LIKE estrutura.*
          

   DEFINE p_tela      ARRAY[500] OF RECORD
          num_ordem     LIKE ordens.num_ordem,
          cod_item      LIKE item.cod_item,
          den_item      CHAR(37),
          qtd_boas      DECIMAL(12,3),
          ies_pend      CHAR(1)
      END RECORD                           


   DEFINE p_tela_pend  ARRAY[500] OF RECORD
          num_ordem     LIKE ordens.num_ordem,
          cod_item      LIKE item.cod_item,
          den_item      CHAR(37),
          qtd_pend      DECIMAL(12,3)
      END RECORD                           

   DEFINE p_tela_erro  ARRAY[500] OF RECORD
          num_ordem     LIKE ordens.num_ordem,
          operacao      CHAR(5),
          texto         CHAR(62)
      END RECORD                           

   DEFINE p_pend   RECORD
          num_ordem     LIKE ordens.num_ordem,
          cod_item      LIKE item.cod_item,
          qtd_pend      DECIMAL(12,3)
      END RECORD           
      
   DEFINE p_w_reservas   RECORD
          cod_item      LIKE item.cod_item,
          qtd_reser     DECIMAL(12,3),
          qtd_saldo     DECIMAL(12,3)
      END RECORD                           
                      

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0570-10.02.07"  
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7

   DEFER INTERRUPT

   CALL log140_procura_caminho("pol.iem") RETURNING comando
   OPTIONS
      FIELD ORDER UNCONSTRAINED,
      HELP FILE comando

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol0570_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0570_controle()
#---------------------------#
   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0570") RETURNING comando    

   OPEN WINDOW w_pol0570 AT 2,2  WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol0570_cria_temp()

   MENU "OPCAO"
      COMMAND "Informar" "Informar Pedido"
         HELP 2926
         MESSAGE ""
            IF pol0570_entrada_parametros() THEN
               NEXT OPTION "Processar"
            ELSE 
               NEXT OPTION "Pendencias"   
            END IF
      COMMAND "Processar" "Processa apontamento das Ordens"
         HELP 2927
         IF p_ies_pend = 'N' THEN 
            IF pol0570_processa() THEN 
               NEXT OPTION "Fim"
            END IF 
         ELSE
            ERROR 'Pedido com pendencias ou ordens nao liberadas, nao pode ser apontado'   
         END IF 
      COMMAND KEY ("N") "peNdencias" "Mostra Pendencias do pedido"
         HELP 2927
         CALL pol0570_pendencias()  
         NEXT OPTION "Fim"
      COMMAND "Erros" "Consulta erros do apontamento"
         HELP 2927
         CALL pol0570_erros() 
         NEXT OPTION "Fim"
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0570_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 509
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0570

END FUNCTION

#-----------------------#
 FUNCTION pol0570_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------------#
 FUNCTION pol0570_entrada_parametros()
#------------------------------------#

   DELETE FROM w_reservas   
   DELETE FROM w_pend
   DELETE FROM man_apont_erro_454

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0570

   INPUT BY NAME p_num_pedido WITHOUT DEFAULTS 
 
     AFTER FIELD p_num_pedido
         IF p_num_pedido IS NOT NULL THEN
            IF NOT pol0570_verifica_pedido() THEN
               ERROR "Pedido Inexistente"
               NEXT FIELD p_num_pedido
            END IF
            IF NOT pol0570_verifica_ordens() THEN
               NEXT FIELD p_num_pedido
            ELSE
               CALL pol0570_seleciona_ordens()
            END IF
         ELSE
            ERROR "Informe o numero do pedido "
            NEXT FIELD p_num_pedido
         END IF
         
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0570
        
   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      LET p_status = FALSE
      RETURN FALSE
   ELSE
      LET p_status = TRUE
      RETURN TRUE
   END IF
END FUNCTION

#----------------------------------#
 FUNCTION pol0570_cria_temp()
#----------------------------------#

   DROP TABLE w_pend;

   CREATE TEMP TABLE w_pend
   (
      num_ordem       DECIMAL(6,0),
      cod_item        CHAR(15),
      qtd_pend        DECIMAL(12,3)
   );

   DROP TABLE w_reservas;

   CREATE TEMP TABLE w_reservas
   (
      cod_item        CHAR(15),
      qtd_reser       DECIMAL(12,3),
      qtd_saldo       DECIMAL(12,3)
   );

   DELETE FROM w_reservas   
   DELETE FROM w_pend
   DELETE FROM man_apont_erro_454
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0570_verifica_pedido()
#----------------------------------#

    SELECT *
      INTO p_pedidos.*
      FROM pedidos
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION

#----------------------------------#
 FUNCTION pol0570_verifica_ordens()
#----------------------------------#
DEFINE l_erro       CHAR(1),
       l_count      SMALLINT,
       l_ies_situa  CHAR(1),
       l_ind        SMALLINT,
       l_cod_item   LIKE item.cod_item,
       l_qtd_planej LIKE ordens.qtd_boas,
       l_den_item   CHAR(34),
       l_sem_est    CHAR(1),
       l_qtd_reser  LIKE ordens.qtd_boas,
       l_qtd_item   LIKE ordens.qtd_boas,
       l_qtd_saldo  LIKE ordens.qtd_boas,
       l_qtd_boas   LIKE ordens.qtd_boas,
       l_saldo      LIKE ordens.qtd_boas,
       l_erro_est   CHAR(1)
       
    LET p_num_ped_ch  =  p_num_pedido,'%'
    LET l_ind = 1
    WHILE TRUE
      IF p_num_ped_ch[l_ind] = ' ' THEN 
         LET p_num_ped_ch = p_num_ped_ch[2,10]
      ELSE
         EXIT WHILE 
      END IF 
    END WHILE 
      
    SELECT COUNT(*)
      INTO l_count 
      FROM ordens
     WHERE cod_empresa   = p_cod_empresa
       AND num_docum LIKE (p_num_ped_ch)
       AND ies_situa = '4'

    IF l_count = 0 THEN
       ERROR "Nao existem ordens para pedido"
       RETURN FALSE
    END IF

   LET l_erro = 'N'
   LET l_erro_est = 'N'
   LET p_ies_pend = 'N'
   LET p_ind = 1
   
   DECLARE cq_ord  CURSOR FOR
    SELECT num_ordem
      FROM ordens
     WHERE cod_empresa  = p_cod_empresa
       AND num_docum    LIKE (p_num_ped_ch)
       AND num_ordem > 0 
       AND ies_situa = '4'

   FOREACH  cq_ord INTO p_num_ordem 

      SELECT cod_item,qtd_planej,qtd_boas,ies_situa
        INTO l_cod_item,l_qtd_planej,l_qtd_boas,l_ies_situa
        FROM ordens 
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem
        
      INITIALIZE p_tela[p_ind].ies_pend TO NULL 
         
      IF l_ies_situa <> '4' THEN    
         CONTINUE FOREACH 
      END IF 
      
      LET l_saldo = l_qtd_planej - l_qtd_boas
      
      IF l_saldo = 0 THEN 
         CONTINUE FOREACH
      ELSE
         LET l_qtd_planej = l_saldo
      END IF     
      
      DECLARE cq_pend CURSOR FOR 
       SELECT *
         FROM trans_pendentes  
        WHERE cod_empresa = p_cod_empresa
          AND num_ordem   = p_num_ordem
          AND qtd_movto   > 0 
      FOREACH cq_pend INTO p_trans_pendentes.*
         LET p_pend.num_ordem = p_trans_pendentes.num_ordem
         LET p_pend.cod_item  = p_trans_pendentes.cod_item 
         LET p_pend.qtd_pend  = p_trans_pendentes.qtd_movto
         LET p_tela[p_ind].ies_pend = 'P'
         INSERT INTO w_pend VALUES (p_pend.*)
         LET l_erro = 'S'
      END FOREACH 
      
      LET l_sem_est = 'N'
      DECLARE cq_est CURSOR FOR 
        SELECT * 
          FROM estrutura 
         WHERE cod_empresa  = p_cod_empresa 
           AND cod_item_pai = l_cod_item  
      FOREACH cq_est INTO p_estrutura.* 
       
         LET l_qtd_item = p_estrutura.qtd_necessaria * l_qtd_planej     
          
         SELECT qtd_reser  
           INTO l_qtd_reser
           FROM w_reservas
          WHERE cod_item =  p_estrutura.cod_item_compon
           
         IF sqlca.sqlcode <> 0 THEN 
            LET l_qtd_reser = 0 
         END IF 
          
         LET l_qtd_item = l_qtd_item + l_qtd_reser

         LET l_count = 0 
          
         SELECT COUNT(*)
           INTO l_count
           FROM estoque
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estrutura.cod_item_compon
            
         IF l_count = 0 THEN            
            LET p_pend.num_ordem = p_num_ordem
            LET p_pend.cod_item  = p_estrutura.cod_item_compon
            LET p_pend.qtd_pend  = l_qtd_item
            LET p_tela[p_ind].ies_pend = 'P'
            INSERT INTO w_pend VALUES (p_pend.*)
         END IF 
               
         SELECT (qtd_liberada - qtd_reservada)
           INTO l_qtd_saldo 
           FROM estoque
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estrutura.cod_item_compon
            
         IF l_qtd_item > l_qtd_saldo THEN 
            LET l_sem_est = 'S'
            LET l_erro_est = 'S'
         END IF     
         
         IF l_qtd_reser = 0 THEN 
            INSERT INTO w_reservas VALUES (p_estrutura.cod_item_compon,l_qtd_item,l_qtd_saldo)
         ELSE 
            UPDATE w_reservas SET qtd_reser = l_qtd_item 
             WHERE cod_item  =  p_estrutura.cod_item_compon 
         END IF 
            
      END FOREACH       
      
      IF l_sem_est = 'S' THEN     
         LET p_tela[p_ind].qtd_boas   = 0
      ELSE
         LET p_tela[p_ind].qtd_boas   = l_qtd_planej 
      END IF
          
      LET p_tela[p_ind].num_ordem  = p_num_ordem
      LET p_tela[p_ind].cod_item   = l_cod_item
      
      SELECT den_item[1,34]
        INTO l_den_item
        FROM item 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item 
      
      LET p_tela[p_ind].den_item  = l_den_item
      LET p_ind = p_ind + 1 
        
   END FOREACH   

   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY p_tela TO s_ordens.*     

   IF l_erro_est = 'S'  THEN 
   
      DECLARE cq_neg CURSOR FOR 
      SELECT UNIQUE * 
        FROM w_reservas
       WHERE qtd_saldo < qtd_reser 
      FOREACH cq_neg  INTO p_w_reservas.*
         LET p_pend.num_ordem = 0
         LET p_pend.cod_item  = p_w_reservas.cod_item 
         LET p_pend.qtd_pend  = p_w_reservas.qtd_reser - p_w_reservas.qtd_saldo
         INSERT INTO w_pend VALUES (p_pend.*)
      END FOREACH    
      ERROR "Pedido possui ordens com itens que ficaram negativos, VEJA PENDENCIAS"
##      LET p_ies_pend = 'S'
##      RETURN FALSE
   END IF 
      
   IF l_erro = 'S' THEN 
      ERROR "Pedido possui ordens com pendencias"
      LET p_ies_pend = 'S'
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF       
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0570_seleciona_ordens()
#----------------------------------#
  
  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_pol0570

  INPUT ARRAY p_tela WITHOUT DEFAULTS
         FROM s_ordens.*

   BEFORE FIELD qtd_boas
   
     LET pa_curr  = ARR_CURR()
     LET sc_curr  = SCR_LINE()   
   
    AFTER  FIELD qtd_boas 
     IF p_tela[pa_curr].qtd_boas IS NULL THEN
        LET p_tela[pa_curr].qtd_boas = 0 
     END IF

     IF p_tela[pa_curr].qtd_boas > 0 AND 
        p_tela[pa_curr].ies_pend IS NOT NULL THEN 
        ERROR 'Ordem com pendencia ou nao liberada nao pode ser apontada'
        NEXT FIELD qtd_boas
     END IF    

  AFTER INPUT
  
  END INPUT

END FUNCTION

#--------------------------#
 FUNCTION pol0570_processa()
#--------------------------#
DEFINE l_hor_ini    DECIMAL(4,2),
       l_hor_fim    DECIMAL(4,2),
       l_qtd_hor    DECIMAL(4,2),
       l_erro       CHAR(1),
       l_count      SMALLINT,
       l_dat_ch     DATE

   IF log0040_confirm(15,20,"PROCESSA APONTAMENTO?") = TRUE THEN 
      
      LET l_erro = 'N'
      
      LET l_dat_ch = TODAY 
      
      DELETE FROM apont_erro_man912
      
      FOR p_ind = 1 TO 500 
      
        IF p_tela[p_ind].num_ordem IS NULL OR 
           p_tela[p_ind].num_ordem = 0 THEN
           EXIT FOR
        END IF
        
        IF p_tela[p_ind].qtd_boas = 0  THEN
           CONTINUE FOR
        END IF    
      
        DELETE FROM man_apont_454 
         WHERE empresa = p_cod_empresa
          
        LET l_count = 0 
        SELECT * 
          INTO p_ordens.*
          FROM ordens
         WHERE cod_empresa = p_cod_empresa
           AND num_ordem   = p_tela[p_ind].num_ordem
        
        LET l_saldo = p_ordens.qtd_planej - p_ordens.qtd_boas
        
        INITIALIZE  p_man_apont_454.parada, 
                    p_man_apont_454.hor_ini_parada,
                    p_man_apont_454.hor_fim_parada,
                    p_man_apont_454.unid_funcional,
                    p_man_apont_454.dat_atualiz,
                    p_man_apont_454.eqpto, 
                    p_man_apont_454.ferramenta, 
                    p_man_apont_454.integr_min  TO NULL 
        
        LET p_man_apont_454.empresa          =   p_ordens.cod_empresa
        LET p_man_apont_454.dat_ini_producao =   l_dat_ch 
        LET p_man_apont_454.dat_fim_producao =   l_dat_ch
        LET p_man_apont_454.item             =   p_ordens.cod_item 
        LET p_man_apont_454.ordem_producao   =   p_tela[p_ind].num_ordem
        LET p_man_apont_454.qtd_boas         =   p_tela[p_ind].qtd_boas
        LET l_hor_ini = 0
        
        IF l_saldo <= p_tela[p_ind].qtd_boas THEN 
           LET p_man_apont_454.terminado    =   'S'
        ELSE
           LET p_man_apont_454.terminado    =   'N'      
        END IF     
        
        DECLARE cq_ord_oper CURSOR FOR
           SELECT *
             FROM ord_oper
            WHERE cod_empresa = p_cod_empresa
              AND num_ordem   = p_ordens.num_ordem
            ORDER BY num_seq_operac  
        FOREACH cq_ord_oper INTO p_ord_oper.*       
            LET l_qtd_hor = (p_ord_oper.qtd_horas * p_tela[p_ind].qtd_boas)/60
            LET l_hor_fim = l_hor_ini + l_qtd_hor
            LET p_man_apont_454.sequencia_operacao =   p_ord_oper.num_seq_operac 
            LET p_man_apont_454.operacao           =   p_ord_oper.cod_operac 
            LET p_man_apont_454.centro_trabalho    =   p_ord_oper.cod_cent_trab 
            LET p_man_apont_454.arranjo            =   p_ord_oper.cod_arranjo
            LET p_man_apont_454.qtd_refugo         =   0
            LET p_man_apont_454.tip_movto          =   'N'
            LET p_man_apont_454.qtd_hor            =   0
            LET p_man_apont_454.matricula          =   p_user
            LET p_man_apont_454.sit_apont          =   '1'
            LET p_man_apont_454.turno              =   '1'  
            LET p_man_apont_454.hor_inicial        =   '00:00'
            LET p_man_apont_454.hor_fim            =   '00:00' 
            LET p_man_apont_454.refugo             =   0 

            SELECT cod_local_prod
              INTO p_man_apont_454.local
              FROM ordens
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = p_ordens.num_ordem
               
           DECLARE cq_funcio CURSOR FOR                                   
            SELECT cod_uni_funcio                                         
	            FROM uni_funcional a, ord_oper b                             
		         WHERE a.cod_empresa      = p_cod_empresa                      
		       	   AND a.cod_empresa      = b.cod_empresa                       
		       	   AND a.cod_centro_custo = b.cod_cent_cust                     
		           AND b.num_ordem        = p_ordens.num_ordem        
		       	   AND b.cod_operac       = p_ord_oper.cod_operac        
		        	 AND b.num_seq_operac   = p_ord_oper.num_seq_operac  
		           AND a.dat_validade_ini <=CURRENT YEAR TO SECOND            
               AND a.dat_validade_fim >=CURRENT YEAR TO SECOND					  
           																                                
		       FOREACH cq_funcio INTO p_man_apont_454.unid_funcional      
	                                                                        
              IF SQLCA.SQLCODE<> 0 THEN                                   
                 CALL log003_err_sql("Lendo","cq_funcio" )                
	            END IF                                                      
	         			                                                          
		         IF p_man_apont_454.unid_funcional IS NOT NULL THEN          
		       		 EXIT FOREACH                                               
		       	END IF                                                        
		       			                                                          
		       END FOREACH                                                    
        
            INSERT INTO man_apont_454  VALUES (p_man_apont_454.*)
            LET l_hor_ini = l_hor_fim
            
        END FOREACH
        
        CALL pol0570_aponta() 
              
      END FOR
      
      ERROR 'TERMINO DO PROCESSAMENTO, CONSULTE TELA DE ERROS PARA CHECAGEM'
   
   END IF 
   
   RETURN TRUE 

END FUNCTION


#----------------------------#
 FUNCTION pol0570_pendencias()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05701") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05701 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ind = 1
   DECLARE cq_p1 CURSOR FOR
     SELECT *
       FROM w_pend
      ORDER BY num_ordem,cod_item
   
   FOREACH cq_p1 INTO p_pend.*
   
     IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','w_pend')
        RETURN
     END IF
     
     LET p_tela_pend[p_ind].num_ordem = p_pend.num_ordem 
     LET p_tela_pend[p_ind].cod_item  = p_pend.cod_item
     LET p_tela_pend[p_ind].qtd_pend  = p_pend.qtd_pend
     
     SELECT den_item[1,37]
       INTO p_tela_pend[p_ind].den_item
       FROM item 
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_pend.cod_item
     
     LET p_ind = p_ind + 1  
      
   END FOREACH        

   CALL SET_COUNT(p_ind - 1)

   DISPLAY ARRAY p_tela_pend TO s_pend.*

   LET p_ind = ARR_CURR()
#   LET s_ind = SCR_LINE()

   MENU "OPCAO"
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol05701
   
END FUNCTION

#------------------------#
 FUNCTION pol0570_erros()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05702") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05702 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ind = 1
   DECLARE cq_err CURSOR FOR
     SELECT *
       FROM man_apont_erro_454
      ORDER BY ordem_producao,operacao
   FOREACH cq_err INTO p_man_apont_erro_454.*
     LET p_tela_erro[p_ind].num_ordem = p_man_apont_erro_454.ordem_producao
     LET p_tela_erro[p_ind].operacao  = p_man_apont_erro_454.operacao
     LET p_tela_erro[p_ind].texto     = p_man_apont_erro_454.texto_erro[1,62]
     IF p_man_apont_erro_454.texto_erro[63,124] <> ' ' AND 
        p_man_apont_erro_454.texto_erro[63,124] IS NOT NULL THEN 
        LET p_ind = p_ind + 1   
        LET p_tela_erro[p_ind].texto  = p_man_apont_erro_454.texto_erro[63,124]      
     END IF    
     IF p_man_apont_erro_454.texto_erro[125,186] <> ' ' AND 
        p_man_apont_erro_454.texto_erro[125,186] IS NOT NULL THEN 
        LET p_ind = p_ind + 1   
        LET p_tela_erro[p_ind].texto  = p_man_apont_erro_454.texto_erro[125,186]      
     END IF    
     IF p_man_apont_erro_454.texto_erro[187,248] <> ' ' AND 
        p_man_apont_erro_454.texto_erro[187,248] IS NOT NULL THEN 
        LET p_ind = p_ind + 1   
        LET p_tela_erro[p_ind].texto  = p_man_apont_erro_454.texto_erro[187,248]      
     END IF    
     LET p_ind = p_ind + 1   
   END FOREACH        

   CALL SET_COUNT(p_ind - 1)

   DISPLAY ARRAY p_tela_erro TO s_erro.*

   LET p_ind = ARR_CURR()
#   LET s_ind = SCR_LINE()

   MENU "OPCAO"
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol05702
   
END FUNCTION

#------------------------#
FUNCTION pol0570_aponta()
#------------------------#

   DEFINE	l_rowid	DECIMAL(15,0),
          p_num_reg INTEGER,
          p_indice  INTEGER,
          p_ind     INTEGER								
			
   DEFINE p_w_apont_prod   RECORD 													
				cod_empresa     CHAR(2), 													
				cod_item        CHAR(15), 														
				num_ordem       INTEGER, 
				num_docum       CHAR(10), 
				cod_roteiro     CHAR(15), 
				num_altern      DEC(2,0), 
				cod_operacao    CHAR(5), 
				num_seq_operac  DEC(3,0), 
				cod_cent_trab   CHAR(5), 
				cod_arranjo     CHAR(5), 
				cod_equip       CHAR(15), 
				cod_ferram      CHAR(15), 
				num_operador    CHAR(15), 
				num_lote        CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno       DEC(3,0), 
				qtd_boas        DEC(10,3), 
				qtd_refug       DEC(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local       CHAR(10), 
				cod_local_est   CHAR(10), 
				dat_producao    DATE, 
				dat_ini_prod    DATE, 
				dat_fim_prod    DATE, 
				cod_tip_movto   CHAR(1), 
				estorno_total   CHAR(1), 
				ies_parada      SMALLINT, 
				ies_defeito     SMALLINT, 
				ies_sucata      SMALLINT, 
				ies_equip_min   CHAR(1), 
				ies_ferram_min  CHAR(1), 
				ies_sit_qtd     CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont       CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent   CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa    CHAR(8), 
				nom_usuario     CHAR(8), 
				num_seq_registro INTEGER, 
				observacao      CHAR(200), 
				cod_item_grade1 CHAR(15), 
				cod_item_grade2 CHAR(15), 
				cod_item_grade3 CHAR(15), 
				cod_item_grade4 CHAR(15), 
				cod_item_grade5 CHAR(15), 
				qtd_refug_ant   DECIMAL(10,3), 
				qtd_boas_ant    DECIMAL(10,3), 
				tip_servico     CHAR(1), 
				abre_transacao  SMALLINT,
				modo_exibicao_msg SMALLINT, 
				seq_reg_integra INTEGER, 
				endereco        INTEGER, 
				identif_estoque CHAR(30), 
				sku             CHAR(25),
				finaliza_operacao CHAR(1)
   END RECORD

   DEFINE  p_w_parada RECORD
				cod_parada 						CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO SECOND ,
				hor_fim_periodo 			DATETIME HOUR TO SECOND,
				hor_tot_periodo 			DECIMAL(7,2)
   END RECORD 

   DEFINE p_apont_erro_man912 RECORD LIKE apont_erro_man912.*

   CALL log085_transacao("BEGIN")

   IF NOT pol0570_w_parada() THEN
      RETURN
   END IF
   
	 DELETE FROM man_log_apo_prod	
		WHERE empresa = p_cod_empresa   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELE��O","man_log_apo_prod")
   END IF

	 CALL log085_transacao("COMMIT")
		
   DISPLAY "Aguarde... efetuando o apontamento !!!" AT 16,15
  
   DECLARE cq_apont CURSOR WITH HOLD FOR 	
    SELECT empresa,
           item,
           ordem_producao,
           operacao,
           sequencia_operacao,
           centro_trabalho,
           turno,
           arranjo,
           eqpto,
           ferramenta,
           hor_inicial,
           hor_fim,
           qtd_refugo,
           qtd_boas,
           qtd_hor,
           local,
           dat_ini_producao,
           dat_fim_producao,
           tip_movto,
           matricula,
					 hor_ini_parada,
					 hor_fim_parada, 
					 parada,
					 terminado, 
					 rowid
			FROM man_apont_454
		 WHERE empresa = p_cod_empresa
			ORDER BY ordem_producao,
			         sequencia_operacao, 
			         terminado
	 
	 FOREACH cq_apont INTO 	
	    p_w_apont_prod.cod_empresa,
			p_w_apont_prod.cod_item,
			p_w_apont_prod.num_ordem,
			p_w_apont_prod.cod_operacao ,
			p_w_apont_prod.num_seq_operac,
			p_w_apont_prod.cod_cent_trab ,
			p_w_apont_prod.cod_turno ,
			p_w_apont_prod.cod_arranjo ,
			p_w_apont_prod.cod_equip ,
			p_w_apont_prod.cod_ferram ,
			p_w_apont_prod.hor_ini_periodo ,
			p_w_apont_prod.hor_fim_periodo,
			p_w_apont_prod.qtd_refug ,
			p_w_apont_prod.qtd_boas ,
			p_w_apont_prod.qtd_total_horas ,
			p_w_apont_prod.cod_local ,
			p_w_apont_prod.dat_ini_prod ,
			p_w_apont_prod.dat_fim_prod ,
			p_w_apont_prod.cod_tip_movto ,
			p_w_apont_prod.num_operador ,
			p_w_parada.hor_ini_periodo,
			p_w_parada.hor_fim_periodo,
			p_w_parada.cod_parada,
			p_w_apont_prod.finaliza_operacao,
			l_rowid

	    IF SQLCA.SQLCODE<> 0 THEN
	    	 CALL log003_err_sql("Lendo","cq_apont:1" )
	    END IF 
			
			SELECT cod_local_estoq, 
			       num_docum, 
			       cod_roteiro, 
			       num_altern_roteiro
			  INTO p_w_apont_prod.cod_local_est,
				  	 p_w_apont_prod.num_docum,
					   p_w_apont_prod.cod_roteiro,
					   p_w_apont_prod.num_altern
			  FROM ordens
			 WHERE cod_empresa = p_cod_empresa
			   AND num_ordem   = p_w_apont_prod.num_ordem
			   AND cod_item 	 = p_w_apont_prod.cod_item

	    IF SQLCA.SQLCODE<> 0 THEN
	    	 CALL log003_err_sql("Lendo","cq_apont:2" )
	    END IF 
			
			IF LENGTH(p_w_apont_prod.cod_cent_trab) = 0 THEN 
				 LET p_w_apont_prod.cod_cent_trab = 0
			END IF 
			
			IF LENGTH(p_w_apont_prod.cod_arranjo) = 0 THEN 
				 LET p_w_apont_prod.cod_arranjo = 0
			END IF 
			
			LET p_w_apont_prod.num_lote 		= NULL
			LET p_w_apont_prod.dat_producao	=	p_w_apont_prod.dat_ini_prod
			
			DECLARE cq_funcio CURSOR FOR 
			 SELECT cod_uni_funcio 
			   FROM uni_funcional a, ord_oper b
				WHERE a.cod_empresa      = p_cod_empresa
				  AND a.cod_empresa      = b.cod_empresa
					AND a.cod_centro_custo = b.cod_cent_cust
					AND b.num_ordem        = p_w_apont_prod.num_ordem
					AND b.cod_operac       = p_w_apont_prod.cod_operacao
					AND b.num_seq_operac   = p_w_apont_prod.num_seq_operac
          AND a.dat_validade_ini <=CURRENT YEAR TO SECOND  
          AND a.dat_validade_fim >=CURRENT YEAR TO SECOND					
																		
			FOREACH cq_funcio INTO p_w_apont_prod.num_secao_requis 

    	   IF SQLCA.SQLCODE<> 0 THEN
	       	  CALL log003_err_sql("Lendo","cq_funcio" )
	       END IF 
					
					IF p_w_apont_prod.cod_cent_trab IS NOT NULL THEN
						EXIT FOREACH
					END IF 
					
			END FOREACH
			
			LET p_w_apont_prod.estorno_total = "N"

			IF p_w_apont_prod.qtd_refug > 0 THEN 
				LET p_w_apont_prod.ies_defeito = 1
			ELSE
				LET p_w_apont_prod.ies_defeito = 0
			END IF 
			
			LET p_w_apont_prod.ies_sucata 					= 0
			LET p_w_apont_prod.ies_sit_qtd 					=	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL
			LET p_w_apont_prod.num_programa 				= 'pol0570'
			LET p_w_apont_prod.nom_usuario 					= p_user
			LET p_w_apont_prod.cod_item_grade1 			= NULL
			LET p_w_apont_prod.cod_item_grade2 			= NULL
			LET p_w_apont_prod.cod_item_grade3 			= NULL
			LET p_w_apont_prod.cod_item_grade4 			= NULL
			LET p_w_apont_prod.cod_item_grade5 			= NULL
			LET p_w_apont_prod.qtd_refug_ant 				= NULL
			LET p_w_apont_prod.qtd_boas_ant 				= NULL
			LET p_w_apont_prod.abre_transacao 			= 1
			LET p_w_apont_prod.modo_exibicao_msg 		= 1
			LET p_w_apont_prod.seq_reg_integra 			= NULL
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
			LET p_w_apont_prod.ies_equip_min        = 'N' 
			LET p_w_apont_prod.ies_ferram_min       = 'N' 
			
	 	  IF manr24_cria_w_apont_prod(0)  THEN 

	 		   CALL man8246_cria_temp_fifo()
	 		   CALL man8237_cria_tables_man8237()
	 	
	 		   IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incuindo apontamento
	 			
				    LET p_hoje = TODAY 
				    
	 			    IF manr27_processa_apontamento(p_w_apont_prod.*)  THEN #processando apontamento
	 				     UPDATE man_apont_454
	 				        SET dat_atualiz = p_hoje 
	 				      WHERE rowid = l_rowid
	 				      				     
	 			    END IF 
	 	     END IF 
	 	  END IF
	 	  
	 		CALL log085_transacao("BEGIN")
	 		
		 	DECLARE cq_erro CURSOR FOR 	
		 	 SELECT ordem_producao,
		 	        operacao,
		 	        texto_resumo  	
		 		 FROM man_log_apo_prod	
		 		WHERE empresa = p_cod_empresa
		  
		  FOREACH cq_erro INTO 	
		  				p_num_ordem,
		  				p_cod_operacao,
		  				m_msg

			   IF STATUS <> 0 THEN
	          CALL log003_err_sql("Lendo","cq_erro")
	          CALL log085_transacao("ROLLBACK")
	          EXIT FOREACH
	       END IF
		  	
         INSERT INTO apont_erro_man912
          VALUES (p_cod_empresa,
                  p_num_ordem,
                  p_cod_operacao,
                  p_w_apont_prod.num_seq_operac,
                  m_msg)


  			 IF STATUS <> 0 THEN
	          CALL log003_err_sql("Inclusao","apont_erro_man912")
	       END IF  

		  END FOREACH

      DELETE FROM man_log_apo_prod	
		 	 WHERE empresa = p_cod_empresa

  		IF STATUS <> 0 THEN
	       CALL log003_err_sql("Deletando","man_log_apo_prod")
	    END IF  

     	CALL log085_transacao("COMMIT")
 																		
   END FOREACH
  
   INSERT INTO man_apont_erro_454
    SELECT * FROM apont_erro_man912   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUS�O","man_apont_erro_454")
   END IF
  
END FUNCTION

#---------------------------#
 FUNCTION pol0570_w_parada()#
#---------------------------#
	
	DROP TABLE w_parada

	CREATE TEMP TABLE w_parada (
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)

	IF SQLCA.SQLCODE <> 0 THEN
	  CALL log003_err_sql('criando','w_parada')
		RETURN FALSE
	END IF 

	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(3,0)
		)

	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 
	
END FUNCTION 

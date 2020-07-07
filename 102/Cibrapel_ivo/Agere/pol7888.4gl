#----------------------------------------------------#
# PROGRAMA: pol7888 - BASE PEDIDO OU CLIENTE         #
# OBJETIVO: atualizar ped_itens_texto                #
#----------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa   CHAR(02),
         p_cancel        INTEGER,
         p_num_nf        LIKE wfat_item.num_nff,
         p_qtd_item      LIKE wfat_item.qtd_item,
         p_qtd_res_at    LIKE estoque.qtd_reservada,
         p_cod_nat_oper  LIKE nat_operacao.cod_nat_oper,
         p_qtd_pecas_romaneio  LIKE ped_itens.qtd_pecas_romaneio,
         p_num_pedido    LIKE pedidos.num_pedido,
         p_num_nff_char  CHAR(06),                 
         p_ies_processou SMALLINT,
         comando         CHAR(80),
         p_ind           SMALLINT,
         p_count         SMALLINT,
         p_resposta      CHAR(1),
         p_baixa_est     CHAR(1),
         p_data          DATE,
         p_hora          CHAR(05),
         p_versao        CHAR(18),               
         p_ped_itens_texto       RECORD LIKE ped_itens_texto.*,
         p_item_chapa_885        RECORD LIKE item_chapa_885.*,
         p_item_bobina_885       RECORD LIKE item_bobina_885.*,
         p_item_caixa_885        RECORD LIKE item_caixa_885.* 

 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(080)
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  CALL log0180_conecta_usuario()
  LET p_versao = "POL7888-05.10.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol7888.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

    CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol7888_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol7888_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol7888") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol78880 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Processar" "Processa atualizacao"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF pol7888_processa() THEN
         ERROR "Processamento Efetuado com Sucesso"
         NEXT OPTION "Fim"
      ELSE
         ERROR "Processamento Cancelado"
      END IF
      
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Sai do programa"
      IF p_ies_processou = FALSE THEN
         ERROR "Funcao deve ser processada"
         NEXT OPTION "Processar"
      ELSE
         EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_pol78880
END FUNCTION

#-----------------------------#
 FUNCTION pol7888_processa()
#-----------------------------#
DEFINE l_count INTEGER,
       l_den_texto CHAR(80),
       l_num_oc    CHAR(80)   

LET p_ies_processou = TRUE
LET p_hora = TIME
DECLARE cq_ped CURSOR FOR 
   SELECT *  
     FROM ped_itens_texto
    WHERE num_sequencia = 0
FOREACH cq_ped INTO p_ped_itens_texto.* 
  
   LET p_ies_situa = 1 

   DISPLAY " Pedido seq 0 : "  AT  7,5
   DISPLAY p_ped_itens_texto.num_pedido AT 7,15

   LET l_count = 0
   SELECT COUNT(*)
     INTO l_count 
     FROM ped_item_texto_885
    WHERE cod_empresa   =  p_ped_itens_texto.cod_empresa
      AND num_pedido    =  p_ped_itens_texto.num_pedido
      AND num_sequencia =  p_ped_itens_texto.num_sequencia
      
   IF l_count = 0 THEN    
      INSERT INTO ped_item_texto_885 VALUES (p_ped_itens_texto.cod_empresa,
                                             p_ped_itens_texto.num_pedido,
                                             p_ped_itens_texto.num_sequencia,
                                             p_ped_itens_texto.den_texto_1,
                                             p_ped_itens_texto.den_texto_2,
                                             p_ped_itens_texto.den_texto_3,
                                             p_ped_itens_texto.den_texto_4,
                                             p_ped_itens_texto.den_texto_5) 
   END IF                                           
END FOREACH                                             
                                             
UPDATE ped_itens_texto SET den_texto_1=NULL,
                           den_texto_2=NULL,
                           den_texto_3=NULL,
                           den_texto_4=NULL,
                           den_texto_5=NULL 
 WHERE num_sequencia = 0 

DECLARE cq_it_ch CURSOR FOR
   SELECT *  
     FROM item_chapa_885
FOREACH cq_it_ch INTO p_item_chapa_885.*

   DISPLAY " chapa seq 1 : "  AT  7,5
   DISPLAY p_item_chapa_885.num_pedido AT 7,15

   LET l_den_texto = p_item_chapa_885.largura,' X ',p_item_chapa_885.comprimento, ' MM'
   
   IF p_item_chapa_885.num_pedido_cli IS NOT NULL THEN 
      LET l_num_oc = 'OC: ',p_item_chapa_885.num_pedido_cli
   ELSE
      INITIALIZE l_num_oc TO NULL
   END IF 
         
   LET l_count = 0 
   SELECT COUNT(*) 
     INTO l_count
     FROM ped_itens_texto
    WHERE cod_empresa   =  p_item_chapa_885.cod_empresa
      AND num_pedido    =  p_item_chapa_885.num_pedido
      AND num_sequencia =  p_item_chapa_885.num_sequencia
   IF l_count > 0 THEN 
     UPDATE ped_itens_texto SET den_texto_1 = l_den_texto,
                                den_texto_2 = l_num_oc 
      WHERE cod_empresa   =  p_item_chapa_885.cod_empresa
        AND num_pedido    =  p_item_chapa_885.num_pedido
        AND num_sequencia =  p_item_chapa_885.num_sequencia
   ELSE
     INSERT INTO  ped_itens_texto VALUES (p_item_chapa_885.cod_empresa,
                                          p_item_chapa_885.num_pedido,
                                          p_item_chapa_885.num_sequencia,
                                          l_den_texto,
                                          l_num_oc,
                                          '',
                                          '',
                                          '')
   END IF 
 
END FOREACH

DECLARE cq_it_bo CURSOR FOR
   SELECT *  
     FROM item_bobina_885
FOREACH cq_it_bo INTO p_item_bobina_885.*

   DISPLAY " bobina seq 1 : "  AT  7,5
   DISPLAY p_item_bobina_885.num_pedido AT 7,15
 
   LET l_den_texto = 'LARGURA : ',p_item_bobina_885.largura,' MM '

   IF p_item_bobina_885.num_pedido_cli IS NOT NULL THEN 
      LET l_num_oc = 'OC: ',p_item_bobina_885.num_pedido_cli
   ELSE
      INITIALIZE l_num_oc TO NULL
   END IF 
 
   LET l_count = 0 
   SELECT COUNT(*) 
     INTO l_count
     FROM ped_itens_texto
    WHERE cod_empresa   =  p_item_bobina_885.cod_empresa
      AND num_pedido    =  p_item_bobina_885.num_pedido
      AND num_sequencia =  p_item_bobina_885.num_sequencia
   IF l_count > 0 THEN 
     UPDATE ped_itens_texto SET den_texto_1 = l_den_texto,
                                den_texto_2 = l_num_oc 
      WHERE cod_empresa   =  p_item_bobina_885.cod_empresa
        AND num_pedido    =  p_item_bobina_885.num_pedido
        AND num_sequencia =  p_item_bobina_885.num_sequencia
   ELSE
     INSERT INTO  ped_itens_texto VALUES (p_item_bobina_885.cod_empresa,
                                          p_item_bobina_885.num_pedido,
                                          p_item_bobina_885.num_sequencia,
                                          l_den_texto,
                                          l_num_oc,
                                          '',
                                          '',
                                          '')
   END IF 
 
END FOREACH

DECLARE cq_it_cx CURSOR FOR
   SELECT *  
     FROM item_caixa_885
FOREACH cq_it_cx INTO p_item_chapa_885.*

   DISPLAY " caixa seq 1 : "  AT  7,5
   DISPLAY p_item_caixa_885.num_pedido AT 7,15

   IF p_item_chapa_885.num_pedido_cli IS NOT NULL THEN 
      LET l_num_oc = 'OC: ',p_item_chapa_885.num_pedido_cli
   ELSE
      INITIALIZE l_num_oc TO NULL
   END IF 
 
   LET l_count = 0 
   SELECT COUNT(*) 
     INTO l_count
     FROM ped_itens_texto
    WHERE cod_empresa   =  p_item_caixa_885.cod_empresa
      AND num_pedido    =  p_item_caixa_885.num_pedido
      AND num_sequencia =  p_item_caixa_885.num_sequencia
   IF l_count > 0 THEN 
     UPDATE ped_itens_texto SET den_texto_1 = '',
                                den_texto_2 = l_num_oc 
      WHERE cod_empresa   =  p_item_caixa_885.cod_empresa
        AND num_pedido    =  p_item_caixa_885.num_pedido
        AND num_sequencia =  p_item_caixa_885.num_sequencia
   ELSE
     INSERT INTO  ped_itens_texto VALUES (p_item_caixa_885.cod_empresa,
                                          p_item_caixa_885.num_pedido,
                                          p_item_caixa_885.num_sequencia,
                                          '',
                                          l_num_oc,
                                          '',
                                          '',
                                          '')
   END IF 
 
END FOREACH
   
IF p_ies_situa = 1  THEN 
   RETURN TRUE  
ELSE
   ERROR "Dados nao encontrado na tabela WFAT_MESTRE"
   SLEEP 2
   RETURN FALSE
END IF
END FUNCTION  

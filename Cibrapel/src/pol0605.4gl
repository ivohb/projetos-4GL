#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O LOGIX X TRIM                                     #
# PROGRAMA: POL0605                                                     #
# OBJETIVO: EXPORTA��O DE CLIENTES P/ O TRIM                            #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 06/06/2007                                                  #
# CONVERS�O 10.02: 17/07/2014 - IVO                                     #
# FUN��ES: FUNC002                                                      #
#-----------------------------------------------------------------------#


DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
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
          p_msg                CHAR(80),
          p_erro               CHAR(10)
   
   
END GLOBALS
          
   DEFINE p_cod_repres         LIKE representante.cod_repres,
          p_nom_repres         LIKE representante.raz_social,
          p_den_cidade         LIKE cidades.den_cidade,
          p_cod_uni_feder      LIKE cidades.cod_uni_feder,
          p_datatualizacao     LIKE cliente_885.datatualizacao,
          p_codrepres          LIKE representante.cod_repres,
          p_dat_trim           CHAR(20),
          p_dat_logix          CHAR(20),
          p_num_seq_loc        INTEGER,
          p_cod_cliente        CHAR(15),
          p_num_seq            INTEGER,
          p_numsequencia       INTEGER,
          p_tip_transp         CHAR(02),
          p_tip_transp_auto    CHAR(02)


   DEFINE p_clientes           RECORD LIKE clientes.*,
          p_cliente_885        RECORD LIKE cliente_885.*,
          p_loc_entrega_885    RECORD LIKE loc_entrega_885.*

   DEFINE p_cliente_repres     RECORD
          cod_nivel1           LIKE cli_canal_venda.cod_nivel_1,
          cod_nivel2           LIKE cli_canal_venda.cod_nivel_2,
          cod_nivel3           LIKE cli_canal_venda.cod_nivel_3,
          cod_nivel4           LIKE cli_canal_venda.cod_nivel_4,
          cod_nivel5           LIKE cli_canal_venda.cod_nivel_5,
          cod_nivel6           LIKE cli_canal_venda.cod_nivel_6,
          cod_nivel7           LIKE cli_canal_venda.cod_nivel_7,
          ies_nivel            LIKE cli_canal_venda.ies_nivel
   END RECORD


   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   
   DEFER INTERRUPT
   LET p_versao = "pol0605-10.02.06  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0605.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '01' 
   #LET p_user = 'pol0605'  
   #LET p_status = 0
   
   IF p_status = 0  THEN
      CALL pol0605_controle()
   END IF
   
END MAIN

#------------------------------#
FUNCTION pol0605_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'pol0605'  #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol0605_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol0605_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0605") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0605 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0605_exib_mensagem()

   IF pol0605_exporta_cli_matriz() THEN
      IF pol0605_exporta_cli_filial() THEN
         LET p_msg = 'Exportacao efetuada com sucesso'
      END IF
   END IF

   CALL POL0605_grava_msg()
   
   CLOSE WINDOW w_pol0605
   
END FUNCTION

#---------------------------#
FUNCTION POL0605_grava_msg()#
#---------------------------#
   
   DEFINE p_dat_hor DATETIME YEAR TO SECOND
   
   LET p_dat_hor = CURRENT
   
   INSERT INTO cliente_msg_885
    VALUES(p_dat_hor, p_msg)

END FUNCTION       

#------------------------------#
FUNCTION pol0605_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

END FUNCTION

#------------------------------------#
FUNCTION pol0605_exporta_cli_matriz()
#------------------------------------#

   SELECT substring(par_vdp_txt,215,2)
     INTO p_tip_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo par_vdp'
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo par_vdp_pad'
      RETURN FALSE
   END IF
   
   SELECT MAX(numsequencia)
     INTO p_num_seq
     FROM cliente_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cliente_885:sequencia'
      RETURN FALSE
   END IF
     
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo loc_entrega_885:sequencia'
      RETURN FALSE
   END IF
     
   IF p_num_seq_loc IS NULL THEN
      LET p_num_seq_loc = 0
   END IF

   DECLARE cq_cli_matriz CURSOR WITH HOLD FOR
    SELECT * 
      FROM clientes
     WHERE cod_cliente_matriz IS NULL 
        OR len(cod_cliente_matriz) = 0
        OR cod_cliente_matriz = ' '
              
   FOREACH cq_cli_matriz INTO p_clientes.*

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo clientes:cq_cli_matriz'
         RETURN FALSE
      END IF

      LET p_cod_cliente = p_clientes.cod_cliente

      LET pr_men[1].mensagem = p_cod_cliente
      CALL pol0605_exib_mensagem()

      SELECT numsequencia,
             datatualizacao,
             codrepresentante
        INTO p_numsequencia,
             p_datatualizacao,
             p_codrepres
        FROM cliente_885
       WHERE codcliente = p_cod_cliente
      
      IF STATUS = 100 THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol0605_insere_cliente_885() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      ELSE
         IF STATUS = 0 THEN
            
            LET p_dat_logix = p_clientes.dat_atualiz
            LET p_dat_logix = p_dat_logix[1,10]
            #LET p_dat_logix = p_dat_logix[7,10],'-',p_dat_logix[4,5],'-',p_dat_logix[1,2]
            LET p_dat_trim  = p_datatualizacao
            LET p_dat_trim  = p_dat_trim[1,10]
            IF p_dat_trim <> p_dat_logix THEN
               CALL log085_transacao("BEGIN")
               IF NOT pol0605_atualiza_cliente_885() THEN
                  CALL log085_transacao("ROLLBACK")
                  RETURN FALSE
               END IF
               CALL log085_transacao("COMMIT")
            END IF
            
            CALL pol0605_exp_repres() RETURNING p_status
         ELSE
            LET p_erro = STATUS
            LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cliente_885:cq_cli_matriz'
            RETURN FALSE
         END IF
      END IF   
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0605_exp_repres()
#---------------------------#

   DEFINE p_exp_repres SMALLINT,
          p_dat_atu    DATE
   
   LET p_exp_repres = FALSE
   LET p_dat_atu = TODAY
   
   IF p_codrepres IS NULL THEN
      LET p_codrepres = 0
   END IF
   
   LET p_cod_repres = NULL 
   
   IF NOT pol0605_le_cli_canal_venda() THEN
      RETURN FALSE
   END IF
   
   IF p_cod_repres IS NOT NULL THEN
      IF p_cod_repres <> p_codrepres THEN
         IF NOT pol0605_le_represenante() THEN
            RETURN FALSE
         END IF
         LET p_exp_repres = TRUE
      END IF
   ELSE
      IF p_codrepres <> 0 THEN
         LET p_exp_repres = TRUE
      END IF
   END IF
   
   IF p_exp_repres THEN
   
      UPDATE cliente_885
         SET codrepresentante  = p_cod_repres,
             nomerepresentante = p_nom_repres,
             tiporegistro   = 'A',
             statusregistro = '0',
             datatualizacao = p_dat_atu
       WHERE numsequencia     = p_numsequencia       

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' atualizando cliente_885'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0605_insere_cliente_885()
#------------------------------------#
   
   INITIALIZE p_cod_repres, p_nom_repres TO NULL
   
   IF NOT pol0605_le_cli_canal_venda() THEN
      RETURN FALSE
   END IF
   
   IF p_cod_repres IS NOT NULL THEN
      IF NOT pol0605_le_represenante() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_num_seq = p_num_seq + 1   

   LET p_cliente_885.numsequencia      = p_num_seq
   LET p_cliente_885.codcliente        = p_cod_cliente
   LET p_cliente_885.nomcliente        = p_clientes.nom_reduzido
   LET p_cliente_885.razaosocial       = p_clientes.nom_cliente
   LET p_cliente_885.cod_prefer        = NULL
   LET p_cliente_885.codseguimento     = NULL
   LET p_cliente_885.nomseguimento     = NULL
   LET p_cliente_885.codrepresentante  = p_cod_repres
   LET p_cliente_885.nomerepresentante = p_nom_repres
   LET p_cliente_885.tiporegistro      = 'I'
   LET p_cliente_885.statusregistro    = '0'
   LET p_cliente_885.datatualizacao    = p_clientes.dat_atualiz

   IF p_clientes.num_cgc_cpf[13,16] = '0000' THEN
      LET p_cliente_885.tipopessoa = 'F'
   ELSE
      LET p_cliente_885.tipopessoa = 'J'
   END IF
   
   IF p_clientes.cod_tip_cli = p_tip_transp OR
      p_clientes.cod_tip_cli = p_tip_transp_auto THEN
      LET p_cliente_885.tipocliente = 'T'
   ELSE
      LET p_cliente_885.tipocliente = 'C'
   END IF
   
   INSERT INTO cliente_885
    VALUES(p_cliente_885.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' inserindo cliente_885'
      RETURN FALSE
   END IF
   
   IF NOT pol0605_insere_loc_entrega_885() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol0605_insere_loc_entrega_885()
#----------------------------------------#
   
   IF NOT pol0605_le_cidades() THEN
      RETURN FALSE
   END IF
   
   LET p_num_seq_loc = p_num_seq_loc + 1   
   LET p_loc_entrega_885.numsequencia   = p_num_seq_loc
   LET p_loc_entrega_885.codcliente     = p_cod_cliente              ## cliente matriz
   LET p_loc_entrega_885.razaosocial    = p_clientes.nom_cliente
   LET p_loc_entrega_885.nrloja         = p_clientes.cod_cliente     ## cod_cliente
   LET p_loc_entrega_885.nrlocalentrega = p_clientes.cod_cliente
   LET p_loc_entrega_885.numcnpj        = p_clientes.num_cgc_cpf
   LET p_loc_entrega_885.inscestatual   = p_clientes.ins_estadual
   LET p_loc_entrega_885.email          = NULL
   LET p_loc_entrega_885.endereco       = p_clientes.end_cliente
   LET p_loc_entrega_885.bairro         = p_clientes.den_bairro
   LET p_loc_entrega_885.cep            = p_clientes.cod_cep
   LET p_loc_entrega_885.telefone1      = p_clientes.num_telefone
   LET p_loc_entrega_885.telefone2      = NULL
   LET p_loc_entrega_885.municipio      = p_den_cidade
   LET p_loc_entrega_885.uf             = p_cod_uni_feder
   LET p_loc_entrega_885.codcidade      = p_clientes.cod_cidade
   LET p_loc_entrega_885.distancia      = NULL
   LET p_loc_entrega_885.tempoviagem    = NULL
   LET p_loc_entrega_885.tiporegistro   = 'I'
   LET p_loc_entrega_885.statusregistro = '0'
   LET p_loc_entrega_885.datatualizacao = p_clientes.dat_atualiz
   LET p_loc_entrega_885.nomprograma    = 'POL0605'
   LET p_loc_entrega_885.numpedido      = 0
   
   INSERT INTO loc_entrega_885
    VALUES(p_loc_entrega_885.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' inserindo loc_entrega_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION

#--------------------------------------#
FUNCTION pol0605_atualiza_cliente_885()
#--------------------------------------#

   UPDATE cliente_885
      SET nomcliente     = p_clientes.nom_reduzido,
          razaosocial    = p_clientes.nom_cliente,
          tiporegistro   = 'A',
          statusregistro = '0',
          datatualizacao = p_clientes.dat_atualiz
    WHERE numsequencia     = p_numsequencia       

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' atualizando cliente_885'
      RETURN FALSE
   END IF

   IF NOT pol0605_atualiza_loc_entrega_885() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol0605_atualiza_loc_entrega_885()
#------------------------------------------#

   IF NOT pol0605_le_cidades() THEN
      RETURN FALSE
   END IF

   UPDATE loc_entrega_885
      SET razaosocial    = p_clientes.nom_cliente,
          numcnpj        = p_clientes.num_cgc_cpf,
          inscestatual   = p_clientes.ins_estadual,
          endereco       = p_clientes.end_cliente,
          bairro         = p_clientes.den_bairro,
          cep            = p_clientes.cod_cep,
          telefone1      = p_clientes.num_telefone,
          municipio      = p_den_cidade,
          codcidade      = p_clientes.cod_cidade,
          uf             = p_cod_uni_feder,
          tiporegistro   = 'A',
          statusregistro = '0',
          datatualizacao = p_clientes.dat_atualiz
    WHERE codcliente     = p_cod_cliente
      AND numcnpj        = p_clientes.num_cgc_cpf

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' atualizando loc_entrega_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0605_exporta_cli_filial()
#------------------------------------#

   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo loc_entrega_885:numsequencia'
      RETURN FALSE
   END IF
     
   IF p_num_seq_loc IS NULL THEN
      LET p_num_seq_loc = 0
   END IF

   DECLARE cq_cli_filial CURSOR WITH HOLD FOR
    SELECT * 
      FROM clientes
     WHERE cod_cliente_matriz IS NOT NULL 
       AND len(cod_cliente_matriz) > 0
       AND cod_cliente_matriz <> ' '
           
   FOREACH cq_cli_filial INTO p_clientes.*

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cq_cli_filial'
         RETURN FALSE
      END IF

      LET p_cod_cliente = p_clientes.cod_cliente_matriz

      LET pr_men[1].mensagem = p_cod_cliente
      CALL pol0605_exib_mensagem()

      SELECT datatualizacao,
             numsequencia
        INTO p_datatualizacao,
             p_numsequencia
        FROM loc_entrega_885
       WHERE codcliente = p_cod_cliente
         AND numcnpj    = p_clientes.num_cgc_cpf
         #AND (nrlocalentrega IS NULL OR len(nrlocalentrega) = 0)
      
      IF STATUS = 100 THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol0605_insere_loc_entrega_885() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      ELSE
         IF STATUS = 0 THEN
            LET p_dat_logix = p_clientes.dat_atualiz
            LET p_dat_logix = p_dat_logix[1,10]
            #LET p_dat_logix = p_dat_logix[7,10],'-',p_dat_logix[4,5],'-',p_dat_logix[1,2]
            LET p_dat_trim  = p_datatualizacao
            LET p_dat_trim  = p_dat_trim[1,10]
            IF p_dat_trim <> p_dat_logix THEN
               CALL log085_transacao("BEGIN")
               IF NOT pol0605_atualiza_loc_entrega_885() THEN
                  CALL log085_transacao("ROLLBACK")
                  RETURN FALSE
               END IF
               CALL log085_transacao("COMMIT")
            END IF
         ELSE
            LET p_erro = STATUS
            LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo loc_entrega_885:cq_cli_filial'
            RETURN FALSE
         END IF
      END IF   
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0605_le_cli_canal_venda()
#------------------------------------#

   DECLARE cq_cliente_repres CURSOR FOR

   SELECT cod_nivel_1,
          cod_nivel_2,
          cod_nivel_3,
          cod_nivel_4,
          cod_nivel_5,
          cod_nivel_6,
          cod_nivel_7,
          ies_nivel
     FROM cli_canal_venda
    WHERE cod_cliente = p_clientes.cod_cliente

   FOREACH cq_cliente_repres INTO
           p_cliente_repres.cod_nivel1,
           p_cliente_repres.cod_nivel2,
           p_cliente_repres.cod_nivel3,
           p_cliente_repres.cod_nivel4,
           p_cliente_repres.cod_nivel5,
           p_cliente_repres.cod_nivel6,           
           p_cliente_repres.cod_nivel7,
           p_cliente_repres.ies_nivel

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cq_cliente_repres'
         RETURN FALSE
      END IF
      
           
      CASE p_cliente_repres.ies_nivel
           
           WHEN '01'
              LET p_cod_repres = p_cliente_repres.cod_nivel1
           WHEN '02'
              LET p_cod_repres = p_cliente_repres.cod_nivel2
           WHEN '03'
              LET p_cod_repres = p_cliente_repres.cod_nivel3
           WHEN '04'
              LET p_cod_repres = p_cliente_repres.cod_nivel4
           WHEN '05'
              LET p_cod_repres = p_cliente_repres.cod_nivel5
           WHEN '06'
              LET p_cod_repres = p_cliente_repres.cod_nivel6
           WHEN '07'
              LET p_cod_repres = p_cliente_repres.cod_nivel7
      END CASE

      EXIT FOREACH
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0605_le_represenante()
#---------------------------------#
   
   DEFINE p_raz_social LIKE representante.raz_social

   SELECT nom_guerra,
          raz_social
     INTO p_nom_repres,
          p_raz_social
     FROM representante
    WHERE cod_repres = p_cod_repres

   IF STATUS <> 0 THEN
      INITIALIZE p_nom_repres, p_raz_social TO NULL
   END IF
   
   IF p_nom_repres IS NULL THEN
      LET p_nom_repres = p_raz_social
   END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0605_le_cidades()
#----------------------------#

   SELECT den_cidade,
          cod_uni_feder
     INTO p_den_cidade,
          p_cod_uni_feder
     FROM cidades
    WHERE cod_cidade = p_clientes.cod_cidade

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cidades'
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#-------------------------------------------------------------------#
# PROGRAMA: pol0827                                                 #
# OBJETIVO: FRETE DE SAIDA - RELACIONAMENTO                         #
# DATA....: 18/03/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_val_icms_c         DECIMAL(10,2),
          p_imprimiu           SMALLINT,
          p_msg                CHAR(70),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_ies_conf           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_query              CHAR(600),
          where_clause         CHAR(500),
          p_ies_efetivado      CHAR(01),
          p_salto              SMALLINT


   DEFINE p_num_docum          LIKE nf_sup.num_nf,
          p_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_val_tot_icms_nf_c  LIKE nf_sup.val_tot_icms_nf_c,
          p_val_tot_nf_c       LIKE nf_sup.val_tot_nf_c,
          p_ies_situacao       LIKE nf_mestre.ies_situacao,
          p_ser_nff            LIKE nf_mestre.ser_nff,
          p_num_om             LIKE ordem_montag_mest.num_om,
          p_tip_transp         CHAR(02),
          p_tip_transp_auto    CHAR(02),
          p_val_frete          DECIMAL(12,2),
          p_val_compl          DECIMAL(12,2),
          p_val_normal         DECIMAL(12,2),
          p_val_ger            DECIMAL(12,2),
          p_tot_nor            DECIMAL(12,2),
          p_tot_ger            DECIMAL(12,2)
          
   DEFINE p_nota         RECORD
          num_nfe        LIKE nfe_x_nff_885.num_nfe,
          cod_for        LIKE fornecedor.cod_fornecedor,
          nom_for        LIKE fornecedor.raz_social,
          dat_nfe        LIKE nf_sup.dat_emis_nf,
          ser_nfe        LIKE nfe_x_nff_885.ser_nfe,
          ssr_nfe        LIKE nfe_x_nff_885.ser_nfe,
          esp_nfe        LIKE nf_sup.ies_especie_nf,
          val_nfe        LIKE nf_sup.val_tot_nf_c,
          val_icm        LIKE nf_sup.val_tot_nf_c,
          ies_validado   CHAR(01)
   END RECORD

   DEFINE pr_nota        ARRAY[1000] OF RECORD
          num_nff        LIKE nf_mestre.num_nff,
          pes_tot_bruto  DECIMAL(05,3),
          nom_reduzido   LIKE clientes.nom_reduzido,
          den_cidade     LIKE cidades.den_cidade
   END RECORD

   DEFINE p_num_nff      LIKE nf_mestre.num_nff,
          p_nom_cliente  LIKE clientes.nom_cliente,
          p_cod_cliente  LIKE nf_mestre.cod_cliente 
   
   DEFINE p_tela         RECORD
          num_nfe        LIKE nfe_x_nff_885.num_nfe,
          num_conhec     LIKE frete_sup_x_nff.num_conhec
   END RECORD 
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0827-05.10.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0827.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0827_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0827_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0827") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0827 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0827_le_parametros() THEN
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Informar" "Informar Nota de Serviço ou Conhecimento"
         IF log005_seguranca(p_user,"VDP","pol0827","IN")  THEN
            CALL pol0827_nota_informar() RETURNING p_status
            IF p_status THEN
               ERROR 'Parâmetros informados com sucesso'
               NEXT OPTION 'Modificar'
            ELSE
               CLEAR FORM
               DISPLAY p_cod_empresa TO cod_empresa
               ERROR "Operação Cancelada !!!"
            END IF
         END IF 
      COMMAND "Consultar" "Consulta relacionamento com as notas de saída"
         CALL pol0827_consulta() 
         CLOSE WINDOW w_pol08271
      
      COMMAND "Modificar" "Modifica relacionamento com as notas de saída"
         IF p_ies_cons THEN
            IF p_nota.ies_validado = 'N' THEN
               CALL pol0827_notas_modificar() RETURNING p_status
               IF p_status THEN
                  ERROR 'Operação efetuada com sucesso'
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            ELSE
               LET p_msg = 'Relacionamento já efetivado!!!... modificação não permitida'
               CALL log0030_mensagem(p_msg,'exclamation')
               NEXT OPTION 'Informar'
            END IF
         ELSE
            ERROR 'Informe previamente os parâmetros!!!'
            NEXT OPTION 'Informar'
         END IF 
      COMMAND "Listar" "Listagem do Relacionamento"
         IF p_ies_cons THEN
            CALL pol0827_listagem()
         ELSE
            ERROR 'Informe previamente os parâmetros!!!'
            NEXT OPTION 'Informar'
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0827

END FUNCTION

#-------------------------------#
FUNCTION pol0827_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   SELECT substring(par_vdp_txt,215,2)
     INTO p_tip_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0827_nota_informar()
#-------------------------------#

   INITIALIZE p_nota TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_nota.* WITHOUT DEFAULTS

      AFTER FIELD num_nfe
         IF p_nota.num_nfe IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD num_nfe       
         END IF 

         SELECT COUNT(num_nf)
           INTO p_count
           FROM nf_sup
          WHERE cod_empresa     = p_cod_empresa
            AND num_nf          = p_nota.num_nfe
            AND (ies_especie_nf = 'NFS' OR 
                 ies_especie_nf = 'CON')
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','nf_sup:1')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            ERROR "Nota fiscal inexistente!!!"
            NEXT FIELD num_nfe       
         END IF 

      AFTER FIELD cod_for

         IF p_nota.cod_for IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD cod_for       
         END IF 

         SELECT raz_social
           INTO p_nota.nom_for
           FROM fornecedor
          WHERE cod_fornecedor = p_nota.cod_for
         
         IF STATUS <> 0 THEN
            ERROR 'Fornecedor inexistente!!!'
            NEXT FIELD cod_for
         END IF

         SELECT ser_nf,
                ssr_nf,
                ies_especie_nf,
                dat_emis_nf,
                val_tot_nf_d, 
                val_tot_nf_c, 
                val_tot_icms_nf_d,
                val_tot_icms_nf_c,
                num_aviso_rec
           INTO p_nota.ser_nfe,
                p_nota.ssr_nfe,
                p_nota.esp_nfe,
                p_nota.dat_nfe,
                p_nota.val_nfe,
                p_val_tot_nf_c,
                p_nota.val_icm,
                p_val_tot_icms_nf_c,
                p_num_aviso_rec
           FROM nf_sup
          WHERE cod_empresa     = p_cod_empresa
            AND num_nf          = p_nota.num_nfe
            AND cod_fornecedor  = p_nota.cod_for
            AND (ies_especie_nf = 'NFS' OR 
                 ies_especie_nf = 'CON')
            
         IF STATUS <> 0 THEN
            LET p_msg = 'Nota de entrada inexistente!... ',
                        'Informe corretamente os parâmetros.'
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD num_nfe
         END IF
         
         IF p_nota.val_nfe = 0  THEN
            LET p_nota.val_nfe = p_val_tot_nf_c
         END IF
         
         IF p_nota.val_icm = 0  THEN
            LET p_nota.val_icm = p_val_tot_icms_nf_c
         END IF
         
         SELECT cod_empresa
           FROM nf_sup
          WHERE cod_empresa    = p_cod_emp_ger
            AND num_nf         = p_nota.num_nfe
            AND ser_nf         = p_nota.ser_nfe
            AND ssr_nf         = p_nota.ssr_nfe
            AND cod_fornecedor = p_nota.cod_for
         
         IF STATUS = 0 THEN
            LET p_nota.ies_validado = 'S'
         ELSE
            LET p_nota.ies_validado = 'N'
         END IF
         
         DISPLAY p_nota.ser_nfe TO ser_nfe
         DISPLAY p_nota.ssr_nfe TO ssr_nfe
         DISPLAY p_nota.esp_nfe TO esp_nfe
         DISPLAY p_nota.val_nfe TO val_nfe
         DISPLAY p_nota.val_icm TO val_icm
         DISPLAY p_nota.dat_nfe TO dat_nfe
         DISPLAY p_nota.nom_for TO nom_for

      ON KEY (control-z)
         CALL pol0827_popup()

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0827_exibe_notas() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_cons = TRUE
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0827_exibe_notas()
#------------------------------#

   DEFINE p_op CHAR(01)
   
   INITIALIZE pr_nota TO NULL

      INPUT ARRAY pr_nota 
         WITHOUT DEFAULTS FROM sr_nota.*
      BEFORE INPUT
         EXIT INPUT
      END INPUT
   
   LET p_index = 1

   DECLARE cq_n_x_s CURSOR FOR
    SELECT num_nff
      FROM nfe_x_nff_885
     WHERE cod_empresa = p_cod_empresa
       AND num_nfe     = p_nota.num_nfe
       AND ser_nfe     = p_nota.ser_nfe
       AND ssr_nfe     = p_nota.ssr_nfe
       AND cod_for     = p_nota.cod_for
     ORDER BY num_nff

   FOREACH cq_n_x_s INTO 
           pr_nota[p_index].num_nff

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nfe_x_nff_885')
         RETURN FALSE
      END IF

      IF NOT pol0827_le_nf_mestre() THEN
         RETURN FALSE
      END IF

      LET p_index = p_index + 1

      IF p_index > 1000 THEN
         CALL log0030_mensagem('Linite de linhas da grade ultapassado','exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH   

   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_nota 
      WITHOUT DEFAULTS FROM sr_nota.*
   BEFORE INPUT
      EXIT INPUT
   END INPUT

   RETURN TRUE

END FUNCTION


#--------------------------#
 FUNCTION pol0827_consulta()
#--------------------------#
    
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0827") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08271 AT 2,2 WITH FORM p_nom_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   
   INPUT P_num_nff WITHOUT DEFAULTS FROM num_nff
   
   AFTER FIELD num_nff
   
   IF P_num_nff IS NULL THEN 
      ERROR "Campo com prenchimento obrigatório!!!"
      NEXT FIELD num_nff
   END IF 
   
   SELECT cod_cliente,
          ser_nff
     INTO p_cod_cliente,
          p_ser_nff          
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_num_nff
      
   IF STATUS = 100 THEN 
      ERROR "Nota fiscal de venda não cadastrada!!!"
      NEXT FIELD num_nff
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'nf_mestre')
         NEXT FIELD num_nff
      END IF
   END IF  
   
   
   SELECT nom_cliente 
     INTO p_nom_cliente
     FROM clientes 
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = p_cod_cliente
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'clientes')
      NEXT FIELD num_nff
   END IF

   DISPLAY p_nom_cliente TO nom_cliente
   

   END INPUT 
    
   IF INT_FLAG THEN
      ERROR "Operação cancelada!!!"
      RETURN 
   END IF

   SELECT num_nfe 
     INTO p_tela.num_nfe
     FROM nfe_x_nff_885
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_num_nff
      AND ser_nff     = p_ser_nff
      
   IF STATUS = 100 THEN 
      
      SELECT num_conhec
        INTO p_tela.num_conhec
        FROM frete_sup_x_nff
       WHERE cod_empresa  = p_cod_empresa
         AND num_nff      = p_num_nff
         AND ser_nf_saida = p_ser_nff
         
      IF STATUS = 100 THEN 
         CALL log0030_mensagem('Não há relacionamento para a nota informada!!!', 'excla')
         RETURN 
      ELSE 
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'frete_sup_x_nff')
            NEXT FIELD num_nff
         ELSE 
            DISPLAY p_tela.num_conhec TO num_conhec
            CALL log0030_mensagem('Relacionamento efetuado com sucesso!!!', 'excla')
            RETURN  
         END IF         
      END IF      
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'nfe_x_nff_885')
         NEXT FIELD num_nff
      ELSE 
         DISPLAY p_tela.num_nfe TO num_nfe
         CALL log0030_mensagem('Relacionamento efetuado com sucesso!!!', 'excla')
         RETURN  
      END IF
   END IF  
   
END FUNCTION 


#------------------------------#
FUNCTION pol0827_le_nf_mestre()
#------------------------------#

      SELECT a.pes_tot_bruto,
             b.nom_reduzido,
             c.den_cidade,
             a.ser_nff,
             a.ies_situacao
        INTO pr_nota[p_index].pes_tot_bruto,
             pr_nota[p_index].nom_reduzido,
             pr_nota[p_index].den_cidade,
             p_ser_nff,
             p_ies_situacao
        FROM nf_mestre a,
             clientes  b,
             cidades   c
       WHERE a.cod_empresa = p_cod_empresa
         AND a.num_nff     = pr_nota[p_index].num_nff
         AND b.cod_cliente = a.cod_cliente
         AND c.cod_cidade  = b.cod_cidade

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_mestre:2')
         RETURN FALSE
      END IF
      
      RETURN TRUE
      
END FUNCTION

#-----------------------#
FUNCTION pol0827_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_for)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_nota.cod_for = p_codigo
            DISPLAY p_codigo TO cod_for
         END IF

   END CASE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0827_notas_modificar()
#--------------------------------#

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_nota WITHOUT DEFAULTS FROM sr_nota.*
   
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD num_nff

         IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_nota[p_index].num_nff IS NULL THEN
               ERROR 'Campo c/ preenchimento obrigatório!!!'
               NEXT FIELD num_nff
            END IF
         
            IF NOT pol0827_le_nf_mestre() THEN
               NEXT FIELD num_nff
            END IF
         
            IF p_ies_situacao = 'C' THEN
               ERROR 'Nota Fiscal Cancelada!!!'
              NEXT FIELD num_nff
            END IF
      
            IF pol0827_repetiu_nf() THEN
               ERROR "NF já consta dessa relação !!!"
               NEXT FIELD num_nff
           END IF
     
           SELECT num_nfe
             INTO p_num_docum
             FROM nfe_x_nff_885
            WHERE cod_empresa = p_cod_empresa
              AND num_nff     = pr_nota[p_index].num_nff
              AND ser_nff     = p_ser_nff
              AND num_nfe    != p_nota.num_nfe
     
           IF STATUS = 0 THEN
              ERROR "NF já relacionada com a nota:",p_num_docum
              NEXT FIELD num_nff
           END IF
     
           LET p_num_docum = NULL
        
           DECLARE cq_num_conhec CURSOR FOR
            SELECT num_conhec
              FROM frete_sup_x_nff
             WHERE cod_empresa  = p_cod_empresa
               AND num_nff      = pr_nota[p_index].num_nff
               AND ser_nf_saida = p_ser_nff
        
           FOREACH cq_num_conhec INTO p_num_docum
        
              IF STATUS <> 0 THEN
                 CALL log003_err_sql('Lendo','frete_sup_x_nff:2')
                 RETURN FALSE
              END IF
              EXIT FOREACH
           
           END FOREACH
        
           IF p_num_docum IS NOT NULL THEN
              ERROR "NF já relacionada com o conecimento:",p_num_docum
              NEXT FIELD num_nff
           END IF
        
           DISPLAY pr_nota[p_index].pes_tot_bruto TO sr_nota[s_index].pes_tot_bruto
           DISPLAY pr_nota[p_index].nom_reduzido  TO sr_nota[s_index].nom_reduzido
           DISPLAY pr_nota[p_index].den_cidade    TO sr_nota[s_index].den_cidade
        END IF
        
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0827_grava_nota() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0827_repetiu_nf()
#----------------------------#

   DEFINE m_ind SMALLINT

   FOR m_ind = 1 TO ARR_COUNT()
       IF m_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_nota[m_ind].num_nff = pr_nota[p_index].num_nff THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION


#----------------------------#
FUNCTION pol0827_grava_nota()
#----------------------------#

   DELETE FROM nfe_x_nff_885
     WHERE cod_empresa = p_cod_empresa
       AND num_nfe     = p_nota.num_nfe
       AND ser_nfe     = p_nota.ser_nfe
       AND ssr_nfe     = p_nota.ssr_nfe
       AND cod_for     = p_nota.cod_for

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','nfe_x_nff_885')
      RETURN FALSE
   END IF

   FOR p_index = 1 TO ARR_COUNT()
       IF pr_nota[p_index].num_nff IS NOT NULL THEN
          IF NOT pol0827_pega_frete() THEN
             RETURN FALSE
          END IF
          INSERT INTO nfe_x_nff_885
             VALUES(p_cod_empresa,
                    p_nota.num_nfe,
                    p_nota.ser_nfe,
                    p_nota.ssr_nfe,
                    p_nota.cod_for,
                    pr_nota[p_index].num_nff,
                    p_ser_nff,
                    p_tot_nor,
                    p_tot_ger,'N')
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','nfe_x_nff_885')
             RETURN FALSE
          END IF
       END IF
   END FOR
       
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0827_pega_frete()
#----------------------------#

   LET p_tot_nor = 0
   LET p_tot_ger = 0
   
   DECLARE cq_ome CURSOR FOR
    SELECT num_om
      FROM ordem_montag_mest
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = pr_nota[p_index].num_nff

   FOREACH cq_ome INTO p_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ome')
         RETURN FALSE
      END IF
      
      SELECT val_frete,
             val_ger
        INTO p_val_normal,
             p_val_ger
        FROM frete_roma_885
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_num_om
      
      IF STATUS = 100 THEN
         LET p_val_normal = 0
         LET p_val_ger    = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','frete_roma_885')
            RETURN FALSE
         END IF
      END IF
      
      IF p_val_normal IS NULL THEN
         LET p_val_normal = 0
      END IF
      
      IF p_val_ger IS NULL THEN
         LET p_val_ger = 0
      END IF
      
      LET p_tot_nor = p_tot_nor + p_val_normal
      LET p_tot_ger = p_tot_ger + p_val_ger
      
   END FOREACH
   
   RETURN TRUE


END FUNCTION

#--------------------------#
FUNCTION pol0827_listagem()
#--------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0732.tmp"
         START REPORT pol0827_relat TO p_caminho
      ELSE
         START REPORT pol0827_relat TO p_nom_arquivo
      END IF
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   LET p_imprimiu = FALSE

   FOR p_ind = 1 TO ARR_COUNT()
   
       OUTPUT TO REPORT pol0827_relat()
       
       LET p_imprimiu = TRUE
   
   END FOR

   MESSAGE ''
   
   FINISH REPORT pol0827_relat

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         ERROR "Relatório impresso na impressora ", p_nom_arquivo
      ELSE
         ERROR "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF


END FUNCTION

#----------------------#
 REPORT pol0827_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 040, "RELACIONAMENTO DE NOTAS",
               COLUMN 073, "PAG.", PAGENO USING "&&&"
               
         PRINT COLUMN 001, "POL0827",
               COLUMN 016, "NF ENTRADA:",p_nota.num_nfe,
               COLUMN 036, "SER:",p_nota.ser_nfe,
               COLUMN 045, "FORNEC:",p_nota.cod_for,
               COLUMN 072, TODAY USING "dd/mm/yy"

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 005, "NUM NF  PESO BRUTO     CLIENTE                    DESTINO"
         PRINT COLUMN 005, "------ ------------ ---------------- ------------------------------"
      
      ON EVERY ROW

         PRINT COLUMN 005, pr_nota[p_ind].num_nff USING '######',
               COLUMN 011, pr_nota[p_ind].pes_tot_bruto USING '####,##&.&&&',
               COLUMN 026, pr_nota[p_ind].nom_reduzido,
               COLUMN 043, pr_nota[p_ind].den_cidade
      ON LAST ROW

         LET p_salto = LINENO
         
         IF p_salto < 63 THEN
            LET p_salto = 63 - p_salto
            SKIP p_salto LINES
         END IF
            
         
END REPORT


#--------------FIM DO PROGRAMA--------------#                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1263                                                 #
# OBJETIVO: IMPRESSÃO DE DUPLICATAS - 4GL+DELPHI                    #
# DATA....: 12/08/14                                                #
# FUNÇÕES.: FUNC002                                                 #
#-------------------------------------------------------------------#

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
          p_caminho            CHAR(080),
          p_last_row           SMALLINT
END GLOBALS

DEFINE p_num_vias              INTEGER,
       p_nom_tela              CHAR(200),
       p_dat_proces_doc        DATE,
       p_end_cobranca          CHAR(100),
       p_ind                   INTEGER


DEFINE p_duplicata             RECORD LIKE duplicata_885.*,
       p_docum                 RECORD LIKE docum_emis.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1263-10.02.01  "
   CALL func002_versao_prg(p_versao)

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'
   #LET p_user = 'admlog'
   #LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1263_controle()
      CLOSE WINDOW w_pol1263
   END IF
   
END MAIN

#--------------------------#
FUNCTION pol1263_controle()#
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1263") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1263 AT 07,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE   
   LET p_num_vias = 2
   
   INPUT p_num_vias
      WITHOUT DEFAULTS FROM num_vias
   
      AFTER FIELD num_vias
      
          IF p_num_vias IS NULL OR
              p_num_vias = 0 THEN
             ERROR 'Por favor, informe o numero de vias.'
             NEXT FIELD num_vias
          END IF
      
   END INPUT
   
   IF INT_FLAG THEN
      RETURN
   END IF
   
   MESSAGE 'AGUARDE. PROCESSANDO...'
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1263_le_docum() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF
   
   CALL log085_transacao("COMMIT")

   CALL POL1263_chama_delphi()            
   
END FUNCTION
   
#--------------------------#   
FUNCTION pol1263_le_docum()#
#--------------------------#

   DELETE FROM duplicata_885 
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','duplicata_885')
      RETURN FALSE
   END IF

   SELECT dat_proces_doc
     INTO p_dat_proces_doc
     FROM par_cre
   
   IF p_dat_proces_doc IS NULL THEN
      LET p_dat_proces_doc = TODAY
   END IF

   DECLARE cq_docum CURSOR FOR
    SELECT *
      FROM docum_emis
     WHERE cod_empresa = p_cod_empresa
       AND ies_impressao = 'N'
   FOREACH cq_docum INTO p_docum.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_docum')
         RETURN FALSE
      END IF
      
      INITIALIZE p_duplicata TO NULL
      
      CALL pol1263_le_nota()
      
      IF NOT pol1263_le_cliente() THEN
         RETURN FALSE
      END IF
      
      IF p_docum.pct_desc = 0 THEN
         LET p_docum.pct_desc = NULL
      END IF
      
      LET p_duplicata.ie_sub_trib = ''
      LET p_duplicata.cod_cliente  = p_docum.cod_cliente
      LET p_duplicata.num_docum    = p_docum.num_docum
      LET p_duplicata.val_docum    = p_docum.val_bruto
      LET p_duplicata.dat_emis     = p_docum.dat_emis
      LET p_duplicata.dat_vencto   = p_docum.dat_vencto_s_desc
      LET p_duplicata.num_nota     = p_docum.num_docum_orig
      LET p_duplicata.desconto_de  = p_docum.pct_desc
      LET p_duplicata.pagto_ate    = p_docum.dat_vencto_c_desc
      LET p_duplicata.end_cobranca = p_end_cobranca
      
      CALL pol1263_extenso() 
      
      FOR p_ind = 1 TO p_num_vias
          INSERT INTO duplicata_885 VALUES(p_duplicata.*)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERT','duplicata_885')
             RETURN FALSE
          END IF
      END FOR
      
      IF NOT pol1263_atualiz_docum() THEN
         RETURN FALSE
      END IF
            
   END FOREACH
      
   RETURN TRUE

END FUNCTION
   
#-------------------------#
FUNCTION pol1263_le_nota()#
#-------------------------#
           
   SELECT cod_nat_oper,
          cod_fiscal
     INTO p_duplicata.cod_nat_oper,
          p_duplicata.cod_fiscal
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_docum.num_docum_orig
      
   IF STATUS <> 0 THEN 
      LET p_duplicata.cod_nat_oper = ''
      LET p_duplicata.den_nat_oper = 'VENDA'
      LET p_duplicata.cod_fiscal = '6101'
   ELSE 
      SELECT den_nat_oper
        INTO p_duplicata.den_nat_oper
        FROM nat_operacao
       WHERE cod_nat_oper = p_duplicata.cod_nat_oper
      
      IF STATUS <> 0 THEN
         LET p_duplicata.den_nat_oper = ''
      END IF 
   END IF 

END FUNCTION

#----------------------------#          
FUNCTION pol1263_le_cliente()#
#----------------------------#
   
   DEFINE p_den_cidade  CHAR(30),
          p_estado      CHAR(02)
          
   SELECT a.num_cgc_cpf,
          a.ins_estadual,
          a.nom_cliente,
          a.end_cliente,
          a.den_bairro,
          a.cod_cep,
          a.num_telefone,
          b.den_cidade,
          b.cod_uni_feder
     INTO p_duplicata.num_cnpj,    
          p_duplicata.insc_estadual,
          p_duplicata.nom_cliente,
          p_duplicata.endereco,   
          p_duplicata.bairro,     
          p_duplicata.cep,   
          p_duplicata.fone,     
          p_duplicata.cidade,     
          p_duplicata.estado     
     FROM clientes a, cidades b
    WHERE a.cod_cliente = p_docum.cod_cliente
      AND b.cod_cidade = a.cod_cidade

   {IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE
   END IF}
   
   IF p_docum.end_cliente_cob IS NULL OR 
        p_docum.end_cliente_cob = ' ' THEN
      LET p_end_cobranca = ''
      RETURN TRUE
   END IF
   
   LET p_end_cobranca = p_docum.end_cliente_cob CLIPPED, ' - ',
         p_docum.den_bairro_cob
   
   IF cod_cidade_cob IS NOT NULL THEN
      SELECT den_cidade,
             cod_uni_feder
        INTO p_den_cidade,
             p_estado
        FROM cidades
       WHERE cod_cidade = p_docum.cod_cidade_cob
      
      IF STATUS = 0 THEN
         LET p_end_cobranca = p_end_cobranca CLIPPED,
             ' - ', p_den_cidade CLIPPED,'/',p_estado
      END IF
   END IF
   
   LET p_end_cobranca = p_end_cobranca CLIPPED, ' CEP: ', p_docum.cod_cep_cob            
                                       
   RETURN TRUE

END FUNCTION
   
#-------------------------#   
FUNCTION pol1263_extenso()#
#-------------------------#
  
   DEFINE p_nom_log CHAR(14)
   DEFINE p_lin1, p_lin2, p_lin3, p_lin4 CHAR(200)
   DEFINE p_comp_l1, p_comp_l2, p_comp_l3, p_comp_l4 INTEGER
       
   SELECT nom_log
     INTO p_nom_log
     FROM val_origem
    WHERE val_origem.cod_empresa   = p_docum.cod_empresa
      AND val_origem.num_docum     = p_docum.num_docum
      AND val_origem.ies_tip_docum = p_docum.ies_tip_docum

   IF STATUS <> 0 THEN
      LET p_nom_log = "log038_extenso"
   END IF
    
   LET p_comp_l1 = 100
   LET p_comp_l2 = 100
   LET p_comp_l3 = 100
   LET p_comp_l4 = 100

   IF p_nom_log = "log038_extenso"  THEN
      CALL log038_extenso(p_docum.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF

   IF p_nom_log = "log036_extenso"  THEN
      CALL log036_extenso(p_docum.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF

   IF p_nom_log = "log033_extenso"  THEN
      CALL log033_extenso(p_docum.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF  

   LET p_duplicata.val_extenso1 = p_lin1
   
   IF p_lin2[1,1] = '*' THEN
      LET p_duplicata.val_extenso2 = ''  
   ELSE
      LET p_duplicata.val_extenso2 = p_lin2   
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1263_atualiz_docum()#
#-------------------------------#

   UPDATE docum 
      SET dat_emis_docum     = p_dat_proces_doc,
          num_lote_remessa   = 0
    WHERE cod_empresa   = p_docum.cod_empresa
      AND num_docum     = p_docum.num_docum
      AND ies_tip_docum = p_docum.ies_tip_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','docum')
      RETURN FALSE
   END IF
   
  UPDATE docum_emis 
     SET ies_impressao = "S"
   WHERE cod_empresa      = p_docum.cod_empresa
     AND num_docum        = p_docum.num_docum
     AND ies_tip_docum    = p_docum.ies_tip_docum 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','docum_emis')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--- localiza caminho e chama progarma delphi ---#

#------------------------------#
FUNCTION POL1263_chama_delphi()#
#------------------------------#

   DEFINE p_param    CHAR(42),
          p_comando  CHAR(200)

   LET p_param = p_num_vias
   
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN FALSE
   END IF

   LET p_comando = p_caminho CLIPPED, 'pgi1174.exe ' #, p_param

   CALL conout(p_comando)

   CALL runOnClient(p_comando)

END FUNCTION   
   
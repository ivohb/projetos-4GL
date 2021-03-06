#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1247                                                 #
# OBJETIVO: PRE�O DE FRETE POR TONELADA                             #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 20/10/13                                                #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
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
          p_excluiu            SMALLINT
         
END GLOBALS

DEFINE p_den_transpor      CHAR(36),
       p_cod_tip_veiculo       CHAR(07),
       p_tip_carga         CHAR(06),
       p_den_cidade_orig   CHAR(30),
       p_den_cidade_dest   CHAR(30),
       p_id_registro       INTEGER,
       p_id_registroa      INTEGER,
       p_estado_orig       CHAR(02),
       p_estado_dest       CHAR(02),
       p_num_versao        INTEGER,
       p_dat_ini           DATE,
       p_dat_fim           DATE,
       p_des_tip_veiculo   CHAR(15),
       p_des_rota          CHAR(76),
       p_cod_cidade        CHAR(05)


DEFINE p_preco         RECORD LIKE preco_frete_455.*


DEFINE sql_stmt, where_clause CHAR(800)  

DEFINE p_reajuste     RECORD
       cod_transpor   CHAR(15),
       pct_frete      DECIMAL(6,2),
       pct_pedagio    DECIMAL(6,2)
END RECORD       
       

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1247-10.02.08  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1247_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1247_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1247") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1247 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1247_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modifica data final da vig�ncia"
         IF p_ies_cons THEN
            CALL pol1247_modificar() RETURNING p_status  
            IF p_status THEN
               ERROR 'Opera��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Execute previamente a consulta"
         END IF
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1247_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1247_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1247_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Nova vers�o" "Gera nova vers�o da tabela."
         IF p_ies_cons THEN
            CALL pol1247_nova_versao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Opera��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Execute previamente a consulta"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1247_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         IF NOT pol1247_listagem() THEN
            ERROR 'Opera��o cancelada.'
         ELSE
            ERROR 'Opera��o efetuada com sucesso.'
         END IF
         IF p_ies_cons THEN 
            LET p_id_registro = p_id_registroa
            CALL pol1247_exibe_dados() RETURNING p_status
         END IF
      COMMAND KEY ("J") "reaJustar" "Aplicar reajustes no frete e/ou ped�gio."
         IF pol1247_reajustar() THEN
            ERROR 'Opera��o efetuada com sucesso.'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancela.'
         END IF 
      COMMAND "Transportadores" "Transportadores para controle de frete"
         CALL log120_procura_caminho("pol1252") RETURNING comando
         LET comando = comando CLIPPED, " ", p_preco.cod_transpor
         RUN comando RETURNING p_status         
      COMMAND "Ve�culos" "Ve�culos para controle de frete"
         CALL log120_procura_caminho("pol1248") RETURNING comando
         LET comando = comando CLIPPED, " ", p_preco.cod_transpor
         RUN comando RETURNING p_status         
      COMMAND "Rota" "Rota por cliente/fornecedor"
         CALL log120_procura_caminho("pol1268") RETURNING comando
         LET comando = comando CLIPPED
         RUN comando RETURNING p_status         
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1247

END FUNCTION

#---------------------------#
FUNCTION pol1247_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1247_inclusao()
#--------------------------#

   CALL pol1247_limpa_tela()
   
   INITIALIZE p_preco, p_estado_orig, p_estado_dest TO NULL
   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   
   LET p_preco.tip_valor = 'T'
   LET p_preco.tip_cobranca = 'N'
   LET p_preco.val_pri_viagem = 0
   LET p_preco.val_demais_viag = 0
   LET p_preco.val_pedagio = 0
   LET p_preco.val_adicional = 0
   LET p_preco.cod_rota_orig = 0
   LET p_preco.cod_rota_dest = 0
   LET p_preco.num_versao = 1
   LET p_preco.dat_atualiz = TODAY
   LET p_preco.cod_usuario = p_user
   LET p_preco.operacao = 'INCLUSAO DA TABELA'
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1247_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1247_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1247_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1247_insere()
#------------------------#
   
   SELECT MAX(id_registro)
     INTO p_id_registro
     FROM preco_frete_455

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("SELECT","preco_frete_455")       
      RETURN FALSE
   END IF
   
   IF p_id_registro IS NULL THEN
      LET p_id_registro = 1
   ELSE
      LET p_id_registro = p_id_registro + 1
   END IF
   
   LET p_preco.id_registro = p_id_registro
   
   INSERT INTO preco_frete_455 VALUES (p_preco.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","preco_frete_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1247_grav_versao()#
#-----------------------------#
   
   IF p_dat_fim > TODAY THEN
      DELETE FROM preco_frete_455
       WHERE id_registro = p_id_registro
   ELSE
      UPDATE preco_frete_455
         SET dat_fim_vigencia = p_dat_fim
       WHERE id_registro = p_id_registro
   END IF
   
   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("ATUALIZANDO","preco_frete_455")       
      RETURN FALSE
   END IF
      
   IF NOT pol1247_insere() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
   
#-------------------------------------#
 FUNCTION pol1247_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME                          
         p_preco.cod_transpor,    
         p_preco.cod_tip_veiculo, 
         p_preco.tip_carga,       
         p_preco.cod_cidade_orig, 
         p_preco.cod_rota_orig,   
         p_preco.cod_cidade_dest, 
         p_preco.cod_rota_dest,   
         p_preco.val_pri_viagem,  
         p_preco.val_demais_viag, 
         p_preco.tip_valor,       
         p_preco.tip_cobranca,    
         p_preco.val_pedagio,     
         p_preco.val_adicional,   
         p_preco.dat_ini_vigencia,
         p_preco.dat_fim_vigencia,
         p_preco.num_versao,      
         p_preco.dat_atualiz,     
         p_preco.cod_usuario  
      WITHOUT DEFAULTS               
              
      BEFORE FIELD cod_transpor

         IF p_funcao = "M" THEN
            NEXT FIELD val_pri_viagem
         END IF
      
      AFTER FIELD cod_transpor

         IF p_preco.cod_transpor IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_transpor   
         END IF

         CALL pol1247_le_den_transpor(p_preco.cod_transpor)
          
         IF p_den_transpor IS NULL THEN 
            ERROR 'Transportadora inexistente.'
            NEXT FIELD cod_transpor
         END IF  
         
         DISPLAY p_den_transpor TO den_transpor
         
      AFTER FIELD cod_tip_veiculo

         IF p_preco.cod_tip_veiculo IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_tip_veiculo   
         END IF
         
         CALL pol1247_le_des_veiculo(p_preco.cod_tip_veiculo)
          
         IF p_des_tip_veiculo IS NULL THEN 
            ERROR 'Ve�culo n�o cadastrado no POL1266.'
            NEXT FIELD cod_tip_veiculo
         END IF  
         
         DISPLAY p_des_tip_veiculo TO des_tip_veiculo
         
      AFTER FIELD cod_cidade_orig

         IF p_preco.cod_cidade_orig IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_cidade_orig   
         END IF

         CALL pol1247_le_den_cidade(p_preco.cod_cidade_orig)
            RETURNING p_den_cidade_orig, p_estado_orig
          
         IF p_den_cidade_orig IS NULL THEN 
            ERROR 'Cidade inexistente.'
            NEXT FIELD cod_cidade_orig
         END IF  
         
         DISPLAY p_den_cidade_orig TO den_cidade_orig
         DISPLAY p_estado_orig TO estado_orig

      AFTER FIELD cod_rota_orig

         IF p_preco.cod_rota_orig IS NULL THEN 
            LET p_preco.cod_rota_orig = 0
            NEXT FIELD cod_rota_orig   
         END IF
         
         IF p_preco.cod_rota_orig > 0 THEN
            CALL pol1247_le_des_rota(p_preco.cod_rota_orig)
            IF p_des_rota IS NULL THEN 
               ERROR 'Rota n�o cadastrado no POL1267.'
               NEXT FIELD cod_rota_orig
            END IF  
            IF p_preco.cod_cidade_orig <> p_cod_cidade THEN
               LET p_msg = 'Cidade origem.: ', p_preco.cod_cidade_orig CLIPPED, '\n',
                           'Cidade da rota: ', p_cod_cidade CLIPPED, '\n',
                           'Informe uma rota da\n cidade origem.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD cod_rota_orig
            END IF
         ELSE
            LET p_des_rota = NULL
         END IF
         
         DISPLAY p_des_rota TO des_rota_orig

      AFTER FIELD cod_cidade_dest

         IF p_preco.cod_cidade_dest IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_cidade_dest   
         END IF

         CALL pol1247_le_den_cidade(p_preco.cod_cidade_dest)
            RETURNING p_den_cidade_dest, p_estado_dest
          
         IF p_den_cidade_dest IS NULL THEN 
            ERROR 'Cidade inexistente.'
            NEXT FIELD cod_cidade_dest
         END IF  
         
         DISPLAY p_den_cidade_dest TO den_cidade_dest
         DISPLAY p_estado_dest TO estado_dest

      AFTER FIELD cod_rota_dest

         IF p_preco.cod_rota_dest IS NULL THEN 
            LET p_preco.cod_rota_dest = 0
            NEXT FIELD cod_rota_dest   
         END IF
         
         IF p_preco.cod_rota_dest > 0 THEN
            CALL pol1247_le_des_rota(p_preco.cod_rota_dest)
            IF p_des_rota IS NULL THEN 
               ERROR 'Rota n�o cadastrado no POL1267.'
               NEXT FIELD cod_rota_dest
            END IF  
            IF p_preco.cod_cidade_dest <> p_cod_cidade THEN
               LET p_msg = 'Cidade destino: ', p_preco.cod_cidade_dest CLIPPED, '\n',
                           'Cidade da rota: ', p_cod_cidade CLIPPED, '\n',
                           'Informe uma rota da\n cidade destino.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD cod_rota_dest
            END IF
         ELSE
            LET p_des_rota = NULL
         END IF
         
         DISPLAY p_des_rota TO des_rota_dest

         SELECT cod_transpor
           FROM preco_frete_455
          WHERE num_versao = p_preco.num_versao 
            AND cod_transpor = p_preco.cod_transpor
            AND cod_tip_veiculo =  p_preco.cod_tip_veiculo
            AND tip_carga =  p_preco.tip_carga
            AND cod_cidade_orig = p_preco.cod_cidade_orig
            AND cod_rota_orig = p_preco.cod_rota_orig
            AND cod_cidade_dest = p_preco.cod_cidade_dest
            AND cod_rota_dest = p_preco.cod_rota_dest
         
         IF STATUS = 0 THEN
            ERROR 'Tabela de pre�o j� cadastrados no pol1247.'
            NEXT FIELD cod_transpor   
         END IF

      BEFORE FIELD val_demais_viag
      
         IF p_preco.val_demais_viag IS NULL OR
            p_preco.val_demais_viag < 0 THEN
            LET p_preco.val_demais_viag = p_preco.val_pri_viagem
            DISPLAY p_preco.val_demais_viag TO val_demais_viag
         END IF                        

      AFTER FIELD dat_fim_vigencia

         IF p_preco.dat_fim_vigencia IS NOT NULL THEN
            IF p_dat_ini IS NOT NULL THEN
               IF p_preco.dat_fim_vigencia >= p_dat_ini THEN
                  LET p_msg = 'O FIM da vig�ncia dessa vers�o\n',
                        'tem que ser MENOR que o IN�CIO da\n ',
                        'vig�ncia da vers�o SEGUINTE.'
                  CALL log0030_mensagem(p_msg,'info')
                  NEXT FIELD dat_fim_vigencia
               END IF
            END IF
         END IF
          
      ON KEY (control-z)
         CALL pol1247_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_preco.val_pri_viagem IS NULL OR p_preco.val_pri_viagem = 0 THEN 
               ERROR 'Campo com preenchimento obrigat�rio.'
               NEXT FIELD val_pri_viagem
            END IF

            IF p_preco.val_demais_viag IS NULL OR p_preco.val_demais_viag < 0 THEN 
               ERROR 'Campo com preenchimento obrigat�rio.'
               NEXT FIELD val_demais_viag
            END IF

            IF p_preco.val_pedagio IS NULL THEN 
               LET p_preco.val_pedagio = 0
            END IF
            IF p_preco.val_adicional IS NULL THEN 
               LET p_preco.val_adicional = 0
            END IF
            IF p_preco.cod_rota_orig IS NULL THEN 
               LET p_preco.cod_rota_orig = 0
            END IF
            IF p_preco.cod_rota_dest IS NULL THEN 
               LET p_preco.cod_rota_dest = 0
            END IF

            IF p_preco.dat_ini_vigencia IS NULL THEN 
               ERROR 'Preencha o in�cio da vig�ncia.'
               NEXT FIELD dat_ini_vigencia
            END IF
            
            IF p_preco.dat_fim_vigencia IS NULL THEN 
               ERROR 'Preencha o fim da vig�ncia.'
               NEXT FIELD dat_fim_vigencia
            END IF

            IF p_dat_ini IS NOT NULL THEN
               IF p_preco.dat_fim_vigencia >= p_dat_ini THEN
                  LET p_msg = 'O FIM da vig�ncia dessa vers�o\n',
                        'tem que ser MENOR que o IN�CIO da\n ',
                        'vig�ncia da vers�o SEGUINTE.'
                  CALL log0030_mensagem(p_msg,'info')
                  NEXT FIELD dat_fim_vigencia
               END IF
            END IF
            
            IF p_preco.dat_ini_vigencia IS NOT NULL AND
               p_preco.dat_fim_vigencia IS NOT NULL THEN 
               IF p_preco.dat_ini_vigencia > p_preco.dat_fim_vigencia THEN
                  ERROR 'Per�odo de vig�ncia inv�lido.'
                  NEXT FIELD dat_ini_vigencia
               END IF
            END IF
            
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1247_le_den_transpor(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT raz_social
     INTO p_den_transpor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_transpor = NULL
   END IF  

END FUNCTION

#-------------------------------------#
FUNCTION pol1247_le_des_veiculo(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT des_tip_veiculo
     INTO p_des_tip_veiculo
     FROM tip_veiculo_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_veiculo = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_des_tip_veiculo = NULL
   END IF  

END FUNCTION

#-------------------------------------#
FUNCTION pol1247_le_des_rota(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT des_rota,
          cod_cidade
     INTO p_des_rota,
          p_cod_cidade
     FROM rota_frete_455
    WHERE cod_rota = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_des_rota = NULL
   END IF  

END FUNCTION

#------------------------------------#
FUNCTION pol1247_le_den_cidade(p_cod)#
#------------------------------------#
   
   DEFINE p_cod        CHAR(05),
          p_den_cidade CHAR(30),
          p_estado     CHAR(02)
   
   SELECT den_cidade,
          cod_uni_feder
     INTO p_den_cidade,
          p_estado
     FROM cidades
    WHERE cod_cidade = p_cod
         
   IF STATUS <> 0 THEN 
      INITIALIZE p_den_cidade, p_estado TO NULL
   END IF  
   
   RETURN p_den_cidade, p_estado

END FUNCTION

#-----------------------#
 FUNCTION pol1247_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
         
         CURRENT WINDOW IS w_pol1247
         IF p_codigo IS NOT NULL THEN
            LET p_preco.cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(cod_tip_veiculo)
         CALL log009_popup(8,10,"TIPO DE VE�CULO","tip_veiculo_455",
              "cod_tip_veiculo","des_tip_veiculo","POL1266","S"," 1=1 order by des_tip_veiculo") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_preco.cod_tip_veiculo = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tip_veiculo
         END IF

      WHEN INFIELD(cod_cidade_orig)
         LET p_codigo = pol1247_sel_cidade()
         CLOSE WINDOW w_pol1247a
         CURRENT WINDOW IS w_pol1247
         IF p_codigo IS NOT NULL THEN
           LET p_preco.cod_cidade_orig = p_codigo
           DISPLAY p_codigo TO cod_cidade_orig
         END IF

      WHEN INFIELD(cod_rota_orig)
         LET p_codigo = pol1247_sel_rota(p_preco.cod_cidade_orig)
         CLOSE WINDOW w_pol1247b
         CURRENT WINDOW IS w_pol1247
                           
         IF p_codigo IS NOT NULL THEN
            LET p_preco.cod_rota_orig = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_rota_orig
         END IF

      WHEN INFIELD(cod_cidade_dest)
         LET p_codigo = pol1247_sel_cidade()
         CLOSE WINDOW w_pol1247a
         CURRENT WINDOW IS w_pol1247
         IF p_codigo IS NOT NULL THEN
           LET p_preco.cod_cidade_dest = p_codigo
           DISPLAY p_codigo TO cod_cidade_dest
         END IF

      WHEN INFIELD(cod_rota_dest)
         LET p_codigo = pol1247_sel_rota(p_preco.cod_cidade_dest)
         CLOSE WINDOW w_pol1247b
         CURRENT WINDOW IS w_pol1247
                   
         IF p_codigo IS NOT NULL THEN
            LET p_preco.cod_rota_dest = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_rota_dest
         END IF

   END CASE 

END FUNCTION 

#----------------------------#
FUNCTION pol1247_sel_cidade()#
#----------------------------#

   DEFINE pr_cidade      ARRAY[5000] OF RECORD
          cod_cidade     CHAR(05),
          den_cidade     CHAR(30),
          estado         CHAR(02)
   END RECORD
   
   DEFINE p_where, p_query CHAR(150)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1247a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1247a AT 5,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   CONSTRUCT BY NAME p_where ON 
      cidades.cod_cidade,
      cidades.den_cidade,
      cod_uni_feder
      
   IF INT_FLAG THEN
      RETURN "" 
   END IF

   LET p_query = 
      "SELECT cod_cidade, den_cidade, cod_uni_feder",
      "  FROM cidades ",
      " WHERE ", p_where CLIPPED,
      " ORDER BY den_cidade"

   PREPARE sql_cidade FROM p_query   
   DECLARE cq_cidade CURSOR FOR sql_cidade

   FOREACH cq_cidade INTO
      pr_cidade[p_ind].cod_cidade,
      pr_cidade[p_ind].den_cidade,
      pr_cidade[p_ind].estado

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cidade')
         RETURN ""
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 5000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhum registro foi encontrado, para os par�metros informados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_cidade TO sr_cidade.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   IF NOT INT_FLAG THEN
      RETURN pr_cidade[p_ind].cod_cidade
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#----------------------------------#
FUNCTION pol1247_sel_rota(p_cidade)#
#----------------------------------#
   
   DEFINE p_cidade       CHAR(05)
     
   DEFINE pr_rota      ARRAY[1000] OF RECORD
          cod_rota     INTEGER,
          des_rota     CHAR(76)
   END RECORD
   
   DEFINE p_where, p_query CHAR(150)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1247b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1247b AT 5,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   DECLARE cq_rota CURSOR FOR 
    SELECT cod_rota, des_rota
      FROM rota_frete_455
     WHERE cod_cidade = p_cidade
     ORDER BY des_rota
     
   FOREACH cq_rota INTO
      pr_rota[p_ind].cod_rota,
      pr_rota[p_ind].des_rota

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_rota')
         RETURN ""
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhuma rota foi encontrada, \npara a cidade ', p_cidade CLIPPED
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_rota TO sr_rota.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   IF NOT INT_FLAG THEN
      RETURN pr_rota[p_ind].cod_rota
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#---------------------------------#
 FUNCTION pol1247_parametros(p_op)#
#---------------------------------#

   DEFINE p_op CHAR(01)
   
   CALL pol1247_limpa_tela()
   LET p_id_registroa = p_id_registro
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON 
      preco_frete_455.cod_transpor,         
      preco_frete_455.cod_tip_veiculo,          
      preco_frete_455.tip_carga,            
      preco_frete_455.cod_cidade_orig,      
      preco_frete_455.cod_rota_orig,      
      preco_frete_455.cod_cidade_dest,      
      preco_frete_455.cod_rota_dest,      
      preco_frete_455.num_versao,           
      preco_frete_455.dat_ini_vigencia,     
      preco_frete_455.dat_fim_vigencia     

      ON KEY (control-z)
         CALL pol1247_popup()

   END CONSTRUCT

   IF INT_FLAG THEN
      IF p_op = 'C' THEN
         IF p_ies_cons THEN 
            IF p_excluiu THEN
               CALL pol1247_limpa_tela()
            ELSE
               LET p_id_registro = p_id_registroa
               CALL pol1247_exibe_dados() RETURNING p_status
            END IF
         END IF    
      END IF
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
 FUNCTION pol1247_consulta()
#--------------------------#

   IF NOT pol1247_parametros('C') THEN
      RETURN FALSE
   END IF
      
   LET p_excluiu = FALSE

   LET sql_stmt = "SELECT id_registro, num_versao, cod_transpor, cod_tip_veiculo, ",
                  " tip_carga, cod_cidade_orig, cod_rota_orig ",
                  " FROM preco_frete_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_transpor, cod_tip_veiculo, tip_carga, ",
                  "          cod_cidade_orig, cod_rota_orig, num_versao "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1247_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1247_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_preco.*
     FROM preco_frete_455
    WHERE id_registro = p_id_registro
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'preco_frete_455')
      RETURN FALSE
   END IF
      
   DISPLAY BY NAME 
         p_preco.cod_transpor,
         p_preco.cod_tip_veiculo,        
         p_preco.tip_carga,          
         p_preco.cod_cidade_orig,    
         p_preco.cod_rota_orig,    
         p_preco.cod_cidade_dest,    
         p_preco.cod_rota_dest,    
         p_preco.val_pri_viagem,     
         p_preco.val_demais_viag,    
         p_preco.tip_valor,    
         p_preco.tip_cobranca,    
         p_preco.val_pedagio,        
         p_preco.val_adicional,      
         p_preco.dat_ini_vigencia,   
         p_preco.dat_fim_vigencia, 
         p_preco.num_versao,       
         p_preco.dat_atualiz,
         p_preco.cod_usuario
   
   CALL pol1247_le_den_transpor(p_preco.cod_transpor)
   DISPLAY p_den_transpor to den_transpor

   CALL pol1247_le_des_veiculo(p_preco.cod_tip_veiculo)
   DISPLAY p_des_tip_veiculo to des_tip_veiculo

   CALL pol1247_le_den_cidade(p_preco.cod_cidade_orig)
      RETURNING p_den_cidade_orig, p_estado_orig
          
   DISPLAY p_den_cidade_orig TO den_cidade_orig
   DISPLAY p_estado_orig TO estado_orig

   CALL pol1247_le_des_rota(p_preco.cod_rota_orig)
   DISPLAY p_des_rota to des_rota_orig

   CALL pol1247_le_den_cidade(p_preco.cod_cidade_dest)
      RETURNING p_den_cidade_dest, p_estado_dest
          
   DISPLAY p_den_cidade_dest TO den_cidade_dest
   DISPLAY p_estado_dest TO estado_dest

   CALL pol1247_le_des_rota(p_preco.cod_rota_dest)
   DISPLAY p_des_rota to des_rota_dest
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1247_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_id_registroa = p_id_registro
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_transpor
           FROM preco_frete_455
          WHERE id_registro = p_id_registro
            
         IF STATUS = 0 THEN
            IF pol1247_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_id_registro = p_id_registroa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1247_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_transpor 
      FROM preco_frete_455  
     WHERE id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","preco_frete_455")
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------#
 FUNCTION pol1247_modificar()
#---------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem exclu�dos !!!", "exclamation")
      RETURN p_retorno
   END IF

   IF NOT pol1247_eh_versao_atual() THEN
      RETURN FALSE
   END IF
   
   IF pol1247_prende_registro() THEN
      IF pol1247_atualiza() THEN
         LET p_retorno = TRUE
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-------------------------#
FUNCTION pol1247_atualiza()
#-------------------------#

   IF NOT pol1247_edita_vigencia() THEN
      RETURN FALSE
   END IF
   
   UPDATE preco_frete_455
      SET dat_fim_vigencia = p_preco.dat_fim_vigencia
    WHERE id_registro = p_id_registro

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("UPDATE","preco_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   
   


#--------------------------#
 FUNCTION pol1247_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem exclu�dos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF p_preco.dat_ini_vigencia <= TODAY THEN
      LET p_msg = 'Tabela em vig�ncia n�o\n pode ser excluida.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1247_prende_registro() THEN
      IF pol1247_deleta() THEN
         INITIALIZE p_preco TO NULL
         CALL pol1247_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#------------------------#
FUNCTION pol1247_deleta()
#------------------------#

   DELETE FROM preco_frete_455
    WHERE id_registro = p_id_registro

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","preco_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#------------------------------#
 FUNCTION pol1247_nova_versao()#
#------------------------------#
   
   LET p_retorno = FALSE
   LET p_id_registroa = p_id_registro
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados para gerar nova vers�o", "exclamation")
      RETURN p_retorno
   END IF
      
   IF NOT pol1247_eh_versao_atual() THEN
      RETURN FALSE
   END IF
   
   LET p_opcao   = "N"
   
   IF pol1247_prende_registro() THEN
      IF pol1247_edita_versao() THEN
         LET p_preco.operacao = 'NOVA VERSAO'
         IF pol1247_grav_versao() THEN
            CALL log085_transacao("COMMIT")
            LET p_retorno = TRUE
            LET p_ies_cons = FALSE
         ELSE
            CALL log085_transacao("ROLLBACK")
            LET p_id_registro = p_id_registroa
            CALL pol1247_exibe_dados() RETURNING p_status
         END IF
      ELSE
         LET p_id_registro = p_id_registroa
         CALL pol1247_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   RETURN p_retorno

END FUNCTION

#---------------------------------#
FUNCTION pol1247_eh_versao_atual()#
#---------------------------------#

   SELECT MAX(num_versao)
     INTO p_count 
     FROM preco_frete_455  
    WHERE cod_transpor = p_preco.cod_transpor
      AND cod_tip_veiculo = p_preco.cod_tip_veiculo
      AND tip_carga =  p_preco.tip_carga
      AND cod_cidade_orig = p_preco.cod_cidade_orig
      AND cod_rota_orig = p_preco.cod_rota_orig
      AND cod_cidade_dest = p_preco.cod_cidade_dest
      AND cod_rota_dest = p_preco.cod_rota_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','preco_frete_455')
      RETURN FALSE
   END IF
   
   IF p_count > p_preco.num_versao THEN
      LET p_msg = 'Para criar nova vers�o,\n consulte a maior vers�o\n da tabela de pre�o.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1247_edita_versao()#
#------------------------------#
   
   DEFINE p_dt_ini_vigencia  DATE
   
   LET p_preco.num_versao = p_preco.num_versao + 1
   LET p_dat_ini = p_preco.dat_ini_vigencia
   LET p_dat_fim = p_preco.dat_fim_vigencia
   LET p_dt_ini_vigencia = TODAY + 1
   LET p_preco.dat_atualiz = TODAY
   LET p_preco.cod_usuario = p_user
   
   LET p_msg = 'Vig�ncia da tabela atual: ', p_dat_ini, ' - ', p_dat_fim
   
   INITIALIZE p_preco.dat_fim_vigencia, 
              p_preco.dat_ini_vigencia TO NULL
              
   LET INT_FLAG = FALSE
   
   INPUT BY NAME 
         p_preco.val_pri_viagem,     
         p_preco.val_demais_viag,  
         p_preco.tip_valor,
         p_preco.tip_cobranca,  
         p_preco.val_pedagio,        
         p_preco.val_adicional,      
         p_preco.dat_ini_vigencia,   
         p_preco.dat_fim_vigencia,
         p_preco.num_versao,         
         p_preco.dat_atualiz,
         p_preco.cod_usuario           
      WITHOUT DEFAULTS
              
      BEFORE FIELD dat_ini_vigencia
      
         ERROR p_msg

      BEFORE FIELD dat_fim_vigencia
      
         ERROR p_msg
                
      ON KEY (control-z)
         CALL pol1247_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_preco.val_pri_viagem IS NULL OR p_preco.val_pri_viagem = 0 THEN 
               ERROR 'Campo com preenchimento obrigat�rio.'
               NEXT FIELD val_pri_viagem
            END IF

            IF p_preco.val_demais_viag IS NULL THEN 
               LET p_preco.val_demais_viag = 0
            END IF

            IF p_preco.val_pedagio IS NULL THEN 
               LET p_preco.val_pedagio = 0
            END IF

            IF p_preco.val_adicional IS NULL THEN 
               LET p_preco.val_adicional = 0
            END IF

            IF p_preco.dat_ini_vigencia IS NULL THEN 
               ERROR 'Preencha o in�cio da vig�ncia.'
               NEXT FIELD dat_ini_vigencia
            END IF

            IF p_preco.dat_ini_vigencia < p_dt_ini_vigencia THEN 
               LET p_msg = 'O IN�CIO da vig�ncia deve ser\n',
                           'MAIOR OU IGUAL a ', p_dt_ini_vigencia
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD dat_ini_vigencia
            END IF

            IF p_preco.dat_ini_vigencia <= p_dat_ini THEN 
               LET p_msg = 'O IN�CIO da vig�ncia da nova vers�o\n',
                           'deve ser MAIOR que ', p_dat_ini
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD dat_ini_vigencia
            END IF

            IF p_preco.dat_fim_vigencia IS NULL THEN 
               ERROR 'Preencha o fim da vig�ncia.'
               NEXT FIELD dat_fim_vigencia
            END IF

            IF p_preco.dat_ini_vigencia > p_preco.dat_fim_vigencia THEN
               ERROR 'Per�odo de vig�ncia inv�lido.'
               NEXT FIELD dat_ini_vigencia
            END IF
            
            LET p_dat_fim = p_preco.dat_ini_vigencia - 1
            
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1247_edita_vigencia()#
#--------------------------------#
                 
   LET INT_FLAG = FALSE
   
   INPUT BY NAME 
         p_preco.dat_fim_vigencia
      WITHOUT DEFAULTS
              
      BEFORE FIELD dat_fim_vigencia
      
         ERROR "Informe a vig�ncia final"
                
      ON KEY (control-z)
         CALL pol1247_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN

            IF p_preco.dat_fim_vigencia IS NULL THEN
               ERROR 'Per�odo de vig�ncia final.'
               NEXT FIELD dat_fim_vigencia
            END IF
            
            IF p_preco.dat_ini_vigencia > p_preco.dat_fim_vigencia THEN
               ERROR 'Per�odo de vig�ncia inv�lido.'
               NEXT FIELD dat_fim_vigencia
            END IF
            
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1247_listagem()
#--------------------------#     

   IF NOT pol1247_parametros('L') THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1247_escolhe_saida() THEN
   		RETURN FALSE
   END IF
      
   IF NOT pol1247_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   LET sql_stmt = "SELECT * FROM preco_frete_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_transpor, cod_tip_veiculo, tip_carga, ",
                  "          cod_cidade_orig, cod_rota_orig, num_versao "

   PREPARE var_imp FROM sql_stmt   
   DECLARE cq_impressao CURSOR FOR var_imp

   FOREACH cq_impressao INTO p_preco.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         EXIT FOREACH 
      END IF 
      
      {CALL pol1247_le_den_transpor(p_preco.cod_transpor)

      CALL pol1247_le_den_cidade(p_preco.cod_cidade_orig)
         RETURNING p_den_cidade_orig, p_estado_orig

      CALL pol1247_le_den_cidade(p_preco.cod_cidade_dest)
         RETURNING p_den_cidade_dest, p_estado_dest}
      
      CALL pol1247_seta_carga()
      
      OUTPUT TO REPORT pol1247_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1247_finaliza_relat()

   RETURN TRUE
     
END FUNCTION 

#----------------------------#
FUNCTION pol1247_seta_carga()#
#----------------------------#

   CASE p_preco.tip_carga
      WHEN 'G' LET p_tip_carga = 'GRANEL'
      WHEN 'S' LET p_tip_carga = 'SECA'
   END CASE

END FUNCTION
      
#-------------------------------#
 FUNCTION pol1247_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1247_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1247.tmp'
         START REPORT pol1247_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1247_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1247_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1247_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1247_relat   

   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1247_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 137, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL1247",
               COLUMN 052, "TABELA DE PRECO DE FRETE",
               COLUMN 117, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   VEICULO    CARGA   CID ORIG ROT ORIG  CID DEST ROT DEST PRIMEIRA VIAG  DEMAIS VIAG  VAL PEDAGIO VAL ADICIONAL PERIODO DE VIGENCIA   TC TV NV'                         
         PRINT COLUMN 001, '---------------- --------- -------- -------- --------  -------- -------- ------------- ------------- ----------- ------------- ---------- ---------- -- -- --'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'TRANSPORTADORA   VEICULO    CARGA   CID ORIG ROT ORIG  CID DEST ROT DEST PRIMEIRA VIAG  DEMAIS VIAG  VAL PEDAGIO VAL ADICIONAL PERIODO DE VIGENCIA   TC TV NV'                         
         PRINT COLUMN 001, '---------------- --------- -------- -------- --------  -------- -------- ------------- ------------- ----------- ------------- ---------- ---------- -- -- --'

      ON EVERY ROW

         PRINT COLUMN 001, p_preco.cod_transpor,
               COLUMN 020, p_preco.cod_tip_veiculo, 
               COLUMN 028, p_preco.tip_carga, ' ', p_tip_carga,
               COLUMN 037, p_preco.cod_cidade_orig,
               COLUMN 046, p_preco.cod_rota_orig USING '####&',
               COLUMN 055, p_preco.cod_cidade_dest,
               COLUMN 064, p_preco.cod_rota_dest USING '####&',
               COLUMN 073, p_preco.val_pri_viagem USING '#,###,###&.&&',
               COLUMN 087, p_preco.val_demais_viag USING '#,###,###&.&&',
               COLUMN 101, p_preco.val_pedagio  USING '###,###&.&&',
               COLUMN 113, p_preco.val_adicional USING '#,###,###&.&&',
               COLUMN 127, p_preco.dat_ini_vigencia,
               COLUMN 138, p_preco.dat_fim_vigencia,
               COLUMN 150, p_preco.tip_cobranca,
               COLUMN 153, p_preco.tip_valor,
               COLUMN 155, p_preco.num_versao USING '#&'
                                             
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#---------------------------#                  
FUNCTION pol1247_reajustar()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1247c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1247c AT 7,27 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_status = FALSE
   
   IF pol1247_info_param() THEN
      CALL log085_transacao("BEGIN")
      IF pol1247_proces_reajuste() THEN
         CALL log085_transacao("COMMIT")
         LET p_status = TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CLOSE WINDOW w_pol1247c
   
   RETURN p_status

END FUNCTION

#----------------------------#

FUNCTION pol1247_info_param()#
#----------------------------#
   
   DEFINE p_pct_txt CHAR(10)
   
   LET p_dat_fim = TODAY + 1
   
   INITIALIZE p_reajuste TO NULL
   LET p_reajuste.pct_frete = 0
   LET p_reajuste.pct_pedagio = 0
   
   INPUT BY NAME                          
         p_reajuste.cod_transpor,    
         p_reajuste.pct_frete,
         p_reajuste.pct_pedagio
      WITHOUT DEFAULTS               
                    
      AFTER FIELD cod_transpor

         IF p_reajuste.cod_transpor IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_transpor   
         END IF

         CALL pol1247_le_den_transpor(p_reajuste.cod_transpor)
          
         IF p_den_transpor IS NULL THEN 
            ERROR 'Transportadora inexistente.'
            NEXT FIELD cod_transpor
         END IF  
         
         DISPLAY p_den_transpor TO den_transpor
         
         SELECT COUNT(cod_transpor)
           INTO p_count
           FROM preco_frete_455
          WHERE cod_transpor = p_reajuste.cod_transpor
            AND dat_fim_vigencia >= p_dat_fim
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','preco_frete_455')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            ERROR 'Transportador sem tabela de pre�os em vig�ncia.'
            NEXT FIELD cod_transpor
         END IF
      
      ON KEY (control-z)
         CALL pol1247_pop_transp()
      
      AFTER INPUT
         IF INT_FLAG THEN
            CALL pol1247_limpa_tela()
            RETURN FALSE
         END IF
         
         IF p_reajuste.pct_frete IS NULL THEN
            LET p_reajuste.pct_frete = 0
         END IF
         
         IF p_reajuste.pct_pedagio IS NULL THEN
            LET p_reajuste.pct_pedagio = 0
         END IF
         
         LET p_msg = NULL
         
         IF p_reajuste.pct_frete > 0 THEN
            LET p_pct_txt = p_reajuste.pct_frete
            LET p_msg = ' - REAJUSTE DE FRETE(',p_pct_txt CLIPPED,')'
         END IF
         
         IF p_reajuste.pct_pedagio > 0 THEN
            LET p_pct_txt = p_reajuste.pct_pedagio
            LET p_msg = p_msg CLIPPED, ' - REAJUSTE DE PEDGIO(',p_pct_txt CLIPPED,')'
         END IF
            
         IF p_msg IS NULL THEN
            ERROR 'Informe os percentuais de reajuste.'
            NEXT FIELD pct_frete
         END IF
      
   END INPUT
      
   RETURN TRUE

END FUNCTION          
         
#---------------------------------#         
FUNCTION pol1247_proces_reajuste()#
#---------------------------------#

   DEFINE p_val_reajuste     DECIMAL(12,2)
          
   MESSAGE 'Processando... '
   
   #lds CALL LOG_refresh_display()	
   
   LET p_preco.operacao = p_msg
   
   
   DECLARE cq_reaj CURSOR FOR
    SELECT *
      FROM preco_frete_455
     WHERE cod_transpor = p_reajuste.cod_transpor
       AND dat_fim_vigencia >= p_dat_fim
   
   FOREACH cq_reaj INTO p_preco.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_reaj')
         RETURN FALSE
      END IF 

      MESSAGE 'Processando... ', p_preco.id_registro
   
      #lds CALL LOG_refresh_display()	
            
      SELECT MAX(num_versao)
        INTO p_num_versao 
        FROM preco_frete_455  
       WHERE cod_transpor = p_preco.cod_transpor
         AND cod_tip_veiculo = p_preco.cod_tip_veiculo
         AND tip_carga =  p_preco.tip_carga
         AND cod_cidade_orig = p_preco.cod_cidade_orig
         AND cod_rota_orig = p_preco.cod_rota_orig
         AND cod_cidade_dest = p_preco.cod_cidade_dest
         AND cod_rota_dest = p_preco.cod_rota_dest

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','preco_frete_455:max')
         RETURN FALSE
      END IF 
      
      IF p_preco.num_versao < p_num_versao THEN
         CONTINUE FOREACH
      END IF
               
      LET p_id_registro = p_preco.id_registro
            
      IF p_preco.dat_ini_vigencia < TODAY THEN
         LET p_dat_fim = TODAY
         LET p_preco.dat_ini_vigencia = TODAY + 1
      ELSE
         LET p_dat_fim = p_preco.dat_ini_vigencia         
      END IF

      LET p_preco.operacao = p_msg
      LET p_preco.num_versao = p_preco.num_versao + 1
      LET p_preco.dat_atualiz = TODAY
      LET p_preco.cod_usuario = p_user
      
      LET p_val_reajuste = p_preco.val_pri_viagem * p_reajuste.pct_frete / 100
      LET p_preco.val_pri_viagem = p_preco.val_pri_viagem + p_val_reajuste

      LET p_val_reajuste = p_preco.val_demais_viag * p_reajuste.pct_frete / 100
      LET p_preco.val_demais_viag = p_preco.val_demais_viag + p_val_reajuste
      
      LET p_val_reajuste = p_preco.val_pedagio * p_reajuste.pct_pedagio / 100
      LET p_preco.val_pedagio = p_preco.val_pedagio + p_val_reajuste
      
      IF NOT pol1247_grav_versao() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   
      
#----------------------------#
 FUNCTION pol1247_pop_transp()
#----------------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
         
         CURRENT WINDOW IS w_pol1247c
         IF p_codigo IS NOT NULL THEN
            LET p_reajuste.cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_transpor
         END IF

   END CASE 

END FUNCTION 

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#

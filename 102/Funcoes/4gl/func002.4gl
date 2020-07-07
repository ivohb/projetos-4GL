
#-------------------------------------------------------------#
#------------funções diversas e não muito complexas-----------#
#-------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_msg           CHAR(150)
END GLOBALS

#--variáveis de uso geral--#

DEFINE p_ind                INTEGER,
       p_msg                CHAR(500),
       p_erro               CHAR(10),
       m_msg                CHAR(500)


#----------------------------------------#
#      Grava auditoria na tabela         #
#          audit_logix padrão            #
#----------------------------------------#
# Retorno: TRUE - sucesso na operação    #
#         FALSE - falha na operação      #
#----------------------------------------#
 FUNCTION func002_grava_auadit(parametro)#
#----------------------------------------#

          #--parâmetros esperados--#
   
   DEFINE parametro     RECORD
          cod_empresa   LIKE audit_logix.cod_empresa,
          texto         LIKE audit_logix.texto,
          num_programa  LIKE audit_logix.num_programa,
          usuario       LIKE audit_logix.usuario
   END RECORD
   
   DEFINE p_dat_proces  DATE,
          p_hor_proces  CHAR(08)

   LET p_dat_proces = TODAY
   LET p_hor_proces = TIME
   
   INSERT INTO audit_logix
    VALUES(parametro.cod_empresa,
           parametro.texto,
           parametro.num_programa,
           p_dat_proces,
           p_hor_proces,
           parametro.usuario)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_logix')
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION
              
#----------------------------------------#
#      Grava auditoria na tabela         #
#          ar_usuario_885                #
#----------------------------------------#
# Retorno: TRUE - sucesso na operação    #
#         FALSE - falha na operação      #
#----------------------------------------#
 FUNCTION func002_ins_operacao(parametro)#
#----------------------------------------#

          #--parâmetros esperados--#
   
   DEFINE parametro     RECORD
          cod_empresa   CHAR(02),
          num_ar        INTEGER,
          usuario       CHAR(08),
          operacao      CHAR(10),
          programa      CHAR(10)
   END RECORD
      
   INSERT INTO ar_usuario_885 (
     cod_empresa,  
     num_aviso_rec,
     usuario,      
     operacao,
     programa)     
    VALUES(parametro.cod_empresa,
           parametro.num_ar,
           parametro.usuario,
           parametro.operacao,
           parametro.programa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ar_usuario_885')
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#--------------------------------------#
#    Atualiza a versão do programa     #
#  na tabela log_versao_prg do Logix   #
#--------------------------------------#
# Parâmetro: versão atual do programa  #
# Retorno: TRUE - sucesso na operação  #
#         FALSE - falha na operação    #
#--------------------------------------#
FUNCTION func002_versao_prg(p_ver_prog)#
#--------------------------------------#
   
   DEFINE p_ver_prog      CHAR(18),
          p_dat_alteracao DATE,
          m_versao        CHAR(18)
          
   DEFINE p_programa RECORD
      nom_programa   CHAR(08),
      ver_programa   CHAR(09)
   END RECORD
   
   LET p_programa.nom_programa = UPSHIFT(p_ver_prog[1,7])     
   LET p_programa.ver_programa = p_ver_prog[9,18]     
   
   SELECT num_versao,
          dat_alteracao
     INTO m_versao,
          p_dat_alteracao
     FROM log_versao_prg
    WHERE num_programa = p_programa.nom_programa

   IF STATUS = 100 THEN
      LET p_dat_alteracao = TODAY
      
      INSERT INTO log_versao_prg(
         num_programa,
         num_versao,
         dat_alteracao)
      VALUES(p_programa.nom_programa,
             p_programa.ver_programa,
             p_dat_alteracao)
   ELSE
      IF m_versao <> p_programa.ver_programa THEN
         LET p_dat_alteracao = TODAY
      END IF
      
      UPDATE log_versao_prg
         SET num_versao = p_programa.ver_programa,
             dat_alteracao = p_dat_alteracao
       WHERE num_programa = p_programa.nom_programa
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------------#
#  Converte interiro para texto, preen-     #
#  chendo com zeros os espaços à esquerda   #
#-------------------------------------------#
# Parâmetro: o inteiro e o tamnho do retorno#
# Retorno: valor convertido                 #
#-------------------------------------------#             
#-------------------------------------------#
FUNCTION func002_strzero(p_valor, p_tamanho)#
#-------------------------------------------#
   
   DEFINE p_valor            INTEGER,
          p_tamanho          INTEGER,
          p_retorno          CHAR(50),
          p_zeros            INTEGER,
          p_val_txt          CHAR(50)
          
		LET p_val_txt = p_valor;
		LET p_zeros = p_tamanho - LENGTH(p_val_txt)
		LET p_retorno = ""
		
		FOR p_ind = 1 TO p_zeros
		    LET p_retorno = p_retorno CLIPPED, '0'
		END FOR
		
		LET p_retorno = p_retorno CLIPPED, p_val_txt
		
		RETURN p_retorno CLIPPED

END FUNCTION

#-------------------------------------------#
#  Converte decimal para texto, preen-      #
#  chendo com zeros os espaços à esquerda   #
#-------------------------------------------#
# Parâmetro: o decimal e o tamnho do retorno#
# Retorno: valor convertido                 #
#-------------------------------------------#             
#---------------------------------------------#
FUNCTION func002_dec_strzero(p_dec, p_tamanho)#
#---------------------------------------------#
   
   DEFINE p_dec              DECIMAL(12,2),
          p_tamanho          INTEGER,
          p_retorno          CHAR(50),
          p_zeros            INTEGER,
          p_val_txt          CHAR(50)
          
		LET p_val_txt = p_dec;
		LET p_zeros = p_tamanho - LENGTH(p_val_txt)
		LET p_retorno = ""
		
		FOR p_ind = 1 TO p_zeros
		    LET p_retorno = p_retorno CLIPPED, '0'
		END FOR
		
		LET p_retorno = p_retorno CLIPPED, p_val_txt
		
		RETURN p_retorno CLIPPED

END FUNCTION

#-------------------------------------------#
#  Tira caracteres de formatação            #
#-------------------------------------------#
# Parâmetro: string formatada               #
# Retorno: string sem formato               #
#-------------------------------------------#             
#-------------------------------------------#
FUNCTION func002_tira_formato(l_conteudo)#--#
#-------------------------------------------#
   
   DEFINE l_conteudo         CHAR(30),
          l_retorno          CHAR(30),
          l_ind              INTEGER,
          l_dig              CHAR(01)
          
    LET l_conteudo = l_conteudo CLIPPED
		LET l_retorno = ""
		
		FOR l_ind = 1 TO LENGTH(l_conteudo)
		    LET l_dig = l_conteudo[l_ind]
		    IF l_dig MATCHES "[.,/-]"  THEN
		    ELSE
		       LET l_retorno = l_retorno CLIPPED, l_dig
		    END IF
		END FOR
				
		RETURN l_retorno CLIPPED

END FUNCTION


#-------------------------------------------#
#       Exibe a versão de programas         #
#-------------------------------------------#
# Parâmetro: nome programa com a sua versão #
# Retorno: nenhum                           #
#-------------------------------------------#             
#-------------------------------------------#
FUNCTION func002_exibe_versao(p_num_versao) #
#-------------------------------------------#
   
   DEFINE  p_num_versao   CHAR(18)
   
   LET p_msg = '        ', p_num_versao CLIPPED,"\n\n",
               "     Autor: Ivo H Barbosa\n",
               "ibarbosa@totvspartners.com.br.com\n",
               "     ivohb.me@gmail.com\n\n",
               "        LOGIX 10.02\n",
               "    www.grupoaceex.com.br\n",
               "    (0xx11) 4991-6667 Com.\n",
               "    (0xx11)94179-6692 Vivo\n",
               "    (0xx11)95118-9707 Tim\n"
               
   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
   

#-------------------------------------------#
#  A partir de uma data inicial e uma quan- #
#  tidade de meses calcula uma data final   #
#-------------------------------------------#
# Parâmetro: data inicial e numero de meses #
# Retorno: data final                       #
#-------------------------------------------#             
#-------------------------------------------------#
FUNCTION func002_dat_validade(p_dt_ini, p_qtd_mes)#
#-------------------------------------------------#
   
   DEFINE p_dt_ini            DATE,
          p_qtd_mes           INTEGER,
          p_mes_atu           INTEGER,
          p_mes_fim           INTEGER,
          p_dia_atu           INTEGER,
          p_ano_atu           INTEGER,
          p_ano_fim           INTEGER,
          p_indice            INTEGER,
          p_dat_txt           CHAR(10),
          p_dt_fim            DATE

   
   IF p_dt_ini IS NULL OR p_qtd_mes IS NULL THEN
      RETURN p_dt_fim
   END IF
   
   LET p_dia_atu = DAY(p_dt_ini)
   LET p_mes_atu = MONTH(p_dt_ini)
   LET p_ano_atu = YEAR(p_dt_ini)    
   LET p_mes_fim = p_mes_atu + p_qtd_mes
   
   LET p_indice = p_mes_fim / 12
   LET p_ano_fim = p_ano_atu + p_indice
   LET p_mes_fim = (p_mes_fim MOD 12)
   
   LET p_dat_txt = p_dia_atu USING '<<', '/', p_mes_fim USING '<<', '/', p_ano_fim USING '<<<<'
   LET p_dt_fim = p_dat_txt
   
   RETURN p_dt_fim
   
END FUNCTION


#-------------------------------------------#
#  remove caracteres especias               #
#-------------------------------------------#
# Parâmetro: uma string                     #
# Retorno: string só com letras e numeros   #
#-------------------------------------------#             
#-----------------------------------------#
FUNCTION func002_retira_especiais(l_texto)#
#-----------------------------------------#
   
   DEFINE l_texto            CHAR(2000),
          l_retorno          CHAR(2000),
          l_carac            CHAR(01),
          l_ind              SMALLINT
          
		LET l_retorno = ''
		
		FOR l_ind = 1 TO LENGTH(l_texto CLIPPED)
        LET l_carac = UPSHIFT(l_texto[l_ind])
        IF l_carac MATCHES '[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ]' THEN 
           LET l_retorno = l_retorno CLIPPED, l_texto[l_ind]
        END IF
		END FOR
		
		RETURN l_retorno CLIPPED

END FUNCTION

#-------------------------------------------#
#  verifica se uma variável está vazia      #
#-------------------------------------------#
# Parâmetro: uma variável e seu tipo        #
#-------------------------------------------#             
#-------------------------------------------#
FUNCTION func002_isEmpty(l_texto, l_tipo)   #
#-------------------------------------------#
   
   DEFINE l_texto            CHAR(2000),
          l_tipo             CHAR(01),
          l_numero           DECIMAL(17,7),
          l_retorno          SMALLINT
   
   LET l_retorno = FALSE
   
   IF l_texto IS NULL THEN
      LET l_retorno = TRUE
   ELSE
      IF l_tipo = 'N' THEN
         LET l_numero = l_texto
         IF l_numero = 0 THEN
            LET l_retorno = TRUE
         END IF
      ELSE
         IF l_tipo = 'C' THEN
            IF l_texto = '' OR l_texto = ' ' THEN
               LET l_retorno = TRUE
            END IF
         END IF
      END IF
   END IF
		
	 RETURN l_retorno 

END FUNCTION

#-------------------------------------------#
#  verifica se um conteúdo só possui digitos#
#-------------------------------------------#
# Parâmetro: variável com o conteudo        #
#-------------------------------------------#             
#-------------------------------------------#
FUNCTION func002_isNumero(l_conteudo)       #
#-------------------------------------------#
   
   DEFINE l_conteudo         CHAR(30),
          l_ind              INTEGER,
          l_char             CHAR(01)          

   FOR l_ind = 1 to LENGTH(l_conteudo CLIPPED)
       LET l_char = l_conteudo[l_ind]
       IF l_char MATCHES '[0123456789]' THEN
       ELSE
          RETURN FALSE
       END IF       
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
#  retorna a descrição do item        #
#-------------------------------------#
# Parâmetro: código do item           #
#-------------------------------------#             
FUNCTION func002_le_den_item(l_codigo)#
#-------------------------------------#
   
   DEFINE l_codigo      LIKE item.cod_item,
          l_desc        LIKE item.den_item
      
   SELECT den_item INTO l_desc
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_codigo

   IF STATUS = 100 THEN
      LET l_desc = 'Produto não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = STATUS
         LET l_desc = 'Erro ',m_msg CLIPPED,
             ' lendo descrição do produto'
      END IF
   END IF
   
   RETURN l_desc

END FUNCTION

#-------------------------------------#
#  retorna a descrição do cliente     #
#-------------------------------------#
# Parâmetro: código do cliente        #
#-------------------------------------#             
FUNCTION func002_le_nom_cliente(l_cod)#
#-------------------------------------#
   
   DEFINE l_cod         LIKE item.cod_item,
          l_desc        LIKE item.den_item
   
   SELECT nom_cliente INTO l_desc
     FROM clientes
    WHERE cod_cliente = l_cod

   IF STATUS = 100 THEN
      LET l_desc = 'Cliente não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = STATUS
         LET l_desc = 'Erro ',m_msg CLIPPED,
             ' lendo descrição do cliente'
      END IF
   END IF
   
   RETURN l_desc

END FUNCTION

#-------------------------------------#
#  retorna a data de fechamento da    #
#         manufatura                  #
#-------------------------------------#
# Parâmetro: nenhum                   #
#-------------------------------------#             
FUNCTION func002_le_fec_man()         #
#-------------------------------------#
   
   DEFINE l_data         DATE
   
   SELECT dat_fecha_ult_man
     INTO l_data
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 100 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,
             ' lendo data de fechamento da manufatura'
   END IF
   
   RETURN l_data

END FUNCTION


#---------------------------------------#
FUNCTION func002_le_estoque(l_parametro)#
#---------------------------------------#
   
   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   DEFINE l_qtd_saldo      DECIMAL(10,3),
          l_qtd_reservada  DECIMAL(10,3)
   
   LET l_qtd_saldo = 0
   LET p_msg = NULL
   
   SELECT SUM(qtd_saldo)
     INTO l_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = l_parametro.cod_empresa
	    AND cod_item      = l_parametro.cod_item
	    AND cod_local     = l_parametro.cod_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'func002_le_estoque - ERRO ',p_erro,' LENDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN p_msg, l_qtd_saldo
   END IF  

   IF l_qtd_saldo IS NULL THEN
      LET l_qtd_saldo = 0
      RETURN p_msg, l_qtd_saldo
   END IF

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = l_parametro.cod_empresa
      AND cod_item    = l_parametro.cod_item
      AND cod_local   = l_parametro.cod_local
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'func002_le_estoque - ERRO ',p_erro,' LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN p_msg, l_qtd_saldo
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   IF l_qtd_reservada >= l_qtd_saldo THEN
      LET l_qtd_saldo = 0
   ELSE   
      LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada
   END IF
   
   RETURN p_msg, l_qtd_saldo

END FUNCTION

#-------------------------------------#
# retorna transação                   #
# da tabela estoque_lote              #
#-------------------------------------#
FUNCTION func002_le_lote(l_parametro) #
#-------------------------------------#
   
   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10),
          num_lote         CHAR(15), #opcional
          ies_situa_qtd    CHAR(01)          
   END RECORD
   
   DEFINE l_num_transac    INTEGER,
          l_msg            CHAR(150),
          l_erro           CHAR(10)
   
   LET l_msg = NULL
   
   SELECT num_transac
     INTO l_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = l_parametro.cod_empresa
	    AND cod_item      = l_parametro.cod_item
	    AND cod_local     = l_parametro.cod_local
      AND ies_situa_qtd = l_parametro.ies_situa_qtd
      AND qtd_saldo > 0
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
   
   IF STATUS = 0 THEN
   ELSE
      LET l_num_transac = 0
      IF STATUS <> 100 THEN
         LET l_erro = STATUS
         LET l_msg = 'func002_le_lote - ERRO ',l_erro,' lendo tab estoque_lote' 
      END IF      
   END IF  
   
   RETURN l_msg, l_num_transac 

END FUNCTION

#------------------------------------------#
# retorna transação                        #
# da tabela estoque_lote                   #
#------------------------------------------#
FUNCTION func002_le_lot_ender(l_parametro) #
#------------------------------------------#
   
   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10),
          num_lote         CHAR(15), #opcional
          ies_situa_qtd    CHAR(01)          
   END RECORD
   
   DEFINE l_num_transac    INTEGER,
          l_msg            CHAR(150),
          l_erro           CHAR(10)
   
   LET l_msg = NULL
   
   SELECT num_transac
     INTO l_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa   = l_parametro.cod_empresa
	    AND cod_item      = l_parametro.cod_item
	    AND cod_local     = l_parametro.cod_local
      AND ies_situa_qtd = l_parametro.ies_situa_qtd
      AND qtd_saldo > 0
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
   
   IF STATUS = 0 THEN
   ELSE
      LET l_num_transac = 0
      IF STATUS <> 100 THEN
         LET l_erro = STATUS
         LET l_msg = 'func002_le_lot_ender - ERRO ',l_erro,' lendo tab estoque_lote_ender' 
      END IF      
   END IF  
   
   RETURN l_msg, l_num_transac 

END FUNCTION

#-------------------------------------#
# retorna transação e saldo disponível#
# da tabela estoque_lote              #
#-------------------------------------#
FUNCTION func002_est_lote(l_parametro)#
#-------------------------------------#
   
   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10),
          num_lote         CHAR(15), #opcional
          ies_situa_qtd    CHAR(01)          
   END RECORD
   
   DEFINE l_qtd_saldo      DECIMAL(10,3),
          l_num_transac    INTEGER,
          l_qtd_reservada  DECIMAL(10,3),
          l_msg            CHAR(150),
          l_erro           CHAR(10)
   
   LET l_qtd_saldo = 0
   LET l_msg = NULL
   
   SELECT qtd_saldo,
          num_transac
     INTO l_qtd_saldo,
          l_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = l_parametro.cod_empresa
	    AND cod_item      = l_parametro.cod_item
	    AND cod_local     = l_parametro.cod_local
      AND ies_situa_qtd = l_parametro.ies_situa_qtd
      AND qtd_saldo > 0
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
   
   IF STATUS = 0 THEN
   ELSE
      LET l_qtd_saldo = 0
      LET l_num_transac = 0
      IF STATUS <> 100 THEN
         LET l_erro = STATUS
         LET l_msg = 'func002_est_lote - ERRO ',l_erro,' lendo tab estoque_lote' 
      END IF
      RETURN l_msg, l_qtd_saldo, l_num_transac 
   END IF  

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = l_parametro.cod_empresa
      AND cod_item    = l_parametro.cod_item
      AND cod_local   = l_parametro.cod_local
      AND ies_situacao = l_parametro.ies_situa_qtd
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
      
   IF STATUS <> 0 THEN
      LET l_erro = STATUS
      LET l_msg = 'func002_est_lote - ERRO ',l_erro,' lendo tab estoque_loc_reser' 
      LET l_qtd_saldo = 0 
      RETURN p_msg, l_qtd_saldo, l_num_transac
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   IF l_qtd_reservada >= l_qtd_saldo THEN
      LET l_qtd_saldo = 0
   ELSE   
      LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada
   END IF
   
   RETURN l_msg, l_qtd_saldo, l_num_transac

END FUNCTION

#------------------------------------------#
# retorna transação e saldo disponível     #
# da tabela estoque_lote_ender             #
#------------------------------------------#
FUNCTION func002_est_lot_ender(l_parametro)#
#------------------------------------------#
   
   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10),
          num_lote         CHAR(15), #opcional
          ies_situa_qtd    CHAR(01)          
   END RECORD
   
   DEFINE l_qtd_saldo      DECIMAL(10,3),
          l_num_transac    INTEGER,
          l_qtd_reservada  DECIMAL(10,3),
          l_msg            CHAR(150),
          l_erro           CHAR(10)
   
   LET l_qtd_saldo = 0
   LET l_msg = NULL
   
   SELECT qtd_saldo,
          num_transac
     INTO l_qtd_saldo,
          l_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa   = l_parametro.cod_empresa
	    AND cod_item      = l_parametro.cod_item
	    AND cod_local     = l_parametro.cod_local
      AND ies_situa_qtd = l_parametro.ies_situa_qtd
      AND qtd_saldo > 0
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
   
   IF STATUS = 0 THEN
   ELSE
      LET l_qtd_saldo = 0
      LET l_num_transac = 0
      IF STATUS <> 100 THEN
         LET l_erro = STATUS
         LET l_msg = 'func002_est_lot_ender - ERRO ',l_erro,' lendo tab estoque_lote_ender' 
      END IF
      RETURN l_msg, l_qtd_saldo, l_num_transac 
   END IF  

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = l_parametro.cod_empresa
      AND cod_item    = l_parametro.cod_item
      AND cod_local   = l_parametro.cod_local
      AND ies_situacao = l_parametro.ies_situa_qtd
      AND ((num_lote = l_parametro.num_lote AND l_parametro.num_lote IS NOT NULL) OR
           (1=1 AND l_parametro.num_lote IS NULL))
      
   IF STATUS <> 0 THEN
      LET l_erro = STATUS
      LET l_msg = 'func002_est_lot_ender - ERRO ',l_erro,' lendo tab estoque_loc_reser' 
      LET l_qtd_saldo = 0 
      RETURN p_msg, l_qtd_saldo, l_num_transac
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   IF l_qtd_reservada >= l_qtd_saldo THEN
      LET l_qtd_saldo = 0
   ELSE   
      LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada
   END IF
   
   RETURN l_msg, l_qtd_saldo, l_num_transac

END FUNCTION

#-------------------------------------------#
FUNCTION func002_verifica_credito(l_cliente)#
#-------------------------------------------#
   
   DEFINE l_cliente            CHAR(15),
          lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
   
   LET g_msg = NULL
      
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = l_cliente
      
   IF STATUS <> 0 THEN
      LET g_msg = 'ERRO ',STATUS USING '<<<<<<',' LENDO TABELA CLI_CREDITO.'
      RETURN FALSE
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET g_msg = 'ERRO ',STATUS USING '<<<<<<',' LENDO TABELA PAR_VDP.'
      RETURN FALSE
   END IF

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         LET g_msg = 'Cliente com duplicatas em atraso excedido.'
         RETURN FALSE
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         LET g_msg = 'Cliente com atraso médio excedido.'
         RETURN FALSE
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'ies_limite_credito'

   IF STATUS = 100 THEN
      LET l_parametro = 'N'
   ELSE
      IF STATUS <> 0 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<',' LENDO TABELA PAR_VDP_PAD.'
         RETURN FALSE
      END IF
   END IF
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + 
                        lr_cli_credito.val_dup_aberto
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         LET g_msg = 'Limite de crédito excedido.'
         RETURN FALSE
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         LET g_msg =  'Data crédito expirada.'
         RETURN FALSE
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
#      Tira espaços da esquerda/direita  #
#----------------------------------------#
# Parâmetro: texto                       #
# Retorno: texto sem espaço              #
#----------------------------------------#
 FUNCTION func002_trim(l_texto)          #
#----------------------------------------#
   
   DEFINE l_texto         CHAR(800),
          l_pos_ini       INTEGER,
          l_pos_fim       INTEGER
   
   FOR l_pos_ini = 1 TO LENGTH(l_texto)
      IF l_texto[l_pos_ini] IS NOT NULL THEN
         EXIT FOR
      END IF
   END FOR
   
   FOR l_pos_fim = LENGTH(l_texto) TO 1 STEP -1
      IF l_texto[l_pos_fim] IS NOT NULL THEN
         EXIT FOR
      END IF
   END FOR
   
   IF l_pos_ini = 0 OR l_pos_ini = 0 THEN
      RETURN ''
   ELSE
      RETURN l_texto[l_pos_ini, l_pos_fim]
   END IF
   
END FUNCTION   

#-------------------------------------------#
#Verifica se a empresa pode usar a aplicação#
#-------------------------------------------#
# Parâmetro: empresa corrente e raiz do cgc #
#   do cliente                              #
# Retorno: TRUE (pode usar) FALSE (Não pode)#
#-------------------------------------------#

#-------------------------------------------#
FUNCTION func002_pega_pirata(mr_control)    #
#-------------------------------------------#

   DEFINE mr_control         RECORD
          cod_empresa        LIKE empresa.cod_empresa,
          raiz_cgc           LIKE empresa.num_cgc,
          dias_valid         INTEGER
   END RECORD
      
   DEFINE l_num_cgc     LIKE empresa.num_cgc

   DEFINE l_raiz_cgc         CHAR(11),
          l_instal           CHAR(08),
          l_control          CHAR(08),
          l_dat_txt          CHAR(10),
          l_dat_inst         DATE,
          l_dat_ctrl         DATE
   
   SELECT num_cgc 
     INTO l_num_cgc
     FROM empresa
    WHERE cod_empresa = mr_control.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF    
   
   LET l_raiz_cgc = l_num_cgc[1,11]
   
   IF l_raiz_cgc <> mr_control.raiz_cgc THEN 
      LET m_msg = 'Você pode estar sendo \n ',
                  'vítima de pirataria.\n',
                  'Processo não autorizado.\n',
                  'Contate ivohb.me@gmail.com'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION
        

#-------------------------------------------#
#criar tabela de controle de autencidade e  #
# grava os parâmetros iniciais              #
#-------------------------------------------#
# Parâmetro: empresa corrente e dias de     #
# controle (validade)                       #
# Retorno: TRUE (sucesso) FALSE (erro)      #
#-------------------------------------------#

#-------------------------------------------#
FUNCTION func002_checa_controle(mr_control) #
#-------------------------------------------#

   DEFINE mr_control         RECORD
          cod_empresa        LIKE empresa.cod_empresa,
          raiz_cgc           LIKE empresa.num_cgc,
          dias_valid         INTEGER
   END RECORD
   
   DEFINE l_dat_atu          DATE,
          l_instal           CHAR(08),
          l_control          CHAR(08),
          l_dat_txt          CHAR(10)
   
   IF log0150_verifica_se_tabela_existe("ctrl_1112") THEN
      RETURN TRUE
   END IF
   
   CREATE  TABLE ctrl_1112 (
    cod_empresa            CHAR(02),
    control01              CHAR(08),
    control02              CHAR(08)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'control')
      RETURN FALSE
   END IF

   CREATE INDEX ix_ctrl_1112
    ON ctrl_1112(cod_empresa);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'ix_control')
      RETURN FALSE
   END IF
 
   LET l_dat_atu = TODAY
   LET l_dat_txt = EXTEND(l_dat_atu, YEAR TO DAY) 
   LET l_instal = l_dat_txt[9,10],l_dat_txt[1,4],l_dat_txt[6,7] #ddyyyymm

   LET l_dat_atu = l_dat_atu + mr_control.dias_valid
   LET l_dat_txt = EXTEND(l_dat_atu, YEAR TO DAY)
   LET l_control = l_dat_txt[9,10],l_dat_txt[1,4],l_dat_txt[6,7] #ddyyyymm
   
   INSERT INTO ctrl_1112 VALUES(mr_control.cod_empresa, l_instal, l_control)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'control')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------------#
#Verifica o prazo de validade da aplicação  #
#-------------------------------------------#
# Parâmetro: empresa corrente               #
# Retorno: TRUE (válido) FALSE (não válido) #
#-------------------------------------------#

#-------------------------------------------#
FUNCTION func002_checa_validade(mr_control) #
#-------------------------------------------#

   DEFINE mr_control         RECORD
          cod_empresa        LIKE empresa.cod_empresa,
          raiz_cgc           LIKE empresa.num_cgc,
          dias_valid         INTEGER
   END RECORD
      
   DEFINE l_instal           CHAR(08),
          l_control          CHAR(08),
          l_dat_txt          CHAR(10),
          l_dat_inst         DATE,
          l_dat_ctrl         DATE
      
   SELECT control01, control02
     INTO l_instal, l_control
     FROM ctrl_1112 WHERE cod_empresa = mr_control.cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','controle')
      RETURN FALSE
   END IF

   LET l_dat_txt = l_instal[1,2],'/',l_instal[7,8],'/',l_instal[3,6]
   LET l_dat_inst = l_dat_txt    
      
   IF l_dat_inst > TODAY THEN
      RETURN FALSE
   END IF
   
   LET l_dat_inst = TODAY
   LET l_dat_txt = EXTEND(l_dat_inst, YEAR TO DAY)
   LET l_instal = l_dat_txt[9,10],l_dat_txt[1,4],l_dat_txt[6,7] #ddyyyymm
   
   UPDATE ctrl_1112 SET control01 = l_instal
    WHERE cod_empresa = mr_control.cod_empresa
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'controle')
      RETURN FALSE
   END IF
   
   LET l_dat_txt = l_control[1,2],'/',l_control[7,8],'/',l_control[3,6]
   LET l_dat_ctrl = l_dat_txt 
   
   IF l_dat_inst > l_dat_ctrl THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
     
END FUNCTION
   

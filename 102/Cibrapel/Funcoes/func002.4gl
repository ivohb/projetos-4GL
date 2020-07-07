
#-------------------------------------------------------------#
#------------funções diversas e não muito complexas-----------#
#-------------------------------------------------------------#

DATABASE logix

#--variáveis de uso geral--#

DEFINE p_ind                INTEGER,
       p_msg                CHAR(500)


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
               "    (0xx11)94179-6633 Vivo\n",
               "    (0xx11)94918-6225 Tim\n"
               
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


#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1185                                                 #
# OBJETIVO: CONSULTA DE SITUAÇÃO DE OP / AR                         #
# AUTOR...: JUCELIO C. S.                                           #
# DATA....: 18/01/2013                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
         p_den_empresa        LIKE empresa.den_empresa,
         p_user               LIKE usuario.nom_usuario,
         p_user_solict        LIKE usuario.nom_usuario,
         p_cod_user           LIKE usuario.nom_usuario,
         p_salto              SMALLINT,
         p_num_seq            SMALLINT,
         P_Comprime           CHAR(01),
         p_descomprime        CHAR(01),
         p_rowid              INTEGER,
         p_retorno            SMALLINT,
         p_status             SMALLINT,
         comando              CHAR(80),
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
         p_versao             CHAR(18),
         p_nom_arquivo        CHAR(100),
         p_nom_tela           CHAR(200),
         p_ies_cons           SMALLINT,
         p_caminho            CHAR(080),
         p_caminho_jar        CHAR(080),
         p_6lpp               CHAR(100),
         p_8lpp               CHAR(100),
         p_msg                CHAR(500),
         p_texto              CHAR(10),
         p_last_row           SMALLINT,
         p_opcao              CHAR(02),
         p_excluiu            SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT
END GLOBALS

  DEFINE array_campo          ARRAY[1000] OF RECORD
         zz2_Produt           CHAR(15),
         zz2_lote             CHAR(16),
         zz2_obs              CHAR(100),
         zz2_tpreg            CHAR(2)
  END RECORD

  
  DEFINE p_campos             RECORD
         tipo                 CHAR(1),
         per_inicio           DATE,
         per_fim              DATE
          
  END RECORD 
  
  DEFINE p_produt             CHAR(15),
         p_lote               CHAR(16),
         p_tpreg              CHAR(2)
         
  DEFINE p_zz2_filial        CHAR(2),
         p_zz2_produt        CHAR(15),
         p_zz2_ar            CHAR(15),
         p_zz2_seqar         CHAR(10),
         p_zz2_lote          CHAR(10),
         p_zz2_qtdlib        CHAR(10),
         p_zz2_qtrej         CHAR(10),
         p_zz2_qtexce        CHAR(10),
         p_zz2_flag          CHAR(1),
         p_zz2_obs           CHAR(100),
         p_zz2_saldo         CHAR(15),
         p_zz2_numseq        CHAR(6),
         p_zz2_data          DATE,
         p_zz2_tpreg         CHAR(2),
         p_zz2_numop         CHAR(6),
         p_zz2_seqlot        CHAR(2),
         p_d_e_l_e_t_        CHAR(1),
         p_r_e_c_n_o_        CHAR(10),
         p_vazio             CHAR(1)   

#----#
MAIN # 
#----#
  CALL log0180_conecta_usuario()

  WHENEVER ANY ERROR CONTINUE
    SET ISOLATION TO DIRTY READ
    SET LOCK MODE TO WAIT 5
  DEFER INTERRUPT
  LET p_versao = "pol1185-10.00.00"
  OPTIONS 
    NEXT KEY control-f,
    INSERT KEY control-i,
    DELETE KEY control-e,
    PREVIOUS KEY control-b

  CALL pol1185_menu()

END MAIN

#-----------------------#
FUNCTION pol1185_menu() #
#-----------------------#

  DEFINE l_tela1 CHAR(1000)
  INITIALIZE l_tela1 TO NULL
  CALL log130_procura_caminho("pol1185") RETURNING l_tela1
  LET l_tela1 = l_tela1 CLIPPED 
  OPEN WINDOW w_cadzz4 AT 02,02 WITH FORM l_tela1
  ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
  DISPLAY p_cod_empresa TO cod_empresa

  MENU "OPCAO" 
     
    COMMAND "Consultar" "Consulta de OP / AR"
      CALL pol1185_selecionar()  
    
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
      DATABASE logix      	
          
    COMMAND KEY("O")"Sobre" "Sobre o Programa"
      CALL f_sobre()
      
    COMMAND "Fim" "Retorna ao menu anterior"
      EXIT MENU      
      
  END MENU
  
  CLOSE WINDOW w_pol1185

END FUNCTION

#------------------#
FUNCTION f_sobre() #
#------------------#

  LET p_msg = p_versao CLIPPED,"\n","\n",
              " LOGIX 10.02 ","\n","\n",
              " Home page: www.aceex.com.br ","\n","\n",
              " (0xx11) 4991-6667 ","\n","\n"

  CALL log0030_mensagem(p_msg,'info')
               
END FUNCTION

#----------------------------#
FUNCTION pol1185_limpa_tela()#
#----------------------------#
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------------#
FUNCTION pol1185_selecionar() #
#-----------------------------#

  CALL pol1185_limpa_tela()
   
  INITIALIZE p_campos TO NULL
   
  LET p_campos.per_inicio = TODAY
  LET p_campos.per_fim = TODAY
  LET p_campos.tipo = 'E' 
   
  INPUT BY NAME  p_campos.* WITHOUT DEFAULTS
       
    AFTER FIELD per_inicio
      IF p_campos.per_inicio = ''THEN
        ERROR 'Selecione a data de Inicio da Consulta!'
        NEXT FIELD per_inicio
      END IF   
        
    AFTER FIELD per_fim
      IF p_campos.per_fim = ''THEN
        ERROR 'Selecione a data de Fim da Consulta!'
        NEXT FIELD per_fim
      END IF               
  END INPUT 
  
  CALL pol1185_populaArray()
  
END FUNCTION

#------------------------------#
FUNCTION pol1185_populaArray() #
#------------------------------#
  
  INITIALIZE array_campo TO NULL
  LET p_ind = 1
  
  IF p_campos.tipo IS NOT NULL THEN
    DECLARE c_zz2010 CURSOR FOR
      SELECT ZZ2_PRODUT,ZZ2_LOTE,ZZ2_OBS,ZZ2_TPREG FROM ZZ2010 
        WHERE ZZ2_DATA BETWEEN p_campos.per_inicio AND p_campos.per_fim 
          AND ZZ2_TPREG = p_campos.tipo
  ELSE
    DECLARE c_zz2010 CURSOR FOR    
      SELECT ZZ2_PRODUT,ZZ2_LOTE,ZZ2_OBS,ZZ2_TPREG FROM ZZ2010 
        WHERE ZZ2_DATA BETWEEN p_campos.per_inicio AND p_campos.per_fim 

  END IF      

  FOREACH c_zz2010 INTO    
    array_campo[p_ind].zz2_Produt,
    array_campo[p_ind].zz2_lote,
    array_campo[p_ind].zz2_obs,
    array_campo[p_ind].zz2_tpreg
    
    LET p_ind = p_ind + 1
    
    IF p_ind > 1000 THEN
      LET p_msg = 'Limite de documentos ultrapassado!\n'
      CALL log0030_mensagem(p_msg,'excla')
      EXIT FOREACH
    END IF  
  END FOREACH  
   
  IF p_ind > 1  THEN
  
    CALL SET_COUNT(p_ind - 1)
    
    INPUT ARRAY array_campo
      WITHOUT DEFAULTS FROM ar_campos.*
        ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
        LET p_ind = ARR_CURR()
        LET s_ind = SCR_LINE() 
 
      ON KEY (control-z)
        IF (array_campo[p_ind].zz2_Produt IS NOT NULL) 
        AND(array_campo[p_ind].zz2_lote   IS NOT NULL) 
        AND(array_campo[p_ind].zz2_tpreg  IS NOT NULL) THEN 
          LET   p_produt   =  array_campo[p_ind].zz2_Produt
          LET   p_lote     =  array_campo[p_ind].zz2_lote
          LET   p_tpreg    =  array_campo[p_ind].zz2_tpreg
          CALL pol1185_detalhe()
        END IF   
    END INPUT   
  END IF    
             
END FUNCTION

#--------------------------#
FUNCTION pol1185_detalhe() #
#--------------------------#

  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol11851") RETURNING p_nom_tela
  LET p_nom_tela = p_nom_tela CLIPPED
  OPEN WINDOW w_pol11851 AT 02,02 WITH FORM p_nom_tela
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
     
  SELECT ZZ2_FILIAL,ZZ2_PRODUT,ZZ2_AR,ZZ2_SEQAR,ZZ2_LOTE,ZZ2_QTDLIB,ZZ2_QTREJ,
         ZZ2_QTEXCE,ZZ2_FLAG,ZZ2_OBS,ZZ2_SALDO,ZZ2_NUMSEQ,ZZ2_DATA,ZZ2_TPREG,
         ZZ2_NUMOP,ZZ2_SEQLOT,D_E_L_E_T_,R_E_C_N_O_ 
         INTO
         p_zz2_filial,p_zz2_produt,p_zz2_ar,p_zz2_seqar,p_zz2_lote,p_zz2_qtdlib,p_zz2_qtrej,
         p_zz2_qtexce,p_zz2_flag,p_zz2_obs,p_zz2_saldo,p_zz2_numseq,p_zz2_data,p_zz2_tpreg,
         p_zz2_numop,p_zz2_seqlot,p_d_e_l_e_t_,p_r_e_c_n_o_        
    FROM ZZ2010  
      WHERE ZZ2_PRODUT = array_campo[p_ind].ZZ2_PRODUT AND
            ZZ2_LOTE   = array_campo[p_ind].ZZ2_LOTE AND
            ZZ2_TPREG  = array_campo[p_ind].ZZ2_TPREG
     
  DISPLAY p_zz2_filial,p_zz2_produt,p_zz2_ar,p_zz2_seqar,p_zz2_lote,p_zz2_qtdlib,p_zz2_qtrej,
          p_zz2_qtexce,p_zz2_obs,p_zz2_saldo,p_zz2_numseq,p_zz2_data,p_zz2_tpreg,
          p_zz2_numop,p_zz2_seqlot
          TO
          zz2_filial,zz2_produt,zz2_ar,zz2_seqar,zz2_lote,zz2_qtdlib,zz2_qtrej,
          zz2_qtexce,zz2_obs,zz2_saldo,zz2_numseq,zz2_data,zz2_tpreg,
          zz2_numop,zz2_seqlot
     
  INPUT   p_vazio FROM  vazio
    AFTER FIELD vazio
      LET  p_vazio = ''
    DISPLAY  p_vazio  TO  vazio             
  END INPUT 
  
  CLOSE WINDOW w_pol11851

END FUNCTION

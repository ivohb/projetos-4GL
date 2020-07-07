# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: POL0138                                                 #
# MODULOS.: POL0138 LOG0010 LOG0030 LOG0050 LOG0060 LOG0130 LOG0280 #
# OBJETIVO: IMPRIME ORDEM DE PRODUCAO POR PROCESSO                  #
# CLIENTE.: POLIMETRI                                               #
# DATA....: 12/04/2001                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_aviso_ent         RECORD LIKE aviso_ent.*,
       	 p_user              LIKE usuario.nom_usuario,
       	 p_status            SMALLINT,
       	 comando             CHAR(80),
       	 p_nom_arquivo       CHAR(100),
         p_caminho2          CHAR(80),
         p_nom_arquivo1      CHAR(100),
         p_ies_impressao     CHAR(001),
         p_num_programa      CHAR(007),
         g_ies_ambiente      CHAR(01),
         p_msg               CHAR(300),
       	 p_den_empresa       LIKE empresa.den_empresa


  DEFINE p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_cancel               INTEGER,
         p_cod_unid_med             LIKE item.cod_unid_med,
         p_ordens            RECORD LIKE ordens.*,
         p_seq_processo             INTEGER,
         p_cod_operac               LIKE consumo.cod_operac,
         p_cod_arranjo              LIKE consumo.cod_arranjo,
         p_den_operac               LIKE operacao.den_operac,
         p_cod_ferramenta           LIKE consumo_fer.cod_ferramenta,
       	 p_cod_recur                LIKE recurso.cod_recur,    
       	 p_den_recur                LIKE recurso.den_recur,   
       	 p_tex_processo             LIKE consumo_txt.tex_processo,     
       	 p_num_seq_linha            INTEGER,    
       	 p_cont                     SMALLINT,
       	 p_cod_item                 LIKE item.cod_item,
       	 p_den_item                 LIKE item.den_item,
       	 p_des_compon_reduz         LIKE componente.des_compon_reduz
 

 DEFINE p_tela
      RECORD
        cod_empresa         CHAR(02),
        ord_inicial       LIKE   ordens.num_ordem,
        ord_final         LIKE   ordens.num_ordem
      END RECORD

 DEFINE p_relat
       RECORD
         num_ordem        DECIMAL(7,0),                 
         cod_item         LIKE ordens.cod_item, 
         den_item         LIKE item.den_item,  
         cod_unid_med     LIKE item.cod_unid_med,
         dat_abert        LIKE ordens.dat_abert,
         dat_ini          LIKE ordens.dat_ini,
         cod_operac       LIKE consumo.cod_operac,
         den_operac       LIKE operacao.den_operac,
         qtd_planej       LIKE ordens.qtd_planej,
       	 cod_recur        LIKE recurso.cod_recur,    
       	 den_recur        LIKE recurso.den_recur,    
       	 tex_processo1    LIKE consumo_txt.tex_processo,    
       	 tex_processo2    LIKE consumo_txt.tex_processo,    
       	 des_compon_reduz LIKE componente.des_compon_reduz
      END RECORD
         

  DEFINE  p_versao  CHAR(18)

 END GLOBALS


MAIN
LET p_versao = "pol0138-10.02.01"
LET p_num_programa = "POL0138"                       
WHENEVER ERROR CONTINUE
SET ISOLATION TO DIRTY READ
WHENEVER ERROR STOP
                       
DEFER INTERRUPT
                       
  CALL log130_procura_caminho("man.iem") RETURNING comando
  OPTIONS
    NEXT KEY CONTROL-F,
    PREVIOUS KEY CONTROL-B,
    FIELD ORDER UNCONSTRAINED,
     HELP FILE comando


    WHENEVER ERROR CONTINUE


    WHENEVER ERROR STOP

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol138_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol138_controle()
#--------------------------#

  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0138") RETURNING comando
  OPEN WINDOW w_pol0138 AT 2,02 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informar"    "Informar parametros"      
      HELP 0002 
      MESSAGE ""
      IF   pol138_entrada_dados() 
           THEN NEXT OPTION "Processar"
      ELSE
           ERROR "Informar parametros"
      END IF
    COMMAND "Processar"   "Processa emissao de ordens de producao"
      HELP 0002
      MESSAGE ""
      IF   p_tela.ord_final             IS NULL OR
           p_tela.ord_final  =  " "             OR  
           p_tela.ord_final  =  0   THEN                    
           ERROR " Falta informar os parametros de entrada para processar. "
           NEXT OPTION "Informar"
      ELSE
           CALL pol138_processa_relatorio()
           NEXT OPTION "Fim"
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0138_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
      DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0138 
END FUNCTION

#-----------------------#
FUNCTION pol0138_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------#
 FUNCTION pol138_entrada_dados()
#-------------------------------#

  DEFINE p_funcao            CHAR(30)
  CALL log006_exibe_teclas("01 02 07",p_versao)

  CURRENT WINDOW IS w_pol0138
  CLEAR FORM

  LET p_tela.cod_empresa   = p_cod_empresa

  DISPLAY BY NAME p_tela.*
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS


  AFTER FIELD  ord_inicial
     IF   p_tela.ord_inicial           IS NULL OR
          p_tela.ord_inicial =  " "            OR   
          p_tela.ord_inicial =  0                   
     THEN ERROR " Preencher numero de ordem inicial " 
          NEXT FIELD ord_inicial 
     END IF
     IF    pol138_pesq_ord(p_tela.ord_inicial)   THEN 
     ELSE
           NEXT FIELD ord_inicial 
     END IF


  AFTER FIELD  ord_final     
     IF   p_tela.ord_final             IS NULL OR
          p_tela.ord_final  =  " "             OR  
          p_tela.ord_final  =  0                   
     THEN ERROR " Preencher numero de ordem final " 
          NEXT FIELD ord_final    
     END IF
     IF    pol138_pesq_ord(p_tela.ord_final)   THEN 
     ELSE
           NEXT FIELD ord_final   
     END IF
  END  INPUT 
 
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol0138
  IF int_flag = 0 
  THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION  pol138_pesq_ord(p_num_ord)
#-----------------------------------------#

   DEFINE p_num_ord       LIKE ordens.num_ordem  


   SELECT  num_ordem    
     FROM ordens                   
    WHERE cod_empresa = p_cod_empresa           
      AND num_ordem   = p_num_ord  
      GROUP BY 1


     IF sqlca.sqlcode <> 0           THEN
        ERROR " Ordem de producao nao foi encontada" 
        RETURN FALSE
     END IF 

   RETURN TRUE  

END FUNCTION

#-------------------------------------#
 FUNCTION pol138_processa_relatorio()
#-------------------------------------#

  IF log028_saida_relat(17,35) IS NOT NULL THEN
     ERROR "Processando a extracao do relatorio ..."ATTRIBUTE(REVERSE)
     IF p_ies_impressao = "S" THEN
        IF g_ies_ambiente = "U"  THEN
           START REPORT pol0138_relat TO PIPE p_nom_arquivo
        ELSE
           CALL log150_procura_caminho ('LST') RETURNING p_caminho
           LET p_caminho = p_caminho CLIPPED, 'pol0138.tmp'
           START REPORT pol0138_relat TO p_caminho
        END IF
     ELSE
        START REPORT pol0138_relat TO p_nom_arquivo
     END IF
  END IF

 DECLARE ct_ord   CURSOR FOR
   SELECT *                                                       
     FROM ordens                 
    WHERE cod_empresa   = p_cod_empresa            AND
          num_ordem     >= p_tela.ord_inicial      AND 
          num_ordem     <= p_tela.ord_final            

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CURSOR","ORDENS")
   END IF

   FOREACH ct_ord INTO p_ordens.*

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("LEITURA","ORDENS")
      END IF

      SELECT den_item, cod_unid_med 
        INTO p_den_item, p_cod_unid_med          
        FROM item   
       WHERE cod_empresa=p_cod_empresa       AND
             cod_item   = p_ordens.cod_item     

      IF sqlca.sqlcode <>  0   
         THEN
         CALL log003_err_sql("SELECT","ITEM")
         RETURN 
      END IF

      CALL  pol138_trata_operacoes()

   END FOREACH                          

  FINISH REPORT pol0138_relat

  ERROR "Fim de processamento... "

 IF  p_ies_impressao = "S" THEN
     MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
              ATTRIBUTE(REVERSE)
     IF g_ies_ambiente = "W" THEN
        LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
        RUN comando
     END IF
 ELSE
     MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " ATTRIBUTE(REVERSE)
 END IF






END FUNCTION
#---------------------------------#
 FUNCTION  pol138_trata_operacoes()
#----------------------------------#

 DECLARE ct_cons  CURSOR FOR

   SELECT a.operacao, a.seq_processo, a.arranjo,  b.den_operac 
     FROM man_processo_item a, operacao b
    WHERE a.empresa = p_cod_empresa          AND 
          a.item   =  p_ordens.cod_item      AND
          a.roteiro = p_ordens.cod_roteiro   AND
          a.empresa = b.cod_empresa          AND
          a.operacao = b.cod_operac

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CURSOR","CONSUMO")
   END IF

   FOREACH ct_cons INTO p_cod_operac, p_seq_processo, p_cod_arranjo, p_den_operac 



     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("LEITURA","CONSUMO")
        EXIT FOREACH
     END IF

     INITIALIZE p_relat.* TO NULL

     LET p_relat.num_ordem    = p_ordens.num_ordem   
     LET p_relat.cod_operac   = p_cod_operac
     LET p_relat.den_operac   = p_den_operac
     LET p_relat.cod_item     = p_cod_item   
     LET p_relat.den_item     = p_den_item   
     LET p_relat.qtd_planej   = p_ordens.qtd_planej
     LET p_relat.dat_abert    = p_ordens.dat_abert 
     LET p_relat.cod_item     = p_ordens.cod_item      
     LET p_relat.cod_unid_med = p_cod_unid_med      

     
     CALL  pol138_le_ferram()

     CALL  pol138_le_recurso()

     CALL  pol138_le_texto()

     OUTPUT TO REPORT pol0138_relat(p_relat.*)

   END FOREACH   


END FUNCTION
#--------------------------#
 FUNCTION  pol138_le_ferram()
#--------------------------#

WHENEVER ERROR CONTINUE

 DECLARE ct_fer   CURSOR FOR
   SELECT a.ferramenta, b.des_compon_reduz
     FROM man_ferramenta_processo a, componente b
    WHERE a.empresa     = p_cod_empresa
      AND a.empresa     = b.cod_empresa 
      AND a.ferramenta  = b.cod_compon 
      AND a.seq_processo = p_seq_processo

   FOREACH ct_fer INTO p_cod_ferramenta  , p_des_compon_reduz

      IF sqlca.sqlcode = NOTFOUND  THEN 
         LET  p_relat.des_compon_reduz = 0 
         EXIT FOREACH
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","CONSUMO_FER")
         END IF
      END IF

      LET p_relat.des_compon_reduz = p_des_compon_reduz
      EXIT  FOREACH 

   END FOREACH   
END FUNCTION

#----------------------------#
 FUNCTION pol138_le_recurso()
#----------------------------#

WHENEVER ERROR STOP

   DECLARE ct_rec  CURSOR FOR 
   SELECT a.cod_recur, b.den_recur
     FROM rec_arranjo a,  recurso b
    WHERE a.cod_empresa  = p_cod_empresa
      AND a.cod_empresa  = b.cod_empresa     
      AND a.cod_recur    = b.cod_recur
      AND a.cod_arranjo  = p_cod_arranjo

   FOREACH ct_rec INTO p_cod_recur, p_den_recur                                
   
      IF sqlca.sqlcode = NOTFOUND  THEN 
         LET  p_relat.cod_recur = 0 
         LET  p_relat.den_recur = ' ' 
         EXIT FOREACH 	
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","CONSUMO_FER")
            EXIT FOREACH 	
         END IF
      END IF
     
      LET p_relat.cod_recur =  p_cod_recur
      LET p_relat.den_recur =  p_den_recur
      EXIT FOREACH 	

   END FOREACH   
    
END FUNCTION
#-------------------------#
 FUNCTION pol138_le_texto()
#-------------------------#

WHENEVER ERROR STOP

   LET p_cont = 0

  DECLARE ct_tex  CURSOR FOR 
   SELECT texto_processo[1,70] , seq_texto_processo          
     FROM man_texto_processo
    WHERE empresa  = p_cod_empresa
      AND seq_processo = p_seq_processo            
      AND tip_texto     = 'P'        
    ORDER BY seq_texto_processo

   FOREACH ct_tex INTO p_tex_processo, p_num_seq_linha                                          
   
      IF sqlca.sqlcode = NOTFOUND  THEN 
         LET  p_relat.tex_processo1  = ' ' 
         LET  p_relat.tex_processo2  = ' ' 
         EXIT FOREACH 	
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","CONSUMO_FER")
            EXIT FOREACH 	
         END IF
      END IF
  
      LET p_cont = p_cont + 1
      IF p_cont = 1   THEN  
         LET  p_relat.tex_processo1  = p_tex_processo
      ELSE
         IF p_cont = 2   THEN  
            LET  p_relat.tex_processo2  = p_tex_processo
         ELSE
            EXIT  FOREACH 
         END IF 
      END IF 

   END FOREACH   
    
END FUNCTION

#----------------------------#
 REPORT pol0138_relat(p_relat)
#----------------------------#
 DEFINE p_relat
       RECORD
         num_ordem        DECIMAL(7,0),                 
         cod_item         LIKE ordens.cod_item, 
         den_item         LIKE item.den_item,  
         cod_unid_med     LIKE item.cod_unid_med,
         dat_abert        LIKE ordens.dat_abert,
         dat_ini          LIKE ordens.dat_ini,
         cod_operac       LIKE consumo.cod_operac,
         den_operac       LIKE operacao.den_operac,
         qtd_planej       LIKE ordens.qtd_planej,
       	 cod_recur        LIKE recurso.cod_recur,    
       	 den_recur        LIKE recurso.den_recur,    
       	 tex_processo1    LIKE consumo_txt.tex_processo,    
       	 tex_processo2    LIKE consumo_txt.tex_processo,    
       	 des_compon_reduz LIKE componente.des_compon_reduz
      END RECORD

  DEFINE p_total        DECIMAL(14,6),
         p_contador     SMALLINT,
         p_count        SMALLINT

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  66

FORMAT

  ON EVERY ROW

    DISPLAY  "PROCESSANDO A ORDEM= " ,  p_relat.num_ordem at 11, 5 

    PRINT 
    PRINT 
    PRINT COLUMN 060, p_relat.num_ordem,
          COLUMN 070, "/",               
          COLUMN 071, p_relat.cod_operac 
 
    SKIP 4  LINE
    PRINT COLUMN 015, p_relat.den_item     
    PRINT 
    PRINT COLUMN 015, p_relat.cod_item     

    SKIP 2  LINE

    PRINT COLUMN 015, p_relat.qtd_planej   
    PRINT 
    PRINT COLUMN 015, p_relat.dat_abert    
    PRINT COLUMN 015, p_relat.cod_unid_med 

    SKIP 5  LINE

    PRINT COLUMN 010, p_relat.cod_recur,  
          COLUMN 031, p_relat.des_compon_reduz[1,11],
          COLUMN 051, p_relat.den_operac[1,28]

    SKIP 41 LINE

    PRINT COLUMN 005, p_relat.tex_processo1                 
    PRINT COLUMN 005, p_relat.tex_processo2                 
END REPORT

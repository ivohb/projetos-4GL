#-------------------------------------------------------------------#
# SISTEMA.: COMERCIAL                                               #
# PROGRAMA: pol0134                                                 #
# MODULOS.: pol0134 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO - MINUTA DE DESPACHO                          #
# ANALISTA: TONI CATINO                                             #
# AUTOR...: TONI CATINO                                             #
# DATA....: 30/04/1999                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_nff_ant       LIKE fat_nf_mestre.nota_fiscal,
         p_num_nff           LIKE fat_nf_mestre.nota_fiscal,
         p_cod_transpor      LIKE fat_nf_mestre.transportadora,
         p_nf_mestre         RECORD LIKE fat_nf_mestre.*,
         p_clientes          RECORD LIKE clientes.*,
         p_transp            RECORD LIKE clientes.*,
         p_ped_end_ent       RECORD LIKE ped_end_ent.*,
         p_status            SMALLINT,
         p_erro              SMALLINT,
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_caminho           CHAR(080),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(01),
      #  p_versao            CHAR(17),
         p_versao            CHAR(18),
         p_ind               SMALLINT,
         i                   SMALLINT,
         pa_curr, sc_curr    SMALLINT,
         p_ies_cons          SMALLINT,
         p_primeira_vez      SMALLINT,
         p_last_row          SMALLINT,
         p_cont              DECIMAL(2,0),
         p_msg               CHAR(500)

END GLOBALS

   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_6lpp                     CHAR(02),
          p_8lpp                     CHAR(02),
          p_count                    INTEGER,
          p_num_vias                 INTEGER,
          p_num_controle             INTEGER


  DEFINE p_tela         RECORD
                          cod_empresa      LIKE empresa.cod_empresa,
                          num_nff_ini      LIKE fat_nf_mestre.nota_fiscal,
                          num_nff_fin      LIKE fat_nf_mestre.nota_fiscal,
                          num_vias         INTEGER
                        END RECORD


  DEFINE p_relat    RECORD
     num_controle      CHAR(06),
     nom_cliente       CHAR(36), 
     end_cliente       CHAR(36),       
     den_bairro        CHAR(20),       
     cid_cliente       CHAR(30),       
     uf_cliente        CHAR(02),       
     num_cgc_cpf       CHAR(20),       
     ins_estadual      CHAR(20),       
     cod_cep           CHAR(10),       
     num_nff           INTEGER,        
     dat_emiss         CHAR(20),       
     num_pedido        INTEGER,   
     end_entrega       CHAR(36),     
     cod_repres        INTEGER,  
     nom_repres        CHAR(30),      
     nom_transp        CHAR(36),       
     tel_transp        CHAR(20),       
     end_transp        CHAR (55),  
     bai_transp        CHAR(20),    
     cid_transp        CHAR(30),       
     val_tot_nff       CHAR(20),       
     pes_bruto         CHAR(20),       
     pes_liquido       CHAR(20),       
     marca             CHAR(10),       
     numero            CHAR(10),
     qtd_embal         CHAR(05),
     especie           CHAR(03),       
     impress           INTEGER,        
     usuario           CHAR(08),       
     cod_empresa       CHAR(02)        
END RECORD

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300
  DEFER INTERRUPT
	LET p_versao = "pol0134-10.02.03"
  INITIALIZE p_nom_help TO NULL
  CALL log140_procura_caminho("pol0134.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help   ,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
       

   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   #LET p_status = 0
       
  IF  p_status = 0  THEN
      CALL pol0134_controle()
  END IF
  
END MAIN

#--------------------------#
 FUNCTION pol0134_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol0134") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED
 OPEN WINDOW w_pol0134 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

      COMMAND "Listar" "Lista dados na tela e para relatorio. "
      
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      
      IF pol0134_consulta() THEN
         CALL pol0134_chama_delphi()
         ERROR 'Operação efetuada com sucesso.'
      ELSE
         ERROR 'Operação cancelada.'
      END IF
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0134_sobre()
      
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
    CLOSE WINDOW w_pol0134
    
 END FUNCTION

#---------------------------#
FUNCTION pol0134_limpa_tab()#
#---------------------------#
   
   DELETE FROM minuta_cairu
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
   
   SELECT COUNT(*)
     INTO p_count
     FROM minuta_cairu
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
           
   IF p_count > 0 THEN 
      LET p_msg = 'Não foi possivel limpar tabela minuta_cairu.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE 

END FUNCTION

#-------------------------------#
FUNCTION pol0134_chama_delphi()#
#-------------------------------#

   DEFINE p_param    CHAR(42),
          p_comando  CHAR(200)

   SELECT COUNT(*)
     INTO p_count
     FROM minuta_cairu
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','minuta_cairu')
      RETURN
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'Não há dados a serem impressos,\n',
                  'para os parâmetros indformados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN
   END IF
   
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
   
   LET p_param = p_cod_empresa, ' ', p_user

   LET p_comando = p_caminho CLIPPED, 'pgi1176.exe ', p_param

   CALL conout(p_comando)

   CALL runOnClient(p_comando)

END FUNCTION   



#---------------------------------------#
 FUNCTION pol0134_consulta()
#---------------------------------------#

 DEFINE where_clause, sql_stmt CHAR(500),
        p_cod_item             LIKE mov_est_fis.cod_item,
        p_qtd_embal            LIKE fat_nf_embalagem.qtd_volume

 IF NOT pol0134_limpa_tab() THEN
    RETURN FALSE
 END IF

 INITIALIZE p_tela.*   TO NULL
 LET p_tela.num_vias = 2
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0134
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 DISPLAY BY NAME p_tela.cod_empresa
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    AFTER FIELD num_nff_ini
       IF p_tela.num_nff_ini IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD num_nff_ini
       END IF

    AFTER FIELD num_nff_fin
       IF p_tela.num_nff_fin IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD num_nff_fin
       END IF

   AFTER INPUT
      IF NOT int_flag THEN
         IF p_tela.num_vias IS NULL OR 
             p_tela.num_vias <= 0 THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD num_vias
         END IF
      END IF
      
END INPUT

IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL
   RETURN FALSE
END IF

LET p_num_vias = p_tela.num_vias
INITIALIZE p_relat TO NULL

SELECT MAX(num_controle)
  INTO p_num_controle
  FROM controle_cairu
 WHERE cod_empresa = p_cod_empresa

IF STATUS <> 0 THEN
   CALL log003_err_sql('SELECT','controle_cairu')
   RETURN FALSE
END IF

IF p_num_controle IS NULL THEN
   LET p_num_controle = 0
   INSERT INTO controle_cairu VALUES(p_cod_empresa, 0)
END IF
   

{IF log028_saida_relat(17,35) IS NOT NULL THEN
   ERROR "Processando a extracao do relatorio ..."ATTRIBUTE(REVERSE)
   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U"  THEN
         START REPORT pol0134_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0134.tmp'
         START REPORT pol0134_relat TO p_caminho 
      END IF
   ELSE
      START REPORT pol0134_relat TO p_nom_arquivo
   END IF
END IF 
}

 CURRENT WINDOW IS w_pol0134

{LET p_comprime    = ascii 15
LET p_descomprime = ascii 18
LET p_6lpp        = ascii 27, "2"
LET p_8lpp        = ascii 27, "0"
}

LET p_relat.usuario = p_user
LET p_relat.cod_empresa = p_cod_empresa

DECLARE cq_consulta CURSOR FOR
    SELECT *                            
      FROM fat_nf_mestre m
     WHERE m.nota_fiscal >= p_tela.num_nff_ini
       AND m.nota_fiscal <= p_tela.num_nff_fin
       AND m.empresa = p_cod_empresa
FOREACH cq_consulta INTO p_nf_mestre.*                                

  LET p_relat.num_nff = p_nf_mestre.nota_fiscal 
  LET p_relat.val_tot_nff = p_nf_mestre.val_nota_fiscal  USING '##,###,###,##&.&&'
  LET p_relat.pes_bruto   = p_nf_mestre.peso_bruto   
  LET p_relat.pes_liquido = p_nf_mestre.peso_liquido
  LET p_relat.dat_emiss   = DATE(p_nf_mestre.dat_hor_emissao)   

	SELECT representante 
	INTO p_relat.cod_repres 
	FROM fat_nf_repr 
		where  empresa = p_cod_empresa
  	and trans_nota_fiscal = p_nf_mestre.trans_nota_fiscal

  SELECT raz_social
    INTO p_relat.nom_repres 
    FROM representante
   WHERE cod_repres = p_relat.cod_repres 

  DECLARE cq_pedido   CURSOR FOR
    SELECT pedido                   
      FROM fat_nf_item   
     WHERE empresa = p_nf_mestre.empresa 
       AND trans_nota_fiscal = p_nf_mestre.trans_nota_fiscal
  FOREACH cq_pedido   INTO p_relat.num_pedido                           
 
    EXIT FOREACH

  END FOREACH

  SELECT a.*,cod_uni_feder,den_cidade                    
    INTO p_clientes.*,p_relat.uf_cliente,p_relat.cid_cliente  
    FROM clientes a, cidades b
   WHERE a.cod_cidade  = b.cod_cidade
           AND a.cod_cliente = p_nf_mestre.cliente

  LET p_relat.nom_cliente = p_clientes.nom_cliente
  LET p_relat.end_cliente = p_clientes.end_cliente 
  LET p_relat.den_bairro = p_clientes.den_bairro 
  LET p_relat.num_cgc_cpf = p_clientes.num_cgc_cpf 
  LET p_relat.ins_estadual= p_clientes.ins_estadual
  LET p_relat.cod_cep     = p_clientes.cod_cep         


  IF p_nf_mestre.transportadora  IS NOT NULL THEN
                 
     SELECT a.*,b.den_cidade                  
       INTO p_transp.*,p_relat.cid_transp   
       FROM clientes a, cidades b
      WHERE a.cod_cidade  = b.cod_cidade
             AND a.cod_cliente = p_nf_mestre.transportadora

     LET p_relat.nom_transp = p_transp.nom_cliente 
     LET p_relat.tel_transp = p_transp.num_telefone  
     LET p_relat.end_transp = p_transp.end_cliente   
     LET p_relat.end_transp = p_transp.end_cliente
     LET p_relat.bai_transp = p_transp.den_bairro
  ELSE    
     SELECT  a.*,b.den_cidade 
       INTO p_ped_end_ent.*,p_relat.cid_transp
       FROM ped_end_ent a,cidades b
      WHERE a.cod_empresa = p_cod_empresa
        AND a.num_pedido = p_relat.num_pedido
        AND a.cod_cidade = b.cod_cidade 

     LET p_relat.end_transp = p_ped_end_ent.end_entrega
     LET p_relat.bai_transp = p_ped_end_ent.den_bairro
    
  END IF

  LET p_relat.marca = "CX" 

    SELECT sum(qtd_volume)              
    INTO p_qtd_embal 
    FROM fat_nf_embalagem                                        
     WHERE empresa = p_cod_empresa 
       AND trans_nota_fiscal = p_nf_mestre.trans_nota_fiscal
    
    IF STATUS <> 0 THEN
       LET p_qtd_embal = 0
    END IF
    
    LET p_relat.qtd_embal = p_qtd_embal USING "###&"
    LET p_relat.numero = p_relat.marca CLIPPED, ' /', p_relat.qtd_embal CLIPPED
    LET p_relat.especie = p_relat.marca    

    LET p_cont = 0

  #OUTPUT TO REPORT pol0134_relat(p_relat.*)
  
  LET p_num_controle = p_num_controle + 1
  
  FOR p_ind = 1 TO p_num_vias
     
     LET p_relat.num_controle = func002_strzero(p_num_controle, 6)
     
     INSERT INTO minuta_cairu VALUES(p_relat.*)
  
     IF STATUS <> 0 THEN
        CALL log003_err_sql('INSERT','minuta_cairu')
        RETURN FALSE
     END IF

  END FOR
  
  INITIALIZE p_relat TO NULL
  LET p_relat.usuario = p_user
  LET p_relat.cod_empresa = p_cod_empresa
  
END FOREACH

UPDATE controle_cairu
  SET num_controle = p_num_controle
 WHERE cod_empresa = p_cod_empresa

IF STATUS <> 0 THEN
   CALL log003_err_sql('UPDATE','controle_cairu')
   RETURN FALSE
END IF

{FINISH REPORT pol0134_relat  

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

LET comando = 'lpdos.bat ' ,p_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
RUN comando}

 RETURN TRUE

END FUNCTION


#----------------------------#
 REPORT pol0134_relat(p_relat)
#----------------------------#
  DEFINE p_relat    RECORD
           nom_cliente       LIKE clientes.nom_cliente,
           end_cliente       LIKE clientes.end_cliente,
           den_bairro        LIKE clientes.den_bairro,
           cid_cliente       LIKE cidades.den_cidade,
           uf_cliente        LIKE cidades.cod_uni_feder, 
           num_cgc_cpf       LIKE clientes.num_cgc_cpf,
           ins_estadual      LIKE clientes.ins_estadual,
           cod_cep           LIKE clientes.cod_cep, 
           num_nff           LIKE fat_nf_mestre.nota_fiscal,	
           dat_emiss         LIKE fat_nf_mestre.dat_hor_emissao,
           num_pedido        LIKE pedidos.num_pedido,
           cod_repres        LIKE fat_nf_repr.representante,
           nom_transp        LIKE clientes.nom_cliente,
           tel_transp        LIKE clientes.num_telefone,
           end_transp        CHAR(55),                     
           cid_transp        LIKE cidades.den_cidade,
           val_tot_nff       LIKE fat_nf_mestre.val_nota_fiscal, 
           pes_bruto         LIKE fat_nf_mestre.peso_bruto,  		
           pes_liquido       LIKE fat_nf_mestre.peso_liquido,		
           cod_embal         LIKE ordem_montag_embal.cod_embal_int,
           qtd_embal         LIKE ordem_montag_embal.qtd_embal_int,
           impress           SMALLINT
                    END RECORD

  DEFINE p_total        DECIMAL(14,6),
         p_contador     SMALLINT,
         p_count        SMALLINT

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  36
FORMAT


    BEFORE GROUP OF p_relat.num_nff 
    SKIP TO TOP OF PAGE 

    PRINT p_6lpp,
          p_descomprime,
          COLUMN 017, p_relat.nom_cliente
    SKIP 1  LINE
    PRINT COLUMN 014, p_relat.end_cliente,
          COLUMN 063, p_relat.cid_cliente
    SKIP  1 LINE
    PRINT COLUMN 014, p_relat.num_cgc_cpf,
          COLUMN 044, p_relat.ins_estadual,
          COLUMN 069, p_relat.uf_cliente
    PRINT COLUMN 069, p_relat.cod_cep   
    SKIP 1 LINE
    PRINT COLUMN 069, p_relat.dat_emiss USING 'dd/mm/yyyy'
    PRINT COLUMN 011, p_relat.num_nff,
          COLUMN 034, p_relat.num_pedido,
          COLUMN 054, p_relat.cod_repres 
    SKIP 1 LINE
    PRINT COLUMN 014, p_relat.nom_transp,
          COLUMN 060, p_relat.tel_transp
    SKIP 1 LINE
    PRINT COLUMN 014, p_relat.end_transp,
          COLUMN 065, p_relat.cid_transp
    SKIP 1 LINE
    PRINT COLUMN 013, p_relat.val_tot_nff   
    SKIP 1 LINE
    PRINT COLUMN 013, p_relat.pes_bruto   USING "###,###,##&.&&&",
          COLUMN 058, p_relat.pes_liquido USING "###,###,##&.&&&"
    SKIP 1 LINE
    PRINT COLUMN 015, p_relat.cod_embal,
          COLUMN 039, p_relat.cod_embal,                                
          COLUMN 042, "/",                  
          COLUMN 043, p_relat.qtd_embal USING "###&",                    
          COLUMN 060, p_relat.qtd_embal USING "###&",                    
          COLUMN 074, p_relat.cod_embal                     
END REPORT


#-----------------------#
 FUNCTION pol0134_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

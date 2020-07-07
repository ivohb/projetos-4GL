# PROGRAMA: pol1306                                                            #
# OBJETIVO: IMPORTAÇÃO DE APONTAMENTOS DO PC_FACTORY                           #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/08/2016                                                         #
# ALTERADO:       www.resgatefacil.com.br                                      #
#------------------------------------------------------------------------------#
{
cDoc := GetSXENum("SC1","C1_NUM")
   SC1->(dbSetOrder(1))

   While SC1->(dbSeek(xFilial("SC1")+cDoc))
    ConfirmSX8()
    cDoc := GetSXENum("SC1","C1_NUM")
   EndDo
}
   
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,
          g_msg                  CHAR(150)         
END GLOBALS

DEFINE    m_msg                  CHAR(150),
          m_erro                 CHAR(10),
          m_cod_empresa          CHAR(02),
          m_apont                SMALLINT,
          m_qtd_movto            DECIMAL(10,3),
          m_tip_movto            CHAR(01),
          m_terminado            CHAR(01),
          m_dtini_prod           DATE,
          m_dtfim_prod           DATE,
          m_hrini_prod           CHAR(08),
          m_hrfim_prod           CHAR(08),
          m_tip_integra          CHAR(01),
          m_integrado            INTEGER,
          m_cod_status           CHAR(01),
          m_qtd_tempo            INTEGER,
          m_dat_ini              DATE,
          m_dat_fim              DATE,
          m_dat_producao         DATE,
          m_hor_ini              CHAR(05),
          m_hor_fim              CHAR(05),
          m_qtd_hor              DECIMAL(10,2),
          m_qtd_estorno          DECIMAL(10,3),
          m_seq_reg_mestre       INTEGER,
          m_qtd_apont            DECIMAL(10,3),
          m_saldo_apont          DECIMAL(10,3),
          m_fat_conver           DECIMAL(12,5),
          m_qtd_conver           DECIMAL(15,3),
          m_tip_prod             CHAR(01),
          m_txt_resumo           CHAR(80),
          m_seq_processo         INTEGER,
          m_qtd_produzida        DECIMAL(10,3), 
          m_qtd_convertida       DECIMAL(10,3),
          m_mot_retrab           CHAR(15),
          m_mot_refugo           CHAR(15),
          m_ies_fecha_op         SMALLINT,
          m_cod_parada           CHAR(20),
          m_dat_proces           DATE,
          m_hor_proces           CHAR(08)
          
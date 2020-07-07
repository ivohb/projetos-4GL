SET ISOLATION TO DIRTY READ

select tabname from systables
where tabname like '%usuar%'

select * from usuarios
select * from usuario_sistema
select * from usuario_senha
select * from user_aprov_265
select * from senha_temp_265
select * from path_logix_v2

select * from PAR_SUP_PAD where cod_empresa = '01' -- contém política de aprovação da empresa (SUP0048)
select * from nivel_autoridade where cod_empresa = '01'  -- contém os níveis de autoridade ex: CO - comprador, SC - supervisor de compra (SUP6040)
select * from SUP_NIV_AUTORID_COMPLEMENTAR where empresa = '01'              -- contém a hierarquia
select * from usuario_nivel_aut where cod_empresa = '01' and ies_versao_atual = 'S' -- contém o nível do usuário. ex: admlog é SC (SUP6050)
select * from USUARIO_NIVEL_SUBS where cod_empresa = '01' and ies_versao_atual = 'S' -- contém usuário substitudo do titular (SUP0810)
select * from USUAR_APROV_FILIAL -- contem as filiais que o usuário poderá aprovar, a partir do nivel de aprovação que o mesmo tem na matriz(SUP4660)

select * from usuario_subs_265

select * from nivel_usuario_265 order by 2,4
select * from nivel_hierarq_265
select * from usuario_nivel_aut where cod_empresa = '01' and nom_usuario = 'berivan'

select * from grade_aprov_oc where cod_empresa = '01' and ies_versao_atual = 'S'  -- contém a grade de arovação das Ordens de Compras para
                                   -- determinado tipo de despesa. ex: tipo desp 101 será aprovada pro CD e depois SC. (SUP6080)
select * from grade_aprov_pc where cod_empresa = '01' and ies_versao_atual = 'S'  -- contém a grade de arovação dos Pedidos de Compras para
                                   -- determinado tipo de despesa. ex: tipo desp 101 será aprovada pro CD e depois SC. (SUP6070)
select * from emp_orig_destino
select * from sup_exc_grd_apr_oc --contém fornecedores/tipos de despesas que não ficarão pedentes de aprovação pela grade de aprovação de OC
select * from item where cod_item = '99.999.8099'
select * from dest_ordem_sup  where cod_empresa = '01' and num_oc = 421899
select * from dest_ordem_sup4  where cod_empresa = '01' and num_oc = 421899
SELECT cod_centro_custo FROM unidade_funcional WHERE cod_empresa = '01' AND cod_uni_funcio = '100000000'
   AND DATE(dat_validade_ini) <= TODAY  AND DATE(dat_validade_fim) >= TODAY
select * from unidade_funcional
select * from linha_prod where cod_lin_prod = 99
select * from linha_prod_cmi
select * from plano_contas where cod_empresa = '99'
select * from ordem_sup where cod_empresa = '01' and num_oc = 421899 421877
select * from cad_cc where cod_cent_cust = 9000
select * from aprov_ordem_sup where cod_empresa = '01'
select * from pedido_sup where cod_empresa = '01' and num_pedido in (25818, 25819, 25821)
select * from ordem_sup where cod_empresa = '01' and num_pedido = 25821
select * from prog_ordem_sup where cod_empresa = '01' and num_oc = 421478
SELECT * FROM AR_PED WHERE COD_EMPRESA='01' AND NUM_PEDIDO=25821
select * from aviso_rec where cod_item = '99.999.9926'  and num_pedido = 25821 and num_aviso_rec = 45285  99.999.9926
--aprovação de PC mod 1 - sup6440
select * from aprov_ped_sup where cod_empresa = '01' and num_pedido = 25783
select * from log_versao_prg where num_programa = 'CAP3560'
select * from usuarios

select * from empresa_temp_265
SELECT * FROM nivel_temp_265


 SELECT * FROM COS_PAGTO_ETAPA WHERE EMPRESA = '01' AND FILIAL = 0 AND NOTA_FISCAL=12345
 AND SERIE_NOTA_FISCAL='U  ' AND SUBSERIE_NF=1 AND HIST_PAGTO[750, 755] ='102285'
select * from nfe_aprov_265
select * from ad_mestre where num_ad = 49
select * from nf_sup where num_aviso_rec = 102268
select * from vencimento_nff where num_nf = 123
select * from pedido_sup_txt where num_pedido  >= 25779
select * from CAP_MSG_SUSP_APROV order by empresa, apropr_desp, num_mensag-- (cap3560)
select * from audit_ar
select * from COS_CONTR_SERVICO
select * from COS_ETAPA_CONTRATO
select * from res_cpr_deb_direto where cod_empresa in ('01','05') order by cod_empresa
select * from unidade_funcional
select * from uni_funcional

select * from usuarios
select * from unid_aprov_265
select * from aprov_etapa_265
select * from usuarios
select * from cos_etapas
select * from cos_oc_etapa
select * from sip_etapa_servico
select * from fornecedor where cod_fornecedor = '061854147000133'
select tabname from systables
where tabname like '%etap%'

select * from item where cod_empresa = '01' and ies_ctr_estoque = 'N' and cod_item = '99.999.8096'
select * from ordem_sup where cod_empresa = '01' and cod_item = '99.999.8096' order by num_oc
select * from ordem_sup where cod_empresa = '01' and num_oc = 315
select * from PROG_ordem_sup where cod_empresa = '01' and num_oc = 315
select * from PROG_ORDEM_SUP_COM where cod_empresa = '01' and num_oc = 315

select * from ORDEM_SUP_AUDIT where cod_empresa = '01' and num_oc = 313

select * from ordem_sup_compl where cod_empresa = '01' and num_oc = 313
select * from pedido_sup where cod_empresa = '01' and num_pedido = 55
select * from comprador
select * from log_versao_prg where num_programa = 'SUP6440'

select * from res_cpr_deb_direto where nom_usuario = 'admlog'
select * from cos_contr_servico
select * from cos_etapa_contrato

    SELECT a.empresa,
           a.contrato_servico,
           a.versao_contrato,
           a.num_etapa,
           b.fornecedor,
           a.dat_vencto_etapa,
           a.val_etapa,
           b.unid_funcional
      FROM cos_etapa_contrato a,
           cos_contr_servico b,
           res_cpr_deb_direto c
     WHERE a.dat_vencto_etapa between '01/01/1990' and '31/12/2999'
       AND a.sit_etapa = 'A'
       AND b.empresa = a.empresa
       AND b.contrato_servico = a.contrato_servico
       AND b.versao_contrato = a.versao_contrato
       AND b.filial = 0
       AND c.cod_empresa = b.empresa
       AND c.cod_uni_funcio = b.unid_funcional
       AND c.nom_usuario = 'admlog'
     ORDER BY a.empresa, a.contrato_servico, a.num_etapa

       select * FROM nivel_temp_265
       SELECT * FROM empresa_temp_265
       select * FROM usuar_aprov_filial --filial que o aprovador de obrigações de aprovação
       select * from resumo_aprov_265


    SELECT a.cod_empresa,
           a.num_contrato,
           a.versao_contrato,
           a.num_etapa,
           b.dat_vencto_etapa,
           b.val_etapa,
           a.usuario_solic
      FROM aprov_etapa_265 a,
           cos_etapa_contrato b,
           res_cpr_deb_direto c
     WHERE a.cod_empresa IN (SELECT DISTINCT empresa FROM empresa_temp_265)
       AND c.nom_usuario = 'admlog'
       AND a.cod_empresa = c.cod_empresa
       AND a.unid_funcional = c.cod_uni_funcio
       AND b.empresa = a.cod_empresa
       AND b.contrato_servico = a.num_contrato
       AND b.versao_contrato = a.versao_contrato
       AND b.num_etapa = a.num_etapa
       AND b.sit_etapa = 'A'
     ORDER BY a.cod_empresa, a.num_contrato, a.num_etapa

      SELECT *
        FROM res_cpr_deb_direto
       WHERE cod_empresa = '01'
         AND cod_uni_funcio = '100000000'
         AND nom_usuario = 'admlog'

  select * from usuario_nivel_subs
   where cod_empresa= '01'
     and cod_usuario_subs='admlog'
     and ies_versao_atual='S'
     and dat_ini_validade<=today and dat_fim_validade>=today

    select a.cod_empresa,
           a.cod_nivel_autorid,
           a.ies_tip_autoridade,
           b.den_nivel_autorid
      from usuario_nivel_aut a,
           nivel_autoridade b
     where a.cod_empresa = '01'
       and a.nom_usuario = 'admlog'
       and a.ies_versao_atual = 'S'
       and b.cod_empresa = a.cod_empresa
       and b.cod_nivel_autorid = a.cod_nivel_autorid

       select * FROM nivel_temp_265
       SELECT * FROM empresa_temp_265
       select * FROM usuar_aprov_filial
       select * from docum_aprovar_265

    SELECT DISTINCT * FROM usuar_aprov_filial
           cod_empresa_filial,
           cod_nivel_autorid
      FROM usuar_aprov_filial
     WHERE cod_empresa = '01'
       AND nom_usuario = 'admlog'
       AND cod_nivel_autorid IN (SELECT nivel_autorid FROM nivel_temp_265)

select * from SUP_NIV_AUTORID_COMPLEMENTAR where empresa = '01'              -- contém a hierarquia
SELECT * FROM empresa_temp_265
SELECT * FROM aprov_ped_sup WHERE nom_usuario_aprov is null and num_pedido > 25800  order by num_pedido
select * from nivel_temp_265
select * from aprov_ped_sup where num_pedido = 25783 and cod_empresa = '01'  AND num_versao_pedido = 1
select * from sup_pc_aprov_uni_func where num_pedido = 25783 and empresa = '01'  AND num_versao_pedido = 1
select * from docum_aprovar_265
select * from resumo_aprov_265
select * from sup_par_ped_compra
select * from pedido_sup where num_pedido >= 25700
select * from ordem_sup where num_pedido = 25783
select * from sup_par_ped_compra where pedido_compra = 25783

    SELECT UNIQUE *
           --b.cod_empresa,
           --b.num_pedido,
           --b.num_versao,
           --b.dat_emis,
           --b.cod_comprador,
           --b.cod_fornecedor,
           --b.val_tot_ped
      FROM aprov_ped_sup a, pedido_sup b
     WHERE a.cod_empresa IN (SELECT DISTINCT empresa FROM empresa_temp_265)
       AND a.cod_nivel_autorid IN (SELECT DISTINCT nivel_autorid FROM empresa_temp_265 )
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")
       AND b.cod_empresa      = a.cod_empresa
       AND b.ies_versao_atual = "S"
       AND b.ies_situa_ped    = "A"
       AND b.num_pedido       = a.num_pedido
       AND b.num_versao       = a.num_versao_pedido
     ORDER BY b.cod_empresa, b.num_pedido

  select aprov_ped_sup.cod_empresa,
         aprov_ped_sup.cod_nivel_autorid,
         aprov_ped_sup.nom_usuario_aprov,
         aprov_ped_sup.dat_aprovacao,
         aprov_ped_sup.hor_aprovacao,
         sup_niv_autorid_complementar.hierarquia
    from sup_niv_autorid_complementar,
         aprov_ped_sup
   where sup_niv_autorid_complementar.empresa = '01'
     and sup_niv_autorid_complementar.nivel_autoridade = aprov_ped_sup.cod_nivel_autorid
     and aprov_ped_sup.cod_empresa = '01'
     and aprov_ped_sup.num_pedido = 25783 -- 2358 2393 2398 2403
     and aprov_ped_sup.num_versao_pedido = 1
     AND (aprov_ped_sup.nom_usuario_aprov IS NULL OR aprov_ped_sup.nom_usuario_aprov = " ")
   order by sup_niv_autorid_complementar.hierarquia desc


      SELECT max(a.hierarquia)
        FROM sup_niv_autorid_complementar a,
             aprov_ped_sup b
       WHERE a.empresa = '01'
         AND b.cod_empresa = a.empresa
         AND b.cod_nivel_autorid = a.nivel_autoridade
         AND b.num_pedido = 25783
         AND b.num_versao_pedido = 1
         AND (b.nom_usuario_aprov IS NULL OR b.nom_usuario_aprov = " ")


 -- delete from aprov_ar_265
 select * from aprov_ar_265 order by cod_empresa, num_aviso_rec, hierarquia desc
 select * from nfe_aprov_265
 select * from erro_pol1159_265
 select * from unid_aprov_265

    SELECT  b.nom_usuario,
            a.nivel_autoridade
      FROM nivel_hierarq_265 a,
           nivel_usuario_265 b
     WHERE a.empresa = '01'
       AND a.empresa = b.cod_empresa
       AND a.nivel_autoridade = b.cod_nivel_autorid
       AND b.ies_versao_atual = 'S'


       SELECT *
         FROM sup_par_ar
        WHERE empresa = '01'
          AND aviso_recebto  in (102166, 102266, 102282, 102283, 102285, 102287)
          AND seq_aviso_recebto = 0
          AND parametro = 'secao_resp_aprov'
order by aviso_recebto

 select * from nivel_hierarq_265
 select * from nivel_usuario_265
 select * from nf_sup where ies_incl_cap = 'X'  and cod_empresa in ('01','05')
 select * from nf_sup where  num_aviso_rec >= 102268
 select * from aviso_rec where num_aviso_rec in (102271, 102282)
 select * from SUP_OBS_AR where aviso_recebto >= 102268
 select distinct a.cod_empresa,  a.num_aviso_rec, b.dat_entrada_nf from aviso_rec a, nf_sup b  where (a.num_pedido is null or a.num_pedido = ' ')
    and b.cod_empresa = a.cod_empresa and b.num_aviso_rec = a.num_aviso_rec and b.ies_incl_cap = 'N'  and b.dat_entrada_nf >= '15/08/2011'
    order by 1, 2, 3
select * from usuarios

  select * from nivel_autoridade where cod_empresa in ('01','05')                                                   SC       GC       CO
  select * from usuario_nivel_aut where cod_empresa in ('01','01') and nom_usuario = 'marisa' in ('admlog','flavio','eliana')  and ies_versao_atual = 'S'
 select * from res_cpr_deb_direto where cod_empresa in ('01','05') order by cod_empresa
 select * from SUP_NIV_AUTORID_COMPLEMENTAR where empresa in ('01','05') and nivel_autoridade in ('SC','GC','CO') ORDER BY 1,3

 select * from dest_aviso_rec  where cod_empresa = '01' and num_aviso_rec >= 102268
 select COD_ITEM,PCT_IPI from item where cod_empresa = '01' and den_item like '%PAPEL%' = '100000034209'
 select * from fornecedor where cod_fornecedor = '000009638000355'
 SELECT * FROM audit_logix  WHERE cod_empresa  = '01' AND num_programa = 'pol1159' ORDER BY data desc, hora DESC

 select * from dest_aviso_rec where cod_empresa = '01' and num_seq = 1 and num_aviso_rec in (
    SELECT DISTINCT a.num_aviso_rec
      FROM aviso_rec a, nf_sup b
     WHERE (a.num_pedido IS NULL OR a.num_pedido = ' ')
       AND b.cod_empresa = a.cod_empresa
       AND b.num_aviso_rec = a.num_aviso_rec
       AND b.ies_incl_cap = 'X'
       AND b.dat_entrada_nf >= '15/08/2011'
       and a.cod_empresa = '01'
)

 select * from aprov_ar_265
 select * from nf_sup where num_aviso_rec = 102166

    SELECT UNIQUE
           b.cod_empresa,
           b.num_aviso_rec,
           b.dat_emis_nf,
           b.cod_fornecedor,
           b.val_tot_nf_d,
           a.cod_nivel_autorid
      FROM aprov_ar_265 a, nf_sup b, nfe_aprov_265 c
     WHERE a.cod_nivel_autorid IN
           (SELECT DISTINCT nivel_autorid FROM nivel_temp_265 WHERE tip_docum = 'AR')
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")
       AND b.cod_empresa   = a.cod_empresa
       AND b.ies_incl_cap  = 'X'
       AND b.num_aviso_rec = a.num_aviso_rec
       AND c.cod_empresa   = b.cod_empresa
       AND c.num_aviso_rec = b.num_aviso_rec
       --AND c.ies_ar_cs     = p_docum
     ORDER BY b.cod_empresa, b.num_aviso_rec

    SELECT UNIQUE
           b.cod_empresa,
           b.num_aviso_rec,
           b.dat_emis_nf,
           b.cod_fornecedor,
           b.val_tot_nf_d
      FROM aprov_ar_265 a, nf_sup b
     WHERE a.cod_empresa IN (SELECT DISTINCT empresa FROM empresa_temp_265)
       AND a.cod_nivel_autorid IN (SELECT DISTINCT nivel_autorid FROM empresa_temp_265 )
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")
       AND b.cod_empresa      = a.cod_empresa
       AND b.ies_incl_cap    = 'X'
       AND b.num_aviso_rec    = a.num_aviso_rec
     ORDER BY b.cod_empresa, b.num_aviso_rec

      SELECT hierarquia FROM sup_niv_autorid_complementar  WHERE empresa IN ('01', '05') AND nivel_autoridade = 'SC'

      -- 102166 102262 102263 102264 102266 102267 102268 102271 / 10340 10345 10346 10347 10349

      SELECT MAX(a.hierarquia) FROM sup_niv_autorid_complementar a, aprov_ar_265 b
       WHERE a.empresa = '01' AND b.cod_empresa = a.empresa AND b.num_aviso_rec = 102271
         AND b.cod_nivel_autorid = a.nivel_autoridade  AND (b.nom_usuario_aprov IS NULL OR b.nom_usuario_aprov = " ")

select * from tipo_despesa where cod_empresa = '02'
select * from emp_orig_destino
select * from usuario_subs_cap where cod_usuario_subs = 'admlog' -- define quem o usuário logado pode substiruir
select * from aprov_necessaria order by 1, 2, 5 -- contém os titutos e quem deve aprovar
select * from docum_tmp_265
select * from par_cap_pad  WHERE COD_EMPRESA = '02' AND COD_PARAMETRO = 'ies_forma_aprov' -- parâmetros do cap
select * from ad_mestre where num_ad in (47,48,49,50) order by NUM_AD   -- titulos do cap
select * from cap_ad_susp_aprov    --cap6260
select * from cap_msg_susp_aprov

    SELECT cod_nivel_autor
      FROM aprov_necessaria
     WHERE cod_empresa = '02'
       AND num_ad = 47
       AND ies_aprovado = 'N'
       AND cod_nivel_autor > 30
     ORDER BY cod_nivel_autor

       SELECT *
         FROM usu_nivel_aut_cap
        WHERE cod_empresa = '02'
          AND cod_nivel_autor = '50'
          AND cod_emp_usuario IS NOT NULL
          AND cod_uni_funcio = '121030000'
          AND ies_versao_atual = 'S'
          AND num_versao IS NOT NULL
          AND ies_tip_autor IS NOT NULL
          AND ies_ativo = 'S'

      SELECT *
        FROM log_usu_dir_relat
       WHERE usuario = 'amanda'
         AND empresa = '01'
         AND sistema_fonte = 'LST'
         AND ambiente = 'W'

-- delete from cap_msg_susp_aprov
  SELECT *  FROM ad_mestre  WHERE cod_empresa = "02"
   AND num_ad IN        (SELECT apropr_desp FROM cap_msg_susp_aprov WHERE empresa = "02" )
   AND dat_emis_nf      BETWEEN "01/01/1901" AND "31/12/2999"
   AND num_ad           BETWEEN       1 AND  999999
   AND cod_tip_despesa  BETWEEN     1 AND  9999 AND num_ad IN
   (SELECT cap_ad_susp_aprov.apropr_desp  FROM cap_ad_susp_aprov cap_ad_susp_aprov
      WHERE cap_ad_susp_aprov.apropr_desp = ad_mestre.num_ad
        AND cap_ad_susp_aprov.empresa     = ad_mestre.cod_empresa)
        ORDER BY num_ad

select * from ad_ap where num_ad >= 47 and num_ad <= 50
select * from ap where num_ap >= 43 and num_ap <= 46
select * from nf_sup where cod_empresa = '01' and num_nf = 19
select * from CAP_MSG_SUSP_APROV order by empresa, apropr_desp, num_mensag-- (cap3560)
select * from ad_mestre where num_ad >= 47 and num_ad <= 50
SELECT * FROM TIPO_DESPESA WHERE  COD_EMPRESA='02'  and IES_PREVISAO='P' AND COD_TIP_DESPESA=1104
select * from nivel_autor_cap --contém nivel de autoridade e sua descrição
select * from usu_nivel_aut_cap where cod_usuario = 'admlog' -- contém o usuário e seu nivel de autoridade para cada unidade funcional
SELECT * FROM USUARIOS WHERE COD_USUARIO = 'admlog'
select * from aprov_necessaria where IES_APROVADO = 'N'
select * from usu_niv_temp_265  --W_CAP3560

       SELECT aprov_necessaria.num_ad,
              aprov_necessaria.num_versao,
              aprov_necessaria.num_linha_grade,
              aprov_necessaria.cod_nivel_autor,
              aprov_necessaria.cod_uni_funcio
         FROM aprov_necessaria, ad_mestre
        WHERE aprov_necessaria.cod_empresa = '02'
          AND aprov_necessaria.num_ad IS NOT NULL
          AND aprov_necessaria.cod_nivel_autor IS NOT NULL
          AND aprov_necessaria.ies_aprovado = 'N'
          AND ad_mestre.cod_empresa = aprov_necessaria.cod_empresa
          AND ad_mestre.num_ad = aprov_necessaria.num_ad
          AND EXISTS
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov_necessaria.cod_empresa
                  AND aprov_necessaria.num_ad IS NOT NULL
                  AND aprov_necessaria.cod_nivel_autor IS NOT NULL
                  AND (tmp.cod_nivel_autor = aprov_necessaria.cod_nivel_autor OR
                       (tmp.cod_nivel_autor <> aprov_necessaria.cod_nivel_autor AND tmp.substituto = 'S'))
                  AND tmp.ies_tip_autor='G')

                  select * from aprov_necessaria
       SELECT aprov.num_ad,
              aprov.num_versao,
              aprov.num_linha_grade,
              aprov.cod_nivel_autor,
              aprov.cod_uni_funcio
         FROM aprov_necessaria aprov
        WHERE aprov.cod_empresa = '02'
          AND aprov.ies_aprovado = 'N'
          AND aprov.num_ad IS NOT NULL
          AND aprov.cod_nivel_autor IS NOT NULL
          AND EXISTS
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov.cod_empresa
                  AND tmp.cod_uni_funcional = aprov.cod_uni_funcio
                  AND aprov.num_ad IS NOT NULL
                  AND aprov.cod_nivel_autor IS NOT NULL
                  AND (tmp.cod_nivel_autor = aprov.cod_nivel_autor OR
                       (tmp.cod_nivel_autor <> aprov.cod_nivel_autor AND tmp.substituto = 'S'))
                  AND tmp.ies_tip_autor='H')


select * from ad_aprov_temp_265 order by 2, 3
alter table ad_aprov_temp_265 add ies_soma char(01)


       SELECT aprov_necessaria.num_ad,
              aprov_necessaria.num_versao,
              aprov_necessaria.num_linha_grade,
              aprov_necessaria.cod_nivel_autor,
              aprov_necessaria.cod_uni_funcio
         FROM aprov_necessaria, ad_mestre
        WHERE aprov_necessaria.cod_empresa = '02'
          AND aprov_necessaria.num_ad IS NOT NULL
          AND aprov_necessaria.cod_nivel_autor IS NOT NULL
          AND aprov_necessaria.ies_aprovado = 'N'
          AND ad_mestre.cod_empresa = aprov_necessaria.cod_empresa
          AND ad_mestre.num_ad = aprov_necessaria.num_ad
          AND EXISTS
              (SELECT DISTINCT aprov_necessaria.cod_empresa
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov_necessaria.cod_empresa
                  AND aprov_necessaria.num_ad IS NOT NULL
                  AND aprov_necessaria.cod_nivel_autor IS NOT NULL
                  AND (tmp.cod_nivel_autor = aprov_necessaria.cod_nivel_autor OR
                      (tmp.cod_nivel_autor = aprov_necessaria.cod_nivel_autor AND tmp.situacao = 'Substituto'))
                  AND tmp.ies_tip_autor = 'G')
        ORDER BY aprov_necessaria.num_ad

       SELECT aprov.num_ad,
              aprov.num_versao,
              aprov.num_linha_grade,
              aprov.cod_nivel_autor,
              aprov.cod_uni_funcio
         FROM aprov_necessaria aprov
        WHERE aprov.cod_empresa = '02'
          AND aprov.ies_aprovado = 'N'
          AND aprov.num_ad IS NOT NULL
          AND aprov.cod_nivel_autor IS NOT NULL
          AND EXISTS
              (SELECT DISTINCT aprov.cod_empresa
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov.cod_empresa
                  AND tmp.cod_uni_funcional = aprov.cod_uni_funcio
                  AND aprov.num_ad IS NOT NULL
                  AND aprov.cod_nivel_autor IS NOT NULL
                  AND (tmp.cod_nivel_autor = aprov.cod_nivel_autor OR
                      (tmp.cod_nivel_autor = aprov.cod_nivel_autor AND tmp.situacao = 'Substituto'))
                  AND tmp.ies_tip_autor = 'H')
        ORDER BY aprov.cod_empresa, aprov.num_ad, aprov.cod_nivel_autor, aprov.cod_uni_funcio

      SELECT par_ies FROM par_cap_pad WHERE cod_empresa   = '02' AND cod_parametro ='ies_forma_aprov' --se 3, respeita a hierarquia
       SELECT * FROM par_cap_pad WHERE cod_empresa   = '02' AND cod_parametro ='ies_forma_aprov'

  SELECT cod_empresa,
         cod_uni_funcio,
         ies_tip_autor,
         cod_nivel_autor,
         cod_emp_usuario
    FROM usu_nivel_aut_cap
   WHERE cod_empresa = '01'
     AND cod_emp_usuario IS NOT NULL
     AND cod_usuario = 'amanda'
     AND cod_uni_funcio IS NOT NULL
     AND ies_versao_atual = 'S'
     AND num_versao IS NOT NULL
     AND ies_tip_autor IS NOT NULL
     AND ies_ativo = 'S'

     insert into usu_niv_temp_265 values('01','100000000','1','','G','N','01')
     insert into usu_niv_temp_265 values('01','121030000','AF','','H','N','01')

SELECT UNIQUE COD_EMPRESA  FROM APROV_NECESSARIA WHERE COD_EMPRESA IN
  ((SELECT UNIQUE COD_EMPRESA FROM PAR_CAP_PAD)) AND IES_APROVADO='N' ORDER BY COD_EMPRESA

SELECT distinct cod_empresa FROM   par_cap_pad order by cod_empresa
WHERE  cod_empresa = ''
       AND cod_parametro = 'ies_forma_aprov'

SELECT a.cod_empresa,
       a.num_ad,
       a.val_tot_nf,
       a.dat_emis_nf,
       a.cod_fornecedor,
       c.raz_social,
       b.ies_aprovado,
       b.dat_aprovacao
FROM   ad_mestre a
       INNER JOIN aprov_necessaria b
               ON b.cod_empresa = a.cod_empresa
                  AND b.num_ad = a.num_ad
       INNER JOIN fornecedor c
               ON c.cod_fornecedor = a.cod_fornecedor
       INNER JOIN usu_nivel_aut_cap e
               ON e.cod_empresa = a.cod_empresa
                  AND e.cod_nivel_autor = b.cod_nivel_autor
                  AND e.cod_uni_funcio = b.cod_uni_funcio
                  AND e.ies_ativo = 'S'

SELECT DISTINCT cod_usuario
FROM   usuario_subs_cap
WHERE  cod_usuario_subs = 'cod_usuario_ad'
       AND "campo.sysdate" BETWEEN dat_ini_validade AND dat_fim_validade
       AND ies_versao_atual = 'S'

SELECT cod_depto
FROM   pg_usuario
WHERE  cod_usuario = 'cod_usuario'

SELECT DISTINCT a.cod_usuario,a.nom_funcionario AS nom_funcionario,
                a.cod_usuario
FROM   usuarios a
       INNER JOIN usuario_cap b
               ON b.cod_usuario = a.cod_usuario
ORDER  BY a.cod_usuario

SELECT b.den_nivel_autor,
       a.cod_usuario_aprov,
       a.dat_aprovacao,
       a.hor_aprovacao
FROM   aprov_necessaria a
       INNER JOIN nivel_autor_cap b
               ON b.cod_empresa = a.cod_empresa
                  AND b.cod_nivel_autor = a.cod_nivel_autor
WHERE  a.num_ad = "ad";

SELECT cod_nivel_autor,
       cod_uni_funcio,
       ies_tip_autor
FROM   usu_nivel_aut_cap
WHERE  cod_empresa = 'cod_empresa'
       AND cod_usuario = 'cod_usuario'

SELECT a.cod_empresa,
       a.num_ad,
       a.val_tot_nf,
       a.dat_emis_nf,
       a.dat_venc,
       b.cod_usuario_aprov,
       c.raz_social,
       d.cod_tip_despesa,
       d.nom_tip_despesa,
       a.observ,
       e.cod_nivel_autor,
       e.cod_uni_funcio,
       f.cod_grp_despesa,
       f.nom_grp_despesa
FROM   ad_mestre a
       INNER JOIN aprov_necessaria b
               ON b.cod_empresa = a.cod_empresa
                  AND b.num_ad = a.num_ad
       INNER JOIN fornecedor c
               ON c.cod_fornecedor = a.cod_fornecedor
       INNER JOIN tipo_despesa d
               ON d.cod_empresa = a.cod_empresa
                  AND d.cod_tip_despesa = a.cod_tip_despesa
       INNER JOIN usu_nivel_aut_cap e
               ON e.cod_empresa = a.cod_empresa
                  AND e.cod_nivel_autor = b.cod_nivel_autor
                  AND e.cod_uni_funcio = b.cod_uni_funcio
                  AND e.ies_ativo = 'S'
       INNER JOIN grupo_despesa f
               ON f.cod_empresa = d.cod_empresa
                  AND f.cod_grp_despesa = d.cod_grp_despesa
WHERE  b.ies_aprovado = 'N'

      SELECT nom_caminho
        FROM log_usu_dir_relat
       WHERE usuario = p_cod_usuario
         AND empresa = p_cod_empresa
         AND sistema_fonte = 'LST'
         AND ambiente = g_ies_ambiente

    SELECT DISTINCT
           cod_usuario, tip_docum
      FROM email_env_265

       SELECT num_docum,
              cod_empresa
         FROM email_env_265
        WHERE cod_usuario = 'ivo'
          AND tip_docum = 'AD'
        ORDER by cod_empresa, num_docum

        select * from resumo_aprov_265
       select * from email_temp_265
       select * from email_env_265
       select * from usuarios where cod_usuario in ('admlog','ivo', 'ibarbosa')

    SELECT DISTINCT nom_usuario  FROM email_temp_265    WHERE tip_docum = 'CS'
    SELECT * FROM email_temp_265 -- WHERE nom_usuario = 'ivo'
        SELECT * FROM email_env_265
      ORDER BY num_docum, num_etapa
    SELECT nom_caminho  FROM path_logix_v2  WHERE cod_sistema = 'JAR'  AND cod_empresa  = '01'  --AND ies_ambiente = 'W'

select * from nf_sup where num_aviso_rec = 102282
    SELECT DISTINCT a.num_aviso_rec, a.cod_empresa,
                    b.ies_incl_cap, b.ies_nf_aguard_nfe
      FROM aviso_rec a, nf_sup b
     WHERE (a.num_pedido IS NULL OR a.num_pedido = ' ')
       AND b.cod_empresa = a.cod_empresa
       AND b.num_aviso_rec = a.num_aviso_rec
       AND b.ies_incl_cap IN ('N','X')
       AND b.dat_entrada_nf >= '15/05/2012'
       AND a.num_aviso_rec NOT IN
           (SELECT c.num_aviso_rec FROM nfe_aprov_265 c
             WHERE c.cod_empresa = a.cod_empresa
               AND c.num_aviso_rec = a.num_aviso_rec)


    SELECT UNIQUE
           b.cod_empresa,
           b.num_aviso_rec,
           b.dat_emis_nf,
           b.cod_fornecedor,
           b.val_tot_nf_d
      FROM aprov_ar_265 a, nf_sup b, nfe_aprov_265 c
     WHERE a.cod_empresa IN (SELECT DISTINCT empresa FROM empresa_temp_265)
       AND a.cod_nivel_autorid IN (SELECT DISTINCT nivel_autorid FROM empresa_temp_265 )
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")
       AND b.cod_empresa   = a.cod_empresa
       AND b.ies_incl_cap  = 'X'
       AND b.num_aviso_rec = a.num_aviso_rec
       AND c.cod_empresa   = b.cod_empresa
       AND c.num_aviso_rec = b.num_aviso_rec
       AND c.ies_ar_cs     = 'AR'
     ORDER BY b.cod_empresa, b.num_aviso_rec

alter table mapa_compras_data_454 add chave_processo decimal(10,0)
select * from mapa_compras_data_454 where cod_empresa = '10'
select * from res_cpr_deb_direto where nom_usuario = 'admlog' order by cod_empresa, cod_uni_funcio
select * from nivel_autorid_265
select * from nivel_hierarq_265 where nivel_autoridade = 'SC'
select * from nivel_usuario_265 where nom_usuario = 'admlog'
select * from sup_niv_autorid_complementar
 SELECT n.*, h.hierarquia
   FROM nivel_autorid_265 AS n
  INNER JOIN nivel_hierarq_265 AS h
     ON n.cod_empresa = h.empresa
    AND n.cod_nivel_autorid = h.nivel_autoridade
    WHERE n.cod_empresa = '01'
      AND n.cod_nivel_autorid = 'SC'

    SELECT a.nivel_autoridade, a.hierarquia
      FROM nivel_hierarq_265 a,               -- sup_niv_autorid_complementar
           nivel_usuario_265 b,               -- usuario_nivel_aut
           res_cpr_deb_direto c
     WHERE c.cod_empresa = '01'
       AND c.cod_uni_funcio = '100000000'
       AND b.cod_empresa = c.cod_empresa
       AND b.ies_versao_atual = 'S'
       AND b.nom_usuario = c.nom_usuario
       AND a.empresa = b.cod_empresa
       AND a.nivel_autoridade = b.cod_nivel_autorid
     ORDER BY a.hierarquia
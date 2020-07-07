<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:24/06/2005
 //M¢dulo:         VDP
 //Processo:       Vendas - Dados de Comissoes
 //-----------------------------------------------------------------------------
 $prog="vdp/vdp0006";
 $versao=1;  
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax,
                b.cod_usuario,b.cod_rep,b.erep,
                b.fone,b.fax,b.celular,b.email

	from	empresa a,
                lt1200:lt1200_usuarios b
	where	a.cod_empresa='".$empresa."'
	        and b.cod_usuario='".$ifx_user."'
	";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($funcio,$res);
 $mat=$cfetch_row($result);

 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_estadual"];


 $mes_ref=substr($dfin,3,2);
 $ano_ref=substr($dfin,6,4);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

  $cons_comis="select * from lt1200_ctr_comis
                       where mes_ref='".$mes_ref."'
                         and ano_ref='".$ano_ref."'
                         and cod_empresa='".$empresa."' ";

  $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_comis = $cquery($cons_comis,$res_comis);
  $mat_sit=$cfetch_row($result_comis);
  $ger=chop($mat_sit["cod_empresa"]);
  if($ger=="")
  {
   $cons_comis="insert into lt1200_ctr_comis (cod_empresa,mes_ref,ano_ref,
          sit_func,sit_rep,sit_aut,sit_fr)
          values('".$empresa."','".$mes_ref."','".$ano_ref."','X','X','X','X')
          ";
               
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);
  }

  $cons_comis="select * from lt1200_ctr_comis
                       where mes_ref='".$mes_ref."'
                         and ano_ref='".$ano_ref."'
                         and cod_empresa='".$empresa."' ";

  $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_comis = $cquery($cons_comis,$res_comis);
  $mat_sit=$cfetch_row($result_comis);

  $sit_func=chop($mat_sit["sit_func"]);
  $sit_rep=chop($mat_sit["sit_rep"]);
  $sit_aut=chop($mat_sit["sit_aut"]);
  $sit_fr=chop($mat_sit["sit_fr"]);
  $tipo=chop($tipo);
  if($tipo=='F')
  {
   if($sit_func<>"F")
   {
    $campo='sit_func';
    $procede="S";
   }else{
    $procede="N";
   } 
  }
  if($tipo=='R')
  {
   if($sit_rep<>"F")
   {
    $campo='sit_rep';
    $procede="S";
   }else{
    $procede="N";
   } 
  }
  if($tipo=='A')
  {
   if($sit_aut<>"F")
   {
    $campo='sit_aut';
    $procede="S";
   }else{
    $procede="N";
   } 
  }
  if($tipo=='C')
  {
   if($sit_fr<>"F")
   {
    $campo='sit_fr';
    $procede="S";
   }else{
    $procede="N";
   } 
  }
  if($procede=="S")
  {
   $cons_comis="delete from lt1200_comissoes
                      where ies_tipo_lancto='G'
                      and mes_ref='".$mes_ref."'
                      and ano_ref='".$ano_ref."'
                      and cod_repres in
                    (select cod_repres from lt1200_representante
                     where tipo='".$tipo."') ";

   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="insert into lt1200_comissoes
              SELECT unique 'NF','G','".$mes_ref."','".$ano_ref."','".$empresa."'
                    ,a.cod_repres,a.num_nff,a.num_nff,a.dat_emissao,
                     a.cod_cliente,a.val_tot_mercadoria,a.val_tot_nff,'',d.cod_nivel_3,
                     f.num_pedido,f.num_pedido_repres,
                     f.dat_emis_repres,f.dat_pedido
              from logix:nf_mestre a,
                   logix:representante b,
                   lt1200_representante c,
                   logix:canal_venda d ,
                   logix:nf_item e,
                   logix:pedidos f
              where
               a.cod_empresa='".$empresa."'
               and a.dat_emissao between '".$dini."' and '".$dfin."'
               and a.ies_situacao  <>'C'
               and b.cod_repres=a.cod_repres
               and c.cod_repres=b.cod_repres
               and c.tipo='".$tipo."'
               and c.pct_nff > 0
               and d.cod_nivel_4=a.cod_repres
               and (a.cod_empresa||a.num_nff||trim(a.cod_cliente)||round(a.cod_repres)) 
           not in (
               select(a.cod_empresa||trim(a.num_nff)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 
               and e.cod_empresa=a.cod_empresa
               and e.num_nff=a.num_nff
               and f.cod_empresa=e.cod_empresa
               and f.num_pedido=e.num_pedido
               ";
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="insert into lt1200_comissoes
              SELECT unique 'NF','G','".$mes_ref."','".$ano_ref."','".$empresa."'
                    ,d.cod_nivel_3,a.num_nff,a.num_nff,a.dat_emissao,
                     a.cod_cliente,a.val_tot_mercadoria,a.val_tot_nff,'',d.cod_nivel_3,
                     f.num_pedido,f.num_pedido_repres,
                     f.dat_emis_repres,f.dat_pedido
              from logix:nf_mestre a,
                   logix:representante b,
                   lt1200_representante c,
                   logix:canal_venda d ,
                   logix:nf_item e,
                   logix:pedidos f
              where
               a.cod_empresa='".$empresa."'
               and a.dat_emissao between '".$dini."' and '".$dfin."'
               and a.ies_situacao  <>'C'
               and b.cod_repres=a.cod_repres
               and d.cod_nivel_4=a.cod_repres
               and c.cod_repres=d.cod_nivel_3
               and c.tipo='".$tipo."'
               and c.pct_nff > 0
               and (a.cod_empresa||a.num_nff||trim(a.cod_cliente)||round(d.cod_nivel_3)) 
           not in  (select(a.cod_empresa||trim(a.num_nff)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 
               and e.cod_empresa=a.cod_empresa
               and e.num_nff=a.num_nff
               and f.cod_empresa=e.cod_empresa
               and f.num_pedido=e.num_pedido
               ";
               
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="insert into lt1200_comissoes
              SELECT unique 'NF','G','".$mes_ref."','".$ano_ref."','".$empresa."'
                    ,a.cod_repres,a.num_nff,a.num_nff,a.dat_emissao,
                     a.cod_cliente,a.val_tot_mercadoria,a.val_tot_nff,'',d.cod_nivel_3,
                     f.num_pedido,f.num_pedido_repres,
                     f.dat_emis_repres,f.dat_pedido
              from logix:nf_mestre a,
                   logix:representante b,
                   lt1200_representante c,
                   logix:canal_venda d ,
                   logix:nf_item e,
                   logix:pedidos f
              where
               a.cod_empresa='".$empresa."'
               and a.dat_emissao between '".$dini."' and '".$dfin."'
               and a.ies_situacao  <>'C'
               and b.cod_repres=a.cod_repres
               and c.cod_repres=b.cod_repres
               and c.tipo='".$tipo."'
               and c.pct_nff > 0
               and d.cod_nivel_3=a.cod_repres
               and d.cod_nivel_4=0
               and (a.cod_empresa||a.num_nff||trim(a.cod_cliente)||round(a.cod_repres)) 
           not in (
               select(a.cod_empresa||trim(a.num_nff)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 
               and e.cod_empresa=a.cod_empresa
               and e.num_nff=a.num_nff
               and f.cod_empresa=e.cod_empresa
               and f.num_pedido=e.num_pedido
               ";
               
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="insert into lt1200_comissoes
               SELECT a.ies_tip_docum,'G','".$mes_ref."','".$ano_ref."',
                    '".$empresa."',c.cod_repres,
                   b.num_docum_origem,b.num_docum,a.dat_pgto,
                    b.cod_cliente,b.val_liquido,a.val_pago,'',e.cod_nivel_3,
                    '','','',''
               from logix:docum_pgto a,
                   logix:docum b,
                   logix:representante c, 
                   lt1200_representante d,
                   logix:canal_venda e
               where
                 a.cod_empresa='".$empresa."'
                 and a.dat_pgto between '".$dini."' and '".$dfin."'
                 and b.cod_empresa=a.cod_empresa
               and b.num_docum=a.num_docum
               and c.cod_repres=b.cod_repres_1
               and a.ies_tip_docum='DP'
               and d.cod_repres=c.cod_repres
               and d.tipo='".$tipo."'
               and d.pct_dp > 0
               and e.cod_nivel_4=b.cod_repres_1
               and (a.cod_empresa||trim(b.num_docum)||trim(b.cod_cliente)||round(b.cod_repres_1)) 
           not in (
               select(a.cod_empresa||trim(a.num_docum)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 

               ";
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="insert into lt1200_comissoes
               SELECT a.ies_tip_docum,'G','".$mes_ref."','".$ano_ref."',
                    '".$empresa."',c.cod_repres,
                   b.num_docum_origem,b.num_docum,a.dat_pgto,
                    b.cod_cliente,b.val_liquido,a.val_pago,'',e.cod_nivel_3,
                    '','','',''
               from logix:docum_pgto a,
                   logix:docum b,
                   logix:representante c, 
                   lt1200_representante d,
                   logix:canal_venda e
               where
                 a.cod_empresa='".$empresa."'
                 and a.dat_pgto between '".$dini."' and '".$dfin."'
                 and b.cod_empresa=a.cod_empresa
               and b.num_docum=a.num_docum
               and c.cod_repres=b.cod_repres_1
               and a.ies_tip_docum='DP'
               and d.cod_repres=c.cod_repres
               and d.tipo='".$tipo."'
               and d.pct_dp > 0
               and e.cod_nivel_3=b.cod_repres_1
               and e.cod_nivel_4=0
               and (a.cod_empresa||trim(b.num_docum)||trim(b.cod_cliente)||round(b.cod_repres_1)) 
           not in (
               select(a.cod_empresa||trim(a.num_docum)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 

               ";
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);


   $cons_comis="insert into lt1200_comissoes
               SELECT a.ies_tip_docum,'G','".$mes_ref."','".$ano_ref."',
                    '".$empresa."',c.cod_repres,
                   b.num_docum_origem,b.num_docum,a.dat_pgto,
                    b.cod_cliente,b.val_liquido,a.val_pago,'',e.cod_nivel_3,
                    '','','',''
               from logix:docum_pgto a,
                   logix:docum b,
                   logix:representante c, 
                   lt1200_representante d,
                   logix:canal_venda e
               where
                 a.cod_empresa='".$empresa."'
                 and a.dat_pgto between '".$dini."' and '".$dfin."'
                 and b.cod_empresa=a.cod_empresa
               and b.num_docum=a.num_docum
               and c.cod_repres=b.cod_repres_1
               and a.ies_tip_docum='DP'
               and d.cod_repres=c.cod_repres
               and d.tipo='".$tipo."'
               and d.pct_dp > 0
               and e.cod_nivel_3=b.cod_repres_1
               and e.cod_nivel_4=0
               and (a.cod_empresa||trim(b.num_docum)||trim(b.cod_cliente)||round(b.cod_repres_1)) 
           not in (
               select(a.cod_empresa||trim(a.num_docum)||trim(a.cod_cliente)||round(a.cod_repres)) 
                       from lt1200_comissoes a
                 where a.ies_tipo_lancto=='G'
                  and a.cod_empresa='".$empresa."') 

               ";
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

   $cons_comis="update lt1200_ctr_comis
                  set $campo='G'
                       where mes_ref='".$mes_ref."'
                         and ano_ref='".$ano_ref."'
                         and cod_empresa='".$empresa."' ";

   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);

//dados de Notas de Devolução

   $cons_comis="SELECT unique 'NF' as ies_tip_docto,'G' as ies_tipo_lancto,
                     '".$mes_ref."' as mes_ref,'".$ano_ref."' as ano_ref,
                     '".$empresa."' as cod_empresa,
                     c.texto_compl1[9,11] as cod_repres ,
                     c.texto_compl2[1,6] as num_nff,
                     a.num_aviso_rec as num_docum,
                     a.dat_entrada_nf as dat_emissao,
                     a.cod_fornecedor as cod_cliente,
                     sum(b.val_base_c_ipi_it) as val_tot_mercadoria,
                     a.val_tot_nf_c as val_tot_docum,
                     c.texto_compl1[13,120] as observacao,
                     c.texto_compl1[1,7] as val_frete
              from logix:nf_sup a,
                   logix:aviso_rec b,
                   logix:nfe_sup_compl c
    where a.cod_operacao[3,5] in ('101','102','201','202')
           and a.dat_entrada_nf between  '".$dini."' and '".$dfin."'
           and b.cod_empresa=a.cod_empresa
           and b.num_aviso_rec=a.num_aviso_rec
           and c.cod_empresa=a.cod_empresa
           and c.num_aviso_rec=a.num_aviso_rec

     group by 1,2,3,4,5,6,7,8,9,10,12,13,14";
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($cons_comis,$res_comis);
   $mat=$cfetch_row($result_comis);
   while (is_array($mat))
   {
    $ies_tip_docto=$mat["ies_tip_docto"]; 
    $ies_tipo_lancto=$mat["ies_tipo_lancto"]; 
    $mes_ref=$mat["mes_ref"];  
    $ano_ref=$mat["ano_ref"];  
    $cod_empresa=$mat["cod_empresa"]; 
    $cod_repres=round($mat["cod_repres"]);  
    $num_nff=round($mat["num_nff"]);  
    $num_docum=$mat["num_docum"];  
    $dat_emissao=$mat["dat_emissao"]; 
    $cod_cliente=$mat["cod_cliente"]; 
    $val_tot_mercadoria=($mat["val_tot_mercadoria"]*-1); 
    $val_tot_docum=($mat["val_tot_docum"]*-1);  
    $val_frete=$mat["val_frete"];
    $val_frete=str_replace(",",".",$val_frete);
    $observacao=$mat["observacao"]; 

    $sel_supervisor="select a.cod_nivel_3,a.cod_nivel_4,b.tipo
                       from canal_venda a,
                          lt1200:lt1200_representante b
                       where a.cod_nivel_4='".$cod_repres."'
                            and b.cod_repres=a.cod_nivel_4
                           ";
    $res_super = $cconnect("logix",$ifx_user,$ifx_senha);
    $result_super = $cquery($sel_supervisor,$res_super);     
    $mat_super=$cfetch_row($result_super);
    $teste=round($mat_super["cod_nivel_4"]);                        
    $cod_supervisor=round($mat_super["cod_nivel_3"]);                        
    $tipo_rep=chop($mat_super["tipo"]);                        
          
    if($teste<>$cod_repres)
    {
     $sel_supervisor="select a.cod_nivel_3,a.cod_nivel_4,b.tipo
                       from canal_venda a,
                            lt1200:lt1200_representante b

                       where a.cod_nivel_3='".$cod_repres."'
                       and a.cod_nivel_4=0 
                       and b.cod_repres=a.cod_nivel_3
                          ";
     $res_super = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_super = $cquery($sel_supervisor,$res_super);     
     $mat_super=$cfetch_row($result_super);
     $teste=round($mat_super["cod_nivel_3"]);                        
     $tipo_sup=chop($mat_super["tipo"]);                        
     $cod_supervisor=round($mat_super["cod_nivel_3"]);                        
    }
     if($num_nff > 0)
     {
      $cons_nff="select f.num_pedido,f.num_pedido_repres,
                     f.dat_emis_repres,f.dat_pedido
              from logix:nf_mestre a,
                   logix:nf_item e,
                   logix:pedidos f
              where
               a.cod_empresa='".$empresa."'
               and a.num_nff='".$num_nff."'
               and e.cod_empresa=a.cod_empresa
               and e.num_nff=a.num_nff
               and f.cod_empresa=e.cod_empresa
               and f.num_pedido=e.num_pedido
               ";
               
      $res_nff = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_nff = $cquery($cons_nff,$res_nff);
      $mat_nff=$cfetch_row($result_nff);
      $num_pedido=$mat_nff["num_pedido"];  
      $num_pedido_repres=$mat_nff["num_pedido_repres"]; 
      $dat_emis_repres=$mat_nff["dat_emis_repres"];  
      $dat_pedido=$mat_nff["dat_pedido"];  
      $teste_nff=round($mat_nff["num_nff"]);
     }

     $cons="select count(cod_repres) as count_rep from 
                   lt1200_comissoes
                where cod_repres='".$cod_repres."'
                   and num_nff='".$num_nff."'
                   and num_docum='".$num_docum."'
                   and val_tot_mercadoria='".$val_tot_mercadoria."'
                   and val_tot_docum='".$val_tot_docum."'
                   and dat_emissao='".$dat_emissao."'
                   and cod_cliente= '".$cod_cliente."' ";
      $res_cons = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_cons = $cquery($cons,$res_cons);
      $mat_cons=$cfetch_row($result_cons);
      $val_rep=round($mat_cons["count_rep"]);  
      if($tipo_rep<>$tipo)
      {
       $val_rep=1;
      }
     if(round($val_rep)==0)
     {                   
      $insere_nfe="insert into lt1200_comissoes values(
       '".$ies_tip_docto."','".$ies_tipo_lancto."',
       '".$mes_ref."','".$ano_ref."','".$cod_empresa."','".$cod_repres."', 
       '".$num_nff."','".$num_docum."', 
       '".$dat_emissao."','".$cod_cliente."',
       '".$val_tot_mercadoria."','".$val_tot_docum."', 
       '".$observacao."','".$cod_supervisor."','".$num_pedido."',
       '".$num_pedido_repres."','".$dat_emis_repres."','".$dat_pedido."') "; 
      $res_nfe = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_nfe = $cquery($insere_nfe,$res_nfe);
      if($val_frete/1 > 0)
      {
       $val_frete=($val_frete*-1);
       $insere_frete="insert into lt1200_comissoes values(
        'EF','".$ies_tipo_lancto."',
        '".$mes_ref."','".$ano_ref."','".$cod_empresa."','".$cod_repres."', 
        '".$num_nff."','".$num_docum."', 
        '".$dat_emissao."','".$cod_cliente."',
        '".$val_frete."','".$val_frete."', 
        'FRETE COBRADO','".$cod_supervisor."','".$num_pedido."',
        '".$num_pedido_repres."','".$dat_emis_repres."','".$dat_pedido."') "; 
       $res_frete = $cconnect("lt1200",$ifx_user,$ifx_senha);
       $result_frete = $cquery($insere_frete,$res_frete);
      }
     }
     $cons="select count(cod_repres) as count_rep from 
                   lt1200_comissoes
                where cod_repres='".$cod_supervisor."'
                   and num_nff='".$num_nff."'
                   and num_docum='".$num_docum."'
                   and val_tot_mercadoria='".$val_tot_mercadoria."'
                   and val_tot_docum='".$val_tot_docum."'
                   and dat_emissao='".$dat_emissao."'
                   and cod_cliente= '".$cod_cliente."' ";
      $res_cons = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_cons = $cquery($cons,$res_cons);
      $mat_cons=$cfetch_row($result_cons);
      $val_rep=round($mat_cons["count_rep"]);  
      $sel_supervisor="select b.tipo
                       from canal_venda a,
                            lt1200:lt1200_representante b

                       where a.cod_nivel_3='".$cod_supervisor."'
                       and a.cod_nivel_4=0 
                       and b.cod_repres=a.cod_nivel_3
                          ";
     $res_super = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_super = $cquery($sel_supervisor,$res_super);     
     $mat_super=$cfetch_row($result_super);
     $tipo_sup=chop($mat_super["tipo"]);                        
     if($tipo_sup<>$tipo)
     {
      $val_rep=1;
     }
     if(round($val_rep)==0)
     {                   
      $insere_nfe="insert into lt1200_comissoes values(
       '".$ies_tip_docto."','".$ies_tipo_lancto."',
       '".$mes_ref."','".$ano_ref."','".$cod_empresa."','".$cod_supervisor."', 
       '".$num_nff."','".$num_docum."', 
       '".$dat_emissao."','".$cod_cliente."',
       '".$val_tot_mercadoria."','".$val_tot_docum."', 
       '".$observacao."','".$cod_supervisor."','".$num_pedido."',
       '".$num_pedido_repres."','".$dat_emis_repres."','".$dat_pedido."') "; 
      $res_nfe = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_nfe = $cquery($insere_nfe,$res_nfe);
  
      if($val_frete/1 > 0)
      {
       $insere_frete="insert into lt1200_comissoes values(
        'EF','".$ies_tipo_lancto."',
        '".$mes_ref."','".$ano_ref."','".$cod_empresa."','".$cod_supervisor."', 
        '".$num_nff."','".$num_docum."', 
        '".$dat_emissao."','".$cod_cliente."',
        '".$val_frete."','".$val_frete."', 
        'FRETE COBRADO','".$cod_supervisor."','".$num_pedido."',
        '".$num_pedido_repres."','".$dat_emis_repres."','".$dat_pedido."') "; 
       $res_frete = $cconnect("lt1200",$ifx_user,$ifx_senha);
       $result_frete = $cquery($insere_frete,$res_frete);
      }
   } 
   $mat=$cfetch_row($result_comis);
  }
/*  $sel_apont="insert into lt1200_comissoes
               select a.ies_tip_docto,'G',a.mes_ref,
                      a.ano_ref,a.cod_empresa,a.cod_supervisor ,a.num_nff,a.num_docum,
                      a.dat_emissao,a.cod_cliente,
                      a.val_tot_mercadoria,a.val_tot_docum,a.observacao,
                      a.cod_supervisor,a.num_pedido,
                      a.num_pedido_repres,a.dat_emis_repres,a.dat_pedido
                 from lt1200_comissoes a,
                      logix:canal_venda b
                where a.mes_ref='".$mes_ref."' 
                      and a.ano_ref='".$ano_ref."'
                      and a.ies_tipo_lancto='A'
                      and b.cod_nivel_4=a.cod_repres
                      and a.cod_supervisor > 0
                       ";
  $res_apont = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_apont = $cquery($sel_apont,$res_apont);
*/
  $mensagem1="Concluido";
  $mensagem2="Dados de Comissoes para o mes $mes_ref de $ano_ref";
  include('../../bibliotecas/mensagem.inc');
  $ajusta_zona="select cod as cod_repres,cdfilial
                  from vnpfisic" ;
  $res_zona = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_zona = $cquery($ajusta_zona,$res_zona);     
   $mat_zona=$cfetch_row($result_zona);
   while (is_array($mat_zona))
   {
    $cod_aju=round($mat_zona["cod_repres"]);
    $zona_aju=chop($mat_zona["cdfilial"]);
    $ajuste="update lt1200_hist_comis set zona='".$zona_aju."'
               where cod_repres='".$cod_aju."' 
                     and ano_ref='".$ano_ref."'
                     and mes_ref='".$mes_ref."' " ;
    $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $cquery($ajuste,$res_ajuste);     
    $mat_zona=$cfetch_row($result_zona);
   }




  }else{
   $mensagem1="Atenção!!!";
   $mensagem2="Mes ja encerrado !!!";
   $mensagem3="Verifique suas Datas";
   include('../../bibliotecas/mensagem.inc');
  }
?>
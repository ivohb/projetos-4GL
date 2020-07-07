<?PHP
  //-----------------------------------------------------------------------------
  //Desenvolvedor: Henrique Antonio Conte
  //Manutenção:
  //Data manutenção:21/06/2005
  //Módulo:         SUP
  //Processo:       Custo Operacional do Vendedor
  //Versão:         1.0
  $prog="vdp/vdp0015";
  $versao=1;
  //-----------------------------------------------------------------------------
  $dia=date("d");
  $mes=date("m");
  $ano=date("Y");
  include("../../bibliotecas/inicio.inc");
  include("../../bibliotecas/usuario.inc");
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
  define('FPDF_FONTPATH','../fpdf151/font/');
  require('../fpdf151/fpdf_paisagem.php');
  require('../fpdf151/rotation.php');
  include('../../bibliotecas/cabec_fame.inc');
  $ano_ini=sprintf("%04d-%02d",$ano_ini,$mes_ini);
  $ano_fim=sprintf("%04d-%02d",$ano_fim,$mes_fim);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $cquery($transac,$res_trans);
  $acerta_valores=" select cod_empresa,num_matricula,ano_mes_ref 
                      from lt1200_hist_comis
                      where tipo in ('F','C')
                        and sal_liquido=0 
                        and ano_mes_ref  between '".$ano_ini."' and '".$ano_fim."'
                     order by cod_empresa,num_matricula ";

  $res_acerta = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_acerta = $cquery($acerta_valores,$res_acerta);
  $mat_acerta=$cfetch_row($result_acerta);
  while (is_array($mat_acerta))
  {
   $emp_acerta=$mat_acerta["cod_empresa"]; 
   $matricula_acerta=$mat_acerta["num_matricula"]; 
   $mes_ano_acerta=$mat_acerta["ano_mes_ref"]; 
   //acerta salario bruto
   $valor=0;
   $acerta_val="select sum(val_evento) as valor 
                  from hist_movto
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and dat_referencia='".$mes_ano_acerta."'
                     and cod_evento in (1,15,93,42)
                     and cod_tip_proc=1          ";
   $res_val = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_val = $cquery($acerta_val,$res_val);
   $mat_val=$cfetch_row($result_val);
   $valor=$mat_val["valor"];
  if($valor > 0)
  {  
   $up_val="update lt1200_hist_comis
                     set sal_bruto=$valor
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and ano_mes_ref='".$mes_ano_acerta."' ";

   $res_up_val = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $cquery($up_val,$res_up_val);
  }
   //acerta dsr
   $valor=0;
   $acerta_val="select sum(val_evento) as valor 
                  from hist_movto
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and dat_referencia='".$mes_ano_acerta."'
                     and cod_evento in (42)
                     and cod_tip_proc=1          ";
   $res_val = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_val = $cquery($acerta_val,$res_val);
   $mat_val=$cfetch_row($result_val);
   $valor=$mat_val["valor"];
  if($valor > 0)
  {  
   $up_val="update lt1200_hist_comis
                     set dsr=$valor
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and ano_mes_ref='".$mes_ano_acerta."' ";

   $res_up_val = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_up_val = $cquery($up_val,$res_up_val);
  }
   //acerta encargos
   $valor=0;
   $acerta_val="select sum(val_evento) as valor 
                  from hist_movto
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and dat_referencia='".$mes_ano_acerta."'
                     and cod_evento in (1230,1231,1233,951)
                     and cod_tip_proc=1          ";
   $res_val = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_val = $cquery($acerta_val,$res_val);
   $mat_val=$cfetch_row($result_val);
   $valor=$mat_val["valor"];
  if($valor > 0)
  {  
   $up_val="update lt1200_hist_comis
                     set encargos=$valor
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and ano_mes_ref='".$mes_ano_acerta."' ";

   $res_up_val = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_up_val = $cquery($up_val,$res_up_val);
  }
   //acerta liquido
   $valor=0;
   $acerta_val="select val_liquido  as valor 
                  from hist_funcio
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and dat_referencia='".$mes_ano_acerta."'
                     and cod_tip_proc=1          ";
   $res_val = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_val = $cquery($acerta_val,$res_val);
   $mat_val=$cfetch_row($result_val);
   $valor=$mat_val["valor"];
   $acerta_val="select val_evento  as valor 
                  from hist_movto
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and dat_referencia='".$mes_ano_acerta."'
                     and cod_evento in (103)
                     and cod_tip_proc=1          ";
   $res_val = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_val = $cquery($acerta_val,$res_val);
   $mat_val=$cfetch_row($result_val);
   $valor=$valor+$mat_val["valor"];
  if($valor > 0)
  {  
   $up_val="update lt1200_hist_comis
                     set sal_liquido=$valor
                   where cod_empresa='".$emp_acerta."'
                     and num_matricula='".$matricula_acerta."'
                     and ano_mes_ref='".$mes_ano_acerta."' ";

   $res_up_val = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_up_val = $cquery($up_val,$res_up_val);
  }



   $mat_acerta=$cfetch_row($result_acerta);
  }





  if($supervisor=="S")
  {
   $sel_sup="and a.zona[7,8]='00'";
  }else{
   $sel_sup="";
  }

  if($erep <> "S" )
  {
   if($srepres<>"todos")
   {
    $cod_rep=$srepres;
   }    
  }
 if($erep=="S")
  {
   $sel_rep="and x.cod_nivel_4='".$cod_rep."' 
                   and x.cod_nivel_4=b.cod_repres ";
   $sel_rep1="and x.cod_nivel_4='".$cod_rep."' 
                   and x.cod_nivel_4=b.cod_repres ";
   $tab_canal=",canal_venda x";
  }elseif($erep=="C") {
   $sel_rep="and x.cod_nivel_3='".$cod_rep."' and x.cod_nivel_4=0
                   and x.cod_nivel_3=b.cod_repres ";
   $sel_rep1=" and x.cod_nivel_3='".$cod_rep."'
                    and x.cod_nivel_4=b.cod_repres ";
   $tab_canal=",canal_venda x";
  }else{
   if($srepres=="todos")
   {
    $sel_rep="and  x.cod_nivel_4=0
                   and x.cod_nivel_3=b.cod_repres ";
    $sel_rep1=" and x.cod_nivel_4=b.cod_repres ";
    $tab_canal=",canal_venda x";
   }else{
    $sel_rep=" and b.cod_repres='".$cod_rep."'
               and  x.cod_nivel_4=0
                   and x.cod_nivel_3=b.cod_repres ";
    $sel_rep1=" and b.cod_repres='".$cod_rep."'
                and x.cod_nivel_4=b.cod_repres ";
    $tab_canal=",canal_venda x";

   }
 }
     $consulta="select 
              sum(a.val_merc_nff) as fat_total
             from 
                  lt1200:lt1200_hist_comis a,
                  representante b
                  $tab_canal
                 where a.ano_mes_ref  between '".$ano_ini."' and
                     '".$ano_fim."'
                 and a.tipo in ('F','C')

                 and a.zona[7,8] <>''
                 and b.cod_repres=a.cod_repres
                 $sel_rep
                 $sel_sup
                ";
     $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
     $result2 = $cquery($consulta,$res2);
     $mat_total=$cfetch_row($result2);
     $fat_total=$mat_total["fat_total"];


  $consulta="select a.zona[1,5],a.zona, a.mes_ref,a.ano_ref,a.cod_repres,a.mes_ref+a.ano_ref,
              a.tipo,a.cod_empresa,a.num_matricula,
              a.pct_nff,a.pct_dp,a.salario,
              a.fixo,a.cota,a.val_merc_nff,
              a.val_merc_dp,a.cod_supervisor,
              a.pct_alcancado,a.valor_comissao,a.outros,
              a.indenizacao,a.sal_bruto,a.sal_liquido,
              a.dsr,a.encargos,a.despesas,a.zona,
              a.zona[1,2]||a.zona[4,5] as nivel,
              b.raz_social,a.zona[7,8] as sup
             from 
                  lt1200:lt1200_hist_comis a,
                  representante b
                  $tab_canal
                 where a.ano_mes_ref  between '".$ano_ini."' and
                     '".$ano_fim."'
                 and a.tipo in ('F','C')
                 and b.cod_repres=a.cod_repres
                 $sel_rep
                 $sel_sup
  union 
    select
        a.zona[1,5],a.zona,a.mes_ref,a.ano_ref,a.cod_repres,a.mes_ref+a.ano_ref,
              a.tipo,a.cod_empresa,a.num_matricula,
              a.pct_nff,a.pct_dp,a.salario,
              a.fixo,a.cota,a.val_merc_nff,
              a.val_merc_dp,a.cod_supervisor,
              a.pct_alcancado,a.valor_comissao,a.outros,
              a.indenizacao,a.sal_bruto,a.sal_liquido,
              a.dsr,a.encargos,a.despesas,a.zona,
              a.zona[1,2]||a.zona[4,5] as nivel,
              b.raz_social,a.zona[7,8] as sup
             from 
                  lt1200:lt1200_hist_comis a,
                  representante b
                  $tab_canal
                 where a.ano_mes_ref  between '".$ano_ini."' and
                     '".$ano_fim."'
                 and a.tipo in  ('F','C')
                 and b.cod_repres=a.cod_repres
                 $sel_rep1
                 $sel_sup
               order by 1,2,17,5,4,3,6 ";
 $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($consulta,$res2);
  $mat_hist=$cfetch_row($result2);
  $cab=1;
  $titulo="Custo Operacional do Vendedor ";


  $pdf=new PDF();
  $pdf->Open();
  $pdf->AliasNbPages();
  $pdf->addpage(); 
  $nivel_atu=round($mat_hist["cod_supervisor"]);
  
  $rep_atu=$mat_hist["cod_repres"];
  while (is_array($mat_hist))
  {
   if($nivel_ant<>$nivel_atu)
   {
    $sel_nivel="select descr from vnorgao
                  where nivel='02'
                 and cdpfisic='".round($nivel_atu)."'" ;
    $res_nivel = $cconnect("logix",$ifx_user,$ifx_senha);
    $result_nivel = $cquery($sel_nivel,$res_nivel);
    $mat_nivel=$cfetch_row($result_nivel);
    $desc_nivel=$mat_nivel["descr"];
    $pdf->SetFont('Arial','B',12);
    $pdf->ln();
    $pdf->cell(180,6,chop($desc_nivel),'LRTB',0,'L');
    $pdf->SetFont('Arial','B',8);
   }
   if($rep_ant<>$rep_atu)
   {
    $pdf->ln();
    $pdf->SetFont('Arial','B',8);
    $pdf->cell(100,6,round($mat_hist["cod_repres"]).'-'.$mat_hist["raz_social"],'LRTB',0,'L');
    $pdf->cell(60,6,'Zona: '.chop($mat_hist["zona"]),'LRTB',0,'L');
   }
   if($resumo<>"S")
   {
    $pdf->SetFont('Arial','B',7);
    $pdf->ln();
    $mes_num=$mat_hist["mes_ref"];
    include("../../bibliotecas/nome_mes.inc");
    $pdf->cell(15,4,$abrev_mes.'/'.round($mat_hist["ano_ref"]),'LRTB',0,'L');
    $pdf->cell(20,4,number_format($mat_hist["cota"],2,",","."),'LTRB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["val_merc_nff"],2,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["sal_bruto"],2,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["sal_liquido"],2,",","."),'LRTB',0,'R');
    $pdf->cell(10,4,number_format((($mat_hist["cota"]==0)?0:($mat_hist["val_merc_nff"]*100)/$mat_hist["cota"]),0,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["salario"],2,",","."),'LRTB',0,'R');
    $total_mes=$mat_hist["salario"]+$mat_hist["valor_comissao"]+$mat_hist["dsr"]+$mat_hist["encargos"]+$mat_hist["despesas"];
    $pfixo=($mat_hist["salario"]*100)/$total_mes;
    $pcomis=($mat_hist["valor_comissao"]*100)/$total_mes;
    $pdsr=($mat_hist["dsr"]*100)/$total_mes;
    $pencarg=($mat_hist["encargos"]*100)/$total_mes;
    $pdesp =($mat_hist["despesas"]*100)/$total_mes;
    $pcusto =($total_mes*100)/$mat_hist["val_merc_nff"];
    $pdf->cell(10,4,number_format($pfixo,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["valor_comissao"],2,",","."),'LRTB',0,'R');
    $pdf->cell(10,4,number_format($pcomis,0,",","."),'LRTB',0,'R');
    $pdf->cell(15,4,number_format($mat_hist["dsr"],2,",","."),'LRTB',0,'R');
    $pdf->cell(10,4,number_format($pdsr,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($mat_hist["encargos"],2,",","."),'LRTB',0,'R');
    $pdf->cell(10,4,number_format($pencarg,0,",","."),'LRTB',0,'R');
    $pdf->cell(15,4,number_format($mat_hist["despesas"],2,",","."),'LRTB',0,'R');
    $pdf->cell(10,4,number_format($pdesp,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,4,number_format($total_mes,2,",","."),'LRTB',0,'R');
    $pdf->cell(15,4,number_format($pcusto,0,",","."),'LRTB',0,'R');
   }  
   $cota=$cota+$mat_hist["cota"];
   $val_merc=$val_merc+$mat_hist["val_merc_nff"];
   $val_bruto=$val_bruto+$mat_hist["sal_bruto"];
   $val_liquido=$val_liquido+$mat_hist["sal_liquido"];
   $salario=$salario+$mat_hist["salario"];
   $val_comissao=$val_comissao+$mat_hist["valor_comissao"];
   $dsr=$dsr+$mat_hist["dsr"];
   $encargos=$encargos+$mat_hist["encargos"];
   $despesas=$despesas+$mat_hist["despesas"];
   $m_total=$m_total+$mat_hist["salario"]+$mat_hist["valor_comissao"]+$mat_hist["dsr"]+$mat_hist["encargos"]+$mat_hist["despesas"];

   $zcota=$zcota+$mat_hist["cota"];
   $zval_merc=$zval_merc+$mat_hist["val_merc_nff"];
   $zval_bruto=$zval_bruto+$mat_hist["sal_bruto"];
   $zval_liquido=$zval_liquido+$mat_hist["sal_liquido"];
   $zsalario=$zsalario+$mat_hist["salario"];
   $zval_comissao=$zval_comissao+$mat_hist["valor_comissao"];
   $zdsr=$dsr+$zmat_hist["dsr"];
   $zencargos=$zencargos+$mat_hist["encargos"];
   $zdespesas=$zdespesas+$mat_hist["despesas"];
   $z_total=$z_total+$mat_hist["salario"]+$mat_hist["valor_comissao"]+$mat_hist["dsr"]+$mat_hist["encargos"]+$mat_hist["despesas"];

   $tcota=$tcota+$mat_hist["cota"];
   $tval_merc=$tval_merc+$mat_hist["val_merc_nff"];
   $tval_bruto=$tval_bruto+$mat_hist["sal_bruto"];
   $tval_liquido=$tval_liquido+$mat_hist["sal_liquido"];
   $tsalario=$tsalario+$mat_hist["salario"];
   $tval_comissao=$tval_comissao+$mat_hist["valor_comissao"];
   $tdsr=$tdsr+$mat_hist["dsr"];
   $tencargos=$tencargos+$mat_hist["encargos"];
   $tdespesas=$tdespesas+$mat_hist["despesas"];
   $t_total=$t_total+$mat_hist["salario"]+$mat_hist["valor_comissao"]+$mat_hist["dsr"]+$mat_hist["encargos"]+$mat_hist["despesas"];

   $nivel_ant=chop($mat_hist["cod_supervisor"]);
   $rep_ant=$mat_hist["cod_repres"];
   $raz_ant=$mat_hist["raz_social"];
   $super=chop($mat_hist["sup"]);

   $mat_hist=$cfetch_row($result2);
   $nivel_atu=chop($mat_hist["cod_supervisor"]);
   $rep_atu=$mat_hist["cod_repres"];
   if($rep_ant<>$rep_atu)
   {
    $m_pfixo=($salario*100)/$m_total;
    $m_pcomis=($val_comissao*100)/$m_total;
    $m_pdsr=($dsr*100)/$m_total;
    $m_pencarg=($encargos*100)/$m_total;
    $m_pdesp =($despesas*100)/$m_total;
    $m_pcusto =($m_total*100)/$val_merc;
    if($supervisor<>"S")
    {
     $pdf->ln();
     $pdf->SetFont('Arial','B',7);
     $pdf->cell(15,6,'Total.:','LRTB',0,'L');
     $pdf->cell(20,6,number_format($cota,2,",","."),'LTRB',0,'R');
     $pdf->cell(20,6,number_format($val_merc,2,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($val_bruto,2,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($val_liquido,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format( (($cota==0)?0:($val_merc*100)/$cota),0,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($salario,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format($m_pfixo,0,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($val_comissao,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format($m_pcomis,0,",","."),'LRTB',0,'R');
     $pdf->cell(15,6,number_format($dsr,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format($m_pdsr,0,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($encargos,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format($m_pencarg,0,",","."),'LRTB',0,'R');
     $pdf->cell(15,6,number_format($despesas,2,",","."),'LRTB',0,'R');
     $pdf->cell(10,6,number_format($m_pdesp,0,",","."),'LRTB',0,'R');
     $pdf->cell(20,6,number_format($m_total,2,",","."),'LRTB',0,'R');
     $pdf->cell(15,6,number_format($m_pcusto,0,",","."),'LRTB',0,'R');
    }
    if($super=="00")
    {
     $val_super=$val_merc;
    }
   
 
    if($resumo<>"S")
    {
     $pdf->ln();
    }
    $cota=0;
    $val_merc=0;
    $val_bruto=0;
    $val_liquido=0;
    $salario=0;
    $val_comissao=0;
    $dsr=0;
    $encargos=0;
    $despesas=0;
    $m_total=0;
   }

   if($nivel_ant<>$nivel_atu)
   {
    $pct_tot=round( (($fat_total==0)?0:($val_super*100/$fat_total)),1);
    if($resumo<>"S")
    {
     $pdf->ln();
    }
    $z_pfixo=($zsalario*100)/$z_total;
    $z_pcomis=($zval_comissao*100)/$z_total;
    $z_pdsr=($zdsr*100)/$z_total;
    $z_pencarg=($zencargos*100)/$z_total;
    $z_pdesp =($zdespesas*100)/$z_total;
    $z_pcusto =($z_total*100)/$zval_merc;
    $pdf->SetFont('Arial','B',7);
    $pdf->ln();
    $pdf->cell(15,6,'Zona: '.$pct_tot.'%','LRTB',0,'L');
    $pdf->cell(20,6,number_format($zcota,2,",","."),'LTRB',0,'R');
    $pdf->cell(20,6,number_format($zval_merc,2,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($zval_bruto,2,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($zval_liquido,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format((($zcota==0)?0:($zval_merc*100)/$zcota),0,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($zsalario,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format($z_pfixo,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($zval_comissao,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format($z_pcomis,0,",","."),'LRTB',0,'R');
    $pdf->cell(15,6,number_format($zdsr,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format($z_pdsr,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($zencargos,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format($z_pencarg,0,",","."),'LRTB',0,'R');
    $pdf->cell(15,6,number_format($zdespesas,2,",","."),'LRTB',0,'R');
    $pdf->cell(10,6,number_format($z_pdesp,0,",","."),'LRTB',0,'R');
    $pdf->cell(20,6,number_format($z_total,2,",","."),'LRTB',0,'R');
    $pdf->cell(15,6,number_format($z_pcusto,0,",","."),'LRTB',0,'R');
    
    $zcota=0;
    $zval_merc=0;
    $zval_bruto=0;
    $zval_liquido=0;
    $zsalario=0;
    $zval_comissao=0;
    $zdsr=0;
    $zencargos=0;
    $zdespesas=0;
    $z_total=0;




    /*(Marcelo Peres-02/02/2007) Retirada essa verificao para que no haja pginas semi-completas no meio do relatrio.    /*(Marcelo Peres-02/02/2007) Retirada essa verificao para que no haja pginas semi-completas no meio do relatrio.

    if($resumo<>"S")
    { 
     if($nivel_ant<>$nivel_atu)
     {
      $pdf->addpage();
     }
    }
*/
   }
  }
  $pdf->ln();
  $pdf->SetFont('Arial','B',7);
  $pdf->ln();
  $t_pfixo=($tsalario*100)/$t_total;
  $t_pcomis=($tval_comissao*100)/$t_total;
  $t_pdsr=($tdsr*100)/$t_total;
  $t_pencarg=($tencargos*100)/$t_total;
  $t_pdesp =($tdespesas*100)/$t_total;
  $t_pcusto =($t_total*100)/$tval_merc;
  $pdf->cell(15,6,'Tot.Geral:','LRTB',0,'L');
  $pdf->cell(20,6,number_format($tcota,2,",","."),'LTRB',0,'R');
  $pdf->cell(20,6,number_format($tval_merc,2,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($tval_bruto,2,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($tval_liquido,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format(($tval_merc*100)/$tcota,0,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($tsalario,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format($t_pfixo,0,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($tval_comissao,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format($t_pcomis,0,",","."),'LRTB',0,'R');
  $pdf->cell(15,6,number_format($tdsr,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format($t_pdsr,0,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($tencargos,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format($t_pencarg,0,",","."),'LRTB',0,'R');
  $pdf->cell(15,6,number_format($tdespesas,2,",","."),'LRTB',0,'R');
  $pdf->cell(10,6,number_format($t_pdesp,0,",","."),'LRTB',0,'R');
  $pdf->cell(20,6,number_format($t_total,2,",","."),'LRTB',0,'R');
  $pdf->cell(15,6,number_format($t_pcusto,0,",","."),'LRTB',0,'R');
  $tcota=0;
  $tval_merc=0;
  $tval_bruto=0;
  $tval_liquido=0;
  $tsalario=0;
  $tval_comissao=0;
  $tdsr=0;
  $tencargos=0;
  $tdespesas=0;
  $t_total=0;
  $pdf->Output('custo_operacional.pdf',true);

?>

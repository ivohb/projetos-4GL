<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten��o:     Henrique
 //Data manuten��o:24/06/2005
 //M�dulo:         VDP
 //Processo:       Vendas - Emiss�o de Relt�rio de Comiss�es
 //-----------------------------------------------------------------------------
 $prog="vdp/vdp0005";
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
 $dados=chop($dados);
 if($dados=="T")
 {
  $t_dados="";
 }elseif($dados=="E"){
  $t_dados="and b.val_tot_mercadoria < 0";
 }else{
  $t_dados="and b.ies_tipo_lancto='".$dados."'";
 }

 if($tipo=="S")
 {
  $sel_repres='and d.cod_repres=b.cod_repres';
  $sel_tipo="";
  $t_canal_vendas='and g.cod_nivel_3=d.cod_repres and g.cod_nivel_4=0';
 }else{
  $sel_repres='and d.cod_repres=b.cod_repres';
  $sel_tipo="and f.tipo='".$tipo."' "; 
  $t_canal_vendas='and g.cod_nivel_4=d.cod_repres ';
 }
 if($tipo=="F" or $tipo=="C" or $tipo=="S")
 {
  $sel_sal=',h.salario';
  $tab_sal=',fun_salario h';
  $selec_sal='and h.cod_empresa=f.cod_empresa and
              h.num_matricula=f.num_matricula';
 }else{
  $sel_sal='';
  $tab_sal='';
  $selec_sal='';
}
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

 if($dados=="T" )
 {
  $consulta="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  f.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,f.nivel
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
             where
               b.cod_empresa='".$empresa."'
               and b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and c.cod_cliente=b.cod_cliente
               $sel_repres
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and f.cod_repres=d.cod_repres
               $sel_tipo
               and b.ies_tip_docto in ('DP','NF')               
               $t_dados
               $t_canal_vendas
               $selec_sal
            order by d.cod_repres,b.ies_tipo_lancto desc ,
                     b.ies_tip_docto desc,b.num_nff,b.num_docum ";
 }elseif($dados=="E")
 {
  $consulta="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  f.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,f.nivel
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
             where
               b.cod_empresa='".$empresa."'
               and b.dat_emissao between '".$dini."' and '".$dfin."'
               and c.cod_cliente=b.cod_cliente
               $sel_repres
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and f.cod_repres=d.cod_repres
               $sel_tipo
               and b.ies_tip_docto in ('NF')
               and b.ies_tipo_lancto='G'
               $t_dados
               $t_canal_vendas
               $selec_sal
            order by d.cod_repres,b.ies_tipo_lancto desc ,
                     b.ies_tip_docto desc,b.num_nff,b.num_docum ";
   }else{ 
    $consulta="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  f.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,f.nivel
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
             where
               b.cod_empresa='".$empresa."'
               and b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and c.cod_cliente=b.cod_cliente
               $sel_repres
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and f.cod_repres=d.cod_repres
               $sel_tipo
               and b.ies_tip_docto in ('GR','DP','NF','BC','AC','EI','EF','EG')               
               $t_dados
               $t_canal_vendas
               $selec_sal
            order by d.cod_repres,b.ies_tipo_lancto desc ,
                     b.ies_tip_docto desc,b.num_nff,b.num_docum             " ;
      }  
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result2 = $cquery($consulta,$res);


 $mat=$cfetch_row($result2);

 $cab=1;
 $nf_ant="0"; 
 $nf_atu=$mat["num_nff"]; 

 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf_paisagem.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $val_nf=0;
 $val_dp=0;
 $rep_atu=$mat["cod_repres"];
 $rep_ant="";
 $raz_atu=$mat["raz_social"];
 if($tipo=='F')
 {
  if(chop($mat["sit_func"])=="F")
  {
   $situacao="CONFIRMADO";
  }else{
   $situacao="CONFERENCIA";
  } 
 }  
 if($tipo=='R')
 {
  if(chop($mat["sit_rep"])=="F")
  {
   $situacao="CONFIRMADO";
  }else{
   $situacao="CONFERENCIA";
  } 
 }  
 if($tipo=='A')
 {
  if(chop($mat["sit_aut"])=="F")
  {
   $situacao="CONFIRMADO";
  }else{
   $situacao="CONFERENCIA";
  } 
 }  
 if($tipo=='C')
 {
  if(chop($mat["sit_aut"])=="F")
  {
   $situacao="CONFIRMADO";
  }else{
   $situacao="CONFERENCIA";
  } 
 }  


 while (is_array($mat))
 {
   $num_ped_logix=round($mat["num_pedido"]);
   $num_ped_rep=round($mat["num_pedido_repres"]);
   $dat_emis=$mat["dat_pedido"];
   $dat_emis_rep=$mat["dat_emis_repres"];
  $salario=$mat["salario"];
  if($rep_ant<>$rep_atu)
  {
   $raz_atu=$mat["raz_social"];
   $matricula=$mat["num_matricula"];
   $titulo=$situacao."->  Comiss�es  ".$mes_ref." / ".$ano_ref." Rep.:".round($rep_atu)."-".$raz_atu;
   $pdf->AddPage();
  } 
  $pdf->ln();
  $pdf->SetFont('Arial','B',8);
  $pdf->setx(10);
  $tipo_docto=chop($mat["ies_tip_docto"]);
  $num_nff=round($mat["num_nff"]);
  $emp_nff=chop($mat["emp_nff"]);
/*  if($tipo_docto=="NF" or $tipo_docto=="DP")
  {
   $cons_ped="SELECT
                  b.num_pedido,b.num_pedido_repres,
                  b.dat_emis_repres,b.dat_pedido
             from nf_item a,
                  pedidos b
             where  a.cod_empresa='".$emp_nff."'
               and  a.num_nff='".$num_nff."'
               and b.cod_empresa=a.cod_empresa
               and b.num_pedido=a.num_pedido
              " ;
   $res_ped = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_ped = $cquery($cons_ped,$res_ped);
   $mat_ped=$cfetch_row($result_ped);
   $num_ped_logix=round($mat_ped["num_pedido"]);
   $num_ped_rep=round($mat_ped["num_pedido_repres"]);
   $dat_emis=$mat_ped["dat_pedido"];
   $dat_emis_rep=$mat_ped["dat_emis_repres"];
  }
 */
  $pdf->cell(10,5,$tipo_docto,'LRTB',0,'L');
  $pdf->cell(20,5,round($mat["num_nff"]),'LRTB',0,'L');
  $pdf->cell(20,5,$num_ped_logix,'LRTB',0,'L');
  $pdf->cell(20,5,$num_ped_rep,'LRTB',0,'L');
  $pdf->cell(20,5,$dat_emis,'LRTB',0,'L');
  $pdf->cell(20,5,$dat_emis_rep,'LRTB',0,'L');
  $pdf->cell(25,5,$mat["num_docum"],'LRTB',0,'L');
  $pdf->cell(70,5,$mat["nom_cliente"],'LRTB',0,'L');
  $pdf->cell(20,5,$mat["dat_emissao"],'LRTB',0,'R');
  if(chop($mat["ies_tip_docto"])=='NF')
  {
   $pdf->cell(25,5,number_format($mat["val_tot_mercadoria"],2,",","."),'LRTB',0,'R');
   $val_nf=$val_nf+$mat["val_tot_mercadoria"];
   $val_nf_t=$val_nf_t+$mat["val_tot_mercadoria"];
   $pdf->cell(25,5,' ','LRTB',0,'R');
  }else{
   $pdf->cell(25,5,' ','LRTB',0,'R');
   $pdf->cell(25,5,number_format($mat["val_tot_mercadoria"],2,",","."),'LRTB',0,'R');
   $val_dp=$val_dp+$mat["val_tot_mercadoria"];
   $val_dp_t=$val_dp_t+$mat["val_tot_mercadoria"];
  }
  if(chop($mat["observacao"])<>"")
  {
   $pdf->ln();
   $pdf->SetFont('Arial','B',8);
   $pdf->setx(10);
   $pdf->cell(10,5,'','TB',0,'L');
   $pdf->cell(20,5,'','TB',0,'L');
   $pdf->cell(20,5,'','TB',0,'L');
   $pdf->cell(20,5,'','TB',0,'L');
   $pdf->cell(20,5,'','TB',0,'L');
   $pdf->cell(20,5,'','TB',0,'L');
   $pdf->cell(25,5,'','TB',0,'L');
   $pdf->cell(140,5,$mat["observacao"],'LRTB',0,'L');
  }
  $rep_ant=$mat["cod_repres"];
  $raz_ant=$mat["raz_social"];
  $cota=$mat["cota"];
  $pct_nff=$mat["pct_nff"];
  $pct_dp=$mat["pct_dp"];
  $teto=$mat["teto"];

  $matricula=chop($mat["num_matricula"]);
  $empresa=chop($mat["cod_empresa"]);
  $tipo_ant=$mat["ies_tipo_lancto"];
  $ind=$mat["ind"];
  if(chop($mat["nivel"])=="G")
  {
   $gestor="S";
  }else{
   $gestor="N";
  }


  $mat=$cfetch_row($result2);

  $tipo_atu=$mat["ies_tipo_lancto"];

  $raz_atu=$mat["raz_social"];
  $rep_atu=$mat["cod_repres"];
  if($rep_ant<>$rep_atu)
  {
   $tipo_atu="";
  }
  if($tipo_atu<>$tipo_ant)
  {
   if($tipo_ant=="G")
   {
    $desc_tipo="Total Lan�amentos de notas e Titulos a Creditar";
   }elseif($tipo_ant=="A"){
    $desc_tipo="Total de Outros Lan�amentos";
   }   
   $pdf->ln();
   $pdf->cell(225,5,$desc_tipo,'LRTB',0,'C');
   $pdf->cell(25,5,number_format($val_nf_t,2,",","."),'LRTB',0,'R');
   $pdf->cell(25,5,number_format($val_dp_t,2,",","."),'LRTB',0,'R');
   $val_nf_t=0;
   $val_dp_t=0;
   $pdf->ln();
  }

  if($rep_ant<>$rep_atu)
  {
   $pdf->ln();
   $pdf->cell(225,5,"Totais do Representante",'LRTB',0,'C');
   $pdf->cell(25,5,number_format($val_nf,2,",","."),'LRTB',0,'R');
   $pdf->cell(25,5,number_format($val_dp,2,",","."),'LRTB',0,'R');

   if($tipo=="F" or  $tipo=="S")
   {
    $pdf->ln();
    $pdf->cell(35,5,"Valor da Cota:",'LRTB',0,'C');
    $pdf->cell(25,5,number_format($cota,2,",","."),'LRTB',0,'R');
    $pdf->cell(35,5,"Percentual alcan�ado:",'LRTB',0,'C');
    if($cota==0)
    {
     $pct_alcancado=0;
    }else{
     $pct_alcancado=round((($val_nf*100)/$cota));
    }
    $pdf->cell(25,5,number_format($pct_alcancado,0,",","."),'LRTB',0,'R');

    

    if($gestor=="S")
    {
      $pct_alc=round($pct_alcancado);     
      $cons_faixa="SELECT *
                 from lt1200_faixas_comis a
                where '".$pct_alc."' between  a.pct_ini and a.pct_fin
                 " ;

     $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_faixa = $cquery($cons_faixa,$res_faixa);
     $mat_faixa=$cfetch_row($result_faixa);
     $pct_sal=$mat_faixa["pct_sal"];

     $pdf->cell(35,5,"Cobertura Gestor:",'LRTB',0,'C');
     $pdf->cell(25,5,number_format($pct_sal,2,",","."),'LRTB',0,'R');
     $pct_alcancado=$pct_sal;
    }else{
     if($pct_alcancado < $pct_nff)
     {
      $pct_alcancado=0;
     }
    }
    $pdf->ln();
    $pdf->cell(35,5,"Valor do Salario Normal:",'LRTB',0,'C');
    $pdf->cell(25,5,number_format($salario,2,",","."),'LRTB',0,'R');
    $pdf->cell(35,5,"Comiss�o:",'LRTB',0,'C');
    $sal_alcancado=($salario*$pct_alcancado/100);
    $pdf->cell(25,5,number_format($sal_alcancado,2,",","."),'LRTB',0,'R');
    if($ind=="S")
    {
     $pdf->cell(35,5,"Indeniza��o:",'LRTB',0,'C');
     $val_ind=($sal_alcancado/12);
     $pdf->cell(25,5,number_format($val_ind,2,",","."),'LRTB',0,'R');
     $pdf->ln();
     $pdf->cell(35,5,"Comiss�o+Indeniza��o:",'LRTB',0,'C');
     $pdf->cell(25,5,number_format($val_ind+$sal_alcancado,2,",","."),'LRTB',0,'R');
    }
   }

   if($tipo=="R" or $tipo=="A" or $tipo=="C")
   {
    $pdf->SetFont('Arial','B',8);
    $pdf->ln();
    $pdf->cell(225,5,"Percentuais de Comiss�o:",'0',0,'R');
    $pdf->cell(25,5,number_format($pct_nff,0,",","."),'LRTB',0,'C');
    $pdf->cell(25,5,number_format($pct_dp,0,",","."),'LRTB',0,'C');
    $pdf->ln();

    $pdf->cell(225,5,"Valores da Comiss�o:",'0',0,'R');
    $val_com_nff=($val_nf*$pct_nff/100);
    $pdf->cell(25,5,number_format($val_com_nff,2,",","."),'LRTB',0,'R');
    $val_com_dp=($val_dp*$pct_dp/100);
    $pdf->cell(25,5,number_format($val_com_dp,2,",","."),'LRTB',0,'R');

    $pdf->ln();
    $pdf->cell(225,5,"Valores Total da Comiss�o:",'0',0,'R');
    $val_tot_com=$val_com_nff+$val_com_dp;
    $pdf->cell(50,5,number_format($val_tot_com,2,",","."),'LRTB',0,'R');
    $sal_alcancado=$val_tot_com;
    $pdf->ln();
    if($ind=="S")
    {
     $pdf->cell(225,5,"Indeniza��o:",'0',0,'R');
     $val_ind=($sal_alcancado/12);
     $pdf->cell(50,5,number_format($val_ind,2,",","."),'LRTB',0,'R');
     $pdf->ln();
     $pdf->cell(225,5,"Comiss�o+Indeniza��o:",'0',0,'R');
     $pdf->cell(50,5,number_format($val_ind+$sal_alcancado,2,",","."),'LRTB',0,'R');
    }
   }
   $val_nf=0;
   $val_dp=0;
   $pdf->ln();
   $cons_extra="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,b.cod_repres,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao
             from lt1200:lt1200_comissoes b     

             where
                b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and b.cod_repres='".$rep_ant."'
               and b.ies_tip_docto in ('GR','BC','AC','CP','EI','EF','EG')               
            order by b.val_tot_mercadoria             " ;
   $res_extra = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_extra = $cquery($cons_extra,$res_extra);
   $mat_extra=$cfetch_row($result_extra);
   $pdf->ln();
   $pdf->SetFont('Arial','B',10);
   $pdf->cell(150,5,"OUTROS VALORES",'LRTB',0,'C');
   $pdf->ln();
   $val_extra=0;
   while (is_array($mat_extra))
   {
    $pdf->SetFont('Arial','B',8);
    $pdf->cell(100,5,$mat_extra["observacao"],'LRTB',0,'C');
    $pdf->cell(50,5,number_format($mat_extra["val_tot_mercadoria"],2,",","."),'LRTB',0,'R');
    $val_extra=$val_extra+$mat_extra["val_tot_mercadoria"];
    $pdf->ln();
    $mat_extra=$cfetch_row($result_extra);
   }
   $pdf->cell(100,5,"Total de Extras",'LRTB',0,'C');
   $pdf->cell(50,5,number_format($val_extra,2,",","."),'LRTB',0,'R');
   $val_extra=0;
  }
 }
 $pdf->ln();
 $val_nf=0;
 $val_dp=0;
 $pdf->ln();
 $pdf->Output('comis.pdf',true);


?>




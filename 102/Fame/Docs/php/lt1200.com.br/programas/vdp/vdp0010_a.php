<?  
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten��o:     Henrique
 //Data manuten��o:24/06/2005
 //M�dulo:         VDP
 //Processo:       Vendas - Emiss�o de Relt�rio de Comiss�es
 //-----------------------------------------------------------------------------
 $prog="vdp/vdp0010";
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
 if($dados=="T")
 {
  $t_dados="";
 }else{
  $t_dados="and b.ies_tipo_lancto='".$dados."'";
 }

 if($tipo=="S")
 {/*
  $sel_repres='and d.cod_repres=b.cod_supervisor';
  $sel_tipo="";
  $t_canal_vendas='and g.cod_nivel_3=d.cod_repres and g.cod_nivel_4=0';
  */
  
  $sel_repres='and ((d.cod_repres=b.cod_supervisor) or (d.cod_repres=g.cod_nivel_2))';
  $sel_tipo="";
  $t_canal_vendas='and g.cod_nivel_3=b.cod_supervisor and g.cod_nivel_4=0';
  /*
  $sel_repres='and d.cod_repres = g.cod_nivel_2 --in (select cod_nivel_2 from canal_venda where cod_nivel_3=b.cod_supervisor and cod_nivel_4=0)';
  $sel_tipo="";
  $t_canal_vendas='and g.cod_nivel_3=b.cod_supervisor and g.cod_nivel_4=b.cod_repres';
  */
 }else{
  $sel_repres='and d.cod_repres=b.cod_repres';
  $sel_tipo="and f.tipo='".$tipo."' "; 
  $t_canal_vendas='and g.cod_nivel_4=d.cod_repres ';
 }
 if($tipo=="F" or $tipo=="C" or $tipo=="S" or $tipo=="K")
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
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

 $consulta="SELECT DISTINCT
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
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,e.sit_tel,
                  f.cota,f.pct_nff,f.pct_dp,f.ind,f.tipo,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3,g.cod_nivel_2
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
                     b.ies_tip_docto desc,b.num_nff,b.num_docum
                 " ;

 
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result2 = $cquery($consulta,$res);


 $mat=$cfetch_row($result2);

 $cab=1;
 $nf_ant="0"; 
 $nf_atu=$mat["num_nff"]; 

 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf_paisagem.php');
 require('../fpdf151/rotation.php');
 $titulo=$situacao."-> Resumo Comiss�es  ".$mes_ref." / ".$ano_ref;
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
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
 if($tipo=='K')
 {
  if(chop($mat["sit_tel"])=="F")
  {
   $situacao="CONFIRMADO";
  }else{
   $situacao="CONFERENCIA";
  } 
 }

$t_val_nf=0;
$t_val_dp=0;
$t_val_comis=0;
$t_val_bonus=0;

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
  } 
  $tipo_docto=chop($mat["ies_tip_docto"]);
  $num_nff=round($mat["num_nff"]);
  $emp_nff=chop($mat["emp_nff"]);
  if(chop($mat["ies_tip_docto"])=='NF')
  {
   $val_nf=$val_nf+$mat["val_tot_mercadoria"];
   $val_nf_t=$val_nf_t+$mat["val_tot_mercadoria"];
  }else{
   $val_dp=$val_dp+$mat["val_tot_mercadoria"];
   $val_dp_t=$val_dp_t+$mat["val_tot_mercadoria"];
  }
  $rep_ant=$mat["cod_repres"];
  $raz_ant=$mat["raz_social"];
  $cod_nivel_2_ant=$mat["cod_nivel_2"];
  $cota=$mat["cota"];
  $pct_nff=$mat["pct_nff"];
  $pct_dp=$mat["pct_dp"];
  $teto=$mat["teto"];

  $matricula=chop($mat["num_matricula"]);
  $empresa=chop($mat["cod_empresa"]);
  $tipo_ant=$mat["ies_tipo_lancto"];
  $ind=$mat["ind"];
  
  //Marco gestor e supervisor, pois logo abaixo d� um next no resultset.
  if(trim($mat["nivel"])=="G")
  {
   $gestor="S";
  }else{
   $gestor="N";
  }
  
  if(trim($mat["nivel"])=="S")
  	$supervisor="S";
  else
  	$supervisor="N"; 

  //Verifico se � do tipo telemarketing
  if(trim($mat["tipo"])=="K")
  	{
  	$tlmk="S";
  	}
  else
  	{
  	$tlmk="N";
  	}


  $mat=$cfetch_row($result2);

  $tipo_atu=$mat["ies_tipo_lancto"];

  $raz_atu=$mat["raz_social"];
  $rep_atu=$mat["cod_repres"];
  if($rep_ant<>$rep_atu)
  {
   $tipo_atu="";
  }
  if($rep_ant<>$rep_atu)
  {
   $pdf->ln();
   $pdf->cell(100,5,round($rep_ant).'-'.$raz_ant,'LRTB',0,'L');
   $pdf->cell(25,5,round($matricula).'/'.$empresa,'LRTB',0,'L');
   $pdf->cell(35,5,number_format($val_nf,2,",","."),'LRTB',0,'R');
   $pdf->cell(35,5,number_format($val_dp,2,",","."),'LRTB',0,'R');
   $t_val_nf=$t_val_nf+$val_nf;
   $t_val_dp=$t_val_dp+$val_dp;

   if($tipo=="F" or  $tipo=="S")
   {
    if($cota==0)
    {
     $pct_alcancado=0;
    }else{
     $pct_alcancado=round((($val_nf*100)/$cota));
     $pct_imprime=$pct_alcancado;
  	}
    
    $pct_alc=round($pct_alcancado);
    
    if($gestor=="S")
    {     
      $cons_faixa="SELECT *
                 from lt1200_faixas_comis a
                where '".$pct_alc."' between  a.pct_ini and a.pct_fin
                 " ;

     $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_faixa = $cquery($cons_faixa,$res_faixa);
     $mat_faixa=$cfetch_row($result_faixa);
     $pct_sal=$mat_faixa["pct_sal"];

     $pct_alcancado=$pct_sal;
     $pct_imprime=$pct_alc;
    }elseif($tlmk=="S"){
    // Caso seja supervisor do TLMK	
      if($pct_alc >= 70 && $pct_alc < 100)
      	{
      	if($cod_nivel_2_ant == $rep_ant)
      		{
      		$pct_alcancado=50;	
      		}
      	else
      		{
      		$pct_alcancado=50; // extin��o da fun��o de supervisor	
      		}	
      	}
      elseif($pct_alc >= 100)
      	{
      	if($cod_nivel_2_ant == $rep_ant)
      		{
      		$pct_alcancado=100;	
      		}
      	else
      		{
      		$pct_alcancado=100; // extin��o da fun��o de supervisor	
      		}	
      	}
      else
      	{
      	$pct_alcancado=0;
      	}
      $pct_imprime=$pct_alc;
    }elseif($pct_alcancado < 101){
    	
     $cons_faixa="SELECT *
                 from lt1200_faixas_comis_geral a
                where '".$pct_alc."' between  a.pct_ini and a.pct_fin
                 " ;

     $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_faixa = $cquery($cons_faixa,$res_faixa);
     $mat_faixa=$cfetch_row($result_faixa);
     $pct_sal=$mat_faixa["pct_sal"];

     $pct_alcancado=$pct_sal;
     $pct_imprime=$pct_alc;
    	
     if($pct_alc < $pct_nff)
     {
      $pct_imprime=$pct_alc;
      $pct_alcancado=0;
     }
    }
       
    $sal_alcancado=($salario*$pct_alcancado/100);
    
    if($ind=="S")
    {
     $val_ind=($sal_alcancado/12);
     $pdf->cell(30,5,number_format($val_ind+$sal_alcancado,2,",","."),'LRTB',0,'R');
    }else{
     $pdf->cell(30,5,number_format($sal_alcancado,2,",","."),'LRTB',0,'R');
    }
   $bonus=0;
   if($gestor!="S" && trim($tlmk) != "S" && $rep_ant != "127" && $rep_ant != "198") // PROVIS�RIO (criar um campo no cadastro de repres para indicar se tem bonus ou n�o)
   	{
	   if($pct_imprime >= 100 && trim($supervisor) == "S")
		   {
		   	//(22/07/2009) - Marcelo Peres - Inclus�o da tabela gradual de b�nus
		   	/*
		   	 if($pct_alc >= 65 && $pct_alc < 75)
		   	 	$bonus=600;
		   	 elseif($pct_alc >= 75 && $pct_alc < 85)
		   	 	$bonus=800;
		   	 elseif($pct_alc >= 85 && $pct_alc < 100)
		   	 	$bonus=1000;
		   	 elseif($pct_alc >= 100 && $pct_alc < 120)
		   	 	$bonus=1200;
		   	 elseif($pct_alc >= 120)
		   	 	$bonus=1500;
		   	 */
		     $bonus=($salario * 0.1);
		   }
	   elseif($pct_imprime >= 100 && trim($supervisor) != "S")
	   	   {
	  		$bonus=($salario * 0.1);	
	   	   }
   	}
   $pdf->cell(30,5,number_format($bonus,2,",","."),'LRTB',0,'R'); // Bonus  
   $pdf->cell(20,5,number_format($pct_imprime,2,",","."),'LRTB',0,'R');
   $t_val_comis=$t_val_comis+$sal_alcancado+$val_ind;
   $t_val_bonus=$t_val_bonus+$bonus;
   }
   // Totais dos atendentes TLMK
  if($tipo=="K")
   {
    if($cota==0)
    {
     $pct_alcancado=0;
    }else{
     $pct_alcancado=round((($val_nf*100)/$cota));
     $pct_imprime=$pct_alcancado;
  	}
    
    $pct_alc=round($pct_alcancado);
    
    $pct_consulta = 0;
    /*
    // pct m�ximo de 160% de cobertura
    if($pct_alc > 160)
    	$pct_consulta = 160;
    else 
    	$pct_consulta = $pct_alc;
    */	
    $pct_consulta = $pct_alc;
        
     $cons_faixa="SELECT *
                 from lt1200_faixas_comis_tlmk a
                where '".$pct_consulta."' between  a.pct_ini and a.pct_fin
                 " ;

     $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_faixa = $cquery($cons_faixa,$res_faixa);
     $mat_faixa=$cfetch_row($result_faixa);
     $pct_sal=$mat_faixa["pct_sal"];

     $pct_alcancado=$pct_sal;
     $pct_imprime=$pct_alc;
     
    if($pct_alc < $pct_nff)
     {
      $pct_alcancado=0;
     }
    
    $sal_alcancado=($salario*$pct_alcancado/100);
    
    if($ind=="S")
    {
     $val_ind=($sal_alcancado/12);
     $pdf->cell(30,5,number_format($val_ind+$sal_alcancado,2,",","."),'LRTB',0,'R');
    }else{
     $pdf->cell(30,5,number_format($sal_alcancado,2,",","."),'LRTB',0,'R');
    }
   $bonus=0;
   
   $pdf->cell(30,5,number_format($bonus,2,",","."),'LRTB',0,'R'); // Bonus  
   $pdf->cell(20,5,number_format($pct_imprime,2,",","."),'LRTB',0,'R');
   $t_val_comis=$t_val_comis+$sal_alcancado+$val_ind;
   $t_val_bonus=$t_val_bonus+$bonus;
   }
   // Representantes
   if($tipo=="R" or $tipo=="A" or $tipo=="C")
   {
    $val_com_nff=($val_nf*$pct_nff/100);
    $val_com_dp=($val_dp*$pct_dp/100);

    $val_tot_com=$val_com_nff+$val_com_dp;
    $sal_alcancado=$val_tot_com;
    if($ind=="S")
    {
     $val_ind=($sal_alcancado/12);
     $pdf->cell(30,5,number_format($val_ind+$sal_alcancado,2,",","."),'LRTB',0,'R');
    }else{
     $pdf->cell(30,5,number_format($sal_alcancado,2,",","."),'LRTB',0,'R');
    }
   $bonus=0;
   if($gestor!="S" && $rep_ant != "127" && $rep_ant != "198") // PROVIS�RIO (criar um campo no cadastro de repres para indicar se tem bonus ou n�o)
   	{
	   if($pct_imprime >= 65 && trim($supervisor) == "S")
		   {
		   	//(22/07/2009) - Marcelo Peres - Inclus�o da tabela gradual de b�nus
		   	 if($pct_alc >= 65 && $pct_alc < 75)
		   	 	$bonus=600;
		   	 elseif($pct_alc >= 75 && $pct_alc < 85)
		   	 	$bonus=800;
		   	 elseif($pct_alc >= 85 && $pct_alc < 100)
		   	 	$bonus=1000;
		   	 elseif($pct_alc >= 100 && $pct_alc < 120)
		   	 	$bonus=1200;
		   	 elseif($pct_alc >= 120)
		   	 	$bonus=1500;
		   }
	   elseif($pct_imprime >= 101 && trim($supervisor) != "S")
	   	   {
	  		$bonus=($sal_alcancado * 0.1);	
	   	   }
   	}
   $pdf->cell(30,5,number_format($bonus,2,",","."),'LRTB',0,'R'); //Bonus
   $pdf->cell(20,5,number_format($pct_imprime,2,",","."),'LRTB',0,'R');
   $t_val_comis=$t_val_comis+$sal_alcancado+$val_ind;
   $t_val_bonus=$t_val_bonus+$bonus;
   }
   $val_nf=0;
   $val_dp=0;
  }
 }
 $pdf->ln();
 $pdf->cell(125,5,'TOTAL GERAL','LRTB',0,'L');
 $pdf->cell(35,5,number_format($t_val_nf,2,",","."),'LRTB',0,'R');
 $pdf->cell(35,5,number_format($t_val_dp,2,",","."),'LRTB',0,'R');
 $pdf->cell(30,5,number_format($t_val_comis,2,",","."),'LRTB',0,'R');
 $pdf->cell(30,5,number_format($t_val_bonus,2,",","."),'LRTB',0,'R');

 $pdf->ln();
 $val_nf=0;
 $val_dp=0;
 $pdf->ln();
 $pdf->Output('rcomis.pdf',true);
?>



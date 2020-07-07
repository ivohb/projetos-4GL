<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten�o:     Henrique
 //Data manuten�o30/08/2005
 //Mdulo:        Fame
 //Processo:     Rela��o cliente com Direito a Relogio
 //-----------------------------------------------------------------------------
 $prog="fame/fam0018";
 $versao=1;  
 $mes_ctr=round($mes_ini);
 $ano_ctr=round($ano_ini);
 $dia_ctr=round($dia_ini);
 $mesano_ctr=$mes_ctr.$ano_ctr;
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $data_cab=sprintf("%02d/%02d/%04d",$dia_ctr,$mes_ctr,$ano_ctr);
 $empresa="01";
 include('../../bibliotecas/atu_ped.inc');

 if($det<>"S")
 {
 $atualiza="select max(num_om) as ult_om from ordem_montag_mest
            where cod_empresa='".$empresa."' ";

 $res_atu = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_atu = $cquery($atualiza,$res_atu);
 $mat_atu=$cfetch_row($result_atu);
 $ult_om=$mat_atu["ult_om"];

 $atu_proc="update lt1200_ctr_prom set
            num_proc=num_proc+1,
            prim_om=ult_om,
            ult_om='".$ult_om."',
            date_proc='".$data."' ";

 $res_proc = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_proc = $cquery($atu_proc,$res_proc);

 $sel_proc="select * from lt1200_ctr_prom";

 $res_proc = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_proc = $cquery($sel_proc,$res_proc);
 $mat_atu=$cfetch_row($result_proc);
 $prim_om=$mat_atu["prim_om"];
 $ult_om=$mat_atu["ult_om"];
 $num_proc=$mat_atu["num_proc"];
 $del_cancel="delete from lt1200_cli_prom
              where num_om not in (select num_om from
                       logix:ordem_montag_mest)
             ";
 $res_cancel = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_cancel = $cquery($del_cancel,$res_cancel);

  $ins_promo="insert into lt1200:lt1200_cli_prom
            SELECT
                'D',c.cod_cliente,a.cod_empresa,a.num_om,a.num_nff,
               a.dat_emis,'".$num_proc."',c.num_pedido,
               CASE when k.cod_grupo_item in('048','049')
                       then qtd_reservada
                       ELSE 0
                      end promo,
               CASE when k.cod_grupo_item in('008','022','045')
                       then qtd_reservada
                       ELSE 0
                      end outras
             from ordem_montag_mest a,
                  ordem_montag_item b,
                  pedidos c,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  vnempre o
             where a.cod_empresa ='01'
               and b.num_om=a.num_om
               and b.cod_empresa=a.cod_empresa
               and c.ies_sit_pedido in ('N','2','F','3','1','B')
               and c.num_pedido=b.num_pedido
               and c.dat_pedido > '30/11/2005'
               and k.cod_empresa=b.cod_empresa
               and k.cod_item=b.cod_item
               and k.cod_grupo_item in('048','049','008','022','045')
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=b.cod_item
               and m.cod_empresa=b.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and o.cdclierp=c.cod_cliente
               and o.cdrmneg  in ('01','02','03','04') ";
  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo= $cquery($ins_promo,$res_promo);

  $ins_promo="insert into lt1200:lt1200_cli_prom
             select 'I',cod_cliente,cod_empresa,num_om,
                 num_nff,date_emis,num_proc,num_pedido,
                 sum(nducha),sum(ducha)
             from lt1200:lt1200_cli_prom
             where num_proc='".$num_proc."'
                and tipo='D' 
            group by 1,2,3,4,5,6,7,8";
  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo= $cquery($ins_promo,$res_promo);
  $ins_promo="insert into lt1200:lt1200_cli_prom
              select 'P',cod_cliente,cod_empresa,num_om,
               num_nff,date_emis,num_proc,num_pedido,nducha,ducha
              from lt1200:lt1200_cli_prom
              where num_proc='".$num_proc."'
                  and tipo='I'
                and nducha+ducha > 29
                and nducha > 3
               and cod_cliente not in
                     (select cod_cliente from lt1200:lt1200_cli_prom where tipo='P')";
  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo= $cquery($ins_promo,$res_promo);
  $ins_promo="delete from lt1200:lt1200_cli_prom
                where num_proc='".$num_proc."'
                 and tipo in ('D','I')";

  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo= $cquery($ins_promo,$res_promo);
 } 
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
 $mes_num=$mes_ctr;

 $titulo="CLIENTES COM DIREITO A RELOGIO   PROCESSAMENTO:".$num_proc ;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 if($det<>"S")
 {
  $selec_promo="select a.num_proc,a.num_om,a.num_nff,a.num_pedido,a.nducha,a.ducha,b.nom_cliente
                 from lt1200:lt1200_cli_prom a, clientes b
                   where b.cod_cliente=a.cod_cliente
                     and a.num_proc='".$num_proc."'
                 order by 1";
 }else{
  if($proc<>"todos")
  {
   $processos="and a.num_proc=".$proc;
  }else{
   $processos="";
  }

  $selec_promo="select a.num_proc,a.num_om,a.num_nff,a.num_pedido,a.nducha,a.ducha,b.nom_cliente
                 from lt1200:lt1200_cli_prom a, clientes b
                   where b.cod_cliente=a.cod_cliente
                     $processos
                 order by 1,2";
 }
  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo = $cquery($selec_promo,$res_promo);
  $mat_promo=$cfetch_row($result_promo);
    $pdf->SetFont('Arial','B',10);
    $pdf->setx(10);
    $pdf->Cell(20,5,'OM',TBLR,0,'C');
    $pdf->Cell(20,5,'NUM_PROC',TBLR,0,'C');
    $pdf->Cell(20,5,'PEDIDO',TBLR,0,'C');
    $pdf->Cell(80,5,'CLIENTE',TBLR,0,'C');
    $pdf->SetFillColor(220);
    $pdf->Cell(30,5,'NOVA DUCHA',TBLR,0,'L',1);
    $pdf->SetFillColor(260);
    $pdf->Cell(20,5,'OUTRAS',TBLR,0,'L');
    $pdf->ln();
  $total=0;
  while (is_array($mat_promo))
  {
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->Cell(20,5,round($mat_promo["num_om"]),TBLR,0,'R');
    $pdf->Cell(20,5,round($mat_promo["num_proc"]),TBLR,0,'R');
    $pdf->Cell(20,5,round($mat_promo["num_pedido"]),TBLR,0,'R');
    $pdf->Cell(80,5,$mat_promo["nom_cliente"],TBLR,0,'L');
    $pdf->SetFillColor(220);
    $pdf->Cell(30,5,round($mat_promo["nducha"]),TBLR,0,'R',1);
    $pdf->SetFillColor(260);
    $pdf->Cell(20,5,round($mat_promo["ducha"]),TBLR,0,'R');
    $pdf->ln();
    $total=$total+1;
  $mat_promo=$cfetch_row($result_promo);
 }
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->Cell(50,5,"TOTAL DE RELOGIOS:",TBLR,0,'R');
    $pdf->Cell(20,5,round($total),TBLR,0,'R');
    $pdf->ln();

 $pdf->Output('relogio.pdf',D);
?>
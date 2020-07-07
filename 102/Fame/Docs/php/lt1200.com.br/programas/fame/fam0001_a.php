<?
 copy($import1,"tmp/".$destino);
 unlink($import1);
 //-----------------------------------------------------------------------------
 //Módulo:         FAM
 //Processo:       Consistencia de Arquivo
 //-----------------------------------------------------------------------------
 $data=sprintf("%02d/%02d/%04d-%02d:%02d",$dia,$mes,$ano,$hora,$min);
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);


 $argv[0];
 $argv[1]='tmp/lt1200_imp_fame.txt';
 $argv[2]='lt1200_imp_fame';
 $argv[3]='S';
 
 //DELIMITADORES
 $delimita = "|";
 if(file_exists($argv[1])) 
 {
  $conecta_ifx =ifx_connect("lt1200",$ifx_user,$ifx_senha);
  $arquivo= file("$argv[1]");
  $qtdecampos = explode("$delimita",$arquivo[0]);
  $qtdecampos = count($qtdecampos)-1;
  // Verificando se a quantidade de campos concide com o banco
  $query=" select count(a.tabname) as mqc
                from  systables a, syscolumns b
               where b.tabid=a.tabid
                     and a.tabname='".$argv[2]."'";
  $res = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result = $cquery($query,$res);
  $mat=$cfetch_row($result);
  $mqc=($mat["mqc"]-6);
  $mcampos="0";
  $linha=0;
  $primeiro=0; 
  if($mqc != $qtdecampos)
  {
   $mcampos="O arquivo contem". $qtdecampos." colunas e o programa de importação  so aceita $mqc";
  }
 
  //Se tabela existir remove o conteúdo caso selecionar opcao s
  if($argv[3]=="S" or $argv[3]=="s")
  {
   $query="delete from ".$argv[2]."
             where cod_empresa <> '' ";
  
   $res = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result = $cquery($query,$res);
  }
  $ac = count($arquivo);
  unset($sql);

  for($x=0;$x<$ac;$x++)
  {
   $linha=$linha+1;
   $valor_campo = explode("$delimita",$arquivo[$x]);
   $valor_campo[0] = str_replace("\"","",$valor_campo[0]);
   $valor_campo[0] = str_replace('\'','',$valor_campo[0]);
   $sql = 'insert into lt1200_imp_fame
   (linha,cod_empresa,num_lote,cod_sistema,dat_refer,num_conta,ies_tipo_lanc,dat_movto,val_lanc,cod_rateio,cod_hist,tex_compl,ies_sit_lanc,cod_lin_prod,cod_lin_recei,cod_seg_merc,cod_cla_uso,
   c_hist,c_per,c_sist,c_cont,c_plan) values('.$linha.',"'.$valor_campo[0];
   if($primeiro==0)
   {
    $empresa=$valor_campo[0];
    $primeiro=$primeiro+1;
   }   
   for($y=1;$y<$qtdecampos;$y++)
   {
    $valor_campo[$y] = str_replace("\"'","",$valor_campo[$y]);
    $valor_campo[$y] = str_replace(",",".",$valor_campo[$y]);
    $valor_campo[$y] = str_replace(" ","",$valor_campo[$y]);
    $sql=$sql.'","'.$valor_campo[$y];
   }
   
   if($mcampos=="0")
   {
    $sql=rtrim($sql).'","0","0","0","0","0';
    $sql=rtrim($sql).'")';
    $res = $cconnect("lt1200",$ifx_user,$ifx_senha);

    $result=$cquery($sql,$res); 
    
   }
  }
 } else {
  exit;    
 }


 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax,
                b.cod_usuario,b.cod_rep,b.erep,b.ctr_exp,
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
 $titulo='FAME - Relatório de Inconsistencia de Arquivo de importação';
 include('../../bibliotecas/cabec_s.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage(); 
 $pdf->SetFont('Arial','B',10);
 $pdf->SetFillColor(260);
 $pdf->setx(10);
 $xposr=$pdf->getx(); 
 $yposr=$pdf->gety();
 $pdf->SetFillColor(260);
//  testa plano de contas
  $contas="update lt1200:lt1200_imp_fame set c_plan=1
           where cod_empresa||num_conta not in (
           select cod_empresa||num_conta_reduz
               from plano_contas)
                  "; 
           $res_cta = $cconnect("logix",$ifx_user,$ifx_senha);
           $result_cta = $cquery($contas,$res_cta);

  //testa Lotes
  $lotes="update lt1200:lt1200_imp_fame set c_cont=1
           where cod_empresa||cod_sistema||num_lote not in (
            select cod_empresa||cod_sistema||num_lote_lanc_cont
               from controle_lotes) 
                  "; 
  $res_lote = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_lote = $cquery($lotes,$res_lote);

  //testa Sistemas
  $sistemas="update lt1200:lt1200_imp_fame set c_sist=1
               where cod_empresa||cod_sistema not in (select cod_empresa||cod_sistema 
               from sistemas )
                  "; 
  $res_sistema = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_sistema = $cquery($sistemas,$res_sistema);

  //testa HISTORICO
  $historicos="update lt1200:lt1200_imp_fame set c_hist=1
               where cod_empresa||cod_hist not in 
                (select cod_empresa||cod_hist  
                 from hist_padrao)
                  "; 
  $res_historicos = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_historicos = $cquery($historicos,$res_historicos);

  $selecao="select * from lt1200_imp_fame
                where (c_hist+c_per+c_sist+c_cont+c_plan) > 0
                  order by linha ";
  $res = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result = $cquery($selecao,$res);
  $mat_selec=$cfetch_row($result);
  $pdf->Ln();
  $pdf->SetFont('Arial','B',8);
  $pdf->cell(8,5,"REG",'0',0,L,1);
  $pdf->cell(8,5,"EMP",'0',0,L,1);
  $pdf->cell(15,5,"LOTE",'0',0,R,1);
  $pdf->cell(20,5,"SISTEMA",'0',0,L,1);
  $pdf->cell(18,5,"DAT REF",'0',0,L,1);
  $pdf->cell(25,5,"N.CONTA",'0',0,L,1);
  $pdf->cell(15,5,"TP LCTO",'0',0,L,1);
  $pdf->cell(22,5,"DAT MOVTO",'0',0,L,1);
  $pdf->cell(30,5,"Val.LCTO",'0',0,R,1);
  $pdf->cell(15,5,"CD.RAT.",'0',0,L,1);
  $pdf->cell(22,5,"CD.HIST",'0',0,L,1);
  $pdf->cell(70,5,"CPL",'0',0,L,1);
  $pdf->Ln();
  while (is_array($mat_selec))
  {
   $pdf->SetFillColor(260);
   $pdf->Ln();
   $pdf->SetFont('Arial','B',8);
   $pdf->cell(8,4,$mat_selec["linha"],'0',0,L,1);
   $pdf->cell(8,4,$mat_selec["cod_empresa"],'0',0,L,1);
   $pdf->cell(15,4,$mat_selec["num_lote"],'0',0,R,1);
   $pdf->cell(20,4,$mat_selec["cod_sistema"],'0',0,L,1);
   $pdf->cell(18,4,$mat_selec["dat_refer"],'0',0,L,1);
   $pdf->cell(25,4,$mat_selec["num_conta"],'0',0,L,1);
   $pdf->cell(15,4,$mat_selec["ies_tipo_lanc"],'0',0,L,1);
   $pdf->cell(22,4,$mat_selec["dat_movto"],'0',0,L,1);
   $pdf->cell(30,4,number_format($mat_selec["val_lanc"],2,",","."),'0',0,R,1); 
   $pdf->cell(15,4,$mat_selec["cod_rateio"],'0',0,L,1);
   $pdf->cell(22,4,round($mat_selec["cod_hist"]),'0',0,L,1);
   $pdf->cell(70,4,$mat_selec["tex_compl"],'0',0,L,1);
   $pdf->Ln();
   if($mat_selec["c_plan"]==1){
    $pdf->cell(100,4,'Registro não encontrado no Plano Contas','0',0,L,1);
   $pdf->Ln();
   } 
   if($mat_selec["c_cont"]==1){
    $pdf->cell(100,4,'Lote não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($mat_selec["c_sist"]==1){
    $pdf->cell(100,4,'Sistema  não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($mat_selec["c_per"]==1){
    $pdf->cell(100,4,'Periodo não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($mat_selec["c_hist"]==1){
    $pdf->cell(100,4,'Histórico  não existe','0',0,L,1);
    $pdf->Ln();
   }
  $mat_selec=$cfetch_row($result);
 }
 $pdf->Output('consiste.pdf',true);
?> 
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
  $mqc=($mat["mqc"]-1);
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
   $sql = 'insert into lt1200_imp_fame (linha,cod_empresa,num_lote,cod_sistema,dat_refer,num_conta,ies_tipo_lanc,dat_movto,val_lanc,cod_rateio,cod_hist,tex_compl,ies_sit_lanc,cod_lin_prod,cod_lin_recei,cod_seg_merc,cod_cla_uso) values('.$linha.',"'.$valor_campo[0];
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

 $selecao="select * from lt1200_imp_fame
                  order by linha ";
 $res = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result = $cquery($selecao,$res);
 $mat_selec=$cfetch_row($result);
 if($mcampos<>"0")
 {
  $pdf->SetFillColor(260);
  $pdf->Ln();
  $pdf->SetFont('Arial','B',12);
  $pdf->cell(150,5,$mcampos,'0',0,L,1);
 } 
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
/* $pdf->cell(10,5,"SIT",'0',0,L,1);
 $pdf->cell(10,5,"L.PROD",'0',0,L,1);
 $pdf->cell(10,5,"L.RECE",'0',0,L,1);
 $pdf->cell(10,5,"S.MERC",'0',0,L,1);
 $pdf->cell(10,5,"C.USO",'0',0,L,1);
*/ $pdf->Ln();
 $controle=0;
 while (is_array($mat_selec))
 {
  $num_conta=chop($mat_selec["num_conta"]);
  $cod_emp=chop($mat_selec["cod_empresa"]);
  $cod_sistema=chop($mat_selec["cod_sistema"]);

  //testa plano de contas
  $contas="select num_conta,ies_titulo,ies_sit_conta from plano_contas
                 where num_conta_reduz='".$num_conta."' and cod_empresa='".$cod_emp."'
        
                  "; 
           $res_cta = $cconnect("logix",$ifx_user,$ifx_senha);
           $result_cta = $cquery($contas,$res_cta);
           $mat_cta=$cfetch_row($result_cta);
  $plano_cta="1";
  $plano_cta_t="0";
  $plano_cta_s="0";
  while (is_array($mat_cta))
  {
   if(chop($mat_cta['ies_titulo'])<>'N')
   {
    $plano_cta_t=1;
   }    
   if(chop($mat_cta['ies_sit_conta'])<>'A')
   {
    $plano_cta_s=1;
   }    

   $plano_cta=0;
   $mat_cta=$cfetch_row($result_cta);
  }  

  $cod_sistema=chop($mat_selec["cod_sistema"]);
  $num_lote=round($mat_selec["num_lote"]);
  //testa Lotes
  $lotes="select num_lote_lanc_cont,cod_sistema
               from controle_lotes 
                where cod_empresa='".$cod_emp."'
                  and cod_sistema='".$cod_sistema."'
                  and num_lote_lanc_cont='".$num_lote."'
                  "; 
  $res_lote = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_lote = $cquery($lotes,$res_lote);
  $mat_lote=$cfetch_row($result_lote);
  $lote_lote=1;
  while (is_array($mat_lote))
  {
   $lote_lote=0;
   $mat_lote=$cfetch_row($result_lote);
  }  

  //testa Sistemas
  $sistemas="select cod_sistema 
               from sistemas 
                where cod_empresa='".$cod_emp."'
                  and cod_sistema='".$cod_sistema."'
                  "; 
  $res_sistema = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_sistema = $cquery($sistemas,$res_sistema);
  $mat_sistema=$cfetch_row($result_sistema);
  $cnt_sistema=1;
  while (is_array($mat_sistema))
  {
   $cnt_sistema=0;
   $mat_sistema=$cfetch_row($result_sistema);
  }  


  //testa Periodos
  $num_lote=round($mat_selec["num_lote"]);
  $dat_lancto=$mat_selec["dat_movto"];
   
  $periodos="select * 
                 from periodos
                where cod_empresa='".$cod_emp."'
                  and dat_ini_seg_per <= '".$dat_lancto."'
                  and dat_fim_seg_per >= '".$dat_lancto."'
                  "; 
  $res_periodos = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_periodos = $cquery($periodos,$res_periodos);
  $mat_periodos=$cfetch_row($result_periodos);
  $cnt_periodos=1;
  while (is_array($mat_periodos))
  {
   $cnt_periodos=0;
   $mat_periodos=$cfetch_row($result_periodos);
  }  

  //testa HISTORICO
  $cod_hist=$mat_selec["cod_hist"];
   
  $historicos="select * 
                 from hist_padrao
                where cod_empresa='".$cod_emp."'
                  and cod_hist== '".$cod_hist."'
                  "; 
  $res_historicos = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_historicos = $cquery($historicos,$res_historicos);
  $mat_historicos=$cfetch_row($result_historicos);
  $cnt_historicos=1;
  while (is_array($mat_historicos))
  {
   $cnt_historicos=0;
   $mat_historicos=$cfetch_row($result_historicos);
  }  
  $controle=$controle+$plano_cta+$plano_cta_s+$plano_cta_t+$lote_lote+
   $cnt_sistema+$cnt_periodos+$cnt_historicos;
  if($controle > 0)
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
/*   $pdf->cell(10,4,$mat_selec["ies_sit_lanc"],'0',0,L,1);
   $pdf->cell(10,4,$mat_selec["cod_lin_prod"],'0',0,L,1);
   $pdf->cell(10,4,$mat_selec["cod_lin_recei"],'0',0,L,1);
   $pdf->cell(10,4,$mat_selec["cod_seg_merc"],'0',0,L,1);
   $pdf->cell(10,4,$mat_selec["cod_cla_uso"],'0',0,L,1);
   $pdf->cell(10,4,$mat_selec["cod_cla_uso"],'0',0,L,1);
*/   $pdf->SetFillColor(260);
   $pdf->Ln();
   if($plano_cta==1){
    $pdf->cell(100,4,'Registro não encontrado no Plano Contas','0',0,L,1);
   $pdf->Ln();
   } 
   if($plano_cta_t==1){
    $pdf->cell(100,4,'Conta está com campo ies_titulo diferente de << N >>','0',0,L,1);
   $pdf->Ln();
   } 
   if($plano_cta_s==1){
    $pdf->cell(100,4,'Conta está com situação diferente de << A >>','0',0,L,1);
   $pdf->Ln();
   } 
   if($lote_lote==1){
    $pdf->cell(100,4,'Lote não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($cnt_sistema==1){
    $pdf->cell(100,4,'Sistema  não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($cnt_periodos==1){
    $pdf->cell(100,4,'Periodo não existe','0',0,L,1);
    $pdf->Ln();
   }
   if($cnt_historicos==1){
    $pdf->cell(100,4,'Histórico  não existe','0',0,L,1);
    $pdf->Ln();
   }
   $controle=0;
  }
  $mat_selec=$cfetch_row($result);
 }
 $pdf->Output('consiste.pdf',true);
?> 
<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:13/07/2005
 //Módulo:         FAM
 //Processo:       Relatório de Inconsistencia de Arquivo
 //Versão:         1.0
 $prog="fame/fam0001";
 $versao="1";
 //-----------------------------------------------------------------------------
 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 $a_color="#6465B1";
 $b_color="#434EB1";
 $c_color="#000066";
 $bot_style ='border-botton:.75pt;border-color:"'.$b_color.'";border-style:solid;border-left:none;border-top:none;border-right:none';
 $n_style ='border-color:white;border-style:solid;border-bottom:none;border-left:none;border-right:none;border-top:none';
 $top_style ='border-top:.75pt;border-color:"'.$b_color.'";border-style:solid;border-bottom:none;border-left:none;border-right:none';

 $top_bot_style='border-top:.75pt;border-botton:.75pt;border-color:"'.$c_color.'";border-style:solid;border-left:none;border-right:none';

 $all_style='border-top:.75pt;border-botton:.75pt;border-left:.75pt;border-right:.75pt;border-color:"'.$b_color.'";border-style:solid';
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $c_color="#000099";
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
         printf("<TABLE WIDTH=750 BORDER=0 border-style=solid bordercolor='#3366cc'  CELLPADDING=1 CELLSPACING=0 RULES=groups  style='page-break-after:right' >
         <tr >
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         </tr>
         <tr>
         <td width='300' style=$n_style rowspan='3' colspan='30'  ><img src='../../imagens/logocpd3.jpg'></td> 
         <td width='450'  style=$n_style colspan='45'     align='center'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         $nome_</font></i></b>
         </td>
         </tr>
         <tr>
         <td width='430'  style=$n_style colspan='43'     align='right'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
         Versão:</font></i></b>
         </td>
         <td width='20'  style=$n_style colspan='2'     align='right'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
         $versao</font></i></b>
         </td>
         </tr>
         <tr>
         <td width='300'  style=$n_style colspan='30'     align='left'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$b_color>
         Usuario:$ifx_user</font></i></b>
         </td>
         <td width='80'  style=$n_style colspan='8'     align='right'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$a_color>
         Data:</font></i></b>
         </td>
         <td width='70'  style=$n_style colspan='7'     align='left'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$a_color>
         $data</font></i></b>
         </td>
         </tr>
         </tr>
         <tr>
         </tr>
         </table>
         <TABLE WIDTH=750 BORDER=0 border-style=solid bordercolor=$c_color  CELLPADDING=1 CELLSPACING=0 RULES=groups  style='page-break-after:right' >
         <tr >
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         </tr>
         <tr>
          <td width='750' colspan='75' style=$top_bot_style height=1 ></td>
         </tr>
          <td width='750' colspan='75' style=$n_style height=1 ></td>
         </tr>
 ");
 if($nome_<>"")
 {
  
  printf("
  <form action='fam0001_a.php' method='post' enctype='multipart/form-data'>
  <tr><td><input type='file' name='import1' size=70></td></tr>
  <tr><td><input type='hidden' name='destino' value='lt1200_imp_fame.txt' size='02'></td></tr>
  <tr><td><input type='submit'></td></tr>
  </FORM>");
  include("../../bibliotecas/autentica.inc");
 }else{
  fechar();
 }
 printf("</html>");
?>

<?php
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 $a_color="#6465B1";
 $b_color="#434EB1";
 $c_color="#000066";

 $bot_style
='border-botton:.75pt;border-color:"'.$b_color.'";border-style:solid;border-left:none;border-top:none;border-right:none';
  $n_style    ='border-color:#FF9900;border-style:solid;border-left:none;border-right:none;border-top:none;border-bottom:none';
 $top_style ='border-top:.75pt;border-color:"'.$b_color.'";border-style:solid;border-bottom:none;border-left:none;border-right:none';
$top_bot_style='border-top:.75pt;border-bottom:.75pt;border-color:"'.$c_color.'";border-style:solid;border-left:none;border-right:none';

 $nstyle    ="border-color:#FF9900;border-style:solid;border-left:none;border-right:none;border-top:none;border-bottom:none";
 $tstyle    ="border-top:.75pt;border-color:#FF9900;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $bstyle    ="border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-top:none;border-left:none;border-right:none";
 $rstyle    ="border-right:.75pt;border-color:#FF9900;border-style:solid;border-left:none;border-bottom:none;border-top:none";
 $rbstyle   ="border-right:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-left:none;border-top:none";
 $rtstyle   ="border-top:.75pt;border-right:.75pt;border-color:#FF9900;border-style:solid;border-left:none;border-bottom:none";
 $rtbstyle  ="border-top:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-left:none";
 $rltbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid";
 $rltstyle  ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-color:#FF9900;border-style:solid;border-bottom:none";
 $lstyle    ="border-left:.75pt;border-color:#FF9900;border-style:solid;border-right:none;border-bottom:none;border-top:none";
 $lrstyle  = "border-left:.75pt;border-right:.75pt;border-color:#FF9900;border-style:solid;border-top:none;border-bottom:none";
 $lbstyle   ="border-left:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-top:none;border-right:none";

 $ltstyle   ="border-top:.75pt;border-left:.75pt;border-color:#FF9900;border-style:solid;border-right:none;border-bottom:none";
 $ltbstyle  ="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-right:none";
 $lrtbstyle="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-right:.75pt;border-color:#FF9900;border-style:solid";
 $lrtstyle ="border-top:.75pt;border-left:.75pt;border-right:.75pt;border-color:#FF9900;border-style:solid;border-bottom:none";
 $lrbstyle ="border-left:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:#FF9900;border-style:solid;border-top:none;";

//bordas Pretas
 $black_tstyle     ="border-top:.75pt;border-color:black;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $black_bstyle    ="border-bottom:.75pt;border-color:black;border-style:solid;border-top:none;border-left:none;border-right:none";
 $black_rstyle    ="border-right:.75pt;border-color:black;border-style:solid;border-left:none;border-bottom:none;border-top:none";
 $black_rbstyle   ="border-right:.75pt;border-bottom:.75pt;border-color:black;border-style:solid;border-left:none;border-top:none";
 $black_rtstyle   ="border-top:.75pt;border-right:.75pt;border-color:black;border-style:solid;border-left:none;border-bottom:none";
 $black_rtbstyle  ="border-top:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:black;border-style:solid;border-left:none";
 $black_rltbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:black;border-style:solid";
 $black_lstyle    ="border-left:.75pt;border-color:black;border-style:solid;border-right:none;border-bottom:none;border-top:none";
 $black_lrstyle  = "border-left:.75pt;border-right:.75pt;border-color:black;border-style:solid;border-top:none;border-bottom:none";
 $black_lbstyle   ="border-left:.75pt;border-bottom:.75pt;border-color:black;border-style:solid;border-top:none;border-right:none";
 $black_ltstyle   ="border-top:.75pt;border-left:.75pt;border-color:black;border-style:solid;border-right:none;border-bottom:none";
 $black_ltbstyle  ="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:black;border-style:solid;border-right:none";
 $black_lrtbstyle="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-right:.75pt;border-color:black;border-style:solid";
 $black_lrtstyle ="border-top:.75pt;border-left:.75pt;border-right:.75pt;border-color:black;border-style:solid;border-bottom:none";
 $black_lrbstyle ="border-left:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:black;border-style:solid;border-top:none;";
 $black_lrbbstyle ="border-left:.75pt;border-right:.75pt;border-bottom:2.5pt;border-color:black;border-style:solid;border-top:none;";
 $black_rtbbstyle  ="border-top:.75pt;border-right:.75pt;border-bottom:2.5pt;border-color:black;border-style:solid;border-left:none";
 $black_rltbbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:2.5pt;border-color:black;border-style:solid";
 $black_rltbbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:2.5pt;border-color:black;border-style:solid";

//bordas Azuis
 $blue_tstyle     ="border-top:.75pt;border-color:blue;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $blue_bstyle    ="border-bottom:.75pt;border-color:blue;border-style:solid;border-top:none;border-left:none;border-right:none";
 $blue_rstyle    ="border-top:.75pt;border-right:.75pt;border-color:blue;border-style:solid;border-left:none;border-bottom:none;border-top:none;";
 $blue_rbstyle   ="border-right:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid;border-left:none;border-top:none";
 $blue_rtstyle   ="border-top:.75pt;border-right:.75pt;border-color:blue;border-style:solid;border-left:none;border-bottom:none";
 $blue_rtbstyle  ="border-top:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid;border-left:none";
 $blue_rltbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid";
 $blue_lstyle    ="border-left:.75pt;border-color:blue;border-style:solid;border-right:none;border-bottom:none;border-top:none";
 $blue_lrstyle  = "border-left:.75pt;border-right:.75pt;border-color:blue;border-style:solid;border-top:none;border-bottom:none";
 $blue_lbstyle   ="border-left:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid;border-top:none;border-right:none";
 $blue_ltstyle   ="border-top:.75pt;border-left:.75pt;border-color:blue;border-style:solid;border-right:none;border-bottom:none";
 $blue_ltbstyle  ="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid;border-right:none";
 $blue_lrtbstyle="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-right:.75pt;border-color:blue;border-style:solid";
 $blue_lrtstyle ="border-top:.75pt;border-left:.75pt;border-right:.75pt;border-color:blue;border-style:solid;border-bottom:none";
 $blue_lrbstyle ="border-left:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:blue;border-style:solid;border-top:none;";

//bordas Verdes
 $green_tstyle     ="border-top:.75pt;border-color:green;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $green_bstyle    ="border-bottom:.75pt;border-color:green;border-style:solid;border-top:none;border-left:none;border-right:none";
 $green_rstyle    ="border-top:.75pt;border-right:.75pt;border-color:green;border-style:solid;border-left:none;border-bottom:none;border-top:none;";
 $green_rbstyle   ="border-right:.75pt;border-bottom:.75pt;border-color:green;border-style:solid;border-left:none;border-top:none";
 $green_rtstyle   ="border-top:.75pt;border-right:.75pt;border-color:green;border-style:solid;border-left:none;border-bottom:none";
 $green_rtbstyle  ="border-top:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:green;border-style:solid;border-left:none";
 $green_rltbstyle ="border-top:.75pt;border-right:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:green;border-style:solid";
 $green_lstyle    ="border-left:.75pt;border-color:green;border-style:solid;border-right:none;border-bottom:none;border-top:none";
 $green_lrstyle  = "border-left:.75pt;border-right:.75pt;border-color:green;border-style:solid;border-top:none;border-bottom:none";
 $green_lbstyle   ="border-left:.75pt;border-bottom:.75pt;border-color:green;border-style:solid;border-top:none;border-right:none";
 $green_ltstyle   ="border-top:.75pt;border-left:.75pt;border-color:green;border-style:solid;border-right:none;border-bottom:none";
 $green_ltbstyle  ="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-color:green;border-style:solid;border-right:none";
 $green_lrtbstyle="border-top:.75pt;border-left:.75pt;border-bottom:.75pt;border-right:.75pt;border-color:green;border-style:solid";
 $green_lrtstyle ="border-top:.75pt;border-left:.75pt;border-right:.75pt;border-color:green;border-style:solid;border-bottom:none";
 $green_lrbstyle ="border-left:.75pt;border-right:.75pt;border-bottom:.75pt;border-color:green;border-style:solid;border-top:none;";
 //insere botao de logoff
 printf("<FORM METHOD='POST' ACTION='../../index.php'>");
 printf("<tr>
   <td width='10'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='L' name='prog_c' size='1' maxlenght='1' readonly>
   </td>
   </FORM>");
$all_style='border-top:.75pt;border-bottom:.75pt;border-left:.75pt;border-right:.75pt;border-color:"'.$b_color.'";border-style:solid';
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $c_color="#000099";
 printf("<BODY BGCOLOR='white' DIR='LTR'>");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);

 //'<input type='hidden' name='nav' value='symbol' size='10'>'
 //'<input type='hidden' name='nav' value='arial' size='10'>'
/* printf("<script language='javascript' type='TEXT/JAVASCRIPT'>
  ie4 = ( document .all) ? true : false;
   document.write (ie4 + '<br>');
   if(ie4 != true)
    {
    document.write ('yes' + '<input type='hidden' name='nav' value='symbol' size='10' maxlenght='10'>');
    }
   else
    {
    document.write ('no' + '<input type='hidden' name='nav' value='arial' size='10' maxlenght='10'>');
    }
 </script>");
echo $font;*/
//echo $_SERVER['HTTP_USER_AGENT'];

$Firefox='Mozilla/5.0 (X11; U; Linux i686; pt-BR; rv:1.8.0.1) Gecko/20060124 Firefox/1.5.0.1';
if($_SERVER['HTTP_USER_AGENT'] == $Firefox)
{
$fonte='arial black';
}else{
$fonte='courier';
}
 printf("<table border=0 width=750 border-style=solid bordercolor='#3366cc' cellpadding=1 cellspacing=0>
       <tr>
       <td width=375 rowspan='2'><img src='../../imagens/logocpd3.jpg'></td>
       <td width=375><b>
       <font face=$fonte size='3' color='#0033CC'>
       <span style='letter-spacing: 1pt'> $nome_ </font></b></td>
       </tr>
       <tr>
       <td width=375 align='right'><b>
       <font face=$fonte color='#0033CC'>
       <span style='letter-spacing: 1pt'> Usuario: $ifx_user    /    Versão: $versao</font></b></td>
       </tr>
       </table>
       <TABLE WIDTH='750' BORDER='0' border-style=solid bordercolor='0' CELLPADDING='0' CELLSPACING='0' style='page-break-after:right'>
	 <tr>
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
	 </tr>");
?>

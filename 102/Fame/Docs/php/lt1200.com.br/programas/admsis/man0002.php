<?PHP 
 $versao="1";
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $hora=date("h");
 $min=date("i");
 $data=sprintf("%02d/%02d/%04d-%02d:%02d",$dia,$mes,$ano,$hora,$min);
 $ip=$HTTP_X_FORWARDED_FOR;
 $ip_ext=$REMOTE_ADDR;
 $teste=session_register("id");
 session_register("ifx_user");
 session_register("ifx_senha");
 session_register("nome_");
 if(!$teste)
 {
  $msg = "N�o foi poss�vel registrar essa sess�o. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 printf("<script language='javascript'>
         function chamada(n,b)
         {
          url='man0002_a.php?uid='+n+'&uid1='+b;
          window.close();
          window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
         }
         </script>");
 printf("<script language='javascript'>
         function chamada_d(n,b)
         {
          url='man0002_d.php?uid='+n+'&uid1='+b;
          window.close();
          window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
         }
         </script>");
 function fechar(){
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 $prog="admsis/man0002";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 include("../../bibliotecas/usuario.inc");
 $menu_c="select max(cod_menu) as ult_m 
            from lt1200_menu
           where cod_class=0
	   ";
 $res_menu_c=ifx_query($menu_c,$link);
 $mat_c=ifx_fetch_row($res_menu_c);
 $new_menu=$mat_c["ult_m"]+1;
 $menu="select * from lt1200_menu
         where cod_class=0
         order by cod_menu,cod_class";
 $res_menu=ifx_query($menu,$link);
 printf("<html>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 include("../../bibliotecas/style.inc");
 printf("<tr>
       </tr>
       <tr>
       <td width='750'  style=$top_bot_style colspan='75'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
       Selecione o Menu para Manuten��o</font></i>");
 $mat_menu=ifx_fetch_row($res_menu);
 while(is_array($mat_menu))
 {
  $new_clas=0;
  $cab_menu=$mat_menu["cod_menu"];
  $tit_menu=$mat_menu["titulo"];
  printf("</tr>
        <tr>
        <td width='550'  style=$n_style colspan='55'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
        $tit_menu</font></i>
        </td>
        </tr>");
  $clas_c="select max(cod_class) as ult_clas
             from lt1200_menu
 	    where cod_menu=$cab_menu
	          and cod_class <> 0
 	   ";
  $res_clas_c=ifx_query($clas_c,$link);
  $mat_clas=ifx_fetch_row($res_clas_c);
  $new_clas=$mat_clas["ult_clas"]+1;
  $clas="select a.cod_menu,a.titulo,a.cod_class,count(b.class) as men_out 
           from lt1200_menu a,
                outer lt1200_programas b
 	  where a.cod_menu=$cab_menu
		and a.cod_class <> 0
                and b.codigo=a.cod_menu
                and b.class=a.cod_class
          group by 1,2,3
    	  order by 1,2
	 ";
  $res_clas=ifx_query($clas,$link);
  $mat_clas=ifx_fetch_row($res_clas);
  $uid=$cab_menu;
  while(is_array($mat_clas))
  {
   $cab_clas=$mat_clas["cod_class"];
   $tit_clas=$mat_clas["titulo"];
   $class_menu=$mat_menu["cod_class"];   
   $men_out=$mat_clas["men_out"];
   $uid1=$cab_clas; 
   $linha= "<a href='javascript:chamada(\"".$uid."\",\"".$uid1."\");'>".$tit_clas."</a><br>";
   $linha_d= "<a href='javascript:chamada_d(\"".$uid."\",\"".$uid1."\");'>Excluir</a><br>";
   printf("</tr>
           <tr>
           <td width='50'  style=$n_style colspan='5'     align='left'>
           <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
           &nbsp</font></i>
           </td>
           <td width='550'  style=$n_style colspan='55'     align='left'>
           <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
           $linha</font></i>
          </td>");
   if($men_out=="0")
   {       
    printf("<td width='50'  style=$n_style colspan='5'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
          $linha_d</font></i>
          </td>
          </tr>
          <tr>");
   }
   $mat_clas=ifx_fetch_row($res_clas);
  }
  $uid1=$new_clas;
  $linha= "<a href='javascript:chamada(\"".$uid."\",\"".$uid1."\");'>Novo Item</a><br>";
  printf("</tr>
         <tr>
         <td width='750'  style=$top_bot_style colspan='75'     align='center'>
         <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         $linha</font></i></b>
         </td>
         </tr>
         <tr>");
  $mat_menu=ifx_fetch_row($res_menu);
 }
 printf("</html>");
?>
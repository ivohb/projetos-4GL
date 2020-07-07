<?PHP
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
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 printf("<script language='javascript'>
         function chamada(n)
         {
          url='man0001_a.php?uid='+n;
          window.close();
          window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
         }
         </script>");
 printf("<script language='javascript'>
        function chamada_d(n)
        {
         url='man0001_d.php?uid='+n;
         window.close();
         window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
        }
        </script>");
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 $prog="admsis/man0001";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 include("../../bibliotecas/usuario.inc");
 $menu_c="select max(cod_menu) as ult_m 
            from lt1200_menu
           where cod_class=0 ";
 $res_menu_c=ifx_query($menu_c,$link);
 $mat_c=ifx_fetch_row($res_menu_c);
 $new_menu=$mat_c["ult_m"]+1;
 $menu="select a.cod_menu,a.titulo,a.cod_class,max(b.cod_class) as class_out
          from lt1200_menu a, 
               lt1200_menu b
                where a.cod_class=0
                      and b.cod_menu=a.cod_menu
	        group by 1,2,3
	        order by 1,2,4 desc
	         ";
 $res_menu=ifx_query($menu,$link);
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 include("../../bibliotecas/style.inc");
 printf("<tr>
         </tr>
         <tr>
         <td width='750'  style=$top_bot_style colspan='75'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
         Selecione o Menu para Manutenção</font></i>");
 $mat_menu=ifx_fetch_row($res_menu);
 while(is_array($mat_menu))
 {
  $cab_menu=$mat_menu["cod_menu"];
  $tit_menu=$mat_menu["titulo"];
  $class_menu=$mat_menu["cod_class"];   
  $class_out=$mat_menu["class_out"];
  $uid=$cab_menu;
  $linha= "<a href='javascript:chamada(\"".$uid."\");'>".$tit_menu."</a><br>";
  $linha_d= "<a href='javascript:chamada_d(\"".$uid."\");'>Excluir</a><br>";
  printf("</tr>
         <tr>
         <td width='550'  style=$n_style colspan='55'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
         $linha</font></i>
         </td>");
  if($class_out==0)
  {
   printf("<td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
         $linha_d</font></i>
         </td>");
  }
   printf("</tr>
         <tr>");
  $mat_menu=ifx_fetch_row($res_menu);
 }
 $uid=$new_menu;
 $linha= "<a href='javascript:chamada(\"".$uid."\");'>Novo Item</a><br>";
 printf("</tr>
        <tr>
        <td width='750'  style=$top_style colspan='75'     align='center'>
        <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
        $linha</font></i></b>
        </td>
        </tr>
        <tr>");
 printf("</html>");
?>

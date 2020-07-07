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
          url='man0005_a.php?ctr_usu='+n;
          /* window.close();
          */
          window.open(url,n);
           }
         </script>");
 printf("<script language='javascript'>
         function chamada_c(n)
        {
         url='man0005_c.php?ctr_usu='+n;
         /* window.close();
         */ window.open(url,n);
         }
         </script>");
 printf("<script language='javascript'>
         function chamada_d(n)
         {
         url='man0005_dg.php?ctr_usu='+n;
         window.close();
          window.open(url,n);
         }
         </script>");
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 $prog="admsis/man0005";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 include("../../bibliotecas/usuario.inc");
 $menu="select a.cod_usuario,a.nom_funcionario 
          from logix:usuarios a,
	    lt1200_usuarios b
	    where b.cod_usuario=a.cod_usuario
	   order by a.nom_funcionario ";
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
      Selecione o Usuário para Manutenção</font></i>");

 $mat_menu=ifx_fetch_row($res_menu);
 $c_cor=1;
 while(is_array($mat_menu))
 {
  $cab_menu=$mat_menu["cod_usuario"];
  $tit_menu=$cab_menu."-".$mat_menu["nom_funcionario"];
  $class_menu=$mat_menu["cod_class"];   
  $uid=trim($cab_menu);
  $ctr_usu=trim($cab_menu);
  if($c_cor>=0)
  {
   $bgcolor='white';
  }else{
   $bgcolor='#ffcc99';
  }
  $bg_color=
  $linha= "<a href='javascript:chamada(\"".$uid."\");'>".$tit_menu."</a><br>";
  $linha_c= "<a href='javascript:chamada_c(\"".$uid."\");'>Copia de Outro Usuário</a><br>";
  $linha_d= "<a href='javascript:chamada_d(\"".$uid."\");'>Exclui Todos Acessos</a><br>";
  printf("</tr>
      <tr>
      <td width='350'  style=$n_style colspan='35'   bgcolor=$bgcolor  align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      $linha</font></i>
      </td>
      <td width='150'  style=$n_style colspan='15'   bgcolor=$bgcolor    align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      $linha_d</font></i>
      </td>
      </tr>
      <tr>");
  $mat_menu=ifx_fetch_row($res_menu);
  $c_cor=$c_cor*-1;
 }
 printf("</html>");
?>

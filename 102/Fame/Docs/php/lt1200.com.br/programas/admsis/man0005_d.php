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
 $ctr_usu=$uid3;
 $uid3=trim($uid3);
 if(!$teste)
 {
  $msg = "N�o foi poss�vel registrar essa sess�o. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 $prog="man0005";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $query=("delete from  lt1200_ctr_usuario
		 where usuario='".$uid3."'
                   and programa='".$uid2."'
               ");
 $res=ifx_query($query,$link);
 printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");
 printf("newWindow=window.open('man0005_a.php?ctr_usu=$uid3')");
 printf("</script>");
 fechar();
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 printf("</FORM>");
 printf("</BODY>");
 printf("</html>");
?>
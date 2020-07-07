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
 if(!$teste)
 {
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 function fechar(){
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");
 printf("function validForm(passForm){
	if(passForm.titulo_.value==''){
	   alert('Voce deve digitar a Descrição')
	   passForm.titulo_.focus()
	   return false
        }
        return true }");
 printf("</script>");
 $prog="man0001";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $menu="select * from lt1200_menu
	    where cod_class=0
	     and cod_menu=$uid
	   order by cod_menu,cod_class";
 $res_menu=ifx_query($menu,$link);

 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 include("../../bibliotecas/style.inc");
 printf("<BODY BGCOLOR='WHITE'>");
 printf("<FORM onSubmit='return validForm(this)'
	ACTION='man0001_b.php' method=post>");
 $msg="Informe o nome do Menu";
 printf("<tr>
      </tr>
     <tr>
      <td width='750'  style=$top_bot_style colspan='75'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
      $msg</font></i>");
 $mat_menu=ifx_fetch_row($res_menu);
 $cab_menu=$mat_menu["cod_menu"];
 $tit_menu=$mat_menu["titulo"];
 $class_menu=$mat_menu["cod_class"];   
 printf("</tr>
      <tr>

      <td width='550'  style=$n_style colspan='55'     align='left'
      <i><input type='text' size='60'value='$tit_menu' name='titulo_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='left'
      <i><input type='text' size='6'value='$uid' name='cod_menu_' readonly 
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      </tr>
      <tr>");

      printf("<td width='450'  style=$n_style colspan='45'     align='left'>
      <P><input type='submit' value='Confirma'>&nbsp;&nbsp;&nbsp;&nbsp
      </td>
      </tr>");

 printf("</FORM>");
 printf("</BODY>");
 printf("</html>");
?>

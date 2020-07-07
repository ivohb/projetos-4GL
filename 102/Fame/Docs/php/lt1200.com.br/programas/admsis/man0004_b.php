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
 function fechar() 
 {
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
 $prog="man0004";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $menu="select * from lt1200_usuarios
	    where cod_usuario='".$usuario_."'
	   ";
 $res_menu=ifx_query($menu,$link);
 $mat=ifx_fetch_row($res_menu);
 $cod_usuario=$mat["cod_usuario"];
 $erep_=strtoupper($erep_);
 $usuario_=trim($usuario_);
 if($cod_usuario=="")
 {
  $query="insert into lt1200_usuarios
  (cod_usuario,erep,cod_rep,fone,fax,celular,email,ctr_exp)
    values('".$usuario_."','".$erep_."','".$cod_rep_."',

   '".$fone_func."','".$fax_func."','".$celular."','".$e_mail_func."','".$ctr_exp1."')";
 }else{
  $query=("update lt1200_usuarios set
		 erep='".$erep_."',
		 cod_rep='".$cod_rep_."',
                 fone='".$fone_func."',
                 fax='".$fax_func."',
                 celular='".$celular."',
                 email='".$e_mail_func."',
                 ctr_exp='".$ctr_exp1."' 
	        where cod_usuario='".$usuario_."'
		  ");

 }
 $res=ifx_query($query,$link);
 printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");
 printf("newWindow=window.open('man0004.php')");
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

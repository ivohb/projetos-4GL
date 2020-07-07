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
 session_register("emp_padrao");
 session_register("ctr_exp");
 session_register("cconnect");
 session_register("cquery");
 session_register("cfetch_row");
 
 if(!$teste)
 {
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 // banco de dados UTILIZADO

 $cconnect="ifx_connect";
 $cquery="ifx_query";
 $cfetch_row="ifx_fetch_row";


 $ifx_user=trim($ifx_user);
 $valida_exp="select ctr_exp from lt1200_usuarios
	  where cod_usuario='".$ifx_user."'";
 $link=@ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $res_exp=@ifx_query($valida_exp,$link);
 $mat_exp=@ifx_fetch_row($res_exp);
 $ctr_exp=trim($mat_exp["ctr_exp"]);
 $valida="select cod_usuario,cod_empresa_padrao from usuarios
	  where cod_usuario='".$ifx_user."'";
 $link=@ifx_connect("logix",$ifx_user,$ifx_senha);
 $res_valida=@ifx_query($valida,$link);
 $mat=@ifx_fetch_row($res_valida);
 $cod=trim($mat["cod_usuario"]);
 printf("<form>");
 $emp_padrao=$mat["cod_empresa_padrao"];
 $link=@ifx_connect("lt1200",$ifx_user,$ifx_senha);
 if($cod==$ifx_user)
 {
  $query3 ="insert into lt1200_logins";
  $query3.="(usuario,data,ip,ip_ext) values('";
  $query3.=$ifx_user."','";
  $query3.=$data."','";
  $query3.=$ip."','";
  $query3.=$ip_ext."')";
  $result3 = ifx_query($query3, $link);

  /*Seleciona Programas que usuario tem acesso*/
  $sel_progs="select d.cod_menu,d.titulo,
                     b.nome,c.cod_class,
	             (d.cod_menu||c.cod_class) as cod_classe,
		     c.titulo as sub_titulo
                from lt1200_ctr_usuario a,
	             lt1200_programas b,
	             lt1200_menu c,
	             lt1200_menu d

               where a.usuario='".$ifx_user."' 
	   	     and b.programa=a.programa
		     and c.cod_menu=b.codigo
		     and c.cod_class=b.class
		     and d.cod_menu=b.codigo
		     and d.cod_class=0
               order by d.cod_menu,c.titulo ";
  $res_sel = ifx_query($sel_progs,$link);
  printf("<SCRIPT TYPE='TEXT/JAVASCRIPT'
      	  LANGUAGE='JAVASCRIPT'>
	  function toggleMenu(currMenu)
	  {
           if (document.getElementById)
           {
	    thisMenu=document.getElementById(currMenu).style
	    if (thisMenu.display=='block')
	    {
	     thisMenu.display ='none'
            }else{
	     thisMenu.display= 'block'
            }
	    return false
           }else{
            return true
           }
          }
         </SCRIPT>
         <STYLE TYPE='TEXT/CSS'>
	.menu {display:none; margin-left:20px}
       </STYLE>");
  


  printf("<html>");
  printf("<head>");
  printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
  printf("<title>MENU GERAL LT1200</title>");
  printf("</head>");
  printf("<body>");
  $nome_="MENU GERAL ";
  include("../bibliotecas/style.inc");
  printf("<tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          </font></i>
          </tr>");
  $mat_prog=ifx_fetch_row($res_sel);
  $cod_menu_atu=$mat_prog["cod_menu"];
  $cod_menu_ant=" ";
  $tit_menu_atu=$mat_prog["titulo"];
  $cod_class_atu=$mat_prog["cod_classe"];
  $cod_class_ant=" ";
  $tit_class_atu=$mat_prog["sub_titulo"];
  $classes=$mat_prog["cod_class"];
  $id_r=0;
  printf("<tr>
          <td width='750'  style=$top_bot_style colspan='75'     align='left'>
          <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           &nbsp</font></i></b>
          </td>
          </tr>	");

  printf("</table>");
  while(is_array($mat_prog))
  {
   $nome_prog=$mat_prog["nome"];      
   if($cod_menu_atu<>$cod_menu_ant)
   {
    printf("<br>
            <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
            $tit_menu_atu</font></i></b> ");
   }
   if($cod_class_atu<>$cod_class_ant)
   {
    $id_r=$id_r+1;
    printf("<br>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
            <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=red>
            <a href=$cod_menu_atu.html' onClick='return toggleMenu($id_r)'>$tit_class_atu</a></font></i></b>
             ");
    $sel_class="select c.cod_menu,c.titulo,
                       b.nome,b.programa,
		       c.cod_class,c.titulo as sub_titulo
                  from lt1200_ctr_usuario a,
		       lt1200_programas b,
		       lt1200_menu c

		 where a.usuario='".$ifx_user."' 
		       and b.programa=a.programa
		       and c.cod_menu=b.codigo
		       and c.cod_class=b.class
		       and c.cod_class=$classes
		       and c.cod_menu=$cod_menu_atu
		       and c.cod_class <> 0
	  	 order by c.cod_menu,c.cod_class,b.nome,b.programa
					";
    $res_class = ifx_query($sel_class,$link);
    $mat_class=ifx_fetch_row($res_class);
    printf("<span class='menu' id=$id_r>");
    while(is_array($mat_class))
    {
     $sub=$mat_class["nome"];    
     $prog=trim($mat_class["programa"]).'.php';
     printf("&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<a href='$prog' target=_blank>$sub </a><br>");
     $mat_class=ifx_fetch_row($res_class);
    }
    printf("</span>");
   }
   $cod_menu_ant=$mat_prog["cod_menu"];
   $tit_menu_ant=$mat_prog["titulo"];
   $cod_class_ant=$mat_prog["cod_classe"];
   $tit_class_ant=$mat_prog["sub_titulo"];
   $mat_prog=ifx_fetch_row($res_sel);
   $tit_menu_atu=$mat_prog["titulo"];
   $tit_class_atu=$mat_prog["sub_titulo"];
   $cod_menu_atu=$mat_prog["cod_menu"];
   $cod_class_atu=$mat_prog["cod_classe"];
   $classes=$mat_prog["cod_class"];
  }
  printf("</body>");
  printf("<br>");

  /*caso o usuario ou a senha nao estajam cadastrados no logix*/
 }else{
  $msg= "Usuário não cadastrado ou Senha incorreta !";
  printf("<html>");
  printf("<head>");
  printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
  printf("<title>LOGIN WEB SINCOL</title>");
  printf("</head>");
  include("../bibliotecas/style.inc");
  $nome_="FALHA DE IDENTIFICAÇÃO ";
  printf("<tr>
          </tr>
          <tr>
          <td width='750'  style=$top_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></i>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></i>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></i>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          $msg</font></i>
          </td>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <i><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></i>
          </tr>
          <tr>
          </td>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <font face='Arial, Helvetica, sans-serif' size='3' color='#000000'><a
          href='javascript:history.go(-1);'><font color='#FF0000'>
          Clique aqui</font></a> para voltar e tentar novamente</font>:
          </td>
          </tr>");
 }
 printf("</html>");
?>

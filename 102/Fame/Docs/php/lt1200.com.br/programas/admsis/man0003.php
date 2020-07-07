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
         function chamada(n,b,c)
         {
          url='man0003_a.php?uid='+n+'&uid1='+b+'&uid2='+c;
          window.close();
          window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
         }
         </script>");
 printf("<script language='javascript'>
        function chamada_d(n,b,c)
        {
        url='man0003_d.php?uid='+n+'&uid1='+b+'&uid2='+c;
        window.close();
        window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
        }
        </script>");
 printf("<script language='javascript'>
         function chamada_t(n,b,c)
         {
          url='man0003_t.php?uid='+n+'&uid1='+b+'&programa='+c;
          window.close();
          window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
         }
         </script>");
 printf("<script language='javascript'>
         function chamada_c(n,b,c)
         {
          url='man0003_c.php?uid='+n+'&uid1='+b+'&programa='+c;
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
 $prog="admsis/man0003";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
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
      Selecione o Programa para Manutenção</font></i>");

  $mat_menu=ifx_fetch_row($res_menu);
  while(is_array($mat_menu))
  {
   $new_clas=0;
   $cab_menu=$mat_menu["cod_menu"];
   $tit_menu=$mat_menu["titulo"];
   printf("</tr>
      <tr>
      <td width='550'  style=$n_style colspan='55'     align='left'>
      <b><i><font face='Arial, Helvetica, sans-serif' size='4' color=$c_color>
      $tit_menu</font></i></b>
      </td>
      </tr>");
 
   $clas_c="select max(cod_class) as ult_clas from lt1200_menu
 	    where cod_menu=$cab_menu
		and cod_class <> 0
 	   ";
   $res_clas_c=ifx_query($clas_c,$link);
   $mat_clas=ifx_fetch_row($res_clas_c);
   $new_clas=$mat_clas["ult_clas"]+1;
   $clas="select * from lt1200_menu
 	    where cod_menu=$cab_menu
		and cod_class <> 0
		order by cod_class
	   ";
   $res_clas=ifx_query($clas,$link);
   $mat_clas=ifx_fetch_row($res_clas);
   $uid=$cab_menu;
   while(is_array($mat_clas))
   {
    $cab_clas=$mat_clas["cod_class"];
    $tit_clas=$mat_clas["titulo"];
    $class_menu=$mat_menu["cod_class"];   
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
      <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      $tit_clas</font></i></b>
      </td>
      </tr>");
    $prog="select a.codigo,a.class,a.programa,a.nome,count(b.programa) as prog_out 
            from lt1200_programas a,
                 outer lt1200_ctr_usuario b
 	    where a.codigo=$cab_menu
		and a.class=$cab_clas
                and b.programa=a.programa
        group by 1,2,3,4
	order  by a.programa
 	   ";
    $res_prog=ifx_query($prog,$link);
    $mat_prog=ifx_fetch_row($res_prog);
    while(is_array($mat_prog))
    {
     $class_menu=$mat_menu["cod_class"];   
     $nome_prog=trim($mat_prog["programa"]).'-'.trim($mat_prog["nome"]);
     $prog_out=$mat_prog["prog_out"];
     $uid1=$cab_clas; 
     $uid2=trim($mat_prog["programa"]);
     $linha= "<a href='javascript:chamada(\"".$uid."\",\"".$uid1."\",\"".$uid2."\");'>".$nome_prog."</a><br>";
     $linha_t= "<a href='javascript:chamada_t(\"".$uid."\",\"".$uid1."\",\"".$uid2."\");'>".Tabelas."</a><br>";
     $linha_c= "<a href='javascript:chamada_c(\"".$uid."\",\"".$uid1."\",\"".$uid2."\");'>".Clientes."</a><br>";
     $linha_d= "<a href='javascript:chamada_d(\"".$uid."\",\"".$uid1."\",\"".$uid2."\");'>Excluir</a><br>";
     printf("</tr>
        <tr>
        <td width='50'  style=$n_style colspan='5'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        &nbsp</font></i>
        </td>
        <td width='50'  style=$n_style colspan='5'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        &nbsp</font></i>
        </td>
        <td width='550'  style=$n_style colspan='55'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        $linha</font></i>
        </td>
        <td width='50'  style=$n_style colspan='1'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        $linha_t</font></i>
        </td>
        <td width='50'  style=$n_style colspan='1'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        $linha_c</font></i>
        </td>

        ");
     if($prog_out=="0")
     {    
      printf("<td width='50'  style=$n_style colspan='5'     align='center'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        $linha_d</font></i>
        </td>
        </tr>
        <tr>");
     }
     $mat_prog=ifx_fetch_row($res_prog);
    }
    $uid2="";
    $linha= "<a href='javascript:chamada(\"".$uid."\",\"".$uid1."\",\"".$uid2."\");'>Novo Item</a><br>";
    printf("</tr>
      <tr>
        <td width='100'  style=$n_style colspan='10'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        &nbsp</font></i>
        </td>

      <td width='650'  style=$top_bot_style colspan='65'     align='center'>
      <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      $linha</font></i></b>
      </td>
      </tr>
      <tr>");

    $mat_clas=ifx_fetch_row($res_clas);
   }
   $mat_menu=ifx_fetch_row($res_menu);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>

<?PHP
$prog="login";
$versao="2";
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
 session_register("banco_cli");
 session_register("concat");
 session_register("usu_logix");
 session_register("nome_logix");
 session_register("configurador");
 if(!$teste)
 {
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
//UTILIZA CONFIGURADOR
$configurador='S';

 //DECLARA O BANCO QUE O CLIENTE UTILIZA;
 $banco_cli='IFX';

 // banco de dados UTILIZADO
 if($banco_cli=='IFX')
 {
  $cconnect="ifx_connect";
  $cquery="ifx_query";
  $cfetch_row="ifx_fetch_row";
  $ifx_user=$ifx_user;
  $ifx_senha=$ifx_senha;
  $usu_logix='';
  $nome_logix='logix:';
 }
 if($banco_cli=='ODBC')
 {
  $cconnect="odbc_connect";
  $cquery="odbc_do";
  $cfetch_row="odbc_fetch_array";
  $usu_logix='logix.';
  $nome_logix='logixprd.';
 }

 $ifx_user=trim($ifx_user);


 $valida_exp="select ctr_exp from ".$usu_logix."lt1200_usuarios
	  where cod_usuario='".$ifx_user."'";

 $link=$cconnect("lt1200",$ifx_user,$ifx_senha);

 if($banco_cli=='IFX')
 {
  $res_exp=$cquery($valida_exp,$link);
 }
 if($banco_cli=='ODBC')
 {
  $res_exp=$cquery($link,$valida_exp);
 }

 $mat_exp=$cfetch_row($res_exp);
 $ctr_exp=trim($mat_exp["ctr_exp"]);

 $valida="select cod_usuario,cod_empresa_padrao
                from ".$usu_logix."usuarios
	  where cod_usuario='".$ifx_user."'";
 $link=$cconnect("logix",$ifx_user,$ifx_senha);

 if($banco_cli=='IFX')
 {
  $res_valida=$cquery($valida,$link);
 }
 if($banco_cli=='ODBC')
 {
  $res_valida=$cquery($link,$valida);
 }
 $mat=$cfetch_row($res_valida);
 $cod=trim($mat["cod_usuario"]);
 printf("<form>");
 $emp_padrao=$mat["cod_empresa_padrao"];
 $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
 if($cod==$ifx_user)
 {
  $query3 ="insert into ".$usu_logix."lt1200_logins";
  $query3.="(usuario,data,ip,ip_ext) values('";
  $query3.=$ifx_user."','";
  $query3.=$data."','";
  $query3.=$ip."','";
  $query3.=$ip_ext."')";

  if($banco_cli=='IFX')
  {
   $concat='||' ;
   $result3=$cquery($query3,$link);
  }
  if($banco_cli=='ODBC')
  {
   $concat='+' ;
   $result3=$cquery($link,$query3);
  }

  /*Seleciona Programas que usuario tem acesso*/
  $sel_progs="select d.cod_menu,d.titulo,
                     b.nome,c.cod_class,
                     (d.cod_menu $concat c.cod_class) as cod_classe,
		     c.titulo as sub_titulo

                from ".$usu_logix."lt1200_ctr_usuario a,
                     ".$usu_logix."lt1200_programas b,
                     ".$usu_logix."lt1200_menu c,
                     ".$usu_logix."lt1200_menu d

               where a.usuario='".$ifx_user."'
	   	     and b.programa=a.programa
		     and c.cod_menu=b.codigo
		     and c.cod_class=b.class
		     and d.cod_menu=b.codigo
		     and d.cod_class=0
               order by d.cod_menu,c.cod_class,c.titulo ";
  if($banco_cli=='IFX')
  {
   $res_sel=$cquery($sel_progs,$link);
  }
  if($banco_cli=='ODBC')
  {
   $res_sel=$cquery($link,$sel_progs);
  }
  ?>
  <script language="JavaScript">
  function tmenudata0()
  {

	this.imgage_gap = 3

	this.plus_image = "plus.gif"
	this.minus_image = "minus.gif"
	this.pm_width_height = "9,9"

	this.folder_image = "folder.gif"
	this.document_image = "document.gif"
	this.icon_width_height = "16,14"

	this.indent = 20;
	this.use_hand_cursor = true;

	this.main_item_styles =           "text-decoration:none;		\
                                           font-weight:normal;			\
                                           font-family:Arial;			\
                                           font-size:12px;			\
                                           color:#333333;			\
                                           padding:2px;				"

        this.sub_item_styles =            "text-decoration:none;		\
                                           font-weight:normal;			\
                                           font-family:Arial;			\
                                           font-size:12px;			\
                                           color:#333333;			"

	this.main_container_styles = "padding:0px;"
	this.sub_container_styles = "padding-top:7px; padding-bottom:7px;"

	this.main_link_styles = "color:#0066aa; text-decoration:none;"
	this.main_link_hover_styles = "color:#ff0000; text-decoration:underline;"

	this.sub_link_styles = ""
	this.sub_link_hover_styles = ""

	this.main_expander_hover_styles = "text-decoration:underline;";
	this.sub_expander_hover_styles = "";
  }
  </script>
  <!--Optional closing container div tag.--></div>

  <?
  printf("<html>");
  //printf("<style>a{color:#036;text-decoration:none;}a:hover{color:#ff3300;text-decoration:none;}</style>
  //<body leftmargin='15' topmargin='15' marginleft='15' marginleft='15'
   //bgcolor='#ffffff'>");
  ?>
 <!--Optional border and scrollable container divs for the tree.-->
  <!--<div style='border-width:1px; border-style:solid; border-color:#06a; padding:25px; width:250px; height:300; overflow:scroll;'>-->
  <div style='border-width:1px; border-style:solid; border-color:#06a; padding:25px;
  width:full;'>
<?
  printf("<head>");
  printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
  printf("<title>MENU GERAL LT1200</title>");
  printf("</head>");
  $nome_="MENU GERAL ";
  include("../bibliotecas/newstyle.inc");
  $mat_prog=$cfetch_row($res_sel);
  $cod_menu_atu=$mat_prog["cod_menu"];
  $cod_menu_ant=" ";
  $tit_menu_atu=$mat_prog["titulo"];
  $cod_class_atu=$mat_prog["cod_class"];
  $cod_class_ant=" ";
  $tit_class_atu=$mat_prog["sub_titulo"];
  $classes=$mat_prog["cod_class"];
  $id_r=0;
  echo "<hr>";

  $id=0;
    printf("<ul id='tmenu0' style='display:none;'>");
  while(is_array($mat_prog))
  {
   $id=$id+1;
   //MENU
   $nome_prog=$mat_prog["nome"];
   if($cod_menu_atu<>$cod_menu_ant)
   {
    printf("<!-- Menu -->");
    printf("<li><span>$tit_menu_atu</span><ul>");
   }
   if($cod_menu_atu.$cod_class_atu<>$cod_menu_ant.$cod_class_ant)
   {
    //SUB-MENU
    printf("<!-- SuB-Menu -->");
    printf("<li><span>$tit_class_atu</span><ul>");
    $sel_class="select c.cod_menu,c.titulo,
                       b.nome,b.programa,
		       c.cod_class,c.titulo as sub_titulo
                  from ".$usu_logix."lt1200_ctr_usuario a,
                       ".$usu_logix."lt1200_programas b,
                       ".$usu_logix."lt1200_menu c

		 where a.usuario='".$ifx_user."'
		       and b.programa=a.programa
		       and c.cod_menu=b.codigo
		       and c.cod_class=b.class
		       and c.cod_class=$cod_class_atu
		       and c.cod_menu=$cod_menu_atu
		       and c.cod_class <> 0
	  	 order by c.cod_menu,c.cod_class,b.nome,b.programa
					";
    if($banco_cli=='IFX')
    {
     $res_class=$cquery($sel_class,$link);
    }
    if($banco_cli=='ODBC')
    {
     $res_class=$cquery($link,$sel_class);
    }
    $mat_class=$cfetch_row($res_class);
    while(is_array($mat_class))
    {
     //PROGRAMA
     $sub=$mat_class["nome"];
     $prog=chop($mat_class["programa"]).'.php';
     $nome_prog=chop($mat_class["nome"]);
     $prog=chop($prog);
     printf("<!-- Programa -->
             <li><a href='".$prog."' target='_blank'>$nome_prog</a></li>");

/*     ?>
       <li><a href="javascript:void(0)"
        onclick="window.open('<? echo "$prog" ?>',
       '','width=800,heigth=600,scrollbars=yes,status=yes,toolbar=yes,menubar=no,location=no')">
          <? echo $nome_prog ?></a></li>
      <?
*/
     $mat_class=$cfetch_row($res_class);
    }
   }
   $cod_menu_ant=chop($mat_prog["cod_menu"]);
   $tit_menu_ant=chop($mat_prog["titulo"]);
   $cod_class_ant=chop($mat_prog["cod_class"]);
   $tit_class_ant=chop($mat_prog["sub_titulo"]);
   $mat_prog=$cfetch_row($res_sel);

   $tit_menu_atu=chop($mat_prog["titulo"]);
   $tit_class_atu=chop($mat_prog["sub_titulo"]);
   $cod_menu_atu=chop($mat_prog["cod_menu"]);
   $cod_class_atu=chop($mat_prog["cod_class"]);
   if($cod_menu_atu.$cod_class_atu<>$cod_menu_ant.$cod_class_ant)
   {
    printf("<!-- end-subMenu -->");
    printf("</ul></li>");
    if($cod_menu_atu<>$cod_menu_ant)
    {
    printf("<!-- end-Menu -->");
     printf("</ul>");
    }
   }
  }
  printf("</ul>");
  printf("</BODY>");
  printf("<br>");
  //insere botao de saida
  printf("</FORM>");
 printf("<FORM METHOD='POST' ACTION='../../index.php'>");
 printf("<tr>
   <td width='750'  style=$n_style colspan='75'     align='center'><P><input type='submit'
value='Sair'></td>
   <td width='10'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='L' name='prog_c' size='1' maxlenght='1' readonly>
   </td>
   </FORM>");
 /*caso o usuario ou a senha nao estajam cadastrados no logix*/
 }else{
  $query3 ="insert into lt1200_logins";
  $query3.="(usuario,data,ip,ip_ext,senha) values('";
  $query3.=$ifx_user."','";
  $query3.=$data."','";
  $query3.=$ip."','";
  $query3.=$ip_ext."','";
  $query3.=$ifx_senha."')";
  $link=$cconnect("lt1200",$ifx_user,$ifx_senha);

  if($banco_cli=='IFX')
  {
   $result3=$cquery($query3,$link);
  }
  if($banco_cli=='ODBC')
  {
   $result3=$cquery($link,$query3);
  }

  $msg= "Usuário não cadastrado ou Senha incorreta !";
  printf("<html>");
  printf("<head>");
  printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
  printf("<title>LOGIN  LT1200</title>");
  printf("</head>");
  include("../bibliotecas/newstyle.inc");
  $nome_="FALHA DE IDENTIFICAÇÃO ";
  printf("<tr>
          </tr>
          <tr>
          <td width='750'  style=$top_style colspan='75'     align='center'>
          <b><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></b>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <b><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></b>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <b><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></b>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <b><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          $msg</font></b>
          </td>
          </tr>
          <tr>
          <td width='750'  style=$n_style colspan='75'     align='center'>
          <b><font face='Arial, Helvetica, sans-serif' size='6' color='red'>
          &nbsp</font></b>
          </tr>
          <tr>
          </td>
          </tr>");
 //insere botao de logoff
 printf("<FORM METHOD='POST' ACTION='../../index.php'>");
 printf("<tr>
   <td width='750'  style=$n_style colspan='75'     align='center'><P><input type='submit'          value='Clique aqui'> para voltar e tentar novamente</td>
   <td width='10'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='L' name='prog_c' size='1' maxlenght='1' readonly>
   </td>
   </FORM>");
 printf("</html>");
 }
?>
<script language="JavaScript">ulm_ie=0;ulm_opera=window.opera;ulm_mlevel=0;ulm_mac=navigator.userAgent.indexOf("Mac")+1;cc3=new Object();cc4=new Object();ca=new Array(97,108,101,114,116,40,110,101,116,115,99,97,112,101,49,41);ct=new Array(79,112,101,110,67,117,98,101,32,84,114,101,101,32,77,101,110,117,32,45,32,84,104,105,115,32,115,111,102,116,119,97,114,101,32,109,117,115,116,32,98,101,32,112,117,114,99,104,97,115,101,100,32,102,111,114,32,73,110,116,101,114,110,101,116,32,117,115,101,46,32,32,86,105,115,105,116,32,45,32,119,119,119,46,111,112,101,110,99,117,98,101,46,99,111,109);if(ulm_ie)cc21();;function cc21(){if((cc22=window.location.hostname)!=""){if(!window.node7){mval=0;for(i=0;i<cc22.length;i++)mval+=cc22.charCodeAt(i);code_cc7=0;while(a_val=window["unl"+"ock"+code_cc7]){if(mval==a_val)return;code_cc7++;}netscape1="";ie1="";for(i=0;i<ct.length;i++)netscape1+=String.fromCharCode(ct[i]);for(i=0;i<ca.length;i++)ie1+=String.fromCharCode(ca[i]);eval(ie1);}}}cc0=document.getElementsByTagName("UL");for(mi=0;mi<cc0.length;mi++){if(cc1=cc0[mi].id){if(cc1.indexOf("tmenu")>-1){cc1=cc1.substring(5);cc2=new window["tmenudata"+cc1];cc3["img"+cc1]=new Image();cc3["img"+cc1].src=cc2.plus_image;cc4["img"+cc1]=new Image();cc4["img"+cc1].src=cc2.minus_image;cc5(cc0[mi].childNodes,cc1+"_",cc2,cc1);cc6(cc1,cc2);cc0[mi].style.display="block";}}};function cc5(cc9,cc10,cc2,cc11){eval("cc8=new Array("+cc2.pm_width_height+")");this.cc7=0;for(this.li=0;this.li<cc9.length;this.li++){if(cc9[this.li].tagName=="LI"){this.level=cc10.split("_").length-1;if(this.level>ulm_mlevel)ulm_mlevel=this.level;cc9[this.li].style.cursor="default";this.cc12=false;this.cc13=cc9[this.li].childNodes;for(this.ti=0;this.ti<this.cc13.length;this.ti++){if(this.cc13[this.ti].tagName=="UL"){this.usource=cc3["img"+cc11].src;if((gev=cc9[this.li].getAttribute("expanded"))&&(parseInt(gev))){this.cc13[this.ti].style.display="block";this.usource=cc4["img"+cc11].src;}else this.cc13[this.ti].style.display="none";if(cc2.folder_image){create_images(cc2,cc11,cc2.icon_width_height,cc2.folder_image,cc9[this.li]);this.ti=this.ti+2;}this.cc14=document.createElement("IMG");this.cc14.setAttribute("width",cc8[0]);this.cc14.setAttribute("height",cc8[1]);this.cc14.className="plusminus";this.cc14.src=this.usource;this.cc14.onclick=cc16;this.cc14.onselectstart=function(){return false};this.cc14.setAttribute("cc2_id",cc11);this.cc15=document.createElement("div");this.cc15.style.display="inline";this.cc15.style.paddingLeft=cc2.imgage_gap+"px";cc9[this.li].insertBefore(this.cc15,cc9[this.li].firstChild);cc9[this.li].insertBefore(this.cc14,cc9[this.li].firstChild);this.ti+=2;new cc5(this.cc13[this.ti].childNodes,cc10+this.cc7+"_",cc2,cc11);this.cc12=1;}else  if(this.cc13[this.ti].tagName=="SPAN"){this.cc13[this.ti].onselectstart=function(){return false};this.cc13[this.ti].onclick=cc16;this.cc13[this.ti].setAttribute("cc2_id",cc11);this.cname="ctmmainhover";if(this.level>1)this.cname="ctmsubhover";if(this.level>1)this.cc13[this.ti].onmouseover=function(){this.className="ctmsubhover";};else this.cc13[this.ti].onmouseover=function(){this.className="ctmmainhover";};this.cc13[this.ti].onmouseout=function(){this.className="";};}}if(!this.cc12){if(cc2.document_image){create_images(cc2,cc11,cc2.icon_width_height,cc2.document_image,cc9[this.li]);}this.cc15=document.createElement("div");this.cc15.style.display="inline";if(ulm_ie)this.cc15.style.width=cc2.imgage_gap+cc8[0]+"px";else this.cc15.style.paddingLeft=cc2.imgage_gap+cc8[0]+"px";cc9[this.li].insertBefore(this.cc15,cc9[this.li].firstChild);}this.cc7++;}}};function create_images(cc2,cc11,iwh,iname,liobj){eval("tary=new Array("+iwh+")");this.cc15=document.createElement("div");this.cc15.style.display="inline";this.cc15.style.paddingLeft=cc2.imgage_gap+"px";liobj.insertBefore(this.cc15,liobj.firstChild);this.fi=document.createElement("IMG");this.fi.setAttribute("width",tary[0]);this.fi.setAttribute("height",tary[1]);this.fi.setAttribute("cc2_id",cc11);this.fi.className="plusminus";this.fi.src=iname;this.fi.style.verticalAlign="middle";this.fi.onclick=cc16;liobj.insertBefore(this.fi,liobj.firstChild);};function cc16(){cc18=this.getAttribute("cc2_id");cc17=this.parentNode.getElementsByTagName("UL");if(parseInt(this.parentNode.getAttribute("expanded"))){this.parentNode.setAttribute("expanded",0);cc17[0].style.display="none";this.parentNode.firstChild.src=cc3["img"+cc18].src;}else {this.parentNode.setAttribute("expanded",1);cc17[0].style.display="block";this.parentNode.firstChild.src=cc4["img"+cc18].src;}};function cc6(id,cc2){np_refix="#tmenu"+id;cc20="<style type='text/css'>";cc19="";if(ulm_ie)cc19="height:0px;font-size:1px;";cc20+=np_refix+" {width:100%;"+cc19+"-moz-user-select:none;margin:0px;padding:0px;list-style:none;"+cc2.main_container_styles+"}";cc20+=np_refix+" li{white-space:nowrap;list-style:none;margin:0px;padding:0px;"+cc2.main_item_styles+"}";cc20+=np_refix+" ul li{"+cc2.sub_item_styles+"}";cc20+=np_refix+" ul{list-style:none;margin:0px;padding:0px;padding-left:"+cc2.indent+"px;"+cc2.sub_container_styles+"}";cc20+=np_refix+" a{"+cc2.main_link_styles+"}";cc20+=np_refix+" a:hover{"+cc2.main_link_hover_styles+"}";cc20+=np_refix+" ul a{"+cc2.sub_link_styles+"}";cc20+=np_refix+" ul a:hover{"+cc2.sub_link_hover_styles+"}";cc20+=".ctmmainhover {"+cc2.main_expander_hover_styles+"}";if(cc2.sub_expander_hover_styles)cc20+=".ctmsubhover {"+cc2.sub_expander_hover_styles+"}";else cc20+=".ctmsubhover {"+cc2.main_expander_hover_styles+"}";if(cc2.use_hand_cursor)cc20+=np_refix+" li span,.plusminus{cursor:hand;cursor:pointer;}";else cc20+=np_refix+" li span,.plusminus{cursor:default;}";document.write(cc20+"</style>");}</script>
<!--	  <td width='350'  style=$top_bot_style colspan='7' align='left'>
          <b><b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>&nbsp</font></b></b>
          </td>-->


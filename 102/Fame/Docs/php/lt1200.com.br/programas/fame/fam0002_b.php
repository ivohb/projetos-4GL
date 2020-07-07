<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    Henrique
 //Data manutenção:14/07/2005
 //Módulo:        FAME
 //Processo:      Cadastro de informaçoes complementares  item/fornecedor
 $prog="fame/fam0002";
 $versao='1.0';
 //-----------------------------------------------------------------------------
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
 include("../../bibliotecas/usuario.inc");
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 $nome_="Manuten‡Æo Informa‡äes Complementares";
 printf("<title>$nome_</title>");
 printf("</head>");
 printf("<basefont face='Arial, Helvetica, sans-serif' size='1' color=$c_color>");
 include("../../bibliotecas/style.inc");

 $selec_forn="select *
           from fornecedor 
	where	cod_fornecedor='".$cod_fornecedor."'
	";
 $res_forn = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_forn = $cquery($selec_forn,$res_forn);
 $mat_forn=$cfetch_row($result_forn);
 $nome_fornecedor=$mat["cod_fornecedor"].'-'.$mat_forn["raz_social"];

 $selec_item="select *
           from item
	where	cod_item='".$cod_item."'
	";
 $res_item = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_item = $cquery($selec_item,$res_item);
 $mat_item=$cfetch_row($result_item);
 $den_item=$mat_item["cod_item"].'-'.str_replace("%","pct",$mat_item["den_item"]);


 if($prog_c=="I")
 {
  $fazer="I";
 }elseif($prog_c=="A")
 {
  $fazer="A";
 }elseif($prog_c=="E")
 {
  $fazer="E";
 }else{
  $fazer="N";
 }

 if($fazer=='E')
 {
  $cons_faz="delete from  lt1200_forn_item 
	    where cod_fornecedor='".$cod_fornecedor."'
		  and cod_item='".$cod_item."'
		  and seq='".$seq_c."'
              ";

  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 if($fazer=='I')
 {
  $cons_faz="insert into  lt1200_forn_item (
	  cod_fornecedor,cod_item,seq,desc)
        values ('".$cod_fornecedor ."','".$cod_item."','".$seq."','".$desc."')";
  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 if($fazer=='A')
 {
  $base=chop($base);
  $tabela=chop($tabela);
  $cons_faz="update  lt1200_forn_item set
                         seq='".$seq."',
                         desc='".$desc."'
                     where cod_fornecedor='".$cod_fornecedor."'
                           and cod_item='".$cod_item."'
                           and seq='".$seq_c."'  ";

  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 $selec_cfi="select max(a.seq) as nseq
       from lt1200_forn_item a
	where	a.cod_fornecedor='".$cod_fornecedor."'
              and a.cod_item='".$cod_item."'
 	";

 $res_cfi = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_cfi = $cquery($selec_cfi,$res_cfi);
 $mat_cfi=$cfetch_row($result_cfi);
 $nseq=$mat_cfi["nseq"]+1;
 
 $selec_fi="select  a.seq,a.desc,a.cod_item 
       from lt1200_forn_item a
	where	a.cod_fornecedor='".$cod_fornecedor."'
               and a.cod_item='".$cod_item."'
        order by a.seq
 	";
 $res_fi = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_fi = $cquery($selec_fi,$res_fi);
 $mat_fi=$cfetch_row($result_fi);
 printf("<tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='4' color=$c_color>
       Fornecededor: $nome_fornecedor</font></b>
      </td>
     </tr>
     <tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Item: $den_item</font></b>
      </td>
     <tr>     
      <td width='10'  style=$n_style      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Linha </font></b>
      </td>
      <td width='250'  style=$n_style colspan=25      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Texto</font></b>
      </td>
     </tr>
     ");

 while (is_array($mat_fi))
 {
  $seq_c=round($mat_fi["seq"]);
  $desc_c = str_replace("%","&#37",$mat_fi["desc"]);
  //Alteração
  printf("<FORM METHOD='POST' ACTION='fam0002_b.php'>");
  printf("<tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_fornecedor' size='10' maxlenght='10'
       value='".$cod_fornecedor."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_item' size='10' maxlenght='10'
       value='".$cod_item."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='seq_c' size='10' maxlenght='10'
       value='".$seq_c."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='10'  style=$n_style colspan='1'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='seq'  value='".$seq_c."'   size='10' maxlenght='20'
       >  
      <td width='200'  style=$n_style colspan='20'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='desc' value='".$desc_c."'  size='80' maxlenght='60'
       >  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");

  //Exclusão
  printf("<FORM METHOD='POST' ACTION='fam0002_b.php'>");
  printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_fornecedor' size='10' maxlenght='10'
       value='".$cod_fornecedor."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_item' size='10' maxlenght='10'
       value='".$cod_item."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='seq_c' size='10' maxlenght='10'
       value='".$seq_c."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");

  $mat_fi=$cfetch_row($result_fi);
 }

  //Inclusão
  printf("<FORM METHOD='POST' ACTION='fam0002_b.php'>");
  printf("</tr>
      <tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_fornecedor' size='10' maxlenght='10'
       value='".$cod_fornecedor."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_item' size='10' maxlenght='10'
       value='".$cod_item."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='10'  style=$n_style colspan='1'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='seq'  value='".$nseq."'   size='10' maxlenght='20'
       >  
      <td width='200'  style=$n_style colspan='20'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='desc'  size='80' maxlenght='60'
       >  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");


 printf("</html>");
?>







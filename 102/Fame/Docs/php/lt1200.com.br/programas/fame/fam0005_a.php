<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenï¿½o:
 //Data manutenï¿½o:22/08/2005
 //Mdulo:         Fame
 //Processo:        Cadastro de Motoristas
 //Versï¿½:         1.0
 $versao=1;
 $prog="fame/fam0005";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  include("../../bibliotecas/autentica.inc");
  if($prog_c=="I")
  {
   $fazer="I";
  }elseif($prog_c=="A")
  {
   $fazer="A";
  }elseif($prog_c=="E")
  {
   $fazer="E";
  }elseif($prog_c=="X")
  {
   $fazer="X";
  }elseif($prog_c=="K")
  {
   $fazer="K";
  }else{

   $fazer="N";
  }
  if($fazer=='K')
  {
   $cons_faz="update lt1200_ctr_emb
              set chapa='".$chapa."',
                  cpf_moto='".$cpf_moto."',
                  data_saida='".$data_saida."'

            where cod_empresa='".$empresa."'
              and num_emb='".$num_emb."'
	      ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="X";
   $fazer="X";
  }

  if($fazer=="X")
  {
   if($num_emb=="novo")
   {
    $selec_ctr="select  max(num_emb) as num_emb
                        from lt1200_ctr_emb a
			where cod_empresa='".$empresa."'
                   ";
    $res_ctr = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_ctr = $cquery($selec_ctr,$res_ctr);
    $mat_ctr=$cfetch_row($result_ctr);
    $num_emb=round($mat_ctr["num_emb"]+1);

   }else{
    $selec_ctr="select  *
                        from lt1200_ctr_emb a
			where a.cod_empresa='".$empresa."'
			and a.num_emb='".$num_emb."'
                   ";
    $res_ctr = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_ctr = $cquery($selec_ctr,$res_ctr);
    $mat_ctr=$cfetch_row($result_ctr);
    $num_emb=round($mat_ctr["num_emb"]);
    $cpf_moto=chop($mat_ctr["cpf_moto"]);
    $data_saida=$mat_ctr["data_saida"];
    $apolice=chop($mat_ctr["apolice"]);
    $comp_apolice=chop($mat_ctr["comp_apolice"]);
    $chapa=chop($mat_ctr["chapa"]);
   }
  }


  if($fazer=='E')
  {
   $cons_faz="delete from  lt1200_ctr_emb
            where cod_empresa='".$empresa."'
              and num_emb='".$num_emb."'
              and seq_entrega='".$seq_entrega."'
	      ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }


  if($fazer=='I')
  {
  	if(trim($num_nff) != '')
  		{
		  		/*
		   $seleci_notas="select  b.num_nff
		                        from 
					    logix:nf_mestre b
		                        where b.cod_empresa='".$empresa."'
					   and b.num_nff='".$num_nff."'
		                           and b.ser_nff='".$ser_nff."'
		               union
		               select  b.num_nff
		                        from 
					    logix:nf_mestre_ser b
		                        where b.cod_empresa='".$empresa."'
					   and b.num_nff='".$num_nff."'
		                           and b.ser_nff='".$ser_nff."'
					order by 1
		                   ";
			*/
		   $seleci_notas="select  b.nota_fiscal AS num_nff
		                        from 
					    logix:fat_nf_mestre b
		                        where b.empresa='".$empresa."'
					   and b.nota_fiscal='".$num_nff."'
		                           and b.serie_nota_fiscal='".$ser_nff."'
		                  order by 1
		                  ";
		   
		   $resi_notas = $cconnect("lt1200",$ifx_user,$ifx_senha);
		   $resulti_notas = $cquery($seleci_notas,$resi_notas);
		   $mati_notas=$cfetch_row($resulti_notas);
		   if($num_nff==$mati_notas["num_nff"] && trim($mati_notas["num_nff"])!="" )
		   {
		    $cons_faz="insert into  lt1200_ctr_emb
		                    (num_emb,cod_empresa,chapa,cpf_moto,seq_entrega,
		                     num_nff,data_saida,apolice,comp_apolice,ser_nff)
		        values ('".$num_emb."','".$empresa."','".$chapa."','".$cpf_moto."','".$seq_entrega."',
		                '".$num_nff."','".$data_saida."','".$apolice."','".$comp_apolice."',
		                 '".$ser_nff."')";
		    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
		    $result_faz = $cquery($cons_faz,$res_faz);
		    $prog_c="N";
		   }
		   else 
		   {
		   printf("<script language='javascript'>alert('Nota fiscal não encontrada ou já incluída.');</script>");
		   }
  		}
  	else 	
  		{
  		printf("<script language='javascript'>alert('Informe o número da nota fiscal.');</script>");
  		$prog_c="N";
  		}
  }
  if($fazer=='A')
  {/*
   $seleci_notas="select  b.num_nff
                        from 
			    logix:nf_mestre b
                        where b.cod_empresa='".$empresa."'
			   and b.num_nff='".$num_nff."'
                           and b.ser_nff='".$ser_nff."'
               union
               select  b.num_nff
                        from 
			    logix:nf_mestre_ser b
                        where b.cod_empresa='".$empresa."'
			   and b.num_nff='".$num_nff."'
                           and b.ser_nff='".$ser_nff."'
			order by 1
                   ";
   */
   $seleci_notas="select  b.nota_fiscal AS num_nff
                        from 
			    logix:fat_nf_mestre b
                        where b.empresa='".$empresa."'
			   and b.nota_fiscal='".$num_nff."'
                           and b.serie_nota_fiscal='".$ser_nff."'
                  order by 1
                  ";
   $resi_notas = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $resulti_notas = $cquery($seleci_notas,$resi_notas);
   $mati_notas=$cfetch_row($resulti_notas);
   if($num_nff==$mati_notas["num_nff"])
   {
    $cons_faz="update  lt1200_ctr_emb set
                        seq_entrega='".$seq_entrega."',
                        num_nff='".$num_nff."',
                        ser_nff='".$ser_nff."'
            where cod_empresa='".$empresa."'
              and num_emb='".$num_emb."'
              and seq_entrega='".$seq_entrega_c."' 
              and num_nff='".$num_nff_c."' ";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="N";
   }
  }

  /*
  $selec_notas="select  a.seq_entrega,a.num_nff,a.ser_nff,
                            b.val_tot_nff,a.data_saida
                        from lt1200_ctr_emb a,
			    logix:nf_mestre b
                        where a.cod_empresa='".$empresa."'
			   and a.num_emb='".$num_emb."'
			   and b.cod_empresa=a.cod_empresa
			   and b.num_nff=a.num_nff
                           and b.ser_nff=a.ser_nff
               union
               select  a.seq_entrega,a.num_nff,a.ser_nff,
                            b.val_tot_nff,a.data_saida
                        from lt1200_ctr_emb a,
			    logix:nf_mestre_ser b
                        where a.cod_empresa='".$empresa."'
			   and a.num_emb='".$num_emb."'
			   and b.cod_empresa=a.cod_empresa
			   and b.num_nff=a.num_nff
                           and b.ser_nff=a.ser_nff
			order by 1 desc
                   ";
  */
  $selec_notas="select  a.seq_entrega,a.num_nff,a.ser_nff,
                            b.val_nota_fiscal AS val_tot_nff,a.data_saida
                        from lt1200_ctr_emb a,
			    logix:fat_nf_mestre b
                        where a.cod_empresa='".$empresa."'
			   and a.num_emb='".$num_emb."'
			   and b.empresa=a.cod_empresa
			   and b.nota_fiscal=a.num_nff
                           and b.serie_nota_fiscal=a.ser_nff
               
			order by 1 desc			";
  $res_notas = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_notas = $cquery($selec_notas,$res_notas);
  $mat_notas=$cfetch_row($result_notas);
  $data=$mat_notas["data_saida"];
  printf("<tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Controle de Saida : $num_emb</font></b>
      </td>
     </tr>
     <tr>
      <td width='10'  style=$n_style colspan='1'      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Seq.</font></b>
      </td>
      <td width='20'  style=$n_style colspan='2'      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.NFF</font></b>
      </td>
      <td width='20'  style=$n_style colspan='2'      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ser.NFF</font></b>
      </td>
      <td width='20'  style=$n_style colspan='2'      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Valor.NFF</font></b>
      </td>
     </tr>
     ");

  printf("<FORM METHOD='POST' ACTION='fam0005_a.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='seq_entrega'  size='10' maxlenght='10'>
      </td>
      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='num_nff'  size='15' maxlenght='15'>
      </td>
      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='ser_nff' value='1' size='15' maxlenght='15'>
      </td>


      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='chapa' value='".$chapa."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='data_saida' value='".$data_saida."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='apolice' value='".$apolice."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='comp_apolice' value='".$comp_apolice."' readonly  size='15' maxlenght='15'>
      </td>

      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='cpf_moto' value='".$cpf_moto."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_emb' value='".$num_emb."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='empresa' value='".$empresa."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr>
     </FORM>");

  while (is_array($mat_notas))
  {
   printf("<FORM METHOD='POST' ACTION='fam0005_a.php'>");
   printf("<tr>

      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='seq_entrega' value='".$mat_notas["seq_entrega"]."'
       size='10' maxlenght='10'>
      </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='num_nff' value='".round($mat_notas["num_nff"])."'
       size='15' maxlenght='15'>
      </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='ser_nff' value='".round($mat_notas["ser_nff"])."'
       size='15' maxlenght='15'>
      </td>
     <td width='20'  style=$n_style colspan='2'      align='rigth'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='val_tot_nff' readonly value='".number_format($mat_notas["val_tot_nff"],2,",",".")."'
       size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='seq_entrega_c' value='".$mat_notas["seq_entrega"]."'
       size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='chapa' value='".$chapa."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='data_saida' value='".$data_saida."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='apolice' value='".$apolice."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='comp_apolice' value='".$comp_apolice."' readonly  size='15' maxlenght='15'>
      </td>

      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='cpf_moto' value='".$cpf_moto."' readonly  size='15' maxlenght='15'>
      </td>

     <td width='0'  style=$n_style colspan='0'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_nff_c' value='".round($mat_notas["num_nff"])."'
       size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_emb' value='".$num_emb."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='empresa' value='".$empresa."' readonly  size='15' maxlenght='15'>
      </td>

      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");

   printf("<FORM METHOD='POST' ACTION='fam0005_a.php'>");
   printf("
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='seq_entrega' value='".$mat_notas["seq_entrega"]."'
       size='10' maxlenght='10'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_emb' value='".$num_emb."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='empresa' value='".$empresa."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr>
     </FORM>");

   $mat_notas=$cfetch_row($result_notas);
  }
   printf("<FORM METHOD='POST' ACTION='fam0005_b.php'>");
   printf("
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_emb' value='".$num_emb."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='empresa' value='".$empresa."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='L' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Gerar Relatorio e Arquivo TXT '>
      </td>
     </tr>
     </FORM>");


  printf("<FORM METHOD='POST' ACTION='fam0005_a.php'>");
  printf("</tr><tr>");
  printf("
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='num_emb' value='".$num_emb."' readonly  size='15' maxlenght='15'>
      </td>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='hidden' name='empresa' value='".$empresa."' readonly  size='15' maxlenght='15'>
      </td>
    </tr><tr>
      <td width='50'  style=$n_style colspan='5'     align='center'>
        <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          Chapa:</font></i>
        </td>
         <td width='100'  style=$n_style colspan='10'  >
          <select name='chapa'>");
   printf("<option value='$chapa'  selected>$chapa</option>");
   $selec_caminhoes="select  *
                        from lt1200_caminhoes a
                       order by chapa
                   ";
  $res_caminhoes = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_caminhoes = $cquery($selec_caminhoes,$res_caminhoes);

  $mat_caminhoes=$cfetch_row($result_caminhoes);
  while(is_array($mat_caminhoes))
  {
   $chapa=trim($mat_caminhoes["chapa"]);
   printf("<option value='$chapa' >$chapa</option>");
   $mat_caminhoes=$cfetch_row($result_caminhoes);
  }
  printf("</select>
         </td> ");


  printf("<tr>
          <td width='50'  style=$n_style colspan='5'     align='center'>
            <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
             Motorista:</font></i>
          </td>
         <td width='100'  style=$n_style colspan='10'  >
          <select name='cpf_moto'>");



  $selec_motoristas="select  *
                        from lt1200_motoristas 
                       where cpf_moto='".$cpf_moto."'
                   ";
  $res_motoristas = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_motoristas = $cquery($selec_motoristas,$res_motoristas);
  $mat_motoristas=$cfetch_row($result_motoristas);
   $cpf_moto=trim($mat_motoristas["cpf_moto"]);
   $nome_moto=trim($mat_motoristas["nome_moto"]);


   printf("<option value='$cpf_moto' >$nome_moto</option>");

  $selec_motoristas="select  *
                        from lt1200_motoristas a
                       order by nome_moto
                   ";
  $res_motoristas = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_motoristas = $cquery($selec_motoristas,$res_motoristas);
  $mat_motoristas=$cfetch_row($result_motoristas);
  while(is_array($mat_motoristas))
  {
   $cpf_moto=trim($mat_motoristas["cpf_moto"]);
   $nome_moto=trim($mat_motoristas["nome_moto"]);
   printf("<option value='$cpf_moto' >$nome_moto</option>");
   $mat_motoristas=$cfetch_row($result_motoristas);
  }
  printf("</select>
         </td> 

     <tr>
       <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Data.Saida:</font></i>
         </td>
      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='data_saida' value='".$data_saida."'
        size='10' maxlenght='10'>
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='K' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
       <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar'>
      </td>
     </tr>
     </FORM>");

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>







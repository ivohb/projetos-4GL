<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         VDP
 //Processo:       Pesquisa Contas a Receber
 //Vers�o:         1.0
 $prog="vdp/pesq05";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  printf("<tr> <FORM METHOD='POST' ACTION='pesq05_ab.php' target='resultado'></tr>");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/opentable.inc");
  printf("<tr>
      <td width='100'  style=$n_style colspan='10'     align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=red>
       Tit�los </font>
      </td>");
  printf("<tr>
      <td width='100'  style=$n_style colspan='10'     align='left'>");
  printf("<select name='dados'>");
  printf("<OPTION VALUE='00' selected >Todos</OPTION>");
  printf("<OPTION VALUE='01'  >Pagos</OPTION>");
  printf("<OPTION VALUE='02'  >A vencer</OPTION>");
  printf("<OPTION VALUE='03'  >Vencidos</OPTION>");
  printf("</select>");
  printf("</td>");


  printf("<tr>
      <td width='100'  style=$n_style colspan='10'     align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=red>
       Gr�fico:</font>
      </td>");
  printf("<tr>
      <td width='100'  style=$n_style colspan='10'     align='left'>");
  printf("<select name='tipo'>");
  printf("<OPTION VALUE='bars' selected >Barras</OPTION>");
  printf("<OPTION VALUE='linepoints'  >Linhas</OPTION>");
  printf("<OPTION VALUE='pie'   >Pizza</OPTION>");
  printf("</select>");
  printf("</td>");
  printf("</tr>");
  printf("<tr>");

  include("../../bibliotecas/opentable.inc");
  printf("<tr>
       <td width='100'  colspan='10' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Gerar'>
         <input type='hidden' name='prog_c' value='G'>
       </td></tr><tr>
        <td width='100'  colspan='10' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar '>
        </td>
       </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
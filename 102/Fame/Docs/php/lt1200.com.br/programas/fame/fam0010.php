<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten�o:
 //Data manuten�o:22/08/2005
 //Mdulo:         Fame
 //Processo:      Relatóio do Mapa de Vendas
 //Vers�:         1.0
 $versao=1;
 $prog="fame/fam0010";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0010_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/empresa.inc");
   printf("<tr>

      <td width='50'  style=$n_style colspan='5'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Meses:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='meses' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dia Base:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='dia_ini' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes Base:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='mes_ini' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano Base:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='ano_ini' size='4' maxlenght='4'> 
      </td>
      </tr>
      <tr>
      <td width='100'  style=$n_style colspan='10'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dias Uteis no Mes:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='dias_uteis' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dia Util:</font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='center'>
       <input type='text' name='dia_util' size='2' maxlenght='2'> 
      </td>


      <tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='det' value='S' >
         Detalha Ordens
        </td>
      <tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='depura' value='S' >
         Depurar Produtos em Carteira
        </td>


      </table>
      <table>
      <tr>
      <td width='50'  style=$n_style      align='center'>
       <input type='submit' name='Confirmar'>
      </td>
      <td width='50'  style=$n_style     align='center'>
       <input type='reset' name='Cancelar'>
      </td>
     </FORM>
     </tr>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>







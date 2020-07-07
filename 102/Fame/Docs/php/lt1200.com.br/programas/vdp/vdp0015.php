<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Modulo:         VDP
 //Processo:       Notas Fiscais Emitidas por Periodo  e por Cidade
 //Versão:         1.0
  $prog="vdp/vdp0015";
  $versao=1;
 //-----------------------------------------------------------------------------
 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0015_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  printf("</tr><tr>");
  include("../../bibliotecas/autentica.inc");

  printf("</table><table>
      <td width='70'  style=$n_style      align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes/ano Inicio:</font></i>
      </td>
      <td width='50'  style=$n_style     align='center'>
       <input type='text' name='mes_ini' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style      align='center'>
       <input type='text' name='ano_ini' size='4' maxlenght='4'> 
      </td>
      <td width='50'  style=$n_style      align='center'>
       <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes/Ano Fim:</font></i>
      </td>
      <td width='50'  style=$n_style     align='center'>
       <input type='text' name='mes_fim' size='2' maxlenght='2'> 
      </td>
      <td width='50'  style=$n_style      align='center'>
       <input type='text' name='ano_fim' size='4' maxlenght='4'> 
      </td>");
  if($erep<>"S")
  {
   printf("</tr><tr><td width='250'  style=$n_style  align='left'>
          <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          Digite Código do Representante:</font></i>
          </td>
          <td width='50'  style=$n_style      align='left'>
          <input type='text' name='srepres' value='todos' size='10' maxlenght='10'> 
          </td>");
  }

     printf("</table><table><tr>
        <td width='750' style=$n_style      align='left'>
         <input type='checkbox' name='supervisor' value='S' >
         So Supervisor  </td></tr><tr>");
     printf("</table><table><tr>
        <td width='750' style=$n_style      align='left'>
         <input type='checkbox' name='resumo' value='S' >
         Resumo  </td></tr><tr>");


  printf("</table><table><td width='70'  style=$n_style  color=$c_color     align='center'>
           <input type='submit' name='Confirmar' value='Processar'>
           </td>
           </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>

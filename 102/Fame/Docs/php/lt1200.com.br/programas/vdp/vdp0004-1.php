<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Emissao Pedido de Vendas
 //Versão:         1.0
 $prog="vdp/vdp0004";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0004_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  $nom_=strtoupper($nom_);
  $nom_=chop($nom_);
  if($nom_<>"")
  {
   $query="select a.cod_cliente,a.nom_cliente,a.end_cliente,
                a.den_bairro as bairro_cli,a.cod_cep as cep_cli,
                a.num_telefone as fone_cli, a.num_fax as fax_cli,
                a.nom_contato,a.num_cgc_cpf,a.ins_estadual,
                a.cidade as cidade_cli,
                a.uf as uf_cli,a.email,a.cod_repres as cod_nivel_4,'lt'
             from lt1200:lt1200_clientes a 
             where nom_cliente like '%".$nom_."%'
                   and cod_cliente not in ( 
             select a.cod_cliente
             from clientes a,
                   cidades b,
                   outer vdp_cliente_compl c,
                   cli_canal_venda d
                 where b.cod_cidade=a.cod_cidade
                 and a.nom_cliente like '%".$nom_."%'
                 and c.cliente=a.cod_cliente
                 and d.cod_cliente=a.cod_cliente)
           union
             select a.cod_cliente,nom_cliente,end_cliente,
                den_bairro as bairro_cli,cod_cep as cep_cli,
                num_telefone as fone_cli, num_fax as fax_cli,
                nom_contato,num_cgc_cpf,ins_estadual,
                den_cidade as cidade_cli,
                cod_uni_feder as uf_cli,email, d.cod_nivel_4,'lo'
             from clientes a,
                   cidades b,
                   outer vdp_cliente_compl c,
                   cli_canal_venda d
                 where b.cod_cidade=a.cod_cidade
                 and a.nom_cliente like '%".$nom_."%'
                 and c.cliente=a.cod_cliente
                 and d.cod_cliente=a.cod_cliente
               order by a.nom_cliente            ";

   $link = $cconnect("logix",$ifx_user,$ifx_senha);
   $result = $cquery($query, $link);
  }else{
   $query="select a.cod_cliente,a.nom_cliente,a.end_cliente,
                a.den_bairro as bairro_cli,a.cod_cep as cep_cli,
                a.num_telefone as fone_cli, a.num_fax as fax_cli,
                a.nom_contato,a.num_cgc_cpf,a.ins_estadual,
                a.cidade as cidade_cli,
                a.uf as uf_cli,a.email,a.cod_repres as cod_nivel_4,'lt'
             from lt1200:lt1200_clientes a 
             where nom_cliente like '%".$nom_."%'
                   and cod_cliente not in ( 
             select a.cod_cliente
             from clientes a,
                   cidades b,
                   outer vdp_cliente_compl c,
                   cli_canal_venda d
                 where b.cod_cidade=a.cod_cidade
                 and a.cod_cliente='".$cgc_."'
                 and c.cliente=a.cod_cliente
                 and d.cod_cliente=a.cod_cliente)
           union
             select a.cod_cliente,nom_cliente,end_cliente,
                den_bairro as bairro_cli,cod_cep as cep_cli,
                num_telefone as fone_cli, num_fax as fax_cli,
                nom_contato,num_cgc_cpf,ins_estadual,
                den_cidade as cidade_cli,
                cod_uni_feder as uf_cli,email, d.cod_nivel_4,'lo'
             from clientes a,
                   cidades b,
                   outer vdp_cliente_compl c,
                   cli_canal_venda d
                 where b.cod_cidade=a.cod_cidade
                 and a.cod_cliente='".$cgc_."'
                 and c.cliente=a.cod_cliente
                 and d.cod_cliente=a.cod_cliente
               order by a.nom_cliente            ";
   $link = $cconnect("logix",$ifx_user,$ifx_senha);
   $result = $cquery($query, $link);
  }
  printf("
  <script language='javascript'>
   function confirma(n)
   {
    window.location = 'orc002-1a.php?uid='+n;
   }
   </script>
   <script language='javascript'>
    function fim_do_orcamento()
    {
     window.close();
    } 
   </script>                               
   <form action='orc001.php' method='POST'>
  <tr>");
  while ($array = $cfetch_row($result))
  {
   $espaco=' - ';
   $uid=$array["cod_cliente"];
   if($rep_s=="N")
   {
    if($rep==round($array["cod_nivel_4"]))
    {
     $linha= "<a href='javascript:confirma(\"".$uid."\");'>".$array["cod_cliente"]."".$espaco."".$array["nom_cliente"]."".$espaco."".round($array["cod_nivel_4"])."</a><br>";
    }else{
     $linha=$array["cod_cliente"]."".$espaco."".$array["nom_cliente"]."".$espaco."".round($array["cod_nivel_4"]);
    }
    printf("<tr>");
    printf("<td width='550' COLSPAN='55' ><p align='left'>$linha<font face=Arial color='red' size='1'></font></p></td>");
    printf("</tr>");
   }else{
   if($rep==round($array["cod_nivel_4"]))
   {
    $linha= "<a href='javascript:confirma(\"".$uid."\");'>".$array["cod_cliente"]."".$espaco."".$array["nom_cliente"]."".$espaco."".round($array["cod_nivel_4"])."</a><br>";
    printf("<tr>");
    printf("<td width='550' COLSPAN='55' ><p align='left'>$linha<font face=Arial color='red' size='1'></font></p></td>");
    printf("</tr>");
   }
  }
 }
 printf("<tr>
          <td width 50 colspan='5'
           <input type='submit' name='incluir' value='INCLUIR NOVO CLIENTE'>
          </td>
          <td width='50' colspan='5' height='10'>
           <input type='text' value='$rep' name='rep' readonly size='5' maxlength='5'>
          </td>
         </tr>
         </form>");

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>

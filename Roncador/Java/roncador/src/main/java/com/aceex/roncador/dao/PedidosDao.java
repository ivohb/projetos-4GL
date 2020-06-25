package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import main.java.com.aceex.roncador.model.PedItemSical;
import main.java.com.aceex.roncador.model.PedidoSical;
import main.java.com.aceex.roncador.model.Pedido;

public class PedidosDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;
	private Connection conect;
	
	public PedidosDao(Connection conexao) {
		super(conexao);
	}

	public Connection getConect() {
		return getConexao();
	}

	public String getCodigo(Integer numero) throws SQLException {

		String codigo = null;
		String query = "";

		query += "select cod_cliente from pedidos";
		query += " where num_pedido =  ? ";

		stmt = getConexao().prepareStatement(query);

		stmt.setInt(1, numero);

		rs = stmt.executeQuery();

		if (rs.next()) {
			codigo = rs.getString(1);
		}

		rs.close();
		stmt.close();

		return codigo;
	}

	public boolean isPedido(String empresa, Integer numero) throws SQLException {

		boolean result = false;
		String query = "";

		query += "select ies_sit_pedido from pedidos";
		query += " where trim(cod_empresa) = ? and num_pedido =  ? ";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, empresa.trim());
		stmt.setInt(2, numero);

		rs = stmt.executeQuery();

		if (rs.next()) {
			String situa = rs.getString(1);
			if (situa.equalsIgnoreCase("9")) {
			} else {
				result = true;
			}
		}

		rs.close();
		stmt.close();

		return result;
	}

	@SuppressWarnings("deprecation")
	public void inserir(Pedido pedido, PedidoSical ps,
			List<PedItemSical> itens) throws Exception {
		
		conect = getConexao();
		conect.setAutoCommit(false);

		String query =
			"INSERT INTO pedidos (cod_empresa, num_pedido, cod_cliente,"				
			+ " pct_comissao, num_pedido_repres, dat_emis_repres, cod_nat_oper,"
			+ " ies_finalidade, ies_frete, ies_preco, cod_cnd_pgto, pct_desc_financ,"
			+ " ies_embal_padrao, ies_tip_entrega, ies_aceite, ies_sit_pedido, dat_pedido, "
			+ " num_pedido_cli, pct_desc_adic, num_list_preco, cod_repres, cod_repres_adic, "
			+ " dat_alt_sit, cod_tip_venda, cod_moeda, ies_comissao,"
			+ " pct_frete, cod_tip_carteira, num_versao_lista)"
			+ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		stmt = conect.prepareStatement(query); 
		Date data = new Date(Date.parse(pedido.getDatPedido()));
		stmt.setString(1, pedido.getCodEmpresa());
		stmt.setInt(2, pedido.getNumPedido());
		stmt.setString(3, pedido.getCodCliente());
		stmt.setDouble(4, pedido.getPctComissao());
		stmt.setString(5, pedido.getNumPedRepres());
		stmt.setDate(6, data);
		stmt.setInt(7, pedido.getCodNatOper());
		stmt.setInt(8, pedido.getIesFinalidade());		
		stmt.setInt(9, pedido.getIesFrete());
		stmt.setString(10, pedido.getIesPreco());
		stmt.setInt(11, pedido.getCodCndPgto());
		stmt.setDouble(12, pedido.getPctDescFinanc());
		stmt.setString(13, pedido.getIesEmbalPadrao());
		stmt.setInt(14, pedido.getIesTipEntrega());
		stmt.setString(15, pedido.getIesAceite());		
		stmt.setString(16, pedido.getIesSitPedido());		
		stmt.setDate(17, data);
		stmt.setString(18, pedido.getNumPedidoCli());
		stmt.setDouble(19, pedido.getPctDescAdic());
		stmt.setInt(20, pedido.getNumListPreco());
		stmt.setInt(21, pedido.getCodRepres());
		stmt.setInt(22, pedido.getCodRepresAdic());
		stmt.setDate(23, data);
		stmt.setInt(24, pedido.getCodTipVenda());
		stmt.setInt(25, pedido.getCodMoeda());
		stmt.setString(26, pedido.getIesComissao());
		stmt.setDouble(27, pedido.getPctFrete());
		stmt.setString(28, pedido.getCodTipCarteira());
		stmt.setInt(29, pedido.getNumVersaoLista());
		stmt.executeUpdate();
		stmt.close();

		query = "INSERT INTO ped_inf_com_mestre (empresa, pedido, usuario, dat_inclusao) "
			+ " VALUES(?,?,?,?) ";

		stmt = conect.prepareStatement(query); 
		stmt.setString(1, pedido.getCodEmpresa());
		stmt.setInt(2, pedido.getNumPedido());
		stmt.setString(3,"sical");
		stmt.setDate(4, data);
		stmt.executeUpdate();
		stmt.close();

		if (pedido.getNatOperRemessa() != null && pedido.getNatOperRemessa() > 0) {
			query = "INSERT INTO ped_item_nat "
				+ "(cod_empresa, num_pedido, num_sequencia, ies_tipo, "
				+ " ies_separa_nff, cod_cliente, cod_nat_oper, cod_cnd_pgto)"
				+ " VALUES(?,?,?,?,?,?,?,?)";	

			stmt = conect.prepareStatement(query); 
			stmt.setString(1, pedido.getCodEmpresa());
			stmt.setInt(2, pedido.getNumPedido());
			stmt.setInt(3, 0);
			stmt.setString(4, "N");
			stmt.setString(5, "N");
			stmt.setString(6, pedido.getCodCliente());
			stmt.setInt(7, pedido.getNatOperRemessa());
			stmt.setInt(8, pedido.getCodCndPgto());
			
			stmt.executeUpdate();
			stmt.close();
		}

		if (pedido.getObsNf() != null && pedido.getObsNf().trim().length() > 0) {
			query = "INSERT INTO ped_itens_texto "
				+ "(cod_empresa, num_pedido, num_sequencia, den_texto_1,"
				+ " den_texto_2, den_texto_3, den_texto_4, den_texto_5)"
				+ " VALUES(?,?,?,?,?,?,?,?)";	

			stmt = conect.prepareStatement(query); 
			stmt.setString(1, pedido.getCodEmpresa());
			stmt.setInt(2, pedido.getNumPedido());
			stmt.setInt(3, 0);
			stmt.setString(4, pedido.getObsNf());
			stmt.setString(5, pedido.getObs2Nf());
			stmt.setString(6, pedido.getObs3Nf());
			stmt.setString(7, pedido.getObs4Nf());
			stmt.setString(8, pedido.getObs5Nf());
			stmt.executeUpdate();
			stmt.close();
		}

		if (pedido.getObsPedido() != null && pedido.getObsPedido().trim().length() > 0) {
			query = "INSERT INTO ped_observacao "
				+ "(cod_empresa, num_pedido, tex_observ_1, tex_observ_2)"
				+ " VALUES(?,?,?,?)";	

			stmt = conect.prepareStatement(query); 
			stmt.setString(1, pedido.getCodEmpresa());
			stmt.setInt(2, pedido.getNumPedido());
			stmt.setString(3, pedido.getObsPedido());
			stmt.setString(4, pedido.getObs2Pedido());
			stmt.executeUpdate();
			stmt.close();
		}

		int numSeq = 0;
		
		for (PedItemSical pis : itens) {
			query = "INSERT INTO ped_itens (cod_empresa, num_pedido, num_sequencia, "
					+ " pct_desc_adic, pre_unit, qtd_pecas_solic, qtd_pecas_atend, "
					+ " qtd_pecas_cancel, qtd_pecas_reserv, prz_entrega, "
					+ " val_desc_com_unit, val_frete_unit, val_seguro_unit, "
					+ " qtd_pecas_romaneio, pct_desc_bruto, cod_item)"
					+ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";	

			stmt = conect.prepareStatement(query); 
			
			numSeq++;

			double precoTabela = Double.parseDouble(pis.getPreco_tabela());
			double precoUnit = Double.parseDouble(pis.getPreco_unitario());
			double valDesc = precoTabela - precoUnit;

			stmt.setString(1, pedido.getCodEmpresa());
			stmt.setInt(2, pedido.getNumPedido());
			stmt.setInt(3, numSeq);
			stmt.setDouble(4, 0);
			stmt.setDouble(5, precoUnit);
			stmt.setDouble(6, Double.parseDouble(pis.getQuant()));
			stmt.setDouble(7, 0);
			stmt.setDouble(8, Double.parseDouble(pis.getQuant_cancelada()));
			stmt.setDouble(9, 0);
			stmt.setDate(10, data);
			stmt.setDouble(11, 0);
			stmt.setDouble(12, 0);
			stmt.setDouble(13, 0);
			stmt.setDouble(14, 0);
			stmt.setDouble(15, 0);
			String codProduto = getProduto(pedido.getCodEmpresa(), pis.getCod_produto());
			stmt.setString(16,codProduto);
			stmt.executeUpdate();
			stmt.close();

		}
		
		query = "UPDATE pedido_sical SET situacao = 'F', ";
		query += " pedido_logix = '"+pedido.getNumPedido()+"' ";
		query += " WHERE trim(cnpj_empresa) = ? and trim(pedido_sical) = ? ";
		query += " and num_versao = ?";

		stmt = conect.prepareStatement(query);
		stmt.setString(1, ps.getCnpj_empresa());
		stmt.setString(2, ps.getNum_pedido());
		stmt.setInt(3, ps.getNum_versao());

	    stmt.executeUpdate();
	    stmt.close();	

	    conect.commit();
	    
	}

	public String getProduto(String codEmpresa, String codSical) throws SQLException {

		String codLogix = null;
		String query = "";
		 
		query += "select cod_logix from de_para_produto ";
		query += " where trim(cod_empresa) =  ? and trim(cod_sical) = ?";

		PreparedStatement stmt = getConexao().prepareStatement(query);
		stmt.setString(1, codEmpresa.trim());
		stmt.setString(2, codSical.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			codLogix = rs.getString("cod_logix");
		}

		rs.close();
		stmt.close();

		return codLogix;
	}
	
	
	public void abortaConec() {
		try {
			if (this.conect != null) {
				this.conect.rollback();
				//this.conect.close();
			}			
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

	public void fechaConec() {
		try {
			if (this.conect != null) {
				this.conect.close();
			}			
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

	public void fechaConec(Connection conexao) {
		try {
			if (conexao != null) {
				conexao.rollback();
				conexao.close();
			}			
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

}

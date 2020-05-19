package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import main.java.com.aceex.roncador.model.PedItemSical;

public class PedItemSicalDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public PedItemSicalDao(Connection conexao) {
		super(conexao);
	}
	
	public boolean isItem(PedItemSical pis) throws SQLException {

		boolean result = false;
		String query = "";

		query += "select 1 from ped_item_sical";
		query += " where cnpj_empresa = ? and pedido_sical = ? ";
		query += " and cod_produto =  ? ";
		
		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, pis.getCnpj_empresa());
		stmt.setString(2, pis.getNum_pedido());
		stmt.setString(3, pis.getCod_produto());

		rs = stmt.executeQuery();

		if (rs.next()) {
			result = true;
		}

		rs.close();
		stmt.close();

		return result;
	}

	public void inserir(PedItemSical pis) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO ped_item_sical (cnpj_empresa, pedido_sical, num_versao, "
			+ "cod_produto, qtd_prod_tonelada, qtd_canc_tonelada, preco_tabela, "
			+ "pct_desc, preco_unit_liquido, total_bruto, total_liquido)"
			+ " VALUES(?,?,?,?,?,?,?,?,?,?,?)";

		stmt = con.prepareStatement(query); 
		stmt.setString(1, pis.getCnpj_empresa());
		stmt.setString(2, pis.getNum_pedido());
		stmt.setInt(3, pis.getNum_versao());
		stmt.setString(4, pis.getCod_produto());
		stmt.setString(5, pis.getQuant());
		stmt.setString(6, pis.getQuant_cancelada());
		stmt.setString(7, pis.getPreco_tabela());
		stmt.setString(8, pis.getPerc_desc());
		stmt.setString(9, pis.getPreco_unitario());
		stmt.setString(10, pis.getTotal_bruto());
		stmt.setString(11, pis.getTotal_liquido());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

	public void atualizar(PedItemSical pis) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE ped_item_sical SET qtd_prod_tonelada = '"+pis.getQuant()+"' ";
		query += ", qtd_canc_tonelada = '"+pis.getQuant_cancelada()+"' ";
		query += ", total_bruto = '"+pis.getTotal_bruto()+"' ";
		query += ", total_liquido = '"+pis.getTotal_liquido()+"' ";
		query += " where cnpj_empresa = ? and pedido_sical = ? ";
		query += " and cod_produto =  ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, pis.getCnpj_empresa());
		stmt.setString(2, pis.getNum_pedido());
		stmt.setString(3, pis.getCod_produto());

		stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}
	
	public List<PedItemSical> listaItens(String empresa, 
			String pedido, Integer versao) throws SQLException {
		
		List<PedItemSical> itens = new ArrayList<PedItemSical>();
		PedItemSical pis = null;
		Connection con = getConexao();
		
		String query = "";

		query += "SELECT cod_produto, qtd_prod_tonelada, qtd_canc_tonelada, ";
		query += "preco_tabela, pct_desc, preco_unit_liquido ";
		query += "FROM ped_item_sical ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ? and num_versao = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setString(2, pedido);
		stmt.setInt(3, versao);
		
		rs = stmt.executeQuery();

		while (rs.next()) {
			pis = new PedItemSical();
			pis.setCod_produto(rs.getString(1));
			pis.setQuant(rs.getString(2));
			pis.setQuant_cancelada(rs.getString(3));
			pis.setPreco_tabela(rs.getString(4));
			pis.setPerc_desc(rs.getString(5));
			pis.setPreco_unitario(rs.getString(6));

			itens.add(pis);
		}

		return itens;		
	}

}

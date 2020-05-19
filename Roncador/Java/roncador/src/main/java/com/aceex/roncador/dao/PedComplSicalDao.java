package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import main.java.com.aceex.roncador.model.PedComplSical;

public class PedComplSicalDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public PedComplSicalDao(Connection conexao) {
		super(conexao);
	}

	public boolean isCompl(PedComplSical pcs) throws SQLException {

		boolean result = false;
		String query = "";

		query += "select 1 from pedido_compl_sical";
		query += " where cnpj_empresa = ? and pedido_sical = ? ";
		
		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, pcs.getCnpj_empresa());
		stmt.setString(2, pcs.getNum_pedido());

		rs = stmt.executeQuery();

		if (rs.next()) {
			result = true;
		}

		rs.close();
		stmt.close();

		return result;
	}

	public void inserir(PedComplSical pcs) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO pedido_compl_sical (num_versao, "
			+ " cnpj_empresa, pedido_sical, obs, obs_nota_fiscal)"
			+ " VALUES(?,?,?,?,?)";

		stmt = con.prepareStatement(query); 
		stmt.setInt(1, pcs.getNum_versao());
		stmt.setString(2, pcs.getCnpj_empresa());
		stmt.setString(3, pcs.getNum_pedido());
		stmt.setString(4, pcs.getObs());
		stmt.setString(5, pcs.getObs_nota_fiscal());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

	public void atualizar(PedComplSical pcs) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE pedido_compl_sical SET obs = '"+pcs.getObs()+"' ";
		query += ", obs_nota_fiscal = '"+pcs.getObs_nota_fiscal()+"' ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, pcs.getCnpj_empresa());
		stmt.setString(2, pcs.getNum_pedido());
	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public PedComplSical getCompl(String empresa, 
			String pedido, Integer versao) throws SQLException {
		
		PedComplSical pcs = null;

		String query = "";

		query += "select cnpj_empresa, obs, obs_nota_fiscal from pedido_compl_sical";
		query += " where cnpj_empresa = ? and pedido_sical = ? and num_versao = ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setString(2, pedido);
		stmt.setInt(3, versao);

		rs = stmt.executeQuery();

		if (rs.next()) {
			pcs = new PedComplSical();
			pcs.setNum_versao(versao);
			pcs.setCnpj_empresa(rs.getString("cnpj_empresa"));
			pcs.setNum_pedido(pedido);
			pcs.setObs(rs.getString("obs"));
			pcs.setObs_nota_fiscal(rs.getString("obs_nota_fiscal"));
		}

		rs.close();
		stmt.close();

		return pcs;
				
		
	}

}

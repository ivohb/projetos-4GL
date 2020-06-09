package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

		query += "select pedido_sical from pedido_compl_sical";
		query += " where num_versao = ? and trim(cnpj_empresa) = ? ";
		query += " and trim(pedido_sical) = ? ";
		
		stmt = getConexao().prepareStatement(query);

		stmt.setInt(1, pcs.getNum_versao());
		stmt.setString(2, pcs.getCnpj_empresa().trim());
		stmt.setString(3, pcs.getNum_pedido().trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			result = true;
		}

		rs.close();
		stmt.close();

		return result;
	}

	public void inserir(PedComplSical pcs) throws SQLException {
		
		String texto = "";
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
		
		texto =  pcs.getObs();
		if (texto.length() > 76) {
			texto = texto.substring(0, 76);
		}		
		stmt.setString(4, texto);
		
		texto =   pcs.getObs_nota_fiscal();
		if (texto.length() > 76) {
			texto = texto.substring(0, 76);
		}
		stmt.setString(5, texto);
		
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
		query += " where num_versao = ? and trim(cnpj_empresa) = ? ";
		query += " and trim(pedido_sical) = ? ";

		stmt = con.prepareStatement(query);
		stmt.setInt(1, pcs.getNum_versao());
		stmt.setString(2, pcs.getCnpj_empresa().trim());
		stmt.setString(3, pcs.getNum_pedido().trim());
	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public PedComplSical getCompl(String empresa, 
			String pedido, Integer versao) throws SQLException {
		
		PedComplSical pcs = null;

		String query = "";

		query += "select cnpj_empresa, obs, obs_nota_fiscal from pedido_compl_sical";
		query += " where trim(cnpj_empresa) = ? and trim(pedido_sical) = ? ";
		query += " and num_versao = ? ";
		
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

	public List<PedComplSical> getLista(String empresa, 
			String pedido, Integer versao) throws SQLException {
		
		List<PedComplSical> lista = new ArrayList<PedComplSical>();
		PedComplSical pcs = null;

		String query = "";

		query += "select obs, obs_nota_fiscal from pedido_compl_sical";
		query += " where trim(cnpj_empresa) = ? and trim(pedido_sical) = ? ";
		query += " and num_versao = ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setString(2, pedido);
		stmt.setInt(3, versao);

		rs = stmt.executeQuery();

		if (rs.next()) {
			pcs = new PedComplSical();
			pcs.setObs(rs.getString("obs"));
			pcs.setObs_nota_fiscal(rs.getString("obs_nota_fiscal"));
			lista.add(pcs);
		}

		rs.close();
		stmt.close();

		return lista;
				
		
	}

}

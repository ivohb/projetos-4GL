package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ItemDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public ItemDao(Connection conexao) {
		super(conexao);
	}
	
	public boolean isItem(String codEmpresa, String codItem) throws SQLException {

		boolean result = false;
		String query = "";

		query += "select 1 from item ";
		query += "where trim(cod_empresa) = ? ";
		query += " and trim(cod_item) = ? and ies_situacao = 'A' ";

		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, codEmpresa.trim());
		stmt.setString(2, codItem.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			result = true;
		}

		rs.close();
		stmt.close();

		return result;
	}


}

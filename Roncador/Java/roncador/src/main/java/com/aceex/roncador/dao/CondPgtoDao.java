package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CondPgtoDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public CondPgtoDao(Connection conexao) {
		super(conexao);
	}
	
	public String getCodigo(String codCond) throws SQLException {

		String codigo = null;
		String query = "";

		query += "select cod_cnd_pgto from cond_pgto";
		query += " where cod_cnd_pgto =  ? ";

		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, codCond);

		rs = stmt.executeQuery();

		if (rs.next()) {
			codigo = rs.getString("cod_cnd_pgto");
		}

		rs.close();
		stmt.close();

		return codigo;
	}

}

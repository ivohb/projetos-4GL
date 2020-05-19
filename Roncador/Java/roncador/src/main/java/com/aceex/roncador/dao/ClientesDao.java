package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ClientesDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public ClientesDao(Connection conexao) {
		super(conexao);
	}
	
	public String getCodigo(String cnpj) throws SQLException {

		String codigo = null;
		String query = "";

		query += "select cod_cliente from clientes";
		query += " where num_cgc_cpf =  ? ";

		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, cnpj);

		rs = stmt.executeQuery();

		if (rs.next()) {
			codigo = rs.getString("cod_cliente");
		}

		rs.close();
		stmt.close();

		return codigo;
	}

}

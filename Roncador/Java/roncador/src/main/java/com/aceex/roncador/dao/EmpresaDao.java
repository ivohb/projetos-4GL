package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import main.java.com.aceex.roncador.model.Empresa;

public class EmpresaDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public EmpresaDao(Connection conexao) {
		super(conexao);
	}

	public String getCodigo(String numCgc) throws SQLException {

		String codigo = null;
		String query = "";

		query += "select cod_empresa from empresa";
		query += " where trim(num_cgc) =  ? ";

		stmt = getConexao().prepareStatement(query);

		stmt.setString(1, numCgc.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			codigo = rs.getString("cod_empresa");
		}

		rs.close();
		stmt.close();

		return codigo;
	}

	public List<Empresa> getEmpresas() throws SQLException {
		
		List<Empresa> empresas = new ArrayList<Empresa>();
		Empresa empresa;
		
		Connection con = getConexao();
		String query = "";

		query += "SELECT  cod_empresa, num_cnpj from cnpj_empresa ";
		
		PreparedStatement stmt = con.prepareStatement(query);
		ResultSet rs = stmt.executeQuery();

		while (rs.next()) {
			empresa = new Empresa();
			empresa.setCodigo(rs.getString(1));
			empresa.setCnpj(rs.getString(2));
			empresas.add(empresa);
		}

		return empresas;
	}

}

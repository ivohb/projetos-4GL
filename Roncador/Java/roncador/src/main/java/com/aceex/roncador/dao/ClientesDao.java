package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.action.Pedidos;

public class ClientesDao extends Dao {

	private static Logger log = Logger.getLogger(ClientesDao.class);
	private PreparedStatement stmt;
	private ResultSet rs;

	public ClientesDao(Connection conexao) {
		super(conexao);
	}
	
	public String getCodigo(String cnpj, String insc) throws SQLException {
		
		log.info("Cnpj:"+cnpj+"Inscricao:"+insc);
		
		String codigo = null;
		String query = "";

		if (insc == null) {
			insc = "ISENTO";
		}

		query  = "select cod_cliente from clientes ";
		query += " where trim(num_cgc_cpf) =  ? ";
	    query += " and trim(ins_estadual) = ? ";		
						
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, cnpj.trim());
		stmt.setString(2, insc.trim());
		rs = stmt.executeQuery();

		if (rs.next()) {
			codigo = rs.getString("cod_cliente");
		} else {
			rs.close();
			stmt.close();
			
			query = "select cod_cliente from clientes "
				+ " where trim(num_cgc_cpf) =  ? ";
			
			stmt = getConexao().prepareStatement(query);
			stmt.setString(1, cnpj.trim());
			rs = stmt.executeQuery();
			
			if (rs.next()) {
				codigo = rs.getString("cod_cliente");
			}
		}

		rs.close();
		stmt.close();

		return codigo;
	}

}

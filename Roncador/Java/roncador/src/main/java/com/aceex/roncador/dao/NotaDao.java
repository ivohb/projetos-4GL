package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.action.Notas;
import main.java.com.aceex.roncador.model.Nota;

public class NotaDao extends Dao {

	private static Logger log = Logger.getLogger(Notas.class);
	private Nota nota;

	public NotaDao(Connection conexao) {
		super(conexao);
	}
	
	public List<Nota> lstCanceladas(String codEmpresa) throws SQLException {
		
		List<Nota> notas = new ArrayList<Nota>();
		
		Connection con = getConexao();
		String query = "";

		query += "SELECT trans_nota_fiscal, nota_fiscal, serie_nota_fiscal, dat_hor_cancel ";
		query += " FROM fat_nf_mestre f, nota_sical s ";
		query += " where f.empresa = ? and  f.sit_nota_fiscal = 'C' ";
		query += " and f.empresa = s.cod_empresa ";
		query += " and f.trans_nota_fiscal = s.num_transac ";
		query += " and f.trans_nota_fiscal not in (select n.num_transac from nota_sical n ";
		query += " where n.cod_empresa = f.empresa and n.sit_nota = 'C')";

		log.info(query);
		
		PreparedStatement stmt = con.prepareStatement(query);
		stmt.setString(1, codEmpresa);
		ResultSet rs = stmt.executeQuery();

		while (rs.next()) {
			
			nota = new Nota();
			nota.setEmpresa(codEmpresa);
			nota.setTransac(rs.getInt("trans_nota_fiscal"));
			nota.setNum_nota(rs.getInt("nota_fiscal"));
			nota.setSerie(rs.getString("serie_nota_fiscal"));
			nota.setDt_emissao(rs.getDate("dat_hor_cancel"));
			nota.setSit_nota("C");
			notas.add(nota);
		}

		rs.close();
		stmt.close();

		return notas;		
	}	

	
	public List<Nota> lstEmitidas(String codEmpresa) throws SQLException {
		
		List<Nota> notas = new ArrayList<Nota>();
		
		Connection con = getConexao();
		String query = "";

		query += "SELECT DISTINCT f.trans_nota_fiscal, f.item,  f.qtd_item as quant, ";
		query += " p.pedido_logix as pedido, p.tipo_pedido as tipo, p.entrega_futura as entrega, ";
		query += " nota_fiscal,serie_nota_fiscal,placa_veiculo,dat_hor_emissao,sit_nota_fiscal ";
		query += " FROM fat_nf_item f, pedido_sical p, fat_nf_mestre m ";
		query += " where m.empresa = ? and m.sit_nota_fiscal <> 'C' and m.empresa = f.empresa ";
		query += " and m.trans_nota_fiscal = f.trans_nota_fiscal and f.empresa = p.cod_empresa";
		query += " and f.pedido = p.pedido_logix and p.pedido_logix  > 0 ";
		query += " and f.trans_nota_fiscal not in (select n.num_transac from  nota_sical n ";
		query += " where n.cod_empresa = f.empresa )";
		
		log.info(query);
		
		PreparedStatement stmt = con.prepareStatement(query);
		stmt.setString(1, codEmpresa);
		ResultSet rs = stmt.executeQuery();

		while (rs.next()) {
			
			Integer transac = rs.getInt(1);

			nota = new Nota();
			nota.setEmpresa(codEmpresa);
			nota.setTransac(transac);
			nota.setNum_nota(rs.getInt("nota_fiscal"));
			nota.setDt_emissao(rs.getDate("dat_hor_emissao"));
			nota.setPlaca_veiculo(rs.getString("placa_veiculo"));
			nota.setSit_nota(rs.getString("sit_nota_fiscal"));
			nota.setSerie(rs.getString("serie_nota_fiscal"));				
			nota.setNum_pedido(rs.getInt("pedido"));
			nota.setQuant(rs.getDouble("quant"));
			String tipo = rs.getString("tipo");
			String entrega = rs.getString("entrega");
	
			Integer operacao = 0;
				
			if (tipo.equalsIgnoreCase("1")) {
				if (entrega.equalsIgnoreCase("0")) {
					operacao = 1;
				} else operacao = 2;
			} else {
				operacao = (Integer.parseInt(tipo)) + 2;					
			}

			nota.setTipo_operacao(operacao);
			notas.add(nota);
		}

		rs.close();
		stmt.close();

		return notas;		
	}	

	public boolean getNota(String empresa, Integer transac) throws SQLException {

		boolean result = false;
		String query = "";

		query += "select nota_fiscal, serie_nota_fiscal, placa_veiculo, dat_hor_emissao ";
		query += "from fat_nf_mestre where empresa = ? and trans_nota_fiscal = ? ";
		
		PreparedStatement stmt = getConexao().prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setInt(2, transac);
		ResultSet rs = stmt.executeQuery();

		if (rs.next()) {
			nota = new Nota();
			nota.setEmpresa(empresa);
			nota.setTransac(transac);
			nota.setNum_nota(rs.getInt("nota_fiscal"));
			nota.setDt_emissao(rs.getDate("dat_hor_emissao"));
			nota.setPlaca_veiculo(rs.getString("placa_veiculo"));
			nota.setSerie(rs.getString("serie_nota_fiscal"));
			result = true;
		}

		rs.close();
		stmt.close();

		return result;

	}
	
	public void salva(Nota nota) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO nota_sical "
			+ "(cod_empresa, num_transac, num_nota, serie, "
			+ " pedido_sical, sit_nota, qtd_item) "
			+ " VALUES(?,?,?,?,?,?,?)";	

		PreparedStatement stmt = con.prepareStatement(query); 
		stmt.setString(1, nota.getEmpresa());
		stmt.setInt(2, nota.getTransac());
		stmt.setInt(3, nota.getNum_nota());
		stmt.setString(4, nota.getSerie());
		Integer pedSical = nota.getNum_pedido();
		if (pedSical == null) {
			pedSical = 0;
		}
		stmt.setInt(5, pedSical);
		stmt.setString(6, nota.getSit_nota());
		stmt.setDouble(7, nota.getQuant());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

}

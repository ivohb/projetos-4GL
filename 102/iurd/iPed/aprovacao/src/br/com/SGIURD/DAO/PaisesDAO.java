package br.com.SGIURD.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.struts.action.ActionForm;
import org.json.JSONException;
import org.json.JSONObject;

import br.com.SGIURD.Interface.IDAO;
import br.com.SGIURD.form.PaisesForm;
import br.com.SGIURD.utils.Simplifying;

public class PaisesDAO implements IDAO {
	private Connection connection;
	private String sql, retorno;
	private PreparedStatement stmt;
	private ResultSet rs;
	private Simplifying s = new Simplifying();
	JSONObject j = new JSONObject();
	
	public PaisesDAO(Connection connection){
		this.connection = connection;
	}
	
	@Override
	public JSONObject insere(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		try{
			sql ="INSERT INTO paises_iurd (cod_pais,den_pais,cod_ddi,cod_language, for_data) VALUES (?,?,?,?,?)";
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1, pais.getCod_pais());
			stmt.setString(2, pais.getDen_pais());
			stmt.setString(3, pais.getCod_ddi());
			stmt.setString(4, pais.getCod_language());
			stmt.setString(5, pais.getFor_data());			
			//executa a query
			stmt.execute();
			stmt.close();
			
			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");
		} catch (Exception e) {
			j.put("errorCode", 302);
			j.put("errorDesc","PaisesDAO.insere(). Erro de Sintaxe.");
			System.out.println("PaisesDAO.insere()" + e);
		}		
		return j;	
	}

	@Override
	public JSONObject altera(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		try{
			sql = "UPDATE paises_iurd SET den_pais = ?, cod_ddi = ? , for_data = ? "
					+ "where cod_pais = ? and cod_language = ?";
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1, pais.getDen_pais());
			stmt.setString(2, pais.getCod_ddi());
			stmt.setString(3, pais.getFor_data());
			stmt.setString(4, pais.getCod_pais());
			stmt.setString(5, pais.getCod_language());
			//executa a query
			stmt.execute();
			stmt.close();
	
			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");		
		} catch (Exception e) {
			j.put("errorCode", 302);
			j.put("errorDesc","PaisesDAO.altera(). Erro de Sintaxe.");
			System.out.println("PaisesDAO.altera()" + e);
		}
		return j;
	}



	public JSONObject filtra(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		try{
			sql = "SELECT cod_pais, den_pais, cod_ddi, cod_language, for_data FROM paises_iurd "
				+ " WHERE cod_language = ? ORDER BY cod_pais";
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1, pais.getCod_language());

			rs = stmt.executeQuery();

			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");
			
			while(rs.next()){
				j.append("data",s.toJson(rs));
			}
			stmt.close();
			rs.close();
		} catch (Exception e) {
			j.put("errorCode", 302);
			j.put("errorDesc","PaisesDAO.filtra(). Erro de Sintaxe");
			System.out.println("PaisesDAO.filtra()" + e);
		}
		return j;
	}
	
	@Override
	public JSONObject exclui(ActionForm form) throws JSONException {
		return null;
	}

	@Override
	public boolean isEntidadeExiste(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		boolean flag = false;
	
		try {		
			sql = "select cod_pais from paises_iurd where cod_language = ?"
					+ " and (cod_pais = ? or den_pais = ?)";
			
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1,pais.getCod_language());
			stmt.setString(2,pais.getCod_pais());
			stmt.setString(3,pais.getDen_pais());

			rs = stmt.executeQuery();
			
			flag = rs.next();
			
			stmt.close();
			rs.close();
		} catch (Exception e) {
			System.out.println("PaisesDAO.isEntidadeExiste()" + e);
		}
		return flag;
	}

	@Override
	public Integer geraId() {
		return null;
	}
	
	public JSONObject filtracomLocalEPermissao(ActionForm form) throws JSONException {
		try{
		PaisesForm pais = (PaisesForm) form;

			sql = "SELECT DISTINCT paises_iurd.cod_pais, paises_iurd.den_pais, paises_iurd.cod_ddi, paises_iurd.cod_language, paises_iurd.for_data "
			    + " FROM paises_iurd"
				+ " JOIN igreja_iurd ON igreja_iurd.cod_pais = paises_iurd.cod_pais"
				+ " WHERE cod_language = ?";
			
			//adiciona o filtro de localidade
			if(pais.getPermissaoLocalidade().length() > 0){
				sql += " AND " + pais.getPermissaoLocalidade();
			}					
			
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1,pais.getCod_language());
			rs = stmt.executeQuery();
	
			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");
			
			while(rs.next()){
				j.append("data", s.toJson(rs));
			}
			
			stmt.close();
			rs.close();	
		} catch (Exception e) {
			j.put("errorCode", 302);
			j.put("errorDesc","PaisesDAO.filtracomLocalEPermissao(). Erro de Sintaxe");
			System.out.println("PaisesDAO.filtracomLocalEPermissao()" + e);
		}			
		return j;		
	}
	
	public String buscaDDIPorCod_pais(PaisesForm pais){
		sql = "select cod_ddi from paises_iurd where cod_pais = ? ";
		try {
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1, pais.getCod_pais());
			rs = stmt.executeQuery();
	
			if (rs.next()) {
				retorno = rs.getString("cod_ddi");
			}			
	
			stmt.close();
			rs.close();
		} catch (SQLException e) {
			System.out.println("PaisesDAO.buscaDDIPorCod_pais()" + e);
		}
		return retorno;
	}
	
	public Boolean isPais(String cod_pais) throws SQLException {
		Boolean flag = false;
		sql = "select cod_pais, den_pais, cod_ddi, cod_language, for_data from paises_iurd where cod_pais = ?";
		try {
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1,cod_pais);
			rs = stmt.executeQuery();
			
			if(rs.next()){
				flag = true;
			}
			
			stmt.close();
			rs.close();
		}
		catch (Exception e) {
			System.out.println("PaisesDAO.isPais()" + e);
			stmt.close();
			rs.close();			
		}
		return flag;					
	}
	
	public JSONObject buscaPaisPorCodigo(PaisesForm pais) throws JSONException {
		sql = "select * from paises_iurd where cod_pais = ? and cod_language = ?";
		try {
			// prepared statement para insures
			stmt = connection.prepareStatement(sql);
			// seta os valores
			stmt.setString(1,pais.getCod_pais());
			stmt.setString(2,pais.getCod_language());
			rs = stmt.executeQuery();
			
			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");			
			
			if(rs.next()){
				j.put("data", s.toJson(rs));	
			};
			
			stmt.close();
			rs.close();
		} catch (SQLException e) {
			j.put("errorCode",302);
			j.put("errorDesc","Erro: PaisesDAO.buscaPaisPorCodigo(). Erro de Sintaxe");
			System.out.println("PaisesDAO.buscaPaisPorCodigo()" + e);
		}
		return j;
	}

	@Override
	public JSONObject seleciona(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}	
}

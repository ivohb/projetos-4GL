package main.java.com.aceex.roncador.connection;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.log4j.Logger;

public class ErroConexao {

	private static Properties properties = null;	
	private static BasicDataSource dataSource;
	private static String url;
	private static String driver;
	private static String user;
	private static String password;

	private static Logger log = Logger.getLogger(ErroConexao.class);

	public ErroConexao() {
		this.leArqProps();
		this.configConexao();

	}

    /**
     * adequa o númro de cnexões ativas para o establelecido
     * e retorna uma conexão do poll
     */
    public Connection getConexao(){
        try{
             return ErroConexao.dataSource.getConnection();
             
        }catch (SQLException sqle){
        	log.fatal("sqleErroConexao " + sqle.getMessage()+" "+sqle.getCause());
        }catch (Exception e){
        	log.fatal("eErroConexao  " + e.getMessage()+" "+e.getCause());
        }

        return null;

    }

	public synchronized void leArqProps(){  
	      if (properties == null) {  
	    	  lePropriedades();
	      }  
	   }  	

	private void lePropriedades() {
		
		try {		
			FileInputStream		fis	= null;
			fis = new FileInputStream(
				new File(new File(
					new File(System.getProperty("catalina.home")),"/conf"),"integracao.props"));

			properties = new Properties();
			properties.load(fis);
			
			if (properties.getProperty("url") != null) {
				url = properties.getProperty("url").toString();
			}
			if (properties.getProperty("driver") != null) {
				driver = properties.getProperty("driver").toString();
			}
			if (properties.getProperty("user") != null) {
				user = properties.getProperty("user").toString();
			}
			if (properties.getProperty("password") != null) {
				password = properties.getProperty("password").toString();
			}

			fis.close();	
		} catch (Exception e) {			
			log.fatal("Erro ao carregar o arquivo sql.props");
			e.printStackTrace();
		}

	}
	
    private void configConexao(){
    	
    	if(dataSource == null){
    		ErroConexao.dataSource = new BasicDataSource();
    		ErroConexao.dataSource.setDriverClassName(driver);
    		ErroConexao.dataSource.setUsername(user);
    		ErroConexao.dataSource.setPassword(password);
    		ErroConexao.dataSource.setUrl(url);
    		//Seta o pool para apenas uma conexão ativa
    		ErroConexao.dataSource.setInitialSize(1);
    		//Obriga o pool a ter pelo menos uma conexão sempre ativa
    		ErroConexao.dataSource.setMinIdle(1);
    		//SqlConecta.dataSource.setMaxActive(500);
    		ErroConexao.dataSource.setMinEvictableIdleTimeMillis(6000000);
    		//Habilita o teste da conexão antes de retorná-la
    		ErroConexao.dataSource.setTestOnReturn(true);
    		// remove conexoes abondonadas
    		ErroConexao.dataSource.setRemoveAbandoned(true); 
    		// remove as conexoes abondonadas depois de determinado tempo 
    		ErroConexao.dataSource.setRemoveAbandonedTimeout(30);
    	}
    }

}

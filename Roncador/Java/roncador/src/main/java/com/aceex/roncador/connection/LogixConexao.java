package main.java.com.aceex.roncador.connection;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.log4j.Logger;

public class LogixConexao {

	private static Properties properties = null;	
	private static BasicDataSource dataSource;
	private static String url;
	private static String driver;
	private static String user;
	private static String password;

	private static Logger log = Logger.getLogger(LogixConexao.class);

	public LogixConexao() {
		this.leArqProps();
		this.configConexao();

	}

    /**
     * adequa o númro de cnexões ativas para o establelecido
     * e retorna uma conexão do poll
     */
    public Connection getConexao(){
        try{
             return LogixConexao.dataSource.getConnection();
             
        }catch (SQLException sqle){
        	log.fatal("sqleLogixConexao " + sqle.getMessage()+" "+sqle.getCause());
        }catch (Exception e){
        	log.fatal("eLogixConexao  " + e.getMessage()+" "+e.getCause());
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
					new File(System.getProperty("catalina.home")),"/conf"),"logix.props"));

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
    		LogixConexao.dataSource = new BasicDataSource();
    		LogixConexao.dataSource.setDriverClassName(driver);
    		LogixConexao.dataSource.setUsername(user);
    		LogixConexao.dataSource.setPassword(password);
    		LogixConexao.dataSource.setUrl(url);
    		//Seta o pool para apenas uma conexão ativa
    		LogixConexao.dataSource.setInitialSize(1);
    		//Obriga o pool a ter pelo menos uma conexão sempre ativa
    		LogixConexao.dataSource.setMinIdle(1);
    		//SqlConecta.dataSource.setMaxActive(500);
    		LogixConexao.dataSource.setMinEvictableIdleTimeMillis(6000000);
    		//Habilita o teste da conexão antes de retorná-la
    		LogixConexao.dataSource.setTestOnReturn(true);
    		// remove conexoes abondonadas
    		LogixConexao.dataSource.setRemoveAbandoned(true); 
    		// remove as conexoes abondonadas depois de determinado tempo 
    		LogixConexao.dataSource.setRemoveAbandonedTimeout(30);
    	}
    }

}

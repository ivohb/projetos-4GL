<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.4.custom.min.js"></script>
<script type="text/javascript" src="js/jquery.maskedinput-1.2.2.js"></script>
<script type="text/javascript" src="js/jquery.alphanumeric.pack.js"></script>
<script type="text/javascript">
///////////
	function cadastra() {

		var JSonPais = {
				        "cod_pais": "199",
				        "for_data": "DD/MM/AAAA",
				        "cod_ddi": "55",
				        "den_pais": {
				            "en-us": "BRAZIL",
				            "es-es": "BRAZIL",
				            "fr-fr": "BRAZIL",
				            "pt-br": "BRASILsss"
				        }
		        };
		
		$.ajax( {
			type : 'POST',
			url : 'paises.do',
			data : {
			    acao: 0,
			    pais: JSON.stringify(JSonPais),
			    token:"9y2InJIZNXZn6oCoJ/MC3CpacZEUliMM",
			    api_key: "C66C73A75E725F35F1DD6E7519AC20BE",
			    cod_language: "pt-br"
			},
			dataType : 'json',

			async : false,
			success : function(data) {
				alert(data.data);
			},
			error : function(data) {
				alert(data.data);
			}
		});
	}
	
	function listar() {
		$.ajax( {
			type : 'POST',
			url : 'paises.do',
			data : {"acao": 3,"cod_language":"pt-br","token": "9y2InJIZNXZn6oCoJ/MC3CpacZEUliMM",api_key:'C66C73A75E725F35F1DD6E7519AC20BE',
				cod_language:'pt-br'},		
			dataType : 'json',

			async : false,
			success : function(data) {
				alert(JSON.stringify(data));
			},
			error : function(data) {
				alert(data);
			}
		});		
	}		
	
	function buscar() {
		$.ajax( {
			type : 'POST',
			url : 'paises.do',
			data : {acao: 2,
					cod_pais:"001",
					token: "9y2InJIZNXZn6oCoJ/MC3CpacZEUliMM",
					api_key:'C66C73A75E725F35F1DD6E7519AC20BE',
					cod_language:'pt-br'},			
			dataType : 'json',

			async : false,
			success : function(data) {
				alert(JSON.stringify(data));
			},
			error : function(data) {
				alert(data);
			}
		});		
	}	
	
	function estrutura() {
		$.ajax( {
			type : 'POST',
			url : 'paises.do',
			data : {"acao": 99,"cod_language":"pt-br","token": "9y2InJIZNXZn6oCoJ/MC3CpacZEUliMM",api_key:'C66C73A75E725F35F1DD6E7519AC20BE',
				cod_language:'pt-br'},		
			dataType : 'json',

			async : false,
			success : function(data) {
				alert(JSON.stringify(data));
			},
			error : function(data) {
				alert(data);
			}
		});		
	}		
	</script>
<title>Insert title here</title>
</head>
<body>
<div><a href="#" onclick=cadastra();>cadastrar</a></div><br>
<div><a href="#" onclick=buscar();>buscar</a></div><br>
<div><a href="#" onclick=listar();>listar</a></div><br>
<div><a href="#" onclick=estrutura();>estrutura</a></div><br>
</body>
</html>
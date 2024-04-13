<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>

<html>
<head>
<meta charset="UTF-8">
<title>Consulta de Produtos</title>
<link rel="stylesheet" href="./css/styles.css">
</head>
<body>
	<div>
		<jsp:include page="menu.jsp" />
	</div>

	<br />

	<div align="center" class="container">
		<form action="consulta" method="post">
			<p class="title">
				<b>Consulta</b>
			</p>

			<table>
				<tr>
					<td colspan="4" style="text-align: center;"><label
						for="codigo"
						style="display: inline-block; width: 30%; text-align: right;">Valor
							de Entrada:</label> <input class="input_data_id" type="number" min="0"
						step="1" id="valorEntrada" name="valorEntrada"
						placeholder="Valor Entrada" required
						style="display: inline-block; width: 30%;"> <input
						type="submit" id="botao" name="botao" value="Consultar"
						style="display: inline-block;"></td>
				</tr>
			</table>
		</form>



		<h2>Resultado da Consulta:</h2>

		<div align="center">
			<c:if test="${not empty erro}">
				<p style="color: red;">
					<c:out value="${erro }" />
				</p>
			</c:if>
		</div>

		<br />

		<div align="center">
			<c:if test="${not empty produtos}">
				<table class="table_round">
					<thead>
						<tr>
							<th>Código</th>
							<th>Nome</th>
							<th>Qtd Estoque</th>

						</tr>
					</thead>
					<tbody>
						<c:forEach var="produto" items="${produtos}">
							<tr>

								<td><c:out value="${produto.codigo }" /></td>
								<td><c:out value="${produto.nome }" /></td>
								<td><c:out value="${produto.qtdEstoque }" /></td>

							</tr>
						</c:forEach>
					</tbody>
				</table>
				<div align="center">
					<div align="center">
						<div align="center">
							<h3>Quantidade de Produtos Abaixo do valor de "${param.valorEntrada}" é igual a
								 ${qtdEstoque}</h3>
						</div>

					</div>

				</div>
			</c:if>
		</div>
	</div>
</body>
</html>

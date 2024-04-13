package br.edu.fateczl.CRUDProdutos.persistence;

import java.sql.SQLException;
import java.util.List;

import br.edu.fateczl.CRUDProdutos.model.Produto;


public interface IConsultaDao {
	
	public List<Produto> listarProduto(int valor) throws SQLException, ClassNotFoundException;
	public int calcularQtdProdutos(int QtdProdutos) throws SQLException, ClassNotFoundException;

}

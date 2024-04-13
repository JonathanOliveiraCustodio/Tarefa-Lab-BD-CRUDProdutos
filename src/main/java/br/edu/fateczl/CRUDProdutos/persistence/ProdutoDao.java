package br.edu.fateczl.CRUDProdutos.persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Repository;
import br.edu.fateczl.CRUDProdutos.model.Produto;

@Repository
public class ProdutoDao implements ICrud<Produto>, IProdutoDao,IConsultaDao {

	private GenericDao gDao;

	public ProdutoDao(GenericDao gDao) {
		this.gDao = gDao;
	}

	@Override
	public Produto consultar(Produto p) throws SQLException, ClassNotFoundException {
		Connection c = gDao.getConnection();
		String sql = "SELECT codigo, nome, valorUnitario,qtdEstoque FROM produto WHERE codigo = ?";
		PreparedStatement ps = c.prepareStatement(sql);
		ps.setInt(1, p.getCodigo());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {
			p.setCodigo(rs.getInt("codigo"));
			p.setNome(rs.getString("nome"));
			p.setValorUnitario(rs.getFloat("valorUnitario"));
			p.setQtdEstoque(rs.getInt("qtdEstoque"));
		}
		rs.close();
		ps.close();
		c.close();
		return p;
	}

	@Override
	public List<Produto> listar() throws SQLException, ClassNotFoundException {

		List<Produto> produtos = new ArrayList<>();
		Connection c = gDao.getConnection();
		String sql = "SELECT * FROM fn_produtos()";
		PreparedStatement ps = c.prepareStatement(sql);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			Produto p = new Produto();
			p.setCodigo(rs.getInt("codigoProduto"));
			p.setNome(rs.getString("nomeProduto"));
			p.setValorUnitario(rs.getFloat("valorUnitarioProduto"));
			p.setQtdEstoque(rs.getInt("qtdEstoqueProduto"));
			produtos.add(p);
		}
		rs.close();
		ps.close();
		c.close();
		return produtos;
	}

	@Override
	public String iudProduto(String acao, Produto p) throws SQLException, ClassNotFoundException {
		Connection c = gDao.getConnection();
		String sql = "{CALL sp_iud_produto (?,?,?,?,?,?)}";
		CallableStatement cs = c.prepareCall(sql);
		cs.setString(1, acao);
		cs.setInt(2, p.getCodigo());
		cs.setString(3, p.getNome());
	    cs.setFloat(4, p.getValorUnitario());
	    cs.setInt(5, p.getQtdEstoque());
		cs.registerOutParameter(6, Types.VARCHAR);
		cs.execute();
		String saida = cs.getString(6);
		cs.close();
		c.close();

		return saida;
	}

	//Listar Comum do ICRUD
	@Override
	public List<Produto> listarProduto() throws SQLException, ClassNotFoundException {
		List<Produto> produtos = new ArrayList<>();
		Connection c = gDao.getConnection();
		String sql = "SELECT codigo, nome, valorUnitario, qtdEstoque FROM fn_produtos()";
		PreparedStatement ps = c.prepareStatement(sql);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			Produto p = new Produto();
			p.setCodigo(rs.getInt("codigo"));
			p.setNome(rs.getString("nome"));
			p.setValorUnitario(rs.getFloat("valorUnitario"));
			p.setQtdEstoque(rs.getInt("qtdEstoque"));
			produtos.add(p);
		}
		rs.close();
		ps.close();
		c.close();
		return produtos;
	}
	// Listar da Consulta
	@Override
	public List<Produto> listarProduto(int valor) throws SQLException, ClassNotFoundException {
	    List<Produto> produtos = new ArrayList<>();
	    Connection con = gDao.getConnection();
	    StringBuffer sql = new StringBuffer();

	    sql.append("SELECT codigo, nome, qtdEstoque ");
	    sql.append("FROM dbo.fn_produtosEstoque(?)");

	    PreparedStatement ps = con.prepareStatement(sql.toString());
	    ps.setInt(1, valor);
	    ResultSet rs = ps.executeQuery();

	    while (rs.next()) {
	        Produto produto = new Produto();
	        produto.setCodigo(rs.getInt("codigo"));
	        produto.setNome(rs.getString("nome"));
	        produto.setQtdEstoque(rs.getInt("qtdEstoque"));
	        
	        produtos.add(produto);
	    }
	    rs.close();
	    ps.close();
	    con.close();

	    return produtos;
	}


	@Override
	public int calcularQtdProdutos(int QtdProdutos) throws SQLException, ClassNotFoundException {
	    Connection con = gDao.getConnection();
	    String sql = "{ ? = call fn_quantidadeEstoque(?) }";
	    CallableStatement cs = con.prepareCall(sql);
	    cs.registerOutParameter(1, Types.INTEGER);
	    cs.setInt(2, QtdProdutos);
	    cs.execute();
	    int qtdProdutosAbaixo = cs.getInt(1);
	    cs.close();
	    con.close();
	    return qtdProdutosAbaixo;
	}

}
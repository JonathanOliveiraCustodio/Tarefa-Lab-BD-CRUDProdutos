package br.edu.fateczl.CRUDProdutos.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import br.edu.fateczl.CRUDProdutos.model.Produto;
import br.edu.fateczl.CRUDProdutos.persistence.GenericDao;
import br.edu.fateczl.CRUDProdutos.persistence.ProdutoDao;


@Controller
public class ProdutoController {

	@Autowired
	GenericDao gDao;

	@Autowired
	ProdutoDao pDao;

	@RequestMapping(name = "produto", value = "/produto", method = RequestMethod.GET)
	public ModelAndView indexGet(@RequestParam Map<String, String> allRequestParam, ModelMap model) {

		String cmd = allRequestParam.get("cmd");
		String codigo = allRequestParam.get("codigo");

		if (cmd != null) {
			Produto p = new Produto();
			p.setCodigo(Integer.parseInt(codigo));

			String saida = "";
			String erro = "";
			List<Produto> produtos = new ArrayList<>();

			try {
				if (cmd.contains("alterar")) {
					p = buscarProduto(p);
				} else if (cmd.contains("excluir")) {
					saida = excluirProduto(p);
				}

				produtos = listarProdutos();

			} catch (SQLException | ClassNotFoundException e) {
				erro = e.getMessage();
			} finally {

				model.addAttribute("saida", saida);
				model.addAttribute("erro", erro);
				model.addAttribute("produto", p);
				model.addAttribute("produtos", produtos);
		
			}
		}
		return new ModelAndView("produto");
	}

	@RequestMapping(name = "produto", value = "/produto", method = RequestMethod.POST)
	public ModelAndView indexPost(@RequestParam Map<String, String> allRequestParam, ModelMap model) {

		String cmd = allRequestParam.get("botao");
		String codigo = allRequestParam.get("codigo");
		String nome = allRequestParam.get("nome");
		String valorUnitario = allRequestParam.get("valorUnitario");
		String qtdEstoque = allRequestParam.get("qtdEstoque");

		// Saida
		String saida = "";
		String erro = "";
		Produto p = new Produto();
		List<Produto> produtos = new ArrayList<>();

		if (!cmd.contains("Listar")) {
			p.setCodigo(Integer.parseInt(codigo));
		}
		if (cmd.contains("Cadastrar") || cmd.contains("Alterar")) {
			p.setNome(nome);
			p.setValorUnitario(Float.parseFloat(valorUnitario));
			p.setQtdEstoque(Integer.parseInt(qtdEstoque));
		}

		try {
			if (cmd.contains("Cadastrar")) {
				saida = cadastrarProduto(p);
				p = null;
			}
			if (cmd.contains("Alterar")) {
				saida = alterarProduto(p);
				p = null;
			}
			if (cmd.contains("Excluir")) {
				saida = excluirProduto(p);
				p = null;
			}
			if (cmd.contains("Buscar")) {
				p = buscarProduto(p);
			}
			if (cmd.contains("Listar")) {
				produtos = listarProdutos();
			}

		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			model.addAttribute("saida", saida);
			model.addAttribute("erro", erro);
			model.addAttribute("produto", p);
			model.addAttribute("produtos", produtos);
		}

		return new ModelAndView("produto");
	}

	private String cadastrarProduto(Produto p) throws SQLException, ClassNotFoundException {
		String saida = pDao.iudProduto("I", p);
		return saida;

	}

	private String alterarProduto(Produto p) throws SQLException, ClassNotFoundException {
		String saida = pDao.iudProduto("U", p);
		return saida;

	}

	private String excluirProduto(Produto p) throws SQLException, ClassNotFoundException {
		Float valorUnitario = (p.getValorUnitario() != null) ? p.getValorUnitario().floatValue() : 0.0f;
	    p.setValorUnitario(valorUnitario);
	    String saida = pDao.iudProduto("D", p);
	    return saida;
	}

	private Produto buscarProduto(Produto p) throws SQLException, ClassNotFoundException {
		p = pDao.consultar(p);
		return p;

	}

	private List<Produto> listarProdutos() throws SQLException, ClassNotFoundException {
		List<Produto> professores = pDao.listar();
		return professores;
	}

}
USE master
CREATE DATABASE aulafunction
GO

USE aulafunction 

GO
CREATE TABLE funcionario ( 
codigo			INT			 NOT NULL, 
nome			VARCHAR(50)  NULL,
salario			DECIMAL(7,2) NULL
PRIMARY KEY (codigo)
)
GO

CREATE TABLE dependente(
codigo		INT			 NOT NULL, 
nome			VARCHAR(50)   NULL, 
salario		DECIMAL(7,2)  NULL,
funcionario		INT			 NULL 
PRIMARY KEY (codigo)
FOREIGN KEY (funcionario) REFERENCES funcionario(codigo) 
)
GO

INSERT INTO funcionario (codigo, nome, salario)
VALUES
    (1, 'Jo�o Silva', 5450.0),
    (2, 'Maria Oliveira', 3150.0),
    (3, 'Carlos Santos', 4800.0),
    (4, 'Ana Pereira', 1800.00),
    (5, 'Paulo Oliveira', 2000.50),
    (6, 'Juliana Martins', 5100.32),
    (7, 'Lucas Silva', 4900.00),
    (8, 'Mariana Santos', 5400.00),
    (9, 'Pedro Oliveira', 4700.00),
    (10, 'Camila Martins', 1600.00);

INSERT INTO dependente VALUES
    (1, 'Jo�o Silva Filho', 150.00, 1),
    (2, 'Maria Oliveira Filha', 990.00, 1),
    (3, 'Pedro Santos Filho', 975.00, 1),
    (4, 'Ana Costa Filha', 203.00, 2),
    (5, 'Carlos Pereira Filho', 500.00, 3),
    (6, 'Lu�sa Martins Filha', 460.00, 4),
    (7, 'Lucas Fernandes Filho', 950.00, 5),
    (8, 'Mariana Almeida Filha', 860.00, 6),
    (9, 'Rafael Lima Filho', 120.00, 7),
    (10, 'Tatiane Souza Filha', 100.00, 8);

--1. Criar uma database, criar as tabelas abaixo, definindo o tipo de dados e a rela��o PK/FK e popular com alguma massa de dados de teste (Suficiente para testar UDFs)
--Funcion�rio (C�digo, Nome, Sal�rio)
--Dependendente (C�digo_Dep, C�digo_Funcion�rio, Nome_Dependente, Sal�rio_Dependente)
--a) C�digo no Github ou Pastebin de uma Function que Retorne uma tabela:
--(Nome_Funcion�rio, Nome_Dependente, Sal�rio_Funcion�rio, Sal�rio_Dependente)

CREATE FUNCTION fn_funcionarios_dependentes()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.codigo AS codigoDependente, 
        f.codigo AS codigoFuncionario,
        f.nome AS nomeFuncionario,
        d.nome AS nomeDependente,
		d.salario AS salarioDependente,
		f.salario AS salarioFuncionario
    FROM funcionario f 
    INNER JOIN dependente d ON f.codigo = d.funcionario
);

SELECT * FROM fn_funcionarios_dependentes()


CREATE FUNCTION fn_consultar_funcionarios_dependentes(@codigoFuncionario INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.codigo AS codigoDependente, 
        f.codigo AS codigoFuncionario,
        f.nome AS nomeFuncionario,
        d.nome AS nomeDependente,
		d.salario AS salarioDependente,
		f.salario AS salarioFuncionario
    FROM 
        funcionario f 
    INNER JOIN 
        dependente d ON f.codigo = d.funcionario
    WHERE
        f.codigo = @codigoFuncionario
);

SELECT * FROM fn_consultar_funcionarios_dependentes(1);



--b) C�digo no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Sal�rios dos dependentes, mais a do funcion�rio. 

CREATE FUNCTION fn_soma_salario (@codigoFuncionario INT)
RETURNS DECIMAL(7,2)
AS
BEGIN
    DECLARE @totalSalario DECIMAL(7,2);

    SELECT @totalSalario = ISNULL(SUM(d.salario), 0) + ISNULL(f.salario, 0)
    FROM funcionario f
    LEFT JOIN dependente d ON f.codigo = d.funcionario
    WHERE f.codigo = @codigoFuncionario
    GROUP BY f.salario;

    RETURN @totalSalario;
END;

SELECT dbo.fn_soma_salario(4) AS "Soma Salarios"

CREATE PROCEDURE sp_iud_funcionario 
    @acao CHAR(1), 
    @codigo INT, 
    @nome VARCHAR(50), 
    @salario DECIMAL(7,2),
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF (@acao = 'I')
    BEGIN
        INSERT INTO funcionario (codigo, nome, salario) 
        VALUES (@codigo, @nome, @salario)
        SET @saida = 'Funcion�rio inserido com sucesso'
    END
    ELSE IF (@acao = 'U')
    BEGIN
        UPDATE funcionario 
        SET nome = @nome, salario = @salario
        WHERE codigo = @codigo
        SET @saida = 'Funcion�rio alterado com sucesso'
    END
    ELSE IF (@acao = 'D')
    BEGIN
        IF EXISTS (SELECT 1 FROM funcionario WHERE codigo = @codigo)
        BEGIN
            DELETE FROM funcionario WHERE codigo = @codigo
            SET @saida = 'Funcion�rio exclu�do com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Funcion�rio n�o encontrado'
        END
    END
    ELSE
    BEGIN
        RAISERROR('Opera��o inv�lida', 16, 1)
        RETURN
    END
END

CREATE PROCEDURE sp_iud_dependente 
    @acao CHAR(1), 
    @codigo INT, 
    @nome VARCHAR(50), 
    @salario DECIMAL(7,2),
    @funcionario INT,
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF (@acao = 'I')
    BEGIN
        INSERT INTO dependente(codigo, nome, salario, funcionario) 
        VALUES (@codigo, @nome, @salario, @funcionario)
        SET @saida = 'Dependente inserido com sucesso'
    END
    ELSE IF (@acao = 'U')
    BEGIN
        UPDATE dependente 
        SET nome = @nome, salario = @salario, funcionario = @funcionario
        WHERE codigo = @codigo
        SET @saida = 'Dependente alterado com sucesso'
    END
    ELSE IF (@acao = 'D')
    BEGIN
        IF EXISTS (SELECT 1 FROM dependente WHERE codigo = @codigo)
        BEGIN
            DELETE FROM dependente WHERE codigo = @codigo
            SET @saida = 'Dependente exclu�do com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Dependente n�o encontrado'
        END
    END
    ELSE
    BEGIN
        RAISERROR('Opera��o inv�lida', 16, 1)
        RETURN
    END
END

CREATE FUNCTION fn_produtos()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.codigo AS codigoProduto,
        p.nome AS nomeProduto,
        p.valorUnitario AS valorUnitarioProduto,
        p.qtdEstoque AS qtdEstoqueProduto
    FROM produto p
);

SELECT * FROM fn_produtos();
SELECT * FROM fn_funcionarios_dependentes();



CREATE TABLE produto(
codigo					INT			NOT NULL, 
nome					VARCHAR(30) NOT NULL,
valorUnitario			DECIMAL(7,2)NOT NULL,
qtdEstoque				INT			NOT NULL
PRIMARY KEY (codigo)
)
GO
INSERT INTO produto VALUES
(1, 'Smart TV', 1299.99, 50),
(2, 'Notebook', 2399.00, 30),
(3, 'Forno Micro-ondas', 299.90, 80),
(4, 'Liquidificador', 79.99, 100),
(5, 'Geladeira', 2599.00, 20),
(6, 'M�quina de Lavar Roupa', 1899.99, 40),
(7, 'Aspirador de P�', 159.50, 70),
(8, 'Secador de Cabelo', 49.90, 60),
(9, 'C�mera Fotogr�fica', 899.00, 15),
(10, 'Console de Videogame', 499.99, 25),
(11, 'Roteador Wi-Fi', 89.90, 55),
(12, 'Fone de Ouvido Bluetooth', 129.99, 85),
(13, 'Tablet', 349.00, 45),
(14, 'Monitor de Computador', 299.90, 35),
(15, 'Caixa de Som Bluetooth', 79.99, 75),
(16, 'Ventilador', 129.90, 90),
(17, 'C�mera de Seguran�a', 199.00, 10),
(18, 'Carregador Port�til', 39.90, 65),
(19, 'Impressora', 199.99, 30),
(20, 'Forno El�trico', 399.90, 20);
GO

CREATE PROCEDURE sp_iud_produto 
    @acao CHAR(1), 
    @codigo INT, 
    @nome VARCHAR(30), 
    @valorUnitario DECIMAL(7,2),
    @qtdEstoque INT,
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF (@acao = 'I')
    BEGIN
        IF EXISTS (SELECT 1 FROM produto WHERE codigo = @codigo)
        BEGIN
            SET @saida = 'Erro: Produto j� existe com o c�digo especificado'
            RETURN
        END
        ELSE
        BEGIN
            INSERT INTO produto (codigo, nome, valorUnitario, qtdEstoque) 
            VALUES (@codigo, @nome, @valorUnitario, @qtdEstoque)
            SET @saida = 'Produto inserido com sucesso'
        END
    END
    ELSE IF (@acao = 'U')
    BEGIN
        IF EXISTS (SELECT 1 FROM produto WHERE codigo = @codigo)
        BEGIN
            UPDATE produto 
            SET nome = @nome, valorUnitario = @valorUnitario, qtdEstoque = @qtdEstoque
            WHERE codigo = @codigo
            SET @saida = 'Produto alterado com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Erro: Produto n�o encontrado para altera��o'
            RETURN
        END
    END
    ELSE IF (@acao = 'D')
    BEGIN
        IF EXISTS (SELECT 1 FROM produto WHERE codigo = @codigo)
        BEGIN
            DELETE FROM produto WHERE codigo = @codigo
            SET @saida = 'Produto exclu�do com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Erro: Produto n�o encontrado para exclus�o'
            RETURN
        END
    END
    ELSE
    BEGIN
        SET @saida = 'Erro: Opera��o inv�lida'
        RETURN
    END
END

--a) a partir da tabela Produtos (codigo, nome, valor unit�rio e qtd estoque), quantos produtos est�o com estoque abaixo de um valor de entrada
CREATE FUNCTION fn_quantidadeEstoque (@qtdMinima INT)
RETURNS INT
AS
BEGIN
    DECLARE @qtdEstoqueAbaixo INT;

    SELECT @qtdEstoqueAbaixo = COUNT(*)
    FROM produto
    WHERE qtdEstoque < @qtdMinima;

    RETURN @qtdEstoqueAbaixo;
END;

SELECT dbo.fn_quantidadeEstoque(40) AS "Quantidade Estoque"

--b) Uma tabela com o c�digo, o nome e a quantidade dos produtos que est�o com o estoque abaixo de um valor de entrada

CREATE FUNCTION fn_produtosEstoque (@valor INT)
RETURNS TABLE
AS
RETURN (
    SELECT codigo, nome, qtdEstoque
    FROM produto
    WHERE qtdEstoque < @valor
);

SELECT * FROM dbo.fn_produtosEstoque(16)

--3. Criar, uma UDF, que baseada nas tabelas abaixo, retorne
--Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje
--Tabelas iniciais:
--Cliente (Codigo, nome)
--Produto (Codigo, nome, valor)


CREATE TABLE cliente (
    codigo INT,
    nome VARCHAR(50)
	PRIMARY KEY (codigo)
)
GO

CREATE TABLE produto1 (
    codigo INT ,
    nome VARCHAR(50),
    valor DECIMAL(7,2)
	
)
GO

CREATE TABLE venda (
    cliente INT,
    produto INT,
    qtd INT,
    dataCompra DATE,
    FOREIGN KEY (cliente) REFERENCES cliente(Codigo),
    FOREIGN KEY (produto) REFERENCES produto(Codigo)
)
GO

CREATE FUNCTION fn_calculo()
RETURNS @tabela TABLE (
Nome_cliente VARCHAR(100),
Nome_produto VARCHAR(100),
qtd_p INT,
valot_tot DECIMAL(10, 2),
data_hoje DATE
) 
BEGIN
 
    INSERT INTO @tabela(Nome_cliente, Nome_produto, qtd_p, valot_tot, data_hoje )
	     SELECT C.nome, P.Nome, COUNT(P.Codigo) AS qtd_p, SUM(p.valorUnitario) AS valor_tot, GETDATE() as data_hoje
		 FROM Cliente C
		 INNER JOIN produto p ON p.codigo = c.codigo
		 GROUP BY c.nome, p.nome;
		 RETURN
END
 SELECT * FROM fn_calculo()





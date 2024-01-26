use uc4atividades;

/* CONSULTA 1 - RELATÓRIO DE VENDAS EM DINHEIRO */
-- Consulta original --
SELECT *
FROM venda v, item_venda iv, produto p, cliente c, funcionario f
WHERE v.id = iv.venda_id
    AND c.id = v.cliente_id
    AND p.id = iv.produto_id
    AND f.id = v.funcionario_id
    AND tipo_pagamento = 'D';
    
-- Consulta otimizada com JOINs explícitos e seleção de colunas --
SELECT v.data, v.valor_total,
       p.nome AS NomeProduto, iv.quantidade, iv.valor_unitario,
       c.nome AS NomeCliente, c.cpf, c.telefone
FROM venda v
JOIN item_venda iv ON v.id = iv.venda_id
JOIN produto p ON iv.produto_id = p.id
JOIN cliente c ON v.cliente_id = c.id
JOIN funcionario f ON v.funcionario_id = f.id
WHERE v.tipo_pagamento = 'D'
ORDER BY v.data DESC;

-- Criação de índices
CREATE INDEX idx_venda_tipo_pagamento ON venda (tipo_pagamento);



/* CONSULTA 2 - VENDAS DE PRODUTOS DE UM FRABRICANTE */
-- Consulta original --
SELECT *
FROM produto p, item_venda iv, venda v
WHERE p.id = iv.produto_id
    AND v.id = iv.venda_id
    AND p.fabricante LIKE '%lar%'
ORDER BY p.nome;


-- Consulta otimizada com JOINs explícitos e seleção de colunas --
SELECT p.nome AS NomeProduto, iv.quantidade, v.data
FROM produto p
JOIN item_venda iv ON p.id = iv.produto_id
JOIN venda v ON iv.venda_id = v.id
WHERE p.fabricante LIKE '%lar%'
ORDER BY p.nome;

-- Criação de índices --
CREATE INDEX idx_produto_fabricante ON produto (fabricante);



/* CONSULTA 3 - RELATÓRIO DE VENDAS DE PRODUTOS POR CLIENTE */
-- Consulta original --
SELECT SUM(iv.subtotal), SUM(iv.quantidade)
FROM produto p, item_venda iv, venda v, cliente c
WHERE p.id = iv.produto_id
    AND v.id = iv.venda_id
    AND c.id = v.cliente_id
GROUP BY c.nome, p.nome;

-- Consulta otimizada com JOINs explícitos e seleção de colunas --
SELECT c.nome AS NomeCliente, p.nome AS NomeProduto, 
       SUM(iv.subtotal) AS ValorTotal, SUM(iv.quantidade) AS QuantidadeTotal
FROM cliente c
JOIN venda v ON c.id = v.cliente_id
JOIN item_venda iv ON v.id = iv.venda_id
JOIN produto p ON iv.produto_id = p.id
GROUP BY c.nome, p.nome;


-- Criação de índices --
CREATE INDEX idx_cliente_nome ON cliente (nome);



/* CRIAÇÃO DE VIEWS PARA CADA COLUNA */

-- View para Consulta 1 --
CREATE VIEW RelatorioVendasPagasEmDinheiro AS
SELECT v.data, v.valor_total,
       p.nome AS NomeProduto, iv.quantidade, iv.valor_unitario,
       c.nome AS NomeCliente, c.cpf, c.telefone
FROM venda v
JOIN item_venda iv ON v.id = iv.venda_id
JOIN produto p ON iv.produto_id = p.id
JOIN cliente c ON v.cliente_id = c.id
JOIN funcionario f ON v.funcionario_id = f.id
WHERE v.tipo_pagamento = 'D'
ORDER BY v.data DESC;

-- View para Consulta 2 --
CREATE VIEW VendasPorFabricante AS
SELECT p.nome AS NomeProduto, iv.quantidade, v.data
FROM produto p
JOIN item_venda iv ON p.id = iv.produto_id
JOIN venda v ON iv.venda_id = v.id
WHERE p.fabricante LIKE '%lar%'
ORDER BY p.nome;

-- View para Consulta 3 --
CREATE VIEW RelatorioVendasPorCliente AS
SELECT c.nome AS NomeCliente, p.nome AS NomeProduto, 
       SUM(iv.subtotal) AS ValorTotal, SUM(iv.quantidade) AS QuantidadeTotal
FROM cliente c
JOIN venda v ON c.id = v.cliente_id
JOIN item_venda iv ON v.id = iv.venda_id
JOIN produto p ON iv.produto_id = p.id
GROUP BY c.nome, p.nome;
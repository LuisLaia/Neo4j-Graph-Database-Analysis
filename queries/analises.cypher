// Consulta 1 — Pares de produtos comprados na mesma encomenda, por cidade
MATCH (e:Encomenda)-[:ENVIADA_PARA]->(m:Morada),
      (e)-[:TEM_ITEM]->(p1:Produto),
      (e)-[:TEM_ITEM]->(p2:Produto)
WHERE p1.Product < p2.Product
WITH m.City AS Cidade, p1.Product AS Produto1, p2.Product AS Produto2,
     COUNT(*) AS Frequencia
ORDER BY Frequencia DESC
RETURN Cidade, Produto1, Produto2, Frequencia
LIMIT 20;

// Consulta 2 — Distribuição geográfica da procura por produto
MATCH (e:Encomenda)-[r:TEM_ITEM]->(p:Produto),
      (e)-[:ENVIADA_PARA]->(m:Morada)
WITH p.Product AS Produto, m.City AS Cidade, SUM(r.`Quantity Ordered`) AS QtdCidade
WITH Produto, collect({cidade:Cidade, qtd:QtdCidade}) AS Distribuicao,
     SUM(QtdCidade) AS TotalProduto
WHERE TotalProduto > 0
UNWIND Distribuicao AS d
RETURN Produto, d.cidade AS Cidade, d.qtd AS QuantidadeNaCidade,
       ROUND((toFloat(d.qtd) / TotalProduto) * 100, 2) AS PercentagemDoProduto
ORDER BY PercentagemDoProduto DESC
LIMIT 15;

// Consulta 3 — Top 3 produtos por cidade
MATCH (e:Encomenda)-[r:TEM_ITEM]->(p:Produto),
      (e)-[:ENVIADA_PARA]->(m:Morada)
WITH m.City AS Cidade, p.Product AS Produto,
     SUM(r.`Quantity Ordered`) AS TotalVendido
ORDER BY Cidade, TotalVendido DESC
WITH Cidade, collect({produto: Produto, total: TotalVendido})[0..3] AS Top3
RETURN Cidade, Top3;

-- Criar o banco de dados Cafe, se não existir
CREATE DATABASE IF NOT EXISTS Cafe;
USE Cafe;

-- Criação das tabelas
CREATE TABLE IF NOT EXISTS Cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    data_nascimento DATE
);

CREATE TABLE IF NOT EXISTS Pastel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Recheio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Pastel_Recheio (
    pastel_id INT,
    recheio_id INT,
    FOREIGN KEY (pastel_id) REFERENCES Pastel(id),
    FOREIGN KEY (recheio_id) REFERENCES Recheio(id),
    PRIMARY KEY (pastel_id, recheio_id)
);

CREATE TABLE IF NOT EXISTS Bebida (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ingrediente_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (ingrediente_id) REFERENCES Recheio(id)
);

CREATE TABLE IF NOT EXISTS Pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES Cliente(id)
);

CREATE TABLE IF NOT EXISTS Pedido_Item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    pastel_id INT,
    bebida_id INT,
    ingrediente_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES Pedido(id),
    FOREIGN KEY (pastel_id) REFERENCES Pastel(id),
    FOREIGN KEY (bebida_id) REFERENCES Bebida(id),
    FOREIGN KEY (ingrediente_id) REFERENCES Recheio(id)
);

-- Inserção de dados de exemplo
INSERT IGNORE INTO Cliente (nome, email, data_nascimento) VALUES
('João', 'joao@example.com', '1990-05-15'),
('Maria', 'maria@example.com', '1985-10-20'),
('Pedro', 'pedro@example.com', '1995-03-08'),
('Ana', 'ana@example.com', '1992-07-12'),
('Lucas', 'lucas@example.com', '1988-09-25'),
('Luke Skywalker', 'luke@starwars.com', '1977-05-25'),
('Leia Organa', 'leia@starwars.com', '1977-05-25'),
('Obi-Wan Kenobi', 'obiwan@starwars.com', '1960-05-25'),
('Jujutsu Kaisen', 'jujutsu@example.com', '2000-12-15'),
('Satoru Gojo', 'gojo@example.com', '1988-03-28'),
('Yuji Itadori', 'yuji@example.com', '2003-09-10'),
('Megumi Fushiguro', 'megumi@example.com', '2002-07-04');

INSERT INTO Pastel (nome, descricao, preco, categoria) VALUES
('Pastel de Carne', 'Delicioso pastel de carne moída', 3.50, 'Salgado'),
('Pastel de Queijo', 'Saboroso pastel com recheio de queijo', 3.00, 'Salgado'),
('Pastel de Chocolate', 'Irresistível pastel recheado com chocolate', 2.50, 'Doce');

INSERT INTO Recheio (nome) VALUES
('Carne'),
('Queijo'),
('Chocolate');

INSERT INTO Pastel_Recheio (pastel_id, recheio_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO Bebida (nome, preco) VALUES
('Café', 2.00),
('Suco de Laranja', 3.50),
('Água Mineral', 1.50),
('Refrigerante', 4.00),
('Chá Gelado', 2.50);

INSERT INTO Pedido (cliente_id, data_pedido) VALUES
(1, '2024-06-01 08:30:00'),
(2, '2024-06-02 12:15:00'),
(3, '2024-06-03 17:45:00');

INSERT INTO Pedido_Item (pedido_id, pastel_id, bebida_id, quantidade) VALUES
(1, 1, 1, 2),
(1, 2, NULL, 3),
(2, 3, 2, 1),
(3, 1, 4, 2),
(3, 3, 5, 1);

-- Função para calcular o total de um pedido
DELIMITER //
CREATE FUNCTION CalculaTotalPedido(pedido_id INT) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT SUM((p.preco * pi.quantidade) + COALESCE(b.preco, 0))
    INTO total
    FROM Pedido_Item pi
    LEFT JOIN Pastel p ON pi.pastel_id = p.id
    LEFT JOIN Bebida b ON pi.bebida_id = b.id
    WHERE pi.pedido_id = pedido_id;
    
    RETURN IFNULL(total, 0.00);
END//
DELIMITER ;

-- Função para listar os pasteis com recheio de bacon ou queijo
DELIMITER //
CREATE FUNCTION ListaPastelComBaconOuQueijo() RETURNS VARCHAR(255)
BEGIN
    DECLARE nomes_pastel VARCHAR(255);
    
    SELECT GROUP_CONCAT(p.nome SEPARATOR ', ')
    INTO nomes_pastel
    FROM Pastel p
    JOIN Pastel_Recheio pr ON p.id = pr.pastel_id
    JOIN Recheio r ON pr.recheio_id = r.id
    WHERE r.nome IN ('Carne', 'Queijo');
    
    RETURN IFNULL(nomes_pastel, 'Nenhum pastel possui carne ou queijo no recheio.');
END//
DELIMITER ;

-- Função para listar a quantidade de pedidos que incluem pasteis e bebidas
DELIMITER //
CREATE FUNCTION ListaPedidosPastelBebida() RETURNS INT
BEGIN
    DECLARE total_pedidos INT;
    
    SELECT COUNT(DISTINCT pedido_id)
    INTO total_pedidos
    FROM Pedido_Item
    WHERE pastel_id IS NOT NULL AND bebida_id IS NOT NULL;
    
    RETURN total_pedidos;
END//
DELIMITER ;

-- Função para obter o pastel mais vendido
DELIMITER //
CREATE FUNCTION PastelMaisVendido() RETURNS VARCHAR(255)
BEGIN
    DECLARE nome_pastel VARCHAR(255);
    
    SELECT nome
    INTO nome_pastel
    FROM (
        SELECT pastel_id, SUM(quantidade) AS total_vendas
        FROM Pedido_Item
        GROUP BY pastel_id
        ORDER BY total_vendas DESC
        LIMIT 1
    ) AS t
    JOIN Pastel p ON t.pastel_id = p.id;
    
    RETURN IFNULL(nome_pastel, 'Nenhum pastel vendido.');
END//
DELIMITER ;

-- Criação da visualização DetalhesPedido
CREATE VIEW DetalhesPedido AS
SELECT p.id AS pedido_id, c.nome AS nome_cliente, c.email AS email_cliente, c.data_nascimento AS data_nascimento_cliente,
       p.data_pedido, 
       SUM(pi.quantidade) AS total_itens, 
       GROUP_CONCAT(CONCAT(pi.quantidade, 'x ', pa.nome) SEPARATOR ', ') AS itens_pedido,
       CalculaTotalPedido(p.id) AS total_pedido
FROM Pedido p
JOIN Pedido_Item pi ON p.id = pi.pedido_id
JOIN Cliente c ON p.cliente_id = c.id
JOIN Pastel pa ON pi.pastel_id = pa.id
GROUP BY p.id, c.nome, c.email, c.data_nascimento, p.data_pedido;

-- Criação da visualização PastelInfo
CREATE VIEW PastelInfo AS
SELECT p.id, p.nome, p.descricao, p.preco, p.categoria,
       GROUP_CONCAT(r.nome SEPARATOR ', ') AS recheios
FROM Pastel p
JOIN Pastel_Recheio pr ON p.id = pr.pastel_id
JOIN Recheio r ON pr.recheio_id = r.id
GROUP BY p.id;

-- Criação da visualização RecheioInfo
CREATE VIEW RecheioInfo AS
SELECT pr.pastel_id, 
       GROUP_CONCAT(r.nome SEPARATOR ', ') AS recheios
FROM Pastel_Recheio pr
JOIN Recheio r ON pr.recheio_id = r.id
GROUP BY pr.pastel_id;

-- Criação da visualização Vendas
CREATE VIEW Vendas AS
SELECT p.data_pedido, pi.quantidade, 
       pa.nome AS nome_pastel, pa.descricao AS descricao_pastel, pa.preco AS preco_pastel, pa.categoria AS categoria_pastel, 
       r.recheios,
       b.nome AS nome_bebida, b.preco AS preco_bebida,
       CalculaTotalPedido(p.id) AS total_pedido
FROM Pedido p
JOIN Pedido_Item pi ON p.id = pi.pedido_id
LEFT JOIN Pastel pa ON pi.pastel_id = pa.id
LEFT JOIN RecheioInfo r ON r.pastel_id = pa.id
LEFT JOIN Bebida b ON pi.bebida_id = b.id;

-- Criação da visualização FaixaPrecoBebida
CREATE VIEW FaixaPrecoBebida AS
SELECT CASE 
        WHEN preco <= 2.00 THEN 'Até R$2.00'
        WHEN preco > 2.00 AND preco <= 3.00 THEN 'De R$2.01 a R$3.00'
        ELSE 'Acima de R$3.00'
    END AS Faixa_Preco,
    nome AS Nome_Bebida,
    SUM(pi.quantidade) AS Quantidade_Vendida
FROM Bebida b
JOIN Pedido_Item pi ON b.id = pi.bebida_id
GROUP BY Faixa_Preco, b.id
ORDER BY Faixa_Preco, Quantidade_Vendida DESC;

-- Consulta 1: DetalhesPedido
SELECT * FROM DetalhesPedido;

-- Consulta 2: PastelInfo
SELECT * FROM PastelInfo;

-- Consulta 3: RecheioInfo
SELECT * FROM RecheioInfo;

-- Consulta 4: Vendas
SELECT * FROM Vendas;

-- Consulta 5: ListaPastelComBaconOuQueijo()
SELECT ListaPastelComBaconOuQueijo() AS Pasteis_Com_Carne_Ou_Queijo;

-- Consulta 6: ListaPedidosPastelBebida()
SELECT ListaPedidosPastelBebida() AS Quantidade_Pedidos_Pasteis_Bebidas;

-- Consulta 7: PastelMaisVendido()
SELECT PastelMaisVendido() AS Pastel_Mais_Vendido;

-- Consulta 8: FaixaPrecoBebida
SELECT * FROM FaixaPrecoBebida;
CREATE DATABASE IF NOT EXISTS Cafe;
USE Cafe;

CREATE TABLE IF NOT EXISTS Cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    nome_chamado VARCHAR(255),
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(15),
    email VARCHAR(255) UNIQUE,
    bairro VARCHAR(255),
    cidade VARCHAR(255),
    estado VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS Pastel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50),
    tamanho VARCHAR(20)
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

INSERT IGNORE INTO Cliente (nome, nome_chamado, cpf, data_nascimento, telefone, email, bairro, cidade, estado) VALUES
('João Silva', 'João', '12345678901', '1990-05-15', '21987654321', 'joao@example.com', 'Centro', 'Rio de Janeiro', 'RJ'),
('Maria Souza', 'Maria', '23456789012', '1985-10-20', '21987654322', 'maria@example.com', 'Copacabana', 'Rio de Janeiro', 'RJ'),
('Pedro Santos', 'Pedro', '34567890123', '1995-03-08', '21987654323', 'pedro@example.com', 'Barra', 'Rio de Janeiro', 'RJ'),
('Ana Oliveira', 'Ana', '45678901234', '1992-07-12', '21987654324', 'ana@example.com', 'Botafogo', 'Rio de Janeiro', 'RJ');

INSERT INTO Pastel (nome, descricao, preco, categoria, tamanho) VALUES
('Pastel de Carne', 'Delicioso pastel de carne moída', 3.50, 'Salgado', 'Grande'),
('Pastel de Queijo', 'Saboroso pastel com recheio de queijo', 3.00, 'Salgado', 'Médio'),
('Pastel de Chocolate', 'Irresistível pastel recheado com chocolate', 2.50, 'Doce', 'Pequeno'),
('Pastel Vegano', 'Pastel com recheio de legumes e tofu', 4.00, 'Vegano', 'Grande');

INSERT INTO Recheio (nome) VALUES
('Carne'),
('Queijo'),
('Chocolate'),
('Legumes'),
('Tofu');

INSERT INTO Pastel_Recheio (pastel_id, recheio_id) VALUES
(1, 1), -- Pastel de Carne com Carne
(2, 2), -- Pastel de Queijo com Queijo
(3, 3), -- Pastel de Chocolate com Chocolate
(4, 4), -- Pastel Vegano com Legumes
(4, 5); -- Pastel Vegano com Tofu

INSERT INTO Bebida (nome, preco) VALUES
('Café', 2.00),
('Suco de Laranja', 3.50),
('Água Mineral', 1.50),
('Refrigerante', 4.00),
('Chá Gelado', 2.50);

INSERT INTO Pedido (cliente_id, data_pedido) VALUES
(1, '2024-06-01 08:30:00'),
(2, '2024-06-02 12:15:00'),
(3, '2024-06-03 17:45:00'),
(4, '2024-06-04 11:30:00');

INSERT INTO Pedido_Item (pedido_id, pastel_id, bebida_id, quantidade) VALUES
(1, 1, 1, 2), -- Pedido 1: 2 Pastéis de Carne e 1 Café
(1, 2, NULL, 3), -- Pedido 1: 3 Pastéis de Queijo
(2, 3, 2, 1), -- Pedido 2: 1 Pastel de Chocolate e 1 Suco de Laranja
(3, 1, 4, 2), -- Pedido 3: 2 Pastéis de Carne e 1 Refrigerante
(3, 3, 5, 1), -- Pedido 3: 1 Pastel de Chocolate e 1 Chá Gelado
(4, 4, 3, 1); -- Pedido 4: 1 Pastel Vegano e 1 Água Mineral

DELIMITER //
CREATE PROCEDURE RegistraCliente (
    IN p_nome VARCHAR(255),
    IN p_nome_chamado VARCHAR(255),
    IN p_cpf VARCHAR(11),
    IN p_data_nascimento DATE,
    IN p_telefone VARCHAR(15),
    IN p_email VARCHAR(255),
    IN p_bairro VARCHAR(255),
    IN p_cidade VARCHAR(255),
    IN p_estado VARCHAR(2)
)
BEGIN
    INSERT INTO Cliente (nome, nome_chamado, cpf, data_nascimento, telefone, email, bairro, cidade, estado)
    VALUES (p_nome, p_nome_chamado, p_cpf, p_data_nascimento, p_telefone, p_email, p_bairro, p_cidade, p_estado);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RegistraPedido (
    IN p_cliente_id INT,
    IN p_data_pedido DATETIME
)
BEGIN
    INSERT INTO Pedido (cliente_id, data_pedido)
    VALUES (p_cliente_id, p_data_pedido);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AdicionaItemPedido (
    IN p_pedido_id INT,
    IN p_pastel_id INT,
    IN p_bebida_id INT,
    IN p_quantidade INT
)
BEGIN
    INSERT INTO Pedido_Item (pedido_id, pastel_id, bebida_id, quantidade)
    VALUES (p_pedido_id, p_pastel_id, p_bebida_id, p_quantidade);
END //
DELIMITER ;

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
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION ListaPastelComBaconOuQueijo() RETURNS VARCHAR(255)
BEGIN
    DECLARE nomes_pastel VARCHAR(255);
    
    SELECT GROUP_CONCAT(p.nome SEPARATOR ', ')
    INTO nomes_pastel
    FROM Pastel p
    JOIN Pastel_Recheio pr ON p.id = pr.pastel_id
    JOIN Recheio r ON pr.recheio_id = r.id
    WHERE r.nome IN ('Bacon', 'Queijo');
    
    RETURN IFNULL(nomes_pastel, 'Nenhum pastel possui bacon ou queijo no recheio.');
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION ListaPedidosPastelBebida() RETURNS INT
BEGIN
    DECLARE total_pedidos INT;
    
    SELECT COUNT(DISTINCT pedido_id)
    INTO total_pedidos
    FROM Pedido_Item
    WHERE pastel_id IS NOT NULL AND bebida_id IS NOT NULL;
    
    RETURN total_pedidos;
END //
DELIMITER ;

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
    ) AS subquery
    JOIN Pastel p ON subquery.pastel_id = p.id;
    
    RETURN nome_pastel;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER VerificaEstoque
BEFORE INSERT ON Pedido_Item
FOR EACH ROW
BEGIN
    DECLARE qtd_estoque INT;
    IF NEW.ingrediente_id IS NOT NULL THEN
        SELECT quantidade INTO qtd_estoque
        FROM Estoque
        WHERE ingrediente_id = NEW.ingrediente_id;
        IF qtd_estoque < NEW.quantidade THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantidade insuficiente em estoque';
        END IF;
    END IF;
END //
DELIMITER ;

CREATE VIEW vw_pedidos_clientes AS
SELECT p.id AS pedido_id, c.nome AS cliente, p.data_pedido
FROM Pedido p
JOIN Cliente c ON p.cliente_id = c.id;

SELECT p.categoria, p.nome, COUNT(pi.id) AS total_vendido
FROM Pedido_Item pi
JOIN Pastel p ON pi.pastel_id = p.id
GROUP BY p.categoria, p.nome
ORDER BY p.categoria, total_vendido DESC;

SELECT c.nome, COUNT(p.id) AS total_pedidos
FROM Pedido p
JOIN Cliente c ON p.cliente_id = c.id
GROUP BY c.nome
ORDER BY total_pedidos DESC;

SELECT YEAR(p.data_pedido) AS ano, MONTH(p.data_pedido) AS mes, 
       SUM((pastel.preco * pi.quantidade) + COALESCE(b.preco, 0)) AS receita_total
FROM Pedido p
JOIN Pedido_Item pi ON p.id = pi.pedido_id
LEFT JOIN Pastel pastel ON pi.pastel_id = pastel.id
LEFT JOIN Bebida b ON pi.bebida_id = b.id
GROUP BY ano, mes
ORDER BY ano, mes;

SELECT p.nome, COUNT(pi.id) AS total_vendido
FROM Pedido_Item pi
JOIN Pastel p ON pi.pastel_id = p.id
GROUP BY p.nome
ORDER BY total_vendido DESC
LIMIT 10;

SELECT b.nome, COUNT(pi.id) AS total_vendido
FROM Pedido_Item pi
JOIN Bebida b ON pi.bebida_id = b.id
GROUP BY b.nome
ORDER BY total_vendido DESC
LIMIT 10;

SELECT p.categoria, SUM(p.preco * pi.quantidade) AS receita_total
FROM Pedido_Item pi
JOIN Pastel p ON pi.pastel_id = p.id
GROUP BY p.categoria
ORDER BY receita_total DESC;

SELECT c.nome, SUM((pastel.preco * pi.quantidade) + COALESCE(b.preco, 0)) AS receita_total
FROM Pedido p
JOIN Cliente c ON p.cliente_id = c.id
JOIN Pedido_Item pi ON p.id = pi.pedido_id
LEFT JOIN Pastel pastel ON pi.pastel_id = pastel.id
LEFT JOIN Bebida b ON pi.bebida_id = b.id
GROUP BY c.nome
ORDER BY receita_total DESC;

SELECT YEAR(p.data_pedido) AS ano, MONTH(p.data_pedido) AS mes, COUNT(p.id) AS total_pedidos
FROM Pedido p
GROUP BY ano, mes
ORDER BY ano, mes;

SELECT c.nome, COUNT(p.id) AS total_pedidos
FROM Pedido p
JOIN Cliente c ON p.cliente_id = c.id
GROUP BY c.nome
ORDER BY total_pedidos DESC;

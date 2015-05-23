CREATE VIEW  `category_has_node` AS
SELECT c.*, i.node_index 
FROM `category` AS c INNER JOIN `category_node_index` AS i
WHERE c.id = i.id;

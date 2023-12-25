CREATE DATABASE go_lang;

use go_lang;
SHOW TABLES;


DELIMITER //

	CREATE PROCEDURE add_node(IN parent_id NUMERIC, IN node_name VARCHAR(50))

BEGIN
	-- declaring variables 
	DECLARE parent_left NUMERIC;
	DECLARE tree_id_ VARCHAR(255);
	
	-- getting the left value and the tree_if and storing it in the parent_left and tree_id_ for furthure queries
	SELECT lft, employees.tree_id INTO parent_left, tree_id_ FROM employees WHERE name = parent_id;
	
	UPDATE employees SET rgt = rgt + 2 WHERE rgt > parent_left AND employees.tree_id = tree_id_;
	UPDATE employees SET lft = lft + 2 WHERE lft > parent_left AND employees.tree_id = tree_id_;
	
    INSERT INTO employees(name, lft, rgt, tree_id)
    VALUES (node_name, parent_left + 1, parent_left + 2, tree_id_);
END //

DELIMITER ;

drop table employees;

DROP PROCEDURE IF EXISTS add_node;

DELETE FROM employees;

SELECT * FROM employees;

SELECT COUNT(name) FROM employees;

SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION'; 

SELECT CONCAT( REPEAT( '-', (COUNT(parent.name) - 1) ), node.name) AS name
FROM employees AS node,
        employees AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
GROUP BY node.name
ORDER BY node.lft;

DROP DATABASE go_lang;

show variables like 'datadir';
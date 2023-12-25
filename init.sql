CREATE DATABASE directory;
CREATE DATABASE go_lang;
use directory;


show TABLES;

-- creating a table with the id. name with lft and right values of that node. We can't use left and right because it's a reserved keyword in mySQL.

CREATE TABLE IF NOT EXISTS nodes (
	id serial PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	lft NUMERIC NOT NULL,
	rgt NUMERIC NOT NULL,
    tree_id VARCHAR(255) NOT NULL
);

drop table nodes;

select * from nodes;

DELETE FROM nodes;

INSERT INTO nodes VALUES(1,'ELECTRONICS',1,20,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(2,'TELEVISIONS',2,9,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(3,'TUBE',3,4,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),
 (4,'LCD',5,6,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(5,'PLASMA',7,8,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(6,'PORTABLE ELECTRONICS',10,19,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(7,'MP3 PLAYERS',11,14,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(8,'FLASH',12,13,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),
 (9,'CD PLAYERS',15,16,'ea227dbb-f90d-47bc-bf99-f4c617c8db96'),(10,'2 WAY RADIOS',17,18,'ea227dbb-f90d-47bc-bf99-f4c617c8db96');

-- the below statement is a procedure. Procedure are named objects which execute one or more instructions in a sequence when called

-- DELIMITER command is used to temporarily change the delimiter from ; to // so that all the ; inside will be passed as it is to the server.
DELIMITER //

-- this creates the proecedure with create_root_node as the name which takes in name as the parameter.
CREATE PROCEDURE create_root_node(IN name VARCHAR(50))
-- marks the start of the procedure
BEGIN
    INSERT INTO nodes(`name`, `lft`, `rgt`, `tree_id`)
    VALUES (name, 1, 2, UUID());
-- marks the end of the procedure note that // is used since it's the delimiter now
END //
-- we are reverting the delimiter back to ;
DELIMITER ;

-- to delete the procedure
DROP PROCEDURE IF EXISTS create_root_node;

-- calls the procedure create_root_node with "top_boss" as it's name
CALL create_root_node("top_boss");


-- update all of the right values of the nodes where the right is bigger than the parent’s left  by 2
-- update all of the left values of the nodes where the left is bigger than the parent’s left  by 2
-- the new node left value will be the parent’s left + 1
-- the new node right value will be the parent’s right + 2
DELIMITER //

CREATE PROCEDURE add_node(IN parent_id NUMERIC, IN node_name VARCHAR(50))

BEGIN
	-- declaring variables 
	DECLARE parent_left NUMERIC;
	DECLARE tree_id_ VARCHAR(255);
	
	-- getting the left value and the tree_if and storing it in the parent_left and tree_id_ for furthure queries
	SELECT lft, nodes.tree_id INTO parent_left, tree_id_ FROM nodes WHERE id = parent_id;
	
	UPDATE nodes SET rgt = rgt + 2 WHERE rgt > parent_left AND nodes.tree_id = tree_id_;
	UPDATE nodes SET lft = lft + 2 WHERE lft > parent_left AND nodes.tree_id = tree_id_;
	
    INSERT INTO nodes(`name`, `lft`, `rgt`, `tree_id`)
    VALUES (node_name, parent_left + 1, parent_left + 2, tree_id_);
END //

DELIMITER ;


CALL add_node(8,"second_boss");

CALL add_node(11,"small boss");


-- to delete a branch
-- ! find the node's left and right values
-- ! create a variable that is equal to the right - left + 1
-- ! delete all of the nodes that their left and right is between the node's left and right
-- ! update the right values in the tree to be right - width where thier right is bigger the node's right
-- ! update the left values in the tree to be left - width where thier left is bigger the node's right

DELIMITER //

CREATE PROCEDURE remove_branch(node_id NUMERIC)

BEGIN
	DECLARE width NUMERIC;
	DECLARE node_rgt NUMERIC;
	DECLARE node_lft NUMERIC;
	DECLARE tree_id_ VARCHAR(255);
	
	
	SELECT `rgt` , `lft`, `rgt` - `lft` + 1, tree_id INTO node_rgt, node_lft, width, tree_id_ FROM nodes WHERE id = node_id;
	
	DELETE FROM nodes WHERE lft BETWEEN node_lft AND node_rgt and tree_id = tree_id_;
	
	UPDATE nodes SET `rgt` = `rgt` - width WHERE `rgt` > node_rgt and tree_id = tree_id_;
	UPDATE nodes SET `lft` = `lft` - width WHERE `lft` > node_rgt and tree_id = tree_id_;
END //

DELIMITER;


CALL remove_branch(6);



-- to delete a node and uplift its descendants
-- ! find the node's left and right values
-- ! delete the node by filtering on the left value
-- ! to uplift the descendants:
--      ! update the right values in the tree to be right - 1 and left to be left - 1 where their left is between the deleted node's left and right
-- ! update the right values in the tree to be right - 2 where their right is bigger than the deleted node's right
-- ! update the left values in the tree to be left - 2 where their left is bigger than the deleted node's right

DELIMITER //

CREATE PROCEDURE remove_node(node_id NUMERIC)

BEGIN
	DECLARE node_left NUMERIC;
	DECLARE node_right NUMERIC;
	DECLARE tree_id_ VARCHAR(255);
	
	SELECT lft, rgt,tree_id INTO node_left, node_right, tree_id_ FROM nodes WHERE id = node_id;
	
	DELETE FROM nodes WHERE id = node_id;
	
	UPDATE nodes SET rgt = rgt - 1 , lft = lft - 1 WHERE lft BETWEEN node_left AND node_right and tree_id = tree_id_;
	
	UPDATE nodes SET rgt = rgt - 2 WHERE rgt > node_right and tree_id = tree_id_;
	UPDATE nodes SET lft = lft - 2 WHERE lft > node_right and tree_id = tree_id_;

END //

DELIMITER ;

DROP PROCEDURE remove_node;
CALL remove_node(2);

select * from nodes;

CALL create_root_node('top_boss');

CALL add_node(1, 'A');
CALL add_node(1, 'B');

CALL add_node(2, 'F');

CALL add_node(3, 'C');
CALL add_node(3, 'D');
CALL add_node(3, 'E');

SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION';



-- pretty print the table

SELECT CONCAT( REPEAT( '-', (COUNT(parent.name) - 1) ), node.name) AS name
FROM nodes AS node,
        nodes AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
GROUP BY node.name
ORDER BY node.lft;



-- to get the single path
SELECT parent.name
FROM nodes AS node,
        nodes AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND node.name = 'PORTABLE ELECTRONICS'
ORDER BY parent.lft DESC LIMIT 3;

-- to get the immediate descendants of a node

SELECT node.name, (COUNT(parent.name) - (sub_tree.depth + 1)) AS depth
FROM nodes AS node,
        nodes AS parent,
        nodes AS sub_parent,
        (
                SELECT node.name, (COUNT(parent.name) - 1) AS depth
                FROM nodes AS node,
                        nodes AS parent
                WHERE node.lft BETWEEN parent.lft AND parent.rgt
                        AND node.name = 'PORTABLE ELECTRONICS'
                GROUP BY node.name
                ORDER BY node.lft
        )AS sub_tree
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt
        AND sub_parent.name = sub_tree.name
GROUP BY node.name
HAVING depth = 1
ORDER BY node.lft; 



-- :name create-user! :! :n
-- :doc creates a new user record
INSERT INTO users
(name, gender)
VALUES (:name, :gender)

-- :name update-user! :! :n
-- :doc updates an existing user record
--UPDATE users
--SET first_name = :first_name, last_name = :last_name, email = :email
--WHERE id = :id

-- :name get-users :? :*
-- :doc retrieves a user record given the id
SELECT * FROM users
--WHERE id = :id

-- :name delete-user! :! :n
-- :doc deletes a user record given the id
--DELETE FROM users
--WHERE id = :id


-- :name create-relation! :! :n
-- :doc creates a new relation record
INSERT INTO relations
(from_id, to_id)
VALUES (:from_id, :to_id)

-- :name get-relations :? :*
-- :doc retrieves all relations
SELECT * FROM relations
JOIN users u_from on relations.from_id = u_from.id
JOIN users u_to on relations.to_id = u_to.id
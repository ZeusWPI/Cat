-- :name create-user! :insert
-- :doc creates a new user record
INSERT INTO users
(name, gender, zeusid)
VALUES (:name, :gender, :zeusid)

-- :name update-user! :! :n
-- :doc updates an existing user record
--UPDATE users
--SET first_name = :first_name, last_name = :last_name, email = :email
--WHERE id = :id

-- :name get-zeus-user :<! :1
-- :doc retrieve a user on their zeuswpi id
SELECT * FROM users
WHERE zeusid = :zeusid

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
SELECT u_from.name from_name, u_to.name to_name, from_id, to_id FROM relations
JOIN users u_from on relations.from_id = u_from.id
JOIN users u_to on relations.to_id = u_to.id

/*
  -------------------------------
  RELATION REQUESTS
 */

-- :name create-relation-request! :!
-- :doc adds a request for a relation from a user to another user
INSERT INTO relation_requests
(from_id, to_id, status)
VALUES (:from_id, :to_id, :status)

-- :name update-relation-request-status! :! :n
-- :doc updates an existing relation record
UPDATE relation_requests
SET status = :status
WHERE id = :id

-- :name get-relation-request :? :1
-- :doc retrieves one relation request on id
SELECT * FROM relation_requests
WHERE id = :id

-- :name get-relation-requests-from-user :? :*
-- :doc retrieves all relations requests that a user made
SELECT rr.id as rr_id, rr.status, u_to.name as to_name, u_to.id as to_id FROM relation_requests as rr
JOIN users u_to on rr.to_id = u_to.id
WHERE from_id = :from_id

-- :name get-relation-requests-to-user :? :*
-- :doc retrieves all relations requests send to a user
SELECT rr.id as rr_id, rr.status, u_from.name as from_name, u_from.id as from_id FROM relation_requests as rr
JOIN users u_from on rr.from_id = u_from.id
WHERE to_id = :to_id

/*
  COMPLEX QUERIES
 */

-- :name get-connection-existence :? :1
-- :doc retrieves all relations-requests or relations between 2 users
SELECT count(*) count
  FROM(
    SELECT rr.from_id FROM relation_requests rr WHERE rr.from_id = :user_id and rr.to_id = :other_id
     UNION ALL
    SELECT rr.to_id FROM relation_requests rr WHERE rr.from_id = :other_id and rr.to_id = :user_id
     UNION ALL
    SELECT rel.from_id  FROM relations rel WHERE rel.from_id = :user_id and rel.to_id = :other_id
     UNION ALL
    SELECT rel.to_id FROM relations rel WHERE rel.from_id = :other_id and rel.to_id = :user_id) x

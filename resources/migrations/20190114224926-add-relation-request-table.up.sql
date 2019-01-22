CREATE TABLE relation_requests
(id INT NOT NULL AUTO_INCREMENT,
 from_id INT NOT NULL,
 to_id INT NOT NULL,
 status ENUM('open', 'accepted', 'declined') NOT NULL,

 PRIMARY KEY (id),
 FOREIGN KEY (from_id) REFERENCES users (id),
 FOREIGN KEY (to_id) REFERENCES users (id));
CREATE TABLE relations
(id SERIAL PRIMARY KEY,
 from_id INTEGER NOT NULL,
 to_id INTEGER NOT NULL,
 FOREIGN KEY (from_id) REFERENCES users (id),
 FOREIGN KEY (to_id) REFERENCES users (id));
-- Database: Desafío - Consultas en Múltiples Tablas

-- DROP DATABASE IF EXISTS "Desafío - Consultas en Múltiples Tablas";

CREATE DATABASE "Desafío - Consultas en Múltiples Tablas"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;



--Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido.

--Creacion de tabla Usuarios
CREATE TABLE IF NOT EXISTS
	Usuarios
		(
			id SERIAL PRIMARY KEY,
			email VARCHAR,
			nombre VARCHAR,
			apellido VARCHAR,
			rol VARCHAR
		)
;

--Se insertan datos a la tabla Usuarios, 5 usuarios donde 2 son administradores.

INSERT INTO Usuarios (email, nombre, apellido, rol)
	VALUES
		('admin_1@example.com', 'Gerardo', 'Santos', 'administrador'),
		
		('user_1@example.com', 'Sofia', 'Jigashi', 'usuario'),

		('admin_2@example.com', 'Miguel', 'Acosta', 'administrador'),

		('user_2@example.com', 'Johan', 'Mungia', 'usuario'),

		('user_3@example.com', 'Felipe', 'Ramos', 'usuario');

--Consultar Datos actuales

SELECT * FROM Usuarios;

--Se crea la siguiente tabla Posts(Articulos):

CREATE TABLE IF NOT EXISTS
	Posts
		(
			id SERIAL PRIMARY KEY,
			titulo VARCHAR,
			contenido TEXT,
			fecha_creacion TIMESTAMP,
			fecha_actualizacion TIMESTAMP,
			destacado BOOLEAN,
			usuario_id BIGINT,
			CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES Usuarios (id)
		)
;

--Consultar Datos actuales

SELECT * FROM Posts;

--Se crea contenido de los post para los usuarios administradores.

INSERT INTO Posts (titulo, contenido, destacado, usuario_id)
	VALUES 
		('Primer Post', 'Hola, soy administrador', TRUE, 1),
		('Segundo Post', 'Hola, tambien soy administrador', FALSE, 1),
		('Tercer Post', 'Hola, soy usuario', FALSE, 2),
		('Cuarto Post', 'Hola, tambien soy usuario', TRUE, 2),
		('Quinto Post', 'Hola, no estoy asignado', FALSE, NULL);

--Consultar Datos actuales

SELECT * FROM Posts;

--Se crea la siguiente tabla Comentarios:

CREATE TABLE IF NOT EXISTS
	Comentarios
		(
			id SERIAL PRIMARY KEY,
			contenido TEXT,
			fecha_creacion TIMESTAMP,
			usuario_id BIGINT,
			post_id BIGINT,
			CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES Usuarios (id),
   			CONSTRAINT fk_post FOREIGN KEY (post_id) REFERENCES Posts (id)
		)
;

--Se agregan datos a tabla Comentarios,

INSERT INTO  Comentarios (contenido, usuario_id, post_id)
	VALUES
		('Este es el primer comentario', 1, 1),
		('Este es el segundo comentario', 2, 1),
		('Este es el tercero comentario', 3, 1),
		('Este es el cuarto comentario', 1, 2),
		('Este es el quinto comentario', 2, 2);

--Consultar Datos actuales

SELECT * FROM Comentarios
ORDER BY id ASC;

--Se hace correccion en el comentario del ID 3. Tecero a Tecer de la tabla Comentarios,

Update Comentarios
SET contenido = 'Este es el tercer comentario'
Where id = 3;


-- Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: 
-- nombre y email del usuario junto al título y contenido del post.


--USO del JOIN

SELECT 
    Usuarios.nombre, 
    Usuarios.email, 
    Posts.titulo, 
    Posts.contenido
FROM 
    Usuarios
INNER JOIN 
    Posts 
ON 
    Usuarios.id = Posts.usuario_id
;

--Muestra el id, título y contenido de los posts de los administradores.
-- a. El administrador puede ser cualquier id.


--USO DEL JOIN (Muestra solo usuarios administradores)
SELECT
	Posts.id,
	Posts.titulo,
	Posts.contenido
FROM
	Posts
INNER JOIN
	Usuarios
	ON 
		Posts.usuario_id = Usuarios.id
WHERE
	Usuarios.rol = 'administrador'
;

-- Cuenta la cantidad de posts de cada usuario.
--a. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.

--USO DEL COUNT, JOIN Y GROUP BY.

SELECT
	Usuarios.id,
	Usuarios.email,
		COUNT
			(Posts.id) AS cantidadPost
FROM
	Usuarios
LEFT JOIN
	Posts
	ON
		Usuarios.id = Posts.usuario_id
GROUP BY
	Usuarios.id, Usuarios.email
ORDER BY id ASC
;

-- Muestra el email del usuario que ha creado más posts.
-- a. Aquí la tabla resultante tiene un único registro y muestra solo el email.
SELECT
	Usuarios.email
FROM
	Usuarios
JOIN
	Posts
	ON
		Usuarios.id = Posts.usuario_id
GROUP BY
	Usuarios.email
ORDER BY
	COUNT (Posts.id) DESC
LIMIT 1;

--Muestra la fecha del último post de cada usuario.
--Se agrega fecha para continuar con ejercicio.

UPDATE Posts
SET fecha_creacion = NOW(),
    fecha_actualizacion = NOW();

UPDATE Comentarios
SET fecha_creacion = NOW();

--Muestra el título y contenido del post (artículo) con más comentarios
--Mostrar el ultimo post.

SELECT 
	Usuarios.email, Usuarios.nombre, 
		MAX(Posts.fecha_creacion) AS fecha_ultimo_post
FROM 
	Posts
INNER JOIN 
	Usuarios
		ON Posts.usuario_id = Usuarios.id
GROUP BY 
	Usuarios.id, Usuarios.email, Usuarios.nombre
;

--Mostrar el titulo y post con mas comentarios.

SELECT
	Posts.titulo, Posts.contenido
FROM
	Posts
INNER JOIN
	Comentarios
	ON
		Posts.id = Comentarios.post_id
GROUP BY
	Posts.id
ORDER BY
	COUNT (Comentarios.id) DESC
LIMIT 1
;

--Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
--de cada comentario asociado a los posts mostrados, junto con el email del usuario
--que lo escribió.

SELECT
    p.titulo, p.contenido, c.contenido, u.email
FROM
    Posts p
INNER JOIN
    (
        SELECT * 
		FROM Comentarios
    ) c ON p.id = c.post_id
INNER JOIN
    Usuarios u 
	ON c.usuario_id = u.id
;

--Muestra el contenido del último comentario de cada usuario.

SELECT
    u.email,
    c.contenido
FROM
    Usuarios u
INNER JOIN
    Comentarios c ON u.id = c.usuario_id
WHERE
    c.fecha_creacion = (
        SELECT MAX(fecha_creacion)
        FROM Comentarios c2
        WHERE c2.usuario_id = c.usuario_id
    );

--Muestra los emails de los usuarios que no han escrito ningún comentario.

SELECT u.email
FROM Usuarios u
LEFT JOIN Comentarios c ON u.id = c.usuario_id
WHERE c.id IS NULL;


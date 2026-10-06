CREATE DATABASE EvolutionDB
GO
USE EvolutionDB
GO

-- 1) Regiones y ubicaciones
CREATE TABLE Regiones (
    IdRegion INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL
);

CREATE TABLE Paises (
    IdPais INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL,
    IdRegion INT NOT NULL,
    CONSTRAINT FK_Paises_Regiones FOREIGN KEY (IdRegion) REFERENCES Regiones(IdRegion)
);

CREATE TABLE Provincias (
    IdProvincia INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL,
    IdPais INT NOT NULL,
    CONSTRAINT FK_Provincias_Paises FOREIGN KEY (IdPais) REFERENCES Paises(IdPais)
);

CREATE TABLE Calles (
    IdCalle INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL,
    IdProvincia INT NOT NULL,
    CONSTRAINT FK_Calles_Provincias FOREIGN KEY (IdProvincia) REFERENCES Provincias(IdProvincia)
);

CREATE TABLE Direcciones (
    IdDireccion INT IDENTITY(1,1) PRIMARY KEY,
    IdCalle INT NOT NULL,
    Numero INT NOT NULL,
    CodigoPostal VARCHAR(30) NOT NULL, -- alfanumérico
    CONSTRAINT FK_Direcciones_Calles FOREIGN KEY (IdCalle) REFERENCES Calles(IdCalle)
);

-- 2) Usuarios y formas de pago
CREATE TABLE FormasPago (
    IdFormaPago INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    FechaRegistro DATE NOT NULL,
	PasswordHash VARBINARY(MAX),
	PasswordSalt VARBINARY(MAX),
	Rol			 varchar(50)
    -- Se eliminan IdBiblioteca e IdWishlist (REFACTOR)
);

-- 3) Pegi, Juegos y DLCs
CREATE TABLE Pegis (
    IdPegi INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE Juegos (
    IdJuego INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    FechaLanzamiento DATE,
    IdPegi INT NOT NULL,
    Estado VARCHAR(100) NOT NULL,
	ImagenUrl VARCHAR(500) NULL,
    CONSTRAINT FK_Juegos_Pegis FOREIGN KEY (IdPegi) REFERENCES Pegis(IdPegi)
);


CREATE TABLE Dlcs (
    IdDlc INT IDENTITY(1,1) PRIMARY KEY,
    IdJuego INT NOT NULL, -- Juego base al que pertenece
    Nombre VARCHAR(100) NOT NULL, -- Añadido: Los DLCs deben tener nombre
    Descripcion VARCHAR(255),
    Estado VARCHAR(50),
    FechaLanzamiento DATE,
    IdPegi INT NOT NULL,
    CONSTRAINT FK_Dlcs_Juegos FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego),
    CONSTRAINT FK_Dlcs_Pegis FOREIGN KEY (IdPegi) REFERENCES Pegis(IdPegi)
);

-- 4) Productos, precios y descuentos (El "Marketplace")
CREATE TABLE Productos (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdJuego INT NULL, -- Es un Juego base
    IdDlc INT NULL,   -- Es un DLC
    Tipo VARCHAR(20) NOT NULL, -- 'Juego', 'DLC', 'Bundle', etc.
    CONSTRAINT FK_Productos_Juegos FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego),
    CONSTRAINT FK_Productos_Dlcs FOREIGN KEY (IdDlc) REFERENCES Dlcs(IdDlc)
);

CREATE TABLE PreciosProductos (
    IdPrecioProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdProducto INT NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    FechaInicio DATE NOT NULL,
    CONSTRAINT FK_Precios_Productos FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto)
);

CREATE TABLE Descuentos (
    IdDescuento INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE
);

CREATE TABLE DescuentosProducto (
    IdDescuentoProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdDescuento INT NOT NULL,
    IdProducto INT NOT NULL,
    Porcentaje DECIMAL(5,2) NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE,
    CONSTRAINT FK_DescProd_Descuento FOREIGN KEY (IdDescuento) REFERENCES Descuentos(IdDescuento),
    CONSTRAINT FK_DescProd_Producto FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto)
);

-- 5) Transacciones
CREATE TABLE DatosPagosGuardados (
    IdMetodoPagoGuardado INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT NOT NULL,
    NumTarjeta VARCHAR(16) NOT NULL, -- Simplificado. En un caso real, esto se tokeniza.
    IdFormaPago INT NOT NULL,
    CONSTRAINT FK_Usuario_DatosPagos FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_FormasPago_DatosGuardados FOREIGN KEY (IdFormaPago) REFERENCES FormasPago(IdFormaPago)
);

CREATE TABLE Transacciones (
    IdTransaccion INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT NOT NULL,
    Fecha DATETIME NOT NULL,
    Tipo VARCHAR(30),
    IdMetodoPagoGuardado INT NOT NULL,
    CONSTRAINT FK_Usuario_Transaccion FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_PagoGuardado_Transaccion FOREIGN KEY (IdMetodoPagoGuardado) REFERENCES DatosPagosGuardados(IdMetodoPagoGuardado)
);

CREATE TABLE DetallesTransacciones (
    IdDetalleTransaccion INT IDENTITY(1,1) PRIMARY KEY,
    IdTransaccion INT NOT NULL,
    IdProducto INT NOT NULL,
    IdDescuentoProducto INT,
    IdPrecioProducto INT NOT NULL,
    CONSTRAINT FK_DetTrans_Transaccion FOREIGN KEY (IdTransaccion) REFERENCES Transacciones(IdTransaccion),
    CONSTRAINT FK_DetTrans_Producto FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto),
    CONSTRAINT FK_DetTrans_Descuento FOREIGN KEY (IdDescuentoProducto) REFERENCES DescuentosProducto(IdDescuentoProducto),
    CONSTRAINT FK_DetTrans_Precio FOREIGN KEY (IdPrecioProducto) REFERENCES PreciosProductos(IdPrecioProducto)
);

-- 6) Logros
CREATE TABLE Logros (
    IdLogro INT IDENTITY(1,1) PRIMARY KEY,
    IdJuego INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    CONSTRAINT FK_Logros_Juegos FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

-- 7) Desarrolladoras y publishers
CREATE TABLE Desarrolladoras (
    IdDesarrolladora INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    EmailContacto VARCHAR(100),
    IdPais INT NOT NULL,
    SitioWeb VARCHAR(200),
    CONSTRAINT FK_Desarrolladoras_Pais FOREIGN KEY (IdPais) REFERENCES Paises(IdPais)
);

CREATE TABLE Publishers (
    IdPublisher INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    EmailContacto VARCHAR(100),
    SitioWeb VARCHAR(200),
    IdPais INT NOT NULL,
    CONSTRAINT FK_Publishers_Pais FOREIGN KEY (IdPais) REFERENCES Paises(IdPais)
);

-- 8) Relaciones de Juegos (Etiquetas, Géneros, SO, etc.)
--    NOTA: Estas tablas usan Clave Primaria Compuesta (CPK) para EF Core.

CREATE TABLE Etiquetas (
    IdEtiqueta INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE JuegosEtiquetas (
    IdEtiqueta INT NOT NULL,
    IdJuego INT NOT NULL,
    CONSTRAINT PK_JuegosEtiquetas PRIMARY KEY (IdEtiqueta, IdJuego), -- CPK
    CONSTRAINT FK_JuegosE_Etiqueta FOREIGN KEY (IdEtiqueta) REFERENCES Etiquetas(IdEtiqueta),
    CONSTRAINT FK_JuegosE_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

CREATE TABLE Generos (
    IdGenero INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE JuegosGeneros (
    IdGenero INT NOT NULL,
    IdJuego INT NOT NULL,
    CONSTRAINT PK_JuegosGeneros PRIMARY KEY (IdGenero, IdJuego), -- CPK
    CONSTRAINT FK_JuegosG_Genero FOREIGN KEY (IdGenero) REFERENCES Generos(IdGenero),
    CONSTRAINT FK_JuegosG_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

CREATE TABLE SistemasOperativos (
    IdSistemaOperativo INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE SistemasOperativosJuegos (
    IdSistemaOperativo INT NOT NULL,
    IdJuego INT NOT NULL,
    CONSTRAINT PK_SistemasOperativosJuegos PRIMARY KEY (IdSistemaOperativo, IdJuego), -- CPK
    CONSTRAINT FK_JuegosSO_SistOp FOREIGN KEY (IdSistemaOperativo) REFERENCES SistemasOperativos(IdSistemaOperativo),
    CONSTRAINT FK_JuegosSO_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

CREATE TABLE JuegosDesarrolladoras (
    IdDesarrolladora INT NOT NULL,
    IdJuego INT NOT NULL,
    CONSTRAINT PK_JuegosDesarrolladoras PRIMARY KEY (IdDesarrolladora, IdJuego), -- CPK
    CONSTRAINT FK_JuegosDes_Desarrolladora FOREIGN KEY (IdDesarrolladora) REFERENCES Desarrolladoras(IdDesarrolladora),
    CONSTRAINT FK_JuegosDes_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);


CREATE TABLE JuegosPublishers (
    IdPublisher INT NOT NULL,
    IdJuego INT NOT NULL,
    CONSTRAINT PK_JuegosPublishers PRIMARY KEY (IdPublisher, IdJuego), -- CPK
    CONSTRAINT FK_JuegosPub_Publisher FOREIGN KEY (IdPublisher) REFERENCES Publishers(IdPublisher),
    CONSTRAINT FK_JuegosPub_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

-- 9) Relaciones de Usuarios (Biblioteca, Wishlist, Logros)
--    NOTA: Estas son tablas "con payload" (tienen datos extra), 
--    por lo que SÍ conservan su propio ID.

CREATE TABLE UsuariosJuegos ( -- Esta es la "Biblioteca"
    IdUsuarioJuego INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT NOT NULL,
    IdJuego INT NOT NULL,
    TiempoTotal INT,
    FechaAdquisicion DATE,
    UltimaVez DATETIME,
    EstaEnBiblioteca BIT NOT NULL DEFAULT 1, -- (1 = Activo, 0 = Oculto/Eliminado)
    CONSTRAINT FK_UsuJuegos_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_UsuJuegos_Juego FOREIGN KEY (IdJuego) REFERENCES Juegos(IdJuego)
);

CREATE TABLE UsuariosLogros (
    IdUsuarioLogro INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT NOT NULL,
    IdLogro INT NOT NULL,
    FechaDesbloqueo DATETIME,
    CONSTRAINT FK_UsuLogros_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_UsuLogros_Logro FOREIGN KEY (IdLogro) REFERENCES Logros(IdLogro)
);

CREATE TABLE UsuariosWishlist ( -- Nueva tabla (REFACTOR)
    IdUsuarioWishlist INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT NOT NULL,
    IdProducto INT NOT NULL, -- Apunta a Producto (Juego o DLC)
    FechaAgregado DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Wishlist_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Wishlist_Producto FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto)
);

--inserts
USE EvolutionDB
GO

-- 1. Metadatos Base (Entidades sin dependencias)
PRINT 'Insertando metadatos base...'
INSERT INTO Pegis (Descripcion) VALUES 
('PEGI 3'), ('PEGI 12'), ('PEGI 18');

INSERT INTO Generos (Nombre) VALUES 
('RPG'), ('Accion'), ('Estrategia'), ('Simulacion'), ('Aventura');

INSERT INTO Etiquetas (Nombre) VALUES 
('Mundo Abierto'), ('Multijugador'), ('Indie'), ('VR'), ('Cyberpunk');

INSERT INTO SistemasOperativos (Nombre) VALUES 
('Windows'), ('Linux'), ('MacOS');

INSERT INTO FormasPago (Nombre) VALUES 
('Tarjeta de Credito'), ('PayPal'), ('TiendaPuntos');

INSERT INTO Regiones (Nombre) VALUES 
('America'), ('Europa'), ('Asia');

INSERT INTO Descuentos (Nombre, FechaInicio, FechaFin) VALUES 
('Oferta de Verano 2025', '2025-06-21', '2025-07-05'),
('Oferta de Halloween 2025', '2025-10-25', '2025-11-02');
GO

-- 2. Entidades dependientes (Nivel 1)
PRINT 'Insertando entidades de Nivel 1...'
INSERT INTO Paises (Nombre, IdRegion) VALUES 
('Estados Unidos', 1), ('Polonia', 2), ('Japon', 3);

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('jperez', 'juan@email.com', 'Juan', 'Perez', '1995-03-15', '2023-01-10'),
('mgomez', 'maria@email.com', 'Maria', 'Gomez', '2001-11-30', '2024-05-20');

INSERT INTO Desarrolladoras (Nombre, IdPais) VALUES 
('CD Projekt Red', 2), ('ConcernedApe', 1), ('Rockstar Games', 1);

INSERT INTO Publishers (Nombre, IdPais) VALUES 
('CD Projekt Red', 2), ('Rockstar Games', 1), ('Nintendo', 3);
GO

-- 3. Entidades de Juegos y Logros
PRINT 'Insertando Juegos y Logros...'
-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('Cyberpunk 2077', 'Juego de rol de accion...', '2020-12-10', 3, 'Publicado'),
('Stardew Valley', 'Simulador de granja...', '2016-02-26', 2, 'Publicado'),
('The Witcher 3', 'Juego de rol de fantasia...', '2015-05-19', 3, 'Publicado');

INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(1, 'El Demonio de V', 'Completa la historia de V.'),
(2, 'Millonario', 'Gana 1,000,000g'),
(2, 'Amigo del Pueblo', 'Alcanza 5 corazones con 20 personas');
GO

-- 4. DLCs y Productos (La "Tienda")
PRINT 'Insertando DLCs y Productos...'
-- Asumimos que los juegos insertados tienen ID 1='Cyberpunk', 2='Stardew', 3='Witcher'
INSERT INTO Dlcs (IdJuego, Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
(1, 'Phantom Liberty', 'Expansion de espionaje...', '2023-09-26', 3, 'Publicado');
-- Asumimos que el DLC insertado tiene ID 1='Phantom Liberty'

INSERT INTO Productos (IdJuego, IdDlc, Tipo) VALUES 
(1, NULL, 'Juego'), -- Producto 1: Cyberpunk 2077 (Base)
(2, NULL, 'Juego'), -- Producto 2: Stardew Valley (Base)
(3, NULL, 'Juego'), -- Producto 3: The Witcher 3 (Base)
(NULL, 1, 'DLC');   -- Producto 4: Phantom Liberty (DLC)
GO

-- 5. Precios y Descuentos
PRINT 'Insertando Precios y Descuentos...'
-- Asumimos que los productos tienen ID 1-4
INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(1, 59.99, '2020-12-10'), -- Precio 1: Cyberpunk
(2, 14.99, '2016-02-26'), -- Precio 2: Stardew
(3, 39.99, '2015-05-19'), -- Precio 3: Witcher
(4, 29.99, '2023-09-26'); -- Precio 4: DLC

-- Aplicar descuento de Halloween (ID 2) a The Witcher 3 (Producto 3)
INSERT INTO DescuentosProducto (IdDescuento, IdProducto, Porcentaje, FechaInicio, FechaFin) VALUES 
(2, 3, 75.00, '2025-10-25', '2025-11-02'); -- DescuentoProducto ID 1
GO

-- 6. Tablas de Relación (Muchos-a-Muchos con CPK)
PRINT 'Insertando relaciones N-a-N...'
-- Generos (1='RPG', 2='Accion', 4='Simulacion')
INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(1, 1), (1, 2), -- Cyberpunk es RPG y Accion
(2, 1), (2, 4), -- Stardew es RPG y Simulacion
(3, 1), (3, 2); -- Witcher es RPG y Accion

-- Etiquetas (1='Mundo Abierto', 3='Indie', 5='Cyberpunk')
INSERT INTO JuegosEtiquetas (IdJuego, IdEtiqueta) VALUES
(1, 1), (1, 5), -- Cyberpunk
(2, 3),         -- Stardew
(3, 1);         -- Witcher

-- SOs (1='Windows', 2='Linux', 3='MacOS')
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
(1, 1), -- Cyberpunk solo Windows
(2, 1), (2, 2), (2, 3), -- Stardew en todos
(3, 1); -- Witcher solo Windows

-- Desarrolladoras (1='CDPR', 2='ConcernedApe')
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES
(1, 1), (3, 1), -- CDPR hizo Cyberpunk y Witcher
(2, 2);         -- ConcernedApe hizo Stardew

-- Publishers (1='CDPR')
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES
(1, 1), (3, 1); -- CDPR publica sus juegos
GO

-- 7. Datos de Usuario (Biblioteca, Wishlist, Pagos)
PRINT 'Insertando datos de Usuarios...'
-- Asumimos Usuario 1='juan', Usuario 2='maria'
-- Asumimos FormaPago 1='Credito', 2='PayPal'
INSERT INTO DatosPagosGuardados (IdUsuario, NumTarjeta, IdFormaPago) VALUES 
(1, '1234567890123456', 1),
(2, '9876543210987654', 2);
-- Asumimos que estos son los ID 1 y 2 de PagosGuardados

-- Biblioteca de Juan (Usuario 1)
-- Tiene Stardew (Juego 2) y está activo
INSERT INTO UsuariosJuegos (IdUsuario, IdJuego, TiempoTotal, FechaAdquisicion, UltimaVez, EstaEnBiblioteca) VALUES 
(1, 2, 150, '2023-01-20', '2025-10-20 18:00:00', 1);
-- Tuvo The Witcher 3 (Juego 3) pero lo "ocultó"
INSERT INTO UsuariosJuegos (IdUsuario, IdJuego, TiempoTotal, FechaAdquisicion, UltimaVez, EstaEnBiblioteca) VALUES 
(1, 3, 80, '2024-01-15', '2024-01-15 12:00:00', 0);

-- Biblioteca de Maria (Usuario 2)
-- Tiene The Witcher 3 (Juego 3) y está activo
INSERT INTO UsuariosJuegos (IdUsuario, IdJuego, TiempoTotal, FechaAdquisicion, UltimaVez, EstaEnBiblioteca) VALUES 
(2, 3, 200, '2024-06-01', '2025-10-30 20:00:00', 1);

-- Logros de Juan (Usuario 1)
-- Asumimos Logro 2='Millonario'
INSERT INTO UsuariosLogros (IdUsuario, IdLogro, FechaDesbloqueo) VALUES 
(1, 2, '2024-03-01 10:30:00');

-- Wishlist de Juan (Usuario 1)
-- Quiere Cyberpunk (Producto 1) y el DLC (Producto 4)
INSERT INTO UsuariosWishlist (IdUsuario, IdProducto, FechaAgregado) VALUES 
(1, 1, '2024-10-01'),
(1, 4, '2024-10-02');
GO

-- 8. Transacciones (Simulación de Compra)
PRINT 'Simulando transacciones...'
-- Maria (Usuario 2) compra Cyberpunk (Producto 1)
-- Asumimos que la Transaccion tendrá ID 1
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(2, '2025-10-28 14:30:00', 'Compra', 2); -- Usa su pago ID 2

-- Detalle de esa transacción
-- Compra Cyberpunk (Producto 1) a su precio normal (Precio ID 1)
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(1, 1, NULL, 1);

-- Juan (Usuario 1) compra The Witcher 3 (Producto 3) CON DESCUENTO
-- Asumimos que la Transaccion tendrá ID 2
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(1, '2025-10-29 09:15:00', 'Compra', 1); -- Usa su pago ID 1

-- Detalle de esa transacción
-- Compra The Witcher 3 (Producto 3)
-- Usa el Precio ID 3 (39.99)
-- Usa el DescuentoProducto ID 1 (75% off)
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(2, 3, 1, 3);
GO

PRINT 'Script de insercion finalizado.'

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 2 de Inserciones Masivas ---'

-- 1. Nuevos Metadatos Base
PRINT 'Insertando nuevos metadatos (Géneros, Etiquetas, Países)...'
INSERT INTO Generos (Nombre) VALUES 
('Terror Psicologico'), ('Construccion de Ciudades'), ('Roguelike'), ('Plataformas');
INSERT INTO Etiquetas (Nombre) VALUES 
('Pixel Art'), ('Acceso Anticipado'), ('Cooperativo'), ('Supervivencia');
INSERT INTO Paises (Nombre, IdRegion) VALUES 
('Canada', 1), ('Suecia', 2), ('Reino Unido', 2);
GO

-- 2. Nuevas Desarrolladoras y Publishers
-- Asumiendo IDs existentes: 1='USA', 2='Polonia', 3='Japon'
-- Nuevos IDs: 4='Canada', 5='Suecia', 6='Reino Unido'
PRINT 'Insertando nuevas Desarrolladoras y Publishers...'
INSERT INTO Desarrolladoras (Nombre, IdPais) VALUES 
('Red Hook Studios', 4),       -- ID 4
('Mojang Studios', 5),         -- ID 5
('Larian Studios', 2),         -- ID 6 (Usando Polonia/Belgica, simplificado)
('Team Cherry', 6),            -- ID 7
('Colossal Order', 5),         -- ID 8
('Phasmophobia Ltd', 6);      -- ID 9

INSERT INTO Publishers (Nombre, IdPais) VALUES 
('Microsoft Game Studios', 1), -- ID 4
('Larian Studios', 2),         -- ID 5
('Team Cherry', 6),            -- ID 6
('Paradox Interactive', 5),    -- ID 7
('Red Hook Studios', 4),       -- ID 8
('Kinetic Games', 6);          -- ID 9
GO

-- 3. Nuevos Usuarios
PRINT 'Insertando nuevos Usuarios...'
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('carlosS', 'carlos@email.com', 'Carlos', 'Sanchez', '1990-07-22', '2024-02-11'),
('anaM', 'ana@email.com', 'Ana', 'Martinez', '1998-12-01', '2024-03-15'),
('test_user', 'test@test.com', 'Usuario', 'Prueba', '2000-01-01', '2024-04-01'),
('dev_main', 'dev@email.com', 'Desarrollador', 'Principal', '1985-05-10', '2024-06-30'),
('gamer_pro', 'pro@email.com', 'Laura', 'Nuñez', '2002-08-19', '2024-08-25');
-- IDs Asumidos: 3='carlosS', 4='anaM', 5='test_user', 6='dev_main', 7='gamer_pro'
GO

-- 4. Nuevos Juegos
PRINT 'Insertando nuevos Juegos...'
-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('Darkest Dungeon', 'Un desafiante RPG roguelike...', '2016-01-19', 3, 'Publicado'), -- ID 4
('Minecraft', 'Juego de construccion y supervivencia...', '2011-11-18', 1, 'Publicado'), -- ID 5
('Baldur''s Gate 3', 'Un RPG de nueva generacion...', '2023-08-03', 3, 'Publicado'), -- ID 6
('Hollow Knight', 'Aventura de accion clasica en 2D...', '2017-02-24', 2, 'Publicado'), -- ID 7
('Cities: Skylines', 'Simulador de construccion de ciudades...', '2015-03-10', 1, 'Publicado'), -- ID 8
('Phasmophobia', 'Terror psicologico cooperativo...', '2020-09-18', 3, 'Acceso Anticipado'); -- ID 9
GO

-- 5. Nuevos DLCs
PRINT 'Insertando nuevos DLCs...'
-- IDs Juegos: 4='Darkest', 8='Cities'
INSERT INTO Dlcs (IdJuego, Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
(4, 'The Crimson Court', 'Expansion con vampiros...', '2017-06-19', 3, 'Publicado'), -- ID 2
(8, 'After Dark', 'Expansion de ciclo dia/noche...', '2015-09-24', 1, 'Publicado'); -- ID 3
GO

-- 6. Nuevos Productos y Precios
PRINT 'Insertando nuevos Productos y Precios...'
-- IDs Juegos: 4-9. IDs DLCs: 2-3
INSERT INTO Productos (IdJuego, IdDlc, Tipo) VALUES 
(4, NULL, 'Juego'), -- Producto 5: Darkest Dungeon
(5, NULL, 'Juego'), -- Producto 6: Minecraft
(6, NULL, 'Juego'), -- Producto 7: Baldur's Gate 3
(7, NULL, 'Juego'), -- Producto 8: Hollow Knight
(8, NULL, 'Juego'), -- Producto 9: Cities: Skylines
(9, NULL, 'Juego'), -- Producto 10: Phasmophobia
(NULL, 2, 'DLC'),   -- Producto 11: DLC Crimson Court
(NULL, 3, 'DLC');   -- Producto 12: DLC After Dark

INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(5, 24.99, '2016-01-19'), -- Precio 5
(6, 29.99, '2011-11-18'), -- Precio 6
(7, 59.99, '2023-08-03'), -- Precio 7
(8, 14.99, '2017-02-24'), -- Precio 8
(9, 29.99, '2015-03-10'), -- Precio 9
(10, 13.99, '2020-09-18'), -- Precio 10
(11, 9.99, '2017-06-19'),  -- Precio 11
(12, 14.99, '2015-09-24'); -- Precio 12
GO

-- 7. Nuevas Relaciones N-a-N
PRINT 'Insertando nuevas relaciones N-a-N para los juegos...'
-- IDs Juegos: 4='Darkest', 5='Minecraft', 6='BG3', 7='Hollow', 8='Cities', 9='Phasmo'
-- IDs Géneros: 1='RPG', 6='Terror', 7='Ciudades', 8='Roguelike', 9='Plataformas'
INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(4, 1), (4, 8),   -- Darkest (RPG, Roguelike)
(5, 4),           -- Minecraft (Simulacion)
(6, 1),           -- BG3 (RPG)
(7, 2), (7, 9),   -- Hollow Knight (Accion, Plataformas)
(8, 4), (8, 7),   -- Cities (Simulacion, Ciudades)
(9, 6);           -- Phasmophobia (Terror)




-- IDs Desarrolladoras: 4='Red Hook', 5='Mojang', 6='Larian', 7='Team Cherry', 8='Colossal', 9='Phasmo Ltd'
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES
(4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9);

-- IDs Publishers: 4='Microsoft', 5='Larian', 6='Team Cherry', 7='Paradox', 8='Red Hook', 9='Kinetic'
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES
(4, 8), (5, 4), (6, 5), (7, 6), (8, 7), (9, 9);

-- IDs SO: 1='Windows', 2='Linux', 3='MacOS'
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
(4, 1), (4, 2), (4, 3),
(5, 1), (5, 2), (5, 3),
(6, 1), (6, 3),
(7, 1), (7, 2), (7, 3),
(8, 1), (8, 2), (8, 3),
(9, 1);
GO

-- 8. Poblar Bibliotecas y Wishlists de Nuevos Usuarios
PRINT 'Poblando Bibliotecas y Wishlists...'
-- IDs Usuarios: 3='carlosS', 4='anaM', 5='test_user', 7='gamer_pro'
-- IDs Juegos: 1='Cyberpunk', 2='Stardew', 4='Darkest', 5='Minecraft', 6='BG3', 7='Hollow', 8='Cities', 9='Phasmo'
-- IDs Productos: 2='Stardew', 6='Minecraft', 7='BG3', 8='Hollow', 11='DLC Crimson Court'

-- Bibliotecas
INSERT INTO UsuariosJuegos (IdUsuario, IdJuego, TiempoTotal, FechaAdquisicion, UltimaVez, EstaEnBiblioteca) VALUES 
(3, 5, 300, '2024-02-15', '2025-10-10 12:00:00', 1), -- Carlos: Minecraft
(3, 8, 50, '2024-03-01', '2025-09-15 15:00:00', 1), -- Carlos: Cities: Skylines
(4, 2, 80, '2024-03-20', '2025-10-25 22:00:00', 1), -- Ana: Stardew Valley
(4, 7, 40, '2024-05-10', '2025-10-01 19:00:00', 1), -- Ana: Hollow Knight
(5, 9, 15, '2024-04-02', '2025-08-11 23:00:00', 1), -- Test User: Phasmophobia
(7, 1, 120, '2024-09-01', '2025-10-30 01:00:00', 1), -- Gamer Pro: Cyberpunk
(7, 6, 90, '2024-09-15', '2025-10-28 17:00:00', 1); -- Gamer Pro: BG3

-- Wishlists
INSERT INTO UsuariosWishlist (IdUsuario, IdProducto, FechaAgregado) VALUES 
(3, 7, '2025-01-15'), -- Carlos quiere BG3
(3, 12, '2025-02-01'), -- Carlos quiere DLC Cities
(4, 5, '2025-04-10'), -- Ana quiere Minecraft
(7, 11, '2025-10-01'); -- Gamer Pro quiere DLC Darkest
GO

-- 9. Nuevos Pagos Guardados y Transacciones
PRINT 'Insertando nuevos Pagos Guardados y Transacciones...'
-- IDs Usuarios: 3='carlosS', 4='anaM', 7='gamer_pro'
-- IDs FormaPago: 1='Credito', 2='PayPal'
INSERT INTO DatosPagosGuardados (IdUsuario, NumTarjeta, IdFormaPago) VALUES 
(3, '1111222233334444', 1), -- ID 3
(4, '5555666677778888', 1), -- ID 4
(7, '9999000011112222', 2); -- ID 5

-- Nuevas Transacciones
-- ID Transaccion 3: Carlos (User 3) compra Minecraft (Prod 6)
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(3, '2024-02-15 10:00:00', 'Compra', 3);
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(3, 6, NULL, 6); -- Precio 6 (29.99)

-- ID Transaccion 4: Ana (User 4) compra Hollow Knight (Prod 8)
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(4, '2024-05-10 18:30:00', 'Compra', 4);
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(4, 8, NULL, 8); -- Precio 8 (14.99)

-- ID Transaccion 5: Gamer Pro (User 7) compra BG3 (Prod 7)
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(7, '2024-09-15 12:15:00', 'Compra', 5);
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(5, 7, NULL, 7); -- Precio 7 (59.99)

-- ID Transaccion 6: Ana (User 4) compra Stardew (Prod 2)
INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES 
(4, '2024-03-20 17:00:00', 'Compra', 4);
INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(6, 2, NULL, 2); -- Precio 2 (14.99)
GO

PRINT '--- Lote 2 de Inserciones Finalizado ---'

-- -----------------------------------------------------------------
--          INICIO: Lote 3 de Inserciones (Famosos)
-- -----------------------------------------------------------------
PRINT '--- Iniciando Lote 3 de Inserciones Masivas ---'
GO

-- 1. Nuevos Países
-- Asumiendo que los IDs de Región son: 1='America', 2='Europa', 3='Asia'
PRINT 'Insertando 10 nuevos Países...'
INSERT INTO Paises (Nombre, IdRegion) VALUES 
('Alemania', 2),        -- Nuevo ID Pais: 7
('Francia', 2),         -- Nuevo ID Pais: 8
('Corea del Sur', 3),   -- Nuevo ID Pais: 9
('China', 3),           -- Nuevo ID Pais: 10
('Finlandia', 2),       -- Nuevo ID Pais: 11
('Italia', 2),          -- Nuevo ID Pais: 12
('Brasil', 1),          -- Nuevo ID Pais: 13
('Mexico', 1),          -- Nuevo ID Pais: 14
('España', 2),          -- Nuevo ID Pais: 15
('Australia', 1);       -- Nuevo ID Pais: 16 (Asignado a 'America' por falta de 'Oceania')
GO

-- 2. Nuevas Desarrolladoras Famosas
-- Asumiendo IDs de País: 1='EEUU', 3='Japón', 4='Canadá', 8='Francia', 11='Finlandia'
PRINT 'Insertando 15 nuevas Desarrolladoras...'
INSERT INTO Desarrolladoras (Nombre, IdPais) VALUES 
('Naughty Dog', 1),             -- EEUU
('Santa Monica Studio', 1),     -- EEUU
('Insomniac Games', 1),         -- EEUU
('Ubisoft Montreal', 4),        -- Canadá
('Nintendo EPD', 3),            -- Japón
('FromSoftware', 3),            -- Japón
('Kojima Productions', 3),      -- Japón
('Valve Corporation', 1),       -- EEUU
('Riot Games', 1),              -- EEUU
('Blizzard Entertainment', 1),  -- EEUU
('Guerrilla Games', 8),         -- Francia (Sede Paises Bajos, usando Francia como proxy Europeo)
('BioWare', 4),                 -- Canadá
('Square Enix', 3),             -- Japón (Actúa como Dev y Publisher)
('Capcom', 3),                  -- Japón (Actúa como Dev y Publisher)
('Remedy Entertainment', 11);   -- Finlandia
GO

-- 3. Nuevos Publishers Famosos
-- Asumiendo IDs de País: 1='EEUU', 3='Japón', 8='Francia'
PRINT 'Insertando 15 nuevos Publishers...'
INSERT INTO Publishers (Nombre, IdPais) VALUES 
('Electronic Arts', 1),                 -- EEUU
('Activision', 1),                      -- EEUU
('Ubisoft', 8),                         -- Francia
('Take-Two Interactive', 1),            -- EEUU (Dueño de Rockstar)
('Sony Interactive Entertainment', 1),  -- EEUU (Oficialmente la sede es de EEUU)
('Square Enix', 3),                     -- Japón
('Capcom', 3),                          -- Japón
('Bandai Namco', 3),                    -- Japón
('Sega', 3),                            -- Japón
('Bethesda Softworks', 1),              -- EEUU (Ahora parte de Microsoft)
('Valve Corporation', 1),               -- EEUU
('Riot Games', 1),                      -- EEUU
('Konami', 3),                          -- Japón
('Devolver Digital', 1),                -- EEUU (Famoso por Indies)
('Annapurna Interactive', 1);          -- EEUU (Famoso por Indies)
GO

PRINT '--- Lote 3 de Inserciones Finalizado ---'
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 20 Usuarios (Lote 4.1) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('ShadowSlayer117', 'juan.perez@evolution.com', 'Juan', 'Perez', '1995-03-15', '2023-01-10'),
('CyberPunkette2077', 'maria.gomez@digital.net', 'Maria', 'Gomez', '2001-11-30', '2023-02-11'),
('martin_garcia88', 'martin.garcia@mail.com', 'Martin', 'Garcia', '1998-07-20', '2023-03-05'),
('VoidRunner42', 'lucas.diaz@proton.dev', 'Lucas', 'Diaz', '1992-01-05', '2023-04-19'),
('sofia_lopez12', 'sofia.lopez@user.io', 'Sofia', 'Lopez', '2003-09-12', '2023-05-22'),
('QuantumBladeZ', 'diego.mtz@evolution.com', 'Diego', 'Martinez', '1996-04-30', '2023-06-01'),
('ana_rocha9', 'ana.rodriguez@digital.net', 'Ana', 'Rodriguez', '1999-12-11', '2023-07-14'),
('OmegaKnight7', 'carlos.sanchez@mail.com', 'Carlos', 'Sanchez', '1990-10-08', '2023-08-20'),
('PixelWizard_1', 'laura.ramirez@proton.dev', 'Laura', 'Ramirez', '2000-06-25', '2023-09-03'),
('javi_flores22', 'javier.flores@user.io', 'Javier', 'Flores', '1993-02-28', '2023-10-16'),
('NeonStriker00', 'valentina.torres@evolution.com', 'Valentina', 'Torres', '2002-08-05', '2023-11-28'),
('dani_rivera3', 'daniel.rivera@digital.net', 'Daniel', 'Rivera', '1997-05-14', '2023-12-09'),
('AstroFox81', 'paula.gimenez@mail.com', 'Paula', 'Gimenez', '1994-11-02', '2024-01-15'),
('RogueAgent47', 'miguel.ortiz@proton.dev', 'Miguel', 'Ortiz', '1991-07-17', '2024-02-22'),
('camila_castro19', 'camila.castro@user.io', 'Camila', 'Castro', '2004-03-03', '2024-03-30'),
('GlitchMasterX', 'nicolas.romero@evolution.com', 'Nicolas', 'Romero', '1998-12-24', '2024-04-11'),
('CrimsonReaper', 'gabriela.mendoza@digital.net', 'Gabriela', 'Mendoza', '1999-01-19', '2024-05-18'),
('matias_vargas7', 'matias.vargas@mail.com', 'Matias', 'Vargas', '1995-09-09', '2024-06-25'),
('ZeroCool_1995', 'lucia.ruiz@proton.dev', 'Lucia', 'Ruiz', '2001-10-27', '2024-07-07'),
('SolarFlare22', 'andres.silva@user.io', 'Andres', 'Silva', '1997-08-31', '2024-08-14');

GO
PRINT '--- Tanda de 20 Usuarios (Lote 4.1) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 20 Usuarios (Lote 4.2) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('SteelHeart', 'sergio.ramos@mail.com', 'Sergio', 'Ramos', '1996-10-20', '2024-08-21'),
('carla_gomez99', 'carla.gomez@digital.net', 'Carla', 'Gomez', '1999-04-12', '2024-08-25'),
('BioSynthWave', 'roberto.diaz@evolution.com', 'Roberto', 'Diaz', '1992-07-03', '2024-09-02'),
('helena_paz5', 'helena.paz@proton.dev', 'Helena', 'Paz', '2001-02-18', '2024-09-15'),
('LunarSpecter', 'luis.mendez@user.io', 'Luis', 'Mendez', '1993-11-09', '2024-09-30'),
('QuickSilver23', 'julia.castillo@mail.com', 'Julia', 'Castillo', '1997-01-22', '2024-10-04'),
('ivan_soto_8', 'ivan.soto@digital.net', 'Ivan', 'Soto', '1995-08-16', '2024-10-18'),
('CrimsonFang', 'fernanda.navarro@evolution.com', 'Fernanda', 'Navarro', '2000-03-29', '2024-10-29'),
('ZeroTolerance', 'oscar.aguilar@proton.dev', 'Oscar', 'Aguilar', '1990-12-07', '2024-11-05'),
('eli_morales_g', 'elisa.morales@user.io', 'Elisa', 'Morales', '2003-05-11', '2024-11-12'),
('DataPhreak77', 'francisco.benitez@mail.com', 'Francisco', 'Benitez', '1994-06-08', '2024-11-20'),
('RogueJester', 'patricia.reyes@digital.net', 'Patricia', 'Reyes', '1998-04-01', '2024-12-01'),
('victor_cabrera', 'victor.cabrera@evolution.com', 'Victor', 'Cabrera', '1996-09-14', '2024-12-15'),
('AlphaWolf_2', 'teresa.mendoza@proton.dev', 'Teresa', 'Mendoza', '1992-11-26', '2024-12-28'),
('EcoStriker', 'eduardo.vargas@user.io', 'Eduardo', 'Vargas', '2002-02-02', '2025-01-07'),
('gabriel_ruiz94', 'gabriel.ruiz@mail.com', 'Gabriel', 'Ruiz', '1994-10-13', '2025-01-20'),
('MysticMind', 'hugo.iglesias@digital.net', 'Hugo', 'Iglesias', '1997-07-07', '2025-02-03'),
('NetRunner_80', 'beatriz.soto@evolution.com', 'Beatriz', 'Soto', '1993-03-18', '2025-02-19'),
('pedro_moreno', 'pedro.moreno@proton.dev', 'Pedro', 'Moreno', '2000-11-11', '2025-03-05'),
('Hyperion_G', 'yolanda.paz@user.io', 'Yolanda', 'Paz', '1991-04-25', '2025-03-20');

GO
PRINT '--- Tanda de 20 Usuarios (Lote 4.2) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 20 Usuarios (Lote 4.3) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('emilio_reye90', 'emiliore2522@@digital.net', 'Emilio', 'Reyes', '1999-05-22', '2024-01-20');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('AzureWave429', 'alejandrofr702@@user.io', 'Alejandro', 'Franco', '2005-11-03', '2025-02-11');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('AstroWave107', 'zacariasca510@@user.io', 'Zacarias', 'Castillo', '1993-11-07', '2023-06-29');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('victor_camp21', 'victorca615@@gmx.com', 'Victor', 'Campos', '2003-10-13', '2023-10-04');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('LightCore758', 'pedrolu4441@@mail.com', 'Pedro', 'Luna', '1988-10-29', '2025-04-07');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('sara_gome2', 'sarago5340@@proton.dev', 'Sara', 'Gomez', '2005-03-14', '2023-11-19');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('quintin_diaz30', 'quintindi5931@@proton.dev', 'Quintin', 'Diaz', '2003-09-29', '2024-05-30');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('CrimsonWizard831', 'renatasa1962@@evolution.com', 'Renata', 'Salazar', '2004-09-13', '2024-12-19');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('matias_ramo90', 'matiasra3235@@digital.net', 'Matias', 'Ramos', '1989-04-21', '2023-11-17');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('renata_flor57', 'renatafl176@@mail.com', 'Renata', 'Flores', '2004-01-23', '2023-01-12');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('valeria_rios55', 'valeriari6388@@evolution.com', 'Valeria', 'Rios', '2001-12-05', '2025-02-25');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('ZeroStorm856', 'laurato887@@user.io', 'Laura', 'Torres', '2004-12-17', '2023-08-28');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('raul_more64', 'raulmo7744@@evolution.com', 'Raul', 'Moreno', '1989-10-07', '2024-03-16');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('NeonRider638', 'quintinsi527@@proton.dev', 'Quintin', 'Silva', '1999-03-23', '2024-11-15');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('SolarKing485', 'carloslo9994@@digital.net', 'Carlos', 'Lopez', '1993-05-13', '2024-07-22');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('diego_cast86', 'diegoca7383@@mail.com', 'Diego', 'Castillo', '2000-11-10', '2025-06-23');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('SteelWizard589', 'javiersa6410@@gmx.com', 'Javier', 'Salazar', '2002-06-04', '2025-06-23');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('ShadowHeart664', 'julietaor4331@@gmx.com', 'Julieta', 'Ortiz', '1995-10-23', '2025-08-19');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('AlphaSoul442', 'valeriaal8549@@mail.com', 'Valeria', 'Alvarez', '1999-11-06', '2023-07-22');
INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('AzureKnight591', 'gabrielari4417@@mail.com', 'Gabriela', 'Rivera', '2005-10-28', '2024-01-10');

PRINT '--- Tanda de 20 Usuarios (Lote 4.3) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 20 Usuarios (Lote 4.4) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('QuantumJester', 'santiago.iglesias@mail.com', 'Santiago', 'Iglesias', '1995-12-01', '2025-04-01'),
('DarkHeart99', 'isabela.guzman@digital.net', 'Isabela', 'Guzman', '2000-07-22', '2025-04-05'),
('david_franco1', 'david.franco@evolution.com', 'David', 'Franco', '1996-03-10', '2025-04-12'),
('GhostReaper7', 'karla.salazar@proton.dev', 'Karla', 'Salazar', '1999-09-05', '2025-04-20'),
('IronMind88', 'kevin.vega@user.io', 'Kevin', 'Vega', '1991-06-12', '2025-05-01'),
('jorge_molina_5', 'jorge.molina@mail.com', 'Jorge', 'Molina', '1994-01-30', '2025-05-10'),
('AstroPulse', 'ursula.mendez@digital.net', 'Ursula', 'Mendez', '1997-11-07', '2025-05-15'),
('benja_acosta07', 'benjamin.acosta@evolution.com', 'Benjamin', 'Acosta', '2003-08-19', '2025-05-28'),
('SynthRunner22', 'wendy.rios@proton.dev', 'Wendy', 'Rios', '1998-05-02', '2025-06-03'),
('RogueBot_101', 'jose.hernandez@user.io', 'Jose', 'Hernandez', '1990-03-25', '2025-06-12'),
('hilda_guzman3', 'hilda.guzman@mail.com', 'Hilda', 'Guzman', '2002-10-10', '2025-06-20'),
('AlphaShift', 'luis.hernandez@digital.net', 'Luis', 'Hernandez', '1995-07-14', '2025-06-30'),
('QuickSoul', 'raul.flores@evolution.com', 'Raul', 'Flores', '1993-01-28', '2025-07-07'),
('elena_silva47', 'elena.silva@proton.dev', 'Elena', 'Silva', '2004-04-04', '2025-07-15'),
('CyberFang', 'oscar.perez@user.io', 'Oscar', 'Perez', '1997-02-17', '2025-07-22'),
('marta_diaz91', 'marta.diaz@mail.com', 'Marta', 'Diaz', '1991-09-30', '2025-08-01'),
('VoidStriker', 'xavier.navarro@digital.net', 'Xavier', 'Navarro', '1999-06-06', '2025-08-10'),
('TurboByte', 'natalia.lopez@evolution.com', 'Natalia', 'Lopez', '1996-08-23', '2025-08-19'),
('omar_castro11', 'omar.castro@proton.dev', 'Omar', 'Castro', '1994-12-14', '2025-08-28'),
('GlitchPunk', 'rosa.gimenez@user.io', 'Rosa', 'Gimenez', '2001-07-31', '2025-09-05');

GO
PRINT '--- Tanda de 20 Usuarios (Lote 4.4) Finalizada ---'
GO

USE EvolutionDB
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 20 Usuarios (Lote 4.5) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('juan_pablo_s', 'jp.soto@mail.com', 'Juan Pablo', 'Soto', '1998-05-15', '2025-09-10'),
('QuantumShift', 'ana.franco@digital.net', 'Ana', 'Franco', '2001-02-20', '2025-09-12'),
('DarkReaper_88', 'rodrigo.vega@evolution.com', 'Rodrigo', 'Vega', '1988-11-01', '2025-09-15'),
('clara_luna_12', 'clara.luna@proton.dev', 'Clara', 'Luna', '2003-01-25', '2025-09-18'),
('BioHazard_X', 'alberto.mendez@user.io', 'Alberto', 'Mendez', '1992-10-30', '2025-09-21'),
('SolarStriker', 'veronica.diaz@mail.com', 'Veronica', 'Diaz', '1996-07-19', '2025-09-24'),
('el_fede_95', 'federico.romero@digital.net', 'Federico', 'Romero', '1995-04-09', '2025-09-27'),
('MysticBot_v2', 'isidora.rios@evolution.com', 'Isidora', 'Rios', '1999-08-08', '2025-09-30'),
('sergio_reyes_k', 'sergio.reyes@proton.dev', 'Sergio', 'Reyes', '1997-03-14', '2025-10-02'),
('Quickdraw_GG', 'cecilia.castillo@user.io', 'Cecilia', 'Castillo', '2000-12-12', '2025-10-05'),
('NetPhreak_01', 'hernan.gomez@mail.com', 'Hernan', 'Gomez', '1990-06-21', '2025-10-08'),
('belen_medina', 'belen.medina@digital.net', 'Belen', 'Medina', '1998-02-14', '2025-10-10'),
('RogueSpecter', 'matias.hernandez@evolution.com', 'Matias', 'Hernandez', '1994-09-07', '2025-10-12'),
('LightFang', 'barbara.lopez@proton.dev', 'Barbara', 'Lopez', '2002-05-16', '2025-10-15'),
('emiliano_vega', 'emi.vega@user.io', 'Emiliano', 'Vega', '1997-10-23', '2025-10-18'),
('AstroSlayer', 'tomas.rodriguez@mail.com', 'Tomas', 'Rodriguez', '1999-01-01', '2025-10-20'),
('VoidNinja', 'gloria.perez@digital.net', 'Gloria', 'Perez', '1993-07-27', '2025-10-22'),
('santi_cabrera_f', 'santiago.cabrera@evolution.com', 'Santiago', 'Cabrera', '1996-12-30', '2025-10-25'),
('IronJester', 'ramiro.diaz@proton.dev', 'Ramiro', 'Diaz', '1991-08-15', '2025-10-28'),
('valen_sanchez_2', 'valentina.sanchez@user.io', 'Valentina', 'Sanchez', '2004-06-28', '2025-10-30');

GO
PRINT '--- Tanda de 20 Usuarios (Lote 4.5) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 30 Usuarios (Lote 4.6) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('hernan_luna81', 'hernanlu1218@@proton.dev', 'Hernan', 'Luna', '1989-08-09', '2024-09-05'),
('elena_rami26', 'elenara854@@proton.dev', 'Elena', 'Ramirez', '1991-04-19', '2023-11-30'),
('gloria_roja16', 'gloriaro7929@@user.io', 'Gloria', 'Rojas', '2003-11-16', '2025-09-11'),
('TurboPhreak403', 'kevinra2116@@user.io', 'Kevin', 'Ramos', '1985-05-20', '2025-04-28'),
('zacarias_ramo67', 'zacariasra3914@@mail.com', 'Zacarias', 'Ramos', '2003-08-14', '2025-10-20'),
('AlphaPhreak871', 'isidorasa9541@@user.io', 'Isidora', 'Sanchez', '1988-09-18', '2023-12-29'),
('MysticRider933', 'wendyri2339@@evolution.com', 'Wendy', 'Rivera', '1995-09-22', '2025-07-17'),
('GhostRunner945', 'gabrielaro4129@@digital.net', 'Gabriela', 'Rodriguez', '1987-09-04', '2024-08-27'),
('belen_ruiz63', 'belenru4495@@proton.dev', 'Belen', 'Ruiz', '2005-05-16', '2025-05-29'),
('NeonSlayer345', 'gloriato5142@@proton.dev', 'Gloria', 'Torres', '1988-05-01', '2024-02-16'),
('camila_roja30', 'camilaro8008@@mail.com', 'Camila', 'Rojas', '1990-08-02', '2024-05-22'),
('NeonStriker270', 'lauraca7316@@evolution.com', 'Laura', 'Campos', '1994-09-29', '2024-07-11'),
('ana_mart73', 'anama5334@@gmx.com', 'Ana', 'Martinez', '1988-08-09', '2024-09-22'),
('belen_vega16', 'belenve4021@@mail.com', 'Belen', 'Vega', '1986-09-13', '2023-03-12'),
('yolanda_pena43', 'yolandape4058@@proton.dev', 'Yolanda', 'Pena', '1996-03-15', '2024-09-01'),
('DataPulse234', 'santiagomo936@@gmx.com', 'Santiago', 'Morales', '1993-09-29', '2025-05-15'),
('teresa_pere50', 'teresape42@@user.io', 'Teresa', 'Perez', '2003-01-31', '2023-11-25'),
('miguel_pena61', 'miguelpe149@@gmx.com', 'Miguel', 'Pena', '2005-10-04', '2024-03-27'),
('TurboBlade583', 'luciame9356@@mail.com', 'Lucia', 'Medina', '1993-01-19', '2023-11-11'),
('ursula_mora88', 'ursulamo1223@@user.io', 'Ursula', 'Morales', '1998-12-07', '2023-05-24'),
('IronSlayer334', 'belenra4823@@mail.com', 'Belen', 'Ramirez', '2000-04-11', '2023-06-11'),
('AstroCore797', 'valeriasa9265@@proton.dev', 'Valeria', 'Sanchez', '1988-08-02', '2023-05-04'),
('ursula_gonz1', 'ursulago9711@@gmx.com', 'Ursula', 'Gonzalez', '1992-09-03', '2024-10-16'),
('MysticKing608', 'juanag1538@@proton.dev', 'Juan', 'Aguilar', '1991-02-27', '2024-12-12'),
('natalia_hern60', 'nataliahe7924@@evolution.com', 'Natalia', 'Hernandez', '1993-10-19', '2024-11-09'),
('zacarias_fran27', 'zacariasfr8627@@user.io', 'Zacarias', 'Franco', '1989-02-12', '2023-07-15'),
('OmegaSlayer30', 'carolinago8680@@user.io', 'Carolina', 'Gonzalez', '1990-01-02', '2023-05-03'),
('omar_roja4', 'omarro913@@mail.com', 'Omar', 'Rojas', '1997-08-12', '2024-09-27'),
('oscar_igle61', 'oscarig6055@@user.io', 'Oscar', 'Iglesias', '2000-06-10', '2023-01-20'),
('natalia_garc39', 'nataliaga945@@user.io', 'Natalia', 'Garcia', '1999-11-24', '2023-11-14');

PRINT '--- Tanda de 30 Usuarios (Lote 4.6) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 30 Usuarios (Lote 4.7) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('carlos_fern71', 'carlosfe7097@@mail.com', 'Carlos', 'Fernandez', '1998-10-14', '2023-01-28'),
('QuantumSoul112', 'camilaga7943@@mail.com', 'Camila', 'Garcia', '1996-03-24', '2023-11-20'),
('jorge_gonz97', 'jorgego2647@@user.io', 'Jorge', 'Gonzalez', '2005-12-25', '2023-04-18'),
('jorge_sanc14', 'jorgesa5737@@digital.net', 'Jorge', 'Sanchez', '1990-12-19', '2025-05-18'),
('AstroStorm391', 'andresca869@@mail.com', 'Andres', 'Castillo', '1994-04-06', '2025-02-12'),
('VoidFox391', 'andresmo9652@@gmx.com', 'Andres', 'Moreno', '1993-11-23', '2023-11-09'),
('ZeroByte531', 'ursulago1053@@user.io', 'Ursula', 'Gonzalez', '1990-11-13', '2024-03-12'),
('ShadowRider369', 'pedrogo9506@@digital.net', 'Pedro', 'Gonzalez', '1991-09-17', '2025-07-28'),
('CrimsonMind213', 'luispe5205@@gmx.com', 'Luis', 'Perez', '2001-08-01', '2025-01-28'),
('hugo_rom_94', 'hugoro4662@@proton.dev', 'Hugo', 'Romero', '1986-07-29', '2025-05-12'),
('AstroHawk131', 'anara9902@@proton.dev', 'Ana', 'Ramirez', '1990-09-08', '2024-11-26'),
('raul_vega45', 'raulve4024@@user.io', 'Raul', 'Vega', '1994-06-18', '2025-02-23'),
('benja_diaz83', 'benjadi9078@@user.io', 'Benja', 'Diaz', '2002-11-04', '2023-11-07'),
('LightWizard430', 'wendyfl7661@@proton.dev', 'Wendy', 'Flores', '1994-03-22', '2024-07-16'),
('xavier_flor56', 'xavierfl5617@@mail.com', 'Xavier', 'Flores', '2001-09-22', '2023-04-16'),
('SolarReaper816', 'julietahe1345@@evolution.com', 'Julieta', 'Hernandez', '1995-10-18', '2025-06-03'),
('isabela_orti45', 'isabelaor6709@@user.io', 'Isabela', 'Ortiz', '1990-09-04', '2024-03-25'),
('OmegaJester130', 'albertofl9723@@user.io', 'Alberto', 'Flores', '1992-05-23', '2023-08-01'),
('CrimsonPunk670', 'lauraro9349@@evolution.com', 'Laura', 'Rodriguez', '1985-05-02', '2025-06-25'),
('EcoReaper911', 'lauralo907@@evolution.com', 'Laura', 'Lopez', '2005-08-16', '2023-03-01'),
('elena_sanc14', 'elenasa9964@@evolution.com', 'Elena', 'Sanchez', '1994-11-25', '2025-07-01'),
('lucia_gonz54', 'luciago3105@@evolution.com', 'Lucia', 'Gonzalez', '2000-02-09', '2024-01-20'),
('clara_cast52', 'claraca3319@@gmx.com', 'Clara', 'Castro', '1996-03-20', '2024-11-01'),
('AstroKing739', 'ramirope8376@@evolution.com', 'Ramiro', 'Perez', '1990-03-12', '2023-04-13'),
('BioBlade228', 'diegoro862@@proton.dev', 'Diego', 'Rodriguez', '1998-03-09', '2024-01-13'),
('AlphaHeart320', 'carolinahe4151@@gmx.com', 'Carolina', 'Hernandez', '1987-03-17', '2023-04-01'),
('HyperCore413', 'davidgo3268@@user.io', 'David', 'Gonzalez', '2004-06-25', '2024-12-07'),
('isabela_moli41', 'isabelamo9910@@digital.net', 'Isabela', 'Molina', '1988-12-25', '2024-07-29'),
('DarkQueen465', 'gabrielaro1050@@evolution.com', 'Gabriela', 'Romero', '1999-07-22', '2023-09-03'),
('martin_rami1', 'martinra5246@@mail.com', 'Martin', 'Ramirez', '1989-10-17', '2024-08-14');

PRINT '--- Tanda de 30 Usuarios (Lote 4.7) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 30 Usuarios (Lote 4.8) ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 30 Usuarios (Lote 4.8) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('carlos_sanch18', 'carlossa6030@@mail.com', 'Carlos', 'Sanchez', '1990-09-02', '2025-09-08'),
('CyberStorm325', 'andresmo8365@@user.io', 'Andres', 'Morales', '1987-05-18', '2023-11-23'),
('raul_alva62', 'raulal7428@@user.io', 'Raul', 'Alvarez', '2001-05-27', '2023-11-23'),
('AstroSlayer179', 'renataro1073@@user.io', 'Renata', 'Romero', '1990-10-18', '2024-04-18'),
('benja_cast51', 'benjaca4327@@gmx.com', 'Benja', 'Castillo', '1993-01-20', '2024-08-01'),
('CrimsonHeart458', 'hildafl6792@@user.io', 'Hilda', 'Flores', '1998-05-24', '2025-05-09'),
('ZeroPulse332', 'jorgemo1453@@proton.dev', 'Jorge', 'Moreno', '2000-09-17', '2025-08-07'),
('VoidKnight258', 'xavierhe4073@@user.io', 'Xavier', 'Herrera', '1992-06-03', '2024-11-09'),
('AlphaWizard679', 'lauraro4658@@proton.dev', 'Laura', 'Rodriguez', '2003-09-10', '2025-01-05'),
('xavier_moli54', 'xaviermo1271@@gmx.com', 'Xavier', 'Molina', '2003-12-04', '2023-01-28'),
('GlitchCore818', 'hugoal1895@@mail.com', 'Hugo', 'Alvarez', '2003-07-27', '2025-09-09'),
('kevin_soto24', 'kevinso1214@@digital.net', 'Kevin', 'Soto', '1993-03-08', '2023-09-12'),
('karla_gome49', 'karlago862@@proton.dev', 'Karla', 'Gomez', '1991-03-06', '2024-10-14'),
('GlitchWave835', 'juliadi7593@@evolution.com', 'Julia', 'Diaz', '1992-12-19', '2023-02-17'),
('clara_mend57', 'clarame1621@@mail.com', 'Clara', 'Mendoza', '1991-08-11', '2024-10-09'),
('ShadowStriker691', 'yolandafl6175@@digital.net', 'Yolanda', 'Flores', '1987-11-28', '2024-06-18'),
('SteelFang288', 'fernandafl5819@@evolution.com', 'Fernanda', 'Flores', '1990-10-13', '2024-08-12'),
('OmegaFox191', 'fernandahe5475@@mail.com', 'Fernanda', 'Hernandez', '1996-03-24', '2023-12-25'),
('jorge_rami35', 'jorgera7270@@digital.net', 'Jorge', 'Ramirez', '1991-09-16', '2023-11-29'),
('AstroSpecter186', 'patriciaro8558@@evolution.com', 'Patricia', 'Romero', '1996-10-12', '2023-07-06'),
('omar_sanc73', 'omarsa7064@@evolution.com', 'Omar', 'Sanchez', '1989-12-23', '2023-03-16'),
('DarkNinja422', 'martinri386@@evolution.com', 'Martin', 'Rios', '1986-06-18', '2024-06-25'),
('julieta_cast10', 'julietaca290@@mail.com', 'Julieta', 'Castro', '1998-10-25', '2023-01-08'),
('LightMind252', 'davidme706@@gmx.com', 'David', 'Mendez', '2000-09-11', '2025-06-12'),
('SteelBlade773', 'jorgega3799@@user.io', 'Jorge', 'Garcia', '1996-11-26', '2025-02-28'),
('BioShift121', 'laurago3001@@user.io', 'Laura', 'Gomez', '1989-05-24', '2023-11-28'),
('ZeroStriker991', 'ivanra8873@@mail.com', 'Ivan', 'Ramos', '1992-06-24', '2023-03-24'),
('CrimsonBot374', 'isidorame608@@proton.dev', 'Isidora', 'Medina', '1998-08-01', '2025-07-29'),
('omar_orti3', 'omaror137@@user.io', 'Omar', 'Ortiz', '1987-01-14', '2025-07-03'),
('jose_more50', 'josemo861@@mail.com', 'Jose', 'Moreno', '2005-09-08', '2024-04-18');

PRINT '--- Tanda de 30 Usuarios (Lote 4.8) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 30 Usuarios (Lote 4.8) ---'
GO

INSERT INTO Usuarios (NombreUsuario, Email, Nombre, Apellido, FechaNacimiento, FechaRegistro) VALUES 
('QuantumGhost559', 'claraac7723@@proton.dev', 'Clara', 'Acosta', '1998-05-13', '2023-01-28'),
('lucas_silv11', 'lucassi3685@@digital.net', 'Lucas', 'Silva', '2000-02-12', '2023-09-02'),
('LightStriker687', 'luispe5207@@mail.com', 'Luis', 'Pena', '1993-02-15', '2024-03-24'),
('AlphaReaper112', 'danielave5862@@mail.com', 'Daniela', 'Vega', '1990-09-17', '2025-06-25'),
('julieta_rami33', 'julietara3312@@gmx.com', 'Julieta', 'Ramirez', '1997-01-08', '2023-08-01'),
('DarkSlayer219', 'luisgo7304@@evolution.com', 'Luis', 'Gonzalez', '1989-10-09', '2024-03-09'),
('ZeroPulse591', 'ivanme7132@@user.io', 'Ivan', 'Mendez', '2001-05-06', '2025-06-19'),
('EcoBot626', 'isidorame6798@@proton.dev', 'Isidora', 'Medina', '1997-09-21', '2024-10-02'),
('VoidSoul123', 'carolinafl1422@@digital.net', 'Carolina', 'Flores', '1993-12-16', '2023-06-27'),
('sara_vega3', 'sarave9124@@user.io', 'Sara', 'Vega', '1987-05-27', '2025-01-14'),
('jose_guzm3', 'josegu2847@@evolution.com', 'Jose', 'Guzman', '1986-07-25', '2023-03-16'),
('AstroHawk788', 'javierhe4292@@gmx.com', 'Javier', 'Hernandez', '1994-01-18', '2023-02-17'),
('CyberHeart474', 'joseca7172@@gmx.com', 'Jose', 'Campos', '1993-11-20', '2023-11-12'),
('kevin_soto54', 'kevinso1219@@digital.net', 'Kevin', 'Soto', '1986-12-28', '2024-08-27'),
('BioCore886', 'patriciamedina@user.io', 'Patricia', 'Medina', '1995-10-18', '2025-07-29'),
('IronKnight397', 'franciscohe3705@@mail.com', 'Francisco', 'Herrera', '1995-10-11', '2023-07-06'),
('karla_more19', 'karlamo4297@@mail.com', 'Karla', 'Morales', '2004-12-07', '2023-03-24'),
('jorge_rami12', 'jorgera7270@@digital.net', 'Jorge', 'Ramirez', '1991-09-16', '2023-11-29'),
('AstroSpecter986', 'patriciaro8558@@evolution.com', 'Patricia', 'Romero', '1996-10-12', '2023-07-06'),
('omar_sanc73', 'omarsa7064@@evolution.com', 'Omar', 'Sanchez', '1989-12-23', '2023-03-16'),
('DarkNinja422', 'martinri386@@evolution.com', 'Martin', 'Rios', '1986-06-18', '2024-06-25'),
('julieta_cast10', 'julietaca290@@mail.com', 'Julieta', 'Castro', '1998-10-25', '2023-01-08'),
('LightMind252', 'davidme706@@gmx.com', 'David', 'Mendez', '2000-09-11', '2025-06-12'),
('SteelBlade773', 'jorgega3799@@user.io', 'Jorge', 'Garcia', '1996-11-26', '2025-02-28'),
('BioShift121', 'laurago3001@@user.io', 'Laura', 'Gomez', '1989-05-24', '2023-11-28'),
('ZeroStriker991', 'ivanra8873@@mail.com', 'Ivan', 'Ramos', '1992-06-24', '2023-03-24'),
('CrimsonBot374', 'isidorame608@@proton.dev', 'Isidora', 'Medina', '1998-08-01', '2025-07-29'),
('omar_orti3', 'omaror137@@user.io', 'Omar', 'Ortiz', '1987-01-14', '2025-07-03'),
('jose_more50', 'josemo861@@mail.com', 'Jose', 'Moreno', '2005-09-08', '2024-04-18'),
('martin_rami1', 'martinra5246@@mail.com', 'Martin', 'Ramirez', '1989-10-17', '2024-08-14');

PRINT '--- Tanda de 30 Usuarios (Lote 4.8) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Juegos (Lote 5) ---'
GO

-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('Red Dead Redemption 2', 'Aventura de vaqueros en un mundo abierto masivo.', '2018-10-26', 3, 'Publicado'),
('Elden Ring', 'RPG de accion de FromSoftware en un vasto mundo de fantasia.', '2022-02-25', 3, 'Publicado'),
('Grand Theft Auto V', 'Mundo abierto de crimenes en la ciudad de Los Santos.', '2013-09-17', 3, 'Publicado'),
('The Legend of Zelda: Breath of the Wild', 'Aventura epica de exploracion en Hyrule.', '2017-03-03', 2, 'Publicado'),
('God of War (2018)', 'Kratos viaja por la mitologia nordica con su hijo Atreus.', '2018-04-20', 3, 'Publicado'),
('God of War Ragnarök', 'La conclusion de la saga nordica de Kratos y Atreus.', '2022-11-09', 3, 'Publicado'),
('Marvels Spider-Man', 'Aventura de accion balanceandose por Nueva York.', '2018-09-07', 2, 'Publicado'),
('The Last of Us Part II', 'La secuela de la aclamada historia de supervivencia y venganza.', '2020-06-19', 3, 'Publicado'),
('DOOM (2016)', 'Shooter en primera persona de alta velocidad contra demonios.', '2016-05-13', 3, 'Publicado'),
('DOOM Eternal', 'La secuela de DOOM, aun mas rapida y brutal.', '2020-03-20', 3, 'Publicado'),
('Resident Evil 4 (Remake)', 'Remake del clasico survival horror de 2005.', '2023-03-24', 3, 'Publicado'),
('Resident Evil Village', 'Survival horror que continua la historia de Ethan Winters.', '2021-05-07', 3, 'Publicado'),
('Horizon Zero Dawn', 'Aloy caza maquinas roboticas en un mundo post-apocaliptico.', '2017-02-28', 2, 'Publicado'),
('Ghost of Tsushima', 'Un samurai lucha por liberar la isla de Tsushima.', '2020-07-17', 3, 'Publicado'),
('Uncharted 4: A Thiefs End', 'La ultima aventura del cazatesoros Nathan Drake.', '2016-05-10', 2, 'Publicado'),
('Bloodborne', 'RPG de accion gotico y oscuro de FromSoftware.', '2015-03-24', 3, 'Publicado'),
('Sekiro: Shadows Die Twice', 'Accion y sigilo shinobi con combate de precision.', '2019-03-22', 3, 'Publicado'),
('Dark Souls III', 'La conclusion de la iconica saga de RPGs de accion.', '2016-03-24', 3, 'Publicado'),
('Hades', 'Roguelike de accion donde escapas del inframundo griego.', '2020-09-17', 2, 'Publicado'),
('Celeste', 'Juego de plataformas de precision sobre salud mental.', '2018-01-25', 1, 'Publicado'),
('Persona 5 Royal', 'JRPG de estilo anime sobre ladrones fantasma.', '2019-10-31', 3, 'Publicado'),
('Control', 'Aventura de accion sobrenatural en la Oficina Federal de Control.', '2019-08-27', 3, 'Publicado'),
('Death Stranding', 'Aventura de mundo abierto sobre reconectar una sociedad fracturada.', '2019-11-08', 3, 'Publicado'),
('Final Fantasy VII Remake', 'Reimaginacion moderna de la primera parte del clasico JRPG.', '2020-04-10', 2, 'Publicado'),
('Helldivers 2', 'Shooter cooperativo de ciencia ficcion contra amenazas alienigenas.', '2024-02-08', 3, 'Publicado');

GO
PRINT '--- Tanda de 25 Juegos (Lote 5) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Juegos (Lote 6) ---'
GO

-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('Alan Wake 2', 'Survival horror psicologico siguiendo a un escritor y una agente del FBI.', '2023-10-27', 3, 'Publicado'),
('Diablo IV', 'RPG de accion isometrico en el oscuro mundo de Santuario.', '2023-06-05', 3, 'Publicado'),
('Starfield', 'RPG de exploracion espacial de Bethesda Game Studios.', '2023-09-06', 3, 'Publicado'),
('Forza Horizon 5', 'Juego de carreras arcade en un mundo abierto masivo en Mexico.', '2021-11-09', 1, 'Publicado'),
('Star Wars Jedi: Survivor', 'Secuela de la aventura de accion de Cal Kestis.', '2023-04-28', 2, 'Publicado'),
('Dead Space (Remake)', 'Remake del clasico survival horror espacial.', '2023-01-27', 3, 'Publicado'),
('Mass Effect Legendary Edition', 'Remasterizacion de la trilogia de RPG de ciencia ficcion.', '2021-05-14', 3, 'Publicado'),
('It Takes Two', 'Aventura de plataformas diseñada exclusivamente para cooperativo.', '2021-03-26', 2, 'Publicado'),
('Lethal Company', 'Juego indie de terror cooperativo sobre recoleccion de chatarra.', '2023-10-23', 3, 'Acceso Anticipado'),
('Palworld', 'Juego de supervivencia y crafteo con criaturas.', '2024-01-19', 2, 'Acceso Anticipado'),
('Mortal Kombat 1', 'Reinicio de la saga de lucha con graficos viscerales.', '2023-09-19', 3, 'Publicado'),
('Street Fighter 6', 'Juego de lucha moderno con nuevos sistemas de combate.', '2023-06-02', 2, 'Publicado'),
('Lies of P', 'Soulslike de accion ambientado en una version oscura de Pinocho.', '2023-09-18', 3, 'Publicado'),
('Sea of Thieves', 'Aventura de piratas en un mundo abierto multijugador.', '2018-03-20', 2, 'Publicado'),
('Microsoft Flight Simulator', 'Simulador de vuelo hiperrealista del mundo entero.', '2020-08-18', 1, 'Publicado'),
('The Sims 4', 'Simulador de vida donde creas y controlas personas.', '2014-09-02', 2, 'Publicado'),
('Valheim', 'Juego de supervivencia y exploracion ambientado en la mitologia nordica.', '2021-02-02', 2, 'Acceso Anticipado'),
('Deep Rock Galactic', 'Shooter cooperativo de enanos espaciales mineros.', '2020-05-13', 2, 'Publicado'),
('Nier: Automata', 'RPG de accion filosofico sobre androides en un mundo post-apocaliptico.', '2017-02-23', 3, 'Publicado'),
('Ori and the Will of the Wisps', 'Aventura de plataformas Metroidvania con graficos hermosos.', '2020-03-11', 1, 'Publicado'),
('Subnautica', 'Supervivencia y exploracion en un planeta alienigena oceanico.', '2018-01-23', 2, 'Publicado'),
('Outer Wilds', 'Aventura de exploracion espacial basada en un bucle temporal.', '2019-05-30', 1, 'Publicado'),
('Disco Elysium', 'RPG de dialogo profundo sin combate tradicional.', '2019-10-15', 3, 'Publicado'),
('Cuphead', 'Juego de accion run-and-gun con estetica de dibujos animados de 1930.', '2017-09-29', 1, 'Publicado'),
('Rocket League', 'Futbol arcade con autos a reaccion.', '2015-07-07', 1, 'Publicado');

GO
PRINT '--- Tanda de 25 Juegos (Lote 6) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Juegos (Lote 7) ---'
GO

-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('The Elder Scrolls V: Skyrim', 'Aventura de rol epica en un mundo abierto nordico lleno de dragones.', '2011-11-11', 3, 'Publicado'),
('Fallout 4', 'RPG post-apocaliptico en el area de Boston, con construccion de asentamientos.', '2015-11-10', 3, 'Publicado'),
('Divinity: Original Sin 2', 'RPG tactico por turnos con una profunda narrativa y libertad de eleccion.', '2017-09-14', 3, 'Publicado'),
('Monster Hunter: World', 'Juego de accion y caza de monstruos gigantes en un ecosistema vivo.', '2018-01-26', 2, 'Publicado'),
('Borderlands 3', 'Shooter-looter en primera persona con miles de millones de armas y humor irreverente.', '2019-09-13', 3, 'Publicado'),
('Assassin''s Creed Odyssey', 'Aventura de rol en la antigua Grecia con decisiones narrativas.', '2018-10-05', 3, 'Publicado'),
('Assassin''s Creed Valhalla', 'Invasion vikinga de Inglaterra en un masivo mundo abierto de rol.', '2020-11-10', 3, 'Publicado'),
('Far Cry 5', 'Shooter en primera persona en un condado rural de EEUU controlado por un culto.', '2018-03-27', 3, 'Publicado'),
('Far Cry 6', 'Shooter en primera persona para liberar la isla tropical de Yara de un dictador.', '2021-10-07', 3, 'Publicado'),
('Titanfall 2', 'Shooter en primera persona aclamado por su campaña y movilidad fluida.', '2016-10-28', 3, 'Publicado'),
('Apex Legends', 'Battle Royale de heroes con habilidades unicas y jugabilidad rapida.', '2019-02-04', 2, 'Publicado'),
('Rainbow Six Siege', 'Shooter tactico 5v5 enfocado en la destruccion de entornos y combate cercano.', '2015-12-01', 3, 'Publicado'),
('Slay the Spire', 'Juego de cartas roguelike de construccion de mazos.', '2019-01-23', 1, 'Publicado'),
('Dead Cells', 'Metroidvania de accion roguelite de ritmo rapido.', '2018-08-06', 2, 'Publicado'),
('Portal 2', 'Juego de puzzles en primera persona basado en portales con una gran campaña coop.', '2011-04-19', 1, 'Publicado'),
('Half-Life: Alyx', 'La experiencia insignia de Realidad Virtual de Valve.', '2020-03-23', 3, 'Publicado'),
('Factorio', 'Juego de gestion y automatizacion de fabricas en un planeta alienigena.', '2020-08-14', 1, 'Publicado'),
('Terraria', 'Sandbox 2D de aventura, crafteo, construccion y combate.', '2011-05-16', 2, 'Publicado'),
('No Man''s Sky', 'Exploracion espacial infinita en un universo generado proceduralmente.', '2016-08-09', 1, 'Publicado'),
('Hitman 3', 'Conclusion de la trilogia de sigilo y asesinatos creativos del Agente 47.', '2021-01-20', 3, 'Publicado'),
('Metal Gear Solid V: The Phantom Pain', 'Sigilo y accion tactica en un mundo abierto.', '2015-09-01', 3, 'Publicado'),
('A Plague Tale: Requiem', 'Secuela de la oscura aventura narrativa en la Francia medieval.', '2022-10-18', 3, 'Publicado'),
('Garry''s Mod', 'Sandbox de fisicas que permite a los jugadores manipular objetos y crear modos de juego.', '2006-11-29', 2, 'Publicado'),
('Vampire Survivors', 'Roguelite minimalista de supervivencia contra hordas de monstruos.', '2022-10-20', 2, 'Publicado'),
('F1 23', 'Simulador de carreras oficial de la Formula 1.', '2023-06-16', 1, 'Publicado');

GO
PRINT '--- Tanda de 25 Juegos (Lote 7) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Juegos (Lote 8) ---'
GO

-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
INSERT INTO Juegos (Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
('Civilization VI', 'Juego de estrategia por turnos 4X. Construye un imperio que resista el paso del tiempo.', '2016-10-21', 2, 'Publicado'),
('XCOM 2', 'Estrategia tactica por turnos donde lideras la resistencia contra una invasion alienigena.', '2016-02-05', 3, 'Publicado'),
('The Last of Us Part I', 'Remake completo de la aclamada aventura narrativa post-apocaliptica.', '2022-09-02', 3, 'Publicado'),
('Demon''s Souls (Remake)', 'Remake del RPG de accion que definio el genero Soulslike.', '2020-11-12', 3, 'Publicado'),
('Ratchet & Clank: Rift Apart', 'Aventura de plataformas y accion interdimensional exclusiva de PS5.', '2021-06-11', 2, 'Publicado'),
('Returnal', 'Roguelike de accion y disparos en tercera persona con terror psicologico.', '2021-04-30', 3, 'Publicado'),
('Marvel''s Guardians of the Galaxy', 'Aventura de accion narrativa para un jugador con los Guardianes de la Galaxia.', '2021-10-26', 2, 'Publicado'),
('Hogwarts Legacy', 'RPG de accion en mundo abierto ambientado en el universo de Harry Potter en 1800.', '2023-02-10', 2, 'Publicado'),
('EA Sports FC 24', 'Simulador de futbol, sucesor de la saga FIFA.', '2023-09-29', 1, 'Publicado'),
('NBA 2K24', 'Simulador de baloncesto profesional de la temporada 2024.', '2023-09-08', 1, 'Publicado'),
('Madden NFL 24', 'Simulador de futbol americano profesional.', '2023-08-18', 1, 'Publicado'),
('Dead by Daylight', 'Juego de terror multijugador asimetrico 4 contra 1.', '2016-06-14', 3, 'Publicado'),
('Alien: Isolation', 'Survival horror en primera persona enfocado en el sigilo contra un xenomorfo.', '2014-10-07', 3, 'Publicado'),
('Metro Exodus', 'Shooter en primera persona post-apocaliptico con exploracion y supervivencia.', '2019-02-15', 3, 'Publicado'),
('Days Gone', 'Aventura de accion y supervivencia en mundo abierto infestado de "Freakers".', '2019-04-26', 3, 'Publicado'),
('Dying Light 2 Stay Human', 'Accion y parkour en un mundo abierto post-apocaliptico con zombies.', '2022-02-04', 3, 'Publicado'),
('Mount & Blade II: Bannerlord', 'Simulador de combate y estrategia medieval en un sandbox masivo.', '2022-10-25', 3, 'Publicado'),
('Total War: WARHAMMER III', 'Juego de estrategia por turnos y batallas en tiempo real.', '2022-02-17', 2, 'Publicado'),
('Crusader Kings III', 'Gran estrategia de rol donde controlas una dinastia real a traves de los siglos.', '2020-09-01', 2, 'Publicado'),
('Tekken 8', 'La mas reciente entrega de la legendaria saga de lucha en 3D.', '2024-01-26', 2, 'Publicado'),
('Guilty Gear -Strive-', 'Juego de lucha de anime con graficos revolucionarios y sistema de combate accesible.', '2021-06-11', 2, 'Publicado'),
('Yakuza: Like a Dragon', 'JRPG por turnos que sigue la historia de Ichiban Kasuga.', '2020-11-10', 3, 'Publicado'),
('Dragon Quest XI S', 'JRPG tradicional de fantasia con una historia epica y personajes memorables.', '2019-09-27', 2, 'Publicado'),
('Undertale', 'RPG indie donde nadie tiene que morir.', '2015-09-15', 2, 'Publicado'),
('Shovel Knight', 'Juego de plataformas de accion retro inspirado en los clasicos de 8 bits.', '2014-06-26', 1, 'Publicado');

GO
PRINT '--- Tanda de 25 Juegos (Lote 8) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Logros (Lote 9) ---'
GO

-- Logros para los juegos 1-25
INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(1, 'El Loco', 'Completa la mision principal de Cyberpunk 2077.'),
(2, 'El Orgullo del Abuelo', 'Alcanza la perfeccion en Stardew Valley.'),
(3, 'El Rey ha Muerto', 'Encuentra y mata al Rey de la Caceria Salvaje.'),
(4, 'En las fauces de la locura', 'Completa la Mazmorra Mas Oscura (Darkest Dungeon).'),
(5, 'El Fin', 'Derrota al Dragon del End.'),
(6, 'Heroe de los Reinos Olvidados', 'Completa el acto final de Baldurs Gate 3.'),
(7, 'El Sello Roto', 'Derrota al Hollow Knight.'),
(8, 'Metropoli', 'Alcanza una poblacion de 100,000 habitantes.'),
(9, 'Investigador Profesional', 'Identifica correctamente 50 fantasmas.'),
(10, 'Redencion', 'Completa la historia de Arthur Morgan.'),
(11, 'Señor de Elden', 'Obten todos los finales posibles.'),
(12, 'Bienvenido a Los Santos', 'Completa la introduccion de GTA V.'),
(13, 'La derrota de Ganon', 'Libera Hyrule de la calamidad.'),
(14, 'Padre e Hijo', 'Esparce las cenizas en la montaña mas alta.'),
(15, 'Ragnarök', 'Completa la profecia del Ragnarök.'),
(16, 'Un Gran Poder', 'Completa la historia principal de Marvels Spider-Man.'),
(17, 'Lo que fue necesario', 'Completa la historia de The Last of Us Part II.'),
(18, 'Descanse en Paz', 'Mata al Cyberdemonio en DOOM (2016).'),
(19, 'Cazador de Sacerdotes', 'Derrota a todos los Sacerdotes Infernales.'),
(20, 'Salvador de la Aldea', 'Completa el juego Resident Evil 4.'),
(21, 'Padre del Año', 'Encuentra a Rose en Resident Evil Village.'),
(22, 'Victoria sobre HADES', 'Derrota a HADES y descubre la verdad.'),
(23, 'El Fantasma de Tsushima', 'Libera la isla de los mongoles.'),
(24, 'El Fin de un Ladron', 'Encuentra el tesoro de Avery en Uncharted 4.'),
(25, 'Amanecer de Yharnam', 'Sobrevive a la caceria y presencia el amanecer.');

GO
PRINT '--- Tanda de 25 Logros (Lote 9) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Logros (Lote 10) ---'
GO

-- Logros para los juegos 26-50
INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(26, 'El Lobo de un solo brazo', 'Derrota a Genichiro Ashina en Sekiro.'),
(27, 'Enlazar la Primera Llama', 'Completa el final principal de Dark Souls III.'),
(28, '¿No hay escapatoria?', 'Completa una huida exitosa del inframundo en Hades.'),
(29, 'Mas alla de la cumbre', 'Alcanza la cima de la montaña Celeste.'),
(30, 'Ladron Fantasma Legendario', 'Completa el ultimo palacio en Persona 5 Royal.'),
(31, 'Toma el Control', 'Completa la mision final de Control.'),
(32, 'Mañana esta en tus manos', 'Reconecta America en Death Stranding.'),
(33, 'El Destino de Midgar', 'Completa el Remake de Final Fantasy VII.'),
(34, '¡Por la Supertierra!', 'Completa el entrenamiento basico de Helldivers 2.'),
(35, 'Regreso a Bright Falls', 'Sobrevive a la primera intrusion en Alan Wake 2.'),
(36, 'Heraldo de Lilith', 'Completa la campaña de Diablo IV.'),
(37, 'Hacia las estrellas', 'Unete a Constelacion en Starfield.'),
(38, 'Bienvenido a Mexico', 'Llega al festival Horizon en Forza Horizon 5.'),
(39, 'Superviviente de Koboh', 'Completa la historia de Star Wars Jedi: Survivor.'),
(40, 'Desmembramiento Estrategico', 'Sobrevive al primer encuentro en el Ishimura.'),
(41, 'Salva la Galaxia', 'Completa la trilogia Mass Effect.'),
(42, 'Terapia de Pareja', 'Completa el Libro del Amor en It Takes Two.'),
(43, 'Cumplimiento de Cuota', 'Alcanza la cuota de beneficios por primera vez.'),
(44, 'Maestro de Pals', 'Captura 50 tipos diferentes de Pals.'),
(45, 'Nuevo Comienzo', 'Completa el modo historia de Mortal Kombat 1.'),
(46, 'Campeon Mundial', 'Gana el torneo principal en el World Tour de SF6.'),
(47, 'El titere que miente', 'Derrota al jefe final de Lies of P.'),
(48, 'Leyenda Pirata', 'Alcanza el nivel maximo de reputacion con una faccion.'),
(49, 'Vuelta al Mundo', 'Completa un vuelo de larga distancia (2000+ NM).'),
(50, 'Arbol Genealogico', 'Haz que tu familia Sim llegue a la tercera generacion.');

GO
PRINT '--- Tanda de 25 Logros (Lote 10) Finalizada ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Logros (Lote 11) ---'
GO

-- Logros para los juegos 51-75
INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(51, 'Legado Familiar', 'Lleva una familia Sim a la tercera generacion.'),
(52, 'El Favor de Odin', 'Derrota al primer jefe, Eikthyr, en Valheim.'),
(53, '¡Roca y Piedra!', 'Completa tu primera mision de mineria profunda.'),
(54, 'Fin de la Ruta [A]', 'Completa la historia principal de 2B en Nier: Automata.'),
(55, 'Luz Restaurada', 'Salva el bosque de Niwen en Ori and the Will of the Wisps.'),
(56, 'Libre al Fin', 'Escapa del planeta 4546B en Subnautica.'),
(57, 'Eco del Ojo', 'Descubre el secreto del bucle temporal en Outer Wilds.'),
(58, 'El Detective Sobrio', 'Completa el primer dia sin consumir alcohol.'),
(59, 'Deuda Pagada', 'Derrota a todos los jefes de Inkwell Isle I.'),
(60, 'Sangre de Dragon', 'Absorbe tu primera alma de dragon en Skyrim.'),
(61, 'El Errante Solitario', 'Sal del Refugio 111 en Fallout 4.'),
(62, 'Divinidad Alcanzada', 'Asciende a la Divinidad en Fort Joy.'),
(63, 'Caceria Exitosa', 'Derrota a un Anjanath en Monster Hunter: World.'),
(64, '¡Hola, Cazacamaras!', 'Abre tu primera camara en Borderlands 3.'),
(65, 'El Culto Desenmascarado', 'Elimina a todos los miembros del Culto de Kosmos.'),
(66, 'Hogar, Dulce Hogar', 'Construye tu asentamiento en Inglaterra (AC Valhalla).'),
(67, 'Salvador de Hope', 'Libera el condado de Hope de Joseph Seed.'),
(68, '¡Viva la Revolucion!', 'Libera la isla de Yara de Anton Castillo.'),
(69, 'Confiad en mi', 'Completa la campaña de Titanfall 2.'),
(70, 'El Campeon', 'Gana una partida de Apex Legends.'),
(71, 'Muro Reforzado', 'Gana 10 rondas como Defensor en Rainbow Six Siege.'),
(72, 'El Fin?', 'Derrota al jefe del Acto 3 por primera vez.'),
(73, 'El Prisionero', 'Escapa de los Cuarteles de los Prisioneros en Dead Cells.'),
(74, 'Despertar Inoportuno', 'Despierta a GLaDOS en Portal 2.'),
(75, 'Enjaulada', 'Llega a la Boveda en Half-Life: Alyx.');

GO
PRINT '--- Tanda de 25 Logros (Lote 11) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 25 Logros (Lote 12) ---'
GO

-- Logros para los juegos 76-100
INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(76, 'Solo un turno mas...', 'Gana una partida de Civilization VI en cualquier dificultad.'),
(77, 'Comandante de la Resistencia', 'Completa la campaña y libera la Tierra en XCOM 2.'),
(78, 'Sobrevivir y Resistir', 'Completa la historia principal de The Last of Us Part I.'),
(79, 'Cazador de Demonios', 'Derrota al Demonio Falange en Demons Souls.'),
(80, 'Falla Dimensional', 'Atraviesa tu primera fisura dimensional en Ratchet & Clank.'),
(81, 'Ciclo Roto', 'Derrota al primer jefe (Phrike) en Returnal.'),
(82, '¡FLARK!', 'Completa el primer capitulo con los Guardianes de la Galaxia.'),
(83, 'El Sombrero Seleccionador', 'Se seleccionado para una de las cuatro casas de Hogwarts.'),
(84, 'Bienvenido a Ultimate Team', 'Gana tu primer partido en FC 24 Ultimate Team.'),
(85, 'Novato del Año', 'Completa tu primera temporada en el modo MyCareer de NBA 2K24.'),
(86, 'Touchdown', 'Anota tu primer touchdown en Madden NFL 24.'),
(87, 'Escapista', 'Escapa con exito de una prueba como Superviviente.'),
(88, 'No estoy solo', 'Sobrevive al primer encuentro con el Xenomorfo en Alien: Isolation.'),
(89, 'El Aurora', 'Encuentra la locomotora y forma tu tripulacion en Metro Exodus.'),
(90, 'Motociclista de Oregon', 'Consigue tu primera motocicleta con Deacon.'),
(91, 'Bienvenido a Villedor', 'Entra a la ciudad en Dying Light 2.'),
(92, 'Señor de la Guerra', 'Gana tu primera batalla de asedio en Mount & Blade II.'),
(93, 'Conquistador del Caos', 'Gana una campaña con cualquier faccion de Total War: WARHAMMER III.'),
(94, 'Fundador de Dinastia', 'Asegura que tu heredero tome el trono en Crusader Kings III.'),
(95, '¡KO Perfecto!', 'Gana una ronda de Tekken 8 sin recibir daño.'),
(96, 'Let''s Rock!', 'Completa el tutorial de Guilty Gear -Strive-.'),
(97, 'Heroe de Yokohama', 'Completa el Capitulo 1 de Yakuza: Like a Dragon.'),
(98, 'El Luminario', 'Acepta tu destino como el Luminario de Dragon Quest XI S.'),
(99, 'Determinacion', 'Llega al primer punto de guardado en Undertale.'),
(100, '¡Por la Pala!', 'Derrota al Caballero Negro por primera vez.');

GO
PRINT '--- Tanda de 25 Logros (Lote 12) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda Final de 9 Logros (Lote 13) ---'
GO

-- Logros para los juegos 101-109 (final del Lote 8)
INSERT INTO Logros (IdJuego, Nombre, Descripcion) VALUES 
(101, 'Rey de Calradia', 'Unifica el imperio bajo tu estandarte en Mount & Blade II.'),
(102, 'Dominio del Caos', 'Completa la campaña del Reino del Caos en Total War: WARHAMMER III.'),
(103, 'Legado Imperial', 'Funda un nuevo imperio que dure 100 años en Crusader Kings III.'),
(104, 'Campeon del Puño de Hierro', 'Completa el modo historia (The Dark Awakens) en Tekken 8.'),
(105, 'Destruccion Celestial', 'Ejecuta con exito un "Instant Kill" en Guilty Gear -Strive-.'),
(106, 'Heroe de Ijincho', 'Completa la historia de Ichiban Kasuga en Yakuza: Like a Dragon.'),
(107, 'Salvador de Erdea', 'Derrota al Heraldo Oscuro y salva el mundo en Dragon Quest XI S.'),
(108, 'Paciente', 'Completa la ruta Pacifista Verdadera en Undertale.'),
(109, '¡Ataque de Pala!', 'Derrota a La Hechicera y completa el juego.');

GO
PRINT '--- Tanda de 9 Logros (Lote 13) Finalizada ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Tanda de 70 DLCs (Lote 14) ---'
GO
-- IDs de Pegi: 1='PEGI 3', 2='PEGI 12', 3='PEGI 18'
-- Los IDs de Juego van del 1 al 109.
-- Los IDs de Dlc existentes (del Lote 2) son 1, 2, 3. Los nuevos empezaran en 4.

PRINT '--- Lote 14.1: Primeros 35 DLCs ---'
GO

INSERT INTO Dlcs (IdJuego, Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
-- Mas para The Witcher 3 (IdJuego 3)
(3, 'Blood and Wine', 'Una expansion masiva de 30 horas en la region de Toussaint.', '2016-05-31', 3, 'Publicado'),
(3, 'Hearts of Stone', 'Una nueva aventura de 10 horas con un hombre inmortal.', '2015-10-13', 3, 'Publicado'),
-- Mas para Cities: Skylines (IdJuego 8)
(8, 'Mass Transit', 'Nuevas formas de transporte publico para tu ciudad.', '2017-05-18', 1, 'Publicado'),
(8, 'Industries', 'Gestiona la cadena de produccion industrial en detalle.', '2018-10-23', 1, 'Publicado'),
(8, 'Green Cities', 'Nuevos edificios ecologicos y politicas verdes.', '2017-10-19', 1, 'Publicado'),
-- Para Elden Ring (IdJuego 11)
(11, 'Shadow of the Erdtree', 'Una nueva historia en la Tierra Sombria.', '2024-06-21', 3, 'Publicado'),
-- Para RDR2 (IdJuego 10)
(10, 'Red Dead Online', 'El componente multijugador de Red Dead Redemption 2.', '2018-11-27', 3, 'Publicado'),
-- Para God of War (2018) (IdJuego 14)
(14, 'God of War: Ragnarok - Valhalla', 'Epilogo roguelite gratuito.', '2023-12-12', 3, 'Gratuito'),
-- Para Horizon Zero Dawn (IdJuego 22)
(22, 'The Frozen Wilds', 'Aloy viaja a las heladas tierras de la tribu Banuk.', '2017-11-07', 2, 'Publicado'),
-- Para DOOM Eternal (IdJuego 19)
(19, 'The Ancient Gods - Part One', 'La primera expansion de la campaña.', '2020-10-20', 3, 'Publicado'),
(19, 'The Ancient Gods - Part Two', 'La conclusion epica de la saga del Slayer.', '2021-03-18', 3, 'Publicado'),
-- Para Resident Evil Village (IdJuego 21)
(21, 'Winters Expansion', 'Incluye la historia de "Shadows of Rose" y modo 3ra persona.', '2022-10-28', 3, 'Publicado'),
-- Para Control (IdJuego 31)
(31, 'The Foundation', 'Explora las raices de la Casa Inmemorial.', '2020-03-26', 3, 'Publicado'),
(31, 'AWE', 'Jesse investiga un Sector perdido de la agencia relacionado con Alan Wake.', '2020-08-27', 3, 'Publicado'),
-- Para The Sims 4 (IdJuego 51) - Tanda 1
(51, 'Get to Work', 'Controla a tus Sims en sus trabajos.', '2015-03-31', 2, 'Publicado'),
(51, 'Seasons', 'Añade climas, estaciones y festividades.', '2018-06-22', 2, 'Publicado'),
(51, 'Cats & Dogs', 'Añade perros y gatos a las familias de tus Sims.', '2017-11-10', 2, 'Publicado'),
(51, 'City Living', 'Muda a tus Sims a la vibrante ciudad de San Myshuno.', '2016-11-01', 2, 'Publicado'),
(51, 'Discover University', 'Envia a tus Sims a la universidad.', '2019-11-15', 2, 'Publicado'),
-- Para Skyrim (IdJuego 60)
(60, 'Dawnguard', 'Unete a los vampiros o a los cazadores de vampiros.', '2012-06-26', 3, 'Publicado'),
(60, 'Dragonborn', 'Viaja a la isla de Solstheim y enfrentate al primer Sangre de Dragon.', '2012-12-04', 3, 'Publicado'),
(60, 'Hearthfire', 'Construye tu propia casa y adopta niños.', '2012-09-04', 1, 'Publicado'),
-- Para Fallout 4 (IdJuego 61)
(61, 'Far Harbor', 'Investiga un caso en una isla misteriosa y radiactiva.', '2016-05-19', 3, 'Publicado'),
(61, 'Nuka-World', 'Explora un parque de atracciones de Nuka-Cola convertido en bastion de saqueadores.', '2016-08-30', 3, 'Publicado'),
(61, 'Automatron', 'Construye y personaliza tus propios robots acompañantes.', '2016-03-22', 3, 'Publicado'),
-- Para Civilization VI (IdJuego 76)
(76, 'Rise and Fall', 'Introduce mecanicas de Lealtad y Eras Doradas/Oscuras.', '2018-02-08', 1, 'Publicado'),
(76, 'Gathering Storm', 'Introduce desastres naturales y un Congreso Mundial.', '2019-02-14', 1, 'Publicado'),
(76, 'New Frontier Pass', 'Un pase de temporada con nuevas civilizaciones y modos de juego.', '2020-05-21', 1, 'Publicado'),
-- Para Monster Hunter: World (IdJuego 63)
(63, 'Iceborne', 'Una expansion masiva que añade un nuevo continente helado y monstruos.', '2019-09-06', 2, 'Publicado'),
-- Para Borderlands 3 (IdJuego 64)
(64, 'Moxxi''s Heist of the Handsome Jackpot', 'Primer DLC de campaña.', '2019-12-19', 3, 'Publicado'),
(64, 'Guns, Love, and Tentacles', 'Segundo DLC de campaña.', '2020-03-26', 3, 'Publicado'),
(64, 'Bounty of Blood', 'Tercer DLC de campaña.', '2020-06-25', 3, 'Publicado'),
(64, 'Psycho Krieg and the Fantastic Fustercluck', 'Cuarto DLC de campaña.', '2020-09-10', 3, 'Publicado'),
-- Para XCOM 2 (IdJuego 77)
(77, 'War of the Chosen', 'Expansion masiva que añade nuevas facciones, enemigos y clases.', '2017-08-29', 3, 'Publicado'),
-- Para Cuphead (IdJuego 59)
(59, 'The Delicious Last Course', 'Añade una nueva isla, jefes y a Ms. Chalice.', '2022-06-30', 1, 'Publicado');
GO

PRINT '--- Lote 14.1 Finalizado ---'
PRINT '--- Lote 14.2: Ultimos 35 DLCs ---'
GO

INSERT INTO Dlcs (IdJuego, Nombre, Descripcion, FechaLanzamiento, IdPegi, Estado) VALUES 
-- Para Total War: WARHAMMER III (IdJuego 98)
(98, 'Champions of Chaos', 'Nuevos Señores Legendarios para las facciones del Caos.', '2022-08-23', 2, 'Publicado'),
(98, 'Forge of the Chaos Dwarfs', 'Introduce la raza de los Enanos del Caos.', '2023-04-13', 2, 'Publicado'),
(98, 'Shadows of Change', 'Nuevas unidades y señores para Tzeentch, Kislev y Cathay.', '2023-08-31', 2, 'Publicado'),
-- Para Crusader Kings III (IdJuego 99)
(99, 'Northern Lords', 'Pack de sabor centrado en los Vikingos.', '2021-03-16', 2, 'Publicado'),
(99, 'Royal Court', 'Añade una sala del trono 3D, gestion de artefactos y cultura.', '2022-02-08', 2, 'Publicado'),
(99, 'Tours & Tournaments', 'Gestiona torneos, viajes y grandes bodas.', '2023-05-11', 2, 'Publicado'),
-- Para The Sims 4 (IdJuego 51) - Tanda 2
(51, 'Growing Together', 'Expansion centrada en las dinamicas familiares e hitos vitales.', '2023-03-16', 2, 'Publicado'),
(51, 'Eco Lifestyle', 'Tus Sims pueden impactar el medio ambiente de su mundo.', '2020-06-05', 2, 'Publicado'),
(51, 'Cottage Living', 'Vive de la tierra, cria animales y disfruta de la vida en el campo.', '2021-07-22', 2, 'Publicado'),
(51, 'High School Years', 'Vive la experiencia completa del instituto americano.', '2022-07-28', 2, 'Publicado'),
-- Para AC Odyssey (IdJuego 65)
(65, 'Legacy of the First Blade', 'Conoce al primer heroe en usar la hoja oculta.', '2018-12-04', 3, 'Publicado'),
(65, 'The Fate of Atlantis', 'Explora los reinos mitologicos de la Atlantida.', '2019-04-23', 3, 'Publicado'),
-- Para AC Valhalla (IdJuego 66)
(66, 'Wrath of the Druids', 'Viaja a Irlanda y desentraña los misterios de un culto druidico.', '2021-05-13', 3, 'Publicado'),
(66, 'The Siege of Paris', 'Participa en el historico asedio vikingo de Paris.', '2021-08-12', 3, 'Publicado'),
(66, 'Dawn of Ragnarök', 'Eivor debe abrazar su destino como Odin en el reino de Svartalfheim.', '2022-03-10', 3, 'Publicado'),
-- Para Resident Evil 4 Remake (IdJuego 11)
(11, 'Separate Ways', 'Vive la historia desde la perspectiva de Ada Wong.', '2023-09-21', 3, 'Publicado'),
-- Para Metro Exodus (IdJuego 89)
(89, 'The Two Colonels', 'Sigue la historia del Coronel Miller un año antes.', '2019-08-20', 3, 'Publicado'),
(89, 'Sam''s Story', 'Juega como Sam, un marine de EEUU buscando volver a casa.', '2020-02-11', 3, 'Publicado'),
-- Para Dead Cells (IdJuego 73)
(73, 'The Bad Seed', 'Nuevos biomas, enemigos y armas.', '2020-02-11', 2, 'Publicado'),
(73, 'Fatal Falls', 'Nuevos niveles, un nuevo jefe y mas equipo.', '2021-01-26', 2, 'Publicado'),
(73, 'The Queen and the Sea', 'Nuevos biomas finales y un jefe alternativo.', '2022-01-07', 2, 'Publicado'),
(73, 'Return to Castlevania', 'Crossover masivo con la legendaria saga de Konami.', '2023-03-06', 2, 'Publicado'),
-- Para Dying Light 2 (IdJuego 91)
(91, 'Bloody Ties', 'Entra en el torneo de lucha "Carnage Hall".', '2022-11-10', 3, 'Publicado'),
-- Para Factorio (IdJuego 78)
(78, 'Space Age', 'Expansion masiva que añade nuevos planetas y exploracion espacial.', '2024-10-21', 1, 'Publicado'),
-- Para Nier: Automata (IdJuego 54)
(54, '3C3C1D119440927', 'DLC de arenas de combate y trajes cosmeticos.', '2017-05-02', 3, 'Publicado'),
-- Para Deep Rock Galactic (IdJuego 53)
(53, 'Season 01: Rival Incursion', 'Pase de temporada gratuito con nuevos enemigos.', '2021-11-04', 2, 'Gratuito'),
(53, 'Season 02: Rival Escalation', 'Segundo pase de temporada gratuito.', '2022-04-28', 2, 'Gratuito'),
-- Para Slay the Spire (IdJuego 72)
(72, 'The Watcher', 'Cuarto personaje jugable, añadido como actualizacion gratuita.', '2020-01-14', 1, 'Gratuito'),
-- Para Hitman 3 (IdJuego 85)
(85, 'Seven Deadly Sins', 'Coleccion de 7 DLCs cosmeticos y misiones tematicas.', '2021-03-30', 3, 'Publicado'),
-- Para Alan Wake 2 (IdJuego 26)
(26, 'Night Springs', 'Juega como varios personajes en episodios de "Que pasaria si...".', '2024-06-08', 3, 'Publicado'),
(26, 'The Lake House', 'Expansion de historia que conecta universos.', '2024-10-22', 3, 'Publicado'),
-- Para Diablo IV (IdJuego 27)
(27, 'Vessel of Hatred', 'Expansion de historia completa en la region de Nahantu.', '2024-10-08', 3, 'Publicado'),
-- Para Mass Effect Legendary Edition (IdJuego 32)
(32, 'Genesis 2', 'Comic interactivo que resume los juegos anteriores.', '2021-05-14', 3, 'Publicado'),
-- Para Forza Horizon 5 (IdJuego 29)
(29, 'Hot Wheels', 'Expansion con pistas de Hot Wheels en el cielo.', '2022-07-19', 1, 'Publicado'),
(29, 'Rally Adventure', 'Expansion centrada en carreras de Rally en Sierra Nueva.', '2023-03-29', 1, 'Publicado');
GO

PRINT '--- Lote 14.2 Finalizado ---'
PRINT '--- 70 DLCs añadidos (Lotes 14.1 y 14.2) ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 15: Mapeo de Juegos y DLCs a Productos ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 15: Mapeo de Juegos y DLCs a Productos (Corregido) ---'
GO

-- -----------------------------------------------------------------
--          Lote 15.1: Mapeo de JUEGOS (IDs 10-109)
-- -----------------------------------------------------------------
-- (Los productos 1-12 ya fueron insertados en el Lote 2)
-- Mapeamos los 100 juegos restantes que agregamos en los lotes 5, 6, 7 y 8.

PRINT 'Insertando 100 Juegos restantes (10-109) en la tabla Productos...'
GO

INSERT INTO Productos (IdJuego, IdDlc, Tipo) VALUES 
(10, NULL, 'Juego'), (11, NULL, 'Juego'), (12, NULL, 'Juego'), (13, NULL, 'Juego'), (14, NULL, 'Juego'), (15, NULL, 'Juego'),
(16, NULL, 'Juego'), (17, NULL, 'Juego'), (18, NULL, 'Juego'), (19, NULL, 'Juego'), (20, NULL, 'Juego'), (21, NULL, 'Juego'),
(22, NULL, 'Juego'), (23, NULL, 'Juego'), (24, NULL, 'Juego'), (25, NULL, 'Juego'), (26, NULL, 'Juego'), (27, NULL, 'Juego'),
(28, NULL, 'Juego'), (29, NULL, 'Juego'), (30, NULL, 'Juego'), (31, NULL, 'Juego'), (32, NULL, 'Juego'), (33, NULL, 'Juego'),
(34, NULL, 'Juego'), (35, NULL, 'Juego'), (36, NULL, 'Juego'), (37, NULL, 'Juego'), (38, NULL, 'Juego'), (39, NULL, 'Juego'),
(40, NULL, 'Juego'), (41, NULL, 'Juego'), (42, NULL, 'Juego'), (43, NULL, 'Juego'), (44, NULL, 'Juego'), (45, NULL, 'Juego'),
(46, NULL, 'Juego'), (47, NULL, 'Juego'), (48, NULL, 'Juego'), (49, NULL, 'Juego'), (50, NULL, 'Juego'), (51, NULL, 'Juego'),
(52, NULL, 'Juego'), (53, NULL, 'Juego'), (54, NULL, 'Juego'), (55, NULL, 'Juego'), (56, NULL, 'Juego'), (57, NULL, 'Juego'),
(58, NULL, 'Juego'), (59, NULL, 'Juego'), (60, NULL, 'Juego'), (61, NULL, 'Juego'), (62, NULL, 'Juego'), (63, NULL, 'Juego'),
(64, NULL, 'Juego'), (65, NULL, 'Juego'), (66, NULL, 'Juego'), (67, NULL, 'Juego'), (68, NULL, 'Juego'), (69, NULL, 'Juego'),
(70, NULL, 'Juego'), (71, NULL, 'Juego'), (72, NULL, 'Juego'), (73, NULL, 'Juego'), (74, NULL, 'Juego'), (75, NULL, 'Juego'),
(76, NULL, 'Juego'), (77, NULL, 'Juego'), (78, NULL, 'Juego'), (79, NULL, 'Juego'), (80, NULL, 'Juego'), (81, NULL, 'Juego'),
(82, NULL, 'Juego'), (83, NULL, 'Juego'), (84, NULL, 'Juego'), (85, NULL, 'Juego'), (86, NULL, 'Juego'), (87, NULL, 'Juego'),
(88, NULL, 'Juego'), (89, NULL, 'Juego'), (90, NULL, 'Juego'), (91, NULL, 'Juego'), (92, NULL, 'Juego'), (93, NULL, 'Juego'),
(94, NULL, 'Juego'), (95, NULL, 'Juego'), (96, NULL, 'Juego'), (97, NULL, 'Juego'), (98, NULL, 'Juego'), (99, NULL, 'Juego'),
(100, NULL, 'Juego'), (101, NULL, 'Juego'), (102, NULL, 'Juego'), (103, NULL, 'Juego'), (104, NULL, 'Juego'), (105, NULL, 'Juego'),
(106, NULL, 'Juego'), (107, NULL, 'Juego'), (108, NULL, 'Juego'), (109, NULL, 'Juego');
GO

-- -----------------------------------------------------------------
--          Lote 15.2: Mapeo de DLCs (IDs 4-73)
-- -----------------------------------------------------------------
-- Mapeamos los 70 DLCs restantes que agregamos en el Lote 14.

INSERT INTO Generos (nombre) VALUES 
('Supervivencia'), -- ID 10
('Shooter'), -- ID 11
('Deportivo'), -- ID 12
('Mundo Abierto'), -- ID 13
('Indie'), -- ID 14
('Sigilo'); -- ID 15
GO


PRINT '--- Lote 9.1 Finalizado: 9 Generos nuevos añadidos ---'
GO


PRINT 'Insertando 70 DLCs restantes (4-73) en la tabla Productos...'
GO

INSERT INTO Productos (IdJuego, IdDlc, Tipo) VALUES 
(NULL, 4, 'DLC'), (NULL, 5, 'DLC'), (NULL, 6, 'DLC'), (NULL, 7, 'DLC'), (NULL, 8, 'DLC'), (NULL, 9, 'DLC'), (NULL, 10, 'DLC'),
(NULL, 11, 'DLC'), (NULL, 12, 'DLC'), (NULL, 13, 'DLC'), (NULL, 14, 'DLC'), (NULL, 15, 'DLC'), (NULL, 16, 'DLC'), (NULL, 17, 'DLC'),
(NULL, 18, 'DLC'), (NULL, 19, 'DLC'), (NULL, 20, 'DLC'), (NULL, 21, 'DLC'), (NULL, 22, 'DLC'), (NULL, 23, 'DLC'), (NULL, 24, 'DLC'),
(NULL, 25, 'DLC'), (NULL, 26, 'DLC'), (NULL, 27, 'DLC'), (NULL, 28, 'DLC'), (NULL, 29, 'DLC'), (NULL, 30, 'DLC'), (NULL, 31, 'DLC'),
(NULL, 32, 'DLC'), (NULL, 33, 'DLC'), (NULL, 34, 'DLC'), (NULL, 35, 'DLC'), (NULL, 36, 'DLC'), (NULL, 37, 'DLC'), (NULL, 38, 'DLC'),
(NULL, 39, 'DLC'), (NULL, 40, 'DLC'), (NULL, 41, 'DLC'), (NULL, 42, 'DLC'), (NULL, 43, 'DLC'), (NULL, 44, 'DLC'), (NULL, 45, 'DLC'),
(NULL, 46, 'DLC'), (NULL, 47, 'DLC'), (NULL, 48, 'DLC'), (NULL, 49, 'DLC'), (NULL, 50, 'DLC'), (NULL, 51, 'DLC'), (NULL, 52, 'DLC'),
(NULL, 53, 'DLC'), (NULL, 54, 'DLC'), (NULL, 55, 'DLC'), (NULL, 56, 'DLC'), (NULL, 57, 'DLC'), (NULL, 58, 'DLC'), (NULL, 59, 'DLC'),
(NULL, 60, 'DLC'), (NULL, 61, 'DLC'), (NULL, 62, 'DLC'), (NULL, 63, 'DLC'), (NULL, 64, 'DLC'), (NULL, 65, 'DLC'), (NULL, 66, 'DLC'),
(NULL, 67, 'DLC'), (NULL, 68, 'DLC'), (NULL, 69, 'DLC'), (NULL, 70, 'DLC'), (NULL, 71, 'DLC'), (NULL, 72, 'DLC'), (NULL, 73, 'DLC');
GO

PRINT '--- Lote 15 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 16: Precios de Productos (13-50) ---'
GO



INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(13, 59.99, '2018-10-26'), -- Producto 13 (Juego 10: RDR 2)
(14, 59.99, '2022-02-25'), -- Producto 14 (Juego 11: Elden Ring)
(15, 29.99, '2013-09-17'), -- Producto 15 (Juego 12: GTA V)
(16, 59.99, '2017-03-03'), -- Producto 16 (Juego 13: Zelda BOTW)
(17, 39.99, '2018-04-20'), -- Producto 17 (Juego 14: God of War 2018)
(18, 59.99, '2022-11-09'), -- Producto 18 (Juego 15: God of War Ragnarök)
(19, 49.99, '2018-09-07'), -- Producto 19 (Juego 16: Marvel's Spider-Man)
(20, 39.99, '2020-06-19'), -- Producto 20 (Juego 17: The Last of Us Part II)
(21, 19.99, '2016-05-13'), -- Producto 21 (Juego 18: DOOM (2016))
(22, 39.99, '2020-03-20'), -- Producto 22 (Juego 19: DOOM Eternal)
(23, 59.99, '2023-03-24'), -- Producto 23 (Juego 20: Resident Evil 4 Remake)
(24, 49.99, '2021-05-07'), -- Producto 24 (Juego 21: Resident Evil Village)
(25, 39.99, '2017-02-28'), -- Producto 25 (Juego 22: Horizon Zero Dawn)
(26, 49.99, '2020-07-17'), -- Producto 26 (Juego 23: Ghost of Tsushima)
(27, 39.99, '2016-05-10'), -- Producto 27 (Juego 24: Uncharted 4)
(28, 29.99, '2015-03-24'), -- Producto 28 (Juego 25: Bloodborne)
(29, 49.99, '2019-03-22'), -- Producto 29 (Juego 26: Sekiro)
(30, 29.99, '2016-03-24'), -- Producto 30 (Juego 27: Dark Souls III)
(31, 24.99, '2020-09-17'), -- Producto 31 (Juego 28: Hades)
(32, 19.99, '2018-01-25'), -- Producto 32 (Juego 29: Celeste)
(33, 59.99, '2019-10-31'), -- Producto 33 (Juego 30: Persona 5 Royal)
(34, 29.99, '2019-08-27'), -- Producto 34 (Juego 31: Control)
(35, 29.99, '2019-11-08'), -- Producto 35 (Juego 32: Death Stranding)
(36, 49.99, '2020-04-10'), -- Producto 36 (Juego 33: Final Fantasy VII Remake)
(37, 59.99, '2024-02-08'), -- Producto 37 (Juego 34: Helldivers 2)
(38, 49.99, '2023-10-27'), -- Producto 38 (Juego 35: Alan Wake 2)
(39, 69.99, '2023-06-05'), -- Producto 39 (Juego 36: Diablo IV)
(40, 69.99, '2023-09-06'), -- Producto 40 (Juego 37: Starfield)
(41, 59.99, '2021-11-09'), -- Producto 41 (Juego 38: Forza Horizon 5)
(42, 59.99, '2023-04-28'), -- Producto 42 (Juego 39: Star Wars Jedi: Survivor)
(43, 49.99, '2023-01-27'), -- Producto 43 (Juego 40: Dead Space (Remake))
(44, 49.99, '2021-05-14'), -- Producto 44 (Juego 41: Mass Effect Legendary)
(45, 39.99, '2021-03-26'), -- Producto 45 (Juego 42: It Takes Two)
(46, 9.99, '2023-10-23'),  -- Producto 46 (Juego 43: Lethal Company)
(47, 29.99, '2024-01-19'), -- Producto 47 (Juego 44: Palworld)
(48, 69.99, '2023-09-19'), -- Producto 48 (Juego 45: Mortal Kombat 1)
(49, 59.99, '2023-06-02'), -- Producto 49 (Juego 46: Street Fighter 6)
(50, 49.99, '2023-09-18'); -- Producto 50 (Juego 47: Lies of P)
GO

PRINT '--- Lote 16 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 17: Precios de Productos (51-90) ---'
GO

INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(51, 39.99, '2014-09-02'), -- Producto 51 (Juego 48: The Sims 4)
(52, 39.99, '2018-03-20'), -- Producto 52 (Juego 49: Sea of Thieves)
(53, 59.99, '2020-08-18'), -- Producto 53 (Juego 50: Microsoft Flight Simulator)
(54, 19.99, '2021-02-02'), -- Producto 54 (Juego 51: Valheim)
(55, 29.99, '2020-05-13'), -- Producto 55 (Juego 52: Deep Rock Galactic)
(56, 39.99, '2017-02-23'), -- Producto 56 (Juego 53: Nier: Automata)
(57, 29.99, '2020-03-11'), -- Producto 57 (Juego 54: Ori and the Will of the Wisps)
(58, 29.99, '2018-01-23'), -- Producto 58 (Juego 55: Subnautica)
(59, 24.99, '2019-05-30'), -- Producto 59 (Juego 56: Outer Wilds)
(60, 39.99, '2019-10-15'), -- Producto 60 (Juego 57: Disco Elysium)
(61, 19.99, '2017-09-29'), -- Producto 61 (Juego 58: Cuphead)
(62, 0.00, '2015-07-07'),  -- Producto 62 (Juego 59: Rocket League - F2P)
(63, 39.99, '2011-11-11'), -- Producto 63 (Juego 60: Skyrim)
(64, 39.99, '2015-11-10'), -- Producto 64 (Juego 61: Fallout 4)
(65, 44.99, '2017-09-14'), -- Producto 65 (Juego 62: Divinity: Original Sin 2)
(66, 29.99, '2018-01-26'), -- Producto 66 (Juego 63: Monster Hunter: World)
(67, 59.99, '2019-09-13'), -- Producto 67 (Juego 64: Borderlands 3)
(68, 59.99, '2018-10-05'), -- Producto 68 (Juego 65: AC Odyssey)
(69, 59.99, '2020-11-10'), -- Producto 69 (Juego 66: AC Valhalla)
(70, 49.99, '2018-03-27'), -- Producto 70 (Juego 67: Far Cry 5)
(71, 59.99, '2021-10-07'), -- Producto 71 (Juego 68: Far Cry 6)
(72, 19.99, '2016-10-28'), -- Producto 72 (Juego 69: Titanfall 2)
(73, 0.00, '2019-02-04'),  -- Producto 73 (Juego 70: Apex Legends - F2P)
(74, 19.99, '2015-12-01'), -- Producto 74 (Juego 71: Rainbow Six Siege)
(75, 24.99, '2019-01-23'), -- Producto 75 (Juego 72: Slay the Spire)
(76, 24.99, '2018-08-06'), -- Producto 76 (Juego 73: Dead Cells)
(77, 9.99, '2011-04-19'),  -- Producto 77 (Juego 74: Portal 2)
(78, 59.99, '2020-03-23'), -- Producto 78 (Juego 75: Half-Life: Alyx)
(79, 30.00, '2020-08-14'), -- Producto 79 (Juego 76: Factorio)
(80, 9.99, '2011-05-16'),  -- Producto 80 (Juego 77: Terraria)
(81, 59.99, '2016-08-09'), -- Producto 81 (Juego 78: No Man's Sky)
(82, 59.99, '2021-01-20'), -- Producto 82 (Juego 79: Hitman 3)
(83, 29.99, '2015-09-01'), -- Producto 83 (Juego 80: Metal Gear Solid V)
(84, 49.99, '2022-10-18'), -- Producto 84 (Juego 81: A Plague Tale: Requiem)
(85, 9.99, '2006-11-29'),  -- Producto 85 (Juego 82: Garry's Mod)
(86, 4.99, '2022-10-20'),  -- Producto 86 (Juego 83: Vampire Survivors)
(87, 69.99, '2023-06-16'), -- Producto 87 (Juego 84: F1 23)
(88, 59.99, '2016-10-21'), -- Producto 88 (Juego 85: Civilization VI)
(89, 49.99, '2016-02-05'), -- Producto 89 (Juego 86: XCOM 2)
(90, 69.99, '2022-09-02'); -- Producto 90 (Juego 87: The Last of Us Part I)
GO

PRINT '--- Lote 17 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 18: Precios de Productos (91-130) ---'
GO

INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(91, 69.99, '2020-11-12'), -- Producto 91 (Juego 88: Demon's Souls Remake)
(92, 69.99, '2021-06-11'), -- Producto 92 (Juego 89: Ratchet & Clank: Rift Apart)
(93, 69.99, '2021-04-30'), -- Producto 93 (Juego 90: Returnal)
(94, 59.99, '2021-10-26'), -- Producto 94 (Juego 91: Marvel's Guardians of the Galaxy)
(95, 59.99, '2023-02-10'), -- Producto 95 (Juego 92: Hogwarts Legacy)
(96, 69.99, '2023-09-29'), -- Producto 96 (Juego 93: EA Sports FC 24)
(97, 69.99, '2023-09-08'), -- Producto 97 (Juego 94: NBA 2K24)
(98, 69.99, '2023-08-18'), -- Producto 98 (Juego 95: Madden NFL 24)
(99, 29.99, '2016-06-14'), -- Producto 99 (Juego 96: Dead by Daylight)
(100, 29.99, '2014-10-07'), -- Producto 100 (Juego 97: Alien: Isolation)
(101, 39.99, '2019-02-15'), -- Producto 101 (Juego 98: Metro Exodus)
(102, 39.99, '2019-04-26'), -- Producto 102 (Juego 99: Days Gone)
(103, 49.99, '2022-02-04'), -- Producto 103 (Juego 100: Dying Light 2)
(104, 49.99, '2022-10-25'), -- Producto 104 (Juego 101: Mount & Blade II: Bannerlord)
(105, 59.99, '2022-02-17'), -- Producto 105 (Juego 102: Total War: WARHAMMER III)
(106, 49.99, '2020-09-01'), -- Producto 106 (Juego 103: Crusader Kings III)
(107, 69.99, '2024-01-26'), -- Producto 107 (Juego 104: Tekken 8)
(108, 59.99, '2021-06-11'), -- Producto 108 (Juego 105: Guilty Gear -Strive-)
(109, 59.99, '2020-11-10'), -- Producto 109 (Juego 106: Yakuza: Like a Dragon)
(110, 39.99, '2019-09-27'), -- Producto 110 (Juego 107: Dragon Quest XI S)
(111, 9.99, '2015-09-15'),  -- Producto 111 (Juego 108: Undertale)
(112, 19.99, '2014-06-26'), -- Producto 112 (Juego 109: Shovel Knight)
-- AQUI COMIENZAN LOS DLCS (del Lote 14)
(113, 24.99, '2016-05-31'), -- Producto 113 (DLC 4: Witcher 3 - Blood and Wine)
(114, 9.99, '2015-10-13'), -- Producto 114 (DLC 5: Witcher 3 - Hearts of Stone)
(115, 14.99, '2017-05-18'), -- Producto 115 (DLC 6: Cities - Mass Transit)
(116, 14.99, '2018-10-23'), -- Producto 116 (DLC 7: Cities - Industries)
(117, 9.99, '2017-10-19'), -- Producto 117 (DLC 8: Cities - Green Cities)
(118, 39.99, '2024-06-21'), -- Producto 118 (DLC 9: Elden Ring - Shadow of the Erdtree)
(119, 0.00, '2018-11-27'),  -- Producto 119 (DLC 10: Red Dead Online)
(120, 0.00, '2023-12-12'),  -- Producto 120 (DLC 11: GoW Ragnarok - Valhalla)
(121, 19.99, '2017-11-07'), -- Producto 121 (DLC 12: Horizon - The Frozen Wilds)
(122, 19.99, '2020-10-20'), -- Producto 122 (DLC 13: DOOM Eternal - Ancient Gods 1)
(123, 19.99, '2021-03-18'), -- Producto 123 (DLC 14: DOOM Eternal - Ancient Gods 2)
(124, 19.99, '2022-10-28'), -- Producto 124 (DLC 15: RE Village - Winters Expansion)
(125, 14.99, '2020-03-26'), -- Producto 125 (DLC 16: Control - The Foundation)
(126, 14.99, '2020-08-27'), -- Producto 126 (DLC 17: Control - AWE)
(127, 39.99, '2015-03-31'), -- Producto 127 (DLC 18: Sims 4 - Get to Work)
(128, 39.99, '2018-06-22'), -- Producto 128 (DLC 19: Sims 4 - Seasons)
(129, 39.99, '2017-11-10'), -- Producto 129 (DLC 20: Sims 4 - Cats & Dogs)
(130, 39.99, '2016-11-01'); -- Producto 130 (DLC 21: Sims 4 - City Living)
GO

PRINT '--- Lote 18 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 19: Precios de Productos (131-160) ---'
GO

INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(131, 39.99, '2019-11-15'), -- Producto 131 (DLC 22: Sims 4 - Discover University)
(132, 19.99, '2012-06-26'), -- Producto 132 (DLC 23: Skyrim - Dawnguard)
(133, 19.99, '2012-12-04'), -- Producto 133 (DLC 24: Skyrim - Dragonborn)
(134, 4.99, '2012-09-04'),  -- Producto 134 (DLC 25: Skyrim - Hearthfire)
(135, 24.99, '2016-05-19'), -- Producto 135 (DLC 26: Fallout 4 - Far Harbor)
(136, 19.99, '2016-08-30'), -- Producto 136 (DLC 27: Fallout 4 - Nuka-World)
(137, 9.99, '2016-03-22'),  -- Producto 137 (DLC 28: Fallout 4 - Automatron)
(138, 29.99, '2018-02-08'), -- Producto 138 (DLC 29: Civ VI - Rise and Fall)
(139, 39.99, '2019-02-14'), -- Producto 139 (DLC 30: Civ VI - Gathering Storm)
(140, 39.99, '2020-05-21'), -- Producto 140 (DLC 31: Civ VI - New Frontier Pass)
(141, 39.99, '2019-09-06'), -- Producto 141 (DLC 32: Monster Hunter - Iceborne)
(142, 14.99, '2019-12-19'), -- Producto 142 (DLC 33: Borderlands 3 - Moxxi's Heist)
(143, 14.99, '2020-03-26'), -- Producto 143 (DLC 34: Borderlands 3 - Guns, Love...)
(144, 14.99, '2020-06-25'), -- Producto 144 (DLC 35: Borderlands 3 - Bounty of Blood)
(145, 14.99, '2020-09-10'), -- Producto 145 (DLC 36: Borderlands 3 - Psycho Krieg)
(146, 39.99, '2017-08-29'), -- Producto 146 (DLC 37: XCOM 2 - War of the Chosen)
(147, 7.99, '2022-06-30'),  -- Producto 147 (DLC 38: Cuphead - Delicious Last Course)
(148, 15.99, '2022-08-23'), -- Producto 148 (DLC 39: TW: WH3 - Champions of Chaos)
(149, 24.99, '2023-04-13'), -- Producto 149 (DLC 40: TW: WH3 - Forge of Chaos Dwarfs)
(150, 24.99, '2023-08-31'), -- Producto 150 (DLC 41: TW: WH3 - Shadows of Change)
(151, 6.99, '2021-03-16'),  -- Producto 151 (DLC 42: CKIII - Northern Lords)
(152, 29.99, '2022-02-08'), -- Producto 152 (DLC 43: CKIII - Royal Court)
(153, 29.99, '2023-05-11'), -- Producto 153 (DLC 44: CKIII - Tours & Tournaments)
(154, 39.99, '2023-03-16'), -- Producto 154 (DLC 45: Sims 4 - Growing Together)
(155, 39.99, '2020-06-05'), -- Producto 155 (DLC 46: Sims 4 - Eco Lifestyle)
(156, 39.99, '2021-07-22'), -- Producto 156 (DLC 47: Sims 4 - Cottage Living)
(157, 39.99, '2022-07-28'), -- Producto 157 (DLC 48: Sims 4 - High School Years)
(158, 24.99, '2018-12-04'), -- Producto 158 (DLC 49: AC Odyssey - Legacy of First Blade)
(159, 24.99, '2019-04-23'), -- Producto 159 (DLC 50: AC Odyssey - Fate of Atlantis)
(160, 24.99, '2021-05-13'); -- Producto 160 (DLC 51: AC Valhalla - Wrath of Druids)
GO

PRINT '--- Lote 19 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 20: Precios de Productos (161-182) [TANDA FINAL] ---'
GO

INSERT INTO PreciosProductos (IdProducto, Precio, FechaInicio) VALUES 
(161, 24.99, '2021-08-12'), -- Producto 161 (DLC 52: AC Valhalla - Siege of Paris)
(162, 39.99, '2022-03-10'), -- Producto 162 (DLC 53: AC Valhalla - Dawn of Ragnarök)
(163, 9.99, '2023-09-21'),  -- Producto 163 (DLC 54: RE4 - Separate Ways)
(164, 7.99, '2019-08-20'),  -- Producto 164 (DLC 55: Metro Exodus - Two Colonels)
(165, 17.99, '2020-02-11'), -- Producto 165 (DLC 56: Metro Exodus - Sam's Story)
(166, 4.99, '2020-02-11'),  -- Producto 166 (DLC 57: Dead Cells - The Bad Seed)
(167, 4.99, '2021-01-26'),  -- Producto 167 (DLC 58: Dead Cells - Fatal Falls)
(168, 4.99, '2022-01-07'),  -- Producto 168 (DLC 59: Dead Cells - Queen and the Sea)
(169, 9.99, '2023-03-06'),  -- Producto 169 (DLC 60: Dead Cells - Return to Castlevania)
(170, 9.99, '2022-11-10'),  -- Producto 170 (DLC 61: Dying Light 2 - Bloody Ties)
(171, 30.00, '2024-10-21'), -- Producto 171 (DLC 62: Factorio - Space Age)
(172, 9.99, '2017-05-02'),  -- Producto 172 (DLC 63: Nier: Automata - 3C3C...)
(173, 0.00, '2021-11-04'),  -- Producto 173 (DLC 64: Deep Rock Galactic - Season 1)
(174, 0.00, '2022-04-28'),  -- Producto 174 (DLC 65: Deep Rock Galactic - Season 2)
(175, 0.00, '2020-01-14'),  -- Producto 175 (DLC 66: Slay the Spire - The Watcher)
(176, 29.99, '2021-03-30'), -- Producto 176 (DLC 67: Hitman 3 - Seven Deadly Sins)
(177, 14.99, '2024-06-08'), -- Producto 177 (DLC 68: Alan Wake 2 - Night Springs)
(178, 19.99, '2024-10-22'), -- Producto 178 (DLC 69: Alan Wake 2 - The Lake House)
(179, 39.99, '2024-10-08'), -- Producto 179 (DLC 70: Diablo IV - Vessel of Hatred)
(180, 4.99, '2021-05-14'),  -- Producto 180 (DLC 71: Mass Effect LE - Genesis 2)
(181, 19.99, '2022-07-19'), -- Producto 181 (DLC 72: Forza Horizon 5 - Hot Wheels)
(182, 19.99, '2023-03-29'); -- Producto 182 (DLC 73: Forza Horizon 5 - Rally Adventure)
GO

PRINT '--- Lote 20 Finalizado ---'
GO

USE EvolutionDB
GO


PRINT '--- Iniciando Lote 10: Generos para Juegos 10-34 ---'
GO

INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(10, 2), (10, 3), (10, 13), -- RDR 2 (Accion, Aventura, Mundo Abierto)
(11, 1), (11, 2), (11, 13), -- Elden Ring (RPG, Accion, Mundo Abierto)
(12, 2), (12, 3), (12, 13), -- GTA V (Accion, Aventura, Mundo Abierto)
(13, 1), (13, 3), (13, 13), -- Zelda: BOTW (RPG, Aventura, Mundo Abierto)
(14, 2), (14, 3),           -- God of War (2018) (Accion, Aventura)
(15, 2), (15, 3),           -- God of War Ragnarök (Accion, Aventura)
(16, 2), (16, 3), (16, 13), -- Marvel's Spider-Man (Accion, Aventura, Mundo Abierto)
(17, 2), (17, 3), (17, 15), -- The Last of Us Part II (Accion, Aventura, Sigilo)
(18, 2), (18, 11),          -- DOOM (2016) (Accion, Shooter)
(19, 2), (19, 11),          -- DOOM Eternal (Accion, Shooter)
(20, 2), (20, 6), (20, 10), -- RE4 Remake (Accion, Terror, Supervivencia)
(21, 2), (21, 6), (21, 10), -- RE Village (Accion, Terror, Supervivencia)
(22, 1), (22, 2), (22, 3),  -- Horizon Zero Dawn (RPG, Accion, Aventura)
(23, 2), (23, 3), (23, 15), -- Ghost of Tsushima (Accion, Aventura, Sigilo)
(24, 2), (24, 3), (24, 9),  -- Uncharted 4 (Accion, Aventura, Plataformas)
(25, 1), (25, 2), (25, 6),  -- Bloodborne (RPG, Accion, Terror)
(26, 2), (26, 15),          -- Sekiro (Accion, Sigilo)
(27, 1), (27, 2),           -- Dark Souls III (RPG, Accion)
(28, 2), (28, 8), (28, 14), -- Hades (Accion, Roguelike, Indie)
(29, 9), (29, 14),          -- Celeste (Plataformas, Indie)
(30, 1),                    -- Persona 5 Royal (RPG)
(31, 2), (31, 3),           -- Control (Accion, Aventura)
(32, 3), (32, 4),           -- Death Stranding (Aventura, Simulacion)
(33, 1),                    -- Final Fantasy VII Remake (RPG)
(34, 2), (34, 11);          -- Helldivers 2 (Accion, Shooter)
GO

PRINT '--- Lote 10 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 11: Generos para Juegos 35-59 ---'
GO


INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(35, 3), (35, 6),           -- Alan Wake 2 (Aventura, Terror)
(36, 1), (36, 2),           -- Diablo IV (RPG, Accion)
(37, 1), (37, 13),          -- Starfield (RPG, Mundo Abierto)
(38, 4), (38, 12),          -- Forza Horizon 5 (Simulacion, Deportivo)
(39, 2), (39, 3),           -- Star Wars Jedi: Survivor (Accion, Aventura)
(40, 6), (40, 10),          -- Dead Space (Remake) (Terror, Supervivencia)
(41, 1), (41, 11),          -- Mass Effect LE (RPG, Shooter)
(42, 3), (42, 9),           -- It Takes Two (Aventura, Plataformas)
(43, 6), (43, 14),          -- Lethal Company (Terror, Indie)
(44, 2), (44, 10),          -- Palworld (Accion, Supervivencia)
(45, 2),                    -- Mortal Kombat 1 (Accion)
(46, 2),                    -- Street Fighter 6 (Accion)
(47, 1), (47, 2),           -- Lies of P (RPG, Accion)
(48, 3), (48, 13),          -- Sea of Thieves (Aventura, Mundo Abierto)
(49, 4),                    -- Microsoft Flight Simulator (Simulacion)
(50, 4),                    -- The Sims 4 (Simulacion)
(51, 10), (51, 14),         -- Valheim (Supervivencia, Indie)
(52, 2), (52, 11),          -- Deep Rock Galactic (Accion, Shooter)
(53, 1), (53, 2),           -- Nier: Automata (RPG, Accion)
(54, 3), (54, 9),           -- Ori and the Will of the Wisps (Aventura, Plataformas)
(55, 3), (55, 10),          -- Subnautica (Aventura, Supervivencia)
(56, 3), (56, 14),          -- Outer Wilds (Aventura, Indie)
(57, 1), (57, 14),          -- Disco Elysium (RPG, Indie)
(58, 2), (58, 9), (58, 14), -- Cuphead (Accion, Plataformas, Indie)
(59, 12);                   -- Rocket League (Deportivo)
GO

PRINT '--- Lote 11 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 12: Generos para Juegos 60-84 ---'
GO

INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(60, 1), (60, 13),          -- Skyrim (RPG, Mundo Abierto)
(61, 1), (61, 11), (61, 13),-- Fallout 4 (RPG, Shooter, Mundo Abierto)
(62, 1), (62, 5),           -- Divinity: Original Sin 2 (RPG, Estrategia)
(63, 1), (63, 2),           -- Monster Hunter: World (RPG, Accion)
(64, 2), (64, 11),          -- Borderlands 3 (Accion, Shooter)
(65, 1), (65, 2), (65, 13), -- AC Odyssey (RPG, Accion, Mundo Abierto)
(66, 1), (66, 2), (66, 13), -- AC Valhalla (RPG, Accion, Mundo Abierto)
(67, 2), (67, 11),          -- Far Cry 5 (Accion, Shooter)
(68, 2), (68, 11),          -- Far Cry 6 (Accion, Shooter)
(69, 2), (69, 11),          -- Titanfall 2 (Accion, Shooter)
(70, 2), (70, 11),          -- Apex Legends (Accion, Shooter)
(71, 2), (71, 5), (71, 11), -- Rainbow Six Siege (Accion, Estrategia, Shooter)
(72, 5), (72, 8), (72, 14), -- Slay the Spire (Estrategia, Roguelike, Indie)
(73, 2), (73, 8), (73, 9),  -- Dead Cells (Accion, Roguelike, Plataformas)
(74, 9),                    -- Portal 2 (Plataformas - *Es Puzzle, pero 9 es el mas cercano*)
(75, 2), (75, 3), (75, 11), -- Half-Life: Alyx (Accion, Aventura, Shooter)
(76, 4), (76, 5),           -- Factorio (Simulacion, Estrategia)
(77, 3), (77, 4), (77, 10), -- Terraria (Aventura, Simulacion, Supervivencia)
(78, 3), (78, 4),           -- No Man's Sky (Aventura, Simulacion)
(79, 2), (79, 15),          -- Hitman 3 (Accion, Sigilo)
(80, 2), (80, 15),          -- Metal Gear Solid V (Accion, Sigilo)
(81, 3), (81, 15),          -- A Plague Tale: Requiem (Aventura, Sigilo)
(82, 4),                    -- Garry's Mod (Simulacion)
(83, 2), (83, 8),           -- Vampire Survivors (Accion, Roguelike)
(84, 4), (84, 12);          -- F1 23 (Simulacion, Deportivo)
GO

PRINT '--- Lote 12 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 13: Generos para Juegos 85-109 ---'
GO


INSERT INTO JuegosGeneros (IdJuego, IdGenero) VALUES 
(85, 5),                    -- Civilization VI (Estrategia)
(86, 5),                    -- XCOM 2 (Estrategia)
(87, 2), (87, 3),           -- The Last of Us Part I (Accion, Aventura)
(88, 1), (88, 2),           -- Demon's Souls (Remake) (RPG, Accion)
(89, 2), (89, 9),           -- Ratchet & Clank (Accion, Plataformas)
(90, 2), (90, 8), (90, 11), -- Returnal (Accion, Roguelike, Shooter)
(91, 2), (91, 3),           -- Guardians of the Galaxy (Accion, Aventura)
(92, 1), (92, 2), (92, 3),  -- Hogwarts Legacy (RPG, Accion, Aventura)
(93, 12),                   -- EA Sports FC 24 (Deportivo)
(94, 12),                   -- NBA 2K24 (Deportivo)
(95, 12),                   -- Madden NFL 24 (Deportivo)
(96, 6), (96, 10),          -- Dead by Daylight (Terror, Supervivencia)
(97, 6), (97, 15),          -- Alien: Isolation (Terror, Sigilo)
(98, 2), (98, 10), (98, 11),-- Metro Exodus (Accion, Supervivencia, Shooter)
(99, 2), (99, 3), (99, 10), -- Days Gone (Accion, Aventura, Supervivencia)
(100, 2), (100, 10),        -- Dying Light 2 (Accion, Supervivencia)
(101, 1), (101, 5),         -- Mount & Blade II (RPG, Estrategia)
(102, 5),                   -- Total War: WARHAMMER III (Estrategia)
(103, 1), (103, 5),         -- Crusader Kings III (RPG, Estrategia)
(104, 2),                   -- Tekken 8 (Accion)
(105, 2),                   -- Guilty Gear -Strive- (Accion)
(106, 1), (106, 2),         -- Yakuza: Like a Dragon (RPG, Accion)
(107, 1),                   -- Dragon Quest XI S (RPG)
(108, 1), (108, 14),        -- Undertale (RPG, Indie)
(109, 9), (109, 14);        -- Shovel Knight (Plataformas, Indie)
GO

PRINT '--- Lote 13 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 21: Insercion de 10 Etiquetas nuevas ---'
GO

-- IDs 1-9 ya existen.
INSERT INTO Etiquetas (Nombre) VALUES
('Primera Persona'), -- ID 10
('Tercera Persona'), -- ID 11
('Historia Profunda'), -- ID 12
('Dificil'), -- ID 13
('Atmosferico'), -- ID 14
('Fantasia'), -- ID 15
('Ciencia Ficcion'), -- ID 16
('Relaxing'), -- ID 17
('Construccion'), -- ID 18
('Puzzle'); -- ID 19
GO

PRINT '--- Lote 21 Finalizado ---'
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 22: JuegosEtiquetas para Juegos 1-3 y 10-34 ---'
GO

INSERT INTO JuegosEtiquetas (IdJuego, IdEtiqueta) VALUES 
-- Stardew Valley (ID 2)
(2, 4), (2, 6), (2, 8), (2, 17), (2, 18),
-- The Witcher 3 (ID 3)
(3, 4), (3, 11), (3, 12), (3, 15),
-- RDR 2 (ID 10)
(10, 1), (10, 4), (10, 11), (10, 12), (10, 14),
-- Elden Ring (ID 11)
(11, 1), (11, 4), (11, 8), (11, 11), (11, 13), (11, 15),
-- GTA V (ID 12)
(12, 1), (12, 2), (12, 4), (12, 8), (12, 11),
-- Zelda: BOTW (ID 13)
(13, 1), (13, 4), (13, 11), (13, 15), (13, 17),
-- God of War (2018) (ID 14)
(14, 4), (14, 11), (14, 12), (14, 14), (14, 15),
-- GoW Ragnarök (ID 15)
(15, 4), (15, 12), (15, 14), (15, 15),
-- Marvel's Spider-Man (ID 16)
(16, 1), (16, 4), (16, 11),
-- TLOU Part II (ID 17)
(17, 4), (17, 11), (17, 12), (17, 14),
-- DOOM (2016) (ID 18)
(18, 4), (18, 10),
-- DOOM Eternal (ID 19)
(19, 4), (19, 10),
-- RE4 Remake (ID 20)
(20, 4), (20, 11), (20, 14),
-- RE Village (ID 21)
(21, 4), (21, 10), (21, 14),
-- Horizon Zero Dawn (ID 22)
(22, 1), (22, 4), (22, 11), (22, 12), (22, 16),
-- Ghost of Tsushima (ID 23)
(23, 1), (23, 4), (23, 11), (23, 12),
-- Uncharted 4 (ID 24)
(24, 4), (24, 11), (24, 12),
-- Bloodborne (ID 25)
(25, 4), (25, 11), (25, 13), (25, 14), (25, 15),
-- Sekiro (ID 26)
(26, 4), (26, 11), (26, 13),
-- Dark Souls III (ID 27)
(27, 4), (27, 8), (27, 11), (27, 13), (27, 15),
-- Hades (ID 28)
(28, 3), (28, 4), (28, 13), (28, 15),
-- Celeste (ID 29)
 (29, 4), (29, 6), (29, 12), (29, 13),
-- Persona 5 Royal (ID 30)
(30, 4), (30, 5), (30, 12), (30, 15),
-- Control (ID 31)
(31, 4), (31, 11), (31, 14), (31, 16),
-- Death Stranding (ID 32)
(32, 4), (32, 11), (32, 12), (32, 14), (32, 16),
-- FFVII Remake (ID 33)
(33, 4), (33, 11), (33, 12), (33, 15), (33, 16),
-- Helldivers 2 (ID 34)
(34, 2), (34, 8), (34, 11), (34, 16);
GO

PRINT '--- Lote 22 Finalizado ---'
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 23: JuegosEtiquetas para Juegos 35-59 ---'
GO

INSERT INTO JuegosEtiquetas (IdJuego, IdEtiqueta) VALUES 
(35, 4), (35, 11), (35, 12), (35, 14),
(36, 2), (36, 8), (36, 14), (36, 15),
(37, 1), (37, 4), (37, 10), (37, 16),
(38, 1), (38, 2), (38, 4), (38, 17),
(39, 1), (39, 4), (39, 11), (39, 12), (39, 16),
(40, 4), (40, 11), (40, 14), (40, 16),
(41, 4), (41, 11), (41, 12), (41, 16),
(42, 2), (42, 8), (42, 19),
(43, 3), (43, 8), (43, 10), (43, 14),
(44, 1), (44, 2), (44, 8), (44, 9), (44, 18),
(45, 2), (45, 4),
(46, 2), (46, 4),
(47, 4), (47, 11), (47, 13), (47, 15),
(48, 1), (48, 2), (48, 8),
(49, 4), (49, 17),
(50, 4), (50, 17), (50, 18),
(51, 3), (51, 8), (51, 9), (51, 15), (51, 18),
(52, 3), (52, 8), (52, 10),
(53, 4), (53, 11), (53, 12), (53, 13), (53, 16),
(54, 3), (54, 4), (54, 12), (54, 14),
(55, 3), (55, 4), (55, 9), (55, 14), (55, 16), (55, 18),
(56, 3), (56, 4), (56, 14), (56, 16), (56, 19),
(57, 3), (57, 4), (57, 12),
(58, 3), (58, 4), (58, 8), (58, 13),
(59, 2);
GO

PRINT '--- Lote 23 Finalizado ---'
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 24: JuegosEtiquetas para Juegos 60-84 ---'
GO

INSERT INTO JuegosEtiquetas (IdJuego, IdEtiqueta) VALUES 
(60, 1), (60, 4), (60, 10), (60, 15),
(61, 1), (61, 4), (61, 10), (61, 16), (61, 18),
(62, 4), (62, 5), (62, 8), (62, 12), (62, 15),
(63, 2), (63, 4), (63, 8), (63, 11),
(64, 2), (64, 8), (64, 10),
(65, 1), (65, 4), (65, 11), (65, 12),
(66, 1), (66, 4), (66, 11), (66, 12),
(67, 1), (67, 4), (67, 8), (67, 10),
(68, 1), (68, 4), (68, 8), (68, 10),
(69, 2), (69, 4), (69, 10), (69, 12), (69, 16),
(70, 2), (70, 10),
(71, 2), (71, 5), (71, 10),
(72, 3), (72, 4), (72, 5), (72, 13),
(73, 3), (73, 4), (73, 6), (73, 13),
(74, 4), (74, 8), (74, 10), (74, 16), (74, 19),
(75, 4), (75, 10), (75, 12), (75, 14), (75, 16),
(76, 3), (76, 4), (76, 5), (76, 18),
(77, 1), (77, 3), (77, 6), (77, 8), (77, 9), (77, 18),
(78, 1), (78, 8), (78, 9), (78, 16), (78, 18),
(79, 4), (79, 11),
(80, 1), (80, 4), (80, 11), (80, 12),
(81, 4), (81, 11), (81, 12), (81, 14),
(82, 2), (82, 3), (82, 8), (82, 18),
(83, 3), (83, 4), (83, 6), (83, 17),
(84, 2), (84, 4);
GO

PRINT '--- Lote 24 Finalizado ---'
GO
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 25: JuegosEtiquetas para Juegos 85-109 ---'
GO

INSERT INTO JuegosEtiquetas (IdJuego, IdEtiqueta) VALUES 
(85, 4), (85, 5), (85, 8),
(86, 4), (86, 5), (86, 13), (86, 16),
(87, 4), (87, 11), (87, 12), (87, 14),
(88, 4), (88, 11), (88, 13), (88, 15),
(89, 4), (89, 11), (89, 16),
(90, 4), (90, 11), (90, 13), (90, 16),
(91, 4), (91, 11), (91, 12), (91, 16),
(92, 1), (92, 4), (92, 11), (92, 15),
(93, 2), (93, 4), (93, 8),
(94, 2), (94, 4),
(95, 2), (95, 4),
(96, 2), (96, 8), (96, 14),
(97, 4), (97, 10), (97, 14), (97, 16),
(98, 1), (98, 4), (98, 10), (98, 12), (98, 14),
(99, 1), (99, 4), (99, 9), (99, 11),
(100, 1), (100, 8), (100, 9), (100, 10),
(101, 1), (101, 2), (101, 4), (101, 5),
(102, 2), (102, 4), (102, 5), (102, 15),
(103, 4), (103, 5), (103, 12),
(104, 2), (104, 4),
(105, 2), (105, 4),
(106, 4), (106, 5), (106, 12),
(107, 4), (107, 12), (107, 15),
(108, 3), (108, 4), (108, 6), (108, 12), (108, 19),
(109, 3), (109, 4), (109, 6);
GO

PRINT '--- Lote 25 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 21: Insercion de 10 Etiquetas nuevas ---'
GO



PRINT '--- Lote 21 Finalizado ---'
GO
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 22: JuegosEtiquetas para Juegos 1-3 y 10-34 ---'
GO

-- SOs (1='Windows', 2='Linux', 3='MacOS')
-- Lote 5: Juegos 10–34
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
(10, 1),        -- Red Dead Redemption 2 (PC)
(11, 1),        -- Elden Ring (PC)
(12, 1),        -- Grand Theft Auto V (PC)
-- (13) The Legend of Zelda: BOTW -> sin asignar (consola)
(14, 1),        -- God of War (2018) (PC)
(15, 1),        -- God of War Ragnarök (PC)
(16, 1),        -- Marvel's Spider-Man (PC)
(17, 1),        -- The Last of Us Part II (PC)
(18, 1),        -- DOOM (2016) (PC)
(19, 1),        -- DOOM Eternal (PC)
(20, 1),        -- Resident Evil 4 Remake (PC)
(21, 1), (21, 3), -- Resident Evil Village (PC + Mac)
(22, 1),        -- Horizon Zero Dawn (PC)
(23, 1),        -- Ghost of Tsushima (PC)
(24, 1),        -- Uncharted 4 (vía Legacy of Thieves en PC)
-- (25) Bloodborne -> sin asignar (consola)
(26, 1),        -- Sekiro (PC)
(27, 1),        -- Dark Souls III (PC)
(28, 1), (28, 3), -- Hades (PC + Mac)
(29, 1), (29, 2), (29, 3), -- Celeste (PC + Linux + Mac)
(30, 1),        -- Persona 5 Royal (PC)
(31, 1),        -- Control (PC)
(32, 1), (32, 3), -- Death Stranding (PC + Mac)
(33, 1),        -- Final Fantasy VII Remake (PC)
(34, 1);        -- Helldivers 2 (PC)
GO

USE EvolutionDB;
GO

-- SOs usados: 1=Windows, 2=Linux, 3=MacOS
-- Completar mapeo de SO para Juegos 26–50
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES

    -- 28: (Lote 10 muestra logro “¿No hay escapatoria?” de Hades; si en tu dataset Id 28 es Hades, soporta Win/Linux/Mac)
    (28, 2),

    -- 29: Celeste (PC nativo Win/Linux/Mac)
    (29, 3),

    -- 30: Persona 5 Royal (PC)
    (30, 1),

    -- 31: Control (PC)
    (31, 1),

    -- 32: Death Stranding (PC)
    (32, 1),

    -- 33: Final Fantasy VII Remake Intergrade (PC)
    (33, 1),

    -- 34: Helldivers 2 (PC)
    (34, 1),

    -- 35: Alan Wake 2 (PC)
    (35, 1),

    -- 36: Diablo IV (PC)
    (36, 1),

    -- 37: Starfield (PC)
    (37, 1),

    -- 38: Forza Horizon 5 (PC)
    (38, 1),

    -- 39: Star Wars Jedi: Survivor (PC)
    (39, 1),

    -- 40: Dead Space (Remake) (PC)
    (40, 1),

    -- 41: Mass Effect Legendary Edition (PC)
    (41, 1),

    -- 42: It Takes Two (PC)
    (42, 1),

    -- 43: (según logros “Cumplimiento de Cuota”; si en tu dataset es Satisfactory, PC)
    (43, 1),

    -- 44: Palworld (PC)
    (44, 1),

    -- 45: Mortal Kombat 1 (PC)
    (45, 1),

    -- 46: Street Fighter 6 (PC)
    (46, 1),

    -- 47: Lies of P (PC)
    (47, 1),

    -- 48: Sea of Thieves (PC)
    (48, 1),

    -- 49: Microsoft Flight Simulator (PC)
    (49, 1),

    -- 50: The Sims (la tanda de logros habla de árbol genealógico; si este Id es The Sims 3 en tu dataset, PC.
    --  OJO: The Sims 4 está en Id 51 según los DLCs; lo dejo 50=PC y 51=PC+Mac más abajo)
    (50, 1);
GO

-- Extra: comienzo de 51–60 (aprovechando que en DLCs se ve Id 51 = The Sims 4 y Id 60 = Skyrim)
-- (puedo seguir con el resto si querés que cierre hasta el 109)
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
    -- 51: The Sims 4 (PC + Mac)
    (51, 1), (51, 3),

    -- 52: Valheim (PC Win + Linux)
    (52, 1), (52, 2),

    -- 53: Deep Rock Galactic (PC Win + Linux)
    (53, 1), (53, 2),

    -- 54: NieR: Automata (PC)
    (54, 1),

    -- 55: Ori and the Will of the Wisps (PC)
    (55, 1),

    -- 60: The Elder Scrolls V: Skyrim (PC)
    (60, 1);
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 26: JuegosPublishers para Juegos 1-3 y 10-34 ---'
GO

select * from JuegosPublishers
-- IDs de Publisher: (1) CD Projekt, (2) Rockstar, (3) Nintendo, (11) Activision,
-- (14) Sony, (15) Square Enix, (16) Capcom, (17) Bandai Namco, (18) Sega, (19) Bethesda.
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES 
-- The Witcher 3 -> CD Projekt Red
-- (Juego 2: Stardew Valley es autopublicado, no esta en la lista)
(10, 2), -- RDR 2 -> Rockstar Games
(11, 17),-- Elden Ring -> Bandai Namco
(12, 2), -- GTA V -> Rockstar Games
(13, 3), -- Zelda: BOTW -> Nintendo
(14, 14),-- God of War (2018) -> Sony
(15, 14),-- God of War Ragnarök -> Sony
(16, 14),-- Marvel's Spider-Man -> Sony
(17, 14),-- The Last of Us Part II -> Sony
(18, 19),-- DOOM (2016) -> Bethesda Softworks
(19, 19),-- DOOM Eternal -> Bethesda Softworks
(20, 16),-- RE4 Remake -> Capcom
(21, 16),-- RE Village -> Capcom
(22, 14),-- Horizon Zero Dawn -> Sony
(23, 14),-- Ghost of Tsushima -> Sony
(24, 14),-- Uncharted 4 -> Sony
(25, 14),-- Bloodborne -> Sony
(26, 11),-- Sekiro -> Activision
(27, 17),-- Dark Souls III -> Bandai Namco
-- (Juego 28: Hades es autopublicado)
-- (Juego 29: Celeste es autopublicado)
(30, 18),-- Persona 5 Royal -> Sega (dueño de Atlus)
-- (Juego 31: Control es de 505 Games, no esta en la lista)
(32, 14),-- Death Stranding -> Sony (en PS), 505 (en PC). Usamos Sony.
(33, 15),-- Final Fantasy VII Remake -> Square Enix
(34, 14);-- Helldivers 2 -> Sony
GO
PRINT '--- Lote 26 Finalizado ---'
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 27: JuegosPublishers para Juegos 35-59 ---'
GO

-- IDs de Publisher: (10) EA, (12) Ubisoft, (14) Sony, (15) Square Enix, (16) Capcom, 
-- (19) Bethesda, (23) Devolver Digital, (24) Annapurna
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES 
-- (Juego 35: Alan Wake 2 es de Epic Games, no esta en la lista)
(36, 11),-- Diablo IV -> Activision (Activision-Blizzard)
(37, 19),-- Starfield -> Bethesda Softworks
(38, 14),-- Forza Horizon 5 -> Sony (Publicado por Xbox Game Studios, ID 14 es Sony/Microsoft en tu Lote 3)
(39, 10),-- Star Wars Jedi: Survivor -> Electronic Arts
(40, 10),-- Dead Space (Remake) -> Electronic Arts
(41, 10),-- Mass Effect LE -> Electronic Arts
(42, 10),-- It Takes Two -> Electronic Arts
-- (Juego 43: Lethal Company es autopublicado)
-- (Juego 44: Palworld es autopublicado)
(45, 19),-- Mortal Kombat 1 -> Bethesda (Warner Bros. Games en tu Lote 3 es ID 19)
(46, 16),-- Street Fighter 6 -> Capcom
(47, 17),-- Lies of P -> Bandai Namco (Publicado por Neowiz, usaremos Bandai como similar)
(48, 14),-- Sea of Thieves -> Sony (Publicado por Xbox Game Studios, ID 14)
(49, 14),-- Microsoft Flight Simulator -> Sony (Publicado por Xbox Game Studios, ID 14)
(50, 10),-- The Sims 4 -> Electronic Arts
-- (Juego 51: Valheim es de Coffee Stain, no esta en la lista)
-- (Juego 52: Deep Rock Galactic es de Coffee Stain, no esta en la lista)
(53, 15),-- Nier: Automata -> Square Enix
(54, 14),-- Ori and the Will of the Wisps -> Sony (Publicado por Xbox Game Studios, ID 14)
-- (Juego 55: Subnautica es de Unknown Worlds, no esta en la lista)
(56, 24),-- Outer Wilds -> Annapurna Interactive
(57, 18),-- Disco Elysium -> Sega (Publicado por ZA/UM, usaremos Sega como similar indie)
(58, 23),-- Cuphead -> Devolver Digital (Publicado por Studio MDHR, usaremos Devolver como similar)
(59, 10);-- Rocket League -> Electronic Arts (Publicado por Psyonix/Epic, usaremos EA)
GO
PRINT '--- Lote 27 Finalizado ---'
GO
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 28: JuegosPublishers para Juegos 60-84 ---'
GO

-- IDs de Publisher: (10) EA, (12) Ubisoft, (19) Bethesda, (20) Valve, (23) Devolver Digital
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES 
(60, 19),-- Skyrim -> Bethesda Softworks
(61, 19),-- Fallout 4 -> Bethesda Softworks
(62, 5), -- Divinity: Original Sin 2 -> Larian Studios (ID 5)
(63, 16),-- Monster Hunter: World -> Capcom
(64, 13),-- Borderlands 3 -> Take-Two Interactive
(65, 12),-- AC Odyssey -> Ubisoft
(66, 12),-- AC Valhalla -> Ubisoft
(67, 12),-- Far Cry 5 -> Ubisoft
(68, 12),-- Far Cry 6 -> Ubisoft
(69, 10),-- Titanfall 2 -> Electronic Arts
(70, 10),-- Apex Legends -> Electronic Arts
(71, 12),-- Rainbow Six Siege -> Ubisoft
-- (Juego 72: Slay the Spire es autopublicado)
(73, 23),-- Dead Cells -> Devolver Digital (Publicado por Motion Twin, usaremos Devolver)
(74, 20),-- Portal 2 -> Valve Corporation
(75, 20),-- Half-Life: Alyx -> Valve Corporation
-- (Juego 76: Factorio es autopublicado)
-- (Juego 77: Terraria es autopublicado)
-- (Juego 78: No Man's Sky es autopublicado)
(79, 15),-- Hitman 3 -> Square Enix (Publicado por IO Interactive, usaremos S-E)
(80, 22),-- Metal Gear Solid V -> Konami
(81, 18),-- A Plague Tale: Requiem -> Sega (Publicado por Focus, usaremos Sega)
(82, 20),-- Garry's Mod -> Valve Corporation
(83, 23),-- Vampire Survivors -> Devolver Digital (Autopublicado, usaremos Devolver)
(84, 10);-- F1 23 -> Electronic Arts
GO
PRINT '--- Lote 28 Finalizado ---'
GO
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 29: JuegosPublishers para Juegos 85-109 ---'
GO

-- IDs de Publisher: (10) EA, (12) Ubisoft, (13) Take-Two, (14) Sony,
-- (17) Bandai Namco, (18) Sega, (19) Bethesda.
INSERT INTO JuegosPublishers (IdJuego, IdPublisher) VALUES 
(85, 13),-- Civilization VI -> Take-Two Interactive
(86, 13),-- XCOM 2 -> Take-Two Interactive
(87, 14),-- The Last of Us Part I -> Sony
(88, 14),-- Demon's Souls (Remake) -> Sony
(89, 14),-- Ratchet & Clank: Rift Apart -> Sony
(90, 14),-- Returnal -> Sony
(91, 15),-- Marvel's Guardians of the Galaxy -> Square Enix
(92, 19),-- Hogwarts Legacy -> Bethesda (Warner Bros. Games en tu Lote 3 es ID 19)
(93, 10),-- EA Sports FC 24 -> Electronic Arts
(94, 13),-- NBA 2K24 -> Take-Two Interactive
(95, 10),-- Madden NFL 24 -> Electronic Arts
-- (Juego 96: Dead by Daylight es de Behaviour, no esta en la lista)
(97, 18),-- Alien: Isolation -> Sega
(98, 19),-- Metro Exodus -> Bethesda (Deep Silver/Koch Media, usaremos Bethesda)
(99, 14),-- Days Gone -> Sony
(100, 19),-- Dying Light 2 -> Bethesda (Warner Bros. Games en tu Lote 3 es ID 19)
(101, 18),-- Mount & Blade II: Bannerlord -> Sega (Publicado por TaleWorlds, usaremos Sega)
(102, 18),-- Total War: WARHAMMER III -> Sega
(103, 12),-- Crusader Kings III -> Ubisoft (Publicado por Paradox, usaremos Ubisoft)
(104, 17),-- Tekken 8 -> Bandai Namco
(105, 17),-- Guilty Gear -Strive- -> Bandai Namco
(106, 18),-- Yakuza: Like a Dragon -> Sega
(107, 15),-- Dragon Quest XI S -> Square Enix
-- (Juego 108: Undertale es autopublicado)
(109, 23);-- Shovel Knight -> Devolver Digital (Autopublicado, usaremos Devolver)
GO
PRINT '--- Lote 29 Finalizado ---'
GO

USE EvolutionDB;
GO

-- SOs: 1=Windows, 2=Linux, 3=MacOS
-- Completo 56–75

INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
-- 56: Outer Wilds
(56, 1), (56, 3),

-- 57: Disco Elysium
(57, 1), (57, 2), (57, 3),

-- 58: Cuphead
(58, 1), (58, 3),

-- 59: Rocket League
(59, 1),


-- 61: Fallout 4
(61, 1),

-- 62: Divinity: Original Sin 2
(62, 1), (62, 3),

-- 63: Monster Hunter: World
(63, 1),

-- 64: Borderlands 3
(64, 1),

-- 65: Assassin's Creed Odyssey
(65, 1),

-- 66: Assassin's Creed Valhalla
(66, 1),

-- 67: Far Cry 5
(67, 1),

-- 68: Far Cry 6
(68, 1),

-- 69: Titanfall 2
(69, 1),

-- 70: Apex Legends
(70, 1),

-- 71: Rainbow Six Siege
(71, 1),

-- 72: Slay the Spire
(72, 1), (72, 2), (72, 3),

-- 73: Dead Cells
(73, 1), (73, 2), (73, 3),

-- 74: Portal 2
(74, 1), (74, 2), (74, 3),

-- 75: Half-Life: Alyx
(75, 1);
GO

-- Completo 76–90

INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES
-- 76: Factorio
(76, 1), (76, 2), (76, 3),

-- 77: Terraria
(77, 1), (77, 2), (77, 3),

-- 78: No Man's Sky
(78, 1),

-- 79: Hitman 3
(79, 1),

-- 80: Metal Gear Solid V
(80, 1),

-- 81: A Plague Tale: Requiem
(81, 1),

-- 82: Garry's Mod
(82, 1), (82, 2), (82, 3),

-- 83: Vampire Survivors
(83, 1), (83, 2), (83, 3),

-- 84: F1 23
(84, 1),

-- 85: Sid Meier's Civilization VI
(85, 1), (85, 2), (85, 3),

-- 86: XCOM 2
(86, 1), (86, 2), (86, 3),

-- 87: The Last of Us Part I
(87, 1);

-- 88: Demon's Souls Remake  -> sin asignar (exclusivo de consola en tu dataset)
-- (88, 1) -- NO insertar

-- 89: Ratchet & Clank: Rift Apart
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES (89, 1);

-- 90: Returnal
INSERT INTO SistemasOperativosJuegos (IdJuego, IdSistemaOperativo) VALUES (90, 1);
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 30: Insercion de UsuariosJuegos (Tanda 1) ---'
GO

INSERT INTO UsuariosJuegos (IdUsuario, IdJuego, TiempoTotal, FechaAdquisicion, UltimaVez, EstaEnBiblioteca) VALUES 
(13, 96, 308, '2023-02-21', '2023-06-08 17:51:46', 1),
(52, 88, 79, '2023-09-17', '2024-12-10 17:56:44', 1),
(102, 36, 193, '2023-08-27', '2025-03-19 14:03:19', 1),
(70, 19, 58, '2023-03-14', '2024-06-14 08:33:01', 1),
(155, 22, 140, '2023-02-18', '2023-08-17 23:54:47', 1),
(44, 71, 246, '2025-05-22', '2025-10-02 18:11:24', 1),
(58, 81, 20, '2024-02-06', '2025-04-30 21:47:27', 1),
(61, 95, 88, '2024-11-27', '2024-12-02 13:26:22', 1),
(29, 7, 295, '2023-10-16', '2025-07-11 11:57:00', 1),
(48, 94, 302, '2023-10-22', '2024-08-02 09:50:10', 1),
(16, 64, 68, '2025-07-17', '2025-10-29 21:44:13', 1),
(116, 90, 189, '2023-07-09', '2025-10-29 19:25:25', 1),
(27, 105, 172, '2024-08-11', '2024-08-20 07:48:32', 1),
(103, 88, 218, '2023-10-03', '2025-10-11 16:42:57', 1),
(114, 64, 335, '2023-07-20', '2024-11-02 22:03:49', 1),
(23, 2, 77, '2024-11-01', '2025-02-20 21:49:26', 1),
(33, 37, 182, '2023-11-20', '2024-07-03 07:05:38', 1),
(9, 74, 223, '2023-05-24', '2023-11-21 10:14:10', 1),
(36, 96, 184, '2025-02-16', '2025-04-07 17:39:19', 1),
(91, 38, 163, '2025-08-09', '2025-09-25 16:27:28', 1),
(59, 48, 17, '2023-02-12', '2023-08-18 14:22:17', 1),
(144, 3, 233, '2024-11-29', '2025-08-16 07:17:28', 1),
(103, 60, 33, '2023-11-17', '2024-03-14 21:42:25', 1),
(33, 59, 48, '2024-04-28', '2025-08-28 17:06:41', 1),
(91, 64, 160, '2025-10-27', '2025-10-27 22:01:27', 1),
(49, 18, 135, '2024-03-30', '2024-06-28 07:19:53', 1),
(114, 52, 271, '2025-03-18', '2025-07-02 19:26:41', 1),
(133, 21, 38, '2024-11-29', '2025-08-30 23:01:37', 1),
(60, 40, 296, '2024-03-23', '2024-04-01 18:20:57', 1),
(78, 73, 251, '2025-08-26', '2025-10-13 13:58:34', 1),
(142, 96, 232, '2025-03-08', '2025-10-01 04:58:53', 1),
(127, 52, 161, '2023-03-10', '2024-11-05 08:49:44', 1),
(72, 40, 218, '2023-10-31', '2024-01-31 17:15:13', 1),
(128, 54, 245, '2024-10-06', '2025-06-07 10:05:19', 1),
(90, 8, 116, '2023-04-05', '2025-09-30 00:25:07', 1),
(71, 75, 49, '2025-10-05', '2025-10-22 08:07:43', 1),
(80, 21, 178, '2023-12-22', '2024-05-28 09:54:01', 1),
(103, 17, 77, '2023-07-07', '2025-05-05 16:04:46', 1),
(74, 2, 175, '2025-07-04', '2025-10-15 13:30:28', 1),
(74, 25, 220, '2024-09-10', '2025-04-23 15:45:59', 1);

PRINT '--- Tanda 1 de 40 Registros (Lote 30) Finalizada ---'
GO
USE EvolutionDB;
GO

INSERT INTO UsuariosWishlist (IdUsuario, IdProducto, FechaAgregado) VALUES
(1, 3, '2025-01-10'), -- Usuario 1 quiere The Witcher 3
(2, 5, '2025-03-20'), -- Usuario 2 quiere Minecraft
(5, 8, '2025-04-02'), -- Usuario 5 quiere Cities: Skylines
(6, 6, '2025-02-15'), -- Usuario 6 quiere Baldur’s Gate 3
(8, 10, '2025-01-30'), -- Usuario 8 quiere Red Dead Redemption 2
(9, 11, '2025-05-12'), -- Usuario 9 quiere DLC de Darkest Dungeon
(10, 19, '2025-06-05'), -- Usuario 10 quiere DOOM Eternal
(11, 22, '2025-07-08'), -- Usuario 11 quiere Horizon Zero Dawn
(12, 31, '2025-08-01'), -- Usuario 12 quiere Control
(13, 60, '2025-09-10'), -- Usuario 13 quiere Skyrim
(14, 51, '2025-09-20'), -- Usuario 14 quiere The Sims 4
(15, 44, '2025-10-03'), -- Usuario 15 quiere Palworld
(16, 47, '2025-10-05'), -- Usuario 16 quiere Lies of P
(17, 66, '2025-10-08'), -- Usuario 17 quiere Assassin's Creed Valhalla
(18, 75, '2025-10-10'), -- Usuario 18 quiere Half-Life: Alyx
(19, 85, '2025-10-15'), -- Usuario 19 quiere Civilization VI
(20, 90, '2025-10-25'); -- Usuario 20 quiere Returnal
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 26: JuegosDesarrolladoras (Tanda 1) ---'
GO

-- IDs de Desarrolladora: 1=CD Projekt, 2=Rockstar, 3=Nintendo, 10=Naughty Dog,
-- 11=Santa Monica, 12=Insomniac, 15=FromSoftware, 16=Kojima, 20=Guerrilla,
-- 22=Square Enix, 23=Capcom, 24=Remedy
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES  -- The Witcher 3 -> CD Projekt Red
(10, 2), -- RDR 2 -> Rockstar Games
(11, 15),-- Elden Ring -> FromSoftware
(12, 2),-- Zelda: BOTW -> Nintendo-- God of War Ragnarök -> Santa Monica Studio
(16, 12),-- Marvel's Spider-Man -> Insomniac Games
(17, 10),-- The Last of Us Part II -> Naughty Dog
(20, 23),-- RE4 Remake -> Capcom
(21, 23),-- RE Village -> Capcom
(22, 20),-- Horizon Zero Dawn -> Guerrilla Games
(24, 10),-- Uncharted 4 -> Naughty Dog
(25, 15),-- Bloodborne -> FromSoftware
(26, 15),-- Sekiro -> FromSoftware
(27, 15),-- Dark Souls III -> FromSoftware
(31, 24),-- Control -> Remedy Entertainment
(32, 16),-- Death Stranding -> Kojima Productions
(33, 22);-- Final Fantasy VII Remake -> Square Enix
GO
PRINT '--- Lote 26 Finalizado ---'
GO
USE EvolutionDB
GO
PRINT '--- Iniciando Lote 27: JuegosDesarrolladoras (Tanda 2) ---'
GO

-- IDs de Desarrolladora: 6=Larian, 10=Naughty Dog, 12=Insomniac, 13=Ubisoft Montreal,
-- 15=FromSoftware, 16=Kojima, 17=Valve, 19=Blizzard, 21=BioWare, 22=Square Enix,
-- 23=Capcom, 24=Remedy
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES 
(35, 24),-- Street Fighter 6 -> Capcom
(62, 6), -- Divinity: Original Sin 2 -> Larian Studios
(63, 23),-- Monster Hunter: World -> Capcom
(65, 13),-- AC Odyssey -> Ubisoft Montreal
(66, 13),-- AC Valhalla -> Ubisoft Montreal
(67, 13),-- Far Cry 5 -> Ubisoft Montreal
(68, 13),-- Far Cry 6 -> Ubisoft Montreal
(71, 13),-- Rainbow Six Siege -> Ubisoft Montreal
(74, 17),-- Portal 2 -> Valve Corporation
(75, 17),-- Half-Life: Alyx -> Valve Corporation
(80, 16),-- Metal Gear Solid V -> Kojima Productions
(82, 17),-- Garry's Mod -> Valve Corporation
(87, 10),-- The Last of Us Part I -> Naughty Dog
(88, 15),-- Demon's Souls (Remake) -> FromSoftware
(89, 12),-- Ratchet & Clank: Rift Apart -> Insomniac Games
(107, 22);-- Dragon Quest XI S -> Square Enix
GO
PRINT '--- Lote 27 Finalizado ---'
GO
USE EvolutionDB;
GO

INSERT INTO UsuariosWishlist (IdUsuario, IdProducto, FechaAgregado) VALUES
(21, 19, '2025-01-03'), -- Usuario 21 quiere DOOM Eternal
(22, 22, '2025-01-04'), -- Usuario 22 quiere Horizon Zero Dawn
(23, 31, '2025-01-06'), -- Usuario 23 quiere Control
(24, 60, '2025-01-07'), -- Usuario 24 quiere Skyrim
(25, 51, '2025-01-08'), -- Usuario 25 quiere The Sims 4
(26, 35, '2025-01-09'), -- Usuario 26 quiere Alan Wake 2
(27, 37, '2025-01-10'), -- Usuario 27 quiere Starfield
(28, 38, '2025-01-12'), -- Usuario 28 quiere Forza Horizon 5
(29, 40, '2025-01-14'), -- Usuario 29 quiere Dead Space Remake
(30, 41, '2025-01-15'), -- Usuario 30 quiere Mass Effect Legendary Edition
(31, 42, '2025-01-16'), -- Usuario 31 quiere It Takes Two
(32, 43, '2025-01-17'), -- Usuario 32 quiere Satisfactory
(33, 44, '2025-01-18'), -- Usuario 33 quiere Palworld
(34, 45, '2025-01-19'), -- Usuario 34 quiere Mortal Kombat 1
(35, 46, '2025-01-20'), -- Usuario 35 quiere Street Fighter 6
(36, 47, '2025-01-22'), -- Usuario 36 quiere Lies of P
(37, 48, '2025-01-24'), -- Usuario 37 quiere Sea of Thieves
(38, 49, '2025-01-26'), -- Usuario 38 quiere Microsoft Flight Simulator
(39, 50, '2025-01-27'), -- Usuario 39 quiere The Sims 3
(40, 52, '2025-01-28'), -- Usuario 40 quiere Valheim
(41, 53, '2025-01-29'), -- Usuario 41 quiere Deep Rock Galactic
(42, 54, '2025-02-01'), -- Usuario 42 quiere NieR: Automata
(43, 55, '2025-02-03'), -- Usuario 43 quiere Ori and the Will of the Wisps
(44, 56, '2025-02-05'), -- Usuario 44 quiere Outer Wilds
(45, 57, '2025-02-06'), -- Usuario 45 quiere Disco Elysium
(46, 58, '2025-02-08'), -- Usuario 46 quiere Cuphead
(47, 59, '2025-02-10'), -- Usuario 47 quiere Rocket League
(48, 61, '2025-02-11'), -- Usuario 48 quiere Fallout 4
(49, 62, '2025-02-13'), -- Usuario 49 quiere Divinity: Original Sin 2
(50, 63, '2025-02-15'), -- Usuario 50 quiere Monster Hunter World
(51, 64, '2025-02-16'), -- Usuario 51 quiere Borderlands 3
(52, 65, '2025-02-17'), -- Usuario 52 quiere Assassin’s Creed Odyssey
(53, 66, '2025-02-19'), -- Usuario 53 quiere Assassin’s Creed Valhalla
(54, 67, '2025-02-21'), -- Usuario 54 quiere Far Cry 5
(55, 68, '2025-02-22'), -- Usuario 55 quiere Far Cry 6
(56, 69, '2025-02-24'), -- Usuario 56 quiere Titanfall 2
(57, 70, '2025-02-25'), -- Usuario 57 quiere Apex Legends
(58, 71, '2025-02-26'), -- Usuario 58 quiere Rainbow Six Siege
(59, 72, '2025-02-28'), -- Usuario 59 quiere Slay the Spire
(60, 73, '2025-03-02'), -- Usuario 60 quiere Dead Cells
(61, 74, '2025-03-04'), -- Usuario 61 quiere Portal 2
(62, 75, '2025-03-05'), -- Usuario 62 quiere Half-Life Alyx
(63, 76, '2025-03-06'), -- Usuario 63 quiere Factorio
(64, 77, '2025-03-07'), -- Usuario 64 quiere Terraria
(65, 78, '2025-03-08'), -- Usuario 65 quiere No Man's Sky
(66, 79, '2025-03-09'), -- Usuario 66 quiere Hitman 3
(67, 80, '2025-03-10'), -- Usuario 67 quiere Metal Gear Solid V
(68, 81, '2025-03-12'), -- Usuario 68 quiere A Plague Tale: Requiem
(69, 82, '2025-03-14'), -- Usuario 69 quiere Garry's Mod
(70, 83, '2025-03-15'), -- Usuario 70 quiere Vampire Survivors
(71, 84, '2025-03-17'), -- Usuario 71 quiere F1 23
(72, 85, '2025-03-19'), -- Usuario 72 quiere Civilization VI
(73, 86, '2025-03-20'), -- Usuario 73 quiere XCOM 2
(74, 87, '2025-03-21'), -- Usuario 74 quiere The Last of Us Part I
(75, 89, '2025-03-22'), -- Usuario 75 quiere Ratchet & Clank: Rift Apart
(76, 90, '2025-03-23'), -- Usuario 76 quiere Returnal
(77, 91, '2025-03-25'), -- Usuario 77 quiere Guardians of the Galaxy
(78, 92, '2025-03-26'), -- Usuario 78 quiere Hogwarts Legacy
(79, 93, '2025-03-28'), -- Usuario 79 quiere EA Sports FC 24
(80, 94, '2025-03-30'), -- Usuario 80 quiere NBA 2K24
(81, 95, '2025-04-01'), -- Usuario 81 quiere Madden 24
(82, 96, '2025-04-02'), -- Usuario 82 quiere Dead by Daylight
(83, 97, '2025-04-03'), -- Usuario 83 quiere Alien: Isolation
(84, 98, '2025-04-04'), -- Usuario 84 quiere Resident Evil 2 Remake
(85, 99, '2025-04-05'), -- Usuario 85 quiere Dragon Quest XI S
(86, 100, '2025-04-06'), -- Usuario 86 quiere Undertale
(87, 101, '2025-04-08'), -- Usuario 87 quiere Tekken 8
(88, 102, '2025-04-09'), -- Usuario 88 quiere Guilty Gear Strive
(89, 103, '2025-04-10'), -- Usuario 89 quiere Total War: Warhammer III
(90, 104, '2025-04-11'), -- Usuario 90 quiere Crusader Kings III
(91, 105, '2025-04-12'), -- Usuario 91 quiere Mount & Blade II: Bannerlord
(92, 106, '2025-04-13'), -- Usuario 92 quiere Dying Light 2 Stay Human
(93, 107, '2025-04-15'), -- Usuario 93 quiere Yakuza: Like a Dragon
(94, 108, '2025-04-16'), -- Usuario 94 quiere Dragon Quest XI S Definitive
(95, 109, '2025-04-17'), -- Usuario 95 quiere Shovel Knight
(96, 10, '2025-04-18'),  -- Usuario 96 quiere Red Dead Redemption 2
(97, 11, '2025-04-19'),  -- Usuario 97 quiere Elden Ring
(98, 14, '2025-04-20'),  -- Usuario 98 quiere God of War (2018)
(99, 16, '2025-04-21'),  -- Usuario 99 quiere Marvel’s Spider-Man
(100, 19, '2025-04-22'); -- Usuario 100 quiere DOOM Eternal
GO

USE EvolutionDB;
GO

INSERT INTO DatosPagosGuardados (IdUsuario, NumTarjeta, IdFormaPago) VALUES
(1, '4000111122223333', 1), -- Visa crédito
(2, '4111222233334444', 2), -- Débito
(5, '4222333344445555', 1), -- Crédito
(6, '4333444455556666', 1), -- Crédito
(8, '4444555566667777', 2), -- Débito
(9, '4555666677778888', 1), -- Crédito
(10, '4666777788889999', 1), -- Crédito
(11, '4777888899990000', 2), -- Débito
(12, '4888999900001111', 1), -- Crédito
(13, '4999000011112222', 1), -- Crédito
(14, '5000111122223333', 2), -- Débito
(15, '5111222233334444', 1), -- Crédito
(16, '5222333344445555', 1), -- Crédito
(17, '5333444455556666', 2), -- Débito
(18, '5444555566667777', 1), -- Crédito
(19, '5555666677778888', 1), -- Crédito
(20, '5666777788889999', 2), -- Débito
(21, '5777888899990000', 1), -- Crédito
(22, '5888999900001111', 1), -- Crédito
(23, '5999000011112222', 2), -- Débito
(24, '6000111122223333', 1), -- Crédito
(25, '6111222233334444', 1), -- Crédito
(26, '6222333344445555', 2), -- Débito
(27, '6333444455556666', 1), -- Crédito
(28, '6444555566667777', 1), -- Crédito
(29, '6555666677778888', 2), -- Débito
(30, '6666777788889999', 1), -- Crédito
(31, '6777888899990000', 1), -- Crédito
(32, '6888999900001111', 2), -- Débito
(33, '6999000011112222', 1), -- Crédito
(34, '7000111122223333', 1), -- Crédito
(35, '7111222233334444', 2), -- Débito
(36, '7222333344445555', 1), -- Crédito
(37, '7333444455556666', 1), -- Crédito
(38, '7444555566667777', 2), -- Débito
(39, '7555666677778888', 1), -- Crédito
(40, '7666777788889999', 1), -- Crédito
(41, '7777888899990000', 2), -- Débito
(42, '7888999900001111', 1), -- Crédito
(43, '7999000011112222', 1), -- Crédito
(44, '8000111122223333', 2), -- Débito
(45, '8111222233334444', 1), -- Crédito
(46, '8222333344445555', 1), -- Crédito
(47, '8333444455556666', 2), -- Débito
(48, '8444555566667777', 1), -- Crédito
(49, '8555666677778888', 1), -- Crédito
(50, '8666777788889999', 2); -- Débito
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 26: JuegosDesarrolladoras (Tanda 1) ---'
GO

-- IDs de Desarrolladora: 1=CD Projekt, 2=Rockstar, 3=Nintendo, 10=Naughty Dog,
-- 11=Santa Monica, 12=Insomniac, 15=FromSoftware, 16=Kojima, 20=Guerrilla,
-- 22=Square Enix, 23=Capcom, 24=Remedy
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES  -- GTA V -> Rockstar Games
(13, 3), -- Zelda: BOTW -> Nintendo
(14, 11),-- God of War (2018) -> Santa Monica Studio
(15, 11),-- God of War Ragnarök -> Santa Monica Studio
(16, 12),-- Marvel's Spider-Man -> Insomniac Games
(17, 10),-- The Last of Us Part II -> Naughty Dog
(20, 23),-- RE4 Remake -> Capcom
(21, 23),-- RE Village -> Capcom
(22, 20),-- Horizon Zero Dawn -> Guerrilla Games
(24, 10),-- Uncharted 4 -> Naughty Dog
(25, 15),-- Bloodborne -> FromSoftware
(26, 15),-- Sekiro -> FromSoftware
(27, 15),-- Dark Souls III -> FromSoftware
(31, 24),-- Control -> Remedy Entertainment
(32, 16),-- Death Stranding -> Kojima Productions
(33, 22);-- Final Fantasy VII Remake -> Square Enix
GO
PRINT '--- Lote 26 Finalizado ---'
GO

USE EvolutionDB
GO
PRINT '--- Iniciando Lote 27: JuegosDesarrolladoras (Tanda 2) ---'
GO

-- IDs de Desarrolladora: 6=Larian, 10=Naughty Dog, 12=Insomniac, 13=Ubisoft Montreal,
-- 15=FromSoftware, 16=Kojima, 17=Valve, 19=Blizzard, 21=BioWare, 22=Square Enix,
-- 23=Capcom, 24=Remedy
INSERT INTO JuegosDesarrolladoras (IdJuego, IdDesarrolladora) VALUES -- Alan Wake 2 -> Remedy Entertainment
(36, 19),-- Diablo IV -> Blizzard Entertainment
(41, 21),-- Street Fighter 6 -> Capcom
(62, 6), -- Divinity: Original Sin 2 -> Larian Studios
(63, 23),-- Monster Hunter: World -> Capcom
(65, 13),-- AC Odyssey -> Ubisoft Montreal
(66, 13),-- AC Valhalla -> Ubisoft Montreal
(67, 13),-- Far Cry 5 -> Ubisoft Montreal
(68, 13),-- Far Cry 6 -> Ubisoft Montreal
(71, 13),-- Rainbow Six Siege -> Ubisoft Montreal
(74, 17),-- Portal 2 -> Valve Corporation
(75, 17),-- Half-Life: Alyx -> Valve Corporation
(80, 16),-- Metal Gear Solid V -> Kojima Productions
(82, 17),-- Garry's Mod -> Valve Corporation
(87, 10),-- The Last of Us Part I -> Naughty Dog
(88, 15),-- Demon's Souls (Remake) -> FromSoftware
(89, 12),-- Ratchet & Clank: Rift Apart -> Insomniac Games
(107, 22);-- Dragon Quest XI S -> Square Enix
GO
PRINT '--- Lote 27 Finalizado ---'
GO

USE EvolutionDB;
GO

-- Continuación desde el usuario 51 hasta el 100
INSERT INTO DatosPagosGuardados (IdUsuario, NumTarjeta, IdFormaPago) VALUES
(51, '8777888899990000', 1), -- Crédito
(52, '8888999900001111', 2), -- Débito
(53, '8999000011112222', 1), -- Crédito
(54, '9000111122223333', 1), -- Crédito
(55, '9111222233334444', 2), -- Débito
(56, '9222333344445555', 1), -- Crédito
(57, '9333444455556666', 1), -- Crédito
(58, '9444555566667777', 2), -- Débito
(59, '9555666677778888', 1), -- Crédito
(60, '9666777788889999', 1), -- Crédito
(61, '9777888899990000', 2), -- Débito
(62, '9888999900001111', 1), -- Crédito
(63, '9999000011112222', 1), -- Crédito
(64, '1000111122223333', 2), -- Débito
(65, '1011222233334444', 1), -- Crédito
(66, '1022333344445555', 1), -- Crédito
(67, '1033444455556666', 2), -- Débito
(68, '1044555566667777', 1), -- Crédito
(69, '1055666677778888', 1), -- Crédito
(70, '1066777788889999', 2), -- Débito
(71, '1077888899990000', 1), -- Crédito
(72, '1088999900001111', 1), -- Crédito
(73, '1099000011112222', 2), -- Débito
(74, '1100111122223333', 1), -- Crédito
(75, '1111222233334444', 1), -- Crédito
(76, '1122333344445555', 2), -- Débito
(77, '1133444455556666', 1), -- Crédito
(78, '1144555566667777', 1), -- Crédito
(79, '1155666677778888', 2), -- Débito
(80, '1166777788889999', 1), -- Crédito
(81, '1177888899990000', 1), -- Crédito
(82, '1188999900001111', 2), -- Débito
(83, '1199000011112222', 1), -- Crédito
(84, '1200111122223333', 1), -- Crédito
(85, '1211222233334444', 2), -- Débito
(86, '1222333344445555', 1), -- Crédito
(87, '1233444455556666', 1), -- Crédito
(88, '1244555566667777', 2), -- Débito
(89, '1255666677778888', 1), -- Crédito
(90, '1266777788889999', 1), -- Crédito
(91, '1277888899990000', 2), -- Débito
(92, '1288999900001111', 1), -- Crédito
(93, '1299000011112222', 1), -- Crédito
(94, '1300111122223333', 2), -- Débito
(95, '1311222233334444', 1), -- Crédito
(96, '1322333344445555', 1), -- Crédito
(97, '1333444455556666', 2), -- Débito
(98, '1344555566667777', 1), -- Crédito
(99, '1355666677778888', 1), -- Crédito
(100, '1366777788889999', 2); -- Débito
GO

USE EvolutionDB;
GO

INSERT INTO DatosPagosGuardados (IdUsuario, NumTarjeta, IdFormaPago) VALUES
(3, '2000111122223333', 1), -- Segunda tarjeta crédito
(3, '2000222233334444', 2), -- Tarjeta débito
(4, '2000333344445555', 1), -- Segunda tarjeta crédito
(7, '2000444455556666', 1), -- Crédito adicional
(7, '2000555566667777', 2), -- Débito adicional
(8, '2000666677778888', 1), -- Crédito
(9, '2000777788889999', 2), -- Débito
(10, '2000888899990000', 1), -- Crédito
(11, '2000999900001111', 1), -- Crédito
(12, '2001000011112222', 2), -- Débito
(13, '2001111122223333', 1), -- Crédito
(14, '2001222233334444', 2), -- Débito
(15, '2001333344445555', 1), -- Crédito
(15, '2001444455556666', 2), -- Débito adicional
(16, '2001555566667777', 1), -- Crédito
(17, '2001666677778888', 1), -- Crédito
(18, '2001777788889999', 2), -- Débito
(19, '2001888899990000', 1), -- Crédito
(20, '2001999900001111', 1), -- Crédito
(21, '2002000011112222', 2), -- Débito
(22, '2002111122223333', 1), -- Crédito
(23, '2002222233334444', 1), -- Crédito
(24, '2002333344445555', 2), -- Débito
(25, '2002444455556666', 1), -- Crédito
(26, '2002555566667777', 1), -- Crédito
(27, '2002666677778888', 2), -- Débito
(28, '2002777788889999', 1), -- Crédito
(29, '2002888899990000', 1), -- Crédito
(30, '2002999900001111', 2), -- Débito
(31, '2003000011112222', 1), -- Crédito
(32, '2003111122223333', 1), -- Crédito
(33, '2003222233334444', 2), -- Débito
(34, '2003333344445555', 1), -- Crédito
(35, '2003444455556666', 1), -- Crédito
(36, '2003555566667777', 2), -- Débito
(37, '2003666677778888', 1), -- Crédito
(38, '2003777788889999', 1), -- Crédito
(39, '2003888899990000', 2), -- Débito
(40, '2003999900001111', 1), -- Crédito
(41, '2004000011112222', 1), -- Crédito
(42, '2004111122223333', 2), -- Débito
(43, '2004222233334444', 1), -- Crédito
(44, '2004333344445555', 1), -- Crédito
(45, '2004444455556666', 2), -- Débito
(46, '2004555566667777', 1), -- Crédito
(47, '2004666677778888', 1), -- Crédito
(48, '2004777788889999', 2), -- Débito
(49, '2004888899990000', 1), -- Crédito
(50, '2004999900001111', 1); -- Crédito
GO

USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(1, '2024-01-05 11:00:00', 'Compra', 1),
(2, '2024-01-07 14:30:00', 'Compra', 2),
(3, '2024-02-15 10:00:00', 'Compra', 3),
(4, '2024-02-20 09:45:00', 'Compra', 4),
(5, '2024-02-22 12:00:00', 'Compra', 5),
(6, '2024-02-23 13:15:00', 'Compra', 6),
(7, '2024-02-25 17:00:00', 'Compra', 7),
(8, '2024-03-01 15:20:00', 'Compra', 8),
(9, '2024-03-02 19:00:00', 'Compra', 9),
(10, '2024-03-03 09:10:00', 'Compra', 10),
(11, '2024-03-04 10:45:00', 'Compra', 11),
(12, '2024-03-05 11:15:00', 'Compra', 12),
(13, '2024-03-06 18:20:00', 'Compra', 13),
(14, '2024-03-07 14:10:00', 'Compra', 14),
(15, '2024-03-08 16:30:00', 'Compra', 15),
(16, '2024-03-10 10:00:00', 'Compra', 16),
(17, '2024-03-11 13:40:00', 'Compra', 17),
(18, '2024-03-12 09:30:00', 'Compra', 18),
(19, '2024-03-13 12:00:00', 'Compra', 19),
(20, '2024-03-14 16:50:00', 'Compra', 20),
(21, '2024-03-15 19:20:00', 'Compra', 21),
(22, '2024-03-17 11:40:00', 'Compra', 22),
(23, '2024-03-18 14:00:00', 'Compra', 23),
(24, '2024-03-20 15:30:00', 'Compra', 24),
(25, '2024-03-21 10:00:00', 'Compra', 25),
(26, '2024-03-22 12:15:00', 'Compra', 26),
(27, '2024-03-23 09:45:00', 'Compra', 27),
(28, '2024-03-24 17:10:00', 'Compra', 28),
(29, '2024-03-25 11:00:00', 'Compra', 29),
(30, '2024-03-26 14:30:00', 'Compra', 30),
(31, '2024-03-27 15:45:00', 'Compra', 31),
(32, '2024-03-28 18:00:00', 'Compra', 32),
(33, '2024-03-29 10:15:00', 'Compra', 33),
(34, '2024-04-01 12:20:00', 'Compra', 34),
(35, '2024-04-02 19:00:00', 'Compra', 35),
(36, '2024-04-03 11:10:00', 'Compra', 36),
(37, '2024-04-04 16:00:00', 'Compra', 37),
(38, '2024-04-05 15:00:00', 'Compra', 38),
(39, '2024-04-06 13:30:00', 'Compra', 39),
(40, '2024-04-07 09:40:00', 'Compra', 40),
(41, '2024-04-08 10:50:00', 'Compra', 41),
(42, '2024-04-09 12:45:00', 'Compra', 42),
(43, '2024-04-10 15:30:00', 'Compra', 43),
(44, '2024-04-11 17:10:00', 'Compra', 44),
(45, '2024-04-12 09:50:00', 'Compra', 45),
(46, '2024-04-13 11:15:00', 'Compra', 46),
(47, '2024-04-14 18:25:00', 'Compra', 47),
(48, '2024-04-15 20:10:00', 'Compra', 48),
(49, '2024-04-16 14:00:00', 'Compra', 49),
(50, '2024-04-17 10:30:00', 'Compra', 50);
GO

USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(12, '2024-04-18 13:00:00', 'Compra', 51),
(15, '2024-04-19 16:30:00', 'Compra', 52),
(18, '2024-04-20 09:00:00', 'Compra', 53),
(20, '2024-04-21 10:45:00', 'Compra', 54),
(21, '2024-04-22 12:30:00', 'Compra', 55),
(22, '2024-04-23 18:15:00', 'Compra', 56),
(25, '2024-04-24 19:10:00', 'Compra', 57),
(26, '2024-04-25 14:00:00', 'Compra', 58),
(28, '2024-04-26 15:40:00', 'Compra', 59),
(29, '2024-04-27 17:50:00', 'Compra', 60),
(30, '2024-04-28 11:00:00', 'Gift', 61),
(32, '2024-04-29 09:20:00', 'Compra', 62),
(33, '2024-04-30 12:30:00', 'Compra', 63),
(34, '2024-05-01 16:10:00', 'Compra', 64),
(35, '2024-05-02 20:00:00', 'Compra', 65),
(36, '2024-05-03 10:00:00', 'Compra', 66),
(37, '2024-05-04 15:45:00', 'Compra', 67),
(38, '2024-05-05 19:30:00', 'Compra', 68),
(39, '2024-05-06 09:00:00', 'Compra', 69),
(40, '2024-05-07 13:50:00', 'Compra', 70),
(41, '2024-05-08 17:40:00', 'Compra', 71),
(42, '2024-05-09 11:15:00', 'Compra', 72),
(43, '2024-05-10 10:00:00', 'Gift', 73),
(44, '2024-05-11 19:10:00', 'Compra', 74),
(45, '2024-05-12 09:30:00', 'Compra', 75),
(46, '2024-05-13 15:20:00', 'Compra', 76),
(47, '2024-05-14 18:10:00', 'Compra', 77),
(48, '2024-05-15 13:00:00', 'Compra', 78),
(49, '2024-05-16 10:45:00', 'Devolución', 79),
(50, '2024-05-17 20:00:00', 'Compra', 80),
(51, '2024-05-18 09:00:00', 'Compra', 81),
(52, '2024-05-19 12:10:00', 'Compra', 82),
(53, '2024-05-20 11:40:00', 'Compra', 83),
(54, '2024-05-21 16:20:00', 'Compra', 84),
(55, '2024-05-22 09:30:00', 'Compra', 85),
(56, '2024-05-23 14:30:00', 'Compra', 86),
(57, '2024-05-24 15:15:00', 'Compra', 87),
(58, '2024-05-25 13:10:00', 'Compra', 88),
(59, '2024-05-26 19:40:00', 'Compra', 89),
(60, '2024-05-27 11:00:00', 'Compra', 90),
(61, '2024-05-28 17:00:00', 'Compra', 91),
(62, '2024-05-29 10:30:00', 'Compra', 92),
(63, '2024-05-30 14:45:00', 'Compra', 93),
(64, '2024-05-31 09:20:00', 'Gift', 94),
(65, '2024-06-01 16:00:00', 'Compra', 95),
(66, '2024-06-02 11:00:00', 'Compra', 96),
(67, '2024-06-03 19:00:00', 'Compra', 97),
(68, '2024-06-04 13:00:00', 'Recarga', 98),
(69, '2024-06-05 15:30:00', 'Compra', 99),
(70, '2024-06-06 10:00:00', 'Compra', 100);
GO
USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(71, '2024-07-01 11:00:00', 'Compra', 101), -- Usuario 71 compra Cyberpunk 2077
(12, '2024-07-01 15:20:00', 'Compra', 102), -- Usuario 12 compra Stardew Valley
(9,  '2024-07-02 18:45:00', 'Compra', 103), -- Usuario 9 compra The Witcher 3
(33, '2024-07-02 20:00:00', 'Compra', 104), -- Usuario 33 compra Darkest Dungeon
(18, '2024-07-03 09:10:00', 'Compra', 105), -- Usuario 18 compra Minecraft
(3,  '2024-07-03 10:30:00', 'Recarga', 106), -- Usuario 3 recarga saldo
(45, '2024-07-04 17:00:00', 'Compra', 107), -- Usuario 45 compra Baldur's Gate 3
(27, '2024-07-04 19:30:00', 'Compra', 108), -- Usuario 27 compra Hollow Knight
(8,  '2024-07-05 11:15:00', 'Compra', 109), -- Usuario 8 compra Cities: Skylines
(55, '2024-07-05 13:50:00', 'Gift', 110), -- Usuario 55 regala Phasmophobia
(14, '2024-07-06 09:00:00', 'Compra', 111), -- Usuario 14 compra Red Dead Redemption 2
(77, '2024-07-06 15:30:00', 'Compra', 112), -- Usuario 77 compra Elden Ring
(29, '2024-07-07 14:10:00', 'Compra', 113), -- Usuario 29 compra GTA V
(61, '2024-07-07 18:00:00', 'Compra', 114), -- Usuario 61 compra God of War
(44, '2024-07-08 10:00:00', 'Compra', 115), -- Usuario 44 compra God of War Ragnarök
(12, '2024-07-08 16:00:00', 'Compra', 116), -- Usuario 12 compra Spider-Man Remastered
(92, '2024-07-09 09:20:00', 'Compra', 117), -- Usuario 92 compra The Last of Us Part II
(13, '2024-07-09 11:45:00', 'Compra', 118), -- Usuario 13 compra DOOM (2016)
(71, '2024-07-10 12:15:00', 'Compra', 119), -- Usuario 71 compra DOOM Eternal
(88, '2024-07-10 15:50:00', 'Compra', 120), -- Usuario 88 compra Resident Evil 4 Remake
(41, '2024-07-11 13:10:00', 'Compra', 121), -- Usuario 41 compra Resident Evil Village
(52, '2024-07-11 18:40:00', 'Compra', 122), -- Usuario 52 compra Hades
(6,  '2024-07-12 09:00:00', 'Compra', 123), -- Usuario 6 compra Ghost of Tsushima
(47, '2024-07-12 12:20:00', 'Compra', 124), -- Usuario 47 compra Uncharted 4
(88, '2024-07-13 14:45:00', 'Devolución', 125), -- Usuario 88 devuelve Bloodborne
(10, '2024-07-13 17:00:00', 'Compra', 126), -- Usuario 10 compra Sekiro
(5,  '2024-07-14 09:30:00', 'Compra', 127), -- Usuario 5 compra Dark Souls III
(22, '2024-07-14 12:00:00', 'Gift', 128), -- Usuario 22 regala Celeste
(80, '2024-07-15 10:25:00', 'Compra', 129), -- Usuario 80 compra Cuphead
(38, '2024-07-15 14:10:00', 'Compra', 130), -- Usuario 38 compra Rocket League
(100,'2024-07-16 16:00:00', 'Compra', 131), -- Usuario 100 compra Persona 5 Royal
(17, '2024-07-16 19:00:00', 'Compra', 132), -- Usuario 17 compra Control
(26, '2024-07-17 11:10:00', 'Compra', 133), -- Usuario 26 compra Death Stranding
(33, '2024-07-17 13:45:00', 'Compra', 134), -- Usuario 33 compra FF VII Remake
(4,  '2024-07-18 15:00:00', 'Compra', 135), -- Usuario 4 compra Helldivers 2
(85, '2024-07-18 18:30:00', 'Compra', 136), -- Usuario 85 compra Alan Wake 2
(51, '2024-07-19 11:20:00', 'Compra', 137), -- Usuario 51 compra Diablo IV
(62, '2024-07-19 14:40:00', 'Compra', 138), -- Usuario 62 compra Starfield
(39, '2024-07-20 09:00:00', 'Compra', 139), -- Usuario 39 compra Forza Horizon 5
(19, '2024-07-20 16:15:00', 'Compra', 140), -- Usuario 19 compra Jedi: Survivor
(72, '2024-07-21 13:00:00', 'Compra', 141), -- Usuario 72 compra Dead Space Remake
(11, '2024-07-21 18:45:00', 'Compra', 142), -- Usuario 11 compra Mass Effect LE
(50, '2024-07-22 10:30:00', 'Compra', 143), -- Usuario 50 compra It Takes Two
(60, '2024-07-22 15:00:00', 'Compra', 144), -- Usuario 60 compra Satisfactory
(31, '2024-07-23 09:30:00', 'Compra', 145), -- Usuario 31 compra Palworld
(73, '2024-07-23 12:15:00', 'Compra', 146), -- Usuario 73 compra Mortal Kombat 1
(14, '2024-07-24 19:10:00', 'Compra', 147), -- Usuario 14 compra Street Fighter 6
(8,  '2024-07-24 20:00:00', 'Compra', 148), -- Usuario 8 compra Lies of P
(42, '2024-07-25 11:40:00', 'Compra', 149), -- Usuario 42 compra Sea of Thieves
(59, '2024-07-25 18:00:00', 'Compra', 150); -- Usuario 59 compra Microsoft Flight Simulator
GO

USE EvolutionDB;
GO
USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(21, '2024-09-01 10:00:00', 'Compra', 151), -- Usuario 21 compra The Sims 4
(66, '2024-09-01 12:30:00', 'Compra', 152), -- Usuario 66 compra Assassin's Creed Valhalla
(4,  '2024-09-02 09:15:00', 'Compra', 153), -- Usuario 4 compra Minecraft
(87, '2024-09-02 16:40:00', 'Compra', 154), -- Usuario 87 compra The Last of Us Part I
(58, '2024-09-03 11:20:00', 'Gift',   155), -- Usuario 58 regala Slay the Spire
(12, '2024-09-03 18:10:00', 'Compra', 156), -- Usuario 12 compra Control
(45, '2024-09-04 14:00:00', 'Compra', 157), -- Usuario 45 compra Baldur's Gate 3
(79, '2024-09-04 19:30:00', 'Compra', 158), -- Usuario 79 compra EA Sports FC 24
(36, '2024-09-05 10:10:00', 'Compra', 159), -- Usuario 36 compra Lies of P
(9,  '2024-09-05 21:00:00', 'Compra', 160), -- Usuario 9 compra The Witcher 3
(33, '2024-09-06 08:55:00', 'Compra', 161), -- Usuario 33 compra Hades
(48, '2024-09-06 13:25:00', 'Devolución',162), -- Usuario 48 devuelve Sea of Thieves
(92, '2024-09-07 11:45:00', 'Compra', 163), -- Usuario 92 compra Elden Ring
(18, '2024-09-07 15:35:00', 'Compra', 164), -- Usuario 18 compra Rocket League
(73, '2024-09-08 09:05:00', 'Compra', 165), -- Usuario 73 compra Mortal Kombat 1
(60, '2024-09-08 17:20:00', 'Recarga',166), -- Usuario 60 recarga saldo
(14, '2024-09-09 10:50:00', 'Compra', 167), -- Usuario 14 compra Red Dead Redemption 2
(31, '2024-09-09 18:00:00', 'Compra', 168), -- Usuario 31 compra Palworld
(25, '2024-09-10 12:15:00', 'Compra', 169), -- Usuario 25 compra The Sims 3
(71, '2024-09-10 19:10:00', 'Compra', 170), -- Usuario 71 compra DOOM Eternal
(5,  '2024-09-11 11:25:00', 'Compra', 171), -- Usuario 5 compra Dark Souls III
(22, '2024-09-11 16:55:00', 'Compra', 172), -- Usuario 22 compra Celeste
(38, '2024-09-12 09:40:00', 'Compra', 173), -- Usuario 38 compra Forza Horizon 5
(53, '2024-09-12 14:30:00', 'Compra', 174), -- Usuario 53 compra Divinity: Original Sin 2
(84, '2024-09-13 10:00:00', 'Compra', 175), -- Usuario 84 compra F1 23
(63, '2024-09-13 18:20:00', 'Compra', 176), -- Usuario 63 compra Monster Hunter: World
(2,  '2024-09-14 09:50:00', 'Compra', 177), -- Usuario 2 compra Stardew Valley
(40, '2024-09-14 20:15:00', 'Compra', 178), -- Usuario 40 compra Microsoft Flight Simulator
(95, '2024-09-15 11:05:00', 'Compra', 179), -- Usuario 95 compra Undertale
(86, '2024-09-15 15:45:00', 'Compra', 180), -- Usuario 86 compra Civilization VI
(13, '2024-09-16 10:30:00', 'Compra', 181), -- Usuario 13 compra DOOM (2016)
(52, '2024-09-16 13:55:00', 'Compra', 182), -- Usuario 52 compra Hades (segunda copia como regalo)
(29, '2024-09-17 09:00:00', 'Gift',   183), -- Usuario 29 regala Persona 5 Royal
(76, '2024-09-17 19:25:00', 'Compra', 184), -- Usuario 76 compra Returnal
(11, '2024-09-18 12:40:00', 'Compra', 185), -- Usuario 11 compra Mass Effect Legendary Edition
(50, '2024-09-18 18:35:00', 'Compra', 186), -- Usuario 50 compra It Takes Two
(24, '2024-09-19 10:20:00', 'Compra', 187), -- Usuario 24 compra Skyrim
(41, '2024-09-19 14:15:00', 'Compra', 188), -- Usuario 41 compra Alan Wake 2
(27, '2024-09-20 09:10:00', 'Compra', 189), -- Usuario 27 compra Hollow Knight
(62, '2024-09-20 16:30:00', 'Compra', 190), -- Usuario 62 compra Starfield
(35, '2024-09-21 11:00:00', 'Compra', 191), -- Usuario 35 compra Street Fighter 6
(44, '2024-09-21 17:50:00', 'Compra', 192), -- Usuario 44 compra Palworld (para amigo)
(98, '2024-09-22 08:45:00', 'Compra', 193), -- Usuario 98 compra God of War (2018)
(7,  '2024-09-22 21:10:00', 'Devolución',194), -- Usuario 7 devuelve Phasmophobia
(91, '2024-09-23 10:05:00', 'Compra', 195), -- Usuario 91 compra Guardians of the Galaxy
(57, '2024-09-23 15:55:00', 'Compra', 196), -- Usuario 57 compra Apex Legends (pack)
(68, '2024-09-24 12:10:00', 'Recarga',197), -- Usuario 68 recarga saldo
(16, '2024-09-24 18:40:00', 'Compra', 198), -- Usuario 16 compra Cuphead
(100,'2024-09-25 13:30:00', 'Compra', 199), -- Usuario 100 compra Persona 5 Royal (edición distinta)
(32, '2024-09-25 20:05:00', 'Compra', 200); -- Usuario 32 compra Satisfactory
GO

USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(12, '2024-11-01 10:05:00', 'Compra', 12),
(35, '2024-11-01 14:20:00', 'Compra', 35),
(77, '2024-11-02 09:45:00', 'Compra', 77),
(4,  '2024-11-02 16:10:00', 'Compra', 4),
(58, '2024-11-03 11:30:00', 'Compra', 58),
(21, '2024-11-03 18:00:00', 'Compra', 21),
(90, '2024-11-04 10:00:00', 'Compra', 90),
(16, '2024-11-04 12:40:00', 'Compra', 16),
(43, '2024-11-05 15:15:00', 'Compra', 43),
(69, '2024-11-05 19:50:00', 'Compra', 69),
(7,  '2024-11-06 09:00:00', 'Compra', 7),
(28, '2024-11-06 13:25:00', 'Compra', 28),
(51, '2024-11-07 17:05:00', 'Compra', 51),
(3,  '2024-11-07 20:30:00', 'Compra', 3),
(66, '2024-11-08 08:55:00', 'Compra', 66),
(24, '2024-11-08 11:40:00', 'Compra', 24),
(81, '2024-11-09 16:35:00', 'Compra', 81),
(19, '2024-11-09 18:45:00', 'Compra', 19),
(55, '2024-11-10 10:10:00', 'Compra', 55),
(34, '2024-11-10 14:50:00', 'Compra', 34),
(73, '2024-11-11 09:25:00', 'Compra', 73),
(10, '2024-11-11 12:15:00', 'Compra', 10),
(46, '2024-11-12 13:30:00', 'Compra', 46),
(98, '2024-11-12 19:05:00', 'Compra', 98),
(62, '2024-11-13 11:20:00', 'Compra', 62),
(27, '2024-11-13 15:10:00', 'Compra', 27),
(39, '2024-11-14 09:40:00', 'Compra', 39),
(84, '2024-11-14 18:25:00', 'Compra', 84),
(1,  '2024-11-15 10:00:00', 'Compra', 1),
(93, '2024-11-15 21:15:00', 'Compra', 93),
(14, '2024-11-16 08:50:00', 'Compra', 14),
(48, '2024-11-16 13:05:00', 'Compra', 48),
(76, '2024-11-17 16:45:00', 'Compra', 76),
(23, '2024-11-17 19:30:00', 'Compra', 23),
(57, '2024-11-18 09:05:00', 'Compra', 57),
(32, '2024-11-18 11:55:00', 'Compra', 32),
(71, '2024-11-19 14:35:00', 'Compra', 71),
(6,  '2024-11-19 20:20:00', 'Compra', 6),
(41, '2024-11-20 10:25:00', 'Compra', 41),
(88, '2024-11-20 17:00:00', 'Compra', 88),
(17, '2024-11-21 12:10:00', 'Compra', 17),
(64, '2024-11-21 18:40:00', 'Compra', 64),
(9,  '2024-11-22 09:35:00', 'Compra', 9),
(52, '2024-11-22 15:55:00', 'Compra', 52),
(79, '2024-11-23 11:45:00', 'Compra', 79),
(20, '2024-11-23 19:05:00', 'Compra', 20),
(36, '2024-11-24 10:50:00', 'Compra', 36),
(85, '2024-11-24 16:15:00', 'Compra', 85),
(100,'2024-11-25 13:30:00', 'Compra', 100),
(29, '2024-11-25 18:55:00', 'Compra', 29);
GO

USE EvolutionDB;
GO

USE EvolutionDB;
GO

USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(12, '2025-02-01 09:15:00', 'Compra', 112),
(44, '2025-02-01 12:10:00', 'Compra', 144),
(86, '2025-02-01 18:40:00', 'Compra', 186),
(5,  '2025-02-02 10:20:00', 'Compra', 105),
(27, '2025-02-02 13:35:00', 'Compra', 127),
(73, '2025-02-02 19:25:00', 'Compra', 173),
(9,  '2025-02-03 09:05:00', 'Compra', 109),
(41, '2025-02-03 11:45:00', 'Compra', 141),
(88, '2025-02-03 16:55:00', 'Compra', 188),
(16, '2025-02-04 10:00:00', 'Compra', 116),
(65, '2025-02-04 14:10:00', 'Compra', 165),
(91, '2025-02-04 20:00:00', 'Compra', 191),
(3,  '2025-02-05 09:35:00', 'Compra', 103),
(58, '2025-02-05 12:50:00', 'Compra', 158),
(80, '2025-02-05 17:30:00', 'Compra', 180),
(22, '2025-02-06 10:45:00', 'Compra', 122),
(49, '2025-02-06 13:20:00', 'Compra', 149),
(76, '2025-02-06 19:15:00', 'Compra', 176),
(11, '2025-02-07 09:25:00', 'Compra', 111),
(36, '2025-02-07 12:05:00', 'Compra', 136),
(84, '2025-02-07 18:25:00', 'Compra', 184),
(7,  '2025-02-08 10:15:00', 'Compra', 107),
(32, '2025-02-08 13:55:00', 'Compra', 132),
(70, '2025-02-08 20:10:00', 'Compra', 170),
(19, '2025-02-09 10:40:00', 'Compra', 119),
(54, '2025-02-09 15:00:00', 'Compra', 154),
(93, '2025-02-09 19:45:00', 'Compra', 193),
(1,  '2025-02-10 09:00:00', 'Compra', 101),
(43, '2025-02-10 12:35:00', 'Compra', 143),
(89, '2025-02-10 18:05:00', 'Compra', 189),
(13, '2025-02-11 09:30:00', 'Compra', 113),
(60, '2025-02-11 11:50:00', 'Compra', 160),
(82, '2025-02-11 17:40:00', 'Compra', 182),
(24, '2025-02-12 10:25:00', 'Compra', 124),
(56, '2025-02-12 14:15:00', 'Compra', 156),
(97, '2025-02-12 19:20:00', 'Compra', 197),
(15, '2025-02-13 09:05:00', 'Compra', 115),
(47, '2025-02-13 12:45:00', 'Compra', 147),
(75, '2025-02-13 18:55:00', 'Compra', 175),
(6,  '2025-02-14 10:35:00', 'Compra', 106),
(40, '2025-02-14 13:25:00', 'Compra', 140),
(87, '2025-02-14 20:00:00', 'Compra', 187),
(20, '2025-02-15 10:50:00', 'Compra', 120),
(53, '2025-02-15 14:05:00', 'Compra', 153),
(79, '2025-02-15 19:30:00', 'Compra', 179),
(10, '2025-02-16 09:20:00', 'Compra', 110),
(35, '2025-02-16 12:40:00', 'Compra', 135),
(63, '2025-02-16 18:35:00', 'Compra', 163),
(14, '2025-02-17 09:45:00', 'Compra', 114),
(67, '2025-02-17 13:15:00', 'Compra', 167);
GO

USE EvolutionDB;
GO
USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(12, '2024-12-01 09:10:00', 'Compra', 87),
(45, '2024-12-01 12:40:00', 'Compra', 145),
(78, '2024-12-01 18:20:00', 'Compra', 62),
(6,  '2024-12-02 10:05:00', 'Compra', 6),
(33, '2024-12-02 15:30:00', 'Compra', 133),
(90, '2024-12-02 19:50:00', 'Compra', 90),
(21, '2024-12-03 08:55:00', 'Compra', 121),
(57, '2024-12-03 11:25:00', 'Compra', 57),
(14, '2024-12-03 16:45:00', 'Compra', 114),
(69, '2024-12-03 20:10:00', 'Compra', 169),
(3,  '2024-12-04 09:00:00', 'Compra', 103),
(51, '2024-12-04 13:35:00', 'Compra', 151),
(28, '2024-12-04 17:15:00', 'Compra', 28),
(76, '2024-12-04 21:05:00', 'Compra', 176),
(10, '2024-12-05 10:20:00', 'Compra', 110),
(42, '2024-12-05 14:55:00', 'Compra', 142),
(85, '2024-12-05 19:40:00', 'Compra', 85),
(19, '2024-12-06 09:30:00', 'Compra', 119),
(63, '2024-12-06 12:15:00', 'Compra', 163),
(37, '2024-12-06 18:50:00', 'Compra', 137),
(95, '2024-12-07 11:10:00', 'Compra', 195),
(8,  '2024-12-07 13:25:00', 'Compra', 108),
(60, '2024-12-07 16:35:00', 'Compra', 160),
(24, '2024-12-07 20:45:00', 'Compra', 124),
(71, '2024-12-08 09:05:00', 'Compra', 171),
(5,  '2024-12-08 12:50:00', 'Compra', 105),
(48, '2024-12-08 17:20:00', 'Compra', 148),
(82, '2024-12-08 19:55:00', 'Compra', 182),
(16, '2024-12-09 10:15:00', 'Compra', 116),
(54, '2024-12-09 14:05:00', 'Compra', 154),
(99, '2024-12-09 18:25:00', 'Compra', 199),
(31, '2024-12-10 09:40:00', 'Compra', 131),
(67, '2024-12-10 11:55:00', 'Compra', 167),
(2,  '2024-12-10 15:35:00', 'Compra', 102),
(40, '2024-12-10 20:00:00', 'Compra', 140),
(88, '2024-12-11 08:50:00', 'Compra', 188),
(23, '2024-12-11 12:20:00', 'Compra', 123),
(72, '2024-12-11 16:10:00', 'Compra', 172),
(13, '2024-12-11 19:30:00', 'Compra', 113),
(59, '2024-12-12 10:25:00', 'Compra', 159),
(36, '2024-12-12 13:45:00', 'Compra', 136),
(80, '2024-12-12 18:35:00', 'Compra', 180),
(26, '2024-12-13 09:15:00', 'Compra', 126),
(50, '2024-12-13 12:05:00', 'Compra', 150),
(91, '2024-12-13 17:55:00', 'Compra', 191),
(7,  '2024-12-13 20:25:00', 'Compra', 107),
(64, '2024-12-14 09:05:00', 'Compra', 164),
(46, '2024-12-14 11:50:00', 'Compra', 146),
(97, '2024-12-14 16:45:00', 'Compra', 197),
(32, '2024-12-14 19:35:00', 'Compra', 132);
GO


INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(18, '2025-01-02 10:10:00', 'Compra', 118),
(41, '2025-01-02 13:20:00', 'Compra', 141),
(74, '2025-01-02 19:40:00', 'Compra', 174),
(9,  '2025-01-03 09:00:00', 'Compra', 109),
(52, '2025-01-03 12:35:00', 'Compra', 152),
(86, '2025-01-03 15:55:00', 'Compra', 186),
(15, '2025-01-04 11:15:00', 'Compra', 115),
(69, '2025-01-04 14:05:00', 'Compra', 169),
(28, '2025-01-04 18:25:00', 'Compra', 128),
(60, '2025-01-05 09:45:00', 'Compra', 160),
(3,  '2025-01-05 11:55:00', 'Compra', 103),
(57, '2025-01-05 16:30:00', 'Compra', 157),
(92, '2025-01-05 20:15:00', 'Compra', 192),
(12, '2025-01-06 10:25:00', 'Compra', 112),
(37, '2025-01-06 13:10:00', 'Compra', 137),
(81, '2025-01-06 18:50:00', 'Compra', 181),
(24, '2025-01-07 09:05:00', 'Compra', 124),
(66, '2025-01-07 12:45:00', 'Compra', 166),
(99, '2025-01-07 19:30:00', 'Compra', 199),
(6,  '2025-01-08 10:40:00', 'Compra', 106),
(45, '2025-01-08 15:05:00', 'Compra', 145),
(70, '2025-01-08 19:55:00', 'Compra', 170),
(22, '2025-01-09 09:25:00', 'Compra', 122),
(54, '2025-01-09 12:15:00', 'Compra', 154),
(88, '2025-01-09 17:05:00', 'Compra', 188),
(10, '2025-01-10 09:35:00', 'Compra', 110),
(63, '2025-01-10 12:25:00', 'Compra', 163),
(31, '2025-01-10 18:00:00', 'Compra', 131),
(76, '2025-01-11 10:10:00', 'Compra', 176),
(14, '2025-01-11 13:50:00', 'Compra', 114),
(50, '2025-01-11 19:20:00', 'Compra', 150),
(97, '2025-01-12 09:00:00', 'Compra', 197),
(26, '2025-01-12 11:40:00', 'Compra', 126),
(58, '2025-01-12 16:15:00', 'Compra', 158),
(83, '2025-01-12 20:35:00', 'Compra', 183),
(1,  '2025-01-13 10:30:00', 'Compra', 101),
(39, '2025-01-13 13:55:00', 'Compra', 139),
(72, '2025-01-13 18:05:00', 'Compra', 172),
(13, '2025-01-14 09:20:00', 'Compra', 113),
(46, '2025-01-14 12:50:00', 'Compra', 146),
(90, '2025-01-14 19:45:00', 'Compra', 190),
(20, '2025-01-15 09:15:00', 'Compra', 120),
(42, '2025-01-15 12:35:00', 'Compra', 142),
(79, '2025-01-15 17:25:00', 'Compra', 179),
(8,  '2025-01-16 10:05:00', 'Compra', 108),
(34, '2025-01-16 13:30:00', 'Compra', 134),
(62, '2025-01-16 19:10:00', 'Compra', 162),
(17, '2025-01-17 10:55:00', 'Compra', 117),
(55, '2025-01-17 14:45:00', 'Compra', 155),
(98, '2025-01-17 18:35:00', 'Compra', 198);
GO


USE EvolutionDB;
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(23, '2025-03-01 09:10:00', 'Compra', 123),
(52, '2025-03-01 12:20:00', 'Compra', 152),
(96, '2025-03-01 19:40:00', 'Compra', 196),
(8,  '2025-03-02 10:05:00', 'Compra', 108),
(31, '2025-03-02 13:35:00', 'Compra', 131),
(71, '2025-03-02 18:55:00', 'Compra', 171),
(4,  '2025-03-03 09:25:00', 'Compra', 104),
(59, '2025-03-03 12:15:00', 'Compra', 159),
(83, '2025-03-03 17:05:00', 'Compra', 183),
(18, '2025-03-04 10:40:00', 'Compra', 118),
(45, '2025-03-04 14:20:00', 'Compra', 145),
(90, '2025-03-04 20:10:00', 'Compra', 190),
(2,  '2025-03-05 09:00:00', 'Compra', 102),
(55, '2025-03-05 11:45:00', 'Compra', 155),
(77, '2025-03-05 19:30:00', 'Compra', 177),
(12, '2025-03-06 10:35:00', 'Compra', 112),
(42, '2025-03-06 15:10:00', 'Compra', 142),
(88, '2025-03-06 19:55:00', 'Compra', 188),
(6,  '2025-03-07 09:15:00', 'Compra', 106),
(36, '2025-03-07 12:05:00', 'Compra', 136),
(81, '2025-03-07 18:45:00', 'Compra', 181),
(20, '2025-03-08 09:50:00', 'Compra', 120),
(48, '2025-03-08 13:30:00', 'Compra', 148),
(95, '2025-03-08 19:25:00', 'Compra', 195),
(10, '2025-03-09 09:30:00', 'Compra', 110),
(33, '2025-03-09 12:50:00', 'Compra', 133),
(70, '2025-03-09 17:20:00', 'Compra', 170),
(14, '2025-03-10 09:40:00', 'Compra', 114),
(51, '2025-03-10 12:25:00', 'Compra', 151),
(86, '2025-03-10 18:15:00', 'Compra', 186),
(16, '2025-03-11 10:00:00', 'Compra', 116),
(41, '2025-03-11 13:55:00', 'Compra', 141),
(79, '2025-03-11 20:05:00', 'Compra', 179),
(1,  '2025-03-12 09:05:00', 'Compra', 101),
(38, '2025-03-12 11:35:00', 'Compra', 138),
(73, '2025-03-12 19:05:00', 'Compra', 173),
(13, '2025-03-13 10:15:00', 'Compra', 113),
(57, '2025-03-13 14:45:00', 'Compra', 157),
(92, '2025-03-13 18:50:00', 'Compra', 192),
(5,  '2025-03-14 09:25:00', 'Compra', 105),
(32, '2025-03-14 12:10:00', 'Compra', 132),
(68, '2025-03-14 16:55:00', 'Compra', 168),
(11, '2025-03-15 09:35:00', 'Compra', 111),
(47, '2025-03-15 13:20:00', 'Compra', 147),
(84, '2025-03-15 19:40:00', 'Compra', 184),
(7,  '2025-03-16 10:20:00', 'Compra', 107),
(29, '2025-03-16 12:55:00', 'Compra', 129),
(64, '2025-03-16 18:35:00', 'Compra', 164),
(15, '2025-03-17 10:45:00', 'Compra', 115),
(53, '2025-03-17 14:30:00', 'Compra', 153);
GO
USE EvolutionDB
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 21: 25 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(98, '2025-03-18 10:00:00', 'Compra', 98),
(74, '2025-03-18 14:30:00', 'Compra', 74),
(22, '2025-03-19 09:15:00', 'Recarga', 22),
(51, '2025-03-20 10:00:00', 'Compra', 81),
(52, '2025-03-20 15:30:00', 'Compra', 82),
(53, '2025-03-21 08:00:00', 'Compra', 83),
(54, '2025-03-21 12:45:00', 'Compra', 84),
(55, '2025-03-22 17:00:00', 'Compra', 85),
(56, '2025-03-23 10:20:00', 'Compra', 86),
(57, '2025-03-24 09:00:00', 'Devolucion', 87),
(58, '2025-03-24 11:10:00', 'Compra', 88),
(59, '2025-03-25 14:00:00', 'Compra', 89),
(60, '2025-03-26 16:30:00', 'Compra', 90),
(61, '2025-03-27 10:00:00', 'Gift', 91),
(62, '2025-03-28 09:30:00', 'Compra', 92),
(63, '2025-03-29 11:20:00', 'Compra', 93),
(64, '2025-03-30 13:40:00', 'Compra', 94),
(65, '2025-03-31 15:00:00', 'Compra', 95),
(66, '2025-04-01 10:10:00', 'Compra', 96),
(3, '2025-04-01 12:00:00', 'Compra', 101), -- Usuario 3 usando su tarjeta ID 101
(3, '2025-04-02 09:00:00', 'Compra', 102), -- Usuario 3 usando su tarjeta ID 102
(7, '2025-04-02 14:30:00', 'Recarga', 104), -- Usuario 7 usando su tarjeta ID 104
(15, '2025-04-03 10:00:00', 'Compra', 15),  -- Usuario 15 usando su tarjeta ID 15
(15, '2025-04-03 17:45:00', 'Compra', 111), -- Usuario 15 usando su tarjeta ID 111
(100, '2025-04-04 09:00:00', 'Compra', 100);

GO

PRINT '--- Lote 21 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 22: 25 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(67, '2025-03-18 09:15:00', 'Compra', 67),
(88, '2025-03-18 11:00:00', 'Compra', 88),
(1, '2025-03-18 15:30:00', 'Compra', 1),
(10, '2025-03-19 10:00:00', 'Compra', 10),
(25, '2025-03-19 14:20:00', 'Recarga', 25),
(100, '2025-03-20 09:00:00', 'Compra', 100),
(50, '2025-03-20 12:10:00', 'Compra', 50),
(42, '2025-03-21 08:30:00', 'Compra', 42),
(77, '2025-03-21 11:45:00', 'Compra', 77),
(3, '2025-03-22 10:00:00', 'Compra', 106), -- Usuario 3, Metodo 106
(7, '2025-03-22 16:15:00', 'Compra', 109), -- Usuario 7, Metodo 109
(15, '2025-03-23 09:40:00', 'Compra', 111), -- Usuario 15, Metodo 111
(99, '2025-03-23 13:00:00', 'Compra', 99),
(81, '2025-03-24 10:25:00', 'Compra', 81),
(12, '2025-03-24 15:00:00', 'Compra', 107), -- Usuario 12, Metodo 107
(19, '2025-03-25 09:00:00', 'Devolucion', 19),
(30, '2025-03-25 11:10:00', 'Compra', 30),
(45, '2025-03-26 14:00:00', 'Compra', 45),
(61, '2025-03-27 10:50:00', 'Compra', 61),
(72, '2025-03-28 09:20:00', 'Gift', 72),
(83, '2025-03-28 12:00:00', 'Compra', 83),
(94, '2025-03-29 17:30:00', 'Compra', 94),
(55, '2025-03-30 10:00:00', 'Recarga', 55),
(2, '2025-03-31 09:10:00', 'Compra', 2),
(28, '2025-03-31 11:00:00', 'Compra', 28);
GO

PRINT '--- Lote 22 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 23: 25 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(67, '2025-04-01 09:10:00', 'Compra', 67),
(88, '2025-04-01 11:30:00', 'Compra', 88),
(1, '2025-04-01 16:00:00', 'Compra', 6), -- Usuario 1, Metodo 6
(10, '2025-04-02 10:00:00', 'Compra', 108), -- Usuario 10, Metodo 108
(25, '2025-04-02 14:00:00', 'Recarga', 125), -- Usuario 25, Metodo 125
(100, '2025-04-03 09:00:00', 'Compra', 100),
(50, '2025-04-03 12:00:00', 'Compra', 150), -- Usuario 50, Metodo 150
(42, '2025-04-04 08:00:00', 'Compra', 142), -- Usuario 42, Metodo 142
(77, '2025-04-04 11:00:00', 'Compra', 77),
(3, '2025-04-05 10:00:00', 'Compra', 101), -- Usuario 3, Metodo 101
(7, '2025-04-05 16:00:00', 'Compra', 104), -- Usuario 7, Metodo 104
(15, '2025-04-06 09:00:00', 'Compra', 110), -- Usuario 15, Metodo 110
(99, '2025-04-06 13:00:00', 'Compra', 99),
(81, '2025-04-07 10:00:00', 'Compra', 81),
(12, '2025-04-07 15:00:00', 'Compra', 107), -- Usuario 12, Metodo 107
(19, '2025-04-08 09:00:00', 'Devolucion', 19),
(30, '2025-04-08 11:00:00', 'Compra', 130), -- Usuario 30, Metodo 130
(45, '2025-04-09 14:00:00', 'Compra', 145), -- Usuario 45, Metodo 145
(61, '2025-04-10 10:00:00', 'Compra', 61),
(72, '2025-04-11 09:00:00', 'Gift', 72),
(83, '2025-04-11 12:00:00', 'Compra', 83),
(94, '2025-04-12 17:00:00', 'Compra', 94),
(55, '2025-04-13 10:00:00', 'Recarga', 55),
(2, '2025-04-14 09:00:00', 'Compra', 2),
(49, '2025-04-14 15:30:00', 'Compra', 49);
GO

PRINT '--- Lote 23 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 24: 25 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(68, '2025-04-15 09:10:00', 'Compra', 68),
(89, '2025-04-15 11:35:00', 'Compra', 89),
(3, '2025-04-15 15:00:00', 'Compra', 101), -- Usuario 3, Metodo 101
(11, '2025-04-16 10:00:00', 'Compra', 11),
(26, '2025-04-16 14:20:00', 'Recarga', 26),
(90, '2025-04-17 09:05:00', 'Compra', 90),
(51, '2025-04-17 12:30:00', 'Compra', 51),
(43, '2025-04-18 08:00:00', 'Compra', 43),
(78, '2025-04-18 11:15:00', 'Compra', 78),
(4, '2025-04-19 10:00:00', 'Compra', 103), -- Usuario 4, Metodo 103
(7, '2025-04-19 16:45:00', 'Compra', 105), -- Usuario 7, Metodo 105
(16, '2025-04-20 09:00:00', 'Compra', 16),
(91, '2025-04-20 13:00:00', 'Compra', 91),
(82, '2025-04-21 10:10:00', 'Compra', 82),
(13, '2025-04-21 15:25:00', 'Compra', 13),
(20, '2025-04-22 09:00:00', 'Devolucion', 20),
(31, '2025-04-22 11:30:00', 'Compra', 31),
(46, '2025-04-23 14:00:00', 'Compra', 46),
(62, '2025-04-24 10:00:00', 'Compra', 62),
(73, '2025-04-25 09:00:00', 'Gift', 73),
(84, '2025-04-25 12:15:00', 'Compra', 84),
(95, '2025-04-26 17:30:00', 'Compra', 95),
(56, '2025-04-27 10:00:00', 'Recarga', 56),
(5, '2025-04-28 09:00:00', 'Compra', 8), -- Usuario 5, Metodo 8
(66, '2025-04-28 15:30:00', 'Compra', 66);
GO

PRINT '--- Lote 24 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 25: 25 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(69, '2025-04-29 09:15:00', 'Compra', 69),
(90, '2025-04-29 11:00:00', 'Compra', 90),
(4, '2025-04-29 14:30:00', 'Compra', 103), -- Usuario 4, Metodo 103
(12, '2025-04-30 10:00:00', 'Compra', 12),
(27, '2025-04-30 14:20:00', 'Recarga', 27),
(91, '2025-05-01 09:00:00', 'Compra', 91),
(52, '2025-05-01 12:45:00', 'Compra', 52),
(44, '2025-05-02 08:30:00', 'Compra', 44),
(79, '2025-05-02 11:10:00', 'Compra', 79),
(5, '2025-05-03 10:00:00', 'Compra', 104), -- Usuario 5, Metodo 104
(8, '2025-05-03 16:00:00', 'Compra', 105), -- Usuario 8, Metodo 105
(17, '2025-05-04 09:00:00', 'Compra', 17),
(92, '2025-05-04 13:00:00', 'Compra', 92),
(83, '2025-05-05 10:00:00', 'Compra', 83),
(14, '2025-05-05 15:00:00', 'Compra', 14),
(21, '2025-05-06 09:00:00', 'Devolucion', 21),
(32, '2025-05-06 11:00:00', 'Compra', 32),
(47, '2025-05-07 14:00:00', 'Compra', 47),
(63, '2025-05-08 10:00:00', 'Compra', 63),
(74, '2025-05-09 09:00:00', 'Gift', 74),
(85, '2025-05-09 12:00:00', 'Compra', 85),
(96, '2025-05-10 17:00:00', 'Compra', 96),
(57, '2025-05-11 10:00:00', 'Recarga', 57),
(9, '2025-05-12 09:00:00', 'Compra', 9),
(68, '2025-05-12 15:30:00', 'Compra', 68);
GO

PRINT '--- Lote 25 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 26: 30 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(70, '2025-05-13 09:10:00', 'Compra', 70),
(91, '2025-05-13 11:05:00', 'Compra', 91),
(3, '2025-05-13 14:30:00', 'Compra', 101), -- Usuario 3, Metodo 101
(13, '2025-05-14 10:00:00', 'Compra', 13),
(28, '2025-05-14 14:20:00', 'Recarga', 28),
(92, '2025-05-15 09:00:00', 'Compra', 92),
(53, '2025-05-15 12:45:00', 'Compra', 53),
(45, '2025-05-16 08:30:00', 'Compra', 45),
(80, '2025-05-16 11:10:00', 'Compra', 80),
(7, '2025-05-17 10:00:00', 'Compra', 104), -- Usuario 7, Metodo 104
(8, '2025-05-17 16:00:00', 'Compra', 106), -- Usuario 8, Metodo 106
(18, '2025-05-18 09:00:00', 'Compra', 18),
(93, '2025-05-18 13:00:00', 'Compra', 93),
(84, '2025-05-19 10:00:00', 'Compra', 84),
(15, '2025-05-19 15:00:00', 'Compra', 15),
(22, '2025-05-20 09:00:00', 'Devolucion', 22),
(33, '2025-05-20 11:00:00', 'Compra', 33),
(48, '2025-05-21 14:00:00', 'Compra', 48),
(64, '2025-05-22 10:00:00', 'Compra', 64),
(75, '2025-05-23 09:00:00', 'Gift', 75),
(86, '2025-05-23 12:00:00', 'Compra', 86),
(97, '2025-05-24 17:00:00', 'Compra', 97),
(58, '2025-05-25 10:00:00', 'Recarga', 58),
(10, '2025-05-26 09:00:00', 'Compra', 10),
(69, '2025-05-26 15:30:00', 'Compra', 69),
(71, '2025-05-27 09:15:00', 'Compra', 71),
(94, '2025-05-27 11:30:00', 'Compra', 94),
(4, '2025-05-27 14:00:00', 'Compra', 103), -- Usuario 4, Metodo 103
(14, '2025-05-28 10:00:00', 'Compra', 14),
(29, '2025-05-28 14:20:00', 'Recarga', 29);
GO

PRINT '--- Lote 26 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 27: 30 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(93, '2025-05-29 09:00:00', 'Compra', 93),
(54, '2025-05-29 12:45:00', 'Compra', 54),
(46, '2025-05-30 08:30:00', 'Compra', 46),
(81, '2025-05-30 11:10:00', 'Compra', 81),
(7, '2025-05-31 10:00:00', 'Compra', 104), -- Usuario 7, Metodo 104
(9, '2025-05-31 16:00:00', 'Compra', 108), -- Usuario 9, Metodo 108
(19, '2025-06-01 09:00:00', 'Compra', 19),
(94, '2025-06-01 13:00:00', 'Compra', 94),
(85, '2025-06-02 10:00:00', 'Compra', 85),
(16, '2025-06-02 15:00:00', 'Compra', 16),
(23, '2025-06-03 09:00:00', 'Devolucion', 23),
(34, '2025-06-03 11:00:00', 'Compra', 34),
(49, '2025-06-04 14:00:00', 'Compra', 49),
(65, '2025-06-05 10:00:00', 'Compra', 65),
(76, '2025-06-06 09:00:00', 'Gift', 76),
(87, '2025-06-06 12:00:00', 'Compra', 87),
(98, '2025-06-07 17:00:00', 'Compra', 98),
(59, '2025-06-08 10:00:00', 'Recarga', 59),
(11, '2025-06-09 09:00:00', 'Compra', 11),
(70, '2025-06-09 15:30:00', 'Compra', 70),
(72, '2025-06-10 09:15:00', 'Compra', 72),
(95, '2025-06-10 11:30:00', 'Compra', 95),
(5, '2025-06-10 14:00:00', 'Compra', 104), -- Usuario 5, Metodo 104
(15, '2025-06-11 10:00:00', 'Compra', 110), -- Usuario 15, Metodo 110
(30, '2025-06-11 14:20:00', 'Recarga', 30),
(96, '2025-06-12 09:00:00', 'Compra', 96),
(55, '2025-06-12 12:45:00', 'Compra', 55),
(47, '2025-06-13 08:30:00', 'Compra', 47),
(82, '2025-06-13 11:10:00', 'Compra', 82),
(8, '2025-06-14 10:00:00', 'Compra', 105); -- Usuario 8, Metodo 105
GO

PRINT '--- Lote 27 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 28: 30 Nuevas Transacciones ---'
GO

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(20, '2025-06-14 16:00:00', 'Compra', 20),
(95, '2025-06-15 09:00:00', 'Compra', 95),
(86, '2025-06-15 13:00:00', 'Compra', 86),
(17, '2025-06-16 10:00:00', 'Compra', 17),
(24, '2025-06-16 15:00:00', 'Compra', 24),
(35, '2025-06-17 09:00:00', 'Devolucion', 35),
(40, '2025-06-17 11:00:00', 'Compra', 40),
(50, '2025-06-18 14:00:00', 'Compra', 50),
(66, '2025-06-19 10:00:00', 'Compra', 66),
(77, '2025-06-20 09:00:00', 'Gift', 77),
(88, '2025-06-20 12:00:00', 'Compra', 88),
(99, '2025-06-21 17:00:00', 'Compra', 99),
(60, '2025-06-22 10:00:00', 'Recarga', 60),
(12, '2025-06-23 09:00:00', 'Compra', 12),
(71, '2025-06-23 15:30:00', 'Compra', 71),
(73, '2025-06-24 09:15:00', 'Compra', 73),
(96, '2025-06-24 11:30:00', 'Compra', 96),
(4, '2025-06-24 14:00:00', 'Compra', 103), -- Usuario 4, Metodo 103
(16, '2025-06-25 10:00:00', 'Compra', 112), -- Usuario 16, Metodo 112
(31, '2025-06-25 14:20:00', 'Recarga', 31),
(97, '2025-06-26 09:00:00', 'Compra', 97),
(56, '2025-06-26 12:45:00', 'Compra', 56),
(48, '2025-06-27 08:30:00', 'Compra', 48),
(83, '2025-06-27 11:10:00', 'Compra', 83),
(9, '2025-06-28 10:00:00', 'Compra', 108), -- Usuario 9, Metodo 108
(21, '2025-06-28 16:00:00', 'Compra', 21),
(98, '2025-06-29 09:00:00', 'Compra', 98),
(57, '2025-06-29 13:00:00', 'Compra', 57),
(87, '2025-06-30 10:00:00', 'Compra', 87),
(18, '2025-06-30 15:00:00', 'Compra', 113); -- Usuario 18, Metodo 113
GO

PRINT '--- Lote 28 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 1: 25 Detalles de Transacciones (7-31) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(7, 51, NULL, 51),   -- Trans 7 (Usuario 51) compra The Sims 4
(8, 52, NULL, 52),   -- Trans 8 (Usuario 52) compra Sea of Thieves
(9, 53, NULL, 53),   -- Trans 9 (Usuario 53) compra Flight Simulator
(10, 54, NULL, 54),  -- Trans 10 (Usuario 54) compra Valheim
(11, 55, NULL, 55),  -- Trans 11 (Usuario 55) compra Deep Rock Galactic
(12, 56, NULL, 56),  -- Trans 12 (Usuario 56) compra Nier: Automata
(13, 57, NULL, 57),  -- Trans 13 (Usuario 57) compra Ori
(14, 58, NULL, 58),  -- Trans 14 (Usuario 58) compra Subnautica
(15, 59, NULL, 59),  -- Trans 15 (Usuario 59) compra Outer Wilds
(16, 63, NULL, 63),  -- Trans 16 (Usuario 60) compra Skyrim
(17, 64, NULL, 64),  -- Trans 17 (Usuario 61) compra Fallout 4
(18, 65, NULL, 65),  -- Trans 18 (Usuario 62) compra Divinity: OS 2
(19, 66, NULL, 66),  -- Trans 19 (Usuario 63) compra Monster Hunter: World
(20, 67, NULL, 67),  -- Trans 20 (Usuario 64) compra Borderlands 3
(21, 68, NULL, 68),  -- Trans 21 (Usuario 65) compra AC Odyssey
(22, 69, NULL, 69),  -- Trans 22 (Usuario 66) compra AC Valhalla
(23, 70, NULL, 70),  -- Trans 23 (Usuario 67) compra Far Cry 5
(24, 71, NULL, 71),  -- Trans 24 (Usuario 68) compra Far Cry 6
(25, 72, NULL, 72),  -- Trans 25 (Usuario 69) compra Titanfall 2
(26, 74, NULL, 74),  -- Trans 26 (Usuario 70) compra Rainbow Six Siege
(27, 75, NULL, 75),  -- Trans 27 (Usuario 71) compra Slay the Spire
(28, 76, NULL, 76),  -- Trans 28 (Usuario 72) compra Dead Cells
(29, 77, NULL, 77),  -- Trans 29 (Usuario 73) compra Portal 2
(30, 78, NULL, 78),  -- Trans 30 (Usuario 74) compra Half-Life: Alyx
(31, 80, NULL, 80);  -- Trans 31 (Usuario 100) compra Terraria
GO

PRINT '--- Lote 1 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 2: 30 Detalles de Transacciones (32-61) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(32, 81, NULL, 81),   -- Trans 32 (Usuario 75) compra No Man's Sky
(33, 82, NULL, 82),   -- Trans 33 (Usuario 76) compra Garry's Mod
(34, 83, NULL, 83),   -- Trans 34 (Usuario 77) compra Vampire Survivors
(35, 84, NULL, 84),   -- Trans 35 (Usuario 78) compra F1 23
(36, 85, NULL, 85),   -- Trans 36 (Usuario 79) compra Civilization VI
(37, 86, NULL, 86),   -- Trans 37 (Usuario 80) compra XCOM 2
(38, 87, NULL, 87),   -- Trans 38 (Usuario 81) compra The Last of Us Part I
(39, 88, NULL, 88),   -- Trans 39 (Usuario 82) compra Demon's Souls Remake
(40, 89, NULL, 89),   -- Trans 40 (Usuario 83) compra Ratchet & Clank
(40, 90, NULL, 90),   -- Trans 40 (Usuario 83) TAMBIÉN compra Returnal
(41, 91, NULL, 91),   -- Trans 41 (Usuario 84) compra Guardians of the Galaxy
(42, 92, NULL, 92),   -- Trans 42 (Usuario 85) compra Hogwarts Legacy
(43, 93, NULL, 93),   -- Trans 43 (Usuario 86) compra EA Sports FC 24
(44, 94, NULL, 94),   -- Trans 44 (Usuario 87) compra NBA 2K24
(45, 95, NULL, 95),   -- Trans 45 (Usuario 88) compra Madden NFL 24
(46, 96, NULL, 96),   -- Trans 46 (Usuario 89) compra Dead by Daylight
(47, 97, NULL, 97),   -- Trans 47 (Usuario 90) compra Alien: Isolation
(48, 98, NULL, 98),   -- Trans 48 (Usuario 91) compra Metro Exodus
(49, 99, NULL, 99),   -- Trans 49 (Usuario 92) compra Days Gone
(50, 100, NULL, 100), -- Trans 50 (Usuario 93) compra Dying Light 2
(50, 170, NULL, 170), -- Trans 50 (Usuario 93) TAMBIÉN compra DLC Dying Light 2
(50, 10, NULL, 13),   -- Trans 50 (Usuario 93) TAMBIÉN compra RDR 2 (Prod 10, Precio 13)
(51, 101, NULL, 101), -- Trans 51 (Usuario 94) compra Mount & Blade II
(52, 102, NULL, 102), -- Trans 52 (Usuario 95) compra Total War: WH3
(53, 103, NULL, 103), -- Trans 53 (Usuario 96) compra Crusader Kings III
(54, 104, NULL, 104), -- Trans 54 (Usuario 97) compra Tekken 8
(55, 105, NULL, 105), -- Trans 55 (Usuario 98) compra Guilty Gear -Strive-
(56, 106, NULL, 106), -- Trans 56 (Usuario 99) compra Yakuza: Like a Dragon
(57, 107, NULL, 107), -- Trans 57 (Usuario 100) compra Dragon Quest XI S
(58, 108, NULL, 108); -- Trans 58 (Usuario 12) compra Undertale
GO

PRINT '--- Lote 2 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 3: 30 Detalles de Transacciones (59-88) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(59, 109, NULL, 112), -- Trans 59 (Usuario 59) compra Shovel Knight
(60, 63, NULL, 63),   -- Trans 60 (Usuario 60) compra Skyrim
(60, 132, NULL, 132), -- Trans 60 (Usuario 60) TAMBIÉN compra DLC Skyrim (Dawnguard)
(61, 64, NULL, 64),   -- Trans 61 (Usuario 61) compra Fallout 4
(62, 65, NULL, 65),   -- Trans 62 (Usuario 62) compra Divinity: OS 2
(63, 66, NULL, 66),   -- Trans 63 (Usuario 63) compra Monster Hunter: World
(64, 67, NULL, 67),   -- Trans 64 (Usuario 64) compra Borderlands 3
(65, 68, NULL, 68),   -- Trans 65 (Usuario 65) compra AC Odyssey
(66, 69, NULL, 69),   -- Trans 66 (Usuario 66) compra AC Valhalla
(67, 70, NULL, 70),   -- Trans 67 (Usuario 67) compra Far Cry 5
(68, 71, NULL, 71),   -- Trans 68 (Usuario 68) compra Far Cry 6
(69, 72, NULL, 72),   -- Trans 69 (Usuario 69) compra Titanfall 2
(70, 74, NULL, 74),   -- Trans 70 (Usuario 70) compra Rainbow Six Siege
(70, 80, NULL, 80),   -- Trans 70 (Usuario 70) TAMBIÉN compra Terraria
(71, 19, NULL, 22),   -- Trans 71 (Usuario 71) compra DOOM Eternal (Prod 19, Precio 22)
(72, 2, NULL, 2),    -- Trans 72 (Usuario 12) compra Stardew Valley (Prod 2, Precio 2)
(73, 3, NULL, 3),    -- Trans 73 (Usuario 9) compra The Witcher 3 (Prod 3, Precio 3)
(74, 5, NULL, 6),    -- Trans 74 (Usuario 33) compra Minecraft (Prod 5, Precio 6)
(75, 7, NULL, 7),    -- Trans 75 (Usuario 18) compra Baldur's Gate 3 (Prod 7, Precio 7)
(76, 8, NULL, 9),    -- Trans 76 (Usuario 8) compra Cities: Skylines (Prod 8, Precio 9)
(77, 10, NULL, 10),   -- Trans 77 (Usuario 55) regala Phasmophobia (Prod 10, Precio 10)
(78, 13, NULL, 13),   -- Trans 78 (Usuario 14) compra RDR 2 (Prod 13, Precio 13)
(79, 14, NULL, 14),   -- Trans 79 (Usuario 77) compra Elden Ring (Prod 14, Precio 14)
(80, 15, NULL, 15),   -- Trans 80 (Usuario 29) compra GTA V (Prod 15, Precio 15)
(81, 17, NULL, 17),   -- Trans 81 (Usuario 61) compra God of War (Prod 17, Precio 17)
(82, 18, NULL, 18),   -- Trans 82 (Usuario 44) compra GoW Ragnarök (Prod 18, Precio 18)
(83, 19, NULL, 19),   -- Trans 83 (Usuario 12) compra Spider-Man (Prod 19, Precio 19)
(84, 20, NULL, 20),   -- Trans 84 (Usuario 92) compra TLOU Part II (Prod 20, Precio 20)
(85, 21, NULL, 21),   -- Trans 85 (Usuario 13) compra DOOM (2016) (Prod 21, Precio 21)
(86, 22, NULL, 22);   -- Trans 86 (Usuario 71) compra DOOM Eternal (Prod 22, Precio 22)
GO

PRINT '--- Lote 3 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 4: 30 Detalles de Transacciones (89-118) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(87, 23, NULL, 25),   -- Trans 87 (Usuario 88) Devuelve RE Village (Prod 23, Precio 25)
(88, 26, NULL, 29),   -- Trans 88 (Usuario 10) Compra Sekiro
(89, 27, NULL, 30),   -- Trans 89 (Usuario 5) Compra Dark Souls III
(90, 29, NULL, 32),   -- Trans 90 (Usuario 22) Regala Celeste
(91, 58, NULL, 61),   -- Trans 91 (Usuario 80) Compra Cuphead
(92, 59, NULL, 62),   -- Trans 92 (Usuario 38) Compra Rocket League
(93, 30, NULL, 33),   -- Trans 93 (Usuario 100) Compra Persona 5 Royal
(94, 31, NULL, 34),   -- Trans 94 (Usuario 17) Compra Control
(95, 32, NULL, 35),   -- Trans 95 (Usuario 26) Compra Death Stranding
(96, 33, NULL, 36),   -- Trans 96 (Usuario 33) Compra FF VII Remake
(97, 34, NULL, 37),   -- Trans 97 (Usuario 4) Compra Helldivers 2
(98, 35, NULL, 38),   -- Trans 98 (Usuario 85) Compra Alan Wake 2
(99, 36, NULL, 39),   -- Trans 99 (Usuario 51) Compra Diablo IV
(100, 37, NULL, 40),  -- Trans 100 (Usuario 62) Compra Starfield
(101, 38, NULL, 41),  -- Trans 101 (Usuario 39) Compra Forza Horizon 5
(101, 181, NULL, 181),-- Trans 101 (Usuario 39) TAMBIÉN Compra DLC Forza (Hot Wheels)
(102, 39, NULL, 42),  -- Trans 102 (Usuario 19) Compra Jedi: Survivor
(103, 40, NULL, 43),  -- Trans 103 (Usuario 72) Compra Dead Space Remake
(104, 41, NULL, 44),  -- Trans 104 (Usuario 11) Compra Mass Effect LE
(105, 42, NULL, 45),  -- Trans 105 (Usuario 50) Compra It Takes Two
(106, 43, NULL, 46),  -- Trans 106 (Usuario 60) Compra Lethal Company
(107, 44, NULL, 47),  -- Trans 107 (Usuario 31) Compra Palworld
(108, 45, NULL, 48),  -- Trans 108 (Usuario 73) Compra Mortal Kombat 1
(109, 46, NULL, 49),  -- Trans 109 (Usuario 14) Compra Street Fighter 6
(110, 47, NULL, 50),  -- Trans 110 (Usuario 8) Compra Lies of P
(111, 48, NULL, 52),  -- Trans 111 (Usuario 42) Compra Sea of Thieves
(112, 49, NULL, 53),  -- Trans 112 (Usuario 59) Compra Flight Simulator
(113, 50, NULL, 54),  -- Trans 113 (Usuario 21) Compra Valheim
(114, 66, NULL, 69),  -- Trans 114 (Usuario 66) Compra AC Valhalla
(114, 160, NULL, 160);-- Trans 114 (Usuario 66) TAMBIÉN Compra DLC AC Valhalla (Wrath of Druids)
GO

PRINT '--- Lote 4 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 5: 30 Detalles de Transacciones (119-148) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(115, 5, NULL, 6),    -- Trans 115 (Usuario 4) Compra Minecraft
(116, 87, NULL, 90),  -- Trans 116 (Usuario 87) Compra The Last of Us Part I
(117, 72, NULL, 75),  -- Trans 117 (Usuario 58) Regala Slay the Spire
(118, 31, NULL, 34),  -- Trans 118 (Usuario 12) Compra Control
(119, 7, NULL, 7),    -- Trans 119 (Usuario 45) Compra Baldur's Gate 3
(120, 93, NULL, 96),  -- Trans 120 (Usuario 79) Compra EA Sports FC 24
(121, 47, NULL, 50),  -- Trans 121 (Usuario 36) Compra Lies of P
(122, 3, 1, 3),       -- Trans 122 (Usuario 9) Compra The Witcher 3 (¡CON DESCUENTO!)
(123, 28, NULL, 31),  -- Trans 123 (Usuario 33) Compra Hades
(124, 48, NULL, 52),  -- Trans 124 (Usuario 48) Devuelve Sea of Thieves
(125, 14, NULL, 14),  -- Trans 125 (Usuario 92) Compra Elden Ring
(126, 58, NULL, 61),  -- Trans 126 (Usuario 18) Compra Cuphead
(127, 45, NULL, 48),  -- Trans 127 (Usuario 73) Compra Mortal Kombat 1
(129, 13, NULL, 13),  -- Trans 129 (Usuario 14) Compra RDR 2
(130, 44, NULL, 47),  -- Trans 130 (Usuario 31) Compra Palworld
(131, 50, NULL, 54),  -- Trans 131 (Usuario 25) Compra Valheim
(132, 22, NULL, 22),  -- Trans 132 (Usuario 71) Compra DOOM Eternal
(133, 27, NULL, 30),  -- Trans 133 (Usuario 5) Compra Dark Souls III
(134, 29, NULL, 32),  -- Trans 134 (Usuario 22) Compra Celeste
(135, 38, NULL, 41),  -- Trans 135 (Usuario 38) Compra Forza Horizon 5
(136, 62, NULL, 65),  -- Trans 136 (Usuario 53) Compra Divinity: OS 2
(137, 84, NULL, 87),  -- Trans 137 (Usuario 84) Compra F1 23
(138, 63, NULL, 66),  -- Trans 138 (Usuario 63) Compra Monster Hunter: World
(139, 2, NULL, 2),    -- Trans 139 (Usuario 2) Compra Stardew Valley
(140, 49, NULL, 53),  -- Trans 140 (Usuario 40) Compra Flight Simulator
(141, 108, NULL, 111),-- Trans 141 (Usuario 95) Compra Undertale
(142, 85, NULL, 88),  -- Trans 142 (Usuario 86) Compra Civilization VI
(143, 21, NULL, 21),  -- Trans 143 (Usuario 13) Compra DOOM (2016)
(143, 10, NULL, 10);  -- Trans 143 (Usuario 13) TAMBIÉN Compra Phasmophobia
GO

PRINT '--- Lote 5 Finalizado ---'
GO
USE EvolutionDB
GO

PRINT '--- Iniciando Lote 5: 30 Detalles de Transacciones (119-148) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(115, 5, NULL, 6),    -- Trans 115 (Usuario 4) Compra Minecraft
(116, 87, NULL, 90),  -- Trans 116 (Usuario 87) Compra The Last of Us Part I
(117, 72, NULL, 75),  -- Trans 117 (Usuario 58) Regala Slay the Spire
(118, 31, NULL, 34),  -- Trans 118 (Usuario 12) Compra Control
(119, 7, NULL, 7),    -- Trans 119 (Usuario 45) Compra Baldur's Gate 3
(120, 93, NULL, 96),  -- Trans 120 (Usuario 79) Compra EA Sports FC 24
(121, 47, NULL, 50),  -- Trans 121 (Usuario 36) Compra Lies of P
(122, 3, 1, 3),       -- Trans 122 (Usuario 9) Compra The Witcher 3 (¡CON DESCUENTO!)
(123, 28, NULL, 31),  -- Trans 123 (Usuario 33) Compra Hades
(124, 48, NULL, 52),  -- Trans 124 (Usuario 48) Devuelve Sea of Thieves
(125, 14, NULL, 14),  -- Trans 125 (Usuario 92) Compra Elden Ring
(126, 58, NULL, 61),  -- Trans 126 (Usuario 18) Compra Cuphead
(127, 45, NULL, 48),  -- Trans 127 (Usuario 73) Compra Mortal Kombat 1
(129, 13, NULL, 13),  -- Trans 129 (Usuario 14) Compra RDR 2
(130, 44, NULL, 47),  -- Trans 130 (Usuario 31) Compra Palworld
(131, 50, NULL, 54),  -- Trans 131 (Usuario 25) Compra Valheim
(132, 22, NULL, 22),  -- Trans 132 (Usuario 71) Compra DOOM Eternal
(133, 27, NULL, 30),  -- Trans 133 (Usuario 5) Compra Dark Souls III
(134, 29, NULL, 32),  -- Trans 134 (Usuario 22) Compra Celeste
(135, 38, NULL, 41),  -- Trans 135 (Usuario 38) Compra Forza Horizon 5
(136, 62, NULL, 65),  -- Trans 136 (Usuario 53) Compra Divinity: OS 2
(137, 84, NULL, 87),  -- Trans 137 (Usuario 84) Compra F1 23
(138, 63, NULL, 66),  -- Trans 138 (Usuario 63) Compra Monster Hunter: World
(139, 2, NULL, 2),    -- Trans 139 (Usuario 2) Compra Stardew Valley
(140, 49, NULL, 53),  -- Trans 140 (Usuario 40) Compra Flight Simulator
(141, 108, NULL, 111),-- Trans 141 (Usuario 95) Compra Undertale
(142, 85, NULL, 88),  -- Trans 142 (Usuario 86) Compra Civilization VI
(143, 21, NULL, 21),  -- Trans 143 (Usuario 13) Compra DOOM (2016)
(143, 10, NULL, 10);  -- Trans 143 (Usuario 13) TAMBIÉN Compra Phasmophobia
GO

PRINT '--- Lote 5 Finalizado ---'
GO
USE EvolutionDB
GO


PRINT '--- Iniciando Lote 6: 30 Detalles de Transacciones (144-173) ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 5 (Re-intento): 30 Detalles de Transacciones (115-143) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(115, 5, NULL, 6),    -- Trans 115 (Usuario 4) Compra Minecraft
(116, 87, NULL, 90),  -- Trans 116 (Usuario 87) Compra The Last of Us Part I
(117, 72, NULL, 75),  -- Trans 117 (Usuario 58) Regala Slay the Spire
(118, 31, NULL, 34),  -- Trans 118 (Usuario 12) Compra Control
(119, 7, NULL, 7),    -- Trans 119 (Usuario 45) Compra Baldur's Gate 3
(120, 93, NULL, 96),  -- Trans 120 (Usuario 79) Compra EA Sports FC 24
(121, 47, NULL, 50),  -- Trans 121 (Usuario 36) Compra Lies of P
(122, 3, 1, 3),       -- Trans 122 (Usuario 9) Compra The Witcher 3 (¡CON DESCUENTO!)
(123, 28, NULL, 31),  -- Trans 123 (Usuario 33) Compra Hades
(124, 48, NULL, 52),  -- Trans 124 (Usuario 48) Devuelve Sea of Thieves
(125, 14, NULL, 14),  -- Trans 125 (Usuario 92) Compra Elden Ring
(126, 58, NULL, 61),  -- Trans 126 (Usuario 18) Compra Cuphead
(127, 45, NULL, 48),  -- Trans 127 (Usuario 73) Compra Mortal Kombat 1
(129, 13, NULL, 13),  -- Trans 129 (Usuario 14) Compra RDR 2
(130, 44, NULL, 47),  -- Trans 130 (Usuario 31) Compra Palworld
(131, 50, NULL, 54),  -- Trans 131 (Usuario 25) Compra Valheim
(132, 22, NULL, 22),  -- Trans 132 (Usuario 71) Compra DOOM Eternal
(133, 27, NULL, 30),  -- Trans 133 (Usuario 5) Compra Dark Souls III
(134, 29, NULL, 32),  -- Trans 134 (Usuario 22) Compra Celeste
(135, 38, NULL, 41),  -- Trans 135 (Usuario 38) Compra Forza Horizon 5
(136, 62, NULL, 65),  -- Trans 136 (Usuario 53) Compra Divinity: OS 2
(137, 84, NULL, 87),  -- Trans 137 (Usuario 84) Compra F1 23
(138, 63, NULL, 66),  -- Trans 138 (Usuario 63) Compra Monster Hunter: World
(139, 2, NULL, 2),    -- Trans 139 (Usuario 2) Compra Stardew Valley
(140, 49, NULL, 53),  -- Trans 140 (Usuario 40) Compra Flight Simulator
(141, 108, NULL, 111),-- Trans 141 (Usuario 95) Compra Undertale
(142, 85, NULL, 88),  -- Trans 142 (Usuario 86) Compra Civilization VI
(143, 21, NULL, 21),  -- Trans 143 (Usuario 13) Compra DOOM (2016)
(143, 10, NULL, 10);  -- Trans 143 (Usuario 13) TAMBIÉN Compra Phasmophobia
GO

PRINT '--- Iniciando Lote 6 (Re-intento): 30 Detalles de Transacciones (144-172) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(144, 28, NULL, 31),  -- Trans 144 (Usuario 22) Compra Hades
(145, 58, NULL, 61),  -- Trans 145 (Usuario 80) Compra Cuphead
(146, 59, NULL, 62),  -- Trans 146 (Usuario 38) Compra Rocket League
(147, 30, NULL, 33),  -- Trans 147 (Usuario 100) Compra Persona 5 Royal
(148, 31, NULL, 34),  -- Trans 148 (Usuario 17) Compra Control
(149, 32, NULL, 35),  -- Trans 149 (Usuario 26) Compra Death Stranding
(150, 33, NULL, 36),  -- Trans 150 (Usuario 33) Compra FF VII Remake
(151, 34, NULL, 37),  -- Trans 151 (Usuario 4) Compra Helldivers 2
(152, 35, NULL, 38),  -- Trans 152 (Usuario 85) Compra Alan Wake 2
(153, 36, NULL, 39),  -- Trans 153 (Usuario 51) Compra Diablo IV
(154, 37, NULL, 40), -- Trans 163 (Usuario 54) Compra Street Fighter 6
(164, 47, NULL, 50),  -- Trans 164 (Usuario 46) Compra Lies of P
(165, 48, NULL, 52),  -- Trans 165 (Usuario 81) Compra Sea of Thieves
(166, 7, NULL, 7),    -- Trans 166 (Usuario 7) Compra Baldur's Gate 3
(166, 118, NULL, 118),-- Trans 166 (Usuario 7) TAMBIÉN Compra DLC Elden Ring
(167, 10, NULL, 13),  -- Trans 167 (Usuario 9) Compra RDR 2 (Prod 10, Precio 13)
(168, 19, NULL, 19),  -- Trans 168 (Usuario 19) Compra Spider-Man
(169, 94, NULL, 97),  -- Trans 169 (Usuario 94) Compra NBA 2K24
(170, 16, NULL, 16),  -- Trans 170 (Usuario 16) Compra Zelda BOTW
(171, 89, NULL, 89),  -- Trans 171 (Usuario 23) Devuelve Ratchet & Clank
(172, 34, NULL, 37);  -- Trans 172 (Usuario 34) Compra Helldivers 2
GO

PRINT '--- Lotes 5 y 6 de Detalles (Re-intento) Finalizados ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 7: 30 Detalles de Transacciones (173-202) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(173, 71, NULL, 74),   -- Trans 173 (Usuario 71) Compra R6 Siege
(174, 12, NULL, 12),   -- Trans 174 (Usuario 12) Compra Stardew Valley (DLC)
(175, 9, NULL, 9),     -- Trans 175 (Usuario 9) Compra Cities: Skylines (DLC)
(176, 33, NULL, 36), -- Trans 177 (Usuario 18) Es una Recarga
(178, 45, NULL, 48),   -- Trans 178 (Usuario 45) Compra Mortal Kombat 1
(179, 27, NULL, 30),   -- Trans 179 (Usuario 27) Compra Dark Souls III
(180, 8, NULL, 9),     -- Trans 180 (Usuario 8) Compra Cities: Skylines
(181, 55, NULL, 58),   -- Trans 181 (Usuario 55) Regala Subnautica
(182, 14, NULL, 14), -- Trans 183 (Usuario 77) Es una Recarga
(184, 29, NULL, 32),   -- Trans 184 (Usuario 29) Compra Celeste
(185, 61, NULL, 64),   -- Trans 185 (Usuario 61) Compra Fallout 4
(186, 44, NULL, 47), -- Trans 187 (Usuario 12) Es una Devolucion
(188, 92, NULL, 95),   -- Trans 188 (Usuario 92) Compra Hogwarts Legacy
(189, 13, NULL, 13), -- Trans 190 (Usuario 71) Es una Recarga
(191, 88, NULL, 91),   -- Trans 191 (Usuario 88) Compra Demon's Souls
(192, 41, NULL, 44),   -- Trans 192 (Usuario 20) Compra Mass Effect LE
(193, 52, NULL, 55),   -- Trans 193 (Usuario 52) Compra Deep Rock Galactic
(194, 6, NULL, 6),     -- Trans 194 (Usuario 6) Compra Minecraft
(195, 47, NULL, 50), -- Trans 196 (Usuario 35) Es una Devolucion
(197, 10, NULL, 10),   -- Trans 197 (Usuario 40) Compra Phasmophobia
(198, 5, NULL, 6),     -- Trans 198 (Usuario 50) Compra Minecraft
(199, 22, NULL, 22),   -- Trans 199 (Usuario 66) Compra DOOM Eternal
(200, 38, NULL, 41),   -- Trans 200 (Usuario 77) Compra Forza Horizon 5
(201, 77, NULL, 80),   -- Trans 201 (Usuario 88) Regala Terraria
(202, 17, NULL, 17);   -- Trans 202 (Usuario 99) Compra God of War
GO

PRINT '--- Lote 7 Finalizado ---'
GO

USE EvolutionDB
GO

PRINT '--- Iniciando Lote 8 (FINAL): 19 Detalles de Transacciones (203-221) ---'
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES 
(204, 12, NULL, 12),   -- Trans 204 (Usuario 12) Compra Stardew Valley (DLC)
(205, 71, NULL, 74),   -- Trans 205 (Usuario 71) Compra R6 Siege
(206, 73, NULL, 76),   -- Trans 206 (Usuario 73) Compra Dead Cells
(207, 96, NULL, 99),   -- Trans 207 (Usuario 96) Compra Dead by Daylight
(208, 4, NULL, 4),      -- Trans 209 (Usuario 16) Es una Recarga
(210, 97, NULL, 100),  -- Trans 210 (Usuario 31) Compra Alien: Isolation
(211, 56, NULL, 59),   -- Trans 211 (Usuario 56) Compra Outer Wilds
(212, 48, NULL, 52)   -- Trans 221 (Usuario 4) Compra EA Sports FC 24
GO

PRINT '--- Lote 8 (FINAL) Finalizado ---'
GO

CREATE PROCEDURE sp_GetReporteJuegoDlc
AS
BEGIN
	SELECT TOP 20
		j.nombre AS JuegoBase,
		COUNT(DISTINCT d.idDlc) AS CantidadDLCs,
		(SELECT COUNT(DISTINCT dt.idTransaccion) 
		 FROM DetallesTransacciones dt
		 JOIN productos p2 ON dt.idProducto = p2.idProducto
		 WHERE p2.idJuego = j.idJuego) AS VentasJuegoBase,
		(SELECT COUNT(DISTINCT dt.idTransaccion)
		 FROM detallesTransacciones dt
		 JOIN productos p3 ON dt.idProducto = p3.idProducto
		 JOIN dlcs d2 ON p3.idDlc = d2.idDlc
		 WHERE d2.idJuego = j.idJuego) AS VentasDLCs,
		 isnull(CAST((SELECT SUM(pp.precio * (1 - ISNULL(dp.porcentaje, 0)/100)) 
		 FROM detallesTransacciones dt
		 JOIN productos p4 ON dt.idProducto = p4.idProducto
		 JOIN preciosProductos pp ON dt.idPrecioProducto = pp.idPrecioProducto
		 LEFT JOIN descuentosProducto dp ON dt.idDescuentoProducto = dp.idDescuentoProducto
		 WHERE p4.idJuego = j.idJuego) AS DECIMAL(10,2)),0) AS IngresosJuegoBase,
		 isnull(CAST((SELECT SUM(pp.precio * (1 - ISNULL(dp.porcentaje, 0)/100))
		 FROM detallesTransacciones dt
		 JOIN productos p5 ON dt.idProducto = p5.idProducto
		 JOIN dlcs d3 ON p5.idDlc = d3.idDlc
		 JOIN preciosProductos pp ON dt.idPrecioProducto = pp.idPrecioProducto
		 LEFT JOIN descuentosProducto dp ON dt.idDescuentoProducto = dp.idDescuentoProducto
		 WHERE d3.idJuego = j.idJuego) AS DECIMAL(10,2)),0) AS IngresosDLCs 
	FROM juegos j
	JOIN dlcs d ON j.idJuego = d.idJuego
	GROUP BY j.idJuego, j.nombre
	ORDER BY 5 desc, 6 desc 
end
go

--select juegos.nombre, Dlcs.Nombre from juegos join Dlcs on Dlcs.IdJuego=juegos.IdJuego

--select Precio from Transacciones join DetallesTransacciones on Transacciones.IdTransaccion=DetallesTransacciones.IdTransaccion
--join PreciosProductos ON PreciosProductos.IdProducto=DetallesTransacciones.IdProducto

USE EvolutionDB;
GO



PRINT '--- Inserción de Detalles: Lote 1 (50 transacciones) ---';
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto)
VALUES
(128, 1, NULL, 1),
(155, 2, NULL, 2),
(156, 3, NULL, 3),
(159, 4, NULL, 4),
(160, 5, NULL, 5),
(161, 6, NULL, 6),
(162, 7, NULL, 7),
(163, 8, NULL, 8),
(177, 9, NULL, 9),
(183, 10, NULL, 10),
(187, 11, NULL, 11),
(190, 12, NULL, 12),
(196, 1, NULL, 1),
(203, 2, NULL, 2),
(204, 3, NULL, 3),
(205, 4, NULL, 4),
(206, 5, NULL, 5),
(207, 6, NULL, 6),
(208, 7, NULL, 7),
(227, 8, NULL, 8),
(228, 9, NULL, 9),
(229, 10, NULL, 10),
(230, 11, NULL, 11),
(231, 12, NULL, 12),
(232, 1, NULL, 1),
(233, 2, NULL, 2),
(234, 3, NULL, 3),
(235, 4, NULL, 4),
(236, 5, NULL, 5),
(237, 6, NULL, 6),
(238, 7, NULL, 7),
(239, 8, NULL, 8),
(240, 9, NULL, 9),
(241, 10, NULL, 10),
(242, 11, NULL, 11),
(243, 12, NULL, 12),
(244, 1, NULL, 1),
(245, 2, NULL, 2),
(246, 3, NULL, 3),
(247, 4, NULL, 4),
(248, 5, NULL, 5),
(249, 6, NULL, 6),
(250, 7, NULL, 7),
(251, 8, NULL, 8),
(252, 9, NULL, 9),
(253, 10, NULL, 10),
(254, 11, NULL, 11),
(255, 12, NULL, 12),
(256, 1, NULL, 1),
(257, 2, NULL, 2);
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de Detalles: Lote 2 (Transacciones 258–307) ---';
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de Detalles: Lote 2 (Transacciones 258–307) ---';
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto)
VALUES
(258, 13, NULL, 13),
(259, 18, NULL, 18),
(260, 24, NULL, 24),
(261, 31, NULL, 31),
(262, 37, NULL, 37),
(263, 41, NULL, 41),
(264, 46, NULL, 46),
(265, 52, NULL, 52),
(266, 59, NULL, 59),
(267, 63, NULL, 63),
(268, 67, NULL, 67),
(269, 72, NULL, 72),
(270, 78, NULL, 78),
(271, 83, NULL, 83),
(272, 86, NULL, 86),
(273, 92, NULL, 92),
(274, 97, NULL, 97),
(275, 99, NULL, 99),
(276, 104, NULL, 104),
(277, 107, NULL, 107),
(278, 111, NULL, 111),
(279, 116, NULL, 116),
(280, 120, NULL, 120),
(281, 124, NULL, 124),
(282, 129, NULL, 129),
(283, 133, NULL, 133),
(284, 138, NULL, 138),
(285, 142, NULL, 142),
(286, 145, NULL, 145),
(287, 149, NULL, 149),
(288, 153, NULL, 153),
(289, 157, NULL, 157),
(290, 160, NULL, 160),
(291, 163, NULL, 163),
(292, 166, NULL, 166),
(293, 169, NULL, 169),
(294, 172, NULL, 172),
(295, 175, NULL, 175),
(296, 178, NULL, 178),
(297, 182, NULL, 182),
(298, 3, NULL, 3),
(299, 6, NULL, 6),
(300, 9, NULL, 9),
(301, 12, NULL, 12),
(302, 15, NULL, 15),
(303, 20, NULL, 20),
(304, 25, NULL, 25),
(305, 30, NULL, 30),
(306, 35, NULL, 35),
(307, 40, NULL, 40);
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de Detalles: Lote 3 (Transacciones 308–357) ---';
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto)
VALUES
(308, 8, NULL, 8),
(308, 12, NULL, 12),
(309, 25, NULL, 25),
(309, 26, NULL, 26),
(310, 32, NULL, 32),
(311, 40, NULL, 40),
(311, 42, NULL, 42),
(312, 50, NULL, 50),
(313, 55, NULL, 55),
(313, 58, NULL, 58),
(314, 61, NULL, 61),
(315, 65, NULL, 65),
(316, 69, NULL, 69),
(317, 72, NULL, 72),
(317, 74, NULL, 74),
(317, 78, NULL, 78),
(318, 80, NULL, 80),
(319, 82, NULL, 82),
(319, 83, NULL, 83),
(319, 84, NULL, 84),
(320, 85, NULL, 85),
(321, 87, NULL, 87),
(321, 90, NULL, 90),
(322, 92, NULL, 92),
(323, 94, NULL, 94),
(324, 95, NULL, 95),
(325, 97, NULL, 97),
(326, 99, NULL, 99),
(327, 101, NULL, 101),
(327, 103, NULL, 103),
(328, 107, NULL, 107),
(329, 109, NULL, 109),
(330, 112, NULL, 112),
(331, 115, NULL, 115),
(331, 118, NULL, 118),
(332, 120, NULL, 120),
(333, 123, NULL, 123),
(333, 126, NULL, 126),
(334, 128, NULL, 128),
(335, 130, NULL, 130),
(335, 131, NULL, 131),
(336, 135, NULL, 135),
(337, 139, NULL, 139),
(338, 141, NULL, 141),
(338, 142, NULL, 142),
(339, 145, NULL, 145),
(339, 147, NULL, 147),
(340, 149, NULL, 149),
(341, 152, NULL, 152),
(342, 155, NULL, 155),
(343, 158, NULL, 158),
(344, 160, NULL, 160),
(344, 161, NULL, 161),
(345, 163, NULL, 163),
(345, 164, NULL, 164),
(345, 165, NULL, 165),
(346, 168, NULL, 168),
(347, 171, NULL, 171),
(347, 172, NULL, 172),
(348, 175, NULL, 175),
(349, 177, NULL, 177),
(350, 179, NULL, 179),
(351, 180, NULL, 180),
(351, 181, NULL, 181),
(352, 182, NULL, 182),
(353, 5, NULL, 5),
(353, 6, NULL, 6),
(354, 9, NULL, 9),
(354, 10, NULL, 10),
(355, 14, NULL, 14),
(356, 16, NULL, 16),
(356, 17, NULL, 17),
(357, 19, NULL, 19),
(357, 22, NULL, 22),
(357, 24, NULL, 24);
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de 15 Descuentos de Productos ---';
GO

INSERT INTO DescuentosProducto (IdDescuento, IdProducto, Porcentaje, FechaInicio, FechaFin)
VALUES
-- Oferta de Verano 2025
(1, 5, 15.00, '2025-06-21', '2025-07-05'),
(1, 12, 25.00, '2025-06-21', '2025-07-05'),
(1, 18, 10.00, '2025-06-21', '2025-07-05'),
(1, 27, 30.00, '2025-06-21', '2025-07-05'),
(1, 36, 20.00, '2025-06-21', '2025-07-05'),
(1, 44, 40.00, '2025-06-21', '2025-07-05'),
(1, 55, 35.00, '2025-06-21', '2025-07-05'),
(1, 63, 18.00, '2025-06-21', '2025-07-05'),

-- Oferta de Halloween 2025
(2, 71, 25.00, '2025-10-25', '2025-11-02'),
(2, 79, 30.00, '2025-10-25', '2025-11-02'),
(2, 88, 12.50, '2025-10-25', '2025-11-02'),
(2, 97, 45.00, '2025-10-25', '2025-11-02'),
(2, 104, 20.00, '2025-10-25', '2025-11-02'),
(2, 115, 25.00, '2025-10-25', '2025-11-02'),
(2, 129, 15.00, '2025-10-25', '2025-11-02');
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de Detalles: Lote 4 (Transacciones 358–407) ---';
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto)
VALUES
-- 358
(358, 22, NULL, 22),
(358, 5, 2, 5),
-- 359
(359, 41, NULL, 41),
-- 360
(360, 12, 3, 12),
(360, 7, NULL, 7),
-- 361
(361, 63, 9, 63),
(361, 18, 4, 18),
(361, 27, 5, 27),
-- 362
(362, 36, 6, 36),
-- 363
(363, 3, 1, 3),
(363, 29, NULL, 29),
-- 364
(364, 79, 11, 79),
(364, 21, NULL, 21),
-- 365
(365, 44, 7, 44),
-- 366
(366, 71, 10, 71),
(366, 9, NULL, 9),
(366, 15, NULL, 15),
-- 367
(367, 104, 14, 104),
-- 368
(368, 5, 2, 5),
(368, 12, 3, 12),
-- 369
(369, 55, 8, 55),
(369, 33, NULL, 33),
(369, 2, NULL, 2),
-- 370
(370, 97, 13, 97),
-- 371
(371, 129, 16, 129),
(371, 6, NULL, 6),
-- 372
(372, 36, 6, 36),
(372, 71, 10, 71),
(372, 14, NULL, 14),
-- 373
(373, 88, 12, 88),
-- 374
(374, 25, NULL, 25),
(374, 104, 14, 104),
-- 375
(375, 115, 15, 115),
(375, 63, 9, 63),
-- 376
(376, 18, 4, 18),
(376, 27, 5, 27),
(376, 44, 7, 44),
(376, 55, 8, 55),
-- 377
(377, 1, NULL, 1),
-- 378
(378, 79, 11, 79),
(378, 47, NULL, 47),
-- 379
(379, 12, 3, 12),
-- 380
(380, 5, 2, 5),
(380, 22, NULL, 22),
-- 381
(381, 3, 1, 3),
(381, 36, 6, 36),
-- 382
(382, 71, 10, 71),
-- 383
(383, 88, 12, 88),
(383, 12, 3, 12),
(383, 18, 4, 18),
-- 384
(384, 44, 7, 44),
-- 385
(385, 63, 9, 63),
(385, 5, 2, 5),
-- 386
(386, 97, 13, 97),
-- 387
(387, 104, 14, 104),
(387, 29, NULL, 29),
-- 388
(388, 115, 15, 115),
(388, 14, NULL, 14),
-- 389
(389, 129, 16, 129),
(389, 9, NULL, 9),
(389, 27, 5, 27),
-- 390
(390, 36, 6, 36),
-- 391
(391, 55, 8, 55),
(391, 41, NULL, 41),
(391, 71, 10, 71),
-- 392
(392, 18, 4, 18),
-- 393
(393, 12, 3, 12),
(393, 63, 9, 63),
-- 394
(394, 22, NULL, 22),
(394, 79, 11, 79),
(394, 3, 1, 3),
-- 395
(395, 5, 2, 5),
-- 396
(396, 104, 14, 104),
(396, 36, 6, 36),
-- 397
(397, 88, 12, 88),
(397, 97, 13, 97),
-- 398
(398, 115, 15, 115),
-- 399
(399, 12, 3, 12),
(399, 5, 2, 5),
(399, 1, NULL, 1),
-- 400
(400, 63, 9, 63),
(400, 55, 8, 55),
-- 401
(401, 27, 5, 27),
-- 402
(402, 36, 6, 36),
(402, 71, 10, 71),
(402, 97, 13, 97),
-- 403
(403, 3, 1, 3),
-- 404
(404, 79, 11, 79),
(404, 22, NULL, 22),
-- 405
(405, 12, 3, 12),
(405, 18, 4, 18),
(405, 44, 7, 44),
-- 406
(406, 5, 2, 5),
(406, 129, 16, 129),
-- 407
(407, 88, 12, 88),
(407, 115, 15, 115);
GO

USE EvolutionDB;
GO

PRINT '--- Inserción de Detalles: Lote FINAL (Transacciones 408–441) ---';
GO

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto)
VALUES
-- 408
(408, 5, 2, 5),
(408, 22, NULL, 22),
-- 409
(409, 41, NULL, 41),
-- 410
(410, 12, 3, 12),
(410, 7, NULL, 7),
(410, 26, NULL, 26),
-- 411
(411, 63, 9, 63),
(411, 18, 4, 18),
-- 412
(412, 36, 6, 36),
-- 413
(413, 3, 1, 3),
(413, 29, NULL, 29),
(413, 80, NULL, 80),
-- 414
(414, 79, 11, 79),
(414, 21, NULL, 21),
-- 415
(415, 44, 7, 44),
-- 416
(416, 71, 10, 71),
(416, 9, NULL, 9),
(416, 15, NULL, 15),
-- 417
(417, 104, 14, 104),
(417, 33, NULL, 33),
-- 418
(418, 5, 2, 5),
(418, 12, 3, 12),
-- 419
(419, 55, 8, 55),
(419, 2, NULL, 2),
(419, 47, NULL, 47),
-- 420
(420, 97, 13, 97),
-- 421
(421, 129, 16, 129),
(421, 6, NULL, 6),
-- 422
(422, 36, 6, 36),
(422, 71, 10, 71),
(422, 14, NULL, 14),
-- 423
(423, 88, 12, 88),
-- 424
(424, 25, NULL, 25),
(424, 104, 14, 104),
-- 425
(425, 115, 15, 115),
(425, 63, 9, 63),
-- 426
(426, 18, 4, 18),
(426, 27, 5, 27),
(426, 44, 7, 44),
(426, 55, 8, 55),
-- 427
(427, 1, NULL, 1),
-- 428
(428, 79, 11, 79),
(428, 47, NULL, 47),
-- 429
(429, 12, 3, 12),
-- 430
(430, 5, 2, 5),
(430, 22, NULL, 22),
-- 431
(431, 3, 1, 3),
(431, 36, 6, 36),
-- 432
(432, 71, 10, 71),
-- 433
(433, 88, 12, 88),
(433, 12, 3, 12),
(433, 18, 4, 18),
-- 434
(434, 44, 7, 44),
-- 435
(435, 63, 9, 63),
(435, 5, 2, 5),
-- 436
(436, 97, 13, 97),
-- 437
(437, 104, 14, 104),
(437, 29, NULL, 29),
-- 438
(438, 115, 15, 115),
(438, 14, NULL, 14),
-- 439
(439, 129, 16, 129),
(439, 9, NULL, 9),
(439, 27, 5, 27),
-- 440
(440, 36, 6, 36),
-- 441
(441, 55, 8, 55),
(441, 41, NULL, 41),
(441, 71, 10, 71);
GO




USE EvolutionDB;
GO

PRINT '--- Lote: 30 Transacciones nuevas (IDs esperadas: 442–471) ---';
GO

-- NOTA: Rotamos por métodos que ya existen en tu base (vistos en lotes previos):
-- 31, 97, 56, 48, 83, 108, 21, 98, 57, 87, 103, 112

INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(4,  '2025-11-05 13:00:00', 'Compra', 31),
(12, '2025-11-05 13:02:00', 'Compra', 97),
(21, '2025-11-05 13:04:00', 'Compra', 56),
(29, '2025-11-05 13:06:00', 'Compra', 48),
(36, '2025-11-05 13:08:00', 'Compra', 83),
(45, '2025-11-05 13:10:00', 'Compra', 108),
(52, '2025-11-05 13:12:00', 'Compra', 21),
(58, '2025-11-05 13:14:00', 'Compra', 98),
(63, '2025-11-05 13:16:00', 'Compra', 57),
(71, '2025-11-05 13:18:00', 'Compra', 87),
(77, '2025-11-05 13:20:00', 'Compra', 103),
(83, '2025-11-05 13:22:00', 'Compra', 112),
(88, '2025-11-05 13:24:00', 'Compra', 31),
(92, '2025-11-05 13:26:00', 'Compra', 97),
(96, '2025-11-05 13:28:00', 'Compra', 56),
(99, '2025-11-05 13:30:00', 'Compra', 48),
(18, '2025-11-05 13:32:00', 'Compra', 83),
(9,  '2025-11-05 13:34:00', 'Compra', 108),
(60, '2025-11-05 13:36:00', 'Compra', 21),
(73, '2025-11-05 13:38:00', 'Compra', 98),
(66, '2025-11-05 13:40:00', 'Compra', 57),
(50, '2025-11-05 13:42:00', 'Compra', 87),
(35, '2025-11-05 13:44:00', 'Compra', 103),
(27, '2025-11-05 13:46:00', 'Compra', 112),
(14, '2025-11-05 13:48:00', 'Compra', 31),
(79, '2025-11-05 13:50:00', 'Compra', 97),
(25, '2025-11-05 13:52:00', 'Compra', 56),
(31, '2025-11-05 13:54:00', 'Compra', 48),
(48, '2025-11-05 13:56:00', 'Compra', 83),
(87, '2025-11-05 13:58:00', 'Compra', 108);
GO

PRINT '--- Lote: 30 Detalles (solo DLC) para Transacciones 442–471 ---';
GO

-- Todos DLC. IdPrecioProducto alineado 1:1 con IdProducto, como en tus lotes.
-- Sin descuentos (IdDescuentoProducto = NULL).

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES
(442,  4,   NULL,  4),   -- Phantom Liberty (CP2077 DLC)
(443,  11,  NULL, 11),   -- The Crimson Court (Darkest Dungeon DLC)
(444,  12,  NULL, 12),   -- After Dark (Cities: Skylines DLC)
(445,  118, NULL, 118),  -- Elden Ring: Shadow of the Erdtree
(446,  122, NULL, 122),  -- DOOM Eternal: The Ancient Gods (Pt.1)
(447,  123, NULL, 123),  -- DOOM Eternal: The Ancient Gods (Pt.2)
(448,  125, NULL, 125),  -- Control: The Foundation
(449,  126, NULL, 126),  -- Control: AWE
(450,  129, NULL, 129),  -- The Sims 4: Cats & Dogs
(451,  130, NULL, 130),  -- The Sims 4: Seasons
(452,  131, NULL, 131),  -- The Sims 4: Get Famous
(453,  132, NULL, 132),  -- The Sims 4: Island Living
(454,  133, NULL, 133),  -- The Sims 4: Discover University
(455,  134, NULL, 134),  -- The Sims 4: Eco Lifestyle
(456,  135, NULL, 135),  -- The Sims 4: Snowy Escape
(457,  136, NULL, 136),  -- The Sims 4: Cottage Living
(458,  137, NULL, 137),  -- The Sims 4: High School Years
(459,  149, NULL, 149),  -- AC Valhalla DLC / similar
(460,  150, NULL, 150),
(461,  151, NULL, 151),
(462,  152, NULL, 152),
(463,  153, NULL, 153),
(464,  154, NULL, 154),
(465,  155, NULL, 155),
(466,  156, NULL, 156),
(467,  157, NULL, 157),
(468,  160, NULL, 160),
(469,  161, NULL, 161),
(470,  162, NULL, 162),
(471,  163, NULL, 163);
GO


create procedure sp_UsuariosMayorGasto
as
begin 
 SELECT top 10    
    u.nombreUsuario as NombreUsuario,
    SUM(ROUND(pp.precio * (1 - COALESCE(dp.porcentaje, 0)/100.0), 2)) AS TotalGastado,
    COUNT(DISTINCT t.idTransaccion) AS CantidadTransacciones
FROM usuarios u
JOIN transacciones t ON t.idUsuario = u.idUsuario
JOIN detallesTransacciones dt ON dt.idTransaccion = t.idTransaccion
JOIN preciosProductos pp ON pp.idPrecioProducto = dt.idPrecioProducto
LEFT JOIN descuentosProducto dp ON dp.idDescuentoProducto = dt.idDescuentoProducto
GROUP BY u.nombreUsuario
HAVING SUM(ROUND(pp.precio * (1 - COALESCE(dp.porcentaje, 0)/100.0), 2)) >
(
    SELECT ROUND(AVG(total_gasto), 2)
    FROM (
        SELECT
            SUM(ROUND(pp2.precio * (1 - COALESCE(dp2.porcentaje, 0)/100.0), 2)) AS total_gasto
        FROM usuarios u2
        JOIN transacciones t2 ON t2.idUsuario = u2.idUsuario
        JOIN detallesTransacciones dt2 ON dt2.idTransaccion = t2.idTransaccion
        JOIN preciosProductos pp2 ON pp2.idPrecioProducto = dt2.idPrecioProducto
        LEFT JOIN descuentosProducto dp2 ON dp2.idDescuentoProducto = dt2.idDescuentoProducto
        GROUP BY u2.nombreUsuario
        HAVING SUM(ROUND(pp2.precio * (1 - COALESCE(dp2.porcentaje, 0)/100.0), 2)) > 0
    ) AS sub_gastos
)
order by TotalGastado desc
end
go


create procedure SP_publishers_ingresos
as
begin
	SELECT TOP 5
		PUB.Nombre AS Publisher,
		ISNULL(COUNT(DT.IdDetalleTransaccion), 0) AS UnidadesVendidas,
		ISNULL(SUM(PP.Precio), 0) AS TotalRecaudado
	FROM
		DetallesTransacciones AS DT
	JOIN PreciosProductos AS PP ON DT.IdPrecioProducto = PP.IdPrecioProducto
	JOIN Productos AS P ON DT.IdProducto = P.IdProducto
	JOIN Juegos AS J ON P.IdJuego = J.IdJuego
	JOIN JuegosPublishers AS JP ON J.IdJuego = JP.IdJuego
	JOIN Publishers AS PUB ON JP.IdPublisher = PUB.IdPublisher
	GROUP BY
		PUB.Nombre
	ORDER BY
		TotalRecaudado DESC;
end
go

use EvolutionDB
go


INSERT INTO Transacciones (IdUsuario, Fecha, Tipo, IdMetodoPagoGuardado) VALUES
(4,  '2025-11-05 13:00:00', 'Compra', 31),
(12, '2025-11-05 13:02:00', 'Compra', 97),
(21, '2025-11-05 13:04:00', 'Compra', 56),
(29, '2025-11-05 13:06:00', 'Compra', 48),
(36, '2025-11-05 13:08:00', 'Compra', 83),
(45, '2025-11-05 13:10:00', 'Compra', 108),
(52, '2025-11-05 13:12:00', 'Compra', 21),
(58, '2025-11-05 13:14:00', 'Compra', 98),
(63, '2025-11-05 13:16:00', 'Compra', 57),
(71, '2025-11-05 13:18:00', 'Compra', 87),
(77, '2025-11-05 13:20:00', 'Compra', 103),
(83, '2025-11-05 13:22:00', 'Compra', 112),
(88, '2025-11-05 13:24:00', 'Compra', 31),
(92, '2025-11-05 13:26:00', 'Compra', 97),
(96, '2025-11-05 13:28:00', 'Compra', 56),
(99, '2025-11-05 13:30:00', 'Compra', 48),
(18, '2025-11-05 13:32:00', 'Compra', 83),
(9,  '2025-11-05 13:34:00', 'Compra', 108),
(60, '2025-11-05 13:36:00', 'Compra', 21),
(73, '2025-11-05 13:38:00', 'Compra', 98),
(66, '2025-11-05 13:40:00', 'Compra', 57),
(50, '2025-11-05 13:42:00', 'Compra', 87),
(35, '2025-11-05 13:44:00', 'Compra', 103),
(27, '2025-11-05 13:46:00', 'Compra', 112),
(14, '2025-11-05 13:48:00', 'Compra', 31),
(79, '2025-11-05 13:50:00', 'Compra', 97),
(25, '2025-11-05 13:52:00', 'Compra', 56),
(31, '2025-11-05 13:54:00', 'Compra', 48),
(48, '2025-11-05 13:56:00', 'Compra', 83),
(87, '2025-11-05 13:58:00', 'Compra', 108);
GO

PRINT '--- Lote: 30 Detalles (solo DLC) para Transacciones 442–471 ---';
GO

-- Todos DLC. IdPrecioProducto alineado 1:1 con IdProducto, como en tus lotes.
-- Sin descuentos (IdDescuentoProducto = NULL).

INSERT INTO DetallesTransacciones (IdTransaccion, IdProducto, IdDescuentoProducto, IdPrecioProducto) VALUES
(442,  4,   NULL,  4),   -- Phantom Liberty (CP2077 DLC)
(443,  11,  NULL, 11),   -- The Crimson Court (Darkest Dungeon DLC)
(444,  12,  NULL, 12),   -- After Dark (Cities: Skylines DLC)
(445,  118, NULL, 118),  -- Elden Ring: Shadow of the Erdtree
(446,  122, NULL, 122),  -- DOOM Eternal: The Ancient Gods (Pt.1)
(447,  123, NULL, 123),  -- DOOM Eternal: The Ancient Gods (Pt.2)
(448,  125, NULL, 125),  -- Control: The Foundation
(449,  126, NULL, 126),  -- Control: AWE
(450,  129, NULL, 129),  -- The Sims 4: Cats & Dogs
(451,  130, NULL, 130),  -- The Sims 4: Seasons
(452,  131, NULL, 131),  -- The Sims 4: Get Famous
(453,  132, NULL, 132),  -- The Sims 4: Island Living
(454,  133, NULL, 133),  -- The Sims 4: Discover University
(455,  134, NULL, 134),  -- The Sims 4: Eco Lifestyle
(456,  135, NULL, 135),  -- The Sims 4: Snowy Escape
(457,  136, NULL, 136),  -- The Sims 4: Cottage Living
(458,  137, NULL, 137),  -- The Sims 4: High School Years
(459,  149, NULL, 149),  -- AC Valhalla DLC / similar
(460,  150, NULL, 150),
(461,  151, NULL, 151),
(462,  152, NULL, 152),
(463,  153, NULL, 153),
(464,  154, NULL, 154),
(465,  155, NULL, 155),
(466,  156, NULL, 156),
(467,  157, NULL, 157),
(468,  160, NULL, 160),
(469,  161, NULL, 161),
(470,  162, NULL, 162),
(471,  163, NULL, 163);
GO

-- Ejemplo de cómo actualizar un juego existente
UPDATE Juegos
SET ImagenUrl = 'https://images.steamusercontent.com/ugc/1842538926658063675/A501F9C4989B1CB48411116CD8AC7E21291C1A32/?imw=512&&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false'
WHERE Nombre = 'Cyberpunk 2077';

UPDATE Juegos
SET ImagenUrl = 'https://image.api.playstation.com/gs2-sec/appkgo/prod/CUSA08519_00/12/i_3da1cf7c41dc7652f9b639e1680d96436773658668c7dc3930c441291095713b/i/icon0.png'
WHERE Nombre = 'Red Dead Redemption 2';

UPDATE Juegos
SET ImagenUrl = 'https://cdn-images.dzcdn.net/images/cover/7248308fc547ad0b94c49cfa7dc1f998/1900x1900-000000-80-0-0.jpg'
WHERE Nombre = 'A Plague Tale: Requiem';

UPDATE Juegos
SET ImagenUrl = 'https://images.steamusercontent.com/ugc/2142084077035734220/B9708A5FDEC34EEB72F75EF32F887C768F5F5B01/?imw=512&&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false'
WHERE Nombre = 'Alan wake 2';

UPDATE Juegos
SET ImagenUrl = 'https://image.api.playstation.com/gs2-sec/appkgo/prod/CUSA00362_00/5/i_78c823374d1397ccb9e9d8dd5acc6153a8ca608414b6249c5c051a73888da9be/i/icon0.png'
WHERE Nombre = 'Alien: isolation';

UPDATE Juegos
SET ImagenUrl = 'https://cdn.mobygames.com/covers/7477029-apex-legends-playstation-4-front-cover.jpg'
WHERE Nombre = 'Apex legends';

UPDATE Juegos
SET ImagenUrl = 'https://image.api.playstation.com/gs2-sec/appkgo/prod/CUSA09303_00/3/i_d6b485c473b4b3d739197a5f020aeb7428f69d6c29e0dda514f6db41916dc3b6/i/icon0.png'
WHERE IdJuego = 65;

UPDATE Juegos
SET ImagenUrl = 'https://cdn.mobygames.com/covers/9456146-assassins-creed-valhalla-playstation-4-front-cover.jpg'
WHERE IdJuego = 66;

UPDATE Juegos
SET ImagenUrl = 'https://assets-prd.ignimgs.com/2023/08/24/baldursg3-1692894717196.jpeg'
WHERE IdJuego = 6;

UPDATE Juegos
SET ImagenUrl = 'https://f4.bcbits.com/img/a4218237573_10.jpg'
WHERE IdJuego = 25;

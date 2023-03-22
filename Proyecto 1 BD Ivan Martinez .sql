/*
Ivan Alejandro Martinez Gracia
Proyecto 1 Bases de Datos
17/03/2023


/*--------------------------------CREACION TABLAS-------------------------------------------------*/
CREATE TABLE Continente (
  ID NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
  Nombre VARCHAR2(50) NOT NULL,
  Extension NUMBER(10,2) NOT NULL,
  CONSTRAINT PK_Continente PRIMARY KEY (ID),
  CONSTRAINT AK_Continente_Nombre UNIQUE (Nombre)
);

CREATE TABLE Pais (
  ID NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
  ID_Continente NUMBER(10,0) NOT NULL,
  Nombre VARCHAR2(50) NOT NULL,
  CONSTRAINT PK_Pais PRIMARY KEY (ID),
  CONSTRAINT AK_Pais_ID_Continente_Nombre UNIQUE (ID_Continente, Nombre),
  CONSTRAINT FK_Pais_Continente FOREIGN KEY (ID_Continente) REFERENCES Continente(ID)
);

CREATE TABLE Destino_Turistico (
  ID NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
  ID_Pais NUMBER(10,0) NOT NULL,
  Nombre VARCHAR2(50) NOT NULL,
  Valor_Tour NUMBER(10,2) DEFAULT 0 NOT NULL,
  Patrimonio_Humanidad VARCHAR2(2) DEFAULT 'no' NOT NULL,
  CONSTRAINT PK_Destino_Turistico PRIMARY KEY (ID),
  CONSTRAINT AK_Destino_Turistico_ID_Pais_Nombre UNIQUE (ID_Pais, Nombre),
  CONSTRAINT FK_Destino_Turistico_Pais FOREIGN KEY (ID_Pais) REFERENCES Pais(ID),
  CONSTRAINT CK_Destino_Turistico_Valor_Tour CHECK (Valor_Tour >= 0),
  CONSTRAINT CK_Destino_Turistico_Patrimonio_Humanidad CHECK (Patrimonio_Humanidad IN ('si','no'))
);


/*------------------------------------CREACION REGISTROS--------------------------------------------*/

INSERT INTO Continente (Nombre, Extension)
VALUES ('América', 42320.3);

INSERT INTO Continente (Nombre, Extension)
VALUES ('Europa', 10180.0);

INSERT INTO Continente (Nombre, Extension)
VALUES ('Asia', 44579.0);

INSERT INTO Continente (Nombre, Extension)
VALUES ('África', 30370.0);

INSERT INTO Continente (Nombre, Extension)
VALUES ('Oceanía', 8503.0);


INSERT INTO Pais (ID_Continente, Nombre)
VALUES (1, 'Estados Unidos');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (1, 'Canadá');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (2, 'España');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (2, 'Francia');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (3, 'China');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (3, 'India');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (4, 'Egipto');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (4, 'Sudáfrica');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (5, 'Australia');

INSERT INTO Pais (ID_Continente, Nombre)
VALUES (5, 'Nueva Zelanda');



INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (1, 'Nueva York', 150, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (1, 'Las Vegas', 200, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (2, 'Toronto', 100, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (2, 'Vancouver', 180, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (3, 'Madrid', 120, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (3, 'Barcelona', 150, 'si');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (4, 'París', 180, 'si');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (4, 'Niza', 120, 'no');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (5, 'Pekín', 200, 'si');

INSERT INTO Destino_Turistico (ID_Pais, Nombre, Valor_Tour, Patrimonio_Humanidad)
VALUES (5, 'Sídney', 180, 'no');



/*-------------------------- VISTAS----------------------------------------*/

/*1*/ CREATE OR REPLACE VIEW destinos_por_pais AS
SELECT c.Nombre AS Nombre_Continente, p.Nombre AS Nombre_Pais, COUNT(dt.ID) AS Cantidad_Destinos
FROM Continente c
INNER JOIN Pais p ON c.ID = p.ID_Continente
LEFT JOIN Destino_Turistico dt ON p.ID = dt.ID_Pais
GROUP BY c.Nombre, p.Nombre;

/*2*/ CREATE OR REPLACE VIEW costo_tours_por_pais AS
SELECT p.Nombre AS Nombre_Pais, SUM(dt.Valor_Tour) AS Total_Costo_Tours
FROM Pais p
LEFT JOIN Destino_Turistico dt ON p.ID = dt.ID_Pais
GROUP BY p.Nombre
UNION ALL
SELECT 'Total Mundial' AS Nombre_Pais, SUM(dt.Valor_Tour) AS Total_Costo_Tours
FROM Destino_Turistico dt;

/*3*/ CREATE OR REPLACE VIEW destino_tour_promedio_continentes AS
SELECT d.Nombre AS Nombre_Destino, c.Nombre AS Nombre_Continente, AVG(dt.Valor_Tour) AS Promedio_Valor_Tour_Continente, d.Valor_Tour
FROM Destino_Turistico d
JOIN Pais p ON d.ID_Pais = p.ID
JOIN Continente c ON p.ID_Continente = c.ID
JOIN Destino_Turistico dt ON dt.ID_Pais = p.ID
GROUP BY d.Nombre, c.Nombre, d.Valor_Tour
HAVING d.Valor_Tour > AVG(dt.Valor_Tour);

/*4*/ CREATE VIEW porcentaje_participacion AS
SELECT p.nombre AS pais, COUNT(*)*100/NULLIF((SELECT COUNT(*) FROM destino_turistico WHERE id_pais IN (SELECT id FROM pais WHERE id_continente = p.id_continente)), 0) AS porcentaje_participacion
FROM pais p
JOIN destino_turistico dt ON p.id = dt.id_pais
GROUP BY p.nombre, p.id_continente;

/*5*/ CREATE OR REPLACE VIEW contiente_con_destino_en_cada_pais AS
SELECT c.Nombre AS Nombre_Continente
FROM Continente c
WHERE NOT EXISTS (
  SELECT p.ID
  FROM Pais p
  WHERE p.ID_Continente = c.ID
  AND NOT EXISTS (
    SELECT d.ID
    FROM Destino_Turistico d
    WHERE d.ID_Pais = p.ID
  )
);

/*6 */CREATE VIEW destinos_patrimonio AS
SELECT t.Continente, 
       t.Patrimonio,
       t.No_Patrimonio,
       t.Total
FROM (
  SELECT c.Nombre AS Continente, 
         SUM(CASE WHEN dt.Patrimonio_Humanidad = 'si' THEN 1 ELSE 0 END) AS Patrimonio,
         SUM(CASE WHEN dt.Patrimonio_Humanidad = 'no' THEN 1 ELSE 0 END) AS No_Patrimonio,
         COUNT(*) AS Total
  FROM Continente c
  JOIN Pais p ON c.ID = p.ID_Continente
  JOIN Destino_Turistico dt ON p.ID = dt.ID_Pais
  GROUP BY GROUPING SETS(c.Nombre, ())
) t
GROUP BY t.Continente, t.Patrimonio, t.No_Patrimonio, t.Total;

/*-------------------------PERMISOS-------------------------------*/

SELECT 'GRANT SELECT ON ' || owner || '.' || table_name || ' TO JPALACIO;' as grant_stmt
FROM all_tables
WHERE owner NOT IN ('SYS','SYSTEM')
UNION
SELECT 'GRANT SELECT ON ' || owner || '.' || view_name || ' TO JPALACIO;' as grant_stmt
FROM all_views
WHERE owner NOT IN ('SYS','SYSTEM');


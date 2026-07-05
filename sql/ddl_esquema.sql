-- =========================================================================
-- SCRIPT DE CREACIÓN DE TABLAS
-- =========================================================================

-- Desactivamos temporalmente el chequeo de claves foráneas
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS H_PRINCIPALS;
DROP TABLE IF EXISTS H_RATINGS;
DROP TABLE IF EXISTS DIM_TITLES;
DROP TABLE IF EXISTS DIM_NAMES;
DROP TABLE IF EXISTS DIM_GENRES;
DROP TABLE IF EXISTS DIM_FECHA;

SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------------------
-- 1. TABLAS INDEPENDIENTES (Dimensiones básicas)
-- -------------------------------------------------------------------------

-- Tabla: DIM_FECHA
CREATE TABLE DIM_FECHA (
    FechaID VARCHAR(10) NOT NULL,
    Año YEAR(4),
    PRIMARY KEY (FechaID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: DIM_GENRES
CREATE TABLE DIM_GENRES (
    GenreID VARCHAR(10) NOT NULL,
    Genre VARCHAR(45),
    PRIMARY KEY (GenreID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: DIM_NAMES
CREATE TABLE DIM_NAMES (
    nameID VARCHAR(10) NOT NULL,
    primaryName VARCHAR(255),
    birthYear INT,
    deathYear INT,
    primaryProfession VARCHAR(45),
    PRIMARY KEY (nameID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------------------
-- 2. TABLAS DEPENDIENTES (Dimensiones complejas y Hechos)
-- -------------------------------------------------------------------------

-- Tabla: DIM_TITLES
-- Depende de: DIM_FECHA, DIM_GENRES y tiene una relación autorreferencial (ParentTitleID)
CREATE TABLE DIM_TITLES (
    titleID VARCHAR(10) NOT NULL,
    titleType VARCHAR(20),
    primaryTitle VARCHAR(500),
    isAdult TINYINT(1),
    startYear YEAR(4),
    endYear YEAR(4),
    runtimeMinutes INT,
    seasonNumber INT,
    episodeNumber INT,
    Fecha VARCHAR(10),
    Genres VARCHAR(10),
    ParentTitleID VARCHAR(10),
    PRIMARY KEY (titleID),
    CONSTRAINT FK_DIM_TITLES_FECHA FOREIGN KEY (Fecha) 
        REFERENCES DIM_FECHA (FechaID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_DIM_TITLES_GENRES FOREIGN KEY (Genres) 
        REFERENCES DIM_GENRES (GenreID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_DIM_TITLES_PARENT FOREIGN KEY (ParentTitleID) 
        REFERENCES DIM_TITLES (titleID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: H_RATINGS
-- Depende de: DIM_TITLES
CREATE TABLE H_RATINGS (
    titleID VARCHAR(10) NOT NULL,
    averageRating DECIMAL(3,1),
    numVotes INT,
    DIM_TITLES_titleID VARCHAR(10),
    DIM_TITLES_titleID1 VARCHAR(10),
    PRIMARY KEY (titleID),
    CONSTRAINT FK_H_RATINGS_TITLES_MAIN FOREIGN KEY (DIM_TITLES_titleID) 
        REFERENCES DIM_TITLES (titleID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_H_RATINGS_TITLES_ALT FOREIGN KEY (DIM_TITLES_titleID1) 
        REFERENCES DIM_TITLES (titleID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: H_PRINCIPALS
-- Depende de: DIM_NAMES y H_RATINGS
CREATE TABLE H_PRINCIPALS (
    titleID VARCHAR(10) NOT NULL,
    ordering INT NOT NULL,
    category VARCHAR(45),
    job VARCHAR(45),
    characters VARCHAR(255),
    Name VARCHAR(10),
    H_RATINGS_titleID VARCHAR(10),
    H_RATINGS_DIM_TITLES_titleID VARCHAR(10),
    PRIMARY KEY (titleID, ordering), -- Usamos clave compuesta para evitar duplicados por película
    CONSTRAINT FK_H_PRINCIPALS_NAMES FOREIGN KEY (Name) 
        REFERENCES DIM_NAMES (nameID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_H_PRINCIPALS_RATINGS FOREIGN KEY (H_RATINGS_titleID) 
        REFERENCES H_RATINGS (titleID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_H_PRINCIPALS_RATINGS_TITLES FOREIGN KEY (H_RATINGS_DIM_TITLES_titleID) 
        REFERENCES H_RATINGS (titleID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
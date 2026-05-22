-- CREATE DATABASE gestion_stock;
-- USE gestion_stock;

-- 1. Table : UTILISATEUR
CREATE TABLE UTILISATEUR (
    id_utilisateur INT AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_utilisateur)
) ENGINE=InnoDB;

-- 2. Table : CLIENT (Dépend de UTILISATEUR via l'association ECHANGER 1,1)
CREATE TABLE CLIENT (
    id_client INT AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    telephone VARCHAR(20),
    status VARCHAR(50),
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_client),
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. Table : ARTICLE
CREATE TABLE ARTICLE (
    id_article INT AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    poids DECIMAL(10,2), -- Correspond à "poids" sur le MCD (noté typo "prenom" sur le MLD)
    fournisseur VARCHAR(100),
    type VARCHAR(50),
    PRIMARY KEY (id_article)
) ENGINE=InnoDB;

-- 4. Table : COMMANDE (Table de liaison N,N entre CLIENT et ARTICLE)
CREATE TABLE COMMANDE (
    id_client INT,
    id_article INT,
    PRIMARY KEY (id_client, id_article),
    FOREIGN KEY (id_client) REFERENCES CLIENT(id_client) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_article) REFERENCES ARTICLE(id_article) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Table : SITE
CREATE TABLE SITE (
    id_site INT AUTO_INCREMENT,
    libelle VARCHAR(100) NOT NULL,
    adresse VARCHAR(255),
    PRIMARY KEY (id_site)
) ENGINE=InnoDB;

-- 6. Table : LOCALISATION (Dépend de SITE)
CREATE TABLE LOCALISATION (
    id_localisation INT AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL,
    zone VARCHAR(50),
    allee VARCHAR(50),
    etage VARCHAR(50),
    place VARCHAR(50),
    id_site INT NOT NULL,
    PRIMARY KEY (id_localisation),
    FOREIGN KEY (id_site) REFERENCES SITE(id_site) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. Table : STOCK (Dépend de LOCALISATION)
CREATE TABLE STOCK (
    id_stock INT AUTO_INCREMENT,
    quantite INT NOT NULL DEFAULT 0,
    id_localisation INT NOT NULL,
    PRIMARY KEY (id_stock),
    FOREIGN KEY (id_localisation) REFERENCES LOCALISATION(id_localisation) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. Table : CONTENIR (Table de liaison N,N entre STOCK et ARTICLE)
CREATE TABLE CONTENIR (
    id_stock INT,
    id_article INT,
    PRIMARY KEY (id_stock, id_article),
    FOREIGN KEY (id_stock) REFERENCES STOCK(id_stock) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_article) REFERENCES ARTICLE(id_article) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. Table : MOUVEMENT (Dépend de UTILISATEUR et de STOCK)
CREATE TABLE MOUVEMENT (
    id_mouvement INT AUTO_INCREMENT,
    ttype VARCHAR(50) NOT NULL, -- "ttype" d'après ton MLD pour éviter le mot-clé réservé TYPE
    reference VARCHAR(100),
    date DATE NOT NULL,
    heure TIME NOT NULL,
    id_utilisateur INT NOT NULL,
    id_stock INT NOT NULL,
    PRIMARY KEY (id_mouvement),
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_stock) REFERENCES STOCK(id_stock) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

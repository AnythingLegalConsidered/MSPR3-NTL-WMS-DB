-- =====================================================================
-- WMS — Schéma DDL MariaDB 11.4
-- Version : 1.0 (2026-05-22) — dérivé du MCD simplifié 7 entités
-- Voir : ../mcd/wms-mcd.md  et  ../mld/wms-mld.md
-- Charset : utf8mb4 / collation utf8mb4_unicode_ci
-- Moteur : InnoDB (FK + transactions)
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Ordre de DROP : tables associatives et dépendantes d'abord
DROP TABLE IF EXISTS article_stock;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS mouvement;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS article;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS localisation;
DROP TABLE IF EXISTS site;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 1. SITE
-- =====================================================================
CREATE TABLE site (
    id_site     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    libelle     VARCHAR(100)  NOT NULL,
    adresse     VARCHAR(255)  NOT NULL,
    PRIMARY KEY (id_site)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 2. LOCALISATION (FK → site)
-- =====================================================================
CREATE TABLE localisation (
    id_localisation INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code            VARCHAR(30)  NOT NULL,
    zone            VARCHAR(30)  NOT NULL,
    allee           VARCHAR(10)  NOT NULL,
    etage           VARCHAR(10)  NOT NULL,
    place           VARCHAR(10)  NOT NULL,
    id_site         INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_localisation),
    UNIQUE KEY uk_localisation_code (code),
    KEY idx_localisation_site (id_site),
    CONSTRAINT fk_localisation_site
        FOREIGN KEY (id_site) REFERENCES site(id_site)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 3. UTILISATEUR
-- =====================================================================
CREATE TABLE utilisateur (
    id_utilisateur INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom            VARCHAR(100) NOT NULL,
    role           VARCHAR(30)  NOT NULL,
    PRIMARY KEY (id_utilisateur)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 4. CLIENT (FK → utilisateur, association ECHANGER)
-- =====================================================================
CREATE TABLE client (
    id_client      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nom            VARCHAR(100)  NOT NULL,
    siret          CHAR(14)      NOT NULL,
    telephone      VARCHAR(20)   NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'actif',
    id_utilisateur INT UNSIGNED  NOT NULL,
    PRIMARY KEY (id_client),
    UNIQUE KEY uk_client_siret (siret),
    KEY idx_client_utilisateur (id_utilisateur),
    CONSTRAINT fk_client_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 5. ARTICLE
-- =====================================================================
CREATE TABLE article (
    id_article  INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(150)   NOT NULL,
    poids       DECIMAL(10,3)  NOT NULL,
    fournisseur VARCHAR(100)   NULL,
    type        VARCHAR(50)    NOT NULL,
    PRIMARY KEY (id_article),
    CONSTRAINT ck_article_poids CHECK (poids > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 6. STOCK (FK → localisation, association CONTENIR stock-localisation)
-- =====================================================================
CREATE TABLE stock (
    id_stock        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    quantite        INT UNSIGNED NOT NULL DEFAULT 0,
    id_localisation INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_stock),
    KEY idx_stock_localisation (id_localisation),
    CONSTRAINT fk_stock_localisation
        FOREIGN KEY (id_localisation) REFERENCES localisation(id_localisation)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 7. MOUVEMENT (FK → stock, utilisateur)
-- Note : id_stock non-UNIQUE (écart MCD volontaire — voir wms-mcd.md §3)
-- =====================================================================
CREATE TABLE mouvement (
    id_mouvement   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type           VARCHAR(20)  NOT NULL,
    reference      VARCHAR(50)  NOT NULL,
    date           DATE         NOT NULL,
    heure          TIME         NOT NULL,
    id_stock       INT UNSIGNED NULL,
    id_utilisateur INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_mouvement),
    UNIQUE KEY uk_mouvement_reference (reference),
    KEY idx_mouvement_date (date),
    KEY idx_mouvement_stock (id_stock),
    KEY idx_mouvement_utilisateur (id_utilisateur),
    CONSTRAINT fk_mouvement_stock
        FOREIGN KEY (id_stock) REFERENCES stock(id_stock)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_mouvement_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_mouvement_type CHECK (type IN ('entree','sortie','ajustement','transfert'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 8. COMMANDE (table associative CLIENT ↔ ARTICLE)
-- =====================================================================
CREATE TABLE commande (
    id_commande        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_client          INT UNSIGNED NOT NULL,
    id_article         INT UNSIGNED NOT NULL,
    quantite_commandee INT UNSIGNED NOT NULL,
    date_commande      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_commande),
    KEY idx_commande_client (id_client),
    KEY idx_commande_article (id_article),
    CONSTRAINT fk_commande_client
        FOREIGN KEY (id_client) REFERENCES client(id_client)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_commande_article
        FOREIGN KEY (id_article) REFERENCES article(id_article)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_commande_quantite CHECK (quantite_commandee > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 9. ARTICLE_STOCK (table associative ARTICLE ↔ STOCK)
-- =====================================================================
CREATE TABLE article_stock (
    id_article INT UNSIGNED NOT NULL,
    id_stock   INT UNSIGNED NOT NULL,
    date_ajout DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_article, id_stock),
    KEY idx_article_stock_stock (id_stock),
    CONSTRAINT fk_article_stock_article
        FOREIGN KEY (id_article) REFERENCES article(id_article)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_article_stock_stock
        FOREIGN KEY (id_stock) REFERENCES stock(id_stock)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- Fin du script
-- =====================================================================

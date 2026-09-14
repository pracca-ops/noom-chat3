-- ============================================================================
--  GéoConsulting — base de données du site
--  Principe : la base ne contient QUE des données publiables.
--  Les montants, numéros de marché, noms d'experts affectés, immatriculations
--  et pièces administratives ne sont volontairement pas modélisés ici.
--  Encodage : utf8mb4 (indispensable pour les accents français).
-- ============================================================================

SET NAMES utf8mb4;
SET time_zone = '+01:00';

CREATE DATABASE IF NOT EXISTS geoconsulting
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE geoconsulting;

-- ---------------------------------------------------------------------------
-- Comptes d'administration
-- ---------------------------------------------------------------------------
CREATE TABLE utilisateurs (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nom            VARCHAR(120) NOT NULL,
  email          VARCHAR(190) NOT NULL UNIQUE,
  mot_de_passe   VARCHAR(255) NOT NULL,           -- hachage password_hash(), jamais en clair
  role           ENUM('administrateur','editeur') NOT NULL DEFAULT 'editeur',
  actif          TINYINT(1) NOT NULL DEFAULT 1,
  derniere_connexion DATETIME NULL,
  cree_le        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Secteurs d'intervention
-- ---------------------------------------------------------------------------
CREATE TABLE secteurs (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nom         VARCHAR(120) NOT NULL,
  slug        VARCHAR(120) NOT NULL UNIQUE,
  description TEXT NULL,
  ordre       SMALLINT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Références / réalisations  (version publique)
-- ---------------------------------------------------------------------------
CREATE TABLE realisations (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titre        VARCHAR(255) NOT NULL,
  slug         VARCHAR(255) NOT NULL UNIQUE,
  secteur_id   INT UNSIGNED NOT NULL,
  client       VARCHAR(190) NULL,                 -- maître d'ouvrage
  bailleur     VARCHAR(190) NULL,                 -- source de financement
  lieu         VARCHAR(190) NULL,
  pays         VARCHAR(90)  NOT NULL DEFAULT 'Niger',
  periode      VARCHAR(60)  NULL,                 -- « 2024 – 2025 », « 2020 – en cours »
  annee_debut  SMALLINT NULL,                     -- pour le tri et les filtres
  statut       ENUM('acheve','en_cours') NOT NULL DEFAULT 'acheve',
  prestations  TEXT NULL,
  description  MEDIUMTEXT NULL,
  attestation  TINYINT(1) NOT NULL DEFAULT 0,     -- attestation de bonne fin obtenue (oui/non seulement)
  phare        TINYINT(1) NOT NULL DEFAULT 0,     -- mise en avant page d'accueil
  publie       TINYINT(1) NOT NULL DEFAULT 0,
  cree_le      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modifie_le   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_realisation_secteur FOREIGN KEY (secteur_id) REFERENCES secteurs(id),
  INDEX idx_publie (publie, phare),
  INDEX idx_secteur (secteur_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Photos rattachées aux réalisations
-- consentement : à cocher uniquement si aucune personne identifiable
-- n'apparaît, ou si l'autorisation écrite a été obtenue.
-- ---------------------------------------------------------------------------
CREATE TABLE photos (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  realisation_id  INT UNSIGNED NULL,
  fichier         VARCHAR(255) NOT NULL,
  alt             VARCHAR(255) NOT NULL,
  legende         VARCHAR(255) NULL,
  categorie       ENUM('chantier','laboratoire','equipement','siege') NOT NULL DEFAULT 'chantier',
  autorisation_ok TINYINT(1) NOT NULL DEFAULT 0,
  ordre           SMALLINT NOT NULL DEFAULT 0,
  CONSTRAINT fk_photo_realisation FOREIGN KEY (realisation_id) REFERENCES realisations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Prestations affichées dans « Nos prestations »
-- ---------------------------------------------------------------------------
CREATE TABLE prestations (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  secteur_id INT UNSIGNED NULL,
  titre      VARCHAR(190) NOT NULL,
  slug       VARCHAR(190) NOT NULL UNIQUE,
  resume     VARCHAR(400) NULL,
  contenu    MEDIUMTEXT NULL,
  ordre      SMALLINT NOT NULL DEFAULT 0,
  publie     TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_prestation_secteur FOREIGN KEY (secteur_id) REFERENCES secteurs(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Catalogue des essais de laboratoire
-- ---------------------------------------------------------------------------
CREATE TABLE essais (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  famille     VARCHAR(90) NOT NULL,
  designation VARCHAR(255) NOT NULL,
  norme       VARCHAR(190) NULL,
  ordre       SMALLINT NOT NULL DEFAULT 0,
  publie      TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Moyens techniques  (aucune immatriculation, aucun numéro de série)
-- ---------------------------------------------------------------------------
CREATE TABLE equipements (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  categorie   ENUM('topographie','geophysique','laboratoire','environnement','informatique','logiciel') NOT NULL,
  designation VARCHAR(190) NOT NULL,
  marque      VARCHAR(120) NULL,
  quantite    SMALLINT NULL,
  ordre       SMALLINT NOT NULL DEFAULT 0,
  publie      TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Certifications
-- ---------------------------------------------------------------------------
CREATE TABLE certifications (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  norme           VARCHAR(60) NOT NULL,
  intitule        VARCHAR(190) NOT NULL,
  organisme       VARCHAR(120) NULL,
  date_emission   DATE NULL,
  date_expiration DATE NULL,                      -- sert à l'alerte de renouvellement
  publie          TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Actualités et offres d'emploi
-- ---------------------------------------------------------------------------
CREATE TABLE actualites (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titre        VARCHAR(255) NOT NULL,
  slug         VARCHAR(255) NOT NULL UNIQUE,
  chapo        VARCHAR(400) NULL,
  contenu      MEDIUMTEXT NULL,
  image        VARCHAR(255) NULL,
  date_publication DATE NOT NULL,
  publie       TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE offres_emploi (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  intitule      VARCHAR(190) NOT NULL,
  type_contrat  VARCHAR(90) NULL,
  lieu          VARCHAR(120) NULL,
  description   MEDIUMTEXT NULL,
  date_limite   DATE NULL,
  publie        TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Messages reçus par le formulaire de contact
-- ---------------------------------------------------------------------------
CREATE TABLE messages (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nom          VARCHAR(120) NOT NULL,
  organisation VARCHAR(190) NULL,
  email        VARCHAR(190) NOT NULL,
  telephone    VARCHAR(40) NULL,
  objet        VARCHAR(190) NULL,
  message      TEXT NOT NULL,
  ip           VARBINARY(16) NULL,
  recu_le      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  traite       TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Partenaires et bailleurs affichés
-- ---------------------------------------------------------------------------
CREATE TABLE partenaires (
  id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nom    VARCHAR(150) NOT NULL,
  logo   VARCHAR(255) NULL,
  site   VARCHAR(255) NULL,
  ordre  SMALLINT NOT NULL DEFAULT 0,
  publie TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Paramètres généraux (coordonnées, textes courts)
-- ---------------------------------------------------------------------------
CREATE TABLE parametres (
  cle    VARCHAR(80) PRIMARY KEY,
  valeur TEXT NOT NULL
) ENGINE=InnoDB;

-- ============================================================================
--  Données de départ
-- ============================================================================

INSERT INTO secteurs (nom, slug, ordre) VALUES
  ('Routes et pistes', 'routes', 1),
  ('Hydraulique et AEP', 'hydraulique', 2),
  ('Bâtiment et équipements', 'batiment', 3),
  ('Géotechnique et environnement', 'geotechnique', 4);

INSERT INTO certifications (norme, intitule, date_emission, date_expiration) VALUES
  ('ISO 9001:2015',  'Management de la qualité',                      '2025-02-13', '2028-02-12'),
  ('ISO 14001:2015', 'Management environnemental',                    '2026-03-10', '2029-03-09'),
  ('ISO 45001:2018', 'Santé et sécurité au travail',                  '2026-03-10', '2029-03-09');

INSERT INTO essais (famille, designation, norme, ordre) VALUES
  ('Sols',        'Analyse granulométrique par tamisage et sédimentométrie', 'ASTM E11 · NF ISO 17892-4', 1),
  ('Sols',        'Limites d''Atterberg (liquidité, plasticité)',            'NF EN ISO 17892-12', 2),
  ('Granulats',   'Équivalent de sable et propreté des granulats',           'NF EN 933-8', 3),
  ('Béton',       'Confection, conservation et résistance à la compression', 'NF EN 12390-1/2/3 · NF P18-451', 4),
  ('Béton',       'Contrôle non destructif au scléromètre',                  NULL, 5),
  ('Chaussées',   'Portance CBR et essai Proctor',                           'NF P94-093 · NF P94-078', 6),
  ('Fondations',  'Pénétration dynamique lourde et légère, carottier SPT',   'NF EN ISO 22476-2 · NF P94-116', 7),
  ('Bitumes',     'Bille-anneau et pénétrabilité à l''aiguille',             'NF EN 1427 · NF EN 1426', 8),
  ('Hydraulique', 'Perméabilité au perméamètre',                             NULL, 9),
  ('Géophysique', 'Sondages électriques et prospection de points d''eau',    NULL, 10);

INSERT INTO parametres (cle, valeur) VALUES
  ('adresse',   'District de Tchangarey — BP 11725, Niamey, Niger'),
  ('telephone', '+227 90 53 53 23'),
  ('telephone2','+227 82 24 24 20'),
  ('email',     'contact@mygeoconsulting.com'),
  ('horaires',  'Du lundi au vendredi, 8 h – 17 h 30');

-- Compte d'administration : à créer APRÈS installation, avec un vrai mot de passe.
-- Générer le hachage en PHP :
--   php -r "echo password_hash('VotreMotDePasseSolide', PASSWORD_DEFAULT);"
-- puis :
--   INSERT INTO utilisateurs (nom, email, mot_de_passe, role)
--   VALUES ('Administrateur', 'contact@mygeoconsulting.com', '<hachage>', 'administrateur');

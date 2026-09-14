# Site GéoConsulting — prototype (version sans sous-dossiers)

Cette version ne contient **aucun dossier**. Tous les fichiers sont au même niveau.
C'est fait exprès : le glisser-déposer de dossiers vers GitHub ne fonctionne pas de
façon fiable sur tous les navigateurs, et c'est ce qui a fait échouer la première
tentative. Ici, il n'y a que des fichiers, donc l'envoi marche partout, Firefox compris.

Le CSS et le JavaScript sont intégrés directement dans chaque page HTML.

## Procédure

1. Décompresse l'archive. Tu dois voir une vingtaine de fichiers, aucun dossier.
2. Sur GitHub, dans ton dépôt : **Add file → Upload files**.
3. Ouvre le dossier décompressé, **Ctrl + A** pour tout sélectionner, puis glisse
   la sélection dans la zone d'envoi.
4. Vérifie que `.nojekyll` fait bien partie des fichiers envoyés. S'il manque,
   crée-le à la main : **Add file → Create new file**, nom exact `.nojekyll`,
   contenu vide, puis Commit.
5. **Commit changes.**
6. Settings → Pages → Source `Deploy from a branch`, branche `main`, dossier `/ (root)`.
7. Attends deux minutes, puis ouvre ton site avec **Ctrl + Maj + R**.

## Avant d'envoyer : nettoie l'ancien essai

Si des fichiers de la tentative précédente sont encore dans le dépôt, supprime-les
d'abord, en particulier `_config.yml` s'il existe (c'est lui qui fait apparaître le
thème GitHub à la place de ton style). Clique sur le fichier → icône corbeille →
Commit changes.

Les anciennes pages `.html` seront simplement écrasées par les nouvelles, pas besoin
de les supprimer.

## Contenu

| Fichier | Rôle |
|---|---|
| `index.html` | Accueil |
| `a-propos.html` | L'entreprise, organisation, engagements QSE |
| `services.html` | Prestations par domaine |
| `laboratoire.html` | Essais, normes, équipements |
| `references.html` | Références filtrables par secteur |
| `moyens.html` | Matériel et logiciels |
| `contact.html` | Coordonnées et formulaire |
| `admin.html` | Espace d'administration — identifiant `admin`, mot de passe `admin` |
| `.nojekyll` | Empêche GitHub de transformer les fichiers |
| `geoconsulting.sql` | Schéma de la base pour la future version PHP |
| `*.jpg`, `logo.png` | Images |

L'espace d'administration n'est pas dans le menu. On y accède par son adresse :
`https://ton-compte.github.io/geoconsulting-site/admin.html`

## Rappels

- **Identifiants de démonstration.** `admin` / `admin` sont écrits en clair dans
  `admin.html`. Sans conséquence ici, aucune donnée n'est derrière. Jamais en production.
- **Rien n'est enregistré.** L'administration revient à son état initial au rechargement.
- **N'ajoute pas** au dépôt les PDF sources (liste du matériel, liste du personnel) :
  ils contiennent des cartes grises, une attestation d'assurance et des noms.
  Un dépôt public est indexé par Google, et l'historique Git garde tout.

## Modifier ensuite

Clique sur un fichier dans le dépôt, puis l'icône crayon, modifie, Commit changes.
Le site se met à jour en une à deux minutes.

Pour ajouter une référence, cherche `const REFERENCES` dans `index.html`,
`references.html` et `admin.html` : recopie un bloc existant et change les valeurs.
Comme le script est intégré dans chaque page, la liste figure dans les trois fichiers —
c'est la contrepartie de cette version sans dossiers. La version PHP réglera ça
définitivement, avec une seule liste en base de données.

## Si le style ne revient pas

Ouvre `https://ton-compte.github.io/geoconsulting-site/index.html` en navigation
privée. Si la page est correcte là mais pas ailleurs, c'est le cache du navigateur.

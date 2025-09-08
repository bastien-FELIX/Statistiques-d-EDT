import controlP5.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

int NbProjets = 6;
int longeurBouton = 120;
int hauteurBouton = 120;
int totalMinutes = 0;
Bouton[] Accueil = new Bouton[NbProjets];
Bouton retourAccueil;
Salle[] classe;
groupe[] Universite;
Cours[] cours;
Date jour;
Date debutCreneau;
Date finCreneau;
StringList BUT123;
StringList GroupeDispo;
PFont myFont;
float[] t;
PImage bgImg;
boolean etage1 = false;
boolean etage2 = false;
boolean etage3 = false;
boolean creneauHeure = false;
boolean creneauJour = false;

boolean S1 = false;
boolean S3 = false;
boolean S5 = false;
String ICSD = "";
String ICSF = "";
String groupe = "S1";

boolean occSalle = false;
boolean occCreneau = false;
boolean activerCamembertCreneau = false;

//// Affichage des différentes pages
boolean afficherAccueil = true;
boolean afficherRU = false;
boolean occupationDesSalles = false;
boolean afficherExam = false;

// Variable necessaire pour controlP5
ControlP5 cp5;
//Pour Occupation des salles#

float[][] donnee;
float[] donneeCreneau;
String[] nom = {"Occupée", "Libre"};
float totalPourcentage = 100;
String heureDebut = "";
String heureFin = "";
int mois = 1;
int annees = 2025;
Bouton suivant = new Bouton();
Bouton precedent = new Bouton();


void setup() {
  size(1500, 800);
  background(255);
  textSize(32);
  myFont = createFont("windows-xp.ttf", 32);
  textFont(myFont);
  bgImg = new PImage();
  bgImg = loadImage("imgwindowsXP.jpg");
  bgImg.resize(width, height);

  cp5 = new ControlP5(this); //Initialisation ControlP5

  for (int i=0; i<NbProjets; i++) {
    Accueil[i] = new Bouton();
  }
  retourAccueil = new Bouton();
  retourAccueil.init(1376, 101, 23, 23, "");
  retourAccueil.image = loadImage("logo_accueil.png");
  retourAccueil.image.resize(23, 23);
  String[] titres = loadStrings("t.txt");
  for (int i=0; i<NbProjets; i++) {
    Accueil[i].init((width/3 - longeurBouton/2)/2 + (width/3 - longeurBouton/2)*(i%3), 100+100*(i/3)+250*(i/3), hauteurBouton, longeurBouton, titres[i]);
    PImage img = loadImage("img"+(i+1)+".png");
   
    img.resize(longeurBouton, hauteurBouton);
    Accueil[i].image = img;
  }

  //Chargement des fichiers
  chargeUniversite();
  chargeSalles();
  BUT123 = new StringList();
  chargeCoursBUT("INFO-BUT1-S1.ics", "BUT1");
  chargeCoursBUT("INFO-BUT2-S3.ics", "BUT2");
  chargeCoursBUT("INFO-BUT3-S5.ics", "BUT3");
  chargeCours();
  triCours();
  loadDonnee();
  println(totalMinutes);
  println(cours.length);

  cours[cours.length-1].afficheCours();

  dateDuJour();
  //miseAJourFuseau();
  println(fluxHeure(10, 0));
  for (int i = 0; i < classe.length; i++) {
    classe[i].affiche();
  }

  precedent.init(315, 450, 50, 180, "Precedent");
  precedent.centre = true;
  suivant.centre = true;
  suivant.init(1220, 450, 50, 150, "Suivant");

  //Modules controleP5
  cp5 = new ControlP5(this);
}



void Accueil() {
  for (int i=0; i<NbProjets; i++) {
    Accueil[i].affiche();
  }
}


// initialise les salles
void chargeSalles() {
  String [] listSalle = loadStrings("salles.csv");
  classe = new Salle[listSalle.length-1]; // car on ne prend pas en compte la primiere ligne qui n'est pas une salle
  for (int i = 1; i < listSalle.length; i++) {
    String[] elemSalle = splitTokens(listSalle[i], ";");
    classe[i-1] = new Salle();
    classe[i-1].initSalle(elemSalle[0], parseInt(elemSalle[1]), elemSalle[2], i-1);
  }
}


// Initialistation université
void chargeUniversite() {

  String[] temp = loadStrings("etudiants.csv");
  Universite = new groupe[temp.length-1];

  for (int i=0; i<temp.length-1; i++) {
    Universite[i] = new groupe();
    String[] ligne = splitTokens(temp[i+1], ";");
    String gp = ligne[0];
    int nbr = int(ligne[2]);
    float r = float(ligne[3]);
    Universite[i].init(gp, nbr, r);
  }
}
void chargeCoursBUT(String nomFichier, String niveau) {
  String charge = "";
  int cpt = 0;
  String[] edt = loadStrings(nomFichier);
  while (edt[cpt].equals("END:VCALENDAR") == false) {
    if (edt[cpt].equals("BEGIN:VEVENT") == true) {
      charge += niveau;
      charge += ";";
      cpt++;
    } else {
      if (edt[cpt].equals("END:VEVENT") == false) {
        charge += edt[cpt];
        charge += ";";
        cpt++;
      } else {
        BUT123.append(charge);
        charge = "";
        cpt++;
      }
    }
  }
}


boolean memeJour(Date d, Date e) {
  if (d.jour == e.jour && d.mois == e.mois && d.annee == e.annee) {
    return true;
  } else {
    return false;
  }
}

boolean memeHeure(Date d, Date e) {
  if (d.heure == e.heure && d.jour == e.jour && d.mois == e.mois && d.annee == e.annee) {
    return true;
  } else {
    return false;
  }
}

void dateDuJour() {
  jour = new Date();
  jour.init(year(), month(), day(), hour(), minute(), second());
}

float fluxHeure(int Heure, int min) {
  GroupeDispo = new StringList();
  float nombreTotal = 0;
  for (int i=0; i<cours.length; i++) {
    if (memeJour(cours[i].fin, jour)) {
      if ( (cours[i].debut.heure <= Heure || (cours[i].debut.heure == Heure && cours[i].debut.minute <= min))   && cours[i].fin.heure > Heure ||  (cours[i].fin.heure == Heure && cours[i].fin.minute > min)) {
        if (cours[i].groupe.length() == 2) {
          for (int j=0; j<Universite.length; j++) {
            if (Universite[j].semestre.equals(cours[i].groupe) && !(GroupeDispo.hasValue(Universite[j].sousGroupe))) {
              GroupeDispo.append(Universite[j].sousGroupe);
            }
          }
        }

        if (cours[i].groupe.length() == 4) {
          for (int j=0; j<Universite.length; j++) {
            if (Universite[j].groupe.equals(cours[i].groupe) && !(GroupeDispo.hasValue(Universite[j].sousGroupe))) {
              GroupeDispo.append(Universite[j].sousGroupe);
            }
          }
        }

        for (int j=0; j<Universite.length; j++) {
          if (Universite[j].sousGroupe == cours[i].groupe && !(GroupeDispo.hasValue(Universite[j].sousGroupe))) {
            GroupeDispo.append(Universite[j].sousGroupe);
          }
        }
      }
    }
  }
  float nbFinal = 0;
  for (int i=0; i<Universite.length; i++) {
    nombreTotal = nombreTotal + ( Universite[i].ru / 100 * Universite[i].nombre );
  }
  for (int i=0; i<Universite.length; i++) {
    if (GroupeDispo.hasValue(Universite[i].sousGroupe)) {
      nbFinal = nbFinal + ( Universite[i].ru / 100 * Universite[i].nombre );
    }
  }
  return nombreTotal - nbFinal;
}
void miseAJourFuseau() {
  for (int i=0; i<cours.length; i++) {
    if ((cours[i].debut.mois > 3 || (cours[i].debut.mois == 3 && cours[i].debut.jour >=30)) && (cours[i].debut.mois <10 || (cours[i].debut.mois == 10 && (cours[i].debut.jour >=27)))) {
      cours[i].debut.heure++;
      cours[i].fin.heure++;
    } else {
      cours[i].debut.heure = cours[i].debut.heure+2;
      cours[i].fin.heure = cours[i].fin.heure+2;
    }
  }
}

void chargeCours() {
  cours = new Cours[BUT123.size()];
  for (int i = 0; i < BUT123.size(); i++) {
    Date start = new Date();
    Date end = new Date();
    String ressource = "";
    String localisation = "";
    String groupe_classe = "";
    String professeur_cours = "";
    String[] info = splitTokens(BUT123.get(i), ";");
    for (int j = 0; j < info.length; j++) {
      String[] event = splitTokens(info[j], ":");
      if (event[0].equals("DTSTART")) {
        start.loadDate(event[1]);
      } else {
        if (event[0].equals("DTEND")) {
          end.loadDate(event[1]);
        } else {
          if (event[0].equals("SUMMARY")) {
            ressource = event[1];
          } else {
            if (event[0].equals("LOCATION")) {
              if (event.length <= 1) {
                localisation = "Pas de Salle";
              } else {
                localisation = event[1];
                int curseur = j + 1;
                String[] arret = splitTokens(info[curseur], ":");
                while (arret[0].equals("DESCRIPTION")== false) {
                  localisation = arret[0];
                  curseur++;
                  arret = splitTokens(info[curseur], ":");
                }
              }
            } else {
              if (event[0].equals("DESCRIPTION")) {
                String[] descri1 = split(event[1], "\\n");
                groupe_classe = descri1[2];
                for (int z = 3; z < descri1.length; z++) {
                  professeur_cours += descri1[z];
                  professeur_cours += " ";
                }
                if (professeur_cours.endsWith(" ")) {
                  professeur_cours = professeur_cours.substring(0, professeur_cours.length() - 1);
                }
                int curseur = j + 1;
                String[] arret = splitTokens(info[curseur], ":");
                if (arret[0].startsWith(" ")) {
                  arret[0] = arret[0].substring(1);
                }
                while (arret[0].equals("UID")== false) {
                  String[] descri = split(arret[0], "\\n");
                  for (int k = 0; k < descri.length; k++) {
                    professeur_cours += descri[k];
                    professeur_cours += " ";
                  }
                  if (professeur_cours.endsWith(" ")) {
                    professeur_cours = professeur_cours.substring(0, professeur_cours.length() - 1);
                  }
                  curseur++;
                  arret = splitTokens(info[curseur], ":");
                  if (arret[0].startsWith(" ")) {
                    arret[0] = arret[0].substring(1);
                  }
                }
                int index = professeur_cours.indexOf("(");
                professeur_cours = professeur_cours.substring(0, index);
              }
            }
          }
        }
      }
    }
    cours[i] = new Cours();
    cours[i].init(start, end, ressource, localisation, groupe_classe, professeur_cours);
  }
}

void triCours() {
  boolean recommencer = true;
  while (recommencer) {
    recommencer = false;
    Cours temp = new Cours();
    for (int i = 0; i < cours.length-1; i++) {
      if (cours[i].debut.compare(cours[i+1].debut) > 0) {
        temp = cours[i];
        cours[i] = cours[i+1];
        cours[i+1] = temp;
        recommencer = true;
      }
    }
  }
}


void afficheGraphique(float t[]) {
  t = new float[14];
  for (int i=0; i<t.length; i++) {
    t[i] = fluxHeure(9 + (i/2), 30*(i%2));
  }


  // AFFICHERRRRs
  stroke(0);
  line(100, 700, 1100, 700);
  line(100, 700, 100, 100);
  int l = 50;
  int x = 280;
  int y = 0;
  int h = 100;

  textSize(13);
  for (int i=0; i<10; i++) {
    text(i*20, 310, 700-(i*20*3));
    line(300, 700-(i*20*3), 1400, 700-(i*20*3));
  }
  stroke(50);

  for (int i=0; i<t.length; i++) {
    if (i%2==0) {
      fill(100);
      stroke(0);
    } else {
      fill(80);
      stroke(0);
    }
    x = x+l+(l/2);
    y = 700;
    h = round(t[i]*3);
    rect(x, y-h, l, h);
    stroke(255);
    fill(255);
    text((9 + (i/2) + "H" + 3*(i%2) + 0), x+5, y-10);
  }
}


void afficherFenetre() {
  float largeur = width - 100;
  float hauteur = height - 100;
  stroke(0);
  fill(200);
  rect(100, 100, largeur - 100, hauteur-100);
  fill(0, 120, 215);
  rect(100, 100, largeur - 100, 25);
  noFill();
  strokeWeight(3);
  line(300, 125, 300, hauteur);
  strokeWeight(1);
  fill(120, 120, 120);
  rect(100, 125, 200, 575);
  noFill();

  retourAccueil.affiche();
}

float calculerTauxOccupationParSalle(String nomSalle) {
  float nbOccupe = 0;
  float nbTotalCreneaux = 0;
  for (int i = 0; i < cours.length; i++) {
    Date jourCourant = cours[i].debut;
    int heureCourante = cours[i].debut.heure;
    int minuteCourante = cours[i].debut.minute;
    boolean salleTrouvee = false;
    while (i < cours.length &&
      cours[i].debut.jour == jourCourant.jour &&
      cours[i].debut.mois == jourCourant.mois &&
      cours[i].debut.annee == jourCourant.annee &&
      cours[i].debut.heure == heureCourante &&
      cours[i].debut.minute == minuteCourante) {

      if (cours[i].salle.contains(nomSalle)) {
        salleTrouvee = true;
      }
      i++;
    }
    nbTotalCreneaux++;
    if (salleTrouvee) {
      nbOccupe++;
    }
    i--;
  }
  if (nbTotalCreneaux == 0) {
    return 0;
  }
  return (nbOccupe / nbTotalCreneaux) * 100;
}

void loadDonnee() {
  if (etage1) {
    donnee = new float[8][2];
    for (int j = 0; j < 8; j++) {
      for (int k = 0; k < 2; k++) {
        switch (k % 2) {
        case 0:
          donnee[j][k] = round(calculerTauxOccupationParSalle(classe[j].nom));
          break;
        case 1:
          donnee[j][k] = 100 - round(calculerTauxOccupationParSalle(classe[j].nom));
          break;
        }
      }
    }
  } else if (etage2) {
    donnee = new float[6][2];
    for (int j = 0; j < 6; j++) {
      for (int k = 0; k < 2; k++) {
        switch (k % 2) {
        case 0:
          donnee[j][k] = round(calculerTauxOccupationParSalle(classe[j + 8].nom));  // Décalage pour l'étage 2
          break;
        case 1:
          donnee[j][k] = 100 - round(calculerTauxOccupationParSalle(classe[j + 8].nom));
          break;
        }
      }
    }
  } else if (etage3) {
    donnee = new float[2][2];
    for (int j = 0; j < 2; j++) {
      for (int k = 0; k < 2; k++) {
        switch (k % 2) {
        case 0:
          donnee[j][k] = round(calculerTauxOccupationParSalle(classe[j + 14].nom));  // Décalage pour l'étage 3
          break;
        case 1:
          donnee[j][k] = 100 - round(calculerTauxOccupationParSalle(classe[j + 14].nom));
          break;
        }
      }
    }
  }
}



void Ru() {
  afficheGraphique(t);
  textSize(32);
  fill(0);
  text("Affluence au RU le   " + jour.jour + "/" + jour.mois + "/" + jour.annee, 600, 200);
}
void controlP5Jour() {
  if (cp5.getController("Selectionner un jour") == null || cp5.getController("valider1") == null ) {
    cp5.addTextfield("Selectionner un jour")
      .setPosition(100, 150)
      .setSize(200, 30)
      .setFont(createFont("windows-xp.ttf", 20))
      .setFocus(true)// Le focus est mis automatiquement sur le champ texte
      .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
      .setColorBackground(color(220))  // Fond de la zone de texte
      .setColorForeground(color(50))
      .setColor(color(0))
      .setCaptionLabel("Entrez la date (JJ:MM:AAAA)")  // Label au-dessus de la zone de texte
      .setAutoClear(false);

    cp5.addButton("valider1")
      .setLabel("Valider")
      .setPosition(100, 205)
      .setSize(100, 30);
  }
}

void controlP5Libre() {
  if (cp5.getController("Entrez une date de début") == null || cp5.getController("Entrez une date fin") == null || cp5.getController("entrer") == null ) {
    cp5.addTextfield("Entrez une date de début")
      .setPosition(100, 150)
      .setSize(200, 30)
      .setFont(createFont("windows-xp.ttf", 20))
      .setFocus(true)// Le focus est mis automatiquement sur le champ texte
      .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
      .setColorBackground(color(220))  // Fond de la zone de texte
      .setColorForeground(color(50))
      .setColor(color(0))
      .setCaptionLabel("Entrez la date (FORMAT ICS)")  // Label au-dessus de la zone de texte
      .setAutoClear(false);

    cp5.addTextfield("Entrez une date fin")
      .setPosition(100, 250)
      .setSize(200, 30)
      .setFont(createFont("windows-xp.ttf", 20))
      .setFocus(true)// Le focus est mis automatiquement sur le champ texte
      .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
      .setColorBackground(color(220))  // Fond de la zone de texte
      .setColorForeground(color(50))
      .setColor(color(0))
      .setCaptionLabel("Entrez la date (FORMAT ICS)")  // Label au-dessus de la zone de texte
      .setAutoClear(false);

    cp5.addButton("entrer")
      .setLabel("entrer")
      .setPosition(100, 350)
      .setSize(100, 30);
  }
}

void controlP5Present() {
  if (cp5.getController("date debut present") == null || cp5.getController("date fin present") == null || cp5.getController("entrerPresent") == null) {
    cp5.addTextfield("date debut present")
        .setPosition(100, 150)
        .setSize(200, 30)
        .setFont(createFont("windows-xp.ttf", 20))
        .setFocus(true)// Le focus est mis automatiquement sur le champ texte
        .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
        .setColorBackground(color(220))  // Fond de la zone de texte
        .setColorForeground(color(50))
        .setColor(color(0))
        .setCaptionLabel("Entrez la date (FORMAT ICS)")  // Label au-dessus de la zone de texte
        .setAutoClear(false);
  
      cp5.addTextfield("date fin present")
        .setPosition(100, 250)
        .setSize(200, 30)
        .setFont(createFont("windows-xp.ttf", 20))
        .setFocus(true)// Le focus est mis automatiquement sur le champ texte
        .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
        .setColorBackground(color(220))  // Fond de la zone de texte
        .setColorForeground(color(50))
        .setColor(color(0))
        .setCaptionLabel("Entrez la date (FORMAT ICS)")  // Label au-dessus de la zone de texte
        .setAutoClear(false);
  
      cp5.addButton("entrerPresent")
        .setLabel("entrer")
        .setPosition(100, 350)
        .setSize(100, 30);
  }
}


void controlP5Groupe() {
  if (cp5.getController("groupes") == null) {
    cp5.addDropdownList("groupes")  // Nom de la liste
      .setPosition(105, 190)        // Position dans la fenêtre
      .setSize(190, 300)            // Taille de la liste
      .setHeight(500)
      .addItem("S1", 0)        // Ajout des choix à la liste
      .addItem("S3", 1)
      .addItem("S5", 2)
      .setLabel("Choisir un groupe")
      .close()  // Ferme la DropdownList immédiatement après sa création
      .onChange(new CallbackListener() {  // Utilisation de CallbackListener
      public void controlEvent(CallbackEvent e) {
        // Réinitialisation des variables
        S1 = false;
        S3 = false;
        S5 = false;

        // Modifie les variables selon le choix
        int selectedIndex = (int) e.getController().getValue();
        if (selectedIndex == 0) {
          S1 = true;
        } else if (selectedIndex == 1) {
          S3 = true;
        } else if (selectedIndex == 2) {
          S5 = true;
        } else if (selectedIndex == 3) {
          S1 = false;
          S3 = false;
          S5 = false;
        }
      }
    }
    );
  }
}

void valider1() {
  String date = cp5.get(Textfield.class, "Selectionner un jour").getText();
  chargeDate(date);
}

void entrer() {
  ICSD = cp5.get(Textfield.class, "Entrez une date de début").getText();
  ICSF = cp5.get(Textfield.class, "Entrez une date fin").getText();
  sallesDispoUI(ICSD, ICSF);
}

void entrerPresent() {
  ICSD = cp5.get(Textfield.class, "date debut present").getText();
  ICSF = cp5.get(Textfield.class, "date fin present").getText();
  etudiantsPresentUI(ICSD, ICSF);
}


void chargeDate(String date) {
  String[] tabDate = splitTokens(date, ":");
  if (tabDate.length != 3) {
    println("Erreur de format. Veuillez écrire la date correctement.");
    return;
  }
  int j = parseInt(tabDate[0]);
  int m = parseInt(tabDate[1]);
  int a = parseInt(tabDate[2]);
  jour.init(a, m, j, 0, 0, 0);
}

void exam() {
  if (S1 == true) {
    groupe = "S1";
  }
  if (S3 == true) {
    groupe = "S3";
  }
  if (S5 == true) {
    groupe = "S5";
  }
  stroke(0);
  fill(0);
  String[] m = loadStrings("mois.txt");


  stroke(0);
  textSize(35);
  precedent.affiche();
  suivant.affiche();
  text("Prochains examens pour "+ groupe, 630, 170);
  text(m[mois-1], 310, 160);
  afficherTableau(groupe, mois);
  controlP5Groupe();
}


void afficherTableau(String groupe, int mois) {

  stroke(0);
  noFill();
  int longueurT = 700;
  int hauteurT = 500;
  rect(500, 200, longueurT, hauteurT);
  Date lendemain = new Date();
  Date jour = new Date();
  jour.init(annees, mois, 1, 0, 0, 0);
  lendemain.init(annees, mois, jour.jour, jour.heure, jour.minute, jour.seconde);
  lendemain.heure = 23;

  int[] nbjours = new int[31];
  for (int i=0; i<nbjours.length; i++) {
    nbjours[i]=0;
    for (int j=0; j<cours.length; j++) {

      if (cours[j].debut.compare(jour)>0 && cours[j].fin.compare(lendemain)<0  && cours[j].groupe.equals(groupe) && estDs(cours[j])) {
        nbjours[i]  = 1;
      }
    }
    jour.jour++;
    lendemain.jour++;
  }
  for (int i=0; i<nbjours.length; i++) {
    if (nbjours[i]==1) {
      stroke(0);
      textSize(30);
      fill(0);
      text("DS", 500+(i%7)*100, 240+100*(i/7));
      fill(255, 0, 0);
    } else {
      stroke(0);
      noFill();
    }
    rect(500+(i%7)*100, 200+100*(i/7), 100, 100);
    fill(0);
    textSize(20);
    text("" +(i+1), 500+(i%7)*100, 220+100*(i/7));
  }
}


boolean estDs(Cours cours) {
  String[] t = splitTokens(cours.matiere, " ");
  for (int i=0; i<t.length; i++) {
    if (t[i].equals("(DS)") || t[i].equals("")) {
      return true;
    }
  }
  return false;
}

void occupation() {
  background(255);
  image(bgImg, 0, 0, width, height);
  //afficherOccupationSalles();
  afficherFenetre();
}

void controlP5Creneau() {
  if (creneauHeure) {
    if (cp5.getController("Heure de début du créneau") == null || cp5.getController("Heure de fin du créneau") == null) {
      cp5.addTextfield("Heure de début du créneau")
        .setPosition(320, 150)
        .setSize(500, 30)
        .setFont(createFont("windows-xp.ttf", 20))
        .setFocus(true)// Le focus est mis automatiquement sur le champ texte
        .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
        .setColorBackground(color(220))  // Fond de la zone de texte
        .setColorForeground(color(50))
        .setColor(color(0))
        .setCaptionLabel("Entrez l'heure (HH:MM:SS)")  // Label au-dessus de la zone de texte
        .setAutoClear(false);

      cp5.addTextfield("Heure de fin du créneau")
        .setPosition(875, 150)
        .setSize(500, 30)
        .setFont(createFont("windows-xp.ttf", 20))
        .setFocus(true)  // Le focus est mis automatiquement sur le champ texte
        .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
        .setColorBackground(color(220))  // Fond de la zone de texte
        .setColorForeground(color(50))
        .setColor(color(0))
        .setCaptionLabel("Entrez l'heure (HH:MM:SS)")  // Label au-dessus de la zone de texte
        .setAutoClear(false);
    }
  } else {
    if (creneauJour) {
      if (cp5.getController("Jour de début du créneau") == null || cp5.getController("Jour de fin du créneau") == null) {

        cp5.addTextfield("Jour de début du créneau")
          .setPosition(320, 150)
          .setSize(500, 30)
          .setFont(createFont("windows-xp.ttf", 20))
          .setFocus(true)// Le focus est mis automatiquement sur le champ texte
          .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
          .setColorBackground(color(220))  // Fond de la zone de texte
          .setColorForeground(color(50))
          .setColor(color(0))
          .setCaptionLabel("Entrez le jour (JJ/MM/AAAA)")  // Label au-dessus de la zone de texte
          .setAutoClear(false);

        cp5.addTextfield("Jour de fin du créneau")
          .setPosition(875, 150)
          .setSize(500, 30)
          .setFont(createFont("windows-xp.ttf", 20))
          .setFocus(true)  // Le focus est mis automatiquement sur le champ texte
          .setColor(color(0, 0, 255))  // Change la couleur du texte (bleu)
          .setColorBackground(color(220))  // Fond de la zone de texte
          .setColorForeground(color(50))
          .setColor(color(0))
          .setCaptionLabel("Entrez le jour (JJ/MM/AAAA)")  // Label au-dessus de la zone de texte
          .setAutoClear(false);
      }
    }
  }
  if (cp5.getController("valider") == null || cp5.getController("salleCreneau") == null) {
    cp5.addButton("valider")
      .setLabel("Valider")
      .setPosition(650, 650)
      .setSize(400, 40);
    DropdownList salleCreneau = cp5.addDropdownList("salleCreneau")  // Nom de la liste
        .setPosition(305, 275)        // Position dans la fenêtre
        .setSize(1090, 300)            // Taille de la liste
        .setHeight(500)
        .setLabel("Choisir une salle");
      for (int i = 0; i < classe.length; i++) {
        salleCreneau.addItem(classe[i].nom, i); // Ajouter chaque élément de 'classe'
      }        // Ajout des choix à la liste
      salleCreneau.close();
  }
}



void valider() {
  if(cp5.getController("reset") == null){
  cp5.addButton("reset")
        .setLabel("Reset")
        .setPosition(650, 650)
        .setSize(400, 40);
  }
  if (creneauHeure) {
    String heureDebut = cp5.get(Textfield.class, "Heure de début du créneau").getText();
    String heureFin = cp5.get(Textfield.class, "Heure de fin du créneau").getText();
    println(heureDebut, heureFin);
    cp5.get(Textfield.class, "Heure de début du créneau").clear();
    cp5.get(Textfield.class, "Heure de fin du créneau").clear();
    chargeHeure(heureDebut, heureFin);
    int selectedIndex = (int) cp5.get(DropdownList.class, "salleCreneau").getValue();
    String salleSelectionnee = classe[selectedIndex].nom;
    float tauxOccupation = calculCreneau(salleSelectionnee, debutCreneau, finCreneau);
    cp5.get(Textfield.class, "Heure de début du créneau").hide();
    cp5.get(Textfield.class, "Heure de fin du créneau").hide();
    cp5.get(DropdownList.class, "salleCreneau").hide();
    cp5.get(Button.class, "valider").hide();
    donneeCreneau = new float[2];
    donneeCreneau[0] = tauxOccupation;
    donneeCreneau[1] = 100 - tauxOccupation;
    dessineCamembert(850, 400, donneeCreneau, 200);
    activerCamembertCreneau = true;
    if (cp5.getController("label1") == null) {
      cp5.addTextlabel("label1")
        .setText("Occupation de le salle: "+salleSelectionnee+" pour le créneau: "+ heureDebut+" - "+heureFin)
        .setPosition(305, 130) // Position du texte
        .setColor(color(0, 0, 0)) // Couleur du texte (bleu)
        .setFont(createFont("windows-xp.ttf", 20)); // Police du texte
    }
    cp5.get(Textlabel.class, "label1").show();
  } else {
    if (creneauJour) {
      String jourDebut = cp5.get(Textfield.class, "Jour de début du créneau").getText();
      String jourFin = cp5.get(Textfield.class, "Jour de fin du créneau").getText();
      chargeJour(jourDebut, jourFin);
      int selectedIndex = (int) cp5.get(DropdownList.class, "salleCreneau").getValue();
      String salleSelectionnee = classe[selectedIndex].nom;
      float tauxOccupation = calculCreneau(salleSelectionnee, debutCreneau, finCreneau);
      cp5.get(Textfield.class, "Jour de début du créneau").hide();
      cp5.get(Textfield.class, "Jour de fin du créneau").hide();
      cp5.get(DropdownList.class, "salleCreneau").hide();
      cp5.get(Button.class, "valider").hide();
      donneeCreneau = new float[2];
      donneeCreneau[0] = tauxOccupation;
      donneeCreneau[1] = 100 - tauxOccupation;
      dessineCamembert(850, 400, donneeCreneau, 200);
      activerCamembertCreneau = true;
      if (cp5.getController("label1") == null) {
        cp5.addTextlabel("label1")
          .setText("Occupation de le salle: "+salleSelectionnee+" pour le créneau: "+ jourDebut+" - "+jourFin)
          .setPosition(305, 130) // Position du texte
          .setColor(color(0, 0, 0)) // Couleur du texte (bleu)
          .setFont(createFont("windows-xp.ttf", 20)); // Police du texte
      }
      cp5.get(Textlabel.class, "label1").show();
    }
  }
    cp5.get(Button.class, "reset").show();
}

  

void reset() {
  controlP5Occupation();
  activerCamembertCreneau = false;
  if(creneauHeure){
    cp5.get(Textfield.class, "Heure de début du créneau").show();
    cp5.get(Textfield.class, "Heure de fin du créneau").show();
    cp5.get(DropdownList.class, "salleCreneau").show();
    cp5.get(Button.class, "valider").show();
    cp5.remove("label1");
    cp5.get(Button.class, "reset").hide();
  }else{
    if(creneauJour){
      cp5.get(Textfield.class, "Jour de début du créneau").show();
      cp5.get(Textfield.class, "Jour de fin du créneau").show();
      cp5.get(DropdownList.class, "salleCreneau").show();
      cp5.get(Button.class, "valider").show();
      cp5.remove("label1");
      cp5.get(Button.class, "reset").hide();
    }
  } 
}


void chargeHeure(String debut, String fin) {
  String[] tabDebut = splitTokens(debut, ":");
  String[] tabFin = splitTokens(fin, ":");
  if (tabDebut.length != 3 || tabFin.length != 3) {
    println("Erreur de format pour les heures.");
    return;
  }
  int hd = parseInt(tabDebut[0]);
  int md = parseInt(tabDebut[1]);
  int sd = parseInt(tabDebut[2]);
  int hf = parseInt(tabFin[0]);
  int mf = parseInt(tabFin[1]);
  int sf = parseInt(tabFin[2]);
  debutCreneau = new Date();
  debutCreneau.init(0, 0, 0, hd, md, sd);
  finCreneau = new Date();
  finCreneau.init(0, 0, 0, hf, mf, sf);
}

void chargeJour(String debut, String fin) {
  String[] tabDebut = splitTokens(debut, "/");
  String[] tabFin = splitTokens(fin, "/");
  if (tabDebut.length != 3 || tabFin.length != 3) {
    println("Erreur de format pour les heures.");
    return;
  }
  int jd = parseInt(tabDebut[0]);
  int md = parseInt(tabDebut[1]);
  int ad = parseInt(tabDebut[2]);
  int jf = parseInt(tabFin[0]);
  int mf = parseInt(tabFin[1]);
  int af = parseInt(tabFin[2]);
  debutCreneau = new Date();
  debutCreneau.init(ad, md, jd, 0, 0, 0);
  finCreneau = new Date();
  debutCreneau.init(af, mf, jf, 0, 0, 0);
}


float calculCreneau(String salle, Date debut, Date fin) {
  int nbTotalCreneau = 0;   
  int nbCreneauSalle = 0; 
  if (creneauHeure) {
    for (int i = 0; i < cours.length; i++) {
      boolean chevauchement = (cours[i].debut.compare(fin) <= 0) && (cours[i].fin.compare(debut) >= 0);    
      if (chevauchement && (cours[i].debut.mois >= 9 || cours[i].debut.mois == 0)) {
        if (cours[i].salle.contains(salle)) {
          nbCreneauSalle++;
        }
      }
    }    
    if (nbTotalCreneau == 0) {
      return 0;
    }
  } else if (creneauJour) {
    for (int i = 0; i < cours.length; i++) {
      boolean chevauchement = (cours[i].debut.compare(fin) <= 0) && (cours[i].fin.compare(debut) >= 0);
      if (chevauchement && (cours[i].debut.mois >= 9 || cours[i].debut.mois == 0)) {
        nbTotalCreneau++; 
        if (cours[i].salle.contains(salle)) {
          nbCreneauSalle++;
        }
      }
    }
  }
  if (nbTotalCreneau == 0) {
    return 0;  
  }
  return round((float) nbCreneauSalle / nbTotalCreneau * 100);
}




void controlP5Occupation() {
  if (cp5.getController("Jour") == null || cp5.getController("heure") == null) {
    cp5.addToggle("Jour")  // Nom du bouton
      .setPosition(113, 300)   // Position dans la fenêtre
      .setSize(75, 30)       // Taille du bouton
      .setLabel("jour")    // Label du bouton
      .setValue(etage1 ? 1 : 0)  // Initialiser à la valeur actuelle de etage1
      .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        if (e.getController().getValue() == 1) {  // Si le bouton "Etage 1" est activé
          creneauJour = true;
          creneauHeure = false;  // Désactiver l'autre bouton "Etage 2"
          cp5.getController("heure").setValue(0);
          cp5.remove("Heure de début du créneau");
          cp5.remove("Heure de fin du créneau");
        } else {  // Si le bouton "Etage 1" est désactivé
          creneauJour = false;
        }
      }
    }
    );

    cp5.addToggle("heure")  // Nom du bouton
      .setPosition(210, 300)  // Position dans la fenêtre
      .setSize(75, 30)       // Taille du bouton
      .setLabel("heure")    // Label du bouton
      .setValue(etage2 ? 1 : 0)  // Initialiser à la valeur actuelle de etage2
      .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        if (e.getController().getValue() == 1) {  // Si le bouton "Etage 2" est activé
          creneauHeure = true;
          creneauJour = false;  // Désactiver l'autre bouton "Etage 1"
          cp5.getController("Jour").setValue(0); // Désactiver l'état du bouton "Etage 1"
          cp5.remove("Jour de début du créneau");
          cp5.remove("Jour de fin du créneau");
        } else {  // Si le bouton "Etage 2" est désactivé
          creneauHeure = false;
        }
      }
    }
    );
  }
  if (cp5.getController("Salle") == null || cp5.getController("Creneau horaire") == null) {
    cp5.addToggle("Salle")  // Nom du bouton
      .setPosition(113, 130)   // Position dans la fenêtre
      .setSize(75, 30)       // Taille du bouton
      .setLabel("Salle")    // Label du bouton
      .setValue(etage1 ? 1 : 0)  // Initialiser à la valeur actuelle de etage1
      .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        if (e.getController().getValue() == 1) {  // Si le bouton "Etage 1" est activé
          occSalle = true;
          occCreneau = false;  // Désactiver l'autre bouton "Etage 2"
          cp5.getController("Creneau horaire").setValue(0);
          cp5.remove("Heure de début du créneau");
          cp5.remove("Heure de fin du créneau");
          cp5.remove("valider");
          cp5.remove("salleCreneau");
          cp5.remove("label1");
          cp5.remove("reset");
          if(creneauJour){
            cp5.remove("Jour de début du créneau");
            cp5.remove("Jour de fin du créneau");
          }else{
            if(creneauHeure){
              cp5.remove("Heure de début du créneau");
              cp5.remove("Heure de fin du créneau");
            }
          }
        } else {  // Si le bouton "Etage 1" est désactivé
          occSalle = false;
        }
      }
    }
    );

    // Création du bouton pour l'Etage 2
    cp5.addToggle("Creneau horaire")  // Nom du bouton
      .setPosition(210, 130)  // Position dans la fenêtre
      .setSize(75, 30)       // Taille du bouton
      .setLabel("creneau horaire")    // Label du bouton
      .setValue(etage2 ? 1 : 0)  // Initialiser à la valeur actuelle de etage2
      .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        if (e.getController().getValue() == 1) {  // Si le bouton "Etage 2" est activé
          occCreneau = true;
          occSalle = false;  // Désactiver l'autre bouton "Etage 1"
          cp5.getController("Salle").setValue(0); // Désactiver l'état du bouton "Etage 1"
        } else {  // Si le bouton "Etage 2" est désactivé
          occCreneau = false;
        }
      }
    }
    );
  }
  if (cp5.getController("etages") == null) {
    cp5.addDropdownList("etages")  // Nom de la liste
      .setPosition(105, 190)        // Position dans la fenêtre
      .setSize(190, 300)            // Taille de la liste
      .setHeight(500)
      .addItem("Etage 1", 0)        // Ajout des choix à la liste
      .addItem("Etage 2", 1)
      .addItem("Etage 3", 2)
      .addItem(" ", 3)
      .setLabel("Choisir un étage")
      .close()  // Ferme la DropdownList immédiatement après sa création
      .onChange(new CallbackListener() {  // Utilisation de CallbackListener
      public void controlEvent(CallbackEvent e) {
        // Réinitialisation des variables
        etage1 = false;
        etage2 = false;
        etage3 = false;

        // Modifie les variables selon le choix
        int selectedIndex = (int) e.getController().getValue();
        if (selectedIndex == 0) {
          etage1 = true;
        } else if (selectedIndex == 1) {
          etage2 = true;
        } else if (selectedIndex == 2) {
          etage3 = true;
        } else if (selectedIndex == 3) {
          etage1 = false;
          etage2 = false;
          etage3 = false;
        }
      }
    }
    );
  }
  //textSize(10);
  //fill(0);
  //text("Choisir un etage", 105, 140);
}


void etage1Occupation() {
  StringList nomSalle = new StringList();
  for (int i = 0; i < classe.length; i++) {
    if (i <= 7 && classe[i].id == i) {
      nomSalle.append(classe[i].nom);
    }
  }
  line(300, height/2, 1400, height/2);
  line(575, 125, 575, height-100);
  line(850, 125, 850, height-100);
  line(1125, 125, 1125, height-100);
  for (int i = 0; i < nomSalle.size(); i++) {
    switch(i) {
    case 0:
      text(nomSalle.get(i), 375, 150);
      break;
    case 1:
      text(nomSalle.get(i), 650, 150);
      break;
    case 2:
      text(nomSalle.get(i), 925, 150);
      break;
    case 3:
      text(nomSalle.get(i), 1200, 150);
      break;
    case 4:
      text(nomSalle.get(i), 375, height/2+25);
      break;
    case 5:
      text(nomSalle.get(i), 650, height/2+25);
      break;
    case 6:
      text(nomSalle.get(i), 925, height/2+25);
      break;
    case 7:
      text(nomSalle.get(i), 1200, height/2+25);
      break;
    }
  }
}




void etage2Occupation() {
  StringList nomSalle = new StringList();
  for (int i = 8; i < classe.length; i++) {
    if (i <= 13 && classe[i].id == i) {
      nomSalle.append(classe[i].nom);
    }
  }
  line(300, height/2, 1400, height/2);
  line(666, 125, 666, height-100);
  line(1032, 125, 1032, height-100);
  for (int i = 0; i < nomSalle.size(); i++) {
    switch(i) {
    case 0:
      text(nomSalle.get(i), 430, 150);
      break;
    case 1:
      text(nomSalle.get(i), 799, 150);
      break;
    case 2:
      text(nomSalle.get(i), 1165, 150);
      break;
    case 3:
      text(nomSalle.get(i), 430, height/2+25);
      break;
    case 4:
      text(nomSalle.get(i), 799, height/2+25);
      break;
    case 5:
      text(nomSalle.get(i), 1165, height/2+25);
      break;
    }
  }
}

void etage3Occupation() {
  StringList nomSalle = new StringList();
  for (int i = 14; i < classe.length; i++) {
    if (i > 13 && classe[i].id == i) {
      nomSalle.append(classe[i].nom);
    }
  }
  line(850, 125, 850, height-100);
  for (int i = 0; i < nomSalle.size(); i++) {
    switch(i) {
    case 0:
      text(nomSalle.get(i), 520, 150);
      break;
    case 1:
      text(nomSalle.get(i), 1070, 150);
      break;
    }
  }
}

void afficherCamemberts() {
  float rayon = 0;
  float espacement = 0;
  float espacementX = 0;
  float espacementY = 0;
  int colonnes = 0;
  int rangee = 0;
  float Xdepart;
  float Ydepart;
  if (etage1) {
    loadDonnee();
    colonnes = 4;
    rangee = 2;
    rayon = 100;
    espacement = 75;
    Xdepart = 438;
    Ydepart = 269;
    for (int i = 0; i < colonnes*rangee; i++) {
      int col = i%colonnes;
      int row = i/colonnes;
      float x = Xdepart + col * (rayon * 2 + espacement);
      float y = Ydepart + row * (rayon * 2 + espacement);
      dessineCamembert(x, y, donnee[i], rayon);
    }
  } else {
    if (etage2) {
      loadDonnee();
      colonnes = 3;
      rangee = 2;
      rayon = 100;
      espacementX = 165;
      espacementY = 85;
      Xdepart = 483;
      Ydepart = 269;
      for (int i = 0; i < colonnes*rangee; i++) {
        int col = i%colonnes;
        int row = i/colonnes;
        float x = Xdepart + col * (rayon * 2 + espacementX);
        float y = Ydepart + row * (rayon * 2 + espacementY);
        dessineCamembert(x, y, donnee[i], rayon);
      }
    } else {
      if (etage3) {
        loadDonnee();
        colonnes = 2;
        rangee = 1;
        rayon = 200;
        espacementX = 150;
        espacementY = 85;
        Xdepart = 575;
        Ydepart = 413;
        for (int i = 0; i < colonnes*rangee; i++) {
          int col = i%colonnes;
          int row = i/colonnes;
          float x = Xdepart + col * (rayon * 2 + espacementX);
          float y = Ydepart + row * (rayon * 2 + espacementY);
          dessineCamembert(x, y, donnee[i], rayon);
        }
      }
    }
  }
}

color couleurPourIndex(int i) {
  color[] colors = {
    color(230, 100, 100),
    color(100, 200, 100),
  };
  return colors[i % colors.length];  // Pour que les couleurs se répètent si nécessaire
}

void dessineCamembert(float x, float y, float[] donnee, float rayon) {
  float total = 0;
  for (int i = 0; i < donnee.length; i++) {
    total += donnee[i];
  }
  float angleDepart = -HALF_PI;
  for (int i = 0; i < donnee.length; i++) {
    float angle = map(donnee[i], 0, total, 0, TWO_PI);
    fill(couleurPourIndex(i));
    arc(x, y, rayon*2, rayon*2, angleDepart, angleDepart + angle);
    angleDepart += angle;
  }
  angleDepart = -HALF_PI;
  for (int i = 0; i < donnee.length; i++) {
    float angle = map(donnee[i], 0, total, 0, TWO_PI);
    float nomAngle = angleDepart + angle / 2;
    float nomX = x + cos(nomAngle) * rayon * 0.7;
    float nomY = y + sin(nomAngle) * rayon * 0.7;

    fill(0);
    textSize(12);
    textAlign(CENTER, CENTER);
    text(nom[i] + ": " + donnee[i] + "%", nomX, nomY);

    angleDepart += angle;
  }
}






void draw() {
  //background(255);

  if (afficherAccueil) {
    image(bgImg, 0, 0, width, height);
    Accueil();
    for (int i=0; i<NbProjets; i++) {
      if (mouseX > Accueil[i].x && mouseX < (Accueil[i].x + longeurBouton) && mouseY > Accueil[i].y && mouseY < (Accueil[i].y + hauteurBouton)) {
        Accueil[i].noir = true;
      } else {
        Accueil[i].noir = false;
      }
    }
  } else {
    if (mouseX > retourAccueil.x && mouseX < (retourAccueil.x + retourAccueil.largeur) && mouseY > retourAccueil.y && mouseY < (retourAccueil.y + retourAccueil.hauteur)) {
      retourAccueil.noir = true;
    } else {
      retourAccueil.noir = false;
    }
  }
  if (afficherRU) {
    image(bgImg, 0, 0, width, height);
    afficherFenetre();
    Ru();
    controlP5Jour();
    retourAccueil.affiche();
  }
  if (afficherExam) {
    image(bgImg, 0, 0, width, height);
    if ((mouseX > suivant.x && mouseX < suivant.x + suivant.largeur) && mouseY > suivant.y && mouseY < (suivant.y + suivant.hauteur)) {
      suivant.noir = true;
    } else {
      suivant.noir = false;
    }

    if ((mouseX > precedent.x && mouseX < precedent.x + precedent.largeur) && mouseY > precedent.y && mouseY < (precedent.y + precedent.hauteur)) {
      precedent.noir = true;
    } else {
      precedent.noir = false;
    }
    afficherFenetre();
    exam();
  }


  if (occupationDesSalles) {
    stroke(0);
    occupation();
    controlP5Occupation();
    if (occSalle) {
      if (etage1) {
        occupation();
        etage1Occupation();
        afficherCamemberts();
        controlP5Occupation();
      } else {
        if (etage2) {
          occupation();
          etage2Occupation();
          afficherCamemberts();
          controlP5Occupation();
        } else {
          if (etage3) {
            occupation();
            etage3Occupation();
            afficherCamemberts();
            controlP5Occupation();
          }
        }
      }
    } else {
      if (occCreneau) {
        controlP5Creneau();
        if (activerCamembertCreneau) {
          dessineCamembert(850, 400, donneeCreneau, 200);
        }
      }
    }
  }
}
void mousePressed() {
  if (afficherAccueil) {
    if (mouseX > Accueil[0].x && mouseX < (Accueil[0].x + longeurBouton) && mouseY > Accueil[0].y && mouseY < (Accueil[0].y + hauteurBouton)) {
      afficherAccueil = false;
      afficherRU = true;
    }

    if (mouseX > Accueil[1].x && mouseX < (Accueil[1].x + longeurBouton) && mouseY > Accueil[1].y && mouseY < (Accueil[1].y + hauteurBouton)) {
      afficherAccueil = false;
      sallesDispoUI(ICSD, ICSF);
    }

    if (mouseX > Accueil[3].x && mouseX < (Accueil[3].x + longeurBouton) && mouseY > Accueil[3].y && mouseY < (Accueil[3].y + hauteurBouton)) {
      afficherAccueil = false;
      etudiantsPresentUI(ICSD, ICSF);
    }

    if (Accueil.length > 4 && mouseX > Accueil[4].x && mouseX < (Accueil[4].x + longeurBouton) && mouseY > Accueil[4].y && mouseY < (Accueil[4].y + hauteurBouton)) {
      afficherAccueil = false;
      afficherExam=true;
    }

    if (Accueil.length > 5 && mouseX > Accueil[5].x && mouseX < (Accueil[5].x + longeurBouton) && mouseY > Accueil[5].y && mouseY < (Accueil[5].y + hauteurBouton)) {
      afficherAccueil = false;
      occupationDesSalles = true;
    }
  } else {
    if (mouseX > retourAccueil.x && mouseX < (retourAccueil.x + retourAccueil.largeur) && mouseY > retourAccueil.y && mouseY < (retourAccueil.y + retourAccueil.hauteur)) {
      afficherAccueil = true;
      afficherRU = false;
      occupationDesSalles = false;
      afficherExam = false;
      cp5.remove("etages");
      cp5.remove("Salle");
      cp5.remove("valider");
      cp5.remove("valider1");
      cp5.remove("Selectionner un jour");
      cp5.remove("Creneau horaire");
      cp5.remove("groupes");
      cp5.remove("Entrez une date");
      cp5.remove("Entrez une date de début");
      cp5.remove("Entrez une date fin");
      cp5.remove("Heure de début du créneau");
      cp5.remove("Heure de fin du créneau");
      cp5.remove("entrer");
      cp5.remove("salleCreneau");
      cp5.remove("label1");
      cp5.remove("reset");
      cp5.remove("Jour de début du créneau");
      cp5.remove("Jour de fin du créneau");
      cp5.remove("Jour");
      cp5.remove("heure");
      cp5.remove("date debut present");
      cp5.remove("date fin present");
      cp5.remove("entrerPresent");
      textSize(32);
      textAlign(CORNER);
      ICSF = "";
      ICSD = "";

    }
  }
  if (afficherExam) {
    if ((mouseX > precedent.x && mouseX < precedent.x + precedent.largeur) && mouseY > precedent.y && mouseY < (precedent.y + precedent.hauteur )) {

      if (mois>1) {
        mois--;
        println(mois);
      } else {
        mois = 12;
        annees--;
      }
    }
    if ((mouseX > suivant.x && mouseX < suivant.x + suivant.largeur) && mouseY > suivant.y && mouseY < (suivant.y + suivant.hauteur)) {
      if (mois == 12) {
        mois = 0;
        annees++;
      }

      mois++;
      println(mois);
    }
  }
}

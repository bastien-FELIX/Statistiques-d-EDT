class Date {
  int annee, mois, jour;
  int heure, minute, seconde;

  void init (int a, int mo, int j, int h, int min, int s) {
    annee = a;
    mois = mo;
    jour = j;
    heure = h;
    minute  = min;
    seconde = s;
  }

  void loadDate (String date) {
    if (!date.equals("")) {
      annee = int(date.charAt(0) - '0') * 1000 + int(date.charAt(1) - '0') * 100 + int(date.charAt(2) - '0') * 10 + int(date.charAt(3) - '0');
      mois = int(date.charAt(4) - '0') * 10 + int(date.charAt(5) - '0');
      jour = int(date.charAt(6) - '0') * 10 + int(date.charAt(7) - '0');
  
      heure = int(date.charAt(9) - '0') * 10 + int(date.charAt(10) - '0');
      minute = int(date.charAt(11) - '0') * 10 + int(date.charAt(12) - '0');
      seconde = int(date.charAt(13) - '0') * 10 + int(date.charAt(14) - '0');
      
      // ajout un décalage d'une ou deux heure(s) pour ajuster au fuseau horaire
      if (mois > 10 || mois == 10 && jour >= 27 || mois < 3 || mois == 4 && jour <= 29) {
        this.ajouterHeure(1);
      } else {
        this.ajouterHeure(2);
      }
      
    } else {
      this.init(year(), month(), day(), hour(), minute(), second());
    }
  }
  
  String dateToIcs(Date convertir){
    String res = "";
    res += convertir.annee;
    if(convertir.mois <= 10){
      res += "0";
      res += convertir.mois;
    }else{
      res += convertir.mois;
    }
    if(convertir.jour <= 10){
      res += "0";
      res += convertir.jour;
    }else{
      res += convertir.jour;
    }
    res += "T";
    if(convertir.heure <= 10){
      res += "0";
      res += convertir.heure;
    }else{
      res += convertir.heure;
    }
    if(convertir.minute <= 10){
      res += "0";
      res += convertir.minute;
    }else{
      res += convertir.minute;
    }
    if(convertir.seconde <= 10){
      res += "0";
      res += convertir.seconde;
    }else{
      res += convertir.seconde;
    }
    res += "Z";
    return res;
    
    
    
  }
      
  // pour les fuseaux horraires
  void ajouterHeure(int h) {
    heure += h;

    if (heure > 24) {
      heure = heure % 24;
      jour++;
    }
  }

  void affiche () {
    println(jour + "/" + mois + "/" + annee + " " + heure + ":" + minute + ":" + seconde);
  }
  
  String afficheStr() {
    return jour + "/" + mois + "/" + annee + " " + heure + ":" + minute + ":" + seconde;
  }


  int compare (Date d) {
    // calcule le nombre total de secondes
    int totalSecSelf = annee * 31557600 + mois * 2629800 + jour * 86400 + heure * 3600 + minute * 60 + seconde;
    int totalSecAutre = d.annee * 31557600 + d.mois * 2629800 + d.jour * 86400 + d.heure * 3600 + d.minute * 60 + d.seconde;

    // résultat positif : self est après d
    // résultat négatif : self est avant d
    // résultat égal à 0 : self est en même temps que d
    return totalSecSelf - totalSecAutre;
  }
  int diffEnMinutes(Date d) {
  // Calcule la différence en secondes entre les deux dates
  int diffSec = this.compare(d);
  
  // Convertir les secondes en minutes
  return diffSec / 60;
  }

}



// le 1er créneau va de a1 à a2 et le second de b1 à b2
// renvoie true si les deux créneaux sont sur les mêmes horaires, renvoie false sinon
  
boolean compareCreneaux (Date a1, Date a2, Date b1, Date b2) {
  if (a1.compare(b2) < 0 && b1.compare(a2) < 0) {
    return true;
  } else {
    return false;
  }
}

StringList sallesDispo(Date debut, Date fin) {
  boolean sallesDispo[] = new boolean[classe.length];
  StringList strList = new StringList();
  StringList resultat  = new StringList();

  for (int i = 0; i < sallesDispo.length; i++) {
    sallesDispo[i] = true; // par défaut la salle est disponible
  }

  // ajoute le nom de toute les salles occupés sur le même créneau, les autres salles sont donc disponibles
  for (int i = 0; i < cours.length; i++) {
    if (compareCreneaux(debut, fin, cours[i].debut, cours[i].fin)) {
      String[] tab = split(cours[i].salle, "\\,");
      
      for (int j = 0; j < tab.length; j++) {
        strList.append(tab[j]);
      }
    }
  }

  // parcourt la liste du nom toutes les salles non disponibles
  // pour mettre à jour la liste de disponibilité des salles
  for (int i = 0; i < strList.size(); i++) {
    for (int j = 0; j < classe.length; j++) {
      if (strList.get(i).equals(classe[j].nom)) {
        sallesDispo[classe[j].id] = false;
      }
    }
  }


  for (int i = 0; i < sallesDispo.length; i++) {
    if (sallesDispo[i]) {
      if (classe[i].informatique) {
        resultat.append(classe[i].nom + "   (salle informatique)");
      } else {
        resultat.append(classe[i].nom);
      }
    }
  }

  return resultat;
}

void afficheStringList(StringList strList) {
  for (int i = 0; i < strList.size(); i++) {
    text(strList.get(i), 320, (i+1) * 30 + 185);
  }
}

void sallesDispoUI(String d, String f) {
  Date d1 = new Date();
  Date d2 = new Date();
  controlP5Libre();
  d1.loadDate(d);
  d2.loadDate(f);
  
  image(bgImg, 0, 0, width, height);
  afficherFenetre();
  controlP5Libre();
  textSize(30);
  
  text("Salles disponibles entre " + d1.afficheStr() + " et " + d2.afficheStr(), 320, 155);
  afficheStringList(sallesDispo(d1, d2));
  
  textSize(32);
}

int etudiantsPresents(Date debut, Date fin) {
  StringList groupesPresents = new StringList();
  StringList sousGroupesPresents = new StringList();
  
  // ajout des groupes présents dans la liste
  for (int i = 0; i < cours.length; i++) {
    if (compareCreneaux(debut, fin, cours[i].debut, cours[i].fin)) {
      String list[] = splitTokens(cours[i].groupe, " ");
      
      for (int j = 0; j < list.length; j++) {
        if (rechercheString(groupesPresents, list[j]) == -1) {
          groupesPresents.append(list[j]);
        }
      }
    }
  }
  
  int etu = 0;
  
  // renvoi les sous groupes au lieux de groupes (par exemple S1G1.1 et S1G1.2 au lieu de S1G1)
  for (int i = 0; i < groupesPresents.size(); i++) {
    switch(groupesPresents.get(i).length()) {
      case 6:
        sousGroupesPresents.append(groupesPresents.get(i));
        break;
      
      case 4:
        for(int j=0; j<Universite.length; j++){
          if(Universite[j].sousGroupe.charAt(1) == groupesPresents.get(i).charAt(1) && Universite[j].sousGroupe.charAt(3) == groupesPresents.get(i).charAt(3)){
            sousGroupesPresents.append(Universite[j].sousGroupe);
          }
        }
        break;
        
      case 2:
        for(int j=0; j<Universite.length; j++){
            if(Universite[j].sousGroupe.charAt(1) == groupesPresents.get(i).charAt(1)){
              sousGroupesPresents.append(Universite[j].sousGroupe);
            }
        }
        break;
    }
  }
  
  // supprime les doublons de la liste sousGroupesPresents
  while(doublon(sousGroupesPresents)) {
    for (int i = 0; i < sousGroupesPresents.size(); i++) {
      for (int j = i + 1; j < sousGroupesPresents.size(); j++) {
        if (sousGroupesPresents.get(i).equals(sousGroupesPresents.get(j))) {
          sousGroupesPresents.remove(j);
        }
      } 
    }
  }
  
  for (int i = 0; i < sousGroupesPresents.size(); i++) {
    for (int j = 0; j < Universite.length; j++) {
      if (sousGroupesPresents.get(i).equals(Universite[j].sousGroupe)) {
        etu += Universite[j].nombre;
      }
    }
  }
  
  return etu;
}

void etudiantsPresentUI(String d, String f) {
  Date d1 = new Date();
  Date d2 = new Date();
  afficherFenetre();
  d1.loadDate(d);
  d2.loadDate(f);
  
  
  image(bgImg, 0, 0, width, height);
  afficherFenetre();
  controlP5Present();
  
  image(bgImg, 0, 0, width, height);
  afficherFenetre();
  
  textSize(30);
  
  text("Nombres d'étudiants présents à l'IUT entre " + d1.afficheStr() + " et " + d2.afficheStr(), 320, 155);
  text(etudiantsPresents(d1, d2), 320, 185);
}


// renvoie l'indice du string dans la stringList, ou renvoi -1 si il n'est pas présent
int rechercheString(StringList strList, String str) {
  for (int i = 0; i < strList.size(); i++) {
    if (strList.get(i).equals(str)) {
      return i;
    } 
  }
  
  return -1;
}

// renvoi true si la stringlist contient un doublon, et false dans le cas contraire
boolean doublon(StringList strList) {
  for (int i = 0; i < strList.size(); i++) {
    for (int j = i + 1; j < strList.size(); j++) {
      if (strList.get(i).equals(strList.get(j))) {
        return true;
      }
    } 
  }
  
  return false;
}

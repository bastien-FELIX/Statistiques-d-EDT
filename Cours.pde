class Cours {
  Date debut;
  Date fin;
  String matiere;
  String salle;
  String groupe;
  String prof;
  
  void init(Date d, Date f, String m, String s, String g, String p){
    debut = d;
    fin = f;
    matiere = m;
    salle = s;
    groupe = g;
    prof = p;
  }
  
  void afficheCours(){
    debut.affiche();
    fin.affiche();
    println("Matiere:", matiere, "Salle:", salle,"Groupe:", groupe,"Prof:", prof);
  }
}

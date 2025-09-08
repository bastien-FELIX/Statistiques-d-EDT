class Salle {
  
  int id;
  String nom;
  int nbPlaces;
  boolean informatique;

  void initSalle(String name, int place, String info, int i) {
    nom = name;
    nbPlaces = place;
    id = i;
    if (info.equals("Informatique") || info.equals("Réseau")) {
      informatique = true;
    } else {
      informatique = false;
    }
  }
  
  void affiche(){
    println("Salle: "+nom+" Nombre de places: "+nbPlaces+" Est informatique ?: "+informatique);
  }
}

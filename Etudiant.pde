class groupe{
  String sousGroupe;
  String groupe;
  String semestre;
  int nombre;
  float ru;
  
  
  void init(String g, int n, float restaurant){
    sousGroupe = g;
    if(sousGroupe.length() == 6){
      groupe = sousGroupe.substring(0,4);
      semestre = groupe.substring(0,2);
    }
    else{
      groupe = g;
      semestre = g;
    }
    nombre = n;
    ru = restaurant;
  }
  void afficheConsole(){
    println("Groupe : " + sousGroupe + " nombre : " + nombre + " ru : "+  ru);
  }
}

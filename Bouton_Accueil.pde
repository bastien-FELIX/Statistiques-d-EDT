class Bouton {
  int x, y;
  int hauteur, largeur;
  PImage image;
  String texte;
  boolean noir = false;
  boolean centre = false;
  void init(int ax,int ay,int h,int l, String txt){
    x = ax;
    y = ay;
    hauteur = h;
    largeur = l;
    texte = txt;
  }
  
  void affiche(){
    noFill();
    if(noir){
      stroke(0);
    }
    else{
      stroke(255);
    }
    //rect(x-1,y-1, largeur+1, hauteur+1);
    if(image != null){
      image(image, x,y);
    }
    fill(0);
    if(centre){
      text(texte, x + largeur/2, y + hauteur/2);
    }
    else{
      text(texte, x - 20, y + hauteur*1.2);
    }
    
  }
}

PFont font;
import controlP5.*;

color[][] colorSet={
 {color(155, 89, 182),color(142, 68, 173)},  //Amethyst, wisteria
 {color(52, 152, 219),color(41, 128, 185)},  //Peter river, belize hole
 {color(46,204,133),color(39, 174, 96)},   //Emerald, nephrite
 {color(26, 188, 156),color(22,160,133)},  //Turguoise, green sea
 {color(241, 196, 15),color(243, 156, 18)},  //Sunflower, orange
 {color(230, 126, 34),color(211, 84, 0)},    //Carrot, pumpkin
 {color(231, 76, 60),color(192, 57, 43)}    //alizarin, pomegranate
};
color[][] reverseColSet={
 {color(142, 68, 173),color(155, 89, 182)},  //wisteria, amethyst(the same below)
 {color(41, 128, 185),color(52, 152, 219)},
 {color(39, 174, 96),color(46,204,133)},
 {color(22,160,133),color(26, 188, 156)},
 {color(243, 156, 18),color(241, 196, 15)},
 {color(211, 84, 0),color(230, 126, 34)},
 {color(192, 57, 43),color(231, 76, 60)}
};
ControlP5 cp5;
Mosaic newMosaic;

void setup(){
  size(900,600);
  background(255);
  noStroke();
  cp5= new ControlP5(this);
  /*
    Sidebar buttons
  */
  cp5.addButton("Create")
     .setPosition(650,380)
     .setSize(200,30);
  
  cp5.addButton("Save")
     .setPosition(650,450)
     .setSize(200,30);
     
  cp5.addButton("Destroy")
     .setPosition(650,520)
     .setSize(200,30);
     
  newMosaic=new Mosaic(0,0,600,10);
  newMosaic.init();
  newMosaic.display();
}

void draw(){

  newMosaic.calculatePressed();
  newMosaic.changePressed();
  newMosaic.display();
}
/*
  trigger event for create button
*/
public void Create(){
  newMosaic.randomPattern();
  newMosaic.modeSwitch=0;
  frameRate(30);
  for(int i=0; i<newMosaic.grid; i++){
      for(int j=0; j<newMosaic.grid; j++){
        newMosaic.destroyed[i][j]=false;
      }
    }
}
/*
  trigger event for save button
*/
public void Save(){
  save("create_save_ruin.jpg");
}
/*
  trigger event for destroy button
*/
public void Destroy(){
  newMosaic.modeSwitch=1;
  //frameRate(4);
}

/* listens for which key is being pressed
  w: reverse color
  a: change color forward
  d: change color backward
  s: change direction
*/
void keyPressed(){
  if(key=='w'){
    if(newMosaic.curIndexX>-1&&newMosaic.curIndexY>-1){
      newMosaic.reverseColor();
    }
  }
  if(key=='a'){
    newMosaic.changeColor(false);
  }
  if(key=='d'){
    newMosaic.changeColor(true);
  }
  if(key=='s'){
    if(newMosaic.curIndexX>-1&&newMosaic.curIndexY>-1){
      newMosaic.changeDir();
    }
  }
  if(keyCode==UP||keyCode==DOWN||keyCode==LEFT||keyCode==RIGHT){
    newMosaic.changeCur();
  }
}
/*
  change pixel when mouse is clicked
*/
void mouseClicked(){
  newMosaic.calculateIndex();
}
/*
  class mosaic
*/
class Mosaic{
  int grid=10; // the size of mosaic board (grid*grid grid)
  int mWidth; 
  int mHeight;
  int mx; //initial value of x axis
  int my; //initial point of y axis
  int bfSize=18; //basic font size, 18 point when width is 600
  color[] randomCol1;
  color[] randomCol2;
  int random7;
  int counter=0;
  int patternSwitch=-1;
  int curIndexX=-1;
  int curIndexY=-1;
  int pressedX=-1;
  int pressedY=-1;
  int selectedCol;
  int modeSwitch=0;
  int tempCol=0;
  boolean[][] destroyed = new boolean[grid][grid];
  
  Pixel[][] board=new Pixel[grid][grid]; //store all the pixel on the mosaic board
  
  /*
    constructor, parameters are 
    1. initial value of x axis
    2. initial value of y axis
    3. width of the mosaic board
    4. the amount of pixels in a side
  */
  Mosaic(int x,int y, int w, int g){
    mx=x;
    my=y;
    mWidth=w;
    mHeight=w;
    selectedCol=int(random(7));
    randomCol1=getRandomCol();
    //prevent two random color generated is the same
    do{
      randomCol2=getRandomCol();
    }while(randomCol2[0]==randomCol1[0]||randomCol2[0]==randomCol1[1]);
    random7=int(random(7));
    bfSize=bfSize*mWidth/600;
    grid=g;
    //the value of grid must be even for loading two existed pattern
    if(grid%2!=0){
      grid++;
    }
    for(int i=0; i<grid; i++){
      for(int j=0; j<grid; j++){
        destroyed[i][j]=false;
      }
    }
  }
  /*
    initialization of mosaic board, 
    display a random pattern,
    title of work and instruction on the screen
  */
  void init(){
    randomPattern();
    display();
    //Title and instruction
    fill(255);
    rect(mWidth/3,mHeight/2-50,mWidth*2/3,100);
    font=loadFont("AppleBraille-48.vlw");
    textFont(font);
    fill(52, 73, 94);
    textSize(2*bfSize);
    text("DIGITAL MOSAIC",605,80);
    fill(149, 165, 166);
    textSize(1.6*bfSize);
    text("Create It & Destroy It",605,110);
    textSize(bfSize);
    text(" - Create an artwork and then",605,150);
    text("    destroyyyyyyyyyyyyyyyyyy it",605,175);
    textSize(12);
    text("- Click or direction key to select",650,425);
    text("- A/W/S/D to adjust pixel",650,440);
    text("- Save your work anytime",650,495);
    text("- Move cursor around to destroy",650,565);
  }
  /*
    display the pixels to the screen
  */
  void display(){
    for(int i=0; i<grid; i++){
      for(int j=0; j<grid; j++){
        pushMatrix();
          translate(mx+i*mWidth/grid, my+j*mHeight/grid);
          board[i][j].display();
        popMatrix();
      }
    }
    if(curIndexX>-1&&curIndexY>-1){
      stroke(255);
      noFill();
      rect(mx+curIndexX*mWidth/grid, my+curIndexY*mHeight/grid, mWidth/grid, mHeight/grid);
      noStroke();
    } 
  }
  /*
    judge whether the cursor is inside the board
  */
  boolean isInside(){
    if(mouseX>mx&&mouseX<(mx+mWidth)&&mouseY>my&&mouseY<(my+mHeight)){
      return true;
    } 
    else{
      curIndexX=-1;
      curIndexY=-1;
      return false;
    }
  }
  /*
    calculate which pixel the cursor is in
  */
  void calculateIndex(){
    if(modeSwitch==1) return;
    if(isInside()){
      curIndexX=(mouseX-mx)/(mWidth/grid);
      curIndexY=(mouseY-my)/(mHeight/grid);
      //print(curIndexX);
      //print(curIndexY);
    }
  }
  /*
    change current active pixel
  */
  void changeCur(){
    if(keyCode==UP){
      curIndexY=(curIndexY-1)%grid;
    }else if(keyCode==DOWN){
      curIndexY=(curIndexY+1)%grid;
    }else if(keyCode==LEFT){
      curIndexX=(curIndexX-1)%grid;
    }else{
      curIndexX=(curIndexX+1)%grid;
    }
  }
  /*
    change the color of current pixel
  */
  void changeColor(boolean dir){
    if(!isInside()) return;
    for(int i=0; i<7; i++){
      if(board[curIndexX][curIndexY].pColor[0]==colorSet[i][0]){
        if(dir){
          board[curIndexX][curIndexY].pColor[0]=colorSet[(i+1)%7][0];
          board[curIndexX][curIndexY].pColor[1]=colorSet[(i+1)%7][1];
        }else{
          if(i==0){
            board[curIndexX][curIndexY].pColor[0]=reverseColSet[6][0];
            board[curIndexX][curIndexY].pColor[1]=reverseColSet[6][1];

          }else{
            board[curIndexX][curIndexY].pColor[0]=reverseColSet[(i-1)%7][0];
            board[curIndexX][curIndexY].pColor[1]=reverseColSet[(i-1)%7][1];
          }
        }
        return;
      }
    }
    for(int i=0; i<7; i++){
      if(board[curIndexX][curIndexY].pColor[0]==reverseColSet[i][0]){
        if(dir){
          board[curIndexX][curIndexY].pColor[0]=reverseColSet[(i+1)%7][0];
          board[curIndexX][curIndexY].pColor[1]=reverseColSet[(i+1)%7][1];
        }else{
          if(i==0){
            board[curIndexX][curIndexY].pColor[0]=reverseColSet[6][0];
            board[curIndexX][curIndexY].pColor[1]=reverseColSet[6][1];

          }else{
            board[curIndexX][curIndexY].pColor[0]=reverseColSet[(i-1)%7][0];
            board[curIndexX][curIndexY].pColor[1]=reverseColSet[(i-1)%7][1];
          }
        }
        return;
      }
    }
  }
  /*
    reverse color of current pixel
  */
  void reverseColor(){
    color temp=board[curIndexX][curIndexY].pColor[0];
    board[curIndexX][curIndexY].pColor[0]=board[curIndexX][curIndexY].pColor[1];
    board[curIndexX][curIndexY].pColor[1]=temp;
  }
  /*
    change direction of current pixel
  */
  void changeDir(){
    board[curIndexX][curIndexY].cuttingLine=1-board[curIndexX][curIndexY].cuttingLine;
  }
  /*
    calculate the current pixel the cursor is hovering on
  */
  void calculatePressed(){
    if(modeSwitch==0) return;
     if(isInside()){
      pressedX=(mouseX-mx)/(mWidth/grid);
      pressedY=(mouseY-my)/(mHeight/grid);
    }
  }
  /*
    change current hovering pixel
  */
  void changePressed(){
    if(modeSwitch==0) return;
    if(!isInside()) return;
    board[pressedX][pressedY].pColor[0]=colorSet[selectedCol][0];
    board[pressedX][pressedY].pColor[1]=colorSet[selectedCol][1];
    destroyed[pressedX][pressedY]=true;
    for(int i=0; i<grid; i++){
      for(int j=0; j<grid; j++){
        if(destroyed[i][j]==false) return;
      }
    }
    frameRate(4);
    selectedCol=(selectedCol+1)%7;
    radial(pressedX, pressedY,selectedCol);
  }
  /*
    create a radial rainbow and track mouse movement
  */
  void radial(int pressedX, int pressedY, int tempCol){
    board[pressedX][pressedY].pColor[0]=reverseColSet[tempCol][0];
    board[pressedX][pressedY].pColor[1]=reverseColSet[tempCol][1];
    for(int i=0; i<grid; i++){
      for(int j=0; j<grid; j++){
        if(Math.abs(i-pressedX)==1 && Math.abs(j-pressedY)<=1||Math.abs(i-pressedX)<=1 && Math.abs(j-pressedY)==1){
          board[i][j].pColor[0]=reverseColSet[(tempCol+9)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+9)%7][1];
        }else if(Math.abs(i-pressedX)==2 && Math.abs(j-pressedY)<=2||Math.abs(i-pressedX)<=2 && Math.abs(j-pressedY)==2){
          board[i][j].pColor[0]=reverseColSet[(tempCol+8)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+8)%7][1];
        }else if(Math.abs(i-pressedX)==3 && Math.abs(j-pressedY)<=3||Math.abs(i-pressedX)<=3 && Math.abs(j-pressedY)==3){
          board[i][j].pColor[0]=reverseColSet[(tempCol+7)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+7)%7][1];
        }else if(Math.abs(i-pressedX)==4 && Math.abs(j-pressedY)<=4||Math.abs(i-pressedX)<=4 && Math.abs(j-pressedY)==4){
          board[i][j].pColor[0]=reverseColSet[(tempCol+6)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+6)%7][1];
        }else if(Math.abs(i-pressedX)==5 && Math.abs(j-pressedY)<=5||Math.abs(i-pressedX)<=5 && Math.abs(j-pressedY)==5){
          board[i][j].pColor[0]=reverseColSet[(tempCol+5)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+5)%7][1];
        }else if(Math.abs(i-pressedX)==6 && Math.abs(j-pressedY)<=6||Math.abs(i-pressedX)<=6 && Math.abs(j-pressedY)==6){
          board[i][j].pColor[0]=reverseColSet[(tempCol+4)%6][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+4)%6][1];
        }else if(Math.abs(i-pressedX)==7 && Math.abs(j-pressedY)<=7||Math.abs(i-pressedX)<=7 && Math.abs(j-pressedY)==7){
          board[i][j].pColor[0]=reverseColSet[(tempCol+3)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+3)%7][1];
        }else if(Math.abs(i-pressedX)==8 && Math.abs(j-pressedY)<=8||Math.abs(i-pressedX)<=8 && Math.abs(j-pressedY)==8){
          board[i][j].pColor[0]=reverseColSet[(tempCol+2)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+2)%7][1];
        }else if(Math.abs(i-pressedX)==9 && Math.abs(j-pressedY)<=9||Math.abs(i-pressedX)<=9 && Math.abs(j-pressedY)==9){
          board[i][j].pColor[0]=reverseColSet[(tempCol+1)%7][0];
          board[i][j].pColor[1]=reverseColSet[(tempCol+1)%7][1];
        }
      }
    }
    tempCol=(tempCol+1)%7;
  }
  /*
    get a random color group(two similar color)
  */
  color[] getRandomCol(){
    int randomColR=int(random(7));
    int randomColC=int(random(2));
    color[] ranCol= {colorSet[randomColR][randomColC],colorSet[randomColR][1-randomColC]};
    return ranCol;
  }
  /*
    generate random pattern, 
    every pixel is generated with random color and direction
  */
  void randomPattern(){
    for(int i=0; i<grid; i++){
     for(int j=0; j<grid; j++){
       board[i][j]=new Pixel(int(random(2)), getRandomCol());
     }
    }
  }

  /*
    class pixel is inside the class mosaic
  */
  class Pixel{
    int pWidth=mWidth/grid;
    int pHeight=mHeight/grid;
    int cuttingLine; //0: left-top/right-bottom; 1: left-bottom/right-top
    color[] pColor;
    
   /*
     constructor, parameters are
     1. the direction of cutting line, 0 or 1
     2. the color group
   */
    Pixel(int cl, color[] pc){
      cuttingLine=cl;
      pColor=pc;
    }
  /*
    draw the pixel to the screen
  */
    void display(){
      //cut to left-top and right-bottom
      if(cuttingLine==0){
        fill(pColor[0]);
        // left-top triangle
        triangle(0,0,0,pHeight,pWidth,0);
        fill(pColor[1]);
        //right-bottom triangle
        triangle(pWidth,0,0,pHeight,pWidth,pHeight);
      }else{ //cut to left-bottom and right-top
        fill(pColor[0]);
        //left-bottom triangle
        triangle(0,0,0,pHeight,pWidth,pHeight);
        fill(pColor[1]);
        //right-top triangle
        triangle(pWidth, 0,0,0,pWidth,pWidth);
      }
    }
  }
}
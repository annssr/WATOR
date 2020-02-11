import java.util.Random;
import java.util.Arrays;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

int[][] FISH, SHARK, FISH_MOVE, SHARK_MOVE, STARVE;
int cell_size = 10;
int DIMENSIONS = 40;
Random rand = new Random();
boolean justLoop = false;
boolean random_eval = false;

int num_fish = 0, num_shark = 0;
float num_cells, fish_percent, shark_percent;
int time_step = 0;
int max_fish = 0;
ArrayList<Pair> graph = new ArrayList<Pair>();

int FISH_BREED = 6, SHARK_BREED = 12, SHARK_STARVE = 8;

void setup(){
  size(800, 400);
  // Initializing arrays
  FISH = new int[DIMENSIONS][DIMENSIONS];
  SHARK = new int[DIMENSIONS][DIMENSIONS];
  FISH_MOVE = new int[DIMENSIONS][DIMENSIONS];
  SHARK_MOVE = new int[DIMENSIONS][DIMENSIONS];
  STARVE = new int[DIMENSIONS][DIMENSIONS];
  
  rando();
}

void draw(){
  background(255, 255, 255);
  if(justLoop)
    updateCells();
  // Draw the left black square
  fill(0, 0, 0);
  rect(0, 0, 400, 400);
  for(int i = 0; i < DIMENSIONS; i++){
    for(int j = 0; j < DIMENSIONS; j++){
      if(SHARK[i][j] != -1){  // Shark red
        fill(255, 0, 0);
        stroke(255, 0, 0);
      }
      else if(FISH[i][j] != -1){  // Fish green
        fill(0, 255, 0);
        stroke(0, 255, 0);
      }
      else  // Empty cell, draw nothing
        continue;
      // Draw square at cell location
      rect(i*cell_size, j*cell_size, cell_size, cell_size);
    }
  }
  if(max_fish < num_fish)
    max_fish = num_fish;
  // Now let's update the right graph
  // First, check if it's the 200th timestep
  if((time_step++) % 1 == 0){
    // Cool, now let's see the percentages of the sharks and fishes
    num_cells = DIMENSIONS * DIMENSIONS;
    fish_percent = num_fish / num_cells * 100;
    shark_percent = num_shark / num_cells * 100 * 10;
    // Let's expand them to scale with the grid's size
    fish_percent *= 4;
    shark_percent *= 4;
    // Add to graph list
    graph.add(new Pair((int)(400 + fish_percent), (int)(400 - shark_percent)));
    if(graph.size() > 200)
      graph.remove(0);
  }
  // Now let's draw
  fill(0, 0, 0);
  int i = 0;
  for(Pair p: graph){
    noStroke();
    fill(0, 0, 0, i++);
    ellipse(p.first, p.second, 5, 5);
  }
  // Reset the numbers
  num_fish = 0;
  num_shark = 0;
}

void keyPressed(){
  switch(key){
    case '-':
      if(cell_size > 2)
        cell_size -= 2;
      else if(cell_size == 2)
        cell_size = 1;
      DIMENSIONS = 400 / cell_size;
      FISH = new int[DIMENSIONS][DIMENSIONS];
      SHARK = new int[DIMENSIONS][DIMENSIONS];
      FISH_MOVE = new int[DIMENSIONS][DIMENSIONS];
      SHARK_MOVE = new int[DIMENSIONS][DIMENSIONS];
      STARVE = new int[DIMENSIONS][DIMENSIONS];
      rando();
      break;
    case '=':
      if(cell_size == 1)
        cell_size = 2;
      else if(cell_size < 16)
        cell_size += 2;
      DIMENSIONS = 400 / cell_size;
      FISH = new int[DIMENSIONS][DIMENSIONS];
      SHARK = new int[DIMENSIONS][DIMENSIONS];
      FISH_MOVE = new int[DIMENSIONS][DIMENSIONS];
      SHARK_MOVE = new int[DIMENSIONS][DIMENSIONS];
      STARVE = new int[DIMENSIONS][DIMENSIONS];
      rando();
      break;
    case 'r':
      rando();
      break;
    case 's':
      updateCells(); //<>//
      break;
    case ' ':
      justLoop = !justLoop;
      break;
    case 't':
      random_eval = !random_eval;
      break;
    default:
      break;
  }
}

void rando(){
  for(int i = 0; i < DIMENSIONS; i++){
    for(int j = 0; j < DIMENSIONS; j++){
      // Initialize the move arrays to 0
      SHARK_MOVE[i][j] = 0;
      FISH_MOVE[i][j] = 0;
      // Get probability
      float probability = abs(rand.nextFloat()) * 100;
      // Get random age
      int rAge = abs(rand.nextInt()) % FISH_BREED;
      if(probability < 2.5){ // Shark
        SHARK[i][j] = rAge;
        FISH[i][j] = -1;
        STARVE[i][j] = 0;
      }
      else if(probability < 25){ // Fish
        FISH[i][j] = rAge;
        SHARK[i][j] = -1;
        STARVE[i][j] = -1;
      }
      else if(probability <= 100){// Normal cell
        SHARK[i][j] = -1;
        FISH[i][j] = -1;
        STARVE[i][j] = -1;
      }
    }
  }
}

void updateCells(){ // update the cells
  
  // Fishes first
  // First, let's see if we're approaching extinction
  if(num_fish < 1){
    // We are. Randomly seed some sharks
    for(int i = 0; i < 1; i++){
      int x = abs(rand.nextInt()) % DIMENSIONS, y = abs(rand.nextInt()) % DIMENSIONS;
      SHARK[x][y] = -1;
      STARVE[x][y] = -1;
      FISH[x][y] = abs(rand.nextInt()) % FISH_BREED;
    }
  }
  if(random_eval){
    List<Integer> a = new ArrayList<Integer>();
    List<Integer> b = new ArrayList<Integer>();
    for(int i = 0; i < DIMENSIONS; i++){
      a.add(i);
      b.add(i);
    }
    Collections.shuffle(a);
    Collections.shuffle(b);
    for(int i: a){
      for(int j: b){
        fish_move(i, j);
      }
    }
  }
  else{
    for(int i = 0; i < DIMENSIONS; i++){
      for(int j = 0; j < DIMENSIONS; j++){
        fish_move(i, j);
      }
    }
  }
  //Time for sharks!
  // First, let's see if we're approaching extinction
  if(num_shark < 1){
    // We are. Randomly seed some sharks
    for(int i = 0; i < 1; i++){
      int x = abs(rand.nextInt()) % DIMENSIONS, y = abs(rand.nextInt()) % DIMENSIONS;
      SHARK[x][y] = abs(rand.nextInt()) % SHARK_BREED;
      STARVE[x][y] = 0;
      FISH[x][y] = -1;
      FISH_MOVE[x][y] = -1;
    }
  }
  if(random_eval){
    List<Integer> a = new ArrayList<Integer>();
    List<Integer> b = new ArrayList<Integer>();
    for(int i = 0; i < DIMENSIONS; i++){
      a.add(i);
      b.add(i);
    }
    Collections.shuffle(a);
    Collections.shuffle(b);
    for(int i: a){
      for(int j: b){
        shark_move(i, j);
      }
    }
  }
  else{
    for(int i = 0; i < DIMENSIONS; i++){
      for(int j = 0; j < DIMENSIONS; j++){
        shark_move(i, j);
      }
    }
  }
  for(int i = 0; i < DIMENSIONS; i++){
    for(int j = 0; j < DIMENSIONS; j++){
      SHARK_MOVE[i][j] = -1;
      FISH_MOVE[i][j] = -1;
    }
  } //<>//
}

void fish_move(int i, int j){
  int tmp;
  // Check if there's an actual fish here, and that we haven't already moved this fish
  if(FISH[i][j] != -1 && FISH_MOVE[i][j] == -1){
    num_fish++;
    // Let's add to its age
    FISH[i][j]++;
    // Store it in a variable
    tmp = FISH[i][j];
    // Let's get a list of directions, then randomly select one
    ArrayList<Pair> directions = new ArrayList<Pair>();
    for(int x = -1; x < 2; x++){
      for(int y = -1; y < 2; y++){
        // Check if the direction doesn't already have a fish or shark there //<>//
        if(FISH[t(i, x)][t(j, y)] == -1 && SHARK[t(i, x)][t(j, y)] == -1){
          directions.add(new Pair(x, y));
        }
      }
    }
    // Check if there are any directions actually viable 
    if(directions.size() == 0)
      return;
    // Let's pick one and go there
    Pair dir = directions.get(abs(rand.nextInt()) % directions.size());
    FISH_MOVE[t(i, dir.first)][t(j, dir.second)] = tmp;
    FISH[t(i, dir.first)][t(j, dir.second)] = tmp;
    // Delete the past
    FISH[i][j] = -1;
    // Check if we can have babies
    if(tmp >= FISH_BREED){
      num_fish++;
      // We can! Set both to 0 age
      FISH_MOVE[t(i, dir.first)][t(j, dir.second)] = 0;
      FISH_MOVE[i][j] = 0;
      FISH[t(i, dir.first)][t(j, dir.second)] = 0;
      FISH[i][j] = 0;
    }
  }
}

void shark_move(int i, int j){
  int tmp;
  // Check if there's an actual shark here
  if(SHARK[i][j] != -1 && SHARK_MOVE[i][j] == -1){
    num_shark++;
    // Let's add to its age
    SHARK[i][j]++;
    // Add to its hunger
    STARVE[i][j]++;
    // Check if we should die of starvation or not yet
    if(STARVE[i][j] >= SHARK_STARVE){
      // We should. Kill everything, then skip
      STARVE[i][j] = -1;
      SHARK[i][j] = -1;
    }
    // Store it in a variable
    tmp = SHARK[i][j];
    // Let's get a list of directions, then randomly select one
    ArrayList<Pair> directions = new ArrayList<Pair>();
    for(int x = -1; x < 2; x++){
      for(int y = -1; y < 2; y++){
        // Check if the directiob has a fish there
        if(FISH[t(i, x)][t(j, y)] != -1){
          directions.add(new Pair(x, y));
        }
      }
    }
    // Check if we found some grub
    boolean ate = false;
    if(directions.size() == 0){
      // We didn't. Let's just see if we can move without bumping into somebody
      for(int x = -1; x < 2; x++){
        for(int y = -1; y < 2; y++){
          // Check if the directiob has a fish there
          if(SHARK[t(i, x)][t(j, y)] == -1){
            directions.add(new Pair(x, y));
          }
        }
      }
      // Did we find somewhere to move to?
      if(directions.size() == 0){
        // No Y_Y
        return;
      }
    }
    else{
      // Yay, we ate!
      ate = true;
    }
    // Let's pick one and go there
    Pair dir = directions.get(abs(rand.nextInt()) % directions.size());
    SHARK_MOVE[t(i, dir.first)][t(j, dir.second)] = tmp;
    SHARK[t(i, dir.first)][t(j, dir.second)] = tmp;
    STARVE[t(i, dir.first)][t(j, dir.second)] = STARVE[i][j];
    // Delete the past
    SHARK[i][j] = -1;
    STARVE[i][j] = -1;
    // Check if we ate
    if(ate){
      num_fish--;
      // We did. Kill the fish we ate
      STARVE[t(i, dir.first)][t(j, dir.second)] = 0;
      FISH[t(i, dir.first)][t(j, dir.second)] = -1;
      FISH_MOVE[t(i, dir.first)][t(j, dir.second)] = -1;
    }
    // Check if we can have babies
    if(tmp >= SHARK_BREED){
      num_shark++;
      // We can! Set both to 0 age
      SHARK_MOVE[t(i, dir.first)][t(j, dir.second)] = 0;
      SHARK_MOVE[i][j] = 0;
      SHARK[t(i, dir.first)][t(j, dir.second)] = 0;
      SHARK[i][j] = 0;
    }
  }
}
  
// This method gives the torroidal wrapping index of the arrays
int t(int current, int ind){
  return (DIMENSIONS + ind + current) % DIMENSIONS;
}

class Pair {
  public final int first;
  public final int second;

  public Pair(final int first, final int second) {
    this.first = first;
    this.second = second;
  }

  //
  // Override 'equals', 'hashcode' and 'toString'
  //
}

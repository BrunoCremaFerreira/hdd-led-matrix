/*  3x4 Hdd Led Matrix Project
 *  (C) 2023 Bruno Crema Ferreira
 *  This code is licenced under the MIT License.
 */

#define ROWS 3
#define COLS 4
#define FRAME_TIME 90 // in milliseconds

int cathodes[ROWS] = { 2, 4, 6 };
int anodes[COLS]   = { 3, 5, 7, 9 };
int slide = 0;

bool mx_animation_1[ROWS][COLS] = {
  {1, 0, 1, 0},
  {0, 1, 0, 1},  
  {1, 0, 1, 0}
};

bool mx_animation_2[ROWS][COLS] = {
  {1, 0, 0, 0},
  {1, 0, 0, 0},  
  {1, 0, 0, 0}
};

bool mx[ROWS][COLS] = {};

void clear()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = 0;
    }
  }
}

void run_animation_1()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = mx_animation_1[i][j + slide];
    }
  }

  if(slide < COLS)
    slide++;
  else
    slide = 0;
}

void run_animation_2()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = mx_animation_1[i][j + slide];
    }
  }

  if(slide < COLS)
    slide++;
  else
    slide = 0;
}

void run_animation_blink_all()
{
  slide++;
  if (slide < 10) {
    clear();
    return;
  }

  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = 1;
    }
  }

  if(slide > 20)
    slide = 0;
}

void setup()
{
  // Pin initialization
  for ( int i = 0; i < ROWS; ++i ) {
    pinMode( cathodes[i], OUTPUT );
    digitalWrite( cathodes[i], HIGH );
  }
  for ( int i = 0; i < COLS; ++i ) {
    pinMode( anodes[i], OUTPUT );
    digitalWrite( anodes[i], LOW );
  }
  
  // Initialize the output array
  clear();
}
 
void loop()
{
  delay(FRAME_TIME);

  run_animation_1();
 
  // Rendering on physical led matrix
  for ( int i = 0; i < ROWS; i++ )
  {
    digitalWrite( cathodes[i], LOW );
    delay(2);

    for ( int j = 0; j < COLS; j++ ) {
      digitalWrite( anodes[j], mx[i][j] );
      delay(2);
    }  

    for ( int j = 0; j < COLS; j++ ) {
      digitalWrite( anodes[j], 0 );
    }
    
    digitalWrite( cathodes[i], HIGH );
    delay(2);
  }
}
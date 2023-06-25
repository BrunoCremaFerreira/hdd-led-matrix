#define ROWS 3
#define COLS 4
#define FRAME_TIME 500 // in milliseconds

int cathodes[ROWS] = { 2, 4, 6 };
int anodes[COLS]   = { 3, 5, 7, 9 };
int slide = 0;

bool mx_data_slide_animation[ROWS][4] = {
  {1, 0, 1, 0},
  {0, 1, 0, 1},  
  {1, 0, 1, 0}
};

bool mx[ROWS][COLS] = {};
unsigned long et = 0;

void run_slide_animation()
{
  // Store the animation data frame
  if (et + FRAME_TIME <= millis()) 
  {
    for (int i = 0; i < ROWS ; i++)  
    {
      for (int j = 0; j < COLS ; j++) {
        mx[i][j] = mx[i][j + slide];
      }
    }
    
    // Slide control
    if (slide < 4)
      ++slide;
    else 
      slide = 0;
    
    // Getting elapsed time
    et = millis();
  }
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
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = 0;
    }
  }
  
  // Initial elapsed time
  et = millis();
}
 
void loop()
{
  run_slide_animation();
 
  // Rendering on physical led matrix
  for ( int i = 0; i < ROWS; i++ )
  {
    digitalWrite( cathodes[i], LOW );
    
    for ( int j = 0; j < COLS; j++ ) {
      digitalWrite( anodes[j], mx[i][j] );
    }
    
    for ( int j = 0; j < COLS; j++ ) {
      digitalWrite( anodes[j], LOW );
    }
      
    digitalWrite( cathodes[i], HIGH );
  }
}
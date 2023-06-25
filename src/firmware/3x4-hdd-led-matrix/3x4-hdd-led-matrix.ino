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
int display_mode = 0;

bool mx_animation_pattern[ROWS][COLS] = {
  {1, 0, 1, 0},
  {0, 1, 0, 1},  
  {1, 0, 1, 0}
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

void run_animation()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = mx_animation_pattern[i][j + slide];
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

void read_serial_input()
{
  if(Serial.available() <= 0) {
    return;
  }

  String str_command = Serial.readStringUntil('\n');

  if(str_command.startsWith("err;")) {
    display_mode = 1;
    return;
  }
  
  if(str_command == "disks;"){
    display_mode = 2;
    return;
  }

  // Default
  display_mode = 0;
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

  Serial.begin(9600);
}
 
void loop()
{
  read_serial_input();

  switch (display_mode)
  {
    // Disk Error animation
    case 1: 
      run_animation_blink_all();
      break;
    // Show disk position
    case 2:
      break;
    // Default animation
    default:
      run_animation();  
      break;
  }

  delay(FRAME_TIME);
  
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
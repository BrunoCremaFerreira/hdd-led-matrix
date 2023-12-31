/*  3x4 Hdd Led Matrix Project
 *  (C) 2023 Bruno Crema Ferreira
 *  This code is licenced under the MIT License.
 */

#define ROWS 3
#define COLS 4
#define DEFAULT_FRAME_TIME 90 // in milliseconds

int cathodes[ROWS] = { 2, 4, 6 };
int anodes[COLS]   = { 3, 5, 7, 9 };
int slide = 0;

bool mx_animation_pattern[ROWS][COLS] = {
  {1, 0, 1, 0},
  {0, 1, 0, 1},  
  {1, 0, 1, 0}
};

bool mx[ROWS][COLS] = {};
bool mx_disks_position[ROWS][COLS] = {};

void clear()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = 0;
    }
  }
}

void clear_mx_disks_position()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx_disks_position[i][j] = 0;
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
    show_disks_position();
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

void show_disks_position()
{
  for (int i = 0; i < ROWS ; ++i) {
    for (int j = 0; j < COLS ; ++j) {
      mx[i][j] = mx_disks_position[i][j];
    }
  }  
}

void set_disks_position(String str_matrix_data)
{
    clear_mx_disks_position();
    
    int i = 0;
    int j = 0;
    for(int s=0; s < str_matrix_data.length() && i < ROWS; s++) {
        char chr = str_matrix_data[s];
        
        if(chr != '0' && chr != '1') { 
          continue;
        }

        mx_disks_position[i][j] = (chr=='1');
        
        j++;
        if(j == COLS) {
          j=0;
          i++;
        }
    }
}

int read_serial_input()
{
  if(Serial.available() <= 0) {
    return;
  }

  String str_command = Serial.readStringUntil('\n');

  // Disk Error Mode
  if(str_command.startsWith("err:")) {
    String matrix_data = str_command.substring(4);
    set_disks_position(matrix_data);
    return 1;
  }
  
  // Show Used Disks
  if(str_command.startsWith("disks:")) {
    String m_data = str_command.substring(6);
    set_disks_position(m_data);
    return 2;
  }

  // Default
  return 0;
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
  int display_mode = read_serial_input();

  switch (display_mode)
  {
    // Disk Error animation
    case 1: 
      run_animation_blink_all();
      break;
    // Show disk position
    case 2:
      show_disks_position();
      break;
    // Default animation
    default:
      run_animation();
      break;
  }

  delay(DEFAULT_FRAME_TIME);
  
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
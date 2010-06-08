/*
  LED Poles
  
  Airsoft / Milsim Program.
  
  Lets teams 'Capture' a position on the field and lighting up appropriate LEDs to indicate such
  
  Author:  Mark Martens
  Date:    June 07, 2010
  Filename: LEDPoles
  Version: 1 alpha2
 
 */

#define op1 2  //LED Ring, LED1
#define op2 3  //LED Ring, LED2
#define op3 4  //LED Ring, LED3
#define op4 5  //LED Ring, LED4
#define op5 6  //LED Ring, LED5
#define op6 7  //LED Ring, LED6
#define op7 8  //LED Ring, LED7
#define op8 12  //LED Ring, LED8

#define opRed 10 //LED GND pin for Red
#define opBlue 11 //LED GND pin for Blue

#define opLedFlash 9 //LED Pin for 'Arming' LED

#define ipRed 0 //Switch Input for Red (momentary connection to GND)
#define ipBlue 1 //Switch Input for Blue (momentary connection to GND)

int current_team = 0;  //Who has control?  0=Nobody 1=red 2=blue

int timetocap = 60*1000;  //How long to hold switch to cap point
int commit_time = 3000;  //Each team gets a 3 second guarantee cap time

//Function Declarations
void demo (void);  //POST function
void neutral(void); //Waiting for someone to capture point
void red_team(void); //Red team has control
void blue_team(void); //Blue team has control
void flash_routine(int segment); //Flash routine

void setup()   
{                
  // The setup() method runs once, when the sketch starts
  pinMode(op1, OUTPUT);
  pinMode(op2, OUTPUT);
  pinMode(op3, OUTPUT);
  pinMode(op4, OUTPUT);
  pinMode(op5, OUTPUT);
  pinMode(op6, OUTPUT);
  pinMode(op7, OUTPUT);
  pinMode(op8, OUTPUT);
  pinMode(opRed, OUTPUT);
  pinMode(opBlue, OUTPUT);
  pinMode(opLedFlash, OUTPUT);
  pinMode(ipRed, INPUT);
  pinMode(ipBlue, INPUT);

  //Set initial States
  digitalWrite(op1,LOW);
  digitalWrite(op2,LOW);
  digitalWrite(op3,LOW);
  digitalWrite(op4,LOW);
  digitalWrite(op5,LOW);
  digitalWrite(op6,LOW);
  digitalWrite(op7,LOW);
  digitalWrite(op8,LOW);
  digitalWrite(opRed,HIGH);
  digitalWrite(opBlue,HIGH);
  digitalWrite(opLedFlash,LOW);
  
  //Enable pullups on our inputs
  digitalWrite(ipRed,HIGH);
  digitalWrite(ipBlue,HIGH);
  
  demo();
  
}

// the loop() method runs over and over again,
// as long as the Arduino has power

void loop()                     
{
  //Main Function Loop
  switch ( current_team)
  {
    case 0:
      //Nobody has control
      neutral();
      break;
      
    case 1:
      //Red has control
      red_team();
      break;
      
    case 2:
      //Blue has control
      blue_team();
      break;
      
    default:
      //Hmmm.. Something Messed up.. let's fix it back to no control
      neutral();
      break;
  }
}


//Flash routine
void flash_routine(int segment)
{
  digitalWrite(op1,LOW);
  digitalWrite(op2,LOW);
  digitalWrite(op3,LOW);
  digitalWrite(op4,LOW);
  digitalWrite(op5,LOW);
  digitalWrite(op6,LOW);
  digitalWrite(op7,LOW);
  digitalWrite(op8,LOW);  
  
  switch (segment)
  {
    case 1:
      digitalWrite(op1,HIGH);
      break;
    
    case 2:
      digitalWrite(op1,HIGH);
      break;
    
    case 3:
      digitalWrite(op1,HIGH);
      break;
    
    case 4:
      digitalWrite(op1,HIGH);
      break;
    
    case 5:
      digitalWrite(op1,HIGH);
      break;
    
    case 6:
      digitalWrite(op1,HIGH);
      break;
    
    case 7:
      digitalWrite(op1,HIGH);
      break;
    
    case 8:
      digitalWrite(op1,HIGH);
      break;
      
    case 0:
    default:
      break;
  }
}




//Red team has control
void red_team(void)
{
  
  unsigned long last_flash;
  unsigned long red_time;
  boolean redFlag;
  int x=1;
  int blue=1;
  
  //start our red Timer
  red_time=millis();
  redFlag = false;
  
  //Set RED leds on
  digitalWrite(opRed,LOW);
  
  //Manualy set the first segment on
  flash_routine(x);
  last_flash=millis();
  delay(75); // Commit time - used to make sure we don't spuriously change states
  
  //Start our routine for red
  while (blue == 1)
  {
    if ((millis() - last_flash) > 125)
    {
      //Time to change which segment is lit.
      x++; //Change to one segment higher
      if (x > 8)
      {
        x=1;
      }
      flash_routine(x); //Set LED
      last_flash=millis(); //Update when we last switched segment
    }
    
    //Any processing we need to do we can do after here.
    
    if (redFlag)
    {
      //Red has had their time, allow blue to cap point
      blue = digitalRead(ipBlue);
    }
    else
    {
      //This is our commit time
      if ((millis() - red_time) > commit_time)
      {
        redFlag = true;
      }
    } 
  }
  //Red Team Lost Control, reset back to neutral
  digitalWrite(opRed,LOW);
  current_team=0;
  
}
  

//Blue team has control
void blue_team(void)
{
  
  unsigned long last_flash;
  unsigned long blue_time;
  boolean blueFlag;
  int x=1;
  int red=1;
  
  //start our red Timer
  blue_time=millis();
  blueFlag = false;
  
  //Set BLUE leds on
  digitalWrite(opBlue,LOW);
  
  //Manualy set the first segment on
  flash_routine(x);
  last_flash=millis();
  delay(75); // Commit time - used to make sure we don't spuriously change states
  
  //Start our routine for blue
  while (red == 1)
  {
    if ((millis() - last_flash) > 125)
    {
      //Time to change which segment is lit.
      x++; //Change to one segment higher
      if (x > 8)
      {
        x=1;
      }
      flash_routine(x); //Set LED
      last_flash=millis(); //Update when we last switched segment
    }
    
    //Any processing we need to do we can do after here.
    
    if (blueFlag)
    {
      //Blue has had their time, allow red to cap point
      red = digitalRead(ipRed);
    }
    else
    {
      //This is our commit time
      if ((millis() - blue_time) > commit_time)
      {
        blueFlag = true;
      }
    } 
  }
  //Blue Team Lost Control, reset back to neutral
  digitalWrite(opBlue,LOW);
  current_team=0;
  
}


//Waiting for Cap Routine
void neutral(void)
{
  
  int red=1;
  int blue=1;
  int arming;
  boolean redFlag;
  boolean blueFlag;
  unsigned long hold_time;
  
  
  //Make sure no LEDs are lit
  digitalWrite(opRed,HIGH);
  digitalWrite(opBlue,HIGH);
  
  
  //Read red and blue inputs constantly until something changes
  while ((red*blue) == 1)
  {
    red=digitalRead(ipRed);
    blue=digitalRead(ipBlue);
  }  //Either red or blue has an input
  if (red == 1)
  {
    redFlag=1;
  }
  else
  {
    blueFlag=1;
  }
  delay(50); //Debounce switch
  
  hold_time=millis();  //Start counting time switch is held.
  
  arming=0;
  //Wait for switch release (but exit if time expires)
  while ((red*blue) == 0)
  {
    //Flash Arming LED to indicate we're reading new position
    if (arming == 0)
    {
      digitalWrite(opLedFlash,HIGH);
      arming=1;
    }
    else
    {
      digitalWrite(opLedFlash,LOW);
      arming=0;
    }
    delay(100);  //Flash Delay
    
    red=digitalRead(ipRed);
    blue=digitalRead(ipBlue);
    if ((millis() - hold_time) > timetocap)
    {
      break;
    }
    
  }  //Either red or blue no longer has an input or we timed out (Player held switch long enough
  delay(50);  //Debounce switch
  
  digitalWrite(opLedFlash,LOW); //Make sure LED is off.
  
  if ((millis() - hold_time) < timetocap)
    {
      //Player did not hold out long enough - reset!
    }  
  else
  {
    //Player satisfied time constraint - cap point
    if (redFlag)
    {
      current_team=1;
    }
    
    if (blueFlag)
    {
      current_team=2;
    }
    
    //Technically if something borks, and both flags get set, blue is set to win (Should be unlikely)
    //If neither flag is set then we simply reset to neutral
  }
}

//Demo Routine
void demo(void)
{
  // This routine is to verify LEDs are operational - like a POST operation.
  int x=0;
  int red=1;
  int blue=1;
  
  while ((red*blue) == 1)
  {
    x++;
    if (x > 8)
    {
      x=1;
    }
    
    flash_routine(x);
    digitalWrite(opRed,LOW);
    digitalWrite(opLedFlash,HIGH);
    delay(125);
    digitalWrite(opRed,HIGH);
    digitalWrite(opBlue,LOW);
    digitalWrite(opLedFlash,LOW);
    delay(125);
    digitalWrite(opBlue,HIGH);
    
    red=digitalRead(ipRed);
    blue=digitalRead(ipBlue);
    
  } //Keep it up until switch is pressed in either direction
  flash_routine(0);
  delay(100); //Debounce Switch
}


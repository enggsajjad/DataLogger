//       SAJJAD HUSSAIN, S.E.
//       SEP. 2014
//       DATA LOGGER


//#include <18F4520.h>
#include <18F458.h>

#device adc=8
#DEVICE WRITE_EEPROM = NOINT
//right near the top of your source
#device PASS_STRINGS=IN_RAM 

//#fuses HS,NOWDT,NOPROTECT,NOLVP
#fuses EC,NOWDT,NOPROTECT,NOLVP
//#fuses EC, NOOSCSEN,NOPUT,NOBROWNOUT,NOWDT,NOSTVREN,NOLVP,NODEBUG,NOPROTECT,NOCPD,NOWRT,NOWRTC
/*
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES XT
//#FUSES EC                    //External clock
//#FUSES EC_IO                    //External clock
//#FUSES HS
//#FUSES INTRC_IO                 //Internal RC Osc, no CLKOUT
//#FUSES INTRC
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT               //No brownout reset
//#FUSES BORV20                   //Brownout reset at 2.0V
#FUSES NOPUT                    //No Power Up Timer
#FUSES NOCPD                    //No EE protection
//#FUSES STVREN                   //Stack full/underflow will cause reset
#FUSES NODEBUG                  //No Debug mode for ICD
#FUSES NOLVP                    //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O
#FUSES NOWRT                    //Program memory not write protected
//#FUSES NOWRTD                   //Data EEPROM not write protected
//#FUSES IESO                     //Internal External Switch Over mode enabled
//#FUSES FCMEN                    //Fail-safe clock monitor enabled
//#FUSES NOPBADEN                   //PORTB pins are configured as analog input channels on RESET
//#FUSES NOWRTC                   //configuration not registers write protected
//#FUSES NOWRTB                   //Boot block not write protected
//#FUSES NOEBTR                   //Memory not protected from table reads
//#FUSES NOEBTRB                  //Boot block not protected from table reads
//#FUSES NOCPB                    //No Boot Block code protection
//#FUSES NOLPT1OSC                  //Timer1 configured for low-power operation
//#FUSES MCLR                     //Master Clear pin enabled
//#FUSES NOXINST                  //Extended set extension and Indexed Addressing mode disabled (Legacy mode)
*/
//#use delay(clock=11059200)
//#use delay(clock=4090000)
#use delay(clock=8192000)
#use rs232(baud=57600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8,STOP=2)
#ROM int8 0xf00000 = {7, 8, 0, 0, 0, 0,1,0,1}// byte wise
//default memory values
//location 0: status byte 0 (lsb)  includes rate, filter clock, impedance
//location 1: status byte 1 include system id
//location 2: status byte 2 (msb)  includes  Tid 
//location 3: Start Addr Running byte 0 (lsb)
//location 4: Start Addr Running byte 1 
//location 5: Start Addr Running byte 2 (msb) 
//location 6: Acquiring Time (lsb) T = 1s to 999s
//location 7: Acquiring Time (msb)
//location 8: System ID

#include "stdlib.h"

// PIN DECLARATIONS
#byte PORTA     = 0x0F80
#byte PORTB     = 0x0F81
#byte PORTC     = 0x0F82
#byte PORTD     = 0x0F83
#byte PORTE     = 0x0F84
#byte ADCON1    = 0x0FC1

#define START    PIN_B1
#define RESET    PIN_B0
#define CSu    PIN_C1
#define DONE    PIN_B2
#define UART    PIN_C0
#define eSDO   PIN_C5
#define eSCLK  PIN_C3

#bit LCD_BL = PORTA.1
#bit LCD_E2 = PORTA.2
#bit LCD_RS = PORTA.3
//#bit LCD_E1 = PORTA.4
#bit LCD_E1 = PORTD.0
#bit LCD_D4  = PORTE.0
#bit LCD_D5  = PORTA.5
#bit LCD_D6  = PORTE.2
#bit LCD_D7 =  PORTE.1
//       CONSTANTS FOR UNDERSTANDING
#define PC  1
#define FPGA 0
#define SPI_PIC      0x00000100
#define SPI_FPGA     0x00000000
#define EEP0         0x00000000
#define EEP1         0x00000200
#define EEP2         0x00000400
#define EEP3         0x00000600
#define CMD_START    0x08000000
#define CMD_STOP     0x0a000000
#define CMD_STATUS   0x0c000000
#define CMD_CONECT   0x0b000000
#define CMD_EOF   0x0e000000
#define CMD_EOF2   0x0f000000

//Screen Modes
#define REDY  0
#define ACQR   1
#define SEND   2
#define ERAS  3
#define CNCT  4

//Receive Letters
#define lKey   0x100// Left Key
#define dKey   0x200//Down
#define oKey   0x300//Ok
#define uKey   0x400//Up
#define rKey   0x500//Right
#define sAck 0xc00// Acknowledge Start Receieved
#define eAck   0xe00// End of Record Receieved
#define eAck2   0xf00// End of All Records Receieved
#define pAck  0xd00// Page Receieved
#define cAck  0xb00// Connection Receieved


#define ready     1
#define mn_conn   2
#define mn_send  3
#define mn_erase 4
#define mn_main       5
#define mn_acquire   6
#define unitary       8
#define sampling       9
#define impedance        10
#define frequency        11
#define mem_erase     12
#define mn_yes    13
#define tenth       14
#define hunderth       15
#define wait_cAck    16
#define wait_sAck        17
#define wait_pAck1      18
#define wait_eAck    19
#define wait_pAck2    20
#define wait_eAck2    21

//             VARIABLES
unsigned char cntms,cnt40ms;//Count timer
unsigned int16 rxChr;// serial char
unsigned int32 status;// status register
unsigned char Module;// LCD enable 1/2
unsigned char state;//state variable
unsigned int32 Tid;//Test ID
unsigned int32 Sid;//System ID
unsigned int16 T;        // Experiment Time (sec) 3 digits
char T0=0,T1=0,T2=0;
unsigned char Tm;       // Maximum Time (sec) w.r.t Memory M and Rate R
unsigned char M=0;      // Available Memory (MB)
unsigned int8 B=100;    // Battery Percentage
unsigned char R;        // Rate (K-samp/sec)
unsigned int32 Z;     // Impedance
unsigned int32 F;     // Cutoff Frequency
unsigned int32 N;       //Total samples in time T at Rate R (kilo)
char s[10];
boolean kflag=0;
boolean online=0;
boolean expired=0;
//unsigned char AA[256];
//unsigned int32 k;
unsigned int32 StopAddr,StartAddr;
unsigned int32 RecStartAddr,RecStopAddr;
unsigned int32 TOT = 16368;//32752
unsigned int32 page;
unsigned int32 record;

//                   Function Prototypes
void LcdInit();
void LcdWriteCmd(unsigned char c);
void LcdWriteChar(unsigned char var);
void LcdWriteStr(unsigned char *var);
void LcdGotoXY(unsigned char r,unsigned char c);
void EraseEE(void);
void WriteEE(void);
void ReadEE(void);
void SendCmd(unsigned int32 cmd);
void GenStatus(void);
void SendPage(unsigned int32 G, unsigned int32 EEPROM);
void SaveRec(unsigned int32 Test);
void Sel_UART(boolean dev);

///////////////  Make Status bytes from individual bits  ////////////////////
void GenStatus (void)
{
   //reset status variable
   status = 0;
   
   // update rate 3 bits
   //set control signals
   if(R==1)
      status |= 0b111;
   else if (R == 8)
      status |= 0b011;
   else if (R == 16)
      status |= 0b001;
   // update filter clock 2 bits
   if (F==4000)
      status |= 0b01000;
   // update Impedance bit
   if (Z==50)
      status |= 0b100000;

   status = status|(Tid<<16);//shift Tid to 3rd byte
   status = status|(Sid<<11);
   
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP0 | SPI_FPGA | status);

   write_eeprom(0,status&0xff);
   write_eeprom(1,(status>>8)&0xff);
   write_eeprom(2,(status>>16)&0xff);
   delay_ms(1);
   
   //Calculate Tm
   Tm = TOT/(R*4);//Seconds
   //if(T>Tm) T = Tm; //incase R is increased
   N = T; N = N *R;//in Kilo
}

//////////////// Generate individual bits from status bytes ////////////////
void ReloadStatus(void)
{
   status = read_eeprom(2);
   status = (status<<8) + read_eeprom(1);
   status = (status<<8) + read_eeprom(0);
   StartAddr = read_eeprom(5);
   StartAddr = (StartAddr<<8) + read_eeprom(4);
   StartAddr = (StartAddr<<8) + read_eeprom(3);
   T = read_eeprom(7);
   T = (T<<8) + read_eeprom(6);
   
   Sid = read_eeprom(1) & 0xf8;
   Sid = Sid>>3;
   Tid = read_eeprom(2);
   
   // Differentiate
   if ((status&0x07) == 0b001)
      R = 16;
   else if ((status&0x07) == 0b011)
      R = 8;
   else if ((status&0x07) == 0b111)
      R = 1;
      
   if ((status&0x18) == 0)
      F = 400;
   else if ((status&0x18) == 0x08)
      F = 4000;
      
   if ((status&0x20) == 0)
      Z = 324;
   else if ((status&0x20) == 0x20)
      Z = 50;
      
  //M = ((TOT-(StartAddr*2))*100)/TOT;
  M = ((TOT-(StartAddr))*100)/TOT;
}

void SendToPC(void)
{
   unsigned int32 pg;

   for(pg=0;pg<(StopAddr);pg++)
   {
      SendPage(pg,EEP0);
      SendPage(pg,EEP1);
   }
}

//////////////////////////// Read and Send Record of a Test ///////////////////
void ReadRec(unsigned int32 Test)
{
   unsigned int32 TA;
   Sel_UART(FPGA);//
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP0 | SPI_PIC | status);
       
   TA = (Test*10) + 0x3ff000; //last sector

   //Read 
   output_low(CSu);
   spi_write(3);//read cmd
   spi_write((TA>>16)&0xff);//addres
   spi_write((TA>>8)&0xff);
   spi_write(TA&0xff);
   
   TA = spi_read(0);                      // 0: Test ID
   
   TA = spi_read(0);                      // 1: StartAddr MSB
   TA = (TA<<8) + spi_read(0);      // 2: 
   TA = (TA<<8) + spi_read(0);      // 3: StartAddr LSB
   RecStartAddr = TA;
   
   TA = spi_read(0);                      // 4: StopAddr MSB
   TA = (TA<<8) + spi_read(0);      // 5: 
   TA = (TA<<8) + spi_read(0);      // 6: StopAddr LSB
   RecStopAddr = TA;
   
   TA = spi_read(0);                         // 7: Status MSB
   TA = (TA<<8) + spi_read(0);        // 8: 
   TA = (TA<<8) + spi_read(0);       // 9: Status LSB
   
   output_high(CSu);
   delay_ms(20);
   
   Sel_UART(PC);
   SendCmd(CMD_START | RecStartAddr);
   SendCmd(CMD_STOP | RecStopAddr);
   SendCmd(CMD_STATUS | TA);
}

/////////////////// Read a Page from EEPROM and Send to PC /////////////////
void SendPage(unsigned int32 G, unsigned int32 EEPROM)
{
   unsigned char AA[256];
   unsigned int32 k;
   
   Sel_UART(FPGA);

   //Switch EEPROM
   SendCmd(CMD_STATUS | EEPROM | SPI_PIC | status);
   
   //Read
   output_low(CSu);
   spi_write(3);//read command 
   spi_write((G>>8)&0xff);
   spi_write(G&0xff);
   spi_write(0);
   for(k=0;k<256;k++)
      AA[k] = spi_read(0);
   output_high(CSu);
   
   //status sel spi FPGA
   //SendCmd(CMD_STATUS | EEPROM | SPI_FPGA | status);
   
   // Switch to PC UART again
   Sel_UART(PC);
   
   for(k=0;k<256;k++)
      printf("%c",AA[k]);//printf("%2X",AA[k]);
}

///////////////////// Acquire Data from the ADC via FPGA  /////////////////////
void Acquire(void)
{
   //default UART = FPGA

   Sel_UART(FPGA);

   //status sel spi FPGA
   SendCmd(CMD_STATUS | EEP0 | SPI_FPGA | status);
   
   //reload last stop address from mem
   //start address
   StartAddr = read_eeprom(5);
   StartAddr = (StartAddr<<8) + read_eeprom(4);
   StartAddr = (StartAddr<<8) + read_eeprom(3);
   SendCmd(CMD_START | StartAddr);
   
   //stop address
   StopAddr = (unsigned int32) (R*4);//7
   StopAddr = StopAddr *  T;
   StopAddr = StartAddr + StopAddr;

   SendCmd((CMD_STOP | StopAddr)-1);
   
 

   
   //generate START of experiment
   output_high(START);
   delay_us(1);//10
   output_low(START);

   while(DONE==0);
   //Finished, now update Test ID, and save stop address for next page
   M = ((TOT-(StopAddr))*100)/TOT;
   SaveRec(Tid);
   // Save in local memory
   Tid++;
   write_eeprom(2,(Tid)&0xff);
   write_eeprom(3,StopAddr&0xff);
   write_eeprom(4,(StopAddr>>8)&0xff);
   write_eeprom(5,(StopAddr>>16)&0xff);

}
////////////////////// Save Record for a Test  ///////////////////////////////
void SaveRec(unsigned int32 Test)
{
   unsigned int32 TA;
   //SPI_PIC
   SendCmd(CMD_STATUS | EEP0 | SPI_PIC | status);
   
   TA = (Test*10) + 0x3ff000; //last sector
   //enable
   output_low(CSu);
   spi_write(6);
   output_high(CSu);
   delay_ms(1);
   
   //write 
   output_low(CSu);
   spi_write(2);//write cmd
   spi_write((TA>>16)&0xff);//addres
   spi_write((TA>>8)&0xff);
   spi_write(TA&0xff);
   spi_write(Tid&0xff);                // 0: Test ID
   spi_write((StartAddr>>16)&0xff);     // 1: StartAddr MSB
   spi_write((StartAddr>>8)&0xff);      // 2: 
   spi_write(StartAddr&0xff);           // 3: StartAddr LSB
   spi_write((StopAddr>>16)&0xff);         // 4: StopAddr SB
   spi_write((StopAddr>>8)&0xff);      // 5: 
   spi_write(StopAddr&0xff);           // 6: StopAddr MSB
   spi_write((Status>>16)&0xff);           // 7: Status LSB
   spi_write((Status>>8)&0xff);        // 8: 
   spi_write(Status&0xff);         // 9: Status MSB
   
   output_high(CSu);
   //delay_ms(20); //PP Time
   
   // status sel_spi FPGA
   SendCmd(CMD_STATUS | EEP0 | SPI_FPGA | status);
}
//////////////////////// EEPROM ////////////////////////////////////////
void EraseAll(void)
{
   Tid =0;
   StartAddr = 0;
   //M = ((TOT-(StartAddr*2))*100)/TOT;
   M = ((TOT-(StartAddr))*100)/TOT;
   
   write_eeprom(2,0);//Tid
   write_eeprom(3,0);//start address
   write_eeprom(4,0);
   write_eeprom(5,0);
   
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP0 | SPI_PIC | status);
   EraseEE();
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP1 | SPI_PIC | status);
   EraseEE();
/*
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP2 | SPI_PIC | status);
   EraseEE();
   //status sel spi uc
   SendCmd(CMD_STATUS | EEP3 | SPI_PIC | status);
   EraseEE();
   
*/
   delay_ms(35000);
   // status sel_spi FPGA
   SendCmd(CMD_STATUS | EEP0 | SPI_FPGA | status);
   
}

void EraseEE(void)
{
   
   //enable
   output_low(CSu);
   spi_write(6);
   output_high(CSu);
   delay_ms(1);
   
   //chip erase
   output_low(CSu);
   spi_write(0xc7);
   /*
   //block erase
   output_low(CSu);
   spi_write(0xd8);
   spi_write(0);
   spi_write(0);
   spi_write(0);
   */
   output_high(CSu);
   //delay_ms(2000);
}


void WriteEE(unsigned char pp,unsigned int32 EEPROM)
{
   
   unsigned int32 k;
   
     //Switch EEPROM
   SendCmd(CMD_STATUS | EEPROM | SPI_PIC | status);
   //enable
   output_low(CSu);
   spi_write(6);
   output_high(CSu);
   //write 
   output_low(CSu);
   spi_write(2);
   spi_write(0);//addres
   spi_write(pp);//page
   spi_write(0);
   for(k=0;k<256;k++)
      spi_write(k);
   spi_write(k);
   output_high(CSu);
   
   delay_ms(20);

}
void ReadEE(void)
{
   unsigned char AA[256];
unsigned int32 k;
   //read command
   output_low(CSu);
   spi_write(3);
   spi_write(0);//address
   spi_write(0);
   spi_write(0);
   for(k=0;k<256;k++)
      AA[k] = spi_read(0);

   output_high(CSu);
   
}

///////////////////// Send Serial Commands  /////////////////////////////////
void SendCmd(unsigned int32 cmd)
{
   unsigned char nible;
   delay_ms(1);
   nible = (unsigned char)((cmd>>20)&0xf0);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd>>20)&0x0f);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd>>16)&0x0f);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd>>12)&0x0f);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd>>8)&0x0f);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd>>4)&0x0f);
   printf("%c",nible);
   delay_ms(1);
   nible = (unsigned char)((cmd)&0x0f);
   printf("%c",nible);
   delay_ms(5);
}

///////////////////////// Select UART ///////////////////////////////////
void Sel_UART(boolean dev)
{
   delay_ms(5);
   output_bit(UART,dev);
   delay_ms(5);
}

//////////////// Start Timer for acknowledge reception     ////////////////
void Start_TimeOut(void)
{
   setup_timer_1(T1_INTERNAL|T1_DIV_BY_4);   // setup interrupts
   set_timer1(0x3CB0);
   enable_interrupts(INT_TIMER1);
   cntms = 0;
   
}

///////////////////////// Stop Timer         ///////////////////////////////
void Stop_TimeOut(void)
{
   setup_timer_1(T1_DISABLED);
   cntms = 0;
}
/////////////// LCD Screen     ///////////////////////////////////////////
void Display(unsigned char mode)
{
   LcdGotoXY(1,1);
   switch(mode)
   {
      case REDY: LcdWriteStr("READY                         Test ID=");break;
      case ACQR: LcdWriteStr("ACQUIRING DATA                Test ID=");break;
      case SEND: LcdWriteStr("SENDING TO PC                 Test ID=");break;
      case ERAS: LcdWriteStr("ERASING MEMORY                Test ID=");break;
      case CNCT: LcdWriteStr("CONECTING TO PC               Test ID=");break;
   }
   
   LcdWriteChar((Tid/10)+48);LcdWriteChar((Tid%10)+48);
   LcdGotoXY(2,1);
   if(online)
      LcdWriteStr("PC = Online         Test Duration =    s");
   else
      LcdWriteStr("PC = Offline        Test Duration =    s");
   LcdGotoXY(2,37);sprintf(s,"%03Lu",T);LcdWriteStr(s);
   LcdGotoXY(3,1);
   LcdWriteStr("Memory =   %              Battery =    %");
   LcdGotoXY(3,10);sprintf(s,"%2u",M);LcdWriteStr(s);
   LcdGotoXY(3,37);sprintf(s,"%3u",B);LcdWriteStr(s);
   LcdGotoXY(4,1);
   LcdWriteStr("  Ks/s       ohm           Hz           ");
   LcdGotoXY(4,1);sprintf(s,"%02u",R);LcdWriteStr(s);
   LcdGotoXY(4,11);sprintf(s,"%3Lu",Z);LcdWriteStr(s);
   LcdGotoXY(4,24);sprintf(s,"%4Lu",F);LcdWriteStr(s);
   LcdGotoXY(4,34);sprintf(s,"%4LuKs",N);LcdWriteStr(s);
}

void LcdReset()
{
   int1 EN1,EN2;
   if (Module==1)
      {EN1 = 1;EN2 = 0;}
   else
      {EN1 = 0; EN2 = 1;}
   
   delay_ms(15);
   //Send 3
   LCD_D7=0;LCD_D6=0;LCD_D5=1;LCD_D4=1;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(5);
   
   LCD_D7=0;LCD_D6=0;LCD_D5=1;LCD_D4=1;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(5);

   LCD_D7=0;LCD_D6=0;LCD_D5=1;LCD_D4=1;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(5);
   
   LCD_D7=0;LCD_D6=0;LCD_D5=1;LCD_D4=0;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(5);

}
void LcdInit ()
{
   Module = 1;
   LcdReset();
   LcdWriteCmd(0x28);   //Function Set 0x38
   LcdWriteCmd(0x28);   //Function Set
   LcdWriteCmd(0x28);   //Function Set
   LcdWriteCmd(0x06);            //Entry Mode Set 0x06
   LcdWriteCmd(0x0C);            //Display On  Off Control 0x0C
   LcdWriteCmd(0x01);
   Module = 2;
   LcdReset();
   LcdWriteCmd(0x28);   //Function Set 0x38
   LcdWriteCmd(0x28);   //Function Set
   LcdWriteCmd(0x28);   //Function Set
   LcdWriteCmd(0x06);            //Entry Mode Set 0x06
   LcdWriteCmd(0x0C);            //Display On  Off Control 0x0C
   LcdWriteCmd(0x01);
 }
 
void LcdWriteCmd(unsigned char cmd)
{ 
   int1 EN1,EN2;
   if (Module==1)
      {EN1 = 1;EN2 = 0;}
   else
      {EN1 = 0; EN2 = 1;}
   delay_us(10);
   //Upper Nibble   
   LCD_D7=(cmd>>7)&1;LCD_D6=(cmd>>6)&1;LCD_D5=(cmd>>5)&1;LCD_D4=(cmd>>4)&1;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_us(10);
   //Lower Nibble
   LCD_D7=(cmd>>3)&1;LCD_D6=(cmd>>2)&1;LCD_D5=(cmd>>1)&1;LCD_D4=cmd&1;LCD_E1=EN1;LCD_RS=0;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(1);

}

void LcdWriteChar (unsigned char dat)
{ 
   int1 EN1,EN2;
   if (Module==1)
      {EN1 = 1;EN2 = 0;}
   else
      {EN1 = 0; EN2 = 1;}
   delay_us(10);
   LCD_D7=(dat>>7)&1;LCD_D6=(dat>>6)&1;LCD_D5=(dat>>5)&1;LCD_D4=(dat>>4)&1;LCD_E1=EN1;LCD_RS=1;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_us(10);
   LCD_D7=(dat>>3)&1;LCD_D6=(dat>>2)&1;LCD_D5=(dat>>1)&1;LCD_D4=dat&1;LCD_E1=EN1;LCD_RS=1;LCD_E2=EN2;
   LCD_E1=0;LCD_E2=0;
   delay_ms(1);
}
void LcdWriteStr(unsigned char *var)
{
   while(*var)       //till string ends send characters one by one
      LcdWriteChar(*var++);
}

void LcdGotoXY(unsigned char row, unsigned char col)
{
   switch (row)
   {
      case 1: Module= 1; LcdWriteCmd(0x80 + col - 1); break;
      case 2: Module= 1; LcdWriteCmd(0xC0 + col - 1); break;
      case 3: Module= 2; LcdWriteCmd(0x80 + col - 1); break;
      case 4: Module= 2; LcdWriteCmd(0xC0 + col - 1); break;
      default:Module= 1; LcdWriteCmd(0x80 + col - 1); break;
   }
  delay_ms(2);
}
void LcdClear(void)
{
  Module= 1; LcdWriteCmd(0x01);
  Module= 2; LcdWriteCmd(0x01);
  delay_ms(2);
}

////////////////////// EEPROM  //////////////////////////////////////////


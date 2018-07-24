#include <windows.h>
#include <stdio.h> //printf
#include "ftd2xx.h" //ftdi shit
#include <iostream> //######################## Anton
#include <bitset> //debug
#include <stdlib.h> //atof
#include <math.h> //floor



using namespace std; //cout

int main(int argc, char* argv[])
{
    DWORD numDevs;
    DWORD devIndex = 0; // first device
    char Buffer[64]; // more than enough room!
    char usbdevice[] = "FT224BT9";

    FT_HANDLE fthandle;
    FT_STATUS status;
    status = FT_ListDevices(&numDevs,NULL,FT_LIST_NUMBER_ONLY);
    if (status == FT_OK) {
        // FT_ListDevices OK, number of devices connected is in numDevs
        while(status == FT_OK){
            status = FT_ListDevices((PVOID)devIndex,Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER);
            if (status == FT_OK) {
                    cout << Buffer << endl; //######################## Anton
                    cout << usbdevice << endl; //######################## Anton
                    if (!strcmp(Buffer,usbdevice)) //######################## Anton
                    {
                        break;
                    }
            // FT_ListDevices OK, serial number is in Buffer
            }
            devIndex++;
        }
    }
    else {
            printf("ehhhh no");
            return 0;
    // FT_ListDevices failed
    }


    status = FT_Open(devIndex, &fthandle);

    if(status != FT_OK)
    {
    printf("open status not ok %d\n", status);
    return 0;
    }
    status = FT_ResetDevice(fthandle);
     if(status != FT_OK)
     {
         printf("reset status not ok %d\n", status);
         return 0;
     }
    UCHAR Mask = 0xFF; // Set data bus to outputs
    UCHAR mode = 0;
    UCHAR mode1 = 0x40; // Configure FT2232H into 0x40 Sync FIFO mode
    status = FT_SetBitMode(fthandle, Mask, mode); // reset MPSSE
    status = FT_SetBitMode(fthandle, Mask, mode1); // configure FT2232H into Sync FIFO mode
    if(status != FT_OK)
     {
         printf("mode status not ok %d\n", status);
         return 0;
     }
    DWORD data_out = 0x00;
    DWORD data_written;
    INT loop, loopy;

printf("Select mode:\n1.Single voltage CH1\n2.Voltage and zero streaming\n3.Single voltage channel selection\n4.Counter mode mayhem\n5.New Improved version");
                  uint32_t sendbuffer ;
                  uint8_t maskmaker;
                  uint8_t byte1, byte2, byte3, byte4;
                  double a,b;
                  double n;
                  char buffer[256];
                  char ch [64];
                  uint32_t byte2buf;
                  uint32_t byte3buf;
                  uint32_t byte4buf;
                  uint16_t ch1;
int selector;
cin>>selector;
if ((selector>5 || selector<1))
{
        printf("Ciao!");
        return 0;
}

printf("Mode selected: %i ", selector);
switch (selector){
    case 1:
        {
            printf("Single voltage CH1\n\n");
            while (true)
            {
                  printf ("Enter voltage between -15V and 15V: ");
                  cin>>buffer;
                  //fgets (buffer,256,stdin);
                  n = atof (buffer);
                  printf ("Voltage picked %f V\n" , n);
                  //Sanity checks
                  if ((n>15 || n<-15))
                    {
                      printf("Ciao!");
                      return 0;
                    }
                  maskmaker=1;
                  a = ((n+15)/30)*(pow(2,16)-1)-(pow(2,16)/2); // makes 16bit voltage
                  b=0;
                  sendbuffer = (uint32_t)floor(a+0.5);
                  //creates 32bit numbers
                  //printf("sendbuffer= %d\n",sendbuffer);
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  byte1=sendbuffer;
                  byte1=byte1*2; //bitshift
                  sendbuffer=sendbuffer/pow(2,7); //bitshifts send buffer for next 8
                  byte2=sendbuffer;
                  byte2=byte2*2;
                  sendbuffer=sendbuffer/pow(2,7);
                  byte3=sendbuffer;
                  byte3=byte3*2;
                  sendbuffer=sendbuffer/pow(2,7);
                  byte4=sendbuffer;
                  byte4=byte4*2;
                  //cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  //cout<< "byte4                            = "<<bitset<8>(byte4)<<endl;
                  byte1=byte1 xor maskmaker; //adds 1 for first bit
                  sendbuffer=0;
                  sendbuffer=sendbuffer xor byte1; //adds corrected bytes to data out
                  cout<< "sendbyte1 ="<<bitset<32>(sendbuffer)<<endl;
                  byte2buf=0;
                  byte2buf=byte2buf xor byte2;
                  byte2buf=byte2buf*pow(2,8);
                  sendbuffer=sendbuffer xor byte2buf;
                  cout<< "sendbyte2 ="<<bitset<32>(sendbuffer)<<endl;
                  byte3buf=0;
                  byte3buf=byte3buf xor byte3;
                  byte3buf=byte3buf*pow(2,16);
                  sendbuffer=sendbuffer xor byte3buf;
                  byte4buf=0;
                  byte4buf=byte4buf xor byte4;
                  byte4buf=byte4buf*pow(2,24);
                  sendbuffer=sendbuffer xor byte4buf;
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  cout<< "byte1="<<bitset<8>(byte1)<<endl;
                  cout<< "byte2="<<bitset<8>(byte2)<<endl;
                  cout<< "byte3="<<bitset<8>(byte3)<<endl;
                  cout<< "byte4="<<bitset<8>(byte4)<<endl;


                  status = FT_Write(fthandle, &sendbuffer, sizeof(sendbuffer), &data_written);
                  if(status != FT_OK)
                    {
                        cout<< "USB comms failed - quitting!" <<endl;
                        break;
                    }
              }
        }
    case 2:
        {
            printf("Voltage and zero streaming\n\n");
            while (true)
            {
                  printf ("Enter voltage between -15V and 15V: ");
                  cin>>buffer;
                  //fgets (buffer,256,stdin);
                  n = atof (buffer);
                  printf ("Voltage picked %f V\n" , n);
                  //Sanity checks
                  if ((n>15 || n<-15))
                    {
                      printf("Ciao!");
                      return 0;
                    }
                  maskmaker=1;
                  a = ((n+15)/30)*(pow(2,16)-1)-(pow(2,16)/2); // makes 16bit voltage
                  b=0;
                  sendbuffer = (uint32_t)floor(a+0.5);
                  //creates 32bit numbers
                  //printf("sendbuffer= %d\n",sendbuffer);
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  byte1=sendbuffer;
                  byte1=byte1*2; //bitshift
                  sendbuffer=sendbuffer/pow(2,7); //bitshifts send buffer for next 8
                  byte2=sendbuffer;
                  byte2=byte2*2;
                  sendbuffer=sendbuffer/pow(2,7);
                  byte3=sendbuffer;
                  byte3=byte3*2;
                  sendbuffer=sendbuffer/pow(2,7);
                  byte4=sendbuffer;
                  byte4=byte4*2;
                  //cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  //cout<< "byte4                            = "<<bitset<8>(byte4)<<endl;
                  byte1=byte1 xor maskmaker; //adds 1 for first bit
                  sendbuffer=0;
                  sendbuffer=sendbuffer xor byte1; //adds corrected bytes to data out
                  cout<< "sendbyte1 ="<<bitset<32>(sendbuffer)<<endl;
                  byte2buf=0;
                  byte2buf=byte2buf xor byte2;
                  byte2buf=byte2buf*pow(2,8);
                  sendbuffer=sendbuffer xor byte2buf;
                  cout<< "sendbyte2 ="<<bitset<32>(sendbuffer)<<endl;
                  byte3buf=0;
                  byte3buf=byte3buf xor byte3;
                  byte3buf=byte3buf*pow(2,16);
                  sendbuffer=sendbuffer xor byte3buf;
                  byte4buf=0;
                  byte4buf=byte4buf xor byte4;
                  byte4buf=byte4buf*pow(2,24);
                  sendbuffer=sendbuffer xor byte4buf;
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  cout<< "byte1="<<bitset<8>(byte1)<<endl;
                  cout<< "byte2="<<bitset<8>(byte2)<<endl;
                  cout<< "byte3="<<bitset<8>(byte3)<<endl;
                  cout<< "byte4="<<bitset<8>(byte4)<<endl;
                  uint32_t zero=1;
                  cout<<"zero="<<bitset<32>(zero)<<endl;
                  for(int loop=0;loop<100000;loop++)
                  {
                      status = FT_Write(fthandle, &sendbuffer, sizeof(sendbuffer), &data_written);
                      //printf("going");
                      if(status != FT_OK)
                        {
                            cout<< "USB comms failed - quitting!" <<endl;
                            break;
                        }
                      status= FT_Write(fthandle,&zero,sizeof(zero),&data_written);
                      if(status != FT_OK)
                        {
                            cout<< "USB comms failed - quitting!" <<endl;
                            break;
                        }
                  }
              }
        }
    case 3:
        {
            printf("Single voltage and channel selection\n\n");
            while (true)
            {
                  printf ("Enter voltage between -15V and 15V: ");
                  cin>>buffer;
                  //Sanity checks
                  n = atof (buffer);
                  if ((n>15 || n<-15))
                    {
                      printf("Ciao!");
                      return 0;
                    }
                  printf ("Enter channel between 0 and 63: ");
                  cin>>ch;
                  ch1=atoi (ch);
                  //fgets (buffer,256,stdin);
                  printf ("Voltage picked %f V on channel %i\n" , n, ch1);
                  maskmaker=1;
                  a = ((n+15)/30)*(pow(2,16)-1)-(pow(2,16)/2); // makes 16bit voltage
                  b=0;
                  sendbuffer = (uint32_t)floor(a+0.5);
                  //creates 32bit numbers
                  cout<< "sendbuffer= "<<bitset<16>(sendbuffer)<<endl;
                  sendbuffer=pow(2,16)*sendbuffer;
                  sendbuffer=sendbuffer/pow(2,16); //the biggest cheat in history? Quite possibly.
                  ch1=ch1*8; //bitshift 3 places
                  cout<< "channel= "<<bitset<9>(ch1)<<endl;
                  byte1=sendbuffer;
                  byte1=byte1*2; //bitshift
                  sendbuffer=sendbuffer/pow(2,7); //bitshifts send buffer for next 8
                  byte2=sendbuffer;
                  byte2=byte2*2;
                  sendbuffer=sendbuffer/pow(2,7);
                  byte3=sendbuffer;
                  byte3=byte3*2;
                  byte3=ch1 xor byte3; //places channel data
                  ch1=ch1/pow(2,8); //orders channel for next XOR operation
                  sendbuffer=sendbuffer/pow(2,7);
                  byte4=sendbuffer;
                  byte4=byte4*2;
                  byte4=ch1 xor byte4;
                  byte4=byte4*2;
                  //cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  //cout<< "byte4                            = "<<bitset<8>(byte4)<<endl;
                  byte1=byte1 xor maskmaker; //adds 1 for first bit
                  sendbuffer=0;
                  sendbuffer=sendbuffer xor byte1; //adds corrected bytes to data out
                  //cout<< "sendbyte1 ="<<bitset<32>(sendbuffer)<<endl;
                  byte2buf=0;
                  byte2buf=byte2buf xor byte2;
                  byte2buf=byte2buf*pow(2,8);
                  sendbuffer=sendbuffer xor byte2buf;
                  //cout<< "sendbyte2 ="<<bitset<32>(sendbuffer)<<endl;
                  byte3buf=0;
                  byte3buf=byte3buf xor byte3;
                  byte3buf=byte3buf*pow(2,16);
                  sendbuffer=sendbuffer xor byte3buf;
                  byte4buf=0;
                  byte4buf=byte4buf xor byte4;
                  byte4buf=byte4buf*pow(2,24);
                  sendbuffer=sendbuffer xor byte4buf;
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  cout<< "byte1="<<bitset<8>(byte1)<<endl;
                  cout<< "byte2="<<bitset<8>(byte2)<<endl;
                  cout<< "byte3="<<bitset<8>(byte3)<<endl;
                  cout<< "byte4="<<bitset<8>(byte4)<<endl;
                  status = FT_Write(fthandle, &sendbuffer, sizeof(sendbuffer), &data_written);
                  if(status != FT_OK)
                    {
                        cout<< "USB comms failed - quitting!" <<endl;
                        break;
                    }
              }
        }
    case 4:
        {
            printf("Counter mode mayhem\n\n");
            for (int loop=0;loop<100000;loop++)
            {
                sendbuffer=1;
                printf("Loop=%i\n",loop);
                for(int loop1=0;loop1<65536;loop1++)
                {
                    status = FT_Write(fthandle, &sendbuffer, sizeof(sendbuffer), &data_written);
                    //cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                    sendbuffer++;
                    if(status != FT_OK)
                    {
                        cout<< "USB comms failed - quitting!" <<endl;
                        break;
                    }
                }
            }
            printf("Done");
        }
    case 5:
        {
            printf("Single voltage and channel selection new and upgraded and things\n\n");
            while (true)
            {
                  printf ("Enter voltage between -15V and 15V: ");
                  cin>>buffer;
                  //Sanity checks
                  n = atof (buffer);
                  if ((n>15 || n<-15))
                    {
                      printf("Ciao!");
                      return 0;
                    }
                  printf ("Enter channel between 0 and 255: ");
                  cin>>ch;

                  ch1=atoi (ch);
                    if ((ch1>255 || ch1<0))
                    {
                      printf("Ciao!");
                      return 0;
                    }
                  //fgets (buffer,256,stdin);
                  printf ("Voltage picked %f V on channel %i\n" , n, ch1);
                  a = ((n+15)/30)*(pow(2,16)-1)-(pow(2,16)/2); // makes 16bit voltage
                  b=0;
                  sendbuffer = (uint32_t)floor(a+0.5);
                  //creates 32bit numbers
                  cout<< "sendbuffer= "<<bitset<16>(sendbuffer)<<endl;
                  sendbuffer=pow(2,16)*sendbuffer;
                  sendbuffer=sendbuffer/pow(2,16); //the biggest cheat in history? Quite possibly.
                  cout<< "channel= "<<bitset<8>(ch1)<<endl;
                  byte1=sendbuffer;
                  sendbuffer=sendbuffer/pow(2,8); //bitshifts send buffer for next 8
                  byte2=sendbuffer;
                  sendbuffer=sendbuffer/pow(2,8);
                  byte3=ch1; //orders channel for next XOR operation
                  sendbuffer=sendbuffer/pow(2,8);
                  byte4=sendbuffer;

                  //cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  //cout<< "byte4                            = "<<bitset<8>(byte4)<<endl;
                   //adds 1 for first bit
                  sendbuffer=0;
                  sendbuffer=sendbuffer xor byte1; //adds corrected bytes to data out
                  //cout<< "sendbyte1 ="<<bitset<32>(sendbuffer)<<endl;
                  byte2buf=0;
                  byte2buf=byte2buf xor byte2;
                  byte2buf=byte2buf*pow(2,8);
                  sendbuffer=sendbuffer xor byte2buf;
                  //cout<< "sendbyte2 ="<<bitset<32>(sendbuffer)<<endl;
                  byte3buf=0;
                  byte3buf=byte3buf xor byte3;
                  byte3buf=byte3buf*pow(2,16);
                  sendbuffer=sendbuffer xor byte3buf;
                  byte4buf=0;
                  byte4buf=byte4buf xor byte4;
                  byte4buf=byte4buf*pow(2,24);
                  sendbuffer=sendbuffer xor byte4buf;
                  cout<< "sendbuffer="<<bitset<32>(sendbuffer)<<endl;
                  cout<< "byte1="<<bitset<8>(byte1)<<endl;
                  cout<< "byte2="<<bitset<8>(byte2)<<endl;
                  cout<< "byte3="<<bitset<8>(byte3)<<endl;
                  cout<< "byte4="<<bitset<8>(byte4)<<endl;
                  status = FT_Write(fthandle, &sendbuffer, sizeof(sendbuffer), &data_written);
                  if(status != FT_OK)
                    {
                        cout<< "USB comms failed - quitting!" <<endl;
                        break;
                    }
              }
        }
}
  return 0;
     if(status != FT_OK)
     {
         printf("status not ok %d\n", status);
         return 0;
     }
     else
        printf("output data \n");
     status = FT_Close(fthandle);
     return 0;
}

clc
clear all
clf
close all
clear all

pts=5000
%SPS=250
%SPS=1000
%SPS=2000
oldSerial= instrfind;
delete(oldSerial);
clear oldSerial
s=serial('COM2','BaudRate',57600)
s.OutputBufferSize=1;
s.InputBufferSize=1;
fopen(s)
pause(1)
state = 1;
switch(state)
    case 1:
        idn = fscanf(s);
        if(idn == 0xc0)
            state = 2;
        else
            state = 1;
        end if
    case 2:
        idn = fscanf(s);
end    

fclose(s)

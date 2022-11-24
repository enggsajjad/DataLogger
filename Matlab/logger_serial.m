close all
clear all
clc
%%%%%%%%%%%%%% Open Com Port 

oldSerial = instrfind;
delete(oldSerial)
s = serial('COM5', 'BaudRate', 57600, 'Terminator','CR');
fopen(s)
s.ReadAsyncMode = 'continuous';
disp('Com Opened');
%%%%%%%%%%%%%% Com Connection Request 
while (s.BytesAvailable<7 )
end
pause(.1);
a=fread(s,7,'uchar');
fwrite(s,hex2dec('B0'));
disp('Online');
records_rx=0;
records_sent=1;

while (records_rx<records_sent)

    %%%%%%%%%%%%%% Start Address, Stop Address, Status 
    while (s.BytesAvailable<21 )
    end
    pause(.1);
    a=fread(s,21,'uchar');
    start_addr=a(2)*2^20 + a(3)*2^16 + a(4)*2^12 + a(5)*2^8+ a(6)*2^4 + a(7)*2^0;
    stop_addr=a(9)*2^20 + a(10)*2^16 + a(11)*2^12 + a(12)*2^8+ a(13)*2^4 + a(14)*2^0;
    test_id=a(16)*2^4 + a(17)*2^0;
    byte18=a(18)*2^4 + a(19)*2^0;
    device_id=bitshift(byte18,-3);
    EEPROM_id=bitand(byte18,7);
    rate=bitand(a(21),7);

    fwrite(s,a(15)); %send acknowledgment to uC 0xC0
    page_rx=0;
    page_sent=(stop_addr-start_addr)*2;
    page_size=255;

    %%%%%%%%%%%%%% Recieve number of pages in a test
    while (page_rx<page_sent)
        %%%%%%%%%%%%%% 256 Bytes
        while (s.BytesAvailable<page_size )
        end %end of while
        pause(.05)
        a=fread(s,256,'uchar');
        fwrite(s,hex2dec('D0')); %send byte 0xd0
        page_rx=page_rx+1
        
        b(:,page_rx) = a;
    end
    
    %%%%%%%%%%%%%% End of Record (Test)
    while (s.BytesAvailable<7 )
    end
    pause(.1);
    a=fread(s,7,'uchar');
    fwrite(s,hex2dec('E0'));

    %%%%%%%%%%%%%% increment record
    records_rx=records_rx+1

    %%%%%%%%%%%%%% Plot the test
    clear c
    n=1;
    for i=1:1:page_rx
        for j=1:2:256
            c(n) = b(j,i) + b(j+1,i)*256;
            n = n+1;
        end
    end
    figure
    plot (c)
    title(strcat('rate=',num2str(rate),' Start=',num2str(start_addr),' Stop=',num2str(stop_addr)))

end    
    %%%%%%%%%%%%%% end of all records
    while (s.BytesAvailable<7 )
    end
    pause(.1);
    a=fread(s,7,'uchar');
    fwrite(s,hex2dec('F0')); %send byte 0xf0

stopasync(s)
fclose(s)
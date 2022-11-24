% t=0:1/(3*1024):1;
% s = int16(65500*sin(2*pi*100*t))
% plot(t,s)

close all
clc
clear all
 fid = fopen('logger.txt', 'r');
 a1 = fread(fid);
 fclose(fid);
 sz = length(a1);
b = zeros(sz/4,1);
%b=uint16(b);

c = zeros(sz/4,1);
%c=uint16(c)
j = 1;
for i=1:sz-4
    if(a1(i)>57)
        a(i) = a1(i)-55;
    else
        a(i) = a1(i)-48;
    end
end 
for i=1:4:sz-4
    b(j) = (a(i+2)*4096) +(a(i+3)*256) + (a(i)*16) + a(i+1);
    %b(j) = b(j)*256;
    if(b(j)>32768)%8388608)
        c(j) = b(j) - 65536+1;%16777216+1;
    else
        c(j) = b(j);
    end
    j=j+1;
end 
c2 = c-mean(c);
figure
plot(c2(1:end-5))
figure
plot(c(1:end-5))
av=mean(c)
mx=max(c)
mn=min(c)
diff=mx-mn
Amp = 10*diff/(2^16)
%ylim([-32768 32768])
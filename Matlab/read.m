% t=0:1/(3*1024):1;
% s = int16(65500*sin(2*pi*100*t))
% plot(t,s)

 fid = fopen('D:\file.txt', 'r');
 a = fread(fid);
 fclose(fid);
sz = size(a);
b = zeros(3*1024,1);
c = zeros(3*1024,1);
j = 1;
for i=1:sz
    if(a(i)>57)
        a(i) = a(i)-55;
    else
        a(i) = a(i)-48;
    end
end 
for i=5:12:sz-12
    b(j) = (a(i+9)*4096) +(a(i+6)*256) + (a(i+3)*16) + a(i);
    %b(j) = b(j)*256;
    if(b(j)>32768)%8388608)
        c(j) = b(j) - 65536+1;%16777216+1;
    else
        c(j) = b(j);
    end
    j=j+1;
end 
c2 = c;%-mean(c);
figure

plot(c2)
av=mean(c)
mx=max(c)
mn=min(c)
diff=mx-mn
%ylim([-32768 32768])
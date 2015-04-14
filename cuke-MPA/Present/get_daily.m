function daily = get_daily()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
pref='B_04_1998_';
fid=fopen('dir.txt')
dir=textscan(fid, '%16s');
fclose(fid)
par1=zeros(1024*9,5);

for k=1:120
    par1=zeros(1024*9,5);
    for i=1:6
        j=2*((k-1)*6+i);
        txt=[dir{1,1}{j-1,1}, '    ',dir{1,1}{j,1}];
        par=load(txt,'-ascii');
        par1=par1+par/6;
    end
    str=[pref, num2str(k,'%03i'),'.txt'];
    fid=fopen(str,'w');
    fprintf(fid,'%10.4f %10.4f %10.4f %5.1f %4.0f\r\n',par1');
    fclose(fid)
end

end


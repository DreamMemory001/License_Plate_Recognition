function shibiehanzi=ShiBieHanZi(hanzi,xiuzhenghanzi);
[y,x,z]=size(xiuzhenghanzi);
for k=1:6
sum=0;
for i=1:y
    for j=1:x
         if  hanzi(i,j,k)==xiuzhenghanzi(i,j)%ͳ�ƺڰ�
             sum=sum+1;
        end
    end
end
baifenbi(1,k)=sum/(x*y);
end
chepai= find(baifenbi>=max(baifenbi));
shibiehanzi=chepai;%�������У���0��ʼ����Ҫ��һ�����ﲻ��
if       shibiehanzi==1
         shibiehanzi='��';
    elseif shibiehanzi==2
         shibiehanzi='��';
    elseif shibiehanzi==3
         shibiehanzi='��';
    elseif shibiehanzi==4
         shibiehanzi='��';
    elseif shibiehanzi==5
         shibiehanzi='��';
    elseif shibiehanzi==6
         shibiehanzi='³';
    elseif shibiehanzi==7
         shibiehanzi='��';
end
function varargout =gui(varargin) 
gui_Singleton = 1;
%创建一个fig会生成下面的结构体函数
%gui_State是一个结构 ，制定了figure打开和输出的函数 
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton', gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] =gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end
%以上都是自动生成的

%各个函数结束初始化
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
%在这里定义自己的数据结构
%————————————
%更新handles的数据结构,非常重要！

guidata(hObject, handles);

%函数输出返回值的定义
%注意：matlab中 ，function对应的end可以没有，但是随着版本的更新，end会被要求

function varargout =gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%传递数据：
%在MATLAB GUI程序中进行值传递：
%1.利用主函数的handles数据结构传值
%2.利用控件UserData来进行传值



%载入图像
function pushbutton1_Callback(hObject, eventdata, handles)
[filename, pathname]=uigetfile({'*.jpg';'*.bmp'}, 'File Selector');%通过本地路径来找到此图片
I=imread([pathname '\' filename]);%读取此图片进行显示
handles.I=I;%利用句柄调用I资源 ，来显示图片
%更新数据
guidata(hObject, handles);
%建立坐标式视图把图片 显示 在此坐标式视图上
axes(handles.axes1);
imshow(I);title('原图');





%进行图像处理
function pushbutton2_Callback(hObject, eventdata, handles)
I=handles.I;%句柄语句 ，进行 获取 资源 
%rgb2gray是处理图像的函数，通过消除图像色调和饱和度信息同事保留亮度亮度实现
%将将RGB图像活着彩色图转换灰色图像，灰度化处理
I1=rgb2gray(I);
%edge（）根据所指定的敏感阈值thresh（0.16），在所指定的方向（这里指定both 是水平和垂直俩个方向）
%用Sobel算子进行边缘检测。
I2=edge(I1,'roberts',0.16,'both');

axes(handles.axes2);
imshow(I1);title('灰度图');

%axes创建坐标系图形系图形对象
axes(handles.axes3);

imshow(I2);title('边缘检测');
se=[1;1;1];

I3=imerode(I2,se);%腐蚀操作

se=strel('rectangle',[25,25]);%创建由指定图形对应的结构与元素 构造结构元素



I4=imclose(I3,se);%图像聚类，填充图像

I5=bwareaopen(I4,2000); %去除聚团灰度值小于2000的部分

[y,x,z]=size(I5);%返回15各维的尺寸，存储在x,y,z中
%%
myI=double(I5);
tic      %tic计时开始，toc结束
Blue_y=zeros(y,1);%产生一个y*1的零针

for i=1:y
    for j=1:x
        if(myI(i,j,1)==1)%如果myI图像坐标为（i，j）点值为1，即背景颜色为蓝色，blue加一
            Blue_y(i,1)=Blue_y(i,1)+1;%蓝色像素点统计
        end
    end
end

[temp, MaxY]=max(Blue_y);
%————————————————————————————————————
%Y方向车牌区域确定
%temp为向量yellow_y的元素中的最大值，MaxY为该值得索引
PY1=MaxY;

while((Blue_y(PY1,1)>=5)&&(PY1>1))
    PY1=PY1-1;
end
PY1 = PY1 - 5;
PY2=MaxY;
while((Blue_y(PY2,1)>=5)&&(PY2<y))
    PY2=PY2+1;
end
PY2 = PY2 + 5 ;
IY=I(PY1:PY2,:,:);

%————————————————————————————————————
%X方向车牌区域确定
Blue_x=zeros(1,x);%进一步确认x方向的车牌区域
for j=1:x
    for i=PY1:PY2
        if(myI(i,j,1)==1)
            Blue_x(1,j)=Blue_x(1,j)+1;
        end
    end
end
PX1=1;
while((Blue_x(1,PX1)<3)&&(PX1<x))
    PX1=PX1+1;
end
PX2=x;
while((Blue_x(1,PX2)<3)&&(PX2>PX1))
    PX2=PX2-1;
end
%——————————————————————————————————————————
PX1=PX1-3;%对车牌区域的矫正

PX2=PX2+3;


dw=I(PY1:PY2-8,PX1:PX2,:);
t=toc;

axes(handles.axes4);imshow(dw),title('定位车牌');


%------------------------------------------------------------------------------

imwrite(dw,'dw.jpg');%将彩色车牌写入dw文件中
a=imread('dw.jpg');%读取车牌
b=rgb2gray(a);%将车牌图像转换为灰度图
imwrite(b,'灰度车牌.jpg');%将灰度图写入文件
g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/3);%T为二值化的阈值
[m,n]=size(b);

%d =imb2w(b,T/256);
d=(double(b)>=T);%d:二值图像
imwrite(d,'二值化.jpg');
%________________________________
[r,s]=size(d);
YuJingDingWei=double(d);
X2=zeros(1,s);%产生1行s列全零数组
for i=1:r
    for j=1:s
        if(YuJingDingWei(i,j)==1)
            X2(1,j)= X2(1,j)+1;%白色像素点统计
        end
    end
end
[g,h]=size(YuJingDingWei);
ZuoKuanDu=0;YouKuanDu=0;KuanDuYuZhi=5;
while sum(YuJingDingWei(:,ZuoKuanDu+1))~=0
    ZuoKuanDu=ZuoKuanDu+1;
end
if ZuoKuanDu<KuanDuYuZhi   % 认为是左侧干扰
    YuJingDingWei(:,[1:ZuoKuanDu])=0;%给图像d中1到KuanDu宽度间的点赋值为零
    YuJingDingWei=cut_license(YuJingDingWei); % 值为零的点会被切割
end
[e,f]=size(YuJingDingWei);%上一步裁剪了一次，所以需要再次获取图像大小
k=f;
while sum(YuJingDingWei(:,k-1))~=0
    YouKuanDu=YouKuanDu+1;
    k=k-1;
end
if YouKuanDu<KuanDuYuZhi   % 认为是右侧干扰
    YuJingDingWei(:,[(f-YouKuanDu):f])=0;%
    YuJingDingWei=cut_license(YuJingDingWei); %值为零的点会被切割
end


h = YuJingDingWei;
g = bwareaopen(h,20);
e = double(g);


%_____________


[p,q]=size(e);
X3=zeros(1,q);%产生1行q列全零数组
for j=1:q
    for i=1:p
       if(e(i,j)==1) 
           X3(1,j)=X3(1,j)+1;
       end
    end
end
%subplot(1,2,2),plot(0:q-1,X3),title('列方向像素点灰度值累计和'),xlabel('列值'),ylabel('累计像素量');

Px0 = q;%字符右侧限
Px1 = p;%字符左侧限
for i=1:6
    while((X3(1,Px0)<3)&&(Px0>0))
       Px0=Px0-1;
    end
    Px1=Px0;
    while(((X3(1,Px1)>=3))&&(Px1>0)||((Px0-Px1)<15))
        Px1=Px1-1;
    end
    ChePaiFenGe=g(:,Px1:Px0,:);
    %二值化
    
    imwrite(ChePaiFenGe,strcat('pic_',num2str(i),'.jpg')); 
  %  figure(6);subplot(1,7,8-i);imshow(Ch、ePaiFenGe);
    ii1=int2str(8-i);
    imwrite(ChePaiFenGe,strcat(ii1,'.jpg'));%strcat连接字符串。保存字符图像。
    Px0=Px1;
end
%%%%%%%%%%对第一个字符进行特别处理%%%%%%%%%%%


PX3=Px1;%字符1右侧限

while((X3(1,PX3)<3)&&(PX3>0))
       PX3=PX3-1;
end

ZiFu1DingWei=e(:,1:PX3,:);

%自动寻找 二值化最适合的阈值

thresh = graythresh(ZiFu1DingWei);
ZiFu1DingWei = im2bw(ZiFu1DingWei,thresh);
ZiFu1DingWei=imcomplement(ZiFu1DingWei);
%figure(11);
%imshow(ZiFu1DingWei);
imwrite(ZiFu1DingWei,'head.jpg');

%-------------------------------


%均值滤波前
%滤波

h=fspecial('average',3);
%建立预定义的滤波算子，average为均值滤波，模板尺寸为3*3
d=im2bw(round(filter2(h,d)));%使用指定的滤波器h对h进行d即均值滤波
imwrite(d,'均值滤波.jpg');
%某些图像进行操作
%膨胀或腐蚀
se=eye(4);%单位矩阵
[m,n]=size(d);  %返回信息矩阵
if bwarea(d)/m/n>=0.365 %计算二值图像中对象的总面积与整个面积的比是否大于0.365
    d=imerode(d,se); %如果大于0.365则进行腐蚀
elseif bwarea(d)/m/n<=0.235%计算二值图像中对值是否小于0.235
    d=imdilate(d,se); %%如果小于则实现膨胀操作象的总面积与整个面积的比
end
d=bwareaopen(d,100); 
imwrite(d,'膨胀.jpg');

%寻找连续有文字的块，若长度大于某阈值，则认为该块有两个字符组成，需要分割
d = cut_license(d);
[m,n]=size(d);
k1=1;
k2=1;
s=sum(d);
j=1;

while j~=n
    while s(j)==0
        j=j+1;
    end
    k1=j;
    while s(j)~=0 && j<=n-1
        j=j+1;
    end
    k2=j-1;
    if k2-k1>=round(n/6.5)
        [val,num]=min(sum(d(:,[k1+5:k2-5])));
        d(:,k1+num + 5)=0;%分割
    end
end
%再切割
d=cut_license(d);
%切割出7个字符
y1=10;
y2=0.25;
flag=0;
word1=[];
while flag==0
    [m,n]=size(d);
    left=1;
    wide=0;
    while sum(d(:,wide+1))~=0&&wide <= n-2
        wide=wide+1;
    end
    if wide<y1 %认为是左干扰 f
        d(:,[1:wide])=0;
        d=cut_license(d);
    else
        temp=cut_license(imcrop(d,[1 1 wide m]));
        [m,n]=size(temp);
        all=sum(sum(temp));
        two_thirds=sum(sum(temp([round(m/3):2*round(m/3)],:)));
          if two_thirds/all>y2
              flag=1;word1=temp;%word1
          end
        d(:,[1:wide])=0;d=cut_license(d);
    end
end

%%
pic_1 = imread('pic_6.jpg');
thresh = graythresh(pic_1);
pic_1 = im2bw(pic_1,thresh);
pic_1=imcomplement(pic_1);
pic_2 = imread('pic_5.jpg');
thresh = graythresh(pic_2);
pic_2 = im2bw(pic_2,thresh);
pic_2=imcomplement(pic_2);
pic_3 = imread('pic_4.jpg');
thresh = graythresh(pic_3);
pic_3 = im2bw(pic_3,thresh);
pic_3=imcomplement(pic_3);
pic_4 = imread('pic_3.jpg');
thresh = graythresh(pic_4);
pic_4 = im2bw(pic_4,thresh);
pic_4=imcomplement(pic_4);
pic_5 = imread('pic_2.jpg');
thresh = graythresh(pic_5);
pic_5 = im2bw(pic_5,thresh); 
pic_5=imcomplement(pic_5);
pic_6 = imread('pic_1.jpg');
thresh = graythresh(pic_6);
pic_6 = im2bw(pic_6,thresh); 
pic_6=imcomplement(pic_6);

%商用系统程序中归一化大小为40*20
ZiFu1DingWei=imresize(ZiFu1DingWei,[110 55],'bilinear');
word1=imresize(pic_1,[110 55],'bilinear');
word2=imresize(pic_2,[110 55],'bilinear');
word3=imresize(pic_3,[110 55],'bilinear');
word4=imresize(pic_4,[110 55],'bilinear');
word5=imresize(pic_5,[110 55],'bilinear');
word6=imresize(pic_6,[110 55],'bilinear');


axes(handles.axes5);imshow(ZiFu1DingWei),title('1');
axes(handles.axes6);imshow(word1),title('2');
axes(handles.axes7);imshow(word2),title('3');
axes(handles.axes8);imshow(word3),title('4');
axes(handles.axes9);imshow(word4),title('5');
axes(handles.axes10);imshow(word5),title('6');
axes(handles.axes11);imshow(word6),title('7');
%%
%文字识别
HanZi=DuQuHanZi(imread('MuBanKu\sichuan.bmp'),imread('MuBanKu\guizhou.bmp'),imread('MuBanKu\beijing.bmp'),imread('MuBanKu\chongqing.bmp'),...
                imread('MuBanKu\guangdong.bmp'),imread('MuBanKu\shandong.bmp'),imread('MuBanKu\zhejiang.bmp'));
ShuZiZiMu=DuQuSZZM(imread('MuBanKu\0.bmp'),imread('MuBanKu\1.bmp'),imread('MuBanKu\2.bmp'),imread('MuBanKu\3.bmp'),imread('MuBanKu\4.bmp'),...
                   imread('MuBanKu\5.bmp'),imread('MuBanKu\6.bmp'),imread('MuBanKu\7.bmp'),imread('MuBanKu\8.bmp'),imread('MuBanKu\9.bmp'),...
                   imread('MuBanKu\10.bmp'),imread('MuBanKu\11.bmp'),imread('MuBanKu\12.bmp'),imread('MuBanKu\13.bmp'),imread('MuBanKu\14.bmp'),...
                   imread('MuBanKu\15.bmp'),imread('MuBanKu\16.bmp'),imread('MuBanKu\17.bmp'),imread('MuBanKu\18.bmp'),imread('MuBanKu\19.bmp'),...
                   imread('MuBanKu\20.bmp'),imread('MuBanKu\21.bmp'),imread('MuBanKu\22.bmp'),imread('MuBanKu\23.bmp'),imread('MuBanKu\24.bmp'),...
                   imread('MuBanKu\25.bmp'),imread('MuBanKu\26.bmp'),imread('MuBanKu\27.bmp'),imread('MuBanKu\28.bmp'),imread('MuBanKu\29.bmp'),...
                   imread('MuBanKu\30.bmp'),imread('MuBanKu\31.bmp'),imread('MuBanKu\32.bmp'),imread('MuBanKu\33.bmp'));
ZiMu=DuQuZiMu(imread('MuBanKu\10.bmp'),imread('MuBanKu\11.bmp'),imread('MuBanKu\12.bmp'),imread('MuBanKu\13.bmp'),imread('MuBanKu\14.bmp'),...
              imread('MuBanKu\15.bmp'),imread('MuBanKu\16.bmp'),imread('MuBanKu\17.bmp'),imread('MuBanKu\18.bmp'),imread('MuBanKu\19.bmp'),...
              imread('MuBanKu\20.bmp'),imread('MuBanKu\21.bmp'),imread('MuBanKu\22.bmp'),imread('MuBanKu\23.bmp'),imread('MuBanKu\24.bmp'),...
              imread('MuBanKu\25.bmp'),imread('MuBanKu\26.bmp'),imread('MuBanKu\27.bmp'),imread('MuBanKu\28.bmp'),imread('MuBanKu\29.bmp'),...
              imread('MuBanKu\30.bmp'),imread('MuBanKu\31.bmp'),imread('MuBanKu\32.bmp'),imread('MuBanKu\33.bmp'));
ShuZi=DuQuShuZi(imread('MuBanKu\0.bmp'),imread('MuBanKu\1.bmp'),imread('MuBanKu\2.bmp'),imread('MuBanKu\3.bmp'),imread('MuBanKu\4.bmp'),...
                imread('MuBanKu\5.bmp'),imread('MuBanKu\6.bmp'),imread('MuBanKu\7.bmp'),imread('MuBanKu\8.bmp'),imread('MuBanKu\9.bmp')); 
%%%%%%%%%%%4.3、车牌字符识别%%%%%%%%%%%
t=1;
ZiFu1JieGuo=ShiBieHanZi(HanZi,ZiFu1DingWei);   ShiBieJieGuo(1,t)=ZiFu1JieGuo;t=t+1;
ZiFu2JieGuo=ShiBieZiMu (ZiMu, word1);   ShiBieJieGuo(1,t)=ZiFu2JieGuo;t=t+1;

businessCard = imread('膨胀.jpg'); 
ocrResults = ocr(businessCard); 
recognizedText = ocrResults.Text; 
text(600,150,recognizedText,'BackgroundColor',[1,1,1]); 
%title('识别英语和数字'); 
u = strfind(recognizedText,' ');
smap_name = recognizedText(u+1:u+5);
PlateNum = [ShiBieJieGuo,smap_name];
msgbox(PlateNum,'结果');
% ==========================退出系统============================
function pushbutton3_Callback(hObject, eventdata, handles)
close(gcf);
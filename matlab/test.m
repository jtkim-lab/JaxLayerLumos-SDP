% plot total reflection TE in db vs frequency


rSlab_TE_abs1 = [];
rSlab_TM_abs1 = [];
a = [];
rSlab_TE_db = [];
epsr = [];
mur = [];
% xValues = [1.9844 1.6872 1.7771 0.8035 1.0088 ];
% yValues = [4 7 4 8 14 ];

%  xValues = [1.8502 1.9066 0.3037 1.1246 1.4475 ];
%  yValues = [4.0000 4.0000 7.0000 8.0000 15.0000 ];
%  
xValues = [1.9863 1.9883 1.4878 0.8485 0.7742 ];
yValues = [4.0000 4.0000 7.0000 16.0000 11.0000 ];

% xValues = [1];
% yValues = [6];

nVar = length(xValues);
%f = [1 10];
f = 0.1:0.01:1; % frequency runs from 0.1 to 1 ghz
M_epsr = []; M_mur = [];

for i = 1:length(f)
  
  M_epsr(1,i) = 10; % eps of material 1
  M_epsr(2,i) = 50; % eps of material 2
  M_epsr(3,i) = 15; % eps of material 3
  M_epsr(4,i) = 15; % eps of material 4
  M_epsr(5,i) = 15; % eps of material 5

  M_epsr_r(6,i) = 5/(f(i)^0.861); % eps of material 6
  M_epsr_i(6,i) = 8/(f(i)^0.569);
  M_epsr(6,i) = M_epsr_r(6,i)-j*M_epsr_i(6,i);

  M_epsr_r(7,i) = 8/(f(i)^0.778); % eps of material 7
  M_epsr_i(7,i) = 10/(f(i)^0.682);
  M_epsr(7,i) = M_epsr_r(7,i)-j*M_epsr_i(7,i);

  M_epsr_r(8,i) = 10/(f(i)^0.778); % eps of material 7
  M_epsr_i(8,i) = 6/(f(i)^0.861);
  M_epsr(8,i) = M_epsr_r(8,i)-j*M_epsr_i(8,i);

  M_epsr(9,i) = 15; %--------------------9
  M_epsr(10,i) = 15; %-------------------10
  M_epsr(11,i) = 15; %-------------------11
  M_epsr(12,i) = 15; %-------------------12
  M_epsr(13,i) = 15;%--------------------13
  M_epsr(14,i) = 15;%--------------------14
  M_epsr(15,i) = 15;%--------------------15
  M_epsr(16,i) = 15;%--------------------16

  M_mur(1,i) = 1;% mur of material 1
  M_mur(2,i) = 1;%-----------------2

  M_mur_r(3,i) = 5/(f(i)^0.974);%-------------3
  M_mur_i(3,i) = 10/(f(i)^0.961);
  M_mur(3,i) = M_mur_r(3,i)-j*M_mur_i(3,i);

  M_mur_r(4,i) = 3/(f(i)^1);%-------------4
  M_mur_i(4,i) = 15/(f(i)^0.957);
  M_mur(4,i) = M_mur_r(4,i)-j*M_mur_i(4,i);

  M_mur_r(5,i) = 7/(f(i)^1);%-------------5
  M_mur_i(5,i) = 12/(f(i)^1);
  M_mur(5,i) = M_mur_r(5,i)-j*M_mur_i(5,i);

  M_mur(6,i) = 1;%-----------------6
  M_mur(7,i) = 1;%-----------------7
  M_mur(8,i) = 1;%-----------------8

  M_mur_r(9,i) = (35*(0.8^2))/(f(i)^2+0.8^2);
  M_mur_i(9,i) = (35*0.8*f(i))/(f(i)^2+0.8^2);
  M_mur(9,i) = M_mur_r(9,i)-j*M_mur_i(9,i); % mur of matrial 9

  M_mur_r(10,i) = (35*(0.5^2))/(f(i)^2+0.5^2);
  M_mur_i(10,i) = (35*0.5*f(i))/(f(i)^2+0.5^2);
  M_mur(10,i) = M_mur_r(10,i)-j*M_mur_i(10,i); % mur of matrial 10

  M_mur_r(11,i) = (30*(1^2))/(f(i)^2+1^2);
  M_mur_i(11,i) = (30*1*f(i))/(f(i)^2+1^2);
  M_mur(11,i) = M_mur_r(11,i)-j*M_mur_i(11,i); % mur of matrial 11

  M_mur_r(12,i) = (18*(0.5^2))/(f(i)^2+0.5^2);
  M_mur_i(12,i) = (18*0.5*f(i))/(f(i)^2+0.5^2);
  M_mur(12,i) = M_mur_r(12,i)-j*M_mur_i(12,i); % mur of matrial 12

  M_mur_r(13,i) = (20*(1.5^2))/(f(i)^2+1.5^2);
  M_mur_i(13,i) = (20*1.5*f(i))/(f(i)^2+1.5^2);
  M_mur(13,i) = M_mur_r(13,i)-j*M_mur_i(13,i); % mur of matrial 13

  M_mur_r(14,i) = (30*(2.5^2))/(f(i)^2+2.5^2);
  M_mur_i(14,i) = (30*2.5*f(i))/(f(i)^2+2.5^2);
  M_mur(14,i) = M_mur_r(14,i)-j*M_mur_i(14,i); % mur of matrial 14

  M_mur_r(15,i) = (30*(2^2))/(f(i)^2+2^2);
  M_mur_i(15,i) = (30*2*f(i))/(f(i)^2+2^2);
  M_mur(15,i) = M_mur_r(15,i)-j*M_mur_i(15,i); % mur of matrial 15

  M_mur_r(16,i) = (25*(3.5^2))/(f(i)^2+3.5^2);
  M_mur_i(16,i) = (25*3.5*f(i))/(f(i)^2+3.5^2);
  M_mur(16,i) = M_mur_r(16,i)-j*M_mur_i(16,i); % mur of matrial 9

  epsr(1,i) = 1; % eps of infinite medium
  epsr(nVar+2,i) = 1; % eps of air
  mur(1,i) = 1; % mur of infinite medium
  mur(nVar+2,i) = 1; % mur of air
  %

  for a = 1:nVar
    epsr(a+1,i) = M_epsr(yValues(a),i);
    mur(a+1,i) = M_mur(yValues(a),i);
  end

  [rSlab_TE_abs,rSlab_TM_abs] = RMultiSlab(nVar,0,epsr(:,i),mur(:,i),f(i),xValues);
  rSlab_TE_abs1(i,:) = rSlab_TE_abs;
  rSlab_TM_abs1(i,:) = rSlab_TM_abs;
  a(i) = rSlab_TE_abs1(i,nVar+1);
  rSlab_TE_db(i) = 10.*log10(a(i));
end

figure(1);
clf;
semilogx(f,rSlab_TE_db,'r','Linewidth',2.5);
xlabel('frequency(Ghz)')
ylabel('Reflection in dB')
grid
hold on
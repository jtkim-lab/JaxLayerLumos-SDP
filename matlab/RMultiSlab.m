function [rSlab_TE_abs,rSlab_TM_abs] = RMultiSlab(M,Theta_inc,epsr,mur,f,d)

% Calculates the reflection coefficient from multilayer slab
% sinTh: array of sin(th) in all slabs
% k: array of wave number in all slabs
% Kz: k*cos(th) in all slabs
% rFresnel: array of Fresnel reflection coeff at each interface 
% rSlab: Total reflection coeff from multilayered slab
%

f = f*1000000000;



e0 = 8.854187817e-12;
u0 = 1.256637061e-6;

eps = epsr*e0;
mu = mur*u0;
d = d*1e-3; % convert from mm to m
Theta_inc = Theta_inc*pi/180; % convert from degree to radian
sinTh = [];
rFresnel = [];
rSlab_TE = [];
rSlab_TM = [];
sinTh(M+2) = sin(Theta_inc);

%Calculate wave number array in each medium
for i = 1:M+2
    k(i) = 2*pi*f*sqrt(eps(i)*mu(i));
end
kz = [];

%Assign kz for the incidence medium
kz(M+2) = k(M+2)*cos(Theta_inc);

%Calculate sinth array for the slabs
for i = 1:M+1
    sinTh(M+2-i) = (k(M+3-i)*sinTh(M+3-i))/k(M+2-i); 
end

%Calculate kz array for the slabs
for i = 1:M+1
    kz(i) = k(i)*sqrt(1-(sinTh(i))^2);
end

%Calculate rFresnel for E and rFresnelH for H
for i = 1:M+1
  rFresnel(i) = (mu(i)*kz(i+1)-mu(i+1)*kz(i))/(mu(i)*kz(i+1)+mu(i+1)*kz(i));
  rFresnelH(i) = (kz(i)*eps(i+1)-kz(i+1)*eps(i))/(kz(i)*eps(i+1)+kz(i+1)*eps(i));
end

%Calculate rFresnel^2 and rFresnelH^2
rFresnel_abs = (abs(rFresnel)).^2; 
rFresnelH_abs = (abs(rFresnelH)).^2;

   rSlab_TE(1) = -1; % PEC 
%  rSlab_TE(1) = rFresnel(1); % initial value for rSlab_TE
%  rSlab_TM(1) = rFresnelH(1); % initial value for rSlab_TM
   rSlab_TM(1) = -1; % PEC
   
%Calculate rSlab_TE for E and rSlab_TM for H
for i = 2:M+1
  -2j*kz(i)*d(i-1)
  rSlab_TE(i) = (rFresnel(i)+rSlab_TE(i-1)*exp(-2j*kz(i)*d(i-1)))/(1+rFresnel(i)*rSlab_TE(i-1)*exp(-2j*kz(i)*d(i-1)));
  rSlab_TM(i) = (rFresnelH(i)+rSlab_TM(i-1)*exp(-2j*kz(i)*d(i-1)))/(1+rFresnelH(i)*rSlab_TM(i-1)*exp(-2j*kz(i)*d(i-1)));
end

%Calculate rSlab_TE^2 and rSlab_TM^2
rSlab_TE_abs = (abs(rSlab_TE)).^2;
rSlab_TM_abs = (abs(rSlab_TM)).^2;


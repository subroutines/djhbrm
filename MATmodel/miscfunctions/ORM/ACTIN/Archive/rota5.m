function [varargout] = rota5(varargin)

clc; close all; clear all;

if nargin == 2
	rot=varargin{1};
	azel=varargin{2};
	do2D=0; do3D=1;
elseif nargin == 1 
	rot=varargin{1};
	azel = [-60 25];
	do2D=0; do3D=1;
else
	rot = [10 0];
	rot1 = rot;
	azel = [-60 25];
	do2D=0; do3D=1;
	sz = [2.5e-3 2.5e-3 1.6 1.2];
end





%==================================================%
%					SETUP
%--------------------------------------------------%
GaSize = 5.1 / 2;	% Actin Size
fID = 1; % filament ID
% 13 possible rotational angles
Ovec = [0   27.6923   55.3846   83.0769  110.7692  138.4615  166.1538...
			193.8461  221.5384  249.2307  276.9230  304.6153  332.3076];


for fID = 1:5
act(fID).n = 270;
act(fID).ax = 70;
act(fID).ay = 20;
act(fID).az = 70;
act(fID).ox = 0;
act(fID).oy = 0;
act(fID).oz = 0;
act(fID).tx = 0;
act(fID).ty = 0;
act(fID).tz = 0;
act(fID).or = 0;
act(fID).ov = Ovec;
act(fID).r = act(fID).n * GaSize;
act(fID).Oxyz = {act(fID).ox, act(fID).oy, act(fID).oz};
act(fID).Txyz = {act(fID).tx, act(fID).ty, act(fID).tz};
act(fID).Amx = {zeros(2,3)};	% Angle Mx			{?,?,?; ?,?,?} 
act(fID).Rmx = {zeros(4,3)};	% Euler Rotation Mx	{x0,y0,z0; x1,y1,z1; x2,y2,z2; X3,Y3,Z3} 
end



%==================================================%
%					3D ROTATION
%--------------------------------------------------%
if do3D
%------------
% clc; close all; clear all;

phi = 20;			% Phi Z Rotation
tta = 70;			% Theta X Rotation
psy = 0;			% Psy Z Rotation



Oxyz1 = [2; 3; 4];		% Origin of current XY
Txyz1 = [10; 0; 10] + Oxyz1;	% Tip of current XY

Oxyz2 = Oxyz1;
Txyz2 = rotfun(Txyz1, phi, tta, psy) + Oxyz1;

Oxyz3 = Oxyz1;
Txyz3 = rotfun(Txyz2, phi, tta, psy);


Oxyz = [Oxyz1 Oxyz2 Oxyz3];
Txyz = [Txyz1 Txyz2 Txyz3];


for nfil = 1:numel(Oxyz(1,:))
OT(nfil).x = [Oxyz(1,nfil); Txyz(1,nfil)];
OT(nfil).y = [Oxyz(2,nfil); Txyz(2,nfil)];
OT(nfil).z = [Oxyz(3,nfil); Txyz(3,nfil)];
end
OTx = [OT(:).x];
OTy = [OT(:).y];
OTz = [OT(:).z];








%------------------
% Tx = R * sin(tta) * cos(phi) + Ox;
% Ty = R * sin(tta) * sin(phi) + Ox;
% Tz = R * cos(tta) + Oz;

Oxyz3 = Txyz2;
R = 14.1421;

Tx = R * sin(tta) * cos(phi) + Oxyz3(1);
Ty = R * sin(tta) * sin(phi) + Oxyz3(2);
Tz = R * cos(tta) + Oxyz3(3);

Txyz3 = [Tx Ty Tz]';

% Txyz3 = rotfun(Txyz3, phi, tta, psy);
%------------------





%------------------
Oxyz = [Oxyz1 Oxyz2 Oxyz3];
Txyz = [Txyz1 Txyz2 Txyz3];
for nfil = 1:numel(Oxyz(1,:))
OT(nfil).x = [Oxyz(1,nfil); Txyz(1,nfil)];
OT(nfil).y = [Oxyz(2,nfil); Txyz(2,nfil)];
OT(nfil).z = [Oxyz(3,nfil); Txyz(3,nfil)];
end
OTx = [OT(:).x];
OTy = [OT(:).y];
OTz = [OT(:).z];
%------------------



%------------------
OTxR = abs(OTx(2,:) - OTx(1,:));
OTyR = abs(OTy(2,:) - OTy(1,:));
OTzR = abs(OTz(2,:) - OTz(1,:));
for rlen = 1:numel(OTx(1,:))
flen(rlen) = sqrt(OTxR(rlen)^2 + OTyR(rlen)^2 + OTzR(rlen)^2);
OT(rlen).flen = flen(rlen);
end
OTflen = [OT(:).flen];
disp(OTflen)
%------------------




%------------------
FigAnime(OTx, OTy, OTz);
%------------------


%----------------------------------------
end
%==================================================%




%==================================================%
% OTx = [OT(:).x];
% OTy = [OT(:).y];
% OTz = [OT(:).z];
% OTflen = [OT(:).flen];
% varargout = {OTx, OTy, OTz, OTflen};

varargout = {OT};
%==================================================%

end



%{

% fDPhi = @(xyz,phi) ([cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1] * xyz);
% fCTta = @(xyz,tta) ([1 0 0; 0 cos(tta) sin(tta); 0 -sin(tta) cos(tta)] * xyz);
% fBPsy = @(xyz,psy) ([cos(psy) sin(psy) 0; -sin(psy) cos(psy) 0; 0 0 1] * xyz);

Tx = R * sind(tta) * cosd(phi) + Ox;
Ty = R * sind(tta) * sind(phi) + Ox;
Tz = R * cosd(tta) + Oz;

theta = (Ovec-180)*pi/180;
r = 2*ones(size(theta));
[u,v] = pol2cart(theta,r);
feather(u,v);

OTx = {OT(:).x}
OTy = {OT(:).y}
OTz = {OT(:).z}

[OTx{1}(:)]
[OTx{:}]

OTx = [OT(:).x]

% for rlen = 1:numel(xp(:,1))
% flen(rlen) = sqrt(xp(rlen,2)^2 + yp(rlen,2)^2 + zp(rlen,2)^2);
% end
% disp(flen)


view([25 25])
campos([25,-25,25])

% for rotfig = 1:10
% 	figure(Fh1)
% 	view(azel+rot)
% 	rot = rot+rot1;
% 	pause(.3)
% end

% figure(Fh1)
% axis vis3d
% for i=1:36
%    % camorbit(10,0,'camera','z')
%    camorbit(10,0,'camera','z')
%    % pause(.2)
%    drawnow
% end


a11	= cos(psi)*cos(phi) - cos(theta)*sin(phi)*sin(psi)
a12	= cos(psi)*sin(phi) + cos(theta)*cos(phi)*sin(psi)
a13	= sin(psi)*sin(theta)
a21	= -sin(psi)*cos(phi) - cos(theta)*sin(phi)*cos(psi)
a22	= -sin(psi)*sin(phi) + cos(theta)*cos(phi)*cos(psi)
a23	= cos(psi)*sin(theta)
a31	= sin(theta)*sin(phi)
a32	= -sin(theta)*cos(phi)
a33	= cos(theta)

RxA = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)];
RyB = [cos(b) 0 -sin(b); 0 1 0; sin(b) 0 cos(b)];
RzG = [cos(g) sin(g) 0; -sin(g) cos(g) 0; 0 0 1];


RdPhi = [1			0			0;
		 0			cos(Phi)	sin(Phi);
		 0			-sin(Phi)	cos(Phi)]
	 
RcTta = [cos(Tta)	0			-sin(Tta); 
		 0			1			0; 
		 sin(Tta)	0			cos(Tta)]
	 
RbPsi = [cos(Psi)	sin(Psi)	0; 
		 -sin(Psi)	cos(Psi)	0; 
		 0			0			1]

RaMx  = [a11 a12 a13; 
		 a21 a22 a23; 
		 a31 a32 a33];


      |
      |
      |     /|
      |    / |
      | ? /  |
      |  /   |
      | /    |
      |/_____|_________
     /  \    |
    /     \  |
   /  ?     \|   
  /
 /
/

% radPdeg = unitsratio('radian', 'degrees')
% degPrad = unitsratio('degrees', 'radian')

% 2D Rotation Matrix
% R2dMx = [cos(Tta) -sin(Tta); sin(Tta) cos(Tta)];
% fR2dMx = @(ang) [cos(ang) -sin(ang); sin(ang) cos(ang)];
% fR2dMx(Tta)

r = vrrotvec([1 1 1],[1 2 3])

ax = 1
ay = 1
az = 1
t = 70

M = makehgtform('xrotate',t) 
M = makehgtform('yrotate',t) 
M = makehgtform('zrotate',t) 
M = makehgtform('axisrotate',[ax,ay,az],t) 

M = makehgtform('xrotate',t) returns a transform that rotates around the x-axis by t radians.
M = makehgtform('yrotate',t) returns a transform that rotates around the y-axis by t radians.
M = makehgtform('zrotate',t) returns a transform that rotates around the z-axis by t radians.
M = makehgtform('axisrotate',[ax,ay,az],t) Rotate around axis [ax ay az] by t radians.


? (or phi ? ?) alpha is the angle between the x axis and the N axis.
? (or theta ?) beta is the angle between the z axis and the Z axis.
? (or psi ?) gamma is the angle between the N axis and the X axis.

This definition implies that:

? represents a rotation around the z axis,
? represents a rotation around the N axis,
? represents a rotation around the Z axis.

for ? and ?, the range is defined modulo 2? radians. A valid range could be [??,??].
for ?, the range covers ? radians (but is not modulo ?)

? = atan2(z1, -z2)
? = arccos(Z3)
? = atan2(X3, Y3)

[x,y,z] = sph2cart(THETA,PHI,R)

xyzO = [0;
		0;
		0];

xyzT = [5;
		5;
		5];

xyzA = [45;
		20;
		70];

RxA = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)];
RyB = [cos(b) 0 -sin(b); 0 1 0; sin(b) 0 cos(b)];
RzG = [cos(g) sin(g) 0; -sin(g) cos(g) 0; 0 0 1];


% RdPhi = [1 0 0; 0 cos(Phi) sin(Phi); 0 -sin(Phi) cos(Phi)];
% RcTta = [cos(Tta) 0 -sin(Tta); 0 1 0; sin(Tta) 0 cos(Tta)];
% RbPsi = [cos(Psi) sin(Psi) 0; -sin(Psi) cos(Psi) 0; 0 0 1];

% RaMx  = [	a11 a12 a13 ; 
%			a21 a22 a23 ; 
%			a31 a32 a33 ];


% nO1 = fDPhi(Oxyz,zPhi)
% nO2 = fCTta(nO1,xTta)
% nO3 = fBPsy(nO2,zPsy)
% nT1 = fDPhi(Txyz,zPhi)
% nT2 = fCTta(nT1,xTta)
% nT3 = fBPsy(nT2,zPsy)

% nO4 = fDPhi(nO3,zPhi)
% nO5 = fCTta(nO4,xTta)
% nO6 = fBPsy(nO5,zPsy)
% nO6 = nT3;
% nT4 = fDPhi(nT3,zPhi)
% nT5 = fCTta(nT4,xTta)
% nT6 = fBPsy(nT5,zPsy)

% xp = [origin0 tip0; 
%       origin1 tip1]
% xp = [Oxyz(1) Txyz(1); nO3(1) nT3(1); nO6(1) nT6(1)];
% yp = [Oxyz(2) Txyz(2); nO3(2) nT3(2); nO6(2) nT6(2)];
% zp = [Oxyz(3) Txyz(3); nO3(3) nT3(3); nO6(3) nT6(3)];


% Set or get the value of the camera view angle
% camva
% to half or double the zoom use: camzoom(.5) or camzoom(2)
% camzoom(.5)

% vis3d
% campos([-10,-25,25])
% camzoom(.12)


%------------------
% Tx = R * sind(tta) * cosd(phi) + Ox;
% Ty = R * sind(tta) * sind(phi) + Ox;
% Tz = R * cosd(tta) + Oz;

Oxyz3 = Txyz2;
R = 14.1421;

Tx = R * sind(phi) * cosd(tta) + Oxyz3(1);
Ty = R * sind(phi) * sind(tta) + Oxyz3(2);
Tz = R * cosd(phi) + Oxyz3(3);

Txyz3 = [Tx Ty Tz]';

% Txyz3 = rotfun([Tx Ty Tz]', phi, tta, psy);
%------------------

%}



%==================================================%
%				ROTATION FUNCTION
%--------------------------------------------------%
function [fBPsy] = rotfun(xyz, phi, tta, psy)

fDPhi = ([cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1] * xyz);
fCTta = ([1 0 0; 0 cos(tta) sin(tta); 0 -sin(tta) cos(tta)] * fDPhi);
fBPsy = ([cos(psy) sin(psy) 0; -sin(psy) cos(psy) 0; 0 0 1] * fCTta);

end


%==================================================%
%				FIGURE SETUP FUNCTION
%--------------------------------------------------%
function [varargout] = FigSetup(varargin)

scsz = get(0,'ScreenSize');


if nargin == 1 
	Fnum=varargin{1};
	pos = scsz./[2.5e-3 2.5e-3 1.5 2];
elseif nargin == 2
	Fnum=varargin{1};
	pos=scsz./varargin{2};
else
	Fnum=1;
	pos = scsz./[2.5e-3 2.5e-3 1.5 2];
end

Fh = figure(Fnum);
set(gcf,'OuterPosition',pos,'Color',[.9,.9,.9])
varargout = {Fh};

end



%==================================================%
%				FIGURE SETUP FUNCTION
%--------------------------------------------------%
function [varargout] = FigAnime(OTx, OTy, OTz, varargin)


%----------------------------------------
%		FIGURE SETUP
%----------------------------------------
sz = [2.5e-3 2.5e-3 1.6 1.2];
Fh1 = FigSetup(1,sz);
%------------
figure(Fh1)
plot3(OTx,OTy,OTz)
axis([-15 15 -15 15 0 30])
xlabel('X');ylabel('Y');zlabel('Z');
grid on;


% figure(Fh1)
camP0 = campos;
camT0 = camtarget;

nfram = 50;
cxp = linspace(-10,25,nfram);
for cf = 1:nfram
    campos([cxp(cf),-25,25])
    drawnow
	pause(.03)
end


% figure(Fh1)
camP1 = campos;
camT1 = camtarget;



% camT = camT1+5;
camT = camT1;
cTx = 5;
cTy = -5;
cTz = 10;
nfram = 30;
cxt = fliplr(linspace(camT(1)-cTx,camT(1),nfram));
cyt = fliplr(linspace(camT(2)-cTy,camT(2),nfram));
czt = fliplr(linspace(camT(3)-cTz,camT(3),nfram));
cxt = [cxt fliplr(cxt)];
cyt = [cyt fliplr(cyt)];
czt = [czt fliplr(czt)];

for cf = 1:nfram*2
	camtarget([cxt(cf),cyt(cf),czt(cf)])
    drawnow
	pause(.02)
end


% figure(Fh1)
% campos(camP1)
% camtarget(camT1)




varargout = {campos, camtarget};

end





















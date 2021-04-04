function varargout = main_plam(varargin)
% MAIN_PLAM MATLAB code for main_plam.fig
%      MAIN_PLAM, by itself, creates a new MAIN_PLAM or raises the existing
%      singleton*.
%
%      H = MAIN_PLAM returns the handle to a new MAIN_PLAM or the handle to
%      the existing singleton*.
%
%      MAIN_PLAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_PLAM.M with the given input arguments.
%
%      MAIN_PLAM('Property','Value',...) creates a new MAIN_PLAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_plam_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_plam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_plam

% Last Modified by GUIDE v2.5 24-Mar-2021 22:22:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_plam_OpeningFcn, ...
                   'gui_OutputFcn',  @main_plam_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main_plam is made visible.
function main_plam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_plam (see VARARGIN)

% Choose default command line output for main_plam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_plam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_plam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global name
[File_Name, Path_Name] = uigetfile('.jpg','.png');
name = strcat(Path_Name,File_Name);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global name
%%
tic
format short
load database.mat
load t.mat
for i = 1:1
    ii = num2str(i);
    strr = name;
    Img = imread(strr);
    Img = imresize(Img, [512 512]);
    I = rgb2gray(Img);
    cc = rgb2hsv(Img);
%     imshow(cc), impixelinfo
    %% spilt HSV color
    hh = cc(:,:,1);
    ss = cc(:,:,2);
    vv = cc(:,:,3);
    [r1 c1] = size(hh);
    %% segmentation with HSV color space
    for i1 = 1:r1
        for j1 = 1:c1
            if hh(i1,j1) >= 0.10 && hh(i1,j1) <= 0.30 &&...
                    ss(i1,j1) >= 0.50 && ss(i1,j1) <= 0.80 &&...
                    vv(i1,j1) >= 0.20 && vv(i1,j1) <= 0.80
                out(i1,j1) = 255;
            else
                out(i1,j1) = 0;
            end
        end
    end
     %% Post-processing
    out = im2bw(out); % Binary image
    out = bwareaopen(out, 100); % Remove object < 100 out from image
    out = imfill(out, 'holes'); % fill holes
    converted = uint8(out) .* I;
%     imshow(out),impixelinfo
    GLCM2 = graycomatrix(converted,'Offset',[-1 0;0 1]);
    stats = GLCM_Features1(GLCM2,0);
    dataGLCM(i,:) = [stats.autoc stats.contr stats.corrm stats.corrp stats.cprom...
        stats.cshad stats.dissi stats.energ stats.entro stats.homom...
        stats.homop stats.maxpr stats.sosvh stats.savgh stats.svarh...
        stats.senth stats.dvarh stats.denth stats.inf1h stats.inf2h...
        stats.indnc stats.idmnc stats.contr stats.contr stats.contr];
    dataGLCMss = [stats.autoc stats.contr stats.corrm stats.corrp stats.cprom...
        stats.cshad stats.dissi stats.energ stats.entro stats.homom...
        stats.homop stats.maxpr stats.sosvh stats.savgh stats.svarh...
        stats.senth stats.dvarh stats.denth stats.inf1h stats.inf2h...
        stats.indnc stats.idmnc stats.contr stats.contr stats.contr];
   %% Finding Edge
    edged = edge(converted, 'canny');
%     imshow(edged),impixelinfo
    data_edged(i,:) = std2(edged);
    data_edgedss = std2(edged);
    %% Finding gabor
    gaborArray = gabor([4 8],[0 90]); % g = gabor(wavelength,orientation) creates a Gabor filter with the specified wavelength (in pixels/cycle) and orientation (in degrees). 
    gaborMag = imgaborfilt(I,gaborArray);
    data_gaborMag(i,:) = std2(gaborMag);
    data_gaborMagss = std2(gaborMag);
    %%%
    [labeledImage numberOfBlobs] = bwlabel(out, 8);
    blobMeasurements = regionprops(labeledImage, 'Centroid', 'Orientation');
    xCenter = blobMeasurements(1).Centroid(1);
    yCenter = blobMeasurements(1).Centroid(2);
    imshow(I);
    axis on;
    hold on;
    % Plot the centroid.
    plot(xCenter, yCenter, 'b+', 'MarkerSize', 10, 'LineWidth', 3);
    hold on;
    boundaries = bwboundaries(out);
    for k = 1 : length(boundaries)
      thisBoundary = boundaries{k};
      plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 2);
      numberOfBoundaryPoints = length(thisBoundary);
      angle = 0: 10 : 360;
      for a = 1 : length(angle)
          xb = thisBoundary(a,2);
          yb = thisBoundary(a,1);
          angles(a,:) = atand((yb-yCenter) / (xb-xCenter));
          distances(a,:) = sqrt((xb-xCenter).^2+(yb-yCenter).^2);
      end
    end
    stats = regionprops('table',out,'Orientation','Perimeter',...
    'MajorAxisLength','MinorAxisLength');
    Orientationss = mean(stats.Orientation);
    Perimeterss = mean(stats.Perimeter);
    format short
    p = [data_gaborMagss data_edgedss dataGLCMss Orientationss Perimeterss];
    [rr cc] = size(p);
    t = [1	1	1	1	1	2	2	2	2	2];
    %%
    database = [144.097557917073,0.281636352479168,3.50265258072407,3.49428586717221,0.0883836839530333,0.105117111056751,0.953181485327624,0.944317471435751,0.953181485327623,0.944317471435752,38.0564844428618,37.1033943095062,8.00514415237968,7.85117934947858,0.0671859711350294,0.0843474804305284,0.517134273875474,0.514398680444329,1.05223322209305,1.07947943229006,0.968899828767124,0.960461258561644,0.968433684063720,0.959819439663379,0.690248134784736,0.690622706702544,3.49667089652642,3.49667089652642,3.22673067514677,3.22673067514677,8.66639882528585,8.61676362054889,0.995319536792910,1.00270417109237,0.0883836839530333,0.105117111056751,0.244059275901271,0.293575555652591,-0.793124990560281,-0.761874532488486,0.865548603269333,0.857395491238737,0.992743329135667,0.990837107741003,0.998703174977114,0.998438644838319,0.0883836839530333,0.105117111056751,0.0883836839530333,0.105117111056751,0.0883836839530333,0.105117111056751,-8.58954619852694,1082.71900000000;168.098024217259,0.290285949437374,3.99582619863014,3.98360674535225,0.109550819471624,0.133989726027397,0.951322389271980,0.940463250237894,0.951322389271980,0.940463250237894,53.7545426801014,51.9317703209769,9.67370172977457,9.42098136147351,0.0780103351272016,0.0992615582191781,0.486578701178130,0.482983302264021,1.13466984196665,1.16885939203333,0.964513961085290,0.954770377221950,0.963903072589679,0.953631344858808,0.661501651174168,0.661906800391389,3.99739698794490,3.99739698794490,3.42072070694716,3.42072070694716,9.93484977778633,9.87204982755255,1.06629416981944,1.07445489185859,0.109550819471624,0.133989726027397,0.271638946545934,0.330370537597671,-0.782482766109499,-0.745796881911622,0.876019084935356,0.866572981920106,0.991635411653605,0.989318814746897,0.998419707869668,0.998036270934108,0.109550819471624,0.133989726027397,0.109550819471624,0.133989726027397,0.109550819471624,0.133989726027397,-9.76171069283904,1152.58000000000;171.904656068792,0.293121759572240,4.01281571061644,4.00168175146771,0.116384845890411,0.138652764187867,0.947577723524384,0.937547766783926,0.947577723524383,0.937547766783926,51.7418301146999,50.3203503380597,9.24992350659647,9.03474379197858,0.0815343688845401,0.103672333659491,0.465857921046094,0.462115127509891,1.19259522494717,1.23091483432139,0.962986306466080,0.952490266226353,0.962399375088550,0.951415777388405,0.646572284735812,0.647111209637965,4.01747922654721,4.01747922654721,3.44147504892368,3.44147504892368,9.70478026944407,9.63123944423082,1.12180199147525,1.13288019782132,0.116384845890411,0.138652764187867,0.278879136967546,0.340416403751447,-0.780457270644957,-0.741271803500212,0.884696899408402,0.874859537584430,0.991271419433877,0.988827954056978,0.998331992780141,0.997970134647888,0.116384845890411,0.138652764187867,0.116384845890411,0.138652764187867,0.116384845890411,0.138652764187867,0.227456267968677,1179.98300000000;159.959854814347,0.305310143051168,4.82797593566536,4.82256757583170,0.101157350782779,0.111974070450098,0.962682414386553,0.958692058182894,0.962682414386552,0.958692058182895,61.7409932729239,60.2663701390526,9.53850391793864,9.35517683015087,0.0667961105675147,0.0807164261252446,0.450322838895603,0.447143678629625,1.13811900532533,1.16451989315405,0.970353715651500,0.963403814008480,0.969753118746181,0.962542102589192,0.612899033757339,0.613453247309198,4.82014193600171,4.82014193600171,3.75403620352250,3.75403620352250,12.4691329657584,12.4094685539810,1.08030104654232,1.08945143332627,0.101157350782779,0.111974070450098,0.238443973291599,0.282460440034632,-0.808432139433432,-0.780791401268118,0.886874820962279,0.880325726287819,0.992906224530797,0.991339025082604,0.998561430969815,0.998372846745927,0.101157350782779,0.111974070450098,0.101157350782779,0.111974070450098,0.101157350782779,0.111974070450098,-11.0023195949047,1235.86100000000;173.247798755255,0.295656422257758,4.57557943982387,4.56294337084149,0.117997798434442,0.143269936399217,0.953530836110148,0.943578318889375,0.953530836110147,0.943578318889375,59.5599644790690,57.5486245560026,9.53915721060769,9.26799560310656,0.0838047333659491,0.108962206457926,0.433317108956619,0.428443461599847,1.25588649484377,1.30007579448561,0.961821693574690,0.949746590631116,0.961232612446981,0.948719447605175,0.610544581702544,0.611083506604697,4.57749816536204,4.57749816536204,3.66875611545988,3.66875611545988,11.1345446229044,11.0307326592831,1.18400250596483,1.19985743907759,0.117997798434442,0.143269936399217,0.284583469053146,0.352627747674426,-0.780044209803954,-0.737119158707237,0.894046214232290,0.883614932273728,0.991014579028278,0.988233414464151,0.998301905911851,0.997896790038531,0.117997798434442,0.143269936399217,0.117997798434442,0.143269936399217,0.117997798434442,0.143269936399217,-8.06587313059140,1230.90700000000;158.774192793988,0.301457263809070,4.39843750000000,4.38850752201566,0.101088551859100,0.120948507827789,0.958964556783400,0.950902693392843,0.958964556783399,0.950902693392844,56.9997964149394,55.1616862705134,9.50689914437110,9.27256817240051,0.0668266878669276,0.0848061399217221,0.474406344271514,0.470483591415564,1.10197454498941,1.13397715051430,0.970164773422212,0.961791307383399,0.969642345215220,0.960883380947216,0.636091915362035,0.636386221868885,4.39317366568310,4.39317366568310,3.58734405577299,3.58734405577299,11.2953631854251,11.2098654406582,1.04381068503539,1.05674645456145,0.101088551859100,0.120948507827789,0.238618023802008,0.292038238055268,-0.809057872475370,-0.774471546245350,0.881051888684973,0.872618573002928,0.992895864005667,0.990927288797580,0.998572395564039,0.998258494115361,0.101088551859100,0.120948507827789,0.101088551859100,0.120948507827789,0.101088551859100,0.120948507827789,-3.85229618161808,1179.56800000000;138.750880983919,0.304124062742581,4.74882277397261,4.73987509173190,0.104069838551859,0.121965203033268,0.961684516120447,0.955095964059184,0.961684516120448,0.955095964059185,62.8373618443228,60.6653015594931,10.0756155728721,9.81402694024836,0.0646327666340509,0.0841257950097847,0.464346236055100,0.460101658472694,1.08482288283773,1.11952844156808,0.971627514982877,0.962180658329257,0.971133528161001,0.961322258585995,0.626418022260274,0.626815527152642,4.74311819655088,4.74311819655088,3.71095278864971,3.71095278864971,12.5157899014821,12.4211896578555,1.02998289575145,1.04432670172232,0.104069838551859,0.121965203033268,0.228510253461687,0.288999366086820,-0.822084915697070,-0.784401159404317,0.883188685712026,0.874191604439124,0.993182541630744,0.991014545766258,0.998554238091458,0.998255797490869,0.104069838551859,0.121965203033268,0.104069838551859,0.121965203033268,0.104069838551859,0.121965203033268,-10.5548290593758,1173.94300000000;163.975605540384,0.293206086087737,4.75109696061644,4.74337619251468,0.110865643346380,0.126307179549902,0.957959906561963,0.952104498112344,0.957959906561962,0.952104498112343,56.5710679626205,54.7987770717843,8.96298378227498,8.74023892084326,0.0725293542074364,0.0917395425636008,0.445980233990643,0.441365125728303,1.16547196067136,1.20306762171066,0.967763754688519,0.958267401031474,0.967187309756621,0.957326843243884,0.609967435176125,0.610510182240705,4.74841117485629,4.74841117485629,3.73521587573386,3.73521587573386,12.0974902121482,11.9924941970744,1.10195281164962,1.11901254154900,0.110865643346380,0.126307179549902,0.252109666350788,0.310098913826316,-0.801937176439393,-0.763290203076786,0.888771759450918,0.879493967472391,0.992302092409113,0.990146099975937,0.998433301467827,0.998163391111479,0.110865643346380,0.126307179549902,0.110865643346380,0.126307179549902,0.110865643346380,0.126307179549902,-4.20516285562466,1231.19100000000;162.778620602613,0.294832657825604,4.18175146771037,4.17404216609589,0.106638331702544,0.122056934931507,0.954663447411646,0.948108334395824,0.954663447411646,0.948108334395824,53.7399438938938,52.2356377345846,9.48757232845400,9.29590908372752,0.0710463551859100,0.0876651174168297,0.485788400697438,0.482168441432891,1.09485174813166,1.12568649558542,0.968263311317678,0.960333407228474,0.967686214369837,0.959336283742949,0.651399675880626,0.651923312133072,4.18065856814151,4.18065856814151,3.49799718688845,3.49799718688845,10.6774136078520,10.6006989437450,1.03228152510027,1.04474268237624,0.106638331702544,0.122056934931507,0.250256018152839,0.300566534961242,-0.800281078240470,-0.766492914654717,0.876308358017842,0.867844064752760,0.992442076212410,0.990597858786001,0.998487449357788,0.998228146813263,0.106638331702544,0.122056934931507,0.106638331702544,0.122056934931507,0.106638331702544,0.122056934931507,-2.40885174113049,1188.57700000000;168.158606233587,0.301563238184671,4.62266465875734,4.61267352617417,0.112960188356164,0.132942453522505,0.955566942078948,0.947706888387019,0.955566942078947,0.947706888387018,56.0404443112435,54.2251824195604,8.85458351413103,8.61523926377369,0.0748302959882583,0.0971593688845401,0.451642962391868,0.446262330474334,1.15625203041758,1.19533410307044,0.966547861117906,0.955618196550881,0.965993702044833,0.954697299263488,0.611767673679061,0.612214866682975,4.62169884608916,4.62169884608916,3.69216303816047,3.69216303816047,11.7390040164000,11.6239550448018,1.09073014581578,1.10906675909130,0.112960188356164,0.132942453522505,0.258517975868849,0.323022003905355,-0.798906796758431,-0.758309063221809,0.886128871249569,0.876220913578822,0.992042873769115,0.989553038167122,0.998403058784548,0.998069441523865,0.112960188356164,0.132942453522505,0.112960188356164,0.132942453522505,0.112960188356164,0.132942453522505,0.565819608354880,1226.30100000000];
    [pn,ps] = mapminmax(database');
    [tn,ts] = mapminmax(t);
    net=newff(pn,tn,[54 30 10 30 10 2],{'tansig' 'tansig' 'tansig' 'tansig' 'tansig' 'purelin'},'trainrp');
    
    net.trainParam.show = 1000;
    net.trainParam.epochs = 5000;
    net.trainParam.goal = 1e-5;
    net = train(net, pn, tn);
    aaa = sim(net, p');
    y2 = round(mapminmax('reverse',aaa,ts))
end
type1 = {'RRIM600'};
type2 = {'RRIT251'};
if y2==1
    set(handles.text2, 'String', type1);
end
if y2==2
    set(handles.text2, 'String', type2);
end
error = abs(y2-t');
yy = find(error==0);
[errorr errorc] = size(error);
total = errorr;
[rrr ccc] = size(yy);
format short
percenge_acuracy = ((total-rrr)/total)*100;
formatSpec = 'percenge acuracy is %f percenge \n';
fprintf(formatSpec,percenge_acuracy)
set(handles.text4, 'String', percenge_acuracy);
asa=toc;
set(handles.text3, 'String', asa);

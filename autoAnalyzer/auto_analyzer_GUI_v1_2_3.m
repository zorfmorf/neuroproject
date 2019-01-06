

function auto_analyzer_GUI_v1_2_3()

clear;
close all;

%% UI Menu Settings

hFig = figure('Units','normalized','Position',[1 0.05 .49 .85],'MenuBar','None');

% ------------Set menu and toolbar-----------------------------------------
menu1 = uimenu(hFig,'Label','File');
uimenu(menu1,'Label','Load .mat tracks','Callback',@LoadMatTracksCB);
uimenu(menu1,'Label','Batch Processing','Callback',@BatchProcessingCB);
handles.menuVideo = uimenu(menu1,'Label','Create Movie','Callback',@MakeVideoCB, 'Enable','off');

menu2 = uimenu(hFig,'Label','Analysis');
handles.menuTrackLifes = uimenu(menu2,'Label','Track lifes','Callback',@AnalysisModeCB,'Checked','on');
handles.menuHoechst = uimenu(menu2,'Label','Hoechst regions','Callback',@AnalysisModeCB);
handles.menuColocalization = uimenu(menu2,'Label','Colocalization','Callback',@AnalysisModeCB);
handles.menuDiffusion = uimenu(menu2,'Label','Diffusion','Callback',@AnalysisModeCB);
handles.menuITM = uimenu(menu2,'Label','ITM','Callback',@AnalysisModeCB);

menuSettings = uimenu(hFig,'Label','Settings');
handles.menuFilter = uimenu(menuSettings,'Label','Filter Preferences','Callback',@MenuSettingsCB);
handles.menuAcquisition = uimenu(menuSettings,'Label','Acquisition Parameters','Callback',@MenuSettingsCB);% TODO change settings
handles.menuFitting = uimenu(menuSettings,'Label','Fitting Parameters','Callback',@MenuSettingsCB);
handles.menuTracking = uimenu(menuSettings,'Label','Tracking Parameters','Callback',@MenuSettingsCB);
set(hFig,'toolBar','figure');

% Delete unnecessary toolbar icons
hToolbar = findall(hFig,'Type','uitoolbar');
hToDelete = [...
    findall(hToolbar, 'ToolTipString','Print Figure'),...
    findall(hToolbar, 'ToolTipString','Save Figure'),...
    findall(hToolbar, 'ToolTipString','New Figure'),...
    findall(hToolbar, 'ToolTipString','Open File'),...
    findall(hToolbar, 'ToolTipString','Edit Plot'),...
    findall(hToolbar, 'ToolTipString','Rotate 3D'),...
    findall(hToolbar, 'ToolTipString','Brush/Select Data'),...
    findall(hToolbar, 'ToolTipString','Link Plot'),...
    findall(hToolbar, 'ToolTipString','Insert Legend'),...
    findall(hToolbar, 'ToolTipString','New Figure'),...
    findall(hToolbar, 'ToolTipString','Hide Plot Tools'),...
    findall(hToolbar, 'ToolTipString','Show Plot Tools and Dock Figure')];
delete(hToDelete)

handles.axes1 = axes('Units','normalized','Position',[0.05 0.23 .7 .7]);

%% UI Controls
% ------------Standart UIcontrol options--------------------------
uiArgs.Button = {'Units','normalized','Style','pushbutton','Enable','off'};
uiArgs.Text = {'Units','normalized','Style','Text','HorizontalAlignment','Left'};
uiArgs.Edit = {'Units','normalized','Style','Edit','Enable','off'};
uiArgs.Slider = {'Units','normalized','Enable','off','Style','slider'};
uiArgs.Chkbox = {'Units','normalized','Enable','off','Style','Checkbox'};
% -------------Buttons on the upper part of the GUI-------------------------------------

%Load Stack and divide into substacks buttons
handles.uiControls.btnLoadStack = uicontrol(uiArgs.Button{:},'String','Load stack','Position',[0.05 0.96 0.13 0.035],'Callback',@LoadStackCB,'Enable','on');
handles.uiControls.btnSubstacks = uicontrol(uiArgs.Button{:},'String','Divide into substacks','Position',[0.2 0.96 0.13 0.035],'Callback',@DivideIntoSubstacksCB);
handles.uiControls.textFrametime = uicontrol(uiArgs.Text{:},'Position',[.4 .955 .3 .03],'String','Frame time [ms]');
handles.uiControls.editFrametime = uicontrol(uiArgs.Edit{:},'Position',[.49 .965 .03 .025],'String','50','Enable','on','Callback',@UpdateSettingsCB);
handles.uiControls.textPixelsize = uicontrol(uiArgs.Text{:},'Position',[.55 .955 .1 .03],'String','Pixel size [?m]');
handles.uiControls.editPixelsize = uicontrol(uiArgs.Edit{:},'Position',[.63 .965 .04 .025],'String','0.160','Enable','on','Callback',@UpdateSettingsCB);
handles.uiControls.textStackName = uicontrol(uiArgs.Text{:},'Style','Text','HorizontalAlignment','Left','Position',[0.05 0.93 0.7 0.02],'String','Stack Name: ','Enable','on');

% -------------Buttons on the right part of the GUI-------------------------------------

%ROI buttons und Filter image button
handles.uiControls.btnReset = uicontrol(uiArgs.Button{:},'String','Reset','Position',[0.78 0.95 0.13 0.035],'Callback',@Reset);
handles.uiControls.btnAddROI = uicontrol(uiArgs.Button{:},'String','Add ROI','Position',[0.78 0.9 0.13 0.035],'Callback',@AddROICB);
handles.uiControls.btnFilter = uicontrol(uiArgs.Button{:},'String','Filter Stack','Position',[0.78 0.85 0.1 0.035],'Callback',@FilterCB);
handles.uiControls.textBpass = uicontrol(uiArgs.Text{:},'Position',[0.9 0.85 0.04 0.035],'String','Object size');
handles.uiControls.editBpass = uicontrol(uiArgs.Edit{:},'Position',[0.95 0.85 0.04 0.035],'String','3','Enable','on');

%SNR & Threshold textbox
handles.uiControls.textSNR = uicontrol(uiArgs.Text{:},'Position',[0.78 0.79 0.07 0.035],'String','SNR');
handles.uiControls.editSNR = uicontrol(uiArgs.Edit{:},'Position',[0.87 0.8 0.04 0.035],'String','5','Callback',@SNRInTCB,'UserData','uiControls.editSNR');
handles.uiControls.textInT = uicontrol(uiArgs.Text{:},'Position',[0.78 0.74 0.07 0.035],'String','Threshold');
handles.uiControls.editInT = uicontrol(uiArgs.Edit{:},'Position',[0.87 0.75 0.04 0.035],'String','0','Callback',@SNRInTCB,'UserData','uiControls.editInT');
handles.uiControls.textFrames = uicontrol(uiArgs.Text{:},'Position',[0.78 0.70 0.08 0.035],'String','Analyse frames from');
handles.uiControls.textFrames = uicontrol(uiArgs.Text{:},'Position',[0.92 0.685 0.08 0.035],'String','to');
handles.uiControls.editStartFrame = uicontrol(uiArgs.Edit{:},'Position',[0.87 0.70 0.04 0.035],'String','1','Callback',@SNRInTCB);
handles.uiControls.editEndFrame = uicontrol(uiArgs.Edit{:},'Position',[0.94 0.70 0.04 0.035],'String','1','Callback',@SNRInTCB);

%Find spots, fit spots button
handles.uiControls.btnFindSpots = uicontrol(uiArgs.Button{:},'String','Find Spots','Position',[0.78 0.65 0.13 0.035],'Callback',@FindSpotsCB);
handles.uiControls.btnFitSpots = uicontrol(uiArgs.Button{:},'String','Fit Spots','Position',[0.78 0.6 0.13 0.035],'Callback',@FitSpotsCB);

%Frames to analyze, Darktime, Shortest Track % Displacement textbox
handles.uiControls.textMaxJump = uicontrol(uiArgs.Text{:},'Position',[0.78 0.55 0.08 0.035],'String','Max Displacement');
handles.uiControls.editMaxJump = uicontrol(uiArgs.Edit{:},'Position',[0.88 0.55 0.03 0.035],'String','1');
handles.uiControls.textMinLength = uicontrol(uiArgs.Text{:},'Position',[0.78 0.5 0.07 0.035],'String','Shortest Track');
handles.uiControls.editMinLength = uicontrol(uiArgs.Edit{:},'Position',[0.88 0.5 0.03 0.035],'String','2');
handles.uiControls.textDarkFrames = uicontrol(uiArgs.Text{:},'Position',[0.78 0.44 0.07 0.035],'String','Dark Frames');
handles.uiControls.editDarkFrames = uicontrol(uiArgs.Edit{:},'Position',[0.88 0.45 0.03 0.035],'String','0');

%Find Tracks, create Histogram and save button
handles.uiControls.btnFindTracks = uicontrol(uiArgs.Button{:},'String','Find Tracks','Position',[.78 .4 .13 .035],'Callback',@FindTracksCB);
handles.uiControls.btnAddROE = uicontrol(uiArgs.Button{:},'String','Add Exclusions','Position',[.78 .35 .1 .035],'Callback',@AddROECB);
handles.uiControls.btnDelROE = uicontrol(uiArgs.Button{:},'String','Delete Exclusions','Position',[.89 .35 .1 .035],'Callback',@DelROECB);
handles.uiControls.btnCreateHistogram = uicontrol(uiArgs.Button{:},'String','Create Histogram','Position',[.78 .3 .13 .035],'Callback',@CreateHistogramCB);
handles.uiControls.btnSave = uicontrol(uiArgs.Button{:},'String','Save .txt and .mat file','Position',[.78 .2 .13 .035],'Callback',@SaveTxtAndMatCB);
% handles.uiControls.btnSaveXML = uicontrol(uiArgs.Button{:},'String','Save .XML file','Enable','on','Position',[.92 .25 .07 .035],'Callback',@SaveXMLCB);
% handles.uiControls.btnTest = uicontrol(uiArgs.Button{:},'String','Test','Enable','on','Position',[.92 .25 .07 .035],'Callback',@TestCB);

%Other analysis tools
handles.uiControls.btnHoechstRegions = uicontrol(uiArgs.Button{:},'Position',[.78 .25 .1 .035],'String','Define Regions','Visible','off','Callback',@HoechstRegionsCB);
handles.uiControls.btnHoechstTrackAssign = uicontrol(uiArgs.Button{:},'Position',[.89 .25 .1 .035],'String','Assign Tracks','Visible','off','Callback',@HoechstTracksCB);
handles.uiControls.btnDiffusionAna = uicontrol(uiArgs.Button{:},'Position',[.78 .4 .13 .035],'String','Find Diffusion Tracks','Visible','off','Callback',@DiffusionAnalysisCB);
handles.uiControls.btnDiffusionAna = uicontrol(uiArgs.Button{:},'Position',[.78 .4 .13 .035],'String','Find Diffusion Tracks','Visible','off','Callback',@DiffusionAnalysisCB);
handles.uiControls.textColocalize = uicontrol(uiArgs.Text{:},'Position',[.78 .25 .08 .03],'Visible','off','String','Colocalization radius');
handles.uiControls.editColocalize = uicontrol(uiArgs.Edit{:},'Position',[.88 .25 .03 .03],'Visible','off','String','4','Enable','on','Callback',@UpdateSettingsCB);
handles.uiControls.btnColocalize = uicontrol(uiArgs.Button{:},'Position',[.78 .20 .13 .035],'String','Colocalize Tracks','Enable','on','Visible','off','Callback',@ColocalizeCB);

% -------Buttons in the lower part of the GUI-------------------------------------------------------------

handles.uiControls.popOriFil = uicontrol('Units','normalized','Style','popupmenu','String',{'Original','Filtered'},'Enable','off','Position',[.05 .12 .1 .07],'Callback',@UpdateSettingsCB);
handles.uiControls.popSubstack = uicontrol('Units','normalized','Style','popupmenu','String',{'Substack 1','Substack 2'},'Enable','off','Position',[.17 .12 .1 .07],'Callback',@UpdateSettingsCB);

%Textboxes for tracklengths' range
handles.uiControls.textTrackRange1 = uicontrol(uiArgs.Text{:},'Position',[.32 .16 .3 .03],'String','Tracklength range');
handles.uiControls.textTrackRange3 = uicontrol(uiArgs.Text{:},'Position',[.36 .135 .1 .03],'String','to');
handles.uiControls.editTrackMin = uicontrol(uiArgs.Edit{:},'Position',[.32 .14 .03 .03],'String','1','Callback',@UpdateSettingsCB);
handles.uiControls.editTrackMax = uicontrol(uiArgs.Edit{:},'Position',[.38 .14 .03 .03],'String','1','Callback',@UpdateSettingsCB);

%Checkbox for showing spots and tracks
handles.uiControls.ckboxSpots = uicontrol(uiArgs.Chkbox{:},'String','Show Spots','Position',[.48 .165 .1 .03],'Callback',@UpdateSettingsCB);
handles.uiControls.ckboxUniformTrackColor = uicontrol(uiArgs.Chkbox{:},'String','Uniform Track Color','Position',[.48 .135 .2 .03],'Callback',@UpdateSettingsCB);
handles.uiControls.ckboxPlotPixels = uicontrol(uiArgs.Chkbox{:},'String','Plot Pixel Boundaries','Visible','off','Position',[.48 .135 .15 .03],'Callback',@UpdateSettingsCB);
handles.uiControls.popTracks = uicontrol('Units','normalized','Style','popupmenu','String',{'Show all Tracks','Show Tracks in Frame','Show all Tracks until Frame','Hide Tracks'},'Enable','off','Position',[.59 .12 .17 .07],'Callback',@UpdateSettingsCB);

%Frame and brightness selections
handles.uiControls.sliderFrame = uicontrol(uiArgs.Slider{:},'Position',[.05 .2 .65 .02],'Min',1,'Max',2,'Value',1,'SliderStep',[1 1]);
handles.uiControls.sliderFrameListener = addlistener(handles.uiControls.sliderFrame,'Value','PostSet',@(~,~) SliderListenerCB('sliderFrame'));
handles.uiControls.editFrameNum = uicontrol(uiArgs.Edit{:},'Position',[.71 .197 .025 .025],'String','');

handles.uiControls.sliderBlack = uicontrol(uiArgs.Slider{:},'Position',[.05 .11 .5 .02],'Min',0,'Max',65535,'Value',0,'SliderStep',[1/20 1/10]);
handles.uiControls.sliderWhite = uicontrol(uiArgs.Slider{:},'Position',[.05 .08 .5 .02],'Min',0,'Max',65535,'Value',65535,'SliderStep',[1/20 1/10]);
handles.uiControls.sliderBlackListener = addlistener(handles.uiControls.sliderBlack,'Value','PostSet',@(~,~) SliderListenerCB('sliderBlack'));
handles.uiControls.sliderWhiteListener = addlistener(handles.uiControls.sliderWhite,'Value','PostSet',@(~,~) SliderListenerCB('sliderWhite'));

handles.uiControls.ckboxBrightness = uicontrol(uiArgs.Chkbox{:},'Position',[.58 .11 .15 .03],'String','Auto adjust brightness','Callback',@UpdateSettingsCB);
handles.uiControls.ckboxContrast = uicontrol(uiArgs.Chkbox{:},'Position',[.58 .085 .15 .03],'String','Enhace contrast','Callback',@UpdateSettingsCB);
handles.uiControls.ckboxAdaptive = uicontrol(uiArgs.Chkbox{:},'Position',[.58 .06 .2 .03],'String','Adaptive contrast enhancement','Callback',@UpdateSettingsCB);
handles.uiControls.ckboxAverage = uicontrol(uiArgs.Chkbox{:},'Position',[.58 .035 .2 .03],'String','Average stack','Callback',@UpdateSettingsCB);
handles.uiControls.editAverage = uicontrol(uiArgs.Edit{:},'Position',[.69 .039 .03 .02],'String','5','Callback',@UpdateSettingsCB);
handles.uiControls.ckboxStd= uicontrol(uiArgs.Chkbox{:},'Position',[.58 .01 .2 .03],'String','Show standard deviation','Callback',@UpdateSettingsCB);

handles.params = struct( ...
    'curvatureThreshold',   0, ...     %Threshold for 2nd order derivative filter (0 == off)
    'intensityThreshold',   0, ...   %Threshold for intensity filter
    'windowSize',           7, ...     %Side lenght of the area used for fitting in fit_spots
    'minWidth',             0, ...     %Minimum Variance in x -and y-direction of Gaussian -> if smaller than minWidth, spot is discarted
    'maxWidth',             3, ...     %Maximum variance x -and y-direction of Gaussian -> if bigger than minWidth, spot is discarted
    'angle',                -0 * pi/180, ... %Orientation of 2D-Gaussian
    'SNR',                  0);       %SNR which was used to calculate InT

%// IMPORTANT. Update handles structure.
guidata(hFig,handles);
gcp; % Start parallel pool. If no pool, create a new one.

%% Functions

%Executed when any slider is moved
    function SliderListenerCB(srcName)
        %Take care that the black and white brightness sliders do not cross
        if strcmp(srcName,'sliderBlack') && handles.uiControls.sliderBlack.Value > handles.uiControls.sliderWhite.Value
            handles.uiControls.sliderWhite.Value = handles.uiControls.sliderBlack.Value + 1;
        elseif strcmp(srcName,'sliderWhite') && handles.uiControls.sliderWhite.Value < handles.uiControls.sliderBlack.Value
            handles.uiControls.sliderBlack.Value = handles.uiControls.sliderWhite.Value -1;
        end
        UpdatePlot('CurrentStack');
    end
%Executed by mouse wheel for scrolling through frames
    function wheel(~, callbackdata, handles)
        curFrame = round((get(handles.uiControls.sliderFrame,'Value')));
        %Take care that the frame number stays inside the frame range
        if curFrame + callbackdata.VerticalScrollCount > handles.uiControls.sliderFrame.Max
            handles.uiControls.sliderFrame.Value = handles.uiControls.sliderFrame.Max;
        elseif curFrame + callbackdata.VerticalScrollCount < 1
            handles.uiControls.sliderFrame.Value = handles.uiControls.sliderFrame.Min;
        else
            handles.uiControls.sliderFrame.Value = curFrame + callbackdata.VerticalScrollCount;
        end
    end

    function BatchProcessingCB(~,~)
        %% --------Load image stack and filename-----------
        handles = guidata(gcf);
        
        [FileName,pathName] = uigetfile('*.tif','Select files to track spots', 'MultiSelect', 'on');
        
        if isequal(FileName,0) %User did'nt choose a file
            return
        end
        
        numberfiles = 1;
        if iscell(FileName) %Check if multiple files have been chosen
            numberfiles = length(FileName);
        end
        
        cd(char(pathName));
        
        %% ----Dialog: Intensity Threshold or SNR-------------------
        d = dialog('Position',[400 500 300 180],'Name','Settings','KeyPressFcn',@keyPressedCB);
        bg = uibuttongroup('Parent',d,'Visible','off','Position',[0 0.22 1 0.45]);
        
        % Create radio buttons, text field and ok button in the button group.
        uicontrol('Parent',d,'Style','text','HorizontalAlignment','Left',...
            'String','Bandpass filter cut-off length  (approx. size of spot)',...
            'Position',[10 135 170 30]);
%         
        editLBpass = uicontrol('Parent',d,'Style','edit',...
            'Position',[200 135 60 30],...
            'String','3');
        
        uicontrol(bg,'Style',...
            'radiobutton',...
            'String','Signal to noise ratio (SNR)',...
            'Position',[10 10 200 30],...
            'HandleVisibility','off');
        
        uicontrol(bg,'Style','radiobutton',...
            'String','Intensity threshold (InT)',...
            'Position',[10 45 200 30],...
            'HandleVisibility','off');
        
        textBox = uicontrol(bg,'Style','edit',...
            'String','4',...
            'Position',[200 30 60 30],...
            'HandleVisibility','off');
        
        uicontrol('Parent',d,'Position',[20 10 100 30],'String','OK','Callback',@keyPressedCB);
        uicontrol('Parent',d,'Position',[150 10 100 30],'String','Cancel','Callback','return','Callback','delete(gcf)');
        
        % Make the uibuttongroup visible after creating child objects.
        bg.Visible = 'on';
        
        function keyPressedCB(hObject,eventdata)            
            if isa(hObject,'matlab.ui.control.UIControl') && strcmpi(hObject.String,'OK') || strcmpi(eventdata.Key,'return')
                choiseInTSNR = bg.SelectedObject.String;
                InTSNR = str2double(textBox.String);
                lObjectBpass = str2double(editLBpass.String);
                delete(gcf)
            elseif strcmpi(eventdata.Key,'escape')  
                delete(gcf)
            end            
        end
        
        uiwait(d); % Wait for d to close before running to completion
        
        
        if ~exist('choiseInTSNR','var')
            return
        end
        
        %% --------ROIs-----------------------------
        
        ROIs = cell(numberfiles,1);
        ROIlists = cell(numberfiles,1);
        
        for n = 1:numberfiles
            if numberfiles ~= 1
                fname = char(FileName(n)); %Current filename
            else
                fname = char(FileName);
            end
            stack_1 = load_images(fname); %Load current stack
            
            %-----Show Brightfield Image if desired------------
            ROIdrawn = 0;
            while ROIdrawn == 0
                choiceBrightfield = questdlg('Would you like to load a brightfield image?','Load brightfield image?','Yes','No','Cancel batching','Yes');
                
                switch choiceBrightfield
                    case 'Yes'
                        [filename,pathName] = uigetfile('*','Select brightfield image');  
                        
                        if filename == 0
                            continue
                        end                     
                        
                        imagefilename = fullfile(pathName,filename);
                        I = imread(imagefilename);
                        h_im = imshow(I,[]); %Show image                        
                    case 'No'
                        %----------Calculate a projection of the standard deviation for all image slices
                        dummyStack = zeros(size(stack_1{1},1),size(stack_1{1},2),length(stack_1));
                        for m=1:length(stack_1)
                            dummyStack(:,:,m) = stack_1{m};
                        end
                        
                        I = std(dummyStack,0,3);
                        h_im = imshow(I,'DisplayRange',[]); %Show image of projection
                    case 'Cancel batching'
                        return
                end
                
            %---------Create ROI--------------
            myobj = imfreehand(); % draw circle
            
            if isempty(myobj)
                continue
            else
                ROIdrawn = 1;
            end
            
            ROIs{n} = createMask(myobj,h_im); %create binary mask
            ROIlists{n} = getPosition(myobj); %save ROI in List
            ROIlists{n} = cat(1, ROIlists{n}, ROIlists{n}(1,:)); %Close ROI
            
            %----------Plot ROI--------------
            hold on;
            plot(ROIlists{n}(:,1),ROIlists{n}(:,2),'LineWidth',1.1,'Color',[1 1 1]);
            hold off;
            
            end
        end        
       
        %% -------Filter, Find and Fit Spots-----------------
        
        for n = 1:numberfiles
            if numberfiles ~= 1
                fname = char(FileName(n)); %Current filename
            else
                fname = char(FileName);
            end
            
            stack_1 = load_images(fname);
            
%             ------Filter Stack, adjust SNR and InT for finding and fitting spots------
            [denoised,oribgrnd,meQ,sdQ] = filter_stack(stack_1,ROIs{n},lObjectBpass); %Filter stack in ROI

            params = handles.params;
            if strcmp(choiseInTSNR,'Intensity threshold (InT)')
                params.intensityThreshold = InTSNR;
                params.SNR = round((InTSNR - handles.meQ) / handles.sdQ,1);
            else
                params.SNR = InTSNR;
                params.intensityThreshold = round(meQ + InTSNR * sdQ,1); % Threshold estimation
            end
            
%             ----------Find spots-------------------
            tic
            spots   = cellfun(@(image) find_spots_in_ROI(image,params,ROIs{n}), denoised, 'UniformOutput', false);
            
            [nSpots,~] = cellfun(@size, spots, 'UniformOutput', false); %Count spots in each frame
            nSpots = sum(cell2mat(nSpots)); %Count total spot amount
            disp([num2str(nSpots),' Spots found in Stack ', num2str(n), ' of ', num2str(numberfiles)])
            
%             ---------------Fit Spots---------
            % spots = fit_spots2_2(oribgrnd, 'gaussian', params, spots);
            spots = fit_spots_fast(oribgrnd, params.SNR, spots);                             
            toc
            
            [nSpots,~] = cellfun(@size, spots, 'UniformOutput', false); %Count spots in each frame
            nSpots = sum(cell2mat(nSpots)); %Count total spot amount
            disp([num2str(nSpots),' Spots fitted in Stack ', num2str(n), ' of ', num2str(numberfiles)])
            
            ROI = ROIs{n}; %#ok<NASGU> % Get current ROI for saving in .mat file#ok<NASGU>
            ROIlist = ROIlists{n}; %#ok<NASGU> %Get current ROIlist for saving in .mat file
            
            matName  = fname(1:end-4);
            
%             ---Save .mat file--------------------------------
            save([matName,'_GUI'], 'pathName', 'fname', 'matName', 'denoised',...
                'oribgrnd', 'params', 'spots', 'ROI','ROIlist',...
                'meQ','sdQ');
        end
        if exist('finished.jpg','file')
            imshow('finished.jpg');
        end
    end

    function LoadStackCB(~,~)
        handles = guidata(gcf);
        %--------Load image stack and filename-----------
        [handles.fname,handles.pathName] = uigetfile('*.tif','Select .tiff File'); 
        
        if handles.fname == 0
            return
        end
        
        cd(char(handles.pathName));
        
        stack_1 = load_images(handles.fname);        
        handles.matName  = handles.fname(1:end-4); %Filename without .tif extension
        
        %----%Adjust slider settings-------------
        
        numFrames = length(stack_1);
        if handles.uiControls.sliderFrame.Value > numFrames %Take care that current slider value is inside the new boundaries
            handles.uiControls.sliderFrame.Value = numFrames;
        end
        handles.uiControls.sliderFrame.Max = numFrames;
        if numFrames > 1
            handles.uiControls.sliderFrame.SliderStep = [1/(numFrames-1) 2/(numFrames-1)];
        end

        %----Disable substack selection menu
        handles.uiControls.popSubstack.Enable = 'off';
        
        %------%Set mouse wheel handle for scrolling through frames
        set(gcf, 'WindowScrollWheelFcn', {@wheel,handles});
        
        %------Store the image stack in callbacks and update handle structure
        setappdata(hFig,'Stack_1',stack_1);
        setappdata(hFig,'CurrentStack',stack_1);
        guidata(hFig,handles);
        %------Reset all Spots, Tracks etc. and reinitialize GUI
        Reset('LoadStack');        
        
        %-----Load spots if .mat file exists
        handles = guidata(gcf);
        if exist([handles.matName,'_GUI', '.mat'], 'file')
            
            load([handles.matName,'_GUI', '.mat'], 'denoised', 'oribgrnd', 'spots', 'ROI','ROIlist',...
                'meQ','sdQ','params');
            
            handles.params = params;
            handles.ROI = ROI;
            handles.ROIlist = ROIlist;
            handles.spots = spots;
            handles.spotsAll = spots;
            handles.meQ = meQ;
            handles.sdQ = sdQ;
            handles.uiControls.editSNR.String = round((params.intensityThreshold - meQ) / sdQ,1);
            handles.uiControls.editInT.String = params.intensityThreshold;
            setappdata(hFig,'Denoised',denoised);
            setappdata(hFig,'Oribgrnd',oribgrnd);
            cd(char(handles.pathName));
            SetGUIState('FindSpots');
            SetGUIState('FitSpots');
        end
                
        %-----------Display first frame and stack name-----------
        curFrame = round((get(handles.uiControls.sliderFrame,'Value')));
        imshow(stack_1{curFrame},'DisplayRange',[min(min(stack_1{1})) max(max(stack_1{1}))],'Parent',handles.axes1);
        handles.uiControls.textStackName.String = strcat('Stack name:',{' '}, handles.fname);        
        guidata(hFig,handles);
        UpdatePlot('CurrentStack');
    end

    function LoadMatTracksCB(~,~)
        
        handles = guidata(gcf);
        
        %--------Load .mat file-----------
        [FileName,pathName] = uigetfile('*.mat','Select .mat file'); 
        cd(char(pathName));
        load(FileName,'ROIlist','ROElist','ROI','spotsFiltered','spotsAllInROI',...
            'tracksAll','tracksFiltered','stack_1','denoised','oribgrnd',...
            'MaxJump','MinLength','DarkFrames','params')
        
        handles.ROIlist = ROIlist;
        handles.ROElist = ROElist;
        handles.spotsAll = spotsAllInROI;
        handles.spots = spotsFiltered;
        handles.tracksAll = tracksAll;
        handles.tracksFiltered = tracksFiltered;
        handles.ROI = ROI;
        handles.uiControls.editSNR.String = params.SNR;
        handles.uiControls.editInT.String = params.intensityThreshold;
        handles.uiControls.editMaxJump.String = MaxJump;
        handles.uiControls.editMinLength.String = MinLength;
        handles.uiControls.editDarkFrames.String = DarkFrames;
        
        setappdata(hFig,'Stack_1',stack_1);
        setappdata(hFig,'Denoised',denoised);
        setappdata(hFig,'Oribgrnd',oribgrnd);
        setappdata(hFig,'Currentstack',stack_1);
        handles.uiControls.editTrackMax.String = length(stack_1);
        handles.uiControls.editTrackMin.String = MinLength;

        cd(char(handles.pathName));
        SetGUIState('FindTracks')
        guidata(hFig,handles);
        UpdatePlot('CurrentStack');
    end

    function DivideIntoSubstacksCB(~,~)
        Reset('CreateSubstack')
        handles = guidata(gcf);
        
        %% -----Dialog Box: Sequencing numbers and write substacks to TIFF if desired------------
            
        d = dialog('Position',[300 300 270 140],'Name','Select One','CloseRequestFcn',@closereq);
        uicontrol('Parent',d,'Style','text','Position',[10 110 210 20], 'String','Sequencing number of first substack:','HorizontalAlignment','Left');
        editTh1 = uicontrol('Parent',d,'Style','edit','Position',[220 110 30 20], 'String','1','Callback',@userInputCB);

        uicontrol('Parent',d,'Style','text','Position',[10 75 210 20], 'String','Sequencing number of second substack:','HorizontalAlignment','Left');
        editTh2 = uicontrol('Parent',d,'Style','edit','Position',[220 75 30 20], 'String','1','Callback',@userInputCB);
        
        chkbox1 = uicontrol('Parent',d,'Style','checkbox','Position',[10 50 200 20], 'String','Save substacks to .tif files','Callback',@userInputCB);
        
        uicontrol('Parent',d,'Position',[60 15 70 25],'String','OK', 'Callback','delete(gcf)');
        uicontrol('Parent',d,'Position',[140 15 70 25],'String','Cancel', 'Callback',@closereq);

        seq = [1 1]; %Number of frames in each sequence
        saveTif = 0; %Save tif file or not
        returnFlag = 0;
        
        function closereq(~,~)
            returnFlag = 1;
            delete(gcf)
        end

        function userInputCB(~,~)
         seq = [str2double(editTh1.String) str2double(editTh2.String)];
         saveTif = chkbox1.Value;
        end
        
        uiwait(d); % Wait for d to close before running to completion    
        
        if returnFlag %User canceled
            return
        end
               
        %% ---------------------Iterate through frames and create two substacks
        
        stack = getappdata(hFig,'Stack_1'); %Retrieve image stack

        currSeq = 1;
        stackCounter = zeros(1,2);
        stackDummy = seq(1);
        substack = cell(2,round(length(stack)/2));
        
        for i = 1:length(stack)
            stackCounter(currSeq) = stackCounter(currSeq)+1; %Count current frame for each substack
            substack{currSeq,stackCounter(currSeq)} = stack{i}; %Write frame to corresponding substack
            if i == stackDummy && currSeq == 1 %Check if substacks has to change in next frame
                stackDummy = i + seq(2);
                currSeq = 2;
            elseif i == stackDummy && currSeq == 2
                stackDummy = i + seq(1);
                currSeq = 1;
            end
        end
                        
        %% -----Write substacks to TIFF if desired------------
        
        if saveTif
            if ~exist('Substacks', 'dir')    % Folder does not exist so create it.
                mkdir('Substacks')
            end
            
            for i = 1:2 %Iterate through substacks
                I=uint16(substack{i,1}); %Convert into 16-bit Integer
                fName = strcat('Substacks/',handles.matName,'_Substack_',num2str(i),'.tif');
                imwrite(I,fName,'Compression','none','WriteMode','overwrite')
                for j = 2:stackCounter(i) %iterate through frames of substack
                    I=uint16(substack{i,j});
                    imwrite(I,fName,'Compression','none','WriteMode','append')
                end
            end
            disp('Substacks saved');
        else
            disp('Substacks not saved');
        end
        
        handles.seq = seq; %Store sequencing numbers in handles structure
        
        %% ------Store the substsacks in callbacks
        setappdata(hFig,'Stack_1',substack(1,1:stackCounter(1)));
        setappdata(hFig,'Stack_2',substack(2,1:stackCounter(2)));
        
        handles.uiControls.popSubstack.Enable = 'on'; %Enable substack selection menu
        guidata(hFig,handles);
        
        UpdateSettingsCB(handles.uiControls.popSubstack); %Show Substack
    end

    function Reset(src,~)
        %Called by Filter,Reset,LoadStack and CreateSubstack Buttons
        handles = guidata(gcf);
        stack = getappdata(hFig,'CurrentStack');
        handles.uiControls.editEndFrame.String = num2str(length(stack));
        
        %---------Clear list of spots
        numFrames = length(stack);
        handles.spots = cell(1,numFrames);
        handles.spotsAll = cell(1,numFrames);
        handles.spots_2 = cell(1,numFrames);
        handles.spotsAll_2 = cell(1,numFrames);
        handles.params.intensityThreshold = 0;
        handles.params_2.intensityThreshold = 0;
        
        %---------Delete ROI, ROE, tracks and boundaries
        if ~strcmp(src,'Filter')
            handles.ROIlist = [0,0];
            handles.ROElist = {};
            handles.ROI = ones(size(stack{1})); %Initialize ROI to whole image
            handles.tracksAll = {};
            handles.tracksFiltered = {};
            handles.tracksMinLength = {};
            handles.tracksAll_2 = {};
            handles.tracksFiltered_2 = {};
            handles.tracksMinLength_2 = {};
            handles.boundaries1 = cell(1,numFrames);
            handles.boundaries2 = cell(1,numFrames);
            handles.colocalizedTracks = {};
        end
        %--------------------------------------
        SetGUIState('Reset')
        guidata(hFig,handles);
        UpdatePlot('CurrentStack')
    end

    function AddROICB(~,~)
        handles = guidata(gcf);
                
        %-----Show Brightfield Image if desired------------
        choice = questdlg('Would you like to load a brightfield image?','Load brightfield image?','Yes','No','Yes');
        
        switch choice
            case 'Yes'
                [filename,pathName] = uigetfile('*','Select brightfield image');
                imagefilename = fullfile(pathName,filename);
                I = imread(imagefilename);
                imshow(I,[]); %Show image
                
            case 'No'
        end
        
        %---------Create ROI--------------
        myobj = imfreehand(); % draw circle
        handles.ROI = createMask(myobj); %create binary mask
        ROIlist = getPosition(myobj); %save ROI in List
        handles.ROIlist = cat(1, ROIlist, ROIlist(1,:)); %Close ROI and save in handle
        %-----------------------------------
        SetGUIState('Reset')
        guidata(hFig,handles); %return handle
        UpdatePlot('CurrentStack')
    end

    function AddROECB(src,~)
        handles = guidata(gcf);
        src.String = 'Press Esc to finish';
        src.Enable = 'off';
        src.BackgroundColor = 'r'; %Turn button red during computation
                
        set(gcf,'CurrentCharacter', char(1));
        while double(get(gcf,'CurrentCharacter'))~=27 %Drawing possible until ESC is pressed
            
            %---------Create ROE--------------
            myobj = imfreehand(); % draw circle
            if isempty(myobj)
                % User pressed ESC, or something else went wrong
                continue
            end
            ROElistNew = getPosition(myobj); %save ROE in List;
            handles.ROElist{end+1} = ROElistNew;
            
            %--------Clean Spots------------------
            handles.spots   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), handles.spots, 'UniformOutput', false);
            handles.spots_2   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), handles.spots_2, 'UniformOutput', false);
            
            %-------Clean tracks--------
            tracksFiltered   = cellfun(@(tracks) exclude_tracks(handles.ROElist,tracks), handles.tracksFiltered, 'UniformOutput', false);
            tracksFiltered_2   = cellfun(@(tracks) exclude_tracks(handles.ROElist,tracks), handles.tracksFiltered_2, 'UniformOutput', false);
            
            handles.tracksFiltered = tracksFiltered(~cellfun(@isempty,tracksFiltered));
            handles.tracksFiltered_2 = tracksFiltered_2(~cellfun(@isempty,tracksFiltered_2));
            
            UpdatePlot('CurrentStack')
        end
        
        %-----------Update GUI handles
        src.String = 'Add Exclusions';
        src.Enable = 'on';
        src.BackgroundColor = [.94 .94 .94]; %Reset Button color
        SetGUIState('AddROE')
        guidata(hFig,handles); %return handle
    end

    function DelROECB(~,~)
        handles = guidata(gcf);
        
        handles.ROElist = {};
        handles.spots = handles.spotsAll;
        handles.spots_2 = handles.spotsAll_2;
        handles.tracksFiltered = handles.tracksMinLength; 
        handles.tracksFiltered_2 = handles.tracksMinLength_2; 

        SetGUIState('DelROE')
        guidata(hFig,handles); %return handle
        
        UpdatePlot('CurrentStack')
    end

    function FilterCB(src,~)
        Reset('Filter')
        handles = guidata(gcf);
        set(src,'BackgroundColor', 'r','String', 'Busy') %Indicate computation as a red button
        handles.uiControls.btnFitSpots.Enable = 'off';
        drawnow;
        %-------------Filter either stack_1 stack or substacks and store filtered image stacks in callbacks
        stack_1 = getappdata(hFig,'Stack_1');
        [denoised,oribgrnd,handles.meQ,handles.sdQ] = filter_stack(stack_1,handles.ROI,str2double(handles.uiControls.editBpass.String)); %Filter stack in ROI
        
        setappdata(hFig,'Oribgrnd',oribgrnd);
        setappdata(hFig,'Denoised',denoised);
        InT = handles.meQ + str2double(handles.uiControls.editSNR.String) * handles.sdQ; %Threshold estimation
        
        if  strcmp(handles.uiControls.popSubstack.Enable,'on')
            Stack_2 = getappdata(hFig,'Stack_2');
            [Denoised_2,Oribgrnd_2,handles.meQ_2,handles.sdQ_2] = filter_stack(Stack_2,handles.ROI,str2double(handles.uiControls.editBpass.String));
            setappdata(hFig,'Oribgrnd_2',Oribgrnd_2);
            setappdata(hFig,'Denoised_2',Denoised_2);
            if get(handles.uiControls.popSubstack,'Value') == 2
                InT = handles.meQ_2 + str2double(handles.uiControls.editSNR.String) * handles.sdQ_2; % Thershold estimation
            end
        end
        
        %---------------Update GUI handles
        set(handles.uiControls.btnFilter,'String', 'Filter Image','BackgroundColor',[.94 .94 .94]); %Indicate computation finished
        handles.uiControls.editInT.String = round(InT,1);
        
        SetGUIState('Filter')
        guidata(hFig,handles);
        UpdateSettingsCB
        UpdatePlot('CurrentStack')
    end

    %Executed when SNR or InT threshold is changed
    function SNRInTCB(src,~)
        handles = guidata(gcf);
        if strcmp(src.UserData, 'uiControls.editSNR')
            if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %Filter stack_1 stack
                InT = handles.meQ + str2double(src.String) * handles.sdQ; % Threshold estimation Original or Substack1
            else
                InT = handles.meQ_2 + str2double(src.String) * handles.sdQ_2; %Threshold estimation Substack2
            end
            handles.uiControls.editInT.String = round(InT,1);
        elseif strcmp(src.UserData, 'uiControls.editInT')
            if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popOriFil,'Value') == 1 %Original or Substack1
                SNR = round((str2double(src.String) - handles.meQ) / handles.sdQ,1);
            else
                SNR = round((str2double(src.String) - handles.meQ_2) / handles.sdQ_2,1); 
            end
            handles.uiControls.editSNR.String = SNR;
        end
        
        SetGUIState('Filter')
        guidata(hFig,handles); %return handle
    end

    function FindSpotsCB(src,~)
        handles = guidata(gcf);
        
        src.BackgroundColor = 'r'; %Button turns red during computation
        drawnow;
        
        %---------Parameters for finding and fitting spots
        
        params = handles.params;
        params.intensityThreshold = str2double(handles.uiControls.editInT.String);
        params.SNR = str2double(handles.uiControls.editSNR.String);
        
        %----------Find spots either in stack_1 stack or in substack
        if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %One Stack or Substack1
            handles.params = params;
            spotsAll   = cellfun(@(image) find_spots_in_ROI(image,params,handles.ROI), getappdata(hFig,'Denoised'), 'UniformOutput', false); %Find all Spots
            for i=1:length(handles.spotsAll)%Only select spots within desired frame range
                if i <str2double(handles.uiControls.editStartFrame.String) || i > str2double(handles.uiControls.editEndFrame.String)
                    spotsAll{i} = zeros(0,2);
                end
            end
            handles.spots   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), spotsAll, 'UniformOutput', false); %Save only spots which are not in ROE
            handles.spotsAll = spotsAll;
            [nSpots,~] = cellfun(@size, handles.spots, 'UniformOutput', false); %Count No. of Spots
        else %Substack2
            handles.params_2 = params;
            spotsAll_2  = cellfun(@(image) find_spots_in_ROI(image,params,handles.ROI), getappdata(hFig,'Denoised_2'), 'UniformOutput', false); %Find all Spots
            for i=1:length(handles.spotsAll_2)%Only select spots within desired frame range
                if i <str2double(handles.uiControls.editStartFrame.String) || i > str2double(handles.uiControls.editEndFrame.String)
                    spotsAll_2{i} = zeros(0,2);
                end
            end
            handles.spots_2   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), spotsAll_2, 'UniformOutput', false);%Save only spots which are not in ROE
            handles.spotsAll_2 = spotsAll_2;
            [nSpots,~] = cellfun(@size, handles.spots_2, 'UniformOutput', false); %Count No. of Spots
        end
        
        nSpots = sum(cell2mat(nSpots));
        disp(strcat(num2str(nSpots),' Spots found')) %Display number of found spots
        
        
        %-----------Update GUI handles
        src.BackgroundColor = [.94 .94 .94]; %Reset Button
        
        SetGUIState('FindSpots')
        guidata(hFig,handles); %return handle,
        UpdatePlot('CurrentStack');
    end

    function FitSpotsCB(src,~)
        handles = guidata(gcf);
        
        src.BackgroundColor = 'r'; %Button turns red during computation
        drawnow;
        
        %----------Fit spots either in stack_1 stack or in substack------
        %         global catchcount; %Can be used to count errors in fittingprocess -> enable in fit_spots function
        %         catchcount = zeros(1,1);
        tic
        
        if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %One Stack or Substack1
            oribgrnd = getappdata(hFig,'Stack_1');

            params = handles.params;
            spots = handles.spotsAll;            
            
            % FIXME
            %spots = fit_spots2_2(oribgrnd, 'gaussian', params, spots);
            spots = fit_spots_fast(oribgrnd, params.SNR, spots);
            
            handles.spotsAll = spots;
            handles.spots   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), handles.spotsAll, 'UniformOutput', false);%Save spots which are not in ROE in extra Callback
            [nSpots,~] = cellfun(@size, handles.spots, 'UniformOutput', false); %Count Spots
        else %Substack 2
            oribgrnd_2 = getappdata(hFig,'Oribgrnd_2');
            params_2 = handles.params_2;
            spots_2 = handles.spotsAll_2;
            
            % FIXME
            %spots_2 = fit_spots2_2(oribgrnd_2, 'gaussian', params_2, spots_2);
            spots_2 = fit_spots_fast(oribgrnd_2, params_2.SNR, spots_2);
            
            handles.spotsAll_2 = spots_2;
            handles.spots_2   = cellfun(@(spots) exclude_spots(handles.ROElist,spots), handles.spotsAll_2, 'UniformOutput', false);%Save spots which are not in ROE in extra Callback
            [nSpots,~] = cellfun(@size, handles.spots_2, 'UniformOutput', false); %Count Spots
        end
        %----------------------------------------------
        toc
        
        nSpots = sum(cell2mat(nSpots));
        disp(strcat(num2str(nSpots),' Spots fitted')) %Display number of fitted spots
        
        src.BackgroundColor = [.94 .94 .94]; %Reset Button
        
        SetGUIState('FitSpots')
        guidata(hFig,handles); %return handle,
        UpdatePlot('CurrentStack');
    end

    function FindTracksCB(src,~)
        handles = guidata(gcf);
        handles.tracksAll = {};
        handles.tracksFiltered = {};
        handles.tracksMinLength = {};
        handles.tracksAll_2 = {};
        handles.tracksFiltered_2 = {};
        handles.tracksMinLength_2 = {};
        maxdistance = str2double(handles.uiControls.editMaxJump.String);
        pause = str2double(handles.uiControls.editDarkFrames.String);
        minTrackLength = str2double(handles.uiControls.editMinLength.String);        
        
        %----------Find tracks either in stack_1 or in substack

        if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %One Stack or Substack1
                spots = handles.spotsAll;
        else %Substack 2
                spots = handles.spotsAll_2;
        end
                
        if all(cellfun(@isempty,spots)) %Check if spots list is empty
            disp('There are no spots in this stack.')
            return
        end
        
        
        src.BackgroundColor = 'r'; drawnow; %Button turns red during computation
        
        tracksAll  = find_tracks_mod(spots, maxdistance, pause); %Find tracks
        
        %----Filter out tracks < minTrackLength && tracks within ROE
        [nrows,~] = cellfun(@size, tracksAll); %List containing the lengths the tracks        
        tracksMinLength = tracksAll(nrows >= minTrackLength); %Tracks which are longer than the minLength
        tracksFiltered = cellfun(@(tracks) exclude_tracks(handles.ROElist,tracks), tracksMinLength, 'UniformOutput', false); %Tracks longer than MinLength and not inside ROE
        tracksFiltered = tracksFiltered(~cellfun(@isempty,tracksFiltered)); %Throw away empty tracks
        
        %--------- Calculate bound fraction and count tracks---------------
        nSpots = 0;
        for i=1:length(spots)
            nSpots = nSpots + size(spots{i},1);
        end
                
        spotsInTracks = 0;
        for i=1:length(tracksFiltered)
            spotsInTracks = spotsInTracks + size(tracksFiltered{i},1);
        end
                
        boundFraction = spotsInTracks / nSpots;
        nTracks = length(tracksFiltered); %Count tracks    
        
        disp(strcat('Bound fraction: ',num2str(boundFraction))) %Display number of found tracks
        disp(strcat('Tracks found in Stack: ', num2str(nTracks))) %Display number of found tracks
        
        %----Save tracks either for stack_1 or substack
        if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %One Stack or Substack1
            handles.tracksAll = tracksAll; %All Tracks inside ROI
            handles.tracksMinLength = tracksMinLength;%Tracks which are longer than the minLength
            handles.tracksFiltered = tracksFiltered; %Tracks longer than MinLength and not inside ROE
        else %Substack 2
            handles.tracksAll_2 = tracksAll; %All Tracks inside ROI
            handles.tracksMinLength_2 = tracksMinLength;%Tracks which are longer than the minLength
            handles.tracksFiltered_2 = tracksFiltered; %Tracks longer than MinLength and not inside ROE
        end

        %---Set handles and update GUI------------
        SetGUIState('FindTracks')
        handles.uiControls.editTrackMax.String = size(spots,2);
        handles.uiControls.editTrackMin.String = minTrackLength;
        src.BackgroundColor = [.94 .94 .94]; %Button turns red during computation
        guidata(hFig,handles); %return handle,
        UpdatePlot('CurrentStack');
    end

    function DiffusionAnalysisCB(src,~)
        handles = guidata(gcf);
        src.BackgroundColor = 'r'; %Button turns red during computation
        
        maxdistance = str2double(handles.uiControls.editMaxJump.String);
        minTrackLength = str2double(handles.uiControls.editMinLength.String);
        
        %----------Find tracks-------------
        spots = handles.spotsAll;
        
        tracksAll = findDiffusionTracks(spots,maxdistance);        
      
        [nrows,~] = cellfun(@size, tracksAll); %List containing the lengths the tracks
        tracksMinLength = tracksAll(nrows >= minTrackLength); %Tracks which are longer than the minLength
        tracksFiltered = cellfun(@(tracks) exclude_tracks(handles.ROElist,tracks), tracksMinLength, 'UniformOutput', false); %Tracks longer than MinLength and not inside ROE
        tracksFiltered = tracksFiltered(~cellfun(@isempty,tracksFiltered)); %Throw away empty tracks
        nTracks = length(tracksFiltered); %Count tracks
        disp(strcat(num2str(nTracks),' Tracks found')) %Display number of found tracks
        
        handles.tracksAll = tracksAll;
        handles.tracksMinLength = tracksMinLength;
        handles.tracksFiltered = tracksFiltered;        
        %---Set handles and update GUI------------
        SetGUIState('FindTracks')
        handles.uiControls.editTrackMax.String = 2;
        handles.uiControls.editTrackMin.String = 2;
        src.BackgroundColor = [.94 .94 .94]; %Button turns red during computation
        guidata(hFig,handles); %return handle,
        UpdatePlot('CurrentStack');
    end

    function ColocalizeCB(~,~)
        handles = guidata(gcf);
        
        tracks_1 = handles.tracksFiltered;
        tracks_2 = handles.tracksFiltered_2;
        stack_division_1 = handles.seq(1);
        stack_division_2 = handles.seq(2);
        colocDist = str2double(handles.uiControls.editColocalize.String);
        zaehler = 1;
        
         for i=1:length(tracks_1) %Compare all tracks in first stack with every track in second stack
            for j=1:length(tracks_2)  
                anyDuplicates = ~all(diff(sort([tracks_1{i}(:,1);tracks_2{j}(:,1)]))); %Look if two tracks appear in the same frame
                if anyDuplicates
                    framesStack_1 = zeros(size(tracks_1{i},1),1);                 %Used to indicate the colocalized spots in the track by later setting a "1" at the index position
                    framesStack_2 = zeros(size(tracks_2{j},1),1);
                    for k=1:size(tracks_2{j},1)                                 %Iterate through frames of a specific track in stack 2, find corresponding index in second stack and calculate distance
                        assignment = ceil(tracks_2{j}(k,1)/stack_division_2)*stack_division_1;  %Index of stack 1 to which the index of stack 2 has to be compared                        
                        index = find(tracks_1{i}(:,1) == assignment);             %Index in track of first stack which matches to index (k) of track in second stack
                        if index                                                 %If matching index is found, calculate distance between spots
                            xDisp = tracks_2{j}(k,2) - tracks_1{i}(index,2);
                            yDisp = tracks_2{j}(k,3) - tracks_1{i}(index,3);
                            if sqrt(xDisp^2+yDisp^2) < colocDist                 %Check if distance is smaller than user set colocalization distance.
                                framesStack_1(index) = 1;                        %Write a "1" at the colocalized spot position in the track in stack 1
                                framesStack_2(k) = 1;                           %Write a "1" at the colocalized spot position in the track in stack 2
                            end
                        end
                    end
                    if find(framesStack_2) %Save track in variable if a colocalization has been found
                        colocalizedTracks{zaehler,1} = tracks_1{i}(:,1:3);
                        colocalizedTracks{zaehler,2} = tracks_2{j}(:,1:3);
                        colocalizedTracks{zaehler,1}(:,4) = framesStack_1;
                        colocalizedTracks{zaehler,2}(:,4) = framesStack_2;
                        zaehler = zaehler + 1;
                    end
                end
            end
        end

        
        handles.colocalizedTracks = colocalizedTracks;
        
        guidata(hFig,handles); %return handle,
        UpdatePlot('CurrentStack');
    end

    function CreateHistogramCB(~,~)
        if  strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %One Stack or Substack1
            [listTrackLengths,~] = cellfun(@size, handles.tracksFiltered);            
        else
            [listTrackLengths,~] = cellfun(@size, handles.tracksFiltered_2);             
        end
        figure('Name','Track Histogram');
        histogram(listTrackLengths,'BinMethod','Integer')
        xlabel('Binding time [frames]') % x-axis label
        ylabel('Count') % x-axis label
    end

    function SaveTxtAndMatCB(~,~)
        fname = handles.fname;
        pathName = handles.pathName;
        
        %--------make folder and file names----------
        strich = strfind(fname, '_'); %Positions of underlines in filename
        
        name = fname(8:(8+strich(1,2)-strich(1,1)-1)); %Name
        date = fname(3:7); %Date
        expTime = fname(strfind(fname, '_e')+2:strfind(fname, '_e')+4); %Exposure
        timelapse = fname(strfind(fname, '_t')+2:strfind(fname, '_t')+4); %Timelapse condition
        number = fname(strfind(fname, '_n')+2:strfind(fname, '_n')+4); %Video number
        
        newFolderName = strcat(name, date, expTime,timelapse);
        pathName2 = fullfile(pathName, newFolderName);
        
        txtTL = strcat(newFolderName, '_', number, '_tl.txt'); %.txt name for tracklifes
        
        %--.mat Data----------------------
        matName = handles.matName;
        stack_1 = getappdata(hFig,'Stack_1'); %#ok<NASGU>
        denoised = getappdata(hFig,'Denoised');%#ok<NASGU>
        oribgrnd = getappdata(hFig,'Oribgrnd');%#ok<NASGU>
        params = handles.params;%#ok<NASGU>
        spotsFiltered = handles.spots;%#ok<NASGU>
        spotsAllInROI = handles.spotsAll;%#ok<NASGU>
        tracksAll = handles.tracksAll;%#ok<NASGU>
        tracksFiltered = handles.tracksFiltered;
        ROI = handles.ROI;%#ok<NASGU>
        ROIlist = handles.ROIlist;%#ok<NASGU>
        ROElist = handles.ROElist;%#ok<NASGU>
        MaxJump = handles.uiControls.editMaxJump.String;%#ok<NASGU>
        MinLength = handles.uiControls.editMinLength.String;%#ok<NASGU>
        DarkFrames = handles.uiControls.editDarkFrames.String;%#ok<NASGU>
        
        %--------save files-------------
        
        if ~exist(pathName2, 'dir')    % Folder does not exist so create it.
            mkdir(pathName2)
        end
        
        cd(char(pathName2));
                
        if strcmp(handles.menuTrackLifes.Checked,'on') 
            %% Tracklifes analysis mode
            tracklifes = zeros(1,1);
            for i=1:length(tracksFiltered)
                tracklifes(i,1) = tracksFiltered{i}(end,1)-tracksFiltered{i}(1,1);
            end
            
            save(txtTL, 'tracklifes', '-ascii', '-tabs');
            
            %% Save track evaluation (frame, intensity, jump distance, velocity)
            txtAndy = strcat(newFolderName, '_', number, '_myoEval.csv'); %.txt name for Spots Intensities
            tracksFiltered = handles.tracksFiltered;
            frameTime = str2double(handles.uiControls.editFrametime.String)*1e-3;
            pixelSize = str2double(handles.uiControls.editPixelsize.String)*1e-6;
            
            frame = cell(length(tracksFiltered),1);
            intensity = cell(length(tracksFiltered),1);
            disp = cell(length(tracksFiltered),1);
            totDist = cell(length(tracksFiltered),1);
            velocity = cell(length(tracksFiltered),1);
            
            for i=1:length(tracksFiltered)
                frame{i} = tracksFiltered{i}(:,1);
                intensity{i} = tracksFiltered{i}(:,8);
                
                xDisp = abs(tracksFiltered{i}(1:end-1,2) - tracksFiltered{i}(2:end,2));
                yDisp = abs(tracksFiltered{i}(1:end-1,3) - tracksFiltered{i}(2:end,3));
                disp{i} = sqrt(xDisp.^2+yDisp.^2)*pixelSize;
                totDist{i} = cumsum(disp{i});
                velocity{i} = disp{i}/frameTime;
            end
            
            fid = fopen(txtAndy,'wt');
            
            for i=1:length(tracksFiltered)
                fprintf(fid, 'Track;%d\n',i);
                fprintf(fid, 'Frame;');
                fprintf(fid, '%d;', frame{i});
                fprintf(fid, ' \n');
                fprintf(fid, 'Intensity;');
                fprintf(fid, '%d;', intensity{i});
                fprintf(fid, ' \n');
                fprintf(fid, 'Displacement;0;');
                fprintf(fid, '%d;', disp{i});
                fprintf(fid, ' \n');
                fprintf(fid, 'Total Distance;0;');
                fprintf(fid, '%d;', totDist{i});
                fprintf(fid, ' \n');
                fprintf(fid, 'Velocity;0;');
                fprintf(fid, '%d;', velocity{i});
                fprintf(fid, ' \n\n');
            end
            fclose(fid);
            
            save(matName, 'pathName', 'fname', 'stack_1', 'matName', 'denoised',...
                'oribgrnd', 'params', 'spotsAllInROI', 'spotsFiltered', 'tracksAll',...
                'tracksFiltered','ROI','ROIlist','ROElist',...
                'MaxJump','MinLength','DarkFrames')
            
        elseif strcmp(handles.menuDiffusion.Checked,'on') 
            %% Diffusion analysis mode
            pixelsize = str2double(handles.uiControls.editPixelsize.String);
            frametime = str2double(handles.uiControls.editFrametime.String);
            xDisplacements = zeros(size(tracksFiltered,2),1);
            yDisplacements = zeros(size(tracksFiltered,2),1);
            
            diffCoeff = zeros(1,1);
            
            %Calculate x -and y displacements and diffusion constants
            for i=1:length(tracksFiltered)
                xDisplacements(i) = abs(tracksFiltered{i}(1,2)- tracksFiltered{i}(2,2)) * pixelsize;
                yDisplacements(i) = abs(tracksFiltered{i}(1,3)-tracksFiltered{i}(2,3)) * pixelsize;
                diffCoeff(i,1) = (xDisplacements(i)^2 + yDisplacements(i)^2)/4/frametime;
            end
            
            txtTL = strcat(newFolderName, '_', number, '_diff.txt');
            save(txtTL, 'diffCoeff', '-ascii', '-tabs');
            save(matName, 'pathName', 'fname', 'stack_1', 'matName', 'denoised',...
                'oribgrnd', 'params', 'spotsAllInROI', 'spotsFiltered', 'tracksAll',...
                'tracksFiltered','ROI','ROIlist','ROElist',...
                'MaxJump','MinLength','DarkFrames','pixelsize','frametime');
            
        elseif strcmp(handles.menuHoechst.Checked,'on')
            %% Hoechst analysis mode
            stack_2 = getappdata(hFig,'Stack_2'); %#ok<NASGU>
            denoised_2 = getappdata(hFig,'Denoised_2');%#ok<NASGU>
            oribgrnd_2 = getappdata(hFig,'Oribgrnd_2');%#ok<NASGU>
            params_2 = handles.params_2;%#ok<NASGU>
            spotsFiltered_2 = handles.spots_2;%#ok<NASGU>
            spotsAllInROI_2 = handles.spotsAll_2;%#ok<NASGU>
            tracksAll_2 = handles.tracksAll_2;%#ok<NASGU>
            tracksFiltered_2 = handles.tracksFiltered_2;
            areas = handles.areas;
            boundaries1 = handles.boundaries1;%#ok<NASGU>
            boundaries2 = handles.boundaries2;%#ok<NASGU>
            seq = handles.seq;%#ok<NASGU>
            tracksInArea1 = handles.tracksInArea1;
            tracksInArea2 = handles.tracksInArea2;
            tracksInArea3 = handles.tracksInArea3;
            nTracks1 = length(tracksInArea1);%#ok<NASGU> %Count tracks
            nTracks2 = length(tracksInArea2);%#ok<NASGU> %Count tracks
            nTracks3 = length(tracksInArea3);%#ok<NASGU> %Count tracks
            tracklifesAll = zeros(1,1);
            tracklifesArea1 = zeros(1,1);
            tracklifesArea2 = zeros(1,1);
            tracklifesArea3 = zeros(1,1);
            
            for i = 1:length(tracksFiltered_2)
                tracklifesAll(i,1) = tracksFiltered_2{i}(end,1)-tracksFiltered_2{i}(1,1);
            end
            for i = 1:length(tracksInArea1)
                tracklifesArea1(i,1) = tracksInArea1{i}(end,1)-tracksInArea1{i}(1,1);
            end
            for i = 1:length(tracksInArea2)
                tracklifesArea2(i,1) = tracksInArea2{i}(end,1)-tracksInArea2{i}(1,1);
            end
            for i = 1:length(tracksInArea3)
                tracklifesArea3(i,1) = tracksInArea3{i}(end,1)-tracksInArea3{i}(1,1);
            end
            
            txtTlArea1 = strcat(newFolderName, '_', number, '_tl_areaGreen.txt');
            txtTlArea2 = strcat(newFolderName, '_', number, '_tl_areaBlue.txt');
            txtTlArea3 = strcat(newFolderName, '_', number, '_tl_areaWhite.txt');
            save(txtTlArea1, 'tracklifesArea1', '-ascii', '-tabs');
            save(txtTlArea2, 'tracklifesArea2', '-ascii', '-tabs');
            save(txtTlArea3, 'tracklifesArea3', '-ascii', '-tabs');
            save(txtTL, 'tracklifesAll', '-ascii', '-tabs');
            resultsName = strcat(matName, '_spacially_resolved_analysis.txt');
            fid = fopen(resultsName,'wt');
            
            for i=1:length(areas)
                fprintf(fid, '%s\n', areas{i});
            end
            
            fclose(fid);
            save(matName, 'pathName', 'fname', 'matName', 'stack_1', 'denoised',...
                'oribgrnd', 'stack_2', 'denoised_2', 'oribgrnd_2', 'params_2', ...
                'spotsAllInROI_2', 'spotsFiltered_2', 'tracksAll_2',...
                'tracksFiltered_2', 'ROI','ROIlist','ROElist',...
                'MaxJump','MinLength','DarkFrames', 'boundaries1', 'boundaries2',...
                'tracksInArea1', 'tracksInArea2', 'tracksInArea3', 'areas','seq');
            
        elseif strcmp(handles.menuITM.Checked,'on')
            %% ITM analysis mode
            tracksAllFiltered   = cellfun(@(tracks) exclude_tracks(handles.ROElist,tracks), handles.tracksAll, 'UniformOutput', false);            
            handles.tracksAllFiltered = tracksAllFiltered(~cellfun(@isempty,tracksAllFiltered));
           
            tracklifes = zeros(1,1);
            for i=1:length(tracksAllFiltered) %Iterate through all Tracks, including Spots not assigned to a track
                if size(tracksAllFiltered{i},1) == 1 %Spot
                    tracklifes(i,1) = 0.5;
                elseif mod(tracksAllFiltered{i}(1,1),2) == 0 %Track which starts in an even frame -> long bound
                    tracklifes(i,1) = 123;
                else
                    tracklifes(i,1) = tracksAllFiltered{i}(end,1)-tracksAllFiltered{i}(1,1); %Track lengths
                end
            end
            txtITM = strcat(newFolderName, '_', number, '_itm_tl.txt'); %.txt name for tracklifes
            
            save(txtITM, 'tracklifes', '-ascii', '-tabs');
        end
        cd(char(pathName));
    end

    function MakeVideoCB(~,~)
        stack = getappdata(hFig,'CurrentStack');
        [filename, pathName] = uiputfile({'*.avi'},'Save Video',handles.matName);
        cd(char(pathName));

        if ~isequal(filename,0)
            writerObj = VideoWriter(filename);
            writerObj.FrameRate = 20;
            open(writerObj)
            
            fid = figure('Position',[10 10 800 800]);
            axes('Position',[0 0 1 1]);
            
            for curFrame = 1:length(stack)
                figure(fid);
                I = stack{curFrame};

                %% ----------Show Image----------
                xlim = get(handles.axes1, 'XLim'); %Get zoom factor
                ylim = get(handles.axes1, 'YLim');
                
                I = uint16(I);
                I = imadjust(I,stretchlim(uint16(stack{1}),0));
                if handles.uiControls.ckboxBrightness.Value
                    I = imadjust(I);
                end
                if handles.uiControls.ckboxContrast.Value
                    I = histeq(I);
                end
                if handles.uiControls.ckboxAdaptive.Value
                    I = adapthisteq(I);
                end
                if  handles.uiControls.ckboxStd.Value
                    dummyStack = zeros(size(stack{1},1),size(stack{1},2),length(stack));
                    for m=1:length(stack)
                        dummyStack(:,:,m) = stack{m};
                    end
                    I = std(dummyStack,0,3);
                    I = uint16(I);
                    I = imadjust(I,stretchlim(uint16(I),0));
                end
                
                imshow(I,'DisplayRange',[handles.uiControls.sliderBlack.Value handles.uiControls.sliderWhite.Value]);
                
                
                zoom reset;
                handles.axes1.XLim = xlim; %Set Zoom
                handles.axes1.YLim = ylim;
                                
                hold on;
                
                %% ----------Plot Tracks--------------
                tracks = {handles.tracksFiltered,handles.tracksFiltered_2};
                ColOrd = get(gca,'ColorOrder'); %Get color order to make sure Tracks always get the same color
                
                if  strcmp(handles.uiControls.popTracks.Enable,'on')
                    for j = 1:2 %Substack 1&2
                        for i = 1:length(tracks{:,j}) %Iterate through tracks
                            if handles.uiControls.ckboxUniformTrackColor.Value == 0
                                ColRow = rem(i,7); %Determine which color to use (7 colors in total)
                                if ColRow == 0
                                    ColRow = 7;
                                end
                                Col = ColOrd(ColRow,:); %Get plotting color
                            else
                                Col = ColOrd(j,:);
                            end
                            
                            plotInputArgs = {'LineStyle','-','LineWidth', 2,'Color', Col};
                            switch get(handles.uiControls.popTracks,'Value')
                                case 1 %Plot all Tracks
                                    if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String) %Plot only Tracks wihtin desired Tracklength range
                                        index = size(tracks{j}{i},1);
                                    end
                                case 2 %Continuouly plot tracks in current frame
                                    if find(curFrame <= max(tracks{j}{i}(:,1)) && curFrame >= min(tracks{j}{i}(:,1)))
                                        if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String) %Plot only Tracks wihtin desired Tracklength range
                                            index = find(tracks{j}{i}(:,1) <= curFrame, 1, 'last');
                                        end
                                    else
                                        continue
                                    end
                                case 3 %Continuously plot all tracks until current frame
                                    if find(curFrame >= min(tracks{j}{i}(:,1)))
                                        if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String)
                                            index = find(tracks{j}{i}(:,1) <= curFrame, 1, 'last');
                                        end
                                    else
                                        continue
                                    end
                                case 4 %Hide Tracks
                                    index = 0;
                            end
                            plot(tracks{j}{i}(1:index, 2), tracks{j}{i}(1:index, 3), plotInputArgs{:});
                        end
                    end
                end
                
                %% ----------Plot Spots--------------
                
                if handles.uiControls.ckboxSpots.Value
                    plotInputArgs = {'LineStyle','none','Marker','o', 'MarkerSize', 10','LineWidth', 1};
                    if curFrame <= length(handles.spots) && size(handles.spots{curFrame},1) ~=0  %Check if spots exits in current frame of current stack
                        plot (handles.spots{curFrame}(:,1),handles.spots{curFrame}(:,2),'MarkerEdgeColor', ColOrd(6,:),plotInputArgs{:});
                    end
                    if  curFrame <= length(handles.spots_2) && size(handles.spots_2{curFrame},1) ~=0 %Check if spots exits in current frame of current stack
                        plot (handles.spots_2{curFrame}(:,1),handles.spots_2{curFrame}(:,2),'MarkerEdgeColor',ColOrd(3,:),plotInputArgs{:});
                    end
                end
                
                %% ----------Plot ROI and ROE--------------
                plot(handles.ROIlist(:,1),handles.ROIlist(:,2),'LineWidth',1.1,'Color',[1 1 1]);
                %         visboundaries(handles.ROI,'Color','w','EnhanceVisibility', false);
                
                for i = 1:length(handles.ROElist)
                    x = cat(1,handles.ROElist{i}(:,1), handles.ROElist{i}(1,1)); %Close ROEs
                    y = cat(1,handles.ROElist{i}(:,2), handles.ROElist{i}(1,2)); %Close ROEs
                    plot(x,y,'LineWidth',1.1,'Color','g');
                end
                
                hold off;                
                
                %% ----------Plot Boundaries for Hoechst Analysis-----
                if strcmp(handles.uiControls.btnHoechstTrackAssign.Enable,'on')
            
            divisor = ceil(curFrame/handles.seq(2));
            
            stack_1 = getappdata(hFig,'Stack_1');
            
            avgNum = str2double(handles.uiControls.editAverage.String);
            curAvgNum = avgNum;
            divisor_1 = floor(length(stack_1)/curAvgNum);
            remainder = mod(length(stack_1),curAvgNum);
            
            for i=0:divisor_1
                if i == divisor_1 %Last sequence might have less frames
                    curAvgNum = remainder;
                end
                dummyFrame = zeros(size(stack_1{1},1),size(stack_1{1},2));
                for m=1:curAvgNum
                    dummyFrame = dummyFrame + stack_1{i*curAvgNum+m};
                end
                dummyFrame = dummyFrame / curAvgNum; 
                for m=1:curAvgNum
                    stack_1{i*avgNum+m} = dummyFrame;
                end
            end
            
            hold on;
            
            if handles.uiControls.ckboxPlotPixels.Value == 1
                plot_binary_pixel_boundaries(stack_1{divisor}, handles.Th1, 'g')
                plot_binary_pixel_boundaries(stack_1{divisor}, handles.Th2, 'b')
            else
                curFrameBoundary1 = handles.boundaries1{divisor};
                curFrameBoundary2 = handles.boundaries2{divisor};
                visboundaries(curFrameBoundary1,'Color','g','EnhanceVisibility', false);
                visboundaries(curFrameBoundary2,'Color','b','EnhanceVisibility', false);
            end
            hold off;
                end
                
                %% ----------Plot Colocalized Spots--------------
                
                colocalizedTracks = handles.colocalizedTracks;
                
                if ~isempty(colocalizedTracks)
                    for i = 1:size(colocalizedTracks,1)
                        colocalizedSpots_1{i} = colocalizedTracks{i,1}(find(colocalizedTracks{i,1}(:,4)),1:3); %Search for the "1"s in colocalized tracks -> colocalized spots
                        colocalizedSpots_2{i} = colocalizedTracks{i,2}(find(colocalizedTracks{i,2}(:,4)),1:3);
                    end
                    
                    hold on;
                    for i = 1:length(colocalizedSpots_2)
                        switch get(handles.uiControls.popTracks,'Value')
                            case 1 %Plot all Tracks together with all colocalized spots
                                plot(colocalizedSpots_1{i}(:, 2), colocalizedSpots_1{i}(:, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                                plot(colocalizedSpots_2{i}(:, 2), colocalizedSpots_2{i}(:, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                            case 2 %Continuouly plot tracks together with colocalized spots in current frame
                                index_1 = find(curFrame == colocalizedSpots_1{i}(:,1));
                                index_2 = find(curFrame == colocalizedSpots_2{i}(:,1));
                                plot(colocalizedSpots_1{i}(index_1, 2), colocalizedSpots_1{i}(index_1, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                                plot(colocalizedSpots_2{i}(index_2, 2), colocalizedSpots_2{i}(index_2, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                            case 3 %Continuously plot all tracks until current frame
                                index_1 = find(curFrame >= colocalizedSpots_1{i}(:,1));
                                index_2 = find(curFrame >= colocalizedSpots_2{i}(:,1));
                                plot(colocalizedSpots_1{i}(index_1, 2), colocalizedSpots_1{i}(index_1, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                                plot(colocalizedSpots_2{i}(index_2, 2), colocalizedSpots_2{i}(index_2, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                        end
                        
                    end
                    hold off;
                end
                frame = getframe(gcf);
                writeVideo(writerObj,frame);
            end
            close(writerObj);
            close(gcf);
            cd(char(handles.pathName));
        end
    end

    function HoechstRegionsCB(~,~)
        
        handles = guidata(gcf);
        
        a = 1;
        stack = getappdata(hFig,'CurrentStack');
        Q = stack{1}(logical(handles.ROI)); %Get ROI
                        
        for i=1:length(stack)
            stack{i} = stack{i}.*handles.ROI; %Get image of ROI
        end
        
        %-----------Create interface where user can drag two sliders for adjusting the intensity threshold
        d = dialog('Position',[300 300 500 150],'Name','Select One');
        TextTh1 = uicontrol('Parent',d,'Style','text','Position',[20 100 200 40], 'String','Threshold 1 (high)','HorizontalAlignment','Left');
        TextTh2 = uicontrol('Parent',d,'Style','text','Position',[20 55 200 40], 'String','Threshold 2 (low)','HorizontalAlignment','Left');
        uiControls.sliderFrameTh1 = uicontrol('Units','normalized','Enable','on','Style','slider','Position',[.05 .7 .9 .1],'Min',min(Q),'Max',max(Q),'Value',min(Q),'SliderStep',[1/20 1/10]);
        uiControls.sliderFrameTh2 = uicontrol('Units','normalized','Enable','on','Style','slider','Position',[.05 .4 .9 .1],'Min',min(Q),'Max',max(Q),'Value',min(Q),'SliderStep',[1/20 1/10]);
        handles.SliderTh1Listener = addlistener(uiControls.sliderFrameTh1,'Value','PostSet',@(~,~) SliderThListenerCB);
        handles.SliderTh2Listener = addlistener(uiControls.sliderFrameTh2,'Value','PostSet',@(~,~) SliderThListenerCB);
        uicontrol('Parent',d,'Position',[89 20 70 25],'String','OK', 'Callback','delete(gcf)');

        %------------Interactive interface to choose the boundary. Is executed until user presses "OK" button.
        function SliderThListenerCB
            imshow(stack{a},'DisplayRange',[min(Q) max(Q)],'Parent',handles.axes1); %Show first frame of stack
            Th1 = uiControls.sliderFrameTh1.Value; %Get threshold values from sliders
            Th2 = uiControls.sliderFrameTh2.Value;
            TextTh1.String = strcat('Threshold 1 (high):', num2str(round(Th1))); %Display threshold value in interface
            TextTh2.String= strcat('Threshold 2 (low):', num2str(round(Th2)));
            binary1 = stack{a} >= Th1; %Calculate bindary image according to the intensity threshold
            binary2 = stack{a} >= Th2;
            boundaries1 = bwboundaries(binary1); %Create boundary with respect to the binary image
            boundaries2 = bwboundaries(binary2);
            hold (handles.axes1, 'on');
            for f=1:length(boundaries1)
                b1 = boundaries1{f};
                plot(b1(:,2),b1(:,1),'g','LineWidth',2,'Parent',handles.axes1);
            end %Plot boundaries into the image
            for f=1:length(boundaries2)
                b2 = boundaries2{f};
                plot(b2(:,2),b2(:,1),'b','LineWidth',2,'Parent',handles.axes1);
            end
            hold (handles.axes1, 'off');
        end
        
        uiwait(d); % Wait for d to close before running to completion
        
        %---------------Create boundaries for each frame taking into account the user defined thresholds
        boundaries1 = cell(length(stack),0); %Initialise variables for boundaries and areas
        boundaries2 = cell(length(stack),0);
        area1 = zeros(0, length(stack));
        area2 = area1;
        
        for i=1:length(stack) %Iterate through frames and create boundaries for each frame
            binary1 = stack{i} >= Th1;
            binary2 = stack{i} >= Th2;
            area1(i) = sum(binary1(:) == 1);
            area2(i) = sum(binary2(:) == 1);
            boundaries1{i,1} = bwboundaries(binary1);
            boundaries2{i,1} = bwboundaries(binary2);            
        end
        
        area = 0;
        for i=1:length(boundaries1{1})
            area = area + polyarea(boundaries1{1}{i}(:,1),boundaries1{1}{i}(:,2));
        end
                
        area
        area1(1)
        
        %--------Save all values in handles.
        handles.area1 = area1;
        handles.area2 = area2;
        handles.Th1 = Th1;
        handles.Th2 = Th2;
        handles.boundaries1 = boundaries1;
        handles.boundaries2 = boundaries2;        

        SetGUIState('DefineRegions')
        guidata(hFig,handles);
        UpdatePlot('CurrentStack')
    end

    function HoechstTracksCB(~,~) 
        handles = guidata(gcf);
        
        %-----------Assign tracks to regions-------------
        spots_2 = handles.spots_2;
        tracksFiltered_2 = handles.tracksFiltered_2;
        area1 = handles.area1;
        area2 = handles.area2;
        
        [handles.tracksInArea1, remaining] = find_tracks_in_area(handles.boundaries1, tracksFiltered_2, handles.seq);
        [handles.tracksInArea2, handles.tracksInArea3] = find_tracks_in_area(handles.boundaries2, remaining, handles.seq);
        
        sizeArea1 = round(mean(area1),1);
        sizeArea2 = round(mean(area2),1)-sizeArea1;
        sizeArea3 = sum(handles.ROI(:) == 1)-sizeArea1-sizeArea2;
        
        tracksPerPx1 = round(length(handles.tracksInArea1)/sizeArea1,5);
        tracksPerPx2 = round(length(handles.tracksInArea2)/sizeArea2,5);
        tracksPerPx3 = round(length(handles.tracksInArea3)/sizeArea3,5);
        
        %-----Calculate the average fraction of bound molecules/all molecules
        frameTrackSpotMatrix = zeros(length(spots_2),length(tracksFiltered_2));
        for i=1:length(tracksFiltered_2)
            for j=1:size(tracksFiltered_2{i},1)
                frameTrackSpotMatrix(tracksFiltered_2{i}(j,1),i) = 1; %Creates a Matrix: rows=#frames, col=#tracks. Ones mark the positions of spots in corresponding track and frame.
            end
        end
        
        frameFrac = zeros(length(spots_2),1);
        allSpotsInStack = 0;
        boundSpotsInStack = 0;
        for i=1:length(spots_2)
            allSpotsInFrame = size(spots_2{i},1);
            boundSpotsInFrame = sum(frameTrackSpotMatrix(i,:));
            allSpotsInStack = allSpotsInStack + allSpotsInFrame;
            boundSpotsInStack = boundSpotsInStack + boundSpotsInFrame;
            if boundSpotsInFrame
                frameFrac(i) = boundSpotsInFrame/allSpotsInFrame;
            end
        end
        
        stackBoundFrac = round(boundSpotsInStack/allSpotsInStack,3);
        frameBoundFrac = round(mean(frameFrac(frameFrac ~= 0)),3);
        
        normalizedTracksPerPx1 = (tracksPerPx1/allSpotsInStack);
        normalizedTracksPerPx2 = (tracksPerPx2/allSpotsInStack);
        normalizedTracksPerPx3 = (tracksPerPx3/allSpotsInStack);
        
        totalTracks = length(tracksFiltered_2);        
        
        handles.areas = {strcat('Mean size of green area:', num2str(sizeArea1), ' pixels'),...
            strcat('Mean size of blue area: ', num2str(sizeArea2), ' pixels'),...
            strcat('White Area (ROI): ', num2str(sizeArea3), ' pixels'),...
            strcat('Standard deviation green area: ', num2str(round(std(area1),1)), ' pixels'),...
            strcat('Standard deviation blue area: ', num2str(round(std(area2),1)), ' pixels'),...
            strcat('Tracks in green area:', num2str(length(handles.tracksInArea1))),...
            strcat('Tracks in blue area:', num2str(length(handles.tracksInArea2))),...
            strcat('Tracks in white area:', num2str(length(handles.tracksInArea3))),...
            strcat('Tracks per pixel in green area:', num2str(tracksPerPx1)),...
            strcat('Tracks per pixel in blue area:', num2str(tracksPerPx2)),...
            strcat('Tracks per pixel in white area:', num2str(tracksPerPx3)),...
            strcat('Normalized tracks per pixel in green area:', num2str(normalizedTracksPerPx1)),...
            strcat('Normalized tracks per pixel in blue area:', num2str(normalizedTracksPerPx2)),...
            strcat('Normalized tracks per pixel in white area:', num2str(normalizedTracksPerPx3)),...
            strcat('Average bound fraction:', num2str(frameBoundFrac)),...
            strcat('Total bound fraction:', num2str(stackBoundFrac)),...
            strcat('Total tracks:', num2str(totalTracks)),...
            strcat('Total spots:', num2str(allSpotsInStack)),...
            strcat('Total bound spots:', num2str(boundSpotsInStack))};
        
        for i=1:length(handles.areas) %Display area sizes and number of tracks in each area
            disp(handles.areas{i})
        end
                              
        UpdatePlot('CurrentStack')
        SetGUIState('AssignTracks')
        guidata(hFig,handles);
    end

    function AnalysisModeCB(src,~)
        handles = guidata(gcf);
        handlesArray = [handles.menuTrackLifes,handles.menuHoechst,...
            handles.menuColocalization, handles.menuDiffusion, handles.menuITM];
        set(handlesArray, 'Checked', 'off');
        src.Checked = 'on';
        
        handlesArray = [handles.uiControls.btnHoechstRegions, handles.uiControls.btnHoechstTrackAssign, handles.uiControls.btnCreateHistogram,...
            handles.uiControls.btnSave, handles.uiControls.btnFindTracks, handles.uiControls.btnDiffusionAna,...
            handles.uiControls.ckboxPlotPixels, handles.uiControls.btnColocalize,...
            handles.uiControls.editColocalize,handles.uiControls.textColocalize, handles.uiControls.btnDiffusionAna];
        set(handlesArray, 'Visible', 'off');
        
        switch src.Label
            case 'Track lifes'
            handlesArray = [handles.uiControls.btnCreateHistogram,...
                handles.uiControls.btnSave, handles.uiControls.btnFindTracks,...
                handles.uiControls.editDarkFrames,handles.uiControls.textDarkFrames];            
            case 'Hoechst regions'
            handlesArray = [handles.uiControls.btnHoechstRegions, handles.uiControls.btnHoechstTrackAssign, handles.uiControls.btnCreateHistogram,...
                handles.uiControls.btnSave, handles.uiControls.btnFindTracks, handles.uiControls.ckboxPlotPixels];            
            case 'Colocalization'
            handlesArray = [handles.uiControls.btnCreateHistogram,handles.uiControls.btnFindTracks,...
                handles.uiControls.btnColocalize,handles.uiControls.editColocalize,...
                handles.uiControls.textColocalize];
            case 'Diffusion'
            handlesArray = [handles.uiControls.btnSave, handles.uiControls.btnDiffusionAna];
            case 'ITM'
            handlesArray = [handles.uiControls.btnSave, handles.uiControls.btnFindTracks];
        end
        
        set(handlesArray, 'Visible', 'on');
        guidata(hFig,handles);
        
    end

    function MenuSettingsCB(src,~)
        handles = guidata(gcf);
        
%         switch src.Label
%             case 'Filter Preference'
%          d = dialog('Position',[300 300 500 150],'Name','Select One');
%         
%         textLNoise = uicontrol('Parent',d,'Style','text','Position',[20 100 200 40], 'String','Characteristic size of noise (px)','HorizontalAlignment','Left');
%         textLObject = uicontrol('Parent',d,'Style','text','Position',[20 55 200 40], 'String','','HorizontalAlignment','Left');
%         
%         uicontrol('Parent',d,'Position',[89 20 70 25],'String','OK', 'Callback','delete(gcf)');
%                 
%         uiwait(d); % Wait for d to close before running to completion
%             case 'Acquisition Parameters'
                
%             case 'Fitting Parameters'
                
%             case 'Tracking Preferences'
%                 
%         end
        
        guidata(hFig,handles);
        
    end

    %Executed when user changes settings in the lower part of the GUI (Original/Filtered/Substack/Slider/Average)
    function UpdateSettingsCB(~,~)
        handles = guidata(gcf);
        
        %-----Select which stack to show: Stack_1/Stack_2 and Filtered/Original
        
        if strcmp(handles.uiControls.popSubstack.Enable,'off') && strcmp(handles.uiControls.popOriFil.Enable,'off')
            stack = getappdata(hFig,'Stack_1'); %Original Stack 1
        elseif strcmp(handles.uiControls.popSubstack.Enable,'off') || get(handles.uiControls.popSubstack,'Value') == 1 %Stack 1
            if get(handles.uiControls.popOriFil,'Value') == 1 || strcmp(handles.uiControls.popOriFil.Enable,'off') == 1 %Original or not yet filtered
                stack = getappdata(hFig,'Stack_1');%Original Stack 1
            else
                stack = getappdata(hFig,'Denoised'); %Filtered Stack 1
            end
            
            if  strcmp(handles.uiControls.btnFindSpots.Enable,'on') %Update SNR/Threshold for Substack
                handles.uiControls.editInT.String = round(handles.meQ + str2double(handles.uiControls.editSNR.String) * handles.sdQ,1);
            end
        else %Stack 2
            if get(handles.uiControls.popOriFil,'Value') == 1 || strcmp(handles.uiControls.popOriFil.Enable,'off') == 1 %Original or not yet filtered
                stack = getappdata(hFig,'Stack_2'); %Original Stack 2
            else
                stack = getappdata(hFig,'Denoised_2'); %Filtered Stack 2
            end
            
            if  strcmp(handles.uiControls.btnFindSpots.Enable,'on') == 1 %Update SNR/Threshold for Substack
                handles.uiControls.editInT.String = round(handles.meQ_2 + str2double(handles.uiControls.editSNR.String) * handles.sdQ_2,1);
            end
        end
        
        %-------Adjust slider settings in case of divided stacks
        if strcmp(handles.uiControls.popSubstack.Enable,'on')
            numFrames = length(stack);
            if handles.uiControls.sliderFrame.Value > numFrames
                handles.uiControls.sliderFrame.Value = numFrames;
            end
            handles.uiControls.sliderFrame.Max = numFrames;
            handles.uiControls.sliderFrame.SliderStep = [1/(numFrames-1) 2/(numFrames-1)];
            handles.uiControls.editEndFrame.String = numFrames;
        end
                
        %-------------Average Stacks if pressed----------
        
        if handles.uiControls.ckboxAverage.Value == 1
            averaged = stack;
            avgNum = str2double(handles.uiControls.editAverage.String);
            curAvgNum = avgNum;
            divisor = floor(length(stack)/curAvgNum);
            remainder = mod(length(stack),curAvgNum);
            
            for i=0:divisor
                if i == divisor %Last sequence might have less frames
                    curAvgNum = remainder;
                end
                dummyFrame = zeros(size(stack{1},1),size(stack{1},2));
                for m=1:curAvgNum
                    dummyFrame = dummyFrame + stack{i*curAvgNum+m};
                end
                dummyFrame = dummyFrame / curAvgNum; 
                for m=1:curAvgNum
                    averaged{i*avgNum+m} = dummyFrame;
                end
            end
            
            setappdata(hFig,'CurrentStack',averaged);
        else
            setappdata(hFig,'CurrentStack',stack);
        end
        UpdatePlot('CurrentStack')
        guidata(hFig,handles);
        
    end

    function UpdatePlot(stackName)
        stack = getappdata(hFig,stackName);
        curFrame = round(handles.uiControls.sliderFrame.Value);
        I = stack{curFrame};
        %% Test
        
        %% ----------Show Image----------
        xlim = get(handles.axes1, 'XLim'); %Get zoom factor
        ylim = get(handles.axes1, 'YLim');
                
        if handles.uiControls.popOriFil.Value == 3
            imshow(I,[],'Parent',handles.axes1);            
        else
            I = uint16(I);
            I = imadjust(I,stretchlim(uint16(stack{1}),0));
            if  handles.uiControls.ckboxStd.Value
                dummyStack = zeros(size(stack{1},1),size(stack{1},2),length(stack));
                for m=1:length(stack)
                    dummyStack(:,:,m) = stack{m};
                end
                I = std(dummyStack,0,3);
                I = uint16(I);
                I = imadjust(I,stretchlim(uint16(I),0));
            end
            if handles.uiControls.ckboxBrightness.Value
                I = imadjust(I);
            end
            if handles.uiControls.ckboxContrast.Value
                I = histeq(I);
            end
            if handles.uiControls.ckboxAdaptive.Value
                I = adapthisteq(I);
            end
            
            imshow(I,'DisplayRange',[handles.uiControls.sliderBlack.Value handles.uiControls.sliderWhite.Value],'Parent',handles.axes1);
            
        end
        % return
        zoom reset;
        handles.axes1.XLim = xlim; %Set Zoom
        handles.axes1.YLim = ylim;
        
        handles.uiControls.editFrameNum.String = num2str(curFrame);
        
        hold on;
        
        %% ----------Plot Tracks--------------
        tracks = {handles.tracksFiltered,handles.tracksFiltered_2};
        ColOrd = get(gca,'ColorOrder'); %Get color order to make sure Tracks always get the same color
                
        if  strcmp(handles.uiControls.popTracks.Enable,'on')
            for j = 1:2 %Substack 1&2
                for i = 1:length(tracks{:,j}) %Iterate through tracks
                    if handles.uiControls.ckboxUniformTrackColor.Value == 0
                        ColRow = rem(i,7); %Determine which color to use (7 colors in total)
                        if ColRow == 0
                            ColRow = 7;
                        end
                        Col = ColOrd(ColRow,:); %Get plotting color
                    else
                        Col = ColOrd(j,:);
                    end
                    
                    plotInputArgs = {'LineStyle','-','LineWidth', 2,'Color', Col};
                    index = 0; %Index up to which spot the track is plotted (0 -> hide track)
                    switch get(handles.uiControls.popTracks,'Value')
                        case 1 %Plot all Tracks
                            if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String) %Plot only Tracks wihtin desired Tracklength range
                                index = size(tracks{j}{i},1);
                            end
                        case 2 %Continuouly plot tracks in current frame
                            if find(curFrame <= max(tracks{j}{i}(:,1)) && curFrame >= min(tracks{j}{i}(:,1)))
                                if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String) %Plot only Tracks wihtin desired Tracklength range
                                    index = find(tracks{j}{i}(:,1) <= curFrame, 1, 'last');
                                end
                            end
                        case 3 %Continuously plot all tracks until current frame
                            if find(curFrame >= min(tracks{j}{i}(:,1)))
                                if  size(tracks{j}{i},1) >= str2double(handles.uiControls.editTrackMin.String) && size(tracks{j}{i},1) <= str2double(handles.uiControls.editTrackMax.String)
                                    index = find(tracks{j}{i}(:,1) <= curFrame, 1, 'last');
                                end
                            end
                    end
                    plot(tracks{j}{i}(1:index, 2), tracks{j}{i}(1:index, 3), plotInputArgs{:});
                end
            end
        end
        
        %% ----------Plot Spots--------------
        
        if handles.uiControls.ckboxSpots.Value
            plotInputArgs = {'LineStyle','none','Marker','o', 'MarkerSize', 10','LineWidth', 1};
            if curFrame <= length(handles.spots) && size(handles.spots{curFrame},1) ~=0  %Check if spots exits in current frame of current stack
                plot (handles.spots{curFrame}(:,1),handles.spots{curFrame}(:,2),'MarkerEdgeColor', ColOrd(6,:),plotInputArgs{:});
            end
            if  curFrame <= length(handles.spots_2) && size(handles.spots_2{curFrame},1) ~=0 %Check if spots exits in current frame of current stack
                plot (handles.spots_2{curFrame}(:,1),handles.spots_2{curFrame}(:,2),'MarkerEdgeColor',ColOrd(3,:),plotInputArgs{:});
            end
        end
        
        %% ----------Plot ROI and ROE--------------
        plot(handles.ROIlist(:,1),handles.ROIlist(:,2),'LineWidth',1.1,'Color',[1 1 1]);
        %         visboundaries(handles.ROI,'Color','w','EnhanceVisibility', false);
        
        for i = 1:length(handles.ROElist)
            x = cat(1,handles.ROElist{i}(:,1), handles.ROElist{i}(1,1)); %Close ROEs
            y = cat(1,handles.ROElist{i}(:,2), handles.ROElist{i}(1,2)); %Close ROEs
            plot(x,y,'LineWidth',1.1,'Color','g');
        end
        
        hold off;
        impixelinfo
        
        %% ----------Plot Boundaries for Hoechst Analysis-----
        if strcmp(handles.uiControls.btnHoechstTrackAssign.Enable,'on')
            
            divisor = ceil(curFrame/handles.seq(2));
            
            stack_1 = getappdata(hFig,'Stack_1');
            
            avgNum = str2double(handles.uiControls.editAverage.String);
            curAvgNum = avgNum;
            divisor_1 = floor(length(stack_1)/curAvgNum);
            remainder = mod(length(stack_1),curAvgNum);
            
            for i=0:divisor_1
                if i == divisor_1 %Last sequence might have less frames
                    curAvgNum = remainder;
                end
                dummyFrame = zeros(size(stack_1{1},1),size(stack_1{1},2));
                for m=1:curAvgNum
                    dummyFrame = dummyFrame + stack_1{i*curAvgNum+m};
                end
                dummyFrame = dummyFrame / curAvgNum; 
                for m=1:curAvgNum
                    stack_1{i*avgNum+m} = dummyFrame;
                end
            end
            
            hold on;
            
            if handles.uiControls.ckboxPlotPixels.Value == 1
                plot_binary_pixel_boundaries(stack_1{divisor}, handles.Th1, 'g')
                plot_binary_pixel_boundaries(stack_1{divisor}, handles.Th2, 'b')
            else
                curFrameBoundary1 = handles.boundaries1{divisor};
                curFrameBoundary2 = handles.boundaries2{divisor};
                visboundaries(curFrameBoundary1,'Color','g','EnhanceVisibility', false);
                visboundaries(curFrameBoundary2,'Color','b','EnhanceVisibility', false);
            end
            hold off;
        end
        
        %% ----------Plot Colocalized Spots--------------
        
        colocalizedTracks = handles.colocalizedTracks;
        
        if ~isempty(colocalizedTracks)
            for i = 1:size(colocalizedTracks,1)
                colocalizedSpots_1{i} = colocalizedTracks{i,1}(find(colocalizedTracks{i,1}(:,4)),1:3); %Search for the "1"s in colocalized tracks -> colocalized spots
                colocalizedSpots_2{i} = colocalizedTracks{i,2}(find(colocalizedTracks{i,2}(:,4)),1:3);
            end
            
            hold on;
            for i = 1:length(colocalizedSpots_2)
                switch get(handles.uiControls.popTracks,'Value')
                    case 1 %Plot all Tracks together with all colocalized spots
                        plot(colocalizedSpots_1{i}(:, 2), colocalizedSpots_1{i}(:, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                        plot(colocalizedSpots_2{i}(:, 2), colocalizedSpots_2{i}(:, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                    case 2 %Continuouly plot tracks together with colocalized spots in current frame
                        index_1 = find(curFrame == colocalizedSpots_1{i}(:,1));
                        index_2 = find(curFrame == colocalizedSpots_2{i}(:,1));
                        plot(colocalizedSpots_1{i}(index_1, 2), colocalizedSpots_1{i}(index_1, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                        plot(colocalizedSpots_2{i}(index_2, 2), colocalizedSpots_2{i}(index_2, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                    case 3 %Continuously plot all tracks until current frame
                        index_1 = find(curFrame >= colocalizedSpots_1{i}(:,1));
                        index_2 = find(curFrame >= colocalizedSpots_2{i}(:,1));
                        plot(colocalizedSpots_1{i}(index_1, 2), colocalizedSpots_1{i}(index_1, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','b','LineWidth', 2);
                        plot(colocalizedSpots_2{i}(index_2, 2), colocalizedSpots_2{i}(index_2, 3),'s', 'MarkerSize', 20,'MarkerEdgeColor','r','LineWidth', 2);
                end
                
            end
            hold off;
       end
    end

    function SetGUIState(state)
        handlesLoadStackEnable = [handles.menuTrackLifes,handles.menuHoechst,...
            handles.menuColocalization, handles.menuDiffusion,...
            handles.uiControls.ckboxAverage,handles.uiControls.editAverage, handles.uiControls.ckboxStd,...
            handles.uiControls.ckboxAdaptive, handles.uiControls.ckboxContrast, handles.uiControls.ckboxBrightness,...
            handles.uiControls.sliderBlack,handles.uiControls.sliderWhite,handles.uiControls.btnFilter,...
            handles.uiControls.sliderFrame,handles.menuVideo,handles.uiControls.btnSubstacks,...
            handles.uiControls.btnReset,handles.uiControls.btnAddROI];
        
        handlesResetDisable = [handles.uiControls.popOriFil, handles.uiControls.editInT,...
            handles.uiControls.editSNR,handles.uiControls.editStartFrame,handles.uiControls.editEndFrame,...
            handles.uiControls.btnFindSpots,handles.uiControls.btnFitSpots,handles.uiControls.editMaxJump,...
            handles.uiControls.editMinLength,handles.uiControls.editDarkFrames,handles.uiControls.btnAddROE,...
            handles.uiControls.btnFindTracks,handles.uiControls.btnDiffusionAna,handles.uiControls.btnHoechstRegions,...
            handles.uiControls.btnCreateHistogram,handles.uiControls.btnSave,handles.uiControls.ckboxSpots,...
            handles.uiControls.popTracks,handles.uiControls.editTrackMin,handles.uiControls.editTrackMax,...
            handles.uiControls.ckboxPlotPixels,handles.uiControls.btnHoechstTrackAssign,...
            handles.uiControls.ckboxUniformTrackColor];
%         ,handles.uiControls.btnColocalize
        handlesFilterEnable = [handles.uiControls.popOriFil,handles.uiControls.editInT,...
            handles.uiControls.editSNR,handles.uiControls.editStartFrame,handles.uiControls.editEndFrame,...
            handles.uiControls.btnFindSpots];
        
        handlesFindSpotsEnable = [handles.uiControls.btnFitSpots, handles.uiControls.ckboxSpots];
        
        handlesFitSpotsEnable = [handles.uiControls.editMaxJump,handles.uiControls.editMinLength,...
            handles.uiControls.editDarkFrames,handles.uiControls.btnFindTracks,...
            handles.uiControls.btnDiffusionAna,handles.uiControls.btnAddROE];
        
        handlesFindTracksEnable = [handles.uiControls.popTracks,handles.uiControls.editTrackMin,...
            handles.uiControls.editTrackMax,handles.uiControls.ckboxUniformTrackColor,handles.uiControls.btnCreateHistogram,...
            handles.uiControls.btnHoechstRegions];
        
        switch state
            case 'Reset' %Reset, LoadStack, Divide into Substack or AddROI
                set(handlesLoadStackEnable, 'Enable', 'on');
                set(handlesResetDisable, 'Enable', 'off');
                handles.uiControls.ckboxSpots.Value = 0;
            case 'Filter' %Filter Image
                set(handlesResetDisable, 'Enable', 'off');
                set(handlesFilterEnable, 'Enable', 'on');
                handles.uiControls.ckboxSpots.Value = 0;
            case 'FindSpots' %Find Spots
                set(handlesResetDisable, 'Enable', 'off');
                set(handlesFilterEnable, 'Enable', 'on');
                set(handlesFindSpotsEnable, 'Enable', 'on');
                
                handles.uiControls.ckboxSpots.Value = 1;
                
            case 'FitSpots' %Fit Spots or LoadStack w/ spots loaded
                set(handlesResetDisable, 'Enable', 'off');
                set(handlesFilterEnable, 'Enable', 'on');
                set(handlesFindSpotsEnable, 'Enable', 'on');
                set(handlesFitSpotsEnable, 'Enable', 'on');
            case 'AddROE' %Add Exclusi'on'
                handles.uiControls.btnDelROE.Enable = 'on';
            case 'DelROE' %Delete Exclusi'on'
                handles.uiControls.btnDelROE.Enable = 'off';
            case 'FindTracks' %Find Tracks or load .mat tracks
                set(handlesResetDisable, 'Enable', 'off');
                set(handlesFilterEnable, 'Enable', 'on');
                set(handlesFindSpotsEnable, 'Enable', 'on');
                set(handlesFitSpotsEnable, 'Enable', 'on');
                set(handlesFindTracksEnable, 'Enable', 'on');
                
                if strcmp(handles.menuHoechst.Checked, 'off') %In Hoechst analysis, regions have to be drawn before saving
                    handles.uiControls.btnSave.Enable = 'on';
                end
                
            case 'DefineRegions' %Hoechst Regions
                handles.uiControls.btnHoechstTrackAssign.Enable = 'on';
                handles.uiControls.btnSave.Enable = 'off';
                handles.uiControls.ckboxPlotPixels.Enable = 'on';
            case 'AssignTracks' %Hoechst Track analysis
                handles.uiControls.btnSave.Enable = 'on';
        end
    end

end
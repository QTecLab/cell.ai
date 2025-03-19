function varargout = MultiModalLabeler(varargin)
% MULTIMODALLABELER MATLAB code for MultiModalLabeler.fig
%      MULTIMODALLABELER, by itself, creates a new MULTIMODALLABELER or raises the existing
%      singleton*.
%
%      H = MULTIMODALLABELER returns the handle to a new MULTIMODALLABELER or the handle to
%      the existing singleton*.
%
%      MULTIMODALLABELER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMODALLABELER.M with the given input arguments.
%
%      MULTIMODALLABELER('Property','Value',...) creates a new MULTIMODALLABELER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiModalLabeler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiModalLabeler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiModalLabeler

% Last Modified by GUIDE v2.5 19-Mar-2025 05:58:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiModalLabeler_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiModalLabeler_OutputFcn, ...
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

global g_images_dir g_images_name g_images_num g_image_index g_image_mask g_cum_mask g_current_img;
global g_fouridesp g_color_hist g_hogdesp g_center g_box g_polygon;
global g_config g_regionid;
% End initialization code - DO NOT EDIT


% --- Executes just before MultiModalLabeler is made visible.
function MultiModalLabeler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiModalLabeler (see VARARGIN)

global g_images_dir g_images_name g_images_num g_image_index;
% Choose default command line output for MultiModalLabeler
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MultiModalLabeler wait for user response (see UIRESUME)
% uiwait(handles.figure1);
g_images_dir = [];
g_images_name = [];
g_images_num = 0;
g_image_index = 0;


% --- Outputs from this function are returned to the command line.
function [y,approach_shape]=FouriDesp(bw,ratio)
    if(ratio>1)
        ratio=1;
    elseif(ratio<0)
        ratio=1;
    end
    
    b=bwboundaries(bw);
    boundary=b{1,1};
    x=boundary(:,2);
    y=boundary(:,1);

    cnt=complex(x,y);
    fft_cnt=fft(cnt);

    cnt_length=length(cnt);
    keep_length=round(cnt_length*ratio);
    center=floor(cnt_length/2);

    fft_cnt_center=fftshift(fft_cnt);
    y=fft_cnt_center(center-floor(keep_length/2)+1:center+floor(keep_length/2));
    
    %reconstruct
    fft_keep=fft_cnt_center;
    fft_keep(1:center-floor(keep_length/2))=0;
    fft_keep(center+floor(keep_length/2)+1:end)=0;
    fft_keep=ifftshift(fft_keep);

    cord=ifft(fft_keep);
    x_=round(real(cord));
    y_=round(imag(cord));
    approach_shape=[x_(:),y_(:)];

function varargout = MultiModalLabeler_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OpenDir.
function OpenDir_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_images_dir g_images_name g_images_num g_image_index g_image_mask g_cum_mask g_current_img g_regionid;
g_image_mask = [];
g_cum_mask = [];
g_images_dir = uigetdir();
g_images_name = dir(g_images_dir);
g_images_num = size(g_images_name,1)-2;
g_image_index = 0;
g_current_img=[];
g_regionid=0;
if(g_images_num<=0)
    msgbox('no image');
else
   g_image_index=g_image_index+1;
   img=imread([g_images_dir,'\',g_images_name(g_image_index+2).name]);
   axes(handles.axes1);
   imshow(img);
   g_current_img=img;
end


% --- Executes on button press in PreImage.
function PreImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_images_dir g_images_name g_images_num g_image_index g_image_mask g_cum_mask g_current_img g_regionid;
g_image_mask = []; g_cum_mask = [];g_regionid=0;
if(g_images_num<=0)
    msgbox('no image');
    
else
    if(g_image_index<=1)
       msgbox('Already at the first image');
    else
       g_image_index=g_image_index-1;
       img=imread([g_images_dir,'\',g_images_name(g_image_index+2).name]);
       axes(handles.axes1);
       imshow(img);
       g_current_img=img;
    end
end


% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_images_dir g_images_name g_images_num g_image_index g_image_mask g_cum_mask g_current_img g_regionid;
g_image_mask = []; g_cum_mask = [];g_regionid=0;
if(g_images_num<=0)
    msgbox('no image');
else
    if(g_image_index>=g_images_num)
       msgbox('Already at the last image');
    else
       g_image_index=g_image_index+1;
       img=imread([g_images_dir,'\',g_images_name(g_image_index+2).name]);
       axes(handles.axes1);
       imshow(img);
       g_current_img=img;
    end
end


% --- Executes on selection change in tag_dict_listbox.
function tag_dict_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to tag_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tag_dict_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tag_dict_listbox


% --- Executes during object creation, after setting all properties.
function tag_dict_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tag_item_Callback(hObject, eventdata, handles)
% hObject    handle to tag_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tag_item as text
%        str2double(get(hObject,'String')) returns contents of tag_item as a double


% --- Executes during object creation, after setting all properties.
function tag_item_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddTag.
function AddTag_Callback(hObject, eventdata, handles)
% hObject    handle to AddTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tag = get(handles.tag_item, 'String');
tag_dict = cellstr(get(handles.tag_dict_listbox,'string'));
if ~strcmp(tag, tag_dict)
	new_list = [tag_dict; cellstr(tag)];
	set(handles.tag_dict_listbox,'string',new_list);
end




% --- Executes on button press in ChooseTag.
function ChooseTag_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedIndex = get(handles.tag_dict_listbox, 'Value');
selectedItem = get(handles.tag_dict_listbox, 'String');
selectedContent = selectedItem{selectedIndex};
tag_list = cellstr(get(handles.tag_listbox,'string'));
if ~strcmp(selectedContent, tag_list)
	new_list = [tag_list; cellstr(selectedContent)];
	set(handles.tag_listbox,'string',new_list);
end


% --- Executes on button press in CreatePolygonMask.
function CreatePolygonMask_Callback(hObject, eventdata, handles)
% hObject    handle to CreatePolygonMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_images_num g_image_index g_image_mask g_cum_mask g_current_img g_center g_box g_polygon g_regionid;
g_center=[];
g_box=[];
g_polygon=[];
g_regionid=g_regionid+1;
if(g_image_index>g_images_num || g_image_index<=0)
   msgbox('no image');
   g_image_mask = [];
   return;
else
   img=g_current_img;
   axes(handles.axes2);
   BW = roipoly(img);
   D=regionprops(BW,'centroid','BoundingBox');
   centroids = cat(1, D.Centroid);
   g_center=centroids;
   scenter=['x=',num2str(centroids(1)),' y=',num2str(centroids(2))];
   set(handles.edit9,'String',scenter);
   box=round(cat(1,D.BoundingBox));
   g_box=box;
   sbox=['x=',num2str(box(1)),' y=',num2str(box(2)),' w=',num2str(box(3)),' h=',num2str(box(4))];
   set(handles.edit8,'String',sbox);
   b=bwboundaries(BW);
   g_polygon=round(b{1,1});  %y x
   pointnum=size(g_polygon,1);
   spoint=[];
   for k=1:pointnum-1
       spoint=[spoint,'x=',num2str(g_polygon(k,2)),' y=',num2str(g_polygon(k,1)),';'];
   end
   spoint=[spoint,'x=',num2str(g_polygon(pointnum,2)),' y=',num2str(g_polygon(pointnum,1))];
   set(handles.polygon_position,'String',spoint);
   g_image_mask = BW;
   color=round(rand(1,3)*255);
   if(isempty(g_cum_mask))
       if(size(img,3)==1)
           img(g_image_mask>0)=color(1);
           imshow(img)
       else
           r=img(:,:,1);
           g=img(:,:,2);
           b=img(:,:,3);
           r(g_image_mask>0)=color(1);
           g(g_image_mask>0)=color(2);
           b(g_image_mask>0)=color(3);
           img=cat(3,r,g,b);
           imshow(img)
       end
       g_cum_mask = g_image_mask;
   else
       g_cum_mask = g_image_mask + g_cum_mask;
       if(size(img,3)==1)
           img(g_image_mask>0)=color(1);
           imshow(img);
       else
           r=img(:,:,1);
           g=img(:,:,2);
           b=img(:,:,3);
           r(g_image_mask>0)=color(1);
           g(g_image_mask>0)=color(2);
           b(g_image_mask>0)=color(3);
           img=cat(3,r,g,b);
           imshow(img);
       end
   end
   
   g_current_img = img;
end


% --- Executes on selection change in shape_dict_listbox.
function shape_dict_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to shape_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns shape_dict_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shape_dict_listbox


% --- Executes during object creation, after setting all properties.
function shape_dict_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shape_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shape_item_Callback(hObject, eventdata, handles)
% hObject    handle to shape_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shape_item as text
%        str2double(get(hObject,'String')) returns contents of shape_item as a double


% --- Executes during object creation, after setting all properties.
function shape_item_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shape_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddShape.
function AddShape_Callback(hObject, eventdata, handles)
% hObject    handle to AddShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shape = get(handles.shape_item, 'String');
shape_dict = cellstr(get(handles.shape_dict_listbox,'string'));
if ~strcmp(shape, shape_dict)
	new_list = [shape_dict; cellstr(shape)];
	set(handles.shape_dict_listbox,'string',new_list);
end

% --- Executes on button press in ChooseShape.
function ChooseShape_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedIndex = get(handles.shape_dict_listbox, 'Value');
selectedItem = get(handles.shape_dict_listbox, 'String');
selectedContent = selectedItem{selectedIndex};
shape_list = cellstr(get(handles.shape_listbox,'string'));
if ~strcmp(selectedContent, shape_list)
	new_list = [shape_list; cellstr(selectedContent)];
	set(handles.shape_listbox,'string',new_list);
end

% --- Executes on selection change in color_dict_listbox.
function color_dict_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to color_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color_dict_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_dict_listbox


% --- Executes during object creation, after setting all properties.
function color_dict_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function color_item_Callback(hObject, eventdata, handles)
% hObject    handle to color_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color_item as text
%        str2double(get(hObject,'String')) returns contents of color_item as a double


% --- Executes during object creation, after setting all properties.
function color_item_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddColor.
function AddColor_Callback(hObject, eventdata, handles)
% hObject    handle to AddColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

color = get(handles.color_item, 'String');
color_dict = cellstr(get(handles.color_dict_listbox,'string'));
if ~strcmp(color, color_dict)
	new_list = [color_dict; cellstr(color)];
	set(handles.color_dict_listbox,'string',new_list);
end

% --- Executes on button press in ChooseColor.
function ChooseColor_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedIndex = get(handles.color_dict_listbox, 'Value');
selectedItem = get(handles.color_dict_listbox, 'String');
selectedContent = selectedItem{selectedIndex};
color_list = cellstr(get(handles.color_listbox,'string'));
if ~strcmp(selectedContent, color_list)
	new_list = [color_list; cellstr(selectedContent)];
	set(handles.color_listbox,'string',new_list);
end


% --- Executes on selection change in texture_dict_listbox.
function texture_dict_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to texture_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns texture_dict_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from texture_dict_listbox


% --- Executes during object creation, after setting all properties.
function texture_dict_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to texture_dict_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function texture_item_Callback(hObject, eventdata, handles)
% hObject    handle to texture_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of texture_item as text
%        str2double(get(hObject,'String')) returns contents of texture_item as a double


% --- Executes during object creation, after setting all properties.
function texture_item_CreateFcn(hObject, eventdata, handles)
% hObject    handle to texture_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddTexture.
function AddTexture_Callback(hObject, eventdata, handles)
% hObject    handle to AddTexture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
texture = get(handles.texture_item, 'String');
texture_dict = cellstr(get(handles.texture_dict_listbox,'string'));
if ~strcmp(texture, texture_dict)
	new_list = [texture_dict; cellstr(texture)];
	set(handles.texture_dict_listbox,'string',new_list);
end

% --- Executes on button press in ChooseTexture.
function ChooseTexture_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseTexture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedIndex = get(handles.texture_dict_listbox, 'Value');
selectedItem = get(handles.texture_dict_listbox, 'String');
selectedContent = selectedItem{selectedIndex};
texture_list = cellstr(get(handles.texture_listbox,'string'));
if ~strcmp(selectedContent, texture_list)
	new_list = [texture_list; cellstr(selectedContent)];
	set(handles.texture_listbox,'string',new_list);
end

% --- Executes on selection change in shape_listbox.
function shape_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to shape_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns shape_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shape_listbox


% --- Executes during object creation, after setting all properties.
function shape_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shape_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color_listbox.
function color_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to color_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_listbox


% --- Executes during object creation, after setting all properties.
function color_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in texture_listbox.
function texture_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to texture_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns texture_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from texture_listbox


% --- Executes during object creation, after setting all properties.
function texture_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to texture_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tag_listbox.
function tag_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to tag_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tag_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tag_listbox


% --- Executes during object creation, after setting all properties.
function tag_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CreateContinueDesc.
function CreateContinueDesc_Callback(hObject, eventdata, handles)
% hObject    handle to CreateContinueDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveDesc.
function SaveDesc_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_config g_image_index g_images_name g_fouridesp g_color_hist g_hogdesp g_center g_box g_polygon g_image_mask g_regionid;
g_config=load('config.mat');
desp_savepath=g_config.config{2,1};
desp_filename=[desp_savepath,'\',g_images_name(g_image_index+2).name,'.xml'];

fileID = fopen(desp_filename, 'a');

if fileID == -1
    error('cannot open file');
end

fprintf(fileID, '%s\n','<regionid>');
fprintf(fileID, '%d\n', g_regionid);
fprintf(fileID, '%s\n','<regionid\End>');

fprintf(fileID, '\n%s\n','<bounding_box>');
for i=1:4
    fprintf(fileID, '%d\n',g_box(i));
end
fprintf(fileID, '%s\n','<bounding_box\End>');

fprintf(fileID, '\n%s\n','<center>');
for i=1:2
    fprintf(fileID, '%d\n',g_center(i));
end
fprintf(fileID, '%s\n','<center\End>');

fprintf(fileID, '\n%s\n','<polygon_pointnum>');
fprintf(fileID, '%d',size(g_polygon,1));
fprintf(fileID, '\n%s\n','<polygon_pointnum\End>');

fprintf(fileID, '\n%s\n','<polygon>');
polygon_point_num=size(g_polygon,1);
for i=1:polygon_point_num
    fprintf(fileID, '%d\n',g_polygon(i));
end
fprintf(fileID, '%s\n','<polygon\End>');

fprintf(fileID, '\n%s\n','<image_mask>');
for i=g_box(2):g_box(2)+g_box(4)-1
   for j=g_box(1):g_box(1)+g_box(3)-1
       fprintf(fileID, '%d\n',g_image_mask(i,j));
   end
end
fprintf(fileID, '\n%s\n','<image_mask\End>');

fprintf(fileID, '\n%s\n','<tag>');
tag_items = cellstr(get(handles.tag_listbox, 'String'));
tag_items_num = size(tag_items,1);
for i=2:tag_items_num
    fprintf(fileID, '%s\n',tag_items{i,1});
end
fprintf(fileID, '%s\n','<tag\End>');
%clear tag_listbox
items = cellstr(get(handles.tag_listbox, 'String'));
selected = 2:size(items,1);
if isempty(selected) || isempty(items)
    return;
end
items(selected) = [];
set(handles.tag_listbox, 'String', items);
new_len = length(items);
if new_len == 0
    set(handles.tag_listbox, 'Value', 1); 
else
    set(handles.tag_listbox, 'Value', 1); 
end
guidata(hObject, handles);

fprintf(fileID, '\n%s\n','<shape>');
shape_items = cellstr(get(handles.shape_listbox, 'String'));
shape_items_num = size(shape_items,1);
for i=2:shape_items_num
    fprintf(fileID, '%s\n',shape_items{i,1});
end
fprintf(fileID, '%s\n','<shape\End>');
%clear shape_listbox
items = cellstr(get(handles.shape_listbox, 'String'));
selected = 2:size(items,1);
if isempty(selected) || isempty(items)
    return;
end
items(selected) = [];
set(handles.shape_listbox, 'String', items);
new_len = length(items);
if new_len == 0
    set(handles.shape_listbox, 'Value', 1); 
else
    set(handles.shape_listbox, 'Value', 1); 
end
guidata(hObject, handles);

fprintf(fileID, '\n%s\n','<color>');
color_items = cellstr(get(handles.color_listbox, 'String'));
color_items_num = size(color_items,1);
for i=2:color_items_num
    fprintf(fileID, '%s\n',color_items{i,1});
end
fprintf(fileID, '%s\n','<color\End>');
%clear color_listbox
items = cellstr(get(handles.color_listbox, 'String'));
selected = 2:size(items,1);
if isempty(selected) || isempty(items)
    return;
end
items(selected) = [];
set(handles.color_listbox, 'String', items);
new_len = length(items);
if new_len == 0
    set(handles.color_listbox, 'Value', 1); 
else
    set(handles.color_listbox, 'Value', 1); 
end
guidata(hObject, handles);

fprintf(fileID, '\n%s\n','<texture>');
texture_items = cellstr(get(handles.texture_listbox, 'String'));
texture_items_num = size(texture_items,1);
for i=2:texture_items_num
    fprintf(fileID, '%s\n',texture_items{i,1});
end
fprintf(fileID, '%s\n','<texture\End>');
%clear texture_listbox
items = cellstr(get(handles.texture_listbox, 'String'));
selected = 2:size(items,1);
if isempty(selected) || isempty(items)
    return;
end
items(selected) = [];
set(handles.texture_listbox, 'String', items);
new_len = length(items);
if new_len == 0
    set(handles.texture_listbox, 'Value', 1); 
else
    set(handles.texture_listbox, 'Value', 1); 
end
guidata(hObject, handles);

fprintf(fileID, '\n%s\n','<fouri_despnum>');
fprintf(fileID, '%d\n',size(g_fouridesp,1));
fprintf(fileID, '%s\n','<fouri_despnum\End>');

fprintf(fileID, '\n%s\n','<fouri_desp>');
fouri_despnum=size(g_fouridesp,1);
for i=1:fouri_despnum
    fprintf(fileID, '%d\n',real(g_fouridesp(i)));
    fprintf(fileID, '%d\n',imag(g_fouridesp(i)));
end
fprintf(fileID, '%s\n','<fouri_desp\End>');

fprintf(fileID, '\n%s\n','<color_despnum>');
fprintf(fileID, '%d\n',size(g_color_hist,1)*size(g_color_hist,2));
fprintf(fileID, '%s\n','<color_despnum\End>');

fprintf(fileID, '\n%s\n','<color_histbin_num>');
fprintf(fileID, '%d\n',g_config.config{4,1});
fprintf(fileID, '%s\n','<color_histbin_num\End>');

fprintf(fileID, '\n%s\n','<color_desp>');
color_despnum=size(g_color_hist,1);
channelnum=size(g_color_hist,2);
for i=1:color_despnum
    for j=1:channelnum
        fprintf(fileID, '%d\n',g_color_hist(i,j));
    end
end
fprintf(fileID, '%s\n','<color_desp\End>');

fprintf(fileID, '\n%s\n','<hog_despnum>');
fprintf(fileID, '%d\n',size(g_hogdesp,2));
fprintf(fileID, '%s\n','<hog_despnum\End>');

fprintf(fileID, '\n%s\n','<hog_desp>');
hog_despnum=size(g_hogdesp,2);
for i=1:hog_despnum
    fprintf(fileID, '%d\n',g_hogdesp(i));
end
fprintf(fileID, '%s\n','<hog_desp\End>');

fprintf(fileID, '\n%s\n','<text_desp>');
text_desp=get(handles.text_description,'String');
fprintf(fileID, '%s\n',text_desp);
fprintf(fileID, '%s\n','<text_desp\End>');

fclose(fileID);


% --- Executes on button press in SetConfig.
function SetConfig_Callback(hObject, eventdata, handles)
% hObject    handle to SetConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if ~isfield(handles, 'ConfigSetFig') || ~isvalid(handles.ConfigSetFig)
%     % 加载预构建的fig文件
%     handles.ConfigSetFig = openfig('ConfigSet.fig', 'reuse');  % 使用'reuse'防止重复加载
% 
%     % 获取子窗口句柄
%     ConfigSetHandles = guidata(handles.ConfigSetFig);
% 
%     % 存储子窗口句柄到主窗口
%     handles.ConfigSetHandles = ConfigSetHandles;
%     guidata(hObject, handles);  % 更新主窗口数据
% else
%     % 如果窗口存在则前置显示
%     figure(handles.ConfigSetFig)
% end

subFig = findall(0, 'Type', 'figure', 'Tag', 'ConfigSet');
if isempty(subFig)
    % 启动子GUI
    ConfigSet();
else
    % 将焦点移至现有子GUI
    figure(subFig(1));
end


function text_description_Callback(hObject, eventdata, handles)
% hObject    handle to text_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_description as text
%        str2double(get(hObject,'String')) returns contents of text_description as a double


% --- Executes during object creation, after setting all properties.
function text_description_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SaveDictionary.
function SaveDictionary_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDictionary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tag_items = cellstr(get(handles.tag_dict_listbox, 'String'));
shape_items = cellstr(get(handles.shape_dict_listbox, 'String'));
color_items = cellstr(get(handles.color_dict_listbox, 'String'));
texture_items = cellstr(get(handles.texture_dict_listbox, 'String'));
dic_sets=cell(4,1);
dic_sets{1,1}=tag_items;
dic_sets{2,1}=shape_items;
dic_sets{3,1}=color_items;
dic_sets{4,1}=texture_items;
save('dic_sets.mat','dic_sets');
msgbox('save dictionarys success');


function polygon_position_Callback(hObject, eventdata, handles)
% hObject    handle to polygon_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of polygon_position as text
%        str2double(get(hObject,'String')) returns contents of polygon_position as a double


% --- Executes during object creation, after setting all properties.
function polygon_position_CreateFcn(hObject, eventdata, handles)
% hObject    handle to polygon_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DeleteTagDict.
function DeleteTagDict_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteTagDict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.tag_dict_listbox, 'Value');
items = cellstr(get(handles.tag_dict_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.tag_dict_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.tag_dict_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.tag_dict_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);



% --- Executes on button press in DeleteTagListbox.
function DeleteTagListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteTagListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.tag_listbox, 'Value');
items = cellstr(get(handles.tag_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.tag_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.tag_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.tag_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteShapeListbox.
function DeleteShapeListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteShapeListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.shape_listbox, 'Value');
items = cellstr(get(handles.shape_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.shape_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.shape_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.shape_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteColorListbox.
function DeleteColorListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteColorListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.color_listbox, 'Value');
items = cellstr(get(handles.color_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.color_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.color_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.color_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteTextureListbox.
function DeleteTextureListbox_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteTextureListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.texture_listbox, 'Value');
items = cellstr(get(handles.texture_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.texture_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.texture_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.texture_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteShapeDict.
function DeleteShapeDict_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteShapeDict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.shape_dict_listbox, 'Value');
items = cellstr(get(handles.shape_dict_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.shape_dict_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.shape_dict_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.shape_dict_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteColorDict.
function DeleteColorDict_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteColorDict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.color_dict_listbox, 'Value');
items = cellstr(get(handles.color_dict_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.color_dict_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.color_dict_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.color_dict_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in DeleteTextureDict.
function DeleteTextureDict_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteTextureDict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.texture_dict_listbox, 'Value');
items = cellstr(get(handles.texture_dict_listbox, 'String'));

% 检查是否有选中项
if isempty(selected) || isempty(items)
    return;
end

% 删除选中的项目
items(selected) = [];

% 更新Listbox
set(handles.texture_dict_listbox, 'String', items);

% 调整选中索引
new_len = length(items);
if new_len == 0
    set(handles.texture_dict_listbox, 'Value', 1); % 列表为空时设为1
else
    set(handles.texture_dict_listbox, 'Value', 1); % 重置为第一项
end

guidata(hObject, handles);

% --- Executes on button press in AutoCreate.
function AutoCreate_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

is_checked=get(handles.AutoCreate,'Value');
if(is_checked)
    tag_list = cellstr(get(handles.tag_listbox,'string'));
    tag_num=size(tag_list,1)-1;
    text_description='';
    if(tag_num>0)
        text_description='this is a picture of ';
        for i=1:tag_num
            text_description=[text_description,tag_list{i+1,1}];
            if(i==tag_num)
                text_description=[text_description,'. '];
            else
                text_description=[text_description,'; '];
            end
        end
    end
    
    shape_list = cellstr(get(handles.shape_listbox,'string'));
    shape_num=size(shape_list,1)-1;
    if(shape_num>0)
        text_description=[text_description,' the shape is '];
        for i=1:shape_num
            text_description=[text_description,shape_list{i+1,1}];
            if(i==shape_num)
                text_description=[text_description,'. '];
            else
                text_description=[text_description,'; '];
            end
        end
    end
    
    color_list = cellstr(get(handles.color_listbox,'string'));
    color_num=size(color_list,1)-1;
    if(color_num>0)
        text_description=[text_description,' the color is '];
        for i=1:color_num
            text_description=[text_description,color_list{i+1,1}];
            if(i==color_num)
                text_description=[text_description,'. '];
            else
                text_description=[text_description,'; '];
            end
        end
    end
    
    texture_list = cellstr(get(handles.texture_listbox,'string'));
    texture_num=size(texture_list,1)-1;
    if(texture_num>0)
        text_description=[text_description,' the texture is '];
        for i=1:texture_num
            text_description=[text_description,texture_list{i+1,1}];
            if(i==texture_num)
                text_description=[text_description,'. '];
            else
                text_description=[text_description,'; '];
            end
        end
    end

    set(handles.text_description, 'string', text_description);
else
    text_description='';
    set(handles.text_description, 'string', text_description);
end
    


% Hint: get(hObject,'Value') returns toggle state of AutoCreate



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_image_mask g_current_img g_fouridesp;
g_fouridesp=[];
if(isempty(g_image_mask))
    msgbox('no mask image');
    return;
end

[y,approach_shape]=FouriDesp(g_image_mask,1);
g_fouridesp = y;
axes(handles.axes3); % 指定绘图的 axes 控件
bar(log10(abs(y)));
title('FouriDesp');

img=g_current_img;
axes(handles.axes2);
imshow(img);
hold on
plot(approach_shape(:,1),approach_shape(:,2),'r','LineWidth',2);
hold off


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_image_mask g_images_dir g_images_name g_image_index g_color_hist;
g_color_hist=[];
if(isempty(g_image_mask))
    msgbox('no mask image');
    return;
end

img=imread([g_images_dir,'\',g_images_name(g_image_index+2).name]);
if(size(img,3)==1)
    gray = img;
    gray(g_image_mask==0)=[];
    g_color_hist = hist(gray)/length(gray);
else
    r = img(:,:,1);
    r(g_image_mask==0)=[];
    r = imhist(r, 32) / length(r);
    
    g = img(:,:,2);
    g(g_image_mask==0)=[];
    g = imhist(g, 32) / length(g);
    
    b = img(:,:,3);
    b(g_image_mask==0)=[];
    b = imhist(b, 32) / length(b);
    
    g_color_hist = [r,g,b];
end

axes(handles.axes4); % 指定绘图的 axes 控件
bar(g_color_hist(:));
title('ColorDesp');

% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_image_mask g_images_dir g_images_name g_image_index g_hogdesp;
g_hogdesp=[];
if(isempty(g_image_mask))
    msgbox('no mask image');
    return;
end

img=imread([g_images_dir,'\',g_images_name(g_image_index+2).name]);
gray=mean(img,3);
rowsum=sum(g_image_mask,2);
colsum=sum(g_image_mask,1);
top=find(rowsum>0,1,'first');
bottom=find(rowsum>0,1,'last');
left=find(colsum>0,1,'first');
right=find(colsum>0,1,'last');
subimg=gray(top:bottom,left:right);
g_hogdesp = extractHOGFeatures(subimg);
if(isempty(g_hogdesp))
    msgbox('mask image is too small to compute HOG');
    return;
else
    axes(handles.axes5); % 指定绘图的 axes 控件
    bar(g_hogdesp);
    title('HogDesp');
end


% --- Executes on button press in LoadDictionary.
function LoadDictionary_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDictionary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dict_sets=load('dic_sets.mat');
tag_dict=dict_sets.dic_sets{1,1};
set(handles.tag_dict_listbox, 'String', tag_dict);
shape_dict=dict_sets.dic_sets{2,1};
set(handles.shape_dict_listbox, 'String', shape_dict);
color_dict=dict_sets.dic_sets{3,1};
set(handles.color_dict_listbox, 'String', color_dict);
texture_dict=dict_sets.dic_sets{4,1};
set(handles.texture_dict_listbox, 'String', texture_dict);

function obj = lslMarker()

% export member function
obj.set = @set;

% setup LSL stream
lib = lsl_loadlib();
info = lsl_streaminfo(lib,'Markers','Marker',1,0,'cf_string');
outlet = lsl_outlet(info);

    % write string to LSL
    function set(str)
        outlet.push_sample({str});
    end

end
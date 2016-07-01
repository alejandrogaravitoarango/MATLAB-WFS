function startWebServer( port )
% Starts a simple webserver using python. It will host files relative to
% the current path.
% 
% Input
%   port:   port the server listens on
% 
%   todo: check if we already have a server up an running
% 
%   150611sk

system(['python -m SimpleHTTPServer ' num2str(port) ' &']); 

end


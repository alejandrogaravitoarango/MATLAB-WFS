classdef echoServer < matWebSocketServer
    %ECHOSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = echoServer(port)
            %Constructor
            obj@matWebSocketServer(port);
        end
    end
    
    methods (Access = protected)
        function onMessage(obj,message,conn)
            % This function sends and echo back to the client
            obj.send(conn,'true'); % Echo
            disp(message)
            
            pause(3)
            
            obj.send(conn,'false'); % Echo            
        end
    end
end


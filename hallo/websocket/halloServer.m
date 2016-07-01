classdef halloServer < matWebSocketServer
    %halloServer 
    % websocket server to communicate with Web-Interface 
    
    properties
        value = 0; 
        stData; 
    end
    
    methods

        function obj = halloServer(port, stData)
            %Constructor
            obj@matWebSocketServer(port);
            obj.stData = stData; 
        end
        
        function value = getValue(obj)
            value = obj.value;
            obj.value = 0; 
        end
        
    end
    
    methods (Access = protected)
        function onMessage(obj,message,conn)
            obj.value = str2double(message); 
            obj.send(conn,'true');
            obj.stData.update(obj.value);
        end
    end
end


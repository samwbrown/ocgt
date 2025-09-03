
---@meta _
---@class internet: BaseComponent
---@field type "internet"
internet={}

---Opens a new TCP connection. Returns the handle of the connection.
---@param address string
---@param port number|nil
---@return socket
function internet.connect(address, port) end

---Returns whether TCP connections can be made (config setting).
---@return boolean if tcp enabled
function internet.isTcpEnabled() end

---Returns whether HTTP requests can be made (config setting).
---@return boolean if http enabled
function internet.isHttpEnabled() end

---Starts an HTTP request. If this returns true, further results will be pushed using `http_response` signals.
---@param url string
---@param postData string|nil
---@param headers table|nil
---@param method string|nil
---@return httpRequest
function internet.request(url, postData, headers, method) end

---@class socket
socket={}

---Ensures a socket is connected. Errors if the connection failed
---@return boolean connection_ok
function socket.finishConnect() end

---Reads data from the socket.
---@param count integer|nil # The number of bytes to read. If omitted, reads all available data.
---@return string|nil data # The data read from the socket, or nil if no data is available.
function socket.read(count) end

---Writes data to the socket.
---@param data string # The data to write to the socket.
---@return integer bytesWritten # number of bytes
function socket.write(data) end

---Closes the socket.
function socket.close() end

---@class httpRequest
httpRequest={}

---Ensures a response is available. Errors if the connection failed
---@return boolean connection_ok
function httpRequest.finishConnect() end

---Reads data from the socket.
---@param count integer|nil # The number of bytes to read. If omitted, reads all available data.
---@return string|nil data # The data read from the socket, or nil if no data is available.
function httpRequest.read(count) end

---Get response code, message and headers
---@return number response_code
---@return string message
---@return table headers
function httpRequest.write(data) end

---Closes the socket.
function httpRequest.close() end
import json
import urllib.parse
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

class Request:
    """Represents an incoming HTTP request in the AntiGravity framework."""
    def __init__(self, path, method, headers, query_params, body):
        self.path = path
        self.method = method
        self.headers = headers
        self.query_params = query_params
        self.body = body
        self.json = {}
        
        # Auto-parse JSON body if content-type is application/json
        content_type = headers.get("Content-Type", "")
        if body and "application/json" in content_type:
            try:
                self.json = json.loads(body)
            except Exception:
                pass

class Response:
    """Represents an outgoing HTTP response in the AntiGravity framework."""
    def __init__(self, body, status=200, content_type="text/html"):
        self.body = body
        self.status = status
        self.content_type = content_type

def render_template(template_name, **context):
    """
    Renders an HTML template from the 'templates' directory by replacing 
    placeholders like {{ variable }} with values from the context.
    """
    template_path = os.path.join("templates", template_name)
    if not os.path.exists(template_path):
        raise FileNotFoundError(f"Template not found: {template_path}")
    
    with open(template_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Simple placeholder interpolation
    for key, value in context.items():
        placeholder_with_space = f"{{{{ {key} }}}}"
        placeholder_no_space = f"{{{{{key}}}}}"
        content = content.replace(placeholder_with_space, str(value))
        content = content.replace(placeholder_no_space, str(value))
        
    return content

class AntiGravity:
    """The central application class for the AntiGravity micro-framework."""
    def __init__(self):
        self.routes = {}

    def route(self, path, methods=["GET"]):
        """Decorator to register a handler function for a specific URL route and HTTP methods."""
        def decorator(func):
            for method in methods:
                self.routes[(path, method.upper())] = func
            return func
        return decorator

    def run(self, host="127.0.0.1", port=8000):
        """Starts the built-in HTTP server to serve the AntiGravity web application."""
        app_instance = self
        
        class AntiGravityHandler(BaseHTTPRequestHandler):
            def log_message(self, format, *args):
                # Format a clean framework server log
                print(f"[AntiGravity] {self.address_string()} - - [{self.log_date_time_string()}] {format % args}")

            def handle_request(self, method):
                parsed_url = urllib.parse.urlparse(self.path)
                path = parsed_url.path
                query_params = urllib.parse.parse_qs(parsed_url.query)
                # Standardize query param values
                query_params = {k: v[0] if len(v) == 1 else v for k, v in query_params.items()}

                # Read body content if present
                content_length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else ""

                request = Request(path, method, self.headers, query_params, body)

                route_key = (path, method)
                if route_key in app_instance.routes:
                    handler = app_instance.routes[route_key]
                    try:
                        response = handler(request)
                        # Handle automatic object conversions
                        if not isinstance(response, Response):
                            if isinstance(response, dict):
                                response = Response(json.dumps(response), 200, "application/json")
                            elif isinstance(response, str):
                                response = Response(response, 200, "text/html")
                            else:
                                response = Response(str(response), 200, "text/html")
                    except Exception as e:
                        import traceback
                        traceback.print_exc()
                        response = Response(f"500 Internal Server Error:\n{str(e)}", 500, "text/plain")
                else:
                    response = Response("404 Not Found", 404, "text/plain")

                # Send HTTP headers
                self.send_response(response.status)
                self.send_header("Content-Type", response.content_type)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                self.send_header("Access-Control-Allow-Headers", "Content-Type")
                
                # Write body bytes
                body_bytes = response.body.encode("utf-8") if isinstance(response.body, str) else response.body
                self.send_header("Content-Length", str(len(body_bytes)))
                self.end_headers()
                self.wfile.write(body_bytes)

            def do_GET(self):
                self.handle_request("GET")

            def do_POST(self):
                self.handle_request("POST")

            def do_OPTIONS(self):
                # Handle CORS preflight options
                self.send_response(200)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                self.send_header("Access-Control-Allow-Headers", "Content-Type")
                self.end_headers()

        server = HTTPServer((host, port), AntiGravityHandler)
        print(f"\n[AntiGravity] Server running at http://{host}:{port}/")
        print("Press Ctrl+C to terminate.")
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down AntiGravity Server gracefully.")
            server.server_close()

    def __call__(self, environ, start_response):
        """WSGI entry point enabling running the application on Vercel or other WSGI servers."""
        method = environ.get("REQUEST_METHOD", "GET").upper()
        path = environ.get("PATH_INFO", "/")
        
        # Get query parameters
        query_string = environ.get("QUERY_STRING", "")
        query_params = urllib.parse.parse_qs(query_string)
        query_params = {k: v[0] if len(v) == 1 else v for k, v in query_params.items()}
        
        # Build headers
        headers = {}
        for key, value in environ.items():
            if key.startswith("HTTP_"):
                header_name = key[5:].replace("_", "-").title()
                headers[header_name] = value
            elif key in ("CONTENT_TYPE", "CONTENT_LENGTH"):
                header_name = key.replace("_", "-").title()
                headers[header_name] = value
                
        # Read request body
        try:
            content_length = int(environ.get("CONTENT_LENGTH", 0) or 0)
        except ValueError:
            content_length = 0
            
        body = ""
        if content_length > 0:
            body_bytes = environ["wsgi.input"].read(content_length)
            body = body_bytes.decode("utf-8")
            
        request = Request(path, method, headers, query_params, body)
        
        route_key = (path, method)
        if route_key in self.routes:
            handler = self.routes[route_key]
            try:
                response = handler(request)
                if not isinstance(response, Response):
                    if isinstance(response, dict):
                        response = Response(json.dumps(response), 200, "application/json")
                    elif isinstance(response, str):
                        response = Response(response, 200, "text/html")
                    else:
                        response = Response(str(response), 200, "text/html")
            except Exception as e:
                import traceback
                traceback.print_exc()
                response = Response(f"500 Internal Server Error:\n{str(e)}", 500, "text/plain")
        else:
            response = Response("404 Not Found", 404, "text/plain")
            
        # Compile response status
        status_text = {
            200: "200 OK",
            201: "201 Created",
            400: "400 Bad Request",
            401: "401 Unauthorized",
            403: "403 Forbidden",
            404: "404 Not Found",
            500: "500 Internal Server Error"
        }.get(response.status, f"{response.status} Status")
        
        body_bytes = response.body.encode("utf-8") if isinstance(response.body, str) else response.body
        
        headers_list = [
            ("Content-Type", response.content_type),
            ("Content-Length", str(len(body_bytes))),
            ("Access-Control-Allow-Origin", "*"),
            ("Access-Control-Allow-Methods", "GET, POST, OPTIONS"),
            ("Access-Control-Allow-Headers", "Content-Type")
        ]
        
        start_response(status_text, headers_list)
        return [body_bytes]


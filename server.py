from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import time

# Server settings
host = "127.0.0.1"
port = 3753

# Data array that holds the responses
data_array = []



# Variable to track which data element to send next
data_index = 0

# ANSI escape codes for colors
RED = "\033[31m"
GREEN = "\033[32m"
RESET = "\033[0m"

# Function to display elements based on their index and value
def display_colored_array(data_array, data_index):
    # Clear previous output
    print("\033[2J\033[H", end="")  # Clear the terminal and move the cursor to the top

    for index, value in enumerate(data_array):
        if index < data_index:
            # Print the index in red if value < index
            print(f"{GREEN}{index + 1}{RESET}", end=" ")
        else:
            # Print the index in green otherwise
            print(f"{RED}{index + 1}{RESET}", end=" ")

    # Show the data_index in the output
    print(f"\n\n")
    # print(f"\n\nCurrent data index: {data_index}")

# Create a request handler
class MyRequestHandler(BaseHTTPRequestHandler):
    global data_index
    
    def do_GET(self):
        global data_index

        # Prepare the next data to be sent from the array
        if data_index < len(data_array):
            response_data = data_array[data_index]
            data_index += 1
            display_colored_array(data_array, data_index)
        else:
            data_index += 1
            response_data = {"message": "All data is done"}
            print(f'All data is sent. Extra connections : ', (data_index - len(data_array)))

            # data_index = 0
            # response_data = data_array[data_index]
        
        # Convert data to JSON
        response_json = json.dumps(response_data)
        
        # Send response status code
        self.send_response(200)
        
        # Specify response headers (JSON content)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        # Write the response data to the client
        self.wfile.write(response_json.encode('utf-8'))


def generate_combinations(input_obj):
    # Get the keys and values from the input object
    keys = list(input_obj.keys())
    values = list(input_obj.values())

    # Initialize the ID counter
    id_counter = 1

    # Recursive function to generate combinations
    def combine(index, current_combination):
        nonlocal id_counter  # To modify the outer variable inside the inner function
        
        # Base case: when the index reaches the end of the keys
        if index == len(keys):
            # Add the current ID to the combination
            current_combination['id'] = id_counter
            result.append(current_combination.copy())
            id_counter += 1  # Increment the ID for the next combination
            return

        # Iterate over all values for the current key
        for value in values[index]:
            current_combination[keys[index]] = value
            combine(index + 1, current_combination)
    
    # List to store all combinations
    result = []

    # Start the recursive combination generation
    combine(0, {})
    
    return result







# Set up the HTTP server
def run_server():
    server_address = (host, port)
    httpd = HTTPServer(server_address, MyRequestHandler)
    print(f"Server running on {host}:{port}")
    httpd.serve_forever()


# Example usage
input_obj = {
    "func": ["F11", "F12", "F13"],
    "pop": [50, 100, 500, 1000],
    "number": [1.52523, 5.27321, 9.17464, 10.2748]
}


if __name__ == "__main__":
    os.system("cls")
    data_array = generate_combinations(input_obj)
    display_colored_array(data_array, data_index)
    run_server()

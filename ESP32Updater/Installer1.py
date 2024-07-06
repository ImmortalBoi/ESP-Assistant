import tkinter as tk
import requests
from tkinter import messagebox
from tkinter import filedialog
from tkinter import scrolledtext
import subprocess
import serial # Try to import serial first
from serial.tools import list_ports
import os
import threading
import queue
import time

def center_window(window):
    window.update_idletasks()
    width = window.winfo_width()
    height = window.winfo_height()
    x = (window.winfo_screenwidth() // 2) - (width // 2)
    y = (window.winfo_screenheight() // 2) - (height // 2)
    window.geometry('{}x{}+{}+{}'.format(width, height, x, y))



def download_file(url, filename):
    """
    Download a file from a given URL and save it locally.
    """

    try:
        response = requests.get(url)
        response.raise_for_status()  # Check if the download was successful
        with open(filename, 'wb') as f:
            f.write(response.content)
        
        success_window = tk.Toplevel()
        success_window.title("Success")
        success_label = tk.Label(success_window, text="File downloaded successfully")
        success_label.pack()
        
        center_window(success_window)
        root.after(3000, success_window.destroy)  # Close the success window after 3 seconds
    except requests.exceptions.RequestException as e:
        error_window = tk.Toplevel()
        error_window.title("Error")
        error_label = tk.Label(error_window, text=f"Failed to download the file: {e}")
        error_label.pack()
        center_window(error_window)

        

def close_error_window(window):
    window.after(3000, window.destroy)
    
def select_port():
    """
    Function to select a COM port for serial communication.

    This function tries to retrieve a list of available COM ports using serial.tools.list_ports.
    If the method is not available, it displays a message indicating the unavailability.
    It then creates a GUI window using tkinter for port selection, displaying a dropdown menu with available ports.
    The user can confirm the selection by clicking a 'Confirm' button.

    If no COM ports are found, it displays an error message in a separate window.

    Returns:
        None
    """
    global selected_port
    ports = []

    try:
        if hasattr(serial.tools, 'list_ports'):
            ports = [str(p) for p in serial.tools.list_ports.comports()]
        else:
            print("serial.tools.list_ports not available in this version of pyserial")
    except Exception as e:
        print(f"Error getting COM ports using serial: {e}")

    if not ports:
        error_window = tk.Toplevel()
        error_window.title("Error: No COM Ports Found")
        error_label = tk.Label(error_window, text="No COM ports found. Please check your connections.")
        error_label.pack(padx=10, pady=10)
        center_window(error_window)
        close_error_window(error_window)
        return

    port_window = tk.Toplevel()
    port_window.title("Select COM Port")

    port_label = tk.Label(port_window, text="Select COM Port:")
    port_label.pack(padx=10, pady=10)

    window_width = port_window.winfo_reqwidth()
    window_height = port_window.winfo_reqheight()
    position_right = int(port_window.winfo_screenwidth() / 2 - window_width / 2)
    position_down = int(port_window.winfo_screenheight() / 2 - window_height / 2)
    port_window.geometry("+{}+{}".format(position_right, position_down))

    selected_port = tk.StringVar(port_window)
    selected_port.set(ports[0])
    port_menu = tk.OptionMenu(port_window, selected_port, *ports)
    port_menu.pack(padx=10, pady=10)

    confirm_button = tk.Button(port_window, text="Upload", command=lambda: (start_flashing_thread(), port_window.destroy()))
    confirm_button.pack(padx=10, pady=10)
def flash_device(output_queue):
    
    download_file(f"https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/{username}/init/testing.ino.bin", 'init.bin')

    port_name = selected_port.get().split()[0] # Extract only the port name (e.g., COM3) from the full string
    current_directory = os.getcwd()
    filelocation = os.path.join(current_directory , "init.bin" )
    print("Current Directory:", filelocation)  
    cmd = ['esptool', '--port', port_name, 'write_flash', '-fm', "dio", "0x10000", filelocation]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            output_queue.put(output.strip())  # You might want to update a GUI element here
            print(output.strip())  # You might want to update a GUI element here
    if process.poll() != 0:
        print("Flashing failed with exit code", process.returncode)
        output_queue.put("Error", "Flashing failed with exit code {}".format(process.returncode))
    else:
        print("Flashing completed successfully!")
        output_queue.put("Success", "Flashing completed successfully!")
        messagebox.showinfo("Success", "Flashing completed successfully!")
        
def start_flashing_thread():
    global output_queue
    flashing_window = tk.Toplevel()
    flashing_window.title("Flasher Progress")
    
    output_text = scrolledtext.ScrolledText(flashing_window, state='disabled', height=10)
    output_text.pack(pady=20)

    output_queue = queue.Queue()
    flashing_window.after(1000, update_output_text, flashing_window, output_queue, output_text)  # Start periodic check of output queue
    
    threading.Thread(target=flash_device, args=(output_queue,)).start()
    flashing_window.destroy()

def update_output_text(flashing_window, output_queue, output_text):
    while not output_queue.empty():
        item = output_queue.get()
        output_text.insert(tk.END, item + '\n')
        output_text.see(tk.END)  # Scroll to the bottom
        time.sleep(0.1)  # Introduce a delay of 100ms between each insertion
    flashing_window.after(100, update_output_text, flashing_window, output_queue, output_text)  # Schedule to run again after 100ms
def login():
    # This is where you would add your verification logic
    global username
    username = username_entry.get()
    password = password_entry.get()
    print(f"Username: {username}, Password: {password}")
    response = requests.get(f"http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/{username}/{password}")
    if response.status_code == 200:
        # Convert the response to a dictionary
        data = response.json()
        ESPData = data["ESP_cert"]["Thing_name"]
        print(ESPData)
        select_port()
    else:
        messagebox.showerror("Error", "Invalid credentials")
        print(f"Failed to retrieve data. Status code: {response.status_code: {response.status_code}}")

def main_window():
    # Create the main window
    global root , username_entry, password_entry
    root = tk.Tk()
    root.title("ESPA Login Window")

    # Set the window size
    root.geometry("400x160")  # Width x Height

    # Configure the grid
    root.columnconfigure(0, weight=1)
    root.columnconfigure(1, weight=3)

    # Add a title label
    title_label = tk.Label(root, text="ESP Assist Log in", font=("Arial", 16))
    title_label.grid(column=0, row=0, columnspan=2, sticky=tk.N, pady=10)

    # Adjust the starting row for username and password to leave space for the title
    # Username label and entry field
    username_label = tk.Label(root, text="Username:")
    username_label.grid(column=0, row=1, sticky=tk.W, padx=5, pady=5)

    username_entry = tk.Entry(root)
    username_entry.grid(column=1, row=1, sticky=tk.EW, padx=5, pady=5)

    # Password label and entry field
    password_label = tk.Label(root, text="Password:")
    password_label.grid(column=0, row=2, sticky=tk.W, padx=5, pady=5)

    password_entry = tk.Entry(root, show="*")
    password_entry.grid(column=1, row=2, sticky=tk.EW, padx=5, pady=5)

    # Login button
    login_button = tk.Button(root, text="Login", command = login)
    login_button.grid(column=0, row=3, columnspan=2, sticky=tk.EW, padx=5, pady=20)
     # Get the screen width and height
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()

    # Calculate the x and y positions for the Tk root window
    x = (screen_width / 2) - (400 / 2)  # 400 is the width of the window
    y = (screen_height / 2) - (160 / 2)  # 160 is the height of the window

    # Set the position of the window
    root.geometry(f"400x160+{int(x)}+{int(y)}")

    root.mainloop()
    
if __name__ == "__main__":  
    main_window()
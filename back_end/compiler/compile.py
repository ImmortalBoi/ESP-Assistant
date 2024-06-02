import datetime
import os
import subprocess
import sys
import yaml

class Log:
    log = ""
    def addLog(self, string):
        self.log += string

def compile_sketch(spec):
    sketch = None
    board = None
    log = Log()

    if "sketch" not in spec:
        print("Sketch file not specified, unable to compile", flush=True)
        log.addLog( "Sketch file not specified, unable to compile\n")
        return log.log,False
    else:
        sketch = spec["sketch"]

    if "target" not in spec:
        print("Compilation target not specified, unable to compile", flush=True)
        log.addLog( "Compilation target not specified, unable to compile\n")
        return log.log, False

    else:
        if "board" not in spec["target"]:
            print("Target board type not specified, unable to compile", flush=True)
            log.addLog( "Target board type not specified, unable to compile\n")
            return log.log,False

        else:
            board = spec["target"]["board"]
            print(f"Compiling {sketch} for board type {board}", flush=True)
            log.addLog( f"Compiling {sketch} for board type {board}\n")

        if "url" in spec["target"]:
            print(f"""Adding board manager {spec["target"]["url"]}""", flush=True)
            log.addLog( f"""Adding board manager {spec["target"]["url"]}""")
            _add_arduino_core_package_index(spec["target"]["url"],log)

        if "core" in spec["target"]:
            (core_name, core_version) = _parse_version(spec["target"]["core"])
            core_name_version = f"{core_name} v{core_version}" \
                if core_version is not None else f"{core_name} (latest)"
            print(f"Installing core {core_name_version}... ", end="" , flush=True)
            log.addLog( f"Installing core {core_name_version}... ")

            success = _install_arduino_core(core_name, core_version,log=log)
            print("Done!" if success else "Failed!", flush=True)
            log.addLog( "Done!" if success else "Failed!" + "\n")
            if not success:
                log.addLog( "Core installation failed\n")
                return log.log, False

    if "libraries" in spec:
        for lib in spec["libraries"]:
            (lib_name, lib_version) = _parse_version(lib)
            lib_name_version = f"{lib_name} v{lib_version}" \
                if lib_version is not None else f"{lib_name} (latest)"

            print(f"Installing library {lib_name_version}... ", end="", flush=True)
            log.addLog( f"Installing library {lib_name_version}... ")
            success = _install_arduino_lib(lib_name, lib_version,log=log)
            print("Done!" if success else "Failed!", flush=True)
            log.addLog( "Done!" if success else "Failed!" + "\n")

            if not success:
                log.addLog( "Library installation failed\n")
                return log.log, False

    output_path = spec["output_path"]

    print(f"Sketch {sketch} will be compiled to {output_path}...", flush=True)
    log.addLog( f"Sketch {sketch} will be compiled to {output_path}...\n")

    success = _compile_arduino_sketch(sketch, board, output_path,log=log)
    print("Compilation completed!" if success else "Compilation failed!")
    log.addLog( "Compilation completed!" if success else "Compilation failed!" + "\n")

    return log.log, success


def _parse_version(line):
    if "==" in line:
        (name, version) = line.split("==", 1)
    else:
        (name, version) = (line.strip(), None)
    return (name, version)


def _add_arduino_core_package_index(url, log):
    return _run_shell_command(["arduino-cli", "core", "update-index",
                                "--additional-urls", url], log=log)


def _install_arduino_core(name, version=None, log=Log()):
    core = f"{name}@{version}" if version is not None else name
    return _run_shell_command(["arduino-cli", "core", "install", core], log=log)


def _install_arduino_lib(name, version=None, log=Log()):
    lib = f"{name}@{version}" if version is not None else name
    return _run_shell_command(["arduino-cli", "lib", "install", lib], log=log)


def _compile_arduino_sketch(sketch_path, board, output_path, log=Log()):
    os.makedirs("dist/", exist_ok=True)
    
    return _run_shell_command(["arduino-cli", "compile",
                                "-b", board,
                                "--output-dir", output_path, sketch_path], stdout=True, log=log)


def _run_shell_command(arguments, stdout=False, stderr=True, log=Log()):
    process = subprocess.run(arguments, check=False, capture_output=True)
    if stdout and len(process.stdout) > 0:
        print("> %s" % process.stdout.decode("utf-8"), flush=True)
        log.addLog("> %s" % process.stdout.decode("utf-8"))
    if stderr and len(process.stderr) > 0:
        print("ERROR > %s" % process.stderr.decode("utf-8"), flush=True)
        log.addLog("ERROR > %s" % process.stderr.decode("utf-8"))
    return (process.returncode == 0)
# TODO THIS IS WHERE THE ERROR GETS RETURNED

if __name__ == "__main__":
    # Run ls -r using subprocess.run (recommended for Python 3.5+)\
    subprocess.run(['pwd'])

    print("--------")
    result = subprocess.run(['ls'])
    # Check the return code (0 for success)
    print("--------")

        
    try:
        f = open("project.yaml", "r")
        spec = yaml.safe_load(f)
        compile_sketch(spec)
        sys.exit(0)
    except IOError as e:
        print("Specification file project.yaml not found")
        sys.exit(1)
    except yaml.YAMLError as e:
        print("Something wrong with the syntax of project.yaml: %s" % e)
        sys.exit(1)

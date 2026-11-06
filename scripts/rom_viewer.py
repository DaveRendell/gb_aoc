import argparse

rom_filepath = "dist/output.gb"
map_filepath = "dist/output.map"

parser = argparse.ArgumentParser(
    prog="rom_viewer",
    description="Check regions of memory in a gameboy rom with matching map file",
)

parser.add_argument("label")

args = parser.parse_args()

rom_file = open(rom_filepath, "rb")
map_file = open(map_filepath, "r")

label_lines = [line for line in map_file.read().splitlines() if args.label in line]
label_line = label_lines[0] if label_lines else None

if not label_line:
    print("Label not found")
    exit()

label_address = int(label_line.strip().split(" = ")[0][1:], 16)
print(f"{args.label}: {hex(label_address)[2:].upper().rjust(4, '0')}")
print(" ".join([hex(byte)[2:].upper().rjust(2, '0') for byte in rom_file.read()[label_address:label_address+16]]))
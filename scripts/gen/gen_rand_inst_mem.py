"""
This script fills the file <output_file> (passed as an command line arg) with
INST_MEM_DEPTH lines of random 32bit hex values.

Random values are generated with the following weights:
    0000_0000:   weight 1
    ffff_ffff:   weight 1
    full_random: weight 10

Note: If <output_file> doesnt exist this script will create it.

WARNING: If <output_file> does exist this script will overwrite it.
"""
import sys
import random

INST_MEM_DEPTH = 256
INST_MEM_WIDTH = 32
MAX_HEX_VAL = 2**INST_MEM_WIDTH - 1

def gen_rand():
    #get a random category and gen the appropriate value
    cats = ["all_zeros", "all_ones", "full_rand"]
    weights = [1,1, 10]
    cat = random.choices(cats, weights=weights, k = 1)[0]

    match cat:
        case "all_zeros":
            return 0
        case "all_ones":
            return MAX_HEX_VAL
        case "full_rand":
            return random.randint(0, MAX_HEX_VAL)
        case _:
            return 0x00001111

######################### SCRIPT START #########################

if len(sys.argv) != 2:
    print("ERROR: Usage: gen_rand_inst_mem.py <output_file>")
    sys.exit(1)

#open the file
#if it doesnt exist create it
#if it does this line will clear the old data and let us write new stuff
fd = open(sys.argv[1], 'w')

#loop, generate a rand hex, and write to the file
for x in range(INST_MEM_DEPTH):
    value = gen_rand()
    fd.write(f"{value:08x}\n")

fd.close()

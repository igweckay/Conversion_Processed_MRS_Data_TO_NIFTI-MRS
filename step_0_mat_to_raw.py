import sys
import scipy.io
import numpy as np

mat_file = sys.argv[1]
raw_file = sys.argv[2]

# you can use these two lines instead of the top 2 lines to run on a single file within the script
# mat_file = "/path/to/metabolite/file/VAPOR_7_Occipital_Metab.mat"
# raw_file = "/path/to/metabolite/water/file/VAPOR_7_Occipital_Metab.raw"


mat = scipy.io.loadmat(mat_file, squeeze_me=True, struct_as_record=False)
exptDat = mat["exptDat"]

fid = np.asarray(exptDat.fid).ravel()
sf = float(exptDat.sf) / 1e6
sw_h = float(exptDat.sw_h)
dwell = 1.0 / sw_h

# Flip imaginary sign to match the original LCModel .RAW convention
vals = []
for z in fid:
    vals.extend([z.real, -z.imag])

with open(raw_file, "w") as f:
    f.write(" $SEQPAR\n")
    f.write(f" HZPPPM= {sf:.6f}\n")
    f.write(f" NUNFIL= {fid.size}\n")
    f.write(f" DELTAT= {dwell:.12f}\n")
    f.write(" $END\n")
    f.write(" $NMID\n")
    f.write(" ID='MAT converted FID'\n")
    f.write(" FMTDAT='(8E13.5)'\n")
    f.write(" VOLUME=   1.00000E+00\n")
    f.write(" TRAMP=    1.00000E+00\n")
    f.write(" $END\n")

    for i in range(0, len(vals), 8):
        line_vals = vals[i:i+8]
        f.write(" ".join(f"{v:+.5E}" for v in line_vals) + "\n")
import glob, re, zipfile
from pathlib import Path

qsf = glob.glob('*.qsf')[0]
print(f"Opening {qsf}")
with open(qsf) as f:
    lines = f.readlines()

v_files = [line.split()[-1] for line in lines if 'VERILOG_FILE' in line]
exclude = ['imem.v', 'dmem.v'] + [f for f in v_files if '_tb.v' in f]
print(f"Excluding:")
for f in exclude:
    print(f"  {f}")
files_to_zip = [f for f in v_files if f not in exclude] + ['README.md']
print(f"Packing:")
for f in files_to_zip:
    print(f"  {f}")

output_file = "Submission.zip"
print(f"Creating {output_file}")
with zipfile.ZipFile(output_file, 'w') as z:
    for f in files_to_zip :
        if Path(f).exists():
            z.write(f)

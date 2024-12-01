@echo off
echo === Compress images by reducing color ===
python reduce_256_colors.py
echo === Generate color palette and pixel data MIFs ===
python imgs2mif.py
pause
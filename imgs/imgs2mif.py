import os
import math
from PIL import Image

def generate_mif_content(data_list, width, comments=None):
    actual_depth = len(data_list)
    address_width = math.ceil(math.log2(actual_depth + 1))
    required_depth = 2 ** address_width
    
    mif_lines = []
    if comments:
        for comment in comments:
            mif_lines.append(f"-- {comment}")
    mif_lines.append(f"-- Address bus is {address_width} bits")
    mif_lines.extend([
        f"DEPTH = {required_depth};",
        f"WIDTH = {width};",
        "",
        "ADDRESS_RADIX = DEC;",
        "DATA_RADIX = BIN;",
        "",
        "CONTENT",
        "BEGIN"
    ])
    for i, value in enumerate(data_list):
        binary = format(value, f'0{width}b')
        mif_lines.append(f"{i} : {binary};")
    if actual_depth < required_depth:
        mif_lines.append(f"[{actual_depth}..{required_depth - 1}] : 0;")
    mif_lines.append("END;")
    return "\n".join(mif_lines)


def process_images(input_folder, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # First color is hardcoded as transparent
    all_colors = { 0: 0 }
    color_index = 1
    image_pixel_maps = {}
    image_info = {}

    for filename in os.listdir(input_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
            image_path = os.path.join(input_folder, filename)
            print(f"Processing {image_path}...")
            img = Image.open(image_path)
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            pixels = img.load()
            width, height = img.size
            image_info[filename] = (width, height)
            pixel_map = []
            for y in range(height):
                for x in range(width):
                    rgb = pixels[x, y][0] << 16 | pixels[x, y][1] << 8 | pixels[x, y][2]
                    if pixels[x, y][3] == 0xFF:
                        # Only consider fully opaque pixels
                        if rgb not in all_colors:
                            all_colors[rgb] = color_index
                            color_index += 1
                        pixel_map.append(all_colors[rgb])
                    else:
                        pixel_map.append(0)
            image_pixel_maps[filename] = pixel_map

    color_map_path = os.path.join(output_folder, "color_map.mif")
    with open(color_map_path, 'w') as f:
        mif_content = generate_mif_content(
            all_colors.keys(),
            width=24,
            comments=["Color Map"]
        )
        f.write(mif_content)

    for filename, pixel_map in image_pixel_maps.items():
        output_filename = os.path.splitext(filename)[0] + "_pixelmap.mif"
        output_path = os.path.join(output_folder, output_filename)
        width, height = image_info[filename]
        with open(output_path, 'w') as f:
            mif_content = generate_mif_content(
                pixel_map,
                width=16,
                comments=[
                    f"Image: {filename}",
                    f"Size: {width}x{height} pixels"
                ]
            )
            f.write(mif_content)
            
    return len(all_colors)

if __name__ == "__main__":
    total_colors = process_images("./", "./")
    print(f"Processing complete. Found {total_colors} unique colors.")

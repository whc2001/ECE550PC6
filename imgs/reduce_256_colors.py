from PIL import Image
import numpy as np
from sklearn.cluster import KMeans
from pathlib import Path
from scipy.spatial import cKDTree

KMEANS_SEED = 114514


def load_image_nontransparent(image_path):
    img = Image.open(image_path)
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    img_array = np.array(img)
    alpha = img_array[:, :, 3]
    opaque_mask = alpha == 255  # Only consider fully opaque pixels
    pixels = img_array[opaque_mask][:, :3]
    return pixels


def create_color_palette(pixels, n_colors=256):
    # Creare palette using K-means clustering
    unique_colors, unique_counts = np.unique(pixels, axis=0, return_counts=True)
    km = KMeans(n_clusters=n_colors, random_state=KMEANS_SEED)
    km.fit(unique_colors, sample_weight=unique_counts)
    palette = km.cluster_centers_.astype(np.uint8)
    palette = np.unique(palette, axis=0)

    # More colors might be needed due to duplications
    i = 0
    while len(palette) < n_colors:
        i += 1
        additional_colors_needed = n_colors - len(palette)
        km = KMeans(
            n_clusters=additional_colors_needed, random_state=(KMEANS_SEED * 33 + i)
        )
        tree = cKDTree(palette)
        far_pixels = pixels[
            np.argsort(-(tree.query(pixels)[0]))[:1000]
        ]  # Take top 1000 furthest pixels
        km.fit(far_pixels)
        additional_palette = km.cluster_centers_.astype(np.uint8)
        palette = np.unique(np.vstack([palette, additional_palette]), axis=0)
        if i > 10:
            break

    return palette


def process_images(input_folder, output_folder, n_colors=256):
    Path(output_folder).mkdir(parents=True, exist_ok=True)

    print(f"Collecting pixels from {input_folder}")
    image_files = []
    for ext in ["*.png", "*.jpg", "*.jpeg", "*.bmp"]:
        image_files.extend(Path(input_folder).glob(ext))
    all_pixels = []
    for img_path in image_files:
        rgb_pixels = load_image_nontransparent(img_path)
        if len(rgb_pixels) > 0:
            rgb_pixels = np.round(rgb_pixels / 4) * 4
            all_pixels.append(rgb_pixels)
    all_pixels = np.vstack(all_pixels)

    print(f"Creating color palette of {n_colors} colors")
    palette = create_color_palette(all_pixels, n_colors)
    # luminance = np.sum(
    #     palette * np.array([0.299, 0.587, 0.114]), axis=1
    # )  # Sort palette by luminance
    # palette = palette[np.argsort(luminance)]
    palette_tree = cKDTree(palette)  # Create KDTree for fast color mapping

    for img_path in image_files:
        img = Image.open(img_path)
        if img.mode != "RGBA":
            img = img.convert("RGBA")
        img_array = np.array(img)
        alpha = img_array[:, :, 3]
        opaque_mask = alpha == 255
        output_array = img_array.copy()
        if np.any(opaque_mask):
            opaque_pixels = img_array[opaque_mask][:, :3]
            opaque_pixels = np.round(opaque_pixels / 4) * 4
            mapped_colors = palette[palette_tree.query(opaque_pixels)[1]]
            output_array[opaque_mask, :3] = mapped_colors
        new_img = Image.fromarray(output_array)
        output_path = Path(output_folder) / img_path.name
        new_img.save(output_path)
        print(f"Processed: {img_path.name}")

    return palette


if __name__ == "__main__":
    p = process_images(
        "./original", "./reduced", 63
    )  # Leave one for hardcoded transparent placeholder
    print(" ".join([f"{color[0]:02X}{color[1]:02X}{color[2]:02X}" for color in p]))

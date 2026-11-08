"""Turn a flat folder of photos into the class folders the trainer expects.

    python training_processor.py -i training_images

Photo file names must end in `_<number>.<ext>`, e.g. `photo_17.jpg`. Every 10
consecutive numbers form one class (one place): numbers 1-10 go to class
folder `1`, 11-20 to `2`, and so on.
Images are converted (default: grayscale), resized (default: 512x512) and
written to `training_input_folder/<class>/<file name>`.
"""

import os
from argparse import ArgumentParser

import cv2
from imutils.paths import list_images

IMAGE_TYPES = ["original", "gray", "black_and_white"]
OUTPUT_FOLDER = "training_input_folder"


def class_for(path):
    """Class folder number for a file named `<anything>_<n>.<ext>`."""
    number = int(os.path.basename(path).rsplit("_", 1)[-1].split(".")[0])
    return -(-number // 10)  # ceil(number / 10)


def process_image(src_folder="training_images", image_type="original", size=(512, 512)):
    if image_type not in IMAGE_TYPES:
        raise ValueError(f"image_type must be one of {IMAGE_TYPES}")

    print("[INFO] Processing images...")
    image_paths = sorted(list_images(src_folder))
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)
    for path in image_paths:
        img = cv2.imread(path)
        if image_type in ["gray", "black_and_white"]:
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        if image_type == "black_and_white":
            _, img = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
        if size:
            height, width = size
            img = cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)

        des_folder = os.path.join(OUTPUT_FOLDER, str(class_for(path)))
        os.makedirs(des_folder, exist_ok=True)
        file_name = os.path.basename(path)
        if not cv2.imwrite(
            os.path.join(des_folder, file_name), img, [cv2.IMWRITE_JPEG_QUALITY, 100]
        ):
            raise RuntimeError(f"Could not write {file_name}")


def main():
    ap = ArgumentParser(description=__doc__)
    ap.add_argument("-i", "--input", required=True, help="Folder of source photos")
    ap.add_argument(
        "--type",
        default="gray",
        choices=IMAGE_TYPES,
        help="Color conversion (default: gray, which is what the model expects)",
    )
    ap.add_argument(
        "--size",
        type=int,
        default=512,
        help="Output width and height in pixels (default: 512, matches helper/config.py)",
    )
    args = ap.parse_args()
    process_image(src_folder=args.input, image_type=args.type, size=(args.size, args.size))


if __name__ == "__main__":
    main()

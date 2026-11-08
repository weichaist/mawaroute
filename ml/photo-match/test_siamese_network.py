"""Show the model's similarity score for 10 random pairs of test images.

    python test_siamese_network.py --input testing_input_folder

Loads the model trained by train_siamese_network.py and opens one matplotlib
window per pair.
"""

from argparse import ArgumentParser

import cv2
import keras
import matplotlib.pyplot as plt
import numpy as np
from imutils.paths import list_images

from helper import config
from helper import utils  # noqa: F401  (registers DistanceLayer for loading)


def image_process(path):
    """Load an image as grayscale and shape it for the network."""
    image_dim = (config.IMG_SHAPE[1], config.IMG_SHAPE[0])  # cv2 wants (w, h)
    image = cv2.imread(path, 0)
    orig = image.copy()
    image = cv2.resize(image, image_dim, interpolation=cv2.INTER_AREA)
    image = image / 255.0
    image = np.expand_dims(image, axis=-1)  # channel dimension
    image = np.expand_dims(image, axis=0)  # batch dimension
    return image, orig


def plot(image_a, image_b, plot_index, proba):
    fig = plt.figure("Pair #{}".format(plot_index + 1), figsize=(8, 4))
    plt.suptitle("Similarity: {:.2f}".format(proba))
    for i, image in enumerate([image_a, image_b]):
        fig.add_subplot(1, 2, i + 1)
        plt.imshow(image, cmap=plt.cm.gray, aspect="auto")
        plt.axis("off")
    plt.show()


def main():
    ap = ArgumentParser(description=__doc__)
    ap.add_argument(
        "-i", "--input", required=True, help="Directory of testing images"
    )
    args = ap.parse_args()

    print("[INFO] loading test dataset...")
    test_image_paths = list(list_images(args.input))
    np.random.seed(42)
    pairs = np.random.choice(test_image_paths, size=(10, 2))

    print("[INFO] loading siamese model...")
    model = keras.models.load_model(config.MODEL_PATH)

    for i, (path_a, path_b) in enumerate(pairs):
        image_a, orig_a = image_process(path_a)
        image_b, orig_b = image_process(path_b)
        prediction = model.predict([image_a, image_b])
        plot(orig_a, orig_b, i, prediction[0][0])


if __name__ == "__main__":
    main()

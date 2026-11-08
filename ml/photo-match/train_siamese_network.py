"""Train the siamese network on folders of images, one folder per place.

    python train_siamese_network.py --input training_input_folder

Writes the model, and a plot of the training history, to helper/config.py's
BASE_OUTPUT folder.
"""

import gc
import os
from argparse import ArgumentParser

# Let TensorFlow grow GPU memory as needed instead of reserving all of it.
os.environ.setdefault("TF_FORCE_GPU_ALLOW_GROWTH", "true")

import keras  # noqa: E402
import numpy as np  # noqa: E402
import tensorflow as tf  # noqa: E402
from keras.callbacks import Callback  # noqa: E402
from keras.layers import Dense, Input  # noqa: E402
from keras.models import Model  # noqa: E402

from helper import config, siamese_network, utils  # noqa: E402
from helper.dataset import image_datasets_with_paths  # noqa: E402


class ClearMemory(Callback):
    def on_epoch_end(self, epoch, logs=None):
        gc.collect()
        keras.backend.clear_session()


def generate_pair_data(dataset, all_paths, all_labels):
    """Endlessly yield ([image_a, image_b], same_class) batches."""
    for image, _label, file_paths in dataset.repeat():
        pairs, pair_labels = utils.make_batch_pairs(
            all_paths, all_labels, file_paths, image
        )
        yield (pairs[:, 0], pairs[:, 1]), pair_labels.astype(np.int8)


def main():
    ap = ArgumentParser(description=__doc__)
    ap.add_argument(
        "-i",
        "--input",
        required=True,
        help="Directory of training images (one sub-folder per class, see training_processor.py)",
    )
    args = ap.parse_args()

    gpus = tf.config.list_physical_devices("GPU")
    print(f"[INFO] {len(gpus)} GPU(s) available")

    print("[INFO] loading dataset...")
    train_ds, val_ds = image_datasets_with_paths(
        args.input,
        validation_split=0.2,
        seed=42,
        color_mode="grayscale",
        image_size=(config.IMG_SHAPE[0], config.IMG_SHAPE[1]),
        batch_size=config.BATCH_SIZE,
    )

    all_paths = np.array(train_ds.file_paths + val_ds.file_paths)
    all_labels = np.array([utils.class_of(p) for p in all_paths], dtype=int)

    print("[INFO] building siamese network...")
    img_a = Input(shape=config.IMG_SHAPE)
    img_b = Input(shape=config.IMG_SHAPE)
    feature_extractor = siamese_network.build_siamese_model(config.IMG_SHAPE)
    feats_a = feature_extractor(img_a)
    feats_b = feature_extractor(img_b)
    distance = utils.DistanceLayer()([feats_a, feats_b])
    outputs = Dense(1, activation="sigmoid")(distance)
    model = Model(inputs=[img_a, img_b], outputs=outputs)

    print("[INFO] compiling model...")
    model.compile(loss="binary_crossentropy", optimizer="adam", metrics=["accuracy"])

    print("[INFO] training model...")
    history = model.fit(
        x=generate_pair_data(train_ds, all_paths, all_labels),
        validation_data=generate_pair_data(val_ds, all_paths, all_labels),
        epochs=config.EPOCHS,
        steps_per_epoch=len(train_ds),
        validation_steps=len(val_ds),
        callbacks=[ClearMemory()],
        verbose=1,
    )

    os.makedirs(config.BASE_OUTPUT, exist_ok=True)
    print(f"[INFO] saving siamese model to {config.MODEL_PATH}...")
    model.save(config.MODEL_PATH)
    print(f"[INFO] plotting training history to {config.PLOT_PATH}...")
    utils.plot_training(history, config.PLOT_PATH)


if __name__ == "__main__":
    main()

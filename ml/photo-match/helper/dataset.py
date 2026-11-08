"""Image dataset loading that also yields each image's file path.

The training script needs the path of every image in a batch (the class is
the name of the image's parent folder), which
`keras.utils.image_dataset_from_directory` does not return. This module builds
the same kind of `tf.data.Dataset`, yielding `(image, label, path)`.
"""

import os

import numpy as np
import tensorflow as tf

ALLOWED_EXTENSIONS = (".bmp", ".gif", ".jpeg", ".jpg", ".png")
CHANNELS = {"grayscale": 1, "rgb": 3, "rgba": 4}


def list_image_files(directory):
    """Return (paths, labels, class_names) for `directory/<class>/<image>`.

    Labels are indexes into the alphabetically sorted class folder names.
    """
    class_names = sorted(
        name
        for name in os.listdir(directory)
        if os.path.isdir(os.path.join(directory, name))
    )
    paths, labels = [], []
    for index, class_name in enumerate(class_names):
        class_dir = os.path.join(directory, class_name)
        for root, _, files in os.walk(class_dir):
            for file_name in sorted(files):
                if file_name.lower().endswith(ALLOWED_EXTENSIONS):
                    paths.append(os.path.join(root, file_name))
                    labels.append(index)
    return paths, labels, class_names


def load_image(path, image_size, num_channels, interpolation="bilinear"):
    """Read, decode and resize one image to `image_size` (height, width)."""
    img = tf.io.read_file(path)
    img = tf.image.decode_image(img, channels=num_channels, expand_animations=False)
    img = tf.image.resize(img, image_size, method=interpolation)
    img.set_shape((image_size[0], image_size[1], num_channels))
    return img


def _to_dataset(paths, labels, image_size, num_channels, batch_size, shuffle, seed):
    path_ds = tf.data.Dataset.from_tensor_slices(paths)
    img_ds = path_ds.map(
        lambda p: load_image(p, image_size, num_channels),
        num_parallel_calls=tf.data.AUTOTUNE,
    )
    label_ds = tf.data.Dataset.from_tensor_slices(np.array(labels, dtype="int32"))
    ds = tf.data.Dataset.zip((img_ds, label_ds, path_ds)).prefetch(tf.data.AUTOTUNE)
    if shuffle:
        ds = ds.shuffle(buffer_size=batch_size * 8, seed=seed)
    return ds.batch(batch_size)


def image_datasets_with_paths(
    directory,
    validation_split=0.2,
    seed=42,
    color_mode="grayscale",
    image_size=(256, 256),
    batch_size=32,
):
    """Split the images under `directory` into training and validation sets.

    Returns `(train_ds, val_ds)`. Each yields batches of `(images, labels,
    paths)` and has `class_names` and `file_paths` attributes.
    """
    if color_mode not in CHANNELS:
        raise ValueError(f"color_mode must be one of {sorted(CHANNELS)}")
    paths, labels, class_names = list_image_files(directory)
    if not paths:
        raise ValueError(f"No images found in {directory}")

    order = np.random.RandomState(seed).permutation(len(paths))
    paths = [paths[i] for i in order]
    labels = [labels[i] for i in order]
    num_val = int(validation_split * len(paths))
    split = len(paths) - num_val
    train_paths, val_paths = paths[:split], paths[split:]
    train_labels, val_labels = labels[:split], labels[split:]
    if not train_paths or not val_paths:
        raise ValueError("Not enough images for a training/validation split")

    num_channels = CHANNELS[color_mode]
    train_ds = _to_dataset(
        train_paths, train_labels, image_size, num_channels, batch_size, True, seed
    )
    val_ds = _to_dataset(
        val_paths, val_labels, image_size, num_channels, batch_size, False, seed
    )
    for ds, ds_paths in ((train_ds, train_paths), (val_ds, val_paths)):
        ds.class_names = class_names
        ds.file_paths = ds_paths
    return train_ds, val_ds

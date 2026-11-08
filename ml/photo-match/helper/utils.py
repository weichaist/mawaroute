import os

import keras
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

from helper import config
from helper.dataset import load_image


def class_of(path):
    """The class label of an image: the name of its parent folder (an int)."""
    return int(os.path.basename(os.path.dirname(path)))


def preprocess_image(image):
    """Scale a decoded image tensor to float32 values in [0, 1]."""
    image = image / 255.0
    return image.numpy().astype(np.float32)


def make_batch_pairs(images, labels, batch_image_paths, batch_images):
    """Build one positive and one negative pair for every image in a batch.

    `images` / `labels` are the paths and integer classes of the whole dataset;
    the partner images are loaded from disk. Returns `(pairs, pair_labels)`
    where `pairs[:, 0]` / `pairs[:, 1]` are the two inputs and the label is 1
    for "same place" and 0 otherwise.
    """
    image_size = (config.IMG_SHAPE[0], config.IMG_SHAPE[1])
    pair_images = []
    pair_labels = []
    batch_image_paths = np.array(batch_image_paths.numpy(), dtype=str)

    for idx_a in range(len(batch_image_paths)):
        current_image = preprocess_image(batch_images[idx_a])
        current_image_path = batch_image_paths[idx_a]
        label = class_of(current_image_path)

        # a different image of the same class
        pos_images = images[np.where(labels == label)[0]]
        pos_idx = np.where(pos_images != current_image_path)[0]
        pos_image_path = pos_images[np.random.choice(pos_idx)]
        pos_image = preprocess_image(load_image(pos_image_path, image_size, 1))
        pair_images.append([current_image, pos_image])
        pair_labels.append([1])

        # an image of any other class
        neg_idx = np.where(labels != label)[0]
        neg_image_path = images[np.random.choice(neg_idx)]
        neg_image = preprocess_image(load_image(neg_image_path, image_size, 1))
        pair_images.append([current_image, neg_image])
        pair_labels.append([0])

    return np.array(pair_images), np.array(pair_labels)


@keras.saving.register_keras_serializable(package="photo_match")
class DistanceLayer(keras.layers.Layer):
    """Euclidean distance between two embedding vectors."""

    def call(self, vectors):
        feats_a, feats_b = vectors
        sum_squared = tf.reduce_sum(tf.square(feats_a - feats_b), axis=1, keepdims=True)
        return tf.sqrt(tf.maximum(sum_squared, keras.backend.epsilon()))


def plot_training(history, plot_path):
    """Save loss/accuracy curves of a training run to `plot_path`."""
    plt.style.use("ggplot")
    plt.figure()
    plt.plot(history.history["loss"], label="train_loss")
    plt.plot(history.history["val_loss"], label="val_loss")
    plt.plot(history.history["accuracy"], label="train_acc")
    plt.plot(history.history["val_accuracy"], label="val_acc")
    plt.title("Training Loss and Accuracy")
    plt.xlabel("Epoch #")
    plt.ylabel("Loss/Accuracy")
    plt.legend(loc="lower left")
    plt.savefig(plot_path)

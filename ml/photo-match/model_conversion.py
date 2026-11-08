"""Convert the trained Keras model to TensorFlow Lite.

    python model_conversion.py

Reads helper/config.py's MODEL_PATH and writes TF_LITE_MODEL_PATH.
"""

from pathlib import Path

import keras
import tensorflow as tf

from helper import config
from helper import utils  # noqa: F401  (registers DistanceLayer for loading)


def main():
    print(f"[INFO] loading model from {config.MODEL_PATH}...")
    model = keras.models.load_model(config.MODEL_PATH)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    Path(config.TF_LITE_MODEL_PATH).write_bytes(tflite_model)
    print(f"[INFO] wrote {config.TF_LITE_MODEL_PATH}")


if __name__ == "__main__":
    main()

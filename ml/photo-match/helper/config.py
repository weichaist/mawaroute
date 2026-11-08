import os

# Shape of the network inputs (height, width, channels). Images are grayscale.
IMG_SHAPE = (512, 512, 1)
# Batch size and number of epochs for training.
BATCH_SIZE = 4
EPOCHS = 100

# Everything the scripts write goes under this folder (gitignored).
BASE_OUTPUT = "mawaroute_output"
# Trained Keras model (Keras 3 native format).
MODEL_PATH = os.path.join(BASE_OUTPUT, "siamese_model.keras")
# TensorFlow Lite export for on-device use.
TF_LITE_MODEL_PATH = os.path.join(BASE_OUTPUT, "tf_lite_model.tflite")
# Training history plot.
PLOT_PATH = os.path.join(BASE_OUTPUT, "plot.png")

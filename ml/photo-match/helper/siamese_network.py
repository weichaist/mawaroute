from keras.layers import Conv2D, Dense, Dropout, GlobalAveragePooling2D, Input, MaxPooling2D
from keras.models import Model


def build_siamese_model(input_shape, embedding_dim=48):
    """Feature extractor shared by both branches of the siamese network."""
    inputs = Input(input_shape)
    # first set of CONV => RELU => POOL => DROPOUT layers
    x = Conv2D(64, (2, 2), padding="same", activation="relu")(inputs)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Dropout(0.3)(x)
    # second set of CONV => RELU => POOL => DROPOUT layers
    x = Conv2D(64, (2, 2), padding="same", activation="relu")(x)
    x = MaxPooling2D(pool_size=2)(x)
    x = Dropout(0.3)(x)

    pooled_output = GlobalAveragePooling2D()(x)
    outputs = Dense(embedding_dim)(pooled_output)
    return Model(inputs, outputs)

import tensorflow as tf

# Define a simple Sequential model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(units=1, input_shape=[1], use_bias=True)
])

# Set weights so y = 0.5x + 2
weights = [tf.constant([[0.5]]), tf.constant([2.0])]
model.set_weights(weights)

# Compile (required even if not training)
model.compile(optimizer='sgd', loss='mean_squared_error')

# Export the model
export_path = './saved_model_half_plus_two/1'
tf.saved_model.save(model, export_path)

print(f"Model exported to: {export_path}")

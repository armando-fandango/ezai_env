import unittest

import tensorflow as tf

class TestTensorflow(unittest.TestCase):

    def test_tf_cuda_build(self):
        self.assertTrue(tf.test.is_built_with_cuda())

    def test_tf_cuda_available(self):
        if tf.test.is_built_with_cuda() and tf.test.gpu_device_name():
            print('GPU Devices: ',tf.config.list_physical_devices('GPU'))
            print('Tensorflow Default GPU Device: ',tf.test.gpu_device_name())
        self.assertTrue(tf.test.gpu_device_name())

if __name__ == '__main__':
    unittest.main()
import unittest

import torch

class TestTorch(unittest.TestCase):

    def test_torch_cuda_available(self):
        self.assertTrue(torch.cuda.is_available())

if __name__ == '__main__':
    unittest.main()